#
# Projet EYE
# Description : Pilotage d un chercheur electronique asservissant une monture
# Auteur : Frederic Vachier
# Mise a jour $Id: eye.funcs.telescop.tcl 14055 2016-10-01 00:20:40Z fredvachier $
#
   proc ::eye::tel_isconnected { } {
      if { [lsearch [tel::list] $::eye::tel ] != -1 } {
         return 1
      } else {
         return 0
      }
      return [info exists ::eye::tel]
   }





   proc ::eye::tel_goto { } {

      if {$::eye::tel ni [tel::list]} {return}

      set ra  $::eye::widget(coord,wanted,raJ2000)
      set dec $::eye::widget(coord,wanted,decJ2000)

      set w_ra  [mc_angle2deg $ra]
      set w_de  [mc_angle2deg $dec]

      set kwd [buf$::eye::bufNo getkwd "RA"]
      buf$::eye::bufNo setkwd  [lreplace $kwd 1 1 $w_ra]
      set kwd [buf$::eye::bufNo getkwd "DEC"]
      buf$::eye::bufNo setkwd [lreplace $kwd 1 1 $w_de]

      set ::eye::widget(keys,new,equinox) "J2000"

      gren_info "GOTO : tel$::eye::tel radec goto {$ra $dec} -blocking 1\n"

      # on peut gerer le speedtrack = tracking une fois qu il a fait le goto
      
      set err [ catch { tel$::eye::tel radec goto [list $ra $dec] -blocking 1 } msg ]
      if {$err} {
         gren_erreur "::eye::tel_goto: error $err with msg = $msg\n"
      }
      gren_info "GOTO : END :: TRACKING = \[[tel$::eye::tel radec state]\]\n"
      # tel$::eye::tel radec goto {4h43m -3d23m} -blocking 1
      #::eye::tel_tracking_on
      
   }





#tel1 hadec coord
   proc ::eye::tel_get_pos { } {

      if {$::eye::tel ni [tel::list]} {return}

#      gren_info "COORD : tel$::eye::tel radec coord -equinox J2000\n"
      set radec [tel$::eye::tel radec coord -equinox J2000]
      
            # apparent to J2000
            #set now [mc_date2jd now]
            #set radec [mc_nutationradec $radec $now -reverse]
            #set radec [mc_precessradec $radec $now "J2000" ]
            #set radec [mc_aberrationradec annual $radec $now -reverse]
      
      set ::eye::widget(coord,mount,raJ2000)  [mc_angle2hms [lindex $radec 0] 360 zero 1 auto string]
      set ::eye::widget(coord,mount,decJ2000) [mc_angle2dms [lindex $radec 1] 90 zero 1 + string]


      if {$::eye::widget(coord,wanted,raJ2000) != "" && $::eye::widget(coord,wanted,decJ2000) != "" } {
         set dar [expr [mc_angle2deg $::eye::widget(coord,mount,raJ2000)]  - [mc_angle2deg $::eye::widget(coord,wanted,raJ2000)]]
         set dde [expr [mc_angle2deg $::eye::widget(coord,mount,decJ2000)] - [mc_angle2deg $::eye::widget(coord,wanted,decJ2000)]]
         set ::eye::widget(coord,mount,dist) [format "%.1f min" [expr 60.0*sqrt($dar*$dar+$dde*$dde)]]
         set ::eye::widget(coord,mount,state) [tel$::eye::tel radec state]
      } else {
         set ::eye::widget(coord,mount,dist) ""
      }

      return 0
   }





# tel1 hadec init {18h 90}
   proc ::eye::tel_init_pos_on_calib { } {

      if {$::eye::tel ni [tel::list]} {return}

      set ra  [string trim $::eye::widget(coord,reticule,raJ2000) ]
      set dec [string trim $::eye::widget(coord,reticule,decJ2000)]

      if {$ra != "" && $dec !="" } {
         set r [tk_messageBox -message "La monture va etre synchronisée sur les coordonnees :\n $ra $dec" -type yesno]
         if {$r == "yes"} {
            set radec [list $ra $dec]

            tel$::eye::tel radec init $radec
            gren_info "tel_init_pos_on_calib: tel$::eye::tel radec init {$radec}\n"
         }
      } else {
         tk_messageBox -message "Il faut une calibration reussie pour pouvoir synchroniser les coordonnees" -type ok
      }
      return 0
   }





   proc ::eye::tel_init_pos_on_map { } {

      if {$::eye::tel ni [tel::list]} {return}

      set ra  [string trim $::eye::widget(coord,wanted,raJ2000) ]
      set dec [string trim $::eye::widget(coord,wanted,decJ2000)]

      

      if {$ra != "" && $dec !="" } {
         set r [tk_messageBox -message "La monture va etre synchronisée sur les coordonnees :\n $ra $dec" -type yesno]
         if {$r == "yes"} {
            set radec [list $ra $dec]

            # apparent to J2000
            #set now [mc_date2jd now]
            #set radec [mc_nutationradec $radec $now -reverse]
            #set radec [mc_precessradec $radec $now "J2000" ]
            #set radec [mc_aberrationradec annual $radec $now -reverse]

            # on transforme en coordonnees apparente
            #set now   [mc_date2jd now]
            #set radec [mc_aberrationradec annual $radec $now]
            #set radec [mc_precessradec $radec  "J2000" $now]
            #set radec [mc_nutationradec $radec $now]
            #set raa   [mc_angle2hms [lindex $radec 0] 360 zero 1 auto string]
            #set deca  [mc_angle2dms [lindex $radec 1] 90 zero 1 + string]

            set ra  [mc_angle2hms [lindex $radec 0] 360 zero 1 auto string]
            set dec [mc_angle2dms [lindex $radec 1] 90 zero 1 + string]
            
            tel$::eye::tel radec init  [list $ra $dec]
            gren_info "tel_init_pos_on_map: tel$::eye::tel radec init {[list $ra $dec]}\n"
         }
      } else {
         tk_messageBox -message "Il faut selectionner un objet dans la carte et avoir fait un GOTO sur cet objet" -type ok
      }
      return 0
   }





   proc ::eye::tel_tracking { } {
      if {$::eye::tel ni [tel::list]} {return}
      set ::eye::widget(coord,mount,motor) [tel$::eye::tel radec state]
   }





   proc ::eye::tel_tracking_on { } {
      if {$::eye::tel ni [tel::list]} {return}
      tel$::eye::tel radec motor on
   }





   proc ::eye::tel_tracking_off { } {
      if {$::eye::tel ni [tel::list]} {return}
      tel$::eye::tel radec motor off
   }





   proc ::eye::tel_goto_parking { } {
      if {$::eye::tel ni [tel::list]} {return}
      set ::eye::widget(coord,wanted,raJ2000)  ""
      set ::eye::widget(coord,wanted,decJ2000) ""
      tel$::eye::tel gotoparking
   }





   proc ::eye::tel_move_offset { } {

      if {$::eye::tel ni [tel::list]} {return}

      set ra  [expr [mc_angle2deg $::eye::widget(coord,wanted,raJ2000) ] + [mc_angle2deg $::eye::widget(coord,reticule,draJ2000)]]
      set dec [expr [mc_angle2deg $::eye::widget(coord,wanted,decJ2000)] + [mc_angle2deg $::eye::widget(coord,reticule,ddecJ2000)]]

      set err [ catch {[tel$::eye::tel radec goto [list $ra $dec] -equinox J2000]} msg ]
      if {$err} {
         gren_erreur "::eye::tel_move_offset: error $err with msg = $msg\n"
      }

   }

