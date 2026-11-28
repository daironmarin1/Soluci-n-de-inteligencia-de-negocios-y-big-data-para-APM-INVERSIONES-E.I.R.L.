USE ASISTENCIA;
GO

SELECT 'DimPracticante' AS Dimension, COUNT(*) AS Registros
FROM dbo.DimPracticante
UNION ALL
SELECT 'DimTiempo', COUNT(*)
FROM dbo.DimTiempo
UNION ALL
SELECT 'DimEstado', COUNT(*)
FROM dbo.DimEstado
UNION ALL
SELECT 'DimCalidadRegistro', COUNT(*)
FROM dbo.DimCalidadRegistro
UNION ALL
SELECT 'DimModalidadRegistro', COUNT(*)
FROM dbo.DimModalidadRegistro;
GO