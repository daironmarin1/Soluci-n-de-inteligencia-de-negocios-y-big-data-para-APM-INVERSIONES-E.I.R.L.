# EXP-BI-02 | Rendimiento según el volumen de datos

**Proyecto:** Soluciones BI y Big Data para APM Inversiones E.I.R.L.  
**Actividad:** experimento BI con SQL Server / SSMS.  
**Fecha de la evidencia:** 28/11/2026 (capturas aportadas).  
**Responsable asignado:** Cholan Ocampo, Alessandra.

## Objetivo

Evaluar cómo aumenta el tiempo requerido para agrupar las asistencias por `estado` cuando se incrementa el volumen de registros procesados por SQL Server, en un ambiente de prueba que no modifique la información operacional del proyecto.

## Datos y configuración

- Base de datos original: `ASISTENCIA`; tabla origen `dbo.FactAsistencia_ETL`.
- Datos iniciales: **7,111** registros, **7** estados, fechas del **27/01/2026 al 03/09/2026**.
- Herramienta: SQL Server Management Studio y motor SQL Server.
- Operación sometida a prueba: `SELECT estado, COUNT_BIG(*) ... GROUP BY estado` (agregación sobre el campo `estado`).
- Escenario A: **7,111** registros; escenario B: **71,110** (10 copias); escenario C: **355,550** (50 copias).
- Las copias están en tablas temporales de la sesión (`#ExpBI_A`, `#ExpBI_B`, `#ExpBI_C`) y conservan la distribución original; **no son asistencias nuevas**.
- Cinco repeticiones por escenario (**15 mediciones**) usando `SYSDATETIME()` y `DATEDIFF_BIG(MICROSECOND, ...)`, con salida convertida a milisegundos.
- Se comprobó el comportamiento en una sola sesión de consulta. Los escenarios se probaron en orden A, B y C; no se controló totalmente la caché del motor, ni se midió la variación entre sesiones o equipos.

## Procedimiento

1. Ejecutar consultas de verificación de la tabla original y de la distribución por estado.
2. Generar tres escenarios de prueba en tablas temporales, multiplicando los registros mediante `CROSS JOIN` con `sys.all_objects`.
3. Confirmar los tamaños A = 7,111; B = 71,110; C = 355,550.
4. Ejecutar la agregación por `estado` cinco veces por escenario, calculando duración en ms.
5. Obtener promedio, mínimo y máximo; calcular el incremento de tiempo de B y C frente a A.
6. Capturar resultados de SSMS y contrastar los escenarios.

## Resultados observados en capturas

| Escenario | Registros de prueba | Repeticiones | Promedio (ms) | Mínimo (ms) | Máximo (ms) | Incremento vs A |
|:--|--:|--:|--:|--:|--:|--:|
| A | 7,111 | 5 | 2.970 | 2.519 | 3.280 | 0.00 % |
| B | 71,110 | 5 | 23.333 | 22.057 | 24.575 | 685.62 % |
| C | 355,550 | 5 | 113.231 | 110.832 | 114.783 | 3712.49 % |

*Los incrementos reflejan el cambio relativo de tiempo respecto al escenario A, y no una disminución ni una mejora de rendimiento.*

## Análisis

Cuando el volumen se multiplicó por 10 (A → B), el tiempo promedio se multiplicó por aproximadamente **7.86**. Al aumentar el volumen 50 veces (A → C), el tiempo se multiplicó por aproximadamente **38.12**. Bajo estas condiciones, el costo de la agregación aumenta notablemente con la cantidad de filas, aunque no proporcionalmente de forma exacta. Los datos replicados, el orden fijo de ejecución, la caché y el costo de medición limitan la extrapolación a entornos reales.

## Conclusión

Los resultados de esta prueba muestran que la consulta de conteo agrupado por estado conserva su funcionalidad con hasta **355,550** filas de prueba, pero presenta mayor tiempo de respuesta a medida que crece el conjunto de datos. En un entorno productivo convendría evaluar índices, resúmenes precalculados y nuevas mediciones controladas, sin afirmar que estas técnicas ya han sido implementadas o comparadas en este experimento.

## Evidencias originales (sin editar)

Ubicación: `../3. Evidencias BI/13. Experimento BI 02/` desde la carpeta `1. BI/`.

- `01_Verificacion_Datos_7111.png`: tabla original y distribución de estados.
- `02_Escenarios_7111_71110_355550.png`: volúmenes confirmados.
- `03_Mediciones_15_Pruebas.png`: resultados de cinco pruebas por escenario y promedios (en la captura solo se visualizan algunas de las filas individuales, pero el cuadro resumen incluye los tres escenarios).
- `04_Comparacion_Porcentual.png`: incrementos porcentuales calculados en SSMS.

## Reproducción

Ejecutar `1. BI/1. SQL/17_EXP_BI_02_Volumen_Rendimiento.sql` completo **en una sola ventana de SSMS**. Se debe tener acceso de lectura a `ASISTENCIA.dbo.FactAsistencia_ETL`. Las tablas `#` existen solo durante la sesión. Los tiempos variarán según la carga del equipo y el motor; los valores de la tabla son las mediciones originales registradas en las imágenes.
