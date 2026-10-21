USE [ASISTENCIA_BI_DEMO];
GO
-- Datos completamente inventados. Ejecutar SOLO en la base de demostración.
IF DB_NAME() <> N'ASISTENCIA_BI_DEMO' THROW 51000, 'Base de datos incorrecta', 1;
IF EXISTS (SELECT 1 FROM dbo.practicante) OR EXISTS (SELECT 1 FROM dbo.asistencia)
    THROW 51001, 'La demostración ya contiene datos; no volver a insertar', 1;
INSERT INTO dbo.practicante (id_discord, nombre_completo, convenio, semestre, rol, sede, carrera, estado)
VALUES
(900000000001, N'Practicante Demo Uno', N'no', 5, N'Practicante', N'Sede Demo', N'Sistemas', N'activo'),
(900000000002, N'Practicante Demo Dos', N'no', 6, N'Practicante', N'Sede Demo', N'Sistemas', N'activo'),
(900000000003, N'Practicante Demo Tres', N'no', 7, N'Practicante', N'Sede Demo', N'Sistemas', N'activo');
DECLARE @p1 int=(SELECT id FROM dbo.practicante WHERE id_discord=900000000001);
DECLARE @p2 int=(SELECT id FROM dbo.practicante WHERE id_discord=900000000002);
DECLARE @p3 int=(SELECT id FROM dbo.practicante WHERE id_discord=900000000003);
INSERT INTO dbo.asistencia (practicante_id, estado, fecha, hora_entrada, hora_salida, salida_auto, dispositivo)
VALUES
(@p1,N'temprano','2026-10-01','08:00','12:00',0,N'web'),
(@p2,N'tarde','2026-10-01','08:25','12:00',0,N'web'),
(@p3,N'falto','2026-10-01',NULL,NULL,0,NULL),
(@p1,N'clases','2026-10-02',NULL,NULL,0,NULL),
(@p2,N'justificado','2026-10-02',NULL,NULL,0,NULL),
(@p3,N'vacaciones','2026-10-02',NULL,NULL,0,NULL),
(@p1,N'sobreHora','2026-10-03','08:00','15:30',0,N'web'),
(@p2,N'temprano','2026-10-03','08:00',NULL,0,N'web'),
(@p3,N'tarde','2026-10-03',NULL,'12:00',0,N'web'),
(@p1,N'temprano','2026-10-04','23:00','01:00',0,N'web');
GO
