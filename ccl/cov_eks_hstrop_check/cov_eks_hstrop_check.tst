declare link_personid = f8 with noconstant(0.0) go
declare link_encntrid = f8 with noconstant(0.0) go
declare link_orderid = f8 with noconstant(0.0) go

select into "nl:" from orders o where o.order_id = 4737807589
detail
	link_personid = o.person_id
	link_encntrid = o.encntr_id
	link_orderid = o.order_id 
with nocounter go

execute cov_eks_hstrop_check go
