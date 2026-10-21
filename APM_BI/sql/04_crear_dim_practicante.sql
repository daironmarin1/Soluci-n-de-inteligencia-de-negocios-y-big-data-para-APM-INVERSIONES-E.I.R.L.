USE [ASISTENCIA_BI_DEMO]
GO

/****** Objeto: Table [dbo].[DimPracticante] Fecha de script: 21/10/2026 13:03:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DimPracticante](
	[practicante_id] [int] NOT NULL,
	[nombre_completo] [nvarchar](255) NOT NULL,
	[convenio] [nvarchar](20) NULL,
	[semestre] [smallint] NULL,
	[rol] [nvarchar](50) NULL,
	[sede] [nvarchar](100) NULL,
	[carrera] [nvarchar](150) NULL,
	[estado] [nvarchar](255) NULL,
	[fecha_inscripcion] [date] NULL,
	[fecha_retiro] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[practicante_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

