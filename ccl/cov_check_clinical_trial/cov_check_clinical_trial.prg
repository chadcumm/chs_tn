/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:					Chad Cummings
	Date Written:			03/01/2019
	Solution:				Discern
	Source file name:		cov_check_clinical_trial.prg
	Object name:			cov_check_clinical_trial
	Request #:

	Program purpose:

	Executing from:			CCL, Discern Expert

 	Special Notes:			Called by ccl program(s) or Discern Expert templates

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	06/01/2019  Chad Cummings
******************************************************************************/
drop program cov_check_clinical_trial go
create program cov_check_clinical_trial

set retval = -1

free record t_rec
record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	 2 cMRN = vc
	1 prsnl
	 2 username = vc
	 2 position = vc
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 uri_base = vc
	1 uri_method = vc
	1 uri_put = vc
	1 return_value = vc
)

declare callPost(uri_put = vc, response = vc(REF))=null with public

set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid
set t_rec->uri_base							= "http://covhppmodules.covhlth.net/ColdFusionApplications/Cerner_PopulationGroupAlert/WebService.cfc"
;http://covhppmodules.covhlth.net/ColdFusionApplications/Cerner_PopulationGroupAlert/WebService.cfc
;?method=fnPopulationGroupShowAlert&strStaffUserName=CCUMMIN4&strStaffCernerPosition=441&strPatientCMRN=1

if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif

if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->uri_method = value(parameter(1,0))
endif

if (t_rec->uri_method = " ")
	;set t_rec->uri_method = "fnPopulationGroupShowAlert"
	set t_rec->log_message = concat("URI Method not specified as first parameter")
	go to exit_script
endif

if (t_rec->uri_base = " ")
	set t_rec->log_message = concat("URI Base not defined")
	go to exit_script
endif

select into "nl:"
from prsnl p
plan p
	where p.person_id = reqinfo->updt_id
detail
	t_rec->prsnl.username = p.username
	t_rec->prsnl.position = cnvtstring(p.position_cd)
with nocounter

if (t_rec->prsnl.username = " ")
	set t_rec->log_message = concat("Username not found for prsnl_id=",trim(cnvtstring(reqinfo->updt_id)))
	go to exit_script
endif

if (t_rec->prsnl.position = " ")
	set t_rec->log_message = concat("Position not found for prsnl_id=",trim(cnvtstring(reqinfo->updt_id)))
	go to exit_script
endif

select into "nl:"
from
	person_alias pa
plan pa
	where pa.person_id = t_rec->patient.person_id
	and   pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   pa.active_ind = 1
	and   pa.person_alias_type_cd = value(uar_get_code_by("MEANING",4,"CMRN"))
detail
	t_rec->patient.cMRN = pa.alias
	;00628337
	if (size(trim(pa.alias)) = 6)
		t_rec->patient.cMRN = concat("00",t_rec->patient.cMRN)
	elseif (size(pa.alias) = 5)
		t_rec->patient.cMRN = concat("000",t_rec->patient.cMRN)
	elseif (size(pa.alias) = 4)
		t_rec->patient.cMRN = concat("0000",t_rec->patient.cMRN)
	endif
with nocounter

if (t_rec->patient.cMRN = "")
	set t_rec->log_message = concat("cMRN not found for person_id=:",trim(cnvtstring(t_rec->patient.person_id)))
	go to exit_script
endif

set t_rec->uri_put = 	concat(
								t_rec->uri_base
								,^?method=^,					t_rec->uri_method
								,^&strStaffUserName=^,			t_rec->prsnl.username
								,^&strStaffCernerPosition=^,	t_rec->prsnl.position
								,^&strPatientCMRN=^,			t_rec->patient.cMRN
								)


declare uri = vc with protect
declare uri_comp = vc with protect
declare uri_put = vc with protect
declare response = vc with protect
declare _crlf = vc with protect, CONSTANT( build2(char(13),char(10)) )
declare msg = vc with protect
declare source = vc with noConstant("")
declare target = vc with noConstant("")
declare cnt = i4 with noConstant(0)
declare i = i4 with noConstant(0)
declare index = i4 with noConstant(0)
declare os_flag = vc with noConstant("")
declare buf_cclisam = vc
declare idx_file = vc with protect, noConstant("")
declare idx_pos = i4 with protect, noConstant(0)
declare component_file = vc with noconstant
declare health_system_source_id = vc with protect
declare dic_var = vc with noConstant("")
declare response = vc with noConstant("")
declare user_pos = vc with protect, noConstant("")
declare pat_cMRN = vc with protect, noConstant("")

execute srvuri
set t_rec->return_value =  callPost(t_rec->uri_put, response)

#exit_script

if (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
	set t_rec->log_misc1 = concat(trim(t_rec->patient.cMRN),"|",trim(t_rec->prsnl.username),"|",trim(t_rec->prsnl.position))
;elseif (trim(cnvtupper(t_rec->return_value)) = "*TRIAL*")
elseif (trim(cnvtupper(t_rec->return_value)) = "*POP NOTICE*")
	set t_rec->log_misc1 = t_rec->return_value
	set t_rec->log_misc1 = replace(t_rec->log_misc1,^POP NOTICE: ^,^^)
	set t_rec->return_value = replace(t_rec->return_value,^"^,^^)
	set t_rec->retval = 100
else
	set t_rec->retval = 0
endif

set t_rec->log_message = concat(
										trim(t_rec->log_message),";",
										trim(t_rec->log_misc1),";",
										trim(cnvtupper(t_rec->return_value)),";",
										trim(t_rec->patient.cMRN),"|",
										trim(t_rec->prsnl.username),"|",
										trim(t_rec->prsnl.position),":",
										t_rec->uri_put
									)
call echorecord(t_rec)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1



subroutine callPost(uri_put, response)

  ;srvuri variables
  declare hUri_put = i4 with protect
  declare hReq_put = i4 with protect
  declare hBuf_put = i4 with protect
  declare hResp_put = i4 with protect
  declare auth_str = vc with protect, noConstant("")
  declare hResp_Props_put = i4 with protect
  declare hProps_put = i4 with protect
  declare customHeaderProp_put = i4 with protect
  declare pos_put = i4 with protect
  declare buf = c100 with protect
  declare hBuf = i4 with protect
  declare pos = i4 with protect
  declare actual = i4 with protect

  
  set hUri_put = uar_SRV_GetURIParts(value(uri_put))
  set hReq_put = uar_SRV_CreateWebRequest (hUri_put)

  set hProps_put = uar_SRV_CreatePropList()
  set customHeaderProp_put = uar_SRV_CreatePropList ()

  set hBuf_put = uar_SRV_CreateMemoryBuffer (3, 0, 0, 0, 0, 0) ;3 = SRV_ACCESS_READ_WRITE

  set stat = uar_SRV_SetBufferPos(hBuf_put, 0, 0, pos_put)
  set stat = uar_SRV_WriteBuffer(hBuf_put, msg, size(msg), actual)
  set stat = uar_SRV_SetPropString(hProps_put,"method","get")
  set stat = uar_SRV_SetPropString(hProps_put,"contenttype", "application/json")

  set stat = uar_SRV_SetPropString(customHeaderProp_put,"Authorization", nullterm(auth_str))
  set stat = uar_SRV_SetPropHandle(hProps_put,"customHeaders",customHeaderProp_put,1)
  set stat = uar_SRV_SetPropHandle(hProps_put,"reqBuffer",hBuf_put,1)
  set stat = uar_SRV_SetWebRequestProps (hReq_put, hProps_put)
  set hResp_put = uar_SRV_GetWebResponse (hReq_put, hBuf_put)

  IF(hResp_put = 0)
  	set response = concat(response, "Invalid handle returned, failure")
  	call echo ("invalid handle")
  ENDIF
  set hResp_Props_put = uar_SRV_GetWebResponseProps (hResp_put)
  set response = concat(response,"GetWebResponseProps Put: ", build(hResp_Props_put))
  call echo(response)
  set stat = uar_SRV_GetMemoryBufferSize (hBuf_put, 0)
   ; Reset buffer position to beginning
  set stat = uar_SRV_SetBufferPos (hBuf_put, 0, 0, pos)
   ; Read first 8k
  set stat = uar_SRV_ReadBuffer (hBuf_put, buf, 100, actual)
  

  set response = buf
  
  call echo(response)
  
  free record camm_mmf
  record camm_mmf (
  		1 status = vc
   		1 timestamp = dq8
  	)
  
  set camm_mmf->status = response
  set camm_mmf->timestamp = cnvtdatetime(CURDATE,CURTIME)

  call echoxml(camm_mmf,"cammlogservice",1)
  set stat = uar_SRV_CloseHandle (hUri_put)
  set stat = uar_SRV_CloseHandle (hReq_put)
  set stat = uar_SRV_CloseHandle (hProps_put)
  set stat = uar_SRV_CloseHandle (hBuf_put)
  set stat = uar_SRV_CloseHandle (hResp_Props_put)
  set stat = uar_SRV_CloseHandle (hResp_put)

  return (response)
end; callPost


end go
