#
## @file cmaude.tcl
#  @brief Acquisition des images pour un Cloud Monitor - Outil Acquisition MASCOT
#  @author Sylvain RONDI
#  @authors Spécial DAX mis à jour par F. LOSSE Janvier 2012 puis par P.-A. MAHE
#  $Id: cmaude.tcl 13710 2016-04-15 15:14:02Z robertdelmas $
#

#
## @defgroup notice_mascot Mini All Sky Cloud Observation Tool (MASCOT)
#
#  <B>MASCOT</B> stands for <B>M</B>ini <B>A</B>ll <B>S</B>ky <B>C</B>loud <B>O</B>bservation <B>T</B>ool.
#  Its purpose is to make images of the whole night sky over the Observatory in order to permit to evaluate the night sky quality.
#  The observations are made automatically and are available in FITS format as well as in JPEG format.
#
#  Some help :
#  - design manual <A HREF="mascot.pdf"><B>ALL SKY CLOUD DETECTION SYSTEM</B></A>
#  - functions @ref ::cmaude
#

#============================================================
#===   Definition of namespace cmaude to create a panel   ===
#============================================================

## @namespace cmaude
#  @brief Acquisition des images pour un Cloud Monitor - Outil Acquisition MASCOT
namespace eval ::cmaude {
   package provide cmaude 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] cmaude.cap ]

   #================================================================
   #===   Definition of automatic functions to build the panel   ===
   #================================================================

   #------------------------------------------------------------
   ## @brief  Retourne le titre du plugin dans la langue de l'utilisateur
   #  @return Titre du plugin
   #
   proc getPluginTitle { } {
      return $::caption(cmaude,titre_mascot)
   }

   #------------------------------------------------------------
   ## @brief  Retourne le nom du fichier d'aide principal
   #  @return Nom du fichier d'aide principal : "cmaude.htm"
   #
   proc getPluginHelp { } {
      return "cmaude.htm"
   }

   #------------------------------------------------------------
   ## @brief  Retourne le type de plugin
   #  @return Type de plugin : "tool"
   #
   proc getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   ## @brief  Retourne le nom du répertoire du plugin
   #  @return Nom du répertoire du plugin : "cmaude"
   #
   proc getPluginDirectory { } {
      return "cmaude"
   }

   #------------------------------------------------------------
   ## @brief  Retourne le ou les OS de fonctionnement du plugin
   #  @return Liste des OS : "Windows Linux Darwin"
   #
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
   }

   #------------------------------------------------------------
   ## @brief   Retourne les propriétés de l'outil
   #  @details Cet outil s'ouvre dans une fenêtre indépendante à partir du menu Caméra
   #  @param   propertyName Nom de la propriété
   #  @return  Valeur de la propriété ou "" si la propriété n'existe pas
   #
   proc getPluginProperty { propertyName } {
      switch $propertyName {
         function     { return "acquisition" }
         subfunction1 { return "" }
         display      { return "panel" }
         default      { return "" }
      }
   }

   #------------------------------------------------------------
   ## @brief  Crée une nouvelle instance de l'outil
   #  @param  base   Base Tk
   #  @param  visuNo Numéro de la visu
   #  @return Chemin de la fenêtre
   #
   proc createPluginInstance { base { visuNo 1 } } {
      #--- Initialisation des variables
      initConf

      #--- Je selectionne les mots cles selon les exigences de l'outil
      ::cmaude::configToolKeywords $visuNo

      ::console::affiche_prompt "-----------------------------------------\n"
      ::console::affiche_prompt "| $::caption(cmaude,titre_mascot)\n"
      ::console::affiche_prompt "-----------------------------------------\n"
      ::console::affiche_prompt "| Mini\n"
      ::console::affiche_prompt "| All\n"
      ::console::affiche_prompt "| Sky\n"
      ::console::affiche_prompt "| Cloud\n"
      ::console::affiche_prompt "| Observation\n"
      ::console::affiche_prompt "| Tool\n"
      ::console::affiche_prompt "-----------------------------------------\n\n"

      createPanel $base.cmaude
      return $base.cmaude

   }

   #------------------------------------------------------------
   ## @brief   Initialise les variables de configuration dans le tableau \::conf(...)
   #  @details Les variables \::conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - \::conf(cmaude,observatoire)      définit le choix de l'observatoire (1 = Observatoire de Paranal, 2 = Observatoire de Dax)
   #  - \::conf(cmaude,clarte_image_jpg)  définit la luminosité de l'image jpeg (1 = image sombre, 2 = image claire)
   #  - \::conf(cmaude,keywordConfigName) définit la configuration des mots clés pour les acquisitions
   #
   proc initConf { } {
      if { ! [ info exists ::conf(cmaude,observatoire) ] }      { set ::conf(cmaude,observatoire)      "2" }
      if { ! [ info exists ::conf(cmaude,clarte_image_jpg) ] }  { set ::conf(cmaude,clarte_image_jpg)  "2" }
      if { ! [ info exists ::conf(cmaude,keywordConfigName) ] } { set ::conf(cmaude,keywordConfigName) "default" }
   }

   #------------------------------------------------------------
   ## @brief Suppprime l'instance du plugin
   #  @param visuNo Numéro de la visu
   #
   proc deletePluginInstance { visuNo } {
      variable This

      #--- Je verifie si une operation est en cours
      if { $::panneau(cmaude,acquisition) == 1 } {
         return -1
      }

      #--- Je supprime la liste des mots clefs non modifiables
      ::keyword::setKeywordState $visuNo $::conf(cmaude,keywordConfigName) [ list ]
   }

   #------------------------------------------------------------
   ## @brief Crée la fenêtre de l'outil
   #  @param this Chemin Tk de la fenêtre
   #
   proc createPanel { this } {
      variable This
      variable cmconf

      #--- Initialisation de l'heure TU ou TL
      set now [::audace::date_sys2ut now]
      #--- Recuperation du repertoire dedie aux images et de l'extension des images
      set cmconf(folder)    $::audace(rep_images)
      set cmconf(extension) $::conf(extension,defaut)
      set This $this
      #--- Initialisation du compteur des images
      set ::compteur "1"
      #--- Hauteur du Soleil pour lancer les acquisitions (en degres)
      set cmconf(haurore) -10
      #--- Fin du crepuscule astronomique ou debut de la 'vraie' nuit (en degres)
      set cmconf(hastwilight) -18

      #--- Configuration de l'observatoire de Paranal
      if { $::conf(cmaude,observatoire) == "1" } {
         #--- Hauteur de la Lune pour laquelle elle ne gene pas l'observation (en degres)
         set cmconf(hmooncritic) 7
         #--- Mot cle FITS
         set cmconf(fits,OPTICS) "180 Degrees Fisheye Lens"
         #--- Fenetrage en binning 1x1 - La dimension de l'image doit rester de 580x512
         set cmconf(win11) {106 1 685 512}
         #--- Fenetrage en binning 2x2
         set cmconf(win22) {53 1 343 256}
         #--- Initialisation du binning
         set cmconf(binning) 1x1
         #--- Initialisation de l'intervalle entre images (en secondes)
         set cmconf(rythm) 10
         #--- Initialisation du temps de pose sans la Lune (en secondes)
         set cmconf(exptime1) 120
         #--- Initialisation du temps de pose avec la Lune ou pendant le crepuscule (secondes)
         set cmconf(exptime2) 15
      #--- Configuration de l'observatoire de Dax
      } elseif { $::conf(cmaude,observatoire) == "2" } {
         #--- Hauteur de la Lune pour laquelle elle ne gene pas l'observation (en degres)
         set cmconf(hmooncritic) 12
         #--- Mot cle FITS
         set cmconf(fits,OPTICS) "180 Degrees Fisheye Lens"
         #--- Fenetrage en binning 1x1 - La dimension de l'image doit rester de 580x512
         set cmconf(win11) {1 1 768 512}
         #--- Fenetrage en binning 2x2
         set cmconf(win22) {5 1 696 520}
         #--- Initialisation du binning
         set cmconf(binning) 1x1
         #--- Initialisation de l'intervalle entre images (en secondes)
         set cmconf(rythm) 2
         #--- Initialisation du temps de pose sans la Lune (en secondes)
         set cmconf(exptime1) 30
         #--- Initialisation du temps de pose avec la Lune ou pendant le crepuscule (secondes)
         set cmconf(exptime2) 10
      }

      #--- Initialisation de variables
      set ::panneau(cmaude,titre)           $::caption(cmaude,titre_mascot)
      set ::panneau(cmaude,aide)            $::caption(cmaude,help_titre)
      set ::panneau(cmaude,aide1)           $::caption(cmaude,help_titre1)
      set ::panneau(cmaude,config)          $::caption(cmaude,configuration)
      set ::panneau(cmaude,parcourir)       $::caption(cmaude,parcourir)
      set ::panneau(cmaude,label_bias)      $::caption(cmaude,bias)
      set ::panneau(cmaude,bias)            [ file join $cmconf(folder) bias off_synth$cmconf(extension) ]
      set ::panneau(cmaude,label_dark)      $::caption(cmaude,dark)
      set ::panneau(cmaude,dark)            [ file join $cmconf(folder) dark dark_synth$cmconf(extension) ]
      set ::panneau(cmaude,label_overlay)   $::caption(cmaude,overlay)
      set ::panneau(cmaude,overlay)         [ file join $cmconf(folder) overlay overlay$cmconf(extension) ]
      set ::panneau(cmaude,label_dirlast)   $::caption(cmaude,images_www)
      #--- tu peux mettre en dur la librairie de sortie pour le last.jpg dans la ligne : set ::panneau(cmaude,dirlast)...
      #--- comme par exemple : set ::panneau(cmaude,dirlast) "C:\Users\hfosaf\Desktop\maderniereimage.jpg"
      set ::panneau(cmaude,dirlast)         [ file join $cmconf(folder) last.jpg ]
      set ::panneau(cmaude,label_nom)       $::caption(cmaude,nom_image)
      set ::panneau(cmaude,nom)             [ file join $cmconf(folder) "[string range [mc_date2jd $now] 0 6]-" ]
      set ::panneau(cmaude,label_page_html) $::caption(cmaude,page_html)
      set ::panneau(cmaude,page_html)       "0"
      set ::panneau(cmaude,label_binning)   $::caption(cmaude,binning)
      set ::panneau(cmaude,binning)         $cmconf(binning)
      set ::panneau(cmaude,list_binning)    "1x1 2x2"
      set ::panneau(cmaude,label_time)      $::caption(cmaude,temps_pose)
      set ::panneau(cmaude,time)            $cmconf(exptime1)
      set ::panneau(cmaude,label_rythm)     $::caption(cmaude,entre_2_images)
      set ::panneau(cmaude,rythm)           $cmconf(rythm)
      set ::panneau(cmaude,go)              $::caption(cmaude,go_acquisition)
      set ::panneau(cmaude,stop)            $::caption(cmaude,stop)
      set ::panneau(cmaude,ephem)           $::caption(cmaude,ephemerides)
      set ::panneau(cmaude,label_status)    $::caption(cmaude,status)
      set ::panneau(cmaude,status)          $::caption(cmaude,status1)
      set ::panneau(cmaude,status2)         $::caption(cmaude,status2)
      set ::panneau(cmaude,status3)         $::caption(cmaude,status2)
      set ::panneau(cmaude,acquisition)     "0"
      set ::panneau(cmaude,initCompteur)    "0"

      #--- Construction de l'interface
      cmaudeBuildIF $This
   }

   #=======================================================
   #===   Definition of fonctions to run in the panel   ===
   #=======================================================

   #------------------------------------------------------------
   ## @brief Procédure appelée par appui sur le bouton "GO"
   #
   proc cmdGo { } {
      variable This
      variable cmconf

      if { [ ::cam::list ] != "" } {
         set ::panneau(cmaude,acquisition) "1"
         $This.fra2.but1 configure -relief groove -state disabled
         #--- Initialisation de l'heure TU ou TL
         set now [::audace::date_sys2ut now]
         set ::loopexit "0"
         ::console::affiche_erreur "###############################\n"
         ::console::affiche_erreur "$::caption(cmaude,debut_script)\n"
         set ::namelog [string range [mc_date2jd $now] 0 6]

         #--- Recuperation de la position de l'observateur
         set cmconf(localite) $::audace(posobs,observateur,gps)
         set localite $cmconf(localite)

         #--- Altitude of the sun under horizon for which one considers it's night
         set haurore $cmconf(haurore)

         #--- Some astronomical parameters
         set ladate [mc_date2jd $now]

         set datheur [mc_date2ymdhms $ladate]
         set hautsol [lindex [mc_ephem sun [list [mc_date2tt $ladate]] {altitude} -topo $localite] 0]
         set azimsol [lindex [mc_ephem sun [list [mc_date2tt $ladate]] {azimuth} -topo $localite] 0]
         ::console::affiche_erreur "###############################\n"
         ::console::affiche_erreur "$::caption(cmaude,il_est) $datheur $::caption(cmaude,TU)\n"
         ::console::affiche_erreur "$::caption(cmaude,jour_julien) $ladate\n"
         ::console::affiche_erreur "$::caption(cmaude,position_soleil)\n"
         ::console::affiche_erreur "$::caption(cmaude,hauteur) [string range $hautsol 0 5]°\n"
         ::console::affiche_erreur "$::caption(cmaude,azimut) [string range $azimsol 0 5]°\n"
         set phaslun [lindex [mc_ephem moon [list [mc_date2tt $ladate]] {phase} -topo $localite] 0]
         set cmconf(phaslun) $phaslun
         ::console::affiche_erreur "$::caption(cmaude,phase_lune) [string range $phaslun 0 5]°\n"
         set illufrac [expr 100 * (0.5 + 0.5 * cos ($phaslun / 180. * 3.1415))]
         set cmconf(illufrac) $illufrac
         ::console::affiche_erreur "$::caption(cmaude,illumine_lune) ~[expr int($illufrac)]%\n"

         #--- Infinite loop running the automatic acquisition sequence (simulated)
         #--- Begins by calculating the parameters of sunset and sunrise for the current day
         #--- This loop ends by pushing STOP (change "::loopexit" value to 1)

         while { 1 == 1 } {
            if { $::loopexit == "1" } {
               break
            }
            set ::panneau(cmaude,status) $::caption(cmaude,execution_auto)
            $This.fra3.lab2 configure -text $::panneau(cmaude,status)

            #--- Calculate 'jd_deb', le julian day corresponding to the beginning
            #--- of the night (sun altitude equals "haurore")

            set date1 [mc_date2ymdhms [mc_date2jd $now]]
            if { [lindex $date1 3] < "6" } {
               set date1 [mc_date2ymdhms [mc_date2jd now0]]
            } else {
               set date1 [mc_date2ymdhms [mc_date2jd now1]]
            }
            set amj "[lindex $date1 0] [lindex $date1 1] [lindex $date1 2]"
            set jd_deb [mc_date2jd $amj ]
            for { set jj [expr $jd_deb-0.5] } { $jj < [expr $jd_deb] } { set jj [expr $jj+0.001] } {
               set hauteur [lindex [mc_ephem sun [list [mc_date2tt $jj]] {altitude} -topo $localite] 0]
               set result "[mc_date2ymdhms $jj] => h= $hauteur degres "
               if { $hauteur < $haurore } {
                  break
               }
            }
            set jd_deb               "$jj"
            set resultb              "$::caption(cmaude,debut_nuit) [mc_date2iso8601 $jd_deb] $::caption(cmaude,TU)\n"
            set cmconf(resultb)      $resultb
            set resultbhtml          "$::caption(cmaude,debut_nuit_1) [mc_date2iso8601 $jd_deb] $::caption(cmaude,TU)\n"
            set cmconf(resultbhtml)  $resultbhtml
            set cmconf(resultbhtml1) "[mc_date2iso8601 $jd_deb]\n"

            ::console::affiche_erreur "$::caption(cmaude,hauteur_soleil_debut_nuit) < $cmconf(haurore)°\n"
            ::console::affiche_erreur "$resultb"
            ::console::affiche_erreur "$::caption(cmaude,jour_julien) = $jd_deb\n"

            #--- Calculate 'jd_fin', the julian day corresponding to the end
            #--- of the night (sun altitude equals "haurore")

            set date1 [mc_date2ymdhms [mc_date2jd $now]]
            if { [lindex $date1 3] < "6" } {
               set date1 [mc_date2ymdhms [mc_date2jd now0]]
            } else {
               set date1 [mc_date2ymdhms [mc_date2jd now1]]
            }
            set amj "[lindex $date1 0] [lindex $date1 1] [lindex $date1 2]"
            set jd_fin [mc_date2jd $amj ]
            for { set jj $jd_fin } { $jj < [expr $jd_fin+0.5] } { set jj [expr $jj+0.001] } {
               set hauteur [lindex [mc_ephem sun [list [mc_date2tt $jj]] {altitude} -topo $localite] 0]
               if { $hauteur > $haurore } {
                   break
               }
            }
            set jd0                  "$jd_fin"
            set jd_fin               "$jj"
            set resulte              "$::caption(cmaude,fin_nuit) [mc_date2iso8601 $jd_fin] $::caption(cmaude,TU)\n"
            set cmconf(resulte)      $resulte
            set resultehtml          "$::caption(cmaude,fin_nuit_1) [mc_date2iso8601 $jd_fin] $::caption(cmaude,TU)\n"
            set cmconf(resultehtml)  $resultehtml
            set cmconf(resultehtml1) "[mc_date2iso8601 $jd_fin]\n"

            ::console::affiche_erreur "$resulte"
            ::console::affiche_erreur "$::caption(cmaude,jour_julien) = $jd_fin\n"
            ::console::affiche_erreur "###############################\n\n"

            #--- Waiting for the night
            set actuel [mc_date2jd $now]

            while { [mc_date2jd $now] <= $jd_deb } {
            #--- Test to exit the loop if push on STOP
               if { $::loopexit == "1" } {
                  break
               }
               #--- Bouclage sur l'heure systeme
               set now [::audace::date_sys2ut now]
               update
               set actuel [mc_date2jd $now]
               ::console::affiche_erreur "$::caption(cmaude,il_est_maintenant) [string range [mc_date2iso8601 $actuel] 11 20] $::caption(cmaude,TU)\n"
               ::console::affiche_erreur "$::caption(cmaude,attendre_nuit_a) [string range [mc_date2iso8601 $jd_deb] 11 20] $::caption(cmaude,TU)\n"
               ::console::affiche_erreur "$::caption(cmaude,decompte) ### [string range [mc_date2iso8601 [format "%f" [expr $jd_deb - $actuel]]] 11 18] ###\n\n"
               #--- Delay of the waiting loop in seconds
               set delayloop "60"
               set flag [expr [expr $delayloop / 86400.0] + [mc_date2jd $now]]
               #--- Waiting loop
               while { $actuel <= $flag } {
                  if { $::loopexit == "1" } {
                     $This.fra2.but2 configure -relief raised -state normal
                     break
                  }
                  #--- Bouclage sur l'heure systeme
                  set now [::audace::date_sys2ut now]
                  update
                  set actuel [mc_date2jd $now]
                  set ::panneau(cmaude,status2) $::caption(cmaude,attendre_nuit)
                  $This.fra3.labURL3 configure -text $::panneau(cmaude,status2)
                  set ::panneau(cmaude,status3) "$::caption(cmaude,decompte) [string range [mc_date2iso8601 [format "%f" [expr $jd_deb - $actuel]]] 11 18]"
                  $This.fra3.labURL4 configure -text $::panneau(cmaude,status3)
                  update
               }
            }
            if { $::loopexit == "0" } {
               ::console::affiche_prompt "$::caption(cmaude,nuit_a_commencee)\n"
               ::console::affiche_prompt "$::caption(cmaude,debut_acquisition)\n\n"
               #--- Writing the observation Log
               set ::namelog [string range [mc_date2jd $now] 0 6]
               catch {
                  set fileId [open $cmconf(folder)/$::namelog.log a]
                  set textlog "$::caption(cmaude,observation_log) [string range [mc_date2jd $now] 0 6] $::caption(cmaude,ou) [string range [mc_date2iso8601 $actuel] 0 9]\n\n"
                  append textlog "$::caption(cmaude,hauteur_soleil_debut_nuit) < $haurore°\n\n"
                  append textlog $resultb
                  append textlog $resulte
                  puts $fileId $textlog
                  close $fileId
               }
            }

            #--- Night has come, acquisitions beginning (simulation)
            #--- Waiting for the day to end the acquisitions

            set actuel [mc_date2jd $now]

            set ::panneau(cmaude,status2) $::caption(cmaude,status2)
            $This.fra3.labURL3 configure -text $::panneau(cmaude,status2)

            while { [mc_date2jd $now] <= $jd_fin } {
               set ::panneau(cmaude,status2) $::caption(cmaude,boucle_acquisition)
               $This.fra3.labURL3 configure -text $::panneau(cmaude,status2)
               #--- Test to exit the loop if push on STOP
               if { $::loopexit == "1" } {
                  #--- Surveillance de l'intialisation du compteur
                  if { $::panneau(cmaude,initCompteur) == "1" } {
                     set ::compteur "1"
                     set ::panneau(cmaude,initCompteur) "0"
                  }
                  break
               }
               #--- Acquisition procedure
               ::cmaude::cmdAcq
               incr ::compteur
               #--- Bouclage sur l'heure systeme
               set now [::audace::date_sys2ut now]
               update
               set actuel [mc_date2jd $now]
               set flag [expr [expr $::panneau(cmaude,rythm) / 86400.0] + $actuel]
               $This.fra2.but2 configure -relief groove -state disabled
               #--- Loop waiting to take the following image
               while { $actuel <= $flag } {
                  if { $::loopexit == "1" } {
                     break
                  }
                  #--- Bouclage sur l'heure systeme
                  set now [::audace::date_sys2ut now]
                  update
                  set actuel [mc_date2jd $now]
                  set ::panneau(cmaude,status3) "$::caption(cmaude,prochaine_image) [string range [mc_date2iso8601 [format "%f" [expr $flag - $actuel]]] 11 18]"
                  $This.fra3.labURL4 configure -text $::panneau(cmaude,status3)
                  update
               }
               $This.fra2.but2 configure -relief raised -state normal
            }
            if { $::loopexit == "0" } {
               ::console::affiche_prompt "$::caption(cmaude,jour_a_commence)\n"
               ::console::affiche_prompt "$::caption(cmaude,nbre_image_nuit) [expr $::compteur-1]\n\n"
               set textlog "\n$::caption(cmaude,fin_observation) [string range [mc_date2iso8601 $actuel] 0 9] $::caption(cmaude,a) [string range [mc_date2iso8601 $actuel] 11 20] $::caption(cmaude,TU)\n\n"
               catch {
                  set fileId [open $cmconf(folder)/$::namelog.log a]
                  append textlog "$::caption(cmaude,nbre_image_nuit) [expr $::compteur-1]\n"
                  puts $fileId $textlog
                  close $fileId
               }
               set ::compteur "1"
               set ::panneau(cmaude,nom) "$cmconf(folder)"
               ::console::affiche_prompt "$::caption(cmaude,calcul_parametres)\n\n"
               ::console::affiche_erreur "###############################\n"
            }
            #--- Day has come, the loop re-run beginning with
            #--- the calculation of the parameters for the following day
         #--- End of infinite loop
         }
         ::console::affiche_erreur "###############################\n"
         ::console::affiche_erreur "$::caption(cmaude,fin_boucle_acquisition)\n"
         ::console::affiche_erreur "###############################\n\n"
         set ::panneau(cmaude,status2) $::caption(cmaude,pas_activite)
         $This.fra3.labURL3 configure -text $::panneau(cmaude,status2)
         set ::panneau(cmaude,status3) $::caption(cmaude,status2)
         $This.fra3.labURL4 configure -text $::panneau(cmaude,status3)
         set dateend [mc_date2iso8601 now]
         catch {
            set fileId [open $cmconf(folder)/$::namelog.log a]
            puts $fileId "\n$::caption(cmaude,fin_boucle_acquisition_a) $dateend !\n"
            close $fileId
         }
         set ::panneau(cmaude,acquisition) "0"
         $This.fra2.but1 configure -relief raised -state normal
      } else {
         ::confCam::run
      }
   #--- End of proc cmdGO
   }

   #------------------------------------------------------------
   ## @brief Procédure appelée par appui sur le bouton "STOP"
   #
   proc cmdStop { } {
      variable This

      if { [ ::cam::list ] != "" } {
         $This.fra2.but2 configure -relief groove -state disabled
         #--- Initialisation a la demande du compteur des images
         set choix [ tk_messageBox -type yesno -icon warning -title $::caption(cmaude,initialisation) \
            -message $::caption(cmaude,texte_init) ]
         if { $choix == "yes" } {
            set ::panneau(cmaude,initCompteur) "1"
         } else {
            set ::panneau(cmaude,initCompteur) "0"
         }
         #---
         set ::loopexit "1"
         set ::panneau(cmaude,status) $::caption(cmaude,arret_auto_script)
         $This.fra3.lab2 configure -text $::panneau(cmaude,status)
      } else {
         ::confCam::run
      }
   }

   #------------------------------------------------------------
   ## @brief Procédure d'acquisition des images
   #
   proc cmdAcq { } {
      variable This
      variable cmconf

      #--- Initialisation de l'heure TU ou TL
      set now [::audace::date_sys2ut now]
      #--- Acquisition of an image
      set actuel [mc_date2jd $now]
      #--- Test of the astronomical twilight and of the presence of the Moon
      #--- and adapt the right exposure time
      #--- Recuperation de la position de l'observateur
      set cmconf(localite) $::audace(posobs,observateur,gps)
      set localite "$cmconf(localite)"
      set highsun [lindex [mc_ephem sun [list [mc_date2tt $actuel]] {altitude} -topo $localite] 0]
      set highmoon [lindex [mc_ephem moon [list [mc_date2tt $actuel]] {altitude} -topo $localite] 0]
      ::console::affiche_erreur "\n"

      #--- Reinit temporaire du temps de pose utilisateur sinon les tests suivants ne font pas de reset lorsque les conditions redeviennent normales (FL 01/2012)
      #--- ils sont sans clause else
      set ::panneau(cmaude,time) "$cmconf(exptime1)"
      ::console::affiche_erreur "$::caption(cmaude,hauteur_soleil) = [string range $highsun 0 4]°\n"
      if { $highsun > $cmconf(hastwilight) } {
         ::console::affiche_erreur "$::caption(cmaude,au-dessus) $cmconf(hastwilight)°\n"
         ::console::affiche_erreur "$::caption(cmaude,hauteur_limite_soleil)\n"
         set ::panneau(cmaude,time) "$cmconf(exptime2)"
      }
      ::console::affiche_erreur "$::caption(cmaude,hauteur_lune) = [string range $highmoon 0 4]°\n"
      if { $highmoon > $cmconf(hmooncritic) } {
         ::console::affiche_erreur "$::caption(cmaude,au-dessus) $cmconf(hmooncritic)°\n"
         ::console::affiche_erreur "$::caption(cmaude,hauteur_critique_lune)\n"
         set ::panneau(cmaude,time) "$cmconf(exptime2)"
      }

      ::console::affiche_erreur "$::caption(cmaude,acquisition_lance)\n"
      ::cmaude::acq $::panneau(cmaude,time) $::panneau(cmaude,binning)
      set nameima "[string range [mc_date2jd $now] 0 6]-$::compteur$cmconf(extension)"
      set cmconf(nameima) [ file join $cmconf(folder) [string range [mc_date2jd $now] 0 6]-$::compteur ]
      set sidertime [ mc_date2lst now $localite ]
      #--- Specific keywords
      buf$::audace(bufNo) setkwd [ list "OPTICS"   $cmconf(fits,OPTICS)   string "Type of optics used" " " ]
      buf$::audace(bufNo) setkwd [ list "SIDERAL"  $sidertime             string "Local Sideral Time" " " ]

      set textima "$::caption(cmaude,image) $nameima $::caption(cmaude,acquise_le) [string range [mc_date2iso8601 $actuel] 0 9] $::caption(cmaude,a) [string range [mc_date2iso8601 $actuel] 11 18] $::caption(cmaude,TU)"
      ::console::affiche_erreur "$textima\n"
      ::console::affiche_erreur "$::caption(cmaude,posee) $::panneau(cmaude,time) $::caption(cmaude,seconde) - $::caption(cmaude,binning) $::panneau(cmaude,binning)\n"

      #--- Pre-processing
      ::console::affiche_erreur "$::caption(cmaude,pretraitement)\n"
      catch { opt $::panneau(cmaude,dark) $::panneau(cmaude,bias) } msg1
      # ::console::disp "$msg1\n"
      if { $::panneau(cmaude,binning) == "1x1" } {
         #--- Cut of the image to gain space and avoid the black part around
         buf$::audace(bufNo) window $cmconf(win11)
      } elseif { $::panneau(cmaude,binning) == "2x2" } {
         #--- Cut of the image to gain space and avoid the black part around
         buf$::audace(bufNo) window $cmconf(win22)
      }
      #--- Add the image "overlay.extension" with orientation info and logo
      catch { add $::panneau(cmaude,overlay) 0 } msg2
      # ::console::disp "$msg2\n"
      #--- Update the name of the file in the title
      ::confVisu::setFileName $::audace(visuNo) $nameima
      #--- Save FITS image
      saveima $nameima

      #--- Overlay date and time in the JPG Image
      #--- Warning: Run only with Windows
      if { $::tcl_platform(platform) == "windows" } {
         catch {
            #-- I load the image in the buffer
            buf$::audace(bufNo) load [ file join $::audace(rep_images) $nameima ]
            #--- I recover the date + time of the FITS Image
            set dateObs [ buf$::audace(bufNo) getkwd DATE-OBS ]
            if { [ lindex $dateObs 0 ] == "" } {
               error "DATE-OBS $::caption(cmaude,msg_erreur) [ file join $::audace(rep_images) $nameima ]"
            }
            set stringDate [ lindex $dateObs 1 ]
            # ::console::disp "$stringDate\n"
            #--- I delete the output file in case it already exists
            file delete "[ file rootname [ file join $::audace(rep_images) $nameima ] ].jpg"
            #--- Execute the conversion to JPG with incustation date
            #--- Program nconvert.exe
            #--- To display help of nconvert.exe, you have to open a DOS window
            #--- will move to the directory of nconvert and enter "nconvert -help"
            #--- To have this help in a file, enter "nconvert -help > help.txt"
            #--- Verifies that the OS is a 32 or 64 bit
           # set version [ lindex [ ::registry get "HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0" Identifier] 0 ]
           # if { $version == "x86" } {
           #    #--- Initialize the way 32-bit conversion program
           #    set program_exe "nconvert_32_v670.exe"
           # } else {
           #    #--- Initialize the way 64-bit conversion program
           #    set program_exe "nconvert_64_v670.exe"
           # }
            #--- File names
            set inputFile  [ file join $::audace(rep_images) $nameima ]
            set outputFile "[ file rootname [ file join $::audace(rep_images) $nameima ] ].jpg"
            #--- Save image jpg with date & time incrustation
            set program_exe "nconvert.exe"
            set program [ file join $::audace(rep_plugin) tool cmaude $program_exe ]
            exec $program -in -1 -o $outputFile -out jpeg -ctype rgb -autocontrast -text_font "system" 30 -text_color 0 255 0 -text_back 0 0 0 -text_flag "bottom-left" -text $stringDate $inputFile
         } msg3
         # ::console::disp "$msg3\n"
         #--- If msg does not contain 'OK'
         if { [ string first "OK" $msg3 ] == "-1" } {
            #--- Displays the error message nconvert
            tk_messageBox -title "$::caption(cmaude,erreur)" -icon error -type ok -message $msg3
            ::console::disp "$::errorInfo\n"
         } else {
            #--- L'image JPG affichee dans Aud'ACE n'est pas belle, mais elle est belle dans l'apercu de Windows,
            #--- pour rendre son affichage beau dans Aud'ACE il faut jouer avec les seuils RVB
            #--- pour qu'elle soit belle dans Aud'ACE il faut supprimer le parametre "-autocontrast" dans la ligne 30 de ce script,
            #--- mais elle sera sombre dans l'apercu de Windows
            #--- commentaires rajoutes apres discussion avec Michel
            loadima "[ file rootname [ file join $::audace(rep_images) $nameima ] ].jpg"
         }
      }

      #-- Save image jpg for www (dark or clear)
      set namelastjpg [file root $::panneau(cmaude,dirlast)]
      if { $::conf(cmaude,clarte_image_jpg) == "1" } {
         file copy -force [ file join $::audace(rep_images) $outputFile ] [ file join $::audace(rep_images) $namelastjpg.jpg ]
      } elseif { $::conf(cmaude,clarte_image_jpg) == "2" } {
         sauve_jpeg $namelastjpg
      }

      #---
      ::console::affiche_erreur "$::caption(cmaude,image_sauvee)\n"
      ::console::affiche_erreur "\n"
      ::console::affiche_erreur "$::caption(cmaude,prochaine_image_dans) $::panneau(cmaude,rythm) $::caption(cmaude,secondes)\n"
      ::console::affiche_erreur "\n\n"
      set ::panneau(cmaude,nom) "$cmconf(folder)[string range [mc_date2jd $now] 0 6]-$::compteur"
      $This.fra3.lab2 configure -text $::panneau(cmaude,status)
      #--- Writing the observation Log and html file
      if { $::panneau(cmaude,page_html) == "1" } {
         set cmconf(date_debut_pose) $stringDate
         if { $::conf(cmaude,observatoire) == "1" } {
            source [ file join $::audace(rep_plugin) tool cmaude cmaude_makehtml.tcl ]
         } elseif { $::conf(cmaude,observatoire) == "2" } {
            source [ file join $::audace(rep_plugin) tool cmaude cmaude_makehtml_Dax.tcl ]
         }
      }
      catch {
         set fileId [open $cmconf(folder)/$::namelog.log a]
         puts $fileId $textima
         close $fileId
      }
   }

   #------------------------------------------------------------
   ## @brief L'acquisition
   #  @param exptime Temps d'exposition
   #  @param binning Binning
   #
   proc acq { exptime binning } {
      variable This

      #--- Petit raccourci
      set ::numcam [ ::confCam::getCamNo [::confVisu::getCamItem $::audace(visuNo)] ]

      #--- Initialisation du fenetrage
      catch {
         set n1n2 [ cam$::numcam nbcells ]
         cam$::numcam window [ list 1 1 [ lindex $n1n2 0 ] [ lindex $n1n2 1 ] ]
      }

      #--- La commande exptime permet de fixer le temps de pose de l'image
      cam$::numcam exptime $exptime

      #--- La commande bin permet de fixer le binning
      set binalors [ string range $::panneau(cmaude,binning) 0 0 ]
      cam$::numcam bin [list $binalors $binalors]

      #--- Declenchement de l'acquisition
      cam$::numcam acq

      #--- Alarme sonore de fin de pose
      ::camera::alarmeSonore $exptime

      #--- Annonce Timer
      if { $exptime > "1" } {
         ::cmaude::dispTime $This.fra3.labURL4 "#FF0000"
      }

      #--- Attente de la fin de la pose
      ::camera::waitStateStand $::numcam

      #--- Rajoute des mots cles dans l'en-tete FITS
      foreach keyword [ ::keyword::getKeywords $::audace(visuNo) $::conf(cmaude,keywordConfigName) ] {
         buf$::audace(bufNo) setkwd $keyword
      }

      #--- Mise a jour du nom du fichier dans le titre et de la fenetre de l'en-tete FITS
      ::confVisu::setFileName $::audace(visuNo) ""

      #--- Visualisation
      ::audace::autovisu $::audace(visuNo)
   }

   #------------------------------------------------------------
   ## @brief Configuration des mots clés FITS
   #  @param visuNo     Numéro de la visu
   #  @param configName Nom de la configuration
   #
   proc configToolKeywords { visuNo { configName "" } } {
      #--- Je traite la variable configName
      if { $configName == "" } {
         set configName $::conf(cmaude,keywordConfigName)
      }

      #--- Je selectionne les mots cles optionnels a ajouter dans les images
      #--- Ce sont les mots cles CRPIX1, CRPIX2
      ::keyword::selectKeywords $visuNo $configName [ list CRPIX1 CRPIX2 ]

      #--- Je selectionne la liste des mots cles non modifiables
      ::keyword::setKeywordState $visuNo $configName [ list CRPIX1 CRPIX2 ]
   }

   #------------------------------------------------------------
   ## @brief Décompte de l'acquisition
   #  @param labelTime  Décompte ou statut de l'acquisition
   #  @param colorLabel Couleur d'affichage de l'information
   #
   proc dispTime { labelTime colorLabel } {
      set t [ cam$::numcam timer -1 ]

      if { $t > "1" } {
         $labelTime configure -text "[ expr $t-1 ] / [ format "%d" [ expr int([ cam$::numcam exptime ]) ] ]" \
            -fg $colorLabel
         after 1000 ::cmaude::dispTime $labelTime $colorLabel
      } else {
         $labelTime configure -text $::caption(cmaude,numerisation) -fg $colorLabel
      }
   }

   #------------------------------------------------------------
   ## @brief   Procédure appelée par appui sur le bouton "Ephémérides"
   #  @details Affichage dans la Console des éphémérides du Soleil et de la Lune pour le moment
   #
   proc cmdEphe { } {
      variable cmconf

      #--- Recuperation de la position de l'observateur
      set cmconf(localite) $::audace(posobs,observateur,gps)
      set localite "$cmconf(localite)"
      #--- Initialisation de l'heure TU ou TL
      set now [::audace::date_sys2ut now]
      set nownow [mc_date2jd $now]

      set datheur [mc_date2ymdhms $nownow]
      set hautsol [lindex [mc_ephem sun [list [mc_date2tt $nownow]] {altitude} -topo $localite] 0]
      set azimsol [lindex [mc_ephem sun [list [mc_date2tt $nownow]] {azimuth} -topo $localite] 0]

      set hautmoo [lindex [mc_ephem moon [list [mc_date2tt $nownow]] {altitude} -topo $localite] 0]
      set azimmoo [lindex [mc_ephem moon [list [mc_date2tt $nownow]] {azimuth} -topo $localite] 0]
      set elongmoo [lindex [mc_ephem moon [list [mc_date2tt $nownow]] {elong}] 0]
      set phaslun [lindex [mc_ephem moon [list [mc_date2tt $nownow]] {phase} -topo $localite] 0]
      set illufrac [expr 100 * (0.5 + 0.5 * cos ($phaslun / 180. * 3.1415))]
      set sidetime [mc_date2lst $nownow $localite]

      ::console::affiche_prompt "########## MASCOT #########\n"
      ::console::affiche_prompt "######## $::caption(cmaude,ephemerides) ########\n"
      ::console::affiche_prompt "###### $::caption(cmaude,date_courante) #####\n"
      ::console::affiche_prompt "$::caption(cmaude,date) [string range [mc_date2iso8601 $nownow] 0 9]\n"
      ::console::affiche_prompt "$::caption(cmaude,heure_tu) [string range [mc_date2iso8601 $nownow] 11 20]\n"
      ::console::affiche_prompt "$::caption(cmaude,jour_julien:) $nownow\n"
      ::console::affiche_prompt "$::caption(cmaude,temps_sideral) $sidetime\n"
      ::console::affiche_prompt "########### $::caption(cmaude,soleil) ##########\n"
      ::console::affiche_prompt "$::caption(cmaude,position_soleil)\n"
      ::console::affiche_prompt "$::caption(cmaude,hauteur) [string range $hautsol 0 5]°\n"
      ::console::affiche_prompt "$::caption(cmaude,azimut) [string range $azimsol 0 5]°\n"
      ::console::affiche_prompt "########### $::caption(cmaude,lune) ##########\n"
      ::console::affiche_prompt "$::caption(cmaude,position_lune)\n"
      ::console::affiche_prompt "$::caption(cmaude,hauteur) [string range $hautmoo 0 5]°\n"
      ::console::affiche_prompt "$::caption(cmaude,azimut) [string range $azimmoo 0 5]°\n"
      ::console::affiche_prompt "$::caption(cmaude,elongation_lune) [string range $elongmoo 0 4]°\n"
      ::console::affiche_prompt "$::caption(cmaude,phase_lune) [string range $phaslun 0 4]°\n"
      ::console::affiche_prompt "$::caption(cmaude,illumine_lune) [string range $illufrac 0 4]%\n"
      ::console::affiche_prompt "#########################\n\n"
   }

   #------------------------------------------------------------
   ## @brief Procédure appelée par appui surle bouton "..." (parcourir)
   #  @param option { 1 | 2 | 3 | 4} pour rechercher les bias, les dark, l'overlay ou le répertoire de sauvegarde
   #
   proc parcourir { option } {
      variable This

      #--- Parent window
      set fenetre $::audace(base)
      #--- Open the window to select images
      set filename [ ::tkutil::box_load $fenetre $::audace(rep_images) $::audace(bufNo) "1" ]
      #--- File name
      if { $option == "1" } {
         set ::panneau(cmaude,bias) $filename
         $This.fra2.fra4.ent1 xview end
      } elseif { $option == "2" } {
         set ::panneau(cmaude,dark) $filename
         $This.fra2.fra5.ent2 xview end
      } elseif { $option == "3" } {
         set ::panneau(cmaude,overlay) $filename
         $This.fra2.fra6.ent2a xview end
      } elseif { $option == "4" } {
         set ::panneau(cmaude,dirlast) $filename
         $This.fra2.fra7.entdirlast xview end
      }
   }

}

## namespace cmaude::config
#  @brief Fenêtre de configuration de l'outil Acquisition MASCOT

namespace eval ::cmaude::config {

   #------------------------------------------------------------
   ## @brief Initialisation des variables de configuration
   #
   proc initToConf { } {
   }

   #------------------------------------------------------------
   ## @brief Charge la configuration dans des variables locales
   #
   proc confToWidget { } {
   }

   #------------------------------------------------------------
   ## @brief Acquisition de la configuration, c'est à dire isolation des différentes variables dans le tableau \::conf(...)
   #
   proc widgetToConf { } {
   }

   #------------------------------------------------------------
   ## @brief Crée la fenêtre de configuration
   #
   proc run { } {
      variable This

      #---
      set This $::audace(base).cmaudeSetup
      ::confGenerique::run $::audace(visuNo) "$This" "::cmaude::config" -modal 0
      set posx_config [ lindex [ split [ wm geometry $::audace(base) ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::audace(base) ] "+" ] 2 ]
      wm geometry $This +[ expr $posx_config + 180 ]+[ expr $posy_config + 60 ]
   }

   #------------------------------------------------------------
   ## @brief Procédure "Appliquer" pour mémoriser et appliquer la configuration
   #  @param visuNo Numéro de la visu
   #
   proc cmdApply { visuNo } {
      variable cmconf

      #--- Configuration de l'observatoire de Paranal
      if { $::conf(cmaude,observatoire) == "1" } {
         #--- Hauteur de la Lune pour laquelle elle ne gene pas l'observation (en degres)
         set ::cmaude::cmconf(hmooncritic) 7
         #--- Mot cle FITS
         set ::cmaude::cmconf(fits,OPTICS) "180 Degrees Fisheye Lens"
         #--- Fenetrage en binning 1x1 - La dimension de l'image doit rester de 580x512
         set ::cmaude::cmconf(win11) {106 1 685 512}
         #--- Fenetrage en binning 2x2
         set ::cmaude::cmconf(win22) {53 1 343 256}
         #--- Initialisation du binning
         set ::cmaude::cmconf(binning) 1x1
         #--- Initialisation de l'intervalle entre images (en secondes)
         set ::cmaude::cmconf(rythm) 10
         #--- Initialisation du temps de pose sans la Lune (en secondes)
         set ::cmaude::cmconf(exptime1) 120
         #--- Initialisation du temps de pose avec la Lune ou pendant le crepuscule (secondes)
         set ::cmaude::cmconf(exptime2) 15
      #--- Configuration de l'observatoire de Dax
      } elseif { $::conf(cmaude,observatoire) == "2" } {
         #--- Hauteur de la Lune pour laquelle elle ne gene pas l'observation (en degres)
         set ::cmaude::cmconf(hmooncritic) 12
         #--- Mot cle FITS
         set ::cmaude::cmconf(fits,OPTICS) "180 Degrees Fisheye Lens"
         #--- Fenetrage en binning 1x1 - La dimension de l'image doit rester de 580x512
         set ::cmaude::cmconf(win11) {1 1 768 512}
         #--- Fenetrage en binning 2x2
         set ::cmaude::cmconf(win22) {5 1 696 520}
         #--- Initialisation du binning
         set ::cmaude::cmconf(binning) 1x1
         #--- Initialisation de l'intervalle entre images (en secondes)
         set ::cmaude::cmconf(rythm) 2
         #--- Initialisation du temps de pose sans la Lune (en secondes)
         set ::cmaude::cmconf(exptime1) 30
         #--- Initialisation du temps de pose avec la Lune ou pendant le crepuscule (secondes)
         set ::cmaude::cmconf(exptime2) 10
      }

      #--- Mise a jour des widgets
      set ::panneau(cmaude,time)  "$::cmaude::cmconf(exptime1)"
      set ::panneau(cmaude,rythm) "$::cmaude::cmconf(rythm)"

   }

   #------------------------------------------------------------
   ## @brief Procédure appelée lors de l'appui sur le bouton "Aide"
   #
   proc showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::cmaude::getPluginType ] ] \
         [ ::cmaude::getPluginDirectory ] cmaude.htm
   }

   #------------------------------------------------------------
   ## @brief Procédure appelée lors de l'appui sur le bouton "Fermer"
   #  @param visuNo Numéro de la visu
   #
   proc cmdClose { visuNo } {
   }

   #------------------------------------------------------------
   ## @brief  Retourne le titre de la fenêtre dans la langue de l'utilisateur
   #  @return Titre de la fenêtre
   #
   proc getLabel { } {
      return $::caption(cmaude,titre_config)
   }

   #------------------------------------------------------------
   ## @brief Création de l'interface graphique
   #  @param frm    Chemin Tk de la fenêtre
   #  @param visuNo Numéro de la visu
   #
   proc fillConfigPage { frm visuNo } {
      variable This

      #--- Frame pour l'en-tete FITS
      frame $This.frame3 -borderwidth 1 -relief raise

         #--- Label de l'en-tete FITS
         label $This.frame3.lab -text $::caption(cmaude,en-tete_fits)
         pack $This.frame3.lab -side left -padx 6

         #--- Bouton d'acces aux mots cles
         button $This.frame3.but -text $::caption(cmaude,mots_cles) \
            -command "::keyword::run $::audace(visuNo) ::conf(cmaude,keywordConfigName)"
         pack $This.frame3.but -side left -padx 6 -pady 10 -ipadx 20

         #--- Label du nom de la configuration de l'en-tete FITS
         entry $This.frame3.labNom \
            -state readonly -takefocus 0 -textvariable ::conf(cmaude,keywordConfigName) -justify center
         pack $This.frame3.labNom -side left -padx 6

      pack $This.frame3 -side top -fill both -expand 1

      #--- Frame pour le choix de l'observatoire
      frame $This.frame4 -borderwidth 1 -relief raise

         frame $This.frame4.1
            radiobutton $This.frame4.1.rad -text $::caption(cmaude,obsParanal) \
              -variable ::conf(cmaude,observatoire) -value 1
            pack $This.frame4.1.rad -side left
         pack $This.frame4.1 -expand true -fill x

         frame $This.frame4.2
            radiobutton $This.frame4.2.rad -text $::caption(cmaude,obsDax) \
               -variable ::conf(cmaude,observatoire) -value 2
            pack $This.frame4.2.rad -side left
         pack $This.frame4.2 -expand true -fill x

      pack $This.frame4 -side top -fill both -expand 1

      #--- Frame pour le choix de la clarte de l'image jpg
      frame $This.frame5 -borderwidth 1 -relief raise

         frame $This.frame5.1
            label $This.frame5.1.lab -text $::caption(cmaude,images_www)
            pack $This.frame5.1.lab -side left -padx 6
         pack $This.frame5.1 -expand true -fill x

         frame $This.frame5.2
            radiobutton $This.frame5.2.rad1 -text $::caption(cmaude,sombre) \
              -variable ::conf(cmaude,clarte_image_jpg) -value 1
            pack $This.frame5.2.rad1 -side left
            radiobutton $This.frame5.2.rad2 -text $::caption(cmaude,claire) \
               -variable ::conf(cmaude,clarte_image_jpg) -value 2
            pack $This.frame5.2.rad2 -side left
         pack $This.frame5.2 -expand true -fill x

      pack $This.frame5 -side top -fill both -expand 1

   }

}

################################################################

#------------------------------------------------------------
## @brief Crée la fenêtre de l'outil
#  @param This Chemin Tk de la fenêtre
#
proc cmaudeBuildIF { This } {
   #--- Frame of panel
   frame $This -borderwidth 2 -relief groove

      #--- Frame of panel title
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label of title
         Button $This.fra1.but1 -borderwidth 1 \
            -text "$::panneau(cmaude,aide1)\n$::panneau(cmaude,titre)" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::cmaude::getPluginType ] ] \
               [ ::cmaude::getPluginDirectory ] [ ::cmaude::getPluginHelp ]"
         pack $This.fra1.but1 -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but1 -text $::panneau(cmaude,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame du bouton de configuration
      frame $This.fra1a -borderwidth 2 -relief groove

         #--- Label du bouton Configuration
         button $This.fra1a.but -borderwidth 1 -text $::panneau(cmaude,config) \
            -command ::cmaude::config::run
         pack $This.fra1a.but -in $This.fra1a -anchor center -expand 1 -fill both -side top -ipadx 5

      pack $This.fra1a -side top -fill x

      #--- General frame
      frame $This.fra2 -borderwidth 1 -relief groove

         frame $This.fra2.fra4 -borderwidth 0 -relief flat

            #--- Bouton parcourir
            button $This.fra2.fra4.explore1 -borderwidth 2 -text $::panneau(cmaude,parcourir) \
               -command { ::cmaude::parcourir 1 }
            pack $This.fra2.fra4.explore1 -in $This.fra2.fra4 -anchor center -fill none -padx 2 -pady 1 -ipady 3 -side right
            #--- Label for the name of bias
            label $This.fra2.fra4.lab1 -text $::panneau(cmaude,label_bias) -relief flat
            pack $This.fra2.fra4.lab1 -in $This.fra2.fra4 -anchor center -expand 1 -fill both -padx 4 -pady 1
            #--- Entry for the name of bias
            entry $This.fra2.fra4.ent1 -textvariable ::panneau(cmaude,bias) -relief groove
            pack $This.fra2.fra4.ent1 -in $This.fra2.fra4 -anchor center -expand 1 -fill both -padx 4 -pady 2
            $This.fra2.fra4.ent1 xview end

         pack $This.fra2.fra4 -side top -fill x

         frame $This.fra2.fra5 -borderwidth 0 -relief flat

            #--- Bouton parcourir
            button $This.fra2.fra5.explore2 -borderwidth 2 -text $::panneau(cmaude,parcourir) \
               -command { ::cmaude::parcourir 2 }
            pack $This.fra2.fra5.explore2 -in $This.fra2.fra5 -anchor center -fill none -padx 2 -pady 1 -ipady 3 -side right
            #--- Label for the name of dark
            label $This.fra2.fra5.lab2 -text $::panneau(cmaude,label_dark) -relief flat
            pack $This.fra2.fra5.lab2 -in $This.fra2.fra5 -anchor center -expand 1 -fill both -padx 4 -pady 1
            #--- Entry for the name of dark
            entry $This.fra2.fra5.ent2 -textvariable ::panneau(cmaude,dark) -relief groove
            pack $This.fra2.fra5.ent2 -in $This.fra2.fra5 -anchor center -expand 1 -fill both -padx 4 -pady 2
            $This.fra2.fra5.ent2 xview end

         pack $This.fra2.fra5 -side top -fill x

         frame $This.fra2.fra6 -borderwidth 0 -relief flat

            #--- Bouton parcourir
            button $This.fra2.fra6.explore3 -borderwidth 2 -text $::panneau(cmaude,parcourir) \
               -command { ::cmaude::parcourir 3 }
            pack $This.fra2.fra6.explore3 -in $This.fra2.fra6 -anchor center -fill none -padx 2 -pady 1 -ipady 3 -side right
            #--- Label for the name of overlay
            label $This.fra2.fra6.lab2a -text $::panneau(cmaude,label_overlay) -relief flat
            pack $This.fra2.fra6.lab2a -in $This.fra2.fra6 -anchor center -expand 1 -fill both -padx 4 -pady 1
            #--- Entry for the name of overlay
            entry $This.fra2.fra6.ent2a -textvariable ::panneau(cmaude,overlay) -relief groove
            pack $This.fra2.fra6.ent2a -in $This.fra2.fra6 -anchor center -expand 1 -fill both -padx 4 -pady 2
            $This.fra2.fra6.ent2a xview end

         pack $This.fra2.fra6 -side top -fill x

         frame $This.fra2.fra7 -borderwidth 0 -relief flat

            #--- Bouton parcourir
            button $This.fra2.fra7.explore3 -borderwidth 2 -text $::panneau(cmaude,parcourir) \
               -command { ::cmaude::parcourir 4 }
            pack $This.fra2.fra7.explore3 -in $This.fra2.fra7 -anchor center -fill none -padx 2 -pady 1 -ipady 3 -side right
            #--- Label for the name of dirlast
            label $This.fra2.fra7.labdirlast -text $::panneau(cmaude,label_dirlast) -relief flat
            pack $This.fra2.fra7.labdirlast -in $This.fra2.fra7 -anchor center -expand 1 -fill both -padx 4 -pady 1
            #--- Entry for the name of dirlast
            entry $This.fra2.fra7.entdirlast -textvariable ::panneau(cmaude,dirlast) -relief groove
            pack $This.fra2.fra7.entdirlast -in $This.fra2.fra7 -anchor center -expand 1 -fill both -padx 4 -pady 2
            $This.fra2.fra7.entdirlast xview end

         pack $This.fra2.fra7 -side top -fill x

         #--- Label for the name of image
         label $This.fra2.lab3 -text $::panneau(cmaude,label_nom) -relief flat
         pack $This.fra2.lab3 -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 2
         #--- Entry for the name of image
         entry $This.fra2.ent3 -textvariable ::panneau(cmaude,nom) -relief groove
         pack $This.fra2.ent3 -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 2
         $This.fra2.ent3 xview end

         #--- Checkbutton for HTML page creation
         checkbutton $This.fra2.chck1 -text $::panneau(cmaude,label_page_html) -variable panneau(cmaude,page_html)
         pack $This.fra2.chck1 -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 2

         #--- Label for the binning
         label $This.fra2.lab4 -text $::panneau(cmaude,label_binning) -relief flat
         pack $This.fra2.lab4 -in $This.fra2 -anchor center -expand 1 -padx 4 -pady 1
         #--- Menu for the binning
         menubutton $This.fra2.but_binning -textvariable ::panneau(cmaude,binning) \
            -menu $This.fra2.but_binning.menu -relief raised
         pack $This.fra2.but_binning -in $This.fra2 -anchor center -padx 4 -pady 2 -ipadx 3
         set m [menu $This.fra2.but_binning.menu -tearoff 0 ]
         foreach binning $::panneau(cmaude,list_binning) {
            $m add radiobutton -label "$binning" \
               -indicatoron "1" \
               -value "$binning" \
               -variable ::panneau(cmaude,binning) \
               -command { }
         }

         #--- Label for the exptime
         label $This.fra2.lab5 -text $::panneau(cmaude,label_time) -relief flat
         pack $This.fra2.lab5 -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 1
         #--- Entry for the exptime
         entry $This.fra2.ent5 -textvariable ::panneau(cmaude,time) -width 4 -relief groove -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
         pack $This.fra2.ent5 -in $This.fra2 -anchor center -padx 4 -pady 2

         #--- Label for the rythm
         label $This.fra2.lab6 -text $::panneau(cmaude,label_rythm) -relief flat
         pack $This.fra2.lab6 -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 2
         #--- Entry for the rythm
         entry $This.fra2.ent6 -textvariable ::panneau(cmaude,rythm) -width 5 -relief groove -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 0 9999 }
         pack $This.fra2.ent6 -in $This.fra2 -anchor center -padx 4 -pady 2

         #--- Button GO
         button $This.fra2.but1 -borderwidth 2 -text $::panneau(cmaude,go) \
            -command ::cmaude::cmdGo
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 8 -ipadx 25 -ipady 6

         #--- Button STOP
         button $This.fra2.but2 -borderwidth 2 -text $::panneau(cmaude,stop) \
            -command ::cmaude::cmdStop
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill none -pady 8 -ipadx 15 -ipady 2

         #--- Button Ephemeris
         button $This.fra2.but3 -borderwidth 2 -text $::panneau(cmaude,ephem) \
            -command ::cmaude::cmdEphe
         pack $This.fra2.but3 -in $This.fra2 -anchor center -fill none -pady 8 -ipadx 15 -ipady 2

      pack $This.fra2 -side top -fill x

      #--- Frame for the status
      frame $This.fra3 -borderwidth 2 -relief groove

         #--- Label for designation of status
         label $This.fra3.lab1 -text $::panneau(cmaude,label_status) -relief flat
         pack $This.fra3.lab1 -in $This.fra3 -anchor center -expand 1 -fill both -side top
         #--- Label for status2
         label $This.fra3.lab2 -text $::panneau(cmaude,status) -relief flat
         pack $This.fra3.lab2 -in $This.fra3 -anchor center -fill none -padx 4 -pady 1
         #--- Label for status2
         label $This.fra3.labURL3 -text $::panneau(cmaude,status2) -fg $::color(red) -relief flat
         pack $This.fra3.labURL3 -in $This.fra3 -anchor center -fill none -padx 4 -pady 1
         #--- Label for status3
         label $This.fra3.labURL4 -text $::panneau(cmaude,status3) -fg $::color(red) -relief flat
         pack $This.fra3.labURL4 -in $This.fra3 -anchor center -fill none -padx 4 -pady 1

      pack $This.fra3 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

#================================
#=== Intialisation of pannel  ===
#================================

#=== End of file cmaude.tcl ===

