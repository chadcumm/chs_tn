/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Chad Cummings
	Date Written:
	Solution:
	Source file name:	cov_hstrop_process_ops.prg
	Object name:		cov_hstrop_process_ops
	Request #:
 
	Program purpose:
 
	Executing from:		CCL
 
  Special Notes:      Additional Scripts:
 
  						cov_troponin_util
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
001   	12/11/2021  Chad Cummings			initial build
******************************************************************************/
 
drop program cov_hstrop_process_ops:dba go
create program cov_hstrop_process_ops:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
 
call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))
 
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
) with protect
endif
 
call set_codevalues(null)
call check_ops(null)
 
execute cov_troponin_util
 
;free set t_rec
record t_rec
(
	1 cnt			= i4
	1 prompts
	 2 outdev		= vc
	1 files
	 2 records_attachment		= vc
	1 dminfo
	 2 info_domain	= vc
	 2 info_name	= vc
	1 cons
	 2 run_dt_tm 				= dq8
	 2 hsTrop_cd				= f8
	 2 order_dt_tm_margin_min	= i4
	1 dates
	 2 start_dt_tm	= dq8
	 2 stop_dt_tm	= dq8
	1 ord_process_ind = i2
	1 task_cnt = i2
	1 task_qual[*]
	 2 task_id = f8
	 2 current_task_dt_tm = dq8
	 2 order_start_dt_tm = dq8
	 2 new_task_dt_tm = dq8
	1 event_cnt     = i4
	1 event_list[*]
	 2 event_id		= f8
	 2 new_event_id = f8
	 2 encntr_id	= f8
	 2 person_id    = f8
	 2 name_full_formatted = vc
	 2 initial
	 	3 order_id		= f8
	 	3 collect_dt_tm = dq8
	 2 one_hour
	    3 needed_ind 	= i4
	 	3 order_id 		= f8
		3 collect_dt_tm = dq8
		3 target_dt_tm 	= dq8
		3 cancel_ind	= i4
		3 run_dt_tm_diff = i4
		3 order_now_ind = i4
	 2 three_hour
	    3 needed_ind 	= i4
	 	3 order_id 		= f8
		3 collect_dt_tm = dq8
		3 target_dt_tm 	= dq8
		3 cancel_ind    = i4
		3 run_dt_tm_diff = i4
		3 order_now_ind	= i4
) with protect
 
 
set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
 
set t_rec->dminfo.info_domain	= "COV_DEV_OPS"
set t_rec->dminfo.info_name		= concat(trim(cnvtupper(curprog)),":","start_dt_tm")
set t_rec->dates.start_dt_tm 	= get_dminfo_date(t_rec->dminfo.info_domain,t_rec->dminfo.info_name)
set t_rec->dates.stop_dt_tm 	= cnvtdatetime(curdate,curtime3)
set t_rec->cons.run_dt_tm		= cnvtdatetime(curdate,curtime3)
 
if (t_rec->dates.start_dt_tm = 0.0)
	call writeLog(build2("->No start date and time found, setting to go live date"))
	set t_rec->dates.start_dt_tm = cnvtdatetime(curdate,curtime3)
endif
 
 
set t_rec->cons.hsTrop_cd = GethsTropAlgEC(null)
set t_rec->cons.order_dt_tm_margin_min = GethsTropAlgOrderMargin(null)
 
declare order_comment = vc with noconstant(" "), protect
 
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))
 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Getting hsTroponin Algorithms on active patients ***"))
 
select into "nl:"
from
	 encntr_domain ed
	,encounter e
	,person p
	,clinical_event ce
	,ce_blob ceb
plan ed
	where ed.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
	and   ed.active_ind = 1
join e
	where e.encntr_id = ed.encntr_id
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
	call writeLog(build2("->found ce.parent_event_id=",ce.parent_event_id))
	call writeLog(build2("->found p.name_full_formatted=",p.name_full_formatted))
	call writeLog(build2("->found e.encntr_id=",e.encntr_id))
	call writeLog(build2("->found p.person_id=",p.person_id))
 
	t_rec->event_cnt = (t_rec->event_cnt + 1)
	stat = alterlist(t_rec->event_list,t_rec->event_cnt)
	t_rec->event_list[t_rec->event_cnt].encntr_id = e.encntr_id
	t_rec->event_list[t_rec->event_cnt].event_id = ce.parent_event_id
	t_rec->event_list[t_rec->event_cnt].person_id = p.person_id
	t_rec->event_list[t_rec->event_cnt].name_full_formatted = p.name_full_formatted
with nocounter
 
if (t_rec->event_cnt = 0)
	set reply->status_data.status = "Z"
	go to exit_script
endif
 
call writeLog(build2("-------------------------------------------------------------"))
call writeLog(build2("- Getting individual algorithm results"))
for (i=1 to t_rec->event_cnt)
 
	call addhsTropDataRec(1)
	call writeLog(build2("->getting event_id=",t_rec->event_list[i].event_id))
	set stat = cnvtjsontorec(GethsTropAlgDataByEventID(t_rec->event_list[i].event_id))
	if (validate(hsTroponin_data))
		set t_rec->event_list[i].initial.order_id				= hsTroponin_data->initial.order_id
		set t_rec->event_list[i].initial.collect_dt_tm			= hsTroponin_data->initial.collect_dt_tm
		set t_rec->event_list[i].one_hour.collect_dt_tm			= hsTroponin_data->one_hour.collect_dt_tm
		set t_rec->event_list[i].one_hour.needed_ind			= hsTroponin_data->one_hour.needed_ind
		set t_rec->event_list[i].one_hour.order_id				= hsTroponin_data->one_hour.order_id
		set t_rec->event_list[i].one_hour.target_dt_tm			= hsTroponin_data->one_hour.target_dt_tm
		set t_rec->event_list[i].three_hour.collect_dt_tm		= hsTroponin_data->three_hour.collect_dt_tm
		set t_rec->event_list[i].three_hour.needed_ind			= hsTroponin_data->three_hour.needed_ind
		set t_rec->event_list[i].three_hour.order_id			= hsTroponin_data->three_hour.order_id
		set t_rec->event_list[i].three_hour.target_dt_tm		= hsTroponin_data->three_hour.target_dt_tm
	endif
endfor
 
call writeLog(build2("* END   Getting hsTroponin Algorithms on active patients ***"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Determine Orders to Create *************************"))
 
for (i=1 to t_rec->event_cnt)
	;Check one hour to see if it's needed and within the time margin
	if ((t_rec->event_list[i].one_hour.needed_ind = 1) and (t_rec->event_list[i].one_hour.order_id = 0.0))
		call writeLog(build2("-one_hour order still needed=",t_rec->event_list[i].one_hour.order_id))
		set t_rec->event_list[i].one_hour.run_dt_tm_diff
			= datetimediff(t_rec->event_list[i].one_hour.target_dt_tm,t_rec->cons.run_dt_tm,4)
		call writeLog(build2("-one_hour.run_dt_tm_diff=",t_rec->event_list[i].one_hour.run_dt_tm_diff))
 
		if (t_rec->event_list[i].one_hour.run_dt_tm_diff < t_rec->cons.order_dt_tm_margin_min)
			set t_rec->event_list[i].one_hour.order_now_ind = 1
		endif
	endif
 
	if ((t_rec->event_list[i].three_hour.needed_ind = 1) and (t_rec->event_list[i].three_hour.order_id = 0.0))
		call writeLog(build2("-one_hour order still needed=",t_rec->event_list[i].three_hour.order_id))
		set t_rec->event_list[i].three_hour.run_dt_tm_diff
			= datetimediff(t_rec->event_list[i].three_hour.target_dt_tm,t_rec->cons.run_dt_tm,4)
		call writeLog(build2("-one_hour.run_dt_tm_diff=",t_rec->event_list[i].three_hour.run_dt_tm_diff))
 
		if (t_rec->event_list[i].three_hour.run_dt_tm_diff < t_rec->cons.order_dt_tm_margin_min)
			set t_rec->event_list[i].three_hour.order_now_ind = 1
		endif
	elseif ((t_rec->event_list[i].three_hour.needed_ind = 1) and (t_rec->event_list[i].three_hour.order_id > 0.0))
		call writeLog(build2("-three_hour order still needed and active=",t_rec->event_list[i].three_hour.order_id))
		set t_rec->event_list[i].three_hour.run_dt_tm_diff
			= datetimediff(t_rec->cons.run_dt_tm,t_rec->event_list[i].initial.collect_dt_tm,4)
		call writeLog(build2("-three_hour.run_dt_tm_diff=",t_rec->event_list[i].three_hour.run_dt_tm_diff))

		if (t_rec->event_list[i].three_hour.run_dt_tm_diff > t_rec->cons.order_dt_tm_margin_max)
			if (GetOrderStatus(t_rec->event_list[i].three_hour.order_id) in(uar_get_code_by("MEANING",6004,"ORDERED")))
				set t_rec->event_list[i].three_hour.cancel_ind = 1
				set t_rec->event_list[i].three_hour.needed_ind = 0
			endif
		endif

	endif
endfor
 
call writeLog(build2("* END   Determine Orders to Create *************************"))
call writeLog(build2("************************************************************"))
 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Creating Required Orders ***************************"))
 
call writeLog(build2("t_rec->event_cnt=",t_rec->event_cnt))
for (ii=1 to t_rec->event_cnt)
 
 /* for testing only, restricts to a single patient
 if (t_Rec->event_list[ii].person_id =    20743786.00)
 /* for testing only, restricts to a single patient */
 
	call writeLog(build2("t_rec->event_list ii=",ii))
	if ((t_rec->event_list[ii].one_hour.order_now_ind = 1) or (t_rec->event_list[ii].three_hour.order_now_ind = 1)
		or (t_rec->event_list[ii].one_hour.cancel_ind = 1) or (t_rec->event_list[ii].three_hour.cancel_ind = 1))
 
		call addhsTropDataRec(1)
		call writeLog(build2("->getting event_id=",t_rec->event_list[ii].event_id))
		set stat = cnvtjsontorec(GethsTropAlgDataByEventID(t_rec->event_list[ii].event_id))
 		set hsTroponin_data->algorithm_info.process_dt_tm = cnvtdatetime(curdate,curtime3)
 
 		call writeLog(build2("t_rec->event_list three hour check ii=",ii))
		call writeLog(build2("-patient=",t_rec->event_list[ii].name_full_formatted))
		call writeLog(build2("-event_id=",t_rec->event_list[ii].event_id))
 
		if (t_rec->event_list[ii].one_hour.order_now_ind = 1)
 
 			;add one hour troponin
			if (SetupNewhsTropOrder(t_rec->event_list[ii].person_id,t_rec->event_list[ii].encntr_id) = FALSE)
				call writeLog("unable to setup request for hour one order")
				go to exit_script
			endif
 
		 	set stat = UpdateOrderDetailDtTm("REQSTARTDTTM",hsTroponin_data->one_hour.target_dt_tm)
		 	set stat = UpdateOrderDetailValueCd("COLLPRI",value(uar_get_code_by("MEANING",2054,"STAT")))
			set order_comment = build2(	 "Ordered automatically per rapid screening protocols. "
													,"Initiated from accession "
													,trim(GetOrderAccessionbyOrderID(hsTroponin_data->initial.order_id))
													," ["
													,GethsTropAlgDescription(null)
													,"]"
									)
			set stat = AddhsTropOrderComment(order_comment)
			set hsTroponin_data->one_hour.order_id = CallNewhsTropOrderServer(null)
 
			if (hsTroponin_data->one_hour.order_id > 0.0)
 
				set t_rec->ord_process_ind = 1
 
				if (AddOrderTohsTropList(hsTroponin_data->one_hour.order_id) = FALSE)
					call writeLog("unable to add one hour order_id to list")
					go to exit_script
				endif
			else
				call writeLog(build2("* FAILED TO ADD ONE HOUR ORDER"))
				set t_rec->ord_process_ind = 1
			endif
 
			;add one hour ecg
		 if (hsTroponin_data->one_hour.ecg_order_id = 0.0)
			if (SetupNewECGOrder(t_rec->event_list[ii].person_id,t_rec->event_list[ii].encntr_id) = FALSE)
				call writeLog("unable to setup request for hour one ECG order")
				go to exit_script
			else
				call writeLog("setup request for hour one ECG order")
			endif
 
	 		set stat = UpdateECGOrderDetailDtTm("REQSTARTDTTM",hsTroponin_data->one_hour.target_dt_tm)
	 		set stat = UpdateECGOrderDetailValueCd("PRIORITY",value(uar_get_code_by("MEANING",1304,"STAT")))
			set order_comment = build2(	 "Ordered automatically per rapid screening protocols. "
													,"Initiated from accession "
													,trim(GetOrderAccessionbyOrderID(hsTroponin_data->initial.order_id))
													," ["
													,GethsTropAlgDescription(null)
													,"]"
									)
			set stat = AddECGOrderComment(order_comment)
			set hsTroponin_data->one_hour.ecg_order_id = CallNewECGOrderServer(null)
 
			if (hsTroponin_data->one_hour.ecg_order_id > 0.0)
				call writeLog("created one hour ECG order")
				if (AddOrderTohsTropList(hsTroponin_data->one_hour.ecg_order_id) = FALSE)
					call writeLog("unable to add one hour ecg_order_id to list")
					go to exit_script
				endif
			else
				call writeLog("did not create one hour ECG order")
			endif
 		 endif
		endif ;one_hour order now
 
		if (t_rec->event_list[ii].three_hour.order_now_ind = 1)
 			call writeLog(build2("--three_hour.order_now_ind=",t_rec->event_list[ii].three_hour.order_now_ind ))
 
			if (SetupNewhsTropOrder(t_rec->event_list[ii].person_id,t_rec->event_list[ii].encntr_id) = FALSE)
				call writeLog("unable to setup request for hour one order")
				go to exit_script
			endif
 
 			call writeLog(build2("---new order setup complete"))
 
		 	set stat = UpdateOrderDetailDtTm("REQSTARTDTTM",hsTroponin_data->three_hour.target_dt_tm)
		 	set stat = UpdateOrderDetailValueCd("COLLPRI",value(uar_get_code_by("MEANING",2054,"STAT")))
 			set order_comment = build2(	 "Ordered automatically per rapid screening protocols. "
													,"Initiated from accession "
													,trim(GetOrderAccessionbyOrderID(hsTroponin_data->initial.order_id))
													," ["
													,GethsTropAlgDescription(null)
													,"]"
									)
			set stat = AddhsTropOrderComment(order_comment)
			call writeLog(build2("---new order details set complete"))
 
			set hsTroponin_data->three_hour.order_id = CallNewhsTropOrderServer(null)
 
			if (hsTroponin_data->three_hour.order_id > 0.0)
 
				set t_rec->ord_process_ind = 1
 
				if (AddOrderTohsTropList(hsTroponin_data->three_hour.order_id) = FALSE)
					call writeLog("unable to add one hour order_id to list")
					go to exit_script
				endif
			else
				call writeLog(build2("* FAILED TO ADD THREE HOUR ORDER"))
				set t_rec->ord_process_ind = 1
			endif
			
		if (hsTroponin_data->three_hour.ecg_order_id = 0.0)
			if (SetupNewECGOrder(t_rec->event_list[ii].person_id,t_rec->event_list[ii].encntr_id) = FALSE)
				call writeLog("unable to setup request for hour three ECG order")
				go to exit_script
			else
				call writeLog("setup request for hour three ECG order")
			endif
 
	 		set stat = UpdateECGOrderDetailDtTm("REQSTARTDTTM",hsTroponin_data->three_hour.target_dt_tm)
	 		set stat = UpdateECGOrderDetailValueCd("PRIORITY",value(uar_get_code_by("MEANING",1304,"STAT")))
			set order_comment = build2(	 "Ordered automatically per rapid screening protocols. "
													,"Initiated from accession "
													,trim(GetOrderAccessionbyOrderID(hsTroponin_data->initial.order_id))
													," ["
													,GethsTropAlgDescription(null)
													,"]"
									)
			set stat = AddECGOrderComment(order_comment)
			set hsTroponin_data->three_hour.ecg_order_id = CallNewECGOrderServer(null)
 
			if (hsTroponin_data->three_hour.ecg_order_id > 0.0)
				call writeLog("created three hour ECG order")
				if (AddOrderTohsTropList(hsTroponin_data->three_hour.ecg_order_id) = FALSE)
					call writeLog("unable to three  hour ecg_order_id to list")
					go to exit_script
				endif
			else
				call writeLog("did not create three hour ECG order")
			endif
 		 endif
		endif ;three_hour order now

		if (t_rec->event_list[ii].three_hour.cancel_ind = 1)
			set t_rec->ord_process_ind = 1
			execute cov_eks_trigger_by_o ^nl:^,^COV_EE_DISCONTINUE_ORD^,value(hsTroponin_data->three_hour.order_id)
			;set hsTroponin_data->three_hour.order_id = 0.0
			
	 		;start algorithm over again
			if (SetupNewhsTropOrder(t_rec->event_list[ii].person_id,t_rec->event_list[ii].encntr_id) = FALSE)
				call writeLog("unable to setup request for new order")
				go to exit_script
			endif
 
		 	set stat = UpdateOrderDetailDtTm("REQSTARTDTTM",cnvtdatetime(sysdate))
		 	set stat = UpdateOrderDetailValueCd("COLLPRI",value(uar_get_code_by("MEANING",2054,"STAT")))
			set order_comment = build2(	 "Restarted hs Troponin algorithm due to >6 hour collection time")
			set stat = AddhsTropOrderComment(order_comment)
			set new_order_id = CallNewhsTropOrderServer(null)			
		
			if (GetOrderStatus(t_rec->event_list[i].three_hour.ecg_order_id) in(uar_get_code_by("MEANING",6004,"ORDERED")))
				execute cov_eks_trigger_by_o ^nl:^,^COV_EE_DISCONTINUE_ORD^,value(hsTroponin_data->three_hour.ecg_order_id)
				;set hsTroponin_data->three_hour.ecg_order_id = 0.0
				
				if (SetupNewECGOrder(t_rec->event_list[ii].person_id,t_rec->event_list[ii].encntr_id) = FALSE)
					call writeLog("unable to setup request for hour three ECG order")
					go to exit_script
				else
					call writeLog("setup request for hour three ECG order")
				endif
	 
		 		set stat = UpdateECGOrderDetailDtTm("REQSTARTDTTM",cnvtdatetime(sysdate))
		 		set stat = UpdateECGOrderDetailValueCd("PRIORITY",value(uar_get_code_by("MEANING",1304,"STAT")))
				set order_comment = build2(	 "Restarted hs Troponin algorithm due to >6 hour collection time" )
				set stat = AddECGOrderComment(order_comment)
				set new_order_id = CallNewECGOrderServer(null)	
					
			endif
				
			set hsTroponin_data->algorithm_info.current_phase = "END"
			
		endif
		;add hsTroponin_data record structure to chart for tracking
		set hsTroponin_data->algorithm_info.process_dt_tm = cnvtdatetime(curdate,curtime3)
		set t_rec->event_list[ii].new_event_id = EnsurehsTropAlgData(
																	 hsTroponin_data->person_id
																	,hsTroponin_data->encntr_id
																	,t_rec->event_list[ii].event_id
																	,cnvtrectojson(hsTroponin_data)
																)
 
		call writeLog(cnvtrectojson(hsTroponin_data))
 
	endif
 
 
 /* for testing only, restricts to a single patient *
 endif
 /* for testing only, restricts to a single patient */
endfor
 
call writeLog(build2("* END   Creating Required Orders ***************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Tasks **************************************"))

select into "nl:"
from
	 orders o
	,order_catalog oc
	,order_container_r ocr
	,task_activity ta
	,person p
	,encounter e
	,encntr_alias ea
plan oc
	where oc.description = "Troponin HS"
join o
	where o.catalog_cd = oc.catalog_cd
	and   o.order_status_cd in(value(uar_get_code_by("MEANING",6004,"ORDERED")))
join ocr
	where ocr.order_id = o.order_id
join ta
	where ta.container_id = ocr.container_id
	and   ta.task_dt_tm >= cnvtdatetime(sysdate)
	and   ta.task_status_cd in(
										value(uar_get_code_by("MEANING",79,"PENDING"))
									)
join p
	where p.person_id = ta.person_id
join e
	where e.encntr_id = ta.encntr_id
join ea
	where ea.encntr_id = ta.encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
order by
	ta.task_id
head report
	null
head ta.task_id
	if (cnvtlookbehind("30,MIN",cnvtdatetime(ta.scheduled_dt_tm)) < cnvtdatetime(sysdate))
		t_rec->task_cnt = (t_rec->task_cnt + 1)
		stat = alterlist(t_rec->task_qual,t_rec->task_cnt)
		t_rec->task_qual[t_rec->task_cnt].task_id = ta.task_id
		t_rec->task_qual[t_rec->task_cnt].current_task_dt_tm = ta.task_dt_tm
		t_rec->task_qual[t_rec->task_cnt].new_task_dt_tm = cnvtdatetime(sysdate)
		call writeLog(build("person=",p.name_full_formatted))
		call writeLog(build("FIN=",ea.alias))
		call writeLog(build("location=",uar_get_code_display(e.loc_nurse_unit_cd)))
		call writeLog(build("scheduled_dt_tm=",format(ta.scheduled_dt_tm,"dd-mmm-yyyy hh:mm:ss zzz;;q")))
		call writeLog(build("current_dt_tm=",format(sysdate,"dd-mmm-yyyy hh:mm:ss zzz;;q")))
		call writeLog(build("difference=",datetimediff(ta.scheduled_dt_tm,cnvtdatetime(sysdate),4)))
	endif
with nocounter

for (i=1 to t_rec->task_cnt)
	set t_rec->ord_process_ind = 1
	update into task_activity set task_dt_tm = cnvtdatetime(t_rec->task_qual[i].new_task_dt_tm)
	where task_id = t_rec->task_qual[i].task_id
	commit 
endfor

call writeLog(build2("* END   Finding Tasks **************************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Creating Audit *************************************"))
	call writeAudit(build2(
							char(34),^ITEM^,char(34),char(44),
							char(34),^DESC^,char(34)
						))
for (i=1 to t_rec->cnt)
		call writeAudit(build2(
							char(34),t_rec->qual[i].a											,char(34),char(44),
							char(34),t_rec->qual[i].b											,char(34)
						))
 
endfor
call writeLog(build2("* END   Creating Audit *************************************"))
call writeLog(build2("************************************************************"))
 
 
set reply->status_data.status = "S"
#exit_script
 
if (reply->status_data.status in("Z","S"))
	call writeLog(build2("* START Set Date Range ************************************"))
	call set_dminfo_date(t_rec->dminfo.info_domain,t_rec->dminfo.info_name,t_rec->dates.stop_dt_tm)
	call writeLog(build2("* END Set Date Range ************************************v1"))
endif
;001 end
 
if (t_rec->ord_process_ind = 1)
	call addEmailLog("chad.cummings@covhlth.com")
endif
 
call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
call addAttachment(program_log->files.file_path, replace(t_rec->files.records_attachment,"cclscratch:",""))
execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"","CP"
;execute cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->files.records_attachment)
 
call writeLog(build2("_v1"))
 
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)
 
 
end
go
 
