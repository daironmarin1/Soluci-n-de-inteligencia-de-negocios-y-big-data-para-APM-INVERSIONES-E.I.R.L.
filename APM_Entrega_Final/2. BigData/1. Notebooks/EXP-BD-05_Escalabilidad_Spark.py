# Databricks notebook source
# EXP-BD-05 - Escalabilidad del procesamiento con Spark
# APM Inversiones E.I.R.L. | Codigo reconstruido desde las celdas compartidas.
# No es una exportacion nativa de Databricks ni modifica tablas persistentes.

# COMMAND ----------

# Paso 1 - Tres escenarios sobre el mismo contenido Silver
from statistics import mean
from pyspark.sql import functions as F
import time

df_base = spark.table(
    "workspace.apm_inversiones.asistencia_silver"
).select("Estado", "Horas_Cumplidas")

df_A = df_base
df_B = df_base.crossJoin(
    spark.range(10).selectExpr("id AS replica")
).drop("replica")
df_C = df_base.crossJoin(
    spark.range(100).selectExpr("id AS replica")
).drop("replica")

print("ESCENARIOS DEL EXPERIMENTO")
print("A - Original:", df_A.count())
print("B - 10 veces:", df_B.count())
print("C - 100 veces:", df_C.count())

# COMMAND ----------

# Paso 2 - Cinco pruebas por escenario, con calentamiento
escenarios = [
    ("A", df_A, 7111),
    ("B", df_B, 71110),
    ("C", df_C, 711100)
]

def procesar(datos):
    return (
        datos.groupBy("Estado")
        .agg(
            F.count("*").alias("Total"),
            F.round(F.avg("Horas_Cumplidas"), 3).alias("Promedio_Horas")
        )
        .collect()
    )

for nombre, datos, esperado in escenarios:
    filas = procesar(datos)
    assert sum(fila["Total"] for fila in filas) == esperado

resultados = []
for prueba in range(1, 6):
    orden = escenarios[(prueba - 1) % 3:] + escenarios[:(prueba - 1) % 3]
    for nombre, datos, esperado in orden:
        inicio = time.perf_counter()
        filas = procesar(datos)
        tiempo_ms = (time.perf_counter() - inicio) * 1000
        assert sum(fila["Total"] for fila in filas) == esperado
        resultados.append((nombre, esperado, prueba, round(tiempo_ms, 3)))

df_resultados = spark.createDataFrame(
    resultados, ["Escenario", "Registros", "Prueba", "Tiempo_ms"]
)
print("RESULTADOS DE LAS 15 PRUEBAS")
display(df_resultados.orderBy("Escenario", "Prueba"))
print("PROMEDIOS FINALES")
for nombre, datos, esperado in escenarios:
    tiempos = [r[3] for r in resultados if r[0] == nombre]
    print(nombre, "- Registros:", esperado,
          "- Promedio:", round(mean(tiempos), 3), "ms")

# COMMAND ----------

# Paso 3 - Comparacion usando las medidas que se acaban de obtener
promedios = {
    nombre: mean(fila[3] for fila in resultados if fila[0] == nombre)
    for nombre in ["A", "B", "C"]
}
base = promedios["A"]
print("RESULTADOS FINALES EXP-BD-05")
for nombre, cantidad in [("A", 7111), ("B", 71110), ("C", 711100)]:
    tiempo = promedios[nombre]
    incremento = (tiempo - base) / base * 100
    print("Escenario:", nombre,
          "| Registros:", cantidad,
          "| Promedio:", round(tiempo, 3), "ms",
          "| Variacion vs A:", round(incremento, 2), "%")
print("Experimento completado.")
