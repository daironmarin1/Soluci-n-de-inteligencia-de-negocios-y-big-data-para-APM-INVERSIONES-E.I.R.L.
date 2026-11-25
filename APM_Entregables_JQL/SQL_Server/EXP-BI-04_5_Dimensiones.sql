
USE BI_APM_Inversiones;
GO

-- Generar 20,000 identificadores de prueba
SELECT TOP (20000)
    CAST(ROW_NUMBER() OVER (
        ORDER BY a.object_id, b.object_id
    ) AS INT) AS ID
INTO #Numeros
FROM sys.all_objects a
CROSS JOIN sys.all_objects b;

-- Insertar registros en las 5 tablas
INSERT INTO exp_bi04.Dim_Curso_Prueba
SELECT ID, 0 FROM #Numeros
WHERE ID NOT IN (
    SELECT ID FROM exp_bi04.Dim_Curso_Prueba
);

INSERT INTO exp_bi04.Dim_Estado_Prueba
SELECT ID, 0 FROM #Numeros
WHERE ID NOT IN (
    SELECT ID FROM exp_bi04.Dim_Estado_Prueba
);

INSERT INTO exp_bi04.Dim_Periodo_Prueba
SELECT ID, 0 FROM #Numeros
WHERE ID NOT IN (
    SELECT ID FROM exp_bi04.Dim_Periodo_Prueba
);

INSERT INTO exp_bi04.Dim_Practicante_Prueba
SELECT ID, 0 FROM #Numeros
WHERE ID NOT IN (
    SELECT ID FROM exp_bi04.Dim_Practicante_Prueba
);

INSERT INTO exp_bi04.Dim_Tiempo_Prueba
SELECT ID, 0 FROM #Numeros
WHERE ID NOT IN (
    SELECT ID FROM exp_bi04.Dim_Tiempo_Prueba
);

-- Verificar cantidad de registros
SELECT 'Curso' AS Dimension, COUNT(*) AS Registros
FROM exp_bi04.Dim_Curso_Prueba
UNION ALL
SELECT 'Estado', COUNT(*)
FROM exp_bi04.Dim_Estado_Prueba
UNION ALL
SELECT 'Periodo', COUNT(*)
FROM exp_bi04.Dim_Periodo_Prueba
UNION ALL
SELECT 'Practicante', COUNT(*)
FROM exp_bi04.Dim_Practicante_Prueba
UNION ALL
SELECT 'Tiempo', COUNT(*)
FROM exp_bi04.Dim_Tiempo_Prueba;

DROP TABLE #Numeros;
