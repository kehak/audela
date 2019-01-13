#
## @file carte.tcl
#  @brief Namespace générique des cartes (~ classe abstraite) ;
#  @details Transmet les appels aux procédures du namespace de la carte choisie avec confcat.tcl
#  @author Michel PUJOL
#  @namespace carte
#  @brief Namespace générique des cartes (~ classe abstraite) ;
#  $Id: carte.tcl 13695 2016-04-13 19:23:32Z rzachantke $
#

namespace eval ::carte {
}

#--- chargement des captions
source [file join $::audace(rep_caption) carte.cap]

#------------------------------------------------------------
## @brief affiche la carte sur les coordonnées contenues dans le buffer de l'image
#  @pre   image dans le buffer avec mots clés FITS "RA" et "DEC"
#  @param buffer : buffer de l'image
#  @return return 0 (OK) , 1(error)
#
proc ::carte::showMapFromBuffer { buffer } {
   if { [ $buffer imageready ] == "0" } {
      tk_messageBox -message "$::caption(carte,error_no_image)" -title "$::caption(carte,title)" -icon error
      return
   }

   #--- Premiere tentative : je recupere les coordonnees dans le fichier FIT
   set ra  [lindex [$buffer getkwd RA] 1]
   set dec [lindex [$buffer getkwd DEC] 1]

  # console::disp "gotoFromBuffer [$buffer getkwd RA]\n"

   if { "$ra" != "" && "$dec" != "" } {
      #--- je convertis RA au format HMS
      set ra "[mc_angle2hms $ra 360 zero 0 auto string]"
      #--- je supprime les decimales des secondes
      set ra [string range $ra 0 [expr [string first "s" "$ra" ] ] ]

      #--- je convertis DEC au format DMS
      set dec "[mc_angle2dms $dec 90 zero 0 + string ] "
      #--- je supprime les decimales des secondes
      set dec [string range $dec 0 [expr [string first "s" "$dec" ] ] ]

      set zoom_carte "10"
      set avant_plan "1"
      ::carte::gotoObject "" "$ra" "$dec" $zoom_carte $avant_plan
   } else {
      set message "$::caption(carte,error_image_buffer)"
      tk_messageBox -message "$::caption(carte,error_image_buffer)" -title "$::caption(carte,title)" -icon error
   }
}

#------------------------------------------------------------
#  gotoObject
## @brief centre la fenêtre de la carte sur les coordonnées passées en paramètres
#  et fixe la taille du champ
#  @param nom_objet  : nom de l'objet   (ex : "NGC7000")
#  @param ad         : ascension droite (ex : "16h41m42s")
#  @param dec        : declinaison      (ex : "+36d28m00s")
#  @param zoom_objet : champ 1 a 10
#  @param avant_plan : 1=mettre la carte au premier plan 0=ne pas mettre au premier plan
#  @return 0 (OK) , 1(error)
#
proc ::carte::gotoObject { nom_objet ad dec zoom_objet avant_plan } {
  # console::disp "::carte::gotoObject $nom_objet, $ad, $dec, $zoom_objet, $avant_plan, carte=$::conf(confCat) \n"
   set result 1
   if { $::conf(confCat) != "" } {
      set resultcatch [ catch { set result [$::conf(confCat)\:\:gotoObject "$nom_objet" "$ad" "$dec" "$zoom_objet" "$avant_plan" ] } msg]
   } else {
      #--- Affichage de la fenetre de configuration des cartes si aucune carte n'est selectionnee
      set choice [tk_messageBox -message "$::caption(carte,error_no_map)" -title "$::caption(carte,title)" \
         -icon question -type yesno]
      if {$choice=="yes"} {
         ::confCat::run
      }
   }
   return $result
}

#------------------------------------------------------------
## @brief récupère les coordonnées et le nom de l'objet sélectionné dans la carte
#  @return [list $ra $dec $objName $mag ] ou "" si erreur
#  - $ra        : right ascension  (ex : "16h41m42s")
#  - $dec       : declinaison      (ex : "+36d28m00s")
#  - $objName   : object name      (ex : "M 13")
#  - $magnitude : object magnitude (ex : "5.78")
#
proc ::carte::getSelectedObject { } {
   set result ""
   if { $::conf(confCat) != "" } {
      set resultcatch [ catch { set result [$::conf(confCat)\:\:getSelectedObject] } msg]
      if { $resultcatch == "1" } {
         console::affiche_erreur "::carte::gotoObject msg=$msg \n"
      }
   } else {
      #--- Affichage de la fenetre de configuration des cartes si aucune carte n'est selectionnee
      set choice [tk_messageBox -message "$::caption(carte,error_no_map)" -title "$::caption(carte,title)" \
         -icon question -type yesno]
      if {$choice=="yes"} {
         ::confCat::run
      }
   }
   return $result
}

#------------------------------------------------------------
## @brief informe de l'état de la connexion au logiciel qui affiche la carte
#  @return 0 (ready) ou 1 (not ready)

proc ::carte::isReady { } {
   set result ""
   if { $::conf(confCat) != "" } {
      set resultcatch [ catch { set result [$::conf(confCat)\:\:isReady] } msg]
      if { $resultcatch == "1" } {
         console::affiche_erreur "::carte::gotoObject msg=$msg \n"
      }
   } else {
      #--- Affichage de la fenetre de configuration des cartes si aucune carte n'est selectionnee
      set choice [tk_messageBox -message "$::caption(carte,error_no_map)" -title "$::caption(carte,title)" \
         -icon question -type yesno]
      if {$choice=="yes"} {
         ::confCat::run
      }
   }
   return $result
}

