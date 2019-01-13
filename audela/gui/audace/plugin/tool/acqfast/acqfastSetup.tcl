#
# Fichier : acqfastSetup.tcl
# Description : Configuration de certains parametres de l'outil Acquisition
# Auteur : Robert DELMAS
# Mise à jour $Id: acqfastSetup.tcl 12575 2016-01-10 17:25:14Z robertdelmas $
#

namespace eval ::acqfastSetup {

   #
   # acqfastSetup::init
   # Chargement des captions
   #
   proc init { } {
      global audace

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool acqfast acqfastSetup.cap ]
   }

   #
   # acqfastSetup::initToConf
   # Initialisation des variables de configuration
   #
   proc initToConf { visuNo } {
      variable parametres

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::acqfast::parametres(acqfast,$visuNo,messages) ] }                           { set ::acqfast::parametres(acqfast,$visuNo,messages)                           "1" }
      if { ! [ info exists ::acqfast::parametres(acqfast,$visuNo,save_file_log) ] }                      { set ::acqfast::parametres(acqfast,$visuNo,save_file_log)                      "1" }
      if { ! [ info exists ::acqfast::parametres(acqfast,$visuNo,verifier_ecraser_fichier) ] }           { set ::acqfast::parametres(acqfast,$visuNo,verifier_ecraser_fichier)           "1" }
   }

   #
   # acqfastSetup::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set panneau(acqfast,$visuNo,messages)                           $::acqfast::parametres(acqfast,$visuNo,messages)
      set panneau(acqfast,$visuNo,save_file_log)                      $::acqfast::parametres(acqfast,$visuNo,save_file_log)
      set panneau(acqfast,$visuNo,verifier_ecraser_fichier)           $::acqfast::parametres(acqfast,$visuNo,verifier_ecraser_fichier)
   }

   #
   # acqfastSetup::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { visuNo } {
      variable parametres
      global panneau

      #--- widgetToConf
      set ::acqfast::parametres(acqfast,$visuNo,messages)                           $panneau(acqfast,$visuNo,messages)
      set ::acqfast::parametres(acqfast,$visuNo,save_file_log)                      $panneau(acqfast,$visuNo,save_file_log)
      set ::acqfast::parametres(acqfast,$visuNo,verifier_ecraser_fichier)           $panneau(acqfast,$visuNo,verifier_ecraser_fichier)
   }

   #
   # acqfastSetup::run
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc run { visuNo this } {
      global audace panneau

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set base "$audace(base)"
      } else {
         set base ".visu$visuNo"
      }

      #---
      set panneau(acqfast,$visuNo,acqfastSetup) $this
      ::confGenerique::run $visuNo "$panneau(acqfast,$visuNo,acqfastSetup)" "::acqfastSetup" -modal 0
      set posx_config [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $panneau(acqfast,$visuNo,acqfastSetup) +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   }

   #
   # acqfastSetup::cmdApply
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc cmdApply { visuNo } {
      ::acqfastSetup::widgetToConf $visuNo
   }

   #
   # acqfastSetup::showHelp
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::acqfast::getPluginType ] ] \
         [ ::acqfast::getPluginDirectory ] acqfastSetup.htm
   }

   #
   # acqfastSetup::cmdClose
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc cmdClose { visuNo } {
   }

   #
   # acqfastSetup::getLabel
   # Retourne le nom de la fenetre de configuration
   #
   proc getLabel { } {
      global caption

      return "$caption(acqfastSetup,titre)"
   }

   #
   # acqfastSetup::fillConfigPage
   # Creation de l'interface graphique
   #
   proc fillConfigPage { frm visuNo } {
      global caption panneau

      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::acqfastSetup::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set camItem [ ::confVisu::getCamItem $visuNo ]

      #--- Frame pour les commentaires
      frame $panneau(acqfast,$visuNo,acqfastSetup).frame3 -borderwidth 1 -relief raise

         #--- Frame pour l'en-tete FITS
         frame $panneau(acqfast,$visuNo,acqfastSetup).frame3.en-tete -borderwidth 0

            #--- Label de l'en-tete FITS
            label $panneau(acqfast,$visuNo,acqfastSetup).frame3.en-tete.lab -text $caption(acqfastSetup,en-tete_fits)
            pack $panneau(acqfast,$visuNo,acqfastSetup).frame3.en-tete.lab -side left -padx 6

            #--- Bouton d'acces aux mots cles
            button $panneau(acqfast,$visuNo,acqfastSetup).frame3.en-tete.but -text $caption(acqfastSetup,mots_cles) \
               -command "::keyword::run $visuNo ::conf(acqfast,keywordConfigName)"
            pack $panneau(acqfast,$visuNo,acqfastSetup).frame3.en-tete.but -side left -padx 6 -pady 10 -ipadx 20

         pack $panneau(acqfast,$visuNo,acqfastSetup).frame3.en-tete -side top -fill both -expand 1

         #--- Frame pour le commentaire 1
         frame $panneau(acqfast,$visuNo,acqfastSetup).frame3.frame4 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 1
            frame $panneau(acqfast,$visuNo,acqfastSetup).frame3.frame4.frame8 -borderwidth 0
               checkbutton $panneau(acqfast,$visuNo,acqfastSetup).frame3.frame4.frame8.check1 -highlightthickness 0 \
                  -text "$caption(acqfastSetup,texte1)" -variable panneau(acqfast,$visuNo,messages)
               pack $panneau(acqfast,$visuNo,acqfastSetup).frame3.frame4.frame8.check1 -side right -padx 5 -pady 0
            pack $panneau(acqfast,$visuNo,acqfastSetup).frame3.frame4.frame8 -side left

         pack $panneau(acqfast,$visuNo,acqfastSetup).frame3.frame4 -side top -fill both -expand 1

         #--- Frame pour le commentaire 2
         frame $panneau(acqfast,$visuNo,acqfastSetup).frame3.frame5 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 2
            frame $panneau(acqfast,$visuNo,acqfastSetup).frame3.frame5.frame10 -borderwidth 0
               checkbutton $panneau(acqfast,$visuNo,acqfastSetup).frame3.frame5.frame10.check2 -highlightthickness 0 \
                  -text "$caption(acqfastSetup,texte2)" -variable panneau(acqfast,$visuNo,save_file_log)
               pack $panneau(acqfast,$visuNo,acqfastSetup).frame3.frame5.frame10.check2 -side right -padx 5 -pady 0
            pack $panneau(acqfast,$visuNo,acqfastSetup).frame3.frame5.frame10 -side left

         pack $panneau(acqfast,$visuNo,acqfastSetup).frame3.frame5 -side top -fill both -expand 1

         #--- Frame pour le commentaire 4 : verifier_ecraser_fichier
         frame $panneau(acqfast,$visuNo,acqfastSetup).frame3.frame7 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 4
            frame $panneau(acqfast,$visuNo,acqfastSetup).frame3.frame7.frame12 -borderwidth 0
               checkbutton $panneau(acqfast,$visuNo,acqfastSetup).frame3.frame7.frame12.check3 -highlightthickness 0 \
                  -text "$caption(acqfastSetup,texte4)" -variable panneau(acqfast,$visuNo,verifier_ecraser_fichier)
               pack $panneau(acqfast,$visuNo,acqfastSetup).frame3.frame7.frame12.check3 -side right -padx 5 -pady 0
            pack $panneau(acqfast,$visuNo,acqfastSetup).frame3.frame7.frame12 -side left

         pack $panneau(acqfast,$visuNo,acqfastSetup).frame3.frame7 -side top -fill both -expand 1

      pack $panneau(acqfast,$visuNo,acqfastSetup).frame3 -side top -fill both -expand 1
   }

}

#--- Initialisation au demarrage
::acqfastSetup::init

