#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_setup.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_setup.tcl
# Description    : Configuration de certains parametres de l'outil Acquisition
# Auteur         : Robert DELMAS et Frederic Vachier
# Mise à jour $Id: atos_setup.tcl 14092 2016-10-20 22:02:19Z fredvachier $
#

namespace eval ::atos_setup {
  
   #
   # atos_setup::init
   # Chargement des captions
   #
   proc ::atos_setup::init { } {
      global audace

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool atos atos_setup.cap ]
   }

   #
   # atos_setup::initToConf
   # Initialisation des variables de configuration
   #
   proc ::atos_setup::initToConf { visuNo } {

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::atos::parametres(atos,$visuNo,messages) ] }                 { set ::atos::parametres(atos,$visuNo,messages)                 "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,save_file_log) ] }            { set ::atos::parametres(atos,$visuNo,save_file_log)            "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,alarme_fin_serie) ] }         { set ::atos::parametres(atos,$visuNo,alarme_fin_serie)         "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier) ] } { set ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier) "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,verifier_index_depart) ] }    { set ::atos::parametres(atos,$visuNo,verifier_index_depart)    "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,mode_debug) ] }               { set ::atos::parametres(atos,$visuNo,mode_debug)               "0" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,screen_refresh) ] }           { set ::atos::parametres(atos,$visuNo,screen_refresh)           "500" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,free_space) ] }               { set ::atos::parametres(atos,$visuNo,free_space)               "500" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,dir_prj) ] }                  { set ::atos::parametres(atos,$visuNo,dir_prj)                  "" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,tmpfs) ] }                    { set ::atos::parametres(atos,$visuNo,tmpfs)                    "/dev/shm" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,color_mode) ] }               {set ::atos::parametres(atos,$visuNo,color_mode)               "gray" }

      if { ! [ info exists ::atos::parametres(atos,$visuNo,exec_ocr_default) ]}          { set ::atos::parametres(atos,$visuNo,exec_ocr_default)  "gocr -d 6 -C '0-9' -f UTF8" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,exec_ocr_kiwi)    ]}          { set ::atos::parametres(atos,$visuNo,exec_ocr_kiwi)     "gocr -d 6 -C '0-9' -f UTF8" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,exec_convert_tim) ]}          { set ::atos::parametres(atos,$visuNo,exec_convert_tim)  "convert -blur 0x0.4 -unsharp 0x15.0" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,exec_ocr_tim)     ]}          { set ::atos::parametres(atos,$visuNo,exec_ocr_tim)      "gocr -d 6 -C '0-9' -f UTF8" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,exec_convert_vti) ]}          { set ::atos::parametres(atos,$visuNo,exec_convert_vti)  "convert -blur 0x0.4 -unsharp 0x15.0" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,exec_ocr_vti)     ]}          { set ::atos::parametres(atos,$visuNo,exec_ocr_vti)      "gocr -d 6 -C '0-9:' -c x -f UTF8" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,exec_ocr_sharpcap)]}          { set ::atos::parametres(atos,$visuNo,exec_ocr_sharpcap) "gocr -d 2 -C '0-9:' -f UTF8" }

   }

   #
   # atos_setup::run
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc ::atos_setup::run { visuNo this } {

      global audace panneau

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set base "$audace(base)"
      } else {
         set base ".visu$visuNo"
      }

      #---
      set panneau(atos,$visuNo,atos_setup) $this
      ::confGenerique::run $visuNo "$panneau(atos,$visuNo,atos_setup)" "::atos_setup" -modal 0
      set posx_config [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $panneau(atos,$visuNo,atos_setup) +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   }

   #
   # atos_setup::cmdApply
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc ::atos_setup::cmdApply { visuNo } {
       #--- Sauvegarde de la configuration de prise de vue
      ::atos_setup::enregistrerVariable $visuNo

   }

   #
   # atos_setup::showHelp
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc ::atos_setup::showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::atos::getPluginType ] ] \
         [ ::atos::getPluginDirectory ] atos_setup.htm
   }

   #
   # atos_setup::cmdClose
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc ::atos_setup::cmdClose { visuNo } {

   }

   #
   # atos_setup::getLabel
   # Retourne le nom de la fenetre de configuration
   #
   proc ::atos_setup::getLabel { } {
      global caption

      return "$caption(atos_setup,titre)"
   }

   #
   # atos::deletePluginInstance
   #    suppprime l'instance du plugin
   #
   proc ::atos_setup::enregistrerVariable { visuNo } {

      ::console::affiche_resultat "Enregistrement de la Configuration...\n"
      #foreach { a b } [ array get ::atos::parametres ] {
      #   if  {[string first atos $a]==0} {
      #   ::console::affiche_resultat "$a = $b\n"
      #   }
      #}

      #--- Sauvegarde des parametres
      catch {
        set nom_fichier [ file join $::audace(rep_home) atos.ini ]
        if [ catch { open $nom_fichier w } fichier ] {
           #---
        } else {
           foreach { a b } [ array get ::atos::parametres ] {
              if  {[string first atos $a]==0} {
                 puts $fichier "set ::atos::parametres($a) \"$b\""
              }
           }
           close $fichier
        }
      }
   }
   #
   # atos_acq::demo
   # Ouvre une boite de telechargement d'une video de reference
   #
   proc ::atos_setup::demo { visuNo frm } {

      package require http

      set ::atos_setup::demo_title "Téléchargement en cours"
      set ::atos_setup::demo_state disabled

      $frm configure -text  $::atos_setup::demo_title
      $frm configure -state $::atos_setup::demo_state

      $frm configure -text "Télécharger"
      $frm configure -state normal

      return

      set msg "La Démo va créer un repertoire et un fichier dans votre repertoire projet\n"
      append msg "Une video de 76 Mo va etre telechargée dans ce repertoire\n"
      set res [tk_messageBox -message $msg -type yesno]
      if {$res=="yes"} {
         ::console::affiche_resultat "ok\n"
      }

      if {$::atos::parametres(atos,$visuNo,dir_prj)==""} {
         tk_messageBox -message "Veuillez choisir un repertoire Projet" -type ok
      }

      set url "http://www.imcce.fr/~vachier/occultation/demo/sapphoseg.00.avi"
      #set url "http://www.imcce.fr/~vachier/occultation/demo/test"

      set dir [file join $::atos::parametres(atos,$visuNo,dir_prj) DEMO_20100604_234000_80_Sappho]
      if {![file exists $dir]} {file mkdir $dir}

      set filename [file join $dir [file tail $url]]
      ::console::affiche_resultat "Debut du telechargement de [file tail $url]\n"

      set ::atos_setup::r [http::geturl $url -binary 1]

      set fo [open $filename w]
      fconfigure $fo -translation binary
      puts -nonewline $fo [http::data $::atos_setup::r]
      close $fo
      ::http::cleanup $::atos_setup::r

      ::console::affiche_resultat "Got $url -> $filename"

   }

   #
   # atos_acq::chgdir
   # Ouvre une boite de dialogue pour choisir un nom  de repertoire
   #
   proc ::atos_setup::chgdir { This } {
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
      set rep "$audace(rep_images)"
      set title $caption(atos_setup,chgdir)

      set numerror [ catch { set filename "[ ::cwdWindow::tkplus_chooseDir "$rep" $title $This ]" } msg ]
      if { $numerror == "1" } {
         set filename "[ ::cwdWindow::tkplus_chooseDir "[pwd]" $title $This ]"
      }

      $This delete 0 end
      $This insert 0 $filename

   }


   #
   # atos_setup::fillConfigPage
   # Creation de l'interface graphique
   #
   proc ::atos_setup::fillConfigPage { frm visuNo } {

      global caption panneau atosconf

      #--- Retourne l'item de la camera associee a la visu
      set camItem [ ::confVisu::getCamItem $visuNo ]
      set frm $panneau(atos,$visuNo,atos_setup)

      #--- Cree des onglets
      set onglets [frame $frm.onglets -borderwidth 0 -cursor arrow -relief groove]
      pack $onglets -in $frm -side top -expand 0 -fill x -fill y -padx 10 -pady 5

         pack [ttk::notebook $onglets.nb]
         set f0  [frame $onglets.nb.f0]
         set f1  [frame $onglets.nb.f1]
         set f2  [frame $onglets.nb.f2]

         $onglets.nb add $f0  -text $caption(atos_setup,preferences)
         $onglets.nb add $f1  -text $caption(atos_setup,ocr)
         #$onglets.nb add $f2  -text $caption(atos_setup,demo)
         $onglets.nb select $f0
         ttk::notebook::enableTraversal $onglets.nb

      #--- Frame pour l'onglet preferences
      frame $f0.frame3 -borderwidth 1 -relief raise
      pack $f0.frame3 -side top -fill both -expand 1

         #--- Frame pour le : repertoire projet
         frame $f0.frame3.dir_prj -borderwidth 0
         pack $f0.frame3.dir_prj -side top -fill both -expand 1 -padx 5 -pady 5

            frame $f0.frame3.dir_prj.frm -borderwidth 0
            pack $f0.frame3.dir_prj.frm -side left

               button $f0.frame3.dir_prj.frm.but -text "..." -borderwidth 1 -command "::atos_setup::chgdir $f0.frame3.dir_prj.frm.value"
               pack $f0.frame3.dir_prj.frm.but -side right -padx 2 -pady 0
               entry $f0.frame3.dir_prj.frm.value -width 40 -textvariable ::atos::parametres(atos,$visuNo,dir_prj)
               pack $f0.frame3.dir_prj.frm.value -side right -padx 5 -pady 0
               label $f0.frame3.dir_prj.frm.lab -text "$caption(atos_setup,dir_prj)"
               pack $f0.frame3.dir_prj.frm.lab -side right -padx 5 -pady 0

         #--- Frame pour le : repertoire tmpfs
         frame $f0.frame3.tmpfs -borderwidth 0
         pack $f0.frame3.tmpfs -side top -fill both -expand 1 -padx 5 -pady 5

            frame $f0.frame3.tmpfs.frm -borderwidth 0
            pack $f0.frame3.tmpfs.frm -side left

               entry $f0.frame3.tmpfs.frm.value -width 40 -textvariable ::atos::parametres(atos,$visuNo,tmpfs)
               pack $f0.frame3.tmpfs.frm.value -side right -padx 5 -pady 0
               label $f0.frame3.tmpfs.frm.lab -text "$caption(atos_setup,tmpfs)"
               pack $f0.frame3.tmpfs.frm.lab -side right -padx 5 -pady 0

         #--- Frame pour le : AVI color mode
         frame $f0.frame3.colormode -borderwidth 0
         pack $f0.frame3.colormode -side top -fill both -expand 1 -padx 5 -pady 5

            frame $f0.frame3.colormode.frm -borderwidth 0
            pack $f0.frame3.colormode.frm -side left

               set sav $::atos::parametres(atos,$visuNo,color_mode)
               spinbox $f0.frame3.colormode.frm.value -values [list "gray" "rgb"] \
                       -textvariable ::atos::parametres(atos,$visuNo,color_mode)
               pack $f0.frame3.colormode.frm.value -side right -padx 5 -pady 0
               label $f0.frame3.colormode.frm.lab -text "$caption(atos_setup,color_mode)"
               pack $f0.frame3.colormode.frm.lab -side right -padx 5 -pady 0
               $f0.frame3.colormode.frm.value set $sav

         #--- Frame pour le commentaire 1
         frame $f0.frame3.frame4 -borderwidth 0
         pack $f0.frame3.frame4 -side top -fill both -expand 1 -padx 5 -pady 2

            #--- Cree le checkbutton pour le commentaire 1
            frame $f0.frame3.frame4.frame8 -borderwidth 0
               checkbutton $f0.frame3.frame4.frame8.check1 -highlightthickness 0 \
                  -text "$caption(atos_setup,texte1)" -variable ::atos::parametres(atos,$visuNo,messages)
               pack $f0.frame3.frame4.frame8.check1 -side right -padx 5 -pady 0
            pack $f0.frame3.frame4.frame8 -side left


         #--- Frame pour le commentaire 4 : verifier_ecraser_fichier
         frame $f0.frame3.frame7 -borderwidth 0
         pack $f0.frame3.frame7 -side top -fill both -expand 1 -padx 5 -pady 2

            #--- Cree le checkbutton pour le commentaire 4
            frame $f0.frame3.frame7.frame12 -borderwidth 0
               checkbutton $f0.frame3.frame7.frame12.check3 -highlightthickness 0 \
                  -text "$caption(atos_setup,texte4)" -variable ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier)
               pack $f0.frame3.frame7.frame12.check3 -side right -padx 5 -pady 0
            pack $f0.frame3.frame7.frame12 -side left


         #--- Frame pour le commentaire 5 : mode_debug
         frame $f0.frame3.frame9 -borderwidth 0
         pack $f0.frame3.frame9 -side top -fill both -expand 1 -padx 5 -pady 2

            #--- Cree le checkbutton pour le commentaire 5
            frame $f0.frame3.frame9.frame12 -borderwidth 0
               checkbutton $f0.frame3.frame9.frame12.check3 -highlightthickness 0 \
                  -text "$caption(atos_setup,texte6)" -variable ::atos::parametres(atos,$visuNo,mode_debug)
               pack $f0.frame3.frame9.frame12.check3 -side right -padx 5 -pady 0
            pack $f0.frame3.frame9.frame12 -side left


         #--- Frame pour le : screen_refresh
         frame $f0.frame3.screen_refresh -borderwidth 0
         pack $f0.frame3.screen_refresh -side top -fill both -expand 1 -padx 5 -pady 5

            frame $f0.frame3.screen_refresh.frm -borderwidth 0
            pack $f0.frame3.screen_refresh.frm -side left

               label $f0.frame3.screen_refresh.frm.unit -text "ms"
               pack $f0.frame3.screen_refresh.frm.unit -side right -padx 1 -pady 0
               entry $f0.frame3.screen_refresh.frm.value -width 5 -textvariable ::atos::parametres(atos,$visuNo,screen_refresh)
               pack $f0.frame3.screen_refresh.frm.value -side right -padx 5 -pady 0
               label $f0.frame3.screen_refresh.frm.lab -text "$caption(atos_setup,screen_refresh)"
               pack $f0.frame3.screen_refresh.frm.lab -side right -padx 5 -pady 0

         #--- Frame pour le : free_space
         frame $f0.frame3.free_space -borderwidth 0
         pack $f0.frame3.free_space -side top -fill both -expand 1 -padx 5 -pady 5

            frame $f0.frame3.free_space.frm -borderwidth 0
            pack $f0.frame3.free_space.frm -side left

               label $f0.frame3.free_space.frm.unit -text "Mo"
               pack $f0.frame3.free_space.frm.unit -side right -padx 1 -pady 0
               entry $f0.frame3.free_space.frm.value -width 5 -textvariable ::atos::parametres(atos,$visuNo,free_space)
               pack $f0.frame3.free_space.frm.value -side right -padx 5 -pady 0
               label $f0.frame3.free_space.frm.lab -text "$caption(atos_setup,free_space)"
               pack $f0.frame3.free_space.frm.lab -side right -padx 5 -pady 0

      #--- Frame pour l'onglet OCR
      frame $f1.frame3 -borderwidth 1 -relief raise
      pack $f1.frame3 -side top -fill both -expand 1

         #--- Frame pour la label
         label $f1.frame3.lab -text "$caption(atos_setup,exec_ocr)"
         pack $f1.frame3.lab -side top -padx 5 -pady 10

         #--- Frame pour le : exec_ocr
         frame $f1.frame3.ocr -borderwidth 0
         pack $f1.frame3.ocr -side top -fill both -expand 1

            frame $f1.frame3.ocr.def -borderwidth 0
            pack $f1.frame3.ocr.def -side top -pady 5
               button $f1.frame3.ocr.def.but -text "test" -borderwidth 1 -command "" -state disabled
               pack $f1.frame3.ocr.def.but -side right -padx 5 -pady 0 -ipadx 10
               entry $f1.frame3.ocr.def.value -width 50 -textvariable ::atos::parametres(atos,$visuNo,exec_ocr_default)
               pack $f1.frame3.ocr.def.value -side right -padx 1 -pady 1
               label $f1.frame3.ocr.def.lab -text "Default:" -anchor e -width 8
               pack $f1.frame3.ocr.def.lab -side right -padx 5 -pady 2

            frame $f1.frame3.ocr.vti -borderwidth 0
            pack $f1.frame3.ocr.vti -side top -pady 5
               button $f1.frame3.ocr.vti.but -text "test" -borderwidth 1 -command "" -state disabled
               pack $f1.frame3.ocr.vti.but -side right -padx 5 -pady 0 -ipadx 10

               frame $f1.frame3.ocr.vti.c -borderwidth 0
               pack $f1.frame3.ocr.vti.c -side right -padx 5 -pady 0
                  entry $f1.frame3.ocr.vti.c.value1 -width 50 -textvariable ::atos::parametres(atos,$visuNo,exec_convert_vti)
                  pack $f1.frame3.ocr.vti.c.value1 -side top -padx 1 -pady 1
                  entry $f1.frame3.ocr.vti.c.value2 -width 50 -textvariable ::atos::parametres(atos,$visuNo,exec_ocr_vti)
                  pack $f1.frame3.ocr.vti.c.value2 -side top -padx 1 -pady 1

               label $f1.frame3.ocr.vti.lab -text "IOTA-VTI:" -anchor e -width 8
               pack $f1.frame3.ocr.vti.lab -side right -padx 5 -pady 2

            frame $f1.frame3.ocr.tim -borderwidth 0
            pack $f1.frame3.ocr.tim -side top -pady 5
               button $f1.frame3.ocr.tim.but -text "test" -borderwidth 1 -command "" -state disabled
               pack $f1.frame3.ocr.tim.but -side right -padx 5 -pady 0 -ipadx 10

               frame $f1.frame3.ocr.tim.c -borderwidth 0
               pack $f1.frame3.ocr.tim.c -side right -padx 5 -pady 0
                  entry $f1.frame3.ocr.tim.c.value1 -width 50 -textvariable ::atos::parametres(atos,$visuNo,exec_convert_tim)
                  pack $f1.frame3.ocr.tim.c.value1 -side top -padx 1 -pady 1
                  entry $f1.frame3.ocr.tim.c.value2 -width 50 -textvariable ::atos::parametres(atos,$visuNo,exec_ocr_tim)
                  pack $f1.frame3.ocr.tim.c.value2 -side right -padx 1 -pady 1

               label $f1.frame3.ocr.tim.lab -text "TIM-10:" -anchor e -width 8
               pack $f1.frame3.ocr.tim.lab -side right -padx 5 -pady 2

            frame $f1.frame3.ocr.kiwi -borderwidth 0
            pack $f1.frame3.ocr.kiwi -side top -pady 5
               button $f1.frame3.ocr.kiwi.but -text "test" -borderwidth 1 -command "" -state disabled
               pack $f1.frame3.ocr.kiwi.but -side right -padx 5 -pady 0 -ipadx 10
               entry $f1.frame3.ocr.kiwi.value -width 50 -textvariable ::atos::parametres(atos,$visuNo,exec_ocr_kiwi)
               pack $f1.frame3.ocr.kiwi.value -side right -padx 1 -pady 1
               label $f1.frame3.ocr.kiwi.lab -text "Kiwi-OSD:" -anchor e -width 8
               pack $f1.frame3.ocr.kiwi.lab -side right -padx 5 -pady 2

            frame $f1.frame3.ocr.sharpcap -borderwidth 0
            pack $f1.frame3.ocr.sharpcap -side top -pady 5
               button $f1.frame3.ocr.sharpcap.but -text "test" -borderwidth 1 -command "" -state disabled
               pack $f1.frame3.ocr.sharpcap.but -side right -padx 5 -pady 0 -ipadx 10
               entry $f1.frame3.ocr.sharpcap.value -width 50 -textvariable ::atos::parametres(atos,$visuNo,exec_ocr_sharpcap)
               pack $f1.frame3.ocr.sharpcap.value -side right -padx 1 -pady 1
               label $f1.frame3.ocr.sharpcap.lab -text "SharpCap:" -anchor e -width 8
               pack $f1.frame3.ocr.sharpcap.lab -side right -padx 5 -pady 2

      #--- Frame pour l'onglet DEMO
      #frame $f2.frame3 -borderwidth 1 -relief raise
      #pack $f2.frame3 -side top -fill both -expand 1
      #
      #   #--- Frame pour le : repertoire projet
      #   frame $f2.frame3.demo -borderwidth 0
      #
      #      frame $f2.frame3.demo.frm -borderwidth 0
      #         button $f2.frame3.demo.frm.but -text "Télécharger" -borderwidth 1 -command "::atos_setup::demo $visuNo $f2.frame3.demo.frm.but"
      #         pack $f2.frame3.demo.frm.but -side right -padx 2 -pady 0
      #         label $f2.frame3.demo.frm.lab -text "Télécharger la demo : "
      #         pack $f2.frame3.demo.frm.lab -side right -padx 5 -pady 0
      #      pack $f2.frame3.demo.frm -side left
      #
      #   pack $f2.frame3.demo -side top -fill both -expand 1

   }

}

#--- Initialisation au demarrage
::atos_setup::init

