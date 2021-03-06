USE [omsprod]
GO
/****** Object:  Table [DO_OmsCustomer]    Script Date: 01/22/2018 16:05:50 ******/
DROP TABLE [DO_OmsCustomer]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [DO_OmsCustomer](
	[ID] [varchar](36) NOT NULL,
	[Code] [varchar](100) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Description] [varchar](200) NULL,
	[State] [char](1) NULL,
	[SourceType] [varchar](36) NULL,
	[SourceID] [varchar](36) NULL,
	[Creator] [varchar](128) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifier] [varchar](128) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsNamed] [int] NULL,
	[IsNew] [int] NULL,
	[CustomerManager] [varchar](36) NULL,
	[City] [varchar](36) NULL,
 CONSTRAINT [DO_OmsCustomer_PRIMARYKEY] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
