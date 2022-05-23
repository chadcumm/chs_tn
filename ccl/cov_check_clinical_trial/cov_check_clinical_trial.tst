declare link_encntrid = f8 with noconstant(0.0) go
declare link_personid = f8 with noconstant(0.0) go

select into "nl:"
from
	encntr_alias ea
	,encounter e
plan ea
	where ea.alias = "5211201313"
join e
	where e.encntr_id = ea.encntr_id
detail
	link_encntrid = e.encntr_id
	link_personid = e.person_id
with nocounter go

;http://covhppmodules.covhlth.net/ColdFusionApplications/Cerner_PopulationGroupAlert/WebService.cfc?method=fnPopulationCernerSmartZone&strStaffUserName=CCUMMIN4&strStaffCernerPosition=441&strPatientCMRN=1424710
execute cov_check_clinical_trial "fnPopulationCernerSmartZone" go