#
# Fichier : telscript_template_equatorial.tcl
# Description : Driver de monture en TCL
# Auteur : Alain KLOTZ
# Mise à jour $Id: telscript_template_equatorial.tcl 9982 2013-08-18 05:43:03Z robertdelmas $
#

# === Script to test and to develop a scripted telescope driver for AudeLA ===
#
# INTRODUCTION
# ------------
# Driving a telescope with AudeLA is based on a Tcl instantiation of
# an AudeLA object called tel1. The driver itself is written in C/C++
# code (source codes in audela/src/libtel).
#
# As a consequence, an astronomer interested to develop a new telescope
# driver for AudeLA must program the corresponding C/C++ code that is
# not easy for most astronomers.
#
# The libtelscript telescope library is a programmed C/C++ telescope
# driver for AudeLA that calls a Tcl script every few milliseconds.
# By this way it becomes possible to develop a Tcl script that can
# drive a telescope.
#
# AN EXAMPLE
# ----------
# The telscript_template_equatorial.tcl script simulates a basic equatorial telescope driver.
# To test this driver, type the following terminal command:
#
# tel::create telscript -telname mytel -script $audace(rep_install)/gui/audace/plugin/mount/telscript/telscript_template_equatorial.tcl -home \{$audace(posobs,observateur,gps)\}
#
# During the creation of tel1, firstly the script telscript_template_equatorial.tcl
# is sourced. This script must contains at less two procs: setup and loop
# (with no input parameters). Secondly, the proc setup is called. The
# contents of the setup proc should establish the physical connections
# with the telescope controller. Thirdly, the proc loop is called inside
# an infinite loop. The proc loop should contain the code to process the
# actions to drive the telescope.
#
# After the creation, the tel1 commands like "tel1 radec coord" and others
# can be used.
#
# VARIABLE EXHANGE BETWEEN C AND TCL
# ----------------------------------
# The Tcl array telscript is used to exchange data between the Tcl script
# and the C code of libtelscript. For this reason, don't forget to write
# global telscript as the first line of the procs of the script.
# Anyway, the variable telscript(def,telname) contains the name defined
# by the -telname option (=telscript_template_equatorial by default).
# Herafter we designed telname the value of telscript(def,telname).
#
# Before calling the loop proc, the following variables are updated
# from tel1 functions:
# telscript($telname,action_next)
#    = motor_on motor_off motor_stop radec_init radec_goto hadec_init hadec_goto move_start
#    Provided by "tel1 radec motor on|off" "tel1 radec stop" "tel1 radec init" "tel1 radec goto" "tel1 hadec init" "tel1 hadec goto" "tel1 radec move"
# telscript($telname,action_prev)
#    = previous action before moving by the move or by a goto
# telscript($telname,ha0)
#    = Hour angle position to reach for the next GOTO or for the next MATCH
#    Provided by "tel1 hadec init" "tel1 hadec goto"
# telscript($telname,ra0)
#    = Right Ascension position to reach for the next GOTO or for the next MATCH
#    Provided by "tel1 radec init" "tel1 radec goto"
# telscript($telname,dec0)
#    = Declination position to reach for the next GOTO or for the next MATCH
#    Provided by "tel1 radec init" "tel1 radec goto" "tel1 hadec init" "tel1 hadec goto"
# telscript($telname,radec_move_rate)
#    = Speed (0 to 1) for moving
#    Provided by "tel1 radec move"
# telscript($telname,move_direction)
#    = Direction (n,s,e,w) for moving
#    Provided by "tel1 radec move"
#
# After calling the loop proc, the following variables are commited
# to the C code to be used by tel1 functions:
# telscript($telname,coord_app_cod_deg_ra)
#    = Current Right Ascension position
#    Used by "tel1 radec coord"
# telscript($telname,coord_app_cod_deg_dec)
#    = Current Declination position
#    Used by "tel1 radec coord" "tel1 hadec coord"
# telscript($telname,coord_app_cod_deg_ha)
#    = Current Hour angle position
#    Used by "tel1 hadec coord"
# telscript($telname,action_next)
# telscript($telname,action_prev)=telscript($telname,action_next)
# telscript($telname,motion_next)
# telscript($telname,motion_prev)=telscript($telname,motion_next)
# telscript($telname,message)
#    Usefull to debug.
#
# tel1 SPECIAL FUNCTIONS
# ----------------------
#
# tel1 looperror
#      To read the errors found in the proc loop.
#      A empty string is returned if there is no error.
#
# tel1 source
#      To source again the script (useful to correct the loop proc)
#
# foreach res [lsort [tel1 variables]] { console::affiche_resultat "$res\n" }
#      To display the exchange variables
#
# tel1 loopeval
#      To send a string to evaluate inside the proc loop.
#      The result is displayed using "tel1 loopresult"
#
# tel1 loopresult
#      To display the result of "tel1 loopeval"
#
# tel1 action
#      To display the last action_next and the number of loops ever done.
#
# tel::create telscript -telname mytel -script $audace(rep_install)/gui/audace/scripts/telscript/telscript_template_equatorial.tcl -home \{$audace(posobs,observateur,gps)\}
# foreach res [lsort [tel1 variables]] { console::affiche_resultat "$res\n" }
#
# ============================================================================================

# --- common defined variables
# telscript(def,telname) is ever defined before the source of this script
set telscript(def,speed_diurnal) [expr 360./(23*3600+56*60+4)] ; # diurnal motion (deg/sec)
set telscript(def,goto,speed) 1 ; # GOTO speed (deg/sec)

# === Proc called one time at the start of the driver
proc setup { } {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)

   # --- Add extensions that are not loaded in the thread
   set pwd0 [pwd]
   set path [file dirname [info nameofexecutable]]
   cd $path
   load libaudela[info sharedlibextension]
   cd $pwd0

   # --- The initial telescope position is HA=0 and Dec=0 to UT time
   set telscript($telname,coord_app_cod_deg_ha)  0
   set telscript($telname,coord_app_cod_deg_dec) 0
   set date [date_sys2ut now]
   set telscript($telname,jdutc_app_cod) [mc_date2jd $date]

   # --- The initial telescope motion is "motor off"
   set telscript($telname,speed_app_cod_deg_ha) 0
   set telscript($telname,speed_app_cod_deg_dec) 0
   set telscript($telname,motion_next) "stopped"

   # --- Set a comment that the setup is OK
   set telscript($telname,status) "setup OK"
   #catch {set f [open "log.txt" w] ; close $f}
}

# === Proc called on loop after the start of the driver
proc loop { } {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)
   set home $telscript($telname,home)
   set telscript($telname,message) ""
   #catch {append telscript($telname,message) "DEBUG 0: telscript($telname,action_next)=$telscript($telname,action_next)\n"}

   # === Compute current apparent coordinates for "tel1 radec coord"
   set jd1 $telscript($telname,jdutc_app_cod)
   set date [date_sys2ut now]
   set jd2 [mc_date2jd $date]
   set lst [mc_date2lst $jd2 $home -format deg]
   set dsec [expr 86400.*($jd2-$jd1)]
   if {($telscript($telname,motion_next)=="radec_slewing")||($telscript($telname,motion_next)=="hadec_slewing")} {
      if {($telscript($telname,goto,speed_ha)==0)&&($telscript($telname,goto,speed_dec)==0)} {
         if {($telscript($telname,motion_next)=="radec_slewing")} {
            set dsec_start [expr 86400.*($jd2-$telscript($telname,goto,jd_start))]
            if {$dsec_start>2} {
               set telscript($telname,motion_next) "tracking"
            } else {
               # --- second GOTO to take acount for the slewing duration
               set telscript($telname,action_next) "radec_goto"
            }
         } else {
            set telscript($telname,motion_next) "stopped"
         }
      } else {
         set ha [expr $telscript($telname,coord_app_cod_deg_ha)+$dsec*$telscript($telname,goto,speed_ha)]
         set ha [expr fmod(720+$ha,360)]
         if {$ha>180} { set ha [expr $ha-360] }
         if {($telscript($telname,goto,speed_ha)>0)&&($ha>$telscript($telname,goto,halim))} {
            set ha $telscript($telname,goto,halim)
            set telscript($telname,goto,speed_ha) 0
         }
         if {($telscript($telname,goto,speed_ha)<0)&&($ha<$telscript($telname,goto,halim))} {
            set ha $telscript($telname,goto,halim)
            set telscript($telname,goto,speed_ha) 0
         }
         set dec [expr $telscript($telname,coord_app_cod_deg_dec)+$dsec*$telscript($telname,goto,speed_dec)]
         if {($telscript($telname,goto,speed_dec)>0)&&($dec>$telscript($telname,goto,declim))} {
            set dec $telscript($telname,goto,declim)
            set telscript($telname,goto,speed_dec) 0
         }
         if {($telscript($telname,goto,speed_dec)<0)&&($dec<$telscript($telname,goto,declim))} {
            set dec $telscript($telname,goto,declim)
            set telscript($telname,goto,speed_dec) 0
         }
      }
   } else {
      set ha  [expr $telscript($telname,coord_app_cod_deg_ha)+$dsec*$telscript($telname,speed_app_cod_deg_ha)]
      set ha [expr fmod(720+$ha,360)]
      set dec [expr $telscript($telname,coord_app_cod_deg_dec)+$dsec*$telscript($telname,speed_app_cod_deg_dec)]
   }
   set ra [expr fmod(720+$lst-$ha,360)]
   set telscript($telname,jdutc_app_cod) $jd2
   # --- variables used to commit "tel1 radec coord" and "tel1 hadec coord" after this proc
   set telscript($telname,coord_app_cod_deg_ha) $ha
   set telscript($telname,coord_app_cod_deg_dec) $dec
   set telscript($telname,coord_app_cod_deg_ra) $ra

   # === Process actions (actions are set by tel1 commands)
   if {$telscript($telname,action_next)=="motor_on"} {

      # --- Action = motor_on
      # (don't change telscript($telname,motion_next))
      if {$telscript($telname,motion_next)!="correction"} {
         set telscript($telname,speed_app_cod_deg_ha) $telscript(def,speed_diurnal)
         set telscript($telname,speed_app_cod_deg_dec) 0
         set telscript($telname,motion_prev) "tracking"
      }

   } elseif {$telscript($telname,action_next)=="motor_off"} {

      # --- Action = motor_off
      # (don't change telscript($telname,motion_next))
      if {$telscript($telname,motion_next)!="correction"} {
         set telscript($telname,speed_app_cod_deg_ha) 0
         set telscript($telname,speed_app_cod_deg_dec) 0
         set telscript($telname,motion_prev) "stopped"
      }

   } elseif {$telscript($telname,action_next)=="motor_stop"} {

      # --- Action = motor_stop
      if {$telscript($telname,motion_next)!="correction"} {
         set telscript($telname,speed_app_cod_deg_ha) 0
         set telscript($telname,speed_app_cod_deg_dec) 0
         set telscript($telname,motion_next) "stopped"
         set telscript($telname,action_next) "motor_off"
      } else {
         set direction [string toupper $telscript($telname,move_direction)]
         if {$telscript($telname,motion_prev)=="tracking"} {
            if {($direction=="N")||($direction=="S")} {
               set telscript($telname,speed_app_cod_deg_dec) 0
            }
            if {($direction=="W")||($direction=="E")} {
               set telscript($telname,speed_app_cod_deg_ha) $telscript(def,speed_diurnal)
            }
            if {($telscript($telname,speed_app_cod_deg_dec)==0)&&($telscript($telname,speed_app_cod_deg_ha)==$telscript(def,speed_diurnal))} {
               set telscript($telname,motion_next) "$telscript($telname,motion_prev)"
            }
         } else {
            if {($direction=="N")||($direction=="S")} {
               set telscript($telname,speed_app_cod_deg_dec) 0
            }
            if {($direction=="W")||($direction=="E")} {
               set telscript($telname,speed_app_cod_deg_ha) 0
            }
            if {($telscript($telname,speed_app_cod_deg_dec)==0)&&($telscript($telname,speed_app_cod_deg_ha)==0)} {
               set telscript($telname,motion_next) "$telscript($telname,motion_prev)"
            }
         }
      }

   } elseif {$telscript($telname,action_next)=="radec_init"} {

      # --- Action = radec_init
      set telscript($telname,coord_app_cod_deg_ra) $telscript($telname,ra0)
      set telscript($telname,coord_app_cod_deg_ha) [expr fmod(720+$lst-$telscript($telname,coord_app_cod_deg_ra),360)]
      set telscript($telname,coord_app_cod_deg_dec) $telscript($telname,dec0)
      set telscript($telname,action_next) "motor_on"

   } elseif {$telscript($telname,action_next)=="radec_goto"} {

      # --- Action = radec_goto
      set ra0 $telscript($telname,ra0)
      set dec0 $telscript($telname,dec0)
      set ha0 [expr fmod(720+$lst-$ra0,360)]
      if {$ha0>180} { set ha0 [expr $ha0-360] }
      if {$ha>180} { set ha [expr $ha-360] }
      set dha [expr $ha0-$ha] ; # western positive
      set telscript($telname,goto,halim) $ha0
      set telscript($telname,goto,speed_ha) $telscript(def,goto,speed)
      if {$dha<0} {
         set telscript($telname,goto,speed_ha) [expr -1*$telscript($telname,goto,speed_ha)]
      }
      set ddec [expr $dec0-$dec] ; # northern positive
      set telscript($telname,goto,declim) $dec0
      set telscript($telname,goto,speed_dec) $telscript(def,goto,speed)
      if {$ddec<0} {
         set telscript($telname,goto,speed_dec) [expr -1*$telscript($telname,goto,speed_dec)]
      }
      set telscript($telname,goto,jd_start) $telscript($telname,jdutc_app_cod)
      set telscript($telname,motion_next) "radec_slewing"
      set telscript($telname,action_next) "motor_on"

   } elseif {$telscript($telname,action_next)=="hadec_init"} {

      # --- Action = radec_init
      set telscript($telname,coord_app_cod_deg_ha) $telscript($telname,ha0)
      set telscript($telname,coord_app_cod_deg_ra) [expr fmod(720+$lst-$telscript($telname,coord_app_cod_deg_ha),360)]
      set telscript($telname,coord_app_cod_deg_dec) $telscript($telname,dec0)
      set telscript($telname,action_next) "motor_off"

   } elseif {$telscript($telname,action_next)=="hadec_goto"} {

      # --- Action = hadec_goto
      set ha0 $telscript($telname,ha0)
      set dec0 $telscript($telname,dec0)
      if {$ha0>180} { set ha0 [expr $ha0-360] }
      if {$ha>180} { set ha [expr $ha-360] }
      set dha [expr $ha0-$ha] ; # western positive
      set telscript($telname,goto,halim) $ha0
      set telscript($telname,goto,speed_ha) $telscript(def,goto,speed)
      if {$dha<0} {
         set telscript($telname,goto,speed_ha) [expr -1*$telscript($telname,goto,speed_ha)]
      }
      set ddec [expr $dec0-$dec] ; # northern positive
      set telscript($telname,goto,declim) $dec0
      set telscript($telname,goto,speed_dec) $telscript(def,goto,speed)
      if {$ddec<0} {
         set telscript($telname,goto,speed_dec) [expr -1*$telscript($telname,goto,speed_dec)]
      }
      set telscript($telname,goto,jd_start) $telscript($telname,jdutc_app_cod)
      set telscript($telname,motion_next) "hadec_slewing"
      set telscript($telname,action_next) "motor_off"

   } elseif {$telscript($telname,action_next)=="move_start"} {

      # --- Action = move_start
      set rate $telscript($telname,radec_move_rate)
      if {$rate<=0.25} {
         set speed $telscript(def,speed_diurnal)
      } elseif {$rate<=0.5} {
         set speed 0.1
      } elseif {$rate<=0.75} {
         set speed 0.5
      } else {
         set speed 2
      }
      if {$telscript($telname,motion_prev)=="tracking"} {
         set cur_speed_ha  $telscript(def,speed_diurnal)
         set cur_speed_dec 0
      } else {
         set cur_speed_ha  0
         set cur_speed_dec 0
      }
      set direction [string toupper $telscript($telname,move_direction)]
      if {$direction=="N"} {
         set telscript($telname,speed_app_cod_deg_dec) [expr $cur_speed_dec+$speed]
      } elseif {$direction=="S"} {
         set telscript($telname,speed_app_cod_deg_dec) [expr $cur_speed_dec-$speed]
      } elseif {$direction=="W"} {
         set telscript($telname,speed_app_cod_deg_ha) [expr $cur_speed_ha+$speed]
      } elseif {$direction=="E"} {
         set telscript($telname,speed_app_cod_deg_ha) [expr $cur_speed_ha-$speed]
      }
      set telscript($telname,motion_next) "correction"

   }

   # --- Set a comment that the loop is OK
   set telscript($telname,status) "loop OK"

   # set f [open "log.txt" a] ; puts "============================\n$telscript($telname,message)" ; close $f
}

# === This proc returns the UTC date
proc date_sys2ut { { date now } } {
   if { $date == "now" } {
      set time [ clock format [ clock seconds ] -format "%Y %m %d %H %M %S" -timezone :UTC ]
   } else {
      set jjnow [ mc_date2jd $date ]
      set time  [ mc_date2ymdhms $jjnow ]
   }
   return $time
}

