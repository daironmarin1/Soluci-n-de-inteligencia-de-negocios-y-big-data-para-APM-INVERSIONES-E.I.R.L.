# EXP-BD-01 — Evaluación de calidad y limpieza de registros experimentales

**Proyecto:** Soluciones BI y Big Data — APM Inversiones E.I.R.L.  
**Plataforma:** Databricks con Apache Spark (Python); lectura de tablas Bronze y Silver.  
**Evidencia:** capturas de ejecuciones del 28/11/2026.  
**Responsable individual:** pendiente de asignación y de validación de participación.  
**Estado:** experimento ejecutado en Databricks según capturas. El archivo Python es una **reconstrucción reproducible** de las celdas, no una exportación nativa del notebook.

## Objetivo
Comprobar las reglas básicas de calidad (valores nulos en Estado, Fecha y Horas_Cumplidas, y valores negativos en Horas_Cumplidas) y probar la capacidad de un proceso de filtrado para detectar y excluir registros incorrectos **introducidos artificialmente**.

## Hipótesis y condiciones
- Si se agregan tres registros artificiales inválidos a una copia de Bronze, un filtro basado en reglas podrá excluir esos tres registros sin alterar el origen.
- Fuente: `workspace.apm_inversiones.asistencia_bronze` (6 columnas) y `workspace.apm_inversiones.asistencia_silver` (7 columnas, incluida `Calidad_Registro`).
- Las dos fuentes contienen 7,111 registros. En la verificación inicial **ambas tenían cero registros incompletos y cero horas negativas**. En Silver, los 7,111 tenían `Calidad_Registro = Correcto` bajo el procedimiento previo.
- Se añade **un registro sin Estado**, **uno con Horas_Cumplidas = −2** y **uno sin Fecha** a un DataFrame temporal. El volumen experimental queda en 7,114 filas.
- No se hicieron modificaciones ni escrituras en Bronze, Silver u otras tablas Delta; no se interpreta que estos errores existieran originalmente en el negocio.

## Procedimiento
1. Leer Bronze y Silver con `spark.table()` y consultar cantidades y nombres de columnas.
2. Calcular nulos y horas negativas de ambas capas; revisar la columna `Calidad_Registro` de Silver.
3. Construir con `withColumn`, `lit` y `unionByName` una copia experimental que contiene tres registros inválidos introducidos intencionalmente.
4. Aplicar `filter` para excluir registros con Estado o Fecha nulos, Horas_Cumplidas nulas, no convertibles a número o negativas.
5. Comprobar cantidades antes y después y contrastar registros con error mediante una agregación.
6. Conservar capturas de la ejecución y el notebook para reproducción.

## Resultados observados

| Indicador | Bronze inicial | Silver inicial |
|---|---:|---:|
| Registros | 7,111 | 7,111 |
| Registros incompletos (tres campos revisados) | 0 | 0 |
| Horas negativas | 0 | 0 |
| Registros clasificados como `Correcto` | No aplica | 7,111 |

| Indicador | Datos de prueba antes | Datos de prueba después |
|---|---:|---:|
| Filas | 7,114 | 7,111 |
| Filas con error según las reglas | 3 | 0 |
| Filas incompletas | 2 | 0 |
| Filas con horas negativas | 1 | 0 |
| Filas sintéticas rechazadas | — | 3 |

**Tasa de detección y exclusión sobre los tres errores introducidos:** 3/3 = **100 % en esta prueba controlada**. La tasa de registros experimentales excluidos fue 3/7,114 ≈ **0.0422 %**.

## Análisis
El conjunto de datos original no mostraba fallas en los tres campos y reglas evaluados; por lo tanto, **no hubo una mejora medible en la tasa de errores al pasar de Bronze a Silver en esas verificaciones**. La prueba adicional fue necesaria para validar el comportamiento de un filtro de limpieza ante datos incorrectos introducidos artificialmente. Tras aplicar la limpieza quedaron 7,111 filas y cero errores de esos tipos.

La clasificación `Correcto` en Silver es propia de las reglas implementadas y **no certifica que no existan otros problemas** (por ejemplo, duplicados reales, inconsistencias de negocio o identidades ausentes). La experiencia no mide tiempo de ejecución ni demuestra superioridad universal de una estrategia. El ensayo mide la efectividad funcional de las reglas frente a tres tipos de anomalías.

## Conclusión
El proceso experimental detectó y excluyó los tres errores sintéticos introducidos (100 % de los casos de prueba), sin alterar las 7,111 filas originales. Esto valida las reglas de filtrado **para los casos estudiados** y proporciona evidencia de transformación de datos mediante PySpark; no implica que la capa Silver hubiera corregido defectos existentes ni prueba calidad completa de los datos.

## Reproducción y evidencias
- Código: `2. BigData/1. Notebooks/EXP-BD-01_Limpieza_y_Calidad_Datos.py`.
- Captura 01: verificación inicial, 7,111 registros por capa, columnas.
- Captura 02: calidad inicial, 0 incompletos/negativos y 7,111 clasificados `Correcto` en Silver.
- Captura 03: introducción sintética de tres errores, 7,114 filas.
- Captura 04: limpieza temporal, 7,111 filas y 3 rechazadas.
- Captura 05: comparación final, 3 casos con error antes y 0 después.

**Trazabilidad:** las capturas son las aportadas de Databricks; los valores del CSV de resultados son una transcripción de dichas capturas. No se atribuye el experimento a una persona hasta validar su participación y responsabilidad.
