#
## @file aud_menu_5.tcl
#  @brief scripts regroupant des fonctionnalites du menu Analyse
#  $Id: aud_menu_5.tcl 14552 2019-01-09 16:36:44Z fredvachier $
#  @todo améliorer la doxygénation de psf_toolbox

namespace eval ::audace {
}

#
## @brief visualisation de l'histogramme de l'image affichée dans la visu
#  @param visuNo numéro de la visu
#
proc ::audace::Histo { visuNo } {
   global caption

   set bufNo [ visu$visuNo buf ]
   if { [ buf$bufNo imageready ] == "1" } {
      buf$bufNo imaseries "CUTS lofrac=0.01 hifrac=0.99 hicut=SH locut=SB keytype=FLOAT"
      set mini [ lindex [ buf$bufNo getkwd SB ] 1 ]
      set maxi [ lindex [ buf$bufNo getkwd SH ] 1 ]
      set r    [ buf$bufNo histo 50 $mini $maxi ]
      set figureNo [ ::plotxy::figure $visuNo ]
      ::plotxy::clf $figureNo
      ::plotxy::title  "$caption(audace,histo_titre) (visu$visuNo)"
      ::plotxy::xlabel "$caption(audace,histo_adu)"
      ::plotxy::ylabel "$caption(audace,histo_nbpix)"
      ::plotxy::plot   [ lindex $r 1 ] [ lindex $r 0 ]
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor .audace.plotxy1
   }
}

#
## @brief fournit les statistiques d'une fenêtre d'une image
#  @param visuNo numéro de la visu
#
proc ::audace::statwin { visuNo } {
   variable private
   global caption conf

   #---
   set base [ ::confVisu::getBase $visuNo ]

   #---
   set private(statwin,$visuNo,frm) "$base.statwin$visuNo"
   set frm $private(statwin,$visuNo,frm)
   if [ winfo exists $frm ] {
      ::audace::fermeFenetresAnalyse $visuNo $frm statwin
   }

   #--- Initialisation de variables
   if { ! [ info exists conf(statwin,$visuNo,position) ] }    { set conf(statwin,$visuNo,position)    "+350+75" }
   if { ! [ info exists conf(statwin,$visuNo,modeRefresh) ] } { set conf(statwin,$visuNo,modeRefresh) "0" }

   #--- Capture de la fenetre d'analyse
   set private(statwin,box) [ ::confVisu::getBox $visuNo ]
   if { $private(statwin,box) == "" } {
      return
   }

   #--- Creation de la fenetre
   toplevel $frm
   wm transient $frm $base
   wm resizable $frm 0 0
   wm title $frm "$caption(audace,menu,statwin)"
   wm geometry $frm $conf(statwin,$visuNo,position)
   wm protocol $frm WM_DELETE_WINDOW "::audace::fermeFenetresAnalyse $visuNo $frm statwin"

   #--- Creation d'une frame
   frame $frm.frame1 -borderwidth 2 -relief raised

      #--- Cree les etiquettes
      label $frm.frame1.lab0 -text "Visu$visuNo"
      pack $frm.frame1.lab0 -padx 10 -pady 2
      label $frm.frame1.lab1 -text ""
      pack $frm.frame1.lab1 -padx 10 -pady 2
      label $frm.frame1.lab2 -text ""
      pack $frm.frame1.lab2 -padx 10 -pady 2
      label $frm.frame1.lab3 -text ""
      pack $frm.frame1.lab3 -padx 10 -pady 2
      label $frm.frame1.lab4 -text ""
      pack $frm.frame1.lab4 -padx 10 -pady 2
      label $frm.frame1.lab5 -text ""
      pack $frm.frame1.lab5 -padx 10 -pady 2
      label $frm.frame1.lab6 -text ""
      pack $frm.frame1.lab6 -padx 10 -pady 2

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Creation d'une frame
   frame $frm.frame2 -borderwidth 2 -relief raised

      #--- Cree le checkbutton pour choisir le mode de rafraichissement
      checkbutton $frm.frame2.modeRefresh -text "$caption(audace,refreshAuto)" \
         -variable conf(statwin,$visuNo,modeRefresh) -command "::audace::confStatwin $visuNo"
      pack $frm.frame2.modeRefresh -anchor w -side top -padx 3 -pady 3

      #--- Cree le bouton pour rafraichir les statistiques
      button $frm.frame2.butRefresh -text "$caption(audace,refreshManuel)" \
         -command "::audace::refreshStatwin $visuNo"
      pack $frm.frame2.butRefresh -side top -padx 6 -pady 10 -ipadx 20 -ipady 6

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Rafraichit les valeurs
   ::audace::refreshStatwin $visuNo

   #--- Rafraichit la fenetre
   ::audace::confStatwin $visuNo

   #--- La fenetre est active
   focus $frm

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $frm <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
#  brief commande du checkbutton "Rafraîchir maintenant"
#  param visuNo numéro de la visu
#  param args arguments du listener
#
proc ::audace::refreshStatwin { visuNo args } {
   variable private
   global caption

   #--- Capture de la fenetre d'analyse
   set private(statwin,box) [ ::confVisu::getBox $visuNo ]
   if { $private(statwin,box) == "" } {
      return
   }

   #--- Lecture des parametres dans la fenetre
   set err [catch {set bufNo [::confVisu::getBufNo $visuNo ]} msg]
   if {$err} { set bufNo 1 }

   set private(statwin,valeurs) [ buf$bufNo stat $private(statwin,box) ]

   #--- Mise a jour des variables
   set private(statwin,maxi)                 "$caption(audace,maxi) [ lindex $private(statwin,valeurs) 2 ]"
   set private(statwin,mini)                 "$caption(audace,mini) [ lindex $private(statwin,valeurs) 3 ]"
   set private(statwin,moyenne)              "$caption(audace,moyenne) [ lindex $private(statwin,valeurs) 4 ]"
   set private(statwin,ecart_type)           "$caption(audace,ecart_type) [ lindex $private(statwin,valeurs) 5 ]"
   set private(statwin,moyenne_fond_ciel)    "$caption(audace,moyenne_fond_ciel) [ lindex $private(statwin,valeurs) 6 ]"
   set private(statwin,ecart_type_fond_ciel) "$caption(audace,ecart_type_fond_ciel) [ lindex $private(statwin,valeurs) 7 ]"

   #--- Mise a jour des labels
   $private(statwin,$visuNo,frm).frame1.lab1 configure -text "$private(statwin,maxi)"
   $private(statwin,$visuNo,frm).frame1.lab2 configure -text "$private(statwin,mini)"
   $private(statwin,$visuNo,frm).frame1.lab3 configure -text "$private(statwin,moyenne)"
   $private(statwin,$visuNo,frm).frame1.lab4 configure -text "$private(statwin,ecart_type)"
   $private(statwin,$visuNo,frm).frame1.lab5 configure -text "$private(statwin,moyenne_fond_ciel)"
   $private(statwin,$visuNo,frm).frame1.lab6 configure -text "$private(statwin,ecart_type_fond_ciel)"
}

#
#  brief commande associée au checkbutton "Rafraîchissement automatique"
#  param visuNo numéro de la visu
#  param args arguments du listener
#
proc ::audace::confStatwin { visuNo args } {
   variable private
   global conf

   #--- Configure le bouton pour le rafraichissement
   if { $conf(statwin,$visuNo,modeRefresh) == "0" } {
      $private(statwin,$visuNo,frm).frame2.butRefresh configure -state normal
      #--- J'arrete le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::removeFileNameListener $visuNo "::audace::refreshStatwin $visuNo"
   } else {
      $private(statwin,$visuNo,frm).frame2.butRefresh configure -state disabled
      #--- Je declare le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::addFileNameListener $visuNo "::audace::refreshStatwin $visuNo"
   }
}

###################################################################################

#
## @brief fournit les fwhm en x et en y d'une fenêtre d'une image
#  @param visuNo numéro de la visu
#
proc ::audace::fwhm { visuNo } {
   variable private
   global caption conf

   #---
   set base [ ::confVisu::getBase $visuNo ]

   #---
   set private(fwhm,$visuNo,frm) "$base.fwhm$visuNo"
   set frm $private(fwhm,$visuNo,frm)
   if [ winfo exists $frm ] {
      ::audace::fermeFenetresAnalyse $visuNo $frm fwhm
   }

   #--- Capture de la fenetre d'analyse
   set private(fwhm,box) [ ::confVisu::getBox $visuNo ]
   if { $private(fwhm,box) == "" } {
      return
   }

   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(fwhm,$visuNo,position) ] }    { set conf(fwhm,$visuNo,position)    "+350+75" }
   if { ! [ info exists conf(fwhm,$visuNo,modeRefresh) ] } { set conf(fwhm,$visuNo,modeRefresh) "0" }

   #--- Creation de la fenetre
   toplevel $frm
   wm transient $frm $base
   wm resizable $frm 0 0
   wm title $frm "$caption(audace,menu,fwhm)"
   wm geometry $frm $conf(fwhm,$visuNo,position)
   wm protocol $frm WM_DELETE_WINDOW "::audace::fermeFenetresAnalyse $visuNo $frm fwhm"

   #--- Creation d'une frame
   frame $frm.frame1 -borderwidth 2 -relief raised

      #--- Cree les etiquettes
      label $frm.frame1.lab0 -text "Visu$visuNo"
      pack $frm.frame1.lab0 -padx 10 -pady 2
      label $frm.frame1.lab1 -text ""
      pack $frm.frame1.lab1 -padx 10 -pady 2
      label $frm.frame1.lab2 -text ""
      pack $frm.frame1.lab2 -padx 10 -pady 2

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Creation d'une frame
   frame $frm.frame2 -borderwidth 2 -relief raised

      #--- Cree le checkbutton pour choisir le mode de rafraichissement
      checkbutton $frm.frame2.modeRefresh -text "$caption(audace,refreshAuto)" \
         -variable conf(fwhm,$visuNo,modeRefresh) -command "::audace::confFwhm $visuNo"
      pack $frm.frame2.modeRefresh -anchor w -side top -padx 3 -pady 3

      #--- Cree le bouton pour rafraichir les fwhm
      button $frm.frame2.butRefresh -text "$caption(audace,refreshManuel)" \
         -command "::audace::refreshFwhm $visuNo"
      pack $frm.frame2.butRefresh -side top -padx 6 -pady 10 -ipadx 20 -ipady 6

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Rafraichit les valeurs
   ::audace::refreshFwhm $visuNo

   #--- Rafraichit la fenetre
   ::audace::confFwhm $visuNo

   #--- La fenetre est active
   focus $frm

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $frm <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
#  brief rafraichit les valeurs de la fenêtre
#  param visuNo  numéro de la visu
#  param args arguments du listener
#
proc ::audace::refreshFwhm { visuNo args } {
   variable private
   global caption

   #--- Capture de la fenetre d'analyse
   set private(fwhm,box) [ ::confVisu::getBox $visuNo ]
   if { $private(fwhm,box) == "" } {
      return
   }

   #--- Lecture des parametres dans la fenetre
   set err [catch {set bufNo [::confVisu::getBufNo $visuNo ]} msg]
   if {$err} { set bufNo 1 }
   set private(fwhm,valeurs) [ buf$bufNo fwhm $private(fwhm,box) ]

   #--- Mise a jour des variables
   set private(fwhm,x) "$caption(audace,fwhm_x) [ lindex $private(fwhm,valeurs) 0 ]"
   set private(fwhm,y) "$caption(audace,fwhm_y) [ lindex $private(fwhm,valeurs) 1 ]"

   #--- Mise a jour des labels
   $private(fwhm,$visuNo,frm).frame1.lab1 configure -text "$private(fwhm,x)"
   $private(fwhm,$visuNo,frm).frame1.lab2 configure -text "$private(fwhm,y)"
}

#
#  brief commande associée au checkbutton "Rafraîchissement automatique"
#  param visuNo numéro de la visu
#  param args arguments du listener
#
proc ::audace::confFwhm { visuNo args } {
   variable private
   global conf

   #--- Configure le bouton pour le rafraichissement
   if { $conf(fwhm,$visuNo,modeRefresh) == "0" } {
      $private(fwhm,$visuNo,frm).frame2.butRefresh configure -state normal
      #--- J'arrete le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::removeFileNameListener $visuNo "::audace::refreshFwhm $visuNo"
   } else {
      $private(fwhm,$visuNo,frm).frame2.butRefresh configure -state disabled
      #--- Je declare le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::addFileNameListener $visuNo "::audace::refreshFwhm $visuNo"
   }
}

###################################################################################

#
## @brief ajuste une gaussienne dans une fenêtre d'une image
#  @param visuNo numéro de la visu
#
proc ::audace::fitgauss { visuNo } {
   variable private
   global caption conf

   #---
   set base [ ::confVisu::getBase $visuNo ]

   #---
   set private(fitgauss,$visuNo,frm) "$base.fitgauss$visuNo"
   set frm $private(fitgauss,$visuNo,frm)
   if [ winfo exists $frm ] {
      ::audace::fermeFenetresAnalyse $visuNo $frm fitgauss
   }

   #--- Capture de la fenetre d'analyse
   set private(fitgauss,box) [ ::confVisu::getBox $visuNo ]
   if { $private(fitgauss,box) == "" } {
      return
   }

   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(fitgauss,$visuNo,position) ] }    { set conf(fitgauss,$visuNo,position)    "+350+75" }
   if { ! [ info exists conf(fitgauss,$visuNo,modeRefresh) ] } { set conf(fitgauss,$visuNo,modeRefresh) "0" }

   #--- Creation de la fenetre
   toplevel $frm
   wm transient $frm $base
   wm resizable $frm 0 0
   wm title $frm "$caption(audace,menu,fitgauss)"
   wm geometry $frm $conf(fitgauss,$visuNo,position)
   wm protocol $frm WM_DELETE_WINDOW "::audace::fermeFenetresAnalyse $visuNo $frm fitgauss"

   #--- Creation d'une frame
   frame $frm.frame1 -borderwidth 2 -relief raised

      label $frm.frame1.lab0 -text "Visu$visuNo"
      pack $frm.frame1.lab0 -padx 10 -pady 2

      label $frm.frame1.lab1 -text ""
      pack $frm.frame1.lab1 -padx 10 -pady 2

      label $frm.frame1.lab2 -text ""
      pack $frm.frame1.lab2 -padx 10 -pady 2

      label $frm.frame1.lab3 -text ""
      pack $frm.frame1.lab3 -padx 10 -pady 2

      label $frm.frame1.lab4 -text ""
      pack $frm.frame1.lab4 -padx 10 -pady 2

      label $frm.frame1.lab5 -text ""
      pack $frm.frame1.lab5 -padx 10 -pady 2

      label $frm.frame1.lab6 -text ""
      pack $frm.frame1.lab6 -padx 10 -pady 2

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Creation d'une frame
   frame $frm.frame2 -borderwidth 2 -relief raised

      #--- Cree le checkbutton pour choisir le mode de rafraichissement
      checkbutton $frm.frame2.modeRefresh -text "$caption(audace,refreshAuto)" \
         -variable conf(fitgauss,$visuNo,modeRefresh) -command "::audace::confFitgauss $visuNo"
      pack $frm.frame2.modeRefresh -anchor w -side top -padx 3 -pady 3

      #--- Cree le bouton pour rafraichir l'ajustement de la gaussienne
      button $frm.frame2.butRefresh -text "$caption(audace,refreshManuel)" \
         -command "::audace::refreshFitgauss $visuNo"
      pack $frm.frame2.butRefresh -side top -padx 6 -pady 10 -ipadx 20 -ipady 6

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Rafraichit les valeurs
   ::audace::refreshFitgauss $visuNo

   #--- Rafraichit la fenetre
   ::audace::confFitgauss $visuNo

   #--- La fenetre est active
   focus $frm

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $frm <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
#  brief rafraichit les valeurs de la fenêtre
#  param visuNo numéro de la visu
#  param args arguments du listener
#
proc ::audace::refreshFitgauss { visuNo args } {
   variable private
   global audace caption color conf

   #--- Capture de la fenetre d'analyse
   set private(fitgauss,results) ""
   set private(fitgauss,box)     [ ::confVisu::getBox $visuNo ]
   if { $private(fitgauss,box) == "" } {
      return
   }

   #---
   set base [ ::confVisu::getBase $visuNo ]

   #--- Lecture de la gaussienne d'ajustement
   set err [catch {set bufNo [::confVisu::getBufNo $visuNo ]} msg]
   if {$err} { set bufNo 1 }

   set valeurs [ buf$bufNo fitgauss $private(fitgauss,box) ]
   set naxis1 [lindex [buf$bufNo getkwd NAXIS1] 1]
   if {$naxis1=={}} { set naxis1 1 }
   set naxis2 [lindex [buf$bufNo getkwd NAXIS2] 1]
   if {$naxis2=={}} { set naxis2 1 }
   set dif 0.
   set intx [lindex $valeurs 0]
   set xc [lindex $valeurs 1]
   set fwhmx [lindex $valeurs 2]
   set bgx [lindex $valeurs 3]
   set inty [lindex $valeurs 4]
   set yc [lindex $valeurs 5]
   set fwhmy [lindex $valeurs 6]
   set bgy [lindex $valeurs 7]
   if {$naxis1==1} {
      set if0 [ expr $inty*$fwhmy*.601*sqrt(3.14159265) ]
      set leq 0.
      if {$bgy!=0} {
         set leq [expr -$if0/$bgy]
      }
   } elseif {$naxis2==1} {
      set if0 [ expr $intx*$fwhmx*.601*sqrt(3.14159265) ]
      set leq 0.
      if {$bgx!=0} {
         set leq [expr -$if0/$bgx]
      }
   } else {
      set if0 [ expr $fwhmx*$fwhmy*.601*.601*3.14159265 ]
      set if1 [ expr $intx*$if0 ]
      set if2 [ expr $inty*$if0 ]
      set if0 [ expr ($if1+$if2)/2. ]
      set dif [ expr abs($if1-$if0) ]
   }
   set fitgauss_result ""
   lappend fitgauss_result [list xc $xc]
   lappend fitgauss_result [list yc $yc]
   lappend fitgauss_result [list fwhmx $fwhmx]
   lappend fitgauss_result [list fwhmy $fwhmy]
   lappend fitgauss_result [list intx $intx]
   lappend fitgauss_result [list inty $inty]
   lappend fitgauss_result [list flux $if0]
   lappend fitgauss_result [list dflux $dif]
   set private(fitgauss,results) $fitgauss_result
   set audace(fitgauss,results)  $fitgauss_result

   #--- Cree les etiquettes
   ::console::affiche_resultat "=== Visu$visuNo $caption(audace,titre_gauss)\n"
   ::console::affiche_resultat "$caption(audace,coord_box) : $private(fitgauss,box)\n"
   set texte "$caption(audace,center_xy) : "
   if {($naxis1>1)&&($naxis2>1)} {
      append texte "[ format "%.2f" $xc ] / [ format "%.2f" $yc ]"
   } elseif {($naxis1>1)&&($naxis2==1)} {
      append texte "[ format "%.2f" $xc ]"
   } elseif {($naxis1==1)&&($naxis2>1)} {
      append texte "[ format "%.2f" $yc ]"
   }
   ::console::affiche_resultat "$texte\n"
   $private(fitgauss,$visuNo,frm).frame1.lab1 configure -text "$texte"
   set texte "$caption(audace,fwhm_xy) : "
   if {($naxis1>1)&&($naxis2>1)} {
      append texte "[ format "%.3f" $fwhmx ] / [ format "%.3f" $fwhmy ]"
   } elseif {($naxis1>1)&&($naxis2==1)} {
      append texte "[ format "%.3f" $fwhmx ]"
   } elseif {($naxis1==1)&&($naxis2>1)} {
      append texte "[ format "%.3f" $fwhmy ]"
   }
   ::console::affiche_resultat "$texte\n"
   $private(fitgauss,$visuNo,frm).frame1.lab2 configure -text "$texte"
   set texte "$caption(audace,intens_xy) : "
   if {($naxis1>1)&&($naxis2>1)} {
      append texte "[ format "%f" $intx ] / [ format "%f" $inty ]"
   } elseif {($naxis1>1)&&($naxis2==1)} {
      append texte "[ format "%f" $intx ]"
   } elseif {($naxis1==1)&&($naxis2>1)} {
      append texte "[ format "%f" $inty ]"
   }
   ::console::affiche_resultat "$texte\n"
   $private(fitgauss,$visuNo,frm).frame1.lab3 configure -text "$texte"
   set texte "$caption(audace,back_xy) : "
   if {($naxis1>1)&&($naxis2>1)} {
      append texte "[ format "%f" $bgx ] / [ format "%f" $bgy ]"
   } elseif {($naxis1>1)&&($naxis2==1)} {
      append texte "[ format "%f" $bgx ]"
   } elseif {($naxis1==1)&&($naxis2>1)} {
      append texte "[ format "%f" $bgy ]"
   }
   ::console::affiche_resultat "$texte\n"
   $private(fitgauss,$visuNo,frm).frame1.lab4 configure -text "$texte"
   set texte "$caption(audace,integflux) : $if0 "
   if {($naxis1>1)&&($naxis2>1)} {
      append texte "+/- $dif"
   }
   ::console::affiche_resultat "$texte\n"
   $private(fitgauss,$visuNo,frm).frame1.lab5 configure -text "$texte"

   #---
   if {($naxis1==1)||($naxis2==1)} {
      set texte "$caption(audace,largeurequiv) : [ format "%f" $leq ] pixels"
      ::console::affiche_resultat "$texte\n"
      $private(fitgauss,$visuNo,frm).frame1.lab6 configure -text "$texte"
   }

   #---
   if {[expr $if0+$dif]<=0} {
      set dif [expr $if0+1]
   }
   set mag1 [ expr -2.5*log10($if0+$dif) ]
   if {[expr $if0-$dif]<=0} {
      set dif [expr $if0-1]
   }
   set mag2 [ expr -2.5*log10($if0-$dif) ]
   set mag0 [ expr ($mag1+$mag2)/2. ]
   set dmag [ expr abs($mag1-$mag0) ]
   set texte "$caption(audace,mag_instrument) : [ format %6.3f $mag0 ] +/- [ format %6.3f $dmag ]"
   ::console::affiche_resultat "$texte\n"
   ::console::affiche_saut "\n"
   if { [ $base.fra1.labURLX cget -fg ] == "$color(blue)" } {

      set err [catch {set bufNo [::confVisu::getBufNo $visuNo ]} msg]
      if {$err} { set bufNo 1 }

      set radec [ buf$bufNo xy2radec [ list [ lindex $valeurs 1 ] [ lindex $valeurs 5 ] ] ]
      set ra [ lindex $radec 0 ]
      set dec [ lindex $radec 1 ]
      set rah [ mc_angle2hms $ra 360 zero 2 auto string ]
      set decd [ mc_angle2dms $dec 90 zero 2 + string ]
      set texte "$caption(audace,RA) $caption(audace,DEC) : $ra $dec"
      ::console::affiche_resultat "$texte\n"
      set texte "$caption(audace,RA) $caption(audace,DEC) : $rah $decd"
      ::console::affiche_resultat "$texte\n"
      # 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
      #    Rab101    C2003 10 18.89848 01 33 53.74 +02 27 19.3          18.6        xxx
      #--- C2003 10 18.89848 : Indique la date du milieu de la pose pour l'image
      #--- (annee, mois, jour decimal --> qui permet d'avoir l'heure du milieu de la pose a la seconde pres)
      set mpc "OLD $caption(audace,MPC_format)\n     .        C"
      set demiexposure [ expr ( [ lindex [ buf$bufNo getkwd EXPOSURE ] 1 ]+0. )/86400./2. ]
      set d [mc_date2iso8601 [ mc_datescomp [ lindex [ buf$bufNo getkwd DATE-OBS ] 1 ] + $demiexposure ] ]
      set annee [ string range $d 0 3 ]
      set mois  [ string range $d 5 6 ]
      set jour  [ string range $d 8 9 ]
      set h [ string range $d 11 12 ]
      set m [ string range $d 14 15 ]
      set s [ string range $d 17 22 ]
      set hh [ string trimleft $h 0 ] ; if { $hh == "" } { set hh "0" }
      set mm [ string trimleft $m 0 ] ; if { $mm == "" } { set mm "0" }
      set ss [ string trimleft $s 0 ] ; if { $ss == "" } { set ss "0" }
      set res [ expr ($hh+$mm/60.+$ss/3600.)/24. ]
      set res [ string range $res 1 6 ]
      append mpc "$annee $mois ${jour}${res} "
      set h [ string range $rah 0 1 ]
      set m [ string range $rah 3 4 ]
      set s [ string range $rah 6 10 ]
      set s [ string replace $s 2 2 . ]
      append mpc "$h $m $s "
      set d [ string range $decd 0 2 ]
      set m [ string range $decd 4 5 ]
      set s [ string range $decd 7 10 ]
      set s [ string replace $s 2 2 . ]
      append mpc "$d $m $s "
      append mpc "         "
      set cmagr [ expr ( [ lindex [ buf$bufNo getkwd CMAGR ] 1 ]+0. ) ]
      if { $cmagr == "0" } { set cmagr "23" }
      set mag [ expr $cmagr+$mag0 ]
      append mpc "[ format %04.1f $mag ]"
      #---
      if { ! [ info exists conf(posobs,station_uai) ] } { set conf(posobs,station_uai) "" }
      if { $conf(posobs,station_uai) == "" } {
         set xxx "xxx"
      } else {
         set xxx $conf(posobs,station_uai)
      }
      #---
      append mpc "        $xxx"
      ::console::affiche_saut "\n"
      ::console::affiche_resultat "$mpc\n"
      ::console::affiche_saut "\n"
      #---
      if { $xxx != "xxx" } {
         ::console::affiche_erreur "$caption(audace,gauss_attention)\n"
         ::console::affiche_erreur "[eval [concat {format} { $caption(audace,UAI_site_image) $conf(posobs,station_uai) } ] ]\n"
         ::console::affiche_saut "\n"
      }
      #         1         2         3         4         5         6         7         8        9         10        11        12        13
      #123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 12
      #       J94R1234   1*C19940608.988773453 16 22 02.7812  -17 49 13.745   18.511R      1                                           0104
      #       J94R1234   2*C19940608.988773453 00.500 00.50            F.4000N             1.000                                       0104
      #       J94R1234   3*C19940608.988773453 2002.1234          +43.1234          148.0                                              0104
      #       .          1 C
      #set mpc "NEW $caption(audace,MPC_format)\n       .          1 C"
      # ---
      ::console::affiche_resultat "Use http://cfa-www.harvard.edu/iau/info/Astrometry.html for informations.\n"
      ::console::affiche_resultat "Use ::astrometry::mpc_provisional2packed to convert designation to MPC packed form.\n"
      ::console::affiche_saut "\n"
   }
}

#
#  brief commande associée au checkbutton "Rafraîchissement automatique"
#  param visuNo numéro de la visu
#  param args arguments du listener
#
proc ::audace::confFitgauss { visuNo args } {
   variable private
   global conf

   #--- Configure le bouton pour le rafraichissement
   if { $conf(fitgauss,$visuNo,modeRefresh) == "0" } {
      $private(fitgauss,$visuNo,frm).frame2.butRefresh configure -state normal
      #--- J'arrete le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::removeFileNameListener $visuNo "::audace::refreshFitgauss $visuNo"
   } else {
      $private(fitgauss,$visuNo,frm).frame2.butRefresh configure -state disabled
      #--- Je declare le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::addFileNameListener $visuNo "::audace::refreshFitgauss $visuNo"
   }
}

###################################################################################

#
## @brief fournit le photocentre d'une fenêtre d'une image
#  @param visuNo numéro de la visu
#
proc ::audace::center { visuNo } {
   variable private
   global caption conf

   #---
   set base [ ::confVisu::getBase $visuNo ]

   #---
   set private(center,$visuNo,frm) "$base.center$visuNo"
   set frm $private(center,$visuNo,frm)
   if [ winfo exists $frm ] {
      ::audace::fermeFenetresAnalyse $visuNo $frm center
   }

   #--- Capture de la fenetre d'analyse
   set private(center,box) [ ::confVisu::getBox $visuNo ]
   if { $private(center,box) == "" } {
      return
   }

   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(center,$visuNo,position) ] }    { set conf(center,$visuNo,position)    "+350+75" }
   if { ! [ info exists conf(center,$visuNo,modeRefresh) ] } { set conf(center,$visuNo,modeRefresh) "0" }

   #--- Creation de la fenetre
   toplevel $frm
   wm transient $frm $base
   wm resizable $frm 0 0
   wm title $frm "$caption(audace,menu,centro)"
   wm geometry $frm $conf(center,$visuNo,position)
   wm protocol $frm WM_DELETE_WINDOW "::audace::fermeFenetresAnalyse $visuNo $frm center"

   #--- Creation d'une frame
   frame $frm.frame1 -borderwidth 2 -relief raised

      #--- Cree les etiquettes
      label $frm.frame1.lab0 -text "Visu$visuNo"
      pack $frm.frame1.lab0 -padx 10 -pady 2
      label $frm.frame1.lab1 -text ""
      pack $frm.frame1.lab1 -padx 10 -pady 2

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Creation d'une frame
   frame $frm.frame2 -borderwidth 2 -relief raised

      #--- Cree le checkbutton pour choisir le mode de rafraichissement
      checkbutton $frm.frame2.modeRefresh -text "$caption(audace,refreshAuto)" \
         -variable conf(center,$visuNo,modeRefresh) -command "::audace::confCenter $visuNo"
      pack $frm.frame2.modeRefresh -anchor w -side top -padx 3 -pady 3

      #--- Cree le bouton pour rafraichir le photocentre
      button $frm.frame2.butRefresh -text "$caption(audace,refreshManuel)" \
         -command "::audace::refreshCenter $visuNo"
      pack $frm.frame2.butRefresh -side top -padx 6 -pady 10 -ipadx 20 -ipady 6

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Rafraichit les valeurs
   ::audace::refreshCenter $visuNo

   #--- Rafraichit la fenetre
   ::audace::confCenter $visuNo

   #--- La fenetre est active
   focus $frm

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $frm <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
#  brief rafraichit les valeurs de la fenêtre
#  param visuNo numéro de la visu
#  param args arguments du listener
#
proc ::audace::refreshCenter { visuNo args } {
   variable private
   global caption

   #--- Capture de la fenetre d'analyse
   set private(center,box) [ ::confVisu::getBox $visuNo ]
   if { $private(center,box) == "" } {
      return
   }

   #--- Lecture des parametres dans la fenetre
   set err [catch {set bufNo [::confVisu::getBufNo $visuNo ]} msg]
   if {$err} { set bufNo 1 }
   set private(center,valeurs) [ buf$bufNo centro $private(center,box) ]

   #--- Mise a jour des variables
   set private(center,centro) "$caption(audace,center_xy) : ( [ format "%.2f" [ lindex $private(center,valeurs) 0 ] ] / [ format "%.2f" [ lindex $private(center,valeurs) 1 ] ] )"

   #--- Mise a jour des labels
   $private(center,$visuNo,frm).frame1.lab1 configure -text "$private(center,centro)"
}

#
#  brief commande associée au checkbutton "Rafraîchissement automatique"
#  param visuNo numéro de la visu
#  param args arguments du listener
#
proc ::audace::confCenter { visuNo args } {
   variable private
   global conf

   #--- Configure le bouton pour le rafraichissement
   if { $conf(center,$visuNo,modeRefresh) == "0" } {
      $private(center,$visuNo,frm).frame2.butRefresh configure -state normal
      #--- J'arrete le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::removeFileNameListener $visuNo "::audace::refreshCenter $visuNo"
   } else {
      $private(center,$visuNo,frm).frame2.butRefresh configure -state disabled
      #--- Je declare le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::addFileNameListener $visuNo "::audace::refreshCenter $visuNo"
   }
}

###################################################################################

#
## @brief fournit la photométrie intégrale d'une fenêtre d'une image
#  @param visuNo numéro de la visu
#
proc ::audace::photom { visuNo } {
   variable private
   global caption conf

   #---
   set base [ ::confVisu::getBase $visuNo ]

   #---
   set private(photom,$visuNo,frm) "$base.photom$visuNo"
   set frm $private(photom,$visuNo,frm)
   if [ winfo exists $frm ] {
      ::audace::fermeFenetresAnalyse $visuNo $frm photom
   }

   #--- Capture de la fenetre d'analyse
   set private(photom,box) [ ::confVisu::getBox $visuNo ]
   if { $private(photom,box) == "" } {
      return
   }

   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(photom,$visuNo,position) ] }    { set conf(photom,$visuNo,position)    "+350+75" }
   if { ! [ info exists conf(photom,$visuNo,modeRefresh) ] } { set conf(photom,$visuNo,modeRefresh) "0" }

   #--- Creation de la fenetre
   toplevel $frm
   wm transient $frm $base
   wm resizable $frm 0 0
   wm title $frm "$caption(audace,menu,phot)"
   wm geometry $frm $conf(photom,$visuNo,position)
   wm protocol $frm WM_DELETE_WINDOW "::audace::fermeFenetresAnalyse $visuNo $frm photom"

   #--- Creation d'une frame
   frame $frm.frame1 -borderwidth 2 -relief raised

      #--- Cree les etiquettes
      label $frm.frame1.lab0 -text "Visu$visuNo"
      pack $frm.frame1.lab0 -padx 10 -pady 2
      label $frm.frame1.lab1 -text ""
      pack $frm.frame1.lab1 -padx 10 -pady 2

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Creation d'une frame
   frame $frm.frame2 -borderwidth 2 -relief raised

      #--- Cree le checkbutton pour choisir le mode de rafraichissement
      checkbutton $frm.frame2.modeRefresh -text "$caption(audace,refreshAuto)" \
         -variable conf(photom,$visuNo,modeRefresh) -command "::audace::confPhotom $visuNo"
      pack $frm.frame2.modeRefresh -anchor w -side top -padx 3 -pady 3

      #--- Cree le bouton pour rafraichir la photometrie integrale
      button $frm.frame2.butRefresh -text "$caption(audace,refreshManuel)" \
         -command "::audace::refreshPhotom $visuNo"
      pack $frm.frame2.butRefresh -side top -padx 6 -pady 10 -ipadx 20 -ipady 6

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Rafraichit les valeurs
   ::audace::refreshPhotom $visuNo

   #--- Rafraichit la fenetre
   ::audace::confPhotom $visuNo

   #--- La fenetre est active
   focus $frm

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $frm <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
#  brief rafraichit les valeurs de la fenêtre
#  param visuNo numéro de la visu
#  param args arguments du listener
#
proc ::audace::refreshPhotom { visuNo args } {
   variable private
   global caption

   #--- Capture de la fenetre d'analyse
   set private(photom,box) [ ::confVisu::getBox $visuNo ]
   if { $private(photom,box) == "" } {
      return
   }

   #--- Lecture des parametres dans la fenetre
   set err [catch {set bufNo [::confVisu::getBufNo $visuNo ]} msg]
   if {$err} { set bufNo 1 }
   set private(photom,valeurs) [ buf$bufNo phot $private(photom,box) ]

   #--- Mise a jour des variables
   set private(photom,integflux) "$caption(audace,integflux) : [ lindex $private(photom,valeurs) 0 ]"

   #--- Mise a jour des labels
   $private(photom,$visuNo,frm).frame1.lab1 configure -text "$private(photom,integflux)"
}

#
#  brief commande associée au checkbutton "Rafraîchissement automatique"
#  param visuNo numéro de la visu
#  param args arguments du listener
#
proc ::audace::confPhotom { visuNo args } {
   variable private
   global conf

   #--- Configure le bouton pour le rafraichissement
   if { $conf(photom,$visuNo,modeRefresh) == "0" } {
      $private(photom,$visuNo,frm).frame2.butRefresh configure -state normal
      #--- J'arrete le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::removeFileNameListener $visuNo "::audace::refreshPhotom $visuNo"
   } else {
      $private(photom,$visuNo,frm).frame2.butRefresh configure -state disabled
      #--- Je declare le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::addFileNameListener $visuNo "::audace::refreshPhotom $visuNo"
   }
}

###################################################################################
# Procedures annexes des procedures ci-dessus
###################################################################################

#
## @brief sauve les coordonnées des boîtes de dialogue dans des variables conf(nom_conf,$visuNo,position)
#  pour les fonctions :
#   - "Statistiques dans la fenêtre" ; nom_conf="statwin"
#   - "Fwhm" ; nom_conf="fwhm"
#   - "Ajuster une gaussienne" ; nom_conf="fitgauss"
#   - "Photocentre" ; nom_conf="center"
#   - "Photométrie intégrale" ; nom_conf="photom"
#  @param visuNo numéro de la visu
#  @param frm chemin Tk
#  @param nom_conf nom spécifique de la fenêtre
#
proc ::audace::fermeFenetresAnalyse { visuNo frm nom_conf } {
   global conf

   #--- J'arrete le rafraichissement automatique des valeurs si on charge une image
   ::confVisu::removeFileNameListener $visuNo "::audace::refreshStatwin $visuNo"
   ::confVisu::removeFileNameListener $visuNo "::audace::refreshFwhm $visuNo"
   ::confVisu::removeFileNameListener $visuNo "::audace::refreshFitgauss $visuNo"
   ::confVisu::removeFileNameListener $visuNo "::audace::refreshCenter $visuNo"
   ::confVisu::removeFileNameListener $visuNo "::audace::refreshPhotom $visuNo"

   #--- Determination de la position de la fenetre
   set geometry [ wm geometry $frm ]
   set deb [ expr 1 + [ string first + $geometry ] ]
   set fin [ string length $geometry ]
   set conf($nom_conf,$visuNo,position) "+[ string range $geometry $deb $fin ]"

   #--- Fermeture de la fenetre
   destroy $frm
}

############################# Fin du namespace audace #############################

###################################################################################
# Procedures psf_toolbox ci-dessus
###################################################################################

#
# psf_toolbox visuNo
# Ajuste une psf dans une fenetre d'une image
#

proc ::audace::psf_toolbox { visuNo } {

   global private
   global caption
   global conf

   #---
   set base [ ::confVisu::getBase $visuNo ]

   #---
   set private(psf_toolbox,$visuNo,frm) "$base.psfimcce$visuNo"
   set frm $private(psf_toolbox,$visuNo,frm)
   if [ winfo exists $frm ] {
      ::audace::fermeFenetresAnalyse $visuNo $frm psfimcce
   }

   #--- Capture de la fenetre d'analyse
   set private(psf_toolbox,$visuNo,box) [ ::confVisu::getBox $visuNo ]
   if { $private(psf_toolbox,$visuNo,box) == "" } {
      return
   }

   #--- Initialisation de la position de la fenetre
   ::audace::psf_init $visuNo

   #--- On se trouve dans une GUI
   set private(psf_toolbox,$visuNo,gui)   1
   set private(psf_toolbox,$visuNo,graph) 1

   #--- Creation de la fenetre
   toplevel $frm
   wm transient $frm $base
   wm resizable $frm 0 0
   wm title $frm "$caption(audace,menu,psf_toolbox) Visu$visuNo"
   wm geometry $frm $conf(psf_toolbox,$visuNo,position)
   wm protocol $frm WM_DELETE_WINDOW "::audace::psf_fermer $visuNo $frm"
   set onglets [frame $frm.onglets]

   pack $onglets -in $frm

         pack [ttk::notebook $onglets.nb] -expand yes -fill both
         # set f1 [frame $onglets.nb.f1]
         set f_res  [frame $onglets.nb.f_res]
         set f_img  [frame $onglets.nb.f_img]
         set f_mark [frame $onglets.nb.f_mark]
         set f_comp [frame $onglets.nb.f_comp]

         # $onglets.nb add $f1 -text "Methode"
         $onglets.nb add $f_res  -text "$caption(audace,psf_toolbox_Mesures)"
         $onglets.nb add $f_img  -text "$caption(audace,psf_toolbox_Image)"
         $onglets.nb add $f_mark -text "$caption(audace,psf_toolbox_Marques)"
         $onglets.nb add $f_comp -text "$caption(audace,psf_toolbox_Comparaison)"

         $onglets.nb select $f_res
         ttk::notebook::enableTraversal $onglets.nb

         # onglets : methodes

         # set methodes [frame $f1.methodes]
         # pack $methodes -in $f1 -padx 5 -pady 5

         # psf_gui_methodes $visuNo $methodes

         # onglets : mesures

         set results [frame $f_res.results]
         pack $results -in $f_res

         ::audace::psf_gui_graphes $visuNo $results

         # onglets : images

         set images [frame $f_img.images]

         pack $images -in $f_img -expand yes -fill both

            set block1 [frame $images.block1 -borderwidth 2 -relief groove]
            set block2 [frame $images.block2 -borderwidth 2 -relief groove]
            set block3 [frame $images.block3 -borderwidth 2 -relief groove]
            set block4 [frame $images.block4 -borderwidth 2 -relief groove]

            grid $block1 -in $images -row 0 -column 0 -sticky news
            grid $block2 -in $images -row 0 -column 1 -sticky news
            grid $block3 -in $images -row 1 -column 0 -sticky news
            grid $block4 -in $images -row 1 -column 1 -sticky news

            grid rowconfigure $images {0 1} -weight 1
            grid columnconfigure $images 0 -weight 1
            grid columnconfigure $images 1 -weight 1

            label $block1.lab -text "$caption(audace,psf_toolbox_imagenondispo)" -justify center
            grid $block1.lab -in $block1 -row 0 -column 0 -sticky es -pady 10 -padx 10

            label $block2.lab -text "$caption(audace,psf_toolbox_imagenondispo)"  -justify center -pady 10 -padx 10
            grid $block2.lab -in $block2 -row 0 -column 0 -sticky news

            label $block3.lab -text "$caption(audace,psf_toolbox_imagenondispo)"  -justify center -pady 10 -padx 10
            grid $block3.lab -in $block3 -row 0 -column 0 -sticky news

         # onglets : Marques

         set marks [frame $f_mark.marks]
         pack $marks -in $f_mark -expand yes -fill both

            set block [frame $marks.marks]
            pack $block -in $marks

               checkbutton $block.voir -text "$caption(audace,psf_toolbox_Voirlescercles)" \
                                 -variable private(psf_toolbox,$visuNo,marks,cercle)
               button $block.delete -text "$caption(audace,psf_toolbox_Nettoyerlesmarques)" -relief "raised" -height 1\
                                 -command "::audace::psf_clean_mark $visuNo"
               grid $block.voir     -sticky nsw -pady 8
               grid $block.delete   -sticky nsw -pady 3

         # onglets : Comparaison

         set compar [frame $f_comp.compar]
         pack $compar -in $f_comp -expand yes -fill both

            set block [frame $compar.methodes]
            pack $block -in $compar

               label       $block.lab           -text "$caption(audace,psf_toolbox_Compdesmethodes)" -justify left
               checkbutton $block.photom        -text "photom"        -variable private(psf_toolbox,$visuNo,compar,photom)
               checkbutton $block.fitgauss2D    -text "fitgauss2D"    -variable private(psf_toolbox,$visuNo,compar,fitgauss2D)
               checkbutton $block.psfimcce      -text "psfimcce"      -variable private(psf_toolbox,$visuNo,compar,psfimcce)
               checkbutton $block.psfgaussian2d -text "psfgaussian2d" -variable private(psf_toolbox,$visuNo,compar,psfgaussian2d)
               checkbutton $block.psfmoffat     -text "psfmoffat"     -variable private(psf_toolbox,$visuNo,compar,psfmoffat)

               button $block.go -text "$caption(audace,psf_toolbox_Go)" -relief "raised" -width 8 -height 1\
                                 -command "::audace::psf_compar $visuNo $compar"

               grid $block.lab             -sticky nsw -pady 8
               grid $block.photom          -sticky nsw -pady 3
               grid $block.fitgauss2D      -sticky nsw -pady 3
               grid $block.psfimcce        -sticky nsw -pady 3
               grid $block.psfgaussian2d   -sticky nsw -pady 3
               grid $block.psfmoffat       -sticky nsw -pady 3
               grid $block.go              -sticky nsw -pady 10

            set block [frame $compar.graph]
            pack $block -in $compar

               button $block.xsm -state normal -text "xsm" -relief "raised" -width 8 -height 1\
                                 -command "::audace::psf_graph_compar $visuNo xsm"
               button $block.ysm -state normal -text "ysm" -relief "raised" -width 8 -height 1\
                                 -command "::audace::psf_graph_compar $visuNo ysm"
               button $block.fwhmx -state normal -text "fwhmx" -relief "raised" -width 8 -height 1\
                                 -command "::audace::psf_graph_compar $visuNo fwhmx"
               button $block.fwhmy -state normal -text "fwhmy" -relief "raised" -width 8 -height 1\
                                 -command "::audace::psf_graph_compar $visuNo fwhmy"
               button $block.fwhm -state normal -text "fwhm" -relief "raised" -width 8 -height 1\
                                 -command "::audace::psf_graph_compar $visuNo fwhm"
               button $block.flux -state normal -text "flux" -relief "raised" -width 8 -height 1\
                                 -command "::audace::psf_graph_compar $visuNo flux"
               button $block.sky -state normal -text "sky" -relief "raised" -width 8 -height 1\
                                 -command "::audace::psf_graph_compar $visuNo sky"
               button $block.snint -state normal -text "snint" -relief "raised" -width 8 -height 1\
                                 -command "::audace::psf_graph_compar $visuNo snint"

               grid $block.xsm $block.fwhmx  $block.fwhm $block.sky   -sticky nsw -pady 3
               grid $block.ysm $block.fwhmy  $block.flux $block.snint -sticky nsw -pady 3

   #--- Creation d'une frame
   frame $frm.config -borderwidth 2 -relief raised
   pack $frm.config -side top -fill both -expand 1

      ::audace::psf_gui_methodes $visuNo $frm.config

   #--- Creation d'une frame
   frame $frm.temps -borderwidth 2 -relief raised
   pack $frm.temps -side top -fill both -expand 1 -anchor c

      label $frm.temps.lab -text "$caption(audace,psf_toolbox_Duree)" -justify center -pady 1 -padx 1
      label $frm.temps.val -textvariable private(psf_toolbox,$visuNo,duree) -justify center -pady 1 -padx 1
      label $frm.temps.sec -text "$caption(audace,psf_toolbox_sec)"  -justify center -pady 1 -padx 1

      grid $frm.temps.lab $frm.temps.val $frm.temps.sec -sticky news

   #--- Creation d'une frame
   frame $frm.frame2 -borderwidth 2 -relief raised

      #--- Cree le checkbutton pour choisir le mode de rafraichissement
      checkbutton $frm.frame2.modeRefresh -text "$caption(audace,refreshAuto)" \
         -variable conf(psf_toolbox,$visuNo,modeRefresh) -command "::audace::confFitgauss $visuNo"\
         -state disabled

      button $frm.frame2.buthelp -text "$caption(audace,psf_toolbox_aide)" \
         -command "::audace::psf_help $visuNo" -width 10

      #--- Cree le bouton pour rafraichir l'ajustement de la gaussienne
      button $frm.frame2.butRefresh -text "$caption(audace,refreshManuel)" \
         -command "::audace::refreshPSF $visuNo"

      #--- Cree le bouton pour rafraichir l'ajustement de la gaussienne
      button $frm.frame2.butFermer -text "$caption(audace,psf_toolbox_fermer)" \
         -command "::audace::psf_fermer $visuNo $frm" -width 10

      grid $frm.frame2.modeRefresh -columnspan 3 -sticky news
      grid $frm.frame2.buthelp $frm.frame2.butRefresh $frm.frame2.butFermer -sticky news

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Rafraichit les valeurs
   ::audace::refreshPSF_simple $visuNo

   #--- Rafraichit la fenetre
   #::audace::confFitgauss $visuNo

   #--- La fenetre est active
   focus $frm

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $frm <Key-r> {catch {::console::affiche_erreur "Ressource\n" ; source [file join $audace(rep_gui) audace aud_menu_5.tcl] ; source [file join $audace(rep_gui) audace caption aud_menu_5.cap] }}
   bind $frm <Key-n> {catch {::console::affiche_erreur "Edit source: \n nc /srv/develop/audela/gui/audace/aud_menu_5.tcl\n" }}
   bind $frm <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm

}

proc ::audace::get_fields_current_psf { } {
   return [list "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "err_psf" "flux" "err_flux" "pixmax" \
                "intensity" "sky" "err_sky" "snint" "radius" ]
}

proc ::audace::get_fields_current_psf_left { } {
   return [list "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "err_psf" ]
}

proc ::audace::get_fields_current_psf_right { } {
   return [list "flux" "err_flux" "pixmax" "intensity" "sky" "err_sky" "snint" "radius" ]
}

proc ::audace::psf_get_methodes { } {
   return { fitgauss photom fitgauss2D psfimcce psfgaussian2d psfmoffat }
}

#------------------------------------------------------------
#  brief créé l'interface des graphiques
#  param visuNo numéro de la visu
#  param frm chemin Tk
#
proc ::audace::psf_gui_graphes { visuNo frm } {
   set block [frame $frm.params]
   pack $block -in $frm

      set values [ frame $block.valuesleft]
      pack $values -in $block -anchor n -side left

         foreach key [::audace::get_fields_current_psf_left] {

            set value [ frame $values.$key -borderwidth 0 -cursor arrow -relief groove ]
            pack $value -in $values -anchor n -side top -expand 1 -fill both -padx 0 -pady 0

               if {$key=="err_xsm"||$key=="err_ysm"||$key=="err_psf"} {
                  set active disabled
               } else {
                  set active active
               }
               button $value.graph -state $active -text "$key" -relief "raised" -width 8 -height 1\
                  -command "::audace::psf_graph $visuNo $key"
               label $value.lab1 -text " = "
               label $value.lab2 -textvariable private(psf_toolbox,$visuNo,psf,$key) -width 8
               grid $value.graph $value.lab1 $value.lab2 -sticky nsw -pady 3

         }

      set values [ frame $block.valuesright]
      pack $values -in $block -anchor n -side right

         foreach key [::audace::get_fields_current_psf_right] {

            set value [ frame $values.$key -borderwidth 0 -cursor arrow -relief groove ]
            pack $value -in $values -anchor n -side top -padx 0 -pady 0

               if {$key=="err_flux"||$key=="radius"||$key=="err_sky"||$key=="pixmax"} {
                  set active disabled
               } else {
                  set active active
               }
               button $value.graph -state $active -text "$key" -relief "raised" -width 8 -height 1\
                  -command "::audace::psf_graph $visuNo $key"
               label $value.lab1 -text " = "
               label $value.lab2 -textvariable private(psf_toolbox,$visuNo,psf,$key)  -width 8
               grid $value.graph $value.lab1 $value.lab2 -sticky nsw -pady 3

         }
}

proc ::audace::psf_gui_methodes { visuNo frm } {
   global private
   global caption

   set spinlist ""
   for {set i 1} {$i<$private(psf_toolbox,$visuNo,radius,max)} {incr i} {lappend spinlist $i}

   set block_methodes [frame $frm.block_methodes -borderwidth 1 -cursor arrow -relief groove]
   pack $block_methodes -in $frm -anchor c -side top

   # Choix de methode
   set actions [frame $block_methodes.actions -borderwidth 0 -cursor arrow -relief groove]
   pack $actions -in $block_methodes -anchor w -side top

      label $actions.lab1 -text "$caption(audace,psf_toolbox_MethodepourPSF)"
      menubutton $actions.b -menu $actions.b.m -textvar private(psf_toolbox,$visuNo,methode) -width 10 -relief groove
      menu $actions.b.m -tearoff 0
      foreach value [psf_get_methodes] {
         $actions.b.m add command -label $value -command "::audace::psf_set_methode $visuNo $block_methodes $value"
      }
      grid $actions.lab1 $actions.b
      #$actions.b.m select

   # Configuration de la methode
   set conf [frame $block_methodes.config -borderwidth 0 -cursor arrow -relief groove]
   pack $conf -in $block_methodes -anchor w -side top

   # Configuration de la globale
   set glo [frame $block_methodes.glo -borderwidth 0 -cursor arrow -relief groove]
   pack $glo -in $block_methodes -anchor w -side top

      set glocheck [frame $glo.check -borderwidth 0 -cursor arrow -relief groove]
      pack $glocheck -in $glo -anchor w -side top
      set glocconf [frame $glo.conf -borderwidth 0 -cursor arrow -relief groove]
      pack $glocconf -in $glo -anchor w -side top

         checkbutton $glocheck.globale -text "$caption(audace,psf_toolbox_Rechercheglobale)" \
            -variable private(psf_toolbox,$visuNo,globale) \
            -command "::audace::psf_switch_globale $visuNo $glocconf"
         grid $glocheck.globale

   # Configuration de l Ecretage
   set ecr [frame $block_methodes.ecr -borderwidth 0 -cursor arrow -relief groove]
   pack $ecr -in $block_methodes -anchor w -side top

      set ecrcheck [frame $ecr.check -borderwidth 0 -cursor arrow -relief groove]
      pack $ecrcheck -in $ecr -anchor w -side top
      set ecrcconf [frame $ecr.conf -borderwidth 0 -cursor arrow -relief groove]
      pack $ecrcconf -in $ecr -anchor w -side top

         checkbutton $ecrcheck.ecrbale -text "$caption(audace,psf_toolbox_Ecretage)" \
            -variable private(psf_toolbox,$visuNo,ecretage) \
            -command "::audace::psf_switch_ecretage $visuNo $ecrcconf"
         grid $ecrcheck.ecrbale

   ::audace::psf_set_methode $visuNo $block_methodes $private(psf_toolbox,$visuNo,methode)
   ::audace::psf_switch_globale $visuNo $glocconf
   ::audace::psf_switch_ecretage $visuNo $ecrcconf
}

proc ::audace::psf_switch_globale { visuNo frm } {
   global private
   global caption

   set block $frm.here
   destroy $block
   set conf [frame $block -borderwidth 0 -cursor arrow -relief groove]
   pack $conf -in $frm -anchor w -side top

   if {$private(psf_toolbox,$visuNo,globale)==1} {

      label $conf.c1 -text "" -width 5
      set limit [frame $conf.limit -borderwidth 0 -cursor arrow -relief groove]
      grid $conf.c1 $limit  -sticky news

         label $limit.radl1 -text "$caption(audace,psf_toolbox_Limitemin)"
         entry $limit.radv1 -textvariable private(psf_toolbox,$visuNo,globale,min) -relief sunken -width 5

         label $limit.radl2 -text "$caption(audace,psf_toolbox_Limitemax)"
         entry $limit.radv2 -textvariable private(psf_toolbox,$visuNo,globale,max) -relief sunken -width 5

         grid $limit.radl1 $limit.radv1 -sticky news
         grid $limit.radl2 $limit.radv2 -sticky news

      label $conf.c2 -text "" -width 5
      set errors [frame $conf.errors -borderwidth 0 -cursor arrow -relief groove]
      grid $conf.c2 $errors -sticky news

         checkbutton $errors.arret -text "$caption(audace,psf_toolbox_Arretsi)" -variable private(psf_toolbox,$visuNo,globale,arret)
         set sav $private(psf_toolbox,$visuNo,globale,nberror)
         spinbox $errors.nberror   -values [list 1 2 3 5 10] -from 1 -to 10 \
                                  -textvariable private(psf_toolbox,$visuNo,globale,nberror) -width 3
         set private(psf_toolbox,$visuNo,globale,nberror) $sav
         label $errors.arretlab    -text "$caption(audace,psf_toolbox_erreurs)"

         grid $errors.arret  $errors.nberror $errors.arretlab -sticky news

      label $conf.c3 -text "" -width 5
      set confidence [frame $conf.confidence -borderwidth 0 -cursor arrow -relief groove]
      grid $conf.c3 $confidence -sticky news

         label $confidence.radl1 -text "$caption(audace,psf_toolbox_Confidence)"
         entry $confidence.radv1 -textvariable private(psf_toolbox,$visuNo,globale,confidence) -relief sunken -width 5
         grid $confidence.radl1 $confidence.radv1 -sticky news

   }

}

proc ::audace::psf_switch_ecretage { visuNo frm } {
   global private
   global caption

   set block $frm.here
   destroy $block
   set conf [frame $block -borderwidth 0 -cursor arrow -relief groove]
   pack $conf -in $frm -anchor w -side top

   if {$private(psf_toolbox,$visuNo,ecretage)==1} {

      label $conf.c1 -text "" -width 5
      set limit [frame $conf.limit -borderwidth 0 -cursor arrow -relief groove]
      grid $conf.c1 $limit  -sticky nws

         label $limit.satl -text "$caption(audace,psf_toolbox_Saturation)"
         entry $limit.satv -textvariable private(psf_toolbox,$visuNo,saturation)  -relief sunken -width 5

         label $limit.thrl -text "$caption(audace,psf_toolbox_Seuil)"
         entry $limit.thrv -textvariable private(psf_toolbox,$visuNo,threshold) -relief sunken -width 5

         grid $limit.satl  $limit.satv -sticky nsw -pady 3
         grid $limit.thrl  $limit.thrv -sticky nsw -pady 3
   }

}
proc ::audace::psf_gui_moffat_ajust_beta { visuNo frm } {

   global private
   if {$private(psf_toolbox,$visuNo,ajust_beta)==1} {
      $frm configure -state disabled
   } else {
      $frm configure -state normal
   }
}

proc ::audace::psf_set_methode { visuNo frm value } {

   global private
   global caption

   set private(psf_toolbox,$visuNo,methode) $value
   ::console::affiche_resultat "$caption(audace,psf_toolbox_Methode) : $private(psf_toolbox,$visuNo,methode)\n"

   set block $frm.config.here
   destroy $block
   set conf [frame $block -borderwidth 0 -cursor arrow -relief groove]
   pack $conf -in $frm.config -anchor w -side top -expand 0

   set spinlist ""
   for {set i 1} {$i<$private(psf_toolbox,$visuNo,radius,max)} {incr i} {lappend spinlist $i}

      label $conf.c1 -text "" -width 5
      set limit [frame $conf.limit -borderwidth 0 -cursor arrow -relief groove]
      grid $conf.c1 $limit -sticky nws

   switch $value {
      "photom" {
                  label $limit.radl -text "$caption(audace,psf_toolbox_Rayon)"
                  set sav $private(psf_toolbox,$visuNo,radius)
                  spinbox $limit.radiusc -values $spinlist -from 1 -to $private(psf_toolbox,$visuNo,radius,max) \
                      -textvariable private(psf_toolbox,$visuNo,radius) -width 3 \
                      -command "if {$private(psf_toolbox,$visuNo,gui)} {::audace::refreshPSF_simple $visuNo}"
                  set private(psf_toolbox,$visuNo,radius) $sav
                  $limit.radiusc set $private(psf_toolbox,$visuNo,radius)

                  LabelEntry $limit.r1 -label "$caption(audace,psf_toolbox_r1)" -textvariable private(psf_toolbox,$visuNo,photom,r1) -relief sunken -width 5
                  label $limit.r1s -text "$caption(audace,psf_toolbox_xRayon)"

                  LabelEntry $limit.r2 -label "$caption(audace,psf_toolbox_r2)" -textvariable private(psf_toolbox,$visuNo,photom,r2) -relief sunken -width 5
                  label $limit.r2s -text "$caption(audace,psf_toolbox_xRayon)"

                  LabelEntry $limit.r3 -label "$caption(audace,psf_toolbox_r3)" -textvariable private(psf_toolbox,$visuNo,photom,r3) -relief sunken -width 5
                  label $limit.r3s -text "$caption(audace,psf_toolbox_xRayon)"

                  grid $limit.radl $limit.radiusc -sticky nsw -pady 1
                  grid $limit.r1   $limit.r1s -sticky nsw -pady 0 -columnspan 2
                  grid $limit.r2   $limit.r2s -sticky nsw -pady 0 -columnspan 2
                  grid $limit.r3   $limit.r3s -sticky nsw -pady 0 -columnspan 2
               }

      "fitgauss2D" {
                  label $limit.radl -text "$caption(audace,psf_toolbox_Rayon)"
                  set sav $private(psf_toolbox,$visuNo,radius)
                  spinbox $limit.radiusc -values $spinlist -from 1 -to $private(psf_toolbox,$visuNo,radius,max) \
                      -textvariable private(psf_toolbox,$visuNo,radius) -width 3 \
                      -command "if {$private(psf_toolbox,$visuNo,gui)} {::audace::refreshPSF_simple $visuNo}"
                  set private(psf_toolbox,$visuNo,radius) $sav
                  $limit.radiusc set $private(psf_toolbox,$visuNo,radius)

                  grid $limit.radl $limit.radiusc -sticky nsw -pady 3
               }

      "psfimcce" {
                  label $limit.radl -text "$caption(audace,psf_toolbox_Rayon)"
                  set sav $private(psf_toolbox,$visuNo,radius)
                  spinbox $limit.radiusc -values $spinlist -from 1 -to $private(psf_toolbox,$visuNo,radius,max) \
                      -textvariable private(psf_toolbox,$visuNo,radius) -width 3 \
                      -command "if {$private(psf_toolbox,$visuNo,gui)} {::audace::refreshPSF_simple $visuNo}"
                  set private(psf_toolbox,$visuNo,radius) $sav
                  $limit.radiusc set $private(psf_toolbox,$visuNo,radius)

                  grid $limit.radl    $limit.radiusc  -sticky nsw -pady 3
               }

      "psfgaussian2d" {
                  label $limit.radl -text "$caption(audace,psf_toolbox_Rayon)"
                  set sav $private(psf_toolbox,$visuNo,radius)
                  spinbox $limit.radiusc -values $spinlist -from 1 -to $private(psf_toolbox,$visuNo,radius,max) \
                      -textvariable private(psf_toolbox,$visuNo,radius) -width 3 \
                      -command "if {$private(psf_toolbox,$visuNo,gui)} {::audace::refreshPSF_simple $visuNo}"
                  set private(psf_toolbox,$visuNo,radius) $sav
                  $limit.radiusc set $private(psf_toolbox,$visuNo,radius)

                  checkbutton $limit.gs -text "$caption(audace,psf_toolbox_gaussian_statistics)" -variable private(psf_toolbox,$visuNo,gaussian_statistics)
                  LabelEntry $limit.ron -label "$caption(audace,psf_toolbox_read_out_noise)" -textvariable private(psf_toolbox,$visuNo,read_out_noise) -relief sunken -width 5

                  grid $limit.gs  -sticky nsw -pady 3 -columnspan 2
                  grid $limit.ron  -sticky nsw -pady 3 -columnspan 2
                  grid $limit.radl    $limit.radiusc  -sticky nsw -pady 3
               }

      "psfmoffat" {
                  label $limit.radl -text "$caption(audace,psf_toolbox_Rayon)"
                  set sav $private(psf_toolbox,$visuNo,radius)
                  spinbox $limit.radiusc -values $spinlist -from 1 -to $private(psf_toolbox,$visuNo,radius,max) \
                      -textvariable private(psf_toolbox,$visuNo,radius) -width 3 \
                      -command "if {$private(psf_toolbox,$visuNo,gui)} {::audace::refreshPSF_simple $visuNo}"
                  set private(psf_toolbox,$visuNo,radius) $sav
                  $limit.radiusc set $private(psf_toolbox,$visuNo,radius)

                  checkbutton $limit.gs -text "$caption(audace,psf_toolbox_gaussian_statistics)" -variable private(psf_toolbox,$visuNo,gaussian_statistics)
                  LabelEntry $limit.ron -label "$caption(audace,psf_toolbox_read_out_noise)" -textvariable private(psf_toolbox,$visuNo,read_out_noise) -relief sunken -width 5
                  # valeur par defaut si rien est mis dans la case
                  if {$private(psf_toolbox,$visuNo,beta)==""} {set private(psf_toolbox,$visuNo,beta) -3}
                  LabelEntry $limit.beta -label "beta" -textvariable private(psf_toolbox,$visuNo,beta) -relief sunken -width 5
                  checkbutton $limit.ajustbeta -text "$caption(audace,psf_toolbox_adjust_beta)" -variable private(psf_toolbox,$visuNo,ajust_beta) -command "::audace::psf_gui_moffat_ajust_beta $visuNo $limit.beta"
                  # activation du select
                  ::audace::psf_gui_moffat_ajust_beta $visuNo $limit.beta
                  grid $limit.gs  -sticky nsw -pady 3 -columnspan 2
                  grid $limit.ron  -sticky nsw -pady 3 -columnspan 2
                  grid $limit.beta $limit.ajustbeta  -sticky nsw
                  grid $limit.radl    $limit.radiusc  -sticky nsw -pady 3
               }

   }

}

proc ::audace::refreshPSF { visuNo args } {

   global private
   global caption

   $private(psf_toolbox,$visuNo,hcanvas) delete globalePSF

   #--- Capture de la fenetre d'analyse
   set private(center,box) [ ::confVisu::getBox $visuNo ]
   if { $private(center,box) == "" } {
      return
   }

   set err [catch {set bufNo [::confVisu::getBufNo $visuNo ]} msg]
   if {$err} { set bufNo 1 }

   set r [ buf$bufNo fitgauss $private(center,box) ]
   set x [lindex $r 1]
   set y [lindex $r 5]

   set tt0 [clock clicks -milliseconds]

   #::console::affiche_resultat "Refresh PSF : $private(psf_toolbox,$visuNo,methode) globale=$private(psf_toolbox,$visuNo,globale)\n"

   if { $private(psf_toolbox,$visuNo,globale) } {
      ::audace::PSF_globale $visuNo $x $y
   } else {
      ::audace::PSF_one_radius $visuNo $x $y
   }

   if {$private(psf_toolbox,$visuNo,gui)} {
     ::audace::displayStar $visuNo
   }

   set private(psf_toolbox,$visuNo,duree) [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.] ]

   return
}

proc ::audace::refreshPSF_simple { visuNo } {

   global private

   #--- Capture de la fenetre d'analyse
   set private(center,box) [ ::confVisu::getBox $visuNo ]
   if { $private(center,box) == "" } {
      return
   }

   set err [catch {set bufNo [::confVisu::getBufNo $visuNo ]} msg]
   if {$err} { set bufNo 1 }

   set r [ buf$bufNo fitgauss $private(center,box) ]
   set x [lindex $r 1]
   set y [lindex $r 5]

   set tt0 [clock clicks -milliseconds]

   ::console::affiche_resultat "RefreshPSF_simple : $private(psf_toolbox,$visuNo,methode) globale=$private(psf_toolbox,$visuNo,globale)\n"

   ::audace::PSF_one_radius $visuNo $x $y

   set private(psf_toolbox,$visuNo,duree) [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.] ]

   return
}

#------------------------------------------------------------
## Fonction qui mesure le photocentre d'une source
# suivant la methode fournit par l appel a
# buf1 fitgauss
#
# @brief Normalisation des donnees resultats
#
# @param visuNo
# @param x : coordonnee pixel de la source dans l'image
# @param y : coordonnee pixel de la source dans l'image
#
proc ::audace::PSF_method_fitgauss { visuNo x y } {

   global private

   set err [catch {set bufNo [::confVisu::getBufNo $visuNo ]} msg]
   if {$err} { set bufNo 1 }

   set xs0 [expr int($x - $private(psf_toolbox,$visuNo,radius))]
   set ys0 [expr int($y - $private(psf_toolbox,$visuNo,radius))]
   set xs1 [expr int($x + $private(psf_toolbox,$visuNo,radius))]
   set ys1 [expr int($y + $private(psf_toolbox,$visuNo,radius))]
   set box [list $xs0 $ys0 $xs1 $ys1]
   set r [ buf$bufNo fitgauss $box ]
   set private(psf_toolbox,$visuNo,psf,xsm)       [format "%.4f" [lindex $r 1] ]
   set private(psf_toolbox,$visuNo,psf,ysm)       [format "%.4f" [lindex $r 5] ]
   set private(psf_toolbox,$visuNo,psf,err_xsm)   "-"
   set private(psf_toolbox,$visuNo,psf,err_ysm)   "-"
   set private(psf_toolbox,$visuNo,psf,fwhmx)     [format "%.2f" [lindex $r 2] ]
   set private(psf_toolbox,$visuNo,psf,fwhmy)     [format "%.2f" [lindex $r 6] ]
   set private(psf_toolbox,$visuNo,psf,fwhm)      [format "%.2f" [expr sqrt ( ( pow ( [lindex $r 2],2 ) + pow ( [lindex $r 6],2 ) ) / 2.0 ) ] ]
   set private(psf_toolbox,$visuNo,psf,flux)      "-"
   set private(psf_toolbox,$visuNo,psf,err_flux)  "-"
   set private(psf_toolbox,$visuNo,psf,pixmax)    "-"
   set private(psf_toolbox,$visuNo,psf,intensity) [format "%.2f" [expr sqrt ( ( pow ( [lindex $r 0],2 ) + pow ( [lindex $r 4],2 ) ) / 2.0 ) ] ]
   set private(psf_toolbox,$visuNo,psf,sky)       [format "%.2f" [expr sqrt ( ( pow ( [lindex $r 3],2 ) + pow ( [lindex $r 7],2 ) ) / 2.0 ) ] ]
   set private(psf_toolbox,$visuNo,psf,err_sky)   "-"
   set private(psf_toolbox,$visuNo,psf,snint)     "-"
   set private(psf_toolbox,$visuNo,psf,radius)    "-"
   set private(psf_toolbox,$visuNo,psf,err_psf)   "-"
   return
}

#------------------------------------------------------------
## Fonction qui mesure le photocentre d'une source
# suivant la methode fournit par l appel a
# buf1 fitgauss pour la postion et buf1 photom pour la
# photometrie
#
# @brief Normalisation des donnees resultats
#
# @param visuNo
# @param x : coordonnee pixel de la source dans l'image
# @param y : coordonnee pixel de la source dans l'image
#
proc ::audace::PSF_method_photom { visuNo x y } {
   global private

   set err [catch {set bufNo [::confVisu::getBufNo $visuNo ]} msg]
   if {$err} { set bufNo 1 }

   set xs0 [expr int($x - $private(psf_toolbox,$visuNo,radius))]
   set ys0 [expr int($y - $private(psf_toolbox,$visuNo,radius))]
   set xs1 [expr int($x + $private(psf_toolbox,$visuNo,radius))]
   set ys1 [expr int($y + $private(psf_toolbox,$visuNo,radius))]
   set box [list $xs0 $ys0 $xs1 $ys1]
   set r [ buf$bufNo fitgauss $box ]
   set r1  [expr int($private(psf_toolbox,$visuNo,photom,r1) * $private(psf_toolbox,$visuNo,radius))]
   set r2  [expr int($private(psf_toolbox,$visuNo,photom,r2) * $private(psf_toolbox,$visuNo,radius))]
   set r3  [expr int($private(psf_toolbox,$visuNo,photom,r3) * $private(psf_toolbox,$visuNo,radius))]

   if {$private(psf_toolbox,$visuNo,gui)} {
      ::console::affiche_resultat "buf$bufNo photom $box square $r1 $r2 $r3\n"
   }

   set err [ catch { set photom [buf$bufNo photom $box square $r1 $r2 $r3 ] } msg ]
   if {$err} {
      set private(psf_toolbox,$visuNo,psf,err_psf)  "Erreur buf photom"
      return -code -1 "Erreur buf photom : $msg"
   }
   set err [ catch { set stat [buf$bufNo stat $box ] } msg ]
   if {$err} {
      set private(psf_toolbox,$visuNo,psf,err_psf)  "Erreur buf stat"
      return -code -1 "Erreur buf stat : $stat"
   }
   set npix [expr ($xs1 - $xs0 + 1) * ($ys1 - $ys0 + 1)]

   set private(psf_toolbox,$visuNo,psf,xsm)       [format "%.4f" [lindex $r 1] ]
   set private(psf_toolbox,$visuNo,psf,ysm)       [format "%.4f" [lindex $r 5] ]
   set private(psf_toolbox,$visuNo,psf,err_xsm)   "-"
   set private(psf_toolbox,$visuNo,psf,err_ysm)   "-"
   set private(psf_toolbox,$visuNo,psf,fwhmx)     [format "%.2f" [lindex $r 2] ]
   set private(psf_toolbox,$visuNo,psf,fwhmy)     [format "%.2f" [lindex $r 6] ]
   set private(psf_toolbox,$visuNo,psf,fwhm)      [format "%.2f" [expr sqrt ( ( pow ( [lindex $r 2],2 ) + pow ( [lindex $r 6],2 ) ) / 2.0 ) ] ]
   set private(psf_toolbox,$visuNo,psf,flux)      [format "%.2f" [lindex $photom 0] ]
   set private(psf_toolbox,$visuNo,psf,err_flux)  "-"
   set private(psf_toolbox,$visuNo,psf,pixmax)    [format "%.2f" [lindex $stat 2] ]
   set private(psf_toolbox,$visuNo,psf,intensity) [format "%.2f" [expr [lindex $stat 2] - [lindex $photom 2] ] ]
   set private(psf_toolbox,$visuNo,psf,sky)       [format "%.2f" [lindex $photom 2] ]
   set private(psf_toolbox,$visuNo,psf,err_sky)   [format "%.2f" [lindex $photom 3] ]
   set private(psf_toolbox,$visuNo,psf,snint)     [format "%.2f" [expr [lindex $photom 0] / sqrt ([lindex $photom 0]+[lindex $photom 4]*[lindex $photom 2] ) ] ]
   set private(psf_toolbox,$visuNo,psf,radius)    $private(psf_toolbox,$visuNo,radius)
   set private(psf_toolbox,$visuNo,psf,err_psf)   "-"
   return
}

#------------------------------------------------------------
## Fonction qui mesure le photocentre d'une source
# suivant la methode fournit par l appel a
# buf1 fitgauss2d
#
# @brief Normalisation des donnees resultats
#
# @param visuNo
# @param x : coordonnee pixel de la source dans l'image
# @param y : coordonnee pixel de la source dans l'image
#
proc ::audace::PSF_method_fitgauss2D { visuNo x y } {
   global private

   set err [catch {set bufNo [::confVisu::getBufNo $visuNo ]} msg]
   if {$err} { set bufNo 1 }

   set xs0 [expr int($x - $private(psf_toolbox,$visuNo,radius))]
   set ys0 [expr int($y - $private(psf_toolbox,$visuNo,radius))]
   set xs1 [expr int($x + $private(psf_toolbox,$visuNo,radius))]
   set ys1 [expr int($y + $private(psf_toolbox,$visuNo,radius))]
   set box [list $xs0 $ys0 $xs1 $ys1]

   if {$private(psf_toolbox,$visuNo,gui)} {
      ::console::affiche_resultat "buf$bufNo fitgauss2d $box\n"
   }

   set r [buf$bufNo fitgauss2d $box]

   set err [ catch { set stat [buf$bufNo stat $box] } msg ]
   if {$err} {
      set private(psf_toolbox,$visuNo,psf,err_psf)  "Erreur buf stat"
      return -code -1 "Erreur buf stat : $stat"
   }
   set npix [expr ($xs1 - $xs0 + 1) * ($ys1 - $ys0 + 1)]

   set private(psf_toolbox,$visuNo,psf,xsm)       [format "%.4f" [lindex $r 1] ]
   set private(psf_toolbox,$visuNo,psf,ysm)       [format "%.4f" [lindex $r 5] ]
   set private(psf_toolbox,$visuNo,psf,err_xsm)   "-"
   set private(psf_toolbox,$visuNo,psf,err_ysm)   "-"
   set private(psf_toolbox,$visuNo,psf,fwhmx)     [format "%.2f" [lindex $r 2] ]
   set private(psf_toolbox,$visuNo,psf,fwhmy)     [format "%.2f" [lindex $r 6] ]
   set private(psf_toolbox,$visuNo,psf,fwhm)      [format "%.2f" [expr sqrt ( ( pow ( [lindex $r 2],2 ) + pow ( [lindex $r 6],2 ) ) / 2.0 ) ] ]
   set private(psf_toolbox,$visuNo,psf,flux)      [format "%.2f" [expr (([lindex $r 0])+([lindex $r 4])) / 2. * 2 * 3.14159265359 * [lindex $r 2] * [lindex $r 6] / 2.35482 / 2.35482] ]
   set private(psf_toolbox,$visuNo,psf,err_flux)  "-"
   set private(psf_toolbox,$visuNo,psf,pixmax)    [format "%.2f" [lindex $stat 2] ]
   set private(psf_toolbox,$visuNo,psf,intensity) [format "%.2f" [expr sqrt ( ( pow ( [lindex $r 0],2 ) + pow ( [lindex $r 4],2 ) ) / 2.0 ) ] ]
   set private(psf_toolbox,$visuNo,psf,sky)       [format "%.2f" [expr sqrt ( ( pow ( [lindex $r 3],2 ) + pow ( [lindex $r 7],2 ) ) / 2.0 ) ] ]
   set private(psf_toolbox,$visuNo,psf,err_sky)   "-"
   set private(psf_toolbox,$visuNo,psf,snint)     [format "%.2f" [expr $private(psf_toolbox,$visuNo,psf,flux) / sqrt ($private(psf_toolbox,$visuNo,psf,flux)+$npix*$private(psf_toolbox,$visuNo,psf,sky) ) ] ]
   set private(psf_toolbox,$visuNo,psf,radius)    $private(psf_toolbox,$visuNo,radius)
   set private(psf_toolbox,$visuNo,psf,err_psf)   "-"
   return
}

#------------------------------------------------------------
## Fonction qui mesure le photocentre d'une source
# suivant la methode fournit par l appel a
# buf1 psfimcce
#
# @brief Normalisation des donnees resultats
#
# @param visuNo
# @param x : coordonnee pixel de la source dans l'image
# @param y : coordonnee pixel de la source dans l'image
#
proc ::audace::PSF_method_psfimcce { visuNo x y } {
   global private

   set err [catch {set bufNo [::confVisu::getBufNo $visuNo]} msg]
   if {$err} { set bufNo 1 }

   set xs0 [expr int($x - $private(psf_toolbox,$visuNo,radius))]
   set ys0 [expr int($y - $private(psf_toolbox,$visuNo,radius))]
   set xs1 [expr int($x + $private(psf_toolbox,$visuNo,radius))]
   set ys1 [expr int($y + $private(psf_toolbox,$visuNo,radius))]
   set box [list $xs0 $ys0 $xs1 $ys1]

   if {$private(psf_toolbox,$visuNo,gui)} {
      ::console::affiche_resultat "buf$bufNo psfimcce $box\n"
   }

   set r [buf$bufNo psfimcce $box]
   set private(psf_toolbox,$visuNo,psf,xsm)       [format "%.4f" [lindex $r 0] ]
   set private(psf_toolbox,$visuNo,psf,ysm)       [format "%.4f" [lindex $r 1] ]
   set private(psf_toolbox,$visuNo,psf,err_xsm)   "-"
   set private(psf_toolbox,$visuNo,psf,err_ysm)   "-"
   set private(psf_toolbox,$visuNo,psf,fwhmx)     [format "%.2f" [lindex $r 4] ]
   set private(psf_toolbox,$visuNo,psf,fwhmy)     [format "%.2f" [lindex $r 5] ]
   set private(psf_toolbox,$visuNo,psf,fwhm)      [format "%.2f" [lindex $r 6] ]
   set private(psf_toolbox,$visuNo,psf,flux)      [format "%.1f" [lindex $r 7] ]
   set private(psf_toolbox,$visuNo,psf,err_flux)  "-"
   set private(psf_toolbox,$visuNo,psf,pixmax)    [format "%d" [expr int([lindex $r 9])] ]
   set private(psf_toolbox,$visuNo,psf,intensity) [format "%.2f" [lindex $r 10] ]
   set private(psf_toolbox,$visuNo,psf,sky)       [format "%.2f" [lindex $r 11] ]
   set private(psf_toolbox,$visuNo,psf,err_sky)   "-"

   set err [catch {set private(psf_toolbox,$visuNo,psf,snint) [format "%.2f" [lindex $r 13] ]} msg]
   if {$err} { set private(psf_toolbox,$visuNo,psf,snint) nan }

   set private(psf_toolbox,$visuNo,psf,radius)    [format "%d" [lindex $r 14] ]

   if {[lindex $r 15] == 0} {
      set private(psf_toolbox,$visuNo,psf,err_psf)   "-"
   } else {
      set private(psf_toolbox,$visuNo,psf,err_psf) [format "%s" [lindex $r 15] ]
   }
   if {$private(psf_toolbox,$visuNo,psf,snint)==nan} { set private(psf_toolbox,$visuNo,psf,err_psf) "snint" }
   if {$private(psf_toolbox,$visuNo,psf,flux)<0} { set private(psf_toolbox,$visuNo,psf,err_psf) "negative flux" }
}








proc ::audace::psf_toolbox_set_format { x fmt } {

   if {$x eq "nan" || $x eq "-nan"} {
      return "-1"
   }

   set err [ catch { set a [format $fmt $x] } ]
   if {$err} {
      return $x
   } else {
      return $a
   }
}

#------------------------------------------------------------
## Fonction qui mesure le photocentre d'une source
# suivant la methode fournit par l appel a
# buf1 PSF_method_psfgaussian2d
#
# @brief Normalisation des donnees resultats
#
# @param visuNo
# @param x : coordonnee pixel de la source dans l'image
# @param y : coordonnee pixel de la source dans l'image
#
proc ::audace::PSF_method_psfgaussian2d { visuNo x y } {

   global private
   global private_graph

   set err [catch {set bufNo [::confVisu::getBufNo $visuNo]} msg]
   if {$err} { set bufNo 1 }

#-radius_max $radius_max
#-saturation_limit $saturation_limit
#-read_out_noise $read_out_noise
#-position_threshold $position_threshold
#-number_successive_errors $number_successive_errors
#-confidence_level $confidence_level
#-graph
#-gaussian_statistics

   set cmd "buf$bufNo psfgaussian2d $x $y"

   if {$private(psf_toolbox,$visuNo,globale)==0} {
      append cmd " $private(psf_toolbox,$visuNo,radius)"
   } else {
      append cmd " $private(psf_toolbox,$visuNo,globale,min)"
      append cmd " -radius_max $private(psf_toolbox,$visuNo,globale,max)"
      if {$private(psf_toolbox,$visuNo,globale,arret)==1} {
         append cmd " -number_successive_errors $private(psf_toolbox,$visuNo,globale,nberror)"
      }
      append cmd " -confidence_level $private(psf_toolbox,$visuNo,globale,confidence)"
   }

   if {$private(psf_toolbox,$visuNo,ecretage)==1} {
      append cmd " -saturation_limit $private(psf_toolbox,$visuNo,saturation)"
      append cmd " -position_threshold $private(psf_toolbox,$visuNo,threshold)"
   }

   if {$private(psf_toolbox,$visuNo,gaussian_statistics)==1} {
      append cmd " -gaussian_statistics"
   } else {
      append cmd " -read_out_noise $private(psf_toolbox,$visuNo,read_out_noise)"
   }

   if {$private(psf_toolbox,$visuNo,graph)} {
      append cmd " -graph"
   }

   if {$private(psf_toolbox,$visuNo,gui)} {
      ::console::affiche_resultat "$cmd\n"
   }

   set err [catch {set r [eval $cmd]} msg]
   if {$err} {
      set private(psf_toolbox,$visuNo,psf,err_psf) $msg
      ::console::affiche_erreur "$msg"
      return
   }

   #  0  photoCenterX,          261.429569
   #  1  photoCenterY,          540.084074
   #  2  photoCenterXError,     0.000282
   #  3  photoCenterYError,     0.000269
   #  4  fwhmX,                 3.460519
   #  5  fwhmY,                 3.293034
   #  6  fwhm,                  3.377814
   #  7  totalFlux,             37423.391
   #  8  totalFluxError,        10.196
   #  9  maximumIntensity,      3290.000
   # 10  intensity,             2898.287
   # 11  sky,                   206.158
   # 12  skyError,              0.012
   # 13  signalToNoiseRatio,    193.451
   # 14  radius,                48
   # 15  doesDiverge,           0
   # 16  intensityError,        0.557
   # 17  theta,                 3.189
   # 18  thetaError,            0.003
   # 19  FwhmXError,            0.001
   # 20  FwhmYError             0.001
   # 21  list of radii          { { ... } { ... } ... }

   set private(psf_toolbox,$visuNo,psf,xsm)            [psf_toolbox_set_format [lindex $r  0] "%.4f"] ;#  photoCenterX,
   set private(psf_toolbox,$visuNo,psf,ysm)            [psf_toolbox_set_format [lindex $r  1] "%.4f"] ;#  photoCenterY,
   set private(psf_toolbox,$visuNo,psf,err_xsm)        [psf_toolbox_set_format [lindex $r  2] "%.4f"] ;#  photoCenterXError,
   set private(psf_toolbox,$visuNo,psf,err_ysm)        [psf_toolbox_set_format [lindex $r  3] "%.4f"] ;#  photoCenterYError,
   set private(psf_toolbox,$visuNo,psf,fwhmx)          [psf_toolbox_set_format [lindex $r  4] "%.2f"] ;#  fwhmX,
   set private(psf_toolbox,$visuNo,psf,fwhmy)          [psf_toolbox_set_format [lindex $r  5] "%.2f"] ;#  fwhmY,
   set private(psf_toolbox,$visuNo,psf,fwhm)           [psf_toolbox_set_format [lindex $r  6] "%.2f"] ;#  fwhm,
   set private(psf_toolbox,$visuNo,psf,flux)           [psf_toolbox_set_format [lindex $r  7] "%.1f"] ;#  totalFlux,
   set private(psf_toolbox,$visuNo,psf,err_flux)       [psf_toolbox_set_format [lindex $r  8] "%.1f"] ;#  totalFluxError,
   set private(psf_toolbox,$visuNo,psf,pixmax)         [psf_toolbox_set_format [lindex $r  9] "%.1f"] ;#  maximumIntensity,
   set private(psf_toolbox,$visuNo,psf,intensity)      [psf_toolbox_set_format [lindex $r 10] "%.1f"] ;#  intensity,
   set private(psf_toolbox,$visuNo,psf,sky)            [psf_toolbox_set_format [lindex $r 11] "%.1f"] ;#  sky,
   set private(psf_toolbox,$visuNo,psf,err_sky)        [psf_toolbox_set_format [lindex $r 12] "%.1f"] ;#  skyError,
   set private(psf_toolbox,$visuNo,psf,snint)          [psf_toolbox_set_format [lindex $r 13] "%.1f"] ;#  signalToNoiseRatio,
   set private(psf_toolbox,$visuNo,psf,radius)         [psf_toolbox_set_format [lindex $r 14]   "%d"] ;#  radius,
   set private(psf_toolbox,$visuNo,psf,diverge)        [psf_toolbox_set_format [lindex $r 15]   "%d"] ;#  doesDiverge,
   set private(psf_toolbox,$visuNo,psf,err_intensity)  [psf_toolbox_set_format [lindex $r 16] "%.4f"] ;#  intensityError,
   set private(psf_toolbox,$visuNo,psf,theta)          [psf_toolbox_set_format [lindex $r 17] "%.4f"] ;#  theta,
   set private(psf_toolbox,$visuNo,psf,err_theta)      [psf_toolbox_set_format [lindex $r 18] "%.4f"] ;#  thetaError,
   set private(psf_toolbox,$visuNo,psf,err_fwhmx)      [psf_toolbox_set_format [lindex $r 19] "%.4f"] ;#  FwhmXError,
   set private(psf_toolbox,$visuNo,psf,err_fwhmy)      [psf_toolbox_set_format [lindex $r 20] "%.4f"] ;#  FwhmYError

   if {$private(psf_toolbox,$visuNo,psf,diverge) == 0} {
      set private(psf_toolbox,$visuNo,psf,err_psf)   "-"
   } else {
      set private(psf_toolbox,$visuNo,psf,err_psf) "diverge"
   }
   if {$private(psf_toolbox,$visuNo,psf,flux)<0} { set private(psf_toolbox,$visuNo,psf,err_psf) "negative flux" }

   # Option Graph activee
   #::console::affiche_resultat "NB args = [llength $r]\n"
   if {[llength $r] == 22 && $private(psf_toolbox,$visuNo,graph)} {
      set r [lindex $r  21]
      set private_graph(list_radius) ""
      #::console::affiche_resultat "radius= "
      foreach l $r {
         set radius [lindex $l 14]
         #::console::affiche_resultat "$radius"
         set private_graph($radius,xsm)           [lindex $l  0]
         set private_graph($radius,ysm)           [lindex $l  1]
         set private_graph($radius,err_xsm)       [lindex $l  2]
         set private_graph($radius,err_ysm)       [lindex $l  3]
         set private_graph($radius,fwhmx)         [lindex $l  4]
         set private_graph($radius,fwhmy)         [lindex $l  5]
         set private_graph($radius,fwhm)          [lindex $l  6]
         set private_graph($radius,flux)          [lindex $l  7]
         set private_graph($radius,err_flux)      [lindex $l  8]
         set private_graph($radius,pixmax)        [lindex $l  9]
         set private_graph($radius,intensity)     [lindex $l 10]
         set private_graph($radius,sky)           [lindex $l 11]
         set private_graph($radius,err_sky)       [lindex $l 12]
         set private_graph($radius,snint)         [lindex $l 13]
         set private_graph($radius,radius)        [lindex $l 14]
         set private_graph($radius,err_psf)       [lindex $l 15]
         lappend private_graph(list_radius)       $radius
      }
      #::console::affiche_resultat "\n"
   }
}

#------------------------------------------------------------
## Fonction qui mesure le photocentre d'une source
# suivant la methode fournit par l appel a
# buf1 PSF_method_psfmoffat
#
# @brief Normalisation des donnees resultats
#
# @param visuNo
# @param x : coordonnee pixel de la source dans l'image
# @param y : coordonnee pixel de la source dans l'image
#
proc ::audace::PSF_method_psfmoffat { visuNo x y } {
   global private
   global private_graph

   set err [catch {set bufNo [::confVisu::getBufNo $visuNo]} msg]
   if {$err} { set bufNo 1 }

#-radius_max $radius_max
#-saturation_limit $saturation_limit
#-read_out_noise $read_out_noise
#-position_threshold $position_threshold
#-number_successive_errors $number_successive_errors
#-confidence_level $confidence_level
#-graph $graph
#-beta $beta

   set cmd "buf$bufNo psfmoffat $x $y"

   if {$private(psf_toolbox,$visuNo,globale)==0} {
      append cmd " $private(psf_toolbox,$visuNo,radius)"
   } else {
      append cmd " $private(psf_toolbox,$visuNo,globale,min)"
      append cmd " -radius_max $private(psf_toolbox,$visuNo,globale,max)"
      if {$private(psf_toolbox,$visuNo,globale,arret)==1} {
         append cmd " -number_successive_errors $private(psf_toolbox,$visuNo,globale,nberror)"
      }
      append cmd " -confidence_level $private(psf_toolbox,$visuNo,globale,confidence)"
   }

   if {$private(psf_toolbox,$visuNo,ecretage)==1} {
      append cmd " -saturation_limit $private(psf_toolbox,$visuNo,saturation)"
      append cmd " -position_threshold $private(psf_toolbox,$visuNo,threshold)"
   }

   if {$private(psf_toolbox,$visuNo,ajust_beta)==0} {
      append cmd " -beta $private(psf_toolbox,$visuNo,beta)"
      set nbreturn 22
   } else {
      set nbreturn 24
   }

   if {$private(psf_toolbox,$visuNo,gaussian_statistics)==1} {
      append cmd " -gaussian_statistics"
   } else {
      append cmd " -read_out_noise $private(psf_toolbox,$visuNo,read_out_noise)"
   }

   if {$private(psf_toolbox,$visuNo,graph)} {
      append cmd " -graph"
   }

   if {$private(psf_toolbox,$visuNo,gui)} {
      ::console::affiche_resultat "$cmd\n"
   }

   set err [catch {set r [eval $cmd]} msg]
   if {$err} {
      set private(psf_toolbox,$visuNo,psf,err_psf) $msg
      ::console::affiche_erreur "$msg"
      return
   }

   #  0  photoCenterX,          261.429569
   #  1  photoCenterY,          540.084074
   #  2  photoCenterXError,     0.000282
   #  3  photoCenterYError,     0.000269
   #  4  fwhmX,                 3.460519
   #  5  fwhmY,                 3.293034
   #  6  fwhm,                  3.377814
   #  7  totalFlux,             37423.391
   #  8  totalFluxError,        10.196
   #  9  maximumIntensity,      3290.000
   # 10  intensity,             2898.287
   # 11  sky,                   206.158
   # 12  skyError,              0.012
   # 13  signalToNoiseRatio,    193.451
   # 14  radius,                48
   # 15  doesDiverge,           0
   # 16  intensityError,        0.557
   # 17  theta,                 3.189
   # 18  thetaError,            0.003
   # 19  FwhmXError,            0.001
   # 20  FwhmYError             0.001
   # 21  beta                   -6.517 (cas ou le beta n est pas donn知n parametre)
   # 22  betaError              0.036  (cas ou le beta n est pas donn知n parametre)
   # 23  list of radii          { { ... } { ... } ... }

   set private(psf_toolbox,$visuNo,psf,xsm)            [psf_toolbox_set_format [lindex $r  0] "%.4f"] ;#  photoCenterX,
   set private(psf_toolbox,$visuNo,psf,ysm)            [psf_toolbox_set_format [lindex $r  1] "%.4f"] ;#  photoCenterY,
   set private(psf_toolbox,$visuNo,psf,err_xsm)        [psf_toolbox_set_format [lindex $r  2] "%.4f"] ;#  photoCenterXError,
   set private(psf_toolbox,$visuNo,psf,err_ysm)        [psf_toolbox_set_format [lindex $r  3] "%.4f"] ;#  photoCenterYError,
   set private(psf_toolbox,$visuNo,psf,fwhmx)          [psf_toolbox_set_format [lindex $r  4] "%.2f"] ;#  fwhmX,
   set private(psf_toolbox,$visuNo,psf,fwhmy)          [psf_toolbox_set_format [lindex $r  5] "%.2f"] ;#  fwhmY,
   set private(psf_toolbox,$visuNo,psf,fwhm)           [psf_toolbox_set_format [lindex $r  6] "%.2f"] ;#  fwhm,
   set private(psf_toolbox,$visuNo,psf,flux)           [psf_toolbox_set_format [lindex $r  7] "%.1f"] ;#  totalFlux,
   set private(psf_toolbox,$visuNo,psf,err_flux)       [psf_toolbox_set_format [lindex $r  8] "%.1f"] ;#  totalFluxError,
   set private(psf_toolbox,$visuNo,psf,pixmax)         [psf_toolbox_set_format [lindex $r  9] "%.1f"] ;#  maximumIntensity,
   set private(psf_toolbox,$visuNo,psf,intensity)      [psf_toolbox_set_format [lindex $r 10] "%.1f"] ;#  intensity,
   set private(psf_toolbox,$visuNo,psf,sky)            [psf_toolbox_set_format [lindex $r 11] "%.1f"] ;#  sky,
   set private(psf_toolbox,$visuNo,psf,err_sky)        [psf_toolbox_set_format [lindex $r 12] "%.1f"] ;#  skyError,
   set private(psf_toolbox,$visuNo,psf,snint)          [psf_toolbox_set_format [lindex $r 13] "%.1f"] ;#  signalToNoiseRatio,
   set private(psf_toolbox,$visuNo,psf,radius)         [psf_toolbox_set_format [lindex $r 14]   "%d"] ;#  radius,
   set private(psf_toolbox,$visuNo,psf,diverge)        [psf_toolbox_set_format [lindex $r 15]   "%d"] ;#  doesDiverge,
   set private(psf_toolbox,$visuNo,psf,err_intensity)  [psf_toolbox_set_format [lindex $r 16] "%.4f"] ;#  intensityError,
   set private(psf_toolbox,$visuNo,psf,theta)          [psf_toolbox_set_format [lindex $r 17] "%.4f"] ;#  theta,
   set private(psf_toolbox,$visuNo,psf,err_theta)      [psf_toolbox_set_format [lindex $r 18] "%.4f"] ;#  thetaError,
   set private(psf_toolbox,$visuNo,psf,err_fwhmx)      [psf_toolbox_set_format [lindex $r 19] "%.4f"] ;#  FwhmXError,
   set private(psf_toolbox,$visuNo,psf,err_fwhmy)      [psf_toolbox_set_format [lindex $r 20] "%.4f"] ;#  FwhmYError

   if {$private(psf_toolbox,$visuNo,ajust_beta)==1} {
      set private(psf_toolbox,$visuNo,psf,beta)           [psf_toolbox_set_format [lindex $r 21] "%.4f"] ;#  FwhmYError
      set private(psf_toolbox,$visuNo,psf,err_beta)       [psf_toolbox_set_format [lindex $r 22] "%.4f"] ;#  FwhmYError
   }

   if {$private(psf_toolbox,$visuNo,psf,diverge) == 0} {
      set private(psf_toolbox,$visuNo,psf,err_psf)   "-"
   } else {
      set private(psf_toolbox,$visuNo,psf,err_psf) "diverge"
   }
   if {$private(psf_toolbox,$visuNo,psf,flux)<0} { set private(psf_toolbox,$visuNo,psf,err_psf) "negative flux" }

   # Option Graph activee
   #::console::affiche_resultat "NB args = [llength $r] == $nbreturn\n"
   if {[llength $r] == $nbreturn && $private(psf_toolbox,$visuNo,graph)} {
      set r [lindex $r [expr $nbreturn-1]]
      set private_graph(list_radius) ""
      #::console::affiche_resultat "radius= "
      foreach l $r {
         set radius [lindex $l 14]
         #::console::affiche_resultat "$radius"
         set private_graph($radius,xsm)           [lindex $l  0]
         set private_graph($radius,ysm)           [lindex $l  1]
         set private_graph($radius,err_xsm)       [lindex $l  2]
         set private_graph($radius,err_ysm)       [lindex $l  3]
         set private_graph($radius,fwhmx)         [lindex $l  4]
         set private_graph($radius,fwhmy)         [lindex $l  5]
         set private_graph($radius,fwhm)          [lindex $l  6]
         set private_graph($radius,flux)          [lindex $l  7]
         set private_graph($radius,err_flux)      [lindex $l  8]
         set private_graph($radius,pixmax)        [lindex $l  9]
         set private_graph($radius,intensity)     [lindex $l 10]
         set private_graph($radius,sky)           [lindex $l 11]
         set private_graph($radius,err_sky)       [lindex $l 12]
         set private_graph($radius,snint)         [lindex $l 13]
         set private_graph($radius,radius)        [lindex $l 14]
         set private_graph($radius,err_psf)       [lindex $l 15]
         lappend private_graph(list_radius)       $radius
      }
      #::console::affiche_resultat "\n"
   }
}

#------------------------------------------------------------
## @brief mesure le photocentre d'une source
#  pour un seul rayon de mesure et ne fournissant que les
#  positions X Y pixel dans l image.
#  @remark Cette fonction dialogue avec une GUI ou non
#  @param visuNo numéro de la visu
#  @param x : coordonnée pixel de la source dans l'image
#  @param y : coordonnée pixel de la source dans l'image
#
proc ::audace::PSF_one_radius { visuNo x y } {
   global private

   # Valeur d'initialisation pour que la variable existe
   set private(psf_toolbox,$visuNo,psf,rdiff) 0

   # duree du traitement
   if { $private(psf_toolbox,$visuNo,globale) == 0 } {
      set tt0 [clock clicks -milliseconds]
   }

   # Mode GUI
   if {$private(psf_toolbox,$visuNo,gui)} {

      # Effacement des marques
      $private(psf_toolbox,$visuNo,hcanvas) delete mesurePSF

      # Recupere la boite selectionnee dans la visu
      set private(center,box) [ ::confVisu::getBox $visuNo ]
      if { $private(center,box) == "" } {
         return
      }

   }

   set err [catch {set bufNo [::confVisu::getBufNo $visuNo ]} msg]
   if {$err} { set bufNo 1 }
   set naxis1 [lindex [buf$bufNo getkwd NAXIS1] 1]
   set naxis2 [lindex [buf$bufNo getkwd NAXIS2] 1]
   if {$x>1 && $x<$naxis1 && $y>1 && $y<$naxis2 } {
      # ok
   } else {
      # erreur
      #::console::affiche_resultat "Erreur PSF_one_radius : $x $y \n"
      set private(psf_toolbox,$visuNo,psf,err_psf) "Out of image"
      return
   }

   # Appel des methodes
   switch $private(psf_toolbox,$visuNo,methode) {

      "fitgauss"      { ::audace::PSF_method_fitgauss        $visuNo $x $y }
      "photom"        { ::audace::PSF_method_photom          $visuNo $x $y }
      "fitgauss2D"    { ::audace::PSF_method_fitgauss2D      $visuNo $x $y }
      "psfimcce"      { ::audace::PSF_method_psfimcce        $visuNo $x $y }
      "psfgaussian2d" { ::audace::PSF_method_psfgaussian2d   $visuNo $x $y }
      "psfmoffat"     { ::audace::PSF_method_psfmoffat       $visuNo $x $y }
      default         { ::audace::PSF_method_psfgaussian2d   $visuNo $x $y }
   }

   # Ecretage
   set private(psf_toolbox,$visuNo,psf,rdiff) [format "%.2f" [expr sqrt((($private(psf_toolbox,$visuNo,psf,xsm)-$x)**2 + ($private(psf_toolbox,$visuNo,psf,ysm)-$y)**2)) / 2.0]]

   if { $private(psf_toolbox,$visuNo,ecretage) == 1 } {

      if { $private(psf_toolbox,$visuNo,psf,rdiff) > $private(psf_toolbox,$visuNo,threshold) } {
         set private(psf_toolbox,$visuNo,psf,err_psf) "Too Far"
      }

      if { $private(psf_toolbox,$visuNo,psf,pixmax) > $private(psf_toolbox,$visuNo,saturation) } {
         set private(psf_toolbox,$visuNo,psf,err_psf) "Saturated"
      }
   }

   # Mode GUI
   if {$private(psf_toolbox,$visuNo,gui)} {

      # Affichage des cercles
      if { $private(psf_toolbox,$visuNo,marks,cercle) == 1 } {
         ::audace::psf_display_circle $visuNo $private(psf_toolbox,$visuNo,psf,xsm) \
                           $private(psf_toolbox,$visuNo,psf,ysm) $private(psf_toolbox,$visuNo,radius) \
                           green mesurePSF
      }

   }

   # duree du traitement
   if { $private(psf_toolbox,$visuNo,globale) == 0 } {
      set private(psf_toolbox,$visuNo,duree) [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.] ]
   }

   return
}

proc ::audace::calcule_solution { visuNo } {

   global private
   global private_graph
   global caption

   set sky   ""
   set flux  ""
   set mean  ""
   set stdev ""

   for {set radius $private(psf_toolbox,$visuNo,globale,min)} {$radius <= $private(psf_toolbox,$visuNo,globale,max)} {incr radius} {
      if {[info exists private_graph($radius,sky)]} {
         lappend sky  [list $radius $private_graph($radius,sky)]
         lappend flux [list $radius $private_graph($radius,flux)]
      }
   }
   set sky [lsort -index 1  -real -increasing $sky]
   set n [expr [llength $sky]/2]
   set zsky [lrange $sky 0 $n]
   set data ""
   foreach v $zsky {
      lappend data [lindex $v 1]
   }
   set err [ catch {
      set mean [::math::statistics::mean $data]
      set stdev [::math::statistics::stdev $data]
   } msg ]

   if { $err } {
      #set err [ catch { ::console::affiche_erreur "$caption(audace,psf_toolbox_message3)\n (Err msg: $msg)\n" } msg2 ]
      #if { $err } {
      #   ::console::affiche_erreur "$caption(audace,psf_toolbox_message3) (Err msg: $msg)\n"
      #}
      #set nbdata [llength $data]
      #::console::affiche_erreur "nb data = $nbdata\n"
      #for {set radius $private(psf_toolbox,$visuNo,globale,min)} {$radius <= $private(psf_toolbox,$visuNo,globale,max)} {incr radius} {
      #   ::console::affiche_erreur "$radius  Err  $private_graph($radius,err_psf) \n"
      #}
      return ""
   }

   if { $stdev == "" } {
   
      set list_radius ""
      foreach v $sky {
         lappend list_radius [lindex $v 0]
      }

   } else {

      set limit [expr $mean + 3*$stdev]

      set list_radius ""
      foreach v $sky {
         if {[lindex $v 1]<$limit} {
            lappend list_radius [lindex $v 0]
         }
      }
   
   }

   # on calcule les moyennes et erreurs

   foreach key [::audace::get_fields_current_psf] {

      if {$key in [list  "err_xsm" "err_ysm" "err_flux" "err_sky" "radius"]} {continue}
      set data ""
      foreach radius $list_radius {
         if {[info exists private_graph($radius,$key)]} {
            lappend data $private_graph($radius,$key)
         }
      }
      if {$key == "err_psf"} {
         if {[llength $data]>0} {
            set private(psf_toolbox,$visuNo,psf,err_psf) "-"
         } else {
            set private(psf_toolbox,$visuNo,psf,err_psf) "Globale no data"
         }
         continue
      }
      set err [ catch {
         set max   [::math::statistics::max $data]
         set mean  [::math::statistics::mean $data]
         set stdev [::math::statistics::stdev $data]
      } msg ]

      if { $err } {
         ::console::affiche_erreur "determination de $key impossible\n"
         set private(psf_toolbox,$visuNo,psf,$key) "-"
         continue
      }

   if { $stdev == "" } {
      switch $key {
         "xsm" {
            set private(psf_toolbox,$visuNo,psf,xsm)      [format "%.4f" $mean]
            set private(psf_toolbox,$visuNo,psf,err_xsm)  "-"
         }
         "ysm" {
            set private(psf_toolbox,$visuNo,psf,ysm)      [format "%.4f" $mean]
            set private(psf_toolbox,$visuNo,psf,err_ysm)  "-"
         }
         "flux" {
            set private(psf_toolbox,$visuNo,psf,flux)     [format "%.2f" $mean]
            set private(psf_toolbox,$visuNo,psf,err_flux) "-"
         }
         "sky" {
            set private(psf_toolbox,$visuNo,psf,sky)      [format "%.2f" $mean]
            set private(psf_toolbox,$visuNo,psf,err_sky)  "-"
         }
         "fwhmx" - "fwhmy" - "fwhm" - "intensity" - "snint"  {
            set private(psf_toolbox,$visuNo,psf,$key)     [format "%.2f" $mean]
         }
         "pixmax" {
            set private(psf_toolbox,$visuNo,psf,$key)     [format "%d" [expr int($mean)] ]
         }
         "rdiff" {
            set private(psf_toolbox,$visuNo,psf,$key)     [format "%.2f" [expr int($max)] ]
         }
      }
   } else {
      switch $key {
         "xsm" {
            set private(psf_toolbox,$visuNo,psf,xsm)      [format "%.4f" $mean]
            set private(psf_toolbox,$visuNo,psf,err_xsm)  [format "%.4f" [expr 3.0 * $stdev] ]
         }
         "ysm" {
            set private(psf_toolbox,$visuNo,psf,ysm)      [format "%.4f" $mean]
            set private(psf_toolbox,$visuNo,psf,err_ysm)  [format "%.4f" [expr 3.0 * $stdev] ]
         }
         "flux" {
            set private(psf_toolbox,$visuNo,psf,flux)     [format "%.2f" $mean]
            set private(psf_toolbox,$visuNo,psf,err_flux) [format "%.2f" [expr 3.0 * $stdev] ]
         }
         "sky" {
            set private(psf_toolbox,$visuNo,psf,sky)      [format "%.2f" $mean]
            set private(psf_toolbox,$visuNo,psf,err_sky)  [format "%.2f" [expr 3.0 * $stdev] ]
         }
         "fwhmx" - "fwhmy" - "fwhm" - "intensity" - "snint"  {
            set private(psf_toolbox,$visuNo,psf,$key)     [format "%.2f" $mean]
         }
         "pixmax" {
            set private(psf_toolbox,$visuNo,psf,$key)     [format "%d" [expr int($mean)] ]
         }
         "rdiff" {
            set private(psf_toolbox,$visuNo,psf,$key)     [format "%.2f" [expr int($max)] ]
         }
      }
   }


   }

   # Calcul du rayon ideal
   if {$private(psf_toolbox,$visuNo,methode)!="fitgauss"} {
      set flux [lsort -index 0  -integer -increasing $flux]
      foreach v $flux {
         if {[lindex $v 1] > $private(psf_toolbox,$visuNo,psf,flux)} {
            set private(psf_toolbox,$visuNo,psf,radius) [lindex $v 0]
            break
         }
      }
   }

   return $list_radius
}

proc ::audace::suppression_par_distance_solution { visuNo } {
   global private
   global private_graph

   set sky  ""
   set flux ""
   set xsm  ""
   set ysm  ""
   for {set radius $private(psf_toolbox,$visuNo,globale,min)} {$radius <= $private(psf_toolbox,$visuNo,globale,max)} {incr radius} {
      if {[info exists private_graph($radius,sky)]} {
         lappend sky  [list $radius [expr abs($private_graph($radius,sky)-$private(psf_toolbox,$visuNo,psf,sky))]]
         lappend flux [list $radius [expr abs($private_graph($radius,flux)-$private(psf_toolbox,$visuNo,psf,flux))]]
         lappend xsm [list $radius [expr abs($private_graph($radius,xsm)-$private(psf_toolbox,$visuNo,psf,xsm))]]
         lappend ysm [list $radius [expr abs($private_graph($radius,ysm)-$private(psf_toolbox,$visuNo,psf,ysm))]]
      }
   }
   set nb   [llength $sky]
   set rm   [expr int($nb*(100.0 - $private(psf_toolbox,$visuNo,globale,confidence))/100.0)]
   set sky  [lsort -index 1 -real -decreasing $sky]
   set flux [lsort -index 1 -real -decreasing $flux]
   set xsm  [lsort -index 1 -real -decreasing $xsm]
   set ysm  [lsort -index 1 -real -decreasing $ysm]
   set lkeys [list sky flux xsm ysm]

   set lrm ""
   for {set i 0} {$i <$rm} { } {
      lappend lrm [lindex $sky  [list $i 0]]
      lappend lrm [lindex $flux [list $i 0]]
      lappend lrm [lindex $xsm  [list $i 0]]
      lappend lrm [lindex $ysm  [list $i 0]]
      incr i
   }
   set lrm2 ""
   set cpt 0
   foreach x $lrm {
      if {$x in $lrm2} {continue}
      lappend lrm2 $x
      incr cpt
      if {$cpt == $rm} {break}
   }
   foreach x $lrm2 {
      foreach key [::audace::get_fields_current_psf] {
         unset private_graph($x,$key)
      }
   }

   return
}

#------------------------------------------------------------
## @brief mesure le photocentre d'une source
#  pour un ensemble de rayons de mesure et ne fournissant
#  que les positions X Y pixel dans l'image.
#  @remark la variable globale private permet de fixer
#  les paramètres pour dialoguer avec une gui et/ou
#  stocker les résultats pour dessiner des graphes
#  @param visuNo numéro de la visu
#  @param x : coordonnée pixel de la source dans l'image
#  @param y : coordonnée pixel de la source dans l'image
#
proc ::audace::PSF_globale { visuNo x y } {

   global private
   global private_graph
   global caption

   array unset private_graph

   # duree du traitement
   set tt0 [clock clicks -milliseconds]

   # Mode GUI
   if {$private(psf_toolbox,$visuNo,gui)} {
      # Effacement des marques
      $private(psf_toolbox,$visuNo,hcanvas) delete globalePSF
   }

   # Mesure les photocentres
   switch $private(psf_toolbox,$visuNo,methode) {
      "psfgaussian2d" -
      "psfmoffat" {

         # methode de mesure ayant la methode globale en interne
         ::audace::PSF_one_radius $visuNo $x $y

         if {$private(psf_toolbox,$visuNo,gui)} {
            if {[info exists private_graph(list_radius)]} {
               set list_radius $private_graph(list_radius)
            } else {

            }
         }

      }
      default {

         # methode de mesure n'ayant pas la methode global en interne
         # on applique le methode globale ici dans le TCL

         set nberror 0
         for {set radius $private(psf_toolbox,$visuNo,globale,min)} {$radius <= $private(psf_toolbox,$visuNo,globale,max)} {incr radius} {

            set private(psf_toolbox,$visuNo,radius) $radius

            # Effectue une mesure
            ::audace::PSF_one_radius $visuNo $x $y

            if {$private(psf_toolbox,$visuNo,psf,err_psf)=="-"} {

               # Si ca marche le compteur d erreur consecutives retombent a zero
               set nberror 0

               # Recupere les donnees intermediaires
               foreach key [::audace::get_fields_current_psf] {
                  set private_graph($radius,$key) $private(psf_toolbox,$visuNo,psf,$key)
               }

            } else {
               incr nberror
            }

            # Mise a jour de la GUI
            if {$private(psf_toolbox,$visuNo,gui)} {
               update
            }

            # Arret si trop d erreurs
            if {$private(psf_toolbox,$visuNo,globale,arret) && $nberror>=$private(psf_toolbox,$visuNo,globale,nberror)} {
               if {$private(psf_toolbox,$visuNo,gui)} {
                  ::console::affiche_erreur "$caption(audace,psf_toolbox_message1) $nberror $caption(audace,psf_toolbox_message2)\n"
               }
               break
            }

         }

         if {$private(psf_toolbox,$visuNo,methode)!="fitgauss"} {
            # on supprime les valeurs dont le flux diminue en debut de courbe
            set cpt 0
            for {set radius $private(psf_toolbox,$visuNo,globale,min)} {$radius <= $private(psf_toolbox,$visuNo,globale,max)} {incr radius} {
               if {[info exists private_graph($radius,flux)]} {
                  incr cpt

                  # premier contact
                  if {$cpt==1} {
                     # gren_info "premier contact\n"
                     set flux $private_graph($radius,flux)
                     set last_radius $radius
                     continue
                  }

                  if {$private_graph($radius,flux)>$flux} {
                     # le flux est croissant, on sort
                     # gren_info "le flux est croissant, on sort\n"
                     break
                  } else {
                     # le flux est decroissant
                     # gren_info "le flux est decroissant\n"
                     foreach key [::audace::get_fields_current_psf] {
                        unset private_graph($last_radius,$key)
                     }
                     set flux $private_graph($radius,flux)
                     set last_radius $radius
                  }
               }
            }
         }

         # on cherche les meilleurs rayons
         # par critere sur le fond du ciel minimal
         set list_radius [calcule_solution $visuNo]

         # calcul des distances aux solutions de Flux
         if {$private(psf_toolbox,$visuNo,methode)!="fitgauss"} {
            suppression_par_distance_solution $visuNo
            set list_radius [calcule_solution $visuNo]
         }

      }

   }

   # Mode GUI
   if {$private(psf_toolbox,$visuNo,gui) && [info exists list_radius]} {

      # Affichage des marques
      if { $private(psf_toolbox,$visuNo,marks,cercle) == 1 } {

         $private(psf_toolbox,$visuNo,hcanvas) delete mesurePSF

         set list_radius [lsort -integer -increasing $list_radius]
         set radius [lindex $list_radius 0]
         if {$radius == $private(psf_toolbox,$visuNo,globale,min)} { incr radius }
         ::audace::psf_display_circle $visuNo $private(psf_toolbox,$visuNo,psf,xsm) \
                           $private(psf_toolbox,$visuNo,psf,ysm) $radius \
                           yellow globalePSF
         set radius [lindex $list_radius end]
         if {$radius == $private(psf_toolbox,$visuNo,globale,max)} { incr radius -1 }
         ::audace::psf_display_circle $visuNo $private(psf_toolbox,$visuNo,psf,xsm) \
                           $private(psf_toolbox,$visuNo,psf,ysm) $radius \
                           yellow globalePSF
         ::audace::psf_display_circle $visuNo $private(psf_toolbox,$visuNo,psf,xsm) \
                           $private(psf_toolbox,$visuNo,psf,ysm) $private(psf_toolbox,$visuNo,psf,radius) \
                           green globalePSF
         ::audace::psf_display_circle $visuNo $private(psf_toolbox,$visuNo,psf,xsm) \
                           $private(psf_toolbox,$visuNo,psf,ysm) $private(psf_toolbox,$visuNo,globale,min) \
                           blue globalePSF
         ::audace::psf_display_circle $visuNo $private(psf_toolbox,$visuNo,psf,xsm) \
                           $private(psf_toolbox,$visuNo,psf,ysm) $private(psf_toolbox,$visuNo,globale,max) \
                           blue globalePSF
      }
   }

   # duree du traitement
   set private(psf_toolbox,$visuNo,duree) [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.] ]
   return
}

#------------------------------------------------------------
## @brief affiche un graphique montrant l'évolution
#  d'un paramètre en fonction de la taille du rayon choisi.
#  @remark Cette fonction dialogue avec une GUI
#  @param visuNo numéto de la visu
#  @param key : paramètre que l'on veut grapher
#
proc ::audace::psf_graph { visuNo key } {

   global private
   global private_graph

   set x ""
   set y ""
   for {set radius $private(psf_toolbox,$visuNo,globale,min)} {$radius <= $private(psf_toolbox,$visuNo,globale,max)} {incr radius} {
      if {[info exists private_graph($radius,$key)]} {
         if {$private_graph($radius,$key)!="-"} {
            lappend x $radius
            lappend y $private_graph($radius,$key)
         }
      }
   }

   ::plotxy::clf 1
   ::plotxy::figure 1
   ::plotxy::hold on
   ::plotxy::position {0 0 600 400}
   ::plotxy::title "$key VS radius"
   ::plotxy::xlabel radius
   ::plotxy::ylabel $key

   if {[llength $y] == 0} { return }

   set h [::plotxy::plot $x $y .]
   plotxy::sethandler $h [list -color "#18ad86" -linewidth 1]

   # Affichage de la valeur obtenue sous forme d'une ligne horizontale
   set x0 [list 0 $private(psf_toolbox,$visuNo,globale,max)]
   set y0 [list $private(psf_toolbox,$visuNo,psf,$key) $private(psf_toolbox,$visuNo,psf,$key)]
   set h [::plotxy::plot $x0 $y0 .]
   plotxy::sethandler $h [list -color black -linewidth 2]

   # Affichage des barres d erreurs
   if {$key in [list "xsm" "ysm" "flux" "sky"]} {
      if { $private(psf_toolbox,$visuNo,psf,err_$key) == "-" } { return }

      set yl [expr $private(psf_toolbox,$visuNo,psf,$key) + $private(psf_toolbox,$visuNo,psf,err_$key)]
      set x0 [list 0 $private(psf_toolbox,$visuNo,globale,max)]
      set y0 [list $yl $yl]
      set h [::plotxy::plot $x0 $y0 .]
      plotxy::sethandler $h [list -color "#808080" -linewidth 2]

      set yl [expr $private(psf_toolbox,$visuNo,psf,$key) - $private(psf_toolbox,$visuNo,psf,err_$key)]
      set x0 [list 0 $private(psf_toolbox,$visuNo,globale,max)]
      set y0 [list $yl $yl]
      set h [::plotxy::plot $x0 $y0 .]
      plotxy::sethandler $h [list -color "#808080" -linewidth 2]
   }

   if {$key == "flux"} {
     set a [plotxy::axis]
     set a [lreplace $a 2 2 0]
     plotxy::axis $a
   }

}

#------------------------------------------------------------
## @brief fonction générale de comparaison des méthodes
#  @remark cette fonction dialogue avec une GUI
#  @param visuNo numéro de la visu
#  @param frm : frame de la gui
#
proc ::audace::psf_compar { visuNo frm } {
   global private
   global graph_compar

   array unset graph_compar

   set tt0 [clock clicks -milliseconds]

   #--- Capture de la fenetre d'analyse
   set private(center,box) [ ::confVisu::getBox $visuNo ]
   if { $private(center,box) == "" } {
      return
   }

   set err [catch {set bufNo [::confVisu::getBufNo $visuNo ]} msg]
   if {$err} { set bufNo 1 }
   set r [ buf$bufNo fitgauss $private(center,box) ]

   set x [lindex $r 1]
   set y [lindex $r 5]

   if { $private(psf_toolbox,$visuNo,compar,photom) == 1} {
      set private(psf_toolbox,$visuNo,methode) "photom"
      for {set radius $private(psf_toolbox,$visuNo,globale,min)} {$radius <= $private(psf_toolbox,$visuNo,globale,max)} {incr radius} {
         set private(psf_toolbox,$visuNo,radius) $radius
         ::audace::PSF_one_radius $visuNo $x $y
         if {$private(psf_toolbox,$visuNo,psf,err_psf)=="-"} {
            set x $private(psf_toolbox,$visuNo,psf,xsm)
            set y $private(psf_toolbox,$visuNo,psf,ysm)
            foreach key [::audace::get_fields_current_psf] {
               set graph_compar(psfimcce,compar,photom,$radius,$key) $private(psf_toolbox,$visuNo,psf,$key)
            }
         }
         update
      }
   }

   set x [lindex $r 1]
   set y [lindex $r 5]

   if { $private(psf_toolbox,$visuNo,compar,fitgauss2D) == 1} {
      set private(psf_toolbox,$visuNo,methode) "fitgauss2D"
      for {set radius $private(psf_toolbox,$visuNo,globale,min)} {$radius <= $private(psf_toolbox,$visuNo,globale,max)} {incr radius} {
         set private(psf_toolbox,$visuNo,radius) $radius
         ::audace::PSF_one_radius $visuNo $x $y
         if {$private(psf_toolbox,$visuNo,psf,err_psf)=="-"} {
            set x $private(psf_toolbox,$visuNo,psf,xsm)
            set y $private(psf_toolbox,$visuNo,psf,ysm)
            foreach key [::audace::get_fields_current_psf] {
               set graph_compar(psfimcce,compar,fitgauss2D,$radius,$key) $private(psf_toolbox,$visuNo,psf,$key)
            }
         }
         update
      }
   }

   set x [lindex $r 1]
   set y [lindex $r 5]

   if { $private(psf_toolbox,$visuNo,compar,psfimcce) == 1} {
      set private(psf_toolbox,$visuNo,methode) "psfimcce"
      for {set radius $private(psf_toolbox,$visuNo,globale,min)} {$radius <= $private(psf_toolbox,$visuNo,globale,max)} {incr radius} {
         set private(psf_toolbox,$visuNo,radius) $radius
         ::audace::PSF_one_radius $visuNo $x $y
         if {$private(psf_toolbox,$visuNo,psf,err_psf)=="-"} {
            set x $private(psf_toolbox,$visuNo,psf,xsm)
            set y $private(psf_toolbox,$visuNo,psf,ysm)
            foreach key [::audace::get_fields_current_psf] {
               set graph_compar(psfimcce,compar,psfimcce,$radius,$key) $private(psf_toolbox,$visuNo,psf,$key)
            }
         }
         update
      }
   }

   set x [lindex $r 1]
   set y [lindex $r 5]

   if { $private(psf_toolbox,$visuNo,compar,psfgaussian2d) == 1} {
      set private(psf_toolbox,$visuNo,methode) "psfgaussian2d"
      ::audace::PSF_one_radius $visuNo $x $y

      for {set radius $private(psf_toolbox,$visuNo,globale,min)} {$radius <= $private(psf_toolbox,$visuNo,globale,max)} {incr radius} {
         if {$private(psf_toolbox,$visuNo,psf,err_psf)=="-"} {
            foreach key [::audace::get_fields_current_psf] {
               set graph_compar(psfimcce,compar,psfgaussian2d,$radius,$key) $private(psf_toolbox,$visuNo,psf,$key)
            }
         }
         update
      }
   }

   set x [lindex $r 1]
   set y [lindex $r 5]

   if { $private(psf_toolbox,$visuNo,compar,psfmoffat) == 1} {
      set private(psf_toolbox,$visuNo,methode) "psfmoffat"
      ::audace::PSF_one_radius $visuNo $x $y

      for {set radius $private(psf_toolbox,$visuNo,globale,min)} {$radius <= $private(psf_toolbox,$visuNo,globale,max)} {incr radius} {
         if {$private(psf_toolbox,$visuNo,psf,err_psf)=="-"} {
            foreach key [::audace::get_fields_current_psf] {
               set graph_compar(psfimcce,compar,psfmoffat,$radius,$key) $private(psf_toolbox,$visuNo,psf,$key)
            }
         }
         update
      }
   }

   set private(psf_toolbox,$visuNo,duree) [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.] ]
}

#------------------------------------------------------------
## @brief trace les mesures comparatives pour un paramètre
#  @remark Cette fonction dialogue avec une GUI
#  @param visuNo numéro de la visu
#  @param key : nom du parametre
#
proc ::audace::psf_graph_compar { visuNo key } {
   global private
   global graph_compar

   ::plotxy::clf 1
   ::plotxy::figure 1
   ::plotxy::hold on
   ::plotxy::position {0 0 1000 400}
   ::plotxy::title "$key VS radius"
   ::plotxy::xlabel radius
   ::plotxy::ylabel $key

   if { $private(psf_toolbox,$visuNo,compar,photom) == 1} {
      set xphotom ""
      set yphotom ""
      for {set radius $private(psf_toolbox,$visuNo,globale,min)} {$radius <= $private(psf_toolbox,$visuNo,globale,max)} {incr radius} {
         if {[info exists graph_compar(psfimcce,compar,photom,$radius,$key)]} {
            if {$graph_compar(psfimcce,compar,photom,$radius,$key)!="-"} {
               lappend xphotom $radius
               lappend yphotom $graph_compar(psfimcce,compar,photom,$radius,$key)
            }
         }
      }
      set h1 [::plotxy::plot $xphotom $yphotom . 3 "" "Photom"]
      plotxy::sethandler $h1 [list -color "#18ad86" -linewidth 1]
   }

   if { $private(psf_toolbox,$visuNo,compar,fitgauss2D) == 1} {
      set xfitgauss2D ""
      set yfitgauss2D ""
      for {set radius $private(psf_toolbox,$visuNo,globale,min)} {$radius <= $private(psf_toolbox,$visuNo,globale,max)} {incr radius} {
         if {[info exists graph_compar(psfimcce,compar,fitgauss2D,$radius,$key)]} {
            if {$graph_compar(psfimcce,compar,fitgauss2D,$radius,$key)!="-"} {
               lappend xfitgauss2D $radius
               lappend yfitgauss2D $graph_compar(psfimcce,compar,fitgauss2D,$radius,$key)
            }
         }
      }
      set h2 [::plotxy::plot $xfitgauss2D $yfitgauss2D . 3 "" "fitgauss2D"]
      plotxy::sethandler $h2 [list -color red -linewidth 1]
   }

   if { $private(psf_toolbox,$visuNo,compar,psfimcce) == 1} {
      set xpsfimcce ""
      set ypsfimcce ""
      for {set radius $private(psf_toolbox,$visuNo,globale,min)} {$radius <= $private(psf_toolbox,$visuNo,globale,max)} {incr radius} {
         if {[info exists graph_compar(psfimcce,compar,psfimcce,$radius,$key)]} {
            if {$graph_compar(psfimcce,compar,psfimcce,$radius,$key)!="-"} {
               lappend xpsfimcce $radius
               lappend ypsfimcce $graph_compar(psfimcce,compar,psfimcce,$radius,$key)
            }
         }
      }
      set h3 [::plotxy::plot $xpsfimcce $ypsfimcce . 3 "" "psfimcce"]
      plotxy::sethandler $h3 [list -color black -linewidth 1]
   }

   if { $private(psf_toolbox,$visuNo,compar,psfgaussian2d) == 1} {
      set xpsfgaussian2d ""
      set ypsfgaussian2d ""
      for {set radius $private(psf_toolbox,$visuNo,globale,min)} {$radius <= $private(psf_toolbox,$visuNo,globale,max)} {incr radius} {
         if {[info exists graph_compar(psfimcce,compar,psfgaussian2d,$radius,$key)]} {
            if {$graph_compar(psfimcce,compar,psfgaussian2d,$radius,$key)!="-"} {
               lappend xpsfgaussian2d $radius
               lappend ypsfgaussian2d $graph_compar(psfimcce,compar,psfgaussian2d,$radius,$key)
            }
         }
      }
      set h4 [::plotxy::plot $xpsfgaussian2d $ypsfgaussian2d . 3 "" "psfgaussian2d"]
      plotxy::sethandler $h4 [list -color blue -linewidth 1]
   }

   if { $private(psf_toolbox,$visuNo,compar,psfmoffat) == 1} {
      set xpsfmoffat ""
      set ypsfmoffat ""
      for {set radius $private(psf_toolbox,$visuNo,globale,min)} {$radius <= $private(psf_toolbox,$visuNo,globale,max)} {incr radius} {
         if {[info exists graph_compar(psfimcce,compar,psfmoffat,$radius,$key)]} {
            if {$graph_compar(psfimcce,compar,psfmoffat,$radius,$key)!="-"} {
               lappend xpsfmoffat $radius
               lappend ypsfmoffat $graph_compar(psfimcce,compar,psfmoffat,$radius,$key)
            }
         }
      }
      set h4 [::plotxy::plot $xpsfmoffat $ypsfmoffat . 3 "" "psfmoffat"]
      plotxy::sethandler $h4 [list -color yellow -linewidth 1]
   }

   ::plotxy::legend no right

}

#------------------------------------------------------------
## @brief trace un cercle dans la visu
#  @remark cette fonction dialogue avec une GUI
#  @param visuNo numéro de la visu
#  @param xpic   centre en x
#  @param ypic   centre en y
#  @param radius rayon
#  @param color  couleur du cercle
#  @param tag    tag du cercle
#
proc ::audace::psf_display_circle { visuNo xpic ypic radius color tag } {
   global private

   if {$xpic=="-" || $ypic=="-" || $radius=="-"} {return}
   if {$xpic=="" || $ypic=="" || $radius==""} {return}

   set xi [expr $xpic - $radius]
   set yi [expr $ypic - $radius]
   set can_xy [::confVisu::picture2Canvas $visuNo [list $xi $yi]]
   set cxi [lindex $can_xy 0]
   set cyi [lindex $can_xy 1]

   set xs [expr $xpic + $radius]
   set ys [expr $ypic + $radius]
   set can_xy [::confVisu::picture2Canvas $visuNo [list $xs $ys]]
   set cxs [lindex $can_xy 0]
   set cys [lindex $can_xy 1]

   $private(psf_toolbox,$visuNo,hcanvas) create oval $cxi $cyi $cxs $cys \
              -fill {} -outline $color -width 2 -activewidth 3 \
              -tag $tag

}

#------------------------------------------------------------
## @brief recopie l'image de l'étoile dans block1 de l'onglet "images"
#  @remark Cette fonction est activée avec le rafraîchissemnt
#  @param visuNo numéro de la visu
#
proc ::audace::displayStar { visuNo } {
   global private

   #--   raccourci du nom du conteneur de l'image de l'etoile
   set w $private(psf_toolbox,$visuNo,frm).onglets.nb.f_img.images.block1

   #--   recupere les coordonnees images du centre et le rayon
   #--   question : faut-il choisir un autre rayon que le max ?
   set x $private(psf_toolbox,$visuNo,psf,xsm)
   set y $private(psf_toolbox,$visuNo,psf,ysm)
   set radius $private(psf_toolbox,$visuNo,globale,max)

   #--   cree un canvas pour l'image s'il n'existe pas
   if {[winfo exists $w.canv] ==0} {
      canvas $w.canv -borderwidth 0 -highlightthickness 0
      $w.canv create image 0 0 -anchor nw -tag etoile
      grid $w.canv -in $w -row 0 -column 0 -sticky news
   }

   #--   configure le canvas selon un carre
   set side [expr { 2*$radius+1 }]
   $w.canv configure -width $side -height $side
   set etoile [image create photo -gamma 2]
   $w.canv itemconfigure etoile -image $etoile

   #--   recupere les coordonnes canvas du centre
   lassign [::confVisu::picture2Canvas $visuNo [list $x $y]] xc yc

   #--   definit une boite en coordonnees canvas
   #--   todo : si le cercle sort de l'image il y a une erreur
   #     il faut vérifier que les coordonnees ne sort pas de l'image et,
   #     si necessaire, les corriger
   set x0 [expr {$xc-$radius}]
   set x1 [expr {$xc+$radius}]
   set y0 [expr {$yc-$radius}]
   set y1 [expr {$yc+$radius}]

   set bufNo [ visu$visuNo buf ]
   set naxis1 [lindex [buf$bufNo getkwd NAXIS1] 1]
   set naxis2 [lindex [buf$bufNo getkwd NAXIS2] 1]
   #::console::affiche_resultat "$naxis1+$naxis2 avbox:$x0 $y0 $x1 $y1\n"
   if {$x0<1} {set x0 1}
   if {$y0<1} {set y0 1}
   if {$x1>$naxis1} {set x1 $naxis1}
   if {$y1>$naxis2} {set y1 $naxis2}
   #::console::affiche_resultat "box:$x0 $y0 $x1 $y1\n"

   set zoom 1

   #--   l'image Tk du buffer de la visu est la source invariante des donnees
   #--   les coordonnes sont des entiers ainsi que le zoom
   $etoile blank
   $etoile copy imagevisu$visuNo \
      -from $x0 $y0 $x1 $y1 -to 0 0 \
      -zoom $zoom -compositingrule set

   ::audace::getIntegrale $visuNo
}

#------------------------------------------------------------
## @brief établit un graphique de l'intensité relative (somme des colonnes)
#  en fonction des coordonnées x des pixels dans le graphique initial
#  et le recopie dans block2 de l'onglet "images"
#  @remark Cette fonction est activee avec le rafraichissemnt apres displayStar
#  @param visuNo numéro de la visu
#
proc ::audace::getIntegrale { visuNo } {
   global private

   package require BLT

   #--   raccourci du nom du conteneur de la courbe integrale
   set w $private(psf_toolbox,$visuNo,frm).onglets.nb.f_img.images.block2

   #--   Cree les vecteurs coordonnees du graphique
   if {"::audace::Vx" ni [blt::vector names]} {
      blt::vector create Vx -watchunset 1
   }
   if {"::audace::Vintens" ni [blt::vector names]} {
      blt::vector create Vintens -watchunset 1
   }

   #--   mise a longuer nulle des deux vecteurs en vue du rafraichissement
   Vx length 0
   Vintens length 0

   set bufNo [visu$visuNo buf]

   #--   recupere les coordonnees images du centre et le rayon
   set x $private(psf_toolbox,$visuNo,psf,xsm)
   set y $private(psf_toolbox,$visuNo,psf,ysm)
   if {$private(psf_toolbox,$visuNo,globale)} {
      set radius $private(psf_toolbox,$visuNo,globale,max)
   } else {
      set radius $private(psf_toolbox,$visuNo,radius)
   }
   set x0 [expr { int($x-$radius) }]
   set x1 [expr { int($x+$radius) }]
   set y0 [expr { int($y-$radius) }]
   set y1 [expr { int($y+$radius) }]
   set box [list $x0 $y0 $x1 $y1]

   #--   recopie l'image vers un buffer de travail
   set dest [::buf::create]
   buf$bufNo copyto $dest

   #--   fenetrage de ce buffer sur la boite
   buf$dest window $box
   set naxis1 [buf$dest getpixelswidth]
   set naxis2 [buf$dest getpixelsheight]

   #--   somme toutes les lignes
   buf$dest biny 1 $naxis2 1

   #--   l'axe des x a pour coordonnees le n° des colonnes x dans l'image initiale
   Vx seq $x0 $x1 1
   for {set col 1} {$col <= $naxis1} {incr col} {
       Vintens append [lindex [buf$dest getpix [list $col 1]] 1]
   }

   #--   intensite relative (entre 0 et 1)
   Vintens expr {Vintens/$Vintens(max)}
   Vintens offset $x0 ; # le premier indice commence a $x0 au lieu de 0

   #::console::affiche_resultat "abscisses du graphique $Vx(:)\n"
   #::console::affiche_resultat "ordonnes du graphique $Vintens(:)\n"

   #--   detruit le graphique pour forcer la mise a jour
   if {[winfo exist $w.graf] ==1} {
      destroy $w.graf
   }

   #--   cree le frame du graphique
   #--   cree une zone graphique sans couleur de fond ni bordure
   blt::graph $w.graf -plotbackground [$w cget -background] -plotborderwidth 0 -relief flat

   #--   configuration du graphique
   $w.graf element create coupe -xdata $Vx(:) -ydata $Vintens(:) \
         -linewidth 1 -color red -symbol "none" -hide no
   #--   titre de l'axe des x (masque pour l'instant)
   $w.graf axis configure x -title "$::caption(audace,coord)" -hide yes -min {} -max {}
   #--   titre de l'axe des intensite(masque pour l'instant)
   $w.graf axis configure y -title "$::caption(audace,intens_xy)" -hide yes
   #--   pas de legende
   $w.graf legend configure -hide yes
   #--
   grid $w.graf -in $w -row 0 -column 0 -sticky news

   set size [expr { 2*$radius+1 }]
   $w.graf configure -height $size -width $size
   $w.graf axis configure y -min {} -max {}

   update

   #--   detruit le buffer de travail
   ::buf::delete $dest
}

#------------------------------------------------------------
## @brief commande du bouton "Effacer les marques"
#  @param visuNo numéro de la visu
#
proc ::audace::psf_clean_mark { visuNo } {
   global private

   catch {$private(psf_toolbox,$visuNo,hcanvas) delete mesurePSF}
   catch {$private(psf_toolbox,$visuNo,hcanvas) delete globalePSF}

}

#------------------------------------------------------------
#  brief commande du bouton "Aide"
#  param visuNo numéro de la visu
#
proc ::audace::psf_help { visuNo } {
   global help

   ::audace::showHelpItem $help(dir,analyse) "1110psf.htm"
}

#------------------------------------------------------------
## @brief commande du bouton "Fermer"
#  @param visuNo numéro de la visu
#  @param frm chemin tK
#
proc ::audace::psf_fermer { visuNo frm } {
   ::audace::psf_clean_mark $visuNo
   ::audace::psf_close_to_conf $visuNo
   ::audace::fermeFenetresAnalyse $visuNo $frm psf_toolbox
   catch { blt::vector destroy ::Vx ::Vintens }
}

#------------------------------------------------------------
## @brief enregistre les paramètres dans la configuration de Audela
#  @param visuNo numéro de la visu
#
proc ::audace::psf_close_to_conf { visuNo } {

   global private
   global conf
   
   if {![info exists private(psf_toolbox,$visuNo,radius)]} {return}
   set conf(psf_toolbox,$visuNo,radius)             $private(psf_toolbox,$visuNo,radius)
   set conf(psf_toolbox,$visuNo,radius,min)         $private(psf_toolbox,$visuNo,radius,min)
   set conf(psf_toolbox,$visuNo,radius,max)         $private(psf_toolbox,$visuNo,radius,max)
   set conf(psf_toolbox,$visuNo,globale,min)        $private(psf_toolbox,$visuNo,globale,min)
   set conf(psf_toolbox,$visuNo,globale,max)        $private(psf_toolbox,$visuNo,globale,max)
   set conf(psf_toolbox,$visuNo,globale,confidence) $private(psf_toolbox,$visuNo,globale,confidence)
   set conf(psf_toolbox,$visuNo,saturation)         $private(psf_toolbox,$visuNo,saturation)
   set conf(psf_toolbox,$visuNo,threshold)          $private(psf_toolbox,$visuNo,threshold)
   set conf(psf_toolbox,$visuNo,globale)            $private(psf_toolbox,$visuNo,globale)
   set conf(psf_toolbox,$visuNo,ecretage)           $private(psf_toolbox,$visuNo,ecretage)
   set conf(psf_toolbox,$visuNo,methode)            $private(psf_toolbox,$visuNo,methode)
   set conf(psf_toolbox,$visuNo,precision)          $private(psf_toolbox,$visuNo,precision)
   set conf(psf_toolbox,$visuNo,photom,r1)          $private(psf_toolbox,$visuNo,photom,r1)
   set conf(psf_toolbox,$visuNo,photom,r2)          $private(psf_toolbox,$visuNo,photom,r2)
   set conf(psf_toolbox,$visuNo,photom,r3)          $private(psf_toolbox,$visuNo,photom,r3)
   set conf(psf_toolbox,$visuNo,marks,cercle)       $private(psf_toolbox,$visuNo,marks,cercle)
   set conf(psf_toolbox,$visuNo,globale,arret)      $private(psf_toolbox,$visuNo,globale,arret)
   set conf(psf_toolbox,$visuNo,globale,nberror)    $private(psf_toolbox,$visuNo,globale,nberror)
   set conf(psf_toolbox,$visuNo,gaussian_statistics)    $private(psf_toolbox,$visuNo,gaussian_statistics)
   set conf(psf_toolbox,$visuNo,read_out_noise)    $private(psf_toolbox,$visuNo,read_out_noise)
   set conf(psf_toolbox,$visuNo,beta)              $private(psf_toolbox,$visuNo,beta)
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'outil "PSF ToolBox"
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - conf(psf_toolbox,$visuNo,position) position de la fenêtre
#  - conf(psf_toolbox,$visuNo,modeRefresh)
#  - conf(psf_toolbox,$visuNo,radius)
#  - conf(psf_toolbox,$visuNo,radius,min)
#  - conf(psf_toolbox,$visuNo,radius,max)
#  - conf(psf_toolbox,$visuNo,globale,max)
#  - conf(psf_toolbox,$visuNo,globale,min)
#  - conf(psf_toolbox,$visuNo,globale,confidence)
#  - conf(psf_toolbox,$visuNo,saturation)
#  - conf(psf_toolbox,$visuNo,threshold)
#  - conf(psf_toolbox,$visuNo,globale)
#  - conf(psf_toolbox,$visuNo,ecretage)
#  - conf(psf_toolbox,$visuNo,methode)
#  - conf(psf_toolbox,$visuNo,precision)
#  - conf(psf_toolbox,$visuNo,photom,r1)
#  - conf(psf_toolbox,$visuNo,photom,r2)
#  - conf(psf_toolbox,$visuNo,photom,r3)
#  - conf(psf_toolbox,$visuNo,marks,cercle)
#  - conf(psf_toolbox,$visuNo,globale,arret)
#  - conf(psf_toolbox,$visuNo,globale,nberror)
#  - conf(psf_toolbox,$visuNo,gaussian_statistics)
#  - conf(psf_toolbox,$visuNo,read_out_noise)
#  - conf(psf_toolbox,$visuNo,beta)
#  @param visuNo numéro de la visu
#
proc ::audace::psf_init { visuNo } {
   global conf private

   if { ! [ info exists conf(psf_toolbox,$visuNo,position)    ] }        { set conf(psf_toolbox,$visuNo,position)              "+350+75" }
   if { ! [ info exists conf(psf_toolbox,$visuNo,modeRefresh) ] }        { set conf(psf_toolbox,$visuNo,modeRefresh)           "0" }

   if { ! [ info exists conf(psf_toolbox,$visuNo,radius)             ] } { set private(psf_toolbox,$visuNo,radius)              15         } else { set private(psf_toolbox,$visuNo,radius)              $conf(psf_toolbox,$visuNo,radius)             }
   if { ! [ info exists conf(psf_toolbox,$visuNo,radius,min)         ] } { set private(psf_toolbox,$visuNo,radius,min)          1          } else { set private(psf_toolbox,$visuNo,radius,min)          $conf(psf_toolbox,$visuNo,radius,min)         }
   if { ! [ info exists conf(psf_toolbox,$visuNo,radius,max)         ] } { set private(psf_toolbox,$visuNo,radius,max)          300        } else { set private(psf_toolbox,$visuNo,radius,max)          $conf(psf_toolbox,$visuNo,radius,max)         }
   if { ! [ info exists conf(psf_toolbox,$visuNo,globale,min)        ] } { set private(psf_toolbox,$visuNo,globale,min)         5          } else { set private(psf_toolbox,$visuNo,globale,min)         $conf(psf_toolbox,$visuNo,globale,min)        }
   if { ! [ info exists conf(psf_toolbox,$visuNo,globale,max)        ] } { set private(psf_toolbox,$visuNo,globale,max)         40         } else { set private(psf_toolbox,$visuNo,globale,max)         $conf(psf_toolbox,$visuNo,globale,max)        }
   if { ! [ info exists conf(psf_toolbox,$visuNo,globale,confidence) ] } { set private(psf_toolbox,$visuNo,globale,confidence)  90         } else { set private(psf_toolbox,$visuNo,globale,confidence)  $conf(psf_toolbox,$visuNo,globale,confidence) }
   if { ! [ info exists conf(psf_toolbox,$visuNo,saturation)         ] } { set private(psf_toolbox,$visuNo,saturation)          65000      } else { set private(psf_toolbox,$visuNo,saturation)          $conf(psf_toolbox,$visuNo,saturation)         }
   if { ! [ info exists conf(psf_toolbox,$visuNo,threshold)          ] } { set private(psf_toolbox,$visuNo,threshold)           3          } else { set private(psf_toolbox,$visuNo,threshold)           $conf(psf_toolbox,$visuNo,threshold)          }
   if { ! [ info exists conf(psf_toolbox,$visuNo,globale)            ] } { set private(psf_toolbox,$visuNo,globale)             0          } else { set private(psf_toolbox,$visuNo,globale)             $conf(psf_toolbox,$visuNo,globale)            }
   if { ! [ info exists conf(psf_toolbox,$visuNo,ecretage)           ] } { set private(psf_toolbox,$visuNo,ecretage)            0          } else { set private(psf_toolbox,$visuNo,ecretage)            $conf(psf_toolbox,$visuNo,ecretage)           }
   if { ! [ info exists conf(psf_toolbox,$visuNo,methode)            ] } { set private(psf_toolbox,$visuNo,methode)             "photom"   } else { set private(psf_toolbox,$visuNo,methode)             $conf(psf_toolbox,$visuNo,methode)            }
   if { ! [ info exists conf(psf_toolbox,$visuNo,precision)          ] } { set private(psf_toolbox,$visuNo,precision)           high       } else { set private(psf_toolbox,$visuNo,precision)           $conf(psf_toolbox,$visuNo,precision)          }
   if { ! [ info exists conf(psf_toolbox,$visuNo,photom,r1)          ] } { set private(psf_toolbox,$visuNo,photom,r1)           1          } else { set private(psf_toolbox,$visuNo,photom,r1)           $conf(psf_toolbox,$visuNo,photom,r1)          }
   if { ! [ info exists conf(psf_toolbox,$visuNo,photom,r2)          ] } { set private(psf_toolbox,$visuNo,photom,r2)           2          } else { set private(psf_toolbox,$visuNo,photom,r2)           $conf(psf_toolbox,$visuNo,photom,r2)          }
   if { ! [ info exists conf(psf_toolbox,$visuNo,photom,r3)          ] } { set private(psf_toolbox,$visuNo,photom,r3)           2.6        } else { set private(psf_toolbox,$visuNo,photom,r3)           $conf(psf_toolbox,$visuNo,photom,r3)          }
   if { ! [ info exists conf(psf_toolbox,$visuNo,marks,cercle)       ] } { set private(psf_toolbox,$visuNo,marks,cercle)        1          } else { set private(psf_toolbox,$visuNo,marks,cercle)        $conf(psf_toolbox,$visuNo,marks,cercle)       }
   if { ! [ info exists conf(psf_toolbox,$visuNo,globale,arret)      ] } { set private(psf_toolbox,$visuNo,globale,arret)       1          } else { set private(psf_toolbox,$visuNo,globale,arret)       $conf(psf_toolbox,$visuNo,globale,arret)      }
   if { ! [ info exists conf(psf_toolbox,$visuNo,globale,nberror)    ] } { set private(psf_toolbox,$visuNo,globale,nberror)     3          } else { set private(psf_toolbox,$visuNo,globale,nberror)     $conf(psf_toolbox,$visuNo,globale,nberror)    }
   if { ! [ info exists conf(psf_toolbox,$visuNo,gaussian_statistics)] } { set private(psf_toolbox,$visuNo,gaussian_statistics) 1          } else { set private(psf_toolbox,$visuNo,gaussian_statistics) $conf(psf_toolbox,$visuNo,gaussian_statistics)}
   if { ! [ info exists conf(psf_toolbox,$visuNo,read_out_noise)     ] } { set private(psf_toolbox,$visuNo,read_out_noise)      0          } else { set private(psf_toolbox,$visuNo,read_out_noise)      $conf(psf_toolbox,$visuNo,read_out_noise)     }
   if { ! [ info exists conf(psf_toolbox,$visuNo,beta)               ] } { set private(psf_toolbox,$visuNo,beta)                -3         } else { set private(psf_toolbox,$visuNo,beta)                $conf(psf_toolbox,$visuNo,beta)               }

   catch {set private(psf_toolbox,$visuNo,hcanvas) [::confVisu::getCanvas $visuNo]}

   foreach key [::audace::get_fields_current_psf] {
      set private(psf_toolbox,$visuNo,psf,$key) "-"
   }
   set private(psf_toolbox,$visuNo,duree) ""
   set private(psf_toolbox,$visuNo,gui)   0
   set private(psf_toolbox,$visuNo,graph) 0
}

