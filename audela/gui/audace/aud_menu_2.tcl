#
## @file aud_menu_2.tcl
#  @brief Scripts regroupant les fonctionnalités du menu Affichage
#  $Id: aud_menu_2.tcl 14406 2018-04-12 20:30:44Z robertdelmas $
#

## namespace div
#  @brief Script de Digital Image Visualisation
#  @author Raymond Zachantke
#  @pre cet outil exige la présence d'une image dans le buffer de la visu

namespace eval ::div {

   #---------------------------------------------------------------------------
   #  brief initialisation
   #  param visuNo numéro de la visu
   #
   proc run { visuNo } {
      variable private
      global audace caption

      if {![buf[visu$visuNo buf] imageready]} {return}

      ::div::createIcon $visuNo
      ::div::initConf $visuNo

      set private(div,visu$visuNo,position) $::conf(div,visu$visuNo,position)
      set private(div,$visuNo,start) 1

      ::div::cmdReset $visuNo

      #--   cree les vecteurs Vx=abscisse FT= fonction de transfert \
      #--   H=Histogramme D=Distribution des intensités
      #--   associés à la couleur geree {r g b} et a visuNo
      uplevel #0 blt::vector create \
         ::Vx${visuNo} ::Bspline${visuNo}_x ::Bspline${visuNo}_y \
         ::FT_r${visuNo} ::FT_g${visuNo} ::FT_b${visuNo} \
         ::H_r${visuNo} ::H_g${visuNo} ::H_b${visuNo} \
         ::D_r${visuNo} ::D_g${visuNo} ::D_b${visuNo} -watchunset 1

      #--   remplit le vecteur abscisses x avec 0,1,2,3,....,255
      ::Vx${visuNo} seq 0 255 1

      #--   surveille le chargement d'une image et le changement des seuils
      ::confVisu::addFileNameListener $visuNo "::div::changeImg $visuNo"
      trace add variable conf(seuils,histoautohaut) write "::div::createHisto $visuNo"
      trace add variable conf(seuils,histoautobas) write "::div::createHisto $visuNo"
      trace add variable conf(seuils,visu$visuNo,mode) write "::div::createHisto $visuNo"
      #--   surveille le changement de palette
      trace add variable ::div::private(div,$visuNo,palette) write "::div::cmdModifyPalette $visuNo"
      #--   surveille le changement de boite
      trace add variable ::div::private(div,$visuNo,box) write "::div::configVisualBox $visuNo"

      #--   cree la fenetre de dialogue
      set private(div,$visuNo,this) "$audace(base).div$visuNo"
      ::div::createDialog $visuNo

      lassign $::conf(div,visu$visuNo,mode) k \
         private(div,$visuNo,lumen) private(div,$visuNo,contrast) \
         private(div,$visuNo,inversion) private(div,$visuNo,histo) \
         private(div,$visuNo,step) private(div,$visuNo,gamma)

      #--   initialise les vecteurs avec la palette courante
      ::div::readPalette $visuNo "myconf_${visuNo}.pal"

      #--   force la mise a jour pour les plans couleurs et l'histogramme
      ::div::changeImg $visuNo
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de l'outil "Fonction de transfert"
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(div,visu$visuNo,position) définit la position de la fenêtre
   #  - conf(div,visu$visuNo,scale) configure l'échelle de l'histogramme (linéaire ou logarithmique)
   #  - conf(div,visu$visuNo,mode) liste de paramètres utilisateurs enregistrés à la fermeture :
   #      -# rang de la palette dans la liste des palettes
   #      -# réglage de luminosité
   #      -# réglage de contraste
   #      -# inversion (0 ou 1)
   #      -# affichage de l'histogramme (0 ou 1)
   #      -# valeur du pas de la palette "Rampe"
   #      -# coefficient gamma de la palette "Gamma"
   #
   proc initConf { visuNo } {
      global conf

      if {![info exists conf(div,visu$visuNo,position)]} {
         set conf(div,visu$visuNo,position) "+40+100"
      }
      if {![info exists conf(div,visu$visuNo,scale)]} {
         set conf(div,visu$visuNo,scale) "0"
      }
   }

   #-----------------les commandes attachees a la fenetre----------------------

   #---------------------------------------------------------------------------
   ## @brief commande associée au checkbutton de l'histogramme
   #  @details affiche ou masque l'histogramme et la balance de dynamique
   #  @param visuNo numéro de la visu
   #
   proc cmdHisto { visuNo } {
      variable private

      set graph $private(div,$visuNo,this).g
      set tbl $private(div,$visuNo,this).val
      set k [lsearch -exact $private(div,$visuNo,listPalettes) $private(div,$visuNo,palette)]

      ::div::selectGraph $visuNo "histogram"
      ::div::selectGraph $visuNo "function"

      if {$private(div,$visuNo,histo) == "0"} {

         #--   masque les histogrammes
         foreach c {r g b} {
            $graph element configure histogram_$c -hide yes
         }

         #--   masque l'axe y2
         $graph axis configure y2 -hide yes
         #--   masque la dynamique
         foreach child {lab_niveau black white} {
            if {[blt::table search $tbl -pattern "$tbl.$child"] ne ""} {
               blt::table forget $tbl.$child
            }
         }

      } else {

         #--   demasque l'axe y2
         $graph axis configure y2 -hide no

         if {$k < "6" && [visu$visuNo image] != 100} {
            #--   demasque la dynamique
            blt::table $tbl \
            $tbl.lab_niveau 1,0 -anchor w -ipadx 10 -pady 10\
            $tbl.black 1,1 -anchor w -ipadx 2 -ipady 2 \
            $tbl.white 1,2 -anchor w -ipadx 2 -ipady 2
         }
      }
      update
   }

   #---------------------------------------------------------------------------
   ## @brief commande associée au radiobutton de sélection de l'échelle
   #  @details configure l'échelle de l'histogramme
   #  @param visuNo numéro de la visu
   #
   proc ::div::cmdConfigHistoScale { visuNo } {
      variable private
      global conf

      if {$conf(div,visu$visuNo,scale) == 0} {
         $private(div,$visuNo,this).g axis configure y2 -min 0 -max {} \
            -logscale 0
      } else {
         $private(div,$visuNo,this).g axis configure y2 -min {} -max {} \
            -logscale 1
      }
   }

   #---------------------------------------------------------------------------
   ## @brief commande associée au choix du plan couleur
   #  @details configure les courbes de fonctions en fonction du plan couleur et de la palette
   #  et la boîte de confinement
   #  @param visuNo numéro de la visu
   #
   proc cmdConfigGraph { visuNo } {
      variable private
      global caption

      ::div::selectGraph $visuNo function

      set k [lsearch -exact $private(div,$visuNo,listPalettes) $private(div,$visuNo,palette)]
      if {$k < 6} {
         set box $private(div,$visuNo,box)
      } elseif {$k in [list 6 7 8]} {
         #--   cas des palettes etirement,iris, rainbow
         set box [list 0 0 255 255]
      } elseif {$k == 9} {
         #--   cas de la palette mypal
         set box [::div::getBox $visuNo]
      }
      #--   actualise le dessin de la boite
      set private(div,$visuNo,box) $box
   }

   #---------------------------------------------------------------------------
   ## @brief calcule la boîte de confinement de la fonction de transfert
   #  @details invoqée par un réglage de luminosité ou de contraste
   #  @param visuNo numéro de la visu
   #
   proc cmdConfigBox { visuNo } {
      variable private

      set luminosite [expr {$private(div,$visuNo,lumen)*2/100.}]
      set pi [expr {acos(-1)}]
      set angle [expr {$pi/4*(1.+$private(div,$visuNo,contrast)/100.0)}]
      set pente [expr {tan($angle)}]
      set constante [expr {127.5*(1-$pente+$luminosite)}]

      set box [::div::setBox $pente $constante]

      #--   initialise avec les deux points extremes pour la courbe Bspline
      lassign $box x0 y0 x1 y1
      ::Bspline${visuNo}_x set [list $x0 $x1]
      ::Bspline${visuNo}_y set [list $y0 $y1]

      if {[info exists private(div,$visuNo,destination)]} {unset private(div,$visuNo,destination)}

      set private(div,$visuNo,box) $box

      if {$private(div,$visuNo,start) == 0} {
         ::div::updateValues $visuNo
      } else {
         set private(div,$visuNo,start) 0
      }
   }

   #---------------------------------------------------------------------------
   ## @brief commande associée à la combobox de sélection de la palette
   #  @details sélectionne la palette
   #  @param visuNo numéro de la visu
   #  @param args
   proc  cmdModifyPalette { visuNo args } {
      variable private

      set k [lsearch -exact $private(div,$visuNo,listPalettes) $private(div,$visuNo,palette)]

      #--   actualise les palettes
      if {$k < "6"} {
         ::div::cmdConfigBox $visuNo
      }  else {
         #--   Affecte les valeurs lues en mémoire ou dans un fichier
         switch -exact $k {
            6  {  set private(div,$visuNo,histo) 1
                  ::div::etireHisto $visuNo }
            7  {  ::div::readPalette $visuNo iris }
            8  {  ::div::readPalette $visuNo rainbow }
            9  {  ::div::readPalette $visuNo mypal_$visuNo }
         }

         #--   inverse la palette
         if {$private(div,$visuNo,inversion) == "1"} {
            ::div::cmdInvertValues $visuNo
            if {$k == 9} {
               ::div::cmdInvertValues $visuNo
            }
         }
         ::div::updatePalette $visuNo
      }

      ::div::cmdHisto $visuNo
      ::div::cmdConfigGraph $visuNo
      ::div::configTable $visuNo
   }

   #---------------------------------------------------------------------------
   ## @brief commande du bouton "Linéariser" (palettes Lineaire et Bspline)
   #  @details RAZ des réglages utilisateur
   #  @param visuNo numéro de la visu
   #
   proc cmdLinear { visuNo } {
      variable private

      #--   variable de la proc shift
      if {[info exists private(div,$visuNo,destination)]} {
         unset private(div,$visuNo,destination)
      }

      #--   palette Bspline
      if {$private(div,$visuNo,palette) eq "$::caption(div,ajust)"} {
         ::Bspline${visuNo}_x set {0 255}
         ::Bspline${visuNo}_y set {0 255}
      }

      ::div::cmdConfigBox $visuNo
      ::div::updateValues $visuNo
   }

   #---------------------------------------------------------------------------
   ## @brief commande du checkbutton "Palette inversée"
   #  @details inverse les palettes
   #  @param visuNo numéro de la visu
   #
   proc cmdInvertValues { visuNo } {
      variable private

      lassign $private(div,$visuNo,box) x0 y0 x1 y1
      foreach vector [::div::getVectorId $visuNo function] {
         $vector expr {$y1+$y0-$vector}
      }

      ::div::updatePalette $visuNo
   }

   #---------------------------------------------------------------------------
   ## @brief commande du bouton "Exporter vers le presse-papier"
   #  @details copie l'image vers le presse-papier de Windows
   #  @param visuNo numéro de la visu
   #
   proc cmdImg2Clipboard { visuNo } {
      package require Img
      package require twapi
      package require base64

      ::div::configGui $visuNo disabled

      #--   recupere le No de l'image TK
      set imageNo [visu$visuNo image]

      # First 14 bytes are bitmapfileheader - get rid of this
      set data [string range [base64::decode [imagevisu$imageNo data -format bmp]] 14 end]
      twapi::open_clipboard
      twapi::empty_clipboard
      twapi::write_clipboard 8 $data
      twapi::close_clipboard

      ::div::configGui $visuNo normal
   }

   #---------------------------------------------------------------------------
   ## @brief commande du bouton "Exporter vers un fichier"
   #  @details copie l'image dans un fichier
   #  @param visuNo numéro de la visu
   #
   proc cmdImg2File { visuNo } {
      global audace

      package require Img

      ::div::configGui $visuNo disabled

      #--   extrait les dimensions de l'image Tk
      set naxis1 [image width imagevisu$visuNo]
      set naxis2 [image height imagevisu$visuNo]

      #--   copie l'image Tk
      set temp [image create photo -gamma 2]
      $temp copy imagevisu$visuNo -from 1 1 $naxis1 $naxis2 -to 0 0 \
         -zoom 1 -compositingrule set

      set types {{"PNG" {.png}}}
      set filename [tk_getSaveFile \
         -filetypes $types \
         -initialdir $audace(rep_images) \
         -initialfile captureVisu$visuNo \
         -defaultextension .png]
      if {[llength $filename]} {
         $temp write -format png $filename
      }
      image delete $temp

      ::div::configGui $visuNo normal
   }

   #---------------------------------------------------------------------------
   #  brief commande du bouton "OK"
   #  param visuNo numéro de la visu
   #
   proc cmdOK { visuNo } {
      ::div::cmdApply $visuNo
      ::div::cmdClose $visuNo
   }

   #---------------------------------------------------------------------------
   ## @brief commande du bouton "Appliquer"
   #  @details copie l'image dans un fichier
   #  @param visuNo numéro de la visu
   #
   proc cmdApply { visuNo } {
      variable private
      global audace conf

      #--   sauve la position et le nom du reglage
      regsub {([0-9]+x[0-9]+)} [wm geometry $private(div,$visuNo,this)] "" conf(div,visu$visuNo,position)

      #--   sauve les parametres sous forme de liste
      set k [lsearch -exact $private(div,$visuNo,listPalettes) $private(div,$visuNo,palette)]
      set conf(div,visu$visuNo,mode) [list $k \
         $private(div,$visuNo,lumen) $private(div,$visuNo,contrast) \
         $private(div,$visuNo,inversion) $private(div,$visuNo,histo) \
         $private(div,$visuNo,step) $private(div,$visuNo,gamma)]

      #--   recopie la palette fonction_transfert_$visuNo.pal sous myconf_$visuNo.pal
      ::div::saveCurrentPal $visuNo myconf
   }

   #---------------------------------------------------------------------------
   ## @brief commande du bouton "Sauver ma palette"
   #  @details sauvegarde la palette fonction_transfert_$visuNo.pal sous mypal_$visuNo.pal
   #  et complète le menu des palettes disponibles
   #  @param visuNo numéro de la visu
   #
   proc cmdSaveMypal { visuNo } {
      variable private
      global caption

      ::div::updatePalette $visuNo
      ::div::saveCurrentPal $visuNo mypal

      #--   ajoute "Ma palette" a la liste des options si elle n'existe pas deja
      set mypal "$caption(div,mypal)"
      if {[lsearch $private(div,$visuNo,listPalettes) $mypal] eq "-1"} {
         lappend private(div,$visuNo,listPalettes) $mypal
         $private(div,$visuNo,this).val.palette configure -values $private(div,$visuNo,listPalettes)
      }
      set private(div,$visuNo,palette) $mypal
   }

   #---------------------------------------------------------------------------
   ## @brief commande du bouton "Réinitialiser"
   #  @param visuNo numéro de la visu
   #
   proc cmdReset { visuNo } {
      variable private
      global audace conf caption

      lassign $conf(div,visu$visuNo,mode) k \
         private(div,$visuNo,lumen) private(div,$visuNo,contrast) \
         private(div,$visuNo,inversion) private(div,$visuNo,histo) \
         private(div,$visuNo,step) private(div,$visuNo,gamma)

      #--   liste les palettes disponibles
      set private(div,$visuNo,listPalettes) ""
      foreach label [list lin log rampe gamma ajust sigma egal iris arc_en_ciel] {
         lappend private(div,$visuNo,listPalettes) "$caption(div,$label)"
      }

      if {[file exists [file join $::audace(rep_home) palette mypal_$visuNo.pal]]} {
         lappend private(div,$visuNo,listPalettes) "$caption(div,mypal)"
       } else {
         #--   si l'utilisateur a detruit mypal_$visuNo.pal
         if {$k == 9} {
            #--   retablit une palette lineaire
            set k 0
         }
      }
      set private(div,$visuNo,palette) "[lindex $private(div,$visuNo,listPalettes) $k]"

      #--   retablit la palette enregistree par 'Appliquer'
      #set private(div,$visuNo,start) 1
      if {[winfo exists $audace(base).div$visuNo]} {
         ::div::restorePalette $visuNo
         ::div::readPalette $visuNo "myconf_${visuNo}.pal"
      }
   }

   #---------------------------------------------------------------------------
   #  brief commande du bouton "Aide"
   #  param visuNo numéro de la visu
   #
   proc cmdHelp { $visuNo } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,affichage)" "1040palette.htm"
   }

   #---------------------------------------------------------------------------
   ## @brief commande du bouton "Fermer"
   #  @details ferme la fenêtre
   #  @param visuNo numéro de la visu
   #
   proc cmdClose { visuNo } {
      variable private
      global audace conf

      ::div::restorePalette $visuNo

      set this $private(div,$visuNo,this)

      #--   supprime les icones
      image delete \
         $private(div,$visuNo,pipette_blanche) \
         $private(div,$visuNo,pipette_noire) \
         $private(div,$visuNo,info)

      #--   supprime les bindings
      foreach scale [list scale_lumen scale_contrast scale_step scale_gamma] {
         bind $this.val.$scale <ButtonRelease> ""
      }
      bind $this <Key-Escape> ""

      #--   supprime les traces
      ::confVisu::removeFileNameListener $visuNo "::div::changeImg $visuNo"
      foreach v [list conf(seuils,histoautohaut) conf(seuils,histoautobas) conf(seuils,visu$visuNo,mode)] {
         trace remove variable $v write "::div::createHisto $visuNo"
      }
      trace remove variable ::div::private(div,$visuNo,palette) write "::div::cmdModifyPalette $visuNo"
      trace remove variable ::div::private(div,$visuNo,box) write "::div::configVisualBox $visuNo"

      #--   supprime les vecteurs
      blt::vector destroy ::Vx${visuNo} ::Bspline${visuNo}_x ::Bspline${visuNo}_y \
         ::FT_r${visuNo} ::FT_g${visuNo} ::FT_b${visuNo} \
         ::H_r${visuNo} ::H_g${visuNo} ::H_b${visuNo} \
         ::D_r${visuNo} ::D_g${visuNo} ::D_b${visuNo}

      destroy $this
   }

   #---------------------------------------------------------------------------
   ## @brief mise à jour de la combobox du choix des plans
   #  @details invoquee par un listener
   #  @param visuNo numéro de la visu
   #  @param args arguments du listener
   #
   proc changeImg { visuNo args } {
      variable private
      global caption

      #--   ferme l'outil si on efface l'image
      set fileName $::confVisu::private($visuNo,lastFileName)
      if {$fileName eq ""} {
          ::div::cmdClose $visuNo
      }

      set bufNo [visu$visuNo buf]
      set naxis [lindex [buf$bufNo getkwd NAXIS] 1]
      set tbl $private(div,$visuNo,this).val

      if {![winfo exists $tbl]} {return}

      if {$naxis eq "2"} {
         set private(div,$visuNo,plan) "gray"
      } else {
         set private(div,$visuNo,plan) "$caption(div,RGB)"
      }

      #--   teste l'existence de la combobox de choix du plan couleur
      set comboPlan 0
      if {[blt::table search $tbl -pattern "$tbl.plan"] ne ""} {
         set comboPlan 1
      }

      #--   configure la combobox de selection des plans en fonction de l'image
      if {$naxis eq "2" && $comboPlan eq "1"} {
         #--   masque la combobox pour les N&B
         blt::table forget $tbl.lab_plan $tbl.plan
      } elseif {$naxis eq "3" && $comboPlan eq "0"} {
         #--   affiche la combobox pour les RVB
         blt::table $tbl \
            $tbl.lab_plan 2,0 -anchor w -ipadx 10  \
            $tbl.plan 2,1 -anchor w -fill x -pady 10
      }

      ::div::createHisto $visuNo
      ::div::cmdModifyPalette $visuNo

      raise $private(div,$visuNo,this)
   }

   #---------------------------------------------------------------------------
   ## @brief dessine la boîte de confinement sur le graphique
   #  @details par cmdGetValue, cmdConfigBox et configGraph
   #  @param visuNo numéro de la visu
   #  @param args arguments du listener
   #
   proc configVisualBox { visuNo args } {
      variable private

      lassign $private(div,$visuNo,box) x0 y0 x1 y1

      $private(div,$visuNo,this).g marker configure box \
         -coords [list $x0 $y0 $x0 $y1 $x1 $y1 $x1 $y0]
   }

   #----------------configuration des elements de la fenetre-------------------

   #---------------------------------------------------------------------------
   ## @brief modifie l'épaisseur de la courbe (palette Linéaire et Bspline)
   #  @details invoquée par KeyPress B1 de la souris
   #  @param W  chemin fourni par KeyPress B1
   #  @param x  abscisse fournie par KeyPress B1
   #  @param y  ordonnée fournie par KeyPress B1
   #  @param visuNo numéro de la visu
   #
   proc activateElement { W x y visuNo } {
      variable private

      set k [lsearch -exact $private(div,$visuNo,listPalettes) $private(div,$visuNo,palette)]
      if {$k == "0" || $k == "4"} {
         set element [$W element get current]
         if {[$W element closest $x $y MyInfo $element]} {
            $W element configure $element -linewidth 3 -symbol none
         }
      }
   }

   #---------------------------------------------------------------------------
   ## @brief déeplace la courbe dans la fenêtre graphique (palette Linéaire et Bspline)
   #  @details invoquée par relâchement B1 de la souris
   #  @param W  chemin fourni par relâchement B1
   #  @param x  abscisse fournie par relâchement B1
   #  @param y  ordonnée fournie par relâchement B1
   #  @param visuNo numéro de la visu
   #
   proc shift { W x y visuNo } {
      variable private

      set k [lsearch -exact $private(div,$visuNo,listPalettes) $private(div,$visuNo,palette)]
      #--   arrete si fonction non deformable
      if {$k ni [list 0 4]} {return}

      set coord_x [expr {int([$W axis invtransform x $x])}]
      set coord_y [expr {int([$W axis invtransform y $y])}]

      #--   en cas de palette inversee
      if {$private(div,$visuNo,inversion) == "1"} {
         lassign $private(div,$visuNo,box) x0 y0 x1 y1
         set coord_y [expr {$y1+$y0-$coord_y}]
      }

      set private(div,$visuNo,destination) [list $coord_x $coord_y]
      $W element configure [$W element get current] -linewidth 2

      ::div::updateValues $visuNo
   }

   #---------------------------------------------------------------------------
   ## @brief configure la visibilité et la couleur des courbes
   #  @details invoquée par configGraph et cmdHisto
   #  @param visuNo numéro de la visu
   #  @param element élément à gérer {function|histogram}
   #
   proc selectGraph { visuNo element } {
      variable private
      global caption color

      set graph $private(div,$visuNo,this).g
      set plan $private(div,$visuNo,plan)
      set k [lsearch -exact $private(div,$visuNo,listPalettes) $private(div,$visuNo,palette)]

      #--   masque toutes les courbes
      $graph element configure ${element}_r ${element}_g ${element}_b -label "" -hide yes

      #---  demasque la courbe appropriee
      if {$plan eq "gray"} {
         $graph element configure ${element}_r -color $color(gray_pad) -hide no
      } elseif {$plan eq  "$caption(div,RGB)" || $k in [list 7 8]} {
         $graph element configure ${element}_r -color red -hide no
         $graph element configure ${element}_g -color green -hide no
         $graph element configure ${element}_b -color blue -hide no
      } elseif {$plan eq  "$caption(div,red)"} {
         $graph element configure ${element}_r -color red -hide no
      } elseif {$plan eq  "$caption(div,green)"} {
         $graph element configure ${element}_g -color green -hide no
      } elseif {$plan eq  "$caption(div,blue)"} {
         $graph element configure ${element}_b -color blue -hide no
      }
   }

   #---------------------------------------------------------------------------
   ## @brief configure le panneau en fonction de la palette
   #  @details invoquée par cmdModifyPalette, cmdSaveMypal et changeImg
   #  @param visuNo numéro de la visu
   #
   proc configTable { visuNo } {
      variable private

      set tbl $private(div,$visuNo,this).val
      set k [lsearch -exact $private(div,$visuNo,listPalettes) $private(div,$visuNo,palette)]

      #--   masque tout
      set widgetList [list lab_niveau black white lab_lumen scale_lumen lab_contrast \
         scale_contrast lab_step scale_step lab_gamma scale_gamma linear]
      foreach child $widgetList {
         if {[blt::table search $tbl -pattern "$tbl.$child"] ne ""} {
            blt::table forget $tbl.$child
         }
      }

      #--   desinhibe la fonction histogramme
      $tbl.histo configure -state normal

      if {$k < 6} {

         #--   affiche la dynamique
         if {$private(div,$visuNo,histo) == 1} {
            blt::table $tbl \
               $tbl.lab_niveau 1,0 -anchor w -ipadx 10 -pady 10 \
               $tbl.black 1,1 -anchor w -ipadx 2 -ipady 2 \
               $tbl.white 1,2 -anchor w -ipadx 2 -ipady 2
         }

         #--   affiche la luminosite et le contraste
         blt::table $tbl \
            $tbl.lab_lumen 3,0 -anchor w -ipadx 10 -height {35} \
            $tbl.scale_lumen 3,1 -columnspan 3 -fill x -height {35} \
            $tbl.lab_contrast 4,0 -anchor w -ipadx 10 -height {35} \
            $tbl.scale_contrast 4,1 -columnspan 3 -fill x -height {35}

      } elseif {$k == 6} {
         $tbl.histo configure -state disabled
      }

      #--   affiche la reglette specifique a la fonction
      switch -exact $k {
         0  {  #--   fonction de transfert lineaire
               blt::table $tbl $tbl.linear 7,3 -padx 10 -pady 10
            }
         1  {  #--   fonction de transfert log }
         2  {  #--   fonction de transfert rampe
               blt::table $tbl \
                  $tbl.lab_step 5,0 -anchor w -ipadx 10 -height {35} \
                  $tbl.scale_step 5,1 -columnspan 3 -fill x -height {35}
            }
         3  {  #--   fonction de transfert gamma
               blt::table $tbl \
                  $tbl.lab_gamma 5,0 -anchor w -ipadx 10 -height {35} \
                  $tbl.scale_gamma 5,1 -columnspan 3 -fill x -height {35}
            }
         4  {  #--   fonction de transfert courbe libre
               blt::table $tbl $tbl.linear 7,3 -padx 10 -pady 10
            }
      }
   }

   #---------------------------------------------------------------------------
   ## @brief retourne le nom des vecteurs ordonnées de la palette
   #  @details invoquée par cmdModifyPalette, cmdSaveMypal et changeImg
   #  @param visuNo numéro de la visu
   #  @param prefixe
   #  @return liste des noms de vecteurs de l'axe des ordonnées associés aux éléments dont le nom commence par $prefixe
   #
   proc getVectorId { visuNo prefixe } {
      variable private

      set graph $private(div,$visuNo,this).g
      set element_names [$graph element names "${prefixe}*"]

      for {set i 0} {$i < [llength $element_names]} {incr i} {
        lappend vector_list [lindex [$graph element configure [lindex $element_names $i] -ydata] end]
      }

      #--   trie dans l'ordre r g b
      set vector_list [linsert $vector_list 0 [lindex $vector_list end]]
      set vector_list [lrange $vector_list 0 2]

      return $vector_list
   }

   #-----------------------gestion du fichier palette--------------------------

   #---------------------------------------------------------------------------
   #  brief actualise le fichier fonction_transfert_$visuNo.pal
   #  details invoquée par cmdModifyPalette, cmdInvertValues, cmdSaveMypal et updateValues
   #  param visuNo numéro de la visu
   #  param args
   #
   proc updatePalette { visuNo args } {
      set rep $::audace(rep_temp)
      set palette fonction_transfert_$visuNo
      lassign [::div::getVectorId $visuNo function] vector1 vector2 vector3

      #--   ecrit le fichier palette
      set f [open [file join $rep $palette.pal] w]
      for {set k 0} {$k < 256} {incr k} {
         set data "[set ${vector1}($k)] [set ${vector2}($k)] [set ${vector3}($k)]"
         #::console::affiche_resultat "$data\n"
         puts $f "$data"
      }
      close $f

      #--   affiche les couleurs
      visu$visuNo paldir "$rep"
      visu$visuNo pal $palette
   }

   #---------------------------------------------------------------------------
   #  brief les vecteurs graphiques avec un fichier palette
   #  details invoquée par run (démarrage) et configTable
   #  param visuNo numéro de la visu
   #  param palette "" par défaut
   #
   proc readPalette { visuNo {palette ""} } {
      global audace conf

      #--   definit la source de la palette
      if {$palette in [list gray iris rainbow "mypal_${visuNo}" "myconfpal_${visuNo}.pal" ]} {
         set srcFile [file join $conf(rep_userPalette) $palette.pal]
      } else {
         #--   cas du demarrage normal
         set srcFile [file join $audace(rep_temp) fonction_transfert_$visuNo.pal]
      }

      #--   reset les fonctions de transfert rgb dans l'ordre
      lassign [::div::getVectorId $visuNo function] vector1 vector2 vector3
      $vector1 length 0 ; $vector2 length 0 ; $vector3 length 0

      #--   affecte les valeurs aux vecteurs couleur
      set f [open $srcFile r]
      while {![eof $f]} {
         foreach {a b c} [gets $f] {
            $vector1 append $a
            $vector2 append $b
            $vector3 append $c
         }
      }
      close $f
   }

   #---------------------------------------------------------------------------
   #  brief ferme de le fenêtre
   #  details invoquée par cmdReset et cmdClose
   #  param visuNo numéro de la visu
   #
   proc restorePalette { visuNo } {
      global audace conf

      #--   retablit la palette enregistree par 'Appliquer'
      set src [file join $conf(rep_userPalette) myconf_$visuNo.pal]
      set dest [file join $audace(rep_temp) fonction_transfert_$visuNo.pal]
      file copy -force $src $dest

      #--   affiche les couleurs
      visu$visuNo paldir "$audace(rep_temp)"
      visu$visuNo pal fonction_transfert_$visuNo
   }

   #---------------------------------------------------------------------------
   ## @brief sauve fonction_transfert_$visuNo.pal dans $conf(rep_userPalette)
   #  @details invoquée cmdApply et cmdSaveMypal
   #  @param visuNo numéro de la visu
   #  @param name chemin du fichier
   #
   proc saveCurrentPal { visuNo name } {
      global audace conf

      set src [file join $audace(rep_temp) fonction_transfert_$visuNo.pal]
      set dest [file join $conf(rep_userPalette) ${name}_${visuNo}.pal]
      file copy -force $src $dest
   }

   #-----------------------fonctions d'info et de calcul-----------------------

   #---------------------------------------------------------------------------
   #  brief mise a jour
   #  details invoquée par cmdConfigBox, cmdLinear, shift, scale_lumen et scale_contrast
   #  param visuNo numéro de la visu
   #
   proc updateValues { visuNo } {
      variable private
      global caption

      set k [lsearch -exact $private(div,$visuNo,listPalettes) $private(div,$visuNo,palette)]

      #--   definit les limites de representation
      lassign $private(div,$visuNo,box) x0 y0 x1 y1
      set plage_x [expr {$x1-$x0}]
      set plage_y [expr {$y1-$y0}]

      ::blt::vector create vx vy -watchunset 1

      #--   pre-calcul de la dynamique
      vx seq 0 255 1
      vy expr {(vx-$x0)*1./$plage_x}

      switch -exact $k {
         0  {  #--   fonction linaire
               if {![info exists private(div,$visuNo,destination)]} {
                  #--   droite simple
                  vy expr {vy*$plage_y+$y0}

               } else {
                  #--   droite bi-modale
                  lassign $private(div,$visuNo,destination) x2 y2
                  if {$x2 < $x0 || $x2 > $x1 || $y2 < $y0 || $y2 > $y1} {return}
                  lassign [::div::getPente [list $x0 $y0 $x2 $y2]] pente1 ord_orig1
                  lassign [::div::getPente [list $x2 $y2 $x1 $y1]] pente2 ord_orig2
                  for {set x $x0} {$x <= $x1} {incr x} {
                     if {$x < $x2} {
                        set vy($x) [expr {$x*$pente1+$ord_orig1}]
                     } elseif {$x >= $x2 && $x <= $x1} {
                        set vy($x) [expr {$x*$pente2+$ord_orig2}]
                     }
                  }
               }
            }
         1  {  #--   fonction log
               for {set x 0} {$x <= 255} {incr x} {
                  if {$x <= $x0} {
                     set vy($x) 0
                  } elseif {$x >= $x1} {
                     set vy($x) 255
                  } else {
                     set vy($x) [expr { log($vy($x) * 255. ) * 43.954 + 10.257 }]
                     set vy($x) [expr { $vy($x) * $plage_y / 255. + $y0 }]
                  }
               }

            }
         2  {  #--   fonction rampe
               set n $private(div,$visuNo,step)
               vy expr {round(vy*$n)}
               vy expr {vy*$plage_y*1./$n+$y0}
            }
         3  {  #--   fonction gamma
               vy expr {vy*(vy > 0)}
               vy expr {$plage_y*vy^$private(div,$visuNo,gamma)+$y0}
            }
         4  {  #--   fonction courbe
               if {![info exists private(div,$visuNo,destination)]} {
                  #--   ligne droite par defaut
                  vy expr {$plage_y*vy+$y0}
               } else {
                  #--   ajoute les coordonnees du point s'ils sont dans l'intervalle de confinement
                  #--   ruse avec le nom et les valeurs des vecteurs
                  set x_min "::Bspline${visuNo}_x(min)"
                  set x_max "::Bspline${visuNo}_x(max)"
                  set y_min "::Bspline${visuNo}_y(min)"
                  set y_max "::Bspline${visuNo}_y(max)"
                  lassign $private(div,$visuNo,destination) x y
                  if {$x > [set $x_min] && $x < [set $x_max] && $y > [set $y_min] && $y < [set $y_max]} {
                     ::Bspline${visuNo}_x append $x
                     ::Bspline${visuNo}_y append $y
                     #--   tri par ordre croissant
                     ::Bspline${visuNo}_x sort ::Bspline${visuNo}_y
                     #--   interpole vy pour toutes les valeurs de ::Vx${visuNo}
                     blt::spline quadratic ::Bspline${visuNo}_x ::Bspline${visuNo}_y ::Vx${visuNo} vy
                  }
               }
            }
         5  {  #--   fonction sigmoîde ou tangente hyperbolique
               vy expr {(vx-($x0+$x1)/2.)*5.2/$plage_x}
               vy expr {$plage_y/2.*(1+tanh(vy))+$y0}
            }
      }

      #--   remplace les valeurs < minimum (>=0) par le minimum et celles > maximum (<=255) par le maximum
      set vy(0:$x0) $y0
      set vy($x1:255) $y1

      #--   transfert les valeurs vers les vecteurs graphiques
      lassign [::div::getVectorId $visuNo function] vector1 vector2 vector3
      switch $private(div,$visuNo,plan) \
         "gray"                  {  $vector1 set vy ; $vector2 set vy ; $vector3 set vy } \
         "$caption(div,RGB)"     {  $vector1 set vy ; $vector2 set vy ; $vector3 set vy } \
         "$caption(div,red)"     {  $vector1 set vy } \
         "$caption(div,green)"   {  $vector2 set vy } \
         "$caption(div,blue)"    {  $vector3 set vy }

      ::blt::vector destroy vx vy

      if {$private(div,$visuNo,inversion) eq "1"} {
         ::div::cmdInvertValues $visuNo
      }

      ::div::updatePalette $visuNo
   }

   #---------------------------------------------------------------------------
   #  brief calcule l'histogramme cumulé sur chaque plan couleur même si image N&B
   #  details invoquée par cmdModifyPalette
   #  param visuNo numéro de la visu
   #
   proc etireHisto { visuNo } {
      variable private

      set Flist [::div::getVectorId $visuNo function]
      set Hlist [::div::getVectorId $visuNo histogram]

      #--   active le calcul de l'histogramme
      set private(div,$visuNo,histo) 1
      ::div::cmdHisto $visuNo

      blt::vector create cumul -watchunset 1
      foreach v_function $Flist v_histo $Hlist {
         cumul set $v_histo
         #--   calcule le cumul
         for {set i 1} {$i < 256} {incr i} {
            set j [expr {$i-1}]
            set cumul($i) [expr {$cumul($j)+$cumul($i)}]
         }
         cumul expr {cumul*255/$cumul(max)}
         $v_function set cumul

         #--   acceleration si image grise
         if {$private(div,$visuNo,plan) eq "gray"} {
            [lindex $Flist 1] set cumul
            [lindex $Flist 2] set cumul
            break
         }
      }
      blt::vector destroy cumul
   }

   #---------------------------------------------------------------------------
   #  brief retourne la pente et l'ordonnée à l'origine de la
   #  diagonale ascendante d'une boîte rectangulaire
   #  details invoquée par cmdGetValue et updateValues
   #  param box coordonnées {x0 y0 x1 y1} d'une boîte rectangulaire
   #  return pente et ordonnée à l'origine de la diagonale
   #
   proc getPente { box } {
      lassign $box x0 y0 x1 y1
      set pente [expr {($y1-$y0)*1./($x1-$x0)}]
      set ordonnee_origine [expr {int($y1-$x1*$pente)}]

      return [list $pente $ordonnee_origine]
   }

   #---------------------------------------------------------------------------
   #  brief retourne les limites de la boîte de confinement de la fonction de transfert
   #  à partir de l'équation de la diagonale (une droite)
   #  details invoquée par cmdConfigBox
   #  param pente pente de la droite
   #  param cosntante ordonnée à l'origine
   #  return coordonnées de la boîte de confinement
   #
   proc setBox { pente constante } {
      #--   definition des bornes x et y pour que 0<=x<=255 et 0<=y<=255
      blt::vector create borne1 borne2 vx -watchunset 1
      vx seq 0 255 1
      borne1 expr {round(vx*$pente+$constante)}
      borne2 expr {borne1 >= 0 && borne1 < 256}
      set indexes [borne2 search 1]
      set x0 [lindex $indexes 0]
      set x1 [lindex $indexes end]
      set y0 [expr {int($borne1($x0))}]
      set y1 [expr {int($borne1($x1))}]
      blt::vector destroy borne1 borne2 vx

      return [list $x0 $y0 $x1 $y1]
   }

   #---------------------------------------------------------------------------
   #  brief retourne les limites de la boîte de confinement de la fonction de transfert
   #  details invoquée par cmdConfigGraph
   #  param visuNo numéro de la visu
   #  return coordonnées de la boîte de confinement
   #
   proc getBox { visuNo } {
      lassign [list 0 0 255 255] x0 y0 x1 y1
      blt::vector create vy -watchunset 1
      #--   prend le vecteur rouge
      ::FT_r$visuNo dup vy
      set y0 [expr {int($vy(min))}]
      set y1 [expr {int($vy(max))}]
      set x0 [lindex [vy search $y0] end]
      set x1 [lindex [vy search $y1] 0]
      blt::vector destroy vy

      return [list $x0 $y0 $x1 $y1]
   }

   #---------------------------------------------------------------------------
   #  brief créé l'histogramme
   #  details invoquée par un changement de seuil et d'image
   #  param visuNo numéro de la visu
   #  param args arguments
   #
   proc createHisto { visuNo args } {
      variable private

      ::div::configGui $visuNo disabled

      set bufNo [visu$visuNo buf]
      set imagetype $private(div,$visuNo,plan)
      set vectorList [::div::getVectorId $visuNo histogram]
      foreach v $vectorList {$v length 0}

      #--   reset des vecteurs de distribution des pixels et de l'histogramme
      foreach v [list ::D_r$visuNo ::D_g$visuNo ::D_b$visuNo] {$v length 0}

      if {$imagetype eq "gray"} {
         set bufList [list $bufNo]
         set vectors [lindex $vectorList 0]
      } else {
         #--   separe les 3 composantes R G B
         #rgb_split $bufNo
         set bufList [::div::emulRGB_split $bufNo]
         set vectors $vectorList
      }

      foreach buf $bufList vector $vectors {

         #--   identifie le vecteur Distribution
         regsub "::H_" $vector "::D_" vectorIntervalle
         $vectorIntervalle length 0

         set stat [buf$buf stat]
         lassign $stat max_disable min_disable max_loadima min_loadima moyenne

         switch $::conf(seuils,visu$visuNo,mode) {
            disable     {  set max $max_disable ; set min $min_disable }
            loadima     {  set max $max_loadima ; set min $min_loadima }
            iris        {  set min $::conf(seuils,irisautobas)
                           set max $::conf(seuils,irisautohaut)
                        }
            histoauto   {  #--   prend en compte l'histogramme sur une partie de la plage
                           set keytype FLOAT
                           buf$bufNo imaseries "CUTS lofrac=[expr 0.01*$::conf(seuils,histoautobas)] hifrac=[expr 0.01*$::conf(seuils,histoautohaut)] keytype=$keytype"
                           set min [expr {[lindex [buf$bufNo getkwd MIPS-LO] 1]}]
                           set max [expr {[lindex [buf$bufNo getkwd MIPS-HI] 1]}]
                        }
            initiaux    {  #--   prend en compte les seuils de l'image
                           set min [expr {[lindex [buf$bufNo getkwd MIPS-LO] 1]}]
                           set max [expr {[lindex [buf$bufNo getkwd MIPS-HI] 1]}]
                        }
         }

         $vector length 0
         set stat [buf$buf histo 255 $min $max]
         $vector append 0 [lindex $stat 0]
         #--   complete le vecteur Distribution
         $vectorIntervalle set [lindex $stat 2]
         set sum [set ${vector}(sum)]
         #--   densite entre 0 et 100
         if {$sum !=0} {
            $vector expr {$vector*100/$sum}
         } else {
            #--   passe en mode lineaire a cause de sum = 0
            $private(div,$visuNo,this).val.histlin invoke
         }
      }

      if {$imagetype ne "gray"} {
         #--   detruit les buffers provisoires
         foreach buf $bufList {::buf::delete $buf}
      } else {
         #--   cas d'une image non RGB ; recopie le vector dans les deux autres
         ::H_g$visuNo set ::H_r$visuNo
         ::H_b$visuNo set ::H_r$visuNo
         ::D_g$visuNo set ::D_r$visuNo
         ::D_b$visuNo set ::D_r$visuNo
     }

     ::div::configGui $visuNo normal
   }

   #-----------------------------configuration du GUI--------------------------

   #---------------------------------------------------------------------------
   #  brief créé la fenêtre
   #  param visuNo numéro de la visu
   #
   proc createDialog { visuNo } {
      variable private
      global conf caption color

      set this $private(div,$visuNo,this)
      if {[winfo exists $this]} {destroy $this}

      toplevel $this
      wm resizable $this 0 0
      wm deiconify $this
      wm title $this "$caption(audace,menu,display) (visu$visuNo) - $caption(audace,menu,palette)"
      wm geometry $this $private(div,visu$visuNo,position)
      wm protocol $this WM_DELETE_WINDOW "::div::cmdClose $visuNo"

      #--   cree un frame pour le graphique
      blt::graph $this.g -plotbackground $color(white) -relief raised -borderwidth 1 -width 400 \
         -leftmargin 67 -rightmargin 67 -height 346 -topmargin 30 -bottommargin 50
      pack  $this.g -in $this -anchor n -side top -fill both -expand 1

      foreach c {r g b} {
         $this.g element create function_$c -xdata ::Vx${visuNo} -ydata ::FT_$c$visuNo \
            -hide no -symbol none -linewidth 2 -smooth quadratic
         $this.g element bind function_$c <ButtonPress-1> [list ::div::activateElement %W %x %y $visuNo]
         $this.g element bind function_$c <ButtonRelease-1> [list ::div::shift %W %x %y $visuNo]
         $this.g element create histogram_$c -xdata ::Vx${visuNo} -ydata ::H_$c$visuNo \
            -hide yes -mapx x2 -mapy y2 -symbol none -linewidth 2 -smooth quadratic
      }

      #--   configure les axes
      $this.g axis configure x -title $caption(div,in)
      $this.g axis configure y -title $caption(div,out)
      $this.g axis configure x y x2 -min 0 -max 255 -subdivision 10
      $this.g axis configure y2 -title "%" -min {} -max {} -subdivision 10 -logscale yes -hide yes

      #--   masque la legende
      $this.g legend configure -hide yes -position bottom

      #--   cree la boite de confinement
      $this.g marker create polygon -element box -name box -under 1 \
         -dashes dash -linewidth 1 -outline black -fill ""

      set tbl "$this.val"
      frame $tbl -borderwidth 1 -relief raised

      radiobutton $tbl.histlin -text "$caption(div,lin)" \
         -indicatoron 1 -variable ::conf(div,visu$visuNo,scale) \
         -value 0 -command  [list ::div::cmdConfigHistoScale $visuNo ]

      radiobutton $tbl.histlog -text "$caption(div,log)"  \
         -indicatoron 1 -variable ::conf(div,visu$visuNo,scale) \
         -value 1 -command [list ::div::cmdConfigHistoScale $visuNo ]

      #--   checkbutton pour affichage de l'histogramme
      checkbutton $tbl.histo -text $caption(div,histo) \
         -indicatoron "1" -onvalue "1" -offvalue "0" \
         -variable ::div::private(div,$visuNo,histo) \
         -command "::div::cmdHisto $visuNo"

      #--   ligne de reglage des niveaux
      Label $tbl.lab_niveau -text $caption(div,niveaux)
      button $tbl.black  -image $private(div,$visuNo,pipette_noire) -borderwidth 3 \
         -width 16 -command "::div::cmdGetValue $visuNo black "
      button $tbl.white -image $private(div,$visuNo,pipette_blanche) -borderwidth 3 \
         -width 16 -command "::div::cmdGetValue $visuNo white"

      #--   choix des plans
      Label $tbl.lab_plan -text $caption(div,plan)
      set private(div,$visuNo,listPlans) [list "$caption(div,RGB)" "$caption(div,red)" \
            "$caption(div,green)" "$caption(div,blue)"]
      ComboBox $tbl.plan -textvariable ::div::private(div,$visuNo,plan) -relief sunken \
         -height 4 -width 4 -values $private(div,$visuNo,listPlans) \
         -modifycmd "::div::cmdConfigGraph $visuNo"

      #--   les reglettes
      foreach label {lumen contrast step gamma} {
         Label $tbl.lab_$label -text "$caption(div,$label)"
         ::div::createScale $visuNo $label
      }
      $tbl.scale_lumen configure -from -99 -to 99 -resolution 1
      bind $tbl.scale_lumen <ButtonRelease> "::div::cmdConfigBox $visuNo"
      $tbl.scale_contrast configure -from -100 -to 99 -resolution 1
      bind $tbl.scale_contrast <ButtonRelease> "::div::cmdConfigBox $visuNo"
      $tbl.scale_step configure  -from 5 -to 15 -resolution 1
      bind $tbl.scale_step <ButtonRelease> "::div::updateValues $visuNo"
      $tbl.scale_gamma configure -from 0.02 -to 8 -resolution 0.01
      bind $tbl.scale_gamma <ButtonRelease> "::div::updateValues $visuNo"

      #--   liste les palettes disponibles
      Label $tbl.lab_fonction -text $caption(div,fonction)
      set labelwidth [::tkutil::lgEntryComboBox $private(div,$visuNo,listPalettes)]
      ComboBox $tbl.palette -textvariable ::div::private(div,$visuNo,palette) \
         -relief sunken -width $labelwidth -height 9 \
         -values $private(div,$visuNo,listPalettes)

      #--   bouton de linearisation
      button $tbl.linear -text $caption(div,lineariser) -borderwidth 3 -width 15 \
         -command "::div::cmdLinear $visuNo"

      frame $tbl.spec

      #--   checkbutton d'inversion
      checkbutton $tbl.spec.inv -text $caption(div,inverse) \
         -indicatoron "1" -onvalue "1" -offvalue "0" \
         -variable ::div::private(div,$visuNo,inversion) \
         -command "::div::cmdInvertValues $visuNo"
      pack $tbl.spec.inv -side left -padx 8 -pady 3

      #--   bouton de creation de ma palette
      button $tbl.spec.save -text "$caption(div,save)" -borderwidth 2 -width 15 \
         -relief raised -command "::div::cmdSaveMypal $visuNo"
      pack $tbl.spec.save -side left -pady 3

      if { $::tcl_platform(platform) == "windows" } {
         #--   bouton d'exportation de l'image (pour Windows seulement)
         button $tbl.spec.copy -text $caption(div,copy) -borderwidth 2 -width 30 \
            -relief raised -command "::div::cmdImg2Clipboard $visuNo"
         pack $tbl.spec.copy -side left -padx 5 -pady 3
      } else {
         #--   bouton d'exportation de l'image vers un fichier .png
         button $tbl.spec.copy -text $caption(div,copy2file) -borderwidth 2 -width 30 \
            -relief raised -command "::div::cmdImg2File $visuNo"
         pack $tbl.spec.copy -side left -padx 5 -pady 3
      }

      #---  les commandes habituelles
      frame $tbl.cmd -relief raised -borderwidth 1
      set widgetList [list ok apply reset help close]
      set cmdList [list OK Apply Reset Help Close]
      foreach wid $widgetList post $cmdList {
         button $tbl.cmd.$wid -text "$caption(div,$wid)" -width 10 -borderwidth 2 \
            -relief raised -command "::div::cmd$post $visuNo"
         if {$wid ne "ok" || $wid eq "ok" && $::conf(ok+appliquer) == 1} {
            pack $tbl.cmd.$wid -side left -padx 5 -pady 3
         }
      }

      #--   positionne les elements permanents dans le frame
      blt::table $tbl \
         $tbl.histo 0,0 -anchor w -cspan 2 -padx 5 \
         $tbl.histlin 0,2 -anchor w -padx 5 \
         $tbl.histlog 0,3 -anchor w -padx 5 \
         $tbl.lab_fonction 7,0 -anchor w -ipadx 10  \
         $tbl.palette 7,1 -anchor w -fill x -cspan 2 -pady 10 \
         $tbl.spec 8,0 -anchor w -cspan 4 -height {40} \
         $tbl.cmd 9,0 -anchor w -cspan 4 -fill both -height {40}
      pack $tbl -in $this -side bottom -fill both -expand 1
      blt::table configure $tbl c1 c2 c3 -width 90

      #---  binding
      bind $this <Key-Escape> "::div::cmdClose $visuNo"

      #--- Focus
      focus $this

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $this
   }

   #---------------------------------------------------------------------------
   #  brief  inhibe/désinhibe toutes les commandes de l'interface
   #  details invoquée par cmdImg2Clipboard et createHisto
   #  param visuNo numéro de la visu
   #  param state normal ou disabled
   #
   proc configGui { visuNo state } {
      variable private

      set this $private(div,$visuNo,this).val
      set k [lsearch -exact $private(div,$visuNo,listPalettes) $private(div,$visuNo,palette)]

      set widgetList [list histo black white plan scale_lumen scale_contrast \
         scale_step scale_gamma linear palette "spec.inv" "spec.save" \
         "cmd.ok" "cmd.apply" "cmd.reset" "cmd.help" "cmd.close"]
      if { $::tcl_platform(platform) == "windows" } {
         lappend widgetList "spec.copy"
      }
      foreach wid $widgetList {
         $this.$wid configure -state $state
      }

      #--   inhibe le decochage de l'histogramme
      if {$k in [list 5 6 7]} {
         $this.histo configure -state disabled
      }

      update
   }

   #---------------------------------------------------------------------------
   #  brief  créé une glissiere
   #  details invoquée par createDialog
   #  param visuNo numéro de la visu
   #  param label label de la glissière
   #
   proc createScale { visuNo label } {
      variable private

      scale $private(div,$visuNo,this).val.scale_$label -orient horizontal -length 200 -width 10 -showvalue 1 \
         -borderwidth 2 -sliderlength 20 -sliderrelief raised -digit 0 \
         -variable ::div::private(div,$visuNo,$label)
   }

   #----------------------------gestion de la dynamique------------------------

   #---------------------------------------------------------------------------
   #  brief commande des boutons pipettes noire et blanche
   #  details capture la/les valeurs d'un point désigné par la souris
   #  et définit la boite de confinement de la fonction de transfert
   #  warning ne peut fonctionner qu'avec l'histogramme
   #  param visuNo numéro de la visu
   #  @param color couleur
   #
   proc cmdGetValue { visuNo color } {
      variable private
      global caption

      ::div::configGui $visuNo disabled

      #--   cree le binding
      ::confVisu::addBindDisplay $visuNo <ButtonPress-1> [list ::div::getIntensite $visuNo]

      #--   cree une fenetre pour le message et attend une reponse
      set w [::div::createMsgBox $visuNo $caption(div,$color)]

      vwait ::div::private(div,$visuNo,answer)

      #--   supprime le binding
      ::confVisu::removeBindDisplay $visuNo <ButtonPress-1> [list ::div::getIntensite $visuNo]

      #--   supprime la fenetre
      destroy $w

      #--   arrete si annulation
      if {$private(div,$visuNo,answer) == 1} {
         if {![info exists private(div,$visuNo,intensite)]} {
            #--   mesage si pas de point designe
            tk_messageBox -title "$caption(div,attention)" -icon info -type ok \
               -message "[format $caption(div,no_selection) $caption(div,$color)]"
         } else {
            #--
            ::div::calcDynamic $visuNo $color
            ::div::updateValues $visuNo
         }
      }

      ::div::configGui $visuNo normal
   }

   #---------------------------------------------------------------------------
   #  brief calcule le seuil Bas/Haut dans la distribution
   #  details invoquée par cmdGetValue
   #  param visuNo numéro de la visu
   #  @param color couleur
   #
   proc calcDynamic { visuNo color } {
      variable private

      set private(div,$visuNo,$color) ""
      blt::vector create t1 dred dgreen dblue -watchunset 1

      if {[llength $private(div,$visuNo,intensite)] eq "1"} {
         set listeVector {dred}
         set DistList [list ::D_r$visuNo]
      } else {
        set listeVector {dred dgreen dblue}
         set DistList [list ::D_r$visuNo ::D_g$visuNo ::D_b$visuNo]
      }
      foreach val $private(div,$visuNo,intensite) vector $DistList {
         #--   cherche la valeur de l'intensite dans le vecteur de distribution
         t1 expr {$vector <= $val}
         set index [lindex [t1 search 1] end]
        if {$index eq ""} {set index 0}
         lappend private(div,$visuNo,$color) $index
      }

      blt::vector destroy t1 dred dgreen dblue

      switch -exact $color {
         black {set index 0}
         white {set index 2}
      }

      set private(div,$visuNo,box) [lreplace $private(div,$visuNo,box) $index $index [lindex $private(div,$visuNo,$color) 0]]

      #--   le contraste est lie a la pente de la diagonale de la boite de confinement
      lassign [::div::getPente $private(div,$visuNo,box)] pente b
      set private(div,$visuNo,contrast) [expr {int(100*($pente-1))}]

      #--   la luminosite est l'ordonne a l'origine de la diagonale
      set luminosite [expr {$b/127.5+$pente-1}]
      set private(div,$visuNo,lumen) [expr {int($luminosite*100/2)}]
   }

   #---------------------------------------------------------------------------
   #  brief capture l'intensité d'un pixel
   #  details binding avec Button1-Press
   #  param visuNo numéro de la visu
   #
   proc getIntensite { visuNo } {
      variable private
      global caption

      #--   lit l'intensite
      set result [$::confVisu::private($visuNo,This).fra1.labI cget -text]

      #--   ote le text
      set pattern [list $caption(confVisu,I) "" $caption(confVisu,egale) "" \
         $caption(confVisu,rouge) "" $caption(confVisu,vert) "" $caption(confVisu,bleu) ""]
      set intensite [string map -nocase $pattern $result]

      #--   extrait les entiers
      for {set i 0} {$i < [llength $intensite]} {incr i} {
         set val [expr {int([lindex $intensite $i])}]
         set intensite [lreplace $intensite $i $i $val]
      }

      set private(div,$visuNo,intensite) $intensite
   }

   #---------------------------------------------------------------------------
   #  brief créé une fenêtre d'info pour la capture des points noirs et blancs
   #  details invoquée par cmdGetValue
   #  param visuNo numéro de la visu
   #  param color couleur à saisir
   #
   proc createMsgBox { visuNo color } {
      variable private
      global caption

      set this $private(div,$visuNo,this)

      toplevel $this.q
      wm resizable $this 0 0
      wm transient $this.q $this
      wm title $this.q "$caption(div,attention)"
      regsub -all {\+} $private(div,visu$visuNo,position) " " geometrie
      lassign $geometrie x y
      set x [expr {$x+100}]
      set y [expr {$y+100}]
      wm geometry $this.q "+$x+$y"
      wm protocol $this.q WM_DELETE_WINDOW "set ::div::private(div,$visuNo,answer) 0"

      pack [frame $this.q.fr]

      label $this.q.lab -image $private(div,$visuNo,info) -compound left \
         -text [format $caption(div,select) $color]
      pack $this.q.lab -side top -padx 10 -pady 10
      button $this.q.but1 -text "$caption(div,ok)" -width 7 \
         -command "set ::div::private(div,$visuNo,answer) 1"
      pack $this.q.but1 -side left -padx 5 -pady 5
      button $this.q.but2 -text "$caption(div,annuler)" -width 7 \
         -command "set ::div::private(div,$visuNo,answer) 0"
      pack $this.q.but2 -side right -padx 5 -pady 5

      #--- Focus
      focus $this.q

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $this.q

      return $this.q
   }

   #---------------------------------------------------------------------------
   #  brief créé les icônes pour la dynamique
   #  details invoquée par run
   #  param visuNo numéro de la visu
   #
   proc createIcon { visuNo } {
      variable private

      #--- icone pipette_noire ; gestion de la dynamique
      set private(div,$visuNo,pipette_noire) [image create photo pipette_noire -data {
         R0lGODlhEAAQAMIIAPHx8R8eIG9ub9zc3snJy7OztP7+/gAAACwAAAAAEAAQ
         AAADKni6vBKiyfNCmKxCrHTklPVxAiCMmGCg6Qp27quy0/xSMWjLOWneFBom
         AQA7}]

      #--- icone pipette_blanche ; gestion de la dynamique
      set private(div,$visuNo,pipette_blanche) [image create photo pipette_blanche -data {
         R0lGODlhEAAQAMIHANPR2JmZmWFhYfLy9ePi5RgYGAAAAP///ywAAAAAEAAQ
         AAADKni6vFKiySOMKZNVGzO1RucVnKcAAWQeKDCs7coGgBzDtJ3jNa/3q50s
         AQA7}]

      #--- icone info  ; utilise par createMsgBox
      set private(div,$visuNo,info) [ image create photo imageinfo -data {
         R0lGODlhGAAYAIIAMS4tNpKSpvD4Nfj5+l1eUHd30goI+66vqiwAAAAAGAAY
         AAIDkyi6GnHvsTnhGTgfS9nLILh1wgUWRhoeBGWCaVqs7RKEGKriQb3hQBzg
         ILjxCoVA4SUClIAHnWGGOwyN1Rh1BfhAtdAudgWudovBcqhbQIcCsdR4QCBI
         BITVZfPL9HoMeUFvbBQAgkEsdncTBABDIY51BTUkDo+CBV2LJBVWF3V8nSR5
         AUOjo3UERKidh6ytlgEkCQA7
      } ]
   }

   #---------------------------------------------------------------------------
   #  brief émulation de rgb_split
   #  details invoquée par createHisto
   #  param bufNo numéro du buffer contenant l'image
   #
   proc emulRGB_split { bufNo } {

      set bufList {}
      set ext $::conf(extension,defaut)
      set rep $::audace(rep_temp)
      set in [file join $rep orig$ext]
      set out [file join $rep test]

      #-- recopie l'image dans le dossier temp
      buf$bufNo save $in

      #-- decompose l'image en 3 images (1 pour chaque plan)
      ::conv2::Do_rgb2r+g+b $in $out

      #-- charge chaque plan couleur
      foreach col {r g b} {
         #-- cree le buffer
         set b [::buf::create]
         lappend bufList $b
         #-- charge l'image dans le buffer
         buf$b load $out$col
         #-- detruit l'image
         file delete $out$col$ext
      }
      #-- detruit la copie de l'image
      file delete $in

      return $bufList
   }

}

#---------------fin du namespace ::div------------------------------------------

## namespace seuilWindow
# @brief Gère les seuils de visualisation

namespace eval ::seuilWindow {

   #
   #  brief lance la fenêtre de dialogue de réglage des seuils de visualisation
   #  param visuNo numéro de la visu
   #
   proc run { visuNo } {
      global seuilWindow

      #--- Fenetre de base
      set base $::confVisu::private($visuNo,This)

      ::seuilWindow::initConf $visuNo
      set seuilWindow($visuNo,This) $base.seuilwindow

      if { [ winfo exists $seuilWindow($visuNo,This) ] } {
         wm withdraw $seuilWindow($visuNo,This)
         wm deiconify $seuilWindow($visuNo,This)
         focus $seuilWindow($visuNo,This)
      } else {
         set seuilWindow($visuNo,max) $::confVisu::private($visuNo,maxdyn)
         set seuilWindow($visuNo,min) $::confVisu::private($visuNo,mindyn)
         createDialog $visuNo
      }
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de l'outil "Seuils"
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(seuils,visu$visuNo,position) définit la position de la fenêtre
   #  - conf(seuils,auto_manuel)   sélection de la dynamique (auto ou manuel)
   #  - conf(seuils,%_dynamique)   ??
   #  - conf(seuils,irisautohaut)  définit le seuil haut en mode IRIS
   #  - conf(seuils,irisautobas)   définit le seuil bas en mode IRIS
   #  - conf(seuils,histoautohaut) définit le seuil haut en % de l'histogramme
   #  - conf(seuils,histoautobas)  définit le seuil bas en % de l'histogramme
   #  @param visuNo numéro de la visu
   #
   proc initConf { { visuNo 1 } } {
      global conf

      if { ! [ info exists conf(seuils,visu$visuNo,position) ] } { set conf(seuils,visu$visuNo,position) "+0+0" }
      if { ! [ info exists conf(seuils,auto_manuel) ] }          { set conf(seuils,auto_manuel)      "1" }
      if { ! [ info exists conf(seuils,%_dynamique) ] }          { set conf(seuils,%_dynamique)      "50" }
      if { ! [ info exists conf(seuils,irisautohaut) ] }         { set conf(seuils,irisautohaut)     "1000" }
      if { ! [ info exists conf(seuils,irisautobas) ] }          { set conf(seuils,irisautobas)      "200" }
      if { ! [ info exists conf(seuils,histoautohaut) ] }        { set conf(seuils,histoautohaut)    "99" }
      if { ! [ info exists conf(seuils,histoautobas) ] }         { set conf(seuils,histoautobas)     "3" }
   }

   #
   #  brief créé de l'interface graphique
   #  param visuNo numéro de la visu
   #
   proc createDialog { visuNo } {
      global caption conf seuilWindow tmp

      #---
      set seuilWindow($visuNo,choix_dynamique) "65535 32767 20000 10000 5000 2000 1000 500 200 0 -500 -1000 -32768"

      #---
      set seuilWindow($visuNo,intervalleSHSB)         $::confVisu::private($visuNo,intervalleSHSB)
      set seuilWindow($visuNo,seuilWindowAuto_Manuel) $conf(seuils,auto_manuel)
      set seuilWindow($visuNo,pourcentage_dynamique)  $conf(seuils,%_dynamique)

      #---
      toplevel $seuilWindow($visuNo,This) -class $visuNo
      wm resizable $seuilWindow($visuNo,This) 0 0
      wm deiconify $seuilWindow($visuNo,This)
      wm title $seuilWindow($visuNo,This) "$caption(seuilWindow,titre) (visu$visuNo)"
      wm geometry $seuilWindow($visuNo,This) $conf(seuils,visu$visuNo,position)
      wm transient $seuilWindow($visuNo,This) [ winfo parent $seuilWindow($visuNo,This) ]
      wm protocol $seuilWindow($visuNo,This) WM_DELETE_WINDOW " ::seuilWindow::cmdClose $visuNo "

      #--- Sauvegarde des anciens reglages
      set tmp(seuils,visu$visuNo,mode)  $conf(seuils,visu$visuNo,mode)
      set tmp(seuils,irisautohaut)      $conf(seuils,irisautohaut)
      set tmp(seuils,irisautobas)       $conf(seuils,irisautobas)
      set tmp(seuils,histoautohaut)     $conf(seuils,histoautohaut)
      set tmp(seuils,histoautobas)      $conf(seuils,histoautobas)

      #--- Sauveagarde des reglages courants
      set tmp(seuils,visu$visuNo,mode_) $conf(seuils,visu$visuNo,mode)
      set tmp(seuils,irisautohaut_)     $conf(seuils,irisautohaut)
      set tmp(seuils,irisautobas_)      $conf(seuils,irisautobas)
      set tmp(seuils,histoautohaut_)    $conf(seuils,histoautohaut)
      set tmp(seuils,histoautobas_)     $conf(seuils,histoautobas)

      #---
      frame $seuilWindow($visuNo,This).usr1 -borderwidth 1 -relief raised

         frame $seuilWindow($visuNo,This).usr1.affichage_intensites

            label $seuilWindow($visuNo,This).usr1.affichage_intensites.lab1 -text "$caption(seuilWindow,intensite)"
            pack $seuilWindow($visuNo,This).usr1.affichage_intensites.lab1 -side left -padx 10

         pack $seuilWindow($visuNo,This).usr1.affichage_intensites -side left -expand true

         frame $seuilWindow($visuNo,This).usr1.affichage_intensites.0

            radiobutton $seuilWindow($visuNo,This).usr1.affichage_intensites.0.but \
               -variable ::confVisu::private($visuNo,intensity) -value 1 \
               -text $caption(seuilWindow,intensite_avec_zero)
            pack $seuilWindow($visuNo,This).usr1.affichage_intensites.0.but -side left -padx 10

         pack $seuilWindow($visuNo,This).usr1.affichage_intensites.0 -side top -padx 10 -fill x

         frame $seuilWindow($visuNo,This).usr1.affichage_intensites.1

            radiobutton $seuilWindow($visuNo,This).usr1.affichage_intensites.1.but \
               -variable ::confVisu::private($visuNo,intensity) -value 0 \
               -text $caption(seuilWindow,intensite_sans_zero)
            pack $seuilWindow($visuNo,This).usr1.affichage_intensites.1.but -side left -padx 10

         pack $seuilWindow($visuNo,This).usr1.affichage_intensites.1 -side top -padx 10 -fill x

      pack $seuilWindow($visuNo,This).usr1 -side top -fill both -expand 1 -ipady 5

      frame $seuilWindow($visuNo,This).usr11 -borderwidth 1 -relief raised

         frame $seuilWindow($visuNo,This).usr11.shsb

            label $seuilWindow($visuNo,This).usr11.shsb.lab1 -text "$caption(seuilWindow,intervalle_sh-sb)"
            pack $seuilWindow($visuNo,This).usr11.shsb.lab1 -side left -padx 10

            entry $seuilWindow($visuNo,This).usr11.shsb.intervalleSHSB -textvariable seuilWindow($visuNo,intervalleSHSB) \
               -width 8 -justify center
            pack $seuilWindow($visuNo,This).usr11.shsb.intervalleSHSB -side left -padx 0

         pack $seuilWindow($visuNo,This).usr11.shsb -side left

         frame $seuilWindow($visuNo,This).usr11.label1

            label $seuilWindow($visuNo,This).usr11.label1.lab2 -text "$caption(seuilWindow,exemple>x)"
            pack $seuilWindow($visuNo,This).usr11.label1.lab2 -side left -padx 0

         pack $seuilWindow($visuNo,This).usr11.label1 -side top -padx 10 -fill x

         frame $seuilWindow($visuNo,This).usr11.label2

            label $seuilWindow($visuNo,This).usr11.label2.lab2 -text "$caption(seuilWindow,exemple<x)"
            pack $seuilWindow($visuNo,This).usr11.label2.lab2 -side left -padx 0

         pack $seuilWindow($visuNo,This).usr11.label2 -side top -padx 10 -fill x

      pack $seuilWindow($visuNo,This).usr11 -side top -fill both -expand 1

      frame $seuilWindow($visuNo,This).usr2 -borderwidth 1 -relief raised

         frame $seuilWindow($visuNo,This).usr2.1 -borderwidth 0 -relief flat

            label $seuilWindow($visuNo,This).usr2.1.lab1 -text "$caption(seuilWindow,dynamique)"
            pack $seuilWindow($visuNo,This).usr2.1.lab1 -side left -padx 10
            radiobutton $seuilWindow($visuNo,This).usr2.1.rad1 -variable seuilWindow($visuNo,seuilWindowAuto_Manuel) \
               -text $caption(seuilWindow,auto) -value 1 -command " ::seuilWindow::cmdseuilWindowAuto_Manuel $visuNo "
            pack $seuilWindow($visuNo,This).usr2.1.rad1 -side left -padx 10
            radiobutton $seuilWindow($visuNo,This).usr2.1.rad2 -variable seuilWindow($visuNo,seuilWindowAuto_Manuel) \
               -text $caption(seuilWindow,manuel) -value 2 -command " ::seuilWindow::cmdseuilWindowAuto_Manuel $visuNo "
            pack $seuilWindow($visuNo,This).usr2.1.rad2 -side left -padx 10

         pack $seuilWindow($visuNo,This).usr2.1 -side top -fill both

         frame $seuilWindow($visuNo,This).usr2.2 -borderwidth 0 -relief flat

            scale $seuilWindow($visuNo,This).usr2.2.bornesMinMax_variant -from 20 -to 300 -length 370 -orient horizontal \
               -showvalue true -tickinterval 20 -resolution 5 -borderwidth 2 -relief groove \
               -variable seuilWindow($visuNo,pourcentage_dynamique) -width 10
            pack $seuilWindow($visuNo,This).usr2.2.bornesMinMax_variant -side top -padx 10 -pady 7

            frame $seuilWindow($visuNo,This).usr2.2.1 -borderwidth 0 -relief flat
               label $seuilWindow($visuNo,This).usr2.2.1.lab1 -text "$caption(seuilWindow,dynamique_max)"
               pack $seuilWindow($visuNo,This).usr2.2.1.lab1 -side left -padx 10 -pady 5
               entry $seuilWindow($visuNo,This).usr2.2.1.ent1 -textvariable seuilWindow($visuNo,max) -width 10
               pack $seuilWindow($visuNo,This).usr2.2.1.ent1 -side left -padx 10 -pady 5
               menubutton $seuilWindow($visuNo,This).usr2.2.1.but -text $caption(seuilWindow,parcourir) -menu $seuilWindow($visuNo,This).usr2.2.1.but.menu \
                  -relief raised
               pack $seuilWindow($visuNo,This).usr2.2.1.but -side left -padx 10 -pady 5
               set m [ menu $seuilWindow($visuNo,This).usr2.2.1.but.menu -tearoff 0 ]
               foreach dynamique $seuilWindow($visuNo,choix_dynamique) {
                  $m add radiobutton -label "$dynamique" \
                     -indicatoron "1" \
                     -value "$dynamique" \
                     -variable seuilWindow($visuNo,max) \
                     -command { }
               }
            pack $seuilWindow($visuNo,This).usr2.2.1 -side top -fill both

            frame $seuilWindow($visuNo,This).usr2.2.2 -borderwidth 0 -relief flat
               label $seuilWindow($visuNo,This).usr2.2.2.lab1 -text "$caption(seuilWindow,dynamique_min)"
               pack $seuilWindow($visuNo,This).usr2.2.2.lab1 -side left -padx 10 -pady 5
               entry $seuilWindow($visuNo,This).usr2.2.2.ent1 -textvariable seuilWindow($visuNo,min) -width 10
               pack $seuilWindow($visuNo,This).usr2.2.2.ent1 -side left -padx 10 -pady 5
               menubutton $seuilWindow($visuNo,This).usr2.2.2.but -text $caption(seuilWindow,parcourir) -menu $seuilWindow($visuNo,This).usr2.2.2.but.menu \
                  -relief raised
               pack $seuilWindow($visuNo,This).usr2.2.2.but -side left -padx 10 -pady 5
               set m [ menu $seuilWindow($visuNo,This).usr2.2.2.but.menu -tearoff 0 ]
               foreach dynamique $seuilWindow($visuNo,choix_dynamique) {
                  $m add radiobutton -label "$dynamique" \
                     -indicatoron "1" \
                     -value "$dynamique" \
                     -variable seuilWindow($visuNo,min) \
                     -command { }
               }
            pack $seuilWindow($visuNo,This).usr2.2.2 -side top -fill both

         pack $seuilWindow($visuNo,This).usr2.2 -side top -fill both

      pack $seuilWindow($visuNo,This).usr2 -side top -fill both -expand 1 -ipady 5

      #--- Mise a jour de l'interface
      ::seuilWindow::cmdseuilWindowAuto_Manuel $visuNo

      frame $seuilWindow($visuNo,This).usr3 -borderwidth 1 -relief raised

         frame $seuilWindow($visuNo,This).usr3.regl_seuils
         pack $seuilWindow($visuNo,This).usr3.regl_seuils -side left -expand true

         frame $seuilWindow($visuNo,This).usr3.regl_seuils.0
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.0 -fill x
         radiobutton $seuilWindow($visuNo,This).usr3.regl_seuils.0.but -variable tmp(seuils,visu$visuNo,mode_) \
            -text $caption(seuilWindow,pas_de_calcul_auto) -value disable
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.0.but -side left -padx 10
         frame $seuilWindow($visuNo,This).usr3.regl_seuils.1
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.1 -fill x
         radiobutton $seuilWindow($visuNo,This).usr3.regl_seuils.1.but -variable tmp(seuils,visu$visuNo,mode_) \
            -text $caption(seuilWindow,loadima) -value loadima
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.1.but -side left -padx 10
         frame $seuilWindow($visuNo,This).usr3.regl_seuils.2
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.2 -fill x
         radiobutton $seuilWindow($visuNo,This).usr3.regl_seuils.2.but -variable tmp(seuils,visu$visuNo,mode_) \
            -text $caption(seuilWindow,iris) -value iris
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.2.but -side left -padx 10
         entry $seuilWindow($visuNo,This).usr3.regl_seuils.2.enth -textvariable tmp(seuils,irisautohaut_) \
            -width 10 -justify center
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.2.enth -side right -padx 10
         entry $seuilWindow($visuNo,This).usr3.regl_seuils.2.entb -textvariable tmp(seuils,irisautobas_) \
            -width 10 -justify center
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.2.entb -side right -padx 10
         frame $seuilWindow($visuNo,This).usr3.regl_seuils.4
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.4 -fill x
         radiobutton $seuilWindow($visuNo,This).usr3.regl_seuils.4.but -variable tmp(seuils,visu$visuNo,mode_) \
            -text $caption(seuilWindow,histoauto) -value histoauto
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.4.but -side left -padx 10
         entry $seuilWindow($visuNo,This).usr3.regl_seuils.4.enth -textvariable tmp(seuils,histoautohaut_) \
            -width 10 -justify center
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.4.enth -side right -padx 10
         entry $seuilWindow($visuNo,This).usr3.regl_seuils.4.entb -textvariable tmp(seuils,histoautobas_) \
            -width 10 -justify center
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.4.entb -side right -padx 10
         frame $seuilWindow($visuNo,This).usr3.regl_seuils.6
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.6 -fill x
         radiobutton $seuilWindow($visuNo,This).usr3.regl_seuils.6.but -variable tmp(seuils,visu$visuNo,mode_) \
            -text $caption(seuilWindow,initiaux) -value initiaux
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.6.but -side left -padx 10
         frame $seuilWindow($visuNo,This).usr3.regl_seuils.7
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.7 -fill x
         button $seuilWindow($visuNo,This).usr3.regl_seuils.7.but -text $caption(seuilWindow,previsu) \
            -command " ::seuilWindow::cmdPreview $visuNo "
         pack $seuilWindow($visuNo,This).usr3.regl_seuils.7.but -side top -expand true -padx 10 -pady 5 -ipadx 10

      pack $seuilWindow($visuNo,This).usr3 -side top -fill both -expand 1 -ipady 5

      frame $seuilWindow($visuNo,This).cmd -borderwidth 1 -relief raised

         button $seuilWindow($visuNo,This).cmd.ok -text "$caption(seuilWindow,ok)" -width 7 \
            -command " ::seuilWindow::cmdOk $visuNo "
         if { $conf(ok+appliquer)=="1" } {
            pack $seuilWindow($visuNo,This).cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }

         button $seuilWindow($visuNo,This).cmd.appliquer -text "$caption(seuilWindow,appliquer)" -width 8 \
            -command "::seuilWindow::cmdApply $visuNo "
         pack $seuilWindow($visuNo,This).cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

         button $seuilWindow($visuNo,This).cmd.fermer -text "$caption(seuilWindow,fermer)" -width 7 \
            -command " ::seuilWindow::cmdClose $visuNo "
         pack $seuilWindow($visuNo,This).cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

         button $seuilWindow($visuNo,This).cmd.aide -text "$caption(seuilWindow,aide)" -width 7 \
            -command " ::seuilWindow::afficheAide "
         pack $seuilWindow($visuNo,This).cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

      pack $seuilWindow($visuNo,This).cmd -side top -fill x

      #---
      bind $seuilWindow($visuNo,This) <Key-Return> " ::seuilWindow::cmdOk $visuNo "
      bind $seuilWindow($visuNo,This) <Key-Escape> " ::seuilWindow::cmdClose $visuNo "

      #--- La fenetre est active
      focus $seuilWindow($visuNo,This)

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $seuilWindow($visuNo,This) <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $seuilWindow($visuNo,This)
   }

   #
   #  brief  commande associée au radiobutton de sélection du mode
   #  detail modifie l'interface graphique en fonction du choix (automatique ou manuel)
   #  param visuNo numéro de la visu
   #
   proc cmdseuilWindowAuto_Manuel { visuNo } {
      global seuilWindow

      if { $seuilWindow($visuNo,seuilWindowAuto_Manuel) == "1" } {
         pack $seuilWindow($visuNo,This).usr2.2.bornesMinMax_variant -side top -padx 10 -pady 7
         pack forget $seuilWindow($visuNo,This).usr2.2.1
         pack forget $seuilWindow($visuNo,This).usr2.2.1.lab1
         pack forget $seuilWindow($visuNo,This).usr2.2.1.ent1
         pack forget $seuilWindow($visuNo,This).usr2.2.1.but
         pack forget $seuilWindow($visuNo,This).usr2.2.2
         pack forget $seuilWindow($visuNo,This).usr2.2.2.lab1
         pack forget $seuilWindow($visuNo,This).usr2.2.2.ent1
         pack forget $seuilWindow($visuNo,This).usr2.2.2.but
      } else {
         pack forget $seuilWindow($visuNo,This).usr2.2.bornesMinMax_variant
         pack $seuilWindow($visuNo,This).usr2.2.1 -side top -fill both
         pack $seuilWindow($visuNo,This).usr2.2.1.lab1 -side left -padx 10 -pady 5
         pack $seuilWindow($visuNo,This).usr2.2.1.ent1 -side left -padx 10 -pady 5
         pack $seuilWindow($visuNo,This).usr2.2.1.but -side left -padx 10 -pady 5
         pack $seuilWindow($visuNo,This).usr2.2.2 -side top -fill both
         pack $seuilWindow($visuNo,This).usr2.2.2.lab1 -side left -padx 10 -pady 5
         pack $seuilWindow($visuNo,This).usr2.2.2.ent1 -side left -padx 10 -pady 5
         pack $seuilWindow($visuNo,This).usr2.2.2.but -side left -padx 10 -pady 5
      }
   }

   #
   ## @brief commande du bouton "Aperçu"
   #  @details Fonction apercu
   #  @param visuNo numéro de la visu
   #
   proc cmdPreview { visuNo } {
      global conf tmp

      #--- Copie des reglages courants
      set conf(seuils,visu$visuNo,mode) $tmp(seuils,visu$visuNo,mode_)
      set conf(seuils,irisautohaut)     $tmp(seuils,irisautohaut_)
      set conf(seuils,irisautobas)      $tmp(seuils,irisautobas_)
      set conf(seuils,histoautohaut)    $tmp(seuils,histoautohaut_)
      set conf(seuils,histoautobas)     $tmp(seuils,histoautobas_)
      #--- Visualisation avec les reglages courants
      ::audace::autovisu $visuNo
      #--- Recuperation des anciens reglages
      set conf(seuils,visu$visuNo,mode) $tmp(seuils,visu$visuNo,mode)
      set conf(seuils,irisautohaut)     $tmp(seuils,irisautohaut)
      set conf(seuils,irisautobas)      $tmp(seuils,irisautobas)
      set conf(seuils,histoautohaut)    $tmp(seuils,histoautohaut)
      set conf(seuils,histoautobas)     $tmp(seuils,histoautobas)
   }

   #
   #  brief commande bouton "OK"
   #  param visuNo numéro de la visu
   #
   proc cmdOk { visuNo } {
      cmdApply $visuNo
      cmdClose $visuNo
   }

   #
   ## @brief commande bouton "Appliquer"
   #  @param visuNo numéro de la visu
   #
   proc cmdApply { visuNo } {
      global audace conf select seuilWindow tmp

      #--- Copie des seuils manuels maxi et mini
      if { $seuilWindow($visuNo,seuilWindowAuto_Manuel) == "2" } {
         set ::confVisu::private($visuNo,maxdyn) $seuilWindow($visuNo,max)
         set ::confVisu::private($visuNo,mindyn) $seuilWindow($visuNo,min)
      }
      #--- Copie des parametres du reglage
      set ::confVisu::private($visuNo,intervalleSHSB) $seuilWindow($visuNo,intervalleSHSB)
      set conf(seuils,auto_manuel)                    $seuilWindow($visuNo,seuilWindowAuto_Manuel)
      set conf(seuils,%_dynamique)                    $seuilWindow($visuNo,pourcentage_dynamique)
      #--- Copie des reglages courants
      set conf(seuils,visu$visuNo,mode) $tmp(seuils,visu$visuNo,mode_)
      set conf(seuils,histoautohaut)    $tmp(seuils,histoautohaut_)
      set conf(seuils,histoautobas)     $tmp(seuils,histoautobas_)
      set conf(seuils,irisautohaut)     $tmp(seuils,irisautohaut_)
      set conf(seuils,irisautobas)      $tmp(seuils,irisautobas_)
      #--- Visualisation avec les reglages courants dans la fenetre principale
      ::confVisu::autovisu $visuNo
      #--- Visualisation avec les reglages courants dans la fenetre de selection des images si elle existe
      if [ winfo exists $audace(base).select ] {
         ::audace::autovisu $select(visuNo)
      }
      #--- Recuperation de la position de la fenetre de reglages
      seuils_recup_position $visuNo
   }

   #
   #  brief commande bouton "Aide"
   #  param visuNo numéro de la visu
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,affichage)" "1060seuils.htm"
   }

   #
   ## @brief commande bouton "Fermer
   #  @param visuNo numéro de la visu
   #
   proc cmdClose { visuNo } {
      global seuilWindow

      #--- Recuperation de la position de la fenetre de reglages
      seuils_recup_position $visuNo
      #---
      destroy $seuilWindow($visuNo,This)
      unset seuilWindow($visuNo,This)
   }

   #
   #  brief récupère les coordonnees de la fenêtre de dialogue des seuils
   #  param visuNo numéro de la visu
   #
   proc seuils_recup_position { visuNo } {
      global conf seuilWindow

      set seuilWindow(seuils,$visuNo,geometry) [ wm geometry $seuilWindow($visuNo,This) ]
      set deb [ expr 1 + [ string first + $seuilWindow(seuils,$visuNo,geometry) ] ]
      set fin [ string length $seuilWindow(seuils,$visuNo,geometry) ]
      set conf(seuils,visu$visuNo,position) "+[string range $seuilWindow(seuils,$visuNo,geometry) $deb $fin]"
   }

}

########################### Fin du namespace seuilWindow ###########################

## namespace seuilCouleur
#  @brief Gère la balance RVB des couleurs

namespace eval ::seuilCouleur {

   #
   #  brief lance la fenêtre de dialogue pour le réglage de la balance RVB
   #  param visuNo numéro de la visu
   #
   proc run { visuNo } {
      variable widget
      global seuilCouleur

      #--- fenetre de base
      set base $::confVisu::private($visuNo,This)

      #---
      ::seuilCouleur::initConf $visuNo
      ::seuilCouleur::confToWidget $visuNo
      #---
      set seuilCouleur($visuNo,base) $base
      set seuilCouleur($visuNo,This) $base.seuilcouleur
      if { [ winfo exists $seuilCouleur($visuNo,This) ] } {
         wm withdraw $seuilCouleur($visuNo,This)
         wm deiconify $seuilCouleur($visuNo,This)
         focus $seuilCouleur($visuNo,This)
      } else {
         if { [ info exists seuilCouleur(seuils,$visuNo,geometry) ] } {
            set deb [ expr 1 + [ string first + $seuilCouleur(seuils,$visuNo,geometry) ] ]
            set fin [ string length $seuilCouleur(seuils,$visuNo,geometry) ]
            set widget(seuils,$visuNo,position) "+[string range $seuilCouleur(seuils,$visuNo,geometry) $deb $fin]"
         }
         ::seuilCouleur::createDialog $visuNo
      }
   }

   #
   ## @brief initialise les paramètres de l'outil "Balance RVB"
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(seuilCouleur,visu$visuNo,position) définit la position de la fenêtre
   #  @param visuNo numéro de la visu
   #
   proc initConf { visuNo } {
      global conf

      if { ! [ info exists conf(seuilCouleur,visu$visuNo,position) ] } { set conf(seuilCouleur,visu$visuNo,position) "+350+75" }
   }

   #
   #  brief charge les variables de configuration dans des variables locales
   #  param visuNo numéro de la visu
   #
   proc confToWidget { visuNo } {
      variable widget
      global conf

      set widget(seuils,$visuNo,position) "$conf(seuilCouleur,visu$visuNo,position)"
   }

   #
   #  brief charge les variables locales dans des variables de configuration
   #  param visuNo numéro de la visu
   #
   proc widgetToConf { visuNo } {
      variable widget
      global conf

      set conf(seuilCouleur,visu$visuNo,position) "$widget(seuils,$visuNo,position)"
   }

   #
   #  brief récupère la position de la fenetre
   #  param visuNo numéro de la visu
   #
   proc recupPosition { visuNo } {
      variable widget
      global seuilCouleur

      set seuilCouleur(seuils,$visuNo,geometry) [wm geometry $seuilCouleur($visuNo,This)]
      set deb [ expr 1 + [ string first + $seuilCouleur(seuils,$visuNo,geometry) ] ]
      set fin [ string length $seuilCouleur(seuils,$visuNo,geometry) ]
      set widget(seuils,$visuNo,position) "+[string range $seuilCouleur(seuils,$visuNo,geometry) $deb $fin]"
      #---
      ::seuilCouleur::widgetToConf $visuNo
   }

   #
   #  brief créé l'interface graphique
   #  param visuNo numéro de la visu
   #
   proc createDialog { visuNo } {
      variable widget
      global audace caption color conf seuilCouleur

      #--- Initialisation de variables
      set seuilCouleur(avancement,$visuNo) ""
      ::seuilCouleur::initSeuils

      #---
      toplevel $seuilCouleur($visuNo,This)
      wm resizable $seuilCouleur($visuNo,This) 0 0
      wm deiconify $seuilCouleur($visuNo,This)
      wm title $seuilCouleur($visuNo,This) "$caption(audace,menu,balance_rvb) (visu$visuNo)"
      wm geometry $seuilCouleur($visuNo,This) $widget(seuils,$visuNo,position)
      wm transient $seuilCouleur($visuNo,This) [ winfo parent $seuilCouleur($visuNo,This) ]
      wm protocol $seuilCouleur($visuNo,This) WM_DELETE_WINDOW "::seuilCouleur::cmdClose $visuNo"

      #---
      frame $seuilCouleur($visuNo,This).usr -borderwidth 0 -relief raised

         frame $seuilCouleur($visuNo,This).usr.1 -borderwidth 1 -relief raised
            label $seuilCouleur($visuNo,This).usr.1.lab1 \
               -textvariable "caption(seuilCouleur,image_affichee)"
            pack $seuilCouleur($visuNo,This).usr.1.lab1 -side left -padx 10 -pady 5
         pack $seuilCouleur($visuNo,This).usr.1 -side top -fill both

         frame $seuilCouleur($visuNo,This).usr.2 -borderwidth 1 -relief raised
            label $seuilCouleur($visuNo,This).usr.2.lab5 \
               -text "$caption(seuilCouleur,selection_zone_blanche)"
            pack $seuilCouleur($visuNo,This).usr.2.lab5 -side top -padx 5 -pady 5
            button $seuilCouleur($visuNo,This).usr.2.btn1 \
               -text "$caption(seuilCouleur,confirmer_zone_blanche)" \
               -command "::seuilCouleur::confirmerBlanc $visuNo"
            pack $seuilCouleur($visuNo,This).usr.2.btn1 -side top -pady 5 -ipadx 15 -ipady 5
            label $seuilCouleur($visuNo,This).usr.2.lab6 \
               -text "$caption(seuilCouleur,selection_zone_noire)"
            pack $seuilCouleur($visuNo,This).usr.2.lab6 -side top -padx 5 -pady 5
            button $seuilCouleur($visuNo,This).usr.2.btn2 \
               -text "$caption(seuilCouleur,confirmer_zone_noire)" \
               -command "::seuilCouleur::confirmerNoir $visuNo"
            pack $seuilCouleur($visuNo,This).usr.2.btn2 -side top -pady 5 -ipadx 15 -ipady 5
         pack $seuilCouleur($visuNo,This).usr.2 -side top -fill both

         frame $seuilCouleur($visuNo,This).usr.3 -borderwidth 1 -relief raised
            label $seuilCouleur($visuNo,This).usr.3.labURL1 \
               -textvariable "seuilCouleur(avancement,$visuNo)" -fg $color(blue)
            pack $seuilCouleur($visuNo,This).usr.3.labURL1 -side top -padx 10 -pady 5
         pack $seuilCouleur($visuNo,This).usr.3 -side top -fill both

      pack $seuilCouleur($visuNo,This).usr -side top -fill both -expand 1

      frame $seuilCouleur($visuNo,This).cmd -borderwidth 1 -relief raised

         button $seuilCouleur($visuNo,This).cmd.ok -text "$caption(pretraitement,ok)" -width 7 \
            -command "::seuilCouleur::cmdOk $visuNo"
         if { $conf(ok+appliquer)=="1" } {
            pack $seuilCouleur($visuNo,This).cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }

         button $seuilCouleur($visuNo,This).cmd.appliquer -text "$caption(pretraitement,appliquer)" \
            -width 8 -command "::seuilCouleur::cmdApply $visuNo"
         pack $seuilCouleur($visuNo,This).cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

         button $seuilCouleur($visuNo,This).cmd.fermer -text "$caption(pretraitement,fermer)" -width 7 \
            -command "::seuilCouleur::cmdClose $visuNo"
         pack $seuilCouleur($visuNo,This).cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

         button $seuilCouleur($visuNo,This).cmd.aide -text "$caption(pretraitement,aide)" -width 7 \
            -command "::seuilCouleur::afficheAide"
         pack $seuilCouleur($visuNo,This).cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

      pack $seuilCouleur($visuNo,This).cmd -side top -fill x

      #---
      bind $seuilCouleur($visuNo,This) <Key-Return> "::seuilCouleur::cmdOk $visuNo"
      bind $seuilCouleur($visuNo,This) <Key-Escape> "::seuilCouleur::cmdClose $visuNo"

      #---
      focus $seuilCouleur($visuNo,This)

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $seuilCouleur($visuNo,This) <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $seuilCouleur($visuNo,This)
   }

   #
   #  brief commande du bouton "OK"
   #  param visuNo numéro de la visu
   #
   proc cmdOk { visuNo } {
      ::seuilCouleur::cmdApply $visuNo
      ::seuilCouleur::cmdClose $visuNo
   }

   #
   ## @brief commande du bouton "Appliquer"
   #  @param visuNo numéro de la visu
   #
   proc cmdApply { visuNo } {
      variable private
      global caption conf seuilCouleur

      #---
      set seuilCouleur(avancement,$visuNo) "$caption(seuilCouleur,en_cours)"
      update

      #--- Il faut une image affichee
      if { [ buf[ ::confVisu::getBufNo $visuNo ] imageready ] != "1" } {
         tk_messageBox -title "$caption(seuilCouleur,attention)" -type ok \
            -message "$caption(seuilCouleur,header_noimage)"
         set seuilCouleur(avancement,$visuNo) ""
         return
      }

      #--- Traitement
      set catchError [ catch {
         #--- Affectation des niveaux maxi et mini pour le Rouge, le Vert et le Bleu
         set mycuts [ list $seuilCouleur(blanc_R) $seuilCouleur(noir_R) $seuilCouleur(blanc_V) $seuilCouleur(noir_V) $seuilCouleur(blanc_B) $seuilCouleur(noir_B) ]
         if { $seuilCouleur(blanc_R) == "" } {
            tk_messageBox -title "$caption(seuilCouleur,attention)" -icon error \
               -message "$caption(seuilCouleur,pas_selection_blanc)"
            set seuilCouleur(avancement,$visuNo) ""
            return
         } elseif { $seuilCouleur(noir_R) == "" } {
            tk_messageBox -title "$caption(seuilCouleur,attention)" -icon error \
               -message "$caption(seuilCouleur,pas_selection_noir)"
            set seuilCouleur(avancement,$visuNo) ""
            return
         } elseif { $seuilCouleur(blanc_V) == "" } {
            tk_messageBox -title "$caption(seuilCouleur,attention)" -icon error \
               -message "$caption(seuilCouleur,pas_couleur)"
            ::seuilCouleur::initSeuils
            set seuilCouleur(avancement,$visuNo) ""
            return
         }
         visu$visuNo cut $mycuts
         #--- Affichage de l'image
         visu$visuNo disp
         #--- Actualisation des glissieres RVB
         ::colorRGB::configureScale $visuNo
         #--- Initialisation
         ::seuilCouleur::initSeuils
         set seuilCouleur(avancement,$visuNo) "$caption(seuilCouleur,fin_traitement)"
      } m ]
      if { $catchError == "1" } {
         tk_messageBox -title "$caption(seuilCouleur,attention)" -icon error -message "$m"
         set seuilCouleur(avancement,$visuNo) ""
      }
      ::seuilCouleur::recupPosition $visuNo
   }

   #
   ## @brief commande du bouton "Fermer"
   #  @param visuNo numéro de la visu
   #
   proc cmdClose { visuNo } {
      global seuilCouleur

      ::seuilCouleur::recupPosition $visuNo
      destroy $seuilCouleur($visuNo,This)
      unset seuilCouleur($visuNo,This)
   }

   #
   #  brief commande du bouton "Aide"
   #  param visuNo numéro de la visu
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,affichage)" "1070balance_rvb.htm"
   }

   #
   ## @brief commande du bouton "Confirmer la sélection de la zone blanche"
   #  @param visuNo numéro de la visu
   #
   proc confirmerBlanc { visuNo } {
      global caption seuilCouleur

      #--- Retourne les coordonnees de la zone selectionnee avec la souris
      set box [ ::confVisu::getBox $visuNo ]
      if { $box == "" } {
         #--- J'initialise les seuils
         lassign [ list "" "" "" ] set seuilCouleur(blanc_R) seuilCouleur(blanc_V) seuilCouleur(blanc_B)
         #---
         tk_messageBox -title "$caption(seuilCouleur,attention)" -icon error \
            -message "$caption(seuilCouleur,pas_selection_blanc)"
         return
      }

      #--- Calcule les coordonnees du centre de la zone selectionnee avec la souris
      set Xmoy [ expr int( ( [ lindex $box 2 ] + [ lindex $box 0 ] ) / 2. ) ]
      set Ymoy [ expr int( ( [ lindex $box 3 ] + [ lindex $box 1 ] ) / 2. ) ]

      #--- Je recupere le numero du buffer de la visu
      set bufNo [ ::confVisu::getBufNo $visuNo ]

      #--- Retourne les intensites R, V et B du centre de la zone selectionnee avec la souris
      lassign [ buf$bufNo getpix [ list $Xmoy $Ymoy ] ] nihil seuilCouleur(blanc_R) seuilCouleur(blanc_V) seuilCouleur(blanc_B)

      #--- Suppression de la zone selectionnee avec la souris
      ::confVisu::deleteBox $visuNo
   }

   #
   ## @brief commande du bouton "Confirmer la sélection de la zone noire"
   #  @param visuNo numéro de la visu
   #
   proc confirmerNoir { visuNo } {
      global caption seuilCouleur

      #--- Retourne les coordonnees de la zone selectionnee avec la souris
      set box [ ::confVisu::getBox $visuNo ]
      if { $box == "" } {
         #--- J'initialise les seuils
         lassign [ list "" "" "" ] set seuilCouleur(noir_R) seuilCouleur(noir_V) seuilCouleur(noir_B)
         #---
         tk_messageBox -title "$caption(seuilCouleur,attention)" -icon error \
            -message "$caption(seuilCouleur,pas_selection_noir)"
         return
      }

      #--- Calcule les coordonnees du centre de la zone selectionnee avec la souris
      set Xmoy [ expr int( ( [ lindex $box 2 ] + [ lindex $box 0 ] ) / 2.0 ) ]
      set Ymoy [ expr int( ( [ lindex $box 3 ] + [ lindex $box 1 ] ) / 2.0 ) ]

      #--- Je recupere le numero du buffer de la visu
      set bufNo [ ::confVisu::getBufNo $visuNo ]

      #--- Retourne les intensites R, V et B du centre de la zone selectionnee avec la souris
      lassign [ buf$bufNo getpix [ list $Xmoy $Ymoy ] ] nihil seuilCouleur(noir_R) seuilCouleur(noir_V) seuilCouleur(noir_B)

      #--- Suppression de la zone selectionnee avec la souris
      ::confVisu::deleteBox $visuNo
   }

   #
   #  brief initialise a vide les seuils maxi et mini de chaque couleur
   #
   proc initSeuils { } {
      global seuilCouleur

      lassign [ list "" "" "" "" "" "" ] seuilCouleur(blanc_R) seuilCouleur(blanc_V) \
         seuilCouleur(blanc_B) seuilCouleur(noir_R) seuilCouleur(noir_V) seuilCouleur(noir_B)
   }
}

########################## Fin du namespace seuilCouleur ##########################

