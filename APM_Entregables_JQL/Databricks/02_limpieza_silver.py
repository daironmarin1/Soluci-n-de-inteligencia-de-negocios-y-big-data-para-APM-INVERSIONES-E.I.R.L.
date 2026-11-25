# Databricks notebook source
df_bronze = spark.table("workspace.apm_inversiones.asistencia_bronze")
df_bronze.printSchema()

# COMMAND ----------

from pyspark.sql.functions import col, sum
df_bronze.select([sum(col(c).isNull().cast("int")).alias(c)for c in df_bronze.columns]).show()

# COMMAND ----------

total = df_bronze.count()
unicos = df_bronze.dropDuplicates().count()
print("Total de registros:", total)
print("Registros únicos:", unicos)
print("Posibles duplicados:", total - unicos)

# COMMAND ----------

from pyspark.sql.functions import col, trim
vacios = df_bronze.filter(trim(col("Estado")) == "").count()
print("Estados vacíos:", vacios)

# COMMAND ----------

from pyspark.sql.functions import col, trim
df_silver = df_bronze.withColumn( "Estado",trim(col("Estado")))
display(df_silver.limit(10))

# COMMAND ----------

print("Registros Bronze:", df_bronze.count())
print("Registros Silver:", df_silver.count())
corregidos = df_bronze.filter(col("Estado") != trim(col("Estado"))).count()
print("Estados con espacios corregidos:", corregidos)

# COMMAND ----------

print("Horas negativas:", df_silver.filter(col("Horas_Cumplidas") < 0).count())
display(df_silver.groupBy("Falta_Injustificada").count())

# COMMAND ----------


display(df_silver.groupBy("Estado", "Falta_Injustificada").count().orderBy("Estado"))

# COMMAND ----------

from pyspark.sql.functions import col, when
df_silver = df_silver.withColumn("Calidad_Registro", when((col("Horas_Cumplidas") < 0) |((col("Estado") == "Falta Injustificada") &(col("Falta_Injustificada") != 1)) |((col("Estado") != "Falta Injustificada") &(col("Falta_Injustificada") != 0)),"Revisar").otherwise("Correcto"))
display(df_silver.groupBy("Calidad_Registro").count())


# COMMAND ----------

df_silver.write.format("delta").saveAsTable("workspace.apm_inversiones.asistencia_silver")

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT Calidad_Registro,COUNT(*) AS Total 
# MAGIC FROM workspace.apm_inversiones.asistencia_silver
# MAGIC GROUP BY Calidad_Registro;

# COMMAND ----------

# MAGIC %sql
# MAGIC DESCRIBE TABLE workspace.apm_inversiones.asistencia_silver;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT 'Bronze' AS Capa, COUNT(*) AS Total
# MAGIC FROM workspace.apm_inversiones.asistencia_bronze
# MAGIC UNION ALL
# MAGIC SELECT 'Silver' AS Capa, COUNT(*) AS Total
# MAGIC FROM workspace.apm_inversiones.asistencia_silver;
# MAGIC

# COMMAND ----------

# MAGIC %sql
# MAGIC DESCRIBE DETAIL workspace.apm_inversiones.asistencia_silver;