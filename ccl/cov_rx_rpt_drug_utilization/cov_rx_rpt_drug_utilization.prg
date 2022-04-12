DROP PROGRAM cov_rx_rpt_drug_utilization :dba GO
CREATE PROGRAM cov_rx_rpt_drug_utilization :dba
 prompt 
	"Output to File/Printer/MINE:" = "MINE"
	, "Search by Drug or Therapeutic Class:" = "Drug"
	, "Enter the search string (* for all):" = "*"
	, "Enter Facility (* for all):" = ""
	, "Enter the START date range (mmddyyyy hhmm)  FROM :" = "SYSDATE"
	, "(mmddyyyy hhmm)    TO :" = "SYSDATE"
	, "Include Pyxis Orders:" = "Yes" 

with OUTDEV, SEARCHTYPE, SEARCHSTRING, FACILITY, STARTDATE, STOPDATE, PYXIS
 SUBROUTINE  (formattolength (drugname =vc ,length =i4 ) =vc )
  SET return_string = drugname
  IF ((size (drugname ,1 ) > length ) )
   SET return_string = concat (substring (1 ,(length - 3 ) ,drugname ) ,"..." )
  ENDIF
  RETURN (return_string )
 END ;Subroutine
 DECLARE start_dt = q8
 DECLARE nstart_tm = i2 WITH protect ,noconstant (0 )
 DECLARE stop_dt = q8
 DECLARE nstop_tm = i2 WITH protect ,noconstant (0 )
 DECLARE nhit_report = i2 WITH protect ,noconstant (0 )
 DECLARE ssearch_string = vc WITH protect ,noconstant (" " )
 DECLARE medcnt = i4 WITH protect ,noconstant (0 )
 DECLARE itemcnt = i4 WITH protect ,noconstant (0 )
 DECLARE nindex = i4 WITH protect ,noconstant (0 )
 DECLARE nactual_size = i4 WITH protect ,noconstant (0 )
 DECLARE nexpand_size = i2 WITH protect ,constant (50 )
 DECLARE nexpand_total = i4 WITH protect ,noconstant (0 )
 DECLARE nexpand_start = i4 WITH protect ,noconstant (0 )
 DECLARE nexpand_stop = i4 WITH protect ,noconstant (0 )
 DECLARE nexpand = i4 WITH protect ,noconstant (0 )
 DECLARE nfacilitycounter = i2 WITH protect ,noconstant (0 )
 DECLARE med_cnt = i4 WITH protect ,noconstant (0 )
 DECLARE ord_cnt = i4 WITH protect ,noconstant (0 )
 DECLARE new_model_check = i2 WITH protect ,noconstant (0 )
 DECLARE total_dispenses = f8 WITH protect ,noconstant (0.0 )
 DECLARE total_cost = f8 WITH protect ,noconstant (0.0 )
 DECLARE total_charges = f8 WITH protect ,noconstant (0.0 )
 DECLARE total_orders = f8 WITH protect ,noconstant (0.0 )
 DECLARE total_dispenses_ther = f8 WITH protect ,noconstant (0.0 )
 DECLARE total_dispenses_ther_facility = f8 WITH protect ,noconstant (0.0 )
 DECLARE total_cost_ther = f8 WITH protect ,noconstant (0.0 )
 DECLARE total_charges_ther = f8 WITH protect ,noconstant (0.0 )
 DECLARE total_orders_ther = f8 WITH protect ,noconstant (0.0 )
 DECLARE dlastprotocolorderid = f8 WITH protect ,noconstant (0.0 )
 DECLARE cmeddef = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,11001 ,"MED_DEF" ) )
 DECLARE citemgroup = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,11001 ,"ITEM_GROUP" ) )
 DECLARE clabel = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,11000 ,"DESC" ) )
 DECLARE cgeneric = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,11000 ,"GENERIC_NAME" ) )
 DECLARE ccatalogcd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,6000 ,"PHARMACY" ) )
 DECLARE activity_type = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,106 ,"PHARMACY" ) )
 DECLARE csystem = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4062 ,"SYSTEM" ) )
 DECLARE csyspkgtyp = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4062 ,"SYSPKGTYP" ) )
 DECLARE cinpatient = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4500 ,"INPATIENT" ) )
 DECLARE cformat = c50 WITH protect ,constant (fillstring (50 ,"#" ) )
 DECLARE ctempstock = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4032 ,"TEMPSTOCK" ) )
 DECLARE nprotocolorder = i2 WITH protect ,constant (7 )
 DECLARE cwaste_charge = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4032 ,"WASTECHARGE"
   ) )
 DECLARE cwaste_credit = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4032 ,"WASTECREDIT"
   ) )
 DECLARE ccompound_parent_flag = i2 WITH protect ,constant (4 )
 DECLARE ccompound_child_flag = i2 WITH protect ,constant (5 )
 DECLARE swastedispensehxidcolname = vc WITH protect ,noconstant ("" )
 IF ((checkdic ("DISPENSE_HX.WASTE_DISPENSE_HX_ID" ,"A" ,0 ) > 0 ) )
  SET swastedispensehxidcolname = "dh.waste_dispense_hx_id"
 ELSE
  SET swastedispensehxidcolname = "0"
 ENDIF
 SET start_dt = cnvtdate (trim (substring (1 ,8 , $STARTDATE ) ) )
 SET nstart_tm = cnvtint (trim (substring (10 ,4 , $STARTDATE ) ) )
 SET stop_dt = cnvtdate (trim (substring (1 ,8 , $STOPDATE ) ) )
 SET nstop_tm = cnvtint (trim (substring (10 ,4 , $STOPDATE ) ) )
 IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "DRUG" ) )
  SET ssearch_string = trim ( $SEARCHSTRING ,4 )
 ELSE
  SET ssearch_string = trim ( $SEARCHSTRING )
 ENDIF
 DECLARE sutcdatetime = vc WITH protect ,noconstant (" " )
 DECLARE dutcdatetime = f8 WITH protect ,noconstant (0.0 )
 DECLARE cutc = i2 WITH protect ,constant (curutc )
 SUBROUTINE  (utcdatetime (sdatetime =vc ,lindex =i4 ,bshowtz =i2 ,sformat =vc ) =vc )
  DECLARE offset = i2 WITH protect ,noconstant (0 )
  DECLARE daylight = i2 WITH protect ,noconstant (0 )
  DECLARE lnewindex = i4 WITH protect ,noconstant (curtimezoneapp )
  DECLARE snewdatetime = vc WITH protect ,noconstant (" " )
  DECLARE ctime_zone_format = vc WITH protect ,constant ("ZZZ" )
  IF ((lindex > 0 ) )
   SET lnewindex = lindex
  ENDIF
  SET snewdatetime = datetimezoneformat (sdatetime ,lnewindex ,sformat )
  IF ((cutc = 1 )
  AND (bshowtz = 1 ) )
   IF ((size (trim (snewdatetime ) ) > 0 ) )
    SET snewdatetime = concat (snewdatetime ," " ,datetimezoneformat (sdatetime ,lnewindex ,
      ctime_zone_format ) )
   ENDIF
  ENDIF
  SET snewdatetime = trim (snewdatetime )
  RETURN (snewdatetime )
 END ;Subroutine
 SUBROUTINE  (utcshorttz (lindex =i4 ) =vc )
  DECLARE offset = i2 WITH protect ,noconstant (0 )
  DECLARE daylight = i2 WITH protect ,noconstant (0 )
  DECLARE lnewindex = i4 WITH protect ,noconstant (curtimezoneapp )
  DECLARE snewshorttz = vc WITH protect ,noconstant (" " )
  DECLARE ctime_zone_format = i2 WITH protect ,constant (7 )
  IF ((cutc = 1 ) )
   IF ((lindex > 0 ) )
    SET lnewindex = lindex
   ENDIF
   SET snewshorttz = datetimezonebyindex (lnewindex ,offset ,daylight ,ctime_zone_format )
  ENDIF
  SET snewshorttz = trim (snewshorttz )
  RETURN (snewshorttz )
 END ;Subroutine
 IF (NOT (validate (reply ,0 ) ) )
  ;CALL echo ("Defining record structure" )
  RECORD reply (
    1 status_data
      2 status = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET dispenses_table[1000 ] = 0.0
 SET facility_table[1000 ] = 0.0
 SET errcode = 1
 SET errmsg = fillstring (132 ," " )
 SET errcnt = 0
 SET count1 = 0
 SET error = script_failure
 SET firsttime = 1
 SET did_break = 0
 SET qualified = 0
 SET med_rec = fillstring (30 ," " )
 SET fin_nbr = fillstring (30 ," " )
 SET i = 0
 SET first_real = 1
 SET total_thers = 0
 EXECUTE rx_get_facs_for_prsnl_rr_incl WITH replace ("REQUEST" ,"PRSNL_FACS_REQ" ) , replace ("REPLY" ,"PRSNL_FACS_REPLY" )
 SET stat = alterlist (prsnl_facs_req->qual ,1 )
 ;CALL echo (build ("Reqinfo->updt_id --" ,reqinfo->updt_id ) )
 ;CALL echo (build ("curuser --" ,curuser ) )
 SET prsnl_facs_req->qual[1 ].username = trim (curuser )
 SET prsnl_facs_req->qual[1 ].person_id = reqinfo->updt_id
 EXECUTE rx_get_facs_for_prsnl WITH replace ("REQUEST" ,"PRSNL_FACS_REQ" ) , replace ("REPLY" ,"PRSNL_FACS_REPLY" )
 ;CALL echo (build ("Size of facility list in prg--" ,size (prsnl_facs_reply->qual[1 ].facility_list ,5 ) ) )
 FREE RECORD facility_list
 RECORD facility_list (
   1 qual [* ]
     2 facility_cd = f8
 )
 SET stat = alterlist (facility_list->qual ,value (size (prsnl_facs_reply->qual[1 ].facility_list ,5
    ) ) )
 FOR (x = 1 TO size (prsnl_facs_reply->qual[1 ].facility_list ,5 ) )
  ;CALL echo (build ("Checking facility --" ,
  ;trim (format (prsnl_facs_reply->qual[1 ].facility_list[x].facility_cd ,cformat ) ,3 ) ) )
  ;CALL echo (build ("against --" , $FACILITY ) )
  IF ((trim (format (prsnl_facs_reply->qual[1 ].facility_list[x ].facility_cd ,cformat ) ,3 ) =
   $FACILITY ) )
   SET nfacilitycounter +=1
   SET facility_list->qual[nfacilitycounter ].facility_cd = prsnl_facs_reply->qual[1 ].facility_list[
   x ].facility_cd
  ENDIF
 ENDFOR
 SET stat = alterlist (facility_list->qual ,nfacilitycounter )
 ;CALL echo (build ("Facility list size --" ,value (size (facility_list->qual ,5 ) ) ) )
 IF ((size (facility_list->qual ,5 ) = 0 ) )
  ;CALL echo ("*** User does not have access to selected facility ***" )
  GO TO exit_script
 ENDIF
 RECORD errors (
   1 err_cnt = i4
   1 err [* ]
     2 err_code = i4
     2 err_msg = vc
 )
 RECORD internal (
   1 select_desc = c30
   1 begin_dt_tm = dq8
   1 end_dt_tm = dq8
   1 output_device_s = c30
   1 orderid = f8
   1 personid = f8
   1 encntrid = f8
   1 alt_sel_cat_id = f8
   1 item_id = f8
 )
 
 record output (
 
 		1 cnt = i4
 		1 qual[*] 
 		 2 pharmacy_identifier = vc
 		 2 date_of_service = vc
 		 2 date_of_service_dq8 = dq8
 		 2 prescriber_ident = vc
 		 2 prescriber_id = f8
 		 2 ndc = vc
 		 2 encntr_id = f8
 		 2 item_id = f8
 		 2 quantity_dispensed = f8
 		 2 dispenses = f8
 		 2 unit_of_dispense = f8
 		 2 unit_of_measure = vc
 		 2 ingredient_cost = f8
 		 2 order_id = f8
 		 2 gender = i2
 		 2 state = vc
 		 2 realationship = i2
 		 2 realationship_vc = vc
	)
	
 SET internal->begin_dt_tm = cnvtdatetime (start_dt ,nstart_tm )
 SET internal->end_dt_tm = cnvtdatetime (stop_dt ,nstop_tm )
 SELECT INTO "nl:"
  dmp.pref_nbr
  FROM (dm_prefs dmp )
  WHERE (dmp.application_nbr = 300000 )
  AND (dmp.person_id = 0 )
  AND (dmp.pref_domain = "PHARMNET-INPATIENT" )
  AND (dmp.pref_section = "FRMLRYMGMT" )
  AND (dmp.pref_name = "NEW MODEL" )
  DETAIL
   IF ((dmp.pref_nbr = 1 ) ) new_model_check = 1
   ENDIF
  WITH nocounter
 ;end select
 RECORD orderrec (
   1 qual [* ]
     2 item_id = f8
     2 identifier_id = f8
     2 synonym_id = f8
     2 class_description = c35
     2 generic_name = c100
   1 orderlist [* ]
     2 sort_generic_name = vc
     2 sort_label_desc = c35
     2 class_total_dispensed = f8
     2 orderid = f8
     2 cost = f8
     2 price = f8
     2 deptmiscline = c255
     2 name = c30
     2 med_rec = c30
     2 fin_nbr = c30
     2 projected_stop_dt_tm = dq8
     2 projected_stop_tz = i4
     2 current_start_dt_tm = dq8
     2 current_start_tz = i4
     2 encntr_id = f8
     2 loc_s = c30
     2 loc_room_s = c10
     2 loc_bed_s = c10
     2 facility = c30
     2 facility_cd = f8
     2 order_status = f8
     2 all_unverified_ind = i2
     2 qualified = c1
     2 generic_name = vc
     2 ingredient [* ]
       3 generic_name = c100
       3 cost = f8
       3 unit_cost = f8
       3 price = f8
       3 dispenses = f8
       3 ingredient_type_flag = i2
       3 compound_parent = c50
       3 compound_ingred_add = i2
       3 item_id = f8
       3 ndc = vc
       3 class_description = c35
       3 volume_unit_cd = f8
       3 strength_unit_cd = f8
     2 skip_dup_dot_order_ind = i2
 )
 SET ccost = 2004.00
 SET ccomponentcost = 2005.00
 SET cdispensefromloc = 2006.00
 SET cdispensecategory = 2007.00
 SET ccomponentdispensecategory = 2008.00
 SET cfreq = 2011.00
 SET ccomponentfreq = 2012.00
 SET civfreq = 2013.00
 SET cdrugform = 2014.00
 SET cdispenseqty = 2015.00
 SET crefillqty = 2016.00
 SET cdaw = 2017.00
 SET csamplesgiven = 2018.00
 SET csampleqty = 2019.00
 SET cnextdispensedttm = 2024.00
 SET cpharmnotes = 2028.00
 SET cnotetype = 2029.00
 SET cparvalue = 2032.00
 SET cphysician = 2033.00
 SET cprinter = 2039.00
 SET crate = 2043.00
 SET ccomponentrate = 2044.00
 SET ccollroute = 2045.00
 SET croute = 2050.00
 SET ccomponentroute = 2046.00
 SET cstartbag = 2047.00
 SET ccomponentstartbag = 2048.00
 SET cstopbag = 2053.00
 SET cstoptype = 2055.00
 SET cstrengthdose = 2056.00
 SET cstrengthdoseunit = 2057.00
 SET cvolumedose = 2058.00
 SET cvolumedoseunit = 2059.00
 SET ctotalvolume = 2060.00
 SET cduration = 2061.00
 SET cdurationunit = 2062.00
 SET cfreetxtdose = 2063.00
 SET cinfuseoverunit = 2064.00
 SET cinfuseover = 118.00
 SET cstopdttm = 2073.00
 SET cdiluentid = 2065.00
 SET cdiluentvol = 2066.00
 SET cschprn = 2037.00
 SET ctreatmentperiod = 3524.00
 ;CALL echo ("Last Mod = 001" )
 ;CALL echo ("Mod Date = 12/01/2009" )
 ;CALL echo ("---END PHA_OE_FIELD_CONST.INC---" )
 SET count = 0
 SET prev_dseq = 1
 SET fac_dseq = 1
 SET crepl = 2068.00
 SET creplunit = 2069.00
 SET cordertype = 2070.00
 SET ctitrate = 2078.00
 ;CALL echo (build ("Search string ===" ,ssearch_string ) )
   SELECT DISTINCT INTO "NL:"
    mi2.item_id
    FROM (med_identifier mi ),
     (med_identifier mi2 )
    PLAN (mi
     WHERE (mi.value_key = patstring (value (cnvtupper (trim (ssearch_string ,4 ) ) ) ) )
     AND (mi.med_identifier_type_cd IN (cgeneric ,
     clabel ) )
     AND (mi.flex_type_cd = csystem )
     AND (mi.pharmacy_type_cd = cinpatient )
     AND (mi.med_product_id = 0 ) )
     JOIN (mi2
     WHERE (mi2.item_id = mi.item_id )
     AND (mi2.med_identifier_type_cd = clabel )
     AND (mi2.primary_ind = 1 )
     AND (mi2.flex_type_cd = csystem )
     AND (mi2.pharmacy_type_cd = cinpatient )
     AND (mi2.med_product_id = 0 ) )
    HEAD REPORT
     medcnt = 0
    DETAIL
     medcnt +=1 ,
     IF ((medcnt > size (orderrec->qual ,5 ) ) ) stat = alterlist (orderrec->qual ,(medcnt + 10 ) )
     ENDIF
     ,orderrec->qual[medcnt ].item_id = mi2.item_id ,
     orderrec->qual[medcnt ].generic_name = mi2.value 
     ;CALL echo (build ("Gen name --" ,orderrec->qual[medcnt ].generic_name ) ) ,
     ;CALL echo (build ("item id ---" ,orderrec->qual[medcnt ].item_id ) )
    WITH nocounter
   ;end select
  SET stat = alterlist (orderrec->qual ,medcnt )
  
 RECORD orderlist (
   1 data [* ]
     2 order_id = f8
     2 item_id = f8
     2 charge_qty = f8
     2 credit_qty = f8
     2 dispense_hx_id = f8
     2 cost = f8
     2 price = f8
 )
 SET idx = 0
 SET cntr = 0
 SET cntr = size (orderrec->qual ,5 )
 ;CALL echo (build ("cntr ---" ,cntr ) )
 SET nactual_size = size (orderrec->qual ,5 )
 SET nexpand_total = (nactual_size + (nexpand_size - mod (nactual_size ,nexpand_size ) ) )
 SET stat = alterlist (orderrec->qual ,nexpand_total )
 FOR (x = (nactual_size + 1 ) TO nexpand_total )
  SET orderrec->qual[x ].item_id = orderrec->qual[nactual_size ].item_id
 ENDFOR
 ;CALL echo (build ("Facility ==========" , $FACILITY ) )
 ;CALL echo (build ("start date ---" ,format (cnvtdatetime (internal->begin_dt_tm ) , "MM/dd/yy hh:mm;;d" ) ) )
 ;CALL echo (build ("end date ---" ,format (cnvtdatetime (internal->end_dt_tm ) ,"MM/dd/yy hh:mm;;d") ) )
 SELECT DISTINCT INTO "NL:"
  o.order_id ,
  dfacilityareacd =
  IF ((o.encntr_id > 0 ) ) eh.loc_facility_cd
  ELSE od.future_loc_facility_cd
  ENDIF
  FROM (dispense_hx dh ),
   (orders o ),
   (order_dispense od ),
   (encounter eh ),
   (prod_dispense_hx pdh ),
   (dispense_category dc )
  PLAN (dh
   WHERE (dh.updt_dt_tm <= cnvtdatetime (internal->end_dt_tm ) )
   AND (dh.updt_dt_tm >= cnvtdatetime (internal->begin_dt_tm ) )
   AND NOT ((dh.disp_event_type_cd IN (ctempstock ,
   cwaste_charge ,
   cwaste_credit ) ) )
   AND (parser (swastedispensehxidcolname ) IN (0 ,
   null ) ) )
   JOIN (pdh
   WHERE expand (nexpand ,1 ,nexpand_total ,pdh.item_id ,orderrec->qual[nexpand ].item_id )
   AND (pdh.dispense_hx_id = dh.dispense_hx_id ) )
   JOIN (o
   WHERE (o.order_id = dh.order_id )
   AND (o.catalog_type_cd = ccatalogcd )
   AND ((((o.orig_ord_as_flag + 0 ) = 0 ) ) OR ((cnvtupper ( $PYXIS ) = "YES" )
   AND ((o.orig_ord_as_flag + 0 ) = 4 ) ))
   AND ((o.template_order_flag + 0 ) != nprotocolorder ) )
   JOIN (od
   WHERE (od.order_id = o.order_id ) )
   JOIN (dc
   WHERE (dc.dispense_category_cd = od.dispense_category_cd )
   AND (((dc.charge_pt_sch_ind != 2 ) ) OR ((((dc.charge_pt_sch_ind = 2 )
   AND (dh.charge_ind = 1 ) ) OR ((dc.charge_pt_prn_ind = 2 )
   AND (dh.charge_ind = 1 )
   AND (o.prn_ind = 1 ) )) )) )
   JOIN (eh
   WHERE (eh.encntr_id = o.encntr_id ) and (eh.encntr_type_cd = value(uar_get_code_by("MEANING",71,"INPATIENT"))))
  ORDER BY o.protocol_order_id ,
   dh.order_id ,
   pdh.item_id ,
   pdh.dispense_hx_id
  HEAD REPORT
   idx = 0 ,
   ningred_cnt = 0 ,
   ordcnt = 0
  HEAD dh.order_id
   ;CALL echo (build ("Order id --" ,o.order_id ) ) ,
   ;CALL echo (build ("dFacilityAreaCD --" ,dfacilityareacd ) ) ,
   IF ((locateval (x ,1 ,size (facility_list->qual ,5 ) ,dfacilityareacd ,facility_list->qual[x ].facility_cd ) > 0 ) )
    ;CALL echo ("Storing order id" ) ,
    IF ((dfacilityareacd > 0 ) ) 
    	facility_area = uar_get_code_display (dfacilityareacd )
    ENDIF
    ordcnt +=1 
    stat = alterlist (orderrec->orderlist ,ordcnt ) 
    stat = alterlist (orderrec->orderlist[ordcnt ].ingredient ,0 ) 
    orderrec->orderlist[ordcnt ].orderid = o.order_id 
    orderrec->orderlist[ordcnt ].facility = substring (1 ,30 ,facility_area )
    orderrec->orderlist[ordcnt ].facility_cd = dfacilityareacd
    ningred_cnt = 0
    IF ((o.protocol_order_id > 0 ) AND (dlastprotocolorderid = o.protocol_order_id ) ) 
    	orderrec->orderlist[ordcnt ].skip_dup_dot_order_ind = 1
    ENDIF
    
    dlastprotocolorderid = o.protocol_order_id
   
   ENDIF
   
  HEAD pdh.item_id
   IF ((locateval (x ,1 ,size (facility_list->qual ,5 ) ,dfacilityareacd ,facility_list->qual[x ].facility_cd ) > 0 ) )
    ;CALL echo (build ("pdh item id ---" ,pdh.item_id ) ) ,
    IF ((dh.order_id > 0 ) ) 
    	ningred_cnt +=1
    	stat = alterlist (orderrec->orderlist[ordcnt ].ingredient ,ningred_cnt ) 
    	orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].class_description = fillstring (35 ," " )
     
     	nindex = locateval (x ,1 ,nactual_size ,pdh.item_id ,orderrec->qual[x ].item_id )
     	orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].generic_name = orderrec->qual[nindex ].generic_name 
     	orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].item_id = orderrec->qual[nindex ].item_id 
     ;CALL echo (build ("Label desc ===" ,orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].generic_name ) )
    ENDIF
   ENDIF
  HEAD pdh.dispense_hx_id
   IF ((locateval (x ,1 ,size (facility_list->qual ,5 ) ,dfacilityareacd ,facility_list->qual[x ].facility_cd ) > 0 ) )
    ;CALL echo (build ("dispense_hx id --" ,pdh.dispense_hx_id ) ) ,
    IF ((dh.order_id > 0 ) )
     IF ((pdh.charge_qty > 0 ) )
      ;CALL echo (build ("doses ==" ,dh.doses ) ) ,
      orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].dispenses +=dh.doses 
      
      orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].cost+=(pdh.cost * pdh.charge_qty ) 
      orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].price += pdh.price
      orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].unit_cost = pdh.cost
     ELSE 
     	orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].dispenses -=dh.doses 
     	orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].cost -=(pdh.cost * pdh.credit_qty ) 
     	orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].price -=pdh.price
       	orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].unit_cost = pdh.cost
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter ,expand = 1
 ;end select
 IF ((curqual > 0 ) )
  DECLARE icnt = i4 WITH protect ,noconstant (0 )
  SET nactual_size = size (orderrec->orderlist ,5 )
  SELECT into "nl:"
   dh.doses ,
   pdh.cost ,
   pdh.price ,
   pdh.charge_qty
   FROM (order_ingredient oi ),
    (dispense_hx dh ),
    (prod_dispense_hx pdh ),
    (med_identifier mi )
   PLAN (dh
    WHERE expand (nexpand ,1 ,nactual_size ,dh.order_id ,orderrec->orderlist[nexpand ].orderid ) )
    JOIN (oi
    WHERE (oi.order_id = dh.order_id )
    AND (((oi.ingredient_type_flag = ccompound_parent_flag ) ) 
    	OR ((oi.ingredient_type_flag = ccompound_child_flag ) ))
    AND (dh.order_id = oi.order_id )
    AND (dh.action_sequence = oi.action_sequence ) )
    JOIN (pdh
   	 	WHERE (dh.dispense_hx_id = pdh.dispense_hx_id )
     	AND (pdh.ingred_sequence = oi.comp_sequence ) )
    JOIN (mi
    	WHERE (pdh.item_id = mi.item_id )
    	AND (mi.med_identifier_type_cd = clabel )
    	AND (mi.med_product_id = 0 ) )
   DETAIL
    nindex = locateval (icnt ,1 ,size (orderrec->orderlist ,5 ), dh.order_id ,orderrec->orderlist[icnt ].orderid ) 
   
    IF ((nindex > 0 ) ) 
    	norderingredlistsize = size (orderrec->orderlist[nindex ].ingredient ,5 ) 
     	ningred = locateval (icnt ,1 ,norderingredlistsize ,pdh.item_id ,orderrec->orderlist[nindex ].ingredient[icnt ].item_id ) 
    
    
     IF ((ningred > 0 ) ) 
     	orderrec->orderlist[nindex ].ingredient[ningred ].ingredient_type_flag = oi.ingredient_type_flag
     	orderrec->orderlist[nindex ].ingredient[ningred ].volume_unit_cd   = oi.volume_unit
     	orderrec->orderlist[nindex ].ingredient[ningred ].strength_unit_cd = oi.strength_unit
     ELSEIF ((ningred = 0 )) 
     	norderingredlistsize +=1 
     	stat = alterlist (orderrec->orderlist[nindex ].ingredient ,norderingredlistsize ) 
     	orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].generic_name = substring (1 ,50 ,mi.value ) 
     	orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].item_id = pdh.item_id 
     	orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].ingredient_type_flag = oi.ingredient_type_flag 
     	orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].class_description = fillstring (35 ," " ) 
     	orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].compound_ingred_add = 1
     	orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].volume_unit_cd   = oi.volume_unit
     	orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].strength_unit_cd = oi.strength_unit
     ENDIF
     
     IF ((orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].item_id = pdh.item_id )
     		AND (orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].compound_ingred_add = 1 ) )
      IF ((pdh.charge_qty > 0 ) ) 
      	orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].dispenses +=dh.doses
      	orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].cost +=(pdh.cost * pdh.charge_qty )
      	orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].price +=pdh.price
        orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].unit_cost = pdh.cost
        orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].volume_unit_cd   = oi.volume_unit
     	orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].strength_unit_cd = oi.strength_unit
      ELSE 
      	orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].dispenses -=dh.doses
       orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].cost -=(pdh.cost * pdh.credit_qty ) 
       orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].price -=pdh.price
       orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].unit_cost = pdh.cost
       orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].volume_unit_cd   = oi.volume_unit
     	orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].strength_unit_cd = oi.strength_unit
      ENDIF
      
      
     ELSEIF ((orderrec->orderlist[nindex ].ingredient[ningred ].compound_ingred_add = 1 ) )
      IF ((pdh.charge_qty > 0 ) ) orderrec->orderlist[nindex ].ingredient[ningred ].dispenses +=dh.doses
      	orderrec->orderlist[nindex ].ingredient[ningred ].cost +=(pdh.cost * pdh.charge_qty )
      	orderrec->orderlist[nindex ].ingredient[ningred ].price +=pdh.price
      	orderrec->orderlist[nindex ].ingredient[ningred ].unit_cost = pdh.cost
      	orderrec->orderlist[nindex ].ingredient[ningred ].volume_unit_cd   = oi.volume_unit
     	orderrec->orderlist[nindex ].ingredient[ningred ].strength_unit_cd = oi.strength_unit
      ELSE orderrec->orderlist[nindex ].ingredient[ningred ].dispenses -=dh.doses
      	orderrec->orderlist[nindex ].ingredient[ningred ].cost -=(pdh.cost * pdh.credit_qty )
      	orderrec->orderlist[nindex ].ingredient[ningred ].price -=pdh.price
		orderrec->orderlist[nindex ].ingredient[ningred ].unit_cost = pdh.cost
		orderrec->orderlist[nindex ].ingredient[ningred ].volume_unit_cd   = oi.volume_unit
     	orderrec->orderlist[nindex ].ingredient[ningred ].strength_unit_cd = oi.strength_unit
      ENDIF
     ENDIF
     
     
    ENDIF
   WITH nocounter, expand =1
  ;end select
 ENDIF
 SET printfile = "cer_print:rxadi.dat"
 DECLARE nmax_ingred = i2 WITH protect ,noconstant (0 )
 ;CALL echo ("*** Finding max number of ingredients ***" )
 SELECT INTO "NL:"
  order_id = orderrec->orderlist[d.seq ].orderid
  FROM (dummyt d WITH seq = value (size (orderrec->orderlist ,5 ) ) )
  HEAD order_id
   ningred_cnt = 0 ,
   ;CALL echo (build ("# of ingredients ---" ,size (orderrec->orderlist[d.seq ].ingredient ,5 ) ) ) ,
   IF ((size (orderrec->orderlist[d.seq ].ingredient ,5 ) > nmax_ingred ) ) 
   	nmax_ingred = size (orderrec->orderlist[d.seq ].ingredient ,5 )
   ENDIF
  WITH nocounter
 ;end select
 ;CALL echo (build ("Max ingredients ---" ,nmax_ingred ) )
 SET total_dispenses = 0
 SET total_cost = 0
 SET total_charges = 0
 SET total_orders = 0
 SET total_dispenses_ther = 0
 SET total_cost_ther = 0
 SET total_charges_ther = 0
 SET total_orders_ther = 0
 SET total_dispenses_ther_facility = 0
 SET prev_dseq = 1
 SET fac_dseq = 1
 SET norderlistsize = size (orderrec->orderlist ,5 )
 FOR (nordercnt = 1 TO norderlistsize )
  SET ningredsize = size (orderrec->orderlist[nordercnt ].ingredient ,5 )
  SET nindex = locateval (x ,1 ,ningredsize ,4 ,orderrec->orderlist[nordercnt ].ingredient[x ].
   ingredient_type_flag )
  IF ((nindex > 0 ) )
   FOR (ningredcnt = 1 TO ningredsize )
    IF ((orderrec->orderlist[nordercnt ].ingredient[ningredcnt ].ingredient_type_flag =ccompound_child_flag ) )
     SET orderrec->orderlist[nordercnt ].ingredient[ningredcnt ].compound_parent = trim (orderrec->
      orderlist[nordercnt ].ingredient[nindex ].generic_name )
     SET orderrec->orderlist[nordercnt ].ingredient[ningredcnt ].generic_name = concat (trim (
       orderrec->orderlist[nordercnt ].ingredient[nindex ].generic_name ) ," " ,trim (orderrec->
       orderlist[nordercnt ].ingredient[ningredcnt ].generic_name ) )
    ENDIF
   ENDFOR
  ENDIF
 ENDFOR



select into "nl:"
from
	 encntr_alias ea
	,encounter e
	,orders o
	,(dummyt   d1  with seq = size(orderrec->orderlist, 5))
plan d1
join o
	where o.order_id = orderrec->orderlist[d1.seq].orderid
	and   o.order_id > 0.0
join e
	where e.encntr_id = o.encntr_id
	and   e.encntr_id > 0.0
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
detail
	orderrec->orderlist[d1.seq].fin_nbr = ea.alias
	orderrec->orderlist[d1.seq].encntr_id = e.encntr_id
with nocounter
 
 declare i = i4 with noconstant(0)
 declare j = i4 with noconstant(0)
 declare k = i4 with noconstant(0)
 
 for (i=1 to size(orderrec->orderlist,5))
 	for (j=1 to size(orderrec->orderlist[i].ingredient,5))
 		
 		set k += 1
 		
 		set stat = alterlist(output->qual,k)
 		set output->qual[k].pharmacy_identifier = orderrec->orderlist[i].facility
 		set output->qual[k].pharmacy_identifier = cnvtstring(orderrec->orderlist[i].facility_cd)
 		set output->qual[k].item_id = orderrec->orderlist[i].ingredient[j].item_id
 		set output->qual[k].order_id = orderrec->orderlist[i].orderid
 		set output->qual[k].encntr_id = orderrec->orderlist[i].encntr_id
 		set output->qual[k].ingredient_cost = orderrec->orderlist[i].ingredient[j].unit_cost
 		set output->qual[k].dispenses = orderrec->orderlist[i].ingredient[j].dispenses
 		
 		/*
 		 record output (
 
 		1 cnt = i4
 		1 qual[*] 
 		 2 pharmacy_identifier = vc
 		 2 date_of_service = vc
 		 2 date_of_service_dq8 = dq8
 		 2 prescriber_ident = vc
 		 2 prescriber_id = f8
 		 2 ndc = vc
 		 
 		 
 		 2 quantity_dispensed = i2
 		 2 unit_of_measure = vc
 		 
 		 
 		 2 gender = i2
 		 2 state = vc
 		 2 realationship = i2
			)
		*/
 		set output->cnt = k
 	endfor
 endfor


select into "nl:"
from
	 encounter e
	,person p
	,(dummyt d1 with seq=output->cnt)
plan d1
join e
	where e.encntr_id = output->qual[d1.seq].encntr_id
join p
	where p.person_id = e.person_id
detail
	if (cnvtupper(substring(1,1,uar_get_code_display(p.sex_cd))) = "F")
		output->qual[d1.seq].gender = 2
	elseif (cnvtupper(substring(1,1,uar_get_code_display(p.sex_cd))) = "M")
		output->qual[d1.seq].gender = 1
	else
		output->qual[d1.seq].gender = 0
	endif
with nocounter
    	
select into "nl:"
from
	 order_ingredient oi
	,dispense_hx dh
    ,prod_dispense_hx pdh 
    ,med_identifier mi
    ,orders o
    ,order_action oa
	,(dummyt d1 with seq=output->cnt)
	,(dummyt d2)
	,(dummyt d3)
	,(dummyt d4)
plan d1
join dh
	where dh.order_id = output->qual[d1.seq].order_id
join d2
join oi
	where oi.order_id = dh.order_id
	and  oi.action_sequence = dh.action_sequence
join o
	where o.order_id = oi.order_id
join oa
	where oa.order_id = o.order_id
	and oa.action_sequence = o.last_action_sequence
join d3
join pdh
	where pdh.dispense_hx_id = dh.dispense_hx_id
	and pdh.ingred_sequence = oi.comp_sequence
join d4
join mi
	where pdh.item_id = mi.item_id
	and mi.med_product_id = pdh.med_product_id
	and mi.med_identifier_type_cd = value(uar_get_code_by("MEANING",11000,"NDC"))
order by
	oi.order_id
detail
	    if (oi.strength_unit > 0.0)
	    	output->qual[d1.seq].unit_of_measure = uar_get_code_display(oi.strength_unit)
	    	output->qual[d1.seq].unit_of_dispense = oi.strength
	    else
	    	output->qual[d1.seq].unit_of_measure = uar_get_code_display(oi.volume_unit)
	    	output->qual[d1.seq].unit_of_dispense = oi.volume
	    endif
	    output->qual[d1.seq].ndc = mi.value
	    output->qual[d1.seq].quantity_dispensed = ( output->qual[d1.seq].dispenses *  output->qual[d1.seq].unit_of_dispense)
	    output->qual[d1.seq].prescriber_id = oa.order_provider_id
	    output->qual[d1.seq].date_of_service_dq8 = dh.dispense_dt_tm
	    output->qual[d1.seq].date_of_service = format(dh.dispense_dt_tm,"YYYYMMDD;;q")
with nocounter, outerjoin=d4

select into "nl:"
from	
		  prsnl pr
		, prsnl_alias pa
		,(dummyt d1 with seq=output->cnt)
plan d1
join pr 
	where pr.person_id = output->qual[d1.seq].prescriber_id
join pa where pa.person_id = pr.person_id
	and pa.alias_pool_cd = value(uar_get_code_by("DISPLAY", 263,"National Provider Identifier"))
	and pa.prsnl_alias_type_cd = value(uar_get_code_by("DISPLAY", 320, "National Provider Identifier"))
detail
	output->qual[d1.seq].prescriber_ident = pa.alias
with nocounter


select into "nl:"
from	
		  person p
		, address a
		, encounter e
		,(dummyt d1 with seq=output->cnt)
plan d1
join e
	where e.encntr_id = output->qual[d1.seq].encntr_id
join p 
	where p.person_id = e.person_id
join a 
	where a.parent_entity_id = p.person_id
	and   a.address_type_cd = value(uar_get_code_by("MEANING",212,"HOME"))
	and   a.active_ind = 1
	and   cnvtdatetime(sysdate) between a.beg_effective_dt_tm and a.end_effective_dt_tm
order by
	 p.person_id
	,a.beg_effective_dt_tm
detail
	output->qual[d1.seq].state = substring(1,2,cnvtupper(uar_get_code_display(a.state_cd)))
with nocounter



select into "nl:"
	from
		 encounter e
		,person_plan_reltn ppr1
		,person_person_reltn ppr2
	 	,(dummyt d1 with seq=output->cnt)
	plan d1
	join e
		where e.encntr_id = output->qual[d1.seq].encntr_id
	join ppr1
		where ppr1.person_id = e.person_id
		and   ppr1.active_ind = 1
		and   cnvtdatetime(sysdate) between ppr1.beg_effective_dt_tm and ppr1.end_effective_dt_tm
	join ppr2
		where ppr2.related_person_id = ppr1.subscriber_person_id
	head report
		i = 0
	detail
		if (ppr2.person_reltn_cd = value(uar_get_code_by("MEANING",40,"SPOUSE")))
			output->qual[d1.seq].realationship = 2
		elseif ((ppr2.person_reltn_cd != value(uar_get_code_by("MEANING",40,"SELF"))) and (ppr2.person_reltn_cd > 0.0))
			output->qual[d1.seq].realationship = 3
		else
			output->qual[d1.seq].realationship = 1
		endif
		output->qual[d1.seq].realationship_vc = uar_get_code_display(ppr2.person_reltn_cd)
	with nocounter
	
	
  SET reply->status_data.status = "S"
  ;CALL echo ("Success" )
 
#exit_script
/*
SELECT into $OUTDEV
	ORDERLIST_SORT_GENERIC_NAME = SUBSTRING(1, 30, ORDERREC->orderlist[D1.SEQ].sort_generic_name)
	, ORDERLIST_SORT_LABEL_DESC = ORDERREC->orderlist[D1.SEQ].sort_label_desc
	, ORDERLIST_CLASS_TOTAL_DISPENSED = ORDERREC->orderlist[D1.SEQ].class_total_dispensed
	, ORDERLIST_ORDERID = ORDERREC->orderlist[D1.SEQ].orderid
	, ORDERLIST_COST = ORDERREC->orderlist[D1.SEQ].cost
	, ORDERLIST_PRICE = ORDERREC->orderlist[D1.SEQ].price
	, ORDERLIST_DEPTMISCLINE = ORDERREC->orderlist[D1.SEQ].deptmiscline
	, ORDERLIST_NAME = ORDERREC->orderlist[D1.SEQ].name
	, ORDERLIST_MED_REC = ORDERREC->orderlist[D1.SEQ].med_rec
	, ORDERLIST_FIN_NBR = ORDERREC->orderlist[D1.SEQ].fin_nbr
	, ORDERLIST_PROJECTED_STOP_DT_TM = ORDERREC->orderlist[D1.SEQ].projected_stop_dt_tm
	, ORDERLIST_PROJECTED_STOP_TZ = ORDERREC->orderlist[D1.SEQ].projected_stop_tz
	, ORDERLIST_CURRENT_START_DT_TM = ORDERREC->orderlist[D1.SEQ].current_start_dt_tm
	, ORDERLIST_CURRENT_START_TZ = ORDERREC->orderlist[D1.SEQ].current_start_tz
	, ORDERLIST_ENCNTR_ID = ORDERREC->orderlist[D1.SEQ].encntr_id
	, ORDERLIST_LOC_S = ORDERREC->orderlist[D1.SEQ].loc_s
	, ORDERLIST_LOC_ROOM_S = ORDERREC->orderlist[D1.SEQ].loc_room_s
	, ORDERLIST_LOC_BED_S = ORDERREC->orderlist[D1.SEQ].loc_bed_s
	, ORDERLIST_FACILITY = ORDERREC->orderlist[D1.SEQ].facility
	, ORDERLIST_ORDER_STATUS = ORDERREC->orderlist[D1.SEQ].order_status
	, ORDERLIST_ALL_UNVERIFIED_IND = ORDERREC->orderlist[D1.SEQ].all_unverified_ind
	, ORDERLIST_QUALIFIED = ORDERREC->orderlist[D1.SEQ].qualified
	, ORDERLIST_GENERIC_NAME = SUBSTRING(1, 30, ORDERREC->orderlist[D1.SEQ].generic_name)
	, INGREDIENT_GENERIC_NAME = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].generic_name
	, ORDERLIST_INGREDIENT_GENERIC_NAME = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].generic_name
	, INGREDIENT_COST = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].cost
	, INGREDIENT_PRICE = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].price
	, INGREDIENT_DISPENSES = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].dispenses
	, INGREDIENT_INGREDIENT_TYPE_FLAG = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].ingredient_type_flag
	, INGREDIENT_COMPOUND_PARENT = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].compound_parent
	, INGREDIENT_COMPOUND_INGRED_ADD = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].compound_ingred_add
	, INGREDIENT_ITEM_ID = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].item_id
	, INGREDIENT_CLASS_DESCRIPTION = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].class_description
	, ORDERLIST_SKIP_DUP_DOT_ORDER_IND = ORDERREC->orderlist[D1.SEQ].skip_dup_dot_order_ind

FROM
	(DUMMYT   D1  WITH SEQ = SIZE(ORDERREC->orderlist, 5))
	, (DUMMYT   D2  WITH SEQ = 1)

PLAN D1 WHERE MAXREC(D2, SIZE(ORDERREC->orderlist[D1.SEQ].ingredient, 5))
JOIN D2

WITH NOCOUNTER, SEPARATOR=" ", FORMAT
*/

SELECT INTO $OUTDEV
	  QUAL_PHARMACY_IDENTIFIER = SUBSTRING(1, 30, OUTPUT->qual[D1.SEQ].pharmacy_identifier)
	, QUAL_DATE_OF_SERVICE = SUBSTRING(1, 30, OUTPUT->qual[D1.SEQ].date_of_service)
	, QUAL_PRESCRIBER_IDENT = SUBSTRING(1, 30, OUTPUT->qual[D1.SEQ].prescriber_ident)
	;, QUAL_PRESCRIBER_ID = OUTPUT->qual[D1.SEQ].prescriber_id
	, QUAL_NDC = SUBSTRING(1, 30, OUTPUT->qual[D1.SEQ].ndc)
	, QUAL_QUANTITY_DISPENSED = OUTPUT->qual[D1.SEQ].quantity_dispensed
	, QUAL_UNIT_OF_MEASURE = SUBSTRING(1, 30, OUTPUT->qual[D1.SEQ].unit_of_measure)
	, QUAL_INGREDIENT_COST = OUTPUT->qual[D1.SEQ].ingredient_cost
	, QUAL_ENCNTR_ID = OUTPUT->qual[D1.SEQ].encntr_id
	, QUAL_GENDER = OUTPUT->qual[D1.SEQ].gender
	, QUAL_STATE = SUBSTRING(1, 30, OUTPUT->qual[D1.SEQ].state)
	, QUAL_REALATIONSHIP = OUTPUT->qual[D1.SEQ].realationship
	;, QUAL_ENCNTR_ID = OUTPUT->qual[D1.SEQ].encntr_id
	;, QUAL_ITEM_ID = OUTPUT->qual[D1.SEQ].item_id
	;, QUAL_DISPENSES = OUTPUT->qual[D1.SEQ].dispenses

FROM
	(DUMMYT   D1  WITH SEQ = SIZE(OUTPUT->qual, 5))

PLAN D1
	where output->qual[d1.seq].prescriber_id not in(   18111746.00,0.0)
	and   output->qual[d1.seq].item_id not in(77903336)

;WITH NOCOUNTER, SEPARATOR=" ", FORMAT
with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,maxcol=32000,format


; call echorecord(orderrec)
; call echorecord(output)
 
END GO
