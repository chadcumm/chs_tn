 
/*
2 SUBSTANCE_QUAL[647,769*]
   3 SOURCE_STRING=VC14   {Darvocet (all)}
   3 SOURCE_IDENTIFIER=VC6   {d03434}
   3 ALLERGY_TYPE_DISP=VC11   {Multum Drug}
   3 ALLERGY_TYPE_CD=F8   {1237.0000000000                         }
   3 SUBSTANCE_NOMEN_ID=F8   {0.0000000000                            }
   3 FREETEXT_CNT= I2   {2}
   3 SUBSTANCE_TYPE=VC4   {drug}
   3 SUBSTANCE_TYPE_CD=F8   {3288.0000000000                         }
   3 FREETEXT_QUAL[1,2*]
    4 SUBSTANCE_FTDESC=VC8   {darvocet}
   3 FREETEXT_QUAL[2,2*]
    4 SUBSTANCE_FTDESC=VC10   {darvocet-n}
   */
/* 
select into "nl:"
		 n.nomenclature_id
		,n.source_identifier
		,n.source_string
	from
		 nomenclature n
		,code_value cv1
	plan cv1
		where cv1.code_set				= 400
		and   cv1.display 				= "Multum Drug"
		and   cv1.active_ind 			= 1
	join n
		where n.source_vocabulary_cd 	= cv1.code_value
		and   n.source_identifier 		= "d03434"
		and   n.source_string			= "*"
		and	  n.active_ind				= 1
		and   cnvtdatetime(curdate,curtime3) between n.beg_effective_dt_tm and n.end_effective_dt_tm
	order by
		 n.source_identifier
		,n.beg_effective_dt_tm desc
go
*/
 
set link_encntrid = 0.0 go
set link_personid = 0.0 go
 
select into "nl:"
from encounter e,encntr_alias ea
where ea.alias = "2125900102"; "2300000001"
and e.encntr_id = ea.encntr_id
detail
link_personid = e.person_id
link_encntrid = e.encntr_id
with nocounter go
 
execute cov_upd_allergy_profile go
 
 
 
 
