#
# @file     sophiecamerathread.tcl
# @brief    Fichier du namespace ::camerathread
# @author   Michel PUJOL et Robert DELMAS
# $Id: sophiecamerathread.tcl 13349 2016-03-11 14:45:52Z rzachantke $

## namespace camerathread
# @brief   procedure d'acquisition et de traitement exécutee dans le thread de la camera

namespace eval ::camerathread {

}

#------------------------------------------------------------
# guideSophie lance la boucle d'acquisition continue
#
#------------------------------------------------------------
proc ::camerathread::guideSophie { exptime originCoord targetCoord cameraAngle targetBoxSize mountEnabled mountRate alphaReverse deltaReverse intervalle } {
   variable private

   if { $private(acquisitionState) == 1 } {
      ::camerathread::notify "error" "camera is busy"
      return
   }

   set private(exptime)              $exptime
   set private(originCoord)          $originCoord
   set private(targetCoord)          $targetCoord
   set private(fiberCoord)           $originCoord
   set private(targetBoxSize)        $targetBoxSize
   set private(cameraAngle)          $cameraAngle
   set private(mountEnabled)         $mountEnabled
   set private(mountRate)            $mountRate
   set private(alphaReverse)         $alphaReverse
   set private(deltaReverse)         $deltaReverse
   set private(intervalle)           $intervalle

   set private(centerDeltaList)      ""
   set private(acquisitionState)     "1"
   set private(previousClock)        "0"

   #--- variables de travail
   set private(simulationCounter)    "1"
   set private(originSumCounter)     0
   set private(xDiffCumul)           0
   set private(yDiffCumul)           0
   set private(xPreviousDiff)            ""
   set private(yPreviousDiff)            ""
   set private(centerDeltaList)      ""
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]

   ###::camerathread::disp "::camerathread::processAcquisition \n"
   #--- je parametre la camera
   cam$private(camNo) exptime $private(exptime)
   set private(previousClock) [clock clicks -milliseconds ]
   #--- je lance la bloucle d'acquisition
   ::camerathread::sophieAcquisitionLoop
}

#------------------------------------------------------------
## @brief boucle d'acquisition continue
#
proc ::camerathread::sophieAcquisitionLoop { } {
   variable private

   #--- debut du catch pour intercepter les erreurs
   #--- ATTENTION: il ne faut pas d'instruction return dans un cath !!!
   set catchError [ catch {
      set bufNo $private(bufNo)

      #--- je prends en compte les modifications des parametres synchrone et asynchrone
      ::camerathread::updateParameter

      if { $private(acquisitionState) == 1 } {
         #--- je calcule le temps ecoule entre deux debuts de pose (en seconde)
         set currentClock [clock clicks -milliseconds ]
         set interval [expr double($currentClock - $private(previousClock))/ 1000.0 ]
         set private(previousClock) $currentClock

         if { $private(simulation) == 0 } {
            #--- je fais une acquisition
            cam$private(camNo) acq -blocking
         } else {
            #--- je simule la duree de l'acquisition
            after [expr int($private(exptime) * 1000.0)]
            #--- je charge l'image à la place de celle de la camer
            set extension [buf$bufNo extension]
            set fileName "$private(simulationGenericFileName)$private(simulationCounter)$extension"
            buf$bufNo load "$fileName"

            #--- je simule le miroir
            if { [cam$private(camNo) mirrorh] == 1 } {
                buf$bufNo mirrorx
            }
            if { [cam$private(camNo) mirrorv] == 1 } {
                buf$bufNo mirrory
             }

            #--- je simule le fenetrage
            set windowing [cam$private(camNo) window]
            set nbcells [cam$private(camNo) nbcells]
            if { $windowing != [list 1 1 [lindex $nbcells 0 ] [lindex $nbcells 1 ]] } {
               buf$bufNo window $windowing
            }
            #--- je simule le binning
            set binning [cam$private(camNo) bin]
            if { "$binning" != "1 1" } {
               set xScale  [expr 1.0 / [lindex $binning 0 ] ]
               set yScale  [expr 1.0 / [lindex $binning 1 ] ]
               buf$bufNo scale [list $xScale $yScale ] 1.0
            }
            #--- j'increment le compteur de fichier de simulation
            incr private(simulationCounter)
            if { [file exists "$private(simulationGenericFileName)$private(simulationCounter)$extension" ] == 0 } {
               set private(simulationCounter) 1
            }
         }
      }

      if { $private(acquisitionState) == 1 } {

         #--- je prends en compte les modifications des parametres synchrones
         update

         set targetDetection ""
         #--- je calcule les coordonnees de la fenetre d'analyse
         if {  $private(mode) == "GUIDE" } {
            if { $private(guidingMode) == "OBJECT" } {
               #--- je calcule la position de la fenetre est centree sur la consigne
               #--- car la camera fait une acquition de toute l'image pour avoir l'étoile+consigne et la fibre
               set x  [lindex $private(originCoord) 0]
               set y  [lindex $private(originCoord) 1]
               set x1 [expr round($x - $private(targetBoxSize))]
               set x2 [expr $x1 + 2 * $private(targetBoxSize)]
               set y1 [expr round($y - $private(targetBoxSize))]
               set y2 [expr $y1 + 2 * $private(targetBoxSize)]
               #--- je choisis la detection de l'étoile par calcul du barycentre
               set starDetectionMode 2
               #--- j'active l'intégration de l'image
               set integratedImage 2
               set previousFiberX [lindex $private(fiberCoord) 0]
               set previousFiberY [lindex $private(fiberCoord) 1]
            } else {
               #--- la fenetre correspond à toute l'image qui est centree sur la consigne
               #--- car l'image est déjà fenetree au niveau de l'acquisition de la camera
               set x1 1
               set y1 1
               set x2 [buf$bufNo getpixelswidth]
               set y2 [buf$bufNo getpixelsheight]
               #--- je choisis la detection de l'étoile par calcul du barycentre
               set starDetectionMode 2
               #--- j'active l'intégration de l'image
               set integratedImage 1
               set previousFiberX [lindex $private(originCoord) 0]
               set previousFiberY [lindex $private(originCoord) 1]
            }
         } else {
            #--- la fenetre est centree sur l'etoile en mode centrage et en mode focalisaiton
            set x  [lindex $private(targetCoord) 0]
            set y  [lindex $private(targetCoord) 1]
            set x1 [expr round($x - $private(targetBoxSize))]
            if { $x1 < 1 } { set x1 1 }
            set x2 [expr $x1 + 2 * $private(targetBoxSize)]
            set y1 [expr round($y - $private(targetBoxSize))]
            if { $y1 < 1 } { set y1 1 }
            set y2 [expr $y1 + 2 * $private(targetBoxSize)]
            #--- je choisis la detection de l'étoile par ajustement de gaussiennne pour le cetrage
            set starDetectionMode 1
            #--- je desactive l'intégration de l'image
            set integratedImage 0
            set previousFiberX [lindex $private(originCoord) 0]
            set previousFiberY [lindex $private(originCoord) 1]
         }

         #--- j'affiche l'image et je transmets le temps ecoule entre 2 debuts de pose
         ::camerathread::notify "autovisu" $interval $private(mode) $private(guidingMode) [list $x1 $y1 $x2 $y2] $private(zoom)

         #--- j'incremente le compteur des images integrees
         if { $integratedImage != 0 } {
            incr private(originSumCounter)
         }

         #--- je mesure la position de l'etoile et le trou de la fibre
         # buf$bufNo fibercentro
         # Parameters IN:
         # @param     Argv[2]= [list x1 y1 x2 y2 ] fenetre de detection de l'etoile
         # @param     Argv[3]=starDetectionMode    1=fit de gaussienne  2=barycentre
         # @param     Argv[4]=fiberDetectionMode   1=fit de gaussienne  2=barycentre
         # @param     Argv[5]=integratedImage      0=pas d'image integree, 1=image integree centree la fenetre, 2=image integree centree sur la consigne
         # @param     Argv[6]=findFiber            1=recherche de l'entrée de fibre , 0= ne pas rechercher
         # @param     Argv[7]=maskBufNo            numero du buffer du masque
         # @param     Argv[8]=sumBufNo             numero du buffer de l'image integree
         # @param     Argv[9]=fiberBufNo           numero du buffer de l'image resultat
         # @param     Argv[10]=originSumMinCounter  nombre d'acquisition de l'image integree
         # @param     Argv[11]=originSumCounter    compteur d'integration de l'image de l'origine
         # @param     Argv[12]=previousFiberX      abcisse du centre de la fibre
         # @param     Argv[13]=previousFiberY      ordonnee du centre de la fibre
         # @param     Argv[14]=maskRadius          rayon du masque
         # @param     Argv[15]=maskFwhm            largeur a mi hauteur de la gaussienne
         # @param     Argv[16]=pixelMinCount       nombre minimal de pixels pour accepter l'image
         # @param     Argv[17]=maskPercent         pourcentage du niveau du masque
         # @param     Argv[18]=biasValue           valeur du bias
         #
         # @return si TCL_OK
         #            list[0] starStatus           resultat de la recherche de la fibre (DETECTED NO_SIGNAL)
         #            list[1] starX                abcisse du centre de l'etoile (pixel binné)
         #            list[2] starY                ordonnee du centre de l'etoile  (pixel binné
         #            list[3] fiberStatus          resultat de la recherche de la fibre (DETECTED NO_SIGNAL)
         #            list[4] fiberX               abcisse du centre de la fibre  (pixel binné)
         #            list[5] fiberY               ordonnee du centre de la fibre (pixel binné)
         #            list[6] measuredFwhmX        gaussienne mesuree (pixel binné)
         #            list[7] measuredFwhmY        gaussienne mesuree (pixel binné)
         #            list[8] background           fond du ciel (ADU)
         #            list[9] maxIntensity         intensite max (ADU)
         #            list[10] maxIntensity        flux de l'étoile (ADU)
         #            list[11] message             message d'information
         #
         #         si TCL_ERREUR
         #            message d'erreur

         set result [buf$bufNo fibercentro "[list $x1 $y1 $x2 $y2]" \
            $starDetectionMode $private(fiberDetectionMode) \
            $integratedImage  $private(findFiber) \
            $private(maskBufNo) $private(sumBufNo) $private(fiberBufNo) \
            $private(originSumMinCounter) $private(originSumCounter) \
            $previousFiberX $previousFiberY \
            $private(maskRadius) $private(maskFwhm) $private(pixelMinCount) $private(maskPercent) \
            $private(biasValue)]

         set binning [cam$private(camNo) bin]
         set xBinning [lindex $binning 0]
         set yBinning [lindex $binning 1]

         set starStatus       [lindex $result 0 ]
         set starX            [lindex $result 1 ]
         set starY            [lindex $result 2 ]
         set fiberStatus      [lindex $result 3 ]
         set fiberX           [lindex $result 4 ]
         set fiberY           [lindex $result 5 ]
         set measuredFwhmX    [expr [lindex $result 6 ] * $xBinning]
         set measuredFwhmY    [expr [lindex $result 7 ] * $yBinning]
         set background       [lindex $result 8 ]
         set maxIntensity     [lindex $result 9 ]
         set starFlux         [lindex $result 10 ]
         set infoMessage      [lindex $result 11 ]

         #--- je calcule le flux en ADU/seconde  (si exptime = 0 , je ne change pas la valeur)
         if { $private(exptime) != 0 } {
             set starFlux [expr $starFlux / $private(exptime) ]
             set skyLevel [expr $background / $private(exptime)]
         }

         ###::camerathread::disp  "starStatus=$starStatus starX,starY=$starX $starY fiberStatus=$fiberStatus fiberX,fiberY=$fiberX $fiberY infoMessage=$infoMessage\n"
         if { $starStatus == "DETECTED" } {
            #--- l'etoile est detectee
            set targetDetection 1
            #--- je memorise les nouvelles coordonnees de la cible
            set private(targetCoord) [list $starX $starY ]
         } else {
            #--- l'etoile n'est pas detectee
            set targetDetection 0
         }

         switch $fiberStatus {
            "DETECTED" {
               #--- je memorise les coordonnes de la consigne
               set private(originCoord) [list $fiberX $fiberY ]
            }
            "INTEGRATING" -
            "TOO_FAR" -
            "LOW_SIGNAL" -
            "NO_SIGNAL" -
            "DISABLED" -
            "OUTSIDE" -
            default {
               #--- rien a faire, je transmet le status de la fibre tel quel
            }
         }

         #--- je calcule l'ecart de position entre la cible et la consigne (en pixels ramene au binning 1x1)
         set dx [expr (double([lindex $private(targetCoord) 0]) - [lindex $private(originCoord) 0]) * $xBinning ]
         set dy [expr (double([lindex $private(targetCoord) 1]) - [lindex $private(originCoord) 1]) * $yBinning ]

        #--- je pondere la position si on est en mode GUIDE sur la fibre
         if { $private(mode) == "GUIDE"  && $private(guidingMode) != "OBJECT" } {
            ###if { [expr abs($dx) * $xBinning ] < 16 } {
            ###   #--- le denominateur est toujours non nul parce que dx > 1.7/0.04)
            ###   set dx [expr $dx / (1.7 - abs($dx) * 0.04)]
            ###}
            ###if { [expr abs($dy) * $yBinning ] < 16 } {
            ###   set dy [expr $dy / (1.7 - abs($dy) * 0.04)]
            ###}

            set distance [expr sqrt($dx * $dx + $dy * $dy ) ]
            if { $distance < 16 && $distance > 0 } {
               #--- j'utilise atan2() a la place de atan() car atan2() permet de déterminer l'angle theta sur l'intervalle [-pi,pi]
               set theta [expr atan2($dy,$dx)]
               #--- le denominateur est toujours non nul parce que distance != 1.7/0.04 (=42.5)  car distance < 16
               set distance2 [expr $distance / (1.7 - abs($distance) * 0.04)]
               set dx [expr $distance2 * cos($theta)]
               set dy [expr $distance2 * sin($theta)]
            }
         }

         if { $private(angle) != 0 } {
             set angle [expr $private(angle)* 3.14159265359/180 ]
             #--- je calcule l'ecart de position en arcseconde avec projection sur les axes de l'ascensiond droite et de la delinaison
             set alphaDiff [expr (   cos($angle) * $dx + sin($angle) *$dy) * $private(pixelScale)]
             set deltaDiff [expr (-  sin($angle) * $dx + cos($angle) *$dy) * $private(pixelScale)]
         } else {
            #--- je calcule l'ecart de position (en arcseconde)
            set alphaDiff [expr $dx * $private(pixelScale) ]
            set deltaDiff [expr $dy * $private(pixelScale) ]
         }

         #--- j'applique le PID sur les corrections
         if { $private(mountEnabled) == 1 && $starStatus == "DETECTED" } {
            if { $private(mode) == "GUIDE" } {
               #--- j'applique le PID pour le guidage si on est en mode GUIDE

               #--- je calcule le terme integrateur
               set private(xDiffCumul) [expr $private(xDiffCumul) + $dx * $interval]
               set private(yDiffCumul) [expr $private(yDiffCumul) + $dy * $interval]
               #--- J’ecrete le terme integrateur s’il engendre un déplacement superieur au demi cote de la fenetre d’analyse
               if { [expr abs($private(xDiffCumul)) - $private(targetBoxSize) ] > 0} {
                  set private(xDiffCumul) 0
               }
               if { [expr abs($private(yDiffCumul)) - $private(targetBoxSize) ] > 0 } {
                  set private(yDiffCumul) 0
               }
               set alphaIntegralTerm [expr $private(xDiffCumul) * $private(pixelScale)]
               set deltaIntegralTerm [expr $private(yDiffCumul) * $private(pixelScale)]

               #--- je calcule le terme derivateur
               if { $private(xPreviousDiff) != "" } {
                  set alphaDerivativeTerm [expr ($dx - $private(xPreviousDiff)) * $private(pixelScale) / $interval ]
                  set private(xPreviousDiff) $dx
               } else {
                  #--- si la valeur precedente n'existe pas encore, le terme derivateur est nul
                  set alphaDerivativeTerm 0
                  set private(xPreviousDiff) $dx
               }
               if { $private(yPreviousDiff) != "" } {
                  set deltaDerivativeTerm [expr ($dy - $private(yPreviousDiff)) * $private(pixelScale) / $interval ]
                  set private(yPreviousDiff) $dy
               } else {
                  #--- si la valeur precedente n'existe pas encore, le terme derivateur est nul
                  set deltaDerivativeTerm 0
                  set private(yPreviousDiff) $dy
               }
               #--- je calcule la correction avec les termes proportionnels, integrateurs et dérivateurs
               set alphaCorrection [expr $alphaDiff * $private(alphaProportionalGain) + $alphaIntegralTerm * $private(alphaIntegralGain) + $alphaDerivativeTerm * $private(alphaDerivativeGain)]
               set deltaCorrection [expr $deltaDiff * $private(deltaProportionalGain) + $deltaIntegralTerm * $private(deltaIntegralGain) + $deltaDerivativeTerm * $private(deltaDerivativeGain)]
            } else {
               #--- je ne prends que 90% de la valeur car les anciens moteurs vont trop vite surtout pour centrer en delta
               set alphaCorrection $alphaDiff
               set deltaCorrection $deltaDiff
               #--- raz du cumul pour le calcul du terme integrateur
               set private(xDiffCumul) "0"
               set private(yDiffCumul) "0"
               #--- raz de la position precedente pour le calcul du terme derivateur
               set private(xPreviousDiff) ""
               set private(yPreviousDiff) ""
            }

            #--- je verifie si le centrage est fini
            if { $private(mode)=="CENTER" } {
               #--- j'ajoute les nouvelles valeurs à la fin de la liste
               lappend private(centerDeltaList) [list $alphaCorrection $deltaCorrection ]
               #--- je supprime le premier element
               set private(centerDeltaList) [lrange $private(centerDeltaList) 1 end ]
               set xmean "0"
               set ymean "0"
               #--- je calcule la somme des ecarts
               foreach delta  $private(centerDeltaList) {
                  set xmean [expr $xmean + abs( [lindex $delta 0 ] ) ]
                  set ymean [expr $ymean + abs( [lindex $delta 1 ] ) ]
               }
               #--- je calcule la moyenne des ecarts
               set xmean [expr $xmean / [llength $private(centerDeltaList)]]
               set ymean [expr $ymean / [llength $private(centerDeltaList)]]

               #--- je vérifie si la moyenne est inferieure au seuil
               if { $xmean < $private(centerMaxLimit)  && $ymean < $private(centerMaxLimit) } {
                  #--- j'envoie une notification au thread principal pour arreter le centrage
                  ::camerathread::notify "acquisitionResult" "CENTER" $private(targetCoord)
               } else {
                  #--- rien a faire, on continue la boucle de centrage
               }
            }

            #--- j'inverse le sens des deplacements (voir l'option dans la configuration de la monture)
            if { $private(alphaReverse) == "1" } {
               set alphaCorrection [expr -$alphaCorrection]
            }
            if { $private(deltaReverse) == "1" } {
               set deltaCorrection [expr -$deltaCorrection]
            }

            #--- je prends en compte la declinaison dans le calcul de la correction de alpha
            set alphaCorrection [expr $alphaCorrection / (cos($private(targetDec) * 3.14159265359/180)) ]

            #--- j'ecrete l'ampleur du deplacement en alpha
            set maxAlpha [expr $private(targetBoxSize) * $xBinning * $private(pixelScale) ]
            if { $alphaCorrection > 0 } {
               if { $alphaCorrection > $maxAlpha } {
                  set alphaCorrection $maxAlpha
               }
            } else {
               if { $alphaCorrection < -$maxAlpha } {
                  set alphaCorrection [expr - $maxAlpha]
               }
            }

            #--- j'ecrete l'ampleur du deplacement en delta
            set maxDelta [expr $private(targetBoxSize) * $yBinning * $private(pixelScale) ]
            if { $deltaCorrection > 0 } {
               if { $deltaCorrection > $maxDelta } {
                  set deltaCorrection $maxDelta
               }
            } else {
               if { $deltaCorrection <  -$maxDelta } {
                  set deltaCorrection  [expr -$maxDelta]
               }
            }
         } else {
            #--- pas de correction si l'envoi a la monture est desactive
            set alphaCorrection 0.0
            set deltaCorrection 0.0
         }
         #--- j'envoi une notification au thread principal pour mettre a jour l'affichage de la fenetre principale
         ::camerathread::notify "targetCoord" \
            $private(targetCoord) $dx $dy $targetDetection $fiberStatus \
            [lindex $private(originCoord) 0] [lindex $private(originCoord) 1] \
            $measuredFwhmX $measuredFwhmY $skyLevel $maxIntensity $starFlux \
            $alphaDiff $deltaDiff $alphaCorrection $deltaCorrection $infoMessage
      }

      if { $private(acquisitionState) == "1" } {

         #--- je prends en compte les modifications des parametres synchones et assynchones
         ::camerathread::updateParameter

         #--- je deplace le telescope
         if { $private(mountEnabled) == 1 && $private(acquisitionState) == "1"  } {
            #--- je calcule la direction alpha
            if { $alphaCorrection >= 0 } {
               set alphaDirection "w"
            } else {
               set alphaDirection "e"
            }

            #--- je calcule la direction delta
            if { $deltaCorrection >= 0 } {
               set deltaDirection "n"
            } else {
               set deltaDirection "s"
            }

            #--- j'envoi un message au thread principal pour afficher les informations concernant la correction
            ::camerathread::notify "mountInfo" $alphaDirection [expr abs($alphaCorrection)] $deltaDirection [expr abs($deltaCorrection)]

            #--- je deplace le telescope
            if { $alphaCorrection != 0 || $deltaCorrection != 0 } {
               set correctError [ catch {
                 #--- j'envoie la commande au telescope
                  #  alphaDirection : direction alpha ( e ou w)
                  #  alphaCorrection : distance en ascension droite en arcsec
                  #  deltaDirection :  direction delta ( n ou s)
                  #  deltaCorrection : distance declinaison en arcsec
                  #  vitessse :  Pour le T193 0.0 = guidage   0.33 = centrage  0.66 = centrage2
                  tel1 radec correct $alphaDirection [expr abs($alphaCorrection)] $deltaDirection [expr abs($deltaCorrection)] $private(mountRate)
               }]
               if { $correctError != 0 } {
                  if { [string first  "tel_radec_goto already moving" $::errorInfo  ] == 0 } {
                     #--- c'est une erreur non bloquante, je continue la boucle
                  } else {
                      #--- c'est une erreur bloquante, j'interromp la boucle en tranmettant l'erreur
                      error $::errorInfo
                  }
               }
            }
         }
      }
   } catchMessage ]

   if { $catchError == 1 } {
      set  private(acquisitionState)  0
      ::camerathread::notify "error" "$::errorInfo"
   } else {
      if { $private(acquisitionState) ==  1 }  {
         #--- c'est reparti pour un tour ...
         after [expr int($private(intervalle) *1000)] ::camerathread::sophieAcquisitionLoop
      } else {
         ::camerathread::notify "acquisitionResult" "END"
      }
   }
}

#--- j'intialise les variables
# AK on inhibe pour le Tcl 8.6
#::thread::copycommand $::camerathread::private(mainThreadNo) "::camerathread::guideSophie"

