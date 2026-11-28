/*
 EXP-BI-03: comparación de búsqueda de registros por fecha SIN índice y CON índice.
 Proyecto: APM Inversiones E.I.R.L.
 Reproducibilidad: SQL Server / SSMS. Abrir una NUEVA consulta, ejecutar TODO el script.
 Modifica exclusivamente tablas temporales locales de la sesión (#...).
 No modifica dbo.FactAsistencia_ETL ni crea índices permanentes.
 El costo de CREAR el índice no está incluido en el tiempo de búsqueda.
*/
USE ASISTENCIA;
GO
SET NOCOUNT ON;

-- 1. Crear un escenario sintético a partir de 50 réplicas de la tabla de hechos.
DROP TABLE IF EXISTS #EXP_BI03_Prueba;
DROP TABLE IF EXISTS #EXP_BI03_Resultados;
SELECT f.estado, f.fecha
INTO #EXP_BI03_Prueba
FROM dbo.FactAsistencia_ETL AS f
CROSS JOIN (SELECT TOP (50) object_id FROM sys.all_objects ORDER BY object_id) AS n;

SELECT COUNT_BIG(*) AS Total_Registros FROM #EXP_BI03_Prueba;
SELECT COUNT(*) AS Total_Indices
FROM tempdb.sys.indexes
WHERE object_id=OBJECT_ID('tempdb..#EXP_BI03_Prueba') AND index_id > 0;

CREATE TABLE #EXP_BI03_Resultados (
    Tipo_Prueba VARCHAR(20) NOT NULL,
    Prueba INT NOT NULL,
    Fecha_Buscada DATE NOT NULL,
    Registros_Encontrados BIGINT NOT NULL,
    Tiempo_ms DECIMAL(12,3) NOT NULL
);

DECLARE @Fecha DATE, @Prueba INT, @Inicio DATETIME2(7),
        @Total BIGINT, @Tiempo DECIMAL(12,3);

-- Selección fija de la fecha menos frecuente para ambas condiciones.
SELECT TOP (1) @Fecha = CAST(fecha AS DATE)
FROM #EXP_BI03_Prueba
WHERE fecha IS NOT NULL
GROUP BY CAST(fecha AS DATE)
ORDER BY COUNT_BIG(*) ASC, CAST(fecha AS DATE);
IF @Fecha IS NULL THROW 51011, 'No se encontró una fecha para las pruebas.', 1;

-- 2. CINCO búsquedas SIN índice; una búsqueda de calentamiento fuera de medición.
SELECT @Total = COUNT_BIG(*)
FROM #EXP_BI03_Prueba
WHERE fecha >= @Fecha AND fecha < DATEADD(DAY,1,@Fecha);
SET @Prueba=1;
WHILE @Prueba<=5
BEGIN
    SET @Inicio=SYSDATETIME();
    SELECT @Total=COUNT_BIG(*)
    FROM #EXP_BI03_Prueba
    WHERE fecha >= @Fecha AND fecha < DATEADD(DAY,1,@Fecha);
    SET @Tiempo=DATEDIFF_BIG(MICROSECOND,@Inicio,SYSDATETIME())/1000.0;
    INSERT INTO #EXP_BI03_Resultados
        (Tipo_Prueba,Prueba,Fecha_Buscada,Registros_Encontrados,Tiempo_ms)
    VALUES ('Sin indice',@Prueba,@Fecha,@Total,@Tiempo);
    SET @Prueba+=1;
END;

-- 3. Crear únicamente el índice de la tabla temporal.
CREATE NONCLUSTERED INDEX IX_EXP_BI03_Fecha
ON #EXP_BI03_Prueba(fecha);

-- Mismo predicado y misma fecha, con un calentamiento inicial.
SELECT @Total = COUNT_BIG(*)
FROM #EXP_BI03_Prueba
WHERE fecha >= @Fecha AND fecha < DATEADD(DAY,1,@Fecha);
SET @Prueba=1;
WHILE @Prueba<=5
BEGIN
    SET @Inicio=SYSDATETIME();
    SELECT @Total=COUNT_BIG(*)
    FROM #EXP_BI03_Prueba
    WHERE fecha >= @Fecha AND fecha < DATEADD(DAY,1,@Fecha);
    SET @Tiempo=DATEDIFF_BIG(MICROSECOND,@Inicio,SYSDATETIME())/1000.0;
    INSERT INTO #EXP_BI03_Resultados
        (Tipo_Prueba,Prueba,Fecha_Buscada,Registros_Encontrados,Tiempo_ms)
    VALUES ('Con indice',@Prueba,@Fecha,@Total,@Tiempo);
    SET @Prueba+=1;
END;

-- 4. Comparar las diez observaciones y los promedios.
SELECT * FROM #EXP_BI03_Resultados ORDER BY Tipo_Prueba DESC, Prueba;
SELECT Tipo_Prueba, COUNT(*) AS Total_Pruebas,
       CAST(AVG(Tiempo_ms) AS DECIMAL(12,3)) AS Promedio_ms,
       MIN(Tiempo_ms) AS Minimo_ms, MAX(Tiempo_ms) AS Maximo_ms
FROM #EXP_BI03_Resultados GROUP BY Tipo_Prueba;

;WITH promedio AS (
   SELECT Tipo_Prueba, AVG(Tiempo_ms) AS Promedio_ms
   FROM #EXP_BI03_Resultados GROUP BY Tipo_Prueba
)
SELECT a.Promedio_ms AS Tiempo_Sin_Indice_ms,
       b.Promedio_ms AS Tiempo_Con_Indice_ms,
       CAST(100.0*(a.Promedio_ms-b.Promedio_ms)/NULLIF(a.Promedio_ms,0)
            AS DECIMAL(10,2)) AS Reduccion_Tiempo_Porcentual
FROM promedio a CROSS JOIN promedio b
WHERE a.Tipo_Prueba='Sin indice' AND b.Tipo_Prueba='Con indice';
/*
 Capturas registradas el 28/11/2026: 355550 filas, fecha 2026-01-31,
 300 filas encontradas, 5 pruebas por configuración.
 Sin índice (ms): 25.092; 25.327; 23.139; 24.306; 23.852. Promedio: 24.343.
 Con índice: mínimo reportado 0.000 ms; máximo 1.036 ms; promedio 0.207 ms.
 Reducción relativa reportada: 99.15 %.
 Los resultados de una repetición futura pueden variar. Valores 0.000 son
 resoluciones insuficientes de medición, no búsquedas literalmente instantáneas.
*/
