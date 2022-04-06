
/*
;OPERATIONS -> sys_runccl (4903)
 
free record request go
record request (
	1 batch_selection = vc
	1 output_dist = vc
	1 ops_date = dq8
	) go
 
Free record reply go
record reply (
	1 ops_event = vc
%i cclsource:status_block.inc
	) go
 	
set request->batch_selection = ^COV_PHA_PRODUCTIVITY_RPT "OPS",0,"","",1.0,0^ go
set request->output_dist = "chad.cummings@covhlth.com" go
set request->ops_date = cnvtdatetime(curdate+0,curtime3) go
set reqinfo->updt_req = 3053000 go
 
execute ccl_run_program_from_ops go
 
call echorecord(reply) go
 


 
free record request go
record request (
  1 program_name = vc
  1 query_command = vc
  1 output_device = vc
  1 Is_printer = i1
  1 Is_Odbc = i1
  1 IsBlob = i1
  1 params = vc
  1 qual[*]
    2 parameter = vc
    2 data_type = i1
  1 blob_in = gvc
) go
 
set request->program_name = "cov_rpt_hrts_tt" go
;set request->output_device = "MINE" go
set request->params = ^"MINE"^ go

execute VCCL_RUN_PROGRAM go
*/

/*
select
     location = trim(uar_get_code_display(l.location_cd))
    ,l.location_cd
from
     location   l
    ,organization   o
    ,code_value_set cvs
    ,code_value cv1
    ,code_value cv2
plan cvs
    where cvs.definition            = "COVCUSTOM"
join cv1
    where cv1.code_set              = cvs.code_set
    and   cv1.definition            = trim(cnvtlower("cov_rpt_op_readiness"))   
    and   cv1.active_ind            = 1
    and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    and   cv1.end_effective_dt_tm   >= cnvtdatetime(curdate,curtime3)
    and   cv1.cdf_meaning           = "FACILITY"
join l 
    where   l.location_type_cd      = value(uar_get_code_by("MEANING",222,"FACILITY"))
    and     l.active_ind            = 1
join cv2
    where   cv2.code_value          = l.location_cd
    and     cv2.display             = cv1.display
join o 
    where o.organization_id         = l.organization_id
order by
    location
FLMC	 2552503635.00
FSR	   21250403.00
LCMC	 2552503653.00
MHHS	 2552503639.00
MMC	 2552503613.00
PW	 2552503645.00
RMC	 2552503649.00

*/

/*
set debug_ind = 1 go
execute cov_rpt_hrts_tt 
	  "OPS"
	 , 0	;all facilities
	 ;, VALUE(2552503635,21250403,2552503653,2552503639,255250361,2552503645,2552503649) ;facility cd
	 , VALUE(2552503649) ;facility cd
	 , 0 ;
	 , "21-JUL-2020 00:00:00"
	 , "22-JUL-2020 23:59:00"
	 , 0
go
*/

;"MINE", "18-AUG-2020 00:00:00", "18-AUG-2020 23:59:00", VALUE(1.0), 0
set debug_ind = 1 go
execute COV_PHA_PRODUCTIVITY_RPT
	  "MINE"
	 ,0
	 ,"06-APR-2022 00:00:00"
	 ,"06-APR-2022 23:59:00"
	 ;,VALUE(2552503613.00) ;MMC
	 ,value(1.0)
	 ,0
go
 
 

