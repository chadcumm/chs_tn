/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       
  Solution:           
  Source file name:   cov_bh_adult_aggitation_check.prg
  Object name:        cov_bh_adult_aggitation_check
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
drop program cov_bh_adult_aggitation_check:dba go
create program cov_bh_adult_aggitation_check:dba

execute cov_std_log_routines

call SubroutineLog(build2("starting ",trim(curprog)))

set retval = -1

free record t_rec
record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	 2 pathway_id = f8
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
)

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

/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */

set t_rec->return_value = "FALSE"

select
	pc.description
	,o.order_mnemonic
	,p.description
	,p.*
from
	 encounter e
	,orders o
	,pathway_catalog pc
	,act_pw_comp apc
	,pathway p
plan e
	where e.encntr_id = t_rec->patient.encntr_id
join o
	where o.encntr_id = e.encntr_id
	and   o.order_mnemonic = "Provider to Assess the Need for Continuation of Protocol Every 48 Hours"
	and   o.order_status_cd = value(uar_get_code_by("MEANING",6004,"ORDERED"))
join apc
	where apc.parent_entity_id = o.order_id
join pc
	where pc.pathway_catalog_id = o.pathway_catalog_id
	and   pc.description = "BH Adult Agitation Orders*"
	;and   pc.description = "HOS Syncope Admission"
join p
	where p.pathway_id = apc.pathway_id
	and   p.pw_status_cd = value(uar_get_code_by("MEANING",16769,"INITIATED"))
	and   p.start_dt_tm <= cnvtlookbehind("40,H",cnvtdatetime(sysdate))
order by
	 e.encntr_id
	,p.start_dt_tm
head e.encntr_id
	t_rec->log_misc1 = build2(trim(p.description),":",trim(format(p.start_dt_tm,";;q")))
	t_rec->return_value = "TRUE"
	t_rec->patient.pathway_id = p.pathway_id
with nocounter,uar_code(d,1),format(date,"dd-mm-yyyy hh:mm:ss;;q")

;set t_rec->return_value = "TRUE"

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
										trim("p:",cnvtstring(t_rec->patient.person_id)),"|",
										trim("e:",cnvtstring(t_rec->patient.encntr_id)),"|",
										trim("pw:",cnvtstring(t_rec->patient.pathway_id)),"|",
										trim(t_rec->log_misc1)
									)
call echorecord(t_rec)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1

end 
go
