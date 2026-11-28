# Proyecto Big Data - APM Inversiones

Responsable: Alessandra Cholan Ocampo
Plataforma: Databricks Free Edition
Procesamiento: Apache Spark - Serverless CPU
Entorno: Environment version 6

## Datos
Dataset ficticio de 7111 registros de asistencia.
Formato de entrada: CSV separado por punto y coma.

## Notebooks
01_ingesta_bronze
02_limpieza_silver

## Tablas Delta
workspace.apm_inversiones.asistencia_bronze
workspace.apm_inversiones.asistencia_silver


## Procedimiento de ejecución

### 1. Preparación del entorno
- Ingresar a Databricks Free Edition.
- Utilizar Serverless CPU.
- Seleccionar el catálogo workspace.
- Utilizar el esquema apm_inversiones.

### 2. Carga de datos
- Subir el archivo APM_Asistencia_exportacion_revision.csv.
- Utilizar el volumen apm_inversiones_bronze.
- El archivo contiene datos ficticios.
- Separador CSV: punto y coma (;).
- Total esperado: 7111 registros.

### 3. Notebook 01_ingesta_bronze
- Leer el archivo CSV mediante spark.read.csv().
- Utilizar header=True, inferSchema=True y sep=";".
- Visualizar los datos con display().
- Guardar la tabla Delta asistencia_bronze.
- Validar los 7111 registros con SQL.

### 4. Notebook 02_limpieza_silver
- Leer la tabla Bronze utilizando spark.table().
- Verificar valores nulos y duplicados.
- Revisar estados vacíos y horas negativas.
- Estandarizar la columna Estado con trim().
- Crear la columna Calidad_Registro.
- Guardar la tabla Delta asistencia_silver.
- Comprobar que se conservan los 7111 registros.

## Resultados de validación
- Valores nulos: 0.
- Estados vacíos: 0.
- Horas negativas: 0.
- Posibles duplicados por coincidencia de columnas: 2514.
- Registros que cumplen las reglas de calidad: 7111.
- No se eliminaron registros duplicados.

## Consideraciones
- Los datos utilizados son ficticios.
- Las tablas existentes no deben sobrescribirse sin revisión.
- Los posibles duplicados requieren evaluación adicional.
- Las pruebas experimentales de rendimiento se documentarán por separado.


## Experimento EXP-BD-04: Rendimiento con y sin caché

### Objetivo
Comparar el rendimiento de Apache Spark al ejecutar consultas
repetidas con y sin caché explícita.

### Datos utilizados
Se utilizaron 7111 registros ficticios de asistencia.
Para las pruebas se ampliaron mediante replicación a:
- 100000 registros
- 500000 registros
- 1000000 de registros

### Metodología
Se realizaron cinco mediciones por condición y tamaño.
Se aplicaron operaciones de agrupación, conteo y suma.
Se registró por separado el costo de preparar la caché.

### Resultados
| Registros | Sin caché | Con caché | Mejora |
|---|---|---|---|
| 100000 | 0.7298 s | 0.5970 s | 18.20% |
| 500000 | 0.7557 s | 0.6344 s | 16.06% |
| 1000000 | 0.7854 s | 0.6305 s | 19.73% |

### Preparación de caché
- 100000 registros: 3.0415 segundos.
- 500000 registros: 2.5032 segundos.
- 1000000 de registros: 2.6793 segundos.

### Conclusión
La caché redujo los tiempos promedio de las consultas
repetidas en los tres tamaños evaluados.

Sin embargo, el ahorro de las cinco consultas no compensó
el costo inicial de preparación de la caché.

Los resultados corresponden a datos sintéticos replicados,
consultas con siete grupos de salida y un entorno Serverless.
No deben generalizarse a todas las cargas de trabajo.

### Evidencias
Notebook: EXP-BD-04_Cache_Spark.py
Capturas de pantalla de las mediciones.
Tabla comparativa y gráfico de rendimiento.



## Experimento EXP-BD-02: DataFrames frente a Spark SQL (28/11/2026)

- Notebook reproducible: `1. Notebooks/EXP-BD-02_Comparacion_Procesamiento_Spark.py`.
- Tabla: `workspace.apm_inversiones.asistencia_silver`; 7111 registros, 7 columnas.
- 5 repeticiones por método; resultados funcionales idénticos en 7 estados.
- Promedio DataFrames: **580.002 ms**; Spark SQL: **444.485 ms**.
- Reducción relativa observada del tiempo con Spark SQL: **23.36 %**.
- Informe: `5. Experimentos/EXP-BD-02_Informe.md`.
- Evidencias: `3. Evidencias/EXP-BD-02/`.
- Las mediciones describen solo esta carga y sesión. Responsable individual por confirmar.


## Experimento EXP-BD-05 — escalabilidad Spark (28/11/2026)

Se agregó `1. Notebooks/EXP-BD-05_Escalabilidad_Spark.py`, la documentación y las mediciones bajo `5. Experimentos/` y tres capturas en `3. Evidencias/EXP-BD-05/`. Se usa Silver en modo de solo lectura para comparar A=7,111, B=71,110 y C=711,100 registros; resultados observados: 418.301, 490.728 y 467.500 ms promedio, respectivamente. El notebook `.py` está reconstruido a partir de los pasos verificados y las capturas; quien lo exponga debe ejecutar y comprender sus resultados.


## Experimento EXP-BD-01 — calidad y limpieza controlada (28/11/2026)

Se añadió `1. Notebooks/EXP-BD-01_Limpieza_y_Calidad_Datos.py`, el informe y resumen de resultados en `5. Experimentos/`, y cinco capturas en `3. Evidencias/EXP-BD-01/`. Las capas Bronze y Silver tienen 7,111 filas y cero errores en las reglas revisadas. Para comprobar el filtro se introdujeron temporalmente tres anomalías sintéticas en 7,114 filas y se excluyeron las tres, conservando 7,111. No se alteraron tablas Delta. Participación individual pendiente de documentar.
