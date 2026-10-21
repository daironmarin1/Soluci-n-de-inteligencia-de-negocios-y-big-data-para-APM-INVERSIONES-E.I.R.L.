# APM Inversiones — Solución de Business Intelligence

## Descripción

Repositorio del proyecto de Business Intelligence para analizar la asistencia de practicantes de APM Inversiones E.I.R.L. Incluye el modelo dimensional y el proceso ETL implementados en SQL Server, el dashboard original de Power BI y scripts de demostración con datos ficticios. **No se publican los datos personales reales.**

La solución original registra 7,111 asistencias de 128 practicantes. La base `ASISTENCIA_BI_DEMO` es un entorno independiente para reproducir el proceso ETL con 10 asistencias ficticias de 3 practicantes. El componente Big Data no se implementa en esta entrega, según el alcance comunicado por el equipo; su exclusión de la rúbrica debe confirmarse con el docente.

## Dependencias

- Microsoft SQL Server con soporte para los scripts T-SQL incluidos (versión exacta no documentada).
- SQL Server Management Studio (SSMS).
- Power BI Desktop para abrir `powerbi/APMinversiones.pbix` (versión exacta no documentada).
- Permisos para crear una base de datos, tablas y procedimientos almacenados en una instancia de prueba.

## Estructura del repositorio

```text
APM_INVERSIONES_BI_FINAL/
├── README.md
├── sql/
│   ├── 00_crear_base_demo.sql
│   ├── 01_crear_tabla_practicante.sql
│   ├── 02_crear_tabla_asistencia.sql
│   ├── 03_crear_fact_asistencia.sql
│   ├── 04_crear_dim_practicante.sql
│   ├── 05_crear_dim_estado.sql
│   ├── 06_crear_dim_tiempo.sql
│   ├── 07_etl_asistencia.sql
│   ├── 08_actualizar_modelo_bi.sql
│   ├── 09_datos_ficticios.sql
│   └── 10_ejecutar_y_validar.sql
├── powerbi/
│   └── APMinversiones.pbix
└── evidencias/
    ├── 01_dashboard_final.png
    ├── 02_modelo_powerbi.png
    ├── 03_etl_real.png
    └── 04_etl_demo.png
```

La carpeta `evidencias/` y sus cuatro imágenes deben incorporarse al repositorio antes de publicarlo. La evidencia `03_etl_real.png` documenta una **consulta de validación**, no necesariamente una nueva ejecución del ETL.

## Reproducción del experimento SQL

1. Abrir SSMS y conectarse a una instancia de SQL Server de prueba.
2. Ejecutar `sql/00_crear_base_demo.sql` para crear `ASISTENCIA_BI_DEMO`.
3. Ejecutar los scripts `01` a `08` en orden ascendente, verificando que cada uno apunte a `ASISTENCIA_BI_DEMO`.
4. Ejecutar `sql/09_datos_ficticios.sql` para insertar los datos ficticios.
5. Ejecutar `sql/10_ejecutar_y_validar.sql` para actualizar el modelo y consultar los resultados.

**Precaución:** no ejecutar los scripts de demostración sobre la base original `ASISTENCIA`. Utilizar siempre la base `ASISTENCIA_BI_DEMO`.

### Resultado verificado de la demostración

El 21/10/2026 el equipo ejecutó el procedimiento `dbo.sp_Actualizar_Modelo_BI` en la base de demostración y obtuvo:

| Tabla | Registros |
|---|---:|
| `FactAsistencia_ETL` | 10 |
| `DimPracticante` | 3 |
| `DimTiempo` | 4 |
| `DimEstado` | 7 |

La captura de esta ejecución se conserva como `evidencias/04_etl_demo.png`. Los conteos por categoría de calidad de datos no se consideran verificados hasta contrastarlos con la salida correspondiente de SSMS.

## Modelo y ETL

El modelo está formado por `FactAsistencia_ETL` y las dimensiones `DimPracticante`, `DimTiempo` y `DimEstado`. El procedimiento `dbo.sp_Ejecutar_ETL_Asistencia_BI` carga la tabla de hechos y calcula duración y clasificación de calidad de los registros. `dbo.sp_Actualizar_Modelo_BI` ejecuta primero el ETL y después actualiza las dimensiones. No se ha documentado una ejecución automática programada.

## Power BI y resultados del proyecto original

El archivo `powerbi/APMinversiones.pbix` es el dashboard original, conectado al entorno principal `ASISTENCIA`. Los indicadores documentados son 7,111 asistencias, 128 practicantes, 520 tardanzas y 415 faltas. Incluye visualizaciones de estados, evolución temporal y calidad de datos, así como filtros por practicante, estado y período.

Para intentar utilizarlo con la base ficticia, trabajar sobre **una copia** del archivo, cambiar la conexión SQL Server a `ASISTENCIA_BI_DEMO` y actualizar. Esa adaptación del dashboard no ha sido validada; el experimento reproducido y verificado hasta ahora corresponde al ETL y al modelo dimensional.

## Evidencias

- `01_dashboard_final.png`: dashboard original.
- `02_modelo_powerbi.png`: relaciones del modelo Power BI.
- `03_etl_real.png`: consulta de validación de conteos en la base original.
- `04_etl_demo.png`: ejecución y conteos del ETL de demostración.

Revisar las imágenes antes de publicarlas para evitar divulgar nombres, credenciales u otros datos personales.

## Licencia y trazabilidad

**Licencia:** pendiente de autorización del equipo. Mientras no se incorpore una licencia, no se otorga permiso explícito de reutilización del código.

**URL del repositorio:** pendiente de confirmar tras la publicación final.

**Rama final, etiqueta, hash y fecha del commit:** pendientes de registrar a partir de GitHub después de publicar los archivos. No deben inventarse.

## Alcance

Se documenta la solución BI final y una prueba independiente de reproducibilidad del ETL con datos ficticios. No se publican datos personales reales ni se afirma haber implementado Big Data o automatización programada del ETL.
