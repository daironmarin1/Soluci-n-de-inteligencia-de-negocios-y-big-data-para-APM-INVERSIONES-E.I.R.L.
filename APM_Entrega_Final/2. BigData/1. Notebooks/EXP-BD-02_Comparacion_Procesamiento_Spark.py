# Databricks notebook source
# EXP-BD-02 | Comparacion de agregaciones DataFrames vs Spark SQL
# Proyecto: APM Inversiones E.I.R.L.
# Se ejecuta en Databricks Serverless sobre una tabla Delta existente.
# No escribe ni modifica tablas persistentes.

# COMMAND ----------

# 1. Lectura de la tabla Silver
from pyspark.sql import functions as F
import time
from statistics import mean

df = spark.table("workspace.apm_inversiones.asistencia_silver")
print("Total de registros:", df.count())
print("Total de columnas:", len(df.columns))
display(df.limit(10))

# COMMAND ----------

# 2. Metodos equivalentes (mismas columnas y mismo agregado)
datos = df.select("Estado", "Horas_Cumplidas")
resultado_df = (
    datos.groupBy("Estado")
    .agg(
        F.count("*").alias("Total"),
        F.round(F.avg("Horas_Cumplidas"), 3).alias("Promedio_Horas")
    )
    .orderBy("Estado")
)
print("METODO 1: DATAFRAMES")
display(resultado_df)

datos.createOrReplaceTempView("exp_bd02_datos")
resultado_sql = spark.sql("""
    SELECT
        Estado,
        COUNT(*) AS Total,
        ROUND(AVG(Horas_Cumplidas), 3) AS Promedio_Horas
    FROM exp_bd02_datos
    GROUP BY Estado
    ORDER BY Estado
""")
print("METODO 2: SPARK SQL")
display(resultado_sql)

# COMMAND ----------

# 3. Cinco repeticiones por metodo, calentamiento y alternancia del orden.
# .collect() fuerza la ejecucion de cada consulta.
resultados = []
resultado_df.collect()
resultado_sql.collect()

for prueba in range(1, 6):
    metodos = [("DataFrames", resultado_df), ("Spark SQL", resultado_sql)]
    if prueba % 2 == 0:
        metodos.reverse()
    for nombre, consulta in metodos:
        inicio = time.perf_counter()
        filas = consulta.collect()
        tiempo_ms = (time.perf_counter() - inicio) * 1000
        resultados.append((prueba, nombre, round(tiempo_ms, 3)))

df_resultados = spark.createDataFrame(
    resultados, ["Prueba", "Metodo", "Tiempo_ms"]
)
print("RESULTADOS DE LAS 10 PRUEBAS")
display(df_resultados.orderBy("Prueba", "Metodo"))
print("PROMEDIOS FINALES")
for metodo in ["DataFrames", "Spark SQL"]:
    tiempos = [r[2] for r in resultados if r[1] == metodo]
    print(metodo, "- Promedio:", round(mean(tiempos), 3), "ms")

# COMMAND ----------

# 4. Calculo dinamico a partir de mediciones de esta ejecucion.
promedio_df = mean(r[2] for r in resultados if r[1] == "DataFrames")
promedio_sql = mean(r[2] for r in resultados if r[1] == "Spark SQL")
diferencia = promedio_df - promedio_sql
mejora = diferencia / promedio_df * 100 if promedio_df else float("nan")
print("RESULTADOS FINALES DEL EXPERIMENTO")
print("DataFrames:", round(promedio_df, 3), "ms")
print("Spark SQL:", round(promedio_sql, 3), "ms")
print("Diferencia:", round(diferencia, 3), "ms")
print("Reduccion relativa del tiempo con Spark SQL:", round(mejora, 2), "%")
