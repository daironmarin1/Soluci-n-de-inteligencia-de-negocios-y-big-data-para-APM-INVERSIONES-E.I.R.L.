USE [ASISTENCIA_BI_DEMO]
GO

/****** Objeto: StoredProcedure [dbo].[sp_Actualizar_Modelo_BI] Fecha de script: 21/10/2026 12:58:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[sp_Actualizar_Modelo_BI]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        EXEC dbo.sp_Ejecutar_ETL_Asistencia_BI;

        BEGIN TRANSACTION;

        DELETE FROM dbo.DimPracticante;

        INSERT INTO dbo.DimPracticante
        (
            practicante_id,
            nombre_completo,
            convenio,
            semestre,
            rol,
            sede,
            carrera,
            estado,
            fecha_inscripcion,
            fecha_retiro
        )
        SELECT
            id,
            nombre_completo,
            convenio,
            semestre,
            rol,
            sede,
            carrera,
            estado,
            fecha_inscripcion,
            fecha_retiro
        FROM dbo.practicante;

        DELETE FROM dbo.DimEstado;

        INSERT INTO dbo.DimEstado
        (
            estado,
            categoria
        )
        SELECT DISTINCT
            estado,
            CASE
                WHEN estado IN
                    ('temprano', 'tarde', 'sobreHora')
                    THEN 'Asistencia registrada'
                WHEN estado = 'falto'
                    THEN 'Falta'
                WHEN estado = 'clases'
                    THEN 'Clases'
                WHEN estado = 'vacaciones'
                    THEN 'Vacaciones'
                WHEN estado = 'justificado'
                    THEN 'Justificado'
                ELSE 'Otro'
            END
        FROM dbo.asistencia;

        DELETE FROM dbo.DimTiempo;

        INSERT INTO dbo.DimTiempo
        (
            fecha,
            anio,
            mes,
            nombre_mes,
            trimestre,
            dia,
            dia_semana
        )
        SELECT DISTINCT
            fecha,
            YEAR(fecha),
            MONTH(fecha),
            DATENAME(MONTH, fecha),
            DATEPART(QUARTER, fecha),
            DAY(fecha),
            (
                DATEDIFF(DAY, '19000101', fecha) % 7 + 7
            ) % 7 + 1
        FROM dbo.asistencia;

        COMMIT TRANSACTION;

        SELECT
            'Modelo BI actualizado' AS resultado,
            SYSDATETIME() AS fecha_actualizacion;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO

