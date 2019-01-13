# Script goto_telescope
# This script will be sourced in the loop
# ---------------------------------------
# Goal of the script :
#
# Slew the telescope to the target if robobs(next_scene,action) = "science"
# 
# ---------------------------------------
# Input variables, other than robobs(conf,*) :
#
# robobs(next_scene,action) : updated in loopscript_next_scene
# robobs(next_scene,ra) : RA to point the center of the FoV of the camera (degrees J2000)
# robobs(next_scene,dec) : DEC to point the center of the FoV of the camera (degrees J2000) 
# robobs(next_scene,dra) : Drift againt the RA coordinates (deg/sec)
# robobs(next_scene,ddec) : Drift againt the DEC coordinates (deg/sec)
#
# ---------------------------------------
# Output variables :
#
# None
#
# ---------------------------------------


# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

set diurnal [expr 360./(23*3600+56*60+4)] ; # deg/sec

# === Body of script

if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
	# --- check the integrity of the encoders and solve the problem if possible
	set res [telcheck checkonly]
	if {$res!=""} {
		::robobs::log "Check of encoders PB. $res" 3						
		::robobs::log "Launch telcheck resolve. Wait..." 3						
		set res [telcheck resolve]
		::robobs::log "$res" 3						
	} else {
		::robobs::log "Check of encoders OK." 3						
	}
}

if {$robobs(next_scene,action)!="none"} {
   set sql_mjd1 [expr [mc_date2jd now]-2400000.5]

	# --- read goto parameters
	set do_slew 1
	if {$robobs(next_scene,slew)==""} {
		set do_slew 0
	}
	set type [::robobs::key2val $robobs(next_scene,slew) type]
	if {($type=="")} {
		set do_slew 0
	} elseif {($type=="radec")} {
		set ra [::robobs::key2val $robobs(next_scene,slew) ra]
		set dec [::robobs::key2val $robobs(next_scene,slew) dec]
		if {($ra=="")||($dec=="")} {
			set do_slew 0
		}
	} elseif {($type=="hadec")} {
		set ha [::robobs::key2val $robobs(next_scene,slew) ha]
		set dec [::robobs::key2val $robobs(next_scene,slew) dec]
		if {($ha=="")||($dec=="")} {
			set do_slew 0
		}
	}
	
	if {$do_slew==1} {
		set dra [::robobs::key2val $robobs(next_scene,slew) dra] ; # dra*cos(DEC) ("/s)
		if {$dra==""} { set dra 0 }
		set ddec [::robobs::key2val $robobs(next_scene,slew) ddec] ; # dDEC ("/s)
		if {$ddec==""} { set ddec 0 }
		# --- convert dra->speedha (deg/sec) and ddec->speeddec (deg/sec)
		# ::robobs::log "dra=$dra ddec=$ddec diurnal=$diurnal"
		set speedha [expr -$dra/cos([mc_angle2rad $dec 90])/3600.+$diurnal]
		set speeddec [expr -$ddec/3600.]
		# ::robobs::log "speedha=$speedha speeddec=$speeddec"
		# --- set trackspeed
		set track diurnal
		if {$robobs(tel,name)!="simulation"} {
			if {([expr abs($speedha-$diurnal)/$diurnal]>1e-6)||([expr abs($speeddec)/$diurnal]>1e-6)} {
				set track specific
				set err [catch {tel1 speedtrack $speedha $speeddec} msg]
				if {$err==0} {
					::robobs::log "tel1 speedtrack $speedha $speeddec"
				}
			} else {
				set err [catch {tel1 speedtrack diurnal $ddec} msg]
				if {$err==0} {
					::robobs::log "tel1 speedtrack diurnal 0"
				}
			}
		}
		# --- goto
		set tospeak "Pointe le télescope."
		catch {exec espeak.exe -v fr "$tospeak"}			
		if {$type=="radec"} {
			::robobs::log "tel1 radec goto [list $ra $dec] -blocking 1" 3
			set t0 [clock seconds]
			if {$robobs(tel,name)=="simulation"} {
				after 3000
			} else {
				tel1 radec goto [list $ra $dec] -blocking 1
				set sortie 0
				set radec0 ""
				after 500
				if {$track=="diurnal"} {
					set sortie 1
				}
				while {$sortie==0} {
					update
					after 500
					set radec [tel1 radec coord]
					::robobs::log "tel1 radec coord : $radec" 3
					if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
						set hadec [tel1 hadec coord]
						::robobs::log "tel1 hadec coord : $hadec" 3						
					}
					if {$radec==$radec0} {
						set sortie 1
						break
					}
					set radec0 $radec
				}
			}
		} elseif {$type=="hadec"} {
			::robobs::log "tel1 hadec goto [list $ha $dec] -blocking 1" 3
			set t0 [clock seconds]
			if {$robobs(tel,name)=="simulation"} {
				after 3000
			} else {
				tel1 hadec goto [list $ha $dec] -blocking 1
				set sortie 0
				set hadec0 ""
				after 500
				while {$sortie==0} {
					update
					after 500
					set hadec [tel1 hadec coord]
					::robobs::log "tel1 hadec coord : $hadec" 3
					if {$hadec==$hadec0} {
						set sortie 1
						break
					}
					set hadec0 $hadec
				}
			}
		}
		set dt [expr [clock seconds]-$t0]
		::robobs::log "Telescope slew finished in $dt seconds" 3
	}
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
