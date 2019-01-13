# Script next_scene
# This script will be sourced in the loop
# ---------------------------------------
# Goal of the script :
#
# According the the slylight and meteo conditions, determines the 
# next scene to observe. In this script, you can defines the scheduling
# strategy of the observations.
#
# If skylight = Day, it is recommended to check if the telescope
# is parked. If not, do that.
# 
# ---------------------------------------
# Input variables, other than robobs(conf,*) :
#
# robobs(private,skylight) : updated in loopscript_check_night
# robobs(private,sunelev) : updated in loopscript_check_night
# robobs(tel,name) : updated in loopscript_check_telescope
#
# ---------------------------------------
# Output variables :
#
# robobs(next_scene,action) = none|science|flat & dark
# robobs(next_scene,slew) = (type=radec|hadec ra ha dec dra ddec)
# robobs(next_scene,images) = Image sequence definition {filename exposure shutter filter comment ...}
#
# ---------------------------------------

# ===============================================================================
# ===============================================================================
# Deplacer a terme ces procedures dans robobs.tcl

#------------------------------------------------------------
# ::robobs::key2val
#    Return the value amongst a list constitued by {{key val} {key val} ...}
#------------------------------------------------------------
proc ::robobs::key2val { keyvals key } {
	set val ""
	foreach keyval $keyvals {
		lassign $keyval thiskey thisval
		if {$thiskey==$key} {
			set val $thisval
			break
		}
	}
	return $val
}

#------------------------------------------------------------
# ::robobs::append_keyval
#    Return the keyval list constitued by {{key val} {key val} ...} after appened a couple key val
#------------------------------------------------------------
proc ::robobs::append_keyval { keyvals key val } {
	set keyvalnews ""
	foreach keyval $keyvals {
		lassign $keyval thiskey thisval
		if {$thiskey!=$key} {
			lappend keyvalnews $keyval
		}
	}
	lappend keyvalnews [list $key $val]
	return $keyvalnews
}

# ===============================================================================
# ===============================================================================



# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script
set skylight $robobs(private,skylight)
set sunelev $robobs(private,sunelev)
set sunset $robobs(private,sun_set)
set date [::audace::date_sys2ut]
set jd [mc_date2jd $date]
set home $robobs(conf,home,gps,value)
set diurnal [expr 360./(23*3600+56*60+4)]
set dra $diurnal
set ddec 0
set pi [expr 4*atan(1)]

# --- Init scene description
set robobs(next_scene,action) "none"
set robobs(next_scene,slew) ""
set robobs(next_scene,images) ""
set robobs(next_scene,www_infos) ""

# --- Infos meteo
foreach meteos_info $robobs(next_scene,meteos_infos) {
	set key [lindex $meteos_info 0]
	set val [lindex $meteos_info 1]
	set unit [lindex $meteos_info 2]
	if {$val=="undefined"} { continue }
	if {$key=="SkyCover"} {
		set robobs(next_scene,www_infos) [::robobs::append_keyval $robobs(next_scene,www_infos) skycover $val]
	}
	if {$key=="SkyTemp"} {
		set robobs(next_scene,www_infos) [::robobs::append_keyval $robobs(next_scene,www_infos) skytempr $val]
	}
	if {$key=="OutTemp"} {
		set robobs(next_scene,www_infos) [::robobs::append_keyval $robobs(next_scene,www_infos) temperature $val]
	}		
	if {$key=="Humidity"} {
		set robobs(next_scene,www_infos) [::robobs::append_keyval $robobs(next_scene,www_infos) humidity $val]
	}
	if {$key=="Pressure"} {
		set robobs(next_scene,www_infos) [::robobs::append_keyval $robobs(next_scene,www_infos) pressure $val]
	}
	if {$key=="Water"} {
		set robobs(next_scene,www_infos) [::robobs::append_keyval $robobs(next_scene,www_infos) water $val]
	}
	if {$key=="WinSpeed"} {
		set robobs(next_scene,www_infos) [::robobs::append_keyval $robobs(next_scene,www_infos) winspeed $val]
	}
	if {$key=="WinDir"} {
		set robobs(next_scene,www_infos) [::robobs::append_keyval $robobs(next_scene,www_infos) windir $val]
	}
}

# ---
proc obsconditions { coords home jd } {
   global robobs
   set ra [lindex $coords 0]
   set dec [lindex $coords 1]   
   set res [mc_radec2altaz $ra $dec $home $jd]
   set az [lindex $res 0]
   set elev [lindex $res 1]
   set ha [lindex $res 2]
	set robobs(next_scene,www_infos) [::robobs::append_keyval $robobs(next_scene,www_infos) ra   $ra]
	set robobs(next_scene,www_infos) [::robobs::append_keyval $robobs(next_scene,www_infos) dec  $dec]
	set robobs(next_scene,www_infos) [::robobs::append_keyval $robobs(next_scene,www_infos) az   $az]
	set robobs(next_scene,www_infos) [::robobs::append_keyval $robobs(next_scene,www_infos) elev $elev]
	set robobs(next_scene,www_infos) [::robobs::append_keyval $robobs(next_scene,www_infos) ha   $ha]
   set valid 1
   # --- angle d'elevation limite
   if {$elev<$robobs(conf,security_angles,elev_min,value)} {
      set robobs(next_scene,action) "none"
      ::robobs::log "Elevation $elev too low (<$robobs(conf,security_angles,elev_min,value))"
      set valid 0
      return [list $valid -50]
   } elseif {$elev>$robobs(conf,security_angles,elev_max,value)} {
      set robobs(next_scene,action) "none"
      ::robobs::log "Elevation $elev too high (>$robobs(conf,security_angles,elev_min,value))"
      set valid 0
      return [list $valid -50]
   }
   # --- tester les autres angles limites
   # --- ligne d'horizon
   set sequence [list  [list [list ELEV 0] [list AXE_0 now $ra $dec] ] ]
   set echt 60.
   mc_obsconditions $jd $home $sequence [expr $echt/86400] "test.txt" ALTAZ $robobs(conf,local_horizon,altaz,value)
   set f [open "test.txt" r]
   set lignes [split [read $f] \n]
   close $f
   set ligne [lindex $lignes 0]
   set jd0 [lindex $ligne 0]
   set index [expr int(floor(($jd-$jd0)*86400./$echt))]
   set ligne [lindex $lignes $index]
   set skylevel [lindex $ligne 12]
   set moon_dist [lindex $ligne 14]
	set robobs(next_scene,www_infos) [::robobs::append_keyval $robobs(next_scene,www_infos) skylevel   $skylevel]
	set robobs(next_scene,www_infos) [::robobs::append_keyval $robobs(next_scene,www_infos) moon_dist  $moon_dist]	
   if {$skylevel<$robobs(conf,skylight,skybrightness,value)} {
      set valid 0
   }
   ::robobs::log "At [mc_date2iso8601 [lindex [lindex $lignes $index] 0]], skylevel=$skylevel, az=[format %.1f $az] elev=[format %.1f $elev] ha=[format %.1f $ha] moon_dist=[format %.1f $moon_dist]"
   set skylevel [expr $skylevel-4.]
   return [list $valid $skylevel]
}

proc vachier_berthier_filecontents { distant_file } {
	global audace
   global robobs
	# File generated every hour at about xxh10
	# The goal is to download the file after xxh30
	# Date_ISO, RA (hms), DEC (dms), dra*cos(DEC) ("/s), dDEC ("/s), num, nom, exposure (s), bin, hauteur (deg)

	# --- get the file name
	#set distant_file [string trim $robobs(conf_planif,vachier_berthier,input_file)]
	set jdnow [mc_date2jd [::audace::date_sys2ut now]]
	set fichier [string trim $distant_file]
	set fic [file tail $fichier]
	set path $audace(rep_images)
	set local_file ${path}/${fic}
	# --- download the distant file
	set isurl [string range $fichier 0 3]
	set valid 1
	if {$isurl=="http"} {
		set url $distant_file
		package require http
		if { [catch { set tok [ ::http::geturl $url ] } ErrInfo ] } {
			::robobs::log "No internet connection."
			set valid 0
		} else {
			upvar #0 $tok state
			if { [ ::http::status $tok ] != "ok" } {
				::robobs::log "Problem while reading the html code."
				set valid 0
			}
			# -- verify the contents (TBDone)
			set key [ string range [ ::http::data $tok ] 0 4 ]
			set lignes [::http::data $tok ]
			::http::cleanup $tok
			# ---
			set f [open $local_file w]
			puts -nonewline $f $lignes
			close $f
		}
	} else {
		set err [catch {file copy -force -- $distant_file $local_file} msg]
		if {$err==1} {
			::robobs::log "No distant file $distant_file available."
			set valid 0
		}
	}
	if {([file exists $local_file]==0)} {
		::robobs::log "No file local file $local_file found. Impossible to select a target."
		set valid 0
	}
	set lignes ""
	if {$valid==1} {
		# --- The local file is usable. We read it and select the target
		set tfil [file mtime $local_file]
		set tcur [clock seconds]
		set f [open $local_file r]
		set lignes [split [read $f] \n]
		close $f
		# --- check the first line 
		set ligne [lindex $lignes 1]
		set ls [split $ligne ,]
		set date [mc_date2jd [string trim [lindex $ls 0]]]
		set date_deb $date
		# --- check the last line 
		set ligne [lindex $lignes end-1]
		set ls [split $ligne ,]
		set date [mc_date2jd [string trim [lindex $ls 0]]]
		set date_fin $date
		set djd [expr $date-$jdnow]
		set djdlim 3.
		if {$djd<$djdlim} {
			# email alert because the last line is valid only for the next djdlim days
			if {[info exists robobs(conf_planif,vachier_berthier,pb_date_file)]==0} {
				set robobs(conf_planif,vachier_berthier,pb_date_file) 0
			}
			if {$robobs(conf_planif,vachier_berthier,pb_date_file)==0} {
				::robobs::log "Problem because $local_file is valid less than 3 days."
				set originator "Alain Klotz <alain.klotz@free.fr>"
				set recipients {jerome.berthier@obspm.fr frederic.vachier@obspm.fr jpaulteng@orange.fr alain.klotz@free.fr}
				set email_server smtp.orange.fr
				set subject "T60 Les Makes - Ephem file trop vieux" 
				set body "Bonjour ami du T60,\n\n"
				append body "Le fichier $local_file est trop vieux.\nURL = $distant_file\nIl ne reste que $djd jours alors\nque la limite est $djdlim jours).\n\n(fichier envoyé automatiquement)"
				foreach recipient $recipients {
					set err [catch {
						::robobs::send_simple_message $originator $recipient $email_server $subject $body
					} msg]
					::robobs::log "Email envoyé à $recipient (err=$err msg=$msg)"
				}
			}
			set robobs(conf_planif,vachier_berthier,pb_date_file) 1
		}
		# --- select the target given the date
		set lignes [lrange $lignes 1 end-1]
	}
	return $lignes
}

proc strategy2expbins { } {
	global audace
   global robobs
   if {$robobs(planif,mode)=="vachier_berthier"} {
      # --- set the (exp,bin) possible values in the list expbins for darks and bins for flats
      set lignes [vachier_berthier_filecontents $robobs(conf_planif,vachier_berthier,input_file)]
      set expbins ""
      set bins ""
      if {$lignes!=""} {
         set now [mc_date2jd now]
			# Date_ISO, RA (hms), DEC (dms), dra*cos(DEC) ("/s), dDEC ("/s), num, nom, mag, exposure (s), bin, hauteur (deg)
			# 2018-06-08T20:12:00.00,  14h26m14.466s,  -32d56m33.10s,  -0.37980,  0.16010,  12686,  Bezuglyj,  17.36,  300,  3,  53.79			
         foreach ligne $lignes {
				set ligne [split $ligne ,]
            lassign $ligne date ra dec dra ddec num nom mag exposure bin elev
            set djd [expr [mc_date2jd $date]-$now]
            if {$djd>0.6} { 
               break 
            } elseif {$djd<-0.6} {
               continue 
            }
            set exposure [string trim $exposure]
            set bin [string trim $bin]
            if {($exposure=="")||($bin=="")} { continue }
            set valid 1
            foreach expbin $expbins {
               lassign $expbin e b
               if {($exposure==$e)&&($bin==$b)} {
                  set valid 0
               }
            }
            if {$valid==1} {
               lappend expbins [list $exposure $bin]
            }
            foreach b $bins {
               if {($bin==$b)} {
                  set valid 0
               }
            }
            if {$valid==1} {
               lappend bins $bin
            }
         }
      }
   }
   if {$robobs(planif,mode)=="star_light_curve"} {
      # --- set the (exp,bin) possible values in the list expbins for darks and bins for flats
      set expbins ""
      lappend expbins [list $robobs(conf_planif,star_light_curve,exposure) $robobs(conf_planif,star_light_curve,binning)]
      set bins ""
      lappend bins $robobs(conf_planif,star_light_curve,binning)
   }
   return [list $expbins $bins]
}

if {$robobs(planif,mode)=="vachier_berthier"} {
   #--- Calibration strategy
   set robobs(planif,calib,strategy) "1"
} elseif {$robobs(planif,mode)=="star_light_curve"} {
   #--- Calibration strategy
   set robobs(planif,calib,strategy) "2"
} else {
   set robobs(planif,calib,strategy) "0"
}
if {$robobs(conf,home,telescope_id,value)=="guitalens_taca"} {
   set robobs(planif,calib,strategy) "0"
}

set calib 0
set sunelev_flatbeg -6 ;
set sunelev_flatend -12 ;

# --- condition to perform darks well before the sun set.
set djd [expr $sunset-$jd] ; # >0 before sunset and <0 after sunset
if {($djd>0)&&($djd<0.5)} {
   ::robobs::log "Next sunset in [format %.1f [expr $djd*1440]] minutes ([mc_date2iso8601 $sunset])."
}
if {$robobs(planif,calib,strategy)>0} {
   console::affiche_resultat "DJD = $djd sunelev=$sunelev skylight=$skylight\n"
   if {(($skylight=="Day")&&($djd<[expr 2./24]))} {
      # --- we are two hours before the sun set
      # --- set the (exp,bin) possible values in the list expbins for darks and bins for flats
      set res [strategy2expbins]
      lassign $res expbins bins
      # --- compute the estimated time to begin darks
      set totalsec 0
      set nimages 5
      foreach expbin $expbins {
         lassign $expbin exp bin
         set deadtime [expr 30./$bin]
         set totalsec [expr $totalsec+($exp+$deadtime)*$nimages]
      }
      # --- compute the date when start the dark series
      ::robobs::log "totalsec = $totalsec."
      set sundark [expr $sunset - $totalsec/86400.]
      ::robobs::log "sundark = [mc_date2iso8601 $sundark]."
      set djd [expr $sundark-$jd] ; # >0 before sundark and <0 after sundark
      ::robobs::log "djd to sundark = $djd."
      if {$djd<0} {
         # --- The sun is not already set. It is time to start the darks
         # ==========
         # === Darks 
         # ==========
         if {[info exists robobs(planif,calib,strategy)]==1} {
            if {$robobs(planif,calib,strategy)>0} {
               # --- set the (exp,bin) possible values in the list expbins for darks and bins for flats
               set res [strategy2expbins]
               lassign $res expbins bins
               # --- darks
               if {$expbins!=""} {
                  foreach expbin $expbins {
                     # --- 
                     lassign $expbin exp bin
                     set exp [expr int(floor($exp))]
                     set fichier $audace(rep_images)/superdark_bin${bin}_exp${exp}.fit
                     if {[file exists $fichier]==0} {
                        set robobs(next_scene,action) "flat & dark"
                        set nimages 5
                        for {set k 1} {$k<=$nimages} {incr k} {
                           set scene_desc ""
                           set scene_desc [::robobs::append_keyval $scene_desc prefix DA]
                           set scene_desc [::robobs::append_keyval $scene_desc name dark$k]
                           set scene_desc [::robobs::append_keyval $scene_desc exposure $exp]
                           set scene_desc [::robobs::append_keyval $scene_desc binx $bin]
                           set scene_desc [::robobs::append_keyval $scene_desc biny $bin]
                           set scene_desc [::robobs::append_keyval $scene_desc shutter_mode closed]
                           set scene_desc [::robobs::append_keyval $scene_desc comment "dark $k/$nimages"]
                           set scene_desc [::robobs::append_keyval $scene_desc nimages $nimages]
                           if {$k==1} {
                              set scene_desc [::robobs::append_keyval $scene_desc flatlight 0]
                           }
                           lappend robobs(next_scene,images) $scene_desc
                        }
                     } else {
                        ::robobs::log "File $fichier already exists."
                     }
                  }
               }
            }
         }
      } else {
         ::robobs::log "Dark acquisition will start in [format %.0f [expr $djd*1440]] minutes ([mc_date2iso8601 $sundark])."
      }
   } elseif {($skylight=="Dusk")&&($sunelev<$sunelev_flatbeg)&&($sunelev>$sunelev_flatend)} {
      # --- we are at -4 deg elevation of sun to start the flats
      if {$robobs(planif,calib,strategy)>0} {
         # --- set the (exp,bin) possible values in the list expbins for darks and bins for flats
         set res [strategy2expbins]
         lassign $res expbins bins
      }
      # --- it is time to start the flats
      # ==========
      # === Flats
      # ==========
      if {$bins!=""} {
         set hadec_flat {22h11m19s 45d12m53s}
         set slew_desc ""
         set slew_desc [::robobs::append_keyval $slew_desc type hadec]
         set slew_desc [::robobs::append_keyval $slew_desc ha  [lindex $hadec_flat 0]]
         set slew_desc [::robobs::append_keyval $slew_desc dec [lindex $hadec_flat 1]]
         set slew_desc [::robobs::append_keyval $slew_desc dra 0]
         set slew_desc [::robobs::append_keyval $slew_desc ddec 0]
         foreach bin $bins {
            # --- 
				set fi $robobs(conf_planif,$robobs(planif,mode),filter)
            set fichier $audace(rep_images)/superflat_bin${bin}_${fi}.fit
            if {[file exists $fichier]==0} {
               set robobs(next_scene,action) "flat & dark"
               set robobs(next_scene,slew) $slew_desc
               set nimages 7
               for {set k 1} {$k<=$nimages} {incr k} {
                  set scene_desc ""
                  set scene_desc [::robobs::append_keyval $scene_desc prefix FL]
                  set scene_desc [::robobs::append_keyval $scene_desc name flat$k]
                  set scene_desc [::robobs::append_keyval $scene_desc exposure 3?]
                  set scene_desc [::robobs::append_keyval $scene_desc binx $bin]
                  set scene_desc [::robobs::append_keyval $scene_desc biny $bin]
                  set scene_desc [::robobs::append_keyval $scene_desc shutter_mode synchro]
                  set scene_desc [::robobs::append_keyval $scene_desc filter_name $robobs(conf_planif,$robobs(planif,mode),filter)]
                  set scene_desc [::robobs::append_keyval $scene_desc comment "flat $k/$nimages"]
                  set scene_desc [::robobs::append_keyval $scene_desc nimages $nimages]
                  set scene_desc [::robobs::append_keyval $scene_desc ngain 10000]
                  set scene_desc [::robobs::append_keyval $scene_desc adumin 10000]
                  set scene_desc [::robobs::append_keyval $scene_desc adumax 40000]
                  set scene_desc [::robobs::append_keyval $scene_desc exposuremax 60]
                  set scene_desc [::robobs::append_keyval $scene_desc exposuremin  5]
                  if {$k==1} {
                     set scene_desc [::robobs::append_keyval $scene_desc flatlight 1]
                  }
                  lappend robobs(next_scene,images) $scene_desc
               }
               set nimages 5
               for {set k 1} {$k<=$nimages} {incr k} {
                  set scene_desc ""
                  set scene_desc [::robobs::append_keyval $scene_desc prefix DA]
                  set scene_desc [::robobs::append_keyval $scene_desc name dark$k]
                  set scene_desc [::robobs::append_keyval $scene_desc exposure 10?]
                  set scene_desc [::robobs::append_keyval $scene_desc binx $bin]
                  set scene_desc [::robobs::append_keyval $scene_desc biny $bin]
                  set scene_desc [::robobs::append_keyval $scene_desc shutter_mode closed]
                  set scene_desc [::robobs::append_keyval $scene_desc comment "dark $k/$nimages"]
                  set scene_desc [::robobs::append_keyval $scene_desc nimages $nimages]
                  if {$k==1} {
                     set scene_desc [::robobs::append_keyval $scene_desc flatlight 0]
                  }
                  lappend robobs(next_scene,images) $scene_desc
               }
            } else {
               ::robobs::log "File $fichier already exists."
            }
         }
      }
   }
}
   
if {($skylight=="Night")&&($robobs(next_scene,images)=="")} {
	# ===================
	# === Science
	# ===================
	if {($robobs(meteo,global_check)=="OK")&&($robobs(ups,global_check)=="OK")} {

		# --- Add here the alert scene description
		
      if {$robobs(planif,mode)=="meridian"} {
         # === MERIDIAN
         set res [mc_altaz2radec 0 80 $home $jd]
         set ra [lindex $res 0]
         set dec [lindex $res 1]   
         set dra $diurnal
         set ddec 0.00
			# --- Fill the scene descrition
         set robobs(next_scene,action) "science"
			set scene_desc ""
			set scene_desc [::robobs::append_keyval $scene_desc prefix IM]
			set scene_desc [::robobs::append_keyval $scene_desc name meridian]
			set scene_desc [::robobs::append_keyval $scene_desc exposure 120]
			set scene_desc [::robobs::append_keyval $scene_desc shutter_mode synchro]
			set scene_desc [::robobs::append_keyval $scene_desc filter_name C]
			set scene_desc [::robobs::append_keyval $scene_desc comment "meridian"]
			lappend robobs(next_scene,images) $scene_desc
			set slew_desc ""
			set slew_desc [::robobs::append_keyval $slew_desc type radec]
			set slew_desc [::robobs::append_keyval $slew_desc ra $ra]
			set slew_desc [::robobs::append_keyval $slew_desc dec $dec]
			set slew_desc [::robobs::append_keyval $slew_desc dra $dra]
			set slew_desc [::robobs::append_keyval $slew_desc ddec $ddec]
			set robobs(next_scene,slew) $slew_desc

      } elseif {$robobs(planif,mode)=="vttrrlyr"} {
         # === VTT RRLYR
         set object_name rrlyr
         set coords [list 19h25m28s +42d47m05s]
         set exposure 30
         ::robobs::log "Try $object_name"
         set res [obsconditions $coords $home $jd]
         set valid [lindex $res 0]
         #set valid 0 ; # debug
         if {$valid==0} {
            set object_name ttlyn
            set coords [list 09h03m07.9s +44d35m08.5s]
            set exposure 60
            ::robobs::log "Try $object_name"
            set res [obsconditions $coords $home $jd]
            set valid [lindex $res 0]
         }
         if {$valid==0} {
            set object_name arper
            set coords [list 04h17m17.2s +47d24m00.6s]
            set exposure 60
            ::robobs::log "Try $object_name"
            set res [obsconditions $coords $home $jd]
            set valid [lindex $res 0]
         }
         set skylevel [lindex $res 1]
         set ra [string trim [mc_angle2deg [lindex $coords 0]]]
         set dec [string trim [mc_angle2deg [lindex $coords 1] 90]]
         # ---
         if {$valid==1} {
            if {[info exists robobs(next_scene,shutter_synchro)]==0} {
               set robobs(next_scene,shutter_synchro) 0
            }
				set scene_desc ""
				set scene_desc [::robobs::append_keyval $scene_desc exposure $exposure]
				set scene_desc [::robobs::append_keyval $scene_desc filter_name C]
				set scene_desc [::robobs::append_keyval $scene_desc simunaxis1 768]
				set scene_desc [::robobs::append_keyval $scene_desc simunaxis2 512]
				set scene_desc [::robobs::append_keyval $scene_desc skylevel $skylevel]				
				set slew_desc ""				
            incr robobs(next_scene,shutter_synchro)
            if {$robobs(next_scene,shutter_synchro)>5} {
					set robobs(next_scene,action) "dark"
					set scene_desc [::robobs::append_keyval $scene_desc name dark$object_name]
					set scene_desc [::robobs::append_keyval $scene_desc shutter_mode closed]
					set scene_desc [::robobs::append_keyval $scene_desc comment "Dark"]
               set robobs(next_scene,shutter_synchro) 0
            } else {
					set robobs(next_scene,action) "science"
					set scene_desc [::robobs::append_keyval $scene_desc name $object_name]
					set scene_desc [::robobs::append_keyval $scene_desc shutter_mode synchro]
					set scene_desc [::robobs::append_keyval $scene_desc comment "$object_name $robobs(next_scene,shutter_synchro)"]
					set slew_desc [::robobs::append_keyval $slew_desc type radec]
					set slew_desc [::robobs::append_keyval $slew_desc ra $ra]
					set slew_desc [::robobs::append_keyval $slew_desc dec $dec]
					set slew_desc [::robobs::append_keyval $slew_desc dra $dra]
					set slew_desc [::robobs::append_keyval $slew_desc ddec $ddec]					
            }
				lappend robobs(next_scene,images) $scene_desc
				set robobs(next_scene,slew) $slew_desc
         }
                  
      } elseif {$robobs(planif,mode)=="geostat1"} {
         # === Geostat
         set valid 1
         set date [mc_date2jd [::audace::date_sys2ut now]]
         set res [mc_earthshadow $date $home 1.0]
         set pointages [lindex $res 6]
         set ra_w [lindex $pointages 0]
         set ra_e [lindex $pointages 1]
         set dec [lindex $pointages 2]
         set ra  [mc_angle2hms [expr $ra_w-0.0] 360 zero 1 auto string]
         set dec [mc_angle2dms [expr $dec-0.25] 90 zero 0 + string]
         set coords [list $ra $dec]
         set res [obsconditions $coords $home $jd]
         set valid [lindex $res 0]
         set skylevel [lindex $res 1]
         set ra [string trim [mc_angle2deg [lindex $coords 0]]]
         set dec [string trim [mc_angle2deg [lindex $coords 1] 90]]
         set dra 0
         set ddec 0      
         # ---
         if {$valid==1} {
            set robobs(next_scene,action) "science"			
				set scene_desc ""
				set scene_desc [::robobs::append_keyval $scene_desc name geo]
				set scene_desc [::robobs::append_keyval $scene_desc exposure 30]
				set scene_desc [::robobs::append_keyval $scene_desc shutter_mode synchro]
				set scene_desc [::robobs::append_keyval $scene_desc filter_name C]
				set scene_desc [::robobs::append_keyval $scene_desc comment "GEO"]
				set scene_desc [::robobs::append_keyval $scene_desc simunaxis1 768]
				set scene_desc [::robobs::append_keyval $scene_desc simunaxis2 512]
				set scene_desc [::robobs::append_keyval $scene_desc skylevel $skylevel]				
				lappend robobs(next_scene,images) $scene_desc
				set scene_desc ""
				set scene_desc [::robobs::append_keyval $scene_desc name dark]
				set scene_desc [::robobs::append_keyval $scene_desc exposure 30]
				set scene_desc [::robobs::append_keyval $scene_desc shutter_mode closed]
				set scene_desc [::robobs::append_keyval $scene_desc filter_name C]
				set scene_desc [::robobs::append_keyval $scene_desc comment "Dark"]
				set scene_desc [::robobs::append_keyval $scene_desc simunaxis1 768]
				set scene_desc [::robobs::append_keyval $scene_desc simunaxis2 512]
				set scene_desc [::robobs::append_keyval $scene_desc skylevel $skylevel]				
				lappend robobs(next_scene,images) $scene_desc
				set slew_desc ""
				set slew_desc [::robobs::append_keyval $slew_desc type radec]
				set slew_desc [::robobs::append_keyval $slew_desc ra $ra]
				set slew_desc [::robobs::append_keyval $slew_desc dec $dec]
				set slew_desc [::robobs::append_keyval $slew_desc dra $dra]
				set slew_desc [::robobs::append_keyval $slew_desc ddec $ddec]					
				set robobs(next_scene,slew) $slew_desc
         }
         
      } elseif {$robobs(planif,mode)=="snresearch1"} {
         # === SN searching
         set valid 1
         if {[file exists $robobs(conf_planif,snresearch1,filegals)]==0} {
            # --- traiter le cas d'un fichier sn.txt manquant
         }
         if {[info exists robobs(planif,snresearch1,fields)]==0} {      
            ::robobs::log "Read fields in the file [file tail $robobs(conf_planif,snresearch1,filegals)]"
            set f [open $robobs(conf_planif,snresearch1,filegals) r]
            set lignes [split [read $f] \n]
            close $f
            set robobs(planif,snresearch1,fields) ""
            set k 0
            foreach ligne $lignes {
               if {[llength $ligne]<8} { continue }
               set name [lindex $ligne 0]            
               set ra [mc_angle2deg [lindex $ligne 1]h[lindex $ligne 2]m[lindex $ligne 3]s]
               set dec [mc_angle2deg [lindex $ligne 4]d[lindex $ligne 5]m[lindex $ligne 6]s 90]
               set mag [lindex $ligne 7]
               set observed 0
               if {$mag<$robobs(conf_planif,snresearch1,magliminf)} {set observed -1}
               if {$mag>$robobs(conf_planif,snresearch1,maglimsup)} {set observed -1}            
               if {$observed==0} { incr k }
               lappend robobs(planif,snresearch1,fields) [list $name $ra $dec $mag $observed]
            }
            # --- sort by increased RA
            set robobs(planif,snresearch1,fields) [lsort -index 1 $robobs(planif,snresearch1,fields)]
            ::robobs::log "$k fields in the file [file tail $robobs(conf_planif,snresearch1,filegals)]"
         }
         # --- dha
         set ha_set  [expr fmod($robobs(conf,security_angles,ha_set,value)+720,360)]
         set ha_rise [expr fmod($robobs(conf,security_angles,ha_rise,value)+720,360)]
         if {$ha_set>=$ha_rise} {
            set ha_set 179.9
            set ha_rise 180.1
         }
         # --- number of fields to observe
         set nf [llength $robobs(planif,snresearch1,fields)]
         # --- local sideral time
         set ts [mc_date2lst $jd $home -format deg]
         # --- RA for set
         set ha $ha_set
         set ramin [expr fmod($ts-$ha+720,360)]
         # --- kmin = index corresponding to RA for set
         set ra $ramin
         set kdeb 0
         set kfin [expr $nf-1]
         set kmed -1
         set sortie 0
         while {$sortie==0} {
            set kmed [expr ($kdeb+$kfin)/2]
            set ramed [lindex [lindex $robobs(planif,snresearch1,fields) $kmed] 1]
            #::robobs::log "A kdeb=$kdeb kmed=$kmed kfin=$kfin ($ra $ramed)"
            if {$kmed==$kdeb} { set sortie 1 }
            if {$kmed==$kfin} { set sortie 1 }
            if {$ra<$ramed} { 
               set kfin $kmed
            } elseif {$ra>=$ramed} { 
               set kdeb $kmed 
            }
         }
         set kmin $kmed
         if {[info exists robobs(planif,snresearch1,kobs)]==1} {
            set kmin $robobs(planif,snresearch1,kobs)
         }            
         # --- RA for rise
         set ha $ha_rise
         set ramax [expr fmod($ts-$ha+720,360)]
         # --- kmax = index corresponding to RA for rise
         set ra $ramax
         set kdeb 0
         set kfin [expr $nf-1]
         set kmed -1
         set sortie 0
         while {$sortie==0} {
            set kmed [expr ($kdeb+$kfin)/2]
            set ramed [lindex [lindex $robobs(planif,snresearch1,fields) $kmed] 1]
            #::robobs::log "B kdeb=$kdeb kmed=$kmed kfin=$kfin ($ra $ramed)"
            if {$kmed==$kdeb} { set sortie 1 }
            if {$kmed==$kfin} { set sortie 1 }
            if {$ra<$ramed} { 
               set kfin $kmed
            } elseif {$ra>=$ramed} { 
               set kdeb $kmed 
            }
         }
         set kmax $kmed
         ::robobs::log "ramin=$ramin ramax=$ramax"
         ::robobs::log "kmin=$kmin kmax=$kmax"
         # --- Loop over the observable fields
         while {1==1} {
            # --- select the observed==0 field the nearest of the set HA limit
            set kobs -1
            set k1 $kmin
            if {$kmax>=$kmin} { 
               set k2 $kmax 
            } else { 
               set k2 [expr $nf-1] 
            }
            #::robobs::log "=== A k1=$k1 k2=$k2"
            for {set k $k1} {$k<=$k2} {incr k} {
               set observed [lindex [lindex $robobs(planif,snresearch1,fields) $k] 4]
               #::robobs::log "A k=$k observed=$observed"
               if {$observed==0} {
                  set kobs $k
                  break
               }
            }
            if {($kobs==-1)&&($kmax<$kmin)} {
               set k1 0
               set k2 $kmax
               #::robobs::log "=== B k1=$k1 k2=$k2"
               for {set k $k1} {$k<=$k2} {incr k} {
                  set observed [lindex [lindex $robobs(planif,snresearch1,fields) $k] 4]
                  #::robobs::log "B k=$k observed=$observed"
                  if {$observed==0} {
                     set kobs $k
                     break
                  }
               }         
            }
            if {$kobs==-1} {
               # --- pas de galaxies à observer en ce moment
               ::robobs::log "No field observable at this time"
               set valid 0
               break
            }
            # ---
            set robobs(planif,snresearch1,kobs) $kobs
            set field [lindex $robobs(planif,snresearch1,fields) $kobs]
            ::robobs::log "Check observability of $field"
            set name [lindex $field 0]
            set ra   [lindex $field 1]
            set dec  [lindex $field 2]
            set coords [list $ra $dec]
            set res [obsconditions $coords $home $jd]
            set valid [lindex $res 0]
            set skylevel [lindex $res 1]
            #::robobs::log "valid=$valid k=$k kmin=$kmin"
            if {$valid==0} {
               set kmin [expr $k+1]
               continue
            }
            # --- valid==1
				set robobs(next_scene,action) "science"			
				set slew_desc ""
				set slew_desc [::robobs::append_keyval $slew_desc type radec]
				set slew_desc [::robobs::append_keyval $slew_desc ra $ra]
				set slew_desc [::robobs::append_keyval $slew_desc dec $dec]
				set slew_desc [::robobs::append_keyval $slew_desc dra $dra]
				set slew_desc [::robobs::append_keyval $slew_desc ddec $ddec]					
				set robobs(next_scene,slew) $slew_desc
            for {set k 1} {$k<=$robobs(conf_planif,snresearch1,nbimages)} {incr k} {         
					set scene_desc ""
					set scene_desc [::robobs::append_keyval $scene_desc name ${robobs(planif,mode)}_$nam]
					set scene_desc [::robobs::append_keyval $scene_desc exposure $robobs(conf_planif,snresearch1,exposure)]					
					set scene_desc [::robobs::append_keyval $scene_desc shutter_mode synchro]
					set scene_desc [::robobs::append_keyval $scene_desc filter_name C]
					set scene_desc [::robobs::append_keyval $scene_desc comment "$name image $k / $robobs(conf_planif,snresearch1,nbimages)"]
					set scene_desc [::robobs::append_keyval $scene_desc simunaxis1 768]
					set scene_desc [::robobs::append_keyval $scene_desc simunaxis2 512]
					set scene_desc [::robobs::append_keyval $scene_desc skylevel $skylevel]
					set scene_desc [::robobs::append_keyval $scene_desc binx $robobs(conf_planif,snresearch1,binning)]		
					set scene_desc [::robobs::append_keyval $scene_desc biny $robobs(conf_planif,snresearch1,binning)]		
					lappend robobs(next_scene,images) $scene_desc
            }
            set res [lindex $robobs(next_scene,images) end]
            ::robobs::log "[lindex $res 4]"
            break
         }
         
      } elseif {$robobs(planif,mode)=="asteroid_light_curve"} {
         # === 3 objects light curve
         set valid 0
         if {[info exists robobs(planif,asteroid_light_curve,index_last_field)]==0} {      
            set robobs(planif,asteroid_light_curve,index_last_field) 1
         }
         #::robobs::log "A robobs(planif,asteroid_light_curve,index_last_field)=$robobs(planif,asteroid_light_curve,index_last_field)" 3
         set kk [expr $robobs(planif,asteroid_light_curve,index_last_field)-1]
         for {set k 1} {$k<=3} {incr k} {
            incr kk
            if {$kk>3} {
               set kk 1
            }
            #::robobs::log "A k=$k kk=$kk" 3
            set name "$robobs(conf_planif,asteroid_light_curve,object_name$kk)"
            set coord "$robobs(conf_planif,asteroid_light_curve,object_coord$kk)"
            # --- resolveur de nom
            set radec ""
            if {$name!=""} {
               set n [llength $coord]
               if {$n==6} {
                  set radec "[lindex $coord 0]h[lindex $coord 1]m[lindex $coord 2]s [lindex $coord 3]d[lindex $coord 4]m[lindex $coord 5]s 0 0"
               } elseif {$n==2} {
                  set radec "[lindex $coord 0] [lindex $coord 1] 0 0"
               } else {
                  set err [catch {name2coord $name -drift} radec]
                  if {$err==1} {
                     set err [catch {vo_getmpcephem $name $jd $home} res]
                     if {$err==0} {
                        set res [lindex $res 0]
                        set a [lindex $res 0]
                        regsub -all \\( $a "" b ; set a $b
                        regsub -all \\) $a "" b ; set a $b
                        regsub -all " " $a _ b ; set a $b
                        set name $a
                        set ra [lindex $res 2]
                        set dec [lindex $res 3]
                        set dra [lindex $res 4]
                        set ddec [lindex $res 5]
                        set radec [list $ra $dec $dra $ddec]						
                     } else {
                        ::robobs::log "name=$name coordinates not found."
                        continue
                     }				
                  }
               }
               #::robobs::log "radec A = $radec"
               set coords [lrange $radec 0 1]
               set res [obsconditions $coords $home $jd]
               set valid [lindex $res 0]
               set skylevel [lindex $res 1]
               ::robobs::log "name=$name kk=$kk $coords valid=$valid skylevel=[format %.2f $skylevel]"
               if {$valid==0} {
                  continue
               } else {
                  # --- valid==1
                  set valid 1
                  lassign $radec ra dec dra ddec
                  set dra $diurnal
                  set ddec 0
                  if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
                     set filter_name $robobs(conf_planif,$robobs(planif,mode),filter)
                  } else {
                     set filter_name C
                  }
						set robobs(next_scene,action) "science"
						set slew_desc ""
						set slew_desc [::robobs::append_keyval $slew_desc type radec]
						set slew_desc [::robobs::append_keyval $slew_desc ra $ra]
						set slew_desc [::robobs::append_keyval $slew_desc dec $dec]
						set slew_desc [::robobs::append_keyval $slew_desc dra $dra]
						set slew_desc [::robobs::append_keyval $slew_desc ddec $ddec]					
						set robobs(next_scene,slew) $slew_desc
                  for {set k 1} {$k<=$robobs(conf_planif,asteroid_light_curve,nbimages)} {incr k} {  
							set scene_desc ""
							set scene_desc [::robobs::append_keyval $scene_desc name $name]
							set scene_desc [::robobs::append_keyval $scene_desc exposure $robobs(conf_planif,asteroid_light_curve,exposure)]					
							set scene_desc [::robobs::append_keyval $scene_desc shutter_mode synchro]
							set scene_desc [::robobs::append_keyval $scene_desc filter_name $filter_name]
							set scene_desc [::robobs::append_keyval $scene_desc comment "$name image $k / $robobs(conf_planif,asteroid_light_curve,nbimages)"]
							set scene_desc [::robobs::append_keyval $scene_desc simunaxis1 768]
							set scene_desc [::robobs::append_keyval $scene_desc simunaxis2 512]
							set scene_desc [::robobs::append_keyval $scene_desc skylevel $skylevel]
							set scene_desc [::robobs::append_keyval $scene_desc binx $robobs(conf_planif,asteroid_light_curve,binning)]		
							set scene_desc [::robobs::append_keyval $scene_desc biny $robobs(conf_planif,asteroid_light_curve,binning)]		
							lappend robobs(next_scene,images) $scene_desc
                  }
                  set res [lindex $robobs(next_scene,images) end]
                  #::robobs::log "[lindex $res 4]"
                  break
               }				
            }
         }
         set robobs(planif,asteroid_light_curve,index_last_field) $kk
         #::robobs::log "AA robobs(planif,asteroid_light_curve,index_last_field)=$robobs(planif,asteroid_light_curve,index_last_field)" 3		
         if {$valid==0} {
            # --- pas d'objet à observer en ce moment
            ::robobs::log "No field observable at this time"
            set valid 0
         }
         
      } elseif {$robobs(planif,mode)=="star_light_curve"} {
         # === 3 objects light curve
         set valid 0
         if {[info exists robobs(planif,star_light_curve,index_last_field)]==0} {      
            set robobs(planif,star_light_curve,index_last_field) 1
         }
         #::robobs::log "A robobs(planif,star_light_curve,index_last_field)=$robobs(planif,star_light_curve,index_last_field)" 3
         set kk [expr $robobs(planif,star_light_curve,index_last_field)-1]
         for {set k 1} {$k<=3} {incr k} {
            incr kk
            if {$kk>3} {
               set kk 1
            }
            #::robobs::log "A k=$k kk=$kk" 3
            set name "$robobs(conf_planif,star_light_curve,object_name$kk)"
            set coord "$robobs(conf_planif,star_light_curve,object_coord$kk)"
            # --- resolveur de nom
            set radec ""
            if {$name!=""} {
               set n [llength $coord]
               if {$n==6} {
                  set radec "[lindex $coord 0]h[lindex $coord 1]m[lindex $coord 2]s [lindex $coord 3]d[lindex $coord 4]m[lindex $coord 5]s 0 0"
               } elseif {$n==2} {
                  set radec "[lindex $coord 0] [lindex $coord 1] 0 0"
               } else {
                  set err [catch {name2coord $name -drift} radec]
                  if {$err==1} {
                     set err [catch {vo_getmpcephem $name $jd $home} res]
                     if {$err==0} {
                        set res [lindex $res 0]
                        set a [lindex $res 0]
                        regsub -all \\( $a "" b ; set a $b
                        regsub -all \\) $a "" b ; set a $b
                        regsub -all " " $a _ b ; set a $b
                        set name $a
                        set ra [lindex $res 2]
                        set dec [lindex $res 3]
                        set dra [lindex $res 4]
                        set ddec [lindex $res 5]
                        set radec [list $ra $dec $dra $ddec]						
                     } else {
                        ::robobs::log "name=$name coordinates not found."
                        continue
                     }				
                  }
               }
               #::robobs::log "radec A = $radec"
               set coords [lrange $radec 0 1]
               set res [obsconditions $coords $home $jd]
               set valid [lindex $res 0]
               set skylevel [lindex $res 1]
               ::robobs::log "name=$name kk=$kk $coords valid=$valid skylevel=[format %.2f $skylevel]"
               if {$valid==0} {
                  continue
               } else {
                  # --- valid==1
                  set valid 1
                  lassign $radec ra dec dra ddec
                  set dra $diurnal
                  set ddec 0
                  if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
                    set filter_name $robobs(conf_planif,$robobs(planif,mode),filter)
                  } else {
                     set filter_name C
                  }
						set robobs(next_scene,action) "science"
						set slew_desc ""
						set slew_desc [::robobs::append_keyval $slew_desc type radec]
						set slew_desc [::robobs::append_keyval $slew_desc ra $ra]
						set slew_desc [::robobs::append_keyval $slew_desc dec $dec]
						set slew_desc [::robobs::append_keyval $slew_desc dra $dra]
						set slew_desc [::robobs::append_keyval $slew_desc ddec $ddec]					
						set robobs(next_scene,slew) $slew_desc
                  for {set k 1} {$k<=$robobs(conf_planif,star_light_curve,nbimages)} {incr k} {
							set scene_desc ""
							set scene_desc [::robobs::append_keyval $scene_desc name cdl_$name]
							set scene_desc [::robobs::append_keyval $scene_desc exposure $robobs(conf_planif,star_light_curve,exposure)]					
							set scene_desc [::robobs::append_keyval $scene_desc shutter_mode synchro]
							set scene_desc [::robobs::append_keyval $scene_desc filter_name $filter_name]
							set scene_desc [::robobs::append_keyval $scene_desc comment "$name image $k / $robobs(conf_planif,star_light_curve,nbimages)"]
							set scene_desc [::robobs::append_keyval $scene_desc simunaxis1 768]
							set scene_desc [::robobs::append_keyval $scene_desc simunaxis2 512]
							set scene_desc [::robobs::append_keyval $scene_desc skylevel $skylevel]
							set scene_desc [::robobs::append_keyval $scene_desc binx $robobs(conf_planif,star_light_curve,binning)]		
							set scene_desc [::robobs::append_keyval $scene_desc biny $robobs(conf_planif,star_light_curve,binning)]		
							lappend robobs(next_scene,images) $scene_desc
                  }
                  set res [lindex $robobs(next_scene,images) end]
                  #::robobs::log "[lindex $res 4]"
                  break
               }				
            }
         }
         set robobs(planif,star_light_curve,index_last_field) $kk
         #::robobs::log "AA robobs(planif,star_light_curve,index_last_field)=$robobs(planif,star_light_curve,index_last_field)" 3		
         if {$valid==0} {
            # --- pas d'objet à observer en ce moment
            ::robobs::log "No field observable at this time"
            set valid 0
         }         
         
      } elseif {$robobs(planif,mode)=="vachier_berthier"} {

			set lignes [vachier_berthier_filecontents $robobs(conf_planif,vachier_berthier,input_file)]
         if {$lignes!=""} {
				set jdnow [mc_date2jd [::audace::date_sys2ut now]]
            set selects ""
            set k 0
            foreach ligne $lignes {
               incr k
               if {[string length $ligne]<10} {
                  continue
               }
               set ls [split $ligne ,]
               set date [mc_date2jd [string trim [lindex $ls 0]]]
               set djd [expr $date-$jdnow]
               if {$djd>=0} {
                  if {$djd<=[expr 2./1440]} {
                     set selects $ls
                  }
                  break
               }
            }
            #::robobs::log "k=$k"
            #::robobs::log "date_deb = [mc_date2iso8601 $date_deb]"
            #::robobs::log "date_fin = [mc_date2iso8601 $date_fin]"
            #::robobs::log "date=$date [mc_date2iso8601 $date]"
            #::robobs::log "jdnow=$jdnow [mc_date2iso8601 $jdnow]"
            #::robobs::log "djd=$djd"
            #::robobs::log "selects = $ls"
            set valid 1
            if {$selects==""} {
               set valid 0
            } else {
					# Date_ISO, RA (hms), DEC (dms), dra*cos(DEC) ("/s), dDEC ("/s), num, nom, exposure (s), bin, hauteur (deg)
					set as ""
					foreach select $selects {
						lappend as [string trim $select]
					}
					set selects $as
               lassign $selects date ra dec dra ddec num nom mag exposure bin elev
               ## set ra [string trim $ra] ; ## set ra [lindex $ra 0]h[lindex $ra 1]m[lindex $ra 2]s
               ## set dec [string trim $dec] ; ## set dec [lindex $dec 0]d[lindex $dec 1]m[lindex $dec 2]s
               set coords [list $ra $dec]
               set res [obsconditions $coords $home $jd]
               set valid [lindex $res 0]               
               set skylevel [lindex $res 1]
               ::robobs::log "$coords valid=$valid skylevel=[format %.2f $skylevel]"
               if {$valid==1} {
                  set dra [string trim $dra]               
                  # set dra $diurnal
                  set ddec [string trim $ddec]               
                  # set ddec 0
                  ## set num [string trim $num]
                  set n1 [string trim $nom]
                  set n2 [regsub -all '   $n1 "_"]
                  set n1 [regsub -all " " $n2 "_"]
                  set nom $n1
                  set nom [regsub -all / $nom "_"]
                  if {$num==""} {
                     # 2014_FR25
                     set name ${nom}                  
                  } else {
                     # 41_daphne
                     set name ${num}_${nom}                  
                  }               
                  if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
                     set filter_name $robobs(conf_planif,$robobs(planif,mode),filter)
                  } else {
                     set filter_name C
                  }
						#::robobs::log "lappend robobs(next_scene,images) [list [list name $name] [list exposure $exposure] [list shutter_mode synchro] [list filter_name $filter_name] [list comment "From file $fic"] {simunaxis1 768} {simunaxis2 512} [list skylevel $skylevel] [list binx $bin] [list biny $bin] ]\n"						
						#tk_messageBox -type ok -detail "Regarder la console d'Aud'ACE"
						set robobs(next_scene,action) "science"
						set slew_desc ""
						set slew_desc [::robobs::append_keyval $slew_desc type radec]
						set slew_desc [::robobs::append_keyval $slew_desc ra $ra]
						set slew_desc [::robobs::append_keyval $slew_desc dec $dec]
						set slew_desc [::robobs::append_keyval $slew_desc dra [expr $dra/2.]]
						set slew_desc [::robobs::append_keyval $slew_desc ddec [expr $ddec/2.]]					
						set robobs(next_scene,slew) $slew_desc
						set scene_desc ""
						set scene_desc [::robobs::append_keyval $scene_desc name $name]
						set scene_desc [::robobs::append_keyval $scene_desc exposure $exposure]					
						set scene_desc [::robobs::append_keyval $scene_desc shutter_mode synchro]
						set scene_desc [::robobs::append_keyval $scene_desc filter_name $filter_name]
						set scene_desc [::robobs::append_keyval $scene_desc comment "From file [file tail $robobs(conf_planif,vachier_berthier,input_file)]"]
						set scene_desc [::robobs::append_keyval $scene_desc simunaxis1 768]
						set scene_desc [::robobs::append_keyval $scene_desc simunaxis2 512]
						set scene_desc [::robobs::append_keyval $scene_desc skylevel $skylevel]
						set scene_desc [::robobs::append_keyval $scene_desc binx $bin]		
						set scene_desc [::robobs::append_keyval $scene_desc biny $bin]		
						lappend robobs(next_scene,images) $scene_desc
               }
            }
         }
         if {$valid==0} {
            # --- pas d'objet à observer en ce moment
            ::robobs::log "No field observable at this time"
            set valid 0
         }
      }
   }
}

# --- special case to stop the motor when there is nothing to observe
#::robobs::log "ETAPE 1" 3
if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
	if {($robobs(next_scene,action)=="none")&&($robobs(next_scene,slew)=="")&&($robobs(next_scene,images)=="")} {
		::robobs::log "tel1 radec motor off" 3
		tel1 radec motor off
	}
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
