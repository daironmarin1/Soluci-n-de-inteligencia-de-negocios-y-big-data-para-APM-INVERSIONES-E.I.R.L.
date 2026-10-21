USE [ASISTENCIA_BI_DEMO]
GO

/****** Objeto: Table [dbo].[asistencia] Fecha de script: 21/10/2026 13:07:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[asistencia](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[practicante_id] [int] NOT NULL,
	[estado] [nvarchar](20) NOT NULL,
	[fecha] [date] NOT NULL,
	[hora_entrada] [time](7) NULL,
	[hora_salida] [time](7) NULL,
	[salida_auto] [bit] NULL,
	[dispositivo] [nvarchar](10) NULL,
 CONSTRAINT [asistencia_pkey] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [asistencia_practicante_id_fecha_key] UNIQUE NONCLUSTERED 
(
	[practicante_id] ASC,
	[fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [ukpwbwowyaiit33m6a4sr2j1gcv] UNIQUE NONCLUSTERED 
(
	[practicante_id] ASC,
	[fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[asistencia] ADD  DEFAULT ((0)) FOR [salida_auto]
GO

ALTER TABLE [dbo].[asistencia]  WITH CHECK ADD  CONSTRAINT [asistencia_practicante_id_fkey] FOREIGN KEY([practicante_id])
REFERENCES [dbo].[practicante] ([id])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[asistencia] CHECK CONSTRAINT [asistencia_practicante_id_fkey]
GO

