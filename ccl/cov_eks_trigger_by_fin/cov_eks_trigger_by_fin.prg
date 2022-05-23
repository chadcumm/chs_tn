
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				   Chad Cummings
	Date Written:		   03/01/2019
	Solution:			   
	Source file name:	   cov_eks_trigger_by_fin.prg
	Object name:		   cov_eks_trigger_by_fin
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	03/01/2019  Chad Cummings
002     02/23/2020	Chad Cummings			Changed srv execution to tdbexecute
******************************************************************************/

drop program cov_eks_trigger_by_fin:dba go
create program cov_eks_trigger_by_fin:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Trigger" = ""
	, "FIN" = "1812900019" 

with OUTDEV, TRIGGER, FIN


call echo(build("loading script: ",curprog))
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

if (program_log->run_from_ops = 1)
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus[1].operationname		= "STARTUP"
	set reply->status_data.subeventstatus[1].operationstatus	= "F"
	set reply->status_data.subeventstatus[1].targetobjectname	= ""
	set reply->status_data.subeventstatus[1].targetobjectvalue	= "Script Started and Ended"
endif

call set_codevalues(null)
call check_ops(null)

call addEmailLog("chad.cummings@covhlth.com")


record t_rec
(
	1 cnt = i2
	1 start_dt_tm = dq8
	1 audit_mode = i2
	1 trigger = vc
	1 ce_id = f8
	1 fin = vc
	1 qual[*]
	 2 encntr_id  = f8
) with protect
record EKSOPSRequest (
   1 expert_trigger	= vc
   1 qual[*]
	2 person_id	= f8
	2 sex_cd	= f8
	2 birth_dt_tm	= dq8
	2 encntr_id	= f8
	2 accession_id	= f8
	2 order_id	= f8
	2 data[*]
	     3 vc_var		= vc
	     3 double_var	= f8
	     3 long_var		= i4
	     3 short_var	= i2
)

%i cclsource:eks_rprq3091001.inc

set t_rec->fin = $FIN
set t_rec->trigger = $TRIGGER

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Encounter **********************************"))

select into "nl:"
	facility=uar_get_code_display(e.loc_facility_cd)
from
	 encntr_alias ea
	,encounter e
	,person p
plan ea
	where ea.alias = t_rec->fin
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = code_values->cv.cs_319.fin_nbr_cd
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join e
	where e.encntr_id = ea.encntr_id
join p
	where p.person_id = e.person_id
order by
	 e.encntr_id
	,ea.beg_effective_dt_tm desc
head report
	cnt = 0
head e.encntr_id
	cnt = cnt +1
	if(mod(cnt,100) = 1)
		stat = alterlist(t_rec->qual, cnt +99)
	endif
	call writeLog(build2("->Adding encounter=",trim(cnvtstring(e.encntr_id))))
	t_rec->qual[cnt].encntr_id = e.encntr_id
foot report
	 stat = alterlist(t_rec->qual, cnt)
	 t_rec->cnt = cnt
	 call writeLog(build2("-->Total to process:",trim(cnvtstring(t_rec->cnt))))
with nocounter

call writeLog(build2("* END   Finding Encounter **********************************"))
call writeLog(build2("************************************************************"))

if (t_rec->cnt = 0)
	if (program_log->run_from_ops = 1)
		set reply->status_data.status = "Z"
		set reply->status_data.subeventstatus[1].operationname		= "ENCNTR"
		set reply->status_data.subeventstatus[1].operationstatus	= "Z"
		set reply->status_data.subeventstatus[1].targetobjectname	= "ENCOUNTER"
		set reply->status_data.subeventstatus[1].targetobjectvalue	= "No Encounters qualified"
	endif
	go to exit_script
endif
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Sending Documents to EKS ***************************"))

/*
Use the following commands to create and call the sub-routine that sends
the data in the EKSOPSRequest to the Expert Servers.
*/
 
%i cclsource:eks_run3091001.inc

call writeLog(build2("Starting EKSOPSRequest calls:",trim(cnvtstring(t_rec->cnt))))
for (i = 1 to t_rec->cnt)
	call writeLog(build2("-->Looking at Item:",trim(cnvtstring(i))))
	call writeLog(build2("-->Setting Expert Trigger to ",t_rec->trigger))
	set stat = initrec(EKSOPSRequest)
	select into "NL:"
		e.encntr_id,
		e.person_id,
		e.reg_dt_tm,
		p.birth_dt_tm,
		p.sex_cd
	from
		person p,
		encounter e
	plan e
		where e.encntr_id = t_rec->qual[i].encntr_id
	join p where p.person_id= e.person_id
	head report
		cnt = 0
		EKSOPSRequest->expert_trigger = t_rec->trigger
	detail
		cnt = cnt +1
		stat = alterlist(EKSOPSRequest->qual, cnt)
		EKSOPSRequest->qual[cnt].person_id = p.person_id
		EKSOPSRequest->qual[cnt].sex_cd  = p.sex_cd
		EKSOPSRequest->qual[cnt].birth_dt_tm  = p.birth_dt_tm
		EKSOPSRequest->qual[cnt].encntr_id  = e.encntr_id
		call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].person_id=",
			trim(cnvtstring(EKSOPSRequest->qual[cnt].person_id))))
		call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].encntr_id=",
			trim(cnvtstring(EKSOPSRequest->qual[cnt].encntr_id))))
	with nocounter
	set dparam = 0
	if (t_rec->audit_mode != 1)
		call writeLog(build2("------>CALLING srvRequest"))
		;002 call srvRequest(dparam)
		;002 call pause(3)
		set dparam = tdbexecute(3055000,4801,3091001,"REC",EKSOPSRequest,"REC",ReplyOut) ;002
		call writeLog(build2(cnvtrectojson(ReplyOut)))	;002
	else
		call writeLog(build2("------>AUDIT MODE, Not calling srvRequest"))
	endif
	call writeLog(build2(cnvtrectojson(EKSOPSRequest)))	;002 
endfor

call writeLog(build2("* END   Sending Documents to EKS ***************************"))
call writeLog(build2("************************************************************"))

if (program_log->run_from_ops = 1)
	set reply->status_data.status = "S"
	set reply->status_data.subeventstatus[1].operationname		= "ENCNTR"
	set reply->status_data.subeventstatus[1].operationstatus	= "S"
	set reply->status_data.subeventstatus[1].targetobjectname	= "ENCOUNTER"
	set reply->status_data.subeventstatus[1].targetobjectvalue	= "Encounters Sent"
endif
	
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

;call writeLog(build2("************************************************************"))
;call writeLog(build2("* START Sending Documents to EKS ***************************"))
;call writeLog(build2("* END   Sending Documents to EKS ***************************"))
;call writeLog(build2("************************************************************"))


#exit_script
call writeLog(build2(cnvtrectojson(t_rec)))	;002
execute ccl_readfile $OUTDEV, program_log->files.filename_log,0,11,8.5


call exitScript(null)
call echorecord(EKSOPSRequest)
call echorecord(t_rec)
;call echorecord(code_values)
call echorecord(program_log)


end
go
