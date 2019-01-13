socket_client_open zadko 127.0.01 5003
fconfigure $audace(socket,client,zadko) -buffering none -blocking 0 -eofchar { ; }


socket_client_put zadko "#25;" ; after 100 ; socket_client_get zadko



# === pointage 17h -10d
socket_client_put zadko "#6,17,-10;" ; after 100 ; socket_client_put zadko "#12;"

socket_client_close zadko

socket_client_put zadko "#25;" ; after 100 ; read $audace(socket,client,zadko)
# #1.339175,15.999938,-10.000475,2008.500000,1.136131,17.339114,9.910129,2008.704437;

socket_client_put zadko "#26;" ; after 100 ; read $audace(socket,client,zadko)
# #5,228,0;

socket_client_put zadko "#28;" ; after 100 ; read $audace(socket,client,zadko)
# #16.000000,-10.000000,15.999889,-10.000483,1.346667;

# === park the telescope
socket_client_put zadko "#14,0,0,0,0;" ; after 100 ; socket_client_put zadko "#10;" ; after 100 ; socket_client_put zadko "#12;"

# === unpark the telescope,
socket_client_put zadko "#14,15.000,0,14.876,0;" 


socket_client_put zadko "#29,0;"


set octet 255
set pos 7 ; set bos pow(2,$pos) ; set bos [expr pow(2,$pos)] ; set b [expr int(floor($octet/$bos))] ; set octet [expr $octet-$bos*$b]

tel::create dfm com1
tel1 coord

===============================================================================

tel1 status
# { {slewing 0} {final_limit 0} {approaching_limit 0} {dome_on/off 0} {slew_enable 0} {track_on/off 1} {guide_on/off 0} {initialized 1} } { {drives_on/off 1} {rate_cor_on/off 1} {cosdec_on/off 1} {target_out_of_range 0} {dome_ok 0} {excom_on/off 0} {trailing 0} {setting 0} } { {aux._track_rate 1} {next_object_active 0} {W 0} {E 0} {S 0} {N 0} {dome_track/free 0} {slew_computing 0} } 

tel1 putread "#14,15.002,.05,14.545,0.;\r"

tel1 putread "#14,15.002,.05,13.545,0.;\r"

tel1 putread "#14,0.00,.0,13.545,0.;\r"

tel1 putread "#14,0.00,.0,0.0,0.;\r"

tel1 putread "#4,1;\r"

tel1 hadec coord
# 23h00m12s -28d26m13s

tel1 hadec coord
# 23h00m12s -28d47m40s

tel1 hadec coord
# 23h00m12s -29d41m28s

tel1 putread "#30,1;\r"

tel1 status
# { {slewing 1} {final_limit 0} {approaching_limit 0} {dome_on/off 0} {slew_enable 0} {track_on/off 1} {guide_on/off 0} {initialized 1} } { {drives_on/off 1} {rate_cor_on/off 1} {cosdec_on/off 1} {target_out_of_range 0} {dome_ok 0} {excom_on/off 0} {trailing 0} {setting 0} } { {aux._track_rate 1} {next_object_active 0} {W 0} {E 0} {S 0} {N 0} {dome_track/free 0} {slew_computing 0} } 

lindex [tel1 status] 0
#  {slewing 1} {final_limit 0} {approaching_limit 0} {dome_on/off 0} {slew_enable 0} {track_on/off 1} {guide_on/off 0} {initialized 1} 

lindex [lindex [tel1 status] 0] 0
# slewing 1

lindex [lindex [lindex [tel1 status] 0] 0] 0
# slewing

lindex [lindex [lindex [tel1 status] 0] 0] 1
# 1

lindex [lindex [lindex [tel1 status] 0] 0] 1
# 1

lindex [lindex [lindex [tel1 status] 0] 0] 1
# 1

lindex [lindex [lindex [tel1 status] 0] 0] 1
# 1

lindex [lindex [lindex [tel1 status] 0] 0] 1
# 0

lindex [lindex [lindex [tel1 status] 0] 0] 1
# 0

lindex [lindex [lindex [tel1 status] 0] 0] 1
# 0

tel1 radec goto {13h -25}

tel1 putread "#12;\r"


expr (23+56./60+4./3600)

=============== pointing modele

tel1 putread "#24;\r"
# -0.515792 14.355746 -31.281371 2000.000000 1.006758 13.839954 7.419278 2009.665298

===============================================================================

tel1 speedtrack 0 0 1
after 1000
tel1 speedtrack diurnal 0
tel1 blockingmethod 1
tel1 radec goto {12h -20} -blocking 1

tel1 speedtrack 0 0 1
after 1000
tel1 speedtrack diurnal 0
tel1 blockingmethod 1
tel1 radec goto {14h -30} -blocking 1

tel1 speedtrack 0 0

tel1 speedtrack diurnal 0


