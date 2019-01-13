#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_cdl_gui.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_cdl_gui.tcl
# Description    : GUI de l'outil de mesure photometrique
# Auteur         : Frederic Vachier
# Mise à jour $Id: atos_cdl_gui.tcl 14424 2018-05-03 15:41:51Z fredvachier $
#

namespace eval ::atos_cdl_gui {

   #
   # Chargement des captions
   #
   proc ::atos_cdl_gui::init { } {
      global audace

      wm focusmodel . passive
      wm withdraw .
      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool atos atos_cdl_gui.cap ]

      ::atos_cdl_tools::init

   }



   #
   # Initialisation des variables de configuration
   #
   proc ::atos_cdl_gui::initToConf { visuNo } {
      variable parametres

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::atos::parametres(atos,$visuNo,messages) ] }                 { set ::atos::parametres(atos,$visuNo,messages)                           "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,save_file_log) ] }            { set ::atos::parametres(atos,$visuNo,save_file_log)                      "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,alarme_fin_serie) ] }         { set ::atos::parametres(atos,$visuNo,alarme_fin_serie)                   "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier) ] } { set ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier)           "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,verifier_index_depart) ] }    { set ::atos::parametres(atos,$visuNo,verifier_index_depart)              "1" }

   }



   #
   # Charge la configuration dans des variables locales
   #
   proc ::atos_cdl_gui::confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set ::atos_cdl_gui::panneau(atos,$visuNo,messages)                   $::atos::parametres(atos,$visuNo,messages)
      set ::atos_cdl_gui::panneau(atos,$visuNo,save_file_log)              $::atos::parametres(atos,$visuNo,save_file_log)
      set ::atos_cdl_gui::panneau(atos,$visuNo,alarme_fin_serie)           $::atos::parametres(atos,$visuNo,alarme_fin_serie)
      set ::atos_cdl_gui::panneau(atos,$visuNo,verifier_ecraser_fichier)   $::atos::parametres(atos,$visuNo,verifier_ecraser_fichier)
      set ::atos_cdl_gui::panneau(atos,$visuNo,verifier_index_depart)      $::atos::parametres(atos,$visuNo,verifier_index_depart)

   }



   #
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc ::atos_cdl_gui::widgetToConf { visuNo } {
      variable parametres
      global panneau

   }



   #
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc ::atos_cdl_gui::run { visuNo frm } {

      global audace panneau
      set panneau(atos,$visuNo,atos_cdl_gui) $frm
      createdialog $visuNo $frm

   }



   #
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc ::atos_cdl_gui::showHelp { } {
 
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::atos::getPluginType ] ] \
         [ ::atos::getPluginDirectory ] atos_cdl_gui.htm
 
   }



   #
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc ::atos_cdl_gui::closeWindow { this visuNo } {

      ::atos_cdl_gui::widgetToConf $visuNo
      destroy $this

   }

   #
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc ::atos_cdl_gui::correction_preview { visuNo } {
      
      set bufNo [ ::confVisu::getBufNo $visuNo ]
      set correction $::atos_gui::frame(correction)
      
      saveima tmp_cdl_img
      
      # Traitement des darks
      set okdark 0
      if {$::atos_cdl_tools::usedark } {
         set masterdark [$correction.dark_path get]
         if {[file exists $masterdark]} {
            set okdark 1
            loadima $masterdark
            set stat [buf$bufNo stat]
            set meandark [format "%.0f" [lindex $stat 4]]
            gren_info "Correction par le Darks actif\n"
            gren_info "file = $masterdark\n"
            gren_info "meandark = $meandark\n"
         }
      }
      # Traitement des flats
      set okflat 0
      if {$::atos_cdl_tools::useflat } {
         set masterflat [$correction.flat_path get]
         if {[file exists $masterflat]} {
            set okflat 1
            loadima $masterflat
            set stat [buf$bufNo stat]
            set meanflat [format "%.0f" [lindex $stat 4]]
            gren_info "Correction par le Flat actif\n"
            gren_info "file = $masterflat\n"
            gren_info "meanflat = $meanflat\n"
         }
      }

      loadima tmp_cdl_img
      
      if {$okdark} {
         buf$bufNo sub $masterdark $meandark
      }
      if {$okflat} {
         buf$bufNo div $masterflat $meanflat
      }
      if {$okflat||$okdark} {
         visu$visuNo disp
      } else {
         gren_erreur "no preview"
      }

      file delete -force tmp_cdl_img   
      
   }


   #
   # Fonction appellee lors de l'appui sur le bouton '...'
   # selectionne la video pour les flat ou les dark
   #
   proc ::atos_cdl_gui::select_file { visuNo type } {

      global audace

      set frm $::atos_gui::frame($type)
      
      set bufNo [ visu$visuNo buf ]
      
      if { $::atos_tools::traitement == "fits" } {
         gren_erreur "TODO\n"
      }
      if { $::atos_tools::traitement == "avi" } {
         set filename [ ::tkutil::box_load_avi $frm $audace(rep_images) $bufNo "1" ]
      }
      
      $frm.path delete 0 end
      $frm.path insert 0 $filename
      
      return 0
   }

   #
   # Appuie sur le bouton Selection ... de USe Dark ou Flat
   #
   proc ::atos_cdl_gui::select_master { visuNo type } {

      set bufNo [ visu$visuNo buf ]
      set corr $::atos_gui::frame(correction)
   
      set master [::tkutil::box_load $::atos_gui::frame(base) [pwd] $bufNo "1"]
      if {[file exists $master]} {
         $corr.${type}_path delete 0 end
         $corr.${type}_path insert 0 $master
         gren_info "Use $master\n"
      }


   }
   #
   # Fonction appellee lors de l'appui sur le check button flat ou dark
   #
   proc ::atos_cdl_gui::usedf { visuNo type } {


      set corr $::atos_gui::frame(correction)

      gren_info "usedf $type $::atos_cdl_tools::useflat $::atos_cdl_tools::usedark\n"
      
      if {$type == "dark" && $::atos_cdl_tools::usedark } {
         set masterdark [::atos_cdl_gui::get_filename_master $visuNo $type]
         if {[file exists $masterdark]} {
            gren_info "masterdark = $masterdark exists\n"
         } else {
            gren_erreur "masterdark = $masterdark doesnt exist\n"
         }
         #$corr.dark_path delete 0 end
         #$corr.dark_path insert 0 $masterdark
      }
      
   }

   #
   # Fournit le nom du fichier Master (Dark ou Flat) 
   #
   proc ::atos_cdl_gui::get_filename_master { visuNo df } {

      set bufNo [::confVisu::getBufNo $visuNo]
      set ext   [buf$bufNo extension]

      if { $::atos_tools::traitement=="fits" } {
         set filename [file join ${::atos_tools::destdir} "${::atos_tools::prefix}"]
      }

      if { $::atos_tools::traitement=="avi" }  {
         set filename $::atos_tools::avi_filename
         if { ! [file exists $filename] } {
         ::console::affiche_erreur "Fichier AVI introuvable!\n"
         }
      }

      return "${filename}.master.${df}${ext}"

   }

   #
   # Creation de l'interface graphique
   #
   proc ::atos_cdl_gui::createdialog { visuNo this } {

      package require Img

      global caption panneau atosconf color audace
      
      ::audace::psf_init $visuNo
      set ::atos_cdl_tools::compute_image_first ""

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
      if { $::atos_tools::traitement == "fits" } { wm title $this $caption(atos_cdl_gui,bar_title_fits) }
      if { $::atos_tools::traitement == "avi" }  { wm title $this $caption(atos_cdl_gui,bar_title_avi) }
      wm protocol $this WM_DELETE_WINDOW "::atos_cdl_gui::closeWindow $this $visuNo"

      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::atos_cdl_gui::confToWidget $visuNo

      if { $::atos_tools::traitement == "fits" } { set titre $caption(atos_cdl_gui,titre_fits) }
      if { $::atos_tools::traitement == "avi" }  { set titre $caption(atos_cdl_gui,titre_avi) }

      #--- frame general
      set frm $this.frm_atos_cdl_gui
      set ::atos_gui::frame(base) $frm

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
                    button $frm.form.butopen.open -text $caption(atos_cdl_gui,ouvrir) -borderwidth 2 \
                       -command "::atos_cdl_tools::open_flux $visuNo"
                    pack $frm.form.butopen.open \
                       -in $frm.form.butopen -side left -anchor e \
                       -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

               #--- Cree un frame pour la gestion de fichier
               frame $frm.form.field -borderwidth 1 -cursor arrow
               pack $frm.form.field -in $frm.form -side left -expand 0 -fill x -padx 1 -pady 1

                    #--- Cree un frame pour afficher les intitules
                    set intitle [frame $frm.form.field.l -borderwidth 0]
                    pack $intitle -in $frm.form.field -side left

                      #--- Cree un label pour
                      label $intitle.destdir -font $atosconf(font,courier_10) -padx 3 \
                            -text $caption(atos_cdl_gui,dirimg)
                      pack $intitle.destdir -in $intitle -side top -padx 3 -pady 1 -anchor w

                      #--- Cree un label pour
                      label $intitle.prefix -font $atosconf(font,courier_10) \
                            -text $caption(atos_cdl_gui,prefix)
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
                      button $inbutton.chgdir -text "..." -borderwidth 2 \
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
             button $frm.open.but_open -text $caption(atos_cdl_gui,ouvrir) -borderwidth 2 \
                -command "::atos_cdl_tools::open_flux $visuNo"
             pack $frm.open.but_open -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             #--- Creation du bouton select
             button $frm.open.but_select -text "..." -borderwidth 2 -takefocus 1 \
                -command "::atos_cdl_tools::select $visuNo"
             pack $frm.open.but_select -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             #--- Cree un label pour le chemin de l'AVI
             entry $frm.open.avipath 
             pack $frm.open.avipath -side left -padx 3 -pady 1 -expand true -fill x

        }

        set info_load [frame $frm.info_load]
        pack $info_load -in $frm -side top  -padx 1 -pady 1

           #--- Cree un label pour le nb d image
           label $info_load.status -font $atosconf(font,courier_10) -text ""

           #--- Cree un label pour le nb d image
           label $info_load.nbtotal -font $atosconf(font,courier_10) -text ""

           grid $info_load.status $info_load.nbtotal

        set ::atos_gui::frame(info_load) $info_load

        #--- Creation de la barre de defilement
        scale $frm.scrollbar -from 0 -to 1 -length 600 -variable ::atos_tools::scrollbar \
           -label "" -orient horizontal -state disabled
        pack $frm.scrollbar -in $frm -anchor center -fill none -pady 5 -ipadx 5 -ipady 3
        bind $frm.scrollbar <ButtonRelease> "::atos_cdl_tools::move_scroll $visuNo"

        set ::atos_gui::frame(scrollbar) $frm.scrollbar

        #--- Cree un frame pour afficher
        set btnav [frame $frm.btnav -borderwidth 0]
        pack $btnav -in $frm -side top

        #--- Creation du bouton quick prev image
        image create photo .arr -format PNG -file [ file join $audace(rep_plugin) tool atos img arr.png ]
        button $frm.qprevimage -image .arr -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::atos_cdl_tools::quick_prev_image $visuNo"
        pack $frm.qprevimage -in $frm.btnav -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton prev image
        image create photo .arn -format PNG -file [ file join $audace(rep_plugin) tool atos img arn.png ]
        button $frm.previmage -image .arn -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::atos_cdl_tools::prev_image $visuNo"
        pack $frm.previmage -in $frm.btnav -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton next image
        image create photo .avn -format PNG -file [ file join $audace(rep_plugin) tool atos img avn.png ]
        button $frm.nextimage -image .avn -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::atos_cdl_tools::next_image $visuNo"
        pack $frm.nextimage -in $frm.btnav -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton quick next image
        image create photo .avr -format PNG -file [ file join $audace(rep_plugin) tool atos img avr.png ]
        button $frm.qnextimage -image .avr -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::atos_cdl_tools::quick_next_image $visuNo"
        pack $frm.qnextimage -in $frm.btnav -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          #--- Affichage positions
          frame $frm.pos -borderwidth 1 -relief raised -cursor arrow
          pack $frm.pos -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

             #--- Creation du bouton setmin
             button $frm.pos.setmin -text "setmin" -borderwidth 2 \
                -command "::atos_tools::setmin"
             pack $frm.pos.setmin -in $frm.pos -side left -anchor w \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             #--- Creation du bouton setmax
             button $frm.pos.setmax -text "setmax" -borderwidth 2 \
                -command "::atos_tools::setmax"
             pack $frm.pos.setmax -in $frm.pos -side left -anchor w \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             #--- Cree un frame pour afficher
             frame $frm.pos.min -borderwidth 0
             pack $frm.pos.min -in $frm.pos -side left

                #--- Cree un label pour
                entry $frm.pos.min.val -fg $color(blue) -relief sunken
                pack $frm.pos.min.val -in $frm.pos.min -side top -pady 1 -anchor w

                set ::atos_gui::frame(posmin) $frm.pos.min.val

             #--- Cree un frame pour afficher
             frame $frm.pos.max -borderwidth 0
             pack $frm.pos.max -in $frm.pos -side left

                #--- Cree un label pour
                entry $frm.pos.max.val -fg $color(blue) -relief sunken
                pack $frm.pos.max.val -in $frm.pos.max -side top -pady 1 -anchor w

                set ::atos_gui::frame(posmax) $frm.pos.max.val

             #--- Creation du bouton crop
             button $frm.pos.crop -text "crop" -borderwidth 2 \
                -command "::atos_tools::crop $visuNo"
             pack $frm.pos.crop -in $frm.pos -side left -anchor w \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             #--- Creation du bouton uncrop
             button $frm.pos.uncrop -text "uncrop" -borderwidth 2 \
                -command "::atos_tools::uncrop $visuNo"
             pack $frm.pos.uncrop -in $frm.pos -side left -anchor w \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


  #--- Onglets


          set onglets [frame $frm.onglets]
          pack $onglets -in $frm

             pack [ttk::notebook $onglets.nb] -expand yes -fill both 
             set f_phot [frame $onglets.nb.f_phot]
             set f_psf  [frame $onglets.nb.f_psf]
             set f_corr [frame $onglets.nb.f_corr]
             set f_geom [frame $onglets.nb.f_geom]
             set f_suiv [frame $onglets.nb.f_suiv]

             $onglets.nb add $f_phot -text $caption(atos_cdl_gui,photometrie)
             $onglets.nb add $f_psf  -text $caption(atos_cdl_gui,psf)
             $onglets.nb add $f_corr -text $caption(atos_cdl_gui,corr)
             $onglets.nb add $f_geom -text $caption(atos_cdl_gui,geometrie)
             $onglets.nb add $f_suiv -text $caption(atos_cdl_gui,suivi)

             $onglets.nb select $f_phot
             ttk::notebook::enableTraversal $onglets.nb

    # onglets : photometrie
    
             set photometrie [frame $f_phot.photometrie]
             pack $photometrie -in $f_phot

             set ::atos_gui::frame(photometrie) $photometrie
             
                 #--- Cree un frame 
                 frame $photometrie.photom -borderwidth 1 -relief raised -cursor arrow 
                 pack $photometrie.photom -in $photometrie -side top -expand 0 -fill x -padx 1 -pady 1

                 #--- Cree un frame 
                 frame $photometrie.photom.values -borderwidth 0 -cursor arrow
                 pack $photometrie.photom.values -in $photometrie.photom -side top -expand 5

                 #--- Cree un frame pour image
                 set image [frame $photometrie.photom.values.image -borderwidth 1]
                 pack $image -in $photometrie.photom.values -side left -padx 30 -pady 1

                     #--- Cree un frame
                     frame $image.t -borderwidth 0 -cursor arrow
                     pack  $image.t -in $image -side top -expand 5 -anchor w

                     #--- Cree un label
                     label $image.t.titre -font $atosconf(font,courier_10) -font $atosconf(font,courier_10_b) -text $caption(atos_cdl_gui,image)
                     pack  $image.t.titre -in $image.t -side left -anchor w -padx 30

                     button $image.t.select -text $caption(atos_cdl_gui,select) -borderwidth 1 -takefocus 1 \
                                            -command "::atos_cdl_tools::select_fullimg $visuNo"
                     pack $image.t.select -in $image.t -side left -anchor e 

                     set ::atos_gui::frame(image,buttons) $image.t

                     #--- Cree un frame pour les info 
                     frame $image.v -borderwidth 0 -cursor arrow
                     pack  $image.v -in $image -side top

                     frame $image.v.l -borderwidth 0 -cursor arrow
                     pack  $image.v.l -in $image.v -side left

                     frame $image.v.r -borderwidth 0 -cursor arrow
                     pack  $image.v.r -in $image.v -side right

                     set ::atos_gui::frame(image,values) $image.v.r

                        #---
                        label $image.v.l.fenetre -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,fenetre)
                        pack  $image.v.l.fenetre -in $image.v.l -side top -anchor w
                        label $image.v.r.fenetre -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $image.v.r.fenetre -in $image.v.r -side top -anchor w

                        #---
                        label $image.v.l.intmin -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,min_int)
                        pack  $image.v.l.intmin -in $image.v.l -side top -anchor w
                        label $image.v.r.intmin -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $image.v.r.intmin -in $image.v.r -side top -anchor w

                        #---
                        label $image.v.l.intmax -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,max_int)
                        pack  $image.v.l.intmax -in $image.v.l -side top -anchor w
                        label $image.v.r.intmax -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $image.v.r.intmax -in $image.v.r -side top -anchor w

                        #---
                        label $image.v.l.intmoy -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,mean_int)
                        pack  $image.v.l.intmoy -in $image.v.l -side top -anchor w
                        label $image.v.r.intmoy -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $image.v.r.intmoy -in $image.v.r -side top -anchor w

                        #---
                        label $image.v.l.sigma -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,sigma)
                        pack  $image.v.l.sigma -in $image.v.l -side top -anchor w
                        label $image.v.r.sigma -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $image.v.r.sigma -in $image.v.r -side top -anchor w

                        #---
                        label $image.v.l.mag -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,flux)
                        pack  $image.v.l.mag -in $image.v.l -side top -anchor w
                        label $image.v.r.mag -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $image.v.r.mag -in $image.v.r -side top -anchor w

                 #--- Cree un frame pour object
                 set object [frame $photometrie.photom.values.object -borderwidth 1]
                 pack $object -in $photometrie.photom.values -side left -padx 30 -pady 1

                     #--- Cree un label
                     label $object.titre -font $atosconf(font,courier_10) -font $atosconf(font,courier_10_b) -text $caption(atos_cdl_gui,objet)
                     pack  $object.titre -in $object -side top -anchor w -padx 30


                     set but [frame $object.but -borderwidth 1]
                     pack $but -in $object -side top 
  
                           button $but.select -text $caption(atos_cdl_gui,select) -borderwidth 1 -takefocus 1 \
                                                  -command "::atos_cdl_tools::select_source $visuNo object"
                           button $but.modifier -text $caption(atos_cdl_gui,modif) -borderwidth 1 -takefocus 1 \
                                                  -command "::atos_cdl_tools::modif_source $visuNo object"
                           button $but.verifier -text $caption(atos_cdl_gui,valid) -borderwidth 1 -takefocus 1 \
                                                  -command "::atos_cdl_tools::verif_source $visuNo object"

                           grid $but.select $but.modifier $but.verifier 

                     set ::atos_gui::frame(object,buttons) $but

                     #--- Cree un frame pour les info 
                     frame $object.v -borderwidth 0 -cursor arrow
                     pack  $object.v -in $object -side top

                     frame $object.v.l -borderwidth 0 -cursor arrow
                     pack  $object.v.l -in $object.v -side left

                     frame $object.v.r -borderwidth 0 -cursor arrow
                     pack  $object.v.r -in $object.v -side right

                     set ::atos_gui::frame(object,values) $object.v.r

                        #---
                        label $object.v.l.position -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,position)
                        pack  $object.v.l.position -in $object.v.l -side top -anchor w
                        label $object.v.r.position -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $object.v.r.position -in $object.v.r -side top -anchor w

                        #---
                        label $object.v.l.radius -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,radius)
                        pack  $object.v.l.radius -in $object.v.l -side top -anchor w
                        label $object.v.r.radius -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $object.v.r.radius -in $object.v.r -side top -anchor w

                        #---
                        label $object.v.l.fint -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,int_flux)
                        pack  $object.v.l.fint -in $object.v.l -side top -anchor w
                        label $object.v.r.fint -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $object.v.r.fint -in $object.v.r -side top -anchor w

                        #---
                        label $object.v.l.fwhm -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,fwhm)
                        pack  $object.v.l.fwhm -in $object.v.l -side top -anchor w
                        label $object.v.r.fwhm -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $object.v.r.fwhm -in $object.v.r -side top -anchor w

                        #---
                        label $object.v.l.pixmax -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,pixmax)
                        pack  $object.v.l.pixmax -in $object.v.l -side top -anchor w
                        label $object.v.r.pixmax -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $object.v.r.pixmax -in $object.v.r -side top -anchor w

                        #---
                        label $object.v.l.intensite -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,intensity)
                        pack  $object.v.l.intensite -in $object.v.l -side top -anchor w
                        label $object.v.r.intensite -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $object.v.r.intensite -in $object.v.r -side top -anchor w

                        #---
                        label $object.v.l.sigmafond -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,sigma_bg)
                        pack  $object.v.l.sigmafond -in $object.v.l -side top -anchor w
                        label $object.v.r.sigmafond -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $object.v.r.sigmafond -in $object.v.r -side top -anchor w

                        #---
                        label $object.v.l.snint -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,ssb_int)
                        pack  $object.v.l.snint -in $object.v.l -side top -anchor w
                        label $object.v.r.snint -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $object.v.r.snint -in $object.v.r -side top -anchor w

                        #---
                        label $object.v.l.snpx -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,ssb_pix)
                        pack  $object.v.l.snpx -in $object.v.l -side top -anchor w
                        label $object.v.r.snpx -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $object.v.r.snpx -in $object.v.r -side top -anchor w


                 #--- Cree un frame pour reference
                 set reference [frame $photometrie.photom.values.reference -borderwidth 1]
                 pack $reference -in $photometrie.photom.values -side left -padx 30 -pady 1

                     #--- Cree un label
                     label $reference.titre -font $atosconf(font,courier_10) -font $atosconf(font,courier_10_b) -text $caption(atos_cdl_gui,reference)
                     pack  $reference.titre -in $reference -side top -anchor w -padx 30

                     set but [frame $reference.but -borderwidth 1]
                     
                     pack $but -in $reference -side top 
  
                        button $but.select -text $caption(atos_cdl_gui,select) -borderwidth 1 -takefocus 1 \
                                               -command "::atos_cdl_tools::select_source $visuNo reference"
                        button $but.modifier -text $caption(atos_cdl_gui,modif) -borderwidth 1 -takefocus 1 \
                                               -command "::atos_cdl_tools::modif_source $visuNo reference"
                        button $but.verifier -text $caption(atos_cdl_gui,valid) -borderwidth 1 -takefocus 1 \
                                               -command "::atos_cdl_tools::verif_source $visuNo reference"

                        grid $but.select $but.modifier $but.verifier 

                     set ::atos_gui::frame(reference,buttons) $but


                     #--- Cree un frame pour les info 
                     frame $reference.v -borderwidth 0 -cursor arrow
                     pack  $reference.v -in $reference -side top

                     frame $reference.v.l -borderwidth 0 -cursor arrow
                     pack  $reference.v.l -in $reference.v -side left

                     frame $reference.v.r -borderwidth 0 -cursor arrow
                     pack  $reference.v.r -in $reference.v -side right
  
                     set ::atos_gui::frame(reference,values) $reference.v.r

                        #---
                        label $reference.v.l.position -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,position)
                        pack  $reference.v.l.position -in $reference.v.l -side top -anchor w
                        label $reference.v.r.position -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $reference.v.r.position -in $reference.v.r -side top -anchor w

                        #---
                        label $reference.v.l.radius -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,radius)
                        pack  $reference.v.l.radius -in $reference.v.l -side top -anchor w
                        label $reference.v.r.radius -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $reference.v.r.radius -in $reference.v.r -side top -anchor w

                        #---
                        label $reference.v.l.fint -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,int_flux)
                        pack  $reference.v.l.fint -in $reference.v.l -side top -anchor w
                        label $reference.v.r.fint -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $reference.v.r.fint -in $reference.v.r -side top -anchor w

                        #---
                        label $reference.v.l.fwhm -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,fwhm)
                        pack  $reference.v.l.fwhm -in $reference.v.l -side top -anchor w
                        label $reference.v.r.fwhm -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $reference.v.r.fwhm -in $reference.v.r -side top -anchor w

                        #---
                        label $reference.v.l.pixmax -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,pixmax)
                        pack  $reference.v.l.pixmax -in $reference.v.l -side top -anchor w
                        label $reference.v.r.pixmax -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $reference.v.r.pixmax -in $reference.v.r -side top -anchor w

                        #---
                        label $reference.v.l.intensite -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,intensity)
                        pack  $reference.v.l.intensite -in $reference.v.l -side top -anchor w
                        label $reference.v.r.intensite -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $reference.v.r.intensite -in $reference.v.r -side top -anchor w

                        #---
                        label $reference.v.l.sigmafond -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,sigma_bg)
                        pack  $reference.v.l.sigmafond -in $reference.v.l -side top -anchor w
                        label $reference.v.r.sigmafond -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $reference.v.r.sigmafond -in $reference.v.r -side top -anchor w

                        #---
                        label $reference.v.l.snint -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,ssb_int)
                        pack  $reference.v.l.snint -in $reference.v.l -side top -anchor w
                        label $reference.v.r.snint -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $reference.v.r.snint -in $reference.v.r -side top -anchor w

                        #---
                        label $reference.v.l.snpx -font $atosconf(font,courier_10) -text $caption(atos_cdl_gui,ssb_pix)
                        pack  $reference.v.l.snpx -in $reference.v.l -side top -anchor w
                        label $reference.v.r.snpx -font $atosconf(font,courier_10) -fg $color(blue) -text "?"
                        pack  $reference.v.r.snpx -in $reference.v.r -side top -anchor w

    # onglets : psf

             set psf [frame $f_psf.psf]
             pack $psf -in $f_psf

                 ::audace::psf_gui_methodes $visuNo $psf

    # onglets : Correction
 
             set corr [frame $f_corr.corr]
             pack $corr -in $f_corr
             set ::atos_gui::frame(correction) $corr

                checkbutton $corr.flat_check -text $caption(atos_cdl_gui,useflat) \
                    -variable ::atos_cdl_tools::useflat -state normal 

                button $corr.flat_but_select -text "..." -borderwidth 2 -takefocus 1 \
                   -command "::atos_cdl_gui::select_master $visuNo flat"

                entry $corr.flat_path -width 90

                checkbutton $corr.dark_check -text $caption(atos_cdl_gui,usedark) \
                    -variable ::atos_cdl_tools::usedark -state normal 

                button $corr.dark_but_select -text "..." -borderwidth 2 -takefocus 1 \
                   -command "::atos_cdl_gui::select_master $visuNo dark"

                entry $corr.dark_path -width 90

                button $corr.preview -text "Preview" -borderwidth 2 -takefocus 1 \
                   -command "::atos_cdl_gui::correction_preview $visuNo"

             grid   $corr.flat_check $corr.flat_but_select $corr.flat_path -sticky nsw
             grid   $corr.dark_check $corr.dark_but_select $corr.dark_path -sticky nsw
             grid   $corr.preview    -columnspan 3 -sticky nsw

    # onglets : geometrie


             set geometrie [frame $f_geom.geometrie]
             pack $geometrie -in $f_geom

             set ::atos_gui::frame(geometrie) $geometrie
 
                frame $geometrie.binning -borderwidth 0 -cursor arrow
                pack  $geometrie.binning -in $geometrie -side top
 
                   label $geometrie.binning.lab -font $atosconf(font,courier_10) -width 12 -anchor e -text $caption(atos_cdl_gui,binning)
                   pack  $geometrie.binning.lab -in $geometrie.binning -side left  -padx 10 -pady 2
                   spinbox $geometrie.binning.val -font $atosconf(font,courier_10) -from 1 -to 4 -command "" -width 5 -state disable
                   pack  $geometrie.binning.val -in $geometrie.binning -side left -anchor w

                frame $geometrie.sum -borderwidth 0 -cursor arrow
                pack  $geometrie.sum -in $geometrie -side top
 
                   label $geometrie.sum.lab -font $atosconf(font,courier_10) -width 12 -anchor e -text $caption(atos_cdl_gui,sommation)
                   pack  $geometrie.sum.lab -in $geometrie.sum -side left  -padx 10 -pady 2
                   spinbox $geometrie.sum.val -font $atosconf(font,courier_10) -width 5 -from 1 -to 30 -increment 1 -command ""
                   pack  $geometrie.sum.val -in $geometrie.sum -side left -anchor w

                frame $geometrie.cosmic -borderwidth 0 -cursor arrow
                pack  $geometrie.cosmic -in $geometrie -side top

                   set ::atos_cdl_tools::uncosmic_check 0
                   checkbutton $geometrie.cosmic.check -text $caption(atos_cdl_gui,uncosmic) -variable ::atos_cdl_tools::uncosmic_check -state disable
                   pack  $geometrie.cosmic.check -in $geometrie.cosmic -side left -anchor c -pady 5
                   
                frame $geometrie.buttons -borderwidth 0 -cursor arrow
                pack  $geometrie.buttons -in $geometrie -side top

                   button $geometrie.buttons.preview -state normal -text $caption(atos_cdl_gui,preview) -relief "raised" -width 8 -height 1\
                                     -command "::atos_cdl_tools::preview $visuNo" 
                   pack  $geometrie.buttons.preview -in $geometrie.buttons -side left -anchor w
                   button $geometrie.buttons.launch -state normal -text "Appliquer" \
                                     -relief "raised" -width 8 -height 1\
                                     -command "::atos_cdl_tools::compute_image $visuNo" 
                   pack  $geometrie.buttons.launch -in $geometrie.buttons -side left -anchor w
                                                         
                frame $geometrie.info -borderwidth 0 -cursor arrow
                pack  $geometrie.info -in $geometrie -side top

                   label $geometrie.info.lab -font $atosconf(font,courier_10) \
                       -text "$caption(atos_cdl_gui,activer) $::atos_cdl_tools::compute_image_first"

                frame $geometrie.corr -borderwidth 0 -cursor arrow
                pack  $geometrie.corr -in $geometrie -side top

                   label $geometrie.corr.lab -font $atosconf(font,courier_10) \
                       -text ""


    # onglets : suivi


             set suivi [frame $f_suiv.suivi]
             pack $suivi -in $f_suiv

             set ::atos_gui::frame(suivi) $suivi

                frame $suivi.methode -borderwidth 0 -cursor arrow
                pack  $suivi.methode -in $suivi -side top -pady 10

                   label $suivi.methode.lab -text $caption(atos_cdl_gui,methode)
                   pack  $suivi.methode.lab -in $suivi.methode -side left -anchor w

                   spinbox $suivi.methode.val -font $atosconf(font,courier_10)  \
                      -value [list "Interpolation" "Auto"] -state readonly \
                      -textvariable ::atos_cdl_tools::methode_suivi \
                      -command "::atos_cdl_gui::options_suivi" 
                   pack $suivi.methode.val -in $suivi.methode -side left -anchor w

                frame $suivi.threshold -borderwidth 0 -cursor arrow
                pack $suivi.threshold -in $suivi -side top -pady 20

                  frame $suivi.threshold.obj -borderwidth 0 -cursor arrow
                  pack  $suivi.threshold.obj -in $suivi.threshold -side top -pady 5

                     label $suivi.threshold.obj.lab -text $caption(atos_cdl_gui,threshold_target) -width 22 -anchor e
                     pack  $suivi.threshold.obj.lab -in $suivi.threshold.obj -side left -anchor e
                     spinbox $suivi.threshold.obj.valx -font $atosconf(font,courier_10) -width 3 \
                        -from 1 -to 30 -increment 1 -textvariable ::atos_cdl_tools::x_obj_threshold -command "" 
                     pack  $suivi.threshold.obj.valx -in $suivi.threshold.obj -side left -anchor w
                     spinbox $suivi.threshold.obj.valy -font $atosconf(font,courier_10) -width 3 \
                        -from 1 -to 30 -increment 1 -textvariable ::atos_cdl_tools::y_obj_threshold -command "" 
                     pack  $suivi.threshold.obj.valy -in $suivi.threshold.obj -side left -anchor w

                  frame $suivi.threshold.ref -borderwidth 0 -cursor arrow
                  pack  $suivi.threshold.ref -in $suivi.threshold -side top -pady 5

                     label $suivi.threshold.ref.lab -text $caption(atos_cdl_gui,threshold_ref) -width 22 -anchor e
                     pack  $suivi.threshold.ref.lab -in $suivi.threshold.ref -side left -anchor e
                     spinbox $suivi.threshold.ref.valx -font $atosconf(font,courier_10) -width 3 \
                         -from 1 -to 30 -increment 1 \
                         -textvariable ::atos_cdl_tools::x_ref_threshold \
                         -command "" 
                     pack  $suivi.threshold.ref.valx -in $suivi.threshold.ref -side left -anchor w
                     spinbox $suivi.threshold.ref.valy -font $atosconf(font,courier_10) -width 3 \
                         -from 1 -to 30 -increment 1 \
                         -textvariable ::atos_cdl_tools::y_ref_threshold \
                         -command "" 
                     pack  $suivi.threshold.ref.valy -in $suivi.threshold.ref -side left -anchor w

                # Choix par defaut de la methode de suivi
                ::atos_cdl_gui::options_suivi


   #--- Fin Onglets


        #--- Cree un frame pour  les boutons d action 
        frame $frm.action \
              -borderwidth 1 -relief raised -cursor arrow
        pack $frm.action \
             -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

           image create photo .start -format PNG -file [ file join $audace(rep_plugin) tool atos img start.png ]
           image create photo .stop  -format PNG -file [ file join $audace(rep_plugin) tool atos img stop.png ]
           image create photo .graph -format PNG -file [ file join $audace(rep_plugin) tool atos img cdl.png ]
           image create photo .save  -format PNG -file [ file join $audace(rep_plugin) tool atos img save.png ]

           button $frm.action.start -image .start\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::atos_cdl_tools::start $visuNo"
           pack $frm.action.start \
              -in $frm.action \
              -side left -anchor w \
              -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
           DynamicHelp::add $frm.action.start -text $caption(atos_cdl_gui,start)

           set ::atos_gui::frame(buttons,start) $frm.action.start

           button $frm.action.graph_xy_obj -image .graph\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::atos_cdl_tools::graph_xy $visuNo object"
           pack $frm.action.graph_xy_obj \
              -in $frm.action \
              -side left -anchor w \
              -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
           DynamicHelp::add $frm.action.graph_xy_obj -text $caption(atos_cdl_gui,graph1)

           button $frm.action.graph_xy_ref -image .graph\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::atos_cdl_tools::graph_xy $visuNo reference"
           pack $frm.action.graph_xy_ref \
              -in $frm.action \
              -side left -anchor w \
              -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
           DynamicHelp::add $frm.action.graph_xy_ref -text $caption(atos_cdl_gui,graph2)
           
           button $frm.action.graph_flux_obj -image .graph\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::atos_cdl_tools::graph_flux $visuNo object"
           pack $frm.action.graph_flux_obj \
              -in $frm.action \
              -side left -anchor w \
              -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
           DynamicHelp::add $frm.action.graph_flux_obj -text $caption(atos_cdl_gui,graph3)
           
           button $frm.action.graph_flux_ref -image .graph\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::atos_cdl_tools::graph_flux $visuNo reference"
           pack $frm.action.graph_flux_ref \
              -in $frm.action \
              -side left -anchor w \
              -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
           DynamicHelp::add $frm.action.graph_flux_ref -text $caption(atos_cdl_gui,graph4)
           
           button $frm.action.graph_flux_norm -image .graph\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::atos_cdl_tools::graph_flux $visuNo normal"
           pack $frm.action.graph_flux_norm \
              -in $frm.action \
              -side left -anchor w \
              -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
           DynamicHelp::add $frm.action.graph_flux_norm -text $caption(atos_cdl_gui,graph5)
           
           button $frm.action.save -image .save\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::atos_cdl_tools::save $visuNo"
           pack $frm.action.save \
              -in $frm.action \
              -side left -anchor w \
              -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
           DynamicHelp::add $frm.action.save -text $caption(atos_cdl_gui,save)

           #--- Creation du bouton fermer
           button $frm.action.fermer \
              -text "$caption(atos_cdl_gui,fermer)" -borderwidth 2 \
              -command "::atos_cdl_gui::closeWindow $this $visuNo"
           pack $frm.action.fermer -in $frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $frm.action.aide \
              -text "$caption(atos_cdl_gui,aide)" -borderwidth 2 \
              -command "::audace::showHelpPlugin tool atos atos.htm cdl"
           pack $frm.action.aide -in $frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


      # Application du theme
      ::confColor::applyColor $this

   }



   proc options_suivi {} {

      set suivi $::atos_gui::frame(suivi)

      if {$::atos_cdl_tools::methode_suivi == "Auto"} {
         pack $suivi.threshold -in $suivi -side top -pady 20
      } else {
         pack forget $suivi.threshold
      }

   }

}

#--- Initialisation au demarrage
::atos_cdl_gui::init
