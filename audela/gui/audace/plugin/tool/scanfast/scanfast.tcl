#
# Fichier : scanfast.tcl
# Description : Outil pour l'acquisition en mode scan rapide
# Compatibilite : Montures LX200, AudeCom et Ouranos avec camera Audine (liaisons parallele et EthernAude)
# Auteur : Alain KLOTZ
# Mise à jour $Id: scanfast.tcl 12688 2016-01-16 18:53:20Z robertdelmas $
#

global panneau

set panneau(scanfast,temps_mort) "0"

#------------------------------------------------------------
# prescanfast
#    Realise une simulation de scan rapide pour determiner les parametres
#
# Parametres :
#    largpix  : Largeur de l'image en pixels
#    hautpix  : Hauteur de l'image en pixels
#    dt       : Temps d'integration interligne en millisecondes
#    firstpix : Indice du premier photosite de la largeur de l'image, commence a 1 (optionnel)
#    bin      : Binning du scan (optionnel)
# Return :
#    dt0   : Temps d'integration interligne sans le temps mort en millisecondes
#    speed : Nombre de boucles pour realiser un temps d'attente de 1 milliseconde
#------------------------------------------------------------
proc prescanfast { largpix hautpix dt { firstpix 1 } { bin 1 } } {
   global audace caption panneau

   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "$caption(scanfast,comment1)\n"
   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "[ format $caption(scanfast,comment2) [ expr int($hautpix*$dt*3/1000.) ] ]\n"
   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "$caption(scanfast,comment3)\n"
   cam$audace(camNo) scan $largpix $hautpix $bin 0 -firstpix $firstpix -fast 0 -tmpfile -biny $bin
   set tmort [ expr 1000.*[ lindex [ buf$audace(bufNo) getkwd DTEFF ] 1 ] ]
   ::console::affiche_resultat "   $caption(scanfast,comment4) = $tmort $caption(scanfast,ms/ligne)\n"
   set panneau(scanfast,temps_mort) $tmort
   set dt0 [ expr $dt-$tmort ]
   if { $dt0 < "0" } {
      ::console::affiche_erreur "$caption(scanfast,comment5) dt=$dt $caption(scanfast,ms)\n"
      ::console::affiche_resultat "\n"
      ::console::disp "\n"
      return [ list 0 0 ]
   }
   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "$caption(scanfast,comment6)\n"
   ::console::affiche_resultat "\n"
   set speed [ cam$audace(camNo) scanloop ]
   ::console::affiche_resultat "$caption(scanfast,iteration) 0 :\n"
   ::console::affiche_resultat "[ format $caption(scanfast,comment7) [ expr int($hautpix*$dt/1000.) ] ]\n"
   cam$audace(camNo) scan $largpix $hautpix $bin $dt0 -firstpix $firstpix -fast $speed -tmpfile -biny $bin
   set dteff [ lindex [ buf$audace(bufNo) getkwd DTEFF ] 1 ]
   ::console::affiche_resultat "   $caption(scanfast,comment8) = $speed ([ expr 1000*$dteff ] $caption(scanfast,ms/ligne))\n"
   set speed [ expr $dt/$dteff/1000.*$speed ];
   ::console::affiche_resultat "      $caption(scanfast,comment9) = $speed\n"
   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "$caption(scanfast,iteration) 1 :\n"
   ::console::affiche_resultat "[ format $caption(scanfast,comment7) [ expr int($hautpix*$dt/1000.) ] ]\n"
   cam$audace(camNo) scan $largpix $hautpix $bin $dt0 -firstpix $firstpix -fast $speed -tmpfile -biny $bin
   set dteff [ lindex [ buf$audace(bufNo) getkwd DTEFF ] 1 ]
   ::console::affiche_resultat "   $caption(scanfast,comment8) = $speed ([ expr 1000*$dteff ] $caption(scanfast,ms/ligne))\n"
   set speed [ expr $dt/$dteff/1000.*$speed ];
   ::console::affiche_resultat "      $caption(scanfast,comment9) = $speed\n"
   ::console::affiche_resultat "\n"
   if { [ expr int($hautpix*$dt/1000.) ] < "20" } {
      ::console::affiche_resultat "$caption(scanfast,iteration) 2 :\n"
      ::console::affiche_resultat "[ format $caption(scanfast,comment7) [ expr int($hautpix*$dt/1000.) ] ]\n"
      cam$audace(camNo) scan $largpix $hautpix $bin $dt0 -firstpix $firstpix -fast $speed -tmpfile -biny $bin
      set dteff [ lindex [ buf$audace(bufNo) getkwd DTEFF ] 1 ]
      ::console::affiche_resultat "   $caption(scanfast,comment8) = $speed ([ expr 1000*$dteff ] $caption(scanfast,ms/ligne))\n"
      set speed [ expr $dt/$dteff/1000.*$speed ];
      ::console::affiche_resultat "      $caption(scanfast,comment9) = $speed\n"
      ::console::affiche_resultat "\n"
      ::console::affiche_resultat "$caption(scanfast,iteration) 3 :\n"
      ::console::affiche_resultat "[ format $caption(scanfast,comment7) [ expr int($hautpix*$dt/1000.) ] ]\n"
      cam$audace(camNo) scan $largpix $hautpix $bin $dt0 -firstpix $firstpix -fast $speed -tmpfile -biny $bin
      set dteff [ lindex [ buf$audace(bufNo) getkwd DTEFF ] 1 ]
      ::console::affiche_resultat "   $caption(scanfast,comment8) = $speed ([ expr 1000*$dteff ] $caption(scanfast,ms/ligne))\n"
      set speed [ expr $dt/$dteff/1000.*$speed ];
      ::console::affiche_resultat "      $caption(scanfast,comment9) = $speed\n"
      ::console::affiche_resultat "\n"
   }
   ::console::affiche_resultat "$caption(scanfast,comment10)\n"
   ::console::affiche_resultat "cam$audace(camNo) scan $largpix $hautpix $bin $dt0 -firstpix $firstpix -fast $speed -tmpfile -biny $bin \n"
   ::console::affiche_resultat "\n"
   ::console::disp "\n"
   return [ list $dt0 $speed ]
}

#============================================================
# Declaration du namespace scanfast
#    Initialise le namespace
#============================================================
namespace eval ::scanfast {
   package provide scanfast 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] scanfast.cap ]
}

#------------------------------------------------------------
# getPluginTitle
#    Retourne le titre du plugin dans la langue de l'utilisateur
#
# Parametres :
#    Aucun
# Return :
#    caption(nom_plugin,titre)
#------------------------------------------------------------
proc ::scanfast::getPluginTitle { } {
   global caption

   return "$caption(scanfast,scanfast)"
}

#------------------------------------------------------------
# getPluginHelp
#    Retourne la documentation du plugin
#
# Parametres :
#    Aucun
# Return :
#    nom_plugin.htm
#------------------------------------------------------------
proc ::scanfast::getPluginHelp { } {
   return "scanfast.htm"
}

#------------------------------------------------------------
# getPluginType
#    Retourne le type du plugin
#
# Parametres :
#    Aucun
# Return :
#    tool
#------------------------------------------------------------
proc ::scanfast::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# getPluginDirectory
#    Retourne le repertoire du plugin
#
# Parametres :
#    Aucun
# Return :
#    nom_repertoire_plugin
#------------------------------------------------------------
proc ::scanfast::getPluginDirectory { } {
   return "scanfast"
}

#------------------------------------------------------------
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
# Parametres :
#    Aucun
# Return :
#    La liste des OS supportes par le plugin
#------------------------------------------------------------
proc ::scanfast::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
# getPluginProperty
#    Retourne la valeur de la propriete
#
# Parametres :
#    propertyName : Nom de la propriete
# Return :
#    Valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::scanfast::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "acquisition" }
      subfunction1 { return "scan" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# createPluginInstance
#    Cree une nouvelle instance du plugin
#
# Parametres :
#    in : Widget parent (optionnel)
#    visuNo : Numero de la visu (optionnel)
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanfast::createPluginInstance { base { visuNo 1 } } {
   global audace

   #--- Chargement des fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool scanfast scanfastSetup.tcl ]\""

   #--- Mise en place de l'interface graphique
   createPanel $base.scanfast

   #--- Surveillance de l'extension par defaut
   trace add variable ::conf(extension,defaut) write ::scanfast::initExtension

   return $base.scanfast
}

#------------------------------------------------------------
# deletePluginInstance
#    Suppprime l'instance du plugin
#
# Parametres :
#    visuNo : Numero de la visu
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanfast::deletePluginInstance { visuNo } {
   #--- Je desactive la surveillance de l'extension par defaut
   trace remove variable ::conf(extension,defaut) write ::scanfast::initExtension
}

#------------------------------------------------------------
# createPanel
#    Prepare la creation de l'interface de l'outil
#
# Parametres :
#    this : Widget de l'interface
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanfast::createPanel { this } {
   variable This
   global caption conf panneau

   #--- Initialisation du nom du widget
   set This $this

   #--- Initialisation des captions
   set panneau(scanfast,titre)           "$caption(scanfast,scanfast)"
   set panneau(scanfast,aide)            "$caption(scanfast,help_titre)"
   set panneau(scanfast,aide1)           "$caption(scanfast,help_titre1)"
   set panneau(scanfast,configuration)   "$caption(scanfast,configuration)"
   set panneau(scanfast,col)             "$caption(scanfast,colonnes)"
   set panneau(scanfast,lig)             "$caption(scanfast,lignes)"
   set panneau(scanfast,interligne)      "$caption(scanfast,interligne)"
   set panneau(scanfast,bin)             "$caption(scanfast,binning)"
   set panneau(scanfast,calcul)          "$caption(scanfast,calcul)"
   set panneau(scanfast,ms)              "$caption(scanfast,milliseconde)"
   set panneau(scanfast,calib)           "$caption(scanfast,calibration)"
   set panneau(scanfast,loops)           "$caption(scanfast,boucles)"
   set panneau(scanfast,obturateur)      "$caption(scanfast,obt)"
   set panneau(scanfast,acq)             "$caption(scanfast,acquisition)"
   set panneau(scanfast,go0)             "$caption(scanfast,goccd)"
   set panneau(scanfast,stop)            "$caption(scanfast,stop)"
   set panneau(scanfast,go1)             "$caption(scanfast,en_cours)"
   set panneau(scanfast,go2)             "$caption(scanfast,visu)"
   set panneau(scanfast,go)              "$panneau(scanfast,go0)"
   set panneau(scanfast,attention)       "$caption(scanfast,attention)"
   set panneau(scanfast,msg)             "$caption(scanfast,message)"
   set panneau(scanfast,nom)             "$caption(scanfast,nom)"
   set panneau(scanfast,extension)       "$caption(scanfast,extension)"
   set panneau(scanfast,index)           "$caption(scanfast,index)"
   set panneau(scanfast,sauvegarde)      "$caption(scanfast,sauvegarde)"
   set panneau(scanfast,pb)              "$caption(scanfast,pb)"
   set panneau(scanfast,nom_fichier)     "$caption(scanfast,nom_fichier)"
   set panneau(scanfast,nom_blanc)       "$caption(scanfast,nom_blanc)"
   set panneau(scanfast,mauvais_car)     "$caption(scanfast,mauvais_car)"
   set panneau(scanfast,saisir_indice)   "$caption(scanfast,saisir_indice)"
   set panneau(scanfast,indice_entier)   "$caption(scanfast,indice_entier)"
   set panneau(scanfast,confirmation)    "$caption(scanfast,confirmation)"
   set panneau(scanfast,fichier_existe)  "$caption(scanfast,fichier_existe)"
   set panneau(scanfast,calcul_confirm)  "$caption(scanfast,calcul_confirm)"

   #--- Initialisation des variables
   set panneau(scanfast,listBinningX)    [ list "" ]
   set panneau(scanfast,listBinningY)    [ list "" ]
   set panneau(scanfast,nom_image)       ""
   set panneau(scanfast,extension_image) "$conf(extension,defaut)"
   set panneau(scanfast,indexer)         "0"
   set panneau(scanfast,indice)          "1"
   set panneau(scanfast,acquisition)     "0"
   set panneau(Scan,Stop)                "0"

   #--- Construction de l'interface
   scanfastBuildIF $This
}

#------------------------------------------------------------
# chargerVar
#    Chargement des variables locales
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanfast::chargerVar { } {
   variable parametres

   #--- Ouverture du fichier de parametres
   set fichier [ file join $::audace(rep_home) scanfast.ini ]
   if { [ file exists $fichier ] } {
      source $fichier
   }

   #--- Creation des variables si elles n'existent pas
   if { ! [ info exists parametres(scanfast,col1) ] }       { set parametres(scanfast,col1)       "1" }
   if { ! [ info exists parametres(scanfast,col2) ] }       { set parametres(scanfast,col2)       "768" }
   if { ! [ info exists parametres(scanfast,lig1) ] }       { set parametres(scanfast,lig1)       "1500" }
   if { ! [ info exists parametres(scanfast,binningX) ] }   { set parametres(scanfast,binningX)   "2" }
   if { ! [ info exists parametres(scanfast,binningY) ] }   { set parametres(scanfast,binningY)   "2" }
   if { ! [ info exists parametres(scanfast,interligne) ] } { set parametres(scanfast,interligne) "100" }
   if { ! [ info exists parametres(scanfast,dt) ] }         { set parametres(scanfast,dt)         "40" }
   if { ! [ info exists parametres(scanfast,speed) ] }      { set parametres(scanfast,speed)      "8000" }
   if { ! [ info exists parametres(scanfast,obt) ] }        { set parametres(scanfast,obt)        "2" }

   #--- Creation des variables si elles sont vides
   if { $parametres(scanfast,col1) == "" }       { set parametres(scanfast,col1)       "1" }
   if { $parametres(scanfast,col2) == "" }       { set parametres(scanfast,col2)       "768" }
   if { $parametres(scanfast,lig1) == "" }       { set parametres(scanfast,lig1)       "1500" }
   if { $parametres(scanfast,binningX) == "" }   { set parametres(scanfast,binningX)   "2" }
   if { $parametres(scanfast,binningY) == "" }   { set parametres(scanfast,binningY)   "2" }
   if { $parametres(scanfast,interligne) == "" } { set parametres(scanfast,interligne) "100" }
   if { $parametres(scanfast,dt) == "" }         { set parametres(scanfast,dt)         "40" }
   if { $parametres(scanfast,speed) == "" }      { set parametres(scanfast,speed)      "8000" }
   if { $parametres(scanfast,obt) == "" }        { set parametres(scanfast,obt)        "2" }

   #--- Creation des variables de la boite de configuration si elles n'existent pas
   ::scanfastSetup::initToConf
}

#------------------------------------------------------------
# enregistrerVar
#    Sauvegarde des variables locales
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanfast::enregistrerVar { } {
   variable parametres
   global panneau

   #--- Changement de variables
   set parametres(scanfast,col1)       $panneau(scanfast,col1)
   set parametres(scanfast,col2)       $panneau(scanfast,col2)
   set parametres(scanfast,lig1)       $panneau(scanfast,lig1)
   set parametres(scanfast,binningX)   $panneau(scanfast,binningX)
   set parametres(scanfast,binningY)   $panneau(scanfast,binningY)
   set parametres(scanfast,interligne) $panneau(scanfast,interligne)
   set parametres(scanfast,dt)         $panneau(scanfast,dt)
   set parametres(scanfast,speed)      $panneau(scanfast,speed)
   set parametres(scanfast,obt)        $panneau(scanfast,obt)

   #--- Sauvegarde des parametres
   catch {
      set nom_fichier [ file join $::audace(rep_home) scanfast.ini ]
      if [ catch { open $nom_fichier w } fichier ] {
         #---
      } else {
         foreach { a b } [ array get parametres ] {
            puts $fichier "set parametres($a) \"$b\""
         }
         close $fichier
      }
   }
}

#------------------------------------------------------------
# initExtension
#    Met a jour l'affichage de l'extension par defaut
#
# Parametres :
#    Tous optionnels et indispensables
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanfast::initExtension { { a "" } { b "" } { c "" } } {
   global conf panneau

   #--- Mise a jour de l'extension par defaut
   set panneau(scanfast,extension_image) $conf(extension,defaut)
}

#------------------------------------------------------------
# adaptOutilScanfast
#    Adapte l'interface graphique a la configuration de la camera
#
# Parametres :
#    args : Valeurs fournies par le gestionnaire de listener
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanfast::adaptOutilScanfast { args } {
   variable This
   global conf panneau

   #--- Numero de la camera
   set camItem [ ::confVisu::getCamItem 1 ]
   set camNo   [ ::confCam::getCamNo $camItem ]

   #--- Configuration de l'obturateur
   if { $camNo != "0" } {
      if { ! [ info exists conf(audine,foncobtu) ] } {
         set conf(audine,foncobtu) "2"
      } else {
         if { $conf(audine,foncobtu) == "0" } {
            set panneau(scanfast,obt) "0"
         } elseif { $conf(audine,foncobtu) == "1" } {
            set panneau(scanfast,obt) "1"
         } elseif { $conf(audine,foncobtu) == "2" } {
            set panneau(scanfast,obt) "2"
         }
      }
      pack $This.fra4.obt.but -side left -ipady 3
      pack $This.fra4.obt.lab1 -side left -fill x -expand true -ipady 3
      pack forget $This.fra4.obt.lab2
      $This.fra4.obt.lab1 configure -text $panneau(scanfast,obt,$panneau(scanfast,obt))
   } else {
      pack forget $This.fra4.obt.but
      pack forget $This.fra4.obt.lab1
      pack $This.fra4.obt.lab2 -side top -fill x -ipady 3
   }

   #--- Mise a jour du binning X en fonction de la liaison
   set panneau(scanfast,listBinningX) [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] binningXListScan ]
   if { $panneau(scanfast,listBinningX) == "{}" } {
      $This.fra3.bin.binX configure -height 1
      $This.fra3.bin.binX configure -values "1"
   } else {
      set height [ llength $panneau(scanfast,listBinningX) ]
      if { $height > "16" } {
         set height "16"
      }
      $This.fra3.bin.binX configure -height $height
      $This.fra3.bin.binX configure -values $panneau(scanfast,listBinningX)
   }

   #--- Mise a jour du binning Y en fonction de la liaison
   set panneau(scanfast,listBinningY) [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] binningYListScan ]
   if { $panneau(scanfast,listBinningY) == "{}" } {
      $This.fra3.bin.binY configure -height 1
      $This.fra3.bin.binY configure -values "1"
   } else {
      set height [ llength $panneau(scanfast,listBinningY) ]
      if { $height > "16" } {
         set height "16"
      }
      $This.fra3.bin.binY configure -height $height
      $This.fra3.bin.binY configure -values $panneau(scanfast,listBinningY)
   }

   #--- Binnings et frames associes aux liaisons
   switch [ ::confLink::getLinkNamespace $conf(audine,port) ] {
      ethernaude {
         #--- Adaptation des binnings extremes
         if { $panneau(scanfast,binningX) > "2" } {
            set panneau(scanfast,binningX) "1"
         }
         #--- Etat du bouton et mise en forme des frames
         $This.fra33.but1 configure -state normal
         pack forget $This.fra33
         pack $This.fra4 -side top -fill x
         pack forget $This.fra4.but2
         pack $This.fra4.but2 -anchor center -fill x -padx 5 -pady 5 -ipadx 15 -ipady 3
         pack $This.fra5 -side top -fill x
      }
      parallelport {
         #--- Adaptation des binnings extremes
         if { $panneau(scanfast,binningY) > "16" } {
            set panneau(scanfast,binningY) "1"
         }
         #--- Etat du bouton et mise en forme des frames
         $This.fra33.but1 configure -state normal
         pack $This.fra33 -side top -fill x
         pack forget $This.fra4
         pack $This.fra4 -side top -fill x
         pack forget $This.fra4.but2
         pack forget $This.fra5
         pack $This.fra5 -side top -fill x
      }
      default {
         #--- Etat du bouton
         $This.fra33.but1 configure -state disabled
      }
   }
}

#------------------------------------------------------------
# startTool
#    Affiche l'interface de l'outil
#
# Parametres :
#    visuNo : Numero de la visu
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanfast::startTool { visuNo } {
   variable This
   variable parametres
   global caption panneau

   #--- On cree la variable de configuration des mots cles
   if { ! [ info exists ::conf(scanfast,keywordConfigName) ] } { set ::conf(scanfast,keywordConfigName) "default" }

   #--- Chargement de la configuration
   chargerVar

   #--- Initialisation des variables de l'outil
   set panneau(scanfast,col1)       "$parametres(scanfast,col1)"
   set panneau(scanfast,col2)       "$parametres(scanfast,col2)"
   set panneau(scanfast,lig1)       "$parametres(scanfast,lig1)"
   set panneau(scanfast,binningX)   "$parametres(scanfast,binningX)"
   set panneau(scanfast,binningY)   "$parametres(scanfast,binningY)"
   set panneau(scanfast,interligne) "$parametres(scanfast,interligne)"
   set panneau(scanfast,dt)         "$parametres(scanfast,dt)"
   set panneau(scanfast,speed)      "$parametres(scanfast,speed)"
   set panneau(scanfast,obt)        "$parametres(scanfast,obt)"

   #--- Initialisation des variables de la boite de configuration
   ::scanfastSetup::confToWidget

   #--- Entrer ici les valeurs pour l'obturateur a afficher dans le menu "obt"
   set panneau(scanfast,obt,0) "$caption(scanfast,obtu_ouvert)"
   set panneau(scanfast,obt,1) "$caption(scanfast,obtu_ferme)"
   set panneau(scanfast,obt,2) "$caption(scanfast,obtu_synchro)"

   #--- Configuration dynamique de l'outil en fonction de la liaison
   adaptOutilScanfast

   #--- Je selectionne les mots cles selon les exigences de l'outil
   ::scanfast::configToolKeywords $visuNo

   #--- Mise en service de la surveillance de la connexion d'une camera
   ::confVisu::addCameraListener $visuNo ::scanfast::adaptOutilScanfast
}

#------------------------------------------------------------
# stopTool
#    Masque l'interface de l'outil
#
# Parametres :
#    visuNo : Numero de la visu
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanfast::stopTool { visuNo } {
   variable This
   global panneau

   #--- Je verifie si une operation est en cours
   if { $panneau(scanfast,acquisition) == 1 } {
      return -1
   }

   #--- Sauvegarde de la configuration
   enregistrerVar

   #--- Je supprime la liste des mots clefs non modifiables
   ::keyword::setKeywordState $visuNo $::conf(scanfast,keywordConfigName) [ list ]

   #--- Arret de la surveillance de la connexion d'une camera
   ::confVisu::removeCameraListener $visuNo ::scanfast::adaptOutilScanfast
}

#------------------------------------------------------------
# getNameKeywords
#    definit le nom de la configuration des mots cles FITS de l'outil
#    uniquement pour les outils qui configurent les mots cles selon des
#    exigences propres a eux
#------------------------------------------------------------
proc ::scanfast::getNameKeywords { visuNo configName } {
   #--- Je definis le nom
   set ::conf(scanfast,keywordConfigName) $configName
}

#------------------------------------------------------------
# configToolKeywords
#    configure les mots cles FITS de l'outil
#------------------------------------------------------------
proc ::scanfast::configToolKeywords { visuNo { configName "" } } {
   #--- Je traite la variable configName
   if { $configName == "" } {
      set configName $::conf(scanfast,keywordConfigName)
   }

   #--- Je selectionne les mots cles optionnels a ajouter dans les images
   #--- Ce sont les mots cles CRPIX1, CRPIX2
   ::keyword::selectKeywords $visuNo $configName [ list CRPIX1 CRPIX2 ]

   #--- Je selectionne la liste des mots cles non modifiables
   ::keyword::setKeywordState $visuNo $configName [ list CRPIX1 CRPIX2 ]

   #--- Je force la capture des mots cles RA et DEC en manuel
   ::keyword::setKeywordsRaDecManuel $visuNo
}

#------------------------------------------------------------
# int
#    Arrondis un nombre reel a l'entier superieur
#
# Parametres :
#    value : Valeur numerique a formater
# Return :
#    value : Valeur numerique formatee
#------------------------------------------------------------
proc ::scanfast::int { value } {
   set a [ expr ceil($value) ]
   set index [ string first . $a ]
   if { $index != "-1" } {
      set point [ expr $index-1 ]
      set value [ string range $a 0 $point ]
   }
   return $value
}

#------------------------------------------------------------
# cmdGo
#    Lancement d'une acquisition et acquisition de drift scan avec
#    controle du moteur de suivi
#
# Parametres :
#    motor : Etat du moteur, motoron ou motoroff (optionnel)
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanfast::cmdGo { { motor motoron } } {
   variable This
   variable parametres
   global audace caption conf panneau

   if { [ ::cam::list ] != "" } {
      if { [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] hasScan ] == "1" } {
         #--- Initialisation des variables
         set panneau(scanfast,acquisition) "1"
         set panneau(Scan,Stop)            "0"

         #--- Les champs "Colonnes", "Lignes" et "Interligne" ne doivent pas etre vides
         if { $panneau(scanfast,col1) == "" } {
            set panneau(scanfast,col1) $parametres(scanfast,col1)
         }
         if { $panneau(scanfast,col2) == "" } {
            set panneau(scanfast,col2) $parametres(scanfast,col2)
         }
         if { $panneau(scanfast,lig1) == "" } {
            set panneau(scanfast,lig1) $parametres(scanfast,lig1)
         }
         if { $panneau(scanfast,interligne) == "" } {
            set panneau(scanfast,interligne) $parametres(scanfast,interligne)
         }

         #--- Les 2 champs de la "Calibration" ne doivent pas etre vides
         if { $panneau(scanfast,dt) == "" } {
            cmdCalcul
         }
         if { $panneau(scanfast,speed) == "" } {
            cmdCalcul
         }

         #--- Le nombre de ligne du scan doit etre superieur ou egal a 2
         if { $panneau(scanfast,lig1) < "0" } {
            set panneau(scanfast,lig1) [ expr abs($panneau(scanfast,lig1)) ]
         }
         if { $panneau(scanfast,lig1) < "2" } {
            set panneau(scanfast,lig1) "2"
         }

         #--- La premiere colonne (firstpix) doit etre superieure ou egale a 1
         if { $panneau(scanfast,col1) < "0" } {
            set panneau(scanfast,col1) [ expr abs($panneau(scanfast,col1)) ]
         }
         if { $panneau(scanfast,col1) < "1" } {
            set panneau(scanfast,col1) "1"
         }

         #--- La seconde colonne doit etre superieure ou egale a 2
         if { $panneau(scanfast,col2) < "0" } {
            set panneau(scanfast,col2) [ expr abs($panneau(scanfast,col2)) ]
         }
         if { $panneau(scanfast,col2) < "2" } {
            set panneau(scanfast,col2) "2"
         }

         #--- La seconde colonne doit etre superieure a la premiere colonne
         if { $panneau(scanfast,col2) < $panneau(scanfast,col1) } {
            set colonne                "$panneau(scanfast,col2)"
            set panneau(scanfast,col2) "$panneau(scanfast,col1)"
            set panneau(scanfast,col1) "$colonne"
         }

         #--- Calcul de la colonne maxi du CCD
         set colonneMaxi "[ lindex [ cam$audace(camNo) nbcells ] 0 ]"

         #--- La premiere colonne doit etre inferieure a la largeur du CCD
         if { $panneau(scanfast,col1) > "$colonneMaxi" } {
            set panneau(scanfast,col1) "1"
         }

         #--- La seconde colonne doit etre inferieure a la largeur du CCD
         if { $panneau(scanfast,col2) > "$colonneMaxi" } {
            set panneau(scanfast,col2) "$colonneMaxi"
         }

         #--- Gestion graphique du bouton GO CCD
         $This.fra4.but1 configure -relief groove -text $panneau(scanfast,go1) -state disabled
         update

         #--- Gestion graphique du bouton STOP - Inactif avant le debut du scan
         $This.fra4.but2 configure -relief groove -text $panneau(scanfast,stop) -state disabled
         update

         #--- Definition du binning
         switch [ ::confLink::getLinkNamespace $conf(audine,port) ] {
            ethernaude {
               set bin  "$panneau(scanfast,binningX)"
               set binY "$panneau(scanfast,binningY)"
            }
            parallelport {
               set bin  "$panneau(scanfast,binningX)"
               set binY "$panneau(scanfast,binningY)"
            }
            default {
               set bin  "1"
               set binY "1"
            }
         }

         #--- Definition des parametres du scan (w : largeur - h : hauteur - f : firstpix)
         set w [ int [ expr $panneau(scanfast,col2) - $panneau(scanfast,col1) + 1 ] ]
         set h [ int $panneau(scanfast,lig1) ]
         set f [ int $panneau(scanfast,col1) ]
         if { $panneau(scanfast,temps_mort) == "0" } {
            set temps_mort "20" ; #--- Estimation du temps mort a 20 ms par ligne
         } else {
            set temps_mort $panneau(scanfast,temps_mort)
         }
         #--- Duree exprimee en secondes
         set duree [ expr ($panneau(scanfast,dt)+$temps_mort)*$h/1000 ]

         #--- Gestion du moteur d'A.D.
         if { $motor == "motoroff" } {
            if { [ ::tel::list ] != "" } {
               #--- Arret du moteur d'AD
               tel$audace(telNo) radec motor off
            }
         }

         #--- Attente du demarrage du scan
         if { $panneau(scanfast,active) == "1" } {
            #--- Decompte du temps d'attente
            set attente $panneau(scanfast,delai)
            if { $panneau(scanfast,delai) > "0" } {
               while { $panneau(scanfast,delai) > "0" } {
                  ::camera::avancementScan "-10" $panneau(scanfast,lig1) $panneau(scanfast,delai)
                  update
                  after 1000
                  incr panneau(scanfast,delai) "-1"
               }
            }
            set panneau(scanfast,delai) $attente
         }

         #--- Gestion graphique du bouton STOP - Devient actif avec le debut du scan
         $This.fra4.but2 configure -relief raised -text $panneau(scanfast,stop) -state normal
         update

         #--- Declenchement de l'acquisition
         if { [ ::confLink::getLinkNamespace $conf(audine,port) ] == "parallelport" } {
            #--- Destruction de la fenetre indiquant l'attente
            if [ winfo exists $audace(base).progress_scan ] {
               destroy $audace(base).progress_scan
            }
            #--- Calcul de l'heure TU de debut du scan
            set date_beg [ clock format [ clock seconds ] -format "%d/%m/%Y %H:%M:%S $caption(audace,temps_universel)" -timezone :UTC ]
            #--- Calcul de l'heure TU previsionnelle de fin du scan
            set date_end [ clock format [ expr { [ clock seconds ] + $duree } ] -format "%d/%m/%Y %H:%M:%S $caption(audace,temps_universel)" -timezone :UTC ]
            #--- Creation d'une fenetre pour l'affichage des heures de debut et de fin du scan
            if [ winfo exists $audace(base).wintimeaudace ] {
               destroy $audace(base).wintimeaudace
            }
            toplevel $audace(base).wintimeaudace
            wm transient $audace(base).wintimeaudace $audace(base)
            wm resizable $audace(base).wintimeaudace 0 0
            wm title $audace(base).wintimeaudace "$caption(scanfast,scanfast)"
            set posx_wintimeaudace [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
            set posy_wintimeaudace [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
            wm geometry $audace(base).wintimeaudace +[ expr $posx_wintimeaudace + 350 ]+[ expr $posy_wintimeaudace + 75 ]
            label $audace(base).wintimeaudace.lab_beg -text "\n$caption(scanfast,debut) $date_beg"
            pack $audace(base).wintimeaudace.lab_beg -padx 10 -pady 5
            label $audace(base).wintimeaudace.lab_end -text "$caption(scanfast,fin) $date_end\n"
            pack $audace(base).wintimeaudace.lab_end -padx 10 -pady 5
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $audace(base).wintimeaudace
            #--- Focus
            update
            focus $audace(base).wintimeaudace
            #--- Declenchement de l'acquisition
            cam$audace(camNo) scan $w $h $bin $panneau(scanfast,dt) -biny $binY -firstpix $f -fast $panneau(scanfast,speed) -tmpfile
         } else {
            #--- Calcul du nombre de lignes par seconde
            set panneau(scanfast,nblg1) [ expr 1000./$panneau(scanfast,interligne) ]
            set panneau(scanfast,nblg)  [ expr int($panneau(scanfast,nblg1)) + 1 ]
            #--- Declenchement de l'acquisition
            cam$audace(camNo) scan $w $h $bin $panneau(scanfast,interligne) -biny $binY -firstpix $f -tmpfile
            #--- Alarme sonore de fin de pose
            set pseudoexptime [ expr $panneau(scanfast,lig1)/$panneau(scanfast,nblg1) ]
            ::camera::alarmeSonore $pseudoexptime
            #--- Appel du timer
            if { $panneau(scanfast,lig1) > "$panneau(scanfast,nblg)" } {
               set t [ expr $panneau(scanfast,lig1) / $panneau(scanfast,nblg1) ]
               ::camera::dispLine $t $panneau(scanfast,nblg1) $panneau(scanfast,lig1) $panneau(scanfast,delai)
            }
            #--- Attente de la fin de la pose
            vwait scan_result$audace(camNo)
            #--- Destruction de la fenetre d'avancement du scan
            set panneau(Scan,Stop) "1"
            if [ winfo exists $audace(base).progress_scan ] {
               destroy $audace(base).progress_scan
            }
         }

         #--- Rajoute des mots cles dans l'en-tete FITS
         foreach keyword [ ::keyword::getKeywords $audace(visuNo) $::conf(scanfast,keywordConfigName) ] {
            buf$audace(bufNo) setkwd $keyword
         }

         #--- Rajoute la date de debut et de fin de pose en jour julien dans l'en-tete FITS
         ::keyword::addJDayOBSandEND

         #--- Mise a jour du nom du fichier dans le titre et de la fenetre de l'en-tete FITS
         ::confVisu::setFileName $audace(visuNo) ""

         #--- Gestion graphique du bouton GO CCD
         $This.fra4.but1 configure -relief groove -text $panneau(scanfast,go2) -state disabled
         update

         #--- Visualisation de l'image
         ::audace::autovisu $audace(visuNo)

         #--- Destruction de la fenetre d'affichage des heures de debut et de fin du scan
         destroy $audace(base).wintimeaudace

         #--- Gestion du moteur d'A.D.
         if { $motor == "motoroff" } {
            if { [ ::tel::list ] != "" } {
               #--- Remise en marche moteur A.D. LX200
               tel$audace(telNo) radec motor on
            }
         }

         #--- Gestion graphique du bouton GO CCD
         set panneau(scanfast,acquisition) "0"
         $This.fra4.but1 configure -relief raised -text $panneau(scanfast,go0) -state normal
         update
      } else {
         tk_messageBox -title $panneau(scanfast,attention) -type ok -message $panneau(scanfast,msg)
      }
   } else {
      ::confCam::run
   }
}

#------------------------------------------------------------
# cmdStop
#    Arret d'une acquisition de drift scan
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanfast::cmdStop { } {
   variable This
   global audace panneau

   if { [ ::cam::list ] != "" } {
      if { $panneau(scanfast,acquisition) == "1" } {
         catch {
            #--- Changement de la valeur de la variable
            set panneau(Scan,Stop) "1"

            #--- Annulation de l'alarme de fin de pose
            catch { after cancel bell }

            #--- Annulation de la pose
            cam$audace(camNo) breakscan
            after 200

            #--- Visualisation de l'image
            ::audace::autovisu $audace(visuNo)

            #--- Gestion du moteur d'A.D.
            if { [ ::tel::list ] != "" } {
               #--- Remise en marche du moteur d'AD
               tel$audace(telNo) radec motor on
            }

            #--- Gestion du graphisme du bouton
            $This.fra4.but1 configure -relief raised -text $panneau(scanfast,go1) -state disabled
            update
         }
      }
   } else {
      ::confCam::run
   }
}

#------------------------------------------------------------
# cmdCalcul
#    Calcul de l'interligne
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanfast::cmdCalcul { } {
   variable This
   variable parametres
   global audace conf panneau

   if { [ ::cam::list ] != "" } {
      $This.fra33.but1 configure -relief groove -state disabled
      update

      #--- Les champs "Colonnes", "Lignes" et "Interligne" ne doivent pas etre vides
      if { $panneau(scanfast,col1) == "" } {
         set panneau(scanfast,col1) $parametres(scanfast,col1)
      }
      if { $panneau(scanfast,col2) == "" } {
         set panneau(scanfast,col2) $parametres(scanfast,col2)
      }
      if { $panneau(scanfast,lig1) == "" } {
         set panneau(scanfast,lig1) $parametres(scanfast,lig1)
      }
      if { $panneau(scanfast,interligne) == "" } {
         set panneau(scanfast,interligne) $parametres(scanfast,interligne)
      }

      #--- Le nombre de ligne du scan doit etre superieur ou egal a 2
      if { $panneau(scanfast,lig1) < "0" } {
         set panneau(scanfast,lig1) [ expr abs($panneau(scanfast,lig1)) ]
      }
      if { $panneau(scanfast,lig1) < "2" } {
         set panneau(scanfast,lig1) "2"
      }

      #--- La premiere colonne (firstpix) doit etre superieure ou egale a 1
      if { $panneau(scanfast,col1) < "0" } {
         set panneau(scanfast,col1) [ expr abs($panneau(scanfast,col1)) ]
      }
      if { $panneau(scanfast,col1) < "1" } {
         set panneau(scanfast,col1) "1"
      }

      #--- La seconde colonne doit etre superieure ou egale a 2
      if { $panneau(scanfast,col2) < "0" } {
         set panneau(scanfast,col2) [ expr abs($panneau(scanfast,col2)) ]
      }
      if { $panneau(scanfast,col2) < "2" } {
         set panneau(scanfast,col2) "2"
      }

      #--- La seconde colonne doit etre superieure a la premiere colonne
      if { $panneau(scanfast,col2) < $panneau(scanfast,col1) } {
         set colonne                "$panneau(scanfast,col2)"
         set panneau(scanfast,col2) "$panneau(scanfast,col1)"
         set panneau(scanfast,col1) "$colonne"
      }

      #--- Calcul de la colonne maxi du CCD
      set colonneMaxi "[ lindex [ cam$audace(camNo) nbcells ] 0 ]"

      #--- La premiere colonne doit etre inferieure a la largeur du CCD
      if { $panneau(scanfast,col1) > "$colonneMaxi" } {
         set panneau(scanfast,col1) "1"
      }

      #--- La seconde colonne doit etre inferieure a la largeur du CCD
      if { $panneau(scanfast,col2) > "$colonneMaxi" } {
         set panneau(scanfast,col2) "$colonneMaxi"
      }

      #---
      switch [ ::confLink::getLinkNamespace $conf(audine,port) ] {
         ethernaude {
            set bin  "$panneau(scanfast,binningX)"
            set binY "$panneau(scanfast,binningY)"
         }
         parallelport {
            set bin  "$panneau(scanfast,binningX)"
            set binY "$panneau(scanfast,binningY)"
         }
         default {
            set bin  "1"
            set binY "1"
         }
      }
      set w [ int [ expr ( $panneau(scanfast,col2) - $panneau(scanfast,col1) + 1 ) / $bin ] ]
      set h [ int $panneau(scanfast,lig1) ]
      set f [ int [ expr $panneau(scanfast,col1) / $bin ] ]
      set results [ prescanfast $w $h $panneau(scanfast,interligne) $f $binY ]
      set panneau(scanfast,dt) [ lindex $results 0 ]
      set panneau(scanfast,speed) [ lindex $results 1 ]
      $This.fra33.fra1.ent1 configure -textvariable panneau(scanfast,dt)
      $This.fra33.fra2.ent1 configure -textvariable panneau(scanfast,speed)
      $This.fra33.but1 configure -relief raised -state normal
      update
   } else {
      ::confCam::run
   }
}

#------------------------------------------------------------
# infoCam
#    Mise a jour de donnees de la camera et relance le calcul de l'interligne
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanfast::infoCam { } {
   variable This
   variable parametres
   global audace conf panneau

   if { [ ::cam::list ] != "" } {
      set parametres(scanfast,col2) "[ lindex [ cam$audace(camNo) nbcells ] 0 ]"
      set panneau(scanfast,col2)    "$parametres(scanfast,col2)"
      $This.fra2.fra1.ent2 configure -textvariable panneau(scanfast,col2)
      update
   }
   if { $conf(audine,port) == "LPT1:" } {
      set choix [ tk_messageBox -type yesno -icon warning -title "$panneau(scanfast,calcul)" \
         -message "$panneau(scanfast,calcul_confirm)" ]
      if { $choix == "yes" } {
         cmdCalcul
      }
   } elseif { $conf(audine,port) == "LPT2:" } {
      set choix [ tk_messageBox -type yesno -icon warning -title "$panneau(scanfast,calcul)" \
         -message "$panneau(scanfast,calcul_confirm)" ]
      if { $choix == "yes" } {
         cmdCalcul
      }
   } elseif { $conf(audine,port) == "LPT3:" } {
      set choix [ tk_messageBox -type yesno -icon warning -title "$panneau(scanfast,calcul)" \
         -message "$panneau(scanfast,calcul_confirm)" ]
      if { $choix == "yes" } {
         cmdCalcul
      }
   }
}

#------------------------------------------------------------
# changeObt
#    Gere le changement de mode de l'obturateur
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanfast::changeObt { } {
   variable This
   global panneau

   if { [ ::cam::list ] != "" } {
      set camItem [ ::confVisu::getCamItem 1 ]
      set result [::confCam::setShutter $camItem $panneau(scanfast,obt)]
      if { $result != -1 } {
         set panneau(scanfast,obt) $result
         $This.fra4.obt.lab1 configure -text $panneau(scanfast,obt,$panneau(scanfast,obt))
      }
   } else {
      ::confCam::run
   }
}

#------------------------------------------------------------
# sauveUneImage
#    Sauvegarde du drift scan acquis
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanfast::sauveUneImage { } {
   global audace conf panneau

   #--- Enregistrer l'extension des fichiers
   set ext $conf(extension,defaut)

   #--- Tests d'integrite de la requete

   #--- Verifier qu'il y a bien un nom de fichier
   if { $panneau(scanfast,nom_image) == "" } {
      tk_messageBox -title $panneau(scanfast,pb) -type ok \
         -message $panneau(scanfast,nom_fichier)
      return
   }

   #--- Verifier que le nom de fichier n'a pas d'espace
   if { [ llength $panneau(scanfast,nom_image) ] > "1" } {
      tk_messageBox -title $panneau(scanfast,pb) -type ok \
         -message $panneau(scanfast,nom_blanc)
      return
   }

   #--- Si la case index est cochee, verifier qu'il y a bien un index
   if { $panneau(scanfast,indexer) == "1" } {
      #--- Verifier que l'index existe
      if { $panneau(scanfast,indice) == "" } {
         tk_messageBox -title $panneau(scanfast,pb) -type ok \
            -message $panneau(scanfast,saisir_indice)
         return
      }
   }

   #--- Generer le nom du fichier
   set nom $panneau(scanfast,nom_image)

   #--- Pour eviter un nom de fichier qui commence par un blanc
   set nom [ lindex $nom 0 ]
   if { $panneau(scanfast,indexer) == "1" } {
      append nom $panneau(scanfast,indice)
   }

   #--- Verifier que le nom du fichier n'existe pas deja
   set nom1 "$nom"
   append nom1 $ext
   if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
      #--- Dans ce cas, le fichier existe deja
      set confirmation [ tk_messageBox -title $panneau(scanfast,confirmation) -type yesno \
         -message $panneau(scanfast,fichier_existe) ]
      if { $confirmation == "no" } {
         return
      }
   }

   #--- Incrementer l'index
   if { $panneau(scanfast,indexer) == "1" } {
      if { [ buf$audace(bufNo) imageready ] != "0" } {
         incr panneau(scanfast,indice)
      } else {
         #--- Sortir immediatement s'il n'y a pas d'image dans le buffer
         return
      }
   }

   #--- Mise a jour du nom du fichier dans le titre et de la fenetre de l'en-tete FITS
   ::confVisu::setFileName $audace(visuNo) $nom$ext

   #--- Sauvegarder l'image
   saveima $nom
}

#------------------------------------------------------------
# scanfastBuildIF
#    Interface graphique
#
# Parametres :
#    This : Widget parent
# Return :
#    Rien
#------------------------------------------------------------
proc scanfastBuildIF { This } {
   global audace panneau

   #--- Frame de l'outil
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra0 -borderwidth 2 -relief groove

         #--- Bouton du titre
         Button $This.fra0.but -borderwidth 1 \
            -text "$panneau(scanfast,aide1)\n$panneau(scanfast,titre)" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::scanfast::getPluginType ] ] \
               [ ::scanfast::getPluginDirectory ] [ ::scanfast::getPluginHelp ]"
         pack $This.fra0.but -in $This.fra0 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra0.but -text $panneau(scanfast,aide)

      pack $This.fra0 -side top -fill x

      #--- Frame du bouton de configuration
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du bouton Configuration
         button $This.fra1.but -borderwidth 1 -text $panneau(scanfast,configuration) \
            -command { ::scanfastSetup::run $audace(base).scanfastSetup }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5

      pack $This.fra1 -side top -fill x

      #--- Frame des colonnes et des lignes
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label pour colonnes
         label $This.fra2.lab1 -text $panneau(scanfast,col) -relief flat
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -fill none -padx 4 -pady 1

         #--- Frame des 2 entries de colonnes
         frame $This.fra2.fra1 -borderwidth 1 -relief flat

            #--- Entry pour la colonne de debut
            entry $This.fra2.fra1.ent1 -textvariable panneau(scanfast,col1) \
               -relief groove -width 5 -justify center
            pack $This.fra2.fra1.ent1 -in $This.fra2.fra1 -side left -fill none -padx 4 -pady 2

            #--- Entry pour la colonne de fin
            entry $This.fra2.fra1.ent2 -textvariable panneau(scanfast,col2) \
               -relief groove -width 5 -justify center
            pack $This.fra2.fra1.ent2 -in $This.fra2.fra1 -side right -fill none -padx 4 -pady 2

         pack $This.fra2.fra1 -in $This.fra2 -anchor center -fill none

         #--- Label pour lignes
         label $This.fra2.lab2 -text $panneau(scanfast,lig) -relief flat
         pack $This.fra2.lab2 -in $This.fra2 -anchor center -fill none -padx 4 -pady 1

         #--- Entry pour lignes
         entry $This.fra2.ent1 -textvariable panneau(scanfast,lig1) \
            -relief groove -width 5 -justify center
         pack $This.fra2.ent1 -in $This.fra2 -anchor center -fill none -padx 4 -pady 2

      pack $This.fra2 -side top -fill x

      #--- Binding sur la zone des infos de la camera
      set zone(camera) $This.fra2
      bind $zone(camera) <ButtonPress-1>      { ::scanfast::infoCam }
      bind $zone(camera).lab1 <ButtonPress-1> { ::scanfast::infoCam }
      bind $zone(camera).lab2 <ButtonPress-1> { ::scanfast::infoCam }

      #--- Frame de l'interligne
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Label pour interligne
         label $This.fra3.lab1 -text $panneau(scanfast,interligne) -relief flat
         pack $This.fra3.lab1 -in $This.fra3 -anchor center -fill none -padx 4 -pady 1

         #--- Frame pour binning (seulement port parallele et EthernAude)
         frame $This.fra3.bin -borderwidth 0 -relief groove

            #--- Label pour binning X
            label $This.fra3.bin.lab1 -text $panneau(scanfast,bin) -relief flat
            pack $This.fra3.bin.lab1 -in $This.fra3.bin -side left -fill none

            #--- Combobox pour binning X
            ComboBox $This.fra3.bin.binX \
               -width 3        \
               -justify center \
               -height [ llength $panneau(scanfast,listBinningX) ] \
               -relief sunken  \
               -borderwidth 1  \
               -editable 0     \
               -textvariable panneau(scanfast,binningX) \
               -values $panneau(scanfast,listBinningX) \
               -modifycmd " "
            pack $This.fra3.bin.binX -in $This.fra3.bin -side left -fill none

            #--- Label pour binning Y
            label $This.fra3.bin.lab2 -text "x" -relief flat
            pack $This.fra3.bin.lab2 -in $This.fra3.bin -side left -fill none

            #--- Combobox pour binning Y
            ComboBox $This.fra3.bin.binY \
               -width 3        \
               -justify center \
               -height [ llength $panneau(scanfast,listBinningY) ] \
               -relief sunken  \
               -borderwidth 1  \
               -editable 0     \
               -textvariable panneau(scanfast,binningY) \
               -values $panneau(scanfast,listBinningY) \
               -modifycmd " "
            pack $This.fra3.bin.binY -in $This.fra3.bin -side left -fill none

         pack $This.fra3.bin -in $This.fra3 -anchor n -fill x -expand 0 -pady 2

         #--- Frame des entry & label
         frame $This.fra3.fra1 -borderwidth 1 -relief flat

            #--- Entry pour les millisecondes
            entry $This.fra3.fra1.ent1 -textvariable panneau(scanfast,interligne) \
               -relief groove -width 6 -justify center
            pack $This.fra3.fra1.ent1 -in $This.fra3.fra1 -side left -fill none -padx 4 -pady 2

            #--- Label pour l'unite
            label $This.fra3.fra1.ent2 -text $panneau(scanfast,ms) -relief flat
            pack $This.fra3.fra1.ent2 -in $This.fra3.fra1 -side left -fill none -padx 2 -pady 2

         pack $This.fra3.fra1 -in $This.fra3 -anchor center -fill none

      pack $This.fra3 -side top -fill x

      #--- Frame de la calibration
      frame $This.fra33 -borderwidth 1 -relief groove

         #--- Label pour calibrations
         label $This.fra33.lab1 -text $panneau(scanfast,calib) -relief flat
         pack $This.fra33.lab1 -in $This.fra33 -anchor center -fill none -padx 4 -pady 1

         #--- Bouton Calcul
         button $This.fra33.but1 -borderwidth 2 -text $panneau(scanfast,calcul) \
            -command "::scanfast::cmdCalcul"
         pack $This.fra33.but1 -in $This.fra33 -anchor center -fill none -ipadx 13 -pady 1

         #--- Frame des entry & label de DT
         frame $This.fra33.fra1 -borderwidth 1 -relief flat

            #--- Entry pour DT
            entry $This.fra33.fra1.ent1 -textvariable panneau(scanfast,dt) -relief groove -width 8
            pack $This.fra33.fra1.ent1 -in $This.fra33.fra1 -side left -fill none -padx 2 -pady 2

            #--- Label pour les ms
            label $This.fra33.fra1.ent2 -text $panneau(scanfast,ms) -relief flat
            pack $This.fra33.fra1.ent2 -in $This.fra33.fra1 -side left -fill none -padx 2 -pady 2

         pack $This.fra33.fra1 -in $This.fra33 -anchor center -fill none

         #--- Frame des entry & label de SPEED
         frame $This.fra33.fra2 -borderwidth 1 -relief flat

            #--- Entry pour SPEED
            entry $This.fra33.fra2.ent1 -textvariable panneau(scanfast,speed) -relief groove -width 8
            pack $This.fra33.fra2.ent1 -in $This.fra33.fra2 -side left -fill none -padx 2 -pady 2

            #--- Label pour les boucles
            label $This.fra33.fra2.ent2 -text $panneau(scanfast,loops) -relief flat
            pack $This.fra33.fra2.ent2 -in $This.fra33.fra2 -side left -fill none -padx 2 -pady 2

         pack $This.fra33.fra2 -in $This.fra33 -anchor center -fill none

      pack $This.fra33 -side top -fill x

      #--- Frame de l'acquisition
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Frame de l'obturateur
         frame $This.fra4.obt -borderwidth 2 -relief ridge -width 16

            #--- Bouton de changement d'etat de l'obturateur
            button $This.fra4.obt.but -text $panneau(scanfast,obturateur) -command "::scanfast::changeObt" \
               -state normal
            pack $This.fra4.obt.but -side left -ipady 3

            #--- Label pour l'etat de l'obturateur
            label $This.fra4.obt.lab1 -text "" -width 6 -relief groove
            pack $This.fra4.obt.lab1 -side left -fill x -expand true -ipady 3

            #--- Label avant la connexion de la camera
            label $This.fra4.obt.lab2 -text "" -relief ridge -justify center
            pack $This.fra4.obt.lab2 -side top -fill x -ipady 3

         pack $This.fra4.obt -side top -fill x

         #--- Label pour l'acquisition
         label $This.fra4.lab1 -text $panneau(scanfast,acq) -relief flat
         pack $This.fra4.lab1 -in $This.fra4 -anchor center -fill none -padx 4 -pady 1

         #--- Bouton GO
         button $This.fra4.but1 -borderwidth 2 -text $panneau(scanfast,go) \
            -command "::scanfast::cmdGo motoroff"
         pack $This.fra4.but1 -in $This.fra4 -anchor center -fill x -padx 5 -ipadx 10 -ipady 3

         #--- Bouton STOP
         button $This.fra4.but2 -borderwidth 2 -text $panneau(scanfast,stop) \
            -command "::scanfast::cmdStop"
         pack $This.fra4.but2 -in $This.fra4 -anchor center -fill x -padx 5 -pady 5 -ipadx 15 -ipady 3

      pack $This.fra4 -side top -fill x

      #--- Frame de la sauvegarde de l'image
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Frame du nom de l'image
         frame $This.fra5.nom -relief ridge -borderwidth 2

            #--- Label du nom de l'image
            label $This.fra5.nom.lab1 -text $panneau(scanfast,nom) -pady 0
            pack $This.fra5.nom.lab1 -fill x -side top

            #--- Entry du nom de l'image
            entry $This.fra5.nom.ent1 -width 10 -textvariable panneau(scanfast,nom_image) -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $This.fra5.nom.ent1 -fill x -side top

            #--- Label de l'extension
            label $This.fra5.nom.lab_extension -text $panneau(scanfast,extension) -pady 0
            pack $This.fra5.nom.lab_extension -fill x -side left

            #--- Button pour le choix de l'extension
            button $This.fra5.nom.extension -textvariable panneau(scanfast,extension_image) \
               -width 7 -command "::confFichierIma::run $audace(base).confFichierIma"
            pack $This.fra5.nom.extension -side right -fill x

         pack $This.fra5.nom -side top -fill x

         #--- Frame de l'index
         frame $This.fra5.index -relief ridge -borderwidth 2

            #--- Checkbutton pour le choix de l'indexation
            checkbutton $This.fra5.index.case -pady 0 -text $panneau(scanfast,index) -variable panneau(scanfast,indexer)
            pack $This.fra5.index.case -side top -fill x

            #--- Entry de l'index
            entry $This.fra5.index.ent2 -width 3 -textvariable panneau(scanfast,indice) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $This.fra5.index.ent2 -side left -fill x -expand true

            #--- Bouton de mise a 1 de l'index
            button $This.fra5.index.but1 -text "1" -width 3 -command "set panneau(scanfast,indice) 1"
            pack $This.fra5.index.but1 -side right -fill x

         pack $This.fra5.index -side top -fill x

         #--- Bouton pour sauvegarder l'image
         button $This.fra5.but_sauve -text $panneau(scanfast,sauvegarde) -command "::scanfast::sauveUneImage"
         pack $This.fra5.but_sauve -side top -fill x

      pack $This.fra5 -side top -fill x

      bind $This.fra4.but1 <ButtonPress-3> { ::scanfast::cmdGo motoron }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

