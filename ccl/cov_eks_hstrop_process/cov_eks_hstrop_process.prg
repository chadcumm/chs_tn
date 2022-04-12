/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/11/2021
  Solution:
  Source file name:   cov_eks_hstrop_process.prg
  Object name:        cov_eks_hstrop_process
  Request #:
 
  Program purpose:
 
  Executing from:     CCL
 
  Special Notes:      Additional Scripts:
  						cov_eks_trigger_by_o
  						cov_troponin_util 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   12/11/2021  Chad Cummings			initial build
******************************************************************************/
drop program cov_eks_hstrop_process:dba go
create program cov_eks_hstrop_process:dba
 
set retval = -1
 
 
record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	 2 order_id = f8
	 2 clinical_event_id = f8
	1 algorithm_data
	 2 linked_eventid = f8
	 2 new_eventid = f8
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
) with protect
 
declare add_log_message(vMessage = vc) = null
 
declare order_comment = vc with noconstant(" "), protect
 
subroutine add_log_message(vMessage)
	call echo(vMessage)
	set t_rec->log_message = concat(
										trim(t_rec->log_message),";",
										trim(vMessage)
									)
end ;add_log_message
 
call add_log_message("v1")
 
set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid
 
set t_rec->patient.clinical_event_id		= link_clineventid
 
if (t_rec->patient.encntr_id <= 0.0)
	call add_log_message("link_encntrid not found")
	go to exit_script
endif
 
if (t_rec->patient.person_id <= 0.0)
	call add_log_message("link_personid not found")
	go to exit_script
endif
 
if (t_rec->patient.clinical_event_id <= 0.0)
	call add_log_message("link_clineventid not found")
	go to exit_script
endif
 
/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */
 
set t_rec->return_value = "FALSE"
 
execute cov_troponin_util
 
;get the order_id related to the incoming result
set t_rec->patient.order_id = GetOrderIDbyCEventID(t_rec->patient.clinical_event_id)
 
if (t_rec->patient.order_id = 0.0)
	call add_log_message("linked clinical event did not produce a valid order_id")
	go to exit_script
endif
 
call add_log_message(cnvtupper(GetOrderPowerPlanbyOrderID(t_rec->patient.order_id)))
 
;get the clinical event that holds the data for the instance of the algorithm.
;the order_list for each instance of the algo is searched
set t_rec->algorithm_data.linked_eventid = FindOrderInhsTrop(t_rec->patient.order_id)
 
 
;if no previous algo instance is found, setup a new one
if (t_rec->algorithm_data.linked_eventid = 0.0)
	call add_log_message("setting up new algorithm")
 
	;create the record structure
	call addhsTropDataRec(1)
 
	;add the person and encounter data, set the initial process date and time
	set hsTroponin_data->person_id = t_rec->patient.person_id
	set hsTroponin_data->encntr_id = t_rec->patient.encntr_id
	set hsTroponin_data->algorithm_info.process_dt_tm = cnvtdatetime(curdate,curtime3)
 	set hsTroponin_data->algorithm_info.current_phase = "INITIAL"
 
	;determine algorithm to use
	if (DeterminehsTropAlg(t_rec->patient.order_id) = FALSE)
		call add_log_message("unable to determine algorithm to use")
		go to exit_script
	else
		call add_log_message("determined algorithm to use")
	endif
 
	;set initial order and result data
	set hsTroponin_data->initial.order_id = t_rec->patient.order_id
	set hsTroponin_data->initial.result_event_id = GetEventIDbyCEventID(t_rec->patient.clinical_event_id)
	set hsTroponin_data->initial.result_parent_event_id = GetParentEventIDbyCEventID(t_rec->patient.clinical_event_id)
	set hsTroponin_data->initial.collect_dt_tm = GetCollectDtTmbyOrderID(hsTroponin_data->initial.order_id)
 	set hsTroponin_data->initial.result_val = GetResultbyCEventID(t_rec->patient.clinical_event_id)
 
 	;set future order dates and times
	if (SethsTropAlgNextTimes(hsTroponin_data->initial.order_id) = FALSE)
		call add_log_message("unable to set times for future orders")
		go to exit_script
	else
		call add_log_message("set times for future orders")
	endif
 	
 	call add_log_message(hsTroponin_data->algorithm_info.type)
 	call add_log_message(hsTroponin_data->algorithm_info.subtype)
 	call add_log_message(GetResultTextbyCEventID(GethsTropCEEventIDbyEventID(hsTroponin_data->initial.result_event_id)))
 	call add_log_message(GetResultTextbyEventID(hsTroponin_data->initial.result_event_id))
 	call add_log_message(GetResultTextbyCEventID(t_rec->patient.clinical_event_id))
 	call add_log_message(cnvtstring(t_rec->patient.clinical_event_id))
 	;process the result by calculating detla and running through algorithm
 	set hsTroponin_data->initial.normalcy = SetNormalcybyMilestone(value(hsTroponin_data->algorithm_info.current_phase))
 
	;add order_id to the associated list for searching
	if (AddOrderTohsTropList(hsTroponin_data->initial.order_id) = FALSE)
		call add_log_message("unable to add order_id to list")
		go to exit_script
	else
		call add_log_message("added initial order_id to list")
	endif
 
	;add result event_id to the associated list for searching
	if (AddEventTohsTropList(hsTroponin_data->initial.result_event_id) = FALSE)
		call add_log_message("unable to add result event_id to list")
		go to exit_script
	else
		call add_log_message("added result event_id to list")
	endif
 
	;add the result that shows the algorith result to the chart under the lab result
	set hsTroponin_data->algorithm_info.current_interp_id = AddAlgorithmCEResult(t_rec->patient.clinical_event_id)
 
	if (hsTroponin_data->algorithm_info.current_interp_id = FALSE)
		call add_log_message("unable to add alorithm result to chart")
		go to exit_script
	else
		call add_log_message("added algorithm result to chart")
		set hsTroponin_data->initial.interp_event_id = hsTroponin_data->algorithm_info.current_interp_id
	endif
 
	;create one hour order if necessary
	if ((hsTroponin_data->one_hour.needed_ind = 1) and (hsTroponin_data->algorithm_info.immediate_orders = 1))
		call add_log_message("creating hour one order")
		if (SetupNewhsTropOrder(t_rec->patient.person_id,t_rec->patient.encntr_id) = FALSE)
			call add_log_message("unable to setup request for hour one order")
			go to exit_script
		else
			call add_log_message("setup request for hour one order")
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
			call add_log_message("one hour order created")
			if (AddOrderTohsTropList(hsTroponin_data->one_hour.order_id) = FALSE)
				call add_log_message("unable to add one hour order_id to list")
				go to exit_script
			else
				call add_log_message("added one hour order_id to list")
			endif
		else
			call add_log_message("did not create one hour order")
		endif
	endif
 
	;add ECG if necessary
        if (    (hsTroponin_data->one_hour.needed_ind = 1) or
                    (    (hsTroponin_data->algorithm_info.type = "INPATIENT")
                    and (hsTroponin_data->algorithm_info.current_normalcy != "ABNORMAL")
                    )
            )
            call add_log_message("creating one hour ECG order")
            if (SetupNewECGOrder(t_rec->patient.person_id,t_rec->patient.encntr_id) = FALSE)
                call add_log_message("unable to setup request for hour one ECG order")
                go to exit_script
            else
                call add_log_message("setup request for hour one ECG order")
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
                call add_log_message("created one hour ECG order")
                if (AddOrderTohsTropList(hsTroponin_data->one_hour.ecg_order_id) = FALSE)
                    call add_log_message("unable to add one hour ecg_order_id to list")
                    go to exit_script
                endif
            else
                call add_log_message("did not create one hour ECG order")
            endif
        endif
 
	;create three hour order if necessary
	if ((hsTroponin_data->three_hour.needed_ind = 1) and (hsTroponin_data->algorithm_info.immediate_orders = 1))
		if (SetupNewhsTropOrder(t_rec->patient.person_id,t_rec->patient.encntr_id) = FALSE)
			call add_log_message("unable to setup request for hour one order")
			go to exit_script
		endif
 
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
 
		set hsTroponin_data->three_hour.order_id = CallNewhsTropOrderServer(null)
 
		if (hsTroponin_data->three_hour.order_id > 0.0)
			if (AddOrderTohsTropList(hsTroponin_data->three_hour.order_id) = FALSE)
				call add_log_message("unable to add three hour order_id to list")
				go to exit_script
			endif
		endif
 
		;add ECG if necessary
		if (	(hsTroponin_data->algorithm_info.type = "ED") or
					(	(hsTroponin_data->algorithm_info.type = "INPATIENT")
					and (hsTroponin_data->algorithm_info.current_normalcy != "ABNORMAL")
					)
			)
			call add_log_message("creating three hour ECG order")
			if (SetupNewECGOrder(t_rec->patient.person_id,t_rec->patient.encntr_id) = FALSE)
				call add_log_message("unable to setup request for hour three ECG order")
				go to exit_script
			else
				call add_log_message("setup request for hour three ECG order")
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
				call add_log_message("created three hour ECG order")
				if (AddOrderTohsTropList(hsTroponin_data->three_hour.ecg_order_id) = FALSE)
					call add_log_message("unable to add three hour ecg_order_id to list")
					go to exit_script
				endif
			else
				call add_log_message("did not create one hour ECG order")
			endif
		endif
	endif
 
	;add hsTroponin_data record structure to chart for tracking
	set t_rec->algorithm_data.new_eventid = EnsurehsTropAlgData(
																	 hsTroponin_data->person_id
																	,hsTroponin_data->encntr_id
																	,t_rec->algorithm_data.linked_eventid
																	,cnvtrectojson(hsTroponin_data)
																)
 
	/* REMOVE THIS AFTER TESTING, THIS REMOVES THE JSON TRACKING ITEM */
	;call RemovehsTropAlgData(hsTroponin_data->person_id,hsTroponin_data->encntr_id,t_rec->algorithm_data.new_eventid)
 
	call echorecord(hsTroponin_data)
else
	call add_log_message("updating existing algorithm")
	set stat = cnvtjsontorec(GethsTropAlgDataByEventID(t_rec->algorithm_data.linked_eventid))
 
	if (validate(hsTroponin_data) = FALSE)
		call add_log_message("unable to get algorithm information for supplied event")
		go to exit_script
	endif
 
	set hsTroponin_data->algorithm_info.current_phase = UpdateCurrentPhase(value(hsTroponin_data->algorithm_info.current_phase))
	set hsTroponin_data->algorithm_info.process_dt_tm = cnvtdatetime(curdate,curtime3)
 
	if (hsTroponin_data->algorithm_info.current_phase = "INITIAL")
		set stat = 0
		/* REVISIT THIS TO REPROCESS INITIAL RESULTS IF NEEDED
		set hsTroponin_data->initial.order_id = t_rec->patient.order_id
		set hsTroponin_data->initial.result_event_id = GetEventIDbyCEventID(t_rec->patient.clinical_event_id)
		set hsTroponin_data->initial.result_parent_event_id = GetParentEventIDbyCEventID(t_rec->patient.clinical_event_id)
		set hsTroponin_data->initial.collect_dt_tm = GetCollectDtTmbyOrderID(hsTroponin_data->initial.order_id)
 		set hsTroponin_data->initial.result_val = GetResultbyCEventID(t_rec->patient.clinical_event_id)
 		*/
	elseif (hsTroponin_data->algorithm_info.current_phase = "ONEHOUR")
		if (hsTroponin_data->one_hour.order_id != t_rec->patient.order_id)
			call add_log_message("order_id associated to result does not match algorithm order_id")
			go to exit_script
		else
			set hsTroponin_data->one_hour.result_event_id = GetEventIDbyCEventID(t_rec->patient.clinical_event_id)
			set hsTroponin_data->one_hour.result_parent_event_id = GetParentEventIDbyCEventID(t_rec->patient.clinical_event_id)
			set hsTroponin_data->one_hour.collect_dt_tm = GetCollectDtTmbyOrderID(hsTroponin_data->one_hour.order_id)
 			set hsTroponin_data->one_hour.result_val = GetResultbyCEventID(t_rec->patient.clinical_event_id)
 
 			;process the result by calculating detla and running through algorithm
 			set hsTroponin_data->one_hour.normalcy = SetNormalcybyMilestone(value(hsTroponin_data->algorithm_info.current_phase))
 
			;add result event_id to the associated list for searching
			if (AddEventTohsTropList(hsTroponin_data->one_hour.result_event_id) = FALSE)
				call add_log_message("unable to add result event_id to list")
				go to exit_script
			endif
 
			;add one hour ecg order if needed
			if (hsTroponin_data->three_hour.needed_ind = 1)
				call add_log_message("creating one hour ECG order")
				if (SetupNewECGOrder(t_rec->patient.person_id,t_rec->patient.encntr_id) = FALSE)
					call add_log_message("unable to setup request for hour one ECG order")
					go to exit_script
				else
					call add_log_message("setup request for hour one ECG order")
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
					call add_log_message("created three hour ECG order")
					if (AddOrderTohsTropList(hsTroponin_data->three_hour.ecg_order_id) = FALSE)
						call add_log_message("unable to add three hour ecg_order_id to list")
						go to exit_script
					endif
				else
					call add_log_message("did not create one hour ECG order")
				endif
			endif
 
 
 
		endif
	elseif (hsTroponin_data->algorithm_info.current_phase = "THREEHOUR")
		if (hsTroponin_data->three_hour.order_id != t_rec->patient.order_id)
			call add_log_message("order_id associated to result does not match algorithm order_id")
			go to exit_script
		else
			set hsTroponin_data->three_hour.result_event_id = GetEventIDbyCEventID(t_rec->patient.clinical_event_id)
			set hsTroponin_data->three_hour.result_parent_event_id = GetParentEventIDbyCEventID(t_rec->patient.clinical_event_id)
			set hsTroponin_data->three_hour.collect_dt_tm = GetCollectDtTmbyOrderID(hsTroponin_data->three_hour.order_id)
 			set hsTroponin_data->three_hour.result_val = GetResultbyCEventID(t_rec->patient.clinical_event_id)
 
			;process the result by calculating detla and running through algorithm
 			set hsTroponin_data->three_hour.normalcy = SetNormalcybyMilestone(value(hsTroponin_data->algorithm_info.current_phase))
 
			;add result event_id to the associated list for searching
			if (AddEventTohsTropList(hsTroponin_data->three_hour.result_event_id) = FALSE)
				call add_log_message("unable to add result event_id to list")
				go to exit_script
			endif
		endif
	else
		call add_log_message("could not determine phase, exiting")
		go to exit_script
	endif
 
	;Look through hsTroponin_data to see if there are orders to cancel (order_id and needed now is 0)
	if ((hsTroponin_data->one_hour.needed_ind = 0) and (hsTroponin_data->one_hour.order_id > 0.0))
		execute cov_eks_trigger_by_o ^nl:^,^COV_EE_DISCONTINUE_ORD^,value(hsTroponin_data->one_hour.order_id)
		set hsTroponin_data->one_hour.order_id = 0.0
	endif
 
	if ((hsTroponin_data->three_hour.needed_ind = 0) and (hsTroponin_data->three_hour.order_id > 0.0))
		execute cov_eks_trigger_by_o ^nl:^,^COV_EE_DISCONTINUE_ORD^,value(hsTroponin_data->three_hour.order_id)
		set hsTroponin_data->three_hour.order_id = 0.0
	endif
 
 	set hsTroponin_data->algorithm_info.current_interp_id = AddAlgorithmCEResult(t_rec->patient.clinical_event_id)
 	call add_log_message(build2("AddAlgorithmCEDeltaResult=",AddAlgorithmCEDeltaResult(t_rec->patient.clinical_event_id)))
 	call add_log_message(build2("AddAlgorithmCETimeResult=",AddAlgorithmCETimeResult(t_rec->patient.clinical_event_id)))
 	
	if (hsTroponin_data->algorithm_info.current_interp_id = FALSE)
		call add_log_message("unable to add alorithm result to chart")
		go to exit_script
	else
		if (hsTroponin_data->algorithm_info.current_phase = "INITIAL")
			set hsTroponin_data->initial.interp_event_id = hsTroponin_data->algorithm_info.current_interp_id
		elseif (hsTroponin_data->algorithm_info.current_phase = "ONEHOUR")
			set hsTroponin_data->one_hour.interp_event_id = hsTroponin_data->algorithm_info.current_interp_id
		elseif (hsTroponin_data->algorithm_info.current_phase = "THREEHOUR")
			set hsTroponin_data->three_hour.interp_event_id = hsTroponin_data->algorithm_info.current_interp_id
		endif
	endif
 
	;add hsTroponin_data record structure to chart for tracking
	set t_rec->algorithm_data.new_eventid = EnsurehsTropAlgData(
																	 hsTroponin_data->person_id
																	,hsTroponin_data->encntr_id
																	,t_rec->algorithm_data.linked_eventid
																	,cnvtrectojson(hsTroponin_data)
																)
 
endif
 
set t_rec->return_value = "TRUE"
 
#exit_script
 
if (validate(hsTroponin_data))
	call add_log_message(cnvtrectojson(hsTroponin_data))
	call echorecord(hsTroponin_data)
endif
 
if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
	set t_rec->log_misc1 = ""
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
else
	set t_rec->retval = 0
endif
 
call add_log_message(cnvtrectojson(t_rec))
 
call echorecord(t_rec)
 
set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1
 
end
go
 
