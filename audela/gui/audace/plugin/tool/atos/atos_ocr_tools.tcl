#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_ocr_tools.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_ocr_tools.tcl
# Description    : Utilitaires pour la reconnaissance de caracteres
# Auteur         : Frederic Vachier
# Mise à jour $Id: atos_ocr_tools.tcl 14424 2018-05-03 15:41:51Z fredvachier $
#

namespace eval ::atos_ocr_tools {

   variable sortie
   variable active_ocr
   variable nbverif
   variable nbocr
   variable nbinterp
   variable timing
   variable rect_img

}

proc ::atos_ocr_tools::select_time { visuNo } {

   global color

   set setup $::atos_gui::frame(ocr_setup)
   set statebutton [$setup.ocr.selectdate.box cget -relief]

   # desactivation
   if {$statebutton == "sunken"} {
      $setup.ocr.selectdate.box configure -text "Select" -fg $color(black)
      $setup.ocr.selectdate.box configure -relief raised
      return
   }

   # activation
   if {$statebutton == "raised"} {

      # Recuperation de la zone de l'image contenant l'incrustation du temps
      set rect [ ::confVisu::getBox $visuNo ]

      # Affichage de la taille de la fenetre
      if {$rect == ""} {
         set ::atos_ocr_tools::rect_img ""
      } else {
         set taillex [expr [lindex $rect 2] - [lindex $rect 0] ]
         set tailley [expr [lindex $rect 3] - [lindex $rect 1] ]
         $setup.ocr.selectdate.box configure -text "${taillex}x${tailley}" -fg $color(blue)
         set ::atos_ocr_tools::rect_img $rect
      }
      $setup.ocr.selectdate.box configure -relief sunken
      ::atos_ocr_tools::workimage $visuNo
      return
   }

}



proc ::atos_ocr_tools::select_ocr { visuNo } {

   global color
   set ocr $::atos_gui::frame(ocr_setup)
   set setunset $::atos_gui::frame(setunset)

   # desactivation
   if {$::atos_ocr_tools::active_ocr == "0"} {
      $ocr.ocr.incrust.spin configure -state disabled
      $ocr.ocr.selectdate.box configure -state disabled
      $setunset.t.ocr configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
      $setunset.t.ocr configure -state disabled
      return
   } else {
      $ocr.ocr.incrust.spin configure -state normal
      $ocr.ocr.selectdate.box configure -state normal
      $setunset.t.ocr configure -state normal
      ::atos_ocr_tools::workimage $visuNo
      return
   }

}


proc ::atos_ocr_tools::ocr_sharpcap { msg } {

# MSG = 2016 09 01 08:14:12:804

   # avec blanc comme separateur
   set poslist [split $msg " "]
   set yy  [lindex $poslist 0]
   set mm  [lindex $poslist 1]
   set dd  [lindex $poslist 2]
   set hms [lindex $poslist 3]

   # avec deux points comme separateur
   set poslist [split $hms ":"]
   set h  [lindex $poslist 0]
   set m  [lindex $poslist 1]
   set s  [lindex $poslist 2]
   set ms [string range [lindex $poslist 3] 0 2]

   set pass "ok"

   if { $h<0  || $h>24   || $h==""  } {set pass "no"}
   if { $m<0  || $m>59   || $m==""  } {set pass "no"}
   if { $s<0  || $s>59   || $s==""  } {set pass "no"}
   if { $ms<0 || $ms>999 || $ms=="" } {set pass "no"}

   return [list $pass [list $yy $mm $dd] [list $h $m $s $ms]]
}



proc ::atos_ocr_tools::ocr_kiwi { msg } {

   # avec deux points comme separateur
   #::console::affiche_resultat "** avec deux points comme separateur \n"
   set poslist [split $msg " "]
   #::console::affiche_resultat "   poslist = $poslist \n"
   set hms [lindex $poslist 0]
   #::console::affiche_resultat "   hms = $hms \n"
   set ms  [lindex $poslist 4]
   set poslist [split $hms "_"]
   #::console::affiche_resultat "   poslist = $poslist \n"
   set h   [lindex $poslist 0]
   set min [lindex $poslist 1]
   set s   [lindex $poslist 2]

   set pass "ok"

   if { $h<0 || $h>24 || $h=="" } {set pass "no"}
   if { $min<0 || $min>59 || $min=="" } {set pass "no"}
   if { $s<0 || $s>59 || $s=="" } {set pass "no"}
   if { $ms<0 || $ms>999 || $ms=="" } {set pass "no"}

   # avec des espaces comme separateur
   #::console::affiche_resultat "** avec des espaces comme separateur \n"
   if { $pass == "no" } {
      set poslist [split $msg " "]
      #::console::affiche_resultat "   poslist = $poslist \n"
      set h   [lindex $poslist 0]
      set min [lindex $poslist 1]
      set s   [lindex $poslist 2]
      set ms  [lindex $poslist 6]

      set pass "ok"
      if { $h<0 || $h>24 || $h=="" } {set pass "no"}
      if { $min<0 || $min>59 || $min=="" } {set pass "no"}
      if { $s<0 || $s>59 || $s=="" } {set pass "no"}
      if { $ms<0 || $ms>999 || $ms=="" } {set pass "no"}

   }

   return [list $pass [list "XXXX" "XX" "XX"] [list $h $min $s $ms]]
}




proc ::atos_ocr_tools::ocr_tim10 { msg } {

   # Recuperation des l'heure depuis l'image paire
   set byy "20[string range $msg 0 1]"
   set bmm [string range $msg 2 3]
   set bdd [string range $msg 4 5]
   set bh  [string range $msg 7 8]
   set bm  [string range $msg 9 10]
   set bs  [string range $msg 11 12]
   set bms [string range $msg 15 17]
   
   gren_info "TIM-10 epoch = $byy $bmm $bdd $bh $bm $bs $bms\n"
   
   set yy "XXXX"
   set err [catch {regexp {[2][0][0-9][0-9]} $byy matched} msg]
   if {$msg == 1} { if {$byy == $matched} {set yy $byy} }
   set mm "XX"
   set err [catch {regexp {[0-9][0-9]} $bmm matched} msg]
   if {$msg == 1} { if {$bmm == $matched} {set mm $bmm} }
   set dd "XX"
   set err [catch {regexp {[0-9][0-9]} $bdd matched} msg]
   if {$msg == 1} { if {$bdd == $matched} {set dd $bdd} }
   
   set h "XX"
   set err [catch {regexp {[0-9][0-9]} $bh matched} msg]
   if {$msg == 1} { if {$bh == $matched} {set h $bh} }
   set m "XX"
   set err [catch {regexp {[0-9][0-9]} $bm matched} msg]
   if {$msg == 1} { if {$bm == $matched} {set m $bm} }
   set s "XX"
   set err [catch {regexp {[0-9][0-9]} $bs matched} msg]
   if {$msg == 1} { if {$bs == $matched} {set s $bs} }
   set ms "XXX"
   set err [catch {regexp {[0-9][0-9][0-9]} $bms matched} msg]
   if {$msg == 1} { if {$bms == $matched} {set ms $bms} }
   
   return [list "ok" [list $yy $mm $dd] [list $h $m $s $ms]]

#      ::console::affiche_resultat "OCR TIM-10 non pris en charge (lisibilite de la fonte insuffisante)\n"
#      return [list "ok" [list "XXXX" "XX" "XX"] [list "XX" "XX" "XX" "XXX"]]
}



#
# Decodage de l'OCR des IOTA-VTI. Le milieu de pose est la plus petite des deux valeurs de ms
# (c.f.: http://www.poyntsource.com/New/IOTAVTI.htm PART THREE)
# 
proc ::atos_ocr_tools::ocr_iota_vti { msg_even msg_odd } {

   # Recuperation de l'heure depuis l'image paire
   set poslist [split [regexp -inline -all -- {\S+} $msg_even] " "]
   #::console::affiche_erreur "poslist = [lindex $poslist 0] ;; [lindex $poslist 1]\n"
   set t    [split [lindex $poslist 0] ":"]
   #::console::affiche_erreur "t = $t\n"
   set hp   [scan [lindex $t 0] "%d"]
   set minp [scan [lindex $t 1] "%d"]
   set sp   [scan [lindex $t 2] "%d"]
   set msp  [scan [lindex $poslist 1] "%d"]
   #::console::affiche_resultat "EVEN: $msg_even => $hp : $minp : $sp : $msp :: \n" 
   
   if { ! ( [string is double $hp] && [string is double $minp] \
         && [string is double $sp] && [string is double $msp] ) } {
      return [list "no" [list "XXXX" "XX" "XX"] [list "XX" "XX" "XX" "XXX"]]
   }

   set hdp  [expr $hp + $minp/60.0 + ($sp+$msp/10000.0)/3600.0]

   # Recuperation de l'heure depuis l'image impaire
   set poslist [split [regexp -inline -all -- {\S+} $msg_odd] " "]
   #::console::affiche_erreur "poslist = [lindex $poslist 0] ;; [lindex $poslist 1]\n"
   set t    [split [lindex $poslist 0] ":"]
   #::console::affiche_erreur "t = $t\n"
   set hi   [scan [lindex $t 0] "%d"]
   set mini [scan [lindex $t 1] "%d"]
   set si   [scan [lindex $t 2] "%d"]
   set msi  [scan [lindex $poslist 1] "%d"]
   #::console::affiche_resultat "ODD: $msg_odd => $hi : $mini : $si : $msi :: \n"

   if { ! ( [string is double $hi] && [string is double $mini] \
        && [string is double $si] && [string is double $msi] ) } {
      return [list "no" [list "XXXX" "XX" "XX"] [list "XX" "XX" "XX" "XXX"]]
   }

   set hdi  [expr $hi + $mini/60.0 + ($si+$msi/10000.0)/3600.0]

   # L'heure la plus petite est le milieu de pose
   if {$hdp > $hdi} {
      set hevent $hdi
   } else {
      if {$hdp < 12.0 && $hdi > 12.0} {
         set hevent $hdi
      } else {
         set hevent $hdp
      }
   }
   set hms [mc_angle2hms [expr $hevent*15.0]]
   set h [lindex $hms 0]
   set min [lindex $hms 1]
   set ss [split [format "%.3f" [lindex $hms 2]] "."]
   set s [lindex $ss 0]
   set ms [lindex $ss 1]
   #::console::affiche_resultat " => $hevent -> $h $min $s $ms\n"

   set pass "ok"

   if { $h<0 || $h>24 || $h=="" } {set pass "no"}
   if { $min<0 || $min>59 || $min=="" } {set pass "no"}
   if { $s<0 || $s>59 || $s=="" } {set pass "no"}
   if { $ms<0 || $ms>999 || $ms=="" } {set pass "no"}

   return [list $pass [list "XXXX" "XX" "XX"] [list $h $min $s $ms]]

}



# Deentrelace l'image img et cree les images paire et impaire
proc ::atos_ocr_tools::deinterlace { img } {

   set img_ocr [image create photo -file $img]
   set tx [image width $img_ocr]
   set ty [image height $img_ocr]

   # Cree un cache de l'image
   set img_cache [image create photo -width $tx -height $ty]

   # Image paire
   set img_even_name "ocr_even.jpg"
   set img_even [image create photo -width $tx -height $ty]
   $img_cache copy $img_ocr -subsample 1 2 -from 0 0
   $img_even copy $img_cache -zoom 1 2
   $img_even write $img_even_name -format "jpeg -quality 90 -optimize"
   
   # Image impaire
   set img_odd_name "ocr_odd.jpg"
   set img_odd [image create photo -width $tx -height $ty]
   $img_cache copy $img_ocr -subsample 1 2 -from 0 1
   $img_odd copy $img_cache -zoom 1 2
   $img_odd write $img_odd_name -format "jpeg -quality 90 -optimize"

   return [list $img_even_name $img_odd_name]

}



proc ::atos_ocr_tools::test { visuNo } {

}



proc ::atos_ocr_tools::workimage { visuNo } {

   global panneau color

   set setup    $::atos_gui::frame(ocr_setup)
   set datetime $::atos_gui::frame(datetime)
   set setunset $::atos_gui::frame(setunset)
   set statebutton [$setup.ocr.selectdate.box cget -relief]

   if {$::atos_ocr_tools::active_ocr == "0" || $statebutton != "sunken"} {
      # OCR non actif, return
      return -1
   }

   # Extraction de la date a partir de l'OCR
   set box [$setup.ocr.incrust.spin get]
   set rect $::atos_ocr_tools::rect_img

   if { [info exists $rect] } {
      return 0
   }

   set bufNo [ visu$visuNo buf ]

   set bf [::buf::create]
   buf$bufNo copyto $bf

   buf$bf window $rect

   set mx [::confVisu::getMirrorX $visuNo]
   if { $mx == 1 } { buf$bf mirrorx }

   set my [::confVisu::getMirrorY $visuNo]
   if { $my == 1 } { buf$bf mirrory }

   # buf1 save ocr.png
   set stat [buf$bf stat]
   buf$bf savejpeg ocr.jpg 100 [lindex $stat 3] [lindex $stat 0]

   buf::delete $bf

   switch $box {

      "SHARPCAP" {
        set err [catch {
           set result [exec sh -c "$::atos_ocr::panneau(atos,$visuNo,exec_ocr_sharpcap) ocr.jpg"]
        } msg]
      }

      "KIWI-OSD" {
        set err [catch {
           set result [exec sh -c "$::atos_ocr::panneau(atos,$visuNo,exec_ocr_kiwi) ocr.jpg"]
        } msg]
      }

      "TIM-10" {
        # Deentrelace l'image
        set deint_ocr [::atos_ocr_tools::deinterlace ocr.jpg]
        # Extrait l'OCR de l'image impaire
        if {$::atos_ocr::panneau(atos,$visuNo,exec_convert_tim) != ""} {
          set err [catch {
             set result [exec sh -c "$::atos_ocr::panneau(atos,$visuNo,exec_convert_tim) [lindex $deint_ocr 1] [lindex $deint_ocr 1]"]
          } msg]
        }
        set err [catch {
           set result [exec sh -c "$::atos_ocr::panneau(atos,$visuNo,exec_ocr_tim) [lindex $deint_ocr 1]"]
        } msg]
      }

      "IOTA-VTI" {
        # Deentrelace l'image
        set deint_ocr [::atos_ocr_tools::deinterlace ocr.jpg]
        # Extrait l'OCR de l'image paire
        if {$::atos_ocr::panneau(atos,$visuNo,exec_convert_vti) != ""} {
          set err [catch {
             set result [exec sh -c "$::atos_ocr::panneau(atos,$visuNo,exec_convert_vti) [lindex $deint_ocr 0] [lindex $deint_ocr 0]"]
          } msg]
        }
        set err [catch {
           set result [exec sh -c "$::atos_ocr::panneau(atos,$visuNo,exec_ocr_vti) [lindex $deint_ocr 0]"]
        } msg_even]
        # Extrait l'OCR de l'image impaire
        if {$::atos_ocr::panneau(atos,$visuNo,exec_convert_vti) != ""} {
          set err [catch {
             set result [exec sh -c "$::atos_ocr::panneau(atos,$visuNo,exec_convert_vti) [lindex $deint_ocr 1] [lindex $deint_ocr 1]"]
          } msg]
        }
        set err [catch {
           set result [exec sh -c "$::atos_ocr::panneau(atos,$visuNo,exec_ocr_vti) [lindex $deint_ocr 1]"]
        } msg_odd]
        set msg "\n$msg_even\n$msg_odd"
      }

      default {
        set err [catch {
           set result [exec sh -c "$::atos_ocr::panneau(atos,$visuNo,exec_ocr_default) ocr.jpg"]
        } msg]
      }

   }

   if {$err == 1} {

     ::console::affiche_erreur "Failed to extract OCR: $msg \n"
     $datetime.h.val   delete 0 end
     $datetime.h.val   insert 0 "?"
     $datetime.min.val delete 0 end
     $datetime.min.val insert 0 "?"
     $datetime.s.val   delete 0 end
     $datetime.s.val   insert 0 "?"
     $datetime.ms.val  delete 0 end
     $datetime.ms.val  insert 0 "?"
     $setunset.t.ocr   configure -bg $color(red) -fg $color(white)
     return 0

   }

   switch $box {
      "SHARPCAP" {
        set ocr [::atos_ocr_tools::ocr_sharpcap $msg]
      }
      "KIWI-OSD" {
        set ocr [::atos_ocr_tools::ocr_kiwi $msg]
      }
      "TIM-10" {
        set ocr [::atos_ocr_tools::ocr_tim10 $msg]
      }
      "IOTA-VTI" {
        set ocr [::atos_ocr_tools::ocr_iota_vti $msg_even $msg_odd]
      }
      default {
        set ocr [list "no" [list "XXXX" "XX" "XX"] [list "XX" "XX" "XX" "XXX"]]
      }
   }

   set pass [lindex $ocr 0]

   set date [lindex $ocr 1]
   set yy [$datetime.y.val get]
   if {[lindex $date 0] != "XXXX"} { set yy [return_4digit [lindex $date 0]] }
   set mm [$datetime.m.val get]
   if {[lindex $date 1] != "XX"}   { set mm [return_2digit [lindex $date 1]] }
   set dd [$datetime.d.val get]
   if {[lindex $date 2] != "XX"}   { set dd [return_2digit [lindex $date 2]] }

   set hms [lindex $ocr 2]
   set h   [return_2digit [lindex $hms 0]]
   set min [return_2digit [lindex $hms 1]]
   set s   [return_2digit [lindex $hms 2]]
   set ms  [return_3digit [lindex $hms 3]]

   if { $pass == "ok" } {

      set err [ catch {

         regexp {[0-9][0-9]} $h matched
         if { $h != $matched } {set pass "no"}
         regexp {[0-9][0-9]} $min matched
         if { $min != $matched } {set pass "no"}
         regexp {[0-9][0-9]} $s matched
         if { $s != $matched } {set pass "no"}
         regexp {[0-9][0-9][0-9]} $ms matched
         if { $ms != $matched } {set pass "no"}

      } msg ]

      if { $err != 0 } {set pass "no"}

   }

   # affichage des resultats
   if { $pass == "ok" } {

      $datetime.y.val   delete 0 end
      $datetime.y.val   insert 0 $yy
      $datetime.m.val   delete 0 end
      $datetime.m.val   insert 0 $mm
      $datetime.d.val   delete 0 end
      $datetime.d.val   insert 0 $dd

      $datetime.h.val   delete 0 end
      $datetime.h.val   insert 0 $h
      $datetime.min.val delete 0 end
      $datetime.min.val insert 0 $min
      $datetime.s.val   delete 0 end
      $datetime.s.val   insert 0 $s
      $datetime.ms.val  delete 0 end
      $datetime.ms.val  insert 0 $ms
      $setunset.t.ocr   configure -bg "#00891b" -fg $color(white)
      return 1

   } else {

      ::console::affiche_erreur "OCR failed: idframe=$::atos_tools::cur_idframe : $yy-$mm-$dd $h:$min:$s.$ms\n"

      $datetime.y.val   delete 0 end
      $datetime.y.val   insert 0 $yy
      $datetime.m.val   delete 0 end
      $datetime.m.val   insert 0 $mm
      $datetime.d.val   delete 0 end
      $datetime.d.val   insert 0 $dd

      $datetime.h.val   delete 0 end
      $datetime.h.val   insert 0 $h
      $datetime.min.val delete 0 end
      $datetime.min.val insert 0 $min
      $datetime.s.val   delete 0 end
      $datetime.s.val   insert 0 $s
      $datetime.ms.val  delete 0 end
      $datetime.ms.val  insert 0 $ms
      $setunset.t.ocr   configure -bg $color(red) -fg $color(white)
      return 0

   }

}



proc ::atos_ocr_tools::getinfofrm { visuNo } {

   global color

   if {![info exists ::atos_tools::nb_frames] || $::atos_tools::nb_frames == 0} {
      # Rien a faire car pas de video chargee
      ::console::affiche_erreur "Error: ::atos_ocr_tools::getinfofrm: unknown number of frames\n"
      return
   }

   set idframe $::atos_tools::cur_idframe

   set frm $::atos_gui::frame(base)
   set datetime $::atos_gui::frame(datetime)
   set setunset $::atos_gui::frame(setunset)

   #::console::affiche_resultat "$idframe - "
   #::console::affiche_resultat "$::atos_ocr_tools::timing($idframe,verif) . "
   #::console::affiche_resultat "$::atos_ocr_tools::timing($idframe,ocr) . "
   #::console::affiche_resultat "$::atos_ocr_tools::timing($idframe,interpol) \n"

   $frm.infofrm.v.nbimage configure -text $::atos_tools::nb_frames
   $frm.infofrm.v.nbverif configure -text $::atos_ocr_tools::nbverif

   set p [format %2.1f [expr $::atos_ocr_tools::nbocr/($::atos_tools::nb_frames*1.0)*100.0]]
   $frm.infofrm.v.nbocr configure -text "$::atos_ocr_tools::nbocr ($p %)"

   set p [format %2.1f [expr $::atos_ocr_tools::nbinterp/($::atos_tools::nb_frames*1.0)*100.0]]
   $frm.infofrm.v.nbinterp configure -text "$::atos_ocr_tools::nbinterp ($p %)"

   if {$::atos_ocr_tools::timing($::atos_tools::cur_idframe,verif) == 1} {
      $setunset.t.verif configure -bg "#00891b" -fg $color(white)
      $setunset.t.verif configure -relief sunken
   } else {
      $setunset.t.verif configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
      $setunset.t.verif configure -relief raised
   }
   if {$::atos_ocr_tools::timing($::atos_tools::cur_idframe,interpol) == 1} {
      $setunset.t.interpol configure -bg "#00891b" -fg $color(white)
      $setunset.t.interpol configure -relief sunken
   } else {
      $setunset.t.interpol configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
      $setunset.t.interpol configure -relief raised
   }

   if {$::atos_ocr_tools::timing($::atos_tools::cur_idframe,verif) == 1 || $::atos_ocr_tools::timing($::atos_tools::cur_idframe,interpol) == 1} {

      set poslist [split $::atos_ocr_tools::timing($::atos_tools::cur_idframe,dateiso) "T"]
      #::console::affiche_resultat "   poslist = $poslist \n"
      set ymd [lindex $poslist 0]
      set hms [lindex $poslist 1]
      set poslist [split $ymd "-"]
      #::console::affiche_resultat "   poslist ymd = $poslist \n"
      set y [lindex $poslist 0]
      set m [lindex $poslist 1]
      set d [lindex $poslist 2]
      set poslist [split $hms ":"]
      #::console::affiche_resultat "   poslist hms = $poslist \n"
      set h [lindex $poslist 0]
      set min [lindex $poslist 1]
      set sms [lindex $poslist 2]
      set poslist [split $sms "."]
      #::console::affiche_resultat "   poslist hms = $poslist \n"
      set s   [return_2digit [lindex $poslist 0]]
      set ms  [lindex $poslist 1]
      #::console::affiche_resultat "$y-$m-${d}T$h:$min:$s.$ms\n"
      $datetime.y.val   delete 0 end
      $datetime.y.val   insert 0 $y
      $datetime.m.val delete 0 end
      $datetime.m.val insert 0 $m
      $datetime.d.val   delete 0 end
      $datetime.d.val   insert 0 $d
      $datetime.h.val   delete 0 end
      $datetime.h.val   insert 0 $h
      $datetime.min.val delete 0 end
      $datetime.min.val insert 0 $min
      $datetime.s.val   delete 0 end
      $datetime.s.val   insert 0 $s
      $datetime.ms.val  delete 0 end
      $datetime.ms.val  insert 0 $ms

   }

}



proc ::atos_ocr_tools::verif_2numdigit { x } {

   set res [ regexp {[0-9]{1,2}} $x matched ]
   if { ! $res } { return 1 }
   if { $x != $matched } {return 1}
   return 0

}



proc ::atos_ocr_tools::verif_yeardigit { x } {

   set res [ regexp {[1-2][0-9]{3}} $x matched ]
   if { ! $res } { return 1 }
   if { $x!=$matched } {return 1}
   return 0

}



proc ::atos_ocr_tools::verif_hourdigit { x } {

   set res [ regexp {[0-9]{1,2}} $x matched ]
   if { ! $res } { return 1 }
   if { $x!=$matched } {return 1}
   if { $x<0 || $x>24 || $x=="" } {return 1}
   return 0

}



proc ::atos_ocr_tools::verif_msdigit { x } {

   set res [ regexp {[0-9]{1,3}} $x matched ]
   if { ! $res } { return 1 }
   if { $x != $matched } {return 1}
   return 0

}



proc ::atos_ocr_tools::return_2digit { x } {

   set res [ regexp {[0-9]{2}} $x matched ]
   if { $res } {
      return $x
   } else {
      if { $x==0 } {
         return "00"
      }
      if { $x<10 } {
         return "0$x"
      }
      return "XX"
   }

}



proc ::atos_ocr_tools::return_3digit { x } {

   set res [ regexp {[0-9]{3}} $x matched ]
   if { $res } {
      return $x
   } else {
      if { $x==0 } {
         return "000"
      }
      if { $x<10 } {
         return "00$x"
      }
      if { $x<100 } {
         return "0$x"
      }
      return "XXX"
   }

}



proc ::atos_ocr_tools::return_4digit { x } {

   set res [ regexp {[0-9]{4}} $x matched ]
   if { $res } {
      return $x
   } else {
      if { $x == 0 } {
         return "0000"
      }
      if { $x < 10 } {
         return "000$x"
      }
      if { $x < 100 } {
         return "00$x"
      }
      if { $x < 1000 } {
         return "0$x"
      }
      return "XXXX"
   }

}



proc ::atos_ocr_tools::verif { visuNo } {

   global color

   set datetime $::atos_gui::frame(datetime)
   set setunset $::atos_gui::frame(setunset)

   set statebutton [$setunset.t.verif cget -relief]

   # desactivation
   if {$statebutton == "sunken"} {
      $setunset.t.verif configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
      $setunset.t.verif configure -relief raised
      incr ::atos_ocr_tools::nbverif -1
      set ::atos_ocr_tools::timing($::atos_tools::cur_idframe,verif) 0
      ::atos_ocr_tools::workimage $visuNo
      ::atos_ocr_tools::getinfofrm $visuNo
      return
   }

   set y   [$datetime.y.val get]
   set m   [$datetime.m.val get]
   set d   [$datetime.d.val get]
   set h   [$datetime.h.val get]
   set min [$datetime.min.val get]
   set s   [$datetime.s.val get]
   set ms  [$datetime.ms.val get]


   if { [verif_yeardigit $y] } {
       tk_messageBox -message "Veuillez entrer une année valide\n ex : 2012" -type ok
       return
   }
   if { [verif_2numdigit $m] } {
       tk_messageBox -message "Veuillez entrer un mois valide\n ex : 12" -type ok
       return
   }
   if { [verif_2numdigit $d] } {
       tk_messageBox -message "Veuillez entrer un jour valide\n ex : 12" -type ok
       return
   }
   if { [verif_hourdigit $h] } {
       tk_messageBox -message "Veuillez entrer une heure valide\n ex : 12" -type ok
       return
   }
   if { [verif_2numdigit $min] } {
       tk_messageBox -message "Veuillez entrer une minute valide\n ex : 12" -type ok
       return
   }
   if { [verif_2numdigit $s] } {
       tk_messageBox -message "Veuillez entrer une seconde valide\n ex : 12" -type ok
       return
   }
   if { [verif_msdigit $ms] } {
       tk_messageBox -message "Veuillez entrer une milli-seconde valide\n ex : 012" -type ok
       return
   }
   set m   [return_2digit $m]
   set d   [return_2digit $d]
   set h   [return_2digit $h]
   set min [return_2digit $min]
   set s   [return_2digit $s]
   set ms  [return_3digit $ms]

   ::console::affiche_resultat "Date verifiee: frame: $::atos_tools::cur_idframe ; date: $y-$m-${d}T$h:$min:$s.$ms\n"

   $datetime.y.val   delete 0 end
   $datetime.y.val   insert 0 $y
   $datetime.m.val   delete 0 end
   $datetime.m.val   insert 0 $m
   $datetime.d.val   delete 0 end
   $datetime.d.val   insert 0 $d
   $datetime.h.val   delete 0 end
   $datetime.h.val   insert 0 $h
   $datetime.min.val delete 0 end
   $datetime.min.val insert 0 $min
   $datetime.s.val   delete 0 end
   $datetime.s.val   insert 0 $s
   $datetime.ms.val  delete 0 end
   $datetime.ms.val  insert 0 $ms
   $setunset.t.verif configure -bg "#00891b" -fg $color(white)
   $setunset.t.verif configure -relief sunken

   incr ::atos_ocr_tools::nbverif
   set ::atos_ocr_tools::timing($::atos_tools::cur_idframe,verif) 1
   set ::atos_ocr_tools::timing($::atos_tools::cur_idframe,dateiso) "$y-$m-${d}T$h:$min:$s.$ms"
   #tk_messageBox -message "$caption(bddimages_status,consoleErr3) $msg" -type ok
   ::atos_ocr_tools::getinfofrm $visuNo

}



proc ::atos_ocr_tools::stop { visuNo } {


   ::console::affiche_resultat "-- stop \n"

   set frm_start $::atos_gui::frame(buttons,start)

   if {$::atos_ocr_tools::sortie == 1} {
      $frm_start configure -image .start
      $frm_start configure -relief raised
      $frm_start configure -command "::atos_ocr_tools::start $visuNo"
   }

   set ::atos_ocr_tools::sortie 1

}



proc ::atos_ocr_tools::select { visuNo } {

   ::atos_tools::select $visuNo
   ::atos_ocr_tools::open_flux $visuNo

}



proc ::atos_ocr_tools::open_flux { visuNo } {
   
   set datetime $::atos_gui::frame(datetime)

   # vidage memoire
   array unset timing
   $datetime.y.val   delete 0 end
   $datetime.m.val   delete 0 end
   $datetime.d.val   delete 0 end
   $datetime.h.val   delete 0 end
   $datetime.min.val delete 0 end
   $datetime.s.val   delete 0 end
   $datetime.ms.val  delete 0 end

   # Vidage Boutons
   set setunset $::atos_gui::frame(setunset)
   $setunset.t.verif configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
   $setunset.t.verif configure -relief raised
   $setunset.t.interpol configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
   $setunset.t.interpol configure -relief raised
   $setunset.t.ocr configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
   $setunset.t.ocr configure -state disabled
   set ocr $::atos_gui::frame(ocr_setup)
   $ocr.ocr.selectdate.box configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
   $ocr.ocr.selectdate.box configure -state disabled

   # Vidage info
   $::atos_gui::frame(inparam).nbimage  configure -text "-"
   $::atos_gui::frame(inparam).nbverif  configure -text "-"
   $::atos_gui::frame(inparam).nbocr    configure -text "-"
   $::atos_gui::frame(inparam).nbinterp configure -text "-"


   # Ouverture du Flux
   ::atos_tools::open_flux $visuNo
   catch {
      array unset ::atos_ocr_tools::timing
      for  {set x 1} {$x<=$::atos_tools::nb_open_frames} {incr x} {
         set ::atos_ocr_tools::timing($x,verif) 0
         set ::atos_ocr_tools::timing($x,ocr) 0
         set ::atos_ocr_tools::timing($x,interpol) 0
         set ::atos_ocr_tools::timing($x,jd)  ""
         set ::atos_ocr_tools::timing($x,diff)  ""
         set ::atos_ocr_tools::timing($x,dateiso) ""
      }
   }

}



proc ::atos_ocr_tools::start_next_image { visuNo } {

   if {$::atos_ocr_tools::active_ocr == "1" && [ $::atos_gui::frame(ocr_setup).ocr.selectdate.box cget -relief] == "sunken"} {
      ::atos_tools::next_image $visuNo
   } else {
      incr ::atos_tools::cur_idframe
   }

}



proc ::atos_ocr_tools::start { visuNo } {

   if {![info exists ::atos_tools::cur_idframe]} {
      # Rien a faire car pas de video chargee
      ::console::affiche_erreur "::atos_ocr_tools::start -> no image\n"
      return
   }

   ::console::affiche_resultat "Extraction des dates ...\n"

   # Premiere frame a analyser
   set fmin [$::atos_gui::frame(posmin) get]
   if {$fmin == ""} {
      set ::atos_tools::frame_min 1
   } else {
      set ::atos_tools::frame_min $fmin
   }
   $::atos_gui::frame(posmin) delete 0 10
   $::atos_gui::frame(posmin) insert 0 $fmin

   # Derniere frame a analyser
   set fmax [$::atos_gui::frame(posmax) get]
   if {$fmax == ""} {
      set ::atos_tools::frame_max $::atos_tools::frame_end
   } else {
      set ::atos_tools::frame_max $fmax
   }
   $::atos_gui::frame(posmax) delete 0 10
   $::atos_gui::frame(posmax) insert 0 $fmax

   ::console::affiche_resultat "  ... extraction entre les frames $::atos_tools::frame_min et $::atos_tools::frame_max ($::atos_tools::nb_frames frames)\n"

   # La date de la premiere frame analyser doit etre verifiee
   if { $::atos_ocr_tools::timing($::atos_tools::cur_idframe,verif) != 1 } {
       tk_messageBox -message "Veuillez commencer par une image VERIFIEE" -type ok
       return
   }

   # Start chrono
   set tt0 [clock clicks -milliseconds]

   # Scan toutes les frames a la recherche des dates verifiees
   ::console::affiche_resultat "* Recherche des dates verifiees ...\n"
   set cpt 0
   set first_verif -1
   set last_verif -1
   for {set idframe $::atos_tools::frame_min} {$idframe <= $::atos_tools::frame_max} {incr idframe } {

      if {$::atos_ocr_tools::timing($idframe,verif) == 1} {
         if {$first_verif == -1} { set first_verif $idframe }
         set last_verif $idframe
         set ::atos_ocr_tools::timing($idframe,jd) [mc_date2jd $::atos_ocr_tools::timing($idframe,dateiso)]
         set ::atos_ocr_tools::timing($idframe,interpol) 0
         ::console::affiche_resultat "  frame $idframe verifiee -> $::atos_ocr_tools::timing($idframe,dateiso)\n"
         incr cpt
      }
   }

   # Au moins une deuxieme date doit etre verifiee
   if {$cpt < 2} {
      tk_messageBox -message "Vous devez VERIFIER au moins deux dates dans le cas eventuel d'une interpolation. Idealement au debut et a la fin." -type ok
      return
   }

   # calcul du framerate
   set jd1 $::atos_ocr_tools::timing($::atos_tools::frame_min,jd)
   set jd2 $::atos_ocr_tools::timing($::atos_tools::frame_max,jd)
   
   ::console::affiche_erreur "frame_min = $::atos_tools::frame_min\n"
   ::console::affiche_erreur "::atos_ocr_tools::timing($::atos_tools::frame_min,jd) = $::atos_ocr_tools::timing(2,jd)\n"
   ::console::affiche_erreur "jd1 = $jd1\n"
   ::console::affiche_erreur "jd2 = $jd2\n"
   
   set djd [expr ($jd2 - $jd1)*86400.0]
   set fps [format "%.3f" [expr ($::atos_tools::frame_max - $::atos_tools::frame_min) / $djd]]

   ::console::affiche_erreur "Frame rate = $fps\n"


   # Mise a jour de la gui
   set action $::atos_gui::frame(action)
   $action.start configure -image .stop
   $action.start configure -relief sunken
   $action.start configure -command "::atos_ocr_tools::stop $visuNo"

   # Initialisations
   set ::atos_ocr_tools::sortie 0
   set ::atos_ocr_tools::nbocr 0
   set ::atos_ocr_tools::nbinterp 0

   # Demarre extraction des dates par interpolation ou OCR
   if {$::atos_ocr_tools::active_ocr == 0} {

      set idframefin [::atos_ocr_tools::start_interpole $first_verif $last_verif]

   } else {

      set idframefin [::atos_ocr_tools::start_ocr $visuNo]

   }

   $action.start configure -image .start
   $action.start configure -relief raised
   $action.start configure -command "::atos_ocr_tools::start $visuNo"

   ::atos_tools::set_frame $visuNo $idframefin

   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   ::console::affiche_resultat "=> Extraction des dates en $tt secondes\n"
   ::console::affiche_resultat "Fin\n"

   tk_messageBox -message "Extraction des dates terminée en $tt secondes" -type ok
   update

}



proc ::atos_ocr_tools::start_interpole { veriframe1 veriframe2 } {

   ::console::affiche_resultat "* Interpolation des dates ...\n"

   # Calcul des coef. de la droite de regression
   set a [expr ($::atos_ocr_tools::timing($veriframe2,jd) - $::atos_ocr_tools::timing($veriframe1,jd)) / ($veriframe2 - $veriframe1)]
   set b [expr $::atos_ocr_tools::timing($veriframe1,jd) - $a * $veriframe1]

   # Calcul de la date pour chaque frame non verifiee
   for {set idframe 1} {$idframe <= $::atos_tools::frame_end} {incr idframe } {
      if {$::atos_ocr_tools::timing($idframe,verif) != 1} {
         set jd [expr $a * $idframe + $b]
         set ::atos_ocr_tools::timing($idframe,jd) $jd
         set ::atos_ocr_tools::timing($idframe,dateiso) [mc_date2iso8601 $jd]
         set ::atos_ocr_tools::timing($idframe,interpol) 1
         incr ::atos_ocr_tools::nbinterp
      }
   }
   
   # Retourne l'id de la derniere frame interpolee
   return 1

}



proc ::atos_ocr_tools::start_ocr { visuNo } {

   # Start chrono
   set tt0 [clock clicks -milliseconds]
   # Defini les champs de date
   set datetime $::atos_gui::frame(datetime)

# Analyse des OCR
   ::console::affiche_resultat "* Analyse des OCR ...\n"

   # Premiere passe: analyse des OCR
   while {$::atos_ocr_tools::sortie == 0} {

      ::atos_ocr_tools::getinfofrm $visuNo
      set idframe $::atos_tools::cur_idframe
      set ::atos_tools::scrollbar $idframe
      update

      #::console::affiche_resultat "$idframe : \[$idframe / $::atos_tools::nb_frames / [expr $::atos_tools::frame_end-$idframe] \]\n"

      if {$idframe == $::atos_tools::frame_end} {
         set ::atos_ocr_tools::sortie 1
      }

      # Si la frame n'est pas verifiee alors extraction OCR
      if {$::atos_ocr_tools::timing($idframe,verif) == 0} {

         set pass "no"

         # OCR
         set res [::atos_ocr_tools::workimage $visuNo]
         if {$res == 1} {
            set pass "ok"

            set y   [$datetime.y.val get]
            set m   [$datetime.m.val get]
            set d   [$datetime.d.val get]
            set h   [$datetime.h.val get]
            set min [$datetime.min.val get]
            set s   [$datetime.s.val get]
            set ms  [$datetime.ms.val get]

            if { [verif_yeardigit $y]   } { set pass "no" }
            if { [verif_2numdigit $m]   } { set pass "no" }
            if { [verif_2numdigit $d]   } { set pass "no" }
            if { [verif_hourdigit $h]   } { set pass "no" }
            if { [verif_2numdigit $min] } { set pass "no" }
            if { [verif_2numdigit $s]   } { set pass "no" }
            if { [verif_msdigit $ms]    } { set pass "no" }

            if {$pass == "ok"} {
               set m   [return_2digit $m]
               set d   [return_2digit $d]
               set h   [return_2digit $h]
               set min [return_2digit $min]
               set s   [return_2digit $s]
               set ms  [return_3digit $ms]

               incr ::atos_ocr_tools::nbocr
               set ::atos_ocr_tools::timing($idframe,dateiso) "$y-$m-${d}T$h:$min:$s.$ms"
               set ::atos_ocr_tools::timing($idframe,jd) [mc_date2jd $::atos_ocr_tools::timing($idframe,dateiso)]
               set ::atos_ocr_tools::timing($idframe,ocr) 1
               set ::atos_ocr_tools::timing($idframe,interpol) 0
               #::console::affiche_resultat "\[$idframe / $::atos_tools::nb_frames / [expr $::atos_tools::nb_frames-$idframe] \] O\n"
            }
         }

         # interpolation
         if {$pass == "no"} {
            set ::atos_ocr_tools::timing($idframe,ocr) 0
            set ::atos_ocr_tools::timing($idframe,interpol) 1
            incr ::atos_ocr_tools::nbinterp
            #::console::affiche_resultat "\[$idframe / $::atos_tools::nb_frames / [expr $::atos_tools::nb_frames-$idframe] \] I\n"
         }

      }

      ::atos_ocr_tools::start_next_image $visuNo

   }

   set tt1 [clock clicks -milliseconds]
   set tt [format "%.3f" [expr ($tt1 - $tt0)/1000.]]
   ::console::affiche_resultat "  ... analyse en $tt secondes\n"

   # Defini la derniere frame analysee
   set idframefin $idframe

# Verification des OCR

   # Deuxieme passe: verification des OCR
   if {$::atos_ocr_tools::nbocr > 0} {

      ::console::affiche_resultat "* Verification des OCR\n"

      set cpt 0
      set cptbad 0
      set cptverif 0
      set cptinterpole 0
      set ::atos_ocr_tools::sortie 0
      # On commence a la premiere frame analysee
      set idframe $::atos_tools::frame_min

      while {$::atos_ocr_tools::sortie == 0} {

         set ::atos_tools::scrollbar $idframe
         update

         if {$idframe == $idframefin} {
            set ::atos_ocr_tools::sortie 1
         }

         if {$::atos_ocr_tools::timing($idframe,ocr) == 1 && $::atos_ocr_tools::timing($idframe,verif) == 0} {

            # OK on interpole ! pour verifier la difference avec l ocr

            set idfrmap [ ::atos_ocr_tools::get_idfrmap $idframe 2]
            set idfrmav [ ::atos_ocr_tools::get_idfrmav $idframe 2]

            if { $idfrmav == -1 || $idfrmap == -1 } {
               set idfrmav [::atos_ocr_tools::get_idfrmap $::atos_tools::cur_idframe 1]
               set idfrmap [::atos_ocr_tools::get_idfrmav $::atos_tools::frame_max 1]
            }

            if { $idfrmav == -1 || $idfrmap == -1 } {
               gren_erreur "Erreur verif OCR : $idfrmav $idfrmap \n"
               gren_erreur "id current : $idframe \n"
               gren_erreur "idfrmap 1 : [ ::atos_ocr_tools::get_idfrmap $idframe 1] \n"
            }
            set jdav $::atos_ocr_tools::timing($idfrmav,jd)
            set jdap $::atos_ocr_tools::timing($idfrmap,jd)
           
            #gren_erreur "$idframe : $::atos_ocr_tools::timing($idframe,dateiso) \n"
            #gren_erreur "$idframe jdav jdap : ($jdav) ($jdap) $idfrmav $idfrmap \n"

            set jd [expr $jdav+($jdap-$jdav)/($idfrmap-$idfrmav)*($idframe-$idfrmav)]
            set jd [format "%6.10f" $jd]

            set diff [expr abs(($::atos_ocr_tools::timing($idframe,jd) - $jd ) * 86400.0)]
            if { $diff > 0.5 } {
               ::console::affiche_erreur "Warning! frame: $idframe ; date: $::atos_ocr_tools::timing($idframe,dateiso)\n"
               set ::atos_ocr_tools::timing($idframe,ocr) 0
               set ::atos_ocr_tools::timing($idframe,interpol) 1
               incr cptbad
            } 
            incr cpt

         } elseif {$::atos_ocr_tools::timing($idframe,ocr) == 0 && $::atos_ocr_tools::timing($idframe,verif) == 0} {

            incr cptinterpole

         } elseif {$::atos_ocr_tools::timing($idframe,verif) == 1} {
            
            incr cptverif

         }
         incr idframe

      }
      ::console::affiche_resultat "  ... total verif =  $cptverif ; ocr = $cpt ; a interpoler = $cptinterpole ; warning = $cptbad \n"

      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt1)/1000.]]
      set tt1 [clock clicks -milliseconds]
      ::console::affiche_resultat "  ... verification en $tt secondes\n"

   }

# interpolation des dates

   # Troisieme passe: interpolation des dates sans OCR
   if {$::atos_ocr_tools::nbinterp > 0} {

      ::console::affiche_resultat "* Interpolation des dates sans OCR ...\n"

      set ::atos_ocr_tools::sortie 0
      # On commence a la premiere frame analysee
      set idframe $::atos_tools::frame_min
      
      while {$::atos_ocr_tools::sortie == 0} {

         set ::atos_tools::scrollbar $idframe
         update

         if {$idframe == $idframefin} {
            set ::atos_ocr_tools::sortie 1
         }

         if {$::atos_ocr_tools::timing($idframe,interpol) == 1 && $::atos_ocr_tools::timing($idframe,verif) == 0} {
            set idfrmav [::atos_ocr_tools::get_idfrmav $idframe 2]
            set idfrmap [::atos_ocr_tools::get_idfrmap $idframe 2]
            #::console::affiche_resultat "$idfrmav < $idfrmap"
            if { $idfrmav == -1 } {
               # il faut interpoler par 2 a droite
               #::console::affiche_resultat "il faut interpoler par 2 a droite : "
               set idfrmav $idfrmap
               set idfrmap [::atos_ocr_tools::get_idfrmap $idfrmap 2]
            }
            if { $idfrmap == -1 } {
               # il faut interpoler par 2 a gauche
               #::console::affiche_resultat "il faut interpoler par 2 a gauche : "
               set idfrmap $idfrmav
               set idfrmav [::atos_ocr_tools::get_idfrmav $idfrmav 2]
            }
            if { $idfrmav == -1 || $idfrmap == -1 } {
               set idfrmav [::atos_ocr_tools::get_idfrmap 0 1]
               set idfrmap [::atos_ocr_tools::get_idfrmav [expr $::atos_tools::nb_frames + 1] 1]
            }

            #::console::affiche_resultat "interpol par $idfrmav << $idfrmap : "
            #::console::affiche_resultat "I : $idframe ($idfrmav<$idfrmap)  "
            set jdav $::atos_ocr_tools::timing($idfrmav,jd)
            set jdap $::atos_ocr_tools::timing($idfrmap,jd)
            set jd [expr $jdav+($jdap-$jdav)/($idfrmap-$idfrmav)*($idframe-$idfrmav)]
            set jd [ format "%6.10f" $jd]
            #::console::affiche_resultat "JD=$jd"
            set dateiso [mc_date2iso8601 $jd]
            set ::atos_ocr_tools::timing($idframe,jd) $jd
            set ::atos_ocr_tools::timing($idframe,dateiso) $dateiso
            #::console::affiche_resultat "date = $::atos_ocr_tools::timing($idframe,dateiso)\n"
         }

         incr idframe

      }

      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt1)/1000.]]
      set tt1 [clock clicks -milliseconds]
      ::console::affiche_resultat "  ... interpolation en $tt secondes\n"

   }

   # Retourne l'id de la derniere frame interpolee
   return $idframefin

}



proc ::atos_ocr_tools::graph { visuNo } {

   if {![info exists ::atos_tools::frame_end]} {
      # Rien a faire car pas de video chargee
      return
   }

   set log 0
   ::plotxy::clf 1
   ::plotxy::figure 1 
   ::plotxy::hold on 
   ::plotxy::position {0 0 600 400}
   ::plotxy::title "Courbe du temps" 
   ::plotxy::xlabel "Time (jd)" 
   ::plotxy::ylabel "id frame" 
   set x ""
   set y ""
   set x_verif    ""
   set x_ocr      ""
   set x_interpol ""
   set y_verif    ""
   set y_ocr      ""
   set y_interpol ""

   set origine 9999999
   for {set idframe 1} {$idframe <= $::atos_tools::frame_end} {incr idframe } {
      catch {  
         set jd $::atos_ocr_tools::timing($idframe,jd)              
         if {$jd != "" && $jd < $origine} {set origine $jd}      
      }
   }
   if {$log} { ::console::affiche_resultat "Origine temporelle : $origine\n"}
   set origine [expr int($origine)]
   ::console::affiche_resultat "Origine temporelle : $origine\n"
   
   for {set idframe 1} {$idframe <= $::atos_tools::frame_end} {incr idframe } {
       
      if {$::atos_ocr_tools::timing($idframe,jd) == ""} { continue}

      if {$log} {         
         catch {  ::console::affiche_erreur "idframe = $idframe "    }
         catch {  ::console::affiche_erreur "dateiso = $::atos_ocr_tools::timing($idframe,dateiso) "    }
         catch {  ::console::affiche_erreur "jd = $::atos_ocr_tools::timing($idframe,jd) "              }
         catch {  ::console::affiche_erreur "verif = $::atos_ocr_tools::timing($idframe,verif) "        }
         catch {  ::console::affiche_erreur "ocr = $::atos_ocr_tools::timing($idframe,ocr) "            }
         catch {  ::console::affiche_erreur "interpol = $::atos_ocr_tools::timing($idframe,interpol) "  }
         catch {  ::console::affiche_erreur "diff = $::atos_ocr_tools::timing($idframe,diff)\n"         }
      }
      catch { 
         set t [expr $::atos_ocr_tools::timing($idframe,jd) - $origine]
         lappend x $t
         lappend y $idframe
         if {$::atos_ocr_tools::timing($idframe,verif) == 1} { 
            if {$log} { ::console::affiche_erreur "yep $t $idframe\n"}
            lappend x_verif    $t
            lappend y_verif    $idframe 
         }
         if {$::atos_ocr_tools::timing($idframe,ocr) == 1} {
            lappend x_ocr      $t
            lappend y_ocr      $idframe
            }
         if {$::atos_ocr_tools::timing($idframe,interpol) == 1} {
            lappend x_interpol $t
            lappend y_interpol $idframe
         }
      }
      #break
   }

   set h4 [::plotxy::plot $x_interpol $y_interpol ro. 2 ]
   plotxy::sethandler $h4 [list -color white -linewidth 0]
   set h3 [::plotxy::plot $x_ocr $y_ocr ro. 5  ]
   plotxy::sethandler $h3 [list -color orange -linewidth 0]
   set h2 [::plotxy::plot $x_verif $y_verif ro. 7 ]
   plotxy::sethandler $h2 [list -color green -linewidth 0]
   set h1 [::plotxy::plot $x $y ro. 10 ]
   plotxy::sethandler $h1 [list -color black -linewidth 1]

}



proc ::atos_ocr_tools::get_idfrmav { idframe gtype } {

   set stop 0
   set id $idframe
   while {$stop == 0} {
      incr id -1
      if {$id == 0} { return -1 }
      if { $gtype == 1 } {
         if {$::atos_ocr_tools::timing($id,verif) == 1} {
            return $id
         }
      }
      if { $gtype == 2 } {
         if {$::atos_ocr_tools::timing($id,verif) == 1 || $::atos_ocr_tools::timing($id,ocr) == 1 } {
            return $id
         }
      }
   }
   return -1

}



proc ::atos_ocr_tools::get_idfrmap { idframe gtype } {

   set stop 0
   set id $idframe
   while {$stop == 0} {
      incr id
      if {$id > $::atos_tools::frame_max} { break }
      if { $gtype == 1 } {
         if {$::atos_ocr_tools::timing($id,verif) == 1} {
            return $id
         }
      }
      if { $gtype == 2 } {
         if {$::atos_ocr_tools::timing($id,verif) == 1 || $::atos_ocr_tools::timing($id,ocr) == 1 } {
            return $id
         }
      }
   }
   return -1

}



proc ::atos_ocr_tools::get_filename_time { } {

   if { $::atos_tools::traitement=="fits" } {
      set filename [file join ${::atos_tools::destdir} "${::atos_tools::prefix}"]
   }

   if { $::atos_tools::traitement=="avi" }  {
      set filename $::atos_tools::avi_filename
      if { ! [file exists $filename] } {
      ::console::affiche_erreur "Fichier AVI introuvable!\n"
      }
   }

   return "${filename}.time"

}



proc ::atos_ocr_tools::save { visuNo } {

   if {![info exists ::atos_tools::nb_open_frames] || $::atos_tools::nb_open_frames == 0} {
      # Rien a faire car pas de video chargee
      return
   }

   set filename [::atos_ocr_tools::get_filename_time]

   ::console::affiche_resultat "Saving timings from frame $::atos_tools::frame_begin to $::atos_tools::frame_end into ${filename}\n"

   set f1 [open $filename "w"]
   puts $f1 "# ** atos - Audela - Linux  * "
   puts $f1 "# FPS = 25"
   set line "idframe, jd, dateiso, verif, ocr, interpol"
   puts $f1 $line

   set cptframe 1
   set idframe $::atos_tools::frame_begin

   set sortie 0
   while {$sortie == 0} {

      if {$idframe == $::atos_tools::frame_end} {
         set sortie 1
      }

      if { ! [info exists ::atos_ocr_tools::timing($idframe,jd)] || $::atos_ocr_tools::timing($idframe,jd) == ""} {
         continue
      }

      set line "$idframe, "
      append line [format %6.10f $::atos_ocr_tools::timing($idframe,jd)] ", "
      append line "$::atos_ocr_tools::timing($idframe,dateiso), "
      append line "$::atos_ocr_tools::timing($idframe,verif), "
      append line "$::atos_ocr_tools::timing($idframe,ocr), "
      append line "$::atos_ocr_tools::timing($idframe,interpol)"
      puts $f1 $line

      incr cptframe
      incr idframe

   }

   close $f1
   ::console::affiche_resultat "nb frames sauvees = $cptframe\n"

}



#
# Passe a l image suivante
#
proc ::atos_ocr_tools::next_image { visuNo } {

   cleanmark
   ::atos_tools::next_image $visuNo
   ::atos_ocr_tools::workimage $visuNo
   ::atos_ocr_tools::getinfofrm $visuNo

}



#
# Passe a l image precedente
#
proc ::atos_ocr_tools::prev_image { visuNo } {

   ::atos_tools::prev_image $visuNo
   ::atos_ocr_tools::workimage $visuNo
   ::atos_ocr_tools::getinfofrm $visuNo

}



#
# Passe a l image suivante
#
proc ::atos_ocr_tools::quick_next_image { visuNo  } {

   ::atos_tools::quick_next_image $visuNo
   ::atos_ocr_tools::workimage $visuNo 
   ::atos_ocr_tools::getinfofrm $visuNo

}



#
# retour rapide
#
proc ::atos_ocr_tools::quick_prev_image { visuNo  } {

   ::atos_tools::quick_prev_image $visuNo
   ::atos_ocr_tools::workimage $visuNo 
   ::atos_ocr_tools::getinfofrm $visuNo 

}



#
#
#
proc ::atos_ocr_tools::move_scroll { visuNo  } {

   #gren_info "scroll on : $::atos_tools::scrollbar - [$::atos_gui::frame(scrollbar) get] - $::atos_tools::cur_idframe\n"
   ::atos_ocr_tools::workimage $visuNo 
   ::atos_ocr_tools::getinfofrm $visuNo 

}
