 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:
  Solution:
  Source file name:   cov_rm_pmdoc_test.prg
  Object name:        cov_rm_pmdoc_test
  Request #:
 
  Program purpose:
 
  Executing from:     CCL
 
  Special Notes:      Called by ccl program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   			  Chad Cummings			initial build
******************************************************************************/
drop program cov_rm_pmdoc_test go
create program cov_rm_pmdoc_test
 
prompt
	"FILENAME" = ""
 
with FILENAME
 
 
set modify maxvarlen 268435456
 
if ($filename = "")
	DECLARE FILEPATH = VC WITH CONSTANT( "cust_script:pm_doc_test.json" )
else
	DECLARE FILEPATH = VC WITH CONSTANT($FILENAME )
endif
 
free set request
 
declare line_in = gvc
 
FREE DEFINE RTL3
DEFINE RTL3 IS FILEPATH
select into "nl:"
from rtl3t r
detail
	line_in = concat(line_in,r.line)
with nocounter
 
;call echo(line_in)
 
set stat = cnvtjsontorec(line_in)
 
set request->destination[1].program_name = "cov_rm_Spool_Labels"
 
;set stat = tdbexecute(100020,100021,114557,"REC",request,"REC",rec_reply)
execute pm_prt_documents
 
call echorecord(reply)
 
end go
 
