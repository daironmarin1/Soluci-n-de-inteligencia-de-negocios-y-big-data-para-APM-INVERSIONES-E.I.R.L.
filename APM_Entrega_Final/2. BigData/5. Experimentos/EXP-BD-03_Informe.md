# EXP-BD-03 — Comparación del procesamiento con 1 y 8 particiones

**Proyecto:** Soluciones BI y Big Data para APM Inversiones E.I.R.L.  
**Entorno:** Databricks, notebook Python con Apache Spark.  
**Fecha de evidencia:** 28/11/2026.  
**Responsable individual:** pendiente de asignar y confirmar. Quien lo presente debe participar en la prueba y conocer sus limitaciones.  
**Estado:** ejecución y resultados demostrados con tres capturas de Databricks; archivo `.py` reconstruido para reproducción, no exportación nativa del notebook ejecutado.

## Objetivo
Evaluar cómo varía el tiempo de una agregación con Spark cuando se utiliza **1 partición** frente a **8 particiones** sobre el mismo conjunto de datos.

## Datos y configuración
- Tabla de origen: `workspace.apm_inversiones.asistencia_silver`.
- Volumen original comprobado: **7,111** filas.
- Volumen de prueba: **497,770** filas, generado al replicar sintéticamente 70 veces las filas originales mediante `crossJoin` con `spark.range(70)`.
- Campos usados: `Estado` y `Horas_Cumplidas`.
- Alternativas: `df_grande.repartition(1)` y `df_grande.repartition(8)`.
- Operación en ambos casos: `groupBy("Estado")`, `COUNT(*)`, `ROUND(AVG(Horas_Cumplidas), 3)` y `collect()`.
- Pruebas: 5 por alternativa (10 en total), con calentamiento previo, alternancia del orden y medición de duración mediante `time.perf_counter()`.
- Comprobación de integridad: el agregado debía sumar **497,770** filas en cada medición (`assert`).
- Ninguna escritura en las tablas Silver/Bronze. Los datos adicionales son réplicas de prueba, no nuevas asistencias reales.
- No se registraron en las capturas versión exacta de runtime ni recursos hardware; por eso los resultados no son extrapolables a otros clústeres.

## Procedimiento
1. Abrir un notebook Python en Databricks, por ejemplo `EXP-BD-03_Optimizacion_Spark`.
2. Leer Silver con `spark.table(...)`, confirmar los 7,111 registros y seleccionar las dos columnas de análisis.
3. Generar 497,770 registros mediante replicación 70× y comprobar el conteo.
4. Crear las dos alternativas `repartition(1)` y `repartition(8)` sin escribir tablas.
5. Ejecutar el mismo agregado en ambas alternativas una vez para calentamiento.
6. Realizar cinco pruebas por alternativa, alternando el orden y forzando la ejecución con `collect()`; verificar que las sumas de conteos coincidan.
7. Comparar los promedios y calcular el incremento relativo del tiempo. Para reproducir, consultar `1. Notebooks/EXP-BD-03_Optimizacion_Spark.py`.

## Mediciones observadas

| Prueba | 1 partición (ms) | 8 particiones (ms) |
|---:|---:|---:|
| 1 | 549.382 | 702.514 |
| 2 | 577.703 | 663.715 |
| 3 | 577.908 | 659.063 |
| 4 | 524.096 | 640.012 |
| 5 | 571.928 | 624.936 |
| **Promedio** | **560.203** | **658.048** |

- Diferencia: **97.845 ms** (promedios mostrados redondeados a tres decimales).
- Incremento relativo del tiempo con 8 particiones: **17.47 %**.
- Fórmula basada en promedios mostrados: `(658.048 − 560.203) / 560.203 × 100 ≈ 17.47 %`.
- En estas condiciones, **1 partición fue la configuración más rápida**.

## Interpretación
Con el volumen experimental y el procesamiento elegido, el mayor número de particiones aumentó el tiempo medio. Una explicación posible es el costo adicional de redistribución y coordinación frente al reducido trabajo útil de una agregación sobre siete grupos. **No se demuestra que una partición siempre sea óptima**, ni que el mero recuento de particiones determine el paralelismo final del plan. Debido a la evaluación diferida de Spark, la medición puede incluir el costo de `repartition()` y la ejecución de la agregación. El resultado depende del entorno, optimizador, caché y otros trabajos concurrentes. Para extraer conclusiones generales habría que repetir en otros volúmenes y condiciones y analizar el plan físico.

## Conclusión
Las cinco pruebas con **1 partición** promediaron **560.203 ms**, frente a **658.048 ms** con **8 particiones**, lo que equivale a un incremento observado de **17.47 %** en tiempo al usar ocho particiones. Para este escenario no resultó ventajoso aumentar las particiones. El experimento sirve para justificar que la configuración de particionado debe validarse con pruebas y no asumirse mejor por tener más particiones.

## Evidencias incluidas
Se conservan sin editar las tres capturas suministradas, en `2. BigData/3. Evidencias/EXP-BD-03/`:

1. `01_Preparacion_497770_Registros.png` — lectura y replicación de Silver.
2. `02_Diez_Mediciones_Particiones.png` — diez tiempos y promedios.
3. `03_Resultado_Final_17_47_Por_Ciento.png` — diferencia y comparación porcentual.

`EXP-BD-03_Mediciones_Observadas.csv` transcribe los diez valores visibles, no es una extracción automática de los resultados desde Databricks.
