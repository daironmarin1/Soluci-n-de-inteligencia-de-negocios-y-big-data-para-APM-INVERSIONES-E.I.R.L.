USE [ASISTENCIA_BI_DEMO]
GO

/****** Objeto: Table [dbo].[practicante] Fecha de script: 21/10/2026 13:08:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[practicante](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[id_discord] [bigint] NOT NULL,
	[nombre_completo] [nvarchar](255) NOT NULL,
	[correo] [nvarchar](255) NULL,
	[clase_lunes] [bit] NULL,
	[clase_martes] [bit] NULL,
	[clase_miercoles] [bit] NULL,
	[clase_jueves] [bit] NULL,
	[clase_viernes] [bit] NULL,
	[clase_sabado] [bit] NULL,
	[convenio] [nvarchar](20) NULL,
	[semestre] [smallint] NULL,
	[rol] [nvarchar](50) NULL,
	[fecha_inscripcion] [date] NULL,
	[matriculado] [bit] NULL,
	[dni] [nvarchar](15) NULL,
	[numero] [nvarchar](20) NULL,
	[sede] [nvarchar](100) NULL,
	[carrera] [nvarchar](150) NULL,
	[usuario_github] [nvarchar](100) NULL,
	[usuario_discord] [nvarchar](100) NULL,
	[estado] [nvarchar](255) NULL,
	[fecha_retiro] [date] NULL,
	[motivo_retiro] [nvarchar](255) NULL,
	[baneos] [int] NULL,
	[horas_base] [nvarchar](50) NULL,
	[created_by] [nvarchar](255) NULL,
	[updated_at] [datetime2](6) NULL,
	[updated_by] [nvarchar](255) NULL,
	[created_at] [datetime2](6) NOT NULL,
	[correo_institucional] [nvarchar](255) NULL,
	[servidor] [nvarchar](20) NULL,
 CONSTRAINT [practicante_pkey] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [practicante_id_discord_key] UNIQUE NONCLUSTERED 
(
	[id_discord] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[practicante] ADD  DEFAULT ((0)) FOR [clase_lunes]
GO

ALTER TABLE [dbo].[practicante] ADD  DEFAULT ((0)) FOR [clase_martes]
GO

ALTER TABLE [dbo].[practicante] ADD  DEFAULT ((0)) FOR [clase_miercoles]
GO

ALTER TABLE [dbo].[practicante] ADD  DEFAULT ((0)) FOR [clase_jueves]
GO

ALTER TABLE [dbo].[practicante] ADD  DEFAULT ((0)) FOR [clase_viernes]
GO

ALTER TABLE [dbo].[practicante] ADD  DEFAULT ((0)) FOR [clase_sabado]
GO

ALTER TABLE [dbo].[practicante] ADD  DEFAULT ('no') FOR [convenio]
GO

ALTER TABLE [dbo].[practicante] ADD  DEFAULT (CONVERT([date],getdate())) FOR [fecha_inscripcion]
GO

ALTER TABLE [dbo].[practicante] ADD  DEFAULT ((0)) FOR [matriculado]
GO

ALTER TABLE [dbo].[practicante] ADD  DEFAULT ('activo') FOR [estado]
GO

ALTER TABLE [dbo].[practicante] ADD  DEFAULT ((0)) FOR [baneos]
GO

ALTER TABLE [dbo].[practicante] ADD  DEFAULT ('00:00:00') FOR [horas_base]
GO

ALTER TABLE [dbo].[practicante] ADD  DEFAULT (sysdatetime()) FOR [created_at]
GO

