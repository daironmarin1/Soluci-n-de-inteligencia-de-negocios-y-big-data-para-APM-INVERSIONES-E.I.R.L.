
USE BI_APM_Inversiones;
GO

-- Crear esquema para las pruebas si no existe
IF SCHEMA_ID('exp_bi04') IS NULL
BEGIN
    EXEC('CREATE SCHEMA exp_bi04');
END;
GO

-- Crear las cinco tablas experimentales

IF OBJECT_ID('exp_bi04.Dim_Curso_Prueba', 'U') IS NULL
    CREATE TABLE exp_bi04.Dim_Curso_Prueba (
        ID INT NOT NULL PRIMARY KEY,
        Valor_Prueba INT NOT NULL DEFAULT 0
    );

IF OBJECT_ID('exp_bi04.Dim_Estado_Prueba', 'U') IS NULL
    CREATE TABLE exp_bi04.Dim_Estado_Prueba (
        ID INT NOT NULL PRIMARY KEY,
        Valor_Prueba INT NOT NULL DEFAULT 0
    );

IF OBJECT_ID('exp_bi04.Dim_Periodo_Prueba', 'U') IS NULL
    CREATE TABLE exp_bi04.Dim_Periodo_Prueba (
        ID INT NOT NULL PRIMARY KEY,
        Valor_Prueba INT NOT NULL DEFAULT 0
    );

IF OBJECT_ID('exp_bi04.Dim_Practicante_Prueba', 'U') IS NULL
    CREATE TABLE exp_bi04.Dim_Practicante_Prueba (
        ID INT NOT NULL PRIMARY KEY,
        Valor_Prueba INT NOT NULL DEFAULT 0
    );

IF OBJECT_ID('exp_bi04.Dim_Tiempo_Prueba', 'U') IS NULL
    CREATE TABLE exp_bi04.Dim_Tiempo_Prueba (
        ID INT NOT NULL PRIMARY KEY,
        Valor_Prueba INT NOT NULL DEFAULT 0
    );
