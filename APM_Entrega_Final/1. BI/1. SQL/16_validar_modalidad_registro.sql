USE ASISTENCIA;
GO

-- Validación de relación con la quinta dimensión.
-- Consulta de solo lectura. Resultado observado el 27/11/2026:
-- Total_Asistencias 7111; Sin_Modalidad 0;
-- Modalidad_Valida 7111; Modalidad_Inexistente 0.
SELECT
    COUNT(*) AS Total_Asistencias,
    SUM(CASE WHEN F.id_modalidad IS NULL THEN 1 ELSE 0 END) AS Sin_Modalidad,
    SUM(CASE WHEN F.id_modalidad IS NOT NULL AND M.id_modalidad IS NOT NULL THEN 1 ELSE 0 END) AS Modalidad_Valida,
    SUM(CASE WHEN F.id_modalidad IS NOT NULL AND M.id_modalidad IS NULL THEN 1 ELSE 0 END) AS Modalidad_Inexistente
FROM dbo.FactAsistencia_ETL AS F
LEFT JOIN dbo.DimModalidadRegistro AS M
    ON F.id_modalidad = M.id_modalidad;
GO
