#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_ocr_gui.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_ocr_gui.tcl
# Description    : GUI de la reconnaissance de caractere 
# Auteur         : Frederic Vachier
# Mise à jour $Id: atos_ocr_gui.tcl 14038 2016-09-12 07:43:30Z jberthier $
#

namespace eval ::atos_ocr_gui {

   #
   # Chargement des captions
   #
   proc ::atos_ocr_gui::init { } {
      global audace

      wm focusmodel . passive
      wm withdraw .
      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool atos atos_ocr_gui.cap ]
   }



   #
   # Initialisation des variables de configuration
   #
   proc ::atos_ocr_gui::initToConf { visuNo } {
      variable parametres

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [info exists ::atos::parametres(atos,$visuNo,messages)]}                 {set ::atos::parametres(atos,$visuNo,messages)                 "1"}
      if { ! [info exists ::atos::parametres(atos,$visuNo,save_file_log)]}            {set ::atos::parametres(atos,$visuNo,save_file_log)            "1"}
      if { ! [info exists ::atos::parametres(atos,$visuNo,alarme_fin_serie)]}         {set ::atos::parametres(atos,$visuNo,alarme_fin_serie)         "1"}
      if { ! [info exists ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier)]} {set ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier) "1"}
      if { ! [info exists ::atos::parametres(atos,$visuNo,verifier_index_depart)]}    {set ::atos::parametres(atos,$visuNo,verifier_index_depart)    "1"}

   }



   #
   # Charge la configuration dans des variables locales
   #
   proc ::atos_ocr_gui::confToWidget { visuNo } {

      variable parametres
      global panneau

      #--- confToWidget
      set ::atos_ocr_gui::panneau(atos,$visuNo,messages)                 $::atos::parametres(atos,$visuNo,messages)
      set ::atos_ocr_gui::panneau(atos,$visuNo,save_file_log)            $::atos::parametres(atos,$visuNo,save_file_log)
      set ::atos_ocr_gui::panneau(atos,$visuNo,alarme_fin_serie)         $::atos::parametres(atos,$visuNo,alarme_fin_serie)
      set ::atos_ocr_gui::panneau(atos,$visuNo,verifier_ecraser_fichier) $::atos::parametres(atos,$visuNo,verifier_ecraser_fichier)
      set ::atos_ocr_gui::panneau(atos,$visuNo,verifier_index_depart)    $::atos::parametres(atos,$visuNo,verifier_index_depart)

      set ::atos_ocr_tools::rect_img              ""
      set ::atos_ocr_tools::datation_methode      ""
      set ::atos_ocr_tools::active_ocr            0
      set ::atos_ocr_tools::nbverif               0
      set ::atos_ocr_tools::nbocr                 0
      set ::atos_ocr_tools::nbinterp              0

   }



   #
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc ::atos_ocr_gui::widgetToConf { visuNo } {
      variable parametres
      global panneau

   }



   #
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc ::atos_ocr_gui::run { visuNo this } {

      global audace panneau

      set panneau(atos,$visuNo,atos_ocr_gui) $this
      createdialog $this $visuNo   

   }



   #
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc ::atos_ocr_gui::showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::atos::getPluginType ] ] \
         [ ::atos::getPluginDirectory ] atos_ocr_gui.htm
   }



   #
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc ::atos_ocr_gui::closeWindow { this visuNo } {

      ::plotxy::clf 1
      ::atos_ocr_gui::widgetToConf $visuNo
      
      destroy $this
   }



   #
   # Creation de l'interface graphique
   #
   proc ::atos_ocr_gui::createdialog { this visuNo } {

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

      if { $::atos_tools::traitement == "fits" } { wm title $this $caption(atos_ocr_gui,bar_title_fits) }
      if { $::atos_tools::traitement == "avi"  } { wm title $this $caption(atos_ocr_gui,bar_title_avi) }

      wm protocol $this WM_DELETE_WINDOW "::atos_ocr_gui::closeWindow $this $visuNo"

      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::atos_ocr_gui::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set frm $this.frm_atos_ocr_gui
      set ::atos_gui::frame(base) $frm

      if { $::atos_tools::traitement == "fits" } { set titre $caption(atos_ocr_gui,titre_fits) }
      if { $::atos_tools::traitement == "avi"  } { set titre $caption(atos_ocr_gui,titre_avi) }

      #--- Cree un frame pour afficher le status de la base
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $this -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un label pour le titre
        label $frm.titre -font $atosconf(font,arial_14_b) -text "$titre"
        pack $frm.titre -in $frm -side top -padx 3 -pady 3

        if { $::atos_tools::traitement == "fits" } { 

          #--- Cree un frame pour la gestion de fichier
          frame $frm.form -borderwidth 1 -relief raised -cursor arrow
          pack $frm.form -in $frm -side top -expand 0 -fill x -padx 1 -pady 1
    
            #--- Cree un frame pour la gestion de fichier
            frame $frm.form.butopen -borderwidth 1 -cursor arrow
            pack $frm.form.butopen -in $frm.form -side left -expand 0 -fill x -padx 1 -pady 1
    
               #--- Creation du bouton open
               button $frm.form.butopen.open -text "open" -borderwidth 2 \
                  -command "::atos_ocr_tools::open_flux $visuNo"
               pack $frm.form.butopen.open -in $frm.form.butopen -side left -anchor e \
                  -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
    
            #--- Cree un frame pour la gestion de fichier
            frame $frm.form.field -borderwidth 1 -cursor arrow
            pack $frm.form.field -in $frm.form -side left -expand 0 -fill x -padx 1 -pady 1
    
               #--- Cree un frame pour afficher les intitules
               set intitle [frame $frm.form.field.l -borderwidth 0]
               pack $intitle -in $frm.form.field -side left
  
                 #--- Cree un label pour
                 label $intitle.destdir -font $atosconf(font,courier_10) -padx 3 \
                       -text $caption(atos_ocr_gui,dir_images)
                 pack $intitle.destdir -in $intitle -side top -padx 3 -pady 1 -anchor w
  
                 #--- Cree un label pour
                 label $intitle.prefix -font $atosconf(font,courier_10) \
                       -text $caption(atos_ocr_gui,prefix_images)
                 pack $intitle.prefix -in $intitle -side top -padx 3 -pady 1 -anchor w
    
    
               #--- Cree un frame pour afficher les valeurs
               set inparam [frame $frm.form.field.v -borderwidth 0]
               pack $inparam -in $frm.form.field -side left -expand 0 -fill x
  
               set ::atos_gui::frame(open,fields) $inparam
  
                 #--- Cree un label pour le repetoire destination
                 entry $inparam.destdir -fg $color(blue) -width 40
                 pack $inparam.destdir -in $inparam -side top -pady 1 -anchor w
  
                 #--- Cree un label pour le prefixe
                 entry $inparam.prefix  -fg $color(blue)
                 pack $inparam.prefix -in $inparam -side top -pady 1 -anchor w
    
               #--- Cree un frame pour afficher les extras
               set inbutton [frame $frm.form.field.e -borderwidth 0]
               pack $inbutton -in $frm.form.field -side left -expand 0 -fill x
  
                 #--- Cree un button
                 button $inbutton.chgdir \
                  -text "..." -borderwidth 2 \
                  -command "::atos_tools::chgdir $inparam.destdir" 
                 pack $inbutton.chgdir -in $inbutton -side top -pady 0 -anchor w
  
                 #--- Cree un label pour le nb d image
                 label $inbutton.blank -font $atosconf(font,courier_10) -text ""
                 pack $inbutton.blank -in $inbutton -side top -padx 3 -pady 1 -anchor w

        }

        if { $::atos_tools::traitement == "avi" }  { 

          #--- Cree un frame pour 
          frame $frm.open -borderwidth 1 -relief raised -cursor arrow
          pack $frm.open -in $frm -side top -expand 0 -fill x -padx 1 -pady 1
 
          #--- Creation du bouton open
          button $frm.open.but_open -text "open" -borderwidth 2 -command "::atos_ocr_tools::open_flux $visuNo"
          pack $frm.open.but_open -side left -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
 
          #--- Creation du bouton select
          button $frm.open.but_select -text "..." -borderwidth 2 -takefocus 1 -command "::atos_ocr_tools::select $visuNo"
          pack $frm.open.but_select -side left -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
 
          #--- Cree un label pour le chemin de l'AVI
          entry $frm.open.avipath 
          pack $frm.open.avipath -side left -padx 3 -pady 1 -expand true -fill x

        }

        set info_load [frame $frm.info_load]
        pack $info_load -in $frm -side top  -padx 1 -pady 1

        set ::atos_gui::frame(info_load) $info_load

        #--- Cree un label pour le nb d image
        label $info_load.status -font $atosconf(font,courier_10) -text ""
        #--- Cree un label pour le nb d image
        label $info_load.nbtotal -font $atosconf(font,courier_10) -text ""

        grid $info_load.status $info_load.nbtotal

        #--- Creation de la barre de defilement
        scale $frm.scrollbar -from 0 -to 1 -length 600 -variable ::atos_tools::scrollbar \
           -label "" -orient horizontal -state disabled
        pack $frm.scrollbar -in $frm -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

        set ::atos_gui::frame(scrollbar) $frm.scrollbar

        #--- Cree un frame pour afficher
        set btnav [frame $frm.btnav -borderwidth 0]
        pack $btnav -in $frm -side top

        #--- Creation du bouton quick prev image
        image create photo .arr -format PNG -file [ file join $audace(rep_plugin) tool atos img arr.png ]
        button $frm.qprevimage -image .arr -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::atos_ocr_tools::quick_prev_image $visuNo"
        pack $frm.qprevimage -in $frm.btnav -side left -anchor w -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton prev image
        image create photo .arn -format PNG -file [ file join $audace(rep_plugin) tool atos img arn.png ]
        button $frm.previmage -image .arn -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::atos_ocr_tools::prev_image $visuNo"
        pack $frm.previmage -in $frm.btnav -side left -anchor w -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton next image
        image create photo .avn -format PNG -file [ file join $audace(rep_plugin) tool atos img avn.png ]
        button $frm.nextimage -image .avn -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::atos_ocr_tools::next_image $visuNo"
        pack $frm.nextimage -in $frm.btnav -side left -anchor w -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton quick next image
        image create photo .avr -format PNG -file [ file join $audace(rep_plugin) tool atos img avr.png ]
        button $frm.qnextimage -image .avr -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::atos_ocr_tools::quick_next_image $visuNo"
        pack $frm.qnextimage -in $frm.btnav -side left -anchor w -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          #--- Affichage positions
          frame $frm.pos \
                -borderwidth 1 -relief raised -cursor arrow
          pack $frm.pos \
               -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

             #--- Creation du bouton setmin
             button $frm.pos.setmin \
                -text "setmin" -borderwidth 2 \
                -command "::atos_tools::setmin"
             pack $frm.pos.setmin \
                -in $frm.pos \
                -side left -anchor w \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             #--- Creation du bouton setmax
             button $frm.pos.setmax \
                -text "setmax" -borderwidth 2 \
                -command "::atos_tools::setmax"
             pack $frm.pos.setmax \
                -in $frm.pos \
                -side left -anchor w \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             #--- Cree un frame pour afficher
             frame $frm.pos.min -borderwidth 0
             pack $frm.pos.min -in $frm.pos -side left

                #--- Cree un label pour
                #entry $frm.datemin -fg $color(blue) -relief sunken
                #pack $frm.datemin -in $frm.pos.min -side top -pady 1 -anchor w
                #--- Cree un label pour
                entry $frm.posmin -fg $color(blue) -relief sunken
                pack $frm.posmin -in $frm.pos.min -side top -pady 1 -anchor w

                set ::atos_gui::frame(posmin) $frm.posmin

             #--- Cree un frame pour afficher
             frame $frm.pos.max -borderwidth 0
             pack $frm.pos.max -in $frm.pos -side left

                #--- Cree un label pour
                #entry $frm.datemax -fg $color(blue) -relief sunken
                #pack $frm.datemax -in $frm.pos.max -side top -pady 1 -anchor w
                #--- Cree un label pour
                entry $frm.posmax -fg $color(blue) -relief sunken
                pack $frm.posmax -in $frm.pos.max -side top -pady 1 -anchor w

                set ::atos_gui::frame(posmax) $frm.posmax

             #--- Creation du bouton setmin
             button $frm.pos.crop -text "crop" -borderwidth 2 -command "::atos_tools::crop $visuNo"
             pack $frm.pos.crop -in $frm.pos -side left -anchor w -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             #--- Creation du bouton setmax
             button $frm.pos.uncrop -text "uncrop" -borderwidth 2 -command "::atos_tools::uncrop $visuNo"
             pack $frm.pos.uncrop -in $frm.pos -side left -anchor w -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

  #--- infos datation

          #--- Cree un frame 
          frame $frm.tdatation -borderwidth 0 -cursor arrow
          pack $frm.tdatation -in $frm -side top -anchor w

          #---Titre
          label $frm.tdatation.title -font $atosconf(font,arial_10_b) -text $caption(atos_ocr_gui,datation)
          pack  $frm.tdatation.title -in $frm.tdatation -side top -anchor w -ipady 10

          #--- Cree un frame pour la partie datation
          frame $frm.datation -borderwidth 1 -relief raised -cursor arrow 
          pack $frm.datation -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

          #--- Cree un frame 
          frame $frm.datation.values -borderwidth 0 -cursor arrow
          pack $frm.datation.values -in $frm.datation -side top -expand 1

          #--- Cree un frame pour activation/desactivation interpolation / ocr
          set ocr [frame $frm.datation.values.setup]
          pack $ocr -in $frm.datation.values -side top -padx 30 -pady 1

          set ::atos_gui::frame(ocr_setup) $ocr

             #--- Cree un frame pour le choix interpolation
             frame $ocr.interpole -borderwidth 0 -cursor arrow
             pack  $ocr.interpole -in $ocr -side top -expand 0 -anchor w -padx 10

               radiobutton $ocr.interpole.but -font $atosconf(font,courier_10_b) -text $caption(atos_ocr_gui,interpole) \
                           -value 0 -variable ::atos_ocr_tools::active_ocr -command "::atos_ocr_tools::select_ocr $visuNo" 
               pack $ocr.interpole.but -in $ocr.interpole -side left -padx 1 -pady 2

             #--- Cree un frame pour le choix ocr
             frame $ocr.ocr -borderwidth 0 -cursor arrow
             pack  $ocr.ocr -in $ocr -side top -expand 0 -anchor w -padx 10

               #--- Cree un frame l'activation de l'OCR
               frame $ocr.ocr.check -borderwidth 0 -cursor arrow
               pack  $ocr.ocr.check -in $ocr.ocr -side left -expand 0 -anchor w

                  radiobutton $ocr.ocr.check.but -font $atosconf(font,courier_10_b) -text $caption(atos_ocr_gui,ocr) \
                              -value 1 -variable ::atos_ocr_tools::active_ocr -command "::atos_ocr_tools::select_ocr $visuNo" 
                  pack $ocr.ocr.check.but -in $ocr.ocr.check -side left -padx 1 -pady 2

               #--- Cree un frame pour le type d'incrustateur
               frame $ocr.ocr.incrust -borderwidth 0 -cursor arrow
               pack  $ocr.ocr.incrust -in $ocr.ocr -side left -expand 0 -anchor w -padx 10

                 #--- Cree un label
                 label $ocr.ocr.incrust.lab -font $atosconf(font,courier_10_b) \
                       -text $caption(atos_ocr_gui,type_incrustateur)
                 pack  $ocr.ocr.incrust.lab -in $ocr.ocr.incrust -side left -anchor w -padx 1 -pady 2

                 #--- Cree un spinbox
                 spinbox $ocr.ocr.incrust.spin -font $atosconf(font,courier_10) -fg $color(blue) \
                         -value [list "IOTA-VTI" "TIM-10" "KIWI-OSD" "SHARPCAP"] -width 10 -state readonly
                 pack  $ocr.ocr.incrust.spin -in $ocr.ocr.incrust -side left -anchor w 

               #--- Cree un frame pour le selecteur du champ date
               frame $ocr.ocr.selectdate -borderwidth 0 -cursor arrow
               pack  $ocr.ocr.selectdate -in $ocr.ocr -side left -expand 0 -anchor w -padx 10

                 #--- Cree un label
                 label $ocr.ocr.selectdate.lab -font $atosconf(font,courier_10) -font $atosconf(font,courier_10_b) \
                       -text $caption(atos_ocr_gui,date_field)
                 pack  $ocr.ocr.selectdate.lab -in $ocr.ocr.selectdate -side left -anchor w -padx 1 -pady 2

                 #--- Cree un bouton
                 button $ocr.ocr.selectdate.box -text $caption(atos_ocr_gui,select) -borderwidth 1 -takefocus 1 \
                        -command "::atos_ocr_tools::select_time $visuNo" -state disabled
                 pack $ocr.ocr.selectdate.box -in $ocr.ocr.selectdate -side left -anchor e 

          #--- Cree un frame pour activation/desactivation ocr
          set datetime [frame $frm.datation.values.datetime -borderwidth 1]
          pack $datetime -in $frm.datation.values -side top -padx 30 -pady 1

          set ::atos_gui::frame(datetime) $datetime

              #--- Cree un frame
              frame $datetime.y -borderwidth 0 -cursor arrow 
              pack  $datetime.y -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.y.lab -text "Y"
                 pack $datetime.y.lab -in $datetime.y -side top -padx 0 -expand 0

                 #--- Label du nom de la configuration de l'en-tete FITS
                 entry $datetime.y.val -takefocus 0 -justify left -width 5 -takefocus 1
                 pack $datetime.y.val -in $datetime.y -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.a1 -borderwidth 0 -cursor arrow
              pack  $datetime.a1 -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.a1.lab -text ""
                 pack $datetime.a1.lab -in $datetime.a1 -side top -padx 0 -expand 0
                 #--- Label de l'en-tete FITS
                 label $datetime.a1.lab2 -text "-"
                 pack $datetime.a1.lab2 -in $datetime.a1 -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.m -borderwidth 0 -cursor arrow
              pack  $datetime.m -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.m.lab -text "M"
                 pack $datetime.m.lab -in $datetime.m -side top -padx 0 -expand 0

                 #--- Label du nom de la configuration de l'en-tete FITS
                 entry $datetime.m.val  -takefocus 0 -justify left -width 3 -takefocus 1
                 pack $datetime.m.val -in $datetime.m -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.a2 -borderwidth 0 -cursor arrow
              pack  $datetime.a2 -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.a2.lab -text ""
                 pack $datetime.a2.lab -in $datetime.a2 -side top -padx 0 -expand 0
                 #--- Label de l'en-tete FITS
                 label $datetime.a2.lab2 -text "-"
                 pack $datetime.a2.lab2 -in $datetime.a2 -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.d -borderwidth 0 -cursor arrow
              pack  $datetime.d -in $datetime -side left -expand 0 -anchor w -expand 0

                 #--- Label de l'en-tete FITS
                 label $datetime.d.lab -text "D"
                 pack $datetime.d.lab -in $datetime.d -side top -padx 0 -expand 0

                 #--- Label du nom de la configuration de l'en-tete FITS
                 entry $datetime.d.val  -takefocus 0 -justify left -width 3 -takefocus 1
                 pack $datetime.d.val -in $datetime.d -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.a3 -borderwidth 0 -cursor arrow
              pack  $datetime.a3 -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.a3.lab -text ""
                 pack $datetime.a3.lab -in $datetime.a3 -side top -padx 0 -expand 0
                 #--- Label de l'en-tete FITS
                 label $datetime.a3.lab2 -text "T"
                 pack $datetime.a3.lab2 -in $datetime.a3 -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.h -borderwidth 0 -cursor arrow
              pack  $datetime.h -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.h.lab -text "H"
                 pack $datetime.h.lab -in $datetime.h -side top -padx 0 -expand 0

                 #--- Label du nom de la configuration de l'en-tete FITS
                 entry $datetime.h.val  -takefocus 0 -justify left -width 3 -takefocus 1
                 pack $datetime.h.val -in $datetime.h -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.a4 -borderwidth 0 -cursor arrow
              pack  $datetime.a4 -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.a4.lab -text ""
                 pack $datetime.a4.lab -in $datetime.a4 -side top -padx 0 -expand 0
                 #--- Label de l'en-tete FITS
                 label $datetime.a4.lab2 -text ":"
                 pack $datetime.a4.lab2 -in $datetime.a4 -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.min -borderwidth 0 -cursor arrow
              pack  $datetime.min -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.min.lab -text "m"
                 pack $datetime.min.lab -in $datetime.min -side top -padx 0 -expand 0

                 #--- Label du nom de la configuration de l'en-tete FITS
                 entry $datetime.min.val  -takefocus 0 -justify left -width 3 -takefocus 1
                 pack $datetime.min.val -in $datetime.min -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.a5 -borderwidth 0 -cursor arrow
              pack  $datetime.a5 -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.a5.lab -text ""
                 pack $datetime.a5.lab -in $datetime.a5 -side top -padx 0 -expand 0
                 #--- Label de l'en-tete FITS
                 label $datetime.a5.lab2 -text ":"
                 pack $datetime.a5.lab2 -in $datetime.a5 -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.s -borderwidth 0 -cursor arrow
              pack  $datetime.s -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.s.lab -text "s"
                 pack $datetime.s.lab -in $datetime.s -side top -padx 0 -expand 0

                 #--- Label du nom de la configuration de l'en-tete FITS
                 entry $datetime.s.val  -takefocus 0 -justify left -width 3 -takefocus 1
                 pack $datetime.s.val -in $datetime.s -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.a6 -borderwidth 0 -cursor arrow
              pack  $datetime.a6 -in $datetime -side left -expand 0 -anchor w

                 #--- Label
                 label $datetime.a6.lab -text ""
                 pack $datetime.a6.lab -in $datetime.a6 -side top -padx 0 -expand 0
                 #--- Entry
                 label $datetime.a6.lab2 -text "."
                 pack $datetime.a6.lab2 -in $datetime.a6 -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.ms -borderwidth 0 -cursor arrow
              pack  $datetime.ms -in $datetime -side left -expand 0 -anchor w

                 #--- Label 
                 label $datetime.ms.lab -text "ms"
                 pack $datetime.ms.lab -in $datetime.ms -side top -padx 0 -expand 0

                 #--- Entry
                 entry $datetime.ms.val  -takefocus 0 -justify left -width 5 -takefocus 1
                 pack $datetime.ms.val -in $datetime.ms -side top -padx 0 -expand 0

          #--- Cree un frame pour activation/desactivation ocr
          set setunset [frame $frm.datation.values.setunset -borderwidth 1]
          pack $setunset -in $frm.datation.values -side top -padx 30 -pady 1

          set ::atos_gui::frame(setunset) $setunset

              #--- Cree un frame
              frame $setunset.t -borderwidth 0 -cursor arrow
              pack  $setunset.t -in $setunset -side left -expand 5 -anchor w

              #--- Cree un bouton
              button $setunset.t.verif -text $caption(atos_ocr_gui,ocr_verifie) -borderwidth 1 -takefocus 1 \
                                     -command "::atos_ocr_tools::verif $visuNo"
              pack $setunset.t.verif -in $setunset.t -side left -anchor e 

              #--- Cree un bouton
              button $setunset.t.ocr -text $caption(atos_ocr_gui,ocr) -borderwidth 1 -takefocus 1 \
                                     -command ""
              pack $setunset.t.ocr -in $setunset.t -side left -anchor c 

              #--- Cree un bouton
              button $setunset.t.interpol -text $caption(atos_ocr_gui,ocr_interpole) -borderwidth 1 -takefocus 1 \
                                     -command ""
              pack $setunset.t.interpol -in $setunset.t -side left -anchor w 

   #---

        #--- Cree un frame pour  les boutons d action 
        frame $frm.infofrm -borderwidth 1 -relief raised -cursor arrow
        pack $frm.infofrm -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

          #--- Cree un frame pour afficher les intitules
          set intitle [frame $frm.infofrm.l -borderwidth 0]
          pack $intitle -in $frm.infofrm -side left

            #--- Cree un label pour le status
            label $intitle.nbimage -font $atosconf(font,courier_10) -text $caption(atos_ocr_gui,ocr_nb_img)
            pack $intitle.nbimage -in $intitle -side top -anchor w

            #--- Cree un label pour le nb d image
            label $intitle.nbverif -font $atosconf(font,courier_10) -text $caption(atos_ocr_gui,ocr_nb_verif)
            pack $intitle.nbverif -in $intitle -side top -anchor w

            #--- Cree un label pour le nb d image
            label $intitle.nbocr -font $atosconf(font,courier_10) -text $caption(atos_ocr_gui,ocr_nb_ocr)
            pack $intitle.nbocr -in $intitle -side top -anchor w

            #--- Cree un label pour le nb d image
            label $intitle.nbinterp -font $atosconf(font,courier_10) -text $caption(atos_ocr_gui,ocr_nb_interpole)
            pack $intitle.nbinterp -in $intitle -side top -anchor w

          #--- Cree un frame pour afficher les valeurs
          set inparam [frame $frm.infofrm.v -borderwidth 0]
          pack $inparam -in $frm.infofrm -side left -expand 0 -fill x

            set ::atos_gui::frame(inparam) $inparam

            #--- Cree un label pour le status
            label $inparam.nbimage -font $atosconf(font,courier_10) -text "-"
            pack $inparam.nbimage -in $inparam -side top -anchor w

            #--- Cree un label pour le nb d image
            label $inparam.nbverif -font $atosconf(font,courier_10) -text "-"
            pack $inparam.nbverif -in $inparam -side top -anchor w

            #--- Cree un label pour le nb d image
            label $inparam.nbocr -font $atosconf(font,courier_10) -text "-"
            pack $inparam.nbocr -in $inparam -side top -anchor w

            #--- Cree un label pour le nb d image
            label $inparam.nbinterp -font $atosconf(font,courier_10) -text "-"
            pack $inparam.nbinterp -in $inparam -side top -anchor w

   #---

        #--- Cree un frame pour  les boutons d action 
        set action [frame $frm.action -borderwidth 1 -relief raised -cursor arrow]
        pack $frm.action -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

        set ::atos_gui::frame(action) $action

           image create photo .start -format PNG -file [ file join $audace(rep_plugin) tool atos img start.png ]
           image create photo .stop  -format PNG -file [ file join $audace(rep_plugin) tool atos img stop.png ]
           image create photo .graph -format PNG -file [ file join $audace(rep_plugin) tool atos img cdl.png ]
           image create photo .save  -format PNG -file [ file join $audace(rep_plugin) tool atos img save.png ]

           #--- Creation du bouton start
           button $frm.action.start -image .start\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::atos_ocr_tools::start $visuNo"
           pack $frm.action.start \
              -in $frm.action \
              -side left -anchor w \
              -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
           DynamicHelp::add $frm.action.start -text $caption(atos_ocr_gui,start)

           set ::atos_gui::frame(buttons,start) $frm.action.start

           #--- Creation du bouton graph
           button $frm.action.graph -image .graph\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::atos_ocr_tools::graph $visuNo"
           pack $frm.action.graph \
              -in $frm.action \
              -side left -anchor w \
              -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
           DynamicHelp::add $frm.action.graph -text $caption(atos_ocr_gui,graph)

           #--- Creation du bouton sauver
           button $frm.action.save -image .save\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::atos_ocr_tools::save $visuNo"
           pack $frm.action.save \
              -in $frm.action \
              -side left -anchor w \
              -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
           DynamicHelp::add $frm.action.save -text $caption(atos_ocr_gui,save)

           #--- Creation du bouton fermer
           button $frm.action.fermer \
              -text "$caption(atos_ocr_gui,fermer)" -borderwidth 2 \
              -command "::atos_ocr_gui::closeWindow $this $visuNo"
           pack $frm.action.fermer -in $frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $frm.action.aide \
              -text "$caption(atos_ocr_gui,aide)" -borderwidth 2 \
              -command "::audace::showHelpPlugin tool atos atos.htm extraction_heure"
           pack $frm.action.aide -in $frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

      bind $frm.scrollbar <ButtonRelease> "::atos_ocr_tools::move_scroll $visuNo"

      ::confColor::applyColor $this

   }
   
}

#--- Initialisation au demarrage
::atos_ocr_gui::init
