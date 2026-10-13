-- =====================================================================================
-- Red Social Pascualina · Pruebas de integridad
-- Ejecutar después de 01_ddl y 02_datos_prueba. Cada prueba intenta una operación inválida
-- y muestra un aviso (NOTICE) con el resultado. Todo se deshace al final con ROLLBACK.
-- =====================================================================================
SET search_path TO red_social;
BEGIN;

-- Función temporal: ejecuta una sentencia que debería fallar y muestra qué regla la rechazó.
CREATE OR REPLACE FUNCTION pg_temp.probar(numero INTEGER, descripcion TEXT, sentencia TEXT)
RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE
    restriccion TEXT;
BEGIN
    EXECUTE sentencia;
    RAISE NOTICE 'Prueba %: FALLÓ, la operación fue aceptada (%)', numero, descripcion;
EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS restriccion = CONSTRAINT_NAME;
    RAISE NOTICE 'Prueba %: OK, rechazada por % (%)', numero, coalesce(nullif(restriccion, ''), SQLERRM), descripcion;
END $$;

-- Pruebas de operaciones inválidas (deben ser rechazadas)
DO $$
BEGIN
    PERFORM pg_temp.probar(1,  'estudiante con un programa que no existe',
    $q$INSERT INTO estudiante (codigo_estudiante, nombres, apellidos, correo_institucional, fecha_nacimiento, semestre, codigo_programa)
       VALUES ('X1', 'A', 'B', 'x1@pascualbravo.edu.co', '2004-01-01', 2, 'NOEXISTE')$q$);
    PERFORM pg_temp.probar(2,  'correo institucional repetido',
    $q$INSERT INTO estudiante (codigo_estudiante, nombres, apellidos, correo_institucional, fecha_nacimiento, semestre, codigo_programa)
       VALUES ('X2', 'A', 'B', 'jhon.quiroz@pascualbravo.edu.co', '2004-01-01', 2, 'TDS')$q$);
    PERFORM pg_temp.probar(3,  'semestre fuera del rango 1 a 10',
    $q$UPDATE estudiante SET semestre = 15 WHERE codigo_estudiante = '20241001'$q$);
    PERFORM pg_temp.probar(4,  'nombre obligatorio vacío (NULL)',
    $q$UPDATE estudiante SET nombres = NULL WHERE codigo_estudiante = '20241001'$q$);
    PERFORM pg_temp.probar(5,  'un estudiante que se sigue a sí mismo',
    $q$INSERT INTO seguimiento (codigo_seguidor, codigo_seguido) VALUES ('20241001', '20241001')$q$);
    PERFORM pg_temp.probar(6,  'seguir dos veces a la misma persona',
    $q$INSERT INTO seguimiento (codigo_seguidor, codigo_seguido) VALUES ('20241001', '20221002')$q$);
    PERFORM pg_temp.probar(7,  'dos reacciones del mismo estudiante a la misma publicación',
    $q$INSERT INTO reaccion (codigo_estudiante, id_publicacion, tipo_reaccion) VALUES ('20241001', 1, 'Útil')$q$);
    PERFORM pg_temp.probar(8,  'tipo de grupo no permitido',
    $q$INSERT INTO grupo (nombre_grupo, tipo_grupo, codigo_creador) VALUES ('Grupo X', 'Fiesta', '20241001')$q$);
    PERFORM pg_temp.probar(9,  'evento que termina antes de empezar',
    $q$INSERT INTO evento (titulo, tipo_evento, fecha_hora_inicio, fecha_hora_fin, modalidad, lugar, cupo_maximo, codigo_organizador)
       VALUES ('Mal horario', 'Taller', '2026-11-01 10:00', '2026-11-01 08:00', 'Virtual', 'Meet', 10, '20241001')$q$);
    PERFORM pg_temp.probar(10, 'periodo académico con formato incorrecto',
    $q$UPDATE grupo_estudio SET periodo_academico = '26-II' WHERE id_grupo = 1$q$);
    PERFORM pg_temp.probar(11, 'borrar un programa que tiene estudiantes (ON DELETE RESTRICT)',
    $q$DELETE FROM programa_academico WHERE codigo_programa = 'TDS'$q$);
    PERFORM pg_temp.probar(12, 'borrar al creador de un grupo (ON DELETE RESTRICT)',
    $q$DELETE FROM estudiante WHERE codigo_estudiante = '20231005'$q$);
    PERFORM pg_temp.probar(13, 'modificar manualmente una clave IDENTITY',
    $q$INSERT INTO interes (id_interes, nombre_interes, categoria) VALUES (99, 'Ajedrez', 'Ocio')$q$);
END $$;

-- Pruebas de acciones en cascada (deben ser aceptadas)
UPDATE programa_academico SET codigo_programa = 'TDSW' WHERE codigo_programa = 'TDS';
SELECT 'Prueba 14: ON UPDATE CASCADE · estudiantes que ahora tienen el código TDSW' AS prueba,
       count(*) AS resultado FROM estudiante WHERE codigo_programa = 'TDSW';

DELETE FROM publicacion WHERE id_publicacion = 2;
SELECT 'Prueba 15: ON DELETE CASCADE · comentarios, etiquetas y pregunta de la publicación 2' AS prueba,
       (SELECT count(*) FROM comentario WHERE id_publicacion = 2)
     + (SELECT count(*) FROM publicacion_etiqueta WHERE id_publicacion = 2)
     + (SELECT count(*) FROM pregunta WHERE id_publicacion = 2) AS resultado;

DELETE FROM materia WHERE codigo_materia = 'WEB1';
DELETE FROM grupo WHERE id_grupo = 3;
SELECT 'Prueba 16: ON DELETE SET NULL · el torneo queda como evento independiente' AS prueba,
       count(*) AS resultado FROM evento WHERE id_evento = 3 AND id_grupo IS NULL;

ROLLBACK;
