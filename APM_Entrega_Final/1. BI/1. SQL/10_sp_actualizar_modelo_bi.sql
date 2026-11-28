USE [ASISTENCIA]
GO

/****** Objeto: StoredProcedure [dbo].[sp_Actualizar_Modelo_BI] Fecha de script: 26/11/2026 20:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[sp_Actualizar_Modelo_BI]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        -- ==========================================
        -- 1. ACTUALIZAR DIMENSION CALIDAD
        -- ==========================================

        UPDATE D
        SET D.descripcion = V.descripcion
        FROM dbo.DimCalidadRegistro AS D
        INNER JOIN
        (
            VALUES
            ('COMPLETO', 'Registro con ambas horas'),
            ('REVISAR_HORARIO', 'Registro con horario inconsistente'),
            ('SIN_AMBAS_HORAS', 'Registro sin entrada ni salida'),
            ('SIN_HORA_ENTRADA', 'Registro sin hora de entrada'),
            ('SIN_HORA_SALIDA', 'Registro sin hora de salida')
        ) AS V(calidad_datos, descripcion)
            ON D.calidad_datos = V.calidad_datos;

        INSERT INTO dbo.DimCalidadRegistro
            (calidad_datos, descripcion)
        SELECT
            V.calidad_datos,
            V.descripcion
        FROM
        (
            VALUES
            ('COMPLETO', 'Registro con ambas horas'),
            ('REVISAR_HORARIO', 'Registro con horario inconsistente'),
            ('SIN_AMBAS_HORAS', 'Registro sin entrada ni salida'),
            ('SIN_HORA_ENTRADA', 'Registro sin hora de entrada'),
            ('SIN_HORA_SALIDA', 'Registro sin hora de salida')
        ) AS V(calidad_datos, descripcion)
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.DimCalidadRegistro AS D
            WHERE D.calidad_datos = V.calidad_datos
        );

        -- ==========================================
        -- 2. ACTUALIZAR DIMENSION PRACTICANTE
        -- ==========================================

        UPDATE D
        SET
            D.nombre_completo = P.nombre_completo,
            D.convenio = P.convenio,
            D.semestre = P.semestre,
            D.rol = P.rol,
            D.sede = P.sede,
            D.carrera = P.carrera,
            D.estado = P.estado,
            D.fecha_inscripcion = P.fecha_inscripcion,
            D.fecha_retiro = P.fecha_retiro
        FROM dbo.DimPracticante AS D
        INNER JOIN dbo.practicante AS P
            ON D.practicante_id = P.id;

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
            P.id,
            P.nombre_completo,
            P.convenio,
            P.semestre,
            P.rol,
            P.sede,
            P.carrera,
            P.estado,
            P.fecha_inscripcion,
            P.fecha_retiro
        FROM dbo.practicante AS P
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.DimPracticante AS D
            WHERE D.practicante_id = P.id
        );

        -- ==========================================
        -- 3. ACTUALIZAR DIMENSION ESTADO
        -- ==========================================

        UPDATE D
        SET D.categoria = S.categoria
        FROM dbo.DimEstado AS D
        INNER JOIN
        (
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
                END AS categoria
            FROM dbo.asistencia
        ) AS S
            ON D.estado = S.estado;

        INSERT INTO dbo.DimEstado
            (estado, categoria)
        SELECT
            S.estado,
            S.categoria
        FROM
        (
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
                END AS categoria
            FROM dbo.asistencia
        ) AS S
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.DimEstado AS D
            WHERE D.estado = S.estado
        );

        -- ==========================================
        -- 4. ACTUALIZAR DIMENSION TIEMPO
        -- ==========================================

        UPDATE D
        SET
            D.anio = YEAR(F.fecha),
            D.mes = MONTH(F.fecha),
            D.nombre_mes = DATENAME(MONTH, F.fecha),
            D.trimestre = DATEPART(QUARTER, F.fecha),
            D.dia = DAY(F.fecha),
            D.dia_semana =
                (DATEDIFF(DAY, '19000101', F.fecha) % 7 + 7) % 7 + 1
        FROM dbo.DimTiempo AS D
        INNER JOIN
        (
            SELECT DISTINCT fecha
            FROM dbo.asistencia
        ) AS F
            ON D.fecha = F.fecha;

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
        SELECT
            F.fecha,
            YEAR(F.fecha),
            MONTH(F.fecha),
            DATENAME(MONTH, F.fecha),
            DATEPART(QUARTER, F.fecha),
            DAY(F.fecha),
            (DATEDIFF(DAY, '19000101', F.fecha) % 7 + 7) % 7 + 1
        FROM
        (
            SELECT DISTINCT fecha
            FROM dbo.asistencia
        ) AS F
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.DimTiempo AS D
            WHERE D.fecha = F.fecha
        );

        -- ==========================================
        -- 5. EJECUTAR ETL DE ASISTENCIA
        -- ==========================================

        EXEC dbo.sp_Ejecutar_ETL_Asistencia_BI;

        -- ==========================================
        -- 6. VALIDAR RELACION DE CALIDAD
        -- ==========================================

        IF EXISTS
        (
            SELECT 1
            FROM dbo.FactAsistencia_ETL AS F
            LEFT JOIN dbo.DimCalidadRegistro AS D
                ON F.calidad_datos = D.calidad_datos
            WHERE D.calidad_datos IS NULL
        )
        BEGIN
            THROW 51001,
                'Existen registros de asistencia sin dimension de calidad.',
                1;
        END;

        -- ==========================================
        -- 7. CONFIRMAR TRANSACCION
        -- ==========================================

        COMMIT TRANSACTION;

        -- ==========================================
        -- 8. MOSTRAR RESULTADOS
        -- ==========================================

        SELECT
            'Modelo BI actualizado correctamente' AS resultado,
            (SELECT COUNT_BIG(*)
             FROM dbo.FactAsistencia_ETL) AS total_hechos,

            (SELECT COUNT(*)
             FROM dbo.DimPracticante) AS total_practicantes,

            (SELECT COUNT(*)
             FROM dbo.DimTiempo) AS total_fechas,

            (SELECT COUNT(*)
             FROM dbo.DimEstado) AS total_estados,

            (SELECT COUNT(*)
             FROM dbo.DimCalidadRegistro) AS total_calidades,

            SYSDATETIME() AS fecha_actualizacion;

    END TRY
    BEGIN CATCH

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH;
END;

GO


