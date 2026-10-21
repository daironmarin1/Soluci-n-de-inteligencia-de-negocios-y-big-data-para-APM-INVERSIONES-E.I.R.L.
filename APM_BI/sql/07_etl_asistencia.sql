USE [ASISTENCIA_BI_DEMO]
GO

/****** Objeto: StoredProcedure [dbo].[sp_Ejecutar_ETL_Asistencia_BI] Fecha de script: 21/10/2026 12:56:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[sp_Ejecutar_ETL_Asistencia_BI]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Recarga completa de la tabla de destino del ETL.
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
            fecha_carga
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
                WHEN a.hora_entrada IS NULL
                  OR a.hora_salida IS NULL
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
                    DATEADD(
                        DAY,
                        1,
                        CAST(a.hora_salida AS DATETIME2)
                    )
                )
            END,

            CASE
                WHEN a.hora_entrada IS NULL
                 AND a.hora_salida IS NULL
                    THEN 'SIN_AMBAS_HORAS'

                WHEN a.hora_entrada IS NULL
                    THEN 'SIN_HORA_ENTRADA'

                WHEN a.hora_salida IS NULL
                    THEN 'SIN_HORA_SALIDA'

                WHEN a.hora_salida < a.hora_entrada
                    THEN 'REVISAR_HORARIO'

                ELSE 'COMPLETO'
            END,

            SYSDATETIME()

        FROM dbo.asistencia AS a
        LEFT JOIN dbo.practicante AS p
            ON p.id = a.practicante_id;

        DECLARE @registros_cargados BIGINT =
            (SELECT COUNT_BIG(*)
             FROM dbo.FactAsistencia_ETL);

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

