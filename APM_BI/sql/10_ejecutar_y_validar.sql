USE [ASISTENCIA_BI_DEMO];
GO
EXEC dbo.sp_Actualizar_Modelo_BI;
GO
SELECT 'FactAsistencia_ETL' AS tabla, COUNT(*) AS registros FROM dbo.FactAsistencia_ETL
UNION ALL SELECT 'DimPracticante',COUNT(*) FROM dbo.DimPracticante
UNION ALL SELECT 'DimEstado',COUNT(*) FROM dbo.DimEstado
UNION ALL SELECT 'DimTiempo',COUNT(*) FROM dbo.DimTiempo;
SELECT calidad_datos, COUNT(*) AS registros FROM dbo.FactAsistencia_ETL GROUP BY calidad_datos ORDER BY calidad_datos;
SELECT estado,COUNT(*) AS registros FROM dbo.FactAsistencia_ETL GROUP BY estado ORDER BY estado;
GO
