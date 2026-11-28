# Automatización ETL por Programador de tareas de Windows

Archivo: `ejecutar_etl.bat` (copia del script probado en el equipo).

**Entorno probado:** Windows, SQL Server Express de instancia predeterminada,
servidor `localhost`, base de datos `ASISTENCIA`, autenticación integrada `-E`,
herramienta `sqlcmd` disponible.

Procedimiento: `EXEC dbo.sp_Ejecutar_ETL_Asistencia_BI;`.
Frecuencia configurada: diariamente a las 17:00.
Nombre de la tarea: `APM_ETL_Diario`.

## Configuración efectuada en el equipo

1. Guardar el BAT en `C:\Users\PC\APM_ETL\ejecutar_etl.bat`.
2. Crear carpeta `C:\Users\PC\APM_ETL\logs` (el BAT deja el archivo
   `ejecuciones.log` en esa carpeta).
3. Crear tarea básica `APM_ETL_Diario`, desencadenador diario a las 17:00,
   acción «Iniciar un programa», ruta del BAT.
4. Configurar ejecución solo con usuario con sesión iniciada; si se necesita
   ejecución desatendida debe configurarse de forma específica con permisos.
5. En Condiciones, no exigir corriente alterna. En Configuración, activar
   «Permitir que la tarea se ejecute a petición» y, si se desea, «Ejecutar
   tarea lo antes posible si no hubo inicio programado».
6. Habilitar historial de todas las tareas para auditar eventos.

## Evidencias

En `../3. Evidencias BI/11. Automatizacion ETL/`:
- `01_ETL_Log_3_Ejecuciones_Exitosas.png`: CMD con tres cargas de 7111 filas.
- `02_ETL_Historial_Windows_Evento_102.png`: historial de Windows de la tarea.
- `03_ETL_Tarea_Diaria_Configurada.png`: tarea «Listo» con desencadenador 17:00.
- `04_ETL_Prueba_Manual_7111.png`: prueba previa desde PowerShell.

En `logs/ejecuciones_evidencia_2026-11-27.log` se transcribió el texto exacto
que el usuario compartió tras ejecutar `type ...\ejecuciones.log`.
El log original vivo permanece solo en `C:\Users\PC\APM_ETL\logs`.

No ejecutar esta automatización simultáneamente con recargas manuales ni
apuntar a una instancia distinta sin confirmar los datos y respaldarlos.
