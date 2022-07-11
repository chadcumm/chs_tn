/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/02/2021
  Solution:
  Source file name:   cov_std_log_routines.prg
  Object name:        cov_std_log_routines
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
drop program cov_std_log_routines:dba go
create program cov_std_log_routines:dba
 
call echo(build2("starting ",trim(cnvtlower(curprog))))
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect
 
/* Global Variables */
declare	cSystemPrsnlID = f8 with noconstant(1.0), protect, persist
 
/* Subroutines */
/**********************************************************************************************************************
** Function START_PROGRAM_LOG()
** ---------------------------------------------------------------------------------------
** Setup the the PROGRAM_LOG record structure and set initial values.  Returns a 0 if program_log is already setup
** and a 1 if the record was created and the inital variables set
**********************************************************************************************************************/
declare start_program_log(null) = i2 with persist, copy
subroutine start_program_log(null)
 
declare vRetSuccess = i2 with noconstant(FALSE)
 
if (not(validate(program_log)))
	record program_log
		(
		 1 produce_log				= i4	;0 to start a log, 1 to not create a log
		 1 produce_audit			= i4	;0 to start a log, 1 to not create a log
		 1 curdomain				= vc	;store the current domain
		 1 curprog					= vc	;current program
		 1 curnode					= vc	;current node the program is running from
		 1 display_on_exit			= i4	;display audit log on exit if 1
		 1 run_from_ops				= i4	;set to 1 if run from ops
		 1 run_from_eks				= i4 	;set to 1 if the script is executed from a rule
		 1 ops_request				= f8	;ops request number
		 1 ops_date					= dq8	;ops date
		 1 email							;list of email addresses
		  2 subject					= vc	;subject of the email
		  2 qual[*]							;array
		   3 email_address  		= vc	;email address to email
		 1 files							;files used in the program
		  2 cclscratch				= vc	;path to domain cclscratch
		  2 ccluserdir				= vc	;path to domain ccluserdir
		  2 filename_log 			= vc	;log filename
		  2 filename_log_full		= vc
		  2 filename_zip			= vc	;zip filename
		  2 filename_audit 			= vc	;audit filename
		  2 filename_audit_zip		= vc	;audit zip filename
		  2 attachments_cnt			= i4	;number of attachments
		  2 attachments[*]
		   3 file_path				= vc	;path to attachments
		   3 filename				= vc    ;file_names
		1 log_cnt					= i4	;log timers 
		1 log_qual[*]
		 2 log_dt_tm				= dq8
		 2 start_dt_tm			 	= dq8
		 2 end_dt_tm				= dq8
		 2 hundseconds_diff			= f8
		 2 log_display				= vc
		1 script_cnt				= i4
		1 script_qual[*]			
		 2 object_name				= vc
		 2 date_time_added			= dq8
	) with persist
 
	set program_log->curdomain				= cnvtlower(trim(curdomain))
	set program_log->curprog				= cnvtlower(trim(curprog))
	set program_log->curnode				= cnvtlower(trim(curnode))
	set program_log->files.cclscratch		= build("/cerner/d_",cnvtlower(trim(curdomain)),"/cclscratch/")
	set program_log->files.ccluserdir		= build("/cerner/d_",cnvtlower(trim(curdomain)),"/ccluserdir/")
	set program_log->files.filename_log 	= build(
												 cnvtlower(trim(curdomain))
												,"_",cnvtlower(trim(curprog))
												,"_",format(cnvtdatetime(sysdate)
												,"yyyy_mm_dd_hh_mm_ss;;d")
												,".log"
											)
	set program_log->files.filename_log_full = build(
														 program_log->files.cclscratch
														,program_log->files.filename_log
													)
	
	set stat = add_script_to_log(curprog)
	
	set vRetSuccess = TRUE
else
	set stat = add_script_to_log(curprog)
endif
	return (vRetSuccess)
end
 

/**********************************************************************************************************************
** Function ADD_SCRIPT_TO_LOG(sOBJECT)
** ---------------------------------------------------------------------------------------
** Add an object to the program_log.  Helpful in auditing when multipple sub programs are called
**********************************************************************************************************************/
declare add_script_to_log(sObject) = i2 with persist, copy
subroutine add_script_to_log(sObject)
	if (validate(program_log))
		set program_log->script_cnt = (program_log->script_cnt + 1)
		set stat = alterlist(program_log->script_qual,program_log->script_cnt)
		set program_log->script_qual[program_log->script_cnt].object_name = sObject
		set program_log->script_qual[program_log->script_cnt].date_time_added = cnvtdatetime(sysdate)
	endif
end

 
/**********************************************************
** Function GET_DMINFO_DATE()                            **
** ----------------------------                          **
** Returns the INFO_DATE for a given DOMAIN/NAME key.    **
** Parameters are for fields INFO_DOMAIN & INFO_NAME.    **
**********************************************************/
declare    get_dminfo_date(sdomain, sname) = dq8 with persist, copy
subroutine get_dminfo_date(sdomain, sname)
  declare dtatgdminfovalue 	= dq8 with protect, noconstant
 
  select into "nl"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  detail
    dtatgdminfovalue = cnvtdatetime(di.info_date)
  with nocounter
 
  return (dtatgdminfovalue)
end

;==========================================================================================
; Capture and report logging for debug and testing
; pMessage = Message to log
; pParam = if set to 'record' then the pMessage is a record structure to be echorecord
; 
; USAGE: call SubroutineLog("record_structure","RECORD") 
;        call SubroutineLog("Log Message") 
;==========================================================================================
declare SubroutineLog(pMessage=vc,pParam=vc(value,'message')) = null with copy, persist
subroutine SubroutineLog(pMessage,pParam)
    declare vMessage = vc with constant(pMessage), protect
    declare vParam = vc with constant(pParam), protect
    declare vEchoParser = vc with noconstant(" "), protect

    if (SubroutineDebug(0)) ;check to make sure debug is on first
        if (cnvtupper(vParam) = cnvtupper('RECORD')) ;check to see if the message is actually a record structure
            set vEchoParser = concat(^call echorecord(^,trim(vMessage),^) go^)
            call echo(trim(vEchoParser))
            call parser(vEchoParser)
        else
            call echo(trim(vMessage))
        endif
    endif
end ;SubroutineLog 

;==========================================================================================
; Check if the debug_ind variable is defined and set to 1 to turn on echos
; 
; USAGE: set DEBUG = SubroutineDebug(null)
;==========================================================================================
declare SubroutineDebug(null) = i2 with copy, persist
subroutine SubroutineDebug(null)
    declare pDebugVar = f8 with noconstant(FALSE), protect

    if (validate(debug_ind))
        if (debug_ind > 0)
            set pDebugVar = TRUE
        endif
    endif
    return (pDebugVar)
end ;SubroutineDebug



/**********************************************************************************************************************
** Function sGetUsername(person_id)
** ---------------------------------------------------------------------------------------
** Returns the username associated to the person_id supplied
**********************************************************************************************************************/
declare sGetUsername(vPersonID=f8) = vc  with copy, persist
subroutine sGetUsername(vPersonID)

	declare vReturnUsername = vc with protect
	
	select into "nl:"
	from
		prsnl p
	plan p
		where p.person_id = vPersonID
	detail
		vReturnUsername = p.username
	with nocounter
	
	return (vReturnUsername)
end




/**********************************************************************************************************************
** Function add_eks_log_message(message)
** ---------------------------------------------------------------------------------------
** sets up and/or adds log message for use in EKS
**********************************************************************************************************************/

declare add_eks_log_message(vMessage = vc) = null 
subroutine add_eks_log_message(vMessage)

	if not(validate(eks_log))
		record eks_log	(
			1 log_message = vc
		)
	endif
	set eks_log->log_message = concat(
										trim(eks_log->log_message),";",
										trim(vMessage)
									)
end ;add_log_message

call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
