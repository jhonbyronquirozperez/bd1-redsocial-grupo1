-- =====================================================================================
-- Red Social Pascualina · Modelo físico (DDL)
-- SGBD: PostgreSQL 16 · Esquema: red_social
-- Bases de Datos I · Tarea 3 · Grupo 1 · Jhon Byron Quiroz Pérez
-- Fuente: modelo lógico de la Tarea 2 (25 tablas en 3FN)
--
-- Estructura del script:
--   1. Esquema           (se elimina y se vuelve a crear para que el script se pueda re-ejecutar)
--   2. Tablas            (25 tablas, creadas en orden de dependencias: primero las tablas padre)
--   3. Índices           (sobre las claves foráneas que no encabezan una clave primaria)
--   4. Comentarios       (documentación guardada dentro de la base de datos)
--
-- Nomenclatura de restricciones: pk_ clave primaria · fk_ clave foránea · uq_ única · ck_ CHECK · ix_ índice
-- =====================================================================================

-- 1. ESQUEMA ---------------------------------------------------------------------------
DROP SCHEMA IF EXISTS red_social CASCADE;
CREATE SCHEMA red_social;
SET search_path TO red_social;

-- 2. TABLAS ----------------------------------------------------------------------------

-- 2.1 Catálogos (tablas sin claves foráneas)

-- programa_academico: Programas académicos de la institución (área de estudio del estudiante).
CREATE TABLE programa_academico (
    codigo_programa  VARCHAR(10)   NOT NULL,
    nombre_programa  VARCHAR(100)  NOT NULL,
    facultad         VARCHAR(100)  NOT NULL,
    nivel_formacion  VARCHAR(30)   NOT NULL,
    CONSTRAINT pk_programa_academico PRIMARY KEY (codigo_programa),
    CONSTRAINT uq_programa_nombre UNIQUE (nombre_programa),
    CONSTRAINT ck_programa_nivel_formacion CHECK (nivel_formacion IN ('Técnico profesional', 'Tecnológico', 'Profesional universitario'))
);

-- materia: Asignaturas del plan de estudios.
CREATE TABLE materia (
    codigo_materia  VARCHAR(10)   NOT NULL,
    nombre_materia  VARCHAR(100)  NOT NULL,
    creditos        SMALLINT      NOT NULL,
    CONSTRAINT pk_materia PRIMARY KEY (codigo_materia),
    CONSTRAINT ck_materia_creditos CHECK (creditos > 0)
);

-- interes: Catálogo de intereses (inteligencia artificial, videojuegos, fútbol…).
CREATE TABLE interes (
    id_interes      INTEGER GENERATED ALWAYS AS IDENTITY  NOT NULL,
    nombre_interes  VARCHAR(60)                           NOT NULL,
    categoria       VARCHAR(40)                           NOT NULL,
    CONSTRAINT pk_interes PRIMARY KEY (id_interes),
    CONSTRAINT uq_interes_nombre UNIQUE (nombre_interes)
);

-- habilidad: Catálogo de habilidades en disciplinas o deportes.
CREATE TABLE habilidad (
    id_habilidad      INTEGER GENERATED ALWAYS AS IDENTITY  NOT NULL,
    nombre_habilidad  VARCHAR(60)                           NOT NULL,
    disciplina        VARCHAR(60)                           NOT NULL,
    CONSTRAINT pk_habilidad PRIMARY KEY (id_habilidad),
    CONSTRAINT uq_habilidad_nombre UNIQUE (nombre_habilidad)
);

-- 2.2 Módulo perfil y conexiones

-- estudiante: Estudiantes registrados en la red social con los datos de su perfil.
CREATE TABLE estudiante (
    codigo_estudiante     VARCHAR(15)   NOT NULL,
    nombres               VARCHAR(60)   NOT NULL,
    apellidos             VARCHAR(60)   NOT NULL,
    correo_institucional  VARCHAR(100)  NOT NULL,
    fecha_nacimiento      DATE          NOT NULL,
    semestre              SMALLINT      NOT NULL,
    biografia             VARCHAR(500)  NULL,
    foto_perfil           VARCHAR(255)  NULL,
    fecha_registro        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    codigo_programa       VARCHAR(10)   NOT NULL,
    CONSTRAINT pk_estudiante PRIMARY KEY (codigo_estudiante),
    CONSTRAINT uq_estudiante_correo UNIQUE (correo_institucional),
    CONSTRAINT ck_estudiante_semestre CHECK (semestre BETWEEN 1 AND 10),
    CONSTRAINT ck_estudiante_correo CHECK (correo_institucional LIKE '%_@_%._%'),
    CONSTRAINT fk_estudiante_programa FOREIGN KEY (codigo_programa) REFERENCES programa_academico (codigo_programa)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- enlace_perfil: Enlaces externos del perfil (GitHub, LinkedIn, portafolio).
CREATE TABLE enlace_perfil (
    codigo_estudiante  VARCHAR(15)   NOT NULL,
    url_enlace         VARCHAR(255)  NOT NULL,
    CONSTRAINT pk_enlace_perfil PRIMARY KEY (codigo_estudiante, url_enlace),
    CONSTRAINT fk_enlace_perfil_estudiante FOREIGN KEY (codigo_estudiante) REFERENCES estudiante (codigo_estudiante)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- estudiante_interes: Intereses registrados por cada estudiante.
CREATE TABLE estudiante_interes (
    codigo_estudiante  VARCHAR(15)  NOT NULL,
    id_interes         INTEGER      NOT NULL,
    CONSTRAINT pk_estudiante_interes PRIMARY KEY (codigo_estudiante, id_interes),
    CONSTRAINT fk_est_interes_estudiante FOREIGN KEY (codigo_estudiante) REFERENCES estudiante (codigo_estudiante)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_est_interes_interes FOREIGN KEY (id_interes) REFERENCES interes (id_interes)
        ON DELETE CASCADE ON UPDATE RESTRICT
);

-- estudiante_habilidad: Habilidades que domina cada estudiante y su nivel.
CREATE TABLE estudiante_habilidad (
    codigo_estudiante  VARCHAR(15)  NOT NULL,
    id_habilidad       INTEGER      NOT NULL,
    nivel              VARCHAR(12)  NOT NULL,
    CONSTRAINT pk_estudiante_habilidad PRIMARY KEY (codigo_estudiante, id_habilidad),
    CONSTRAINT ck_est_habilidad_nivel CHECK (nivel IN ('Básico', 'Intermedio', 'Avanzado')),
    CONSTRAINT fk_est_habilidad_estudiante FOREIGN KEY (codigo_estudiante) REFERENCES estudiante (codigo_estudiante)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_est_habilidad_habilidad FOREIGN KEY (id_habilidad) REFERENCES habilidad (id_habilidad)
        ON DELETE CASCADE ON UPDATE RESTRICT
);

-- seguimiento: Quién sigue a quién dentro de la red.
CREATE TABLE seguimiento (
    codigo_seguidor    VARCHAR(15)  NOT NULL,
    codigo_seguido     VARCHAR(15)  NOT NULL,
    fecha_seguimiento  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_seguimiento PRIMARY KEY (codigo_seguidor, codigo_seguido),
    CONSTRAINT ck_seguimiento_distintos CHECK (codigo_seguidor <> codigo_seguido),
    CONSTRAINT fk_seguimiento_seguidor FOREIGN KEY (codigo_seguidor) REFERENCES estudiante (codigo_estudiante)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_seguimiento_seguido FOREIGN KEY (codigo_seguido) REFERENCES estudiante (codigo_estudiante)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- mentoria: Mentorías entre estudiantes de semestres avanzados y sus aprendices.
CREATE TABLE mentoria (
    codigo_mentor    VARCHAR(15)   NOT NULL,
    codigo_aprendiz  VARCHAR(15)   NOT NULL,
    tema             VARCHAR(100)  NOT NULL,
    fecha_inicio     DATE          NOT NULL DEFAULT CURRENT_DATE,
    estado           VARCHAR(12)   NOT NULL DEFAULT 'Activa',
    CONSTRAINT pk_mentoria PRIMARY KEY (codigo_mentor, codigo_aprendiz),
    CONSTRAINT ck_mentoria_estado CHECK (estado IN ('Activa', 'Finalizada')),
    CONSTRAINT ck_mentoria_distintos CHECK (codigo_mentor <> codigo_aprendiz),
    CONSTRAINT fk_mentoria_mentor FOREIGN KEY (codigo_mentor) REFERENCES estudiante (codigo_estudiante)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_mentoria_aprendiz FOREIGN KEY (codigo_aprendiz) REFERENCES estudiante (codigo_estudiante)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 2.3 Módulo grupos

-- grupo: Grupos creados en la red (datos comunes a los tres tipos).
CREATE TABLE grupo (
    id_grupo        INTEGER GENERATED ALWAYS AS IDENTITY  NOT NULL,
    nombre_grupo    VARCHAR(80)                           NOT NULL,
    descripcion     VARCHAR(500)                          NULL,
    es_privado      BOOLEAN                               NOT NULL DEFAULT FALSE,
    fecha_creacion  DATE                                  NOT NULL DEFAULT CURRENT_DATE,
    tipo_grupo      VARCHAR(10)                           NOT NULL,
    codigo_creador  VARCHAR(15)                           NOT NULL,
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT ck_grupo_tipo_grupo CHECK (tipo_grupo IN ('Estudio', 'Hackaton', 'Club')),
    CONSTRAINT fk_grupo_creador FOREIGN KEY (codigo_creador) REFERENCES estudiante (codigo_estudiante)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- grupo_estudio: Grupos de estudio por materia.
CREATE TABLE grupo_estudio (
    id_grupo           INTEGER      NOT NULL,
    periodo_academico  CHAR(6)      NOT NULL,
    codigo_materia     VARCHAR(10)  NOT NULL,
    CONSTRAINT pk_grupo_estudio PRIMARY KEY (id_grupo),
    CONSTRAINT ck_grupo_estudio_periodo CHECK (periodo_academico ~ '^[0-9]{4}-[12]$'),
    CONSTRAINT fk_grupo_estudio_grupo FOREIGN KEY (id_grupo) REFERENCES grupo (id_grupo)
        ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_grupo_estudio_materia FOREIGN KEY (codigo_materia) REFERENCES materia (codigo_materia)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- equipo_hackaton: Equipos para hackatones.
CREATE TABLE equipo_hackaton (
    id_grupo         INTEGER       NOT NULL,
    nombre_hackaton  VARCHAR(100)  NOT NULL,
    nombre_proyecto  VARCHAR(100)  NULL,
    max_integrantes  SMALLINT      NOT NULL,
    CONSTRAINT pk_equipo_hackaton PRIMARY KEY (id_grupo),
    CONSTRAINT ck_equipo_max_integrantes CHECK (max_integrantes > 0),
    CONSTRAINT fk_equipo_grupo FOREIGN KEY (id_grupo) REFERENCES grupo (id_grupo)
        ON DELETE CASCADE ON UPDATE RESTRICT
);

-- club_interes: Clubes de interés (videojuegos, programación competitiva…).
CREATE TABLE club_interes (
    id_grupo    INTEGER  NOT NULL,
    id_interes  INTEGER  NOT NULL,
    CONSTRAINT pk_club_interes PRIMARY KEY (id_grupo),
    CONSTRAINT fk_club_interes_grupo FOREIGN KEY (id_grupo) REFERENCES grupo (id_grupo)
        ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_club_interes_interes FOREIGN KEY (id_interes) REFERENCES interes (id_interes)
        ON DELETE RESTRICT ON UPDATE RESTRICT
);

-- membresia: Miembros de cada grupo y su rol.
CREATE TABLE membresia (
    codigo_estudiante  VARCHAR(15)  NOT NULL,
    id_grupo           INTEGER      NOT NULL,
    rol                VARCHAR(15)  NOT NULL DEFAULT 'Miembro',
    fecha_union        DATE         NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT pk_membresia PRIMARY KEY (codigo_estudiante, id_grupo),
    CONSTRAINT ck_membresia_rol CHECK (rol IN ('Administrador', 'Moderador', 'Miembro')),
    CONSTRAINT fk_membresia_estudiante FOREIGN KEY (codigo_estudiante) REFERENCES estudiante (codigo_estudiante)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_membresia_grupo FOREIGN KEY (id_grupo) REFERENCES grupo (id_grupo)
        ON DELETE CASCADE ON UPDATE RESTRICT
);

-- 2.4 Módulo publicaciones

-- publicacion: Publicaciones de los estudiantes (datos comunes a todos los tipos).
CREATE TABLE publicacion (
    id_publicacion    INTEGER GENERATED ALWAYS AS IDENTITY  NOT NULL,
    contenido         VARCHAR(2000)                         NOT NULL,
    fecha_hora        TIMESTAMP                             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    visibilidad       VARCHAR(15)                           NOT NULL DEFAULT 'Pública',
    tipo_publicacion  VARCHAR(10)                           NOT NULL DEFAULT 'General',
    codigo_autor      VARCHAR(15)                           NOT NULL,
    id_grupo          INTEGER                               NULL,
    CONSTRAINT pk_publicacion PRIMARY KEY (id_publicacion),
    CONSTRAINT ck_publicacion_visibilidad CHECK (visibilidad IN ('Pública', 'Seguidores', 'Grupo')),
    CONSTRAINT ck_publicacion_tipo_publicacion CHECK (tipo_publicacion IN ('General', 'Pregunta', 'Recurso', 'Noticia', 'Meme')),
    CONSTRAINT fk_publicacion_autor FOREIGN KEY (codigo_autor) REFERENCES estudiante (codigo_estudiante)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_publicacion_grupo FOREIGN KEY (id_grupo) REFERENCES grupo (id_grupo)
        ON DELETE CASCADE ON UPDATE RESTRICT
);

-- publicacion_etiqueta: Etiquetas (#BD1, #Python…) de cada publicación.
CREATE TABLE publicacion_etiqueta (
    id_publicacion  INTEGER      NOT NULL,
    etiqueta        VARCHAR(50)  NOT NULL,
    CONSTRAINT pk_publicacion_etiqueta PRIMARY KEY (id_publicacion, etiqueta),
    CONSTRAINT fk_pub_etiqueta_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion (id_publicacion)
        ON DELETE CASCADE ON UPDATE RESTRICT
);

-- pregunta: Preguntas sobre tareas.
CREATE TABLE pregunta (
    id_publicacion  INTEGER      NOT NULL,
    esta_resuelta   BOOLEAN      NOT NULL DEFAULT FALSE,
    codigo_materia  VARCHAR(10)  NULL,
    CONSTRAINT pk_pregunta PRIMARY KEY (id_publicacion),
    CONSTRAINT fk_pregunta_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion (id_publicacion)
        ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_pregunta_materia FOREIGN KEY (codigo_materia) REFERENCES materia (codigo_materia)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- recurso: Recursos útiles compartidos.
CREATE TABLE recurso (
    id_publicacion  INTEGER       NOT NULL,
    url_recurso     VARCHAR(255)  NOT NULL,
    formato         VARCHAR(20)   NOT NULL,
    CONSTRAINT pk_recurso PRIMARY KEY (id_publicacion),
    CONSTRAINT ck_recurso_formato CHECK (formato IN ('PDF', 'Video', 'Repositorio', 'Página web', 'Otro')),
    CONSTRAINT fk_recurso_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion (id_publicacion)
        ON DELETE CASCADE ON UPDATE RESTRICT
);

-- noticia: Noticias de la industria tecnológica.
CREATE TABLE noticia (
    id_publicacion  INTEGER       NOT NULL,
    fuente          VARCHAR(100)  NOT NULL,
    url_noticia     VARCHAR(255)  NOT NULL,
    CONSTRAINT pk_noticia PRIMARY KEY (id_publicacion),
    CONSTRAINT fk_noticia_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion (id_publicacion)
        ON DELETE CASCADE ON UPDATE RESTRICT
);

-- meme: Memes de la vida universitaria.
CREATE TABLE meme (
    id_publicacion  INTEGER       NOT NULL,
    imagen          VARCHAR(255)  NOT NULL,
    CONSTRAINT pk_meme PRIMARY KEY (id_publicacion),
    CONSTRAINT fk_meme_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion (id_publicacion)
        ON DELETE CASCADE ON UPDATE RESTRICT
);

-- comentario: Comentarios escritos en las publicaciones.
CREATE TABLE comentario (
    id_publicacion  INTEGER        NOT NULL,
    num_comentario  INTEGER        NOT NULL,
    texto           VARCHAR(1000)  NOT NULL,
    fecha_hora      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    codigo_autor    VARCHAR(15)    NOT NULL,
    CONSTRAINT pk_comentario PRIMARY KEY (id_publicacion, num_comentario),
    CONSTRAINT ck_comentario_num CHECK (num_comentario > 0),
    CONSTRAINT fk_comentario_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion (id_publicacion)
        ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_comentario_autor FOREIGN KEY (codigo_autor) REFERENCES estudiante (codigo_estudiante)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- reaccion: Reacciones de los estudiantes a las publicaciones.
CREATE TABLE reaccion (
    codigo_estudiante  VARCHAR(15)  NOT NULL,
    id_publicacion     INTEGER      NOT NULL,
    tipo_reaccion      VARCHAR(15)  NOT NULL,
    fecha_reaccion     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_reaccion PRIMARY KEY (codigo_estudiante, id_publicacion),
    CONSTRAINT ck_reaccion_tipo_reaccion CHECK (tipo_reaccion IN ('Me gusta', 'Útil', 'Divertido', 'Me encanta')),
    CONSTRAINT fk_reaccion_estudiante FOREIGN KEY (codigo_estudiante) REFERENCES estudiante (codigo_estudiante)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reaccion_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion (id_publicacion)
        ON DELETE CASCADE ON UPDATE RESTRICT
);

-- 2.5 Módulo eventos

-- evento: Reuniones de estudio, talleres y actividades sociales.
CREATE TABLE evento (
    id_evento           INTEGER GENERATED ALWAYS AS IDENTITY  NOT NULL,
    titulo              VARCHAR(100)                          NOT NULL,
    descripcion         VARCHAR(500)                          NULL,
    tipo_evento         VARCHAR(20)                           NOT NULL,
    fecha_hora_inicio   TIMESTAMP                             NOT NULL,
    fecha_hora_fin      TIMESTAMP                             NOT NULL,
    modalidad           VARCHAR(10)                           NOT NULL,
    lugar               VARCHAR(150)                          NOT NULL,
    cupo_maximo         SMALLINT                              NOT NULL,
    codigo_organizador  VARCHAR(15)                           NOT NULL,
    id_grupo            INTEGER                               NULL,
    CONSTRAINT pk_evento PRIMARY KEY (id_evento),
    CONSTRAINT ck_evento_tipo_evento CHECK (tipo_evento IN ('Reunión de estudio', 'Taller', 'Actividad social')),
    CONSTRAINT ck_evento_modalidad CHECK (modalidad IN ('Presencial', 'Virtual', 'Híbrida')),
    CONSTRAINT ck_evento_cupo_maximo CHECK (cupo_maximo > 0),
    CONSTRAINT ck_evento_horario CHECK (fecha_hora_fin > fecha_hora_inicio),
    CONSTRAINT fk_evento_organizador FOREIGN KEY (codigo_organizador) REFERENCES estudiante (codigo_estudiante)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_evento_grupo FOREIGN KEY (id_grupo) REFERENCES grupo (id_grupo)
        ON DELETE SET NULL ON UPDATE RESTRICT
);

-- inscripcion: Inscripciones de estudiantes a eventos.
CREATE TABLE inscripcion (
    codigo_estudiante  VARCHAR(15)  NOT NULL,
    id_evento          INTEGER      NOT NULL,
    fecha_inscripcion  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_asistencia  VARCHAR(12)  NOT NULL DEFAULT 'Inscrito',
    CONSTRAINT pk_inscripcion PRIMARY KEY (codigo_estudiante, id_evento),
    CONSTRAINT ck_inscripcion_estado_asistencia CHECK (estado_asistencia IN ('Inscrito', 'Asistió', 'No asistió')),
    CONSTRAINT fk_inscripcion_estudiante FOREIGN KEY (codigo_estudiante) REFERENCES estudiante (codigo_estudiante)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_inscripcion_evento FOREIGN KEY (id_evento) REFERENCES evento (id_evento)
        ON DELETE CASCADE ON UPDATE RESTRICT
);

-- 3. ÍNDICES ---------------------------------------------------------------------------
-- PostgreSQL crea índices para PRIMARY KEY y UNIQUE, pero no para FOREIGN KEY.
CREATE INDEX ix_estudiante_programa ON estudiante (codigo_programa);
CREATE INDEX ix_est_interes_interes ON estudiante_interes (id_interes);
CREATE INDEX ix_est_habilidad_habilidad ON estudiante_habilidad (id_habilidad);
CREATE INDEX ix_seguimiento_seguido ON seguimiento (codigo_seguido);
CREATE INDEX ix_mentoria_aprendiz ON mentoria (codigo_aprendiz);
CREATE INDEX ix_grupo_creador ON grupo (codigo_creador);
CREATE INDEX ix_grupo_estudio_materia ON grupo_estudio (codigo_materia);
CREATE INDEX ix_club_interes_interes ON club_interes (id_interes);
CREATE INDEX ix_membresia_grupo ON membresia (id_grupo);
CREATE INDEX ix_publicacion_autor ON publicacion (codigo_autor);
CREATE INDEX ix_publicacion_grupo ON publicacion (id_grupo);
CREATE INDEX ix_pregunta_materia ON pregunta (codigo_materia);
CREATE INDEX ix_comentario_autor ON comentario (codigo_autor);
CREATE INDEX ix_reaccion_publicacion ON reaccion (id_publicacion);
CREATE INDEX ix_evento_organizador ON evento (codigo_organizador);
CREATE INDEX ix_evento_grupo ON evento (id_grupo);
CREATE INDEX ix_inscripcion_evento ON inscripcion (id_evento);

-- 4. COMENTARIOS -----------------------------------------------------------------------
COMMENT ON TABLE programa_academico IS 'Programas académicos de la institución (área de estudio del estudiante).';
COMMENT ON TABLE materia IS 'Asignaturas del plan de estudios.';
COMMENT ON TABLE interes IS 'Catálogo de intereses (inteligencia artificial, videojuegos, fútbol…).';
COMMENT ON TABLE habilidad IS 'Catálogo de habilidades en disciplinas o deportes.';
COMMENT ON TABLE estudiante IS 'Estudiantes registrados en la red social con los datos de su perfil.';
COMMENT ON TABLE enlace_perfil IS 'Enlaces externos del perfil (GitHub, LinkedIn, portafolio).';
COMMENT ON TABLE estudiante_interes IS 'Intereses registrados por cada estudiante.';
COMMENT ON TABLE estudiante_habilidad IS 'Habilidades que domina cada estudiante y su nivel.';
COMMENT ON TABLE seguimiento IS 'Quién sigue a quién dentro de la red.';
COMMENT ON TABLE mentoria IS 'Mentorías entre estudiantes de semestres avanzados y sus aprendices.';
COMMENT ON TABLE grupo IS 'Grupos creados en la red (datos comunes a los tres tipos).';
COMMENT ON TABLE grupo_estudio IS 'Grupos de estudio por materia.';
COMMENT ON TABLE equipo_hackaton IS 'Equipos para hackatones.';
COMMENT ON TABLE club_interes IS 'Clubes de interés (videojuegos, programación competitiva…).';
COMMENT ON TABLE membresia IS 'Miembros de cada grupo y su rol.';
COMMENT ON TABLE publicacion IS 'Publicaciones de los estudiantes (datos comunes a todos los tipos).';
COMMENT ON TABLE publicacion_etiqueta IS 'Etiquetas (#BD1, #Python…) de cada publicación.';
COMMENT ON TABLE pregunta IS 'Preguntas sobre tareas.';
COMMENT ON TABLE recurso IS 'Recursos útiles compartidos.';
COMMENT ON TABLE noticia IS 'Noticias de la industria tecnológica.';
COMMENT ON TABLE meme IS 'Memes de la vida universitaria.';
COMMENT ON TABLE comentario IS 'Comentarios escritos en las publicaciones.';
COMMENT ON TABLE reaccion IS 'Reacciones de los estudiantes a las publicaciones.';
COMMENT ON TABLE evento IS 'Reuniones de estudio, talleres y actividades sociales.';
COMMENT ON TABLE inscripcion IS 'Inscripciones de estudiantes a eventos.';
