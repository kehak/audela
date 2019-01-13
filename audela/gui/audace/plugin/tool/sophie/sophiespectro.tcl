#
# @file     sophiespectro.tcl
# @brief    fichier du namespace ::sophie::spectro
# @author   Michel PUJOL et Robert DELMAS
# $Id: sophiespectro.tcl 13349 2016-03-11 14:45:52Z rzachantke $

## @namespace sophie::spectro
#  @brief   interface avec le PC du spectrographe Sophie
#
namespace eval ::sophie::spectro {
   variable private

   set private(socketHandle) ""

   #--- variables de calcul des statistiques pour le PC Sophie
   set private(alphaMean) 0.0        ; #---  moyenne des corrections alpha
   set private(alphaRms)  0.0        ; #---  dispersion des corrections alpha
   set private(deltaMean) 0.0        ; #--- moyenne des corrections delta
   set private(deltaRms)  0.0        ; #--- dispersion des corrections delta
   set private(correctionNb)  0      ; #--- nombre de corrections
   set private(statisticsEnabled) 0  ; #---
   set private(xFwhm)     0.0        ; #--- seeing sur l'axe X (en arsec)
   set private(yFwhm)     0.0        ; #--- seeing sur l'axe Y (en arsec)
   set private(skyLevel)  0.0        ; #--- fond du ciel (en ADU)
   set private(starFlux)  0.0        ; #--- flux de l'étoile (en ADU/s)

}

#------------------------------------------------------------
# openSocket
#    ouvre une socket en attente d'une connexion du PC Sophie.
#    La connexion entrante du PC Sophie est traitee par ::sophie::spectro::acceptSocket
#
#------------------------------------------------------------
proc ::sophie::spectro::openSocket { } {
   variable private

   if { $private(socketHandle) != "" } {
      #--- je ferme la socket si elle etait deja ouverte
      closeSocket
   }

   #--- j'ouvre la socket en reception
   set private(socketHandle) [socket -server ::sophie::spectro::acceptSocket $::conf(sophie,socketPort) ]
   ###console::disp "::sophie::spectro::openSocket  OK channel=$private(socketHandle)\n"
}

#------------------------------------------------------------
## @brief traite la demande de connexion entrante du PC Sophie.
#  @details les données recues sont traitées par ::sophie::spectro::readSocket
#  @param channel  identifiant du channel de la socket
#  @param address  adresse de la machine du client
#  @param port     port de la connexion entrante
#
proc ::sophie::spectro::acceptSocket { channel address port } {
   variable private

   #--- je configure la gestion des buffer -buffering none -blocking no -translation binary -encoding binary
   fconfigure $channel -buffering line -blocking false -translation binary -encoding binary
   ###::console::disp  "::sophie::spectro::acceptSocket $address:$port channel=$channel connected \n"
   #--- j'indique la procedure a appeler pour lire et traiter les donnees recues
   fileevent $channel readable [list ::sophie::spectro::readSocket $channel ]
}

#------------------------------------------------------------
# closeSocket
#    deconnexion au PC du spectrographe Sophie
#
#
#------------------------------------------------------------
proc ::sophie::spectro::closeSocket {  } {
   variable private

   if { $private(socketHandle) != "" } {
      close $private(socketHandle)
      set private(socketHandle) ""
   }
}

#------------------------------------------------------------
## @brief lit et traite le message envoyé par le PC Sophie.
#  @details Les messages sont :
#   - si RAZ_STAT  alors appelle resetStatistics
#   - si STAT_ON  alors appelle startStatistics
#   - si STAT_OFF  alors appelle stopStatistics
#   - si GET_STAT  alors appelle getStatistics et retourne les valeurs alphaMean alphaRms deltaMean deltaRms
#  @param channel  identifiant du channel de la socket
#
proc ::sophie::spectro::readSocket { channel } {
   variable private

   if {[eof $channel ]} {
     close $channel
   } else {
      set data [read -nonewline $channel]
      set beginPos [string first "!" $data ]
      set endPos   [string first "@" $data ]
      if { $beginPos != -1 && $endPos != -1 && $beginPos < $endPos } {
         set data [string range $data $beginPos $endPos ]
      }
     ### ::console::disp "::sophie::spectro::readSocket read channel=$channel data=###$data###\n"
      switch $data {
         "!RAZ_STAT@" {
            ::sophie::spectro::resetStatistics
         }
         "!STAT_ON@" {
            #--- j'initialise l'image integree
            set private(AsynchroneParameter) 1
            set camItem [::confVisu::getCamItem [::sophie::getVisuNo]]
            if { $camItem != "" } {
               ::camera::setAsynchroneParameter  $camItem \
                  "originSumCounter"         0
            }
            #--- j'initialise les statistique
            ::sophie::spectro::startStatistics
         }
         "!STAT_OFF@" {
            ::sophie::spectro::stopStatistics
         }
         "!GET_STAT@" {
            #--- je recupere les statistiques ( alphaMean alphaRms deltaMean detaRms)
            set resultList [::sophie::spectro::getStatistics ]
            #--- je calcule le seeing en faisant la moyenne de xFwhm et yFwhm
            set seeing [expr ($private(xFwhm) + $private(yFwhm)) / 2.0 ]
            #--- j'enregistre l'image integree et je recupere son nom
            #--- S'il n'y a pas d'image integree disponible, la commande saveImage
            #--- retourne un nom de fichier factice afin d'envoyer un message
            #--- de longueur fixe au PC Sphie
            set fileName [saveImage [lindex $resultList 0] [lindex $resultList 1] [lindex $resultList 2] [lindex $resultList 3] $seeing $private(skyLevel) $private(starFlux)]
            #--- j'ajoute un message dans le fichier de log
            set log [ format "%s Ecart : A=%5.2f  Arms=%5.2f  D=%5.2f  Drms=%5.2f  Seeing=%5.2f skyLevel= %5.2f Gain : AP=%s  AI=%s AD=%s DP=%s  DI=%s DD=%s Coord : RA=%s  Dec=%s\n" \
               [ mc_date2iso8601 now ] \
               [lindex $resultList 0] [lindex $resultList 1] \
               [lindex $resultList 2] [lindex $resultList 3] \
               $seeing $private(skyLevel) \
               [ expr $::conf(sophie,alphaProportionalGain) * 100 ] \
               [ expr $::conf(sophie,alphaIntegralGain) * 100 ] \
               [ expr $::conf(sophie,deltaProportionalGain) * 100 ] \
               [ expr $::conf(sophie,deltaIntegralGain) * 100 ] \
               [ expr $::conf(sophie,deltaDerivativeGain) * 100 ] \
               [ expr $::conf(sophie,deltaDerivativeGain) * 100 ] \
               $::audace(telescope,getra) $::audace(telescope,getdec) ]
            ::sophie::log::writeLogFile $::audace(visuNo) log $log
            #--- je mets en forme le resultat pour le PC Sophie
            set resultString [format "!GET_STAT@    A = %5.2f  Arms = %5.2f  D = %5.2f  Drms = %5.2f  Seeing= %5.2f  SkyLevel= %5.2f FileName= %s " \
               [lindex $resultList 0] [lindex $resultList 1] \
               [lindex $resultList 2] [lindex $resultList 3] \
               $seeing $private(skyLevel) $fileName \
            ]
            ::console::disp "::sophie::spectro::spectro::readSocket resultString=$resultString\n"
            #--- je retourne le resultat au PC Sophie
            puts $channel $resultString

         }
         "" {
            #--- je ne fais rien s'il n'y a pas de donnees
         }
         default {
            console::affiche_erreur "::sophie::spectro::spectro::readSocket invalid data=$data\n"
         }
      }
   }
}

##------------------------------------------------------------
# resetStatistics
#   raz des variables de calcul des statistiques pour le PC Sophie
#
#------------------------------------------------------------
proc ::sophie::spectro::resetStatistics { } {
   variable private

   set private(alphaMean) 0.0       ; #--- moyenne des corrections alpha
   set private(alphaRms)  0.0       ; #--- dispersion des corrections alpha
   set private(deltaMean) 0.0       ; #--- moyenne des corrections delta
   set private(deltaRms)  0.0       ; #--- dispersion des corrections delta
   set private(correctionNb)  0     ; #--- nombre de corrections

}

#------------------------------------------------------------
## @brief enregistre l'image integrée.
#  @details le nom du fichier est "guidage-<dateISO8601>.fit"
#  @code Exemple :
#  guidage-2009-05-13T18:51:30.250.fit
#  @endcode
#  S'il n'y a pas d'image integree disponible, la commande n'enregistre pas d'image
#  et retourne guidage-0000-00-00T00-00-00.000.fit
#  @note
#  Mots clés enregistrése dans l'image integrée :
# - BIN1     binning horizontal
# - BIN2     binning vertical
# - DATE-OBS  date de début de pose de Sophie (date de réception de la commade STAT_ON)
# - DATE-END  date de fin de pose de Sophie (date de recéption de la commade STAT_OFF)
# - EXPOSURE  temps de pose individuel des images
# - NAXIS1   largeur de l'image en pixel
# - NAXIS2   hauteur de l'image en pixel
# - RA_MEAN  moyenne l'écart étoile/consigne sur l'axe alpha
# - RA_RMS   écart type de l'écart étoile/consigne sur l'axe alpha
# - DEC_MEAN moyenne l'écart étoile/consigne sur l'axe delta
# - DEC_RMS  écart type de l'écart étoile/consigne sur l'axe delta
# - SEEING   seeing moyenne (en arcsec)
# - SKYLEVEL fond du ciel (en ADU)
# - DETNAM   nom de la caméra
# - TELESCOP nom du télescope
# - SWCREATE nom du logiciel d'acquisition
# @param alphaMean
# @param alphaRms
# @param deltaMean
# @param deltaRms
# @param seeing
# @param skyLevel
# @param starFlux
# @return
# - nom du fichier de l'image intégrée
# - guidage-0000-00-00T00-00-00.000.fit s'il n'y a pas eu de correction de guidage ou pas d'image disponible
#
proc ::sophie::spectro::saveImage { alphaMean alphaRms deltaMean deltaRms seeing skyLevel starFlux } {
   variable private

   set shortName ""

   set sumBufNo [::sophie::getBufNo "sumBufNo"]
   if { $sumBufNo != 0 && [buf$sumBufNo imageready] == 1 } {
      set catchError [ catch {
         if { $private(correctionNb) > 0 } {
            set visuNo  [::sophie::getVisuNo]
            set camItem [::confVisu::getCamItem $visuNo ]
            if { [file exists $::audace(rep_images)] == 0 } {
               #--- je signale que le repertoire n'existe pas
               error [format $::caption(sophie,directoryNotFound) $::audace(rep_images)]
            }

            #--- je recupere la date UT
            set shortName "$::conf(sophie,guidingFileNameprefix)-[mc_date2iso8601 [::audace::date_sys2ut now]]$::conf(extension,defaut)"
            #--- je remplace ":" par "-" car ce n'est pas un caractere autorise dans le nom d'un fichier.
            set shortName [string map { ":" "-" } $shortName]
            #--- j'ajoute le repertoire dans le nom du fichier
            set fileName [file join $::audace(rep_images) $shortName]
            #--- j'ajoute les mots cles dans l'image integree
            ::keyword::setKeywordValue $visuNo $::conf(sophie,keywordConfigName) "RA_MEAN"  $alphaMean
            ::keyword::setKeywordValue $visuNo $::conf(sophie,keywordConfigName) "RA_RMS"   $alphaRms
            ::keyword::setKeywordValue $visuNo $::conf(sophie,keywordConfigName) "DEC_MEAN" $deltaMean
            ::keyword::setKeywordValue $visuNo $::conf(sophie,keywordConfigName) "DEC_RMS"  $deltaRms
            ::keyword::setKeywordValue $visuNo $::conf(sophie,keywordConfigName) "SEEING"   $seeing
            ::keyword::setKeywordValue $visuNo $::conf(sophie,keywordConfigName) "DETNAM"   [::confCam::getPluginProperty $camItem "name"]
            ::keyword::setKeywordValue $visuNo $::conf(sophie,keywordConfigName) "TELESCOP" $::conf(telescope)
            ::keyword::setKeywordValue $visuNo $::conf(sophie,keywordConfigName) "SWCREATE" "[::audela::getPluginTitle] $::audela(version)"
            set keywordNameList [list RA_MEAN RA_RMS DEC_MEAN DEC_RMS SEEING SKYLEVEL DETNAM TELESCOP SWCREATE]
            #--- j'ajoute des mots cles dans l'en-tete FITS de l'image
            foreach keyword [ ::keyword::getKeywords $visuNo $::conf(sophie,keywordConfigName) $keywordNameList] {
               #--- j'ajoute tous les mots cles qui ne sont pas vide
               buf$sumBufNo setkwd $keyword
            }

            buf$sumBufNo setkwd  [list "STARFLUX" $starFlux float "Star flux" "ADU/s" ]
            buf$sumBufNo setkwd  [list "SKYLEVEL" $skyLevel float "Sky level" "ADU/s" ]

            #--- Sauvegarde de l'image
            buf$sumBufNo save $fileName
         } else {
            #--- il n'y a pas de eu de correction
             set shortName "$::conf(sophie,guidingFileNameprefix)-0000-00-00T00:00:00.000$::conf(extension,defaut)"
         }
      } ]

      if { $catchError != 0 } {
         #--- je trace le message d'erreur
         ::console::affiche_erreur $::errorInfo
      }
   } else {
      #--- il n'y a pas d'image disponible
      ::console::affiche_erreur $::caption(sophie,sumNotReady)
      set shortName "$::conf(sophie,guidingFileNameprefix)-0000-00-00T00:00:00.000$::conf(extension,defaut)"
   }

   return $shortName
}

#------------------------------------------------------------
## @brief mémorise le flux de l'éoile
#  @param starFlux    flux de l'étoile (en ADU/s)
#
proc ::sophie::spectro::setStarFlux { starFlux} {
   variable private

   set private(starFlux)   $starFlux
}

#------------------------------------------------------------
## @brief mémorise le fond de ciel
#  @param skyLevel  fond du ciel (en ADU/s)
#
proc ::sophie::spectro::setSkyLevel { skyLevel } {
   variable private

   set private(skyLevel)   $skyLevel
}

#------------------------------------------------------------
## @brief mémorise le seeing
#  @param xFwhm       seeing sur l'axe x (en arsec)
#  @param yFwhm       seeing sur l'axe y (en arsec)
#
proc ::sophie::spectro::setSeeing { xFwhm yFwhm } {
   variable private

   set private(xFwhm)      $xFwhm
   set private(yFwhm)      $yFwhm
}

#------------------------------------------------------------
# startStatistics
#  debute le calcul des statistiques de guidage pour le PC Sophie
#
#------------------------------------------------------------
proc ::sophie::spectro::startStatistics { } {
   variable private

   #--- j'active les statistiques
   set private(statisticsEnabled) 1

   #--- je met a jour le voyant dans la fenetre de controle
   ::sophie::control::setAcquisitionSophie 1

   #--- j'ajoute le mot cle DATE-OBS dans l'image integree
   set sumBufNo [::sophie::getBufNo "sumBufNo"]
   if { $sumBufNo != 0 && [buf$sumBufNo imageready] == 1 } {
      set dateObs [mc_date2iso8601 [::audace::date_sys2ut now]]
      buf$sumBufNo setkwd [list "DATE-OBS" $dateObs string "" "" ]
   }
}

##------------------------------------------------------------
# stopStatistics
#  arrete le calcul des statistiques de guidage pour le PC Sophie
#
#------------------------------------------------------------
proc ::sophie::spectro::stopStatistics { } {
   variable private

   #--- j'arrete la mise a jour des statistiques
   set private(statisticsEnabled) 0

   #--- je met a jour le voyant dans la fenetre de controle
   ::sophie::control::setAcquisitionSophie 0

   #--- j'ajoute le mot cle DATE-END dans l'image integree
   set sumBufNo [::sophie::getBufNo "sumBufNo"]
   if { $sumBufNo != 0 && [buf$sumBufNo imageready] == 1 } {
      set dateEnd [mc_date2iso8601 [::audace::date_sys2ut now]]
      buf$sumBufNo setkwd [list "DATE-END" $dateEnd string "" "" ]
   }
}

#------------------------------------------------------------
## @brief retourne les statistiques de guidage pour le PC Sophie
#  @return liste de 4 valeurs :
#  - private(alphaMean)
#  - private(alphaRms)
#  - private(deltaMean) *
#  - private(deltaRms)
#
proc ::sophie::spectro::getStatistics { } {
   variable private

   #--- je calcule la valeur finale de alphaRms
   if { $private(alphaRms) >=0 && $private(correctionNb) > 0 } {
      set private(alphaRms) [expr sqrt($private(alphaRms) / $private(correctionNb)) ]
   } else {
      set private(alphaRms) 0.0
   }

   #--- je calcule la valeur finale de alphaRms
   if { $private(deltaRms) >=0 && $private(correctionNb) > 0 } {
      set private(deltaRms) [expr sqrt($private(deltaRms) / $private(correctionNb)) ]
   } else {
      set private(deltaRms) 0.0
   }

   set result [list $private(alphaMean) $private(alphaRms) $private(deltaMean) $private(deltaRms) ]
   ###set result [list 2.68 83.17 2.74 177.85 ]
   ###console::disp "::sophie::getStatistics $result\n"
   return $result
}

#------------------------------------------------------------
## @brief ajoute la correction du télescope dans les statistiques.
#  @details les variables private(alphaMean) private(alphaRms) private(deltaaMean) private(deltaaRms)
#  sont mises à jour.
#  @param alphaDiff  écart alpha étoile/consigne (arcsec)
#  @param deltaDiff  écart delta étoile/consigne (arcsec)
#
proc ::sophie::spectro::updateStatistics { alphaDiff deltaDiff } {
   variable private

   if { $private(statisticsEnabled) == 0 } {
      #--- je ne fais pas de mise a jour si les statistiques ne sont pas activees
      return
   }

   #--- j'increment le nombre de corrections
   incr private(correctionNb)
   set epsilon "1.0e-300"

   #--- j�initialise les moyennes pour la premi�re it�ration
   if { $private(correctionNb) == 1 }  {
      set private(alphaMean) $alphaDiff
      set private(deltaMean) $deltaDiff
   }

   #--- je calcule la moyenne des corrections Alpha
   set diff [expr $alphaDiff - $private(alphaMean) ]
   if { [expr abs($diff) < $epsilon ] }  {
      if { [expr $diff < 0] } {
         set diff [expr - $epsilon]
      } else {
         set diff [expr $epsilon]
      }
   }
  set mean [expr $private(alphaMean) + $diff / $private(correctionNb)]

  #--- je calcule rms des corrections Alpha
   set rms  [expr $private(alphaRms) + $diff * ($alphaDiff  - $mean)]
   if { [expr abs($rms) < $epsilon ] } {
      if { [expr $rms  < 0] } {
         set rms [expr - $epsilon]
      } else {
         set rms [expr $epsilon]
      }
   }
   set private(alphaMean) $mean
   set private(alphaRms)  $rms

   #--- je calcule la moyenne des corrections Delta
   set diff [expr $deltaDiff - $private(deltaMean) ]
   if { [expr abs($diff) < $epsilon ] }  {
     if { [expr $diff < 0] } {
         set diff [expr - $epsilon]
      } else {
         set diff [expr $epsilon]
      }
   }
   set mean [expr $private(deltaMean) + $diff / $private(correctionNb) ]

   #--- je calcule rms des corrections Delta
   set rms  [expr $private(deltaRms) + $diff * ( $deltaDiff  - $mean )]
   if { [expr abs($rms) < $epsilon ] } {
      if { [expr $rms  < 0] } {
         set rms [expr - $epsilon]
      } else {
         set rms [expr $epsilon]
      }
   }

   set private(deltaMean) $mean
   set private(deltaRms)  $rms

  ### console::disp "::sophie::updateStatistics alphaMean=$private(alphaMean) alphaRms=$private(alphaRms) deltaMean=$private(deltaMean) deltaRms=$private(deltaRms)\n"
   return
}

