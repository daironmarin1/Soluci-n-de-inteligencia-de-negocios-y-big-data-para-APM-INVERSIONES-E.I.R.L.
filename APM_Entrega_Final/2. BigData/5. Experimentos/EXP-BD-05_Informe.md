# EXP-BD-05 — Escalabilidad de Apache Spark ante volúmenes de prueba

**Proyecto:** BI y Big Data — APM Inversiones E.I.R.L.  
**Entorno:** Databricks, Python, Apache Spark; fuente Silver.  
**Fecha de evidencia:** 28/11/2026.  
**Responsable individual:** pendiente de asignación y confirmación; quien lo sustente debe conocer su desarrollo.  
**Estado:** resultados observados en tres capturas de notebook; el archivo `.py` es una reconstrucción reproducible de las celdas, no una exportación nativa del notebook ejecutado.

## Objetivo
Evaluar cuánto cambia el tiempo de una agregación de asistencia por estado al incrementar el volumen de registros procesados con Spark, manteniendo la consulta y el entorno de ejecución.

## Datos y condiciones de prueba
- Origen de solo lectura: `workspace.apm_inversiones.asistencia_silver`.
- Columnas elegidas: `Estado`, `Horas_Cumplidas`.
- Escenario A: 7,111 registros reales de la tabla de trabajo Silver; escenario B: 71,110 filas (10×); escenario C: 711,100 filas (100×).
- B y C se crean mediante `crossJoin(spark.range(N))` y son **réplicas sintéticas**, no nuevos eventos reales de asistencia.
- Se calcula `COUNT(*)` y `ROUND(AVG(Horas_Cumplidas), 3)` por `Estado` y se fuerza la ejecución con `collect()`.
- Cinco mediciones por escenario, con una pasada de calentamiento no cronometrada y con rotación del orden entre escenarios.
- Tiempo medido con `time.perf_counter()` desde Python; se comprueba el número total de registros agregado mediante una aserción.
- No se crean, reemplazan ni borran tablas Delta; las transformaciones son temporales dentro del notebook.
- La versión exacta de Spark, especificación del cómputo y carga concurrente no quedaron documentadas en las capturas.

## Procedimiento de reproducción
1. Abrir Databricks y crear un notebook Python llamado `EXP-BD-05_Escalabilidad_Spark`.
2. Ejecutar el script ubicado en `2. BigData/1. Notebooks/EXP-BD-05_Escalabilidad_Spark.py`.
3. Comprobar que las filas de A, B y C sean 7,111, 71,110 y 711,100.
4. Ejecutar cinco pruebas de la misma agregación por escenario y verificar las 15 mediciones.
5. Calcular promedios y porcentajes en relación con A usando los valores **de la nueva ejecución**. Los tiempos pueden cambiar.

## Mediciones observadas

| Prueba | A: 7,111 (ms) | B: 71,110 (ms) | C: 711,100 (ms) |
|---:|---:|---:|---:|
| 1 | 430.713 | 513.339 | 451.318 |
| 2 | 398.372 | 488.039 | 445.527 |
| 3 | 411.417 | 447.906 | 449.734 |
| 4 | 389.581 | 519.561 | 554.968 |
| 5 | 461.422 | 484.797 | 435.955 |
| **Promedio** | **418.301** | **490.728** | **467.500** |

## Comparación de los resultados
- De A a B: aumento de **72.427 ms** en promedio; **+17.31 %** sobre A.
- De A a C: aumento de **49.199 ms** en promedio; **+11.76 %** sobre A.
- C procesó diez veces más filas que B, pero mostró menor media (467.500 vs 490.728 ms). Las pruebas no prueban que C sea intrínsecamente más rápido: la diferencia puede deberse al plan, el calentamiento, la ejecución diferida, el entorno Serverless y la variabilidad de las mediciones.
- Las cifras son promedios de cinco ejecuciones, no un análisis estadístico concluyente; el volumen representa datos replicados, no mayor diversidad de información.

## Conclusión
Para esta operación y este entorno, al aumentar 10× y 100× las filas, los tiempos medios observados cambiaron de 418.301 a 490.728 y 467.500 ms respectivamente (+17.31 % y +11.76 %). El aumento de filas no produjo un incremento proporcional del tiempo. El ensayo evidencia el comportamiento experimental del procesamiento Spark en estas condiciones; no permite afirmar rendimiento constante ni extrapolar a conjuntos reales más grandes o distintos.

## Evidencias
- `2. BigData/3. Evidencias/EXP-BD-05/01_Escenarios_7111_71110_711100.png`: los tres volúmenes creados.
- `2. BigData/3. Evidencias/EXP-BD-05/02_Quince_Pruebas_Escalabilidad.png`: tabla de 15 tiempos y promedios.
- `2. BigData/3. Evidencias/EXP-BD-05/03_Comparacion_Final_17_31_y_11_76.png`: porcentajes finales.
- `2. BigData/5. Experimentos/EXP-BD-05_Mediciones_Observadas.csv`: transcripción de los tiempos visibles en la evidencia.

**Nota de trazabilidad:** se conservaron los PNG originales sin editar. El CSV es una transcripción manual de los valores presentados en la captura, no una exportación automática desde Databricks.
