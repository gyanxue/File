USE [omsprod]
GO
/****** Object:  Table [DO_OmsCustomerMap]    Script Date: 01/22/2018 16:05:52 ******/
DROP TABLE [DO_OmsCustomerMap]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [DO_OmsCustomerMap](
	[ID] [varchar](36) NOT NULL,
	[MU] [varchar](36) NULL,
	[SASAClevel] [int] NULL,
	[SASAC] [varchar](36) NULL,
	[Customer] [varchar](36) NULL,
	[BusinessClasses] [int] NULL,
	[BU] [varchar](36) NULL,
	[NewOROld] [int] NULL,
	[IsNamed] [int] NULL,
	[CustomerManager] [varchar](36) NULL,
	[Creator] [varchar](128) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifier] [varchar](128) NULL,
	[LastModifiedDate] [datetime] NULL,
	[Parent] [varchar](36) NULL,
	[Layer] [int] NULL,
	[IsDetail] [char](1) NULL,
	[XH] [int] NULL,
	[CustomerCategory] [varchar](36) NULL,
	[CuestomerName] [varchar](36) NULL,
 CONSTRAINT [DO_OmsCustomerMap_PRIMARYKEY] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO