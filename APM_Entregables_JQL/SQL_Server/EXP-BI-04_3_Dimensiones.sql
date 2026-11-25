
USE BI_APM_Inversiones;
GO

SET NOCOUNT ON;

DECLARE @i INT = 1;
DECLARE @inicio DATETIME2(7);
DECLARE @fin DATETIME2(7);
DECLARE @filas INT;

DECLARE @Resultados TABLE (
    Prueba INT,
    Filas_Actualizadas INT,
    Tiempo_ms DECIMAL(18,3)
);

WHILE @i <= 5
BEGIN
    SET @filas = 0;

    BEGIN TRANSACTION;

    SET @inicio = SYSDATETIME();

    UPDATE exp_bi04.Dim_Curso_Prueba
    SET Valor_Prueba = Valor_Prueba + 1;
    SET @filas = @filas + @@ROWCOUNT;

    UPDATE exp_bi04.Dim_Estado_Prueba
    SET Valor_Prueba = Valor_Prueba + 1;
    SET @filas = @filas + @@ROWCOUNT;

    UPDATE exp_bi04.Dim_Periodo_Prueba
    SET Valor_Prueba = Valor_Prueba + 1;
    SET @filas = @filas + @@ROWCOUNT;

    SET @fin = SYSDATETIME();

    ROLLBACK TRANSACTION;

    INSERT INTO @Resultados
    VALUES (
        @i,
        @filas,
        DATEDIFF_BIG(MICROSECOND, @inicio, @fin) / 1000.0
    );

    SET @i = @i + 1;
END;

SELECT
    Prueba,
    Filas_Actualizadas,
    Tiempo_ms,
    CAST(AVG(Tiempo_ms) OVER()
        AS DECIMAL(18,3)) AS Promedio_ms
FROM @Resultados
ORDER BY Prueba;
