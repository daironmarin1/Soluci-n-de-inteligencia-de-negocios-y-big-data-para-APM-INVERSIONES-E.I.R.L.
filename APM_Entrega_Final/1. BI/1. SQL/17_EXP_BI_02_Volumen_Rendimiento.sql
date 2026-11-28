/*
 EXP-BI-02: Rendimiento BI según volumen de registros
 Base: ASISTENCIA; origen: dbo.FactAsistencia_ETL
 Los escenarios B y C son réplicas sintéticas en tablas TEMPORALES locales.
 NO modifica la tabla de hechos ni otras tablas persistentes.
 Ejecución: abrir una nueva ventana de SSMS y ejecutar TODO el script de una vez.
 Pruebas: 5 por escenario. Tiempos en ms medidos en el servidor SQL.
*/
USE ASISTENCIA;
GO
SET NOCOUNT ON;

-- Paso 1: comprobar la base original
SELECT COUNT_BIG(*) AS Total_Registros,
       COUNT(DISTINCT estado) AS Estados_Diferentes,
       MIN(fecha) AS Fecha_Inicial,
       MAX(fecha) AS Fecha_Final
FROM dbo.FactAsistencia_ETL;

SELECT estado, COUNT_BIG(*) AS Total_Asistencias
FROM dbo.FactAsistencia_ETL
GROUP BY estado
ORDER BY Total_Asistencias DESC;

-- Paso 2: escenarios temporales
DROP TABLE IF EXISTS #ExpBI_A;
DROP TABLE IF EXISTS #ExpBI_B;
DROP TABLE IF EXISTS #ExpBI_C;

SELECT estado, fecha INTO #ExpBI_A
FROM dbo.FactAsistencia_ETL;

SELECT f.estado, f.fecha INTO #ExpBI_B
FROM dbo.FactAsistencia_ETL AS f
CROSS JOIN (SELECT TOP (10) object_id FROM sys.all_objects ORDER BY object_id) AS n;

SELECT f.estado, f.fecha INTO #ExpBI_C
FROM dbo.FactAsistencia_ETL AS f
CROSS JOIN (SELECT TOP (50) object_id FROM sys.all_objects ORDER BY object_id) AS n;

SELECT 'A' AS Escenario, COUNT_BIG(*) AS Registros FROM #ExpBI_A
UNION ALL SELECT 'B', COUNT_BIG(*) FROM #ExpBI_B
UNION ALL SELECT 'C', COUNT_BIG(*) FROM #ExpBI_C;

-- Paso 3: medir 5 veces la misma agregación por escenario
DECLARE @Resultados TABLE (
    Escenario CHAR(1) NOT NULL,
    Prueba INT NOT NULL,
    Tiempo_ms DECIMAL(12,3) NOT NULL
);
DECLARE @Escenario INT = 1,
        @Prueba INT,
        @Inicio DATETIME2(7),
        @Tiempo DECIMAL(12,3),
        @Control INT;

WHILE @Escenario <= 3
BEGIN
    SET @Prueba = 1;
    WHILE @Prueba <= 5
    BEGIN
        SET @Inicio = SYSDATETIME();

        IF @Escenario = 1
            SELECT @Control = CHECKSUM_AGG(BINARY_CHECKSUM(estado, Total))
            FROM (SELECT estado, COUNT_BIG(*) AS Total
                  FROM #ExpBI_A GROUP BY estado) AS T;
        IF @Escenario = 2
            SELECT @Control = CHECKSUM_AGG(BINARY_CHECKSUM(estado, Total))
            FROM (SELECT estado, COUNT_BIG(*) AS Total
                  FROM #ExpBI_B GROUP BY estado) AS T;
        IF @Escenario = 3
            SELECT @Control = CHECKSUM_AGG(BINARY_CHECKSUM(estado, Total))
            FROM (SELECT estado, COUNT_BIG(*) AS Total
                  FROM #ExpBI_C GROUP BY estado) AS T;

        SET @Tiempo = DATEDIFF_BIG(MICROSECOND, @Inicio, SYSDATETIME()) / 1000.0;
        INSERT INTO @Resultados(Escenario, Prueba, Tiempo_ms)
        VALUES (CHAR(64 + @Escenario), @Prueba, @Tiempo);
        SET @Prueba += 1;
    END;
    SET @Escenario += 1;
END;

SELECT Escenario, Prueba, Tiempo_ms
FROM @Resultados
ORDER BY Escenario, Prueba;

SELECT Escenario, COUNT(*) AS Total_Pruebas,
       CAST(AVG(Tiempo_ms) AS DECIMAL(12,3)) AS Promedio_ms,
       MIN(Tiempo_ms) AS Minimo_ms,
       MAX(Tiempo_ms) AS Maximo_ms
FROM @Resultados
GROUP BY Escenario ORDER BY Escenario;

-- Paso 4: incremento porcentual respecto al A, a partir de ESTA ejecución
;WITH Resumen AS (
    SELECT Escenario,
           CAST(AVG(Tiempo_ms) AS DECIMAL(12,3)) AS Promedio_ms
    FROM @Resultados GROUP BY Escenario
), Baseline AS (
    SELECT Promedio_ms AS Base_ms FROM Resumen WHERE Escenario = 'A'
)
SELECT R.Escenario, R.Promedio_ms,
       CAST(100.0 * (R.Promedio_ms / NULLIF(B.Base_ms, 0) - 1)
            AS DECIMAL(12,2)) AS Incremento_Porcentual_vs_A
FROM Resumen AS R CROSS JOIN Baseline AS B
ORDER BY R.Escenario;
