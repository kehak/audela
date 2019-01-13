## @file bdi_gui_reports_newaster.tcl
#  @brief     GUI pour le traitement des rapports lies a la decouverte d un asteroide
#  @author    Frederic Vachier
#  @version   1.0
#  @date      2018
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_reports_newaster.tcl]
#  @endcode

# $Id: bdi_gui_reports_newaster.tcl 13117 2016-05-21 02:00:00Z fredvachier $


   #------------------------------------------------------------
   ## lecture de l erreur dans la table pour etre triee
   # @param  err : Erreur lue en chaine de caractere
   # @return err : sous forme d un reel exprime en minute d arc
   #
   proc ::bdi_gui_reports::convert_error { err } {
   
      set motif  "^(.+?)\\\""
      set res [regexp -all -inline -- $motif $err]
      if { [llength $res] == 2} {
         return [ expr [lindex $res 1]/60.0 ]
      } else {
         set motif  "^(.+?)\\\'"
         set res [regexp -all -inline -- $motif $err]
         if { [llength $res] == 2} {
            return [ expr [lindex $res 1]]
         } else {
            set motif  "^(.+?)°"
            set res [regexp -all -inline -- $motif $err]
            if { [llength $res] == 2} {
               return [ expr [lindex $res 1]*60.0 ]
            } else {
               return -code 1 "not recognize error ($err)"
            }
         }
      }
   
   }



   #------------------------------------------------------------
   ## 
   #  @return void
   #
   proc ::bdi_gui_reports::compare_solu_age {item1 item2} {
       
       if {$item1 == "-"} {set item1 -1}
       if {$item2 == "-"} {set item2 -1}
       
       if {$item1 < $item2} { 
          return -1
       } else {
          return 1
       }

       
   }





   #------------------------------------------------------------
   ## 
   #  @return void
   #
   proc ::bdi_gui_reports::compare_err_now {item1 item2} {
       
       set err [ catch {set it1 [::bdi_gui_reports::convert_error $item1] } msg ]
       if {$err} {
          switch $msg {
             "not recognize error (-)" {
                set it1 1.e+99
             }
             default {
                gren_erreur "Err msg = $msg\n"
             }
          }
       }
       set err [ catch {set it2 [::bdi_gui_reports::convert_error $item2] } msg ]
       if {$err} {
          switch $msg {
             "not recognize error (-)" {
                set it2 1.e+99
             }
             default {
                gren_erreur "Err msg = $msg\n"
             }
          }
       }
       
       if {$it1 < $it2} { 
          return -1
       } else {
          return 1
       }

       
   }




   #------------------------------------------------------------
   ## 
   #  @return void
   #
   proc ::bdi_gui_reports::compare_oppo_in {item1 item2} {
       
       if {$item1 == "-"} {set item1 3000}
       if {$item2 == "-"} {set item2 3000}
       
       if {$item1 < $item2} { 
          return -1
       } else {
          return 1
       }
       
   }





   #------------------------------------------------------------
   ## 
   #  @return void
   #
   proc ::bdi_gui_reports::compare_err_oppo {item1 item2} {
       
       set err [ catch {set it1 [::bdi_gui_reports::convert_error $item1] } msg ]
       if {$err} {
          switch $msg {
             "not recognize error (-)" {
                set it1 1.e+99
             }
             default {
                gren_erreur "Err msg = $msg\n"
             }
          }
       }
       set err [ catch {set it2 [::bdi_gui_reports::convert_error $item2] } msg ]
       if {$err} {
          switch $msg {
             "not recognize error (-)" {
                set it2 1.e+99
             }
             default {
                gren_erreur "Err msg = $msg\n"
             }
          }
       }
       
       if {$it1 < $it2} { 
          return -1
       } else {
          return 1
       }

       
   }





   proc ::bdi_gui_reports::build_gui_newaster { frm } {

      set ::bdi_gui_reports::widget(frame,newaster) $frm

      set buttons [frame $frm.buttons ]
      pack $buttons -in $frm -side top -anchor nw

         button $buttons.charge -text "Charge" \
            -command "::bdi_tools_reports::charge_newaster"
         button $buttons.sol -text "Orbites" \
            -command "::bdi_gui_reports::fitobs_orbit_compute_all"
         button $buttons.err -text "Incertitudes" \
            -command "::bdi_gui_reports::fitobs_err_compute_all"
         #set ::bdi_gui_reports::widget(frame,newaster,fitobs,button) $buttons.fitobs
         grid $buttons.charge $buttons.sol $buttons.err -in $buttons -sticky w
            
            
      set frm_table_bodies [frame $frm.frm_table_bodies  -borderwidth 1 -relief groove]
      set ::bdi_gui_reports::widget(frame,newaster,table_bodies) $frm_table_bodies
      pack $frm_table_bodies -in $frm -expand yes -fill both

         set cols [list 0 "id"            right \
                        0 "Nom"           right \
                        0 "Date Decouv"   right \
                        0 "Arc (j)"       left  \
                        0 "Status Solu"   right \
                        0 "Date Solu"     right \
                        0 "Solu age (j)"  right \
                        0 "Err now"       left  \
                        0 "ren"           left  \
                        0 "To Obs"        left  \
                        0 "rto"           left  \
                        0 "Oppo in"       left  \
                        0 "Err Oppo"      left  \
                        0 "reo"           left  \
                        0 "MPC"           left  \
                        0 "Action"        left  \
                  ]

         # Table
         set ::bdi_tools_reports::data_newaster_bodies $frm_table_bodies.table
         tablelist::tablelist $::bdi_tools_reports::data_newaster_bodies \
           -columns $cols \
           -labelcommand tablelist::sortByColumn \
           -xscrollcommand [ list $frm_table_bodies.hsb set ] \
           -yscrollcommand [ list $frm_table_bodies.vsb set ] \
           -selectmode extended \
           -activestyle none \
           -stripebackground "#e0e8f0" \
           -showseparators 1

         # Scrollbar
         scrollbar $frm_table_bodies.hsb -orient horizontal -command [list $::bdi_tools_reports::data_newaster_bodies xview]
         pack $frm_table_bodies.hsb -in $frm_table_bodies -side bottom -fill x
         scrollbar $frm_table_bodies.vsb -orient vertical -command [list $::bdi_tools_reports::data_newaster_bodies yview]
         pack $frm_table_bodies.vsb -in $frm_table_bodies -side right -fill y

         # Popup
         menu $frm_table_bodies.popupTbl -title "Actions"

            $frm_table_bodies.popupTbl add command -label "Regenere l'Orbite" \
                -command "::bdi_gui_reports::fitobs_regen"

            $frm_table_bodies.popupTbl add command -label "Incertitude" \
                -command "::bdi_gui_reports::fitobs_uncertainty"

            $frm_table_bodies.popupTbl add separator

            $frm_table_bodies.popupTbl add command -label "Planifier avec Orbfit" \
                -command "::bdi_gui_reports::newaster_bodies_planification_fitobs"

            $frm_table_bodies.popupTbl add command -label "Planifier avec New Object Ephemeris Generator" \
                -command "::bdi_gui_reports::newaster_bodies_planification_MPC_NOEG"

            $frm_table_bodies.popupTbl add command -label "Supprimer objet" \
                -command "" -state disabled

         # Pack la Table
         pack $::bdi_tools_reports::data_newaster_bodies -in $frm_table_bodies -expand yes -fill both

         # Binding
         bind $::bdi_tools_reports::data_newaster_bodies <<ListboxSelect>> [ list ::bdi_gui_reports::cmdButton1Click_data_newaster_bodies %W ]
         bind [$::bdi_tools_reports::data_newaster_bodies bodypath] <ButtonPress-3> [ list tk_popup $frm_table_bodies.popupTbl %X %Y ]

         # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
         #    Ascii
         foreach ncol [list "Nom" "Date Decouv" "Status Solu" "Date Solu" "To Obs" "MPC" "Action"] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_tools_reports::data_newaster_bodies columnconfigure $pcol -sortmode ascii
         }
         #    Integer
         foreach ncol [list "Arc (j)" ] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_tools_reports::data_newaster_bodies columnconfigure $pcol -sortmode int
         }
         #    Hide
         foreach ncol [list "id" "ren" "rto" "reo"] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_tools_reports::data_newaster_bodies columnconfigure $pcol -hide yes
         }
         #    Spec
         foreach ncol [list "Solu age (j)"] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_tools_reports::data_newaster_bodies columnconfigure $pcol -sortmode command -sortcommand ::bdi_gui_reports::compare_solu_age
         }

         #    Spec
         foreach ncol [list "Err now"] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_tools_reports::data_newaster_bodies columnconfigure $pcol -sortmode command -sortcommand ::bdi_gui_reports::compare_err_now
         }

         #    Spec
         foreach ncol [list "Oppo in"] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_tools_reports::data_newaster_bodies columnconfigure $pcol -sortmode command -sortcommand ::bdi_gui_reports::compare_oppo_in
         }

         #    Spec
         foreach ncol [list "Err Oppo"] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_tools_reports::data_newaster_bodies columnconfigure $pcol -sortmode command -sortcommand ::bdi_gui_reports::compare_err_oppo
         }



      set onglets [frame $frm.onglets -borderwidth 1]
      pack $onglets -in $frm -anchor n  -side top -expand yes -fill both -padx 10 -pady 10
      #grid $onglets -in $frm -sticky news

         pack [ttk::notebook $onglets.nb ]  -side top -expand yes -fill both 
         #grid [ttk::notebook $onglets.nb ]  -row 0 -column 0

         set f_des   [frame $onglets.nb.f_des]
         set f_obs   [frame $onglets.nb.f_obs]
         set f_orb   [frame $onglets.nb.f_orb]

         $onglets.nb add $f_des   -text "Designations" -underline 0
         $onglets.nb add $f_obs   -text "Observations" -underline 0
         $onglets.nb add $f_orb   -text "Orbit"        -underline 0

         #$onglets.nb select $f_des
         $onglets.nb select $f_obs
         ttk::notebook::enableTraversal $onglets.nb


         set frmnb [frame $f_des.frm -borderwidth 4 -cursor arrow -relief sunken -background white ]
         pack $frmnb -in $f_des -side top -expand yes -fill both -padx 10 -pady 10

            ::bdi_gui_reports::build_gui_newaster_designations $frmnb

         set frmnb [frame $f_obs.frm -borderwidth 4 -cursor arrow -relief sunken -background white ]
         pack $frmnb -in $f_obs -side top -expand yes -fill both -padx 10 -pady 10

            ::bdi_gui_reports::build_gui_newaster_observations $frmnb

         set frmnb [frame $f_orb.frm -borderwidth 4 -cursor arrow -relief sunken -background white ]
         pack $frmnb -in $f_orb -side top -expand yes -fill both -padx 10 -pady 10

            ::bdi_gui_reports::build_gui_newaster_orbit $frmnb



         
      return
   }     


   proc ::bdi_gui_reports::build_gui_newaster_designations { frm } {

      set frm_table [frame $frm.frm_table  -borderwidth 1 -relief groove]
      pack $frm_table -in $frm -expand yes -fill both

         set cols [list 0 "id_obj"       left  \
                        0 "Designation"  left \
                        0 "Usuelle"      center \
                        0 "MPC"          center \
                  ]

         # Table
         set ::bdi_tools_reports::data_newaster_des $frm_table.table
         tablelist::tablelist $::bdi_tools_reports::data_newaster_des \
           -columns $cols \
           -labelcommand tablelist::sortByColumn \
           -xscrollcommand [ list $frm_table.hsb set ] \
           -yscrollcommand [ list $frm_table.vsb set ] \
           -selectmode extended \
           -activestyle none \
           -stripebackground "#e0e8f0" \
           -showseparators 1

         # Scrollbar
         scrollbar $frm_table.hsb -orient horizontal -command [list $::bdi_tools_reports::data_newaster_des xview]
         pack $frm_table.hsb -in $frm_table -side bottom -fill x
         scrollbar $frm_table.vsb -orient vertical -command [list $::bdi_tools_reports::data_newaster_des yview]
         pack $frm_table.vsb -in $frm_table -side right -fill y

         # Popup
         menu $frm_table.popupTbl -title "Actions"

            $frm_table.popupTbl add command -label "Ajouter une designation" \
                -command "::bdi_gui_reports::newaster_designations_add" 

            $frm_table.popupTbl add command -label "Convertir une designation MPC" \
                -command "::bdi_gui_reports::newaster_designations_convert" 

            $frm_table.popupTbl add command -label "Selectionner pour designation usuelle" \
                -command "::bdi_gui_reports::newaster_designations_usuelle" 

            $frm_table.popupTbl add command -label "Selectionner pour rapport MPC" \
                -command "::bdi_gui_reports::newaster_designations_MPC" 

            $frm_table.popupTbl add command -label "Supprimer designation" \
                -command "::bdi_gui_reports::newaster_designations_delete" 

         # Pack la Table
         pack $::bdi_tools_reports::data_newaster_des -in $frm_table -expand yes -fill both

         # Binding
         bind [$::bdi_tools_reports::data_newaster_des bodypath] <ButtonPress-3> [ list tk_popup $frm_table.popupTbl %X %Y ]

         # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
         #    Ascii
         foreach ncol [list "Designation" "Usuelle" "MPC"] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_tools_reports::data_newaster_des columnconfigure $pcol -sortmode ascii
         }
         #    Hide
#         foreach ncol [list "id_obj"] {
#            set pcol [expr int ([lsearch $cols $ncol]/3)]
#            $::bdi_tools_reports::data_newaster_bodies columnconfigure $pcol -hide yes
#         }

      return
   }     

   proc ::bdi_gui_reports::newaster_designations_add_apply {  } {

      set id_obj $::bdi_gui_reports::newaster_designations_add_id_obj 
      set newdes [string trim $::bdi_gui_reports::newaster_designations_add_newdes]
      gren_info "APPLY id_obj  = $id_obj\n"
      gren_info "New des = $newdes\n"
      
      if {$newdes == ""} {*
         tk_messageBox -message "Designation invalide" -type ok
         return
      }
      
      array set gfo $::bdi_tools_reports::tab_newaster($id_obj,gfo)
      gren_info "gfo = $::bdi_tools_reports::tab_newaster($id_obj,gfo)\n"
      
      # Verification de l existante
      for {set i 1} {$i <= $gfo(designation,nb)} {incr i} {
         if {$gfo(designation,$i,name) == $newdes} {
            tk_messageBox -message "Designation existante" -type ok
            return
         } 
      }


      incr gfo(designation,nb)
      set gfo(designation,$gfo(designation,nb),name) $newdes
      set gfo(designation,$gfo(designation,nb),fdes) 0
      set gfo(designation,$gfo(designation,nb),fmpc) 0
      set ::bdi_tools_reports::tab_newaster($id_obj,gfo) [array get gfo]
      ::bdi_gui_reports::create_gfo $id_obj

      # Update GUI
      ::bdi_gui_reports::newaster_update_tables_from_id_obj $id_obj
      
      # on tue la fenetre
      destroy .designation
      return
   }     
   
   
   proc ::bdi_gui_reports::newaster_designations_add {  } {
      
      set curselection [$::bdi_tools_reports::data_newaster_des curselection]
      set nb [llength $curselection]
      if {$nb != 1 } {return}
      set id_obj [lindex [$::bdi_tools_reports::data_newaster_des get [lindex $curselection 0] ] 0]
      gren_info "id_obj = $id_obj \n"

      set ::bdi_gui_reports::newaster_designations_add_id_obj $id_obj

      set ::bdi_gui_reports::newaster_designations_add_newdes ""
      catch {destroy .designation}
      toplevel .designation
      wm title .designation "New designation"
      wm positionfrom .designation user
      wm sizefrom .designation user
      frame .designation.f -relief groove
      pack configure .designation.f -side top -fill both -expand 1 -padx 10 -pady 10

      # Frame qui va contenir le label "Type your password:" et une entrÃ©e pour le rentrer
      frame .designation.f.lab
      pack configure .designation.f.lab -side top -fill x

        label .designation.f.lab.e -text "New designation for $id_obj"
        pack configure .designation.f.lab.e -side left -anchor c

      frame .designation.f.val
      pack configure .designation.f.val -side top -fill x

        entry .designation.f.val.v -textvariable ::bdi_gui_reports::newaster_designations_add_newdes
        pack configure .designation.f.val.v -side bottom -anchor c

      # Frame qui va contenir les boutons Cancel et Ok
      frame .designation.f.buttons
      pack configure .designation.f.buttons -side top -fill x

        button .designation.f.buttons.cancel -text Cancel -command { destroy .designation}
        pack configure .designation.f.buttons.cancel -side left

        button .designation.f.buttons.ok -text Ok -command { ::bdi_gui_reports::newaster_designations_add_apply}
        pack configure .designation.f.buttons.ok -side right

      bind .designation.f.val.v <Key-Return> { destroy .designation }

      return
   }     



   proc ::bdi_gui_reports::newaster_designations_convert {  } {


      set curselection [$::bdi_tools_reports::data_newaster_des curselection]
      set nb [llength $curselection]
      if {$nb != 1 } {return}
      set x [$::bdi_tools_reports::data_newaster_des get [lindex $curselection 0] ]
      set id_obj [lindex $x 0]
      set des    [lindex $x 1]
      gren_info "id_obj = $id_obj\n"
      gren_info "des    = $des \n"
      
      if { [regexp {(.*)_(.*)} $des a b c] } {
         #gren_info "$a => $f $c \n"
         set b [string trim $b]
         set c [string trim $c]
         gren_info "designation  => ($b) ($c)\n"
         set des "$b $c" 
      } else {
         set msg "unrecognize $txt"
         gren_erreur "unrecognize $msg\n"
         return -code 1 $msg
      }
      
      set object  [::bdi_tools_mpc::get_packed_designation $des]
      gren_info "packed_designation = $object \n"
      
      set ::bdi_gui_reports::newaster_designations_add_id_obj $id_obj
      set ::bdi_gui_reports::newaster_designations_add_newdes $object
      ::bdi_gui_reports::newaster_designations_add_apply
      
      return
   }     




   proc ::bdi_gui_reports::newaster_designations_MPC {  } {

      set curselection [$::bdi_tools_reports::data_newaster_des curselection]
      set nb [llength $curselection]
      if {$nb != 1 } {return}
      set x [$::bdi_tools_reports::data_newaster_des get [lindex $curselection 0] ]
      set id_obj [lindex $x 0]
      set des    [lindex $x 1]
      gren_info "id_obj = $id_obj \n"
      gren_info "des    = $des \n"
      
      array set gfo $::bdi_tools_reports::tab_newaster($id_obj,gfo)

      for {set i 1} {$i <= $gfo(designation,nb)} {incr i} {
         if {$gfo(designation,$i,name) == $des} {
            set gfo(designation,$i,fmpc) 1
         } else {
            set gfo(designation,$i,fmpc) 0
         } 
      }
      set ::bdi_tools_reports::tab_newaster($id_obj,gfo) [array get gfo]
      ::bdi_gui_reports::create_gfo $id_obj
      
      # Update GUI
      ::bdi_gui_reports::newaster_update_tables_from_id_obj $id_obj
      
      return
   }     


   proc ::bdi_gui_reports::newaster_update_tables_from_id_obj { id_obj } {

      ::bdi_tools_reports::affiche_newaster
      
      # On retrouve la ligne dans la table des objets
      set all [$::bdi_tools_reports::data_newaster_bodies get 0 end]
      set id -1
      foreach select $all {
         incr id
         lassign $select id_obj_list 
         if {$id_obj_list == $id_obj} {
            break
         }
      }

      # On selectionne l objet
      $::bdi_tools_reports::data_newaster_bodies selection set $id

      # On clic dessus
      ::bdi_gui_reports::cmdButton1Click_data_newaster_bodies $::bdi_gui_reports::widget(frame,newaster,table_bodies)

      return
   }     


   proc ::bdi_gui_reports::newaster_designations_usuelle {  } {

      set curselection [$::bdi_tools_reports::data_newaster_des curselection]
      set nb [llength $curselection]
      if {$nb != 1 } {return}
      set x [$::bdi_tools_reports::data_newaster_des get [lindex $curselection 0] ]
      set id_obj [lindex $x 0]
      set des    [lindex $x 1]
      gren_info "id_obj = $id_obj \n"
      gren_info "des    = $des \n"
      
      array set gfo $::bdi_tools_reports::tab_newaster($id_obj,gfo)

      for {set i 1} {$i <= $gfo(designation,nb)} {incr i} {
         if {$gfo(designation,$i,name) == $des} {
            set gfo(designation,$i,fdes) 1
            set gfo(designation,current) $gfo(designation,$i,name)
         } else {
            set gfo(designation,$i,fdes) 0
         } 
      }
      set ::bdi_tools_reports::tab_newaster($id_obj,gfo) [array get gfo]
      ::bdi_gui_reports::create_gfo $id_obj

      # Update GUI
      ::bdi_gui_reports::newaster_update_tables_from_id_obj $id_obj
      
      return
   }     






   proc ::bdi_gui_reports::newaster_designations_delete {  } {

      set curselection [$::bdi_tools_reports::data_newaster_des curselection]
      set nb [llength $curselection]
      if {$nb != 1 } {return}

      set x [$::bdi_tools_reports::data_newaster_des get [lindex $curselection 0] ]
      set id_obj [lindex $x 0]
      set des    [lindex $x 1]
      gren_info "id_obj = $id_obj \n"
       
      set r [tk_messageBox -message "Voulez vous vraiment supprimer cette designation $des ?" -type yesno]

      if {$r == "yes"} {

         gren_info "suppression $id_obj ==> $des\n"
         array set gfo $::bdi_tools_reports::tab_newaster($id_obj,gfo)
         for {set i 1} {$i <= $gfo(designation,nb)} {incr i} {
            if {$gfo(designation,$i,name) == $des} {
               unset gfo(designation,$i,name)
               unset gfo(designation,$i,fdes)
               unset gfo(designation,$i,fmpc)
               break
            } 
         }
         incr gfo(designation,nb) -1
         set ::bdi_tools_reports::tab_newaster($id_obj,gfo) [array get gfo]
         ::bdi_gui_reports::create_gfo $id_obj

         # Update GUI
         ::bdi_gui_reports::newaster_update_tables_from_id_obj $id_obj

         # on tue la fenetre
         destroy .designation

      } else {

         # on tue la fenetre
         destroy .designation
      }
      
      return
   }     






   proc ::bdi_gui_reports::build_gui_newaster_observations { frm } {

      set frm_table_obs [frame $frm.frm_table_obs  -borderwidth 1 -relief groove]
      pack $frm_table_obs -in $frm -expand yes -fill both

         set cols [list \
                        0 "Object"              right \
                        0 "Batch"               left  \
                        0 "First date"          right \
                        0 "nb obs"              right \
                        0 "MPC"                 left  \
                        0 "Angle Obs"           left  \
                        0 "Vitesse Obs (\"/s)"  left  \
                        0 "Angle Calc"          left  \
                        0 "Vitesse Calc (\"/s)" left  \
                        0 "OmC (\")"                 left  \
                        0 "id_obj"              left  \
                        0 "id_info"             left  \
                  ]

         # Table
         set ::bdi_tools_reports::data_newaster_obs $frm_table_obs.table
         tablelist::tablelist $::bdi_tools_reports::data_newaster_obs \
           -columns $cols \
           -labelcommand tablelist::sortByColumn \
           -xscrollcommand [ list $frm_table_obs.hsb set ] \
           -yscrollcommand [ list $frm_table_obs.vsb set ] \
           -selectmode extended \
           -activestyle none \
           -stripebackground "#e0e8f0" \
           -showseparators 1

         # Scrollbar
         scrollbar $frm_table_obs.hsb -orient horizontal -command [list $::bdi_tools_reports::data_newaster_obs xview]
         pack $frm_table_obs.hsb -in $frm_table_obs -side bottom -fill x
         scrollbar $frm_table_obs.vsb -orient vertical -command [list $::bdi_tools_reports::data_newaster_obs yview]
         pack $frm_table_obs.vsb -in $frm_table_obs -side right -fill y

         # Popup
         menu $frm_table_obs.popupTbl -title "Actions"

            $frm_table_obs.popupTbl add command -label "Voir rapport MPC" \
                -command "::bdi_tools_reports::voir_rapport_mpc"

            $frm_table_obs.popupTbl add command -label "Flag MPC no" \
                -command "::bdi_gui_reports::newaster_observations_unflag_mpc"

            $frm_table_obs.popupTbl add command -label "Voir fichier MPC soumis" \
                -command "::bdi_gui_reports::newaster_observations_voir_mpc_soumis"

            $frm_table_obs.popupTbl add command -label "Voir mesure" \
                -command "" -state disabled

            $frm_table_obs.popupTbl add command -label "Supprimer rapport" \
                -command "::bdi_gui_reports::newaster_observations_delete" 


         # Pack la Table
         pack $::bdi_tools_reports::data_newaster_obs -in $frm_table_obs -expand yes -fill both

         # Binding
         bind $::bdi_tools_reports::data_newaster_obs <<ListboxSelect>> [ list ::bdi_gui_reports::cmdButton1Click_data_newaster_obs %W ]
         bind [$::bdi_tools_reports::data_newaster_obs bodypath] <ButtonPress-3> [ list tk_popup $frm_table_obs.popupTbl %X %Y ]

         # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
         #    Ascii
         foreach ncol [list "Object" "Batch" "First date" "MPC"] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_tools_reports::data_newaster_obs columnconfigure $pcol -sortmode ascii
         }
         #    Integer
         foreach ncol [list "nb obs" ] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_tools_reports::data_newaster_obs columnconfigure $pcol -sortmode int
         }
         #    real
         foreach ncol [list "Angle Obs" "Vitesse Obs (\"/s)" "Angle Calc" "Vitesse Calc (\"/s)" "OmC (\")" ] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_tools_reports::data_newaster_obs columnconfigure $pcol -sortmode real
         }
         #    Hide
         foreach ncol [list "id_obj" "id_info" ] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_tools_reports::data_newaster_obs columnconfigure $pcol -hide yes
         }

      return
   }     



   #----------------------------------------------------------------------------
   # 
   proc ::bdi_gui_reports::newaster_observations_unflag_mpc { } {

      set curselection [$::bdi_tools_reports::data_newaster_obs curselection]
      set nb [llength $curselection]
      if {$nb != 1 } {
         tk_messageBox -message "Selectionner un seul rapport" -type ok
         return
      }
      
      # Verification
      set msg ""
      append msg "Les action suivantes vont etre realisees :\n"
      append msg "- Effacement des fichiers MPC uniquement\n"
      append msg "- Flag submit MPC => no\n"
      append msg "- Mise a jour de la table\n"
      append msg "\n"
      append msg "En etes vous sur ?"
      set res [tk_messageBox -message $msg -type yesno]      
      if {$res != "yes"} {return}

      # lecture de la table
      set x [$::bdi_tools_reports::data_newaster_obs get [lindex $curselection 0] ]
      lassign $x object batch firstdate nb_obs submit_mpc angle_obs vitesse_obs angle_calc vitesse_calc omc id_obj id_info
      
      if {$submit_mpc!="yes"} {
         tk_messageBox -message "Le rapport n a pas  ete soumis, il est deja flague NO" -type ok
         return
      }
      
      set file_mpc $::bdi_tools_reports::tab_newaster($id_obj,$id_info,mpc)         
      
      if {![file exists $file_mpc]} {
         tk_messageBox -message "Le fichier n existe pas :\n$file_mpc" -type ok
         return
      }

      # Effacement du rapport MPC
      file delete -force -- $file_mpc
      
      # Update Data
      set file_info $::bdi_tools_reports::tab_newaster($id_obj,$id_info,info)         
      ::bdi_tools_reports::read_info $file_info info
      set info(submit_mpc) "no"
      ::bdi_tools_reports::create_info $file_info info
      set ::bdi_tools_reports::tab_newaster($id_obj,$id_info,submit_mpc) $info(submit_mpc)

      # recharge API
      ::bdi_gui_reports::newaster_update_tables_from_id_obj $id_obj
      
      return
   }     






   #----------------------------------------------------------------------------
   # 
   proc ::bdi_gui_reports::newaster_observations_voir_mpc_soumis { } {

      set curselection [$::bdi_tools_reports::data_newaster_obs curselection]
      set nb [llength $curselection]
      if {$nb != 1 } {
         tk_messageBox -message "Selectionner un seul rapport" -type ok
         return
      }
      
      # lecture de la table
      set x [$::bdi_tools_reports::data_newaster_obs get [lindex $curselection 0] ]
      lassign $x object batch firstdate nb_obs submit_mpc angle_obs vitesse_obs angle_calc vitesse_calc omc id_obj id_info

      if {$submit_mpc!="yes"} {
         tk_messageBox -message "Le rapport n a pas  ete soumis" -type ok
         return
      }
      
      set file_mpc $::bdi_tools_reports::tab_newaster($id_obj,$id_info,mpc)         

      if {![file exists $file_mpc]} {
         tk_messageBox -message "Le fichier n existe pas :\n$file_mpc" -type ok
         return
      }
      
      # Creation GUI
      global bddconf

      set fen .voir_mpc_soumis

      if { [ winfo exists $fen ] } {
         destroy $fen
         ::bdi_gui_reports::newaster_observations_voir_mpc_soumis
         return
      }


      toplevel $fen -class Toplevel
      wm geometry $fen $bddconf(geometry_reports,newaster_voir_rapport_mpc)
      wm resizable $fen 1 1
      wm title $fen "Voir rapport MPC"
      wm protocol $fen WM_DELETE_WINDOW "destroy $fen"

      set frm $fen.appli
      frame $frm  -cursor arrow -relief groove
      pack $frm -in $fen -side top -expand yes -fill both 

         # button2
         set buttons [frame $frm.buttons2 ]
         pack $buttons -in $frm -side top -anchor w

            button $buttons.relance -text "Fermer" \
                                   -command "destroy $fen"

            grid $buttons.relance -in $buttons -sticky w


         set block [frame $frm.file  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $frm -side top -expand 0 -fill x -padx 2 -pady 5

               label  $block.lab -text "Fichier : " -borderwidth 1 -width 10
               pack   $block.lab -side left -padx 3 -pady 1 -anchor w

               entry  $block.val -relief sunken -width 100 -textvariable ::bdi_gui_reports::newaster_observations_voir_mpc_soumis_file
               pack   $block.val -side left -padx 3 -pady 1 -anchor w
 

 
         text $frm.mpc_obs -height 10 -width 80 \
              -xscrollcommand "$frm.mpc_obs.xscroll set" \
              -yscrollcommand "$frm.mpc_obs.yscroll set" \
              -wrap none
         pack $frm.mpc_obs -in $frm -expand yes -fill both -padx 5 -pady 5

         scrollbar $frm.mpc_obs.xscroll -orient horizontal -cursor arrow -command "$frm.mpc_obs xview"
         pack $frm.mpc_obs.xscroll -side bottom -fill x

         scrollbar $frm.mpc_obs.yscroll -orient vertical -cursor arrow -command "$frm.mpc_obs yview"
         pack $frm.mpc_obs.yscroll -side right -fill y
 
      # Lecture des donnees et Affichage
      set ::bdi_gui_reports::newaster_observations_voir_mpc_soumis_file $file_mpc
      $frm.mpc_obs delete 0.0 end
      set f [open $file_mpc "r"]
      set data [read $f]
      close $f
      $frm.mpc_obs insert end $data
      gren_info "$data\n"

      


      return
   }     

   #----------------------------------------------------------------------------
   # 
   proc ::bdi_gui_reports::newaster_observations_delete { } {

      set curselection [$::bdi_tools_reports::data_newaster_obs curselection]
      set nb [llength $curselection]
      if {$nb != 1 } {
         tk_messageBox -message "Selectionner un seul rapport" -type ok
         return
      }
      
      # lecture de la table
      set x [$::bdi_tools_reports::data_newaster_obs get [lindex $curselection 0] ]
      lassign $x object batch firstdate nb_obs submit_mpc angle_obs vitesse_obs angle_calc vitesse_calc omc id_obj id_info
      
      set file_mpc  $::bdi_tools_reports::tab_newaster($id_obj,$id_info,mpc)         
      set file_info $::bdi_tools_reports::tab_newaster($id_obj,$id_info,info)         
      set file_csv  $::bdi_tools_reports::tab_newaster($id_obj,$id_info,csv)         

      gren_info "Effacement : \n"
      gren_info "id_obj    = $id_obj\n"
      gren_info "id_info   = $id_info\n"
      gren_info "file_mpc  = $file_mpc\n"
      gren_info "file_info = $file_info\n"
      gren_info "file_csv  = $file_csv\n"

      file delete -force -- $file_mpc
      file delete -force -- $file_info
      file delete -force -- $file_csv
      
      # Effacement de la variable
      set nl ""
      foreach id_i $::bdi_tools_reports::tab_newaster($id_obj,index_info) {
         if { $id_i != $id_info} {
            lappend nl $id_i
         }
      }
      set ::bdi_tools_reports::tab_newaster($id_obj,index_info) $nl

      # recharge API
      ::bdi_gui_reports::newaster_update_tables_from_id_obj $id_obj

      return
   }     




   proc ::bdi_gui_reports::build_gui_newaster_orbit { frm } {

      set frm_table [frame $frm.frm_table  -borderwidth 1 -relief groove]
      pack $frm_table -in $frm -expand yes -fill both

         frame $frm_table.orb
         pack configure $frm_table.orb -side top -fill x

           set ::bdi_gui_reports::build_gui_newaster_orbit_entry $frm_table.orb.val
           text $::bdi_gui_reports::build_gui_newaster_orbit_entry -height 5 -width 80
#                -xscrollcommand "${::bdi_gui_reports::build_gui_newaster_orbit_entry}.xscroll set" \
#                -yscrollcommand "${::bdi_gui_reports::build_gui_newaster_orbit_entry}.yscroll set" \
#                -wrap none
           pack $::bdi_gui_reports::build_gui_newaster_orbit_entry -in $frm_table.orb -expand yes -fill both -padx 5 -pady 5

         frame $frm_table.buttons
         pack configure $frm_table.buttons -side top -fill x

            button $frm_table.buttons.calcul -text "Calcul" -command "::bdi_gui_reports::build_gui_newaster_orbit_entry_calcul"
            pack configure $frm_table.buttons.calcul -side left


      return
   }     






   proc ::bdi_gui_reports::build_gui_newaster_orbit_entry_calcul {  } {
      set data [split [$::bdi_gui_reports::build_gui_newaster_orbit_entry get 0.0 end] "\n" ]
      gren_info "data = $data\n"
      # angle vitesse_ciel omc
      
      set ra_a ""
      foreach line $data {
         set line [string trim $line]
         set tab [split $line "," ]
         if {[lindex $tab 0] == "linear"} {
            set param [lindex $tab 8]
            lassign [lindex $param 0] ra_a ra_b dec_a dec_b
            gren_info "a b c d = $ra_a $ra_b $dec_a $dec_b\n"
            
            break
         }
      }
      
      if {$ra_a == ""} {
         return
      }
      
      set newlist ""
      set sel [$::bdi_tools_reports::data_newaster_obs get 0 end]
      gren_info "sel = $sel\n"
      set pi [expr 2*asin(1.0)]
      
      foreach tline $sel {

         lassign $tline object batch firstdate nb_obs submit_mpc angle_obs vitesse_obs angle_calc vitesse_calc omc id_obj id_info
         set file_csv  $::bdi_tools_reports::tab_newaster($id_obj,$id_info,csv)
         gren_info "$id_obj $id_info $file_csv\n"
         ::bdi_tools_reports::read_mesure_csv $file_csv mesure

         set tomc     ""
         set tvitobs  ""
         set tvitcalc ""
         set tangobs  ""
         set tangcalc ""
         set cpt 0
         
         foreach jd $mesure(index_jd) {
            
            incr cpt
            set ra     $mesure($jd,ra)
            set dec    $mesure($jd,dec)
            set mag    $mesure($jd,mag)
            
            set ra_calc  [ expr $ra_a + $ra_b * $jd ]
            set dec_calc [ expr $dec_a + $dec_b * $jd ]
            
            set ra_omc   [ expr $ra  - $ra_calc  ]
            set dec_omc  [ expr $dec - $dec_calc ]
            
            set dx [expr $ra_omc * cos($pi / 180.0 * $dec)]
            set dy $dec_omc
            
            set omc [expr sqrt(pow($dx,2) + pow ($dy,2))*3600.0] 
            lappend tomc $omc
            
            set vitobs  ""
            set vitcalc ""
            set angobs  ""
            set angcalc ""
            if {$cpt >1} {
               # Vitesse obs
               set dra  [expr ($ra - $ra_sav) / ($jd - $jd_sav)]
               set ddec [expr ($dec - $dec_sav) / ($jd - $jd_sav)]
               set vitobs  [expr sqrt(pow($dra * cos($pi / 180.0 * $dec),2) + pow($ddec,2)) * 3600.0 / 86400.0]
               lappend tvitobs $vitobs
               
               # Angle obs
               set x [expr ($ra - $ra_sav) * cos($pi / 180.0 * $dec)]
               set y [expr ($dec - $dec_sav)]
               set angobs [ expr 2.0 * atan( $y / ($x + sqrt( pow($x,2) + pow($y,2) ) ) ) * 180.0 / $pi]
               lappend tangobs $angobs
               
               # Vitesse calc
               set dra  [expr ($ra_calc - $ra_calc_sav) / ($jd - $jd_sav)]
               set ddec [expr ($dec_calc - $dec_calc_sav) / ($jd - $jd_sav)]
               set vitcalc  [expr sqrt(pow($dra * cos($pi / 180.0 * $dec_calc),2) + pow($ddec,2)) * 3600.0 / 86400.0]
               lappend tvitcalc $vitcalc

               # Angle obs
               set x [expr ($ra_calc - $ra_calc_sav) * cos($pi / 180.0 * $dec_calc)]
               set y [expr ($dec_calc - $dec_calc_sav)]
               set angcalc [ expr 2.0 * atan( $y / ($x + sqrt( pow($x,2) + pow($y,2) ) ) ) * 180.0 / $pi]
               lappend tangcalc $angcalc
               
            }
            
            set jd_sav       $jd
            set ra_sav       $ra
            set dec_sav      $dec
            set ra_calc_sav  $ra_calc
            set dec_calc_sav $dec_calc
            
            gren_info "    $jd : $ra $dec $mag : $omc $vitobs $vitcalc $angobs $angcalc\n"
         }
         
         set omc     [format "%.1f" [::math::statistics::mean   $tomc     ]]
         set vitobs  [format "%.4f" [::math::statistics::median $tvitobs  ]]
         set vitcalc [format "%.4f" [::math::statistics::median $tvitcalc ]]
         set angobs  [format "%.1f" [::math::statistics::median $tangobs  ]]
         set angcalc [format "%.1f" [::math::statistics::median $tangcalc ]]
         gren_info "omc => $omc \" vitobs => $vitobs \"/s vitcalc => $vitcalc \"/s angobs => $angobs deg angcalc => $angcalc deg\n"
         
         set tline [lreplace $tline 5 9 $angobs $vitobs $angcalc $vitcalc $omc]
         lappend newlist $tline
      }
      
      $::bdi_tools_reports::data_newaster_obs delete 0 end
      foreach tline $newlist {
         $::bdi_tools_reports::data_newaster_obs insert end $tline
      }
      
      return
   }     



   #----------------------------------------------------------------------------
   # Lecture d un fichier mesure.*.csv
   proc ::bdi_tools_reports::read_mesure_csv { file p_tab } {
      upvar $p_tab tab

      array unset tab
      
      set f [open $file "r"]
      set data [read $f]
      close $f
      set cpt 0
      set r [split [string trim $data] "\n"]
      
      foreach line $r {
         if {[string range $line 0 0]=="#"} {continue} 
         if {[string trim $line ]==""} {continue} 
         incr cpt
         lassign [csv:parse $line] id dateiso_mp jd_mp ra dec mag filtre uaicode
         if {$jd_mp=="jd_mp"} {continue}
         
         if {$jd_mp=="jd"} {
            gren_erreur "Obsolete quand tous les rapports seront corriges.  Erreur dans : $file\n"
            continue
         }
         
         lappend tab(index_jd)   $jd_mp
         set tab($jd_mp,dateiso_mp) $dateiso_mp
         set tab($jd_mp,ra)         $ra
         set tab($jd_mp,dec)        $dec
         set tab($jd_mp,mag)        $mag
         set tab($jd_mp,filtre)     $filtre
         set tab($jd_mp,uaicode)    $uaicode
      }
      set tab(index_jd) [lsort -increasing $tab(index_jd)]

      return
   }


#    ::console::clear ; ::bddimages::ressource ; ::bdi_tools_reports::read_gfo_explode_designation "{ 0 0 } M2018A1"

   proc ::bdi_tools_reports::read_gfo_explode_designation { txt } {

      if { [regexp {.*\{(.*)\}(.*)} $txt a f c] } {
         #gren_info "$a => $f $c \n"
         set f [string trim $f]
         set c [string trim $c]
         lassign [split $f " "] fdes fmpc
         #gren_info "designation  => $c ($fdes) ($fmpc)\n"
         return [list $c $fdes $fmpc]
      } else {
         set msg "unrecognize $txt"
         gren_erreur "unrecognize $msg\n"
         return -code 1 $msg
      }
   }





   proc ::bdi_tools_reports::read_gfo { root_file_gfo p_gfo} {
      
      upvar $p_gfo gfo
      
      set file_gfo [file tail $root_file_gfo ]
      
      # Verification des fichiers
      set ext      [file extension $root_file_gfo]
      set size     [file size $root_file_gfo]
      set rootname [file rootname $root_file_gfo]
      set dirname  [file dirname $root_file_gfo]
      #gren_info "info : $info\n"
      #gren_info "ext : $ext\n"
      #gren_info "size : $size\n"
      #gren_info "rootname : $rootname\n"
      #gren_info "dirname : $dirname\n"
      if {$size==0} {return -code 1 "le fichier $file_gfo est vide"}
      
      # Lecture du fichier info
      array unset gfo
      set gfo(designation,nb) 0
      set gfo(root_file_gfo) $root_file_gfo 
      set chan [open $root_file_gfo r]
      while {[gets $chan line] >= 0} {
         set line [string trim $line]
         if {$line == ""} {continue}
         if { [regexp {(.*):=(.*):=(.*)} $line u key val com] } {
            set key [string trim $key]
            set val [string trim $val]
            #gren_erreur "$key => $val => $com\n"
            if {$key != "" && $val != ""} {
               if {[string trim $key] == "designation"} {

                  set err [ catch { set l [::bdi_tools_reports::read_gfo_explode_designation $val]} msg ]
                  if {$err} {
                     gren_erreur "Erreur ($err) : $msg\n"
                     continue
                  }
                  incr gfo(designation,nb)
                  set gfo(designation,$gfo(designation,nb),name) [lindex $l 0]
                  set gfo(designation,$gfo(designation,nb),fdes) [lindex $l 1]
                  set gfo(designation,$gfo(designation,nb),fmpc) [lindex $l 2]
                  
               } else {
                  set gfo($key) $val
               }
            }
         } else {
            if { [regexp {(.*):=(.*)} $line u key val] } {
               set key [string trim $key]
               set val [string trim $val]
               if {$key == "designation"} {

                  set err [ catch { set l [::bdi_tools_reports::read_gfo_explode_designation $val]} msg ]
                  if {$err} {
                     #gren_erreur "Erreur ($err) : $msg\n"
                     continue
                  }
                  incr gfo(designation,nb)
                  set gfo(designation,$gfo(designation,nb),name) [lindex $l 0]
                  set gfo(designation,$gfo(designation,nb),fdes) [lindex $l 1]
                  set gfo(designation,$gfo(designation,nb),fmpc) [lindex $l 2]

               } else {
                  set gfo($key) $val
               }
            } else {
               gren_erreur "Err read_gfo $root_file_gfo\n"
               break
            }
         }
      }
      close $chan


      for {set i 1} {$i <= $gfo(designation,nb)} {incr i} {
         if {$gfo(designation,$i,fdes)==1} {
            set gfo(designation,current) $gfo(designation,$i,name)
         }
         if {$gfo(designation,$i,fmpc)==1} {
            set gfo(designation,mpc) $gfo(designation,$i,name)
         }
      }

      if {[info exists gfo(reo)]} {
         set gfo(err_oppo) [::bdi_tools_orbfit::convert_error_text $gfo(reo)]
      } else {
         set gfo(err_oppo) "-"     
      }


      return
   }
   

#    ::console::clear ; ::bddimages::ressource ; ::bdi_tools_reports::read_info "/bddimages/bdi_t60_les_makes/reports/NEWASTER/M2018A1/M2018A1.Audela_BDI_2018-07-30T18:43:57_GMT.info"
   proc ::bdi_tools_reports::create_info { file_info p_tab} {

      upvar $p_tab tab

      set handler [open $file_info "w"]

      set entete ""
      append entete [format "firstdate            := %-70s := Iso date of the day for the first date in the list\n" $tab(firstdate)  ]
      append entete [format "batch                := %-70s := batch code\n"                                         $tab(batch)      ]
      append entete [format "submit_mpc           := %-70s := Report submitted to MPC\n"                            $tab(submit_mpc) ]
      append entete [format "iau_code             := %-70s := IAU code for the observatory\n"                       $tab(iau_code)   ]
      append entete [format "subscriber           := %-70s := Subscriber \n"                                        $tab(subscriber) ]
      append entete [format "address              := %-70s := Address    \n"                                        $tab(address)    ]
      append entete [format "mail                 := %-70s := Email      \n"                                        $tab(mail)       ]
      append entete [format "software             := %-70s := Software   \n"                                        $::bdi_gui_planetes::software ]
      append entete [format "observers            := %-70s := Observers  \n"                                        $tab(observers)     ]
      append entete [format "reduction            := %-70s := Reduction  \n"                                        $tab(reduction)     ]
      append entete [format "instrument           := %-70s := Instrument \n"                                        $tab(instrument)    ]
      append entete [format "nb_dates             := %-70s := Nb of dates\n"                                        $tab(nb_dates)      ]
      append entete [format "ref_catalogue        := %-70s := Reference catalogue\n"                                $tab(ref_catalogue) ]
      append entete [format "band                 := %-70s := Filter designation\n"                                 $tab(band)          ]
      append entete [format "filter               := %-70s := Filter information\n"                                 $tab(filter)        ]

      puts $handler $entete
      close $handler

      return
   }



   proc ::bdi_tools_reports::read_info { file_info p_tab} {
      
      upvar $p_tab tab
      
      
      set log 1
      
      set info [file tail $file_info ]
      
      # Verification des fichiers
      set ext [file extension $file_info]
      set size [file size $file_info]
      set rootname [file rootname $file_info]
      set dirname [file dirname $file_info]
      #[file join]
      if {$log} {
         gren_info "info : $info\n"
         gren_info "ext : $ext\n"
         gren_info "size : $size\n"
         gren_info "rootname : $rootname\n"
         gren_info "dirname : $dirname\n"
      }
      if {$size==0} {return -code 1 "le fichier .info est vide"}
      
      if {$log} { gren_info "rootname $rootname\n"  }
      set csv "$rootname.csv"
      if {![file exists $csv]} {return -code 2 "le fichier $csv n existe pas"}
      if {![file size $csv]} {return -code 3 "le fichier $csv est vide"}

      set mpc "$rootname.mpc"
      
      # Lecture du fichier info
      if {$log} { gren_info "Lecture du fichier info\n"  }
      array unset tab
      set tab(csv)  $csv
      set tab(mpc)  $mpc 
      set tab(info) $file_info 
      set chan [open $file_info r]
      while {[gets $chan line] >= 0} {
         set line [string trim $line]
         if {$line == ""} {continue}
         if { [regexp {(.*):=(.*):=(.*)} $line u key val com] } {
            #gren_erreur "$key => $val => $com\n"
            if {$key != "" && $val != ""} {
               set tab([string trim $key]) [string trim $val]
            }
         } else {
            if { [regexp {(.*):=(.*)} $line u key val] } {
               if {$key != "" && $val != ""} {
                  set tab([string trim $key]) [string trim $val]
               }
            } else {
               gren_erreur "Err read_info $file_info\n"
               break
            }
         }
      }
      close $chan
      if {$log} { gren_info "read_info : fin\n"  }
      
      #foreach key [array names tab] {
      #   gren_info "tab($key)=$tab($key)\n"
      #}
      #gren_info "tab=[array names tab]\n"
      #gren_info "tab=[array get tab]\n"
      #gren_info "ok\n"
      return
   }
   
   
#    ::console::clear ; ::bddimages::ressource ; ::bdi_tools_reports::charge_newaster

   #----------------------------------------------------------------------------
   # Charge les donnees concernant les decouvertes d asteroides
   proc ::bdi_tools_reports::charge_newaster { } {
      
      ::bdi_tools_reports::charge_newaster_from_gfo
      
      
      return
   }








   #----------------------------------------------------------------------------
   # Charge les donnees concernant les decouvertes d asteroides
   proc ::bdi_tools_reports::charge_newaster_from_gfo { } {
      
      
      global bddconf
      
      gren_info "Chargement ...\n"
      
      array unset ::bdi_tools_reports::tab_newaster
      
      # Recupere la liste des objets
      set err [catch {set dirliste [glob -directory [file join $bddconf(dirreports) NEWASTER] *]} msg ]
      if {$err} {
         tk_messageBox -message $msg -type ok
         return
      }
      
      set ::bdi_tools_reports::tab_newaster(index_obj) ""
      
      foreach dir $dirliste {

         set id_obj [file tail $dir]
         gren_info "id_obj : $id_obj\n"

         lappend ::bdi_tools_reports::tab_newaster(index_obj) $id_obj
         set ::bdi_tools_reports::tab_newaster($id_obj,dir) $dir
         set ::bdi_tools_reports::tab_newaster($id_obj,err_now) "-"        
         set ::bdi_tools_reports::tab_newaster($id_obj,ren)     "-1"        
         set ::bdi_tools_reports::tab_newaster($id_obj,action)  ""

         # Recherche des fichiers nfo
         set err [catch {set list_file_info [glob -directory $dir $id_obj.*.info]} msg ]
         if {$err} {
            tk_messageBox -message $msg -type ok
            return
         }

         set ::bdi_tools_reports::tab_newaster($id_obj,index_info) ""
         set ::bdi_tools_reports::tab_newaster($id_obj,list_file_info) ""
         set listdate ""
         set ::bdi_tools_reports::tab_newaster($id_obj,submit_mpc) "no"

         gren_info "nb_file : [llength $list_file_info]\n"
         foreach file_info $list_file_info {

            set id_info [file tail $file_info]
            gren_info "read_info\n"
            ::bdi_tools_reports::read_info $file_info info
            gren_info "read_mesure_csv\n"
            ::bdi_tools_reports::read_mesure_csv $info(csv) mesure
            
            lappend ::bdi_tools_reports::tab_newaster($id_obj,list_file_info)         $file_info
            lappend ::bdi_tools_reports::tab_newaster($id_obj,index_info)             $id_info
            foreach key [array names info] {
               set ::bdi_tools_reports::tab_newaster($id_obj,$id_info,$key) $info($key)
            }
            
            append listdate " $mesure(index_jd)"
            
            if {$::bdi_tools_reports::tab_newaster($id_obj,submit_mpc)=="no" && $info(submit_mpc)=="yes"} {
               set ::bdi_tools_reports::tab_newaster($id_obj,submit_mpc) "yes"
            }
            
         }

         set listdate [lsort -increasing $listdate]
         set ::bdi_tools_reports::tab_newaster($id_obj,firstdate) [string range [mc_date2iso8601 [lindex $listdate 0]] 0 9]
         set ::bdi_tools_reports::tab_newaster($id_obj,discovery) [string trim  [mc_date2iso8601 [lindex $listdate 0] ] ]
         set ::bdi_tools_reports::tab_newaster($id_obj,arc) [expr int([lindex $listdate end] - [lindex $listdate 0])]


         #[expr int([mc_date2jd now]-  2400000.5 ) ]
         # Recherche des fichier eq0
         set ::bdi_tools_reports::tab_newaster($id_obj,solu_file) [file join $dir "$id_obj.eq0"]
         set date_solu "-"
         set solu_age "-"
         set status "Error"
         if {[file exists $::bdi_tools_reports::tab_newaster($id_obj,solu_file)]} {
            set crea_file [file atime $::bdi_tools_reports::tab_newaster($id_obj,solu_file)]
            set date_solu [clock format $crea_file -format "%Y-%m-%d"]
            set d1 [mc_date2jd [clock format $crea_file -format "%Y-%m-%dT%H:%M:%S"] ]
            set d2 [mc_date2jd [clock format [clock scan now] -format "%Y-%m-%dT%H:%M:%S"] ]
            set solu_age [expr int($d2 - $d1)]
            
            set status [::bdi_tools_orbfit::get_status $::bdi_tools_reports::tab_newaster($id_obj,solu_file)]
         }
         set ::bdi_tools_reports::tab_newaster($id_obj,date_solu) $date_solu
         set ::bdi_tools_reports::tab_newaster($id_obj,solu_age)  $solu_age
         set ::bdi_tools_reports::tab_newaster($id_obj,status)    $status

         # Recherche des fichier gfo
         set ::bdi_tools_reports::tab_newaster($id_obj,root_file_gfo) [file join $dir $id_obj.gfo]
         if {! [file exists $::bdi_tools_reports::tab_newaster($id_obj,root_file_gfo)]} {
            set ::bdi_tools_reports::tab_newaster($id_obj,action) "Regenerer orbite"
            continue
         }
         
         # Lecture du seul fichier .gfo
         gren_info "lecture du fichier $id_obj.gfo\n"
         set err [ catch {::bdi_tools_reports::read_gfo $::bdi_tools_reports::tab_newaster($id_obj,root_file_gfo) gfo} msg]
         if {$err} {
            set ::bdi_tools_reports::tab_newaster($id_obj,action) "Regler probleme : $msg"
            gren_erreur "Erreur : ($err) $msg\n"
            continue
         }
         
         set ::bdi_tools_reports::tab_newaster($id_obj,gfo) [array get gfo]
         
         if {1} {
            
            # Designation
            gren_info "NB designation :: $gfo(designation,nb)\n"
            for {set i 1} {$i <= $gfo(designation,nb)} {incr i} {
               gren_info "designation => $gfo(designation,$i,name) (fdes=$gfo(designation,$i,fdes)) (fmpc=$gfo(designation,$i,fmpc))\n"
            }

            # Other Data
            foreach key [array names gfo] {
               if {[string first "designation" $key]==-1} {
                  gren_info "gfo($key)=$gfo($key)\n"
               }
            }
            
         }
       
       
       
         
      }



      ::bdi_tools_reports::affiche_newaster

      return
   }








   #----------------------------------------------------------------------------
   # Charge les donnees concernant les decouvertes d asteroides
   proc ::bdi_tools_reports::charge_newaster_data_rebuild { } {
   
      global bddconf
      
      gren_info "Chargement ...\n"
      
      array unset ::bdi_tools_reports::tab_newaster
      
      # Recupere la liste des objets
      set err [catch {set dirliste [glob -directory [file join $bddconf(dirreports) NEWASTER] *]} msg ]
      if {$err} {
         tk_messageBox -message $msg -type ok
         return
      }
      
      set ::bdi_tools_reports::tab_newaster(index_obj) ""
      
      foreach dir $dirliste {

         set id_obj [file tail $dir]
         gren_info "id_obj : $id_obj\n"

         lappend ::bdi_tools_reports::tab_newaster(index_obj) $id_obj
         set ::bdi_tools_reports::tab_newaster($id_obj,dir) $dir

         set err [catch {set list_file_info [glob -directory $dir $id_obj.*.info]} msg ]
         if {$err} {
            tk_messageBox -message $msg -type ok
            return
         }
         
         set ::bdi_tools_reports::tab_newaster($id_obj,index_info) ""
         set ::bdi_tools_reports::tab_newaster($id_obj,list_file_info) ""
         set listdate ""
         
         set ::bdi_tools_reports::tab_newaster($id_obj,submit_mpc) "no"




         foreach file_info $list_file_info {

            set id_info [file tail $file_info]
            #gren_info "file info : $id_info\n"
            ::bdi_tools_reports::read_info $file_info info
            ::bdi_tools_reports::read_mesure_csv $info(csv) mesure
            
            #foreach key [array names mesure] {
            #   gren_info "tab($key)=$mesure($key)\n"
            #}
            # ::bdi_tools_reports::data_newaster_bodies
            # ::bdi_tools_reports::data_newaster_obs
            
            
            lappend ::bdi_tools_reports::tab_newaster($id_obj,list_file_info)         $file_info
            lappend ::bdi_tools_reports::tab_newaster($id_obj,index_info)             $id_info
            foreach key [array names info] {
               #gren_info "tab($key)=$info($key)\n"
               set ::bdi_tools_reports::tab_newaster($id_obj,$id_info,$key) $info($key)
            }
            
            append listdate " $mesure(index_jd)"
            
            if {$::bdi_tools_reports::tab_newaster($id_obj,submit_mpc)=="no" && $info(submit_mpc)=="yes"} {
               set ::bdi_tools_reports::tab_newaster($id_obj,submit_mpc) "yes"
            }
            
         }
         
         set listdate [lsort -increasing $listdate]
         set ::bdi_tools_reports::tab_newaster($id_obj,firstdate) [string range [mc_date2iso8601 [lindex $listdate 0]] 0 9]
         
         #   gren_info "t0 : [lindex $listdate end]\n"
         #   gren_info "t1 : [lindex $listdate 0]\n"
         
         set ::bdi_tools_reports::tab_newaster($id_obj,arc) [expr int([lindex $listdate end] - [lindex $listdate 0])]
         gren_info "submit_mpc = $::bdi_tools_reports::tab_newaster($id_obj,submit_mpc)\n"
         
      }

      ::bdi_tools_reports::affiche_newaster
      return
   }



   #----------------------------------------------------------------------------
   # Affiche les donnees concernant les objets
   proc ::bdi_tools_reports::affiche_newaster { } {
      
      $::bdi_tools_reports::data_newaster_bodies delete 0 end
      $::bdi_tools_reports::data_newaster_obs    delete 0 end
      
      set id 0
      foreach id_obj $::bdi_tools_reports::tab_newaster(index_obj) {

         set name       $id_obj
         set firstdate  $::bdi_tools_reports::tab_newaster($id_obj,firstdate)
         set arc        $::bdi_tools_reports::tab_newaster($id_obj,arc)
         set status     $::bdi_tools_reports::tab_newaster($id_obj,status)
         set date_solu  $::bdi_tools_reports::tab_newaster($id_obj,date_solu)
         set solu_age   $::bdi_tools_reports::tab_newaster($id_obj,solu_age)
         set err_now    $::bdi_tools_reports::tab_newaster($id_obj,err_now)
         set ren        $::bdi_tools_reports::tab_newaster($id_obj,ren)
         set to_obs     "-"
         set rto        -1
         set oppo       "-"
         set err_oppo   "-"
         set reo        -1
         set mpc        $::bdi_tools_reports::tab_newaster($id_obj,submit_mpc)
         set action     $::bdi_tools_reports::tab_newaster($id_obj,action)

         if {[info exists ::bdi_tools_reports::tab_newaster($id_obj,gfo)]} {
            #gren_info "$id_obj\n"
            array set gfo $::bdi_tools_reports::tab_newaster($id_obj,gfo)
            set name      $gfo(designation,current)
            set to_obs    $gfo(to_obs)
            set rto       $gfo(rto)
            set oppo      $gfo(oppo)
            set err_oppo  $gfo(err_oppo)
            set reo       $gfo(reo)

         }
         
         $::bdi_tools_reports::data_newaster_bodies insert end [list \
                                  $id_obj    \
                                  $name      \
                                  $firstdate \
                                  $arc       \
                                  $status    \
                                  $date_solu \
                                  $solu_age  \
                                  $err_now   \
                                  $ren       \
                                  $to_obs    \
                                  $rto       \
                                  $oppo      \
                                  $err_oppo  \
                                  $reo       \
                                  $mpc       \
                                  $action    \
                                  ]
         incr n

      }

      for {set id 0} {$id < $n} {incr id} {
         ::bdi_gui_reports::colorize $id
      }

      $::bdi_tools_reports::data_newaster_bodies sortbycolumn 2 -decreasing

      return
   }



   #------------------------------------------------------------
   ## Colori une ligne de la table suivant les criteres
   #  @param  id_obj designation de l objet
   #  @return void
   #
   proc ::bdi_gui_reports::colorize { id } {
      
      set line [$::bdi_tools_reports::data_newaster_bodies get $id $id]
      
      set rd [regexp -inline -all -- {\S+} $line]
      set tab [split $rd " "]
      lassign $tab id_obj name datedecouv arc status datesolu soluage err_now ren to_obs rto oppo err_oppo reo mpc
      
      # Arc
      if {$arc < 3} {
         $::bdi_tools_reports::data_newaster_bodies cellconfigure $id,3 -foreground red
      }
      #gren_info "\[$tab\] \n"

      # Status
      switch $status {
         "Success" {
            set color green
         }
         "Planif" {
            set color orange
         }
         "Error" {
            set color red
         }
         default {
            gren_info "Blue : $status"
            set color blue
         }
      }
      $::bdi_tools_reports::data_newaster_bodies cellconfigure $id,4 -foreground $color
       
      # err_now
      if { $ren < 1.} {
         $::bdi_tools_reports::data_newaster_bodies cellconfigure $id,7 -foreground green
      } elseif {$ren < 10.} {
         $::bdi_tools_reports::data_newaster_bodies cellconfigure $id,7 -foreground darkorange
      } else {
         $::bdi_tools_reports::data_newaster_bodies cellconfigure $id,7 -foreground red
      }
      
      # to_obs
      if { $rto < 7.} {
         $::bdi_tools_reports::data_newaster_bodies cellconfigure $id,9 -foreground red
      } elseif {$rto < 30.} {
         $::bdi_tools_reports::data_newaster_bodies cellconfigure $id,9 -foreground darkorange
      } else {
         $::bdi_tools_reports::data_newaster_bodies cellconfigure $id,9 -foreground black
      }

      # err_oppo
      if { $reo < 1.} {
         $::bdi_tools_reports::data_newaster_bodies cellconfigure $id,12 -foreground green
      } elseif {$reo < 10.} {
         $::bdi_tools_reports::data_newaster_bodies cellconfigure $id,12 -foreground darkorange
      } else {
         $::bdi_tools_reports::data_newaster_bodies cellconfigure $id,12 -foreground red
      }

      # mpc
      set mpc [string range $mpc 0 1]
      #gren_info "\[$mpc\] \n"
      if { $mpc == "ye" } {
         $::bdi_tools_reports::data_newaster_bodies cellconfigure $id,14 -foreground green
      } else {
         $::bdi_tools_reports::data_newaster_bodies cellconfigure $id,14 -foreground red
      }

      update
      return
   }







   #----------------------------------------------------------------------------
   # On click table obs
   proc ::bdi_gui_reports::cmdButton1Click_data_newaster_obs { w args } {

      global bddconf

      return
   }     





   #----------------------------------------------------------------------------
   # On click table Bodies
   proc ::bdi_gui_reports::cmdButton1Click_data_newaster_bodies { w args } {

      global bddconf

      set curselection [$::bdi_tools_reports::data_newaster_bodies curselection]
      set nb [llength $curselection]
      if {$nb != 1 } {
         $::bdi_tools_reports::data_newaster_des    delete 0 end
         $::bdi_tools_reports::data_newaster_obs    delete 0 end
         return
      }

      set id_obj [lindex [$::bdi_tools_reports::data_newaster_bodies get [lindex $curselection 0] ] 0]

      set ::bdi_gui_reports::data_newaster_bodies_selected $id_obj

      gren_info "id_obj = $id_obj \n"
      gren_info "index_info = $::bdi_tools_reports::tab_newaster($id_obj,index_info) \n"
      
      # Remplissage de la table des designations
      $::bdi_tools_reports::data_newaster_des    delete 0 end
      
      if {![info exists ::bdi_tools_reports::tab_newaster($id_obj,gfo)]} {
         return
      }
      
      array set gfo $::bdi_tools_reports::tab_newaster($id_obj,gfo)
      for {set i 1} {$i <= $gfo(designation,nb)} {incr i} {
         $::bdi_tools_reports::data_newaster_des insert end [list \
                  $id_obj  \
                  $gfo(designation,$i,name)  \
                  $gfo(designation,$i,fdes)  \
                  $gfo(designation,$i,fmpc)  \
                  ]
      }
      
      $::bdi_tools_reports::data_newaster_des sortbycolumn 1 -decreasing
      
      # Remplissage de la table d observation
      $::bdi_tools_reports::data_newaster_obs    delete 0 end
      foreach id_info $::bdi_tools_reports::tab_newaster($id_obj,index_info) {
         $::bdi_tools_reports::data_newaster_obs insert end [list \
                  $gfo(designation,current)  \
                  $::bdi_tools_reports::tab_newaster($id_obj,$id_info,batch)  \
                  $::bdi_tools_reports::tab_newaster($id_obj,$id_info,firstdate)  \
                  $::bdi_tools_reports::tab_newaster($id_obj,$id_info,nb_dates)   \
                  $::bdi_tools_reports::tab_newaster($id_obj,$id_info,submit_mpc) \
                  "-1" "-1" "-1" "-1" "-1" \
                  $id_obj $id_info \
                  ]
      }
      $::bdi_tools_reports::data_newaster_obs sortbycolumn 2 -decreasing
      
      
      
      
      return
   }



   #----------------------------------------------------------------------------
   # planification MPC
   proc ::bdi_gui_reports::newaster_bodies_planification_MPC_NOEG { } {

      set curselection [$::bdi_tools_reports::data_newaster_bodies curselection]
      set nb [llength $curselection]
      if {$nb != 1 } {return}
      
      set id_obj [lindex [$::bdi_tools_reports::data_newaster_bodies get [lindex $curselection 0] ] 0]
      gren_info "id_obj = $id_obj \n"
      set ::bdi_gui_reports::newaster_planif_id_obj $id_obj
      ::bdi_gui_reports::build_gui_newaster_planif_MPC_NOEG
      return
   }







   #----------------------------------------------------------------------------
   # planification ORBFIT
   proc ::bdi_gui_reports::newaster_bodies_planification_fitobs { } {

      set curselection [$::bdi_tools_reports::data_newaster_bodies curselection]
      set nb [llength $curselection]
      if {$nb != 1 } {return}
      
      set id_obj [lindex [$::bdi_tools_reports::data_newaster_bodies get [lindex $curselection 0] ] 0]
      set status [lindex [$::bdi_tools_reports::data_newaster_bodies get [lindex $curselection 0] ] 4]    
      
      if {$status == "Planif" || $status == "Success"} {
         gren_info "id_obj = $id_obj \n"
         set ::bdi_gui_reports::newaster_planif_id_obj $id_obj
         ::bdi_gui_reports::build_gui_newaster_planif_orbfit
      } else {
         gren_erreur "status = $status \n"
         set res [tk_messageBox -message  "Planification impossible aucune orbite valide pour cet objet" -type ok]
      }
      
      return
   }






#------------------------------------------------------------
## Cette fonction lit une ligne d un fichier csv
# @return void
#
proc csv:parse {line {sepa ,}} {
   set lst [split $line $sepa]
   set nlst {}
   set l [llength $lst]
   for {set i 0} {$i < $l} {incr i} {
       if {[string index [lindex $lst $i] 0] == "\""} {
          # start of a stringhttp://purl.org/thecliff/tcl/wiki/721.html
          if {[string index [lindex $lst $i] end] == "\""} {
             # check for completeness, on our way we repair double double quotes
             set c1 [string range [lindex $lst $i] 1 end]
             set n1 [regsub -all {""} $c1 {"} c2]
             set n2 [regsub -all {"} $c2 {"} c3]
             if {$n1 == $n2} {
                # string extents to next list element
                set new_el [join [lrange $lst $i [expr {$i + 1}]] $sepa]
                set lst [lreplace $lst $i [expr {$i + 1}] $new_el]
                incr i -1
                incr l -1
                continue
                } else {
                # we are done with this element
                lappend nlst [string trim [string range $c2 0 [expr {[string length $c2] - 2}]]]
                continue
                }
             } else {
             # string extents to next list element
             set new_el [join [lrange $lst $i [expr {$i + 1}]] $sepa]
             set lst [lreplace $lst $i [expr {$i + 1}] $new_el]
             incr i -1
             incr l -1
             continue
             }
          } else {
          # the most simple case
          lappend nlst [string trim [lindex $lst $i]]
          continue
          }
       }
   return $nlst
 }
