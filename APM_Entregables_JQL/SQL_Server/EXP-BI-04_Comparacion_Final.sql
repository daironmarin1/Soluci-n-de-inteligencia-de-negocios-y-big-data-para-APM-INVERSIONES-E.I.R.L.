
USE BI_APM_Inversiones;
GO

WITH Mediciones AS (
    SELECT '3 dimensiones' AS Escenario,
           Tiempo_ms
    FROM (VALUES
        (111.514),
        (77.673),
        (87.748),
        (71.252),
        (75.340)
    ) AS A(Tiempo_ms)

    UNION ALL

    SELECT '5 dimensiones',
           Tiempo_ms
    FROM (VALUES
        (151.722),
        (125.005),
        (118.890),
        (150.053),
        (113.638)
    ) AS B(Tiempo_ms)
),
Promedios AS (
    SELECT
        Escenario,
        AVG(Tiempo_ms) AS Promedio
    FROM Mediciones
    GROUP BY Escenario
)
SELECT
    CAST(A.Promedio AS DECIMAL(12,3))
        AS Promedio_3_Dimensiones_ms,

    CAST(B.Promedio AS DECIMAL(12,3))
        AS Promedio_5_Dimensiones_ms,

    CAST(B.Promedio - A.Promedio AS DECIMAL(12,3))
        AS Diferencia_ms,

    CAST(
        (B.Promedio - A.Promedio)
        / A.Promedio * 100
        AS DECIMAL(10,2)
    ) AS Incremento_Porcentaje

FROM Promedios A
CROSS JOIN Promedios B
WHERE A.Escenario = '3 dimensiones'
  AND B.Escenario = '5 dimensiones';
