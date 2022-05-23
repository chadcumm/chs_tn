/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			Perioperative
	Source file name:	cov_rpt_hrts_tt.prg
	Object name:		cov_rpt_hrts_tt
	Request #:
 
	Program purpose:
 
	Executing from:		CCL
 
 	Special Notes:		Called by ccl program(s).  Formerly: cov_rpt_op_readiness_dev
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	03/30/2020  Chad Cummings			Initial Release
001		10/14/2020 	Chad Cummings			NUMCONFC19COSPPATS for hrts_v4
002		10/14/2020 	Chad Cummings			Added Influenza Results to t2_output
003		10/14/2020 	Chad Cummings			Added Influenza Results hrts v4
004		10/21/2020 	Chad Cummings			corrected q4_ed_of_conf_susp_wait for hrts
005		10/22/2020 	Chad Cummings			corrected q1_total-CURRENT_POS = CURRENT_PEND
006		11/02/2020  Chad Cummings			updated to use positive_onset_dt_tm
007     11/20/2020  Chad Cummings			removed sorting on summary output
008     12/01/2020  Chad Cummings			udpated hrts v4 to have nshn covid death
009     12/09/2020  Chad Cummings			added address and phone to t2_output
010     01/05/2020  Chad Cummings			added accommodation code
011     08/12/2021  Chad Cummings			Added covid-19 vaccine information
012     09/20/2021  Chad Cummings			Added covid-19 date tests and symptoms
******************************************************************************/
 
drop program cov_rpt_hrts_tt:dba go
create program cov_rpt_hrts_tt:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Include All Facilities" = 0
	, "Facilitiy" = 0
	, "Run Historically" = 0
	, "Begin Date and Time" = "SYSDATE"
	, "End Date and Time" = "SYSDATE"
	, "Report Option" = 0
 
with OUTDEV, ALL_FACILITIES, FACILITY, HISTORY_IND, BEG_DT_TM, END_DT_TM,
	REPORT_OPTION
 
 
call echo(build("loading script:",curprog	))
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
)
endif
 
set reply->status_data.status = "F"
 
call set_codevalues(null)
call check_ops(null)
 
free set t_rec
record t_rec
(
	1 curprog					= vc
	1 custom_code_set			= i4
	1 records_attachment		= vc
	1 request					= vc
	1 program_log				= vc
	1 cnt						= i4
	1 prompt_outdev				= vc
	1 output_var				= vc
	1 output_filename			= vc
	1 output_total				= i2
	1 temp_name					= vc
	1 crlf						= vc
	1 report_type_cnt			= i2
	1 report_type_qual[*]
	 2 display					= vc
	 2 type_ind					= i2
	 2 prompt_report_type		= i2
	1 output_cnt				= i2
	1 output_qual[*]
	 2 output_file				= vc
	 2 name						= vc
	 2 prompt_report_type		= i2
	 2 type_ind					= i2
	1 collection_cnt			= i2
	1 collection_qual[*]
	 2 type_ind					= i2
	 2 filename					= vc
	 2 name						= vc
	 2 dclcom					= vc
	 2 status_ind				= i2
	 2 msg_body					= vc
	 2 msg_subject				= vc
	 2 msg_contenttype			= vc
	1 email_dist_cnt			= i2
	1 email_dist[*]
	 2 email_address			= vc
	 2 type_ind					= i2
	 2 attachment				= vc
	 2 subject					= vc
	1 prompt_report_type		= i2
	1 prompt_summary_ind		= i2
	1 prompt_all_fac_ind		= i2
	1 prompt_loc_cnt			= i2
	1 prompt_historical_ind		= i2
	1 prompt_beg_dt_tm			= dq8
	1 prompt_end_dt_tm			= dq8
	1 prompt_loc_qual[*]
	 2 location_cd 				= f8
	 2 location_type_cd			= f8
	1 location_label_cnt		= i2
	1 location_label_qual[*]
	 2 location_cd				= f8
	 2 display					= vc
	 2 alias_type_meaning		= vc
	 2 alias					= vc
	1 diagnosis_search_cnt		= i2
	1 diagnosis_search_qual[*]
	 2 search_description		= vc
	 2 search_string			= vc
	 2 source_vocabulary_cnt	= i2
	 2 source_vocabulary_qual[*]
	  3 display					= vc
	  3 source_vocabulary_cd	= f8
	1 diagnosis_cnt				= i2
	1 diagnosis_qual[*]
	 2 nomenclature_id			= f8
	 2 source_string			= vc
	 2 diagnosis_display		= vc
	 2 source_vocabulary_cd		= f8
	1 encntr_type
	 2 ip_cnt					= i2
	 2 ip_qual[*]
	  3 encntr_type_cd			= f8
	 2 ed_cnt					= i2
	 2 ed_qual[*]
	  3 encntr_type_cd			= f8
	1 vent
	 2 stock_cnt				= i2
	 2 stock_qual[*]
	  3 model_name				= vc
	  3 vent_type				= c1
	 2 model_cnt				= i2
	 2 model_qual[*]
	  3 event_cd				= f8
	  3 vent_type				= c1
	 2 result_cnt				= i2
	 2 result_qual[*]
	  3 event_cd				= f8
	  3 lookback_hrs			= i2
	  3 vent_type				= c1
	1 admit_start_dt_tm			= dq8
	1 admit_end_dt_tm			= dq8
	1 admit_cnt					= i2
	1 admit_qual[*]
	 2 location_cd				= f8
	 2 facility					= vc
	 2 count					= i2
	 2 encntr_cnt				= i2
	 2 encntr_qual[*]
	  3 encntr_id				= f8
	  3 person_id				= f8
	  3 positive_ind			= i2	;1 lab result, 2 diagnosis
	  3 lab_results_cnt			= i2
	  3 lab_results_qual[*]
	  	4 event_id				= f8
	  	4 event_cd				= f8
	  	4 task_assay_cd			= f8
	  	4 order_id				= f8
	  	4 result_val			= vc
	  	4 event_tag				= vc
	  	4 comment				= vc
	  	4 event_end_dt_tm		= dq8
	  	4 valid_from_dt_tm		= dq8
	  	4 clinsig_updt_dt_tm	= dq8
	  	4 result_ignore			= i2
	  3 diagnosis_cnt			= i2
	  3 diagnosis_qual[*]
	   	4 diagnosis_id			= f8
	  	4 source_string			= vc
	  	4 diagnosis_display		= vc
	  	4 nomenclature_id		= f8
	  	4 orig_nomenclature_id	= f8
	  	4 orig_source_string	= vc
	  	4 daig_dt_tm			= dq8
	1 ed_start_dt_tm			= dq8
	1 ed_end_dt_tm				= dq8
	1 emerg_cnt					= i2
	1 emerg_qual[*]
	 2 location_cd				= f8
	 2 facility					= vc
	 2 count					= i2
	 2 encntr_cnt				= i2
	 2 encntr_qual[*]
	  3 encntr_id				= f8
	  3 person_id				= f8
	  3 positive_ind			= i2	;1 lab result, 2 diagnosis
	  3 suspected_ind			= i2
	  3 lab_results_cnt			= i2
	  3 lab_results_qual[*]
	  	4 event_id				= f8
	  	4 event_cd				= f8
	  	4 task_assay_cd			= f8
	  	4 order_id				= f8
	  	4 result_val			= vc
	  	4 event_tag				= vc
	  	4 comment				= vc
	  	4 event_end_dt_tm		= dq8
	  	4 valid_from_dt_tm		= dq8
	  	4 clinsig_updt_dt_tm	= dq8
	  	4 result_ignore			= i2
	  3 diagnosis_cnt			= i2
	  3 diagnosis_qual[*]
	   	4 diagnosis_id			= f8
	  	4 source_string			= vc
	  	4 diagnosis_display		= vc
	  	4 nomenclature_id		= f8
	  	4 orig_nomenclature_id	= f8
	  	4 orig_source_string	= vc
	  	4 daig_dt_tm			= dq8
	1 death_start_dt_tm			= dq8
	1 death_cnt					= i2
	1 death_qual[*]
	 2 location_cd				= f8
	 2 facility					= vc
	 2 count					= i2
	;002 start
	1 flu
	 2 result_cnt				= i2
	 2 result_qual[*]
	  3 event_cd				= f8
	;002 end
 
	1 covid19
	 2 expired_lookback_ind		= i2
	 2 expired_lookback_hours	= i2
	 2 expired_start_dt_tm		= dq8
	 2 expired_end_dt_tm		= dq8
	 2 admission_lookback_ind	= i2
	 2 admission_lookback_hours	= i2
	 2 admission_start_dt_tm	= dq8
	 2 admission_end_dt_tm		= dq8
	 2 onset_lookback_ind	  	= i2
	 2 onset_lookback_hours		= i2
	 2 onset_start_dt_tm		= dq8
	 2 onset_end_dt_tm			= dq8
	 2 positive_cnt				= i2
	 2 positive_qual[*]
	  3 result_val				= vc
	 2 result_cnt				= i2
	 2 result_qual[*]
	  3 event_cd				= f8
	 2 iso_oc_cnt				= i2
	 2 iso_oc_qual[*]
	  3 catalog_cd				= f8
	  3 activity_type_cd		= f8
	  3 catalog_type_cd			= f8
	 2 iso_status_cnt			= i2
	 2 iso_status_qual[*]
	  3 order_status_cd			= f8
	 2 iso_include_cnt			= i2
	 2 iso_include_qual[*]
	  3 oe_field_id				= f8
	  3 oe_field_value			= f8
	  3 oe_field_value_display	= vc
	 2 covid_oc_cnt				= i2
	 2 covid_oc_qual[*]
	  3 catalog_cd				= f8
	  3 activity_type_cd		= f8
	  3 catalog_type_cd			= f8
	 2 covid_status_cnt			= i2
	 2 covid_status_qual[*]
	  3 order_status_cd			= f8
	 2 covid_ignore_cnt			= i2
	 2 covid_ignore_qual[*]
	  3 oe_field_id				= f8
	  3 oe_field_value			= f8
	  3 oe_field_value_display	= vc
	;011 start
	 2 vaccine_result_cnt		= i2
	 2 vaccine_result_qual[*]
	  3 event_cd				= f8
	 2 vaccine_yesno_cnt		= i2
	 2 vaccine_yesno_qual[*]
	  3 event_cd				= f8
	;011 end
	;012 start
	 2 symptom_result_cnt		= i2
	 2 symptom_result_qual[*]
	  3 event_cd				= f8
	 2 date_tested_cnt			= i2
	 2 date_tested_qual[*]
	  3 event_cd				= f8
	;012 end
	1 pso
	 2 ip_pso_cnt				= i2
	 2 ip_pso_qual[*]
	  3 catalog_cd				= f8
	  3 activity_type_cd		= f8
	  3 catalog_type_cd			= f8
	 2 ip_pso_status_cnt		= i2
	 2 ip_pso_status_qual[*]
	  3 order_status_cd			= f8
	 2 ob_pso_cnt				= i2
	 2 ob_pso_qual[*]
	  3 catalog_cd				= f8
	  3 activity_type_cd		= f8
	  3 catalog_type_cd			= f8
	 2 ob_pso_status_cnt		= i2
	 2 ob_pso_status_qual[*]
	  3 order_status_cd			= f8
	1 patient_cnt				= i2
	1 patient_qual[*]
	 2 encntr_id				= f8
	 2 person_id				= f8
	 2 birth_dt_tm				= dq8
	 2 age_in_years				= i2
	 2 cov_facility_alias		= vc
	 2 cov_unit_alias			= vc
	 2 cov_room_alias			= vc
	 2 cov_bed_alias			= vc
	 2 loc_facility_cd			= f8
	 2 loc_unit_cd				= f8
	 2 loc_room_cd				= f8
	 2 loc_bed_cd				= f8
	 2 loc_class_1				= vc
	 2 encntr_type_cd			= f8
	 2 disch_disposition_cd		= f8
	 2 expired_ind				= i2
	 2 previous_admission_ind	= i2
	 2 previous_onset_ind		= i2
	 2 previous_onset_conf_ind	= i2
	 2 expired_dt_tm			= dq8
	 2 reg_dt_tm				= dq8
	 2 disch_dt_tm				= dq8
	 2 inpatient_dt_tm			= dq8
	 2 observation_dt_tm		= dq8
	 2 arrive_dt_tm				= dq8
	 2 dob						= dq8
	 2 positive_onset_dt_tm		= dq8
	 2 suspected_onset_dt_tm	= dq8
	 2 flu_onset_dt_tm			= dq8 ;002
	 2 ip_los_hours				= i2
	 2 ip_los_days				= i2
	 2 fin						= vc
	 2 name_full_formatted		= vc
	 2 accommodation			= vc	;010
	 2 encntr_ignore			= i2
	 2 historic_ind				= i2
	 2 orders_cnt				= i2
	 2 orders_qual[*]
	  3 order_id				= f8
	  3 catalog_cd				= f8
	  3 order_mnemonic			= vc
	  3 order_status_cd			= f8
	  3 order_status_display	= vc
	  3 orig_order_dt_tm		= dq8
	  3 order_status_dt_tm		= dq8
	  3 activity_type_cd		= f8
	  3 catalog_type_cd			= f8
	  3 order_ignore			= i2
	  3 order_detail_cnt		= i2
	  3 order_detal_qual[*]
	   4 oe_field_id			= f8
	   4 oe_field_value			= f8
	   4 oe_field_display_value	= vc
	   4 oe_field_dt_tm_value	= dq8
	 2 lab_results_cnt			= i2
	 2 lab_results_qual[*]
	  3 event_id				= f8
	  3 event_cd				= f8
	  3 task_assay_cd			= f8
	  3 order_id				= f8
	  3 result_val				= vc
	  3 event_tag				= vc
	  3 comment					= vc
	  3 event_end_dt_tm			= dq8
	  3 valid_from_dt_tm		= dq8
	  3 clinsig_updt_dt_tm		= dq8
	  3 result_ignore			= i2
	 ;002 start
	 2 flu_results_cnt			= i2
	 2 flu_results_qual[*]
	  3 event_id				= f8
	  3 event_cd				= f8
	  3 task_assay_cd			= f8
	  3 order_id				= f8
	  3 result_val				= vc
	  3 event_tag				= vc
	  3 comment					= vc
	  3 event_end_dt_tm			= dq8
	  3 valid_from_dt_tm		= dq8
	  3 clinsig_updt_dt_tm		= dq8
	  3 result_ignore			= i2
	 ;002 end
	 2 vent_results_cnt			= i2
	 2 vent_results_qual[*]
	  3 event_id				= f8
	  3 event_cd				= f8
	  3 task_assay_cd			= f8
	  3 order_id				= f8
	  3 result_val				= vc
	  3 event_tag				= vc
	  3 comment					= vc
	  3 ventilator_type			= c1
	  3 event_end_dt_tm			= dq8
	  3 model_event_id			= f8
	  3 model_event_cd			= f8
	  3 model_result_val		= vc
	  3 covenant_stock_ind		= i2
	  3 result_ignore			= i2
	 2 diagnosis_cnt			= i2
	 2 diagnosis_qual[*]
	  3 diagnosis_id			= f8
	  3 source_string			= vc
	  3 diagnosis_display		= vc
	  3 nomenclature_id			= f8
	  3 orig_nomenclature_id	= f8
	  3 orig_source_string		= vc
	  3 daig_dt_tm				= dq8
	 2 encntr_loc_cnt = i2
 	 2 encntr_loc_qual[*]
  	  3 loc_facility_cd 	= f8
  	  3 loc_unit_cd 		= f8
  	  3 facility			= vc
  	  3 unit				= vc
  	  3 beg_dt_tm			= dq8
  	  3 end_dt_tm			= dq8
  	  3 encntr_loc_hist_id	= f8
  	 2 patient_phone_num		= vc	;009
	 2 patient_address_county	= vc	;009
	 2 patient_gender			= vc	;009
	 2 patient_race				= vc	;009
	 2 patient_ethnicity		= vc	;009
	 2 isolation_days			= vc	;009
	 2 covid19_vaccine_event_id	= f8	;011
	 2 covid19_vaccine_dt_tm	= dq8	;011
	 2 covid19_vaccine			= vc	;011
	 2 covid19_vax_yesno_e_id	= f8	;011
	 2 covid19_vax_yesno_dt_tm	= dq8	;011
	 2 covid19_vax_yesno		= vc	;011
	 2 symptom_result_event_id	= f8	;012
	 2 symptom_result_dt_tm		= dq8	;012
	 2 symptom_result			= vc	;012
	 2 date_tested_event_id		= f8	;012
	 2 date_tested_dt_tm		= dq8	;012
	 2 date_tested				= vc	;012
)
 
free record hrts_covid19
record hrts_covid19
(
	1 summary_cnt					= i2
	1 summary_qual[*]
	 2 facility						= vc
	 2 q1_total_pos_inp				= i2
	 2 q1_1_icu_pos_inp				= i2
	 2 q1_2_pos_inp_vent			= i2
	 2 q2_total_pend_inp			= i2
	 2 q2_1_icu_pend_inp			= i2
	 2 q2_2_pend_inp_vent			= i2
	1 patient_cnt 				= i2
	1 patient_qual[*]
	 2 encntr_id				= f8
	 2 person_id				= f8
	 2 patient_name				= vc
	 2 fin						= vc
	 2 facility					= vc
	 2 unit						= vc
	 2 room_bed					= vc
	 2 location_class_1			= vc
	 2 encntr_type				= vc
	 2 expired_dt_tm			= vc
	 2 reg_dt_tm				= vc
	 2 disch_dt_tm				= vc
	 2 inpatient_dt_tm			= vc
	 2 observation_dt_tm		= vc
	 2 arrive_dt_tm				= vc
	 2 pso						= vc
	 2 los_days					= i2
	 2 diagnosis				= vc
	 2 covid19_order			= vc
	 2 covid19_result			= vc
	 2 ventilator_result		= vc
	 2 ventilator_model			= vc
	 2 suspected				= c1
	 2 confirmed				= c1
	 2 ventilator			    = c1
	 2 ventilator_invasive		= c1
	 2 covenant_vent_stock		= c1
	 2 ip_pso					= c1
	 2 expired					= c1
	 2 historical				= c1
	 2 prev_admission			= c1
	 2 prev_onset				= c1
	 2 prev_onset_conf			= c1
	 2 hosp_susp_onset			= c1
	 2 hosp_conf_onset			= c1
)
 
free record nhsn_covid19
record nhsn_covid19
(
	1 summary_cnt					= i2
	1 summary_qual[*]
	 2 facility						= vc
	 2 qa_numc19confnewadm			= i2
	 2 qb_numc19suspnewadm			= i2
	 2 qc_numc19honewpats			= i2
	 2 q1_ip_confirmed				= i2
	 2 q1_ip_suspected				= i2
	 2 q1_total						= i2	;numc19hosppats
	 2 q2_ip_confirmed_vent			= i2
	 2 q2_ip_suspected_vent			= i2
	 2 q2_total						= i2	;numc19mechventpats
	 2 q3_ip_conf_susp_los14		= i2	;numc19hopats
	 2 q3_ip_conf_los14				= i2	;numc19hopats_conf
	 2 q4_ed_of_conf_susp_wait		= i2	;numc19overflowpats
	 2 q4_ed_of_conf_wait			= i2	;numconfc19overflowpats
	 2 q5_ed_of_conf_susp_wait_vent = i2	;numc19ofmechventpats
	 2 q5_ed_of_conf_wait_vent		= i2	;numconfc19ofmechventpats
	 2 q6_disch_expired				= i2	;numc19prevdied
	 2 q6a_all_expired				= i2	;numc19died
	 2 q7_all_beds_total			= i2	;numtotbeds
	 2 q8_all_beds_total_surge		= i2	;numbeds
	 2 q9_occupied_ip_beds			= i2	;numbedsocc
	 2 q10_avail_icu_beds			= i2	;numicubeds
	 2 q11_occupied_icu_beds		= i2	;numicubedsocc
	 2 q12_ventilator_total			= i2	;numvent
	 2 q13_ventilator_in_use		= i2	;numventuse
	 2 qd_numc19honsetprev			= i2	;new hospital onset with confirmed
	 2 q_icu_pos_inp				= i2
	 2 q_icu_susp_inp				= i2
	 2 q_icu_total					= i2
	1 patient_cnt 				= i2
	1 patient_qual[*]
	 2 encntr_id				= f8
	 2 person_id				= f8
	 2 patient_name				= vc
	 2 fin						= vc
	 2 facility					= vc
	 2 unit						= vc
	 2 room_bed					= vc
	 2 location_class_1			= vc
	 2 encntr_type				= vc
	 2 expired_dt_tm			= vc
	 2 reg_dt_tm				= vc
	 2 disch_dt_tm				= vc
	 2 inpatient_dt_tm			= vc
	 2 observation_dt_tm		= vc
	 2 arrive_dt_tm				= vc
	 2 pso						= vc
	 2 los_days					= i2
	 2 diagnosis				= vc
	 2 covid19_order			= vc
	 2 covid19_result			= vc
	 2 isolation_order			= vc
	 2 ventilator_result		= vc
	 2 ventilator_model			= vc
	 2 suspected				= c1
	 2 confirmed				= c1
	 2 ventilator			    = c1
	 2 ventilator_invasive		= c1
	 2 covenant_vent_stock		= c1
	 2 ip_pso					= c1
	 2 expired					= c1
	 2 historical				= c1
	 2 prev_admission			= c1
	 2 prev_onset				= c1
	 2 prev_onset_conf			= c1
	 2 hosp_susp_onset			= c1
	 2 hosp_conf_onset			= c1
)
 
free record tt_covid19
record tt_covid19
(
	1 summary_cnt					= i2
	1 summary_qual[*]
	 2 facility						= vc
	 2 qa_numc19confnewadm			= i2
	 2 qb_numc19suspnewadm			= i2
	 2 qc_numc19honewpats			= i2
	 2 q1_ip_confirmed				= i2
	 2 q1_ip_suspected				= i2
	 2 q1_total						= i2	;numc19hosppats
	 2 q2_ip_confirmed_vent			= i2
	 2 q2_ip_suspected_vent			= i2
	 2 q2_total						= i2	;numc19mechventpats
	 2 q3_ip_conf_susp_los14		= i2	;numc19hopats
	 2 q4_ed_of_conf_susp_wait		= i2	;numc19overflowpats
	 2 q4a_ed_of_conf_wait			= i2	;numc19overflowpats_conf
	 2 q4b_ed_of_susp_wait			= i2	;numc19overflowpats_susp
	 2 q5_ed_of_conf_susp_wait_vent = i2	;numc19ofmechventpats
	 2 q5a_ed_of_wait_vent 			= i2	;numc19ofmechventpats
	 2 q6_disch_expired				= i2	;numc19prevdied
	 2 q6a_all_expired				= i2	;numc19died
	 2 q7_all_beds_total			= i2	;numtotbeds
	 2 q8_all_beds_total_surge		= i2	;numbeds
	 2 q9_occupied_ip_beds			= i2	;numbedsocc
	 2 q10_avail_icu_beds			= i2	;numicubeds
	 2 q11_occupied_icu_beds		= i2	;numicubedsocc
	 2 q12_ventilator_total			= i2	;numvent
	 2 q13_ventilator_in_use		= i2	;numventuse
	 2 q_total_n95_masks			= i2
	 2 q_total_surgical_masks		= i2
	 2 q_total_beds					= i2
	 2 q_icu_confirmed				= i2
	 2 q_icu_suspected				= i2
	 2 q_deaths						= i2
	 2 q_admits_pos					= i2
	1 patient_cnt 				= i2
	1 patient_qual[*]
	 2 encntr_id				= f8
	 2 person_id				= f8
	 2 patient_name				= vc
	 2 fin						= vc
	 2 facility					= vc
	 2 unit						= vc
	 2 room_bed					= vc
	 2 location_class_1			= vc
	 2 encntr_type				= vc
	 2 pso						= vc
	 2 los_days					= i2
	 2 diagnosis				= vc
	 2 covid19_order			= vc
	 2 covid19_result			= vc
	 2 ventilator_result		= vc
	 2 ventilator_model			= vc
	 2 suspected				= c1
	 2 confirmed				= c1
	 2 ventilator			    = c1
	 2 ventilator_invasive		= c1
	 2 covenant_vent_stock		= c1
	 2 ip_pso					= c1
	 2 expired					= c1
	 2 prev_admission			= c1
	 2 prev_onset				= c1
	 2 prev_onset_conf			= c1
	 2 hosp_susp_onset			= c1
	 2 hosp_conf_onset			= c1
)
 
free record t_output
record t_output
(
	1 cnt 						= i2
	1 qual[*]
	 2 person_id				= f8
	 2 encntr_id				= f8
	 2 facility					= vc
	 2 patient_name				= vc
	 2 fin						= vc
	 2 dob						= vc
	 2 unit						= vc
	 2 room_bed					= vc
	 2 location_class_1			= vc
	 2 arrive_dt_tm				= vc
	 2 reg_dt_tm				= vc
	 2 inpatient_dt_tm			= vc
	 2 observation_dt_tm		= vc
	 2 disch_dt_tm				= vc
	 2 expired_dt_tm			= vc
	 2 encntr_type				= vc
	 2 pso						= vc
	 2 los_days					= i2
	 2 los_hours				= i2
	 2 diagnosis				= vc
	 2 covid19_order			= vc
	 2 covid19_order_dt_tm		= vc
	 2 covid19_result			= vc
	 2 covid19_result_dt_tm		= vc
	 2 isolation_order			= vc
	 2 isolation_order_dt_tm	= vc
	 2 ventilator_type			= vc
	 2 ventilator_model			= vc
	 2 ventilator_dt_tm			= vc
	 2 ventilator				= vc
	 2 positive_onset_dt_tm		= vc
	 2 suspected_onset_dt_tm	= vc
	 2 location_history			= vc
	 2 encntr_ignore			= i2
	 2 hrts_ignore				= i2
	 2 cov_summary_ignore		= i2
	 2 positive_ind				= i2
	 2 suspected_ind			= i2
	 2 ventilator_ind			= i2
	 2 covenant_vent_stock_ind	= i2
	 2 pending_test_ind			= i2
	 2 expired_ind				= i2
	 2 historical_ind			= i2
	 2 ed_admit_suspected_ind	= i2
	 2 ed_admit_confirmed_ind	= i2
	 2 previous_admission_ind	= i2
	 2 previous_onset_ind		= i2
	 2 previous_onset_conf_ind	= i2
	 2 hosp_susp_onset			= i2
	 2 hosp_conf_onset			= i2
)
 
free record t2_output
record t2_output
(
	1 cnt 						= i2
	1 qual[*]
	 2 person_id				= f8
	 2 encntr_id				= f8
	 2 facility					= vc
	 2 patient_name				= vc
	 2 fin						= vc
	 2 dob						= vc
	 2 date_of_birth			= dq8
	 2 age						= vc
	 2 unit						= vc
	 2 room_bed					= vc
	 2 location_class_1			= vc
	 2 arrive_dt_tm				= vc
	 2 reg_dt_tm				= vc
	 2 inpatient_dt_tm			= vc
	 2 inpatient_dt_tm_dq8		= dq8 ;002
	 2 observation_dt_tm		= vc
	 2 disch_dt_tm				= vc
	 2 expired_dt_tm			= vc
	 2 encntr_type				= vc
	 2 pso						= vc
	 2 los_days					= i2
	 2 los_hours				= i2
	 2 diagnosis				= vc
	 2 diagnosis_display		= vc
	 2 diagnosis_suspected_dt	= vc
	 2 diagnosis_confirmed_dt	= vc
	 2 diagnosis_suspected_dttm	= dq8
	 2 diagnosis_confirmed_dttm	= dq8
	 2 covid19_order			= vc
	 2 covid19_order_dt_tm		= vc
	 2 covid19_suspected_dt		= vc
	 2 covid19_suspected_dttm	= dq8
	 2 covid19_result			= vc
	 2 covid19_result_dt_tm		= vc
	 2 covid19_result_dttm		= dq8
	 2 covid19_confirmed_dt		= vc
	 2 covid19_confirmed_dttm	= vc
	 ;002 start
	 2 flu_result				= vc
	 2 flu_result_dt_tm			= vc
	 2 flu_result_dttm			= dq8
	 2 flu_confirmed_dt			= vc
	 2 flu_confirmed_dttm		= vc
	 ;002 end
	 2 isolation_order			= vc
	 2 isolation_order_dt_tm	= vc
	 2 ventilator_type			= vc
	 2 ventilator_model			= vc
	 2 ventilator_dt_tm			= vc
	 2 ventilator				= vc
	 2 positive_onset_dt_tm		= vc
	 2 flu_onset_dt_tm			= vc ;002
	 2 flu_onset_dt_tm_dq8		= dq8 ;002
	 2 suspected_onset_dt_tm	= vc
	 2 location_history			= vc
	 2 encntr_ignore			= i2
	 2 hrts_ignore				= i2
	 2 cov_summary_ignore		= i2
	 2 positive_ind				= i2
	 2 flu_positive_ind			= i2 ;002
	 2 suspected_ind			= i2
	 2 ventilator_ind			= i2
	 2 covenant_vent_stock_ind	= i2
	 2 pending_test_ind			= i2
	 2 expired_ind				= i2
	 2 historical_ind			= i2
	 2 ed_admit_suspected_ind	= i2
	 2 ed_admit_confirmed_ind	= i2
	 2 previous_admission_ind	= i2
	 2 previous_onset_ind		= i2
	 2 previous_onset_conf_ind	= i2
	 2 hosp_susp_onset			= i2
	 2 hosp_conf_onset			= i2
	 2 patient_phone_num		= vc	;009
	 2 patient_address_county	= vc	;009
	 2 patient_gender			= vc	;009
	 2 patient_race				= vc	;009
	 2 patient_ethnicity		= vc	;009
	 2 isolation_days			= vc	;009
	 2 accommodation			= vc	;010
	 2 covid19_vaccine			= vc	;011
	 2 covid19_vaccine_yes_no	= vc	;011
	 2 covid19_vaccine_ind		= i2	;011
	 2 symptom_result_dt_tm		= vc	;012
	 2 date_tested_dt_tm		= vc	;012
)
 
free record cov_unit_summary
record cov_unit_summary
(
	1 summary_cnt					= i2
	1 summary_qual[*]
	 2 facility						= vc
	 2 unit_cnt						= i2
	 2 unit_qual[*]
	  3 unit						= vc
	  3 room_bed_cnt				= i2
	  3 room_bed_qual[*]
	   4 room_bed					= vc
	   4 suspected					= c1
	   4 confirmed					= c1
	1 patient_cnt 				= i2
	1 patient_qual[*]
	 2 encntr_id				= f8
	 2 person_id				= f8
	 2 patient_name				= vc
	 2 fin						= vc
	 2 facility					= vc
	 2 unit						= vc
	 2 room_bed					= vc
	 2 location_class_1			= vc
	 2 encntr_type				= vc
	 2 pso						= vc
	 2 los_days					= i2
	 2 diagnosis				= vc
	 2 covid19_order			= vc
	 2 covid19_result			= vc
	 2 ventilator_result		= vc
	 2 ventilator_model			= vc
	 2 suspected				= c1
	 2 confirmed				= c1
	 2 ventilator			    = c1
	 2 ventilator_invasive		= c1
	 2 covenant_vent_stock		= c1
	 2 ip_pso					= c1
	 2 expired					= c1
	 2 prev_admission			= c1
	 2 prev_onset				= c1
)
 
free record teletracking
record teletracking
(
	1 summary_cnt					= i2
	1 summary_qual[*]
	 2 facility = vc
	 2 hospital_name = vc
	 2 hospital_ccn = vc
	 2 hospital_npi = vc
	 2 hospital_aha_id = vc
	 2 hospital_nhsn_id = vc
	 2 address_street1 = vc
	 2 address_street2 = vc
	 2 address_city = vc
	 2 address_state = vc
	 2 address_zip = vc
	 2 date_entered_utc = vc
	 2 teletracking_id = vc
	 2 confirmed_patients = i2
	 2 confirmed_patients_adult = i2
	 2 suspected_patients = i2
	 2 suspected_patients_adult = i2
	 2 hospital_onset_patients = i2
	 2 hospital_onset_patients_adult = i2
	 2 patients_using_ventilation = i2
	 2 patients_using_ventilation_adult = i2
	 2 icu_confirmed_patients = i2
	 2 icu_confirmed_patients_adult = i2
	 2 icu_suspected_patients = i2
	 2 icu_suspected_patients_adult = i2
	 2 ed_overflow_confirmed_patients = i2
	 2 ed_overflow_confirmed_patients_adult = i2
	 2 ed_overflow_suspected_patients = i2
	 2 ed_overflow_suspected_patients_adult = i2
	 2 ed_overflow_patients_using_ventilation = i2
	 2 ed_overflow_patients_using_ventilation_adult = i2
	 2 total_beds = i2
	 2 total_beds_adult = i2
	 2 occupied_inpatient_beds = i2
	 2 occupied_inpatient_beds_adult = i2
	 2 total_inpatient_beds = i2
	 2 total_inpatient_beds_adult = i2
	 2 icu_occupied_beds = i2
	 2 icu_occupied_beds_adult = i2
	 2 icu_total_beds = i2
	 2 icu_total_beds_adult = i2
	 2 total_covid19_deaths = i2
	 2 total_deaths = i2
	 2 total_covid19_admits = i2
	 2 admits_in_last_24_hrs_confirmed = i2
	 2 admits_in_last_24_hrs_confirmed_0_17 = i2
	 2 admits_in_last_24_hrs_confirmed_18_19 = i2
	 2 admits_in_last_24_hrs_confirmed_20_29 = i2
	 2 admits_in_last_24_hrs_confirmed_30_39 = i2
	 2 admits_in_last_24_hrs_confirmed_40_49 = i2
	 2 admits_in_last_24_hrs_confirmed_50_59 = i2
	 2 admits_in_last_24_hrs_confirmed_60_69 = i2
	 2 admits_in_last_24_hrs_confirmed_70_79 = i2
	 2 admits_in_last_24_hrs_confirmed_80 = i2
	 ;2 admits_in_last_24_hrs_confirmed_adult = i2
	 2 admits_in_last_24_hrs_suspected = i2
	 2 admits_in_last_24_hrs_suspected_0_17 = i2
	 2 admits_in_last_24_hrs_suspected_18_19 = i2
	 2 admits_in_last_24_hrs_suspected_20_29 = i2
	 2 admits_in_last_24_hrs_suspected_30_39 = i2
	 2 admits_in_last_24_hrs_suspected_40_49 = i2
	 2 admits_in_last_24_hrs_suspected_50_59 = i2
	 2 admits_in_last_24_hrs_suspected_60_69 = i2
	 2 admits_in_last_24_hrs_suspected_70_79 = i2
	 2 admits_in_last_24_hrs_suspected_80 = i2
	 ;2 admits_in_last_24_hrs_suspected_adult = i2
	 2 ed_visits_in_last_24_hrs_total = i2
	 2 ed_visits_in_last_24_hrs_covid_related = i2
	 2 covid_death_in_last_24_hrs = i2
	 2 ventilators_in_use = i2
	 2 total_ventilators = i2
	 2 other_vent_support_devices = i2
	 2 ventilator_supplies_days_on_hand = vc
	 2 ventilator_supplies_able_to_obtain = vc
	 2 ventilator_supplies_3day_supply = vc
	 2 fentanyl_able_to_obtain = vc
	 2 fentanyl_3day_supply = vc
	 2 hydromorphone_able_to_obtain = vc
	 2 hydromorphone_3day_supply = vc
	 2 propofol_able_to_obtain = vc
	 2 propofol_3day_supply = vc
	 2 midazolam_able_to_obtain = vc
	 2 midazolam_3day_supply = vc
	 2 dexmedetomidine_able_to_obtain = vc
	 2 dexmedetomidine_3day_supply = vc
	 2 cisatracurium_able_to_obtain = vc
	 2 cisatracurium_3day_supply = vc
	 2 rocuronium_able_to_obtain = vc
	 2 rocuronium_3day_supply = vc
	 2 total_n95_masks = i2
	 2 total_n95_days_on_hand = i2
	 2 total_n95_3day_supply = vc
	 2 total_n95_reuse = vc
	 2 total_surgical_masks = i2
	 2 total_surgical_mask_days_on_hand = i2
	 2 total_surgical_mask_3day_supply = vc
	 2 total_surgical_mask_reuse = vc
	 2 total_face_shields = i2
	 2 total_face_shields_days_on_hand = i2
	 2 total_face_shields_3day_supply = vc
	 2 total_face_shields_reuse = vc
	 2 total_gloves = i2
	 2 total_gloves_days_on_hand = i2
	 2 total_gloves_3day_supply = vc
	 2 total_gloves_reuse = vc
	 2 total_surgical_gowns = i2
	 2 total_surgical_gowns_days_on_hand = i2
	 2 total_surgical_gowns_3day_supply = vc
	 2 total_surgical_gowns_reuse = vc
	 2 total_papr = i2
	 2 total_papr_days_on_hand = i2
	 2 total_papr_3day_supply = vc
	 2 total_papr_reuse = vc
	 2 ppe_source = vc
	 2 use_launderable_gowns = vc
	 2 maintain_supply_of_launderable_gowns = vc
	 2 anticipated_critical_medical_supply_shortage = vc
	 2 nasal_pharyngeal_swabs_3day_supply = vc
	 2 nasal_swabs_3day_supply = vc
	 2 viral_transport_media_3day_supply = vc
	 2 staffing_shortage_today = vc
	 2 staffing_shortage_anticipated_this_week = vc
	 2 staffing_shortage_anticipated_environmental_services = vc
	 2 staffing_shortage_anticipated_nurses = vc
	 2 staffing_shortage_anticipated_respiratory_therapists = vc
	 2 staffing_shortage_anticipated_pharmacist_and_pharmacy_tech = vc
	 2 staffing_shortage_anticipated_other_physicians = vc
	 2 staffing_shortage_anticipated_other_licensed_independent_practitioners = vc
	 2 staffing_shortage_anticipated_temporary_staff = vc
	 2 staffing_shortage_anticipated_other_critical_healthcare_personnel = vc
	 2 remdesivir_current_inventory = i2
	 2 remdesivir_used_previous_day = i2
	 2 ventilator_medications_able_to_obtain = vc
 	 2 ventilator_medications_3day_supply = vc
 	 2 n95_able_to_obtain = vc
	 2 surgical_masks_able_to_obtain = vc
 	 2 face_shields_able_to_obtain = vc
 	 2 gloves_able_to_obtain = vc
     2 total_single_use_gowns = i2
 	 2 total_single_use_gowns_days_on_hand = i2
 	 2 total_single_use_gowns_3day_supply = vc
 	 2 single_use_gowns_able_to_obtain = vc
 	 2 papr_able_to_obtain = vc
 	 2 launderable_gowns_inventory = i2
	1 patient_cnt 				= i2
	1 patient_qual[*]
	 2 encntr_id				= f8
	 2 person_id				= f8
	 2 patient_name				= vc
	 2 fin						= vc
	 2 facility					= vc
	 2 unit						= vc
	 2 room_bed					= vc
	 2 location_class_1			= vc
	 2 encntr_type				= vc
	 2 pso						= vc
	 2 los_days					= i2
	 2 diagnosis				= vc
	 2 covid19_order			= vc
	 2 covid19_result			= vc
	 2 ventilator_result		= vc
	 2 ventilator_model			= vc
	 2 suspected				= c1
	 2 confirmed				= c1
	 2 ventilator			    = c1
	 2 ventilator_invasive		= c1
	 2 covenant_vent_stock		= c1
	 2 ip_pso					= c1
	 2 expired					= c1
	 2 prev_admission			= c1
	 2 prev_onset				= c1
	 2 prev_onset_conf			= c1
)
 
free record hrts_0806
record hrts_0806
(
	1 summary_cnt				= i2
	1 summary_qual[*]
	 2 facility = vc
	 2 contact_email = vc
	 2 reporting_for_date = vc
	 2 facility_id = vc
	 2 mechanical_ventilators = i2
	 2 mechanical_ventilators_in_use = i2
	 2 total_adult_patients_hospitalized_confirmed_and_suspected_covid = i2
	 2 total_adult_patients_hospitalized_confirmed_covid = i2
	 2 total_pediatric_patients_hospitalized_confirmed_and_suspected_covid = i2
	 2 total_pediatric_patients_hospitalized_confirmed_covid = i2
	 2 hospitalized_and_ventilated_covid_patients = i2
	 2 staffed_icu_adult_patients_confirmed_and_suspected_covid = i2
	 2 staffed_icu_adult_patients_confirmed_covid = i2
	 2 hospital_onset = i2
	 2 ed_or_overflow = i2
	 2 ed_or_overflow_and_ventilated = i2
	 2 previous_day_deaths_covid = i2
	 2 previous_day_admission_adult_covid_confirmed = i2
	 2 previous_day_admission_adult_covid_confirmed_18_19 = i2
	 2 previous_day_admission_adult_covid_confirmed_20_29 = i2
	 2 previous_day_admission_adult_covid_confirmed_30_39 = i2
	 2 previous_day_admission_adult_covid_confirmed_40_49 = i2
	 2 previous_day_admission_adult_covid_confirmed_50_59 = i2
	 2 previous_day_admission_adult_covid_confirmed_60_69 = i2
	 2 previous_day_admission_adult_covid_confirmed_70_79 = i2
	 2 previous_day_admission_adult_covid_confirmed_80_plus = i2
	 2 previous_day_admission_adult_covid_confirmed_unknown_age = i2
	 2 previous_day_admission_adult_covid_suspected = i2
	 2 previous_day_admission_adult_covid_suspected_18_19 = i2
	 2 previous_day_admission_adult_covid_suspected_20_29 = i2
	 2 previous_day_admission_adult_covid_suspected_30_39 = i2
	 2 previous_day_admission_adult_covid_suspected_40_49 = i2
	 2 previous_day_admission_adult_covid_suspected_50_59 = i2
	 2 previous_day_admission_adult_covid_suspected_60_69 = i2
	 2 previous_day_admission_adult_covid_suspected_70_79 = i2
	 2 previous_day_admission_adult_covid_suspected_80_plus = i2
	 2 previous_day_admission_adult_covid_suspected_unknown_age = i2
	 2 previous_day_admission_pediatric_covid_confirmed = i2
	 2 previous_day_admission_pediatric_covid_suspected = i2
	 2 previous_day_total_ed_visits = i2
	 2 previous_day_covid_ed_visits = i2
	 2 previous_day_remdesivir_used = i2
	 2 on_hand_supply_remdesivir_vials = i2
	 2 critical_staffing_shortage_today = i2
	 2 critical_staffing_shortage_anticipated_within_week = i2
	 2 staffing_shortage_details = i2
	 2 ppe_supply_management_source = i2
	 2 on_hand_ventilator_supplies_in_days = i2
	 2 on_hand_supply_of_n95_respirators_in_days = i2
	 2 on_hand_supply_of_surgical_masks_in_days = i2
	 2 on_hand_supply_of_eye_protection_in_days = i2
	 2 on_hand_supply_of_single_use_surgical_gowns_in_days = i2
	 2 on_hand_supply_of_gloves_in_days = i2
	 2 on_hand_supply_of_n95_respirators_in_units = i2
	 2 on_hand_supply_of_papr_in_units = i2
	 2 on_hand_supply_of_surgical_masks_in_units = i2
	 2 on_hand_supply_of_eye_protection_in_units = i2
	 2 on_hand_supply_of_single_use_surgical_gowns_in_units = i2
	 2 on_hand_supply_of_launderable_surgical_gowns_in_units = i2
	 2 on_hand_supply_of_gloves_in_units = i2
	 2 able_to_obtain_ventilator_supplies = vc
	 2 able_to_obtain_ventilator_medications = vc
	 2 able_to_obtain_n95_masks = vc
	 2 able_to_obtain_paprs = vc
	 2 able_to_obtain_surgical_masks = vc
	 2 able_to_obtain_eye_protection = vc
	 2 able_to_obtain_single_use_gowns = vc
	 2 able_to_obtain_gloves = vc
	 2 able_to_obtain_launderable_gowns = vc
	 2 able_to_maintain_ventilator_3day_supplies = vc
	 2 able_to_maintain_ventilator_3day_medications = vc
	 2 able_to_maintain_n95_masks = vc
	 2 able_to_maintain_3day_paprs = vc
	 2 able_to_maintain_3day_surgical_masks = vc
	 2 able_to_maintain_3day_eye_protection = vc
	 2 able_to_maintain_3day_single_use_gowns = vc
	 2 able_to_maintain_3day_gloves = vc
	 2 able_to_maintain_3day_lab_nasal_pharyngeal_swabs = vc
	 2 able_to_maintain_lab_nasal_swabs = vc
	 2 able_to_maintain_3day_lab_viral_transport_media = vc
	 2 reusable_isolation_gowns_used = i2
	 2 reusable_paprs_or_elastomerics_used = i2
	 2 reusuable_n95_masks_used = i2
	 2 anticipated_medical_supply_medication_shortages = i2
	1 patient_cnt 				= i2
	1 patient_qual[*]
	 2 encntr_id				= f8
	 2 person_id				= f8
	 2 patient_name				= vc
	 2 fin						= vc
	 2 facility					= vc
	 2 unit						= vc
	 2 room_bed					= vc
	 2 location_class_1			= vc
	 2 encntr_type				= vc
	 2 pso						= vc
	 2 los_days					= i2
	 2 diagnosis				= vc
	 2 covid19_order			= vc
	 2 covid19_result			= vc
	 2 ventilator_result		= vc
	 2 ventilator_model			= vc
	 2 suspected				= c1
	 2 confirmed				= c1
	 2 ventilator			    = c1
	 2 ventilator_invasive		= c1
	 2 covenant_vent_stock		= c1
	 2 ip_pso					= c1
	 2 expired					= c1
	 2 prev_admission			= c1
	 2 prev_onset				= c1
	 2 prev_onset_conf			= c1
)
 
free record hrts_v3
record hrts_v3
(
	1 summary_cnt				= i2
	1 summary_qual[*]
	 2 facility = vc
	 2 contact_email = vc
	 2 reporting_for_date = vc
	 2 facility_id = vc
	 2 hosp_name = vc
	 2 current_pos = i2
	 2 current_pos_icu = i2
	 2 current_pos_vent = i2
	 2 current_pend = i2
	 2 current_pend_icu = i2
	 2 current_pend_vent = i2
	 2 current_pos_pediatric = i2
	 2 current_pos_pediatric_icu = i2
	 2 current_pos_pediatric_vent = i2
	 2 current_pend_pediatric = i2
	 2 current_pend_pediatric_icu = i2
	 2 current_pend_pediatric_vent = i2
	 2 prev_day_admiss_confirmed_covid = i2
	 2 previous_day_admission_adult_covid_confirmed_18_19 = i2
	 2 previous_day_admission_adult_covid_confirmed_20_29 = i2
	 2 previous_day_admission_adult_covid_confirmed_30_39 = i2
	 2 previous_day_admission_adult_covid_confirmed_40_49 = i2
	 2 previous_day_admission_adult_covid_confirmed_50_59 = i2
	 2 previous_day_admission_adult_covid_confirmed_60_69 = i2
	 2 previous_day_admission_adult_covid_confirmed_70_79 = i2
	 2 previous_day_admission_adult_covid_confirmed_80_plus = i2
	 2 previous_day_admission_adult_covid_confirmed_unknown_age = i2
	 2 previous_day_admission_adult_covid_suspected = i2
	 2 previous_day_admission_adult_covid_suspected_18_19 = i2
	 2 previous_day_admission_adult_covid_suspected_20_29 = i2
	 2 previous_day_admission_adult_covid_suspected_30_39 = i2
	 2 previous_day_admission_adult_covid_suspected_40_49 = i2
	 2 previous_day_admission_adult_covid_suspected_50_59 = i2
	 2 previous_day_admission_adult_covid_suspected_60_69 = i2
	 2 previous_day_admission_adult_covid_suspected_70_79 = i2
	 2 previous_day_admission_adult_covid_suspected_80_plus = i2
	 2 previous_day_admission_adult_covid_suspected_unknown_age = i2
	 2 prev_day_pediatric_conf = i2
	 2 prev_day_pediatric_susp = i2
	 2 hospital_onset = i2
	 2 previous_day_total_ed_visits = i2
	 2 previous_day_covid_ed_visits = i2
	 2 ed_or_overflow = i2
	 2 ed_or_overflow_and_ventilated = i2
	 2 previous_day_death_covid = i2
	 2 prev_day_rdv_used = i2
	 2 prev_day_rdv_inv = i2
	 2 crit_staffing_shortage_today = c3
	 2 crit_staffing_shortage_week = c3
	 2 staffing_shortage_details = vc
	 2 ppe_supply_mgmt_source = vc
	 2 mechanical_adult_ventilators = i2
	 2 mechanical_adult_vents_in_use = i2
	 2 mechanical_ped_ventilators = i2
	 2 mechanical_ped_vents_in_use = i2
	 2 oh_ventilator_supplies_days = i2
	 2 able_obtain_vent_supp = c3
	 2 able_mtn_vent_3day_supp = c3
	 2 able_obtain_vent_meds = c3
	 2 able_mtn_vent_3day_meds = c3
	 2 oh_n95_respirators_units = i2
	 2 oh_n95_respirators_days = i2
	 2 able_obtain_n95_masks = c3
	 2 able_mtn_n95_masks = c3
	 2 reusuable_n95_masks_used = c3
	 2 oh_paprs_units = i2
	 2 able_obtain_paprs = c3
	 2 able_mtn_3day_paprs = c3
	 2 reusable_paprs_elasto_used = c3
	 2 oh_supply_surgical_masks_units = i2
	 2 oh_supply_surgical_masks_days = i2
	 2 able_obtain_surg_masks = c3
	 2 able_mtn_3day_surg_masks = c3
	 2 oh_eye_protection_units = i2
	 2 oh_eye_protection_days = i2
	 2 able_obtain_eye_protection = c3
	 2 able_mtn_3day_eye_prot = c3
	 2 oh_single_use_surg_gowns_units = i2
	 2 oh_single_use_surg_gowns_days = i2
	 2 able_obtain_single_use_gowns = c3
	 2 able_mtn_3day_singuse_gown = c3
	 2 oh_gloves_units = i2
	 2 oh_gloves_days = i2
	 2 able_obtain_gloves = c3
	 2 able_mtn_3day_gloves = c3
	 2 oh_laund_surg_gowns_units = i2
	 2 able_obtain_launderable_gowns = c3
	 2 reusable_isolation_gowns_used = c3
	 2 able_mtn_3day_pharyngeal_swabs = c3
	 2 able_mtn_lab_nasal_swabs = c3
	 2 able_mtn_3day_viral_trans_media = c3
	 2 ant_medical_sup_med_short = c3
	1 patient_cnt 				= i2
	1 patient_qual[*]
	 2 encntr_id				= f8
	 2 person_id				= f8
	 2 patient_name				= vc
	 2 dob						= vc
	 2 age						= vc
	 2 age_years				= i2
	 2 fin						= vc
	 2 facility					= vc
	 2 unit						= vc
	 2 room_bed					= vc
	 2 location_class_1			= vc
	 2 encntr_type				= vc
	 2 pso						= vc
	 2 los_days					= i2
	 2 diagnosis				= vc
	 2 covid19_order			= vc
	 2 covid19_result			= vc
	 2 ventilator_result		= vc
	 2 ventilator_model			= vc
	 2 suspected				= c1
	 2 confirmed				= c1
	 2 ventilator			    = c1
	 2 ventilator_invasive		= c1
	 2 covenant_vent_stock		= c1
	 2 ip_pso					= c1
	 2 expired					= c1
	 2 prev_admission			= c1
	 2 prev_onset				= c1
	 2 prev_onset_conf			= c1
	 2 hosp_susp_onset			= c1
	 2 hosp_conf_onset			= c1
)
 
free record hrts_v4
record hrts_v4
(
	1 summary_cnt				= i2
	1 summary_qual[*]
	 2 facility = vc
	 2 contact_email = vc
	 2 reporting_for_date = vc
	 2 facility_id = vc
	 2 hosp_name = vc
	 2 current_pos = i2
	 2 current_pos_icu = i2
	 2 current_pos_vent = i2
	 2 current_pend = i2
	 2 current_pend_icu = i2
	 2 current_pend_vent = i2
	 2 current_pos_pediatric = i2
	 2 current_pos_pediatric_icu = i2
	 2 current_pos_pediatric_vent = i2
	 2 current_pend_pediatric = i2
	 2 current_pend_pediatric_icu = i2
	 2 current_pend_pediatric_vent = i2
	 2 prev_day_admiss_confirmed_covid = i2
	 2 previous_day_admission_adult_covid_confirmed_18_19 = i2
	 2 previous_day_admission_adult_covid_confirmed_20_29 = i2
	 2 previous_day_admission_adult_covid_confirmed_30_39 = i2
	 2 previous_day_admission_adult_covid_confirmed_40_49 = i2
	 2 previous_day_admission_adult_covid_confirmed_50_59 = i2
	 2 previous_day_admission_adult_covid_confirmed_60_69 = i2
	 2 previous_day_admission_adult_covid_confirmed_70_79 = i2
	 2 previous_day_admission_adult_covid_confirmed_80_plus = i2
	 2 previous_day_admission_adult_covid_confirmed_unknown_age = i2
	 2 previous_day_admission_adult_covid_suspected = i2
	 2 previous_day_admission_adult_covid_suspected_18_19 = i2
	 2 previous_day_admission_adult_covid_suspected_20_29 = i2
	 2 previous_day_admission_adult_covid_suspected_30_39 = i2
	 2 previous_day_admission_adult_covid_suspected_40_49 = i2
	 2 previous_day_admission_adult_covid_suspected_50_59 = i2
	 2 previous_day_admission_adult_covid_suspected_60_69 = i2
	 2 previous_day_admission_adult_covid_suspected_70_79 = i2
	 2 previous_day_admission_adult_covid_suspected_80_plus = i2
	 2 previous_day_admission_adult_covid_suspected_unknown_age = i2
	 2 prev_day_pediatric_conf = i2
	 2 prev_day_pediatric_susp = i2
	 2 hospital_onset = i2
	 2 previous_day_total_ed_visits = i2
	 2 previous_day_covid_ed_visits = i2
	 2 ed_or_overflow = i2
	 2 ed_or_overflow_and_ventilated = i2
	 2 previous_day_death_covid = i2
	 2 prev_day_rdv_used = i2
	 2 prev_day_rdv_inv = i2
	 2 crit_staffing_shortage_today = c3
	 2 crit_staffing_shortage_week = c3
	 2 staffing_shortage_details = vc
	 2 ppe_supply_mgmt_source = vc
	 2 mechanical_adult_ventilators = i2
	 2 mechanical_adult_vents_in_use = i2
	 2 mechanical_ped_ventilators = i2
	 2 mechanical_ped_vents_in_use = i2
	 2 oh_ventilator_supplies_days = i2
	 2 able_obtain_vent_supp = c3
	 2 able_mtn_vent_3day_supp = c3
	 2 able_obtain_vent_meds = c3
	 2 able_mtn_vent_3day_meds = c3
	 2 oh_n95_respirators_units = i2
	 2 oh_n95_respirators_days = i2
	 2 able_obtain_n95_masks = c3
	 2 able_mtn_n95_masks = c3
	 2 reusuable_n95_masks_used = c3
	 2 oh_paprs_units = i2
	 2 able_obtain_paprs = c3
	 2 able_mtn_3day_paprs = c3
	 2 reusable_paprs_elasto_used = c3
	 2 oh_supply_surgical_masks_units = i2
	 2 oh_supply_surgical_masks_days = i2
	 2 able_obtain_surg_masks = c3
	 2 able_mtn_3day_surg_masks = c3
	 2 oh_eye_protection_units = i2
	 2 oh_eye_protection_days = i2
	 2 able_obtain_eye_protection = c3
	 2 able_mtn_3day_eye_prot = c3
	 2 oh_single_use_surg_gowns_units = i2
	 2 oh_single_use_surg_gowns_days = i2
	 2 able_obtain_single_use_gowns = c3
	 2 able_mtn_3day_singuse_gown = c3
	 2 oh_gloves_units = i2
	 2 oh_gloves_days = i2
	 2 able_obtain_gloves = c3
	 2 able_mtn_3day_gloves = c3
	 2 oh_laund_surg_gowns_units = i2
	 2 able_obtain_launderable_gowns = c3
	 2 reusable_isolation_gowns_used = c3
	 2 able_mtn_3day_pharyngeal_swabs = c3
	 2 able_mtn_lab_nasal_swabs = c3
	 2 able_mtn_3day_viral_trans_media = c3
	 2 ant_medical_sup_med_short = c3
	 2 current_pos_flu = i2
	 2 prev_day_flu_admiss = i2
	 2 current_pos_flu_icu = i2
	 2 current_pos_flu_covid = i2
	 2 prev_day_flu_deaths = i2
	 2 prev_day_flu_covid_deaths = i2
	 2 positive_patients_with_vaccine = i2 ;011
	1 patient_cnt 				= i2
	1 patient_qual[*]
	 2 encntr_id				= f8
	 2 person_id				= f8
	 2 patient_name				= vc
	 2 dob						= vc
	 2 age						= vc
	 2 age_years				= i2
	 2 fin						= vc
	 2 facility					= vc
	 2 unit						= vc
	 2 room_bed					= vc
	 2 location_class_1			= vc
	 2 encntr_type				= vc
	 2 pso						= vc
	 2 los_days					= i2
	 2 diagnosis				= vc
	 2 covid19_order			= vc
	 2 covid19_result			= vc
	 2 flu_result				= vc ;002
	 2 ventilator_result		= vc
	 2 ventilator_model			= vc
	 2 suspected				= c1
	 2 confirmed				= c1
	 2 ventilator			    = c1
	 2 ventilator_invasive		= c1
	 2 covenant_vent_stock		= c1
	 2 ip_pso					= c1
	 2 expired					= c1
	 2 prev_admission			= c1
	 2 prev_onset				= c1
	 2 prev_onset_conf			= c1
	 2 hosp_susp_onset			= c1
	 2 hosp_conf_onset			= c1
	 2 flu_confirmed			= c1 ;002
	 2 inpatient_dt_tm			= dq8 ;003
	 2 flu_result_dt_tm			= dq8 ;003
	 2 covid19_vaccine			= c1 ;011
)
 
free record hrts
record hrts
(
	1 summary_cnt				= i2
	1 summary_qual[*]
	 2 facility 				= vc
	 2 question_1 = i2
	 2 question_2 = i2
	 2 question_3 = i2
	 2 question_4 = i2
	 2 question_5 = i2
	 2 question_6 = i2
	 2 question_7 = i2
	 2 question_8 = i2
	 2 question_9 = i2
	 2 question_10 = i2
	 2 question_11 = i2
	 2 question_12 = i2
	 2 question_13 = i2
	 2 question_14 = i2
	 2 question_15 = i2
	 2 question_16 = i2
	 2 question_17 = i2
	 2 question_18 = i2
	 2 question_19 = i2
	 2 question_20 = i2
	 2 question_21 = i2
	 2 question_22 = i2
	 2 question_23 = i2
	 2 question_24 = i2
	 2 question_25 = vc
	 2 question_26 = vc
	 2 question_27a = vc
	 2 question_27b = vc
	 2 question_27c = vc
	 2 question_27d = vc
	 2 question_27e = vc
	 2 question_27f = vc
	 2 question_27g = vc
	 2 question_27h = vc
	 2 question_28 = vc
	 2 question_29a = i2
	 2 question_29b = i2
	 2 question_29c = i2
	 2 question_29d = i2
	 2 question_29e = i2
	 2 question_29f = i2
	 2 question_29g = i2
	 2 question_30a = vc
	 2 question_30b = vc
	 2 question_30c = vc
	 2 question_30d = vc
	 2 question_30e = vc
	 2 question_30f = vc
	 2 question_30g = vc
	 2 question_30h = vc
	 2 question_30i = vc
	 2 question_31 = vc
	 2 question_31a = vc
	 2 question_31b = vc
	 2 question_31c = vc
	 2 question_31d = vc
	 2 question_31e = vc
	 2 question_31f = vc
	 2 question_31g = vc
	 2 question_31h = vc
	 2 question_31i = vc
	 2 question_31j = vc
	 2 question_32 = vc
	 2 question_33 = vc
	1 patient_cnt 				= i2
	1 patient_qual[*]
	 2 encntr_id				= f8
	 2 person_id				= f8
	 2 patient_name				= vc
	 2 fin						= vc
	 2 facility					= vc
	 2 unit						= vc
	 2 room_bed					= vc
	 2 location_class_1			= vc
	 2 encntr_type				= vc
	 2 pso						= vc
	 2 los_days					= i2
	 2 diagnosis				= vc
	 2 covid19_order			= vc
	 2 covid19_result			= vc
	 2 ventilator_result		= vc
	 2 ventilator_model			= vc
	 2 suspected				= c1
	 2 confirmed				= c1
	 2 ventilator			    = c1
	 2 ventilator_invasive		= c1
	 2 covenant_vent_stock		= c1
	 2 ip_pso					= c1
	 2 expired					= c1
	 2 prev_admission			= c1
	 2 prev_onset				= c1
	 2 prev_onset_conf			= c1
)
 
set t_rec->crlf = concat(char(13),char(10))
 
set t_rec->prompt_outdev = $OUTDEV
set t_rec->prompt_all_fac_ind = $ALL_FACILITIES
set t_rec->prompt_report_type = $REPORT_OPTION
 
if (validate(request))
	set t_rec->request = cnvtrectojson(request)
endif
 
set t_rec->records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
set t_rec->output_filename = concat("_tempname_",trim(cnvtlower(curprog)),"_",trim(format(sysdate,"yyyymmdd_hhmmss;;d")),".csv")
 
if (program_log->run_from_ops = 0)
	if (t_rec->prompt_outdev = "OPS")
		set program_log->run_from_ops = 1
		set program_log->display_on_exit = 0
	endif
endif
 
if (program_log->run_from_ops = 0)
	set t_rec->output_var = t_rec->prompt_outdev
else	;run from ops
	set t_rec->prompt_all_fac_ind = 1
	set t_rec->output_var = concat("cclscratch:",trim(t_rec->output_filename))
endif
 
 
set program_log->email.subject = concat(
											 program_log->curdomain
											," "
											,trim(check(cnvtlower(program_log->curprog)))
											," "
											,format(sysdate,"yyyy-mm-dd hh:mm:ss;;d")
										)
 
set t_rec->prompt_historical_ind = $HISTORY_IND
 
if (t_rec->prompt_historical_ind = 1)
	set t_rec->prompt_beg_dt_tm = cnvtdatetime($BEG_DT_TM)
	set t_rec->prompt_end_dt_tm = cnvtdatetime($END_DT_TM)
endif
 
 
 
set t_rec->curprog = curprog
set t_rec->curprog = "cov_rpt_op_readiness" ;override for dev script
 
declare diagnosis = vc with noconstant(" ")
declare facility = vc with noconstant(" ")
declare encntr_id = f8 with noconstant(0.0)
 
call addEmailLog("chad.cummings@covhlth.com")
 
 
select into "nl:"
from
	code_value_set cvs
plan cvs
	    where cvs.definition            = "COVCUSTOM"
order by
	 cvs.definition
	,cvs.updt_dt_tm desc
head report
	call writeLog(build2("->inside code_value_set query"))
head cvs.definition
	t_rec->custom_code_set = cvs.code_set
	call writeLog(build2("-->t_rec->custom_code_set=",trim(cnvtstring(t_rec->custom_code_set))))
with nocounter
 
if (t_rec->custom_code_set = 0)
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "CODE_SET"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "CODE_SET"
	set reply->status_data.subeventstatus.targetobjectvalue = "The Custom Code Set was not Found"
	go to exit_script
endif
 
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("* START Finding Locations **********************************"))
if (t_rec->prompt_all_fac_ind = 1)
	select into "nl:"
	     location = trim(uar_get_code_display(l.location_cd))
	    ,l.location_cd
	from
	     location   l
	    ,organization   o
	    ,code_value cv1
	    ,code_value cv2
	plan cv1
	    where cv1.code_set              = t_rec->custom_code_set
	    and   cv1.definition            = trim(cnvtlower(t_rec->curprog))
	    and   cv1.active_ind            = 1
	    and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	    and   cv1.end_effective_dt_tm   >= cnvtdatetime(curdate,curtime3)
	    and   cv1.cdf_meaning           = "FACILITY"
	join l
	    where   l.location_type_cd      = value(uar_get_code_by("MEANING",222,"FACILITY"))
	    and     l.active_ind            = 1
	join cv2
	    where   cv2.code_value          = l.location_cd
	    and     cv2.display             = cv1.display
	join o
	    where o.organization_id         = l.organization_id
	order by
	    cv1.collation_seq
	   ,cv2.code_value
	head report
		t_rec->prompt_loc_cnt = 0
		call writeLog(build2("->inside code_value query"))
	head cv2.code_value
		t_rec->prompt_loc_cnt = (t_rec->prompt_loc_cnt + 1)
		stat = alterlist(t_rec->prompt_loc_qual,t_rec->prompt_loc_cnt)
		t_rec->prompt_loc_qual[t_rec->prompt_loc_cnt].location_cd = cv1.code_value
		t_rec->prompt_loc_qual[t_rec->prompt_loc_cnt].location_type_cd = l.location_type_cd
		call writeLog(build2(	 "-->t_rec->prompt_loc_qual[",trim(cnvtstring(t_rec->prompt_loc_cnt)),"].location_cd="
								,trim(cnvtstring(t_rec->prompt_loc_qual[t_rec->prompt_loc_cnt].location_cd))
								,"(",trim(uar_get_code_display(t_rec->prompt_loc_qual[t_rec->prompt_loc_cnt].location_cd)),")"))
	with nocounter
else
	select into "nl:"
		location = trim(uar_get_code_display(l.location_cd))
	from
		code_value cv1
		,location   l
	plan cv1
		where cv1.code_value = $FACILITY
		and   cv1.code_value > 0.0
		and   cv1.active_ind = 1
	join l
		where l.location_cd = cv1.code_value
		and   l.active_ind	= 1
	order by
		 cv1.collation_seq
		,location
		,cv1.code_value
	head report
		t_rec->prompt_loc_cnt = 0
		call writeLog(build2("->inside code_value query"))
	head cv1.code_value
		t_rec->prompt_loc_cnt = (t_rec->prompt_loc_cnt + 1)
		stat = alterlist(t_rec->prompt_loc_qual,t_rec->prompt_loc_cnt)
		t_rec->prompt_loc_qual[t_rec->prompt_loc_cnt].location_cd = cv1.code_value
		t_rec->prompt_loc_qual[t_rec->prompt_loc_cnt].location_type_cd = l.location_type_cd
		call writeLog(build2(	 "-->t_rec->prompt_loc_qual[",trim(cnvtstring(t_rec->prompt_loc_cnt)),"].location_cd="
								,trim(cnvtstring(t_rec->prompt_loc_qual[t_rec->prompt_loc_cnt].location_cd))
								,"(",trim(uar_get_code_display(t_rec->prompt_loc_qual[t_rec->prompt_loc_cnt].location_cd)),")"))
	with nocounter
endif
 
if (t_rec->prompt_loc_cnt = 0)
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "LOCATIONS"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "FACILITY_CD"
	set reply->status_data.subeventstatus.targetobjectvalue = "No prompt location code values were found"
	go to exit_script
endif
 
for (i=1 to t_rec->prompt_loc_cnt)
	call writeLog(build2(	 ^AddLocationList("^
							,value(trim(uar_get_code_meaning(t_rec->prompt_loc_qual[i].location_type_cd)))
							,^","^
							,value(trim(uar_get_code_display(t_rec->prompt_loc_qual[i].location_cd)))
							,")"))
	call AddLocationList(
		 value(trim(uar_get_code_meaning(t_rec->prompt_loc_qual[i].location_type_cd)))
		,value(trim(uar_get_code_display(t_rec->prompt_loc_qual[i].location_cd))))
endfor
 
if (location_list->location_cnt = 0)
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "LOCATIONS"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "FACILITY_CD"
	set reply->status_data.subeventstatus.targetobjectvalue = "No location code values were found"
	go to exit_script
endif
 
call writeLog(build2(cnvtrectojson(location_list)))
call writeLog(build2("* END   Finding Locations **********************************"))
 
 
call writeLog(build2("* START Finding Location Aliases ***************************"))
select into "nl:"
from
	 code_value_outbound cvo
plan cvo
	where cvo.contributor_source_cd = value(uar_get_code_by("DISPLAY",73,"COVDEV1"))
	and   cvo.code_set = 220
	and   cvo.alias_type_meaning in("NURSEUNIT","FACILITY","AMBULATORY","ROOM","BED")
order by
	 cvo.alias_type_meaning
	,cvo.code_value
head report
	call writeLog(build2("->inside code_value_outbound query"))
head cvo.alias_type_meaning
	call writeLog(build2("-->inside cvo.alias_type_meaning=",trim(cvo.alias_type_meaning)))
head cvo.code_value
	call writeLog(build2("--->found cvo.code_value=",trim(cnvtstring(cvo.code_value))))
	t_rec->location_label_cnt = (t_rec->location_label_cnt + 1)
	stat = alterlist(t_rec->location_label_qual,t_rec->location_label_cnt)
	t_rec->location_label_qual[t_rec->location_label_cnt].location_cd = cvo.code_value
	t_rec->location_label_qual[t_rec->location_label_cnt].display = trim(uar_get_code_display(cvo.code_value))
	t_rec->location_label_qual[t_rec->location_label_cnt].alias_type_meaning = trim(cvo.alias_type_meaning)
	t_rec->location_label_qual[t_rec->location_label_cnt].alias = trim(cvo.alias)
with nocounter
 
call writeLog(build2("* END   Finding Location Aliases ***************************"))
 
call writeLog(build2("* START Finding Encounter Types ****************************"))
select into "nl:"
from
     code_value cv1
	,code_value cv2
	,code_value_group cvg
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "ENCNTR_TYPE"
join cvg
	where cvg.parent_code_value		= cv1.code_value
	and   cvg.code_set				= 71
join cv2
	where cv2.code_value			= cvg.child_code_value
order by
	 cv1.description
	,cv2.code_value
head report
	call writeLog(build2("->inside encntr_type query"))
head cv1.description
	call writeLog(build2("-->inside cv1.description=",trim(cv1.description)))
head cv2.code_value
	call writeLog(build2("--->found cv2.code_value=",trim(cnvtstring(cv2.code_value))," (",trim(cv2.display),")"))
	case (cv1.description)
		of "INPATIENT":	t_rec->encntr_type.ip_cnt = (t_rec->encntr_type.ip_cnt + 1)
						stat = alterlist(t_rec->encntr_type.ip_qual,t_rec->encntr_type.ip_cnt)
						t_rec->encntr_type.ip_qual[t_rec->encntr_type.ip_cnt].encntr_type_cd = cv2.code_value
		of "EMERGENCY":	t_rec->encntr_type.ed_cnt = (t_rec->encntr_type.ed_cnt + 1)
						stat = alterlist(t_rec->encntr_type.ed_qual,t_rec->encntr_type.ed_cnt)
						t_rec->encntr_type.ed_qual[t_rec->encntr_type.ed_cnt].encntr_type_cd = cv2.code_value
	endcase
with nocounter
 
if ((t_rec->encntr_type.ip_cnt = 0) or (t_rec->encntr_type.ed_cnt = 0))
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "ENCNTR_TYPE"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "ENCNTR_TYPE"
	set reply->status_data.subeventstatus.targetobjectvalue = "The Inpatient encounter types were not found"
	go to exit_script
endif
call writeLog(build2("* END   Finding Encounter Types ****************************"))
 
call writeLog(build2("* START Finding Order Qualifiers ***************************"))
select into "nl:"
from
     code_value cv1
	,code_value cv2
	,code_value_group cvg
	,order_catalog oc
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "ORDERS"
join cvg
	where cvg.parent_code_value		= cv1.code_value
	and   cvg.code_set				in(200)
join cv2
	where cv2.code_value			= cvg.child_code_value
	and   cv2.active_ind			= 1
join oc
	where oc.catalog_cd				= cv2.code_value
	and   oc.active_ind				= 1
order by
	 cv1.description
	,cvg.collation_seq
	,cv2.code_value
head report
	call writeLog(build2("->inside order_catalog query"))
head cv1.description
	call writeLog(build2("-->inside cv1.description=",trim(cv1.description)))
head cv2.code_value
	call writeLog(build2("--->found cv2.code_value=",trim(cnvtstring(cv2.code_value))," (",trim(cv2.display),")"))
	case (cv1.description)
		of "COVID19":	t_rec->covid19.covid_oc_cnt = (t_rec->covid19.covid_oc_cnt + 1)
						stat = alterlist(t_rec->covid19.covid_oc_qual,t_rec->covid19.covid_oc_cnt)
						t_rec->covid19.covid_oc_qual[t_rec->covid19.covid_oc_cnt].catalog_cd 		= oc.catalog_cd
						t_rec->covid19.covid_oc_qual[t_rec->covid19.covid_oc_cnt].activity_type_cd	= oc.activity_type_cd
						t_rec->covid19.covid_oc_qual[t_rec->covid19.covid_oc_cnt].catalog_type_cd	= oc.catalog_type_cd
		of "PSOIP":		t_rec->pso.ip_pso_cnt = (t_rec->pso.ip_pso_cnt + 1)
						stat = alterlist(t_rec->pso.ip_pso_qual,t_rec->pso.ip_pso_cnt)
						t_rec->pso.ip_pso_qual[t_rec->pso.ip_pso_cnt].catalog_cd 		= oc.catalog_cd
						t_rec->pso.ip_pso_qual[t_rec->pso.ip_pso_cnt].activity_type_cd 	= oc.activity_type_cd
						t_rec->pso.ip_pso_qual[t_rec->pso.ip_pso_cnt].catalog_type_cd	= oc.catalog_type_cd
		of "PSOOB":		t_rec->pso.ob_pso_cnt = (t_rec->pso.ob_pso_cnt + 1)
						stat = alterlist(t_rec->pso.ob_pso_qual,t_rec->pso.ob_pso_cnt)
						t_rec->pso.ob_pso_qual[t_rec->pso.ob_pso_cnt].catalog_cd 		= oc.catalog_cd
						t_rec->pso.ob_pso_qual[t_rec->pso.ob_pso_cnt].activity_type_cd 	= oc.activity_type_cd
						t_rec->pso.ob_pso_qual[t_rec->pso.ob_pso_cnt].catalog_type_cd	= oc.catalog_type_cd
		of "ISOLATION":	t_rec->covid19.iso_oc_cnt = (t_rec->covid19.iso_oc_cnt + 1)
						stat = alterlist(t_rec->covid19.iso_oc_qual,t_rec->covid19.iso_oc_cnt)
						t_rec->covid19.iso_oc_qual[t_rec->covid19.iso_oc_cnt].catalog_cd 		= oc.catalog_cd
						t_rec->covid19.iso_oc_qual[t_rec->covid19.iso_oc_cnt].activity_type_cd 	= oc.activity_type_cd
						t_rec->covid19.iso_oc_qual[t_rec->covid19.iso_oc_cnt].catalog_type_cd	= oc.catalog_type_cd
	endcase
with nocounter
 
if ((t_rec->pso.ip_pso_cnt = 0) or (t_rec->covid19.covid_oc_cnt = 0))
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "ORDER_CATALOG"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "ORDER_CATALOG"
	set reply->status_data.subeventstatus.targetobjectvalue = "COVID-19 or PSO Orderables not found"
	go to exit_script
endif
 
select into "nl:"
from
     code_value cv1
	,code_value cv2
	,code_value_group cvg
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "ORDERS"
join cvg
	where cvg.parent_code_value		= cv1.code_value
	and   cvg.code_set				in(6004)
join cv2
	where cv2.code_value			= cvg.child_code_value
	and   cv2.active_ind			= 1
order by
	 cv1.description
	,cvg.collation_seq
	,cv2.code_value
head report
	call writeLog(build2("->inside order_status query"))
head cv1.description
	call writeLog(build2("-->inside cv1.description=",trim(cv1.description)))
head cv2.code_value
	call writeLog(build2("--->found cv2.code_value=",trim(cnvtstring(cv2.code_value))," (",trim(cv2.display),")"))
	case (cv1.description)
		of "COVID19":	t_rec->covid19.covid_status_cnt = (t_rec->covid19.covid_status_cnt + 1)
						stat = alterlist(t_rec->covid19.covid_status_qual,t_rec->covid19.covid_status_cnt)
						t_rec->covid19.covid_status_qual[t_rec->covid19.covid_status_cnt].order_status_cd 		= cv2.code_value
		of "PSOIP":		t_rec->pso.ip_pso_status_cnt = (t_rec->pso.ip_pso_status_cnt + 1)
						stat = alterlist(t_rec->pso.ip_pso_status_qual,t_rec->pso.ip_pso_status_cnt)
						t_rec->pso.ip_pso_status_qual[t_rec->pso.ip_pso_status_cnt].order_status_cd 			= cv2.code_value
		of "PSOOB":		t_rec->pso.ob_pso_status_cnt = (t_rec->pso.ob_pso_status_cnt + 1)
						stat = alterlist(t_rec->pso.ob_pso_status_qual,t_rec->pso.ob_pso_status_cnt)
						t_rec->pso.ob_pso_status_qual[t_rec->pso.ob_pso_status_cnt].order_status_cd 			= cv2.code_value
		of "ISOLATION":	t_rec->covid19.iso_status_cnt = (t_rec->covid19.iso_status_cnt + 1)
						stat = alterlist(t_rec->covid19.iso_status_qual,t_rec->covid19.iso_status_cnt)
						t_rec->covid19.iso_status_qual[t_rec->covid19.iso_status_cnt].order_status_cd 			= cv2.code_value
	endcase
with nocounter
 
if ((t_rec->pso.ip_pso_cnt = 0) or (t_rec->covid19.covid_oc_cnt = 0))
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "CODE_VALUE"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "CODE_VALUE"
	set reply->status_data.subeventstatus.targetobjectvalue = "Order Status not found"
	go to exit_script
endif
 
call writeLog(build2("* END   Finding Order Qualifiers ***************************"))
 
call writeLog(build2("* START Finding Order Disqualifiers *************************"))
select into "nl:"
from
     code_value cv1
	,code_value cv2
	,code_value cv3
	,code_value_group cvg
	,code_value_group cvb
	,code_value_extension cve
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "ORDERS"
join cvg
	where cvg.parent_code_value		= cv1.code_value
	and   cvg.code_set				= t_rec->custom_code_set
join cvb
	where cvb.parent_code_value		= cvg.child_code_value
join cv2
	where cv2.code_value			= cvg.child_code_value
	and   cv2.active_ind			= 1
	and   cv2.cdf_meaning			= "OEF_IGNORE"
join cv3
	where cv3.code_value			= cvb.child_code_value
	and   cv3.active_ind			= 1
join cve
	where cve.code_value			= cv2.code_value
	and   cve.field_name			= "OE_FIELD_ID"
order by
	 cv1.description
	,cvg.collation_seq
	,cv2.code_value
	,cvb.collation_seq
	,cv3.code_value
head report
	call writeLog(build2("->inside order_entry query"))
head cv2.code_value
	call writeLog(build2("-->looking at oe_field_id=",trim(cnvtstring(cve.field_value))," for ",trim(cv2.display)))
head cv3.code_value
	call writeLog(build2("---->adding code_value=",trim(cnvtstring(cv3.code_value))," (",trim(cv3.display),")"))
	t_rec->covid19.covid_ignore_cnt = (t_rec->covid19.covid_ignore_cnt + 1)
	stat = alterlist(t_rec->covid19.covid_ignore_qual,t_rec->covid19.covid_ignore_cnt)
	t_rec->covid19.covid_ignore_qual[t_rec->covid19.covid_ignore_cnt].oe_field_id			= cnvtreal(cve.field_value)
	t_rec->covid19.covid_ignore_qual[t_rec->covid19.covid_ignore_cnt].oe_field_value		= cv3.code_value
	t_rec->covid19.covid_ignore_qual[t_rec->covid19.covid_ignore_cnt].oe_field_value_display= cv3.display
with nocounter
call writeLog(build2("* END   Finding Order Disqualifiers *************************"))
 
call writeLog(build2("* START Finding Order Qualifiers *************************"))
select into "nl:"
from
     code_value cv1
	,code_value cv2
	,code_value cv3
	,code_value_group cvg
	,code_value_group cvb
	,code_value_extension cve
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "ORDERS"
join cvg
	where cvg.parent_code_value		= cv1.code_value
	and   cvg.code_set				= t_rec->custom_code_set
join cvb
	where cvb.parent_code_value		= cvg.child_code_value
join cv2
	where cv2.code_value			= cvg.child_code_value
	and   cv2.active_ind			= 1
	and   cv2.cdf_meaning			= "OEF_INCLUDE"
join cv3
	where cv3.code_value			= cvb.child_code_value
	and   cv3.active_ind			= 1
join cve
	where cve.code_value			= cv2.code_value
	and   cve.field_name			= "OE_FIELD_ID"
order by
	 cv1.description
	,cvg.collation_seq
	,cv2.code_value
	,cvb.collation_seq
	,cv3.code_value
head report
	call writeLog(build2("->inside order_entry query"))
head cv2.code_value
	call writeLog(build2("-->looking at oe_field_id=",trim(cnvtstring(cve.field_value))," for ",trim(cv2.display)))
head cv3.code_value
	call writeLog(build2("---->adding code_value=",trim(cnvtstring(cv3.code_value))," (",trim(cv3.display),")"))
	t_rec->covid19.iso_include_cnt = (t_rec->covid19.iso_include_cnt + 1)
	stat = alterlist(t_rec->covid19.iso_include_qual,t_rec->covid19.iso_include_cnt)
	t_rec->covid19.iso_include_qual[t_rec->covid19.iso_include_cnt].oe_field_id				= cnvtreal(cve.field_value)
	t_rec->covid19.iso_include_qual[t_rec->covid19.iso_include_cnt].oe_field_value			= cv3.code_value
	t_rec->covid19.iso_include_qual[t_rec->covid19.iso_include_cnt].oe_field_value_display	= cv3.display
with nocounter
call writeLog(build2("* END   Finding Order Qualifiers *************************"))
 
call writeLog(build2("* START Finding Result Qualifiers **************************"))
/*
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->covid19.covid_oc_cnt)
	,order_catalog oc
	,profile_task_r ptr
	,discrete_task_assay dta
	,code_value_event_r cver
	,code_value cv
plan d1
join oc
	where oc.catalog_cd = t_rec->covid19.covid_oc_qual[d1.seq].catalog_cd
join ptr
	where ptr.catalog_cd = oc.catalog_cd
	and   ptr.active_ind = 1
join cver
	where cver.parent_cd = ptr.task_assay_cd
join dta
	where dta.task_assay_cd = ptr.task_assay_cd
join cv
	where cv.code_value = cver.event_cd
order by
	 oc.catalog_cd
	,dta.task_assay_cd
	,cv.code_value
head report
	call writeLog(build2("->inside profile_task query"))
head oc.catalog_cd
	call writeLog(build2("-->inside oc.catalog_cd=",trim(cnvtstring(oc.catalog_cd))
		," (",trim(uar_get_code_display(oc.catalog_cd)),")"))
head dta.task_assay_cd
	call writeLog(build2("--->inside dta.task_assay_cd=",trim(cnvtstring(dta.task_assay_cd))
		," (",trim(dta.description),")"))
head cv.code_value
	call writeLog(build2("---->found cv.code_value=",trim(cnvtstring(cv.code_value))
		," (",trim(cv.display),")"))
	t_rec->covid19.result_cnt = (t_rec->covid19.result_cnt + 1)
	stat = alterlist(t_rec->covid19.result_qual,t_rec->covid19.result_cnt)
	t_rec->covid19.result_qual[t_rec->covid19.result_cnt].event_cd = cv.code_value
with nocounter
*/
 
select into "nl:"
from
     code_value cv1
	,code_value cv2
	,code_value_group cvg
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "EVENT_CODE"
join cvg
	where cvg.parent_code_value		= cv1.code_value
	and   cvg.code_set				in(72)
join cv2
	where cv2.code_value			= cvg.child_code_value
	and   cv2.active_ind			= 1
order by
	 cv1.description
	,cvg.collation_seq
	,cv2.code_value
head report
	call writeLog(build2("->inside event_code query"))
head cv1.description
	call writeLog(build2("-->inside cv1.description=",trim(cv1.description)))
head cv2.code_value
	call writeLog(build2("--->found cv2.code_value=",trim(cnvtstring(cv2.code_value))," (",trim(cv2.display),")"))
	case (cv1.description)
		of "COVID19":
						t_rec->covid19.result_cnt = (t_rec->covid19.result_cnt + 1)
						stat = alterlist(t_rec->covid19.result_qual,t_rec->covid19.result_cnt)
						t_rec->covid19.result_qual[t_rec->covid19.result_cnt].event_cd = cv2.code_value
		;002 start
		of "FLU":
						t_rec->flu.result_cnt = (t_rec->flu.result_cnt + 1)
						stat = alterlist(t_rec->flu.result_qual,t_rec->flu.result_cnt)
						t_rec->flu.result_qual[t_rec->flu.result_cnt].event_cd = cv2.code_value
		;002 end
		;011 start
		of "COVID19VAX":
						t_rec->covid19.vaccine_result_cnt = (t_rec->covid19.vaccine_result_cnt + 1)
						stat = alterlist(t_rec->covid19.vaccine_result_qual,t_rec->covid19.vaccine_result_cnt)
						t_rec->covid19.vaccine_result_qual[t_rec->covid19.vaccine_result_cnt].event_cd = cv2.code_value
		of "COVID19VAXYESNO":
						t_rec->covid19.vaccine_yesno_cnt = (t_rec->covid19.vaccine_yesno_cnt + 1)
						stat = alterlist(t_rec->covid19.vaccine_yesno_qual,t_rec->covid19.vaccine_yesno_cnt)
						t_rec->covid19.vaccine_yesno_qual[t_rec->covid19.vaccine_yesno_cnt].event_cd = cv2.code_value
		;011 end
		;012 start
		of "COVID19SR":
						t_rec->covid19.symptom_result_cnt = (t_rec->covid19.symptom_result_cnt + 1)
						stat = alterlist(t_rec->covid19.symptom_result_qual,t_rec->covid19.symptom_result_cnt)
						t_rec->covid19.symptom_result_qual[t_rec->covid19.symptom_result_cnt].event_cd = cv2.code_value
		of "COVID19DT":
						t_rec->covid19.date_tested_cnt = (t_rec->covid19.date_tested_cnt + 1)
						stat = alterlist(t_rec->covid19.date_tested_qual,t_rec->covid19.date_tested_cnt)
						t_rec->covid19.date_tested_qual[t_rec->covid19.date_tested_cnt].event_cd = cv2.code_value
		;012 end
	endcase
with nocounter
 
select into "nl:"
from
     code_value cv1
	,code_value cv2
	,code_value_group cvg
	,code_value_extension cve1
	,code_value_extension cve2
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "VENTILATOR"
join cvg
	where cvg.parent_code_value		= cv1.code_value
	and   cvg.code_set				in(72)
join cv2
	where cv2.code_value			= cvg.child_code_value
	and   cv2.active_ind			= 1
join cve1
	where cve1.code_value			= outerjoin(cv1.code_value)
	and   cve1.field_name			= outerjoin("LOOKBACK_HRS")
join cve2
	where cve2.code_value			= outerjoin(cv1.code_value)
	and   cve2.field_name			= outerjoin("VENT_TYPE")
order by
	 cv1.description
	,cvg.collation_seq
	,cv2.code_value
head report
	call writeLog(build2("->inside ventilator query"))
head cv1.description
	call writeLog(build2("-->inside cv1.description=",trim(cv1.description)))
head cv2.code_value
	call writeLog(build2("--->found cv2.code_value=",trim(cnvtstring(cv2.code_value))," (",trim(cv2.display),")"))
	call writeLog(build2("--->found cve1.field_value=",trim(cnvtstring(cve1.field_value))," (",trim(cve1.field_value),")"))
	case (cv1.description)
		of "ACTIVITY":
			t_rec->vent.result_cnt = (t_rec->vent.result_cnt + 1)
			stat = alterlist(t_rec->vent.result_qual,t_rec->vent.result_cnt)
			t_rec->vent.result_qual[t_rec->vent.result_cnt].event_cd = cv2.code_value
			t_rec->vent.result_qual[t_rec->vent.result_cnt].lookback_hrs = cnvtint(cve1.field_value)
			t_rec->vent.result_qual[t_rec->vent.result_cnt].vent_type = substring(1,1,cve2.field_value)
		of "MODEL":
			t_rec->vent.model_cnt = (t_rec->vent.model_cnt + 1)
			stat = alterlist(t_rec->vent.model_qual,t_rec->vent.model_cnt)
			t_rec->vent.model_qual[t_rec->vent.model_cnt].event_cd = cv2.code_value
			t_rec->vent.model_qual[t_rec->vent.model_cnt].vent_type = substring(1,1,cve2.field_value)
	endcase
with nocounter
 
if (t_rec->vent.result_cnt = 0)
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "CODE_VALUE"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "EVENT_CD"
	set reply->status_data.subeventstatus.targetobjectvalue = "Vent Event Codes not found"
	go to exit_script
endif
 
call writeLog(build2("* END   Finding Result Qualifiers **************************"))
 
call writeLog(build2("* START Finding Diagnosis Qualifiers ************************")) ;needs documentation and update
select into "nl:"
from
     code_value cv1
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "DIAGNOSIS"
order by
	cv1.code_value
head report
	call writeLog(build2("->inside diagnosis code_value query"))
head cv1.code_value
	call writeLog(build2("-->found cv1.code_value=",trim(cnvtstring(cv1.code_value))," (",trim(cv1.display),")"))
	call writeLog(build2("--->found cv1.description=",trim(cv1.description)))
	t_rec->diagnosis_search_cnt = (t_rec->diagnosis_search_cnt + 1)
	stat = alterlist(t_rec->diagnosis_search_qual,t_rec->diagnosis_search_cnt)
	t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].search_description = cv1.description
foot cv1.code_value
	call writeLog(build2("--->parsing cv1.description=",trim(cv1.description)))
	call writeLog(build2("---->piece 1=",trim(piece(cv1.description,"|",1,notfnd))))
	if (piece(cv1.description,"|",1,notfnd) != notfnd)
		t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].search_string = trim(cnvtupper(piece(cv1.description,"|",1,notfnd)))
		pos = 1
		str = ""
		call writeLog(build2("---->piece 2=",trim(piece(cv1.description,"|",2,notfnd))))
		while (str != notfnd)
			str = piece(piece(cv1.description,"|",2,notfnd),',',pos,notfnd)
			if (str != notfnd)
				call writeLog(build2("----->vocab ",trim(cnvtstring(pos))," =",trim(str)))
				t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_cnt =
					(t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_cnt + 1)
				stat = alterlist(t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_qual,
					t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_cnt)
				t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_qual[
					t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_cnt].display = trim(str,3)
				t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_qual[
					t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_cnt].source_vocabulary_cd =
						uar_get_code_by("DISPLAY",400,trim(str,3))
			endif
			pos = pos+1
		endwhile
	endif
with nocounter
 
call writeLog(build2("** Finding Vocabularies ************************"))
for (i=1 to t_rec->diagnosis_search_cnt)
	if (t_rec->diagnosis_search_qual[i].search_string > " ")
		for	(j=1 to t_rec->diagnosis_search_qual[i].source_vocabulary_cnt)
			if (t_rec->diagnosis_search_qual[i].source_vocabulary_qual[j].source_vocabulary_cd > 0.0)
			select into "nl:"
			from
				nomenclature n
			plan n
				where n.source_vocabulary_cd = t_rec->diagnosis_search_qual[i].source_vocabulary_qual[j].source_vocabulary_cd
				and   n.active_ind = 1
				and   cnvtdatetime(curdate,curtime3) between n.beg_effective_dt_tm and n.end_effective_dt_tm
				and   n.source_string_keycap = patstring(concat("*",t_rec->diagnosis_search_qual[i].search_string,"*"))
			order by
				n.nomenclature_id
			head report
				call writeLog(build2("->inside nomenclature ",trim(uar_get_code_display(n.source_vocabulary_cd))
					," for ",trim(t_rec->diagnosis_search_qual[i].search_string)))
			head n.nomenclature_id
			 if (n.source_string not in(
											 "Educated about 2019 novel coronavirus infection"
											,"Educated about COVID-19 virus infection"
											,"Educated about infection due to severe acute respiratory"
											,"Encounter for laboratory testing for COVID-19 virus"
											,"Encounter for laboratory testing for severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2)"
											,"Advice given about 2019 novel coronavirus by telephone"
											,"Advice given about 2019 novel coronavirus infection"
											,"Advice given about COVID-19 virus by telephone"
											,"Advice given about COVID-19 virus infection"
											,"Advice given about severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) by telephone"
											,"Advice given about severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) infection"
											,"COVID-19 ruled out"
					,"COVID-19 ruled out by clinical criteria"
					,"COVID-19 ruled out by laboratory testing"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) infection ruled out"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) infection ruled out by clinical criteria"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) infection ruled out by laboratory testing"
					,"COVID-19 ruled out"
					,"COVID-19 ruled out by clinical criteria"
					,"COVID-19 ruled out by laboratory testing"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) infection ruled out"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) infection ruled out by clinical criteria"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) infection ruled out by laboratory testing"
					,"2019 novel coronavirus not detected"
					,"2019 novel coronavirus vaccination contraindicated"
					,"2019 novel coronavirus vaccination declined"
					,"2019 novel coronavirus vaccination not done"
					,"2019 novel coronavirus vaccine not available"
					,"COVID-19 virus antibody negative"
					,"COVID-19 virus not detected"
					,"COVID-19 virus vaccination contraindicated"
					,"COVID-19 virus vaccination declined"
					,"COVID-19 virus vaccination not done"
					,"COVID-19 virus vaccine not available"
					,"Did not attend severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccination"
					,"Educated about infection due to severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2)"
					,"High priority for 2019 novel coronavirus vaccination"
					,"High priority for COVID-19 virus vaccination"
					,"High priority for severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccination"
					,"History of 2019 novel coronavirus disease (COVID-19)"
					,"History of 2019 novel coronavirus disease (COVID-19)"
					,"History of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) disease"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) antibody negative"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) not detected"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccination contraindicated"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccination declined"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine not administered"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine not available"
					,"Adverse effect of COVID-19 vaccine"
					,"Adverse effect of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"Allergic reaction to COVID-19 vaccine"
					,"Allergic reaction to severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"COVID-19 vaccine administered"
					,"COVID-19 vaccine dose declined"
					,"COVID-19 vaccine dose not administered"
					,"COVID-19 vaccine first dose declined"
					,"COVID-19 vaccine first dose not administered"
					,"COVID-19 vaccine not available"
					,"COVID-19 vaccine second dose declined"
					,"COVID-19 vaccine second dose not administered"
					,"COVID-19 vaccine series completed"
					,"COVID-19 vaccine series contraindicated"
					,"COVID-19 vaccine series declined"
					,"COVID-19 vaccine series not administered"
					,"COVID-19 vaccine series not completed"
					,"COVID-19 vaccine series not indicated"
					,"COVID-19 vaccine series started"
					,"Encounter for administration of COVID-19 vaccine"
					,"Encounter for administration of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"Erythema at injection site of COVID-19 vaccine"
					,"Erythema at injection site of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"Local reaction to COVID-19 vaccine"
					,"Local reaction to severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"Need for COVID-19 vaccine"
					,"Need for second dose of COVID-19 vaccine"
					,"Need for second dose of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"Need for severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"Pain at injection site of COVID-19 vaccine"
					,"Pain at injection site of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine administered"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine dose declined"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine dose not administered"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine first dose declined"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine first dose not administered"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine second dose declined"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine second dose not administered"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine series contraindicated"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine series declined"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine series not administered"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine series not completed"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine series not indicated"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine series started"
					,"Status post administration of all doses of COVID-19 vaccine series"
					,"Status post administration of all doses of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine series"
					,"Swelling at injection site of COVID-19 vaccine"
					,"Swelling at injection site of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"Systemic adverse effect of COVID-19 vaccine"
					,"Systemic adverse effect of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"Adverse neurologic event after COVID-19 vaccination"
					,"Adverse neurologic event after severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccination"
					,"COVID-19 vaccination contraindicated"
					,"COVID-19 vaccination declined"
					,"COVID-19 vaccination not done"
					,"COVID-19 vaccination refused"
					,"Fatigue after COVID-19 vaccination"
					,"Fatigue after severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccination"
					,"Fever after COVID-19 vaccination"
					,"Fever after severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccination"
					,"High priority for COVID-19 vaccination"
					,"Myalgia after COVID-19 vaccination"
					,"Myalgia after severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccination"
					,"Shortness of breath after COVID-19 vaccination"
					,"Shortness of breath after severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccination"
					,"COVID-19 virus IgG antibody not detected"
					,"COVID-19 virus IgG antibody test result equivocal"
					,"COVID-19 virus IgG antibody test result unknown"
					,"COVID-19 virus IgM antibody not detected"
					,"COVID-19 virus IgM antibody test result equivocal"
					,"COVID-19 virus IgM antibody test result unknown"
					,"COVID-19 virus RNA not detected"
					,"COVID-19 virus RNA test result equivocal"
					,"COVID-19 virus RNA test result unknown"
					,"COVID-19 virus test result equivocal"
					,"COVID-19 virus test result unknown"
					,"Equivocal immunity to COVID-19 virus"
					,"Equivocal immunity to severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2)"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) IgG antibody not detected"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) IgG antibody test result equivocal"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) IgG antibody test result unknown"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) IgM antibody not detected"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) IgM antibody test result equivocal"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) IgM antibody test result unknown"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) RNA not detected"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) RNA test result equivocal"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) RNA test result unknown"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) test result equivocal"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) test result unknown"
					,"Unknown status of immunity to COVID-19 virus"
					,"Unknown status of immunity to severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2)"
					,"COVID-19 virus RNA test result indeterminate"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) RNA test result indeterminate"
					,"Has immunity to COVID-19 virus"
					,"History of COVID-19"
					,"Immune to severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2)"
					,"Personal history of COVID-19"
					,"COVID-19 long hauler"
					,"COVID-19 long hauler manifesting chronic anxiety"
					,"COVID-19 long hauler manifesting chronic concentration deficit"
					,"COVID-19 long hauler manifesting chronic cough"
					,"COVID-19 long hauler manifesting chronic decreased mobility and endurance"
					,"COVID-19 long hauler manifesting chronic dyspnea"
					,"COVID-19 long hauler manifesting chronic fatigue"
					,"COVID-19 long hauler manifesting chronic headache"
					,"COVID-19 long hauler manifesting chronic joint pain"
					,"COVID-19 long hauler manifesting chronic loss of smell"
					,"COVID-19 long hauler manifesting chronic loss of smell and taste"
					,"COVID-19 long hauler manifesting chronic loss of taste"
					,"COVID-19 long hauler manifesting chronic muscle pain"
					,"COVID-19 long hauler manifesting chronic neurologic symptoms"
					,"COVID-19 long hauler manifesting chronic palpitations"
					,"Post COVID-19 condition"
					,"Post COVID-19 condition, unspecified"
					,"Chronic post-COVID-19 syndrome"
					,"Post covid-19 condition, unspecified"
					,"Post-COVID-19 condition"
					,"Post-COVID-19 syndrome"
					,"Post-COVID-19 syndrome manifesting as chronic anxiety"
					,"Post-COVID-19 syndrome manifesting as chronic concentration deficit"
					,"Post-COVID-19 syndrome manifesting as chronic cough"
					,"Post-COVID-19 syndrome manifesting as chronic decreased mobility and endurance"
					,"Post-COVID-19 syndrome manifesting as chronic dyspnea"
					,"Post-COVID-19 syndrome manifesting as chronic fatigue"
					,"Post-COVID-19 syndrome manifesting as chronic headache"
					,"Post-COVID-19 syndrome manifesting as chronic joint pain"
					,"Post-COVID-19 syndrome manifesting as chronic loss of smell"
					,"Post-COVID-19 syndrome manifesting as chronic loss of smell and taste"
					,"Post-COVID-19 syndrome manifesting as chronic loss of taste"
					,"Post-COVID-19 syndrome manifesting as chronic muscle pain"
					,"Post-COVID-19 syndrome manifesting as chronic neurologic symptoms"
					,"Post-COVID-19 syndrome manifesting as chronic palpitations"
					,"Post-COVID-19 syndrome manifesting as chronic shortness of breath"
					,"Post-acute COVID-19 syndrome"
					,"Post-acute sequelae of COVID-19 (PASC)"
					,"Resolved post-COVID-19 syndrome"
										))
				call writeLog(build2("-->adding nomen ",trim(n.source_string)," (",trim(n.source_identifier),")"
								 ," [",trim(cnvtstring(n.nomenclature_id)),"]"))
				t_rec->diagnosis_cnt = (t_rec->diagnosis_cnt + 1)
				stat = alterlist(t_rec->diagnosis_qual,t_rec->diagnosis_cnt)
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].nomenclature_id 		= n.nomenclature_id
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].source_string 			= n.source_string
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].source_vocabulary_cd 	= n.source_vocabulary_cd
			 endif
			with nocounter
			endif
		endfor
	endif
endfor
call writeLog(build2("** Finished Vocabularies ************************"))
call writeLog(build2("* END   Finding Diagnosis Qualifiers ************************"))
 
call writeLog(build2("* START Finding Positive Result Qualifiers ******************"))	;needs documentation
select into "nl:"
from
     code_value cv1
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "RESPONSE"
order by
	 cv1.code_value
head report
	call writeLog(build2("->inside response code_value query"))
head cv1.code_value
	call writeLog(build2("-->found cv1.code_value=",trim(cnvtstring(cv1.code_value))," (",trim(cv1.display),")"))
	call writeLog(build2("--->parsing cv1.description=",trim(cv1.description)))
	pos = 1
	str = " "
	while (str != notfnd)
		call writeLog(build2("---->checking ",trim(cnvtstring(pos))))
		str = piece(cv1.description,',',pos,notfnd)
		call writeLog(build2("---->got ",trim(str)))
		if (str != notfnd)
			if (str > " ")
				t_rec->covid19.positive_cnt = (t_rec->covid19.positive_cnt + 1)
				stat = alterlist(t_rec->covid19.positive_qual,t_rec->covid19.positive_cnt)
				call writeLog(build2("----->term ",trim(cnvtstring(pos))," =",trim(str)))
				t_rec->covid19.positive_qual[t_rec->covid19.positive_cnt].result_val = trim(str,3)
			endif
		endif
		pos = pos+1
	endwhile
 
with nocounter
call writeLog(build2("* END   Finding Positive Result Qualifiers ******************"))
 
call writeLog(build2("* START Finding Ventilator Stock Qualifiers *****************")) ;needs documentation (in ventilator section
select into "nl:"
from
     code_value cv1
	,code_value cv2
	,code_value_group cvg
	,code_value_extension cve
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "STOCK"
join cvg
	where cvg.parent_code_value		= cv1.code_value
	and   cvg.code_set				= t_rec->custom_code_set
join cv2
	where cv2.code_value			= cvg.child_code_value
	and   cv2.active_ind			= 1
join cve
	where cve.code_value			= outerjoin(cv2.code_value)
	and   cve.field_name			= outerjoin("VENT_TYPE")
order by
	 cv1.description
	,cvg.collation_seq
	,cv2.code_value
head report
	call writeLog(build2("->inside stock query"))
head cv1.description
	call writeLog(build2("-->inside cv1.description=",trim(cv1.description)))
head cv2.code_value
	call writeLog(build2("--->found cv2.code_value=",trim(cnvtstring(cv2.code_value))," (",trim(cv2.display),")"))
	case (cv1.description)
		of "VENTILATOR":
						t_rec->vent.stock_cnt = (t_rec->vent.stock_cnt + 1)
						stat = alterlist(t_rec->vent.stock_qual,t_rec->vent.stock_cnt)
						t_rec->vent.stock_qual[t_rec->vent.stock_cnt].model_name = cv2.display
						t_rec->vent.stock_qual[t_rec->vent.stock_cnt].vent_type = substring(1,1,cve.field_value)
 
	endcase
with nocounter
 
 
call writeLog(build2("* END   Finding Ventilator Stock Qualifiers *****************"))
 
call writeLog(build2("* START Finding Expired Patient Lookback ********************")) ;needs documenting
select into "nl:"
from
      code_value cv1
     ,code_value_extension cve
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "EXPIRED"
join cve
	where cve.code_value			= outerjoin(cv1.code_value)
	and   cve.field_name			= outerjoin("LOOKBACK_HRS")
order by
	  cv1.description
	 ,cv1.code_value
	 ,cve.field_name
head report
	call writeLog(build2("->inside expired code_value query"))
head cv1.description
	call writeLog(build2("-->inside cv1.description=",trim(cv1.description)))
head cv1.code_value
	call writeLog(build2("--->found cv1.code_value=",trim(cnvtstring(cv1.code_value))," (",trim(cv1.display),")"))
head cve.field_name
	call writeLog(build2("---->found cve.field_name=",trim(cve.field_name)," (",trim(cve.field_value),")"))
	if (cv1.description = "COVID19")
		if (cnvtint(cve.field_value) > 0)
			t_rec->covid19.expired_lookback_ind = 1
			t_rec->covid19.expired_lookback_hours = cnvtint(cve.field_value)
		endif
	endif
foot cve.field_name
	row +0
foot cv1.code_value
	row +0
foot cv1.description
	row +0
foot report
	row +0
with nocounter
 
if (t_rec->covid19.expired_lookback_ind = 1)
	set t_rec->covid19.expired_start_dt_tm 	= cnvtlookbehind(
																build(t_rec->covid19.expired_lookback_hours, ",", "H"),
																cnvtdatetime(curdate,curtime3))
	set t_rec->covid19.expired_end_dt_tm 	= cnvtdatetime(curdate,curtime3)
else
	set t_rec->covid19.expired_start_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
	set t_rec->covid19.expired_end_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E')
endif
call writeLog(build2("* START Finding Expired Patient Lookback ********************"))
 
call writeLog(build2("* START Finding Previous Admission **************************")) ;needs documenting
select into "nl:"
from
      code_value cv1
     ,code_value_extension cve
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "ADMISSION"
join cve
	where cve.code_value			= outerjoin(cv1.code_value)
	and   cve.field_name			= outerjoin("LOOKBACK_HRS")
order by
	  cv1.description
	 ,cv1.code_value
	 ,cve.field_name
head report
	call writeLog(build2("->inside expired code_value query"))
head cv1.description
	call writeLog(build2("-->inside cv1.description=",trim(cv1.description)))
head cv1.code_value
	call writeLog(build2("--->found cv1.code_value=",trim(cnvtstring(cv1.code_value))," (",trim(cv1.display),")"))
head cve.field_name
	call writeLog(build2("---->found cve.field_name=",trim(cve.field_name)," (",trim(cve.field_value),")"))
	if (cv1.description = "COVID19")
		if (cnvtint(cve.field_value) > 0)
			t_rec->covid19.admission_lookback_ind = 1
			t_rec->covid19.admission_lookback_hours = cnvtint(cve.field_value)
		endif
	endif
foot cve.field_name
	row +0
foot cv1.code_value
	row +0
foot cv1.description
	row +0
foot report
	row +0
with nocounter
 
if (t_rec->covid19.admission_lookback_ind = 1)
	set t_rec->covid19.admission_start_dt_tm 	= cnvtlookbehind(
																build(t_rec->covid19.expired_lookback_hours, ",", "H"),
																cnvtdatetime(curdate,curtime3))
	set t_rec->covid19.admission_end_dt_tm 	= cnvtdatetime(curdate,curtime3)
else
	set t_rec->covid19.admission_start_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
	set t_rec->covid19.admission_end_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E')
endif
 
set t_rec->ed_start_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
set t_rec->ed_end_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E')
 
call writeLog(build2("* END   Finding Previous Admission **************************"))
 
call writeLog(build2("* START Finding Previous Onset ******************************")) ;needs documenting
select into "nl:"
from
      code_value cv1
     ,code_value_extension cve
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "ONSET"
join cve
	where cve.code_value			= outerjoin(cv1.code_value)
	and   cve.field_name			= outerjoin("LOOKBACK_HRS")
order by
	  cv1.description
	 ,cv1.code_value
	 ,cve.field_name
head report
	call writeLog(build2("->inside expired code_value query"))
head cv1.description
	call writeLog(build2("-->inside cv1.description=",trim(cv1.description)))
head cv1.code_value
	call writeLog(build2("--->found cv1.code_value=",trim(cnvtstring(cv1.code_value))," (",trim(cv1.display),")"))
head cve.field_name
	call writeLog(build2("---->found cve.field_name=",trim(cve.field_name)," (",trim(cve.field_value),")"))
	if (cv1.description = "COVID19")
		if (cnvtint(cve.field_value) > 0)
			t_rec->covid19.onset_lookback_ind = 1
			t_rec->covid19.onset_lookback_hours = cnvtint(cve.field_value)
		endif
	endif
foot cve.field_name
	row +0
foot cv1.code_value
	row +0
foot cv1.description
	row +0
foot report
	row +0
with nocounter
 
if (t_rec->covid19.onset_lookback_ind = 1)
	set t_rec->covid19.onset_start_dt_tm 	= cnvtlookbehind(
																build(t_rec->covid19.expired_lookback_hours, ",", "H"),
																cnvtdatetime(curdate,curtime3))
	set t_rec->covid19.onset_end_dt_tm 		= cnvtdatetime(curdate,curtime3)
else
	set t_rec->covid19.onset_start_dt_tm 	= datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
	set t_rec->covid19.onset_end_dt_tm 		= datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E')
endif
call writeLog(build2("* END   Finding Previous Onset *****************************"))
 
call writeLog(build2("* START Finding Death Count Start Date ******************"))
select into "nl:"
from
     code_value cv1
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "DEATH_START"
order by
	 cv1.code_value
head report
	call writeLog(build2("->inside death code_value query"))
head cv1.code_value
	call writeLog(build2("-->found cv1.code_value=",trim(cnvtstring(cv1.code_value))," (",trim(cv1.display),")"))
	call writeLog(build2("--->parsing cv1.description=",trim(cv1.description)))
	t_rec->death_start_dt_tm = cnvtdatetime(trim(cv1.description))
with nocounter
 
if (t_rec->death_start_dt_tm = 0.0)
	set t_rec->death_start_dt_tm = cnvtdatetime("01-JAN-2020 00:00:00")
endif
 
call writeLog(build2("* END     Finding Death Count Start Date ******************"))
 
call writeLog(build2("* START Finding Admit Count Start/End Date ******************"))
select into "nl:"
from
     code_value cv1
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			in( "ADMIT_START", "ADMIT_END")
order by
	 cv1.code_value
head report
	call writeLog(build2("->inside admit code_value query"))
head cv1.code_value
	call writeLog(build2("-->found cv1.code_value=",trim(cnvtstring(cv1.code_value))," (",trim(cv1.display),")"))
	call writeLog(build2("--->parsing cv1.description=",trim(cv1.description)))
	case (cv1.cdf_meaning)
		of "ADMIT_START":	t_rec->admit_start_dt_tm = cnvtdatetime(trim(cv1.description))
		of "ADMIT_END":		t_rec->admit_end_dt_tm	 = cnvtdatetime(trim(cv1.description))
	endcase
with nocounter
 
if (t_rec->admit_start_dt_tm = 0.0)
	set t_rec->admit_start_dt_tm = cnvtdatetime("01-JAN-2020 00:00:00")
endif
 
if (t_rec->admit_end_dt_tm = 0.0)
	set t_rec->admit_end_dt_tm = cnvtdatetime("10-JUN-2020 00:00:00")
endif
 
call writeLog(build2("* END     Finding Admit Count Start/End Date ******************"))
 
call writeLog(build2("* START Finding Email Distribution ****************************"))	;needs documentation
select into "nl:"
from
     code_value cv1
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			in(
										 "EMAIL_SUM"
										,"EMAIL_DET"
									)
order by
	 cv1.cdf_meaning
	,cv1.code_value
head report
	call writeLog(build2("->inside email distribution code_value query"))
head cv1.cdf_meaning
	call writeLog(build2("->found cv1.cdf_meaning=",trim(cnvtstring(cv1.code_value))," (",trim(cv1.cdf_meaning),")"))
	t_rec->collection_cnt = (t_rec->collection_cnt + 1)
	stat = alterlist(t_rec->collection_qual,t_rec->collection_cnt)
	t_rec->collection_qual[t_rec->collection_cnt].name = cv1.display
	t_rec->collection_qual[t_rec->collection_cnt].filename = concat(
																	 trim(cnvtalphanum(cv1.display))
																	,"_"
																	,trim(cnvtlower(program_log->curdomain))
																	,"_"
																	,trim(format(sysdate,"yyyymmdd_hhmmss;;d")),".zip")
head cv1.code_value
	call writeLog(build2("-->found cv1.code_value=",trim(cnvtstring(cv1.code_value))," (",trim(cv1.display),")"))
	call writeLog(build2("--->parsing cv1.description=",trim(cv1.description)))
	pos = 1
	str = " "
	while (str != notfnd)
		call writeLog(build2("---->checking ",trim(cnvtstring(pos))))
		str = piece(cv1.description,';',pos,notfnd)
		call writeLog(build2("---->got ",trim(str)))
		if (str != notfnd)
			if (str > " ")
				t_rec->email_dist_cnt = (t_rec->email_dist_cnt + 1)
				stat = alterlist(t_rec->email_dist,t_rec->email_dist_cnt)
				call writeLog(build2("----->term ",trim(cnvtstring(pos))," =",trim(str)))
				t_rec->email_dist[t_rec->email_dist_cnt].email_address = concat(trim(str,3),"@covhlth.com")
				t_rec->email_dist[t_rec->email_dist_cnt].subject = cv1.display
				case (cv1.cdf_meaning)
					of "EMAIL_SUM":  t_rec->email_dist[t_rec->email_dist_cnt].type_ind = 1
									 t_rec->collection_qual[t_rec->collection_cnt].type_ind = 1
					of "EMAIL_DET":	 t_rec->email_dist[t_rec->email_dist_cnt].type_ind = 0
									 t_rec->collection_qual[t_rec->collection_cnt].type_ind
				endcase
			endif
		endif
		pos = pos+1
	endwhile
 
with nocounter
call writeLog(build2("* END   Finding Email Distribution *************************"))
 
 
call writeLog(build2("* START Finding Report Definitions *************************"))	;needs documentation
select into "nl:"
from
      code_value cv1
     ,code_value_extension cve1
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			in("REPORT_TYPE")
join cve1
		where cve1.code_value		= cv1.code_value
		and   cve1.field_name		in("REPORT_TYPE_IND")
	order by
		 cv1.collation_seq
		,cv1.display
		,cve1.field_name
		,cv1.code_value
head report
	call writeLog(build2("->inside report type code_value query"))
head cv1.code_value
	call writeLog(build2("-->found cv1.code_value=",trim(cnvtstring(cv1.code_value))," (",trim(cv1.display),")"))
	call writeLog(build2("--->parsing cv1.description=",trim(cv1.description)))
	t_rec->report_type_cnt = (t_rec->report_type_cnt + 1)
	stat = alterlist(t_rec->report_type_qual,t_rec->report_type_cnt)
	t_rec->report_type_qual[t_rec->report_type_cnt].display = cv1.display
	t_rec->report_type_qual[t_rec->report_type_cnt].prompt_report_type = cnvtint(cv1.description)
	if (cve1.field_value > " ")
		t_rec->report_type_qual[t_rec->report_type_cnt].type_ind = cnvtint(cve1.field_value)
	else
		t_rec->report_type_qual[t_rec->report_type_cnt].type_ind = -1
	endif
with nocounter,nullreport
 
 
call writeLog(build2("** Building Output List if needed"))
 
if ((t_rec->prompt_report_type = 0) and (program_log->run_from_ops = 1))
for (i=1 to t_rec->report_type_cnt)
		set t_rec->output_cnt = (t_rec->output_cnt + 1)
		set stat = alterlist(t_rec->output_qual,t_rec->output_cnt)
		set t_rec->output_qual[t_rec->output_cnt].output_file = concat(
																		"cclscratch:"
																		,"_tempname_"
																		,trim(cnvtlower(program_log->curdomain))
																		,"_"
																		,trim(format(sysdate,"yyyymmdd_hhmmss;;d"))
																		,".csv"
																		)
		set t_rec->output_qual[t_rec->output_cnt].prompt_report_type = t_rec->report_type_qual[i].prompt_report_type
		set t_rec->output_qual[t_rec->output_cnt].type_ind = t_rec->report_type_qual[i].type_ind
		set t_rec->output_qual[t_rec->output_cnt].name = t_rec->report_type_qual[i].display
	endfor
else
	set t_rec->output_cnt = (t_rec->output_cnt + 1)
	set stat = alterlist(t_rec->output_qual,t_rec->output_cnt)
	set t_rec->output_qual[t_rec->output_cnt].prompt_report_type = t_rec->prompt_report_type
	set t_rec->output_qual[t_rec->output_cnt].output_file = t_rec->output_var
endif
 
for (i=1 to t_rec->output_cnt)
	case (t_rec->output_qual[i].prompt_report_type)
		of 0: set t_rec->temp_name  = trim("full_details            " )
		of 11: set t_rec->temp_name  = trim("zzfull_details         " )
		of 8: set t_rec->temp_name  = trim("teletracking            " )
		of 9: set t_rec->temp_name  = trim("zzhrts                  " )
		of 10: set t_rec->temp_name = trim("zzhrts_v1               " )
		of 12: set t_rec->temp_name = trim("hrts_v3                 " )
		of 13: set t_rec->temp_name = trim("hrts_v4                 " )
		of 1: set t_rec->temp_name  = trim("zznhsn_summary          " )
		of 2: set t_rec->temp_name  = trim("zznhsn_detail           " )
		of 3: set t_rec->temp_name  = trim("zzhrts_summary          " )
		of 4: set t_rec->temp_name  = trim("zzhrts_detail           " )
		of 5: set t_rec->temp_name  = trim("zzfacility_dashboard    " )
			  set t_rec->output_qual[i].output_file = replace(
														 		 t_rec->output_qual[i].output_file
																,".csv"
																,".html"
															)
		of 6: set t_rec->temp_name = trim("zzteletracking_summary  " )
		of 7: set t_rec->temp_name = trim("zzteletracking_detail	")
	endcase
	set t_rec->output_qual[i].output_file = replace(
														 t_rec->output_qual[i].output_file
														,"_tempname_"
														,concat(t_rec->temp_name,"_")
													)
endfor
 
call writeLog(build2("* END   Finding Report Definitions *************************"))	;needs documentation
 
call writeLog(build2("* START Finding Encounter Domain Patients ******************"))
select into "nl:"
from
	 encntr_domain ed
	,encounter e
	,person p
plan ed
	where expand(i,1,location_list->location_cnt,ed.loc_facility_cd,location_list->locations[i].location_cd)
	and   ed.active_ind = 1
	and   ed.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
	and   ed.encntr_domain_type_cd = value(uar_get_code_by("MEANING",339,"CENSUS"))
join e
	where e.encntr_id = ed.encntr_id
	and	  (
				(expand(j,1,t_rec->encntr_type.ip_cnt,e.encntr_type_cd,t_rec->encntr_type.ip_qual[j].encntr_type_cd))
			or
				(expand(j,1,t_rec->encntr_type.ed_cnt,e.encntr_type_cd,t_rec->encntr_type.ed_qual[j].encntr_type_cd))
		   )
	and    e.encntr_status_cd not in(
										 value(uar_get_code_by("MEANING",261,"CANCELLED"))
										,value(uar_get_code_by("MEANING",261,"DISCHARGED"))
									)
join p
	where p.person_id = e.person_id
	and   p.name_last_key not in(
									 "ZZZTEST"
									,"TTTEST"
									,"TTTTEST"
									,"TTTTMAYO"
									,"TTTTTEST"
									,"FFFFOP"
									,"TTTTGENLAB"
									,"TTTTQUEST"
								)
order by
	 e.loc_facility_cd
	,e.person_id
	,e.encntr_id
head report
	call writeLog(build2("->Inside encntr_domain query"))
head e.encntr_id
	t_rec->patient_cnt = (t_rec->patient_cnt + 1)
	stat = alterlist(t_rec->patient_qual,t_rec->patient_cnt)
	t_rec->patient_qual[t_rec->patient_cnt].encntr_id 				= e.encntr_id
	t_rec->patient_qual[t_rec->patient_cnt].person_id				= e.person_id
	t_rec->patient_qual[t_rec->patient_cnt].loc_facility_cd			= e.loc_facility_cd
	t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd				= e.loc_nurse_unit_cd
	t_rec->patient_qual[t_rec->patient_cnt].loc_room_cd				= e.loc_room_cd
	t_rec->patient_qual[t_rec->patient_cnt].loc_bed_cd				= e.loc_bed_cd
	t_rec->patient_qual[t_rec->patient_cnt].encntr_type_cd			= e.encntr_type_cd
	t_rec->patient_qual[t_rec->patient_cnt].reg_dt_tm				= e.reg_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].inpatient_dt_tm			= e.inpatient_admit_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].arrive_dt_tm			= e.arrive_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].disch_dt_tm				= e.disch_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].disch_disposition_cd	= e.disch_disposition_cd
	t_rec->patient_qual[t_rec->patient_cnt].expired_dt_tm			= p.deceased_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].dob						= cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)
	t_rec->patient_qual[t_rec->patient_cnt].ip_los_hours			= datetimediff(sysdate,e.inpatient_admit_dt_tm,3)
	t_rec->patient_qual[t_rec->patient_cnt].ip_los_days				= datetimediff(sysdate,e.inpatient_admit_dt_tm,1)
	t_rec->patient_qual[t_rec->patient_cnt].name_full_formatted		= p.name_full_formatted
	t_rec->patient_qual[t_rec->patient_cnt].patient_ethnicity		= uar_get_code_display(p.ethnic_grp_cd)
	t_rec->patient_qual[t_rec->patient_cnt].patient_race			= uar_get_code_display(p.race_cd)
	t_rec->patient_qual[t_rec->patient_cnt].patient_gender			= uar_get_code_display(p.sex_cd)
	t_rec->patient_qual[t_rec->patient_cnt].accommodation			= uar_get_code_display(e.accommodation_cd) ;010
 
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].person_id="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].person_id))))
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].encntr_id="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].encntr_id))))
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].loc_facility_cd="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].loc_facility_cd))
								,"(",trim(uar_get_code_display(t_rec->patient_qual[t_rec->patient_cnt].loc_facility_cd)),")"))
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].loc_unit_cd="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd))
								,"(",trim(uar_get_code_display(t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd)),")"))
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].encntr_type_cd="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].encntr_type_cd))
								,"(",trim(uar_get_code_display(t_rec->patient_qual[t_rec->patient_cnt].encntr_type_cd)),")"))
	pos = 0
	stat = 0
	call writeLog(build2("--->Start with Bed for location label"))
	;Start with Bed for location label
	pos = locateval(j,1,t_rec->location_label_cnt,t_rec->patient_qual[t_rec->patient_cnt].loc_bed_cd
						,t_rec->location_label_qual[j].location_cd)
	if (pos > 0)
		call writeLog(build2("---->bed_pos=",pos))
		t_rec->patient_qual[t_rec->patient_cnt].loc_class_1 = t_rec->location_label_qual[pos].alias
	else
		;Check Room for location label
		call writeLog(build2("--->Check Room for location label"))
		pos = locateval(j,1,t_rec->location_label_cnt,t_rec->patient_qual[t_rec->patient_cnt].loc_room_cd
							,t_rec->location_label_qual[j].location_cd)
		if (pos > 0)
			call writeLog(build2("---->room_pos=",pos))
			t_rec->patient_qual[i].loc_class_1 = t_rec->location_label_qual[pos].alias
		else
			;Check unit for location label
			call writeLog(build2("--->Check unit for location label"))
			pos = locateval(j,1,t_rec->location_label_cnt,t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd
							,t_rec->location_label_qual[j].location_cd)
			if (pos > 0)
				call writeLog(build2("---->unit_pos=",pos))
				t_rec->patient_qual[t_rec->patient_cnt].loc_class_1 = t_rec->location_label_qual[pos].alias
			else
				call writeLog(build2("---->na_pos=",pos))
				t_rec->patient_qual[t_rec->patient_cnt].loc_class_1 = "NA"
			endif
		endif
	endif
with nocounter
 
if (t_rec->patient_cnt = 0)
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "ENCNTR_DOMAIN"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "ENCNTR_DOMAIN"
	set reply->status_data.subeventstatus.targetobjectvalue = "No Patients found for parameters"
	go to exit_script
endif
 
call writeLog(build2("* END   Finding Encounter Domain Patients ******************"))
 
 
call writeLog(build2("* START Finding Expired Patients ***************************"))
select into "nl:"
from
	 encounter e
	,person p
plan e
	where expand(i,1,location_list->location_cnt,e.loc_facility_cd,location_list->locations[i].location_cd)
	and	  (
				(expand(j,1,t_rec->encntr_type.ip_cnt,e.encntr_type_cd,t_rec->encntr_type.ip_qual[j].encntr_type_cd))
			or
				(expand(j,1,t_rec->encntr_type.ed_cnt,e.encntr_type_cd,t_rec->encntr_type.ed_qual[j].encntr_type_cd))
		   )
	and e.disch_disposition_cd in(
									 value(uar_get_code_by("DISPLAY",19,"Expired (Hospice Claims Only) 41"))
 									,value(uar_get_code_by("MEANING",19,"EXPIRED"))
 								  )
	and e.data_status_cd 	in(
									 value(uar_get_code_by("MEANING",8,"AUTH"))
 									,value(uar_get_code_by("MEANING",8,"MODIFIED"))
 							  )
	;and e.exp <= cnvtdatetime(t_rec->covid19.expired_end_dt_tm)
	and e.active_ind = 1
join p
	where p.person_id = e.person_id
	and   p.name_last_key not in(
									 "ZZZTEST"
									,"TTTEST"
									,"TTTTEST"
									,"TTTTMAYO"
									,"TTTTTEST"
									,"FFFFOP"
									,"TTTTGENLAB"
									,"TTTTQUEST"
								)
	and   p.deceased_dt_tm between cnvtdatetime(t_rec->covid19.expired_start_dt_tm) and cnvtdatetime(t_rec->covid19.expired_end_dt_tm)
order by
	 e.loc_facility_cd
	,e.person_id
	,e.encntr_id
head report
	call writeLog(build2("->Inside expired patients query"))
head e.encntr_id
	t_rec->patient_cnt = (t_rec->patient_cnt + 1)
	stat = alterlist(t_rec->patient_qual,t_rec->patient_cnt)
	t_rec->patient_qual[t_rec->patient_cnt].encntr_id 				= e.encntr_id
	t_rec->patient_qual[t_rec->patient_cnt].person_id				= e.person_id
	t_rec->patient_qual[t_rec->patient_cnt].loc_facility_cd			= e.loc_facility_cd
	t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd				= e.loc_nurse_unit_cd
	t_rec->patient_qual[t_rec->patient_cnt].loc_room_cd				= e.loc_room_cd
	t_rec->patient_qual[t_rec->patient_cnt].loc_bed_cd				= e.loc_bed_cd
	t_rec->patient_qual[t_rec->patient_cnt].encntr_type_cd			= e.encntr_type_cd
	t_rec->patient_qual[t_rec->patient_cnt].reg_dt_tm				= e.reg_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].inpatient_dt_tm			= e.inpatient_admit_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].arrive_dt_tm			= e.arrive_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].disch_dt_tm				= e.disch_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].disch_disposition_cd	= e.disch_disposition_cd
	t_rec->patient_qual[t_rec->patient_cnt].expired_dt_tm			= p.deceased_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].dob						= cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)
	t_rec->patient_qual[t_rec->patient_cnt].ip_los_hours			= datetimediff(e.disch_dt_tm,e.inpatient_admit_dt_tm,3)
	t_rec->patient_qual[t_rec->patient_cnt].ip_los_days				= datetimediff(e.disch_dt_tm,e.inpatient_admit_dt_tm,1)
	t_rec->patient_qual[t_rec->patient_cnt].name_full_formatted		= p.name_full_formatted
	t_rec->patient_qual[t_rec->patient_cnt].patient_ethnicity		= uar_get_code_display(p.ethnic_grp_cd)
	t_rec->patient_qual[t_rec->patient_cnt].patient_race			= uar_get_code_display(p.race_cd)
	t_rec->patient_qual[t_rec->patient_cnt].patient_gender			= uar_get_code_display(p.sex_cd)
	t_rec->patient_qual[t_rec->patient_cnt].expired_ind				= 1
	t_rec->patient_qual[t_rec->patient_cnt].accommodation			= uar_get_code_display(e.accommodation_cd) ;010
 
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].person_id="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].person_id))))
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].encntr_id="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].encntr_id))))
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].loc_facility_cd="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].loc_facility_cd))
								,"(",trim(uar_get_code_display(t_rec->patient_qual[t_rec->patient_cnt].loc_facility_cd)),")"))
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].loc_unit_cd="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd))
								,"(",trim(uar_get_code_display(t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd)),")"))
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].encntr_type_cd="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].encntr_type_cd))
								,"(",trim(uar_get_code_display(t_rec->patient_qual[t_rec->patient_cnt].encntr_type_cd)),")"))
	pos = 0
	stat = 0
	;Start with Bed
	pos = locateval(j,1,t_rec->location_label_cnt,t_rec->patient_qual[t_rec->patient_cnt].loc_bed_cd
						,t_rec->location_label_qual[j].location_cd)
	if (pos > 0)
		t_rec->patient_qual[t_rec->patient_cnt].loc_class_1 = t_rec->location_label_qual[pos].alias
	else
		;Check Room
		pos = locateval(j,1,t_rec->location_label_cnt,t_rec->patient_qual[t_rec->patient_cnt].loc_room_cd
							,t_rec->location_label_qual[j].location_cd)
		if (pos > 0)
			t_rec->patient_qual[i].loc_class_1 = t_rec->location_label_qual[pos].alias
		else
			;Check unit
			pos = locateval(j,1,t_rec->location_label_cnt,t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd
							,t_rec->location_label_qual[j].location_cd)
			if (pos > 0)
				t_rec->patient_qual[t_rec->patient_cnt].loc_class_1 = t_rec->location_label_qual[pos].alias
			else
				t_rec->patient_qual[t_rec->patient_cnt].loc_class_1 = "NA"
			endif
		endif
	endif
with nocounter
call writeLog(build2("* END   Finding Expired Patients ***************************"))
 
call writeLog(build2("* START Finding Death Encounters   ************************************"))
 
select into "nl:"
from
	encounter e
plan e
	where expand(i,1,location_list->location_cnt,e.loc_facility_cd,location_list->locations[i].location_cd)
	and   e.disch_dt_tm between cnvtdatetime(t_rec->death_start_dt_tm) and cnvtdatetime(curdate,curtime3)
	and   e.active_ind = 1
	and	  (
				(expand(j,1,t_rec->encntr_type.ip_cnt,e.encntr_type_cd,t_rec->encntr_type.ip_qual[j].encntr_type_cd))
			or
				(expand(j,1,t_rec->encntr_type.ed_cnt,e.encntr_type_cd,t_rec->encntr_type.ed_qual[j].encntr_type_cd))
		   )
	and e.disch_disposition_cd in(
									 value(uar_get_code_by("DISPLAY",19,"Expired (Hospice Claims Only) 41"))
 									,value(uar_get_code_by("MEANING",19,"EXPIRED"))
 								  )
	and e.data_status_cd 	in(
									 value(uar_get_code_by("MEANING",8,"AUTH"))
 									,value(uar_get_code_by("MEANING",8,"MODIFIED"))
 							  )
order by
	 e.loc_facility_cd
	,e.encntr_id
head e.loc_facility_cd
	t_rec->death_cnt = (t_rec->death_cnt + 1)
	stat = alterlist(t_rec->death_qual,t_rec->death_cnt)
	t_rec->death_qual[t_rec->death_cnt].location_cd = e.loc_facility_cd
	t_rec->death_qual[t_rec->death_cnt].facility = uar_get_code_display(e.loc_facility_cd)
head e.encntr_id
	t_rec->death_qual[t_rec->death_cnt].count = (t_rec->death_qual[t_rec->death_cnt].count + 1)
detail
	stat = 0
foot e.encntr_id
	stat = 0
foot e.loc_facility_cd
	stat = 0
with nocounter
call writeLog(build2("* END   Finding Death Encounters   ************************************"))
 
call writeLog(build2("* START Finding Admitted Encounters   *********************************"))
 
select into "nl:"
from
	encounter e
	,person p
plan e
	where expand(i,1,location_list->location_cnt,e.loc_facility_cd,location_list->locations[i].location_cd)
	and   e.inpatient_admit_dt_tm between cnvtdatetime(t_rec->admit_start_dt_tm) and cnvtdatetime(t_rec->admit_end_dt_tm)
	and   e.active_ind = 1
	and	  (
				(expand(j,1,t_rec->encntr_type.ip_cnt,e.encntr_type_cd,t_rec->encntr_type.ip_qual[j].encntr_type_cd))
		)
	and e.data_status_cd 	in(
									 value(uar_get_code_by("MEANING",8,"AUTH"))
 									,value(uar_get_code_by("MEANING",8,"MODIFIED"))
 							  )
join p
	where p.person_id = e.person_id
	and   p.name_last_key not in(
									 "ZZZTEST"
									,"TTTEST"
									,"TTTTEST"
									,"TTTTMAYO"
									,"TTTTTEST"
									,"FFFFOP"
									,"TTTTGENLAB"
									,"TTTTQUEST"
								)
order by
	 e.loc_facility_cd
	,e.encntr_id
head e.loc_facility_cd
	t_rec->admit_cnt = (t_rec->admit_cnt + 1)
	stat = alterlist(t_rec->admit_qual,t_rec->admit_cnt)
	t_rec->admit_qual[t_rec->admit_cnt].location_cd = e.loc_facility_cd
	t_rec->admit_qual[t_rec->admit_cnt].facility = uar_get_code_display(e.loc_facility_cd)
head e.encntr_id
	t_rec->admit_qual[t_rec->admit_cnt].encntr_cnt = (t_rec->admit_qual[t_rec->admit_cnt].encntr_cnt + 1)
	stat = alterlist(t_rec->admit_qual[t_rec->admit_cnt].encntr_qual,t_rec->admit_qual[t_rec->admit_cnt].encntr_cnt)
	t_rec->admit_qual[t_rec->admit_cnt].encntr_qual[t_rec->admit_qual[t_rec->admit_cnt].encntr_cnt].encntr_id = e.encntr_id
	t_rec->admit_qual[t_rec->admit_cnt].encntr_qual[t_rec->admit_qual[t_rec->admit_cnt].encntr_cnt].person_id = e.person_id
detail
	stat = 0
foot e.encntr_id
	stat = 0
foot e.loc_facility_cd
	stat = 0
with nocounter
call writeLog(build2("* END   Finding Admitted Encounters   ********************************"))
 
call writeLog(build2("* START Finding ED Encounters   *********************************"))
 
select into "nl:"
from
	encounter e
	,person p
plan e
		where expand(i,1,location_list->location_cnt,e.loc_facility_cd,location_list->locations[i].location_cd)
		and	  expand(j,1,t_rec->encntr_type.ed_cnt,e.encntr_type_cd,t_rec->encntr_type.ed_qual[j].encntr_type_cd)
		and (
				(e.disch_dt_tm between cnvtdatetime(t_rec->ed_start_dt_tm) and cnvtdatetime(t_rec->ed_end_dt_tm))
				; or
				;(e.reg_dt_tm between cnvtdatetime(t_rec->admit_start_dt_tm) and cnvtdatetime(t_rec->admit_end_dt_tm))
				; or
				;(e.reg_dt_tm < cnvtdatetime(t_rec->admit_start_dt_tm) and e.disch_dt_tm > cnvtdatetime(t_rec->admit_end_dt_tm))
			)
		and e.active_ind = 1
join p
	where p.person_id = e.person_id
	and   p.name_last_key not in(
									 "ZZZTEST"
									,"TTTEST"
									,"TTTTEST"
									,"TTTTMAYO"
									,"TTTTTEST"
									,"FFFFOP"
									,"TTTTGENLAB"
									,"TTTTQUEST"
								)
order by
	 e.loc_facility_cd
	,e.encntr_id
head report
	call writeLog(build2("->Inside ed patients query"))
head e.loc_facility_cd
	call writeLog(build2("-->Inside facility=",trim(uar_get_code_display(e.loc_facility_cd))))
	t_rec->emerg_cnt = (t_rec->emerg_cnt + 1)
	stat = alterlist(t_rec->emerg_qual,t_rec->emerg_cnt)
	t_rec->emerg_qual[t_rec->emerg_cnt].location_cd = e.loc_facility_cd
	t_rec->emerg_qual[t_rec->emerg_cnt].facility = uar_get_code_display(e.loc_facility_cd)
head e.encntr_id
	call writeLog(build2("-->Inside encounter=",trim(cnvtstring(e.encntr_id))))
	t_rec->emerg_qual[t_rec->emerg_cnt].encntr_cnt = (t_rec->emerg_qual[t_rec->emerg_cnt].encntr_cnt + 1)
	stat = alterlist(t_rec->emerg_qual[t_rec->emerg_cnt].encntr_qual,t_rec->emerg_qual[t_rec->emerg_cnt].encntr_cnt)
	t_rec->emerg_qual[t_rec->emerg_cnt].encntr_qual[t_rec->emerg_qual[t_rec->emerg_cnt].encntr_cnt].encntr_id = e.encntr_id
	t_rec->emerg_qual[t_rec->emerg_cnt].encntr_qual[t_rec->emerg_qual[t_rec->emerg_cnt].encntr_cnt].person_id = e.person_id
detail
	stat = 0
foot e.encntr_id
	stat = 0
foot e.loc_facility_cd
	stat = 0
foot report
	call writeLog(build2("->leaving ed patients query"))
with nocounter,nullreport
 
call writeLog(build2("* END   Finding ED Encounters   ********************************"))
 
call writeLog(build2("* START Finding Historic Patients ***************************"))
if (t_rec->prompt_historical_ind = 1)
	select into "nl:"
	from
		 encounter e
		,person p
	plan e
		where expand(i,1,location_list->location_cnt,e.loc_facility_cd,location_list->locations[i].location_cd)
		and	  (
					(expand(j,1,t_rec->encntr_type.ip_cnt,e.encntr_type_cd,t_rec->encntr_type.ip_qual[j].encntr_type_cd))
				or
					(expand(j,1,t_rec->encntr_type.ed_cnt,e.encntr_type_cd,t_rec->encntr_type.ed_qual[j].encntr_type_cd))
			   )
		and (
				(e.disch_dt_tm between cnvtdatetime(t_rec->prompt_beg_dt_tm) and cnvtdatetime(t_rec->prompt_end_dt_tm))
				 or
				(e.reg_dt_tm between cnvtdatetime(t_rec->prompt_beg_dt_tm) and cnvtdatetime(t_rec->prompt_end_dt_tm))
				 or
				(e.reg_dt_tm < cnvtdatetime(t_rec->prompt_beg_dt_tm) and e.disch_dt_tm > cnvtdatetime(t_rec->prompt_end_dt_tm))
			)
		and e.active_ind = 1
	join p
		where p.person_id = e.person_id
		and   p.name_last_key not in(
										 "ZZZTEST"
										,"TTTEST"
										,"TTTTEST"
										,"TTTTMAYO"
										,"TTTTTEST"
										,"FFFFOP"
										,"TTTTGENLAB"
										,"TTTTQUEST"
									)
	order by
		 e.loc_facility_cd
		,e.person_id
		,e.encntr_id
	head report
		call writeLog(build2("->Inside historical patients query"))
	head e.encntr_id
		i = locateval(j,1,t_rec->patient_cnt,e.encntr_id,t_rec->patient_qual[j].encntr_id)
		if (i = 0)
			t_rec->patient_cnt = (t_rec->patient_cnt + 1)
			stat = alterlist(t_rec->patient_qual,t_rec->patient_cnt)
			t_rec->patient_qual[t_rec->patient_cnt].encntr_id 				= e.encntr_id
			t_rec->patient_qual[t_rec->patient_cnt].person_id				= e.person_id
			t_rec->patient_qual[t_rec->patient_cnt].loc_facility_cd			= e.loc_facility_cd
			t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd				= e.loc_nurse_unit_cd
			t_rec->patient_qual[t_rec->patient_cnt].loc_room_cd				= e.loc_room_cd
			t_rec->patient_qual[t_rec->patient_cnt].loc_bed_cd				= e.loc_bed_cd
			t_rec->patient_qual[t_rec->patient_cnt].encntr_type_cd			= e.encntr_type_cd
			t_rec->patient_qual[t_rec->patient_cnt].reg_dt_tm				= e.reg_dt_tm
			t_rec->patient_qual[t_rec->patient_cnt].inpatient_dt_tm			= e.inpatient_admit_dt_tm
			t_rec->patient_qual[t_rec->patient_cnt].arrive_dt_tm			= e.arrive_dt_tm
			t_rec->patient_qual[t_rec->patient_cnt].disch_dt_tm				= e.disch_dt_tm
			t_rec->patient_qual[t_rec->patient_cnt].expired_dt_tm			= p.deceased_dt_tm
			t_rec->patient_qual[t_rec->patient_cnt].disch_disposition_cd	= e.disch_disposition_cd
			t_rec->patient_qual[t_rec->patient_cnt].dob						= cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)
			t_rec->patient_qual[t_rec->patient_cnt].ip_los_hours			= datetimediff(e.disch_dt_tm,e.inpatient_admit_dt_tm,3)
			t_rec->patient_qual[t_rec->patient_cnt].ip_los_days				= datetimediff(e.disch_dt_tm,e.inpatient_admit_dt_tm,1)
			t_rec->patient_qual[t_rec->patient_cnt].name_full_formatted		= p.name_full_formatted
			t_rec->patient_qual[t_rec->patient_cnt].patient_ethnicity		= uar_get_code_display(p.ethnic_grp_cd)
			t_rec->patient_qual[t_rec->patient_cnt].patient_race			= uar_get_code_display(p.race_cd)
			t_rec->patient_qual[t_rec->patient_cnt].patient_gender			= uar_get_code_display(p.sex_cd)
			t_rec->patient_qual[t_rec->patient_cnt].historic_ind			= 1
			t_rec->patient_qual[t_rec->patient_cnt].accommodation			= uar_get_code_display(e.accommodation_cd) ;010
 
			if (e.disch_disposition_cd in(
									 value(uar_get_code_by("DISPLAY",19,"Expired (Hospice Claims Only) 41"))
 									,value(uar_get_code_by("MEANING",19,"EXPIRED"))
 								  ))
 				t_rec->patient_qual[t_rec->patient_cnt].expired_ind = 1
 			endif
 
			call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].person_id="
										,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].person_id))))
			call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].encntr_id="
										,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].encntr_id))))
			call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].loc_facility_cd="
										,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].loc_facility_cd))
										,"(",trim(uar_get_code_display(t_rec->patient_qual[t_rec->patient_cnt].loc_facility_cd)),")"))
			call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].loc_unit_cd="
										,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd))
										,"(",trim(uar_get_code_display(t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd)),")"))
			call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].encntr_type_cd="
										,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].encntr_type_cd))
										,"(",trim(uar_get_code_display(t_rec->patient_qual[t_rec->patient_cnt].encntr_type_cd)),")"))
			pos = 0
			stat = 0
			;Start with Bed
			pos = locateval(j,1,t_rec->location_label_cnt,t_rec->patient_qual[t_rec->patient_cnt].loc_bed_cd
								,t_rec->location_label_qual[j].location_cd)
			if (pos > 0)
				t_rec->patient_qual[t_rec->patient_cnt].loc_class_1 = t_rec->location_label_qual[pos].alias
			else
				;Check Room
				pos = locateval(j,1,t_rec->location_label_cnt,t_rec->patient_qual[t_rec->patient_cnt].loc_room_cd
									,t_rec->location_label_qual[j].location_cd)
				if (pos > 0)
					t_rec->patient_qual[i].loc_class_1 = t_rec->location_label_qual[pos].alias
				else
					;Check unit
					pos = locateval(j,1,t_rec->location_label_cnt,t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd
									,t_rec->location_label_qual[j].location_cd)
					if (pos > 0)
						t_rec->patient_qual[t_rec->patient_cnt].loc_class_1 = t_rec->location_label_qual[pos].alias
					else
						t_rec->patient_qual[t_rec->patient_cnt].loc_class_1 = "NA"
					endif
				endif
			endif
		endif
	with nocounter
endif
call writeLog(build2("* END   Finding Historic Patients ***************************"))
 
call writeLog(build2("* START Finding Patient Location History ********************"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
	,encntr_loc_hist elh
plan d1
	where t_rec->patient_qual[d1.seq].encntr_id > 0.0
join elh
	where elh.encntr_id 		= t_rec->patient_qual[d1.seq].encntr_id
	and   elh.active_ind 		= 1
	and   elh.loc_facility_cd 	> 0.0
	and   elh.loc_nurse_unit_cd > 0.0
order by
	 elh.encntr_id
	,elh.activity_dt_tm
	,elh.encntr_loc_hist_id
head report
	call writeLog(build2("->Inside location query query"))
	j = 0
	add_ind = 0
	prev_loc_cd = 0.0
head elh.encntr_id
	add_ind = 0
	prev_loc_cd = 0.0
	j = locateval(i,1,t_rec->patient_cnt,elh.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(elh.encntr_id))," at position=",trim(cnvtstring(j))))
head elh.activity_dt_tm
	add_ind = 0
head elh.encntr_loc_hist_id
 if (j > 0)
	add_ind = 0
	if (t_rec->patient_qual[j].encntr_loc_cnt = 0)
		add_ind = 1
	else
		if (elh.loc_nurse_unit_cd = prev_loc_cd)
			call writeLog(build2("same unit=",trim(uar_get_code_display(elh.loc_nurse_unit_cd))
				,"(",trim(cnvtstring(elh.loc_nurse_unit_cd)),")"))
			t_rec->patient_qual[j].encntr_loc_qual[(t_rec->patient_qual[j].encntr_loc_cnt-1)].end_dt_tm = elh.end_effective_dt_tm
		else
			add_ind = 1
			call writeLog(build2("old unit="
				,trim(uar_get_code_display(t_rec->patient_qual[j].encntr_loc_qual[(t_rec->patient_qual[j].encntr_loc_cnt-1)].loc_unit_cd))
				,"(",trim(cnvtstring(t_rec->patient_qual[j].encntr_loc_qual[(t_rec->patient_qual[j].encntr_loc_cnt-1)].loc_unit_cd)),")"))
			call writeLog(build2("new unit=",trim(uar_get_code_display(elh.loc_nurse_unit_cd))
				,"(",trim(cnvtstring(elh.loc_nurse_unit_cd)),")"))
		endif
	endif
	if (add_ind = 1)
		prev_loc_cd = elh.loc_nurse_unit_cd
		t_rec->patient_qual[j].encntr_loc_cnt = (t_rec->patient_qual[j].encntr_loc_cnt + 1)
		stat = alterlist(t_rec->patient_qual[j].encntr_loc_qual,t_rec->patient_qual[j].encntr_loc_cnt)
		call writeLog(build2("adding elh.encntr_loc_hist_id=",elh.encntr_loc_hist_id))
		call writeLog(build2("adding t_rec->patient_qual[j].encntr_loc_cnt=",t_rec->patient_qual[j].encntr_loc_cnt))
		t_rec->patient_qual[j].encntr_loc_qual[t_rec->patient_qual[j].encntr_loc_cnt].loc_facility_cd		= elh.loc_facility_cd
		t_rec->patient_qual[j].encntr_loc_qual[t_rec->patient_qual[j].encntr_loc_cnt].loc_unit_cd			= elh.loc_nurse_unit_cd
		t_rec->patient_qual[j].encntr_loc_qual[t_rec->patient_qual[j].encntr_loc_cnt].facility = uar_get_code_display(elh.loc_facility_cd)
		t_rec->patient_qual[j].encntr_loc_qual[t_rec->patient_qual[j].encntr_loc_cnt].unit	= uar_get_code_display(elh.loc_nurse_unit_cd)
		t_rec->patient_qual[j].encntr_loc_qual[t_rec->patient_qual[j].encntr_loc_cnt].beg_dt_tm				= elh.beg_effective_dt_tm
		t_rec->patient_qual[j].encntr_loc_qual[t_rec->patient_qual[j].encntr_loc_cnt].end_dt_tm				= elh.end_effective_dt_tm
		t_rec->patient_qual[j].encntr_loc_qual[t_rec->patient_qual[j].encntr_loc_cnt].encntr_loc_hist_id	= elh.encntr_loc_hist_id
	endif
 endif
	add_ind = 0
foot elh.encntr_loc_hist_id
	add_ind = 0
foot elh.activity_dt_tm
	add_ind = 0
foot elh.encntr_id
	add_ind = 0
	prev_loc_cd = 0.0
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(elh.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
foot report
	j = 0
with nocounter
call writeLog(build2("* END   Finding Patient Location History ********************"))
 
call writeLog(build2("* START Finding Patient Orders (Non-Historical) *************"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
	,orders o
plan d1
	where t_rec->patient_qual[d1.seq].historic_ind = 0
join o
	where o.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and   o.person_id = t_rec->patient_qual[d1.seq].person_id
 
	and	(
		 (		 expand(i,1,t_rec->pso.ip_pso_cnt			,o.catalog_cd		,t_rec->pso.ip_pso_qual[i].catalog_cd)
			and  expand(i,1,t_rec->pso.ip_pso_status_cnt	,o.order_status_cd	,t_rec->pso.ip_pso_status_qual[i].order_status_cd)
		 )
	   or
	     (		 expand(i,1,t_rec->pso.ob_pso_cnt			,o.catalog_cd		,t_rec->pso.ob_pso_qual[i].catalog_cd)
			and  expand(i,1,t_rec->pso.ob_pso_status_cnt	,o.order_status_cd	,t_rec->pso.ob_pso_status_qual[i].order_status_cd)
		  )
	   or
	     ( 			expand(i,1,t_rec->covid19.covid_oc_cnt		,o.catalog_cd		,t_rec->covid19.covid_oc_qual[i].catalog_cd)
	    	 and	expand(i,1,t_rec->covid19.covid_status_cnt	,o.order_status_cd	,t_rec->covid19.covid_status_qual[i].order_status_cd)
	      )
	   or
	     ( 			expand(i,1,t_rec->covid19.iso_oc_cnt		,o.catalog_cd		,t_rec->covid19.iso_oc_qual[i].catalog_cd)
	    	 and	expand(i,1,t_rec->covid19.iso_status_cnt	,o.order_status_cd	,t_rec->covid19.iso_status_qual[i].order_status_cd)
	      )
	     )
	and   o.template_order_id = 0.0
	and   o.order_id > 0.0
order by
	 o.encntr_id
	,o.catalog_cd
	,o.orig_order_dt_tm desc
	,o.order_id
head report
	call writeLog(build2("->Inside patient orders query"))
	j = 0
head o.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,o.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(o.encntr_id))," at position=",trim(cnvtstring(j))))
;head o.catalog_cd DO WE NEED JUST THE MOST RECENT TEST?
head o.order_id
 if (j > 0)
	call writeLog(build2("--->order_id=",trim(cnvtstring(o.order_id))," (",trim(o.order_mnemonic),")"))
	call writeLog(build2("---->adding ",trim(uar_get_code_display(o.catalog_type_cd))," order"))
	t_rec->patient_qual[j].orders_cnt = (t_rec->patient_qual[j].orders_cnt + 1)
	stat = alterlist(t_rec->patient_qual[j].orders_qual,t_rec->patient_qual[j].orders_cnt)
	t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].order_id 				= o.order_id
	t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].activity_type_cd		= o.activity_type_cd
	t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].catalog_cd			= o.catalog_cd
	t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].catalog_type_cd		= o.catalog_type_cd
	t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].order_mnemonic		= o.hna_order_mnemonic
	t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].order_status_cd		= o.order_status_cd
	t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].order_status_display	=
																									uar_get_code_display(o.order_status_cd)
	t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].orig_order_dt_tm		= o.orig_order_dt_tm
	t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].order_status_dt_tm	= o.status_dt_tm
	/* not using
	if 	(locateval(i,1,t_rec->pso.ip_pso_cnt,o.catalog_cd,t_rec->pso.ip_pso_qual[i].catalog_cd) > 0)
 
 
	elseif	(locateval(i,1,t_rec->covid19.covid_oc_cnt,o.catalog_cd,t_rec->covid19.covid_oc_qual[i].catalog_cd))
 
	endif
	*/
 endif
foot o.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(o.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter
 
call writeLog(build2("* END  Finding Patient Orders (Non-Historical) *************"))
 
if (t_rec->prompt_historical_ind = 1)
	call writeLog(build2("* START Finding Patient Orders (Historical) ****************"))
	select into "nl:"
	from
		 (dummyt d1 with seq=t_rec->patient_cnt)
		,orders o
	plan d1
		where t_rec->patient_qual[d1.seq].historic_ind = 1
	join o
		where o.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
		and   o.person_id = t_rec->patient_qual[d1.seq].person_id
 
		and	(
			 (		 expand(i,1,t_rec->pso.ip_pso_cnt			,o.catalog_cd		,t_rec->pso.ip_pso_qual[i].catalog_cd)
				and  expand(i,1,t_rec->pso.ip_pso_status_cnt	,o.order_status_cd	,t_rec->pso.ip_pso_status_qual[i].order_status_cd)
			 )
		   or
		     (		 expand(i,1,t_rec->pso.ip_pso_cnt			,o.catalog_cd		,t_rec->pso.ip_pso_qual[i].catalog_cd)
				and  (o.order_status_cd in(value(uar_get_code_by("MEANING",6004,"DISCONTINUED"))))
			 )
		   or
		     (		 expand(i,1,t_rec->pso.ob_pso_cnt			,o.catalog_cd		,t_rec->pso.ob_pso_qual[i].catalog_cd)
				and  expand(i,1,t_rec->pso.ob_pso_status_cnt	,o.order_status_cd	,t_rec->pso.ob_pso_status_qual[i].order_status_cd)
			  )
			or
			 (		 expand(i,1,t_rec->pso.ob_pso_cnt			,o.catalog_cd		,t_rec->pso.ob_pso_qual[i].catalog_cd)
				and  (o.order_status_cd in(value(uar_get_code_by("MEANING",6004,"DISCONTINUED"))))
			  )
		    or
		     ( 			expand(i,1,t_rec->covid19.covid_oc_cnt		,o.catalog_cd		,t_rec->covid19.covid_oc_qual[i].catalog_cd)
		    	 and	expand(i,1,t_rec->covid19.covid_status_cnt	,o.order_status_cd	,t_rec->covid19.covid_status_qual[i].order_status_cd)
		      )
		    or
	     	( 			expand(i,1,t_rec->covid19.iso_oc_cnt		,o.catalog_cd		,t_rec->covid19.iso_oc_qual[i].catalog_cd)
	    		 and  (o.order_status_cd in(value(uar_get_code_by("MEANING",6004,"DISCONTINUED"))))
	      	)
		   )
		and   o.template_order_id = 0.0
		and   o.order_id > 0.0
	order by
		 o.encntr_id
		,o.catalog_cd
		,o.orig_order_dt_tm desc
		,o.order_id
	head report
		call writeLog(build2("->Inside patient historical orders query"))
		j = 0
		i = 0
	head o.encntr_id
	    i = 0
		j = locateval(i,1,t_rec->patient_cnt,o.encntr_id,t_rec->patient_qual[i].encntr_id)
		call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(o.encntr_id))," at position=",trim(cnvtstring(j))))
	;head o.catalog_cd DO WE NEED JUST THE MOST RECENT TEST?
	head o.order_id
	 i = 0
	 if (j > 0)
	  i = locateval(i,1,t_rec->patient_qual[j].orders_cnt,o.order_id,t_rec->patient_qual[j].orders_qual[i].order_id)
	  if (i = 0)
		call writeLog(build2("--->order_id=",trim(cnvtstring(o.order_id))," (",trim(o.order_mnemonic),")"))
		call writeLog(build2("---->adding ",trim(uar_get_code_display(o.catalog_type_cd))," order"))
		t_rec->patient_qual[j].orders_cnt = (t_rec->patient_qual[j].orders_cnt + 1)
		stat = alterlist(t_rec->patient_qual[j].orders_qual,t_rec->patient_qual[j].orders_cnt)
		t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].order_id 				= o.order_id
		t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].activity_type_cd		= o.activity_type_cd
		t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].catalog_cd			= o.catalog_cd
		t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].catalog_type_cd		= o.catalog_type_cd
		t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].order_mnemonic		= o.hna_order_mnemonic
		t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].order_status_cd		= o.order_status_cd
		t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].order_status_display	=
																										uar_get_code_display(o.order_status_cd)
		t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].orig_order_dt_tm		= o.orig_order_dt_tm
		t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].order_status_dt_tm	= o.status_dt_tm
		/* not using
		if 	(locateval(i,1,t_rec->pso.ip_pso_cnt,o.catalog_cd,t_rec->pso.ip_pso_qual[i].catalog_cd) > 0)
 
 
		elseif	(locateval(i,1,t_rec->covid19.covid_oc_cnt,o.catalog_cd,t_rec->covid19.covid_oc_qual[i].catalog_cd))
 
		endif
		*/
	  endif
	 endif
	foot o.encntr_id
		call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(o.encntr_id))," at position=",trim(cnvtstring(j))))
		j = 0
	with nocounter
	call writeLog(build2("* END  Finding Patient Orders (Historical)    **************"))
endif
 
call writeLog(build2("* START Finding Patient Orders Details *********************"))
if (t_rec->covid19.covid_ignore_cnt > 0)
	select into "nl:"
	from
		 (dummyt d1 with seq=t_rec->patient_cnt)
		,(dummyt d2 with seq=1)
		,order_detail od
	plan d1
		where maxrec(d2,t_rec->patient_qual[d1.seq].orders_cnt)
		;and   t_rec->patient_qual[d1.seq].expired_ind = 0
	join d2
	join od
		where od.order_id = t_rec->patient_qual[d1.seq].orders_qual[d2.seq].order_id
		and   (
				(expand(i,1,t_rec->covid19.covid_ignore_cnt,od.oe_field_id,t_rec->covid19.covid_ignore_qual[i].oe_field_id))
			or
				(expand(i,1,t_rec->covid19.iso_include_cnt,od.oe_field_id,t_rec->covid19.iso_include_qual[i].oe_field_id))
			)
	order by
		 od.order_id
		,od.oe_field_id
		,od.action_sequence desc
	head report
		call writeLog(build2("->Inside order_detail query"))
	head od.order_id
		call writeLog(build2("-->entering od.order_id=",trim(cnvtstring(od.order_id))))
	head od.oe_field_id
		call writeLog(build2("--->checking od.oe_field_id=",trim(cnvtstring(od.oe_field_id))))
		t_rec->patient_qual[d1.seq].orders_qual[d2.seq].order_detail_cnt
			= (t_rec->patient_qual[d1.seq].orders_qual[d2.seq].order_detail_cnt + 1)
		stat = alterlist(t_rec->patient_qual[d1.seq].orders_qual[d2.seq].order_detal_qual
			,t_rec->patient_qual[d1.seq].orders_qual[d2.seq].order_detail_cnt)
		t_rec->patient_qual[d1.seq].orders_qual[d2.seq].order_detal_qual[t_rec->patient_qual[d1.seq].orders_qual[d2.seq].
			order_detail_cnt].oe_field_id = od.oe_field_id
		t_rec->patient_qual[d1.seq].orders_qual[d2.seq].order_detal_qual[t_rec->patient_qual[d1.seq].orders_qual[d2.seq].
			order_detail_cnt].oe_field_display_value = od.oe_field_display_value
		t_rec->patient_qual[d1.seq].orders_qual[d2.seq].order_detal_qual[t_rec->patient_qual[d1.seq].orders_qual[d2.seq].
			order_detail_cnt].oe_field_dt_tm_value = od.oe_field_dt_tm_value
		t_rec->patient_qual[d1.seq].orders_qual[d2.seq].order_detal_qual[t_rec->patient_qual[d1.seq].orders_qual[d2.seq].
			order_detail_cnt].oe_field_value = od.oe_field_value
	with nocounter
endif
call writeLog(build2("* END Finding Patient Orders Details *********************"))
 
call writeLog(build2("* START Finding Patient Lab Results ****************************"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
	,clinical_event ce
plan d1
join ce
	where ce.person_id = t_rec->patient_qual[d1.seq].person_id
	and	  expand(i,1,t_rec->covid19.result_cnt,ce.event_cd,t_rec->covid19.result_qual[i].event_cd)
	and   ce.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
order by
	 ce.encntr_id
	,ce.event_end_dt_tm desc
	,ce.event_cd
	,ce.event_id
head report
	call writeLog(build2("->Inside clinical_event query"))
	j = 0
head ce.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,ce.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
;head ce.event_cd ;DO WE WANT JUST THE MOST RECENT RESULT per event code or encounter?
head ce.event_id
 if (j > 0)
	call writeLog(build2("--->event_id=",trim(cnvtstring(ce.event_id))," (",trim(uar_get_code_display(ce.event_cd)),")"))
	call writeLog(build2("---->adding ",trim(ce.result_val)," result"))
	t_rec->patient_qual[j].lab_results_cnt = (t_rec->patient_qual[j].lab_results_cnt + 1)
	stat = alterlist(t_rec->patient_qual[j].lab_results_qual,t_rec->patient_qual[j].lab_results_cnt)
	t_rec->patient_qual[j].lab_results_qual[t_rec->patient_qual[j].lab_results_cnt].event_id 		 	= ce.event_id
	t_rec->patient_qual[j].lab_results_qual[t_rec->patient_qual[j].lab_results_cnt].event_cd			= ce.event_cd
	t_rec->patient_qual[j].lab_results_qual[t_rec->patient_qual[j].lab_results_cnt].event_tag			= ce.event_tag
	t_rec->patient_qual[j].lab_results_qual[t_rec->patient_qual[j].lab_results_cnt].order_id			= ce.order_id
	t_rec->patient_qual[j].lab_results_qual[t_rec->patient_qual[j].lab_results_cnt].result_val			= ce.result_val
	t_rec->patient_qual[j].lab_results_qual[t_rec->patient_qual[j].lab_results_cnt].task_assay_cd		= ce.task_assay_cd
	t_rec->patient_qual[j].lab_results_qual[t_rec->patient_qual[j].lab_results_cnt].event_end_dt_tm		= ce.event_end_dt_tm
	t_rec->patient_qual[j].lab_results_qual[t_rec->patient_qual[j].lab_results_cnt].clinsig_updt_dt_tm	= ce.clinsig_updt_dt_tm
	t_rec->patient_qual[j].lab_results_qual[t_rec->patient_qual[j].lab_results_cnt].valid_from_dt_tm	= ce.valid_from_dt_tm
 
 endif
foot ce.event_id
	row +0
foot ce.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter
 
call writeLog(build2("* END   Finding Patient Lab Results ****************************"))
 
call writeLog(build2("* START Finding Patient Flu Results ****************************"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
	,clinical_event ce
plan d1
join ce
	where ce.person_id = t_rec->patient_qual[d1.seq].person_id
	and	  expand(i,1,t_rec->flu.result_cnt,ce.event_cd,t_rec->flu.result_qual[i].event_cd)
	and   ce.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
order by
	 ce.encntr_id
	,ce.event_end_dt_tm desc
	,ce.event_cd
	,ce.event_id
head report
	call writeLog(build2("->Inside clinical_event query"))
	j = 0
head ce.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,ce.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
;head ce.event_cd ;DO WE WANT JUST THE MOST RECENT RESULT per event code or encounter?
head ce.event_id
 if (j > 0)
	call writeLog(build2("--->event_id=",trim(cnvtstring(ce.event_id))," (",trim(uar_get_code_display(ce.event_cd)),")"))
	call writeLog(build2("---->adding ",trim(ce.result_val)," result"))
	t_rec->patient_qual[j].flu_results_cnt = (t_rec->patient_qual[j].flu_results_cnt + 1)
	stat = alterlist(t_rec->patient_qual[j].flu_results_qual,t_rec->patient_qual[j].flu_results_cnt)
	t_rec->patient_qual[j].flu_results_qual[t_rec->patient_qual[j].flu_results_cnt].event_id 		 	= ce.event_id
	t_rec->patient_qual[j].flu_results_qual[t_rec->patient_qual[j].flu_results_cnt].event_cd			= ce.event_cd
	t_rec->patient_qual[j].flu_results_qual[t_rec->patient_qual[j].flu_results_cnt].event_tag			= ce.event_tag
	t_rec->patient_qual[j].flu_results_qual[t_rec->patient_qual[j].flu_results_cnt].order_id			= ce.order_id
	t_rec->patient_qual[j].flu_results_qual[t_rec->patient_qual[j].flu_results_cnt].result_val			= ce.result_val
	t_rec->patient_qual[j].flu_results_qual[t_rec->patient_qual[j].flu_results_cnt].task_assay_cd		= ce.task_assay_cd
	t_rec->patient_qual[j].flu_results_qual[t_rec->patient_qual[j].flu_results_cnt].event_end_dt_tm		= ce.event_end_dt_tm
	t_rec->patient_qual[j].flu_results_qual[t_rec->patient_qual[j].flu_results_cnt].clinsig_updt_dt_tm	= ce.clinsig_updt_dt_tm
	t_rec->patient_qual[j].flu_results_qual[t_rec->patient_qual[j].flu_results_cnt].valid_from_dt_tm	= ce.valid_from_dt_tm
 
 endif
foot ce.event_id
	row +0
foot ce.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter
 
call writeLog(build2("* END   Finding Patient Flu Results ****************************"))
 
;start 011
call writeLog(build2("* START   Finding Patient COVID-19 Vaccine Results *************"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
	,clinical_event ce
plan d1
join ce
	where ce.person_id = t_rec->patient_qual[d1.seq].person_id
	and	  expand(i,1,t_rec->covid19.vaccine_result_cnt,ce.event_cd,t_rec->covid19.vaccine_result_qual[i].event_cd)
	;and   ce.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
order by
	 ce.person_id
	,ce.event_end_dt_tm desc
	,ce.event_cd
	,ce.event_id
head report
	call writeLog(build2("->Inside clinical_event query for vaccines"))
	j = 0
head ce.person_id
	j = locateval(i,1,t_rec->patient_cnt,ce.person_id,t_rec->patient_qual[i].person_id)
	call writeLog(build2("-->entering person_id=",trim(cnvtstring(ce.person_id))," at position=",trim(cnvtstring(j))))
;head ce.event_cd ;DO WE WANT JUST THE MOST RECENT RESULT per event code or encounter?
;head ce.event_id
 if (j > 0)
	call writeLog(build2("--->event_id=",trim(cnvtstring(ce.event_id))," (",trim(uar_get_code_display(ce.event_cd)),")"))
	call writeLog(build2("---->adding ",trim(uar_get_code_display(ce.event_cd))," result"))
	t_rec->patient_qual[j].covid19_vaccine_event_id = ce.event_id
	t_rec->patient_qual[j].covid19_vaccine_dt_tm = ce.event_end_dt_tm
	t_rec->patient_qual[j].covid19_vaccine = uar_get_code_display(ce.event_cd)
 endif
foot ce.event_id
	row +0
foot ce.person_id
	call writeLog(build2("-->leaving person_id=",trim(cnvtstring(ce.person_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter
 
 
select into "nl:"
	 person_id = t_rec->patient_qual[d1.seq].person_id
	,covid19_vaccine_event_id = t_rec->patient_qual[d1.seq].covid19_vaccine_event_id
	,encntr_id = t_rec->patient_qual[d1.seq].encntr_id
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
order by
	 person_id
	,covid19_vaccine_event_id desc
	,encntr_id
head report
	vaccine_pos = 0
	call writeLog(build2("->Inside query to add person level vaccine information to all encounters"))
head person_id
	vaccine_pos = 0
	call writeLog(build2("-->entering person_id=",trim(cnvtstring(person_id))," at position=",trim(cnvtstring(d1.seq))))
head covid19_vaccine_event_id
	call writeLog(build2("--->covid19_vaccine_event_id=",trim(cnvtstring(covid19_vaccine_event_id))
		," at position=",trim(cnvtstring(d1.seq))))
	if (covid19_vaccine_event_id > 0.0)
		call writeLog(build2("---->vaccine_event_id=",trim(cnvtstring(vaccine_event_id))))
		if (vaccine_event_id = 0)
			vaccine_event_id = d1.seq
		endif
	endif
head encntr_id
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(encntr_id))," at position=",trim(cnvtstring(d1.seq))))
	if (vaccine_event_id > 0)
		if (t_rec->patient_qual[d1.seq].covid19_vaccine_event_id = 0.0)
			call writeLog(build2("---->adding information to encounter from position=",trim(cnvtstring(vaccine_event_id))))
			t_rec->patient_qual[d1.seq].covid19_vaccine_event_id = t_rec->patient_qual[vaccine_event_id].covid19_vaccine_event_id
			t_rec->patient_qual[d1.seq].covid19_vaccine_dt_tm = t_rec->patient_qual[vaccine_event_id].covid19_vaccine_dt_tm
			t_rec->patient_qual[d1.seq].covid19_vaccine = t_rec->patient_qual[vaccine_event_id].covid19_vaccine
		endif
	endif
foot report
	call writeLog(build2("<-Leaving query to add person level vaccine information to all encounters"))
with nocounter
call writeLog(build2("* END   Finding Patient COVID-19 Vaccine Results *************"))
 
call writeLog(build2("* START   Finding Patient COVID-19 Vaccine Yes No *************"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
	,clinical_event ce
plan d1
join ce
	where ce.person_id = t_rec->patient_qual[d1.seq].person_id
	and	  expand(i,1,t_rec->covid19.vaccine_yesno_cnt,ce.event_cd,t_rec->covid19.vaccine_yesno_qual[i].event_cd)
	and   ce.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
order by
	 ce.encntr_id
	,ce.event_end_dt_tm desc
	,ce.event_cd
	,ce.event_id
head report
	call writeLog(build2("->Inside clinical_event query"))
	j = 0
head ce.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,ce.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
;head ce.event_cd ;DO WE WANT JUST THE MOST RECENT RESULT per event code or encounter?
;head ce.event_id
 if (j > 0)
	call writeLog(build2("--->event_id=",trim(cnvtstring(ce.event_id))," (",trim(uar_get_code_display(ce.event_cd)),")"))
	call writeLog(build2("---->adding ",trim(ce.result_val)," result"))
	t_rec->patient_qual[j].covid19_vax_yesno_e_id = ce.event_id
	t_rec->patient_qual[j].covid19_vax_yesno_dt_tm = ce.event_end_dt_tm
	t_rec->patient_qual[j].covid19_vax_yesno = trim(ce.result_val)
 endif
foot ce.event_id
	row +0
foot ce.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter
 
call writeLog(build2("* END   Finding Patient COVID-19 Yes No Results *************"))
;end 011
 
 
;start 012
call writeLog(build2("* START   Finding Patient COVID-19 Date Tested *************"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
	,clinical_event ce
plan d1
join ce
	where ce.person_id = t_rec->patient_qual[d1.seq].person_id
	and	  expand(i,1,t_rec->covid19.date_tested_cnt,ce.event_cd,t_rec->covid19.date_tested_qual[i].event_cd)
	and   ce.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
order by
	 ce.encntr_id
	,ce.event_end_dt_tm desc
	,ce.event_cd
	,ce.event_id
head report
	call writeLog(build2("->Inside clinical_event query for  COVID-19 Date Tested"))
	j = 0
head ce.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,ce.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
;head ce.event_cd ;DO WE WANT JUST THE MOST RECENT RESULT per event code or encounter?
;head ce.event_id
 if (j > 0)
	call writeLog(build2("--->event_id=",trim(cnvtstring(ce.event_id))," (",trim(uar_get_code_display(ce.event_cd)),")"))
	call writeLog(build2("---->adding ",trim(uar_get_code_display(ce.event_cd))," result"))
	t_rec->patient_qual[j].date_tested_event_id = ce.event_id
	t_rec->patient_qual[j].date_tested_dt_tm = ce.event_end_dt_tm
	t_rec->patient_qual[j].date_tested = format(t_rec->patient_qual[j].date_tested_dt_tm,"dd-mmm-yyyy;;d")
 endif
foot ce.event_id
	row +0
foot ce.encntr_id
	call writeLog(build2("-->leaving person_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter
 
 
 
call writeLog(build2("* START   Finding Patient COVID-19 symptoms start date *************"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
	,clinical_event ce
plan d1
join ce
	where ce.person_id = t_rec->patient_qual[d1.seq].person_id
	and	  expand(i,1,t_rec->covid19.symptom_result_cnt,ce.event_cd,t_rec->covid19.symptom_result_qual[i].event_cd)
	and   ce.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
order by
	 ce.encntr_id
	,ce.event_end_dt_tm desc
	,ce.event_cd
	,ce.event_id
head report
	call writeLog(build2("->Inside clinical_event query for COVID-19 symptoms start date"))
	j = 0
head ce.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,ce.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
;head ce.event_cd ;DO WE WANT JUST THE MOST RECENT RESULT per event code or encounter?
;head ce.event_id
 if (j > 0)
	call writeLog(build2("--->event_id=",trim(cnvtstring(ce.event_id))," (",trim(uar_get_code_display(ce.event_cd)),")"))
	call writeLog(build2("---->adding ",trim(uar_get_code_display(ce.event_cd))," result"))
	t_rec->patient_qual[j].symptom_result_event_id = ce.event_id
	t_rec->patient_qual[j].symptom_result_dt_tm = ce.event_end_dt_tm
	t_rec->patient_qual[j].symptom_result = format(t_rec->patient_qual[j].symptom_result_dt_tm,"dd-mmm-yyyy;;d")
 endif
foot ce.event_id
	row +0
foot ce.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter
;end 012
 
 
 
for (k=1 to t_rec->admit_cnt)
 
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->admit_qual[k].encntr_cnt)
	,clinical_event ce
plan d1
join ce
	where ce.person_id = t_rec->admit_qual[k].encntr_qual[d1.seq].person_id
	and	  expand(i,1,t_rec->covid19.result_cnt,ce.event_cd,t_rec->covid19.result_qual[i].event_cd)
	and   ce.encntr_id = t_rec->admit_qual[k].encntr_qual[d1.seq].encntr_id
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
order by
	 ce.encntr_id
	,ce.event_end_dt_tm desc
	,ce.event_cd
	,ce.event_id
head report
	call writeLog(build2("->Inside clinical_event query"))
	j = 0
head ce.encntr_id
	j = locateval(i,1,t_rec->admit_qual[k].encntr_cnt,ce.encntr_id,t_rec->admit_qual[k].encntr_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
;head ce.event_cd ;DO WE WANT JUST THE MOST RECENT RESULT per event code or encounter?
head ce.event_id
 if (j > 0)
	call writeLog(build2("--->event_id=",trim(cnvtstring(ce.event_id))," (",trim(uar_get_code_display(ce.event_cd)),")"))
	call writeLog(build2("---->adding ",trim(ce.result_val)," result"))
	t_rec->admit_qual[k].encntr_qual[j].lab_results_cnt = (t_rec->admit_qual[k].encntr_qual[j].lab_results_cnt + 1)
	stat = alterlist(t_rec->admit_qual[k].encntr_qual[j].lab_results_qual,t_rec->admit_qual[k].encntr_qual[j].lab_results_cnt)
	t_rec->admit_qual[k].encntr_qual[j].lab_results_qual[t_rec->admit_qual[k].encntr_qual[j].lab_results_cnt].event_id = ce.event_id
	t_rec->admit_qual[k].encntr_qual[j].lab_results_qual[t_rec->admit_qual[k].encntr_qual[j].lab_results_cnt].event_cd = ce.event_cd
	t_rec->admit_qual[k].encntr_qual[j].lab_results_qual[t_rec->admit_qual[k].encntr_qual[j].lab_results_cnt].event_tag = ce.event_tag
	t_rec->admit_qual[k].encntr_qual[j].lab_results_qual[t_rec->admit_qual[k].encntr_qual[j].lab_results_cnt].order_id = ce.order_id
	t_rec->admit_qual[k].encntr_qual[j].lab_results_qual[t_rec->admit_qual[k].encntr_qual[j].lab_results_cnt].result_val
		= ce.result_val
	t_rec->admit_qual[k].encntr_qual[j].lab_results_qual[t_rec->admit_qual[k].encntr_qual[j].lab_results_cnt].task_assay_cd
		= ce.task_assay_cd
	t_rec->admit_qual[k].encntr_qual[j].lab_results_qual[t_rec->admit_qual[k].encntr_qual[j].lab_results_cnt].event_end_dt_tm
		= ce.event_end_dt_tm
	t_rec->admit_qual[k].encntr_qual[j].lab_results_qual[t_rec->admit_qual[k].encntr_qual[j].lab_results_cnt].clinsig_updt_dt_tm
		= ce.clinsig_updt_dt_tm
	t_rec->admit_qual[k].encntr_qual[j].lab_results_qual[t_rec->admit_qual[k].encntr_qual[j].lab_results_cnt].valid_from_dt_tm
		= ce.valid_from_dt_tm
 
 endif
foot ce.event_id
	row +0
	for (i=1 to t_rec->covid19.positive_cnt)
		if (trim(ce.result_val) = t_rec->covid19.positive_qual[i].result_val)
			t_rec->admit_qual[k].encntr_qual[j].positive_ind = 1
			call writeLog(build2("-->POSITIVE encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
		endif
	endfor
foot ce.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter
endfor
call writeLog(build2("* END   Finding Admitted Patient Lab Results ****************************"))
 
call writeLog(build2("* START Finding ED Patient Lab Results ****************************"))
for (k=1 to t_rec->emerg_cnt)
 
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->emerg_qual[k].encntr_cnt)
	,clinical_event ce
plan d1
join ce
	where ce.person_id = t_rec->emerg_qual[k].encntr_qual[d1.seq].person_id
	and	  expand(i,1,t_rec->covid19.result_cnt,ce.event_cd,t_rec->covid19.result_qual[i].event_cd)
	and   ce.encntr_id = t_rec->emerg_qual[k].encntr_qual[d1.seq].encntr_id
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
order by
	 ce.encntr_id
	,ce.event_end_dt_tm desc
	,ce.event_cd
	,ce.event_id
head report
	call writeLog(build2("->Inside clinical_event query"))
	j = 0
head ce.encntr_id
	j = locateval(i,1,t_rec->emerg_qual[k].encntr_cnt,ce.encntr_id,t_rec->emerg_qual[k].encntr_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
;head ce.event_cd ;DO WE WANT JUST THE MOST RECENT RESULT per event code or encounter?
head ce.event_id
 if (j > 0)
	call writeLog(build2("--->event_id=",trim(cnvtstring(ce.event_id))," (",trim(uar_get_code_display(ce.event_cd)),")"))
	call writeLog(build2("---->adding ",trim(ce.result_val)," result"))
	t_rec->emerg_qual[k].encntr_qual[j].lab_results_cnt = (t_rec->emerg_qual[k].encntr_qual[j].lab_results_cnt + 1)
	stat = alterlist(t_rec->emerg_qual[k].encntr_qual[j].lab_results_qual,t_rec->emerg_qual[k].encntr_qual[j].lab_results_cnt)
	t_rec->emerg_qual[k].encntr_qual[j].lab_results_qual[t_rec->emerg_qual[k].encntr_qual[j].lab_results_cnt].event_id = ce.event_id
	t_rec->emerg_qual[k].encntr_qual[j].lab_results_qual[t_rec->emerg_qual[k].encntr_qual[j].lab_results_cnt].event_cd = ce.event_cd
	t_rec->emerg_qual[k].encntr_qual[j].lab_results_qual[t_rec->emerg_qual[k].encntr_qual[j].lab_results_cnt].event_tag = ce.event_tag
	t_rec->emerg_qual[k].encntr_qual[j].lab_results_qual[t_rec->emerg_qual[k].encntr_qual[j].lab_results_cnt].order_id = ce.order_id
	t_rec->emerg_qual[k].encntr_qual[j].lab_results_qual[t_rec->emerg_qual[k].encntr_qual[j].lab_results_cnt].result_val
		= ce.result_val
	t_rec->emerg_qual[k].encntr_qual[j].lab_results_qual[t_rec->emerg_qual[k].encntr_qual[j].lab_results_cnt].task_assay_cd
		= ce.task_assay_cd
	t_rec->emerg_qual[k].encntr_qual[j].lab_results_qual[t_rec->emerg_qual[k].encntr_qual[j].lab_results_cnt].event_end_dt_tm
		= ce.event_end_dt_tm
	t_rec->emerg_qual[k].encntr_qual[j].lab_results_qual[t_rec->emerg_qual[k].encntr_qual[j].lab_results_cnt].clinsig_updt_dt_tm
		= ce.clinsig_updt_dt_tm
	t_rec->emerg_qual[k].encntr_qual[j].lab_results_qual[t_rec->emerg_qual[k].encntr_qual[j].lab_results_cnt].valid_from_dt_tm
		= ce.valid_from_dt_tm
 
 endif
foot ce.event_id
	row +0
	for (i=1 to t_rec->covid19.positive_cnt)
		if (trim(ce.result_val) = t_rec->covid19.positive_qual[i].result_val)
			t_rec->emerg_qual[k].encntr_qual[j].positive_ind = 1
			call writeLog(build2("-->POSITIVE encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
		endif
	endfor
foot ce.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter
endfor
call writeLog(build2("* END   Finding ED Patient Lab Results ****************************"))
 
call writeLog(build2("* START Finding Patient Ventilator Results ****************************"))
call writeLog(build2("* Searching for Activity"))
 
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
	,clinical_event ce
plan d1
	;where t_rec->patient_qual[d1.seq].expired_ind = 0
join ce
	where ce.person_id = t_rec->patient_qual[d1.seq].person_id
	and	  expand(i,1,t_rec->vent.result_cnt,ce.event_cd,t_rec->vent.result_qual[i].event_cd)
	and   ce.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
order by
	 ce.encntr_id
	,ce.event_cd
	,ce.event_end_dt_tm desc
	,ce.event_id
head report
	call writeLog(build2("->Inside clinical_event query"))
	j = 0
	pos = 0
head ce.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,ce.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
head ce.event_cd
;head ce.event_id ;DO WE WANT JUST THE MOST RECENT RESULT per event code or encounter?
 if (j > 0)
	call writeLog(build2("--->event_id=",trim(cnvtstring(ce.event_id))," (",trim(uar_get_code_display(ce.event_cd)),")"))
	call writeLog(build2("---->adding ",trim(ce.result_val)," result"))
	t_rec->patient_qual[j].vent_results_cnt = (t_rec->patient_qual[j].vent_results_cnt + 1)
	stat = alterlist(t_rec->patient_qual[j].vent_results_qual,t_rec->patient_qual[j].vent_results_cnt)
	t_rec->patient_qual[j].vent_results_qual[t_rec->patient_qual[j].vent_results_cnt].event_id 		 	= ce.event_id
	t_rec->patient_qual[j].vent_results_qual[t_rec->patient_qual[j].vent_results_cnt].event_cd			= ce.event_cd
	t_rec->patient_qual[j].vent_results_qual[t_rec->patient_qual[j].vent_results_cnt].event_tag			= ce.event_tag
	t_rec->patient_qual[j].vent_results_qual[t_rec->patient_qual[j].vent_results_cnt].order_id			= ce.order_id
	t_rec->patient_qual[j].vent_results_qual[t_rec->patient_qual[j].vent_results_cnt].result_val		= ce.result_val
	t_rec->patient_qual[j].vent_results_qual[t_rec->patient_qual[j].vent_results_cnt].task_assay_cd		= ce.task_assay_cd
	t_rec->patient_qual[j].vent_results_qual[t_rec->patient_qual[j].vent_results_cnt].event_end_dt_tm	= ce.event_end_dt_tm
 
	pos = locateval(i,1,t_rec->vent.result_cnt,ce.event_cd,t_rec->vent.result_qual[i].event_cd)
	t_rec->patient_qual[j].vent_results_qual[t_rec->patient_qual[j].vent_results_cnt].ventilator_type 	=
																						t_rec->vent.result_qual[pos].vent_type
 endif
head ce.event_end_dt_tm
	row +0
head ce.event_id
	row +0
foot ce.event_id
	row +0
foot ce.event_end_dt_tm
	row +0
foot ce.event_cd
	row +0
foot ce.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter
 
call writeLog(build2("* Searching for Models "))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
	,(dummyt d2 with seq=1)
	,clinical_event ce
plan d1
	where maxrec(d2,t_rec->patient_qual[d1.seq].vent_results_cnt)
	;and   t_rec->patient_qual[d1.seq].expired_ind = 0
join d2
	where t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_id > 0.0
join ce
	where ce.person_id = t_rec->patient_qual[d1.seq].person_id
	and	  expand(i,1,t_rec->vent.model_cnt,ce.event_cd,t_rec->vent.model_qual[i].event_cd)
	;and   ce.event_end_dt_tm >= cnvtdatetime(curdate-1,0)
	and   ce.event_end_dt_tm = cnvtdatetime(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm)
	and   ce.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
order by
	 ce.encntr_id
	,ce.event_cd
	,ce.event_end_dt_tm desc
	,ce.event_id
head report
	call writeLog(build2("->Inside clinical_event query ventilator models"))
	j = 0
	pos = 0
head ce.encntr_id
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = locateval(i,1,t_rec->patient_cnt,ce.encntr_id,t_rec->patient_qual[i].encntr_id)
head ce.event_cd
	call writeLog(build2("--->checking event_cd=",trim(uar_get_code_display(ce.event_cd))," (",trim(ce.result_val),")"))
	pos = locateval(i,1,t_rec->vent.model_cnt,ce.event_cd,t_rec->vent.model_qual[i].event_cd)
	call writeLog(build2("---->checking type=",trim(t_rec->vent.model_qual[pos].vent_type)," (",trim(cnvtstring(pos)),")"))
	if (t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].ventilator_type = t_rec->vent.model_qual[pos].vent_type)
		t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_event_cd	= ce.event_cd
		t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_event_id	= ce.event_id
		t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_result_val	= trim(ce.result_val)
	endif
	pos = locateval(i,1,t_rec->vent.stock_cnt,trim(ce.result_val),t_rec->vent.stock_qual[i].model_name)
	if (pos > 0)
		t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].covenant_stock_ind = 1
	endif
head ce.event_end_dt_tm
	row +0
head ce.event_id
	row +0
foot ce.event_id
	row +0
foot ce.event_end_dt_tm
	row +0
foot ce.event_cd
	row +0
foot ce.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter
 
 
call writeLog(build2("* Searching for Models when missing documentation "))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
	,(dummyt d2 with seq=1)
	,clinical_event ce
plan d1
	where maxrec(d2,t_rec->patient_qual[d1.seq].vent_results_cnt)
	;and   t_rec->patient_qual[d1.seq].expired_ind = 0
join d2
	where t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_id > 0.0
	and   t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_event_id = 0.0
join ce
	where ce.person_id = t_rec->patient_qual[d1.seq].person_id
	and	  expand(i,1,t_rec->vent.model_cnt,ce.event_cd,t_rec->vent.model_qual[i].event_cd)
	and   ce.event_end_dt_tm >= cnvtdatetime(curdate-1,0)
	;and   ce.event_end_dt_tm = cnvtdatetime(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm)
	and   ce.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
order by
	 ce.encntr_id
	,ce.event_cd
	,ce.event_end_dt_tm desc
	,ce.event_id
head report
	call writeLog(build2("->Inside clinical_event for missing ventilator models query"))
	j = 0
	pos = 0
head ce.encntr_id
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = locateval(i,1,t_rec->patient_cnt,ce.encntr_id,t_rec->patient_qual[i].encntr_id)
	pos = 0
head ce.event_cd
	call writeLog(build2("--->checking event_cd=",trim(uar_get_code_display(ce.event_cd))," (",trim(ce.result_val),")"))
	t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_event_cd	= ce.event_cd
	t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_event_id	= ce.event_id
	t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_result_val	= trim(ce.result_val)
	pos = locateval(i,1,t_rec->vent.stock_cnt,trim(ce.result_val),t_rec->vent.stock_qual[i].model_name)
	if (pos > 0)
		t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].covenant_stock_ind = 1
	endif
/*
head ce.event_end_dt_tm
	row +0
head ce.event_id
	row +0
foot ce.event_id
	row +0
foot ce.event_end_dt_tm
	row +0
foot ce.event_cd
	row +0
foot ce.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
*/
with nocounter
 
call writeLog(build2("* END   Finding Patient Ventilator Results ****************************"))
 
call writeLog(build2("* START Finding Result Comments ****************************"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
	,(dummyt d2 with seq=1)
	,clinical_event ce
	,result r
	,result_comment rc
	,long_text lt
plan d1
	where maxrec(d2,t_rec->patient_qual[d1.seq].lab_results_cnt)
	;and t_rec->patient_qual[d1.seq].expired_ind = 0
join d2
join ce
	where ce.event_id = t_rec->patient_qual[d1.seq].lab_results_qual[d2.seq].event_id
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
join r
	where r.order_id = ce.order_id
join rc
	where rc.result_id = r.result_id
join lt
	where lt.long_text_id = rc.long_text_id
order by
	 ce.encntr_id
	,r.result_id
head report
	call writeLog(build2("->Inside clinical_event query"))
	j = 0
head ce.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,ce.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
head r.result_id
 if (j > 0)
	call writeLog(build2("--->result_id=",trim(cnvtstring(r.result_id))," (",trim(uar_get_code_display(ce.event_cd)),")"))
	for (i=1 to t_rec->patient_qual[j].lab_results_cnt)
		if (t_rec->patient_qual[j].lab_results_qual[i].order_id = ce.order_id)
			t_rec->patient_qual[j].lab_results_qual[i].comment = lt.long_text
			call writeLog(build2("---->comment for order ",trim(cnvtstring(t_rec->patient_qual[j].lab_results_qual[i].order_id))
								,"=",trim(lt.long_text)))
		endif
	endfor
 endif
foot ce.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter
 
call writeLog(build2("* END   Finding Result Comments ****************************"))
 
call writeLog(build2("* START Finding Observation Date and Time ******************"))
select into "nl:"
from
	 patient_event ea
	,(dummyt d1 with seq=t_rec->patient_cnt)
plan d1
join ea
	where ea.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and   ea.active_ind	= 1
order by
	 ea.encntr_id
	,ea.event_type_cd
	,ea.transaction_dt_tm desc
head report
	call writeLog(build2("->Inside patient_event query"))
	j = 0
head ea.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,ea.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
head ea.event_type_cd
 if (j > 0)
	case (uar_get_code_display(ea.event_type_cd))
		of "Observation Start": t_rec->patient_qual[j].observation_dt_tm = ea.event_dt_tm
								call writeLog(build2("--->adding observation start=",trim(format(ea.event_dt_tm,";;q"))))
	endcase
 endif
foot ea.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter
 
call writeLog(build2("* END   Finding Observation Date and Time ******************"))
 
call writeLog(build2("* START Finding Diagnosis **********************************"))
select into "nl:"
from
	 diagnosis ea
	,nomenclature n
	,(dummyt d1 with seq=t_rec->patient_cnt)
plan d1
join ea
	where ea.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and   ea.active_ind	= 1
	and	  cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
	and   ea.confirmation_status_cd in(
										value(uar_get_code_by("MEANING",12031,"CONFIRMED"))
									   )
	and   ea.classification_cd in(
									 value(uar_get_code_by("MEANING",12033,"MEDICAL"))
									,value(uar_get_code_by("MEANING",12033,"PATSTATED"))
								 )
	and	  (
				(expand(i,1,t_rec->diagnosis_cnt,ea.originating_nomenclature_id,t_rec->diagnosis_qual[i].nomenclature_id))
			or
				(expand(i,1,t_rec->diagnosis_cnt,ea.nomenclature_id,t_rec->diagnosis_qual[i].nomenclature_id))
		   )
join n
	where n.nomenclature_id = ea.nomenclature_id
order by
	 ea.encntr_id
	,ea.diagnosis_id
head report
	call writeLog(build2("->Inside diagnosis query"))
	j = 0
head ea.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,ea.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
	if (j > 0)
	 	t_rec->patient_qual[j].diagnosis_cnt = (t_rec->patient_qual[j].diagnosis_cnt + 1)
	 	stat = alterlist(t_rec->patient_qual[j].diagnosis_qual,t_rec->patient_qual[j].diagnosis_cnt)
	 	t_rec->patient_qual[j].diagnosis_qual[t_rec->patient_qual[j].diagnosis_cnt].diagnosis_id 			= ea.diagnosis_id
	 	t_rec->patient_qual[j].diagnosis_qual[t_rec->patient_qual[j].diagnosis_cnt].nomenclature_id			= ea.nomenclature_id
	 	t_rec->patient_qual[j].diagnosis_qual[t_rec->patient_qual[j].diagnosis_cnt].orig_nomenclature_id	= ea.originating_nomenclature_id
	 	t_rec->patient_qual[j].diagnosis_qual[t_rec->patient_qual[j].diagnosis_cnt].source_string			= n.source_string
	 	t_rec->patient_qual[j].diagnosis_qual[t_rec->patient_qual[j].diagnosis_cnt].diagnosis_display		= ea.diagnosis_display
	 	t_rec->patient_qual[j].diagnosis_qual[t_rec->patient_qual[j].diagnosis_cnt].daig_dt_tm				= ea.diag_dt_tm
	 	call writeLog(build2("--->added diagnosis=",trim(ea.diagnosis_display)))
	endif
foot ea.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter
 
call writeLog(build2("* END Finding Diagnosis **********************************"))
 
call writeLog(build2("* START Finding Diagnosis for Admitted **********************************"))
for (k=1 to t_rec->admit_cnt)
select into "nl:"
from
	 diagnosis ea
	,nomenclature n
	,(dummyt d1 with seq=t_rec->admit_qual[k].encntr_cnt)
plan d1
join ea
	where ea.encntr_id = t_rec->admit_qual[k].encntr_qual[d1.seq].encntr_id
	and   ea.active_ind	= 1
	and	  cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
	and   ea.confirmation_status_cd in(
										value(uar_get_code_by("MEANING",12031,"CONFIRMED"))
									   )
	and   ea.classification_cd in(
									 value(uar_get_code_by("MEANING",12033,"MEDICAL"))
									,value(uar_get_code_by("MEANING",12033,"PATSTATED"))
								 )
	and	  (
				(expand(i,1,t_rec->diagnosis_cnt,ea.originating_nomenclature_id,t_rec->diagnosis_qual[i].nomenclature_id))
			or
				(expand(i,1,t_rec->diagnosis_cnt,ea.nomenclature_id,t_rec->diagnosis_qual[i].nomenclature_id))
		   )
join n
	where n.nomenclature_id = ea.nomenclature_id
order by
	 ea.encntr_id
	,ea.diagnosis_id
head report
	call writeLog(build2("->Inside diagnosis query"))
	j = 0
head ea.encntr_id
	j = locateval(i,1,t_rec->admit_qual[k].encntr_cnt,ea.encntr_id,t_rec->admit_qual[k].encntr_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
	if (j > 0)
	 if (ea.diagnosis_display not in(
																				 "SARS-associated coronavirus exposure"
																				,"Exposure to SARS-associated coronavirus"
																				,"Exposure*"
																				,"*exposure*"
																				;,"*Rule Out*"
																				;,"*RULE OUT*"
																				;,"*rule out*"
																				,"*Person under investigation*"
																				,"Person under investigation*"
																				,"Suspected*"))
 
		 	t_rec->admit_qual[k].encntr_qual[j].diagnosis_cnt = (t_rec->admit_qual[k].encntr_qual[j].diagnosis_cnt + 1)
		 	stat = alterlist(t_rec->admit_qual[k].encntr_qual[j].diagnosis_qual,t_rec->admit_qual[k].encntr_qual[j].diagnosis_cnt)
		 	t_rec->admit_qual[k].encntr_qual[j].diagnosis_qual[t_rec->admit_qual[k].encntr_qual[j].diagnosis_cnt].diagnosis_id
		 		= ea.diagnosis_id
		 	t_rec->admit_qual[k].encntr_qual[j].diagnosis_qual[t_rec->admit_qual[k].encntr_qual[j].diagnosis_cnt].nomenclature_id
		 		= ea.nomenclature_id
		 	t_rec->admit_qual[k].encntr_qual[j].diagnosis_qual[t_rec->admit_qual[k].encntr_qual[j].diagnosis_cnt].orig_nomenclature_id
		 		= ea.originating_nomenclature_id
		 	t_rec->admit_qual[k].encntr_qual[j].diagnosis_qual[t_rec->admit_qual[k].encntr_qual[j].diagnosis_cnt].source_string
		 		= n.source_string
		 	t_rec->admit_qual[k].encntr_qual[j].diagnosis_qual[t_rec->admit_qual[k].encntr_qual[j].diagnosis_cnt].diagnosis_display
		 		= ea.diagnosis_display
		 	t_rec->admit_qual[k].encntr_qual[j].diagnosis_qual[t_rec->admit_qual[k].encntr_qual[j].diagnosis_cnt].daig_dt_tm
		 		= ea.diag_dt_tm
		 	call writeLog(build2("--->added diagnosis=",trim(ea.diagnosis_display)))
	 endif
	endif
foot ea.encntr_id
	if (t_rec->admit_qual[k].encntr_qual[j].diagnosis_cnt > 0)
		if (t_rec->admit_qual[k].encntr_qual[j].positive_ind = 0)
			t_rec->admit_qual[k].encntr_qual[j].positive_ind = 0
			call writeLog(build2("-->POSITIVE DX encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
		endif
	endif
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter
endfor
 
call writeLog(build2("* END Finding Diagnosis for Admitted **********************************"))
call writeLog(build2("* START Finding FIN ****************************************"))
select into "nl:"
from
	 encntr_alias ea
	,(dummyt d1 with seq=t_rec->patient_cnt)
plan d1
join ea
	where ea.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and   ea.active_ind	= 1
	and	  cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
order by
	 ea.encntr_id
	,ea.beg_effective_dt_tm desc
head report
	call writeLog(build2("->Inside encntr_alias query"))
	j = 0
head ea.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,ea.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
	if (j > 0)
	 	t_rec->patient_qual[j].fin = cnvtalias(ea.alias,ea.alias_pool_cd)
	 	call writeLog(build2("--->added fin nbr=",trim(t_rec->patient_qual[j].fin)))
	endif
foot ea.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter
call writeLog(build2("* END   Finding FIN ****************************************"))
call writeLog(build2("* START Finding Address ****************************************"))
 
select into "nl:"
from
	person p
	,address a
	,(dummyt d1 with seq=t_rec->patient_cnt)
plan d1
join p
	where p.person_id = t_rec->patient_qual[d1.seq].person_id
join a
	where a.parent_entity_id = p.person_id
	and   a.parent_entity_name = "PERSON"
	and   a.address_type_cd in(value(uar_get_code_by("MEANING",212,"HOME")))
	and   cnvtdatetime(curdate,curtime3) between a.beg_effective_dt_tm and a.end_effective_dt_tm
	and   a.active_ind = 1
order by
	  p.person_id
	 ,a.beg_effective_dt_tm
	 ,a.address_id
head report
	call writeLog(build2("->Inside encntr_alias query"))
head a.address_id
	t_rec->patient_qual[d1.seq].patient_address_county = uar_get_code_display(a.county_cd)
with nocounter
 
call writeLog(build2("* END   Finding Address ****************************************"))
 
 
call writeLog(build2("* START Finding Phone ****************************************"))
 
select into "nl:"
 phone_priority = evaluate(uar_get_code_meaning(ph.phone_type_cd),
						"HOME"		,2,
						"MOBILE"	,1,
						"BUSINESS"	,3,
						"PAGER PERS",4,
						"ALTERNATE"	,5,9)
from
	person p
	,phone ph
	,(dummyt d1 with seq=t_rec->patient_cnt)
plan d1
join p
	where p.person_id = t_rec->patient_qual[d1.seq].person_id
join ph
	where ph.parent_entity_id = p.person_id
	and   ph.parent_entity_name = "PERSON"
	and   cnvtdatetime(curdate,curtime3) between ph.beg_effective_dt_tm and ph.end_effective_dt_tm
	and   ph.active_ind = 1
	and   ph.phone_num > " "
order by
	 p.person_id
	,phone_priority
head report
	call writeLog(build2("->Inside encntr_alias query"))
head p.person_id
	null
head phone_priority
	t_rec->patient_qual[d1.seq].patient_phone_num = cnvtphone(ph.phone_num,ph.phone_format_cd)
with nocounter
 
call writeLog(build2("* END   Finding Phone ****************************************"))
 
call writeLog(build2("* START Finding Covenant Aliases ***************************"))
select into "nl:"
from
	 code_value_outbound cvo
	,encounter e
	,(dummyt d1 with seq=t_rec->patient_cnt)
plan d1
join e
	where 	t_rec->patient_qual[d1.seq].encntr_id = e.encntr_id
join cvo
	where	(
					(cvo.code_value = t_rec->patient_qual[d1.seq].loc_facility_cd)
				or	(cvo.code_value = t_rec->patient_qual[d1.seq].loc_unit_cd)
				or	(cvo.code_value = t_rec->patient_qual[d1.seq].loc_room_cd)
				or	(cvo.code_value = t_rec->patient_qual[d1.seq].loc_bed_cd)
			)
	and cvo.contributor_source_cd = value(uar_get_code_by("DISPLAY",73,"COVENANT"))
order by
	  e.encntr_id
	 ,cvo.alias_type_meaning
head report
	call writeLog(build2("->Inside encntr_alias query"))
	j = 0
head e.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,e.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(e.encntr_id))," at position=",trim(cnvtstring(j))))
head cvo.alias_type_meaning
	call writeLog(build2("--->entering cvo.alias_type_meaning=",trim(cvo.alias_type_meaning)," at position=",trim(cnvtstring(j))))
detail
	if (cvo.code_value = t_rec->patient_qual[j].loc_facility_cd)
		t_rec->patient_qual[j].cov_facility_alias = trim(cvo.alias)
	elseif (cvo.code_value = t_rec->patient_qual[j].loc_unit_cd)
		t_rec->patient_qual[j].cov_unit_alias = trim(cvo.alias)
	elseif (cvo.code_value = t_rec->patient_qual[j].loc_room_cd)
		t_rec->patient_qual[j].cov_room_alias = trim(cvo.alias)
	elseif (cvo.code_value = t_rec->patient_qual[j].loc_bed_cd)
		t_rec->patient_qual[j].cov_bed_alias = trim(cvo.alias)
	endif
with nocounter
 
call writeLog(build2("* END   Finding Covenant Aliases ***************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building Output ************************************"))
 
for (i=1 to t_rec->patient_cnt)
	set t_output->cnt = (t_output->cnt + 1)
	set stat = alterlist(t_output->qual,t_output->cnt)
 
	set t_output->qual[t_output->cnt].person_id				= t_rec->patient_qual[i].person_id
	set t_output->qual[t_output->cnt].encntr_id				= t_rec->patient_qual[i].encntr_id
	set t_output->qual[t_output->cnt].facility				= trim(uar_get_code_display(t_rec->patient_qual[i].loc_facility_cd))
	set t_output->qual[t_output->cnt].encntr_type			= trim(uar_get_code_display(t_rec->patient_qual[i].encntr_type_cd))
	set t_output->qual[t_output->cnt].patient_name			= trim(t_rec->patient_qual[i].name_full_formatted)
	set t_output->qual[t_output->cnt].fin					= trim(t_rec->patient_qual[i].fin)
	set t_output->qual[t_output->cnt].dob					= trim(format(t_rec->patient_qual[i].dob,";;d"))
	set t_output->qual[t_output->cnt].unit					= trim(uar_get_code_display(t_rec->patient_qual[i].loc_unit_cd))
 
	if ((t_rec->patient_qual[i].loc_room_cd = 0.0) and (t_rec->patient_qual[i].loc_bed_cd > 0.0))
		set t_output->qual[t_output->cnt].room_bed				= trim(concat(
																			trim(uar_get_code_display(t_rec->patient_qual[i].loc_bed_cd),3)
																			),3)
	elseif ((t_rec->patient_qual[i].loc_room_cd > 0.0) and (t_rec->patient_qual[i].loc_bed_cd = 0.0))
		set t_output->qual[t_output->cnt].room_bed				= trim(concat(
																			trim(uar_get_code_display(t_rec->patient_qual[i].loc_room_cd),3)
																			),3)
	elseif ((t_rec->patient_qual[i].loc_room_cd > 0.0) and (t_rec->patient_qual[i].loc_bed_cd > 0.0))
		set t_output->qual[t_output->cnt].room_bed				= trim(concat(
																			trim(uar_get_code_display(t_rec->patient_qual[i].loc_room_cd),3)
																			,"-"
																			,trim(uar_get_code_display(t_rec->patient_qual[i].loc_bed_cd),3)
																			),3)
	endif
 
	set t_output->qual[t_output->cnt].los_days				= t_rec->patient_qual[i].ip_los_days
	set t_output->qual[t_output->cnt].los_hours				= t_rec->patient_qual[i].ip_los_hours
	set t_output->qual[t_output->cnt].inpatient_dt_tm		= format(t_rec->patient_qual[i].inpatient_dt_tm,";;q")
	set t_output->qual[t_output->cnt].observation_dt_tm		= format(t_rec->patient_qual[i].observation_dt_tm,";;q")
	set t_output->qual[t_output->cnt].reg_dt_tm				= format(t_rec->patient_qual[i].reg_dt_tm,";;q")
	set t_output->qual[t_output->cnt].arrive_dt_tm			= format(t_rec->patient_qual[i].arrive_dt_tm,";;q")
	set t_output->qual[t_output->cnt].disch_dt_tm			= format(t_rec->patient_qual[i].disch_dt_tm,";;q")
 
	;Diagnosis Column
	if (t_rec->patient_qual[i].diagnosis_cnt > 0)
		for (j=1 to t_rec->patient_qual[i].diagnosis_cnt)
			if (j>1)
				set t_output->qual[t_output->cnt].diagnosis = concat(	 t_output->qual[t_output->cnt].diagnosis,";"
																		,trim(t_rec->patient_qual[i].diagnosis_qual[j].source_string))
			else
				set t_output->qual[t_output->cnt].diagnosis = trim(t_rec->patient_qual[i].diagnosis_qual[j].source_string)
			endif
			if ((t_rec->patient_qual[i].diagnosis_qual[j].source_string in(
																				 "SARS-associated coronavirus exposure"
																				,"Exposure to SARS-associated coronavirus"
																				,"Exposure*"
																				,"*exposure*"
																				,"Suspected*"
																				,"*Person under investigation*"
																				,"Person under investigation*"
																			  ))
			   or (t_rec->patient_qual[i].diagnosis_qual[j].diagnosis_display in(
																				 "SARS-associated coronavirus exposure"
																				,"Exposure to SARS-associated coronavirus"
																				,"Exposure*"
																				,"*exposure*"
																				,"Suspected*"
																				,"*Person under investigation*"
																				,"Person under investigation*"
																			  ))
				)
				set t_output->qual[t_output->cnt].suspected_ind = 1
				set t_rec->patient_qual[i].suspected_onset_dt_tm = t_rec->patient_qual[i].diagnosis_qual[j].daig_dt_tm ;;THIS MAY
				;NEED TO BE REVISITED WHICH TIME TAKES PECIDENT
			else
				set t_output->qual[t_output->cnt].positive_ind = 0
				;set t_rec->patient_qual[i].positive_onset_dt_tm = t_rec->patient_qual[i].diagnosis_qual[j].daig_dt_tm
			endif
		endfor
	endif
 
	;PSO Column
	if (t_rec->patient_qual[i].orders_cnt > 0)
		set stat = 0
		for (j=1 to t_rec->patient_qual[i].orders_cnt)
			if (stat = 0)
				for (k=1 to t_rec->pso.ip_pso_cnt)
					if (stat = 0)
						if (t_rec->pso.ip_pso_qual[k].catalog_cd = t_rec->patient_qual[i].orders_qual[j].catalog_cd)
							set t_output->qual[t_output->cnt].pso = concat(trim(t_rec->patient_qual[i].orders_qual[j].order_mnemonic))
							set stat = 1
						endif
					endif
				endfor
			endif
		endfor
		for (j=1 to t_rec->patient_qual[i].orders_cnt)
			if (stat = 0)
				for (k=1 to t_rec->pso.ob_pso_cnt)
					if (stat = 0)
						if (t_rec->pso.ob_pso_qual[k].catalog_cd = t_rec->patient_qual[i].orders_qual[j].catalog_cd)
							set t_output->qual[t_output->cnt].pso = concat(trim(t_rec->patient_qual[i].orders_qual[j].order_mnemonic))
							set stat = 1
						endif
					endif
				endfor
			endif
		endfor
	endif
 
	;COVID-19 Order Column
	if (t_rec->patient_qual[i].orders_cnt > 0)
		set stat = 0
		set ignore = 0
		for (j=1 to t_rec->patient_qual[i].orders_cnt)
			for (k=1 to t_rec->covid19.covid_oc_cnt)
				if (stat = 0)
					if (t_rec->covid19.covid_oc_qual[k].catalog_cd = t_rec->patient_qual[i].orders_qual[j].catalog_cd)
					 set ignore = 0
					 if (t_rec->covid19.covid_ignore_cnt > 0)
					 	for (pos=1 to t_rec->covid19.covid_ignore_cnt)
					 	 for (ii=1 to t_rec->patient_qual[i].orders_qual[j].order_detail_cnt)
					 	  if (t_rec->patient_qual[i].orders_qual[j].order_detal_qual[ii].oe_field_id =
					 	  	  t_rec->covid19.covid_ignore_qual[pos].oe_field_id)
					 	  	 if (t_rec->patient_qual[i].orders_qual[j].order_detal_qual[ii].oe_field_value =
					 	  	     t_rec->covid19.covid_ignore_qual[pos].oe_field_value)
					 	  	   set ignore = 1
					 	  	   set t_rec->patient_qual[i].orders_qual[j].order_ignore = 1
					 	  	 endif
					 	  endif
					 	 endfor
					 	endfor
					 endif
						if (ignore = 0)
							set t_output->qual[t_output->cnt].covid19_order = concat(trim(t_rec->patient_qual[i].orders_qual[j].order_status_display))
							set t_output->qual[t_output->cnt].covid19_order_dt_tm =
								;switching to orig_order_dt_tm format(t_rec->patient_qual[i].orders_qual[j].order_status_dt_tm,";;q")
								format(t_rec->patient_qual[i].orders_qual[j].orig_order_dt_tm,";;q")
							set stat = 1
							if (
									(t_rec->patient_qual[i].orders_qual[j].order_status_display in("Ordered")
										and (t_rec->patient_qual[i].historic_ind = 0))
								or
									(t_rec->patient_qual[i].historic_ind = 1)
								)
 
								set t_output->qual[t_output->cnt].suspected_ind = 1
								set t_output->qual[t_output->cnt].pending_test_ind = 1
								;THIS NEEDS REVISITED for checking if the patient was in the ED when the test was ordered.
								if (t_rec->patient_qual[i].orders_qual[j].orig_order_dt_tm > t_rec->patient_qual[i].suspected_onset_dt_tm)
									set t_rec->patient_qual[i].suspected_onset_dt_tm = t_rec->patient_qual[i].orders_qual[j].orig_order_dt_tm
								endif
							endif
						endif
					set ignore = 0
					endif
				endif
			endfor
		endfor
	endif
 
	;COVID-19 Isolation Column
	if (t_rec->patient_qual[i].orders_cnt > 0)
		set stat = 0
		set ignore = 0
		for (j=1 to t_rec->patient_qual[i].orders_cnt)
			for (k=1 to t_rec->covid19.iso_oc_cnt)
				if (stat = 0)
					if (t_rec->covid19.iso_oc_qual[k].catalog_cd = t_rec->patient_qual[i].orders_qual[j].catalog_cd)
					 set t_rec->patient_qual[i].orders_qual[j].order_ignore = 1
					 set ignore = 1
					 if (t_rec->covid19.iso_include_cnt > 0)
					 	for (pos=1 to t_rec->covid19.iso_include_cnt)
					 	 for (ii=1 to t_rec->patient_qual[i].orders_qual[j].order_detail_cnt)
					 	  if (t_rec->patient_qual[i].orders_qual[j].order_detal_qual[ii].oe_field_id =
					 	  	  t_rec->covid19.iso_include_qual[pos].oe_field_id)
					 	  	 if (t_rec->patient_qual[i].orders_qual[j].order_detal_qual[ii].oe_field_value =
					 	  	     t_rec->covid19.iso_include_qual[pos].oe_field_value)
					 	  	   set ignore = 0
					 	  	   set t_rec->patient_qual[i].orders_qual[j].order_ignore = 0
					 	  	 endif
					 	  endif
					 	 endfor
					 	endfor
					 endif
						if (ignore = 0)
							set t_output->qual[t_output->cnt].isolation_order = concat(trim(t_rec->patient_qual[i].orders_qual[j].order_status_display))
							set t_output->qual[t_output->cnt].isolation_order_dt_tm =
								;switching to orig_order_dt_tm format(t_rec->patient_qual[i].orders_qual[j].order_status_dt_tm,";;q")
								format(t_rec->patient_qual[i].orders_qual[j].orig_order_dt_tm,";;q")
							set stat = 1
						endif
					set ignore = 1
					endif
				endif
			endfor
		endfor
	endif
 
	;Location History
	if (t_rec->patient_qual[i].encntr_loc_cnt > 0)
		for (j=1 to t_rec->patient_qual[i].encntr_loc_cnt)
			if (j=1)
				set t_output->qual[t_output->cnt].location_history =
					trim(replace(t_rec->patient_qual[i].encntr_loc_qual[j].unit,t_output->qual[t_output->cnt].facility,""),3)
			else
				set t_output->qual[t_output->cnt].location_history = concat(
						 t_output->qual[t_output->cnt].location_history
						,";"
						,trim(replace(t_rec->patient_qual[i].encntr_loc_qual[j].unit,t_output->qual[t_output->cnt].facility,""),3)
						 )
			endif
		endfor
	endif
 
 
	;COVID-19 Result Column
	if (t_rec->patient_qual[i].lab_results_cnt > 0)
		set stat = 0
				for (j=1 to t_rec->covid19.positive_cnt)
			if (t_rec->patient_qual[i].lab_results_qual[1].result_val = t_rec->covid19.positive_qual[j].result_val)
				set stat = 1
				set t_output->qual[t_output->cnt].covid19_result 		= concat("Positive")
				set t_output->qual[t_output->cnt].covid19_result_dt_tm 	=
						;changing to clinsig_updt_dt_tm
						trim(format(t_rec->patient_qual[i].lab_results_qual[1].event_end_dt_tm,";;q"))
						;trim(format(t_rec->patient_qual[i].lab_results_qual[1].clinsig_updt_dt_tm,";;q"))
				set t_output->qual[t_output->cnt].positive_ind = 1
				set t_rec->patient_qual[i].positive_onset_dt_tm = t_rec->patient_qual[i].lab_results_qual[1].event_end_dt_tm
				/* 006if (t_rec->patient_qual[i].lab_results_qual[1].event_end_dt_tm
					>= cnvtlookahead("14,D",t_rec->patient_qual[i].inpatient_dt_tm))
					if (t_rec->patient_qual[i].lab_results_cnt = 1) ;only eval the most recent positive result
						set t_output->qual[t_output->cnt].hosp_conf_onset = 1
					endif
				endif
				006 */
			endif
		endfor
		if (stat = 0)
			if (t_rec->patient_qual[i].lab_results_cnt = 1)
				set t_output->qual[t_output->cnt].covid19_result = concat(	 t_rec->patient_qual[i].lab_results_qual[1].result_val)
				set t_output->qual[t_output->cnt].covid19_result_dt_tm	=
					;changing to clinsig_updt_dt_tm trim(format(t_rec->patient_qual[i].lab_results_qual[1].event_end_dt_tm,";;q"))
					trim(format(t_rec->patient_qual[i].lab_results_qual[1].clinsig_updt_dt_tm,";;q"))
			else
				set pos = 1
				while (pos <= t_rec->patient_qual[i].lab_results_cnt)
					if (stat = 0)
						if (t_rec->patient_qual[i].lab_results_qual[pos].result_val not in("DUPLICATE","RE-ORDERED","SEE BELOW"))
							set stat = 1
							set t_output->qual[t_output->cnt].covid19_result = concat(t_rec->patient_qual[i].lab_results_qual[pos].result_val)
							set t_output->qual[t_output->cnt].covid19_result_dt_tm =
								;changing to clinsig_updt_dt_tm trim(format(t_rec->patient_qual[i].lab_results_qual[pos].event_end_dt_tm,";;q"))
								trim(format(t_rec->patient_qual[i].lab_results_qual[1].clinsig_updt_dt_tm,";;q"))
						endif
					endif
					set pos = (pos + 1)
				endwhile
			endif
		endif
	endif
 
	;COVID-19 Suspected Date and Time
	if (t_output->qual[t_output->cnt].suspected_ind = 1)
		if (t_rec->patient_qual[i].encntr_loc_cnt > 0)
			for (j=1 to t_rec->patient_qual[i].encntr_loc_cnt)
				if (t_rec->patient_qual[i].suspected_onset_dt_tm between
								t_rec->patient_qual[i].encntr_loc_qual[j].beg_dt_tm
							and t_rec->patient_qual[i].encntr_loc_qual[j].end_dt_tm)
					if (trim(replace(t_rec->patient_qual[i].encntr_loc_qual[j].unit,t_output->qual[t_output->cnt].facility,""),3)
						 in("ED","EB"))
						set t_output->qual[t_output->cnt].ed_admit_suspected_ind = 1
						if (t_output->qual[t_output->cnt].positive_ind = 1)
							set t_output->qual[t_output->cnt].ed_admit_confirmed_ind = 1
						endif
					endif
				endif
			endfor
		endif
	endif
	;Ventilator Column - Current Patients
	select into "nl:"
		 encntr_id		 = t_rec->patient_qual[d1.seq].encntr_id
		,event_end_dt_tm = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm
	from
		 (dummyt d1 with seq=t_rec->patient_cnt)
		,(dummyt d2)
	plan d1
		where t_rec->patient_qual[d1.seq].encntr_id = t_rec->patient_qual[i].encntr_id
		and   (t_rec->patient_qual[d1.seq].historic_ind = 0 or t_rec->patient_qual[d1.seq].expired_ind = 0)
		and   maxrec(d2,t_rec->patient_qual[d1.seq].vent_results_cnt)
	join d2
	order by
		 encntr_id
		,event_end_dt_tm desc
	head encntr_id
		stat = 0
	head event_end_dt_tm
	 if (stat = 0)
		if (cnvtupper(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].result_val) in("*DISCONTINUE*"))
			stat = 1
		else
			for (j=1 to t_rec->vent.result_cnt)
				if (t_rec->vent.result_qual[j].lookback_hrs > 0)
					if ((t_rec->vent.result_qual[j].event_cd = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_cd) and
						(datetimediff(cnvtdatetime(curdate,curtime3),t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm,3)
																				<= t_rec->vent.result_qual[j].lookback_hrs))
						t_output->qual[t_output->cnt].ventilator = concat(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].result_val)
						t_output->qual[t_output->cnt].ventilator_dt_tm =
							trim(format(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm,";;q"))
						t_output->qual[t_output->cnt].ventilator_type = uar_get_code_display(t_rec->patient_qual[d1.seq].
							vent_results_qual[d2.seq].event_cd)
						t_output->qual[t_output->cnt].ventilator_model = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_result_val
						stat = 1
						if (t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].ventilator_type = "I")
							t_output->qual[t_output->cnt].ventilator_ind = 1
						elseif (t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].ventilator_type = "N")
							t_output->qual[t_output->cnt].ventilator_ind = 2
						endif
						t_output->qual[t_output->cnt].covenant_vent_stock_ind
							= t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].covenant_stock_ind
					endif
				elseif (t_rec->vent.result_qual[j].event_cd = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_cd)
					t_output->qual[t_output->cnt].ventilator = concat(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].result_val)
					t_output->qual[t_output->cnt].ventilator_dt_tm =
						trim(format(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm,";;q"))
					t_output->qual[t_output->cnt].ventilator_type = uar_get_code_display(t_rec->patient_qual[d1.seq].
						vent_results_qual[d2.seq].event_cd)
					t_output->qual[t_output->cnt].ventilator_model = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_result_val
					stat = 1
					t_output->qual[t_output->cnt].ventilator_ind = 1
					t_output->qual[t_output->cnt].covenant_vent_stock_ind
						= t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].covenant_stock_ind
				endif
			endfor
		endif
	 endif
	with nocounter
 
	;Ventilator Column - Historical and Expired Patients
	select into "nl:"
		 encntr_id		 = t_rec->patient_qual[d1.seq].encntr_id
		,event_end_dt_tm = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm
	from
		 (dummyt d1 with seq=t_rec->patient_cnt)
		,(dummyt d2)
	plan d1
		where t_rec->patient_qual[d1.seq].encntr_id = t_rec->patient_qual[i].encntr_id
		and   (t_rec->patient_qual[d1.seq].historic_ind = 1 or t_rec->patient_qual[d1.seq].expired_ind = 1)
		and   maxrec(d2,t_rec->patient_qual[d1.seq].vent_results_cnt)
	join d2
	order by
		 encntr_id
		,event_end_dt_tm desc
	head encntr_id
		stat = 0
	head event_end_dt_tm
	 if (stat = 0)
		if (cnvtupper(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].result_val) in("*DISCONTINUE*"))
			stat = 0
		else
			for (j=1 to t_rec->vent.result_cnt)
				/*
				if (t_rec->vent.result_qual[j].lookback_hrs > 0)
					if ((t_rec->vent.result_qual[j].event_cd = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_cd) and
						(datetimediff(cnvtdatetime(curdate,curtime3),t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm,3)
																				<= t_rec->vent.result_qual[j].lookback_hrs))
						t_output->qual[t_output->cnt].ventilator = concat(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].result_val)
						t_output->qual[t_output->cnt].ventilator_dt_tm =
							trim(format(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm,";;q"))
						t_output->qual[t_output->cnt].ventilator_type = uar_get_code_display(t_rec->patient_qual[d1.seq].
							vent_results_qual[d2.seq].event_cd)
						t_output->qual[t_output->cnt].ventilator_model = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_result_val
						stat = 1
						if (t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].ventilator_type = "I")
							t_output->qual[t_output->cnt].ventilator_ind = 1
						elseif (t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].ventilator_type = "N")
							t_output->qual[t_output->cnt].ventilator_ind = 2
						endif
						t_output->qual[t_output->cnt].covenant_vent_stock_ind
							= t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].covenant_stock_ind
					endif
				elseif (t_rec->vent.result_qual[j].event_cd = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_cd)
				*/
				if (t_rec->vent.result_qual[j].event_cd = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_cd)
					t_output->qual[t_output->cnt].ventilator = concat(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].result_val)
					t_output->qual[t_output->cnt].ventilator_dt_tm =
						trim(format(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm,";;q"))
					t_output->qual[t_output->cnt].ventilator_type = uar_get_code_display(t_rec->patient_qual[d1.seq].
						vent_results_qual[d2.seq].event_cd)
					t_output->qual[t_output->cnt].ventilator_model = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_result_val
					stat = 1
					t_output->qual[t_output->cnt].ventilator_ind = 1
					t_output->qual[t_output->cnt].covenant_vent_stock_ind
						= t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].covenant_stock_ind
				endif
			endfor
		endif
	 endif
	with nocounter
 
	;Location Class 1
	set t_output->qual[t_output->cnt].location_class_1 = t_rec->patient_qual[i].loc_class_1
 
	;Expired Column
	set t_output->qual[t_output->cnt].expired_ind = t_rec->patient_qual[i].expired_ind
	set t_output->qual[t_output->cnt].expired_dt_tm = trim(format(t_rec->patient_qual[i].expired_dt_tm,";;q"))
 
	;Previous Admission Column
	if (
			(cnvtdatetime(t_rec->patient_qual[i].observation_dt_tm)
				between cnvtdatetime(t_rec->covid19.admission_start_dt_tm) and cnvtdatetime(t_rec->covid19.admission_end_dt_tm))
		or
			(cnvtdatetime(t_rec->patient_qual[i].inpatient_dt_tm)
				between cnvtdatetime(t_rec->covid19.admission_start_dt_tm) and cnvtdatetime(t_rec->covid19.admission_end_dt_tm))
		)
		set t_rec->patient_qual[i].previous_admission_ind = 1
		set t_output->qual[t_output->cnt].previous_admission_ind = t_rec->patient_qual[i].previous_admission_ind
	endif
 
	;Previous Onset Column
	if (t_output->qual[t_output->cnt].suspected_ind = 1)
		set t_output->qual[t_output->cnt].suspected_onset_dt_tm = format(t_rec->patient_qual[i].suspected_onset_dt_tm,";;q")
 
		if (cnvtdatetime(t_rec->patient_qual[i].suspected_onset_dt_tm) between	cnvtdatetime(t_rec->covid19.onset_start_dt_tm)
		 																	and		cnvtdatetime(t_rec->covid19.onset_end_dt_tm))
 
			set t_rec->patient_qual[i].previous_onset_ind = 1
			set t_output->qual[t_output->cnt].previous_onset_ind = t_rec->patient_qual[i].previous_onset_ind
		endif
	endif
 
	if (t_output->qual[t_output->cnt].positive_ind = 1)
		set t_output->qual[t_output->cnt].positive_onset_dt_tm = format(t_rec->patient_qual[i].positive_onset_dt_tm,";;q")
 
		if	(cnvtdatetime(t_rec->patient_qual[i].positive_onset_dt_tm) between	cnvtdatetime(t_rec->covid19.onset_start_dt_tm)
																					and		cnvtdatetime(t_rec->covid19.onset_end_dt_tm))
			set t_rec->patient_qual[i].previous_onset_ind = 1
			set t_rec->patient_qual[i].previous_onset_conf_ind = 1
			set t_output->qual[t_output->cnt].previous_onset_ind = t_rec->patient_qual[i].previous_onset_ind
			set t_output->qual[t_output->cnt].previous_onset_conf_ind = t_rec->patient_qual[i].previous_onset_conf_ind
		endif
	endif
 
	;006 Hospital Onset
	if (t_rec->patient_qual[i].positive_onset_dt_tm >= cnvtlookahead("14,D",t_rec->patient_qual[i].inpatient_dt_tm))
		if ((t_rec->patient_qual[i].inpatient_dt_tm > 0.0) and (t_rec->patient_qual[i].positive_onset_dt_tm > 0.0))
			set t_output->qual[t_output->cnt].hosp_conf_onset = 1
		endif
	endif
	;006 end
 
	;Historical Column
	set t_output->qual[t_output->cnt].historical_ind = t_rec->patient_qual[i].historic_ind
 
 
	/*
	;Ventilator Column
	if (t_rec->patient_qual[i].vent_results_cnt > 0)
		set pos = 1
		set stat = 0
	  for (pos=1 to t_rec->patient_qual[i].vent_results_cnt)
		for (j=1 to t_rec->vent.result_cnt)
			if (cnvtupper(t_rec->patient_qual[i].vent_results_qual[pos].result_val) not in("*DISCONTINUE*"))
				if (t_rec->vent.result_qual[j].lookback_hrs > 0)
					if ((t_rec->vent.result_qual[j].event_cd = t_rec->patient_qual[i].vent_results_qual[pos].event_cd) and
						(datetimediff(cnvtdatetime(curdate,curtime3),t_rec->patient_qual[i].vent_results_qual[pos].event_end_dt_tm,3)
																				<= t_rec->vent.result_qual[j].lookback_hrs))
						set t_output->qual[t_output->cnt].ventilator = concat(t_rec->patient_qual[i].vent_results_qual[pos].result_val)
						set t_output->qual[t_output->cnt].ventilator_dt_tm =
							trim(format(t_rec->patient_qual[i].vent_results_qual[pos].event_end_dt_tm,";;q"))
						set t_output->qual[t_output->cnt].ventilator_type = uar_get_code_display(t_rec->patient_qual[i].
							vent_results_qual[pos].event_cd)
					endif
				elseif (t_rec->vent.result_qual[j].event_cd = t_rec->patient_qual[i].vent_results_qual[pos].event_cd)
					set t_output->qual[t_output->cnt].ventilator = concat(t_rec->patient_qual[i].vent_results_qual[pos].result_val)
					set t_output->qual[t_output->cnt].ventilator_dt_tm =
						trim(format(t_rec->patient_qual[i].vent_results_qual[pos].event_end_dt_tm,";;q"))
					set t_output->qual[t_output->cnt].ventilator_type = uar_get_code_display(t_rec->patient_qual[i].
						vent_results_qual[pos].event_cd)
				endif
			endif
		endfor
	  endfor
	endif
	*/
/*
	 x person_id				= f8
	 x encntr_id				= f8
	 x facility					= vc
	 x patient_name				= vc
	 x fin						= vc
	 x dob						= vc
	 x unit						= vc
	 x room_bed					= vc
	 x pso						= vc
	 x los						= i2
	 x diagnosis				= vc
	 2 covid19_order			= vc
	 2 covid19_result			= vc
	 2 ventilator				= vc
*/
endfor
 
call writeLog(build2("* END   Building Output ************************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building Output2 (t2_output) ***********************"))
 
for (i=1 to t_rec->patient_cnt)
	set t2_output->cnt = (t2_output->cnt + 1)
	set stat = alterlist(t2_output->qual,t2_output->cnt)
 
	set t2_output->qual[t2_output->cnt].person_id				= t_rec->patient_qual[i].person_id
	set t2_output->qual[t2_output->cnt].encntr_id				= t_rec->patient_qual[i].encntr_id
	set t2_output->qual[t2_output->cnt].facility				= trim(uar_get_code_display(t_rec->patient_qual[i].loc_facility_cd))
	set t2_output->qual[t2_output->cnt].encntr_type				= trim(uar_get_code_display(t_rec->patient_qual[i].encntr_type_cd))
	set t2_output->qual[t2_output->cnt].patient_name			= trim(t_rec->patient_qual[i].name_full_formatted)
	set t2_output->qual[t2_output->cnt].fin						= trim(t_rec->patient_qual[i].fin)
	set t2_output->qual[t2_output->cnt].dob						= trim(format(t_rec->patient_qual[i].dob,";;d"))
	set t2_output->qual[t2_output->cnt].date_of_birth			= t_rec->patient_qual[i].dob
	set t2_output->qual[t2_output->cnt].age						= trim(cnvtage(t_rec->patient_qual[i].dob))
	set t2_output->qual[t2_output->cnt].unit					= trim(uar_get_code_display(t_rec->patient_qual[i].loc_unit_cd))
 
	if ((t_rec->patient_qual[i].loc_room_cd = 0.0) and (t_rec->patient_qual[i].loc_bed_cd > 0.0))
		set t2_output->qual[t2_output->cnt].room_bed				= trim(concat(
																			trim(uar_get_code_display(t_rec->patient_qual[i].loc_bed_cd),3)
																			),3)
	elseif ((t_rec->patient_qual[i].loc_room_cd > 0.0) and (t_rec->patient_qual[i].loc_bed_cd = 0.0))
		set t2_output->qual[t2_output->cnt].room_bed				= trim(concat(
																			trim(uar_get_code_display(t_rec->patient_qual[i].loc_room_cd),3)
																			),3)
	elseif ((t_rec->patient_qual[i].loc_room_cd > 0.0) and (t_rec->patient_qual[i].loc_bed_cd > 0.0))
		set t2_output->qual[t2_output->cnt].room_bed				= trim(concat(
																			trim(uar_get_code_display(t_rec->patient_qual[i].loc_room_cd),3)
																			,"-"
																		    ,trim(uar_get_code_display(t_rec->patient_qual[i].loc_bed_cd),3)
																			),3)
	endif
 
	set t2_output->qual[t2_output->cnt].los_days				= t_rec->patient_qual[i].ip_los_days
	set t2_output->qual[t2_output->cnt].los_hours				= t_rec->patient_qual[i].ip_los_hours
	set t2_output->qual[t2_output->cnt].inpatient_dt_tm			= format(t_rec->patient_qual[i].inpatient_dt_tm,"mm-dd-yy hh:mm;;d")
	set t2_output->qual[t2_output->cnt].inpatient_dt_tm_dq8		= t_rec->patient_qual[i].inpatient_dt_tm
	set t2_output->qual[t2_output->cnt].observation_dt_tm		= format(t_rec->patient_qual[i].observation_dt_tm,"mm-dd-yy hh:mm;;d")
	set t2_output->qual[t2_output->cnt].reg_dt_tm				= format(t_rec->patient_qual[i].reg_dt_tm,"mm-dd-yy hh:mm;;d")
	set t2_output->qual[t2_output->cnt].arrive_dt_tm			= format(t_rec->patient_qual[i].arrive_dt_tm,"mm-dd-yy hh:mm;;d")
	set t2_output->qual[t2_output->cnt].disch_dt_tm				= format(t_rec->patient_qual[i].disch_dt_tm,"mm-dd-yy hh:mm;;d")
	set t2_output->qual[t2_output->cnt].patient_phone_num		= t_rec->patient_qual[i].patient_phone_num
	set t2_output->qual[t2_output->cnt].patient_address_county	= t_rec->patient_qual[i].patient_address_county
	set t2_output->qual[t2_output->cnt].patient_gender			= t_rec->patient_qual[i].patient_gender
	set t2_output->qual[t2_output->cnt].patient_race			= t_rec->patient_qual[i].patient_race
	set t2_output->qual[t2_output->cnt].patient_ethnicity		= t_rec->patient_qual[i].patient_ethnicity
	set t2_output->qual[t2_output->cnt].accommodation			= t_rec->patient_qual[i].accommodation	;010
 
	;Reset columns
	set t_rec->patient_qual[i].suspected_onset_dt_tm = 0.0
	set t_rec->patient_qual[i].positive_onset_dt_tm = 0.0
	;Diagnosis Column
	if (t_rec->patient_qual[i].diagnosis_cnt > 0)
		for (j=1 to t_rec->patient_qual[i].diagnosis_cnt)
			if (j>1)
				set t2_output->qual[t2_output->cnt].diagnosis = concat(	 t2_output->qual[t2_output->cnt].diagnosis,";"
																		,trim(t_rec->patient_qual[i].diagnosis_qual[j].source_string))
				set t2_output->qual[t2_output->cnt].diagnosis_display = concat(	 t2_output->qual[t2_output->cnt].diagnosis_display,";"
																		,trim(t_rec->patient_qual[i].diagnosis_qual[j].diagnosis_display))
			else
				set t2_output->qual[t2_output->cnt].diagnosis = trim(t_rec->patient_qual[i].diagnosis_qual[j].source_string)
				set t2_output->qual[t2_output->cnt].diagnosis_display = trim(t_rec->patient_qual[i].diagnosis_qual[j].diagnosis_display)
			endif
			if ((t_rec->patient_qual[i].diagnosis_qual[j].source_string in(
																				 "SARS-associated coronavirus exposure"
																				,"Exposure to SARS-associated coronavirus"
																				,"Exposure*"
																				,"*exposure*"
																				,"Suspected*"
																				,"*Person under investigation*"
																				,"Person under investigation*"
																			  ))
			   or (t_rec->patient_qual[i].diagnosis_qual[j].diagnosis_display in(
																				 "SARS-associated coronavirus exposure"
																				,"Exposure to SARS-associated coronavirus"
																				,"Exposure*"
																				,"*exposure*"
																				,"Suspected*"
																				,"*Person under investigation*"
																				,"Person under investigation*"
																			  ))
				)
				set t2_output->qual[t2_output->cnt].suspected_ind = 1
				set t2_output->qual[t2_output->cnt].diagnosis_suspected_dttm = t_rec->patient_qual[i].diagnosis_qual[j].daig_dt_tm
				set t2_output->qual[t2_output->cnt].diagnosis_suspected_dt =
											format(t2_output->qual[t2_output->cnt].diagnosis_suspected_dttm,"mm-dd-yy hh:mm;;d")
				set t_rec->patient_qual[i].suspected_onset_dt_tm = t_rec->patient_qual[i].diagnosis_qual[j].daig_dt_tm ;;REVISIT
				;THIS NEED TO BE REVISITED WHICH TIME TAKES PECIDENT
			else
				set t2_output->qual[t2_output->cnt].positive_ind = 0
				;set t2_output->qual[t2_output->cnt].diagnosis_confirmed_dttm = t_rec->patient_qual[i].diagnosis_qual[j].daig_dt_tm
				;set t2_output->qual[t2_output->cnt].diagnosis_confirmed_dt =
				;							format(t2_output->qual[t2_output->cnt].diagnosis_confirmed_dttm,"mm-dd-yy hh:mm;;d")
				;set t_rec->patient_qual[i].positive_onset_dt_tm = t_rec->patient_qual[i].diagnosis_qual[j].daig_dt_tm ;;REVISIT
			endif
		endfor
	endif
 
	;PSO Column
	if (t_rec->patient_qual[i].orders_cnt > 0)
		set stat = 0
		for (j=1 to t_rec->patient_qual[i].orders_cnt)
			if (stat = 0)
				for (k=1 to t_rec->pso.ip_pso_cnt)
					if (stat = 0)
						if (t_rec->pso.ip_pso_qual[k].catalog_cd = t_rec->patient_qual[i].orders_qual[j].catalog_cd)
							set t2_output->qual[t2_output->cnt].pso = concat(trim(t_rec->patient_qual[i].orders_qual[j].order_mnemonic))
							set stat = 1
						endif
					endif
				endfor
			endif
		endfor
		for (j=1 to t_rec->patient_qual[i].orders_cnt)
			if (stat = 0)
				for (k=1 to t_rec->pso.ob_pso_cnt)
					if (stat = 0)
						if (t_rec->pso.ob_pso_qual[k].catalog_cd = t_rec->patient_qual[i].orders_qual[j].catalog_cd)
							set t2_output->qual[t2_output->cnt].pso = concat(trim(t_rec->patient_qual[i].orders_qual[j].order_mnemonic))
							set stat = 1
						endif
					endif
				endfor
			endif
		endfor
	endif
 
	;COVID-19 Order Column
	if (t_rec->patient_qual[i].orders_cnt > 0)
		set stat = 0
		set ignore = 0
		for (j=1 to t_rec->patient_qual[i].orders_cnt)
			for (k=1 to t_rec->covid19.covid_oc_cnt)
				if (stat = 0)
					if (t_rec->covid19.covid_oc_qual[k].catalog_cd = t_rec->patient_qual[i].orders_qual[j].catalog_cd)
					 set ignore = 0
					 if (t_rec->covid19.covid_ignore_cnt > 0)
					 	for (pos=1 to t_rec->covid19.covid_ignore_cnt)
					 	 for (ii=1 to t_rec->patient_qual[i].orders_qual[j].order_detail_cnt)
					 	  if (t_rec->patient_qual[i].orders_qual[j].order_detal_qual[ii].oe_field_id =
					 	  	  t_rec->covid19.covid_ignore_qual[pos].oe_field_id)
					 	  	 if (t_rec->patient_qual[i].orders_qual[j].order_detal_qual[ii].oe_field_value =
					 	  	     t_rec->covid19.covid_ignore_qual[pos].oe_field_value)
					 	  	   set ignore = 1
					 	  	   set t_rec->patient_qual[i].orders_qual[j].order_ignore = 1
					 	  	 endif
					 	  endif
					 	 endfor
					 	endfor
					 endif
						if (ignore = 0)
						 if (t2_output->qual[t2_output->cnt].covid19_order > " ")
						 	set t2_output->qual[t2_output->cnt].covid19_order = concat(t2_output->qual[t2_output->cnt].covid19_order,";")
						 endif
							set t2_output->qual[t2_output->cnt].covid19_order = concat(
												trim(t2_output->qual[t2_output->cnt].covid19_order),
											    trim(t_rec->patient_qual[i].orders_qual[j].order_status_display),
									^ (^
									,trim(t_rec->patient_qual[i].orders_qual[j].order_mnemonic)
									,^ [^,trim(format(t_rec->patient_qual[i].orders_qual[j].orig_order_dt_tm,"mm-dd-yy hh:mm;;d"))
									,^]) ^
											)
							;USING THE FIRST (most recent) ORDER IN LIST AS THE ORDER_DT_TM COLUMN
							if (t2_output->qual[t2_output->cnt].covid19_order_dt_tm = " ")
								set t2_output->qual[t2_output->cnt].covid19_order_dt_tm =
										format(t_rec->patient_qual[i].orders_qual[j].orig_order_dt_tm,"mm-dd-yy hh:mm;;d")
							endif
 
							set stat = 0; SET TO 1 TO  ONLY ALLOW ONE ORDER TO QUALIFY (sorted to be most recent first)
							if (
									(t_rec->patient_qual[i].orders_qual[j].order_status_display in("Ordered")
										and (t_rec->patient_qual[i].historic_ind = 0))
								or
									(t_rec->patient_qual[i].historic_ind = 1)
								)
								set t2_output->qual[t2_output->cnt].suspected_ind = 1
								set t2_output->qual[t2_output->cnt].pending_test_ind = 1
								;THIS NEEDS REVISITED for checking if the patient was in the ED when the test was ordered.
								if (t_rec->patient_qual[i].orders_qual[j].orig_order_dt_tm > t_rec->patient_qual[i].suspected_onset_dt_tm)
									set t_rec->patient_qual[i].suspected_onset_dt_tm = t_rec->patient_qual[i].orders_qual[j].orig_order_dt_tm
								endif
							endif
						endif
					set ignore = 0
					endif
				endif
			endfor
		endfor
	endif
 
	;Isolation Order
		if (t_rec->patient_qual[i].orders_cnt > 0)
		set stat = 0
		set ignore = 0
		for (j=1 to t_rec->patient_qual[i].orders_cnt)
			for (k=1 to t_rec->covid19.iso_oc_cnt)
				if (stat = 0)
					if (t_rec->covid19.iso_oc_qual[k].catalog_cd = t_rec->patient_qual[i].orders_qual[j].catalog_cd)
					 set t_rec->patient_qual[i].orders_qual[j].order_ignore = 1
					 set ignore = 1
					 if (t_rec->covid19.iso_include_cnt > 0)
					 	for (pos=1 to t_rec->covid19.iso_include_cnt)
					 	 for (ii=1 to t_rec->patient_qual[i].orders_qual[j].order_detail_cnt)
					 	  if (t_rec->patient_qual[i].orders_qual[j].order_detal_qual[ii].oe_field_id =
					 	  	  t_rec->covid19.iso_include_qual[pos].oe_field_id)
					 	  	 if (t_rec->patient_qual[i].orders_qual[j].order_detal_qual[ii].oe_field_value =
					 	  	     t_rec->covid19.iso_include_qual[pos].oe_field_value)
					 	  	   set ignore = 0
					 	  	   set t_rec->patient_qual[i].orders_qual[j].order_ignore = 0
					 	  	 endif
					 	  endif
					 	 endfor
					 	endfor
					 endif
					   if (ignore = 0)
						set t2_output->qual[t2_output->cnt].isolation_order = concat(trim(t_rec->patient_qual[i].orders_qual[j].order_status_display))
						set t2_output->qual[t2_output->cnt].isolation_order_dt_tm =
								;switching to orig_order_dt_tm format(t_rec->patient_qual[i].orders_qual[j].order_status_dt_tm,";;q")
								format(t_rec->patient_qual[i].orders_qual[j].orig_order_dt_tm,";;q")
						set t2_output->qual[t2_output->cnt].isolation_days = cnvtstring(
																						datetimediff(
																										 cnvtdatetime(curdate,curtime3)
																										,t_rec->patient_qual[i].orders_qual[j].orig_order_dt_tm
																										,1
																									))
						set stat = 1
					   endif
					set ignore = 1
					endif
				endif
			endfor
		endfor
	endif
 
	;Location History
	if (t_rec->patient_qual[i].encntr_loc_cnt > 0)
		for (j=1 to t_rec->patient_qual[i].encntr_loc_cnt)
			if (j=1)
				set t2_output->qual[t2_output->cnt].location_history =
					trim(replace(t_rec->patient_qual[i].encntr_loc_qual[j].unit,t2_output->qual[t2_output->cnt].facility,""),3)
			else
				set t2_output->qual[t2_output->cnt].location_history = concat(
						 t2_output->qual[t2_output->cnt].location_history
						,";"
						,trim(replace(t_rec->patient_qual[i].encntr_loc_qual[j].unit,t2_output->qual[t2_output->cnt].facility,""),3)
						 )
			endif
		endfor
	endif
 
 
	;COVID-19 Result Column
	if (t_rec->patient_qual[i].lab_results_cnt > 0)
		set stat = 0
		;;CHECKING MOST RECENT RESULT FOR POSITIVE
		for (j=1 to t_rec->covid19.positive_cnt)
			if (t_rec->patient_qual[i].lab_results_qual[1].result_val = t_rec->covid19.positive_qual[j].result_val)
				set stat = 1
				set t2_output->qual[t2_output->cnt].covid19_result 		= concat("Positive")
				set t2_output->qual[t2_output->cnt].covid19_result_dt_tm 	=
						;changing to clinsig_updt_dt_tm trim(format(t_rec->patient_qual[i].lab_results_qual[1].event_end_dt_tm,";;q"))
						trim(format(t_rec->patient_qual[i].lab_results_qual[1].event_end_dt_tm,"mm-dd-yy hh:mm;;d"))
				set t2_output->qual[t2_output->cnt].positive_ind = 1
 
				if ((t_rec->patient_qual[i].positive_onset_dt_tm = 0.0) or
							(t_rec->patient_qual[i].lab_results_qual[1].event_end_dt_tm < t_rec->patient_qual[i].positive_onset_dt_tm))
					set t_rec->patient_qual[i].positive_onset_dt_tm = t_rec->patient_qual[i].lab_results_qual[1].event_end_dt_tm
				endif
			endif
		endfor
		;;CHECKING FOR FIRST POSITIVE
		for (k=1 to t_rec->patient_qual[i].lab_results_cnt)
		 call writeLog(build2("-->checking CHECKING FOR FIRST POSITIVE encntr_id=",trim(cnvtstring(t_rec->patient_qual[i].encntr_id))))
		 call writeLog(build2("-->checking CHECKING FOR FIRST POSITIVE event_id="
					,trim(cnvtstring(t_rec->patient_qual[i].lab_results_qual[k].event_id))))
		 for (j=1 to t_rec->covid19.positive_cnt)
			if (t_rec->patient_qual[i].lab_results_qual[k].result_val = t_rec->covid19.positive_qual[j].result_val)
				;set t2_output->qual[t2_output->cnt].covid19_result 		= concat("Positive")
				;set t2_output->qual[t2_output->cnt].covid19_result_dt_tm 	=
				;		;changing to clinsig_updt_dt_tm trim(format(t_rec->patient_qual[i].lab_results_qual[1].event_end_dt_tm,";;q"))
				;		trim(format(t_rec->patient_qual[i].lab_results_qual[1].event_end_dt_tm,"mm-dd-yy hh:mm;;d"))
				;set t2_output->qual[t2_output->cnt].positive_ind = 1
 
				call writeLog(build2("-->checking result_dt_Tm="
					,trim(format(t_rec->patient_qual[i].lab_results_qual[k].event_end_dt_tm,";;q"))))
				call writeLog(build2("-->checking positive_onset_dt_tm="
					,trim(format(t_rec->patient_qual[i].positive_onset_dt_tm,";;q"))))
 
				if (t_rec->patient_qual[i].lab_results_qual[k].event_end_dt_tm < t_rec->patient_qual[i].positive_onset_dt_tm)
					set t_rec->patient_qual[i].positive_onset_dt_tm = t_rec->patient_qual[i].lab_results_qual[k].event_end_dt_tm
					call writeLog(build2("--->setting new positive_onset_Dt_Tm"))
				endif
			endif
		 endfor
		endfor
		if (stat = 0)
			if (t_rec->patient_qual[i].lab_results_cnt = 1)
				set t2_output->qual[t2_output->cnt].covid19_result = concat(	 t_rec->patient_qual[i].lab_results_qual[1].result_val)
				set t2_output->qual[t2_output->cnt].covid19_result_dttm = t_rec->patient_qual[i].lab_results_qual[1].event_end_dt_tm
				set t2_output->qual[t2_output->cnt].covid19_result_dt_tm	=
					;changing to clinsig_updt_dt_tm trim(format(t_rec->patient_qual[i].lab_results_qual[1].event_end_dt_tm,";;q"))
					trim(format(t_rec->patient_qual[i].lab_results_qual[1].event_end_dt_tm,"mm-dd-yy hh:mm;;d"))
			else
				set pos = 1
				while (pos <= t_rec->patient_qual[i].lab_results_cnt)
					if (stat = 0)
						if (t_rec->patient_qual[i].lab_results_qual[pos].result_val not in("DUPLICATE","RE-ORDERED","SEE BELOW"))
							set stat = 1
							set t2_output->qual[t2_output->cnt].covid19_result = concat(t_rec->patient_qual[i].lab_results_qual[pos].result_val)
							set t2_output->qual[t2_output->cnt].covid19_result_dttm = t_rec->patient_qual[i].lab_results_qual[pos].event_end_dt_tm
							set t2_output->qual[t2_output->cnt].covid19_result_dt_tm =
								;changing to clinsig_updt_dt_tm trim(format(t_rec->patient_qual[i].lab_results_qual[pos].event_end_dt_tm,";;q"))
								trim(format(t_rec->patient_qual[i].lab_results_qual[pos].event_end_dt_tm,"mm-dd-yy hh:mm;;d"))
						endif
					endif
					set pos = (pos + 1)
				endwhile
			endif
		endif
	endif
 
	;COVID-19 Suspected Date and Time
	if ((t2_output->qual[t2_output->cnt].suspected_ind = 1) and (t2_output->qual[t2_output->cnt].inpatient_dt_tm > " "))
		if (t_rec->patient_qual[i].suspected_onset_dt_tm >= cnvtlookahead("14,D",t_rec->patient_qual[i].inpatient_dt_tm))
			set t2_output->qual[t2_output->cnt].hosp_susp_onset = 1
		endif
		if (t_rec->patient_qual[i].encntr_loc_cnt > 0)
			for (j=1 to t_rec->patient_qual[i].encntr_loc_cnt)
				if (t_rec->patient_qual[i].suspected_onset_dt_tm between
								t_rec->patient_qual[i].encntr_loc_qual[j].beg_dt_tm
							and t_rec->patient_qual[i].encntr_loc_qual[j].end_dt_tm)
					if (trim(replace(t_rec->patient_qual[i].encntr_loc_qual[j].unit,t2_output->qual[t2_output->cnt].facility,""),3)
						 in("ED","EB"))
						set t2_output->qual[t2_output->cnt].ed_admit_suspected_ind = 1
						if (t2_output->qual[t2_output->cnt].positive_ind = 1)
							set t2_output->qual[t2_output->cnt].ed_admit_confirmed_ind = 1
						endif
					endif
				endif
			endfor
		endif
	endif
 
	;Flu Result Column 002
	if (t_rec->patient_qual[i].flu_results_cnt > 0)
		set stat = 0
		;;CHECKING MOST RECENT RESULT FOR POSITIVE
		for (j=1 to t_rec->covid19.positive_cnt)
			if (t_rec->patient_qual[i].flu_results_qual[1].result_val = t_rec->covid19.positive_qual[j].result_val)
				set stat = 1
				set t2_output->qual[t2_output->cnt].flu_result 		= concat("Positive")
				set t2_output->qual[t2_output->cnt].flu_result_dt_tm 	=
						;changing to clinsig_updt_dt_tm trim(format(t_rec->patient_qual[i].flu_results_qual[1].event_end_dt_tm,";;q"))
						trim(format(t_rec->patient_qual[i].flu_results_qual[1].event_end_dt_tm,"mm-dd-yy hh:mm;;d"))
				set t2_output->qual[t2_output->cnt].flu_positive_ind = 1
 
				if (t_rec->patient_qual[i].flu_onset_dt_tm = 0.0)
					set t_rec->patient_qual[i].flu_onset_dt_tm = t_rec->patient_qual[i].flu_results_qual[1].event_end_dt_tm
				endif
			endif
		endfor
		;;CHECKING FOR FIRST POSITIVE
		for (k=1 to t_rec->patient_qual[i].flu_results_cnt)
		 for (j=1 to t_rec->covid19.positive_cnt)
			if (t_rec->patient_qual[i].flu_results_qual[k].result_val = t_rec->covid19.positive_qual[j].result_val)
				;set t2_output->qual[t2_output->cnt].flu_result 		= concat("Positive")
				;set t2_output->qual[t2_output->cnt].flu_result_dt_tm 	=
				;		;changing to clinsig_updt_dt_tm trim(format(t_rec->patient_qual[i].flu_results_qual[1].event_end_dt_tm,";;q"))
				;		trim(format(t_rec->patient_qual[i].flu_results_qual[1].event_end_dt_tm,"mm-dd-yy hh:mm;;d"))
				;set t2_output->qual[t2_output->cnt].positive_ind = 1
				;
				if (t_rec->patient_qual[i].flu_results_qual[k].event_end_dt_tm < t_rec->patient_qual[i].flu_onset_dt_tm)
					set t_rec->patient_qual[i].flu_onset_dt_tm = t_rec->patient_qual[i].flu_results_qual[k].event_end_dt_tm
				endif
			endif
		 endfor
		endfor
		if (stat = 0)
			if (t_rec->patient_qual[i].flu_results_cnt = 1)
				set t2_output->qual[t2_output->cnt].flu_result = concat(	 t_rec->patient_qual[i].flu_results_qual[1].result_val)
				set t2_output->qual[t2_output->cnt].flu_result_dttm = t_rec->patient_qual[i].flu_results_qual[1].event_end_dt_tm
				set t2_output->qual[t2_output->cnt].flu_result_dt_tm	=
					;changing to clinsig_updt_dt_tm trim(format(t_rec->patient_qual[i].flu_results_qual[1].event_end_dt_tm,";;q"))
					trim(format(t_rec->patient_qual[i].flu_results_qual[1].event_end_dt_tm,"mm-dd-yy hh:mm;;d"))
			else
				set pos = 1
				while (pos <= t_rec->patient_qual[i].flu_results_cnt)
					if (stat = 0)
						if (t_rec->patient_qual[i].flu_results_qual[pos].result_val not in("DUPLICATE","RE-ORDERED","SEE BELOW"))
							set stat = 1
							set t2_output->qual[t2_output->cnt].flu_result = concat(t_rec->patient_qual[i].flu_results_qual[pos].result_val)
							set t2_output->qual[t2_output->cnt].flu_result_dttm = t_rec->patient_qual[i].flu_results_qual[pos].event_end_dt_tm
							set t2_output->qual[t2_output->cnt].flu_result_dt_tm =
								;changing to clinsig_updt_dt_tm trim(format(t_rec->patient_qual[i].flu_results_qual[pos].event_end_dt_tm,";;q"))
								trim(format(t_rec->patient_qual[i].flu_results_qual[pos].event_end_dt_tm,"mm-dd-yy hh:mm;;d"))
						endif
					endif
					set pos = (pos + 1)
				endwhile
			endif
		endif
		set t2_output->qual[t2_output->cnt].flu_onset_dt_tm_dq8 = t_rec->patient_qual[i].flu_onset_dt_tm
	endif
	;end 002
 
	;Ventilator Column - Current Patients
	select into "nl:"
		 encntr_id		 = t_rec->patient_qual[d1.seq].encntr_id
		,event_end_dt_tm = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm
	from
		 (dummyt d1 with seq=t_rec->patient_cnt)
		,(dummyt d2)
	plan d1
		where t_rec->patient_qual[d1.seq].encntr_id = t_rec->patient_qual[i].encntr_id
		and   (t_rec->patient_qual[d1.seq].historic_ind = 0 or t_rec->patient_qual[d1.seq].expired_ind = 0)
		and   maxrec(d2,t_rec->patient_qual[d1.seq].vent_results_cnt)
	join d2
	order by
		 encntr_id
		,event_end_dt_tm desc
	head encntr_id
		stat = 0
	head event_end_dt_tm
	 if (stat = 0)
		if (cnvtupper(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].result_val) in("*DISCONTINUE*"))
			stat = 1
		else
			for (j=1 to t_rec->vent.result_cnt)
				if (t_rec->vent.result_qual[j].lookback_hrs > 0)
					if ((t_rec->vent.result_qual[j].event_cd = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_cd) and
						(datetimediff(cnvtdatetime(curdate,curtime3),t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm,3)
																				<= t_rec->vent.result_qual[j].lookback_hrs))
						t2_output->qual[t2_output->cnt].ventilator = concat(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].result_val)
						t2_output->qual[t2_output->cnt].ventilator_dt_tm =
							trim(format(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm,"mm-dd-yy hh:mm;;d"))
						t2_output->qual[t2_output->cnt].ventilator_type = uar_get_code_display(t_rec->patient_qual[d1.seq].
							vent_results_qual[d2.seq].event_cd)
						t2_output->qual[t2_output->cnt].ventilator_model = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_result_val
						stat = 1
						if (t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].ventilator_type = "I")
							t2_output->qual[t2_output->cnt].ventilator_ind = 1
						elseif (t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].ventilator_type = "N")
							t2_output->qual[t2_output->cnt].ventilator_ind = 2
						endif
						t2_output->qual[t2_output->cnt].covenant_vent_stock_ind
							= t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].covenant_stock_ind
					endif
				elseif (t_rec->vent.result_qual[j].event_cd = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_cd)
					t2_output->qual[t2_output->cnt].ventilator = concat(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].result_val)
					t2_output->qual[t2_output->cnt].ventilator_dt_tm =
						trim(format(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm,"mm-dd-yy hh:mm;;d"))
					t2_output->qual[t2_output->cnt].ventilator_type = uar_get_code_display(t_rec->patient_qual[d1.seq].
						vent_results_qual[d2.seq].event_cd)
					t2_output->qual[t2_output->cnt].ventilator_model = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_result_val
					stat = 1
					t2_output->qual[t2_output->cnt].ventilator_ind = 1
					t2_output->qual[t2_output->cnt].covenant_vent_stock_ind
						= t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].covenant_stock_ind
				endif
			endfor
		endif
	 endif
	with nocounter
 
	;Ventilator Column - Historical and Expired Patients
	select into "nl:"
		 encntr_id		 = t_rec->patient_qual[d1.seq].encntr_id
		,event_end_dt_tm = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm
	from
		 (dummyt d1 with seq=t_rec->patient_cnt)
		,(dummyt d2)
	plan d1
		where t_rec->patient_qual[d1.seq].encntr_id = t_rec->patient_qual[i].encntr_id
		and   (t_rec->patient_qual[d1.seq].historic_ind = 1 or t_rec->patient_qual[d1.seq].expired_ind = 1)
		and   maxrec(d2,t_rec->patient_qual[d1.seq].vent_results_cnt)
	join d2
	order by
		 encntr_id
		,event_end_dt_tm desc
	head encntr_id
		stat = 0
	head event_end_dt_tm
	 if (stat = 0)
		if (cnvtupper(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].result_val) in("*DISCONTINUE*"))
			stat = 0
		else
			for (j=1 to t_rec->vent.result_cnt)
				/*
				if (t_rec->vent.result_qual[j].lookback_hrs > 0)
					if ((t_rec->vent.result_qual[j].event_cd = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_cd) and
						(datetimediff(cnvtdatetime(curdate,curtime3),t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm,3)
																				<= t_rec->vent.result_qual[j].lookback_hrs))
						t2_output->qual[t2_output->cnt].ventilator = concat(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].result_val)
						t2_output->qual[t2_output->cnt].ventilator_dt_tm =
							trim(format(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm,";;q"))
						t2_output->qual[t2_output->cnt].ventilator_type = uar_get_code_display(t_rec->patient_qual[d1.seq].
							vent_results_qual[d2.seq].event_cd)
						t2_output->qual[t2_output->cnt].ventilator_model = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_result_val
						stat = 1
						if (t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].ventilator_type = "I")
							t2_output->qual[t2_output->cnt].ventilator_ind = 1
						elseif (t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].ventilator_type = "N")
							t2_output->qual[t2_output->cnt].ventilator_ind = 2
						endif
						t2_output->qual[t2_output->cnt].covenant_vent_stock_ind
							= t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].covenant_stock_ind
					endif
				elseif (t_rec->vent.result_qual[j].event_cd = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_cd)
				*/
				if (t_rec->vent.result_qual[j].event_cd = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_cd)
					t2_output->qual[t2_output->cnt].ventilator = concat(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].result_val)
					t2_output->qual[t2_output->cnt].ventilator_dt_tm =
						trim(format(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm,"mm-dd-yy hh:mm;;d"))
					t2_output->qual[t2_output->cnt].ventilator_type = uar_get_code_display(t_rec->patient_qual[d1.seq].
						vent_results_qual[d2.seq].event_cd)
					t2_output->qual[t2_output->cnt].ventilator_model = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_result_val
					stat = 1
					t2_output->qual[t2_output->cnt].ventilator_ind = 1
					t2_output->qual[t2_output->cnt].covenant_vent_stock_ind
						= t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].covenant_stock_ind
				endif
			endfor
		endif
	 endif
	with nocounter
 
	;Location Class 1
	set t2_output->qual[t2_output->cnt].location_class_1 = t_rec->patient_qual[i].loc_class_1
 
	;Expired Column
	set t2_output->qual[t2_output->cnt].expired_ind = t_rec->patient_qual[i].expired_ind
	set t2_output->qual[t2_output->cnt].expired_dt_tm = trim(format(t_rec->patient_qual[i].expired_dt_tm,"mm-dd-yy hh:mm;;d"))
 
	;Previous Admission Column
	if (
			(cnvtdatetime(t_rec->patient_qual[i].observation_dt_tm)
				between cnvtdatetime(t_rec->covid19.admission_start_dt_tm) and cnvtdatetime(t_rec->covid19.admission_end_dt_tm))
		or
			(cnvtdatetime(t_rec->patient_qual[i].inpatient_dt_tm)
				between cnvtdatetime(t_rec->covid19.admission_start_dt_tm) and cnvtdatetime(t_rec->covid19.admission_end_dt_tm))
		)
		set t_rec->patient_qual[i].previous_admission_ind = 1
		set t2_output->qual[t2_output->cnt].previous_admission_ind = t_rec->patient_qual[i].previous_admission_ind
	endif
 
	;Previous Onset Column
	if (t2_output->qual[t2_output->cnt].suspected_ind = 1)
		set t2_output->qual[t2_output->cnt].suspected_onset_dt_tm
			= format(t_rec->patient_qual[i].suspected_onset_dt_tm,"mm-dd-yy hh:mm;;d")
 
		if (cnvtdatetime(t_rec->patient_qual[i].suspected_onset_dt_tm) between	cnvtdatetime(t_rec->covid19.onset_start_dt_tm)
		 																	and		cnvtdatetime(t_rec->covid19.onset_end_dt_tm))
 
			set t_rec->patient_qual[i].previous_onset_ind = 1
			set t2_output->qual[t2_output->cnt].previous_onset_ind = t_rec->patient_qual[i].previous_onset_ind
		endif
	endif
 
	set t2_output->qual[t2_output->cnt].positive_onset_dt_tm = format(t_rec->patient_qual[i].positive_onset_dt_tm,"mm-dd-yy hh:mm;;d")
 
	if (t2_output->qual[t2_output->cnt].positive_ind = 1)
 
		if	(cnvtdatetime(t_rec->patient_qual[i].positive_onset_dt_tm) between	cnvtdatetime(t_rec->covid19.onset_start_dt_tm)
																					and		cnvtdatetime(t_rec->covid19.onset_end_dt_tm))
			set t_rec->patient_qual[i].previous_onset_ind = 1
			set t_rec->patient_qual[i].previous_onset_conf_ind = 1
			set t2_output->qual[t2_output->cnt].previous_onset_ind = t_rec->patient_qual[i].previous_onset_ind
			set t2_output->qual[t2_output->cnt].previous_onset_conf_ind = t_rec->patient_qual[i].previous_onset_conf_ind
		endif
	endif
 
	;Hospital Onset
	if (t_rec->patient_qual[i].positive_onset_dt_tm >= cnvtlookahead("14,D",t_rec->patient_qual[i].inpatient_dt_tm))
		if ((t_rec->patient_qual[i].inpatient_dt_tm > 0.0) and (t_rec->patient_qual[i].positive_onset_dt_tm > 0.0))
			set t2_output->qual[t2_output->cnt].hosp_conf_onset = 1
		endif
	endif
 
	;Historical Column
	set t2_output->qual[t2_output->cnt].historical_ind = t_rec->patient_qual[i].historic_ind
 
	;COVID19 Vaccine ;011
	if (t_rec->patient_qual[i].covid19_vaccine > " ")
		set t2_output->qual[t2_output->cnt].covid19_vaccine = build2(
												t_rec->patient_qual[i].covid19_vaccine
												," ("
												,format(t_rec->patient_qual[i].covid19_vaccine_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")
												,")")
 
		set t2_output->qual[t2_output->cnt].covid19_vaccine_ind = 1
	endif
 
	;COVID19 Vaccine Yes No ;011
	if (cnvtupper(t_rec->patient_qual[i].covid19_vax_yesno) = "YES")
		set t2_output->qual[t2_output->cnt].covid19_vaccine_yes_no = build2(
												t_rec->patient_qual[i].covid19_vax_yesno
												," ("
												,format(t_rec->patient_qual[i].covid19_vax_yesno_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")
												,")")
 
		set t2_output->qual[t2_output->cnt].covid19_vaccine_ind = 1
	endif
 
 	;COVID-19 Date Tested
 	set t2_output->qual[t2_output->cnt].date_tested_dt_tm = t_rec->patient_qual[i].date_tested ;012
 
 	;COVID-19 symptoms start date
 	set t2_output->qual[t2_output->cnt].symptom_result_dt_tm = t_rec->patient_qual[i].symptom_result ;012
 
endfor
 
call writeLog(build2("* END   Building Output (t2_output) ************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building zzNHSN Data (1,2) *************************"))
 
for (i=1 to t_output->cnt)
 if ((t_output->qual[i].historical_ind = 0) and (t_rec->prompt_historical_ind = 0))
  call writeLog(build2("-->checking encntr_id=",trim(cnvtstring(t_output->qual[i].encntr_id))))
  set t_output->qual[i].encntr_ignore = 1
  if (t_output->qual[i].expired_ind = 0)
	;Checking Q1 Count of Patients in an inpatient bed with confirmed or suspected COVID-19
	;Checking Q2 Count of Patients in an inpatient bed with confirmed or suspected COVID-19 and on a ventilator
	;Checking Q3 Count of Patients in an inpatient bed with confirmed or suspected COVID-19, LOS 14 days or More
	if ((t_output->qual[i].positive_ind = 1) or (t_output->qual[i].suspected_ind = 1))
		if (t_output->qual[i].location_class_1 in("ICU","MSU"))
			set t_output->qual[i].encntr_ignore = 0
		endif
	endif
 
	;Checking Q4 Count of Patients in ED or Overflow with confirmed or suspected COVID-19, and waiting on an inpatient bed
	if ((t_output->qual[i].positive_ind = 1) or (t_output->qual[i].suspected_ind = 1))
		if (t_output->qual[i].location_class_1 in("ED","EB"))
			if (t_output->qual[i].pso in("PSO Admit to Inpatient"))
				set t_output->qual[i].encntr_ignore = 0
			endif
		endif
	endif
	;Checking Q13 Checking if Patient is on a vent
	if ((t_output->qual[i].ventilator_ind > 0) and (t_output->qual[i].covenant_vent_stock_ind > 0))
		set t_output->qual[i].encntr_ignore = 0
	endif
  elseif (t_output->qual[i].expired_ind = 1)
   set t_output->qual[i].encntr_ignore = 0
  endif
	call writeLog(build2("--->checking encntr_ignore=",trim(cnvtstring(t_output->qual[i].encntr_ignore))))
	if (t_output->qual[i].encntr_ignore = 0)
		set nhsn_covid19->patient_cnt = (nhsn_covid19->patient_cnt + 1)
		set stat = alterlist(nhsn_covid19->patient_qual,nhsn_covid19->patient_cnt)
 
		call writeLog(build2("---->adding nhsn_covid19->patient_cnt=",trim(cnvtstring(nhsn_covid19->patient_cnt))))
 
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].encntr_id = t_output->qual[i].encntr_id
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].person_id = t_output->qual[i].person_id
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].patient_name = t_output->qual[i].patient_name
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].encntr_type = t_output->qual[i].encntr_type
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].facility = t_output->qual[i].facility
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].unit = t_output->qual[i].unit
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].room_bed = t_output->qual[i].room_bed
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].fin = t_output->qual[i].fin
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].los_days = t_output->qual[i].los_days
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].expired_dt_tm = t_output->qual[i].expired_dt_tm
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].reg_dt_tm = t_output->qual[i].reg_dt_tm
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].inpatient_dt_tm = t_output->qual[i].inpatient_dt_tm
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].observation_dt_tm = t_output->qual[i].observation_dt_tm
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].arrive_dt_tm = t_output->qual[i].arrive_dt_tm
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].disch_dt_tm = t_output->qual[i].disch_dt_tm
 
		if (t_output->qual[i].hosp_conf_onset = 1)
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].hosp_conf_onset = "Y"
		endif
 
		if ((t_output->qual[i].expired_ind = 1) and (t_output->qual[i].positive_ind = 1))
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].expired = "Y"
		endif
		if (t_output->qual[i].covid19_order > " ")
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].covid19_order = concat(
																					t_output->qual[i].covid19_order
																					," ("
																					,t_output->qual[i].covid19_order_dt_tm
																					,")"
																					)
		endif
		if (t_output->qual[i].isolation_order > " ")
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].isolation_order = concat(
																					t_output->qual[i].isolation_order
																					," ("
																					,t_output->qual[i].isolation_order_dt_tm
																					,")"
																					)
		endif
		if (t_output->qual[i].covid19_result > " ")
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].covid19_result = concat(
																					t_output->qual[i].covid19_result
																					," ("
																					,t_output->qual[i].covid19_result_dt_tm
																					,")"
																					)
		endif
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].diagnosis = t_output->qual[i].diagnosis
		if (t_output->qual[i].pso in("PSO Admit to Inpatient"))
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].ip_pso = "Y"
		endif
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].location_class_1 = t_output->qual[i].location_class_1
		if ((t_output->qual[i].suspected_ind = 1) and (t_output->qual[i].positive_ind = 0))
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].suspected = "Y"
		endif
 
		if (t_output->qual[i].positive_ind = 1)
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].confirmed = "Y"
		endif
 
		if (t_output->qual[i].ventilator_ind > 0)
			if (t_output->qual[i].ventilator_ind = 1)
				set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].ventilator = "I"
			elseif (t_output->qual[i].ventilator_ind = 2)
				set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].ventilator = "N"
			endif
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].ventilator_model = t_output->qual[i].ventilator_model
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].ventilator_result = t_output->qual[i].ventilator_type
			if (t_output->qual[i].covenant_vent_stock_ind = 1)
				set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].covenant_vent_stock = "Y"
			endif
		endif
 
		if (t_output->qual[i].previous_admission_ind = 1)
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].prev_admission = "Y"
		endif
 
		if (t_output->qual[i].previous_onset_ind = 1)
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].prev_onset = "Y"
		endif
 
	endif ;end if encntr_ignore = 0
 
	;end check, reset
	set t_output->qual[i].encntr_ignore = 1
 elseif ((t_output->qual[i].historical_ind = 1) and (t_rec->prompt_historical_ind = 1))
  call writeLog(build2("-->checking encntr_id=",trim(cnvtstring(t_output->qual[i].encntr_id))))
  set t_output->qual[i].encntr_ignore = 1
  if (t_output->qual[i].expired_ind = 0)
	;Checking Q1 Count of Patients in an inpatient bed with confirmed or suspected COVID-19
	;Checking Q2 Count of Patients in an inpatient bed with confirmed or suspected COVID-19 and on a ventilator
	;Checking Q3 Count of Patients in an inpatient bed with confirmed or suspected COVID-19, LOS 14 days or More
	if ((t_output->qual[i].positive_ind = 1) or (t_output->qual[i].suspected_ind = 1))
		if (t_output->qual[i].location_class_1 in("ICU","MSU"))
			set t_output->qual[i].encntr_ignore = 0
		endif
	endif
 
	;Checking Q4 Count of Patients in ED or Overflow with confirmed or suspected COVID-19, and waiting on an inpatient bed
	if ((t_output->qual[i].positive_ind = 1) or (t_output->qual[i].suspected_ind = 1))
		if (t_output->qual[i].location_class_1 in("ED","EB"))
			if (t_output->qual[i].pso in("PSO Admit to Inpatient"))
				set t_output->qual[i].encntr_ignore = 0
			endif
		endif
	endif
	;Checking Q13 Checking if Patient is on a vent
	if ((t_output->qual[i].ventilator_ind > 0) and (t_output->qual[i].covenant_vent_stock_ind > 0))
		set t_output->qual[i].encntr_ignore = 0
	endif
  elseif (t_output->qual[i].expired_ind = 1)
   set t_output->qual[i].encntr_ignore = 0
  endif
	call writeLog(build2("--->checking encntr_ignore=",trim(cnvtstring(t_output->qual[i].encntr_ignore))))
	if (t_output->qual[i].encntr_ignore = 0)
		set nhsn_covid19->patient_cnt = (nhsn_covid19->patient_cnt + 1)
		set stat = alterlist(nhsn_covid19->patient_qual,nhsn_covid19->patient_cnt)
 
		call writeLog(build2("---->adding nhsn_covid19->patient_cnt=",trim(cnvtstring(nhsn_covid19->patient_cnt))))
 
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].encntr_id = t_output->qual[i].encntr_id
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].person_id = t_output->qual[i].person_id
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].patient_name = t_output->qual[i].patient_name
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].encntr_type = t_output->qual[i].encntr_type
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].facility = t_output->qual[i].facility
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].unit = t_output->qual[i].unit
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].room_bed = t_output->qual[i].room_bed
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].fin = t_output->qual[i].fin
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].los_days = t_output->qual[i].los_days
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].expired_dt_tm = t_output->qual[i].expired_dt_tm
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].reg_dt_tm = t_output->qual[i].reg_dt_tm
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].inpatient_dt_tm = t_output->qual[i].inpatient_dt_tm
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].observation_dt_tm = t_output->qual[i].observation_dt_tm
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].arrive_dt_tm = t_output->qual[i].arrive_dt_tm
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].disch_dt_tm = t_output->qual[i].disch_dt_tm
		if ((t_output->qual[i].expired_ind = 1)); and (t_output->qual[i].positive_ind = 1))
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].expired = "Y"
		endif
		if (t_output->qual[i].covid19_order > " ")
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].covid19_order = concat(
																					t_output->qual[i].covid19_order
																					," ("
																					,t_output->qual[i].covid19_order_dt_tm
																					,")"
																					)
		endif
		if (t_output->qual[i].covid19_result > " ")
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].covid19_result = concat(
																					t_output->qual[i].covid19_result
																					," ("
																					,t_output->qual[i].covid19_result_dt_tm
																					,")"
																					)
		endif
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].diagnosis = t_output->qual[i].diagnosis
		if (t_output->qual[i].pso in("PSO Admit to Inpatient"))
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].ip_pso = "Y"
		endif
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].location_class_1 = t_output->qual[i].location_class_1
		if ((t_output->qual[i].suspected_ind = 1) and (t_output->qual[i].positive_ind = 0))
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].suspected = "Y"
		endif
 
		if (t_output->qual[i].positive_ind = 1)
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].confirmed = "Y"
		endif
 
		if (t_output->qual[i].ventilator_ind > 0)
			if (t_output->qual[i].ventilator_ind = 1)
				set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].ventilator = "I"
			elseif (t_output->qual[i].ventilator_ind = 2)
				set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].ventilator = "N"
			endif
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].ventilator_model = t_output->qual[i].ventilator_model
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].ventilator_result = t_output->qual[i].ventilator_type
			if (t_output->qual[i].covenant_vent_stock_ind = 1)
				set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].covenant_vent_stock = "Y"
			endif
		endif
 
		if (t_output->qual[i].previous_admission_ind = 1)
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].prev_admission = "Y"
		endif
 
		if (t_output->qual[i].previous_onset_ind = 1)
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].prev_onset = "Y"
		endif
 
	endif ;end if encntr_ignore = 0
 
	;end check, reset
	set t_output->qual[i].encntr_ignore = 1
 endif ;if ((t_output->qual[i].historical_ind = 0) and (t_rec->prompt_historical_ind = 0))
endfor
 
 
call writeLog(build2("** Building Summary Table"))
 
for (i=1 to location_list->location_cnt)
	call writeLog(build2("->location:",trim(location_list->locations[i].display)))
	select into "nl:"
		encntr_id				= nhsn_covid19->patient_qual[d1.seq].encntr_id
	from
		(dummyt d1 with seq=nhsn_covid19->patient_cnt)
	plan d1
		where nhsn_covid19->patient_qual[d1.seq].facility = location_list->locations[i].display
	order by
	 	 encntr_id
	head report
		call writeLog(build2("-->inside nhsn_covid19 query for ",trim(location_list->locations[i].display)))
		nhsn_covid19->summary_cnt = (nhsn_covid19->summary_cnt + 1)
		stat = alterlist(nhsn_covid19->summary_qual,nhsn_covid19->summary_cnt)
		nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].facility = trim(location_list->locations[i].display)
		call writeLog(build2("-->nhsn_covid19->summary_cnt=",trim(cnvtstring(nhsn_covid19->summary_cnt))))
	head encntr_id
		call writeLog(build2("--->analyzing encntr_id=",trim(cnvtstring(encntr_id))))
	 if ((nhsn_covid19->patient_qual[d1.seq].expired = "Y") and (nhsn_covid19->patient_qual[d1.seq].confirmed = "Y"))
	 	call writeLog(build2("---->found expired=",trim(nhsn_covid19->patient_qual[d1.seq].expired)))
	 	nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q6_disch_expired =
	 		(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q6_disch_expired + 1)
	 else
		call writeLog(build2("---->reviewing location_class_1=",trim(nhsn_covid19->patient_qual[d1.seq].location_class_1)))
		if (nhsn_covid19->patient_qual[d1.seq].location_class_1 in("MSU","ICU"))
			call writeLog(build2("---->found location_class_1=",trim(nhsn_covid19->patient_qual[d1.seq].location_class_1)))
			;Confirmed
			call writeLog(build2("----->reviewing confirmation=",trim(nhsn_covid19->patient_qual[d1.seq].confirmed)))
			if (nhsn_covid19->patient_qual[d1.seq].confirmed = "Y")
				nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_ip_confirmed =
				(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_ip_confirmed + 1)
				call writeLog(build2("--->setting q1_ip_confirmed=",
					trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_ip_confirmed))))
				if (nhsn_covid19->patient_qual[d1.seq].prev_admission = "Y")
					nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qa_numc19confnewadm =
					 (nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qa_numc19confnewadm + 1)
					call writeLog(build2("--->setting qa_numc19confnewadm=",
					trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qa_numc19confnewadm))))
				endif
 
				if (nhsn_covid19->patient_qual[d1.seq].location_class_1 in("ICU"))
					nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q_icu_pos_inp =
					(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q_icu_pos_inp + 1)
					call writeLog(build2("--->setting q_icu_pos_inp=",
						trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q_icu_pos_inp))))
					nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q_icu_total =
					(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q_icu_total + 1)
					call writeLog(build2("--->setting q_icu_total=",
						trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q_icu_total))))
				endif
 
				;LOS >= 14
				call writeLog(build2("----->reviewing los_days=",
					trim(cnvtstring(nhsn_covid19->patient_qual[d1.seq].los_days))))
				if ((nhsn_covid19->patient_qual[d1.seq].los_days >= 14) and (nhsn_covid19->patient_qual[d1.seq].hosp_conf_onset="Y"))
						nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q3_ip_conf_susp_los14 =
						(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q3_ip_conf_susp_los14 + 1)
						call writeLog(build2("--->setting q3_ip_conf_susp_los14=",
							trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q3_ip_conf_susp_los14))))
 
						nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q3_ip_conf_los14 =
						(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q3_ip_conf_los14 + 1)
						call writeLog(build2("--->setting q3_ip_conf_los14=",
							trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q3_ip_conf_los14))))
 
						if (nhsn_covid19->patient_qual[d1.seq].prev_onset = "Y")
							nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qc_numc19honewpats =
							 (nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qc_numc19honewpats + 1)
							call writeLog(build2("--->setting qc_numc19honewpats=",
							trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qc_numc19honewpats))))
						endif
 
						if (nhsn_covid19->patient_qual[d1.seq].prev_onset_conf = "Y")
							nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qd_numc19honsetprev =
							 (nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qd_numc19honsetprev + 1)
							call writeLog(build2("--->setting qd_numc19honsetprev=",
							trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qd_numc19honsetprev))))
						endif
				endif
 
				;Ventilator
				call writeLog(build2("----->reviewing ventilator=",trim(nhsn_covid19->patient_qual[d1.seq].ventilator)))
				if (nhsn_covid19->patient_qual[d1.seq].ventilator in("I"))
					nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_ip_confirmed_vent =
					(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_ip_confirmed_vent + 1)
					call writeLog(build2("--->setting q2_ip_confirmed_vent=",
						trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_ip_confirmed_vent))))
				endif
			endif
 
			call writeLog(build2("----->reviewing suspected=",trim(nhsn_covid19->patient_qual[d1.seq].suspected)))
			if (nhsn_covid19->patient_qual[d1.seq].suspected = "Y")
				;Suspected
				nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_ip_suspected =
				(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_ip_suspected + 1)
				call writeLog(build2("--->setting q1_ip_suspected=",
					trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_ip_suspected))))
 
 
				if (nhsn_covid19->patient_qual[d1.seq].prev_admission = "Y")
					nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qb_numc19suspnewadm =
					 (nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qb_numc19suspnewadm + 1)
					call writeLog(build2("--->setting qb_numc19suspnewadm=",
					trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qb_numc19suspnewadm))))
				endif
 
				if (nhsn_covid19->patient_qual[d1.seq].location_class_1 in("ICU"))
					nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q_icu_susp_inp =
					(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q_icu_susp_inp + 1)
					call writeLog(build2("--->setting q_icu_pos_inp=",
						trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q_icu_susp_inp))))
					nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q_icu_total =
					(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q_icu_total + 1)
					call writeLog(build2("--->setting q_icu_total=",
						trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q_icu_total))))
				endif
 
				;LOS >= 14
				call writeLog(build2("----->reviewing suspected=",trim(cnvtstring(nhsn_covid19->patient_qual[d1.seq].los_days))))
				if ((nhsn_covid19->patient_qual[d1.seq].los_days >= 14) and (nhsn_covid19->patient_qual[d1.seq].hosp_susp_onset="Y"))
						nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q3_ip_conf_susp_los14 =
						(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q3_ip_conf_susp_los14 + 1)
					call writeLog(build2("--->setting q3_ip_conf_susp_los14=",
						trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q3_ip_conf_susp_los14))))
					endif
 
				;Ventilator
				call writeLog(build2("----->reviewing ventilator=",trim(nhsn_covid19->patient_qual[d1.seq].ventilator)))
				if (nhsn_covid19->patient_qual[d1.seq].ventilator in("I"))
					nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_ip_suspected_vent =
					(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_ip_suspected_vent + 1)
					call writeLog(build2("--->setting q2_ip_suspected_vent=",
						trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_ip_suspected_vent))))
				endif
			endif
		elseif (nhsn_covid19->patient_qual[d1.seq].location_class_1 in("ED","EB"))
			call writeLog(build2("---->found location_class_1=",trim(nhsn_covid19->patient_qual[d1.seq].location_class_1)))
			;ED with PSO
		  	if ((nhsn_covid19->patient_qual[d1.seq].confirmed = "Y") or (nhsn_covid19->patient_qual[d1.seq].suspected = "Y"))
				nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q4_ed_of_conf_susp_wait =
				(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q4_ed_of_conf_susp_wait + 1)
				call writeLog(build2("--->setting q4_ed_of_conf_susp_wait=",
							trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q4_ed_of_conf_susp_wait))))
	 		endif
			if (nhsn_covid19->patient_qual[d1.seq].confirmed = "Y")
				nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q4_ed_of_conf_wait =
				(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q4_ed_of_conf_wait + 1)
				call writeLog(build2("--->setting q4_ed_of_conf_wait=",
						trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q4_ed_of_conf_wait))))
			endif
 
			;Ventilator
			call writeLog(build2("----->reviewing ventilator=",trim(nhsn_covid19->patient_qual[d1.seq].ventilator)))
			if (nhsn_covid19->patient_qual[d1.seq].ventilator in("I"))
				nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q5_ed_of_conf_susp_wait_vent =
				(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q5_ed_of_conf_susp_wait_vent + 1)
				call writeLog(build2("--->setting q5_ed_of_conf_susp_wait_vent=",
						trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q5_ed_of_conf_susp_wait_vent))))
				if (nhsn_covid19->patient_qual[d1.seq].confirmed = "Y")
					nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q5_ed_of_conf_wait_vent =
					(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q5_ed_of_conf_wait_vent + 1)
					call writeLog(build2("--->setting q5_ed_of_conf_wait_vent=",
						trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q5_ed_of_conf_wait_vent))))
				endif
			endif
		endif
		if ((nhsn_covid19->patient_qual[d1.seq].ventilator in("I","N"))
					and (nhsn_covid19->patient_qual[d1.seq].covenant_vent_stock = "Y"))
			nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q13_ventilator_in_use =
			(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q13_ventilator_in_use + 1)
			call writeLog(build2("--->setting q13_ventilator_in_use=",
			trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q13_ventilator_in_use))))
		endif
	 endif
	foot report
		call writeLog(build2("-->leaving nhsn_covid19 query for ",trim(location_list->locations[i].display)))
		call writeLog(build2("-->nhsn_covid19->summary_cnt=",trim(cnvtstring(nhsn_covid19->summary_cnt))))
		nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_total =
			(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_ip_confirmed +
			 nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_ip_suspected)
		call writeLog(build2("-->nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_total="
			,trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_total))))
 
		nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_total =
			(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_ip_confirmed_vent +
			 nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_ip_suspected_vent)
				call writeLog(build2("-->nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_total="
			,trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_total))))
	with nocounter,nullreport
endfor
 
 
call writeLog(build2("** Building Summary Table from Extensions"))
 
for (i=1 to nhsn_covid19->summary_cnt)
	select into "nl:"
	from
		 (dummyt d1 with seq=nhsn_covid19->summary_cnt)
	    ,code_value cv1
	    ,code_value_extension cve1
	plan d1
		where nhsn_covid19->summary_qual[1].facility
	join cv1
	    where cv1.code_set              = t_rec->custom_code_set
	    and   cv1.definition            = trim(cnvtlower(t_rec->curprog))
	    and   cv1.active_ind            = 1
	    and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	    and   cv1.end_effective_dt_tm   >= cnvtdatetime(curdate,curtime3)
	    and   cv1.cdf_meaning           = "FACILITY"
	    and   cv1.display				= nhsn_covid19->summary_qual[d1.seq].facility
	join cve1
		where cve1.code_value			= cv1.code_value
		and   cve1.field_name			in(
											 "Q7"
											,"Q8"
											,"Q10"
											,"Q12"
											,"NUMC19DIED"
											)
	order by
		 cv1.code_value
		,cve1.field_name
	head report
		call writeLog(build2("->inside :",trim(nhsn_covid19->summary_qual[d1.seq].facility)))
	head cv1.code_value
		call writeLog(build2("-->inside :",trim(cv1.display)))
	head cve1.field_name
		call writeLog(build2("--->inside :",trim(cve1.field_name)))
		case (cve1.field_name)
			of "Q7": 	nhsn_covid19->summary_qual[d1.seq].q7_all_beds_total			= cnvtint(cve1.field_value)
			of "Q8": 	nhsn_covid19->summary_qual[d1.seq].q8_all_beds_total_surge		= cnvtint(cve1.field_value)
			of "Q10": 	nhsn_covid19->summary_qual[d1.seq].q10_avail_icu_beds			= cnvtint(cve1.field_value)
			of "Q12": 	nhsn_covid19->summary_qual[d1.seq].q12_ventilator_total			= cnvtint(cve1.field_value)
			of "NUMC19DIED": nhsn_covid19->summary_qual[d1.seq].q6a_all_expired			= cnvtint(cve1.field_value)
		endcase
	foot cv1.code_value
		call writeLog(build2("-->leaving :",trim(nhsn_covid19->summary_qual[d1.seq].facility)))
	foot report
		call writeLog(build2("->leaving :",trim(nhsn_covid19->summary_qual[d1.seq].facility)))
	with nocounter
endfor
 
 
call writeLog(build2("** Building Summary Table for Bed Counts"))
 
for (i=1 to nhsn_covid19->summary_cnt)
 if (t_rec->prompt_historical_ind = 0)
	select into "nl:"
		 facility = t_output->qual[d1.seq].facility
		,encntr_id = t_output->qual[d1.seq].encntr_id
	from
		 (dummyt d1 with seq=t_output->cnt)
	plan d1
		where t_output->qual[d1.seq].facility = nhsn_covid19->summary_qual[i].facility
		and   t_output->qual[d1.seq].expired_ind = 0
	order by
		  facility
		 ,encntr_id
	head report
		call writeLog(build2("->inside :",trim(facility)))
	head facility
		call writeLog(build2("-->inside :",trim(facility)))
	head encntr_id
		call writeLog(build2("--->checking encntr_id=",trim(cnvtstring(encntr_id))))
		if (t_output->qual[d1.seq].location_class_1 in("ICU","MSU"))
			nhsn_covid19->summary_qual[i].q9_occupied_ip_beds = (nhsn_covid19->summary_qual[i].q9_occupied_ip_beds + 1)
		endif
		if (t_output->qual[d1.seq].location_class_1 in("ICU"))
			nhsn_covid19->summary_qual[i].q11_occupied_icu_beds = (nhsn_covid19->summary_qual[i].q11_occupied_icu_beds + 1)
		endif
	foot encntr_id
		call writeLog(build2("--->leaving encntr_id=",trim(cnvtstring(encntr_id))))
	foot facility
		call writeLog(build2("-->leaving :",trim(facility)))
	foot report
		call writeLog(build2("->leaving :",trim(facility)))
	with nocounter
 endif ;if (t_rec->prompt_historical_ind = 0)
endfor
 
call writeLog(build2("* END   Building zzNHSN Data *******************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building TeleTracking Data (8) *********************"))
 
for (i=1 to t_output->cnt)
	call writeLog(build2("-->checking encntr_id=",trim(cnvtstring(t_output->qual[i].encntr_id))))
	set t_output->qual[i].encntr_ignore = 1
	if (t_output->qual[i].expired_ind = 0)
		if ((t_output->qual[i].positive_ind = 1) or (t_output->qual[i].suspected_ind = 1))
			if (t_output->qual[i].location_class_1 in("ICU","MSU"))
				set t_output->qual[i].encntr_ignore = 0
			endif
		endif
 
		if ((t_output->qual[i].positive_ind = 1) or (t_output->qual[i].suspected_ind = 1))
			if (t_output->qual[i].location_class_1 in("ED","EB"))
				if (t_output->qual[i].pso in("PSO Admit to Inpatient"))
					set t_output->qual[i].encntr_ignore = 0
				endif
			endif
		endif
 
		if ((t_output->qual[i].ventilator_ind > 0) and (t_output->qual[i].covenant_vent_stock_ind > 0))
			set t_output->qual[i].encntr_ignore = 0
		endif
	elseif (t_output->qual[i].expired_ind = 1)
		set t_output->qual[i].encntr_ignore = 0
	endif
 
	call writeLog(build2("--->checking encntr_ignore=",trim(cnvtstring(t_output->qual[i].encntr_ignore))))
	if (t_output->qual[i].encntr_ignore = 0)
		set teletracking->patient_cnt = (teletracking->patient_cnt + 1)
		set stat = alterlist(teletracking->patient_qual,teletracking->patient_cnt)
 
		call writeLog(build2("---->adding teletracking->patient_cnt=",trim(cnvtstring(teletracking->patient_cnt))))
 
		set teletracking->patient_qual[teletracking->patient_cnt].encntr_id = t_output->qual[i].encntr_id
		set teletracking->patient_qual[teletracking->patient_cnt].person_id = t_output->qual[i].person_id
		set teletracking->patient_qual[teletracking->patient_cnt].patient_name = t_output->qual[i].patient_name
		set teletracking->patient_qual[teletracking->patient_cnt].encntr_type = t_output->qual[i].encntr_type
		set teletracking->patient_qual[teletracking->patient_cnt].facility = t_output->qual[i].facility
		set teletracking->patient_qual[teletracking->patient_cnt].unit = t_output->qual[i].unit
		set teletracking->patient_qual[teletracking->patient_cnt].room_bed = t_output->qual[i].room_bed
		set teletracking->patient_qual[teletracking->patient_cnt].fin = t_output->qual[i].fin
		set teletracking->patient_qual[teletracking->patient_cnt].los_days = t_output->qual[i].los_days
		if ((t_output->qual[i].expired_ind = 1) and (t_output->qual[i].positive_ind = 1))
			set teletracking->patient_qual[teletracking->patient_cnt].expired = "Y"
		endif
		if (t_output->qual[i].covid19_order > " ")
			set teletracking->patient_qual[teletracking->patient_cnt].covid19_order = concat(
																					t_output->qual[i].covid19_order
																					," ("
																					,t_output->qual[i].covid19_order_dt_tm
																					,")"
																					)
		endif
		if (t_output->qual[i].covid19_result > " ")
			set teletracking->patient_qual[teletracking->patient_cnt].covid19_result = concat(
																					t_output->qual[i].covid19_result
																					," ("
																					,t_output->qual[i].covid19_result_dt_tm
																					,")"
																					)
		endif
 
		set teletracking->patient_qual[teletracking->patient_cnt].diagnosis = t_output->qual[i].diagnosis
 
		if (t_output->qual[i].pso in("PSO Admit to Inpatient"))
			set teletracking->patient_qual[teletracking->patient_cnt].ip_pso = "Y"
		endif
 
		set teletracking->patient_qual[teletracking->patient_cnt].location_class_1 = t_output->qual[i].location_class_1
 
		if ((t_output->qual[i].suspected_ind = 1) and (t_output->qual[i].positive_ind = 0))
			set teletracking->patient_qual[teletracking->patient_cnt].suspected = "Y"
		endif
 
		if (t_output->qual[i].positive_ind = 1)
			set teletracking->patient_qual[teletracking->patient_cnt].confirmed = "Y"
		endif
 
		if (t_output->qual[i].ventilator_ind > 0)
			if (t_output->qual[i].ventilator_ind = 1)
				set teletracking->patient_qual[teletracking->patient_cnt].ventilator = "I"
			elseif (t_output->qual[i].ventilator_ind = 2)
				set teletracking->patient_qual[teletracking->patient_cnt].ventilator = "N"
			endif
			set teletracking->patient_qual[teletracking->patient_cnt].ventilator_model = t_output->qual[i].ventilator_model
			set teletracking->patient_qual[teletracking->patient_cnt].ventilator_result = t_output->qual[i].ventilator_type
			if (t_output->qual[i].covenant_vent_stock_ind = 1)
				set teletracking->patient_qual[teletracking->patient_cnt].covenant_vent_stock = "Y"
			endif
		endif
 
		if (t_output->qual[i].previous_admission_ind = 1)
			set teletracking->patient_qual[teletracking->patient_cnt].prev_admission = "Y"
		endif
 
		if (t_output->qual[i].previous_onset_ind = 1)
			set teletracking->patient_qual[teletracking->patient_cnt].prev_onset = "Y"
		endif
 
	endif ;end if encntr_ignore = 0
 
	set t_output->qual[i].encntr_ignore = 1
endfor
 
call writeLog(build2("** Building Summary Table"))
for (i=1 to location_list->location_cnt)
	call writeLog(build2("->location:",trim(location_list->locations[i].display)))
	select into "nl:"
		encntr_id				= teletracking->patient_qual[d1.seq].encntr_id
	from
		(dummyt d1 with seq=teletracking->patient_cnt)
	plan d1
		where teletracking->patient_qual[d1.seq].facility = location_list->locations[i].display
	order by
	 	 encntr_id
	head report
		call writeLog(build2("-->inside teletracking query for ",trim(location_list->locations[i].display)))
		teletracking->summary_cnt = (teletracking->summary_cnt + 1)
		stat = alterlist(teletracking->summary_qual,teletracking->summary_cnt)
		teletracking->summary_qual[teletracking->summary_cnt].facility = trim(location_list->locations[i].display)
		teletracking->summary_qual[teletracking->summary_cnt].hospital_name
			= uar_get_code_description(location_list->locations[i].location_cd)
		call writeLog(build2("-->teletracking->summary_cnt=",trim(cnvtstring(teletracking->summary_cnt))))
		teletracking->summary_qual[teletracking->summary_cnt].date_entered_utc	= format(sysdate,"mm-dd-yyyy;;d")
		teletracking->summary_qual[teletracking->summary_cnt].ventilator_supplies_days_on_hand	   									= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].ventilator_supplies_able_to_obtain     								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].ventilator_supplies_3day_supply        								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].fentanyl_able_to_obtain                								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].fentanyl_3day_supply                   								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].hydromorphone_able_to_obtain           								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].hydromorphone_3day_supply              								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].propofol_able_to_obtain                								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].propofol_3day_supply                   								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].midazolam_able_to_obtain               								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].midazolam_3day_supply                  								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].dexmedetomidine_able_to_obtain         								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].dexmedetomidine_3day_supply            								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].cisatracurium_able_to_obtain           								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].cisatracurium_3day_supply              								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].rocuronium_able_to_obtain              								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].rocuronium_3day_supply                 								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].total_n95_3day_supply													= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].total_n95_reuse                         								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].total_surgical_mask_3day_supply         								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].total_surgical_mask_reuse               								= "No"
		teletracking->summary_qual[teletracking->summary_cnt].total_face_shields_3day_supply										= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].total_face_shields_reuse                								= "No"
		teletracking->summary_qual[teletracking->summary_cnt].total_gloves_3day_supply                								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].total_gloves_reuse                      								= "No"
		teletracking->summary_qual[teletracking->summary_cnt].total_surgical_gowns_3day_supply        								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].total_surgical_gowns_reuse              								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].total_papr_3day_supply												= "No"
		teletracking->summary_qual[teletracking->summary_cnt].ppe_source															= "System"
		teletracking->summary_qual[teletracking->summary_cnt].use_launderable_gowns													= "No"
		teletracking->summary_qual[teletracking->summary_cnt].nasal_pharyngeal_swabs_3day_supply									= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].nasal_swabs_3day_supply                 								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].viral_transport_media_3day_supply       								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].staffing_shortage_today												= "No"
		teletracking->summary_qual[teletracking->summary_cnt].staffing_shortage_anticipated_this_week                               = "No"
		teletracking->summary_qual[teletracking->summary_cnt].staffing_shortage_anticipated_environmental_services                  = "No"
		teletracking->summary_qual[teletracking->summary_cnt].staffing_shortage_anticipated_nurses                                  = "No"
		teletracking->summary_qual[teletracking->summary_cnt].staffing_shortage_anticipated_respiratory_therapists                  = "No"
		teletracking->summary_qual[teletracking->summary_cnt].staffing_shortage_anticipated_pharmacist_and_pharmacy_tech            = "No"
		teletracking->summary_qual[teletracking->summary_cnt].staffing_shortage_anticipated_other_physicians                        = "No"
		teletracking->summary_qual[teletracking->summary_cnt].staffing_shortage_anticipated_other_licensed_independent_practitioners= "No"
		teletracking->summary_qual[teletracking->summary_cnt].staffing_shortage_anticipated_temporary_staff                         = "No"
		teletracking->summary_qual[teletracking->summary_cnt].staffing_shortage_anticipated_other_critical_healthcare_personnel     = "No"
		teletracking->summary_qual[teletracking->summary_cnt].ventilator_medications_able_to_obtain 								= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].ventilator_medications_3day_supply 									= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].n95_able_to_obtain 													= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].surgical_masks_able_to_obtain 										= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].face_shields_able_to_obtain 											= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].gloves_able_to_obtain								 					= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].total_single_use_gowns_3day_supply 									= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].single_use_gowns_able_to_obtain 										= "Yes"
		teletracking->summary_qual[teletracking->summary_cnt].papr_able_to_obtain 													= "Yes"
	head encntr_id
		call writeLog(build2("--->analyzing encntr_id=",trim(cnvtstring(encntr_id))))
	with nocounter,nullreport
endfor
 
call writeLog(build2("** Building Summary Table from Extensions"))
 
for (i=1 to teletracking->summary_cnt)
		select into "nl:"
	from
		 (dummyt d1 with seq=teletracking->summary_cnt)
	    ,code_value cv1
	    ,code_value_extension cve1
	plan d1
		where teletracking->summary_qual[i].facility
	join cv1
	    where cv1.code_set              = t_rec->custom_code_set
	    and   cv1.definition            = trim(cnvtlower(t_rec->curprog))
	    and   cv1.active_ind            = 1
	    and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	    and   cv1.end_effective_dt_tm   >= cnvtdatetime(curdate,curtime3)
	    and   cv1.cdf_meaning           = "FACILITY"
	    and   cv1.display				= teletracking->summary_qual[d1.seq].facility
	join cve1
		where cve1.code_value			= cv1.code_value
		and   cve1.field_name			in(
											 "Hospital_CCN"
											,"Hospital_NPI"
											,"Hospital_AHA_ID"
											,"Hospital_NHSN_ID"
											,"Address_Street1"
											,"Address_City"
											,"Address_State"
											,"Address_Zip"
											,"TeleTracking_Id"
											)
	order by
		 cv1.code_value
		,cve1.field_name
	head report
		call writeLog(build2("->inside :",trim(teletracking->summary_qual[d1.seq].facility)))
	head cv1.code_value
		call writeLog(build2("-->inside :",trim(cv1.display)))
	head cve1.field_name
		call writeLog(build2("--->inside :",trim(cve1.field_name)))
		case (cve1.field_name)
			of "Hospital_CCN"			:	teletracking->summary_qual[d1.seq].hospital_ccn  	= trim(cve1.field_value)
			of "Hospital_NPI"			:	teletracking->summary_qual[d1.seq].hospital_npi  	= trim(cve1.field_value)
			of "Hospital_AHA_ID"		:	teletracking->summary_qual[d1.seq].hospital_aha_id	= trim(cve1.field_value)
			of "Hospital_NHSN_ID"		:	teletracking->summary_qual[d1.seq].hospital_nhsn_id	= trim(cve1.field_value)
			of "Address_Street1"		:	teletracking->summary_qual[d1.seq].address_street1	= trim(cve1.field_value)
			of "Address_City"			:	teletracking->summary_qual[d1.seq].address_city		= trim(cve1.field_value)
			of "Address_State"			:	teletracking->summary_qual[d1.seq].address_state	= trim(cve1.field_value)
			of "Address_Zip"			:	teletracking->summary_qual[d1.seq].address_zip		= trim(cve1.field_value)
			of "TeleTracking_Id"		:	teletracking->summary_qual[d1.seq].teletracking_id	= trim(cve1.field_value)
		endcase
	foot cv1.code_value
		call writeLog(build2("-->leaving :",trim(teletracking->summary_qual[d1.seq].facility)))
	foot report
		call writeLog(build2("->leaving :",trim(teletracking->summary_qual[d1.seq].facility)))
	with nocounter
endfor
call writeLog(build2("* END   Building TeleTracking Data *************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building HRTS v3 Data (12) *************************"))
 
for (i=1 to t2_output->cnt)
	call writeLog(build2("-->checking encntr_id=",trim(cnvtstring(t2_output->qual[i].encntr_id))))
	set t2_output->qual[i].encntr_ignore = 1
	if (t2_output->qual[i].expired_ind = 0)
		if ((t2_output->qual[i].positive_ind = 1) or (t2_output->qual[i].suspected_ind = 1))
			if (t2_output->qual[i].location_class_1 in("ICU","MSU"))
				set t2_output->qual[i].encntr_ignore = 0
			endif
		endif
 
		if ((t2_output->qual[i].positive_ind = 1) or (t2_output->qual[i].suspected_ind = 1))
			if (t2_output->qual[i].location_class_1 in("ED","EB"))
				if (t2_output->qual[i].pso in("PSO Admit to Inpatient"))
					set t2_output->qual[i].encntr_ignore = 0
				endif
			endif
		endif
 
		if ((t2_output->qual[i].ventilator_ind > 0) and (t2_output->qual[i].covenant_vent_stock_ind > 0))
			set t2_output->qual[i].encntr_ignore = 0
		endif
	elseif (t2_output->qual[i].expired_ind = 1)
		set t2_output->qual[i].encntr_ignore = 0
	endif
 
	call writeLog(build2("--->checking encntr_ignore=",trim(cnvtstring(t2_output->qual[i].encntr_ignore))))
	if (t2_output->qual[i].encntr_ignore = 0)
		set hrts_v3->patient_cnt = (hrts_v3->patient_cnt + 1)
		set stat = alterlist(hrts_v3->patient_qual,hrts_v3->patient_cnt)
 
		call writeLog(build2("---->adding hrts_v3->patient_cnt=",trim(cnvtstring(hrts_v3->patient_cnt))))
 
		set hrts_v3->patient_qual[hrts_v3->patient_cnt].encntr_id = t2_output->qual[i].encntr_id
		set hrts_v3->patient_qual[hrts_v3->patient_cnt].person_id = t2_output->qual[i].person_id
		set hrts_v3->patient_qual[hrts_v3->patient_cnt].patient_name = t2_output->qual[i].patient_name
		set hrts_v3->patient_qual[hrts_v3->patient_cnt].dob = t2_output->qual[i].dob
		set hrts_v3->patient_qual[hrts_v3->patient_cnt].age = t2_output->qual[i].age
		set hrts_v3->patient_qual[hrts_v3->patient_cnt].age_years =
													cnvtint((datetimediff(cnvtdatetime(curdate,0), t2_output->qual[i].date_of_birth)/365.25))
		set hrts_v3->patient_qual[hrts_v3->patient_cnt].encntr_type = t2_output->qual[i].encntr_type
		set hrts_v3->patient_qual[hrts_v3->patient_cnt].facility = t2_output->qual[i].facility
		set hrts_v3->patient_qual[hrts_v3->patient_cnt].unit = t2_output->qual[i].unit
		set hrts_v3->patient_qual[hrts_v3->patient_cnt].room_bed = t2_output->qual[i].room_bed
		set hrts_v3->patient_qual[hrts_v3->patient_cnt].fin = t2_output->qual[i].fin
		set hrts_v3->patient_qual[hrts_v3->patient_cnt].los_days = t2_output->qual[i].los_days
		if ((t2_output->qual[i].expired_ind = 1) and (t2_output->qual[i].positive_ind = 1))
			set hrts_v3->patient_qual[hrts_v3->patient_cnt].expired = "Y"
		endif
		if (t2_output->qual[i].covid19_order > " ")
			set hrts_v3->patient_qual[hrts_v3->patient_cnt].covid19_order = concat(
																					t2_output->qual[i].covid19_order
																					," ("
																					,t2_output->qual[i].covid19_order_dt_tm
																					,")"
																					)
		endif
		if (t2_output->qual[i].covid19_result > " ")
			set hrts_v3->patient_qual[hrts_v3->patient_cnt].covid19_result = concat(
																					t2_output->qual[i].covid19_result
																					," ("
																					,t2_output->qual[i].covid19_result_dt_tm
																					,")"
																					)
		endif
 
		set hrts_v3->patient_qual[hrts_v3->patient_cnt].diagnosis = t2_output->qual[i].diagnosis
 
		if (t2_output->qual[i].pso in("PSO Admit to Inpatient"))
			set hrts_v3->patient_qual[hrts_v3->patient_cnt].ip_pso = "Y"
		endif
 
		set hrts_v3->patient_qual[hrts_v3->patient_cnt].location_class_1 = t2_output->qual[i].location_class_1
 
		if ((t2_output->qual[i].suspected_ind = 1) and (t2_output->qual[i].positive_ind = 0))
			set hrts_v3->patient_qual[hrts_v3->patient_cnt].suspected = "Y"
		endif
 
		if (t2_output->qual[i].positive_ind = 1)
			set hrts_v3->patient_qual[hrts_v3->patient_cnt].confirmed = "Y"
		endif
 
		if (t2_output->qual[i].ventilator_ind > 0)
			if (t2_output->qual[i].ventilator_ind = 1)
				set hrts_v3->patient_qual[hrts_v3->patient_cnt].ventilator = "I"
			elseif (t2_output->qual[i].ventilator_ind = 2)
				set hrts_v3->patient_qual[hrts_v3->patient_cnt].ventilator = "N"
			endif
			set hrts_v3->patient_qual[hrts_v3->patient_cnt].ventilator_model = t2_output->qual[i].ventilator_model
			set hrts_v3->patient_qual[hrts_v3->patient_cnt].ventilator_result = t2_output->qual[i].ventilator_type
			if (t2_output->qual[i].covenant_vent_stock_ind = 1)
				set hrts_v3->patient_qual[hrts_v3->patient_cnt].covenant_vent_stock = "Y"
			endif
		endif
 
		if (t2_output->qual[i].previous_admission_ind = 1)
			set hrts_v3->patient_qual[hrts_v3->patient_cnt].prev_admission = "Y"
		endif
 
		if (t2_output->qual[i].previous_onset_ind = 1)
			set hrts_v3->patient_qual[hrts_v3->patient_cnt].prev_onset = "Y"
		endif
 
		if (t2_output->qual[i].hosp_conf_onset = 1)
			set hrts_v3->patient_qual[hrts_v3->patient_cnt].hosp_conf_onset = "Y"
		endif
 
		if (t2_output->qual[i].hosp_susp_onset = 1)
			set hrts_v3->patient_qual[hrts_v3->patient_cnt].hosp_susp_onset = "Y"
		endif
 
	endif ;end if encntr_ignore = 0
 
	set t2_output->qual[i].encntr_ignore = 1
endfor
 
call writeLog(build2("** Building Summary Table"))
for (i=1 to location_list->location_cnt)
	call writeLog(build2("->location:",trim(location_list->locations[i].display)))
	select into "nl:"
		encntr_id				= hrts_v3->patient_qual[d1.seq].encntr_id
	from
		(dummyt d1 with seq=hrts_v3->patient_cnt)
	plan d1
		where hrts_v3->patient_qual[d1.seq].facility = location_list->locations[i].display
	order by
	 	 encntr_id
	head report
		call writeLog(build2("-->inside hrts_v3 query for ",trim(location_list->locations[i].display)))
		hrts_v3->summary_cnt = (hrts_v3->summary_cnt + 1)
		stat = alterlist(hrts_v3->summary_qual,hrts_v3->summary_cnt)
		call writeLog(build2("-->hrts_v3->summary_cnt=",trim(cnvtstring(hrts_v3->summary_cnt))))
		hrts_v3->summary_qual[hrts_v3->summary_cnt].facility = trim(location_list->locations[i].display)
		hrts_v3->summary_qual[hrts_v3->summary_cnt].contact_email = trim("nchriste@covhlth.com")
		hrts_v3->summary_qual[hrts_v3->summary_cnt].hosp_name = uar_get_code_description(location_list->locations[i].location_cd)
		hrts_v3->summary_qual[hrts_v3->summary_cnt].reporting_for_date	= format(sysdate,"yyyy/mm/dd;;d")
		hrts_v3->summary_qual[hrts_v3->summary_cnt].crit_staffing_shortage_today = ^NO^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].crit_staffing_shortage_week = ^NO^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_obtain_vent_supp = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_mtn_vent_3day_supp = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_obtain_vent_meds = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_mtn_vent_3day_meds = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_obtain_n95_masks = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_mtn_n95_masks = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].reusuable_n95_masks_used = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_obtain_paprs = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_mtn_3day_paprs = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].reusable_paprs_elasto_used = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_obtain_surg_masks = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_mtn_3day_surg_masks = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_obtain_eye_protection = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_mtn_3day_eye_prot = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_obtain_single_use_gowns = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_mtn_3day_singuse_gown = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_obtain_gloves = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_mtn_3day_gloves = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_obtain_launderable_gowns = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].reusable_isolation_gowns_used = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_mtn_3day_pharyngeal_swabs = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_mtn_lab_nasal_swabs = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].able_mtn_3day_viral_trans_media = ^YES^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].ant_medical_sup_med_short = ^NO^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].staffing_shortage_details = ^^
		hrts_v3->summary_qual[hrts_v3->summary_cnt].ppe_supply_mgmt_source = ^SYSTEM^
		current_pos = 0
		current_pos_icu = 0
		current_pos_vent = 0
		current_pend = 0
		current_pend_icu = 0
		current_pend_vent = 0
		current_pos_pediatric = 0
		current_pos_pediatric_icu = 0
		current_pos_pediatric_vent = 0
		current_pend_pediatric = 0
		current_pend_pediatric_icu = 0
		current_pend_pediatric_vent = 0
		prev_day_admiss_confirmed_covid = 0
		previous_day_admission_adult_covid_confirmed_18_19 = 0
		previous_day_admission_adult_covid_confirmed_20_29 = 0
		previous_day_admission_adult_covid_confirmed_30_39 = 0
		previous_day_admission_adult_covid_confirmed_40_49 = 0
		previous_day_admission_adult_covid_confirmed_50_59 = 0
		previous_day_admission_adult_covid_confirmed_60_69 = 0
		previous_day_admission_adult_covid_confirmed_70_79 = 0
		previous_day_admission_adult_covid_confirmed_80_plus = 0
		previous_day_admission_adult_covid_confirmed_unknown_age = 0
		previous_day_admission_adult_covid_suspected = 0
		previous_day_admission_adult_covid_suspected_18_19 = 0
		previous_day_admission_adult_covid_suspected_20_29 = 0
		previous_day_admission_adult_covid_suspected_30_39 = 0
		previous_day_admission_adult_covid_suspected_40_49 = 0
		previous_day_admission_adult_covid_suspected_50_59 = 0
		previous_day_admission_adult_covid_suspected_60_69 = 0
		previous_day_admission_adult_covid_suspected_70_79 = 0
		previous_day_admission_adult_covid_suspected_80_plus = 0
		previous_day_admission_adult_covid_suspected_unknown_age = 0
		prev_day_pediatric_conf = 0
		prev_day_pediatric_susp = 0
		hospital_onset = 0
		previous_day_total_ed_visits = 0
		previous_day_covid_ed_visits = 0
		ed_or_overflow = 0
		ed_or_overflow_and_ventilated = 0
		previous_day_death_covid = 0
		prev_day_rdv_used = 0
		prev_day_rdv_inv = 0
		mechanical_adult_ventilators = 0
		mechanical_adult_vents_in_use = 0
		mechanical_ped_ventilators = 0
		mechanical_ped_vents_in_use = 0
		hosp_susp_onset = 0
	head encntr_id
		call writeLog(build2("--->analyzing encntr_id=",trim(cnvtstring(encntr_id))))
		if (hrts_v3->patient_qual[d1.seq].expired = "Y")
			call writeLog(build2("---->analyzing expired=",trim((hrts_v3->patient_qual[d1.seq].expired))))
		else
			if (hrts_v3->patient_qual[d1.seq].confirmed = "Y")
				call writeLog(build2("---->analyzing expired=",trim((hrts_v3->patient_qual[d1.seq].expired))))
				call writeLog(build2("---->analyzing confirmed=",trim((hrts_v3->patient_qual[d1.seq].confirmed))))
				current_pos = (current_pos + 1)
 
				if (hrts_v3->patient_qual[d1.seq].location_class_1 in("ICU"))
					call writeLog(build2("----->analyzing location_class_1=",trim((hrts_v3->patient_qual[d1.seq].location_class_1))))
					current_pos_icu = (current_pos_icu + 1)
				endif
 
				if (hrts_v3->patient_qual[d1.seq].prev_admission = "Y")
					call writeLog(build2("----->analyzing prev_admission=",trim((hrts_v3->patient_qual[d1.seq].prev_admission))))
					if (hrts_v3->patient_qual[d1.seq].location_class_1 in("ICU","MSU"))
						call writeLog(build2("------>analyzing location_class_1=",trim((hrts_v3->patient_qual[d1.seq].location_class_1))))
						prev_day_admiss_confirmed_covid = (prev_day_admiss_confirmed_covid + 1)
 
						call writeLog(build2("------->analyzing age=",trim(cnvtstring(hrts_v3->patient_qual[d1.seq].age_years))))
						if (hrts_v3->patient_qual[d1.seq].age_years > 0)
							stat = 0
						endif
					endif
				endif
 
				if (hrts_v3->patient_qual[d1.seq].hosp_conf_onset = "Y")
					call writeLog(build2("----->analyzing hosp_conf_onset=",trim((hrts_v3->patient_qual[d1.seq].hosp_conf_onset))))
					hospital_onset = (hospital_onset + 1)
				endif
			endif
			if (hrts_v3->patient_qual[d1.seq].suspected = "Y")
				call writeLog(build2("---->analyzing expired=",trim((hrts_v3->patient_qual[d1.seq].expired))))
				call writeLog(build2("---->analyzing suspected=",trim((hrts_v3->patient_qual[d1.seq].suspected))))
				current_pend = (current_pend + 1)
 
				if (hrts_v3->patient_qual[d1.seq].location_class_1 in("ICU"))
					call writeLog(build2("----->analyzing location_class_1=",trim((hrts_v3->patient_qual[d1.seq].location_class_1))))
					current_pend_icu = (current_pend_icu + 1)
				endif
 
				if (hrts_v3->patient_qual[d1.seq].hosp_susp_onset = "Y")
					call writeLog(build2("----->analyzing hosp_susp_onset=",trim((hrts_v3->patient_qual[d1.seq].hosp_susp_onset))))
					hosp_susp_onset = (hosp_susp_onset + 1)
				endif
			endif
		endif
	foot report
		hrts_v3->summary_qual[hrts_v3->summary_cnt].current_pos 						= current_pos
		hrts_v3->summary_qual[hrts_v3->summary_cnt].current_pos_icu 					= current_pos_icu
		hrts_v3->summary_qual[hrts_v3->summary_cnt].current_pos_vent 					= current_pos_vent
		hrts_v3->summary_qual[hrts_v3->summary_cnt].current_pend 						= current_pend
		hrts_v3->summary_qual[hrts_v3->summary_cnt].current_pend_icu		 			= current_pend_icu
		hrts_v3->summary_qual[hrts_v3->summary_cnt].current_pend_vent 					= current_pend_vent
		hrts_v3->summary_qual[hrts_v3->summary_cnt].current_pos_pediatric 				= current_pos_pediatric
		hrts_v3->summary_qual[hrts_v3->summary_cnt].current_pos_pediatric_icu 			= current_pos_pediatric_icu
		hrts_v3->summary_qual[hrts_v3->summary_cnt].current_pos_pediatric_vent 			= current_pos_pediatric_vent
		hrts_v3->summary_qual[hrts_v3->summary_cnt].current_pend_pediatric 				= current_pend_pediatric
		hrts_v3->summary_qual[hrts_v3->summary_cnt].current_pend_pediatric_icu 			= current_pend_pediatric_icu
		hrts_v3->summary_qual[hrts_v3->summary_cnt].current_pend_pediatric_vent 		= current_pend_pediatric_vent
		hrts_v3->summary_qual[hrts_v3->summary_cnt].prev_day_admiss_confirmed_covid 	= prev_day_admiss_confirmed_covid
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_confirmed_18_19
			= previous_day_admission_adult_covid_confirmed_18_19
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_confirmed_20_29
			= previous_day_admission_adult_covid_confirmed_20_29
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_confirmed_30_39
			= previous_day_admission_adult_covid_confirmed_30_39
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_confirmed_40_49
			= previous_day_admission_adult_covid_confirmed_40_49
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_confirmed_50_59
			= previous_day_admission_adult_covid_confirmed_50_59
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_confirmed_60_69
			= previous_day_admission_adult_covid_confirmed_60_69
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_confirmed_70_79
			= previous_day_admission_adult_covid_confirmed_70_79
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_confirmed_80_plus
			= previous_day_admission_adult_covid_confirmed_80_plus
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_confirmed_unknown_age
			= previous_day_admission_adult_covid_confirmed_unknown_age
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_suspected
			= previous_day_admission_adult_covid_suspected
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_suspected_18_19
			= previous_day_admission_adult_covid_suspected_18_19
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_suspected_20_29
			= previous_day_admission_adult_covid_suspected_20_29
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_suspected_30_39
			= previous_day_admission_adult_covid_suspected_30_39
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_suspected_40_49
			= previous_day_admission_adult_covid_suspected_40_49
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_suspected_50_59
			= previous_day_admission_adult_covid_suspected_50_59
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_suspected_60_69
			= previous_day_admission_adult_covid_suspected_60_69
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_suspected_70_79
			= previous_day_admission_adult_covid_suspected_70_79
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_suspected_80_plus
			= previous_day_admission_adult_covid_suspected_80_plus
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_admission_adult_covid_suspected_unknown_age
			= previous_day_admission_adult_covid_suspected_unknown_age
		hrts_v3->summary_qual[hrts_v3->summary_cnt].prev_day_pediatric_conf 			= prev_day_pediatric_conf
		hrts_v3->summary_qual[hrts_v3->summary_cnt].prev_day_pediatric_susp 			= prev_day_pediatric_susp
		hrts_v3->summary_qual[hrts_v3->summary_cnt].hospital_onset 						= hospital_onset
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_total_ed_visits 		= previous_day_total_ed_visits
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_covid_ed_visits 		= previous_day_covid_ed_visits
		hrts_v3->summary_qual[hrts_v3->summary_cnt].ed_or_overflow 						= ed_or_overflow
		hrts_v3->summary_qual[hrts_v3->summary_cnt].ed_or_overflow_and_ventilated 		= ed_or_overflow_and_ventilated
		hrts_v3->summary_qual[hrts_v3->summary_cnt].previous_day_death_covid 			= previous_day_death_covid
 
		call writeLog(build2("-->leaving hrts_v3 query for ",trim(location_list->locations[i].display)))
		call writeLog(build2("-->hrts_v3->summary_cnt=",trim(cnvtstring(hrts_v3->summary_cnt))))
 
	with nocounter,nullreport
endfor
 
 
set overall_cnt = 0
 
for (i=1 to t_rec->emerg_cnt)
	call writeLog(build2("-->t_rec->emerg_qual[i].facility=",trim(t_rec->emerg_qual[i].facility)))
	for (j=1 to t_rec->emerg_qual[i].encntr_cnt)
		if (t_rec->emerg_qual[i].encntr_qual[j].positive_ind > 0)
			call writeLog(build2("-->Adding Positive patient=",trim(cnvtstring(t_rec->emerg_qual[i].encntr_qual[j].encntr_id))))
			set t_rec->emerg_qual[i].count = (t_rec->emerg_qual[i].count + 1)
			set overall_cnt = (overall_cnt + 1)
			call writeLog(build2("-->t_rec->emerg_qual[i].count=",trim(cnvtstring(t_rec->emerg_qual[i].count))))
			call writeLog(build2("-->t_rec->emerg_qual[i].encntr_cnt=",trim(cnvtstring(t_rec->emerg_qual[i].encntr_cnt))))
		endif
	endfor
	for (j=1 to hrts_v3->summary_cnt)
		call writeLog(build2("-->checking t_rec->emerg_qual[i].facility=",trim(t_rec->emerg_qual[i].facility)))
		call writeLog(build2("-->against hrts_v3->summary_qual[j].facility=",trim(hrts_v3->summary_qual[j].facility)))
		if (t_rec->emerg_qual[i].facility = hrts_v3->summary_qual[j].facility)
			set hrts_v3->summary_qual[j].previous_day_total_ed_visits = t_rec->emerg_qual[i].encntr_cnt
			set hrts_v3->summary_qual[j].previous_day_covid_ed_visits = t_rec->emerg_qual[i].count
		endif
	endfor
endfor
 
call writeLog(build2("** Building Summary Table from Extensions"))
for (i=1 to hrts_v3->summary_cnt)
	;;copy nhsn_covid19 summary values
 
	for (j=1 to nhsn_covid19->summary_cnt)
		if (nhsn_covid19->summary_qual[j].facility = hrts_v3->summary_qual[i].facility)
			set hrts_v3->summary_qual[i].current_pos_vent = nhsn_covid19->summary_qual[j].q2_ip_confirmed_vent
			set hrts_v3->summary_qual[i].current_pend_vent = nhsn_covid19->summary_qual[j].q2_ip_suspected_vent
			set hrts_v3->summary_qual[i].mechanical_adult_ventilators = nhsn_covid19->summary_qual[j].q12_ventilator_total
			set hrts_v3->summary_qual[i].mechanical_adult_vents_in_use = nhsn_covid19->summary_qual[j].q13_ventilator_in_use
			;set hrts_v3->summary_qual[i].hospital_onset = nhsn_covid19->summary_qual[j].q3_ip_conf_los14
		endif
	endfor
 
	select into "nl:"
	from
		 (dummyt d1 with seq=hrts_v3->summary_cnt)
	    ,code_value cv1
	    ,code_value_extension cve1
	plan d1
		where hrts_v3->summary_qual[i].facility
	join cv1
	    where cv1.code_set              = t_rec->custom_code_set
	    and   cv1.definition            = trim(cnvtlower(t_rec->curprog))
	    and   cv1.active_ind            = 1
	    and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	    and   cv1.end_effective_dt_tm   >= cnvtdatetime(curdate,curtime3)
	    and   cv1.cdf_meaning           = "FACILITY"
	    and   cv1.display				= hrts_v3->summary_qual[d1.seq].facility
	join cve1
		where cve1.code_value			= cv1.code_value
		and   cve1.field_name			in(
											 "Hospital_CCN"
											,"Hospital_NPI"
											,"Hospital_AHA_ID"
											,"Hospital_NHSN_ID"
											,"Address_Street1"
											,"Address_City"
											,"Address_State"
											,"Address_Zip"
											,"TeleTracking_Id"
											,"HRTS_Facility_ID"
											)
	order by
		 cv1.code_value
		,cve1.field_name
	head report
		call writeLog(build2("->inside :",trim(hrts_v3->summary_qual[d1.seq].facility)))
	head cv1.code_value
		call writeLog(build2("-->inside :",trim(cv1.display)))
	head cve1.field_name
		call writeLog(build2("--->inside :",trim(cve1.field_name)))
		case (cve1.field_name)
			of "HRTS_Facility_ID"		:	hrts_v3->summary_qual[d1.seq].facility_id	= trim(cve1.field_value)
		endcase
	foot cv1.code_value
		call writeLog(build2("-->leaving :",trim(hrts_v3->summary_qual[d1.seq].facility)))
	foot report
		call writeLog(build2("->leaving :",trim(hrts_v3->summary_qual[d1.seq].facility)))
	with nocounter
endfor
 
 
call writeLog(build2("* END   Building HRTS v3 Data (12) *************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building HRTS v4 Data (13) *************************"))
 
for (i=1 to t2_output->cnt)
	call writeLog(build2("-->checking encntr_id=",trim(cnvtstring(t2_output->qual[i].encntr_id))))
	set t2_output->qual[i].encntr_ignore = 1
	if (t2_output->qual[i].expired_ind = 0)
		;003 if ((t2_output->qual[i].positive_ind = 1) or (t2_output->qual[i].suspected_ind = 1)) ;003
	 	if ((t2_output->qual[i].positive_ind = 1) or (t2_output->qual[i].suspected_ind = 1) 	;003
	 												or (t2_output->qual[i].flu_positive_ind = 1)) ;003
			if (t2_output->qual[i].location_class_1 in("ICU","MSU"))
				set t2_output->qual[i].encntr_ignore = 0
			endif
		endif
 
		if ((t2_output->qual[i].positive_ind = 1) or (t2_output->qual[i].suspected_ind = 1))
			if (t2_output->qual[i].location_class_1 in("ED","EB"))
				if (t2_output->qual[i].pso in("PSO Admit to Inpatient"))
					set t2_output->qual[i].encntr_ignore = 0
				endif
			endif
		endif
 
		if ((t2_output->qual[i].ventilator_ind > 0) and (t2_output->qual[i].covenant_vent_stock_ind > 0))
			set t2_output->qual[i].encntr_ignore = 0
		endif
	elseif (t2_output->qual[i].expired_ind = 1)
		set t2_output->qual[i].encntr_ignore = 0
	endif
 
	call writeLog(build2("--->checking encntr_ignore=",trim(cnvtstring(t2_output->qual[i].encntr_ignore))))
	if (t2_output->qual[i].encntr_ignore = 0)
		set hrts_v4->patient_cnt = (hrts_v4->patient_cnt + 1)
		set stat = alterlist(hrts_v4->patient_qual,hrts_v4->patient_cnt)
 
		call writeLog(build2("---->adding hrts_v4->patient_cnt=",trim(cnvtstring(hrts_v4->patient_cnt))))
 
		set hrts_v4->patient_qual[hrts_v4->patient_cnt].encntr_id = t2_output->qual[i].encntr_id
		set hrts_v4->patient_qual[hrts_v4->patient_cnt].person_id = t2_output->qual[i].person_id
		set hrts_v4->patient_qual[hrts_v4->patient_cnt].patient_name = t2_output->qual[i].patient_name
		set hrts_v4->patient_qual[hrts_v4->patient_cnt].dob = t2_output->qual[i].dob
		set hrts_v4->patient_qual[hrts_v4->patient_cnt].age = t2_output->qual[i].age
		set hrts_v4->patient_qual[hrts_v4->patient_cnt].age_years =
													cnvtint((datetimediff(cnvtdatetime(curdate,0), t2_output->qual[i].date_of_birth)/365.25))
		set hrts_v4->patient_qual[hrts_v4->patient_cnt].encntr_type = t2_output->qual[i].encntr_type
		set hrts_v4->patient_qual[hrts_v4->patient_cnt].facility = t2_output->qual[i].facility
		set hrts_v4->patient_qual[hrts_v4->patient_cnt].unit = t2_output->qual[i].unit
		set hrts_v4->patient_qual[hrts_v4->patient_cnt].room_bed = t2_output->qual[i].room_bed
		set hrts_v4->patient_qual[hrts_v4->patient_cnt].fin = t2_output->qual[i].fin
		set hrts_v4->patient_qual[hrts_v4->patient_cnt].los_days = t2_output->qual[i].los_days
		if ((t2_output->qual[i].expired_ind = 1) and (t2_output->qual[i].positive_ind = 1))
			set hrts_v4->patient_qual[hrts_v4->patient_cnt].expired = "Y"
		endif
		if (t2_output->qual[i].covid19_order > " ")
			set hrts_v4->patient_qual[hrts_v4->patient_cnt].covid19_order = concat(
																					t2_output->qual[i].covid19_order
																					," ("
																					,t2_output->qual[i].covid19_order_dt_tm
																					,")"
																					)
		endif
		if (t2_output->qual[i].covid19_result > " ")
			set hrts_v4->patient_qual[hrts_v4->patient_cnt].covid19_result = concat(
																					t2_output->qual[i].covid19_result
																					," ("
																					,t2_output->qual[i].covid19_result_dt_tm
																					,")"
																					)
		endif
 
		set hrts_v4->patient_qual[hrts_v4->patient_cnt].diagnosis = t2_output->qual[i].diagnosis
 
		if (t2_output->qual[i].pso in("PSO Admit to Inpatient"))
			set hrts_v4->patient_qual[hrts_v4->patient_cnt].ip_pso = "Y"
		endif
 
		set hrts_v4->patient_qual[hrts_v4->patient_cnt].location_class_1 = t2_output->qual[i].location_class_1
 
		if ((t2_output->qual[i].suspected_ind = 1) and (t2_output->qual[i].positive_ind = 0))
			set hrts_v4->patient_qual[hrts_v4->patient_cnt].suspected = "Y"
		endif
 
		if (t2_output->qual[i].positive_ind = 1)
			set hrts_v4->patient_qual[hrts_v4->patient_cnt].confirmed = "Y"
		endif
 
		if (t2_output->qual[i].ventilator_ind > 0)
			if (t2_output->qual[i].ventilator_ind = 1)
				set hrts_v4->patient_qual[hrts_v4->patient_cnt].ventilator = "I"
			elseif (t2_output->qual[i].ventilator_ind = 2)
				set hrts_v4->patient_qual[hrts_v4->patient_cnt].ventilator = "N"
			endif
			set hrts_v4->patient_qual[hrts_v4->patient_cnt].ventilator_model = t2_output->qual[i].ventilator_model
			set hrts_v4->patient_qual[hrts_v4->patient_cnt].ventilator_result = t2_output->qual[i].ventilator_type
			if (t2_output->qual[i].covenant_vent_stock_ind = 1)
				set hrts_v4->patient_qual[hrts_v4->patient_cnt].covenant_vent_stock = "Y"
			endif
		endif
 
		if (t2_output->qual[i].previous_admission_ind = 1)
			set hrts_v4->patient_qual[hrts_v4->patient_cnt].prev_admission = "Y"
		endif
 
		if (t2_output->qual[i].previous_onset_ind = 1)
			set hrts_v4->patient_qual[hrts_v4->patient_cnt].prev_onset = "Y"
		endif
 
		if (t2_output->qual[i].hosp_conf_onset = 1)
			set hrts_v4->patient_qual[hrts_v4->patient_cnt].hosp_conf_onset = "Y"
		endif
 
		if (t2_output->qual[i].hosp_susp_onset = 1)
			set hrts_v4->patient_qual[hrts_v4->patient_cnt].hosp_susp_onset = "Y"
		endif
 
		/*start 002*/
		if (t2_output->qual[i].flu_positive_ind = 1)
			set hrts_v4->patient_qual[hrts_v4->patient_cnt].flu_confirmed = "Y"
		endif
 
		if (t2_output->qual[i].flu_positive_ind = 1)
			set hrts_v4->patient_qual[hrts_v4->patient_cnt].flu_result = "Y"
		endif
 
		if (t2_output->qual[i].flu_result > " ")
			set hrts_v4->patient_qual[hrts_v4->patient_cnt].flu_result = concat(
																					t2_output->qual[i].flu_result
																					," ("
																					,t2_output->qual[i].flu_result_dt_tm
																					,")"
																					)
		endif
 
		set hrts_v4->patient_qual[hrts_v4->patient_cnt].inpatient_dt_tm = t2_output->qual[i].inpatient_dt_tm_dq8
		set hrts_v4->patient_qual[hrts_v4->patient_cnt].flu_result_dt_tm = t2_output->qual[i].flu_onset_dt_tm_dq8
 
		/*end 002*/
 
		;start 011
		if (t2_output->qual[i].covid19_vaccine_ind = 1)
			set hrts_v4->patient_qual[hrts_v4->patient_cnt].covid19_vaccine = "Y"
		endif
		;end 011
 
	endif ;end if encntr_ignore = 0
 
	set t2_output->qual[i].encntr_ignore = 1
endfor
 
call writeLog(build2("** Building Summary Table"))
for (i=1 to location_list->location_cnt)
	call writeLog(build2("->location:",trim(location_list->locations[i].display)))
	select into "nl:"
		encntr_id				= hrts_v4->patient_qual[d1.seq].encntr_id
	from
		(dummyt d1 with seq=hrts_v4->patient_cnt)
	plan d1
		where hrts_v4->patient_qual[d1.seq].facility = location_list->locations[i].display
	order by
	 	 encntr_id
	head report
		call writeLog(build2("-->inside hrts_v4 query for ",trim(location_list->locations[i].display)))
		hrts_v4->summary_cnt = (hrts_v4->summary_cnt + 1)
		stat = alterlist(hrts_v4->summary_qual,hrts_v4->summary_cnt)
		call writeLog(build2("-->hrts_v4->summary_cnt=",trim(cnvtstring(hrts_v4->summary_cnt))))
		hrts_v4->summary_qual[hrts_v4->summary_cnt].facility = trim(location_list->locations[i].display)
		hrts_v4->summary_qual[hrts_v4->summary_cnt].contact_email = trim("nchriste@covhlth.com")
		hrts_v4->summary_qual[hrts_v4->summary_cnt].hosp_name = uar_get_code_description(location_list->locations[i].location_cd)
		hrts_v4->summary_qual[hrts_v4->summary_cnt].reporting_for_date	= format(sysdate,"yyyy/mm/dd;;d")
		hrts_v4->summary_qual[hrts_v4->summary_cnt].crit_staffing_shortage_today = ^NO^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].crit_staffing_shortage_week = ^NO^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_obtain_vent_supp = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_mtn_vent_3day_supp = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_obtain_vent_meds = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_mtn_vent_3day_meds = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_obtain_n95_masks = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_mtn_n95_masks = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].reusuable_n95_masks_used = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_obtain_paprs = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_mtn_3day_paprs = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].reusable_paprs_elasto_used = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_obtain_surg_masks = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_mtn_3day_surg_masks = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_obtain_eye_protection = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_mtn_3day_eye_prot = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_obtain_single_use_gowns = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_mtn_3day_singuse_gown = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_obtain_gloves = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_mtn_3day_gloves = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_obtain_launderable_gowns = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].reusable_isolation_gowns_used = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_mtn_3day_pharyngeal_swabs = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_mtn_lab_nasal_swabs = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].able_mtn_3day_viral_trans_media = ^YES^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].ant_medical_sup_med_short = ^NO^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].staffing_shortage_details = ^^
		hrts_v4->summary_qual[hrts_v4->summary_cnt].ppe_supply_mgmt_source = ^SYSTEM^
		current_pos = 0
		current_pos_icu = 0
		current_pos_vent = 0
		current_pend = 0
		current_pend_icu = 0
		current_pend_vent = 0
		current_pos_pediatric = 0
		current_pos_pediatric_icu = 0
		current_pos_pediatric_vent = 0
		current_pend_pediatric = 0
		current_pend_pediatric_icu = 0
		current_pend_pediatric_vent = 0
		prev_day_admiss_confirmed_covid = 0
		previous_day_admission_adult_covid_confirmed_18_19 = 0
		previous_day_admission_adult_covid_confirmed_20_29 = 0
		previous_day_admission_adult_covid_confirmed_30_39 = 0
		previous_day_admission_adult_covid_confirmed_40_49 = 0
		previous_day_admission_adult_covid_confirmed_50_59 = 0
		previous_day_admission_adult_covid_confirmed_60_69 = 0
		previous_day_admission_adult_covid_confirmed_70_79 = 0
		previous_day_admission_adult_covid_confirmed_80_plus = 0
		previous_day_admission_adult_covid_confirmed_unknown_age = 0
		previous_day_admission_adult_covid_suspected = 0
		previous_day_admission_adult_covid_suspected_18_19 = 0
		previous_day_admission_adult_covid_suspected_20_29 = 0
		previous_day_admission_adult_covid_suspected_30_39 = 0
		previous_day_admission_adult_covid_suspected_40_49 = 0
		previous_day_admission_adult_covid_suspected_50_59 = 0
		previous_day_admission_adult_covid_suspected_60_69 = 0
		previous_day_admission_adult_covid_suspected_70_79 = 0
		previous_day_admission_adult_covid_suspected_80_plus = 0
		previous_day_admission_adult_covid_suspected_unknown_age = 0
		prev_day_pediatric_conf = 0
		prev_day_pediatric_susp = 0
		hospital_onset = 0
		previous_day_total_ed_visits = 0
		previous_day_covid_ed_visits = 0
		ed_or_overflow = 0
		ed_or_overflow_and_ventilated = 0
		previous_day_death_covid = 0
		prev_day_rdv_used = 0
		prev_day_rdv_inv = 0
		mechanical_adult_ventilators = 0
		mechanical_adult_vents_in_use = 0
		mechanical_ped_ventilators = 0
		mechanical_ped_vents_in_use = 0
		hosp_susp_onset = 0
		current_pos_flu = 0
		prev_day_flu_admiss = 0
		current_pos_flu_icu = 0
		current_pos_flu_covid = 0
		prev_day_flu_deaths = 0
		prev_day_flu_covid_deaths = 0
		positive_patients_with_vaccine = 0 ;011
	head encntr_id
		call writeLog(build2("--->analyzing encntr_id=",trim(cnvtstring(encntr_id))))
		if (hrts_v4->patient_qual[d1.seq].expired = "Y")
			call writeLog(build2("---->analyzing expired=",trim((hrts_v4->patient_qual[d1.seq].expired))))
			if (hrts_v4->patient_qual[d1.seq].flu_confirmed = "Y")
				prev_day_flu_deaths = (prev_day_flu_deaths + 1)
				if (hrts_v4->patient_qual[d1.seq].confirmed = "Y")
					prev_day_flu_covid_deaths = (prev_day_flu_covid_deaths + 1)
				endif
			endif
			/*start 008*/
			if (hrts_v4->patient_qual[d1.seq].confirmed = "Y")
				previous_day_death_covid = (previous_day_death_covid + 1)
			endif
			/*end 008*/
		else
			if (hrts_v4->patient_qual[d1.seq].confirmed = "Y")
				call writeLog(build2("---->analyzing expired=",trim((hrts_v4->patient_qual[d1.seq].expired))))
				call writeLog(build2("---->analyzing confirmed=",trim((hrts_v4->patient_qual[d1.seq].confirmed))))
				current_pos = (current_pos + 1)
 
				if (hrts_v4->patient_qual[d1.seq].location_class_1 in("ICU"))
					call writeLog(build2("----->analyzing location_class_1=",trim((hrts_v4->patient_qual[d1.seq].location_class_1))))
					current_pos_icu = (current_pos_icu + 1)
				endif
 
				if (hrts_v4->patient_qual[d1.seq].prev_admission = "Y")
					call writeLog(build2("----->analyzing prev_admission=",trim((hrts_v4->patient_qual[d1.seq].prev_admission))))
					if (hrts_v4->patient_qual[d1.seq].location_class_1 in("ICU","MSU"))
						call writeLog(build2("------>analyzing location_class_1=",trim((hrts_v4->patient_qual[d1.seq].location_class_1))))
						prev_day_admiss_confirmed_covid = (prev_day_admiss_confirmed_covid + 1)
 
						call writeLog(build2("------->analyzing age=",trim(cnvtstring(hrts_v4->patient_qual[d1.seq].age_years))))
						if (hrts_v4->patient_qual[d1.seq].age_years > 0)
							stat = 0
						endif
					endif
				endif
 
				if (hrts_v4->patient_qual[d1.seq].hosp_conf_onset = "Y")
					call writeLog(build2("----->analyzing hosp_conf_onset=",trim((hrts_v4->patient_qual[d1.seq].hosp_conf_onset))))
					hospital_onset = (hospital_onset + 1)
				endif
 
				;start 011
				if (hrts_v4->patient_qual[d1.seq].covid19_vaccine = "Y")
				 if (hrts_v4->patient_qual[d1.seq].location_class_1 in("ICU","MSU"))
					call writeLog(build2("----->analyzing covicovid19_vaccine=",trim((hrts_v4->patient_qual[d1.seq].covicovid19_vaccine))))
					positive_patients_with_vaccine = (positive_patients_with_vaccine + 1)
				 endif
				endif
				;end 011
 
			endif
			if (hrts_v4->patient_qual[d1.seq].suspected = "Y")
				call writeLog(build2("---->analyzing expired=",trim((hrts_v4->patient_qual[d1.seq].expired))))
				call writeLog(build2("---->analyzing suspected=",trim((hrts_v4->patient_qual[d1.seq].suspected))))
				current_pend = (current_pend + 1)
 
				if (hrts_v4->patient_qual[d1.seq].location_class_1 in("ICU"))
					call writeLog(build2("----->analyzing location_class_1=",trim((hrts_v4->patient_qual[d1.seq].location_class_1))))
					current_pend_icu = (current_pend_icu + 1)
				endif
 
				if (hrts_v4->patient_qual[d1.seq].hosp_susp_onset = "Y")
					call writeLog(build2("----->analyzing hosp_susp_onset=",trim((hrts_v4->patient_qual[d1.seq].hosp_susp_onset))))
					hosp_susp_onset = (hosp_susp_onset + 1)
				endif
			endif
			/*start 003*/
			call writeLog(build2("--->analyzing flu data"))
			if (hrts_v4->patient_qual[d1.seq].location_class_1 in("ICU","MSU"))
				call writeLog(build2("------>analyzing location_class_1=",trim((hrts_v4->patient_qual[d1.seq].location_class_1))))
				if (hrts_v4->patient_qual[d1.seq].flu_confirmed = "Y")
					call writeLog(build2("------>analyzing flu_confirmed=",trim((hrts_v4->patient_qual[d1.seq].flu_confirmed))))
					call writeLog(build2("------>analyzing prev_admission=",trim((hrts_v4->patient_qual[d1.seq].prev_admission))))
 
					current_pos_flu = (current_pos_flu + 1)
 
					if (hrts_v4->patient_qual[d1.seq].prev_admission = "Y")
						if (hrts_v4->patient_qual[d1.seq].flu_result_dt_tm < hrts_v4->patient_qual[d1.seq].inpatient_dt_tm)
							prev_day_flu_admiss = (prev_day_flu_admiss + 1)
						endif
					endif
					if (hrts_v4->patient_qual[d1.seq].location_class_1 in("ICU"))
						current_pos_flu_icu = (current_pos_flu_icu + 1)
					endif
					if (hrts_v4->patient_qual[d1.seq].confirmed = "Y")
						current_pos_flu_covid = (current_pos_flu_covid + 1)
					endif
				endif
			endif
			/*end 003*/
		endif
	foot report
		hrts_v4->summary_qual[hrts_v4->summary_cnt].current_pos 						= current_pos
		hrts_v4->summary_qual[hrts_v4->summary_cnt].current_pos_icu 					= current_pos_icu
		hrts_v4->summary_qual[hrts_v4->summary_cnt].current_pos_vent 					= current_pos_vent
		hrts_v4->summary_qual[hrts_v4->summary_cnt].current_pend 						= current_pend
		hrts_v4->summary_qual[hrts_v4->summary_cnt].current_pend_icu		 			= current_pend_icu
		hrts_v4->summary_qual[hrts_v4->summary_cnt].current_pend_vent 					= current_pend_vent
		hrts_v4->summary_qual[hrts_v4->summary_cnt].current_pos_pediatric 				= current_pos_pediatric
		hrts_v4->summary_qual[hrts_v4->summary_cnt].current_pos_pediatric_icu 			= current_pos_pediatric_icu
		hrts_v4->summary_qual[hrts_v4->summary_cnt].current_pos_pediatric_vent 			= current_pos_pediatric_vent
		hrts_v4->summary_qual[hrts_v4->summary_cnt].current_pend_pediatric 				= current_pend_pediatric
		hrts_v4->summary_qual[hrts_v4->summary_cnt].current_pend_pediatric_icu 			= current_pend_pediatric_icu
		hrts_v4->summary_qual[hrts_v4->summary_cnt].current_pend_pediatric_vent 		= current_pend_pediatric_vent
		hrts_v4->summary_qual[hrts_v4->summary_cnt].prev_day_admiss_confirmed_covid 	= prev_day_admiss_confirmed_covid
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_confirmed_18_19
			= previous_day_admission_adult_covid_confirmed_18_19
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_confirmed_20_29
			= previous_day_admission_adult_covid_confirmed_20_29
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_confirmed_30_39
			= previous_day_admission_adult_covid_confirmed_30_39
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_confirmed_40_49
			= previous_day_admission_adult_covid_confirmed_40_49
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_confirmed_50_59
			= previous_day_admission_adult_covid_confirmed_50_59
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_confirmed_60_69
			= previous_day_admission_adult_covid_confirmed_60_69
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_confirmed_70_79
			= previous_day_admission_adult_covid_confirmed_70_79
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_confirmed_80_plus
			= previous_day_admission_adult_covid_confirmed_80_plus
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_confirmed_unknown_age
			= previous_day_admission_adult_covid_confirmed_unknown_age
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_suspected
			= previous_day_admission_adult_covid_suspected
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_suspected_18_19
			= previous_day_admission_adult_covid_suspected_18_19
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_suspected_20_29
			= previous_day_admission_adult_covid_suspected_20_29
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_suspected_30_39
			= previous_day_admission_adult_covid_suspected_30_39
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_suspected_40_49
			= previous_day_admission_adult_covid_suspected_40_49
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_suspected_50_59
			= previous_day_admission_adult_covid_suspected_50_59
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_suspected_60_69
			= previous_day_admission_adult_covid_suspected_60_69
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_suspected_70_79
			= previous_day_admission_adult_covid_suspected_70_79
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_suspected_80_plus
			= previous_day_admission_adult_covid_suspected_80_plus
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_admission_adult_covid_suspected_unknown_age
			= previous_day_admission_adult_covid_suspected_unknown_age
		hrts_v4->summary_qual[hrts_v4->summary_cnt].prev_day_pediatric_conf 			= prev_day_pediatric_conf
		hrts_v4->summary_qual[hrts_v4->summary_cnt].prev_day_pediatric_susp 			= prev_day_pediatric_susp
		hrts_v4->summary_qual[hrts_v4->summary_cnt].hospital_onset 						= hospital_onset
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_total_ed_visits 		= previous_day_total_ed_visits
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_covid_ed_visits 		= previous_day_covid_ed_visits
		hrts_v4->summary_qual[hrts_v4->summary_cnt].ed_or_overflow 						= ed_or_overflow
		hrts_v4->summary_qual[hrts_v4->summary_cnt].ed_or_overflow_and_ventilated 		= ed_or_overflow_and_ventilated
		hrts_v4->summary_qual[hrts_v4->summary_cnt].previous_day_death_covid 			= previous_day_death_covid
		hrts_v4->summary_qual[hrts_v4->summary_cnt].current_pos_flu 					= current_pos_flu
		hrts_v4->summary_qual[hrts_v4->summary_cnt].prev_day_flu_admiss 				= prev_day_flu_admiss
		hrts_v4->summary_qual[hrts_v4->summary_cnt].current_pos_flu_icu 				= current_pos_flu_icu
		hrts_v4->summary_qual[hrts_v4->summary_cnt].current_pos_flu_covid 				= current_pos_flu_covid
		hrts_v4->summary_qual[hrts_v4->summary_cnt].prev_day_flu_deaths 				= prev_day_flu_deaths
		hrts_v4->summary_qual[hrts_v4->summary_cnt].prev_day_flu_covid_deaths 			= prev_day_flu_covid_deaths
		hrts_v4->summary_qual[hrts_v4->summary_cnt].positive_patients_with_vaccine 		= positive_patients_with_vaccine ;011
		call writeLog(build2("-->leaving hrts_v4 query for ",trim(location_list->locations[i].display)))
		call writeLog(build2("-->hrts_v4->summary_cnt=",trim(cnvtstring(hrts_v4->summary_cnt))))
	with nocounter,nullreport
endfor
 
 
set overall_cnt = 0
 
for (i=1 to t_rec->emerg_cnt)
	call writeLog(build2("-->t_rec->emerg_qual[i].facility=",trim(t_rec->emerg_qual[i].facility)))
	for (j=1 to t_rec->emerg_qual[i].encntr_cnt)
		if (t_rec->emerg_qual[i].encntr_qual[j].positive_ind > 0)
			call writeLog(build2("-->Adding Positive patient=",trim(cnvtstring(t_rec->emerg_qual[i].encntr_qual[j].encntr_id))))
			set t_rec->emerg_qual[i].count = (t_rec->emerg_qual[i].count + 1)
			set overall_cnt = (overall_cnt + 1)
			call writeLog(build2("-->t_rec->emerg_qual[i].count=",trim(cnvtstring(t_rec->emerg_qual[i].count))))
			call writeLog(build2("-->t_rec->emerg_qual[i].encntr_cnt=",trim(cnvtstring(t_rec->emerg_qual[i].encntr_cnt))))
		endif
	endfor
	for (j=1 to hrts_v4->summary_cnt)
		call writeLog(build2("-->checking t_rec->emerg_qual[i].facility=",trim(t_rec->emerg_qual[i].facility)))
		call writeLog(build2("-->against hrts_v4->summary_qual[j].facility=",trim(hrts_v4->summary_qual[j].facility)))
		if (t_rec->emerg_qual[i].facility = hrts_v4->summary_qual[j].facility)
			set hrts_v4->summary_qual[j].previous_day_total_ed_visits = t_rec->emerg_qual[i].encntr_cnt
			set hrts_v4->summary_qual[j].previous_day_covid_ed_visits = t_rec->emerg_qual[i].count
		endif
	endfor
endfor
 
call writeLog(build2("** Building Summary Table from Extensions"))
for (i=1 to hrts_v4->summary_cnt)
	;;copy nhsn_covid19 summary values
 
	for (j=1 to nhsn_covid19->summary_cnt)
		if (nhsn_covid19->summary_qual[j].facility = hrts_v4->summary_qual[i].facility)
			set hrts_v4->summary_qual[i].current_pos = nhsn_covid19->summary_qual[j].q1_ip_confirmed ;001
			set hrts_v4->summary_qual[i].current_pend = (nhsn_covid19->summary_qual[j].q1_total - hrts_v4->summary_qual[i].current_pos);005
			set hrts_v4->summary_qual[i].current_pos_vent = nhsn_covid19->summary_qual[j].q2_ip_confirmed_vent
			set hrts_v4->summary_qual[i].current_pend_vent = nhsn_covid19->summary_qual[j].q2_ip_suspected_vent
			set hrts_v4->summary_qual[i].mechanical_adult_ventilators = nhsn_covid19->summary_qual[j].q12_ventilator_total
			set hrts_v4->summary_qual[i].mechanical_adult_vents_in_use = nhsn_covid19->summary_qual[j].q13_ventilator_in_use
			;set hrts_v4->summary_qual[i].hospital_onset = nhsn_covid19->summary_qual[j].q3_ip_conf_los14
			;set hrts_v4->summary_qual[i].ed_or_overflow = nhsn_covid19->summary_qual[j].q4_ed_of_conf_susp_wait ;004
			set hrts_v4->summary_qual[i].ed_or_overflow = nhsn_covid19->summary_qual[j].q4_ed_of_conf_susp_wait ;004
			set hrts_v4->summary_qual[i].previous_day_death_covid = nhsn_covid19->summary_qual[j].q6_disch_expired ;008
			set nhsn_covid19->summary_qual[j].q3_ip_conf_los14 = hrts_v4->summary_qual[i].hospital_onset ;006
		endif
	endfor
 
	select into "nl:"
	from
		 (dummyt d1 with seq=hrts_v4->summary_cnt)
	    ,code_value cv1
	    ,code_value_extension cve1
	plan d1
		where hrts_v4->summary_qual[i].facility
	join cv1
	    where cv1.code_set              = t_rec->custom_code_set
	    and   cv1.definition            = trim(cnvtlower(t_rec->curprog))
	    and   cv1.active_ind            = 1
	    and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	    and   cv1.end_effective_dt_tm   >= cnvtdatetime(curdate,curtime3)
	    and   cv1.cdf_meaning           = "FACILITY"
	    and   cv1.display				= hrts_v4->summary_qual[d1.seq].facility
	join cve1
		where cve1.code_value			= cv1.code_value
		and   cve1.field_name			in(
											 "Hospital_CCN"
											,"Hospital_NPI"
											,"Hospital_AHA_ID"
											,"Hospital_NHSN_ID"
											,"Address_Street1"
											,"Address_City"
											,"Address_State"
											,"Address_Zip"
											,"TeleTracking_Id"
											,"HRTS_Facility_ID"
											)
	order by
		 cv1.code_value
		,cve1.field_name
	head report
		call writeLog(build2("->inside :",trim(hrts_v4->summary_qual[d1.seq].facility)))
	head cv1.code_value
		call writeLog(build2("-->inside :",trim(cv1.display)))
	head cve1.field_name
		call writeLog(build2("--->inside :",trim(cve1.field_name)))
		case (cve1.field_name)
			of "HRTS_Facility_ID"		:	hrts_v4->summary_qual[d1.seq].facility_id	= trim(cve1.field_value)
		endcase
	foot cv1.code_value
		call writeLog(build2("-->leaving :",trim(hrts_v4->summary_qual[d1.seq].facility)))
	foot report
		call writeLog(build2("->leaving :",trim(hrts_v4->summary_qual[d1.seq].facility)))
	with nocounter
endfor
 
 
call writeLog(build2("* END   Building HRTS v4 Data (13) *************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building zzHRTSv1 Data (10) ************************"))
 
for (i=1 to t_output->cnt)
	call writeLog(build2("-->checking encntr_id=",trim(cnvtstring(t_output->qual[i].encntr_id))))
	set t_output->qual[i].encntr_ignore = 1
	if (t_output->qual[i].expired_ind = 0)
		if ((t_output->qual[i].positive_ind = 1) or (t_output->qual[i].suspected_ind = 1))
			if (t_output->qual[i].location_class_1 in("ICU","MSU"))
				set t_output->qual[i].encntr_ignore = 0
			endif
		endif
 
		if ((t_output->qual[i].positive_ind = 1) or (t_output->qual[i].suspected_ind = 1))
			if (t_output->qual[i].location_class_1 in("ED","EB"))
				if (t_output->qual[i].pso in("PSO Admit to Inpatient"))
					set t_output->qual[i].encntr_ignore = 0
				endif
			endif
		endif
 
		if ((t_output->qual[i].ventilator_ind > 0) and (t_output->qual[i].covenant_vent_stock_ind > 0))
			set t_output->qual[i].encntr_ignore = 0
		endif
	elseif (t_output->qual[i].expired_ind = 1)
		set t_output->qual[i].encntr_ignore = 0
	endif
 
	call writeLog(build2("--->checking encntr_ignore=",trim(cnvtstring(t_output->qual[i].encntr_ignore))))
	if (t_output->qual[i].encntr_ignore = 0)
		set hrts_0806->patient_cnt = (hrts_0806->patient_cnt + 1)
		set stat = alterlist(hrts_0806->patient_qual,hrts_0806->patient_cnt)
 
		call writeLog(build2("---->adding hrts_0806->patient_cnt=",trim(cnvtstring(hrts_0806->patient_cnt))))
 
		set hrts_0806->patient_qual[hrts_0806->patient_cnt].encntr_id = t_output->qual[i].encntr_id
		set hrts_0806->patient_qual[hrts_0806->patient_cnt].person_id = t_output->qual[i].person_id
		set hrts_0806->patient_qual[hrts_0806->patient_cnt].patient_name = t_output->qual[i].patient_name
		set hrts_0806->patient_qual[hrts_0806->patient_cnt].encntr_type = t_output->qual[i].encntr_type
		set hrts_0806->patient_qual[hrts_0806->patient_cnt].facility = t_output->qual[i].facility
		set hrts_0806->patient_qual[hrts_0806->patient_cnt].unit = t_output->qual[i].unit
		set hrts_0806->patient_qual[hrts_0806->patient_cnt].room_bed = t_output->qual[i].room_bed
		set hrts_0806->patient_qual[hrts_0806->patient_cnt].fin = t_output->qual[i].fin
		set hrts_0806->patient_qual[hrts_0806->patient_cnt].los_days = t_output->qual[i].los_days
		if ((t_output->qual[i].expired_ind = 1) and (t_output->qual[i].positive_ind = 1))
			set hrts_0806->patient_qual[hrts_0806->patient_cnt].expired = "Y"
		endif
		if (t_output->qual[i].covid19_order > " ")
			set hrts_0806->patient_qual[hrts_0806->patient_cnt].covid19_order = concat(
																					t_output->qual[i].covid19_order
																					," ("
																					,t_output->qual[i].covid19_order_dt_tm
																					,")"
																					)
		endif
		if (t_output->qual[i].covid19_result > " ")
			set hrts_0806->patient_qual[hrts_0806->patient_cnt].covid19_result = concat(
																					t_output->qual[i].covid19_result
																					," ("
																					,t_output->qual[i].covid19_result_dt_tm
																					,")"
																					)
		endif
 
		set hrts_0806->patient_qual[hrts_0806->patient_cnt].diagnosis = t_output->qual[i].diagnosis
 
		if (t_output->qual[i].pso in("PSO Admit to Inpatient"))
			set hrts_0806->patient_qual[hrts_0806->patient_cnt].ip_pso = "Y"
		endif
 
		set hrts_0806->patient_qual[hrts_0806->patient_cnt].location_class_1 = t_output->qual[i].location_class_1
 
		if ((t_output->qual[i].suspected_ind = 1) and (t_output->qual[i].positive_ind = 0))
			set hrts_0806->patient_qual[hrts_0806->patient_cnt].suspected = "Y"
		endif
 
		if (t_output->qual[i].positive_ind = 1)
			set hrts_0806->patient_qual[hrts_0806->patient_cnt].confirmed = "Y"
		endif
 
		if (t_output->qual[i].ventilator_ind > 0)
			if (t_output->qual[i].ventilator_ind = 1)
				set hrts_0806->patient_qual[hrts_0806->patient_cnt].ventilator = "I"
			elseif (t_output->qual[i].ventilator_ind = 2)
				set hrts_0806->patient_qual[hrts_0806->patient_cnt].ventilator = "N"
			endif
			set hrts_0806->patient_qual[hrts_0806->patient_cnt].ventilator_model = t_output->qual[i].ventilator_model
			set hrts_0806->patient_qual[hrts_0806->patient_cnt].ventilator_result = t_output->qual[i].ventilator_type
			if (t_output->qual[i].covenant_vent_stock_ind = 1)
				set hrts_0806->patient_qual[hrts_0806->patient_cnt].covenant_vent_stock = "Y"
			endif
		endif
 
		if (t_output->qual[i].previous_admission_ind = 1)
			set hrts_0806->patient_qual[hrts_0806->patient_cnt].prev_admission = "Y"
		endif
 
		if (t_output->qual[i].previous_onset_ind = 1)
			set hrts_0806->patient_qual[hrts_0806->patient_cnt].prev_onset = "Y"
		endif
 
	endif ;end if encntr_ignore = 0
 
	set t_output->qual[i].encntr_ignore = 1
endfor
 
call writeLog(build2("** Building Summary Table"))
for (i=1 to location_list->location_cnt)
	call writeLog(build2("->location:",trim(location_list->locations[i].display)))
	select into "nl:"
		encntr_id				= hrts_0806->patient_qual[d1.seq].encntr_id
	from
		(dummyt d1 with seq=hrts_0806->patient_cnt)
	plan d1
		where hrts_0806->patient_qual[d1.seq].facility = location_list->locations[i].display
	order by
	 	 encntr_id
	head report
		call writeLog(build2("-->inside nshn query for ",trim(location_list->locations[i].display)))
		hrts_0806->summary_cnt = (hrts_0806->summary_cnt + 1)
		stat = alterlist(hrts_0806->summary_qual,hrts_0806->summary_cnt)
		hrts_0806->summary_qual[hrts_0806->summary_cnt].facility = trim(location_list->locations[i].display)
		call writeLog(build2("-->hrts_0806->summary_cnt=",trim(cnvtstring(hrts_0806->summary_cnt))))
 
		hrts_0806->summary_qual[hrts_0806->summary_cnt].reporting_for_date	= format(sysdate,"mm-dd-yyyy;;d")
 
	head encntr_id
		call writeLog(build2("--->analyzing encntr_id=",trim(cnvtstring(encntr_id))))
	with nocounter,nullreport
endfor
 
 
call writeLog(build2("** Building Summary Table from Extensions"))
 
for (i=1 to hrts_0806->summary_cnt)
		select into "nl:"
	from
		 (dummyt d1 with seq=hrts_0806->summary_cnt)
	    ,code_value cv1
	    ,code_value_extension cve1
	plan d1
		where hrts_0806->summary_qual[i].facility
	join cv1
	    where cv1.code_set              = t_rec->custom_code_set
	    and   cv1.definition            = trim(cnvtlower(t_rec->curprog))
	    and   cv1.active_ind            = 1
	    and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	    and   cv1.end_effective_dt_tm   >= cnvtdatetime(curdate,curtime3)
	    and   cv1.cdf_meaning           = "FACILITY"
	    and   cv1.display				= hrts_0806->summary_qual[d1.seq].facility
	join cve1
		where cve1.code_value			= cv1.code_value
		and   cve1.field_name			in(
											 "Hospital_CCN"
											,"Hospital_NPI"
											,"Hospital_AHA_ID"
											,"Hospital_NHSN_ID"
											,"Address_Street1"
											,"Address_City"
											,"Address_State"
											,"Address_Zip"
											,"TeleTracking_Id"
											)
	order by
		 cv1.code_value
		,cve1.field_name
	head report
		call writeLog(build2("->inside :",trim(hrts_0806->summary_qual[d1.seq].facility)))
	head cv1.code_value
		call writeLog(build2("-->inside :",trim(cv1.display)))
	head cve1.field_name
		call writeLog(build2("--->inside :",trim(cve1.field_name)))
		case (cve1.field_name)
			of "TeleTracking_Id"		:	hrts_0806->summary_qual[d1.seq].facility_id	= trim(cve1.field_value)
		endcase
	foot cv1.code_value
		call writeLog(build2("-->leaving :",trim(hrts_0806->summary_qual[d1.seq].facility)))
	foot report
		call writeLog(build2("->leaving :",trim(hrts_0806->summary_qual[d1.seq].facility)))
	with nocounter
endfor
 
 
call writeLog(build2("* END   Building zzHRTSv1 Data (10) ************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building zzHRTS Data (9) ***************************"))
 
for (i=1 to t_output->cnt)
	call writeLog(build2("-->checking encntr_id=",trim(cnvtstring(t_output->qual[i].encntr_id))))
	set t_output->qual[i].encntr_ignore = 1
	if (t_output->qual[i].expired_ind = 0)
		if ((t_output->qual[i].positive_ind = 1) or (t_output->qual[i].suspected_ind = 1))
			if (t_output->qual[i].location_class_1 in("ICU","MSU"))
				set t_output->qual[i].encntr_ignore = 0
			endif
		endif
 
		if ((t_output->qual[i].positive_ind = 1) or (t_output->qual[i].suspected_ind = 1))
			if (t_output->qual[i].location_class_1 in("ED","EB"))
				if (t_output->qual[i].pso in("PSO Admit to Inpatient"))
					set t_output->qual[i].encntr_ignore = 0
				endif
			endif
		endif
 
		if ((t_output->qual[i].ventilator_ind > 0) and (t_output->qual[i].covenant_vent_stock_ind > 0))
			set t_output->qual[i].encntr_ignore = 0
		endif
	elseif (t_output->qual[i].expired_ind = 1)
		set t_output->qual[i].encntr_ignore = 0
	endif
 
	call writeLog(build2("--->checking encntr_ignore=",trim(cnvtstring(t_output->qual[i].encntr_ignore))))
	if (t_output->qual[i].encntr_ignore = 0)
		set hrts->patient_cnt = (hrts->patient_cnt + 1)
		set stat = alterlist(hrts->patient_qual,hrts->patient_cnt)
 
		call writeLog(build2("---->adding hrts->patient_cnt=",trim(cnvtstring(hrts->patient_cnt))))
 
		set hrts->patient_qual[hrts->patient_cnt].encntr_id = t_output->qual[i].encntr_id
		set hrts->patient_qual[hrts->patient_cnt].person_id = t_output->qual[i].person_id
		set hrts->patient_qual[hrts->patient_cnt].patient_name = t_output->qual[i].patient_name
		set hrts->patient_qual[hrts->patient_cnt].encntr_type = t_output->qual[i].encntr_type
		set hrts->patient_qual[hrts->patient_cnt].facility = t_output->qual[i].facility
		set hrts->patient_qual[hrts->patient_cnt].unit = t_output->qual[i].unit
		set hrts->patient_qual[hrts->patient_cnt].room_bed = t_output->qual[i].room_bed
		set hrts->patient_qual[hrts->patient_cnt].fin = t_output->qual[i].fin
		set hrts->patient_qual[hrts->patient_cnt].los_days = t_output->qual[i].los_days
		if ((t_output->qual[i].expired_ind = 1) and (t_output->qual[i].positive_ind = 1))
			set hrts->patient_qual[hrts->patient_cnt].expired = "Y"
		endif
		if (t_output->qual[i].covid19_order > " ")
			set hrts->patient_qual[hrts->patient_cnt].covid19_order = concat(
																					t_output->qual[i].covid19_order
																					," ("
																					,t_output->qual[i].covid19_order_dt_tm
																					,")"
																					)
		endif
		if (t_output->qual[i].covid19_result > " ")
			set hrts->patient_qual[hrts->patient_cnt].covid19_result = concat(
																					t_output->qual[i].covid19_result
																					," ("
																					,t_output->qual[i].covid19_result_dt_tm
																					,")"
																					)
		endif
 
		set hrts->patient_qual[hrts->patient_cnt].diagnosis = t_output->qual[i].diagnosis
 
		if (t_output->qual[i].pso in("PSO Admit to Inpatient"))
			set hrts->patient_qual[hrts->patient_cnt].ip_pso = "Y"
		endif
 
		set hrts->patient_qual[hrts->patient_cnt].location_class_1 = t_output->qual[i].location_class_1
 
		if ((t_output->qual[i].suspected_ind = 1) and (t_output->qual[i].positive_ind = 0))
			set hrts->patient_qual[hrts->patient_cnt].suspected = "Y"
		endif
 
		if (t_output->qual[i].positive_ind = 1)
			set hrts->patient_qual[hrts->patient_cnt].confirmed = "Y"
		endif
 
		if (t_output->qual[i].ventilator_ind > 0)
			if (t_output->qual[i].ventilator_ind = 1)
				set hrts->patient_qual[hrts->patient_cnt].ventilator = "I"
			elseif (t_output->qual[i].ventilator_ind = 2)
				set hrts->patient_qual[hrts->patient_cnt].ventilator = "N"
			endif
			set hrts->patient_qual[hrts->patient_cnt].ventilator_model = t_output->qual[i].ventilator_model
			set hrts->patient_qual[hrts->patient_cnt].ventilator_result = t_output->qual[i].ventilator_type
			if (t_output->qual[i].covenant_vent_stock_ind = 1)
				set hrts->patient_qual[hrts->patient_cnt].covenant_vent_stock = "Y"
			endif
		endif
 
		if (t_output->qual[i].previous_admission_ind = 1)
			set hrts->patient_qual[hrts->patient_cnt].prev_admission = "Y"
		endif
 
		if (t_output->qual[i].previous_onset_ind = 1)
			set hrts->patient_qual[hrts->patient_cnt].prev_onset = "Y"
		endif
 
	endif ;end if encntr_ignore = 0
 
	set t_output->qual[i].encntr_ignore = 1
endfor
 
call writeLog(build2("** Building Summary Table"))
for (i=1 to location_list->location_cnt)
	call writeLog(build2("->location:",trim(location_list->locations[i].display)))
	select into "nl:"
		encntr_id				= hrts->patient_qual[d1.seq].encntr_id
	from
		(dummyt d1 with seq=hrts->patient_cnt)
	plan d1
		where hrts->patient_qual[d1.seq].facility = location_list->locations[i].display
	order by
	 	 encntr_id
	head report
		call writeLog(build2("-->inside nshn query for ",trim(location_list->locations[i].display)))
		hrts->summary_cnt = (hrts->summary_cnt + 1)
		stat = alterlist(hrts->summary_qual,hrts->summary_cnt)
		hrts->summary_qual[hrts->summary_cnt].facility = trim(location_list->locations[i].display)
		call writeLog(build2("-->hrts->summary_cnt=",trim(cnvtstring(hrts->summary_cnt))))
 
		hrts->summary_qual[hrts->summary_cnt].question_25	= ^No^
		hrts->summary_qual[hrts->summary_cnt].question_26 	= ^No^
		hrts->summary_qual[hrts->summary_cnt].question_27a 	= ^N/A^
		hrts->summary_qual[hrts->summary_cnt].question_27b 	= ^N/A^
		hrts->summary_qual[hrts->summary_cnt].question_27c 	= ^N/A^
		hrts->summary_qual[hrts->summary_cnt].question_27d 	= ^N/A^
		hrts->summary_qual[hrts->summary_cnt].question_27e 	= ^N/A^
		hrts->summary_qual[hrts->summary_cnt].question_27f 	= ^N/A^
		hrts->summary_qual[hrts->summary_cnt].question_27g 	= ^N/A^
		hrts->summary_qual[hrts->summary_cnt].question_27h 	= ^N/A^
		hrts->summary_qual[hrts->summary_cnt].question_28 	= ^System^
		hrts->summary_qual[hrts->summary_cnt].question_30a 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_30b 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_30c 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_30d 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_30e 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_30f 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_30g 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_30h 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_30i 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_31 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_31a 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_31b 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_31c 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_31d 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_31e 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_31f 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_31g 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_31h 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_31i 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_31j 	= ^Yes^
		hrts->summary_qual[hrts->summary_cnt].question_32 	= ^No^
		hrts->summary_qual[hrts->summary_cnt].question_33	= ^^
 
 
	head encntr_id
		call writeLog(build2("--->analyzing encntr_id=",trim(cnvtstring(encntr_id))))
	with nocounter,nullreport
endfor
 
 
/*
call writeLog(build2("** Building Summary Table from Extensions"))
 
for (i=1 to hrts->summary_cnt)
		select into "nl:"
	from
		 (dummyt d1 with seq=hrts->summary_cnt)
	    ,code_value cv1
	    ,code_value_extension cve1
	plan d1
		where hrts->summary_qual[i].facility
	join cv1
	    where cv1.code_set              = t_rec->custom_code_set
	    and   cv1.definition            = trim(cnvtlower(t_rec->curprog))
	    and   cv1.active_ind            = 1
	    and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	    and   cv1.end_effective_dt_tm   >= cnvtdatetime(curdate,curtime3)
	    and   cv1.cdf_meaning           = "FACILITY"
	    and   cv1.display				= hrts->summary_qual[d1.seq].facility
	join cve1
		where cve1.code_value			= cv1.code_value
		and   cve1.field_name			in(
											 "Hospital_CCN"
											,"Hospital_NPI"
											,"Hospital_AHA_ID"
											,"Hospital_NHSN_ID"
											,"Address_Street1"
											,"Address_City"
											,"Address_State"
											,"Address_Zip"
											,"TeleTracking_Id"
											)
	order by
		 cv1.code_value
		,cve1.field_name
	head report
		call writeLog(build2("->inside :",trim(hrts->summary_qual[d1.seq].facility)))
	head cv1.code_value
		call writeLog(build2("-->inside :",trim(cv1.display)))
	head cve1.field_name
		call writeLog(build2("--->inside :",trim(cve1.field_name)))
		case (cve1.field_name)
			of "Hospital_CCN"			:	hrts->summary_qual[d1.seq].hospital_ccn  	= trim(cve1.field_value)
			of "Hospital_NPI"			:	hrts->summary_qual[d1.seq].hospital_npi  	= trim(cve1.field_value)
			of "Hospital_AHA_ID"		:	hrts->summary_qual[d1.seq].hospital_aha_id	= trim(cve1.field_value)
			of "Hospital_NHSN_ID"		:	hrts->summary_qual[d1.seq].hospital_nhsn_id	= trim(cve1.field_value)
			of "Address_Street1"		:	hrts->summary_qual[d1.seq].address_street1	= trim(cve1.field_value)
			of "Address_City"			:	hrts->summary_qual[d1.seq].address_city		= trim(cve1.field_value)
			of "Address_State"			:	hrts->summary_qual[d1.seq].address_state	= trim(cve1.field_value)
			of "Address_Zip"			:	hrts->summary_qual[d1.seq].address_zip		= trim(cve1.field_value)
			of "TeleTracking_Id"		:	hrts->summary_qual[d1.seq].teletracking_id	= trim(cve1.field_value)
		endcase
	foot cv1.code_value
		call writeLog(build2("-->leaving :",trim(hrts->summary_qual[d1.seq].facility)))
	foot report
		call writeLog(build2("->leaving :",trim(hrts->summary_qual[d1.seq].facility)))
	with nocounter
endfor
*/
 
call writeLog(build2("* END   Building zzHRTS Data *******************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building zzTele-Tracking Data (6) ******************"))
 
set overall_cnt = 0
 
for (i=1 to t_rec->admit_cnt)
	call writeLog(build2("-->t_rec->admit_qual[i].facility=",trim(t_rec->admit_qual[i].facility)))
	for (j=1 to t_rec->admit_qual[i].encntr_cnt)
		if (t_rec->admit_qual[i].encntr_qual[j].positive_ind > 0)
			call writeLog(build2("-->Adding Positive patient=",trim(cnvtstring(t_rec->admit_qual[i].encntr_qual[j].encntr_id))))
			set t_rec->admit_qual[i].count = (t_rec->admit_qual[i].count + 1)
			set overall_cnt = (overall_cnt + 1)
			call writeLog(build2("-->t_rec->admit_qual[i].count=",trim(cnvtstring(t_rec->admit_qual[i].count))))
			call writeLog(build2("-->overall_cnt=",trim(cnvtstring(overall_cnt))))
		endif
	endfor
endfor
 
for (i=1 to t_output->cnt)
  call writeLog(build2("-->checking encntr_id=",trim(cnvtstring(t_output->qual[i].encntr_id))))
  set t_output->qual[i].encntr_ignore = 1
  if (t_output->qual[i].expired_ind = 0)
	;Checking Q1 Count of Patients in an inpatient bed with confirmed or suspected COVID-19
	;Checking Q2 Count of Patients in an inpatient bed with confirmed or suspected COVID-19 and on a ventilator
	;Checking Q3 Count of Patients in an inpatient bed with confirmed or suspected COVID-19, LOS 14 days or More
	if ((t_output->qual[i].positive_ind = 1) or (t_output->qual[i].suspected_ind = 1))
		if (t_output->qual[i].location_class_1 in("ICU","MSU"))
			set t_output->qual[i].encntr_ignore = 0
		endif
	endif
 
	;Checking Q4 Count of Patients in ED or Overflow with confirmed or suspected COVID-19, and waiting on an inpatient bed
	if ((t_output->qual[i].positive_ind = 1) or (t_output->qual[i].suspected_ind = 1))
		if (t_output->qual[i].location_class_1 in("ED","EB"))
			if (t_output->qual[i].pso in("PSO Admit to Inpatient")) ;TTQ - do we want to require the PSO to Inpatient and/or OBS
				set t_output->qual[i].encntr_ignore = 0
			endif
		endif
	endif
	;Checking Q13 Checking if Patient is on a vent
	if ((t_output->qual[i].ventilator_ind > 0) and (t_output->qual[i].covenant_vent_stock_ind > 0))
		set t_output->qual[i].encntr_ignore = 0
	endif
 elseif (t_output->qual[i].expired_ind = 1)
  set t_output->qual[i].encntr_ignore = 0
  endif
	call writeLog(build2("--->checking encntr_ignore=",trim(cnvtstring(t_output->qual[i].encntr_ignore))))
	if (t_output->qual[i].encntr_ignore = 0)
		set tt_covid19->patient_cnt = (tt_covid19->patient_cnt + 1)
		set stat = alterlist(tt_covid19->patient_qual,tt_covid19->patient_cnt)
 
		call writeLog(build2("---->adding tt_covid19->patient_cnt=",trim(cnvtstring(tt_covid19->patient_cnt))))
 
		set tt_covid19->patient_qual[tt_covid19->patient_cnt].encntr_id = t_output->qual[i].encntr_id
		set tt_covid19->patient_qual[tt_covid19->patient_cnt].person_id = t_output->qual[i].person_id
		set tt_covid19->patient_qual[tt_covid19->patient_cnt].patient_name = t_output->qual[i].patient_name
		set tt_covid19->patient_qual[tt_covid19->patient_cnt].encntr_type = t_output->qual[i].encntr_type
		set tt_covid19->patient_qual[tt_covid19->patient_cnt].facility = t_output->qual[i].facility
		set tt_covid19->patient_qual[tt_covid19->patient_cnt].unit = t_output->qual[i].unit
		set tt_covid19->patient_qual[tt_covid19->patient_cnt].room_bed = t_output->qual[i].room_bed
		set tt_covid19->patient_qual[tt_covid19->patient_cnt].fin = t_output->qual[i].fin
		set tt_covid19->patient_qual[tt_covid19->patient_cnt].los_days = t_output->qual[i].los_days
		if ((t_output->qual[i].expired_ind = 1) and (t_output->qual[i].positive_ind = 1))
			set tt_covid19->patient_qual[tt_covid19->patient_cnt].expired = "Y"
		endif
		if (t_output->qual[i].covid19_order > " ")
			set tt_covid19->patient_qual[tt_covid19->patient_cnt].covid19_order = concat(
																					t_output->qual[i].covid19_order
																					," ("
																					,t_output->qual[i].covid19_order_dt_tm
																					,")"
																					)
		endif
		if (t_output->qual[i].covid19_result > " ")
			set tt_covid19->patient_qual[tt_covid19->patient_cnt].covid19_result = concat(
																					t_output->qual[i].covid19_result
																					," ("
																					,t_output->qual[i].covid19_result_dt_tm
																					,")"
																					)
		endif
 
		set tt_covid19->patient_qual[tt_covid19->patient_cnt].diagnosis = t_output->qual[i].diagnosis
 
		if (t_output->qual[i].pso in("PSO Admit to Inpatient"))
			set tt_covid19->patient_qual[tt_covid19->patient_cnt].ip_pso = "Y"
		endif
 
		set tt_covid19->patient_qual[tt_covid19->patient_cnt].location_class_1 = t_output->qual[i].location_class_1
 
		if ((t_output->qual[i].suspected_ind = 1) and (t_output->qual[i].positive_ind = 0))
			set tt_covid19->patient_qual[tt_covid19->patient_cnt].suspected = "Y"
		endif
 
		if (t_output->qual[i].positive_ind = 1)
			set tt_covid19->patient_qual[tt_covid19->patient_cnt].confirmed = "Y"
		endif
 
		if (t_output->qual[i].ventilator_ind > 0)
			if (t_output->qual[i].ventilator_ind = 1)
				set tt_covid19->patient_qual[tt_covid19->patient_cnt].ventilator = "I"
			elseif (t_output->qual[i].ventilator_ind = 2)
				set tt_covid19->patient_qual[tt_covid19->patient_cnt].ventilator = "N"
			endif
			set tt_covid19->patient_qual[tt_covid19->patient_cnt].ventilator_model = t_output->qual[i].ventilator_model
			set tt_covid19->patient_qual[tt_covid19->patient_cnt].ventilator_result = t_output->qual[i].ventilator_type
			if (t_output->qual[i].covenant_vent_stock_ind = 1)
				set tt_covid19->patient_qual[tt_covid19->patient_cnt].covenant_vent_stock = "Y"
			endif
		endif
 
		if (t_output->qual[i].previous_admission_ind = 1)
			set tt_covid19->patient_qual[tt_covid19->patient_cnt].prev_admission = "Y"
		endif
 
		if (t_output->qual[i].previous_onset_ind = 1)
			set tt_covid19->patient_qual[tt_covid19->patient_cnt].prev_onset = "Y"
		endif
 
	endif ;end if encntr_ignore = 0
 
	;end check, reset
	set t_output->qual[i].encntr_ignore = 1
endfor
 
 
call writeLog(build2("** Building Summary Table"))
 
for (i=1 to location_list->location_cnt)
	call writeLog(build2("->location:",trim(location_list->locations[i].display)))
	select into "nl:"
		encntr_id				= tt_covid19->patient_qual[d1.seq].encntr_id
	from
		(dummyt d1 with seq=tt_covid19->patient_cnt)
	plan d1
		where tt_covid19->patient_qual[d1.seq].facility = location_list->locations[i].display
	order by
	 	 encntr_id
	head report
		call writeLog(build2("-->inside tt_covid19 query for ",trim(location_list->locations[i].display)))
		tt_covid19->summary_cnt = (tt_covid19->summary_cnt + 1)
		stat = alterlist(tt_covid19->summary_qual,tt_covid19->summary_cnt)
		tt_covid19->summary_qual[tt_covid19->summary_cnt].facility = trim(location_list->locations[i].display)
		call writeLog(build2("-->tt_covid19->summary_cnt=",trim(cnvtstring(tt_covid19->summary_cnt))))
	head encntr_id
		call writeLog(build2("--->analyzing encntr_id=",trim(cnvtstring(encntr_id))))
	 if (tt_covid19->patient_qual[d1.seq].expired = "Y")
	 	call writeLog(build2("---->found expired=",trim(tt_covid19->patient_qual[d1.seq].expired)))
	 	tt_covid19->summary_qual[tt_covid19->summary_cnt].q6_disch_expired =
	 		(tt_covid19->summary_qual[tt_covid19->summary_cnt].q6_disch_expired + 1)
	 else
		call writeLog(build2("---->reviewing location_class_1=",trim(tt_covid19->patient_qual[d1.seq].location_class_1)))
		if (tt_covid19->patient_qual[d1.seq].location_class_1 in("MSU","ICU"))
			call writeLog(build2("---->found location_class_1=",trim(tt_covid19->patient_qual[d1.seq].location_class_1)))
			;Confirmed
			call writeLog(build2("----->reviewing confirmation=",trim(tt_covid19->patient_qual[d1.seq].confirmed)))
			if (tt_covid19->patient_qual[d1.seq].confirmed = "Y")
				tt_covid19->summary_qual[tt_covid19->summary_cnt].q1_ip_confirmed =
				(tt_covid19->summary_qual[tt_covid19->summary_cnt].q1_ip_confirmed + 1)
				call writeLog(build2("--->setting q1_ip_confirmed=",
					trim(cnvtstring(tt_covid19->summary_qual[tt_covid19->summary_cnt].q1_ip_confirmed))))
				if (tt_covid19->patient_qual[d1.seq].prev_admission = "Y")
					tt_covid19->summary_qual[tt_covid19->summary_cnt].qa_numc19confnewadm =
					 (tt_covid19->summary_qual[tt_covid19->summary_cnt].qa_numc19confnewadm + 1)
					call writeLog(build2("--->setting qa_numc19confnewadm=",
					trim(cnvtstring(tt_covid19->summary_qual[tt_covid19->summary_cnt].qa_numc19confnewadm))))
				endif
				if (tt_covid19->patient_qual[d1.seq].location_class_1 in("ICU"))
					tt_covid19->summary_qual[tt_covid19->summary_cnt].q_icu_confirmed =
						(tt_covid19->summary_qual[tt_covid19->summary_cnt].q_icu_confirmed + 1)
				endif
				;LOS >= 14
				call writeLog(build2("----->reviewing los_days=",
					trim(cnvtstring(tt_covid19->patient_qual[d1.seq].los_days))))
				if (tt_covid19->patient_qual[d1.seq].los_days >= 14)
						tt_covid19->summary_qual[tt_covid19->summary_cnt].q3_ip_conf_susp_los14 =
						(tt_covid19->summary_qual[tt_covid19->summary_cnt].q3_ip_conf_susp_los14 + 1)
						call writeLog(build2("--->setting q3_ip_conf_susp_los14=",
							trim(cnvtstring(tt_covid19->summary_qual[tt_covid19->summary_cnt].q3_ip_conf_susp_los14))))
						if (tt_covid19->patient_qual[d1.seq].prev_onset = "Y")
							tt_covid19->summary_qual[tt_covid19->summary_cnt].qc_numc19honewpats =
							 (tt_covid19->summary_qual[tt_covid19->summary_cnt].qc_numc19honewpats + 1)
							call writeLog(build2("--->setting qc_numc19honewpats=",
							trim(cnvtstring(tt_covid19->summary_qual[tt_covid19->summary_cnt].qc_numc19honewpats))))
						endif
				endif
 
				;Ventilator
				call writeLog(build2("----->reviewing ventilator=",trim(tt_covid19->patient_qual[d1.seq].ventilator)))
				if (tt_covid19->patient_qual[d1.seq].ventilator in("I"))
					tt_covid19->summary_qual[tt_covid19->summary_cnt].q2_ip_confirmed_vent =
					(tt_covid19->summary_qual[tt_covid19->summary_cnt].q2_ip_confirmed_vent + 1)
					call writeLog(build2("--->setting q2_ip_confirmed_vent=",
						trim(cnvtstring(tt_covid19->summary_qual[tt_covid19->summary_cnt].q2_ip_confirmed_vent))))
				endif
			endif
 
			call writeLog(build2("----->reviewing suspected=",trim(tt_covid19->patient_qual[d1.seq].suspected)))
			if (tt_covid19->patient_qual[d1.seq].suspected = "Y")
				;Suspected
				tt_covid19->summary_qual[tt_covid19->summary_cnt].q1_ip_suspected =
				(tt_covid19->summary_qual[tt_covid19->summary_cnt].q1_ip_suspected + 1)
				call writeLog(build2("--->setting q1_ip_suspected=",
					trim(cnvtstring(tt_covid19->summary_qual[tt_covid19->summary_cnt].q1_ip_suspected))))
 
				if (tt_covid19->patient_qual[d1.seq].prev_admission = "Y")
					tt_covid19->summary_qual[tt_covid19->summary_cnt].qb_numc19suspnewadm =
					 (tt_covid19->summary_qual[tt_covid19->summary_cnt].qb_numc19suspnewadm + 1)
					call writeLog(build2("--->setting qb_numc19suspnewadm=",
					trim(cnvtstring(tt_covid19->summary_qual[tt_covid19->summary_cnt].qb_numc19suspnewadm))))
				endif
 
				if (tt_covid19->patient_qual[d1.seq].location_class_1 in("ICU"))
					tt_covid19->summary_qual[tt_covid19->summary_cnt].q_icu_suspected =
						(tt_covid19->summary_qual[tt_covid19->summary_cnt].q_icu_suspected + 1)
				endif
 
				;LOS >= 14
				call writeLog(build2("----->reviewing suspected=",trim(cnvtstring(tt_covid19->patient_qual[d1.seq].los_days))))
				if (tt_covid19->patient_qual[d1.seq].los_days >= 14)
						tt_covid19->summary_qual[tt_covid19->summary_cnt].q3_ip_conf_susp_los14 =
						(tt_covid19->summary_qual[tt_covid19->summary_cnt].q3_ip_conf_susp_los14 + 1)
					call writeLog(build2("--->setting q3_ip_conf_susp_los14=",
						trim(cnvtstring(tt_covid19->summary_qual[tt_covid19->summary_cnt].q3_ip_conf_susp_los14))))
					endif
 
				;Ventilator
				call writeLog(build2("----->reviewing ventilator=",trim(tt_covid19->patient_qual[d1.seq].ventilator)))
				if (tt_covid19->patient_qual[d1.seq].ventilator in("I"))
					tt_covid19->summary_qual[tt_covid19->summary_cnt].q2_ip_suspected_vent =
					(tt_covid19->summary_qual[tt_covid19->summary_cnt].q2_ip_suspected_vent + 1)
					call writeLog(build2("--->setting q2_ip_suspected_vent=",
						trim(cnvtstring(tt_covid19->summary_qual[tt_covid19->summary_cnt].q2_ip_suspected_vent))))
				endif
			endif
		elseif (tt_covid19->patient_qual[d1.seq].location_class_1 in("ED","EB"))
			call writeLog(build2("---->found location_class_1=",trim(tt_covid19->patient_qual[d1.seq].location_class_1)))
			;ED with PSO
			if ((tt_covid19->patient_qual[d1.seq].confirmed = "Y") or (tt_covid19->patient_qual[d1.seq].suspected = "Y"))
				tt_covid19->summary_qual[tt_covid19->summary_cnt].q4_ed_of_conf_susp_wait =
				(tt_covid19->summary_qual[tt_covid19->summary_cnt].q4_ed_of_conf_susp_wait + 1)
				call writeLog(build2("--->setting q4_ed_of_conf_susp_wait=",
							trim(cnvtstring(tt_covid19->summary_qual[tt_covid19->summary_cnt].q4_ed_of_conf_susp_wait))))
	 		endif
			if (tt_covid19->patient_qual[d1.seq].confirmed = "Y")
				tt_covid19->summary_qual[tt_covid19->summary_cnt].q4a_ed_of_conf_wait =
					(tt_covid19->summary_qual[tt_covid19->summary_cnt].q4a_ed_of_conf_wait + 1)
				call writeLog(build2("--->setting q4a_ed_of_conf_wait=",
					trim(cnvtstring(tt_covid19->summary_qual[tt_covid19->summary_cnt].q4a_ed_of_conf_wait))))
			endif
 
			if (tt_covid19->patient_qual[d1.seq].suspected = "Y")
				tt_covid19->summary_qual[tt_covid19->summary_cnt].q4b_ed_of_susp_wait =
					(tt_covid19->summary_qual[tt_covid19->summary_cnt].q4b_ed_of_susp_wait + 1)
				call writeLog(build2("--->setting q4a_ed_of_conf_wait=",
					trim(cnvtstring(tt_covid19->summary_qual[tt_covid19->summary_cnt].q4b_ed_of_susp_wait))))
			endif
 
			;Ventilator
			call writeLog(build2("----->reviewing ventilator=",trim(tt_covid19->patient_qual[d1.seq].ventilator)))
			if (tt_covid19->patient_qual[d1.seq].ventilator in("I"))
				tt_covid19->summary_qual[tt_covid19->summary_cnt].q5_ed_of_conf_susp_wait_vent =
				(tt_covid19->summary_qual[tt_covid19->summary_cnt].q5_ed_of_conf_susp_wait_vent + 1)
				call writeLog(build2("--->setting q5_ed_of_conf_susp_wait_vent=",
						trim(cnvtstring(tt_covid19->summary_qual[tt_covid19->summary_cnt].q5_ed_of_conf_susp_wait_vent))))
 
				;NEW TTQ Vent Response
				tt_covid19->summary_qual[tt_covid19->summary_cnt].q5a_ed_of_wait_vent =
				(tt_covid19->summary_qual[tt_covid19->summary_cnt].q5a_ed_of_wait_vent + 1)
				call writeLog(build2("--->setting q5a_ed_of_wait_vent=",
						trim(cnvtstring(tt_covid19->summary_qual[tt_covid19->summary_cnt].q5a_ed_of_wait_vent))))
			endif
		endif
		if ((tt_covid19->patient_qual[d1.seq].ventilator in("I","N"))
					and (tt_covid19->patient_qual[d1.seq].covenant_vent_stock = "Y"))
			tt_covid19->summary_qual[tt_covid19->summary_cnt].q13_ventilator_in_use =
			(tt_covid19->summary_qual[tt_covid19->summary_cnt].q13_ventilator_in_use + 1)
			call writeLog(build2("--->setting q13_ventilator_in_use=",
			trim(cnvtstring(tt_covid19->summary_qual[tt_covid19->summary_cnt].q13_ventilator_in_use))))
		endif
	 endif
	foot report
		call writeLog(build2("-->leaving tt_covid19 query for ",trim(location_list->locations[i].display)))
		call writeLog(build2("-->tt_covid19->summary_cnt=",trim(cnvtstring(tt_covid19->summary_cnt))))
		tt_covid19->summary_qual[tt_covid19->summary_cnt].q1_total =
			(tt_covid19->summary_qual[tt_covid19->summary_cnt].q1_ip_confirmed +
			 tt_covid19->summary_qual[tt_covid19->summary_cnt].q1_ip_suspected)
		call writeLog(build2("-->tt_covid19->summary_qual[tt_covid19->summary_cnt].q1_total="
			,trim(cnvtstring(tt_covid19->summary_qual[tt_covid19->summary_cnt].q1_total))))
 
		tt_covid19->summary_qual[tt_covid19->summary_cnt].q2_total =
			(tt_covid19->summary_qual[tt_covid19->summary_cnt].q2_ip_confirmed_vent +
			 tt_covid19->summary_qual[tt_covid19->summary_cnt].q2_ip_suspected_vent)
				call writeLog(build2("-->tt_covid19->summary_qual[tt_covid19->summary_cnt].q2_total="
			,trim(cnvtstring(tt_covid19->summary_qual[tt_covid19->summary_cnt].q2_total))))
	with nocounter,nullreport
endfor
 
 
call writeLog(build2("** Building Summary Table from Extensions"))
 
for (i=1 to tt_covid19->summary_cnt)
	select into "nl:"
	from
		 (dummyt d1 with seq=tt_covid19->summary_cnt)
	    ,code_value cv1
	    ,code_value_extension cve1
	plan d1
		where tt_covid19->summary_qual[i].facility
	join cv1
	    where cv1.code_set              = t_rec->custom_code_set
	    and   cv1.definition            = trim(cnvtlower(t_rec->curprog))
	    and   cv1.active_ind            = 1
	    and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	    and   cv1.end_effective_dt_tm   >= cnvtdatetime(curdate,curtime3)
	    and   cv1.cdf_meaning           = "FACILITY"
	    and   cv1.display				= tt_covid19->summary_qual[d1.seq].facility
	join cve1
		where cve1.code_value			= cv1.code_value
		and   cve1.field_name			in(
											 "Q7"
											,"Q8"
											,"Q10"
											,"Q12"
											,"NUMC19DIED"
											,"Total_Surgical_Masks"
											,"Total_N95_Masks"
											,"Total_Beds"
											)
	order by
		 cv1.code_value
		,cve1.field_name
	head report
		call writeLog(build2("->inside :",trim(tt_covid19->summary_qual[d1.seq].facility)))
	head cv1.code_value
		call writeLog(build2("-->inside :",trim(cv1.display)))
	head cve1.field_name
		call writeLog(build2("--->inside :",trim(cve1.field_name)))
		case (cve1.field_name)
			of "Q7": 					tt_covid19->summary_qual[d1.seq].q7_all_beds_total			= cnvtint(cve1.field_value)
			of "Q8": 					tt_covid19->summary_qual[d1.seq].q8_all_beds_total_surge	= cnvtint(cve1.field_value)
			of "Q10": 					tt_covid19->summary_qual[d1.seq].q10_avail_icu_beds			= cnvtint(cve1.field_value)
			of "Q12": 					tt_covid19->summary_qual[d1.seq].q12_ventilator_total		= cnvtint(cve1.field_value)
			of "NUMC19DIED": 			tt_covid19->summary_qual[d1.seq].q6a_all_expired			= cnvtint(cve1.field_value)
			of "Total_Surgical_Masks": 	tt_covid19->summary_qual[d1.seq].q_total_surgical_masks		= cnvtint(cve1.field_value)
			of "Total_N95_Masks": 		tt_covid19->summary_qual[d1.seq].q_total_n95_masks			= cnvtint(cve1.field_value)
			of "Total_Beds": 			tt_covid19->summary_qual[d1.seq].q_total_beds				= cnvtint(cve1.field_value)
		endcase
	foot cv1.code_value
		call writeLog(build2("-->leaving :",trim(tt_covid19->summary_qual[d1.seq].facility)))
	foot report
		call writeLog(build2("->leaving :",trim(tt_covid19->summary_qual[d1.seq].facility)))
	with nocounter
 
	;Death Totals
	set pos = locateval(j,1,t_rec->death_cnt,tt_covid19->summary_qual[i].facility,t_rec->death_qual[j].facility)
	if (pos > 0)
		set tt_covid19->summary_qual[i].q_deaths = t_rec->death_qual[pos].count
	endif
	;Admit totals
	set pos = locateval(j,1,t_rec->admit_cnt,tt_covid19->summary_qual[i].facility,t_rec->admit_qual[j].facility)
	if (pos > 0)
		set tt_covid19->summary_qual[i].q_admits_pos = t_rec->admit_qual[pos].count
	endif
 
endfor
 
 
call writeLog(build2("** Building Summary Table for Bed Counts"))
 
for (i=1 to tt_covid19->summary_cnt)
	select into "nl:"
		 facility = t_output->qual[d1.seq].facility
		,encntr_id = t_output->qual[d1.seq].encntr_id
	from
		 (dummyt d1 with seq=t_output->cnt)
	plan d1
		where t_output->qual[d1.seq].facility = tt_covid19->summary_qual[i].facility
		and   t_output->qual[d1.seq].expired_ind = 0
	order by
		  facility
		 ,encntr_id
	head report
		call writeLog(build2("->inside :",trim(facility)))
	head facility
		call writeLog(build2("-->inside :",trim(facility)))
	head encntr_id
		call writeLog(build2("--->checking encntr_id=",trim(cnvtstring(encntr_id))))
		if (t_output->qual[d1.seq].location_class_1 in("ICU","MSU"))
			tt_covid19->summary_qual[i].q9_occupied_ip_beds = (tt_covid19->summary_qual[i].q9_occupied_ip_beds + 1)
		endif
		if (t_output->qual[d1.seq].location_class_1 in("ICU"))
			tt_covid19->summary_qual[i].q11_occupied_icu_beds = (tt_covid19->summary_qual[i].q11_occupied_icu_beds + 1)
		endif
	foot encntr_id
		call writeLog(build2("--->leaving encntr_id=",trim(cnvtstring(encntr_id))))
	foot facility
		call writeLog(build2("-->leaving :",trim(facility)))
	foot report
		call writeLog(build2("->leaving :",trim(facility)))
	with nocounter
endfor
 
call writeLog(build2("* END   Building zzTele-Tracking Data **********************"))
call writeLog(build2("************************************************************"))
 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building zzHRTS Data (3,4) *************************"))
 
for (i=1 to t_output->cnt)
 if ((t_output->qual[i].historical_ind = 0) and (t_rec->prompt_historical_ind = 0))
	call writeLog(build2("-->checking encntr_id=",trim(cnvtstring(t_output->qual[i].encntr_id))))
  	set t_output->qual[i].hrts_ignore = 1
  	if (t_output->qual[i].expired_ind = 0)
  	  ;if (t_output->qual[i].encntr_type = "Inpatient")
  	  if (t_output->qual[i].location_class_1 > " ")
		;Checking Question 1 series for positive patients
		if ((t_output->qual[i].positive_ind = 1))
			set t_output->qual[i].hrts_ignore = 0
		endif
		;Checking Question 2 series for positive patients
		;if ((t_output->qual[i].pending_test_ind = 1))
		if ((t_output->qual[i].suspected_ind = 1))
			set t_output->qual[i].hrts_ignore = 0
		endif
	  endif
  	endif
 
 	call writeLog(build2("--->checking encntr_ignore=",trim(cnvtstring(t_output->qual[i].hrts_ignore))))
	if (t_output->qual[i].hrts_ignore = 0)
		set hrts_covid19->patient_cnt = (hrts_covid19->patient_cnt + 1)
		set stat = alterlist(hrts_covid19->patient_qual,hrts_covid19->patient_cnt)
 
		call writeLog(build2("---->adding hrts_covid19->patient_cnt=",trim(cnvtstring(hrts_covid19->patient_cnt))))
 
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].encntr_id = t_output->qual[i].encntr_id
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].person_id = t_output->qual[i].person_id
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].patient_name = t_output->qual[i].patient_name
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].encntr_type = t_output->qual[i].encntr_type
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].facility = t_output->qual[i].facility
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].unit = t_output->qual[i].unit
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].room_bed = t_output->qual[i].room_bed
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].fin = t_output->qual[i].fin
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].los_days = t_output->qual[i].los_days
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].arrive_dt_tm = t_output->qual[i].arrive_dt_tm
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].reg_dt_tm = t_output->qual[i].reg_dt_tm
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].inpatient_dt_tm = t_output->qual[i].inpatient_dt_tm
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].observation_dt_tm = t_output->qual[i].observation_dt_tm
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].disch_dt_tm = t_output->qual[i].disch_dt_tm
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].expired_dt_tm = t_output->qual[i].expired_dt_tm
 
		if ((t_output->qual[i].expired_ind = 1) and (t_output->qual[i].positive_ind = 1))
			set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].expired = "Y"
		endif
		if (t_output->qual[i].covid19_order > " ")
			set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].covid19_order = concat(
																					t_output->qual[i].covid19_order
																					," ("
																					,t_output->qual[i].covid19_order_dt_tm
																					,")"
																					)
		endif
		if (t_output->qual[i].covid19_result > " ")
			set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].covid19_result = concat(
																					t_output->qual[i].covid19_result
																					," ("
																					,t_output->qual[i].covid19_result_dt_tm
																					,")"
																					)
		endif
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].diagnosis = t_output->qual[i].diagnosis
		if (t_output->qual[i].pso in("PSO Admit to Inpatient"))
			set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].ip_pso = "Y"
		endif
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].location_class_1 = t_output->qual[i].location_class_1
		if ((t_output->qual[i].suspected_ind = 1) and (t_output->qual[i].positive_ind = 0))
			set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].suspected = "Y"
		endif
 
		if (t_output->qual[i].positive_ind = 1)
			set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].confirmed = "Y"
		endif
 
		if (t_output->qual[i].ventilator_ind > 0)
			if (t_output->qual[i].ventilator_ind = 1)
				set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].ventilator = "I"
			elseif (t_output->qual[i].ventilator_ind = 2)
				set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].ventilator = "N"
			endif
			set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].ventilator_model = t_output->qual[i].ventilator_model
			set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].ventilator_result = t_output->qual[i].ventilator_type
			if (t_output->qual[i].covenant_vent_stock_ind = 1)
				set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].covenant_vent_stock = "Y"
			endif
		endif
	endif
	;end check, reset
	set t_output->qual[i].hrts_ignore = 1
 endif ;if ((t_output->qual[i].historical_ind = 0) and (t_rec->prompt_historical_ind = 0))
endfor
 
call writeLog(build2("** Building Summary Table"))
 
for (i=1 to location_list->location_cnt)
	call writeLog(build2("->location:",trim(location_list->locations[i].display)))
	select into "nl:"
		encntr_id				= hrts_covid19->patient_qual[d1.seq].encntr_id
	from
		(dummyt d1 with seq=hrts_covid19->patient_cnt)
	plan d1
		where hrts_covid19->patient_qual[d1.seq].facility = location_list->locations[i].display
	order by
	 	 encntr_id
	head report
		call writeLog(build2("-->inside hrts_covid19 query for ",trim(location_list->locations[i].display)))
		hrts_covid19->summary_cnt = (hrts_covid19->summary_cnt + 1)
		stat = alterlist(hrts_covid19->summary_qual,hrts_covid19->summary_cnt)
		hrts_covid19->summary_qual[hrts_covid19->summary_cnt].facility = trim(location_list->locations[i].display)
		call writeLog(build2("-->hrts_covid19->summary_cnt=",trim(cnvtstring(hrts_covid19->summary_cnt))))
	head encntr_id
		call writeLog(build2("--->analyzing encntr_id=",trim(cnvtstring(encntr_id))))
		if (hrts_covid19->patient_qual[d1.seq].confirmed = "Y")
			call writeLog(build2("--->analyzing confirmed=",trim(hrts_covid19->patient_qual[d1.seq].confirmed)))
			hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q1_total_pos_inp =
				(hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q1_total_pos_inp + 1)
	 		if (hrts_covid19->patient_qual[d1.seq].location_class_1 in("ICU"))
	 			hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q1_1_icu_pos_inp =
					(hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q1_1_icu_pos_inp + 1)
	 		endif
	 		if (hrts_covid19->patient_qual[d1.seq].ventilator in("I","N"))
				hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q1_2_pos_inp_vent =
					(hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q1_2_pos_inp_vent + 1)
			endif
	 	endif
	 	if (hrts_covid19->patient_qual[d1.seq].suspected = "Y")
			call writeLog(build2("--->analyzing suspected=",trim(hrts_covid19->patient_qual[d1.seq].suspected)))
			hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q2_total_pend_inp =
				(hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q2_total_pend_inp + 1)
	 		if (hrts_covid19->patient_qual[d1.seq].location_class_1 in("ICU"))
	 			hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q2_1_icu_pend_inp =
					(hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q2_1_icu_pend_inp + 1)
	 		endif
	 		if (hrts_covid19->patient_qual[d1.seq].ventilator in("I","N"))
				hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q2_2_pend_inp_vent =
					(hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q2_2_pend_inp_vent + 1)
			endif
	 	endif
	foot report
		call writeLog(build2("-->leaving hrts_covid19 query for ",trim(location_list->locations[i].display)))
		call writeLog(build2("-->hrts_covid19->summary_cnt=",trim(cnvtstring(hrts_covid19->summary_cnt))))
	with nocounter,nullreport
endfor
 
call writeLog(build2("* END   Building zzHRTS Data *******************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building zzFacility Unit (5) ************************"))
 
for (i=1 to t_output->cnt)
 if ((t_output->qual[i].historical_ind = 0) and (t_rec->prompt_historical_ind = 0))
	call writeLog(build2("-->checking encntr_id=",trim(cnvtstring(t_output->qual[i].encntr_id))))
  	set t_output->qual[i].cov_summary_ignore = 1
  	if (t_output->qual[i].expired_ind = 0)
  	  ;if (t_output->qual[i].encntr_type = "Inpatient")
  	  	;if (t_output->qual[i].location_class_1 > " ")
		if ((t_output->qual[i].positive_ind = 1))
			set t_output->qual[i].cov_summary_ignore = 0
		endif
		;if ((t_output->qual[i].pending_test_ind = 1))
		if ((t_output->qual[i].suspected_ind = 1))
			set t_output->qual[i].cov_summary_ignore = 0
		endif
	endif
 
 	call writeLog(build2("--->checking encntr_ignore=",trim(cnvtstring(t_output->qual[i].cov_summary_ignore))))
	if (t_output->qual[i].cov_summary_ignore = 0)
 
		set cov_unit_summary->patient_cnt = (cov_unit_summary->patient_cnt + 1)
		set stat = alterlist(cov_unit_summary->patient_qual,cov_unit_summary->patient_cnt)
 
		call writeLog(build2("---->adding cov_unit_summary->patient_cnt=",trim(cnvtstring(cov_unit_summary->patient_cnt))))
 
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].encntr_id = t_output->qual[i].encntr_id
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].person_id = t_output->qual[i].person_id
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].patient_name = t_output->qual[i].patient_name
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].encntr_type = t_output->qual[i].encntr_type
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].facility = t_output->qual[i].facility
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].unit = t_output->qual[i].unit
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].room_bed = t_output->qual[i].room_bed
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].fin = t_output->qual[i].fin
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].los_days = t_output->qual[i].los_days
		if ((t_output->qual[i].expired_ind = 1) and (t_output->qual[i].positive_ind = 1))
			set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].expired = "Y"
		endif
		if (t_output->qual[i].covid19_order > " ")
			set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].covid19_order = concat(
																					t_output->qual[i].covid19_order
																					," ("
																					,t_output->qual[i].covid19_order_dt_tm
																					,")"
																					)
		endif
		if (t_output->qual[i].covid19_result > " ")
			set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].covid19_result = concat(
																					t_output->qual[i].covid19_result
																					," ("
																					,t_output->qual[i].covid19_result_dt_tm
																					,")"
																					)
		endif
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].diagnosis = t_output->qual[i].diagnosis
		if (t_output->qual[i].pso in("PSO Admit to Inpatient"))
			set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].ip_pso = "Y"
		endif
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].location_class_1 = t_output->qual[i].location_class_1
		if ((t_output->qual[i].suspected_ind = 1) and (t_output->qual[i].positive_ind = 0))
			set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].suspected = "Y"
		endif
 
		if (t_output->qual[i].positive_ind = 1)
			set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].confirmed = "Y"
		endif
 
		if (t_output->qual[i].ventilator_ind > 0)
			if (t_output->qual[i].ventilator_ind = 1)
				set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].ventilator = "I"
			elseif (t_output->qual[i].ventilator_ind = 2)
				set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].ventilator = "N"
			endif
			set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].ventilator_model = t_output->qual[i].ventilator_model
			set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].ventilator_result = t_output->qual[i].ventilator_type
			if (t_output->qual[i].covenant_vent_stock_ind = 1)
				set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].covenant_vent_stock = "Y"
			endif
		endif
	endif
	;end check, reset
 endif ;if ((t_output->qual[i].historical_ind = 0) and (t_rec->prompt_historical_ind = 0))
endfor
 
call writeLog(build2("** Building Summary Table"))
 
for (i=1 to location_list->location_cnt)
	call writeLog(build2("->location:",trim(location_list->locations[i].display)))
	select into "nl:"
		 facility				= cov_unit_summary->patient_qual[d1.seq].facility
		,unit					= cov_unit_summary->patient_qual[d1.seq].unit
		,room_bed				= cov_unit_summary->patient_qual[d1.seq].room_bed
		,encntr_id				= cov_unit_summary->patient_qual[d1.seq].encntr_id
	from
		(dummyt d1 with seq=cov_unit_summary->patient_cnt)
	plan d1
		where cov_unit_summary->patient_qual[d1.seq].facility = location_list->locations[i].display
	order by
		 facility
		,unit
		,room_bed
	 	,encntr_id
	head report
		call writeLog(build2("-->inside cov_unit_summary query for ",trim(location_list->locations[i].display)))
		cov_unit_summary->summary_cnt = (cov_unit_summary->summary_cnt + 1)
		stat = alterlist(cov_unit_summary->summary_qual,cov_unit_summary->summary_cnt)
		cov_unit_summary->summary_qual[cov_unit_summary->summary_cnt].facility = trim(location_list->locations[i].display)
		call writeLog(build2("-->cov_unit_summary->summary_cnt=",trim(cnvtstring(cov_unit_summary->summary_cnt))))
		unit_cnt = 0
		room_bed_cnt = 0
		summary_cnt = 0
	head facility
		call writeLog(build2("-->inside facility query for ",trim(cov_unit_summary->patient_qual[d1.seq].facility)))
		summary_cnt = cov_unit_summary->summary_cnt
		unit_cnt = 0
		room_bed_cnt = 0
	head unit
		call writeLog(build2("-->inside unit query for ",trim(cov_unit_summary->patient_qual[d1.seq].unit)))
		unit_cnt = (unit_cnt + 1)
		cov_unit_summary->summary_qual[summary_cnt].unit_cnt = unit_cnt
		stat = alterlist(cov_unit_summary->summary_qual[summary_cnt].unit_qual,unit_cnt)
		cov_unit_summary->summary_qual[summary_cnt].unit_qual[unit_cnt].unit = trim(cov_unit_summary->patient_qual[d1.seq].unit)
		room_bed_cnt = 0
	head room_bed
		call writeLog(build2("-->inside cov_unit_summary query for ",trim(cov_unit_summary->patient_qual[d1.seq].room_bed)))
		room_bed_cnt = (room_bed_cnt + 1)
		cov_unit_summary->summary_qual[summary_cnt].unit_qual[unit_cnt].room_bed_cnt = room_bed_cnt
		stat = alterlist(cov_unit_summary->summary_qual[summary_cnt].unit_qual[unit_cnt].room_bed_qual,room_bed_cnt)
		cov_unit_summary->summary_qual[summary_cnt].unit_qual[unit_cnt].room_bed_qual[room_bed_cnt].room_bed = trim(
		cov_unit_summary->patient_qual[d1.seq].room_bed)
	head encntr_id
		call writeLog(build2("--->analyzing encntr_id=",trim(cnvtstring(encntr_id))))
		if (cov_unit_summary->patient_qual[d1.seq].confirmed = "Y")
			call writeLog(build2("--->analyzing confirmed=",trim(cov_unit_summary->patient_qual[d1.seq].confirmed)))
			cov_unit_summary->summary_qual[summary_cnt].unit_qual[unit_cnt].room_bed_qual[room_bed_cnt].confirmed = "Y"
	 	endif
	 	if (cov_unit_summary->patient_qual[d1.seq].suspected = "Y")
			call writeLog(build2("--->analyzing suspected=",trim(cov_unit_summary->patient_qual[d1.seq].suspected)))
			cov_unit_summary->summary_qual[summary_cnt].unit_qual[unit_cnt].room_bed_qual[room_bed_cnt].suspected = "Y"
	 	endif
	foot room_bed
		call writeLog(build2("-->leaving room_bed query for ",trim(location_list->locations[i].display)))
	foot unit
		call writeLog(build2("-->leaving unit query for ",trim(location_list->locations[i].display)))
	foot facility
		call writeLog(build2("-->leaving facility query for ",trim(location_list->locations[i].display)))
	foot report
		call writeLog(build2("-->leaving cov_unit_summary query for ",trim(location_list->locations[i].display)))
		call writeLog(build2("-->cov_unit_summary->summary_cnt=",trim(cnvtstring(cov_unit_summary->summary_cnt))))
	with nocounter,nullreport
endfor
 
call writeLog(build2("* END   zzBuilding Facility Unit ***************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Output   *******************************************"))
 
call writeLog(build2("->t_rec->output_cnt=",trim(cnvtstring(t_rec->output_cnt))))
call writeLog(build2("->program_log->run_from_ops=",trim(cnvtstring(program_log->run_from_ops))))
 
set modify filestream
 
for (i=1 to t_rec->output_cnt)
 call writeLog(build2("-->t_rec->output_qual[",trim(cnvtstring(i)),"].prompt_report_type="
 	,trim(cnvtstring(t_rec->output_qual[i].prompt_report_type))))
  call writeLog(build2("-->t_rec->output_qual[",trim(cnvtstring(i)),"].output_file="
 	,trim((t_rec->output_qual[i].output_file))))
 if (t_rec->output_qual[i].prompt_report_type = 1) ;zzNHSN Summary
 	call writeLog(build2("--->zzNHSN Summary (nhsn_covid19) [1]"))
	select
		if (program_log->run_from_ops = 1)
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,format
		else
			with nocounter,separator = " ", format
		endif
	into value(t_rec->output_qual[i].output_file)
	 facility 					= trim(nhsn_covid19->summary_qual[d1.seq].facility)					;0
	,collectiondate				= trim(format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy;;d"))		;1
	,numc19confnewadm			= nhsn_covid19->summary_qual[d1.seq].qa_numc19confnewadm			;2
	,numc19suspnewadm			= nhsn_covid19->summary_qual[d1.seq].qb_numc19suspnewadm			;3
	,numc19honewpats			= nhsn_covid19->summary_qual[d1.seq].qc_numc19honewpats				;4
	,numconfc19honewpats 		= nhsn_covid19->summary_qual[d1.seq].qd_numc19honsetprev			;5
	,numc19hosppats				= nhsn_covid19->summary_qual[d1.seq].q1_total						;6
	,numconfc19hosppats			= nhsn_covid19->summary_qual[d1.seq].q1_ip_confirmed				;7
	,numc19mechventpats			= nhsn_covid19->summary_qual[d1.seq].q2_total						;8
	,numconfc19mechventpats		= nhsn_covid19->summary_qual[d1.seq].q2_ip_confirmed_vent			;9
	,numc19icupats				= nhsn_covid19->summary_qual[d1.seq].q_icu_total					;10
	,numconfc19icupats			= nhsn_covid19->summary_qual[d1.seq].q_icu_pos_inp					;11
	,numc19hopats	 			= nhsn_covid19->summary_qual[d1.seq].q3_ip_conf_susp_los14			;12
	,numconfc19hopats			= nhsn_covid19->summary_qual[d1.seq].q3_ip_conf_los14				;13
	,numc19overflowpats			= nhsn_covid19->summary_qual[d1.seq].q4_ed_of_conf_susp_wait		;14
	,numconfc19overflowpats		= nhsn_covid19->summary_qual[d1.seq].q4_ed_of_conf_wait				;15
	,numc19ofmechventpats		= nhsn_covid19->summary_qual[d1.seq].q5_ed_of_conf_susp_wait_vent	;16
	,numconfc19ofmechventpats	= nhsn_covid19->summary_qual[d1.seq].q5_ed_of_conf_wait_vent		;17
	,numc19died					= nhsn_covid19->summary_qual[d1.seq].q6_disch_expired				;18
	,numc19prevdied				= nhsn_covid19->summary_qual[d1.seq].q6_disch_expired				;19
	,numconfc19prevdied			= nhsn_covid19->summary_qual[d1.seq].q6_disch_expired				;20
	,numtotbeds 				= nhsn_covid19->summary_qual[d1.seq].q7_all_beds_total				;21
	,numbeds 					= nhsn_covid19->summary_qual[d1.seq].q8_all_beds_total_surge		;22
	,numbedsocc 				= nhsn_covid19->summary_qual[d1.seq].q9_occupied_ip_beds			;23
	,numicubeds 				= nhsn_covid19->summary_qual[d1.seq].q10_avail_icu_beds				;24
	,numnicubeds				= 0																	;25
	,numicubedsocc 				= nhsn_covid19->summary_qual[d1.seq].q11_occupied_icu_beds			;26
	,numnicubedsocc				= 0																	;27
	,numvent					= nhsn_covid19->summary_qual[d1.seq].q12_ventilator_total			;28
	,numventuse					= nhsn_covid19->summary_qual[d1.seq].q13_ventilator_in_use			;29
	from
		(dummyt d1 with seq=nhsn_covid19->summary_cnt)
	plan d1
	;007 order by
	;007 facility
	with nocounter,separator = " ", format
 
	if (program_log->run_from_ops = 1)
		call writeLog(build2("---->addAttachment(",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),")"))
		;call addAttachment(program_log->files.file_path, replace(t_rec->output_qual[i].output_file,"cclscratch:",""))
		execute cov_astream_file_transfer "cclscratch",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),"","CP"
	endif
 
 elseif (t_rec->output_qual[i].prompt_report_type = 2) ;zzNHSN Detail
 	call writeLog(build2("--->zzNHSN Detail (nhsn_covid19) [2]"))
	select
		if (program_log->run_from_ops = 1)
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,format
		else
			with nocounter,separator = " ", format
		endif
	into value(t_rec->output_qual[i].output_file)
		 facility 				= trim(nhsn_covid19->patient_qual[d1.seq].facility)
		,unit	 				= trim(substring(1,30,nhsn_covid19->patient_qual[d1.seq].unit))
		,encntr_type			= trim(substring(1,30,nhsn_covid19->patient_qual[d1.seq].encntr_type))
		,patient				= substring(1,50,nhsn_covid19->patient_qual[d1.seq].patient_name)
		,fin					= substring(1,10,nhsn_covid19->patient_qual[d1.seq].fin)
		,room_bed				= substring(1,10,nhsn_covid19->patient_qual[d1.seq].room_bed)
		,location_class_1		= substring(1,10,nhsn_covid19->patient_qual[d1.seq].location_class_1)
		,los_days				= substring(1,6,cnvtstring(round(nhsn_covid19->patient_qual[d1.seq].los_days,0),17,0))
		,pso					= substring(1,50,nhsn_covid19->patient_qual[d1.seq].ip_pso)
		,arrive_dt_tm			= substring(1,50,nhsn_covid19->patient_qual[d1.seq].arrive_dt_tm)
		,reg_dt_tm				= substring(1,50,nhsn_covid19->patient_qual[d1.seq].reg_dt_tm)
		,inpatient_dt_tm		= substring(1,50,nhsn_covid19->patient_qual[d1.seq].inpatient_dt_tm)
		,observation_dt_tm		= substring(1,50,nhsn_covid19->patient_qual[d1.seq].observation_dt_tm)
		,disch_dt_tm			= substring(1,50,nhsn_covid19->patient_qual[d1.seq].disch_dt_tm)
		,expired_dt_tm			= substring(1,50,nhsn_covid19->patient_qual[d1.seq].expired_dt_tm)
		,diagnosis				= substring(1,50,nhsn_covid19->patient_qual[d1.seq].diagnosis)
		,covid19_order			= substring(1,50,nhsn_covid19->patient_qual[d1.seq].covid19_order)
		,covid19_result			= substring(1,50,nhsn_covid19->patient_qual[d1.seq].covid19_result)
		,isolation_order		= substring(1,50,nhsn_covid19->patient_qual[d1.seq].isolation_order)
		,ventilator_type		= substring(1,50,nhsn_covid19->patient_qual[d1.seq].ventilator_result)
		,ventilator_model		= substring(1,20,nhsn_covid19->patient_qual[d1.seq].ventilator_model)
		,confirmed				= substring(1,50,nhsn_covid19->patient_qual[d1.seq].confirmed)
		,suspected				= substring(1,50,nhsn_covid19->patient_qual[d1.seq].suspected)
		,prev_admission			= substring(1,50,nhsn_covid19->patient_qual[d1.seq].prev_admission)
		,prev_onset				= substring(1,50,nhsn_covid19->patient_qual[d1.seq].prev_onset)
		,ventilator				= substring(1,50,nhsn_covid19->patient_qual[d1.seq].ventilator)
		,expired				= substring(1,50,nhsn_covid19->patient_qual[d1.seq].expired)
		,person_id				= nhsn_covid19->patient_qual[d1.seq].person_id
		,encntr_id				= nhsn_covid19->patient_qual[d1.seq].encntr_id
	from
		(dummyt d1 with seq=nhsn_covid19->patient_cnt)
	plan d1
	order by
		 facility
		,unit
		,room_bed
		,patient
	with nocounter,separator = " ", format
 
	if (program_log->run_from_ops = 1)
		call writeLog(build2("---->addAttachment(",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),")"))
		;call addAttachment(program_log->files.file_path, replace(t_rec->output_qual[i].output_file,"cclscratch:",""))
		execute cov_astream_file_transfer "cclscratch",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),"","CP"
	endif
 
 elseif (t_rec->output_qual[i].prompt_report_type = 3) ;zzHRTS Summary
 	call writeLog(build2("--->zzHRTS Summary (hrts_covid19) [3]"))
	select
		if (program_log->run_from_ops = 1)
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,format
		else
			with nocounter,separator = " ", format
		endif
	into value(t_rec->output_qual[i].output_file)
		 facility 			= trim(hrts_covid19->summary_qual[d1.seq].facility)
		,date				= trim(format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy;;d"))
		,q1_total_pos		= hrts_covid19->summary_qual[d1.seq].q1_total_pos_inp
		,q1_1_icu_pos		= hrts_covid19->summary_qual[d1.seq].q1_1_icu_pos_inp
		,q1_2_inp_pos_vent	= hrts_covid19->summary_qual[d1.seq].q1_2_pos_inp_vent
		,q2_total_susp		= hrts_covid19->summary_qual[d1.seq].q2_total_pend_inp
		,q2_1_icu_susp		= hrts_covid19->summary_qual[d1.seq].q2_1_icu_pend_inp
		,q2_2_inp_susp_vent	= hrts_covid19->summary_qual[d1.seq].q2_2_pend_inp_vent
	from
		(dummyt d1 with seq=hrts_covid19->summary_cnt)
	plan d1
	;007 order by
	;007 facility
	with nocounter,separator = " ", format
 
	if (program_log->run_from_ops = 1)
		call writeLog(build2("---->addAttachment(",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),")"))
		;call addAttachment(program_log->files.file_path, replace(t_rec->output_qual[i].output_file,"cclscratch:",""))
		execute cov_astream_file_transfer "cclscratch",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),"","CP"
	endif
 
 elseif (t_rec->output_qual[i].prompt_report_type = 4) ;zzHRTS Detail
 	call writeLog(build2("--->zzHRTS Detail (hrts_covid19) [4]"))
	select
		if (program_log->run_from_ops = 1)
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,format
		else
			with nocounter,separator = " ", format
		endif
	into value(t_rec->output_qual[i].output_file)
		 facility 				= trim(hrts_covid19->patient_qual[d1.seq].facility)
		,unit	 				= trim(substring(1,30,hrts_covid19->patient_qual[d1.seq].unit))
		,encntr_type			= trim(substring(1,30,hrts_covid19->patient_qual[d1.seq].encntr_type))
		,patient				= substring(1,50,hrts_covid19->patient_qual[d1.seq].patient_name)
		,fin					= substring(1,10,hrts_covid19->patient_qual[d1.seq].fin)
		,room_bed				= substring(1,10,hrts_covid19->patient_qual[d1.seq].room_bed)
		,location_class_1		= substring(1,10,hrts_covid19->patient_qual[d1.seq].location_class_1)
		,los_days				= substring(1,6,cnvtstring(round(hrts_covid19->patient_qual[d1.seq].los_days,0),17,0))
		,pso					= substring(1,50,hrts_covid19->patient_qual[d1.seq].ip_pso)
		,arrive_dt_tm			= substring(1,50,hrts_covid19->patient_qual[d1.seq].arrive_dt_tm)
		,reg_dt_tm				= substring(1,50,hrts_covid19->patient_qual[d1.seq].reg_dt_tm)
		,inpatient_dt_tm		= substring(1,50,hrts_covid19->patient_qual[d1.seq].inpatient_dt_tm)
		,observation_dt_tm		= substring(1,50,hrts_covid19->patient_qual[d1.seq].observation_dt_tm)
		,disch_dt_tm			= substring(1,50,hrts_covid19->patient_qual[d1.seq].disch_dt_tm)
		,expired_dt_tm			= substring(1,50,hrts_covid19->patient_qual[d1.seq].expired_dt_tm)
		,diagnosis				= substring(1,50,hrts_covid19->patient_qual[d1.seq].diagnosis)
		,covid19_order			= substring(1,50,hrts_covid19->patient_qual[d1.seq].covid19_order)
		,covid19_result			= substring(1,50,hrts_covid19->patient_qual[d1.seq].covid19_result)
		,ventilator_type		= substring(1,50,hrts_covid19->patient_qual[d1.seq].ventilator_result)
		,ventilator_model		= substring(1,20,hrts_covid19->patient_qual[d1.seq].ventilator_model)
		,confirmed				= substring(1,50,hrts_covid19->patient_qual[d1.seq].confirmed)
		,suspected				= substring(1,50,hrts_covid19->patient_qual[d1.seq].suspected)
		,ventilator				= substring(1,50,hrts_covid19->patient_qual[d1.seq].ventilator)
		,expired				= substring(1,50,hrts_covid19->patient_qual[d1.seq].expired)
		,person_id				= hrts_covid19->patient_qual[d1.seq].person_id
		,encntr_id				= hrts_covid19->patient_qual[d1.seq].encntr_id
	from
		(dummyt d1 with seq=hrts_covid19->patient_cnt)
	plan d1
	order by
		 facility
		,unit
		,room_bed
		,patient
	with nocounter,separator = " ", format
 
	if (program_log->run_from_ops = 1)
		call writeLog(build2("---->addAttachment(",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),")"))
		;call addAttachment(program_log->files.file_path, replace(t_rec->output_qual[i].output_file,"cclscratch:",""))
		execute cov_astream_file_transfer "cclscratch",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),"","CP"
	endif
 
 elseif (t_rec->output_qual[i].prompt_report_type = 5) ;zzFacility Dashboard
 	call writeLog(build2("--->zzFacility Dashboard (cov_unit_summary) [5]"))
	select
		if (program_log->run_from_ops = 1)
			with nocounter,maxcol=32000,outerjoin=d2,outerjoin=d3
		else
			with nocounter,maxcol=32000,outerjoin=d2,outerjoin=d3
		endif
	into value(t_rec->output_qual[i].output_file)
		 facility 	= substring(1,10,cov_unit_summary->summary_qual[d1.seq].facility)
		,unit 		= substring(1,20,cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].unit)
		,room_bed 	= substring(1,20,cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].room_bed_qual[d3.seq].room_bed)
		,suspected	= cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].room_bed_qual[d3.seq].suspected
		,confirmed	= cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].room_bed_qual[d3.seq].confirmed
	from
		 (dummyt d1 with seq=cov_unit_summary->summary_cnt)
		,(dummyt d2 with seq=1)
		,(dummyt d3 with seq=1)
	plan d1
		where maxrec(d2,size(cov_unit_summary->summary_qual[d1.seq].unit_qual,5))
	join d2
		where maxrec(d3,size(cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].room_bed_qual,5))
	join d3
	order by
		 facility
		,unit
		,room_bed
	head report
		row +1 "<html>"
		row +1 "<head>"
		row +1 "<title>COVID-19 Facility Dashboard</title>"
		row +1 "</head>"
		row +1 "<body>"
		call print(concat("<table border='1' padding=5 width=300>"))
		call print(concat("<tr><th>Facility</th><th>Unit</th><th>Room</th><th>Status</th></tr>"))
	head facility
		row +1
		;call print(concat("<tr><td colspan=3><b>",trim(cov_unit_summary->summary_qual[d1.seq].facility),"</b></td></tr>"))
	head unit
		row +1
		;call print(concat("<tr><td colspan=3>",trim(cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].unit),"</td></tr>"))
	detail
		call print(concat("<tr>"))
		call print(concat("<td>",trim(cov_unit_summary->summary_qual[d1.seq].facility),"</td>"))
		call print(concat("<td>",trim(cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].unit),"</td>"))
		call print(concat("<td>",trim(cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].room_bed_qual[d3.seq].room_bed),"</td>"))
		if (cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].room_bed_qual[d3.seq].confirmed = "Y")
			call print(concat("<td>Confirmed</td>"))
		elseif (cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].room_bed_qual[d3.seq].suspected = "Y")
			call print(concat("<td>Suspected</td>"))
		endif
		call print(concat("</tr>"))
	foot unit
		row +1
	foot facility
		row +1
	foot report
		call print(concat("</table>"))
		row +1 "</body>"
		row +1 "</html>"
	with nocounter,maxcol=32000,outerjoin=d2,outerjoin=d3
 
	if (program_log->run_from_ops = 1)
		call writeLog(build2("---->addAttachment(",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),")"))
		;call addAttachment(program_log->files.file_path, replace(t_rec->output_qual[i].output_file,"cclscratch:",""))
		execute cov_astream_file_transfer "cclscratch",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),"","CP"
	endif
 
 elseif (t_rec->output_qual[i].prompt_report_type = 6) ;zzTeleTracking Summary
 	call writeLog(build2("--->zzTeleTracking Summary (tt_covid19) [6]"))
	select
		if (program_log->run_from_ops = 1)
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,format
		else
			with nocounter,separator = " ", format
		endif
	into value(t_rec->output_qual[i].output_file)
	 facility 									= trim(tt_covid19->summary_qual[d1.seq].facility)
	,collectiondate								= trim(format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy;;d"))
	,Total_Beds									= tt_covid19->summary_qual[d1.seq].q_total_beds
	,Occupied_InPatient_Beds 					= tt_covid19->summary_qual[d1.seq].q9_occupied_ip_beds
	,Total_InPatient_Beds 						= tt_covid19->summary_qual[d1.seq].q8_all_beds_total_surge
	,Confirmed_Patients							= tt_covid19->summary_qual[d1.seq].q1_ip_confirmed
	,Patients_Under_Investigation				= tt_covid19->summary_qual[d1.seq].q1_ip_suspected
	,Patients_Using_Ventilation					= tt_covid19->summary_qual[d1.seq].q2_total
	,ICU_Occupied_Beds		 					= tt_covid19->summary_qual[d1.seq].q11_occupied_icu_beds
	,ICU_Total_Beds			 					= tt_covid19->summary_qual[d1.seq].q10_avail_icu_beds
	,ICU_Confirmed_Patients						= tt_covid19->summary_qual[d1.seq].q_icu_confirmed
	,ICU_Patients_Under_Investigation			= tt_covid19->summary_qual[d1.seq].q_icu_suspected
	,Ventilators_In_Use							= tt_covid19->summary_qual[d1.seq].q13_ventilator_in_use
	,Total_Ventilators							= tt_covid19->summary_qual[d1.seq].q12_ventilator_total
	,Other_Vent_Support_Devices					= "0"
	,Total_N95_Masks							= "See MM" ;tt_covid19->summary_qual[d1.seq].q_total_n95_masks
	,Total_Surgical_Masks						= "See MM" ;tt_covid19->summary_qual[d1.seq].q_total_surgical_masks
	,Total_Covid19_Deaths						= tt_covid19->summary_qual[d1.seq].q6a_all_expired
	,Total_Deaths								= tt_covid19->summary_qual[d1.seq].q_deaths
	,Total_Positive_Inp_0101_0610				= tt_covid19->summary_qual[d1.seq].q_admits_pos
	,Hospital_Onset_Patients	 				= tt_covid19->summary_qual[d1.seq].q3_ip_conf_susp_los14
	,ED_Overflow_Confirmed_Patients				= "0" ;tt_covid19->summary_qual[d1.seq].q4a_ed_of_conf_wait
	,ED_Overflow_Patients_Investigation			= "0" ;tt_covid19->summary_qual[d1.seq].q4b_ed_of_susp_wait
	,ED_Overflow_Patients_Using_Ventilation		= "0" ;tt_covid19->summary_qual[d1.seq].q5_ed_of_conf_susp_wait_vent
	,Admits_In_Last_24_Hrs_Under_Investigation	= tt_covid19->summary_qual[d1.seq].qb_numc19suspnewadm
	,Admits_In_Last_24_Hrs_Confirmed			= tt_covid19->summary_qual[d1.seq].qa_numc19confnewadm
	;,numc19honewpats							= tt_covid19->summary_qual[d1.seq].qc_numc19honewpats
	;,numc19hosppats							= tt_covid19->summary_qual[d1.seq].q1_total
	;,numc19mechventpats_susp					= tt_covid19->summary_qual[d1.seq].q2_ip_suspected_vent
	;,numc19mechventpats_conf					= tt_covid19->summary_qual[d1.seq].q2_ip_confirmed_vent
	;,numc19overflowpats						= tt_covid19->summary_qual[d1.seq].q4_ed_of_conf_susp_wait
	;,numc19ofmechventpats_a					= tt_covid19->summary_qual[d1.seq].q5a_ed_of_wait_vent
	;,numc19died								= tt_covid19->summary_qual[d1.seq].q6_disch_expired
	;,numc19prevdied							= tt_covid19->summary_qual[d1.seq].q6_disch_expired
	;,numtotbeds 								= tt_covid19->summary_qual[d1.seq].q7_all_beds_total
	from
	(dummyt d1 with seq=tt_covid19->summary_cnt)
	plan d1
	;007 order by
	;007 facility
	with nocounter,separator = " ", format
 
	if (program_log->run_from_ops = 1)
		call writeLog(build2("---->addAttachment(",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),")"))
		;call addAttachment(program_log->files.file_path, replace(t_rec->output_qual[i].output_file,"cclscratch:",""))
		execute cov_astream_file_transfer "cclscratch",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),"","CP"
	endif
 
 elseif (t_rec->output_qual[i].prompt_report_type = 7) ;zzTeleTracking Detail
 	call writeLog(build2("--->zzTeleTracking Detail (tt_covid19) [7]"))
	select
		if (program_log->run_from_ops = 1)
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,format
		else
			with nocounter,separator = " ", format
		endif
	into value(t_rec->output_qual[i].output_file)
	 facility 				= trim(tt_covid19->patient_qual[d1.seq].facility)
	,unit	 				= trim(substring(1,30,tt_covid19->patient_qual[d1.seq].unit))
	,encntr_type			= trim(substring(1,30,tt_covid19->patient_qual[d1.seq].encntr_type))
	,patient				= substring(1,50,tt_covid19->patient_qual[d1.seq].patient_name)
	,fin					= substring(1,10,tt_covid19->patient_qual[d1.seq].fin)
	,room_bed				= substring(1,10,tt_covid19->patient_qual[d1.seq].room_bed)
	,location_class_1		= substring(1,10,tt_covid19->patient_qual[d1.seq].location_class_1)
	,los_days				= substring(1,6,cnvtstring(round(tt_covid19->patient_qual[d1.seq].los_days,0),17,0))
	,pso					= substring(1,50,tt_covid19->patient_qual[d1.seq].ip_pso)
	,diagnosis				= substring(1,50,tt_covid19->patient_qual[d1.seq].diagnosis)
	,covid19_order			= substring(1,50,tt_covid19->patient_qual[d1.seq].covid19_order)
	,covid19_result			= substring(1,50,tt_covid19->patient_qual[d1.seq].covid19_result)
	,ventilator_type		= substring(1,50,tt_covid19->patient_qual[d1.seq].ventilator_result)
	,ventilator_model		= substring(1,20,tt_covid19->patient_qual[d1.seq].ventilator_model)
	,confirmed				= substring(1,50,tt_covid19->patient_qual[d1.seq].confirmed)
	,suspected				= substring(1,50,tt_covid19->patient_qual[d1.seq].suspected)
	,prev_admission			= substring(1,50,tt_covid19->patient_qual[d1.seq].prev_admission)
	,prev_onset				= substring(1,50,tt_covid19->patient_qual[d1.seq].prev_onset)
	,ventilator				= substring(1,50,tt_covid19->patient_qual[d1.seq].ventilator)
	,expired				= substring(1,50,tt_covid19->patient_qual[d1.seq].expired)
	,person_id				= tt_covid19->patient_qual[d1.seq].person_id
	,encntr_id				= tt_covid19->patient_qual[d1.seq].encntr_id
	from
		(dummyt d1 with seq=tt_covid19->patient_cnt)
	plan d1
	order by
		 facility
		,unit
		,room_bed
		,patient
	with nocounter,separator = " ", format
 
	if (program_log->run_from_ops = 1)
		call writeLog(build2("---->addAttachment(",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),")"))
		;call addAttachment(program_log->files.file_path, replace(t_rec->output_qual[i].output_file,"cclscratch:",""))
		execute cov_astream_file_transfer "cclscratch",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),"","CP"
	endif
 
 elseif (t_rec->output_qual[i].prompt_report_type = 8) ;Tele Tracking
 	call writeLog(build2("--->Tele Tracking (teletracking) [8]"))
	select
		if (program_log->run_from_ops = 1)
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,maxcol=32000,format
		else
			with nocounter,separator = " ", format,maxcol=32000
		endif
	into value(t_rec->output_qual[i].output_file)
		 hospital_name				 = substring(1,100,teletracking->summary_qual[d1.seq].hospital_name)
		,hospital_ccn				 = substring(1,100,teletracking->summary_qual[d1.seq].hospital_ccn)
		,hospital_npi				 = substring(1,100,teletracking->summary_qual[d1.seq].hospital_npi)
		,hospital_aha_id			 = substring(1,100,teletracking->summary_qual[d1.seq].hospital_aha_id)
		,hospital_nhsn_id			 = substring(1,100,teletracking->summary_qual[d1.seq].hospital_nhsn_id)
		,address_street1			 = substring(1,100,teletracking->summary_qual[d1.seq].address_street1)
		,address_street2			 = substring(1,100,teletracking->summary_qual[d1.seq].address_street2)
		,address_city				 = substring(1,100,teletracking->summary_qual[d1.seq].address_city)
		,address_state				 = substring(1,100,teletracking->summary_qual[d1.seq].address_state)
		,address_zip				 = substring(1,100,teletracking->summary_qual[d1.seq].address_zip)
		,date_entered_utc			 = substring(1,100,teletracking->summary_qual[d1.seq].date_entered_utc)
		,teletracking_id			 = substring(1,100,teletracking->summary_qual[d1.seq].teletracking_id)
		,confirmed_patients			 = teletracking->summary_qual[d1.seq].confirmed_patients
		,confirmed_patients_adult	 = teletracking->summary_qual[d1.seq].confirmed_patients_adult
		,suspected_patients			 = teletracking->summary_qual[d1.seq].suspected_patients
		,suspected_patients_adult	 = teletracking->summary_qual[d1.seq].suspected_patients_adult
		,hospital_onset_patients	 = teletracking->summary_qual[d1.seq].hospital_onset_patients
		,hospital_onset_patients_adult	 =teletracking->summary_qual[d1.seq].hospital_onset_patients_adult
		,patients_using_ventilation		 =teletracking->summary_qual[d1.seq].patients_using_ventilation
		,patients_using_ventilation_adult=teletracking->summary_qual[d1.seq].patients_using_ventilation_adult
		,icu_confirmed_patients			 =teletracking->summary_qual[d1.seq].icu_confirmed_patients
		,icu_confirmed_patients_adult	 =teletracking->summary_qual[d1.seq].icu_confirmed_patients_adult
		,icu_suspected_patients			 =teletracking->summary_qual[d1.seq].icu_suspected_patients
		,icu_suspected_patients_adult	 =teletracking->summary_qual[d1.seq].icu_suspected_patients_adult
		,ed_overflow_confirmed_patients	 =teletracking->summary_qual[d1.seq].ed_overflow_confirmed_patients
		,ed_overflow_confirmed_patients_adult =teletracking->summary_qual[d1.seq].ed_overflow_confirmed_patients_adult
		,ed_overflow_suspected_patients		  =teletracking->summary_qual[d1.seq].ed_overflow_suspected_patients
		,ed_overflow_suspected_patients_adult =teletracking->summary_qual[d1.seq].ed_overflow_suspected_patients_adult
		,ed_overflow_patients_using_ventilation	=teletracking->summary_qual[d1.seq].ed_overflow_patients_using_ventilation
		,ed_overflow_patients_using_ventilation_adult =teletracking->summary_qual[d1.seq].ed_overflow_patients_using_ventilation_adult
		,total_beds				 =teletracking->summary_qual[d1.seq].total_beds
		,total_beds_adult		 =teletracking->summary_qual[d1.seq].total_beds_adult
		,occupied_inpatient_beds	 	=teletracking->summary_qual[d1.seq].occupied_inpatient_beds
		,occupied_inpatient_beds_adult	=teletracking->summary_qual[d1.seq].occupied_inpatient_beds_adult
		,total_inpatient_beds			=teletracking->summary_qual[d1.seq].total_inpatient_beds
		,total_inpatient_beds_adult		=teletracking->summary_qual[d1.seq].total_inpatient_beds_adult
		,icu_occupied_beds				=teletracking->summary_qual[d1.seq].icu_occupied_beds
		,icu_occupied_beds_adult		=teletracking->summary_qual[d1.seq].icu_occupied_beds_adult
		,icu_total_beds				 	=teletracking->summary_qual[d1.seq].icu_total_beds
		,icu_total_beds_adult			=teletracking->summary_qual[d1.seq].icu_total_beds_adult
		;,total_covid19_deaths			=teletracking->summary_qual[d1.seq].total_covid19_deaths
		;,total_deaths				 	=teletracking->summary_qual[d1.seq].total_deaths
		;,total_covid19_admits			=teletracking->summary_qual[d1.seq].total_covid19_admits
		,admits_in_last_24_hrs_confirmed	 	=teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_confirmed
		;,admits_in_last_24_hrs_confirmed_adult	=teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_confirmed_adult
		,admits_in_last_24_hrs_confirmed_0_17 =teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_confirmed_0_17
		,admits_in_last_24_hrs_confirmed_18_19 =teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_confirmed_18_19
		,admits_in_last_24_hrs_confirmed_20_29 =teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_confirmed_20_29
		,admits_in_last_24_hrs_confirmed_30_39 =teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_confirmed_30_39
		,admits_in_last_24_hrs_confirmed_40_49 =teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_confirmed_40_49
		,admits_in_last_24_hrs_confirmed_50_59 =teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_confirmed_50_59
		,admits_in_last_24_hrs_confirmed_60_69 =teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_confirmed_60_69
		,admits_in_last_24_hrs_confirmed_70_79 =teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_confirmed_70_79
		,admits_in_last_24_hrs_confirmed_80 =teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_confirmed_80
		,admits_in_last_24_hrs_suspected		=teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_suspected
		,admits_in_last_24_hrs_suspected_0_17 =teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_suspected_0_17
		,admits_in_last_24_hrs_suspected_18_19 =teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_suspected_18_19
		,admits_in_last_24_hrs_suspected_20_29 =teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_suspected_20_29
		,admits_in_last_24_hrs_suspected_30_39 =teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_suspected_30_39
		,admits_in_last_24_hrs_suspected_40_49 =teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_suspected_40_49
		,admits_in_last_24_hrs_suspected_50_59 =teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_suspected_50_59
		,admits_in_last_24_hrs_suspected_60_69 =teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_suspected_60_69
		,admits_in_last_24_hrs_suspected_70_79 =teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_suspected_70_79
		,admits_in_last_24_hrs_suspected_80 =teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_suspected_80
		;,admits_in_last_24_hrs_suspected_adult	=teletracking->summary_qual[d1.seq].admits_in_last_24_hrs_suspected_adult
		,ed_visits_in_last_24_hrs_total			=teletracking->summary_qual[d1.seq].ed_visits_in_last_24_hrs_total
		,ed_visits_in_last_24_hrs_covid_related	=teletracking->summary_qual[d1.seq].ed_visits_in_last_24_hrs_covid_related
		,covid_death_in_last_24_hrs				=teletracking->summary_qual[d1.seq].covid_death_in_last_24_hrs
		,ventilators_in_use				 =teletracking->summary_qual[d1.seq].ventilators_in_use
		,total_ventilators				 =teletracking->summary_qual[d1.seq].total_ventilators
		,ventilator_medications_able_to_obtain = substring(1,100,teletracking->summary_qual[d1.seq].ventilator_medications_able_to_obtain)
		,ventilator_medications_3day_supply = substring(1,100,teletracking->summary_qual[d1.seq].ventilator_medications_3day_supply)
		;,other_vent_support_devices				 =teletracking->summary_qual[d1.seq].other_vent_support_devices
		,ventilator_supplies_days_on_hand	 = substring(1,100,teletracking->summary_qual[d1.seq].ventilator_supplies_days_on_hand)
		,ventilator_supplies_able_to_obtain	 = substring(1,100,teletracking->summary_qual[d1.seq].ventilator_supplies_able_to_obtain)
		,ventilator_supplies_3day_supply	 = substring(1,100,teletracking->summary_qual[d1.seq].ventilator_supplies_3day_supply)
		;,fentanyl_able_to_obtain			 = substring(1,100,teletracking->summary_qual[d1.seq].fentanyl_able_to_obtain)
		;,fentanyl_3day_supply				 = substring(1,100,teletracking->summary_qual[d1.seq].fentanyl_3day_supply)
		;,hydromorphone_able_to_obtain				 = substring(1,100,teletracking->summary_qual[d1.seq].hydromorphone_able_to_obtain)
		;,hydromorphone_3day_supply				 = substring(1,100,teletracking->summary_qual[d1.seq].hydromorphone_3day_supply)
		;,propofol_able_to_obtain				 = substring(1,100,teletracking->summary_qual[d1.seq].propofol_able_to_obtain)
		;,propofol_3day_supply				 = substring(1,100,teletracking->summary_qual[d1.seq].propofol_3day_supply)
		;,midazolam_able_to_obtain				 = substring(1,100,teletracking->summary_qual[d1.seq].midazolam_able_to_obtain)
		;,midazolam_3day_supply				 = substring(1,100,teletracking->summary_qual[d1.seq].midazolam_3day_supply)
		;,dexmedetomidine_able_to_obtain				 = substring(1,100,teletracking->summary_qual[d1.seq].dexmedetomidine_able_to_obtain)
		;,dexmedetomidine_3day_supply				 = substring(1,100,teletracking->summary_qual[d1.seq].dexmedetomidine_3day_supply)
		;,cisatracurium_able_to_obtain				 = substring(1,100,teletracking->summary_qual[d1.seq].cisatracurium_able_to_obtain)
		;,cisatracurium_3day_supply				 = substring(1,100,teletracking->summary_qual[d1.seq].cisatracurium_3day_supply)
		;,rocuronium_able_to_obtain				 = substring(1,100,teletracking->summary_qual[d1.seq].rocuronium_able_to_obtain)
		;,rocuronium_3day_supply				 = substring(1,100,teletracking->summary_qual[d1.seq].rocuronium_3day_supply)
		,total_n95_masks				 =teletracking->summary_qual[d1.seq].total_n95_masks
		,total_n95_days_on_hand				 =teletracking->summary_qual[d1.seq].total_n95_days_on_hand
		,total_n95_3day_supply				 = substring(1,100,teletracking->summary_qual[d1.seq].total_n95_3day_supply)
		;,total_n95_reuse				 = substring(1,100,teletracking->summary_qual[d1.seq].total_n95_reuse)
		,n95_able_to_obtain = substring(1,100,teletracking->summary_qual[d1.seq].n95_able_to_obtain)
		,total_surgical_masks				 =teletracking->summary_qual[d1.seq].total_surgical_masks
		,total_surgical_mask_days_on_hand				 =teletracking->summary_qual[d1.seq].total_surgical_mask_days_on_hand
		,total_surgical_mask_3day_supply				 = substring(1,100,teletracking->summary_qual[d1.seq].total_surgical_mask_3day_supply)
		;,total_surgical_mask_reuse				 = substring(1,100,teletracking->summary_qual[d1.seq].total_surgical_mask_reuse)
		,surgical_masks_able_to_obtain = substring(1,100,teletracking->summary_qual[d1.seq].surgical_masks_able_to_obtain)
		,total_face_shields				 =teletracking->summary_qual[d1.seq].total_face_shields
		,total_face_shields_days_on_hand				 =teletracking->summary_qual[d1.seq].total_face_shields_days_on_hand
		,total_face_shields_3day_supply				 = substring(1,100,teletracking->summary_qual[d1.seq].total_face_shields_3day_supply)
		;,total_face_shields_reuse				 = substring(1,100,teletracking->summary_qual[d1.seq].total_face_shields_reuse)
		,face_shields_able_to_obtain = substring(1,100,teletracking->summary_qual[d1.seq].face_shields_able_to_obtain)
		,total_gloves				 =teletracking->summary_qual[d1.seq].total_gloves
		,total_gloves_days_on_hand				 =teletracking->summary_qual[d1.seq].total_gloves_days_on_hand
		,total_gloves_3day_supply				 = substring(1,100,teletracking->summary_qual[d1.seq].total_gloves_3day_supply)
		;,total_gloves_reuse				 = substring(1,100,teletracking->summary_qual[d1.seq].total_gloves_reuse)
		,gloves_able_to_obtain = substring(1,100,teletracking->summary_qual[d1.seq].gloves_able_to_obtain)
		,total_single_use_gowns =teletracking->summary_qual[d1.seq].total_single_use_gowns
		,total_single_use_gowns_days_on_hand =teletracking->summary_qual[d1.seq].total_single_use_gowns_days_on_hand
		,total_single_use_gowns_3day_supply = substring(1,100,teletracking->summary_qual[d1.seq].total_single_use_gowns_3day_supply)
		,single_use_gowns_able_to_obtain = substring(1,100,teletracking->summary_qual[d1.seq].single_use_gowns_able_to_obtain)
		;,total_surgical_gowns				 =teletracking->summary_qual[d1.seq].total_surgical_gowns
		;,total_surgical_gowns_days_on_hand				 =teletracking->summary_qual[d1.seq].total_surgical_gowns_days_on_hand
		;,total_surgical_gowns_3day_supply				 = substring(1,100,teletracking->summary_qual[d1.seq].total_surgical_gowns_3day_supply)
		;,total_surgical_gowns_reuse				 = substring(1,100,teletracking->summary_qual[d1.seq].total_surgical_gowns_reuse)
		,total_papr				 =teletracking->summary_qual[d1.seq].total_papr
		,total_papr_days_on_hand				 =teletracking->summary_qual[d1.seq].total_papr_days_on_hand
		,total_papr_3day_supply				 = substring(1,100,teletracking->summary_qual[d1.seq].total_papr_3day_supply)
		;,total_papr_reuse				 = substring(1,100,teletracking->summary_qual[d1.seq].total_papr_reuse)
		,papr_able_to_obtain = substring(1,100,teletracking->summary_qual[d1.seq].papr_able_to_obtain)
		,maintain_supply_of_launderable_gowns
								= substring(1,100,teletracking->summary_qual[d1.seq].maintain_supply_of_launderable_gowns)
		,launderable_gowns_inventory =teletracking->summary_qual[d1.seq].launderable_gowns_inventory
		,use_launderable_gowns				 = substring(1,100,teletracking->summary_qual[d1.seq].use_launderable_gowns)
		,ppe_source				 = substring(1,100,teletracking->summary_qual[d1.seq].ppe_source)
		,anticipated_critical_medical_supply_shortage
								= substring(1,100,teletracking->summary_qual[d1.seq].anticipated_critical_medical_supply_shortage)
		,nasal_pharyngeal_swabs_3day_supply				 = substring(1,100,teletracking->summary_qual[d1.seq].nasal_pharyngeal_swabs_3day_supply)
		,nasal_swabs_3day_supply				 = substring(1,100,teletracking->summary_qual[d1.seq].nasal_swabs_3day_supply)
		,viral_transport_media_3day_supply				 = substring(1,100,teletracking->summary_qual[d1.seq].viral_transport_media_3day_supply)
		,staffing_shortage_today				 = substring(1,100,teletracking->summary_qual[d1.seq].staffing_shortage_today)
		,staffing_shortage_anticipated_this_week
												= substring(1,100,teletracking->summary_qual[d1.seq].staffing_shortage_anticipated_this_week)
		,staffing_shortage_anticipated_environmental_services
												= substring(1,100,teletracking->summary_qual[d1.seq].staffing_shortage_anticipated_environmental_services)
		,staffing_shortage_anticipated_nurses
												= substring(1,100,teletracking->summary_qual[d1.seq].staffing_shortage_anticipated_nurses)
		,staffing_shortage_anticipated_respiratory_therapists
												= substring(1,100,teletracking->summary_qual[d1.seq].staffing_shortage_anticipated_respiratory_therapists)
		,staffing_shortage_anticipated_pharmacist_and_pharmacy_tech
												= substring(1,100,teletracking->summary_qual[d1.seq].staffing_shortage_anticipated_pharmacist_and_pharmacy_tech)
		,staffing_shortage_anticipated_other_physicians
												= substring(1,100,teletracking->summary_qual[d1.seq].staffing_shortage_anticipated_other_physicians)
		,staffing_shortage_anticipated_other_licensed_independent_practitioners
						= substring(1,100,teletracking->summary_qual[d1.seq].staffing_shortage_anticipated_other_licensed_independent_practitioners)
		,staffing_shortage_anticipated_temporary_staff
												= substring(1,100,teletracking->summary_qual[d1.seq].staffing_shortage_anticipated_temporary_staff)
		,staffing_shortage_anticipated_other_critical_healthcare_personnel
									= substring(1,100,teletracking->summary_qual[d1.seq].staffing_shortage_anticipated_other_critical_healthcare_personnel)
		,remdesivir_current_inventory				 =teletracking->summary_qual[d1.seq].remdesivir_current_inventory
		,remdesivir_used_previous_day				 =teletracking->summary_qual[d1.seq].remdesivir_used_previous_day
 
 
 
	from
	(dummyt d1 with seq=teletracking->summary_cnt)
	plan d1
	;007 order by
	;007	hospital_name
	with nocounter,separator = " ", format,maxcol=32000
 
	if (program_log->run_from_ops = 1)
		call writeLog(build2("---->addAttachment(",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),")"))
		;call addAttachment(program_log->files.file_path, replace(t_rec->output_qual[i].output_file,"cclscratch:",""))
		execute cov_astream_file_transfer "cclscratch",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),"","CP"
	endif
 
 elseif (t_rec->output_qual[i].prompt_report_type = 9) ;zzhrts
 	call writeLog(build2("--->zzHRTS (hrts) [9]"))
	select
		if (program_log->run_from_ops = 1)
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,maxcol=32000,format
		else
			with nocounter,separator = " ", format,maxcol=32000
		endif
	into value(t_rec->output_qual[i].output_file)
		 facility = trim(hrts->summary_qual[d1.seq].facility)
		,question_1 = hrts->summary_qual[d1.seq].question_1
		,question_2 = hrts->summary_qual[d1.seq].question_2
		,question_3 = hrts->summary_qual[d1.seq].question_3
		,question_4 = hrts->summary_qual[d1.seq].question_4
		,question_5 = hrts->summary_qual[d1.seq].question_5
		,question_6 = hrts->summary_qual[d1.seq].question_6
		,question_7 = hrts->summary_qual[d1.seq].question_7
		,question_8 = hrts->summary_qual[d1.seq].question_8
		,question_9 = hrts->summary_qual[d1.seq].question_9
		,question_10 = hrts->summary_qual[d1.seq].question_10
		,question_11 = hrts->summary_qual[d1.seq].question_11
		,question_12 = hrts->summary_qual[d1.seq].question_12
		,question_13 = hrts->summary_qual[d1.seq].question_13
		,question_14 = hrts->summary_qual[d1.seq].question_14
		,question_15 = hrts->summary_qual[d1.seq].question_15
		,question_16 = hrts->summary_qual[d1.seq].question_16
		,question_17 = hrts->summary_qual[d1.seq].question_17
		,question_18 = hrts->summary_qual[d1.seq].question_18
		,question_19 = hrts->summary_qual[d1.seq].question_19
		,question_20 = hrts->summary_qual[d1.seq].question_20
		,question_21 = hrts->summary_qual[d1.seq].question_21
		,question_22 = hrts->summary_qual[d1.seq].question_22
		,question_23 = hrts->summary_qual[d1.seq].question_23
		,question_24 = hrts->summary_qual[d1.seq].question_24
		,question_25 = substring(1,100,hrts->summary_qual[d1.seq].question_25)
		,question_26 = substring(1,100,hrts->summary_qual[d1.seq].question_26)
		,question_27a = substring(1,100,hrts->summary_qual[d1.seq].question_27a)
		,question_27b = substring(1,100,hrts->summary_qual[d1.seq].question_27b)
		,question_27c = substring(1,100,hrts->summary_qual[d1.seq].question_27c)
		,question_27d = substring(1,100,hrts->summary_qual[d1.seq].question_27d)
		,question_27e = substring(1,100,hrts->summary_qual[d1.seq].question_27e)
		,question_27f = substring(1,100,hrts->summary_qual[d1.seq].question_27f)
		,question_27g = substring(1,100,hrts->summary_qual[d1.seq].question_27g)
		,question_27h = substring(1,100,hrts->summary_qual[d1.seq].question_27h)
		,question_28 = substring(1,100,hrts->summary_qual[d1.seq].question_28)
		,question_29a = hrts->summary_qual[d1.seq].question_29a
		,question_29b = hrts->summary_qual[d1.seq].question_29b
		,question_29c = hrts->summary_qual[d1.seq].question_29c
		,question_29d = hrts->summary_qual[d1.seq].question_29d
		,question_29e = hrts->summary_qual[d1.seq].question_29e
		,question_29f = hrts->summary_qual[d1.seq].question_29f
		,question_29g = hrts->summary_qual[d1.seq].question_29g
		,question_30a = substring(1,100,hrts->summary_qual[d1.seq].question_30a)
		,question_30b = substring(1,100,hrts->summary_qual[d1.seq].question_30b)
		,question_30c = substring(1,100,hrts->summary_qual[d1.seq].question_30c)
		,question_30d = substring(1,100,hrts->summary_qual[d1.seq].question_30d)
		,question_30e = substring(1,100,hrts->summary_qual[d1.seq].question_30e)
		,question_30f = substring(1,100,hrts->summary_qual[d1.seq].question_30f)
		,question_30g = substring(1,100,hrts->summary_qual[d1.seq].question_30g)
		,question_30h = substring(1,100,hrts->summary_qual[d1.seq].question_30h)
		,question_30i = substring(1,100,hrts->summary_qual[d1.seq].question_30i)
		,question_31 = substring(1,100,hrts->summary_qual[d1.seq].question_31)
		,question_31a = substring(1,100,hrts->summary_qual[d1.seq].question_31a)
		,question_31b = substring(1,100,hrts->summary_qual[d1.seq].question_31b)
		,question_31c = substring(1,100,hrts->summary_qual[d1.seq].question_31c)
		,question_31d = substring(1,100,hrts->summary_qual[d1.seq].question_31d)
		,question_31e = substring(1,100,hrts->summary_qual[d1.seq].question_31e)
		,question_31f = substring(1,100,hrts->summary_qual[d1.seq].question_31f)
		,question_31g = substring(1,100,hrts->summary_qual[d1.seq].question_31g)
		,question_31h = substring(1,100,hrts->summary_qual[d1.seq].question_31h)
		,question_31i = substring(1,100,hrts->summary_qual[d1.seq].question_31i)
		,question_31j = substring(1,100,hrts->summary_qual[d1.seq].question_31j)
		,question_32 = substring(1,100,hrts->summary_qual[d1.seq].question_32)
		,question_33 = substring(1,100,hrts->summary_qual[d1.seq].question_33)
	from
	(dummyt d1 with seq=hrts->summary_cnt)
	plan d1
	;007 order by
	;007	facility
	with nocounter,separator = " ", format,maxcol=32000
 
	if (program_log->run_from_ops = 1)
		call writeLog(build2("---->addAttachment(",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),")"))
		;call addAttachment(program_log->files.file_path, replace(t_rec->output_qual[i].output_file,"cclscratch:",""))
		execute cov_astream_file_transfer "cclscratch",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),"","CP"
	endif
 
 elseif (t_rec->output_qual[i].prompt_report_type = 10) ;zzhrtsv1
 	call writeLog(build2("--->zzHRTS v1 (hrts_0806) [10]"))
	select
		if (program_log->run_from_ops = 1)
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,maxcol=32000,format
		else
			with nocounter,separator = " ", format,maxcol=32000
		endif
	into value(t_rec->output_qual[i].output_file)
		 facility = trim(hrts->summary_qual[d1.seq].facility)
	    ,contact_email = substring(1,100,hrts_0806->summary_qual[d1.seq].contact_email)
		,reporting_for_date = substring(1,100,hrts_0806->summary_qual[d1.seq].reporting_for_date)
		,facility_id = substring(1,100,hrts_0806->summary_qual[d1.seq].facility_id)
		,mechanical_ventilators =hrts_0806->summary_qual[d1.seq].mechanical_ventilators
		,mechanical_ventilators_in_use =hrts_0806->summary_qual[d1.seq].mechanical_ventilators_in_use
		,total_adult_patients_hospitalized_confirmed_and_suspected_covid
			=hrts_0806->summary_qual[d1.seq].total_adult_patients_hospitalized_confirmed_and_suspected_covid
		,total_adult_patients_hospitalized_confirmed_covid
			=hrts_0806->summary_qual[d1.seq].total_adult_patients_hospitalized_confirmed_covid
		,total_pediatric_patients_hospitalized_confirmed_and_suspected_covid
			=hrts_0806->summary_qual[d1.seq].total_pediatric_patients_hospitalized_confirmed_and_suspected_covid
		,total_pediatric_patients_hospitalized_confirmed_covid
			=hrts_0806->summary_qual[d1.seq].total_pediatric_patients_hospitalized_confirmed_covid
		,hospitalized_and_ventilated_covid_patients =hrts_0806->summary_qual[d1.seq].hospitalized_and_ventilated_covid_patients
		,staffed_icu_adult_patients_confirmed_and_suspected_covid
			=hrts_0806->summary_qual[d1.seq].staffed_icu_adult_patients_confirmed_and_suspected_covid
		,staffed_icu_adult_patients_confirmed_covid =hrts_0806->summary_qual[d1.seq].staffed_icu_adult_patients_confirmed_covid
		,hospital_onset =hrts_0806->summary_qual[d1.seq].hospital_onset
		,ed_or_overflow =hrts_0806->summary_qual[d1.seq].ed_or_overflow
		,ed_or_overflow_and_ventilated =hrts_0806->summary_qual[d1.seq].ed_or_overflow_and_ventilated
		,previous_day_deaths_covid =hrts_0806->summary_qual[d1.seq].previous_day_deaths_covid
		,previous_day_admission_adult_covid_confirmed =hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed
		,previous_day_admission_adult_covid_confirmed_18_19
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_18_19
		,previous_day_admission_adult_covid_confirmed_20_29
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_20_29
		,previous_day_admission_adult_covid_confirmed_30_39
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_30_39
		,previous_day_admission_adult_covid_confirmed_40_49
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_40_49
		,previous_day_admission_adult_covid_confirmed_50_59
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_50_59
		,previous_day_admission_adult_covid_confirmed_60_69
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_60_69
		,previous_day_admission_adult_covid_confirmed_70_79
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_70_79
		,previous_day_admission_adult_covid_confirmed_80_plus
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_80_plus
		,previous_day_admission_adult_covid_confirmed_unknown_age
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_unknown_age
		,previous_day_admission_adult_covid_suspected
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected
		,previous_day_admission_adult_covid_suspected_18_19
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_18_19
		,previous_day_admission_adult_covid_suspected_20_29
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_20_29
		,previous_day_admission_adult_covid_suspected_30_39
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_30_39
		,previous_day_admission_adult_covid_suspected_40_49
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_40_49
		,previous_day_admission_adult_covid_suspected_50_59
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_50_59
		,previous_day_admission_adult_covid_suspected_60_69
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_60_69
		,previous_day_admission_adult_covid_suspected_70_79
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_70_79
		,previous_day_admission_adult_covid_suspected_80_plus
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_80_plus
		,previous_day_admission_adult_covid_suspected_unknown_age
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_unknown_age
		,previous_day_admission_pediatric_covid_confirmed
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_pediatric_covid_confirmed
		,previous_day_admission_pediatric_covid_suspected
			=hrts_0806->summary_qual[d1.seq].previous_day_admission_pediatric_covid_suspected
		,previous_day_total_ed_visits =hrts_0806->summary_qual[d1.seq].previous_day_total_ed_visits
		,previous_day_covid_ed_visits =hrts_0806->summary_qual[d1.seq].previous_day_covid_ed_visits
		,previous_day_remdesivir_used =hrts_0806->summary_qual[d1.seq].previous_day_remdesivir_used
		,on_hand_supply_remdesivir_vials =hrts_0806->summary_qual[d1.seq].on_hand_supply_remdesivir_vials
		,critical_staffing_shortage_today =hrts_0806->summary_qual[d1.seq].critical_staffing_shortage_today
		,critical_staffing_shortage_anticipated_within_week
			=hrts_0806->summary_qual[d1.seq].critical_staffing_shortage_anticipated_within_week
		,staffing_shortage_details =hrts_0806->summary_qual[d1.seq].staffing_shortage_details
		,ppe_supply_management_source =hrts_0806->summary_qual[d1.seq].ppe_supply_management_source
		,on_hand_ventilator_supplies_in_days =hrts_0806->summary_qual[d1.seq].on_hand_ventilator_supplies_in_days
		,on_hand_supply_of_n95_respirators_in_days =hrts_0806->summary_qual[d1.seq].on_hand_supply_of_n95_respirators_in_days
		,on_hand_supply_of_surgical_masks_in_days =hrts_0806->summary_qual[d1.seq].on_hand_supply_of_surgical_masks_in_days
		,on_hand_supply_of_eye_protection_in_days =hrts_0806->summary_qual[d1.seq].on_hand_supply_of_eye_protection_in_days
		,on_hand_supply_of_single_use_surgical_gowns_in_days
			=hrts_0806->summary_qual[d1.seq].on_hand_supply_of_single_use_surgical_gowns_in_days
		,on_hand_supply_of_gloves_in_days =hrts_0806->summary_qual[d1.seq].on_hand_supply_of_gloves_in_days
		,on_hand_supply_of_n95_respirators_in_units =hrts_0806->summary_qual[d1.seq].on_hand_supply_of_n95_respirators_in_units
		,on_hand_supply_of_papr_in_units =hrts_0806->summary_qual[d1.seq].on_hand_supply_of_papr_in_units
		,on_hand_supply_of_surgical_masks_in_units =hrts_0806->summary_qual[d1.seq].on_hand_supply_of_surgical_masks_in_units
		,on_hand_supply_of_eye_protection_in_units =hrts_0806->summary_qual[d1.seq].on_hand_supply_of_eye_protection_in_units
		,on_hand_supply_of_single_use_surgical_gowns_in_units
			=hrts_0806->summary_qual[d1.seq].on_hand_supply_of_single_use_surgical_gowns_in_units
		,on_hand_supply_of_launderable_surgical_gowns_in_units
			=hrts_0806->summary_qual[d1.seq].on_hand_supply_of_launderable_surgical_gowns_in_units
		,on_hand_supply_of_gloves_in_units =hrts_0806->summary_qual[d1.seq].on_hand_supply_of_gloves_in_units
		,able_to_obtain_ventilator_supplies = substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_obtain_ventilator_supplies)
		,able_to_obtain_ventilator_medications = substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_obtain_ventilator_medications)
		,able_to_obtain_n95_masks = substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_obtain_n95_masks)
		,able_to_obtain_paprs = substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_obtain_paprs)
		,able_to_obtain_surgical_masks = substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_obtain_surgical_masks)
		,able_to_obtain_eye_protection = substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_obtain_eye_protection)
		,able_to_obtain_single_use_gowns = substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_obtain_single_use_gowns)
		,able_to_obtain_gloves = substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_obtain_gloves)
		,able_to_obtain_launderable_gowns = substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_obtain_launderable_gowns)
		,able_to_maintain_ventilator_3day_supplies
			= substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_maintain_ventilator_3day_supplies)
		,able_to_maintain_ventilator_3day_medications
			= substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_maintain_ventilator_3day_medications)
		,able_to_maintain_n95_masks = substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_maintain_n95_masks)
		,able_to_maintain_3day_paprs = substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_maintain_3day_paprs)
		,able_to_maintain_3day_surgical_masks = substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_maintain_3day_surgical_masks)
		,able_to_maintain_3day_eye_protection = substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_maintain_3day_eye_protection)
		,able_to_maintain_3day_single_use_gowns = substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_maintain_3day_single_use_gowns)
		,able_to_maintain_3day_gloves = substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_maintain_3day_gloves)
		,able_to_maintain_3day_lab_nasal_pharyngeal_swabs
			= substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_maintain_3day_lab_nasal_pharyngeal_swabs)
		,able_to_maintain_lab_nasal_swabs = substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_maintain_lab_nasal_swabs)
		,able_to_maintain_3day_lab_viral_transport_media
			= substring(1,100,hrts_0806->summary_qual[d1.seq].able_to_maintain_3day_lab_viral_transport_media)
		,reusable_isolation_gowns_used =hrts_0806->summary_qual[d1.seq].reusable_isolation_gowns_used
		,reusable_paprs_or_elastomerics_used =hrts_0806->summary_qual[d1.seq].reusable_paprs_or_elastomerics_used
		,reusuable_n95_masks_used =hrts_0806->summary_qual[d1.seq].reusuable_n95_masks_used
		,anticipated_medical_supply_medication_shortages =hrts_0806->summary_qual[d1.seq].anticipated_medical_supply_medication_shortages
	from
	(dummyt d1 with seq=hrts->summary_cnt)
	plan d1
	;007 order by
	;007	facility
	with nocounter,separator = " ", format,maxcol=32000
 
	if (program_log->run_from_ops = 1)
		call writeLog(build2("---->addAttachment(",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),")"))
		;call addAttachment(program_log->files.file_path, replace(t_rec->output_qual[i].output_file,"cclscratch:",""))
		execute cov_astream_file_transfer "cclscratch",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),"","CP"
	endif
 
 elseif (t_rec->output_qual[i].prompt_report_type = 12) ;hrts_v3
 	call writeLog(build2("--->HRTS v3 (hrts_v3) [12]"))
	select
		if (program_log->run_from_ops = 1)
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,maxcol=32000,format
		else
			with nocounter,separator = " ", format,maxcol=32000
		endif
	into value(t_rec->output_qual[i].output_file)
		 contact_email = substring(1,300,hrts_v3->summary_qual[d1.seq].contact_email)
		,reporting_for_date = substring(1,300,hrts_v3->summary_qual[d1.seq].reporting_for_date)
		,facility_id = substring(1,300,hrts_v3->summary_qual[d1.seq].facility_id)
		,hosp_name = substring(1,300,hrts_v3->summary_qual[d1.seq].hosp_name)
		,current_pos =hrts_v3->summary_qual[d1.seq].current_pos
		,current_pos_icu =hrts_v3->summary_qual[d1.seq].current_pos_icu
		,current_pos_vent =hrts_v3->summary_qual[d1.seq].current_pos_vent
		,current_pend =hrts_v3->summary_qual[d1.seq].current_pend
		,current_pend_icu =hrts_v3->summary_qual[d1.seq].current_pend_icu
		,current_pend_vent =hrts_v3->summary_qual[d1.seq].current_pend_vent
		,current_pos_pediatric =hrts_v3->summary_qual[d1.seq].current_pos_pediatric
		,current_pos_pediatric_icu =hrts_v3->summary_qual[d1.seq].current_pos_pediatric_icu
		,current_pos_pediatric_vent =hrts_v3->summary_qual[d1.seq].current_pos_pediatric_vent
		,current_pend_pediatric =hrts_v3->summary_qual[d1.seq].current_pend_pediatric
		,current_pend_pediatric_icu =hrts_v3->summary_qual[d1.seq].current_pend_pediatric_icu
		,current_pend_pediatric_vent =hrts_v3->summary_qual[d1.seq].current_pend_pediatric_vent
		,prev_day_admiss_confirmed_covid =hrts_v3->summary_qual[d1.seq].prev_day_admiss_confirmed_covid
		,previous_day_admission_adult_covid_confirmed_18_19 =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_18_19
		,previous_day_admission_adult_covid_confirmed_20_29 =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_20_29
		,previous_day_admission_adult_covid_confirmed_30_39 =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_30_39
		,previous_day_admission_adult_covid_confirmed_40_49 =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_40_49
		,previous_day_admission_adult_covid_confirmed_50_59 =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_50_59
		,previous_day_admission_adult_covid_confirmed_60_69 =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_60_69
		,previous_day_admission_adult_covid_confirmed_70_79 =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_70_79
		,previous_day_admission_adult_covid_confirmed_80_plus =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_80_plus
		,previous_day_admission_adult_covid_confirmed_unknown_age =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_unknown_age
		,previous_day_admission_adult_covid_suspected =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected
		,previous_day_admission_adult_covid_suspected_18_19 =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_18_19
		,previous_day_admission_adult_covid_suspected_20_29 =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_20_29
		,previous_day_admission_adult_covid_suspected_30_39 =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_30_39
		,previous_day_admission_adult_covid_suspected_40_49 =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_40_49
		,previous_day_admission_adult_covid_suspected_50_59 =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_50_59
		,previous_day_admission_adult_covid_suspected_60_69 =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_60_69
		,previous_day_admission_adult_covid_suspected_70_79 =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_70_79
		,previous_day_admission_adult_covid_suspected_80_plus =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_80_plus
		,previous_day_admission_adult_covid_suspected_unknown_age =
				hrts_v3->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_unknown_age
		,prev_day_pediatric_conf =hrts_v3->summary_qual[d1.seq].prev_day_pediatric_conf
		,prev_day_pediatric_susp =hrts_v3->summary_qual[d1.seq].prev_day_pediatric_susp
		,hospital_onset =hrts_v3->summary_qual[d1.seq].hospital_onset
		,previous_day_total_ed_visits =hrts_v3->summary_qual[d1.seq].previous_day_total_ed_visits
		,previous_day_covid_ed_visits =hrts_v3->summary_qual[d1.seq].previous_day_covid_ed_visits
		,ed_or_overflow =hrts_v3->summary_qual[d1.seq].ed_or_overflow
		,ed_or_overflow_and_ventilated =hrts_v3->summary_qual[d1.seq].ed_or_overflow_and_ventilated
		,previous_day_death_covid =hrts_v3->summary_qual[d1.seq].previous_day_death_covid
		,prev_day_rdv_used =hrts_v3->summary_qual[d1.seq].prev_day_rdv_used
		,prev_day_rdv_inv =hrts_v3->summary_qual[d1.seq].prev_day_rdv_inv
		,crit_staffing_shortage_today = substring(1,3,hrts_v3->summary_qual[d1.seq].crit_staffing_shortage_today)
		,crit_staffing_shortage_week = substring(1,3,hrts_v3->summary_qual[d1.seq].crit_staffing_shortage_week)
		,staffing_shortage_details = substring(1,300,hrts_v3->summary_qual[d1.seq].staffing_shortage_details)
		,ppe_supply_mgmt_source = substring(1,300,hrts_v3->summary_qual[d1.seq].ppe_supply_mgmt_source)
		,mechanical_adult_ventilators =hrts_v3->summary_qual[d1.seq].mechanical_adult_ventilators
		,mechanical_adult_vents_in_use =hrts_v3->summary_qual[d1.seq].mechanical_adult_vents_in_use
		,mechanical_ped_ventilators =hrts_v3->summary_qual[d1.seq].mechanical_ped_ventilators
		,mechanical_ped_vents_in_use =hrts_v3->summary_qual[d1.seq].mechanical_ped_vents_in_use
		,oh_ventilator_supplies_days =hrts_v3->summary_qual[d1.seq].oh_ventilator_supplies_days
		,able_obtain_vent_supp = substring(1,3,hrts_v3->summary_qual[d1.seq].able_obtain_vent_supp)
		,able_mtn_vent_3day_supp = substring(1,3,hrts_v3->summary_qual[d1.seq].able_mtn_vent_3day_supp)
		,able_obtain_vent_meds = substring(1,3,hrts_v3->summary_qual[d1.seq].able_obtain_vent_meds)
		,able_mtn_vent_3day_meds = substring(1,3,hrts_v3->summary_qual[d1.seq].able_mtn_vent_3day_meds)
		,oh_n95_respirators_units =hrts_v3->summary_qual[d1.seq].oh_n95_respirators_units
		,oh_n95_respirators_days =hrts_v3->summary_qual[d1.seq].oh_n95_respirators_days
		,able_obtain_n95_masks = substring(1,3,hrts_v3->summary_qual[d1.seq].able_obtain_n95_masks)
		,able_mtn_n95_masks = substring(1,3,hrts_v3->summary_qual[d1.seq].able_mtn_n95_masks)
		,reusuable_n95_masks_used = substring(1,3,hrts_v3->summary_qual[d1.seq].reusuable_n95_masks_used)
		,oh_paprs_units =hrts_v3->summary_qual[d1.seq].oh_paprs_units
		,able_obtain_paprs = substring(1,3,hrts_v3->summary_qual[d1.seq].able_obtain_paprs)
		,able_mtn_3day_paprs = substring(1,3,hrts_v3->summary_qual[d1.seq].able_mtn_3day_paprs)
		,reusable_paprs_elasto_used = substring(1,3,hrts_v3->summary_qual[d1.seq].reusable_paprs_elasto_used)
		,oh_supply_surgical_masks_units =hrts_v3->summary_qual[d1.seq].oh_supply_surgical_masks_units
		,oh_supply_surgical_masks_days =hrts_v3->summary_qual[d1.seq].oh_supply_surgical_masks_days
		,able_obtain_surg_masks = substring(1,3,hrts_v3->summary_qual[d1.seq].able_obtain_surg_masks)
		,able_mtn_3day_surg_masks = substring(1,3,hrts_v3->summary_qual[d1.seq].able_mtn_3day_surg_masks)
		,oh_eye_protection_units =hrts_v3->summary_qual[d1.seq].oh_eye_protection_units
		,oh_eye_protection_days =hrts_v3->summary_qual[d1.seq].oh_eye_protection_days
		,able_obtain_eye_protection = substring(1,3,hrts_v3->summary_qual[d1.seq].able_obtain_eye_protection)
		,able_mtn_3day_eye_prot = substring(1,3,hrts_v3->summary_qual[d1.seq].able_mtn_3day_eye_prot)
		,oh_single_use_surg_gowns_units =hrts_v3->summary_qual[d1.seq].oh_single_use_surg_gowns_units
		,oh_single_use_surg_gowns_days =hrts_v3->summary_qual[d1.seq].oh_single_use_surg_gowns_days
		,able_obtain_single_use_gowns = substring(1,3,hrts_v3->summary_qual[d1.seq].able_obtain_single_use_gowns)
		,able_mtn_3day_singuse_gown = substring(1,3,hrts_v3->summary_qual[d1.seq].able_mtn_3day_singuse_gown)
		,oh_gloves_units =hrts_v3->summary_qual[d1.seq].oh_gloves_units
		,oh_gloves_days =hrts_v3->summary_qual[d1.seq].oh_gloves_days
		,able_obtain_gloves = substring(1,3,hrts_v3->summary_qual[d1.seq].able_obtain_gloves)
		,able_mtn_3day_gloves = substring(1,3,hrts_v3->summary_qual[d1.seq].able_mtn_3day_gloves)
		,oh_laund_surg_gowns_units =hrts_v3->summary_qual[d1.seq].oh_laund_surg_gowns_units
		,able_obtain_launderable_gowns = substring(1,3,hrts_v3->summary_qual[d1.seq].able_obtain_launderable_gowns)
		,reusable_isolation_gowns_used = substring(1,3,hrts_v3->summary_qual[d1.seq].reusable_isolation_gowns_used)
		,able_mtn_3day_pharyngeal_swabs = substring(1,3,hrts_v3->summary_qual[d1.seq].able_mtn_3day_pharyngeal_swabs)
		,able_mtn_lab_nasal_swabs = substring(1,3,hrts_v3->summary_qual[d1.seq].able_mtn_lab_nasal_swabs)
		,able_mtn_3day_viral_trans_media = substring(1,3,hrts_v3->summary_qual[d1.seq].able_mtn_3day_viral_trans_media)
		,ant_medical_sup_med_short = substring(1,3,hrts_v3->summary_qual[d1.seq].ant_medical_sup_med_short)
 
	from
	(dummyt d1 with seq=hrts_v3->summary_cnt)
	plan d1
	;007 order by
	;007 hosp_name
	with nocounter,separator = " ", format,maxcol=32000
 
	if (program_log->run_from_ops = 1)
		call writeLog(build2("---->addAttachment(",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),")"))
		;call addAttachment(program_log->files.file_path, replace(t_rec->output_qual[i].output_file,"cclscratch:",""))
		execute cov_astream_file_transfer "cclscratch",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),"","CP"
	endif
 
 elseif (t_rec->output_qual[i].prompt_report_type = 13) ;hrts_v4
 	call writeLog(build2("--->HRTS v4 (hrts_v4) [13]"))
	select
		if (program_log->run_from_ops = 1)
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,maxcol=32000,format
		else
			with nocounter,separator = " ", format,maxcol=32000
		endif
	into value(t_rec->output_qual[i].output_file)
		 contact_email = substring(1,300,hrts_v4->summary_qual[d1.seq].contact_email)
		,reporting_for_date = substring(1,300,hrts_v4->summary_qual[d1.seq].reporting_for_date)
		,facility_id = substring(1,300,hrts_v4->summary_qual[d1.seq].facility_id)
		,hosp_name = substring(1,300,hrts_v4->summary_qual[d1.seq].hosp_name)
		,current_pos =hrts_v4->summary_qual[d1.seq].current_pos
		,current_pos_icu =hrts_v4->summary_qual[d1.seq].current_pos_icu
		,current_pos_vent =hrts_v4->summary_qual[d1.seq].current_pos_vent
		,current_pend =hrts_v4->summary_qual[d1.seq].current_pend
		,current_pend_icu =hrts_v4->summary_qual[d1.seq].current_pend_icu
		,current_pend_vent =hrts_v4->summary_qual[d1.seq].current_pend_vent
		,current_pos_pediatric =hrts_v4->summary_qual[d1.seq].current_pos_pediatric
		,current_pos_pediatric_icu =hrts_v4->summary_qual[d1.seq].current_pos_pediatric_icu
		,current_pos_pediatric_vent =hrts_v4->summary_qual[d1.seq].current_pos_pediatric_vent
		,current_pend_pediatric =hrts_v4->summary_qual[d1.seq].current_pend_pediatric
		,current_pend_pediatric_icu =hrts_v4->summary_qual[d1.seq].current_pend_pediatric_icu
		,current_pend_pediatric_vent =hrts_v4->summary_qual[d1.seq].current_pend_pediatric_vent
		,prev_day_admiss_confirmed_covid =hrts_v4->summary_qual[d1.seq].prev_day_admiss_confirmed_covid
		,previous_day_admission_adult_covid_confirmed_18_19 =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_18_19
		,previous_day_admission_adult_covid_confirmed_20_29 =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_20_29
		,previous_day_admission_adult_covid_confirmed_30_39 =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_30_39
		,previous_day_admission_adult_covid_confirmed_40_49 =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_40_49
		,previous_day_admission_adult_covid_confirmed_50_59 =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_50_59
		,previous_day_admission_adult_covid_confirmed_60_69 =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_60_69
		,previous_day_admission_adult_covid_confirmed_70_79 =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_70_79
		,previous_day_admission_adult_covid_confirmed_80_plus =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_80_plus
		,previous_day_admission_adult_covid_confirmed_unknown_age =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_confirmed_unknown_age
		,previous_day_admission_adult_covid_suspected =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected
		,previous_day_admission_adult_covid_suspected_18_19 =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_18_19
		,previous_day_admission_adult_covid_suspected_20_29 =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_20_29
		,previous_day_admission_adult_covid_suspected_30_39 =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_30_39
		,previous_day_admission_adult_covid_suspected_40_49 =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_40_49
		,previous_day_admission_adult_covid_suspected_50_59 =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_50_59
		,previous_day_admission_adult_covid_suspected_60_69 =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_60_69
		,previous_day_admission_adult_covid_suspected_70_79 =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_70_79
		,previous_day_admission_adult_covid_suspected_80_plus =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_80_plus
		,previous_day_admission_adult_covid_suspected_unknown_age =
				hrts_v4->summary_qual[d1.seq].previous_day_admission_adult_covid_suspected_unknown_age
		,prev_day_pediatric_conf =hrts_v4->summary_qual[d1.seq].prev_day_pediatric_conf
		,prev_day_pediatric_susp =hrts_v4->summary_qual[d1.seq].prev_day_pediatric_susp
		,hospital_onset =hrts_v4->summary_qual[d1.seq].hospital_onset
		,previous_day_total_ed_visits =hrts_v4->summary_qual[d1.seq].previous_day_total_ed_visits
		,previous_day_covid_ed_visits =hrts_v4->summary_qual[d1.seq].previous_day_covid_ed_visits
		,ed_or_overflow =hrts_v4->summary_qual[d1.seq].ed_or_overflow
		,ed_or_overflow_and_ventilated =hrts_v4->summary_qual[d1.seq].ed_or_overflow_and_ventilated
		,previous_day_death_covid =hrts_v4->summary_qual[d1.seq].previous_day_death_covid
		,prev_day_rdv_used =hrts_v4->summary_qual[d1.seq].prev_day_rdv_used
		,prev_day_rdv_inv =hrts_v4->summary_qual[d1.seq].prev_day_rdv_inv
		,crit_staffing_shortage_today = substring(1,3,hrts_v4->summary_qual[d1.seq].crit_staffing_shortage_today)
		,crit_staffing_shortage_week = substring(1,3,hrts_v4->summary_qual[d1.seq].crit_staffing_shortage_week)
		,staffing_shortage_details = substring(1,300,hrts_v4->summary_qual[d1.seq].staffing_shortage_details)
		,ppe_supply_mgmt_source = substring(1,300,hrts_v4->summary_qual[d1.seq].ppe_supply_mgmt_source)
		,mechanical_adult_ventilators =hrts_v4->summary_qual[d1.seq].mechanical_adult_ventilators
		,mechanical_adult_vents_in_use =hrts_v4->summary_qual[d1.seq].mechanical_adult_vents_in_use
		,mechanical_ped_ventilators =hrts_v4->summary_qual[d1.seq].mechanical_ped_ventilators
		,mechanical_ped_vents_in_use =hrts_v4->summary_qual[d1.seq].mechanical_ped_vents_in_use
		,oh_ventilator_supplies_days =hrts_v4->summary_qual[d1.seq].oh_ventilator_supplies_days
		,able_obtain_vent_supp = substring(1,3,hrts_v4->summary_qual[d1.seq].able_obtain_vent_supp)
		,able_mtn_vent_3day_supp = substring(1,3,hrts_v4->summary_qual[d1.seq].able_mtn_vent_3day_supp)
		,able_obtain_vent_meds = substring(1,3,hrts_v4->summary_qual[d1.seq].able_obtain_vent_meds)
		,able_mtn_vent_3day_meds = substring(1,3,hrts_v4->summary_qual[d1.seq].able_mtn_vent_3day_meds)
		,oh_n95_respirators_units =hrts_v4->summary_qual[d1.seq].oh_n95_respirators_units
		,oh_n95_respirators_days =hrts_v4->summary_qual[d1.seq].oh_n95_respirators_days
		,able_obtain_n95_masks = substring(1,3,hrts_v4->summary_qual[d1.seq].able_obtain_n95_masks)
		,able_mtn_n95_masks = substring(1,3,hrts_v4->summary_qual[d1.seq].able_mtn_n95_masks)
		,reusuable_n95_masks_used = substring(1,3,hrts_v4->summary_qual[d1.seq].reusuable_n95_masks_used)
		,oh_paprs_units =hrts_v4->summary_qual[d1.seq].oh_paprs_units
		,able_obtain_paprs = substring(1,3,hrts_v4->summary_qual[d1.seq].able_obtain_paprs)
		,able_mtn_3day_paprs = substring(1,3,hrts_v4->summary_qual[d1.seq].able_mtn_3day_paprs)
		,reusable_paprs_elasto_used = substring(1,3,hrts_v4->summary_qual[d1.seq].reusable_paprs_elasto_used)
		,oh_supply_surgical_masks_units =hrts_v4->summary_qual[d1.seq].oh_supply_surgical_masks_units
		,oh_supply_surgical_masks_days =hrts_v4->summary_qual[d1.seq].oh_supply_surgical_masks_days
		,able_obtain_surg_masks = substring(1,3,hrts_v4->summary_qual[d1.seq].able_obtain_surg_masks)
		,able_mtn_3day_surg_masks = substring(1,3,hrts_v4->summary_qual[d1.seq].able_mtn_3day_surg_masks)
		,oh_eye_protection_units =hrts_v4->summary_qual[d1.seq].oh_eye_protection_units
		,oh_eye_protection_days =hrts_v4->summary_qual[d1.seq].oh_eye_protection_days
		,able_obtain_eye_protection = substring(1,3,hrts_v4->summary_qual[d1.seq].able_obtain_eye_protection)
		,able_mtn_3day_eye_prot = substring(1,3,hrts_v4->summary_qual[d1.seq].able_mtn_3day_eye_prot)
		,oh_single_use_surg_gowns_units =hrts_v4->summary_qual[d1.seq].oh_single_use_surg_gowns_units
		,oh_single_use_surg_gowns_days =hrts_v4->summary_qual[d1.seq].oh_single_use_surg_gowns_days
		,able_obtain_single_use_gowns = substring(1,3,hrts_v4->summary_qual[d1.seq].able_obtain_single_use_gowns)
		,able_mtn_3day_singuse_gown = substring(1,3,hrts_v4->summary_qual[d1.seq].able_mtn_3day_singuse_gown)
		,oh_gloves_units =hrts_v4->summary_qual[d1.seq].oh_gloves_units
		,oh_gloves_days =hrts_v4->summary_qual[d1.seq].oh_gloves_days
		,able_obtain_gloves = substring(1,3,hrts_v4->summary_qual[d1.seq].able_obtain_gloves)
		,able_mtn_3day_gloves = substring(1,3,hrts_v4->summary_qual[d1.seq].able_mtn_3day_gloves)
		,oh_laund_surg_gowns_units =hrts_v4->summary_qual[d1.seq].oh_laund_surg_gowns_units
		,able_obtain_launderable_gowns = substring(1,3,hrts_v4->summary_qual[d1.seq].able_obtain_launderable_gowns)
		,reusable_isolation_gowns_used = substring(1,3,hrts_v4->summary_qual[d1.seq].reusable_isolation_gowns_used)
		,able_mtn_3day_pharyngeal_swabs = substring(1,3,hrts_v4->summary_qual[d1.seq].able_mtn_3day_pharyngeal_swabs)
		,able_mtn_lab_nasal_swabs = substring(1,3,hrts_v4->summary_qual[d1.seq].able_mtn_lab_nasal_swabs)
		,able_mtn_3day_viral_trans_media = substring(1,3,hrts_v4->summary_qual[d1.seq].able_mtn_3day_viral_trans_media)
		,ant_medical_sup_med_short = substring(1,3,hrts_v4->summary_qual[d1.seq].ant_medical_sup_med_short)
		,current_pos_flu = hrts_v4->summary_qual[d1.seq].current_pos_flu
		,prev_day_flu_admiss = hrts_v4->summary_qual[d1.seq].prev_day_flu_admiss
		,current_pos_flu_icu = hrts_v4->summary_qual[d1.seq].current_pos_flu_icu
		,current_pos_flu_covid = hrts_v4->summary_qual[d1.seq].current_pos_flu_covid
		,prev_day_flu_deaths = hrts_v4->summary_qual[d1.seq].prev_day_flu_deaths
		,prev_day_flu_covid_deaths = hrts_v4->summary_qual[d1.seq].prev_day_flu_covid_deaths
		,positive_patients_with_vaccine = hrts_v4->summary_qual[d1.seq].positive_patients_with_vaccine
	from
	(dummyt d1 with seq=hrts_v4->summary_cnt)
	plan d1
	;007 order by
	;007	hosp_name
	with nocounter,separator = " ", format,maxcol=32000
 
	if (program_log->run_from_ops = 1)
		call writeLog(build2("---->addAttachment(",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),")"))
		;call addAttachment(program_log->files.file_path, replace(t_rec->output_qual[i].output_file,"cclscratch:",""))
		execute cov_astream_file_transfer "cclscratch",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),"","CP"
 
		set dclcom = build2("cp /cerner/d_p0665/cclscratch/",trim(replace(t_rec->output_qual[i].output_file,"cclscratch:",""))
							," /cerner/d_p0665/cclscratch/covid_hrts_p0665.csv")
		set dclstat = 0
		call writeLog(build2("---->copying file = ",dclcom))
		call dcl(dclcom, size(trim(dclcom)), dclstat)
		execute cov_astream_file_transfer "cclscratch","covid_hrts_p0665.csv","Extracts/HRTS","MV"
 
	endif
 
 
 
 
 elseif (t_rec->output_qual[i].prompt_report_type = 11) ;zzFull Details
 	call writeLog(build2("--->zzFull Details (t_output) [11]"))
	select
		if (program_log->run_from_ops = 1)
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,format
		else
			with nocounter,separator = " ", format
		endif
	into value(t_rec->output_qual[i].output_file)
		 facility 				= trim(t_output->qual[d1.seq].facility)
		,unit	 				= trim(substring(1,30,t_output->qual[d1.seq].unit))
		,encntr_type			= trim(substring(1,30,t_output->qual[d1.seq].encntr_type))
		,patient				= substring(1,50,t_output->qual[d1.seq].patient_name)
		,fin					= substring(1,10,t_output->qual[d1.seq].fin)
		,room_bed				= substring(1,10,t_output->qual[d1.seq].room_bed)
		,location_class_1		= substring(1,10,t_output->qual[d1.seq].location_class_1)
		,arrive_dt_tm			= substring(1,20,t_output->qual[d1.seq].arrive_dt_tm)
		,reg_dt_tm				= substring(1,20,t_output->qual[d1.seq].reg_dt_tm)
		,inpatient_dt_tm		= substring(1,20,t_output->qual[d1.seq].inpatient_dt_tm)
		,observation_dt_tm		= substring(1,20,t_output->qual[d1.seq].observation_dt_tm)
		,disch_dt_tm			= substring(1,20,t_output->qual[d1.seq].disch_dt_tm)
		,expired_dt_tm			= substring(1,20,t_output->qual[d1.seq].expired_dt_tm)
		,los_days				= substring(1,6,cnvtstring(round(t_output->qual[d1.seq].los_days,0),17,0))
		,los_hours				= substring(1,6,cnvtstring(round(t_output->qual[d1.seq].los_hours,0),17,0))
		,pso					= substring(1,50,t_output->qual[d1.seq].pso)
		,diagnosis				= substring(1,50,t_output->qual[d1.seq].diagnosis)
		,covid19_order			= substring(1,50,t_output->qual[d1.seq].covid19_order)
		,covid19_order_dt_tm	= substring(1,50,t_output->qual[d1.seq].covid19_order_dt_tm)
		,covid19_result			= substring(1,50,t_output->qual[d1.seq].covid19_result)
		,covid19_result_dt_tm	= substring(1,50,t_output->qual[d1.seq].covid19_result_dt_tm)
		,ventilator_type		= substring(1,50,t_output->qual[d1.seq].ventilator_type)
		,ventilator				= substring(1,50,t_output->qual[d1.seq].ventilator)
		,ventilator_model		= substring(1,20,t_output->qual[d1.seq].ventilator_model)
		,ventilator_dt_tm		= substring(1,50,t_output->qual[d1.seq].ventilator_dt_tm)
		,suspected_onset_dt_tm	= substring(1,50,t_output->qual[d1.seq].suspected_onset_dt_tm)
		,positive_onset_dt_tm	= substring(1,50,t_output->qual[d1.seq].positive_onset_dt_tm)
		,location_history		= substring(1,100,t_output->qual[d1.seq].location_history)
		,person_id				= t_output->qual[d1.seq].person_id
		,encntr_id				= t_output->qual[d1.seq].encntr_id
		,positive_ind			= t_output->qual[d1.seq].positive_ind
		,suspected_ind			= t_output->qual[d1.seq].suspected_ind
		,ventilator_ind			= t_output->qual[d1.seq].ventilator_ind
		,covenant_vent_stock_ind= t_output->qual[d1.seq].covenant_vent_stock_ind
		,expired_ind			= t_output->qual[d1.seq].expired_ind
		,historical_ind			= t_output->qual[d1.seq].historical_ind
		,ed_admit_suspected_ind	= t_output->qual[d1.seq].ed_admit_suspected_ind
		,ed_admit_confirmed_ind	= t_output->qual[d1.seq].ed_admit_confirmed_ind
		,previous_admission_ind	= t_output->qual[d1.seq].previous_admission_ind
		,previous_onset_ind		= t_output->qual[d1.seq].previous_onset_ind
	from
		(dummyt d1 with seq=t_output->cnt)
	plan d1
	order by
		 facility
		,unit
		,room_bed
		,patient
	with nocounter,separator = " ", format
 
	if (program_log->run_from_ops = 1)
		call writeLog(build2("---->addAttachment(",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),")"))
		;call addAttachment(program_log->files.file_path, replace(t_rec->output_qual[i].output_file,"cclscratch:",""))
		execute cov_astream_file_transfer "cclscratch",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),"","CP"
 
 
	endif
 elseif (t_rec->output_qual[i].prompt_report_type = 0) ;Full Details
 	call writeLog(build2("--->Full Details (t2_output) [0]"))
	select
		if (program_log->run_from_ops = 1)
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,format
		else
			with nocounter,separator = " ", format
		endif
	into value(t_rec->output_qual[i].output_file)
		 facility 				= trim(t2_output->qual[d1.seq].facility)
		,unit	 				= trim(substring(1,30,t2_output->qual[d1.seq].unit))
		,encntr_type			= trim(substring(1,30,t2_output->qual[d1.seq].encntr_type))
		,patient				= substring(1,50,t2_output->qual[d1.seq].patient_name)
		,age					= substring(1,50,t2_output->qual[d1.seq].age)
		,dob					= substring(1,50,t2_output->qual[d1.seq].dob)
		,fin					= substring(1,10,t2_output->qual[d1.seq].fin)
		,room_bed				= substring(1,10,t2_output->qual[d1.seq].room_bed)
		,location_class_1		= substring(1,10,t2_output->qual[d1.seq].location_class_1)
		,arrive_dt_tm			= substring(1,20,t2_output->qual[d1.seq].arrive_dt_tm)
		,reg_dt_tm				= substring(1,20,t2_output->qual[d1.seq].reg_dt_tm)
		,inpatient_dt_tm		= substring(1,20,t2_output->qual[d1.seq].inpatient_dt_tm)
		,observation_dt_tm		= substring(1,20,t2_output->qual[d1.seq].observation_dt_tm)
		,disch_dt_tm			= substring(1,20,t2_output->qual[d1.seq].disch_dt_tm)
		,expired_dt_tm			= substring(1,20,t2_output->qual[d1.seq].expired_dt_tm)
		,los_days				= substring(1,6,cnvtstring(round(t2_output->qual[d1.seq].los_days,0),17,0))
		,los_hours				= substring(1,6,cnvtstring(round(t2_output->qual[d1.seq].los_hours,0),17,0))
		,pso					= substring(1,50,t2_output->qual[d1.seq].pso)
		,diagnosis				= substring(1,100,t2_output->qual[d1.seq].diagnosis)
		,diagnosis_display		= substring(1,100,t2_output->qual[d1.seq].diagnosis_display)
		,diagnosis_suspected_dt	= substring(1,50,t2_output->qual[d1.seq].diagnosis_suspected_dt)
		,diagnosis_confirmed_dt	= substring(1,50,t2_output->qual[d1.seq].diagnosis_confirmed_dt)
		,covid19_order			= substring(1,100,t2_output->qual[d1.seq].covid19_order)
		,covid19_order_dt_tm	= substring(1,50,t2_output->qual[d1.seq].covid19_order_dt_tm)
		,covid19_result			= substring(1,50,t2_output->qual[d1.seq].covid19_result)
		,covid19_result_dt_tm	= substring(1,50,t2_output->qual[d1.seq].covid19_result_dt_tm)
		,flu_result				= substring(1,50,t2_output->qual[d1.seq].flu_result)
		,flu_result_dt_tm		= substring(1,50,t2_output->qual[d1.seq].flu_result_dt_tm)
		,isolation_order		= substring(1,100,t2_output->qual[d1.seq].isolation_order)
		,isolation_order_dt_tm	= substring(1,50,t2_output->qual[d1.seq].isolation_order_dt_tm)
		,ventilator_type		= substring(1,50,t2_output->qual[d1.seq].ventilator_type)
		,ventilator				= substring(1,50,t2_output->qual[d1.seq].ventilator)
		,ventilator_model		= substring(1,20,t2_output->qual[d1.seq].ventilator_model)
		,ventilator_dt_tm		= substring(1,50,t2_output->qual[d1.seq].ventilator_dt_tm)
		,suspected_onset_dt_tm	= substring(1,50,t2_output->qual[d1.seq].suspected_onset_dt_tm)
		,positive_onset_dt_tm	= substring(1,50,t2_output->qual[d1.seq].positive_onset_dt_tm)
		,location_history		= substring(1,100,t2_output->qual[d1.seq].location_history)
		,person_id				= t2_output->qual[d1.seq].person_id
		,encntr_id				= t2_output->qual[d1.seq].encntr_id
		,positive_ind			= t2_output->qual[d1.seq].positive_ind
		,suspected_ind			= t2_output->qual[d1.seq].suspected_ind
		,flu_positive_ind		= t2_output->qual[d1.seq].flu_positive_ind
		,ventilator_ind			= t2_output->qual[d1.seq].ventilator_ind
		,covenant_vent_stock_ind= t2_output->qual[d1.seq].covenant_vent_stock_ind
		,expired_ind			= t2_output->qual[d1.seq].expired_ind
		,historical_ind			= t2_output->qual[d1.seq].historical_ind
		,ed_admit_suspected_ind	= t2_output->qual[d1.seq].ed_admit_suspected_ind
		,ed_admit_confirmed_ind	= t2_output->qual[d1.seq].ed_admit_confirmed_ind
		,previous_admission_ind	= t2_output->qual[d1.seq].previous_admission_ind
		,previous_onset_ind		= t2_output->qual[d1.seq].previous_onset_ind
		,hosp_susp_onset		= t2_output->qual[d1.seq].hosp_susp_onset
		,hosp_conf_onset		= t2_output->qual[d1.seq].hosp_conf_onset
		,patient_phone_num		= t2_output->qual[d1.seq].patient_phone_num
		,patient_address_county	= t2_output->qual[d1.seq].patient_address_county
		,patient_gender			= t2_output->qual[d1.seq].patient_gender
		,patient_race			= t2_output->qual[d1.seq].patient_race
		,patient_ethnicity		= t2_output->qual[d1.seq].patient_ethnicity
		,isolation_days			= t2_output->qual[d1.seq].isolation_days
		,accommodation			= t2_output->qual[d1.seq].accommodation
		,covid19_vaccine_ind	= t2_output->qual[d1.seq].covid19_vaccine_ind
		,covid19_vaccine		= substring(1,100,t2_output->qual[d1.seq].covid19_vaccine)
		,covid19_vaccine_yes_no	= substring(1,100,t2_output->qual[d1.seq].covid19_vaccine_yes_no)
		,symptom_result_dt		= substring(1,100,t2_output->qual[d1.seq].symptom_result_dt_tm)
		,date_tested_dt			= substring(1,100,t2_output->qual[d1.seq].date_tested_dt_tm)
	from
		(dummyt d1 with seq=t2_output->cnt)
	plan d1
	order by
		 facility
		,unit
		,room_bed
		,patient
	with nocounter,separator = " ", format
 
	if (program_log->run_from_ops = 1)
		call writeLog(build2("---->addAttachment(",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),")"))
		;call addAttachment(program_log->files.file_path, replace(t_rec->output_qual[i].output_file,"cclscratch:",""))
		execute cov_astream_file_transfer "cclscratch",replace(t_rec->output_qual[i].output_file,"cclscratch:",""),"","CP"
 
		set dclcom = build2("cp /cerner/d_p0665/cclscratch/",trim(replace(t_rec->output_qual[i].output_file,"cclscratch:",""))
							," /cerner/d_p0665/cclscratch/covid_full_details_p0665.csv")
		set dclstat = 0
		call writeLog(build2("---->copying file = ",dclcom))
		call dcl(dclcom, size(trim(dclcom)), dclstat)
		execute cov_astream_file_transfer "cclscratch","covid_full_details_p0665.csv","Extracts/HRTS","MV"
 
	endif
 endif
endfor
 
 
 
 
call writeLog(build2("* END   Output   *******************************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Sending Output *************************************"))
 
if (program_log->run_from_ops = 1)
	call writeLog(build2("** Creating Collections *************************************"))
	call writeLog(build2("->t_rec->collection_cnt=",trim(cnvtstring(t_rec->collection_cnt))))
	for (j=1 to t_rec->collection_cnt)
		call writeLog(build2("->t_rec->collection_qual[",trim(cnvtstring(j)),"].name=",trim(t_rec->collection_qual[j].name)))
		call writeLog(build2("->t_rec->collection_qual[",trim(cnvtstring(j)),"].filename=",trim(t_rec->collection_qual[j].filename)))
		call writeLog(build2("->t_rec->collection_qual[",trim(cnvtstring(j)),"].type_ind="
			,trim(cnvtstring(t_rec->collection_qual[j].type_ind))))
		;set t_rec->collection_qual[j].msg_body = concat("<html><body>")
		for (i=1 to t_rec->output_cnt)
			if (t_rec->output_qual[i].type_ind >= t_rec->collection_qual[j].type_ind)
				call writeLog(build2("-->t_rec->output_qual[",trim(cnvtstring(i)),"].output_file=",trim(t_rec->output_qual[i].output_file)))
				call writeLog(build2("-->t_rec->output_qual[",trim(cnvtstring(i)),"].type_ind="
					,trim(cnvtstring(t_rec->output_qual[i].type_ind))))
				set t_rec->collection_qual[j].dclcom = build2("zip -j "
					,trim(concat(program_log->files.file_path,t_rec->collection_qual[j].filename))
					," "
					,trim(concat(program_log->files.file_path, replace(t_rec->output_qual[i].output_file,"cclscratch:",""))))
				set dclstat = 0
				call writeLog(build2("--->zip attachment file t_rec->collection_qual[j].dclcom = ",t_rec->collection_qual[j].dclcom))
				call dcl(t_rec->collection_qual[j].dclcom, size(trim(t_rec->collection_qual[j].dclcom)), dclstat)
				call writeLog(build2("--->dclstat = ",dclstat))
				set t_rec->collection_qual[j].status_ind = dclstat
				if (t_rec->collection_qual[j].status_ind = 1)
					set t_rec->collection_qual[j].msg_body = concat(
																		 t_rec->collection_qual[j].msg_body
																		,t_rec->output_qual[i].name
																		," ("
																		,replace(t_rec->output_qual[i].output_file,"cclscratch:","")
																		,")"
																		;,"<br>"
																		,t_rec->crlf
																	)
				endif
			endif
		endfor
		;set t_rec->collection_qual[j].msg_body = concat(t_rec->collection_qual[j].msg_body,"</body></html>")
		set t_rec->collection_qual[j].msg_contenttype = concat(
																 t_rec->crlf
																,"mime-version: 1.0"
																,t_rec->crlf
																,"content-type: text/plain"
																,t_rec->crlf
																,t_rec->crlf
																,char(0)
																)
		set t_rec->collection_qual[j].msg_subject = concat("[SECURE]","-TESTING ONLY-",t_rec->collection_qual[j].name)
 
		call writeLog(build2("->checking emails for distribution t_rec->email_dist_cnt=",trim(cnvtstring(t_rec->email_dist_cnt))))
		for (i=1 to t_rec->email_dist_cnt)
			if (t_rec->email_dist[i].type_ind = t_rec->collection_qual[j].type_ind)
 
				if (t_rec->collection_qual[j].status_ind = 1)
					call writeLog(build2("-->Sending Email"))
					call writeLog(build2("->t_rec->email_dist[",trim(cnvtstring(i)),"].email_address=",trim(t_rec->email_dist[i].email_address)))
					call writeLog(build2("->t_rec->email_dist[",trim(cnvtstring(i)),"].type_ind=",trim(cnvtstring(t_rec->email_dist[i].type_ind))))
					call covEmailAttachment(
												"DA2_Admin@cerner.com"
												,t_rec->email_dist[i].email_address
												;,concat(t_rec->collection_qual[j].msg_subject,t_rec->collection_qual[j].msg_contenttype)
												,concat(t_rec->collection_qual[j].msg_subject)
												,t_rec->collection_qual[j].msg_body
												,concat("cclscratch:",t_rec->collection_qual[j].filename)
												,5
											)
				endif
			endif
		endfor
	endfor
 
 
endif
 
call writeLog(build2("* END   Sending Output *************************************"))
call writeLog(build2("************************************************************"))
 
set reply->status_data.status = "S"
 
call writeLog(build2("* START Checking Final Status ******************************"))
if (reply->status_data.status = "F") ;t_rec->cnt = 0
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "RESULTS"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "RESULTS"
	set reply->status_data.subeventstatus.targetobjectvalue = "No data was found"
	go to exit_script
endif
call writeLog(build2("* START Checking Final Status ******************************"))
 
#exit_script
if (reply->status_data.status = "F")
	call writeLog(build2(cnvtrectojson(reply)))
endif
 
if (validate(program_log))
	set t_rec->program_log = cnvtrectojson(program_log)
endif
 
call echojson(t_rec, concat("cclscratch:",t_rec->records_attachment) , 1)
call echojson(t_output, concat("cclscratch:",t_rec->records_attachment) , 1)
call echojson(t2_output, concat("cclscratch:",t_rec->records_attachment) , 1)
call echojson(location_list, concat("cclscratch:",t_rec->records_attachment) , 1)
call echojson(nhsn_covid19, concat("cclscratch:",t_rec->records_attachment) , 1)
call echojson(hrts_covid19, concat("cclscratch:",t_rec->records_attachment) , 1)
call echojson(cov_unit_summary, concat("cclscratch:",t_rec->records_attachment) , 1)
call echojson(tt_covid19, concat("cclscratch:",t_rec->records_attachment) , 1)
call echojson(teletracking, concat("cclscratch:",t_rec->records_attachment) , 1)
call echojson(hrts, concat("cclscratch:",t_rec->records_attachment) , 1)
call echojson(hrts_0806, concat("cclscratch:",t_rec->records_attachment) , 1)
call echojson(hrts_v3, concat("cclscratch:",t_rec->records_attachment) , 1)
call echojson(hrts_v4, concat("cclscratch:",t_rec->records_attachment) , 1)
 
;call addAttachment(program_log->files.file_path, t_rec->records_attachment)
 
execute  cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->records_attachment)
 
call exitScript(null)
;call echorecord(code_values)
;call echorecord(program_log)
;call echorecord(cov_unit_summary)
 
 
end
go
 
