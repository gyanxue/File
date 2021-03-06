USE [cwbaseoms]
GO
/****** Object:  StoredProcedure [LComs9999].[SP_OmsProjectEmployeeMHForCost]    Script Date: 01/19/2018 15:10:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [LComs9999].[SP_OmsProjectEmployeeMHForCost]
    --@StartDate date = '',
    --@EndDate date = '',
    --@ProjectDepartment varchar(max)='',
    --@ProjectCategory varchar(max)='',
    --@ProjectState varchar(max)='',
    --@EmployeeDepartment varchar(max)='',
    --@Project varchar(36)='',
    --@ProjectOwner varchar(36)='',
    --@ProjectStage varchar(36)='',
    --@Employee varchar(36)='',
    --@Superior varchar(36)=''
AS
BEGIN

    --IF @StartDate = '' or @StartDate = '0001-01-01T00:00:00+08:00' or @StartDate < '2017-10-01'
    --    set @StartDate = '2017-10-01'
        
    --IF @EndDate = '' or @EndDate = '0001-01-01T00:00:00+08:00'
    --    set @EndDate = getdate()
        
    print '项目字典临时表'
    create table #Temp_ProjectDict (
        ID varchar(36)
    )

    insert into #Temp_ProjectDict exec SP_OmsProjectDict '', '', '', '', '', ''
    print '员工字典临时表'
    create table #Temp_EmployeeDict (
        ID varchar(36)
    )

    insert into #Temp_EmployeeDict exec SP_OmsEmployeeDictGS '', '', '', '', '', ''

    select proj.ID Project,
    stageRec.Stage Stage,
    sum(cast((case when wl.WorkHour>8 then 8 else wl.WorkHour end)/8 as decimal(6,1))) WorkHour8h, 
    sum(cast(WorkHour/8 as decimal(6,1))) WorkHour,
    sum(cast((case when wl.WorkHour>8 then 8 else wl.WorkHour end)/8 as decimal(6,1))*eplp.UnitPricePerDay) MH8H, 
    sum(cast(wl.WorkHour/8 as decimal(6,1)) * eplp.UnitPricePerDay)  MH,
    min(wl.WorkDate) StartWorkDate, max(wl.WorkDate) EndWorkDate
    into #Temp_Result 
    from #Temp_ProjectDict proj 
    left join DO_OmsWorklog wl on wl.project = proj.id
    left join #Temp_EmployeeDict emp on emp.id = wl.employee
	right join DO_OmsEmployeePositionRecord epr on wl.employee=epr.Employee
    left join DO_OmsPositionLevel epl on epl.ID= epr.PositionLevel --岗位级别
    left join DO_OmsPositionLevelPrice eplp on eplp.PositionLevel= epr.PositionLevel  --级别价格 
    left join DO_OmsProjectStageRecord stageRec on stageRec.id = wl.ProjectStageRecord
    where (wl.ProcessState = '2' or wl.ProcessState = '3') and wl.WorkDate >= '2017-10-01' and wl.WorkDate <= getdate()
    --and (stageRec.Stage = 'b709b005-a6e9-4ebd-af40-0dd232abc669' or stageRec.Stage = '32773975-0e5b-c6f7-876f-551e0cee9007')
    group by proj.ID,stageRec.Stage--,epr.PositionLevel ,epr.PositionLevelPrice,epl.Name,epl.PositionLevel


 --   insert into DO_OmsPALWorkLogCollect (ID,ProjectID,Stage,BHJBGZL,SYGZL,BHJBRTCB,SYRTCB)
 --       select cast(newid() as varchar(36)) ,r.Project ,r.Stage, r.WorkHour8h ,r.WorkHour ,r.MH8h ,r.MH
 --   from #Temp_Result r left join DO_OmsPALWorkLogCollect wlc on r.Project=wlc.ProjectID
 --   where r.Project+(case  when isnull(r.Stage) then '' else r.Stage end) not in (select ProjectID+(case  when isnull(Stage) then '' else Stage end) from DO_OmsPALWorkLogCollect)
    
	--Update  DO_OmsPALWorkLogCollect 
 --   set  BHJBGZL=r.WorkHour8h,SYGZL=r.WorkHour ,BHJBRTCB=r.MH8h ,SYRTCB=r.MH
	--from #Temp_Result r left join DO_OmsPALWorkLogCollect wlc on r.Project=wlc.ProjectID
	--where  ProjectID+(case when isnull(wlc.Stage) then '' else wlc.Stage end)=r.Project+(case  when isnull(r.Stage) then '' else r.Stage end
	
	 print('工时统计表转换')

    declare @project varchar(36)

    declare @Stage varchar(36)
    declare @WorkHour8h decimal(18,2)
    declare @WorkHour decimal(18,2)
    declare @MH8h decimal(18,2)
    declare @MH decimal(18,2)


    PRINT('初步计算')
    declare y_curr cursor for --申明游标
        select r.Project ,r.Stage, r.WorkHour8h ,r.WorkHour ,r.MH8h ,r.MH from #Temp_Result r 
    open y_curr --打开游标
    fetch next from y_curr into @project ,@Stage,@WorkHour8h,@WorkHour,@MH8h,@MH
    while(@@fetch_status=0)---返回被 FETCH  语句执行的最后游标的状态，而不是任何当前被连接打开的游标的状态。
    begin
        
        if not exists (select * from DO_OmsPALWorkLogCollect where ProjectID+isnull(Stage,'')=@Project+isnull(@Stage,''))
            begin
                PRINT('insert')
                insert into DO_OmsPALWorkLogCollect (ID,Creator,CreatedDate,LastModifier,LastModifiedDate,ProjectID,Stage,BHJBGZL,SYGZL,BHJBRTCB,SYRTCB)
                values(newid(),'OMS',getdate(),'OMS',getdate(), @project,@Stage,@WorkHour8h,@WorkHour,@MH8h,@MH)
            end
        else
            begin
                PRINT('update')
                update  DO_OmsPALWorkLogCollect set
                BHJBGZL=@WorkHour8h,
                SYGZL= @WorkHour,
                BHJBRTCB=@MH8h,
                SYRTCB=@MH
                where ProjectID+isnull(Stage,'')=@Project+isnull(@Stage,'')
            end

    fetch next from y_curr into @project,@Stage,@WorkHour8h,@WorkHour,@MH8h,@MH
     end
    close y_curr--关闭游标
    deallocate y_curr --释放游标


END


