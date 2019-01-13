## @file      loopscript_check_security.tcl
#  @brief     Explication du fichier ?
#  @pre       This script will be sourced in the loop
#  @author    Alain Klotz
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par       Ressource
#  @code      source [file join $audace(rep_install) gui audace plugin tool robobs loopscript_check_security.tcl]
#  @todo      A completer
#  @endcode

# $Id: loopscript_check_security.tcl 14520 2018-10-23 16:06:25Z alainklotz $

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script
set home $robobs(conf,home,gps,value)

#------------------------------------------------------------
## Explication de la procedure ?
#  @todo A completer
#  @note proc that update two variables:
#        robobs(meteo,global_check) = OK or PB
#        robobs(meteo,global_comment) = "" or a comment when PB
#  @param  void
#  @return list of two value : { resmeteos type }
#          resmeteos : explication
#          type      : explication
#
proc read_meteosensor { } {
   global robobs
   global audace
   set robobs(meteo,global_check) OK
   set robobs(meteo,global_comment) ""
   # --- Read the meteo sensor handler name
   source "$audace(rep_install)/gui/audace/meteosensor_tools.tcl"
   if {[info exists robobs(meteo,meteosensor,name)]==1} {
      set name $robobs(meteo,meteosensor,name)
   } else {
      set name robobs1
   }

   # --- Open meteo sensor connection if needed
   if {[info exists robobs(meteo,meteosensor,name)]==0} {
      catch { meteosensor_close $name }
      ::robobs::log "RobObs [info script] TRY meteosensor_open $robobs(conf,meteostation,type,value) $robobs(conf,meteostation,port,value) $name $robobs(conf,meteostation,params,value)" 3
      set err [catch {meteosensor_open $robobs(conf,meteostation,type,value) $robobs(conf,meteostation,port,value) $name $robobs(conf,meteostation,params,value)} msg ]
      if {$err==0} {
         set robobs(meteo,meteosensor,name) $name
         ::robobs::log "RobObs [info script] success for meteosensor_open: $msg" 3
      } else {
         ::robobs::log "RobObs [info script] problem concerning meteosensor_open: $msg" 3
      }
   }

   # --- Read meteo sensor values
   if {[info exists robobs(meteo,meteosensor,jdlastpb)]==0} {
      set robobs(meteo,meteosensor,jdlastpb) [expr [mc_date2jd [::audace::date_sys2ut]]-($robobs(conf,meteostation,delay_security,value)+1)/86400.]
   }
   #if {[info exists robobs(meteo,global_check)]==0} {
   #   set robobs(meteo,global_comment) ""
   #   set robobs(meteo,global_check) OK
   #}
   set type ""
   set resmeteos ""
   if {[info exists robobs(meteo,meteosensor,name)]==1} {
      set type [meteosensor_type $robobs(meteo,meteosensor,name)]
      set res [meteosensor_getstandard $robobs(meteo,meteosensor,name)]
      foreach re $res {
         lappend resmeteos $re
      }
      set keys ""
      foreach re $res {
         lappend keys [lindex $re 0]
      }
      # --- 
      set key SkyCover
      set value_limit_max $robobs(conf,meteostation,cloud_limit_max,value)
      set k [lsearch -exact $keys $key]
      set value [lindex [lindex $resmeteos $k] 1]
      if {($value_limit_max=="VeryCloudy")&&($value=="VeryCloudy")} {
         set robobs(meteo,global_check) PB
         append robobs(meteo,global_comment) " (${key} = $value)"
      } elseif {($value_limit_max=="Cloudy")&&(($value=="VeryCloudy")||(($value=="Cloudy")))} {
         set robobs(meteo,global_check) PB
         append robobs(meteo,global_comment) " (${key} = $value)"
      } elseif {($value_limit_max=="Clear")} {
         set robobs(meteo,global_check) PB
         append robobs(meteo,global_comment) " (${key} = $value)"
      }
      set value_skycover $value
      # --- Special case of humidity
      set key Humidity
      set value_limit_max $robobs(conf,meteostation,humidity_limit_max,value)
      set k [lsearch -exact $keys $key]
      set value [lindex [lindex $resmeteos $k] 1]
      if {$value>=$value_limit_max} { 
         if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
            if {$value_skycover!="Clear"} {
               # on peut depasser la limite d'humidité si le ciel est Clear
               set robobs(meteo,global_check) PB
               append robobs(meteo,global_comment) " (${key}: $value >= $value_limit_max)"
            }
         } else {
            set robobs(meteo,global_check) PB
            append robobs(meteo,global_comment) " (${key}: $value >= $value_limit_max)"
         }
      }
      # --- Special case of humidity
      set pressure 1013.25
      if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
         # --- Special case of humidity provided by Vantage from Raspberry server
         set err [catch {
            set res [get_vantage_from_raspberry]
         } msg]
         if {$err==0} {
            lassign [get_vantage_from_raspberry] jd OutsideTemp OutsideHumidity RainRate WindSpeed WindDir Barometer
            catch {
               if {$Barometer!=""} {
                  set pressure [expr $Barometer]
               }
            }
         }
      }
      lappend resmeteos [list Pressure $pressure hPa] ; # At sea level
      # --- 
      set key WinSpeed
      set value_limit_max $robobs(conf,meteostation,wind_limit_max,value)
      set k [lsearch -exact $keys $key]
      set value [lindex [lindex $resmeteos $k] 1]
      if {$value>=$value_limit_max} { 
         set robobs(meteo,global_check) PB
         append robobs(meteo,global_comment) " (${key}: $value >= $value_limit_max)"
      }
      # --- 
      set key Water
      set value_limit_max $robobs(conf,meteostation,water_limit_max,value)
      set k [lsearch -exact $keys $key]
      set value [lindex [lindex $resmeteos $k] 1]
      if {($value_limit_max=="Rain")&&($value=="Rain")} {
         set robobs(meteo,global_check) PB
         append robobs(meteo,global_comment) " (${key} = $value)"
      } elseif {($value_limit_max=="Wet")&&(($value=="Rain")||(($value=="Wet")))} {
         set robobs(meteo,global_check) PB
         append robobs(meteo,global_comment) " (${key} = $value)"
      } elseif {($value_limit_max=="Dry")} {
         set robobs(meteo,global_check) PB
         append robobs(meteo,global_comment) " (${key} = $value)"
      }
   }
   return [list $resmeteos $type]
}

#------------------------------------------------------------
## Explication de la procedure ?
#  @todo A completer
#  @note proc that update two variables:
#        robobs(ups,global_check) = OK or PB
#        robobs(ups,global_comment) = "" or a comment when PB
#  @param  void
#  @return list of two value : { resupss type }
#          resupss : explication
#          type    : explication
#
proc read_ups { } {
   global robobs
   global audace
   set robobs(ups,global_check) OK
   set robobs(ups,global_comment) ""
   set resupss ""
   set type No_UPS
   if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
      set type UPS_T60
      set port //./COM13
      set res [read_ups_megatec $port Bat_Charge]
      lassign $res desc val_bch
      #::robobs::log "UPS-UPS 0a res=$res val_bch=$val_bch" 3
      after 100
      set res [read_ups_megatec $port UPS_Mode]
      lassign $res desc val_mod
      #::robobs::log "UPS-UPS 0b res=$res val_mod=$val_mod" 3
      if {$val_mod==0} {
         set onbattery No
      } elseif {$val_bch==0} {
         set onbattery High ; # not critical
      } else {
         set onbattery Low ; # critical
         set robobs(ups,global_check) PB
         set robobs(ups,global_comment) " UPS battery too low."
      }
      lappend resupss [list OnBattery $onbattery "No|High|Low"]
   }
   return [list $resupss $type]
}

#------------------------------------------------------------
## Explication de la procedure ?
#  @todo A completer
#  @note A completer
#  @param  port     : explication
#  @param  commande : explication
#  @return list of two value : { desc val }
#          desc : explication
#          val  : explication
#
proc read_ups_megatec { port commande } {
   package require twapi
   set pids [twapi::get_process_ids]
   foreach pid $pids {
      catch {set name [twapi::get_process_name $pid]}
      if {$name=="UPSilon.exe"} {      
         twapi::end_process $pid -force
         after 1000
      }
      if {$name=="RupsMon.exe"} {      
         twapi::end_process $pid -force
         after 1000
      }
   }
   set f [open $port r+]
   set res [fconfigure $f -blocking 0 -buffering none -buffersize 4096 -encoding utf-8 -translation {auto crlf} -mode 2400,n,8,1]
   set res [fconfigure $f]
   puts -nonewline $f "Q1\r"
   after 300
   set res [read $f]
   close $f 
   
   set res [string range $res 1 end]
   set UPS_Mode [string range [lindex $res 7] 0 0]
   set Bat_Charge [string range [lindex $res 7] 1 1]

   set commandes ""
   lappend commandes [list "Vin" [lindex $res 0] "Voltage from mains (in Volt)"]
   lappend commandes [list "Vout" [lindex $res 2] "Voltage from UPS outlet (in Volt)"]
   lappend commandes [list "Bat_Volt" [lindex $res 5] "Battery voltage (in Volt), max voltage at 2.26 V"]
   lappend commandes [list "UPS_Mode" $UPS_Mode "Mode on UPS : Mains=0 Battery=1"]
   lappend commandes [list "Bat_Charge" $Bat_Charge "Battery remaining charge : Good=0 Low=1"]
   
   foreach cmd $commandes {
      lassign $cmd com val desc
      if {$com==$commande} {
         break
      }
   }   
   return [list $desc $val ]
}

# Continue loopscript ------------------------------------------------------------

lassign [read_meteosensor] resmeteos type
# ::robobs::log "meteo check A is $robobs(meteo,global_check) $robobs(meteo,global_comment)" 3
if {$robobs(meteo,global_check)=="PB"} {
   set robobs(meteo,meteosensor,jdlastpb) [mc_date2jd [::audace::date_sys2ut]]
} else {
   set dsec [expr int(86400*([mc_date2jd [::audace::date_sys2ut]]-$robobs(meteo,meteosensor,jdlastpb)))]
   if {$dsec<$robobs(conf,meteostation,delay_security,value)} {
      set robobs(meteo,global_check) PB
      append robobs(meteo,global_comment) " (Only $dsec seconds since the good conditions appeared)"
   }
}
set textes ""
set meteo_headerfits ""
foreach resmeteo $resmeteos {
   set key [lindex $resmeteo 0]
   set val [lindex $resmeteo 1]
   set unit [lindex $resmeteo 2]
   if {$unit=="text"} { set unit "" }
   if {$val=="undefined"} { continue }
   append textes " ${key}=${val} ${unit}."
   # ---
   if {$key=="OutTemp"} {
      lappend meteo_headerfits [list TEMP $val float "Site temperature" "degC"]
   }
   if {$key=="Humidity"} {
      lappend meteo_headerfits [list HUMIDITY $val float "Air relative humidity" "percent"]
   }
   if {$key=="SkyTemp"} {
      lappend meteo_headerfits [list SKYTEMP $val float "Sky temperature" "degC"]
   } 
   if {$key=="Pressure"} {
      lappend meteo_headerfits [list PRESSURE $val float "Air pressure at site altitude" "hPa"]
      catch {
         #set val 1020
         #lassign [mc_altitude2tp [lindex $home 4] [expr $val*100]] temp pressure
         #set val [expr $pressure/100.]
         #lappend meteo_headerfits [list PRESSEA $val float "Air pressure at sea level" "hPa"]
      }
   } 
}
set robobs(next_scene,meteos_infos) $resmeteos
set robobs(private,meteo_headerfits) $meteo_headerfits   
::robobs::log "meteo from $type: $textes" 3
::robobs::log "meteo check is $robobs(meteo,global_check) $robobs(meteo,global_comment)" 3

lassign [read_ups] resupss type
set textes ""
set ups_headerfits ""
if {$type!="No_UPS"} {
   foreach resups $resupss {
      set key [lindex $resups 0]
      set val [lindex $resups 1]
      set unit [lindex $resups 2]
      if {$unit=="text"} { set unit "" }
      if {$val=="undefined"} { continue }
      append textes " ${key}=${val} ${unit}."
      # ---
      if {$key=="OnBattery"} {
         lappend ups_headerfits [list UPSONBAT $val float "UPS on battery state (No|High|Low)" ""]
      }
   }
   ::robobs::log "UPS from $type: $textes" 3
   ::robobs::log "UPS check is $robobs(ups,global_check) $robobs(ups,global_comment)" 3
}
set robobs(next_scene,ups_infos) $resupss
set robobs(private,ups_headerfits) $ups_headerfits   

if {[info exists robobs(next_scene,action)]==1} {
   if {$robobs(next_scene,action)=="flat & dark"} {
      ::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
      return ""
   }
}

if {$robobs(planif,mode)=="trerrlyr"} {
   # === mode auto for Arduino
   mode auto
   # === Connexion IP CADOR
   package require http
   set err [catch {set ip [get_ipmodem]} msg]
   ::robobs::log "IP : $msg" 3
   if {$err==0} {
      set err [catch {set_ipmodem $ip} msg]
   }
}

#------------------------------------------------------------
## Explication de la procedure ?
#  @todo A completer
#  @note A completer
#  @param  void
#  @return void
#
proc robobs_tel_park {} {
   global robobs
   if {$robobs(conf,home,telescope_id,value)=="guitalens_taca"} {
      set hapark [mc_angle2deg 6h]
      set decpark [mc_angle2deg +90d 90]
      set hadec [tel1 hadec coord]
      set ha [lindex $hadec 0]
      set dec [lindex $hadec 1]
      set sepangle_etel [lindex [mc_anglesep [list $ha $dec $hapark $decpark]] 0]
      if {$sepangle>2} {      
         ::robobs::log "Separation from park is $sepangle degrees." 3
         # --- goto hadec park
         ::robobs::log "tel1 park" 3
         set t0 [clock seconds]
         if {$robobs(tel,name)=="simulation"} {
            after 3000
         } else {
            tel1 park
         }
         set dt [expr [clock seconds]-$t0]
         ::robobs::log "Telescope slew park..." 3
      }      
   }
   if {$robobs(planif,mode)=="vttrrlyr"} {
      set hapark [mc_angle2deg 18h]
      set decpark [mc_angle2deg 90d]
      set hadec [tel1 hadec coord]
      set ha [lindex $hadec 0]
      set dec [lindex $hadec 1]
      set sepangle [lindex [mc_anglesep [list $ha $dec $hapark $decpark]] 0]
      if {$sepangle>2} {      
         ::robobs::log "Separation from park is $sepangle degrees." 3
         # --- goto hadec park
         ::robobs::log "tel1 hadec goto [list 18h 90d] -blocking 1" 3
         set t0 [clock seconds]
         if {$robobs(tel,name)=="simulation"} {
            after 3000
         } else {
            tel1 hadec goto [list $hapark $decpark] -blocking 1
         }
         set dt [expr [clock seconds]-$t0]
         ::robobs::log "Telescope slew park finished in $dt seconds" 3
      }      
   }
   if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
      # --- check ETEL
      set hapark [mc_angle2deg 0h]
      set decpark [mc_angle2deg +60d 90]
      set hadec [tel1 hadec coord]
      set ha [lindex $hadec 0]
      set dec [lindex $hadec 1]
      set sepangle_etel [lindex [mc_anglesep [list $ha $dec $hapark $decpark]] 0]
      # --- Park
      if {($sepangle_etel>1)} {
         ::robobs::log "Separation from park is $sepangle_etel degrees." 3
         telpark
         ::robobs::log "Start park the telescope" 3
         set t0 [clock seconds]
         set sortie 0
         while {$sortie==0} {
            set dt [expr [clock seconds]-$t0]
            set hadec [tel1 hadec coord]
            ::robobs::log "Current position : HADEC = $hadec " 3
            set ha [lindex $hadec 0]
            set dec [lindex $hadec 1]
            set sepangle_etel [lindex [mc_anglesep [list $ha $dec $hapark $decpark]] 0]
            if {($sepangle_etel<0.2)||($dt>60)} {
               if {$dt>60} {
                  ::robobs::log "Exit park by timeout after $dt seconds." 3
               }
               set sortie 1
            }
            after 5000
         }
         ::robobs::log "Telescope parked." 3
      } else {
         ::robobs::log "Telescope already parked." 3
         tel1 radec stop
      }      
   }
   if {$robobs(conf,home,telescope_id,value)=="vtt2"} {
      set hapark [mc_angle2deg 18h]
      set decpark [mc_angle2deg 90d]
      set hadec [tel1 hadec coord]
      set ha [lindex $hadec 0]
      set dec [lindex $hadec 1]
      set sepangle [lindex [mc_anglesep [list $ha $dec $hapark $decpark]] 0]
      if {$sepangle>2} {      
         ::robobs::log "Separation from park is $sepangle degrees." 3
         # --- goto hadec park
         ::robobs::log "tel1 hadec goto [list 18h 90d] -blocking 1" 3
         set t0 [clock seconds]
         if {$robobs(tel,name)=="simulation"} {
            after 3000
         } else {
            tel1 hadec goto [list $hapark $decpark] -blocking 1
         }
         set dt [expr [clock seconds]-$t0]
         ::robobs::log "Telescope slew park finished in $dt seconds" 3
      }      
   }
   if {$robobs(planif,mode)=="trerrlyr"} {
      telpark
   }
}

#------------------------------------------------------------
## Explication de la procedure ?
#  @todo A completer
#  @note A completer
#  @param  void
#  @return void
#
proc robobs_dome_open {} {
   global robobs
   if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
      set res [roof get]
      set k [lsearch -exact $res Roof_state]
      if {$k!=-1} {
         set state [lindex $res [expr $k+1]]
         if {$state=="opened"} {
            ::robobs::log "Roof already opened." 3
         } else {
            roof open
            ::robobs::log "Open the rolling roof." 3
            after 1000
         }
      }
   }
   if {$robobs(planif,mode)=="trerrlyr"} {
      set res [lindex [roof debug] end]
      ::robobs::log "State of the rolling roof: $res" 3
      if {$res!="(opened)"} {
         roof open
         ::robobs::log "Open the rolling roof." 3
         after 1000
      } else {
         ::robobs::log "Roof already opened." 3
      }
   }
}

#------------------------------------------------------------
## Explication de la procedure ?
#  @todo A completer
#  @note A completer
#  @param  void
#  @return void
#
proc robobs_dome_close {} {
   global robobs
   if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
      set res [roof get]
      set k [lsearch -exact $res Roof_state]
      if {$k!=-1} {
         set state [lindex $res [expr $k+1]]
         if {$state=="closed"} {
            ::robobs::log "Roof already closed." 3
         } else {
            roof close
            ::robobs::log "Close the rolling roof." 3
            after 1000
         }
      }
   }
   if {$robobs(planif,mode)=="trerrlyr"} {
      roof close
   }
}

# Continue loopscript ------------------------------------------------------------

# --- Check sensors according the skylight (is the dome is opened/closed, the telescope parked, etc.)

if {$skylight=="Night"} {
   if {($robobs(meteo,global_check)=="OK")&&($robobs(ups,global_check)=="OK")} {
      # --- Check the dome is opened
      robobs_dome_open
   } else {
      # --- Check the dome is closed
      if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
         robobs_dome_close
         robobs_tel_park
      } else {
         robobs_tel_park
         robobs_dome_close
      }
   }
} elseif {$skylight=="Dusk"} {
   if {($robobs(meteo,global_check)=="OK")&&($robobs(ups,global_check)=="OK")} {
      # --- Check the dome is closed
      if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
         robobs_dome_close
         robobs_tel_park
      } else {
         robobs_tel_park
         robobs_dome_close
      }
   } else {
      # --- Check the dome is closed
      if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
         robobs_dome_close
         robobs_tel_park
      } else {
         robobs_tel_park
         robobs_dome_close
      }
   }
} elseif {$skylight=="Dawn"} {
   if {($robobs(meteo,global_check)=="OK")&&($robobs(ups,global_check)=="OK")} {
      # --- Check the dome is opened
      robobs_dome_open
   } else {
      # --- Check the dome is closed
      if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
         robobs_dome_close
         robobs_tel_park
      } else {
         robobs_tel_park
         robobs_dome_close
      }
   }
} elseif {$skylight=="Day"} {
   # --- Check the dome is closed in any case
   if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
      robobs_dome_close
      robobs_tel_park
   } else {
      robobs_tel_park
      robobs_dome_close
   }
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
