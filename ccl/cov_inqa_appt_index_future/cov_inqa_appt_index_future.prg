/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       02/22/2020
  Solution:           
  Source file name:   cov_inqa_appt_index_past.prg
  Object name:        cov_inqa_appt_index_past
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   02/22/2020  Chad Cummings			Initial Release
001   02/22/2020  Chad Cummings			Added Encounter/Org Security 
******************************************************************************/
DROP PROGRAM cov_inqa_appt_index_future GO
CREATE PROGRAM cov_inqa_appt_index_future
 IF ((validate (action_none ,- (1 ) ) != 0 ) )
  DECLARE action_none = i2 WITH protect ,noconstant (0 )
 ENDIF
 IF ((validate (action_add ,- (1 ) ) != 1 ) )
  DECLARE action_add = i2 WITH protect ,noconstant (1 )
 ENDIF
 IF ((validate (action_chg ,- (1 ) ) != 2 ) )
  DECLARE action_chg = i2 WITH protect ,noconstant (2 )
 ENDIF
 IF ((validate (action_del ,- (1 ) ) != 3 ) )
  DECLARE action_del = i2 WITH protect ,noconstant (3 )
 ENDIF
 IF ((validate (action_get ,- (1 ) ) != 4 ) )
  DECLARE action_get = i2 WITH protect ,noconstant (4 )
 ENDIF
 IF ((validate (action_ina ,- (1 ) ) != 5 ) )
  DECLARE action_ina = i2 WITH protect ,noconstant (5 )
 ENDIF
 IF ((validate (action_act ,- (1 ) ) != 6 ) )
  DECLARE action_act = i2 WITH protect ,noconstant (6 )
 ENDIF
 IF ((validate (action_temp ,- (1 ) ) != 999 ) )
  DECLARE action_temp = i2 WITH protect ,noconstant (999 )
 ENDIF
 IF ((validate (true ,- (1 ) ) != 1 ) )
  DECLARE true = i2 WITH protect ,noconstant (1 )
 ENDIF
 IF ((validate (false ,- (1 ) ) != 0 ) )
  DECLARE false = i2 WITH protect ,noconstant (0 )
 ENDIF
 IF ((validate (gen_nbr_error ,- (1 ) ) != 3 ) )
  DECLARE gen_nbr_error = i2 WITH protect ,noconstant (3 )
 ENDIF
 IF ((validate (insert_error ,- (1 ) ) != 4 ) )
  DECLARE insert_error = i2 WITH protect ,noconstant (4 )
 ENDIF
 IF ((validate (update_error ,- (1 ) ) != 5 ) )
  DECLARE update_error = i2 WITH protect ,noconstant (5 )
 ENDIF
 IF ((validate (replace_error ,- (1 ) ) != 6 ) )
  DECLARE replace_error = i2 WITH protect ,noconstant (6 )
 ENDIF
 IF ((validate (delete_error ,- (1 ) ) != 7 ) )
  DECLARE delete_error = i2 WITH protect ,noconstant (7 )
 ENDIF
 IF ((validate (undelete_error ,- (1 ) ) != 8 ) )
  DECLARE undelete_error = i2 WITH protect ,noconstant (8 )
 ENDIF
 IF ((validate (remove_error ,- (1 ) ) != 9 ) )
  DECLARE remove_error = i2 WITH protect ,noconstant (9 )
 ENDIF
 IF ((validate (attribute_error ,- (1 ) ) != 10 ) )
  DECLARE attribute_error = i2 WITH protect ,noconstant (10 )
 ENDIF
 IF ((validate (lock_error ,- (1 ) ) != 11 ) )
  DECLARE lock_error = i2 WITH protect ,noconstant (11 )
 ENDIF
 IF ((validate (none_found ,- (1 ) ) != 12 ) )
  DECLARE none_found = i2 WITH protect ,noconstant (12 )
 ENDIF
 IF ((validate (select_error ,- (1 ) ) != 13 ) )
  DECLARE select_error = i2 WITH protect ,noconstant (13 )
 ENDIF
 IF ((validate (update_cnt_error ,- (1 ) ) != 14 ) )
  DECLARE update_cnt_error = i2 WITH protect ,noconstant (14 )
 ENDIF
 IF ((validate (not_found ,- (1 ) ) != 15 ) )
  DECLARE not_found = i2 WITH protect ,noconstant (15 )
 ENDIF
 IF ((validate (version_insert_error ,- (1 ) ) != 16 ) )
  DECLARE version_insert_error = i2 WITH protect ,noconstant (16 )
 ENDIF
 IF ((validate (inactivate_error ,- (1 ) ) != 17 ) )
  DECLARE inactivate_error = i2 WITH protect ,noconstant (17 )
 ENDIF
 IF ((validate (activate_error ,- (1 ) ) != 18 ) )
  DECLARE activate_error = i2 WITH protect ,noconstant (18 )
 ENDIF
 IF ((validate (version_delete_error ,- (1 ) ) != 19 ) )
  DECLARE version_delete_error = i2 WITH protect ,noconstant (19 )
 ENDIF
 IF ((validate (uar_error ,- (1 ) ) != 20 ) )
  DECLARE uar_error = i2 WITH protect ,noconstant (20 )
 ENDIF
 IF ((validate (duplicate_error ,- (1 ) ) != 21 ) )
  DECLARE duplicate_error = i2 WITH protect ,noconstant (21 )
 ENDIF
 IF ((validate (ccl_error ,- (1 ) ) != 22 ) )
  DECLARE ccl_error = i2 WITH protect ,noconstant (22 )
 ENDIF
 IF ((validate (execute_error ,- (1 ) ) != 23 ) )
  DECLARE execute_error = i2 WITH protect ,noconstant (23 )
 ENDIF
 IF ((validate (failed ,- (1 ) ) != 0 ) )
  DECLARE failed = i2 WITH protect ,noconstant (false )
 ENDIF
 IF ((validate (table_name ,"ZZZ" ) = "ZZZ" ) )
  DECLARE table_name = vc WITH protect ,noconstant ("" )
 ELSE
  SET table_name = fillstring (100 ," " )
 ENDIF
 IF ((validate (call_echo_ind ,- (1 ) ) != 0 ) )
  DECLARE call_echo_ind = i2 WITH protect ,noconstant (false )
 ENDIF
 IF ((validate (i_version ,- (1 ) ) != 0 ) )
  DECLARE i_version = i2 WITH protect ,noconstant (0 )
 ENDIF
 IF ((validate (program_name ,"ZZZ" ) = "ZZZ" ) )
  DECLARE program_name = vc WITH protect ,noconstant (fillstring (30 ," " ) )
 ENDIF
 IF ((validate (sch_security_id ,- (1 ) ) != 0 ) )
  DECLARE sch_security_id = f8 WITH protect ,noconstant (0.0 )
 ENDIF
 IF ((validate (last_mod ,"NOMOD" ) = "NOMOD" ) )
  DECLARE last_mod = c5 WITH private ,noconstant ("" )
 ENDIF
 IF ((validate (schuar_def ,999 ) = 999 ) )
  CALL echo ("Declaring schuar_def" )
  DECLARE schuar_def = i2 WITH persist
  SET schuar_def = 1
  DECLARE uar_sch_check_security ((sec_type_cd = f8 (ref ) ) ,(parent1_id = f8 (ref ) ) ,(parent2_id
   = f8 (ref ) ) ,(parent3_id = f8 (ref ) ) ,(sec_id = f8 (ref ) ) ,(user_id = f8 (ref ) ) ) = i4
  WITH image_axp = "shrschuar" ,image_aix = "libshrschuar.a(libshrschuar.o)" ,uar =
  "uar_sch_check_security" ,persist
  DECLARE uar_sch_security_insert ((user_id = f8 (ref ) ) ,(sec_type_cd = f8 (ref ) ) ,(parent1_id =
   f8 (ref ) ) ,(parent2_id = f8 (ref ) ) ,(parent3_id = f8 (ref ) ) ,(sec_id = f8 (ref ) ) ) = i4
  WITH image_axp = "shrschuar" ,image_aix = "libshrschuar.a(libshrschuar.o)" ,uar =
  "uar_sch_security_insert" ,persist
  DECLARE uar_sch_security_perform () = i4 WITH image_axp = "shrschuar" ,image_aix =
  "libshrschuar.a(libshrschuar.o)" ,uar = "uar_sch_security_perform" ,persist
  DECLARE uar_sch_check_security_ex ((user_id = f8 (ref ) ) ,(sec_type_cd = f8 (ref ) ) ,(parent1_id
   = f8 (ref ) ) ,(parent2_id = f8 (ref ) ) ,(parent3_id = f8 (ref ) ) ,(sec_id = f8 (ref ) ) ) = i4
  WITH image_axp = "shrschuar" ,image_aix = "libshrschuar.a(libshrschuar.o)" ,uar =
  "uar_sch_check_security_ex" ,persist
  DECLARE uar_sch_check_security_ex2 ((user_id = f8 (ref ) ) ,(sec_type_cd = f8 (ref ) ) ,(
   parent1_id = f8 (ref ) ) ,(parent2_id = f8 (ref ) ) ,(parent3_id = f8 (ref ) ) ,(sec_id = f8 (ref
    ) ) ,(position_cd = f8 (ref ) ) ) = i4 WITH image_axp = "shrschuar" ,image_aix =
  "libshrschuar.a(libshrschuar.o)" ,uar = "uar_sch_check_security_ex2" ,persist
  DECLARE uar_sch_security_insert_ex2 ((user_id = f8 (ref ) ) ,(sec_type_cd = f8 (ref ) ) ,(
   parent1_id = f8 (ref ) ) ,(parent2_id = f8 (ref ) ) ,(parent3_id = f8 (ref ) ) ,(sec_id = f8 (ref
    ) ) ,(position_cd = f8 (ref ) ) ) = i4 WITH image_axp = "shrschuar" ,image_aix =
  "libshrschuar.a(libshrschuar.o)" ,uar = "uar_sch_security_insert_ex2" ,persist
 ENDIF
 IF ((validate (i18nuar_def ,999 ) = 999 ) )
  CALL echo ("Declaring i18nuar_def" )
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ,(p4 = f8 ) ) = i4 WITH
  persist
  DECLARE uar_i18ngetmessage ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ) = vc WITH persist
  DECLARE uar_i18nbuildmessage () = vc WITH persist
  DECLARE uar_i18ngethijridate ((imonth = i2 (val ) ) ,(iday = i2 (val ) ) ,(iyear = i2 (val ) ) ,(
   sdateformattype = vc (ref ) ) ) = c50 WITH image_axp = "shri18nuar" ,image_aix =
  "libi18n_locale.a(libi18n_locale.o)" ,uar = "uar_i18nGetHijriDate" ,persist
  DECLARE uar_i18nbuildfullformatname ((sfirst = vc (ref ) ) ,(slast = vc (ref ) ) ,(smiddle = vc (
    ref ) ) ,(sdegree = vc (ref ) ) ,(stitle = vc (ref ) ) ,(sprefix = vc (ref ) ) ,(ssuffix = vc (
    ref ) ) ,(sinitials = vc (ref ) ) ,(soriginal = vc (ref ) ) ) = c250 WITH image_axp =
  "shri18nuar" ,image_aix = "libi18n_locale.a(libi18n_locale.o)" ,uar = "i18nBuildFullFormatName" ,
  persist
  DECLARE uar_i18ngetarabictime ((ctime = vc (ref ) ) ) = c20 WITH image_axp = "shri18nuar" ,
  image_aix = "libi18n_locale.a(libi18n_locale.o)" ,uar = "i18n_GetArabicTime" ,persist
 ENDIF
 DECLARE i18nhandle = i4 WITH public ,noconstant (0 )
 SET stat = uar_i18nlocalizationinit (i18nhandle ,curprog ,"" ,curcclrev )

;start 001
free record request_3054		;uzr_get_prsnl_org_reltn
record request_3054				;uzr_get_prsnl_org_reltn
(
  1 person_id = f8
  1 filter_dir_ind = i2
  1 OrgType_pref = i2
  1 Org_type[*]
    2 org_type_cd = f8
  1 auth_only_ind = i2
  1 return_types_ind = i2
)
 
free record reply_3054			;uzr_get_prsnl_org_reltn
record reply_3054				;uzr_get_prsnl_org_reltn
(
  1 qual[*]
    2 prsnl_org_reltn_id = f8
    2 organization_id = f8
    2 org_name = vc
    2 person_id = f8
    2 name_full_formatted = vc
    2 confid_level_cd = f8
    2 confid_level_disp = c40
    2 confid_level_desc = c60
    2 service_resource_mean = c12
    2 active_ind = i2
    2 updt_cnt = i4
    2 beg_effective_dt_tm = dq8
    2 end_effective_dt_tm = dq8
    2 org_types[*] ;*007*
      3 org_type_cd = f8
      3 org_type_disp = c40
      3 org_type_desc = vc
      3 org_type_mean = c12
%i cclsource:status_block.inc
)

free set secure_locations
record secure_locations
(
	1 prsnl_secure_ind = i2
	1 org_cnt = i2
	1 org_qual[*]
	 2 org_name = vc
	 2 organization_id = f8
	1 sch_cnt = i2
	1 sch_qual[*]
	 2 sch_location = vc
	 2 sch_location_cd = f8
	 2 org_name = vc
	 2 organization_id = f8
)

;end 001

 IF (NOT (validate (get_atgroup_exp_request ,0 ) ) )
  RECORD get_atgroup_exp_request (
    1 security_ind = i2
    1 call_echo_ind = i2
    1 qual [* ]
      2 sch_object_id = f8
      2 duplicate_ind = i2
  )
 ENDIF
 IF (NOT (validate (get_atgroup_exp_reply ,0 ) ) )
  RECORD get_atgroup_exp_reply (
    1 qual_cnt = i4
    1 qual [* ]
      2 sch_object_id = f8
      2 qual_cnt = i4
      2 qual [* ]
        3 appt_type_cd = f8
  )
 ENDIF
 IF (NOT (validate (get_locgroup_exp_request ,0 ) ) )
  RECORD get_locgroup_exp_request (
    1 security_ind = i2
    1 call_echo_ind = i2
    1 qual [* ]
      2 sch_object_id = f8
      2 duplicate_ind = i2
  )
 ENDIF
 IF (NOT (validate (get_locgroup_exp_reply ,0 ) ) )
  RECORD get_locgroup_exp_reply (
    1 qual_cnt = i4
    1 qual [* ]
      2 sch_object_id = f8
      2 qual_cnt = i4
      2 qual [* ]
        3 location_cd = f8
  )
 ENDIF
 IF (NOT (validate (get_res_group_exp_request ,0 ) ) )
  RECORD get_res_group_exp_request (
    1 security_ind = i2
    1 call_echo_ind = i2
    1 qual [* ]
      2 res_group_id = f8
      2 duplicate_ind = i2
  )
 ENDIF
 IF (NOT (validate (get_res_group_exp_reply ,0 ) ) )
  RECORD get_res_group_exp_reply (
    1 qual_cnt = i4
    1 qual [* ]
      2 res_group_id = f8
      2 qual_cnt = i4
      2 qual [* ]
        3 resource_cd = f8
        3 mnemonic = vc
        3 description = vc
        3 quota = i4
        3 person_id = f8
        3 id_disp = vc
        3 res_type_flag = i2
        3 active_ind = i2
  )
 ENDIF
 IF (NOT (validate (get_slot_group_exp_request ,0 ) ) )
  RECORD get_slot_group_exp_request (
    1 security_ind = i2
    1 call_echo_ind = i2
    1 qual [* ]
      2 slot_group_id = f8
      2 duplicate_ind = i2
  )
 ENDIF
 IF (NOT (validate (get_slot_group_exp_reply ,0 ) ) )
  RECORD get_slot_group_exp_reply (
    1 qual_cnt = i4
    1 qual [* ]
      2 slot_group_id = f8
      2 qual_cnt = i4
      2 qual [* ]
        3 slot_type_id = f8
  )
 ENDIF
 DECLARE loadcodevalue ((code_set = i4 ) ,(cdf_meaning = vc ) ,(option_flag = i2 ) ) = f8
 DECLARE s_cdf_meaning = c12 WITH public ,noconstant (fillstring (12 ," " ) )
 DECLARE s_code_value = f8 WITH public ,noconstant (0.0 )
 SUBROUTINE  loadcodevalue (code_set ,cdf_meaning ,option_flag )
  SET s_cdf_meaning = cdf_meaning
  SET s_code_value = 0.0
  SET stat = uar_get_meaning_by_codeset (code_set ,s_cdf_meaning ,1 ,s_code_value )
  IF ((((stat != 0 ) ) OR ((s_code_value <= 0 ) )) )
   SET s_code_value = 0.0
   CASE (option_flag )
    OF 0 :
     SET table_name = build ("ERROR-->loadcodevalue (" ,code_set ,"," ,'"' ,s_cdf_meaning ,'"' ,"," ,
      option_flag ,") not found, CURPROG [" ,curprog ,"]" )
     CALL echo (table_name )
     SET failed = uar_error
     GO TO exit_script
    OF 1 :
     CALL echo (build ("INFO-->loadcodevalue (" ,code_set ,"," ,'"' ,s_cdf_meaning ,'"' ,"," ,
       option_flag ,") not found, CURPROG [" ,curprog ,"]" ) )
   ENDCASE
  ELSE
   CALL echo (build ("SUCCESS-->loadcodevalue (" ,code_set ,"," ,'"' ,s_cdf_meaning ,'"' ,"," ,
     option_flag ,") CODE_VALUE [" ,s_code_value ,"]" ) )
  ENDIF
  RETURN (s_code_value )
 END ;Subroutine
 SET slot_comments_bit = 0
 SET appt_comments_bit = 1
 SET appt_warning_bit = 2
 SET appt_protocol_bit = 3
 SET appt_recurring_bit = 4
 SET appt_lock_bit = 5
 SET slot_lock_bit = 6
 SET appt_unconfirm_bit = 7
 SET slot_release_bit = 8
 SET appt_eem_valid_bit = 9
 SET appt_eem_invalid_bit = 10
 SET appt_eem_unknown_bit = 11
 SET appt_eem_error_bit = 12
 SET appt_eem_ambig_bit = 13
 SET appt_allergy_bit = 14
 SET appt_abn_notsigned_bit = 15
 SET appt_abn_checked_bit = 16
 SET appt_abn_printed_bit = 17
 SET appt_abn_signed_bit = 18
 SET appt_patseen_bit = 19
 SET appt_tofollow_bit = 20
 SET appt_moveup_bit = 21
 SET appt_movedown_bit = 22
 SET appt_donotmove_bit = 23
 SET appt_link_bit = 24
 SET slot_grpsession_bit = 25
 SET appt_grpsession_bit = 26
 SET appt_cab_bit = 27
 SET appt_ibs_bit = 28
 SET appt_capres_bit = 29
 SET appt_vitale_bit = 30
 SET slot_comments_mask = 1
 SET appt_comments_mask = 2
 SET appt_warning_mask = 4
 SET appt_protocol_mask = 8
 SET appt_recurring_mask = 16
 SET appt_lock_mask = 32
 SET slot_lock_mask = 64
 SET appt_unconfirm_mask = 128
 SET slot_release_mask = 256
 SET appt_eem_valid_mask = 512
 SET appt_eem_invalid_mask = 1024
 SET appt_eem_unknown_mask = 2048
 SET appt_eem_error_mask = 4096
 SET appt_eem_ambig_mask = 8192
 SET appt_allergy_mask = 16384
 SET appt_abn_notsigned_mask = 32768
 SET appt_abn_checked_mask = 65536
 SET appt_abn_reviewreq_mask = 98304
 SET appt_abn_signedrfssrv_mask = 163840
 SET appt_abn_printed_mask = 131072
 SET appt_abn_signed_mask = 262144
 SET appt_abn_signedslfpay_mask = 294912
 SET appt_patseen_mask = 524288
 SET appt_tofollow_mask = 1048576
 SET appt_moveup_mask = 2097152
 SET appt_movedown_mask = 4194304
 SET appt_donotmove_mask = 8388608
 SET appt_link_mask = 16777216
 SET slot_grpsession_mask = 33554432
 SET appt_grpsession_mask = 67108864
 SET appt_cab_mask = 134217728
 SET appt_ibs_mask = 268435456
 SET appt_capres_mask = 536870912
 SET appt_vitale_mask = 1073741824
 SET clear_appt_mask = bnot (2113928894 )
 SET clear_slot_mask = bnot (33554753 )
 SET clear_eem_mask = bnot (15872 )
 SET clear_abn_mask = bnot (491520 )
 DECLARE inc_attr ((s_attr_name = vc ) ,(s_attr_label = vc ) ,(s_attr_type = vc ) ) = i2
 DECLARE sync_attr ((s_null_index = i4 ) ) = i2
 RECORD reply (
   1 attr_qual_cnt = i4
   1 attr_qual [* ]
     2 attr_name = c31
     2 attr_label = c60
     2 attr_type = c8
     2 attr_def_seq = i4
     2 attr_alt_sort_column = vc
   1 query_qual_cnt = i4
   1 query_qual [* ]
     2 hide#scheventid = f8
     2 hide#scheduleid = f8
     2 hide#scheduleseq = i4
     2 hide#schapptid = f8
     2 hide#statemeaning = c12
     2 hide#encounterid = f8
     2 hide#personid = f8
     2 hide#bitmask = i4
     2 hide#schappttypecd = f8
     2 beg_dt_tm = dq8
     2 duration = i4
     2 state = vc
     2 appt_type = vc
     2 appt_reason = vc
     2 prime_res = vc
     2 location = vc
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 SET reply->attr_qual_cnt = 0
 CALL inc_attr ("hide#scheventid" ,"HIDE#SCHEVENTID" ,"f8" ,0 )
 CALL inc_attr ("hide#scheduleid" ,"HIDE#SCHEDULEID" ,"f8" ,0 )
 CALL inc_attr ("hide#scheduleseq" ,"HIDE#SCHEDULESEQ" ,"i4" ,0 )
 CALL inc_attr ("hide#schapptid" ,"HIDE#SCHAPPTID" ,"f8" ,0 )
 CALL inc_attr ("hide#statemeaning" ,"HIDE#STATEMEANING" ,"c12" ,0 )
 CALL inc_attr ("hide#encounterid" ,"HIDE#ENCOUNTERID" ,"f8" ,0 )
 CALL inc_attr ("hide#personid" ,"HIDE#PERSONID" ,"f8" ,0 )
 CALL inc_attr ("hide#bitmask" ,"HIDE#BITMASK" ,"i4" ,0 )
 CALL inc_attr ("hide#schappttypecd" ,"HIDE#SCHAPPTTYPECD" ,"f8" ,0 )
 CALL inc_attr ("beg_dt_tm" ,uar_i18ngetmessage (i18nhandle ,"Begin Date/Time" ,"Begin Date/Time" ) ,
  "dq8" ,0 )
 CALL inc_attr ("duration" ,uar_i18ngetmessage (i18nhandle ,"Duration" ,"Duration" ) ,"i4" ,0 )
 CALL inc_attr ("state" ,uar_i18ngetmessage (i18nhandle ,"State" ,"State" ) ,"vc" ,0 )
 CALL inc_attr ("appt_type" ,uar_i18ngetmessage (i18nhandle ,"Appointment Type" ,"Appointment Type"
   ) ,"vc" ,0 )
 CALL inc_attr ("appt_reason" ,uar_i18ngetmessage (i18nhandle ,"Appointment Reason" ,
   "Appointment Reason" ) ,"vc" ,0 )
 CALL inc_attr ("prime_res" ,uar_i18ngetmessage (i18nhandle ,"Primary Resource" ,"Primary Resource"
   ) ,"vc" ,0 )
 CALL inc_attr ("location" ,uar_i18ngetmessage (i18nhandle ,"Location" ,"Location" ) ,"vc" ,0 )
 CALL sync_attr (1 )
 DECLARE failed = i2 WITH protect ,noconstant (true )
 SET reply->query_qual_cnt = 0
 SET stat = alterlist (reply->query_qual ,reply->query_qual_cnt )
 FREE SET t_record
 RECORD t_record (
   1 person_id = f8
 )
 CALL echo ("Checking the input fields..." )
 FOR (i_input = 1 TO size (request->qual ,5 ) )
  IF ((request->qual[i_input ].oe_field_meaning_id = 0 ) )
   CASE (request->qual[i_input ].oe_field_meaning )
    OF "PERSON" :
     SET t_record->person_id = request->qual[i_input ].oe_field_value
   ENDCASE
  ENDIF
 ENDFOR
 

;start 001
 call echo ("Getting Encounter Org Security")
 set request_3054->person_id = reqinfo->updt_id
 set stat = alterlist(request_3054->Org_Type,1)
 set request_3054->Org_type[1].org_type_cd = value(uar_get_code_by("MEANING",278,"FACILITY"))
 set request_3054->auth_only_ind = 1 
 execute uzr_get_prsnl_org_reltn with replace("REQUEST",request_3054),replace("REPLY",reply_3054)
 call echorecord(reply_3054)
 
 select into "nl:"
	o.organization_id
	,o.org_name
from
	organization o
plan o
	where o.org_name in(
							"MHHS Behavioral Health",
							"PW Senior Behavioral Unit",
							"Peninsula Behavioral Health - Div of Parkwest Medical Center",
							"Peninsula Blount Clinic - Div of Parkwest Medical Center",
							"Peninsula Lighthouse - Div of Parkwest Medical Center",
							"Peninsula Loudon Clinic - Div of Parkwest Medical Center",
							"Peninsula Sevier Clinic - Div of Parkwest Medical Center"
						)
order by
	 o.org_name
	,o.organization_id
head report
	secure_locations->org_cnt = 0
head o.organization_id
	secure_locations->org_cnt = (secure_locations->org_cnt + 1)
	stat = alterlist(secure_locations->org_qual,secure_locations->org_cnt)
	secure_locations->org_qual[secure_locations->org_cnt].organization_id = o.organization_id
	secure_locations->org_qual[secure_locations->org_cnt].org_name = o.org_name
with nocounter

select into "nl:"
from
	code_value cv
plan cv
	where cv.code_set = 220
	and   cv.cdf_meaning = "AMBULATORY"
	and   cv.display in(
							 "PBB BCG"
							,"PBS SOG"
							,"PBL LCG"
							,"PBLH KCG"
							,"PBH OMG"
							;,"TOG DOWNTOWN" 
						)
	and	 cv.active_ind = 1
order by
	 cv.display
	,cv.code_value
head report
	secure_locations->sch_cnt = 0
	i = 0
head cv.code_value	
	secure_locations->sch_cnt = (secure_locations->sch_cnt + 1)
	stat = alterlist(secure_locations->sch_qual,secure_locations->sch_cnt)
	secure_locations->sch_qual[secure_locations->sch_cnt].sch_location = cv.display
	secure_locations->sch_qual[secure_locations->sch_cnt].sch_location_cd = cv.code_value
	for (i=1 to secure_locations->org_cnt)
	 if 	((cv.display = "PBB BCG") 
	 	and (secure_locations->org_qual[i].org_name = "Peninsula Blount Clinic - Div of Parkwest Medical Center"))
	 	secure_locations->sch_qual[secure_locations->sch_cnt].org_name = secure_locations->org_qual[i].org_name 
	 	secure_locations->sch_qual[secure_locations->sch_cnt].organization_id = secure_locations->org_qual[i].organization_id
	
	 elseif ((cv.display = "PBS SOG") 
	 	and (secure_locations->org_qual[i].org_name = "Peninsula Sevier Clinic - Div of Parkwest Medical Center"))
	 	secure_locations->sch_qual[secure_locations->sch_cnt].org_name = secure_locations->org_qual[i].org_name 
	 	secure_locations->sch_qual[secure_locations->sch_cnt].organization_id = secure_locations->org_qual[i].organization_id
	
	 elseif ((cv.display = "PBL LCG") 
	 	and (secure_locations->org_qual[i].org_name = "Peninsula Loudon Clinic - Div of Parkwest Medical Center"))
	 	secure_locations->sch_qual[secure_locations->sch_cnt].org_name = secure_locations->org_qual[i].org_name 
	 	secure_locations->sch_qual[secure_locations->sch_cnt].organization_id = secure_locations->org_qual[i].organization_id
	
	 elseif ((cv.display = "PBLH KCG") 
	 	and (secure_locations->org_qual[i].org_name = "Peninsula Lighthouse - Div of Parkwest Medical Center"))
	 	secure_locations->sch_qual[secure_locations->sch_cnt].org_name = secure_locations->org_qual[i].org_name 
	 	secure_locations->sch_qual[secure_locations->sch_cnt].organization_id = secure_locations->org_qual[i].organization_id
	
	 elseif ((cv.display = "PBH OMG") 
	 	and (secure_locations->org_qual[i].org_name = "Peninsula Behavioral Health - Div of Parkwest Medical Center"))
	 	secure_locations->sch_qual[secure_locations->sch_cnt].org_name = secure_locations->org_qual[i].org_name 
	 	secure_locations->sch_qual[secure_locations->sch_cnt].organization_id = secure_locations->org_qual[i].organization_id
	 ;FOR TESTING ONLY
	 ;elseif ((cv.display = "TOG DOWNTOWN") 
	 ;	and (secure_locations->org_qual[i].org_name = "Peninsula Behavioral Health - Div of Parkwest Medical Center"))
	 ;	secure_locations->sch_qual[secure_locations->sch_cnt].org_name = secure_locations->org_qual[i].org_name 
	 ;	secure_locations->sch_qual[secure_locations->sch_cnt].organization_id = secure_locations->org_qual[i].organization_id
	 endif
	
	endfor
with nocounter

declare i = i2 with noconstant(0)	;001
declare j = i2 with noconstant(0)	;001

;end 001
 
 SELECT
  beg_date = a.beg_dt_tm ,
  duration = a.duration ,
  appt_type = e.appt_synonym_free ,
  appt_reason = e.appt_reason_free ,
  resource = ed.disp_display ,
  location = ed1.disp_display ,
  hide#scheventid = a.sch_event_id ,
  hide#scheduleid = a.schedule_id ,
  hide#statemeaning = a.state_meaning ,
  hide#encounterid = a.encntr_id ,
  hide#personid = a.person_id ,
  hide#bitmask = a.bit_mask
  FROM (sch_event_patient ep ),
   (sch_appt a ),
   (sch_event e ),
   (sch_event_disp ed ),
   (sch_event_disp ed1 )
   ,(encounter e1) ;001
  PLAN (ep
   WHERE (ep.person_id = t_record->person_id )
   AND (ep.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" ) ) )
   JOIN (a
   WHERE (a.sch_event_id = ep.sch_event_id )
   AND (a.person_id = t_record->person_id )
   AND (a.beg_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
   AND (a.state_meaning != "RESCHEDULED" ) )
   JOIN (e
   WHERE (e.sch_event_id = ep.sch_event_id ) )
   JOIN (ed
   WHERE (ed.sch_event_id = outerjoin (a.sch_event_id ) )
   AND (ed.schedule_id = outerjoin (a.schedule_id ) )
   AND (ed.disp_field_id = outerjoin (5 ) ) )
   JOIN (ed1
   WHERE (ed1.sch_event_id = outerjoin (a.sch_event_id ) )
   AND (ed1.schedule_id = outerjoin (a.schedule_id ) )
   AND (ed1.disp_field_id = outerjoin (1 ) ) )
   ;start 001
   join (e1
   	where e1.encntr_id = outerjoin (a.encntr_id))
   ;end 001
  ORDER BY a.beg_dt_tm ,
   a.sch_event_id
  HEAD REPORT
   reply->query_qual_cnt = 0
   skip_ind = 0 ;001
   facility_pos = 0 ;001
   sch_location_pos = 0 ;001
   i = 0 ;001
  HEAD a.sch_event_id
   ;start 001
   facility_pos = 0
   sch_location_pos = 0
   skip_ind = 1
   call echo(build2("e1.encntr_id=",e1.encntr_id))
   if (e1.encntr_id > 0.0)
    facility_pos = locateval(i,1,size(reply_3054->qual,5),e1.organization_id,reply_3054->qual[i].organization_id)
   	call echo(build2("-->facility_pos=",facility_pos))
   	 if (facility_pos > 0)
   	  skip_ind = 0
   	 endif
   elseif (e1.encntr_id = 0.0)
   	sch_location_pos = locateval(i,1,secure_locations->sch_cnt,trim(ed1.disp_display),secure_locations->sch_qual[i].sch_location)
   	call echo(build2("-->sch_location_pos=",sch_location_pos))
   	if (sch_location_pos > 0) ;secure location
   	 facility_pos = 
   	 	locateval(j,1,size(reply_3054->qual,5),secure_locations->sch_qual[sch_location_pos].organization_id
   	 		,reply_3054->qual[j].organization_id)
   	 if (facility_pos > 0)
   	  skip_ind = 0
   	 endif
   	else ;not secure location
   	 skip_ind = 0
   	endif
   endif					
   ;end 001
   if (skip_ind = 0)	;001
    reply->query_qual_cnt = (reply->query_qual_cnt + 1 ) ,
    IF ((mod (reply->query_qual_cnt ,100 ) = 1 ) ) stat = alterlist (reply->query_qual ,(reply->
     query_qual_cnt + 99 ) )
   ENDIF
   ,reply->query_qual[reply->query_qual_cnt ].hide#scheventid = a.sch_event_id ,reply->query_qual[
   reply->query_qual_cnt ].hide#scheduleid = a.schedule_id ,reply->query_qual[reply->query_qual_cnt ]
   .hide#scheduleseq = a.schedule_seq ,reply->query_qual[reply->query_qual_cnt ].hide#schapptid = a
   .sch_appt_id ,reply->query_qual[reply->query_qual_cnt ].hide#statemeaning = a.state_meaning ,reply
   ->query_qual[reply->query_qual_cnt ].hide#encounterid = a.encntr_id ,reply->query_qual[reply->
   query_qual_cnt ].hide#personid = a.person_id ,reply->query_qual[reply->query_qual_cnt ].
   hide#bitmask = a.bit_mask ,reply->query_qual[reply->query_qual_cnt ].hide#schappttypecd = e
   .appt_type_cd ,reply->query_qual[reply->query_qual_cnt ].beg_dt_tm = cnvtdatetime (a.beg_dt_tm ) ,
   reply->query_qual[reply->query_qual_cnt ].duration = a.duration ,reply->query_qual[reply->
   query_qual_cnt ].appt_type = uar_get_code_display (e.appt_synonym_cd ) ,reply->query_qual[reply->
   query_qual_cnt ].state = uar_get_code_display (a.sch_state_cd ) ,reply->query_qual[reply->
   query_qual_cnt ].appt_type = e.appt_synonym_free ,reply->query_qual[reply->query_qual_cnt ].
   appt_reason = e.appt_reason_free ,reply->query_qual[reply->query_qual_cnt ].prime_res = ed
   .disp_display ,reply->query_qual[reply->query_qual_cnt ].location = ed1.disp_display
  endif				;001
  FOOT REPORT
   IF ((mod (reply->query_qual_cnt ,100 ) != 0 ) ) stat = alterlist (reply->query_qual ,reply->
     query_qual_cnt )
   ENDIF
  WITH nocounter
 ;end select
 SET failed = false
 GO TO exit_script
#subroutines
 SUBROUTINE  inc_attr (s_attr_name ,s_attr_label ,s_attr_type ,s_attr_def_seq )
  SET reply->attr_qual_cnt = (reply->attr_qual_cnt + 1 )
  IF ((mod (reply->attr_qual_cnt ,10 ) = 1 ) )
   SET stat = alterlist (reply->attr_qual ,(reply->attr_qual_cnt + 9 ) )
  ENDIF
  SET reply->attr_qual[reply->attr_qual_cnt ].attr_name = s_attr_name
  SET reply->attr_qual[reply->attr_qual_cnt ].attr_label = s_attr_label
  SET reply->attr_qual[reply->attr_qual_cnt ].attr_type = s_attr_type
  SET reply->attr_qual[reply->attr_qual_cnt ].attr_def_seq = s_attr_def_seq
 END ;Subroutine
 SUBROUTINE  sync_attr (null_index )
  IF ((mod (reply->attr_qual_cnt ,10 ) != 0 ) )
   SET stat = alterlist (reply->attr_qual ,reply->attr_qual_cnt )
  ENDIF
 END ;Subroutine
#exit_script
 IF ((failed = false ) )
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  IF ((failed != true ) )
   CASE (failed )
    OF select_error :
     SET reply->status_data.subeventstatus[1 ].operationname = "SELECT"
    ELSE
     SET reply->status_data.subeventstatus[1 ].operationname = "PRINTED"
   ENDCASE
   SET reply->status_data.subeventstatus[1 ].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = table_name
  ENDIF
 ENDIF
 IF (request->call_echo_ind )
  CALL echorecord (reply )
  CALL echorecord (t_record )
  call echorecord (secure_locations)
 ENDIF
 FREE SET t_record
END GO
