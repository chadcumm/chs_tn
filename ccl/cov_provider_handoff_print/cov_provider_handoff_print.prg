/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		06/22/2020
	Solution:				
	Source file name:	 	cov_provider_handoff_print.prg
	Object name:		   	cov_provider_handoff_print
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	06/22/2020  Chad Cummings			Initial Deployment
******************************************************************************/
drop program cov_provider_handoff_print go
create program cov_provider_handoff_print

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Report" = 3
	, "List:" = 0.000000 

with OUTDEV, REPORT_TYPE, PATIENT_LIST 


declare debug_ind = i2 with noconstant(1), protect
declare i = i2 with noconstant(0) 


;execute mp_write_app_ini ^MINE^,16908168.0,'600005','Handoff_Print',^^,0 go
;execute MP_PHYS_HAND_PRINT_DRIVER ^MINE^,16908168.0,                0, 0, -1, ^^,1 go

record 600123request (
  1 patient_list_id = f8   
  1 patient_list_type_cd = f8   
  1 best_encntr_flag = i2   
  1 arguments [*]   
    2 argument_name = vc  
    2 argument_value = vc  
    2 parent_entity_name = vc  
    2 parent_entity_id = f8   
  1 encntr_type_filters [*]   
    2 encntr_type_cd = f8   
    2 encntr_class_cd = f8   
  1 patient_list_name = vc  
  1 mv_flag = i2   
  1 rmv_pl_rows_flag = i2   
) 

record 600144request (
  1 patient_list_id = f8   
  1 prsnl_id = f8   
  1 definition_version = i4   
) 


free record t_rec
record t_rec
(
	1 ccl_program = vc
	1 list_type = c1
	1 prompt_patient_list = f8
	1 care_team
	 2 pct_care_team_id = f8
	 2 sourcetype = vc
	 2 facilitycd = f8
	 2 medservicecd = f8
	 2 teamcd = f8
	 2 grouptype = vc
	 2 returnasjson = i2
	 2 return_list = vc
	1 patient_list
	 2 id = f8
	 2 type_cd = f8
	 2 name = vc
	 2 arguments[*]
	  3 argument_name = vc
      3 argument_value= vc
      3 parent_entity_name = vc
      3 parent_entity_id = f8
	1 prsnl_id = f8
	1 application_num = i4
	1 section = vc
	1 parameters = vc
	1 filepath = vc
	1 output = vc
	1 detail_ind = i2
	1 server_ind = i2
	1 unified_content = vc
	1 web_server = vc
	1 error_message = vc
	1 error_ind = i2 
)

free record _memory_reply_string
declare _memory_reply_string = vc with public

call echo(build(trim(curprog),":","setting parameters"))
set t_rec->prsnl_id = reqinfo->updt_id
;set t_rec->prsnl_id = 12297980
set t_rec->application_num = 600005
set t_rec->section = "Handoff_Print"
set t_rec->output = concat("cer_temp:",format(sysdate,"mmddyyyy_hhmm_ss;;q"),"_",trim(cnvtstring(t_rec->prsnl_id)))

set t_rec->detail_ind = $REPORT_TYPE

set t_rec->prompt_patient_list = $PATIENT_LIST

set t_rec->server_ind = 1

if (t_rec->detail_ind in(0,1))
	record print_options(
		1 list_name = vc
		1 user_name = vc
		1 care_team_id = f8
		1 logical_domain_id = f8
		1 prsn_alias = f8
		1 list_id = f8
		1 encntr_alias = f8
		1 type_code = f8
		1 class_code = f8
		1 resuscitation_code = f8
		1 print_template = vc
		1 phys_contact_code = f8
		1 qual[*]
			2 person_id = f8
			2 encntr_id = f8
			2 ppr_cd = f8
			2 location = vc
			2 pat_age = vc
			2 care_team_id = f8
		1 headings[*]
			2 location = vc
			2 patient = vc
			2 ill_sev = vc
			2 phys_contact = vc
			2 diag = vc
			2 code_status = vc
			2 pat_summary = vc
			2 actions = vc
			2 sit_aware = vc
			2 medications = vc
			2 allergies = vc
			2 admit_date = vc
			2 printed = vc
			2 list = vc
			2 found = vc
			2 printed_by = vc
			2 pageNum = vc
			2 phys_handoff = vc
			2 alias_disp = vc
		1 i18nStrings
			2 clinical_event_heading = vc
			2 no_clinical_event_documented = vc
			2 active_diagnoses = vc
			2 allergies_not_recorded = vc
			2 scheduled_heading = vc
			2 continous_heading = vc
			2 prn_unsched_heading = vc
			2 available_to_all = vc
			2 all_facilities = vc
		1 bannerBarEventCodes[*]
			2 event_code = f8
		1 activeDxTypes[*]
			2 dx_type = f8
		1 activeDxClassifications[*]
			2 dx_class = f8
	) with public
	
	set print_options->encntr_alias = uar_get_code_by("MEANING",319,"MRN")
	set print_options->resuscitation_code = uar_get_code_by("MEANING",200,"CODESTATUS")
	
	select into "nl:"
	from
		code_value cv
	plan cv
		where cv.code_set = 93
		and   cv.active_ind = 1
		and   cv.display in(
								"Transition Plan"
							)
	order by
		 cv.display
		,cv.begin_effective_dt_tm desc
		,cv.code_value
	head report
		i = 0
	head cv.display
		i = (i + 1)
		stat = alterlist(print_options->bannerBarEventCodes,i)
		print_options->bannerBarEventCodes[1].event_code = cv.code_value
	with nocounter
	
	set stat = alterlist(print_options->activeDxTypes,1)
	set print_options->activeDxTypes[1].dx_type = uar_get_code_by("MEANING",17,"DISCHARGE")
	
	set stat = alterlist(print_options->activeDxClassifications,1)
	set print_options->activeDxClassifications[1].dx_class = uar_get_code_by("MEANING",12033,"MEDICAL") 
	
	set i = 1
	set stat = alterlist(print_options->headings,i)
	set print_options->headings[i].Location				= "Location"
	set print_options->headings[i].PATIENT				= "Patient"
	set print_options->headings[i].ILL_SEV				= "Illness Severity"
	set print_options->headings[i].PHYS_CONTACT			= "Primary Contact"
	set print_options->headings[i].DIAG					= "Diagnosis"
	set print_options->headings[i].CODE_STATUS			= "Code Status"
	set print_options->headings[i].PAT_SUMMARY			= "Patient Summary"
	set print_options->headings[i].ACTIONS				= "Actions"
	set print_options->headings[i].SIT_AWARE			= "Situational Awareness and Planning"
	set print_options->headings[i].MEDICATIONS			= "Medications"
	set print_options->headings[i].ALLERGIES			= "Allergies"
	set print_options->headings[i].ADMIT_DATE			= "Admit Date"
	set print_options->headings[i].PRINTED				= "Printed:"
	set print_options->headings[i].LIST					= "List:"
	set print_options->headings[i].FOUND				= "** If found, please return to the nearest ward clerk **"
	set print_options->headings[i].PRINTED_BY			= "Printed by:"
	set print_options->headings[i].PAGENUM				= "Page:"
	set print_options->headings[i].PHYS_HANDOFF			= "PHYSICIAN HANDOFF"
	set print_options->headings[i].ALIAS_DISP			= "MRN"
	set print_options->headings[i].ERROR_MSG			= "Error retrieving results"
	
	set print_options->I18NSTRINGS.CLINICAL_EVENT_HEADING="Clinical Event"
	set print_options->I18NSTRINGS.NO_CLINICAL_EVENT_DOCUMENTED="No results found"
	set print_options->I18NSTRINGS.ACTIVE_DIAGNOSES="Active Diagnoses"
	set print_options->I18NSTRINGS.ALLERGIES_NOT_RECORDED="No Allergies Recorded"
	set print_options->I18NSTRINGS.SCHEDULED_HEADING="Scheduled"
	set print_options->I18NSTRINGS.CONTINOUS_HEADING="Continuous"
	set print_options->I18NSTRINGS.PRN_UNSCHED_HEADING="PRN/Unscheduled"
	set print_options->I18NSTRINGS.AVAILABLE_TO_ALL="Available to All"
	set print_options->I18NSTRINGS.ALL_FACILITIES="All Facilities"
	
	set print_options->list_id = t_rec->prompt_patient_list
	
elseif (t_rec->detail_ind in(2,3))

	record print_options(
		1 list_name = vc
		1 CUST_PRINT_CCL = vc
		1 CUST_PRINT_FE = vc
		1 logical_domain_id = f8
		1 PRINT_STYLE = vc
		1 USER_CONTEXT
		 2 USER_ID = f8
		 2 POSITION_CD = f8
		 2 USERNAME = vc
		 2 VIEW_IDENTIFIER = vc
		1 qual[*]
			2 person_id = f8
			2 encntr_id = f8
			2 ppr_cd = f8
			2 location = vc
			2 pat_age = vc
			2 care_team_id = f8
		1 COLUMN_LIST
		 2 columns[*]
		  3 active = i4
		  3 reportMean = vc
		 2 expandedViewPane
		  3 reportID = f8
		  3 filters[*]
		   4 active = vc
		 2 viewIdentifier = vc
		1 CURRENTSORT
		 2 key = vc
		 2 sortOrder = i2
	) with public
	
	if (t_rec->detail_ind = 2)
		set print_options->CUST_PRINT_CCL = "chs_wklist_cust_print_temp"
	elseif (t_rec->detail_ind = 3)
		set print_options->CUST_PRINT_CCL = "chs_wklist_prov_grplist_temp"
	endif

	set print_options->PRINT_STYLE = "simplified"
	set print_options->USER_CONTEXT.USER_ID = t_rec->prsnl_id
	set print_options->USER_CONTEXT.VIEW_IDENTIFIER = "VB_RESPONSIVEPHYSICIANHANDOFFW"
	set print_options->COLUMN_LIST.viewIdentifier = "VB_RESPONSIVEPHYSICIANHANDOFFW"
	set print_options->COLUMN_LIST.expandedViewPane.reportID = 280500310
	set print_options->CURRENTSORT.key = "MP_VB_COL_CONSULTING_CONTACTS"
	set print_options->CURRENTSORT.sortOrder = -1
	
	select into "nl:" 
	from
		prsnl p
	plan p	
		where p.person_id = t_rec->prsnl_id
	detail
		print_options->USER_CONTEXT.POSITION_CD = p.position_cd
		print_options->USER_CONTEXT.USERNAME = p.username
	with nocounter
	
	set i = 18
	set stat = alterlist(print_options->COLUMN_LIST.columns,i)
            set print_options->COLUMN_LIST.columns[1].active= 1,
            set print_options->COLUMN_LIST.columns[1].reportmean= "MP_VB_COL_PATIENT"
			set print_options->COLUMN_LIST.columns[2].active= 0,
            set print_options->COLUMN_LIST.columns[2].reportmean= "MP_VB_COL_CUSTOM1"
			set print_options->COLUMN_LIST.columns[3].active= 1,
            set print_options->COLUMN_LIST.columns[3].reportmean= "MP_VB_COL_CUSTOM3"
			set print_options->COLUMN_LIST.columns[4].active= 0,
            set print_options->COLUMN_LIST.columns[4].reportmean= "MP_VB_COL_DIAGNOSES"
			set print_options->COLUMN_LIST.columns[5].active= 0,
            set print_options->COLUMN_LIST.columns[5].reportmean= "MP_VB_COL_ILL_SEVERITY"
			set print_options->COLUMN_LIST.columns[6].active= 0,
            set print_options->COLUMN_LIST.columns[6].reportmean= "MP_VB_COL_IPASS_ACTIONS"
			set print_options->COLUMN_LIST.columns[7].active= 0,
            set print_options->COLUMN_LIST.columns[7].reportmean= "MP_VB_COL_ISOLATION"
			set print_options->COLUMN_LIST.columns[8].active= 0,
            set print_options->COLUMN_LIST.columns[8].reportmean= "MP_VB_COL_LOCATION"
			set print_options->COLUMN_LIST.columns[9].active= 0,
            set print_options->COLUMN_LIST.columns[9].reportmean= "MP_VB_COL_PRIMARY_CONTACT"
			set print_options->COLUMN_LIST.columns[10].active= 1,
            set print_options->COLUMN_LIST.columns[10].reportmean= "MP_VB_COL_CATHETER"
			set print_options->COLUMN_LIST.columns[11].active= 0,
            set print_options->COLUMN_LIST.columns[11].reportmean= "MP_VB_COL_TELEMETRY"
			set print_options->COLUMN_LIST.columns[12].active= 0,
            set print_options->COLUMN_LIST.columns[12].reportmean= "MP_VB_COL_VISIT"
			set print_options->COLUMN_LIST.columns[13].active= 0,
            set print_options->COLUMN_LIST.columns[13].reportmean= "MP_VB_COL_CUSTOM4"
			set print_options->COLUMN_LIST.columns[14].active= 1,
            set print_options->COLUMN_LIST.columns[14].reportmean= "MP_VB_COL_CUSTOM5"
			set print_options->COLUMN_LIST.columns[15].active= 0,
            set print_options->COLUMN_LIST.columns[15].reportmean= "MP_VB_COL_MED_HX"
			set print_options->COLUMN_LIST.columns[16].active= 0,
            set print_options->COLUMN_LIST.columns[16].reportmean= "MP_VB_COL_CENTRAL_LINE"
			set print_options->COLUMN_LIST.columns[17].active= 0,
            set print_options->COLUMN_LIST.columns[17].reportmean= "MP_VB_COL_CONSULTING_CONTACTS"
			set print_options->COLUMN_LIST.columns[18].active= 1,
            set print_options->COLUMN_LIST.columns[18].reportmean= "MP_VB_COL_CARE_TEAM"
	
endif

if (t_rec->server_ind = 1)
	set t_rec->unified_content = "http://_wasea_/mpage-content/UnifiedContent"
	set t_rec->web_server = concat("http://_wasea_/mpage-content/",trim(cnvtlower(curdomain)),".chs_tn.cernerasp.com/")
	if (trim(cnvtlower(curdomain)) = "p0665")
		set t_rec->unified_content = replace(t_rec->unified_content,"_wasea_","chstnea")
	else
		set t_rec->unified_content = replace(t_rec->unified_content,"_wasea_","chstneanp")
	endif
endif

if (t_rec->prompt_patient_list = 0.0)
	set t_rec->list_type = "C"
	set t_rec->care_team.pct_care_team_id = -1.0
	set t_rec->care_team.sourcetype = "CT"
	set t_rec->care_team.facilitycd	 = 0.0 
	set t_rec->care_team.medservicecd = 0.0
	set t_rec->care_team.teamcd = 0.0
	set t_rec->care_team.grouptype = ""
	set t_rec->care_team.returnasjson = 1
else
	select into "nl:"
	from
		pct_care_team pct
	plan pct 
		where pct.pct_care_team_id = t_rec->prompt_patient_list
	detail
		t_rec->care_team.pct_care_team_id 	= pct.pct_care_team_id
		t_rec->care_team.sourcetype 		= "CT"
		t_rec->care_team.facilitycd 		= pct.facility_cd
		t_rec->care_team.medservicecd		= pct.pct_med_service_cd
		t_rec->care_team.teamcd 			= pct.pct_team_cd
		t_rec->care_team.grouptype 			= ""
		t_rec->care_team.returnasjson 		= 1
	with nocounter
	
	if (t_rec->care_team.pct_care_team_id > 0.0)
		set t_rec->list_type = "C"
	else
		set t_rec->list_type = "P"
		set t_rec->patient_list.id = t_rec->prompt_patient_list
	endif
	
endif

if (t_rec->list_type = "C")
	call echo(build(trim(curprog),":","->starting mp_wklist_get_list_patients"))
	execute mp_wklist_get_list_patients 
		 'MINE'								;"Output to File/Printer/MINE" :: "MINE"
		,t_rec->prsnl_id					;"Personnel Id" :: 0.0
		,t_rec->care_team.pct_care_team_id	;"Source Id" :: 0.0
		,t_rec->care_team.sourcetype		;"Source Type" :: ""
		,t_rec->care_team.facilitycd		;"Source Facility Code" :: 0.0
		,t_rec->care_team.medservicecd		;"Source Medical Service Code" :: 0.0
		,t_rec->care_team.teamcd			;"Source Team Code" :: 0.0
		,t_rec->care_team.grouptype			;"Group Type" :: ""
		,t_rec->care_team.returnasjson		;"Return as JSON" :: 0
	
	set stat = cnvtjsontorec(_memory_reply_string)
	call echo(_memory_reply_string)
	call echo(build(trim(curprog),":","<-finished mp_wklist_get_list_patients"))
	
	set print_options->list_name = "My Assigned Patients"
	
	if (record_data->cnt = 0)
		set t_rec->error_message = "No assigned patients were returned"
		set t_rec->error_ind = 1
		go to exit_script
	endif
	
	for (i=1 to record_data->cnt)
		set stat = alterlist(print_options->qual,i)
		set print_options->qual[i].person_id = record_data->qual[i].patientid
		set print_options->qual[i].encntr_id = record_data->qual[i].encounterid
	endfor
	call echorecord(print_options)
	
	set t_rec->parameters = cnvtrectojson(print_options)
	free record record_data
	set _memory_reply_string = ""
endif

if ((t_rec->patient_list.id > 0.0) and (t_rec->list_type = "P"))
	call echo(build(trim(curprog),":","->inside patient list qualifier"))
	free record 600123reply
	set stat = initrec(600123request)

	free record 600144reply
	set stat = initrec(600144request)
	
	call echo(build(trim(curprog),":","->calling dcp query"))
	select into "nl:"
	from dcp_patient_list dpl
	plan dpl
		where dpl.patient_list_id = t_rec->patient_list.id
	detail
		t_rec->patient_list.type_cd = dpl.patient_list_type_cd
		t_rec->patient_list.name = dpl.name		
	with nocounter
	
	set 600144request->prsnl_id = t_rec->prsnl_id
	set 600144request->patient_list_id = t_rec->patient_list.id
	set 600144request->definition_version = 1
	
	call echo(build(trim(curprog),":","->executing 600144"))
	set stat = tdbexecute(600005,600024,600144,"REC",600144request,"REC",600144reply)
	call echorecord(600144reply)
	
	for (i=1 to size(600144reply->arguments,5))
		set stat = alterlist(t_rec->patient_list.arguments,i)
		set t_rec->patient_list->arguments[i].argument_name = 600144reply->arguments[i].argument_name
		set t_rec->patient_list->arguments[i].argument_value = 600144reply->arguments[i].argument_value
		set t_rec->patient_list->arguments[i].parent_entity_name = 600144reply->arguments[i].parent_entity_name
		set t_rec->patient_list->arguments[i].parent_entity_id = 600144reply->arguments[i].parent_entity_id
	endfor
	
	set 600123request->patient_list_id = t_rec->patient_list.id
	set 600123request->patient_list_type_cd = t_rec->patient_list.type_cd
	set 600123request->patient_list_name = t_rec->patient_list.name
	set 600123request->mv_flag = -1
	
	if (size(t_rec->patient_list.arguments,5) > 0)
		for (i=1 to size(t_rec->patient_list.arguments,5))
			set stat = alterlist(600123request->arguments,i)
			set 600123request->arguments[i].argument_name = t_rec->patient_list.arguments[i].argument_name
			set 600123request->arguments[i].argument_value = t_rec->patient_list.arguments[i].argument_value
			set 600123request->arguments[i].parent_entity_name = t_rec->patient_list.arguments[i].parent_entity_name
			set 600123request->arguments[i].parent_entity_id = t_rec->patient_list.arguments[i].parent_entity_id
		endfor	
	else
		set i = 1
		set stat = alterlist(600123request->arguments,i)
		set 600123request->arguments[i].argument_name = "prsnl_id"
		set 600123request->arguments[i].argument_value = ""
		set 600123request->arguments[i].parent_entity_name = "PRSNL"
		set 600123request->arguments[i].parent_entity_id = t_rec->prsnl_id
	endif

	set stat = tdbexecute(600005,600024,600123,"REC",600123request,"REC",600123reply)
	call echo(build(trim(curprog),":","->finished calling patient list"))
	/*call echorecord(600123reply)
			1 patient_list_id = f8
			1 name = vc
			1 description = vc
			1 patient_list_type_cd = f8
			1 owner_id = f8
			1 prsnl_access_cd = f8
			1 execution_dt_tm = dq8			;002
			1 execution_status_cd = f8		;002
			1 execution_status_disp = vc	;002
			1 arguments[*]
				2 argument_name = vc
				2 argument_value = vc
				2 parent_entity_name = vc
				2 parent_entity_id = f8
			1 encntr_type_filters[*]
				2 encntr_type_cd = f8
			1 patients[*]
				2 person_id = f8
		*/
	
	set print_options->list_name = t_rec->patient_list.name
	if (size(600123reply->patients,5) = 0)
		set t_rec->error_message = "No patients were returned from the Patient List"
		set t_rec->error_ind = 1
		go to exit_script
	endif
	for (i=1 to size(600123reply->patients,5))
		set stat = alterlist(print_options->qual,i)
		set print_options->qual[i].person_id = 600123reply->patients[i].person_id
		set print_options->qual[i].encntr_id = 600123reply->patients[i].encntr_id
	endfor
	call echorecord(print_options)
	set t_rec->parameters = cnvtrectojson(print_options)
	call echo(build(trim(curprog),":","->exiting patient list section"))
endif
call echorecord(print_options)

/*
;uncomment to import from json from backend
;set t_rec->filepath = "ccluserdir:handoff_template_select.json" 
;set t_rec->filepath = "ccluserdir:cust_handoff_print.json" 
;set t_rec->filepath = "ccluserdir:handoff_print.json" 
;set t_rec->filepath = "ccluserdir:handoff_det_print.json" 
set t_rec->filepath = "ccluserdir:handoff.json" 

free record print_options
free set requestin 
declare line_in = vc 
free define rtl3 
define rtl3 is t_rec->filepath 
select into "nl:"
from rtl3t r
detail
	line_in = concat(line_in,r.line)
with nocounter 

set stat = cnvtjsontorec(line_in) 
call echorecord(PRINT_OPTIONS)

set t_rec->parameters = line_in
*/


declare detailFlag = f8 with public
declare printTemplate = vc with public


call echo(build(trim(curprog),":","->starting mp_write_app_ini"))
execute mp_write_app_ini 
	 ^MINE^
	,value(t_rec->prsnl_id)					;Provider ID
	,value(cnvtstring(t_rec->application_num))	;Application
	,value(t_rec->section)						;Section
	,value(t_rec->parameters)					;Param Data
	,1											;MPages Utilities EJS cache teamNamespace
call echo(build(trim(curprog),":","<-finished mp_write_app_ini"))
/*
$OUTDEV :: "Output to File/Printer/MINE" :: "MINE"
$PERSONID :: "Person Id:" :: 0.0
$DETAILFLAG :: "Detail Flag:" :: ""
$CARETEAMLISTTYPE :: "Care Team List Type" :: 0
$CROSSENCOUNTERIPASS :: "Cross Encounter Ipass" :: 0
$GROUPTYPE :: "Group Type" :: "NONE"
$GETPATLOC :: "Retrieve Patient Location" :: 0
$OVERRIDEUNIFIEDCONTENT :: "Override Unified Content Path" :: ""
$OVERRIDEWEBSERVERURL :: "Override Worklist Content Path" :: ""
$I18NOVERRIDE :: "i18n Override" :: ""
$RETAINPRINTDATA :: "Retain print data from Application_ini" :: 0
*/

if (t_rec->detail_ind in(1,2,3))
	call echo(build(trim(curprog),":","->starting detail mp_phys_hand_print_driver"))
	execute mp_phys_hand_print_driver 
	 ^MINE^
	,value(t_rec->prsnl_id)		;"Person Id:" = 0.0
	,t_rec->detail_ind				;"Detail Flag:" = ""
	,0								;"Care Team List Type" = 0
	,-1								;"Cross Encounter Ipass" = 0
	,^^								;"Group Type" = "NONE"
	,1								;"Retrieve Patient Location" = 0
	,t_rec->unified_content	;"Override Unified Content Path" = "" 
	,t_rec->web_server		;"Override Worklist Content Path" = ""
	,^^
	,1
	
	call echo(build2("detailFlag=",detailFlag))
	call echo(build2("printTemplate=",printTemplate))
	call echo(build2("_memory_reply_string=",_memory_reply_string))

	free record putREQUEST
		record putREQUEST (
			1 source_dir = vc
			1 source_filename = vc
			1 nbrlines = i4
			1 line [*]
				2 lineData = vc
			1 OverFlowPage [*]
				2 ofr_qual [*]
					3 ofr_line = vc
			1 IsBlob = c1
			1 document_size = i4
			1 document = gvc
		)
 
		; Set parameters for displaying the file
		set putRequest->source_dir = $outdev
		;set putRequest->source_filename = t_rec->output
		set putRequest->IsBlob = "1"
		set putRequest->document = trim(_memory_reply_string)
		set putRequest->document_size = size(putRequest->document)
 
		;  Display the file.  This allows XmlCclRequest to receive the output
		execute eks_put_source with replace(Request,putRequest),replace(reply,putReply)
else
	call echo(build(trim(curprog),":","->starting simple mp_phys_hand_print_driver"))
	execute mp_phys_hand_print_driver 
	 $OUTDEV
	,value(t_rec->prsnl_id)		;"Person Id:" = 0.0
	,t_rec->detail_ind				;"Detail Flag:" = ""
	,0								;"Care Team List Type" = 0
	,-1								;"Cross Encounter Ipass" = 0
	,^^								;"Group Type" = "NONE"
	,1								;"Retrieve Patient Location" = 0
	,^^								;"Override Unified Content Path" = "" 
	,^^								;"Override Worklist Content Path" = ""
endif

#exit_script

if (t_rec->error_ind != 0)
	select into $OUTDEV
	
		from dummyt d1
		plan d1
		head report
			col 0 t_rec->error_message
		with nocounter,separator = " ", format
endif

call echorecord(t_rec)
call echorecord(print_options)

#final_exit_script

call echo(build(trim(curprog),":","->exiting script"))
end go
