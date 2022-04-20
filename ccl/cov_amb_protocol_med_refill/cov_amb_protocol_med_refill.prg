/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Chad Cummings
	Date Written:
	Solution:
	Source file name:	cov_amb_protocol_med_refill.prg
	Object name:		cov_amb_protocol_med_refill
	Request #:
 
	Program purpose:
 
	Executing from:		CCL
 
 	Special Notes:		Called by ccl program(s).
 					    use cov_st_ccl_template.tst test
						1) Find new CKI
							a. Select * from clinical_note_template go
							b. CKI.NOTETEMPLATE!Protocol-MedicationRefill(LPN&RNOnly)
						2) Updated CODE_VALUE table with new CKI
							a. update into code_value Set CKI = "CKI.NOTETEMPLATE!Protocol-MedicationRefill(LPN&RNOnly)"
								Where code_value = 3161599639 and code_set = 16529

 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	08/12/2021  Chad Cummings			Initial Release
******************************************************************************/
 
drop program cov_amb_protocol_med_refill:dba go
create program cov_amb_protocol_med_refill:dba
 
 
call echo(build("loading script:",curprog))
set nologvar = 1	;do not create log = 1		, create log = 0
set noaudvar = 1	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))
 
execute cov_std_encntr_routines
execute cov_std_rtf_routines
 
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
 
call get_rtf_definitions(null)
 
record t_rec
(
	1 cnt			= i4
	1 encntr_id		= f8
	1 person_id		= f8
	1 facility      = vc
	1 unit			= vc
) with protect
 
 
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))
 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Set Person/Encounter ID ****************************"))
 
if (validate(request->visit[1].encntr_id))
	set t_rec->encntr_id = request->visit[1].encntr_id
endif
 
if (t_rec->encntr_id = 0.0)
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "ENCNTR_ID"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "ENCNTR_ID"
	set reply->status_data.subeventstatus.targetobjectvalue = "Encoutner ID not found or set in request"
	go to exit_script
endif

set t_rec->person_id = sGetPersonID_ByEncntrID(t_rec->encntr_id)

if (t_rec->person_id = 0.0)
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "PERSON_ID"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "PERSON_ID"
	set reply->status_data.subeventstatus.targetobjectvalue = "Person ID not found"
	go to exit_script
endif

set t_rec->facility = sGetFacility_ByEncntrID(t_rec->encntr_id)
set t_rec->unit	    = sGetUnit_ByEncntrID(t_rec->encntr_id)

set reply->text =  build2(reply->text,rtf_definitions->st.rhead)
set reply->text =  build2(reply->text,rtf_definitions->st.wr)

 
call writeLog(build2("* END   Set Person/Encounter ID ****************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Past Appointments   ********************************"))
 
set reply->text =  build2(reply->text," 1) Last Visit with provider:")
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text,rtf_definitions->st.reol)


set stat = cnvtjsontorec(sGetAppts_ByPersonID(t_rec->person_id,365,"PAST"))

if (stat = TRUE)
	for (i=1 to appointment_list->cnt)
	 if ((appointment_list->qual[i].location = t_rec->facility) or (appointment_list->qual[i].location = t_rec->unit))
		call writeLog(build2("appointment_list_i=",i))
		call writeLog(build2("appointment_list->qual[i].scheventid=",appointment_list->qual[i].scheventid))
		set reply->text =  build2(reply->text," \trowd\cellx2000\cellx4000\cellx6000\cellx10000\cellx12000 ")
		set reply->text =  build2(reply->text,"\intbl ",format(appointment_list->qual[i].beg_dt_tm,"MM/DD/YYYY - HH:MM;;q"),"\cell")
		set reply->text =  build2(reply->text,"\intbl ",appointment_list->qual[i].state,"\cell")
		set reply->text =  build2(reply->text,"\intbl ",appointment_list->qual[i].appt_type,"\cell")
		set reply->text =  build2(reply->text,"\intbl ",appointment_list->qual[i].prime_res,"\cell")
		set reply->text =  build2(reply->text,"\intbl ",appointment_list->qual[i].location,"\cell")
		set reply->text =  build2(reply->text," \row ")
	 endif
	endfor
	set reply->text =  build2(reply->text," \pard ")
	set reply->status_data.status = "S"
else
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "PAST_APPT"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "PAST_APPT"
	set reply->status_data.subeventstatus.targetobjectvalue = "Past appointments failed"
	go to exit_script
endif
 
call writeLog(build2("* END   Past Appointments   ********************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Future Appointments   ******************************"))

set reply->text =  build2(reply->text,rtf_definitions->st.reol)	
set reply->text =  build2(reply->text,rtf_definitions->st.reol)	
set reply->text =  build2(reply->text," 2) Next scheduled visit with provider: ")
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text,rtf_definitions->st.reol)

set stat = cnvtjsontorec(sGetAppts_ByPersonID(t_rec->person_id,365,"FUTURE"))
call echorecord(appointment_list)
call writeLog(build2("stat=",stat))

if (stat = TRUE)
	for (i=1 to appointment_list->cnt)
	 if ((appointment_list->qual[i].location = t_rec->facility) or (appointment_list->qual[i].location = t_rec->unit))
		call writeLog(build2("appointment_list_i=",i))
		call writeLog(build2("appointment_list->qual[i].scheventid=",appointment_list->qual[i].scheventid))
		set reply->text =  build2(reply->text," \trowd\cellx2000\cellx4000\cellx6000\cellx10000\cellx12000 ")
		set reply->text =  build2(reply->text,"\intbl ",format(appointment_list->qual[i].beg_dt_tm,"MM/DD/YYYY - HH:MM;;q"),"\cell")
		set reply->text =  build2(reply->text,"\intbl ",appointment_list->qual[i].state,"\cell")
		set reply->text =  build2(reply->text,"\intbl ",appointment_list->qual[i].appt_type,"\cell")
		set reply->text =  build2(reply->text,"\intbl ",appointment_list->qual[i].prime_res,"\cell")
		set reply->text =  build2(reply->text,"\intbl ",appointment_list->qual[i].location,"\cell")
		set reply->text =  build2(reply->text," \row ")
	 endif
	endfor
	set reply->text =  build2(reply->text," \pard ")
	set reply->status_data.status = "S"
else
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "FUTURE_APPT"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "FUTURE_APPT"
	set reply->status_data.subeventstatus.targetobjectvalue = "Past appointments failed"
	go to exit_script
endif
 
call writeLog(build2("* END   Future Appointments   ******************************"))
call writeLog(build2("************************************************************"))
 
  
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building Reply  ************************************"))

set reply->text =  build2(reply->text,rtf_definitions->st.reol)	
set reply->text =  build2(reply->text,rtf_definitions->st.reol)	

set reply->text =  build2(reply->text," If no visit is scheduled for the future - ",
										"schedule an appointment or a preventive/wellness visit if due.")
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text,rtf_definitions->st.reol)	

									
set reply->text =  build2(reply->text," If patient missed appointment since last refill or refuses to make a future appt - ",
									  " Notify the provider.")
									  
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text,rtf_definitions->st.reol)

set reply->text =  build2(reply->text," DO NOT Refill.")

set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text,rtf_definitions->st.reol)

set reply->text =  build2(reply->text,
	" 4) Has the patient been on this medication at current dose for less than 3 months? (   ) Yes   (   ) No")
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text," If Yes, consult with provider, Do Not Refill per protocol")


set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text,rtf_definitions->st.reol)

set reply->text =  build2(reply->text,
	" 5) Is the patient Symptomatic? (via labs or patient report)  (   ) Yes   (   ) No")
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text," If Yes, explain symptoms.")
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text," If Yes, consult with provider, Do Not Refill per protocol")


set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text,rtf_definitions->st.reol)

set reply->text =  build2(reply->text,
	" 6) Pertinent Labs or test required for renewal up to date per protocol?")
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text," Order labs per protocol if needed in anticipation of office visit.")
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text," Refill if normal, notify provider if abnormal.")



set reply->text =  build2(reply->text,
	" 7) Prescription Renewed? (   ) Yes   (   ) No")
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text,rtf_definitions->st.reol)
set reply->text =  build2(reply->text," If NO, document reason:")

set reply->text =  build2(reply->text,rtf_definitions->st.rtfeof)

call writeLog(build2("*->reply->text=",reply->text))
call echorecord(reply)

 
call writeLog(build2("* END   Building Reply  ************************************"))
call writeLog(build2("************************************************************"))
 
#exit_script
 
 
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)
 
 
end
go
 