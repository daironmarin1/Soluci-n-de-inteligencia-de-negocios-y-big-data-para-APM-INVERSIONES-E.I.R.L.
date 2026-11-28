USE ASISTENCIA;
GO

SELECT
    COUNT(*) AS Total_Registros,
    COUNT(DISTINCT asistencia_id) AS Asistencias_Unicas,
    COUNT(DISTINCT practicante_id) AS Practicantes,
    MIN(fecha) AS Fecha_Inicial,
    MAX(fecha) AS Fecha_Final
FROM dbo.FactAsistencia_ETL;
GO