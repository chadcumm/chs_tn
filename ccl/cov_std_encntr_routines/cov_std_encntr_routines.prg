/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/02/2021
  Solution:
  Source file name:   cov_std_encntr_routines.prg
  Object name:        cov_std_encntr_routines
  Request #:
 
  Program purpose:
 
  Executing from:     CCL
 
  Special Notes:      Additional Required Scripts:
 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   12/02/2021  Chad Cummings			initial build
******************************************************************************/
drop program cov_std_encntr_routines:dba go
create program cov_std_encntr_routines:dba
 
call echo(build2("starting ",trim(cnvtlower(curprog))))
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect
 
/* Global Variables */
declare	cSystemPrsnlID = f8 with noconstant(1.0), protect, persist

/* Required Utilities */
execute cov_std_log_routines
 
/* Subroutines */

/**********************************************************************************************************************
** Function sGetFIN_ByEncntrID()
** ---------------------------------------------------------------------------------------
** Returns the active FIN for the encounter number supplied
**********************************************************************************************************************/
declare sGetFIN_ByEncntrID(vEncntrID=f8) = vc  with copy, persist
subroutine sGetFIN_ByEncntrID(vEncntrID)

	declare vReturnFIN = vc with protect
	
	select into "nl:"
	from
		encntr_alias ea
	plan ea
		where ea.encntr_id = vEncntrID
		and   ea.encntr_id > 0.0
		and   ea.active_ind = 1
		and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
		and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
	order by
		 ea.encntr_id
		,ea.beg_effective_dt_tm desc
	head report
		i = 0
	head ea.encntr_id
		vReturnFIN = trim(cnvtalias(ea.alias,ea.alias_pool_cd))
	with nocounter
	
	return (vReturnFIN)

end

/**********************************************************************************************************************
** Function sGetEncntrID_ByFIN()
** ---------------------------------------------------------------------------------------
** Returns the encounter ID for the FIN supplied
**********************************************************************************************************************/
declare sGetEncntrID_ByFIN(vFIN=vc) = f8  with copy, persist
subroutine sGetEncntrID_ByFIN(vFIN)

	declare vReturnEncntrID = f8 with protect
	
	select into "nl:"
	from
		encntr_alias ea
	plan ea
		where ea.alias = vFIN
		and   ea.encntr_id > 0.0
		and   ea.active_ind = 1
		and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
		and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
	order by
		 ea.encntr_id
		,ea.beg_effective_dt_tm desc
	head report
		i = 0
	head ea.encntr_id
		vReturnEncntrID = ea.encntr_id
	with nocounter
	
	return (vReturnEncntrID)

end



/**********************************************************************************************************************
** Function sGetPersonID_ByFIN()
** ---------------------------------------------------------------------------------------
** Returns the person ID for the FIN supplied
**********************************************************************************************************************/
declare sGetPersonID_ByFIN(vFIN=vc) = f8  with copy, persist
subroutine sGetPersonID_ByFIN(vFIN)

	declare vReturnPersonID = f8 with protect
	
	select into "nl:"
	from
		encntr_alias ea
		,encounter e
	plan ea
		where ea.alias = vFIN
		and   ea.encntr_id > 0.0
		and   ea.active_ind = 1
		and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
		and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
	join e
		where e.encntr_id = ea.encntr_id
	order by
		 ea.encntr_id
		,ea.beg_effective_dt_tm desc
	head report
		i = 0
	head ea.encntr_id
		vReturnPersonID = e.person_id
	with nocounter
	
	return (vReturnPersonID)

end


/**********************************************************************************************************************
** Function sGetPersonID_ByEncntrID()
** ---------------------------------------------------------------------------------------
** Returns the person ID for the FIN supplied
**********************************************************************************************************************/
declare sGetPersonID_ByEncntrID(vEncntrID=f8) = f8  with copy, persist
subroutine sGetPersonID_ByEncntrID(vEncntrID)

	declare vReturnPersonID = f8 with protect
	
	select into "nl:"
	from
		encounter e
	plan e
		where e.encntr_id = vEncntrID
	order by
		 e.encntr_id
	head report
		i = 0
	head e.encntr_id
		vReturnPersonID = e.person_id
	with nocounter
	
	return (vReturnPersonID)

end

/**********************************************************************************************************************
** Function sGetFacility_ByEncntrID(encntr_id,[DISPLAY,DESCRIPTION])
** ---------------------------------------------------------------------------------------
** Returns the Facility [display] or description based on the provided encntr_id
**********************************************************************************************************************/
declare sGetFacility_ByEncntrID(vEncntrID=f8,vType=vc(VALUE,"DISPLAY")) = vc  with copy, persist
subroutine sGetFacility_ByEncntrID(vEncntrID,vType)

	declare vReturnFacility = vc with protect
	
	select into "nl:"
	from
		encounter e
	plan e
		where e.encntr_id = vEncntrID
	order by
		 e.encntr_id
	head report
		i = 0
	head e.encntr_id
		if (cnvtupper(vType) = "DESCRIPTION")
			vReturnFacility = uar_get_code_description(e.loc_facility_cd)
		else
			vReturnFacility = uar_get_code_display(e.loc_facility_cd)
		endif
	with nocounter
	
	return (vReturnFacility)

end


/**********************************************************************************************************************
** Function sGetUnit_ByEncntrID(encntr_id,[DISPLAY,DESCRIPTION])
** ---------------------------------------------------------------------------------------
** Returns the Unit [display] or description based on the provided encntr_id
**********************************************************************************************************************/
declare sGetUnit_ByEncntrID(vEncntrID=f8,vType=vc(VALUE,"DISPLAY")) = vc  with copy, persist
subroutine sGetUnit_ByEncntrID(vEncntrID,vType)

	declare vReturnUnit = vc with protect
	
	select into "nl:"
	from
		encounter e
	plan e
		where e.encntr_id = vEncntrID
	order by
		 e.encntr_id
	head report
		i = 0
	head e.encntr_id
		if (cnvtupper(vType) = "DESCRIPTION")
			vReturnUnit = uar_get_code_description(e.loc_nurse_unit_cd)
		else
			vReturnUnit = uar_get_code_display(e.loc_nurse_unit_cd)
		endif
	with nocounter
	
	return (vReturnUnit)

end


/**********************************************************************************************************************
** Function sGetAppts_ByPersonID()
** ---------------------------------------------------------------------------------------
** Returns a list of past or [future] appointments by the PersonID 
**********************************************************************************************************************/
declare sGetAppts_ByPersonID(vPersonID=f8,vDays=i2(VALUE,365),vPastFuture=vc(VALUE,"FUTURE")) = vc  with copy, persist
subroutine sGetAppts_ByPersonID(vPersonID,vDays,vPastFuture)

	call SubroutineLog(build2('start sGetPastAppts_ByPersonID(',vPersonID,',',vDays,',',vPastFuture,')'))
	
	declare vReturnAppts = vc with protect
	declare appt_pass = i2 with protect
	
	free record 651164Reply
	free record 651164Request 
	record 651164Request (
	  1 call_echo_ind = i2   
	  1 program_name = vc  
	  1 advanced_ind = i2   
	  1 query_type_cd = f8   
	  1 query_meaning = vc  
	  1 sch_query_id = f8   
	  1 qual [*]   
	    2 parameter = vc  
	    2 oe_field_id = f8   
	    2 oe_field_value = f8   
	    2 oe_field_display_value = vc  
	    2 oe_field_dt_tm_value = dq8   
	    2 oe_field_meaning_id = f8   
	    2 oe_field_meaning = vc  
	    2 label_text = vc  
	)
	
	free record appointment_list
	record appointment_list
	(
		1 person_id = f8
		1 cnt = i4
		1 qual[*]
			2 scheventid = f8   
			2 scheduleid = f8  
			2 scheduleseq = i4 
			2 schapptid = f8
			2 statemeaning = vc
			2 encounterid = f8  
			2 personid = f8  
			2 bitmask = i4  
			2 schappttypecd = f8   
			2 beg_dt_tm = dq8   
			2 duration = i4  
			2 state = vc   
			2 appt_type = vc
			2 appt_reason = vc
			2 prime_res = vc
			2 location = vc
	)
	
	
	if (vPersonID > 0.0)
	
		set 651164Request->call_echo_ind = 1 
		set 651164Request->advanced_ind = 1
		
		if (cnvtupper(vPastFuture) = "PAST")
			set 651164Request->query_meaning = "APPTINDEXPAS" 
			set 651164Request->program_name = "cov_inqa_appt_index_past" 
			set 651164Request->sch_query_id = 614425
		else
			set 651164Request->query_meaning = "APPTINDEXFUT" 
			set 651164Request->program_name = "cov_inqa_appt_index_future" 
			set 651164Request->sch_query_id = 614426
		endif
		
		set 651164Request->query_type_cd = uar_get_code_by("MEANING",14349,651164Request->query_meaning) 
		 
		set stat = alterlist(651164Request->qual,1) 
		set 651164Request->qual[1].oe_field_value =  vPersonID 
		set 651164Request->qual[1].oe_field_meaning = "PERSON" 
		
		call SubroutineLog("651164Request","record")	
		
		set stat = tdbexecute(600005,652000,651164,"REC",651164Request,"REC",651164Reply) 
		
		call SubroutineLog("651164Reply","record")	
		
		for (j=1 to 651164Reply->query_qual_cnt)
			set appointment_list->person_id = vPersonID
			set appt_pass = 0
			if (vDays > 0)
				if (abs(datetimediff(cnvtdatetime(sysdate),651164reply->query_qual[j].beg_dt_tm,1)) < vDays)
			   		set appt_pass = 1
			 	endif
			else
			  	set appt_pass = 1
			endif
			
			if (appt_pass = 1)
				set appointment_list->cnt = (appointment_list->cnt + 1)
				set stat = alterlist(appointment_list->qual,appointment_list->cnt)
				set appointment_list->qual[appointment_list->cnt].scheventid   		= 651164reply->query_qual[j].hide#scheventid
				set appointment_list->qual[appointment_list->cnt].scheduleid  		= 651164reply->query_qual[j].hide#scheduleid
				set appointment_list->qual[appointment_list->cnt].scheduleseq 	 	= 651164reply->query_qual[j].hide#scheduleseq
				set appointment_list->qual[appointment_list->cnt].schapptid 		= 651164reply->query_qual[j].hide#schapptid
				set appointment_list->qual[appointment_list->cnt].statemeaning 		= 651164reply->query_qual[j].hide#statemeaning
				set appointment_list->qual[appointment_list->cnt].encounterid  		= 651164reply->query_qual[j].hide#encounterid
				set appointment_list->qual[appointment_list->cnt].personid 			= 651164reply->query_qual[j].hide#personid 
				set appointment_list->qual[appointment_list->cnt].bitmask  			= 651164reply->query_qual[j].hide#bitmask
				set appointment_list->qual[appointment_list->cnt].schappttypecd  	= 651164reply->query_qual[j].hide#schappttypecd
				set appointment_list->qual[appointment_list->cnt].beg_dt_tm  		= 651164reply->query_qual[j].beg_dt_tm
				set appointment_list->qual[appointment_list->cnt].duration 			= 651164reply->query_qual[j].duration
				set appointment_list->qual[appointment_list->cnt].state    			= 651164reply->query_qual[j].state
				set appointment_list->qual[appointment_list->cnt].appt_type 		= 651164reply->query_qual[j].appt_type
				set appointment_list->qual[appointment_list->cnt].appt_reason 		= 651164reply->query_qual[j].appt_reason
				set appointment_list->qual[appointment_list->cnt].prime_res 		= 651164reply->query_qual[j].prime_res
				set appointment_list->qual[appointment_list->cnt].location 			= 651164reply->query_qual[j].location
			endif	
		endfor
	endif
	
	set vReturnAppts = cnvtrectojson(appointment_list)
	
	return (vReturnAppts)

end

/**********************************************************************************************************************
** Function sGetInsuranceByEncntrID()
** ---------------------------------------------------------------------------------------
** Returns a JSON object that is convertable to a record structure containting all the insurance information for the
** encounter supplied.  
** 
** INSURANCE_LIST
(
 		1 encntr_id = f8
 		1 person_id = f8
 		1 fin = vc
 		1 insurance
 		 2 primary
 		  3 plan_name = vc
 		  3 group_nbr = vc
 		  3 member_nbr = vc
 		 2 secondary 
 		  3 plan_name = vc
 		  3 group_nbr = vc
 		  3 member_nbr = vc
 		 2 tertiary
 		  3 plan_name = vc
 		  3 group_nbr = vc
 		  3 member_nbr = vc
 		 2 quaternary
 		  3 plan_name = vc
 		  3 group_nbr = vc
 		  3 member_nbr = vc
 		1 plan_cnt = i4
 		1 plan_qual[*]
 		 2 plan_name = vc
 		 2 plan_seq = i4  	
 	) 
** 
** NOTE: The record structure is destroyed on execution. 
**
**********************************************************************************************************************/
declare sGetInsuranceByEncntrID(vEncntrID=f8) = vc  with copy, persist
subroutine sGetInsuranceByEncntrID(vEncntrID)
		
 	free record insurance_list
 	record insurance_list
 	(
 		1 encntr_id = f8
 		1 person_id = f8
 		1 fin = vc
 		1 insurance
 		 2 primary
 		  3 plan_name = vc
 		  3 group_nbr = vc
 		  3 member_nbr = vc
 		 2 secondary 
 		  3 plan_name = vc
 		  3 group_nbr = vc
 		  3 member_nbr = vc
 		 2 tertiary
 		  3 plan_name = vc
 		  3 group_nbr = vc
 		  3 member_nbr = vc
 		 2 quaternary
 		  3 plan_name = vc
 		  3 group_nbr = vc
 		  3 member_nbr = vc
 		1 plan_cnt = i4
 		1 plan_qual[*]
 		 2 plan_name = vc
 		 2 plan_seq = i4 	
 	) with protect
 
	select into "nl:"
	from
		 encounter e
		,encntr_plan_reltn epr
	 	,health_plan hp
	 	,(dummyt d1)
	plan e
		where e.encntr_id = vEncntrID
	join d1
	join epr
	 	where epr.encntr_id = e.encntr_id
	 	and epr.active_ind = 1
	 	and epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	 	and epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	join hp
		where hp.health_plan_id = epr.health_plan_id
		and hp.active_ind = 1
		and hp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
		and hp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	order by
		 e.encntr_id
		,epr.priority_seq
		,epr.beg_effective_dt_tm desc
	head report
		i = 0
	head e.encntr_id
		insurance_list->encntr_id = e.encntr_id
		insurance_list->person_id = e.person_id
	head epr.priority_seq
		case (epr.priority_seq)
			of 1:	insurance_list->insurance.primary.plan_name 		= hp.plan_name
					insurance_list->insurance.primary.group_nbr 		= epr.group_nbr 
					insurance_list->insurance.primary.member_nbr		= epr.member_nbr
			of 2:	insurance_list->insurance.secondary.plan_name 		= hp.plan_name
					insurance_list->insurance.secondary.member_nbr		= epr.member_nbr
					insurance_list->insurance.secondary.group_nbr		= epr.group_nbr
			of 3:   insurance_list->insurance.tertiary.plan_name 		= hp.plan_name
					insurance_list->insurance.tertiary.member_nbr		= epr.member_nbr
					insurance_list->insurance.tertiary.group_nbr		= epr.group_nbr
			of 4:   insurance_list->insurance.quaternary.plan_name 		= hp.plan_name
					insurance_list->insurance.quaternary.group_nbr		= epr.group_nbr
					insurance_list->insurance.quaternary.member_nbr		= epr.member_nbr
		endcase
		insurance_list->plan_cnt = (insurance_list->plan_cnt + 1)
		stat = alterlist(insurance_list->plan_qual,insurance_list->plan_cnt)
		insurance_list->plan_qual[insurance_list->plan_cnt].plan_name = hp.plan_name
		insurance_list->plan_qual[insurance_list->plan_cnt].plan_seq = epr.priority_seq
	foot report
		i = 0
	with nocounter,nullreport,outerjoin=d1
 
 	set insurance_list->fin = sGetFIN_ByEncntrID(insurance_list->encntr_id)
 
	return (cnvtrectojson(insurance_list))
end
 



/**********************************************************************************************************************
** Function sGetPatientDemo(PERSON_ID,ENCNTR_ID)
** ---------------------------------------------------------------------------------------
** Returns a JSON object that is convertable to a record structure containting all the insurance information for the
** encounter supplied.  
** 
** PATIENT_INFO

** 
** NOTE: The record structure is destroyed on execution. 
**
**********************************************************************************************************************/
declare sGetPatientDemo(vPersonID=f8,vEncntrID=f8) = vc  with copy, persist
subroutine sGetPatientDemo(vPersonID,vEncntrID)

call SubroutineLog(build2('start sGetPatientDemo(',vPersonID,',',vEncntrID,')'))	
 	free record patient_info
 	
 	declare _memory_reply_string = vc with noconstant(" "), protect
 	execute mp_get_patient_demo ~MINE~,vPersonID,vEncntrID,0 
 	
 	set stat = cnvtjsontorec(_memory_reply_string)
 	set stat = copyrec(record_data,patient_info,1)
 	
 	call SubroutineLog(build2('end sGetPatientDemo(',vPersonID,',',vEncntrID,')'))
 	return (cnvtrectojson(patient_info))
end 

 
call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go