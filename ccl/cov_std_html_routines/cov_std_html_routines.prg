/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/02/2021
  Solution:
  Source file name:   cov_std_html_routines.prg
  Object name:        cov_std_html_routines
  Request #:
 
  Program purpose:
 
  Executing from:     CCL
 
  Special Notes:      Additional Required Scripts:
 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   12/02/2021  Chad Cummings			initial build
******************************************************************************/
drop program cov_std_html_routines:dba go
create program cov_std_html_routines:dba
 
call echo(build2("starting ",trim(cnvtlower(curprog))))
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect
 
/* Subroutines */
/**********************************************************************************************************************
** Function GET_HTML_TEMPLATE(vFilename,vDirectory[cust_script])
** ---------------------------------------------------------------------------------------
** Open an HTML template from the default (cust_script) or supplied directory and return the HTML as a string
**
** NOTE: Currently the directory variable requires the logical version with the trailing colon (ccluserdir:)
**********************************************************************************************************************/
declare get_html_template(vFilename=vc,vDirectory=vc(VALUE,"cust_script:")) = i2 with persist, copy
subroutine get_html_template(vFilename,vDirectory)
 
	declare vReturnHTML = gvc with protect

	free record 3011001_request
	record 3011001_request (
	  1 module_dir = vc
	  1 module_name = vc
	  1 basblob = i2
	)
	 
	set 3011001_request->module_dir = vDirectory
	set 3011001_request->module_name = vFilename
	set 3011001_request->basblob = 1
	 
	free record 3011001_reply
	
	set stat = tdbexecute(3010000,3011002,3011001,"REC",3011001_request,"REC",3011001_reply)
	 
	if (validate(3011001_reply))
		if (3011001_reply->status_data.status = "S")
			set vReturnHTML = 3011001_reply->data_blob
		endif
	endif
 
	return (vReturnHTML)
end
 

call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go