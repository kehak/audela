#
## @file displaycoord.tcl
#  @brief Affichage des coordonnées du telescope
#  @author Michel PUJOL
#  $Id: displaycoord.tcl 13610 2016-04-04 14:37:59Z rzachantke $
#

#============================================================
# Declaration du namespace displaycoord
#    initialise le namespace
#============================================================

## @namespace displaycoord
#  @brief Affichage des coordonnées du telescope
namespace eval ::displaycoord {
   package provide displaycoord 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] displaycoord.cap ]
}

#------------------------------------------------------------
# brief   retourne le titre du plugin dans la langue de l'utilisateur
# return  titre du plugin
#
proc ::displaycoord::getPluginTitle { } {
   global caption

   return $caption(displaycoord,title)
}

#------------------------------------------------------------
# brief      retourne le nom du fichier d'aide principal
# return     nom du fichier d'aide principal
#
proc ::displaycoord::getPluginHelp { } {
   return "displaycoord.htm"
}

#------------------------------------------------------------
# brief      retourne le type de plugin
# return     type de plugin
#
proc ::displaycoord::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# brief      retourne le nom du répertoire du plugin
# return     nom du répertoire du plugin : "telshift"
#
proc ::displaycoord::getPluginDirectory { } {
   return "displaycoord"
}

#------------------------------------------------------------
## @brief     retourne le ou les OS de fonctionnement du plugin
#  @return    liste des OS : "Windows Linux Darwin"
#
proc ::displaycoord::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
## @brief    retourne les propriétés de l'outil
#  @param    propertyName nom de la propriété
#  @return   valeur de la propriété ou "" si la propriété n'existe pas
#
proc ::displaycoord::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "aiming" }
      subfunction1 { return "" }
      display      { return "window" }
      default      { return "" }
   }
}

#------------------------------------------------------------
## @brief   créé une nouvelle instance de l'outil
#  @param   base   base tk
#  @param   visuNo numéro de la visu
#  @return  chemin de la fenêtre
#
proc ::displaycoord::createPluginInstance { base { visuNo 1 } } {
   variable private

   #--- Creation des variables si elles n'exitaitent pas
  ::displaycoord::initConf

   set dir [ file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [getPluginType]] [getPluginDirectory]]
   source [ file join $dir displayconfig.tcl ]

   #--- j'intialise les variables locale
   set private(socketChannel)    ""
   set private(etat)             "NOT_CONNECTED"
   set private(connexionTimerId) ""

   #--- Initialisation
   set private(base)   "$base.displaycoord"
   set private(sortie) "0"

   font create displayCoordFont1 -family tahoma -size 60 -weight bold
   font create displayCoordFont2 -family tahoma -size 20 -weight normal
   font create displayCoordFont3 -family arial  -size 20 -weight bold
   set private(fonttitle)    {displayCoordFont1}
   set private(font1)        {displayCoordFont1}
   set private(font2)        {displayCoordFont2}
   set private(font3)        {displayCoordFont3}
   set private(font4)        {displayCoordFont2}

   set private(ra0)          "00h 00m 00.00s"
   set private(dec0)         "+00° 00' 00.00''"
   set private(equinox0)     ""
   set private(azimutDms)    "000° 00' 00.0''"
   set private(hauteurDms)   "+00° 00' 00.0''"
   set private(modelName)    ""
   set private(modelEnabled) 0

   #--- j'affiche la fenetre
   ::displaycoord::createWindow $visuNo

   #--- je lance la boucle pour se connecter au serveur
   startConnectionLoop

   #--- j'affiche les valeurs par defaut dans les champs
   ::displaycoord::readSocketCoord

   #---
   return $private(base)
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'outil "Coordonnées du télescope"
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - conf(displaycoord,serverHost) définit l'adress IP du serveur
#  - conf(displaycoord,serverPort) définit le port du serveur
#  - conf(displaycoord,windowPosition) définit la position de la fenêtre
#  - conf(displaycoord,windowMaximize) définit la taille (maximale) de la fenêtre
#
proc ::displaycoord::initConf { } {

   if { ! [ info exists ::conf(displaycoord,serverHost) ] }     { set ::conf(displaycoord,serverHost)     "localhost" }
   if { ! [ info exists ::conf(displaycoord,serverPort) ] }     { set ::conf(displaycoord,serverPort)     "5028" }
   if { ! [ info exists ::conf(displaycoord,windowPosition) ] } { set ::conf(displaycoord,windowPosition) "640x480+50+15" }
   if { ! [ info exists ::conf(displaycoord,windowMaximize) ] } { set ::conf(displaycoord,windowMaximize) 0 }
}

#------------------------------------------------------------
## @brief   suppprime l'instance du plugin
#  @param   visuNo numéro de la visu
#
proc ::displaycoord::deletePluginInstance { visuNo } {
   variable private

   #--- je deconnecte le serveur de coordonnnes
   ::displaycoord::closeSocketCoord
   #--- je memorise l'etat de la fentre (normal=0 , maximized=1)
   if { [wm state $private(base)] == "zoomed" } {
      set ::conf(displaycoord,windowMaximize) 1
   } else {
      set ::conf(displaycoord,windowMaximize) 0
   }

   if { [wm state $private(base)] != "normal" } {
      #--- j'affiche la fenetre en mode normal pour pouvoir recuperer la taille
      wm state $private(base) normal
   }
   #--- je memorise la position courante et la taille de la fenetre
   set ::conf(displaycoord,windowPosition) [ wm geometry $private(base) ]
   #--- je supprime la fenetre
   destroy $private(base)

   set index [lsearch $::confVisu::private($visuNo,pluginInstanceList) ::displaycoord ]
   if { $index != -1 } {
      set ::confVisu::private($visuNo,pluginInstanceList) \
         [lreplace  $::confVisu::private($visuNo,pluginInstanceList) $index $index]
   }

   font delete displayCoordFont1
   font delete displayCoordFont2
   font delete displayCoordFont3

}

#------------------------------------------------------------
#  brief créé l'interface graphique
#  param viusNo nuémro de la visu
#
proc ::displaycoord::createWindow { visuNo } {
   variable private

   set couleur_blanche       #FFFFFF
   set couleur_noire         #000000
   set couleur_or            #FFAA00
   set couleur_orclair       #FF9900
   set couleur_bleuclair     #00AAFF
   set couleur_bleu          #0000FF
   set couleur_rouge         #FF5500
   set private(color,back)   $couleur_bleu
   set private(color,text)   $couleur_or

   #--- Create the toplevel window
   set  base $private(base)
   toplevel $base -class Toplevel
   wm geometry $base $::conf(displaycoord,windowPosition)
   wm focusmodel $base passive
   wm minsize $base 600 400
   wm resizable $base 1 1
   wm deiconify $base
   wm title $base $::caption(displaycoord,title)
   wm protocol $base WM_DELETE_WINDOW "::displaycoord::deletePluginInstance $visuNo"
   ###bind $base <Destroy> { destroy .ohp_t193 }
   $base configure -bg $private(color,back)
   wm withdraw .
   focus -force $base
   if { $::conf(displaycoord,windowMaximize) == 1 } {
      wm state $base zoomed
   }
   #---
   set private(ohp_t193,adinit)  ""
   set private(ohp_t193,decinit) ""
   #set private(ohp_t193,adinit)  00h00m00s
   #set private(ohp_t193,decinit) +00°00'00\"
   set private(ohp_t193,fichierlog) codeurs_t193.log

   #--- frame principale
   frame $base.f -bg $private(color,back)

   #--- titre et bouton de configuration
   frame $base.f.titre -bg $private(color,back)
   label $base.f.titre.lab_titre \
     -bg $private(color,back) -fg $couleur_bleuclair \
     -font $private(fonttitle) -text $::caption(displaycoord,title)
   grid $base.f.titre.lab_titre -row 0 -column 0 -sticky ew

   button $base.f.titre.configuration  -text $::caption(displaycoord,configuration) \
      -command "::displaycoord::config::run $private(base) $visuNo"
   grid $base.f.titre.configuration -row 0 -column 1 -sticky e -padx 4
   grid columnconfig $base.f.titre 0 -weight 1

   pack $base.f.titre -fill x -pady 2 -anchor e

   #--- Etat du telescope
   label $base.f.lab_etat \
      -bg $private(color,text) -fg $private(color,back) \
      -font $private(font1) -height 2 -anchor center
   pack $base.f.lab_etat -fill none -pady 2 -anchor e

   #--- temps
   label $base.f.lab_tu \
     -bg $private(color,back) -fg $private(color,text) \
     -font $private(font1)

   label $base.f.lab_tsl \
     -bg $private(color,back) -fg $private(color,text) \
     -font $private(font1)
   pack $base.f.lab_tu -fill none -pady 2 -anchor w
   pack $base.f.lab_tsl -fill none -pady 2 -anchor w

   #--- coordonnees equatoriales : Alpha et Delta , calage
   frame $base.f.coord -bg $private(color,back)
      label $base.f.coord.alpha_label -text $::caption(displaycoord,ad) \
        -bg $private(color,back) -fg $private(color,text) \
        -font $private(font1)
      grid $base.f.coord.alpha_label -row 0 -column 0 -sticky w
      label $base.f.coord.alpha_value \
          -bg $private(color,back) -fg $private(color,text) \
          -font $private(font1)
      grid $base.f.coord.alpha_value -row 0 -column 1 -sticky w
      label $base.f.coord.equinox -text "(J2000.0)" \
            -bg $private(color,back) -fg $private(color,text) \
            -font $private(font3)
      grid $base.f.coord.equinox -row 0 -column 2 -sticky w
      label $base.f.coord.alpha_calage \
            -bg $private(color,back) -fg $private(color,text) \
            -font $private(font1)
      grid $base.f.coord.alpha_calage -row 0 -column 3 -sticky w

      label $base.f.coord.delta_label -text $::caption(displaycoord,dec) \
         -bg $private(color,back) -fg $private(color,text) \
         -font $private(font1)
      grid $base.f.coord.delta_label -row 1 -column 0 -sticky w
      label $base.f.coord.delta_value \
         -bg $private(color,back) -fg $private(color,text) \
         -font $private(font1)
      grid $base.f.coord.delta_value -row 1 -column 1 -sticky w
      label $base.f.coord.delta_calage \
         -bg $private(color,back) -fg $private(color,text) \
         -font $private(font1)
      grid $base.f.coord.delta_calage -row 1 -column 3 -sticky w

      grid columnconfig $base.f.coord 0 -weight 2
      grid columnconfig $base.f.coord 1 -weight 2
      grid columnconfig $base.f.coord 2 -weight 1   ;# l'equinoxe a moins de poids
      grid columnconfig $base.f.coord 2 -weight 1
   pack $base.f.coord -fill x -pady 2 -padx 2 -anchor w

   #--- coordonnees brutes (sans modele de pointage) et azimut
   frame $base.f.brut -bg $private(color,back)
      #--- ascension droite brute
      label $base.f.brut.ra0_label -text $::caption(displaycoord,ad0) \
         -bg $private(color,back) -fg $couleur_bleuclair -font $private(font3)
      grid $base.f.brut.ra0_label -row 0 -column 0 -sticky e -padx 2
      label $base.f.brut.ra0_value -textvariable ::displaycoord::private(ra0) \
         -bg $private(color,back) -fg $couleur_bleuclair -font $private(font3)
      grid $base.f.brut.ra0_value -row 0 -column 1 -sticky w -padx 2
      label $base.f.brut.equinox0 -textvariable ::displaycoord::private(equinox0) \
         -bg $private(color,back) -fg $couleur_bleuclair -font $private(font3)
      grid $base.f.brut.equinox0 -row 0 -column 2 -sticky w

      #--- declinaison brute
      label $base.f.brut.dec0_label -text $::caption(displaycoord,dec0) \
         -bg $private(color,back) -fg $couleur_bleuclair -font $private(font3)
      grid $base.f.brut.dec0_label -row 1 -column 0 -sticky e
      label $base.f.brut.dec0_value -textvariable ::displaycoord::private(dec0) \
         -bg $private(color,back) -fg $couleur_bleuclair -font $private(font3)
      grid $base.f.brut.dec0_value -row 1 -column 1 -sticky w -padx 2

      #--- azimut
      label $base.f.brut.azimut_label -text $::caption(displaycoord,azimut) \
         -bg $private(color,back) -fg $couleur_bleuclair -font $private(font3)
      grid $base.f.brut.azimut_label -row 0 -column 3 -sticky e -padx 2
      label $base.f.brut.azimut_value -textvariable ::displaycoord::private(azimutDms) \
         -bg $private(color,back) -fg $couleur_bleuclair -font $private(font3)
      grid $base.f.brut.azimut_value -row 0 -column 4 -sticky w -padx 2

      #--- hauteur
      label $base.f.brut.hauteur_label -text $::caption(displaycoord,hauteur) \
         -bg $private(color,back) -fg $couleur_bleuclair -font $private(font3)
      grid $base.f.brut.hauteur_label -row 1 -column 3 -sticky e -padx 2
      label $base.f.brut.hauteur_value -textvariable ::displaycoord::private(hauteurDms) \
         -bg $private(color,back) -fg $couleur_bleuclair -font $private(font3)
      grid $base.f.brut.hauteur_value -row 1 -column 4 -sticky w -padx 2

      grid columnconfig $base.f.brut 0 -weight 1
      grid columnconfig $base.f.brut 1 -weight 1
      grid columnconfig $base.f.brut 2 -weight 1
      grid columnconfig $base.f.brut 3 -weight 1
      grid columnconfig $base.f.brut 4 -weight 1
   pack $base.f.brut -fill x -pady 2 -anchor center

   #--- angle horaire
   label $base.f.lab_ha \
     -bg $private(color,back) -fg $couleur_bleuclair\
     -font $private(font1)
   pack $base.f.lab_ha -fill none -pady 2 -anchor center

   #--- nom du site
   label $base.f.lab_ohp \
     -bg $private(color,back) -fg $private(color,text) \
     -font $private(font4) \
     -text ""
   pack $base.f.lab_ohp -fill none -pady 2 -anchor w

   #--- Latitude - Longitude - Altitude
   label $base.f.lab_altaz \
     -bg $private(color,back) -fg $private(color,text) \
     -font $private(font2) -justify left
   pack $base.f.lab_altaz -fill none -pady 0 -padx 10  -anchor w

   #--- modele de pointage
   frame $base.f.model -bg $private(color,back)
      label $base.f.model.label \
         -bg $private(color,back) -fg $private(color,text) \
         -font $private(font2) \
         -text $::caption(displaycoord,modeldescr)
      pack $base.f.model.label -side left -fill none -pady 0 -padx 0 -anchor w
      label $base.f.model.name \
         -bg $private(color,back) -fg $private(color,text) \
         -font $private(font2) \
         -textvariable ::displaycoord::private(modelName)
      pack $base.f.model.name -side left -fill none -pady 0 -padx 2 -anchor w
     label $base.f.model.enabled \
        -bg $private(color,back) -fg $private(color,text) \
        -font $private(font2) \
        -textvariable ::displaycoord::private(modelEnabled)
     pack $base.f.model.enabled -side left -fill none -pady 0 -padx 2 -anchor w
   pack $base.f.model -fill y -pady 0 -padx 10 -anchor w

   pack $base.f -fill both -expand 1

   bind $private(base).f <Configure> [list onResizeWindow %w %h ]

}

#------------------------------------------------------------
#  brief redimmensionne les polices de caractères qund on change la taille de la fenêtre
#  param width largeur de la fenêtre
#  param height hauteur de la fenêtre
#
proc onResizeWindow { width height } {
   variable private
   set nbCol  35
   set nbLine 20

   set widthFontSize [expr int($width / $nbCol) ]
   set heightFontSize [expr int($height / $nbLine) ]
   if { $widthFontSize < $heightFontSize } {
      set fontSize1 $widthFontSize
   } else {
      set fontSize1 $heightFontSize
   }
   if { $fontSize1 < 8 } {
      set fontSize1 8
   }

   set fontSize23 [expr int($fontSize1 /2)]
   if { $fontSize23 < 8 } {
      set fontSize23 8
   }

   font configure displayCoordFont1 -size $fontSize1
   font configure displayCoordFont2 -size $fontSize23
   font configure displayCoordFont3 -size $fontSize23
}

######################################################################
#
#  gestion de la socket de communication avec le serveur de coordonnees
#
#######################################################################

#------------------------------------------------------------
## @brief ouvre une socket en lecture pour recevoir les notifications des coordonnées
#  @details les parametrès de la connexion sont dans des variables globales :
#  - adresse/nom de host = \::conf(displaycoord,serverHost)
#  - port                = \::conf(displaycoord,serverPort)
#
proc ::displaycoord::startConnectionLoop { } {
   variable private

   #--- je connecte au serveur de coordonnees
   #--- avec un delai de 5 secondes pour ne pas retarder le demarrage d'Audela
   #--- si cet outil est lance au demarrage d'audela
   set private(connexionTimerId) [after 5000 ::displaycoord::openSocketCoord ]
}

#------------------------------------------------------------
## @brief ouvre une socket en lecture pour recevoir les notifications des coordonnees
#  @details les parametrès de la connexion sont dans des variables globales :
#  - adresse/nom de host = \::conf(displaycoord,serverHost)
#  - port                = \::conf(displaycoord,serverPort)
#
proc ::displaycoord::openSocketCoord { } {
   variable private

   set catchError [ catch {

      if { $private(socketChannel) != "" } {
          ::displaycoord::closeSocketCoord
      }

      set private(socketChannel) [socket $::conf(displaycoord,serverHost) $::conf(displaycoord,serverPort) ]
      #---  -translation binary -encoding binary
      fconfigure $private(socketChannel) -buffering line -blocking false -translation binary -encoding binary
      fileevent $private(socketChannel) readable [list ::displaycoord::readSocketCoord ]

      set private(etat) "CONNECTED"
      #--- j'affiche l'affichage (je fais comme si on avais recu une notification)
      readSocketCoord
      set private(connexionTimerId) ""
      ###::console::disp "::displaycoord::openSocketCoord $private(etat)\n"
   } ]

   if { $catchError != 0 } {
      #--- j'affiche l'etat
      readSocketCoord
      ::console::disp "::displaycoord::openSocketCoord $private(etat)\n"
      #--- je fais une nouvelle tentative dans 10s
      set private(connexionTimerId) [after 10000 ::displaycoord::openSocketCoord ]
   }
}

#------------------------------------------------------------
## @brief ferme la socket
#
proc ::displaycoord::closeSocketCoord { } {
   variable private

   if { $private(socketChannel) != "" } {
      close $private(socketChannel)
      set private(socketChannel) ""
      #--- j'affiche l'affichage (je fais comme si on avais recu une notification)
      readSocketCoord
   }

   #--- j'arrete le timer de reconnexion s'il etait lance
   if { $private(connexionTimerId) != "" } {
      after cancel $private(connexionTimerId)
      set private(connexionTimerId) ""
   }

}

#------------------------------------------------------------
## @brief envoie des données vers le PC de guidage
#
proc ::displaycoord::readSocketCoord {  } {
   variable private

   set catchError [catch {
      set returnCode         ""
      set tu                 "0000-00-00T00:00:00"
      set ts                 "00:00:00"
      set ra                 "00h00m00s00"
      set dec                "00d00m00s00"
      set ra0                "00h00m00s00"
      set dec0               "00d00m00s00"
      set raCalage           "A"
      set decCalage          "A"
      set longitudeDegres    "000.0"
      set estouest           "E"
      set latitudeDegres     "+00.0"
      set altitude           "0000.0"
      set nomObservatoire    ""
      set nomModelePointage  ""
      set etatModelePointage 0

      if { $private(socketChannel) == "" } {
         #--- j'affiche les valeurs par defaut
            set private(etat) "NOT_CONNECTED"
         } else {
         if { [eof $private(socketChannel)] } {
            #--- la connexion est ferme par le serveur
            set private(etat) "NOT_CONNECTED"
            ::displaycoord::closeSocketCoord
            #--- je lance une tentative de connexion dans 5s
            set private(connexionTimerId) [after 5000 ::displaycoord::openSocketCoord ]
         } else {
            set private(etat) "CONNECTED"
            set notification [gets $private(socketChannel) ]

            #--- je recupere les valeurs
            # !RADEC COORD [Code retour] [TU] [TS] [alpha_corr] [delta_corr] [alpha_0] [delta_0] [calage_alpha] [calage_delta] @\n
            # Code retour
            #     0   OK
            #     5   Probleme moteur
            #     6   Butees atteintes
            # TU  (format ISO 8601)
            #     Format= "%04d-%02d-%02dT%02d:%02d:%02d"
            # TS
            #     Format= "%02d:%02d:%02d"
            # alpha_corr : coordonnee alpha corrigee avec le modele de pointage
            #     Format = "%02dh%02dm%05.2fs"
            # delta_corr : coordonnee delta corrigee avec le modele de pointage
            #     Format = "%1s%02dd%02dm%05.2fs"
            # alpha_0 : coordonnee brute alpha
            #     Format = "%02dh%02dm%05.2fs"
            # delta_0 : coordonnee brute delta
            #     Format = "%1s%02dd%02dm%05.2fs"
            # calage_alpha
            #     C : cale
            #     D : decale
            #     A : autre : ni cale ni decale
            # calage_delta
            #     C : cale
            #     D : decale
            #     A : autre : ni cale ni decale
            # longitude (en degres)
            #     Format "%10.6f"
            # estouest (E ou W)
            #     Format "%c"
            # latitude (en degres)
            #     Format "%10.6f"
            # altitude (en metre)
            #     Format "%5.1f"
            # nom_site
            #     Format "\"%s\""
            # nom du modele
            #     Format "\"%s\""
            # etat du modle ACTIF=1 INACTIF=0
            #     Format %d

            set nbVar [scan $notification {!RADEC COORD %d %s %s %s %s %s %s %s %s %f %s %f %f "%[^"]" "%[^"]" %d @} \
                 returnCode tu ts ra dec ra0 dec0 raCalage decCalage longitudeDegres estouest latitudeDegres altitude \
                 nomObservatoire nomModelePointage etatModelePointage ]
            if { $nbVar == 16 } {
               if { $returnCode == 0 } {
                  #--- pas d'erreur a signaler
               } else {
                  ::console::affiche_erreur "::displaycoord::readSocketCoord warning returnCode=$returnCode notification=$notification\n"
                  set tu                 "0000-00-00T00:00:00"
                  set ts                 "0000-00-00T00:00:00"
                  set ra                 "00h00m00s00"
                  set dec                "00d00m00s00"
                  set ra0                "00h00m00s00"
                  set dec0               "00d00m00s00"
                  set raCalage           "A"
                  set decCalage          "A"
                  set longitude          "000.0"
                  set estouest           "E"
                  set latitude           "+00.0"
                  set altitude           "0000.0"
                  set nomObservatoire    ""
                  set nomModelePointage  ""
                  set etatModelePointage 0
               }
            } else {
               #--- le message n'a pas le format attendu
               ::console::affiche_erreur "::displaycoord::readSocketCoord error nbVar=$nbVar notification=$notification\n"
            }
         }
      }
      # AK
      #console::affiche_resultat "[mc_date2iso8601 now] : ::displaycoord::readSocketCoord"
      #catch {
      #   console::affiche_resultat "notification = <$notification>"
      #}
      #console::affiche_resultat "\n"

      #--- j'affiche l'etat de la connexion
      switch $private(etat) {
         "NOT_CONNECTED" {
             $private(base).f.lab_etat configure  -text $::caption(displaycoord,nonConnecte) \
                -bg $private(color,back) -fg $private(color,text)
         }
         "CONNECTED" {
            $private(base).f.lab_etat configure  -text $::caption(displaycoord,connecte) \
               -bg $private(color,text) -fg $private(color,back)
         }
      }

      #--- je mets en forme l'heure tu et ts
      scan $tu "%d-%d-%dT%d:%d:%ds" tuy tumo tud tuh tum tus
      set tuHms [format "%02dh %02dm %02ds" $tuh $tum $tus ]
      scan $ts "%d:%d:%d" tslh tslm tsls
      set tsHms [format "%02dh %02dm %02ds" $tslh $tslm $tsls ]

      #--- je mets en forme l'ascension droite et la declinaison
      set alpha "[string range $ra 0 1]h [string range $ra 3 4]m [string range $ra) 6 7].[string range $ra 9 10]s "
      set delta "[string range $dec 0 2]° [string range $dec 4 5]'   [string range $dec) 7 8].[string range $dec 10 10]'' "
      #--- je mets en forme l'ascension droite et la declinaison des coordonnees brutes
      set private(ra0) "[string range $ra0 0 1]h [string range $ra0 3 4]m [string range $ra0) 6 7].[string range $ra0 9 10]s "
      set private(dec0) "[string range $dec0 0 2]° [string range $dec0 4 5]' [string range $dec0) 7 8].[string range $dec0 10 10]'' "
      if { $tuy == "0" } {
         #--- j'affiche l'equinoxe de la date courante si on n'a pas encore recu de message
         set private(equinox0) "([mc_date2equinox now ])"
      } else {
         set private(equinox0) "([mc_date2equinox "$tuy $tumo $tud $tuh $tum $tus" ])"
      }

      #--- je mets en forme la longitude et la latitude de la position de l'observatoire
      set longitudeList [mc_angle2dms $longitudeDegres 180 nozero 1 auto list]
      set longitudeDms [format "%d° %2d' %0.1f''" [lindex $longitudeList 0] [lindex $longitudeList 1] [lindex $longitudeList 2] ]
      set latitudeList [mc_angle2dms $latitudeDegres 90 nozero 1 auto list]
      set latitudeDms [format "%d° %2d' %0.1f''" [lindex $latitudeList 0] [lindex $latitudeList 1] [lindex $latitudeList 2] ]
      if { $estouest == "E" || $estouest == "e" } {
         set estouest $::caption(displaycoord,east)
      } else {
         set estouest $::caption(displaycoord,west)
      }

      #--- je calcule l'azimut, la hauteur et la secanteZ
      if { $returnCode == 0 } {
         set res [mc_radec2altaz $ra $dec "GPS $longitudeDegres $estouest $latitudeDegres $altitude" $tu]
         set azimutDegres  [lindex $res 0]
         set azimutList [mc_angle2dms $azimutDegres 360 nozero 1 auto list]
         set private(azimutDms) [format " %02d° %02d' %04.1f''" [lindex $azimutList 0] [lindex $azimutList 1] [lindex $azimutList 2] ]
         set hauteurDegres [lindex $res 1]
         set hauteurList [mc_angle2dms $hauteurDegres 90 nozero 1 auto list]
         set private(hauteurDms) [format "%+02d° %02d' %04.1f''" [lindex $hauteurList 0] [lindex $hauteurList 1] [lindex $hauteurList 2] ]
         #--- je calcule secz (masse d'air)
         if { $hauteurDegres >= "0" } {
            set distanceZenithale [ expr 90.0 - $hauteurDegres ]
            set distanceZenithale [ mc_angle2rad $distanceZenithale ]
            set secz [format "%5.2f" [ expr 1. / cos($distanceZenithale) ] ]
         } else {
            set secz $::caption(displaycoord,horizon)
         }
      } else {
         set private(azimutDms)  " 00° 00' 00.0''"
         set private(hauteurDms) "+00° 00' 00.0''"
         set secz "0.00"
      }

      #--- je mets en forme le calage des moteurs
      if { $raCalage != "C" && $raCalage != "D" && $raCalage != "A" } {
         set raCalage "A"
      }
      if { $decCalage != "C" && $decCalage != "D" && $decCalage != "A" } {
         set decCalage "A"
      }

      #--- Affichage temps (TU, TSL) et coordonnees (ALPHA, DELTA, ANGLE HORAIRE, Azimut, hauteur du telescope)
      $private(base).f.lab_tu configure    -text "$::caption(displaycoord,tu) $tuHms"
      $private(base).f.lab_tsl configure   -text "$::caption(displaycoord,tsl) $tsHms"
      $private(base).f.lab_ha configure    -text "$::caption(displaycoord,secz) $secz"

      #--- affichage de la position du site
      $private(base).f.lab_ohp configure   -text "$::caption(displaycoord,observatoire) $nomObservatoire"
      $private(base).f.lab_altaz configure -text "$::caption(displaycoord,longitude) $longitudeDms $estouest   $::caption(displaycoord,latitude) $latitudeDms   $::caption(displaycoord,altitude) $altitude m"

      $private(base).f.coord.alpha_value configure -text $alpha
      $private(base).f.coord.alpha_calage configure -text $::caption(displaycoord,calage,$raCalage)
      $private(base).f.coord.delta_value configure -text $delta
      $private(base).f.coord.delta_calage configure -text $::caption(displaycoord,calage,$decCalage)

      #--- affichage du modele
      set private(modelName) $nomModelePointage
      if { $etatModelePointage == 1 } {
         set private(modelEnabled)  $::caption(displaycoord,enabled)
         $private(base).f.model.enabled configure -bg $private(color,text) -fg $private(color,back)
      } else {
         set private(modelEnabled)  $::caption(displaycoord,disabled)
         $private(base).f.model.enabled configure -bg $private(color,back) -fg $private(color,text)
      }

   }]
   if { $catchError != 0 } {
      ::console::affiche_erreur ":$::errorInfo\n"
   }

}

