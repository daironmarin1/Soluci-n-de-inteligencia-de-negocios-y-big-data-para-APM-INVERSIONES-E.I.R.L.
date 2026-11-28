# Databricks notebook source
# EXP-BD-03 - Comparacion de procesamiento con 1 vs 8 particiones
# APM Inversiones E.I.R.L. | Apache Spark, Databricks
# Reconstruccion del notebook a partir del codigo y las capturas compartidos.
# No modifica ni escribe en tablas de Databricks.

# COMMAND ----------

# Paso 1. Cargar y replicar 70 veces los 7111 registros de Silver.
from pyspark.sql import functions as F
from statistics import mean
import time

df_base = spark.table("workspace.apm_inversiones.asistencia_silver")
print("Registros originales:", df_base.count())
df_datos = df_base.select("Estado", "Horas_Cumplidas")
df_grande = df_datos.crossJoin(
    spark.range(70).selectExpr("id AS replica")
).drop("replica")
print("Registros de prueba:", df_grande.count())
display(df_grande.limit(10))

# COMMAND ----------

# Paso 2. Medir el mismo agregado con dos configuraciones de particionado.
# El costo de repartition() puede incluirse en la medicion por evaluacion diferida.
datos_1 = df_grande.repartition(1)
datos_8 = df_grande.repartition(8)

def procesar(datos):
    return (
        datos.groupBy("Estado")
        .agg(
            F.count("*").alias("Total"),
            F.round(F.avg("Horas_Cumplidas"), 3).alias("Promedio_Horas")
        )
        .collect()
    )

# Calentamiento inicial fuera de las mediciones.
procesar(datos_1)
procesar(datos_8)

resultados = []
for prueba in range(1, 6):
    configuraciones = [
        ("1 particion", datos_1),
        ("8 particiones", datos_8)
    ]
    if prueba % 2 == 0:
        configuraciones.reverse()

    for nombre, datos in configuraciones:
        inicio = time.perf_counter()
        filas = procesar(datos)
        tiempo_ms = (time.perf_counter() - inicio) * 1000
        total = sum(fila["Total"] for fila in filas)
        assert total == 497770, f"Conteo inesperado: {total}"
        resultados.append((prueba, nombre, round(tiempo_ms, 3)))

# Mostrar las mediciones y promedios calculados dinamicamente.
df_resultados = spark.createDataFrame(
    resultados, ["Prueba", "Configuracion", "Tiempo_ms"]
)
print("RESULTADOS DE LAS 10 PRUEBAS")
display(df_resultados.orderBy("Prueba", "Configuracion"))
print("PROMEDIOS FINALES")
for nombre in ["1 particion", "8 particiones"]:
    tiempos = [r[2] for r in resultados if r[1] == nombre]
    print(nombre, "- Promedio:", round(mean(tiempos), 3), "ms")

# COMMAND ----------

# Paso 3. Comparar los promedios medidos en esta ejecucion.
promedio_1 = mean(r[2] for r in resultados if r[1] == "1 particion")
promedio_8 = mean(r[2] for r in resultados if r[1] == "8 particiones")
diferencia = promedio_8 - promedio_1
incremento = (diferencia / promedio_1) * 100 if promedio_1 else float('nan')
print("RESULTADOS FINALES EXP-BD-03")
print("Registros de prueba: 497770")
print("1 particion:", round(promedio_1, 3), "ms")
print("8 particiones:", round(promedio_8, 3), "ms")
print("Diferencia:", round(diferencia, 3), "ms")
print("Incremento del tiempo:", round(incremento, 2), "%")
print("Configuracion mas rapida en esta ejecucion:",
      "1 particion" if promedio_1 < promedio_8 else "8 particiones")
