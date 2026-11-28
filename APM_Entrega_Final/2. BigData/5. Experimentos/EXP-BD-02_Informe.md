# EXP-BD-02 — Comparación de rendimiento: DataFrames y Spark SQL

**Proyecto:** Soluciones BI y Big Data para APM Inversiones E.I.R.L.  
**Plataforma:** Databricks con Apache Spark.  
**Evidencia:** capturas de ejecución compartidas el 28/11/2026.  
**Responsable individual:** **pendiente de asignar y confirmar**; quien presente este experimento debe haber participado en su ejecución y poder defenderlo. No atribuir automáticamente a un integrante.

## Objetivo
Comparar el tiempo de respuesta de dos expresiones equivalentes de agregación — API de DataFrames y Spark SQL — para obtener la cantidad de asistencias y el promedio de horas cumplidas por estado.

## Configuración y datos
- Tabla de origen: `workspace.apm_inversiones.asistencia_silver`.
- **7,111 registros** y **7 columnas** en el conjunto Silver.
- Columnas usadas en el cálculo: `Estado`, `Horas_Cumplidas`.
- Consulta lógica en ambos métodos: agrupación por Estado, `COUNT(*)` y `ROUND(AVG(Horas_Cumplidas), 3)`, orden por estado.
- **7 filas de salida** en ambos métodos, con resultados iguales según capturas.
- Entorno: notebook Python y Spark en Databricks (la versión exacta de Spark y el hardware no quedaron capturados en las evidencias).
- Una fase previa de calentamiento mediante `collect()` en ambos métodos y **cinco mediciones de cada método**, alternando el orden por número de repetición.
- Tiempo medido con `time.perf_counter()` hasta completar `collect()`, expresado en milisegundos.
- Solo lectura; sin escritura en tablas Bronze/Silver.

## Procedimiento reproducible
1. Crear notebook Python `EXP-BD-02_Comparacion_Procesamiento_Spark` en Databricks.
2. Ejecutar `spark.table("workspace.apm_inversiones.asistencia_silver")` y comprobar 7,111 filas y 7 columnas.
3. Construir la agregación con DataFrames y su equivalente con Spark SQL, mediante una vista temporal de sesión.
4. Visualizar ambas salidas y verificar que los siete estados, cantidades y promedios coinciden.
5. Ejecutar el calentamiento y las cinco mediciones por método con `collect()`; alternar el orden para reducir el sesgo por precedencia.
6. Calcular promedios y reducción porcentual frente a DataFrames.
7. Conservar la evidencia de la ejecución del notebook (código incluido en `1. Notebooks/EXP-BD-02_Comparacion_Procesamiento_Spark.py`).

## Resultados observados (10 mediciones)

| Prueba | DataFrames (ms) | Spark SQL (ms) |
|---:|---:|---:|
| 1 | 573.296 | 468.515 |
| 2 | 583.509 | 412.105 |
| 3 | 559.349 | 487.817 |
| 4 | 636.186 | 429.418 |
| 5 | 547.668 | 424.571 |
| **Promedio** | **580.002** | **444.485** |

- Diferencia de promedios: **135.517 ms**.
- Reducción relativa del tiempo de Spark SQL frente a DataFrames: **23.36 %**.
- Fórmula: `(580.002 - 444.485) / 580.002 × 100`.

## Análisis e interpretación
En estas diez mediciones, Spark SQL tuvo un tiempo promedio menor al de la API DataFrames, aunque los resultados funcionales fueron equivalentes. **No** se concluye que Spark SQL sea intrínsecamente o siempre más rápido: ambas consultas usan el motor Spark y el resultado depende del plan generado, la caché, los recursos compartidos, la variación entre ejecuciones y el tamaño de la muestra. Se midió la ejecución con `collect()` sobre solo siete filas de salida y un único volumen de 7,111 registros, por lo que no representa una prueba de escalabilidad de alto volumen.

## Conclusión
Para la carga de agrupación utilizada en el proyecto, las cinco repeticiones de Spark SQL registraron **444.485 ms** promedio frente a **580.002 ms** con DataFrames, una diferencia observada del **23.36 %** a favor de Spark SQL. Se recomienda repetir el ensayo en otras sesiones y volúmenes antes de elegir una técnica por rendimiento. Ambas opciones generaron los mismos indicadores en la prueba.

## Evidencias
Ubicación: `2. BigData/3. Evidencias/EXP-BD-02/`.

- `01_Carga_Silver_7111_7_Columnas.png`: lectura de Silver y vista de los datos.
- `02_Resultados_Equivalentes_DataFrames_SparkSQL.png`: las dos salidas agrupadas.
- `03_Mediciones_10_Pruebas.png`: 10 tiempos y promedios observados.
- `04_Comparacion_Final_23_36_Por_Ciento.png`: cálculo final de diferencia y porcentaje.

El archivo `EXP-BD-02_Mediciones_Observadas.csv` transcribe únicamente los valores visibles en la captura (no es una exportación automática de la sesión). El notebook Python es una reconstrucción reproducible del código ejecutado, a partir de las celdas compartidas en la conversación, no una exportación nativa del espacio de trabajo.
