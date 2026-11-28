# Databricks notebook source
# MAGIC
# MAGIC %fs head /Volumes/workspace/apm_inversiones/apm_inversiones_bronze/APM_Asistencia_exportacion_revision.csv

# COMMAND ----------

df_bronze = spark.read.csv("/Volumes/workspace/apm_inversiones/apm_inversiones_bronze/APM_Asistencia_exportacion_revision.csv",header=True,inferSchema=True,sep=";")

# COMMAND ----------


display(df_bronze)

# COMMAND ----------

df_bronze.write.format("delta").saveAsTable("workspace.apm_inversiones.asistencia_bronze")

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT Estado,COUNT(*) AS Total
# MAGIC FROM workspace.apm_inversiones.asistencia_bronze
# MAGIC GROUP BY Estado
# MAGIC ORDER BY Total DESC;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT COUNT(*) AS Total_Registros
# MAGIC FROM workspace.apm_inversiones.asistencia_bronze;

# COMMAND ----------

df_verificacion = spark.table("workspace.apm_inversiones.asistencia_bronze")
display(df_verificacion.limit(10))