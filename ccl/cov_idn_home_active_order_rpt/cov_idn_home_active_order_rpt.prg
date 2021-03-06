/*************************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
**************************************************************************************************
	Author:				Dan Herren
	Date Written:		December 2021
	Solution:
	Source file name:  	cov_idn_home_active_order_rpt.prg
	Object name:		cov_idn_home_active_order_rpt
	CR#:
 
	Program purpose:	Tranlated from Cerner's "idn_rx_active_order_rpt.prg"
	Executing from:		CCL
  	Special Notes:
 
**************************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  -----------------------------------------------
*	001			 Dec 2021	 Dan Herren			   CR 11788
*
**************************************************************************************************/
 
DROP PROGRAM cov_idn_home_active_order_rpt :dba GO
CREATE PROGRAM cov_idn_home_active_order_rpt :dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"                                    ;* Enter or select the printer or file name to send 
	, "Select facility" = VALUE("*                                       ")
	, "Select unit" = VALUE("*                                       ")
	, "Medication search (primary/generic)" = ""
	, "Original Order Start Date and Time" = "SYSDATE"
	, "Original Order End Date and Time" = "SYSDATE" 

with OUTDEV, FACILITY, UNIT, MED_STR, START_DT_TM, END_DT_TM
 
DECLARE fac_cnt 		= i4
DECLARE med_qual_str	= vc
declare days_range 		= i4

 
SET med_qual_str 	= cnvtupper(trim( $MED_STR))
SET cpharm 			= uar_get_code_by("MEANING" ,6000 ,"PHARMACY")
SET cpharmact 		= uar_get_code_by("MEANING" ,106 ,"PHARMACY")
SET cfin 			= uar_get_code_by("MEANING" ,319 ,"FIN NBR")
SET cprimary 		= uar_get_code_by("MEANING" ,6011 ,"PRIMARY")
SET cordered 		= uar_get_code_by("MEANING" ,6004 ,"ORDERED")
SET cpending 		= uar_get_code_by("MEANING" ,6004 ,"PENDING")
SET cactivencntr 	= uar_get_code_by("MEANING" ,261 ,"ACTIVE")
SET cpreadmitencntr	= uar_get_code_by("MEANING" ,261 ,"PREADMIT") 


set days_range		= datetimediff(cnvtdatetime($END_DT_TM),cnvtdatetime($START_DT_TM))

if (days_range > 31)

	select into $OUTDEV
	from dummyt 
	head report
	col 0 "Please select a date range that is less than or equal to 30 days."	
	
	with nocounter 
	go to exit_script
endif


FREE RECORD fac
RECORD fac (
	1 fac [*]
    2 facility_cd = f8
	)
 
SELECT DISTINCT INTO "nl:"
  	 cv.code_value
  	,cv.display
 
FROM PRSNL_ORG_RELTN por
   ,LOCATION loc
   ,CODE_VALUE cv
 
PLAN por
	WHERE por.person_id = reqinfo->updt_id
		AND por.person_id > 0
		AND por.active_ind = 1
		AND por.organization_id > 0
		AND por.end_effective_dt_tm > cnvtdatetime(curdate ,curtime3)
JOIN loc
	WHERE loc.organization_id = por.organization_id
		AND loc.patcare_node_ind = 1
JOIN cv
	WHERE cv.code_value = loc.location_cd
		AND cv.code_set = 220
		AND cv.active_ind = 1
		AND cv.cdf_meaning = "FACILITY"
 
ORDER BY cv.display_key
 
HEAD REPORT
	cnt = 0
 
DETAIL
   	cnt = cnt + 1 ,
   	stat = alterlist(fac->fac,cnt)
	,fac->fac[cnt].facility_cd = cv.code_value
 
WITH nocounter
;end select
 
FREE RECORD ord
RECORD ord (
	1 ord [*]
    2 order_id = f8
 	)
 
SELECT INTO "nl:"
FROM ORDERS o
	;,ORDER_INGREDIENT oi
	,ORDER_CATALOG_SYNONYM ocs
   ;	,ENCNTR_DOMAIN ed
   	,ENCOUNTER e
   	,CODE_VALUE cv
   	,CODE_VALUE cv2
PLAN ocs
	where ocs.mnemonic_type_cd = cprimary
		AND cnvtupper(ocs.mnemonic) = patstring(build("*" ,med_qual_str ,"*"))
join o
	where o.catalog_cd = ocs.catalog_cd
		and  o.activity_type_cd = cpharmact
		;AND o.order_status_cd IN (cordered, cpending)
		AND o.orig_ord_as_flag = 2
		AND o.template_order_id = 0
		and o.orig_order_dt_tm between cnvtdatetime($START_DT_TM) and cnvtdatetime($END_DT_TM)
 
		/*
		          0.00	Normal Order
          1.00	Prescription/Discharge Order
          2.00	Recorded / Home Meds
          3.00	Patient Owns Meds - this value is deprecated and will be removed in the future
          4.00	Pharmacy Charge Only
          5.00	Satellite (Super Bill) Meds
*/
;JOIN oi
;	WHERE oi.order_id = o.order_id
;		AND oi.action_sequence = 1
;JOIN ed
;	WHERE ed.encntr_id = o.encntr_id
JOIN e
	WHERE e.encntr_id = o.encntr_id
		;AND e.encntr_status_cd = cactivencntr
JOIN cv
	WHERE cv.code_value = e.loc_facility_cd
		AND cv.display IN ($FACILITY)
		AND expand(fac_cnt ,1 ,size(fac->fac ,5) ,cv.code_value ,fac->fac[fac_cnt].facility_cd)
JOIN cv2
	WHERE cv2.code_value = e.loc_nurse_unit_cd
		AND cv2.display IN ($UNIT)
ORDER BY o.order_id
 
HEAD REPORT
   	cnt = 0
 
HEAD o.order_id
   	cnt = cnt + 1
	stat = alterlist(ord->ord ,cnt)
 
	ord->ord[cnt].order_id = o.order_id
 
WITH nullreport,expand =1,orahintcbo("XIE1ORDERS")
 ;end select
 
 
FREE RECORD fin
RECORD fin (
 	1 fin [*]
    2 encntr_id = f8
    2 fin_nbr = vc
 	)
 
SELECT INTO "nl:"
FROM (DUMMYT d WITH seq = value (size(ord->ord ,5)))
	,ORDERS o
    ,DUMMYT d2
    ,ENCNTR_ALIAS ea
 
PLAN d
JOIN o
	WHERE o.order_id = ord->ord[d.seq].order_id
JOIN d2
JOIN ea
	WHERE ea.encntr_id = o.encntr_id
		AND ea.encntr_alias_type_cd = cfin
		AND ea.active_ind = 1
		AND ea.beg_effective_dt_tm < cnvtdatetime(curdate ,curtime3)
		AND ea.end_effective_dt_tm > cnvtdatetime(curdate ,curtime3)
 
ORDER BY o.encntr_id ,
	ea.updt_dt_tm DESC
 
HEAD REPORT
   cnt = 0
 
HEAD o.encntr_id
   cnt = (cnt + 1) ,
	stat = alterlist (fin->fin ,cnt) ,fin->fin[cnt].encntr_id = o.encntr_id ,fin->fin[cnt].fin_nbr = trim(ea.alias)
 
WITH outerjoin = d2
 ;end select
 
 
SELECT distinct INTO $OUTDEV
	 fin = substring (1 ,30 ,fin->fin[d2.seq].fin_nbr)
  	,patient_name = substring (1 ,50 ,p.name_full_formatted)
  	,entry_dt_tm = format (o.orig_order_dt_tm ,"@SHORTDATETIME")
  	,current_status = uar_get_code_display (o.order_status_cd)
  	,order_display =
  		IF ((o.iv_ind = 1))
   			IF ((trim (o.ordered_as_mnemonic) > " "))
				trim (o.ordered_as_mnemonic)
   			ELSE
				trim (o.hna_order_mnemonic)
   			ENDIF
  		ELSE
   			IF ((trim (o.ordered_as_mnemonic) > " ")
   				AND (trim (o.ordered_as_mnemonic) != trim (o.hna_order_mnemonic))) concat (trim (o
      				.hna_order_mnemonic) ," (" ,trim (o.ordered_as_mnemonic) ,")")
   			ELSE
				trim (o.hna_order_mnemonic)
   			ENDIF
  		ENDIF
  	,order_details = check(substring(1, 100, o.clinical_display_line))
  	,entered_by = pr.name_full_formatted
  	,position = uar_get_code_display(pr.position_cd)
  	,unit = uar_get_code_display(e.loc_nurse_unit_cd)
  	,room = uar_get_code_display(e.loc_room_cd)
  	,bed = uar_get_code_display(e.loc_bed_cd)
  	,powerplan = pc.description
  	,ord_comment = check(substring(1,3000,replace(replace(lt.long_text, char(13), " ", 0), char(10), " ", 0)))
  	,o.order_id
 
FROM (DUMMYT d WITH seq = value(size(ord->ord ,5)))
   	,ORDERS o
    ,(DUMMYT d2 WITH seq = value(size(fin->fin,5)))
    ,ENCOUNTER e
    ,PERSON p
    ,ORDER_ACTION oa
    ,PRSNL pr
    ,DUMMYT d3
    ,PATHWAY_CATALOG pc
    ,ORDER_COMMENT oc ;001
    ,LONG_TEXT lt ;001
 
PLAN d
JOIN o
	WHERE o.order_id = ord->ord[d.seq].order_id
JOIN d2
   	WHERE o.encntr_id = fin->fin[d2.seq].encntr_id
JOIN p
   	WHERE o.person_id = p.person_id
JOIN oa
   	WHERE oa.order_id = o.order_id
   		AND oa.action_sequence = 1
JOIN pr
   	WHERE pr.person_id = oa.action_personnel_id
JOIN e
   	WHERE e.encntr_id = o.encntr_id
JOIN d3
JOIN pc
   	WHERE pc.pathway_catalog_id = o.pathway_catalog_id
JOIN oc ;001
   	WHERE oc.order_id = outerjoin(o.order_id) ;001
JOIN lt ;001
   	WHERE lt.long_text_id = outerjoin(oc.long_text_id) ;001
 
ORDER BY
	o.orig_order_dt_tm
;	,order_display
   	,order_details
   	,o.order_id
 
WITH outerjoin = d3 ,format ,separator = " "
 ;end select

#exit_script 
 
END GO
