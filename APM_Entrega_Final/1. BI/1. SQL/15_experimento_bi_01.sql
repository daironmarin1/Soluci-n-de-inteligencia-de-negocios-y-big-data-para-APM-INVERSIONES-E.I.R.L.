USE ASISTENCIA;
GO

-- 1. Contar datos ANTES
SELECT 
    (SELECT COUNT(*) FROM dbo.FactAsistencia_ETL) AS hechos_antes,
    (SELECT COUNT(*) FROM dbo.DimPracticante) AS dim_practicante_antes,
    (SELECT COUNT(*) FROM dbo.DimEstado) AS dim_estado_antes,
    (SELECT COUNT(*) FROM dbo.DimTiempo) AS dim_tiempo_antes,
    (SELECT COUNT(*) FROM dbo.DimModalidadRegistro) AS dim_modalidad_antes;

-- 2. Prender cronómetro, ejecutar actualización y apagar cronómetro
DECLARE @inicio DATETIME2 = SYSDATETIME();

EXEC dbo.sp_Actualizar_Modelo_BI;

DECLARE @fin DATETIME2 = SYSDATETIME();

SELECT 
    'EXP-BI-01' AS experimento,
    DATEDIFF(MILLISECOND, @inicio, @fin) AS duracion_ms,
    CAST(DATEDIFF(MILLISECOND, @inicio, @fin) / 1000.0 AS DECIMAL(10,3)) AS duracion_segundos;

-- 3. Contar datos DESPUÉS
SELECT 
    (SELECT COUNT(*) FROM dbo.FactAsistencia_ETL) AS hechos_despues,
    (SELECT COUNT(*) FROM dbo.DimPracticante) AS dim_practicante_despues,
    (SELECT COUNT(*) FROM dbo.DimEstado) AS dim_estado_despues,
    (SELECT COUNT(*) FROM dbo.DimTiempo) AS dim_tiempo_despues,
    (SELECT COUNT(*) FROM dbo.DimModalidadRegistro) AS dim_modalidad_despues;