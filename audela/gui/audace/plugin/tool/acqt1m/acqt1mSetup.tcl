#
# Fichier : acqt1mSetup.tcl
# Description : Configuration de certains parametres de l'outil Acquisition
# Auteur : Robert DELMAS
# Mise à jour $Id: acqt1mSetup.tcl 12575 2016-01-10 17:25:14Z robertdelmas $
#

namespace eval ::acqt1mSetup {

   #
   # acqt1mSetup::init
   # Chargement des captions
   #
   proc init { } {
      global audace

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool acqt1m acqt1mSetup.cap ]
   }

   #
   # acqt1mSetup::initToConf
   # Initialisation des variables de configuration
   #
   proc initToConf { visuNo } {
      variable parametres

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::acqt1m::parametres(acqt1m,$visuNo,messages) ] }                           { set ::acqt1m::parametres(acqt1m,$visuNo,messages)                           "1" }
      if { ! [ info exists ::acqt1m::parametres(acqt1m,$visuNo,save_file_log) ] }                      { set ::acqt1m::parametres(acqt1m,$visuNo,save_file_log)                      "1" }
      if { ! [ info exists ::acqt1m::parametres(acqt1m,$visuNo,alarme_fin_serie) ] }                   { set ::acqt1m::parametres(acqt1m,$visuNo,alarme_fin_serie)                   "1" }
      if { ! [ info exists ::acqt1m::parametres(acqt1m,$visuNo,verifier_ecraser_fichier) ] }           { set ::acqt1m::parametres(acqt1m,$visuNo,verifier_ecraser_fichier)           "1" }
      if { ! [ info exists ::acqt1m::parametres(acqt1m,$visuNo,verifier_index_depart) ] }              { set ::acqt1m::parametres(acqt1m,$visuNo,verifier_index_depart)              "1" }
      if { ! [ info exists ::acqt1m::parametres(acqt1m,$visuNo,enregistrer_acquisiton_interrompue) ] } { set ::acqt1m::parametres(acqt1m,$visuNo,enregistrer_acquisiton_interrompue) "1" }
   }

   #
   # acqt1mSetup::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set panneau(acqt1m,$visuNo,messages)                           $::acqt1m::parametres(acqt1m,$visuNo,messages)
      set panneau(acqt1m,$visuNo,save_file_log)                      $::acqt1m::parametres(acqt1m,$visuNo,save_file_log)
      set panneau(acqt1m,$visuNo,alarme_fin_serie)                   $::acqt1m::parametres(acqt1m,$visuNo,alarme_fin_serie)
      set panneau(acqt1m,$visuNo,verifier_ecraser_fichier)           $::acqt1m::parametres(acqt1m,$visuNo,verifier_ecraser_fichier)
      set panneau(acqt1m,$visuNo,verifier_index_depart)              $::acqt1m::parametres(acqt1m,$visuNo,verifier_index_depart)
      set panneau(acqt1m,$visuNo,enregistrer_acquisiton_interrompue) $::acqt1m::parametres(acqt1m,$visuNo,enregistrer_acquisiton_interrompue)
   }

   #
   # acqt1mSetup::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { visuNo } {
      variable parametres
      global panneau

      #--- widgetToConf
      set ::acqt1m::parametres(acqt1m,$visuNo,messages)                           $panneau(acqt1m,$visuNo,messages)
      set ::acqt1m::parametres(acqt1m,$visuNo,save_file_log)                      $panneau(acqt1m,$visuNo,save_file_log)
      set ::acqt1m::parametres(acqt1m,$visuNo,alarme_fin_serie)                   $panneau(acqt1m,$visuNo,alarme_fin_serie)
      set ::acqt1m::parametres(acqt1m,$visuNo,verifier_ecraser_fichier)           $panneau(acqt1m,$visuNo,verifier_ecraser_fichier)
      set ::acqt1m::parametres(acqt1m,$visuNo,verifier_index_depart)              $panneau(acqt1m,$visuNo,verifier_index_depart)
      set ::acqt1m::parametres(acqt1m,$visuNo,enregistrer_acquisiton_interrompue) $panneau(acqt1m,$visuNo,enregistrer_acquisiton_interrompue)
   }

   #
   # acqt1mSetup::run
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
      set panneau(acqt1m,$visuNo,acqt1mSetup) $this
      ::confGenerique::run $visuNo "$panneau(acqt1m,$visuNo,acqt1mSetup)" "::acqt1mSetup" -modal 0
      set posx_config [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $panneau(acqt1m,$visuNo,acqt1mSetup) +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   }

   #
   # acqt1mSetup::cmdApply
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc cmdApply { visuNo } {
      ::acqt1mSetup::widgetToConf $visuNo
   }

   #
   # acqt1mSetup::showHelp
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::acqt1m::getPluginType ] ] \
         [ ::acqt1m::getPluginDirectory ] acqt1mSetup.htm
   }

   #
   # acqt1mSetup::cmdClose
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc cmdClose { visuNo } {
   }

   #
   # acqt1mSetup::getLabel
   # Retourne le nom de la fenetre de configuration
   #
   proc getLabel { } {
      global caption

      return "$caption(acqt1mSetup,titre)"
   }

   #
   # acqt1mSetup::fillConfigPage
   # Creation de l'interface graphique
   #
   proc fillConfigPage { frm visuNo } {
      global caption panneau

      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::acqt1mSetup::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set camItem [ ::confVisu::getCamItem $visuNo ]

      #--- Frame pour les commentaires
      frame $panneau(acqt1m,$visuNo,acqt1mSetup).frame3 -borderwidth 1 -relief raise

         #--- Frame pour l'en-tete FITS
         frame $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.en-tete -borderwidth 0

            #--- Label de l'en-tete FITS
            label $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.en-tete.lab -text $caption(acqt1mSetup,en-tete_fits)
            pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.en-tete.lab -side left -padx 6

            #--- Bouton d'acces aux mots cles
            button $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.en-tete.but -text $caption(acqt1mSetup,mots_cles) \
               -command "::keyword::run $visuNo ::conf(acqt1m,keywordConfigName)"
            pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.en-tete.but -side left -padx 6 -pady 10 -ipadx 20

         pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.en-tete -side top -fill both -expand 1

         #--- Frame pour le commentaire 1
         frame $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame4 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 1
            frame $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame4.frame8 -borderwidth 0
               checkbutton $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame4.frame8.check1 -highlightthickness 0 \
                  -text "$caption(acqt1mSetup,texte1)" -variable panneau(acqt1m,$visuNo,messages)
               pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame4.frame8.check1 -side right -padx 5 -pady 0
            pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame4.frame8 -side left

         pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame4 -side top -fill both -expand 1

         #--- Frame pour le commentaire 2
         frame $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame5 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 2
            frame $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame5.frame10 -borderwidth 0
               checkbutton $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame5.frame10.check2 -highlightthickness 0 \
                  -text "$caption(acqt1mSetup,texte2)" -variable panneau(acqt1m,$visuNo,save_file_log)
               pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame5.frame10.check2 -side right -padx 5 -pady 0
            pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame5.frame10 -side left

         pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame5 -side top -fill both -expand 1

         #--- Frame pour le commentaire 3
         frame $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame6 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 3
            frame $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame6.frame12 -borderwidth 0
               checkbutton $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame6.frame12.check3 -highlightthickness 0 \
                  -text "$caption(acqt1mSetup,texte3)" -variable panneau(acqt1m,$visuNo,alarme_fin_serie)
               pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame6.frame12.check3 -side right -padx 5 -pady 0
            pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame6.frame12 -side left

         pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame6 -side top -fill both -expand 1

         #--- Frame pour le commentaire 4 : verifier_ecraser_fichier
         frame $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame7 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 4
            frame $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame7.frame12 -borderwidth 0
               checkbutton $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame7.frame12.check3 -highlightthickness 0 \
                  -text "$caption(acqt1mSetup,texte4)" -variable panneau(acqt1m,$visuNo,verifier_ecraser_fichier)
               pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame7.frame12.check3 -side right -padx 5 -pady 0
            pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame7.frame12 -side left

         pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame7 -side top -fill both -expand 1

         #--- Frame pour le commentaire 5 : verifier_index_depart
         frame $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame8 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 5
            frame $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame8.frame12 -borderwidth 0
               checkbutton $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame8.frame12.check3 -highlightthickness 0 \
                  -text "$caption(acqt1mSetup,texte5)" -variable panneau(acqt1m,$visuNo,verifier_index_depart)
               pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame8.frame12.check3 -side right -padx 5 -pady 0
            pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame8.frame12 -side left

         pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame8 -side top -fill both -expand 1

         #--- Frame pour le commentaire 6 : enregistrer_acquisiton_interrompue
         frame $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame9 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 6
            frame $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame9.frame12 -borderwidth 0
               checkbutton $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame9.frame12.check3 -highlightthickness 0 \
                  -text "$caption(acqt1mSetup,texte6)" -variable panneau(acqt1m,$visuNo,enregistrer_acquisiton_interrompue)
               pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame9.frame12.check3 -side right -padx 5 -pady 0
            pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame9.frame12 -side left

         pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3.frame9 -side top -fill both -expand 1

      pack $panneau(acqt1m,$visuNo,acqt1mSetup).frame3 -side top -fill both -expand 1
   }

}

#--- Initialisation au demarrage
::acqt1mSetup::init

