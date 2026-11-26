USE ASISTENCIA_PRUEBA;
GO


CREATE TABLE dbo.DimModalidadRegistro (
    id_modalidad INT IDENTITY(1,1) PRIMARY KEY,
    salida_auto BIT NULL,
    codigo_modalidad VARCHAR(30) NOT NULL UNIQUE,
    descripcion_modalidad VARCHAR(120) NOT NULL
);
GO

INSERT INTO dbo.DimModalidadRegistro (salida_auto, codigo_modalidad, descripcion_modalidad)
SELECT DISTINCT 
    salida_auto,
    CASE 
        WHEN salida_auto = 1 THEN 'CIERRE_AUTOMATICO'
        WHEN salida_auto = 0 THEN 'CIERRE_MANUAL'
        ELSE 'SIN_MARCA_CIERRE'
    END,
    CASE 
        WHEN salida_auto = 1 THEN 'Salida cerrada automáticamente por el sistema'
        WHEN salida_auto = 0 THEN 'Salida registrada de forma manual'
        ELSE 'Registro sin indicador de cierre definido'
    END
FROM dbo.asistencia;
GO

SELECT * FROM dbo.DimModalidadRegistro;
