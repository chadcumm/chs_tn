drop program cov_rad_cpt_rule go
create program cov_rad_cpt_rule
/* ************************************************************
*  CR 1445.   For initial implementation.  May 2018.
*    This ccl is called from rule cov_rad_cpt.  For radiology
*    orders only.   The rule captures an initial radiology order
*    before the order is saved.
*    This ccl goes to the billing setup to capture the cpt code
*    for the order.  From the order go to the bill_item table
*    then to the bill_item_modifier table.

;001 - 09-24-19 - CCUMMIN4 - Updated Bill Item Modifier selection criteria
***************************************************************/
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
 
record eksdata(
1 tqual[4] ;data, evoke, logic and action
2 temptype = c10
2 qual[*]
 3 accession_id = f8
 3 order_id = f8
 3 encntr_id = f8
 3 person_id = f8
 3 task_assay_cd = f8
 3 clinical_event_id = f8
 3 logging = vc
 3 template_name = c30
 3 cnt = i4
 3 data[*]
 4 misc = vc
)
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
set retval = 0
;    Your Code Goes Here
 
declare save_bi_id	= f8
set save_bi_id 		= 0
 
declare cpt_back	= vc
set cpt_back		= " "
 
;set log_message = concat("*Before select*", cnvtstring(trigger_orderid))
 
select *
	from orders 		o
		, bill_item  	bi
		, bill_item_modifier bim
		, code_value cv ;001
plan o where o.order_id = trigger_orderid
		and	o.active_ind 		= 1
		and o.catalog_type_cd 	= 2517   ;  Radiology
join bi ;001 where bi.ext_description = o.order_mnemonic
		where bi.ext_parent_reference_id = o.catalog_cd ;001
		and bi.active_ind 		= 1
		and bi.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
join bim where bim.bill_item_id = bi.bill_item_id
		and bim.active_ind		= 1
		and bim.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		;001 and bim.key3_entity_name = "NOMENCLATURE"
join cv	;001
	where cv.code_value = bim.key1_id ;001
	and   cv.display = "CPT"		;001
order by
	bim.beg_effective_dt_tm desc
	,bim.bill_item_id
head o.order_id
 
		cpt_back =  bim.key6
		save_bi_id = bim.bill_item_id
		retval = 100
		call echo(build2("cpt=",trim(bim.key6)))
 		call echo(build2("bim=",trim(cnvtstring(bim.bill_item_mod_id))))
with nocounter
 
;   Now check to see if there's a CPT modifer if a CPT was found.
 
 
if (save_bi_id > 0)
 
	select into "nl:"
		from bill_item_modifier bim
 
	plan bim where bim.bill_item_id 	= save_bi_id
				and bim.active_ind 		= 1
				and bim.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
				and bim.key1_id			 = 3692   ;  cpt modifier
				and bim.key5_entity_name = "CODE_VALUE"
 
	detail	
 
		cpt_back = concat(cpt_back, bim.key6)
 	call echo(build2("modifier=",trim(bim.key6)))
	with nocounter
endif
 
 
set log_message = cpt_back
 
set log_misc1 = cpt_back
 
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
