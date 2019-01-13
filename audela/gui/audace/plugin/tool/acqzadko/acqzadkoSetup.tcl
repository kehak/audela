#
# Fichier : acqzadkoSetup.tcl
# Description : Configuration de certains parametres de l'outil Acquisition
# Auteur : Robert DELMAS
# Mise à jour $Id: acqzadkoSetup.tcl 12575 2016-01-10 17:25:14Z robertdelmas $
#

namespace eval ::acqzadkoSetup {

   #
   # acqzadkoSetup::init
   # Chargement des captions
   #
   proc init { } {
      global audace

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool acqzadko acqzadkoSetup.cap ]
   }

   #
   # acqzadkoSetup::initToConf
   # Initialisation des variables de configuration
   #
   proc initToConf { visuNo } {
      variable parametres

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::acqzadko::parametres(acqzadko,$visuNo,messages) ] }                           { set ::acqzadko::parametres(acqzadko,$visuNo,messages)                           "1" }
      if { ! [ info exists ::acqzadko::parametres(acqzadko,$visuNo,save_file_log) ] }                      { set ::acqzadko::parametres(acqzadko,$visuNo,save_file_log)                      "1" }
      if { ! [ info exists ::acqzadko::parametres(acqzadko,$visuNo,alarme_fin_serie) ] }                   { set ::acqzadko::parametres(acqzadko,$visuNo,alarme_fin_serie)                   "1" }
      if { ! [ info exists ::acqzadko::parametres(acqzadko,$visuNo,verifier_ecraser_fichier) ] }           { set ::acqzadko::parametres(acqzadko,$visuNo,verifier_ecraser_fichier)           "1" }
      if { ! [ info exists ::acqzadko::parametres(acqzadko,$visuNo,verifier_index_depart) ] }              { set ::acqzadko::parametres(acqzadko,$visuNo,verifier_index_depart)              "1" }
      if { ! [ info exists ::acqzadko::parametres(acqzadko,$visuNo,enregistrer_acquisiton_interrompue) ] } { set ::acqzadko::parametres(acqzadko,$visuNo,enregistrer_acquisiton_interrompue) "1" }
   }

   #
   # acqzadkoSetup::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set panneau(acqzadko,$visuNo,messages)                           $::acqzadko::parametres(acqzadko,$visuNo,messages)
      set panneau(acqzadko,$visuNo,save_file_log)                      $::acqzadko::parametres(acqzadko,$visuNo,save_file_log)
      set panneau(acqzadko,$visuNo,alarme_fin_serie)                   $::acqzadko::parametres(acqzadko,$visuNo,alarme_fin_serie)
      set panneau(acqzadko,$visuNo,verifier_ecraser_fichier)           $::acqzadko::parametres(acqzadko,$visuNo,verifier_ecraser_fichier)
      set panneau(acqzadko,$visuNo,verifier_index_depart)              $::acqzadko::parametres(acqzadko,$visuNo,verifier_index_depart)
      set panneau(acqzadko,$visuNo,enregistrer_acquisiton_interrompue) $::acqzadko::parametres(acqzadko,$visuNo,enregistrer_acquisiton_interrompue)
   }

   #
   # acqzadkoSetup::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { visuNo } {
      variable parametres
      global panneau

      #--- widgetToConf
      set ::acqzadko::parametres(acqzadko,$visuNo,messages)                           $panneau(acqzadko,$visuNo,messages)
      set ::acqzadko::parametres(acqzadko,$visuNo,save_file_log)                      $panneau(acqzadko,$visuNo,save_file_log)
      set ::acqzadko::parametres(acqzadko,$visuNo,alarme_fin_serie)                   $panneau(acqzadko,$visuNo,alarme_fin_serie)
      set ::acqzadko::parametres(acqzadko,$visuNo,verifier_ecraser_fichier)           $panneau(acqzadko,$visuNo,verifier_ecraser_fichier)
      set ::acqzadko::parametres(acqzadko,$visuNo,verifier_index_depart)              $panneau(acqzadko,$visuNo,verifier_index_depart)
      set ::acqzadko::parametres(acqzadko,$visuNo,enregistrer_acquisiton_interrompue) $panneau(acqzadko,$visuNo,enregistrer_acquisiton_interrompue)
   }

   #
   # acqzadkoSetup::run
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
      set panneau(acqzadko,$visuNo,acqzadkoSetup) $this
      ::confGenerique::run $visuNo "$panneau(acqzadko,$visuNo,acqzadkoSetup)" "::acqzadkoSetup" -modal 0
      set posx_config [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $panneau(acqzadko,$visuNo,acqzadkoSetup) +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   }

   #
   # acqzadkoSetup::cmdApply
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc cmdApply { visuNo } {
      ::acqzadkoSetup::widgetToConf $visuNo
   }

   #
   # acqzadkoSetup::showHelp
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::acqzadko::getPluginType ] ] \
         [ ::acqzadko::getPluginDirectory ] acqzadkoSetup.htm
   }

   #
   # acqzadkoSetup::cmdClose
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc cmdClose { visuNo } {
   }

   #
   # acqzadkoSetup::getLabel
   # Retourne le nom de la fenetre de configuration
   #
   proc getLabel { } {
      global caption

      return "$caption(acqzadkoSetup,titre)"
   }

   #
   # acqzadkoSetup::fillConfigPage
   # Creation de l'interface graphique
   #
   proc fillConfigPage { frm visuNo } {
      global caption panneau

      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::acqzadkoSetup::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set camItem [ ::confVisu::getCamItem $visuNo ]

      #--- Frame pour les commentaires
      frame $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3 -borderwidth 1 -relief raise

         #--- Frame pour l'en-tete FITS
         frame $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.en-tete -borderwidth 0

            #--- Label de l'en-tete FITS
            label $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.en-tete.lab -text $caption(acqzadkoSetup,en-tete_fits)
            pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.en-tete.lab -side left -padx 6

            #--- Bouton d'acces aux mots cles
            button $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.en-tete.but -text $caption(acqzadkoSetup,mots_cles) \
               -command "::keyword::run $visuNo ::conf(acqzadko,keywordConfigName)"
            pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.en-tete.but -side left -padx 6 -pady 10 -ipadx 20

            #--- Label du nom de la configuration de l'en-tete FITS
            entry $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.en-tete.labNom \
               -state readonly -takefocus 0 -textvariable ::conf(acqzadko,keywordConfigName) -justify center
            pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.en-tete.labNom -side left -padx 6

         pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.en-tete -side top -fill both -expand 1

         #--- Frame pour le commentaire 1
         frame $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame4 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 1
            frame $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame4.frame8 -borderwidth 0
               checkbutton $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame4.frame8.check1 -highlightthickness 0 \
                  -text "$caption(acqzadkoSetup,texte1)" -variable panneau(acqzadko,$visuNo,messages)
               pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame4.frame8.check1 -side right -padx 5 -pady 0
            pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame4.frame8 -side left

         pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame4 -side top -fill both -expand 1

         #--- Frame pour le commentaire 2
         frame $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame5 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 2
            frame $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame5.frame10 -borderwidth 0
               checkbutton $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame5.frame10.check2 -highlightthickness 0 \
                  -text "$caption(acqzadkoSetup,texte2)" -variable panneau(acqzadko,$visuNo,save_file_log)
               pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame5.frame10.check2 -side right -padx 5 -pady 0
            pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame5.frame10 -side left

         pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame5 -side top -fill both -expand 1

         #--- Frame pour le commentaire 3
         frame $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame6 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 3
            frame $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame6.frame12 -borderwidth 0
               checkbutton $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame6.frame12.check3 -highlightthickness 0 \
                  -text "$caption(acqzadkoSetup,texte3)" -variable panneau(acqzadko,$visuNo,alarme_fin_serie)
               pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame6.frame12.check3 -side right -padx 5 -pady 0
            pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame6.frame12 -side left

         pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame6 -side top -fill both -expand 1

         #--- Frame pour le commentaire 4 : verifier_ecraser_fichier
         frame $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame7 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 4
            frame $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame7.frame12 -borderwidth 0
               checkbutton $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame7.frame12.check3 -highlightthickness 0 \
                  -text "$caption(acqzadkoSetup,texte4)" -variable panneau(acqzadko,$visuNo,verifier_ecraser_fichier)
               pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame7.frame12.check3 -side right -padx 5 -pady 0
            pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame7.frame12 -side left

         pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame7 -side top -fill both -expand 1

         #--- Frame pour le commentaire 5 : verifier_index_depart
         frame $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame8 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 5
            frame $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame8.frame12 -borderwidth 0
               checkbutton $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame8.frame12.check3 -highlightthickness 0 \
                  -text "$caption(acqzadkoSetup,texte5)" -variable panneau(acqzadko,$visuNo,verifier_index_depart)
               pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame8.frame12.check3 -side right -padx 5 -pady 0
            pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame8.frame12 -side left

         pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame8 -side top -fill both -expand 1

         #--- Frame pour le commentaire 6 : enregistrer_acquisiton_interrompue
         frame $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame9 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 6
            frame $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame9.frame12 -borderwidth 0
               checkbutton $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame9.frame12.check3 -highlightthickness 0 \
                  -text "$caption(acqzadkoSetup,texte6)" -variable panneau(acqzadko,$visuNo,enregistrer_acquisiton_interrompue)
               pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame9.frame12.check3 -side right -padx 5 -pady 0
            pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame9.frame12 -side left

         pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3.frame9 -side top -fill both -expand 1

      pack $panneau(acqzadko,$visuNo,acqzadkoSetup).frame3 -side top -fill both -expand 1
   }

}

#--- Initialisation au demarrage
::acqzadkoSetup::init

