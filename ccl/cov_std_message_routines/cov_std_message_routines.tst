declare debug_ind = i2 with constant(1) go
execute cov_std_message_routines go


declare person_id = f8 with protect go
declare encntr_id = f8 with protect go
set encntr_id = 125218607 go

set stat = add_reminder(42467509.0,
						16908168.0,
						encntr_id) go
execute cov_std_message_routines go

call echo(build2("send_discern_notification=",send_discern_notification("CCUMMIN4"))) go
