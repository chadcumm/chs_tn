/*
* Start of GLOBAL VARIABLE Section
*/

include("I:/Winintel/static_content/custom_mpage_content/jquery/jquery-3.6.0.min.js");

if (patientDataSplit.substring(0,1) == "@")	{
		var personID = 14744736.0;
		var encntrID = 125238249.0;
	} else {
		var patientData = patientDataSplit.split("|");
		var personID = patientData[0];
		var encntrID = patientData[1];
	}

/*
* End of GLOBAL VARIABLE Section
*/

function include(file) {
  
  var script  = document.createElement('script');
  script.src  = file;
  script.type = 'text/javascript';
  script.defer = true;
  
  document.getElementsByTagName('head').item(0).appendChild(script);
  
}

function InitMain()	{

	//add the debug section
	$("body").append('<div id=debug_section class=debug_font></div>');
}

function AddDebugInfo(debugText,debugID)	{

	$('<div id="'+debugID+'">'+debugText+'</div>').appendTo('#debug_section');

}

function BuildPatientBannerBar()	{

    PatientBannerBarHTML = [];
    PatientBannerBarHTML.push("<table width=100% border=0>");
    PatientBannerBarHTML.push("<tr>");
    PatientBannerBarHTML.push("<td colspan=2>");
    PatientBannerBarHTML.push("<b><span id=patient_name></span></b>");
    PatientBannerBarHTML.push("</td>");
    PatientBannerBarHTML.push("<td align=right>");
    PatientBannerBarHTML.push("MRN:<span id=patient_mrn></span>");
    PatientBannerBarHTML.push("</td>");
    PatientBannerBarHTML.push("<td align=right>");
    PatientBannerBarHTML.push("FIN:<span id=patient_fin></span>");
    PatientBannerBarHTML.push("</td>");
    PatientBannerBarHTML.push("</tr>");
    PatientBannerBarHTML.push("<tr>");
    PatientBannerBarHTML.push("<tr>");
    PatientBannerBarHTML.push("<td>");
    PatientBannerBarHTML.push("DOB:<span id=patient_dob></span>");
    PatientBannerBarHTML.push("</td>");
    PatientBannerBarHTML.push("<td>");
    PatientBannerBarHTML.push("Age:<span id=patient_age></span>");
    PatientBannerBarHTML.push("</td>");
    PatientBannerBarHTML.push("<td colspan=3 align=right>");
    PatientBannerBarHTML.push("<span id=patient_encntr_type></span>&nbsp");
    PatientBannerBarHTML.push("</td>");
    PatientBannerBarHTML.push("</tr>");
    PatientBannerBarHTML.push("<tr>");
    PatientBannerBarHTML.push("<td colspan=2>");
    PatientBannerBarHTML.push("Loc:<span id=patient_loc_room_bed></span>");
    PatientBannerBarHTML.push("</td>");
    PatientBannerBarHTML.push("<td>");
    PatientBannerBarHTML.push("<span id=patient_sex></span>");
    PatientBannerBarHTML.push("</td>");
    PatientBannerBarHTML.push("</tr>");
    PatientBannerBarHTML.push("</table>");

   	$("#patientBannerBar").html(PatientBannerBarHTML.join(''))
   	$("#patientBannerBar").addClass('banner_bar')
	
	var patientDataJSON = '{"PATIENTDATA":{"PERSON_ID":'+personID+',"ENCNTR_ID":'+encntrID+'}}';

    	var bannerObj = window.external.XMLCclRequest();
 
	bannerObj.open("GET", "cov_eks_patient_banner", false);
	bannerObj.setBlobIn(patientDataJSON);
	bannerObj.send('"MINE"');		
 
	if (bannerObj.status == 200) {

		AddDebugInfo(bannerObj.responseText,"banner bar");
 		var patientBanner = JSON.parse(bannerObj.responseText);
 		document.getElementById('patient_name').innerHTML 			=  patientBanner.PATIENT_BANNER.NAME_FULL;
 		document.getElementById('patient_dob').innerHTML 			=  patientBanner.PATIENT_BANNER.DOB;
 		document.getElementById('patient_age').innerHTML  			=  patientBanner.PATIENT_BANNER.AGE;
 		document.getElementById('patient_mrn').innerHTML  			=  patientBanner.PATIENT_BANNER.MRN;
 		document.getElementById('patient_fin').innerHTML  			=  patientBanner.PATIENT_BANNER.FIN;
 		document.getElementById('patient_encntr_type').innerHTML 		=  patientBanner.PATIENT_BANNER.ENCNTR_TYPE;
 		document.getElementById('patient_loc_room_bed').innerHTML 		=  patientBanner.PATIENT_BANNER.LOC_ROOM_BED;
 		document.getElementById('patient_sex').innerHTML 			=  patientBanner.PATIENT_BANNER.SEX;
 
	}
	else {
   		alert('XMLCclRequest failed with status of ' + bannerObj.status);
	}
 
	bannerObj.cleanup();

}

$(function(){
	$('div[onload]').trigger('onload');
});