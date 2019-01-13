#
## @file acquisition.tcl
#  @brief acquisition eShel
#  @author Michel PUJOL
#  $Id: acquisition.tcl 13602 2016-04-04 12:38:40Z rzachantke $
#

## namespace eshel::acquisition
#  @brief acquisition eShel

namespace eval ::eshel::acquisition {
   variable private

   set private(currentSeriesId) ""
}

proc ::eshel::acquisition::validateFitsData { value valueLabel } {
   if { [string length $value] > 70 } {
      error "$valueLabel is too large (must be < 70 C"
   }

}

#------------------------------------------------------------
## @brief lance une séquence d'acquisition
#  @code
#  Exemple 1 :
#  ::eshel::acquisition::startSequence 1 [list [list ledSerie [list expNb 3 expTime 10]] [list wait [list expTime 12]] [list tharSerie [list expNb 4 expTime 60]]] "reference debut"
#  - une serie de 3 flats de 10 secondes
#  - une attente de 12 secondes
#  - une serie de 4 thar de 60 secondes
#  Exemple 2:
#  ::eshel::acquisition::startSequence 1 [list [list objectSerie [list objectName vega binning 1x1 expNb 3 expTime 60]] ]  "vega"
#       -  une serie de 5 images de vega de 60 secondes, binning 1x1
#  @endcode
#  @param visuNo numéro de la visu
#  @param actionList liste des actions d'acquisitions à faire. C'est une liste de couples de valeurs :
#          -  actionType  : type de l'action
#              types d'action connus:  objectSerie, darkSerie, flatfieldSerie,ledSerie, tharSerie, tungstenSerie, biasSerie, wait
#          - actionParams : paramètres de l'action
#              expTime     (defaut= 0 seconde)
#              expNb       (defaut= 1 image)
#              objectName  (defaut= "" )
#              saveFile    (defaut= 1)
#              binning     (defaut= binning de la configuration courante)
#  @param sequenceName nom de la séquence (paramètre optionel, ce libellé est utilisé pour les traces
#  @param sequenceRepeat nombre de répétition de la séquence ( 1 par défaut)
#  @param sequenceComment commentaire de la séquence (paramètre optionel, ce libellé est ajouté dans le mot clé COMMENT1 des images
#  @return une exception en cas d'erreur
#
proc ::eshel::acquisition::startSequence { visuNo actionList { sequenceName "" } { sequenceRepeat 1 } { sequenceComment "" }} {
   variable private

   set private(currentSeriesId)  ""
   set private(currentSeriesId)  ""
   set private($visuNo,updateStatusId) ""
   set private($visuNo,acquisitionState) ""

   #---- je controle les valeurs qui vont etre mises dasn les mots cles

   #::eshel::acquisition::validateFitsData $::conf(eshel,instrument,config,$configId,cameraName) "camera name"
   #::eshel::acquisition::validateFitsData $::conf(eshel,instrument,config,$configId,spectroName) "spectrograph name"
   #::eshel::acquisition::validateFitsData $::conf(eshel,instrument,config,$configId,telescopeName) "telescope name"
   #::eshel::acquisition::validateFitsData $::conf(eshel,instrument,config,$configId,configName) "configuration name"
   #::eshel::acquisition::validateFitsData $::conf(posobs,nom_observateur) "observer name"

   #--- je verifie que la camera est bien selectionnee
   set camItem [::confVisu::getCamItem $visuNo]
   if { $camItem == "" } {
      #--- la camera n'est pas connectee. je la connecte
      ::eshel::instrument::connectCamera $visuNo
      #--- je verifie que la camera est bien connectee
      if { [::confVisu::getCamItem $visuNo] == "" } {
         #--- je transmets l'erreur , mais sans message car le message a deja ete affiche par connectCamera
         return
      } else {
         #--- je recupere le camItem de la camera
         set camItem [::confVisu::getCamItem $visuNo]
      }
   } else {
      #--- une camera est deja connectee
      #--- je verifie que la camera connecte est bien celle requise par la configuration instrument
      set requiredcameraType $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),cameraLabel)
      set connectedCameraType [::confCam::getPluginProperty $camItem "title"]
      if { $requiredcameraType != $connectedCameraType } {
         #--- je retourne une erreur si une camera d'un autre type est deja connectee
         error [format $::caption(eshel,acquisition,changeCamera) $connectedCameraType $requiredcameraType]
      }
   }

   #--- je configure le fenetrage de la camera
   cam[::confCam::getCamNo $camItem] window \
      [list $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),x1) \
            $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),y1) \
            $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),x2) \
            $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),y2) ]

   #--- je verifie que la bonnette est configuree si elle est utilisee
   if { $::conf(eshel,enableGuidingUnit) == 1  } {
      set bonnetteLabel $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),spectrograhLink)
      if { $bonnetteLabel == "" } {
         error $::caption(eshel,acquisition,errorSpectroPort)
      }
      #--- je verifie que la bonnette est connectee
      set bonnetteLinkNo [::confLink::getLinkNo $bonnetteLabel]
      if { $bonnetteLinkNo == "" } {
         #--- la bonnette n'est pas connectee. Je la connecte
         set bonnetteLinkNo [::confLink::create  $bonnetteLabel "eshel" "acquisition" ""]
         if { $bonnetteLinkNo == "" || $bonnetteLinkNo == 0 } {
            error [ format $::caption(eshel,acquisition,errorSpectrograph) $bonnetteLabel]
         }
      }
   }

   #--- je verifie que le repertoire des images brutes existe
   if { [file exists $::conf(eshel,rawDirectory)] == 0 } {
      error [format $::caption(eshel,directoryNotFound) $::conf(eshel,rawDirectory)]
   }

   #--- je position l'indicateur d'etat des actions de l'utilisateur
   set private($visuNo,demande_arret) "0"

   #--- petit raccourci bien utile
   set bufNo     [ ::confVisu::getBufNo $visuNo ]

   #--- Boucle des repetitions de la sequence
   for { set repeatCounter 1 } { $repeatCounter <= $sequenceRepeat && $private($visuNo,demande_arret) == 0 } { incr repeatCounter } {
      logInfo "$sequenceName: $::caption(eshel,acquisition,sequenceBegin) $repeatCounter/$sequenceRepeat\n"
      #--- Boucle des actions de la sequence
      for { set actionIndex 0 } { $actionIndex < [llength $actionList] } {incr actionIndex } {
      ####foreach action $actionList
         set action [lindex $actionList $actionIndex]

         #--- je determine s'il faut laisser le mirroir actif avant l'action suivante
         set keepMirrorEnabled 0
         if {  $actionIndex  < [expr [llength $actionList] -1] } {
            set nextAction [lindex [lindex $actionList [expr $actionIndex +1]] 0]
            if { $nextAction=="ledSerie" || $nextAction=="tharSerie" || $nextAction=="tungstenSerie" } {
               set keepMirrorEnabled 1
            }
         }

         set catchResult [ catch {

            #--- je recupere le type de l'action
            set actionType [lindex $action 0]
            #--- j'initialise les parametres avec des valeurs par defaut
            set actionParams(expTime) 0
            set actionParams(expNb)   1
            set actionParams(objectName)   ""
            set actionParams(saveFile) 1
            set actionParams(binning)  [::eshel::instrument::getConfigurationProperty  "binning" ]
            set actionParams(seriesId) 0

            #--- je recupere les parametres de la sequence (tous les parametres ne sont pas forcement fournis en fonction de l'action)
            array set actionParams [lindex $action 1]

            logInfo "$sequenceName: $actionType $::caption(eshel,acquisition,beginAction) ([lindex $action 1])\n"

            #--- je configure les intruments en fonction du type d'action
            #---- et je prepare le libelle qui sera affiche dans le status
            switch $actionType {
               objectSerie  {
                  set statusLabel $actionParams(objectName)
                  #--- je mets l'obturateur en mode syncho
                  ::confCam::setShutter $camItem 2 "set"
               }
               darkSerie  {
                  set statusLabel "dark"
                  #--- je ferme l'obturateur de la camera
                  ::confCam::setShutter $camItem 1 "set"
               }
               flatfield  {
                  set statusLabel "flatfield"
                  #--- je mets l'obturateur en mode syncho
                  ::confCam::setShutter $camItem 2 "set"
               }
               ledSerie  {
                  set statusLabel "led"
                  #--- je mets l'obturateur en mode syncho
                  ::confCam::setShutter $camItem 2 "set"
                  if { $::conf(eshel,enableGuidingUnit) == 1  } {
                     #--- j'active le miroir
                     ::eshel::instrument::setSpectrographLamp $bonnetteLinkNo "mirror" 1
                     after 600
                     #--- j'allume les lampes LEDs (flat) et Tungsten (Tungsten) en meme temps
                     ::eshel::instrument::setSpectrographLamp $bonnetteLinkNo "led" 1
                     after 600
                     ::eshel::instrument::setSpectrographLamp $bonnetteLinkNo "tungsten" 1
                  }
               }
               tharSerie  {
                  set statusLabel "thar"
                  #--- je mets l'obturateur en mode syncho
                  ::confCam::setShutter $camItem 2 "set"
                  if { $::conf(eshel,enableGuidingUnit) == 1  } {
                     #--- j'active le miroir
                     ::eshel::instrument::setSpectrographLamp $bonnetteLinkNo "mirror" 1
                     #--- j'allume la lampe
                     ::eshel::instrument::setSpectrographLamp $bonnetteLinkNo "thar" 1
                  }
               }
               tungstenSerie  {
                  set statusLabel "tungsten"
                  #--- je mets l'obturateur en mode syncho
                  ::confCam::setShutter $camItem 2 "set"
                  if { $::conf(eshel,enableGuidingUnit) == 1  } {
                     #--- j'active le miroir
                     ::eshel::instrument::setSpectrographLamp $bonnetteLinkNo "mirror" 1
                     #--- j'allume la lampe
                     ::eshel::instrument::setSpectrographLamp $bonnetteLinkNo "tungsten" 1
                  }
               }

               mirrorOFF  {
               # ::eshel::instrument::setSpectrographLamp $bonnetteLinkNo "mirror" 0
               }
               mirrorON  {
               # ::eshel::instrument::setSpectrographLamp $bonnetteLinkNo "mirror" 1
               }

               biasSerie  {
                  set statusLabel "bias"
                  #--- je ferme l'obturateur de la camera
                  ::confCam::setShutter $camItem 1 set
               }
               wait {
                  set statusLabel "wait"
               }
               readOut {
                  set statusLabel "ReadOut"
                  #--- je desactive l'enregsitrement de l'image dans un fichier
                  set actionParams(saveFile) 0
                  #--- je ferme l'obturateur de la camera
                  ::confCam::setShutter $camItem 1 set
               }
               default {
                  error "unknown action type: $actionType in action : $action\n"
               }
            } ;#--- fin du switch
         }] ;#--- fin du catch

         if { $catchResult != 0 } {
            logError "$::errorInfo\n"
            #--- je sors de la boucle si on a rencontre une erreur
            set private($visuNo,demande_arret) 1
            break
         }

         if { $actionType != "wait" } {
            #--- actionType != wait
            #--- je positionne l'indicateur d'etat de la sequence d'acquisition
            set private($visuNo,acquisitionState) "acquisition"

            #--- je configure le binning de la camera
            if { [::confCam::getPluginProperty $camItem hasBinning] == "1" } {
               cam[::confCam::getCamNo $camItem] bin [list [string range $actionParams(binning) 0 0] [string range $actionParams(binning) 2 2]]
            }

            #--- Boucle d'acquisition des images
            for { set imageCount 1 } { $imageCount <= $actionParams(expNb) && $private($visuNo,demande_arret) == 0 } {incr imageCount } {
               set catchResult [ catch {
                  #--- je lance l'acquisition ( voir callbackAcquisition pour la suite de l'acquisition)
                  if { [file exists $::conf(eshel,mainDirectory)/simulation]  == 0 || $actionParams(expTime) < 7}  {
                     ::camera::acquisition $camItem "::eshel::acquisition::callbackAcquisition $visuNo" $actionParams(expTime)
                  } else {
                     #--- je fais toujours des poses de 5 secondes maximum pour gagner du temps en simulation
                     ::camera::acquisition $camItem "::eshel::acquisition::callbackAcquisition $visuNo" 5
                  }

                  #--- je lance le rafraichissement du status (boucle infinie en parallele avec l'acquisition)
                  ::eshel::acquisition::startUpdateStatus $visuNo $statusLabel $imageCount $actionParams(expNb) $actionParams(expTime) $camItem

                  #--- j'attends la fin de l'acquisition (voir ::eshel::callbackAcquisition)
                  vwait ::eshel::acquisition::private($visuNo,acquisitionState)

                  if { $private($visuNo,acquisitionState) == "error" } {
                     #--- j'interromps la boucle des acquisitions dans la thread de la camera
                     set private($visuNo,demande_arret) 1
                     break
                  }

                  if { $imageCount == 1 } {
                     #--- je memorise la date de la premiere image pour servir d'identifiant de la serie
                     set private(currentSeriesId) [lindex [buf$bufNo getkwd "DATE-OBS" ] 1]
                  }

                  #--- j'enregistre l'image dans un fichier
                  set fileName ""
                  #--- je prepare le nom du fichier et le type d'image
                  switch $actionType {
                     objectSerie  {
                        #--- Mode Object
                        append fileName "[string map { " " "" } $actionParams(objectName)]-$actionParams(expTime)s"
                        set imageType "OBJECT"
                     }
                     darkSerie {
                        #--- Mode Dark
                        append fileName "DARK-$actionParams(expTime)s"
                        set imageType "DARK"
                     }
                     flatfield  {
                         #--- Mode Dark
                         append fileName "FLATFIELD-$actionParams(expTime)s"
                         set imageType "FLATFIELD"
                     }
                     ledSerie {
                        #--- Mode Flat
                        append fileName "LED-$actionParams(expTime)s"
                        set imageType "LED"
                     }
                     tharSerie {
                        #--- Mode Thar
                        append fileName "THAR-$actionParams(expTime)s"
                        set imageType "CALIB"
                     }
                     tungstenSerie  {
                         #--- Mode Dark
                         append fileName "TUNGSTEN-$actionParams(expTime)s"
                         set imageType "TUNGSTEN"
                     }
                     tungstenSerie {
                       #--- Mode Tungsten
                        append fileName "TUNGSTEN-$actionParams(expTime)s"
                        set imageType "TUNGSTEN"
                     }
                     biasSerie  {
                        #--- Mode bias
                        append fileName "BIAS"
                        set imageType "BIAS"
                     }
                  }

                  #--- J'ajoute l'indice et l'extension
                  append fileName "-$imageCount$::conf(extension,defaut)"

                  if { [file exists $::conf(eshel,mainDirectory)/simulation]  == 1 }  {
                     #--- Simulation : je recupere le fichier dans le repertoire simulation
                     set searchedName [file join $::conf(eshel,mainDirectory) simulation "$fileName"]
                     set simulName [lindex [glob -nocomplain $searchedName] 0]
                     if { $simulName != "" } {
                        set dateObs  [lindex [buf$bufNo getkwd "DATE-OBS" ] 1]
                        ###set exposure [lindex [buf$bufNo getkwd "EXPOSURE" ] 1]
                        set exposure $actionParams(expTime)
                        set dateEnd  [mc_date2jd $dateObs ]
                        set dateEnd  [expr $dateEnd + double($exposure)/86400.0]
                        set dateEnd  [mc_date2iso8601 $dateEnd ]
                        loadima $simulName
                        ##logInfo "$sequenceName: $actionType copy $fileName\n"
                        buf$bufNo setkwd [list  "DATE-OBS" $dateObs string "" "" ]
                        buf$bufNo setkwd [list  "DATE-END" $dateEnd string "" "" ]
                        buf$bufNo setkwd [list  "EXPOSURE" $exposure float "" "" ]
                        if { [lindex [buf$bufNo getkwd "UT-START" ] 1] != "" } {
                           #--- j'enleve les mots clefs du logiciel IRIS
                           buf$bufNo delkwd "UT-START"
                        }
                     } else {
                        logError "$sequenceName: Simulation: $searchedName not found\n"
                     }
                  }

                  #--- je donne les valeurs des mots clefs optionnels
                  set configId $::conf(eshel,currentInstrument)
                  ::keyword::setKeywordValue $visuNo $::conf(eshel,keywordConfigName) "IMAGETYP" $imageType
                  ::keyword::setKeywordValue $visuNo $::conf(eshel,keywordConfigName) "OBJNAME"  $actionParams(objectName)
                  ::keyword::setKeywordValue $visuNo $::conf(eshel,keywordConfigName) "SERIESID" $private(currentSeriesId)
                  ::keyword::setKeywordValue $visuNo $::conf(eshel,keywordConfigName) "DETNAM"   $::conf(eshel,instrument,config,$configId,cameraName)
                  ::keyword::setKeywordValue $visuNo $::conf(eshel,keywordConfigName) "INSTRUME" $::conf(eshel,instrument,config,$configId,spectroName)
                  ::keyword::setKeywordValue $visuNo $::conf(eshel,keywordConfigName) "TELESCOP" $::conf(eshel,instrument,config,$configId,telescopeName)
                  ::keyword::setKeywordValue $visuNo $::conf(eshel,keywordConfigName) "CONFNAME" $::conf(eshel,instrument,config,$configId,configName)
                  ::keyword::setKeywordValue $visuNo $::conf(eshel,keywordConfigName) "OBSERVER" $::conf(posobs,nom_observateur)
                  ::keyword::setKeywordValue $visuNo $::conf(eshel,keywordConfigName) "SWCREATE" "eShel-[package present eshel]"
                  #--- j'ajoute des mots clefs dans l'en-tete FITS de l'image
                  foreach keyword [ ::keyword::getKeywords $visuNo $::conf(eshel,keywordConfigName) ] {
                     #--- j'ajoute tous les mots cles qui ne sont pas vide
                     buf$bufNo setkwd $keyword
                  }
                  #--- j'ajoute le mot cle COMMENT1 s'il n'est pas vide
                  if { $sequenceComment != "" } {
                     buf$bufNo setkwd [list "COMMENT1" $sequenceComment string "" "" ]
                  }

                  if { $actionParams(saveFile) == 1} {
                     set dateObs  [mc_date2ymdhms [lindex [buf$bufNo getkwd "DATE-OBS" ] 1]]
                     set dateObs  [split $private(currentSeriesId) {-T:.} ]

                     set fileDate [format "%04s%02s%02s-%02s%02s%02s" [lindex $dateObs 0] [lindex $dateObs 1] [lindex $dateObs 2] [lindex $dateObs 3] [lindex $dateObs 4] [lindex $dateObs 5] ]
                     #--- j'ajoute le repertoire et la date a l'avant du nom
                     set shortName "$fileDate-$fileName"
                     set fileName [file join $::conf(eshel,rawDirectory) $shortName]
                     #--- Sauvegarde de l'image
                     saveima $fileName $visuNo
                     logInfo "$sequenceName: $actionType $shortName\n"
                  }
               } ] ; #--- fin du catch de l'enregistrement de l'image

               if { $catchResult != 0 } {
                  logError "$::errorInfo\n"
                   #--- je sors de la boucle si on a rencontre une erreur
                  break
               }
               if { $private($visuNo,demande_arret) != 0  }  {
                  #--- je sors de la boucle si l'utilisateur a fait une demande d'arret
                  set private($visuNo,demande_arret) 1
                  break
               }
            } ; #--- fin de la boucle compteurImage

            set catchResult [ catch {
               #--- je restaure la configuration des intruments
               switch $actionType {
                  objectSerie  {
                     #--- rien a faire
                  }
                  darkSerie {
                     #--- je remets l'obturateur de la camera en mode synchro
                     ::confCam::setShutter $camItem 2 set
                  }
                  ledSerie  {
                     if { $::conf(eshel,enableGuidingUnit) == 1  } {
                        #--- j'eteins les lampees
                        ::eshel::instrument::setSpectrographLamp $bonnetteLinkNo "led" 0
                        ::eshel::instrument::setSpectrographLamp $bonnetteLinkNo "tungsten" 0
                        #--- je desactive le miroir si l'action suivante
                        if { $keepMirrorEnabled == 0 || $private($visuNo,demande_arret)==1 } {
                           ::eshel::instrument::setSpectrographLamp $bonnetteLinkNo "mirror" 0
                        }
                     }
                  }
                  flatfieldSerie  {
                     #--- rien a faire
                  }
                  tharSerie {
                     if { $::conf(eshel,enableGuidingUnit) == 1  } {
                        #--- j'eteins la lampe
                        ::eshel::instrument::setSpectrographLamp $bonnetteLinkNo "thar" 0
                        #--- je desactive le miroir
                        if { $keepMirrorEnabled == 0 || $private($visuNo,demande_arret)==1 } {
                           ::eshel::instrument::setSpectrographLamp $bonnetteLinkNo "mirror" 0
                        }
                     }
                  }

                  tungstenSerie {
                     if { $::conf(eshel,enableGuidingUnit) == 1  } {
                        #--- j'eteins la lampe
                        ::eshel::instrument::setSpectrographLamp $bonnetteLinkNo "tungsten" 0
                        #--- je desactive le miroir
                        if { $keepMirrorEnabled == 0 || $private($visuNo,demande_arret)==1 } {
                           ::eshel::instrument::setSpectrographLamp $bonnetteLinkNo "mirror" 0
                        }
                     }
                  }
                  biasSerie  {
                     #--- je remets l'obturateur de la camera en mode synchro
                     ::confCam::setShutter $camItem 2 set
                  }
                  readOut  {
                     #--- je remets l'obturateur de la camera en mode synchro
                     ::confCam::setShutter $camItem 2 set
                  }
               }
            } ]

            if { $catchResult != 0 } {
               logError "$::errorInfo\n"
               #--- je sors de la boucle si on a rencontre une erreur
               set private($visuNo,demande_arret) 1
               break
            }

            #--- je supprime nom de la serie en cours
            set private(currentSeriesId) ""
            #--- je lance le traitement
            if { $::conf(eshel,processAuto) == 1 } {
               #-- je lance le traitement apres un leger differe , pour permettre la mise a jour de la variable private(currentSeriesId)
               after 100 ::eshel::process::startProcess
            }
         } else {
            #--- actionType == wait
            #--- j'attend l'expiration du delai par tranche de 1 seconde
            stopUpdateStatus $visuNo
            set delay [expr int( $actionParams(expTime) * 1000)]
            while { $delay  > 0 } {
               #--- j'affiche le status
               set value "$statusLabel [ expr int($delay/1000)]/[ format "%d" $actionParams(expTime) ]"
               ::eshel::setStatus $visuNo $value
               #--- laisse la main pour traiter une eventuelle demande d'arret
               update
               if { $private($visuNo,demande_arret) == 0 } {
                  if { $delay > 1000 } {
                     after 999
                     set delay [expr $delay - 1000 ]
                  } else {
                     after $delay
                     set delay 0
                  }
               } else {
                  #--- j'interromp l'attente s'il y a une demande d'arret
                  set delay 0
               }
            }
            ::eshel::setStatus $visuNo ""
         }

         logInfo "$sequenceName: $actionType $::caption(eshel,acquisition,endAction)\n"
         if { $private($visuNo,demande_arret) != 0  }  {
            #--- je sors de la boucle si l'utilisateur a fait une demande d'arret
            break
         }
   } ; # fin de la boucle des actions de la sequence

   } ; # fin de la boucle de repetion de la sequence

   logInfo "$sequenceName: $::caption(eshel,acquisition,sequenceEnd)\n"
   stopUpdateStatus $visuNo
   set private($visuNo,demande_arret) "0"

   if { $private($visuNo,acquisitionState) == "error" } {
      set private($visuNo,acquisitionState) ""
      #--- je retourne uen erreur � la procedure appelante
      error $::caption(eshel,acquisition,acquisitionError)
   } else {
      set private($visuNo,acquisitionState) ""
   }
}

#------------------------------------------------------------
# stopSequence
#    interrompt une sequence
# parametres
#    visuNo : numero de la visu
#
proc ::eshel::acquisition::stopSequence { visuNo } {
   variable private

   logInfo "$::caption(eshel,acquisition,sequenceInterrupt) !!!\n"
   set camItem [::confVisu::getCamItem $visuNo]
   if { $camItem != "" } {
      #--- je position l'indicateur d'etat des actions de l'utilisateur
      set private($visuNo,demande_arret) 1
      #--- je transmet la demande d'arret a la camera
      ::camera::stopAcquisition $camItem
   }
}

#------------------------------------------------------------
# callbackAcquisition
#    recoit les messages envoyes par la thread de la camera
# parametres
#    visuNo : numero de la visu
#
proc ::eshel::acquisition::callbackAcquisition { visuNo command args } {
   variable private

   ###logInfo "callbackAcquisition visu=$visuNo command=$command args=$args\n"
   switch $command  {
      "autovisu" {
         #--- ce message signale que l'image est prete dans le buffer
         #--- on peut l'afficher sans attendre la fin de la sequence d'acquisition
         ::confVisu::autovisu $visuNo
      }
      "acquisitionResult" {
         #--- ce message signale que la thread de la camera a termine completement l'acquisition
         #--- je traite l'image dans la thread principale
         set private($visuNo,acquisitionState) "acquisition"
      }
      "error" {
         #--- ce message signale qu'une erreur est survenue dans la thread de la camera
         #--- j'affiche l'erreur dans la console
         logError "::eshel::acquisition::callbackAcquisition error: $args\n"
         #--- je termine la sequence dans la thread principale
         set private($visuNo,acquisitionState) "error"
      }
   }
}

#------------------------------------------------------------
# startUpdateStatus
#   Lance la boucle d'affichage du status de l'acquisition
#   Cette procedure est appelle par la procedure d'acquisition
#   chaque fois que l'on commence une serie d'image.
#
proc ::eshel::acquisition::startUpdateStatus { visuNo statusLabel imageCount imageNb expTime camItem } {
   variable private

   set private($visuNo,updateStatus) 1
   #--- j'arrete le timer s'il est encours
   if { [info exists private($visuNo,updateStatusId)] && $private($visuNo,updateStatusId)!="" } {
      after cancel $private($visuNo,updateStatusId)
   }
   set private($visuNo,updateStatusId) ""
   #--- je n'affiche que les les 10 premiers caracteres du nom de l'objet pour ne pas trop elargir le panneau de l'outil
   set statusLabel [string range $statusLabel 0 9]
   #--- j'arrondi le temps de pose
   set expTime [expr int($expTime)]
   #--- je lance la boucle d'affichage pendant la pose
   ::eshel::acquisition::updateStatus $visuNo $statusLabel $imageCount $imageNb $expTime $camItem
}

#------------------------------------------------------------
# stopUpdateStatus
#   arrete la boucle de mise a jour du status
#
proc ::eshel::acquisition::stopUpdateStatus { visuNo } {
   variable private

   set private($visuNo,updateStatus) 0
   after cancel $private($visuNo,updateStatusId)
   set private($visuNo,updateStatusId) ""
   ::eshel::setStatus $visuNo ""
}

#------------------------------------------------------------
# updateStatus
#   Affiche le status de l'acquisition dans la fenetre de la visu
#   Cette procedure est appelle par elle meme toutes les secondes
#   tant que l'indicateur private($visuNo,updateStatus) = 1
#
proc ::eshel::acquisition::updateStatus { visuNo statusLabel imageCount imageNb expTime camItem } {
   variable private

   if { $private($visuNo,updateStatus) == 1 } {
      set camNo [::confCam::getCamNo $camItem]
      if { $camNo == 0 } {
         return
      }

#      if { [set ::status_cam$camNo] == "exp" } {
#         set remainingTime [expr [cam$camNo timer -1] ]
#         set value "$statusLabel  [expr $imageNb - $imageCount + 1]/$imageNb  [ expr $remainingTime ]/[ format "%d" $expTime ]"
#      } elseif { [set ::status_cam$camNo] == "read" }  {
#         set value "$statusLabel  [expr $imageNb - $imageCount + 1]/$imageNb  lecture "
#      } else {
#         set value ""
#      }

      set remainingTime [expr [cam$camNo timer -1] ]
      if { $remainingTime > 0  } {
         set value "$statusLabel  [expr $imageNb - $imageCount + 1]/$imageNb  [ expr $remainingTime ]/[ format "%d" $expTime ]"
      } else {
         set value "$statusLabel  [expr $imageNb - $imageCount + 1]/$imageNb  lecture "
      }

      #--- j'affiche le status
      ::eshel::setStatus $visuNo $value
      #--- je lance l'iteration suivante
      set private($visuNo,updateStatusId) [after 1000 [list ::eshel::acquisition::updateStatus $visuNo $statusLabel $imageCount $imageNb $expTime $camItem ]]
   } else {
      ::eshel::setStatus $visuNo ""
   }
}

#------------------------------------------------------------
# getCurrentSeriesID
#    retourne l'identifiant de la serie en cours d'acquisition
#
# return :
#    retourne private(currentSeriesId)
#
proc ::eshel::acquisition::getCurrentSeriesID { } {
   variable private

   return $private(currentSeriesId)
}

#------------------------------------------------------------
# logInfo
#   ajoute un texte dans les
#
proc ::eshel::acquisition::logInfo { message  } {
   variable private

   ::console::disp "eShel-acq: $message"
   ::eshel::logFile "eShel-acq: $message" "#000000"
}

#------------------------------------------------------------
# logError
#   ajoute un texte dans les
#
proc ::eshel::acquisition::logError { message  } {
   variable private

   ::console::affiche_erreur "eShel-acq: $message"
   ::eshel::logFile "eShel-acq: $message" "#FF0000"
}

