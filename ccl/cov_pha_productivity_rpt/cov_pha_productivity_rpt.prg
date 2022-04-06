/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			Perioperative
	Source file name:	cov_pha_productivity_rpt.prg
	Object name:		cov_pha_productivity_rpt
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s). combined cov_pha_user_productivity_v4
 						and PHARMACY_TAT_EXTRACT

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	03/30/2020  Chad Cummings			Initial Release
001     10/07/2020  Chad Cummings			Added Strata after hours
002		11/04/2020  Chad Cummings			CR-8829: Break/Fix: Update Pharmacy Productivity Strata Extract with Updated Hours
003     11/11/2020  Chad Cummings			TO-DO Add Nurse Unit
******************************************************************************/
drop program cov_pha_productivity_rpt go
create program cov_pha_productivity_rpt
 prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Report Type" = 0
	, "Enter Start Date" = "SYSDATE"
	, "Enter End Date" = "SYSDATE"
	, "Select Facility" = 0
	, "Personnel" = 0
	;<<hidden>>"Search" = ""
	;<<hidden>>"Delete" = "" 

with OUTDEV, REPORT_TYPE, vStart_dt, vEnd_dt, vFacility, NEW_PROVIDER


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
)
endif

set reply->status_data.status = "F"

call set_codevalues(null)
call check_ops(null)

record t_rec
(
	1 cnt					= i2
	1 prompt_outdev			= vc
	1 prompt_report_type	= i2
	1 override_facility		= vc
	1 verify_period_min		= i2
	1 code_values
	 2 cancelcd				= f8 
	 2 pharmordcd			= f8
	 2 fin					= f8 
	 2 ordacttype			= f8 
	 2 dcacttype			= f8 
	 2 modacttype			= f8 
	 2 pharmposcd			= f8 
	 2 pharmt1poscd			= f8
	 2 pharmt2poscd			= f8
	 2 pharmt3poscd			= f8
	 2 pharmmgmntcd			= f8
	 2 ITPharmnetcd			= f8
	 2 techAddrCd			= f8
	1 files
	 2 filename_strata		= vc
	 2 filename_rph			= vc
	 2 filename_details		= vc
	 2 filename_pwafter_hrs	= vc
	 2 filename_pwafter_str	= vc
	 2 cer_temp				= vc
	 2 full_path			= vc
	 2 astream_path			= vc
	 2 astream_mv			= vc
	 2 astream_path_strata	= vc
	 2 astream_mv_strata	= vc
	1 query
	 2 new_provider_var		= vc
	 2 new_provider_id		= f8
	 2 facility_cd			= f8
	 2 facility_var			= vc
	 2 facoper				= vc 
	1 dates
	 2 bdate				= dq8
	 2 edate				= dq8
	1 verify_cnt			= i4
	1 verify_qual[*]
		2 physician_name = vc
		2 orderable = vc
		2 synonym = vc
		2 order_sentence = vc
		2 ordered_date = c10			;
		2 ordered_time = c9				;if outside of 1 hour give credit
		2 orig_order_dt_tm = dq8
		2 action_dt_tm = dq8
		2 verified_day_of_week = i2
		2 verified_time_of_day = i2
		2 verified_date = c10
		2 verified_time = c9
		2 verified_dt_tm = dq8
		2 updt_dt_tm = dq8
		2 verifying_rph = vc
		2 verifying_rph_position = vc
		2 oa_action_type_disp = vc
		2 oa_order_status_disp = vc
		2 ordering_facility = vc
		2 ordering_location = vc
		2 encntr_type = vc
		2 encntr_type_class = vc
		2 patient_type_alias = c1
		2 tat_minutes = f8
		2 tat2_minutes = f8
		2 financial_number = vc
		2 after_hours_ind = i2
		2 rph_qualify_ind = i2
		2 strata_qualify_ind = i2
		2 strata_after_qualify_ind = i2
		2 order_id = f8
		2 loc_facility_cd = f8
		2 loc_nurse_unit_cd = f8 ;003
		2 encntr_id = f8
		2 person_id = f8
		2 verifying_prsnl_id = f8	
		2 location_qualifier = vc
		2 location_company = vc
		2 location_department = vc
		2 original_company = vc			;001
		2 original_department = vc		;001
		
	1 rph_cnt				= i2
	1 rph_qual[*]
		2 verifying_prsnl_id = f8
		2 verifying_prsnl	 = vc
		2 verifying_prsnl_position = vc	
		2 verify_cnt  = i2
		2 verify_qual[*]
			3 verified_dt_tm	 = dq8
			3 verified_date 	 = c10
			3 verified_time 	 = c9
			3 verified_hour		 = c2
			3 verified_cnt		 = i2
			3 order_id			 = f8
			3 location_qualifier = vc
	1 strata_cnt = i2
	1 strata_qual[*]
		2 Company			= vc
		2 Department		= vc
		2 Activity_Code	= vc
		2 Date_Of_Service	= vc
		2 Weight			= vc
		2 IP_Value		= vc
		2 ip_cnt			= i2
		2 OP_Value		= vc
		2 op_cnt			= i2
		2 Total_Value		= vc
		2 total_cnt 		= i2
	1 strata_after_cnt = i2
	1 strata_after_qual[*]
		2 Company			= vc
		2 Department		= vc
		2 Activity_Code	= vc
		2 Date_Of_Service	= vc
		2 Weight			= vc
		2 IP_Value		= vc
		2 ip_cnt			= i2
		2 OP_Value		= vc
		2 op_cnt			= i2
		2 Total_Value		= vc
		2 total_cnt 		= i2
	
)

set t_rec->prompt_outdev = $OUTDEV
set t_rec->prompt_report_type = $REPORT_TYPE

set t_rec->verify_period_min = 60

set t_rec->code_values.pharmordcd	=	UAR_GET_CODE_BY('DISPLAYKEY',106,'PHARMACY')
set t_rec->code_values.cancelcd		=	UAR_GET_CODE_BY('DISPLAYKEY',6004,'CANCELED')
set t_rec->code_values.fin			=	UAR_GET_CODE_BY('DISPLAYKEY',319,'FINNBR')
set t_rec->code_values.ordacttype	=	UAR_GET_CODE_BY('DISPLAYKEY',6003,'ORDER')
set t_rec->code_values.dcacttype	=	UAR_GET_CODE_BY('DISPLAYKEY',6003,'DISCONTINUE')

set t_rec->code_values.modacttype	=	UAR_GET_CODE_BY('DISPLAYKEY',6003,'MODIFY')
set t_rec->code_values.pharmposcd	=	UAR_GET_CODE_BY('DISPLAYKEY',88,'PHARMNETPHARMACIST')
set t_rec->code_values.pharmt1poscd	=	UAR_GET_CODE_BY('DISPLAYKEY',88,'PHARMNETTECHNICIAN1')
set t_rec->code_values.pharmt2poscd	=	UAR_GET_CODE_BY('DISPLAYKEY',88,'PHARMNETTECHNICIAN2')
set t_rec->code_values.pharmt3poscd	=	UAR_GET_CODE_BY('DISPLAYKEY',88,'PHARMNETTECHNICIAN3')
set t_rec->code_values.pharmmgmntcd	=   UAR_GET_CODE_BY('DISPLAYKEY',88,'PHARMNETMANAGEMENT')
set t_rec->code_values.ITPharmnetcd	=	UAR_GET_CODE_BY('DISPLAYKEY',88,'ITPHARMNET')
set t_rec->code_values.techAddrCd	=	UAR_GET_CODE_BY('DISPLAYKEY',212,'TECHNICAL')
																									


if (program_log->run_from_ops = 0)
	if (t_rec->prompt_outdev = "OPS")
		set program_log->run_from_ops = 1
		set program_log->display_on_exit = 0
	endif
endif 

call writeLog(build2("-->Setting up Pharmacist"))
if (($NEW_PROVIDER = 0) or (program_log->run_from_ops = 1))
	set t_rec->query.new_provider_var = "1=1"
else
	set t_rec->query.new_provider_id = $NEW_PROVIDER
	set t_rec->query.new_provider_var = "(orv.review_personnel_id =new_provider_id)" 
endif 

call writeLog(build2("-->Setting up Facility"))
set t_rec->query.facoper =	fillstring(2,' ')
IF (SUBSTRING(1,1,reflect(parameter(parameter2($vFacility),0)))="L")
	SET t_rec->query.facoper = "IN"
ELSEIF (parameter(parameter2($vFacility),1) = 1.0)
	SET t_rec->query.facoper = "!="
ELSE
	SET t_rec->query.facoper = "="
ENDIF

call writeLog(build2("-->Setting up Ops"))
if (program_log->run_from_ops = 1)
	SET t_rec->dates.bdate = datetimefind(CNVTDATETIME(CURDATE-1, 0),'D','B','B')
	SET t_rec->dates.edate = datetimefind(CNVTDATETIME(CURDATE-1, 0),'D','B','E')
else
	SET t_rec->dates.bdate = CNVTDATETIME($vStart_dt)
	SET t_rec->dates.edate = CNVTDATETIME($vEnd_dt)
endif

set t_rec->files.astream_path = build("/nfs/middle_fs/to_client_site/",trim(cnvtlower(curdomain)),"/CernerCCL/")
set t_rec->files.astream_path_strata = build(	"/nfs/middle_fs/to_client_site/"
												,trim(cnvtlower(curdomain))
												,"/ClinicalAncillary/Pharmacy/Strata_Rx/")
set t_rec->files.cer_temp = build("/cerner/d_",cnvtlower(trim(curdomain)),"/temp/")
;CONSTANT(BUILD('cer_temp:','CovHlth_PR_Rx_Stats_',FORMAT(curdate,'yyyymmdd;;q'),'.txt')), PROTECT
set t_rec->files.filename_strata = cnvtlower(build(
													 'cer_temp:'
													,'CovHlth_PR_Rx_Stats_'
													;,format(t_rec->dates.bdate,'yyyymmdd;;q'),'_'
													;,format(t_rec->dates.edate,'yyyymmdd;;q'),'_'
													,format(sysdate,'yyyymmdd;;q')
													;,'_'
													,'.txt')
												)
set t_rec->files.filename_details = cnvtlower(build(
														 'cer_temp:'
														,'V4_CovHlth_Detail_Rx_Stats_'
														,format(t_rec->dates.bdate,'yyyymmdd;;q'),'_'
														,format(t_rec->dates.edate,'yyyymmdd;;q'),'_'
														,format(sysdate,'yyyymmdd_hhmmss;;q')
														,'.csv')
													)
set t_rec->files.filename_rph = cnvtlower(build(
														 'cer_temp:'
														,'V4_CovHlth_rph_Rx_Stats_'
														,format(t_rec->dates.bdate,'yyyymmdd;;q'),'_'
														,format(t_rec->dates.edate,'yyyymmdd;;q'),'_'
														,format(sysdate,'yyyymmdd_hhmmss;;q')
														,'.csv')
													)

set t_rec->files.filename_pwafter_hrs = cnvtlower(build(
														 'cer_temp:'
														,'V4_CovHlth_pwah_Rx_Stats_'
														,format(t_rec->dates.bdate,'yyyymmdd;;q'),'_'
														,format(t_rec->dates.edate,'yyyymmdd;;q'),'_'
														,format(sysdate,'yyyymmdd_hhmmss;;q')
														,'.csv')
													)	
set t_rec->files.filename_pwafter_str = cnvtlower(build(
														 'cer_temp:'
														,'V4_CovHlth_pwah_Strata_Stats_'
														,format(t_rec->dates.bdate,'yyyymmdd;;q'),'_'
														,format(t_rec->dates.edate,'yyyymmdd;;q'),'_'
														,format(sysdate,'yyyymmdd_hhmmss;;q')
														,'.csv')
													)	
													
set program_log->email.subject = concat(
											 program_log->curdomain
											," "
											,trim(check(cnvtlower(program_log->curprog)))
											," "
											,format(sysdate,"yyyy-mm-dd hh:mm:ss;;d")
										)



call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


 SET beg_dt_tm = cnvtdatetime ( $VSTART_DT )
 SET end_dt_tm = cnvtdatetime ( $VEND_DT )
 SET vversion = 0.8
 SET vversion_date = "MAR-12-2012"
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring (12 ," " )
 SET vfin_nbr_cd = 0.0
 SET vpharm_cat_cd = 0.0
 SET vord_action_cd = 0.0
 SET vord_status_cd = 0.0
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET vfin_nbr_cd = code_value
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET vpharm_cat_cd = code_value
 SET code_set = 6003
 SET cdf_meaning = "ORDER"
 EXECUTE cpm_get_cd_for_cdf
 SET vord_action_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET vord_status_cd = code_value
 SET cdcaction = uar_get_code_by ("MEANING" ,6003 ,"DISCONTINUE" )
 SET cordered = uar_get_code_by ("MEANING" ,6004 ,"ORDERED" )
call echorecord(t_rec)
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Order Review Query *********************************"))
call writeLog(build2("-->t_rec->dates.bdate=",format(t_rec->dates.bdate,";;q")))
call writeLog(build2("-->t_rec->dates.edate=",format(t_rec->dates.edate,";;q")))

/* SELECT distinct INTO "nl:"
  physician_name = trim (pmd.name_full_formatted ,3 ) ,
  orderable = trim (o.hna_order_mnemonic ,3 ) ,
  synonym = trim (o.ordered_as_mnemonic ,3 ) ,
  order_sentence = substring (1 ,100 ,check(o.clinical_display_line )) ,
  ordered_date = format(o.orig_order_dt_tm, "mm/dd/yyyy;;d") ,
  ordered_time =format(o.orig_order_dt_tm, "hh:mm:ss;;d") ,
  action_dt_tm =format(oa.action_dt_tm,"@MEDIUMDATETIME") ,
  verified_date = format(ordrev.review_dt_tm, "mm/dd/yyyy;;d") ,
  verified_time = format(ordrev.review_dt_tm, "hh:mm:ss;;d") ,
  verifying_rph = trim (prx.name_full_formatted ,3 ) ,
  oa_action_type_disp = uar_get_code_display (oa.action_type_cd ) ,
  oa_order_status_disp = uar_get_code_display (oa.order_status_cd ) ,
  ordering_facility = trim (cv1.display ,3 ) ,
  ordering_location = trim (cv2.display ,3 ) ,
  tat_minutes = datetimediff (ordrev.review_dt_tm ,o.orig_order_dt_tm ,4 ) ,
  tat2_minutes = datetimediff (ordrev.review_dt_tm ,oa.action_dt_tm ,4 ) ,
  financial_number = trim (ea.alias ,3 ) ,
  order_id = o.order_id
  FROM (code_value cv1 ),
   (code_value cv2 ),
   (orders o ),
   (order_review ordrev ),
   (order_action oa ),
   (prsnl pmd ),
   (prsnl prx ),
   (encntr_loc_hist elh ),
   (encntr_alias ea ),
   (encounter e ),
   (order_review orv)
  plan orv
	where orv.updt_dt_tm BETWEEN cnvtdatetime ( t_rec->dates.bdate ) AND cnvtdatetime ( t_rec->dates.edate ) 
	and orv.review_type_flag = 3
	and NOT orv.review_personnel_id IN (0 , 1 )
    AND orv.reviewed_status_flag != 4 
  join o
   WHERE ((o.catalog_type_cd + 0 ) = vpharm_cat_cd )
   and o.order_id = orv.order_id
   ;AND (o.orig_order_dt_tm 
   JOIN (e
   WHERE (e.encntr_id = o.encntr_id ) )
   JOIN (elh
   WHERE (elh.encntr_id = o.encntr_id )
   AND operator(elh.loc_facility_cd,t_rec->query.facoper,$vFacility)
   AND (elh.beg_effective_dt_tm <= o.orig_order_dt_tm )
   AND (elh.end_effective_dt_tm >= o.orig_order_dt_tm ) )
   JOIN (cv1
   WHERE (elh.loc_facility_cd = cv1.code_value ) )
   JOIN (cv2
   WHERE (elh.loc_nurse_unit_cd = cv2.code_value ) )
   JOIN (ea
   WHERE (o.encntr_id = ea.encntr_id )
   AND (ea.encntr_alias_type_cd = vfin_nbr_cd ) )
   JOIN (oa
   WHERE (o.order_id = oa.order_id )
   AND (oa.needs_verify_ind IN (3 ,
   4 ,
   5 ) )
   ;001 AND (oa.order_status_cd = cordered ) 
   ); 001
   JOIN (pmd
   WHERE (pmd.person_id = oa.order_provider_id ) )
   JOIN (ordrev
   WHERE (oa.order_id = ordrev.order_id )
   AND (oa.action_sequence = ordrev.action_sequence )
   and (ordrev.review_dt_tm BETWEEN cnvtdatetime ( t_rec->dates.bdate ) AND cnvtdatetime ( t_rec->dates.edate ) )
   AND (ordrev.review_type_flag = 3 )
   AND NOT ((ordrev.review_personnel_id IN (0 ,
   1 ) ) )
   AND ((ordrev.reviewed_status_flag + 0 ) != 4 ) 
   and parser(t_rec->query.new_provider_var)
   )
   JOIN (prx
   WHERE (ordrev.review_personnel_id = prx.person_id )
   AND (prx.name_last_key != "SYSTEM" ) 
   and (cnvtlower(prx.name_last_key) != '*test*')
   and (cnvtupper(prx.name_last_key) != 'UA.*'))
*/


SELECT distinct INTO "nl:"
  physician_name = trim (pmd.name_full_formatted ,3 ) ,
  orderable = trim (o.hna_order_mnemonic ,3 ) ,
  synonym = trim (o.ordered_as_mnemonic ,3 ) ,
  order_sentence = substring (1 ,100 ,check(o.clinical_display_line )) ,
  ordered_date = format(o.orig_order_dt_tm, "mm/dd/yyyy;;d") ,
  ordered_time =format(o.orig_order_dt_tm, "hh:mm:ss;;d") ,
  action_dt_tm =format(oa.action_dt_tm,"@MEDIUMDATETIME") ,
  verified_date = format(orv.review_dt_tm, "mm/dd/yyyy;;d") ,
  verified_time = format(orv.review_dt_tm, "hh:mm:ss;;d") ,
  verifying_rph = trim (prx.name_full_formatted ,3 ) ,
  oa_action_type_disp = uar_get_code_display (oa.action_type_cd ) ,
  oa_order_status_disp = uar_get_code_display (oa.order_status_cd ) ,
  ordering_facility = uar_get_code_display(e.loc_facility_cd) ,
  ordering_location = uar_get_code_display (e.loc_nurse_unit_cd ) ,
  tat_minutes = datetimediff (orv.review_dt_tm ,o.orig_order_dt_tm ,4 ) ,
  tat2_minutes = datetimediff (orv.review_dt_tm ,oa.action_dt_tm ,4 ) ,
  financial_number = trim (ea.alias ,3 ) ,
  order_id = o.order_id
from 
	order_review orv ,
	orders o,
	encounter e,
	encntr_alias ea,
	order_action oa,
	prsnl pmd,
	prsnl prx
plan orv
	where orv.updt_dt_tm between cnvtdatetime(t_rec->dates.bdate) and cnvtdatetime(t_rec->dates.edate)
	and orv.review_type_flag = 3
	and not orv.review_personnel_id in (0,1)
    AND orv.reviewed_status_flag != 4 
    and parser(t_rec->query.new_provider_var)
    and orv.review_dt_tm between cnvtdatetime(t_rec->dates.bdate) and cnvtdatetime(t_rec->dates.edate)
join o
	where o.order_id = orv.order_id
	and   o.catalog_type_cd = value(uar_get_code_by("MEANING",6000,"PHARMACY"))
join e
	where e.encntr_id = o.encntr_id
	AND operator(e.loc_facility_cd,t_rec->query.facoper,$vFacility)
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join oa
	where oa.order_id = o.order_id
	and   oa.action_sequence = orv.action_sequence
	and   oa.needs_verify_ind in(3,4,5)
join pmd
	where pmd.person_id = oa.order_provider_id
join prx
   where orv.review_personnel_id = prx.person_id 
   and prx.name_last_key != "SYSTEM" 
   and cnvtlower(prx.name_last_key) != '*test*'
   and cnvtupper(prx.name_last_key) != 'UA.*'
 head report
 	call writeLog(build2("-->Inside Order Verify Query"))
 detail
 	t_rec->verify_cnt = (t_rec->verify_cnt + 1)
	if ((mod(t_rec->verify_cnt,10000) = 1) or (t_rec->verify_cnt = 1))
		stat = alterlist(t_rec->verify_qual,(t_rec->verify_cnt + 9999))
	endif	
	t_rec->verify_qual[t_rec->verify_cnt].physician_name 		= physician_name 
	t_rec->verify_qual[t_rec->verify_cnt].orderable 			= orderable 
	t_rec->verify_qual[t_rec->verify_cnt].synonym 				= synonym 
	t_rec->verify_qual[t_rec->verify_cnt].order_sentence 		= order_sentence 
	t_rec->verify_qual[t_rec->verify_cnt].ordered_date 			= ordered_date 
	t_rec->verify_qual[t_rec->verify_cnt].ordered_time			= ordered_time 
	t_rec->verify_qual[t_rec->verify_cnt].orig_order_dt_tm 		= o.orig_order_dt_tm
	t_rec->verify_qual[t_rec->verify_cnt].action_dt_tm 			= oa.action_dt_tm
	t_rec->verify_qual[t_rec->verify_cnt].verified_day_of_week	= weekday(orv.review_dt_tm)
	t_rec->verify_qual[t_rec->verify_cnt].verified_time_of_day	= cnvttime(orv.review_dt_tm)
	t_rec->verify_qual[t_rec->verify_cnt].verified_date 		= verified_date 
	t_rec->verify_qual[t_rec->verify_cnt].verified_time 		= verified_time 
	t_rec->verify_qual[t_rec->verify_cnt].verified_dt_tm 		= orv.review_dt_tm
	t_rec->verify_qual[t_rec->verify_cnt].updt_dt_tm 			= orv.updt_dt_tm
	t_rec->verify_qual[t_rec->verify_cnt].verifying_rph 		= verifying_rph 
	t_rec->verify_qual[t_rec->verify_cnt].verifying_rph_position = uar_get_code_display(prx.position_cd)
	t_rec->verify_qual[t_rec->verify_cnt].oa_action_type_disp 	= oa_action_type_disp 
	t_rec->verify_qual[t_rec->verify_cnt].oa_order_status_disp	= oa_order_status_disp 
	t_rec->verify_qual[t_rec->verify_cnt].ordering_facility 	= ordering_facility 
	t_rec->verify_qual[t_rec->verify_cnt].ordering_location 	= ordering_location 
	t_rec->verify_qual[t_rec->verify_cnt].encntr_type	 		= uar_get_code_display(e.encntr_type_cd)
	t_rec->verify_qual[t_rec->verify_cnt].encntr_type_class 	= uar_get_code_display(e.encntr_type_class_cd)
	t_rec->verify_qual[t_rec->verify_cnt].tat_minutes 			= tat_minutes 
	t_rec->verify_qual[t_rec->verify_cnt].tat2_minutes 			= tat2_minutes 
	t_rec->verify_qual[t_rec->verify_cnt].financial_number 		= financial_number 
	t_rec->verify_qual[t_rec->verify_cnt].order_id 				= o.order_id 
	t_rec->verify_qual[t_rec->verify_cnt].loc_facility_cd 		= e.loc_facility_cd
	t_rec->verify_qual[t_rec->verify_cnt].loc_nurse_unit_cd		= e.loc_nurse_unit_cd ;003
	t_rec->verify_qual[t_rec->verify_cnt].encntr_id 			= e.encntr_id
	t_rec->verify_qual[t_rec->verify_cnt].person_id 			= e.person_id
	t_rec->verify_qual[t_rec->verify_cnt].verifying_prsnl_id 	= prx.person_id 
 foot report
 	stat = alterlist(t_rec->verify_qual,(t_rec->verify_cnt))
 	call writeLog(build2("<--Leaving Order Verify Query"))	
  WITH nocounter 

call writeLog(build2("* END   Order Review Query *********************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Pharmcist Order Review Query ***********************"))
  
  
SELECT distinct INTO "nl:"
  physician_name = trim (pmd.name_full_formatted ,3 ) ,
  orderable = trim (o.hna_order_mnemonic ,3 ) ,
  synonym = trim (o.ordered_as_mnemonic ,3 ) ,
  order_sentence = substring (1 ,100 ,check(o.clinical_display_line )) ,
  ordered_date = format(o.orig_order_dt_tm, "mm/dd/yyyy;;d") ,
  ordered_time =format(o.orig_order_dt_tm, "hh:mm:ss;;d") ,
  action_dt_tm =format(oa.action_dt_tm,"@MEDIUMDATETIME") ,
  verified_date = format(orv.review_dt_tm, "mm/dd/yyyy;;d") ,
  verified_time = format(orv.review_dt_tm, "hh:mm:ss;;d") ,
  verifying_rph = trim (prx.name_full_formatted ,3 ) ,
  oa_action_type_disp = uar_get_code_display (oa.action_type_cd ) ,
  oa_order_status_disp = uar_get_code_display (oa.order_status_cd ) ,
  ordering_facility = uar_get_code_display(e.loc_facility_cd) ,
  ordering_location = uar_get_code_display (e.loc_nurse_unit_cd ) ,
  tat_minutes = datetimediff (orv.review_dt_tm ,o.orig_order_dt_tm ,4 ) ,
  tat2_minutes = datetimediff (orv.review_dt_tm ,oa.action_dt_tm ,4 ) ,
  financial_number = trim (ea.alias ,3 ) ,
  order_id = o.order_id
from 
	order_review orv ,
	orders o,
	encounter e,
	encntr_alias ea,
	order_action oa,
	prsnl pmd,
	prsnl prx,
	prsnl poa
plan orv
	where orv.updt_dt_tm between cnvtdatetime(t_rec->dates.bdate) and cnvtdatetime(t_rec->dates.edate)
	and orv.review_type_flag = 3
	and not orv.review_personnel_id in (0,1)
    AND orv.reviewed_status_flag != 4 
    and parser(t_rec->query.new_provider_var)
    and orv.review_dt_tm between cnvtdatetime(t_rec->dates.bdate) and cnvtdatetime(t_rec->dates.edate)
join o
	where o.order_id = orv.order_id
	and   o.catalog_type_cd = value(uar_get_code_by("MEANING",6000,"PHARMACY"))
join e
	where e.encntr_id = o.encntr_id
	AND operator(e.loc_facility_cd,t_rec->query.facoper,$vFacility)
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join oa
	where oa.order_id = o.order_id
	and   oa.action_sequence = orv.action_sequence
	and   oa.needs_verify_ind in(0)
join pmd
	where pmd.person_id = oa.order_provider_id
join poa
	where poa.person_id = oa.action_personnel_id
	and   poa.position_cd in (	 value(uar_get_code_by("DISPLAY",88,"PharmNet - Management"))
								,value(uar_get_code_by("DISPLAY",88,"PharmNet - Pharmacist"))
								,value(uar_get_code_by("DISPLAY",88,"DBA"))
							)
join prx
   where orv.review_personnel_id = prx.person_id 
   and prx.name_last_key != "SYSTEM" 
   and cnvtlower(prx.name_last_key) != '*test*'
   and cnvtupper(prx.name_last_key) != 'UA.*'
 head report
 	call writeLog(build2("-->Inside Order Verify Query"))
 detail
 	t_rec->verify_cnt = (t_rec->verify_cnt + 1)
	;if ((mod(t_rec->verify_cnt,10000) = 1) or (t_rec->verify_cnt = 1))
	stat = alterlist(t_rec->verify_qual,(t_rec->verify_cnt))
	;endif	
	t_rec->verify_qual[t_rec->verify_cnt].physician_name 		= physician_name 
	t_rec->verify_qual[t_rec->verify_cnt].orderable 			= orderable 
	t_rec->verify_qual[t_rec->verify_cnt].synonym 				= synonym 
	t_rec->verify_qual[t_rec->verify_cnt].order_sentence 		= order_sentence 
	t_rec->verify_qual[t_rec->verify_cnt].ordered_date 			= ordered_date 
	t_rec->verify_qual[t_rec->verify_cnt].ordered_time			= ordered_time 
	t_rec->verify_qual[t_rec->verify_cnt].orig_order_dt_tm 		= o.orig_order_dt_tm
	t_rec->verify_qual[t_rec->verify_cnt].action_dt_tm 			= oa.action_dt_tm
	t_rec->verify_qual[t_rec->verify_cnt].verified_day_of_week	= weekday(orv.review_dt_tm)
	t_rec->verify_qual[t_rec->verify_cnt].verified_time_of_day	= cnvttime(orv.review_dt_tm)
	t_rec->verify_qual[t_rec->verify_cnt].verified_date 		= verified_date 
	t_rec->verify_qual[t_rec->verify_cnt].verified_time 		= verified_time 
	t_rec->verify_qual[t_rec->verify_cnt].verified_dt_tm 		= orv.review_dt_tm
	t_rec->verify_qual[t_rec->verify_cnt].updt_dt_tm 			= orv.updt_dt_tm
	t_rec->verify_qual[t_rec->verify_cnt].verifying_rph 		= verifying_rph 
	t_rec->verify_qual[t_rec->verify_cnt].verifying_rph_position = uar_get_code_display(prx.position_cd)
	t_rec->verify_qual[t_rec->verify_cnt].oa_action_type_disp 	= oa_action_type_disp 
	t_rec->verify_qual[t_rec->verify_cnt].oa_order_status_disp	= oa_order_status_disp 
	t_rec->verify_qual[t_rec->verify_cnt].ordering_facility 	= ordering_facility 
	t_rec->verify_qual[t_rec->verify_cnt].ordering_location 	= ordering_location 
	t_rec->verify_qual[t_rec->verify_cnt].encntr_type	 		= uar_get_code_display(e.encntr_type_cd)
	t_rec->verify_qual[t_rec->verify_cnt].encntr_type_class 	= uar_get_code_display(e.encntr_type_class_cd)
	t_rec->verify_qual[t_rec->verify_cnt].tat_minutes 			= tat_minutes 
	t_rec->verify_qual[t_rec->verify_cnt].tat2_minutes 			= tat2_minutes 
	t_rec->verify_qual[t_rec->verify_cnt].financial_number 		= financial_number 
	t_rec->verify_qual[t_rec->verify_cnt].order_id 				= o.order_id 
	t_rec->verify_qual[t_rec->verify_cnt].loc_facility_cd 		= e.loc_facility_cd
	t_rec->verify_qual[t_rec->verify_cnt].loc_nurse_unit_cd		= e.loc_nurse_unit_cd ;003
	t_rec->verify_qual[t_rec->verify_cnt].encntr_id 			= e.encntr_id
	t_rec->verify_qual[t_rec->verify_cnt].person_id 			= e.person_id
	t_rec->verify_qual[t_rec->verify_cnt].verifying_prsnl_id 	= prx.person_id 
 foot report
 	stat = alterlist(t_rec->verify_qual,(t_rec->verify_cnt))
 	call writeLog(build2("<--Leaving Order Verify Query"))	
  WITH nocounter 

if (t_rec->verify_cnt = 0)
	set reply->status_data.status = "Z"
	go to exit_script
endif

call writeLog(build2("* END Pharmcist Order Review Query *************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Order Location Review ******************************"))

select into "nl:"
from
	(dummyt d1 with seq=t_rec->verify_cnt)
head report
	call writeLog(build2("-->Inside Order Location Qualifier"))	
detail
	t_rec->verify_qual[d1.seq].location_qualifier = t_rec->verify_qual[d1.seq].ordering_facility
	t_rec->override_facility = "PW"
	
	;RMC
	if (t_rec->verify_qual[d1.seq].ordering_facility = "RMC") 
	 ;Sunday(0),Saturday(6),0700-1700
	 if (t_rec->verify_qual[d1.seq].verified_day_of_week in(0,6))
;002	  if (t_rec->verify_qual[d1.seq].verified_time_of_day between 0700 and 1700)
	if (t_rec->verify_qual[d1.seq].verified_time_of_day between 0700 and 1600) ;002
	  	stat = 0
	  else
	    t_rec->verify_qual[d1.seq].location_qualifier = t_rec->override_facility
	    t_rec->verify_qual[d1.seq].after_hours_ind = 1
	  endif
	 ;Monday(1),Tuesday(2),Wednesday(3),Thursday(4),Friday(5),0630-1700
	 ;002 elseif (t_rec->verify_qual[d1.seq].verified_day_of_week in(1,2,3,4,5))
	 elseif (t_rec->verify_qual[d1.seq].verified_day_of_week in(1,2,3,4,5)) ;002
	  if (t_rec->verify_qual[d1.seq].verified_time_of_day between 0630 and 1800)
	  	stat = 0
	  else
	    t_rec->verify_qual[d1.seq].location_qualifier = t_rec->override_facility
	    t_rec->verify_qual[d1.seq].after_hours_ind = 1
	  endif
	 endif
	endif
	
	;LCMC
	if (t_rec->verify_qual[d1.seq].ordering_facility = "LCMC") 
	 ;Sunday(0),Saturday(6),0600-1600
	 if (t_rec->verify_qual[d1.seq].verified_day_of_week in(0,6))
;002	  if (t_rec->verify_qual[d1.seq].verified_time_of_day between 0600 and 1600)
	  if (t_rec->verify_qual[d1.seq].verified_time_of_day between 0700 and 1600) ;002
	  	stat = 0
	  else
	    t_rec->verify_qual[d1.seq].location_qualifier = t_rec->override_facility
	    t_rec->verify_qual[d1.seq].after_hours_ind = 1
	  endif
	 ;Monday(1),Tuesday(2),Wednesday(3),Thursday(4),Friday(5),0600-1800
	 elseif (t_rec->verify_qual[d1.seq].verified_day_of_week in(1,2,3,4,5))
;002	  if (t_rec->verify_qual[d1.seq].verified_time_of_day between 0600 and 1800)
	if (t_rec->verify_qual[d1.seq].verified_time_of_day between 0630 and 1800) ;002
	  	stat = 0
	  else
	    t_rec->verify_qual[d1.seq].location_qualifier = t_rec->override_facility
	    t_rec->verify_qual[d1.seq].after_hours_ind = 1
	  endif
	 endif
	endif
	
	;FLMC
	if (t_rec->verify_qual[d1.seq].ordering_facility = "FLMC") 
	 ;Sunday(0),Saturday(6),0630-1500
	 if (t_rec->verify_qual[d1.seq].verified_day_of_week in(0,6))
;002	  if (t_rec->verify_qual[d1.seq].verified_time_of_day between 0630 and 1500)
	if (t_rec->verify_qual[d1.seq].verified_time_of_day between 0700 and 1500) ;002
	  	stat = 0
	  else
	    t_rec->verify_qual[d1.seq].location_qualifier = t_rec->override_facility
	    t_rec->verify_qual[d1.seq].after_hours_ind = 1
	  endif
	 ;Monday(1),Tuesday(2),Wednesday(3),Thursday(4),Friday(5),0630-1700
	 elseif (t_rec->verify_qual[d1.seq].verified_day_of_week in(1,2,3,4,5))
;002	  if (t_rec->verify_qual[d1.seq].verified_time_of_day between 0630 and 1700)
	if (t_rec->verify_qual[d1.seq].verified_time_of_day between 0630 and 1800) ;002
	  	stat = 0
	  else
	    t_rec->verify_qual[d1.seq].location_qualifier = t_rec->override_facility
	    t_rec->verify_qual[d1.seq].after_hours_ind = 1
	  endif
	 endif
	endif

	;PBH Peninsula
	if (t_rec->verify_qual[d1.seq].ordering_facility = "PBH Peninsula") 
	 ;Sunday(0),Saturday(6),0700-1500
	 if (t_rec->verify_qual[d1.seq].verified_day_of_week in(0,6))
;002	  if (t_rec->verify_qual[d1.seq].verified_time_of_day between 0700 and 1500)
	if (t_rec->verify_qual[d1.seq].verified_time_of_day between 0700 and 1500) ;002
	  	stat = 0
	  else
	    t_rec->verify_qual[d1.seq].location_qualifier = t_rec->override_facility
	    t_rec->verify_qual[d1.seq].after_hours_ind = 1
	  endif
	 ;Monday(1),Tuesday(2),Wednesday(3),Thursday(4),Friday(5),0700-1800
	 elseif (t_rec->verify_qual[d1.seq].verified_day_of_week in(1,2,3,4,5))
;002	  if (t_rec->verify_qual[d1.seq].verified_time_of_day between 0700 and 1800)
	if (t_rec->verify_qual[d1.seq].verified_time_of_day between 0630 and 1800) ;002
	  	stat = 0
	  else
	    t_rec->verify_qual[d1.seq].location_qualifier = t_rec->override_facility
	    t_rec->verify_qual[d1.seq].after_hours_ind = 1
	  endif
	 endif
	endif
	
	/*start 001*/
	case (t_rec->verify_qual[d1.seq].ordering_facility)
		of ('FLMC'):
			t_rec->verify_qual[d1.seq].original_company = '28'
		of ('FSR'):
			t_rec->verify_qual[d1.seq].original_company = '20'
		of ('FSR INF Oridge'):
			t_rec->verify_qual[d1.seq].original_company = '20.1'
		of ('FSR INF Lenoir'):
			t_rec->verify_qual[d1.seq].original_company = '20.2'
		of ('FSR Pat Neal'):
			t_rec->verify_qual[d1.seq].original_company = '20'
		of ('FSR TCU'):
			t_rec->verify_qual[d1.seq].original_company = '20'
		of ('LCMC'):
			t_rec->verify_qual[d1.seq].original_company = '26'
		of ('LCMC Blount INF'):
			t_rec->verify_qual[d1.seq].original_company = '26.1'
		of ('LCMC Dwtn INF'):
			t_rec->verify_qual[d1.seq].original_company = '26.2'
		of ('LCMC Sevier INF'):
			t_rec->verify_qual[d1.seq].original_company = '26.3'
		of ('LCMC West INF'):
			t_rec->verify_qual[d1.seq].original_company = '26.4'
		of ('MHHS'):
			t_rec->verify_qual[d1.seq].original_company = '25'
		of ('MHHS ASC'):
			t_rec->verify_qual[d1.seq].original_company = '25'
		of ('MHHS Behav Hlth'):
			t_rec->verify_qual[d1.seq].original_company = '25'
		of ('MHHS MRDC'):
			t_rec->verify_qual[d1.seq].original_company = '25'
		of ('MMC'):
			t_rec->verify_qual[d1.seq].original_company = '24'
		of ('MMC Cheyenne'):
			t_rec->verify_qual[d1.seq].original_company = '24'
		of ('PW'):
			t_rec->verify_qual[d1.seq].original_company = '22'
		of ('PW Senior Behav'):
			t_rec->verify_qual[d1.seq].original_company = '22'
		of ('PBH Peninsula'):
			t_rec->verify_qual[d1.seq].original_company = '65'
		of ('RMC'):
			t_rec->verify_qual[d1.seq].original_company = '27'
		else
			t_rec->verify_qual[d1.seq].original_company = '00'
		endcase
		
		case (t_rec->verify_qual[d1.seq].original_company)
			of ('65'): t_rec->verify_qual[d1.seq].original_department = "721500"
		else
			t_rec->verify_qual[d1.seq].original_department = "720000"
		endcase
		/*end 001*/
		
		case (t_rec->verify_qual[d1.seq].location_qualifier)
		of ('FLMC'):
			t_rec->verify_qual[d1.seq].location_company = '28'
		of ('FSR'):
			t_rec->verify_qual[d1.seq].location_company = '20'
		of ('FSR INF Oridge'):
			t_rec->verify_qual[d1.seq].location_company = '20.1'
		of ('FSR INF Lenoir'):
			t_rec->verify_qual[d1.seq].location_company = '20.2'
		of ('FSR Pat Neal'):
			t_rec->verify_qual[d1.seq].location_company = '20'
		of ('FSR TCU'):
			t_rec->verify_qual[d1.seq].location_company = '20'
		of ('LCMC'):
			t_rec->verify_qual[d1.seq].location_company = '26'
		of ('LCMC Blount INF'):
			t_rec->verify_qual[d1.seq].location_company = '26.1'
		of ('LCMC Dwtn INF'):
			t_rec->verify_qual[d1.seq].location_company = '26.2'
		of ('LCMC Sevier INF'):
			t_rec->verify_qual[d1.seq].location_company = '26.3'
		of ('LCMC West INF'):
			t_rec->verify_qual[d1.seq].location_company = '26.4'
		of ('MHHS'):
			t_rec->verify_qual[d1.seq].location_company = '25'
		of ('MHHS ASC'):
			t_rec->verify_qual[d1.seq].location_company = '25'
		of ('MHHS Behav Hlth'):
			t_rec->verify_qual[d1.seq].location_company = '25'
		of ('MHHS MRDC'):
			t_rec->verify_qual[d1.seq].location_company = '25'
		of ('MMC'):
			t_rec->verify_qual[d1.seq].location_company = '24'
		of ('MMC Cheyenne'):
			t_rec->verify_qual[d1.seq].location_company = '24'
		of ('PW'):
			t_rec->verify_qual[d1.seq].location_company = '22'
		of ('PW Senior Behav'):
			t_rec->verify_qual[d1.seq].location_company = '22'
		of ('PBH Peninsula'):
			t_rec->verify_qual[d1.seq].location_company = '65'
		of ('RMC'):
			t_rec->verify_qual[d1.seq].location_company = '27'
		else
			t_rec->verify_qual[d1.seq].location_company = '00'
		endcase
		
		case (t_rec->verify_qual[d1.seq].location_company)
			of ('65'): t_rec->verify_qual[d1.seq].location_department = "721500"
		else
			t_rec->verify_qual[d1.seq].location_department = "720000"
		endcase
		
		if (t_rec->verify_qual[d1.seq].encntr_type_class in('Inpatient','Preadmit','Skilled Nursing'))
			t_rec->verify_qual[d1.seq].patient_type_alias = "I"
		else
			t_rec->verify_qual[d1.seq].patient_type_alias = "O"
		endif

foot report
	call writeLog(build2("<--Leaving Order Location Qualifier"))	
with nocounter

call writeLog(build2("* END   Order Location Review ******************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Pharmacist Review **********************************"))

select into "nl:"
		 verified_date 			= substring(1,10,t_rec->verify_qual[d1.seq].verified_date)
		,verified_time 			= substring(1,9,t_rec->verify_qual[d1.seq].verified_time)
		,verified_dt_tm			= t_rec->verify_qual[d1.seq].verified_dt_tm
		,verified_day_of_week 	= t_rec->verify_qual[d1.seq].verified_day_of_week
		,verified_time_of_day 	= t_rec->verify_qual[d1.seq].verified_time_of_day
		,verifying_rph 			= substring(1,200,t_rec->verify_qual[d1.seq].verifying_rph)
		,order_id 				= t_rec->verify_qual[d1.seq].order_id
		,loc_facility_cd 		= t_rec->verify_qual[d1.seq].loc_facility_cd
		,encntr_id 				= t_rec->verify_qual[d1.seq].encntr_id
		,person_id 				= t_rec->verify_qual[d1.seq].person_id
		,verifying_prsnl_id 	= t_rec->verify_qual[d1.seq].verifying_prsnl_id
from
	(dummyt d1 with seq=t_rec->verify_cnt)
order by
	 verifying_prsnl_id
	,order_id
	,verified_dt_tm
head report
	call writeLog(build2("-->Inside Order Location Qualifier"))	
head verifying_prsnl_id
	call writeLog(build2("--->Adding ",trim(verifying_rph), "(",trim(cnvtstring(verifying_prsnl_id)),")"))	
	t_rec->rph_cnt = (t_rec->rph_cnt + 1)
	if ((mod(t_rec->rph_cnt,100) = 1) or (t_rec->rph_cnt = 1))
		stat = alterlist(t_rec->rph_qual,(t_rec->rph_cnt + 99))
	endif
	t_rec->rph_qual[t_rec->rph_cnt].verifying_prsnl = t_rec->verify_qual[d1.seq].verifying_rph
	t_rec->rph_qual[t_rec->rph_cnt].verifying_prsnl_id = t_rec->verify_qual[d1.seq].verifying_prsnl_id
	t_rec->rph_qual[t_rec->rph_cnt].verifying_prsnl_position = t_rec->verify_qual[d1.seq].verifying_rph_position
head order_id
	call writeLog(build2("--->Found:", t_rec->verify_qual[d1.seq].orderable, "(",trim(cnvtstring(order_id)),")"))
	t_rec->rph_qual[t_rec->rph_cnt].verify_cnt = (t_rec->rph_qual[t_rec->rph_cnt].verify_cnt + 1)
	stat = alterlist(t_rec->rph_qual[t_rec->rph_cnt].verify_qual,t_rec->rph_qual[t_rec->rph_cnt].verify_cnt)
	t_rec->rph_qual[t_rec->rph_cnt].verify_qual[t_rec->rph_qual[t_rec->rph_cnt].verify_cnt].order_id = order_id
	t_rec->rph_qual[t_rec->rph_cnt].verify_qual[t_rec->rph_qual[t_rec->rph_cnt].verify_cnt].verified_time = verified_time
	t_rec->rph_qual[t_rec->rph_cnt].verify_qual[t_rec->rph_qual[t_rec->rph_cnt].verify_cnt].verified_date = verified_date
	t_rec->rph_qual[t_rec->rph_cnt].verify_qual[t_rec->rph_qual[t_rec->rph_cnt].verify_cnt].verified_hour = 
		format(t_rec->verify_qual[d1.seq].verified_dt_tm,"hh;;d")
	t_rec->rph_qual[t_rec->rph_cnt].verify_qual[t_rec->rph_qual[t_rec->rph_cnt].verify_cnt].verified_dt_tm = 
		t_rec->verify_qual[d1.seq].verified_dt_tm
	t_rec->verify_qual[d1.seq].rph_qualify_ind = 1
detail
	if (datetimediff(
						 t_rec->verify_qual[d1.seq].verified_dt_tm
						,t_rec->rph_qual[t_rec->rph_cnt].verify_qual[t_rec->rph_qual[t_rec->rph_cnt].verify_cnt].verified_dt_tm
						,4
					) 
		> t_rec->verify_period_min)
		call writeLog(build2("---->Multiple Verify:", verified_date, "(",trim(verified_time),")"))
		t_rec->rph_qual[t_rec->rph_cnt].verify_cnt = (t_rec->rph_qual[t_rec->rph_cnt].verify_cnt + 1)
		stat = alterlist(t_rec->rph_qual[t_rec->rph_cnt].verify_qual,t_rec->rph_qual[t_rec->rph_cnt].verify_cnt)
		t_rec->rph_qual[t_rec->rph_cnt].verify_qual[t_rec->rph_qual[t_rec->rph_cnt].verify_cnt].order_id = order_id
		t_rec->rph_qual[t_rec->rph_cnt].verify_qual[t_rec->rph_qual[t_rec->rph_cnt].verify_cnt].verified_time = verified_time
		t_rec->rph_qual[t_rec->rph_cnt].verify_qual[t_rec->rph_qual[t_rec->rph_cnt].verify_cnt].verified_date = verified_date
		t_rec->rph_qual[t_rec->rph_cnt].verify_qual[t_rec->rph_qual[t_rec->rph_cnt].verify_cnt].verified_hour = 
			format(t_rec->verify_qual[d1.seq].verified_dt_tm,"hh;;d")
		t_rec->rph_qual[t_rec->rph_cnt].verify_qual[t_rec->rph_qual[t_rec->rph_cnt].verify_cnt].verified_dt_tm = 
			t_rec->verify_qual[d1.seq].verified_dt_tm
		t_rec->verify_qual[d1.seq].rph_qualify_ind = 1
	endif
foot order_id
	row +0
foot verifying_prsnl_id
	row +0
foot report
	call writeLog(build2("<--Leaving Order Location Qualifier"))	
with nocounter

call writeLog(build2("* END   Pharmacist Review *********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Strata Review **************************************"))

select into "nl:"
		 verified_date 			= substring(1,10,t_rec->verify_qual[d1.seq].verified_date)
		,verified_time 			= substring(1,9,t_rec->verify_qual[d1.seq].verified_time)
		,verified_dt_tm			= t_rec->verify_qual[d1.seq].verified_dt_tm
		,verified_day_of_week 	= t_rec->verify_qual[d1.seq].verified_day_of_week
		,verified_time_of_day 	= t_rec->verify_qual[d1.seq].verified_time_of_day
		,verifying_rph 			= substring(1,200,t_rec->verify_qual[d1.seq].verifying_rph)
		,order_id 				= t_rec->verify_qual[d1.seq].order_id
		,loc_facility_cd 		= t_rec->verify_qual[d1.seq].loc_facility_cd
		,encntr_id 				= t_rec->verify_qual[d1.seq].encntr_id
		,person_id 				= t_rec->verify_qual[d1.seq].person_id
		,verifying_prsnl_id 	= t_rec->verify_qual[d1.seq].verifying_prsnl_id
		,location_company		= substring(1,20,t_rec->verify_qual[d1.seq].location_company)
		,location_department	= substring(1,20,t_rec->verify_qual[d1.seq].location_department)
		,patient_type_alias		= substring(1,1,t_rec->verify_qual[d1.seq].patient_type_alias)
from
	(dummyt d1 with seq=t_rec->verify_cnt)
order by
	 verified_date
	,location_company
	,patient_type_alias
	,verifying_prsnl_id
	,order_id
	,verified_dt_tm
head report
	call writeLog(build2("->Inside Strata Qualifier"))	
	check_dt_tm = cnvtdatetime(curdate,curtime3)
	skip_ind = 0
head verified_date
	call writeLog(build2("->Starting ",trim(verified_date)))
head location_company
	call writeLog(build2("--->Looking at ",trim(location_company)))
head patient_type_alias
	call writeLog(build2("---->Adding ",trim(patient_type_alias)))
	t_rec->strata_cnt = (t_rec->strata_cnt + 1)
	stat = alterlist(t_rec->strata_qual,t_rec->strata_cnt)
	t_rec->strata_qual[t_rec->strata_cnt].Date_Of_Service 	= verified_date
	t_rec->strata_qual[t_rec->strata_cnt].Weight 			= "1"
	t_rec->strata_qual[t_rec->strata_cnt].Company 			= location_company
	t_rec->strata_qual[t_rec->strata_cnt].Department 		= location_department
	case (patient_type_alias)
		of "I": t_rec->strata_qual[t_rec->strata_cnt].Activity_Code = "400000UNIT"
		of "O": t_rec->strata_qual[t_rec->strata_cnt].Activity_Code = "420000UNIT"
	endcase
head verifying_prsnl_id
	call writeLog(build2("--->Adding ",trim(verifying_rph), "(",trim(cnvtstring(verifying_prsnl_id)),")"))	
	check_dt_tm = cnvtdatetime(curdate,curtime3)
head order_id
	call writeLog(build2("---->Check Order ",trim(t_rec->verify_qual[d1.seq].orderable), "(",trim(cnvtstring(order_id)),")"))	
	check_dt_tm = t_rec->verify_qual[d1.seq].verified_dt_tm
	skip_ind = -1 ;forces first verification per order per prsnl to be addded
	call writeLog(build2("----->check_dt_tm=",trim(format(check_dt_tm,";;q"))))
	call writeLog(build2("----->skip_ind=",trim(cnvtstring(skip_ind))))
detail
	call writeLog(build2("----->verified_dt_tm=",trim(format(t_rec->verify_qual[d1.seq].verified_dt_tm,";;q"))))
	if (skip_ind >=0)
		if (datetimediff(t_rec->verify_qual[d1.seq].verified_dt_tm,check_dt_tm,4) > t_rec->verify_period_min)
			skip_ind = 0
		else
			skip_ind = 1
		endif
	endif
	call writeLog(build2("----->calculated skip_ind=",trim(cnvtstring(skip_ind))))
	if (skip_ind <= 0)
		case (patient_type_alias)
		of "I": t_rec->strata_qual[t_rec->strata_cnt].ip_cnt = (t_rec->strata_qual[t_rec->strata_cnt].ip_cnt + 1)
		of "O": t_rec->strata_qual[t_rec->strata_cnt].op_cnt = (t_rec->strata_qual[t_rec->strata_cnt].op_cnt + 1)
		endcase	
		t_rec->strata_qual[t_rec->strata_cnt].total_cnt = (t_rec->strata_qual[t_rec->strata_cnt].total_cnt + 1)
		t_rec->verify_qual[d1.seq].strata_qualify_ind = 1
	endif
	skip_ind = 0
foot order_id
	call writeLog(build2("<----Checked Order ",trim(t_rec->verify_qual[d1.seq].orderable), "(",trim(cnvtstring(order_id)),")"))
foot patient_type_alias
	call writeLog(build2("<----Finishing ",trim(patient_type_alias)))
foot location_company
	call writeLog(build2("<---Leaving at ",trim(location_company)))
foot verified_date
	call writeLog(build2("<-Exiting ",trim(verified_date)))	
foot report
	call writeLog(build2("<-Leaving Strata Qualifier"))	
with nocounter


call writeLog(build2("* END   Strata Review **************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Strata After Hours Review **************************"))

select into "nl:"
		 verified_date 			= substring(1,10,t_rec->verify_qual[d1.seq].verified_date)
		,verified_time 			= substring(1,9,t_rec->verify_qual[d1.seq].verified_time)
		,verified_dt_tm			= t_rec->verify_qual[d1.seq].verified_dt_tm
		,verified_day_of_week 	= t_rec->verify_qual[d1.seq].verified_day_of_week
		,verified_time_of_day 	= t_rec->verify_qual[d1.seq].verified_time_of_day
		,verifying_rph 			= substring(1,200,t_rec->verify_qual[d1.seq].verifying_rph)
		,order_id 				= t_rec->verify_qual[d1.seq].order_id
		,loc_facility_cd 		= t_rec->verify_qual[d1.seq].loc_facility_cd
		,encntr_id 				= t_rec->verify_qual[d1.seq].encntr_id
		,person_id 				= t_rec->verify_qual[d1.seq].person_id
		,verifying_prsnl_id 	= t_rec->verify_qual[d1.seq].verifying_prsnl_id
		,location_company		= substring(1,20,t_rec->verify_qual[d1.seq].original_company)
		,location_department	= substring(1,20,t_rec->verify_qual[d1.seq].original_department)
		,patient_type_alias		= substring(1,1,t_rec->verify_qual[d1.seq].patient_type_alias)
from
	(dummyt d1 with seq=t_rec->verify_cnt)
plan d1
	where t_rec->verify_qual[d1.seq].after_hours_ind = 1
order by
	 verified_date
	,location_company
	,patient_type_alias
	,verifying_prsnl_id
	,order_id
	,verified_dt_tm
head report
	call writeLog(build2("->Inside Strata Qualifier"))	
	check_dt_tm = cnvtdatetime(curdate,curtime3)
	skip_ind = 0
head verified_date
	call writeLog(build2("->Starting ",trim(verified_date)))
head location_company
	call writeLog(build2("--->Looking at ",trim(location_company)))
head patient_type_alias
	call writeLog(build2("---->Adding ",trim(patient_type_alias)))
	t_rec->strata_after_cnt = (t_rec->strata_after_cnt + 1)
	stat = alterlist(t_rec->strata_after_qual,t_rec->strata_after_cnt)
	t_rec->strata_after_qual[t_rec->strata_after_cnt].Date_Of_Service 	= verified_date
	t_rec->strata_after_qual[t_rec->strata_after_cnt].Weight 			= "1"
	t_rec->strata_after_qual[t_rec->strata_after_cnt].Company 			= location_company
	t_rec->strata_after_qual[t_rec->strata_after_cnt].Department 		= location_department
	case (patient_type_alias)
		of "I": t_rec->strata_after_qual[t_rec->strata_after_cnt].Activity_Code = "400000UNIT"
		of "O": t_rec->strata_after_qual[t_rec->strata_after_cnt].Activity_Code = "420000UNIT"
	endcase
head verifying_prsnl_id
	call writeLog(build2("--->Adding ",trim(verifying_rph), "(",trim(cnvtstring(verifying_prsnl_id)),")"))	
	check_dt_tm = cnvtdatetime(curdate,curtime3)
head order_id
	call writeLog(build2("---->Check Order ",trim(t_rec->verify_qual[d1.seq].orderable), "(",trim(cnvtstring(order_id)),")"))	
	check_dt_tm = t_rec->verify_qual[d1.seq].verified_dt_tm
	skip_ind = -1 ;forces first verification per order per prsnl to be addded
	call writeLog(build2("----->check_dt_tm=",trim(format(check_dt_tm,";;q"))))
	call writeLog(build2("----->skip_ind=",trim(cnvtstring(skip_ind))))
detail
	call writeLog(build2("----->verified_dt_tm=",trim(format(t_rec->verify_qual[d1.seq].verified_dt_tm,";;q"))))
	if (skip_ind >=0)
		if (datetimediff(t_rec->verify_qual[d1.seq].verified_dt_tm,check_dt_tm,4) > t_rec->verify_period_min)
			skip_ind = 0
		else
			skip_ind = 1
		endif
	endif
	call writeLog(build2("----->calculated skip_ind=",trim(cnvtstring(skip_ind))))
	if (skip_ind <= 0)
		case (patient_type_alias)
		of "I": t_rec->strata_after_qual[t_rec->strata_after_cnt].ip_cnt = (t_rec->strata_after_qual[t_rec->strata_after_cnt].ip_cnt + 1)
		of "O": t_rec->strata_after_qual[t_rec->strata_after_cnt].op_cnt = (t_rec->strata_after_qual[t_rec->strata_after_cnt].op_cnt + 1)
		endcase	
		t_rec->strata_after_qual[t_rec->strata_after_cnt].total_cnt = (t_rec->strata_after_qual[t_rec->strata_after_cnt].total_cnt + 1)
		t_rec->verify_qual[d1.seq].strata_after_qualify_ind = 1
	endif
	skip_ind = 0
foot order_id
	call writeLog(build2("<----Checked Order ",trim(t_rec->verify_qual[d1.seq].orderable), "(",trim(cnvtstring(order_id)),")"))
foot patient_type_alias
	call writeLog(build2("<----Finishing ",trim(patient_type_alias)))
foot location_company
	call writeLog(build2("<---Leaving at ",trim(location_company)))
foot verified_date
	call writeLog(build2("<-Exiting ",trim(verified_date)))	
foot report
	call writeLog(build2("<-Leaving Strata Qualifier"))	
with nocounter


call writeLog(build2("* END   Strata After Hours Review **************************"))
call writeLog(build2("************************************************************"))
	
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Output *********************************************"))

if ((program_log->run_from_ops = 1) or ((program_log->run_from_ops = 0) and (t_rec->prompt_report_type = 0)))

	select 
		if (program_log->run_from_ops = 1)
			into value(t_rec->files.filename_details)
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,format
		else
			with nocounter,separator = " ", format
		endif
	into t_rec->prompt_outdev
		 physician_name 		= substring(1,200,t_rec->verify_qual[d1.seq].physician_name)
		,orderable 				= substring(1,200,t_rec->verify_qual[d1.seq].orderable)
		,synonym 				= substring(1,200,t_rec->verify_qual[d1.seq].synonym)
		,order_sentence 		= substring(1,200,t_rec->verify_qual[d1.seq].order_sentence)
		,ordered_date 			= substring(1,10,t_rec->verify_qual[d1.seq].ordered_date)
		,ordered_time 			= substring(1,9,t_rec->verify_qual[d1.seq].ordered_time)
		,action_dt_tm 			= substring(1,20,format(t_rec->verify_qual[d1.seq].action_dt_tm,";;q"))
		,updt_dt_tm	 			= substring(1,20,format(t_rec->verify_qual[d1.seq].updt_dt_tm,";;q"))
		,verified_date 			= substring(1,10,t_rec->verify_qual[d1.seq].verified_date)
		,verified_time 			= substring(1,9,t_rec->verify_qual[d1.seq].verified_time)
		,verified_day_of_week 	= t_rec->verify_qual[d1.seq].verified_day_of_week
		,verified_time_of_day 	= t_rec->verify_qual[d1.seq].verified_time_of_day
		,verifying_rph 			= substring(1,200,t_rec->verify_qual[d1.seq].verifying_rph)
		,verifying_rph_position	= substring(1,200,t_rec->verify_qual[d1.seq].verifying_rph_position)
		,oa_action_type_disp 	= substring(1,200,t_rec->verify_qual[d1.seq].oa_action_type_disp)
		,oa_order_status_disp	= substring(1,200,t_rec->verify_qual[d1.seq].oa_order_status_disp)
		,ordering_facility 		= substring(1,30,t_rec->verify_qual[d1.seq].ordering_facility)
		,ordering_location 		= substring(1,30,t_rec->verify_qual[d1.seq].ordering_location)
		,location_qualifer 		= substring(1,30,t_rec->verify_qual[d1.seq].location_qualifier)
		,location_company 		= substring(1,30,t_rec->verify_qual[d1.seq].location_company)
		,location_department	= substring(1,30,t_rec->verify_qual[d1.seq].location_department)
		,patient_type_alias		= substring(1,1,t_rec->verify_qual[d1.seq].patient_type_alias)
		,encntr_type_class		= substring(1,30,t_rec->verify_qual[d1.seq].encntr_type_class)
		,encntr_type			= substring(1,30,t_rec->verify_qual[d1.seq].encntr_type)
		,tat_minutes 			= t_rec->verify_qual[d1.seq].tat_minutes
		,tat2_minutes 			= t_rec->verify_qual[d1.seq].tat2_minutes
		,financial_number 		= substring(1,20,t_rec->verify_qual[d1.seq].financial_number)
		,after_hours_ind		= t_rec->verify_qual[d1.seq].after_hours_ind
		,rph_qualify_ind		= t_rec->verify_qual[d1.seq].rph_qualify_ind
		,strata_qualify_ind		= t_rec->verify_qual[d1.seq].strata_qualify_ind
		,order_id 				= t_rec->verify_qual[d1.seq].order_id
		,loc_facility_cd 		= t_rec->verify_qual[d1.seq].loc_facility_cd
		,loc_nurse_unit_cd 		= t_rec->verify_qual[d1.seq].loc_nurse_unit_cd
		,encntr_id 				= t_rec->verify_qual[d1.seq].encntr_id
		,person_id 				= t_rec->verify_qual[d1.seq].person_id
		,verifying_prsnl_id 	= t_rec->verify_qual[d1.seq].verifying_prsnl_id
	from
		(dummyt d1 with seq=t_rec->verify_cnt)
	plan d1
	order by
		 ordering_facility
		,verifying_rph
		,verified_date
		,ordered_time
	with nocounter,separator = " ", format
	
	if (program_log->run_from_ops = 1)
		set t_rec->files.full_path		= concat(t_rec->files.cer_temp,replace(t_rec->files.filename_details,"cer_temp:","")) 
		set t_rec->files.astream_mv 	= build2(
											 "cp "
											,t_rec->files.full_path
											," "
											,t_rec->files.astream_path
											,replace(t_rec->files.filename_details,"cer_temp:","")
										 )
		set dclstat = 0 
		call writeLog(build2("t_rec->files.astream_mv=",trim(t_rec->files.astream_mv)))
		call dcl(t_rec->files.astream_mv, size(trim(t_rec->files.astream_mv)), dclstat) 
		call writeLog(build2("---->addAttachment(",replace(t_rec->files.filename_details,"cer_temp:",""),")"))
		call addAttachment(t_rec->files.cer_temp, replace(t_rec->files.filename_details,"cer_temp:",""))
	endif
endif

if ((program_log->run_from_ops = 1) or ((program_log->run_from_ops = 0) and (t_rec->prompt_report_type = 1)))

	select 
		if (program_log->run_from_ops = 1)
			into value(t_rec->files.filename_rph)
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,format
		else
			with nocounter,separator = " ", format
		endif
	distinct into t_rec->prompt_outdev
		; verified_date 			= substring(1,10,t_rec->verify_qual[d1.seq].verified_date)
		;,verified_time 			= substring(1,9,t_rec->verify_qual[d1.seq].verified_time)
		;,verified_day_of_week 	= t_rec->verify_qual[d1.seq].verified_day_of_week
		;,verified_time_of_day 	= t_rec->verify_qual[d1.seq].verified_time_of_day
		 verifying_rph 			= substring(1,200,t_rec->rph_qual[d1.seq].verifying_prsnl)
		,verifying_rph_position	= substring(1,200,t_rec->rph_qual[d1.seq].verifying_prsnl_position)
		;,oa_action_type_disp 	= substring(1,200,t_rec->verify_qual[d1.seq].oa_action_type_disp)
		;,oa_order_status_disp	= substring(1,200,t_rec->verify_qual[d1.seq].oa_order_status_disp)
		;,ordering_facility 		= substring(1,30,t_rec->verify_qual[d1.seq].ordering_facility)
		;,ordering_location 		= substring(1,30,t_rec->verify_qual[d1.seq].ordering_location)
		;,location_qualifer 		= substring(1,30,t_rec->verify_qual[d1.seq].location_qualifier)
		;,tat_minutes 			= t_rec->verify_qual[d1.seq].tat_minutes
		;,tat2_minutes 			= t_rec->verify_qual[d1.seq].tat2_minutes
		;,financial_number 		= substring(1,20,t_rec->verify_qual[d1.seq].financial_number)
		;,order_id 				= t_rec->verify_qual[d1.seq].order_id
		;,loc_facility_cd 		= t_rec->verify_qual[d1.seq].loc_facility_cd
		;,encntr_id 				= t_rec->verify_qual[d1.seq].encntr_id
		;,person_id 				= t_rec->verify_qual[d1.seq].person_id
		,verifying_prsnl_id 	= t_rec->rph_qual[d1.seq].verifying_prsnl_id
		,verification_cnt		= t_rec->rph_qual[d1.seq].verify_cnt
	from
		 (dummyt d1 with seq=t_rec->rph_cnt)
		,(dummyt d2 with seq=1)
	plan d1
		where maxrec(d2,t_rec->rph_qual[d1.seq].verify_cnt)
	join d2
	order by
		 verifying_rph
		,verification_cnt
		,verifying_prsnl_id
	with nocounter,separator = " ", format
	
	if (program_log->run_from_ops = 1)
		set t_rec->files.full_path		= concat(t_rec->files.cer_temp,replace(t_rec->files.filename_rph,"cer_temp:","")) 
		set t_rec->files.astream_mv 	= build2(
											 "cp "
											,t_rec->files.full_path
											," "
											,t_rec->files.astream_path
											,replace(t_rec->files.filename_rph,"cer_temp:","")
										 )
		set dclstat = 0 
		call writeLog(build2("t_rec->files.astream_mv=",trim(t_rec->files.astream_mv)))
		call dcl(t_rec->files.astream_mv, size(trim(t_rec->files.astream_mv)), dclstat) 
		call writeLog(build2("---->addAttachment(",replace(t_rec->files.filename_rph,"cer_temp:",""),")"))
		call addAttachment(t_rec->files.cer_temp, replace(t_rec->files.filename_rph,"cer_temp:",""))
	endif
endif

if ((program_log->run_from_ops = 1) or ((program_log->run_from_ops = 0) and (t_rec->prompt_report_type = 2)))

	select 
		if (program_log->run_from_ops = 1)
			into value(t_rec->files.filename_strata)
			with nocounter, pcformat(^"^, ^|^, 1,0),format=stream,formfeed=none,format
		else
			with nocounter,separator = " ", format
		endif
	into t_rec->prompt_outdev
		;Company|Department|Activity_Code|Date_of_service|Weight|IP_Value|OP_Value|Total_Value
		 Company			= substring(1,10,t_rec->strata_qual[d1.seq].Company)
		,Department			= substring(1,10,t_rec->strata_qual[d1.seq].Department)
		,Activity_Code		= substring(1,20,t_rec->strata_qual[d1.seq].Activity_Code)
		,Date_of_service	= substring(1,10,t_rec->strata_qual[d1.seq].Date_Of_Service)
		,Weight				= substring(1,1,t_rec->strata_qual[d1.seq].Weight)
		,IP_Value			= substring(1,10,cnvtstring(t_rec->strata_qual[d1.seq].ip_cnt))
		,OP_Value			= substring(1,10,cnvtstring(t_rec->strata_qual[d1.seq].op_cnt))
		,Total_Value		= substring(1,10,cnvtstring(t_rec->strata_qual[d1.seq].total_cnt))
	from
		 (dummyt d1 with seq=t_rec->strata_cnt)
	plan d1
	order by
		 Company
		,Department
		,Date_of_service
	with nocounter,separator = " ", format
	
	if (program_log->run_from_ops = 1)
		set t_rec->files.full_path		= concat(t_rec->files.cer_temp,replace(t_rec->files.filename_strata,"cer_temp:","")) 
		set t_rec->files.astream_mv 	= build2(
											 "cp "
											,t_rec->files.full_path
											," "
											,t_rec->files.astream_path
											,replace(t_rec->files.filename_strata,"cer_temp:","")
										 )
		set t_rec->files.astream_mv_strata 	= build2(
											 "cp "
											,t_rec->files.full_path
											," "
											,t_rec->files.astream_path_strata
											,replace(t_rec->files.filename_strata,"cer_temp:","")
										 )
		set dclstat = 0 
		call writeLog(build2("t_rec->files.astream_mv=",trim(t_rec->files.astream_mv)))
		call dcl(t_rec->files.astream_mv, size(trim(t_rec->files.astream_mv)), dclstat) 
		call writeLog(build2("---->addAttachment(",replace(t_rec->files.filename_strata,"cer_temp:",""),")"))
		call addAttachment(t_rec->files.cer_temp, replace(t_rec->files.filename_strata,"cer_temp:",""))
		set dclstat = 0 
		call writeLog(build2("t_rec->files.astream_mv_strata=",trim(t_rec->files.astream_mv_strata)))
		call dcl(t_rec->files.astream_mv_strata, size(trim(t_rec->files.astream_mv_strata)), dclstat) 
	endif
endif

if ((program_log->run_from_ops = 1) or ((program_log->run_from_ops = 0) and (t_rec->prompt_report_type = 3)))

	select 
		if (program_log->run_from_ops = 1)
			into value(t_rec->files.filename_pwafter_hrs)
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,format
		else
			with nocounter,separator = " ", format
		endif
	into t_rec->prompt_outdev
		 physician_name 		= substring(1,200,t_rec->verify_qual[d1.seq].physician_name)
		,orderable 				= substring(1,200,t_rec->verify_qual[d1.seq].orderable)
		,synonym 				= substring(1,200,t_rec->verify_qual[d1.seq].synonym)
		,order_sentence 		= substring(1,200,t_rec->verify_qual[d1.seq].order_sentence)
		,ordered_date 			= substring(1,10,t_rec->verify_qual[d1.seq].ordered_date)
		,ordered_time 			= substring(1,9,t_rec->verify_qual[d1.seq].ordered_time)
		,action_dt_tm 			= substring(1,20,format(t_rec->verify_qual[d1.seq].action_dt_tm,";;q"))
		,updt_dt_tm	 			= substring(1,20,format(t_rec->verify_qual[d1.seq].updt_dt_tm,";;q"))
		,verified_date 			= substring(1,10,t_rec->verify_qual[d1.seq].verified_date)
		,verified_time 			= substring(1,9,t_rec->verify_qual[d1.seq].verified_time)
		,verified_day_of_week 	= t_rec->verify_qual[d1.seq].verified_day_of_week
		,verified_time_of_day 	= t_rec->verify_qual[d1.seq].verified_time_of_day
		,verifying_rph 			= substring(1,200,t_rec->verify_qual[d1.seq].verifying_rph)
		,verifying_rph_position	= substring(1,200,t_rec->verify_qual[d1.seq].verifying_rph_position)
		,oa_action_type_disp 	= substring(1,200,t_rec->verify_qual[d1.seq].oa_action_type_disp)
		,oa_order_status_disp	= substring(1,200,t_rec->verify_qual[d1.seq].oa_order_status_disp)
		,ordering_facility 		= substring(1,30,t_rec->verify_qual[d1.seq].ordering_facility)
		,ordering_location 		= substring(1,30,t_rec->verify_qual[d1.seq].ordering_location)
		,location_qualifer 		= substring(1,30,t_rec->verify_qual[d1.seq].location_qualifier)
		,location_company 		= substring(1,30,t_rec->verify_qual[d1.seq].location_company)
		,location_department	= substring(1,30,t_rec->verify_qual[d1.seq].location_department)
		,patient_type_alias		= substring(1,1,t_rec->verify_qual[d1.seq].patient_type_alias)
		,encntr_type_class		= substring(1,30,t_rec->verify_qual[d1.seq].encntr_type_class)
		,encntr_type			= substring(1,30,t_rec->verify_qual[d1.seq].encntr_type)
		,tat_minutes 			= t_rec->verify_qual[d1.seq].tat_minutes
		,tat2_minutes 			= t_rec->verify_qual[d1.seq].tat2_minutes
		,financial_number 		= substring(1,20,t_rec->verify_qual[d1.seq].financial_number)
		,after_hours_ind		= t_rec->verify_qual[d1.seq].after_hours_ind
		,rph_qualify_ind		= t_rec->verify_qual[d1.seq].rph_qualify_ind
		,strata_qualify_ind		= t_rec->verify_qual[d1.seq].strata_qualify_ind
		,order_id 				= t_rec->verify_qual[d1.seq].order_id
		,loc_facility_cd 		= t_rec->verify_qual[d1.seq].loc_facility_cd
		,encntr_id 				= t_rec->verify_qual[d1.seq].encntr_id
		,person_id 				= t_rec->verify_qual[d1.seq].person_id
		,verifying_prsnl_id 	= t_rec->verify_qual[d1.seq].verifying_prsnl_id
	from
		(dummyt d1 with seq=t_rec->verify_cnt)
	plan d1
		where t_rec->verify_qual[d1.seq].after_hours_ind = 1
	order by
		 ordering_facility
		,verifying_rph
		,verified_date
		,ordered_time
	with nocounter,separator = " ", format
	
	if (program_log->run_from_ops = 1)
		set t_rec->files.full_path		= concat(t_rec->files.cer_temp,replace(t_rec->files.filename_pwafter_hrs,"cer_temp:","")) 
		set t_rec->files.astream_mv 	= build2(
											 "cp "
											,t_rec->files.full_path
											," "
											,t_rec->files.astream_path
											,replace(t_rec->files.filename_pwafter_hrs,"cer_temp:","")
										 )
		set dclstat = 0 
		call writeLog(build2("t_rec->files.astream_mv=",trim(t_rec->files.astream_mv)))
		call dcl(t_rec->files.astream_mv, size(trim(t_rec->files.astream_mv)), dclstat) 
		call writeLog(build2("---->addAttachment(",replace(t_rec->files.filename_pwafter_hrs,"cer_temp:",""),")"))
		call addAttachment(t_rec->files.cer_temp, replace(t_rec->files.filename_pwafter_hrs,"cer_temp:",""))
	endif
endif

if ((program_log->run_from_ops = 1) or ((program_log->run_from_ops = 0) and (t_rec->prompt_report_type = 4)))
	select 
		if (program_log->run_from_ops = 1)
			into value(t_rec->files.filename_pwafter_str)
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,format
		else
			with nocounter,separator = " ", format
		endif
	into t_rec->prompt_outdev
		;Company|Department|Activity_Code|Date_of_service|Weight|IP_Value|OP_Value|Total_Value
		 Company			= substring(1,10,t_rec->strata_after_qual[d1.seq].Company)
		,Department			= substring(1,10,t_rec->strata_after_qual[d1.seq].Department)
		,Activity_Code		= substring(1,20,t_rec->strata_after_qual[d1.seq].Activity_Code)
		,Date_of_service	= substring(1,10,t_rec->strata_after_qual[d1.seq].Date_Of_Service)
		,Weight				= substring(1,1,t_rec->strata_after_qual[d1.seq].Weight)
		,IP_Value			= substring(1,10,cnvtstring(t_rec->strata_after_qual[d1.seq].ip_cnt))
		,OP_Value			= substring(1,10,cnvtstring(t_rec->strata_after_qual[d1.seq].op_cnt))
		,Total_Value		= substring(1,10,cnvtstring(t_rec->strata_after_qual[d1.seq].total_cnt))
	from
		 (dummyt d1 with seq=t_rec->strata_after_cnt)
	plan d1
	order by
		 Company
		,Department
		,Date_of_service
	with nocounter,separator = " ", format
	
	if (program_log->run_from_ops = 1)
		set t_rec->files.full_path		= concat(t_rec->files.cer_temp,replace(t_rec->files.filename_pwafter_str,"cer_temp:","")) 
		set t_rec->files.astream_mv 	= build2(
											 "cp "
											,t_rec->files.full_path
											," "
											,t_rec->files.astream_path
											,replace(t_rec->files.filename_pwafter_str,"cer_temp:","")
										 )
		set dclstat = 0 
		call writeLog(build2("t_rec->files.astream_mv=",trim(t_rec->files.astream_mv)))
		call dcl(t_rec->files.astream_mv, size(trim(t_rec->files.astream_mv)), dclstat) 
		call writeLog(build2("---->addAttachment(",replace(t_rec->files.filename_pwafter_str,"cer_temp:",""),")"))
		call addAttachment(t_rec->files.cer_temp, replace(t_rec->files.filename_pwafter_str,"cer_temp:",""))
	endif
endif

call writeLog(build2("* END   Order Review Query *********************************"))
call writeLog(build2("************************************************************"))

set reply->status_data.status = "S"

#exit_script

if ((reply->status_data.status in("F","Z")) and (t_rec->prompt_outdev = "MINE"))
	set program_log->display_on_exit = 1
endif

/*
if (validate(t_rec))
	call writeLog(build2(cnvtrectojson(t_rec))) 
endif
*/

if (validate(request))
	call writeLog(build2(cnvtrectojson(request))) 
endif
if (validate(reqinfo))
	call writeLog(build2(cnvtrectojson(reqinfo))) 
endif
if (validate(reply))
	call writeLog(build2(cnvtrectojson(reply))) 
endif
if (validate(program_log))
	call writeLog(build2(cnvtrectojson(program_log)))
endif

call exitScript(null)

if (debug_ind = 1)
	set stat = alterlist(t_rec->verify_qual,0)
	set stat = alterlist(t_rec->rph_qual,0)
	call echorecord(t_rec)
	;call echorecord(a)
	;call echorecord(strata)
	;call echorecord(code_values)
	call echorecord(program_log)
	set stat = 0
endif

;call trace(34)
;%O
END GO
