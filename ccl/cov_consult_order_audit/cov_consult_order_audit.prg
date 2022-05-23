/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_consult_order_audit.prg
	Object name:		cov_consult_order_audit
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	08/12/2021  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_consult_order_audit:dba go
create program cov_consult_order_audit:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date and Time" = "SYSDATE"
	, "End Date and Time" = "SYSDATE"
	, "Report Type" = 0
	, "Priority" = 0
	, "Facility" = 0 

with OUTDEV, beg_dt_tm, end_dt_tm, report_type, priority, facilitiy_prompt


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

call set_codevalues(null)
call check_ops(null)

;free set t_rec
record t_rec
(
	1 prompts
	 2 outdev		= vc
	 2 beg_dt_tm	= vc
	 2 end_dt_tm	= vc
	 2 report_type  = i2
	1 files
	 2 records_attachment		= vc
	1 dminfo
	 2 info_domain	= vc
	 2 info_name	= vc
	1 cons
	 2 run_dt_tm 	= dq8
	 2 opr_fac_var = vc
	 2 opr_priority_var = vc
	1 dates
	 2 start_dt_tm	= dq8
	 2 end_dt_tm	= dq8
	1 catalog_cnt = i2
	1 catalog_qual[*]
	 2 catalog_cd = f8
	 2 mnemonic = vc
	 2 count = i4
	1 cnt	= i4
	1 qual[*]
	 2 order_id = f8
	 2 encntr_id = f8
	 2 person_id = f8
	 2 catalog_cd = f8
	 2 ordered_as = vc
	 2 mnemonic = vc
	 2 orig_order_dt_tm = dq8
	 2 priority = vc
	 2 facility = vc
	 2 loc_facility_cd = f8
	 2 unit = vc
	 2 loc_unit_cd = f8
	 2 fin = vc
	 2 mrn = vc
	 2 name = vc
)

set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.beg_dt_tm = $BEG_DT_TM
set t_rec->prompts.end_dt_tm = $END_DT_TM
set t_rec->prompts.report_type = $REPORT_TYPE

if(substring(1,1,reflect(parameter(parameter2($FACILITIY_PROMPT),0))) = "L")	;multiple values were selected
	set t_rec->cons.opr_fac_var = "in"
elseif(parameter(parameter2($FACILITIY_PROMPT),1)= 1)						;all (any) values were selected
	set t_rec->cons.opr_fac_var = "!="
else																		;a single value was selected
	set t_rec->cons.opr_fac_var = "="
endif

if(substring(1,1,reflect(parameter(parameter2($PRIORITY),0))) = "L")	;multiple values were selected
	set t_rec->cons.opr_priority_var = "in"
elseif(parameter(parameter2($PRIORITY),1)= 1)						;all (any) values were selected
	set t_rec->cons.opr_priority_var = "!="
else																		;a single value was selected
	set t_rec->cons.opr_priority_var = "="
endif

set t_rec->dates.start_dt_tm = cnvtdatetime(t_rec->prompts.beg_dt_tm)
set t_rec->dates.end_dt_tm = cnvtdatetime(t_rec->prompts.end_dt_tm)

;call addEmailLog("chad.cummings@covhlth.com")

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")



call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

select into "nl;"
from
	order_catalog oc
	,order_catalog_synonym ocs
	,order_entry_format oef
plan oef
	where oef.oe_format_name = "Physician Consults"
join ocs
	where ocs.oe_format_id = oef.oe_format_id
	and   ocs.active_ind = 1
join oc
	where oc.catalog_cd = ocs.catalog_cd
	and   oc.active_ind = 1
order by
	 oc.primary_mnemonic
	,oc.catalog_cd
head report
	i = 0
head oc.catalog_cd
	i = (i + 1)
	stat = alterlist(t_rec->catalog_qual,i)
	t_rec->catalog_qual[i].catalog_cd = oc.catalog_cd
	t_rec->catalog_qual[i].mnemonic = oc.primary_mnemonic
foot report
	t_rec->catalog_cnt = i
with nocounter
	
	
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

select into "nl:"
from
	 orders o
	,encounter e
	,person p
	,order_detail od
plan o
	where expand(i,1,t_rec->catalog_cnt,o.catalog_cd,t_rec->catalog_qual[i].catalog_cd)
	and   o.orig_order_dt_tm between cnvtdatetime(t_rec->dates.start_dt_tm) and cnvtdatetime(t_rec->dates.end_dt_tm)
join e
	where e.encntr_id = o.encntr_id
	and   operator(e.loc_facility_cd, t_rec->cons.opr_fac_var, $FACILITIY_PROMPT)
join p
	where p.person_id = e.person_id
	and   p.name_last_key not in("ZZZ*","FFFF*")
join od
	where od.order_id = o.order_id
	and   od.oe_field_id = 12657;Priority	PRIORITY	
	and   operator(od.oe_field_value, t_rec->cons.opr_priority_var, $PRIORITY)  
order by
	 o.encntr_id
	,o.order_id
	,od.action_sequence desc
head report
	j = 0
head o.order_id
	j += 1
	stat = alterlist(t_rec->qual,j)
	t_rec->qual[j].encntr_id = e.encntr_id
	t_rec->qual[j].facility	= uar_get_code_display(e.loc_facility_cd)
	t_rec->qual[j].loc_facility_cd = e.loc_facility_cd
	t_rec->qual[j].loc_unit_cd = e.loc_nurse_unit_cd
	t_rec->qual[j].mnemonic = o.order_mnemonic
	t_rec->qual[j].name = p.name_full_formatted
	t_rec->qual[j].order_id = o.order_id
	t_rec->qual[j].ordered_as = o.ordered_as_mnemonic
	t_rec->qual[j].orig_order_dt_tm = o.orig_order_dt_tm
	t_rec->qual[j].person_id = p.person_id
	t_rec->qual[j].priority = od.oe_field_display_value
	t_rec->qual[j].unit = uar_get_code_display(e.loc_nurse_unit_cd)
	t_rec->qual[j].catalog_cd = o.catalog_cd
foot report
	t_rec->cnt = j
with nocounter

call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

select into "nl:"
	 catalog_cd = t_rec->catalog_qual[d1.seq].catalog_cd
	,order_id = t_rec->qual[d2.seq].order_id
from
	 (dummyt d1 with seq=t_rec->catalog_cnt)
	,(dummyt d2 with seq=t_rec->cnt)
plan d1
join d2
	where t_rec->qual[d2.seq].catalog_cd = t_rec->catalog_qual[d1.seq].catalog_cd
order by
	 catalog_cd
	,order_id
head report
	i = 0
head catalog_cd
	i = 0
head order_id
	i += 1
foot catalog_cd
	t_rec->catalog_qual[d1.seq].count = i
with nocounter,outerjoin=d2


call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


if (t_rec->prompts.report_type = 1)

	select into t_rec->prompts.outdev
		 orderable=substring(1,100,t_rec->catalog_qual[d1.seq].mnemonic)
		,count=t_rec->catalog_qual[d1.seq].count
	from
		(dummyt d1 with seq=t_rec->catalog_cnt)
	plan d1
	order by
		t_rec->catalog_qual[d1.seq].mnemonic
	with nocounter, format, separator = " "


else
	call get_fin(null)
	call get_mrn(null)
	
	select into t_rec->prompts.outdev
		 facility = substring(1,50,t_rec->qual[d1.seq].facility)
		,orderable = substring(1,100,t_rec->qual[d1.seq].mnemonic)
		,priority = substring(1,10,t_rec->qual[d1.seq].priority)
		,order_date = format(t_rec->qual[d1.seq].orig_order_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
		,unit = substring(1,50,t_rec->qual[d1.seq].unit)
		,mrn = substring(1,20,t_rec->qual[d1.seq].mrn)
		,fin = substring(1,20,t_rec->qual[d1.seq].fin)
		,name = substring(1,100,t_rec->qual[d1.seq].name)
		,t_rec->qual[d1.seq].order_id	
	from
		(dummyt d1 with seq=t_rec->cnt)
	plan d1
	order by
		 t_rec->qual[d1.seq].facility
		,t_rec->qual[d1.seq].priority
		,t_rec->qual[d1.seq].mnemonic
	with nocounter, format, separator = " "
endif

#exit_script


;call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
;execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"Extracts/HIM/","CP" 
;execute cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->files.records_attachment)


call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
