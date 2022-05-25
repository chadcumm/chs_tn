/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Chad Cummings
	Date Written:
	Solution:
	Source file name:	cov_imo_add_dx_audit.prg
	Object name:		cov_imo_add_dx_audit
	Request #:
 
	Program purpose:
 
	Executing from:		CCL
 
 	Special Notes:		Called by ccl program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	08/12/2021  Chad Cummings			Initial Release
******************************************************************************/
 
drop program cov_imo_add_dx_audit:dba go
create program cov_imo_add_dx_audit:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date and Time" = "SYSDATE"
	, "End Date and Time" = "SYSDATE"
 
with OUTDEV, START_DT_TM, END_DT_TM
 
 
call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))
 
if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif
 
call set_codevalues(null)
call check_ops(null)
 
;free set t_rec
record t_rec
(
	1 cnt			= i4
	1 prompts
	 2 outdev		= vc
	 2 start_dt_tm	= vc
	 2 end_dt_tm	= vc
	1 files
	 2 records_attachment		= vc
	1 dminfo
	 2 info_domain	= vc
	 2 info_name	= vc
	1 cons
	 2 run_dt_tm 	= dq8
	1 dates
	 2 start_dt_tm	= dq8
	 2 end_dt_tm	= dq8
	1 qual[*]
	 2 person_id	= f8
	 2 encntr_id	= f8
	 2 mrn			= vc
	 2 fin			= vc
	 2 name_full_formatted = vc
	 2 diag_cnt		= i2
	 2 diag_qual[*]
	  3 diagnosis_id = f8
)
 
;call addEmailLog("chad.cummings@covhlth.com")
 
set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
 
set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.start_dt_tm = $START_DT_TM
set t_rec->prompts.end_dt_tm = $END_DT_TM
 
set t_rec->dminfo.info_domain	= "COV_DEV_OPS"
set t_rec->dminfo.info_name		= concat(trim(cnvtupper(curprog)),":","start_dt_tm")
set t_rec->dates.start_dt_tm 	= get_dminfo_date(t_rec->dminfo.info_domain,t_rec->dminfo.info_name)
set t_rec->dates.end_dt_tm 		= cnvtdatetime(curdate,curtime3)
 
if (t_rec->dates.start_dt_tm = 0.0)
	call writeLog(build2("->No start date and time found, setting to go live date"))
	set t_rec->dates.start_dt_tm = cnvtdatetime(curdate,curtime3)
endif
 
set t_rec->cons.run_dt_tm 		= cnvtdatetime(curdate,curtime3)
 
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))
 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Diagnosis   *******************************************"))
 
select into "nl:"
from
	 diagnosis d
	,nomenclature n
	,dummyt d1
	,cmt_cross_map ccm
	,nomenclature n2
plan d
	where d.updt_dt_tm between cnvtdatetime(t_rec->dates.start_dt_tm) and cnvtdatetime(t_rec->dates.end_dt_tm)
join n	
	where n.nomenclature_id = d.originating_nomenclature_id
	and   n.active_ind = 1
	and   n.end_effective_dt_tm >= cnvtdatetime(sysdate)
	and   n.source_vocabulary_cd = value(uar_get_code_by("MEANING",400,"IMO"))
join d1
join ccm
	where ccm.concept_cki = n.concept_cki
	and   ccm.end_effective_dt_tm >= cnvtdatetime(sysdate)
	and   ccm.map_type_cd = value(uar_get_code_by("MEANING",29223,"IMO+ICD10CM"))
join n2
	where n2.concept_cki = ccm.target_concept_cki
	and   n2.active_ind = 1
	and   n2.end_effective_dt_tm >= cnvtdatetime(sysdate)
order by
	d.encntr_id
	,d.diagnosis_id
head report
	i = 0
head d.encntr_id
	t_rec->cnt += 1
	stat = alterlist(t_rec->qual,t_rec->cnt)
	t_rec->qual[t_rec->cnt].encntr_id = d.encntr_id
	t_rec->qual[t_rec->cnt].person_id = d.person_id 
 	i = 0
head d.diagnosis_id
	i += 1
	stat = alterlist(t_rec->qual[t_rec->cnt].diag_qual,i)
	t_rec->qual[t_rec->cnt].diag_qual[i].diagnosis_id = d.diagnosis_id
with nocounter
	
call writeLog(build2("* END   Finding Diagnosis   *******************************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

call get_mrn(null)
call get_fin(null) 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))
 
/*
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Creating Audit *************************************"))
	call writeAudit(build2(
							char(34),^ITEM^,char(34),char(44),
							char(34),^DESC^,char(34)
						))
for (i=1 to t_rec->cnt)
		call writeAudit(build2(
							char(34),t_rec->qual[i].a											,char(34),char(44),
							char(34),t_rec->qual[i].b											,char(34)
						))
 
endfor
call writeLog(build2("* END   Creating Audit *************************************"))
call writeLog(build2("************************************************************"))
*/
 
#exit_script
 
if (reply->status_data.status in("Z","S"))
	call writeLog(build2("* START Set Date Range ************************************"))
	call set_dminfo_date(t_rec->dminfo.info_domain,t_rec->dminfo.info_name,t_rec->dates.end_dt_tm)
	call writeLog(build2("* END Set Date Range ************************************v1"))
endif
;001 end
 
;call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
;execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"Extracts/HIM/","CP"
;execute cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->files.records_attachment)
 
 
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)
 
 
end
go
