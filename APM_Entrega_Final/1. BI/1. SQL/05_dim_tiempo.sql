USE [ASISTENCIA]
GO

/****** Objeto: Table [dbo].[DimTiempo] Fecha de script: 26/11/2026 20:49:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DimTiempo](
	[fecha] [date] NOT NULL,
	[anio] [int] NOT NULL,
	[mes] [int] NOT NULL,
	[nombre_mes] [nvarchar](20) NOT NULL,
	[trimestre] [int] NOT NULL,
	[dia] [int] NOT NULL,
	[dia_semana] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


