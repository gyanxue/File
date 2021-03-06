USE [omsprod]
GO
/****** Object:  Table [DO_OmsCustomerCategory]    Script Date: 01/22/2018 16:05:51 ******/
DROP TABLE [DO_OmsCustomerCategory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [DO_OmsCustomerCategory](
	[ID] [varchar](36) NOT NULL,
	[Code] [varchar](36) NOT NULL,
	[Name] [varchar](36) NULL,
	[Creator] [varchar](128) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifier] [varchar](128) NULL,
	[LastModifiedDate] [datetime] NULL,
 CONSTRAINT [DO_OmsCustomerCategory_PRIMARYKEY] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
