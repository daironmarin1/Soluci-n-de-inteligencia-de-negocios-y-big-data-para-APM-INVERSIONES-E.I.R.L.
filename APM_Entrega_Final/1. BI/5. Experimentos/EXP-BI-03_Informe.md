# EXP-BI-03 | Rendimiento de búsqueda con y sin índice

**Proyecto:** Soluciones BI y Big Data para APM Inversiones E.I.R.L.  
**Componente:** Business Intelligence / SQL Server.  
**Fecha de capturas:** 28/11/2026.  
**Integrante responsable:** pendiente de asignar y validar con quien ejecute y sustente la prueba.

## Objetivo

Comparar el tiempo de ejecución de una consulta BI de filtrado por fecha sobre un volumen sintético de **355,550 registros**, primero sin índice y luego con un índice no agrupado sobre `fecha`, manteniendo el mismo predicado y la misma fecha.

## Metodología, datos y configuración

- Motor: Microsoft SQL Server, consultas ejecutadas desde SQL Server Management Studio (SSMS).
- Origen: base `ASISTENCIA`, tabla `dbo.FactAsistencia_ETL` con **7,111 registros**.
- Tabla de prueba **temporal local**: `#EXP_BI03_Prueba`, creada al repetir **50 veces** las columnas `estado` y `fecha` de los 7,111 registros originales. Las 355,550 filas no representan asistencias adicionales reales.
- Escenario 1: tabla temporal sin índice (`Total_Indices = 0`).
- Escenario 2: la misma tabla temporal con `CREATE NONCLUSTERED INDEX IX_EXP_BI03_Fecha ON #EXP_BI03_Prueba(fecha)`.
- Consulta: `SELECT @Total = COUNT_BIG(*) FROM #EXP_BI03_Prueba WHERE fecha >= @Fecha AND fecha < DATEADD(DAY,1,@Fecha)`.
- Fecha seleccionada en la ejecución observada: **31/01/2026**, con **300 filas** encontradas en cada prueba.
- Cada escenario tuvo un calentamiento y **5 repeticiones medidas**. Las duraciones se calcularon en milisegundos mediante `SYSDATETIME()` y `DATEDIFF_BIG(MICROSECOND, ...)`.
- Los escenarios se probaron secuencialmente: primero sin índice y luego con índice, por lo que pueden influir el calentamiento, caché, compilación y las condiciones del servidor.
- El tiempo de **construcción del índice no se contabilizó**. La modificación se hizo solamente en una tabla temporal, no en el modelo BI persistente.

## Procedimiento

1. Contar las asistencias originales y crear la tabla temporal replicada 50 veces.
2. Comprobar 355,550 filas y ausencia de índices en la tabla temporal.
3. Ejecutar la misma consulta de conteo por fecha cinco veces sin índice (después de un calentamiento).
4. Crear un índice no agrupado sobre `fecha` de la tabla temporal.
5. Repetir la misma búsqueda, con idéntica fecha y predicado, cinco veces con índice (después de un calentamiento).
6. Registrar los tiempos promedio, mínimo, máximo, y calcular la reducción porcentual con base en el promedio sin índice.

## Resultados reales observados

| Condición | Filas de prueba | Repeticiones | Promedio | Mínimo | Máximo |
|:--|--:|--:|--:|--:|--:|
| Sin índice | 355,550 | 5 | **24.343 ms** | 23.139 ms | 25.327 ms |
| Con índice | 355,550 | 5 | **0.207 ms** | 0.000 ms | 1.036 ms |

**Cinco tiempos de búsqueda SIN índice (ms):** 25.092, 25.327, 23.139, 24.306 y 23.852.  
**Cinco tiempos CON índice:** la captura confirma un valor máximo de 1.036 ms, mínimo mostrado de 0.000 ms y promedio 0.207 ms; no se transcriben valores individuales que no aparecen completos en la captura.

**Cálculo de la reducción relativa:** `(24.343 − 0.207) / 24.343 × 100 = 99.15 %` (aproximadamente).

## Comparación y análisis

En el entorno de prueba, la búsqueda indexada tuvo una latencia media considerablemente menor. Como la consulta filtra por fecha y el conjunto de prueba tiene muchas filas, un índice sobre esa columna facilita encontrar los registros coincidentes sin recorrer necesariamente toda la tabla. Este resultado motiva evaluar índices adecuados para las consultas BI de uso frecuente.

**Limitaciones:** la medición de tiempos muy pequeños mediante diferencias de reloj muestra **0.000 ms** en algunas pruebas. Esto no significa una ejecución instantánea, sino que se alcanzó el límite de resolución del método. El diseño no incluye el costo de construir ni mantener el índice, no controla exhaustivamente la caché, no alterna aleatoriamente el orden de escenarios y solo prueba un predicado. Por ello, el **99.15 %** es una reducción *observada en esta prueba*, no una ganancia general garantizada.

## Conclusión

La comparación realizada con 355,550 filas sintéticas muestra que la búsqueda por fecha pasó de **24.343 ms** de promedio sin índice a **0.207 ms** con índice, equivalente a una reducción relativa aproximada del **99.15 %** en las condiciones evaluadas. Se recomienda considerar índices para consultas de filtrado frecuentes en el Data Mart, evaluando también sus costos de mantenimiento y validando el rendimiento con conjuntos reales.

## Evidencias

- `01_Datos_Prueba_355550_Sin_Indices.png`: comprobación de la tabla temporal y cero índices.
- `02_Cinco_Pruebas_Sin_Indice.png`: registros, fecha, cinco tiempos y promedio inicial.
- `03_Cinco_Pruebas_Con_Indice.png`: comparación de ambos escenarios y tiempos resumidos.
- `04_Comparacion_Final_99_15_Por_Ciento.png`: cálculo porcentual en SSMS.

**Código SQL reproducible:** `1. BI/1. SQL/18_EXP_BI_03_Indice_Fecha.sql`.

**Notas académicas:** este experimento no debe asignarse a otro estudiante sin verificar su participación real, ni contarse como experimento Big Data. El script de reproducción puede arrojar tiempos diferentes a los de las capturas.
