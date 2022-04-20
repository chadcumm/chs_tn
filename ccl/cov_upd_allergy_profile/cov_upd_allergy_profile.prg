/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:
  Source file name:   cov_upd_allergy_profile.prg
  Object name:        cov_upd_allergy_profile
  Request #:
 
  Program purpose:
 
  Executing from:     CCL
 
  Special Notes:      Called by ccl program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings			initial build
002   03/23/2019  Chad Cummings			added active_ind to 101706 call
003   09/16/2020  Chad Cummings			removed reaction class from ft to coded flip
004   09/22/2020  Chad Cummings			used lowercase to compare allergies
005   12/03/2021  Chad Cummings			11621 Change specific Side Effects to Allergies
******************************************************************************/
drop program cov_upd_allergy_profile:dba go
create program cov_upd_allergy_profile:dba
 
set retval = -1
 
free record t_rec
record t_rec
(
	1 curprog					= vc
	1 custom_code_set			= i4
	1 custom_code_set_conv		= i4
	1 patient
	 2 encntr_id 				= f8
	 2 person_id 				= f8
	1 retval 					= i2
	1 log_message 				= vc
	1 log_misc1 				= vc
	1 return_value 				= vc
	1 nka_nomed_id 				= f8
	1 substance_type_cd 		= f8
	1 reaction_class_cd 		= f8
	1 side_effect_reaction_class_cd = f8
	1 int_reaction_class_cd 	= f8
	1 contr_reaction_class_cd	= f8
	1 reaction_status_cd 		= f8
	1 cur_allergy_qual 			= i2
	1 cur_side_effect_qual		= i2	;005
	1 allergy_cnt 				= i2
	1 allergy_qual[*]
	 2 allergy_id 				= f8
	1 reactions
	 2 freetext_pos				= i2
	 2 freetext_cnt				= i2
	 2 freetext_qual[*]
	  3 reaction_ftdesc			= vc
	 2 nomenclature_pos			= i2
	 2 nomenclature_cnt			= i2
	 2 nomenclature_qual[*]
	  3 source_string			= vc
	;START 005
	1 allergies
	 2 freetext_pos				= i2
	 2 freetext_cnt				= i2
	 2 freetext_qual[*]
	  3 allergies_ftdesc		= vc
	 2 nomenclature_pos			= i2
	 2 nomenclature_cnt			= i2
	 2 nomenclature_qual[*]
	  3 source_string			= vc
	;END 005
	
	1 alg_ex_cat_cnt			= i2
	1 alg_ex_cat_qual[*]
	 2 category_name			= vc
	 2 category_id				= f8
	1 alg_ex_class_cnt			= i2
	1 alg_ex_class_qual[*]
	 2 class_name				= vc
	 2 class_id					= f8

	1 alg_exclude_pos			= i2
	1 alg_exclude_cnt			= i2
	1 alg_exclue_qua[*]			
	 2 identifier 				= vc
	1 conversion
	 2 substance_cnt			= i2
	 2 substance_qual[*]
	  3 source_string			= vc
	  3 source_identifier		= vc
	  3 allergy_type_disp		= vc
	  3 allergy_type_cd			= f8
	  3 substance_nomen_id		= f8
	  3 freetext_cnt			= i2
	  3 substance_type			= vc
	  3 substance_type_cd		= f8
	  3 freetext_qual[*]
	   4 substance_ftdesc		= vc
)
 
%i cust_script:cov_upd_allergy_profile.inc
 
/*Sample
 
 <allergy_cnt>1</allergy_cnt>
    <allergy>
       <allergy_instance_id>0</allergy_instance_id>
       <allergy_id>0</allergy_id>
       <person_id>18010348</person_id>
       <encntr_id>113915787</encntr_id>
       <substance_nom_id>960419</substance_nom_id>
       <substance_ftdesc></substance_ftdesc>
       <substance_type_cd>3288</substance_type_cd>
       <reaction_class_cd>638974</reaction_class_cd>
       <severity_cd>0</severity_cd>
       <source_of_info_cd>0</source_of_info_cd>
       <source_of_info_ft></source_of_info_ft>
       <onset_dt_tm>0000-00-00T00:00:00.00</onset_dt_tm>
       <onset_tz>0</onset_tz>
       <onset_precision_cd>0</onset_precision_cd>
       <onset_precision_flag>0</onset_precision_flag>
       <reaction_status_cd>3299</reaction_status_cd>
       <cancel_reason_cd>0</cancel_reason_cd>
       <cancel_dt_tm>0000-00-00T00:00:00.00</cancel_dt_tm>
       <cancel_prsnl_id>0</cancel_prsnl_id>
       <created_prsnl_id>-999</created_prsnl_id>
       <reviewed_dt_tm>2019-11-06T13:35:17.00</reviewed_dt_tm>
       <reviewed_tz>126</reviewed_tz>
       <reviewed_prsnl_id>16908168</reviewed_prsnl_id>
       <active_ind>1</active_ind>
       <active_status_cd>0</active_status_cd>
       <active_status_dt_tm>0000-00-00T00:00:00.00</active_status_dt_tm>
       <active_status_prsnl_id>0</active_status_prsnl_id>
       <beg_effective_dt_tm>0000-00-00T00:00:00.00</beg_effective_dt_tm>
       <beg_effective_tz>0</beg_effective_tz>
       <end_effective_dt_tm>0000-00-00T00:00:00.00</end_effective_dt_tm>
       <contributor_system_cd>0</contributor_system_cd>
       <data_status_cd>0</data_status_cd>
       <data_status_dt_tm>0000-00-00T00:00:00.00</data_status_dt_tm>
       <data_status_prsnl_id>0</data_status_prsnl_id>
       <verified_status_flag>0</verified_status_flag>
       <rec_src_vocab_cd>0</rec_src_vocab_cd>
       <rec_src_identifier></rec_src_identifier>
       <rec_src_string></rec_src_string>
       <cmb_instance_id>0</cmb_instance_id>
       <cmb_flag>0</cmb_flag>
       <cmb_prsnl_id>0</cmb_prsnl_id>
       <cmb_person_id>0</cmb_person_id>
       <cmb_dt_tm>0000-00-00T00:00:00.00</cmb_dt_tm>
       <cmb_tz>0</cmb_tz>
       <updt_id>0</updt_id>
       <reaction_status_dt_tm>0000-00-00T00:00:00.00</reaction_status_dt_tm>
       <created_dt_tm>0000-00-00T00:00:00.00</created_dt_tm>
       <orig_prsnl_id>0</orig_prsnl_id>
       <reaction_cnt>0</reaction_cnt>
       <allergy_comment_cnt>0</allergy_comment_cnt>
       <sub_concept_cki></sub_concept_cki>
       <pre_generated_id>0</pre_generated_id>
    </allergy>
    <disable_inactive_person_ens>1</disable_inactive_person_ens>
    <fail_on_duplicate>0</fail_on_duplicate>
 
*/
 
set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid
 
declare j = i2 with noconstant(0), public
declare i = i2 with noconstant(0), public
declare k = i2 with noconstant(0), public
declare h = i2 with noconstant(0), public
declare r = i2 with noconstant(0), public
 
set t_rec->curprog = curprog
;set t_rec->curprog = "" ;override for dev script
 
if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif
 
if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif
 
/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */
 
call echo(build2("Getting custom code set"))
 
select into "nl:"
from
	code_value_set cvs
plan cvs
	    where cvs.definition            in("COVCUSTOM","COVCUSTOMPHACONV")
order by
	 cvs.definition
	,cvs.updt_dt_tm desc
head cvs.definition
	case (cvs.definition)
		of "COVCUSTOM":			t_rec->custom_code_set		= cvs.code_set
		of "COVCUSTOMPHACONV":	t_rec->custom_code_set_conv = cvs.code_set
	endcase
 
with nocounter
 
if (t_rec->custom_code_set = 0)
	set t_rec->log_message = "The Custom Code Set was not Found"
	go to exit_script
endif
 
call echo(build2("definitions to flip between allergies and side effects"))
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
										 "REACTION_FT"
										,"REACTION_KEY"
										,"ALLERGY_FT"  ;005
										,"ALLERGY_KEY" ;005
										,"ALG_EX_CAT"
										,"ALG_EX_CLASS"
									   )
order by
	 cv1.cdf_meaning
	,cv1.code_value
head report
	row +0
head cv1.cdf_meaning
	row +0
head cv1.code_value
	case (cv1.cdf_meaning)
		of "REACTION_FT":	t_rec->reactions.freetext_cnt = (t_rec->reactions.freetext_cnt + 1)
							stat = alterlist(t_rec->reactions.freetext_qual,t_rec->reactions.freetext_cnt)
							t_rec->reactions.freetext_qual[t_rec->reactions.freetext_cnt].reaction_ftdesc = cv1.display
		of "REACTION_KEY":	t_rec->reactions.nomenclature_cnt = (t_rec->reactions.nomenclature_cnt + 1)
							stat = alterlist(t_rec->reactions.nomenclature_qual,t_rec->reactions.nomenclature_cnt)
							t_rec->reactions.nomenclature_qual[t_rec->reactions.nomenclature_cnt].source_string = cv1.display
		;start 005
		of "ALLERGY_FT":	t_rec->allergies.freetext_cnt = (t_rec->allergies.freetext_cnt + 1)
							stat = alterlist(t_rec->allergies.freetext_qual,t_rec->allergies.freetext_cnt)
							t_rec->allergies.freetext_qual[t_rec->allergies.freetext_cnt].allergies_ftdesc = cv1.display
		of "ALLERGY_KEY":	t_rec->allergies.nomenclature_cnt = (t_rec->allergies.nomenclature_cnt + 1)
							stat = alterlist(t_rec->allergies.nomenclature_qual,t_rec->allergies.nomenclature_cnt)
							t_rec->allergies.nomenclature_qual[t_rec->allergies.nomenclature_cnt].source_string = cv1.display
		;end 005
		of "ALG_EX_CAT":	t_rec->alg_ex_cat_cnt = (t_rec->alg_ex_cat_cnt + 1)
							stat = alterlist(t_rec->alg_ex_cat_qual,t_rec->alg_ex_cat_cnt)
							t_rec->alg_ex_cat_qual[t_rec->alg_ex_cat_cnt].category_name = cv1.display
		of "ALG_EX_CLASS":	t_rec->alg_ex_class_cnt = (t_rec->alg_ex_class_cnt + 1)
							stat = alterlist(t_rec->alg_ex_class_qual,t_rec->alg_ex_class_cnt)
							t_rec->alg_ex_class_qual[t_rec->alg_ex_class_cnt].class_name = cv1.display
	endcase
foot cv1.code_value
	row +0
foot cv1.cdf_meaning
	row +0
foot report
	row +0
with nocounter
 
call echo(build2("Getting definitions of allergies to code"))
select into "nl:"
from
      code_value cv1
     ,code_value_extension cve1
     ,code_value_group cvg
     ,code_value cv2
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set_conv
	;and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			in(
										 "ALLERGY_KEY"
									   )
join cve1
	where cve1.code_value			= cv1.code_value
	and   cve1.field_name			in(
										"VOCABULARY"
										,"CATEGORY"
										)
join cvg
	where cvg.parent_code_value		= cv1.code_value
join cv2
	where cv2.code_value			= cvg.child_code_value
	and   cv2.active_ind 			= 1
	and   cv2.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv2.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
order by
	 cv1.code_value
	,cv2.code_value
	,cve1.field_name
head report
	call echo(build2("finding free-text to coded query"))
head cv1.code_value
	call echo(build2("cv1.code_value=",trim(cv1.display)))
	t_rec->conversion.substance_cnt = (t_rec->conversion.substance_cnt + 1)
	stat = alterlist(t_rec->conversion.substance_qual,t_rec->conversion.substance_cnt)
	t_rec->conversion.substance_qual[t_rec->conversion.substance_cnt].source_identifier = cv1.description
	t_rec->conversion.substance_qual[t_rec->conversion.substance_cnt].source_string		= cv1.display
head cv2.code_value
	call echo(build2("cv2.code_value=",trim(cv2.display)))
	t_rec->conversion.substance_qual[t_rec->conversion.substance_cnt].freetext_cnt =
		(t_rec->conversion.substance_qual[t_rec->conversion.substance_cnt].freetext_cnt + 1)
	stat = alterlist(t_rec->conversion.substance_qual[t_rec->conversion.substance_cnt].freetext_qual,
		t_rec->conversion.substance_qual[t_rec->conversion.substance_cnt].freetext_cnt)
	t_rec->conversion.substance_qual[t_rec->conversion.substance_cnt].freetext_qual[t_rec->conversion.substance_qual[t_rec->
		conversion.substance_cnt].freetext_cnt].substance_ftdesc = cv2.display
head cve1.field_name
	row +0
foot cve1.field_name
	case (cve1.field_name)
		of "VOCABULARY":
			t_rec->conversion.substance_qual[t_rec->conversion.substance_cnt].allergy_type_disp = cve1.field_value
			t_rec->conversion.substance_qual[t_rec->conversion.substance_cnt].allergy_type_cd   =
																	uar_get_code_by("DISPLAY",400,trim(cve1.field_value))
		of "CATEGORY":
			t_rec->conversion.substance_qual[t_rec->conversion.substance_cnt].substance_type = trim(cve1.field_value)
			t_rec->conversion.substance_qual[t_rec->conversion.substance_cnt].substance_type_cd =
																uar_get_code_by("MEANING",12020,trim(cnvtupper(cve1.field_value)))
	endcase
foot cv2.code_value
	row +0
foot cv1.code_value
	row +0
foot report
	call echo(build2("finished free-text to coded query"))
with nocounter,nullreport
 
for (i = 1 to t_rec->conversion.substance_cnt)
	select into "nl:"
		 n.nomenclature_id
		,n.source_identifier
		,n.source_string
	from
		 nomenclature n
		,code_value cv1
	plan cv1
		where cv1.code_set				= 400
		and   cv1.display 				= t_rec->conversion.substance_qual[i].allergy_type_disp
		and   cv1.active_ind 			= 1
	join n
		where n.source_vocabulary_cd 	= cv1.code_value
		and   n.source_identifier 		= t_rec->conversion.substance_qual[i].source_identifier
		and   n.source_string			= t_rec->conversion.substance_qual[i].source_string
		and	  n.active_ind				= 1
		and   cnvtdatetime(curdate,curtime3) between n.beg_effective_dt_tm and n.end_effective_dt_tm
	order by
		 n.source_identifier
		,n.beg_effective_dt_tm desc
	head report
		call echo(build2("inside nomenclature query"))
	head n.source_identifier
		t_rec->conversion.substance_qual[i].substance_nomen_id = n.nomenclature_id
	foot n.source_identifier
		call echo(build2("->found ",trim(n.source_identifier),":",trim(n.source_string),"=",trim(cnvtstring(n.nomenclature_id))))
	foot report
		call echo(build2("leaving nomencatlure query"))
	with nocounter
endfor
 
set t_rec->reaction_class_cd	= uar_get_code_by("MEANING",12021,"ALLERGY")
set t_rec->int_reaction_class_cd = uar_get_code_by("MEANING",12021,"INTOLERANCE")
set t_rec->contr_reaction_class_cd = uar_get_code_by("MEANING",12021,"TOXICITY")
set t_rec->side_effect_reaction_class_cd = uar_get_code_by("MEANING",12021,"SIDEEFFECT")
set t_rec->reaction_status_cd	= uar_get_code_by("MEANING",12025,"ACTIVE")
set t_rec->substance_type_cd	= uar_get_code_by("MEANING",12020,"DRUG")
 
if (t_rec->reaction_class_cd <= 0.0)
	set t_rec->log_message = concat("Reaction Class of Allegy not found")
	go to exit_script
endif
 
if (t_rec->reaction_status_cd <= 0.0)
	set t_rec->log_message = concat("Reaction Status of Active not found")
	go to exit_script
endif
 
if (t_rec->substance_type_cd <= 0.0)
	set t_rec->log_message = concat("Substance Type of Drug not found")
	go to exit_script
endif
 
set 963006request->person_id = t_rec->patient.person_id
 
set t_rec->return_value = "FALSE"
 
;005 call echo("get allergy profile for the patient, then check for side effect conversions")
call echo("-------------------------------------------------------------------------------------")
call echo("get allergy profile for the patient, then check for side effect / allergy conversions") ;005
call echo("-------------------------------------------------------------------------------------")
;call echorecord(963006request)
set stat = tdbexecute(600005, 963006, 963006, "REC", 963006request, "REC", 963006reply)
call echorecord(963006reply)
 
if (963006reply->allergy_qual = 0)
	go to exit_script
endif
 
 
call echo(" ")
call echo(" ")
call echo("__reset current allergy qualifed to no")
set t_rec->cur_allergy_qual = 0
 
 
call echo("**********************************************************")
call echo("checking reactions of allergies to convert to side effects")	;005
call echo("**********************************************************")
 
for (i=1 to 963006reply->allergy_qual)
	;reset current allergy qualifed to no
	set t_rec->cur_allergy_qual = 0
 
	call echo("->check allergy reaction class to match ALLERGY and is active")
	if ((963006reply->allergy[i].reaction_class_cd = t_rec->reaction_class_cd) and (963006reply->allergy[i].active_ind = 1) and
		(963006reply->allergy[i].reaction_status_cd = t_rec->reaction_status_cd))
		call echo(build2("-->963006reply->allergy[",trim(cnvtstring(i)),"].reaction_class_cd=",trim(uar_get_code_display(963006reply->
			allergy[i].reaction_class_cd))))
		call echo(build2("-->963006reply->allergy[",trim(cnvtstring(i)),"].source_string=",trim((963006reply->
			allergy[i].source_string))))
		call echo(build2("-->963006reply->allergy[",trim(cnvtstring(i)),"].substance_ftdesc=",trim((963006reply->
			allergy[i].substance_ftdesc))))
 
		call echo("-->Check each reaction ")
		for (j=1 to 963006reply->allergy[i].reaction_qual)
			call echo(build2("--->963006reply->allergy[",trim(cnvtstring(i)),"].reaction[",trim(cnvtstring(j)),"].reaction_id="
				,trim(cnvtstring(963006reply->allergy[i].reaction[j].reaction_id))))
			call echo(build2("--->963006reply->allergy[",trim(cnvtstring(i)),"].reaction[",trim(cnvtstring(j)),"].source_string="
				,trim((963006reply->allergy[i].reaction[j].source_string))))
			call echo(build2("--->963006reply->allergy[",trim(cnvtstring(i)),"].reaction[",trim(cnvtstring(j)),"].reaction_ftdesc="
				,trim((963006reply->allergy[i].reaction[j].reaction_ftdesc))))
			if (963006reply->allergy[i].reaction[j].active_ind = 1)
				if ((j = 1) or ((j > 1) and (t_rec->cur_allergy_qual = 1))) ;if after the first reaction, all previous must have qualifed
 
					if (
							(locateval(	t_rec->reactions.nomenclature_pos,
									  	1,
									  	t_rec->reactions.nomenclature_cnt,
									  	trim(963006reply->allergy[i].reaction[j].source_string),
									  	t_rec->reactions.nomenclature_qual[t_rec->reactions.nomenclature_pos].source_string) > 0
							)
						or
							(locateval(	t_rec->reactions.freetext_pos,
									  	1,
									  	t_rec->reactions.freetext_cnt,
									  	trim(cnvtlower(963006reply->allergy[i].reaction[j].reaction_ftdesc)),
									  	cnvtlower(t_rec->reactions.freetext_qual[t_rec->reactions.freetext_pos].reaction_ftdesc)) > 0
							)
						)
 
						call echo(build2("---->963006reply->allergy[",trim(cnvtstring(i)),"].reaction[",trim(cnvtstring(j)),"].source_string="
							,trim(963006reply->allergy[i].reaction[j].source_string)))
						call echo(build2("---->963006reply->allergy[",trim(cnvtstring(i)),"].reaction[",trim(cnvtstring(j)),"].reaction_ftdesc="
							,trim(963006reply->allergy[i].reaction[j].reaction_ftdesc)))
						;setting allergy qualifier to YES
						set t_rec->cur_allergy_qual = 1
					else
						;setting allergy qualifer to NO
						set t_rec->cur_allergy_qual = 0
					endif ;end if matching reqaction free text or nomenclature
				else
					call echo(build2("963006reply->allergy[",trim(cnvtstring(i)),"].reaction[",trim(cnvtstring(j)),"] WAS NOT REVIEWED"))
				endif ;end check if first reaction or previous reactions qualified
			endif ; reaction is active
		endfor ;reaction qualifications
 
		; check to see if the allergy qualifies
		if (t_rec->cur_allergy_qual = 1)
			call echo(build2("963006reply->allergy[",trim(cnvtstring(i)),"].allergy_id=",trim(cnvtstring(963006reply->
			allergy[i].allergy_id))," QUALIFIED"))
 
			set 101706request->allergy_cnt = (101706request->allergy_cnt + 1)
			set stat = alterlist(101706request->allergy,101706request->allergy_cnt)
 
			set 101706request->allergy[101706request->allergy_cnt].allergy_instance_id  = 963006reply->allergy[i].allergy_instance_id
			set 101706request->allergy[101706request->allergy_cnt].allergy_id			= 963006reply->allergy[i].allergy_id
			set 101706request->allergy[101706request->allergy_cnt].encntr_id			= 963006reply->allergy[i].encntr_id
			set 101706request->allergy[101706request->allergy_cnt].person_id			= t_rec->patient.person_id
			set 101706request->allergy[101706request->allergy_cnt].reaction_class_cd	= value(uar_get_code_by("MEANING",12021,"SIDEEFFECT"))
			set 101706request->allergy[101706request->allergy_cnt].substance_ftdesc		= 963006reply->allergy[i].substance_ftdesc
			set 101706request->allergy[101706request->allergy_cnt].substance_nom_id		= 963006reply->allergy[i].substance_nom_id
			set 101706request->allergy[101706request->allergy_cnt].substance_type_cd	= 963006reply->allergy[i].substance_type_cd
			set 101706request->allergy[101706request->allergy_cnt].onset_dt_tm			= 963006reply->allergy[i].onset_dt_tm
			set 101706request->allergy[101706request->allergy_cnt].onset_precision_cd	= 963006reply->allergy[i].onset_precision_cd
			set 101706request->allergy[101706request->allergy_cnt].active_status_cd		= 963006reply->allergy[i].active_status_cd
			set 101706request->allergy[101706request->allergy_cnt].severity_cd			= 963006reply->allergy[i].severity_cd
			set 101706request->allergy[101706request->allergy_cnt].source_of_info_cd	= 963006reply->allergy[i].source_of_info_cd
			set 101706request->allergy[101706request->allergy_cnt].source_of_info_ft	= 963006reply->allergy[i].source_of_info_ft
			;set 101706request->allergy[101706request->allergy_cnt].updt_id				= 963006reply->allergy[i]
			set 101706request->allergy[101706request->allergy_cnt].updt_id				= 1.0 ;963006reply->allergy[i].updt_id
			set 101706request->allergy[101706request->allergy_cnt].reviewed_dt_tm 		= cnvtdatetime(curdate,curtime3)
			set 101706request->allergy[101706request->allergy_cnt].reviewed_tz 			= 126
			set 101706request->allergy[101706request->allergy_cnt].reviewed_prsnl_id 	= 1
			;002 set 101706request->allergy[1].active_ind 									= 1
			set 101706request->allergy[101706request->allergy_cnt].active_ind 			= 1 ;002
			;set 101706request->allergy[1].created_prsnl_id = -999
			set 101706request->disable_inactive_person_ens 								= 1
 
			; 101706request->allergy[101706request->allergy_cnt]
 
		endif
	endif ;end allergy reaction of ALLERGY
endfor ;allergy qualifications
 
if (101706request->allergy_cnt > 0)
	;call echorecord(101706request)
	set stat = tdbexecute(600005, 961706, 101706, "REC", 101706request, "REC", 101706reply)
	;call echorecord(101706reply)
	set t_rec->return_value = "TRUE"
	set t_rec->log_message = concat(trim(t_rec->log_message),";","converted allergy to side effect")
endif
 
 
;start 005
call echo(" ")
call echo(" ")
call echo("__reset current side effect qualifed to no")
set t_rec->cur_side_effect_qual = 0
 
call echo("**********************************************************")
call echo("checking reactions of side effects to convert to allergies")
call echo("**********************************************************")
 
set stat = initrec(101706request)
set stat = initrec(101706reply)
 
for (i=1 to 963006reply->allergy_qual)
	set t_rec->cur_side_effect_qual = 0
	if ((963006reply->allergy[i].reaction_class_cd in( t_rec->side_effect_reaction_class_cd
													 ; ,t_rec->contr_reaction_class_cd ;do not convert contraindications
													  ,t_rec->int_reaction_class_cd
													 ))
		and (963006reply->allergy[i].active_ind = 1) and (963006reply->allergy[i].reaction_status_cd = t_rec->reaction_status_cd))
		call echo(build2("->963006reply->allergy[",trim(cnvtstring(i)),"].reaction_class_cd=",trim(uar_get_code_display(963006reply->
			allergy[i].reaction_class_cd))))
 		call echo(build2("->963006reply->allergy[",trim(cnvtstring(i)),"].source_string=",trim((963006reply->
			allergy[i].source_string))))
		call echo(build2("->963006reply->allergy[",trim(cnvtstring(i)),"].substance_ftdesc=",trim((963006reply->
			allergy[i].substance_ftdesc))))
 
		call echo("->Check each reaction ")
 
		for (j=1 to 963006reply->allergy[i].reaction_qual)
			call echo(build2("-->963006reply->allergy[",trim(cnvtstring(i)),"].reaction[",trim(cnvtstring(j)),"].reaction_id="
				,trim(cnvtstring(963006reply->allergy[i].reaction[j].reaction_id))))
			call echo(build2("-->963006reply->allergy[",trim(cnvtstring(i)),"].reaction[",trim(cnvtstring(j)),"].source_string="
				,trim((963006reply->allergy[i].reaction[j].source_string))))
			call echo(build2("-->963006reply->allergy[",trim(cnvtstring(i)),"].reaction[",trim(cnvtstring(j)),"].reaction_ftdesc="
				,trim((963006reply->allergy[i].reaction[j].reaction_ftdesc))))
 
			if (963006reply->allergy[i].reaction[j].active_ind = 1)
				if ((j = 1) or ((j > 1) and (t_rec->cur_side_effect_qual in(0, 1)))) ;for side effect->allergy conversion, allow
																	;only one matching reaction to cause the side effect to flip
 
					if (
							(locateval(	t_rec->allergies.nomenclature_pos,
									  	1,
									  	t_rec->allergies.nomenclature_cnt,
									  	trim(963006reply->allergy[i].reaction[j].source_string),
									  	t_rec->allergies.nomenclature_qual[t_rec->allergies.nomenclature_pos].source_string) > 0
							)
						or
							(locateval(	t_rec->allergies.freetext_pos,
									  	1,
									  	t_rec->allergies.freetext_cnt,
									  	trim(cnvtlower(963006reply->allergy[i].reaction[j].reaction_ftdesc)),
									  	cnvtlower(t_rec->allergies.freetext_qual[t_rec->allergies.freetext_pos].allergies_ftdesc)) > 0
							)
						)
 
						call echo(build2("MATCH--->963006reply->allergy[",trim(cnvtstring(i)),"].reaction[",trim(cnvtstring(j)),"].source_string="
							,trim(963006reply->allergy[i].reaction[j].source_string)))
						call echo(build2("MATCH--->963006reply->allergy[",trim(cnvtstring(i)),"].reaction[",trim(cnvtstring(j)),"].reaction_ftdesc="
							,trim(963006reply->allergy[i].reaction[j].reaction_ftdesc)))
						;setting allergy qualifier to YES
						set t_rec->cur_side_effect_qual = 1
					else
						;setting allergy qualifer to NO
						;set t_rec->cur_side_effect_qual = 0
						set stat = 0
					endif ;end if matching reqaction free text or nomenclature
				else
					call echo(build2("-->963006reply->allergy[",trim(cnvtstring(i)),"].reaction[",trim(cnvtstring(j)),"] WAS NOT REVIEWED"))
				endif ;end check if first reaction or previous reactions qualified
			endif ; reaction is active
		endfor ;reaction qualifications
 
		; check to see if the allergy qualifies
		if (t_rec->cur_side_effect_qual = 1)
 
			call echo(build2("963006reply->allergy[",trim(cnvtstring(i)),"].allergy_id=",trim(cnvtstring(963006reply->
			allergy[i].allergy_id))," QUALIFIED"))
 
			set 101706request->allergy_cnt = (101706request->allergy_cnt + 1)
			set stat = alterlist(101706request->allergy,101706request->allergy_cnt)
 
			set 101706request->allergy[101706request->allergy_cnt].allergy_instance_id  = 963006reply->allergy[i].allergy_instance_id
			set 101706request->allergy[101706request->allergy_cnt].allergy_id			= 963006reply->allergy[i].allergy_id
			set 101706request->allergy[101706request->allergy_cnt].encntr_id			= 963006reply->allergy[i].encntr_id
			set 101706request->allergy[101706request->allergy_cnt].person_id			= t_rec->patient.person_id
			set 101706request->allergy[101706request->allergy_cnt].reaction_class_cd	= value(uar_get_code_by("MEANING",12021,"ALLERGY"))
			set 101706request->allergy[101706request->allergy_cnt].substance_ftdesc		= 963006reply->allergy[i].substance_ftdesc
			set 101706request->allergy[101706request->allergy_cnt].substance_nom_id		= 963006reply->allergy[i].substance_nom_id
			set 101706request->allergy[101706request->allergy_cnt].substance_type_cd	= 963006reply->allergy[i].substance_type_cd
			set 101706request->allergy[101706request->allergy_cnt].onset_dt_tm			= 963006reply->allergy[i].onset_dt_tm
			set 101706request->allergy[101706request->allergy_cnt].onset_precision_cd	= 963006reply->allergy[i].onset_precision_cd
			set 101706request->allergy[101706request->allergy_cnt].active_status_cd		= 963006reply->allergy[i].active_status_cd
			set 101706request->allergy[101706request->allergy_cnt].severity_cd			= 963006reply->allergy[i].severity_cd
			set 101706request->allergy[101706request->allergy_cnt].source_of_info_cd	= 963006reply->allergy[i].source_of_info_cd
			set 101706request->allergy[101706request->allergy_cnt].source_of_info_ft	= 963006reply->allergy[i].source_of_info_ft
			;set 101706request->allergy[101706request->allergy_cnt].updt_id				= 963006reply->allergy[i]
			set 101706request->allergy[101706request->allergy_cnt].updt_id				= 1.0 ;963006reply->allergy[i].updt_id
			set 101706request->allergy[101706request->allergy_cnt].reviewed_dt_tm 		= cnvtdatetime(curdate,curtime3)
			set 101706request->allergy[101706request->allergy_cnt].reviewed_tz 			= 126
			set 101706request->allergy[101706request->allergy_cnt].reviewed_prsnl_id 	= 1
			;002 set 101706request->allergy[1].active_ind 									= 1
			set 101706request->allergy[101706request->allergy_cnt].active_ind 			= 1 ;002
			;set 101706request->allergy[1].created_prsnl_id = -999
			set 101706request->disable_inactive_person_ens 								= 1
 
			; 101706request->allergy[101706request->allergy_cnt]
 
		endif
	endif ;end allergy reaction of ALLERGY
endfor
 
if (101706request->allergy_cnt > 0)
	call echorecord(101706request)
	set stat = tdbexecute(600005, 961706, 101706, "REC", 101706request, "REC", 101706reply)
	call echorecord(101706reply)
	set t_rec->return_value = "TRUE"
	set t_rec->log_message = concat(trim(t_rec->log_message),";","converted side effect to allergy")
endif
 
;end 005
 
call echo("----------------------------------------------------------------------------------")
call echo("get allergy profile for the patient, then check for free text to coded conversions")
call echo("----------------------------------------------------------------------------------")
 
set stat = initrec(963006request)
set stat = initrec(963006reply)
set stat = initrec(101706request)
set stat = initrec(101706reply)
 
set 963006request->person_id = t_rec->patient.person_id
 
;call echorecord(963006request)
set stat = tdbexecute(600005, 963006, 963006, "REC", 963006request, "REC", 963006reply)
;call echorecord(963006reply)
 
if (963006reply->allergy_qual = 0)
	go to exit_script
endif
 
;reset current allergy qualifed to no
set t_rec->cur_allergy_qual = 0
;call echorecord(963006reply)
for (i=1 to 963006reply->allergy_qual)
	;reset current allergy qualifed to no
	set t_rec->cur_allergy_qual = 0
	call echo(build2("963006reply->allergy[",trim(cnvtstring(i)),"].reaction_class_cd="
			,trim(uar_get_code_display(963006reply->allergy[i].reaction_class_cd))))
	call echo(build2("963006reply->allergy[",trim(cnvtstring(i)),"].substance_ftdesc="
			,trim(963006reply->allergy[i].substance_ftdesc)))
	;check to see if this substance is free text !!!DO WE NEED TO LIMIT THIS TO JUST REACTION CLASS OF ALLERY (or include SE, etc)
	if (
			;003 (963006reply->allergy[i].reaction_class_cd = t_rec->reaction_class_cd)
			(963006reply->allergy[i].reaction_class_cd > 0.0) ;003
		and (963006reply->allergy[i].active_ind = 1)
		and	(963006reply->allergy[i].reaction_status_cd = t_rec->reaction_status_cd)
		and (963006reply->allergy[i].substance_nom_id = 0.0)
		and (963006reply->allergy[i].substance_ftdesc > " ")
		)
		call echo(build2("->inside check for free text"))
		set j = 0 ;position in fretext_qual
		set k = 0 ;list in conversion.substance_cnt
		set h = 0 ;locateval variable
		for (k = 1 to t_rec->conversion.substance_cnt)
			set j = 0
			set h = 0
			;call echo(build2("->checking ",trim(t_rec->conversion.substance_qual[k].source_string)," (",trim(t_rec->conversion.
			;	substance_qual[k].source_identifier),") "))
			if (t_rec->cur_allergy_qual = 0)
				;004 set j = locateval(h,1,t_rec->conversion.substance_qual[k].freetext_cnt,963006reply->allergy[i].substance_ftdesc,
			 set j = locateval(h,1,t_rec->conversion.substance_qual[k].freetext_cnt,cnvtlower(963006reply->allergy[i].substance_ftdesc), ;004
									 cnvtlower(t_rec->conversion.substance_qual[k].freetext_qual[h].substance_ftdesc))
 
				if ((j > 0) and (t_rec->conversion.substance_qual[k].substance_nomen_id > 0.0))
					set stat = initrec(101706request)
					set stat = initrec(101706reply)
					call echo(build2("--> found locateval return j=",trim(cnvtstring(j))))
					set t_rec->cur_allergy_qual = 1

					call echo(build2("--->adding coded freetext allergy"))
					
					set 101706request->allergy_cnt = (101706request->allergy_cnt + 1)
					set stat = alterlist(101706request->allergy,101706request->allergy_cnt)
 					
					set 101706request->allergy[101706request->allergy_cnt].allergy_instance_id  = 0;963006reply->allergy[i].allergy_instance_id
					set 101706request->allergy[101706request->allergy_cnt].allergy_id			= 0;963006reply->allergy[i].allergy_id
					set 101706request->allergy[101706request->allergy_cnt].encntr_id			= 963006reply->allergy[i].encntr_id
					set 101706request->allergy[101706request->allergy_cnt].person_id			= t_rec->patient.person_id
					set 101706request->allergy[101706request->allergy_cnt].reaction_class_cd	= 963006reply->allergy[i].reaction_class_cd
					set 101706request->allergy[101706request->allergy_cnt].substance_ftdesc		= ""
					set 101706request->allergy[101706request->allergy_cnt].substance_nom_id
						= t_rec->conversion.substance_qual[k].substance_nomen_id
					;set 101706request->allergy[101706request->allergy_cnt].substance_type_cd	= 963006reply->allergy[i].substance_type_cd
					set 101706request->allergy[101706request->allergy_cnt].substance_type_cd
						= t_rec->conversion.substance_qual[k].substance_type_cd
					set 101706request->allergy[101706request->allergy_cnt].onset_dt_tm			= 963006reply->allergy[i].onset_dt_tm
					set 101706request->allergy[101706request->allergy_cnt].onset_precision_cd	= 963006reply->allergy[i].onset_precision_cd
					set 101706request->allergy[101706request->allergy_cnt].active_status_cd		= 963006reply->allergy[i].active_status_cd
					set 101706request->allergy[101706request->allergy_cnt].severity_cd			= 963006reply->allergy[i].severity_cd
					set 101706request->allergy[101706request->allergy_cnt].source_of_info_cd	= 963006reply->allergy[i].source_of_info_cd
					set 101706request->allergy[101706request->allergy_cnt].source_of_info_ft	= 963006reply->allergy[i].source_of_info_ft
					;set 101706request->allergy[101706request->allergy_cnt].updt_id				= 963006reply->allergy[i]
					set 101706request->allergy[101706request->allergy_cnt].updt_id				= 1.0 ;963006reply->allergy[i].updt_id
					set 101706request->allergy[101706request->allergy_cnt].reviewed_dt_tm 		= cnvtdatetime(curdate,curtime3)
					set 101706request->allergy[101706request->allergy_cnt].reviewed_tz 			= 126
					set 101706request->allergy[101706request->allergy_cnt].reviewed_prsnl_id 	= 1
					;002 set 101706request->allergy[1].active_ind 								= 1
					set 101706request->allergy[101706request->allergy_cnt].active_ind 			= 1 ;002
					;set 101706request->allergy[1].created_prsnl_id = -999
					set 101706request->disable_inactive_person_ens 								= 1
					set 101706request->fail_on_duplicate 										= 1
					set 101706request->allergy[101706request->allergy_cnt].reaction_cnt = size(963006reply->allergy[i].reaction,5)
					for (r = 1 to size(963006reply->allergy[i].reaction,5))
						set stat = alterlist(101706request->allergy[101706request->allergy_cnt].reaction,r)
						set 101706request->allergy[101706request->allergy_cnt].reaction[r].reaction_nom_id = 
							963006reply->allergy[i].reaction[r].reaction_nom_id
						set 101706request->allergy[101706request->allergy_cnt].reaction[r].reaction_ftdesc = 
							963006reply->allergy[i].reaction[r].reaction_ftdesc
						set 101706request->allergy[101706request->allergy_cnt].reaction[r].active_ind = 
							963006reply->allergy[i].reaction[r].active_ind
						set 101706request->allergy[101706request->allergy_cnt].reaction[r].active_status_cd = 
							963006reply->allergy[i].reaction[r].active_status_cd
						set 101706request->allergy[101706request->allergy_cnt].reaction[r].active_status_dt_tm = 
							963006reply->allergy[i].reaction[r].active_status_dt_tm
						set 101706request->allergy[101706request->allergy_cnt].reaction[r].active_status_prsnl_id = 
							963006reply->allergy[i].reaction[r].active_status_prsnl_id
						set 101706request->allergy[101706request->allergy_cnt].reaction[r].beg_effective_dt_tm = 
							963006reply->allergy[i].reaction[r].beg_effective_dt_tm
						set 101706request->allergy[101706request->allergy_cnt].reaction[r].end_effective_dt_tm = 
							963006reply->allergy[i].reaction[r].end_effective_dt_tm
						set 101706request->allergy[101706request->allergy_cnt].reaction[r].contributor_system_cd = 
							963006reply->allergy[i].reaction[r].contributor_system_cd
						set 101706request->allergy[101706request->allergy_cnt].reaction[r].data_status_cd = 
							963006reply->allergy[i].reaction[r].data_status_cd
						set 101706request->allergy[101706request->allergy_cnt].reaction[r].data_status_dt_tm = 
							963006reply->allergy[i].reaction[r].data_status_dt_tm
						set 101706request->allergy[101706request->allergy_cnt].reaction[r].data_status_prsnl_id = 
							963006reply->allergy[i].reaction[r].data_status_prsnl_id
					endfor
					call echo("--->request 101706 to add coded allergies")
					set stat = tdbexecute(600005, 961706, 101706, "REC", 101706request, "REC", 101706reply)
					set t_rec->log_message = concat(trim(t_rec->log_message),";","added coded allergy")
										
					call echo(build2("--->removing original freetext allergy"))
					set stat = initrec(101706request)
					set stat = initrec(101706reply)
					set 101706request->allergy_cnt = (101706request->allergy_cnt + 1)
					set stat = alterlist(101706request->allergy,101706request->allergy_cnt)
 					
					set 101706request->allergy[101706request->allergy_cnt].allergy_instance_id  = 963006reply->allergy[i].allergy_instance_id
					set 101706request->allergy[101706request->allergy_cnt].allergy_id			= 963006reply->allergy[i].allergy_id
					set 101706request->allergy[101706request->allergy_cnt].encntr_id			= 963006reply->allergy[i].encntr_id
					set 101706request->allergy[101706request->allergy_cnt].person_id			= t_rec->patient.person_id
					set 101706request->allergy[101706request->allergy_cnt].reaction_status_cd	= uar_get_code_by("MEANING",12025,"CANCELED")
					set 101706request->allergy[101706request->allergy_cnt].reaction_class_cd	= 963006reply->allergy[i].reaction_class_cd
					set 101706request->allergy[101706request->allergy_cnt].substance_ftdesc		= 963006reply->allergy[i].substance_ftdesc
					set 101706request->allergy[101706request->allergy_cnt].substance_nom_id
						= 963006reply->allergy[i].substance_nom_id
					;set 101706request->allergy[101706request->allergy_cnt].substance_type_cd	= 963006reply->allergy[i].substance_type_cd
					set 101706request->allergy[101706request->allergy_cnt].substance_type_cd
						= 963006reply->allergy[i].substance_type_cd
					set 101706request->allergy[101706request->allergy_cnt].onset_dt_tm			= 963006reply->allergy[i].onset_dt_tm
					set 101706request->allergy[101706request->allergy_cnt].onset_precision_cd	= 963006reply->allergy[i].onset_precision_cd
					set 101706request->allergy[101706request->allergy_cnt].active_status_cd		= 963006reply->allergy[i].active_status_cd
					set 101706request->allergy[101706request->allergy_cnt].severity_cd			= 963006reply->allergy[i].severity_cd
					set 101706request->allergy[101706request->allergy_cnt].source_of_info_cd	= 963006reply->allergy[i].source_of_info_cd
					set 101706request->allergy[101706request->allergy_cnt].source_of_info_ft	= 963006reply->allergy[i].source_of_info_ft
					;set 101706request->allergy[101706request->allergy_cnt].updt_id				= 963006reply->allergy[i]
					set 101706request->allergy[101706request->allergy_cnt].updt_id				= 1.0 ;963006reply->allergy[i].updt_id
					set 101706request->allergy[101706request->allergy_cnt].reviewed_dt_tm 		= cnvtdatetime(curdate,curtime3)
					set 101706request->allergy[101706request->allergy_cnt].reviewed_tz 			= 126
					set 101706request->allergy[101706request->allergy_cnt].reviewed_prsnl_id 	= 1
					;002 set 101706request->allergy[1].active_ind 								= 1
					set 101706request->allergy[101706request->allergy_cnt].active_ind 			= 1 ;002
					;set 101706request->allergy[1].created_prsnl_id = -999
					set 101706request->disable_inactive_person_ens 								= 1
					set 101706request->fail_on_duplicate 										= 1
					set stat = tdbexecute(600005, 961706, 101706, "REC", 101706request, "REC", 101706reply)
					set t_rec->log_message = concat(trim(t_rec->log_message),";","removed ft allergy")
					

				endif
			endif
		endfor
	endif
endfor
 
if (101706request->allergy_cnt > 0)
	;call echo("calling request 101706 to update allergies")
	;call echorecord(101706request)
	;call echorecord(101706request)
	;set stat = tdbexecute(600005, 961706, 101706, "REC", 101706request, "REC", 101706reply)
	;call echorecord(101706reply)
	;call echorecord(101706reply)
	set t_rec->return_value = "TRUE"
endif
 
#exit_script
 
if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
	set t_rec->log_misc1 = ""
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
else
	set t_rec->retval = 0
endif
 
set t_rec->log_message = concat(
										trim(t_rec->log_message),";",
										trim(cnvtupper(t_rec->return_value)),":",
										trim(cnvtstring(t_rec->patient.person_id)),"|",
										trim(cnvtstring(t_rec->patient.encntr_id)),"|"
									)
 
set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1
 
/*
if ((validate(t_rec)) and (t_rec->return_value = "TRUE"))
 call echojson(t_rec,concat("cclscratch:",trim(cnvtlower(curprog)),"_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat"),1)
 call echojson(101706request,
 	concat("cclscratch:",trim(cnvtlower(curprog)),"_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat"),1)
 call echojson(963006reply,
 	concat("cclscratch:",trim(cnvtlower(curprog)),"_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat"),1)
endif
*/
 
;call echorecord(t_rec)
end
go
 
