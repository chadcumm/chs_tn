/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Chad Cummings
	Date Written:
	Solution:
	Source file name:	cov_smart_template_test.prg
	Object name:		cov_smart_template_test
	Request #:
 
	Program purpose:
 
	Executing from:		CCL
 
  Special Notes:      
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
001   	12/11/2021  Chad Cummings			initial build
******************************************************************************/
drop program cov_smart_template_test go
create program cov_smart_template_test

prompt 
	"Output to File/Printer/MINE" = "MINE"         ;* Enter or select the printer or file name to send this report to.
	, "FIN" = "2302913670"
	, "Template" = "cov_amb_protocol_med_refill" 

with OUTDEV, FIN, TEMPLATE

execute cov_std_encntr_routines
execute cov_std_rtf_routines
execute cov_std_html_routines

record t_rec
(
	1 prompts
	 2 outdev = vc
	 2 fin = vc
	 2 template = vc
	1 values
	 2 fin = vc
	 2 encntr_id = f8
	 2 person_id = f8
	 2 script = vc
	 2 st_execution = vc
) with protect

free record st_request 
record st_request
(
  1 output_device     = vc
  1 script_name       = vc
  1 person_cnt        = i4
  1 person[*]
      2 person_id     = f8
  1 visit_cnt = i4
  1 visit[*]
      2 encntr_id     = f8
  1 prsnl_cnt = i4
  1 prsnl[*]
      2 prsnl_id      = f8
  1 nv_cnt = i4
  1 nv[*]
      2 pvc_name      = vc
      2 pvc_value     = vc
  1 batch_selection   = vc
) 
 
free set st_reply
record  st_reply
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

declare html_output = gvc with protect

set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.fin = $FIN
set t_rec->prompts.template = $TEMPLATE

set t_rec->values.fin = t_rec->prompts.fin

set t_rec->values.encntr_id = sGetEncntrID_ByFIN(t_rec->values.fin)
set t_rec->values.script = t_rec->prompts.template
 
select into "nl:"
from
	encounter e
plan e
	where e.encntr_id = t_rec->values.encntr_id
head report
	cnt = 1
detail
	st_request->visit_cnt = cnt
	stat = alterlist(st_request->visit,cnt)
	st_request->visit[cnt].encntr_id = e.encntr_id
 
	st_request->person_cnt = cnt
	stat = alterlist(st_request->person,cnt)
	st_request->person[cnt].person_id = e.person_id
 
	st_request->prsnl_cnt = cnt
	stat = alterlist(st_request->prsnl,cnt)
	st_request->prsnl[cnt].prsnl_id = reqinfo->updt_id
with nocounter 
 
set debug_ind = 1 

set t_rec->values.st_execution = build2( ^execute ^
										,trim(t_rec->values.script)
										,^ with replace("REQUEST",st_request),^
										,^ replace("REPLY",st_reply) go^)

call echorecord(st_request) 

call parser(t_rec->values.st_execution)

set html_output = get_html_template(concat(trim(cnvtlower(curprog)),".html"))

call echorecord(st_reply) 
call echorecord(t_rec) 
call echo(build2("html_output=",html_output))

set html_output = replace(html_output,"%%REPLACE_REPLY_TEXT%%",st_reply->text)
set html_output = replace(html_output,"%%REPLACE_ST_REPLY_%%",cnvtrectojson(st_reply))

call put_html_output(t_rec->prompts.outdev,st_reply->text)

end go
