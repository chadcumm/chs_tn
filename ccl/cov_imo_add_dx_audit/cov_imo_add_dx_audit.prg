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
	 2 outdev 		= vc
	1 dates
	 2 start_dt_tm	= dq8
	 2 end_dt_tm	= dq8
	1 qual[*]
	 2 person_id	= f8
	 2 encntr_id	= f8
	 2 mrn			= vc
	 2 fin			= vc
	 2 facility		= vc
	 2 unit			= vc
	 2 loc_facility_cd = f8
	 2 loc_unit_cd 	= f8
	 2 reg_dt_tm = dq8
	 2 disch_dt_tm = dq8
	 2 inpatient_admit_dt_tm = dq8
	 2 name_full_formatted = vc
	 2 diag_cnt		= i2
	 2 diag_qual[*]
	  3 diagnosis_id = f8
	  3 diagnosis_group = f8
	  3 orig_nomen_id = f8
	  3 nomen_id = f8
	  3 orig_source_string = vc
	  3 orig_identifier = vc
	  3 source_string = vc
	  3 identifier = vc
	  3 diag_display = vc
	  3 provider_id	= f8
	  3 responsible_provider = vc
	  3 diag_dt_tm = dq8
	  3 active_dt_tm = dq8
	  3 ccm_map_ind = f8
	  3 diag_priority = i4
)
 
;call addEmailLog("chad.cummings@covhlth.com")
 
set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
 
set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.start_dt_tm = $START_DT_TM
set t_rec->prompts.end_dt_tm = $END_DT_TM

if (program_log->run_from_ops = 1)
	set t_rec->dminfo.info_domain	= "COV_DEV_OPS"
	set t_rec->dminfo.info_name		= concat(trim(cnvtupper(curprog)),":","start_dt_tm")
	set t_rec->dates.start_dt_tm 	= get_dminfo_date(t_rec->dminfo.info_domain,t_rec->dminfo.info_name)
	set t_rec->dates.end_dt_tm 		= cnvtdatetime(curdate,curtime3)
else
	set t_rec->dates.start_dt_tm = cnvtdatetime(t_rec->prompts.start_dt_tm)
	set t_rec->dates.end_dt_tm	= cnvtdatetime(t_rec->prompts.end_dt_tm)
endif
	 
if (t_rec->dates.start_dt_tm = 0.0)
	call writeLog(build2("->No start date and time found, setting to go live date"))
	set t_rec->dates.start_dt_tm = cnvtdatetime(curdate,curtime3)
endif
 
set t_rec->cons.run_dt_tm 		= cnvtdatetime(curdate,curtime3)
set t_rec->cons.outdev 			= t_rec->prompts.outdev
 
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))
 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Diagnosis   *******************************************"))
 
select into "nl:"
from
	 diagnosis d
	,nomenclature n
	,dummyt d1
	,dummyt d2
	,dummyt d3
	,cmt_cross_map ccm
	,nomenclature n2
	,nomenclature n3
plan d
	where d.updt_dt_tm between cnvtdatetime(t_rec->dates.start_dt_tm) and cnvtdatetime(t_rec->dates.end_dt_tm)
	;where   d.person_id = 18866972.0
	;where d.encntr_id = 125475063.0
	and   d.end_effective_dt_tm >= cnvtdatetime(sysdate)
	and   d.active_ind = 1
	and   d.contributor_system_cd = value(uar_get_code_by("MEANING",89,"POWERCHART"))
join n3
	where n3.nomenclature_id = d.nomenclature_id
	and   n3.active_ind = 1
	and   n3.end_effective_dt_tm >= cnvtdatetime(sysdate)
join d1
join n	
	where n.nomenclature_id = d.originating_nomenclature_id
	and   n.active_ind = 1
	and   n.end_effective_dt_tm >= cnvtdatetime(sysdate)
	and   n.source_vocabulary_cd = value(uar_get_code_by("MEANING",400,"IMO"))
join d2
join ccm
	where ccm.concept_cki = n.concept_cki
	and   ccm.end_effective_dt_tm >= cnvtdatetime(sysdate)
	and   ccm.map_type_cd = value(uar_get_code_by("MEANING",29223,"IMO+ICD10CM"))
join d3
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
	t_rec->qual[t_rec->cnt].diag_qual[i].diagnosis_group = d.diagnosis_group
	t_rec->qual[t_rec->cnt].diag_qual[i].nomen_id = d.nomenclature_id
	t_rec->qual[t_rec->cnt].diag_qual[i].orig_nomen_id = d.originating_nomenclature_id
	
	t_rec->qual[t_rec->cnt].diag_qual[i].source_string = n3.source_string
	t_rec->qual[t_rec->cnt].diag_qual[i].identifier = n3.source_identifier
	t_rec->qual[t_rec->cnt].diag_qual[i].diag_display = d.diagnosis_display
	t_rec->qual[t_rec->cnt].diag_qual[i].diag_dt_tm = d.diag_dt_tm
	t_rec->qual[t_rec->cnt].diag_qual[i].active_dt_tm = d.active_status_dt_tm
	
	t_rec->qual[t_rec->cnt].diag_qual[i].orig_identifier = n.source_identifier
	t_rec->qual[t_rec->cnt].diag_qual[i].orig_source_string = n.source_string
	
	t_rec->qual[t_rec->cnt].diag_qual[i].responsible_provider = d.diag_prsnl_name
	t_rec->qual[t_rec->cnt].diag_qual[i].provider_id = d.diag_prsnl_id
	
	t_rec->qual[t_rec->cnt].diag_qual[i].ccm_map_ind = ccm.cmt_cross_map_id
	t_rec->qual[t_rec->cnt].diag_qual[i].diag_priority = d.clinical_diag_priority
foot d.encntr_id
	t_rec->qual[t_rec->cnt].diag_cnt = i
with nocounter,outerjoin=d1,outerjoin=d2,outerjoin=d3
	
call writeLog(build2("* END   Finding Diagnosis   *******************************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

call get_mrn(null)
call get_fin(null) 
call get_patientname(null)
call get_patientloc(null)
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Output   *******************************************"))

select into t_rec->cons.outdev
	 facility=substring(1,50,t_rec->qual[d1.seq].facility)
	,name=substring(1,100,t_rec->qual[d1.seq].name_full_formatted)
	,fin=substring(1,50,t_rec->qual[d1.seq].fin)
	,reg_dt_tm=substring(1,20,format(t_rec->qual[d1.seq].reg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
	,disch_dt_tm=substring(1,20,format(t_rec->qual[d1.seq].disch_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
	,orig_code=substring(1,100,t_rec->qual[d1.seq].diag_qual[d2.seq].orig_identifier)
	,orig_desc=substring(1,100,t_rec->qual[d1.seq].diag_qual[d2.seq].orig_source_string)
	,nomen_code=substring(1,100,t_rec->qual[d1.seq].diag_qual[d2.seq].identifier)
	,nomen_desc=substring(1,100,t_rec->qual[d1.seq].diag_qual[d2.seq].source_string)
	,diag_desc=substring(1,100,t_rec->qual[d1.seq].diag_qual[d2.seq].diag_display)
	,diag_dt_tm=substring(1,20,format(t_rec->qual[d1.seq].diag_qual[d2.seq].diag_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
	,diag_priority=t_rec->qual[d1.seq].diag_qual[d2.seq].diag_priority
	,provider=substring(1,100,t_rec->qual[d1.seq].diag_qual[d2.seq].responsible_provider)
	,diagnosis_id=t_rec->qual[d1.seq].diag_qual[d2.seq].diagnosis_id
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2 with seq=1)
	,diagnosis d
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].diag_cnt)
join d2
	where 	(
				(t_rec->qual[d1.seq].diag_qual[d2.seq].provider_id = 0)
				or 
				(
						(t_rec->qual[d1.seq].diag_qual[d2.seq].provider_id > 0.0) 
					and (t_rec->qual[d1.seq].diag_qual[d2.seq].ccm_map_ind > 0.0)
				)
			)
join d
	where d.diagnosis_id = t_rec->qual[d1.seq].diag_qual[d2.seq].diagnosis_id
order by
	 t_rec->qual[d1.seq].facility
	,t_rec->qual[d1.seq].name_full_formatted
	,t_rec->qual[d1.seq].diag_qual[d2.seq].diagnosis_group
with format,separator = " ",nocounter,format(date,";;q")

call writeLog(build2("* END   Output   *******************************************"))
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
 
if ((reply->status_data.status in("Z","S")) and (program_log->run_from_ops = 1))
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
