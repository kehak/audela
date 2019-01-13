#
## @file foc_cam.tcl
#  @brief Scripts de toutes les commandes concernant l'acquisition
#  @author Alain KLOTZ, Robert DELMAS et Raymond ZACHANTKE
#  $Id: foc_cam.tcl 12892 2016-01-24 22:52:53Z rzachantke $
#

#------------------------------------------------------------
## @brief  commande du bouton "GO" lance le processus d'acquisition
#
proc ::foc::cmdGo { } {
   variable This
   global caption panneau

   #--   Raccourcis
   set visuNo $::audace(visuNo)

   #---
   if { [ ::cam::list ] != "" || [ ::cam::list ] == "" && $panneau(foc,simulation) ==1} {

      #--- Gestion graphique des boutons
      ::foc::setFocusState acq disabled
      ::foc::setAcqState centrage

      #--  la variable panneau(foc,actuel) n'existe que si on a fait le Centrage
      #--  Force Centrage si l'utilisateur a selectionne fenetrage avant Centrage
      if { [ info exists panneau(foc,actuel) ] == "0" } {
         $This.fra2.optionmenu1.menu invoke 0
      }

      if { $panneau(foc,menu) eq "$caption(foc,centrage)" } {

         #--- Mode Centrage
         ::foc::centrage
         set panneau(foc,actuel) "$panneau(foc,menu)"
         set panneau(foc,boucle) "$caption(foc,off)"

      } else {

         #--- Mode Fenetrage
         set binWindow $panneau(foc,window)
         set binBox [foc::fenetrage]
         if {$binBox ==0} { return }
         set panneau(foc,actuel) "$panneau(foc,menu)"
         set panneau(foc,boucle) "$caption(foc,on)"
         ::foc::selectGraph $binBox $binWindow

         #--- Suppression de la zone selectionnee avec la souris
         ::confVisu::deleteBox $visuNo
         #--- Suppression de l'image
         ::confVisu::clear $visuNo
      }

      #--   Acquisition
      if {$panneau(foc,simulation) == 0} {
         #--   S'informe si la cam a le windowing
         set panneau(foc,hasWindow) [ ::confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] hasWindow ]
         #--- Fenetrage sur la cam si elle camera possede le mode fenetrage (pas APN et ni WebCam)
         if {$panneau(foc,hasWindow) == "1"} {
            cam$::audace(camNo) window $panneau(foc,window)
         }
      } else {
         #--   Simulation
         set panneau(foc,seeing) 24.0
         set panneau(foc,hasWindow) 0
         #--   Decoche le suivi
         set panneau(foc,avancement_acq) 0
      }

      #--- Appel a la fonction d'acquisition
      ::foc::cmdAcq

      #--- Gestion graphique des boutons
      ::foc::setAcqState post
      ::foc::setFocusState acq normal

   } else {
      #--   Pas de camera connectee : ouvre le panneau de selection de la camera
      ::confCam::run
   }
}

#------------------------------------------------------------
#  brief configure les variables pour le Centrage
#
proc ::foc::centrage { } {
   global panneau

   if {$panneau(foc,simulation) == 0} {

      #--- Applique le binning demande si la camera possede bien ce binning
      set binningCamera "2x2"
      if { [ lsearch [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] binningList ] $binningCamera ] != "-1" } {
         set panneau(foc,bin) "2"
      } else {
         set panneau(foc,bin) "1"
      }
      set panneau(foc,bin_centrage) "$panneau(foc,bin)"
      lassign [ cam$::audace(camNo) nbcells ] naxis1 naxis2
      set panneau(foc,window)       [ list 1 1 $naxis1 $naxis1 ]

   } else {

      #--   Mode simulation de camera
      set panneau(foc,bin) "2"
      set panneau(foc,bin_centrage) "$panneau(foc,bin)"
      #--   attention moitie de naxis1 et naxis2 du fait du binning
      set panneau(foc,window) [ list 1 1 384  256 ]
   }
}

#------------------------------------------------------------
#  brief configure les variables pour le Fenêtrage
#  return coordonnées de la boîte de fenêtrage, 0 si erreur
#
proc ::foc::fenetrage { } {
   global caption panneau

   if { $panneau(foc,menu) eq "$caption(foc,fenetre_auto)"} {

      #--   Fenetrage automatique

      #--   Coordonnees de l'étoile dans l'image binnee
      #--   attention si l'image est plate x=naxis1 et y=naxis2
      lassign [ ::prtr::searchMax $panneau(foc,window) $::audace(bufNo) ] x y

      #--   Calcule auto des cordonnees de la fenetre dans l'image binnee
      set a [expr { int(round($x)-40) }]
      set b [expr { int(round($y)-40) }]
      set c [expr { int(round($x)+40) }]
      set d [expr { int(round($y)+40) }]
      set binBox [list $a $b $c $d]

      #--   Visualise la boite durant 3 secondes
      ::confVisu::setBox $::audace(visuNo) $binBox
      after 5000

   } else {

      #--   Fenetrage manuel

      #--   Identifie la fenetre dans l'image binnee
      set binBox [ ::confVisu::getBox $::audace(visuNo) ]
      if {$binBox eq ""} {
         tk_messageBox -title $caption(foc,attention)\
            -icon error -type ok -message "$caption(foc,erreur)"
         ::foc::setAcqState stop
         return 0
      }

   }

   #--   Recalcule les coordonnees dans l'image non binnee
   set panneau(foc,bin) "1"
   lassign $binBox a b c d
   #--   Verifie que la selection existe
   if {$a ne ""} {
      set x1 [expr { $panneau(foc,bin_centrage)*$a }]
      set y1 [expr { $panneau(foc,bin_centrage)*$b }]
      set x2 [expr { $panneau(foc,bin_centrage)*$c }]
      set y2 [expr { $panneau(foc,bin_centrage)*$d }]

      #--   Definit le fenetrage dans l'image non binnee
      set panneau(foc,window) [list $x1 $y1 $x2 $y2]

      #--   Calcule la taille de la fenetre a partir de ses coordonnees en tenant compte du binning
      set naxis1Fen [expr { ($x2-$x1+1)*$panneau(foc,bin_centrage) }]
      set naxis2Fen [expr { ($y2-$y1+1)*$panneau(foc,bin_centrage) }]
      set panneau(foc,box) [list 1 1 $naxis1Fen $naxis2Fen]
   }

   return $binBox
}

#------------------------------------------------------------
#  brief ouvre le graphique adhoc s'il n'existe pas déjà
#  param binBox coordonnées de la boîte de fenêtrage
#  param binWindow dimensions de l'image
#
proc ::foc::selectGraph { binBox binWindow } {
   variable This
   global caption panneau

   if { $panneau(foc,typefocuser) == "0" && [winfo exists $This.visufoc] ==0} {

      #--   Lance le graphique normal
      ::foc::focGraphe

      #--   Finalise la ligne de titre du fichier log
      append panneau(foc,fichier) "\n"

   } elseif { $panneau(foc,typefocuser) == "1" && [winfo exists $This.visuhfd] ==0} {

      #--   Lance le graphique HFD
      ::foc::createHFDgraphe

      #--   Photocentre dans la fenetre binnee
      lassign [buf$::audace(bufNo) centro $binBox] xstar ystar

      #--   Dimensions de l'image binnee
      lassign $binWindow -> -> naxis1 naxis2

      #--   Centre l'etoile si l'image est plate
      if {$xstar == $naxis1 && $ystar == $naxis2} {
         set xstar [expr { $naxis1/2 }]
         set ystar [expr { $naxis2/2 }]
      }

      #--   Dessine le schema etoile/image a partir de l'image binnee
      ::foc::updateLocator $naxis1 $naxis2 $xstar $ystar

      #--   Finalise la ligne de titre  du fichier log
      append panneau(foc,fichier) "$caption(foc,hfd)\t${caption(foc,pos_focus)}\n"
   }
}

#------------------------------------------------------------
## @brief boucle d'acquisitions
#
#  initiée par ::foc::cmdGo
#
proc ::foc::cmdAcq { } {
   variable This
   variable Count
   global caption panneau

   #--- Initialisation d'une variable
   set panneau(foc,finAquisition) ""

   #--- Pose en cours
   set panneau(foc,pose_en_cours) "1"

   #--- La commande bin permet de fixer le binning
   if {$panneau(foc,simulation) == 0} {
      cam$::audace(camNo) bin [ list $panneau(foc,bin) $panneau(foc,bin) ]
   }

   #--- Cas des petites poses : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
   if { $panneau(foc,exptime) >= "0" && $panneau(foc,exptime) < "1" } {
      ::foc::avancementPose 0
   }

   #--- Alarme sonore de fin de pose
   ::camera::alarmeSonore $panneau(foc,exptime)

   #--   Effectue le deplacement du focuser sur la position initiale cible
   ::foc::dynamicFoc

   #--   Fait au moins une une acquisition
   for {set rep 1} {$rep <= $panneau(foc,repeat)} {incr rep} {

      if {$panneau(foc,simulation) == 0} {

         #--- Declenchement de l'acquisition
         ::camera::acquisition [ ::confVisu::getCamItem $::audace(visuNo) ] "::foc::attendImage" $panneau(foc,exptime)

         #--- Je lance la boucle d'affichage du decompte
         after 10 ::foc::dispTime

         #--- J'attends la fin de l'acquisition
         vwait panneau(foc,finAquisition)

      } else {

         #--   Cree une image virtuelle
         ::foc::createImage $panneau(foc,bin) [::foc::computeSeeing] $panneau(foc,exptime)
      }

      if {$panneau(foc,demande_arret) == 1} {
         set panneau(foc,boucle) "$caption(foc,off)"
      }

      #--  S'assure que l'image est en NB ou un plan couleur G
      ::foc::traiteImage

      #--- Informations sur l'image fenetree
      if { $panneau(foc,actuel) ne "$caption(foc,centrage)" && $panneau(foc,boucle) == "$caption(foc,on)"} {
         ::foc::updateValues
         after idle ::foc::cmdAcq
      } else {
         ::foc::setAcqState stop
      }
   }

   #--- Pose en cours
   set panneau(foc,pose_en_cours) "0"

   #--- Demande d'arret de la pose
   set panneau(foc,demande_arret) "0"

   #--- Effacement de la barre de progression quand la pose est terminee
   ::foc::avancementPose -1
}

#------------------------------------------------------------
#  brief extrait le plan G des images RAW ou RGB
#
proc ::foc::traiteImage { } {

   set bufNo $::audace(bufNo)
   set naxis [lindex [buf$bufNo getkwd NAXIS] 1]
   set naxis3 [lindex [buf$bufNo getkwd NAXIS3] 1]
   set rawcolor [lindex [buf$bufNo getkwd RAWCOLOR] 1]   ; #--nouveau mot cle
   set rawcolors [lindex [buf$bufNo getkwd RAWCOLORS] 1] ; #--ancien mot cle

   if {$naxis ==2 && $naxis3 eq ""} {
      if {$rawcolor ne "" || $rawcolors ne ""} {
         #-- image RAW
         #--- Convertit en RGB
         buf$bufNo cfa2rgb 1
         buf$bufNo delkwd RAWCOLOR
         #--   Rappelle la fonction pour isoler le plan G
         ::foc::traiteImage
       } else {
         #-- rien a faire : image monocolore NB ou plan couleur
         return
       }
   } elseif {$naxis ==3 && $naxis3 ne ""} {
      #-- image RGB : selection du plan G
      set fileName [file join $::audace(rep_images) planR$::conf(extension,defaut)]
      buf$bufNo setkwd [ list NAXIS 2 int "" "" ]
      buf$bufNo setkwd [ list RGBFILTR G string "Color extracted (Green)" "" ]
      buf$bufNo delkwd RAWCOLOR
      #--- Sauve et recharge le plan couleur
      buf$bufNo save3d $fileName 3 2 2
      buf$bufNo load $fileName
      #--- Calcule les seuils
      buf$bufNo stat
      ::confVisu::autovisu $::audace(visuNo)
      #--  Detruit le fichier image
      file delete $fileName
   }
}

#------------------------------------------------------------
#  brief updateValues met a jour les graphiques
#
proc ::foc::updateValues { } {
   global panneau

   set bufNo $::audace(bufNo)

   #--- Fenetrage sur le buffer si la camera ne possede pas le mode fenetrage (APN et WebCam)
   if {$panneau(foc,hasWindow) == "0"} {
      buf$bufNo window $panneau(foc,window)
      ::confVisu::autovisu $::audace(visuNo)
   }

   #--- Gestion graphique des boutons
   ::foc::setAcqState window

   incr panneau(foc,compteur)

   #--   Normalise le fond du ciel
   buf$bufNo noffset 0

   if {$panneau(foc,typefocuser) == "1"} {
      ::foc::extractBiny $::audace(bufNo)
   }

   #--- Statistiques
   set s [ stat ]
   set maxi [ lindex $s 2 ]
   set fond [ lindex $s 7 ]
   set contr [ format "%.0f" [ expr -1.*[ lindex $s 8 ] ] ]
   set inten [ format "%.0f" [ expr $maxi-$fond ] ]
   #--- Fwhm
   lassign [ buf$bufNo fwhm $panneau(foc,box) ] fwhmx fwhmy
   #--- Valeurs a l'ecran
   ::foc::qualiteFoc $inten $fwhmx $fwhmy $contr
   update

   #--  Traitement differentie selon focuser
   if { $panneau(foc,typefocuser) == "0"} {
      #--   Mise a jour des graphiques
      ::foc::updateFocGraphe [list $panneau(foc,compteur) $inten $fwhmx $fwhmy $contr]
      #--- Actualise les donnees pour le fichier log
      append panneau(foc,fichier) "$inten\t$fwhmx\t$fwhmy\t$contr\n"
   } else {
      #--   Calculs et Mise a jour des graphiques (le temps de traitement double)
      ::foc::processHFD
      #--- Actualise les donnees pour le fichier log
      append panneau(foc,fichier) "$inten\t$fwhmx\t$fwhmy\t$contr\t$panneau(foc,hfd)\t$::audace(focus,currentFocus)\n"
   }
}

#------------------------------------------------------------
#  brief sous processus de cmdAcq
#  param message { autovisu acquisitionResult error}
#  param args
#
proc ::foc::attendImage { message args } {
   global panneau

   switch $message {
      "autovisu" {
         #--- ce message signale que l'image est prete dans le buffer
         #--- on peut l'afficher sans attendre la fin complete de la thread de la camera
         ::confVisu::autovisu $::audace(visuNo)
      }
      "acquisitionResult" {
         #--- ce message signale que la thread de la camera a termine completement l'acquisition
         #--- je peux traiter l'image
         set panneau(foc,finAquisition) "acquisitionResult"
      }
      "error" {
         #--- ce message signale qu'une erreur est survenue dans la thread de la camera
         #--- j'affiche l'erreur dans la console
         ::console::affiche_erreur "foc::cmdAcq error: $args\n"
         set panneau(foc,finAquisition) "error"
      }
   }
}

#------------------------------------------------------------
#  brief compte à rebours du temps d'exposition
#
proc ::foc::dispTime { } {
   global panneau

   #--- J'arrete le timer s'il est deja lance
   if { [info exists panneau(foc,dispTimeAfterId)] && $panneau(foc,dispTimeAfterId)!="" } {
      after cancel $panneau(foc,dispTimeAfterId)
      set panneau(foc,dispTimeAfterId) ""
   }

   #--- Je mets a jour la fenetre de progression
   set t [cam$::audace(camNo) timer -1 ]
   ::foc::avancementPose $t

   if { $t > 0 } {
      #--- Je lance l'iteration suivante avec un delai de 1000 millisecondes
      #--- (mode asynchone pour eviter l'empilement des appels recursifs)
      set panneau(foc,dispTimeAfterId) [ after 1000 ::foc::dispTime ]
   } else {
      #--- Je ne relance pas le timer
      set panneau(foc,dispTimeAfterId) ""
   }
}

#------------------------------------------------------------
## @brief commande du bouton STOP/RAZ
#
proc ::foc::cmdStop { } {
   variable This
   global caption panneau

   if { [ ::cam::list ] != "" } {
      if { [ $This.fra2.but2 cget -text ] eq "$panneau(foc,raz)" } {
         ::foc::razGraph
      } else {
         #--- Je positionne l'indicateur d'arret de la pose
         set panneau(foc,demande_arret) "1"
         #--- On annule l'identificateur qui arrete le moteur de foc
         catch { after cancel $::audace(after,focstop,id) }
         #--- Graphiques du panneau
         set panneau(foc,boucle) "$caption(foc,off)"
         #--- Annulation de l'alarme de fin de pose
         catch { after cancel bell }
         #--- Arret de la capture de l'image
         ::camera::stopAcquisition [ ::confVisu::getCamItem $::audace(visuNo) ]
         #--- Sauvegarde du fichier des traces
         ::foc::cmdSauveLog foc.log
         #--- J'attends la fin de l'acquisition
         vwait panneau(foc,finAquisition)

         #--- Gestion graphique des boutons
         ::foc::setAcqState stop
      }
      ::foc::setFocusState acq normal
   } else {
      if {$panneau(foc,simulation) ==1} {
         if {[ $This.fra2.but1 cget -relief ] eq "groove"} {
            #--- Demande d'arret de la pose
            set panneau(foc,demande_arret) "1"
            set panneau(foc,boucle) "$caption(foc,off)"
            #--- Gestion graphique des boutons
            ::foc::setAcqState stop
            ::foc::setFocusState acq normal
         } else {
            ::foc::razGraph
         }
         $This.fra2.optionmenu1.menu invoke 0
     } else {
         ::confCam::run
     }
   }
}

#------------------------------------------------------------
#  brief gère l'état des boutons GO et STOP/RAZ en fonctions des opérations
#  param op { goto centrage post window stop }
#  param state { normal disabled }
#
proc ::foc::setAcqState { op {state ""} } {
   variable This
   global caption panneau

   #--   raccourcis
   set but_GO $This.fra2.but1
   set but_STOP_RAZ $This.fra2.but2

   #--   Rem : state n'est pas toujours utile
   switch -exact $op {
      goto     {  #--  Etat lors d'un GOTO
                  $but_GO configure -state $state
                  $but_STOP_RAZ configure -state $state
               }
      centrage {  #--  Etat avant une acquisition de centrage
                  $but_GO configure -relief groove -state disabled
                  $but_STOP_RAZ configure -relief raised -text $panneau(foc,stop) -state normal
               }
      post     {  #--  Etat apres une acquisition de centrage
                  if { $panneau(foc,actuel) == "$caption(foc,centrage)" } {
                     $but_GO configure -relief raised -text $panneau(foc,go) -state normal
                  }
                  $but_STOP_RAZ configure -relief raised -text $panneau(foc,raz)
               }
      window   {  #--  Etat post-window
                  $but_GO configure -relief groove -text $panneau(foc,go)
                  $but_STOP_RAZ configure -text $panneau(foc,stop)
               }
      stop     {  #--  Etat a la fin d'un stop
                  $but_GO configure -relief raised -text $panneau(foc,go) -state normal
                  $but_STOP_RAZ configure -relief raised -text $panneau(foc,raz) -state normal
               }
   }
   update
}

