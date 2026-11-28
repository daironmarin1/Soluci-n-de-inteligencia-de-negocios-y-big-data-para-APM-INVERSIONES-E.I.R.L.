/*
 EXP-BI-05 — Rendimiento de consultas BI con y sin preagregación
 Proyecto: APM Inversiones E.I.R.L. | SSMS / SQL Server
 Ejecutar el script completo en una misma ventana y conexión.
 Modifica únicamente tablas temporales locales; no cambia las tablas originales.
 Los escenarios replican datos para pruebas: no son asistencias adicionales reales.
 El tiempo de generación del resumen NO forma parte del benchmark.
*/
USE ASISTENCIA;
GO
SET NOCOUNT ON;

-- Paso 1: generar los escenarios exclusivamente en tempdb.
DROP TABLE IF EXISTS #EXP_BI05_Detalle;
DROP TABLE IF EXISTS #EXP_BI05_Resumen;
DROP TABLE IF EXISTS #EXP_BI05_Resultados;

SELECT CAST(f.fecha AS DATE) AS fecha, f.estado
INTO #EXP_BI05_Detalle
FROM dbo.FactAsistencia_ETL AS f
CROSS JOIN (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) AS A(n)
CROSS JOIN (VALUES (1),(2),(3),(4),(5)) AS B(n);

SELECT fecha, estado, COUNT_BIG(*) AS Total_Asistencias
INTO #EXP_BI05_Resumen
FROM #EXP_BI05_Detalle
GROUP BY fecha, estado;

SELECT 'Detalle' AS Tipo_Tabla, COUNT_BIG(*) AS Registros
FROM #EXP_BI05_Detalle
UNION ALL
SELECT 'Resumen', COUNT_BIG(*) FROM #EXP_BI05_Resumen;

-- Verificar que ambos caminos devuelvan los mismos totales por estado.
IF EXISTS (
    SELECT estado, COUNT_BIG(*) AS Total
    FROM #EXP_BI05_Detalle GROUP BY estado
    EXCEPT
    SELECT estado, SUM(Total_Asistencias) AS Total
    FROM #EXP_BI05_Resumen GROUP BY estado
)
    THROW 51051, 'La preagregacion no coincide con los datos de detalle.', 1;

CREATE TABLE #EXP_BI05_Resultados (
    Metodo VARCHAR(30) NOT NULL,
    Prueba INT NOT NULL,
    Tiempo_ms DECIMAL(12,3) NOT NULL
);

DECLARE @Prueba INT = 1,
        @Inicio DATETIME2(7),
        @Tiempo DECIMAL(12,3),
        @Firma_Detalle INT,
        @Firma_Resumen INT;

-- Calentamiento: fuera de las cinco mediciones.
SELECT @Firma_Detalle = CHECKSUM_AGG(BINARY_CHECKSUM(estado, Total))
FROM (SELECT estado, COUNT_BIG(*) AS Total
      FROM #EXP_BI05_Detalle GROUP BY estado) AS T;

SELECT @Firma_Resumen = CHECKSUM_AGG(BINARY_CHECKSUM(estado, Total))
FROM (SELECT estado, SUM(Total_Asistencias) AS Total
      FROM #EXP_BI05_Resumen GROUP BY estado) AS T;

IF @Firma_Detalle <> @Firma_Resumen
    THROW 51052, 'Las dos consultas no devuelven los mismos resultados.', 1;

-- Paso 2: cinco mediciones de cada método (sin incluir la creación del resumen).
WHILE @Prueba <= 5
BEGIN
    SET @Inicio = SYSDATETIME();
    SELECT @Firma_Detalle = CHECKSUM_AGG(BINARY_CHECKSUM(estado, Total))
    FROM (SELECT estado, COUNT_BIG(*) AS Total
          FROM #EXP_BI05_Detalle GROUP BY estado) AS T;
    SET @Tiempo = DATEDIFF_BIG(MICROSECOND, @Inicio, SYSDATETIME()) / 1000.0;
    INSERT INTO #EXP_BI05_Resultados (Metodo, Prueba, Tiempo_ms)
    VALUES ('Sin preagregacion', @Prueba, @Tiempo);

    SET @Inicio = SYSDATETIME();
    SELECT @Firma_Resumen = CHECKSUM_AGG(BINARY_CHECKSUM(estado, Total))
    FROM (SELECT estado, SUM(Total_Asistencias) AS Total
          FROM #EXP_BI05_Resumen GROUP BY estado) AS T;
    SET @Tiempo = DATEDIFF_BIG(MICROSECOND, @Inicio, SYSDATETIME()) / 1000.0;
    INSERT INTO #EXP_BI05_Resultados (Metodo, Prueba, Tiempo_ms)
    VALUES ('Con preagregacion', @Prueba, @Tiempo);

    IF @Firma_Detalle <> @Firma_Resumen
        THROW 51053, 'Inconsistencia entre los resultados de las consultas.', 1;
    SET @Prueba += 1;
END;

SELECT * FROM #EXP_BI05_Resultados ORDER BY Metodo DESC, Prueba;
SELECT Metodo, COUNT(*) AS Total_Pruebas,
       CAST(AVG(Tiempo_ms) AS DECIMAL(12,3)) AS Promedio_ms,
       MIN(Tiempo_ms) AS Minimo_ms,
       MAX(Tiempo_ms) AS Maximo_ms
FROM #EXP_BI05_Resultados
GROUP BY Metodo;

-- Paso 3: calcular el porcentaje desde las mediciones de la sesión.
WITH Promedios AS (
    SELECT Metodo, AVG(CAST(Tiempo_ms AS FLOAT)) AS Promedio
    FROM #EXP_BI05_Resultados
    GROUP BY Metodo
), Comparacion AS (
    SELECT
        MAX(CASE WHEN Metodo='Sin preagregacion' THEN Promedio END) AS Sin_Preagregacion,
        MAX(CASE WHEN Metodo='Con preagregacion' THEN Promedio END) AS Con_Preagregacion
    FROM Promedios
)
SELECT CAST(Sin_Preagregacion AS DECIMAL(12,3)) AS Tiempo_Sin_Preagregacion_ms,
       CAST(Con_Preagregacion AS DECIMAL(12,3)) AS Tiempo_Con_Preagregacion_ms,
       CAST((Sin_Preagregacion-Con_Preagregacion)
             / NULLIF(Sin_Preagregacion,0)*100 AS DECIMAL(10,2)) AS Mejora_Porcentual
FROM Comparacion;
