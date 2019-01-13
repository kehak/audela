# --------------------------------------------------
# source audace/plugin/tool/robobs/robobs_planif.tcl
# --------------------------------------------------
#
# Fichier        : robobs_planif.tcl
# Description    : planification de RobObs
# Auteur         : Alain Klotz
# Mise à jour $Id: robobs_planif.tcl 14439 2018-06-08 12:51:06Z alainklotz $
#
# --------------------------------------------------
# robobs(planif,mode) : meridian vttrrlyr snresearch1 geostat1 asteroid_light_curve
# robobs(conf,home,telescope_id,value) : makes_t60
# --------------------------------------------------

namespace eval ::robobs_planif {

   global audace
   global robobsplanif
   global robobs

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool robobs robobs_planif.cap ]\""

   #--------------------------------------------------
   # run { this }
   #--------------------------------------------------
   #
   #    fonction  :
   #        Creation de la fenetre
   #
   #    procedure externe :
   #
   #    variables en entree :
   #        this = chemin de la fenetre
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc run { this } {
      variable This
      global caption
      global robobs
      global audace

      set This $this
      # ---
      ::robobs_config::update
      ::robobs_planif::update
      ::robobs_planif::wizard ""
      return
   }

   proc update {} {
      variable This
      global caption
      global robobs
      global audace
      # --- defines type mode of scheduling
      set robobs(planif,modes) {meridian vttrrlyr trerrlyr snresearch1 geostat1 asteroid_light_curve star_light_curve vachier_berthier}
		lappend robobs(planif,modes) personal
      # --- fill the list caption(robobs_planif,modes) using other captions
      set caption(robobs_planif,modes) ""
      set n [llength $robobs(planif,modes)]
      for {set k 0} {$k<$n} {incr k} {
         set name_mode [lindex $robobs(planif,modes) $k]
         lappend caption(robobs_planif,modes) $caption(robobs_planif,mode,$name_mode)
      }
      # --- default mode
      if {[info exists robobs(planif,mode)]==0} {
         set robobs(planif,mode) meridian
      }
      set fic "$audace(rep_travail)/robobs/robobs.sch"
      catch {
         source $fic
      }
   }

   #--------------------------------------------------
   # fermer { }
   #--------------------------------------------------
   #
   #    fonction  :
   #        Fonction appellee lors de l'appui
   #        sur le bouton 'Fermer'
   #
   #    procedure externe :
   #
   #    variables en entree :
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc fermer { } {
      variable This
      global caption
      global robobs
      global audace

      if {[catch {$This configure}]==1} {
         return
      }
      ::robobs_planif::recup_position
      destroy $This
      # enregistre les nouveaux parametres dans un fichier de configuration
      set texte ""
      append texte "set robobs(planif,mode) $robobs(planif,mode)\n"
      set fic "$audace(rep_travail)/robobs/robobs.sch"
      catch {
         set f [open $fic w]
         puts -nonewline $f $texte
         close $f
      }
      ::robobs_config::save_config
      return
   }

   #--------------------------------------------------
   #  recup_position { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       Permet de recuperer et de sauvegarder
   #       la position de la fenetre
   #
   #    procedure externe :
   #
   #    variables en entree :
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc recup_position { } {
      variable This
      global audace
      global conf
      global robobsplanif

      set robobsplanif(geometry_status) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $robobsplanif(geometry_status) ] ]
      set fin [ string length $robobsplanif(geometry_status) ]
      set robobsplanif(position_status) "+[ string range $robobsplanif(geometry_status) $deb $fin ]"
      #---
      set conf(robobs,position_status) $robobsplanif(position_status)
      return
   }

   #--------------------------------------------------
   #  createDialog { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       Creation de l'interface graphique
   #
   #    procedure externe :
   #
   #    variables en entree :
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc createDialog { {mode ""} } {

      variable This
      global audace
      global caption
      global color
      global conf
      global robobsplanif
      global robobs
      global robobsconf

      #--- initConf
      if { ! [ info exists conf(robobs,position_status) ] } { set conf(robobs,position_status) "+80+40" }

      #--- confToWidget
      set robobsplanif(position_status) $conf(robobs,position_status)

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         return
      }

      #---
      if { [ info exists robobsplanif(geometry_status) ] } {
         set deb [ expr 1 + [ string first + $robobsplanif(geometry_status) ] ]
         set fin [ string length $robobsplanif(geometry_status) ]
         set robobsplanif(position_status) "+[ string range $robobsplanif(geometry_status) $deb $fin ]"
      }

      #---
      toplevel $This -class Toplevel
      wm geometry $This $robobsplanif(position_status)
      wm resizable $This 1 1
      wm title $This $caption(robobs_planif,main_title)
      wm protocol $This WM_DELETE_WINDOW { ::robobs_planif::fermer }

      #--- Cree un frame pour afficher le titre
      frame $This.frame1 -borderwidth 0 -cursor arrow -relief groove
      pack $This.frame1 -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

      #--- Cree un label pour le titre
      label $This.frame1.titre \
        -text "$caption(robobs_planif,titre)"
      pack $This.frame1.titre \
       -in $This.frame1 -side top -padx 3 -pady 3

      set robobs(planif,window,mode) $mode

      if {$mode==""} {

         #--- Cree un frame pour le choix du mode de planif
         frame $This.frame2 -borderwidth 0 -cursor arrow -relief groove
         pack $This.frame2 -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

           #--- Cree un label
           label $This.frame2.titre \
                 -text "$caption(robobs_planif,type_modes)"
           pack $This.frame2.titre \
                -in $This.frame2 -side left -padx 3 -pady 3

            ComboBox $This.frame2.combobox \
               -expand tab -width 45         \
               -relief sunken    \
               -borderwidth 2    \
               -editable 0       \
               -modifycmd "::robobs_planif::modif_choix $This.frame2.combobox" \
               -values $caption(robobs_planif,modes)
            $This.frame2.combobox setvalue @[::robobs_planif::mode $robobs(planif,mode) index]
            pack $This.frame2.combobox -in $This.frame2 -anchor w -side left -padx 2 -pady 5

         #--- Cree un frame pour le choix du mode de planif
         frame $This.frame2b -borderwidth 0 -cursor arrow -relief groove
         pack $This.frame2b -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

           #--- Cree un label
           label $This.frame2b.titre \
                 -text ""
           pack $This.frame2b.titre \
                -in $This.frame2b -side left -padx 3 -pady 3
            $This.frame2b.titre configure -text $caption(robobs_planif,infos,$robobs(planif,mode))


      } else {

         set robobs(conf_planif,$robobs(planif,mode),filter) C
         
			#--- Calibration strategy
			if {[info exists robobs(planif,calib,strategy)]==0} {
				set robobs(planif,calib,strategy) ""
			}
			
         #--- Cree un frame pour indiquer le choix du mode de planif
         frame $This.frame2b -borderwidth 0 -cursor arrow -relief groove
         pack $This.frame2b -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 2

         #--- Cree un label
         label $This.frame2b.titre \
           -text ""
         pack $This.frame2b.titre \
          -in $This.frame2b -side top -padx 3 -pady 0
         $This.frame2b.titre configure -text "$caption(robobs_planif,attrib): $caption(robobs_planif,mode,$robobs(planif,mode))"
         $This.frame2b.titre configure -font $robobsconf(font,arial_12_b)

         if {$robobs(planif,mode)=="snresearch1"} {

            # --- charge la configuration
            ::robobs_config::load_config

            #--- Cree un frame
            frame $This.frame2c -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame2c -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame2c.lab1 \
                    -text ""
               pack $This.frame2c.lab1 \
                   -in $This.frame2c -side left -padx 3 -pady 0
               $This.frame2c.lab1 configure -text "$caption(robobs_planif,snresearch1,filegals)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,snresearch1,filegals)]==0} {
                  set robobs(conf_planif,snresearch1,filegals) "[file join $audace(rep_plugin) tool supernovae cata_supernovae sn.txt]"
               }
               entry $This.frame2c.ent1 \
                 -width 50 -textvariable robobs(conf_planif,snresearch1,filegals)
               pack $This.frame2c.ent1 \
                -in $This.frame2c -side left -padx 3 -pady 0

               #--- Cree un bouton
               button $This.frame2c.but1 \
                    -text "$caption(robobs_planif,snresearch1,change)" -command { global robobs ; set a [tk_getOpenFile] ; if {$a!=""} { set robobs(conf_planif,snresearch1,filegals) $a} }
               pack $This.frame2c.but1 \
                   -in $This.frame2c -side left -padx 3 -pady 0

               #--- Cree un bouton
               button $This.frame2c.but2 \
                    -text "$caption(robobs_planif,snresearch1,default)" -command { global robobs audace ; set robobs(conf_planif,snresearch1,filegals) [file join $audace(rep_plugin) tool supernovae cata_supernovae sn.txt] ; update }
               pack $This.frame2c.but2 \
                   -in $This.frame2c -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame2d -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame2d -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame2d.lab1 \
                    -text ""
               pack $This.frame2d.lab1 \
                   -in $This.frame2d -side left -padx 3 -pady 0
               $This.frame2d.lab1 configure -text "$caption(robobs_planif,snresearch1,magliminf)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,snresearch1,magliminf)]==0} {
                  set robobs(conf_planif,snresearch1,magliminf) "-1"
               }
               entry $This.frame2d.ent1 \
                 -width 10 -textvariable robobs(conf_planif,snresearch1,magliminf)
               pack $This.frame2d.ent1 \
                -in $This.frame2d -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame2e -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame2e -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame2e.lab1 \
                    -text ""
               pack $This.frame2e.lab1 \
                   -in $This.frame2e -side left -padx 3 -pady 0
               $This.frame2e.lab1 configure -text "$caption(robobs_planif,snresearch1,maglimsup)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,snresearch1,maglimsup)]==0} {
                  set robobs(conf_planif,snresearch1,maglimsup) "13.5"
               }
               entry $This.frame2e.ent1 \
                 -width 10 -textvariable robobs(conf_planif,snresearch1,maglimsup)
               pack $This.frame2e.ent1 \
                -in $This.frame2e -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame2f -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame2f -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame2f.lab1 \
                    -text ""
               pack $This.frame2f.lab1 \
                   -in $This.frame2f -side left -padx 3 -pady 0
               $This.frame2f.lab1 configure -text "$caption(robobs_planif,snresearch1,exposure)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,snresearch1,exposure)]==0} {
                  set robobs(conf_planif,snresearch1,exposure) "60"
               }
               entry $This.frame2f.ent1 \
                 -width 5 -textvariable robobs(conf_planif,snresearch1,exposure)
               pack $This.frame2f.ent1 \
                -in $This.frame2f -side left -padx 3 -pady 0

               #--- Cree un label
               label $This.frame2f.lab2 \
                    -text ""
               pack $This.frame2f.lab2 \
                   -in $This.frame2f -side left -padx 3 -pady 0
               $This.frame2f.lab2 configure -text "$caption(robobs_planif,snresearch1,seconds)"

            #--- Cree un frame
            frame $This.frame2g -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame2g -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame2g.lab1 \
                    -text ""
               pack $This.frame2g.lab1 \
                   -in $This.frame2g -side left -padx 3 -pady 0
               $This.frame2g.lab1 configure -text "$caption(robobs_planif,snresearch1,binning)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,snresearch1,binning)]==0} {
                  set robobs(conf_planif,snresearch1,binning) "2"
               }
               entry $This.frame2g.ent1 \
                 -width 5 -textvariable robobs(conf_planif,snresearch1,binning)
               pack $This.frame2g.ent1 \
                -in $This.frame2g -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame2h -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame2h -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame2h.lab1 \
                    -text ""
               pack $This.frame2h.lab1 \
                   -in $This.frame2h -side left -padx 3 -pady 0
               $This.frame2h.lab1 configure -text "$caption(robobs_planif,snresearch1,nbimages)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,snresearch1,nbimages)]==0} {
                  set robobs(conf_planif,snresearch1,nbimages) "1"
               }
               entry $This.frame2h.ent1 \
                 -width 5 -textvariable robobs(conf_planif,snresearch1,nbimages)
               pack $This.frame2h.ent1 \
                -in $This.frame2h -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame2i -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame2i -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame2i.lab1 \
                    -text ""
               pack $This.frame2i.lab1 \
                   -in $This.frame2i -side left -padx 3 -pady 0
               $This.frame2i.lab1 configure -text "$caption(robobs_planif,snresearch1,smearing)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,snresearch1,smearing)]==0} {
                  set robobs(conf_planif,snresearch1,smearing) "0"
               }
               entry $This.frame2i.ent1 \
                 -width 10 -textvariable robobs(conf_planif,snresearch1,smearing)
               pack $This.frame2i.ent1 \
                -in $This.frame2i -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame2j -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame2j -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame2j.lab1 \
                    -text ""
               pack $This.frame2j.lab1 \
                   -in $This.frame2j -side left -padx 3 -pady 0
               $This.frame2j.lab1 configure -text "$caption(robobs_planif,snresearch1,filebias)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,snresearch1,filebias)]==0} {
                  set robobs(conf_planif,snresearch1,filebias) "[file join $audace(rep_images) bias.fit]"
               }
               entry $This.frame2j.ent1 \
                 -width 50 -textvariable robobs(conf_planif,snresearch1,filebias)
               pack $This.frame2j.ent1 \
                -in $This.frame2j -side left -padx 3 -pady 0

               #--- Cree un bouton
               button $This.frame2j.but1 \
                    -text "$caption(robobs_planif,snresearch1,change)" -command { global robobs ; set a [tk_getOpenFile] ; if {$a!=""} { set robobs(conf_planif,snresearch1,filebias) $a} }
               pack $This.frame2j.but1 \
                   -in $This.frame2j -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame2k -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame2k -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame2k.lab1 \
                    -text ""
               pack $This.frame2k.lab1 \
                   -in $This.frame2k -side left -padx 3 -pady 0
               $This.frame2k.lab1 configure -text "$caption(robobs_planif,snresearch1,filedark)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,snresearch1,filedark)]==0} {
                  set robobs(conf_planif,snresearch1,filedark) "[file join $audace(rep_images) dark.fit]"
               }
               entry $This.frame2k.ent1 \
                 -width 50 -textvariable robobs(conf_planif,snresearch1,filedark)
               pack $This.frame2k.ent1 \
                -in $This.frame2k -side left -padx 3 -pady 0

               #--- Cree un bouton
               button $This.frame2k.but1 \
                    -text "$caption(robobs_planif,snresearch1,change)" -command { global robobs ; set a [tk_getOpenFile] ; if {$a!=""} { set robobs(conf_planif,snresearch1,filedark) $a} }
               pack $This.frame2k.but1 \
                   -in $This.frame2k -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame2l -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame2l -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame2l.lab1 \
                    -text ""
               pack $This.frame2l.lab1 \
                   -in $This.frame2l -side left -padx 3 -pady 0
               $This.frame2l.lab1 configure -text "$caption(robobs_planif,snresearch1,fileflat)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,snresearch1,fileflat)]==0} {
                  set robobs(conf_planif,snresearch1,fileflat) "[file join $audace(rep_images) flat.fit]"
               }
               entry $This.frame2l.ent1 \
                 -width 50 -textvariable robobs(conf_planif,snresearch1,fileflat)
               pack $This.frame2l.ent1 \
                -in $This.frame2l -side left -padx 3 -pady 0

               #--- Cree un bouton
               button $This.frame2l.but1 \
                    -text "$caption(robobs_planif,snresearch1,change)" -command { global robobs ; set a [tk_getOpenFile] ; if {$a!=""} { set robobs(conf_planif,snresearch1,fileflat) $a} }
               pack $This.frame2l.but1 \
                   -in $This.frame2l -side left -padx 3 -pady 0
         }

         if {$robobs(planif,mode)=="asteroid_light_curve"} {

            # --- charge la configuration
            ::robobs_config::load_config

            #--- Cree un frame
            frame $This.frame3c -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame3c -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame3c.lab1 \
                    -text ""
               pack $This.frame3c.lab1 \
                   -in $This.frame3c -side left -padx 3 -pady 0
               $This.frame3c.lab1 configure -text "$caption(robobs_planif,asteroid_light_curve,object_name1)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,asteroid_light_curve,object_name1)]==0} {
                  set robobs(conf_planif,asteroid_light_curve,object_name1) "ceres"
               }
               entry $This.frame3c.ent1 \
                 -width 20 -textvariable robobs(conf_planif,asteroid_light_curve,object_name1)
               pack $This.frame3c.ent1 \
                -in $This.frame3c -side left -padx 3 -pady 0

               #--- Cree un label
               label $This.frame3c.lab2 \
                    -text ""
               pack $This.frame3c.lab2 \
                   -in $This.frame3c -side left -padx 3 -pady 0
               $This.frame3c.lab2 configure -text "$caption(robobs_planif,asteroid_light_curve,object_coord)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,asteroid_light_curve,object_coord1)]==0} {
                  set robobs(conf_planif,asteroid_light_curve,object_coord1) ""
               }
               entry $This.frame3c.ent2 \
                 -width 30 -textvariable robobs(conf_planif,asteroid_light_curve,object_coord1)
               pack $This.frame3c.ent2 \
                -in $This.frame3c -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame3d -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame3d -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame3d.lab1 \
                    -text ""
               pack $This.frame3d.lab1 \
                   -in $This.frame3d -side left -padx 3 -pady 0
               $This.frame3d.lab1 configure -text "$caption(robobs_planif,asteroid_light_curve,object_name2)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,asteroid_light_curve,object_name2)]==0} {
                  set robobs(conf_planif,asteroid_light_curve,object_name2) ""
               }
               entry $This.frame3d.ent1 \
                 -width 20 -textvariable robobs(conf_planif,asteroid_light_curve,object_name2)
               pack $This.frame3d.ent1 \
                -in $This.frame3d -side left -padx 3 -pady 0

               #--- Cree un label
               label $This.frame3d.lab2 \
                    -text ""
               pack $This.frame3d.lab2 \
                   -in $This.frame3d -side left -padx 3 -pady 0
               $This.frame3d.lab2 configure -text "$caption(robobs_planif,asteroid_light_curve,object_coord)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,asteroid_light_curve,object_coord2)]==0} {
                  set robobs(conf_planif,asteroid_light_curve,object_coord2) ""
               }
               entry $This.frame3d.ent2 \
                 -width 30 -textvariable robobs(conf_planif,asteroid_light_curve,object_coord2)
               pack $This.frame3d.ent2 \
                -in $This.frame3d -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame3e -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame3e -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame3e.lab1 \
                    -text ""
               pack $This.frame3e.lab1 \
                   -in $This.frame3e -side left -padx 3 -pady 0
               $This.frame3e.lab1 configure -text "$caption(robobs_planif,asteroid_light_curve,object_name3)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,asteroid_light_curve,object_name3)]==0} {
                  set robobs(conf_planif,asteroid_light_curve,object_name3) ""
               }
               entry $This.frame3e.ent1 \
                 -width 20 -textvariable robobs(conf_planif,asteroid_light_curve,object_name3)
               pack $This.frame3e.ent1 \
                -in $This.frame3e -side left -padx 3 -pady 0

               #--- Cree un label
               label $This.frame3e.lab2 \
                    -text ""
               pack $This.frame3e.lab2 \
                   -in $This.frame3e -side left -padx 3 -pady 0
               $This.frame3e.lab2 configure -text "$caption(robobs_planif,asteroid_light_curve,object_coord)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,asteroid_light_curve,object_coord3)]==0} {
                  set robobs(conf_planif,asteroid_light_curve,object_coord3) ""
               }
               entry $This.frame3e.ent2 \
                 -width 30 -textvariable robobs(conf_planif,asteroid_light_curve,object_coord3)
               pack $This.frame3e.ent2 \
                -in $This.frame3e -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame3f -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame3f -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame3f.lab1 \
                    -text ""
               pack $This.frame3f.lab1 \
                   -in $This.frame3f -side left -padx 3 -pady 0
               $This.frame3f.lab1 configure -text "$caption(robobs_planif,asteroid_light_curve,exposure)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,asteroid_light_curve,exposure)]==0} {
                  set robobs(conf_planif,asteroid_light_curve,exposure) "60"
               }
               entry $This.frame3f.ent1 \
                 -width 5 -textvariable robobs(conf_planif,asteroid_light_curve,exposure)
               pack $This.frame3f.ent1 \
                -in $This.frame3f -side left -padx 3 -pady 0

               #--- Cree un label
               label $This.frame3f.lab2 \
                    -text ""
               pack $This.frame3f.lab2 \
                   -in $This.frame3f -side left -padx 3 -pady 0
               $This.frame3f.lab2 configure -text "$caption(robobs_planif,asteroid_light_curve,seconds)"

            #--- Cree un frame
            frame $This.frame3g -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame3g -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame3g.lab1 \
                    -text ""
               pack $This.frame3g.lab1 \
                   -in $This.frame3g -side left -padx 3 -pady 0
               $This.frame3g.lab1 configure -text "$caption(robobs_planif,asteroid_light_curve,binning)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,asteroid_light_curve,binning)]==0} {
                  set robobs(conf_planif,asteroid_light_curve,binning) "2"
               }
               entry $This.frame3g.ent1 \
                 -width 5 -textvariable robobs(conf_planif,asteroid_light_curve,binning)
               pack $This.frame3g.ent1 \
                -in $This.frame3g -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame3h -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame3h -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame3h.lab1 \
                    -text ""
               pack $This.frame3h.lab1 \
                   -in $This.frame3h -side left -padx 3 -pady 0
               $This.frame3h.lab1 configure -text "$caption(robobs_planif,asteroid_light_curve,nbimages)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,asteroid_light_curve,nbimages)]==0} {
                  set robobs(conf_planif,asteroid_light_curve,nbimages) "1"
               }
               entry $This.frame3h.ent1 \
                 -width 5 -textvariable robobs(conf_planif,asteroid_light_curve,nbimages)
               pack $This.frame3h.ent1 \
                -in $This.frame3h -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame3j -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame3j -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame3j.lab1 \
                    -text ""
               pack $This.frame3j.lab1 \
                   -in $This.frame3j -side left -padx 3 -pady 0
               $This.frame3j.lab1 configure -text "$caption(robobs_planif,asteroid_light_curve,filebias)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,asteroid_light_curve,filebias)]==0} {
                  set robobs(conf_planif,asteroid_light_curve,filebias) "[file join $audace(rep_images) bias.fit]"
               }
               entry $This.frame3j.ent1 \
                 -width 50 -textvariable robobs(conf_planif,asteroid_light_curve,filebias)
               pack $This.frame3j.ent1 \
                -in $This.frame3j -side left -padx 3 -pady 0

               #--- Cree un bouton
               button $This.frame3j.but1 \
                    -text "$caption(robobs_planif,asteroid_light_curve,change)" -command { global robobs ; set a [tk_getOpenFile] ; if {$a!=""} { set robobs(conf_planif,asteroid_light_curve,filebias) $a} }
               pack $This.frame3j.but1 \
                   -in $This.frame3j -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame3k -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame3k -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame3k.lab1 \
                    -text ""
               pack $This.frame3k.lab1 \
                   -in $This.frame3k -side left -padx 3 -pady 0
               $This.frame3k.lab1 configure -text "$caption(robobs_planif,asteroid_light_curve,filedark)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,asteroid_light_curve,filedark)]==0} {
                  set robobs(conf_planif,asteroid_light_curve,filedark) "[file join $audace(rep_images) dark.fit]"
               }
               entry $This.frame3k.ent1 \
                 -width 50 -textvariable robobs(conf_planif,asteroid_light_curve,filedark)
               pack $This.frame3k.ent1 \
                -in $This.frame3k -side left -padx 3 -pady 0

               #--- Cree un bouton
               button $This.frame3k.but1 \
                    -text "$caption(robobs_planif,asteroid_light_curve,change)" -command { global robobs ; set a [tk_getOpenFile] ; if {$a!=""} { set robobs(conf_planif,asteroid_light_curve,filedark) $a} }
               pack $This.frame3k.but1 \
                   -in $This.frame3k -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame3l -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame3l -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame3l.lab1 \
                    -text ""
               pack $This.frame3l.lab1 \
                   -in $This.frame3l -side left -padx 3 -pady 0
               $This.frame3l.lab1 configure -text "$caption(robobs_planif,asteroid_light_curve,fileflat)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,asteroid_light_curve,fileflat)]==0} {
                  set robobs(conf_planif,asteroid_light_curve,fileflat) "[file join $audace(rep_images) flat.fit]"
               }
               entry $This.frame3l.ent1 \
                 -width 50 -textvariable robobs(conf_planif,asteroid_light_curve,fileflat)
               pack $This.frame3l.ent1 \
                -in $This.frame3l -side left -padx 3 -pady 0

               #--- Cree un bouton
               button $This.frame3l.but1 \
                    -text "$caption(robobs_planif,asteroid_light_curve,change)" -command { global robobs ; set a [tk_getOpenFile] ; if {$a!=""} { set robobs(conf_planif,asteroid_light_curve,fileflat) $a} }
               pack $This.frame3l.but1 \
                   -in $This.frame3l -side left -padx 3 -pady 0
         }

         if {$robobs(planif,mode)=="star_light_curve"} {

            # --- charge la configuration
            ::robobs_config::load_config

            #--- Cree un frame
            frame $This.frame4c -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame4c -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame4c.lab1 \
                    -text ""
               pack $This.frame4c.lab1 \
                   -in $This.frame4c -side left -padx 3 -pady 0
               $This.frame4c.lab1 configure -text "$caption(robobs_planif,star_light_curve,object_name1)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,star_light_curve,object_name1)]==0} {
                  set robobs(conf_planif,star_light_curve,object_name1) "AAPsA"
               }
               entry $This.frame4c.ent1 \
                 -width 20 -textvariable robobs(conf_planif,star_light_curve,object_name1)
               pack $This.frame4c.ent1 \
                -in $This.frame4c -side left -padx 3 -pady 0

               #--- Cree un label
               label $This.frame4c.lab2 \
                    -text ""
               pack $This.frame4c.lab2 \
                   -in $This.frame4c -side left -padx 3 -pady 0
               $This.frame4c.lab2 configure -text "$caption(robobs_planif,star_light_curve,object_coord)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,star_light_curve,object_coord1)]==0} {
                  set robobs(conf_planif,star_light_curve,object_coord1) ""
               }
               entry $This.frame4c.ent2 \
                 -width 30 -textvariable robobs(conf_planif,star_light_curve,object_coord1)
               pack $This.frame4c.ent2 \
                -in $This.frame4c -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame4d -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame4d -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame4d.lab1 \
                    -text ""
               pack $This.frame4d.lab1 \
                   -in $This.frame4d -side left -padx 3 -pady 0
               $This.frame4d.lab1 configure -text "$caption(robobs_planif,star_light_curve,object_name2)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,star_light_curve,object_name2)]==0} {
                  set robobs(conf_planif,star_light_curve,object_name2) ""
               }
               entry $This.frame4d.ent1 \
                 -width 20 -textvariable robobs(conf_planif,star_light_curve,object_name2)
               pack $This.frame4d.ent1 \
                -in $This.frame4d -side left -padx 3 -pady 0

               #--- Cree un label
               label $This.frame4d.lab2 \
                    -text ""
               pack $This.frame4d.lab2 \
                   -in $This.frame4d -side left -padx 3 -pady 0
               $This.frame4d.lab2 configure -text "$caption(robobs_planif,star_light_curve,object_coord)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,star_light_curve,object_coord2)]==0} {
                  set robobs(conf_planif,star_light_curve,object_coord2) ""
               }
               entry $This.frame4d.ent2 \
                 -width 30 -textvariable robobs(conf_planif,star_light_curve,object_coord2)
               pack $This.frame4d.ent2 \
                -in $This.frame4d -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame4e -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame4e -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame4e.lab1 \
                    -text ""
               pack $This.frame4e.lab1 \
                   -in $This.frame4e -side left -padx 3 -pady 0
               $This.frame4e.lab1 configure -text "$caption(robobs_planif,star_light_curve,object_name3)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,star_light_curve,object_name3)]==0} {
                  set robobs(conf_planif,star_light_curve,object_name3) ""
               }
               entry $This.frame4e.ent1 \
                 -width 20 -textvariable robobs(conf_planif,star_light_curve,object_name3)
               pack $This.frame4e.ent1 \
                -in $This.frame4e -side left -padx 3 -pady 0

               #--- Cree un label
               label $This.frame4e.lab2 \
                    -text ""
               pack $This.frame4e.lab2 \
                   -in $This.frame4e -side left -padx 3 -pady 0
               $This.frame4e.lab2 configure -text "$caption(robobs_planif,star_light_curve,object_coord)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,star_light_curve,object_coord3)]==0} {
                  set robobs(conf_planif,star_light_curve,object_coord3) ""
               }
               entry $This.frame4e.ent2 \
                 -width 30 -textvariable robobs(conf_planif,star_light_curve,object_coord3)
               pack $This.frame4e.ent2 \
                -in $This.frame4e -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame4f -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame4f -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame4f.lab1 \
                    -text ""
               pack $This.frame4f.lab1 \
                   -in $This.frame4f -side left -padx 3 -pady 0
               $This.frame4f.lab1 configure -text "$caption(robobs_planif,star_light_curve,exposure)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,star_light_curve,exposure)]==0} {
                  set robobs(conf_planif,star_light_curve,exposure) "60"
               }
               entry $This.frame4f.ent1 \
                 -width 5 -textvariable robobs(conf_planif,star_light_curve,exposure)
               pack $This.frame4f.ent1 \
                -in $This.frame4f -side left -padx 3 -pady 0

               #--- Cree un label
               label $This.frame4f.lab2 \
                    -text ""
               pack $This.frame4f.lab2 \
                   -in $This.frame4f -side left -padx 3 -pady 0
               $This.frame4f.lab2 configure -text "$caption(robobs_planif,star_light_curve,seconds)"

            #--- Cree un frame
            frame $This.frame4g -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame4g -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame4g.lab1 \
                    -text ""
               pack $This.frame4g.lab1 \
                   -in $This.frame4g -side left -padx 3 -pady 0
               $This.frame4g.lab1 configure -text "$caption(robobs_planif,star_light_curve,binning)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,star_light_curve,binning)]==0} {
                  set robobs(conf_planif,star_light_curve,binning) "2"
               }
               entry $This.frame4g.ent1 \
                 -width 5 -textvariable robobs(conf_planif,star_light_curve,binning)
               pack $This.frame4g.ent1 \
                -in $This.frame4g -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame4h -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame4h -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame4h.lab1 \
                    -text ""
               pack $This.frame4h.lab1 \
                   -in $This.frame4h -side left -padx 3 -pady 0
               $This.frame4h.lab1 configure -text "$caption(robobs_planif,star_light_curve,nbimages)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,star_light_curve,nbimages)]==0} {
                  set robobs(conf_planif,star_light_curve,nbimages) "1"
               }
               entry $This.frame4h.ent1 \
                 -width 5 -textvariable robobs(conf_planif,star_light_curve,nbimages)
               pack $This.frame4h.ent1 \
                -in $This.frame4h -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame4j -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame4j -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame4j.lab1 \
                    -text ""
               pack $This.frame4j.lab1 \
                   -in $This.frame4j -side left -padx 3 -pady 0
               $This.frame4j.lab1 configure -text "$caption(robobs_planif,star_light_curve,filebias)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,star_light_curve,filebias)]==0} {
                  set robobs(conf_planif,star_light_curve,filebias) "[file join $audace(rep_images) bias.fit]"
               }
               entry $This.frame4j.ent1 \
                 -width 50 -textvariable robobs(conf_planif,star_light_curve,filebias)
               pack $This.frame4j.ent1 \
                -in $This.frame4j -side left -padx 3 -pady 0

               #--- Cree un bouton
               button $This.frame4j.but1 \
                    -text "$caption(robobs_planif,star_light_curve,change)" -command { global robobs ; set a [tk_getOpenFile] ; if {$a!=""} { set robobs(conf_planif,star_light_curve,filebias) $a} }
               pack $This.frame4j.but1 \
                   -in $This.frame4j -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame4k -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame4k -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame4k.lab1 \
                    -text ""
               pack $This.frame4k.lab1 \
                   -in $This.frame4k -side left -padx 3 -pady 0
               $This.frame4k.lab1 configure -text "$caption(robobs_planif,star_light_curve,filedark)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,star_light_curve,filedark)]==0} {
                  set robobs(conf_planif,star_light_curve,filedark) "[file join $audace(rep_images) dark.fit]"
               }
               entry $This.frame4k.ent1 \
                 -width 50 -textvariable robobs(conf_planif,star_light_curve,filedark)
               pack $This.frame4k.ent1 \
                -in $This.frame4k -side left -padx 3 -pady 0

               #--- Cree un bouton
               button $This.frame4k.but1 \
                    -text "$caption(robobs_planif,star_light_curve,change)" -command { global robobs ; set a [tk_getOpenFile] ; if {$a!=""} { set robobs(conf_planif,star_light_curve,filedark) $a} }
               pack $This.frame4k.but1 \
                   -in $This.frame4k -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame4l -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame4l -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame4l.lab1 \
                    -text ""
               pack $This.frame4l.lab1 \
                   -in $This.frame4l -side left -padx 3 -pady 0
               $This.frame4l.lab1 configure -text "$caption(robobs_planif,star_light_curve,fileflat)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,star_light_curve,fileflat)]==0} {
                  set robobs(conf_planif,star_light_curve,fileflat) "[file join $audace(rep_images) flat.fit]"
               }
               entry $This.frame4l.ent1 \
                 -width 50 -textvariable robobs(conf_planif,star_light_curve,fileflat)
               pack $This.frame4l.ent1 \
                -in $This.frame4l -side left -padx 3 -pady 0

               #--- Cree un bouton
               button $This.frame4l.but1 \
                    -text "$caption(robobs_planif,star_light_curve,change)" -command { global robobs ; set a [tk_getOpenFile] ; if {$a!=""} { set robobs(conf_planif,star_light_curve,fileflat) $a} }
               pack $This.frame4l.but1 \
                   -in $This.frame4l -side left -padx 3 -pady 0
            }

         if {$robobs(planif,mode)=="vachier_berthier"} {

            set robobs(conf_planif,$robobs(planif,mode),filebias) ""
            set robobs(conf_planif,$robobs(planif,mode),filedark) ""
            set robobs(conf_planif,$robobs(planif,mode),fileflat) ""
            set robobs(conf_planif,$robobs(planif,mode),filter) R
            # --- charge la configuration
            ::robobs_config::load_config

            #--- Cree un frame
            frame $This.frame5c -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame5c -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame5c.lab1 \
                    -text ""
               pack $This.frame5c.lab1 \
                   -in $This.frame5c -side left -padx 3 -pady 0
               $This.frame5c.lab1 configure -text "$caption(robobs_planif,vachier_berthier,input_file)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,vachier_berthier,input_file)]==0} {
                  set robobs(conf_planif,vachier_berthier,input_file) "c:/srv/www/htdocs/planif_fj/planif.eph"
               }
               entry $This.frame5c.ent1 \
                 -width 60 -textvariable robobs(conf_planif,vachier_berthier,input_file)
               pack $This.frame5c.ent1 \
                -in $This.frame5c -side left -padx 3 -pady 0
					 
            #--- Cree un frame
            frame $This.frame5d -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame5d -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame5d.lab1 \
                    -text ""
               pack $This.frame5d.lab1 \
                   -in $This.frame5d -side left -padx 3 -pady 0
               $This.frame5d.lab1 configure -text "$caption(robobs_planif,vachier_berthier,filter)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,vachier_berthier,filter)]==0} {
                  set robobs(conf_planif,vachier_berthier,filter) "R"
               }
               entry $This.frame5d.ent1 \
                 -width 50 -textvariable robobs(conf_planif,vachier_berthier,filter)
               pack $This.frame5d.ent1 \
                -in $This.frame5d -side left -padx 3 -pady 0
                
            #--- Cree un frame
            frame $This.frame5j -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame5j -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame5j.lab1 \
                    -text ""
               pack $This.frame5j.lab1 \
                   -in $This.frame5j -side left -padx 3 -pady 0
               $This.frame5j.lab1 configure -text "$caption(robobs_planif,vachier_berthier,sql_host)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,vachier_berthier,sql_host)]==0} {
                  set robobs(conf_planif,vachier_berthier,sql_host) "192.168.1.5"
               }
               entry $This.frame5j.ent1 \
                 -width 50 -textvariable robobs(conf_planif,vachier_berthier,sql_host)
               pack $This.frame5j.ent1 \
                -in $This.frame5j -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame5k -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame5k -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame5k.lab1 \
                    -text ""
               pack $This.frame5k.lab1 \
                   -in $This.frame5k -side left -padx 3 -pady 0
               $This.frame5k.lab1 configure -text "$caption(robobs_planif,vachier_berthier,sql_user)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,vachier_berthier,sql_user)]==0} {
                  set robobs(conf_planif,vachier_berthier,sql_user) "user"
               }
               entry $This.frame5k.ent1 \
                 -width 50 -textvariable robobs(conf_planif,vachier_berthier,sql_user)
               pack $This.frame5k.ent1 \
                -in $This.frame5k -side left -padx 3 -pady 0

            #--- Cree un frame
            frame $This.frame5l -borderwidth 0 -cursor arrow -relief groove
            pack $This.frame5l -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 1

               #--- Cree un label
               label $This.frame5l.lab1 \
                    -text ""
               pack $This.frame5l.lab1 \
                   -in $This.frame5l -side left -padx 3 -pady 0
               $This.frame5l.lab1 configure -text "$caption(robobs_planif,vachier_berthier,sql_pass)"

               #--- Cree l'entry
               if {[info exists robobs(conf_planif,vachier_berthier,sql_pass)]==0} {
                  set robobs(conf_planif,vachier_berthier,sql_pass) "****"
               }
               entry $This.frame5l.ent1 \
                 -width 50 -textvariable robobs(conf_planif,vachier_berthier,sql_pass)
               pack $This.frame5l.ent1 \
                -in $This.frame5l -side left -padx 3 -pady 0

         }

      }
      #--- Cree un frame pour les boutons de validation
      frame $This.frame3 -borderwidth 0 -cursor arrow -relief groove
      pack $This.frame3 -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un bouton
        button $This.frame3.but1 \
              -text "$caption(robobs_planif,but1)" -command {::robobs_planif::push_button 1 }
        pack $This.frame3.but1 \
             -in $This.frame3 -side left -padx 3 -pady 3

        #--- Cree un bouton
        button $This.frame3.but2 \
              -text "$caption(robobs_planif,but2)" -command {::robobs_planif::push_button 2 }
        pack $This.frame3.but2 \
             -in $This.frame3 -side left -padx 3 -pady 3

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      #::confColor::applyColor $This
      $This.frame1.titre configure -font $robobsconf(font,arial_12_b)

   }

   proc wizard { { mode "" } } {
      ::robobs_planif::fermer
      ::robobs_planif::createDialog $mode
   }

   # return either index, name or caption of a schedule mode, according whatever the input you enter.
   proc mode { input output } {
      global robobs
      global caption
      set outputs "index name caption"
      set index -1
      # --- test si input est un caption
      set totests $caption(robobs_planif,modes)
      set n [llength $totests]
      for {set k 0} {$k<$n} {incr k} {
         set totest [lindex $totests $k]
         if {$input==$totest} {
            set index $k
         }
      }
      # --- test si input est un mode
      set totests $robobs(planif,modes)
      set n [llength $totests]
      for {set k 0} {$k<$n} {incr k} {
         set totest [lindex $totests $k]
         if {$input==$totest} {
            set index $k
         }
      }
      # --- test si input est un index
      for {set k 0} {$k<$n} {incr k} {
         if {$input==$k} {
            set index $k
         }
      }
      # ---
      if {$index==-1} {
         return ""
      }
      if {$output=="index"} {
         return $index
      }
      if {$output=="mode"} {
         return [lindex $robobs(planif,modes) $index]
      }
      if {$output=="caption"} {
         return [lindex $caption(robobs_planif,modes) $index]
      }
      return ""
   }

   proc modif_choix { widget } {
      variable This
      global audace
      global caption
      global color
      global conf
      global robobsplanif
      global robobs
      global robobsconf

      #--- Je recupere l'index de l'element selectionne
      set index [ $widget getvalue ]
      if { "$index" == "" } {
         set index 0
      }
      set robobs(planif,mode) [::robobs_planif::mode $index mode]
      $This.frame2b.titre configure -text $caption(robobs_planif,infos,$robobs(planif,mode))
      ::robobs::log "Planif mode = $robobs(planif,mode)"
   }

   proc push_button {action {mode ""} } {
      variable This
      global robobs
      if {$action==1} {
         ::robobs_planif::fermer
      }
      if {$action==2} {
         ::robobs_planif::fermer
         if {($robobs(planif,mode)!="")&&($robobs(planif,window,mode)=="")} {
            ::robobs_planif::wizard $robobs(planif,mode)
         }
      }

   }

}