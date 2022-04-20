/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren / Chad Cummings
	Date Written:		June 2021
	Solution:
	Source file name:	cov_st_Imm_Meds_common.inc
	Object name:		cov_wh_Imm_Meds
	CR#:				9517
 
	Program purpose:	Smart Template - WH_Newborn_Immunizations_Medications
	Executing from:		cov_wh_imm_meds.prg
 
	Executing from:		CCL
 
******************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  ---------------------------------------
*
*
******************************************************************************************/
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
/*
record request
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
*/
 
if (not(validate(reply,0)))
record  reply (
	1 text 						= vc
	1 status_data
	 	2 status 				= c1
	 	2 subeventstatus[1]
	  		3 operationname 	= c15
	  		3 operationstatus 	= c1
	  		3 targetobjectname 	= c15
	  		3 targetobjectvalue = c100
	)
endif
 
record rec (
	1 rec_cnt					= i4
	1 username					= vc
	1 list[*]
		2 facility      		= vc
		2 unit    				= vc
		2 pat_name				= vc
		2 fin					= vc
		2 reg_dt				= dq8
		2 request_dt			= dq8
		2 encntr_type			= vc
		2 ce_event				= vc
		2 ce_event_tag			= vc
		2 ce_result				= vc
		2 ce_result_status		= f8
		2 ce_event_dt			= dq8
		2 ce_clinsig_dt			= dq8
		2 dosage				= vc ;f8
		2 route					= vc
		2 encntr_id				= f8
		2 person_id				= f8
		2 event_id				= f8
	)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare FIN_VAR            		= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR")),protect
declare ERYTHROMYCIN_VAR    	= f8 with constant(uar_get_code_by("DISPLAYKEY",  72, "ERYTHROMYCINOPHTHALMIC")),protect
declare PHYTONADIONE_VAR    	= f8 with constant(uar_get_code_by("DISPLAYKEY",  72, "PHYTONADIONE")),protect
declare HEPATITISBPEDIATRIC_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",  72, "HEPATITISBPEDIATRICVACCINE")),protect
declare HEPATITISBIMMUNEGLOBULIN_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",  72, "HEPATITISBIMMUNEGLOBULIN")),protect
declare GLUCOSE_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",  72, "GLUCOSE")),protect
declare NEWBORN_TYPE_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",  71, "NEWBORN")),protect
declare ORDERED_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",6004, "ORDERED")),protect
declare LIDOCAINEPRILOCAINETOPICAL_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",  72, "LIDOCAINEPRILOCAINETOPICAL")),protect
declare LIDOCAINE_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",  72, "LIDOCAINE")),protect
declare ACETAMINOPHEN_VAR = f8 with constant(uar_get_code_by("DISPLAYKEY",  72, "ACETAMINOPHEN")),protect
;--
declare ACTIVE_VAR				= f8 with constant(uar_get_code_by("MEANING",8, "ACTIVE")),protect
declare AUTHVERIFIED_VAR		= f8 with constant(uar_get_code_by("MEANING",8, "AUTH")),protect
declare ALTERED_VAR				= f8 with constant(uar_get_code_by("MEANING",8, "ALTERED")),protect
declare MODIFIED_VAR			= f8 with constant(uar_get_code_by("MEANING",8, "MODIFIED")),protect
declare NOTDONE_VAR				= f8 with constant(uar_get_code_by("MEANING",8, "NOT DONE")),protect
;--
declare username           		= vc with protect
declare initcap()          		= c100
declare num				   		= i4 with noconstant(0)
 
 
/**************************************************************
; DVDev START CODING
**************************************************************/
; GET USERNAME FOR REPORT
select into "NL:"
from
	prsnl p
where p.person_id = reqinfo->updt_id
detail
	rec->username = p.username
with nocounter
 
 
;====================================================
;MAIN SELECT FOR DATA
;====================================================
select distinct
from ENCOUNTER e
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = FIN_VAR ;1077
;		and ea.alias = "1919700054"
		and ea.active_ind = 1)
 
	,(inner join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id
		and ce.person_id = e.person_id
		and ce.event_cd in (	ERYTHROMYCIN_VAR
							, PHYTONADIONE_VAR
							, HEPATITISBPEDIATRIC_VAR
							,LIDOCAINEPRILOCAINETOPICAL_VAR
							,LIDOCAINE_VAR
							,ACETAMINOPHEN_VAR
							, HEPATITISBIMMUNEGLOBULIN_VAR) ;2797711, 2798478, 19952796
		and ce.result_status_cd in (ACTIVE_VAR, AUTHVERIFIED_VAR, MODIFIED_VAR, ALTERED_VAR, NOTDONE_VAR) ;23,25,34,35,36
		and ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3))
 
	,(inner join PERSON p on p.person_id = e.person_id
		and p.active_ind = 1)
 
	,(left join CE_MED_RESULT cmr on cmr.event_id = ce.event_id
		and cmr.valid_until_dt_tm > cnvtdatetime(curdate ,curtime3))
 
where e.encntr_id = request->visit[1].encntr_id
	and e.encntr_type_cd = NEWBORN_TYPE_VAR
	and e.active_ind = 1
 
order by e.encntr_id, ce.event_id
 
head report
	cnt  = 0
 
detail
	cnt = cnt + 1
 
	stat = alterlist(rec->list, cnt)
 
 	rec->rec_cnt = cnt
 
	rec->list[cnt].facility  		= uar_get_code_display(e.loc_facility_cd)
	rec->list[cnt].unit				= uar_get_code_display(e.loc_nurse_unit_cd)
	rec->list[cnt].pat_name			= p.name_full_formatted
	rec->list[cnt].fin				= ea.alias
	rec->list[cnt].reg_dt			= e.reg_dt_tm
	rec->list[cnt].encntr_type		= uar_get_code_display(e.encntr_type_cd)
	rec->list[cnt].ce_event			= uar_get_code_display(ce.event_cd)
	rec->list[cnt].ce_event_tag		= ce.event_tag
	rec->list[cnt].ce_result		= ce.result_val
	rec->list[cnt].ce_result_status	= ce.result_status_cd
	rec->list[cnt].ce_event_dt		= ce.event_end_dt_tm
	rec->list[cnt].ce_clinsig_dt	= ce.clinsig_updt_dt_tm
	rec->list[cnt].dosage			= cnvtstring(cmr.admin_dosage)
	rec->list[cnt].route			= uar_get_code_display(cmr.admin_route_cd)
	rec->list[cnt].encntr_id		= e.encntr_id
	rec->list[cnt].person_id		= p.person_id
	rec->list[cnt].event_id			= ce.event_id
 
 	if(rec->list[cnt].ce_result_status in (AUTHVERIFIED_VAR, ALTERED_VAR, MODIFIED_VAR)) ;25,34,35
		rec->list[cnt].dosage = build2(rec->list[cnt].ce_event_tag, " ", rec->list[cnt].route)
		rec->list[cnt].ce_result = "Given"
	else
		rec->list[cnt].ce_result = rec->list[cnt].ce_result
		rec->list[cnt].dosage = "N/A"
	endif
 



;====================================================
;GLUCOSE SPECIFIC MEDICATIONS
;====================================================
select distinct
from ENCOUNTER e
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = FIN_VAR ;1077
;		and ea.alias = "1919700054"
		and ea.active_ind = 1)
 
	,(inner join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id
		and ce.person_id = e.person_id
		and ce.event_cd in (GLUCOSE_VAR) 
		and ce.result_status_cd in (ACTIVE_VAR, AUTHVERIFIED_VAR, MODIFIED_VAR, ALTERED_VAR, NOTDONE_VAR) ;23,25,34,35,36
		and ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3))
 
	,(inner join PERSON p on p.person_id = e.person_id
		and p.active_ind = 1)
		
	,(inner join ORDERS o on O.order_id = ce.order_id)
	
	,(inner join ORDER_CATALOG_SYNONYM ocs on ocs.synonym_id = o.synonym_id
		and ocs.mnemonic = "glucose 40% oral gel")
 
	,(left join CE_MED_RESULT cmr on cmr.event_id = ce.event_id
		and cmr.valid_until_dt_tm > cnvtdatetime(curdate ,curtime3))
 
where e.encntr_id = request->visit[1].encntr_id
	and e.encntr_type_cd = NEWBORN_TYPE_VAR
	and e.active_ind = 1
 
order by e.encntr_id, ce.event_end_dt_tm desc
 
head report
	cnt  = rec->rec_cnt
 
e.encntr_id
	cnt = cnt + 1
 
	stat = alterlist(rec->list, cnt)
 
 	rec->rec_cnt = cnt
 
	rec->list[cnt].facility  		= uar_get_code_display(e.loc_facility_cd)
	rec->list[cnt].unit				= uar_get_code_display(e.loc_nurse_unit_cd)
	rec->list[cnt].pat_name			= p.name_full_formatted
	rec->list[cnt].fin				= ea.alias
	rec->list[cnt].reg_dt			= e.reg_dt_tm
	rec->list[cnt].encntr_type		= uar_get_code_display(e.encntr_type_cd)
	rec->list[cnt].ce_event			= ocs.mnemonic ;uar_get_code_display(ce.event_cd)
	rec->list[cnt].ce_event_tag		= ce.event_tag
	rec->list[cnt].ce_result		= ce.result_val
	rec->list[cnt].ce_result_status	= ce.result_status_cd
	rec->list[cnt].ce_event_dt		= ce.event_end_dt_tm
	rec->list[cnt].ce_clinsig_dt	= ce.clinsig_updt_dt_tm
	rec->list[cnt].dosage			= cnvtstring(cmr.admin_dosage)
	rec->list[cnt].route			= uar_get_code_display(cmr.admin_route_cd)
	rec->list[cnt].encntr_id		= e.encntr_id
	rec->list[cnt].person_id		= p.person_id
	rec->list[cnt].event_id			= ce.event_id
 
 	if(rec->list[cnt].ce_result_status in (AUTHVERIFIED_VAR, ALTERED_VAR, MODIFIED_VAR)) ;25,34,35
		rec->list[cnt].dosage = build2(rec->list[cnt].ce_event_tag, " ", rec->list[cnt].route)
		rec->list[cnt].ce_result = "Given"
	else
		rec->list[cnt].ce_result = rec->list[cnt].ce_result
		rec->list[cnt].dosage = "N/A"
	endif
  
;call echorecord(rec)
;go to exitscript
 
;
;;====================================================
;; REPORT OUTPUT
;;====================================================
;select into value ($OUTDEV)
;	facility      		= substring(1,50,trim(rec->list[d.seq].facility))
;	,unit    			= substring(1,40,trim(rec->list[d.seq].unit))
;	,pat_name			= substring(1,40,trim(rec->list[d.seq].pat_name))
;	,fin				= substring(1,12,rec->list[d.seq].fin)
;	,reg_dt				= format(rec->list[d.seq].reg_dt, "mm/dd/yyyy hh:mm;;q")
;	,encntr_type		= substring(1,50,trim(rec->list[d.seq].encntr_type))
;	,ce_event			= substring(1,50,trim(rec->list[d.seq].ce_event))
;	,ce_result			= substring(1,50,trim(rec->list[d.seq].ce_result))
;;	,ce_result_status	= substring(1,50,trim(rec->list[d.seq].ce_result_status))
;	,sched_admin_dt		= format(rec->list[d.seq].ce_event_dt, "mm/dd/yyyy hh:mm;;q")
;	,actual_admin_dt	= format(rec->list[d.seq].ce_clinsig_dt, "mm/dd/yyyy hh:mm;;q")
;;	,dosage				= rec->list[d.seq].dosage
;;	,route				= rec->list[d.seq].route
;	,encntr_id     		= rec->list[d.seq].encntr_id
;	,event_id	   		= rec->list[d.seq].event_id
;	,person_id			= rec->list[d.seq].person_id
;;	,username      		= rec->username
;;	,rec_cnt			= rec->rec_cnt
;
;from (DUMMYT d  with seq = value(size(rec->list,5)))
;
;plan d
;
;order by facility, pat_name, rec->list[d.seq].encntr_id, rec->list[d.seq].event_id
;
;with nocounter, format, check, separator = " "
 
 
