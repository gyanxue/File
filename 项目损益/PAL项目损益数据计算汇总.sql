USE [cwbaseoms]
GO
/****** Object:  StoredProcedure [LComs9999].[SP_OmsPALDataCollect]    Script Date: 01/19/2018 14:47:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [LComs9999].[SP_OmsPALDataCollect]
AS
BEGIN
	--BEGIN TRAN
	--BEGIN TRY 
        print('工时统计表临时表')
		--售前
        select * into #tempWorkLogPresaler from Do_OmsPALWorkLogCollect where Stage='c9603451-d861-21f8-e4bc-4a629ebd40cb'
        --实施
        select * into #tempWorkLogImplement from Do_OmsPALWorkLogCollect where Stage='b709b005-a6e9-4ebd-af40-0dd232abc669'
        --客开
        select * into #tempWorkLogCustomerDevelepment from Do_OmsPALWorkLogCollect where Stage='32773975-0e5b-c6f7-876f-551e0cee9007'
        --运维
        select * into #tempWorkLogOperation from Do_OmsPALWorkLogCollect where Stage='abd284e5-57a6-db7e-26cd-68d44f0711c8'
        
        print('报价数据按项目合并临时表')
        
        select sum([CBHS]) as CBHS,sum([FJS]) as FJS,sum([WB]) as WB,sum([ZJZY]) as ZJZY,sum([CGCB]) as CGCB,sum([JSFY]) as JSFY,sum([HBFC]) as HBFC,
        sum([MUQG]) as MUQG,sum([HTML]) as HTML,sum([HTEBHS]) as HTEBHS,sum([CBBHS]) as CBBHS,sum([XMFY]) as XMFY,[ProjectID]
	    into #tempProfitLoss 
	    from DO_OmsPALBaoJiaCollect group by ProjectID
       
        PRINT('初步计算')
        
		declare @project varchar(36)
		declare @HK decimal(18,2)
		declare @HTE_HS decimal(18,2)
		declare @HTE_BHS decimal(18,2)
		declare @DL decimal(18,2)
		declare @CG decimal(18,2)
		declare @WB decimal(18,2)
		declare @CB_HS decimal(18,2)
		declare @CB_BHS decimal(18,2)
		declare @HTML decimal(18,2)
		declare @FJS decimal(18,2)
		declare @MUQG decimal(18,2)
		declare @JSFY decimal(18,2)
		declare @JSSQFYFT decimal(18,2)
		declare @CLF decimal(18,2)
		declare @YWF decimal(18,2)
		declare @FTFY decimal(18,2)
		declare @QDRQ dateTime
		declare @JZYS dateTime
		declare @YJYS dateTime
		declare @SJYS dateTime
		declare @JZGQ int
		declare @YJGQ int
		declare @SJGQ int
		declare @YJGQPC decimal(18,2)
		declare @YJGZL decimal(18,2)
		declare @JHWCD decimal(18,2)
		declare @SJWCD decimal(18,2)
		declare @WCDPC decimal(18,2)
		declare @SJGZL decimal(18,2)
 
		declare y_curr cursor for --申明游标
			select  pro.ID,--项目ID
					cont.HKJE,--回款
					cont.ContractAmount,--合同额_含税
					cont.ContractNetAmount,--合同额_不含税 
					cast( pal.CBHS*cont.HKJE/cont.ContractAmount as decimal(18,2)),--成本_含税
					cast( pal.HBFC*cont.HKJE/cont.ContractAmount as decimal(18,2)),--代理
					cast( pal.CGCB*cont.HKJE/cont.ContractAmount as decimal(18,2)),--采购
					cast( pal.WB*cont.HKJE/cont.ContractAmount as decimal(18,2)),--外包
					
					cast(cont.ContractNetAmount*cont.HKJE/cont.ContractAmount as decimal(18,2)),--成本_不含税
					pal.HTML,--合同毛利
					cast( pal.FJS*cont.HKJE/cont.ContractAmount as decimal(18,2)),--附加税
					cast( pal.MUQG*cont.HKJE/cont.ContractAmount as decimal(18,2)),--MU切割
					(wri.SYRTCB+wrcd.SYRTCB+wro.SYRTCB)*+cast( pal.JSFY*cont.HKJE/cont.ContractAmount as decimal(18,2)),--结算费用
					(wrp.SYRTCB)+cast( ys.YSFTFY*cont.HKJE/cont.ContractAmount as decimal(18,2)),--结算售前费用
					bx.CLF,--差旅费
					bx.YWF,--业务费
				    cast( ys.YSFTFY*cont.HKJE/cont.ContractAmount as decimal(18,2)),--分摊费用
					--净利润
					pdc.QDRQ,--启动日期
					pdc.JZYS,--基准验收
					pdc.YJYS,--预计验收
					pdc.SJYS,--实际验收
					datediff(d,pdc.QDRQ,pdc.JZYS),--基准工期
					datediff(d,pdc.QDRQ,pdc.YJYS),---预计工期
					case when pdc.SJYS is not null then datediff(d,pdc.QDRQ,pdc.SJYS) else null end,--实际工期
					ys.YSGZL,--预算工作量
					ys.DQQYWCGZL/ys.YSGZL,--计划完工度
					pdc.SJWCD,--实际完工度
					ys.DQQYWCGZL/ys.YSGZL- pdc.SJWCD,--完工度偏差
					wri.SYGZL+wrcd.SYGZL+wro.SYGZL--实际工作量       
					from DO_OmsProject pro 
					--损益数据集合
					left join #tempProfitLoss pal on pal.ProjectID = pro.ID 
					--盈亏预估数据
					left join DO_OmsProfitLoss opl on opl.ContactID=pro.Contract
					--合同归档数据
					left join DO_OmsContractinfoGD  cont  on cont.ID=opl.ContactID
					--报销系统数据
					left join DO_OmsPALBaoXiaoCollect bx on bx.ProjectID = pro.ID
					--合同预算数据
					left join DO_OmsPALYuSuanCollect ys on ys.ProjectID = pro.ID 
					--PDC系统数据
					left join DO_OmsPALPDCCollect pdc on pdc.ProjectID =pro.ID
					--售前人工成本
					left join #tempWorkLogPresaler  wrp on wrp.ProjectID =pro.ID
					--实施人工成本
                    left join #tempWorkLogImplement wri on wri.ProjectID =pro.ID
                    --开发人工成本
                    left join #tempWorkLogCustomerDevelepment  wrcd on wrcd.ProjectID =pro.ID
                    --运维人工成本
                    left join #tempWorkLogOperation wro on wro.ProjectID =pro.ID
		open y_curr --打开游标
		fetch next from y_curr into @project 
		,@HK,@HTE_HS,@HTE_BHS,@DL,@CG,@WB,@CB_HS,@CB_BHS,@HTML,@FJS,@MUQG,@JSFY,@JSSQFYFT,@CLF,@YWF,@FTFY,@QDRQ,@JZYS,@YJYS,@SJYS,@JZGQ,@YJGQ,@SJGQ,@YJGZL,@JHWCD,@SJWCD,@WCDPC,@SJGZL -- 开始循环游标变量----开始循环游标变量
		while(@@fetch_status=0)---返回被 FETCH  语句执行的最后游标的状态，而不是任何当前被连接打开的游标的状态。
		begin
			
			if not exists (select * from DO_OmsPALDataCollect where ProjectID=@project)
				begin
			        --PRINT('insert')
					insert into DO_OmsPALDataCollect (ID,Creator,CreatedDate,LastModifier,LastModifiedDate,
					HK,HTE_HS,HTE_BHS,DL,CG,WB,CB_BHS,HTML,FJS,MUQG,JSFY,JSSQFYFT,CLF,YWF,FTFY,QDRQ,JZYS,YJYS,SJYS,JZGQ,YJGQ,SJGQ,YJGZL,JHWCD,SJWCD,WCDPC,SJGZL,ProjectID) 
					values
					(newid(),'OMS',getdate(),'OMS',getdate(),
					@HK,@HTE_HS,@HTE_BHS,
					@DL,@CG,@WB,@CB_BHS,@HTML,
					@FJS,@MUQG,@JSFY,@JSSQFYFT,@CLF,@YWF,
					@FTFY,
					@QDRQ,@JZYS,@YJYS,@SJYS,@JZGQ,@YJGQ,@SJGQ,
					@YJGZL,@JHWCD,@SJWCD,@WCDPC,@SJGZL,@project
					)
				end
			else
				begin
				   --PRINT('update')
					update  DO_OmsPALDataCollect set
					HK=@HK,--回款
					HTE_HS= @HTE_HS,--合同额_含税
					HTE_BHS= @HTE_BHS,--同额_不含税 
					DL= @DL,--代理
					CG= @CG,--采购
					WB= @WB,--外包
					CB_HS =@CB_HS,--成本_含税
					CB_BHS= @CB_BHS,--成本_不含税
					HTML= @HTML,--合同毛利
					FJS= @FJS,--附加税
					MUQG= @MUQG,--MU切割
					JSFY= @JSFY ,--结算费用
					JSSQFYFT= @JSSQFYFT,--结算售前费用分摊
					CLF= @CLF,--差旅费
					YWF= @YWF,--业务费
					FTFY= @FTFY,--分摊费用
					QDRQ= @QDRQ,--启动日期
					JZYS= @JZYS,--基准验收
					YJYS= @YJYS,--预计验收
					SJYS= @SJYS,--实际验收
					JZGQ= @JZGQ,--基准工期
					YJGQ= @YJGQ,---预计工期
					SJGQ= @SJGQ,--实际工期
					YJGZL= @YJGZL,--预算工作量
					JHWCD= @JHWCD,--计划完工度
					SJWCD= @SJWCD,--实际完工度
					WCDPC= @WCDPC,--完工度偏差
					SJGZL= @SJGZL--实际工作量 
					where ProjectID=@project
				end

		fetch next from y_curr into @project ,
		@HK,@HTE_HS,@HTE_BHS,@DL,@CG,@WB,@CB_HS,@CB_BHS,@HTML,@FJS,@MUQG,@JSFY,@JSSQFYFT,@CLF,@YWF,@FTFY,@QDRQ,@JZYS,@YJYS,@SJYS,@JZGQ,@YJGQ,@SJGQ,@YJGZL,@JHWCD,@SJWCD,@WCDPC,@SJGZL -- 开始循环游标变量
		end
		close y_curr--关闭游标
		deallocate y_curr --释放游标
		
		PRINT('二次计算')
			update  DO_OmsPALDataCollect set
			--CB_HS=DL+CG+WB,
			XMFY= FJS+MUQG+MUQG+JSFY,
			BJLR= HTML-(FJS+MUQG+MUQG+JSFY),
			JLR=  HTML-(FJS+MUQG+MUQG+JSFY)-FTFY,
			SJGQPC= case when pdc.SJYS is not null then cast(datediff(d,pdc.SJYS,pdc.QDRQ)/JZGQ as decimal(6,1)) else null end,--实际工期偏差
			YJGQPC= cast(datediff(d,pdc.YJYS,pdc.QDRQ)/JZGQ as decimal(6,1))--预计工期偏差
			from DO_OmsPALDataCollect data 
			left join DO_OmsPALPDCCollect pdc on pdc.ProjectID =data.ProjectID
--	  COMMIT TRAN 
--	END TRY 

--BEGIN CATCH 
--  RAISERROR ('Error?raised?in?TRY?block.',10,1); --0~10??
--   ROLLBACK TRAN 
--END CATCH 
--PRINT 'Owner DONE'
END


