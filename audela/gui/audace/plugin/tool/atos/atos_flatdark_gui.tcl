#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_ocr_gui.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_flatdark_gui.tcl
# Description    : GUI de la reconnaissance de caractere 
# Auteur         : Frederic Vachier
# Mise à jour $Id: atos_ocr_gui.tcl 10675 2014-04-10 12:50:31Z fredvachier $
#

namespace eval ::atos_flatdark_gui {



   #
   # Initialisation des variables de configuration
   #
   proc ::atos_flatdark_gui::initToConf { visuNo } {
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
   proc ::atos_flatdark_gui::confToWidget { visuNo } {

      variable parametres
      global panneau

      #--- confToWidget

      set ::atos_flatdark::rect_img              ""
      set ::atos_flatdark::datation_methode      ""
      set ::atos_flatdark::active_ocr            0
      set ::atos_flatdark::nbverif               0
      set ::atos_flatdark::nbocr                 0
      set ::atos_flatdark::nbinterp              0

   }



   #
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc ::atos_flatdark_gui::widgetToConf { visuNo } {
      variable parametres
      global panneau

   }



   #
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc ::atos_flatdark_gui::run { visuNo this } {

      global audace panneau

      set panneau(atos,$visuNo,atos_flatdark_gui) $this
      createdialog $this $visuNo   

   }



   #
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc ::atos_flatdark_gui::showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::atos::getPluginType ] ] \
         [ ::atos::getPluginDirectory ] atos_flatdark_gui.htm
   }



   #
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc ::atos_flatdark_gui::closeWindow { this visuNo } {

      set bufNo [::confVisu::getBufNo $visuNo]
      set ext   [buf$bufNo extension]

      set err [catch {file delete -force "atos_build_dark_tmp$ext"} msg]
      set err [catch {file delete -force "atos_build_flat_tmp$ext"} msg]


      ::plotxy::clf 1
      ::atos_flatdark_gui::widgetToConf $visuNo
      
      destroy $this
   }



   #
   # Creation de l'interface graphique
   #
   proc ::atos_flatdark_gui::createdialog { this visuNo } {

      package require Img

      global caption panneau atosconf color audace

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set base "$audace(base)"
      } else {
         set base ".visu$visuNo"
      }

      set ::atos_flatdark::typecorr "dark"
      set ::atos_flatdark_gui::pcimg 20
      set ::atos_flatdark_gui::datagraph(all,x)   ""
      set ::atos_flatdark_gui::datagraph(all,min) ""
      set ::atos_flatdark_gui::datagraph(all,max) ""
      set ::atos_flatdark_gui::datagraph(all,moy) ""
      set ::atos_flatdark_gui::usedark 0
      
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

      if { $::atos_tools::traitement == "fits" } { wm title $this $caption(atos_flatdark,bar_title_fits) }
      if { $::atos_tools::traitement == "avi"  } { wm title $this $caption(atos_flatdark,bar_title_avi) }

      wm protocol $this WM_DELETE_WINDOW "::atos_flatdark_gui::closeWindow $this $visuNo"

      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::atos_flatdark_gui::confToWidget $visuNo

      #--- Creation des images
      image create photo .flat  -format PNG -file [ file join $audace(rep_plugin) tool atos img flat.png  ]
      image create photo .dark  -format PNG -file [ file join $audace(rep_plugin) tool atos img dark.png  ]
      image create photo .start -format PNG -file [ file join $audace(rep_plugin) tool atos img start.png ]
      image create photo .stop  -format PNG -file [ file join $audace(rep_plugin) tool atos img stop.png  ]
      image create photo .graph -format PNG -file [ file join $audace(rep_plugin) tool atos img cdl.png   ]
      image create photo .save  -format PNG -file [ file join $audace(rep_plugin) tool atos img save.png  ]
      image create photo .help  -format PNG -file [ file join $audace(rep_plugin) tool atos img help.png  ]
      image create photo .view  -format PNG -file [ file join $audace(rep_plugin) tool atos img view.png  ]

      #--- Retourne l'item de la camera associee a la visu
      set frmtitre [frame $this.titre ]
      pack $frmtitre -in $this -side top
      
         #--- Cree un label pour le titre
         label $frmtitre.lab -font $atosconf(font,arial_14_b) -text $caption(atos_flatdark,title_dark)
         pack $frmtitre.lab -in $frmtitre -side top -padx 3 -pady 3
         set ::atos_gui::frame(flatdark,titre) $frmtitre.lab

      set frm1 [frame $this.frm1 ]
      pack $frm1 -in $this -side top
      set ::atos_gui::frame(flatdark,base) $frm1

         set frmimg [frame $frm1.frmimg ]
         pack $frmimg -in $frm1 -side left

            if {$::atos_flatdark::typecorr == "dark"} {
               button $frmimg.typecorr -image .dark\
                  -borderwidth 2 -width 204 -height 204 -compound center \
                  -command "::atos_flatdark_gui::switchcorr"
            } else {
               button $frmimg.typecorr -image .flat\
                  -borderwidth 2 -width 204 -height 204 -compound center \
                  -command "::atos_flatdark_gui::switchcorr"
            }

            pack $frmimg.typecorr \
               -in $frmimg \
               -side left -anchor w \
               -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
            set ::atos_gui::frame(flatdark,img) $frmimg.typecorr



         # GUI DES FLATS

         set frmdf [frame $frm1.frmflat ]
         set ::atos_gui::frame(flatdark,flat) $frmdf

         if {$::atos_flatdark::typecorr == "flat"} {
              pack $frmdf -in $frm1 -side left
              set ::atos_gui::frame(scrollbar) $frmdf.frm_scroll.scrollbar
              set ::atos_gui::frame(info)      $frmdf.frm_info.info
              set ::atos_gui::frame(param)     $frmdf.frm_info.param

         } 

            label $frmdf.labfile -text "Fichier Video :"

            entry $frmdf.path -width 70 

            button $frmdf.but_select -text "..." -borderwidth 2 -takefocus 1 \
                  -command "::atos_flatdark_gui::select_file $visuNo"

            button $frmdf.but_load -text "Open" -borderwidth 2  \
                  -command "::atos_flatdark_gui::open_file $visuNo"

            frame $frmdf.frm_scroll

               scale $frmdf.frm_scroll.scrollbar -from 0 -to 1 -length 600 \
                  -label "" -orient horizontal -state disabled

               bind $frmdf.frm_scroll.scrollbar <ButtonRelease> "::atos_flatdark_gui::move_scroll $visuNo"

            frame $frmdf.frm_crop

               set fcrop [frame $frmdf.frm_crop.but]
               set ::atos_gui::frame(crop) $fcrop

                  button $fcrop.setmin -text "setmin" -borderwidth 2 -command "::atos_tools::setmin"
                  button $fcrop.setmax -text "setmax" -borderwidth 2 -command "::atos_tools::setmax"
                  entry  $fcrop.min    -fg $color(blue) -relief sunken -width 8
                  entry  $fcrop.max    -fg $color(blue) -relief sunken -width 8
                  button $fcrop.crop   -text "crop" -borderwidth 2 -command "::atos_tools::crop $visuNo"
                  button $fcrop.uncrop -text "uncrop" -borderwidth 2 -command "::atos_tools::uncrop $visuNo"

                  set ::atos_gui::frame(posmin) $fcrop.min
                  set ::atos_gui::frame(posmax) $fcrop.max

                  grid $fcrop.setmin $fcrop.setmax $fcrop.min $fcrop.max $fcrop.crop $fcrop.uncrop -sticky nsw -padx 2

            frame $frmdf.frm_info
               
               set info [frame $frmdf.frm_info.info]

                  label $info.lab -text "Statistiques de l'image (ADU) -> "
                  LabelEntry $info.min -label "min : " -textvariable ::atos_flatdark_gui::min -width 6 -justify center
                  LabelEntry $info.max -label "max : " -textvariable ::atos_flatdark_gui::max -width 6 -justify center
                  LabelEntry $info.moy -label "moy : " -textvariable ::atos_flatdark_gui::moy -width 6 -justify center
                  LabelEntry $info.stdev -label "stdev : " -textvariable ::atos_flatdark_gui::stdev -width 6 -justify center

                  grid $info.lab $info.min $info.max $info.moy $info.stdev -sticky nw -padx 2
                  
               set param [frame $frmdf.frm_info.param]

                  label $param.lab -text "% d'images pour creer le Flat maitre : "
                  entry $param.pcimg  -textvariable ::atos_flatdark_gui::pcimg -width 4

                  grid $param.lab $param.pcimg -sticky nw

            set use_dark [frame $frmdf.use_dark]
                
               checkbutton $use_dark.check -text "Use Dark" \
                          -variable ::atos_flatdark_gui::usedark -state normal \
                          -command "::atos_flatdark_gui::select_dark $visuNo"
               entry $use_dark.path -width 70
               set ::atos_gui::frame(use_dark) $use_dark.path
               button $use_dark.but_select -text "..." -borderwidth 2 -takefocus 1 \
                      -command "::atos_flatdark_gui::select_masterdark $visuNo $this"

               grid $use_dark.check -sticky nsw
               grid $use_dark.path $use_dark.but_select -sticky nsw -padx 3

            grid $frmdf.labfile    -sticky nsw -row 0 -column 0
            grid $frmdf.path       -sticky nsw -row 1 -column 0 -padx 3
            grid $frmdf.but_select -sticky nsw -row 1 -column 1 -padx 3
            grid $frmdf.but_load   -sticky ""  -row 2 -columnspan 2 -pady 5
            grid $frmdf.frm_scroll -sticky nw  -row 3 -columnspan 2
            grid $frmdf.frm_crop   -sticky ""  -row 4 -columnspan 2 -pady 3
            grid $frmdf.frm_info   -sticky nw  -row 4 -columnspan 2
            grid $frmdf.use_dark   -sticky nw  -row 5 -columnspan 2 -pady 5


         # GUI DES DARKS

         set frmdf [frame $frm1.frmdark ]
         set ::atos_gui::frame(flatdark,dark) $frmdf

            label $frmdf.labfile -text "Fichier Video :"

            entry $frmdf.path -width 70 

            button $frmdf.but_select -text "..." -borderwidth 2 -takefocus 1 \
                  -command "::atos_flatdark_gui::select_file $visuNo"

            button $frmdf.but_load -text "Open" -borderwidth 2  \
                  -command "::atos_flatdark_gui::open_file $visuNo"

            frame $frmdf.frm_scroll

               scale $frmdf.frm_scroll.scrollbar -from 0 -to 1 -length 600  \
                  -label "" -orient horizontal -state disabled
               bind $frmdf.frm_scroll.scrollbar <ButtonRelease> "::atos_flatdark_gui::move_scroll $visuNo"

            frame $frmdf.frm_crop

               set fcrop [frame $frmdf.frm_crop.but]
               set ::atos_gui::frame(crop) $fcrop

                  button $fcrop.setmin -text "setmin" -borderwidth 2 -command "::atos_tools::setmin"
                  button $fcrop.setmax -text "setmax" -borderwidth 2 -command "::atos_tools::setmax"
                  entry  $fcrop.min    -fg $color(blue) -relief sunken -width 8
                  entry  $fcrop.max    -fg $color(blue) -relief sunken -width 8
                  button $fcrop.crop   -text "crop" -borderwidth 2 -command "::atos_tools::crop $visuNo"
                  button $fcrop.uncrop -text "uncrop" -borderwidth 2 -command "::atos_tools::uncrop $visuNo"

                  set ::atos_gui::frame(posmin) $fcrop.min
                  set ::atos_gui::frame(posmax) $fcrop.max

                  grid $fcrop.setmin $fcrop.setmax $fcrop.min $fcrop.max $fcrop.crop $fcrop.uncrop -sticky nsw -padx 2

            frame $frmdf.frm_info
               
               set info [frame $frmdf.frm_info.info]
               set ::atos_gui::frame(info) $info

                  label $info.lab -text "Statistiques de l'image (ADU) :"
                  LabelEntry $info.min -label "min : " -textvariable ::atos_flatdark_gui::min -width 6 -justify center
                  LabelEntry $info.max -label "max : " -textvariable ::atos_flatdark_gui::max -width 6 -justify center
                  LabelEntry $info.moy -label "moy : " -textvariable ::atos_flatdark_gui::moy -width 6 -justify center
                  LabelEntry $info.stdev -label "stdev : " -textvariable ::atos_flatdark_gui::stdev -width 6 -justify center

                  grid $info.lab $info.min $info.max $info.moy $info.stdev -sticky nsw -padx 2

               set param [frame $frmdf.frm_info.param]
               set ::atos_gui::frame(param) $param

                  label $param.lab -text "% d'images pour creer le Dark Maitre : "
                  entry $param.pcimg -textvariable ::atos_flatdark_gui::pcimg -width 4
                  
                  grid $param.lab $param.pcimg -sticky nsw -pady 5

            grid $frmdf.labfile    -sticky nsw -row 0 -column 0
            grid $frmdf.path       -sticky nsw -row 1 -column 0 -padx 5
            grid $frmdf.but_select -sticky nsw -row 1 -column 1 -padx 5
            grid $frmdf.but_load   -sticky ""  -row 2 -columnspan 2 -pady 5
            grid $frmdf.frm_scroll -sticky nsw -row 3 -columnspan 2
            grid $frmdf.frm_crop   -sticky ""  -row 4 -columnspan 2 -pady 3
            grid $frmdf.frm_info   -sticky nsw -row 5 -columnspan 2 -pady 10

         if {$::atos_flatdark::typecorr == "dark"} {
            pack $frmdf -in $frm1 -side top 
            set ::atos_gui::frame(scrollbar) $frmdf.frm_scroll.scrollbar
         } 


        #--- Cree un frame pour  les boutons d action 

        set action [frame $this.action -borderwidth 1 -relief raised -cursor arrow]
        pack $action -in $this -side bottom -anchor e -expand 0 -fill x -padx 1 -pady 1


           button $action.start -image .start\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::atos_flatdark_gui::start $visuNo"
           DynamicHelp::add $action.start -text $caption(atos_cdl_gui,start)
           set ::atos_gui::frame(action,start) $action.start
           
           button $action.graph -image .graph\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::atos_flatdark_gui::graph $visuNo"
           DynamicHelp::add $action.graph -text ""

           button $action.view -image .view\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::atos_flatdark_gui::view $visuNo"
           DynamicHelp::add $action.view -text "Voir"

           button $action.save -image .save\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::atos_flatdark_gui::save $visuNo"
           DynamicHelp::add $action.save -text $caption(atos_cdl_gui,save)

           button $action.help -image .help\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::audace::showHelpPlugin tool atos atos.htm correction_flat"
           DynamicHelp::add $action.save -text "Aide"

           #--- Creation du bouton fermer
           button $action.fermer \
              -text "$caption(atos_flatdark,fermer)" -borderwidth 2 \
              -command "::atos_flatdark_gui::closeWindow $this $visuNo"
           #pack $action.fermer -in $action \
           #   -side right -anchor e \
           #   -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


           grid $action.start $action.graph $action.view $action.save $action.help $action.fermer -sticky nswe



 


   }
   
   #
   # Fonction appellee lors de l'appui sur le bouton '...'
   # selectionne la video pour les flat ou les dark
   #
   proc ::atos_flatdark_gui::select_file { visuNo } {

      global audace

      set frm $::atos_gui::frame(flatdark,$::atos_flatdark::typecorr)
      
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
   # Switch de l outil FLat vers Dark et inversement
   #
   proc ::atos_flatdark_gui::switchcorr { } {

      global audace caption

      set df $::atos_flatdark::typecorr

      set df $::atos_flatdark::typecorr
      set df [expr { $df =="dark" ? "flat" : "dark" } ]
      set ::atos_flatdark::typecorr $df

      set ::atos_gui::frame(scrollbar) $::atos_gui::frame(flatdark,$df).frm_scroll.scrollbar
      set ::atos_gui::frame(info)      $::atos_gui::frame(flatdark,$df).frm_info.info
      set ::atos_gui::frame(param)     $::atos_gui::frame(flatdark,$df).frm_info.param
      
      if { $df == "flat"} {
         set titre $caption(atos_flatdark,title_flat)
         image create photo .img -format PNG -file [ file join $audace(rep_plugin) tool atos img flat.png ]
         pack forget $::atos_gui::frame(flatdark,dark)
         pack $::atos_gui::frame(flatdark,flat) -in $::atos_gui::frame(flatdark,base)
      } else {
         set titre $caption(atos_flatdark,title_dark)
         image create photo .img -format PNG -file [ file join $audace(rep_plugin) tool atos img dark.png ]
         pack forget $::atos_gui::frame(flatdark,flat)
         pack $::atos_gui::frame(flatdark,dark) -in $::atos_gui::frame(flatdark,base)
      }
      
      $::atos_gui::frame(flatdark,titre) configure -text $titre
      $::atos_gui::frame(flatdark,img)   configure -image .img

      
   }

   #
   # Ouverture d un flux
   #
   proc ::atos_flatdark_gui::open_file { visuNo } {

      set path $::atos_gui::frame(flatdark,$::atos_flatdark::typecorr).path
      set ::atos_tools::avi_filename [$path get]
      
      if {![file exists [$path get]]} {
         gren_erreur "Fichier inconnu\n"
         return
      }

      if { $::atos_tools::traitement == "fits" } {
         gren_erreur "TODO\n"

         #pack $::atos_gui::frame(scrollbar) -anchor center -fill none -ipadx 5 
         #pack $::atos_gui::frame(crop)
         #pack $::atos_gui::frame(info)
      }

      if { $::atos_tools::traitement == "avi" } {
         set ::atos_tools::avi_filename [$path get]
         ::atos_tools::open_flux $visuNo

         pack $::atos_gui::frame(scrollbar) -anchor center -fill none -ipadx 5 
         pack $::atos_gui::frame(crop)
         pack $::atos_gui::frame(info)
         pack $::atos_gui::frame(param)

         set df $::atos_flatdark::typecorr
         set df [expr { $df == "dark" ? "flat" : "dark" } ]

         pack forget $::atos_gui::frame(flatdark,$df).frm_scroll.scrollbar
         pack forget $::atos_gui::frame(flatdark,$df).frm_info.info
         pack forget $::atos_gui::frame(flatdark,$df).frm_info.param
         
         ::atos_flatdark_gui::move_scroll $visuNo
      }
      
   }

   #
   # Ouverture d un flux
   #
   proc ::atos_flatdark_gui::move_scroll { visuNo } {
      
      cleanmark

      set scrollbar $::atos_gui::frame(scrollbar)

      set bufNo [::confVisu::getBufNo $visuNo]
      set stat  [buf$bufNo stat]

      set ::atos_flatdark_gui::max   [format "%.0f" [lindex $stat 2]]
      set ::atos_flatdark_gui::min   [format "%.0f" [lindex $stat 3]]
      set ::atos_flatdark_gui::moy   [format "%.0f" [lindex $stat 4]]
      set ::atos_flatdark_gui::stdev [format "%.0f" [lindex $stat 5]]

   }

   #
   # arrete le processus de construction
   #
   proc ::atos_flatdark_gui::stop { visuNo } {
      
      set frm_start $::atos_gui::frame(action,start)

      if {$::atos_flatdark_gui::sortie == 1} {
         $frm_start configure -image .start
         $frm_start configure -relief raised
         $frm_start configure -command "::atos_flatdark_gui::start $visuNo"
      }

      set ::atos_flatdark_gui::sortie 1

   }

   #
   # Construction de l image maitre : flat ou dark
   #
   proc ::atos_flatdark_gui::start { visuNo } {

      global audace

      gren_info "Start Analyse $::atos_flatdark::typecorr ...\n"
      
      # on change le bouton en stop
      set frm_start $::atos_gui::frame(action,start)
      $frm_start configure -image .stop
      $frm_start configure -relief sunken
      $frm_start configure -command "::atos_flatdark_gui::stop $visuNo"

      # Init Variables
      set df $::atos_flatdark::typecorr
      set bufNo [::confVisu::getBufNo $visuNo]
      set ext [buf$bufNo extension]

      # Init chrono
      set ttstart [clock clicks -milliseconds]
      set tt0 [clock clicks -milliseconds]

      # construction du graphe :
      set ::atos_flatdark_gui::datagraph(all,x)   ""
      set ::atos_flatdark_gui::datagraph(all,min) ""
      set ::atos_flatdark_gui::datagraph(all,max) ""
      set ::atos_flatdark_gui::datagraph(all,moy) ""
      set ::atos_flatdark_gui::datagraph(use,x)   ""
      set ::atos_flatdark_gui::datagraph(use,moy)   ""

      # Id de la premiere image a traiter (-1 car on commence par next_image)
      set ::atos_tools::cur_idframe [expr $::atos_tools::frame_begin - 1]

      # Verification des Images
      set cpt 0
      set ::atos_flatdark_gui::sortie 0
      while {$::atos_flatdark_gui::sortie == 0} {

         update
         ::atos_tools::next_image $visuNo novisu

         set stat [buf$bufNo stat]
         lappend ::atos_flatdark_gui::datagraph(all,x)   $cpt
         lappend ::atos_flatdark_gui::datagraph(all,min) [format "%.0f" [lindex $stat 2]]
         lappend ::atos_flatdark_gui::datagraph(all,max) [format "%.0f" [lindex $stat 3]]
         lappend ::atos_flatdark_gui::datagraph(all,moy) [format "%.0f" [lindex $stat 4]]

         if {$::atos_tools::cur_idframe >= $::atos_tools::frame_end} {
            set ::atos_flatdark_gui::sortie 1
         }
         incr cpt

      }
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Verification des stats dans les images en $tt secondes\n"

      # Extraction des Images
      set tt0 [clock clicks -milliseconds]
      set nb [expr int($::atos_tools::nb_frames * $::atos_flatdark_gui::pcimg / 100.0)]
      gren_info "Estimation du nb image a traiter : $nb sur $::atos_tools::nb_frames\ images au total\n"
      set pas [expr int( $::atos_tools::nb_frames / ($nb)) ]
      gren_info "On garde 1 image toutes les $pas images\n"

      set cpt 0
      for {set i 0} {$i < $nb} {incr i} {
         update
         set ::atos_tools::cur_idframe [expr $::atos_tools::frame_begin + $i*$pas - 1]
         if {$::atos_tools::cur_idframe > $::atos_tools::frame_end} {break}

         ::atos_tools::next_image $visuNo novisu

         set stat [buf$bufNo stat]
         lappend ::atos_flatdark_gui::datagraph(use,x)   [expr $i*$pas]
         lappend ::atos_flatdark_gui::datagraph(use,moy) [format "%.0f" [lindex $stat 4]]

         buf$bufNo save atos_build_df${i}
         incr cpt
      }
      set nbimg $cpt
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Extraction des $nbimg images de reference en $tt secondes\n"

      # Construction du flat ou du dark
      set tt0 [clock clicks -milliseconds]
      ::console::affiche_resultat "Working ...\n"

      set nbk [expr $nbimg - 1]
      set fileout "atos_build_${df}_tmp"

      if {$df == "flat"} {

         # On fait des Flats

         # Est ce qu on utilise un Master Dark
         set masterdark [$::atos_gui::frame(use_dark) get]

         if {$::atos_flatdark_gui::usedark && [file exists ${masterdark}]} {

               # Ok le Master Dark existe et on l utilise
               gren_info "Ok le Master Dark existe\n"
               
               ttscript2 "IMA/SERIES . atos_build_df  0 $nbk $ext . atos_build_df 0 $ext SUB file=${masterdark} offset=0 bitpix=8"
               ttscript2 "IMA/STACK . atos_build_df 0 $nbk $ext . $fileout . $ext MED bitpix=8"
               
         } else {
            
            # On Traite sans Dark
            gren_info "On Traite sans Dark\n"
            ttscript2 "IMA/STACK . atos_build_df 0 $nbk $ext . $fileout . $ext MED bitpix=8"

         }

         loadima [file join $audace(rep_travail) $fileout]

      } else {

         # On fait des Darks
         
         ttscript2 "IMA/STACK  . atos_build_df 0 $nbk $ext . $fileout . $ext MED bitpix=8"
         ttscript2 "IMA/SERIES . $fileout .  .  $ext . $fileout . $ext STAT bitpix=8"

         loadima [file join $audace(rep_travail) $fileout]

      }

      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Construction du Flat Maitre en $tt secondes\n"
      

      for {set x 0} {$x < $nbimg} {incr x} {
         file delete -force "atos_build_df${x}${ext}" 
         file delete -force "atos_build_dfn${x}${ext}" 
      }

      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $ttstart)/1000.]]
      ::console::affiche_resultat "Traitement total en $tt secondes\n"

      $frm_start configure -image .start
      $frm_start configure -relief raised
      $frm_start configure -command "::atos_flatdark_gui::start $visuNo"
      
   }

   #
   # Sauvegarde de l image maitre : flat ou dark
   #
   proc ::atos_flatdark_gui::view { visuNo } {

      global audace

      set bufNo [::confVisu::getBufNo $visuNo]
      set ext [buf$bufNo extension]
      set df $::atos_flatdark::typecorr
      set fileout [file join $audace(rep_travail) "atos_build_${df}_tmp"]

      if {[file exists $fileout$ext]} { 
         loadima $fileout
      } else {
         gren_erreur "Pas de ${df}\n"
      }
      
   }

   #
   # Sauvegarde de l image maitre : flat ou dark
   #
   proc ::atos_flatdark_gui::save { visuNo } {
      
      global audace

      set bufNo [::confVisu::getBufNo $visuNo]
      set ext [buf$bufNo extension]
      set df $::atos_flatdark::typecorr
      set fileout [file join $audace(rep_travail) "atos_build_${df}_tmp"]

      if {[file exists $fileout$ext]} { 
         loadima $fileout
         set filefinal [$::atos_gui::frame(flatdark,$df).path get]
         set filefinal "$filefinal.master.${df}${ext}"
         gren_info "Save : $filefinal \n"
         set err [catch {file copy -force $fileout$ext $filefinal} msg]
         if {$err} {
            tk_messageBox -message "Imposible d entregistrer le fichier : \n$filefinal\nMSG : $msg " -type ok
         }
      } else {
         gren_erreur "Pas de ${df}\n"
      }

   }

   #
   # Affiche le graphique de l image maitre : flat ou dark
   #
   proc ::atos_flatdark_gui::graph { visuNo } {
      
      ::plotxy::clf 1
      ::plotxy::figure 1
      ::plotxy::hold on 
      ::plotxy::position {0 0 600 400}
      ::plotxy::title "Master $::atos_flatdark::typecorr" 
      ::plotxy::xlabel "$::atos_tools::frame_begin + id frame" 
      ::plotxy::ylabel "Flux (min, moy,max) ADU" 
      set nbx [llength $::atos_flatdark_gui::datagraph(all,x)]
      ::plotxy::axis [list 1 $nbx 0.0 256.0]
     
      set href [::plotxy::plot $::atos_flatdark_gui::datagraph(use,x) $::atos_flatdark_gui::datagraph(use,moy) ro. 3 ]
      plotxy::sethandler $href [list -color green -linewidth 0]
      set hmoy [::plotxy::plot $::atos_flatdark_gui::datagraph(all,x) $::atos_flatdark_gui::datagraph(all,moy) ro. 2 ]
      plotxy::sethandler $hmoy [list -color blue -linewidth 0]
      set hmin [::plotxy::plot $::atos_flatdark_gui::datagraph(all,x) $::atos_flatdark_gui::datagraph(all,min) ro. 2 ]
      plotxy::sethandler $hmin [list -color red -linewidth 0]
      set hmax [::plotxy::plot $::atos_flatdark_gui::datagraph(all,x) $::atos_flatdark_gui::datagraph(all,max) ro. 2 ]
      plotxy::sethandler $hmax [list -color red -linewidth 0]
      
   }

   #
   # Appuie sur le bouton USe Dark
   #
   proc ::atos_flatdark_gui::select_dark { visuNo } {
   
      set bufNo [::confVisu::getBufNo $visuNo]
      set ext [buf$bufNo extension]
      
      set masterdark [$::atos_gui::frame(flatdark,dark).path get]
      set masterdark "$masterdark.master.dark${ext}"
      if {[file exists $masterdark] && $::atos_flatdark_gui::usedark} {
         $::atos_gui::frame(use_dark) delete 0 end
         $::atos_gui::frame(use_dark) insert 0 $masterdark
         gren_info "Use $masterdark\n"
      }

   }

   #
   # Appuie sur le bouton Selection ... de USe Dark
   #
   proc ::atos_flatdark_gui::select_masterdark { visuNo frm } {

      global audace

      set bufNo [ visu$visuNo buf ]

      set df $::atos_flatdark::typecorr
gren_info "[$::atos_gui::frame(flatdark,$df).path get]   \n"
      set masterdark [::tkutil::box_load $frm [$::atos_gui::frame(flatdark,$df).path get] $bufNo "1"]
      if {[file exists $masterdark]} {
         $::atos_gui::frame(use_dark) delete 0 end
         $::atos_gui::frame(use_dark) insert 0 $masterdark
         gren_info "Use $masterdark\n"
      }

   }

}
