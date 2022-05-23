/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       
  Solution:           
  Source file name:   cov_wh_ce_invalid_dyn_group.prg
  Object name:        cov_wh_ce_invalid_dyn_group
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
drop program cov_wh_ce_invalid_dyn_group:dba go
create program cov_wh_ce_invalid_dyn_group:dba

execute cov_std_log_routines

call SubroutineLog(build2("starting ",trim(curprog)))

set retval = -1

free record t_rec
record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	 2 order_id = f8
	 2 clinical_event_id = f8
	 2 label = vc
	1 ce_cnt = i4
	1 ce_qual[*]
	 2 clinical_event_id = f8
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
)

set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid

set t_rec->patient.clinical_event_id		= request->clin_detail_list[1].clinical_event_id

set t_rec->ce_cnt = size(request->clin_detail_list,5)

select into "nl:"
from
	(dummyt d1 with seq=t_rec->ce_cnt)
plan d1
head report
	i = 0
detail
	i += 1
	stat = alterlist(t_rec->ce_qual,i)
	t_rec->ce_qual[i].clinical_event_id = request->clin_detail_list[i].clinical_event_id
with nocounter

if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif

if (t_rec->patient.clinical_event_id <= 0.0)
	set t_rec->log_message = concat("Link_clineventid not found")
	go to exit_script
endif

/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */

set t_rec->return_value = "FALSE"

select into "nl:"
	from
		 clinical_event ce3
		,ce_dynamic_label cdl
		,prsnl p
		,(dummyt d1 with seq=t_rec->ce_cnt)
	plan d1
	join ce3
	where ce3.clinical_event_id = t_rec->ce_qual[d1.seq].clinical_event_id
	and	  ce3.encntr_id > 0.0
	and	  ce3.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   ce3.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ce3.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce3.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce3.event_tag        != "Date\Time Correction"
	and   ce3.person_id not in(select pr.person_id from problem pr where pr.person_id = ce3.person_id
								and pr.nomenclature_id =      7777483.00
								and pr.life_cycle_status_cd =        3301.00	;	Active
								and pr.active_ind = 1 and cnvtdatetime(curdate,curtime3) between
								pr.beg_effective_dt_tm and pr.end_effective_dt_tm)
	join cdl
		where cdl.ce_dynamic_label_id = ce3.ce_dynamic_label_id
		and   cdl.label_name = "Baby*"
	join p
		where p.person_id = ce3.verified_prsnl_id
	detail
		t_rec->return_value = "TRUE"
		t_rec->patient.label = cdl.label_name
	with nocounter

#exit_script

if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
else
	set t_rec->retval = 0
endif

set t_rec->log_message = concat(
										trim(t_rec->log_message),";",
										trim(cnvtupper(t_rec->return_value)),":",
										"p:",trim(cnvtstring(t_rec->patient.person_id)),"|",
										"e:",trim(cnvtstring(t_rec->patient.encntr_id)),"|",
										"ce:",trim(cnvtstring(t_rec->patient.clinical_event_id)),"|",
										"label:",trim(t_rec->patient.label),"|"
									)
set t_rec->log_misc1 = log_message

call echorecord(t_rec)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1

end 
go
