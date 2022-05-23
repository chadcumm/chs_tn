DROP PROGRAM cov_resolve_merged_pregnancies :dba GO
CREATE PROGRAM cov_resolve_merged_pregnancies :dba

 FREE RECORD probrequest
 RECORD probrequest (
   1 person_id = f8
   1 problem [* ]
     2 problem_action_ind = i2
     2 problem_id = f8
     2 problem_instance_id = f8
     2 nomenclature_id = f8
     2 annotated_display = vc
     2 organization_id = f8
     2 source_vocabulary_cd = f8
     2 source_identifier = vc
     2 problem_ftdesc = vc
     2 classification_cd = f8
     2 confirmation_status_cd = f8
     2 qualifier_cd = f8
     2 life_cycle_status_cd = f8
     2 life_cycle_dt_tm = dq8
     2 life_cycle_dt_flag = i2
     2 life_cycle_dt_cd = f8
     2 persistence_cd = f8
     2 certainty_cd = f8
     2 ranking_cd = f8
     2 probability = f8
     2 onset_dt_flag = i2
     2 onset_dt_cd = f8
     2 onset_dt_tm = dq8
     2 onset_tz = i4
     2 course_cd = f8
     2 severity_class_cd = f8
     2 severity_cd = f8
     2 severity_ftdesc = vc
     2 prognosis_cd = f8
     2 person_aware_cd = f8
     2 family_aware_cd = f8
     2 person_aware_prognosis_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 status_upt_precision_flag = i2
     2 status_upt_precision_cd = f8
     2 status_upt_dt_tm = dq8
     2 cancel_reason_cd = f8
     2 originating_nomenclature_id = f8
     2 problem_comment [* ]
       3 problem_comment_id = f8
       3 comment_action_ind = i2
       3 comment_dt_tm = dq8
       3 comment_tz = i4
       3 comment_prsnl_id = f8
       3 comment_prsnl_name = vc
       3 problem_comment = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 problem_discipline [* ]
       3 discipline_action_ind = i2
       3 problem_discipline_id = f8
       3 management_discipline_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 problem_prsnl [* ]
       3 prsnl_action_ind = i2
       3 problem_reltn_dt_tm = dq8
       3 problem_reltn_cd = f8
       3 problem_prsnl_id = f8
       3 problem_reltn_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 secondary_desc_list [* ]
       3 group_sequence = i4
       3 group [* ]
         4 secondary_desc_id = f8
         4 nomenclature_id = f8
         4 sequence = i4
     2 problem_uuid = vc
     2 problem_instance_uuid = vc
     2 contributor_system_cd = f8
     2 problem_type_flag = i2
     2 show_in_pm_history_ind = i2
   1 skip_fsi_trigger = i2
 )
 
 
 DECLARE getpregnancypreferences (null ) = null
 DECLARE findnomenclature (null ) = null
 DECLARE getmergedpregnancydetails (null ) = null
 DECLARE resolveactivepregnantproblems (null ) = null
 DECLARE resolvehistoricalpregnancyproblems (null ) = null
 DECLARE resolveclosedpregnancyproblems (null ) = null
 DECLARE resolveactivepregnancyproblems (null ) = null
 DECLARE resolvehistoricalpregnancyproblemsaction ((patient_indx = i4 ) ) = null
 DECLARE resolveclosedpregnancyproblemsaction ((patient_indx = i4 ) ) = null
 DECLARE validatepregnancyproblems (null ) = null
 DECLARE getmergedproblempatientscount (null ) = null
 DECLARE snomensourceid = vc WITH protect ,noconstant ("" )
 DECLARE nomen_id = f8 WITH protect ,noconstant (0.0 )
 DECLARE snomenvocabmean = vc WITH protect ,noconstant ("" )
 DECLARE failed = i2 WITH public ,noconstant (0 )
 DECLARE canceled_action_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,12030 ,"CANCELED" ) )
 DECLARE resolved_action_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,12030 ,"RESOLVED" ) )
 DECLARE active_action_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,12030 ,"ACTIVE" ))
 DECLARE pregnancy_flag = i4 WITH protect ,constant (2 )
 DECLARE master_pregnancy_id = f8 WITH protect ,noconstant (0.0 )
 DECLARE new_preg_inst_id = f8 WITH protect ,noconstant (0.0 )
 DECLARE master_preg_inst_id = f8 WITH protect ,noconstant (0.0 )
 DECLARE leastgestage = i4 WITH protect ,noconstant (0 )
 DECLARE cnt = i4 WITH protect ,noconstant (0 )
 DECLARE earlydeldttm = dq8 WITH protect ,noconstant (cnvtdatetime ("31-DEC-2100" ) )
 DECLARE patientscnt = i4 WITH protect ,noconstant (0 )
 DECLARE onsetdttm = dq8 WITH protect ,noconstant (cnvtdatetime ("31-DEC-2100" ) )
 DECLARE pregnancycnt = i4 WITH protect ,noconstant (0 )
 DECLARE patient_index = i4 WITH protect ,noconstant (0 )
 DECLARE preg_index = i4 WITH protect ,noconstant (0 )
 DECLARE newproblemid = f8 WITH protect ,noconstant (0.0 )

 FREE RECORD patients
 RECORD patients (
   1 qual [* ]
     2 patient_id = f8
     2 pregnancies [* ]
       3 pregnancy_id = f8
       3 pregnancy_instance_id = f8
       3 problem_id = f8
       3 historical_ind = i2
       3 pregnancy_end_dt_tm = dq8
 )

 FREE RECORD problemsdetails
 RECORD problemsdetails (
   1 qual [* ]
     2 patient_id = f8
     2 problem [* ]
       3 problem_id = f8
       3 problem_instance_id = f8
       3 nomenclature_id = f8
       3 annotated_display = vc
       3 organization_id = f8
       3 originating_nomenclature_id = f8
       3 onset_dt_tm = dq8
       3 onset_tz = i4
       3 classification_cd = f8
       3 confirmation_status_cd = f8
 )

 CALL getpregnancypreferences (null )

 CALL findnomenclature (null )

 CALL validatepregnancyproblems (null )

 CALL getmergedproblempatientscount (null )

 CALL resolveactivepregnantproblems (null )

 CALL getmergedpregnancydetails (null )

 CALL resolveactivepregnancyproblems (null )

 CALL resolveclosedpregnancyproblems (null )

 CALL resolvehistoricalpregnancyproblems (null )


 SUBROUTINE  validatepregnancyproblems (null )
  SELECT INTO "nl:"
   FROM (problem p )
   WHERE (p.nomenclature_id = nomen_id )
   WITH nocounter
  ;end select
  IF ((curqual = 0 ) )
   IF ((validate (debug_ind ,0 ) > 0 ) )
    CALL echo (
     "Domain doesn't have pregnant problem same as what is added from pregnancy component." )
   ENDIF
   GO TO exit_script
  ELSE
   IF ((validate (debug_ind ,0 ) > 0 ) )
    CALL echo ("Domain has pregnant problems same as what is added from pregnancy component." )
   ENDIF
  ENDIF
 END ;Subroutine






 SUBROUTINE  getmergedproblempatientscount (null )
  SELECT DISTINCT INTO "nl:"
   pi.person_id
   FROM (pregnancy_instance pi ),
    (person p )
   PLAN (pi
    WHERE (pi.active_ind = 1 )
    AND (pi.problem_id IN (
    (SELECT
     pi2.problem_id
     FROM (pregnancy_instance pi2 )
     WHERE (pi2.active_ind = 1 )
     AND (pi2.person_id = pi.person_id )
     AND (pi2.pregnancy_id != pi.pregnancy_id )
     AND (pi2.pregnancy_instance_id != pi.pregnancy_instance_id ) ) ) ) )
    JOIN (p
    WHERE (p.person_id = pi.person_id )
    AND (p.logical_domain_id IN (
    (SELECT
     logical_domain_id
     FROM (prsnl )
     WHERE (person_id = reqinfo->updt_id ) ) ) ) )
   HEAD pi.person_id
    cnt = (cnt + 1 ) ,
    IF ((mod (cnt ,10 ) = 1 ) ) istat = alterlist (patients->qual ,(cnt + 9 ) )
    ENDIF
    ,patients->qual[cnt ].patient_id = pi.person_id
   WITH nocounter
  ;end select
  SET istat = alterlist (patients->qual ,cnt )
  IF ((validate (debug_ind ,0 ) > 0 ) )
   CALL echorecord (patients )
  ENDIF
 END ;Subroutine







 SUBROUTINE  getpregnancypreferences (null )
  FREE RECORD prefs
  RECORD prefs (
    1 qual [* ]
      2 pref_entry_name = vc
  )
  DECLARE stat = i2 WITH protect ,noconstant (0 )
  DECLARE llocateindex = i4 WITH protect ,noconstant (0 )
  DECLARE ltermindex = i4 WITH protect ,noconstant (0 )
  DECLARE hpref = i4 WITH private ,noconstant (0 )
  DECLARE hgroup = i4 WITH private ,noconstant (0 )
  DECLARE hrepgroup = i4 WITH private ,noconstant (0 )
  DECLARE hsection = i4 WITH private ,noconstant (0 )
  DECLARE hattr = i4 WITH private ,noconstant (0 )
  DECLARE hentry = i4 WITH private ,noconstant (0 )
  DECLARE lentrycnt = i4 WITH private ,noconstant (0 )
  DECLARE lentryidx = i4 WITH private ,noconstant (0 )
  DECLARE larraysize = i4 WITH private ,noconstant (0 )
  DECLARE ilen = i4 WITH private ,noconstant (255 )
  DECLARE lattrcnt = i4 WITH private ,noconstant (0 )
  DECLARE lattridx = i4 WITH private ,noconstant (0 )
  DECLARE lvalcnt = i4 WITH private ,noconstant (0 )
  DECLARE sentryname = c255 WITH private ,noconstant ("" )
  DECLARE sattrname = c255 WITH private ,noconstant ("" )
  DECLARE sval = c255 WITH private ,noconstant ("" )
  SET stat = alterlist (prefs->qual ,2 )
  SET prefs->qual[1 ].pref_entry_name = "vocabmeaning"
  SET prefs->qual[2 ].pref_entry_name = "sourceid"
  SET larraysize = size (prefs->qual ,5 )
  EXECUTE prefrtl
  SET hpref = uar_prefcreateinstance (0 )
  SET stat = uar_prefaddcontext (hpref ,nullterm ("default" ) ,nullterm ("system" ) )
  SET stat = uar_prefsetsection (hpref ,nullterm ("component" ) )
  SET hgroup = uar_prefcreategroup ()
  SET stat = uar_prefsetgroupname (hgroup ,nullterm ("Pregnancy" ) )
  SET stat = uar_prefaddgroup (hpref ,hgroup )
  SET stat = uar_prefperform (hpref )
  SET hsection = uar_prefgetsectionbyname (hpref ,nullterm ("component" ) )
  SET hrepgroup = uar_prefgetgroupbyname (hsection ,nullterm ("Pregnancy" ) )
  SET stat = uar_prefgetgroupentrycount (hrepgroup ,lentrycnt )
  FOR (lentryidx = 0 TO (lentrycnt - 1 ) )
   SET hentry = uar_prefgetgroupentry (hrepgroup ,lentryidx )
   SET ilen = 255
   SET sentryname = ""
   SET stat = uar_prefgetentryname (hentry ,sentryname ,ilen )
   SET ltermindex = locateval (llocateindex ,1 ,larraysize ,trim (sentryname ) ,prefs->qual[
    llocateindex ].pref_entry_name )
   IF ((ltermindex > 0 ) )
    SET lattrcnt = 0
    SET stat = uar_prefgetentryattrcount (hentry ,lattrcnt )
    FOR (lattridx = 0 TO (lattrcnt - 1 ) )
     SET hattr = uar_prefgetentryattr (hentry ,lattridx )
     SET ilen = 255
     SET sattrname = ""
     SET stat = uar_prefgetattrname (hattr ,sattrname ,ilen )
     IF ((sattrname = "prefvalue" ) )
      SET lvalcnt = 0
      SET stat = uar_prefgetattrvalcount (hattr ,lvalcnt )
      IF ((lvalcnt > 0 ) )
       SET sval = ""
       SET ilen = 255
       SET stat = uar_prefgetattrval (hattr ,sval ,ilen ,0 )
       CASE (ltermindex )
        OF 1 :
         SET snomenvocabmean = trim (sval )
        OF 2 :
         SET snomensourceid = trim (sval )
       ENDCASE
      ENDIF
      SET lattridx = lattrcnt
     ENDIF
    ENDFOR
   ENDIF
  ENDFOR
  IF ((((snomenvocabmean = "" ) ) OR ((snomensourceid = "" ) )) )
   IF ((validate (debug_ind ,0 ) > 0 ) )
    CALL echo (
     "VocabMeaning or NomenSourceId preference values are not configured correctly in preferencemanager"
     )
   ENDIF
   GO TO exit_script
  ENDIF
  IF ((validate (debug_ind ,0 ) > 0 ) )
   CALL echorecord (prefs )
  ENDIF
  CALL uar_prefdestroysection (hsection )
  CALL uar_prefdestroygroup (hgroup )
  CALL uar_prefdestroyinstance (hpref )
  FREE RECORD prefs
 END ;Subroutine
 
 
 
 
 
 SUBROUTINE  findnomenclature (null )
  DECLARE nomen_vocab_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,400 ,nullterm (
     snomenvocabmean ) ) )
  SELECT INTO "nl:"
   FROM (nomenclature nm )
   WHERE (nm.source_identifier = snomensourceid )
   AND (nm.source_vocabulary_cd = nomen_vocab_cd )
   AND (nm.primary_cterm_ind = 1 )
   AND (nm.active_ind = true )
   DETAIL
    nomen_id = nm.nomenclature_id
   WITH nocounter
  ;end select
  IF ((nomen_id <= 0 ) )
   SET failed = true
   CALL echo ("*failed - nomenclature couldn't be found*" )
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE  getmergedpregnancydetails (null )
  SET patient_index = 0
  SET patientscnt = size (patients->qual ,5 )
  FOR (patient_index = 1 TO patientscnt )
   SET preg_index = 0
   SELECT INTO "nl:"
    FROM (pregnancy_instance pi ),
     (person p )
    PLAN (pi
     WHERE (pi.person_id = patients->qual[patient_index ].patient_id )
     AND (pi.active_ind = 1 )
     AND (pi.problem_id IN (
     (SELECT
      pi2.problem_id
      FROM (pregnancy_instance pi2 )
      WHERE (pi2.active_ind = 1 )
      AND (pi2.person_id = pi.person_id )
      AND (pi2.pregnancy_id != pi.pregnancy_id )
      AND (pi2.pregnancy_instance_id != pi.pregnancy_instance_id ) ) ) ) )
     JOIN (p
     WHERE (p.person_id = pi.person_id )
     AND (p.logical_domain_id IN (
     (SELECT
      logical_domain_id
      FROM (prsnl )
      WHERE (person_id = reqinfo->updt_id ) ) ) ) )
    ORDER BY pi.pregnancy_instance_id DESC
    HEAD pi.pregnancy_id
     preg_index = (preg_index + 1 ) ,
     IF ((mod (preg_index ,10 ) = 1 ) ) istat = alterlist (patients->qual[patient_index ].pregnancies
        ,(preg_index + 9 ) )
     ENDIF
     ,patients->qual[patient_index ].pregnancies[preg_index ].pregnancy_id = pi.pregnancy_id ,
     patients->qual[patient_index ].pregnancies[preg_index ].problem_id = pi.problem_id ,patients->
     qual[patient_index ].pregnancies[preg_index ].historical_ind = pi.historical_ind ,patients->
     qual[patient_index ].pregnancies[preg_index ].pregnancy_instance_id = pi.pregnancy_instance_id ,
     patients->qual[patient_index ].pregnancies[preg_index ].pregnancy_end_dt_tm = pi.preg_end_dt_tm
    FOOT REPORT
     istat = alterlist (patients->qual[patient_index ].pregnancies ,preg_index )
   ;end select
  ENDFOR
 END ;Subroutine
 
 
 
 
 
 SUBROUTINE  resolveactivepregnantproblems (null )
  DECLARE qual_index = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (problem pb )
   WHERE (pb.nomenclature_id = nomen_id )
   AND (pb.active_ind = 1 )
   AND (pb.end_effective_dt_tm >= cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
   AND (pb.life_cycle_status_cd = active_action_cd )
   AND (pb.problem_type_flag != pregnancy_flag )
   AND (pb.person_id IN (
   (SELECT
    pi2.person_id
    FROM (pregnancy_instance pi2 )
    WHERE (pi2.person_id = pb.person_id ) ) ) )
   AND NOT ((pb.problem_id IN (
   (SELECT
    pi2.problem_id
    FROM (pregnancy_instance pi2 )
    WHERE (pi2.person_id = pb.person_id )
    AND (pi2.problem_id = pb.problem_id ) ) ) ) )
   HEAD pb.person_id
    qual_index = (qual_index + 1 ) ,
    IF ((mod (qual_index ,10 ) = 1 ) ) istat = alterlist (problemsdetails->qual ,(qual_index + 9 ) )
    ENDIF
    ,problemsdetails->qual[qual_index ].patient_id = pb.person_id ,istat = alterlist (problemsdetails
     ->qual[qual_index ].problem ,1 ) ,problemsdetails->qual[qual_index ].problem[1 ].
    problem_instance_id = pb.problem_instance_id ,problemsdetails->qual[qual_index ].problem[1 ].
    problem_id = pb.problem_id ,problemsdetails->qual[qual_index ].problem[1 ].nomenclature_id = pb
    .nomenclature_id ,problemsdetails->qual[qual_index ].problem[1 ].annotated_display = pb
    .annotated_display ,problemsdetails->qual[qual_index ].problem[1 ].classification_cd = pb
    .classification_cd ,problemsdetails->qual[qual_index ].problem[1 ].onset_dt_tm = pb.onset_dt_tm ,
    problemsdetails->qual[qual_index ].problem[1 ].onset_tz = pb.onset_tz ,problemsdetails->qual[
    qual_index ].problem[1 ].organization_id = pb.organization_id ,problemsdetails->qual[qual_index ]
    .problem[1 ].originating_nomenclature_id = pb.originating_nomenclature_id ,problemsdetails->qual[
    qual_index ].problem[1 ].confirmation_status_cd = pb.confirmation_status_cd
   FOOT REPORT
    istat = alterlist (problemsdetails->qual ,qual_index )
   WITH nocounter
  ;end select
  DECLARE patientcnt = i4 WITH protect ,noconstant (size (problemsdetails->qual ,5 ) )
  FOR (idx = 1 TO patientcnt )
   FREE RECORD probrequest
   RECORD probrequest (
     1 person_id = f8
     1 problem [* ]
       2 problem_action_ind = i2
       2 problem_id = f8
       2 problem_instance_id = f8
       2 nomenclature_id = f8
       2 annotated_display = vc
       2 organization_id = f8
       2 source_vocabulary_cd = f8
       2 source_identifier = vc
       2 problem_ftdesc = vc
       2 classification_cd = f8
       2 confirmation_status_cd = f8
       2 qualifier_cd = f8
       2 life_cycle_status_cd = f8
       2 life_cycle_dt_tm = dq8
       2 life_cycle_dt_flag = i2
       2 life_cycle_dt_cd = f8
       2 persistence_cd = f8
       2 certainty_cd = f8
       2 ranking_cd = f8
       2 probability = f8
       2 onset_dt_flag = i2
       2 onset_dt_cd = f8
       2 onset_dt_tm = dq8
       2 onset_tz = i4
       2 course_cd = f8
       2 severity_class_cd = f8
       2 severity_cd = f8
       2 severity_ftdesc = vc
       2 prognosis_cd = f8
       2 person_aware_cd = f8
       2 family_aware_cd = f8
       2 person_aware_prognosis_cd = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 status_upt_precision_flag = i2
       2 status_upt_precision_cd = f8
       2 status_upt_dt_tm = dq8
       2 cancel_reason_cd = f8
       2 originating_nomenclature_id = f8
       2 problem_comment [* ]
         3 problem_comment_id = f8
         3 comment_action_ind = i2
         3 comment_dt_tm = dq8
         3 comment_tz = i4
         3 comment_prsnl_id = f8
         3 comment_prsnl_name = vc
         3 problem_comment = vc
         3 beg_effective_dt_tm = dq8
         3 end_effective_dt_tm = dq8
       2 problem_discipline [* ]
         3 discipline_action_ind = i2
         3 problem_discipline_id = f8
         3 management_discipline_cd = f8
         3 beg_effective_dt_tm = dq8
         3 end_effective_dt_tm = dq8
       2 problem_prsnl [* ]
         3 prsnl_action_ind = i2
         3 problem_reltn_dt_tm = dq8
         3 problem_reltn_cd = f8
         3 problem_prsnl_id = f8
         3 problem_reltn_prsnl_id = f8
         3 beg_effective_dt_tm = dq8
         3 end_effective_dt_tm = dq8
       2 secondary_desc_list [* ]
         3 group_sequence = i4
         3 group [* ]
           4 secondary_desc_id = f8
           4 nomenclature_id = f8
           4 sequence = i4
       2 problem_uuid = vc
       2 problem_instance_uuid = vc
       2 contributor_system_cd = f8
       2 problem_type_flag = i2
       2 show_in_pm_history_ind = i2
     1 skip_fsi_trigger = i2
   )
   SET probrequest->person_id = problemsdetails->qual[idx ].patient_id
   SET istat = alterlist (probrequest->problem ,1 )
   SET probrequest->problem[1 ].problem_id = problemsdetails->qual[idx ].problem[1 ].problem_id
   SET probrequest->problem[1 ].problem_instance_id = problemsdetails->qual[idx ].problem[1 ].problem_instance_id
   SET probrequest->problem[1 ].nomenclature_id = problemsdetails->qual[idx ].problem[1 ].nomenclature_id
   SET probrequest->problem[1 ].annotated_display = problemsdetails->qual[idx ].problem[1 ].annotated_display
   SET probrequest->problem[1 ].classification_cd = problemsdetails->qual[idx ].problem[1 ].classification_cd
   SET probrequest->problem[1 ].onset_dt_tm = problemsdetails->qual[idx ].problem[1 ].onset_dt_tm
   SET probrequest->problem[1 ].onset_tz = problemsdetails->qual[idx ].problem[1 ].onset_tz
   SET probrequest->problem[1 ].organization_id = problemsdetails->qual[idx ].problem[1 ].organization_id
   SET probrequest->problem[1 ].originating_nomenclature_id = problemsdetails->qual[idx ].problem[1 ].originating_nomenclature_id
   SET probrequest->problem[1 ].confirmation_status_cd = problemsdetails->qual[idx ].problem[1 ].confirmation_status_cd
   SET probrequest->problem[1 ].life_cycle_status_cd = resolved_action_cd
   SET probrequest->problem[1 ].problem_action_ind = 2
   SET probrequest->skip_fsi_trigger = 1
   ;EXECUTE kia_ens_problem WITH replace ("REQUEST" ,probrequest ) ,replace ("REPLY" ,probreply )
   IF ((probreply->status_data.status = "F" ) )
    IF ((validate (debug_ind ,0 ) > 0 ) )
     CALL echo ("*Failed - problem ensure*" )
    ENDIF
   ELSE
    IF ((validate (debug_ind ,0 ) > 0 ) )
     CALL echo ("Pregnancy Problem Ensured" )
    ENDIF
   ENDIF
  ENDFOR
 END ;Subroutine
 
 
 
 SUBROUTINE  resolveclosedpregnancyproblems (null )
  SET patientscnt = size (patients->qual ,5 )
  SET patient_index = 0
  FOR (patient_index = 1 TO patientscnt )
   CALL resolveclosedpregnancyproblemsaction (patient_index )
  ENDFOR
 END ;Subroutine
 
 
 
 SUBROUTINE  resolveclosedpregnancyproblemsaction (patient_index )
  SET leastgestage = 0
  SET cnt = 0
  SET earlydeldttm = cnvtdatetime ("31-DEC-2100" )
  SET onsetdttm = cnvtdatetime ("31-DEC-2100" )
  SET preg_index = 0
  SET pregnancycnt = size (patients->qual[patient_index ].pregnancies ,5 )
  FOR (preg_index = 1 TO pregnancycnt )
   FREE RECORD probrequest
   RECORD probrequest (
     1 person_id = f8
     1 problem [* ]
       2 problem_action_ind = i2
       2 problem_id = f8
       2 problem_instance_id = f8
       2 nomenclature_id = f8
       2 annotated_display = vc
       2 organization_id = f8
       2 source_vocabulary_cd = f8
       2 source_identifier = vc
       2 problem_ftdesc = vc
       2 classification_cd = f8
       2 confirmation_status_cd = f8
       2 qualifier_cd = f8
       2 life_cycle_status_cd = f8
       2 life_cycle_dt_tm = dq8
       2 life_cycle_dt_flag = i2
       2 life_cycle_dt_cd = f8
       2 persistence_cd = f8
       2 certainty_cd = f8
       2 ranking_cd = f8
       2 probability = f8
       2 onset_dt_flag = i2
       2 onset_dt_cd = f8
       2 onset_dt_tm = dq8
       2 onset_tz = i4
       2 course_cd = f8
       2 severity_class_cd = f8
       2 severity_cd = f8
       2 severity_ftdesc = vc
       2 prognosis_cd = f8
       2 person_aware_cd = f8
       2 family_aware_cd = f8
       2 person_aware_prognosis_cd = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 status_upt_precision_flag = i2
       2 status_upt_precision_cd = f8
       2 status_upt_dt_tm = dq8
       2 cancel_reason_cd = f8
       2 originating_nomenclature_id = f8
       2 problem_comment [* ]
         3 problem_comment_id = f8
         3 comment_action_ind = i2
         3 comment_dt_tm = dq8
         3 comment_tz = i4
         3 comment_prsnl_id = f8
         3 comment_prsnl_name = vc
         3 problem_comment = vc
         3 beg_effective_dt_tm = dq8
         3 end_effective_dt_tm = dq8
       2 problem_discipline [* ]
         3 discipline_action_ind = i2
         3 problem_discipline_id = f8
         3 management_discipline_cd = f8
         3 beg_effective_dt_tm = dq8
         3 end_effective_dt_tm = dq8
       2 problem_prsnl [* ]
         3 prsnl_action_ind = i2
         3 problem_reltn_dt_tm = dq8
         3 problem_reltn_cd = f8
         3 problem_prsnl_id = f8
         3 problem_reltn_prsnl_id = f8
         3 beg_effective_dt_tm = dq8
         3 end_effective_dt_tm = dq8
       2 secondary_desc_list [* ]
         3 group_sequence = i4
         3 group [* ]
           4 secondary_desc_id = f8
           4 nomenclature_id = f8
           4 sequence = i4
       2 problem_uuid = vc
       2 problem_instance_uuid = vc
       2 contributor_system_cd = f8
       2 problem_type_flag = i2
       2 show_in_pm_history_ind = i2
     1 skip_fsi_trigger = i2
   )
   SET master_pregnancy_id = 0.0
   IF ((patients->qual[patient_index ].pregnancies[preg_index ].historical_ind = 0 )
   AND (patients->qual[patient_index ].pregnancies[preg_index ].pregnancy_end_dt_tm != cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )
    SELECT INTO "nl:"
     FROM (pregnancy_instance pi ),
      (pregnancy_child pc )
     PLAN (pi
      WHERE (pi.pregnancy_id = patients->qual[patient_index ].pregnancies[preg_index ].pregnancy_id
      )
      AND (pi.pregnancy_instance_id = patients->qual[patient_index ].pregnancies[preg_index ].
      pregnancy_instance_id ) )
      JOIN (pc
      WHERE (pc.pregnancy_id = pi.pregnancy_id )
      AND (pc.pregnancy_instance_id = pi.pregnancy_instance_id ) )
     HEAD pc.pregnancy_child_id
      cnt = (cnt + 1 ) ,
      IF ((cnt = 1 ) ) leastgestage = pc.gestation_age ,earlydeldttm = pc.delivery_dt_tm
      ELSE
       IF ((pc.delivery_dt_tm < cnvtdatetime (cnvtdate (earlydeldttm ) ,0 ) ) ) earlydeldttm = pc
        .delivery_dt_tm
       ENDIF
       ,
       IF ((pc.gestation_age < leastgestage ) ) leastgestage = pc.gestation_age
       ENDIF
      ENDIF
      ,
      IF ((earlydeldttm != 0.0 )
      AND (leastgestage != 0 ) ) onsetdttm = cnvtdatetime (pi.preg_start_dt_tm )
      ELSE onsetdttm = null
      ENDIF
      ,master_pregnancy_id = pi.pregnancy_id ,master_preg_inst_id = pi.pregnancy_instance_id
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (problem p )
     WHERE (p.person_id = patients->qual[patient_index ].patient_id )
     AND (p.problem_id = patients->qual[patient_index ].pregnancies[preg_index ].problem_id )
     AND (p.active_ind = 1 )
     HEAD p.problem_id
      probrequest->person_id = patients->qual[patient_index ].patient_id ,istat = alterlist (
       probrequest->problem ,2 ) ,probrequest->problem[1 ].problem_id = p.problem_id ,probrequest->
      problem[1 ].problem_instance_id = p.problem_instance_id ,probrequest->problem[1 ].
      nomenclature_id = p.nomenclature_id ,probrequest->problem[1 ].annotated_display = p
      .annotated_display ,probrequest->problem[1 ].classification_cd = p.classification_cd ,
      probrequest->problem[1 ].onset_dt_tm = onsetdttm ,probrequest->problem[1 ].onset_tz = p
      .onset_tz ,probrequest->problem[1 ].organization_id = p.organization_id ,probrequest->problem[
      1 ].originating_nomenclature_id = p.originating_nomenclature_id ,probrequest->problem[1 ].
      confirmation_status_cd = p.confirmation_status_cd ,probrequest->problem[1 ].
      life_cycle_status_cd = canceled_action_cd ,probrequest->problem[1 ].problem_action_ind = 2 ,
      probrequest->skip_fsi_trigger = 1
     WITH nocounter
    ;end select
    IF ((curqual = 1 ) )
     SET probrequest->problem[2 ].nomenclature_id = probrequest->problem[1 ].nomenclature_id
     SET probrequest->problem[2 ].annotated_display = probrequest->problem[1 ].annotated_display
     SET probrequest->problem[2 ].classification_cd = probrequest->problem[1 ].classification_cd
     SET probrequest->problem[2 ].onset_dt_tm = onsetdttm
     SET probrequest->problem[2 ].onset_tz = probrequest->problem[1 ].onset_tz
     SET probrequest->problem[2 ].organization_id = probrequest->problem[1 ].organization_id
     SET probrequest->problem[2 ].originating_nomenclature_id = probrequest->problem[1 ].
     originating_nomenclature_id
     SET probrequest->problem[2 ].confirmation_status_cd = probrequest->problem[1 ].
     confirmation_status_cd
     SET probrequest->problem[2 ].life_cycle_status_cd = resolved_action_cd
     SET probrequest->problem[2 ].problem_action_ind = 4
     SET istat = alterlist (probrequest->problem[2 ].problem_comment ,1 )
     SET probrequest->problem[2 ].problem_comment[1 ].problem_comment =
     "New problem added to resolve merged 					pregnancy issue."
     SET probrequest->problem[2 ].problem_comment[1 ].beg_effective_dt_tm = cnvtdatetime (curdate ,
      curtime3 )
     SET probrequest->problem[2 ].problem_comment[1 ].comment_action_ind = 4
     IF ((validate (debug_ind ,0 ) > 0 ) )
      CALL echo ("ResolveClosedPregnancyProblemsAction_probrequest" )
      CALL echorecord (probrequest )
     ENDIF
    ; EXECUTE kia_ens_problem WITH replace ("REQUEST" ,probrequest ) , replace ("REPLY" ,probreply )
     IF ((validate (debug_ind ,0 ) > 0 ) )
      CALL echo ("ResolveClosedPregnancyProblemsAction_probreply" )
      CALL echorecord (probreply )
     ENDIF
     IF ((probreply->status_data.status = "F" ) )
      CALL echo ("*Failed - problem ensure*" )
      SET failed = true
      GO TO exit_script
     ELSE
      SET newproblemid = 0
      SET newproblemid = probreply->problem_list[2 ].problem_id
      IF ((validate (debug_ind ,0 ) > 0 ) )
       CALL echo ("Pregnancy Problem Ensured" )
      ENDIF
     ENDIF
     
     /*
     UPDATE FROM (pregnancy_instance pi )
      SET pi.problem_id = newproblemid ,
       pi.updt_id = reqinfo->updt_id ,
       pi.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
       pi.updt_applctx = reqinfo->updt_applctx ,
       pi.updt_cnt = (pi.updt_cnt + 1 ) ,
       pi.updt_task = reqinfo->updt_task
      WHERE (pi.pregnancy_id = master_pregnancy_id )
      AND (pi.pregnancy_instance_id = master_preg_inst_id )
      WITH nocounter
     ;end update
     */
    ENDIF
   ENDIF
  ENDFOR
 END ;Subroutine
 
 
 
 SUBROUTINE  resolveactivepregnancyproblems (null )
  SET patientscnt = size (patients->qual ,5 )
  SET newproblemid = 0.0
  SET patient_index = 0
  SET preg_index = 0
  FOR (patient_index = 1 TO patientscnt )
   SET pregnancycnt = size (patients->qual[patient_index ].pregnancies ,5 )
   FOR (preg_index = 1 TO pregnancycnt )
    FREE RECORD probrequest
    RECORD probrequest (
      1 person_id = f8
      1 problem [* ]
        2 problem_action_ind = i2
        2 problem_id = f8
        2 problem_instance_id = f8
        2 nomenclature_id = f8
        2 annotated_display = vc
        2 organization_id = f8
        2 source_vocabulary_cd = f8
        2 source_identifier = vc
        2 problem_ftdesc = vc
        2 classification_cd = f8
        2 confirmation_status_cd = f8
        2 qualifier_cd = f8
        2 life_cycle_status_cd = f8
        2 life_cycle_dt_tm = dq8
        2 life_cycle_dt_flag = i2
        2 life_cycle_dt_cd = f8
        2 persistence_cd = f8
        2 certainty_cd = f8
        2 ranking_cd = f8
        2 probability = f8
        2 onset_dt_flag = i2
        2 onset_dt_cd = f8
        2 onset_dt_tm = dq8
        2 onset_tz = i4
        2 course_cd = f8
        2 severity_class_cd = f8
        2 severity_cd = f8
        2 severity_ftdesc = vc
        2 prognosis_cd = f8
        2 person_aware_cd = f8
        2 family_aware_cd = f8
        2 person_aware_prognosis_cd = f8
        2 beg_effective_dt_tm = dq8
        2 end_effective_dt_tm = dq8
        2 status_upt_precision_flag = i2
        2 status_upt_precision_cd = f8
        2 status_upt_dt_tm = dq8
        2 cancel_reason_cd = f8
        2 originating_nomenclature_id = f8
        2 problem_comment [* ]
          3 problem_comment_id = f8
          3 comment_action_ind = i2
          3 comment_dt_tm = dq8
          3 comment_tz = i4
          3 comment_prsnl_id = f8
          3 comment_prsnl_name = vc
          3 problem_comment = vc
          3 beg_effective_dt_tm = dq8
          3 end_effective_dt_tm = dq8
        2 problem_discipline [* ]
          3 discipline_action_ind = i2
          3 problem_discipline_id = f8
          3 management_discipline_cd = f8
          3 beg_effective_dt_tm = dq8
          3 end_effective_dt_tm = dq8
        2 problem_prsnl [* ]
          3 prsnl_action_ind = i2
          3 problem_reltn_dt_tm = dq8
          3 problem_reltn_cd = f8
          3 problem_prsnl_id = f8
          3 problem_reltn_prsnl_id = f8
          3 beg_effective_dt_tm = dq8
          3 end_effective_dt_tm = dq8
        2 secondary_desc_list [* ]
          3 group_sequence = i4
          3 group [* ]
            4 secondary_desc_id = f8
            4 nomenclature_id = f8
            4 sequence = i4
        2 problem_uuid = vc
        2 problem_instance_uuid = vc
        2 contributor_system_cd = f8
        2 problem_type_flag = i2
        2 show_in_pm_history_ind = i2
      1 skip_fsi_trigger = i2
    )
    IF ((patients->qual[patient_index ].pregnancies[preg_index ].historical_ind = 0 )
    AND (patients->qual[patient_index ].pregnancies[preg_index ].pregnancy_end_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )
     SELECT INTO "nl:"
      FROM (pregnancy_instance pi ),
       (problem p )
      PLAN (pi
       WHERE (pi.pregnancy_id = patients->qual[patient_index ].pregnancies[preg_index ].pregnancy_id
       )
       AND (pi.pregnancy_instance_id = patients->qual[patient_index ].pregnancies[preg_index ].
       pregnancy_instance_id ) )
       JOIN (p
       WHERE (p.problem_id = pi.problem_id )
       AND (p.active_ind = 1 ) )
      DETAIL
       probrequest->person_id = patients->qual[patient_index ].patient_id ,
       istat = alterlist (probrequest->problem ,2 ) ,
       probrequest->problem[1 ].problem_id = p.problem_id ,
       probrequest->problem[1 ].problem_instance_id = p.problem_instance_id ,
       probrequest->problem[1 ].nomenclature_id = p.nomenclature_id ,
       probrequest->problem[1 ].annotated_display = p.annotated_display ,
       probrequest->problem[1 ].classification_cd = p.classification_cd ,
       probrequest->problem[1 ].onset_dt_tm = p.onset_dt_tm ,
       probrequest->problem[1 ].onset_tz = p.onset_tz ,
       probrequest->problem[1 ].organization_id = p.organization_id ,
       probrequest->problem[1 ].originating_nomenclature_id = p.originating_nomenclature_id ,
       probrequest->problem[1 ].confirmation_status_cd = p.confirmation_status_cd ,
       probrequest->problem[1 ].life_cycle_status_cd = resolved_action_cd ,
       probrequest->problem[1 ].problem_action_ind = 2 ,
       probrequest->skip_fsi_trigger = 1 ,
       master_pregnancy_id = pi.pregnancy_id ,
       master_preg_inst_id = pi.pregnancy_instance_id
      WITH nocounter
     ;end select
     IF ((curqual = 1 ) )
      SET probrequest->problem[2 ].nomenclature_id = probrequest->problem[1 ].nomenclature_id
      SET probrequest->problem[2 ].annotated_display = probrequest->problem[1 ].annotated_display
      SET probrequest->problem[2 ].classification_cd = probrequest->problem[1 ].classification_cd
      SET probrequest->problem[2 ].onset_dt_tm = probrequest->problem[1 ].onset_dt_tm
      SET probrequest->problem[2 ].onset_tz = probrequest->problem[1 ].onset_tz
      SET probrequest->problem[2 ].organization_id = probrequest->problem[1 ].organization_id
      SET probrequest->problem[2 ].originating_nomenclature_id = probrequest->problem[1 ].
      originating_nomenclature_id
      SET probrequest->problem[2 ].confirmation_status_cd = probrequest->problem[1 ].
      confirmation_status_cd
      SET probrequest->problem[2 ].life_cycle_status_cd = active_action_cd
      SET probrequest->problem[2 ].problem_action_ind = 4
      SET istat = alterlist (probrequest->problem[2 ].problem_comment ,1 )
      SET probrequest->problem[2 ].problem_comment[1 ].problem_comment =
      "New problem added to resolve merged 					pregnancy issue."
      SET probrequest->problem[2 ].problem_comment[1 ].beg_effective_dt_tm = cnvtdatetime (curdate ,
       curtime3 )
      SET probrequest->problem[2 ].problem_comment[1 ].comment_action_ind = 4
      IF ((validate (debug_ind ,0 ) > 0 ) )
       CALL echo ("ResolveActivePregnancyProblems_probrequest" )
       CALL echorecord (probrequest )
      ENDIF
      ;EXECUTE kia_ens_problem WITH replace ("REQUEST" ,probrequest ) , replace ("REPLY" ,probreply )
      IF ((validate (debug_ind ,0 ) > 0 ) )
       CALL echo ("ResolveActivePregnancyProblems_probreply" )
       CALL echorecord (probreply )
      ENDIF
      IF ((probreply->status_data.status = "F" ) )
       IF ((validate (debug_ind ,0 ) > 0 ) )
        CALL echo ("*Failed - problem ensure*" )
       ENDIF
       SET failed = true
       GO TO exit_script
      ELSE
       SET newproblemid = probreply->problem_list[2 ].problem_id
      ENDIF
      SET master_prob_id = newproblemid
      
      /*
      UPDATE FROM (pregnancy_instance pi )
       SET pi.problem_id = newproblemid ,
        pi.updt_id = reqinfo->updt_id ,
        pi.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
        pi.updt_applctx = reqinfo->updt_applctx ,
        pi.updt_cnt = (pi.updt_cnt + 1 ) ,
        pi.updt_task = reqinfo->updt_task
       WHERE (pi.pregnancy_id = master_pregnancy_id )
       AND (pi.pregnancy_instance_id = master_preg_inst_id )
       WITH nocounter
      ;end update
      */
      
     ENDIF
    ENDIF
   ENDFOR
  ENDFOR
 END ;Subroutine
 
 
 
 SUBROUTINE  resolvehistoricalpregnancyproblems (null )
  SET patientscnt = size (patients->qual ,5 )
  FOR (patient_index = 1 TO patientscnt )
   CALL resolvehistoricalpregnancyproblemsaction (patient_index )
  ENDFOR
 END ;Subroutine
 SUBROUTINE  resolvehistoricalpregnancyproblemsaction (patient_index )
  SET pregnancycnt = size (patients->qual[patient_index ].pregnancies ,5 )
  FOR (preg_index = 1 TO pregnancycnt )
   FREE RECORD probrequest
   RECORD probrequest (
     1 person_id = f8
     1 problem [* ]
       2 problem_action_ind = i2
       2 problem_id = f8
       2 problem_instance_id = f8
       2 nomenclature_id = f8
       2 annotated_display = vc
       2 organization_id = f8
       2 source_vocabulary_cd = f8
       2 source_identifier = vc
       2 problem_ftdesc = vc
       2 classification_cd = f8
       2 confirmation_status_cd = f8
       2 qualifier_cd = f8
       2 life_cycle_status_cd = f8
       2 life_cycle_dt_tm = dq8
       2 life_cycle_dt_flag = i2
       2 life_cycle_dt_cd = f8
       2 persistence_cd = f8
       2 certainty_cd = f8
       2 ranking_cd = f8
       2 probability = f8
       2 onset_dt_flag = i2
       2 onset_dt_cd = f8
       2 onset_dt_tm = dq8
       2 onset_tz = i4
       2 course_cd = f8
       2 severity_class_cd = f8
       2 severity_cd = f8
       2 severity_ftdesc = vc
       2 prognosis_cd = f8
       2 person_aware_cd = f8
       2 family_aware_cd = f8
       2 person_aware_prognosis_cd = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 status_upt_precision_flag = i2
       2 status_upt_precision_cd = f8
       2 status_upt_dt_tm = dq8
       2 cancel_reason_cd = f8
       2 originating_nomenclature_id = f8
       2 problem_comment [* ]
         3 problem_comment_id = f8
         3 comment_action_ind = i2
         3 comment_dt_tm = dq8
         3 comment_tz = i4
         3 comment_prsnl_id = f8
         3 comment_prsnl_name = vc
         3 problem_comment = vc
         3 beg_effective_dt_tm = dq8
         3 end_effective_dt_tm = dq8
       2 problem_discipline [* ]
         3 discipline_action_ind = i2
         3 problem_discipline_id = f8
         3 management_discipline_cd = f8
         3 beg_effective_dt_tm = dq8
         3 end_effective_dt_tm = dq8
       2 problem_prsnl [* ]
         3 prsnl_action_ind = i2
         3 problem_reltn_dt_tm = dq8
         3 problem_reltn_cd = f8
         3 problem_prsnl_id = f8
         3 problem_reltn_prsnl_id = f8
         3 beg_effective_dt_tm = dq8
         3 end_effective_dt_tm = dq8
       2 secondary_desc_list [* ]
         3 group_sequence = i4
         3 group [* ]
           4 secondary_desc_id = f8
           4 nomenclature_id = f8
           4 sequence = i4
       2 problem_uuid = vc
       2 problem_instance_uuid = vc
       2 contributor_system_cd = f8
       2 problem_type_flag = i2
       2 show_in_pm_history_ind = i2
     1 skip_fsi_trigger = i2
   )
   IF ((patients->qual[patient_index ].pregnancies[preg_index ].historical_ind = 1 ) )
    SET leastgestage = 0
    SET cnt = 0
    SET earlydeldttm = cnvtdatetime ("31-DEC-2100" )
    SELECT INTO "nl:"
     FROM (pregnancy_instance pi ),
      (pregnancy_child pc )
     PLAN (pi
      WHERE (pi.pregnancy_id = patients->qual[patient_index ].pregnancies[preg_index ].pregnancy_id
      )
      AND (pi.pregnancy_instance_id = patients->qual[patient_index ].pregnancies[preg_index ].
      pregnancy_instance_id ) )
      JOIN (pc
      WHERE (pc.pregnancy_id = pi.pregnancy_id )
      AND (pc.pregnancy_instance_id = pi.pregnancy_instance_id ) )
     HEAD pc.pregnancy_child_id
      cnt = (cnt + 1 ) ,
      IF ((cnt = 1 ) ) leastgestage = pc.gestation_age ,earlydeldttm = pc.delivery_dt_tm
      ELSE
       IF ((pc.delivery_dt_tm < cnvtdatetime (cnvtdate (earlydeldttm ) ,0 ) ) ) earlydeldttm = pc
        .delivery_dt_tm
       ENDIF
       ,
       IF ((pc.gestation_age < leastgestage ) ) leastgestage = pc.gestation_age
       ENDIF
      ENDIF
      ,
      IF ((earlydeldttm != 0.0 )
      AND (leastgestage != 0 ) ) onsetdttm = cnvtdatetime (pi.preg_start_dt_tm )
      ELSE onsetdttm = null
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (problem p )
     WHERE (p.person_id = patients->qual[patient_index ].patient_id )
     AND (p.problem_id = patients->qual[patient_index ].pregnancies[preg_index ].problem_id )
     AND (p.active_ind = 1 )
     DETAIL
      probrequest->person_id = patients->qual[patient_index ].patient_id ,
      istat = alterlist (probrequest->problem ,1 ) ,
      probrequest->problem[1 ].problem_id = p.problem_id ,
      probrequest->problem[1 ].problem_instance_id = p.problem_instance_id ,
      probrequest->problem[1 ].nomenclature_id = p.nomenclature_id ,
      probrequest->problem[1 ].annotated_display = p.annotated_display ,
      probrequest->problem[1 ].classification_cd = p.classification_cd ,
      probrequest->problem[1 ].onset_dt_tm = onsetdttm ,
      probrequest->problem[1 ].onset_tz = p.onset_tz ,
      probrequest->problem[1 ].organization_id = p.organization_id ,
      probrequest->problem[1 ].originating_nomenclature_id = p.originating_nomenclature_id ,
      probrequest->problem[1 ].confirmation_status_cd = p.confirmation_status_cd ,
      probrequest->problem[1 ].life_cycle_status_cd = resolved_action_cd ,
      probrequest->problem[1 ].problem_action_ind = 2 ,
      probrequest->skip_fsi_trigger = 1
     WITH nocounter
    ;end select
    IF ((validate (debug_ind ,0 ) > 0 ) )
     CALL echo ("ResolveHistoricalPregnancyProblemsAction_probrequest" )
     CALL echorecord (probrequest )
    ENDIF
    ;EXECUTE kia_ens_problem WITH replace ("REQUEST" ,probrequest ) , replace ("REPLY" ,probreply )
    IF ((validate (debug_ind ,0 ) > 0 ) )
     CALL echo ("ResolveHistoricalPregnancyProblemsAction_probreply" )
     CALL echorecord (probreply )
    ENDIF
    IF ((probreply->status_data.status = "F" ) )
     IF ((validate (debug_ind ,0 ) > 0 ) )
      CALL echo ("*Failed - problem ensure*" )
     ENDIF
     SET failed = true
     GO TO exit_script
    ELSE
     IF ((validate (debug_ind ,0 ) > 0 ) )
      CALL echo ("Pregnancy Problem Resolved" )
     ENDIF
    ENDIF
   ENDIF
  ENDFOR
 END ;Subroutine
 
 
#exit_script
 IF ((failed = false ) )
  CALL echo ("Script executed successfully." )
  ;COMMIT
  ROLLBACK
 ELSE
  CALL echo ("Script execution terminated as there were some issue encountered in between." )
  ROLLBACK
 ENDIF
END GO
