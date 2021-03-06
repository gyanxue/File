USE [cwbaseoms]
GO
/****** Object:  StoredProcedure [LComs9999].[SP_OmsPALDataCollectOneProject]    Script Date: 01/19/2018 15:26:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [LComs9999].[SP_OmsPALDataCollectOneProject]
@pro varchar(36)=''
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
    		  PRINT('INSERT')
  			if not exists (select * from DO_OmsPALDataCollect where ProjectID=@pro)
				begin
    				insert into DO_OmsPALDataCollect (ID,Creator,CreatedDate,LastModifier,LastModifiedDate,
					HK,HTE_HS,HTE_BHS,DL,CG,WB,CB_BHS,HTML,FJS,MUQG,JSFY,JSSQFYFT,CLF,YWF,FTFY,QDRQ,JZYS,YJYS,SJYS,JZGQ,YJGQ,SJGQ,YJGZL,JHWCD,SJWCD,WCDPC,SJGZL,ProjectID) 
					select 
					newid(),'OMS',getdate(),'OMS',getdate(), 
					cont.HKJE,--回款
					cont.ContractAmount,--合同额_含税
					cont.ContractNetAmount,--合同额_不含税 
					cast( pal.CBHS*cont.HKJE/cont.ContractAmount as decimal(18,2)),--成本_含税
					cast( pal.HBFC*cont.HKJE/cont.ContractAmount as decimal(18,2)),--代理
					cast( pal.CGCB*cont.HKJE/cont.ContractAmount as decimal(18,2)),--采购
					cast( pal.WB*cont.HKJE/cont.ContractAmount as decimal(18,2)),--外包
	 
					cast(pal.CBBHS*cont.HKJE/cont.ContractAmount as decimal(18,2)),--成本_不含税
					pal.HTML,--合同毛利
					cast( pal.FJS*cont.HKJE/cont.ContractAmount as decimal(18,2)),--附加税
					cast( pal.MUQG*cont.HKJE/cont.ContractAmount as decimal(18,2)),--MU切割
					(wri.SYRTCB+wrcd.SYRTCB+wro.SYRTCB)*+cast( pal.JSFY*cont.HKJE/cont.ContractAmount as decimal(18,2)),--结算费用
					(wrp.SYRTCB)+cast( ys.YSFTFY*cont.HKJE/cont.ContractAmount as decimal(18,2)),--结算售前费用分摊
					bx.CLF,--差旅费
					bx.YWF,--业务费
				    cast( ys.YSFTFY*cont.HKJE/cont.ContractAmount as decimal(18,2)),--分摊费用
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
					wri.SYGZL+wrcd.SYGZL,--实际工作量  
                    @pro 
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
					left join #tempWorkLogImplement  wri on wri.ProjectID =pro.ID
					--开发人工成本
					left join #tempWorkLogCustomerDevelepment  wrcd on wrcd.ProjectID =pro.ID
					--运维人工成本
					left join #tempWorkLogOperation wro on wro.ProjectID =pro.ID
					where pro.ID=@pro
				end
			else
				begin
				   PRINT('update')
					update  DO_OmsPALDataCollect set
					HK=cont.HKJE,--回款
					HTE_HS=cont.ContractAmount,--合同额_含税
					HTE_BHS= cont.ContractNetAmount,--合同额_不含税 
					CB_HS =cast(pal.CBHS*cont.HKJE/cont.ContractAmount as decimal(18,2)),--成本_不含税
					DL= cast( pal.HBFC*cont.HKJE/cont.ContractAmount as decimal(18,2)),--代理
					CG= cast( pal.CGCB*cont.HKJE/cont.ContractAmount as decimal(18,2)),--采购
					WB=	cast( pal.WB*cont.HKJE/cont.ContractAmount as decimal(18,2)),--外包
					CB_BHS= cast(pal.CBBHS*cont.HKJE/cont.ContractAmount as decimal(18,2)),--成本_不含税
					HTML=pal.HTML,--合同毛利
					FJS= cast( pal.FJS*cont.HKJE/cont.ContractAmount as decimal(18,2)),--附加税
					MUQG= cast( pal.MUQG*cont.HKJE/cont.ContractAmount as decimal(18,2)),--MU切割
					JSFY=(wri.SYRTCB+wrcd.SYRTCB)*+cast( pal.JSFY*cont.HKJE/cont.ContractAmount as decimal(18,2)),--结算费用
					JSSQFYFT= (wrp.SYRTCB)+cast( ys.YSFTFY*cont.HKJE/cont.ContractAmount as decimal(18,2)),--结算售前费用分摊
					CLF= bx.CLF,--差旅费
					YWF= bx.YWF,--业务费
					FTFY= cast( ys.YSFTFY*cont.HKJE/cont.ContractAmount as decimal(18,2)),--分摊费用
					QDRQ= pdc.QDRQ,--启动日期
					JZYS= pdc.JZYS,--基准验收
					YJYS= pdc.YJYS,--预计验收
					SJYS= pdc.SJYS,--实际验收
					JZGQ= datediff(d,pdc.QDRQ,pdc.JZYS),--基准工期
					YJGQ=	datediff(d,pdc.QDRQ,pdc.YJYS),---预计工期
					SJGQ= case when pdc.SJYS is not null then datediff(d,pdc.QDRQ,pdc.SJYS) else null end,--实际工期
					YJGZL= ys.YSGZL,--预算工作量
					JHWCD= ys.DQQYWCGZL/ys.YSGZL,--计划完工度
					SJWCD= pdc.SJWCD,--实际完工度
					WCDPC= ys.DQQYWCGZL/ys.YSGZL- pdc.SJWCD,--完工度偏差
					SJGZL= wri.SYGZL+wrcd.SYGZL--实际工作量  
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
					left join #tempWorkLogImplement  wri on wri.ProjectID =pro.ID
					--开发人工成本
					left join #tempWorkLogCustomerDevelepment  wrcd on wrcd.ProjectID =pro.ID
					where pro.ID=@pro
				end	
		PRINT('二次计算')
			update  DO_OmsPALDataCollect set
			XMFY= FJS+MUQG+MUQG+JSFY,
			BJLR= HTML-(FJS+MUQG+MUQG+JSFY),
			JLR=  HTML-(FJS+MUQG+MUQG+JSFY)-FTFY,
			SJGQPC= case when pdc.SJYS is not null then cast(datediff(d,pdc.SJYS,pdc.QDRQ)/JZGQ as decimal(6,1)) else null end,--实际工期偏差
			YJGQPC= cast(datediff(d,pdc.YJYS,pdc.QDRQ)/JZGQ as decimal(6,1))--预计工期偏差
			from DO_OmsPALDataCollect data 
			left join DO_OmsPALPDCCollect pdc on pdc.ProjectID =data.ProjectID
      	where data.ProjectID=@pro

END


