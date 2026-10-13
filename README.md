# Bases de Datos I · Grupo 1

En este repositorio estaré subiendo las tareas de la asignatura **Bases de Datos I** de la **Tecnología en Desarrollo de Software** de la **Institución Universitaria Pascual Bravo**.

## Autor

| Nombre | Rol | Grupo |
|---|---|---|
| Jhon Byron Quiroz Pérez | Integrante | Grupo 1 |

**Docente:** Oralia Cortes Grajales


## Tareas

| Tarea | Tema | Carpeta | Estado |
|---|---|---|---|
| Tarea 1 | Modelo conceptual (Entidad-Relación) de la **Red Social Pascualina** | [`Tarea1/`](Tarea1/) | Entregada |
| Tarea 2 | Modelo lógico relacional normalizado (1FN, 2FN, 3FN) y diccionario de datos | [`Tarea2/`](Tarea2/) | Entregada |
| Tarea 3 | Modelo físico en PostgreSQL: scripts DDL, datos de prueba y pruebas de integridad | [`Tarea3/`](Tarea3/) | Entregada |

## Tarea 1 · Red Social Pascualina

**a. Nombre del proyecto:** Red Social Pascualina, una red social estudiantil para crear perfiles, conectar con compañeros y mentores, publicar actualizaciones, formar grupos y programar eventos.

**b. Integrantes del equipo:** Jhon Byron Quiroz Pérez (Grupo 1).



## Tarea 2 · Modelo lógico de la Red Social Pascualina

A partir del modelo conceptual de la Tarea 1 se diseñó el **modelo lógico relacional**: 25 tablas, 102 columnas y 34 claves foráneas, normalizadas hasta la **tercera forma normal (3FN)** y documentadas con un **diccionario de datos** (claves primarias, foráneas y únicas, tipos de datos genéricos y justificación de cada atributo).

## Tarea 3 · Modelo físico de la Red Social Pascualina

El modelo lógico de la Tarea 2 se implementó como **modelo físico en PostgreSQL 16** (esquema `red_social`): 25 tablas con sus claves primarias, foráneas, restricciones `UNIQUE` y `CHECK`, 17 índices sobre claves foráneas y comentarios guardados en la base de datos.

| Archivo | Contenido |
|---|---|
| [`Informe_Tarea3_ModeloFisico_RedSocialPascualina (1).pdf`](<Tarea3/Informe_Tarea3_ModeloFisico_RedSocialPascualina (1).pdf>) | Informe de la tarea |
| [`01_ddl_red_social_pascualina.sql`](Tarea3/01_ddl_red_social_pascualina.sql) | Crea el esquema, las tablas, los índices y los comentarios (se puede re-ejecutar) |
| [`02_datos_prueba.sql`](Tarea3/02_datos_prueba.sql) | Inserta datos de prueba en todas las tablas |
| [`03_pruebas_integridad.sql`](Tarea3/03_pruebas_integridad.sql) | 13 pruebas que intentan operaciones inválidas y verifican que las restricciones las rechacen (todo se deshace con `ROLLBACK`) |
| [`modelo_fisico_RedSocialPascualina.png`](Tarea3/modelo_fisico_RedSocialPascualina.png) | Diagrama del modelo físico |
| [`Video_Presentacion.md`](Tarea3/Video_Presentacion.md) | Enlace al video de presentación |

Los scripts se ejecutan en orden: `01` → `02` → `03`.



## Estructura del repositorio

```
├── README.md
├── Tarea1/    ← informe (PDF), diagrama MER y enlace al video
├── Tarea2/    ← informe (PDF), diagrama del modelo lógico y enlace al video
└── Tarea3/    ← informe (PDF), scripts SQL, diagrama del modelo físico y enlace al video
```

Cada nueva tarea tendrá su propia carpeta (`Tarea4/`, …).

## Herramientas

- draw.io (diagrams.net)
- PostgreSQL 16
- Git y GitHub
- YouTube

---

Institución Universitaria Pascual Bravo · Medellín, 2026
