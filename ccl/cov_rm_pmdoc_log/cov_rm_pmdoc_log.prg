drop program cov_rm_pmdoc_log go
create program cov_rm_pmdoc_log
 
record t_rec
(
	1 prompts
	 2 outdev		= vc
	1 files
	 2 records_attachment		= vc
)
 
set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
 
call echojson(request, concat("cclscratch:",t_rec->files.records_attachment) , 1)
execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"","CP"
 
end
go
 
