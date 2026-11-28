USE ASISTENCIA;
GO

-- Verificar cantidad de registros
SELECT COUNT(*) AS Total_Registros
FROM dbo.FactAsistencia_ETL;

-- Verificar calidad de registros
SELECT calidad_datos, COUNT(*) AS Cantidad
FROM dbo.FactAsistencia_ETL
GROUP BY calidad_datos;

-- Verificar modalidades de cierre
SELECT salida_auto, COUNT(*) AS Cantidad
FROM dbo.FactAsistencia_ETL
GROUP BY salida_auto;

-- Verificar fechas
SELECT
    MIN(fecha) AS Fecha_Inicial,
    MAX(fecha) AS Fecha_Final
FROM dbo.FactAsistencia_ETL;
GO