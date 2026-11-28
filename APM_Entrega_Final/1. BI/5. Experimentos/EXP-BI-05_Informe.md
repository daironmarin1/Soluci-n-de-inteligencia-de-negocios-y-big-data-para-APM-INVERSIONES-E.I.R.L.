# EXP-BI-05 — Optimización de consultas mediante preagregación

**Proyecto:** Soluciones BI y Big Data para APM Inversiones E.I.R.L.  
**Componente:** Business Intelligence, SQL Server / SSMS.  
**Evidencias:** capturas proporcionadas el 28/11/2026.  
**Responsable:** por asignar y verificar con el integrante que ejecutará/sustentará el experimento.

## Objetivo e hipótesis

Comparar los tiempos de una misma agrupación por `estado` de las asistencias usando (a) datos detallados y (b) una tabla de asistencia previamente agregada por fecha y estado. Se espera que reutilizar el resumen ya generado reduzca el tiempo de respuesta de la consulta para un dashboard.

## Datos y configuración

- Base: `ASISTENCIA`, tabla `dbo.FactAsistencia_ETL` (7,111 registros originales).
- **Escenario de prueba sintético:** 50 réplicas de los registros originales, solo con `fecha` y `estado`, en `#EXP_BI05_Detalle`: **355,550 filas**. No representan 355,550 asistencias reales.
- **Resumen:** `#EXP_BI05_Resumen`, agrupado por `fecha` y `estado`: **828 filas** en la ejecución observada.
- Consultas equivalentes: agrupar por `estado` y contar desde el detalle, frente a sumar `Total_Asistencias` desde el resumen.
- Se hizo un calentamiento por método y **cinco ejecuciones medidas por método**. Se calculó la duración en milisegundos mediante `SYSDATETIME()` y `DATEDIFF_BIG(MICROSECOND,...)`.
- El orden de los métodos fue secuencial en cada prueba; tanto el calentamiento, la caché y el optimizador como otras cargas del servidor pueden influir.
- **No se contabilizó el tiempo de construir ni mantener la tabla resumida**, por lo que el resultado compara el tiempo de *consulta*, no el coste total de un ETL completo.
- No se modificó ningún objeto permanente de la base; las tablas con prefijo `#` son temporales en la sesión de SSMS.

## Procedimiento reproducible

1. Ejecutar `1. BI/1. SQL/19_EXP_BI_05_Preagregacion.sql` en una sesión de SSMS conectada a `ASISTENCIA`.
2. Generar 355,550 filas de prueba en `#EXP_BI05_Detalle` y el resumen de 828 filas.
3. Verificar que ambas estrategias producen los mismos conteos por estado.
4. Ejecutar un calentamiento y cinco consultas medidas de cada método.
5. Revisar las diez mediciones, sus promedios y la diferencia porcentual.
6. Guardar las capturas de la verificación, medición y comparación final como evidencias.

## Resultados medidos

| Método | Filas de entrada | Mediciones | Promedio | Mínimo | Máximo |
|---|---:|---:|---:|---:|---:|
| Sin preagregación | 355,550 | 5 | **114.380 ms** | 111.483 ms | 117.508 ms |
| Con preagregación | 828 | 5 | **0.812 ms** | 0.000 ms | 1.036 ms |

**Reducción del tiempo promedio de consulta:** `(114.380 - 0.812) / 114.380 × 100 = 99.29 %` (aprox.).

La captura de las mediciones solo muestra ocho de las diez duraciones individuales; las estadísticas de las cinco ejecuciones de cada método sí se observan en su tabla resumen. Por eso se preservan los **promedios y extremos verificados** sin inventar los valores que no se ven.

### Interpretación

En el escenario ensayado, consultar el resumen ya materializado fue significativamente más rápido que agrupar todo el detalle. Esta estrategia puede resultar beneficiosa para dashboards con indicadores frecuentes y agrupaciones estables. Sin embargo, mantener el resumen implica costes de almacenamiento y actualización, no incluidos en la medición.

**Limitaciones:** el mínimo `0.000 ms` es un valor redondeado a la resolución de la medición, no prueba una ejecución instantánea. No generalizar el porcentaje a todas las consultas ni a conjuntos de datos reales más grandes. El resultado se obtuvo con datos replicados, una carga y condiciones concretas de SQL Server.

## Evidencias

- `1. BI/3. Evidencias BI/15. Experimento BI 05/01_Detalle_355550_Resumen_828.png`
- `1. BI/3. Evidencias BI/15. Experimento BI 05/02_Diez_Mediciones_y_Promedios.png`
- `1. BI/3. Evidencias BI/15. Experimento BI 05/03_Comparacion_Final_99_29_Por_Ciento.png`

## Conclusión

En las diez mediciones de consulta, la preagregación redujo el promedio observado de **114.380 ms** a **0.812 ms** (aprox. **99.29 %**) sin cambiar los resultados de la agregación por estado. Se recomienda analizar el uso de resúmenes para indicadores repetitivos de BI, midiendo también el coste de generación y mantenimiento antes de adoptarlos en producción.
