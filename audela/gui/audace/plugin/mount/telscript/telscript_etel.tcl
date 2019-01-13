#
# Fichier : telscript_etel.tcl
# Description : Driver de la monture T940 en TCL
# Auteur : Alain KLOTZ & Pierre THIERRY
# Mise à jour $Id: telscript_etel.tcl 11009 2014-09-27 15:07:29Z robertdelmas $
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
# The telscript_etel.tcl script simulates a basic equatorial telescope driver.
# To test this driver, type the following terminal command:
#
# tel::create telscript -telname t940 -script $audace(rep_install)/gui/audace/plugin/mount/telscript/telscript_etel.tcl -home \{$audace(posobs,observateur,gps)\}
#
# During the creation of tel1, firstly the script telscript_etel.tcl
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
# by the -telname option (=telscript_etel by default).
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
# tel::create telscript -telname mytel -script $audace(rep_install)/gui/audace/scripts/telscript/telscript_etel.tcl -home \{$audace(posobs,observateur,gps)\}
# tel::create telscript -telname t940 -script $audace(rep_install)/gui/audace/plugin/mount/telscript/telscript_etel.tcl -home \{$audace(posobs,observateur,gps)\}
# foreach res [lsort [tel1 variables]] { console::affiche_resultat "$res\n" }
#
# ============================================================================================

# --- common defined variables
# telscript(def,telname) is ever defined before the source of this script
set telscript(def,speed_diurnal) [expr 360./(23*3600+56*60+4)] ; # diurnal motion (deg/sec)

# ################################################################################
# ### Proc called one time at the start of the driver
# ################################################################################
proc setup { } {
   global telscript audace
   package require twapi
   # --- Get useful variables
   set telname $telscript(def,telname)
   catch {exec espeak.exe -v fr "Démarre setup"}

   # --- Select the type of mount
   if {$telname=="t940"} {
      set telscript($telname,mount_type) azelevrot
      set telscript($telname,mount_type) azelev
   }
   if {$telname=="rapido"} {
      set telscript($telname,mount_type) hadec
   }
   if {$telname=="t400"} {
      set telscript($telname,mount_type) hadec
   }

   # === compatibility with Aud'ACE procs
   set path [file dirname [info nameofexecutable]]
   set audace(rep_install) [file normalize ${path}/..]
   set audace(rep_gui) "$audace(rep_install)/gui"
   set audace(rep_catalogues) "$audace(rep_gui)/audace/catalogues"
   source ${path}/../gui/audace/celestial_mechanics.tcl
   source ${path}/../gui/audace/satel.tcl
   source ${path}/../gui/audace/vo_tools.tcl
   package require http
   namespace eval ::console {
      proc affiche_resultat { msg } { }
   }

   # === check the functions if not loaded in the thread
   set pwd0 [pwd]
   cd $path
   load libaudela[info sharedlibextension]
   catch {load libeteltcl[info sharedlibextension]}
   # --- Open the ports for combits
   set telscript($telname,combitnum0) 2
   set telscript($telname,combitnum1) 3
   set err [catch {
      porttalk open all
      load libcombit[info sharedlibextension]
      set telscript($telname,combit0) [open COM$telscript($telname,combitnum0) "RDWR"]
      fconfigure $telscript($telname,combit0) -mode "9600,n,8,1" -buffering none -blocking 0
      set telscript($telname,combit1) [open COM$telscript($telname,combitnum1) "RDWR"]
      fconfigure $telscript($telname,combit1) -mode "9600,n,8,1" -buffering none -blocking 0
      combit $telscript($telname,combitnum0) 3 0
      combit $telscript($telname,combitnum0) 4 0
      combit $telscript($telname,combitnum0) 7 0
      combit $telscript($telname,combitnum1) 3 0
      combit $telscript($telname,combitnum1) 4 0
      combit $telscript($telname,combitnum1) 7 0
   }  msg ]
   set telscript($telname,z1) "$err $msg"
   if {$err==1} {
      proc combit { args } {
         global telscript
         # --- Get useful variables
         set telname $telscript(def,telname)
         set argc  [llength $args]
         set argv0 [lindex $args 0]
         set argv1 [lindex $args 1]
         set argv2 [lindex $args 2]
         set res 0
         if {($argc==2)&&($argv0=="2")} {
            # --- simule le combit de changement de mode
            if {($telscript($telname,combit_simu_mode)=="rapide")&&($argv1=="1")} { set res 1 }
            if {($telscript($telname,combit_simu_mode)=="lente")&&($argv1=="6")} { set res 1 }
            if {($telscript($telname,combit_simu_mode)=="spectro")&&($argv1=="8")} { set res 1 }
            if {$res==1} {
               set telscript($telname,combit_simu_mode) ""
            }
         }
         if {($argc==2)&&($argv0=="1")} {
            # --- simule le combit de direction
            # set telscript($telname,combit_simu_direction) N
            if {($telscript($telname,combit_simu_direction)=="N")&&($argv1=="1")} { set res 1 }
            if {($telscript($telname,combit_simu_direction)=="S")&&($argv1=="9")} { set res 1 }
            if {($telscript($telname,combit_simu_direction)=="E")&&($argv1=="8")} { set res 1 }
            if {($telscript($telname,combit_simu_direction)=="W")&&($argv1=="6")} { set res 1 }
         }
         return $res
      }
      set telscript($telname,combit0) simu0
      set telscript($telname,combit1) simu1
      set telscript($telname,combit_simu_mode) "rapide"
      set telscript($telname,combit_simu_direction) ""
   } else {
      catch {
         catch {exec espeak.exe -v fr "Raquette active."}
         after 500
      }
   }
   set telscript($telname,focus_controler) arduino
   if {$telscript($telname,focus_controler)=="combit"} {
      # --- open the combit
      set telscript($telname,combitnum2) 4
      set err [catch {
         set telscript($telname,combit2) [open COM$telscript($telname,combitnum2) "RDWR"]
         fconfigure $telscript($telname,combit2) -mode "9600,n,8,1" -buffering none -blocking 0
         combit $telscript($telname,combitnum2) 3 0
         combit $telscript($telname,combitnum2) 4 0
         combit $telscript($telname,combitnum2) 7 0
      }  msg ]
      set telscript($telname,z3) "$err $msg"
      if {$err==1} {
         set telscript($telname,combit2) simu2
         set telscript($telname,combit_simu_direction) ""
      } else {
         catch {
            catch {exec espeak.exe -v fr "Focuss actif. commebitt."}
            after 500
         }
      }
   } else {
      # --- open the Arduino
      set telscript($telname,comarduinonum0) //./com13
      set err [catch {
         set telscript($telname,comarduino0) [open COM$telscript($telname,comarduinonum0) w+]
         fconfigure $telscript($telname,comarduino0) -mode "9600,n,8,1" -buffering none -blocking 0 -translation {binary binary}
      }  msg ]
      set telscript($telname,z2) "$err $msg"
      if {$err==1} {
         set telscript($telname,comarduino0) simu0
         set telscript($telname,combit_simu_direction) ""
      } else {
         catch {
            catch {exec espeak.exe -v fr "Raquette active arduino."}
            after 500
         }
      }
   }
   cd $pwd0

   after 1000
   # --- Open the ETEL connection
   load libeteltcl
   if {$telscript($telname,mount_type)=="azelevrot"} {
      # --- axe az=0 (etel=2)
      # --- axe elev=1 (etel=5)
      # --- axe rot=2 (etel=4)
      set err [catch {etel_open -driver com1 -axis 2 -axis 5 -axis 4} msg]
      catch {exec espeak.exe -v fr "altaz avec rotation"}
   } elseif {$telscript($telname,mount_type)=="azelev"} {
      catch {exec espeak.exe -v fr "altaz sans rotation"}
      set err [catch {etel_open -driver com1 -axis 2 -axis 5} msg]
   } elseif {$telscript($telname,mount_type)=="hadec"} {
      set err [catch {etel_open -driver com1 -axis 0 -axis 1} msg]
      catch {exec espeak.exe -v fr "équatorial"}
   } else {
      set err 1
   }
   if {$err==0} {
      set telscript($telname,simulation) 0
      catch {
         catch {exec espeak.exe -v fr "Controlleur oké"}
         after 500
      }
   } else {
      catch {
         catch {exec espeak.exe -v fr "Simulation"}
         after 500
      }
      set telscript($telname,simulation) 1
      set telscript($telname,etel_msg) $msg
      # --- inhibe les appels ETEL en mode simulation
      proc etel_status { args } {
      }
      proc etel_get_register_s { args } {
         global telscript
         set res 0
         set telname $telscript(def,telname)
         lassign $args axe reg num
         if {($axe=="0")&&($reg=="M")&&($num=="7")} {
            set res $telscript($telname,coord_app_adu_az0)
         }
         if {($axe=="1")&&($reg=="M")&&($num=="7")} {
            set home $telscript($telname,home)
            set latitude [lindex $home 3]
            set app_dec -40
            set elev [expr 90-$latitude+$app_dec]
            set res [expr $telscript($telname,coord_app_adu_elev0)+6.26*$telscript($telname,adu4deg_elev)]
         }
         return $res
      }
      proc etel_set_register_s { args } {
      }
      proc etel_execute_command_x_s { args } {
      }
   }

   # --- modele de pointage
   if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
      set telscript($telname,modpoi_symbols) {IA IE}
      set telscript($telname,modpoi_values) {0 0}
   }
   if {$telscript($telname,mount_type)=="hadec"} {
      set telscript($telname,modpoi_symbols) {IH ID}
      set telscript($telname,modpoi_values) {0 0}
   }

   source $audace(rep_install)/gui/audace/plugin/mount/telscript/telscript_etel.tcl

   if {$telscript($telname,simulation)==0} {

      # --- Lancement des routines controleurs
      etel_execute_command_x_s 1 79 0
      etel_execute_command_x_s 1 26 1 0 0 79
      etel_execute_command_x_s 0 79 0
      etel_execute_command_x_s 0 26 1 0 0 79
      if {$telscript($telname,mount_type)=="azelevrot"} {
         etel_execute_command_x_s 2 79 0
         etel_execute_command_x_s 2 26 1 0 0 79
      }
      load_params
      #---arret de tous les moteurs
      etel_execute_command_x_s ! 69 1 0 0 0

   } else {

      load_params

   }

   # --- The initial telescope motion is "motor off"
   set telscript($telname,speed_app_cod_deg_ha) 0
   set telscript($telname,speed_app_cod_deg_dec) 0
   set telscript($telname,motion_next) "stopped"
   set telscript($telname,action_next) "motor_off"
   set telscript($telname,action_prev) $telscript($telname,action_next)
   set telscript($telname,motor_prev) $telscript($telname,action_next)
   set telscript($telname,goto,object) ""
   set telscript($telname,drift_move_rate) 1
   set telscript($telname,move_generator) 0
   set telscript($telname,speed_virtual_pad) 0
   set telscript($telname,move_virtual_pad) ""
   set telscript($telname,move_virtual_foc) ""
   set telscript($telname,speed_app_adu_mult) 1.
   set telscript($telname,external_trigger) 0 ; # 0= AudeLA+Aud'ACE   1= interface graphique specifique
   set telscript($telname,external_move_direction) ""

   # --- Set a comment that the setup is OK
   set telscript($telname,status) "setup OK"
   catch {set f [open "log.txt" w] ; close $f}
   catch {exec espeak.exe -v fr "Entre dans la boucle."}
}

# ################################################################################
# ### Proc called on loop after the start of the driver
# ################################################################################
proc loop { } {
   global telscript audace
   # --- Get useful variables
   set telname $telscript(def,telname)
   set home $telscript($telname,home)
   set telscript($telname,message) ""
   #catch {append telscript($telname,message) "DEBUG 0:\n"}
   #catch {set f [open "log.txt" a] ; puts $f "[mc_date2iso8601 now] ==============================================="; close $f}
   #catch {set f [open "log.txt" a] ; puts $f "[mc_date2iso8601 now] Etape 10 = $telscript($telname,action_next) / $telscript($telname,motor_prev) motion=$telscript($telname,motion_next) \n$telscript($telname,goto,object)"; close $f}

   # === Read current apparent coordinates for "tel1 radec coord"
   get_pos_adus
   adus2degs
   lassign [degs2radec] raj2000 decj2000
   # --- variables used to commit "tel1 radec coord" and "tel1 hadec coord" after this proc
   set telscript($telname,coord_app_cod_deg_ha)  $telscript($telname,coord_app_deg_ha)
   set telscript($telname,coord_app_cod_deg_dec) $telscript($telname,coord_app_deg_dec)
   set telscript($telname,coord_app_cod_deg_ra)  $telscript($telname,coord_app_deg_ra)

   # === Read if an external trigger for goto was actived
   if {($telscript($telname,external_trigger)==1)} {
      set goto_status ""
      if {([info exists telscript($telname,goto,status)]==1)&&([info exists telscript($telname,goto,object)]==1)} {
         set goto_status $telscript($telname,goto,status)
         if {$goto_status=="todo"} {
            set telscript($telname,action_next) "radec_goto"
         }
      }
   }

   # === Read the end of a slewing
   if {($telscript($telname,motion_next)=="slewing")||($telscript($telname,motion_next)=="slewing2")} {
      set valid 0
      if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
         set daz [expr $telscript($telname,coord_app_adu_az)-$telscript($telname,coord0_app_adu_az)]
         if {[expr abs($daz)<2000]} { incr valid }
         set delev [expr $telscript($telname,coord_app_adu_elev)-$telscript($telname,coord0_app_adu_elev)]
         if {[expr abs($delev)<2000]} { incr valid }
      }
      if {$telscript($telname,mount_type)=="azelevrot"} {
         set drot [expr $telscript($telname,coord_app_adu_rot)-$telscript($telname,coord0_app_adu_rot)]
         if {[expr abs($drot)<2000]} { incr valid }
      }
      if {$telscript($telname,mount_type)=="hadec"} {
         set dha [expr $telscript($telname,coord_app_adu_ha)-$telscript($telname,coord0_app_adu_ha)]
         if {[expr abs($dha)<2000]} { incr valid }
         set ddec [expr $telscript($telname,coord_app_adu_dec)-$telscript($telname,coord0_app_adu_dec)]
         if {[expr abs($ddec)<2000]} { incr valid }
      }
      if {((($telscript($telname,mount_type)=="azelev")||($telscript($telname,mount_type)=="hadec"))&&($valid==2))||(($telscript($telname,mount_type)=="azelevrot")&&($valid==3))} {
         if {$telscript($telname,motion_next)=="slewing"} {
            catch {espeak "Premier pointage terminé."}
            # - faire le second pointage
            set telscript($telname,action_next) "radec_goto2"
            lassign [object2radec] raj2000 decj2000 drift_ra drift_dec
         } else {
            catch {espeak "Second pointage terminé."}
            lassign $telscript($telname,goto,object) objname0 objtype objname raj2000 decj2000 drift_ra drift_dec
            if {($objname0=="*STOP")||($objname0=="*PARK")} {
               set telscript($telname,action_next) motor_off
            } else {
               set telscript($telname,action_next) motor_on
            }
         }
         set telscript($telname,motion_next) "stopped"
      }
   }

   # === Read the pad buttons
   get_pad_buttons
   get_pad_focus
   #espeak "$telscript($telname,action_next)"

   # === Process actions (actions are set by tel1 commands)

   if {$telscript($telname,action_next)=="motor_on"} {

      # --- Action = motor_on
      if {$telscript($telname,motion_next)!="correction"} {
         set telscript($telname,speed_app_adu_mult) 1.
         lassign [object2radec] raj2000 decj2000 drift_ra drift_dec
         radec2degs goto $raj2000 $decj2000 $drift_ra $drift_dec
         degs2adus goto
         set_speed_adus
         set telscript($telname,motion_next) "drift"
         set telscript($telname,motor_prev) $telscript($telname,action_next)
      }

   } elseif {$telscript($telname,action_next)=="motor_off"} {

      # --- Action = motor_off
      if {$telscript($telname,motion_next)!="correction"} {
         set telscript($telname,ra00) $raj2000
         set telscript($telname,dec00) $decj2000
         set telscript($telname,goto,object) ""
         stop_motors
         set telscript($telname,motion_next) "stopped"
         set telscript($telname,action_next) "motor_off"
         set telscript($telname,motor_prev) $telscript($telname,action_next)
      }

   } elseif {$telscript($telname,action_next)=="motor_stop"} {

      # --- Action = motor_stop
      set telscript($telname,ra00) $raj2000
      set telscript($telname,dec00) $decj2000
      set telscript($telname,goto,object) ""
      stop_motors
      set telscript($telname,motion_next) "stopped"
      set telscript($telname,action_next) "motor_off"

   } elseif {$telscript($telname,action_next)=="radec_init"} {

      # --- Action = radec_init
      if {$telscript($telname,motion_next)=="drift"} {
         lassign [object2radec] raj2000 decj2000 drift_ra drift_dec
         radec2degs goto $raj2000 $decj2000 $drift_ra $drift_dec
         degs2adus goto
         if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
            set adu0 [expr $telscript($telname,coord_app_adu_az)-($telscript($telname,goto_app_deg_az)-$telscript($telname,coord_app_deg_az0))*$telscript($telname,adu4deg_az)]
            set telscript($telname,coord_app_adu_az0) [expr round($adu0)]
            set adu0 [expr $telscript($telname,coord_app_adu_elev)-($telscript($telname,goto_app_deg_elev)-$telscript($telname,coord_app_deg_elev0))*$telscript($telname,adu4deg_elev)]
            set telscript($telname,coord_app_adu_elev0) [expr round($adu0)]
            if {($telscript($telname,mount_type)=="azelevrot")} {
               set adu0 [expr $telscript($telname,coord_app_adu_rot)-($telscript($telname,goto_app_deg_rot)-$telscript($telname,coord_app_deg_rot0))*$telscript($telname,adu4deg_rot)]
               set telscript($telname,coord_app_adu_rot0) [expr round($adu0)]
            }
         }
         if {$telscript($telname,mount_type)=="hadec"} {
            set adu0 [expr $telscript($telname,coord_app_adu_ha)-($telscript($telname,simugoto_app_deg_ha)-$telscript($telname,coord_app_deg_ha0))*$telscript($telname,adu4deg_ha)]
            set telscript($telname,coord_app_adu_ha0) [expr round($adu0)]
            set adu0 [expr $telscript($telname,coord_app_adu_dec)-($telscript($telname,simugoto_app_deg_dec)-$telscript($telname,coord_app_deg_dec0))*$telscript($telname,adu4deg_dec)]
            set telscript($telname,coord_app_adu_dec0) [expr round($adu0)]
         }
         set telscript($telname,action_next) $telscript($telname,motor_prev)
      }

   } elseif {$telscript($telname,action_next)=="radec_goto"} {

      # --- Action = radec_goto
      catch {espeak "Pointage."}
      lassign [object2radec] raj2000 decj2000 drift_ra drift_dec 3.
      radec2degs goto $raj2000 $decj2000 $drift_ra $drift_dec
      degs2adus goto
      set_pos_adus
      set telscript($telname,goto,status) ""
      set telscript($telname,motion_next) "slewing"
      set telscript($telname,action_next) "radec_goto2"
      after 1000

   } elseif {($telscript($telname,action_next)=="radec_goto2")&&($telscript($telname,motion_next)=="stopped")} {

      # --- Action = radec_goto2
      radec2degs goto $raj2000 $decj2000 $drift_ra $drift_dec 3.
      degs2adus goto
      set_pos_adus
      set telscript($telname,goto,status) ""
      set telscript($telname,motion_next) "slewing2"
      after 300

   } elseif {$telscript($telname,action_next)=="radec_goto_stop"} {

      # --- Action = motor_stop
      set telscript($telname,ra00) $raj2000
      set telscript($telname,dec00) $decj2000
      set telscript($telname,goto,object) ""
      stop_motors
      catch {espeak "Stoppe les moteurs."}
      set telscript($telname,motion_next) "stopped"
      set telscript($telname,action_next) "motor_off"

   } elseif {$telscript($telname,action_next)=="hadec_init"} {

      # --- Action = hadec_init

   } elseif {$telscript($telname,action_next)=="hadec_goto"} {

      # --- Action = hadec_goto

   } elseif {$telscript($telname,action_next)=="move_start"} {

      # --- Action = move_start
      if {$telscript($telname,motion_next)!="correction"} {
         if {$telscript($telname,move_generator)==0} {
            # --- from tel1 radec move
            set direction [string toupper $telscript($telname,move_direction)]
            set rate $telscript($telname,radec_move_rate)
            set telscript($telname,drift_move_rate) $telscript($telname,radec_move_rate)
         } else {
            # --- from external (combit, gui pad)
            set direction [string toupper $telscript($telname,external_move_direction)]
            set rate $telscript($telname,drift_move_rate)
         }
         if {$rate<=0.35} {
            start_shift_spectro $direction
         } elseif {$rate<=0.70} {
            start_shift_lent $direction
         } else {
            start_shift_rapide $direction
         }
      }
      set telscript($telname,motion_next) "correction"

   } elseif {$telscript($telname,action_next)=="move_stop"} {

      # --- Action = move_stop
      if {$telscript($telname,motion_next)=="correction"} {
         set direction [string toupper $telscript($telname,move_direction)]
         if {$telscript($telname,move_generator)==0} {
            set direction [string toupper $telscript($telname,move_direction)]
            set rate $telscript($telname,radec_move_rate)
            set telscript($telname,drift_move_rate) $telscript($telname,radec_move_rate)
         } else {
            set rate $telscript($telname,drift_move_rate)
            set direction [string toupper $telscript($telname,external_move_direction)]
         }
         if {$rate<=0.35} {
            stop_shift_spectro $direction
         } elseif {$rate<=0.70} {
            stop_shift_lent $direction
         } else {
            stop_shift_rapide $direction
         }
         set telscript($telname,move_generator) 0
         set telscript($telname,motion_next) ""
      }
      set telscript($telname,action_next) $telscript($telname,motor_prev)
      set telscript($telname,move_virtual_pad) ""

   } elseif {$telscript($telname,action_next)=="focus_start +"} {

      # --- Action = focus_start +
      if {$telscript($telname,motion_next)!="correction"} {
         if {$telscript($telname,focus_controler)=="combit"} {
            if {$telscript($telname,combit2)!="simu2"} {
               combit $telscript($telname,combitnum2) 3 0 ; # sélectionne le sens 1 de mise au point
               combit $telscript($telname,combitnum2) 4 1 ; # sélecteur actif raquette physique déconnectée le moteur tourne dans le sens 1
            }
         } else {
            if {$telscript($telname,comarduino0)!="simu2"} {
               puts -nonewline $telscript($telname,comarduino0) "pad_focus+\n"
            }
         }
      }
      set telscript($telname,motion_next) "correction"

   } elseif {$telscript($telname,action_next)=="focus_start -"} {

      # --- Action = focus_start -
      if {$telscript($telname,motion_next)!="correction"} {
         if {$telscript($telname,focus_controler)=="combit"} {
            if {$telscript($telname,combit2)!="simu2"} {
               combit $telscript($telname,combitnum2) 3 1 ; # sélectionne le sens 2 de mise au point
               combit $telscript($telname,combitnum2) 4 1 ; # sélecteur actif raquette physique déconnectée le moteur tourne dans le sens 2
            }
         } else {
            if {$telscript($telname,comarduino0)!="simu2"} {
               puts -nonewline $telscript($telname,comarduino0) "pad_focus-\n"
            }
         }
      }
      set telscript($telname,motion_next) "correction"

   } elseif {$telscript($telname,action_next)=="focus_stop"} {

      # --- Action = focus_stop
      if {$telscript($telname,motion_next)=="correction"} {
         if {$telscript($telname,focus_controler)=="combit"} {
            if {$telscript($telname,combit2)!="simu2"} {
               combit $telscript($telname,combitnum2) 4 0 ; # sélecteur inactif raquette physique reconnectée le moteur s'arrête.
            }
         } else {
            if {$telscript($telname,comarduino0)!="simu2"} {
               puts -nonewline $telscript($telname,comarduino0) "pad_focus_stop\n"
            }
         }
      }
      set telscript($telname,action_next) $telscript($telname,motor_prev)
      set telscript($telname,move_virtual_foc) ""

   }

   # === Store adus to detect the end of a slewing
   if {($telscript($telname,motion_next)=="slewing")||($telscript($telname,motion_next)=="slewing2")} {
      if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
         set telscript($telname,coord0_app_adu_az) $telscript($telname,coord_app_adu_az)
         set telscript($telname,coord0_app_adu_elev) $telscript($telname,coord_app_adu_elev)
      }
      if {$telscript($telname,mount_type)=="azelevrot"} {
         set telscript($telname,coord0_app_adu_rot) $telscript($telname,coord_app_adu_rot)
      }
      if {$telscript($telname,mount_type)=="hadec"} {
         set telscript($telname,coord0_app_adu_ha) $telscript($telname,coord_app_adu_ha)
         set telscript($telname,coord0_app_adu_dec) $telscript($telname,coord_app_adu_dec)
      }
   }

   # --- Set a comment that the loop is OK
   set telscript($telname,status) "loop OK"

   #catch {set f [open "log.txt" a] ; puts $f "[mc_date2iso8601 now] Etape 1000 = $telscript($telname,action_next) / $telscript($telname,motor_prev) motion=$telscript($telname,motion_next) \n$telscript($telname,goto,object)"; close $f}
}

# ################################################################################
# ### Proc called in the loop to return the current J2000 coordinates for a given object
# ################################################################################
proc object2radec { } {
   global telscript
   # --- Get useful variables
   set t0 [mc_date2jd now]
   set telname $telscript(def,telname)
   if {($telscript($telname,external_trigger)==1)} {
      if {[llength $telscript($telname,goto,object)]>0} {
         lassign $telscript($telname,goto,object) objname0 objtype objname raj2000 decj2000 drift_ra drift_dec
         if {$objtype!="coords"} {
            set key [string index $objname0 0]
            if {($objname0=="*GEO")||($objname0=="*GPS")} {
               lassign [decode_radec_entry "${key}${objname}"] objtype objname raj2000 decj2000 drift_ra drift_dec
            } else {
               lassign [decode_radec_entry $objname0] objtype objname raj2000 decj2000 drift_ra drift_dec
            }
         }
      } else {
         set raj2000 $telscript($telname,ra00)
         set decj2000 $telscript($telname,dec00)
         set drift_ra 0
         set drift_dec 0
      }
   } else {
      set raj2000 $telscript($telname,ra0)
      set decj2000 $telscript($telname,dec0)
      set drift_ra 0
      set drift_dec 0
   }
   set telscript($telname,time_compute_radec) [expr 86400.*([mc_date2jd now]-$t0)]
   return [list $raj2000 $decj2000 $drift_ra $drift_dec]
}

# ################################################################################
# ### proc lecture des boutons des raquettes autres que Aud'ACE
# ################################################################################
# global inputs:
# telscript($telname,motion_next)
# telscript($telname,speed_virtual_pad)
# telscript($telname,move_virtual_pad)
# telscript($telname,move_direction)
# global outputs:
# telscript($telname,action_next) "move_start"
# telscript($telname,move_direction) NSEW
# telscript($telname,move_generator) 1
# ################################################################################
proc get_pad_buttons {} {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)

   if {($telscript($telname,motion_next)!="slewing")&&($telscript($telname,motion_next)!="slewing2")} {

      if {$telscript($telname,focus_controler)=="combit"} {
         #ajout des bits de changement de mode des vitesses de raquette en les dédoublant pour eviter les courants fugififs
         set v1 "[combit $telscript($telname,combitnum1) 1]"
         set v2 "[combit $telscript($telname,combitnum1) 6]"
         set v3 "[combit $telscript($telname,combitnum1) 8]"
         after 100
         set v11 "[combit $telscript($telname,combitnum1) 1]"
         set v21 "[combit $telscript($telname,combitnum1) 6]"
         set v31 "[combit $telscript($telname,combitnum1) 8]"
         set v1 [expr $v1+$v11]
         set v2 [expr $v2+$v21]
         set v3 [expr $v3+$v31]
         # mesure de la variable d'état des vitesses
         set v $telscript($telname,speed_virtual_pad)
         set telscript($telname,speed_virtual_pad) 0
         if {($v1 == 2) || ($v==1) }  {
            catch {espeak "raquette rapide."}
            set telscript($telname,drift_move_rate) 1
         }
         if {$v2 == 2 || ($v==2) }  {
            catch {espeak "raquette lente."}
            set telscript($telname,drift_move_rate) 0.5
         }
         if {$v3 == 2 || ($v==3) }  {
            catch {espeak "raquette spectro."}
            set telscript($telname,drift_move_rate) 0.1
         }

         # mesure de la variable d'état des bits de rappel
         if {$telscript($telname,move_virtual_pad)!=""} {
            # utilisation raquette soft (boutons de l'interface graphique)
            lassign $telscript($telname,move_virtual_pad) actif sens
            set telscript($telname,speed_virtual_pad) ""
            if {$telscript($telname,motion_next)!="correction"} {
               if {($actif=="1")}  {
                  set telscript($telname,action_next) "move_start"
                  set telscript($telname,external_move_direction) [string toupper $sens]
                  set telscript($telname,move_generator) 1
               }
            } else {
               if {($actif=="0")}  {
                  set telscript($telname,action_next) "move_stop"
               }
            }
         } else {
            # utilisation raquette physique (boutons combit)
            if {$telscript($telname,motion_next)!="correction"} {
               set rappel 0
               set n "[combit $telscript($telname,combitnum0) 1]"
               if {($n == 1) }  {
                  set telscript($telname,action_next) "move_start"
                  set telscript($telname,external_move_direction) N
                  set telscript($telname,move_generator) 1
               }
               set s "[combit $telscript($telname,combitnum0) 9]"
               if {($s == 1) }  {
                  set telscript($telname,action_next) "move_start"
                  set telscript($telname,external_move_direction) S
                  set telscript($telname,move_generator) 1
               }
               set e "[combit $telscript($telname,combitnum0) 8]"
               if {($e == 1) }  {
                  set telscript($telname,action_next) "move_start"
                  set telscript($telname,external_move_direction) E
                  set telscript($telname,move_generator) 1
               }
               set o "[combit $telscript($telname,combitnum0) 6]"
               if {($o == 1) }  {
                  set telscript($telname,action_next) "move_start"
                  set telscript($telname,external_move_direction) W
                  set telscript($telname,move_generator) 1
               }
            } else {
               # detecte la relache des bits de rappel (utilisation raquette soft)
               set rappel 1
               if {$telscript($telname,external_move_direction)=="N"} {
                  set rappel "[combit $telscript($telname,combitnum0) 1]"
               }
               if {$telscript($telname,external_move_direction)=="S"} {
                  set rappel "[combit $telscript($telname,combitnum0) 9]"
               }
               if {$telscript($telname,external_move_direction)=="E"} {
                  set rappel "[combit $telscript($telname,combitnum0) 8]"
               }
               if {$telscript($telname,external_move_direction)=="W"} {
                  set rappel "[combit $telscript($telname,combitnum0) 6]"
               }
               if {($rappel == 0)}  {
                  set telscript($telname,action_next) "move_stop"
               }
            }
         }
      } else {
         puts -nonewline $telscript($telname,comarduino0) "read_digital_pins\n"
         after 200
         set res [read  -nonewline $telscript($telname,comarduino0)]

         set code [lindex $res 0]
         if {$code=="tel"} {
            # --- mode telescope
            set telscript($telname,pad,haut) [lindex $res 1]
            set telscript($telname,pad,bas) [lindex $res 2]
            set telscript($telname,pad,droite) [lindex $res 3]
            set telscript($telname,pad,gauche) [lindex $res 4]
            set telscript($telname,pad,rapide) [lindex $res 5]
            set telscript($telname,pad,lente)  [lindex $res 6]
            set telscript($telname,pad,spectro) [lindex $res 7]
            set telscript($telname,pad,suivfich) [lindex $res  8]
            set telscript($telname,pad,suivant) [lindex $res 9]
            set telscript($telname,pad,focus_plus) [lindex $res 10]
            set telscript($telname,pad,focus_moins) [lindex $res 11]
            set telscript($telname,pad,pourcent)  [lindex $res 12]
            set telscript($telname,pad,delta0) [lindex $res 13]
            set telscript($telname,pad,pointer) [lindex $res 14]

            #CALCUL DES VITESSES ET ACCELERATION RAQUETTE
            set telscript($telname,pad,pourcent_az)     $telscript($telname,pad,pourcent)
            set telscript($telname,pad,pourcent_ht)    $telscript($telname,pad,pourcent)

            set telscript($telname,pad,v_rap) [expr $telscript($telname,pad,v_rap0)* $telscript($telname,pad,pourcent)/20]
            set telscript($telname,pad,ac_rap) [expr $telscript($telname,pad,ac_rap0)* $telscript($telname,pad,pourcent)/20]
            set telscript($telname,pad,v_rap) [expr round($telscript($telname,pad,v_rap)) ]
            set telscript($telname,pad,ac_rap) [expr round($telscript($telname,pad,ac_rap)) ]
            set telscript($telname,pad,vra) [expr 1000* $telscript($telname,pad,pourcent)/30]
            set telscript($telname,pad,vrh)    [expr 12000* $telscript($telname,pad,pourcent)/30]

            # mesure de la variable d'état des vitesses
            if {$telscript($telname,pad,rapide)==1}  {
               catch {espeak "raquette rapide."}
               set telscript($telname,drift_move_rate) 1
            }
            if {$telscript($telname,pad,lente)==1}  {
               catch {espeak "raquette lente."}
               set telscript($telname,drift_move_rate) 0.5
            }
            if {$telscript($telname,pad,spectro)==1}  {
               catch {espeak "raquette spectro."}
               set telscript($telname,drift_move_rate) 0.1
            }

            # mesure de la variable d'état des bits de rappel
            if {$telscript($telname,move_virtual_pad)!=""} {
               # utilisation raquette soft (boutons de l'interface graphique)
               lassign $telscript($telname,move_virtual_pad) actif sens
               set telscript($telname,speed_virtual_pad) ""
               if {$telscript($telname,motion_next)!="correction"} {
                  if {($actif=="1")}  {
                     set telscript($telname,action_next) "move_start"
                     set telscript($telname,external_move_direction) [string toupper $sens]
                     set telscript($telname,move_generator) 1
                  }
               } else {
                  if {($actif=="0")}  {
                     set telscript($telname,action_next) "move_stop"
                  }
               }
            } else {
               # utilisation raquette physique (boutons arduino)
               if {$telscript($telname,motion_next)!="correction"} {
                  set rappel 0
                  set n $telscript($telname,pad,haut)
                  if {($n == 1) }  {
                     set telscript($telname,action_next) "move_start"
                     set telscript($telname,external_move_direction) N
                     set telscript($telname,move_generator) 1
                  }
                  set s $telscript($telname,pad,bas)
                  if {($s == 1) }  {
                     set telscript($telname,action_next) "move_start"
                     set telscript($telname,external_move_direction) S
                     set telscript($telname,move_generator) 1
                  }
                  set e $telscript($telname,pad,gauche)
                  if {($e == 1) }  {
                     set telscript($telname,action_next) "move_start"
                     set telscript($telname,external_move_direction) E
                     set telscript($telname,move_generator) 1
                  }
                  set o $telscript($telname,pad,droite)
                  if {($o == 1) }  {
                     set telscript($telname,action_next) "move_start"
                     set telscript($telname,external_move_direction) W
                     set telscript($telname,move_generator) 1
                  }
               } else {
                  # detecte l'appuis sur les boutons de focus
                  if {$telscript($telname,pad,focus_plus)==1}  {
                     gui_start_focus base.f.ffoc.fr2.but_w +
                  }
                  if {$telscript($telname,pad,focus_moins)==1}  {
                     gui_start_focus base.f.ffoc.fr2.but_e -
                  }
                  # detecte la relache des bits de rappel (utilisation raquette soft)
                  set rappel 1
                  if {$telscript($telname,external_move_direction)=="N"} {
                     set rappel $telscript($telname,pad,haut)
                  }
                  if {$telscript($telname,external_move_direction)=="S"} {
                     set rappel $telscript($telname,pad,bas)
                  }
                  if {$telscript($telname,external_move_direction)=="E"} {
                     set rappel $telscript($telname,pad,gauche)
                  }
                  if {$telscript($telname,external_move_direction)=="W"} {
                     set rappel $telscript($telname,pad,droite)
                  }
                  if {($rappel == 0)}  {
                     set telscript($telname,action_next) "move_stop"
                  }
               }
            }
         } elseif {$code=="pas"} {
            # --- mode passerelle
            set telscript($telname,pad,hautp) [lindex $res 1]
            set telscript($telname,pad,basp) [lindex $res 2]
            set telscript($telname,pad,droitep) [lindex $res 3]
            set telscript($telname,pad,gauchep) [lindex $res 4]
            set telscript($telname,pad,coupdr) [lindex $res 5]
            set telscript($telname,pad,coupg)  [lindex $res 6]
            set telscript($telname,pad,focus_plus) [lindex $res 7]
            set telscript($telname,pad,focus_moins) [lindex $res 8]
            # detecte l'appuis sur les boutons de focus (TODO)
         }
      }
   }
}

# ################################################################################
# ### proc lecture des boutons de focus autres que Aud'ACE
# ################################################################################
# global inputs:
# telscript($telname,motion_next)
# global outputs:
# ################################################################################
proc get_pad_focus {} {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)
   if {($telscript($telname,motion_next)!="slewing")&&($telscript($telname,motion_next)!="slewing2")} {
      if {$telscript($telname,move_virtual_foc)!=""} {
         # utilisation raquette soft (boutons de l'interface graphique)
         lassign $telscript($telname,move_virtual_foc) actif sens
         if {$telscript($telname,motion_next)!="correction"} {
            if {($actif=="1")}  {
               set telscript($telname,action_next) "pad_focus$sens"
               set telscript($telname,move_generator) 1
            }
         } else {
            if {($actif=="0")}  {
               set telscript($telname,action_next) "pad_focus_stop"
            }
         }
      }
   }
}

# ################################################################################
# ### proc direction2axesens
# ################################################################################
proc direction2axesens { direction } {
   set axe 1 ; set sens 1
   if {$direction=="N"} {
      set axe 1 ; set sens 1
   } elseif {$direction=="S"} {
      set axe 1 ; set sens 0
   } elseif {$direction=="E"} {
      set axe 0 ; set sens 1
   } elseif {$direction=="W"} {
      set axe 0 ; set sens 0
   }
   return [list $axe $sens]
}

# ################################################################################
# ### proc stop_shift_rapide
# ################################################################################
# global inputs:
# global outputs:
# + motor commands (26/74)
# ################################################################################
proc stop_shift_rapide { {direction N } } {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)
   lassign [direction2axesens $direction] axe sens
   # commande obligatoire sur les dscdm et sur les dsc2p
   etel_execute_command_x_s $axe 26 1 0 0 74
   # --- Faut-il remettre les vitesses des X26 et X27 ?
}

# ################################################################################
# ### proc start_shift_rapide
# ################################################################################
# global inputs:
# telscript($telname,speed_app_adu_*)
# global outputs:
# + motor commands (26/75 26/76)
# ################################################################################
proc start_shift_rapide { direction } {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)
   lassign [direction2axesens $direction] axe sens
   if {$axe==0} {
      if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
         set v0 $telscript($telname,speed_app_adu_az)
      } elseif {$telscript($telname,mount_type)=="hadec"} {
         set v0 $telscript($telname,speed_app_adu_ha)
      }
   } else {
      if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
         set v0 $telscript($telname,speed_app_adu_elev)
      } elseif {$telscript($telname,mount_type)=="hadec"} {
         set v0 $telscript($telname,speed_app_adu_dec)
      }
   }
   # --- on stocke temporairement les vitesses actuelles
   #etel_set_register_s $axe X 27 0  $v0
   #etel_set_register_s $axe X 26 0  $v0
   # --- start_motion
   if {$sens==1} {
      etel_execute_command_x_s $axe 26 1 0 0 75
   } else {
      etel_execute_command_x_s $axe 26 1 0 0 76
   }
}

# ################################################################################
# ### proc stop_shift_lent
# ################################################################################
# global inputs:
# global outputs:
# + motor commands (26/74)
# ################################################################################
proc stop_shift_lent { {direction N } } {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)
   lassign [direction2axesens $direction] axe sens
   # commande obligatoire sur les dscdm et sur les dsc2p
   etel_execute_command_x_s $axe 26 1 0 0 74
   # --- Faut-il remettre les vitesses des X26 et X27 ?
}

# ################################################################################
# ### proc start_shift_lent
# ################################################################################
# global inputs:
# telscript($telname,speed_app_adu_*)
# + motor register (X40)
# global outputs:
# + motor register (X41 X42 X43)
# + motor commands (26/82 26/83 26/84 26/85)
# ################################################################################
proc start_shift_lent { direction } {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)
   lassign [direction2axesens $direction] axe sens
   #
   set vrh  [etel_get_register_s $axe X 41]
   #récupération de la vitesse actuelle de suivi
   if {$axe==0} {
      if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
         set v0 $telscript($telname,speed_app_adu_az)
      } elseif {$telscript($telname,mount_type)=="hadec"} {
         set v0 $telscript($telname,speed_app_adu_ha)
      }
   } else {
      if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
         set v0 $telscript($telname,speed_app_adu_elev)
      } elseif {$telscript($telname,mount_type)=="hadec"} {
         set v0 $telscript($telname,speed_app_adu_dec)
      }
   }
   set vh $v0
   #vitesse rappel lent plus
   set vhr [expr $vh+$vrh]
   #vitesse rappel lent moins
   set vhl [expr $vh-$vrh]
   #enregistrement vitesses
   etel_set_register_s $axe X 42 0 [expr abs($vhr) ]
   etel_set_register_s $axe X 43 0 [expr abs($vhl) ]
   #::console::affiche_resultat "  $vrh $vh $ $vhr $vhl \n"
   #récupération du sens actuel de rotation
   set sens [etel_get_register_s $axe X 40]
   #mouvement télescope
   if {$direction=="N"} {
      if { $sens == 1  } {
         etel_execute_command_x_s $axe 26 1 0 0 83
      }
      if { $sens == 0  } {
         if { $vhl < 0  } {
            etel_execute_command_x_s $axe 26 1 0 0 83
         }
         if { $vhl >= 0  } {
            etel_execute_command_x_s $axe 26 1 0 0 85
         }
      }
   }

   if {$direction=="S"} {
      if { $sens == 0  } {
         etel_execute_command_x_s $axe 26 1 0 0 84
      }
      if { $sens == 1  } {
         if { $vhr < 0  } {
            etel_execute_command_x_s $axe 26 1 0 0 82
         }
         if { $vhr >= 0  } {
            etel_execute_command_x_s $axe 26 1 0 0 84
         }
      }
   }
  if {$direction=="E"} {
      if { $sens == 1  } {
         etel_execute_command_x_s $axe 26 1 0 0 83
      }
      if { $sens == 0  } {
         if { $vhl < 0  } {
            etel_execute_command_x_s $axe 26 1 0 0 84
         }
         if { $vhl >= 0  } {
            etel_execute_command_x_s $axe 26 1 0 0 82
         }
      }
   }
   if {$direction=="W"} {
      if { $sens == 0  } {
         etel_execute_command_x_s $axe 26 1 0 0 85
      }
      if { $sens == 1  } {
         if { $vhl < 0  } {
            etel_execute_command_x_s $axe 26 1 0 0 85
         }
         if { $vhl >= 0  } {
            etel_execute_command_x_s $axe 26 1 0 0 83
         }
      }
   }

}

# ################################################################################
# ### proc stop_shift_spectro
# ################################################################################
# global inputs:
# global outputs:
# telscript($telname,speed_app_adu_mult) = 1
# ################################################################################
proc stop_shift_spectro { {direction N } } {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)
   lassign [direction2axesens $direction] axe sens
   set telscript($telname,speed_app_adu_mult) 1.
   # --- Faut-il remettre les vitesses des X26 et X27 ?
}

# ################################################################################
# ### proc start_shift_spectro
# ################################################################################
# global inputs:
# + motor register (X40)
# global outputs:
# telscript($telname,speed_app_adu_mult) = 0.99 ou 1.01
# ################################################################################
proc start_shift_spectro { direction } {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)
   lassign [direction2axesens $direction] axe sens
   #récupération du sens actuel de rotation
   set sens [etel_get_register_s $axe X 40]
   set percent 1.
   if {$direction=="N"} {
      set telscript($telname,speed_app_adu_mult) [expr 1.-$percent/100.]
   }
   if {$direction=="S"} {
      set telscript($telname,speed_app_adu_mult) [expr 1.+$percent/100.]
   }
   if {$direction=="E"} {
      set telscript($telname,speed_app_adu_mult) [expr 1.-$percent/100.]
   }
   if {$direction=="W"} {
      set telscript($telname,speed_app_adu_mult) [expr 1.+$percent/100.]
   }
}

# ################################################################################
# ### proc stop motors
# ################################################################################
# global inputs:
# global outputs:
# telscript($telname,speed_app_deg_*) = 0
# telscript($telname,speed_app_adu_*) = 0
# + motor commands (124/0)
# ################################################################################
proc stop_motors { } {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)
   set telscript($telname,speed_app_deg_az) 0
   set telscript($telname,speed_app_deg_elev) 0
   set telscript($telname,speed_app_deg_ha) 0
   set telscript($telname,speed_app_deg_dec) 0
   set telscript($telname,speed_app_deg_rot) 0
   set telscript($telname,speed_app_adu_az) 0
   set telscript($telname,speed_app_adu_elev) 0
   set telscript($telname,speed_app_adu_ha) 0
   set telscript($telname,speed_app_adu_dec) 0
   set telscript($telname,speed_app_adu_rot) 0
   set_speed_adus
}

# ################################################################################
# ### proc vitesses en adu apparents
# ################################################################################
# global inputs:
# telscript($telname,speed_app_deg_*)
# telscript($telname,adu4deg4sec_*)
# telscript($telname,speed_app_adu_mult)
# global outputs:
# + motor register (X13)
# + motor commands (26/71 26/72)
# ################################################################################
proc set_speed_adus { } {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)
   set app_drift_az $telscript($telname,speed_app_deg_az) ; # vitesse demandee (arcsec/sec)
   set app_drift_elev $telscript($telname,speed_app_deg_elev)
   set app_drift_HA $telscript($telname,speed_app_deg_ha)
   set app_drift_dec $telscript($telname,speed_app_deg_dec)
   set app_drift_rot $telscript($telname,speed_app_deg_rot)
   set coef 15.041; #$app_drift_HA (arcsec/sec) pour conversion en arcsec/15sec
   if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
      set vs $telscript($telname,adu4deg4sec_az) ; # vitesse coef (adu/(deg/s))
      set vadu [expr round(-$app_drift_az/$coef*$vs/1000.)]
      set telscript($telname,speed_app_adu_az) $vadu
      set vadu [expr $vadu*$telscript($telname,speed_app_adu_mult)]
      etel_set_register_s 0 X 13 0 [expr abs($vadu)]
      if {$vadu>=0} {
         etel_execute_command_x_s 0 26 1 0 0 72
      } else {
         etel_execute_command_x_s 0 26 1 0 0 71
      }
      set vs $telscript($telname,adu4deg4sec_elev)
      set vadu [expr round(-$app_drift_elev/$coef*$vs/1000.)]
      set telscript($telname,speed_app_adu_elev) $vadu
      set vadu [expr $vadu*$telscript($telname,speed_app_adu_mult)]
      etel_set_register_s 1 X 13 0 [expr abs($vadu)]
      if {$vadu>=0} {
         etel_execute_command_x_s 1 26 1 0 0 71
      } else {
         etel_execute_command_x_s 1 26 1 0 0 72
      }
   }
   if {$telscript($telname,mount_type)=="azelevrot"} {
      if {1==0} {
         set vs $telscript($telname,adu4deg4sec_rot)
         set vadu [expr round(-$app_drift_rot/$coef*$vs/1000.)]
         set telscript($telname,speed_app_adu_rot) $vadu
         set vadu [expr $vadu*$telscript($telname,speed_app_adu_mult)]
         etel_set_register_s 2 X 13 0 [expr abs($vadu)]
         if {$vadu>=0} {
            etel_execute_command_x_s 2 26 1 0 0 72
         } else {
            etel_execute_command_x_s 2 26 1 0 0 71
         }
      }
   }
   if {$telscript($telname,mount_type)=="hadec"} {
      set vs $telscript($telname,adu4deg4sec_ha)
      set vadu [expr round(-$app_drift_HA/$coef*$vs/1000.)]
      set telscript($telname,speed_app_adu_ha) $vadu
      set vadu [expr $vadu*$telscript($telname,speed_app_adu_mult)]
      etel_set_register_s 0 X 13 0 [expr abs($vadu)]
      if {$vadu>=0} {
         etel_execute_command_x_s 0 26 1 0 0 72
      } else {
         etel_execute_command_x_s 0 26 1 0 0 71
      }
      set vs $telscript($telname,adu4deg4sec_dec)
      set vadu [expr round(-$app_drift_dec/$coef*$vs/1000.)]
      set telscript($telname,speed_app_adu_dec) $vadu
      set vadu [expr $vadu*$telscript($telname,speed_app_adu_mult)]
      etel_set_register_s 1 X 13 0 [expr abs($vadu)]
      if {$vadu>=0} {
         etel_execute_command_x_s 1 26 1 0 0 71
      } else {
         etel_execute_command_x_s 1 26 1 0 0 72
      }
   }
   after 200
}

# ################################################################################
# ### proc goto en adu apparents
# ################################################################################
# global inputs:
# telscript($telname,goto_app_adu_*)
# global outputs:
# + motor register (X21)
# + motor commands (26/73)
# ################################################################################
proc set_pos_adus { } {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)
   set date $telscript($telname,jdutc_app_adu)
   if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
      etel_set_register_s 0 X 21 0 [expr round($telscript($telname,goto_app_adu_az))]
      etel_set_register_s 1 X 21 0 [expr round($telscript($telname,goto_app_adu_elev))]
      etel_execute_command_x_s 0 26 1 0 0 73
      etel_execute_command_x_s 1 26 1 0 0 73
   }
   if {$telscript($telname,mount_type)=="azelevrot"} {
      if {1==0} {
         etel_set_register_s 2 X 21 0 [expr round($telscript($telname,goto_app_adu_rot))]
         etel_execute_command_x_s 2 26 1 0 0 73
      }
   }
   if {$telscript($telname,mount_type)=="hadec"} {
      etel_set_register_s 0 X 21 0 [expr round($telscript($telname,goto_app_adu_ha))]
      etel_set_register_s 1 X 21 0 [expr round($telscript($telname,goto_app_adu_dec))]
      etel_execute_command_x_s 0 26 1 0 0 73
      etel_execute_command_x_s 1 26 1 0 0 73
   }
   #after 1500
}


# ################################################################################
# ### proc save_x_stop_controlers => voir proc save_params a utiliser avant
# ################################################################################
proc save_x_stop_controlers { {stop 0 } } {
   global telscript
   # --- Set useful variables
   set telname $telscript(def,telname)
   if {1==0} {
      if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
         etel_set_register_s 0 X 26 0 $telscript($telname,adu4deg4sec_az)
         etel_set_register_s 0 X 27 0 $telscript($telname,adu4deg4sec_az)
         etel_set_register_s 0 X 28 0 [expr abs($telscript($telname,adu4deg_az))]
         etel_set_register_s 0 X 29 0 [expr abs($telscript($telname,adu4deg_az))]
         etel_set_register_s 0 X 62 0 $telscript($telname,coord_app_adu_az0)
         etel_set_register_s 1 X 26 0 $telscript($telname,adu4deg4sec_elev)
         etel_set_register_s 1 X 27 0 $telscript($telname,adu4deg4sec_elev)
         etel_set_register_s 1 X 28 0 [expr abs($telscript($telname,adu4deg_elev))]
         etel_set_register_s 1 X 29 0 [expr abs($telscript($telname,adu4deg_elev))]
         etel_set_register_s 1 X 62 0 $telscript($telname,coord_app_adu_elev0)
      }
      if {$telscript($telname,mount_type)=="azelevrot"} {
         etel_set_register_s 2 X 26 0 $telscript($telname,adu4deg4sec_rot)
         etel_set_register_s 2 X 27 0 $telscript($telname,adu4deg4sec_rot)
         etel_set_register_s 2 X 28 0 [expr abs($telscript($telname,adu4deg_rot))]
         etel_set_register_s 2 X 29 0 [expr abs($telscript($telname,adu4deg_rot))]
         etel_set_register_s 2 X 62 0 $telscript($telname,coord_app_adu_rot0)
      }
      if {$telscript($telname,mount_type)=="hadec"} {
         etel_set_register_s 0 X 26 0 $telscript($telname,adu4deg4sec_ha)
         etel_set_register_s 0 X 27 0 $telscript($telname,adu4deg4sec_ha)
         etel_set_register_s 0 X 28 0 [expr abs($telscript($telname,adu4deg_ha))]
         etel_set_register_s 0 X 29 0 [expr abs($telscript($telname,adu4deg_ha))]
         etel_set_register_s 0 X 62 0 $telscript($telname,coord_app_adu_ha0)
         etel_set_register_s 1 X 26 0 $telscript($telname,adu4deg4sec_dec)
         etel_set_register_s 1 X 27 0 $telscript($telname,adu4deg4sec_dec)
         etel_set_register_s 1 X 28 0 [expr abs($telscript($telname,adu4deg_dec))]
         etel_set_register_s 1 X 29 0 [expr abs($telscript($telname,adu4deg_dec))]
         etel_set_register_s 1 X 62 0 $telscript($telname,coord_app_adu_dec0)
      }
   }
   # --- 119 arrete les moteurs. On ne peut pas s'en affranchir sinon on tue les setting de l'axe 0
   # ---  79 envoie un reset errors au controleur
   etel_execute_command_x_s 0 119 0
   after 1000
   etel_execute_command_x_s 0 79 0
   after 1000
   etel_execute_command_x_s 1 119 0
   after 1000
   etel_execute_command_x_s 1 79 0
   after 1000
   if {$telscript($telname,mount_type)=="azelevrot"} {
      etel_execute_command_x_s 2 119 0
      after 1000
      etel_execute_command_x_s 2 79 0
      after 1000
   }
}

# ################################################################################
# ### proc save_params (remplace save_x_stop_controlers)
# ################################################################################
proc save_params { } {
   global telscript
   # --- Set useful variables
   set telname $telscript(def,telname)
   set lignes ""
   append lignes "# sauvegarde faite le [mc_date2iso8601 now] avec telscript_etel.tcl\n"
   append lignes "# monture type $telscript($telname,mount_type)\n"
   if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
      append lignes "# === axe az\n"
      append lignes "set register_0_X_26 $telscript($telname,adu4deg4sec_az) ; # vitesse coef (adu/(deg/s))\n"
      append lignes "set register_0_X_27 $telscript($telname,adu4deg4sec_az) ; \n"
      append lignes "set register_0_X_28 [expr abs($telscript($telname,adu4deg_az))] ; # position coef (adu/deg)\n"
      append lignes "set register_0_X_29 [expr abs($telscript($telname,adu4deg_az))]\n"
      append lignes "set register_0_X_62 $telscript($telname,coord_app_adu_az0) ; # position init (adu)\n"
      append lignes "set register_0_X_60 $telscript($telname,lim_min_az) ; # limite inf adu\n"
      append lignes "set register_0_X_61 $telscript($telname,lim_max_az) ; # limite inf adu\n"
      append lignes "# === axe elev\n"
      append lignes "set register_1_X_26 $telscript($telname,adu4deg4sec_elev) ; # vitesse coef (adu/(deg/s))\n"
      append lignes "set register_1_X_27 $telscript($telname,adu4deg4sec_elev)\n"
      append lignes "set register_1_X_28 [expr abs($telscript($telname,adu4deg_elev))] ; # position coef (adu/deg)\n"
      append lignes "set register_1_X_29 [expr abs($telscript($telname,adu4deg_elev))]\n"
      append lignes "set register_1_X_62 $telscript($telname,coord_app_adu_elev0) ; # position init (adu)\n"
      append lignes "set register_1_X_60 $telscript($telname,lim_min_elev) ; # limite inf adu\n"
      append lignes "set register_1_X_61 $telscript($telname,lim_max_elev) ; # limite inf adu\n"
      append lignes "# === axe rot\n"
      append lignes "set register_2_X_26 $telscript($telname,adu4deg4sec_rot) ; # vitesse coef (adu/(deg/s))\n"
      append lignes "set register_2_X_27 $telscript($telname,adu4deg4sec_rot)\n"
      append lignes "set register_2_X_28 [expr abs($telscript($telname,adu4deg_rot))] ; # position coef (adu/deg)\n"
      append lignes "set register_2_X_29 [expr abs($telscript($telname,adu4deg_rot))]\n"
      append lignes "set register_2_X_62 $telscript($telname,coord_app_adu_rot0) ; # position init (adu)\n"
      append lignes "set register_2_X_60 $telscript($telname,lim_min_rot) ; # limite inf adu\n"
      append lignes "set register_2_X_61 $telscript($telname,lim_max_rot) ; # limite inf adu\n"
   }
   if {$telscript($telname,mount_type)=="hadec"} {
      append lignes "# === axe ha\n"
      append lignes "set register_0_X_26 $telscript($telname,adu4deg4sec_ha) ; # vitesse coef (adu/(deg/s))\n"
      append lignes "set register_0_X_27 $telscript($telname,adu4deg4sec_ha)\n"
      append lignes "set register_0_X_28 [expr abs($telscript($telname,adu4deg_ha))] ; # position coef (adu/deg)\n"
      append lignes "set register_0_X_29 [expr abs($telscript($telname,adu4deg_ha))]\n"
      append lignes "set register_0_X_62 $telscript($telname,coord_app_adu_ha0) ; # position init (adu)\n"
      append lignes "set register_0_X_60 $telscript($telname,lim_min_ha) ; # limite inf adu\n"
      append lignes "set register_0_X_61 $telscript($telname,lim_max_ha) ; # limite inf adu\n"
      append lignes "# === axe dec\n"
      append lignes "set register_1_X_26 $telscript($telname,adu4deg4sec_dec) ; # vitesse coef (adu/(deg/s))\n"
      append lignes "set register_1_X_27 $telscript($telname,adu4deg4sec_dec)\n"
      append lignes "set register_1_X_28 [expr abs($telscript($telname,adu4deg_dec))] ; # position coef (adu/deg)\n"
      append lignes "set register_1_X_29 [expr abs($telscript($telname,adu4deg_dec))]\n"
      append lignes "set register_1_X_62 $telscript($telname,coord_app_adu_dec0) ; # position init (adu)\n"
      append lignes "set register_1_X_60 $telscript($telname,lim_min_dec) ; # limite inf adu\n"
      append lignes "set register_1_X_61 $telscript($telname,lim_max_dec) ; # limite inf adu\n"
   }
   append lignes "# === offsets de delta0\n"
   append lignes "set telscript($telname,pad,off-zero-az) $telscript($telname,off-zero-az); # offset delta0\n"
   append lignes "set telscript($telname,pad,off-zero-ht) $telscript($telname,off-zero-ht); # offset delta0\n"
   package require registry
   set mesDocuments [ ::registry get "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders" Personal ]
   set rep_log [ file normalize [ file join $mesDocuments audela ] ]
   file mkdir $rep_log
   set ficlog ${rep_log}/etel_register.log
   set f [open $ficlog w]
   puts -nonewline $f $lignes
   close $f
}

# ################################################################################
# ### proc load_params
# ################################################################################
proc load_params { } {
   global telscript
   # --- Set useful variables
   set telname $telscript(def,telname)
   package require registry
   set mesDocuments [ ::registry get "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders" Personal ]
   set rep_log [ file normalize [ file join $mesDocuments audela ] ]
   set ficlog ${rep_log}/etel_register.log
   if {[file exist $ficlog]==0} {
      # --- Recuperation des parametres monture pour simulation
      if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
         # --- az
         set register_0_X_26 651568 ; # vitesse coef (adu/(deg/s))
         set register_0_X_27 651568 ; # vitesse coef (adu/(deg/s))
         set register_0_X_28 3640000 ; # position coef (adu/deg)
         set register_0_X_29 3640000 ; # position coef (adu/deg)
         set register_0_X_62 660097614  ; # position init (adu)
         set register_0_X_60 75815853  ; # limite inf adu
         set register_0_X_61 1719983053  ; # limite sup adu
         # --- elev
         set register_1_X_26 7635922 ; # vitesse coef (adu/(deg/s))
         set register_1_X_27 7635922 ; # vitesse coef (adu/(deg/s))
         set register_1_X_28 14307595 ; # position coef (adu/deg)
         set register_1_X_29 14307595 ; # position coef (adu/deg)
         set register_1_X_62 304766223 ; # position init (adu)
         set register_1_X_60 363742618  ; # limite inf adu
         set register_1_X_61 1635256918 ; # limite sup adu
         # --- rot
         set register_2_X_26 924300.0  ; # vitesse coef (adu/(deg/s))
         set register_2_X_27 924300.0  ; # vitesse coef (adu/(deg/s))
         set register_2_X_28 1244885380  ; # position coef (adu/deg)
         set register_2_X_29 1244885380  ; # position coef (adu/deg)
         set register_2_X_62 0 ; # position init (adu)
         set register_2_X_60 20971520 ; # limite inf adu
         set register_2_X_61 1265856900 ; # limite sup adu
      }
      if {$telscript($telname,mount_type)=="hadec"} {
         # --- ha
         set register_0_X_26 651568 ; # vitesse coef (adu/(deg/s))
         set register_0_X_28 3640000 ; # position coef (adu/deg)
         set register_0_X_62 672077190 ; # position init (adu)
         set register_0_X_60 [expr 672077188-180*3640000] ; # limite inf adu
         set register_0_X_61 [expr 672077188+180*3640000] ; # limite sup adu
         # --- dec
         set register_1_X_26 7817302 ; # vitesse coef (adu/(deg/s))
         set register_1_X_28 14570000 ; # position coef (adu/deg)
         set register_1_X_62 0 ; # position init (adu)
         set register_1_X_60 0 ; # limite inf adu
         set register_1_X_61 0 ; # limite sup adu
      }
      # --- offsets delta0
      set telscript($telname,off-zero-az) $telscript($telname,pad,off-zero-az)
      set telscript($telname,off-zero-ht) $telscript($telname,pad,off-zero-ht)
   } else {
      source $ficlog
   }
   # --- Recuperation des parametres monture
   if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
      # --- az
      set telscript($telname,adu4deg4sec_az)    $register_0_X_26 ; # vitesse coef (adu/(deg/s))
      set telscript($telname,adu4deg_az)        $register_0_X_28 ; # position coef (adu/deg)
      set telscript($telname,coord_app_adu_az0) $register_0_X_62 ; # position init (adu)
      set telscript($telname,coord_app_deg_az0) 0 ; # position init (deg)
      set telscript($telname,lim_min_az)        $register_0_X_60 ; # limite inf adu
      set telscript($telname,lim_max_az)        $register_0_X_61 ; # limite sup adu
      # --- special T940 on change les signes des coefs
      set telscript($telname,adu4deg_az)        [expr -1*$telscript($telname,adu4deg_az)]
      # --- elev
      set telscript($telname,adu4deg4sec_elev)    $register_1_X_26 ; # vitesse coef (adu/(deg/s))
      set telscript($telname,adu4deg_elev)        $register_1_X_28 ; # position coef (adu/deg)
      set telscript($telname,coord_app_adu_elev0) $register_1_X_62 ; # position init (adu)
      set telscript($telname,coord_app_deg_elev0) 0 ; # position init (deg)
      set telscript($telname,lim_min_elev)        $register_1_X_60 ; # limite inf adu
      set telscript($telname,lim_max_elev)        $register_1_X_61 ; # limite sup adu
      # --- rot
      set telscript($telname,adu4deg4sec_rot)    $register_2_X_26 ; # vitesse coef (adu/(deg/s))
      set telscript($telname,adu4deg_rot)        $register_2_X_28 ; # position coef (adu/deg)
      set telscript($telname,coord_app_adu_rot0) $register_2_X_62 ; # position init (adu)
      set telscript($telname,coord_app_deg_rot0) 0 ; # position init (deg)
      set telscript($telname,lim_min_rot)        $register_2_X_60 ; # limite inf adu
      set telscript($telname,lim_max_rot)        $register_2_X_61 ; # limite sup adu
   }
   if {$telscript($telname,mount_type)=="hadec"} {
      # --- ha
      set telscript($telname,adu4deg4sec_ha)    $register_0_X_26 ; # vitesse coef (adu/(deg/s))
      set telscript($telname,adu4deg_ha)        $register_0_X_28 ; # position coef (adu/deg)
      set telscript($telname,coord_app_adu_ha0) $register_0_X_62 ; # position init (adu)
      set telscript($telname,coord_app_deg_ha0) 0 ; # position init (deg)
      set telscript($telname,lim_min_ha)        $register_0_X_60 ; # limite inf adu
      set telscript($telname,lim_max_ha)        $register_0_X_61 ; # limite sup adu
      # --- dec
      set telscript($telname,adu4deg4sec_dec)    $register_1_X_26 ; # vitesse coef (adu/(deg/s))
      set telscript($telname,adu4deg_dec)        $register_1_X_28 ; # position coef (adu/deg)
      set telscript($telname,coord_app_adu_dec0) $register_1_X_62 ; # position init (adu)
      set telscript($telname,coord_app_deg_dec0) 0 ; # position init (deg)
      set telscript($telname,lim_min_dec)        $register_1_X_60 ; # limite inf adu
      set telscript($telname,lim_max_dec)        $register_1_X_61 ; # limite sup adu
   }
}

# ################################################################################
# ### proc conversion des coordonnees catalogues J2000 en degres apparents
# ################################################################################
# inputs:
# type = goto | simu
# raj2000,decj2000 (Angles)
# drift_ra,drift_dec (deg/sec)
# global inputs:
# global outputs:
# telscript($telname,jdutc_app_adu)
# telscript($telname,goto_app_deg_*)
# telscript($telname,speed_app_deg_*)
# ################################################################################
proc radec2degs { type raj2000 decj2000 drift_ra drift_dec {lag_sec 0}} {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)
   set home $telscript($telname,home)
   set drift_ra [expr $drift_ra*3600.]
   set drift_dec [expr $drift_dec*3600.]
   set date [mc_datescomp [date_sys2ut now] + [expr $lag_sec/86400.]]
   set telscript($telname,jdutc_app_adu) $date
   set modpoi_symbols $telscript($telname,modpoi_symbols)
   set modpoi_values $telscript($telname,modpoi_values)
   set hip [list 1 1 [string trim [mc_angle2deg "$raj2000"]] [string trim [mc_angle2deg "$decj2000" 90]] J2000 J2000 0 0 0]
   set res [mc_hip2tel $hip $date $home 101325 290 $modpoi_symbols $modpoi_values -drift radec -driftvalues [list $drift_ra $drift_dec]]
   set app_RA         [lindex $res 10] ; # : Acsension droite apparente avec modèle (deg)
   set app_DEC        [lindex $res 11] ; # : Déclinaison apparente avec modèle (deg)
   set app_HA         [lindex $res 12] ; # : Angle horaire apparente avec modèle (deg)
   set app_az         [lindex $res 13] ; # : Azimut apparente avec  modèle (deg)
   set app_elev       [lindex $res 14] ; # : Elevation apparente avec modèle (deg)
   set app_rot        [lindex $res 15] ; # : Angle parallactique apparent avec modèle (deg)
   set app_drift_RA   [lindex $res 16] ; # : Vitesse en acsension droite apparente avec modèle (arcsec/sec)
   set app_drift_DEC  [lindex $res 17] ; # : Vitesse en déclinaison apparente avec modèle (arcsec/sec)
   set app_drift_HA   [lindex $res 18] ; # : Vitesse en angle horaire apparente avec modèle (arcsec/sec)
   set app_drift_az   [lindex $res 19] ; # : Vitesse en azimut apparente avec  modèle (arcsec/sec)
   set app_drift_elev [lindex $res 20] ; # : Vitesse en elevation apparente avec modèle (arcsec/sec)
   set app_drift_rot  [lindex $res 21] ; # : Vitesse en angle parallactique apparent avec modèle (arcsec/sec)
   if {$app_az>180} {
      set app_az [expr $app_az-360]
   }
   if {$telname=="t940"} {
      if {$app_az>90} {
         set app_azop [expr $app_az-180]
         set app_az0 $telscript($telname,coord_app_deg_az)
         if {$app_az0<$app_azop} {
            set app_az [expr $app_az-360]
         }
      }
   }
   if {$app_HA>180} {
      set app_HA [expr $app_HA-360]
   }
   if {$type=="goto"} {
      set telscript($telname,goto_app_deg_az) $app_az
      set telscript($telname,goto_app_deg_elev) $app_elev
      set telscript($telname,goto_app_deg_rot) $app_rot
      set telscript($telname,goto_app_deg_ha) $app_HA
      set telscript($telname,goto_app_deg_ra) $app_RA
      set telscript($telname,goto_app_deg_dec) $app_DEC
      set telscript($telname,speed_app_deg_az) $app_drift_az
      set telscript($telname,speed_app_deg_elev) $app_drift_elev
      set telscript($telname,speed_app_deg_ha) $app_drift_HA
      set telscript($telname,speed_app_deg_dec) $app_drift_DEC
      set telscript($telname,speed_app_deg_rot) $app_drift_rot
   }
   if {$type=="simugoto"} {
      set telscript($telname,simugoto_app_deg_az) $app_az
      set telscript($telname,simugoto_app_deg_elev) $app_elev
      set telscript($telname,simugoto_app_deg_rot) $app_rot
      set telscript($telname,simugoto_app_deg_ha) $app_HA
      set telscript($telname,simugoto_app_deg_ra) $app_RA
      set telscript($telname,simugoto_app_deg_dec) $app_DEC
      set telscript($telname,simuspeed_app_deg_az) $app_drift_az
      set telscript($telname,simuspeed_app_deg_elev) $app_drift_elev
      set telscript($telname,simuspeed_app_deg_ha) $app_drift_HA
      set telscript($telname,simuspeed_app_deg_dec) $app_drift_DEC
      set telscript($telname,simuspeed_app_deg_rot) $app_drift_rot
   }
   set out [list $app_az $app_elev $app_rot $app_HA $app_DEC $app_drift_az $app_drift_elev $app_drift_rot $app_drift_HA $app_drift_DEC]
   return $out
}

# ################################################################################
# ### proc conversion degres apparents en adu
# ################################################################################
# adu = adu0 + (deg-deg0) * adu4deg
#
# global inputs:
# telscript($telname,jdutc_app_adu)
# telscript($telname,goto_app_deg_*)
# telscript($telname,coord_app_adu_*0)
# telscript($telname,coord_app_deg_*0)
# global outputs:
# telscript($telname,goto_app_adu_*)
# ################################################################################
proc degs2adus { {type goto} } {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)
   set home $telscript($telname,home)
   set date $telscript($telname,jdutc_app_adu)
   #set date [date_sys2ut now]
   if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
      set deg  $telscript($telname,${type}_app_deg_az)
      set adu0 $telscript($telname,coord_app_adu_az0)
      set deg0 $telscript($telname,coord_app_deg_az0)
      set adu4deg $telscript($telname,adu4deg_az)
      set adu [expr $adu0 + 1.*($deg-$deg0) * $adu4deg]
      set telscript($telname,${type}_app_adu_az) $adu
      set deg  $telscript($telname,${type}_app_deg_elev)
      set adu0 $telscript($telname,coord_app_adu_elev0)
      set deg0 $telscript($telname,coord_app_deg_elev0)
      set adu4deg $telscript($telname,adu4deg_elev)
      set adu [expr $adu0 + 1.*($deg-$deg0) * $adu4deg]
      set telscript($telname,${type}_app_adu_elev) $adu
   }
   if {$telscript($telname,mount_type)=="azelevrot"} {
      set deg  $telscript($telname,${type}_app_deg_rot)
      set adu0 $telscript($telname,coord_app_adu_rot0)
      set deg0 $telscript($telname,coord_app_deg_rot0)
      set adu4deg $telscript($telname,adu4deg_rot)
      set adu [expr $adu0 + 1.*($deg-$deg0) * $adu4deg]
      set telscript($telname,${type}_app_adu_rot) $adu
   }
   if {$telscript($telname,mount_type)=="hadec"} {
      set deg  $telscript($telname,${type}_app_deg_ha)
      set adu0 $telscript($telname,coord_app_adu_ha0)
      set deg0 $telscript($telname,coord_app_deg_ha0)
      set adu4deg $telscript($telname,adu4deg_ha)
      set adu [expr $adu0 + 1.*($deg-$deg0) * $adu4deg]
      set telscript($telname,${type}_app_adu_ha) $adu
      set deg  $telscript($telname,${type}_app_deg_dec)
      set adu0 $telscript($telname,coord_app_adu_dec0)
      set deg0 $telscript($telname,coord_app_deg_dec0)
      set adu4deg $telscript($telname,adu4deg_dec)
      set adu [expr $adu0 + 1.*($deg-$deg0) * $adu4deg]
      set telscript($telname,${type}_app_adu_dec) $adu
   }
}

# ################################################################################
# ### proc lecture codeurs en adu apparents
# ################################################################################
# global inputs:
# read coders
# global outputs:
# telscript($telname,jdutc_app_adu)
# telscript($telname,coord_app_adu_*)
# ################################################################################
proc get_pos_adus { } {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)
   set date [date_sys2ut now]
   set telscript($telname,jdutc_app_adu) [mc_date2jd $date]
   if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
      set telscript($telname,coord_app_adu_az)   [etel_get_register_s 0 M 7]
      set telscript($telname,coord_app_adu_elev) [etel_get_register_s 1 M 7]
   }
   if {$telscript($telname,mount_type)=="azelevrot"} {
      set telscript($telname,coord_app_adu_rot)  [etel_get_register_s 2 M 7]
   }
   if {$telscript($telname,mount_type)=="hadec"} {
      set telscript($telname,coord_app_adu_ha)   [etel_get_register_s 0 M 7]
      set telscript($telname,coord_app_adu_dec)  [etel_get_register_s 1 M 7]
   }
}

# ################################################################################
# ### proc conversion des adu en degres apparents
# ################################################################################
# deg = deg0 + (adu-adu0) / adu4deg
#
# global inputs:
# telscript($telname,jdutc_app_adu)
# telscript($telname,coord_app_adu_*)
# telscript($telname,coord_app_adu_*0)
# telscript($telname,coord_app_deg_*0)
# telscript($telname,adu4deg_*)
# global outputs:
# telscript($telname,coord_app_deg_*)
# ################################################################################
proc adus2degs { } {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)
   set home $telscript($telname,home)
   set date $telscript($telname,jdutc_app_adu)
   if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
      set adu  $telscript($telname,coord_app_adu_az)
      set adu0 $telscript($telname,coord_app_adu_az0)
      set deg0 $telscript($telname,coord_app_deg_az0)
      set adu4deg $telscript($telname,adu4deg_az)
      set deg [expr $deg0 + 1.*($adu-$adu0) / $adu4deg]
      set telscript($telname,coord_app_deg_az) $deg
      set az $deg
      set adu  $telscript($telname,coord_app_adu_elev)
      set adu0 $telscript($telname,coord_app_adu_elev0)
      set deg0 $telscript($telname,coord_app_deg_elev0)
      set adu4deg $telscript($telname,adu4deg_elev)
      set deg [expr $deg0 + 1.*($adu-$adu0) / $adu4deg]
      set telscript($telname,coord_app_deg_elev) $deg
      set elev $deg
      lassign [mc_altaz2radec $az $elev $home $date] ra dec ha rot
      set telscript($telname,coord_app_deg_ha) $ha
      set telscript($telname,coord_app_deg_dec) $dec
   }
   if {$telscript($telname,mount_type)=="azelevrot"} {
      set adu  $telscript($telname,coord_app_adu_rot)
      set adu0 $telscript($telname,coord_app_adu_rot0)
      set deg0 $telscript($telname,coord_app_deg_rot0)
      set adu4deg $telscript($telname,adu4deg_rot)
      set deg [expr $deg0 + 1.*($adu-$adu0) / $adu4deg]
      set telscript($telname,coord_app_deg_rot) $deg
   }
   if {$telscript($telname,mount_type)=="hadec"} {
      set adu  $telscript($telname,coord_app_adu_ha)
      set adu0 $telscript($telname,coord_app_adu_ha0)
      set deg0 $telscript($telname,coord_app_deg_ha0)
      set adu4deg $telscript($telname,adu4deg_ha)
      set deg [expr $deg0 + 1.*($adu-$adu0) / $adu4deg]
      set telscript($telname,coord_app_deg_ha) $deg
      set ha $deg
      set adu  $telscript($telname,coord_app_adu_dec)
      set adu0 $telscript($telname,coord_app_adu_dec0)
      set deg0 $telscript($telname,coord_app_deg_dec0)
      set adu4deg $telscript($telname,adu4deg_dec)
      set deg [expr $deg0 + 1.*($adu-$adu0) / $adu4deg]
      set telscript($telname,coord_app_deg_dec) $deg
      set dec $deg
   }
   set lst [mc_date2lst $date $home -format deg]
   set ra [expr fmod(720+$lst-$ha,360)]
   set telscript($telname,coord_app_deg_ra) $ra
   if {$telscript($telname,mount_type)=="hadec"} {
      lassign [mc_radec2altaz $ra $dec $home $date] az elev
      set telscript($telname,coord_app_deg_az) $az
      set telscript($telname,coord_app_deg_elev) $elev
   }
}

# ################################################################################
# ### proc conversion des degres apparents en coordonnees catalogues J2000
# ################################################################################
# global inputs:
# telscript($telname,jdutc_app_adu)
# telscript($telname,coord_app_deg_*)
# global outputs:
# List (ra,dec) J2000
# ################################################################################
proc degs2radec { } {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)
   set home $telscript($telname,home)
   set date [date_sys2ut now]
   set modpoi_symbols $telscript($telname,modpoi_symbols)
   set modpoi_values $telscript($telname,modpoi_values)
   if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
      set app_az $telscript($telname,coord_app_deg_az)
      set app_elev $telscript($telname,coord_app_deg_elev)
      set res [mc_tel2cat [list $app_az $app_elev] ALTAZ $date $home 101325 290 $modpoi_symbols $modpoi_values -model_only 0 -refraction 1]
   }
   if {$telscript($telname,mount_type)=="hadec"} {
      set app_ha $telscript($telname,coord_app_deg_ha)
      set app_dec $telscript($telname,coord_app_deg_dec)
      set res [mc_tel2cat [list $app_ha $app_dec] HADEC $date $home 101325 290 $modpoi_symbols $modpoi_values -model_only 0 -refraction 1]
   }
   lassign $res raj2000 decj2000
   set raj2000 [mc_angle2hms $raj2000 360 zero 2 auto string ]
   set decj2000 [mc_angle2dms $decj2000 90 zero 1 + string]
   set out [list $raj2000 $decj2000]
   return $out
}

# ################################################################################
# ### proc qui retourne la date UTC
# ################################################################################
proc date_sys2ut { { date now } } {
   if { $date == "now" } {
      set time [ clock format [ clock seconds ] -format "%Y %m %d %H %M %S" -timezone :UTC ]
   } else {
      set jjnow [ mc_date2jd $date ]
      set time  [ mc_date2ymdhms $jjnow ]
   }
   return $time
}

# ################################################################################
# ### proc de l'interface graphique des variables d'echange
# ################################################################################
proc telscript_variables { } {
   global telscript
   global paramscript
   global audace

   set textevar ""
   foreach res [lsort [tel1 variables]] {
      eval "set $res"
      append textevar "$res\n"
   }
   set telname $telscript(def,telname)

   # --- Create the toplevel window
   set base .etelvar
   catch { destroy $base}
   toplevel $base -class Toplevel
   wm geometry $base 640x800+600+0
   wm focusmodel $base passive
   wm maxsize $base 600 700
   wm minsize $base 600 700
   #wm overrideredirect $base 0
   wm resizable $base 1 1
   wm deiconify $base
   wm title $base "Pilotage télescope $telname : Variables d'échange"
   wm protocol $base WM_DELETE_WINDOW { destroy .etelvar }
   bind $base <Destroy> { destroy .etelvar }
   $base configure -bg $paramscript(color,back)
   wm withdraw .
   focus -force $base

   #--- Create the label and the radiobutton
   #--- Cree l'etiquette et les radiobuttons
   frame $base.frame1 -borderwidth 0 -relief raised
      #--- Label
      label $base.frame1.label -text " " \
         -borderwidth 0 -relief flat
      pack $base.frame1.label -fill x -side left -padx 5 -pady 5
   pack $base.frame1 -side top -fill both -expand 0

   #--- cree un acsenseur vertical pour la console de retour d'etats
   frame $base.fra1
      scrollbar $base.fra1.scr1 -orient vertical \
         -command "$base.fra1.lst1 yview" -takefocus 0 -borderwidth 1
      pack $base.fra1.scr1 \
         -in $base.fra1 -side right -fill y
      set telscript(scroll,status_scrl) $base.fra1.scr1

      scrollbar $base.fra1.scr2 -orient horizontal \
         -command "$base.fra1.lst1 xview" -takefocus 0 -borderwidth 1
      pack $base.fra1.scr2 \
         -in $base.fra1 -side bottom -fill x
      set telscript(scroll,status_scrlx) $base.fra1.scr2

      #--- cree la console de retour d'etats
      text $base.fra1.lst1 \
         -borderwidth 1 -relief sunken  -height 6 -font {courier 8 bold} -bg $paramscript(color,scroll)\
         -yscrollcommand "$base.fra1.scr1 set"  -xscrollcommand "$base.fra1.scr2 set" -wrap none
      pack $base.fra1.lst1 \
         -in $base.fra1 -expand yes -fill both \
         -padx 3 -pady 3
      set telscript(scroll,status_list) $base.fra1.lst1

      $telscript(scroll,status_list) insert end "VARIABLES de l'array telscript:\n\n"
      $telscript(scroll,status_list) yview moveto 1.0

      $telscript(scroll,status_list) delete 1.0 end
      $telscript(scroll,status_list) insert end "$textevar"
      $telscript(scroll,status_list) yview moveto 0.0
      $base.fra1.lst1 configure -font {courier 8 bold}

   pack $base.fra1 -side top -fill both -expand 1
   #--- Create the button 'OK'
   #--- Cree le bouton 'OK'
   button $base.but_ok -text "Mettre à jour" \
      -borderwidth 2 -command {
         global telscript
         global paramscript
         global audace
         set textevar ""
         foreach res [lsort [tel1 variables]] {
            eval "set $res"
            append textevar "$res\n"
         }
         set telname $telscript(def,telname)
         set old [$telscript(scroll,status_list) yview]
         $telscript(scroll,status_list) delete 1.0 end
         $telscript(scroll,status_list) insert end "$textevar"
         $telscript(scroll,status_list) yview moveto [lindex $old 0]
      }
   pack $base.but_ok -side right -anchor w -padx 5 -pady 5
   $base.but_ok configure  -state disabled
   $base.but_ok configure  -state normal

   #--- La fenetre est active
   focus $base

   update

}

# ################################################################################
# ### espeak
# priority = wait : attend la fin du message precedent
# priority = skip : passe le message si le precedent n'est pas termine
# priority = over : superpose les messages
# ################################################################################
proc espeak { msg {priority wait} } {
   global audace
   package require twapi
   set exe "$audace(rep_install)/bin/espeak.exe"
   if {$priority=="wait"} {
      set ever_launched 1
      while {$ever_launched==1} {
         set pids [twapi::get_process_ids]
         set ever_launched 0
         foreach pid $pids {
            set res [twapi::get_process_info $pid -name]
            set name [lindex $res 1]
            if {$name=="espeak.exe"} {
               set ever_launched 1
               break
            }
         }
      }
   }
   if {$priority=="skip"} {
      set pids [twapi::get_process_ids]
      set ever_launched 0
      foreach pid $pids {
         set res [twapi::get_process_info $pid -name]
         set name [lindex $res 1]
         if {$name=="espeak.exe"} {
            set ever_launched 1
            break
         }
      }
      if {$ever_launched==1} {
         return
      }
   }
   set cmdline " -v fr \"$msg\""
   twapi::create_process ${exe} -cmdline $cmdline -startdir [file dirname $exe] -detached 1
}

# ################################################################################
# ### proc de creation du telescope
# ################################################################################
proc connect_tel { {mode_boot 0} } {
   global paramscript
   global audace
   catch {
      close $telscript($telname,combit0)
      close $telscript($telname,combit1)
   }
   set telno [tel::list]
   if {$mode_boot==0} {
      if {$telno==""} {
         ::tel::create telscript -telname t940 -script $paramscript(script) -home $audace(posobs,observateur,gps)
      }
   }
   if {$mode_boot==1} {
      if {$telno!=""} {
         ::console::affiche_resultat "::tel::delete $telno\n"
         ::tel::delete $telno
         after 500
         ::console::affiche_resultat "::tel::create telscript\n"
         ::tel::create telscript -telname t940 -script $paramscript(script) -home $audace(posobs,observateur,gps)
      }
   }
}

# ################################################################################
# ### proc de la resolution des noms
# ################################################################################
# Accepte *M1 *NGC1976 *IC45 *jupiter *ISS *GPS *GEO
# ------
# ################################################################################
proc decode_radec_entry { objname0 {date ""} } {
   global telscript
   global audace
   set telname $telscript(def,telname)
   set home $telscript($telname,home)
   if {$date==""} {
      set date [date_sys2ut now]
   }
   set modpoi_symbols $telscript($telname,modpoi_symbols)
   set modpoi_values $telscript($telname,modpoi_values)
   set objname0 [string toupper $objname0]
   set no [llength $objname0]
   set car [string index $objname0 0]
   set type_obj coords
   set objname coords
   set xdra 0
   set xddec 0
   if {$car=="&"} {
      set name [string range $objname0 1 end]
      if {$name=="NEO1"} {
         set name 2012DA14
      }
      set err [catch { vo_getmpcephem $name $date $home } res ]
      if {$err==1} {
         # --- pas de connexion internet alors on prend un GPS
         set res [best_satel GPS 0 45 $home $date]
         set objname [lindex $res 0]
         set xra [lindex $res 1]
         set xdec [lindex $res 2]
         set xdra [expr [lindex $res 3]/3600.]
         set xddec [expr [lindex $res 4]/3600.]
         set type_obj name2coord
      } else {
         set res [lindex $res 0]
         console::affiche_resultat "vo_getmpcephem $name $date $home\n"
         console::affiche_resultat "res=$res\n"
         lassign $res obj_name obj_date obj_ra obj_dec obj_drift_ra obj_drift_dec obj_magv obj_az obj_elev obj_elong obj_phase obj_r obj_delta sun_elev
         set objname $obj_name
         set xra $obj_ra
         set xdec $obj_dec
         # --- drifts donnes en "/min -> deg/sec
         set xdra [expr $obj_drift_ra/60./3600.]
         set xddec [expr $obj_drift_dec/60./3600.]
         set type_obj mpcephem
      }
   } elseif {$car=="*"} {
      set name [string range $objname0 1 end]
      set objname $name
      if {($name=="ISS")||($name=="GEO")||($name=="GPS")} {
         set res [best_satel $name 0 45 $home $date]
         set objname [lindex $res 0]
         set xra [lindex $res 1]
         set xdec [lindex $res 2]
         set xdra [expr [lindex $res 3]/3600.]
         set xddec [expr [lindex $res 4]/3600.]
         set type_obj name2coord
      } elseif {($name=="STOP")} {
         set objname STOP
         lassign [degs2radec] raj2000 decj2000
         set xra $raj2000
         set xdec $decj2000
         set xdra [expr -1*$telscript(def,speed_diurnal)]
         set xddec 0
         set type_obj name2coord
      } elseif {($name=="PARK")} {
         set objname PARK
         set res [mc_tel2cat [list 0 -40] HADEC $date $home 101325 290 $modpoi_symbols $modpoi_values -model_only 0 -refraction 1]
         lassign $res raj2000 decj2000
         set xra $raj2000
         set xdec $decj2000
         set xdra [expr -1*$telscript(def,speed_diurnal)]
         set xddec 0
         set type_obj name2coord
      } else {
         set err [catch {name2coord $name -date $date -home $home -drift} coords]
         if {$err==1} {
            error $coords
         } else {
            set xra [lindex $coords 0]
            set xdec [lindex $coords 1]
            set xdra [lindex $coords 2]
            set xddec [lindex $coords 3]
            set type_obj name2coord
         }
      }
   } else {
      if {$no==8} {
         lassign $objname0 rah ram ras decd decm decs xdra xddec
         set ra [list $rah $ram $ras h]
         set dec [list $decd $decm $decs]
      } elseif {$no==6} {
         lassign $objname0 rah ram ras decd decm decs
         set ra [list $rah $ram $ras h]
         set dec [list $decd $decm $decs]
      } else {
         lassign $objname0 ra dec
      }
      set xra  [string trim [mc_angle2deg $ra]]
      set xdec [string trim [mc_angle2deg $dec 90]]
   }
   set xra [mc_angle2hms $xra 360 zero 2 auto string]
   set xdec [mc_angle2dms $xdec 90 zero 1 + string]
   set xdra [format %.5f $xdra]
   set xddec [format %.5f $xddec]
   return [list $type_obj $objname $xra $xdec $xdra $xddec]
}

# ################################################################################
# ### proc best_satel
# ################################################################################
proc best_satel { type az0 elev0 home date} {
   global audace
   # --- update
   set satfile [ file join $::audace(rep_userCatalog) tle geo.txt ]
   if {[file exists $satfile]==1} {
      set datfile [ file mtime $satfile ]
      set dt [expr ([clock seconds]-$datfile)/86400.]
   } else {
      set dt [expr 10*86400]
   }
   if {$dt>1} {
      satel_update
   }
   # --- type = GPS, ISS, GEO
   if {$type=="GEO"} {
      set satels [satel_names]
   } else {
      set satels [satel_names $type]
   }
   # --- filtre
   set res ""
   foreach satel $satels {
      set ftle [lindex $satel 1]
      if {$type=="GPS"} {
         if {$ftle=="gps-ops.txt"} {
            lappend res $satel
         }
      }
      if {$type=="GEO"} {
         if {$ftle=="geo.txt"} {
            lappend res $satel
         }
      }
      if {$type=="ISS"} {
         if {$ftle=="stations.txt"} {
            lappend res $satel
         }
      }
   }
   # --- selection
   set satels $res
   set sepanglemin 360
   set bestsatel ""
   foreach satel $satels {
      set satelname [lindex $satel 0]
      set ftle [lindex $satel 1]
      set res [satel_ephem $satelname $date $home]
      if {$res==""} {
         continue
      }
      set res [lindex $res 0]
      set name [string trim [lindex [lindex $res 0] 0]]
      set ra [mc_angle2hms [lindex $res 1] 360 zero 2 auto string]
      set dec [mc_angle2dms [lindex $res 2] 90 zero 1 + string]
      set ill [lindex $res 6]
      set azim [lindex $res 8]
      set elev [lindex $res 9]
      if {($ill<=0)||($elev<0)} {
         continue
      }
      set res [mc_anglesep [list $azim $elev $az0 $elev0]]
      set sepangle [lindex $res 0]
      if {$sepangle<$sepanglemin} {
         set sepanglemin $sepangle
         set bestsatel $satel
      }
   }
   if {$bestsatel==""} {
      error "no satellite for type $type"
   }
   set satel $bestsatel
   set satelname [lindex $satel 0]
   set res [satel_ephem $satelname $date $home]
   set res [lindex $res 0]
   set name [string trim [lindex [lindex $res 0] 0]]
   set ra [lindex $res 1]
   set dec [lindex $res 2]
   set ill [lindex $res 6]
   set azim [lindex $res 8]
   set elev [lindex $res 9]
   set date2 [mc_datescomp $date + [expr 1./86400]]
   set res [satel_ephem $satelname $date2 $home]
   set res [lindex $res 0]
   set ra2 [lindex $res 1]
   set dec2 [lindex $res 2]
   set dra [expr ($ra2-$ra)*3600.]
   set ddec [expr ($dec2-$dec)*3600.]
   set ra [mc_angle2hms $ra 360 zero 2 auto string ]
   set dec [mc_angle2dms $dec 90 zero 1 + string]
   #console::affiche_resultat "BEST SAT RA$ra DEC$dec DRA$dra DDEC$ddec\n"
   set out "[list $name] $ra $dec $dra $ddec"
   return $out
}

# ################################################################################
# ### proc appelée par l'interface graphique principale
# ################################################################################
proc gui_calcul_coordonnees { objname0 } {
   global telscript
   global audace
   set telname $telscript(def,telname)
   set base $telscript(def,base)
   set cs0 [decode_radec_entry $objname0]
   lassign $cs0 objtype objname raj2000 decj2000 drift_ra drift_dec
   set cs [radec2degs simugoto $raj2000 $decj2000 $drift_ra $drift_dec]
   set result ""
   lappend result "$objname0"
   lappend result "$objtype"
   lappend result "$objname"
   lappend result "$raj2000"
   lappend result "$decj2000"
   lappend result "$drift_ra"
   lappend result "$drift_dec"
   lappend result "$cs"
   set t ""
   lappend t $objtype
   lappend t $objname
   append t "  ra = $raj2000 dec = $decj2000"
   $base.f.fpoi2.lab_coord configure -text "$t"
   set t ""
   if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
      append t "az = [format %.2f [lindex $cs 0]] elev = [format %.2f [lindex $cs 1]]  "
      degs2adus simugoto
      set as ""
      set adu $telscript($telname,lim_min_az)
      set adumin [format %.0f [expr $adu/1e6]]
      lappend as [list min= $adumin]
      set adu $telscript($telname,simugoto_app_adu_az)
      set adupoi [format %.0f [expr $adu/1e6]]
      lappend as [list poi= $adupoi]
      set adu $telscript($telname,lim_max_az)
      set adumax [format %.0f [expr $adu/1e6]]
      lappend as [list max= $adumax]
      set adu $telscript($telname,coord_app_adu_az0)
      set adu0 [format %.0f [expr $adu/1e6]]
      lappend as [list mer= $adu0]
      set adu $telscript($telname,coord_app_adu_az)
      set aducur [format %.0f [expr $adu/1e6]]
      lappend as [list cur= $aducur]
      set as [lsort -index 1 -real $as]
   }
   if {($telscript($telname,mount_type)=="hadec")} {
      append t "ha = [format %.2f [lindex $cs 3]] dec = [format %.2f [lindex $cs 4]]  "
      degs2adus simugoto
      set as ""
      set adu $telscript($telname,lim_min_ha)
      set adumin [format %.0f [expr $adu/1e6]]
      lappend as [list min= $adumin]
      set adu $telscript($telname,simugoto_app_adu_ha)
      set adupoi [format %.0f [expr $adu/1e6]]
      lappend as [list poi= $adupoi]
      set adu $telscript($telname,lim_max_ha)
      set adumax [format %.0f [expr $adu/1e6]]
      lappend as [list max= $adumax]
      set adu $telscript($telname,coord_app_adu_ha0)
      set adu0 [format %.0f [expr $adu/1e6]]
      lappend as [list mer= $adu0]
      set adu $telscript($telname,coord_app_adu_ha)
      set aducur [format %.0f [expr $adu/1e6]]
      lappend as [list cur= $aducur]
      set as [lsort -index 1 -real $as]
   }
   append t "$as (adu/1e6)"
   $base.f.fpoi2b.lab_coord configure -text "$t"
   set command ""
   append command "set ::audace(rep_userCatalog)"
   lappend command "$::audace(rep_userCatalog)"
   append command " ; "
   append command "set ::audace(posobs,observateur,gps) \"$::audace(posobs,observateur,gps)\""
   tel1 loopeval $command
   return $result
}

# ################################################################################
# ### proc appelée par l'appui sur les boutons de direction de la raquette virtuelle
# ################################################################################
proc gui_start_shift { widget direction } {
   global telscript
   global paramscript
   set telname $telscript(def,telname)
   set base $telscript(def,base)
   eval "\$${widget} configure -bg $paramscript(color,greendark) -relief sunken"
   update
   set command ""
   append command "set telscript($telscript(def,telname),move_virtual_pad) \"1 ${direction}\" "
   tel1 loopeval "$command"
   after 300
}

# ################################################################################
# ### proc appelée par la relache des boutons de direction de la raquette virtuelle
# ################################################################################
proc gui_stop_shift { widget direction } {
   global telscript
   global paramscript
   set telname $telscript(def,telname)
   set base $telscript(def,base)
   set command ""
   append command "set telscript($telscript(def,telname),move_virtual_pad) \"0 ${direction}\" "
   console::affiche_resultat "command=$command\n"
   tel1 loopeval "$command"
   after 300
   $base.f.fr1.fr2.fr1.but_n configure -bg $paramscript(color,back) -relief raised
   eval "\$${widget} configure -bg $paramscript(color,back) -relief raised"
   update
   console::affiche_resultat "result=[tel1 loopresult]\n"
}

# ################################################################################
# ### proc appelée par l'appui sur les boutons de focalisation de la raquette virtuelle
# ################################################################################
proc gui_start_focus { widget direction } {
   global telscript
   global paramscript
   set telname $telscript(def,telname)
   set base $telscript(def,base)
   eval "\$${widget} configure -bg $paramscript(color,greendark) -relief sunken"
   update
   set command ""
   append command "set telscript($telscript(def,telname),move_virtual_foc) \"1 ${direction}\" "
   #console::affiche_resultat "command=$command\n"
   tel1 loopeval "$command"
   after 300
}

# ################################################################################
# ### proc appelée par la relache des boutons de focalisation de la raquette virtuelle
# ################################################################################
proc gui_stop_focus { widget direction } {
   global telscript
   global paramscript
   set telname $telscript(def,telname)
   set base $telscript(def,base)
   set command ""
   append command "set telscript($telscript(def,telname),move_virtual_foc) \"0 0\" "
   console::affiche_resultat "command=$command\n"
   tel1 loopeval "$command"
   after 300
   eval "\$${widget} configure -bg $paramscript(color,back) -relief raised"
   update
   console::affiche_resultat "result=[tel1 loopresult]\n"
}

# ################################################################################
# ### proc appelée par l'appui sur les boutons de vitesse de la raquette virtuelle
# ################################################################################
proc gui_speed_shift { widget speed } {
   global telscript
   global paramscript
   set telname $telscript(def,telname)
   set base $telscript(def,base)
   if {$speed==0} {
      set relief raised
      set bgcol $paramscript(color,back)
   } else {
      set relief sunken
      set bgcol $paramscript(color,greendark)
   }
   eval "\$${widget} configure -relief $relief"
   update
   set command ""
   append command "set telscript($telscript(def,telname),speed_virtual_pad) $speed"
   tel1 loopeval "$command"
   after 300
   console::affiche_resultat "result=[tel1 loopresult]\n"
}

# ################################################################################
# ### proc de l'interface graphique principale
# ################################################################################
# source $audace(rep_install)/gui/audace/plugin/mount/telscript/telscript_etel.tcl ; telscript_gui
# source telscript_etel.tcl ; telscript_gui
proc telscript_gui { } {
   global telscript
   global paramscript
   global audace

   set paramscript(loop) 0
   ### set paramscript(script) "[pwd]/telscript_etel.tcl"
   set paramscript(script) "$audace(rep_install)/gui/audace/plugin/mount/telscript/telscript_etel.tcl"
   after 200
   connect_tel 0
   foreach res [lsort [tel1 variables]] {
      eval "set $res"
      #console::affiche_resultat "$res\n"
   }

   # --- Get useful variables
   set telname $telscript(def,telname)
   set home $telscript($telname,home)

   set telscript($telname,poi_objname) ""

   # --- Definition des couleurs  tk_chooseColor
   set paramscript(color,back)       #56789A
   set paramscript(color,text)       #FFFFFF
   set paramscript(color,back_image) #123456
   set paramscript(color,white)      #FFFFFF
   set paramscript(color,yellow)     #FFFF00
   set paramscript(color,red)        #FF0000
   set paramscript(color,green)      #00FF00
   set paramscript(color,greendark)  #00AA00
   set paramscript(color,blue)       #0000FF
   set paramscript(color,rectangle)  #0000EF
   set paramscript(color,scroll)     #BBBBBB
   set paramscript(font)             {times 11 bold}
   set paramscript(font1)            {times 15 bold}

   # --- Create the toplevel window
   set base .etel
   set telscript(def,base) .etel
   catch { destroy $base}
   toplevel $base -class Toplevel
   wm geometry $base 800x850+0+0
   wm focusmodel $base passive
   wm maxsize $base [winfo screenwidth $base] [winfo screenheight $base]
   wm minsize $base 800 850
   #wm overrideredirect $base 0
   wm resizable $base 1 1
   wm deiconify $base
   wm title $base "Pilotage télescope $telname"
   #wm protocol $base WM_DELETE_WINDOW fermer
   wm protocol $base WM_DELETE_WINDOW { global audace ; save_params ; destroy .etel }
   bind $base <Destroy> { global audace ; save_params ; destroy .etel }
   $base configure -bg $paramscript(color,back)
   wm withdraw .
   focus -force $base

   frame $base.f -bg $paramscript(color,back)
      label $base.f.lab_titre \
         -bg $paramscript(color,back) -fg $paramscript(color,text) \
         -font $paramscript(font) -text "Pilotage télescope $telname"
      pack $base.f.lab_titre
      #--- DATES
      frame $base.f.f3 -bg $paramscript(color,back)
         label $base.f.f3.lab_tu \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text "UT"
         pack $base.f.f3.lab_tu -side left -fill none -pady 2 -padx 5
         label $base.f.f3.lab_tsl \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text "TSL"
         pack $base.f.f3.lab_tsl -side left -fill none -pady 2 -padx 5
      pack $base.f.f3 -fill none -pady 2
      #--- LOOP labels
      frame $base.f.f2 -bg $paramscript(color,back)
         label $base.f.f2.lab_loopaction \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text "LOOP"
         pack $base.f.f2.lab_loopaction -side left -fill none -pady 2
         label $base.f.f2.lab_action \
            -bg $paramscript(color,back) -fg $paramscript(color,yellow) \
            -font $paramscript(font) -text ""
         pack $base.f.f2.lab_action -side left -fill none -pady 2
         label $base.f.f2.lab_loopno \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.f2.lab_loopno -side left -fill none -pady 2
         label $base.f.f2.lab_loopsimu \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.f2.lab_loopsimu -side left -fill none -pady 2
         label $base.f.f2.lab_loopmotion \
            -bg $paramscript(color,back) -fg $paramscript(color,yellow) \
            -font $paramscript(font) -text ""
         pack $base.f.f2.lab_loopmotion -side left -fill none -pady 2
         label $base.f.f2.lab_looperror \
            -bg $paramscript(color,back) -fg $paramscript(color,red) \
            -font $paramscript(font) -text ""
         pack $base.f.f2.lab_looperror -side left -fill none -pady 2
      pack $base.f.f2 -fill none -pady 2
      #--- LOOP buttons
      frame $base.f.f1 -bg $paramscript(color,back)
         button $base.f.f1.but_create \
            -text "Reboot tel1" -borderwidth 2 \
            -command { connect_tel 1 }
         pack $base.f.f1.but_create -side left -anchor center -padx 3 -pady 3
         button $base.f.f1.but_sourcetel \
            -text "Source loop" -borderwidth 2 \
            -command {tel1 source}
         pack $base.f.f1.but_sourcetel -side left -anchor center -padx 3 -pady 3
         button $base.f.f1.but_sourceaud \
            -text "Source Tk" -borderwidth 2 \
            -command { global audace ; ::console::affiche_resultat "\nsource \"$audace(rep_install)/gui/audace/plugin/mount/telscript/$scriptname\" ; telscript_gui\n" ; source $audace(rep_install)/gui/audace/plugin/mount/telscript/$scriptname ; telscript_gui}
         pack $base.f.f1.but_sourceaud -side left -anchor center -padx 3 -pady 3
         button $base.f.f1.but_coefs \
            -text "Paramètres ETEL" -borderwidth 2 \
            -command { }
         pack $base.f.f1.but_coefs -side left -anchor center -padx 3 -pady 3
         button $base.f.f1.but_vars \
            -text "Variables" -borderwidth 2 \
            -command {telscript_variables}
         pack $base.f.f1.but_vars -side left -anchor center -padx 3 -pady 3
      pack $base.f.f1 -fill none -pady 2
      #--- POSITIONS
      frame $base.f.fp1 -bg $paramscript(color,back)
         label $base.f.fp1.lab_def \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text "POSITION APP (adu)"
         pack $base.f.fp1.lab_def -side left -fill none -pady 0 -padx 4
         label $base.f.fp1.lab_ax0 \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fp1.lab_ax0 -side left -fill none -pady 0 -padx 4
         label $base.f.fp1.lab_ax1 \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fp1.lab_ax1 -side left -fill none -pady 0 -padx 4
         if {($telscript($telname,mount_type)=="azelevrot")} {
            label $base.f.fp1.lab_ax2 \
               -bg $paramscript(color,back) -fg $paramscript(color,text) \
               -font $paramscript(font) -text ""
            pack $base.f.fp1.lab_ax2 -side left -fill none -pady 0 -padx 4
         }
      pack $base.f.fp1 -fill none -pady 0
      frame $base.f.fp2 -bg $paramscript(color,back)
         label $base.f.fp2.lab_def \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text "POSITION COEFS (adu/deg)"
         pack $base.f.fp2.lab_def -side left -fill none -pady 0 -padx 4
         label $base.f.fp2.lab_ax0 \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fp2.lab_ax0 -side left -fill none -pady 0 -padx 4
         label $base.f.fp2.lab_ax1 \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fp2.lab_ax1 -side left -fill none -pady 0 -padx 4
         if {($telscript($telname,mount_type)=="azelevrot")} {
            label $base.f.fp2.lab_ax2 \
               -bg $paramscript(color,back) -fg $paramscript(color,text) \
               -font $paramscript(font) -text ""
            pack $base.f.fp2.lab_ax2 -side left -fill none -pady 0 -padx 4
         }
      pack $base.f.fp2 -fill none -pady 0
      frame $base.f.fp3 -bg $paramscript(color,back)
         label $base.f.fp3.lab_def \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text "POSITION INIT (adu)"
         pack $base.f.fp3.lab_def -side left -fill none -pady 0 -padx 4
         label $base.f.fp3.lab_ax0 \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fp3.lab_ax0 -side left -fill none -pady 0 -padx 4
         label $base.f.fp3.lab_ax1 \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fp3.lab_ax1 -side left -fill none -pady 0 -padx 4
         if {($telscript($telname,mount_type)=="azelevrot")} {
            label $base.f.fp3.lab_ax2 \
               -bg $paramscript(color,back) -fg $paramscript(color,text) \
               -font $paramscript(font) -text ""
            pack $base.f.fp3.lab_ax2 -side left -fill none -pady 0 -padx 4
         }
      pack $base.f.fp3 -fill none -pady 0
      frame $base.f.fp4 -bg $paramscript(color,back)
         label $base.f.fp4.lab_def \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text "POSITION INIT (deg)"
         pack $base.f.fp4.lab_def -side left -fill none -pady 0 -padx 4
         label $base.f.fp4.lab_ax0 \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fp4.lab_ax0 -side left -fill none -pady 0 -padx 4
         label $base.f.fp4.lab_ax1 \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fp4.lab_ax1 -side left -fill none -pady 0 -padx 4
         if {($telscript($telname,mount_type)=="azelevrot")} {
            label $base.f.fp4.lab_ax2 \
               -bg $paramscript(color,back) -fg $paramscript(color,text) \
               -font $paramscript(font) -text ""
            pack $base.f.fp4.lab_ax2 -side left -fill none -pady 0 -padx 4
         }
      pack $base.f.fp4 -fill none -pady 0
      frame $base.f.fp4a -bg $paramscript(color,back)
         label $base.f.fp4a.lab_def \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text "POSITION THEO (deg)"
         pack $base.f.fp4a.lab_def -side left -fill none -pady 0 -padx 4
         label $base.f.fp4a.lab_ax0 \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fp4a.lab_ax0 -side left -fill none -pady 0 -padx 4
         label $base.f.fp4a.lab_ax1 \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fp4a.lab_ax1 -side left -fill none -pady 0 -padx 4
         if {($telscript($telname,mount_type)=="azelevrot")} {
            label $base.f.fp4a.lab_ax2 \
               -bg $paramscript(color,back) -fg $paramscript(color,text) \
               -font $paramscript(font) -text ""
            pack $base.f.fp4a.lab_ax2 -side left -fill none -pady 0 -padx 4
         }
      pack $base.f.fp4a -fill none -pady 0
      frame $base.f.fp4b -bg $paramscript(color,back)
         label $base.f.fp4b.lab_def \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text "POSITION THEO (adu)"
         pack $base.f.fp4b.lab_def -side left -fill none -pady 0 -padx 4
         label $base.f.fp4b.lab_ax0 \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fp4b.lab_ax0 -side left -fill none -pady 0 -padx 4
         label $base.f.fp4b.lab_ax1 \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fp4b.lab_ax1 -side left -fill none -pady 0 -padx 4
         if {($telscript($telname,mount_type)=="azelevrot")} {
            label $base.f.fp4b.lab_ax2 \
               -bg $paramscript(color,back) -fg $paramscript(color,text) \
               -font $paramscript(font) -text ""
            pack $base.f.fp4b.lab_ax2 -side left -fill none -pady 0 -padx 4
         }
      pack $base.f.fp4b -fill none -pady 0
      frame $base.f.fp4c -bg $paramscript(color,back)
         label $base.f.fp4c.lab_def \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text "POSITION INIT THEO (adu)"
         pack $base.f.fp4c.lab_def -side left -fill none -pady 0 -padx 4
         label $base.f.fp4c.lab_ax0 \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fp4c.lab_ax0 -side left -fill none -pady 0 -padx 4
         label $base.f.fp4c.lab_ax1 \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fp4c.lab_ax1 -side left -fill none -pady 0 -padx 4
         if {($telscript($telname,mount_type)=="azelevrot")} {
            label $base.f.fp4c.lab_ax2 \
               -bg $paramscript(color,back) -fg $paramscript(color,text) \
               -font $paramscript(font) -text ""
            pack $base.f.fp4c.lab_ax2 -side left -fill none -pady 0 -padx 4
         }
      pack $base.f.fp4c -fill none -pady 0
      frame $base.f.fp5 -bg $paramscript(color,back)
         label $base.f.fp5.lab_def \
            -bg $paramscript(color,back) -fg $paramscript(color,green) \
            -font $paramscript(font) -text "POSITION APP (deg)"
         pack $base.f.fp5.lab_def -side left -fill none -pady 0 -padx 4
         label $base.f.fp5.lab_ax0 \
            -bg $paramscript(color,back) -fg $paramscript(color,yellow) \
            -font $paramscript(font) -text ""
         pack $base.f.fp5.lab_ax0 -side left -fill none -pady 0 -padx 4
         label $base.f.fp5.lab_ax1 \
            -bg $paramscript(color,back) -fg $paramscript(color,yellow) \
            -font $paramscript(font) -text ""
         pack $base.f.fp5.lab_ax1 -side left -fill none -pady 0 -padx 4
         if {($telscript($telname,mount_type)=="azelevrot")} {
            label $base.f.fp5.lab_ax2 \
               -bg $paramscript(color,back) -fg $paramscript(color,yellow) \
               -font $paramscript(font) -text ""
            pack $base.f.fp5.lab_ax2 -side left -fill none -pady 0 -padx 4
         }
         label $base.f.fp5.lab_bonus \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fp5.lab_bonus -side left -fill none -pady 0 -padx 4
      pack $base.f.fp5 -fill none -pady 0
      frame $base.f.fp6 -bg $paramscript(color,back)
         label $base.f.fp6.lab_def \
            -bg $paramscript(color,back) -fg $paramscript(color,green) \
            -font $paramscript(font) -text "POSITION ACTUELLE J2000"
         pack $base.f.fp6.lab_def -side left -fill none -pady 0 -padx 4
         label $base.f.fp6.lab_ra \
            -bg $paramscript(color,back) -fg $paramscript(color,yellow) \
            -font $paramscript(font) -text ""
         pack $base.f.fp6.lab_ra -side left -fill none -pady 0 -padx 4
         label $base.f.fp6.lab_dec \
            -bg $paramscript(color,back) -fg $paramscript(color,yellow) \
            -font $paramscript(font) -text ""
         pack $base.f.fp6.lab_dec -side left -fill none -pady 0 -padx 4
      pack $base.f.fp6 -fill none -pady 0
      frame $base.f.fpoi1 -bg $paramscript(color,back)
         label $base.f.fpoi1.lab_def \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text "NOM ou COORD"
         pack $base.f.fpoi1.lab_def -side left -fill none -pady 0 -padx 4
         entry $base.f.fpoi1.ent \
            -textvariable telscript($telname,poi_objname) -width 30
         pack $base.f.fpoi1.ent \
            -side left -anchor center -expand 1 -fill x \
            -padx 10 -pady 3
         button $base.f.fpoi1.but_vars \
            -text "Calcul coordonnées" -borderwidth 2 \
            -command {
               global telscript
               set telname $telscript(def,telname)
               set base $telscript(def,base)
               $base.f.fpoi1.but_vars configure -state disabled
               set result [gui_calcul_coordonnees $telscript($telname,poi_objname)]
               set res [lrange $result 0 6]
               set telscript($telscript(def,telname),simugoto,object) $res
               $base.f.fpoi1.but_vars configure -state active
            }
         pack $base.f.fpoi1.but_vars -side left -anchor center -padx 3 -pady 3
      pack $base.f.fpoi1 -fill none -pady 0
      frame $base.f.fpoi2 -bg $paramscript(color,back)
         label $base.f.fpoi2.lab_def \
            -bg $paramscript(color,back) -fg $paramscript(color,green) \
            -font $paramscript(font) -text "POSITION A POINTER J2000"
         pack $base.f.fpoi2.lab_def -side left -fill none -pady 0 -padx 4
         label $base.f.fpoi2.lab_coord \
            -bg $paramscript(color,back) -fg $paramscript(color,yellow) \
            -font $paramscript(font) -text ""
         pack $base.f.fpoi2.lab_coord -side left -fill none -pady 0 -padx 4
      pack $base.f.fpoi2 -fill none -pady 0
      frame $base.f.fpoi2b -bg $paramscript(color,back)
         label $base.f.fpoi2b.lab_def \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text "PARCOURS prévu"
         pack $base.f.fpoi2b.lab_def -side left -fill none -pady 0 -padx 4
         label $base.f.fpoi2b.lab_coord \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fpoi2b.lab_coord -side left -fill none -pady 0 -padx 4
      pack $base.f.fpoi2b -fill none -pady 0
      frame $base.f.fpoi3 -bg $paramscript(color,back)
         button $base.f.fpoi3.but_match \
            -text "MATCH (Delta0)" -borderwidth 2 \
            -command {
               global telscript
               set telname $telscript(def,telname)
               set base $telscript(def,base)
               $base.f.fpoi3.but_match configure -state disabled
               set command ""
               append command "set telscript($telscript(def,telname),action_next) radec_init"
               tel1 loopeval "$command"
               after 300
               set res [tel1 loopresult]
               console::affiche_resultat "res=$res\n"
               $base.f.fpoi3.but_match configure -state normal
            }
         pack $base.f.fpoi3.but_match -side left -anchor center -padx 3 -pady 3
         button $base.f.fpoi3.but_goto \
            -text "GOTO" -borderwidth 2 -padx 20\
            -command {
               global telscript
               set telname $telscript(def,telname)
               set base $telscript(def,base)
               $base.f.fpoi3.but_goto configure -state disabled
               set result [gui_calcul_coordonnees $telscript($telname,poi_objname)]
               set cs [lindex $result 7]
               lassign $cs app_az app_elev app_HA
               console::affiche_resultat "GOTO $app_az $app_elev $app_HA\n"
               # --
               if {$app_elev<0} {
                  catch {espeak "Pointage impossible."}
                  tk_messageBox -icon warning -type ok -message "Astre couché\nElevation=[format %.1f $app_elev] deg."
                  return
               }
               # --
               set res [lrange $result 0 6]
               set command ""
               append command "set telscript($telscript(def,telname),goto,object) \"$res\";"
               append command "set telscript($telscript(def,telname),goto,status) todo"
               tel1 loopeval "$command"
               after 300
               set res [tel1 loopresult]
               console::affiche_resultat "res=$res\n"
               $base.f.fpoi3.but_goto configure -state normal
            }
         pack $base.f.fpoi3.but_goto -side left -anchor center -padx 3 -pady 3
         button $base.f.fpoi3.but_stop \
            -text "STOP GOTO" -borderwidth 2 \
            -command {
               global telscript
               set telname $telscript(def,telname)
               set command ""
               append command "set telscript($telscript(def,telname),action_next) radec_goto_stop"
               tel1 loopeval "$command"
               after 300
               set res [tel1 loopresult]
               console::affiche_resultat "res=$res\n"
            }
         pack $base.f.fpoi3.but_stop -side left -anchor center -padx 3 -pady 3
         button $base.f.fpoi3.but_park \
            -text "PARK" -borderwidth 2 \
            -command {
               global telscript
               set telname $telscript(def,telname)
               set base $telscript(def,base)
               set home $telscript($telname,home)
               set telscript($telname,poi_objname) "*PARK"
               set result [gui_calcul_coordonnees $telscript($telname,poi_objname)]
               set cs [lindex $result 7]
               lassign $cs app_az app_elev app_HA
               console::affiche_resultat "GOTO $app_az $app_elev $app_HA\n"
               set res [lrange $result 0 6]
               set command ""
               append command "set telscript($telscript(def,telname),goto,object) \"$res\";"
               append command "set telscript($telscript(def,telname),goto,status) todo"
               tel1 loopeval "$command"
               after 300
               set res [tel1 loopresult]
               console::affiche_resultat "res=$res\n"
            }
         pack $base.f.fpoi3.but_park -side left -anchor center -padx 3 -pady 3
      pack $base.f.fpoi3 -fill none -pady 0
      #--- SPEED
      frame $base.f.fs1 -bg $paramscript(color,back)
         label $base.f.fs1.lab_def \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text "SPEEP APP (adu)"
         pack $base.f.fs1.lab_def -side left -fill none -pady 0 -padx 4
         label $base.f.fs1.lab_ax0 \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fs1.lab_ax0 -side left -fill none -pady 0 -padx 4
         label $base.f.fs1.lab_ax1 \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fs1.lab_ax1 -side left -fill none -pady 0 -padx 4
         if {($telscript($telname,mount_type)=="azelevrot")} {
            label $base.f.fs1.lab_ax2 \
               -bg $paramscript(color,back) -fg $paramscript(color,text) \
               -font $paramscript(font) -text ""
            pack $base.f.fs1.lab_ax2 -side left -fill none -pady 0 -padx 4
         }
      pack $base.f.fs1 -fill none -pady 0
      frame $base.f.fs2 -bg $paramscript(color,back)
         label $base.f.fs2.lab_def \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text "SPEED COEFS (adu/(deg/s))"
         pack $base.f.fs2.lab_def -side left -fill none -pady 0 -padx 4
         label $base.f.fs2.lab_ax0 \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fs2.lab_ax0 -side left -fill none -pady 0 -padx 4
         label $base.f.fs2.lab_ax1 \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fs2.lab_ax1 -side left -fill none -pady 0 -padx 4
         if {($telscript($telname,mount_type)=="azelevrot")} {
            label $base.f.fs2.lab_ax2 \
               -bg $paramscript(color,back) -fg $paramscript(color,text) \
               -font $paramscript(font) -text ""
            pack $base.f.fs2.lab_ax2 -side left -fill none -pady 0 -padx 4
         }
      pack $base.f.fs2 -fill none -pady 0
      frame $base.f.fs3 -bg $paramscript(color,back)
         label $base.f.fs3.lab_def \
            -bg $paramscript(color,back) -fg $paramscript(color,green) \
            -font $paramscript(font) -text "SPEED APP (arcsec/s)"
         pack $base.f.fs3.lab_def -side left -fill none -pady 0 -padx 4
         label $base.f.fs3.lab_ax0 \
            -bg $paramscript(color,back) -fg $paramscript(color,yellow) \
            -font $paramscript(font) -text ""
         pack $base.f.fs3.lab_ax0 -side left -fill none -pady 0 -padx 4
         label $base.f.fs3.lab_ax1 \
            -bg $paramscript(color,back) -fg $paramscript(color,yellow) \
            -font $paramscript(font) -text ""
         pack $base.f.fs3.lab_ax1 -side left -fill none -pady 0 -padx 4
         if {($telscript($telname,mount_type)=="azelevrot")} {
            label $base.f.fs3.lab_ax2 \
               -bg $paramscript(color,back) -fg $paramscript(color,text) \
               -font $paramscript(font) -text ""
            pack $base.f.fs3.lab_ax2 -side left -fill none -pady 0 -padx 4
         }
         label $base.f.fs3.lab_bonus \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fs3.lab_bonus -side left -fill none -pady 0 -padx 4
      pack $base.f.fs3 -fill none -pady 0
      frame $base.f.fs4 -bg $paramscript(color,back)
         button $base.f.fs4.but_drifton \
            -text "Drift ON" -borderwidth 2 \
            -command {
               global telscript
               set telname $telscript(def,telname)
               set base $telscript(def,base)
               set command ""
               append command "set telscript($telscript(def,telname),action_next) motor_on;"
               tel1 loopeval "$command"
            }
         pack $base.f.fs4.but_drifton -side left -anchor center -padx 3 -pady 3
         button $base.f.fs4.but_driftoff \
            -text "Drift OFF" -borderwidth 2 \
            -command {
               global telscript
               set telname $telscript(def,telname)
               set base $telscript(def,base)
               set command ""
               append command "set telscript($telscript(def,telname),action_next) motor_off;"
               tel1 loopeval "$command"
            }
         pack $base.f.fs4.but_driftoff -side left -anchor center -padx 3 -pady 3
      pack $base.f.fs4 -fill none -pady 0
      # ---- raquette
      frame $base.f.fr1 -bg $paramscript(color,back)
         # --- vitesses de la raquette
         frame $base.f.fr1.fr1 -bg $paramscript(color,back)
            label $base.f.fr1.fr1.but_rapide -padx 10 -pady 15\
               -borderwidth 3 -relief raised \
               -text "Raquette rapide" -borderwidth 1 -bg $paramscript(color,back) \
               -fg $paramscript(color,text) -font $paramscript(font)
            pack $base.f.fr1.fr1.but_rapide -side top -anchor center -padx 3 -pady 3
            bind $base.f.fr1.fr1.but_rapide <ButtonPress-1> { gui_speed_shift base.f.fr1.fr1.but_rapide 1}
            bind $base.f.fr1.fr1.but_rapide <ButtonRelease-1> { gui_speed_shift base.f.fr1.fr1.but_rapide 0}
            label $base.f.fr1.fr1.but_lent -padx 10 -pady 15\
               -borderwidth 3 -relief raised \
               -text "Raquette lente" -borderwidth 1 -bg $paramscript(color,back) \
               -fg $paramscript(color,text) -font $paramscript(font)
            pack $base.f.fr1.fr1.but_lent -side top -anchor center -padx 3 -pady 3
            bind $base.f.fr1.fr1.but_lent <ButtonPress-1> { gui_speed_shift base.f.fr1.fr1.but_lent 2}
            bind $base.f.fr1.fr1.but_lent <ButtonRelease-1> { gui_speed_shift base.f.fr1.fr1.but_lent 0}
            label $base.f.fr1.fr1.but_spectro -padx 10 -pady 15\
               -borderwidth 3 -relief raised \
               -text "Raquette spectro" -borderwidth 1 -bg $paramscript(color,back) \
               -fg $paramscript(color,text) -font $paramscript(font)
            pack $base.f.fr1.fr1.but_spectro -side top -anchor center -padx 3 -pady 3
            bind $base.f.fr1.fr1.but_spectro <ButtonPress-1> { gui_speed_shift base.f.fr1.fr1.but_spectro 3}
            bind $base.f.fr1.fr1.but_spectro <ButtonRelease-1> { gui_speed_shift base.f.fr1.fr1.but_spectro 0}
         pack $base.f.fr1.fr1 -fill none -pady 0 -side left -padx 20
         # --- vitesses de la raquette
         frame $base.f.fr1.fr2 -bg $paramscript(color,back)
            frame $base.f.fr1.fr2.fr1 -bg $paramscript(color,back)
               label $base.f.fr1.fr2.fr1.but_n -padx 100 -pady 15\
                  -borderwidth 3 -relief raised \
                  -text "N" -borderwidth 1 -bg $paramscript(color,back) \
                  -fg $paramscript(color,text) -font $paramscript(font)
               pack $base.f.fr1.fr2.fr1.but_n -side top -anchor center -padx 3 -pady 3
               bind $base.f.fr1.fr2.fr1.but_n <ButtonPress-1> { gui_start_shift base.f.fr1.fr2.fr1.but_n N}
               bind $base.f.fr1.fr2.fr1.but_n <ButtonRelease-1> { gui_stop_shift base.f.fr1.fr2.fr1.but_n N}
            pack $base.f.fr1.fr2.fr1 -fill none -pady 0 -side top
            frame $base.f.fr1.fr2.fr2 -bg $paramscript(color,back)
               label $base.f.fr1.fr2.fr2.but_e -padx 100 -pady 15\
                  -borderwidth 3 -relief raised \
                  -text "E" -borderwidth 1 -bg $paramscript(color,back) \
                  -fg $paramscript(color,text) -font $paramscript(font)
               pack $base.f.fr1.fr2.fr2.but_e -side left -anchor center -padx 3 -pady 3
               bind $base.f.fr1.fr2.fr2.but_e <ButtonPress-1> { gui_start_shift base.f.fr1.fr2.fr2.but_e E}
               bind $base.f.fr1.fr2.fr2.but_e <ButtonRelease-1> { gui_stop_shift base.f.fr1.fr2.fr2.but_e E}
               label $base.f.fr1.fr2.fr2.but_w -padx 100 -pady 15\
                  -borderwidth 3 -relief raised \
                  -text "W" -borderwidth 1 -bg $paramscript(color,back) \
                  -fg $paramscript(color,text) -font $paramscript(font)
               pack $base.f.fr1.fr2.fr2.but_w -side left -anchor center -padx 3 -pady 3
               bind $base.f.fr1.fr2.fr2.but_w <ButtonPress-1> { gui_start_shift base.f.fr1.fr2.fr2.but_w W}
               bind $base.f.fr1.fr2.fr2.but_w <ButtonRelease-1> { gui_stop_shift base.f.fr1.fr2.fr2.but_w W}
            pack $base.f.fr1.fr2.fr2 -fill none -pady 0 -side top -padx 100
            frame $base.f.fr1.fr2.fr3 -bg $paramscript(color,back)
               label $base.f.fr1.fr2.fr3.but_s -padx 100 -pady 15\
                  -borderwidth 3 -relief raised \
                  -text "S" -borderwidth 1 -bg $paramscript(color,back) \
                  -fg $paramscript(color,text) -font $paramscript(font)
               pack $base.f.fr1.fr2.fr3.but_s -side top -anchor center -padx 3 -pady 3
               bind $base.f.fr1.fr2.fr3.but_s <ButtonPress-1> { gui_start_shift base.f.fr1.fr2.fr3.but_s S}
               bind $base.f.fr1.fr2.fr3.but_s <ButtonRelease-1> { gui_stop_shift base.f.fr1.fr2.fr3.but_s S}
            pack $base.f.fr1.fr2.fr3 -fill x -pady 0 -side top -padx 0
         pack $base.f.fr1.fr2 -fill none -pady 0 -side left -padx 0
      pack $base.f.fr1 -fill none -pady 0
      # --- focus
      frame $base.f.ffoc -bg $paramscript(color,back)
         frame $base.f.ffoc.fr2 -bg $paramscript(color,back)
            label $base.f.ffoc.fr2.lab1 -padx 90 -pady 15\
               -bg $paramscript(color,back)
            pack $base.f.ffoc.fr2.lab1 -side left -anchor center -padx 3 -pady 3
            label $base.f.ffoc.fr2.but_e -padx 80 -pady 15\
               -borderwidth 3 -relief raised \
               -text "Foc -" -borderwidth 1 -bg $paramscript(color,back) \
               -fg $paramscript(color,text) -font $paramscript(font)
            pack $base.f.ffoc.fr2.but_e -side left -anchor center -padx 3 -pady 3
            bind $base.f.ffoc.fr2.but_e <ButtonPress-1> { gui_start_focus base.f.ffoc.fr2.but_e -}
            bind $base.f.ffoc.fr2.but_e <ButtonRelease-1> { gui_stop_focus base.f.ffoc.fr2.but_e -}
            label $base.f.ffoc.fr2.but_w -padx 80 -pady 15\
               -borderwidth 3 -relief raised \
               -text "Foc +" -borderwidth 1 -bg $paramscript(color,back) \
               -fg $paramscript(color,text) -font $paramscript(font)
            pack $base.f.ffoc.fr2.but_w -side left -anchor center -padx 3 -pady 3
            bind $base.f.ffoc.fr2.but_w <ButtonPress-1> { gui_start_focus base.f.ffoc.fr2.but_w +}
            bind $base.f.ffoc.fr2.but_w <ButtonRelease-1> { gui_stop_focus base.f.ffoc.fr2.but_w +}
         pack $base.f.ffoc.fr2 -fill none -pady 0 -side top -padx 100
      pack $base.f.ffoc -fill none -pady 0 -padx 0
      # --- eval
      frame $base.f.feval1 -bg $paramscript(color,back)
         label $base.f.feval1.lab_def \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text "LOOP eval"
         pack $base.f.feval1.lab_def -side left -fill none -pady 0 -padx 4
         entry $base.f.feval1.ent \
            -textvariable telscript($telname,loopeval_input) -width 50
         pack $base.f.feval1.ent \
            -side left -anchor center -expand 1 -fill x \
            -padx 10 -pady 3
         button $base.f.feval1.but_eval \
            -text "loop eval" -borderwidth 2 \
            -command {
               global telscript
               set telname $telscript(def,telname)
               set base $telscript(def,base)
               $base.f.feval1.but_eval configure -state disabled
               set texte "set telname \$telscript(def,telname) ; $telscript($telname,loopeval_input)"
               tel1 loopeval $texte
               after 400
               set res [tel1 loopresult]
               $base.f.feval1.lab_res configure -text $res
               $base.f.feval1.but_eval configure -state active
            }
         pack $base.f.feval1.but_eval -side left -anchor center -padx 3 -pady 3
         label $base.f.feval1.lab_res \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.feval1.lab_res -side left -fill none -pady 0 -padx 4
      pack $base.f.feval1 -fill none -pady 0
      frame $base.f.fgetreg1 -bg $paramscript(color,back)
         label $base.f.fgetreg1.lab_def \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text "REGISTER axe X|M|K num ?val?"
         pack $base.f.fgetreg1.lab_def -side left -fill none -pady 0 -padx 4
         entry $base.f.fgetreg1.ent \
            -textvariable telscript($telname,loopeval_register) -width 15
         pack $base.f.fgetreg1.ent \
            -side left -anchor center -expand 1 -fill x \
            -padx 10 -pady 3
         button $base.f.fgetreg1.but_eval \
            -text "loop get/set register" -borderwidth 2 \
            -command {
               global telscript
               set telname $telscript(def,telname)
               set base $telscript(def,base)
               $base.f.fgetreg1.but_eval configure -state disabled
               set n [llength $telscript($telname,loopeval_register)]
               if {$n==4} {
                  set texte "etel_set_register_s $telscript($telname,loopeval_register)"
               } else {
                  set texte "etel_get_register_s $telscript($telname,loopeval_register)"
               }
               tel1 loopeval "$texte"
               after 400
               set res [tel1 loopresult]
               $base.f.fgetreg1.lab_res configure -text $res
               $base.f.fgetreg1.but_eval configure -state active
            }
         pack $base.f.fgetreg1.but_eval -side left -anchor center -padx 3 -pady 3
         label $base.f.fgetreg1.lab_res \
            -bg $paramscript(color,back) -fg $paramscript(color,text) \
            -font $paramscript(font) -text ""
         pack $base.f.fgetreg1.lab_res -side left -fill none -pady 0 -padx 4
      pack $base.f.fgetreg1 -fill none -pady 0
      frame $base.f.fgetreg2 -bg $paramscript(color,back)
         button $base.f.fgetreg2.but_save \
            -text "save params" -borderwidth 2 \
            -command {
               global telscript
               set telname $telscript(def,telname)
               set base $telscript(def,base)
               $base.f.fgetreg2.but_save configure -state disabled
               set texte "save_params"
               tel1 loopeval "$texte"
               after 400
               set res [tel1 loopresult]
               $base.f.fgetreg2.but_save configure -state active
            }
         pack $base.f.fgetreg2.but_save -side left -anchor center -padx 3 -pady 3
         button $base.f.fgetreg2.but_exit \
            -text "exit controleurs" -borderwidth 2 \
            -command {
               global telscript
               set telname $telscript(def,telname)
               set base $telscript(def,base)
               $base.f.fgetreg2.but_exit configure -state disabled
               set texte "save_x_stop_controlers"
               tel1 loopeval "$texte"
               after 400
               set res [tel1 loopresult]
               $base.f.fgetreg2.but_exit configure -state active
            }
         pack $base.f.fgetreg2.but_exit -side left -anchor center -padx 3 -pady 3
      pack $base.f.fgetreg2 -fill none -pady 0
   pack $base.f -fill both

   set telscript($telname,loopeval_register) "0 M 7"
   set telscript($telname,poi_objname) "*STOP"
   set result [gui_calcul_coordonnees $telscript($telname,poi_objname)]
   set res [lrange $result 0 6]
   set telscript($telscript(def,telname),simugoto,object) $res

   set command ""
   append command "set telscript($telscript(def,telname),external_trigger) 1"
   tel1 loopeval "$command"

   # --- infinite loop that updates the graphic interface
   set paramscript(loop) 1
   while {$paramscript(loop)==1} {
      after 100
      set errw [catch {
         set textevar ""
         foreach res [lsort [tel1 variables]] {
            eval "set $res"
            append textevar "$res\n"
         }
         set date [date_sys2ut now]
         $base.f.f3.lab_tu configure -text "Date = [string range [mc_date2iso8601 $date] 0 end-4] TU"
         $base.f.f3.lab_tsl configure -text "TSL = [string range [mc_date2lst $date $home] 0 end-7]"
         set res [tel1 action]
         $base.f.f2.lab_action configure -text "action = [lindex $res 0]"
         $base.f.f2.lab_loopno configure -text "boucle = [lindex $res 1]"
         $base.f.f2.lab_loopsimu configure -text "(simulation = $telscript($telname,simulation))"
         $base.f.f2.lab_loopmotion configure -text "motion = $telscript($telname,motion_next)"
         set res [tel1 looperror]
         if {$res!=""} {
            $base.f.f2.lab_looperror configure -text " $res"
         } else {
            $base.f.f2.lab_looperror configure -text ""
         }
         set radecj2000 [lrange $telscript($telname,simugoto,object) 3 4]
         if {($telscript($telname,mount_type)=="azelevrot")||($telscript($telname,mount_type)=="azelev")} {
            $base.f.fp1.lab_ax0 configure -text "az = $telscript($telname,coord_app_adu_az)"
            $base.f.fp1.lab_ax1 configure -text "elev = $telscript($telname,coord_app_adu_elev)"
            if {($telscript($telname,mount_type)=="azelevrot")} {
               $base.f.fp1.lab_ax2 configure -text "rot = $telscript($telname,coord_app_adu_rot)"
            }
            $base.f.fp2.lab_ax0 configure -text "az = $telscript($telname,adu4deg_az)"
            $base.f.fp2.lab_ax1 configure -text "elev = $telscript($telname,adu4deg_elev)"
            if {($telscript($telname,mount_type)=="azelevrot")} {
               $base.f.fp2.lab_ax2 configure -text "rot = $telscript($telname,adu4deg_rot)"
            }
            $base.f.fp3.lab_ax0 configure -text "az0 = $telscript($telname,coord_app_adu_az0)"
            $base.f.fp3.lab_ax1 configure -text "elev0 = $telscript($telname,coord_app_adu_elev0)"
            if {($telscript($telname,mount_type)=="azelevrot")} {
               $base.f.fp3.lab_ax2 configure -text "rot = $telscript($telname,coord_app_adu_rot0)"
            }
            $base.f.fp4.lab_ax0 configure -text "az0 = [format %.5f $telscript($telname,coord_app_deg_az0)]"
            $base.f.fp4.lab_ax1 configure -text "elev0 = [format %.5f $telscript($telname,coord_app_deg_elev0)]"
            if {($telscript($telname,mount_type)=="azelevrot")} {
               $base.f.fp4.lab_ax2 configure -text "rot = [format %.5f $telscript($telname,coord_app_deg_rot0)]"
            }
            $base.f.fp4a.lab_ax0 configure -text "az = [format %.5f $telscript($telname,simugoto_app_deg_az)]"
            $base.f.fp4a.lab_ax1 configure -text "elev = [format %.5f $telscript($telname,simugoto_app_deg_elev)] ($radecj2000)"
            if {($telscript($telname,mount_type)=="azelevrot")} {
               $base.f.fp4a.lab_ax2 configure -text "rot = [format %.4f $telscript($telname,simugoto_app_deg_rot)]"
            }
            $base.f.fp4b.lab_ax0 configure -text "az = [format %.0f $telscript($telname,simugoto_app_adu_az)]"
            $base.f.fp4b.lab_ax1 configure -text "elev = [format %.0f $telscript($telname,simugoto_app_adu_elev)]"
            if {($telscript($telname,mount_type)=="azelevrot")} {
               $base.f.fp4b.lab_ax2 configure -text "rot = [format %.0f $telscript($telname,simugoto_app_adu_rot)]"
            }
            # adu = adu0 + (az-az0)*adu4deg
            # Avant MATCH:
            # coord_app_deg_az0 <---> coord_app_adu_az0
            # on lit coord_app_adu_az (az)
            # on calcule coord_app_deg_az = coord_app_deg_az0 + (coord_app_adu_az - coord_app_adu_az0)/adu4deg
            # donc on a coord_app_adu_az = coord_app_adu_az0 + (coord_app_deg_az - coord_app_deg_az0)*adu4deg
            # donc on a coord_app_adu_az0 = coord_app_adu_az - (coord_app_deg_az - coord_app_deg_az0)*adu4deg
            # Pendant MATCH:
            # simugoto_app_deg_az <---> coord_app_adu_az
            # on calcule coord_app_adu_az0 = coord_app_adu_az - (simugoto_app_deg_az - coord_app_deg_az0)*adu4deg
            set adu0 [expr $telscript($telname,coord_app_adu_az)-($telscript($telname,simugoto_app_deg_az)-$telscript($telname,coord_app_deg_az0))*$telscript($telname,adu4deg_az)]
            $base.f.fp4c.lab_ax0 configure -text "az0 = [format %.0f $adu0]"
            set adu0 [expr $telscript($telname,coord_app_adu_elev)-($telscript($telname,simugoto_app_deg_elev)-$telscript($telname,coord_app_deg_elev0))*$telscript($telname,adu4deg_elev)]
            $base.f.fp4c.lab_ax1 configure -text "elev0 = [format %.0f $adu0]"
            if {($telscript($telname,mount_type)=="azelevrot")} {
               set adu0 [expr $telscript($telname,coord_app_adu_rot)-($telscript($telname,simugoto_app_deg_rot)-$telscript($telname,coord_app_deg_rot0))*$telscript($telname,adu4deg_rot)]
               $base.f.fp4c.lab_ax2 configure -text "rot0 = [format %.0f $adu0]"
            }
            $base.f.fp5.lab_ax0 configure -text "az = [format %.5f $telscript($telname,coord_app_deg_az)]"
            $base.f.fp5.lab_ax1 configure -text "elev = [format %.5f $telscript($telname,coord_app_deg_elev)]"
            if {($telscript($telname,mount_type)=="azelevrot")} {
               $base.f.fp5.lab_ax2 configure -text "rot = [format %.5f $telscript($telname,coord_app_deg_rot)]"
            }
            $base.f.fp5.lab_bonus configure -text "ha = [format %.5f $telscript($telname,coord_app_deg_ha)]   dec = [format %.5f $telscript($telname,coord_app_deg_dec)]"
            $base.f.fs1.lab_ax0 configure -text "daz = $telscript($telname,speed_app_adu_az)"
            $base.f.fs1.lab_ax1 configure -text "delev = $telscript($telname,speed_app_adu_elev)"
            if {($telscript($telname,mount_type)=="azelevrot")} {
               $base.f.fs1.lab_ax2 configure -text "drot = $telscript($telname,speed_app_adu_rot)"
            }
            $base.f.fs2.lab_ax0 configure -text "daz = $telscript($telname,adu4deg4sec_az)"
            $base.f.fs2.lab_ax1 configure -text "delev = $telscript($telname,adu4deg4sec_elev)"
            if {($telscript($telname,mount_type)=="azelevrot")} {
               $base.f.fs2.lab_ax2 configure -text "drot = $telscript($telname,adu4deg4sec_rot)"
            }
            $base.f.fs3.lab_ax0 configure -text "daz = [format %.3f $telscript($telname,speed_app_deg_az)]"
            $base.f.fs3.lab_ax1 configure -text "delev = [format %.3f $telscript($telname,speed_app_deg_elev)]"
            if {($telscript($telname,mount_type)=="azelevrot")} {
               $base.f.fs3.lab_ax2 configure -text "drot = [format %.3f $telscript($telname,speed_app_deg_rot)]"
            }
            $base.f.fs3.lab_bonus configure -text "dha = [format %.3f $telscript($telname,speed_app_deg_ha)]  ddec = [format %.3f $telscript($telname,speed_app_deg_dec)]"
         }
         if {$telscript($telname,mount_type)=="hadec"} {
            $base.f.fp1.lab_ax0 configure -text "ha = $telscript($telname,coord_app_adu_ha)"
            $base.f.fp1.lab_ax1 configure -text "dec = $telscript($telname,coord_app_adu_dec)"
            $base.f.fp2.lab_ax0 configure -text "ha = $telscript($telname,adu4deg_ha)"
            $base.f.fp2.lab_ax1 configure -text "dec = $telscript($telname,adu4deg_dec)"
            $base.f.fp3.lab_ax0 configure -text "ha0 = $telscript($telname,coord_app_adu_ha)"
            $base.f.fp3.lab_ax1 configure -text "dec0 = $telscript($telname,coord_app_adu_dec)"
            $base.f.fp4.lab_ax0 configure -text "ha0 = [format %.5f $telscript($telname,coord_app_deg_ha0)]"
            $base.f.fp4.lab_ax1 configure -text "dec0 = [format %.5f $telscript($telname,coord_app_deg_dec0)]"
            $base.f.fp4a.lab_ax0 configure -text "ha = [format %.5f $telscript($telname,simugoto_app_deg_ha)]"
            $base.f.fp4a.lab_ax1 configure -text "dec = [format %.5f $telscript($telname,simugoto_app_deg_dec)] ($radecj2000)"
            $base.f.fp4b.lab_ax0 configure -text "ha = [format %.0f $telscript($telname,simugoto_app_adu_ha)]"
            $base.f.fp4b.lab_ax1 configure -text "dec = [format %.0f $telscript($telname,simugoto_app_adu_dec)]"
            # adu =adu0 + (ang-ang0)*adu4deg
            set adu0 [expr $telscript($telname,coord_app_adu_ha)-($telscript($telname,simugoto_app_deg_ha)-$telscript($telname,coord_app_deg_ha0))*$telscript($telname,adu4deg_ha)]
            $base.f.fp4c.lab_ax0 configure -text "ha0 = [format %.0f $adu0]"
            set adu0 [expr $telscript($telname,coord_app_adu_dec)-($telscript($telname,simugoto_app_deg_dec)-$telscript($telname,coord_app_deg_dec0))*$telscript($telname,adu4deg_dec)]
            $base.f.fp4c.lab_ax1 configure -text "dec0 = [format %.0f $adu0]"
            $base.f.fp5.lab_ax0 configure -text "ha = [format %.5f $telscript($telname,coord_app_deg_ha)]"
            $base.f.fp5.lab_ax1 configure -text "dec = [format %.5f $telscript($telname,coord_app_deg_dec)]"
            $base.f.fp5.lab_bonus configure -text "az = [format %.5f $telscript($telname,coord_app_deg_az)]   elev = [format %.5f $telscript($telname,coord_app_deg_elev)]"
            $base.f.fs1.lab_ax0 configure -text "dha = $telscript($telname,speed_app_adu_ha)"
            $base.f.fs1.lab_ax1 configure -text "ddec = $telscript($telname,speed_app_adu_dec)"
            $base.f.fs2.lab_ax0 configure -text "dha = $telscript($telname,adu4deg4sec_ha)"
            $base.f.fs2.lab_ax1 configure -text "ddec = $telscript($telname,adu4deg4sec_dec)"
            $base.f.fs3.lab_ax0 configure -text "dha = [format %.3f $telscript($telname,speed_app_deg_ha)]"
            $base.f.fs3.lab_ax1 configure -text "ddec = [format %.3f $telscript($telname,speed_app_deg_dec)]"
            $base.f.fs3.lab_bonus configure -text "daz = [format %.3f $telscript($telname,speed_app_deg_az)]  delev = [format %.3f $telscript($telname,speed_app_deg_elev)]"
         }
         #lassign [tel1 radec coord] ra dec
         lassign [degs2radec] ra dec
         $base.f.fp6.lab_ra configure -text "ra = $ra"
         $base.f.fp6.lab_dec configure -text "dec = $dec"
         if {[$base.f.fpoi2.lab_coord cget -text]==""} {
            $base.f.fpoi2.lab_coord configure -text "coord coord [$base.f.fp6.lab_ra cget -text] [$base.f.fp6.lab_dec cget -text]"
         }
         #
         if {$telscript($telname,drift_move_rate)<0.35} {
            $base.f.fr1.fr1.but_rapide configure -bg $paramscript(color,back)
            $base.f.fr1.fr1.but_lent configure -bg $paramscript(color,back)
            $base.f.fr1.fr1.but_spectro configure -bg $paramscript(color,greendark)
         } elseif {$telscript($telname,drift_move_rate)<0.70} {
            $base.f.fr1.fr1.but_rapide configure -bg $paramscript(color,back)
            $base.f.fr1.fr1.but_lent configure -bg $paramscript(color,greendark)
            $base.f.fr1.fr1.but_spectro configure -bg $paramscript(color,back)
         } else {
            $base.f.fr1.fr1.but_rapide configure -bg $paramscript(color,greendark)
            $base.f.fr1.fr1.but_lent configure -bg $paramscript(color,back)
            $base.f.fr1.fr1.but_spectro configure -bg $paramscript(color,back)
         }
         if {$telscript($telname,motion_next)=="correction"} {
            if {$telscript($telname,move_generator)==0} {
               set direction [string toupper $telscript($telname,move_direction)]
            } else {
               set direction [string toupper $telscript($telname,external_move_direction)]
            }
            if {$direction=="N"} { $base.f.fr1.fr2.fr1.but_n configure -bg $paramscript(color,greendark) -relief sunken }
            if {$direction=="S"} { $base.f.fr1.fr2.fr3.but_s configure -bg $paramscript(color,greendark) -relief sunken }
            if {$direction=="E"} { $base.f.fr1.fr2.fr2.but_e configure -bg $paramscript(color,greendark) -relief sunken }
            if {$direction=="W"} { $base.f.fr1.fr2.fr2.but_w configure -bg $paramscript(color,greendark) -relief sunken }
         } else {
            $base.f.fr1.fr2.fr1.but_n configure -bg $paramscript(color,back) -relief raised
            $base.f.fr1.fr2.fr3.but_s configure -bg $paramscript(color,back) -relief raised
            $base.f.fr1.fr2.fr2.but_e configure -bg $paramscript(color,back) -relief raised
            $base.f.fr1.fr2.fr2.but_w configure -bg $paramscript(color,back) -relief raised
         }
      } msgw ]
      set telscript($telname,loop_gui,error_message) $msgw
      update
   }

}

