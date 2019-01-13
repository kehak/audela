#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_tools_avi.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_tools_avi.tcl
# Description    : Utilitaires pour la manipulation des AVI
# Auteur         : Frederic Vachier
# Mise à jour $Id: atos_tools_avi.tcl 14090 2016-10-20 21:51:50Z jberthier $
#

namespace eval ::atos_tools_avi {

   variable avi1
   variable log 0

   variable sommation 1
   variable uncosmic 0

   variable use_dark 0
   variable master_dark ""
   variable meandark_value 0

}

# ::atos_tools_avi::list_diff_shift
# Retourne la liste test epurée de l intersection des deux listes
proc ::atos_tools_avi::list_diff_shift { ref test }  {

   foreach elemref $ref {
      set new_test ""
      foreach elemtest $test {
         if {$elemref!=$elemtest} {lappend new_test $elemtest}
      }
      set test $new_test
   }
   return $test

}



proc ::atos_tools_avi::exist {  } {

   catch {
      set exist [ expr [ llength [info commands ::atos_tools_avi::avi1] ]  == 1 ]
      ::console::affiche_resultat "exists  : $exist\n"
      ::console::affiche_resultat "exists  : [info exists avi1]\n"
      ::console::affiche_resultat "globals : [info globals]\n"
      ::console::affiche_resultat "locals  : [info locals]\n"
      ::console::affiche_resultat "vars    : [info vars avi1]\n"
   }

}



proc ::atos_tools_avi::close_flux {  } {

   catch {
      ::atos_tools_avi::avi1 close
      rename ::atos_tools_avi::avi1 {}
   }

}


proc ::atos_tools_avi::select { visuNo } {

   global audace panneau

   set frm $::atos_gui::frame(base)

   #--- Fenetre parent
   set fenetre [::confVisu::getBase $visuNo]

   # Color mode
   set ::avi::default_color_mode $::atos::parametres(atos,$visuNo,color_mode)

   #--- Ouvre la fenetre de choix des images
   set bufNo [ visu$visuNo buf ]
   set ::atos_tools::avi_filename [ ::tkutil::box_load_avi $frm $audace(rep_images) $bufNo "1" ]
   $frm.open.avipath delete 0 end
   $frm.open.avipath insert 0 $::atos_tools::avi_filename

}



proc ::atos_tools_avi::open_flux { visuNo } {

   global audace panneau

   # Color mode
   set ::avi::default_color_mode $::atos::parametres(atos,$visuNo,color_mode)

   set bufNo [ visu$visuNo buf ]
   ::atos_tools_avi::close_flux
   ::avi::create ::atos_tools_avi::avi1
   catch { ::atos_tools_avi::avi1 load $::atos_tools::avi_filename }
   if {[::atos_tools_avi::avi1 status] != 0} {
      ::console::affiche_erreur "Echec du chargement de la video\n"
      catch {
         $::atos_gui::frame(info_load).status   configure -text "Error"
         $::atos_gui::frame(info_load).nbtotal  configure -text "?"
      }
      return
   }

   set ::atos_tools::cur_idframe 0
   set ::atos_tools::nb_open_frames [::atos_tools_avi::avi1 get_nb_frames]
   set ::atos_tools::nb_frames $::atos_tools::nb_open_frames
   set ::atos_tools::frame_begin 1
   set ::atos_tools::frame_end $::atos_tools::nb_frames

   ::atos_tools_avi::next_image
   ::audace::autovisu $audace(visuNo)

}



# Verification d un fichier avi
proc ::atos_tools_avi::verif { visuNo this } {

   global audace panneau

   #--- Determination de la fenetre parente
   if { $visuNo == "1" } {
      set base "$audace(base)"
   } else {
      set base ".visu$visuNo"
   }

   set bufNo [ visu$visuNo buf ]
   ::avi::create ::atos_tools_avi::avi1
   ::atos_tools_avi::avi1 load $::atos_tools::avi_filename
   set ::atos_tools::cur_idframe 0
   ::atos_tools_avi::next_image
   ::atos_tools_avi::exist
   set autocuts [buf$bufNo autocuts]
   visu$visuNo disp [list [lindex $autocuts 0] [lindex $autocuts 1]]

   set text [$panneau(atos,$visuNo,atos_verif).frmverif.results.txt cget -text]


   # Lancement des etapes de verification
   set nbimage [::atos_tools_avi::get_nbimage]
   append text "Nb d'images : $nbimage\n"

   append text "Test:"
   append text [::atos_tools_avi::avi1 test]
   append text "\n"
   ::atos_tools_avi::next_image
   append text "Test:"
   append text [::atos_tools_avi::avi1 test]
   append text "\n"

   # Fin
   $panneau(atos,$visuNo,atos_verif).frmverif.results.txt configure -text $text

}



proc ::atos_tools_avi::get_nbimage { } {
   
   return [::atos_tools_avi::avi1 get_nb_frames]

}



proc ::atos_tools_avi::next_image { } {

   if {![info exists ::atos_tools::cur_idframe]} {
      ::console::affiche_erreur "Error: ::atos_tools_avi::next_image: pas de video (unknown cur_idframe)\n"
      # Rien a faire car pas de video chargee
      return
   }

   if {$::atos_tools_avi::log} { ::console::affiche_resultat "\nnext_image deb : $::atos_tools::cur_idframe \n" }

   set ::atos_tools::cur_idframe [expr int($::atos_tools::cur_idframe + 1)]
   if { $::atos_tools::cur_idframe > $::atos_tools::frame_end } {
      set ::atos_tools::cur_idframe $::atos_tools::frame_end
   } else {
      ::atos_tools_avi::avi1 next
   }

   if {$::atos_tools_avi::log} {
      ::console::affiche_resultat "next_image fin : $::atos_tools::cur_idframe \n"
      set pc [expr ( $::atos_tools::cur_idframe - 1.0 ) / ( $::atos_tools::nb_frames - 1.0 ) ]
      ::console::affiche_resultat "next_image idframe = $::atos_tools::cur_idframe ; pc = $pc\n"
   }

}



proc ::atos_tools_avi::prev_image { } {

   if {![info exists ::atos_tools::cur_idframe]} {
      # Rien a faire car pas de video chargee
      return
   }

   if {$::atos_tools_avi::log} { ::console::affiche_resultat "\nprev_image av : $::atos_tools::cur_idframe \n " }

   set idframe [expr int($::atos_tools::cur_idframe - 1)]
   if { $idframe < $::atos_tools::frame_begin } {
      set idframe $::atos_tools::frame_begin
   }
   ::atos_tools_avi::set_frame $idframe

   if {$::atos_tools_avi::log} { ::console::affiche_resultat "prev_image ap : $::atos_tools::cur_idframe \n" }

}



proc ::atos_tools_avi::quick_next_image { } {

   set idframe [expr int($::atos_tools::cur_idframe + 100)]
   if { $idframe > $::atos_tools::frame_end } {
      set idframe $::atos_tools::frame_end
   }
   ::atos_tools_avi::set_frame $idframe

}



proc ::atos_tools_avi::quick_prev_image { } {

   set idframe [expr int($::atos_tools::cur_idframe - 100)]
   if { $idframe < $::atos_tools::frame_begin } {
      set idframe $::atos_tools::frame_begin
   }
   ::atos_tools_avi::set_frame $idframe

}





proc ::atos_tools_avi::set_frame { idframe } {

   if {![info exists ::atos_tools::nb_open_frames] || $::atos_tools::nb_open_frames == 0} {
      # Rien a faire car pas de video chargee
      return
   }

   if {$::atos_tools_avi::log} {
      ::console::affiche_resultat "$::atos_tools::cur_idframe $::atos_tools::frame_end $::atos_tools::frame_begin\n"
   }

   set nbf [expr $::atos_tools::nb_open_frames * 1.0]

   if {$idframe > $::atos_tools::frame_end} {
      set idframe $::atos_tools::frame_end
   }

   if {$idframe < $::atos_tools::frame_begin} {
      set idframe $::atos_tools::frame_begin
   }

   set ::atos_tools::cur_idframe [expr int($idframe)]

   if {$::atos_tools_avi::log} {
      set pc [expr ( $idframe - 1.0 ) / ( $nbf - 1.0 ) ]
      ::console::affiche_resultat "set_frame idframe = $idframe ; pc = $pc ; ($idframe-1) / ($nbf-1.0)\n"
   }

   ::atos_tools_avi::avi1 seektoframe [expr $idframe -1]

   set ::atos_tools::cur_idframe [expr $idframe -1]

   ::atos_tools_avi::next_image
   if {$::atos_tools_avi::log} {
      ::console::affiche_resultat "set_frame next_image cur_idframe = $::atos_tools::cur_idframe\n"
   }

   set ::atos_tools::cur_idframe [expr int($idframe)]
   if {$::atos_tools_avi::log} {
      ::console::affiche_resultat "cur_idframe final = $::atos_tools::cur_idframe\n"
   }

}



#   proc ::atos_tools_avi::avi_seek { visuNo arg } {
#      ::console::affiche_resultat "% : [expr $arg / 100.0 ]"
#      ::atos_tools::avi1 seekpercent [expr $arg / 100.0 ]
#      ::atos_tools::avi1 next
#      visu$visuNo disp
#   }



#   proc ::atos_tools_avi::avi_seekbyte { arg } {
#      set visuNo 1
#      ::console::affiche_resultat "arg = $arg"
#      ::atos_tools::avi1 seekbyte $arg
#      ::atos_tools::avi1 next
#      visu$visuNo disp
#   }



proc ::atos_tools_avi::setmin { This } {

   if { ! [info exists ::atos_tools::cur_idframe] } {
       tk_messageBox -message "Veuillez charger une video" -type ok
       return
   }

   $This.posmin delete 0 end
   $This.posmin insert 0 $::atos_tools::cur_idframe
   catch { $This.imagecount delete 0 end }

}



proc ::atos_tools_avi::setmax { This } {

   if { ! [info exists ::atos_tools::cur_idframe] } {
       tk_messageBox -message "Veuillez charger une video" -type ok
       return
   }

   $This.posmax delete 0 end
   $This.posmax insert 0 $::atos_tools::cur_idframe
   catch { $This.imagecount delete 0 end }

}



proc ::atos_tools_avi::imagecount {  } {

   if {![info exists ::atos_tools::nb_open_frames]} {
      # Rien a faire car pas de video chargee
      return
   }

   set posmin $::atos_gui::frame(posmin)
   set posmax $::atos_gui::frame(posmax)
   set imagecount $::atos_gui::frame(imagecount)

   $imagecount delete 0 end
   set fmin [$posmin get]
   set fmax [$posmax get]
   if { $fmin == "" } {
      set fmin 1
   }
   if { $fmax == "" } {
      set fmax $::atos_tools::nb_open_frames
   }
   $imagecount insert 0 [ expr $fmax - $fmin + 1 ]

}



proc ::atos_tools_avi::acq_is_running { } {

   set avipid ""
   set err [ catch {set avipid [exec sh -c "pgrep av4l-grab"]} msg ]
   if {$avipid == ""} {
       return 0
   } else {
      return 1
   }

}



proc ::atos_tools_avi::acq_display { visuNo } {

   global audace
   set tmpfs $::atos::parametres(atos,$visuNo,tmpfs)

   set frm_image        $::atos_gui::frame(image,values) 
   set frm_objet        $::atos_gui::frame(object,values) 
   set frm_reference    $::atos_gui::frame(reference,values) 
   set select_image     $::atos_gui::frame(image,buttons).select
   set select_objet     $::atos_gui::frame(object,buttons).select
   set select_reference $::atos_gui::frame(reference,buttons).select

   set bufNo [ visu$visuNo buf ]

   if {! [::atos_tools_avi::acq_is_running]} {
      ::atos_tools_avi::acq_stop
      $::atos_gui::frame(base).oneshot configure -state normal
      $::atos_gui::frame(base).oneshot2 configure -state normal
      $::atos_gui::frame(base).demarre configure -state normal
      ::console::affiche_resultat "Acquisition finie...\n"
      return
   }

   set pict [file join $tmpfs pict.yuv422]
   if {[ file exists $pict ]} {
      ::avi::convert_shared_image $bufNo $pict
      visu$visuNo disp
      ::audace::autovisu $visuNo
      file delete -force $pict

      cleanmark
      set statebutton [$select_objet cget -relief]
      if { $statebutton == "sunken" } {
         set delta [ $frm_objet.delta get]
         ::atos_cdl_tools::mesure_obj $::atos_cdl_tools::obj(x) $::atos_cdl_tools::obj(y) $visuNo $delta
      }
      set statebutton [ $select_reference cget -relief]
      if { $statebutton == "sunken" } {
         set delta [ $frm_reference.delta get]
         ::atos_cdl_tools::mesure_ref $::atos_cdl_tools::ref(x) $::atos_cdl_tools::ref(y) $visuNo $delta
      }
      set statebutton [ $select_image cget -relief]
      if { $statebutton == "sunken" } {
         ::atos_cdl_tools::get_fullimg $visuNo
      }
      if {$::atos_ocr_tools::active_ocr} {
         if {[$::atos_gui::frame(ocr,select) cget -relief] == "sunken" \
          && [$::atos_gui::frame(ocr,select) cget -state]  == "normal"} {
            ::atos_ocr_tools::workimage $visuNo
         }
      }

   }
   after $::atos::parametres(atos,$visuNo,screen_refresh) "::atos_tools_avi::acq_display $visuNo"

}




proc ::atos_tools_avi::acq_display_with_sum { visuNo } {

   global audace
   set tmpfs $::atos::parametres(atos,$visuNo,tmpfs)

   set frm_image        $::atos_gui::frame(image,values) 
   set frm_objet        $::atos_gui::frame(object,values) 
   set frm_reference    $::atos_gui::frame(reference,values) 
   set select_image     $::atos_gui::frame(image,buttons).select
   set select_objet     $::atos_gui::frame(object,buttons).select
   set select_reference $::atos_gui::frame(reference,buttons).select

   set bufNo [ visu$visuNo buf ]
   set bufNofs [ ::buf::create ]

   if {! [::atos_tools_avi::acq_is_running]} {
      ::atos_tools_avi::acq_stop
      $::atos_gui::frame(base).oneshot configure -state normal
      $::atos_gui::frame(base).oneshot2 configure -state normal
      $::atos_gui::frame(base).demarre configure -state normal
      ::console::affiche_resultat "Acquisition finie...\n"
      return
   }

   # Par defaut le travail est realise dans /dev/shm (tmpfs)
   for {set i 0} {$i<$::atos_tools_avi::sommation} {incr i} {
      set pict [file join $tmpfs pict.yuv422]
      if {[ file exists $pict ]} {
         ::avi::convert_shared_image $bufNofs $pict
         if {$::atos_tools_avi::use_dark} {
            buf$bufNofs sub $::atos_tools_avi::master_dark $::atos_tools_avi::meandark_value
         }
         if {$i == 0} {
            buf$bufNofs copyto $bufNo
         } else {
            buf$bufNofs save [file join $tmpfs buftmp.fit]
            buf$bufNo add [file join $tmpfs buftmp.fit] 0
         }
         file delete -force $pict
      }
      after 50
   }

   if {$::atos_tools_avi::uncosmic} { ::atos_tools::uncosmic $bufNo }
   visu$visuNo disp
   ::audace::autovisu $visuNo

   cleanmark
   set statebutton [ $select_objet cget -relief]
   if { $statebutton == "sunken" } {
      set delta [$frm_objet.delta get]
      ::atos_cdl_tools::mesure_obj $::atos_cdl_tools::obj(x) $::atos_cdl_tools::obj(y) $visuNo $delta
   }
   set statebutton [ $select_reference cget -relief]
   if { $statebutton == "sunken" } {
      set delta [$frm_reference.delta get]
      ::atos_cdl_tools::mesure_ref $::atos_cdl_tools::ref(x) $::atos_cdl_tools::ref(y) $visuNo $delta
   }
   set statebutton [ $select_image cget -relief]
   if { $statebutton == "sunken" } {
      ::atos_cdl_tools::get_fullimg $visuNo
   }
   if {$::atos_ocr_tools::active_ocr} {
      if {[$::atos_gui::frame(ocr,select) cget -relief]=="sunken" \
       && [$::atos_gui::frame(ocr,select) cget -state]=="normal"} {
         ::atos_ocr_tools::workimage $visuNo
      }
   }

   after $::atos::parametres(atos,$visuNo,screen_refresh) "::atos_tools_avi::acq_display_with_sum $visuNo"
   buf::delete $bufNofs
}




proc ::atos_tools_avi::acq_getdevinfo { visuNo autoflag } {

   global audace
   set frm $::atos_gui::frame(base)

   set bufNo [ visu$visuNo buf ]
   ::console::affiche_resultat "Get device info\n"

   set dev $::atos_acq::frmdevpath

   if { [ string equal $dev ""] } {
      set options "-0"
   } else {
      set options "-0 -i $dev"
   }

   if { [ string equal $autoflag auto ] } {
       set options "$options -a"
   }

   set devparams { }

   set commandline "LD_LIBRARY_PATH=$audace(rep_install)/bin $audace(rep_install)/bin/av4l-grab $options 2>&1"
   ::console::affiche_resultat "Appel de : $commandline\n"
   set err [ catch { exec sh -c $commandline } msg ]
   if { $err != 0 } {
      ::console::affiche_erreur "Echec lors de l'appel a av4l-grab\n"
      ::console::affiche_erreur "Code d'erreur : $err\n"
      ::console::affiche_erreur "=== Messages retournes par av4l-grab :\n"
      foreach line [split $msg "\n"] {
         ::console::affiche_erreur "$line\n"
      }
      ::console::affiche_erreur "=== Fin des messages\n"
      $frm.oneshot configure -state disabled
      $frm.oneshot2 configure -state disabled
      $frm.demarre configure -state disabled
      set ::atos_acq::frmdevmodel ?
      set ::atos_acq::frmdevinput ?
      set ::atos_acq::frmdevwidth ?
      set ::atos_acq::frmdevheight ?
      set ::atos_acq::frmdevdimen ?
      return $err
   } else {
      ::console::affiche_resultat "=== Messages retournes par av4l-grab :\n"
      foreach line [split $msg "\n"] {
         set l [split $line "="]
         if { [llength $l] == 2 } {
            lappend devparams [list [string trim [lindex $l 0]] [string trim [lindex $l 1]] ]
         }
         ::console::affiche_resultat "$line\n"
      }
      ::console::affiche_resultat "=== Fin des messages\n"

      $frm.oneshot configure -state normal
      $frm.oneshot2 configure -state normal
      $frm.demarre configure -state normal

      set ::atos_acq::frmdevmodel [lindex [lsearch -index 0 -inline $devparams cap_card] 1]
      set ::atos_acq::frmdevinput [lindex [lsearch -index 0 -inline $devparams video_input_index] 1]
      set ::atos_acq::frmdevwidth [lindex [lsearch -index 0 -inline $devparams format_width] 1]
      set ::atos_acq::frmdevheight [lindex [lsearch -index 0 -inline $devparams format_height] 1]
      set ::atos_acq::frmdevdimen "$::atos_acq::frmdevwidth X $::atos_acq::frmdevheight"
      if { [ string equal $dev ""] } {
         set ::atos_acq::frmdevpath [lindex [lsearch -index 0 -inline $devparams video_device] 1]
      }
   }

}


#
# Acquisition continue
# @param visuNo Numero de la visu courante
#
proc ::atos_tools_avi::acq_oneshot { visuNo } {

   global audace
   set tmpfs $::atos::parametres(atos,$visuNo,tmpfs)

   set bufNo [ visu$visuNo buf ]
   set bufNofs [ ::buf::create ]

   if { [acq_is_running] } {
      ::console::affiche_resultat "Acquisition en cours.\n"
      return
   }

   if {$::atos_tools_avi::sommation > 1} {
      ::console::affiche_resultat "Acquisition unique avec sommation de $::atos_tools_avi::sommation images ...\n"
   } else {
      ::console::affiche_resultat "Acquisition unique ...\n"
   }

   if {$::atos_tools_avi::uncosmic} {
      ::console::affiche_resultat "  Correction des cosmiques active\n"
   } else {
      ::console::affiche_erreur "  Pas de correction des cosmiques\n"
   }

   if {$::atos_tools_avi::use_dark && [file exists $::atos_tools_avi::master_dark]} {
      ::console::affiche_resultat "  Correction de dark active\n"
   } else {
      set ::atos_tools_avi::use_dark 0
      ::console::affiche_erreur "  Pas de correction de dark\n"
   }

   set dev $::atos_acq::frmdevpath
   if { [ string equal $dev ""] } {
      set options ""
      return
   } else {
      set options "-1 -i $dev"
   }

   for {set i 0} {$i<$::atos_tools_avi::sommation} {incr i} {
      set err [ catch { exec sh -c "LD_LIBRARY_PATH=$audace(rep_install)/bin $audace(rep_install)/bin/av4l-grab $options 2>&1" } msg ]
      if {$err != 0} {
         ::console::affiche_erreur "Echec lors de l'appel a av4l-grab\n"
         ::console::affiche_erreur "Code d'erreur : $err\n"
         ::console::affiche_erreur "=== Messages retournes par av4l-grab :\n"
         foreach line [split $msg "\n"] {
            ::console::affiche_erreur "$line\n"
         }
         ::console::affiche_erreur "=== Fin des messages\n"
         return $err
      } else {
         if {$i == 0} {
            ::console::affiche_resultat "=== Messages retournes par av4l-grab :\n"
            foreach line [split $msg "\n"] {
               ::console::affiche_resultat "$line\n"
            }
            ::console::affiche_resultat "=== Fin des messages\n"
         }
      }

      if {$err == 0} {
         set pict [file join $tmpfs pict.yuv422]
         if {[file exists $pict ]} {
            ::avi::convert_shared_image $bufNofs $pict
            if {$::atos_tools_avi::use_dark} {
               buf$bufNofs sub $::atos_tools_avi::master_dark $::atos_tools_avi::meandark_value
            }
            if {$i == 0} {
               buf$bufNofs copyto $bufNo
            } else {
               buf$bufNofs save [file join $tmpfs buftmp.fit]
               buf$bufNo add [file join $tmpfs buftmp.fit] 0
            }
            file delete -force $pict
         }
         after 0
      } else {
         ::console::affiche_erreur "Image inexistante \n"
      }
   }

   visu$visuNo disp
   ::audace::autovisu $visuNo

   set statebutton [ $::atos_gui::frame(object,select) cget -relief]
   if { $statebutton == "sunken" } {
      set delta [ $::atos_gui::frame(object,delta) get]
      ::atos_cdl_tools::mesure_obj $::atos_cdl_tools::obj(x) $::atos_cdl_tools::obj(y) $visuNo $delta
   }
   set statebutton [ $::atos_gui::frame(reference,select) cget -relief]
   if { $statebutton == "sunken" } {
      set delta [ $::atos_gui::frame(reference,delta) get]
      ::atos_cdl_tools::mesure_ref $::atos_cdl_tools::ref(x) $::atos_cdl_tools::ref(y) $visuNo $delta
   }
   set statebutton [ $::atos_gui::frame(image,select) cget -relief]
   if { $statebutton == "sunken" } {
      ::atos_cdl_tools::get_fullimg $visuNo
   }
   if {$::atos_ocr_tools::active_ocr} {
      if {[$::atos_gui::frame(ocr,select) cget -relief]=="sunken" \
       && [$::atos_gui::frame(ocr,select) cget -state]=="normal"} {
         
         ::atos_ocr_tools::workimage $visuNo
      }
   }

   buf::delete $bufNofs

}



#
# Acquisition continue
# @param visuNo Numero de la visu courante
#
proc ::atos_tools_avi::acq_oneshotcontinuous { visuNo } {

   global audace

   set bufNo [ visu$visuNo buf ]

   if { [acq_is_running] } {
      ::console::affiche_resultat "Acquisition en cours.\n"
      return
   }

   if {$::atos_tools_avi::sommation > 1} {
      ::console::affiche_resultat "Acquisition continue avec sommation de $::atos_tools_avi::sommation images ...\n"
   } else {
      ::console::affiche_resultat "Acquisition continue ...\n"
   }

   if {$::atos_tools_avi::uncosmic} {
      ::console::affiche_resultat "  Correction des cosmiques active\n"
   } else {
      ::console::affiche_erreur "  Pas de correction des cosmiques\n"
   }

   if {$::atos_tools_avi::use_dark && [file exists $::atos_tools_avi::master_dark]} {
      set ::atos_tools_avi::meandark_value 0
      set bufNodark [ ::buf::create ]
      buf$bufNodark load $::atos_tools_avi::master_dark
      set ::atos_tools_avi::meandark_value [format "%.0f" [lindex [buf$bufNodark stat] 4]]
      # Copy le dark dans tmpfs 
      set ::atos_tools_avi::master_dark [file join $::atos::parametres(atos,$visuNo,tmpfs) master_dark.fit]
      buf$bufNodark save $::atos_tools_avi::master_dark
      buf$bufNodark clear
      ::console::affiche_resultat "  Correction du dark active (mean dark = $::atos_tools_avi::meandark_value) ...\n"
   } else {
      set ::atos_tools_avi::use_dark 0
      ::console::affiche_erreur "  Pas de correction du dark\n"
   }

   set dev $::atos_acq::frmdevpath
   if { [ string equal $dev ""] } {
      set options ""
      return
   } else {
      set options "-2 -i $dev"
   }

   set err [ catch { set chan [open "|sh -c \"LD_LIBRARY_PATH=$audace(rep_install)/bin $audace(rep_install)/bin/av4l-grab $options > /dev/null 2>&1\"" r+] } msg ]

   if { $err != 0 } {
      ::console::affiche_erreur "Echec lors de l'appel a av4l-grab\n"
      ::console::affiche_erreur "Code d'erreur : $err\n"
      ::console::affiche_erreur "=== Messages retournes par av4l-grab :\n"
      foreach line [split $msg "\n"] {
         ::console::affiche_erreur "$line\n"
      }
      ::console::affiche_erreur "=== Fin des messages\n"
      return $err
   } else {
      ::console::affiche_resultat "=== Messages retournes par av4l-grab :\n"
      foreach line [split $msg "\n"] {
         ::console::affiche_resultat "$line\n"
      }
      ::console::affiche_resultat "=== Fin des messages\n"
   }

   after 100 " ::atos_tools_avi::acq_display_with_sum $visuNo"

}



proc ::atos_tools_avi::format_seconds { n } {

   set h [expr int($n / 3600)]
   set n [expr $n - $h * 3600]
   set m [expr int($n / 60)]
   set s [expr $n - $m * 60]
   return [format "%02d:%02d:%02d" $h $m $s]

}



proc ::atos_tools_avi::acq_grab_read_status { chan } {

   if {![eof $chan]} {
      gets $chan line
      if {[string equal -length 4 "tcl:" $line]} {
         set line [string range $line 4 end]
         set free_disk [lindex [lsearch -index 0 -inline $line free_disk] 1]
         $::atos_gui::frame(info,dispo) configure -text $free_disk
         set file_size [lindex [lsearch -index 0 -inline $line file_size_mb] 1]
         $::atos_gui::frame(info,size) configure -text $file_size
         set frame_count [lindex [lsearch -index 0 -inline $line frame_count] 1]
         $::atos_gui::frame(info,nbi) configure -text $frame_count
         set duree [lindex [lsearch -index 0 -inline $line duree] 1]
         $::atos_gui::frame(info,duree) configure -text [format_seconds $duree]
         set restduree [lindex [lsearch -index 0 -inline $line duree_rest] 1]
         $::atos_gui::frame(info,restduree) configure -text [format_seconds $restduree]
      } else {
         if {[string equal -length 2 "W:" $line] || [string equal -length 2 "E:" $line]} {
            ::console::affiche_erreur "$line\n"
         } else {
            ::console::affiche_resultat "$line\n"
         }
      }
   } else {
      close $chan
   }

}



proc ::atos_tools_avi::acq_start { visuNo { timing "" } } {

   global audace

   set dev $::atos_acq::frmdevpath
   set destdir [$::atos_gui::frame(dest,dir) get]
   set prefix  [$::atos_gui::frame(dest,prefix) get]

   if { [acq_is_running] } {
      ::console::affiche_resultat "Acquisition en cours.\n"
      return
   }

   if {$timing == ""} {
      ::console::affiche_resultat "Acquisition continue avec sauvegarde ...\n"
   } else {
      ::console::affiche_resultat "Acquisition de $timing avec sauvegarde ...\n"
   }

   if { $dev == "" } {
      ::console::affiche_erreur "Veuillez choisir un peripherique de capture !\n"
      return
   }

   if { $destdir == "" } {
      ::console::affiche_erreur "Veuillez choisir un repertoire !"
      return
   }

   set prefix [string trim $prefix]
   set prefix [string map {" " _} $prefix]
   if { $prefix == "" } {
      ::console::affiche_erreur "Veuillez choisir un nom de fichier !"
      return
   }

   set tag [clock format [clock seconds] -timezone :UTC -format %Y%m%dT%H%M%S]
   set prefix "$prefix-$tag"

   if {$timing == ""} {
      set options "-i $dev -y $::atos::parametres(atos,$visuNo,screen_refresh) -s $::atos::parametres(atos,$visuNo,free_space) -d 120m -c 120m -o $destdir -p $prefix"
   } else {
      set options "-i $dev -y $::atos::parametres(atos,$visuNo,screen_refresh) -s $::atos::parametres(atos,$visuNo,free_space) -d $timing -c $timing -o $destdir -p $prefix"
   }

   ::console::affiche_resultat "Acquisition demarre ...\n"
   ::console::affiche_resultat "           path   : $destdir\n"
   ::console::affiche_resultat "           prefix : $prefix\n"
   ::console::affiche_resultat "           options: $options\n"

   set err [ catch { set chan [open "|sh -c \"LD_LIBRARY_PATH=$audace(rep_install)/bin $audace(rep_install)/bin/av4l-grab $options 2>&1\"" r+] } msg ]

   if { $err != 0 } {
      ::console::affiche_erreur "Echec lors de l'execution de av4l-grab\n"
      return
   }

   fconfigure $chan -blocking 0
   fileevent $chan readable [list ::atos_tools_avi::acq_grab_read_status $chan]

   after 100 "::atos_tools_avi::acq_display $visuNo"

}



proc ::atos_tools_avi::acq_stop { } {

   global audace

   set avipid ""
   set err [ catch {set avipid [exec sh -c "pgrep av4l-grab"]} msg ]
   if {$avipid == ""} {
      ::console::affiche_resultat "Aucune acquisition en cours\n"
      return
   }

   set err [ catch {[exec pkill -x av4l-grab]} msg ]
   after 2000

   if { [::atos_tools_avi::acq_is_running] } {
      ::console::affiche_erreur "L'acquisition n'a pas pu etre arretee\n"
   }

}
