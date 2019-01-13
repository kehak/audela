#
# Fichier : scan.tcl
# Description : Outil pour l'acquisition en mode drift scan
# Compatibilite : Montures LX200, AudeCom et Ouranos avec camera Audine (liaisons parallele et EthernAude)
# Auteur : Alain KLOTZ
# Mise à jour $Id: scan.tcl 12688 2016-01-16 18:53:20Z robertdelmas $
#

#============================================================
# Declaration du namespace scan
#    Initialise le namespace
#============================================================
namespace eval ::scan {
   package provide scan 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] scan.cap ]
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
proc ::scan::getPluginTitle { } {
   global caption

   return "$caption(scan,drift_scan)"
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
proc ::scan::getPluginHelp { } {
   return "scan.htm"
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
proc ::scan::getPluginType { } {
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
proc ::scan::getPluginDirectory { } {
   return "scan"
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
proc ::scan::getPluginOS { } {
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
proc ::scan::getPluginProperty { propertyName } {
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
proc ::scan::createPluginInstance { base { visuNo 1 } } {
   global audace

   #--- Chargement des fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool scan scanSetup.tcl ]\""

   #--- Mise en place de l'interface graphique
   createPanel $base.scan

   #--- Surveillance de l'extension par defaut
   trace add variable ::conf(extension,defaut) write ::scan::initExtension

   return $base.scan
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
proc ::scan::deletePluginInstance { visuNo } {
   #--- Je desactive la surveillance de l'extension par defaut
   trace remove variable ::conf(extension,defaut) write ::scan::initExtension
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
proc ::scan::createPanel { this } {
   variable This
   global caption conf panneau

   #--- Initialisation du nom du widget
   set This $this

   #--- Initialisation des captions
   set panneau(scan,titre)           "$caption(scan,drift_scan)"
   set panneau(scan,aide)            "$caption(scan,help_titre)"
   set panneau(scan,aide1)           "$caption(scan,help_titre1)"
   set panneau(scan,configuration)   "$caption(scan,configuration)"
   set panneau(scan,col)             "$caption(scan,colonnes)"
   set panneau(scan,lig)             "$caption(scan,lignes)"
   set panneau(scan,pixel)           "$caption(scan,pixel)"
   set panneau(scan,unite)           "$caption(scan,micron)"
   set panneau(scan,interlig)        "$caption(scan,interligne)"
   set panneau(scan,bin)             "$caption(scan,binning)"
   set panneau(scan,focale)          "$caption(scan,focale)"
   set panneau(scan,metres)          "$caption(scan,metre)"
   set panneau(scan,declinaison)     "$caption(scan,declinaison)"
   set panneau(scan,calcul)          "$caption(scan,calcul)"
   set panneau(scan,ms)              "$caption(scan,milliseconde)"
   set panneau(scan,obturateur)      "$caption(scan,obt)"
   set panneau(scan,acq)             "$caption(scan,acquisition)"
   set panneau(scan,go0)             "$caption(scan,goccd)"
   set panneau(scan,stop)            "$caption(scan,stop)"
   set panneau(scan,go1)             "$caption(scan,en_cours)"
   set panneau(scan,go2)             "$caption(scan,visu)"
   set panneau(scan,go)              "$panneau(scan,go0)"
   set panneau(scan,attention)       "$caption(scan,attention)"
   set panneau(scan,msg)             "$caption(scan,message)"
   set panneau(scan,nom)             "$caption(scan,nom)"
   set panneau(scan,extension)       "$caption(scan,extension)"
   set panneau(scan,index)           "$caption(scan,index)"
   set panneau(scan,sauvegarde)      "$caption(scan,sauvegarde)"
   set panneau(scan,pb)              "$caption(scan,pb)"
   set panneau(scan,nom_fichier)     "$caption(scan,nom_fichier)"
   set panneau(scan,nom_blanc)       "$caption(scan,nom_blanc)"
   set panneau(scan,mauvais_car)     "$caption(scan,mauvais_car)"
   set panneau(scan,saisir_indice)   "$caption(scan,saisir_indice)"
   set panneau(scan,indice_entier)   "$caption(scan,indice_entier)"
   set panneau(scan,confirmation)    "$caption(scan,confirmation)"
   set panneau(scan,fichier_existe)  "$caption(scan,fichier_existe)"

   #--- Initialisation des variables
   set panneau(scan,listBinningX)    [ list "" ]
   set panneau(scan,listBinningY)    [ list "" ]
   set panneau(scan,nom_image)       ""
   set panneau(scan,extension_image) "$conf(extension,defaut)"
   set panneau(scan,indexer)         "0"
   set panneau(scan,indice)          "1"
   set panneau(scan,acquisition)     "0"
   set panneau(Scan,Stop)            "0"

   #--- Construction de l'interface
   scanBuildIF $This
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
proc ::scan::chargerVar { } {
   variable parametres

   #--- Ouverture du fichier de parametres
   set fichier [ file join $::audace(rep_home) scan.ini ]
   if { [ file exists $fichier ] } {
      source $fichier
   }

   #--- Creation des variables si elles n'existent pas
   if { ! [ info exists parametres(scan,col1) ] }     { set parametres(scan,col1)     "1" }
   if { ! [ info exists parametres(scan,col2) ] }     { set parametres(scan,col2)     "768" }
   if { ! [ info exists parametres(scan,lig1) ] }     { set parametres(scan,lig1)     "1500" }
   if { ! [ info exists parametres(scan,dimpix) ] }   { set parametres(scan,dimpix)   "9.0" }
   if { ! [ info exists parametres(scan,binningX) ] } { set parametres(scan,binningX) "2" }
   if { ! [ info exists parametres(scan,binningY) ] } { set parametres(scan,binningY) "2" }
   if { ! [ info exists parametres(scan,foc) ] }      { set parametres(scan,foc)      ".85" }
   if { ! [ info exists parametres(scan,dec) ] }      { set parametres(scan,dec)      "0d" }
   if { ! [ info exists parametres(scan,obt) ] }      { set parametres(scan,obt)      "2" }

   #--- Creation des variables si elles sont vides
   if { $parametres(scan,col1) == "" }     { set parametres(scan,col1)     "1" }
   if { $parametres(scan,col2) == "" }     { set parametres(scan,col2)     "768" }
   if { $parametres(scan,lig1) == "" }     { set parametres(scan,lig1)     "1500" }
   if { $parametres(scan,dimpix) == "" }   { set parametres(scan,dimpix)   "9.0" }
   if { $parametres(scan,binningX) == "" } { set parametres(scan,binningX) "2" }
   if { $parametres(scan,binningY) == "" } { set parametres(scan,binningY) "2" }
   if { $parametres(scan,foc) == "" }      { set parametres(scan,foc)      ".85" }
   if { $parametres(scan,dec) == "" }      { set parametres(scan,dec)      "0d" }
   if { $parametres(scan,obt) == "" }      { set parametres(scan,obt)      "2" }

   #--- Creation des variables de la boite de configuration si elles n'existent pas
   ::scanSetup::initToConf
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
proc ::scan::enregistrerVar { } {
   variable parametres
   global panneau

   #--- Changement de variables
   set parametres(scan,col1)     $panneau(scan,col1)
   set parametres(scan,col2)     $panneau(scan,col2)
   set parametres(scan,lig1)     $panneau(scan,lig1)
   set parametres(scan,dimpix)   $panneau(scan,pix)
   set parametres(scan,binningX) $panneau(scan,binningX)
   set parametres(scan,binningY) $panneau(scan,binningY)
   set parametres(scan,foc)      $panneau(scan,foc)
   set parametres(scan,dec)      $panneau(scan,dec)
   set parametres(scan,obt)      $panneau(scan,obt)

   #--- Sauvegarde des parametres
   catch {
      set nom_fichier [ file join $::audace(rep_home) scan.ini ]
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
proc ::scan::initExtension { { a "" } { b "" } { c "" } } {
   global conf panneau

   #--- Mise a jour de l'extension par defaut
   set panneau(scan,extension_image) $conf(extension,defaut)
}

#------------------------------------------------------------
# adaptOutilScan
#    Adapte l'interface graphique a la configuration de la camera
#
# Parametres :
#    args : Valeurs fournies par le gestionnaire de listener
# Return :
#    Rien
#------------------------------------------------------------
proc ::scan::adaptOutilScan { args } {
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
            set panneau(scan,obt) "0"
         } elseif { $conf(audine,foncobtu) == "1" } {
            set panneau(scan,obt) "1"
         } elseif { $conf(audine,foncobtu) == "2" } {
            set panneau(scan,obt) "2"
         }
      }
      pack $This.fra4.obt.but -side left -ipady 3
      pack $This.fra4.obt.lab1 -side left -fill x -expand true -ipady 3
      pack forget $This.fra4.obt.lab2
      $This.fra4.obt.lab1 configure -text $panneau(scan,obt,$panneau(scan,obt))
   } else {
      pack forget $This.fra4.obt.but
      pack forget $This.fra4.obt.lab1
      pack $This.fra4.obt.lab2 -side top -fill x -ipady 3
   }

   #--- Mise a jour du binning X en fonction de la liaison
   set panneau(scan,listBinningX) [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] binningXListScan ]
   if { $panneau(scan,listBinningX) == "{}" } {
      $This.fra3.bin.binX configure -height 1
      $This.fra3.bin.binX configure -values "1"
   } else {
      set height [ llength $panneau(scan,listBinningX) ]
      if { $height > "16" } {
         set height "16"
      }
      $This.fra3.bin.binX configure -height $height
      $This.fra3.bin.binX configure -values $panneau(scan,listBinningX)
   }

   #--- Mise a jour du binning Y en fonction de la liaison
   set panneau(scan,listBinningY) [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] binningYListScan ]
   if { $panneau(scan,listBinningY) == "{}" } {
      $This.fra3.bin.binY configure -height 1
      $This.fra3.bin.binY configure -values "1"
   } else {
      set height [ llength $panneau(scan,listBinningY) ]
      if { $height > "16" } {
         set height "16"
      }
      $This.fra3.bin.binY configure -height $height
      $This.fra3.bin.binY configure -values $panneau(scan,listBinningY)
   }

   #--- Binnings associes aux liaisons
   switch [ ::confLink::getLinkNamespace $conf(audine,port) ] {
      ethernaude {
         #--- Adaptation des binnings extremes
         if { $panneau(scan,binningX) > "2" } {
            set panneau(scan,binningX) "1"
         }
         #--- Etat des boutons
         $This.fra3.but1 configure -state normal
         $This.fra3.fra3.but2 configure -state normal
      }
      parallelport {
         #--- Adaptation des binnings extremes
         if { $panneau(scan,binningY) > "16" } {
            set panneau(scan,binningY) "1"
         }
         #--- Etat des boutons
         $This.fra3.but1 configure -state normal
         $This.fra3.fra3.but2 configure -state normal
      }
      default {
         #--- Etat des boutons
         $This.fra3.but1 configure -state disabled
         $This.fra3.fra3.but2 configure -state disabled
      }
   }
}

#------------------------------------------------------------
# updateCellDim
#    Mise a jour de la dimension des photosites du CCD
#
# Parametres :
#    args : Valeurs fournies par le gestionnaire de listener
# Return :
#    Rien
#------------------------------------------------------------
proc ::scan::updateCellDim { args } {
   variable parametres
   global audace panneau

   #--- Mise a jour de la dimension du photosite
   if { [ ::cam::list ] != "" } {
      set panneau(scan,pix) "[ expr [ lindex [ cam$audace(camNo) celldim ] 0 ] * 1e006]"
   } else {
      set panneau(scan,pix) "$parametres(scan,dimpix)"
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
proc ::scan::startTool { visuNo } {
   variable This
   variable parametres
   global caption panneau

   #--- On cree la variable de configuration des mots cles
   if { ! [ info exists ::conf(scan,keywordConfigName) ] } { set ::conf(scan,keywordConfigName) "default" }

   #--- Chargement de la configuration
   chargerVar

   #--- Initialisation des variables de l'outil
   set panneau(scan,col1)     "$parametres(scan,col1)"
   set panneau(scan,col2)     "$parametres(scan,col2)"
   set panneau(scan,lig1)     "$parametres(scan,lig1)"
   set panneau(scan,pix)      "$parametres(scan,dimpix)"
   set panneau(scan,binningX) "$parametres(scan,binningX)"
   set panneau(scan,binningY) "$parametres(scan,binningY)"
   set panneau(scan,foc)      "$parametres(scan,foc)"
   set panneau(scan,dec)      "$parametres(scan,dec)"
   set panneau(scan,obt)      "$parametres(scan,obt)"

   #--- Initialisation des variables de la boite de configuration
   ::scanSetup::confToWidget

   #--- Entrer ici les valeurs pour l'obturateur a afficher dans le menu "obt"
   set panneau(scan,obt,0) "$caption(scan,obtu_ouvert)"
   set panneau(scan,obt,1) "$caption(scan,obtu_ferme)"
   set panneau(scan,obt,2) "$caption(scan,obtu_synchro)"

   #--- Calcul de dt en fonction des parametres initialises
   cmdCalcul

   #--- Configuration dynamique de l'outil en fonction de la liaison
   adaptOutilScan

   #--- Mise a jour de la dimension du pixel a la connexion d'une camera
   updateCellDim

   #--- Je selectionne les mots cles selon les exigences de l'outil
   ::scan::configToolKeywords $visuNo

   #--- Mise en service de la surveillance de la connexion d'une camera
   ::confVisu::addCameraListener $visuNo ::scan::adaptOutilScan
   ::confVisu::addCameraListener $visuNo ::scan::updateCellDim
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
proc ::scan::stopTool { visuNo } {
   variable This
   global panneau

   #--- Je verifie si une operation est en cours
   if { $panneau(scan,acquisition) == 1 } {
      return -1
   }

   #--- Sauvegarde de la configuration
   enregistrerVar

   #--- Je supprime la liste des mots clefs non modifiables
   ::keyword::setKeywordState $visuNo $::conf(scan,keywordConfigName) [ list ]

   #--- Arret de la surveillance de la connexion d'une camera
   ::confVisu::removeCameraListener $visuNo ::scan::adaptOutilScan
   ::confVisu::removeCameraListener $visuNo ::scan::updateCellDim
}

#------------------------------------------------------------
# getNameKeywords
#    definit le nom de la configuration des mots cles FITS de l'outil
#    uniquement pour les outils qui configurent les mots cles selon des
#    exigences propres a eux
#------------------------------------------------------------
proc ::scan::getNameKeywords { visuNo configName } {
   #--- Je definis le nom
   set ::conf(scan,keywordConfigName) $configName
}

#------------------------------------------------------------
# configToolKeywords
#    configure les mots cles FITS de l'outil
#------------------------------------------------------------
proc ::scan::configToolKeywords { visuNo { configName "" } } {
   #--- Je traite la variable configName
   if { $configName == "" } {
      set configName $::conf(scan,keywordConfigName)
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
proc ::scan::int { value } {
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
#    Lancement d'une acquisition de drift scan avec controle du moteur de suivi
#
# Parametres :
#    motor : Etat du moteur, motoron ou motoroff (optionnel)
# Return :
#    Rien
#------------------------------------------------------------
proc ::scan::cmdGo { { motor motoron } } {
   variable This
   variable parametres
   global audace conf panneau

   if { [ ::cam::list ] != "" } {
      if { [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] hasScan ] == "1" } {
         #--- Initialisation des variables
         set panneau(scan,acquisition) "1"
         set panneau(Scan,Stop)        "0"

         #--- Les champs "Colonnes" et "Lignes" ne doivent pas etre vides
         if { $panneau(scan,col1) == "" } {
            set panneau(scan,col1) $parametres(scan,col1)
         }
         if { $panneau(scan,col2) == "" } {
            set panneau(scan,col2) $parametres(scan,col2)
         }
         if { $panneau(scan,lig1) == "" } {
            set panneau(scan,lig1) $parametres(scan,lig1)
         }

         #--- Le nombre de ligne du scan doit etre superieur ou egal a 2
         if { $panneau(scan,lig1) < "0" } {
            set panneau(scan,lig1) [ expr abs($panneau(scan,lig1)) ]
         }
         if { $panneau(scan,lig1) < "2" } {
            set panneau(scan,lig1) "2"
         }

         #--- La premiere colonne (firstpix) doit etre superieure ou egale a 1
         if { $panneau(scan,col1) < "0" } {
            set panneau(scan,col1) [ expr abs($panneau(scan,col1)) ]
         }
         if { $panneau(scan,col1) < "1" } {
            set panneau(scan,col1) "1"
         }

         #--- La seconde colonne doit etre superieure ou egale a 2
         if { $panneau(scan,col2) < "0" } {
            set panneau(scan,col2) [ expr abs($panneau(scan,col2)) ]
         }
         if { $panneau(scan,col2) < "2" } {
            set panneau(scan,col2) "2"
         }

         #--- La seconde colonne doit etre superieure a la premiere colonne
         if { $panneau(scan,col2) < $panneau(scan,col1) } {
            set colonne            "$panneau(scan,col2)"
            set panneau(scan,col2) "$panneau(scan,col1)"
            set panneau(scan,col1) "$colonne"
         }

         #--- Calcul de la colonne maxi du CCD
         set colonneMaxi "[ lindex [ cam$audace(camNo) nbcells ] 0 ]"

         #--- La premiere colonne doit etre inferieure a la largeur du CCD
         if { $panneau(scan,col1) > "$colonneMaxi" } {
            set panneau(scan,col1) "1"
         }

         #--- La seconde colonne doit etre inferieure a la largeur du CCD
         if { $panneau(scan,col2) > "$colonneMaxi" } {
            set panneau(scan,col2) "$colonneMaxi"
         }

         #--- Gestion graphique du bouton GO CCD
         $This.fra4.but1 configure -relief groove -text $panneau(scan,go1) -state disabled

         #--- Gestion graphique du bouton STOP - Inactif avant le debut du scan
         $This.fra4.but2 configure -relief groove -text $panneau(scan,stop) -state disabled
         update

         #--- Definition du binning
         switch [ ::confLink::getLinkNamespace $conf(audine,port) ] {
            ethernaude {
               set bin  "$panneau(scan,binningX)"
               set binY "$panneau(scan,binningY)"
            }
            parallelport {
               set bin  "$panneau(scan,binningX)"
               set binY "$panneau(scan,binningY)"
            }
            default {
               set bin  "1"
               set binY "1"
            }
         }

         #--- Definition des parametres du scan (w : largeur - h : hauteur - f : firstpix)
         set w [ int [ expr $panneau(scan,col2) - $panneau(scan,col1) + 1 ] ]
         set h [ int $panneau(scan,lig1) ]
         set f [ int $panneau(scan,col1) ]

         #--- Gestion du moteur d'A.D.
         if { $motor == "motoroff" } {
            if { [ ::tel::list ] != "" } {
               #--- Arret du moteur d'AD
               tel$audace(telNo) radec motor off
            }
         }

         #--- Attente du demarrage du scan
         if { $panneau(scan,active) == "1" } {
            #--- Decompte du temps d'attente
            set attente $panneau(scan,delai)
            if { $panneau(scan,delai) > "0" } {
               while { $panneau(scan,delai) > "0" } {
                  ::camera::avancementScan "-10" $panneau(scan,lig1) $panneau(scan,delai)
                  update
                  after 1000
                  incr panneau(scan,delai) "-1"
               }
            }
            set panneau(scan,delai) $attente
         }

         #--- Gestion graphique du bouton STOP - Devient actif avec le debut du scan
         $This.fra4.but2 configure -relief raised -text $panneau(scan,stop) -state normal
         update

         #--- Changement de variable
         set dt $panneau(scan,interlig1)

         #--- Appel a la fonction d'acquisition
         scan $w $h $bin $binY $dt $f

         #--- Rajoute des mots cles dans l'en-tete FITS
         foreach keyword [ ::keyword::getKeywords $audace(visuNo) $::conf(scan,keywordConfigName) ] {
            buf$audace(bufNo) setkwd $keyword
         }

         #--- Rajoute la date de debut et de fin de pose en jour julien dans l'en-tete FITS
         ::keyword::addJDayOBSandEND

         #--- Mise a jour du nom du fichier dans le titre et de la fenetre de l'en-tete FITS
         ::confVisu::setFileName $audace(visuNo) ""

         #--- Gestion graphique du bouton GO CCD
         $This.fra4.but1 configure -relief groove -text $panneau(scan,go2) -state disabled
         update

         #--- Visualisation de l'image
         ::audace::autovisu $audace(visuNo)

         #--- Gestion du moteur d'A.D.
         if { $motor == "motoroff" } {
            if { [ ::tel::list ] != "" } {
               #--- Remise en marche du moteur d'AD
               tel$audace(telNo) radec motor on
            }
         }

         #--- Gestion graphique du bouton GO CCD
         set panneau(scan,acquisition) "0"
         $This.fra4.but1 configure -relief raised -text $panneau(scan,go0) -state normal
         update
      } else {
         tk_messageBox -title $panneau(scan,attention) -type ok -message $panneau(scan,msg)
      }
   } else {
      ::confCam::run
   }
}

#------------------------------------------------------------
# scan
#    Acquisition d'un drift scan
#
# Parametres :
#    w    : Largeur du scan
#    h    : Hauteur du scan
#    bin  : Binning sur l'axe des x
#    binY : Binning sur l'axe des y
#    dt   : Interligne
#    f    : Pixel definissant la colonne de debut de scan
# Return :
#    Rien
#------------------------------------------------------------
proc ::scan::scan { w h bin binY dt f } {
   global audace panneau

   #--- Calcul du nombre de lignes par seconde
   set panneau(scan,nblg1) [ expr 1000./$dt ]

   #--- Declenchement de l'acquisition
   if { $f == "0" } {
      cam$audace(camNo) scan $w $h $bin $dt -biny $binY
   } else {
      cam$audace(camNo) scan $w $h $bin $dt -biny $binY -firstpix $f
   }

   #--- Alarme sonore de fin de pose
   set pseudoexptime [ expr $panneau(scan,lig1) / $panneau(scan,nblg1) ]
   ::camera::alarmeSonore $pseudoexptime

   #--- Appel du timer
   if { $panneau(scan,lig1) > "$panneau(scan,nblg1)" } {
      set t [ expr $panneau(scan,lig1) / $panneau(scan,nblg1) ]
      ::camera::dispLine $t $panneau(scan,nblg1) $panneau(scan,lig1) $panneau(scan,delai)
   }

   #--- Attente de la fin de la pose
   vwait scan_result$audace(camNo)

   #--- Destruction de la fenetre d'avancement du scan
   set panneau(Scan,Stop) "1"
   if [ winfo exists $audace(base).progress_scan ] {
      destroy $audace(base).progress_scan
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
proc ::scan::cmdStop { } {
   variable This
   global audace panneau

   if { [ ::cam::list ] != "" } {
      if { $panneau(scan,acquisition) == "1" } {
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
            $This.fra4.but1 configure -relief raised -text $panneau(scan,go1) -state disabled
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
proc ::scan::cmdCalcul { } {
   variable This
   variable parametres
   global conf panneau

   #--- Le champ "Pixel" ne doit pas etre vide
   if { $panneau(scan,pix) == "" } {
      updateCellDim
   }

   #--- Le champ "Focale" ne doit pas etre vide
   if { $panneau(scan,foc) == "" } {
      set panneau(scan,foc) "$parametres(scan,foc)"
   }

   #--- Le champ "Dec." ne doit pas etre vide
   if { $panneau(scan,dec) == "" } {
      cmdDec
   }

   #--- Calcul de dt
   switch [ ::confLink::getLinkNamespace $conf(audine,port) ] {
      ethernaude {
         set bin  "$panneau(scan,binningX)"
         set binY "$panneau(scan,binningY)"
      }
      parallelport {
         set bin  "$panneau(scan,binningX)"
         set binY "$panneau(scan,binningY)"
      }
      default {
         set bin  "1"
         set binY "1"
      }
   }
   set panneau(scan,interlig1) [ expr $binY*86164*2*atan($panneau(scan,pix)/2./($panneau(scan,foc)*1e6))/360.*180/3.1415926*1000./cos( [ mc_angle2rad $panneau(scan,dec) ] ) ]
   $This.fra3.fra1.ent1 configure -textvariable panneau(scan,interlig1)
   update
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
proc ::scan::infoCam { } {
   variable This
   variable parametres
   global audace panneau

   if { [ ::cam::list ] != "" } {
      set parametres(scan,col2)   "[ lindex [ cam$audace(camNo) nbcells ] 0 ]"
      set parametres(scan,dimpix) "[ expr [ lindex [ cam$audace(camNo) celldim ] 0 ] * 1e006]"
      set panneau(scan,col2)      "$parametres(scan,col2)"
      set panneau(scan,pix)       "$parametres(scan,dimpix)"
      $This.fra2.fra1.ent2 configure -textvariable panneau(scan,col2)
      $This.fra2.fra3.ent1 configure -textvariable panneau(scan,pix)
      update
   }

   #--- Calcul de dt en fonction du changement de parametres
   cmdCalcul
}

#------------------------------------------------------------
# cmdDec
#    Capture la declinaison et relance le calcul de l'interligne
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::scan::cmdDec { } {
   variable This
   variable parametres
   global audace panneau

   #--- Initialisation et/ou determination de la position de la declinaison
   if { [ ::confTel::isReady ] == "1" } {
      if { [ ::confTel::getPluginProperty hasCoordinates ] == "1" } {
         set panneau(scan,dec) "$audace(telescope,getdec)"
      } else {
         set panneau(scan,dec) "$parametres(scan,dec)"
      }
   } else {
      set panneau(scan,dec) "$parametres(scan,dec)"
   }

   #--- Affiche la declinaison
   $This.fra3.fra3.ent2 configure -textvariable panneau(scan,dec)
   update

   #--- Calcul de dt en fonction de la declinaison
   cmdCalcul
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
proc ::scan::changeObt { } {
   variable This
   global panneau

   if { [ ::cam::list ] != "" } {
      set camItem [ ::confVisu::getCamItem 1 ]
      set result [::confCam::setShutter $camItem $panneau(scan,obt)]
      if { $result != -1 } {
         set panneau(scan,obt) $result
         $This.fra4.obt.lab1 configure -text $panneau(scan,obt,$panneau(scan,obt))
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
proc ::scan::sauveUneImage { } {
   global audace conf panneau

   #--- Enregistrer l'extension des fichiers
   set ext $conf(extension,defaut)

   #--- Tests d'integrite de la requete

   #--- Verifier qu'il y a bien un nom de fichier
   if { $panneau(scan,nom_image) == "" } {
      tk_messageBox -title $panneau(scan,pb) -type ok \
         -message $panneau(scan,nom_fichier)
      return
   }

   #--- Verifier que le nom de fichier n'a pas d'espace
   if { [ llength $panneau(scan,nom_image) ] > "1" } {
      tk_messageBox -title $panneau(scan,pb) -type ok \
         -message $panneau(scan,nom_blanc)
      return
   }

   #--- Si la case index est cochee, verifier qu'il y a bien un index
   if { $panneau(scan,indexer) == "1" } {
      #--- Verifier que l'index existe
      if { $panneau(scan,indice) == "" } {
         tk_messageBox -title $panneau(scan,pb) -type ok \
            -message $panneau(scan,saisir_indice)
         return
      }
   }

   #--- Generer le nom du fichier
   set nom $panneau(scan,nom_image)

   #--- Pour eviter un nom de fichier qui commence par un blanc
   set nom [ lindex $nom 0 ]
   if { $panneau(scan,indexer) == "1" } {
      append nom $panneau(scan,indice)
   }

   #--- Verifier que le nom du fichier n'existe pas deja
   set nom1 "$nom"
   append nom1 $ext
   if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
      #--- Dans ce cas, le fichier existe deja
      set confirmation [ tk_messageBox -title $panneau(scan,confirmation) -type yesno \
         -message $panneau(scan,fichier_existe) ]
      if { $confirmation == "no" } {
         return
      }
   }

   #--- Incrementer l'index
   if { $panneau(scan,indexer) == "1" } {
      if { [ buf$audace(bufNo) imageready ] != "0" } {
         incr panneau(scan,indice)
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
# scanBuildIF
#    Interface graphique
#
# Parametres :
#    This : Widget parent
# Return :
#    Rien
#------------------------------------------------------------
proc scanBuildIF { This } {
   global audace panneau

   #--- Frame de l'outil
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra0 -borderwidth 2 -relief groove

         #--- Bouton du titre
         Button $This.fra0.but -borderwidth 1 \
            -text "$panneau(scan,aide1)\n$panneau(scan,titre)" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::scan::getPluginType ] ] \
               [ ::scan::getPluginDirectory ] [ ::scan::getPluginHelp ]"
         pack $This.fra0.but -in $This.fra0 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra0.but -text $panneau(scan,aide)

      pack $This.fra0 -side top -fill x

      #--- Frame du bouton de configuration
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du bouton Configuration
         button $This.fra1.but -borderwidth 1 -text $panneau(scan,configuration) \
            -command { ::scanSetup::run $audace(base).scanSetup }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5

      pack $This.fra1 -side top -fill x

      #--- Frame des colonnes, des lignes et de la dimension des pixels
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label pour colonnes
         label $This.fra2.lab1 -text $panneau(scan,col) -relief flat
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -fill none -padx 4 -pady 1

         #--- Frame des 2 entries de colonnes
         frame $This.fra2.fra1 -borderwidth 1 -relief flat

            #--- Entry pour la colonne de debut
            entry $This.fra2.fra1.ent1 -textvariable panneau(scan,col1) \
               -relief groove -width 5 -justify center
            pack $This.fra2.fra1.ent1 -in $This.fra2.fra1 -side left -fill none -padx 4 -pady 1

            #--- Entry pour la colonne de fin
            entry $This.fra2.fra1.ent2 -textvariable panneau(scan,col2) \
               -relief groove -width 5 -justify center
            pack $This.fra2.fra1.ent2 -in $This.fra2.fra1 -side right -fill none -padx 4 -pady 1

         pack $This.fra2.fra1 -in $This.fra2 -anchor center -fill none

         #--- Frame pour lignes
         frame $This.fra2.fra2 -borderwidth 1 -relief flat

            #--- Label pour lignes
            label $This.fra2.fra2.lab2 -text $panneau(scan,lig) -relief flat
            pack $This.fra2.fra2.lab2 -in $This.fra2.fra2 -side left -fill none -padx 2 -pady 1

            #--- Entry pour lignes
            entry $This.fra2.fra2.ent1 -textvariable panneau(scan,lig1) \
               -relief groove -width 7 -justify center
            pack $This.fra2.fra2.ent1 -in $This.fra2.fra2 -side right -fill none -padx 2 -pady 1

         pack $This.fra2.fra2 -in $This.fra2 -anchor center -fill none

         #--- Frame pour la dimension des pixels
         frame $This.fra2.fra3 -borderwidth 1 -relief flat

            #--- Label pour la dimension des pixels
            label $This.fra2.fra3.lab3 -text $panneau(scan,pixel) -relief flat
            pack $This.fra2.fra3.lab3 -in $This.fra2.fra3 -side left -fill none -padx 2 -pady 1

            #--- Entry pour la dimension des pixels
            entry $This.fra2.fra3.ent1 -textvariable panneau(scan,pix) \
               -relief groove -width 4 -justify center
            pack $This.fra2.fra3.ent1 -in $This.fra2.fra3 -side left -fill none -padx 2 -pady 1

            #--- Label pour l'unite de la dimension des pixels
            label $This.fra2.fra3.lab4 -text $panneau(scan,unite) -relief flat
            pack $This.fra2.fra3.lab4 -in $This.fra2.fra3 -side right -fill none -padx 2 -pady 1

         pack $This.fra2.fra3 -in $This.fra2 -anchor center -fill none

      pack $This.fra2 -side top -fill x

      #--- Binding sur la zone des infos de la camera
      set zone(camera) $This.fra2
      bind $zone(camera) <ButtonPress-1>           { ::scan::infoCam }
      bind $zone(camera).lab1 <ButtonPress-1>      { ::scan::infoCam }
      bind $zone(camera).fra2.lab2 <ButtonPress-1> { ::scan::infoCam }
      bind $zone(camera).fra3.lab3 <ButtonPress-1> { ::scan::infoCam }
      bind $zone(camera).fra3.lab4 <ButtonPress-1> { ::scan::infoCam }

      #--- Frame de l'interligne
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Label pour interligne
         label $This.fra3.lab1 -text $panneau(scan,interlig) -relief flat
         pack $This.fra3.lab1 -in $This.fra3 -anchor center -fill none

         #--- Frame pour binning (seulement port parallele et EthernAude)
         frame $This.fra3.bin -borderwidth 0 -relief groove

            #--- Label pour binning X
            label $This.fra3.bin.lab1 -text $panneau(scan,bin) -relief flat
            pack $This.fra3.bin.lab1 -in $This.fra3.bin -side left -fill none

            #--- Combobox pour binning X
            ComboBox $This.fra3.bin.binX \
               -width 3        \
               -justify center \
               -height [ llength $panneau(scan,listBinningX) ] \
               -relief sunken  \
               -borderwidth 1  \
               -editable 0     \
               -textvariable panneau(scan,binningX) \
               -values $panneau(scan,listBinningX) \
               -modifycmd "::scan::cmdCalcul"
            pack $This.fra3.bin.binX -in $This.fra3.bin -side left -fill none

            #--- Label pour binning Y
            label $This.fra3.bin.lab2 -text "x" -relief flat
            pack $This.fra3.bin.lab2 -in $This.fra3.bin -side left -fill none

            #--- Combobox pour binning Y
            ComboBox $This.fra3.bin.binY \
               -width 3        \
               -justify center \
               -height [ llength $panneau(scan,listBinningY) ] \
               -relief sunken  \
               -borderwidth 1  \
               -editable 0     \
               -textvariable panneau(scan,binningY) \
               -values $panneau(scan,listBinningY) \
               -modifycmd "::scan::cmdCalcul"
            pack $This.fra3.bin.binY -in $This.fra3.bin -side left -fill none

         pack $This.fra3.bin -in $This.fra3 -anchor n -fill x -expand 0 -pady 2

         #--- Frame des entry & labels de la focale
         frame $This.fra3.fra2 -borderwidth 1 -relief flat

            #--- Label pour la focale
            label $This.fra3.fra2.lab1 -text $panneau(scan,focale) -relief flat
            pack $This.fra3.fra2.lab1 -in $This.fra3.fra2 -side left -fill none -padx 1 -pady 2

            #--- Entry pour la focale
            entry $This.fra3.fra2.ent1 -textvariable panneau(scan,foc) \
               -relief groove -width 5 -justify center
            pack $This.fra3.fra2.ent1 -in $This.fra3.fra2 -side left -fill none -padx 1 -pady 2

            #--- Label pour l'unite de la focale
            label $This.fra3.fra2.lab2 -text $panneau(scan,metres) -relief flat
            pack $This.fra3.fra2.lab2 -in $This.fra3.fra2 -side left -fill none -padx 1 -pady 2

         pack $This.fra3.fra2 -in $This.fra3 -anchor center -fill none

         #--- Frame des bouton & entry de la declinaison
         frame $This.fra3.fra3 -borderwidth 1 -relief flat

            #--- Bouton pour la mise a jour de la dec
            button $This.fra3.fra3.but2 -borderwidth 2 -text $panneau(scan,declinaison) \
               -width 3 -command "::scan::cmdDec"
            pack $This.fra3.fra3.but2 -in $This.fra3.fra3 -side left -fill none -pady 1

            #--- Entry pour la dec
            entry $This.fra3.fra3.ent2 -textvariable panneau(scan,dec) -relief groove -width 10
            pack $This.fra3.fra3.ent2 -in $This.fra3.fra3 -side right -fill none -pady 1

         pack $This.fra3.fra3 -in $This.fra3 -anchor center -fill none

         #--- Bouton de calcul
         button $This.fra3.but1 -borderwidth 2 -text $panneau(scan,calcul) \
            -command "::scan::cmdCalcul"
         pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 1 -ipadx 13

         #--- Frame des entry & label
         frame $This.fra3.fra1 -borderwidth 1 -relief flat

            #--- Entry pour les millisecondes
            entry $This.fra3.fra1.ent1 -width 7 -relief groove \
              -textvariable panneau(scan,interlig1) -state disabled
            pack $This.fra3.fra1.ent1 -in $This.fra3.fra1 -side left -fill none -padx 1 -pady 2

            #--- Label pour l'unite
            label $This.fra3.fra1.ent2 -text $panneau(scan,ms) -relief flat
            pack $This.fra3.fra1.ent2 -in $This.fra3.fra1 -side left -fill none -padx 1 -pady 2

         pack $This.fra3.fra1 -in $This.fra3 -anchor center -fill none

      pack $This.fra3 -side top -fill x

      #--- Frame de l'acquisition
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Frame de l'obturateur
         frame $This.fra4.obt -borderwidth 2 -relief ridge -width 16

            #--- Bouton de changement d'etat de l'obturateur
            button $This.fra4.obt.but -text $panneau(scan,obturateur) -command "::scan::changeObt" \
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
         label $This.fra4.lab1 -text $panneau(scan,acq) -relief flat
         pack $This.fra4.lab1 -in $This.fra4 -anchor center -fill none -padx 4 -pady 1

         #--- Bouton GO
         button $This.fra4.but1 -borderwidth 2 -text $panneau(scan,go) \
            -command "::scan::cmdGo motoroff"
         pack $This.fra4.but1 -in $This.fra4 -anchor center -fill x -padx 5 -ipadx 10 -ipady 3

         #--- Bouton STOP
         button $This.fra4.but2 -borderwidth 2 -text $panneau(scan,stop) \
            -command "::scan::cmdStop"
         pack $This.fra4.but2 -in $This.fra4 -anchor center -fill x -padx 5 -pady 5 -ipadx 15 -ipady 3

      pack $This.fra4 -side top -fill x

      #--- Frame de la sauvegarde de l'image
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Frame du nom de l'image
         frame $This.fra5.nom -relief ridge -borderwidth 2

            #--- Label du nom de l'image
            label $This.fra5.nom.lab1 -text $panneau(scan,nom) -pady 0
            pack $This.fra5.nom.lab1 -fill x -side top

            #--- Entry du nom de l'image
            entry $This.fra5.nom.ent1 -width 10 -textvariable panneau(scan,nom_image) -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $This.fra5.nom.ent1 -fill x -side top

            #--- Label de l'extension
            label $This.fra5.nom.lab_extension -text $panneau(scan,extension) -pady 0
            pack $This.fra5.nom.lab_extension -fill x -side left

            #--- Button pour le choix de l'extension
            button $This.fra5.nom.extension -textvariable panneau(scan,extension_image) \
               -width 7 -command "::confFichierIma::run $audace(base).confFichierIma"
            pack $This.fra5.nom.extension -side right -fill x

         pack $This.fra5.nom -side top -fill x

         #--- Frame de l'index
         frame $This.fra5.index -relief ridge -borderwidth 2

            #--- Checkbutton pour le choix de l'indexation
            checkbutton $This.fra5.index.case -pady 0 -text $panneau(scan,index) -variable panneau(scan,indexer)
            pack $This.fra5.index.case -side top -fill x

            #--- Entry de l'index
            entry $This.fra5.index.ent2 -width 3 -textvariable panneau(scan,indice) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $This.fra5.index.ent2 -side left -fill x -expand true

            #--- Bouton de mise a 1 de l'index
            button $This.fra5.index.but1 -text "1" -width 3 -command "set panneau(scan,indice) 1"
            pack $This.fra5.index.but1 -side right -fill x

         pack $This.fra5.index -side top -fill x

         #--- Bouton pour sauvegarder l'image
         button $This.fra5.but_sauve -text $panneau(scan,sauvegarde) -command "::scan::sauveUneImage"
         pack $This.fra5.but_sauve -side top -fill x

      pack $This.fra5 -side top -fill x

   bind $This.fra4.but1 <ButtonPress-3> { ::scan::cmdGo motoron }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

