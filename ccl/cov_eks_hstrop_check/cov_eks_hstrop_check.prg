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

set retval = -1
 
 
record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	 2 order_id = f8
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
) with protect
 
 
call add_eks_log_message("v1")
 
set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid
 
set t_rec->patient.clinical_event_id		= link_clineventid
 
if (t_rec->patient.encntr_id <= 0.0)
	call add_eks_log_message("link_encntrid not found")
	go to exit_script
endif
 
if (t_rec->patient.person_id <= 0.0)
	call add_eks_log_message("link_personid not found")
	go to exit_script
endif
 
 
/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */
 
set t_rec->return_value = "FALSE"
 
execute cov_troponin_util
 
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

call add_eks_log_message(cnvtrectojson(t_rec))

set t_rec->log_message = eks_log->log_message
 
call echorecord(t_rec)
 
set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1
 
end
go
 
