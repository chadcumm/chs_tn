/***********************************************************************************************************************
  Program Name:			cov_rpt_eks_catalog
  Source File Name:		cov_rpt_eks_catalog.prg
  Layout File Name:		n/a
  Program Written By:	Chad Cummings
  Date:					26-Apr-2022
  Program Purpose:		Extracts Rules related reference data
 
 
************************************************************************************************************************
												*MODIFICATION HISTORY*
************************************************************************************************************************
 
Rev	Date		Jira		Programmer				Comment
---	-----------	----------	---------------------	----------------------------------------------------------

***********************************************************************************************************************/
drop program cov_rpt_eks_catalog go
create program cov_rpt_eks_catalog
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Audit Type" = 0
	, "Include Inactive Rules" = 0
 
with OUTDEV, AUDIT_TYPE, INCLUDE_INACTIVE
 
 
;===================================================================================================
; DECLARED RECORDS
;===================================================================================================
record eks_audit
(
	1 prompts
	 2 outdev 					= vc
	 2 audit_type				= i4		;0-All, 1-Maintenance, 2-Library, 3-Knowledge
	 2 include_inactive			= i4
	1 cnt = i4
	1 qual[*]
		2 module_name			= c30
 		2 version				= c10
  		2 num_storage			= i4
  		2 eks_release			= c10
 		2 active_flag			= c1
  		2 updt_dt_tm			= dq8
  		2 maint_title			= vc
  		2 maint_filename		= c30
  		2 last_updated_by		= vc
  		2 maint_version			= c10
  		2 maint_institution		= vc
  		2 maint_author			= vc
  		2 maint_specialist		= vc
  		2 maint_date			= dq8
  		2 maint_dur_begin_dt_tm	= dq8
  		2 maint_dur_end_dt_tm	= dq8
  		2 maint_validation		= c12
  		2 know_type				= c20
  		2 know_priority			= i4
  		2 know_urgency			= i4
  		2 purpose				= vc
  		2 explanation			= vc
  		2 key_words				= vc
  		2 citation				= vc
  		2 links					= vc
  		2 data					= vc
  		2 evoke					= vc
  		2 logic					= vc
  		2 action				= vc
  		2 impact				= vc
  		2 query					= vc
) with protect
 
set eks_audit->prompts.outdev = $OUTDEV
set eks_audit->prompts.audit_type = $AUDIT_TYPE
set eks_audit->prompts.include_inactive = $INCLUDE_INACTIVE
 
;===================================================================================================
; DECLARED VARIABLES
;===================================================================================================
;helper variable for expand/locateval
declare vNum = i4
 
;===================================================================================================
; SUBROUTINE - Load Labels
;===================================================================================================
declare get_eks_detail(vDetail = vc) = i2
subroutine get_eks_detail(vDetail)
 
	call echo(build2("inside get_eks_detail(",trim(vDetail),")"))
 
	declare vReturn = i2 with noconstant(FALSE), protect
	declare vDataType = i2 with noconstant(0), protect
 
	case (vDetail)
		of "Purpose"		: set vDataType = 1
		of "Explanation"	: set vDataType = 2
		of "Key Words"		: set vDataType = 3
		of "Citation"		: set vDataType = 4
		of "Links"			: set vDataType = 5
		of "Data"			: set vDataType = 6
		of "Evoke"			: set vDataType = 7
		of "Logic"			: set vDataType = 8
		of "Action"			: set vDataType = 9
		of "Impact"			: set vDataType = 10
		of "Query"			: set vDataType = 11
	endcase
 
	call echo(build2("->vDataType=",vDataType))
 
	select into "nl:"
	from
		 (dummyt d1 with seq=eks_audit->cnt)
		,eks_modulestorage em
	plan d1
	join em
		where em.module_name 	= eks_audit->qual[d1.seq].module_name
		and   em.version 		= eks_audit->qual[d1.seq].version
		and   em.data_type 		= vDataType
	order by
		 em.module_name
	head em.module_name
		case (vDataType)
			of 1:		eks_audit->qual[d1.seq].purpose			= check(em.ekm_info)
			of 2:		eks_audit->qual[d1.seq].explanation		= check(em.ekm_info)
			of 3:		eks_audit->qual[d1.seq].key_words		= check(em.ekm_info)
			of 4:		eks_audit->qual[d1.seq].citation		= check(em.ekm_info)
			of 5:		eks_audit->qual[d1.seq].links			= check(em.ekm_info)
			of 6:		eks_audit->qual[d1.seq].data			= check(em.ekm_info)
			of 7:		eks_audit->qual[d1.seq].evoke			= check(em.ekm_info)
			of 8:		eks_audit->qual[d1.seq].logic			= check(em.ekm_info)
			of 9:		eks_audit->qual[d1.seq].action			= check(em.ekm_info)
			of 10:		eks_audit->qual[d1.seq].impact			= check(em.ekm_info)
			of 11:		eks_audit->qual[d1.seq].query			= check(em.ekm_info)
		endcase
	with nocounter
 
	set vReturn = vDataType
	return (vReturn)
end
 
;===================================================================================================
; MAIN LOGIC
;===================================================================================================
select into "nl:"
from
	 eks_module em
	,prsnl p
plan em
	where em.active_flag = "A"
join p
	where p.person_id = outerjoin(em.updt_id)
order by
	em.module_name
head report
	vNum = 0
	pass_ind = 0
head em.module_name
	pass_ind = 0
	if (eks_audit->prompts.include_inactive = 1)
		pass_ind = 1
	else
		if (trim(cnvtlower(em.maint_validation)) = "production")
			pass_ind = 1
		endif
	endif
foot em.module_name
	if (pass_ind = 1)
		vNum += 1
		stat = alterlist(eks_audit->qual,vNum)
		eks_audit->qual[vNum].module_name					= em.module_name
		eks_audit->qual[vNum].version						= em.version
		eks_audit->qual[vNum].num_storage					= em.num_storage
		eks_audit->qual[vNum].eks_release					= em.eks_release
		eks_audit->qual[vNum].active_flag					= em.active_flag
		eks_audit->qual[vNum].updt_dt_tm					= em.updt_dt_tm
		eks_audit->qual[vNum].maint_title					= em.maint_title
		eks_audit->qual[vNum].maint_filename				= em.maint_filename
		eks_audit->qual[vNum].last_updated_by				= p.name_full_formatted
		eks_audit->qual[vNum].maint_version					= em.maint_version
		eks_audit->qual[vNum].maint_institution				= em.maint_institution
		eks_audit->qual[vNum].maint_author					= em.maint_author
		eks_audit->qual[vNum].maint_specialist				= em.maint_specialist
		eks_audit->qual[vNum].maint_date					= em.maint_date
		eks_audit->qual[vNum].maint_dur_begin_dt_tm			= em.maint_dur_begin_dt_tm
		eks_audit->qual[vNum].maint_dur_end_dt_tm	 		= em.maint_dur_end_dt_tm
		eks_audit->qual[vNum].maint_validation				= em.maint_validation
		eks_audit->qual[vNum].know_type						= em.know_type
		eks_audit->qual[vNum].know_priority					= em.know_priority
		eks_audit->qual[vNum].know_urgency					= em.know_urgency
	endif
foot report
	eks_audit->cnt = vNum
with nocounter
 
if (eks_audit->prompts.audit_type = 3)
 
	set stat = get_eks_detail("Data")
	set stat = get_eks_detail("Evoke")
	set stat = get_eks_detail("Logic")
	set stat = get_eks_detail("Action")
 
elseif (eks_audit->prompts.audit_type = 2)
 
	set stat = get_eks_detail("Purpose")
	set stat = get_eks_detail("Explanation")
	set stat = get_eks_detail("Key Words")
	set stat = get_eks_detail("Citation")
	set stat = get_eks_detail("Links")
	set stat = get_eks_detail("Impact")
	set stat = get_eks_detail("Query")
 
elseif (eks_audit->prompts.audit_type = 0)
 
	set stat = get_eks_detail("Data")
	set stat = get_eks_detail("Evoke")
	set stat = get_eks_detail("Logic")
	set stat = get_eks_detail("Action")
	set stat = get_eks_detail("Purpose")
	set stat = get_eks_detail("Explanation")
	set stat = get_eks_detail("Key Words")
	set stat = get_eks_detail("Citation")
	set stat = get_eks_detail("Links")
	set stat = get_eks_detail("Impact")
	set stat = get_eks_detail("Query")
 
endif
 
 
select
 if (eks_audit->prompts.audit_type = 0)
	 module_name				= trim(substring(1,30,eks_audit->qual[d1.seq].module_name			))
	,version					= trim(substring(1,10,eks_audit->qual[d1.seq].version				))
	,num_storage				= eks_audit->qual[d1.seq].num_storage
	,eks_release				= trim(substring(1,10,eks_audit->qual[d1.seq].eks_release			))
	;,active_flag				= trim(substring(1,1,eks_audit->qual[d1.seq].active_flag			))
	,updt_dt_tm					= trim(format(eks_audit->qual[d1.seq].updt_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q"))
	,maint_title				= trim(substring(1,30,eks_audit->qual[d1.seq].maint_title			))
	,maint_filename				= trim(substring(1,30,eks_audit->qual[d1.seq].maint_filename		))
	,last_updated_by			= trim(substring(1,100,eks_audit->qual[d1.seq].last_updated_by		))
	,maint_version				= trim(substring(1,10,eks_audit->qual[d1.seq].maint_version			))
	,maint_institution			= trim(substring(1,100,eks_audit->qual[d1.seq].maint_institution		))
	,maint_author				= trim(substring(1,100,eks_audit->qual[d1.seq].maint_author			))
	,maint_specialist			= trim(substring(1,100,eks_audit->qual[d1.seq].maint_specialist		))
	,maint_date					= trim(format(eks_audit->qual[d1.seq].maint_date,"dd-mmm-yyyy;;d"))
	,maint_dur_begin_dt_tm		= trim(format(eks_audit->qual[d1.seq].maint_dur_begin_dt_tm,"dd-mmm-yyyy;;d"))
	,maint_dur_end_dt_tm		= trim(format(eks_audit->qual[d1.seq].maint_dur_end_dt_tm,"dd-mmm-yyyy;;d"))
	,maint_validation			= trim(substring(1,12,eks_audit->qual[d1.seq].maint_validation		))
	,know_type					= trim(substring(1,20,eks_audit->qual[d1.seq].know_type				))
	,know_priority				= eks_audit->qual[d1.seq].know_priority
	,know_urgency				= eks_audit->qual[d1.seq].know_urgency
	,purpose					= trim(substring(1,1000,eks_audit->qual[d1.seq].purpose			))
	,explanation				= trim(substring(1,1000,eks_audit->qual[d1.seq].explanation		))
	,key_words					= trim(substring(1,1000,eks_audit->qual[d1.seq].key_words			))
	,citation					= trim(substring(1,1000,eks_audit->qual[d1.seq].citation			))
	,links						= trim(substring(1,1000,eks_audit->qual[d1.seq].links				))
	,impact						= trim(substring(1,1000,eks_audit->qual[d1.seq].impact				))
	,query						= trim(substring(1,1000,eks_audit->qual[d1.seq].query				))
	,data						= trim(substring(1,1000,eks_audit->qual[d1.seq].data		))
	,evoke						= trim(substring(1,1000,eks_audit->qual[d1.seq].evoke		))
	,logic						= trim(substring(1,1000,eks_audit->qual[d1.seq].logic		))
	,action						= trim(substring(1,1000,eks_audit->qual[d1.seq].action		))
 elseif (eks_audit->prompts.audit_type = 3)
	 module_name	= trim(substring(1,30,eks_audit->qual[d1.seq].module_name	))
	,data			= trim(substring(1,1000,eks_audit->qual[d1.seq].data		))
	,evoke			= trim(substring(1,1000,eks_audit->qual[d1.seq].evoke		))
	,logic			= trim(substring(1,1000,eks_audit->qual[d1.seq].logic		))
	,action			= trim(substring(1,1000,eks_audit->qual[d1.seq].action		))
 elseif (eks_audit->prompts.audit_type = 1)
	 module_name				= trim(substring(1,30,eks_audit->qual[d1.seq].module_name			))
	,version					= trim(substring(1,10,eks_audit->qual[d1.seq].version				))
	,num_storage				= eks_audit->qual[d1.seq].num_storage
	,eks_release				= trim(substring(1,10,eks_audit->qual[d1.seq].eks_release			))
	;,active_flag				= trim(substring(1,1,eks_audit->qual[d1.seq].active_flag			))
	,updt_dt_tm					= trim(format(eks_audit->qual[d1.seq].updt_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q"))
	,maint_title				= trim(substring(1,30,eks_audit->qual[d1.seq].maint_title			))
	,maint_filename				= trim(substring(1,30,eks_audit->qual[d1.seq].maint_filename		))
	,last_updated_by			= trim(substring(1,100,eks_audit->qual[d1.seq].last_updated_by		))
	,maint_version				= trim(substring(1,10,eks_audit->qual[d1.seq].maint_version			))
	,maint_institution			= trim(substring(1,100,eks_audit->qual[d1.seq].maint_institution		))
	,maint_author				= trim(substring(1,100,eks_audit->qual[d1.seq].maint_author			))
	,maint_specialist			= trim(substring(1,100,eks_audit->qual[d1.seq].maint_specialist		))
	,maint_date					= trim(format(eks_audit->qual[d1.seq].maint_date,"dd-mmm-yyyy;;d"))
	,maint_dur_begin_dt_tm		= trim(format(eks_audit->qual[d1.seq].maint_dur_begin_dt_tm,"dd-mmm-yyyy;;d"))
	,maint_dur_end_dt_tm		= trim(format(eks_audit->qual[d1.seq].maint_dur_end_dt_tm,"dd-mmm-yyyy;;d"))
	,maint_validation			= trim(substring(1,12,eks_audit->qual[d1.seq].maint_validation		))
	,know_type					= trim(substring(1,20,eks_audit->qual[d1.seq].know_type				))
	,know_priority				= eks_audit->qual[d1.seq].know_priority
	,know_urgency				= eks_audit->qual[d1.seq].know_urgency
 elseif (eks_audit->prompts.audit_type = 2)
	 module_name	= trim(substring(1,30,eks_audit->qual[d1.seq].module_name			))
	,purpose		= trim(substring(1,1000,eks_audit->qual[d1.seq].purpose			))
	,explanation	= trim(substring(1,1000,eks_audit->qual[d1.seq].explanation		))
	,key_words		= trim(substring(1,1000,eks_audit->qual[d1.seq].key_words			))
	,citation		= trim(substring(1,1000,eks_audit->qual[d1.seq].citation			))
	,links			= trim(substring(1,1000,eks_audit->qual[d1.seq].links				))
	,impact			= trim(substring(1,1000,eks_audit->qual[d1.seq].impact				))
	,query			= trim(substring(1,1000,eks_audit->qual[d1.seq].query				))
 elseif (eks_audit->prompts.audit_type = 3)
	 module_name	= trim(substring(1,30,eks_audit->qual[d1.seq].module_name	))
	,data			= trim(substring(1,1000,eks_audit->qual[d1.seq].data		))
	,evoke			= trim(substring(1,1000,eks_audit->qual[d1.seq].evoke		))
	,logic			= trim(substring(1,1000,eks_audit->qual[d1.seq].logic		))
	,action			= trim(substring(1,1000,eks_audit->qual[d1.seq].action		))
 else
 	module_name	= trim(substring(1,30,eks_audit->qual[d1.seq].module_name			))
 endif
into eks_audit->prompts.outdev
from
	(dummyt d1 with seq=eks_audit->cnt)
plan d1
order by
	module_name
with format,separator = " ",nocounter
 
call echorecord(eks_audit)
 
end
go
