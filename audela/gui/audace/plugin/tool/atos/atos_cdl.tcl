#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_cdl.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_cdl.tcl
# Description    : outil de mesure photometrique sans GUI
# Auteur         : Frederic Vachier
# Mise à jour $Id: atos_cdl.tcl 12575 2016-01-10 17:25:14Z robertdelmas $
#

namespace eval ::atos_cdl {

   #
   # atos_cdl::init
   # Chargement des captions
   #
   proc ::atos_cdl::init { } {
      global audace

      wm focusmodel . passive
      wm withdraw .
      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool atos atos_cdl.cap ]
   }

   #
   # atos_cdl::initToConf
   # Initialisation des variables de configuration
   #
   proc ::atos_cdl::initToConf { visuNo } {
      variable parametres

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::atos::parametres(atos,$visuNo,messages) ] }                  { set ::atos::parametres(atos,$visuNo,messages)                 "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,save_file_log) ] }             { set ::atos::parametres(atos,$visuNo,save_file_log)            "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,alarme_fin_serie) ] }          { set ::atos::parametres(atos,$visuNo,alarme_fin_serie)         "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier) ] }  { set ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier) "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,verifier_index_depart) ] }     { set ::atos::parametres(atos,$visuNo,verifier_index_depart)    "1" }
   }

   #
   # atos_cdl::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc ::atos_cdl::confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set ::atos_cdl::panneau(atos,$visuNo,messages)                 $::atos::parametres(atos,$visuNo,messages)
      set ::atos_cdl::panneau(atos,$visuNo,save_file_log)            $::atos::parametres(atos,$visuNo,save_file_log)
      set ::atos_cdl::panneau(atos,$visuNo,alarme_fin_serie)         $::atos::parametres(atos,$visuNo,alarme_fin_serie)
      set ::atos_cdl::panneau(atos,$visuNo,verifier_ecraser_fichier) $::atos::parametres(atos,$visuNo,verifier_ecraser_fichier)
      set ::atos_cdl::panneau(atos,$visuNo,verifier_index_depart)    $::atos::parametres(atos,$visuNo,verifier_index_depart)
   }

   #
   # atos_cdl::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc ::atos_cdl::widgetToConf { visuNo } {
      variable parametres
      global panneau

   }


   #
   # atos_cdl::run
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc ::atos_cdl::run { visuNo this } {
     global audace panneau


      set panneau(atos,$visuNo,atos_cdl) $this
      #::confGenerique::run $visuNo "$panneau(atos,$visuNo,atos_cdl)" "::atos_cdl" -modal 1

      createdialog $this $visuNo

   }

   #
   # atos_cdl::cmdApply
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc ::atos_cdl::cmdApply { visuNo } {
      ::atos_cdl::widgetToConf $visuNo
      ::atos_tools::avi_extract
   }

   #
   # atos_cdl::showHelp
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc ::atos_cdl::showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::atos::getPluginType ] ] \
         [ ::atos::getPluginDirectory ] atos_cdl.htm
   }


   #
   # atos_cdl::cmdClose
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc ::atos_cdl::cmdClose { this visuNo } {

      ::atos_cdl::widgetToConf $visuNo
      destroy $this
   }

   #
   # atos_cdl::getLabel
   # Retourne le nom de la fenetre d extraction
   #
   proc ::atos_cdl::getLabel { } {
      global caption

      return "$caption(atos_cdl,bar_title)"
   }


   proc ::atos_cdl::run_fits { this visuNo base } {

      set ::atos_tools::traitement "fits"
     ::atos_cdl_gui::run  $visuNo $base.atos_cdl_gui
     ::atos_cdl::cmdClose $this $visuNo
   }

   proc ::atos_cdl::run_avi { this visuNo base } {

      set ::atos_tools::traitement "avi"
     ::atos_cdl_gui::run  $visuNo $base.atos_cdl_gui
     ::atos_cdl::cmdClose $this $visuNo
   }


   #
   # atos_cdl::fillConfigPage
   # Creation de l'interface graphique
   #
   proc ::atos_cdl::createdialog { this visuNo } {

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
      wm title $this $caption(atos_cdl,bar_title)
      wm protocol $this WM_DELETE_WINDOW "::atos_cdl::cmdClose $this $visuNo"


      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::atos_cdl::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set frm $this.frm_atos_cdl_fits

      #--- Cree un frame pour afficher le status de la base
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $this -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un label pour le titre
        label $frm.titre -font $atosconf(font,arial_14_b) -text "$caption(atos_cdl,titre)"
        pack $frm.titre -in $frm -side top -padx 3 -pady 3

        #--- Cree un frame pour les 2 actions de traitement
        frame $frm.traitement -borderwidth 1 -relief raised -cursor arrow
        pack $frm.traitement -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

        #--- Creation du traitement cdl par liste de fits
        frame $frm.traitement.fits -borderwidth 1 -relief raised -cursor arrow
        pack $frm.traitement.fits -in $frm.traitement -side left -expand 0 -fill x -padx 1 -pady 1

           #--- Creation du bouton
           image create photo .visu -format PNG -file [ file join $audace(rep_plugin) tool atos img bouton_visu.png ]
           button $frm.traitement.fits.ico -image .visu\
              -borderwidth 2 -width 130 -height 130 -compound center \
              -command "::atos_cdl::run_fits $this $visuNo $base"
           pack $frm.traitement.fits.ico -in $frm.traitement.fits \
              -side top -anchor w -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
           DynamicHelp::add  $frm.traitement.fits.ico -text "$caption(atos_cdl,traite_img)"

        #--- Creation du traitement cdl par  avi
        frame $frm.traitement.avi -borderwidth 1 -relief raised -cursor arrow
        pack $frm.traitement.avi -in $frm.traitement -side right -expand 0 -fill x -padx 1 -pady 1

           #--- Creation du bouton
           image create photo .video -format PNG -file [ file join $audace(rep_plugin) tool atos img bouton_video.png ]
           button $frm.traitement.avi.ico -image .video\
              -borderwidth 2 -width 130 -height 130 -compound center \
              -command "::atos_cdl::run_avi $this $visuNo $base"
           pack $frm.traitement.avi.ico -in $frm.traitement.avi \
              -side left -anchor w -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
           DynamicHelp::add  $frm.traitement.avi.ico -text "$caption(atos_cdl,traite_video)"

        #--- Cree un frame pour  les boutons d action
        frame $frm.action -borderwidth 1 -relief raised -cursor arrow
        pack $frm.action -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

           #--- Creation du bouton fermer
           button $frm.action.fermer -text "$caption(atos_cdl,fermer)" -borderwidth 2 \
              -command "::atos_cdl::cmdClose $this $visuNo"
           pack $frm.action.fermer -in $frm.action -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $frm.action.aide -text "$caption(atos_cdl,aide)" -borderwidth 2 \
              -command "::audace::showHelpPlugin tool atos atos_cdl.htm"
           pack $frm.action.aide -in $frm.action -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

   }

}

#--- Initialisation au demarrage
::atos_cdl::init
