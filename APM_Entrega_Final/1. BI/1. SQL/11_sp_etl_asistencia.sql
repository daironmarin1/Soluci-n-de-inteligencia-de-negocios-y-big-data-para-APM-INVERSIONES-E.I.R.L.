USE [ASISTENCIA];
GO

-- Versión documentada según el procedimiento comprobado por el equipo
-- el 27/11/2026 en SQL Server Express, con DimModalidadRegistro.
-- IMPORTANTE: recarga por completo dbo.FactAsistencia_ETL.
CREATE OR ALTER PROCEDURE dbo.sp_Ejecutar_ETL_Asistencia_BI
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM dbo.FactAsistencia_ETL;

        INSERT INTO dbo.FactAsistencia_ETL
        (
            asistencia_id,
            practicante_id,
            nombre_practicante,
            estado,
            fecha,
            hora_entrada,
            hora_salida,
            salida_auto,
            dispositivo,
            duracion_segundos,
            calidad_datos,
            fecha_carga,
            id_modalidad
        )
        SELECT
            a.id,
            a.practicante_id,
            p.nombre_completo,
            a.estado,
            a.fecha,
            a.hora_entrada,
            a.hora_salida,
            a.salida_auto,
            a.dispositivo,
            CASE
                WHEN a.hora_entrada IS NULL OR a.hora_salida IS NULL
                    THEN NULL
                WHEN a.hora_salida >= a.hora_entrada
                    THEN DATEDIFF_BIG(
                        SECOND,
                        CAST(a.hora_entrada AS DATETIME2),
                        CAST(a.hora_salida AS DATETIME2)
                    )
                ELSE DATEDIFF_BIG(
                    SECOND,
                    CAST(a.hora_entrada AS DATETIME2),
                    DATEADD(DAY, 1, CAST(a.hora_salida AS DATETIME2))
                )
            END,
            CASE
                WHEN a.hora_entrada IS NULL AND a.hora_salida IS NULL
                    THEN 'SIN_AMBAS_HORAS'
                WHEN a.hora_entrada IS NULL
                    THEN 'SIN_HORA_ENTRADA'
                WHEN a.hora_salida IS NULL
                    THEN 'SIN_HORA_SALIDA'
                WHEN a.hora_salida < a.hora_entrada
                    THEN 'REVISAR_HORARIO'
                ELSE 'COMPLETO'
            END,
            SYSDATETIME(),
            m.id_modalidad
        FROM dbo.asistencia AS a
        LEFT JOIN dbo.practicante AS p
            ON p.id = a.practicante_id
        LEFT JOIN dbo.DimModalidadRegistro AS m
            ON a.salida_auto = m.salida_auto
            OR (a.salida_auto IS NULL AND m.salida_auto IS NULL);

        IF EXISTS
        (
            SELECT 1
            FROM dbo.FactAsistencia_ETL
            WHERE id_modalidad IS NULL
        )
        BEGIN
            THROW 51002, 'Existen registros sin modalidad asignada.', 1;
        END;

        DECLARE @registros_cargados BIGINT =
            (SELECT COUNT_BIG(*) FROM dbo.FactAsistencia_ETL);

        COMMIT TRANSACTION;

        SELECT
            'Carga ETL completada' AS resultado,
            @registros_cargados AS registros_cargados,
            SYSDATETIME() AS fecha_ejecucion;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
