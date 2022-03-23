/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_result_copy_util.prg
	Object name:		cov_result_copy_util
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

drop program cov_result_copy_util:dba go
create program cov_result_copy_util:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "FIN" = ""                                                                                                      ;* Patient E
	;<<hidden>>"Patient Name" = 0
	;<<hidden>>"Instructions" = "Select a PowerFrom from other encoutners that you would like to copy results from"   ;* Select a 
	, "PowerForms" = "" 

with OUTDEV, FIN, RESULTS


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
	 2 fin 			= vc
	 2 powerform	= vc
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
) with protect


set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.fin = $FIN
set t_rec->prompts.powerform = $RESULTS

declare link_encntrid = f8 with noconstant(0.0)
declare link_personid = f8 with noconstant(0.0)
declare link_powerform = vc with noconstant(" ")
declare debug_ind = i2 with constant(1) 

set link_powerform = t_rec->prompts.powerform

select into "nl:"
from encounter e
	 ,encntr_alias ea
plan ea
	where ea.alias = t_rec->prompts.fin
join e
	where e.encntr_id = ea.encntr_id
detail
	link_encntrid	= e.encntr_id
	link_personid	= e.person_id
with nocounter 

call addEmailLog("chad.cummings@covhlth.com")

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

call echorecord(t_rec)

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START cov_copy_powerform_results   ***********************"))

execute cov_copy_powerform_results ~MINE~,link_powerform

call writeLog(build2("* END   cov_copy_powerform_results   ***********************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

#exit_script

;001 end

;call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
;execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"Extracts/HIM/","CP" 
;execute cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->files.records_attachment)


call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)


end
go
