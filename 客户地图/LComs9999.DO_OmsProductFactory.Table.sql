USE [cwbaseoms]
GO
/****** Object:  Table [LComs9999].[DO_OmsProductFactory]    Script Date: 01/22/2018 16:22:52 ******/
DROP TABLE [DO_OmsProductFactory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [DO_OmsProductFactory](
	[ID] [varchar](36) NOT NULL,
	[Code] [varchar](36) NULL,
	[Name] [varchar](36) NULL,
	[Creator] [varchar](128) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifier] [varchar](128) NULL,
	[LastModifiedDate] [datetime] NULL,
 CONSTRAINT [DO_OmsProductFactory_PRIMARYKEY] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
