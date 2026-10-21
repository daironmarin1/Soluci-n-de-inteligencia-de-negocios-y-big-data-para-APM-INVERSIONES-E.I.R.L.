USE [ASISTENCIA_BI_DEMO]
GO

/****** Objeto: Table [dbo].[FactAsistencia_ETL] Fecha de script: 21/10/2026 13:00:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[FactAsistencia_ETL](
	[asistencia_id] [int] NOT NULL,
	[practicante_id] [int] NOT NULL,
	[nombre_practicante] [nvarchar](255) NULL,
	[estado] [nvarchar](20) NOT NULL,
	[fecha] [date] NOT NULL,
	[hora_entrada] [time](7) NULL,
	[hora_salida] [time](7) NULL,
	[salida_auto] [bit] NULL,
	[dispositivo] [nvarchar](10) NULL,
	[duracion_segundos] [bigint] NULL,
	[calidad_datos] [nvarchar](40) NOT NULL,
	[fecha_carga] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[asistencia_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[FactAsistencia_ETL] ADD  CONSTRAINT [DF_FactAsistencia_ETL_fecha_carga]  DEFAULT (sysdatetime()) FOR [fecha_carga]
GO

