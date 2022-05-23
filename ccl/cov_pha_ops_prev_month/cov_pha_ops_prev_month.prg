/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Chad Cummings
	Date Written:		07/15/2021
	Solution:
	Source file name:	cov_pha_ops_prev_month.prg
	Object name:		cov_pha_ops_prev_month
	Request #:
 
	Program purpose:
 
	Executing from:		CCL
 
 	Special Notes:		Called by ccl program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	07/15/2021  Chad Cummings			Initial Release
******************************************************************************/
 
drop program cov_pha_ops_prev_month:dba go
create program cov_pha_ops_prev_month:dba
 
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
)
endif
 
set reply->status_data.status = "F"
 
call set_codevalues(null)
call check_ops(null)
 
free set t_rec
record t_rec
(
	1 dclstat					= i2
	1 cons
	 2 run_dt_tm				= dq8
	 2 run_dt_tm_vc				= vc
	 2 run_dt_filename			= vc
	 2 run_dt_tm_filename		= vc
	 2 paths
	  3 temp					= vc
	  3 astream					= vc
	  3 astream_ccl				= vc
	 2 lookback
	  3 year					= vc
	  3 month					= vc
	  3 week					= vc
	  3 day						= vc
	 2 dates
	  3 prev_year_start_dt_tm	= dq8
	  3 prev_year_end_dt_tm		= dq8
	  3 prev_month_start_dt_tm	= dq8
	  3 prev_month_end_dt_tm	= dq8
	  3 prev_week_start_dt_tm	= dq8
	  3 prev_week_end_dt_tm		= dq8
	  3 prev_day_start_dt_tm	= dq8
	  3 prev_day_end_dt_tm		= dq8
	 2 acute_facility_cnt		= i2
	 2 acute_facilities[*]
	  3 display 				= vc
	  3 description				= vc
	  3 value					= f8
	 2 all_facility_cnt			= i2
	 2 all_facilities[*]
	  3 display 				= vc
	  3 description				= vc
	  3 value					= f8
	1 cnt						= i4
	1 reports[*]
	 2 title					= vc
	 2 object					= vc
	 2 param_template			= vc
	 2 start_dt_tm_vc			= vc
	 2 end_dt_tm_vc				= vc
	 2 start_dt_tm				= dq8
	 2 end_dt_tm				= dq8
	 2 override_astream_ccl		= i2
	 2 instance_cnt				= i2
	 2 instances[*]
	  3 facility					= vc
	  3 params						= vc
	  3 filename					= vc
	  3 temp_path					= vc
	  3 final_path					= vc
	  3 ccl_command					= vc
	  3 astream_copy_command		= vc
)
 
;call addEmailLog("chad.cummings@covhlth.com")
 
set t_rec->cons.lookback.year	= build(^"^,^1^,^,Y"^)
set t_rec->cons.lookback.month	= build(^"^,^1^,^,M"^)
set t_rec->cons.lookback.week	= build(^"^,^1^,^,W"^)
set t_rec->cons.lookback.day	= build(^"^,^1^,^,D"^)
 
set t_rec->cons.run_dt_tm 			= cnvtdatetime(curdate,curtime3)
set t_rec->cons.run_dt_tm_vc		= format(t_rec->cons.run_dt_tm,"DD-MMM-YYYY HH:MM:SS;;q")
set t_rec->cons.run_dt_filename		= format(t_rec->cons.run_dt_tm,"YYYY_MM_DD;;q")
set t_rec->cons.run_dt_tm_filename	= format(t_rec->cons.run_dt_tm,"YYYY_MM_DD_HH_MM_SS;;q")
 
set t_rec->cons.dates.prev_year_start_dt_tm
	= datetimefind(cnvtlookbehind(t_rec->cons.lookback.month,cnvtdatetime(curdate,curtime3)), 'Y', 'B', 'B')
set t_rec->cons.dates.prev_year_end_dt_tm
	= datetimefind(cnvtlookbehind(t_rec->cons.lookback.month,cnvtdatetime(curdate,curtime3)), 'Y', 'E', 'E')
 
set t_rec->cons.dates.prev_month_start_dt_tm
	= datetimefind(cnvtlookbehind(t_rec->cons.lookback.month,cnvtdatetime(curdate,curtime3)), 'M', 'B', 'B') ;change back to M
set t_rec->cons.dates.prev_month_end_dt_tm
	= datetimefind(cnvtlookbehind(t_rec->cons.lookback.month,cnvtdatetime(curdate,curtime3)), 'M', 'E', 'E') ;change back to M
 
set t_rec->cons.dates.prev_week_start_dt_tm
	= datetimefind(cnvtlookbehind(t_rec->cons.lookback.week,cnvtdatetime(curdate,curtime3)), 'W', 'B', 'B')
set t_rec->cons.dates.prev_week_end_dt_tm
	= datetimefind(cnvtlookbehind(t_rec->cons.lookback.week,cnvtdatetime(curdate,curtime3)), 'W', 'E', 'E')
 
set t_rec->cons.dates.prev_day_start_dt_tm
	= datetimefind(cnvtlookbehind(t_rec->cons.lookback.day,cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
set t_rec->cons.dates.prev_day_end_dt_tm
	= datetimefind(cnvtlookbehind(t_rec->cons.lookback.day,cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E')
 
 
set t_rec->cons.paths.temp 		= build("/cerner/d_",cnvtlower(trim(curdomain)),"/temp/")
set t_rec->cons.paths.astream	= build("/nfs/middle_fs/to_client_site/"
										,trim(cnvtlower(curdomain)),"/ClinicalAncillary/Pharmacy/R2W/")
;\\chstn_astream_prod.cernerasp.com\middle_fs\to_client_site\p0665\ClinicalAncillary\Pharmacy\R2W
 
set t_rec->cons.paths.astream_ccl	= build("/nfs/middle_fs/to_client_site/",trim(cnvtlower(curdomain)),"/CernerCCL/")
;set t_rec->cons.paths.astream = t_rec->cons.paths.astream_ccl
 
set reply->status_data.status = "Z"
 
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))
 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Getting Acute Facilities ***************************"))
 
select into "nl:"
from
	code_value cv
plan cv
	where cv.code_set = 2062
	and   cv.active_ind = 1
	and   cv.description in(
								 "FSR"
								,"LCMC"
								,"MHHS"
								,"PWMC"
								,"MMC"
								,"RMC"
								,"FLMC"
							)
order by
	 cv.display
	,cv.description
	,cv.code_value
head report
	i = 0
head cv.code_value
	i = (i + 1)
	stat = alterlist(t_rec->cons.acute_facilities,i)
	t_rec->cons.acute_facilities[i].display			= cv.display
	t_rec->cons.acute_facilities[i].description		= cv.description
	t_rec->cons.acute_facilities[i].value			= cv.code_value
foot report
	t_rec->cons.acute_facility_cnt = i
with nocounter
 
call writeLog(build2("* END   Getting Acute Facilities ***************************"))
call writeLog(build2("************************************************************"))
 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Getting All Facilities *****************************"))
 
select distinct into "nl:"
  cv.code_value,
  cv.display
from
  prsnl_org_reltn por,
  location loc,
  code_value cv
plan por
  where por.person_id = 1.0
  and por.person_id > 0
  and por.active_ind = 1
  and por.organization_id > 0
join loc
  where loc.organization_id =  por.organization_id
  and loc.patcare_node_ind = 1
join cv
  where cv.code_value = loc.location_cd
  and cv.code_set = 220
  and cv.active_ind = 1
  and cv.cdf_meaning = "FACILITY"
  and cv.display in(
  						^COV CORP CLINIC^,
						^COV CORP CLIN - ONCOLOGY INFUSION^,
						^COV CORP HOSP^,
						^FLMC^,
						^FSR^,
						^FSR INF Lenoir^,
						^FSR INF Oridge^,
						^FSR Pat Neal^,
						^FSR TCU^,
						^LCMC^,
						^LCMC Blount INF^,
						^LCMC Dwtn INF^,
						^LCMC Sevier INF^,
						^LCMC West INF^,
						^MHHS^,
						^MHHS ASC^,
						^MHHS Behav Hlth^,
						^MMC^,
						^PBH Peninsula^,
						^PW^,
						^PW Senior Behav^,
						^RMC^,
						^PW^,
						^PW Cardio Rehab^,
						^PW Breast Ctr^,
						^PW Emp Health^,
						^PW Hyperbaric^,
						^PW Senior Behav^,
						^PW Sleep Center^,
						^PW Therapy W^,
						^PW Plaza Diag^,
						^RMC^,
						^RMC PNRC Harrim^,
						^RMC Card Rehab^,
						^MMC^,
						^MMC Sleep Ctr^,
						^MMC Cheyenne^,
						^MMC OR Breast^,
						^MMC Wound^,
						^MMC Card Rehab^,
						^MMC Endo^,
						^MHHS^,
						^MHHS ASC^,
						^MHHS Behav Hlth^,
						^MHHS Sleep^,
						^MHHS MRDC^,
						^MHHS Wound Ctr^,
						^LCMC^,
						^LCMC Sleep Ctr^,
						^LCMC Nsg Home^,
						^LCMC Card Rehab^,
						^LCMC Breast Ctr^,
						^LCMC Therapy SV^,
						^LCMC Therapy SY^,
						^FSR^,
						^FSR Therapy H^,
						^FSR FSW Diagn^,
						^FSR Pat Neal^,
						^FSR Select Spec^,
						^FSR Breast Ctr^,
						^FSR TCU^,
						^FSR Wound Ctr^,
						^FLMC^,
						^FLMC Therapy LC^,
						^FLMC Therapy LO^,
						^FLMC Card Rehab^,
						^LCMC Blount INF^,
						^LCMC Dwtn INF^,
						^FSR INF Lenoir^,
						^FSR INF Oridge^,
						^LCMC Sevier INF^,
						^LCMC West INF^
					)
order by
   cv.display
  ,cv.code_value
head report
	i = 0
head cv.code_value
	i = (i + 1)
	stat = alterlist(t_rec->cons.all_facilities,i)
	t_rec->cons.all_facilities[i].display			= cv.display
	t_rec->cons.all_facilities[i].description		= cv.description
	t_rec->cons.all_facilities[i].value				= cv.code_value
foot report
	t_rec->cons.all_facility_cnt = i
with nocounter
 
call writeLog(build2("* END   Getting All Facilities *****************************"))
call writeLog(build2("************************************************************"))
 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Adding Report Definitions **************************"))
 
;Report 1 Cov - BCMA Compliance Detailed Unit and Personnel (COV_PHQ_BCMA_PRSNL_DETAIL_LB)
set t_rec->cnt = 1
set stat = alterlist(t_rec->reports,t_rec->cnt)
set k = t_rec->cnt
 
set t_rec->reports[k].title 			= "Cov - BCMA Compliance Detailed Unit and Personnel"
set t_rec->reports[k].object 			= "COV_PHQ_BCMA_PRSNL_DETAIL_LB"
set t_rec->reports[k].param_template	= ^"FILENAME", "START_DT_TM_VAR", "END_DT_TM_VAR", ACUTE_FACILITY, VALUE(0.0), REPORT_OPTION^
set t_rec->reports[k].start_dt_tm		= t_rec->cons.dates.prev_month_start_dt_tm
set t_rec->reports[k].end_dt_tm			= t_rec->cons.dates.prev_month_end_dt_tm
set t_rec->reports[k].start_dt_tm_vc	= format(t_rec->reports[k].start_dt_tm,	"DD-MMM-YYYY HH:MM:SS;;q")
set t_rec->reports[k].end_dt_tm_vc		= format(t_rec->reports[k].end_dt_tm,	"DD-MMM-YYYY HH:MM:SS;;q")
 
;Report Option 1
set j = 0
for (i=1 to t_rec->cons.acute_facility_cnt)
	set j = (j + 1)
	set t_rec->reports[k].instance_cnt = j
	set stat = alterlist(t_rec->reports[k].instances,j)
	set t_rec->reports[k].instances[j].facility 	= t_rec->cons.acute_facilities[i].description
	set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
	set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower(t_rec->cons.acute_facilities[i].description)
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																;,"_"
																;,cnvtlower(format(t_rec->reports[k].start_dt_tm,"MMM;;q"))
																;,"_"
																;,t_rec->cons.run_dt_tm_filename
																,"_ccl"
																,".pdf"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ACUTE_FACILITY"
															,cnvtstring(t_rec->cons.acute_facilities[i].value)
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"REPORT_OPTION"
															,cnvtstring(0)
														)
endfor
 
;Report Option 2
;set j = 0
for (i=1 to t_rec->cons.acute_facility_cnt)
	set j = (j + 1)
	set t_rec->reports[k].instance_cnt = j
	set stat = alterlist(t_rec->reports[k].instances,j)
	set t_rec->reports[k].instances[j].facility 	= t_rec->cons.acute_facilities[i].description
	set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
	set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower(t_rec->cons.acute_facilities[i].description)
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ACUTE_FACILITY"
															,cnvtstring(t_rec->cons.acute_facilities[i].value)
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"REPORT_OPTION"
															,cnvtstring(2)
														)
endfor
 
;Report 2 Cov - Pharmacy Clinical Intervention Detail (COV_PHA_RX_INTERVENTION)
set j = 0 ;reset instance counter
set t_rec->cnt = 2
set stat = alterlist(t_rec->reports,t_rec->cnt)
set k = t_rec->cnt
 
set t_rec->reports[k].title 			= "Cov - Pharmacy Clinical Intervention Detail"
set t_rec->reports[k].object 			= "COV_PHA_RX_INTERVENTION"
set t_rec->reports[k].param_template	= ^"FILENAME", ALL_FACILITY, "START_DT_TM_VAR", "END_DT_TM_VAR", 1^
set t_rec->reports[k].start_dt_tm		= t_rec->cons.dates.prev_month_start_dt_tm
set t_rec->reports[k].end_dt_tm			= t_rec->cons.dates.prev_month_end_dt_tm
set t_rec->reports[k].start_dt_tm_vc	= format(t_rec->reports[k].start_dt_tm,	"DD-MMM-YYYY;;q")
set t_rec->reports[k].end_dt_tm_vc		= format(t_rec->reports[k].end_dt_tm,	"DD-MMM-YYYY;;q")
 
;Parkwest Medical Center and PW Senior Behavioral Unit
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Parkwest Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "PW Senior Behavioral Unit")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
 
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("PWMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
 
;Roane Medical Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Roane Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("RMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
;Peninsula Behavioral Health - Div of Parkwest Medical Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Peninsula Behavioral Health - Div of Parkwest Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("PBH")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
 
;Methodist Medical Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Methodist Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("MMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
;LeConte Medical Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "LeConte Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("LCMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
;Fort Loudoun Medical Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Fort Loudoun Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("FLMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
;Morristown-Hamblen Healthcare System
;MHHS Ambulatory Surgery Center
;MHHS Behavioral Health
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Morristown-Hamblen Healthcare System")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "MHHS Ambulatory Surgery Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "MHHS Behavioral Health")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("MHHS")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
;Fort Sanders Regional Medical Center
;FSR Patricia Neal Rehabilitation Center
;FSR Transitional Care Unit
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Fort Sanders Regional Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "FSR Patricia Neal Rehabilitation Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "FSR Transitional Care Unit")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("FSR")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)

;Infusion Centers
/*
LCMC Infusion Clinic - Blount
LCMC Infusion Clinic - Downtown
FSR Infusion Clinic - Lenoir City
FSR Infusion Clinic - Oak Ridge
LCMC Infusion Clinic - Sevier
LCMC Infusion Clinic - West
*/

set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "FSR Infusion Clinic - Lenoir City")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "FSR Infusion Clinic - Oak Ridge")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "LCMC Infusion Clinic - Blount")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "LCMC Infusion Clinic - Downtown")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "LCMC Infusion Clinic - Sevier")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "LCMC Infusion Clinic - West")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("TOG")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
;Report 3 Cov - BCMA Compliance Patent Level (COV_PHQ_BCMA_LEAPFROG_COMPL)
set t_rec->cnt = 3
set j = 0 ;reset instance counter
set stat = alterlist(t_rec->reports,t_rec->cnt)
set k = t_rec->cnt
 
set t_rec->reports[k].title 			= "Cov - BCMA Compliance Patent Level"
set t_rec->reports[k].object 			= "COV_CSV_BCMA_LEAPFROG_COMPL" ;"COV_PHQ_BCMA_LEAPFROG_COMPL"
set t_rec->reports[k].param_template	= ^"FILENAME", "START_DT_TM_VAR", "END_DT_TM_VAR", ACUTE_FACILITY, VALUE(0.0), VALUE(0.0)^
set t_rec->reports[k].start_dt_tm		= t_rec->cons.dates.prev_month_start_dt_tm
set t_rec->reports[k].end_dt_tm			= t_rec->cons.dates.prev_month_end_dt_tm
set t_rec->reports[k].start_dt_tm_vc	= format(t_rec->reports[k].start_dt_tm,	"DD-MMM-YYYY HH:MM:SS;;q")
set t_rec->reports[k].end_dt_tm_vc		= format(t_rec->reports[k].end_dt_tm,	"DD-MMM-YYYY HH:MM:SS;;q")
 
for (i=1 to t_rec->cons.acute_facility_cnt)
	set j = (j + 1)
	set t_rec->reports[k].instance_cnt = j
	set stat = alterlist(t_rec->reports[k].instances,j)
	set t_rec->reports[k].instances[j].facility 	= t_rec->cons.acute_facilities[i].description
	set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
	set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower(t_rec->cons.acute_facilities[i].description)
																,"_"
																;,cnvtlower(t_rec->reports[k].object)
																,cnvtlower("COV_PHQ_BCMA_LEAPFROG_COMPL")
																;,"_"
																;,cnvtlower(format(t_rec->reports[k].start_dt_tm,"MMM;;q"))
																;,"_"
																;,t_rec->cons.run_dt_tm_filename
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ACUTE_FACILITY"
															,cnvtstring(t_rec->cons.acute_facilities[i].value)
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"REPORT_OPTION"
															,cnvtstring(0)
														)
endfor
 
;Report 4 Order Actions by Facility / Location (RX_RPT_ORDER_ACTION)
set j = 0 ;reset instance counter
set t_rec->cnt = 4
set stat = alterlist(t_rec->reports,t_rec->cnt)
set k = t_rec->cnt
 
set t_rec->reports[k].title 			= "Order Actions by Facility / Location"
set t_rec->reports[k].object 			= "COV_RX_RPT_ORDER_ACTION"	;"RX_RPT_ORDER_ACTION"
set t_rec->reports[k].param_template	= build2(	 ^"FILENAME", "START_DT_TM_VAR", "END_DT_TM_VAR", ALL_FACILITY,^
													,^ "SUMMARY ", "Show only actions utilized "^)
set t_rec->reports[k].start_dt_tm		= t_rec->cons.dates.prev_month_start_dt_tm
set t_rec->reports[k].end_dt_tm			= t_rec->cons.dates.prev_month_end_dt_tm
set t_rec->reports[k].start_dt_tm_vc	= format(t_rec->reports[k].start_dt_tm,	"MMDDYYYY HHMM;;q")
set t_rec->reports[k].end_dt_tm_vc		= format(t_rec->reports[k].end_dt_tm,	"MMDDYYYY HHMM;;q")
 
;Roane Medical Center
;RMC Patricia Neal Outpatient Center - Harriman
;RMC Cardiopulmonary Rehabilitation
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Roane Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "RMC Patricia Neal Outpatient Center - Harriman")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "RMC Cardiopulmonary Rehabilitation")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("RMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".asc"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
;Parkwest Medical Center
;PW Cardiopulmonary Rehabilitation
;PW Comprehensive Breast Center
;PW Employee and Occupational Health Services
;PW Hyperbaric Center
;PW Senior Behavioral Unit
;PW Sleep Center
;PW Therapy Center - Fort Sanders West
;PW Plaza Diagnostics
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Parkwest Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "PW Cardiopulmonary Rehabilitation")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "PW Comprehensive Breast Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "PW Employee and Occupational Health Services")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "PW Hyperbaric Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "PW Senior Behavioral Unit")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "PW Sleep Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "PW Therapy Center - Fort Sanders West")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "PW Plaza Diagnostics")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("PWMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".asc"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
;Peninsula Behavioral Health - Div of Parkwest Medical Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Peninsula Behavioral Health - Div of Parkwest Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("PBH")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".asc"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
;Methodist Medical Center
;MMC Sleep Diagnostic Center
;MMC Cheyenne Outpatient Diagnostic Center
;MMC Oak Ridge Breast Center
;MMC Wound Treatment Center
;MMC Cardiopulmonary Therapy
;MMC Endoscopy Center of Oak Ridge
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Methodist Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "MMC Sleep Diagnostic Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "MMC Cheyenne Outpatient Diagnostic Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "MMC Oak Ridge Breast Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "MMC Wound Treatment Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "MMC Cardiopulmonary Therapy")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "MMC Endoscopy Center of Oak Ridge")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("MMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".asc"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
;Morristown-Hamblen Healthcare System
;MHHS Ambulatory Surgery Center
;MHHS Behavioral Health
;MHHS Sleep Disorder Center
;MHHS Regional Diagnostic Center
;MHHS Wound Treatment Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Morristown-Hamblen Healthcare System")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "MHHS Ambulatory Surgery Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "MHHS Behavioral Health")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "MHHS Sleep Disorder Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "MHHS Regional Diagnostic Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "MHHS Wound Treatment Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("MHHS")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".asc"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
;LeConte Medical Center
;LCMC Sleep Disorders Center
;LCMC Ft Sanders Sevier Nursing Home-Div of LeConte Medical
;LCMC Cardiopulmonary Rehabilitation
;LCMC Comprehensive Breast Center
;LCMC Therapy Services - Sevierville
;LCMC Therapy Services - Seymour
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "LeConte Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "LCMC Sleep Disorders Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "LCMC Ft Sanders Sevier Nursing Home-Div of LeConte Medical")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "LCMC Cardiopulmonary Rehabilitation")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "LCMC Comprehensive Breast Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "LCMC Therapy Services - Sevierville")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "LCMC Therapy Services - Seymour")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("LCMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".asc"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
 
;Fort Sanders Regional Medical Center
;FSR Therapy Center - Halls
;FSR West Diagnostic Center
;FSR Patricia Neal Rehabilitation Center
;FSR Select Specialty Hospital
;FSR Thompson Comprehensive Breast Center
;FSR Transitional Care Unit
;FSR Wound Treatment Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Fort Sanders Regional Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "FSR Therapy Center - Halls")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "FSR West Diagnostic Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "FSR Patricia Neal Rehabilitation Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "FSR Select Specialty Hospital")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "FSR Thompson Comprehensive Breast Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "FSR Transitional Care Unit")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "FSR Wound Treatment Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("FSR")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".asc"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
;Fort Loudoun Medical Center
;FLMC Therapy Center - Lenoir City
;FLMC Therapy Center - Loudon
;FLMC Cardiopulmonary Rehabilitation
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Fort Loudoun Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "FLMC Therapy Center - Lenoir City")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "FLMC Therapy Center - Loudon")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "FLMC Cardiopulmonary Rehabilitation")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,^"^,cnvtstring(t_rec->cons.all_facilities[i].value,20,0),^"^
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("FLMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".asc"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
;Report 5 Order Verification Turn Around Time (Summary) (PHA_ORD_VERIFY_TAT)
set j = 0 ;reset instance counter
set t_rec->cnt = 5
set stat = alterlist(t_rec->reports,t_rec->cnt)
set k = t_rec->cnt
 
set t_rec->reports[k].title 			= "Order Verification Turn Around Time (Summary)"
set t_rec->reports[k].object 			= "PHA_ORD_VERIFY_TAT"
set t_rec->reports[k].param_template	= build2(	 ^"FILENAME", "1 ", ALL_FACILITY, "START_DT_TM_VAR", "END_DT_TM_VAR", 1, 0, "1"^)
set t_rec->reports[k].start_dt_tm		= t_rec->cons.dates.prev_month_start_dt_tm
set t_rec->reports[k].end_dt_tm			= t_rec->cons.dates.prev_month_end_dt_tm
set t_rec->reports[k].start_dt_tm_vc	= format(t_rec->reports[k].start_dt_tm,	"DD-MMM-YYYY HH:MM:SS;;q")
set t_rec->reports[k].end_dt_tm_vc		= format(t_rec->reports[k].end_dt_tm,	"DD-MMM-YYYY HH:MM:SS;;q")
 
;Roane Medical Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Roane Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("RMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".pdf"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
;Parkwest Medical Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Parkwest Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("PWMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".pdf"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
;Methodist Medical Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Methodist Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("MMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".pdf"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
;LeConte Medical Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "LeConte Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("LCMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".pdf"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
;Fort Loudoun Medical Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Fort Loudoun Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("FLMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".pdf"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
;Morristown-Hamblen Healthcare System
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Morristown-Hamblen Healthcare System")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("MHHS")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".pdf"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
 
;Fort Sanders Regional Medical Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Fort Sanders Regional Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("FSR")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".pdf"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)


;Infusion Centers
/*
LCMC Infusion Clinic - Blount
LCMC Infusion Clinic - Downtown
FSR Infusion Clinic - Lenoir City
FSR Infusion Clinic - Oak Ridge
LCMC Infusion Clinic - Sevier
LCMC Infusion Clinic - West
*/
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "FSR Infusion Clinic - Lenoir City")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "FSR Infusion Clinic - Oak Ridge")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "LCMC Infusion Clinic - Blount")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	 ,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "LCMC Infusion Clinic - Downtown")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "LCMC Infusion Clinic - Sevier")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "LCMC Infusion Clinic - West")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("TOG")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".pdf"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)




 
;Report 6 - Pharmacy Specialty Report (COV_PHA_SPECIALTY_RX_MEDS)
set t_rec->cnt = 6
set stat = alterlist(t_rec->reports,t_rec->cnt)
set k = t_rec->cnt
 
set t_rec->reports[k].title 			= "Cov - Specialty Pharmacy Audit"
set t_rec->reports[k].object 			= "COV_PHA_SPECIALTY_RX_MEDS"
set t_rec->reports[k].param_template	= ^"FILENAME", "START_DT_TM_VAR", "END_DT_TM_VAR", VALUE(0), "", VALUE(0), REPORT_OPTION^
set t_rec->reports[k].start_dt_tm		= t_rec->cons.dates.prev_month_start_dt_tm
set t_rec->reports[k].end_dt_tm			= t_rec->cons.dates.prev_month_end_dt_tm
set t_rec->reports[k].start_dt_tm_vc	= format(t_rec->reports[k].start_dt_tm,	"DD-MMM-YYYY HH:MM:SS;;q")
set t_rec->reports[k].end_dt_tm_vc		= format(t_rec->reports[k].end_dt_tm,	"DD-MMM-YYYY HH:MM:SS;;q")
set t_rec->reports[k].override_astream_ccl	= 1
 
;Report Option 1
set j = 0
for (i=1 to 1) ;only need 1 instance
	set j = (j + 1)
	set t_rec->reports[k].instance_cnt = j
	set stat = alterlist(t_rec->reports[k].instances,j)
	set t_rec->reports[k].instances[j].facility 	= "all"
	set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
	set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("cov")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																;,"_"
																;,cnvtlower(format(t_rec->reports[k].start_dt_tm,"MMM;;q"))
																;,"_"
																;,t_rec->cons.run_dt_tm_filename
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"REPORT_OPTION"
															,cnvtstring(0)
														)
endfor
 
 
 
 
;Report 7 - Pharmacy Lab Orders (COV_PHA_LABORDERSBYPHARM)
;cov_pha_labordersbypharm
;"MINE", "21-JAN-2022 00:00:00", "21-JAN-2022 23:59:00", VALUE(2552503649.00), 1
set t_rec->cnt = 7
set stat = alterlist(t_rec->reports,t_rec->cnt)
set k = t_rec->cnt
 
set t_rec->reports[k].title 			= "Cov - Pharmacy Lab Orders"
set t_rec->reports[k].object 			= "COV_PHA_LABORDERSBYPHARM"
set t_rec->reports[k].param_template	= ^"FILENAME", "START_DT_TM_VAR", "END_DT_TM_VAR", ALL_FACILITY, REPORT_OPTION^
set t_rec->reports[k].start_dt_tm		= t_rec->cons.dates.prev_month_start_dt_tm
set t_rec->reports[k].end_dt_tm			= t_rec->cons.dates.prev_month_end_dt_tm
set t_rec->reports[k].start_dt_tm_vc	= format(t_rec->reports[k].start_dt_tm,	"DD-MMM-YYYY HH:MM:SS;;q")
set t_rec->reports[k].end_dt_tm_vc		= format(t_rec->reports[k].end_dt_tm,	"DD-MMM-YYYY HH:MM:SS;;q")
 
;Report Option 1
set j = 0
 
;Parkwest Medical Center and PW Senior Behavioral Unit
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Parkwest Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "PW Senior Behavioral Unit")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
 
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("PWMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"REPORT_OPTION"
															,cnvtstring(1)
														)
 
 
;Roane Medical Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Roane Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("RMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"REPORT_OPTION"
															,cnvtstring(1)
														)
 
 
;Peninsula Behavioral Health - Div of Parkwest Medical Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Peninsula Behavioral Health - Div of Parkwest Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("PBH")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"REPORT_OPTION"
															,cnvtstring(1)
														)
 
 
 
;Methodist Medical Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Methodist Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("MMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"REPORT_OPTION"
															,cnvtstring(1)
														)
 
;LeConte Medical Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "LeConte Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("LCMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"REPORT_OPTION"
															,cnvtstring(1)
														)
 
 
;Fort Loudoun Medical Center
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Fort Loudoun Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("FLMC")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"REPORT_OPTION"
															,cnvtstring(1)
														)
 
 
;Morristown-Hamblen Healthcare System
;MHHS Ambulatory Surgery Center
;MHHS Behavioral Health
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Morristown-Hamblen Healthcare System")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "MHHS Ambulatory Surgery Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "MHHS Behavioral Health")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("MHHS")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"REPORT_OPTION"
															,cnvtstring(1)
														)
 
 
;Fort Sanders Regional Medical Center
;FSR Patricia Neal Rehabilitation Center
;FSR Transitional Care Unit
set j = (j + 1)
set t_rec->reports[k].instance_cnt = j
set stat = alterlist(t_rec->reports[k].instances,j)
set t_rec->reports[k].instances[j].facility 	= build(^value(^)
for (i=1 to t_rec->cons.all_facility_cnt)
	if (t_rec->cons.all_facilities[i].description 		= "Fort Sanders Regional Medical Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	 t_rec->reports[k].instances[j].facility
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "FSR Patricia Neal Rehabilitation Center")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
	if (t_rec->cons.all_facilities[i].description 		= "FSR Transitional Care Unit")
		set t_rec->reports[k].instances[j].facility 	= build(
																	t_rec->reports[k].instances[j].facility
																	,","
																	,t_rec->cons.all_facilities[i].value
																)
	endif
endfor
set t_rec->reports[k].instances[j].facility 	= build(t_rec->reports[k].instances[j].facility,^)^)
set t_rec->reports[k].instances[j].params 		= t_rec->reports[k].param_template
set t_rec->reports[k].instances[j].filename		= build(
																 cnvtlower("FSR")
																,"_"
																,cnvtlower(t_rec->reports[k].object)
																,"_ccl"
																,".xls"
															)
 
	set t_rec->reports[k].instances[j].temp_path	= build(
																 t_rec->cons.paths.temp
																,t_rec->reports[k].instances[j].filename
															)
	if (t_rec->reports[k].override_astream_ccl = 1)
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream_ccl
																	,t_rec->reports[k].instances[j].filename
																)	
	else
		set t_rec->reports[k].instances[j].final_path	= build(
																	 t_rec->cons.paths.astream
																	,t_rec->reports[k].instances[j].filename
																)
	endif
	
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"FILENAME"
															,t_rec->reports[k].instances[j].temp_path
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"START_DT_TM_VAR"
															,t_rec->reports[k].start_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"END_DT_TM_VAR"
															,t_rec->reports[k].end_dt_tm_vc
														)
 
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"ALL_FACILITY"
															,t_rec->reports[k].instances[j].facility
														)
	set t_rec->reports[k].instances[j].params = replace(
															 t_rec->reports[k].instances[j].params
															,"REPORT_OPTION"
															,cnvtstring(1)
														)
 
 
call echorecord(t_rec)
 
call writeLog(build2("* END   Adding Report Definitions **************************"))
call writeLog(build2("************************************************************"))
 
 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Executing Each Report Instance *********************"))
for (k=1 to t_rec->cnt)
	for (j=1 to t_rec->reports[k].instance_cnt)
	 ;if (k in(1,2,3,4,5,7)) ;remove after testing, this will limit the extract to running just one report
		set t_rec->reports[k].instances[j].ccl_command = build2(
																	 "execute "
																	,t_rec->reports[k].object
																	," "
																	,t_rec->reports[k].instances[j].params
																	," go"
																)
		call writeLog(build2("t_rec->reports[k].instances[j].ccl_command=",t_rec->reports[k].instances[j].ccl_command))
		call parser(t_rec->reports[k].instances[j].ccl_command)
		call writeLog(build2("Finished ccl_command parser"))
 
		call writeLog(build2("->Copy File to AStream"))
		set t_rec->reports[k].instances[j].astream_copy_command = build2(
																			 "mv "
																			,t_rec->reports[k].instances[j].temp_path
																			," "
																			,t_rec->reports[k].instances[j].final_path
																		)
		call writeLog(build2("t_rec->reports[k].instances[j].astream_copy_command=",t_rec->reports[k].instances[j].astream_copy_command))
		call dcl(	 t_rec->reports[k].instances[j].astream_copy_command
					,size(trim(t_rec->reports[k].instances[j].astream_copy_command))
					,t_rec->dclstat)
		call writeLog(build2("Finished astream_copy_command dcl"))
	 ;endif
	endfor
endfor
 
 
 
call writeLog(build2("* END   Executing Each Report Instance *********************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))
 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))
 
set reply->status_data.status = "S"
 
#exit_script
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)
 
 
end
go
 
