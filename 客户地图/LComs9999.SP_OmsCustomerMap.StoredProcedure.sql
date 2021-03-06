USE [omsprod]
GO
/****** Object:  StoredProcedure [SP_OmsCustomerMap]    Script Date: 01/22/2018 16:06:53 ******/
DROP PROCEDURE [SP_OmsCustomerMap]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SP_OmsCustomerMap]

AS
BEGIN

print('计算主表统计数据')
select 
mu.Name as mucm, --MU
Count(SASAClevel) as 'SJGZW' ,
SUM(case when NewOROld=1 then 0 else 1 end) as 'Old',
SUM(case when IsNamed=1 then 1 else 0 end) as 'CRMIsNamed',
SUM(case when IsNamed=1 then 1 else 0 end)/Count(SASAClevel) as 'IsNamdCover' 
into #TempCustomerMap
from DO_OmsCustomerMap cm 
left join DO_OmsMU mu on cm.MU=mu.ID 
group by mu.Name,SASAClevel 
union all
select 
'合计',
Count(SASAClevel),
SUM(case when NewOROld=1 then 0 else 1 end) ,
SUM(case when IsNamed=1 then 1 else 0 end),
SUM(case when IsNamed=1 then 1 else 0 end)/Count(SASAClevel)
from DO_OmsCustomerMap cm 
left join DO_OmsMU mu on cm.MU=mu.ID 
--select *from  #TempCustomerMap
--drop table #TempCustomerMap

print('计算子表统计数据')
select 
mu.Name as MUPB, --MU
isnull(pt.Name,'')+'_'+isnull(pf_cp.Name ,'') as FullName,
COUNT(isnull(mu.Name,'')+isnull(pt.Name,'')+isnull(pf_cp.Name,'')) as Val
into #TempProductBusiness
from DO_OmsProductBusiness pb 
left join DO_OmsCustomerMap cm on pb.CustomerID=cm.ID 
left join DO_OmsMU mu on cm.MU=mu.ID 
left join DO_OmsProductFactory  pf_cp on pb.SoftFactory=pf_cp.ID --产品厂家
left join DO_OmsProductType pt on pb.ProductType =pt.ID
left join DO_OmsProductFactory  pf_zx on pb.SoftFactory=pf_zx.ID --咨询厂家
where  mu.Name is not null and pt.Name is not null and (pf_cp.Name is not null OR pf_zx.Name is not null)
group by mu.Name,pt.Name,pf_cp.Name

--select *from  #TempProductBusiness
--drop table #TempProductBusiness
print('行列转换')
declare @s varchar(3000)
declare @sql varchar(3000)
if exists(select * from tempdb..sysobjects where id=object_id('tempdb..##MidTable'))
 drop table ##MidTable
select @s=  ISNULL(@s + ',', '') + QUOTENAME(Name) from (select distinct(pb.FullName) Name from #TempProductBusiness pb where pb.FullName is not null ) as con
set @sql='select TBL.* into ##MidTable from(select * from #TempProductBusiness ) as temp  
PIVOT
(
	sum(temp.Val) for temp.FullName in('+@s+')
)TBL '
exec(@sql)

print('合计')
if exists(select * from tempdb..sysobjects where id=object_id('tempdb..##BeforeResult'))
 drop table ##BeforeResult
declare @count varchar(3000)
declare @test varchar(3000)
set @count=''
select @count=@count+',sum('+name+') as '+name from tempdb..syscolumns where id=object_id('tempdb..##MidTable') and name not in('MUPB') order by colid     --写不要汇总的列名
set @test='select * into ##BeforeResult from ##MidTable union all select ''合计'''+@count+' from ##MidTable'
exec(@test)

print('查询')

declare @result varchar(3000)
set @result='select * from #TempCustomerMap tcm left join ##BeforeResult br on br.MUPB=tcm.mucm' 
exec(@result)

END
GO
