USE [omsprod]
GO
/****** Object:  StoredProcedure [SP_OmsCustomerMapDisplay]    Script Date: 01/22/2018 16:06:53 ******/
DROP PROCEDURE [SP_OmsCustomerMapDisplay]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SP_OmsCustomerMapDisplay]

AS
BEGIN

--select 
--mu.Name as MU, --MU
--SUM(case when SASAClevel=2 then 1 else 0 end) as  SJGZW,
--SUM(case when NewOROld=1 then 0 else 1 end) as Old,
--SUM(case when IsNamed=1 then 1 else 0 end) as CRMIsNamed,
--SUM(case when IsNamed=1 then 1 else 0 end)/Count(SASAClevel) as IsNamedCover 
--into #TempCustomerMap
--from DO_OmsCustomerMap cm 
--left join DO_OmsMU mu on cm.MU=mu.ID 
--group by mu.Name,SASAClevel 

----select *from  #TempCustomerMap
----drop table #TempCustomerMap
--SELECT MU,'A基本信息' as Category,
--case P.Item when 'SJGZW' then '客户机构名称' when 'Old' then '老客户' when 'CRMIsNamed' then 'CRM指名客户' when 'IsNamedCover' then '指名客户覆盖率' else p.Item end as Item,
--convert(decimal(10,2),P.Val) as Val into #TempResult
--FROM 
--(
--    SELECT MU,SJGZW, Old, CRMIsNamed, IsNamedCover 
--     FROM #TempCustomerMap
--)T
--UNPIVOT 
--(
--    Val FOR Item IN
--    (SJGZW, Old, CRMIsNamed, IsNamedCover )
--) P

select 
mu.Name as MU, --MU
cm.SASAC as '所有制',
cu.Name as '客户',
isnull(pt.Name,'') as '产品类别',
pf_cp.Name '厂商'
--case when isnull(pf_cp.Name ,'') in('SAP','Oracle','金蝶','浪潮','自主研发','用友') then isnull(pf_cp.Name ,'') else '未知' end  as Factory,
--isnull(pt.Name,'')+'_'+isnull(pf_cp.Name ,'') as FullName,
--into #TempProductBusiness
from DO_OmsProductBusiness pb 
left join DO_OmsCustomerMap cm on pb.CustomerID=cm.ID 
left join DO_OmsMU mu on cm.MU=mu.ID 
left join DO_OmsProductFactory  pf_cp on pb.Factory=pf_cp.ID --产品厂家
left join DO_OmsProductLists pt on pb.Product =pt.ID
left join DO_OmsCustomer cu on  cu.ID=cm.Customer
where  mu.Name is not null and pt.Name is not null and pf_cp.Name is not null
group by mu.Name,cm.SASAC,pt.Name,pf_cp.Name,cu.Name
--select * from  #TempResult union all select *from #TempProductBusiness 
END
GO
