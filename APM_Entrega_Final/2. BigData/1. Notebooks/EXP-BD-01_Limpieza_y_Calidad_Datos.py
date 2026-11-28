# Databricks notebook source
# EXP-BD-01: Calidad de datos Bronze vs Silver y limpieza controlada
# Proyecto: APM Inversiones E.I.R.L.
# Uso exclusivo de lectura. Los registros corruptos son SINTETICOS,
# y no se guardan cambios en tablas de Databricks.

# COMMAND ----------
from pyspark.sql import functions as F

bronze = spark.table("workspace.apm_inversiones.asistencia_bronze")
silver = spark.table("workspace.apm_inversiones.asistencia_silver")

print("REGISTROS")
print("Bronze:", bronze.count())
print("Silver:", silver.count())
print("COLUMNAS BRONZE:", bronze.columns)
print("COLUMNAS SILVER:", silver.columns)

# COMMAND ----------
# Calidad inicial bajo reglas limitadas: campos nulos y horas negativas

def evaluar_calidad(datos, nombre):
    horas = F.expr("try_cast(Horas_Cumplidas AS DOUBLE)")
    return datos.agg(
        F.count("*").alias("Total_Registros"),
        F.sum(F.when(
            F.col("Estado").isNull() |
            F.col("Fecha").isNull() |
            F.col("Horas_Cumplidas").isNull(), 1
        ).otherwise(0)).alias("Registros_Incompletos"),
        F.sum(F.when(horas < 0, 1).otherwise(0)).alias("Horas_Negativas")
    ).withColumn("Capa", F.lit(nombre))

comparacion = evaluar_calidad(bronze, "Bronze").unionByName(
    evaluar_calidad(silver, "Silver")
)
display(comparacion.select(
    "Capa", "Total_Registros", "Registros_Incompletos", "Horas_Negativas"
))
display(silver.groupBy("Calidad_Registro").count())

# COMMAND ----------
# Tres errores de prueba; no se actualizan las tablas de origen.
modelo = bronze.limit(1)
caso_1 = modelo.withColumn(
    "Estado", F.lit(None).cast(bronze.schema["Estado"].dataType)
)
caso_2 = modelo.withColumn(
    "Horas_Cumplidas", F.lit(-2.0).cast(bronze.schema["Horas_Cumplidas"].dataType)
)
caso_3 = modelo.withColumn(
    "Fecha", F.lit(None).cast(bronze.schema["Fecha"].dataType)
)
datos_prueba = bronze.unionByName(caso_1).unionByName(caso_2).unionByName(caso_3)

def resumen_calidad(datos, etapa):
    horas = F.expr("try_cast(Horas_Cumplidas AS DOUBLE)")
    error = (
        F.col("Estado").isNull() |
        F.col("Fecha").isNull() |
        F.col("Horas_Cumplidas").isNull() |
        horas.isNull() |
        (horas < 0)
    )
    return datos.agg(
        F.count("*").alias("Total_Registros"),
        F.sum(F.when(error, 1).otherwise(0)).alias("Registros_Con_Error")
    ).withColumn("Etapa", F.lit(etapa))

print("DATOS EXPERIMENTALES CON ERRORES")
display(datos_prueba.agg(
    F.count("*").alias("Total_Registros"),
    F.sum(F.when(
        F.col("Estado").isNull() |
        F.col("Fecha").isNull() |
        F.col("Horas_Cumplidas").isNull(), 1
    ).otherwise(0)).alias("Registros_Incompletos"),
    F.sum(F.when(
        F.expr("try_cast(Horas_Cumplidas AS DOUBLE)") < 0, 1
    ).otherwise(0)).alias("Horas_Negativas")
))

# COMMAND ----------
# Aplicar limpieza a la copia experimental unicamente.
horas_validas = F.expr("try_cast(Horas_Cumplidas AS DOUBLE)")
datos_limpios = datos_prueba.filter(
    F.col("Estado").isNotNull() &
    F.col("Fecha").isNotNull() &
    F.col("Horas_Cumplidas").isNotNull() &
    horas_validas.isNotNull() &
    (horas_validas >= 0)
)

antes_n = datos_prueba.count()
despues_n = datos_limpios.count()
print("RESULTADOS DE LA LIMPIEZA")
print("Registros antes:", antes_n)
print("Registros despues:", despues_n)
print("Registros eliminados:", antes_n - despues_n)
assert antes_n == 7114 and despues_n == 7111

# COMMAND ----------
antes = resumen_calidad(datos_prueba, "Antes")
despues = resumen_calidad(datos_limpios, "Despues")
print("COMPARACION FINAL EXP-BD-01")
comparacion_final = antes.unionByName(despues).select(
    "Etapa", "Total_Registros", "Registros_Con_Error"
)
display(comparacion_final)
# Solo se prueba la eliminación de los tres registros sintéticos bajo las
# reglas definidas; no implica ausencia de todos los posibles errores.
print("Registros incorrectos sinteticos eliminados: 3 de 3 (100 %)")
