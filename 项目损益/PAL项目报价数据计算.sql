USE [cwbaseoms]
GO
/****** Object:  StoredProcedure [LComs9999].[SP_OmsPALBaoJiaDataCollect]    Script Date: 01/19/2018 15:25:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [LComs9999].[SP_OmsPALBaoJiaDataCollect] 

AS
BEGIN
	SET NOCOUNT ON;
	
	
	select 
      sum([CBHS]) as CBHS,sum([FJS]) as FJS,sum([WB]) as WB,sum([ZJZY]) as ZJZY,sum([CGCB]) as CGCB,sum([JSFY]) as JSFY,sum([HBFC]) as HBFC,
      sum([MUQG]) as MUQG,sum([HTML]) as HTML,sum([HTEBHS]) as HTEBHS,sum([CBBHS]) as CBBHS,sum([XMFY]) as XMFY,[ProjectID]
	into #tempTable from DO_OmsPALBaoJiaCollect group by ProjectID
	update DO_OmsPALDataCollect set 
	CB_HS=tmp.CBHS,
	FJS=tmp.FJS,
	WB=tmp.WB,
	ZJZY=tmp.ZJZY,
	CG=tmp.CGCB,
	DL=tmp.HBFC,
	MUQG=tmp.MUQG,
	HTML=tmp.HTML,
	HTE_BHS=tmp.HTEBHS,
	CB_BHS=tmp.CBBHS,
	XMFY=tmp.XMFY													
	from DO_OmsPALDataCollect data left join #tempTable tmp  on data.ProjectID=tmp.ProjectID
END
