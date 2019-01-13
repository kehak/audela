#
# Fichier : acqfcSetup.tcl
# Description : Configuration de certains parametres de l'outil Acquisition
# Auteur : Robert DELMAS
# Mise à jour $Id: acqfcSetup.tcl 12575 2016-01-10 17:25:14Z robertdelmas $
#

namespace eval ::acqfcSetup {

   #
   # acqfcSetup::init
   # Chargement des captions
   #
   proc init { } {
      global audace

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool acqfc acqfcSetup.cap ]
   }

   #
   # acqfcSetup::initToConf
   # Initialisation des variables de configuration
   #
   proc initToConf { visuNo } {
      variable parametres

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::acqfc::parametres(acqfc,$visuNo,messages) ] }                           { set ::acqfc::parametres(acqfc,$visuNo,messages)                           "1" }
      if { ! [ info exists ::acqfc::parametres(acqfc,$visuNo,save_file_log) ] }                      { set ::acqfc::parametres(acqfc,$visuNo,save_file_log)                      "1" }
      if { ! [ info exists ::acqfc::parametres(acqfc,$visuNo,alarme_fin_serie) ] }                   { set ::acqfc::parametres(acqfc,$visuNo,alarme_fin_serie)                   "1" }
      if { ! [ info exists ::acqfc::parametres(acqfc,$visuNo,verifier_ecraser_fichier) ] }           { set ::acqfc::parametres(acqfc,$visuNo,verifier_ecraser_fichier)           "1" }
      if { ! [ info exists ::acqfc::parametres(acqfc,$visuNo,verifier_index_depart) ] }              { set ::acqfc::parametres(acqfc,$visuNo,verifier_index_depart)              "1" }
      if { ! [ info exists ::acqfc::parametres(acqfc,$visuNo,enregistrer_acquisiton_interrompue) ] } { set ::acqfc::parametres(acqfc,$visuNo,enregistrer_acquisiton_interrompue) "1" }
   }

   #
   # acqfcSetup::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set panneau(acqfc,$visuNo,messages)                           $::acqfc::parametres(acqfc,$visuNo,messages)
      set panneau(acqfc,$visuNo,save_file_log)                      $::acqfc::parametres(acqfc,$visuNo,save_file_log)
      set panneau(acqfc,$visuNo,alarme_fin_serie)                   $::acqfc::parametres(acqfc,$visuNo,alarme_fin_serie)
      set panneau(acqfc,$visuNo,verifier_ecraser_fichier)           $::acqfc::parametres(acqfc,$visuNo,verifier_ecraser_fichier)
      set panneau(acqfc,$visuNo,verifier_index_depart)              $::acqfc::parametres(acqfc,$visuNo,verifier_index_depart)
      set panneau(acqfc,$visuNo,enregistrer_acquisiton_interrompue) $::acqfc::parametres(acqfc,$visuNo,enregistrer_acquisiton_interrompue)
   }

   #
   # acqfcSetup::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { visuNo } {
      variable parametres
      global panneau

      #--- widgetToConf
      set ::acqfc::parametres(acqfc,$visuNo,messages)                           $panneau(acqfc,$visuNo,messages)
      set ::acqfc::parametres(acqfc,$visuNo,save_file_log)                      $panneau(acqfc,$visuNo,save_file_log)
      set ::acqfc::parametres(acqfc,$visuNo,alarme_fin_serie)                   $panneau(acqfc,$visuNo,alarme_fin_serie)
      set ::acqfc::parametres(acqfc,$visuNo,verifier_ecraser_fichier)           $panneau(acqfc,$visuNo,verifier_ecraser_fichier)
      set ::acqfc::parametres(acqfc,$visuNo,verifier_index_depart)              $panneau(acqfc,$visuNo,verifier_index_depart)
      set ::acqfc::parametres(acqfc,$visuNo,enregistrer_acquisiton_interrompue) $panneau(acqfc,$visuNo,enregistrer_acquisiton_interrompue)
   }

   #
   # acqfcSetup::run
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
      set panneau(acqfc,$visuNo,acqfcSetup) $this
      ::confGenerique::run $visuNo "$panneau(acqfc,$visuNo,acqfcSetup)" "::acqfcSetup" -modal 0
      set posx_config [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $panneau(acqfc,$visuNo,acqfcSetup) +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   }

   #
   # acqfcSetup::cmdApply
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc cmdApply { visuNo } {
      ::acqfcSetup::widgetToConf $visuNo
   }

   #
   # acqfcSetup::showHelp
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::acqfc::getPluginType ] ] \
         [ ::acqfc::getPluginDirectory ] acqfcSetup.htm
   }

   #
   # acqfcSetup::cmdClose
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc cmdClose { visuNo } {
   }

   #
   # acqfcSetup::getLabel
   # Retourne le nom de la fenetre de configuration
   #
   proc getLabel { } {
      global caption

      return "$caption(acqfcSetup,titre)"
   }

   #
   # acqfcSetup::fillConfigPage
   # Creation de l'interface graphique
   #
   proc fillConfigPage { frm visuNo } {
      global caption panneau

      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::acqfcSetup::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set camItem [ ::confVisu::getCamItem $visuNo ]

      #--- Frame pour les commentaires
      frame $panneau(acqfc,$visuNo,acqfcSetup).frame3 -borderwidth 1 -relief raise

         #--- Frame pour l'en-tete FITS
         frame $panneau(acqfc,$visuNo,acqfcSetup).frame3.en-tete -borderwidth 0

            #--- Label de l'en-tete FITS
            label $panneau(acqfc,$visuNo,acqfcSetup).frame3.en-tete.lab -text $caption(acqfcSetup,en-tete_fits)
            pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.en-tete.lab -side left -padx 6

            #--- Bouton d'acces aux mots cles
            button $panneau(acqfc,$visuNo,acqfcSetup).frame3.en-tete.but -text $caption(acqfcSetup,mots_cles) \
               -command "::keyword::run $visuNo ::conf(acqfc,keywordConfigName)"
            pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.en-tete.but -side left -padx 6 -pady 10 -ipadx 20

            #--- Label du nom de la configuration de l'en-tete FITS
            entry $panneau(acqfc,$visuNo,acqfcSetup).frame3.en-tete.labNom \
               -state readonly -takefocus 0 -textvariable ::conf(acqfc,keywordConfigName) -justify center
            pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.en-tete.labNom -side left -padx 6

         pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.en-tete -side top -fill both -expand 1

         #--- Frame pour le commentaire 1
         frame $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame4 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 1
            frame $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame4.frame8 -borderwidth 0
               checkbutton $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame4.frame8.check1 -highlightthickness 0 \
                  -text "$caption(acqfcSetup,texte1)" -variable panneau(acqfc,$visuNo,messages)
               pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame4.frame8.check1 -side right -padx 5 -pady 0
            pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame4.frame8 -side left

         pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame4 -side top -fill both -expand 1

         #--- Frame pour le commentaire 2
         frame $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame5 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 2
            frame $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame5.frame10 -borderwidth 0
               checkbutton $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame5.frame10.check2 -highlightthickness 0 \
                  -text "$caption(acqfcSetup,texte2)" -variable panneau(acqfc,$visuNo,save_file_log)
               pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame5.frame10.check2 -side right -padx 5 -pady 0
            pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame5.frame10 -side left

         pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame5 -side top -fill both -expand 1

         #--- Frame pour le commentaire 3
         frame $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame6 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 3
            frame $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame6.frame12 -borderwidth 0
               checkbutton $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame6.frame12.check3 -highlightthickness 0 \
                  -text "$caption(acqfcSetup,texte3)" -variable panneau(acqfc,$visuNo,alarme_fin_serie)
               pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame6.frame12.check3 -side right -padx 5 -pady 0
            pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame6.frame12 -side left

         pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame6 -side top -fill both -expand 1

         #--- Frame pour le commentaire 4 : verifier_ecraser_fichier
         frame $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame7 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 4
            frame $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame7.frame12 -borderwidth 0
               checkbutton $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame7.frame12.check3 -highlightthickness 0 \
                  -text "$caption(acqfcSetup,texte4)" -variable panneau(acqfc,$visuNo,verifier_ecraser_fichier)
               pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame7.frame12.check3 -side right -padx 5 -pady 0
            pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame7.frame12 -side left

         pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame7 -side top -fill both -expand 1

         #--- Frame pour le commentaire 5 : verifier_index_depart
         frame $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame8 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 5
            frame $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame8.frame12 -borderwidth 0
               checkbutton $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame8.frame12.check3 -highlightthickness 0 \
                  -text "$caption(acqfcSetup,texte5)" -variable panneau(acqfc,$visuNo,verifier_index_depart)
               pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame8.frame12.check3 -side right -padx 5 -pady 0
            pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame8.frame12 -side left

         pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame8 -side top -fill both -expand 1

         #--- Frame pour le commentaire 6 : enregistrer_acquisiton_interrompue
         frame $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame9 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 6
            frame $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame9.frame12 -borderwidth 0
               checkbutton $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame9.frame12.check3 -highlightthickness 0 \
                  -text "$caption(acqfcSetup,texte6)" -variable panneau(acqfc,$visuNo,enregistrer_acquisiton_interrompue)
               pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame9.frame12.check3 -side right -padx 5 -pady 0
            pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame9.frame12 -side left

         pack $panneau(acqfc,$visuNo,acqfcSetup).frame3.frame9 -side top -fill both -expand 1

      pack $panneau(acqfc,$visuNo,acqfcSetup).frame3 -side top -fill both -expand 1
   }

}

#--- Initialisation au demarrage
::acqfcSetup::init

