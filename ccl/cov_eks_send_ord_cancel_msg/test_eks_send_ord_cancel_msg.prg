/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   cov_eks_send_ord_cancel_msg.prg
  Object name:        cov_eks_send_ord_cancel_msg
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
drop program test_eks_send_ord_cancel_msg:dba go
create program test_eks_send_ord_cancel_msg:dba

set retval = -1

free record t_rec
record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 organization_id = f8
	 2 org_name = vc
	 2 person_id = f8
	1 orders
	 2 order_id	= f8
	 2 mnemonic = vc
	 2 start_dt_tm = vc
	1 appointment 
	 2 type_cd = f8
	 2 type_display = vc
	1 message 
	 2 event_cd = f8
	 2 task_type_cd = f8
	 2 priority_cd = f8
	 2 save_to_chart_ind = i2
	 2 msg_sender_prsnl_id = f8
	 2 text = vc
	1 detail_cnt = i2
	1 detail_qual[*]
	 2 field_value = vc
	 2 field_name = vc
	 2 oe_field_id = f8
	1 no_show_ind = i2
	1 cancel_reason_1 = vc
	1 cancel_reason_2 = vc
	1 cancel_comment_1 = vc
	1 cancel_comment_2 = vc
	1 log_file = vc
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
	1 code_set = i4
	1 default_pool_id = f8
	1 pool_cnt = i2
	1 pool_pos = i2
	1 pool_qual[*]
	 2 code_value = f8
	 2 org_name = vc
	 2 org_id = f8
	 2 pool_name = vc
	 2 pool_id = f8
)

record 967503_request (
  1 message_list [*]
    2 draft_msg_uid = vc
    2 person_id = f8
    2 encntr_id = f8
    2 event_cd = f8
    2 task_type_cd = f8
    2 priority_cd = f8
    2 save_to_chart_ind = i2
    2 msg_sender_pool_id = f8
    2 msg_sender_person_id = f8
    2 msg_sender_prsnl_id = f8
    2 msg_subject = vc
    2 refill_request_ind = i2
    2 msg_text = gvc
    2 reminder_dt_tm = dq8
    2 due_dt_tm = dq8
    2 callerName = vc
    2 callerPhone = vc
    2 notify_info
      3 notify_pool_id = f8
      3 notify_prsnl_id = f8
      3 notify_priority_cd = f8
      3 notify_status_list [*]
        4 notify_status_cd = f8
        4 delay
          5 value = i4
          5 unit_flag = i2
    2 action_request_list [*]
      3 action_request_cd = f8
    2 assign_prsnl_list [*]
      3 assign_prsnl_id = f8
      3 cc_ind = i2
      3 selection_nbr = i4
    2 assign_person_list [*]
      3 assign_person_id = f8
      3 cc_ind = i2
      3 selection_nbr = i4
      3 reply_allowed_ind = i2
    2 assign_pool_list [*]
      3 assign_pool_id = f8
      3 assign_prsnl_id = f8
      3 cc_ind = i2
      3 selection_nbr = i4
    2 encounter_class_cd = f8
    2 encounter_type_cd = f8
    2 org_id = f8
    2 get_best_encounter = i2
    2 create_encounter = i2
    2 proposed_order_list [*]
      3 proposed_order_id = f8
    2 event_id = f8
    2 order_id = f8
    2 encntr_prsnl_reltn_cd = f8
    2 facility_cd = f8
    2 send_to_chart_ind = i2
    2 original_task_uid = vc
    2 rx_renewal_list [*]
      3 rx_renewal_uid = vc
      3 rx_renewal_id = f8
    2 task_status_flag = i2
    2 task_activity_flag = i2
    2 event_class_flag = i2
    2 attachments [*]
      3 name = c255
      3 location_handle = c255
      3 media_identifier = c255
      3 media_version = i4
    2 sender_email = c320
    2 assign_emails [*]
      3 email = c320
      3 cc_ind = i2
      3 selection_nbr = i4
      3 first_name = c100
      3 last_name = c100
      3 display_name = c100
    2 sender_email_display_name = c100
    2 result_set_id = f8
    2 portal_users [*]
      3 portal_user_uuid = c128
    2 responsible_prsnl_id = f8
    2 rx_change_ids [*]
      3 rx_change_id = f8
    2 text_format_cd = f8
    2 task_subtype_cd = f8
  1 action_dt_tm = dq8
  1 action_tz = i4
  1 skip_validation_ind = i2
)

/*
>>>Begin EchoRecord 967503_REPLY   ;967503_REPLY
 1 STATUS_DATA
  2 STATUS=VC1   {S}
  2 SUBEVENTSTATUS[0,0*]
 1 INVALID_RECEIVERS[0,0*]
 1 NOTIFICATIONS[1,1*]
  2 TASK_ID=F8   {1674354887.0000000000                   }
  2 EVENT_ID=F8   {1587122790.0000000000                   }
>>>End EchoRecord 967503_REPLY Varchar=1, Varlist=1, Fixsize=48, Varsize=33
*/


set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid
set t_rec->orders.order_id					= link_orderid

set t_rec->message.event_cd					= uar_get_code_by("DISPLAY",72,"Phone Msg")
set t_rec->message.priority_cd				= uar_get_code_by("MEANING",1304,"ROUTINE")
set t_rec->message.task_type_cd				= uar_get_code_by("MEANING",6026,"PHONE MSG")
set t_rec->message.msg_sender_prsnl_id		= 1.0
set t_rec->message.save_to_chart_ind		= 1

select into "nl:"
from
	 code_value_set cvs
	,code_value cv
plan cvs
	where cvs.definition = "Appointment Cancelation Pool-Org"
join cv
	where cv.code_set = cvs.code_set
	and   cv.active_ind = 1 
head report
	t_rec->code_set = cvs.code_set
	cnt = 0
detail
	cnt = (cnt + 1)
	stat = alterlist(t_rec->pool_qual,cnt)
	t_rec->pool_qual[cnt].code_value = cv.code_value
	t_rec->pool_qual[cnt].org_name = trim(cv.definition)
	t_rec->pool_qual[cnt].pool_name = trim(cv.description)
foot report
	t_rec->pool_cnt = cnt
with nocounter, nullreport

select into "nl:"
from
	organization o
	,(dummyt d1 with seq=t_rec->pool_cnt)
plan d1
join o
	where o.org_name = t_rec->pool_qual[d1.seq].org_name
	and o.active_ind = 1
detail
	t_rec->pool_qual[d1.seq].org_id = o.organization_id
with nocounter

select into "nl:"
from
	prsnl_group pg
	,(dummyt d1 with seq=t_rec->pool_cnt)
plan d1
join pg
	where pg.prsnl_group_name = t_rec->pool_qual[d1.seq].pool_name
detail
	t_rec->pool_qual[d1.seq].pool_id = pg.prsnl_group_id
with nocounter

select into "nl:"
from 
	prsnl_group pg
plan pg
	where pg.prsnl_group_name = "FSR Orders and Documents Corrections"
	and   pg.active_ind = 1
order by
	 pg.prsnl_group_name
	,pg.beg_effective_dt_tm desc
head pg.prsnl_group_name
	t_rec->default_pool_id = pg.prsnl_group_id
with nocounter


set t_rec->default_pool_id = 0

set t_rec->log_file	= concat(
									 trim(cnvtlower(curprog))
									,^_^
									,trim(format(cnvtdatetime(curdate,curtime3),"yyyy_mm_dd_hhmmss;;q"))
									,^.dat^)

set rhead 	= concat (	
						"{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss MS Sans Serif;}" ,
  						"}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134" 
  					 )

set reol 	= "\par "
set rtab 	= "\tab "
set wr 		= "\plain \f0 \fs18 \cb2 "
set wb 		= "\plain \f0 \fs18 \b \cb2 "
set hi 		= "\pard\fi-2340\li2340 "
set rtfeof 	= "}"
set i = 0
 									  
if (t_rec->message.event_cd <= 0.0)
	set t_rec->log_message = concat("message event_cd not found")
	go to exit_script
endif

if (t_rec->message.priority_cd <= 0.0)
	set t_rec->log_message = concat("message priority_cd not found")
	go to exit_script
endif

if (t_rec->message.task_type_cd <= 0.0)
	set t_rec->log_message = concat("message task_type_cd not found")
	go to exit_script
endif

/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */

set t_rec->return_value = "FALSE"

select into "nl:"
from
	orders o
	,order_detail od
	,order_entry_fields oef
plan o
	where o.order_id = t_rec->orders.order_id
join od
	where od.order_id = o.order_id
join oef
	where oef.oe_field_id = od.oe_field_id	
order by 
	 o.order_id
	,od.oe_field_id
	,od.action_sequence desc
head report
	cnt = 0
head o.order_id
	t_rec->orders.mnemonic = o.order_mnemonic
	t_rec->patient.encntr_id = o.originating_encntr_id
	t_rec->orders.start_dt_tm = format(o.current_start_dt_tm,"mm/dd/yyyy hh:mm;;q")
head od.oe_field_id
	cnt = (cnt + 1)
	stat = alterlist(t_rec->detail_qual,cnt)
	t_rec->detail_qual[cnt].field_name = oef.description
	t_rec->detail_qual[cnt].field_value = od.oe_field_display_value
	t_rec->detail_qual[cnt].oe_field_id = od.oe_field_id
foot report
	t_rec->detail_cnt = cnt
with nocounter


select
                o.order_id
                , scheduled_ind = if (sea.sch_attach_id > 0.0) 1 else 0 endif
                , cancel_reason = trim(sed.oe_field_display_value)
                , cancel_reason2 = trim(uar_get_code_display(seva.sch_reason_cd))
                , comment1 = replace(replace(trim(sed2.oe_field_display_value), char(10), ""), char(13), "")
                , comment2 = replace(replace(trim(lt.long_text), char(10), ""), char(13), "")
from
                ORDERS o
                
                , (left join SCH_EVENT_ATTACH sea on sea.order_id = o.order_id
                                and sea.sch_event_id > 0.0
                                and sea.attach_type_cd = 10473.00 ; order
                                and sea.active_ind = 1)
                                
                , (left join SCH_APPT sa on sa.sch_event_id = sea.sch_event_id
                                and sa.role_meaning = "PATIENT"
                                and sa.active_ind = 1)
                                
                , (left join SCH_EVENT_ACTION seva on seva.sch_event_id = sea.sch_event_id
                                and seva.schedule_id = sa.schedule_id
                                and seva.sch_action_cd = 4518.00 ; cancel
                                and seva.active_ind = 1)
                                
                , (left join SCH_EVENT_DETAIL sed on sed.sch_event_id = sea.sch_event_id
                                and sed.oe_field_meaning_id in (1105.00) ; cancel reason
                                and sed.active_ind = 1)
                                
                , (left join SCH_EVENT_DETAIL sed2 on sed2.sch_event_id = sea.sch_event_id
                                and sed2.oe_field_meaning_id in (2085.00) ; comment
                                and sed2.active_ind = 1)
                                
                , (left join SCH_EVENT_COMM sec on sec.sch_event_id = sea.sch_event_id
                                and sec.sch_action_id = seva.sch_action_id
                                and sec.active_ind = 1)
                                
                , (left join LONG_TEXT lt on lt.long_text_id = sec.text_id)
                
                , (left join SCH_ENTRY se on se.sch_event_id = sea.sch_event_id)
                
where
	o.order_id = t_rec->orders.order_id
detail
	call echo(build2("cancel_reason=",cancel_reason))
	call echo(build2("cancel_reason2=",cancel_reason2))
	
	call echo(build2("comment1=",comment1))
	call echo(build2("comment2=",comment2))
	if (cancel_reason > " ")
		t_rec->cancel_reason_1	= cancel_reason
	endif
	
	if (cancel_reason2 > " ")
		t_rec->cancel_reason_2	= cancel_reason2
	endif
	
	if (comment1 > " ")
		t_rec->cancel_comment_1	= comment1
	endif
	
	if (comment2 > " ")
		t_rec->cancel_comment_2	= comment2
	endif
	
	if (t_rec->patient.encntr_id = 0.0)
		t_rec->patient.encntr_id = se.encntr_id
	endif
	if (t_rec->patient.encntr_id = 0.0)
		t_rec->patient.encntr_id = sa.encntr_id
	endif
	
	
with nocounter  

select
	se.sch_state_cd,se.*
from
	 orders o
	,sch_event_attach sea 
	,sch_event se
plan o	
	where o.order_id = t_rec->orders.order_id
join sea
	where sea.order_id = o.order_id
join se
	where se.sch_event_id = sea.sch_event_id
detail
	if (uar_get_code_display(se.sch_state_cd) = "No Show")
		t_rec->no_show_ind = 1
		t_rec->cancel_reason_1 = build2("No Show ",t_rec->cancel_reason_1)
	endif
with nocounter,uar_code(d),format(date,";;q")

/*
if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif
*/

select into "nl:"
from
	 encounter e
	,organization o
plan e
	where e.encntr_id = t_rec->patient.encntr_id
join o
	where o.organization_id = e.organization_id
order by
	e.encntr_id
head e.encntr_id
	t_rec->patient.organization_id = o.organization_id
	t_rec->patient.org_name = o.org_name
with nocounter

set stat = alterlist(967503_request->message_list,1) 
set 967503_request->message_list[1].person_id 							= t_rec->patient.person_id 
set 967503_request->message_list[1].encntr_id 							= t_rec->patient.encntr_id 
set 967503_request->message_list[1].event_cd 							= t_rec->message.event_cd  
set 967503_request->message_list[1].task_type_cd 						= t_rec->message.task_type_cd
set 967503_request->message_list[1].priority_cd 						= t_rec->message.priority_cd
set 967503_request->message_list[1].save_to_chart_ind 					= t_rec->message.save_to_chart_ind
set 967503_request->message_list[1].msg_sender_prsnl_id 				= t_rec->message.msg_sender_prsnl_id
set 967503_request->message_list[1].msg_subject 						= concat("CANCELED - ",trim(t_rec->orders.mnemonic))
set 967503_request->message_list[1].callerName  						= "Scheduling" 

set stat = alterlist(967503_request->message_list[1].assign_pool_list,1) 
set t_rec->pool_pos = locateval(i,1,t_rec->pool_cnt,t_rec->patient.organization_id,t_rec->pool_qual[i].org_id)
if (t_rec->pool_pos > 0)
	set 967503_request->message_list[1].assign_pool_list[1].assign_pool_id 	= t_rec->pool_qual[t_rec->pool_pos].pool_id
else	
	set 967503_request->message_list[1].assign_pool_list[1].assign_pool_id = t_rec->default_pool_id
endif
set 967503_request->message_list[1].assign_pool_list[1].selection_nbr 	= 1 
set 967503_request->action_dt_tm = cnvtdatetime(curdate,curtime3) 
set 967503_request->action_tz = 126 
set 967503_request->skip_validation_ind = 1 

set 967503_request->message_list[1].msg_text = rhead 
set 967503_request->message_list[1].msg_text = build2(
														 967503_request->message_list[1].msg_text,wb
														,trim(t_rec->orders.mnemonic),^ scheduled for ^
														,trim(t_rec->orders.start_dt_tm), ^ has been canceled. ^,wr,reol,reol
														,^Cancel Reason: ^,trim(t_rec->cancel_reason_1),^ ^,trim(t_rec->cancel_reason_2),reol
														,^Comments: ^,trim(t_rec->cancel_comment_1),^ ^,trim(t_rec->cancel_comment_2),^ ^,reol,reol
														,^Order Details^,reol,reol
													  )
for (i=1 to t_rec->detail_cnt)
	set 967503_request->message_list[1].msg_text = build2(
														 967503_request->message_list[1].msg_text,^ ^
														;,trim(cnvtstring(i)),^. ^
														,t_rec->detail_qual[i].field_name,^: ^
														,t_rec->detail_qual[i].field_value,^ ^,reol
														)
endfor

set 967503_request->message_list[1].msg_text = build2(
														 967503_request->message_list[1].msg_text,^ ^
														,^Order ID: ^,cnvtstring(t_rec->orders.order_id) 
													  )
set 967503_request->message_list[1].msg_text = build2(
														 967503_request->message_list[1].msg_text,^ ^
														,rtfeof 
													  )

if (t_rec->pool_pos > 0)
	call echorecord(967503_request) 
	;set stat = tdbexecute(600005,967100,967503,"REC",967503_request,"REC",967503_reply) 
	call echorecord(967503_reply)
else
	set t_rec->return_value = "FALSE"
endif

if (967503_reply->status_data->status = "S")
	set t_rec->return_value = "TRUE"
endif


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
										trim(t_rec->log_message),";v2;",
										trim(cnvtupper(t_rec->return_value)),":",
										trim(cnvtstring(t_rec->patient.person_id)),"|",
										trim(cnvtstring(t_rec->patient.encntr_id)),"|"
									)
call echorecord(t_rec)

/* logging
if (validate(request))
	call echojson(request,concat(^cclscratch:^,t_rec->log_file),1)
endif

if (validate(967503_request))
	call echojson(967503_request,concat(^cclscratch:^,t_rec->log_file),1)
endif

if (validate(967503_reply))
	call echojson(967503_reply,concat(^cclscratch:^,t_rec->log_file),1)
endif
call echojson(t_rec,concat(^cclscratch:^,t_rec->log_file),1)

execute cov_astream_file_transfer ^cclscratch:^,value(t_rec->log_file),^CernerCCL^,^MV^
*/
set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1

end 
go
