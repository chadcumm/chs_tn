 
;OPERATIONS -> sys_runccl (4903)
set debug_ind = 1 go 
free record request go
record request (
	1 batch_selection = vc
	1 output_dist = vc
	1 ops_date = dq8
	) with protect go
 
Free record reply go
record reply (
	1 ops_event = vc
%i cclsource:status_block.inc
	) with protect go
 
set request->batch_selection = "cov_hstrop_process_ops" go
set request->output_dist = "chad.cummings@covhlth.com" go
set request->ops_date = cnvtdatetime(curdate+0,curtime3) go
set reqinfo->updt_req = 4903 go
 
 
execute sys_runccl go
 
call echorecord(reply) go
 
/*
 
 
 
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
 
set request->program_name = "CCL_TEMPLATE" go
;set request->output_device = "MINE" go
set request->params = ^"MINE"^ go
 
execute VCCL_RUN_PROGRAM go
*/
 
;execute CCL_TEMPLATE "MINE"  go
 
 
 
 
