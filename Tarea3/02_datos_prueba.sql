-- =====================================================================================
-- Red Social Pascualina · Datos de prueba
-- Ejecutar después de 01_ddl_red_social_pascualina.sql
-- =====================================================================================
SET search_path TO red_social;

-- Catálogos
INSERT INTO programa_academico (codigo_programa, nombre_programa, facultad, nivel_formacion) VALUES
    ('TDS', 'Tecnología en Desarrollo de Software', 'Facultad de Ingeniería', 'Tecnológico'),
    ('IS',  'Ingeniería de Software',               'Facultad de Ingeniería', 'Profesional universitario'),
    ('TDG', 'Tecnología en Diseño Gráfico',         'Facultad de Producción y Diseño', 'Tecnológico');

INSERT INTO materia (codigo_materia, nombre_materia, creditos) VALUES
    ('BD1',  'Bases de Datos I',          3),
    ('PRG1', 'Programación I',            4),
    ('MAT1', 'Matemáticas Discretas',     3),
    ('WEB1', 'Desarrollo Web',            3);

INSERT INTO interes (nombre_interes, categoria) VALUES
    ('Inteligencia artificial',    'Tecnología'),   -- id 1
    ('Videojuegos',                'Ocio'),         -- id 2
    ('Programación competitiva',   'Tecnología'),   -- id 3
    ('Fútbol',                     'Deporte'),      -- id 4
    ('Fotografía',                 'Arte');         -- id 5

INSERT INTO habilidad (nombre_habilidad, disciplina) VALUES
    ('Python',          'Programación'),  -- id 1
    ('SQL',             'Bases de datos'),-- id 2
    ('Diseño gráfico',  'Diseño'),        -- id 3
    ('Voleibol',        'Deporte'),       -- id 4
    ('Java',            'Programación');  -- id 5

-- Perfil
INSERT INTO estudiante (codigo_estudiante, nombres, apellidos, correo_institucional, fecha_nacimiento, semestre,
                        biografia, codigo_programa) VALUES
    ('20241001', 'Jhon Byron', 'Quiroz Pérez',  'jhon.quiroz@pascualbravo.edu.co',  '2003-05-10', 5, 'Me gustan las bases de datos.', 'TDS'),
    ('20221002', 'Laura',      'Gómez Ruiz',    'laura.gomez@pascualbravo.edu.co',  '2001-08-22', 9, 'Monitora de Programación I.',   'IS'),
    ('20261003', 'Andrés',     'Mejía Toro',    'andres.mejia@pascualbravo.edu.co', '2006-01-15', 1, NULL,                            'TDS'),
    ('20251004', 'Sara',       'Ríos Henao',    'sara.rios@pascualbravo.edu.co',    '2005-11-03', 3, 'Diseño y fotografía.',          'TDG'),
    ('20231005', 'Mateo',      'Cardona López', 'mateo.cardona@pascualbravo.edu.co','2002-02-28', 7, NULL,                            'IS'),
    ('20261006', 'Valentina',  'Arango Gil',    'valentina.arango@pascualbravo.edu.co', '2007-06-19', 1, NULL,                        'TDS');

INSERT INTO enlace_perfil (codigo_estudiante, url_enlace) VALUES
    ('20241001', 'https://github.com/jbquiroz'),
    ('20241001', 'https://www.linkedin.com/in/jbquiroz'),
    ('20251004', 'https://www.behance.net/sararios');

INSERT INTO estudiante_interes (codigo_estudiante, id_interes) VALUES
    ('20241001', 1), ('20241001', 3), ('20221002', 3), ('20221002', 1),
    ('20261003', 2), ('20251004', 5), ('20231005', 2), ('20231005', 4), ('20261006', 1);

INSERT INTO estudiante_habilidad (codigo_estudiante, id_habilidad, nivel) VALUES
    ('20241001', 2, 'Intermedio'), ('20241001', 1, 'Básico'),
    ('20221002', 1, 'Avanzado'),   ('20221002', 5, 'Avanzado'),
    ('20251004', 3, 'Avanzado'),   ('20231005', 4, 'Intermedio');

-- Conexiones
INSERT INTO seguimiento (codigo_seguidor, codigo_seguido) VALUES
    ('20241001', '20221002'), ('20261003', '20221002'), ('20261006', '20241001'),
    ('20221002', '20241001'), ('20251004', '20231005');

INSERT INTO mentoria (codigo_mentor, codigo_aprendiz, tema, fecha_inicio, estado) VALUES
    ('20221002', '20261003', 'Programación I',   '2026-08-10', 'Activa'),
    ('20221002', '20241001', 'Bases de Datos I', '2026-08-15', 'Activa'),
    ('20231005', '20261006', 'Matemáticas Discretas', '2026-02-01', 'Finalizada');

-- Grupos (uno de cada tipo) y sus subclases
INSERT INTO grupo (nombre_grupo, descripcion, es_privado, tipo_grupo, codigo_creador) VALUES
    ('Repaso de Bases de Datos I', 'Ejercicios de normalización y SQL',   FALSE, 'Estudio',  '20241001'), -- id 1
    ('Los Pascualinos Hack',       'Equipo para la hackatón de la ciudad', TRUE,  'Hackaton', '20231005'), -- id 2
    ('Club de Videojuegos',        'Torneos y partidas los viernes',       FALSE, 'Club',     '20261003'); -- id 3

INSERT INTO grupo_estudio   (id_grupo, periodo_academico, codigo_materia) VALUES (1, '2026-2', 'BD1');
INSERT INTO equipo_hackaton (id_grupo, nombre_hackaton, nombre_proyecto, max_integrantes)
    VALUES (2, 'Hackatón Medellín 2026', 'App de movilidad estudiantil', 5);
INSERT INTO club_interes    (id_grupo, id_interes) VALUES (3, 2);

INSERT INTO membresia (codigo_estudiante, id_grupo, rol) VALUES
    ('20241001', 1, 'Administrador'), ('20261003', 1, 'Miembro'), ('20221002', 1, 'Moderador'),
    ('20231005', 2, 'Administrador'), ('20241001', 2, 'Miembro'),
    ('20261003', 3, 'Administrador'), ('20231005', 3, 'Miembro');

-- Publicaciones (una general y una de cada subclase)
INSERT INTO publicacion (contenido, visibilidad, tipo_publicacion, codigo_autor, id_grupo) VALUES
    ('¡Bienvenidos a la Red Social Pascualina!',                         'Pública', 'General',  '20221002', NULL), -- id 1
    ('¿Cómo identifico una dependencia transitiva en la tarea 2?',       'Grupo',   'Pregunta', '20261003', 1),    -- id 2
    ('Les comparto la guía oficial de PostgreSQL en español.',           'Pública', 'Recurso',  '20241001', NULL), -- id 3
    ('Nueva versión de PostgreSQL con mejoras de rendimiento.',          'Pública', 'Noticia',  '20231005', NULL), -- id 4
    ('Cuando el script corre a la primera sin errores.',                 'Pública', 'Meme',     '20251004', NULL); -- id 5

INSERT INTO publicacion_etiqueta (id_publicacion, etiqueta) VALUES
    (2, 'BD1'), (2, 'normalizacion'), (3, 'PostgreSQL'), (4, 'PostgreSQL'), (5, 'humor');

INSERT INTO pregunta (id_publicacion, esta_resuelta, codigo_materia) VALUES (2, FALSE, 'BD1');
INSERT INTO recurso  (id_publicacion, url_recurso, formato) VALUES (3, 'https://www.postgresql.org/docs/', 'Página web');
INSERT INTO noticia  (id_publicacion, fuente, url_noticia) VALUES (4, 'PostgreSQL Global Development Group', 'https://www.postgresql.org/about/news/');
INSERT INTO meme     (id_publicacion, imagen) VALUES (5, '/media/memes/script_sin_errores.png');

INSERT INTO comentario (id_publicacion, num_comentario, texto, codigo_autor) VALUES
    (2, 1, 'Revisa si un atributo no clave depende de otro atributo no clave.', '20221002'),
    (2, 2, '¡Gracias, ya lo entendí!',                                           '20261003'),
    (5, 1, 'Jajaja, eso nunca pasa.',                                            '20241001');

INSERT INTO reaccion (codigo_estudiante, id_publicacion, tipo_reaccion) VALUES
    ('20241001', 1, 'Me gusta'), ('20261003', 2, 'Útil'), ('20221002', 3, 'Útil'),
    ('20241001', 5, 'Divertido'), ('20261006', 5, 'Me encanta');

-- Eventos
INSERT INTO evento (titulo, descripcion, tipo_evento, fecha_hora_inicio, fecha_hora_fin, modalidad, lugar,
                    cupo_maximo, codigo_organizador, id_grupo) VALUES
    ('Repaso para el parcial de BD1', 'Ejercicios de SQL', 'Reunión de estudio', '2026-10-20 14:00', '2026-10-20 16:00',
     'Presencial', 'Bloque 7, aula 302', 15, '20241001', 1),                                                 -- id 1
    ('Taller de PostgreSQL',          'Instalación y primeros pasos', 'Taller', '2026-10-24 09:00', '2026-10-24 12:00',
     'Virtual', 'https://meet.example.com/pg', 40, '20221002', NULL),                                        -- id 2
    ('Torneo de videojuegos',         NULL, 'Actividad social', '2026-10-31 15:00', '2026-10-31 19:00',
     'Presencial', 'Bienestar Universitario', 32, '20261003', 3);                                            -- id 3

INSERT INTO inscripcion (codigo_estudiante, id_evento, estado_asistencia) VALUES
    ('20261003', 1, 'Inscrito'), ('20221002', 1, 'Inscrito'),
    ('20241001', 2, 'Inscrito'), ('20261006', 2, 'Inscrito'), ('20251004', 2, 'Inscrito'),
    ('20231005', 3, 'Inscrito');
