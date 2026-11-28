USE [ASISTENCIA]
GO

/****** Objeto: Table [dbo].[DimModalidadRegistro] Fecha de script: 26/11/2026 20:50:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DimModalidadRegistro](
	[id_modalidad] [int] IDENTITY(1,1) NOT NULL,
	[salida_auto] [bit] NULL,
	[codigo_modalidad] [varchar](30) NOT NULL,
	[descripcion_modalidad] [varchar](120) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_modalidad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[codigo_modalidad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


