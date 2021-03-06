USE [cwbaseoms]
GO
/****** Object:  StoredProcedure [LComs9999].[SP_OmsPALBaoXiaoDataCollect]    Script Date: 01/19/2018 15:26:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [LComs9999].[SP_OmsPALBaoXiaoDataCollect]

AS
BEGIN

	SET NOCOUNT ON;
	
	insert into DO_OmsPALBaoXiaoCollect (ID,Creator,CreatedDate,LastModifier,LastModifiedDate,CLF,YWF,ProjectID)
	select
	newid(),'OMS',getdate(),'OMS',getdate(),
    sum(case when ROFYXM_ZJM='51010000100002' then JE else 0 end) as CLF,
    sum(case when ROFYXM_ZJM='51010000100006' then JE else 0 end) as YWF,
    XMID
	from DO_PALBaoXiaoSource  where XmID not in(select ProjectID from DO_OmsPALBaoXiaoCollect) group by XMID
	
	--select *from DO_OmsPALBaoXiaoCollect
	--delete from DO_OmsPALBaoXiaoCollect

END
