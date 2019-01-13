#
## @file sn_tarot.tcl
#  @brief Visualise les images de la nuit et compare avec des images de référence
#  @author Alain KLOTZ et Raymond ZACHANTKE
#  $Id: sn_tarot.tcl 13978 2016-06-11 07:05:28Z rzachantke $
#  @warning Conventions pour ce script :
#   - Les indices 1 se rapportent à l'image de gauche
#   - Les indices 2 se rapportent à l'image de droite
#

#  source $audace(rep_install)/gui/audace/plugin/tool/sn_tarot/sn_tarot.tcl
#

#-----------------------------------------------------
## @brief binding d'un joystick
#  @note utiliser les boutons de la xBoxOne
#  - B pour explorer l'image suivante (button 1)
#  - X pour explorer l'image précédente (button2 )
#  - Y pour commander le blink (button 3)
#  - A pour afficher une image noire (button 0)
#  - manette gauche pour simuler un déplacement relatif (haut bas, gauche droite) de la souris
#  - bouton supérieur avant droit pour simuler un clic droit de la souris (button 5)
#    et faire apparaître le menu
#  - bouton supérieur avant gauche pour simuler un clic gauche de la souris (button 4)
#    et sélectionner un élément du menu
#
proc ::sn_tarot::bindjoystick { } {
   global snvisu

   set err [catch {
      set res [joystick event peek]
      if {$res=="joystick 0 button 1 value 1"} {
         ::sn_tarot::incrImage
      } elseif {$res=="joystick 0 button 2 value 1"} {
         ::sn_tarot::incrImage -1
      } elseif {$res=="joystick 0 button 3 value 1"} {
         set snvisu(exit_blink) "1"
         if { $snvisu(blink_go) == "0" } {
            ::sn_tarot::snBlinkImage
         }
      } elseif {$res=="joystick 0 button 0 value 1"} {
         ::sn_tarot::noStar
      } else {
         set k [lsearch -ascii $res joystick ]
         if {$k>=0} {
            set joystick [lindex $res [expr $k+1]]
            set opt      [lrange $res [expr $k+2] [expr $k+3]]
         }
         set k [lsearch -ascii $res value]
         if {$k>=0} { set value [lindex $res [expr $k+1]] }
         set opts "joystick $joystick $opt"
         set val 0
         if {$opts=="joystick 0 axis 0"} {
            set val  [expr round($value/5000.0)]
            catch {twapi::move_mouse $val 0 -relative}
         }
         if {$opts=="joystick 0 axis 1"} {
            set val  [expr round($value/5000.0)]
            catch {twapi::move_mouse 0 $val -relative}
         }
         if {($opts=="joystick 0 button 4")&&($value==1)} {
            set val [twapi::get_mouse_location]
            catch {twapi::click_mouse_button left}
         }
         if {($opts=="joystick 0 button 5")&&($value==1)} {
            set val [twapi::get_mouse_location]
            catch {twapi::click_mouse_button right}
         }
      }
   } msg]
   if {$err==1} {
      #::console::affiche_resultat "::sn_tarot::bindjoystick error: $msg\n"
   }
}

#-----------------------------------------------------
#  brief définit le nom des répertoires et leur contenu
#  en fonction du type de télescope (Tarot ou Zadko)
#  code
#  ::sn_tarot::SiteChosen Tarot_Calern_20160318
#  encode
#  param file_name nom du fichier (site_date)
#
proc ::sn_tarot::SiteChosen { file_name } {
   global panneau rep snconfvisu

   #--   extrait le type de tel (Tarot ou Zadko)
   set typetel [lindex [split $file_name "_"] 0]

   #--   definit le chemin des repertoires des images de references
   #     et de des images dss en fonction de typetel
   switch -exact $typetel {
      Tarot   { set rep(name2) "[ file join $panneau(init_dir) references ]"
                set rep(name3) "[ file join $panneau(init_dir) dss ]"
              }
      Zadko   { set rep(name2) "[ file join $panneau(init_dir) references_zadko ]"
                set rep(name3) "[ file join $panneau(init_dir) dss_zadko ]"
              }
   }

   #--   liste les fichiers presents dans night (i=1), references (i=2)  et dss (i=3)
   set err [catch {
      for { set i 1 } { $i <=3 } { incr i } {
         set rep(x$i) [ lsort -dictionary [ glob -nocomplain -type f -dir $rep(name$i) *$::conf(extension,defaut) ] ]
         set rep(sum$i) [ llength $rep(x$i) ]
         #--   fixe le premier index a 0
         if { $rep(sum$i) != 0 } {
            set rep(index$i) 0
         }
      }
   } msg]

}

#-----------------------------------------------------
##  @brief initialise et construit la fenêtre "Tarot SN Visu"
#   @pre lancée par le bouton "Recherche supernovae" du panneau, après initialisation préalable
proc ::sn_tarot::createTarotVisu { } {
   variable This

   # =======================================
   # === Initialisation of the variables
   # === Initialisation des variables
   # =======================================

   #--- Definition of global variables (arrays)
   #--- Definition des variables globales (arrays)
   global zone       #--- Window name of usefull screen parts
   global info_image #--- Some infos on the current image
   global audace conf snvisu snconfvisu num caption color rep panneau

   #--- Chargement de la configuration
   lassign $conf(sn_tarot) snconfvisu(cuts_change) snconfvisu(delai_blink) \
      snconfvisu(nb_blink) snconfvisu(auto_blink) snconfvisu(gzip)
   set snconfvisu(zoom_normal) 4

   if { $conf(sn_tarot,last_archive) ni $rep(list_archives) } {
      set snconfvisu(archive) "-"
    } else {
      set snconfvisu(archive) $conf(sn_tarot,last_archive)
   }

   ###--   Note RZ : pour éviter une erreur je démarre sur les images DSS
   lassign [ list "" "0" "1" "1" ] rep(blink,last) snvisu(blink_go) \
   snvisu(exit_blink) snconfvisu(pers_or_dss)
   set snvisu(afflog) 1 ; #--- Pour un affichage des images en mode logarithme
   set snvisu(dss) 0    ; #-- pour signaler le telechargement

   ::sn_tarot::SiteChosen $snconfvisu(archive)

   #--   lancee au démarage et au changement de fichier images de la nuit
   set rep(index1) -1  ; #--indice de l'image affichee dans night ; -1 si pas d'image
   set rep(index2) -1  ; #--indice de l'image dans references ; -1 si pas d'image
   set rep(index3) -1  ; #--indice de l'image dans dss  ; -1 si pas d'image

   set rep(gz) "$snconfvisu(gzip)"
   set gnaxis 308 ; # = 4 * naxis

   # =========================================
   # === Setting the graphic interface
   # === Met en place l'interface graphique
   # =========================================

   set fr $This.snvisu

   #--- Create the toplevel window $This.snvisu
   #--- Cree la fenetre $This.snvisu de niveau le plus haut

   if { [ winfo exists $fr ] } {
      wm withdraw $fr
      wm deiconify $fr
      return
   }

   toplevel $fr -class Toplevel

   if { $::tcl_platform(os) == "Linux" } {
      wm minsize $fr 800 600
   } else {
      wm minsize $fr 660 548
   }

   wm geometry $fr $conf(sn_tarot,geometry)
   wm resizable $fr 0 0
   wm title $fr $caption(sn_tarot,main_title)
   wm protocol $fr WM_DELETE_WINDOW "::sn_tarot::cmdClose"

   label $fr.lab -text [ format $caption(sn_tarot,title) $snconfvisu(archive) ]
   pack $fr.lab -pady 5

   #--- Create frames
   #--- Cree des frames
   foreach item [ list fr1 fr2 fr3 fr4 fr5 ] {
      set $item $fr.$item
      frame [ set $item ] -borderwidth 0 -cursor arrow
      pack [ set $item ] -anchor n -side top -fill x
   }

   #--- First frame : time and name
   #--- Premier frame : les heures et le nom de l'image
   foreach lab [ list labelh1 label1 labelh2 ] {
      set zone($lab) $fr1.$lab
      label $zone($lab) -text "" -borderwidth 0 -relief flat -width 22
      pack $zone($lab) -padx 5 -pady 10
   }
   pack configure $zone(labelh1) -side left -anchor nw
   pack configure $zone(label1) -side left -padx 100
   pack configure $zone(labelh2) -side right -anchor ne

   #--- Create the canvas for the image 1 and 2 in the second frame
   #--- Cree le canevas pour l'image 1 et 2 dans le frame 2
   lassign [split [lindex [split $conf(sn_tarot,geometry) +] 0] x]] dimx dimy
   canvas $fr2.image0 -width 0 -height 0
   set padxx 5
   set padx [expr ($dimx/2-$gnaxis-2*$padxx)/2]
   if {$padx<0} { set padx 0 }
   pack $fr2.image0 -expand 0 -fill none -side left -anchor e -padx $padx
   foreach imgNo [ list 1 2 ] {
      set zone(image$imgNo) $fr2.image$imgNo
      canvas $zone(image$imgNo) -width $gnaxis -height $gnaxis
      $zone(image$imgNo) configure -cursor crosshair
      pack $zone(image$imgNo) -expand 0 -fill none -side left -anchor e -padx $padxx
   }

   #--- Scales are in the third frame
   #--- Les glissieres sont dans le troisieme
   set gnaxis1scale $gnaxis
   foreach sca [ list sh1 sh2 ] cmd [ list ::sn_tarot::changeHiCut1 ::sn_tarot::changeHiCut2 ] {
      set zone($sca) $fr3.$sca
      scale $zone($sca) -orient horizontal -to 32767 -from -10000 \
         -length $gnaxis1scale -background $audace(color,cursor_blue) \
         -borderwidth 1 -showvalue 0 -width 10 -sliderlength 20 \
         -activebackground $audace(color,cursor_blue_actif) \
         -relief raised -command $cmd
      pack $zone($sca) -anchor s -side left -expand 1 -fill x -padx 10
   }

   #--- Buttons are in the fourth frame
   #--- Les boutons sont dans le quatrieme
   #--- Create the button 'Previous', 'Next', 'Go to', 'Sky Background', 'Start Blink', 'Save'
   #--- Cree le bouton 'Precedente', 'Suivante', 'Aller a, 'Fond du ciel', 'GO Blink', 'Enregistrer'
   set button_list [ list prev next goto background blink_go save ]
   set cmd_list [ list "incrImage -1" "incrImage" gotoImage snSubSky snBlinkImage confirmSave ]
   foreach but $button_list cmd $cmd_list {
      set i [lsearch -exact $button_list $but ]
      button $fr4.but_$but -text $caption(sn_tarot,$but) -borderwidth 2 \
         -command "::sn_tarot::$cmd"
      grid $fr4.but_$but -row 0 -column $i -ipadx 5 -ipady 5 -sticky ns
   }

   #--- Create the radio-buttons
   #--- Cree les radio-boutons
   #--- Bouton radio 1 "Dossier de reference perso"
   radiobutton $fr4.but_rad0 -text $caption(sn_tarot,perso) \
      -variable snconfvisu(pers_or_dss) -value 0 \
      -command "::sn_tarot::displayImages"
   incr i
   grid $fr4.but_rad0 -row 0 -column $i -ipadx 5 -sticky ns
   #--- Bouton radio 2 "Dossier de reference DSS"
   radiobutton $fr4.but_rad1 -text $caption(sn_tarot,dss) \
      -variable snconfvisu(pers_or_dss) -value 1 \
      -command "::sn_tarot::displayImages"
   incr i
   grid $fr4.but_rad1 -row 0 -column $i -ipadx 5 -sticky ns
   $fr4.but_rad1 configure -state disabled

   grid columnconfigure $fr4 { 0 1 2 3 4 5 6 7 8 } -weight 1 -pad 5

   #--- Create a console for status returned
   #--- Cree la console de retour d'etats
   set zone(status_list) $fr.lst1
   listbox $zone(status_list) -height 3 -borderwidth 1 -relief sunken \
      -yscrollcommand [ list $zone(status_list).scr1 set ]
   pack $zone(status_list) -fill x -anchor ne -padx 3 -pady 3

   #--- Create a vertical scrollbar for the status listbox
   #--- Cree un ascenseur vertical pour la console de retour d'etats
   scrollbar $zone(status_list).scr1 -orient vertical -takefocus 1 -borderwidth 1 \
      -command [ list $zone(status_list) yview ]
   pack $zone(status_list).scr1 -in $zone(status_list) -fill y -side right -anchor ne

   #--   Create the command SetUp Help and Exit
   pack configure $fr5 -side bottom
   foreach but [ list configuration exit aide ] cmd [ list snSetup cmdClose "snHelp sn_visu" ] {
      button $fr5.but_$but -text "$caption(sn_tarot,$but)" \
         -width 10 -borderwidth 2 -command "::sn_tarot::$cmd"
      pack $fr5.but_$but -side right -padx 10 -pady 5 -ipadx 5 -ipady 5
   }
   pack $fr5.but_configuration -side left

   label $fr5.lab -text "$caption(sn_tarot,select)"
   pack $fr5.lab -side left -padx 10 -pady 5 -ipadx 5 -ipady 5

   ComboBox $fr5.select -height 10 -relief sunken -width 25 \
      -textvariable snconfvisu(night) \
      -values $rep(list_archives) \
      -modifycmd "::sn_tarot::snSelect"
   pack $fr5.select -side left
   set k [ lsearch $rep(list_archives) $snconfvisu(night) ]
   if { $k == -1 } { set k 0 }
   $fr5.select setvalue @$k

   #--- La fenetre est active
   focus $fr

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $fr
   $fr.lab configure -font "{MS Sans Serif} 8 bold"

   # =========================================
   # === Setting the binding
   # === Met en place les liaisons
   # =========================================

   set have_joystick 0
   set err [catch {
      package require mkLibsdl
      set count [joystick count]
      if {$count>0} {
         joystick event eval ::sn_tarot::bindjoystick
         set have_joystick 1
      }
      package require twapi
   } msg]
   #::console::affiche_resultat "bindings: $err = $msg\n"

   bind $fr <Key-space> { ::sn_tarot::incrImage }
   bind $fr <Key-F1>    { ::sn_tarot::incrImage }
   bind $fr <Key-Right> { ::sn_tarot::incrImage }
   bind $fr <Key-Left>  { ::sn_tarot::incrImage -1}
   bind $fr <Key-F2>    { ::sn_tarot::snSubSky }
   bind $fr <Key-Up>    {
      set snvisu(exit_blink) "1"
      if { $snvisu(blink_go) == "0" } {
         ::sn_tarot::snBlinkImage
      }
   }
   bind $fr <Key-F3> {
      set snvisu(exit_blink) "1"
      if { $snvisu(blink_go) == "0" } {
         ::sn_tarot::snBlinkImage
      }
   }
   bind $fr <Key-Down> { ::sn_tarot::noStar }
   bind $fr <Key-F4> { ::sn_tarot::confirmSave }
   bind $fr <Key-F5> { ::sn_tarot::snHeader $num(buffer1) }
   bind $fr <Key-F6> { ::sn_tarot::snHeader $num(buffer2) }
   bind $fr <Key-F7> { ::sn_tarot::noCosmic }
   bind $fr <Key-F8> { ::sn_tarot::noStar }

   if { [ string tolower "$snconfvisu(cuts_change)" ] == "motion" } {
      set cmd Motion
   } else {
      set cmd ButtonRelease
   }
   bind $zone(sh1) <$cmd> { visu$num(visu1) disp }
   bind $zone(sh2) <$cmd> { visu$num(visu2) disp }

   # ========================================
   # === Setting the astronomical devices ===
   # ========================================

   foreach b [ list buffer1 buffer1b buffer2 buffer2b ] {
      #--- Declare a new buffer in memory to place images
      set num($b) [::buf::create]
      buf$num($b) extension $conf(extension,defaut)
      if { $conf(fichier,compres) == "0" } {
         buf$num($b) compress "none"
      } else {
         buf$num($b) compress "gzip"
      }
      if { $conf(format_fichier_image) == "0" } {
         buf$num($b) bitpix ushort
      } else {
         buf$num($b) bitpix float
      }
   }

   #--- Image visu100 et visu200
   set num(visu1) [::visu::create $num(buffer1) 100 ]
   set num(visu2) [::visu::create $num(buffer2) 200 ]

   visu$num(visu1) zoom $snconfvisu(zoom_normal)
   visu$num(visu2) zoom $snconfvisu(zoom_normal)

   #--- Create a widget image in a canvas to display that of the visu space
   $zone(image1) create image 0 0 -image imagevisu100 -anchor nw -tag display
   $zone(image2) create image 0 0 -image imagevisu200 -anchor nw -tag display

   #--  Create a popup menu in Image 1 display
   set menu [ winfo toplevel $zone(image1) ].menuButton3
   menu $menu -tearoff no
      $menu add command -label "$caption(sn_tarot,galaxy_center)" \
         -command "::sn_tarot::snGalaxyCenter"
      $menu add command -label "$caption(sn_tarot,star_ref)" \
         -command "::sn_tarot::snStarRef"
      $menu add command -label "$caption(sn_tarot,star_pos)" \
         -command "::sn_tarot::snCandidate"
      $menu add command -label "$caption(sn_tarot,star_id) " \
         -command "::sn_tarot::snCreateCandidateId"
      $menu add command -label "$caption(sn_tarot,swatch) " \
         -command "::div::initDiv $num(visu1)"
   $zone(image1) bind display <ButtonPress-3> { set snvisu(candidate,xy) [list %x [expr [$zone(image1) cget -height]-%y]] ; tk_popup [ winfo toplevel $zone(image1) ].menuButton3 %X %Y}

   #--   liste les fichiers presents dans night, references et dss
   for { set i 1 } { $i <=3 } { incr i } {
      set rep(x$i) [ lsort -dictionary [ glob -nocomplain -type f -dir $rep(name$i) *$conf(extension,defaut) ] ]
      set rep(sum$i) [ llength $rep(x$i) ]
      if { $rep(sum$i) != 0 } {
         set rep(index$i) 0
      }
   }

   #--   on cherche l'indice de l'image
   ::sn_tarot::searchGalaxy

   #--   s'il y a une image on l'affiche
   if { $rep(index1) != "-1" } {
      ::sn_tarot::displayImages
   }
}

#-----------------------------------------------------
#  brief commande de la glissière pour la
#  mise à jour des seuils de visualisation de l'image 1
#  param foo
#
proc ::sn_tarot::changeHiCut1 { foo } {
   global num snvisu

   set sbh [visu$num(visu1) cut]
   visu$num(visu1) cut [list $foo [lindex $sbh 1]]
   set snvisu(seuil_g_haut) $foo
   set snvisu(seuil_g_bas)  [lindex $sbh 1]
}

#-----------------------------------------------------
#  brief commande de la glissière pour la
#  mise à jour des seuils de visualisation de l'image 2
#  param foo
#
proc ::sn_tarot::changeHiCut2 { foo } {
   global num snvisu

   set sbh [visu$num(visu2) cut]
   visu$num(visu2) cut [list $foo [lindex $sbh 1]]
   set snvisu(seuil_d_haut) $foo
   set snvisu(seuil_d_bas)  [lindex $sbh 1]
}

#-----------------------------------------------------
## @brief commande du bouton "Suivante" & "Précédente" de la fenêtre "Tarot SN Visu"
#  @param incr incrément de
#  - +1 pour "Suivante" (par défaut)
#  - -1 pour "Précédente"
#
proc ::sn_tarot::incrImage { { incr 1 } } {
   global rep snconfvisu

   set rep(blink,last) ""
   set old_index $rep(index1)

   #--   Traitement des limites : bloqué sur 0 ou $rep(sum1)
   set sup [ expr {$rep(sum1)-1} ]
   switch -exact $incr {
      "1"   {  if { $rep(index1) >= 0 && $rep(index1) < $sup } {
                  incr rep(index1) $incr
               }
            }
      "-1"  {  if { $rep(index1) > 0 && $rep(index1) <= $sup } {
                  incr rep(index1) $incr
               }
            }
   }

   #--   arrete si les index sont identiques
   if { $rep(index1) == $old_index } {
      return
   }

   ::sn_tarot::searchGalaxy
   ::sn_tarot::displayImages

   if { $snconfvisu(auto_blink) == "1" } {
      ::sn_tarot::snBlinkImage
   }
}

#-----------------------------------------------------
#  brief sous processus lancé par nextImage et prevImage
#  invoqué par ::sn_tarot::incrImage et ::sn_tarot::cmdGoToImageNo
#  param subsky     0 par défaut
#  param fname_img1 "" par défaut
#
proc ::sn_tarot::displayImages { {subsky 0} {fname_img1 ""} } {
   variable console_msg
   global caption rep zone num snvisu snconfvisu

   #--- Initialisation
   set afflog1  "$snvisu(afflog)"
   set afflog2  "$snvisu(afflog)"

   #--- Nettoyage des 2 canvas avant affichage
   catch {
      #--- Du canvas de l'image 1
      visu$num(visu1)   clear
      buf$num(buffer1)  clear
      buf$num(buffer1b) clear
      #--- Du canvas de l'image 2
      visu$num(visu2)   clear
      buf$num(buffer2)  clear
      buf$num(buffer2b) clear
   }

   #---
   set side1 4
   set side2 4
   set affspecial 0
   if {$fname_img1==""} {
      set filename [ lindex $rep(x1) $rep(index1) ]
   } else {
      set filename $fname_img1
      set affspecial 1
      set afflog1 0
   }
   set snvisu(name) [ file tail $filename ]

   #---
   if { $afflog1==0 } {
      visu$num(visu1) buf $num(buffer1)
   } else {
      visu$num(visu1) buf $num(buffer1b)
   }
   if { $afflog2==0 } {
      visu$num(visu2) buf $num(buffer2)
   } else {
      visu$num(visu2) buf $num(buffer2b)
   }

   set a [catch {buf$num(buffer1) load $filename} result]
   if {$a==1} {
      return
   }

   #-- Effectue une eventuelle correction de fond de ciel
   if {$subsky==1} {
      set back_threshold 0.2
      set back_kernel 15
      buf$num(buffer1) imaseries "BACK sub back_kernel=$back_kernel back_threshold=$back_threshold"
   }

   #--   Met a jour la ligne de titre
   $zone(labelh1) configure -text [lindex [buf$num(buffer1) getkwd DATE-OBS] 1]
   $zone(label1) configure -text "$snvisu(name)    [expr $rep(index1)+1]/$rep(sum1)"

   #---  regle la glissiere du buffer1
   lassign  [ buf$num(buffer1) stat ] sh sb scalemax scalemin mean std backmean backstd
   visu$num(visu1) cut [ list $sh $sb ]

   #--- Affichage en mode logarithme
   if { $afflog1==1 } {
      visu$num(visu1) cut [ ::sn_tarot::snBufLog $num(buffer1) $num(buffer1b) $side1 ]
   }

   # --- Affichage en mode nostar
   if { $affspecial==1 } {
      set sb [expr $backmean-3*$backstd]
      set sh [expr $backmean+30*$backstd]
      visu$num(visu1) cut [list $sh $sb]
   }

   visu$num(visu1) disp

   #--   configure la reglette de la visu1 selon le mode log/pas log
   ::sn_tarot::configScale 1 $afflog1

   set user [lindex [buf$num(buffer1) getkwd USER] 1]
   if {$user!=""} {
      set user "[string trim ${user}]"
   }
   set name [lindex [buf$num(buffer1) getkwd NAME] 1]
   if {$name!=""} {
      set name "[string trim ${name}]"
   }
   set gren_ha [lindex [buf$num(buffer1) getkwd GREN_HA] 1]
   set gren_dec [lindex [buf$num(buffer1) getkwd DEC] 1]
   set gren_alt [lindex [buf$num(buffer1) getkwd GREN_ALT] 1]
   set fwhm [lindex [buf$num(buffer1) getkwd FWHM] 1]
   set complus ""
   if {($gren_ha!="")&&($gren_dec!="")&&($gren_alt!="")&&($fwhm!="")} {
      set complus " [string trim ${gren_ha}] dec=[string trim ${gren_dec}] elev=[string trim ${gren_alt}] fwhm=[string trim ${fwhm}]"
   }
   set console_msg "[ format $caption(sn_tarot,image1) [ ::sn_tarot::shortPath $filename 7 ] $result [string trim [lindex [::sn_tarot::snCenterRaDec $num(buffer1)] 0]] $user $name $complus ]"
   ::sn_tarot::afficheConsole

   #--   charge l'image dans la visu 2 selon le choix Personnel ou DSS
   set filename ""
   if { $snconfvisu(pers_or_dss) == 0 && $rep(index2) != "-1" } {
      set filename [ lindex $rep(x2) $rep(index2) ]
   } elseif { $snconfvisu(pers_or_dss) == 1 && $rep(index3) != "-1" && $rep(sum3) != 0} {
      set filename [ lindex $rep(x3) $rep(index3) ]
   } else {
      set filename [ lindex $rep(x2) $rep(index2) ]
   }

   set result ""
   set a [catch { buf$num(buffer2) load $filename } result]

   if { $a == 1 } {
      if { $a == 1 } {
         #--   Met a jour la ligne de titre
         $zone(labelh2) configure -text "-"
         if {$snconfvisu(pers_or_dss)==0} {
            ::sn_tarot::saveImage 0
         }
      }
      set filename ""
      if { ($snconfvisu(pers_or_dss) == 0) } {
         set filename [ lindex $rep(x3) $rep(index3) ]
         set result ""
         set a [catch { buf$num(buffer2) load $filename } result]
      }
      if { $a == 1 } {
         return
      } else {
         $zone(labelh2) configure -text "$caption(sn_tarot,dss)"
         # $fr4.but_rad0 et $fr4.but_rad1
      }
   } else {
      #--   Met a jour la ligne de titre
      $zone(labelh2) configure -text [lindex [buf$num(buffer2) getkwd DATE-OBS] 1]
   }

   set console_msg "[ format $caption(sn_tarot,image2) [ ::sn_tarot::shortPath $filename 7 ] $result ]"
   ::sn_tarot::afficheConsole

   #-- Effectue une eventuelle correction de fond de ciel
   if {$subsky==1} {
      buf$num(buffer2) imaseries "BACK sub back_kernel=$back_kernel back_threshold=$back_threshold"
   }

   #---
   catch {
      lassign [ buf$num(buffer2) stat ] sh sb
      visu$num(visu2) cut [ list $sh $sb ]
   }

   #--- Affichage en mode logarithme
   if {$afflog2==1} {
      visu$num(visu2) cut [ ::sn_tarot::snBufLog $num(buffer2) $num(buffer2b) $side2 ]
   }

   visu$num(visu2) disp

   if {$result==""} {
      #--   configure la reglette de la visu2 selon le mode log/pas log
      ::sn_tarot::configScale 2 $afflog2
   } else {
      if {$afflog2==0} {
         set seuil [lindex [::sn_tarot::getSeuils $num(buffer2)] 0]
      } else {
         set seuil [lindex [::sn_tarot::getSeuils $num(buffer2b)] 0]
      }
      $zone(sh2) set $seuil
      $zone(labelh2) configure -text ""
   }
   set snvisu(candidate,starref_coords) ""
   set snvisu(candidate,host_coords) ""
   set snvisu(candidate,sn_coords) ""
}

#-----------------------------------------------------
## @brief commande du bouton "Aller à" de la fenêtre "Tarot SN Visu"
#
proc ::sn_tarot::gotoImage { } {
   variable This
   global caption zone info_image panneau

   set fram $This.snvisu.allera

   #---
   if { [ winfo exists $fram ] } {
      wm withdraw $fram
      wm deiconify $fram
      focus $fram.but_cancel
      return
   }

   #--- Create the toplevel window $This.snvisu.allera
   #--- Cree la fenetre $This.snvisu.allera de niveau le plus haut
   toplevel $fram -class Toplevel
   wm title $fram $caption(sn_tarot,secondary_title)
   set posx_snvisu_1 [ lindex [ split [ wm geometry $This.snvisu ] "+" ] 1 ]
   set posy_snvisu_1 [ lindex [ split [ wm geometry $This.snvisu ] "+" ] 2 ]
   wm geometry $fram +[ expr $posx_snvisu_1 + 490 ]+[ expr $posy_snvisu_1 + 160 ]
   wm transient $fram $This.snvisu
   wm resizable $fram 0 0
   wm protocol $fram WM_DELETE_WINDOW "set command_line2 \"\" ; destroy $fram"

   #--- Create the label and the command line
   #--- Cree l'etiquette et la ligne de commande
   frame $fram.frame1 -borderwidth 0 -relief raised
      label $fram.frame1.label -text $caption(sn_tarot,image_numero) \
         -borderwidth 0 -relief flat
      pack $fram.frame1.label -fill x -side left -padx 5 -pady 5
      entry $fram.frame1.command_line -textvariable panneau(command_line2) \
         -borderwidth 1 -relief groove -takefocus 1 -width 8
      pack $fram.frame1.command_line -fill x -side right -padx 5 -pady 5
   pack $fram.frame1 -side top -fill both -expand 1

   #--- Je place le focus immediatement dans la zone de saisie
   focus $fram.frame1.command_line

   #--- Create the button 'GO'
   #--- Cree le bouton 'GO'
   button $fram.but_go -text $caption(sn_tarot,go) -borderwidth 2 -width 10 \
     -command "::sn_tarot::cmdGoImage"
   pack $fram.but_go -side left -anchor w -padx 5 -pady 5 -ipadx 5 -ipady 5

   #--- Create the button 'Cancel'
   #--- Cree le bouton 'Annuler'
   button $fram.but_cancel -text $caption(sn_tarot,cancel) -borderwidth 2  -width 10 \
      -command "set command_line2 \"\" ; destroy $fram"
   pack $fram.but_cancel -side right -anchor w -padx 5 -pady 5 -ipadx 5 -ipady 5

   #--- La touche Return est equivalente au bouton "but_go"
   bind $fram <Key-Return>  { $This.snvisu.allera.but_go invoke }

   #--- La touche Escape est equivalente au bouton "but_cancel"
   bind $fram <Key-Escape>  { $This.snvisu.allera.but_cancel invoke }

   $fram.frame1.command_line selection range 0 end

   #--- La fenetre est active
   focus $fram

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $fram
}

#-----------------------------------------------------
##  @brief commande du bouton "Go" de la fenêtre "Aller à"
#
proc ::sn_tarot::cmdGoImage { } {
   variable This
   global rep panneau

   set objNo $panneau(command_line2)

   if {$objNo != ""} {
      set rep(index1) [expr {$objNo-1}]
      ::sn_tarot::searchGalaxy
      ::sn_tarot::displayImages
      destroy $This.snvisu.allera
   }
}

#-----------------------------------------------------
## @brief commande du bouton "Fond du ciel"  de la fenêtre "Tarot SN Visu"
#
proc ::sn_tarot::snSubSky { } {
   variable This
   variable console_msg

   set w $This.snvisu.fr4.but_background

   #--- Gestion du bouton 'background'
   $w configure -relief groove -state disabled
   update

   ::sn_tarot::displayImages 1

   #--- Gestion du bouton 'background'
   $w configure -relief raised -state normal
   update
}

#-----------------------------------------------------
## @brief commande du bouton "Blink" de la fenêtre "Tarot SN Visu"
#
proc ::sn_tarot::snBlinkImage { } {
   variable This
   global audace caption num snconfvisu snvisu zone rep panneau

   #--- Execute le blink uniquement s'il y a une image dans le canvas 1
   if { [ buf$num(buffer2) imageready ] == "0" } {
      return
   }

   #--- Animation en cours
   set snvisu(blink_go) "1"

   #--- Initialisation
   set rep(blink,last) ""
   set afflog          "$snvisu(afflog)"

   #---
   if {$afflog==0} {
      visu$num(visu1) buf $num(buffer1)
      visu$num(visu2) buf $num(buffer2)
   } else {
      visu$num(visu1) buf $num(buffer1b)
      visu$num(visu2) buf $num(buffer2b)
   }

   #--- Recentrage de l'image de reference
   set b [::buf::create]
   set ext $::conf(extension,defaut)
   buf$b extension "$ext"
   set compress [buf$audace(bufNo) compress]
   buf$b compress "$compress"
   set bitpix [buf$audace(bufNo) bitpix]
   buf$b bitpix "$bitpix"
   set filename [lindex $rep(x1) $rep(index1)]
   set dir $panneau(init_dir)
   if {$rep(blink,last)!=$filename} {
      set rep(blink,last) "$filename"
      buf$num(buffer2) copyto $b
      set dimx [lindex [buf$num(buffer1) getkwd NAXIS1 ] 1]
      set dimy [lindex [buf$num(buffer1) getkwd NAXIS2 ] 1]
      buf$b window [list 1 1 $dimx $dimy]
      buf$b            save [ file join $dir dummy2 ]
      buf$num(buffer1) save [ file join $dir dummy1 ]
      set objefile "__dummy__"
      set error [ catch {
         set wcs1 [::sn_tarot::snVerifWCS $num(buffer1)]
         set wcs2 [::sn_tarot::snVerifWCS $b]
         if {($wcs1==0)||($wcs2==0)} {
            ttscript2 "IMA/SERIES \"$dir\" \"dummy\" 1 2 \"$ext\" \"$dir\" \"$objefile\" 1 \"$ext\" STAT objefile"
            ttscript2 "IMA/SERIES \"$dir\" \"$objefile\" 1 2 \"$ext\" \"$dir\" \"dummyb\" 1 \"$ext\" REGISTER translate=never"
            ttscript2 "IMA/SERIES \"$dir\" \"$objefile\" 1 2 \"$ext\" \"$dir\" \"$objefile\" 1 \"$ext\" DELETE"
         } else {
            ttscript2 "IMA/SERIES \"$dir\" \"dummy\" 1 2 \"$ext\" \"$dir\" \"dummyb\" 1 \"$ext\" REGISTER matchwcs"
         }
      } msg ]
      #--- Interception de l'erreur
      if { $error == "1" } {
         tk_messageBox -title "$caption(sn_tarot,attention)" -type ok -message "$msg \n"
         #--- Detruit les fichiers intermediaires
         file delete [ file join $dir dummy1$ext ]
         file delete [ file join $dir dummy2$ext ]
         file delete [ file join $dir dummyb2$ext ]
         catch { file delete [ file join $rep(name1) __dummy__1$ext ] }
         file delete [ file join [pwd] com.lst ]
         file delete [ file join [pwd] dif.lst ]
         file delete [ file join [pwd] eq.lst ]
         file delete [ file join [pwd] in.lst ]
         file delete [ file join [pwd] ref.lst ]
         file delete [ file join [pwd] xy.lst ]
         #---
         return
      }
      buf$b load [ file join $dir dummyb2 ]
      #--- Affichage en mode logarithme
      if {$afflog==1} {
         set shsb [::sn_tarot::snBufLog $b $b]
      } else {
         set shsb [visu$num(visu2) cut]
      }
      #---
      set text0 "[buf$b getkwd MIPS-LO]"
      set text0 [lreplace $text0 1 1 [lindex $shsb 1]]
      buf$b setkwd $text0
      set text0 "[buf$b getkwd MIPS-HI]"
      set text0 [lreplace $text0 1 1 [lindex $shsb 0]]
      buf$b setkwd $text0
      buf$b save [ file join $dir dummyb2 ]
      ttscript2 "IMA/SERIES \"$dir\" \"dummyb\" 1 1 \"$ext\" \"$dir\" \"$objefile\" 1 \"$ext\" DELETE"
   } else {
      catch { buf$b load [ file join $dir dummyb2 ] }
   }

   #--- Gestion du bouton 'blink'
   $This.snvisu.fr4.but_blink_go configure -text $caption(sn_tarot,blink_stop) -command { set snvisu(exit_blink) "0" }
   update

   #--- Creation de la Tk_photoimage pour le blink
   catch { image delete imagevisu101 }
   ::visu::create $b 101 101
   image create photo imagevisu101
   visu101 zoom $snconfvisu(zoom_normal)
   visu101 disp [ list $snvisu(seuil_d_haut) $snvisu(seuil_d_bas) ]

   #--- Animation
   for { set t 1 } { $t <= $snconfvisu(nb_blink) } { incr t } {
      catch {
         $zone(image1) itemconfigure display -image imagevisu100
         update
         after $snconfvisu(delai_blink)
         $zone(image1) itemconfigure display -image imagevisu101
         update
         after $snconfvisu(delai_blink)
      }
      if { $snvisu(exit_blink) == "0" } {
         break
      }
   }

   #--- Detruit les visu et les Tk_photoimage
   ::visu::delete 101
   catch { image delete imagevisu101 }
   ::buf::delete $b

   #--- Detruit les fichiers intermediaires
   file delete [ file join $dir dummy1$ext ]
   file delete [ file join $dir dummy2$ext ]
   file delete [ file join $dir dummyb2$ext ]
   catch { file delete [ file join $dir __dummy__1$ext ] }
   file delete [ file join [pwd] com.lst ]
   file delete [ file join [pwd] dif.lst ]
   file delete [ file join [pwd] eq.lst ]
   file delete [ file join [pwd] in.lst ]
   file delete [ file join [pwd] ref.lst ]
   file delete [ file join [pwd] xy.lst ]

   #--- Reconfigure pour Aud'ACE normal
   catch {$zone(image1) itemconfigure display -image imagevisu100}
   update

   #--- Gestion du bouton 'blink'
   $This.snvisu.fr4.but_blink_go configure -text $caption(sn_tarot,blink_go) -command { set snvisu(exit_blink) "1" ; ::sn_tarot::snBlinkImage }
   update

   #--- Animation terminee
   set snvisu(blink_go) "0"
}

#-----------------------------------------------------
## @brief sauve la nouvelle image de référence
#  @param redisp
#
proc ::sn_tarot::saveImage { {redisp 1} } {
   variable console_msg
   global caption num rep

   #---
   set rep(blink,last) ""

   #--- on recharge l'image originale car on a pu enlever le ciel entre temps
   set filename [lindex $rep(x1) $rep(index1)]
   set a [catch {buf$num(buffer1) load $filename} result]
   if {$a==1} {
      return
   }
   if { $filename != "" } {
      set name [file tail $filename]
      set shortname [string range $name 0 [expr [string last - $name]-1]]
      if { $shortname != "" } {
         set filename [ file join $rep(name2) ${shortname}[file extension $name] ]
      } else {
         set filename [ file join $rep(name2) $name ]
      }
      #--- Destruction des eventuels fichiers existants deja
      catch { file delete $filename }
      catch { file delete $filename.gz }
      #---
      buf$num(buffer1) bitpix float
      if { $rep(gz) == "yes" } {
         set result [ buf$num(buffer1) save $filename ]
         gzip $filename
         set console_msg "$caption(sn_tarot,newref) -> $filename.gz"
      } else {
         set result [ buf$num(buffer1) save $filename ]
         set console_msg "$caption(sn_tarot,newref) -> [ ::sn_tarot::shortPath "" 7 ]"
      }
      set k [ lsearch $rep(x2) $filename ]
      if {$k==-1} {
         lappend rep(x2) $filename
      }
      if {$redisp==1} {
         ::sn_tarot::searchGalaxy
         ::sn_tarot::afficheConsole
         #--- Mise a jour de l'affichage avec la nouvelle image de reference
         ::sn_tarot::displayImages
      }
   } else {
      set console_msg "$caption(sn_tarot,0image)"
      ::sn_tarot::afficheConsole
   }
}

#-----------------------------------------------------
## @brief commande associée à la combobox de sélection
#  du dossier à traiter dans la fenêtre "Tarot SN Visu"
#
proc ::sn_tarot::snSelect { } {
   variable This
   global caption snconfvisu rep snvisu panneau

   set w $This.snvisu.fr4

   #-- definit le fichier a dezipper et le repertoire de destination
   set src [ file join $rep(archives) $snconfvisu(night).zip ]
   set dest $rep(name1)

   ::sn_tarot::unzipFile $src $dest

   #--   rafraichit la liste des fichiers presents (chemin complet) dans night
   set rep(x1) [ lsort -dictionary [ glob -nocomplain -type f -dir $rep(name1) *$::conf(extension,defaut) ] ]
   set rep(sum1) [ llength $rep(x1) ]

   #--   liste les images DSS manquantes
   set file_to_load ""
   foreach file $rep(x1) {
      set img [ file tail $file ]
      if { ![ file exists [ file join $rep(name3) $img ] ] } {
         lappend file_to_load $img
      }
   }

   #--
   if { $file_to_load ne "" } {
      set answer [tk_messageBox -title $caption(sn_tarot_go,attention) \
                     -icon info -type yesno \
                     -message [format $caption(sn_tarot,dss_manq) $file_to_load ]]
      if { $answer eq "yes" } {
         #--  bascule vers 'Personnel'
         if { $snconfvisu(pers_or_dss) == 1 } {
            set snconfvisu(pers_or_dss) 0
         }

         #--   inhibe le radiobouton DSS
         $w.but_rad1 configure -state disabled

         #--   ote l'extension pour ne garder que les noms courts
         regsub -all ".fit" $file_to_load "" file_to_load
         set total [ llength $file_to_load ]

         ::sn_tarot::listRequest $file_to_load

         #--   met a jour la liste des fichiers et leur nombre

         set rep(x3) [ lsort -dictionary [ glob -nocomplain -type f -dir $rep(name3) *$::conf(extension,defaut) ] ]
         set rep(sum3) [ llength $rep(x3) ]

         if { $rep(sum3) != 0 } {
            #--   desinhibe le radiobouton DSS
            $w.but_rad1 configure -state normal
         }
      }
   } else {
      #--   si pas de fichiers manquants
      tk_messageBox -title $caption(sn_tarot_go,attention) \
         -icon info  -type ok \
         -message "$caption(sn_tarot,dss_all)"
   }

   #--   affiche le nom de l'archive dans le titre
   ::sn_tarot::SiteChosen $snconfvisu(night)

   set snconfvisu(archive) $snconfvisu(night)
   $This.snvisu.lab configure -text [ format $caption(sn_tarot,title) $snconfvisu(archive) ]

   #--   selectionne la premiere image de la nouvelle serie
   set rep(index1) 0
   ::sn_tarot::searchGalaxy
   ::sn_tarot::displayImages
}

#-----------------------------------------------------
## @brief commande du bouton "Quitter" de la fenêtre "Tarot SN Visu"
#  @warning ferme totalement l'outil y compris le panneau
#
proc ::sn_tarot::cmdClose { } {
   variable This
   global num conf snvisu snconfvisu rep

   #--- On ne ferme SnVisu que s'il n'y a pas de blink en cours
   if { $snvisu(blink_go) == "1" || $snvisu(dss) == "1" } {
      return
   }

   set conf(sn_tarot,geometry) "[ wm geometry $This.snvisu ]"
   #--   memorise le nom du telescope et fichier selectionne
   set conf(sn_tarot,last_archive) "$snconfvisu(night)"

   #--- Nettoyage des eventuels fichiers crees
   foreach file [ list filter filter2 filter3 ] {
      set f [ file join $rep(name1) $file$conf(extension,defaut) ]
      if { [ file exist $f ] } {
         file delete $f
      }
   }

   #--- Supprime les images
   catch { image delete imagevisu100 ; image delete imagevisu200 }

   #--- Supprime les visu
   ::visu::delete $num(visu1)
   ::visu::delete $num(visu2)

   #--- Supprime les buffer
   foreach b [ list buffer1 buffer1b buffer2 buffer2b ] {
      ::buf::delete $num($b)
   }

   #--   supprime le paneau et la fenêtre snvisu et ses annexes
   ::confVisu::stopTool [::confVisu::getToolVisuNo ::sn_tarot] ::sn_tarot

   #--   supprime la fenêtre snvisu et ses annexes mais pas le panneau
   #destroy $This.snvisu
}

#--------------- bindings sans boutons -----------------

#-----------------------------------------------------
## @brief commande de binding associée a <Key-F5> et <Key-F6>
#  @remark affiche les mots clés de l'image
#  @param bufnum numéro du buffer, 1 ou 2 selon le côté
#
proc ::sn_tarot::snHeader { bufnum } {
   variable This
   global caption color num snvisu

   #--   raccourci
   set w $This.snvisu.snheader

   if { [ winfo exists $w ] } {
      destroy $w
   }

   if { [ buf$bufnum imageready ] == "1" } {
      if { $bufnum == "$num(buffer1)" } {
         set title "$caption(sn_tarot,fits_header) : $snvisu(name)     [ lindex [ buf$num(buffer1) getkwd DATE-OBS ] 1 ]"
      } elseif { $bufnum == "$num(buffer2)" } {
         set title "$caption(sn_tarot,fits_header) - $caption(sn_tarot,reference) : \
            $snvisu(name)      [ lindex [ buf$num(buffer2) getkwd DATE-OBS ] 1 ]"
      }
   } else {
      if { $bufnum == "$num(buffer1)" } {
         set title "$caption(sn_tarot,fits_header)"
      } elseif { $bufnum == "$num(buffer2)" } {
         set title "$caption(sn_tarot,fits_header) - $caption(sn_tarot,reference)"
      }
   }

   toplevel $w
   wm transient $w $This.snvisu
   if { [ buf$bufnum imageready ] == "1" } {
      wm minsize $w 632 303
   }
   wm resizable $w 1 1
   wm title $w "$title"
   wm geometry $w 632x303+3+75

   Scrolled_Text $w.slb -width 150 -height 20
   pack $w.slb -fill y -expand true

   if { [ buf$bufnum imageready ] == "1" } {
      $w.slb.list tag configure keyw -foreground $color(blue)
      $w.slb.list tag configure egal -foreground $color(black)
      $w.slb.list tag configure valu -foreground $color(red)
      $w.slb.list tag configure comm -foreground $color(green1)
      $w.slb.list tag configure unit -foreground $color(orange)
      foreach kwd [ lsort -dictionary [ buf$bufnum getkwds ] ] {
         set liste [ buf$bufnum getkwd $kwd ]
         #--- je fais une boucle pour traiter les mots cles a valeur multiple
         foreach { name value type comment unit } $liste {
            $w.slb.list insert end "[format "%8s" $name] " keyw
            $w.slb.list insert end "= "                    egal
            $w.slb.list insert end "$value "               valu
            $w.slb.list insert end "$comment "             comm
            $w.slb.list insert end "$unit\n"               unit
         }
      }
   } else {
      $w.slb.list insert end "$caption(sn_tarot,header,noimage)"
   }

   #--- La nouvelle fenetre est active
   focus $w

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $w
}

#-----------------------------------------------------
## @brief commande de binding associée à <Key-F7>
#  @remark applique un filtre médian sur l'image de la nuit pour éliminer les cosmiques
proc ::sn_tarot::noCosmic { } {
   global rep

   if { $rep(index1) != "-1" } {
      set ext $::conf(extension,defaut)
      set src [ lindex $rep(x1) $rep(index1) ]
      set name [ file rootname [ file tail $src ] ]
      ttscript2 "IMA/SERIES \"$rep(name1)\" \"$name\" . . $ext \"$rep(name1)\" filter . $ext FILTER kernel_type=med kernel_width=3 kernel_coef=1.2"
      ::sn_tarot::afficheImg $src filter$ext 1
   }
}

#-----------------------------------------------------
## @brief commande de binding associée à <Key-F8>
#  @remark applique un filtre pour éliminer les étoiles déjà présentes sur l'image de référence
#  @warning cette fonction ne peut être utilisée qu'avec des images de référence personnelles
#
proc ::sn_tarot::noStar { } {
   global conf rep audace

   if { $rep(index1) != "-1" && $rep(index2) != "-1"} {
      set ext $conf(extension,defaut)
      set src [ lindex $rep(x1) $rep(index1) ]
      set name [ file rootname [ file tail $src ] ]
      set file_image ${src}
      set file_image_out [file dirname $src]/filter${ext}
      set ext $conf(extension,defaut)
      set src [ lindex $rep(x2) $rep(index2) ]
      set name [ file rootname [ file tail $src ] ]
      set file_image_reference ${src}
      ::sn_tarot::subopt $file_image $file_image_reference 0 1
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save $file_image_out
      ::sn_tarot::displayImages 0 $file_image_out

   }
}

#-----------------sous-proc --------------------------

#-----------------------------------------------------
#  brief sous-proc de displayImages et snBlinkImage
#  param numbuf numéro du buffer
#  param bufNo
#  param side
#
proc ::sn_tarot::snBufLog { numbuf bufno {side 4} } {

   set n1 [buf$numbuf getpixelswidth]
   if {$n1==0} {
      return [list 0 0]
   }
   if {$numbuf!=$bufno} {
      buf$numbuf copyto $bufno
   }
   lassign   [ lrange [buf$bufno stat] 6 7 ] fond sigma
   set seuil [expr $fond-3.*$sigma]
   buf$bufno log 1000 [expr -1.*$seuil]
   lassign   [ lrange [buf$bufno stat] 6 7 ] fond sigma
   set sb    [expr $fond-5.*$sigma]
   set n1    [buf$bufno getpixelswidth]
   set n2    [buf$bufno getpixelsheight]
   set d     $side
   set x1    [expr $n1/2-$d] ; if {$x1<1} {set x1 1}
   set x2    [expr $n1/2+$d] ; if {$x1>$n1} {set x1 $n1}
   set y1    [expr $n2/2-$d] ; if {$y1<1} {set y1 1}
   set y2    [expr $n2/2+$d] ; if {$y2>$n2} {set y2 $n2}
   set box   [list $x1 $y1 $x2 $y2]
   set res   [buf$bufno stat $box]
   set maxi  [lindex $res 2]
   set sh    [expr 1.*$maxi]
   if {$sh<=$sb} {
      set sh [expr $sb+10.*$sigma]
   }
   buf$bufno setkwd  [list MIPS-LO [expr int($sb)] float "seuil bas" ""]
   buf$bufno setkwd  [list MIPS-HI [expr int($sh)] float "seuil haut" ""]
   buf$numbuf setkwd [list MIPS-LO [expr int($sb)] float "seuil bas" ""]
   buf$numbuf setkwd [list MIPS-HI [expr int($sh)] float "seuil haut" ""]
   return [list $sh $sb]
}

#-----------------------------------------------------
## @brief commande du bouton "Enregistrer" de la fenêtre "Tarot SN Visu"
#
proc ::sn_tarot::confirmSave { } {
   variable This
   global caption num

   if { [ buf$num(buffer1) imageready ] == "1" } {
      set choix [ tk_messageBox -type yesno -icon warning \
         -title "$caption(sn_tarot,save1)" \
         -message "$caption(sn_tarot,confirm)" ]
      if { [ winfo exists $This.snvisu ] } {
         if { $choix == "yes" } {
            ::sn_tarot::saveImage
         }
         focus $This.snvisu
      }
   }
}

#-----------------------------------------------------
#  brief routine de fixation des seuils
#  param numbuf numéro du buffer
#
proc ::sn_tarot::setSeuils { numbuf } {

   foreach { v kwd1 kwd2 val } [ list hi MIPS-HI DATAMAX nf lo MIPS-LO DATAMIN nf ] {
      set $v [ lindex [ buf$numbuf getkwd $kwd1 ] 1 ]
      if { [ set $v ] == "" } {
         set $v [ lindex [ buf$numbuf getkwd $kwd1 ] 1 ]
      }
      if { [ set $v ] == "" } {
         set $v $val
      }
   }

   if { $hi=="nf" || $lo=="nf" } {
      set hi [ lindex [ buf$numbuf getkwd MIPS-HI ] 1 ]
      set lo [ lindex [ buf$numbuf getkwd MIPS-LO ] 1 ]
   }
   visu$numbuf cut [ list $hi $lo ]
}

#-----------------------------------------------------
#  brief sous-proc de displayImages
#  param  visu 1 ou 2 selon le côte
#  param afflog
#
proc ::sn_tarot::configScale { visu {afflog 0} } {
   global snvisu zone num

   if {$afflog==0} {
      set nume $num(buffer${visu})
   } else {
      set nume $num(buffer${visu}b)
   }

   set scalecut [ lindex [ ::sn_tarot::getSeuils $nume ] 0 ]
   set err [ catch { buf$nume stat } s ]
   if { $err == "0" } {
      set scalemax [ lindex $s 2 ]
      set scalemin [ lindex $s 3 ]
      if {($scalecut>=$scalemin)&&($scalecut<=$scalemax)} {
         set ds1 [expr $scalemax-$scalecut]
         set ds2 [expr $scalecut-$scalemin]
         if {$ds1>$ds2} {
            set scalemin [expr $scalecut-$ds1]
         } else {
            set scalemax [expr $scalecut+$ds2]
         }
      }
      $zone(sh${visu}) configure -to $scalemax -from $scalemin
   }
   $zone(sh${visu}) set $scalecut
   update
}

#-----------------------------------------------------
#  brief routine de lecture des seuils ;
#  fixe une valeur par défaut en l'absence des mots clés MIPS-HI et MIPS-LO
#  param numbuf numéro du buffer
#
proc ::sn_tarot::getSeuils { numbuf } {

   foreach { v kwd1 kwd2 val } [ list hi MIPS-HI DATAMAX 32768 lo MIPS-LO DATAMIN 32768 ] {
      set $v [ lindex [ buf$numbuf getkwd $kwd1 ] 1 ]
      if { [ set $v ] == "" } {
         set $v [ lindex [ buf$numbuf getkwd $kwd1 ] 1 ]
      }
      if { [ set $v ] == "" } {
         set $v $val
      }
   }
   return [ list $hi $lo ]
}

#-----------------------------------------------------
#  brief affiche une image filtree ;
#  Sous-proc de noCosmic et de snSubSky
#  param src chemin du fichier source
#  param filter_file nom de l'image filtrée
#  param i 1 ou 2 selon le côté
#
proc ::sn_tarot::afficheImg { src filter_file i } {
   variable console_msg
   global caption num zone rep

   #--   toutes les images 'filter' sont dans rep(name1)
   set file [ file join $rep(name1) $filter_file ]

   set result [ buf$num(buffer$i) load $file ]
   visu$num(visu$i) disp
   $zone(sh$i) set [ lindex [ ::sn_tarot::getSeuils $num(buffer$i) ] 0 ]

   set console_msg "[ format $caption(sn_tarot,filter) [ ::sn_tarot::shortPath $src 7 ] \
      [ ::sn_tarot::shortPath $file 7 ] $result ]"
   ::sn_tarot::afficheConsole
}

#------------------------------------------------------------
#  brief affiche un message dans la mini-console :
# sous-proc de afficheImg et de displayImages
#
proc ::sn_tarot::afficheConsole { } {
   variable This
   variable console_msg

   set w $This.snvisu

   $w.lst1 insert end $console_msg
   $w.lst1 yview moveto 1.0

   #--- Disparition du sautillement des widgets inferieurs
   pack $w.lst1.scr1 -fill y -side right -anchor ne
}

#------------------------------------------------------------
## @brief cherche l'existence de la galaxie dans les répertoires 'references' et 'dss'
#  @remark configure les radioboutons en fonction de l'existence de la reference
#  sous-proc de ::sn_tarot::createTarotVisu, de ::sn_tarot::incrImage, de sn_tarot::snSelect et de ::sn_tarot::gotoImage
#
proc ::sn_tarot::searchGalaxy { } {
   variable This
   global rep snvisu

   #--   isole le nom court de l'image
   set snvisu(name) [ file tail [ lindex $rep(x1)  $rep(index1) ] ]

   foreach { rep_name f index but } [ list name2 x2 index2 but_rad0 name3 x3 index3 but_rad1 ] {
      set state disabled
      set rep($index) -1
      set reference_name [ file join $rep($rep_name) $snvisu(name) ]
      if { [ file exists $reference_name ] == 1 } {
         set rep($index) [ lsearch $rep($f) $reference_name ]
         set state normal
      }
      $This.snvisu.fr4.$but configure -state normal
   }
}

#------- toutes les proc Configuration ---------------

#------------------------------------------------------------
## @brief commande du bouton "Configuration" de la fenêtre "Tarot SN Visu"
#  créant la fenêtre "Configuration"
#
proc ::sn_tarot::snSetup { } {
   variable This
   global audace caption snconfvisu

   #--   raccourci
   set fconf $This.snvisu.config

   if { [ winfo exists $fconf ] } {
      wm withdraw $fconf
      wm deiconify $fconf
      #focus $fconf.but_cancel
      return
   }

   #--- Create the toplevel window $This.snvisu.config
   #--- Cree la fenetre $This.snvisu.config de niveau le plus haut
   toplevel $fconf -class Toplevel
   wm title $fconf $caption(sn_tarot,config_title)
   regsub -all {[\+|x]} [ wm geometry $This.snvisu ]  " " pos
   wm geometry $fconf +[expr {[ lindex $pos 1 ] + 165 } ]+[ expr {[ lindex $pos 2 ] + 100} ]
   wm resizable $fconf 0 0
   wm transient $fconf $This.snvisu
   wm protocol $fconf WM_DELETE_WINDOW { set command_line2 "" ; destroy $fconf }

   #--- Create the label and the radiobutton
   #--- Cree l'etiquette et les radiobuttons
   frame $fconf.frame1 -borderwidth 0 -relief raised
      #--- Label
      label $fconf.frame1.label -text $caption(sn_tarot,rafraich_images) \
         -borderwidth 0 -relief flat
      pack $fconf.frame1.label -fill x -side left -padx 5 -pady 5
      #--- Bouton radio 1 - Option "motion"
      radiobutton $fconf.frame1.but_rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text $caption(sn_tarot,motion) -value "motion" -variable snconfvisu(cuts_change) \
         -command "::sn_tarot::confBindCuts"
      pack $fconf.frame1.but_rad0 -side left -anchor center -padx 5 -pady 5
      #--- Bouton radio 2 - Option "release"
      radiobutton $fconf.frame1.but_rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text $caption(sn_tarot,release) -value "release" -variable snconfvisu(cuts_change) \
         -command "::sn_tarot::confBindCuts"
      pack $fconf.frame1.but_rad1 -side left -anchor center -padx 5 -pady 5
   pack $fconf.frame1 -side top -fill both -expand 1

   #--- Create the label and the command lines
   #--- Cree l'etiquette et les lignes de commande
   frame $fconf.frame2 -borderwidth 0 -relief raised
      #--- Label
      label $fconf.frame2.label -text $caption(sn_tarot,blink_delai) \
         -borderwidth 0 -relief flat
      pack $fconf.frame2.label -fill x -side left -padx 5 -pady 5
      #--- Entry
      entry $fconf.frame2.command_line -textvariable snconfvisu(delai_blink) \
         -borderwidth 1 -relief groove -takefocus 1 -width 8 -justify center
      pack $fconf.frame2.command_line -fill x -side left -padx 5 -pady 5
      #--- Label
      label $fconf.frame2.label1 -text $caption(sn_tarot,blink_nbre) \
         -borderwidth 0 -relief flat
      pack $fconf.frame2.label1 -fill x -side left -padx 5 -pady 5
      #--- Entry
      entry $fconf.frame2.command_line_1 -textvariable snconfvisu(nb_blink) \
         -borderwidth 1 -relief groove -takefocus 1 -width 8 -justify center
      pack $fconf.frame2.command_line_1 -fill x -side left -padx 5 -pady 5
      #--- Label
      label $fconf.frame2.label2 -text $caption(sn_tarot,auto_blink) \
         -borderwidth 0 -relief flat
      pack $fconf.frame2.label2 -fill x -side left -padx 5 -pady 5

      #--- Checkbutton
      checkbutton $fconf.frame2.auto -text "$caption(sn_tarot,auto_blink)" \
         -highlightthickness 0 -variable snconfvisu(auto_blink)
      pack $fconf.frame2.auto -anchor center -side left \
        -padx 5 -pady 5

   pack $fconf.frame2 -side top -fill both -expand 1

   #--- Create the label and the radiobutton
   #--- Cree l'etiquette et les radiobuttons
   frame $fconf.frame4 -borderwidth 0 -relief raised
      #--- Label
      label $fconf.frame4.label -text $caption(sn_tarot,image_gzip) \
         -borderwidth 0 -relief flat
      pack $fconf.frame4.label -fill x -side left -padx 5 -pady 5
      #--- Bouton radio 1 - Option enregistrement image non compressee
      radiobutton $fconf.frame4.but_rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$::conf(extension,defaut)" -value "no" -variable snconfvisu(gzip) \
         -command { set rep(gz) "$snconfvisu(gzip)" }
      pack $fconf.frame4.but_rad0 -side left -anchor center -padx 5 -pady 5
      #--- Bouton radio 2 - Option enregistrement image compressee
      radiobutton $fconf.frame4.but_rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$::conf(extension,defaut).gz" -value "yes" -variable snconfvisu(gzip) \
         -command { set rep(gz) "$snconfvisu(gzip)" }
      pack $fconf.frame4.but_rad1 -side left -anchor center -padx 5 -pady 5
   pack $fconf.frame4 -side top -fill both -expand 1

   #--- Create the button 'GO'
   #--- Cree le bouton 'GO'
   button $fconf.but_go -text $caption(sn_tarot,go) \
      -borderwidth 2 -width 8 -command "::sn_tarot::snSaveConfig"
   pack $fconf.but_go -side left -anchor w -padx 5 -pady 5

   #--- Create the button 'Cancel'
   #--- Cree le bouton 'Annuler'
   button $fconf.but_cancel -text $caption(sn_tarot,cancel) -width 8 \
      -borderwidth 2 -command "destroy $This.snvisu.config"
   pack $fconf.but_cancel -side right -anchor w -padx 5 -pady 5

   #--- Create the button 'Help'
   #--- Cree le bouton 'Aide'
   button $fconf.but_help -text $caption(sn_tarot,aide) \
      -borderwidth 2 -width 8 -command "::sn_tarot::snHelp sn_config"
   pack $fconf.but_help -side right -anchor w -padx 5 -pady 5

   #--- La touche Escape est equivalente au bouton "but_cancel"
   bind $fconf <Key-Escape> { $This.snvisu.config.but_cancel invoke }

   #--- La touche Return est equivalente au bouton "but_go"
   bind $fconf <Key-Return> { $This.snvisu.config.but_go invoke }

   #--- La fenetre est active
   focus $fconf

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $fconf
}

#------------------------------------------------------------
## @brief commande associée aux radiobuttons de sélection
#dans la fenêtre de Configuration
#
proc ::sn_tarot::confBindCuts { } {
   global zone num snconfvisu

   if { [ string tolower "$snconfvisu(cuts_change)" ] == "motion" } {
      set cmd Motion
   } else {
      set cmd ButtonRelease
   }
   bind $zone(sh1) <$cmd> { visu$num(visu1) disp }
   bind $zone(sh2) <$cmd> { visu$num(visu2) disp }
}

#------------------------------------------------------------
## @brief commande du bouton "Go" de la fenêtre "Configuration"
#  @remark sauve les valeurs de configuration sous forme de liste dans la variable conf(sn_tarot) ;
#  cette nouvelle configuration ne prend effet que lors du prochain lancement.
#
proc ::sn_tarot::snSaveConfig { } {
   variable This
   global audace conf caption snconfvisu

   set conf(sn_tarot) [ list \
      "$snconfvisu(cuts_change)" \
      "$snconfvisu(delai_blink)" \
      "$snconfvisu(nb_blink)" \
      "$snconfvisu(auto_blink)" \
      "$snconfvisu(gzip)" ]

   destroy $This.snvisu.config
   tk_messageBox -message "$caption(sn_tarot,alerte)" \
      -icon warning -title "$caption(sn_tarot,attention)"
}

#------------------  utilitaires ----------------------------

#------------------------------------------------------------
#  brief retourne le nom raccourci du répertoire à partir de Mes Documents/....
#  details utilisée pour avoir une longueur de fichier raisonnable
#  code
#  ::sn_tarot::shortPath "Mes Documents/audela/archives/tarot/dss/IC7.fit" 3
#  --> Mes Documents/audela/archives/tarot/dss/IC7.fit
#  ::sn_tarot::shortPath "Mes Documents/audela/archives/tarot/dss/IC7.fit" 4
#  --> audela/archives/tarot/dss/IC7.fit
#  ::sn_tarot::shortPath "Mes Documents/audela/archives/tarot/dss/IC7.fit" 7
#  --> dss/IC7.fit
#  endcode
#  n=3 Mes Documents/.... n=4 audela/... n=6 tarot/...
#  param dir nom du répertoire
#  param n nombre d'éléments à ôter
#
proc ::sn_tarot::shortPath { dir n } {

   set rep  [ lrange [ split $dir / ] $n end ]
   set f [ lindex $rep 0 ]
   foreach dos [ lrange $rep 1 end ] {
      set f [ file join $f $dos ]
   }
   return $f
}

#------------------------------------------------------------
## @brief décompresse un fichier zip vers un dossier
#  @param fullfile_zip nom complet du fichier à dézipper
#  @param path répertoire de destination
#
proc ::sn_tarot::unzipFile { fullfile_zip path } {
   global audace caption

   set ext $::conf(extension,defaut)

   #--   nettoie le dossier de destination
   set fics [ glob -nocomplain -type f -tails -dir $path *$ext ]
   set nb [ llength $fics ]
   if { $nb != 0 } {
      ttscript2 "IMA/SERIES \"$path\" \"$fics\" * * . . . . . DELETE"
   }

   #--   chemin de unzip.exe
   if { $::tcl_platform(os) == "Linux" } {
      set tarot_unzip unzip
   } else {
      set tarot_unzip [ file join $audace(rep_plugin) tool sn_tarot unzip.exe ]
   }
   #--   decompresse les images vers le dossier de destination
   exec $tarot_unzip -d $path $fullfile_zip

   #--   definit les repertoires de references et de dss en fonction du type de telescope
   ::sn_tarot::SiteChosen [ file tail $fullfile_zip ]

   #--   informe utilisateur
   set nb [ llength [ glob -nocomplain -type f -tails -dir $path *$ext ] ]
   set raccourci [ ::sn_tarot::shortPath $path 3 ]
   tk_messageBox -icon info -type ok \
      -message [ format $caption(sn_tarot_go,unzip) [ file tail $fullfile_zip ] $nb $raccourci ]
}

#------------------------------------------------------------
#  brief barre de progression du téléchargement des images DSS
#  return chemin de la fenêtre
#
proc ::sn_tarot::createProgressBar { } {
   variable This
   global caption snvisu

   set fconf $This.snvisu.progr

   toplevel $fconf -class Toplevel
   wm title $fconf "$caption(sn_tarot,dss_title)"
   regsub -all {[\+|x]} [ wm geometry $This.snvisu ]  " " pos
   lassign $pos -> -> x y
   incr x 100
   incr y 250
   wm geometry $fconf "420x78+$x+$y"
   wm resizable $fconf 0 0
   wm transient $fconf $This.snvisu
   wm protocol $fconf WM_DELETE_WINDOW ""

   pack [ frame $fconf.fr ]
   label $fconf.fr.d -textvariable snvisu(start_load) -width 40
   pack $fconf.fr.d -padx 10 -pady 5
   ttk::progressbar $fconf.fr.p -orient horizontal -length 400 -maximum 100.0 \
      -mode determinate -variable snvisu(progress)
   pack $fconf.fr.p -padx 10 -pady 5

   #--   initialise
   set snvisu(start_load) [ format $caption(sn_tarot,dss_galaxy) "-" ]
   set snvisu(progress) 0.0

   focus $fconf

   return $fconf
}

