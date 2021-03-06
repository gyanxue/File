USE [omsprod]
GO

DROP TABLE [DO_OmsCRMCustomerMapping]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [DO_OmsCRMCustomerMapping](
	[ID] [varchar](36) NOT NULL,
	[Creator] [varchar](128) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifier] [varchar](128) NULL,
	[LastModifiedDate] [datetime] NULL,
	[OmsID] [varchar](36) NOT NULL,
	[CrmID] [varchar](36) NULL,
 CONSTRAINT [DO_OmsCRMCustomerMapping_PRIMARYKEY] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
