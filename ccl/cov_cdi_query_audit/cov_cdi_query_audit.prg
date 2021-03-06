/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   cov_cdi_query_audit.prg
  Object name:        cov_cdi_query_audit
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings			initial build
******************************************************************************/
drop program cov_cdi_query_audit go
create program cov_cdi_query_audit 

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "REQUEST" = ""
	, "Param1" = 0
	, "Param2" = ""
	, "Param3" = ""
	, "Param4" = "" 

with OUTDEV, REQUEST, PARAM1, PARAM2, PARAM3, PARAM4

execute cov_std_log_routines
execute cov_cdi_routines
execute cov_std_html_routines

declare mpage_content_url = vc with noconstant(" ") 
declare html_output = vc with noconstant(" ")

record prompts
(
	1 outdev = vc
	1 request = vc
	1 param1 = f8
	1 param2 = vc
	1 param3 = vc
	1 param4 = vc
)

set prompts->outdev = $OUTDEV
set prompts->request = $REQUEST
set prompts->param1 = $PARAM1
set prompts->param2 = $PARAM2
set prompts->param3 = $PARAM3
set prompts->param4 = $PARAM4

call echorecord(prompts)

if (prompts->request = "DEFINITIONS")
	set _memory_reply_string = get_cdi_code_query_def(null)
	call echo(_memory_reply_string)
	go to exit_script
elseif (prompts->request = "UPDATE_CDI_CODE")
	if (validate_cdi_code_value(prompts->param1))
		set stat = update_cdi_code_value(prompts->param1,prompts->param2,prompts->param3,prompts->param4) 
	endif
	go to exit_script
elseif (prompts->request = "UPDATE_CDI")
	if (validate_cdi_value(prompts->param1))
		set stat = update_cdi_value(prompts->param1,prompts->param2,prompts->param3)               
	endif
	go to exit_script
elseif (prompts->request = "GET_SAVED_DOCUMENT")
	free record document
	record document
		(
			1 clinical_event_id = f8
			1 event_id = f8
			1 html = gvc
		)
	set document->clinical_event_id = prompts->param1
	set document->event_id = GetEventIDbyCEventID(prompts->param1)
	set document->html = get_saved_document(document->event_id)       
	set _memory_reply_string = cnvtrectojson(document) 
	go to exit_script
endif


set html_output = get_html_template("cov_cdi_query_audit.html")

set html_output = replace(html_output,"%%MPAGE_CONTENT_URL%%",get_static_content_base(null))
set html_output = replace(html_output,"%%PROMPTS%%",cnvtrectojson(prompts))
call put_html_output(prompts->outdev,html_output)

#exit_script

end
go

