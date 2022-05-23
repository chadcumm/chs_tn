/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		06/22/2020
	Solution:				
	Source file name:	 	cov_get_care_team_lists.prg
	Object name:		   	cov_get_care_team_lists
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	06/22/2020  Chad Cummings			Initial Deployment
******************************************************************************/
drop program cov_get_care_team_lists go
create program cov_get_care_team_lists

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "PRSNLID" = 0 

with OUTDEV, PRSNLID


record t_rec
(
	1 prsnl_id = f8
	1 user_pref = vc
	1 user_pref_ind = i2
	1 cnt = i2
	1 qual[*]
	 2 list_type = c1
	 2 list_id   = f8
	 2 name      = vc
	 2 active_ind = i2
	 2 list_type_full = vc
)

set t_rec->prsnl_id = $PRSNLID

if (t_rec->prsnl_id = 0.0)
	set t_rec->prsnl_id = reqinfo->updt_id
endif

;set t_rec->prsnl_id = 16908168	;CCUMMIN4	   16908168.00
;set t_rec->prsnl_id = 4122622	;PHYSHOSP	    4122622.00
;set t_rec->prsnl_id = 12297980	;RTHACKER	   12297980.00
;set t_rec->prsnl_id = 16442891	;UA.RTHACKER	   16442891.00

set t_rec->cnt = (t_rec->cnt + 1)
set stat = alterlist(t_rec->qual,t_rec->cnt)
set t_rec->qual[t_rec->cnt].list_type 	= "M"
set t_rec->qual[t_rec->cnt].list_id 	= 0.0
set t_rec->qual[t_rec->cnt].name		= "My Assigned Patients"
set t_rec->qual[t_rec->cnt].active_ind 			= 1

/*
select
    dpl.patient_list_id
    ,dpl.name 
fr;om
     detail_prefs dp
    ,dcp_patient_list dpl
    ,name_value_prefs nvp
plan dpl
    where dpl.owner_prsnl_id = t_rec->prsnl_id
join nvp
    where cnvtreal(nvp.pvc_value) = dpl.patient_list_id
    and   nvp.parent_entity_name = "DETAIL_PREFS"
    and   cnvtupper(nvp.pvc_name) = "PATIENTLISTID"
    and   nvp.active_ind = 1
join dp
    where dp.detail_prefs_id = nvp.parent_entity_id
    and dp.view_name = "PATLISTVIEW"
    and dp.view_seq > 0
    and dp.prsnl_id = dpl.owner_prsnl_id
    and dp.active_ind = 1
order by
	   dpl.name
	  ,dpl.patient_list_id
head report
	i = t_rec->cnt
head dpl.patient_list_id
	i = (i + 1)
	stat = alterlist(t_rec->qual,i)
	t_rec->qual[i].list_type 	= "P"
	t_rec->qual[i].list_id 		= dpl.patient_list_id
	t_rec->qual[i].name			= dpl.name
foot report
	t_rec->cnt = i
with nocounter

/*
select distinct
     team=concat(trim(uar_get_code_display(pct.facility_cd))
          ," - "
          ,trim(uar_get_code_display(pct.pct_med_service_cd)))
    ,pct.pct_care_team_id
from
    PCT_CARE_TEAM pct
    ,location f
plan pct
    where pct.prsnl_id in(value(reqinfo->updt_id),4122622)
    and   pct.active_ind = 1
    and   pct.facility_cd > 0.0
    and   pct.pct_med_service_cd > 0.0
    and   cnvtdatetime(sysdate) between pct.begin_effective_dt_tm and pct.end_effective_dt_tm
    ;and   pct.orig_pct_team_id = pct.pct_care_team_id
join f
    where f.location_cd = pct.facility_cd
    and   f.active_ind = 1
order by
     team
    ,pct.orig_pct_team_id
head report
	i = t_rec->cnt
head pct.orig_pct_team_id
	i = (i + 1)
	stat = alterlist(t_rec->qual,i)
	t_rec->qual[i].list_type 	= "C"
	t_rec->qual[i].list_id 		= pct.orig_pct_team_id
	t_rec->qual[i].name			= team
foot report
	t_rec->cnt = i
with nocounter
*/

select into "nl:"
from 
	 app_prefs a
	,name_value_prefs n
plan a 
	;where a.prsnl_id 		in(value(reqinfo->updt_id),4122622)
	where a.prsnl_id 		in(value(t_rec->prsnl_id))
	and a.application_number in(600005,3202020)
join n 
	where n.parent_entity_id = a.app_prefs_id
	and n.parent_entity_name = "APP_PREFS"
	and n.pvc_name = "MP_PHYS_HANDOFF_CTLISTS"
	and n.active_ind = 1
order by
	n.sequence
detail
	t_rec->user_pref = concat(trim(t_rec->user_pref),trim(n.pvc_value))
	t_rec->user_pref_ind = 1
with nocounter


if (t_rec->user_pref_ind = 1)
	set stat = cnvtjsontorec(t_rec->user_pref)

	if (validate(ctlists->lists))
		set i = t_rec->cnt
		for (j=1 to size(ctlists->lists,5))
			set i = (i + 1)
			set stat = alterlist(t_rec->qual,i)
			set t_rec->qual[i].list_type 	= "C"
			set t_rec->qual[i].active_ind 	= 1
			set t_rec->qual[i].list_id 		= ctlists->lists[j].pct_care_team_id
			set t_rec->qual[i].name			= concat(	 trim(uar_get_code_display(ctlists->lists[j].facility_cd))
	         	 									," - "
	         	 									,trim(ctlists->lists[j].ct_list_name))
	          										;,trim(uar_get_code_display(pct.pct_med_service_cd)))
		    if (ctlists->lists[j].facility_cd = 0.0)
	        	set t_rec->qual[i].name			= concat(trim(ctlists->lists[j].ct_list_name))
	        endif
		endfor
		set t_rec->cnt = i
	endif	
endif

declare _Memory_Reply_String = vc with public

execute mp_get_pct_care_team_config ^MINE^,0.0,0.0,0.0,t_rec->prsnl_id,0,0,-1.0 
;	with replace("REQUEST",request),replace("REPLY",reply)

;execute mp_wklist_get_care_team_lists ^MINE^,t_rec->prsnl_id

;set stat = cnvtjsontorec(_Memory_Reply_String)
;call echorecord(record_data)

call echo(_Memory_Reply_String)
set stat = cnvtjsontorec(_Memory_Reply_String)

if (validate(record_data->ct_cv_active_ind))
set i = t_rec->cnt
	for (j=1 to size(record_data->pct_teams,5))
		set i = (i + 1)
		set stat = alterlist(t_rec->qual,i)
		set t_rec->qual[i].list_type 	= "C"
		set t_rec->qual[i].active_ind 	= 1
		set t_rec->qual[i].list_id 		= record_data->pct_teams[j].orig_pct_team_id
		set t_rec->qual[i].name			= concat(	 trim(uar_get_code_display(record_data->pct_teams[j].facility_cd))
         	 									," - "
         	 									,trim(uar_get_code_display(record_data->pct_teams[j].pct_medserv_cd)))
          										;,trim(uar_get_code_display(pct.pct_med_service_cd)))
	    if (ctlists->lists[j].facility_cd = 0.0)
        	set t_rec->qual[i].name			= concat(trim(ctlists->lists[j].ct_list_name))
        endif
	endfor
	set t_rec->cnt = i
endif

;execute mp_phys_hand_get_patlists ^MINE^, t_rec->prsnl_id, 1
record 600142request (
  1 prsnl_id = f8   
) 

record 600142reply (
   1 patient_lists [* ]
     2 patient_list_id = f8
     2 name = vc
     2 description = vc
     2 patient_list_type_cd = f8
     2 owner_id = f8
     2 list_access_cd = f8
     2 arguments [* ]
       3 argument_name = vc
       3 argument_value = vc
       3 parent_entity_name = vc
       3 parent_entity_id = f8
     2 encntr_type_filters [* ]
       3 encntr_type_cd = f8
       3 encntr_class_cd = f8
     2 proxies [* ]
       3 prsnl_id = f8
       3 prsnl_group_id = f8
       3 list_access_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )

set 600142request->prsnl_id = t_rec->prsnl_id

set stat = tdbexecute(3202004, 3202004, 600142, "REC", 600142request, "REC", 600142reply)

call echorecord(600142reply)
if (validate(600142reply->patient_lists))
	set i = t_rec->cnt
	for (j=1 to size(600142reply->patient_lists,5))
		set i = (i + 1)
		set stat = alterlist(t_rec->qual,i)
		set t_rec->qual[i].list_type 	= "P"
		set t_rec->qual[i].list_id 		= 600142reply->patient_lists[j].patient_list_id
		set t_rec->qual[i].name			= 600142reply->patient_lists[j].name
		
		select
		    dpl.patient_list_id
		    ,dpl.name 
		from
		     detail_prefs dp
		    ,dcp_patient_list dpl
		    ,name_value_prefs nvp
		plan dpl
		    where dpl.patient_list_id = t_rec->qual[i].list_id
		join nvp
		    where cnvtreal(nvp.pvc_value) = dpl.patient_list_id
		    and   nvp.parent_entity_name = "DETAIL_PREFS"
		    and   cnvtupper(nvp.pvc_name) = "PATIENTLISTID"
		    and   nvp.active_ind = 1
		join dp
		    where dp.detail_prefs_id = nvp.parent_entity_id
		    and dp.view_name = "PATLISTVIEW"
		    and dp.view_seq > 0
		    and dp.prsnl_id = t_rec->prsnl_id
		    and dp.active_ind = 1
		order by
			   dpl.name
			  ,dpl.patient_list_id
		head dpl.patient_list_id
			t_rec->qual[i].active_ind = 1
		with nocounter
	endfor
	set t_rec->cnt = i
endif

FREE RECORD request
  RECORD request (
    1 query = vc
    1 parameters [* ]
      2 name = vc
      2 value = vc
      2 datatype = i2
    1 context [* ]
      2 value = vc
    1 misc [* ]
      2 value = vc
    1 options [* ]
      2 option = vc
    1 returndata = i2
  ) WITH persistscript,protect
      
execute CCL_PROMPT_API_DATASET "all"
  

call echo(build(trim(curprog),":","setting CCL_PROMPT_API_DATASET"))

;Initialize variable to reference rows in the data set
declare RecNum = i4 with NoConstant(0),Protect
;Initialize variable to the number of people in the record structure list
declare tcnt = i4 with NoConstant(t_rec->cnt),Protect
;Initialize variable to use in a for loop
declare lcnt = i4 with NoConstant(0),Protect

call echo(build(trim(curprog),":","Initialize the data set"))
;Initialize the data set
set stat = MakeDataSet(100)

call echo(build(trim(curprog),":","Define fields in the data set"))
;Define fields in the data set
set vLISTID			= AddRealField("LISTID","List ID:", 1)
;set vLISTTYPE 		= AddStringField("LISTTYPE","Type", 1, 25)
set vLISTNAME 		= AddStringField("LISTNAME","Name:", 1, 75)

;Populate the data set
for (lcnt = 1 to tcnt)	
 if (t_rec->qual[lcnt].active_ind = 1)
	/*Set RecNum equal to the next available row in the data set and add positions to the data set buffer if needed. */
	set RecNum = GetNextRecord(0)
	
	if (t_rec->qual[lcnt].list_type in("M","C"))
		set t_rec->qual[lcnt].list_type_full = "Care Team"
	else
		set t_rec->qual[lcnt].list_type_full = "Patient List"
	endif
	
	/*Move information from the Person record structure into the data set */
	set stat = SetRealField  (RecNum, vLISTID, 			t_rec->qual[lcnt].list_id )
	;set stat = SetStringField(RecNum, vLISTTYPE,		t_rec->qual[lcnt].list_type_full)
	;set stat = SetStringField(RecNum, vLISTNAME,		concat( trim(cnvtstring(lcnt)),". ",t_rec->qual[lcnt].name, " (",
	set stat = SetStringField(RecNum, vLISTNAME,		concat( t_rec->qual[lcnt].name, " (",
																trim(t_rec->qual[lcnt].list_type_full),")"))
 endif
endfor

;Close the data set
set stat = CloseDataSet(0)

call echorecord(t_rec)

end
go
