declare link_personid = f8 with noconstant(0.0) go
declare link_encntrid = f8 with noconstant(0.0) go
declare link_orderid = f8 with constant(5809889387) go

select into "nl:"
from 
	orders o
plan o
	where o.order_id = link_orderid
detail
	link_personid = o.person_id
	link_encntrid = o.encntr_id
with nocounter go

execute test_eks_send_ord_cancel_msg go
