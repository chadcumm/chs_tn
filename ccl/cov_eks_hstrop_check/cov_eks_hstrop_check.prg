/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/11/2021
  Solution:
  Source file name:   cov_eks_hstrop_check.prg
  Object name:        cov_eks_hstrop_check
  Request #:
 
  Program purpose:
 
  Executing from:     CCL
 
  Special Notes:      Additional Scripts:
  						
  						cov_troponin_util 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   12/11/2021  Chad Cummings			initial build
******************************************************************************/
drop program cov_eks_hstrop_check:dba go
create program cov_eks_hstrop_check:dba

execute cov_std_log_routines
execute cov_troponin_util

set retval = -1
 
 
record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	 2 order_id = f8
	1 retval = i2
	1 cons
	 2 hsTrop_cd				= f8
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
	1 event_cnt     = i4
	1 event_list[*]
	 2 event_id		= f8
	 2 new_event_id = f8
	 2 encntr_id	= f8
	 2 person_id    = f8
	 2 current_phase = vc
	 2 order_dt_tm = dq8
	 2 order_dt_tm_vc = vc
) with protect
 
 
call add_eks_log_message("v1")
 
set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid
  
if (t_rec->patient.encntr_id <= 0.0)
	call add_eks_log_message("link_encntrid not found")
	go to exit_script
endif
 
if (t_rec->patient.person_id <= 0.0)
	call add_eks_log_message("link_personid not found")
	go to exit_script
endif

set t_rec->cons.hsTrop_cd = GethsTropAlgEC(null) 
 
/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */
 
set t_rec->return_value = "FALSE"

select into "nl:"
from
	 encounter e
	,person p
	,clinical_event ce
	,ce_blob ceb
plan e
	where e.encntr_id = t_rec->patient.encntr_id
join p
	where p.person_id = e.person_id
join ce
	where ce.encntr_id = e.encntr_id
	and   ce.event_cd =  t_rec->cons.hsTrop_cd
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
join ceb
	where ceb.event_id = ce.event_id
order by
	ce.parent_event_id
head ce.parent_event_id
	t_rec->event_cnt = (t_rec->event_cnt + 1)
	stat = alterlist(t_rec->event_list,t_rec->event_cnt)
	t_rec->event_list[t_rec->event_cnt].encntr_id = e.encntr_id
	t_rec->event_list[t_rec->event_cnt].event_id = ce.parent_event_id
	t_rec->event_list[t_rec->event_cnt].person_id = p.person_id
with nocounter

if (t_rec->patient.encntr_id <= 0.0)
	call add_eks_log_message("no alogrithms found")
	go to exit_script
endif

for (i=1 to t_rec->event_cnt)
 
	call addhsTropDataRec(1)
	set stat = cnvtjsontorec(GethsTropAlgDataByEventID(t_rec->event_list[i].event_id))
	if (validate(hsTroponin_data))
		call echorecord(hsTroponin_data)
		set t_rec->event_list[i].current_phase = hsTroponin_data->current_phase
		set t_rec->event_list[i].order_dt_tm = hsTroponin_data->three_hour.target_dt_tm
		set t_rec->event_list[i].order_dt_tm_vc = format(
															t_rec->event_list[i].order_dt_tm
															,"dd-mmm-yyyy hh:mm:ss zzz;;q"
														)
		if (t_rec->event_list[i].current_phase = "INITIAL")
			set t_rec->return_value = "TRUE"
			set t_rec->log_misc1 = t_rec->event_list[i].order_dt_tm_vc
		endif
	endif
endfor
 
#exit_script
 
if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
else
	set t_rec->retval = 0
endif

call add_eks_log_message(cnvtrectojson(t_rec))

set t_rec->log_message = eks_log->log_message
 
call echorecord(t_rec)
 
set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1
 
end
go
 
