# Guía de replicación técnica — APM Inversiones E.I.R.L.

**Versión documental:** 28 de noviembre de 2026  
**Alcance:** solución BI (SQL Server + Power BI), solución Big Data (Databricks + Spark), automatización ETL y diez experimentos.  
**Fuente de verificación:** scripts, notebooks, capturas y resultados incluidos en `APM FINAL/`, junto con el apartado 4.6 y el capítulo VI del informe final.  
**Objeto:** describir cómo repetir las operaciones en un entorno autorizado. **No certifica que se haya ejecutado de nuevo cada paso** con este manual ni garantiza los mismos tiempos.

## 1. Antes de empezar

- Descargar el ZIP final y extraerlo, conservando la carpeta raíz `APM FINAL/` y sus subcarpetas. Abrir el informe Word y el diagrama en `4. Documentación/`.
- Usar SQL Server + SQL Server Management Studio (SSMS), Power BI Desktop y Databricks con Apache Spark; el equipo documentó pruebas en Windows y Databricks Serverless. Las versiones exactas instaladas en otro equipo pueden diferir.
- **No ejecutar scripts de creación y recarga sobre una base operativa**. Los procedimientos BI borran y reconstruyen `FactAsistencia_ETL`; primero identificar instancia y base, y comprobar que existe respaldo de la base *de prueba* con permisos de uso.
- **No publicar información personal.** La exportación CSV incluida en `2. BigData/2. Datos/` es ficticia. El ZIP no incluye el contenido completo original de `dbo.practicante` y `dbo.asistencia` de la base ASISTENCIA; por tanto, **no es posible reconstruir exactamente los 7,111 hechos originales desde cero utilizando únicamente este ZIP**.
- Los scripts originales de tablas del modelo son archivos de definición (`CREATE TABLE`), algunos fijan `USE [ASISTENCIA]`, y `10_sp_actualizar_modelo_bi.sql` usa `ALTER PROCEDURE`. Están destinados a su entorno existente o a una copia previamente preparada, no a una instalación nueva con un solo clic.
- `01_creacion_base_datos.sql` es un script generado del servidor con rutas `.mdf`/`.ldf` y configuración local. **No ejecutarlo directamente en otro equipo**: revisar compatibilidad de SQL Server, rutas y permisos. No sustituye a un respaldo con datos.

## 2. Mapa de carpetas relevante

| Componente | Ruta dentro de `APM FINAL/` |
|---|---|
| SQL y validaciones del modelo BI | `1. BI/1. SQL/` |
| Modelo/dashboards Power BI | `1. BI/2. Power BI/APMinversiones.pbix` |
| Evidencias BI | `1. BI/3. Evidencias BI/` |
| Automatización | `1. BI/4. Automatizacion ETL/` |
| Informes de experimentos BI | `1. BI/5. Experimentos/` |
| CSV ficticio | `2. BigData/2. Datos/APM_Asistencia_exportacion_revision.csv` |
| Ingesta, limpieza y notebooks experimentales | `2. BigData/1. Notebooks/` |
| Evidencias de Big Data | `2. BigData/3. Evidencias/` |
| Scripts aislados EXP-BI-04 | `2. BigData/4. SQL/` (ubicación histórica conservada) |
| Informes de experimentos Big Data | `2. BigData/5. Experimentos/` |
| Experimento de caché | `3. Exp/EXP-BD-04_Cache_Spark.py` |
| Diagrama general e informe | `4. Documentación/Diagramas/` y `4. Documentación/Informe Final/` |

## 3. Replicación BI sobre una copia autorizada de ASISTENCIA

### 3.1. Comprobación previa: solo lectura

Conectar SSMS a una **copia autorizada** de la instancia que contenga `ASISTENCIA`. Revisar el contexto y ejecutar:

```sql
USE ASISTENCIA;
GO
SELECT DB_NAME() AS Base_Actual,
       (SELECT COUNT_BIG(*) FROM dbo.asistencia) AS Filas_Origen,
       (SELECT COUNT_BIG(*) FROM dbo.FactAsistencia_ETL) AS Filas_Hechos;
SELECT COUNT_BIG(*) AS Total_Hechos,
       SUM(CASE WHEN f.id_modalidad IS NULL THEN 1 ELSE 0 END) AS Sin_Modalidad,
       SUM(CASE WHEN f.id_modalidad IS NOT NULL AND m.id_modalidad IS NOT NULL THEN 1 ELSE 0 END) AS Modalidad_Valida,
       SUM(CASE WHEN f.id_modalidad IS NOT NULL AND m.id_modalidad IS NULL THEN 1 ELSE 0 END) AS Modalidad_Inexistente
FROM dbo.FactAsistencia_ETL AS f
LEFT JOIN dbo.DimModalidadRegistro AS m ON f.id_modalidad = m.id_modalidad;
```

La evidencia del equipo mostró 7,111 hechos, 0 sin modalidad, 7,111 modalidades válidas y 0 inexistentes. Es un **valor de referencia de la sesión documentada**, no un resultado garantizado al repetir las pruebas con otra base.

### 3.2. Modelo dimensional, ETL y dashboard

1. Comprobar la existencia de `dbo.practicante`, `dbo.asistencia`, `dbo.FactAsistencia_ETL` y las cinco dimensiones `DimPracticante`, `DimTiempo`, `DimEstado`, `DimCalidadRegistro` y `DimModalidadRegistro`.
2. Revisar `1. BI/1. SQL/04_...` a `09_...` para ver las definiciones. **No ejecutarlas sobre tablas existentes**, pues son scripts de creación.
3. En el sistema existente, el código actual de `dbo.sp_Ejecutar_ETL_Asistencia_BI` está documentado en `11_sp_etl_asistencia.sql`; este procedimiento usa la relación `salida_auto` de `DimModalidadRegistro`. La dimensión debe contener los códigos correspondientes a `0`, `1` y `NULL` antes de una recarga; su script `08_...` define la tabla pero no incluye la carga de las categorías. Verificarla antes de ejecutar.
4. Si se necesita **replicar la recarga**, hacerlo únicamente sobre una **copia respaldada y autorizada**, con tablas existentes y dimensiones correctamente preparadas. El archivo `10_sp_actualizar_modelo_bi.sql` documenta el procedimiento principal y `11_sp_etl_asistencia.sql` el proceso que reconstruye la tabla de hechos. Ejecutar `EXEC dbo.sp_Actualizar_Modelo_BI;` o `EXEC dbo.sp_Ejecutar_ETL_Asistencia_BI;` según el alcance previsto y revisar los mensajes. **No ejecutar ambos innecesariamente**, ya que el primero invoca el segundo.
5. Ejecutar **sin modificar datos** los scripts `12_validaciones_fact_asistencia.sql`, `13_validar_cinco_dimensiones.sql`, `14_validar_tabla_hechos.sql` y `16_validar_modalidad_registro.sql`. Guardar los resultados.
6. Abrir `1. BI/2. Power BI/APMinversiones.pbix`. Si Power BI pide origen o credenciales, usar una conexión **autorizada**; si no está disponible, consultar `01_modelo_power_bi.png` y `02_dashboard_principal.png`. La reconexión de este PBIX a una base nueva no fue demostrada en las evidencias, por lo que requiere prueba aparte.

### 3.3. Automatización ETL (Windows)

- Guía específica: `1. BI/4. Automatizacion ETL/README_automatizacion_ETL.md`.
- Archivo: `ejecutar_etl.bat`; incluye llamada a `sqlcmd` sobre `localhost`, autenticación de Windows, base `ASISTENCIA` y `EXEC dbo.sp_Ejecutar_ETL_Asistencia_BI;`.
- En el equipo de prueba se creó la tarea `APM_ETL_Diario` para las **17:00** y el log `APM_ETL/logs/ejecuciones.log`. Para repetirla en otro equipo es necesario **ajustar servidor, ruta, usuario y permisos**; no copiar el BAT a ciegas.
- Evidencias de **tres ejecuciones satisfactorias a petición**, de 7,111 filas, y evento 102 del Programador de tareas. No hay evidencia en este paquete de la primera ejecución activada únicamente por el horario diario.
- No duplicar tareas sobre una misma base ni ejecutarlas en paralelo con recargas manuales.

## 4. Replicación Big Data en Databricks

### 4.1. Datos, ingesta y persistencia

1. Abrir Databricks con Apache Spark (entorno de referencia: Serverless), seleccionar o preparar catálogo `workspace` y esquema `apm_inversiones`. Crear/usar un **esquema de pruebas distinto** si en el workspace ya hay tablas de otro integrante. El script original contiene nombres de tablas fijos; deben sustituirse si se usa un esquema nuevo.
2. Crear un volumen o tener un volumen accesible y cargar allí `2. BigData/2. Datos/APM_Asistencia_exportacion_revision.csv`. Ruta utilizada en la prueba original: `/Volumes/workspace/apm_inversiones/apm_inversiones_bronze/APM_Asistencia_exportacion_revision.csv`.
3. Abrir/importar `01_ingesta_bronze.py` como notebook de Databricks y ejecutar por celdas. La lectura usa `header=True`, `inferSchema=True`, `sep=";"`; verifica el conteo, guarda tabla Delta `workspace.apm_inversiones.asistencia_bronze` y efectúa consultas de agrupación. **No sobrescribir una tabla Bronze existente** sin autorización.
4. Abrir `02_limpieza_silver.py` y ejecutar por celdas: esquema, nulos, coincidencias de filas, espacios en `Estado`, horas negativas, `Calidad_Registro`, persistencia en `workspace.apm_inversiones.asistencia_silver` y consultas de validación. **No eliminar automáticamente** las 2,514 coincidencias observadas sin una clave única de evento.
5. En la ejecución documentada, Bronze y Silver conservaron **7,111 filas**, Silver añadió `Calidad_Registro`, y los chequeos descritos no detectaron nulos ni horas negativas. Son referencias, no una garantía para nuevos archivos.

### 4.2. EDA y dashboard

Ejecutar en una celda SQL de Databricks, una vez que exista Silver:

```sql
SELECT Estado, COUNT(*) AS Total
FROM workspace.apm_inversiones.asistencia_silver
GROUP BY Estado ORDER BY Total DESC;

SELECT Fecha, COUNT(*) AS Total
FROM workspace.apm_inversiones.asistencia_silver
GROUP BY Fecha ORDER BY Fecha;

SELECT Falta_Injustificada, COUNT(*) AS Total
FROM workspace.apm_inversiones.asistencia_silver
GROUP BY Falta_Injustificada ORDER BY Falta_Injustificada;

SELECT Estado, AVG(Horas_Cumplidas) AS Promedio_Horas
FROM workspace.apm_inversiones.asistencia_silver
GROUP BY Estado ORDER BY Estado;
```

En la demostración se construyeron cuatro visualizaciones (barras por estado, línea temporal, dona por falta injustificada y promedio de horas por estado). **El paquete no incluye una exportación instalable completa del dashboard de Databricks**; para reproducirlo es necesario recrear visualizaciones desde los resultados anteriores. Capturas del dashboard están incorporadas en el informe.

## 5. Replicación de los diez experimentos

### 5.1. BI (SQL Server)

| Código | Archivo y orden | Datos / comprobación | Límite de interpretación |
|---|---|---|---|
| **EXP-BI-01** | `1. BI/1. SQL/15_experimento_bi_01.sql`; en **copia respaldada**, pues ejecuta `sp_Actualizar_Modelo_BI` | Conteos antes/después; referencia de **una ejecución** de 205 ms | No es una comparación de varios ensayos |
| **EXP-BI-02** | `1. BI/1. SQL/17_EXP_BI_02_Volumen_Rendimiento.sql`; ejecutar completo en **una ventana de SSMS** | Escenarios de 7,111 / 71,110 / 355,550 filas sintéticas; 5 mediciones cada uno | Datos replicados, no nuevos registros |
| **EXP-BI-03** | `1. BI/1. SQL/18_EXP_BI_03_Indice_Fecha.sql`; ejecutar completo en una ventana | Búsqueda por fecha con y sin índice temporal; 5 mediciones por condición | Mediciones de 0.000 ms tienen resolución limitada |
| **EXP-BI-04** | Abrir **base de prueba** `BI_APM_Inversiones`; usar los cinco scripts `EXP-BI-04_...` de `2. BigData/4. SQL/`. Ejecutar en orden: `Crear_Tablas`, `Insertar_Datos`, `3_Dimensiones`, **`5_Dimensiones_Medicion_Reproducible`**, `Comparacion_Final` | 20,000 identificadores por tabla; 60,000 vs 100,000 filas actualizadas por ensayo, 5 ensayos por condición | Cambian simultáneamente cantidad de tablas y filas. `Comparacion_Final` muestra mediciones históricas **fijas**: reemplazar por resultados nuevos para analizar una nueva ejecución. El archivo histórico `5_Dimensiones.sql` **inserta filas**, no mide tiempo. |
| **EXP-BI-05** | `1. BI/1. SQL/19_EXP_BI_05_Preagregacion.sql`; ejecutar completo en una ventana | 355,550 filas temporales y resumen de 828; 5 ensayos por método | No mide costo de crear/actualizar el resumen; valores casi cero con precisión limitada |

**Ubicación del nuevo script auxiliar no ejecutado por el equipo:** `2. BigData/4. SQL/EXP-BI-04_5_Dimensiones_Medicion_Reproducible.sql`. Está preparado para permitir una repetición completa del método; no se presentan nuevas métricas inventadas.

Para el caso EXP-BI-04, si la base experimental no existe, crear **una base vacía para pruebas** desde `master` antes de ejecutar los scripts (p. ej., `CREATE DATABASE BI_APM_Inversiones;`) y verificar que no tiene datos relevantes. Los cinco archivos de prueba trabajan bajo `USE BI_APM_Inversiones;`; no confundir esta base con `ASISTENCIA`.

### 5.2. Big Data (Databricks, Spark)

Primero verificar Bronze y Silver; ejecutar las celdas de cada notebook en su orden. Los resultados de tiempo pueden cambiar por caché, concurrencia y recursos Serverless.

| Código | Archivo | Comparación / validación |
|---|---|---|
| **EXP-BD-01** | `2. BigData/1. Notebooks/EXP-BD-01_Limpieza_y_Calidad_Datos.py` | Bronze/Silver (7,111 filas); introducir **3 errores solo en DataFrames temporales** y limpiar; comprobar 7,114 antes y 7,111 después, sin escritura en las tablas persistidas. |
| **EXP-BD-02** | `2. BigData/1. Notebooks/EXP-BD-02_Comparacion_Procesamiento_Spark.py` | Agregación por `Estado` mediante DataFrames vs Spark SQL, cinco pruebas cada una, igualdad de resultados. |
| **EXP-BD-03** | `2. BigData/1. Notebooks/EXP-BD-03_Optimizacion_Spark.py` | 497,770 registros sintéticos; una partición vs ocho particiones, cinco pruebas cada una. |
| **EXP-BD-04** | `3. Exp/EXP-BD-04_Cache_Spark.py` | Escenarios de 100,000 / 500,000 / 1,000,000 filas sintéticas; cinco ensayos sin caché y con caché; **registrar por separado el costo de materializarla y liberar al final**. |
| **EXP-BD-05** | `2. BigData/1. Notebooks/EXP-BD-05_Escalabilidad_Spark.py` | 7,111 / 71,110 / 711,100 filas; cinco pruebas por tamaño; comparar promedios y evitar inferir escalabilidad de producción. |

**Nota sobre los archivos:** los `.py` de BD-01, BD-02, BD-03 y BD-05 se reconstruyeron a partir de celdas y capturas de las pruebas; no son exportaciones nativas de notebooks de Databricks. Revisar sus celdas antes de ejecutarlos y no presentar una ejecución nueva sin registros propios.

## 6. Evidencias y criterio de reproducción

1. Registrar fecha, persona que realiza la prueba, herramienta, nombre de base o tabla, tamaño del dataset, número de ensayos y tiempos de cada ejecución (no solo el promedio).
2. Capturar la consola de SQL Server o el resultado de Databricks con la consulta/celda y los datos, preferiblemente sin información identificable.
3. Conservar los archivos de resultados observados (`.csv`, `.md`, `.png`) junto al código. **Los promedios del informe son los de la ejecución documentada**, no umbrales para aprobar un nuevo entorno.
4. Verificar que ambos métodos comparados calculen el mismo resultado lógico; reportar las diferencias de configuración y límites de precisión.
5. Verificar que se pueda abrir `APMinversiones.pbix` (o exhibir las capturas si no hay conexión autorizada) y que las tablas Delta Bronze/Silver existan y puedan consultarse.
6. En el caso de repositorio GitHub, incorporar esta guía y enlazarla en el `README.md` de la raíz. **La presencia local en el ZIP no demuestra que haya sido publicada en GitHub**.

## 7. Limitaciones de reconstrucción completa

- **BI original:** faltan las filas originales de `dbo.asistencia` y `dbo.practicante` y el respaldo `.bak`; el modelo original no se reconstruye desde cero con el ZIP sin una copia autorizada. La tabla `DimModalidadRegistro` se define en el script 08, pero sus filas de catálogo no se incluyen como `INSERT` autónomo.
- **Power BI:** hay `.pbix` y capturas, pero la reconexión y actualización desde una copia nueva no ha sido probada en el material recibido.
- **Databricks:** Bronze/Silver son reproducibles con el CSV ficticio, si existe un workspace autorizado y se ajustan las rutas de volumen y tabla. El dashboard debe recrearse con las consultas.
- **ETL automático:** las pruebas manuales y el evento 102 están documentados, no la primera activación diaria por el horario.
- **Experimentos:** los scripts reconstruidos y el nuevo auxiliar de BI-04 permiten repetir los pasos, pero no se ha efectuado desde este paquete una ejecución de validación de extremo a extremo en un segundo entorno.
