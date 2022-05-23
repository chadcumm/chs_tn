/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			Perioperative
	Source file name:	cov_pha_ft_conversion_audit.prg
	Object name:		cov_pha_ft_conversion_audit
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	03/30/2020  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_pha_ft_conversion_audit:dba go
create program cov_pha_ft_conversion_audit:dba

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.

with OUTDEV


call echo(build("loading script:",curprog))
set nologvar = 1	;do not create log = 1		, create log = 0
set noaudvar = 1	;do not create audit = 1	, create audit = 0
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

free set t_rec
record t_rec
(
	1 cnt			= i4
)

call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

select into $OUTDEV
	 cv1.code_value
	,cv1.display
	,cv1.description
	,cve1.field_value
	,cve2.field_value
	,cv2.display
	,cv2.code_value
	,nomen_id=n.nomenclature_id
	,n.source_string
from
	 code_value cv1
	,code_value cv2
	,code_value_extension cve1
	,code_value_extension cve2
	,code_value_group cvg1
	,nomenclature n
	,code_value cv3
	,dummyt d1
	,dummyt d3
plan cv1
	where cv1.code_set = 100523
	and   cv1.active_ind = 1
	and   cv1.cdf_meaning = "ALLERGY_KEY"
join d1
join cve1
	where cve1.code_value = cv1.code_value
	and   cve1.field_name = "CATEGORY"
join cve2
	where cve2.code_value = cv1.code_value
	and   cve2.field_name = "VOCABULARY"
join cvg1
	where cvg1.parent_code_value = cv1.code_value
join cv2
	where cv2.code_value = cvg1.child_code_value
join cv3
	where cv3.code_set				= 400
	and   cv3.display 				= cve2.field_value
	and   cv3.active_ind 			= 1
join d3
join n
	where n.source_vocabulary_cd 	= cv3.code_value
	and   n.source_identifier 		= cv1.description
	and   n.source_string			= cv1.display
	;and	  n.active_ind				= 1
	;and   cnvtdatetime(curdate,curtime3) between n.beg_effective_dt_tm and n.end_effective_dt_tm

order by
	 cv1.display
	,cv2.display
with format(date,";;q"),uar_code(d),format,seperator=" ",outerjoin=d1

call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)


end
go
