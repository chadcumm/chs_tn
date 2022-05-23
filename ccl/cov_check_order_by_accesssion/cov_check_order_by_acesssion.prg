/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			
	Source file name:	cov_check_order_by_accesssion.prg
	Object name:		cov_check_order_by_accesssion
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	03/30/2021  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_check_order_by_accesssion:dba go
create program cov_check_order_by_accesssion:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "ACCESSION" = ""
	, "ATTEMPT" = 0 

with OUTDEV, ACCESSION, ATTEMPT


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 prompts
	 2 outdev				= vc
	 2 accession			= vc
	 2 attempts				= i2
	1 cnt					= i4
	1 order_id				= f8
	1 encntr_id				= f8
	1 loc_facility_cd		= f8
	1 facility				= vc
	1 order_status			= vc
	1 dept_status			= vc
	1 accession				= vc
	1 viewpoint_ind			= i2
	1 order_mnemonic		= vc
	1 send_notification_ind	= i2
	1 memory_reply_string	= vc
	1 page_sent_ind			= i2
	1 page_cnt 				= i2
	1 page_qual[*]
	  2 address				= vc
	  2 facility			= vc
	  2 viewpoint			= i2
)

free record 3051004Request 
record 3051004Request (
  1 MsgText = vc  
  1 Priority = i4   
  1 TypeFlag = i4   
  1 Subject = vc  
  1 MsgClass = vc  
  1 MsgSubClass = vc  
  1 Location = vc  
  1 UserName = vc  
) 

/*
set t_rec->page_cnt = 1
set stat = alterlist(t_rec->page_qual,t_rec->page_cnt)
set t_rec->page_qual[1].address = "8162886144@tmomail.net"
*/



declare sendNotification(null)=null

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Setting Variables **********************************"))

set t_rec->prompts.outdev 		= $OUTDEV
set t_rec->prompts.accession	= $ACCESSION
set t_rec->prompts.attempts		= $ATTEMPT

call writeLog(build2("* END   Setting Variables **********************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Checking Values ************************************"))

if (t_rec->prompts.accession = "")
	set t_rec->memory_reply_string = "No Acccession Number Sent"
	set reply->status_data->status = "F"
	go to exit_script
endif

call writeLog(build2("* END   Checking Values ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Order **************************************"))

select
	into "nl:"
from
	 accession_order_r aor
	,accession a
	,orders o
plan a
	where a.accession = t_rec->prompts.accession
join aor
	where aor.accession_id = a.accession_id
join o
	where o.order_id = aor.order_id
order by
	o.order_id
head o.order_id
	t_rec->order_id			= o.order_id
	t_rec->order_status		= uar_get_code_display(o.order_status_cd)
	t_rec->dept_status		= uar_get_code_display(o.dept_status_cd)
	t_rec->order_mnemonic	= o.order_mnemonic
	t_rec->accession		= cnvtacc(a.accession)
	t_rec->encntr_id		= o.encntr_id
	if (t_rec->accession = "*-CA-*")
		t_rec->viewpoint_ind = 1
	endif
with nocounter

if (t_rec->order_id = 0.0)
	set t_rec->memory_reply_string = concat("No Orders Found Related to Accession ",trim(t_rec->prompts.accession))
	set reply->status_data->status = "Z"
	go to exit_script
endif

if (t_rec->order_status not in("Ordered"))
	set t_rec->memory_reply_string = concat(
												; trim(t_rec->order_mnemonic)
												;," (",trim(t_rec->prompts.accession),")"
												;," is in a "
												"Order "
												,trim(t_rec->order_status)
												;," status")
												)
	set reply->status_data->status = "Z"
	go to exit_script
endif

call writeLog(build2("* END   Finding Order **************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Check Status and Attempts **************************"))

if (t_rec->dept_status not in("Exam Completed"))
	if (t_rec->prompts.attempts >= 4)
		set t_rec->send_notification_ind = 4
	elseif (t_rec->prompts.attempts = 1)
		set t_rec->send_notification_ind = 1
	endif
endif

call writeLog(build2("* END   Check Status and Attempts **************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Getting Encounter Information *********************"))

select into "nl:"
from
	encounter e
plan e
	where e.encntr_id = t_rec->encntr_id
detail
	t_rec->loc_facility_cd = e.loc_facility_cd
	t_rec->facility = uar_get_code_display(e.loc_facility_cd)
with nocounter

call writeLog(build2("* END    Getting Encounter Information *********************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Setting up Distribution ****************************"))

set t_rec->page_cnt = 39
set stat = alterlist(t_rec->page_qual,t_rec->page_cnt)
set t_rec->page_qual[1].address   = "lcrowe@CovHlth.com"
set t_rec->page_qual[1].facility  = "FSR FSW Diagn"
set t_rec->page_qual[2].address   = "8655974186@usamobility.net"
set t_rec->page_qual[2].facility  = "FSR"
set t_rec->page_qual[3].address   = "lscott@CovHlth.com"
set t_rec->page_qual[3].facility  = "FSR"
set t_rec->page_qual[4].address   = "PShnider@CovHlth.com"
set t_rec->page_qual[4].facility  = "FSR"
set t_rec->page_qual[5].address   = "8652543098@uscc.textmsg.com" ;@uscc.textmsg.com
set t_rec->page_qual[5].facility  = "LCMC"
set t_rec->page_qual[6].address   = "THuskey@CovHlth.com"
set t_rec->page_qual[6].facility  = "LCMC"
set t_rec->page_qual[7].address   = "ehuff@CovHlth.com"
set t_rec->page_qual[7].facility  = "LCMC"
set t_rec->page_qual[8].address   = "8655972640@usamobility.net"
set t_rec->page_qual[8].facility  = "FLMC"
set t_rec->page_qual[9].address   = "rbolin@CovHlth.com"
set t_rec->page_qual[9].facility  = "FLMC"
set t_rec->page_qual[10].address  = "8655973386@usamobility.net"
set t_rec->page_qual[10].facility = "MMC"
set t_rec->page_qual[11].address  = "8655972459@usamobility.net"
set t_rec->page_qual[11].facility = "MMC"
set t_rec->page_qual[12].address  = "tleinart@CovHlth.com"
set t_rec->page_qual[12].facility = "MMC"
set t_rec->page_qual[13].address  = "mmanfred@CovHlth.com"
set t_rec->page_qual[13].facility = "MMC"
set t_rec->page_qual[14].address  = "4237142647@page.americanmessaging.net" ;@page.americanmessaging.net
set t_rec->page_qual[14].facility = "MHHS"
set t_rec->page_qual[15].address  = "eblomenb@CovHlth.com"
set t_rec->page_qual[15].facility = "MHHS"
set t_rec->page_qual[16].address  = "krayburn@CovHlth.com"
set t_rec->page_qual[16].facility = "MHHS"
set t_rec->page_qual[17].address  = "8656600686@uscc.textmsg.com" ;@uscc.textmsg.com
set t_rec->page_qual[17].facility = "PW"
set t_rec->page_qual[18].address  = "rtipton@CovHlth.com"
set t_rec->page_qual[18].facility = "PW"
set t_rec->page_qual[19].address  = "tburche1@CovHlth.com"
set t_rec->page_qual[19].facility = "PW"
set t_rec->page_qual[20].address  = "8655971788@usamobility.net"
set t_rec->page_qual[20].facility = "RMC"
set t_rec->page_qual[21].address  = "Abuck@CovHlth.com"
set t_rec->page_qual[21].facility = "RMC"

set t_rec->page_qual[22].address  = "dwalker8@covhlth.com"
set t_rec->page_qual[22].facility = "RMC"
set t_rec->page_qual[22].viewpoint = 1
set t_rec->page_qual[23].address  = "8658501791@usamobility.net"
set t_rec->page_qual[23].facility = "RMC"
set t_rec->page_qual[23].viewpoint = 1
set t_rec->page_qual[24].address  = "sdoughty@covhlth.com"
set t_rec->page_qual[24].facility = "MMC"
set t_rec->page_qual[24].viewpoint = 1
set t_rec->page_qual[25].address  = "8655678331@usamobility.net"
set t_rec->page_qual[25].facility = "MMC"
set t_rec->page_qual[25].viewpoint = 1
set t_rec->page_qual[26].address  = "sriddley@CovHlth.com"
set t_rec->page_qual[26].facility = "PW"
set t_rec->page_qual[26].viewpoint = 1
set t_rec->page_qual[27].address  = "cwindham@covhlth.com"
set t_rec->page_qual[27].facility = "PW"
set t_rec->page_qual[27].viewpoint = 1
set t_rec->page_qual[28].address  = "wshock@CovHlth.com"
set t_rec->page_qual[28].facility = "PW"
set t_rec->page_qual[28].viewpoint = 1
set t_rec->page_qual[29].address  = "8655972035@usamobility.net"
set t_rec->page_qual[29].facility = "PW"
set t_rec->page_qual[29].viewpoint = 1
set t_rec->page_qual[30].address  = "jjohns14@CovHlth.com"
set t_rec->page_qual[30].facility = "FSR"
set t_rec->page_qual[30].viewpoint = 1
set t_rec->page_qual[31].address  = "rbrown21@CovHlth.com"
set t_rec->page_qual[31].facility = "FSR"
set t_rec->page_qual[31].viewpoint = 1
set t_rec->page_qual[32].address  = "8655973488@usamobility.net"
set t_rec->page_qual[32].facility = "FSR"
set t_rec->page_qual[32].viewpoint = 1
set t_rec->page_qual[33].address  = "rbolin@CovHlth.com"
set t_rec->page_qual[33].facility = "FLMC"
set t_rec->page_qual[33].viewpoint = 1
set t_rec->page_qual[34].address  = "8655972640@usamobility.net"
set t_rec->page_qual[34].facility = "FLMC"
set t_rec->page_qual[34].viewpoint = 1
set t_rec->page_qual[35].address  = "edavidso@CovHlth.com"
set t_rec->page_qual[35].facility = "LCMC"
set t_rec->page_qual[35].viewpoint = 1
set t_rec->page_qual[36].address  = "thuskey@covhlth.com"
set t_rec->page_qual[36].facility = "LCMC"
set t_rec->page_qual[36].viewpoint = 1
set t_rec->page_qual[37].address  = "8652163275@usamobility.net"
set t_rec->page_qual[37].facility = "LCMC"
set t_rec->page_qual[37].viewpoint = 1
set t_rec->page_qual[38].address  = "bhensle4@CovHlth.com"
set t_rec->page_qual[38].facility = "MHHS"
set t_rec->page_qual[38].viewpoint = 1
set t_rec->page_qual[39].address  = "4239733316@@usamobility.net"
set t_rec->page_qual[39].facility = "MHHS"
set t_rec->page_qual[39].viewpoint = 1

/*
set t_rec->page_qual[].address  = ""
set t_rec->page_qual[].facility = ""
set t_rec->page_qual[].viewpoint = 1
*/


call writeLog(build2("* END   Setting up Distribution ****************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Set Department Status for Return *******************"))

set t_rec->memory_reply_string = t_rec->dept_status

call writeLog(build2("* END   Set Department Status for Return *******************"))
call writeLog(build2("************************************************************"))

if (t_rec->send_notification_ind = 1)
	call sendNotification(0)
elseif (t_rec->send_notification_ind = 4)
	call sendNotification(0)
endif

subroutine sendNotification(null)
	call echo("sendNotification")
	
	if (t_rec->send_notification_ind = 1)
		set 3051004Request->Subject = "Incomplete Exam"
		set 3051004Request->MsgText = concat("Please complete (",t_rec->accession
											,"). The system will make 3 more attempts to resend report.")
	elseif (t_rec->send_notification_ind = 4)
		set 3051004Request->Subject = "Report failure"
		set 3051004Request->MsgText = concat("(",t_rec->accession,") report failed not completed within timeframe.")
	endif

	for (i=1 to t_rec->page_cnt)
		if ((t_rec->page_qual[i].facility = t_rec->facility) and (t_rec->page_qual[i].viewpoint = t_rec->viewpoint_ind))
			call writeLog(build2("sending notification to ",t_rec->page_qual[i].address," for ",t_rec->page_qual[i].facility))
			set t_rec->page_sent_ind = 1
			call uar_send_mail (NullTerm(t_rec->page_qual[i].address),
                                NullTerm(3051004Request->Subject),
                                NullTerm(3051004Request->MsgText),
                                NullTerm("eCare@covhlth.net"),
                                5,
                                "IPM.Note")
                           
            
		endif
	endfor

	if (t_rec->viewpoint_ind = 1)
		set 3051004Request->Subject = concat(3051004Request->Subject,"->ViewPoint Specific Message")
	endif
	
	if (cnvtupper(curdomain) != "P0665")
		set 3051004Request->Subject = concat(3051004Request->Subject," (",trim(curdomain),")")
	endif
	
	call writeLog(build2("sending default notification chad"))
	call uar_send_mail (NullTerm("chad.cummings@covhlth.com"),
                                NullTerm(3051004Request->Subject),
                                NullTerm(3051004Request->MsgText),
                                NullTerm("eCare@covhlth.net"),
                                5,
                                "IPM.Note")
	
	call writeLog(build2("sending default notification paula"))
	call uar_send_mail (NullTerm("pfische1@CovHlth.com"),
                                NullTerm(3051004Request->Subject),
                                NullTerm(3051004Request->MsgText),
                                NullTerm("eCare@covhlth.net"),
                                5,
                                "IPM.Note")
    call writeLog(build2("sending default notification carlos"))
	call uar_send_mail (NullTerm("ccarrasq@CovHlth.com"),
                                NullTerm(3051004Request->Subject),
                                NullTerm(3051004Request->MsgText),
                                NullTerm("eCare@covhlth.net"),
                                5,
                                "IPM.Note")
							
	;set t_rec->return_value = "TRUE"
end ;sendNotification

set reply->status_data->status = "Z"

if (t_rec->page_sent_ind = 1)
	call addEmailLog("chad.cummings@covhlth.com")
	set reply->status_data->status = "S"
endif



#exit_script
call writeLog(build2(cnvtrectojson(t_rec)))

set _memory_reply_string = t_rec->memory_reply_string

call exitScript(null)

call echorecord(code_values)
call echorecord(program_log)
call echorecord(t_rec)
call echorecord(reply)
end
go
