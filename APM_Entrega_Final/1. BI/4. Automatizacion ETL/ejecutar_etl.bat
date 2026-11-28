@echo off
setlocal

set "LOG=%~dp0logs\ejecuciones.log"

echo ======================================== >> "%LOG%"
echo Inicio ETL: %date% %time% >> "%LOG%"

sqlcmd -S "localhost" -E -C -d "ASISTENCIA" -b -r 1 -l 15 -Q "EXEC dbo.sp_Ejecutar_ETL_Asistencia_BI;" >> "%LOG%" 2>&1

if errorlevel 1 (
    echo ERROR ETL: %date% %time% >> "%LOG%"
    exit /b 1
)

echo EXITO ETL: %date% %time% >> "%LOG%"
exit /b 0
