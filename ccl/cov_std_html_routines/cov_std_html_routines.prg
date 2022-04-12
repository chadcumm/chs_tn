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

execute cov_std_log_routines
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect
 
/* Subroutines */
/**********************************************************************************************************************
** Function PUT_HTML_OUTPUT()
** ---------------------------------------------------------------------------------------
** Put HTML content to the supplied output
**********************************************************************************************************************/
declare put_html_output(vOutput=vc,vContent=gvc(VALUE,"<html>Failure</html>")) = null with persist, copy
subroutine put_html_output(vOutput,vContent)
	
	free record putrequest
	record putrequest (
	 
	     1 source_dir = vc
	     1 source_filename = vc
	     1 nbrlines = i4
	     1 line [* ]
	       2 linedata = vc
	     1 overflowpage [* ]
	       2 ofr_qual [* ]
	         3 ofr_line = vc
	     1 isblob = c1
	     1 document_size = i4
	     1 document = gvc
	)
	 
	set putrequest->source_dir	 	=  vOutput
	set putrequest->isblob 			= "1"
	set putrequest->document 		= vContent
	set putrequest->document_size 	= size(putrequest->document)
	
	execute eks_put_source with replace ("REQUEST" ,putrequest ) , replace ("REPLY" ,putreply ) 

end



/**********************************************************************************************************************
** Function GET_HTML_TEMPLATE(vFilename,vDirectory[cust_script])
** ---------------------------------------------------------------------------------------
** Open an HTML template from the default (cust_script) or supplied directory and return the HTML as a string
**
** NOTE: Currently the directory variable requires the logical version with the trailing colon (ccluserdir:)
**********************************************************************************************************************/
declare get_html_template(vFilename=vc,vDirectory=vc(VALUE,"cust_script:")) = gvc with persist, copy
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



/**********************************************************************************************************************
** Function GET_CONTENT_SERVICE_URL(null)
** ---------------------------------------------------------------------------------------
** Get the base URL for the MPage static content
**
**********************************************************************************************************************/
declare get_content_service_url(null) = vc with persist, copy
subroutine get_content_service_url(null)
	
	declare vReturnURL = vc with noconstant("http://<notfound>"), protect
	
	select into "nl:"
	from
		dm_info di
	plan di
		where di.info_name = "CONTENT_SERVICE_URL"
	detail
		vReturnURL = di.info_char
	with nocounter 
	
	return (vReturnURL)
end


/**********************************************************************************************************************
** Function GET_STATIC_CONTENT_BASE(null)
** ---------------------------------------------------------------------------------------
** Get the base front-end file share for the MPage static content
**
**********************************************************************************************************************/
declare get_static_content_base(null) = vc with persist, copy
subroutine get_static_content_base(null)
	
	declare vReturnURL = vc with noconstant("I:/Winintel/static_content"), protect
	
	select into "nl:"
	from
		dm_info di
	plan di
		where di.info_name = "FE_WH"
		and   di.info_domain = "INS"
	detail
		vReturnURL = concat(
							trim(di.info_char)
							,"Winintel/static_content"
							)
	with nocounter 
	
	return (vReturnURL)
end


/**********************************************************************************************************************
** Function BUILD_PATIENTDATA(person_id,encntr_id)
** ---------------------------------------------------------------------------------------
** Return JSON string for PATIENTDATA based on provided person_id and encntr_id
**
**********************************************************************************************************************/
declare build_patientdata(vPersonID=f8,vEncntrID=f8) = vc with persist, copy
subroutine build_patientdata(vPersonID,vEncntrID)
	
	declare vReturnPatientData = vc with protect
	
	set vReturnPatientData = build(
										vPersonID
									,"|",
										vEncntrID
							 	 )
								
	return (vReturnPatientData)
end


/**********************************************************************************************************************
** Function REPLACE_HTML_TOKEN(html,token,content)
** ---------------------------------------------------------------------------------------
** return string after replacing the token with the provided content
**
**********************************************************************************************************************/
declare replace_html_token(vHTML=gvc,vToken=vc,vContent=vc) = gvc with persist, copy
subroutine replace_html_token(vHTML,vToken,vContent)
	
	declare vReturnHTML = gvc with protect
	
	set vReturnHTML = vHTML
	
	set vReturnHTML = replace(vReturnHTML,vToken,vContent)
								
	return (vReturnHTML)
end


/**********************************************************************************************************************
** Function ADD_PATIENTDATA(person_id,encntr_id,content)
** ---------------------------------------------------------------------------------------
** Updates the provided string by prelacing @MESSAGE:[PATIENTDATA] the proper PATIENTDATA based on provided person_id and encntr_id
**
**********************************************************************************************************************/
declare add_patientdata(vPersonID=f8,vEncntrID=f8,vContent=gvc) = gvc with persist, copy
subroutine add_patientdata(vPersonID,vEncntrID,vContent)
	
	set vContent = replace_html_token(vContent,"@MESSAGE:[PATIENTDATA]",build_patientdata(vPersonID,vEncntrID))
								
	return (vContent)
end

call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
