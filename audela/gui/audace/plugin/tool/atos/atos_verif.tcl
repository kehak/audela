#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_verif.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_verif.tcl
# Description    : Utilitaires de verification de la video
# Auteur         : Frederic Vachier
# Mise à jour $Id: atos_verif.tcl 12575 2016-01-10 17:25:14Z robertdelmas $
#


namespace eval ::atos_verif {

   #
   # atos_verif::init
   # Chargement des captions
   #
   proc init { } {
      global audace

      wm focusmodel . passive
      wm withdraw .
      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool atos atos_verif.cap ]
   }

   #
   # atos_verif::initToConf
   # Initialisation des variables de configuration
   #
   proc initToConf { visuNo } {
      variable parametres

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::atos::parametres(atos,$visuNo,messages) ] }                           { set ::atos::parametres(atos,$visuNo,messages)                           "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,save_file_log) ] }                      { set ::atos::parametres(atos,$visuNo,save_file_log)                      "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,alarme_fin_serie) ] }                   { set ::atos::parametres(atos,$visuNo,alarme_fin_serie)                   "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier) ] }           { set ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier)           "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,verifier_index_depart) ] }              { set ::atos::parametres(atos,$visuNo,verifier_index_depart)              "1" }
   }

   #
   # atos_verif::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set ::atos_verif::panneau(atos,$visuNo,messages)                   $::atos::parametres(atos,$visuNo,messages)
      set ::atos_verif::panneau(atos,$visuNo,save_file_log)              $::atos::parametres(atos,$visuNo,save_file_log)
      set ::atos_verif::panneau(atos,$visuNo,alarme_fin_serie)           $::atos::parametres(atos,$visuNo,alarme_fin_serie)
      set ::atos_verif::panneau(atos,$visuNo,verifier_ecraser_fichier)   $::atos::parametres(atos,$visuNo,verifier_ecraser_fichier)
      set ::atos_verif::panneau(atos,$visuNo,verifier_index_depart)      $::atos::parametres(atos,$visuNo,verifier_index_depart)
   }

   #
   # atos_verif::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { visuNo } {
      variable parametres
      global panneau

   }


   #
   # atos_verif::run
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc run { visuNo this } {
     global audace panneau


      set panneau(atos,$visuNo,atos_verif) $this
      #::confGenerique::run $visuNo "$panneau(atos,$visuNo,atos_verif)" "::atos_verif" -modal 1

      createdialog $this $visuNo

   }

   #
   # atos_verif::cmdApply
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc cmdApply { visuNo } {
      ::atos_verif::widgetToConf $visuNo
      ::atos_tools::avi_extract
   }

   #
   # atos_verif::showHelp
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::atos::getPluginType ] ] \
         [ ::atos::getPluginDirectory ] atos_verif.htm
   }


   #
   # atos_verif::cmdClose
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc cmdClose { this visuNo } {

      ::atos_verif::widgetToConf $visuNo
      destroy $this
   }

   #
   # atos_verif::getLabel
   # Retourne le nom de la fenetre de verification
   #
   proc getLabel { } {
      global caption

      return "$caption(atos_verif,titre)"
   }


   #
   # atos_verif::chgdir
   # Ouvre une boite de dialogue pour choisir un nom  de repertoire
   #
   proc chgdir { This } {
      global caption
      global cwdWindow
      global audace

      #--- Initialisation des variables a 2 (0 et 1 reservees a Configuration --> Repertoires)
      set cwdWindow(rep_images)      "2"
      set cwdWindow(rep_travail)     "2"
      set cwdWindow(rep_scripts)     "2"
      set cwdWindow(rep_catalogues)  "2"
      set cwdWindow(rep_userCatalog) "2"
      set cwdWindow(rep_archives)    "2"

      set parent "$audace(base)"
      set title "Choisir un repertoire de destination"
      set rep "$audace(rep_images)"

      set numerror [ catch { set filename "[ ::cwdWindow::tkplus_chooseDir "$rep" $title $This ]" } msg ]
      if { $numerror == "1" } {
         set filename "[ ::cwdWindow::tkplus_chooseDir "[pwd]" $title $This ]"
      }


      ::console::affiche_resultat $audace(rep_images)

      $This delete 0 end
      $This insert 0 $filename

   }



   #
   # atos_verif::fillConfigPage
   # Creation de l'interface graphique
   #
   proc createdialog { this visuNo } {

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
      wm title $this $caption(atos_verif,titre)
      wm protocol $this WM_DELETE_WINDOW "::atos_verif::cmdClose $this $visuNo"


      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::atos_verif::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set frm $this.frmverif
      set ::atos_verif::nomfichavi "/data/Occultations/20100605_80SAPPHO/sapphoseg.00.avi"

      #--- Cree un frame pour afficher le status de la base
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $this -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un label pour le titre
        label $frm.titre -font $atosconf(font,arial_14_b) \
              -text "$caption(atos_verif,titre)"
        pack $frm.titre \
             -in $frm -side top -padx 3 -pady 3

        #--- Cree un frame pour
        frame $frm.open \
              -borderwidth 1 -relief raised -cursor arrow
        pack $frm.open \
             -in $frm -side top -expand 0 -fill x -padx 1 -pady 1
        #--- Creation du bouton select
        button $frm.open.but_select \
           -text "..." -borderwidth 2 -takefocus 1 \
           -command "::atos_tools::avi_select $visuNo $frm"
        pack $frm.open.but_select \
           -side left -anchor e \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Cree un label pour le chemin de l'AVI
        entry $frm.open.avipath -textvariable ::atos_verif::nomfichavi
        pack $frm.open.avipath -side left -padx 3 -pady 1 -expand true -fill x



        #--- Cree un bouton pour le lancement de la verif
        set btnav [frame $frm.btnav -borderwidth 0]
        pack $btnav -in $frm -side top

           #--- Creation du bouton one shot
           image create photo .verif -format PNG -file [ file join $audace(rep_plugin) tool atos img verif.png ]
           button $frm.verif -image .verif\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::atos_tools::avi_verif  $visuNo $frm"
           pack $frm.verif \
              -in $frm.btnav \
              -side left -anchor w \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
           DynamicHelp::add $frm.verif -text "Lance la vérification"








          #--- Affichage positions
          frame $frm.results -borderwidth 1 -relief raised -cursor arrow
          pack $frm.results -in $frm -side top -expand 0 -fill x -padx 1 -pady 1


             #--- Cree un label pour le titre
             label $frm.results.txt -font $atosconf(font,courier_10) \
                   -text "Verification :\n"
             pack $frm.results.txt \
                  -in $frm.results -side top -padx 3 -pady 3





   #---
        #--- Cree un frame pour  les boutons d action
        frame $frm.action \
              -borderwidth 1 -relief raised -cursor arrow
        pack $frm.action \
             -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

           #--- Creation du bouton fermer
           button $frm.action.fermer \
              -text "$caption(atos_verif,fermer)" -borderwidth 2 \
              -command "::atos_verif::cmdClose $this $visuNo"
           pack $frm.action.fermer -in $frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $frm.action.aide \
              -text "$caption(atos_verif,aide)" -borderwidth 2 \
              -command "::audace::showHelpPlugin tool atos atos_verif.htm"
           pack $frm.action.aide -in $frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

   }

}

#--- Initialisation au demarrage
::atos_verif::init

