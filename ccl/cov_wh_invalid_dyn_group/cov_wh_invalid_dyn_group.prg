/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Chad Cummings
	Date Written:
	Solution:
	Source file name:	cov_wh_invalid_dyn_group.prg
	Object name:		cov_wh_invalid_dyn_group
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
 
drop program cov_wh_invalid_dyn_group:dba go
create program cov_wh_invalid_dyn_group:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
 
call echo(build("loading script:",curprog))
set nologvar = 1	;do not create log = 1		, create log = 0
set noaudvar = 1	;do not create audit = 1	, create audit = 0
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
	 2 encntr_id = f8
	 2 person_id = f8
	 2 fin = vc
	 2 mrn = vc
	 2 label_name = vc
	 2 event_end_dt_tm = dq8
	 2 valid_from_dt_tm = dq8
	 2 prsnl = vc
	 2 position = vc
)
 
;call addEmailLog("chad.cummings@covhlth.com")
 
set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
 
set t_rec->dminfo.info_domain	= "COV_DEV_OPS"
set t_rec->dminfo.info_name		= concat(trim(cnvtupper(curprog)),":","start_dt_tm")
set t_rec->dates.start_dt_tm 	= get_dminfo_date(t_rec->dminfo.info_domain,t_rec->dminfo.info_name)
set t_rec->dates.end_dt_tm 		= cnvtdatetime(curdate,curtime3)
 
if (t_rec->dates.start_dt_tm = 0.0)
	call writeLog(build2("->No start date and time found, setting to go live date"))
	set t_rec->dates.start_dt_tm = cnvtdatetime("01-JAN-2022 00:00:00")
endif
 
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))
 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))
 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
 
call echorecord(t_rec->dates)
 
select into "nl:"
	from
		 clinical_Event ce3
		,ce_dynamic_label cdl
		,prsnl p
	plan ce3
	where
			;ce3.encntr_id in(select encntr_id from encntr_alias where alias ="5131900094")
		  ce3.valid_from_dt_tm >= cnvtdatetime(t_rec->dates.start_dt_tm)
	and   ce3.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ce3.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce3.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce3.event_tag        != "Date\Time Correction"
	and   ce3.person_id not in(select person_id from problem where nomenclature_id =      7777483.00
								and active_ind = 1 and cnvtdatetime(curdate,curtime3) between
								beg_effective_dt_tm and end_effective_dt_tm)
	join cdl
		where cdl.ce_dynamic_label_id = ce3.ce_dynamic_label_id
		and   cdl.label_name = "Baby*"
	join p
		where p.person_id = ce3.verified_prsnl_id
order by
	 ce3.encntr_id
	,cdl.label_name
	,ce3.valid_from_dt_tm
head report
	i = 0
head ce3.encntr_id
	null
head cdl.label_name
	i = (i + 1)
	stat = alterlist(t_rec->qual,i)
	t_rec->qual[i].label_name = cdl.label_name
	t_rec->qual[i].encntr_id = ce3.encntr_id
	t_rec->qual[i].person_id = ce3.person_id
	t_rec->qual[i].event_end_dt_tm = ce3.event_end_dt_tm
	t_rec->qual[i].valid_from_dt_tm = ce3.valid_from_dt_tm
	t_rec->qual[i].prsnl = p.name_full_formatted
	t_rec->qual[i].position = uar_get_code_display(p.position_cd)
foot report
	t_rec->cnt = i
with nocounter
 
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))
 
call get_mrn(null)
call get_fin(null)
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Creating Audit *************************************"))
	call writeAudit(build2(
							char(34),^MRN^,			char(34),char(44),
							char(34),^FIN^,			char(34),char(44),
							char(34),^IVIEW DATE^,	char(34),char(44),
							char(34),^ENTERED DATE^,	char(34),char(44),
							char(34),^LABEL^,		char(34),char(44),
							char(34),^PRSNL^,		char(34),char(44),
							char(34),^POSITION^,	char(34)
						))
for (i=1 to t_rec->cnt)
		call writeAudit(build2(
							char(34),t_rec->qual[i].mrn													,char(34),char(44),
							char(34),t_rec->qual[i].fin													,char(34),char(44),
							char(34),format(t_rec->qual[i].event_end_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")	,char(34),char(44),
							char(34),format(t_rec->qual[i].valid_from_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")	,char(34),char(44),
							char(34),t_rec->qual[i].label_name											,char(34),char(44),
							char(34),t_rec->qual[i].prsnl												,char(34),char(44),
							char(34),t_rec->qual[i].position											,char(34)
						))
 
endfor
 
if (t_rec->cnt > 0)
	set reply->status_data.status = "S"
else
	set reply->status_data.status = "Z"
	set stat = alterlist(program_log->email->qual,0)
endif
 
call writeLog(build2("* END   Creating Audit *************************************"))
call writeLog(build2("************************************************************"))
 
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
 
