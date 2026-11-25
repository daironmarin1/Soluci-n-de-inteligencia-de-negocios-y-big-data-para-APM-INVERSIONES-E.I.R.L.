# Databricks notebook source
df_experimento = spark.table("workspace.apm_inversiones.asistencia_silver")
print("Registros para el experimento:", df_experimento.count())

# COMMAND ----------

df_agrupado = df_experimento.groupBy("Estado").count()
display(df_agrupado.orderBy("Estado"))

# COMMAND ----------

import time
tiempos_sin_cache = []
for i in range(5):
    inicio = time.perf_counter()
    resultados = df_agrupado.orderBy("Estado").collect()
    fin = time.perf_counter()
    duracion = fin - inicio
    tiempos_sin_cache.append(duracion)
    total = sum(fila["count"] for fila in resultados)
    print(f"Prueba {i+1}: {duracion:.4f} segundos | Registros: {total}")
promedio_sin_cache = sum(tiempos_sin_cache) / 5
print(f"\nPromedio SIN caché: {promedio_sin_cache:.4f} segundos")


# COMMAND ----------

inicio_cache = time.perf_counter()
df_agrupado.cache()
fin_cache = time.perf_counter()
tiempo_preparacion_cache = fin_cache - inicio_cache
print(f"Tiempo de preparación de caché: {tiempo_preparacion_cache:.4f} segundos")
print("Grupos almacenados:", df_agrupado.count())


# COMMAND ----------

tiempos_con_cache = []
for i in range(5):
    inicio = time.perf_counter()
    resultados = df_agrupado.orderBy("Estado").collect()
    fin = time.perf_counter()
    duracion = fin - inicio
    tiempos_con_cache.append(duracion)
    total = sum(fila["count"] for fila in resultados)
    print(f"Prueba {i+1}: {duracion:.4f} segundos | Registros: {total}")
promedio_con_cache = sum(tiempos_con_cache) / 5
print(f"\nPromedio CON caché: {promedio_con_cache:.4f} segundos")

# COMMAND ----------

diferencia = promedio_con_cache - promedio_sin_cache
porcentaje = (diferencia / promedio_sin_cache) * 100
print("RESULTADOS DEL EXPERIMENTO EXP-BD-04")
print("----------------------------------")
print(f"Promedio SIN caché: {promedio_sin_cache:.4f} segundos")
print(f"Promedio CON caché: {promedio_con_cache:.4f} segundos")
print(f"Diferencia: {diferencia:.4f} segundos")
print(f"Variación: {porcentaje:.2f}%")
if porcentaje > 0:
    print("Resultado: CON caché fue más lento.")
elif porcentaje < 0:
    print("Resultado: CON caché fue más rápido.")
else:
    print("Resultado: ambos tiempos fueron iguales.")

# COMMAND ----------

df_agrupado.unpersist()
print("Caché liberada correctamente.")
print("Experimento EXP-BD-04 finalizado.")

# COMMAND ----------

# Ampliar datos ficticios para pruebas de rendimiento
df_prueba_100k = (
    df_experimento.crossJoin(spark.range(15).toDF("Replica")).limit(100000))
print("Total de registros:", df_prueba_100k.count())

# COMMAND ----------

from pyspark.sql import functions as F
df_agrupado_100k = (
    df_prueba_100k
    .groupBy("Curso_ID", "Estado")
    .agg(
        F.count("*").alias("Total_Asistencias"),
        F.sum("Horas_Cumplidas").alias("Total_Horas")
    )
)
total = df_agrupado_100k.agg(
    F.sum("Total_Asistencias")
).first()[0]
print("Registros procesados:", total)
print("Grupos obtenidos:", df_agrupado_100k.count())

# COMMAND ----------

import time
tiempos_100k_sin_cache = []
for i in range(5):
    inicio = time.perf_counter()
    resultados = df_agrupado_100k.orderBy("Curso_ID", "Estado").collect()
    fin = time.perf_counter()
    duracion = fin - inicio
    tiempos_100k_sin_cache.append(duracion)
    total = sum(fila["Total_Asistencias"] for fila in resultados)
    print(f"Prueba {i+1}: {duracion:.4f} segundos | Registros: {total}")
promedio_100k_sin_cache = sum(tiempos_100k_sin_cache) / 5
print(f"\nPromedio 100K SIN caché: {promedio_100k_sin_cache:.4f} segundos")


# COMMAND ----------

import time
tiempos_100k_sin_cache = []
for i in range(5):
    inicio = time.perf_counter()
    resultados = df_agrupado_100k.orderBy("Curso_ID", "Estado").collect()
    fin = time.perf_counter()
    duracion = fin - inicio
    tiempos_100k_sin_cache.append(duracion)
    total = sum(fila["Total_Asistencias"] for fila in resultados)
    print(f"Prueba {i+1}: {duracion:.4f} segundos | Registros: {total}")
promedio_100k_sin_cache = sum(tiempos_100k_sin_cache) / 5
print(f"\nPromedio 100K SIN caché: {promedio_100k_sin_cache:.4f} segundos")


# COMMAND ----------


import time

inicio_cache_100k = time.perf_counter()

df_100k_cache = df_prueba_100k.cache()

total_cache_100k = df_100k_cache.count()

fin_cache_100k = time.perf_counter()

tiempo_preparacion_100k = fin_cache_100k - inicio_cache_100k

print("CACHÉ DE 100,000 REGISTROS")
print("Registros almacenados:", total_cache_100k)
print(f"Tiempo de preparación: {tiempo_preparacion_100k:.4f} segundos")


# COMMAND ----------


from pyspark.sql import functions as F
import time

df_agrupado_100k_cache = (
    df_100k_cache
    .groupBy("Curso_ID", "Estado")
    .agg(
        F.count("*").alias("Total_Asistencias"),
        F.sum("Horas_Cumplidas").alias("Total_Horas")
    )
)

tiempos_100k_con_cache = []

for i in range(5):
    inicio = time.perf_counter()

    resultados = df_agrupado_100k_cache.orderBy(
        "Curso_ID", "Estado"
    ).collect()

    fin = time.perf_counter()
    duracion = fin - inicio

    tiempos_100k_con_cache.append(duracion)

    total = sum(fila["Total_Asistencias"] for fila in resultados)

    print(f"Prueba {i+1}: {duracion:.4f} segundos | Registros: {total}")

promedio_100k_con_cache = sum(tiempos_100k_con_cache) / 5

print(f"\nPromedio 100K CON caché: {promedio_100k_con_cache:.4f} segundos")


# COMMAND ----------


diferencia_100k = promedio_100k_sin_cache - promedio_100k_con_cache

mejora_100k = (diferencia_100k / promedio_100k_sin_cache) * 100

print("EXPERIMENTO CON 100,000 REGISTROS")
print("--------------------------------")
print(f"Sin caché: {promedio_100k_sin_cache:.4f} segundos")
print(f"Con caché: {promedio_100k_con_cache:.4f} segundos")
print(f"Diferencia: {diferencia_100k:.4f} segundos")
print(f"Mejora observada: {mejora_100k:.2f}%")
print(f"Preparación de caché: {tiempo_preparacion_100k:.4f} segundos")


# COMMAND ----------


df_100k_cache.unpersist()

print("Caché de 100,000 registros liberada.")
print("Listo para el experimento de 500,000 registros.")


# COMMAND ----------


# Crear 500,000 registros sintéticos para el experimento
df_prueba_500k = (
    df_experimento
    .crossJoin(spark.range(71).toDF("Replica"))
    .limit(500000)
)
print("EXPERIMENTO CON 500,000 REGISTROS")
print("Total de registros:", df_prueba_500k.count())


# COMMAND ----------


from pyspark.sql import functions as F

df_agrupado_500k = (
    df_prueba_500k
    .groupBy("Curso_ID", "Estado")
    .agg(
        F.count("*").alias("Total_Asistencias"),
        F.sum("Horas_Cumplidas").alias("Total_Horas")
    )
)

total_500k = df_agrupado_500k.agg(
    F.sum("Total_Asistencias")
).first()[0]

print("Registros procesados:", total_500k)
print("Grupos obtenidos:", df_agrupado_500k.count())


# COMMAND ----------


import time
tiempos_500k_sin_cache = []

for i in range(5):
    inicio = time.perf_counter()

    resultados = df_agrupado_500k.orderBy(
        "Curso_ID", "Estado"
    ).collect()

    fin = time.perf_counter()
    duracion = fin - inicio

    tiempos_500k_sin_cache.append(duracion)

    total = sum(fila["Total_Asistencias"] for fila in resultados)

    print(f"Prueba {i+1}: {duracion:.4f} segundos | Registros: {total}")

promedio_500k_sin_cache = sum(tiempos_500k_sin_cache) / 5

print(f"\nPromedio 500K SIN caché: {promedio_500k_sin_cache:.4f} segundos")


# COMMAND ----------


import time

inicio_cache_500k = time.perf_counter()

df_500k_cache = df_prueba_500k.cache()

total_cache_500k = df_500k_cache.count()

fin_cache_500k = time.perf_counter()

tiempo_preparacion_500k = fin_cache_500k - inicio_cache_500k

print("CACHÉ DE 500,000 REGISTROS")
print("Registros almacenados:", total_cache_500k)
print(f"Tiempo de preparación: {tiempo_preparacion_500k:.4f} segundos")


# COMMAND ----------


from pyspark.sql import functions as F
import time

df_agrupado_500k_cache = (
    df_500k_cache
    .groupBy("Curso_ID", "Estado")
    .agg(
        F.count("*").alias("Total_Asistencias"),
        F.sum("Horas_Cumplidas").alias("Total_Horas")
    )
)

tiempos_500k_con_cache = []

for i in range(5):
    inicio = time.perf_counter()

    resultados = df_agrupado_500k_cache.orderBy(
        "Curso_ID", "Estado"
    ).collect()

    fin = time.perf_counter()
    duracion = fin - inicio

    tiempos_500k_con_cache.append(duracion)

    total = sum(fila["Total_Asistencias"] for fila in resultados)

    print(f"Prueba {i+1}: {duracion:.4f} segundos | Registros: {total}")

promedio_500k_con_cache = sum(tiempos_500k_con_cache) / 5

print(f"\nPromedio 500K CON caché: {promedio_500k_con_cache:.4f} segundos")


# COMMAND ----------


diferencia_500k = promedio_500k_sin_cache - promedio_500k_con_cache

mejora_500k = (diferencia_500k / promedio_500k_sin_cache) * 100

print("EXPERIMENTO CON 500,000 REGISTROS")
print("--------------------------------")
print(f"Sin caché: {promedio_500k_sin_cache:.4f} segundos")
print(f"Con caché: {promedio_500k_con_cache:.4f} segundos")
print(f"Diferencia: {diferencia_500k:.4f} segundos")
print(f"Mejora observada: {mejora_500k:.2f}%")
print(f"Preparación de caché: {tiempo_preparacion_500k:.4f} segundos")


# COMMAND ----------


df_500k_cache.unpersist()

print("Caché de 500,000 registros liberada.")
print("Listo para el experimento de 1,000,000 de registros.")


# COMMAND ----------


# Crear 1,000,000 de registros sintéticos
df_prueba_1m = (
    df_experimento
    .crossJoin(spark.range(141).toDF("Replica"))
    .limit(1000000)
)

print("EXPERIMENTO CON 1,000,000 DE REGISTROS")
print("Total de registros:", df_prueba_1m.count())


# COMMAND ----------


from pyspark.sql import functions as F

df_agrupado_1m = (
    df_prueba_1m
    .groupBy("Curso_ID", "Estado")
    .agg(
        F.count("*").alias("Total_Asistencias"),
        F.sum("Horas_Cumplidas").alias("Total_Horas")
    )
)

total_1m = df_agrupado_1m.agg(
    F.sum("Total_Asistencias")
).first()[0]

print("Registros procesados:", total_1m)
print("Grupos obtenidos:", df_agrupado_1m.count())


# COMMAND ----------


import time

tiempos_1m_sin_cache = []

for i in range(5):
    inicio = time.perf_counter()

    resultados = df_agrupado_1m.orderBy(
        "Curso_ID", "Estado"
    ).collect()

    fin = time.perf_counter()
    duracion = fin - inicio

    tiempos_1m_sin_cache.append(duracion)

    total = sum(fila["Total_Asistencias"] for fila in resultados)

    print(f"Prueba {i+1}: {duracion:.4f} segundos | Registros: {total}")

promedio_1m_sin_cache = sum(tiempos_1m_sin_cache) / 5

print(f"\nPromedio 1M SIN caché: {promedio_1m_sin_cache:.4f} segundos")


# COMMAND ----------


import time

inicio_cache_1m = time.perf_counter()

df_1m_cache = df_prueba_1m.cache()

total_cache_1m = df_1m_cache.count()

fin_cache_1m = time.perf_counter()

tiempo_preparacion_1m = fin_cache_1m - inicio_cache_1m

print("CACHÉ DE 1,000,000 DE REGISTROS")
print("Registros almacenados:", total_cache_1m)
print(f"Tiempo de preparación: {tiempo_preparacion_1m:.4f} segundos")


# COMMAND ----------


from pyspark.sql import functions as F
import time

df_agrupado_1m_cache = (
    df_1m_cache
    .groupBy("Curso_ID", "Estado")
    .agg(
        F.count("*").alias("Total_Asistencias"),
        F.sum("Horas_Cumplidas").alias("Total_Horas")
    )
)

tiempos_1m_con_cache = []

for i in range(5):
    inicio = time.perf_counter()

    resultados = df_agrupado_1m_cache.orderBy(
        "Curso_ID", "Estado"
    ).collect()

    fin = time.perf_counter()
    duracion = fin - inicio

    tiempos_1m_con_cache.append(duracion)

    total = sum(fila["Total_Asistencias"] for fila in resultados)

    print(f"Prueba {i+1}: {duracion:.4f} segundos | Registros: {total}")

promedio_1m_con_cache = sum(tiempos_1m_con_cache) / 5

print(f"\nPromedio 1M CON caché: {promedio_1m_con_cache:.4f} segundos")


# COMMAND ----------


diferencia_1m = promedio_1m_sin_cache - promedio_1m_con_cache

mejora_1m = (diferencia_1m / promedio_1m_sin_cache) * 100

print("EXPERIMENTO CON 1,000,000 DE REGISTROS")
print("-------------------------------------")
print(f"Sin caché: {promedio_1m_sin_cache:.4f} segundos")
print(f"Con caché: {promedio_1m_con_cache:.4f} segundos")
print(f"Diferencia: {diferencia_1m:.4f} segundos")
print(f"Mejora observada: {mejora_1m:.2f}%")
print(f"Preparación de caché: {tiempo_preparacion_1m:.4f} segundos")


# COMMAND ----------


df_1m_cache.unpersist()

print("Caché de 1,000,000 de registros liberada.")
print("Mediciones del experimento EXP-BD-04 completadas.")


# COMMAND ----------

datos_comparacion = [
    (100000, promedio_100k_sin_cache, promedio_100k_con_cache, tiempo_preparacion_100k),
    (500000, promedio_500k_sin_cache, promedio_500k_con_cache, tiempo_preparacion_500k),
    (1000000, promedio_1m_sin_cache, promedio_1m_con_cache, tiempo_preparacion_1m)
]
df_comparacion = spark.createDataFrame(
    datos_comparacion,
    ["Registros", "Sin_Cache_s", "Con_Cache_s", "Preparacion_s"]
)
from pyspark.sql.functions import col, round
df_comparacion = df_comparacion.withColumn(
    "Mejora_Porcentaje",
    round(
        ((col("Sin_Cache_s") - col("Con_Cache_s")) /
         col("Sin_Cache_s")) * 100,
        2
    )
)
display(df_comparacion.orderBy("Registros"))

# COMMAND ----------


# Resultados obtenidos en las pruebas de rendimiento
datos_grafico = [
    (100000, "Sin caché", 0.7298),
    (100000, "Con caché", 0.5970),
    (500000, "Sin caché", 0.7557),
    (500000, "Con caché", 0.6344),
    (1000000, "Sin caché", 0.7854),
    (1000000, "Con caché", 0.6305)
]

df_grafico = spark.createDataFrame(
    datos_grafico,
    ["Registros", "Metodo", "Tiempo_s"]
)

display(df_grafico.orderBy("Registros", "Metodo"))


# COMMAND ----------

# MAGIC %md
# MAGIC
# MAGIC ## EXP-BD-04: Comparación del rendimiento de Spark con y sin caché
# MAGIC
# MAGIC ### Objetivo
# MAGIC Comparar los tiempos de ejecución de consultas de agregación en Apache Spark, utilizando caché y sin caché explícita.
# MAGIC
# MAGIC ### Metodología
# MAGIC Se utilizó un conjunto inicial de 7,111 registros ficticios de asistencia. Para evaluar distintos volúmenes, se generaron conjuntos sintéticos de 100,000, 500,000 y 1,000,000 de registros mediante replicación.
# MAGIC
# MAGIC En cada conjunto se realizaron cinco ejecuciones por condición. Se calcularon los tiempos promedio y se registró por separado el costo de preparación de la caché.
# MAGIC
# MAGIC ### Resultados
# MAGIC
# MAGIC | Registros | Sin caché | Con caché | Mejora |
# MAGIC |---|---|---|---|
# MAGIC | 100,000 | 0.7298 s | 0.5970 s | 18.20 % |
# MAGIC | 500,000 | 0.7557 s | 0.6344 s | 16.06 % |
# MAGIC | 1,000,000 | 0.7854 s | 0.6305 s | 19.73 % |
# MAGIC
# MAGIC ### Interpretación
# MAGIC Las consultas repetidas con caché presentaron menores tiempos promedio en los tres tamaños evaluados.
# MAGIC
# MAGIC Sin embargo, preparar la caché requirió entre 2.50 y 3.04 segundos, aproximadamente. Por tanto, el ahorro registrado durante las cinco consultas no compensó el costo inicial de preparación.
# MAGIC
# MAGIC ### Limitaciones
# MAGIC Los registros ampliados son sintéticos y contienen datos replicados. Las consultas producen siete grupos de salida y las mediciones pueden variar según las condiciones del entorno Serverless.
# MAGIC
# MAGIC ### Conclusión
# MAGIC La caché redujo los tiempos promedio de consulta en las condiciones evaluadas, pero no mejoró el tiempo total del proceso al considerar su preparación. Su conveniencia depende de la carga de trabajo y del número de veces que se reutilizan los datos.
# MAGIC