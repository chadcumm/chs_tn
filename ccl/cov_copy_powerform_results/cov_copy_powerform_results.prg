/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       
  Solution:           
  Source file name:   cov_copy_powerform_results.prg
  Object name:        cov_copy_powerform_results
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   			  Chad Cummings			initial build
******************************************************************************/
drop program cov_copy_powerform_results:dba go
create program cov_copy_powerform_results:dba

execute cov_std_log_routines
execute cov_std_ce_routines

call SubroutineLog(build2("starting ",trim(curprog)))

set retval = -1

record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	1 output
	 2 outdev = vc
	1 powerform
	 2 dcp_forms_ref_id = f8
	 2 description = vc
	 2 form_dt_tm = dq8
	 2 dcp_forms_act_id = f8
	1 results_cnt = i4
	1 results[*]
	 2 event_cd = f8
	 2 event_code = vc
	 2 event_class_cd = f8
	 2 current_event_id = f8
	 2 new_event_id = f8
	 2 result_val = vc
	 2 result_dt_tm = dq8
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
) with protect

set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid

if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif


if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->output.outdev = value(parameter(1,0))
endif

if(size(trim(reflect(parameter(2,0))),1) > 0)
  set t_rec->powerform.description = value(parameter(2,0))
endif 


if (t_rec->powerform.description = " ")
	set t_rec->log_message = concat("powerform description parameter not found")
	go to exit_script
endif

set t_rec->powerform.dcp_forms_ref_id = sGetPowerFormRefbyDesc(t_rec->powerform.description)

if (t_rec->powerform.dcp_forms_ref_id <= 0.0)
	set t_rec->log_message = concat("dcp_forms_ref_id not found")
	go to exit_script
endif

set t_rec->powerform.dcp_forms_act_id = sMostRecentPowerForm(t_rec->patient.person_id,0.0,t_rec->powerform.dcp_forms_ref_id)

set t_rec->return_value = "FALSE"

select into "nl:"
from
      dcp_forms_activity dfa
    , dcp_forms_activity_comp dfac
    , clinical_event ce1
    , clinical_event ce2
    , clinical_event ce3
    , discrete_task_assay dta
plan dfa 
	where 	dfa.dcp_forms_activity_id = t_rec->powerform.dcp_forms_act_id
    and 	dfa.active_ind = 1
    and 	dfa.form_status_cd in(
    								 value(uar_get_code_by("MEANING", 8, "AUTH"))
                              		,value(uar_get_code_by("MEANING", 8, "MODIFIED"))
                              	)
join dfac 
	where 	dfac.dcp_forms_activity_id = dfa.dcp_forms_activity_id
    and 	dfac.component_cd = value(uar_get_code_by("DISPLAY_KEY", 18189, "PRIMARYEVENTID"))
    and 	dfac.parent_entity_name = "CLINICAL_EVENT"
join ce1 
	where 	ce1.event_id = dfac.parent_entity_id
    and 	ce1.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.000")
    and 	ce1.result_status_cd in(
    									 value(uar_get_code_by("MEANING", 8, "AUTH"))
                                		,value(uar_get_code_by("MEANING", 8, "MODIFIED"))
                                	)
    and 	ce1.event_reltn_cd = value(uar_get_code_by("MEANING", 24, "ROOT"))
join ce2 
	where 	ce2.parent_event_id = ce1.event_id
    and 	ce2.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.000")
    and 	ce2.result_status_cd in (	 value(uar_get_code_by("MEANING", 8, "AUTH"))
            		                    ,value(uar_get_code_by("MEANING", 8, "MODIFIED")))
    and 	ce2.event_reltn_cd = value(uar_get_code_by("MEANING", 24, "CHILD")) 
join ce3 
	where 	ce3.parent_event_id = ce2.event_id
    and 	ce3.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.000")
    and 	ce3.result_status_cd in (value(uar_get_code_by("MEANING", 8, "AUTH"))
                                , value(uar_get_code_by("MEANING", 8, "MODIFIED")))
    and 	ce3.event_reltn_cd = value(uar_get_code_by("MEANING", 24, "CHILD")) 
join dta
	where dta.task_assay_cd = ce3.task_assay_cd
	and   dta.default_result_type_cd != value(uar_get_code_by("MEANING",289,"8"))
order by
	 ce3.event_cd
	,ce3.valid_from_dt_tm desc
	,dfa.form_dt_tm desc
head report
	i = 0
	t_rec->powerform.form_dt_tm = dfa.form_dt_tm
	t_rec->powerform.dcp_forms_act_id = dfa.dcp_forms_activity_id
head ce3.event_cd
	i = (i + 1)
	stat = alterlist(t_rec->results,i)
	t_rec->results[i].current_event_id = ce3.event_id
	t_rec->results[i].event_cd = ce3.event_cd
	t_rec->results[i].event_code = uar_get_code_display(ce3.event_cd)
	t_rec->results[i].result_val = ce3.result_val
	t_rec->results[i].event_class_cd = ce3.event_class_cd
foot report
	t_rec->results_cnt = i
with nocounter

if (t_rec->results_cnt <= 0)
	set t_rec->log_message = concat("no results found for the patient and powerform")
	go to exit_script
endif

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->results_cnt)
	,ce_date_result cdr
plan d1
	where t_rec->results[d1.seq].event_class_cd = value(uar_get_code_by("MEANING",53,"DATE"))
join cdr
	where cdr.event_id = t_rec->results[d1.seq].current_event_id
	and   cnvtdatetime(sysdate) between cdr.valid_from_dt_tm and cdr.valid_until_dt_tm
order by
	 cdr.event_id
	,cdr.valid_until_dt_tm desc
head cdr.event_id
	t_rec->results[d1.seq].result_val = format(cdr.result_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")
	t_rec->results[d1.seq].result_dt_tm = cdr.result_dt_tm
with nocounter

for (i=1 to t_rec->results_cnt)

	call SubroutineLog(build2("->processing ",t_rec->results[i].event_code, " value=",trim(t_rec->results[i].result_val)))
	set t_rec->results[i].new_event_id = Add_CEResult(
														 t_rec->patient.encntr_id
														,t_rec->results[i].event_cd
														,t_rec->results[i].result_val
														,cnvtdatetime(curdate,curtime3)
														,"NUM") 
endfor
  
set t_rec->return_value = "TRUE"

#exit_script

if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
	set t_rec->log_misc1 = ""
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
else
	set t_rec->retval = 0
endif

set t_rec->log_message = concat(
										trim(t_rec->log_message),";",
										trim(cnvtupper(t_rec->return_value)),":",
										trim(cnvtstring(t_rec->patient.person_id)),"|",
										trim(cnvtstring(t_rec->patient.encntr_id)),"|"
									)
call SubroutineLog("t_rec","record")

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1

end 
go
