#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_flatdark.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_flatdark.tcl
# Description    : Construction des images de corrections flat et dark
# Auteur         : Frederic Vachier
# Mise à jour $Id: atos_flatdark.tcl 10653 2014-04-07 23:21:31Z fredvachier $
#

namespace eval ::atos_flatdark {

   #
   # atos_flatdark::init
   # Chargement des captions
   #
   proc ::atos_flatdark::init { } {
      global audace caption

      wm focusmodel . passive
      wm withdraw .
      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool atos atos_flatdark.cap ]
   }



   #
   # atos_flatdark::initToConf
   # Initialisation des variables de configuration
   #
   proc ::atos_flatdark::initToConf { visuNo } {
      variable parametres

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::atos::parametres(atos,$visuNo,messages) ] }                 { set ::atos::parametres(atos,$visuNo,messages)                 "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,save_file_log) ] }            { set ::atos::parametres(atos,$visuNo,save_file_log)            "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,alarme_fin_serie) ] }         { set ::atos::parametres(atos,$visuNo,alarme_fin_serie)         "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier) ] } { set ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier) "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,verifier_index_depart) ] }    { set ::atos::parametres(atos,$visuNo,verifier_index_depart)    "1" }
   }



   #
   # atos_flatdark::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc ::atos_flatdark::confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
   }



   #
   # atos_flatdark::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc ::atos_flatdark::widgetToConf { visuNo } {
      variable parametres
      global panneau

   }



   #
   # atos_flatdark::run
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc ::atos_flatdark::run { visuNo this } {
      global audace panneau

      set panneau(atos,$visuNo,atos_flatdark) $this
      #::confGenerique::run $visuNo "$panneau(atos,$visuNo,atos_flatdark)" "::atos_flatdark" -modal 1
      ::atos_flatdark::createdialog $this $visuNo

   }



   #
   # atos_flatdark::showHelp
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc ::atos_flatdark::showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::atos::getPluginType ] ] \
         [ ::atos::getPluginDirectory ] atos_flatdark.htm
   }



   #
   # atos_flatdark::cmdClose
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc ::atos_flatdark::cmdClose { this visuNo } {

      ::atos_flatdark::widgetToConf $visuNo
      destroy $this
   }



   #
   # atos_flatdark::getLabel
   # Retourne le nom de la fenetre d extraction
   #
   proc ::atos_flatdark::getLabel { } {
      global caption

      return "$caption(atos_flatdark,bar_title)"
   }



   proc ::atos_flatdark::run_fits { this visuNo base } {

     set ::atos_tools::traitement "fits"
     ::atos_flatdark_gui::run  $visuNo $base.atos_flatdark_gui
     ::atos_flatdark::cmdClose $this $visuNo
   }



   proc ::atos_flatdark::run_avi { this visuNo base } {

      set ::atos_tools::traitement "avi"
     ::atos_flatdark_gui::run  $visuNo $base.atos_flatdark_gui
     ::atos_flatdark::cmdClose $this $visuNo
   }



   #
   # atos_flatdark::fillConfigPage
   # Creation de l'interface graphique
   #
   proc ::atos_flatdark::createdialog { this visuNo } {

      package require Img

      global caption panneau atosconf color audace

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set base "$audace(base)"
      } else {
         set base ".visu$visuNo"
      }

      #--- Creation de la fenetre
      if { [winfo exists $this] } {
         wm withdraw $this
         wm deiconify $this
         focus $this
         return
      }
      toplevel $this -class Toplevel

      set posx_config [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $this +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $this 1 1
      wm title $this $caption(atos_flatdark,bar_title)
      wm protocol $this WM_DELETE_WINDOW "::atos_flatdark::cmdClose $this $visuNo"

      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::atos_flatdark::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set frm $this.frm_atos_flatdark_fits

      #--- Cree un frame pour afficher le status de la base
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $this -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un label pour le titre
        label $frm.titre -font $atosconf(font,arial_14_b) -text "$caption(atos_flatdark,titre)"
        pack $frm.titre -in $frm -side top -padx 3 -pady 3

        #--- Cree un frame pour les 2 actions de traitement
        frame $frm.traitement -borderwidth 1 -relief raised -cursor arrow
        pack $frm.traitement -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

        #--- Creation du traitement cdl par liste de fits
        frame $frm.traitement.fits -borderwidth 1 -relief raised -cursor arrow
        pack $frm.traitement.fits -in $frm.traitement -side left -expand 0 -fill x -padx 1 -pady 1

           #--- Creation du bouton
           image create photo .visu -format PNG -file [ file join $audace(rep_plugin) tool atos img bouton_visu.png ]
           button $frm.traitement.fits.ico -image .visu -borderwidth 2 -width 130 -height 130 -compound center \
              -command "::atos_flatdark::run_fits $this $visuNo $base" -state disabled
           pack $frm.traitement.fits.ico -in $frm.traitement.fits \
              -side top -anchor w -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
           DynamicHelp::add  $frm.traitement.fits.ico -text "Traitement par lot d'images"

        #--- Creation du traitement cdl par  avi
        frame $frm.traitement.avi -borderwidth 1 -relief raised -cursor arrow
        pack $frm.traitement.avi -in $frm.traitement -side right -expand 0 -fill x -padx 1 -pady 1

           #--- Creation du bouton
           image create photo .video -format PNG -file [ file join $audace(rep_plugin) tool atos img bouton_video.png ]
           button $frm.traitement.avi.ico -image .video -borderwidth 2 -width 130 -height 130 -compound center \
              -command "::atos_flatdark::run_avi $this $visuNo $base"
           pack $frm.traitement.avi.ico -in $frm.traitement.avi \
              -side left -anchor w -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
           DynamicHelp::add  $frm.traitement.avi.ico -text "Traitement direct de la video"

        #--- Cree un frame pour  les boutons d action
        frame $frm.action -borderwidth 1 -relief raised -cursor arrow
        pack $frm.action -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

           #--- Creation du bouton fermer
           button $frm.action.fermer -text "$caption(atos_flatdark,fermer)" -borderwidth 2 \
              -command "::atos_flatdark::cmdClose $this $visuNo"
           pack $frm.action.fermer -in $frm.action -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $frm.action.aide -text "$caption(atos_flatdark,aide)" -borderwidth 2 \
              -command "::audace::showHelpPlugin tool atos atos_flatdark.htm"
           pack $frm.action.aide -in $frm.action -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

   }

}

#--- Initialisation au demarrage
