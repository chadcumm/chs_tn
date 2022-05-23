/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/02/2021
  Solution:
  Source file name:   cov_troponin_util.prg
  Object name:        cov_troponin_util
  Request #:
 
  Program purpose:
 
  Executing from:     CCL
 
  Special Notes:      Additional Required Scripts:
  													cov_mp_add_document
  													cov_mp_unchart_result
  													mp_event_detail_query
  													cov_eks_hstrop_ce_add
  													hstrop_ordrequest.json
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   12/02/2021  Chad Cummings			initial build
******************************************************************************/
drop program cov_troponin_util:dba go
create program cov_troponin_util:dba

execute cov_std_html_routines
execute cov_std_message_routines
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect
 
/* Global Variables */
declare	SystemPrsnlID = f8 with noconstant(1.0), protect, persist
 
/* Subroutines */
 
declare AddhsTropRefRec(freeRec=i2) = i2 with copy, persist
declare AddhsTropDataRec(freeRec=i2) = i2 with copy, persist
declare AddMPEventReply(null) = i2 with copy, persist

declare GetOrderStatus(vOrderID=f8) = f8 with copy, persist
 
declare GethsTropAlgEC(null) = f8 with copy, persist
declare GethsTropInterpEC(null) = f8 with copy, persist
declare GethsTropDeltaEC(null) = f8 with copy, persist
declare GethsTropTimeEC(null) = f8 with copy, persist
declare GethsTropAlgOrderMargin(null) = i4 with copy, persist
declare GethsTropAlgOrderMarginMax(null) = i4 with copy, persist
 
declare EnsurehsTropAlgData(vPersonID=f8,vEncntrID=f8,vEventID=f8,vJSON=vc) = f8 with copy, persist
declare RemovehsTropAlgData(vPersonID=f8,vEncntrID=f8,vEventID=f8) = f8 with copy, persist
declare AddhsTropAlgData(vPersonID=f8,vEncntrID=f8,vJSON=vc) = vc with copy, persist
 
declare RemovehsTropInterp(vPersonID=f8,vEncntrID=f8,vEventID=f8) = f8 with copy, persist
 
declare GethsTropAlgDescription(null) = vc with copy, persist
 
declare GethsTropAlgDataByEventID(vEventID=f8) = vc with copy, persist
 
declare GethsTropCEEventIDbyEventID(vEventID=f8) = f8 with copy, persist
 
declare GethsTropOpsDate(vScript) = vc with copy, persist
 
declare GetOrderSynonymbyOrderID(vOrderID=f8) = vc with copy, persist
declare GetOrderLocationbyOrderID(vOrderID=f8) = vc with copy, persist
declare GetOrderAccessionbyOrderID(vOrderID=f8) = vc with copy, persist

declare GetPatientLocationbyEncntrID(vEncntrID=f8) = vc with copy, persist
declare GetPatientTypebyEncntrID(vEncntrID=f8) = vc with copy, persist

declare isPatientinED(vEncntrID = f8) = i2 with copy, persist
declare isPatientOutpatient(vEncntrID = f8) = i2 with copy, persist
 
declare GetOrderPowerPlanbyOrderID(vOrderID=f8) = vc with copy, persist
 
declare GetOrderIDbyCEventID(vCEventID=f8) = f8 with copy, persist
declare GetEventIDbyCEventID(vCEventID=f8) = f8 with copy, persist
declare GetParentEventIDbyCEventID(vCEventID=f8) = f8 with copy, persist
declare GetEncntrIDbyOrderID(vOrderID=f8) = f8 with copy, persist
 
declare GetResultbyCEventID(vCEventID=f8) = f8 with copy, persist
declare GetResultTextbyCEventID(vCEventID=f8) = vc with copy, persist
declare GetResultTextbyEventID(vEventID=f8) = vc with copy, persist

declare SetNormalcybyMilestone(vMilestone=vc) = vc with copy, persist
declare UpdateCurrentPhase(vCurrentPhase=vc) = vc with copy, persist
 
declare IsSystemOrder(vOrderID=f8) = i2 with copy, persist
declare GetCollectDtTmbyOrderID(vOrderID=f8) = dq8 with copy, persist
declare GetCollectDtTmbyEventID(vEventID=f8) = dq8 with copy, persist
 
declare DeterminehsTropAlg(vOrderID=f8) = i2 with copy,persist
declare AddOrderTohsTropList(vOrderID=f8) = i2 with copy,persist
declare AddEventTohsTropList(vEventID=f8) = i2 with copy,persist
 
declare SethsTropAlgNextTimes(vOrderID=f8) = i2 with copy, persist
 
declare GethsTropAlgListByEncntrID(vEncntrID=f8) = vc with copy, persist
 
declare FindOrderInhsTrop(vOrderID=f8) = f8 with copy, persist
 
declare SetupNewhsTropOrder(vPersonID=f8,vEncntrID=f8) = i2 with copy, persist
declare UpdateOrderDetailDtTm(vOEFieldMeaning=vc,vDateTime=dq8) = i2 with copy, persist
declare UpdateOrderDetailValueCd(vOEFieldMeaning=vc,vValueCd=f8) = i2 with copy, persist
declare AddhsTropOrderComment(vComment=vc) = i2 with copy, persist
declare CallNewhsTropOrderServer(null) = f8 with copy, persist
 
declare SetupNewECGOrder(vPersonID=f8,vEncntrID=f8) = i2 with copy, persist
declare UpdateECGOrderDetailDtTm(vOEFieldMeaning=vc,vDateTime=dq8) = i2 with copy, persist
declare UpdateECGOrderDetailValueCd(vOEFieldMeaning=vc,vValueCd=f8) = i2 with copy, persist
declare AddECGOrderComment(vComment=vc) = i2 with copy, persist
declare CallNewECGOrderServer(null) = f8 with copy, persist
 
 
declare AddAlgorithmResult(vCEventID=f8) = i2 with copy, persist
declare AddAlgorithmCEResult(vCEventID=f8) = f8 with copy, persist
declare AddAlgorithmCEDeltaResult(vCEventID=f8) = f8 with copy, persist
declare AddAlgorithmCETimeResult(vCEventID=f8) = f8 with copy, persist
 

subroutine GetOrderStatus(vOrderID)

	declare vOrderStatusCd = f8 with noconstant(0.0)
	
	select into "nl:"
	from
		orders o
	plan o
		where o.order_id = vOrderID
	detail
		vOrderStatusCd = o.order_status_cd
	with nocounter
	
	return (vOrderStatusCd)

end ;GetOrderStatus

 
subroutine GethsTropOpsDate(vScript)
 
	declare vDateTime = dq8 with noconstant, protect
 
	select into "nl"
  	from dm_info di
 	 plan di
  	where di.info_domain = "COV_DEV_OPS"
  	  and di.info_name   = vScript
  	detail
  	  vDateTime = cnvtdatetime(di.info_date)
 	 with nocounter
 
	return (vDateTime)
end
 
subroutine GethsTropCEEventIDbyEventID(vEventID)
 
	declare vReturnCEEventID = f8 with noconstant(0.0)
 
	select into "nl:"
	from
		clinical_event ce3
	plan ce3
		where ce3.event_id = vEventID
		and   ce3.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
		and	  ce3.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
		and   ce3.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
		and   ce3.event_tag        != "Date\Time Correction"
		and   ce3.view_level = 1
	order by
		 ce3.event_id
		,ce3.valid_from_dt_tm
	head ce3.event_id
		vReturnCEEventID = ce3.clinical_event_id
	with nocounter
 
	return (vReturnCEEventID)
 
end ;GethsTropCEEventIDbyEventID
 
subroutine GethsTropAlgDescription(null)
 
	declare vReturnDescription = vc with noconstant("ERROR")
 
	if (validate(hsTroponin_data) = FALSE)
		return (vReturnDescription)
	else
		set vReturnDescription = cnvtlower(hsTroponin_data->algorithm_info.type)
		if (hsTroponin_data->algorithm_info.type = "ED")
			if (hsTroponin_data->algorithm_info.subtype = "LESS")
				set vReturnDescription = build2(vReturnDescription, "-symptoms < 3hr")
			else
				set vReturnDescription = build2(vReturnDescription, "-symptoms >= 3hr")
			endif
		endif
	endif
 
 	set vReturnDescription = build2(vReturnDescription, " (",trim(cnvtlower(hsTroponin_data->algorithm_info.current_phase)),")")
 
	return (vReturnDescription)
 
end
 
subroutine GetOrderAccessionbyOrderID(vOrderID)
 
	declare vReturnAccession = vc with noconstant("")
	select into "nl:"
	from
		 orders o
		,accession_order_r aor
		,accession a
	plan o
		where o.order_id = vOrderID
		and   o.order_id > 0.0
	join aor
		where aor.order_id = o.order_id
	join a
		where a.accession_id = aor.accession_id
	detail
		vReturnAccession = cnvtacc(a.accession)
	with nocounter
 
	return (vReturnAccession)
end
 
subroutine AddAlgorithmCEResult(vCEventID)
	declare vReturnSuccess = f8 with noconstant(FALSE)
	declare vInterpEC = f8 with constant(GethsTropInterpEC(null))
 
	if (validate(hsTroponin_data) = FALSE)
		return (vReturnSuccess)
	else
		free record cerequest
		free record cereply
%i cclsource:eks_rprq1000012.inc
		select into "nl:"
		from
			clinical_event ce
		plan ce
			where ce.clinical_event_id = vCEventID
		detail
			cerequest->ensure_type = 2
			cerequest->clin_event.view_level = 1
			cerequest->clin_event.person_id = ce.person_id
			cerequest->clin_event.encntr_id = ce.encntr_id
			cerequest->clin_event.contributor_system_cd = ce.contributor_system_cd
			cerequest->clin_event.event_class_cd = uar_get_code_by("MEANING",53,"TXT")
			cerequest->clin_event.event_cd = vInterpEC
			cerequest->clin_event.event_tag = hsTroponin_data->algorithm_info.current_full_normalcy
			cerequest->clin_event.event_start_dt_tm = ce.event_start_dt_tm
			cerequest->clin_event.event_end_dt_tm = ce.event_end_dt_tm
			cerequest->clin_event.event_end_dt_tm_os_ind = 1
			cerequest->clin_event.record_status_cd = uar_get_code_by("MEANING",48,"ACTIVE")
			cerequest->clin_event.result_status_cd = uar_get_code_by("MEANING",8,"AUTH")
			cerequest->clin_event.authentic_flag_ind = 1
			cerequest->clin_event.publish_flag = 1
			case (hsTroponin_data->algorithm_info.current_normalcy)
				of "RULED OUT": 		cerequest->clin_event.normalcy_cd = uar_get_code_by_cki("CKI.CODEVALUE!2690")	;Normal
				of "NO INJURY":			cerequest->clin_event.normalcy_cd = uar_get_code_by_cki("CKI.CODEVALUE!2690")	;Normal
				of "INDETERMINATE":		cerequest->clin_event.normalcy_cd = uar_get_code_by_cki("CKI.CODEVALUE!2680")	;Abnormal
				of "ABNORMAL":			cerequest->clin_event.normalcy_cd = uar_get_code_by_cki("CKI.CODEVALUE!3707")	;Extreme High
			else
				cerequest->clin_event.normalcy_cd = uar_get_code_by_cki("CKI.CODEVALUE!3707")	;>Extreme High
			endcase
 
			cerequest->clin_event.subtable_bit_map = 8193
			cerequest->clin_event.expiration_dt_tm_ind = 1
			cerequest->clin_event.valid_from_dt_tm = ce.valid_from_dt_tm
			cerequest->clin_event.valid_until_dt_tm = ce.valid_until_dt_tm
			cerequest->clin_event.valid_from_dt_tm_ind = 1
			cerequest->clin_event.valid_until_dt_tm_ind = 1
			cerequest->clin_event.verified_dt_tm_ind = 1
			cerequest->clin_event.performed_dt_tm = cnvtdatetime(curdate,curtime3)
			cerequest->clin_event.performed_prsnl_id = 1
			cerequest->clin_event.updt_id = 1
			cerequest->clin_event.updt_dt_tm = cnvtdatetime(curdate,curtime)
			cerequest->ensure_type2 = 1
 
			stat = alterlist(cerequest->clin_event.string_result,1)
			cerequest->clin_event.string_result.string_result_text = hsTroponin_data->algorithm_info.current_full_normalcy
			cerequest->clin_event.string_result.string_result_format_cd = uar_get_code_by("MEANING",14113,"ALPHA")
			cerequest->clin_event.string_result.last_norm_dt_tm_ind = 1
			cerequest->clin_event.string_result.feasible_ind_ind = 1
			cerequest->clin_event.string_result.inaccurate_ind_ind = 1
 
			stat = alterlist(cerequest->clin_event.event_prsnl_list,2)
			cerequest->clin_event.event_prsnl_list[1].person_id = ce.person_id
			cerequest->clin_event.event_prsnl_list[1].action_type_cd = 112
			cerequest->clin_event.event_prsnl_list[1].request_dt_tm_ind = 1
			cerequest->clin_event.event_prsnl_list[1].action_dt_tm = cnvtdatetime(curdate,curtime3)
			cerequest->clin_event.event_prsnl_list[1].action_prsnl_id = 1.0
			cerequest->clin_event.event_prsnl_list[1].action_status_cd = 653
			cerequest->clin_event.event_prsnl_list[1].valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
 
			cerequest->clin_event.event_prsnl_list[2].person_id = ce.person_id
			cerequest->clin_event.event_prsnl_list[2].action_type_cd = 104
			cerequest->clin_event.event_prsnl_list[2].request_dt_tm_ind = 1
			cerequest->clin_event.event_prsnl_list[2].action_dt_tm = cnvtdatetime(curdate,curtime3)
			cerequest->clin_event.event_prsnl_list[2].action_prsnl_id = 1.0
			cerequest->clin_event.event_prsnl_list[2].action_status_cd = 653
			cerequest->clin_event.event_prsnl_list[2].valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
		with nocounter
 
		set stat = tdbexecute(0,3055000,1000012,"REC",CERequest,"REC",CEReply,1)
 
		;call echojson(CEReply,"cmc2.json")
		call echorecord(CERequest)
		call echorecord(CEReply)
		call echo(build2("CEReply->rb_list[1].event_id=",CEReply->rb_list[1].event_id))
		if (validate(CEReply->rb_list[1].event_id))
			set vReturnSuccess = CEReply->rb_list[1].event_id
		else
			call echo("CEReply->rb_list[1].event_id not valid")
			set vReturnSuccess = FALSE
		endif
	endif
 
	return (vReturnSuccess)
 
end ;AddAlgorithmCEResult

subroutine AddAlgorithmCEDeltaResult(vCEventID)
	declare vReturnSuccess = f8 with noconstant(FALSE)
	declare vInterpEC = f8 with constant(GethsTropDeltaEC(null))
	
 	declare vhtml_output = vc with protect
 	declare vUsername = vc with protect
 	declare vAccession = vc with protect
 	declare vVerifiedPrsnlID = f8 with protect
 	
	if (validate(hsTroponin_data) = FALSE)
		return (vReturnSuccess)
	else
		free record cerequest
		free record cereply
%i cclsource:eks_rprq1000012.inc
		select into "nl:"
		from
			clinical_event ce
		plan ce
			where ce.clinical_event_id = vCEventID
		detail
			cerequest->ensure_type = 2
			cerequest->clin_event.view_level = 1
			cerequest->clin_event.person_id = ce.person_id
			cerequest->clin_event.encntr_id = ce.encntr_id
			cerequest->clin_event.contributor_system_cd = ce.contributor_system_cd
			cerequest->clin_event.event_class_cd = uar_get_code_by("MEANING",53,"TXT")
			cerequest->clin_event.event_cd = vInterpEC
			cerequest->clin_event.event_tag = cnvtstring(hsTroponin_data->algorithm_info.current_delta)
			cerequest->clin_event.event_start_dt_tm = ce.event_start_dt_tm
			cerequest->clin_event.event_end_dt_tm = ce.event_end_dt_tm
			cerequest->clin_event.event_end_dt_tm_os_ind = 1
			cerequest->clin_event.record_status_cd = uar_get_code_by("MEANING",48,"ACTIVE")
			cerequest->clin_event.result_status_cd = uar_get_code_by("MEANING",8,"AUTH")
			cerequest->clin_event.authentic_flag_ind = 1
			cerequest->clin_event.publish_flag = 1
			case (hsTroponin_data->algorithm_info.current_normalcy)
				of "RULED OUT": 		cerequest->clin_event.normalcy_cd = uar_get_code_by_cki("CKI.CODEVALUE!2690")	;Normal
				of "NO INJURY":			cerequest->clin_event.normalcy_cd = uar_get_code_by_cki("CKI.CODEVALUE!2690")	;Normal
				of "INDETERMINATE":		cerequest->clin_event.normalcy_cd = uar_get_code_by_cki("CKI.CODEVALUE!2680")	;Abnormal
				of "ABNORMAL":			cerequest->clin_event.normalcy_cd = uar_get_code_by_cki("CKI.CODEVALUE!3707")	;Extreme High
			else
				cerequest->clin_event.normalcy_cd = uar_get_code_by_cki("CKI.CODEVALUE!3707")	;>Extreme High
			endcase
 
			cerequest->clin_event.subtable_bit_map = 8193
			cerequest->clin_event.expiration_dt_tm_ind = 1
			cerequest->clin_event.valid_from_dt_tm = ce.valid_from_dt_tm
			cerequest->clin_event.valid_until_dt_tm = ce.valid_until_dt_tm
			cerequest->clin_event.valid_from_dt_tm_ind = 1
			cerequest->clin_event.valid_until_dt_tm_ind = 1
			cerequest->clin_event.verified_dt_tm_ind = 1
			cerequest->clin_event.performed_dt_tm = cnvtdatetime(curdate,curtime3)
			cerequest->clin_event.performed_prsnl_id = 1
			cerequest->clin_event.updt_id = 1
			cerequest->clin_event.updt_dt_tm = cnvtdatetime(curdate,curtime)
			cerequest->ensure_type2 = 1
 
			stat = alterlist(cerequest->clin_event.string_result,1)
			cerequest->clin_event.string_result.string_result_text = cnvtstring(hsTroponin_data->algorithm_info.current_delta)
			cerequest->clin_event.string_result.string_result_format_cd = uar_get_code_by("MEANING",14113,"ALPHA")
			cerequest->clin_event.string_result.last_norm_dt_tm_ind = 1
			cerequest->clin_event.string_result.feasible_ind_ind = 1
			cerequest->clin_event.string_result.inaccurate_ind_ind = 1
 
			stat = alterlist(cerequest->clin_event.event_prsnl_list,2)
			cerequest->clin_event.event_prsnl_list[1].person_id = ce.person_id
			cerequest->clin_event.event_prsnl_list[1].action_type_cd = 112
			cerequest->clin_event.event_prsnl_list[1].request_dt_tm_ind = 1
			cerequest->clin_event.event_prsnl_list[1].action_dt_tm = cnvtdatetime(curdate,curtime3)
			cerequest->clin_event.event_prsnl_list[1].action_prsnl_id = 1.0
			cerequest->clin_event.event_prsnl_list[1].action_status_cd = 653
			cerequest->clin_event.event_prsnl_list[1].valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
 
			cerequest->clin_event.event_prsnl_list[2].person_id = ce.person_id
			cerequest->clin_event.event_prsnl_list[2].action_type_cd = 104
			cerequest->clin_event.event_prsnl_list[2].request_dt_tm_ind = 1
			cerequest->clin_event.event_prsnl_list[2].action_dt_tm = cnvtdatetime(curdate,curtime3)
			cerequest->clin_event.event_prsnl_list[2].action_prsnl_id = 1.0
			cerequest->clin_event.event_prsnl_list[2].action_status_cd = 653
			cerequest->clin_event.event_prsnl_list[2].valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
			
			vVerifiedPrsnlID = ce.verified_prsnl_id
			
		with nocounter
 
		set stat = tdbexecute(0,3055000,1000012,"REC",CERequest,"REC",CEReply,1)
 
		call echo(build2("CEReply->rb_list[1].event_id=",CEReply->rb_list[1].event_id))
		if (validate(CEReply->rb_list[1].event_id))
			set vReturnSuccess = CEReply->rb_list[1].event_id
			
		 	if (hsTroponin_data->algorithm_info.current_delta >= 7)
				set vhtml_output = get_html_template("cov_troponin_util_notify.html")
 				
 				set vUsername = sGetUsername(vVerifiedPrsnlID)
 				set vAccession = trim(GetOrderAccessionbyOrderID(hsTroponin_data->three_hour.order_id))
 				
 				set vhtml_output = add_patientdata(cerequest->clin_event.person_id,cerequest->clin_event.encntr_id,vhtml_output)

 				set vhtml_output = replace_html_token(
 													 vhtml_output
 													,"%%DELTA_VALUE%%"
 													,cnvtstring(hsTroponin_data->algorithm_info.current_delta)
 													)	
 													
 			
 				set vhtml_output = replace_html_token(
 													 vhtml_output
 													,"%%RESULT_VALUE%%"
 													,cnvtstring(hsTroponin_data->algorithm_info.current_result_val)
 													)	
 				
 				set vhtml_output = replace_html_token(
 													 vhtml_output
 													,"%%ACCESSION%%"
 													,vAccession
 													)
 																														
 				call echo(build2("vhtml_output=",vhtml_output))  
 				
 				set stat = send_discern_notification(
 														vUsername
 														,concat("Critical Troponin HS Result - ",vAccession)
 														,vhtml_output
 													)
		 	endif 	
		 	
		else
			call echo("CEReply->rb_list[1].event_id not valid")
			set vReturnSuccess = FALSE
		endif
	endif
 
	return (vReturnSuccess)
 
end


subroutine AddAlgorithmCETimeResult(vCEventID)
	declare vReturnSuccess = f8 with noconstant(FALSE)
	declare vInterpEC = f8 with constant(GethsTropTimeEC(null))
 	declare vTimeValue = vc with noconstant("ERROR")
 	
	if (validate(hsTroponin_data) = FALSE)
		return (vReturnSuccess)
	else
		free record cerequest
		free record cereply
%i cclsource:eks_rprq1000012.inc
		select into "nl:"
		from
			clinical_event ce
		plan ce
			where ce.clinical_event_id = vCEventID
		detail
			cerequest->ensure_type = 2
			cerequest->clin_event.view_level = 1
			cerequest->clin_event.person_id = ce.person_id
			cerequest->clin_event.encntr_id = ce.encntr_id
			cerequest->clin_event.contributor_system_cd = ce.contributor_system_cd
			cerequest->clin_event.event_class_cd = uar_get_code_by("MEANING",53,"TXT")
			cerequest->clin_event.event_cd = vInterpEC
			
			if (hsTroponin_data->algorithm_info.current_phase = "ONEHOUR")
				vTimeValue = concat(
											trim(cnvtstring(datetimediff(hsTroponin_data->one_hour.collect_dt_tm,
																	hsTroponin_data->initial.collect_dt_tm,4)))
										 ," min")
			elseif (hsTroponin_data->algorithm_info.current_phase = "THREEHOUR")
				vTimeValue = concat(
											trim(cnvtstring(datetimediff(hsTroponin_data->three_hour.collect_dt_tm,
																	hsTroponin_data->initial.collect_dt_tm,4)))
										 ," min")
			endif
			cerequest->clin_event.event_tag = vTimeValue
			cerequest->clin_event.event_start_dt_tm = ce.event_start_dt_tm
			cerequest->clin_event.event_end_dt_tm = ce.event_end_dt_tm
			cerequest->clin_event.event_end_dt_tm_os_ind = 1
			cerequest->clin_event.record_status_cd = uar_get_code_by("MEANING",48,"ACTIVE")
			cerequest->clin_event.result_status_cd = uar_get_code_by("MEANING",8,"AUTH")
			cerequest->clin_event.authentic_flag_ind = 1
			cerequest->clin_event.publish_flag = 1
			case (hsTroponin_data->algorithm_info.current_normalcy)
				of "RULED OUT": 		cerequest->clin_event.normalcy_cd = uar_get_code_by_cki("CKI.CODEVALUE!2690")	;Normal
				of "NO INJURY":			cerequest->clin_event.normalcy_cd = uar_get_code_by_cki("CKI.CODEVALUE!2690")	;Normal
				of "INDETERMINATE":		cerequest->clin_event.normalcy_cd = uar_get_code_by_cki("CKI.CODEVALUE!2680")	;Abnormal
				of "ABNORMAL":			cerequest->clin_event.normalcy_cd = uar_get_code_by_cki("CKI.CODEVALUE!3707")	;Extreme High
			else
				cerequest->clin_event.normalcy_cd = uar_get_code_by_cki("CKI.CODEVALUE!3707")	;>Extreme High
			endcase
			
 			cerequest->clin_event.normalcy_cd = uar_get_code_by_cki("CKI.CODEVALUE!2690")	;override above and always post Normal
 			
			cerequest->clin_event.subtable_bit_map = 8193
			cerequest->clin_event.expiration_dt_tm_ind = 1
			cerequest->clin_event.valid_from_dt_tm = ce.valid_from_dt_tm
			cerequest->clin_event.valid_until_dt_tm = ce.valid_until_dt_tm
			cerequest->clin_event.valid_from_dt_tm_ind = 1
			cerequest->clin_event.valid_until_dt_tm_ind = 1
			cerequest->clin_event.verified_dt_tm_ind = 1
			cerequest->clin_event.performed_dt_tm = cnvtdatetime(curdate,curtime3)
			cerequest->clin_event.performed_prsnl_id = 1
			cerequest->clin_event.updt_id = 1
			cerequest->clin_event.updt_dt_tm = cnvtdatetime(curdate,curtime)
			cerequest->ensure_type2 = 1
 
			stat = alterlist(cerequest->clin_event.string_result,1)
			cerequest->clin_event.string_result.string_result_text = vTimeValue
			cerequest->clin_event.string_result.string_result_format_cd = uar_get_code_by("MEANING",14113,"ALPHA")
			cerequest->clin_event.string_result.last_norm_dt_tm_ind = 1
			cerequest->clin_event.string_result.feasible_ind_ind = 1
			cerequest->clin_event.string_result.inaccurate_ind_ind = 1
 
			stat = alterlist(cerequest->clin_event.event_prsnl_list,2)
			cerequest->clin_event.event_prsnl_list[1].person_id = ce.person_id
			cerequest->clin_event.event_prsnl_list[1].action_type_cd = 112
			cerequest->clin_event.event_prsnl_list[1].request_dt_tm_ind = 1
			cerequest->clin_event.event_prsnl_list[1].action_dt_tm = cnvtdatetime(curdate,curtime3)
			cerequest->clin_event.event_prsnl_list[1].action_prsnl_id = 1.0
			cerequest->clin_event.event_prsnl_list[1].action_status_cd = 653
			cerequest->clin_event.event_prsnl_list[1].valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
 
			cerequest->clin_event.event_prsnl_list[2].person_id = ce.person_id
			cerequest->clin_event.event_prsnl_list[2].action_type_cd = 104
			cerequest->clin_event.event_prsnl_list[2].request_dt_tm_ind = 1
			cerequest->clin_event.event_prsnl_list[2].action_dt_tm = cnvtdatetime(curdate,curtime3)
			cerequest->clin_event.event_prsnl_list[2].action_prsnl_id = 1.0
			cerequest->clin_event.event_prsnl_list[2].action_status_cd = 653
			cerequest->clin_event.event_prsnl_list[2].valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
		with nocounter
 
		set stat = tdbexecute(0,3055000,1000012,"REC",CERequest,"REC",CEReply,1)
 
		;call echojson(CEReply,"cmc2.json")
		call echorecord(CERequest)
		call echorecord(CEReply)
		
		call echo(build2("CEReply->rb_list[1].event_id=",CEReply->rb_list[1].event_id))
		if (validate(CEReply->rb_list[1].event_id))
			set vReturnSuccess = CEReply->rb_list[1].event_id
		else
			call echo("CEReply->rb_list[1].event_id not valid")
			set vReturnSuccess = FALSE
		endif
	endif
 
	return (vReturnSuccess)
 
end
 
 
subroutine AddAlgorithmResult(vCEventID)
	declare vReturnSuccess = i2 with noconstant(FALSE)
	if (validate(hsTroponin_data) = FALSE)
		return (vReturnSuccess)
	else
		execute cov_eks_hstrop_ce_add
			 ^nl:^
			,^COV_EE_HS_TROP_CE_ADD^
			,vCEventID
			,(hsTroponin_data->algorithm_info.current_normalcy)
			,(hsTroponin_data->algorithm_info.current_normalcy)
 
		set vReturnSuccess = TRUE
	endif
 
	return (vReturnSuccess)
 
end
 
subroutine GethsTropAlgOrderMargin(null)
	declare vReturnNumberofMinues = i4 with noconstant(0), protect
 
	set vReturnNumberofMinues = 30 ;(1 hours)
 	
	return (vReturnNumberofMinues)
end ;GethsTropAlgOrderMargin

subroutine GethsTropAlgOrderMarginMax(null)
	declare vReturnNumberofMinues = i4 with noconstant(0), protect
 
	set vReturnNumberofMinues = 360 ;(6 hours)
 
	return (vReturnNumberofMinues)
end ;GethsTropAlgOrderMargin

subroutine GetPatientLocationbyEncntrID(vEncntrID)

	declare vReturnUnit = vc with noconstant(""), protect
 
	select into "nl:"
	from
		 encounter e
	plan e
		where e.encntr_id = vEncntrID
	detail
		vReturnUnit = uar_get_code_display(e.loc_nurse_unit_cd)
	with nocounter
 
	return (vReturnUnit)
 
end ;GetPatientLocationbyEncntrID

subroutine GetPatientTypebyEncntrID(vEncntrID)

	declare vReturnType = vc with noconstant(""), protect
 
	select into "nl:"
	from
		 encounter e
	plan e
		where e.encntr_id = vEncntrID
	detail
		vReturnType = uar_get_code_display(e.encntr_type_cd)
	with nocounter
 
	return (vReturnType)
 
end ;GetPatientTypebyEncntrID

subroutine isPatientinED(vEncntrID)

	declare vReturnResponse = i2 with noconstant(FALSE)
	
	if (GetPatientLocationbyEncntrID(vEncntrID) in("*ED","*EB"))
 		set vReturnResponse = TRUE
 	endif

	return (vReturnResponse)
end ;isPatientinED

subroutine isPatientOutpatient(vEncntrID)

	declare vReturnResponse = i2 with noconstant(FALSE)
	
	if (GetPatientTypebyEncntrID(vEncntrID) in("Clinic","Outpatient"))
 		set vReturnResponse = TRUE
 	endif

	return (vReturnResponse)
end ;isPatientOutpatient

 
subroutine GetOrderLocationbyOrderID(vOrderID)
	declare vReturnUnit = vc with noconstant(""), protect
 
	select into "nl:"
	from
		 orders o
		,encntr_loc_hist elh
	plan o
		where o.order_id =  vOrderID
		and   o.order_id > 0.0
	join elh
		where elh.encntr_id = o.encntr_id
		and   o.orig_order_dt_tm between elh.beg_effective_dt_tm and elh.end_effective_dt_tm
		and   elh.active_ind = 1
	detail
		vReturnUnit = uar_get_code_display(elh.loc_nurse_unit_cd)
	with nocounter
 
	return (vReturnUnit)
 
end ;GetOrderLocationbyOrderID
 
subroutine GetOrderSynonymbyOrderID(vOrderID)
	declare vReturnSynonym = vc with noconstant(""), protect
 
	select into "nl:"
	from
		orders o
		,order_catalog_synonym ocs
	plan o
		where o.order_id = vOrderID
		and   o.order_id > 0.0
	join ocs
		where ocs.synonym_id = o.synonym_id
	detail
		vReturnSynonym = ocs.mnemonic
	with nocounter
 
	return (vReturnSynonym)
end ;GetOrderSynonymbyOrderID
 
subroutine GetOrderPowerPlanbyOrderID(vOrderID)
	declare vReturnPowerPlan = vc with noconstant("(ad hoc)"), protect
 
	select into "nl:"
	from
		orders o
		,pathway_catalog pc
	plan o
		where o.order_id = vOrderID
		and   o.order_id > 0.0
	join pc
		where pc.pathway_catalog_id = o.pathway_catalog_id
		and   pc.pathway_catalog_id > 0.0
	detail
		vReturnPowerPlan = pc.description
	with nocounter
 
	return (vReturnPowerPlan)
end ;GetOrderPowerPlanbyOrderID
 
 
subroutine UpdateCurrentPhase(vCurrentPhase)
	declare vReturnPhase = vc with noconstant("ERROR"), protect
 
	if (validate(hsTroponin_data) = FALSE)
		return (vReturnPhase)
	else
		if (hsTroponin_data->algorithm_info.type = "ED")
			case (vCurrentPhase)
				of "INITIAL":	set vReturnPhase = "THREEHOUR"
				of "ONEHOUR":	set vReturnPhase = "THREEHOUR"
				of "THREEHOUR": set vReturnPhase = "END"
			endcase
		elseif (hsTroponin_data->algorithm_info.type = "INPATIENT")
			case (vCurrentPhase)
				of "INITIAL":	set vReturnPhase = "THREEHOUR"
				of "THREEHOUR": set vReturnPhase = "END"
			endcase
		endif
	endif
 
	return (vReturnPhase)
 
end ;UpdateCurrentPhase
 
 
subroutine CallNewECGOrderServer(null)
	declare vNewOrderID = f8 with noconstant(0.0), protect
 
 	free record ecg_ordreply
	set stat = tdbexecute(560210,500210,560201,"REC",ecg_ordrequest,"REC",ecg_ordreply)
 
 	call echorecord(ecg_ordreply)
 
	for (i=1 to size(ecg_ordreply->orderlist,5))
		set vNewOrderID = ecg_ordreply->orderlist[i].orderid
	endfor
 
	return (vNewOrderID)
end ;CallNewECGOrderServer
 
 
subroutine UpdateECGOrderDetailDtTm(vOEFieldMeaning,vDateTime)
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
 	declare j=i4 with noconstant(0), protect
 	declare i=i4 with noconstant(0), protect
 
	if (validate(ecg_ordrequest) = FALSE)
		set vReturnSuccess = FALSE
		return (vReturnSuccess)
	endif
 
	for (j=1 to size(ecg_ordrequest->orderlist,5))
		for (i=1 to size(ecg_ordrequest->orderlist[j].detaillist,5))
			if (ecg_ordrequest->orderlist[j].detaillist[i].oefieldmeaning=trim(cnvtupper(vOEFieldMeaning)))
				set ecg_ordrequest->orderlist[j].detaillist[i].oefielddttmvalue = cnvtdatetime(vDateTime)
				set ecg_ordrequest->orderlist[j].detaillist[i].oefielddisplayvalue = format(vDateTime,";;q")
				set vReturnSuccess = TRUE
			endif
		endfor
	endfor
 
	return (vReturnSuccess)
end ;UpdateECGOrderDetailDtTm
 
subroutine UpdateECGOrderDetailValueCd(vOEFieldMeaning,vValueCd)
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
	declare j=i4 with noconstant(0), protect
 	declare i=i4 with noconstant(0), protect
 
	if (validate(ecg_ordrequest) = FALSE)
		set vReturnSuccess = FALSE
		return (vReturnSuccess)
	endif
 
	for (j=1 to size(ecg_ordrequest->orderlist,5))
		for (i=1 to size(ecg_ordrequest->orderlist[j].detaillist,5))
			if (ecg_ordrequest->orderlist[j].detaillist[i].oefieldmeaning=trim(cnvtupper(vOEFieldMeaning)))
				set ecg_ordrequest->orderlist[j].detaillist[i].oefieldvalue = vValueCd
				set ecg_ordrequest->orderlist[j].detaillist[i].oefielddisplayvalue = uar_get_code_display(vValueCd)
				set vReturnSuccess = TRUE
			endif
		endfor
	endfor
 
	return (vReturnSuccess)
end ;UpdateECGOrderDetailValueCd
 
subroutine SetupNewECGOrder(vPersonID,vEncntrID)
 
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
	declare ecg_ordrequest_template = vc with noconstant("cust_script:ed_ecg_ordrequest.json")
	declare ecg_ordrequest_line_in = vc with noconstant(" ")
 
 	if (isPatientInED(vEncntrID) = FALSE)
 		set ecg_ordrequest_template = "cust_script:ecg_ordrequest.json"
 	endif
 
 	if (isPatientOutpatient(vEncntrID) = TRUE)
 		set ecg_ordrequest_template = "cust_script:out_ecg_ordrequest.json"
 	endif
 
	free define rtl3
	define rtl3 is ecg_ordrequest_template
 
	select into "nl:"
	from rtl3t r
	detail
		ecg_ordrequest_line_in = concat(ecg_ordrequest_line_in,r.line)
	with nocounter
 
	free record ecg_ordrequest
	set stat = cnvtjsontorec(ecg_ordrequest_line_in,2)
 
	if (validate(ecg_ordrequest) = FALSE)
		set vReturnSuccess = FALSE
	else
		set ecg_ordrequest->personid = vPersonID
		set ecg_ordrequest->encntrid = vEncntrID
		set ecg_ordrequest->orderlist[1].encntrid = vEncntrID
 
		set vReturnSuccess = TRUE
	endif
	return (vReturnSuccess)
end ;SetupNewECGOrder
 
 
 
 
subroutine CallNewhsTropOrderServer(null)
	declare vNewOrderID = f8 with noconstant(0.0), protect
 
 	free record hstrop_ordreply
	set stat = tdbexecute(560210,500210,560201,"REC",hstrop_ordrequest,"REC",hstrop_ordreply)
 
	for (i=1 to size(hstrop_ordreply->orderlist,5))
		set vNewOrderID = hstrop_ordreply->orderlist[i].orderid
	endfor
 
	return (vNewOrderID)
end ;CallNewhsTropOrderServer
 
subroutine AddECGOrderComment(vComment)
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
 	declare j=i4 with noconstant(0), protect
 	declare i=i4 with noconstant(0), protect
 
	if (validate(ecg_ordrequest) = FALSE)
		set vReturnSuccess = FALSE
		return (vReturnSuccess)
	endif
 
	for (j=1 to size(ecg_ordrequest->orderlist,5))
		;set i = size(ecg_ordrequest->orderlist[j].commentlist,5)
		;set i = (i + 1)
		;set stat = alterlist(ecg_ordrequest->orderlist[j].commentlist,i)
		set i = 1
		set ecg_ordrequest->orderlist[j].commentlist[i].commenttype = uar_get_code_by("MEANING",14,"ORD COMMENT")
		set ecg_ordrequest->orderlist[j].commentlist[i].commenttext = trim(vComment)
		set vReturnSuccess = TRUE
	endfor
 
	return (vReturnSuccess)
end ;AddECGOrderComment
 
subroutine AddhsTropOrderComment(vComment)
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
 	declare j=i4 with noconstant(0), protect
 	declare i=i4 with noconstant(0), protect
 
	if (validate(hstrop_ordrequest) = FALSE)
		set vReturnSuccess = FALSE
		return (vReturnSuccess)
	endif
 
	for (j=1 to size(hstrop_ordrequest->orderlist,5))
		;set i = size(hstrop_ordrequest->orderlist[j].commentlist,5)
		;set i = (i + 1)
		;set stat = alterlist(hstrop_ordrequest->orderlist[j].commentlist,i)
		set i = 1
		set hstrop_ordrequest->orderlist[j].commentlist[i].commenttype = uar_get_code_by("MEANING",14,"ORD COMMENT")
		set hstrop_ordrequest->orderlist[j].commentlist[i].commenttext = trim(vComment)
		set vReturnSuccess = TRUE
	endfor
 
	return (vReturnSuccess)
end ;AddhsTropOrderComment
 
subroutine UpdateOrderDetailDtTm(vOEFieldMeaning,vDateTime)
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
 	declare j=i4 with noconstant(0), protect
 	declare i=i4 with noconstant(0), protect
 
	if (validate(hstrop_ordrequest) = FALSE)
		set vReturnSuccess = FALSE
		return (vReturnSuccess)
	endif
 
	for (j=1 to size(hstrop_ordrequest->orderlist,5))
		for (i=1 to size(hstrop_ordrequest->orderlist[j].detaillist,5))
			if (hstrop_ordrequest->orderlist[j].detaillist[i].oefieldmeaning=trim(cnvtupper(vOEFieldMeaning)))
				set hstrop_ordrequest->orderlist[j].detaillist[i].oefielddttmvalue = cnvtdatetime(vDateTime)
				set hstrop_ordrequest->orderlist[j].detaillist[i].oefielddisplayvalue = format(vDateTime,";;q")
				set vReturnSuccess = TRUE
			endif
		endfor
	endfor
 
	return (vReturnSuccess)
end ;UpdateOrderDetailDtTm
 
subroutine UpdateOrderDetailValueCd(vOEFieldMeaning,vValueCd)
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
	declare j=i4 with noconstant(0), protect
 	declare i=i4 with noconstant(0), protect
 
	if (validate(hstrop_ordrequest) = FALSE)
		set vReturnSuccess = FALSE
		return (vReturnSuccess)
	endif
 
	for (j=1 to size(hstrop_ordrequest->orderlist,5))
		for (i=1 to size(hstrop_ordrequest->orderlist[j].detaillist,5))
			if (hstrop_ordrequest->orderlist[j].detaillist[i].oefieldmeaning=trim(cnvtupper(vOEFieldMeaning)))
				set hstrop_ordrequest->orderlist[j].detaillist[i].oefieldvalue = vValueCd
				set hstrop_ordrequest->orderlist[j].detaillist[i].oefielddisplayvalue = uar_get_code_display(vValueCd)
				set vReturnSuccess = TRUE
			endif
		endfor
	endfor
 
	return (vReturnSuccess)
end ;UpdateOrderDetailValueCd
 
subroutine SetupNewhsTropOrder(vPersonID,vEncntrID)
 
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
	declare hstrop_ordrequest_template = vc with constant("cust_script:hstrop_ordrequest.json")
	declare hstrop_ordrequest_line_in = vc with noconstant(" ")
 
	free define rtl3
	define rtl3 is hstrop_ordrequest_template
 
	select into "nl:"
	from rtl3t r
	detail
		hstrop_ordrequest_line_in = concat(hstrop_ordrequest_line_in,r.line)
	with nocounter
 
	free record hstrop_ordrequest
	set stat = cnvtjsontorec(hstrop_ordrequest_line_in,2)
 
	if (validate(hstrop_ordrequest) = FALSE)
		set vReturnSuccess = FALSE
	else
		set hstrop_ordrequest->personid = vPersonID
		set hstrop_ordrequest->encntrid = vEncntrID
		set hstrop_ordrequest->orderlist[1].encntrid = vEncntrID
 
		set vReturnSuccess = TRUE
	endif
	return (vReturnSuccess)
end ;SetuphsTropOrder
 
subroutine AddEventTohsTropList(vEventID)
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
 
	if (validate(hsTroponin_data) = FALSE)
		set vReturnSuccess = FALSE
		return (vReturnSuccess)
	else
		set hsTroponin_data->result_cnt = (hsTroponin_data->result_cnt + 1)
		set stat = alterlist(hsTroponin_data->result_list,hsTroponin_data->result_cnt)
		set hsTroponin_data->result_list[hsTroponin_data->result_cnt].result_event_id = vEventID
		set vReturnSuccess = TRUE
	endif
 
	return (vReturnSuccess)
end ;AddEventTohsTropList
 
subroutine AddOrderTohsTropList(vOrderID)
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
 
	if (validate(hsTroponin_data) = FALSE)
		set vReturnSuccess = FALSE
		return (vReturnSuccess)
	else
		set hsTroponin_data->order_cnt = (hsTroponin_data->order_cnt + 1)
		set stat = alterlist(hsTroponin_data->order_list,hsTroponin_data->order_cnt)
		set hsTroponin_data->order_list[hsTroponin_data->order_cnt].order_id = vOrderID
		set vReturnSuccess = TRUE
	endif
 
	return (vReturnSuccess)
end ;AddOrderTohsTropList
 
subroutine DeterminehsTropAlg(vOrderID)
 
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
 
	if (validate(hsTroponin_data) = FALSE)
		set vReturnSuccess = FALSE
		return (vReturnSuccess)
	else
		;exit if this is a result from an order in a stemi plan
		if (cnvtupper(GetOrderPowerPlanbyOrderID(vOrderID)) = "*STEMI*")
			set vReturnSuccess = FALSE
			return (vReturnSuccess)
		endif
 
		;need to setup logic to determine if ED and check synonym
		set hsTroponin_data->algorithm_info.type = "NOTSET" ;Eventually default to the ED algorithm
		set hsTroponin_data->algorithm_info.subtype = "LESS" ;Default to (Symptoms < 3 hrs)
 
		if (GetOrderSynonymbyOrderID(vOrderID) = "*(Symptoms >= 3 hrs)*")
			set hsTroponin_data->algorithm_info.type = "ED"
			set hsTroponin_data->algorithm_info.subtype = "GREATER"
		elseif (GetOrderSynonymbyOrderID(vOrderID) = "*(Symptoms < 3 hrs)*")
			set hsTroponin_data->algorithm_info.type = "ED"
			set hsTroponin_data->algorithm_info.subtype = "LESS"
		endif
 
 		if (hsTroponin_data->algorithm_info.type = "NOTSET")
 			;Primary or unknown synonym used, use patient location
 			if (GetOrderLocationbyOrderID(vOrderID) not in("","*ED","*EB"))
 				set hsTroponin_data->algorithm_info.type = "INPATIENT"
 			endif
 		endif
 
		if (cnvtupper(GetOrderPowerPlanbyOrderID(vOrderID)) = "*STROKE*")
			set hsTroponin_data->algorithm_info.type = "INPATIENT"
		endif
 
 		if (hsTroponin_data->algorithm_info.type = "NOTSET")
 			set hsTroponin_data->algorithm_info.type = "ED"
 		endif
 
		if (hsTroponin_data->algorithm_info.type = "ED")
			;ED Troponin HS (Symptoms >= 3 hrs)
			;ED Troponin HS (Symptoms < 3 hrs)
 
			;set orderes to drop immediately when first result is recieved
			set hsTroponin_data->algorithm_info.immediate_orders = 0
 
 			;assume one and three hour will be needed
			set hsTroponin_data->one_hour.needed_ind = 0
			set hsTroponin_data->three_hour.needed_ind = 1
 		elseif (hsTroponin_data->algorithm_info.type = "INPATIENT")
 
			;set orderes to drop immediately when first result is recieved
			set hsTroponin_data->algorithm_info.immediate_orders = 0
 
 			;for inpatient only three hour will be needed
			set hsTroponin_data->one_hour.needed_ind = 0
			set hsTroponin_data->three_hour.needed_ind = 1
		endif
 
		set vReturnSuccess = TRUE
	endif
 
	return (vReturnSuccess)
end ;DeterminehsTropAlg
 
subroutine SethsTropAlgNextTimes(vOrderID)
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
 
	if (validate(hsTroponin_data) = FALSE)
		set vReturnSuccess = FALSE
		return (vReturnSuccess)
	else
		if ((vOrderID = hsTroponin_data->initial.order_id) and (hsTroponin_data->initial.collect_dt_tm != null))
			set hsTroponin_data->one_hour.target_dt_tm = cnvtlookahead("1,H",hsTroponin_data->initial.collect_dt_tm)
			set hsTroponin_data->three_hour.target_dt_tm = cnvtlookahead("3,H",hsTroponin_data->initial.collect_dt_tm)
			set vReturnSuccess = TRUE
		else
			set vReturnSuccess = FALSE
			return (vReturnSuccess)
		endif
	endif
 
	return (vReturnSuccess)
end ;SethsTropAlgNextTimes
 
subroutine GetCollectDtTmbyEventID(vEventID)
 
	declare rCollectDtTm = dq8 with noconstant(0.0), protect
	declare vOrderID = f8
 
	select into "nl:"
	from clinical_event ce where ce.event_id = vEventID
	detail
		vOrderID = ce.order_id
	with nocounter
 
	set rCollectDtTm = GetCollectDtTmbyOrderID(vOrderID)
 
	return (rCollectDtTm)
 
end ;GetCollectDtTmbyEventID
 
subroutine GetCollectDtTmbyOrderID(vOrderID)
 
	declare rCollectDtTm = dq8 with noconstant(0.0), protect
 
	select into "nl:"
	from
		orders o
	plan o
		where o.order_id = vOrderID
	detail
		rCollectDtTm = o.current_start_dt_tm
	with nocounter
 
	return (rCollectDtTm)
 
end ;GetCollectDtTmbyOrderID
 
subroutine IsSystemOrder(vOrderID)
	declare rSystemOrderInd = i2 with noconstant(FALSE)
 
	select into "nl:"
	from
		orders o
	    ,order_action oa
	plan o
		where o.order_id = vOrderID
	join oa
		where oa.order_id = o.order_id
		and   oa.action_type_cd = value(uar_get_code_by("MEANING",6003,"ORDER"))
	detail
		if (oa.order_provider_id = SystemPrsnlID)
			rSystemOrderInd = TRUE
		endif
	with nocounter
 
	return (rSystemOrderInd)
end ;IsSystemOrder
 
 
subroutine FindOrderInhsTrop(vOrderID)
	declare vEncntrID = f8 with constant(GetEncntrIDbyOrderID(vOrderID)), protect
	declare rParentEventID = f8 with noconstant(0.0), protect
	declare i=i4 with noconstant(0), protect
	declare j=i4 with noconstant(0), protect
 
	free record hsTroponin_list
	set stat = cnvtjsontorec(GethsTropAlgListByEncntrID(vEncntrID))
	;call echorecord(hsTroponin_list)
 
	for (i=1 to hsTroponin_list->cnt)
		set stat = cnvtjsontorec(GethsTropAlgDataByEventID(hsTroponin_list->qual[i].parent_event_id))
		;call echorecord(hsTroponin_data)
		for (j=1 to hsTroponin_data->order_cnt)
			if (hsTroponin_data->order_list[j].order_id = vOrderID)
				set rParentEventID = hsTroponin_list->qual[i].parent_event_id
				return (rParentEventID)
			endif
		endfor
	endfor
 
	return (rParentEventID)
end ;FindOrderInhsTrop
 
subroutine GetEncntrIDbyOrderID(vOrderID)
	declare rEncntrID = f8 with noconstant(0.0), protect
 
	select into "nl:"
	from
		orders o
	plan o
		where o.order_id = vOrderID
		and   o.order_id > 0.0
	detail
		rEncntrID = o.encntr_id
	with nocounter
 
	return (rEncntrID)
end ;GetEncntrIDbyOrderID
 
subroutine GethsTropAlgListByEncntrID(vEncntrID)
 
	declare vEventCD = f8 with constant(GethsTropAlgEC(null)), protect
 
	record hsTroponin_list
	(
		1 cnt = i4
		1 qual[*]
		 2 event_id = f8
		 2 parent_event_id = f8
	) with protect
 
	select into "nl:"
	from
		 clinical_event ce
		,ce_blob ceb
		,encounter e
	plan e
		where e.encntr_id = vEncntrID
	join ce
		where ce.encntr_id = e.encntr_id
		and   ce.person_id = e.person_id
		and   ce.event_cd = vEventCD
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
		and   ceb.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
		and   ceb.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	order by
		 ce.event_end_dt_tm desc
		,ce.parent_event_id
	head report
		i = hsTroponin_list->cnt
	head ce.parent_event_id
		i = (i + 1)
		stat = alterlist(hsTroponin_list->qual,i)
		hsTroponin_list->qual[i].event_id = ce.event_id
		hsTroponin_list->qual[i].parent_event_id = ce.parent_event_id
	foot report
		hsTroponin_list->cnt = i
	with nocounter
 
	return(cnvtrectojson(hsTroponin_list))
 
end ;GethsTropAlgListByEncntrID
 
 
 
subroutine SetNormalcybyMilestone(vMilestone)
	declare vReturnNormalcy = vc with noconstant("ERROR"), protect
 	declare vMilestoneDisplay = vc with noconstant("ERROR"), protect
 	declare vCollectDtTm = vc with noconstant("ERROR"), protect
 	
	if (validate(hsTroponin_data) = FALSE)
		return (vReturnNormalcy)
	else
		if (hsTroponin_data->algorithm_info.type  = "ED")
			if (hsTroponin_data->algorithm_info.subtype = "GREATER")
				;ED >3 Hours Algoritm
				if (cnvtupper(vMilestone) = "INITIAL")
 				 if (validate(t_rec->patient.clinical_event_id))
 				 	if (GetResultTextbyCEventID(t_rec->patient.clinical_event_id) = "<6")
	 				 	set vReturnNormalcy = "RULED OUT"
						set hsTroponin_data->one_hour.needed_ind = 0
						set hsTroponin_data->three_hour.needed_ind = 0
					else
						if (hsTroponin_data->initial.result_val <= 6)
							set vReturnNormalcy = "RULED OUT"
							set hsTroponin_data->one_hour.needed_ind = 0
							set hsTroponin_data->three_hour.needed_ind = 0
							;0A
						elseif ((hsTroponin_data->initial.result_val > 6) and (hsTroponin_data->initial.result_val <= 51))
							set vReturnNormalcy = "INDETERMINATE"
							set hsTroponin_data->one_hour.needed_ind = 0
							set hsTroponin_data->three_hour.needed_ind = 1
							;0B and 0C
						elseif (hsTroponin_data->initial.result_val >= 52)
							set vReturnNormalcy = "INDETERMINATE"
							set hsTroponin_data->one_hour.needed_ind = 0
							set hsTroponin_data->three_hour.needed_ind = 1
							;0D
	 				 	endif
	 				 endif
 				 elseif (GetResultTextbyCEventID(GethsTropCEEventIDbyEventID(hsTroponin_data->initial.result_event_id)) = "<6")
 				 	set vReturnNormalcy = "RULED OUT"
					set hsTroponin_data->one_hour.needed_ind = 0
					set hsTroponin_data->three_hour.needed_ind = 0
 				 else
					if (hsTroponin_data->initial.result_val <= 6)
						set vReturnNormalcy = "RULED OUT"
						set hsTroponin_data->one_hour.needed_ind = 0
						set hsTroponin_data->three_hour.needed_ind = 0
						;0A
					elseif ((hsTroponin_data->initial.result_val > 6) and (hsTroponin_data->initial.result_val <= 51))
						set vReturnNormalcy = "INDETERMINATE"
						set hsTroponin_data->one_hour.needed_ind = 0
						set hsTroponin_data->three_hour.needed_ind = 1
						;0B and 0C
					elseif (hsTroponin_data->initial.result_val >= 52)
						set vReturnNormalcy = "INDETERMINATE"
						set hsTroponin_data->one_hour.needed_ind = 0
						set hsTroponin_data->three_hour.needed_ind = 1
						;0D
					endif
 				 endif
				elseif (cnvtupper(vMilestone) = "ONEHOUR")
					set hsTroponin_data->algorithm_info.immediate_orders = 0 ;Do not immediated drop 3hour orders if necessary
					set hsTroponin_data->one_hour.delta = abs(hsTroponin_data->one_hour.result_val - hsTroponin_data->initial.result_val)
 
					if (hsTroponin_data->initial.result_val >= 52)
						if (hsTroponin_data->one_hour.delta < 3)
							set vReturnNormalcy = "NO INJURY"
							set hsTroponin_data->three_hour.needed_ind = 0
							;1H
						elseif ((hsTroponin_data->one_hour.delta >= 3) and (hsTroponin_data->one_hour.delta <= 4))
							set vReturnNormalcy = "INDETERMINATE"
							set hsTroponin_data->three_hour.needed_ind = 1
							;1I
						elseif (hsTroponin_data->one_hour.delta >= 5)
							set vReturnNormalcy = "ABNORMAL"
							set hsTroponin_data->three_hour.needed_ind = 0
							;1J
						endif
 
 
					elseif ((hsTroponin_data->initial.result_val >= 6) and (hsTroponin_data->initial.result_val <= 11))
						if (hsTroponin_data->one_hour.delta < 3)
							set vReturnNormalcy = "RULED OUT"
							set hsTroponin_data->three_hour.needed_ind = 0
							;1A
						elseif ((hsTroponin_data->one_hour.delta >= 3) and (hsTroponin_data->one_hour.delta <= 4))
							set vReturnNormalcy = "INDETERMINATE"
							set hsTroponin_data->three_hour.needed_ind = 1
							;1B
						elseif (hsTroponin_data->one_hour.delta >= 5)
							set vReturnNormalcy = "ABNORMAL"
							set hsTroponin_data->three_hour.needed_ind = 0
							;1C
						endif
						if (hsTroponin_data->one_hour.result_val >= 52)
							set vReturnNormalcy = "ABNORMAL"
							set hsTroponin_data->three_hour.needed_ind = 0
							;1D
						endif
 
 
					elseif ((hsTroponin_data->initial.result_val >= 12) and (hsTroponin_data->initial.result_val <= 51))
						if (hsTroponin_data->one_hour.delta < 5)
							set vReturnNormalcy = "INDETERMINATE"
							set hsTroponin_data->three_hour.needed_ind = 1
							;1E
						elseif (hsTroponin_data->one_hour.delta >= 5)
							set vReturnNormalcy = "ABNORMAL"
							set hsTroponin_data->three_hour.needed_ind = 0
							;1F
						endif
						if (hsTroponin_data->one_hour.result_val >= 52)
							set vReturnNormalcy = "INDETERMINATE"
							set hsTroponin_data->three_hour.needed_ind = 0
							;1G
						endif
 
					endif
				elseif (cnvtupper(vMilestone) = "THREEHOUR")
					set hsTroponin_data->three_hour.delta = abs(hsTroponin_data->three_hour.result_val - hsTroponin_data->initial.result_val)
 
 
					if (hsTroponin_data->three_hour.delta >= 7)
						set vReturnNormalcy = "ABNORMAL"
						;3B and 3E and 3H
					elseif (hsTroponin_data->three_hour.delta < 7)
						if (hsTroponin_data->initial.result_val >= 52)
							set vReturnNormalcy = "RULED OUT"
							;3G
						else
							set vReturnNormalcy = "RULED OUT"
							;3A and 3D
						endif
					endif
 
					;if (hsTroponin_data->three_hour.result_val >= 52)
					;	if (hsTroponin_data->initial.result_val < 52)
					;		set vReturnNormalcy = "ABNORMAL"
					;		;3C and 3F
					;	endif
					;endif
 
				endif
 
			elseif (hsTroponin_data->algorithm_info.subtype = "LESS")
				;ED <3 Hours Algoritm
				if (cnvtupper(vMilestone) = "INITIAL")
					if ((hsTroponin_data->initial.result_val >= 0) and (hsTroponin_data->initial.result_val <= 51))
						set vReturnNormalcy = "INDETERMINATE"
						set hsTroponin_data->one_hour.needed_ind = 0
						set hsTroponin_data->three_hour.needed_ind = 1
						;0A
					elseif (hsTroponin_data->initial.result_val >= 52)
						set vReturnNormalcy = "INDETERMINATE"
						set hsTroponin_data->one_hour.needed_ind = 0
						set hsTroponin_data->three_hour.needed_ind = 1
						;0B
					endif
				elseif (cnvtupper(vMilestone) = "ONEHOUR")
					set hsTroponin_data->one_hour.delta = abs(hsTroponin_data->one_hour.result_val - hsTroponin_data->initial.result_val)
 
					if (hsTroponin_data->initial.result_val >= 52)
						if (hsTroponin_data->one_hour.delta < 3)
							set vReturnNormalcy = "NO INJURY"
							set hsTroponin_data->three_hour.needed_ind = 0
							;1D
						elseif ((hsTroponin_data->one_hour.delta >= 3) and (hsTroponin_data->one_hour.delta <= 4))
							set vReturnNormalcy = "INDETERMINATE"
							set hsTroponin_data->three_hour.needed_ind = 1
							;1E
						elseif (hsTroponin_data->one_hour.delta >= 5)
							set vReturnNormalcy = "ABNORMAL"
							set hsTroponin_data->three_hour.needed_ind = 0
							;1F
						endif
 
					elseif (hsTroponin_data->initial.result_val < 52)
						if (hsTroponin_data->one_hour.delta < 5)
							set vReturnNormalcy = "INDETERMINATE"
							set hsTroponin_data->three_hour.needed_ind = 1
							;1A
						elseif (hsTroponin_data->one_hour.delta >= 5)
							set vReturnNormalcy = "ABNORMAL"
							set hsTroponin_data->three_hour.needed_ind = 0
							;1B
						endif
 
						if (hsTroponin_data->one_hour.result_val >= 52)
							set vReturnNormalcy = "INDETERMINATE"
							set hsTroponin_data->three_hour.needed_ind = 0
							;1C
						endif
 
					endif
				elseif (cnvtupper(vMilestone) = "THREEHOUR")
					set hsTroponin_data->three_hour.delta = abs(hsTroponin_data->three_hour.result_val - hsTroponin_data->initial.result_val)
 
					if (hsTroponin_data->three_hour.delta >= 7)
						set vReturnNormalcy = "ABNORMAL"
						;3B and 3E
					elseif (hsTroponin_data->three_hour.delta < 7)
						if (hsTroponin_data->initial.result_val >= 52)
							set vReturnNormalcy = "RULED OUT"
							;3D
						else
							set vReturnNormalcy = "RULED OUT"
							;3A
						endif
					endif
 
					;if (hsTroponin_data->three_hour.result_val >= 52)
					;	if (hsTroponin_data->initial.result_val < 52)
					;		set vReturnNormalcy = "ABNORMAL"
					;		;3C
					;	endif
					;endif
 
				endif
			endif
		elseif (hsTroponin_data->algorithm_info.type = "INPATIENT")
			if (cnvtupper(vMilestone) = "INITIAL")
				if ((hsTroponin_data->initial.result_val >= 0) and (hsTroponin_data->initial.result_val <= 51))
					set vReturnNormalcy = "INDETERMINATE"
					;0A
				elseif (hsTroponin_data->initial.result_val >= 52)
					set vReturnNormalcy = "INDETERMINATE"
					;0B
				endif
			elseif (cnvtupper(vMilestone) = "THREEHOUR")
				set hsTroponin_data->three_hour.delta = abs(hsTroponin_data->three_hour.result_val - hsTroponin_data->initial.result_val)
 
				if (hsTroponin_data->three_hour.delta >= 7)
					set vReturnNormalcy = "ABNORMAL"
					;3B and 3E
				elseif (hsTroponin_data->three_hour.delta < 7)
					if (hsTroponin_data->initial.result_val >= 52)
						set vReturnNormalcy = "RULED OUT"
						;3D
					else
						set vReturnNormalcy = "RULED OUT"
						;3A
					endif
				endif
 
				;if (hsTroponin_data->three_hour.result_val >= 52)
				;	if (hsTroponin_data->initial.result_val < 52)
				;		set vReturnNormalcy = "ABNORMAL"
				;		;3C
				;	endif
				;endif
			endif
		endif
	endif
 
 	set hsTroponin_data->algorithm_info.current_normalcy = vReturnNormalcy
 
 	case (hsTroponin_data->algorithm_info.current_normalcy)
 		of "RULED OUT": 		set hsTroponin_data->algorithm_info.current_full_normalcy = "AMI RULED OUT"
		of "NO INJURY":			set hsTroponin_data->algorithm_info.current_full_normalcy = "AMI RULED OUT"
		of "INDETERMINATE":		set hsTroponin_data->algorithm_info.current_full_normalcy = hsTroponin_data->algorithm_info.current_normalcy
		of "ABNORMAL":			set hsTroponin_data->algorithm_info.current_full_normalcy = hsTroponin_data->algorithm_info.current_normalcy
	else
		set hsTroponin_data->algorithm_info.current_full_normalcy = "ERROR"
 	endcase


	case (cnvtupper(vMilestone))
		of "INITIAL":	set vMilestoneDisplay = "0h"
						set vCollectDtTm = format(hsTroponin_data->initial.collect_dt_tm,"dd-mmm-yyyy hh:mm:ss zzz;;q")
		of "ONEHOUR":	set vMilestoneDisplay = "1h"
						set vCollectDtTm = format(hsTroponin_data->one_hour.collect_dt_tm,"dd-mmm-yyyy hh:mm:ss zzz;;q")
						set hsTroponin_data->algorithm_info.current_delta = hsTroponin_data->one_hour.delta
						set hsTroponin_data->algorithm_info.current_result_val = hsTroponin_data->one_hour.result_val
		of "THREEHOUR":	set vMilestoneDisplay = "3h"
						set vCollectDtTm = format(hsTroponin_data->three_hour.collect_dt_tm,"dd-mmm-yyyy hh:mm:ss zzz;;q")
						set hsTroponin_data->algorithm_info.current_delta = hsTroponin_data->three_hour.delta
						set hsTroponin_data->algorithm_info.current_result_val = hsTroponin_data->three_hour.result_val
	endcase
	
	select into "nl:"
	from
		clinical_event ce
	plan ce
		where ce.event_id in(
								 hsTroponin_data->initial.result_event_id
								,hsTroponin_data->one_hour.result_event_id
								,hsTroponin_data->three_hour.result_event_id
								)
		and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
		and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
		and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
		and   ce.event_tag        != "Date\Time Correction"
		and   ce.view_level = 1
	order by
		 ce.event_id
		,ce.valid_from_dt_tm
	head ce.event_id
		case (ce.event_id)
		of hsTroponin_data->initial.result_event_id:	
			vCollectDtTm = format(ce.valid_from_dt_tm,"dd-mmm-yyyy hh:mm:ss zzz;;q")
		of hsTroponin_data->one_hour.result_event_id:	
			vCollectDtTm = format(ce.valid_from_dt_tm,"dd-mmm-yyyy hh:mm:ss zzz;;q")
		of hsTroponin_data->three_hour.result_event_id:	
			vCollectDtTm = format(ce.valid_from_dt_tm,"dd-mmm-yyyy hh:mm:ss zzz;;q")
	endcase
	with nocounter
	
	set hsTroponin_data->algorithm_info.current_full_normalcy = concat(
																		 	 hsTroponin_data->algorithm_info.current_full_normalcy
																			," ["
																			,vMilestoneDisplay
																			,"]"
																	   )
																		
 
 	return (vReturnNormalcy)
end ;SetNormalcybyMilestone
 
subroutine GetResultbyCEventID(vCEventID)
 
	declare rResultVal = f8 with noconstant(0.0), protect
 
	select into "nl:"
	from
		clinical_event ce
	plan ce
		where ce.clinical_event_id = vCEventID
		and   ce.clinical_event_id > 0.0
	detail
		if (trim(ce.result_val) = "<6")
			rResultVal = 6.0
		elseif (trim(ce.result_val) = ">10000")
			rResultVal = 10000.0
		else
			rResultVal = cnvtreal(ce.result_val)
		endif
	with nocounter
 	
	return(rResultVal)
end ;GetResultbyCEventID


subroutine GetResultTextbyCEventID(vCEventID)
 
	declare rResultValText = vc with noconstant(" "), protect
 
	select into "nl:"
	from
		clinical_event ce
	plan ce
		where ce.clinical_event_id = vCEventID
		and   ce.clinical_event_id > 0.0
	detail
		rResultValText = trim(ce.result_val)
	with nocounter
 
	return(rResultValText)
end ;GetResultTextbyCEventID

subroutine GetResultTextbyEventID(vEventID)
 
	declare rResultValText = vc with noconstant(" "), protect
 
	select into "nl:"
	from
		clinical_event ce
	plan ce
		where ce.event_id = vEventID
		and   ce.event_id > 0.0
		and   ce.valid_from_dt_tm <= cnvtdatetime(sysdate)
		and   ce.valid_until_dt_tm >= cnvtdatetime(sysdate)
	detail
		rResultValText = trim(ce.result_val)
	with nocounter
 
	return(rResultValText)
end ;GetResultTextbyEventID
 
 
subroutine GetParentEventIDbyCEventID(vCEventID)
 
	declare rParentEventID = f8 with noconstant(0.0), protect
 
	select into "nl:"
	from
		clinical_event ce
	plan ce
		where ce.clinical_event_id = vCEventID
		and   ce.clinical_event_id > 0.0
	detail
		rParentEventID = ce.parent_event_id
	with nocounter
 
	return(rParentEventID)
end ;GetParentEventIDbyCEventID
 
subroutine GetEventIDbyCEventID(vCEventID)
 
	declare rEventID = f8 with noconstant(0.0), protect
 
	select into "nl:"
	from
		clinical_event ce
	plan ce
		where ce.clinical_event_id = vCEventID
		and   ce.clinical_event_id > 0.0
	detail
		rEventID = ce.event_id
	with nocounter
 
	return(rEventID)
end ;GetEventIDbyCEventID
 
subroutine GetOrderIDbyCEventID(vCEventID)
 
	declare rOrderID = f8 with noconstant(0.0), protect
 
	select into "nl:"
	from
		clinical_event ce
	plan ce
		where ce.clinical_event_id = vCEventID
		and   ce.clinical_event_id > 0.0
	detail
		rOrderID = ce.order_id
	with nocounter
 
	return(rOrderID)
end ;GetOrderIDbyCEventID
 
subroutine AddMPEventReply(null)
 
	/*
	declare filepath1 = vc with constant("ccluserdir:mp_event_detail_query.reply"), protect
	declare eksdata_line_in = vc with noconstant(""), protect
 
	free define rtl3
	define rtl3 is filepath1
	select into "nl:"
	from rtl3t r
	detail
		eksdata_line_in = concat(eksdata_line_in,r.line)
	with nocounter
	*/
	free record event_reply
	;set stat = cnvtjsontorec(eksdata_line_in,8)
 
end ;AddMPEventReply
 
subroutine GethsTropAlgDataByEventID(vEventID)
 	; maybe switch to mp_get_blob_contents
	declare dFormatCd = f8 with noconstant(0.0), protect
	declare rhsTropAlgDataJSON = vc with noconstant(" "), protect
 	declare i=i4 with noconstant(0), protect
	declare j=i4 with noconstant(0), protect
 
	free record event_request
	record event_request
	(
		1 event_id = f8
		1 query_mode = i4
		1 subtable_bit_map_ind = i2
		1 valid_from_dt_tm_ind = i2
	) with protect
 
	set event_request->event_id = vEventID
	set event_request->query_mode = 269615107
	set event_request->subtable_bit_map_ind = 1
	set event_request->valid_from_dt_tm_ind = 1
 
	call AddMPEventReply(null)
 
	execute mp_event_detail_query with replace("REQUEST",event_request), replace("REPLY",event_reply)
 
	free record raw_blob_list
	record raw_blob_list
	(
		1 blobs_cnt = i4
		1 blobs[*]
			2 compression_cd = f8
			2 blob = gvc
			2 format_cd = f8
	)
 
	if(size(event_reply->rb_list,5) > 0)
		for(rbIdx=1 to size(event_reply->rb_list,5))
			for(rbbrIdx=1 to size(event_reply->rb_list[rbIdx]->blob_result,5))
				 set dFormatCd = event_reply->rb_list[rbIdx]->blob_result[rbbrIdx].format_cd
				for(rbbrbIdx=1 to size(event_reply->rb_list[rbIdx]->blob_result[rbbrIdx]->blob,5))
					 set raw_blob_list->blobs_cnt = raw_blob_list->blobs_cnt + 1
					 set nStat = alterlist(raw_blob_list->blobs, raw_blob_list->blobs_cnt)
					 set raw_blob_list->blobs[raw_blob_list->blobs_cnt].compression_cd =
						event_reply->rb_list[rbIdx]->blob_result[rbbrIdx]->blob[rbbrbIdx].compression_cd
					 set raw_blob_list->blobs[raw_blob_list->blobs_cnt].blob =
						substring(1, event_reply->rb_list[rbIdx]->blob_result[rbbrIdx]->blob[rbbrbIdx].blob_length
									,event_reply->rb_list[rbIdx]->blob_result[rbbrIdx]->blob[rbbrbIdx].blob_contents)
					 set raw_blob_list->blobs[raw_blob_list->blobs_cnt].format_cd = dFormatCd
				endfor
				 set dFormatCd = 0.0
			endfor
			for(cIdx=1 to size(event_reply->rb_list[rbIdx]->child_event_list,5))
				for(rbbrIdx=1 to size(event_reply->rb_list[rbIdx]->child_event_list[cIdx]->blob_result,5))
					 set dFormatCd = event_reply->rb_list[rbIdx]->child_event_list[cIdx]->blob_result[rbbrIdx].format_cd
					for(rbbrbIdx=1 to size(event_reply->rb_list[rbIdx]->child_event_list[cIdx]->blob_result[rbbrIdx]->blob,5))
						 set raw_blob_list->blobs_cnt = raw_blob_list->blobs_cnt + 1
						 set nStat = alterlist(raw_blob_list->blobs, raw_blob_list->blobs_cnt)
						 set raw_blob_list->blobs[raw_blob_list->blobs_cnt].compression_cd =
							event_reply->rb_list[rbIdx]->child_event_list[cIdx]->blob_result[rbbrIdx]->blob[rbbrbIdx].compression_cd
						 set raw_blob_list->blobs[raw_blob_list->blobs_cnt].blob =
							substring(1, event_reply->rb_list[rbIdx]->child_event_list[cIdx]->blob_result[rbbrIdx]->blob[rbbrbIdx].blob_length
										,event_reply->rb_list[rbIdx]->child_event_list[cIdx]->blob_result[rbbrIdx]->blob[rbbrbIdx].blob_contents)
						 set raw_blob_list->blobs[raw_blob_list->blobs_cnt].format_cd = dFormatCd
					endfor
					 set dFormatCd = 0.0
				endfor
				for(scIdx=1 to size(event_reply->rb_list[rbIdx]->child_event_list[cIdx]->child_event_list,5))
					for(rbbrIdx=1 to size(event_reply->rb_list[rbIdx]->child_event_list[cIdx]->child_event_list[scIdx]->blob_result,5))
						set dFormatCd = event_reply->rb_list[rbIdx]->child_event_list[cIdx]->child_event_list[scIdx]->blob_result[rbbrIdx].format_cd
						for(rbbrbIdx=1 to
							size(event_reply->rb_list[rbIdx]->child_event_list[cIdx]->child_event_list[scIdx]->blob_result[rbbrIdx]->blob,5))
							 set raw_blob_list->blobs_cnt = raw_blob_list->blobs_cnt + 1
							 set nStat = alterlist(raw_blob_list->blobs, raw_blob_list->blobs_cnt)
							 set raw_blob_list->blobs[raw_blob_list->blobs_cnt].compression_cd =
		event_reply->rb_list[rbIdx]->child_event_list[cIdx]->child_event_list[scIdx]->blob_result[rbbrIdx]->blob[rbbrbIdx].compression_cd
							 set raw_blob_list->blobs[raw_blob_list->blobs_cnt].blob =
								substring(1, event_reply->rb_list[rbIdx]->child_event_list[cIdx]->child_event_list[scIdx]->
												blob_result[rbbrIdx]->blob[rbbrbIdx].blob_length
											,event_reply->rb_list[rbIdx]->child_event_list[cIdx]->child_event_list[scIdx]->
												blob_result[rbbrIdx]->blob[rbbrbIdx].blob_contents)
							 set raw_blob_list->blobs[raw_blob_list->blobs_cnt].format_cd = dFormatCd
						endfor
						 set dFormatCd = 0.0
					endfor
				endfor
			endfor
		endfor
	endif
 
	for (i=1 to raw_blob_list->blobs_cnt)
		set rhsTropAlgDataJSON = raw_blob_list->blobs[i].blob
	endfor
 
	return (rhsTropAlgDataJSON)
end ;GethsTropAlgDataByEventID
 
 
subroutine RemovehsTropInterp(vPersonID,vEncntrID,vEventID)
	declare _memory_reply_string = vc with protect
	declare vEventCD = f8 with constant(GethsTropInterpEC(null)), protect
	declare rParentEventID = f8 with noconstant(0.0), protect
 
 	execute cov_mp_unchart_result
											 ^MINE^
											,vPersonID
											,value(SystemPrsnlID)
											,vEncntrID
											,vEventCD
											,vEventID
											,0.0
		free record record_data
		set stat = cnvtjsontorec(_memory_reply_string)
		;call echorecord(record_data)
		set _memory_reply_string = ""
 
 		set rParentEventID = vEventID ;this needs to be updated to get ID from reply
 	return (rParentEventID)
end ;RemovehsTropInterp
 
 
subroutine RemovehsTropAlgData(vPersonID,vEncntrID,vEventID)
	declare _memory_reply_string = vc with protect
	declare vEventCD = f8 with constant(GethsTropAlgEC(null)), protect
	declare rParentEventID = f8 with noconstant(0.0), protect
 
 	execute cov_mp_unchart_result
											 ^MINE^
											,vPersonID
											,value(SystemPrsnlID)
											,vEncntrID
											,vEventCD
											,vEventID
											,0.0
		free record record_data
		set stat = cnvtjsontorec(_memory_reply_string)
		;call echorecord(record_data)
		set _memory_reply_string = ""
 
 		set rParentEventID = vEventID ;this needs to be updated to get ID from reply
 	return (rParentEventID)
end ;RemovehsTropAlgData
 
subroutine AddhsTropAlgData(vPersonID,vEncntrID,vJSON)
	declare _memory_reply_string = vc with protect
	declare vEventCD = f8 with constant(GethsTropAlgEC(null)), protect
	declare rParentEventID = f8 with noconstant(0.0), protect
 
	execute cov_mp_add_document
								^MINE^
								,vPersonID
								,value(SystemPrsnlID)
								,vEncntrID
								,vEventCD
								,"hsTroponin_Algorithm"
								,vJSON
								,0.0
 
	free record record_data
	set stat = cnvtjsontorec(_memory_reply_string)
 	;call echorecord(record_data)
 
 	return (_memory_reply_string)
end ;AddhsTropAlgData
 
subroutine EnsurehsTropAlgData(vPersonID,vEncntrID,vEventID,vJSON)
	declare _memory_reply_string = vc with protect
	declare vEventCD = f8 with constant(GethsTropAlgEC(null)), protect
	declare rParentEventID = f8 with noconstant(0.0), protect
 	declare validEventIDInd = i2 with noconstant(0), protect
	declare rParentInErrorID = f8 with noconstant(0.0), protect
	declare rRecordDataJSON = vc with noconstant(" "), protect
 
	if (vEventID > 0.0)
		select into "nl:"
		from clinical_event ce where ce.event_id = vEventID and ce.event_cd = vEventCD
		detail
			validEventIDInd = 1
		with nocounter
 
		if (validEventIDInd = 1)
			set rParentInErrorID = RemovehsTropAlgData(vPersonID,vEncntrID,vEventID)
		endif
	endif
 
 	set rRecordDataJSON = AddhsTropAlgData(vPersonID,vEncntrID,vJSON)
 
 	free record record_data
	set stat = cnvtjsontorec(rRecordDataJSON)
 
	call pause(1)
 
	select into "nl:"
	from
		 (dummyt d1 with seq=size(record_data->rep,5))
		,(dummyt d2 with seq=1)
		,clinical_event ce
		,ce_blob ceb
	plan d1
		where maxrec(d2,size(record_data->rep[d1.seq].rb_list,5))
	join d2
	join ce
		where ce.parent_event_id = record_data->rep[d1.seq].rb_list[d2.seq].parent_event_id
		and   cnvtdatetime(curdate,curtime3) between ce.valid_from_dt_tm and ce.valid_until_dt_tm
	join ceb
		where ceb.event_id = ce.event_id
		and   cnvtdatetime(curdate,curtime3) between ceb.valid_from_dt_tm and ceb.valid_until_dt_tm
	detail
		rParentEventID = ce.parent_event_id
	with nocounter
 
	return (rParentEventID)
 
end ;EnsurehsTropAlgData

subroutine GethsTropInterpEC(null)
	declare hsTropInterpEC = f8 with protect
 
	select into "nl:"
	from
		code_value cv
	plan cv
		where cv.code_set = 72
		and   cv.active_ind = 1
		and   cv.display = "hs Troponin Interpretation"
	order by
		cv.begin_effective_dt_tm desc
		,cv.display
	head cv.display
		hsTropInterpEC = cv.code_value
	with nocounter
 
	return (hsTropInterpEC)
end ;GethsTropInterpEC

subroutine GethsTropDeltaEC(null)
	declare hsTropDeltaEC = f8 with protect
 
	select into "nl:"
	from
		code_value cv
	plan cv
		where cv.code_set = 72
		and   cv.active_ind = 1
		and   cv.display = "hs Troponin Delta"
	order by
		cv.begin_effective_dt_tm desc
		,cv.display
	head cv.display
		hsTropDeltaEC = cv.code_value
	with nocounter
 
	return (hsTropDeltaEC)
end ;GethsTropDeltaEC
 
subroutine GethsTropTimeEC(null)
	declare hsTropTimeEC = f8 with protect
 
	select into "nl:"
	from
		code_value cv
	plan cv
		where cv.code_set = 72
		and   cv.active_ind = 1
		and   cv.display = "hs Troponin Timeframe"
	order by
		cv.begin_effective_dt_tm desc
		,cv.display
	head cv.display
		hsTropTimeEC = cv.code_value
	with nocounter
 
	return (hsTropTimeEC)
end ;GethsTropTimeEC
 
 
subroutine GethsTropAlgEC(null)
	declare hsTropEC = f8 with protect
 
	select into "nl:"
	from
		code_value cv
	plan cv
		where cv.code_set = 72
		and   cv.active_ind = 1
		and   cv.display = "hs Troponin Algorithm Data"
		;and   cv.code_value = 3904321687.00; hs Troponin Algorithm Data
	order by
		cv.begin_effective_dt_tm desc
		,cv.display
	head cv.display
		hsTropEC = cv.code_value
	with nocounter
 
	return (hsTropEC)
end ;GethsTropAlgEC
 
subroutine AddhsTropRefRec(freeRec)
	if (freeRec = 1)
		free record hsTroponin_ref
	endif
 
	record hsTroponin_ref
	(
		1 type = vc
	)
end ;AddhsTropRefRec
 
subroutine AddhsTropDataRec(freeRec)
	if (freeRec = 1)
		free record hsTroponin_data
	endif
 
	record hsTroponin_data
	(
		1 person_id = f8
		1 encntr_id = f8
		1 algorithm_info
		 2 process_dt_tm = dq8
		 2 type = vc
		 2 subtype = vc
		 2 current_phase = vc
		 2 current_normalcy = vc
		 2 current_result_val = f8
		 2 current_delta = f8
		 2 current_full_normalcy = vc
		 2 current_interp_id = f8
		 2 immediate_orders = i2
		1 initial
		 2 order_id = f8
		 2 ecg_order_id = f8
		 2 collect_dt_tm = dq8
		 2 result_event_id = f8
		 2 result_parent_event_id = f8
		 2 result_val = f8
		 2 normalcy = vc
		 2 ordering_provider_id = f8
		 2 ordering_provider_name = vc
		 2 interp_event_id = f8
		1 one_hour
	     2 needed_ind = i4
		 2 order_id = f8
		 2 ecg_order_id = f8
		 2 collect_dt_tm = dq8
		 2 target_dt_tm = dq8
		 2 result_event_id = f8
		 2 result_parent_event_id = f8
		 2 result_val = f8
		 2 delta = f8
		 2 normalcy = vc
		 2 interp_event_id = f8
		1 three_hour
		 2 needed_ind = i4
		 2 order_id = f8
		 2 ecg_order_id = f8
		 2 collect_dt_tm = dq8
		 2 target_dt_tm = dq8
		 2 result_event_id = f8
		 2 result_parent_event_id = f8
		 2 result_val = f8
		 2 delta = f8
		 2 normalcy = vc
		 2 interp_event_id = f8
		1 order_cnt = i4
		1 order_list[*]
		 2 order_id = f8
		1 result_cnt = i4
		1 result_list[*]
		 2 result_event_id = f8
	) with protect, persist
 
	return (TRUE)
end ;AddhsTropDataRec
 
 
 
end
go
 
