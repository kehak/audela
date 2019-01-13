## @file bdi_gui_reports_astrophotom.tcl
#  @brief     GUI pour le traitement des rapports photometrique et astrometrique
#  @author    Frederic Vachier
#  @version   1.0
#  @date      2018
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_reports_astrophotom.tcl]
#  @endcode

# $Id: bdi_gui_reports_astrophotom.tcl 13117 2016-05-21 02:00:00Z fredvachier $







proc ::bdi_gui_reports::build_gui_astrophotom { frm_astrophotom } {

      set view_list [list normal astrom photom nostd submit files]


      set ::bdi_gui_reports::widget(frame,astrophotom) $frm_astrophotom
      
         set buttons [frame $frm_astrophotom.buttons -borderwidth 1 -relief groove]
         pack $buttons -in $frm_astrophotom -side top

            button $buttons.charge -text "Charge" -borderwidth 2 -takefocus 1 \
               -command "::bdi_tools_reports::charge"
            label  $buttons.blanck -text "" -borderwidth 1 -width 10

            button $buttons.wb_obj -state active -text "Objects" -relief "sunken" \
               -command "::bdi_gui_reports::click_button_obj"
            button $buttons.wb_fda -state active -text "Dates" -relief "raised" \
               -command "::bdi_gui_reports::click_button_firstdate"
            button $buttons.wb_nui -state active -text "Nuitees" -relief "raised" \
               -command "::bdi_gui_reports::click_button_nuitee"
            button $buttons.wb_tot -state active -text "Total" -relief "raised" \
               -command "::bdi_gui_reports::click_button_total "

            label  $buttons.wb_labview -text "View mode :" -borderwidth 1 -width 12

            menubutton $buttons.wb_viewmode -relief sunken -borderwidth 2  \
                          -textvariable ::bdi_tools_reports::viewmode \
                          -menu $buttons.wb_viewmode.list

            set menuconfig [menu $buttons.wb_viewmode.list -tearoff 1]
            foreach myview $view_list {
               $menuconfig add radiobutton -label $myview -value $myview \
                  -variable ::bdi_tools_reports::viewmode \
                  -command "::bdi_gui_reports::affiche_data"
            }

            grid $buttons.charge $buttons.blanck $buttons.wb_obj $buttons.wb_fda $buttons.wb_nui $buttons.wb_tot $buttons.wb_labview $buttons.wb_viewmode

  set table_resume [frame $frm_astrophotom.table_resume  -borderwidth 1 -relief groove]
  pack $table_resume -in $frm_astrophotom -expand yes -fill both


  set double [frame $table_resume.double  -borderwidth 1 -relief groove]
  pack $double -in $table_resume -expand yes -fill both

     set wf_obj [frame $double.wf_obj  -borderwidth 1 -relief groove]
     pack $wf_obj -in $double -expand yes -fill both -side left

            set cols [list 0 "Obj"   right \
                           0 "Num"   right \
                           0 "Name"  left \
                     ]

            # Table
            set ::bdi_tools_reports::data_obj $wf_obj.table
            tablelist::tablelist $::bdi_tools_reports::data_obj \
              -columns $cols \
              -labelcommand tablelist::sortByColumn \
              -xscrollcommand [ list $wf_obj.hsb set ] \
              -yscrollcommand [ list $wf_obj.vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -showseparators 1

            # Scrollbar
            scrollbar $wf_obj.hsb -orient horizontal -command [list $::bdi_tools_reports::data_obj xview]
            pack $wf_obj.hsb -in $wf_obj -side bottom -fill x
            scrollbar $wf_obj.vsb -orient vertical -command [list $::bdi_tools_reports::data_obj yview]
            pack $wf_obj.vsb -in $wf_obj -side right -fill y

            # Pack la Table
            pack $::bdi_tools_reports::data_obj -in $wf_obj -expand yes -fill both

            # Binding
            bind $::bdi_tools_reports::data_obj <<ListboxSelect>> [ list ::bdi_gui_reports::cmdButton1Click_data_obj %W ]
            #bind [$::bdi_tools_reports::data_obj bodypath] <ButtonPress-3> [ list tk_popup $wf_obj.popupTbl %X %Y ]

            # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
            #    Ascii
            foreach ncol [list "Obj"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_tools_reports::data_obj columnconfigure $pcol -hide yes
            }
            foreach ncol [list "Num"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_tools_reports::data_obj columnconfigure $pcol -sortmode int
            }
            foreach ncol [list "Name"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_tools_reports::data_obj columnconfigure $pcol -sortmode ascii
            }

     set wf_fda [frame $double.wf_fda  -borderwidth 1 -relief groove]
     pack $wf_fda -in $double -expand yes -fill both -side left

            set cols [list 0 "1ere Date"    left  \
                     ]

            # Table
            set ::bdi_tools_reports::data_firstdate $wf_fda.table
            tablelist::tablelist $::bdi_tools_reports::data_firstdate \
              -columns $cols \
              -labelcommand tablelist::sortByColumn \
              -xscrollcommand [ list $wf_fda.hsb set ] \
              -yscrollcommand [ list $wf_fda.vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -showseparators 1

            # Scrollbar
            scrollbar $wf_fda.hsb -orient horizontal -command [list $::bdi_tools_reports::data_firstdate xview]
            pack $wf_fda.hsb -in $wf_fda -side bottom -fill x
            scrollbar $wf_fda.vsb -orient vertical -command [list $::bdi_tools_reports::data_firstdate yview]
            pack $wf_fda.vsb -in $wf_fda -side right -fill y

            # Pack la Table
            pack $::bdi_tools_reports::data_firstdate -in $wf_fda -expand yes -fill both

            # Binding
            bind $::bdi_tools_reports::data_firstdate <<ListboxSelect>> [ list ::bdi_gui_reports::cmdButton1Click_data_firstdate %W ]
            #bind [$::bdi_tools_reports::data_firstdate bodypath] <ButtonPress-3> [ list tk_popup $wf_fda.popupTbl %X %Y ]

            # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
            #    Ascii
            foreach ncol [list "1ere Date"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_tools_reports::data_firstdate columnconfigure $pcol -sortmode ascii
            }

  set wf_nui [frame $table_resume.wf_nui  -borderwidth 1 -relief groove]
  # pack $wf_nui -in $table_resume -expand yes -fill both

            set cols [::bdi_tools_reports::get_cols_nuitee]

            set ::bdi_tools_reports::data_nuitee $wf_nui.table
            tablelist::tablelist $::bdi_tools_reports::data_nuitee \
              -columns $cols \
              -labelcommand tablelist::sortByColumn \
              -xscrollcommand [ list $wf_nui.hsb set ] \
              -yscrollcommand [ list $wf_nui.vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -showseparators 1

            # Scrollbar
            scrollbar $wf_nui.hsb -orient horizontal -command [list $::bdi_tools_reports::data_nuitee xview]
            pack $wf_nui.hsb -in $wf_nui -side bottom -fill x
            scrollbar $wf_nui.vsb -orient vertical -command [list $::bdi_tools_reports::data_nuitee yview]
            pack $wf_nui.vsb -in $wf_nui -side right -fill y

            # Pack la Table
            pack $::bdi_tools_reports::data_nuitee -in $wf_nui -expand yes -fill both

            # Binding
            bind $::bdi_tools_reports::data_nuitee <<ListboxSelect>> [ list ::bdi_gui_reports::cmdButton1Click_data_nuitee  %W ]
            #bind [$::bdi_tools_reports::data_nuitee bodypath] <ButtonPress-3> [ list tk_popup $wf_nui.popupTbl %X %Y ]

            # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)

            # ascii
            foreach pcol [list 0 1 3 10 12 ] {
               $::bdi_tools_reports::data_nuitee columnconfigure $pcol -sortmode ascii
            }
            # real
            foreach pcol [list 3 4 5 6 7 8 9 ] {
               $::bdi_tools_reports::data_nuitee columnconfigure $pcol -sortmode real
            }
            # integer
            foreach pcol [list 11 13 14 15 16 17 19 21 ] {
               $::bdi_tools_reports::data_nuitee columnconfigure $pcol -sortmode integer
            }

            #   Couleurs
            foreach pcol [list 6 7 8 9 18 19 ] {
               $::bdi_tools_reports::data_nuitee columnconfigure $pcol -background ivory
            }
            foreach pcol [list 10 11 12 13 14 15 16 17 20 21 ] {
               $::bdi_tools_reports::data_nuitee columnconfigure $pcol -background #dbfff8
            }

  set wf_tot [frame $table_resume.wf_tot  -borderwidth 1 -relief groove]
  # pack $wf_tot -in $table_resume -expand yes -fill both

            set cols [::bdi_tools_reports::get_cols_total]

            set ::bdi_tools_reports::data_total $wf_tot.table
            tablelist::tablelist $::bdi_tools_reports::data_total \
              -columns $cols \
              -labelcommand tablelist::sortByColumn \
              -xscrollcommand [ list $wf_tot.hsb set ] \
              -yscrollcommand [ list $wf_tot.vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -showseparators 1

            # Scrollbar
            scrollbar $wf_tot.hsb -orient horizontal -command [list $::bdi_tools_reports::data_total xview]
            pack $wf_tot.hsb -in $wf_tot -side bottom -fill x
            scrollbar $wf_tot.vsb -orient vertical -command [list $::bdi_tools_reports::data_total yview]
            pack $wf_tot.vsb -in $wf_tot -side right -fill y

            # Pack la Table
            pack $::bdi_tools_reports::data_total -in $wf_tot -expand yes -fill both

            # Popup
            menu $wf_tot.popupTbl -title "Actions"

               $wf_tot.popupTbl add command -label "Voir" \
                   -command "::bdi_gui_reports::view_reports ::bdi_tools_reports::data_total"

               $wf_tot.popupTbl add command -label "Exporter" \
                   -command "::bdi_gui_reports::export"

               $wf_tot.popupTbl add separator

               $wf_tot.popupTbl add command -label "Repertoire de travail" -state disable \
                   -command "::bdi_gui_reports::get_workdir_reports"

               $wf_tot.popupTbl add command -label "Effacer Entree"  \
                   -command "::bdi_gui_reports::delete_reports ::bdi_tools_reports::data_total"

               $wf_tot.popupTbl add separator

               $wf_tot.popupTbl add command -label "Soumettre rapport MPC" \
                   -command "::bdi_gui_reports::submit_reports_mpc ::bdi_tools_reports::data_total"

               $wf_tot.popupTbl add command -label "Envoyer par Mail" \
                   -command "::bdi_gui_reports::send_mail_reports ::bdi_tools_reports::data_total"

               $wf_tot.popupTbl add separator
               $wf_tot.popupTbl add command -label "Analyse des donnees" \
                   -command "::bdi_gui_reports::analysis ::bdi_tools_reports::data_total"

            # Binding
            bind $::bdi_tools_reports::data_total <<ListboxSelect>> [ list ::bdi_gui_reports::cmdButton1Click_data_total  %W ]
            bind [$::bdi_tools_reports::data_total bodypath] <ButtonPress-3> [ list tk_popup $wf_tot.popupTbl %X %Y ]
            #bind [$::bdi_tools_reports::data_total bodypath] <ButtonPress-3> [ list tk_popup $wf_tot.popupTbl %X %Y ]

            # ascii
            foreach pcol [list 0 1 2 3 4 12 14 20 22] {
               $::bdi_tools_reports::data_total columnconfigure $pcol -sortmode ascii
            }
            # real
            foreach pcol [list 5 6 7 8 9 10 11 ] {
               $::bdi_tools_reports::data_total columnconfigure $pcol -sortmode real
            }
            # integer
            foreach pcol [list 13 15 16 17 18 19 21  ] {
               $::bdi_tools_reports::data_total columnconfigure $pcol -sortmode integer
            }

            #   Couleurs
            foreach pcol [list  8 9 10 11] {
               $::bdi_tools_reports::data_total columnconfigure $pcol -background ivory
            }
            foreach pcol [list 12 13 14 15 16 17 18 19 ] {
               $::bdi_tools_reports::data_total columnconfigure $pcol -background #dbfff8
            }


  set wf_rep [frame $frm_astrophotom.wf_rep  -borderwidth 1 -relief groove]
  pack $wf_rep -in $frm_astrophotom -expand yes -fill both

         #set cols $reportscols
         set cols [::bdi_tools_reports::get_cols_reports_batch]

         #$::bdi_tools_reports::data_report -columnconfigure [::bdi_tools_reports::get_cols_reports_batch]
         #$::bdi_tools_reports::data_report deletecolumns 0 end
         #$::bdi_tools_reports::data_report configure -columns $reportscols
         #$::bdi_tools_reports::data_report configure -columntitles [::bdi_tools_reports::get_cols_reports_batch]

         # Table
         set ::bdi_tools_reports::data_report $wf_rep.table
         tablelist::tablelist $::bdi_tools_reports::data_report \
           -columns $cols \
           -labelcommand tablelist::sortByColumn \
           -xscrollcommand [ list $wf_rep.hsb set ] \
           -yscrollcommand [ list $wf_rep.vsb set ] \
           -selectmode extended \
           -activestyle none \
           -stripebackground "#e0e8f0" \
           -showseparators 1

         # Scrollbar
         scrollbar $wf_rep.hsb -orient horizontal -command [list $::bdi_tools_reports::data_report xview]
         pack $wf_rep.hsb -in $wf_rep -side bottom -fill x
         scrollbar $wf_rep.vsb -orient vertical -command [list $::bdi_tools_reports::data_report yview]
         pack $wf_rep.vsb -in $wf_rep -side right -fill y

         # Pack la Table
         pack $::bdi_tools_reports::data_report -in $wf_rep -expand yes -fill both

         # Popup
         menu $wf_rep.popupTbl -title "Actions"

            $wf_rep.popupTbl add command -label "Voir" \
                -command "::bdi_gui_reports::view_reports ::bdi_tools_reports::data_report"

            $wf_rep.popupTbl add command -label "Exporter" \
                -command "::bdi_gui_reports::export"

            $wf_rep.popupTbl add separator

            $wf_rep.popupTbl add command -label "Repertoire de travail" -state disable \
                -command "::bdi_gui_reports::get_workdir_reports"

            $wf_rep.popupTbl add command -label "Effacer Entree"  \
                -command "::bdi_gui_reports::delete_reports ::bdi_tools_reports::data_report"

            $wf_rep.popupTbl add separator

            $wf_rep.popupTbl add command -label "Soumettre rapport MPC" \
                -command "::bdi_gui_reports::submit_reports_mpc ::bdi_tools_reports::data_report"

            $wf_rep.popupTbl add command -label "Envoyer par Mail" \
                -command "::bdi_gui_reports::send_mail_reports ::bdi_tools_reports::data_report"

            $wf_rep.popupTbl add separator
            $wf_rep.popupTbl add command -label "Analyse des donnees" \
                -command "::bdi_gui_reports::analysis ::bdi_tools_reports::data_report"


         # Binding
         bind $::bdi_tools_reports::data_report <<ListboxSelect>> [ list ::bdi_gui_reports::cmdButton1Click_data_reports %W ]
         bind [$::bdi_tools_reports::data_report bodypath] <ButtonPress-3> [ list tk_popup $wf_rep.popupTbl %X %Y ]
         bind [$::bdi_tools_reports::data_report bodypath] <Double-Button-1> [ list ::bdi_gui_reports::cmdButton2Click_data_reports %W ]

         # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
         #    Ascii
#            foreach ncol [list "Batch"] {
#               set pcol [expr int ([lsearch $cols $ncol]/3)]
#               $::bdi_tools_reports::data_report columnconfigure $pcol -sortmode ascii
#            }
         #    Reel
#            foreach ncol [list "Astrom\n  TXT" "Astrom\n  XML" "Astrom\n  MPC" "Photom\n  TXT" "Photom\n  XML"] {
#               set pcol [expr int ([lsearch $cols $ncol]/3)]
#               $::bdi_tools_reports::data_report columnconfigure $pcol -sortmode ascii
#            }

}




















#------------------------------------------------------------
## gere la selection du type de tri, objects
#  @return void
#
proc ::bdi_gui_reports::click_button_obj { } {

   set appli  $::bdi_gui_reports::widget(frame,astrophotom)
   set resume $::bdi_gui_reports::widget(frame,astrophotom).table_resume
   set double $::bdi_gui_reports::widget(frame,astrophotom).table_resume.double
   set wf_nui $::bdi_gui_reports::widget(frame,astrophotom).table_resume.wf_nui
   set wf_tot $::bdi_gui_reports::widget(frame,astrophotom).table_resume.wf_tot
   set wf_rep $::bdi_gui_reports::widget(frame,astrophotom).wf_rep
   #set action $::bdi_gui_reports::widget(frame,astrophotom).actions

   set err [ catch { pack info $double } msg ]
   if {$err} {
      gren_info "double is not packed.\n"
      pack $double -in $resume -expand yes -fill both
   } else {
      gren_info "double is packed.\n"
   }

   set err [ catch { pack info $wf_nui } msg ]
   if {$err} {
      gren_info "wf_nui is not packed.\n"
   } else {
      gren_info "wf_nui is packed.\n"
      pack forget $wf_nui
   }

   set err [ catch { pack info $wf_tot } msg ]
   if {$err} {
      gren_info "wf_tot is not packed.\n"
   } else {
      gren_info "wf_tot is packed.\n"
      pack forget $wf_tot
   }

   set err [ catch { pack info $wf_rep } msg ]
   if {$err} {
      gren_info "wf_rep is not packed.\n"
      pack $wf_rep -in $appli -expand yes -fill both
   } else {
      gren_info "wf_rep is packed.\n"
   }

   #pack forget $action
   #pack $action -in $appli -expand no -fill none


   $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_obj configure -relief "sunken"
   $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_fda configure -relief "raised"
   $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_nui configure -relief "raised"
   $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_tot configure -relief "raised"

   ::bdi_gui_reports::affiche_data
   $::bdi_tools_reports::data_obj sortbycolumn 1 -increasing
}




#------------------------------------------------------------
## gere la selection du type de tri, objects our dates
#  @return void
#
proc ::bdi_gui_reports::click_button_firstdate { } {

   set appli  $::bdi_gui_reports::widget(frame,astrophotom)
   set resume $::bdi_gui_reports::widget(frame,astrophotom).table_resume
   set double $::bdi_gui_reports::widget(frame,astrophotom).table_resume.double
   set wf_nui $::bdi_gui_reports::widget(frame,astrophotom).table_resume.wf_nui
   set wf_tot $::bdi_gui_reports::widget(frame,astrophotom).table_resume.wf_tot
   set wf_rep $::bdi_gui_reports::widget(frame,astrophotom).wf_rep
   #set action $::bdi_gui_reports::widget(frame,astrophotom).actions

   set err [ catch { pack info $double } msg ]
   if {$err} {
      gren_info "double is not packed.\n"
      pack $double -in $resume -expand yes -fill both
   } else {
      gren_info "double is packed.\n"
   }

   set err [ catch { pack info $wf_nui } msg ]
   if {$err} {
      gren_info "wf_nui is not packed.\n"
   } else {
      gren_info "wf_nui is packed.\n"
      pack forget $wf_nui
   }

   set err [ catch { pack info $wf_tot } msg ]
   if {$err} {
      gren_info "wf_tot is not packed.\n"
   } else {
      gren_info "wf_tot is packed.\n"
      pack forget $wf_tot
   }

   set err [ catch { pack info $wf_rep } msg ]
   if {$err} {
      gren_info "wf_rep is not packed.\n"
      pack $wf_rep -in $appli -expand yes -fill both
   } else {
      gren_info "wf_rep is packed.\n"
   }

   #pack forget $action
   #pack $action -in $appli -expand no -fill none

   $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_obj configure -relief "raised"
   $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_fda configure -relief "sunken"
   $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_nui configure -relief "raised"
   $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_tot configure -relief "raised"

   ::bdi_gui_reports::affiche_data
   $::bdi_tools_reports::data_firstdate sortbycolumn 0 -decreasing
}




#------------------------------------------------------------
## affiche une liste Nuitees des dates et des objets
#  @return void
#
proc ::bdi_gui_reports::click_button_nuitee { } {

   set appli  $::bdi_gui_reports::widget(frame,astrophotom)
   set resume $::bdi_gui_reports::widget(frame,astrophotom).table_resume
   set double $::bdi_gui_reports::widget(frame,astrophotom).table_resume.double
   set wf_nui $::bdi_gui_reports::widget(frame,astrophotom).table_resume.wf_nui
   set wf_tot $::bdi_gui_reports::widget(frame,astrophotom).table_resume.wf_tot
   set wf_rep $::bdi_gui_reports::widget(frame,astrophotom).wf_rep
   #set action $::bdi_gui_reports::widget(frame,astrophotom).actions

   set err [ catch { pack info $double } msg ]
   if {$err} {
      gren_info "double is not packed.\n"
   } else {
      gren_info "double is packed.\n"
      pack forget $double
   }

   set err [ catch { pack info $wf_nui } msg ]
   if {$err} {
      gren_info "wf_nui is not packed.\n"
      pack $wf_nui -in $resume -expand yes -fill both
   } else {
      gren_info "wf_nui is packed.\n"
   }

   set err [ catch { pack info $wf_tot } msg ]
   if {$err} {
      gren_info "wf_tot is not packed.\n"
   } else {
      gren_info "wf_tot is packed.\n"
      pack forget $wf_tot
   }

   set err [ catch { pack info $wf_rep } msg ]
   if {$err} {
      gren_info "wf_rep is not packed.\n"
      pack $wf_rep -in $appli -expand yes -fill both
   } else {
      gren_info "wf_rep is packed.\n"
   }

   #pack forget $action
   #pack $action -in $appli -expand no -fill none

   $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_obj configure -relief "raised"
   $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_fda configure -relief "raised"
   $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_nui configure -relief "sunken"
   $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_tot configure -relief "raised"

   ::bdi_gui_reports::affiche_data
   $::bdi_tools_reports::data_nuitee sortbycolumn 0 -decreasing

}




#------------------------------------------------------------
## affiche une liste total  des dates et des objets
#  @return void
#
proc ::bdi_gui_reports::click_button_total  { } {

   set appli  $::bdi_gui_reports::widget(frame,astrophotom)
   set resume $::bdi_gui_reports::widget(frame,astrophotom).table_resume
   set double $::bdi_gui_reports::widget(frame,astrophotom).table_resume.double
   set wf_nui $::bdi_gui_reports::widget(frame,astrophotom).table_resume.wf_nui
   set wf_tot $::bdi_gui_reports::widget(frame,astrophotom).table_resume.wf_tot
   set wf_rep $::bdi_gui_reports::widget(frame,astrophotom).wf_rep
   #set action $::bdi_gui_reports::widget(frame,astrophotom).actions

   set err [ catch { pack info $double } msg ]
   if {$err} {
      gren_info "double is not packed.\n"
   } else {
      gren_info "double is packed.\n"
      pack forget $double
   }

   set err [ catch { pack info $wf_nui } msg ]
   if {$err} {
      gren_info "wf_nui is not packed.\n"
   } else {
      gren_info "wf_nui is packed.\n"
      pack forget $wf_nui
   }

   set err [ catch { pack info $wf_tot } msg ]
   if {$err} {
      gren_info "wf_tot is not packed.\n"
      pack $wf_tot -in $resume -expand yes -fill both
   } else {
      gren_info "wf_tot is packed.\n"
   }

   set err [ catch { pack info $wf_rep } msg ]
   if {$err} {
      gren_info "wf_rep is not packed.\n"
   } else {
      gren_info "wf_rep is packed.\n"
      pack forget $wf_rep
   }

   #pack forget $action
   #pack $action -in $appli -expand no -fill none

   $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_obj configure -relief "raised"
   $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_fda configure -relief "raised"
   $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_nui configure -relief "raised"
   $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_tot configure -relief "sunken"

   ::bdi_gui_reports::affiche_data

}




#------------------------------------------------------------
## lecture des info astrometrique
# @param  obj       : nom de l objet
# @param  firstdate : date iso YYYY-MM-DD de la premiere observation
# @param  submit    : Yes ou No
# @param  file      : Chemin complet vers fichier
# @return void
#
proc ::bdi_tools_reports::get_info_astrom { obj firstdate submit file } {


   set chan [open $file r]

   set lecture 0
   while {[gets $chan line] >= 0} {

      if {!$lecture} {
         if {[regexp -- {^\#\$\+} $line]} {
            #gren_info "on demarre la lecture\n"
            set lecture 1
         }
         continue
      }

      if {[regexp -- {^\#\$\-} $line]} {
         #gren_info "on arrete la lecture\n"
         break
      }

      # OBJECT            = SKYBOT_202421_2005_UQ513
      set r [regexp -all -inline -- {^\# OBJECT *= (.*)} $line] ; #"
      if {$r!=""} {
         set object [lindex $r 1]
         if {$object!=$obj} {
            #gren_erreur "Objet non conforme : $object != $obj \n"
            set lecture 0
            continue
         }
      }

      # IAU code          = 586
      set r [regexp -all -inline -- {^\# IAU code *= (.*)} $line] ; #"
      if {$r!=""} { set iau_code [lindex $r 1] ; continue }

      # Nb of firstdates       = 74
      set r [regexp -all -inline -- {^\# Nb of firstdates *= (.*)} $line] ; #"
      if {$r!=""} { set nbpts_a [lindex $r 1] ; continue }

      # Duration (h)      = 4.2
      set r [regexp -all -inline -- {^\# Duration \(h\) *= (.*)} $line] ; #"
      if {$r!=""} { set duration [lindex $r 1] ; continue }

      # Magnitude         = 12
      set r [regexp -all -inline -- {^\# Magnitude *= (.*)} $line] ; #"
      if {$r!=""} { set mag [lindex $r 1] ; continue }

      # Magnitude STD     = 0.1
      set r [regexp -all -inline -- {^\# Magnitude STD *= (.*)} $line] ; #"
      if {$r!=""} { set mag_std [lindex $r 1] ; continue }

      # Magnitude Ampl    = 0.6
      set r [regexp -all -inline -- {^\# Magnitude Ampl *= (.*)} $line] ; #"
      if {$r!=""} { set mag_ampl [lindex $r 1] ; continue }

      # Magnitude Prec    = 0.1
      set r [regexp -all -inline -- {^\# Variation Moy CM *= (.*)} $line] ; #"
      if {$r!=""} { set prec_mag [lindex $r 1] ; continue }

      # FWHM (arcsec)     = 3.5
      set r [regexp -all -inline -- {^\# FWHM \(arcsec\) *= (.*)} $line] ; #"
      if {$r!=""} { set fwhm [lindex $r 1] ; continue }

      # FWHM STD (arcsec) = 0.3
      set r [regexp -all -inline -- {^\# FWHM STD \(arcsec\) *= (.*)} $line] ; #"
      if {$r!=""} { set fwhm_std [lindex $r 1] ; continue }

      # Right Asc. (hms)  = 00 30 11.1434
      set r [regexp -all -inline -- {^\# Right Asc\. \(hms\) *= (.*)} $line] ; #"
      if {$r!=""} { set ra [lindex $r 1] ; continue }

      # Declination (dms) = +30 37 22.074
      set r [regexp -all -inline -- {^\# Declination \(dms\) *= (.*)} $line] ; #"
      if {$r!=""} { set dec [lindex $r 1] ; continue }

      # RA STD (mas)      = 3470.0
      set r [regexp -all -inline -- {^\# RA STD \(mas\) *= (.*)} $line] ; #"
      if {$r!=""} { set ra_std [lindex $r 1] ; continue }

      # DEC STD (mas)     = 590.4
      set r [regexp -all -inline -- {^\# DEC STD \(mas\) *= (.*)} $line] ; #"
      if {$r!=""} { set dec_std [lindex $r 1] ; continue }

      # Residus (mas)     = 170
      set r [regexp -all -inline -- {^\# Residus \(mas\) *= (.*)} $line] ; #"
      if {$r!=""} { set residus [lindex $r 1] ; continue }

      # Residus STD (mas) = 1
      set r [regexp -all -inline -- {^\# Residus STD \(mas\) *= (.*)} $line] ; #"
      if {$r!=""} { set residus_std [lindex $r 1] ; continue }

      # OmC (mas)         = +677
      set r [regexp -all -inline -- {^\# OmC \(mas\) *= (.*)} $line] ; #"
      if {$r!=""} { set omc [lindex $r 1] ; continue }

      # OmC STD (mas)     = +33
      set r [regexp -all -inline -- {^\# OmC STD \(mas\) *= (.*)} $line] ; #"
      if {$r!=""} { set omc_std [lindex $r 1] ; continue }

   }
   close $chan


   set ::bdi_tools_reports::tab_report($obj,$firstdate,astrom)    "Yes"
   set ::bdi_tools_reports::tab_report($obj,$firstdate,submit_a)  $submit

   if {[info exists iau_code]}    { set ::bdi_tools_reports::tab_report($obj,$firstdate,iau_code)    $iau_code }
   if {[info exists nbpts_a]}     { set ::bdi_tools_reports::tab_report($obj,$firstdate,nbpts_a)     $nbpts_a }
   if {[info exists fwhm]}        { set ::bdi_tools_reports::tab_report($obj,$firstdate,fwhm)        $fwhm }
   if {[info exists fwhm_std]}    { set ::bdi_tools_reports::tab_report($obj,$firstdate,fwhm_std)    $fwhm_std }
   if {[info exists ra]}          { set ::bdi_tools_reports::tab_report($obj,$firstdate,ra)          $ra }
   if {[info exists dec]}         { set ::bdi_tools_reports::tab_report($obj,$firstdate,dec)         $dec }
   if {[info exists ra_std]}      { set ::bdi_tools_reports::tab_report($obj,$firstdate,ra_std)      $ra_std }
   if {[info exists dec_std]}     { set ::bdi_tools_reports::tab_report($obj,$firstdate,dec_std)     $dec_std }
   if {[info exists residus]}     { set ::bdi_tools_reports::tab_report($obj,$firstdate,residus)     $residus }
   if {[info exists residus_std]} { set ::bdi_tools_reports::tab_report($obj,$firstdate,residus_std) $residus_std }
   if {[info exists omc]}         { set ::bdi_tools_reports::tab_report($obj,$firstdate,omc)         $omc }
   if {[info exists omc_std]}     { set ::bdi_tools_reports::tab_report($obj,$firstdate,omc_std)     $omc_std }

   if {![info exists ::bdi_tools_reports::tab_report($obj,$firstdate,duration)]} {
      if {[info exists duration]} {
         set ::bdi_tools_reports::tab_report($obj,$firstdate,duration) $duration
      }
   }

   if {![info exists ::bdi_tools_reports::tab_report($obj,$firstdate,mag)]} {
      if {[info exists mag]} {
         set ::bdi_tools_reports::tab_report($obj,$firstdate,mag) $mag
      }
   }

   if {![info exists ::bdi_tools_reports::tab_report($obj,$firstdate,mag_std)]} {
      if {[info exists mag_std]} {
         set ::bdi_tools_reports::tab_report($obj,$firstdate,mag_std) $mag_std
      }
   }

   if {![info exists ::bdi_tools_reports::tab_report($obj,$firstdate,mag_ampl)]} {
      if {[info exists mag_ampl]} {
         set ::bdi_tools_reports::tab_report($obj,$firstdate,mag_ampl) $mag_ampl
      }
   }

   if {![info exists ::bdi_tools_reports::tab_report($obj,$firstdate,prec_mag)]} {
      if {[info exists prec_mag]} {
         set ::bdi_tools_reports::tab_report($obj,$firstdate,prec_mag) $prec_mag
      }
   }


}

#------------------------------------------------------------
## lecture des info photometrique
# @param  obj       : nom de l objet
# @param  firstdate : date iso YYYY-MM-DD de la premiere observation
# @param  submit    : Yes ou No
# @param  file      : Chemin complet vers fichier
# @return void
#
 proc ::bdi_tools_reports::get_info_photom { obj firstdate submit file } {

   set chan [open $file r]

   set lecture 0
   while {[gets $chan line] >= 0} {

      if {!$lecture} {
         if {[regexp -- {^\#\$\+} $line]} {
            #gren_info "on demarre la lecture\n"
            set lecture 1
         }
         continue
      }

      if {[regexp -- {^\#\$\-} $line]} {
         #gren_info "on arrete la lecture\n"
         break
      }

      # OBJECT            = SKYBOT_202421_2005_UQ513
      set r [regexp -all -inline -- {^\# OBJECT *= (.*)} $line] ; #"
      if {$r!=""} {
         set object [lindex $r 1]
         if {$object!=$obj} {
            #gren_erreur "Objet non conforme : $object != $obj \n"
            set lecture 0
            continue
         }
      }

      # IAU code          = 586
      set r [regexp -all -inline -- {^\# IAU code *= (.*)} $line] ; #"
      if {$r!=""} { set iau_code [lindex $r 1]; continue }

      # Nb of firstdates       = 74
      set r [regexp -all -inline -- {^\# Nb of firstdates *= (.*)} $line] ; #"
      if {$r!=""} { set nbpts_p [lindex $r 1] ; continue }

      # Duration (h)      = 4.2
      set r [regexp -all -inline -- {^\# Duration \(h\) *= (.*)} $line] ; #"
      if {$r!=""} { set duration [lindex $r 1] ; continue }

      # Magnitude         = 12
      set r [regexp -all -inline -- {^\# Magnitude *= (.*)} $line] ; #"
      if {$r!=""} { set mag [lindex $r 1] ; continue }

      # Magnitude STD     = 0.1
      set r [regexp -all -inline -- {^\# Magnitude STD *= (.*)} $line] ; #"
      if {$r!=""} { set mag_std [lindex $r 1] ; continue }

      # Magnitude Ampl    = 0.6
      set r [regexp -all -inline -- {^\# Magnitude Ampl *= (.*)} $line] ; #"
      if {$r!=""} { set mag_ampl [lindex $r 1] ; continue }

      # Magnitude Prec    = 0.1
      set r [regexp -all -inline -- {^\# Variation Moy CM *= (.*)} $line] ; #"
      if {$r!=""} { set prec_mag [lindex $r 1] ; continue }

      # FWHM (arcsec)     = 3.5
      set r [regexp -all -inline -- {^\# FWHM \(arcsec\) *= (.*)} $line] ; #"
      if {$r!=""} { set fwhm [lindex $r 1] ; continue }

      # FWHM STD (arcsec) = 0.3
      set r [regexp -all -inline -- {^\# FWHM STD \(arcsec\) *= (.*)} $line] ; #"
      if {$r!=""} { set fwhm_std [lindex $r 1] ; continue }

      # Right Asc. (hms)  = 00 30 11.1434
      set r [regexp -all -inline -- {^\# Right Asc\. \(hms\) *= (.*)} $line] ; #"
      if {$r!=""} { set ra [lindex $r 1] ; continue }

      # Declination (dms) = +30 37 22.074
      set r [regexp -all -inline -- {^\# Declination \(dms\) *= (.*)} $line] ; #"
      if {$r!=""} { set dec [lindex $r 1] ; continue }

      # RA STD (mas)      = 3470.0
      set r [regexp -all -inline -- {^\# RA STD \(mas\) *= (.*)} $line] ; #"
      if {$r!=""} { set ra_std [lindex $r 1] ; continue }

      # DEC STD (mas)     = 590.4
      set r [regexp -all -inline -- {^\# DEC STD \(mas\) *= (.*)} $line] ; #"
      if {$r!=""} { set dec_std [lindex $r 1] ; continue }


   }
   close $chan

   set ::bdi_tools_reports::tab_report($obj,$firstdate,photom)    "Yes"
   set ::bdi_tools_reports::tab_report($obj,$firstdate,submit_p)  $submit

   if {[info exists iau_code]}  { set ::bdi_tools_reports::tab_report($obj,$firstdate,iau_code)  $iau_code }
   if {[info exists duration]}  { set ::bdi_tools_reports::tab_report($obj,$firstdate,duration)  $duration }
   if {[info exists mag]}       { set ::bdi_tools_reports::tab_report($obj,$firstdate,mag)       $mag }
   if {[info exists mag_std]}   { set ::bdi_tools_reports::tab_report($obj,$firstdate,mag_std)   $mag_std }
   if {[info exists mag_ampl]}  { set ::bdi_tools_reports::tab_report($obj,$firstdate,mag_ampl)  $mag_ampl }
   if {[info exists prec_mag]}  { set ::bdi_tools_reports::tab_report($obj,$firstdate,prec_mag)  $prec_mag }
   if {[info exists nbpts_p]}   { set ::bdi_tools_reports::tab_report($obj,$firstdate,nbpts_p)   $nbpts_p }

   if {![info exists ::bdi_tools_reports::tab_report($obj,$firstdate,fwhm) ]} {
      if {[info exists fwhm]} {
         set ::bdi_tools_reports::tab_report($obj,$firstdate,fwhm) $fwhm
      }
   }

   if {![info exists ::bdi_tools_reports::tab_report($obj,$firstdate,fwhm_std) ]} {
      if {[info exists fwhm_std]} {
         set ::bdi_tools_reports::tab_report($obj,$firstdate,fwhm_std) $fwhm_std
      }
   }

   if {![info exists ::bdi_tools_reports::tab_report($obj,$firstdate,ra) ]} {
      if {[info exists ra]} {
         set ::bdi_tools_reports::tab_report($obj,$firstdate,ra) $ra
      }
   }

   if {![info exists ::bdi_tools_reports::tab_report($obj,$firstdate,dec) ]} {
      if {[info exists dec]} {
         set ::bdi_tools_reports::tab_report($obj,$firstdate,dec) $dec
      }
   }

   if {![info exists ::bdi_tools_reports::tab_report($obj,$firstdate,ra_std) ]} {
      if {[info exists ra_std]} {
         set ::bdi_tools_reports::tab_report($obj,$firstdate,ra_std) $ra_std
      }
   }

   if {![info exists ::bdi_tools_reports::tab_report($obj,$firstdate,dec_std) ]} {
      if {[info exists dec_std]} {
         set ::bdi_tools_reports::tab_report($obj,$firstdate,dec_std) $dec_std
      }
   }
}



#----------------------------------------------------------------------------
# On click Bouton Objet
proc ::bdi_gui_reports::cmdButton1Click_data_obj { w args } {

   global bddconf


   set wb_obj $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_obj
   set wb_fda $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_fda


   if {[$wb_fda cget -relief] == "sunken"} {

      # si le bouton theme firstdate est enfoncé
      # et qu on clique sur la liste objet

      set curselection [$::bdi_tools_reports::data_obj curselection]
      set nb [llength $curselection]
      if {$nb == 0 } {return}

      set cpt 0
      foreach line [$::bdi_tools_reports::data_obj get 0 end] {
         $::bdi_tools_reports::data_obj cellconfigure $cpt,0 -font $bddconf(font,arial_10)
         incr cpt
      }

      $::bdi_tools_reports::data_report delete 0 end
      foreach select $curselection {

         $::bdi_tools_reports::data_obj cellconfigure $select,0 -font $bddconf(font,arial_10_b)
         set ::bdi_gui_reports::selected_obj [lindex [$::bdi_tools_reports::data_obj get $select] 0]

         set obj       $::bdi_gui_reports::selected_obj
         set firstdate $::bdi_gui_reports::selected_firstdate

         if {[info exists ::bdi_tools_reports::tab_batch($obj,$firstdate)]} {

            foreach batch $::bdi_tools_reports::tab_batch($obj,$firstdate) {

               set line [::bdi_tools_reports::get_line_reports_batch $obj $firstdate $batch]
               if {$line!=""} {$::bdi_tools_reports::data_report insert end $line}
            }
         }

         $::bdi_tools_reports::data_report sortbycolumn 0 -decreasing

      }

   } else {

      # On a cliqué sur les OBJETS
      set curselection [$::bdi_tools_reports::data_obj curselection]
      set nb [llength $curselection]
      #gren_info "nb select = $nb\n"

      if {$nb == 0 } {return}
      if {$nb > 1 } {
         tk_messageBox -message "Veuillez selectionner 1 seul objet" -type ok
         return
      }

      set cpt 0
      foreach line [$::bdi_tools_reports::data_obj get 0 end] {
         $::bdi_tools_reports::data_obj cellconfigure $cpt,0 -font $bddconf(font,arial_10)
         incr cpt
      }

      foreach select $curselection {
         $::bdi_tools_reports::data_obj cellconfigure $select,0 -font $bddconf(font,arial_10_b)
         set obj [lindex [$::bdi_tools_reports::data_obj get $select] 0]
         gren_info "Info sur l objet : $obj\n"
      }
      set ::bdi_gui_reports::selected_obj $obj


      $::bdi_tools_reports::data_firstdate delete 0 end

      foreach firstdate $::bdi_tools_reports::tab_firstdate($obj) {

         $::bdi_tools_reports::data_firstdate insert end $firstdate

      }

      $::bdi_tools_reports::data_firstdate sortbycolumn 0 -decreasing
      $::bdi_tools_reports::data_report delete 0 end

   }

}



#----------------------------------------------------------------------------
# On click
proc ::bdi_gui_reports::cmdButton1Click_data_firstdate { w args } {

   global bddconf

   set wb_obj $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_obj
   set wb_fda $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_fda

   if {[$wb_fda cget -relief] == "sunken"} {

      # si le bouton theme firstdate est enfoncé
      # et qu on clique sur la liste firstdate

      #gren_info "choose dates\n"

      set curselection [$::bdi_tools_reports::data_firstdate curselection]
      set nb [llength $curselection]
      #gren_info "nb select = $nb\n"

      if {$nb == 0 } {return}
      if {$nb > 1 } {
         tk_messageBox -message "Veuillez selectionner 1 seule date" -type ok
         return
      }

      set cpt 0
      foreach line [$::bdi_tools_reports::data_firstdate get 0 end] {
         $::bdi_tools_reports::data_firstdate cellconfigure $cpt,0 -font $bddconf(font,arial_10)
         incr cpt
      }

      foreach select $curselection {
         $::bdi_tools_reports::data_firstdate cellconfigure $select,0 -font $bddconf(font,arial_10_b)
         set firstdate [lindex [$::bdi_tools_reports::data_firstdate get $select] 0]
         gren_info "Info sur la firsdate : $firstdate\n"
      }
      set ::bdi_gui_reports::selected_firstdate $firstdate


      $::bdi_tools_reports::data_obj delete 0 end

      foreach obj $::bdi_tools_reports::tab_obj($firstdate) {
         set n [split $obj "_"]
         set num  [string trim [lindex $n 1]]
         set name [string trim [lrange $n 2 end]]
         $::bdi_tools_reports::data_obj insert end [list $obj $num $name]
      }

      $::bdi_tools_reports::data_obj sortbycolumn 1 -increasing
      $::bdi_tools_reports::data_report delete 0 end


   } else {

      # si le bouton theme Objet est enfoncé
      # et qu on clique sur la liste firstdate

      set curselection [$::bdi_tools_reports::data_firstdate curselection]
      set nb [llength $curselection]
      if {$nb == 0 } {return}

      set cpt 0
      foreach line [$::bdi_tools_reports::data_firstdate get 0 end] {
         $::bdi_tools_reports::data_firstdate cellconfigure $cpt,0 -font $bddconf(font,arial_10)
         incr cpt
      }

      $::bdi_tools_reports::data_report delete 0 end
      foreach select $curselection {

         $::bdi_tools_reports::data_firstdate cellconfigure $select,0 -font $bddconf(font,arial_10_b)
         set ::bdi_gui_reports::selected_firstdate [lindex [$::bdi_tools_reports::data_firstdate get $select] 0]

         set obj       $::bdi_gui_reports::selected_obj
         set firstdate $::bdi_gui_reports::selected_firstdate

         if {[info exists ::bdi_tools_reports::tab_batch($obj,$firstdate)]} {

            foreach batch $::bdi_tools_reports::tab_batch($obj,$firstdate) {

               set line [::bdi_tools_reports::get_line_reports_batch $obj $firstdate $batch]
               if {$line!=""} {$::bdi_tools_reports::data_report insert end $line}
            }
         }

         $::bdi_tools_reports::data_report sortbycolumn 0 -decreasing

      }

   }

}


#----------------------------------------------------------------------------
# On click
proc ::bdi_gui_reports::cmdButton1Click_data_nuitee { w args } {

   global bddconf

   set curselection [$::bdi_tools_reports::data_nuitee curselection]
   set nb [llength $curselection]
   if {$nb == 0 } {return}

   set cpt 0
   foreach line [$::bdi_tools_reports::data_nuitee get 0 end] {
      $::bdi_tools_reports::data_nuitee rowconfigure $cpt -font $bddconf(font,arial_10)
      incr cpt
   }

   $::bdi_tools_reports::data_report delete 0 end

   foreach select $curselection {

      $::bdi_tools_reports::data_nuitee rowconfigure $select -font $bddconf(font,arial_10_b)

      set obj       [lindex [$::bdi_tools_reports::data_nuitee get $select] 1]
      set firstdate [lindex [$::bdi_tools_reports::data_nuitee get $select] 0]

      if {[info exists ::bdi_tools_reports::tab_batch($obj,$firstdate)]} {

         foreach batch $::bdi_tools_reports::tab_batch($obj,$firstdate) {
            set line [::bdi_tools_reports::get_line_reports_batch $obj $firstdate $batch]
            if {$line!=""} {$::bdi_tools_reports::data_report insert end $line}
         }
      }

   }

   $::bdi_tools_reports::data_report sortbycolumn 0 -decreasing

return
}


#----------------------------------------------------------------------------
# On click
proc ::bdi_gui_reports::cmdButton1Click_data_total  { w args } {

   global bddconf

   set curselection [$::bdi_tools_reports::data_nuitee curselection]
   set nb [llength $curselection]
   if { $nb == 0 } {return}

   set cpt 0
   foreach line [$::bdi_tools_reports::data_total get 0 end] {
      $::bdi_tools_reports::data_total rowconfigure $cpt -font $bddconf(font,arial_10)
      incr cpt
   }

   foreach select $curselection {

      $::bdi_tools_reports::data_total rowconfigure $select -font $bddconf(font,arial_10_b)

   }

}


#----------------------------------------------------------------------------

proc ::bdi_gui_reports::cmdButton1Click_data_reports { w args } {

#      gren_info "Click Droit : ($w) ($args)\n"
}



#----------------------------------------------------------------------------
proc ::bdi_gui_reports::cmdButton2Click_data_reports { w args } {

   global bddconf

   gren_info "Double Click Gauche: ($w) ($args)\n"

   set fen .view_reports
   if { ! [ winfo exists $fen ] } {
      ::bdi_gui_reports::view_reports ::bdi_tools_reports::data_report
      return
   }
   wm iconify $fen ; wm deiconify $fen



   set curselection [$::bdi_tools_reports::data_report curselection]
   set nb [llength $curselection]
   if { $nb != 1 } {
      gren_erreur "Veuillez selectionner un seul rapport\n"
      return
   }

   set select [lindex $curselection 0]
   set n [$::bdi_tools_reports::data_report size]
   gren_info "$select / $n\n"

   for {set i 0} {$i < $n} {incr i} {
      if {$i == $select} {
         $::bdi_tools_reports::data_report cellconfigure $select,0 -font $bddconf(font,arial_10_b)

         gren_info "OBJ= $::bdi_gui_reports::selected_obj\n"

         set obj   [lindex [$::bdi_tools_reports::data_report get $select] 2]
         set batch [lindex [$::bdi_tools_reports::data_report get $select] 0]
         gren_info "BATCH= $batch\n"

         ::bdi_gui_reports::view_reports_affichage $obj $batch
      } else {
         $::bdi_tools_reports::data_report cellconfigure $i,0 -font $bddconf(font,arial_10)
      }
   }

}



#------------------------------------------------------------
## Affichage des donnees dans la GUI
#  @return void
#
proc ::bdi_gui_reports::affiche_data { } {

   global bddconf

   # Flag pour creer des fichiers de resume
   set savefile "yes"

   set tt0 [clock clicks -milliseconds]

   $::bdi_tools_reports::data_obj       delete 0 end
   $::bdi_tools_reports::data_firstdate delete 0 end
   $::bdi_tools_reports::data_report    delete 0 end

   set wb_obj $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_obj
   set wb_fda $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_fda
   set wb_tot $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_tot
   set wb_nui $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_nui

   # On refait les colonnes en fonction du mode de vue
   $::bdi_tools_reports::data_report deletecolumns 0 end
   $::bdi_tools_reports::data_report configure -columns [::bdi_tools_reports::get_cols_reports_batch]



   # Bouton DATES enfonce
   if {[$wb_fda cget -relief] == "sunken"} {

      #gren_info "choose dates\n"
      if {![info exists ::bdi_tools_reports::list_firstdate]} {return}
      if {[llength $::bdi_tools_reports::list_firstdate]==0} {return}
      set cpt 0
      foreach firstdate $::bdi_tools_reports::list_firstdate {
         $::bdi_tools_reports::data_firstdate insert end $firstdate
         if {[info exists ::bdi_gui_reports::selected_firstdate]} {
            if {$::bdi_gui_reports::selected_firstdate==$firstdate} {
               $::bdi_tools_reports::data_firstdate  cellselection  set $cpt,0 $cpt,end
            }
         }
         incr cpt
      }

      if {[info exists ::bdi_gui_reports::selected_firstdate]} {

         ::bdi_gui_reports::cmdButton1Click_data_firstdate ::bdi_tools_reports::data_firstdate

         if {[info exists ::bdi_gui_reports::selected_obj]} {

            set cpt 0
            foreach objs [$::bdi_tools_reports::data_obj get 0 end] {
               lassign $objs obj num name
               #gren_info "line // $object\n"
               if  { $obj == $::bdi_gui_reports::selected_obj} {
                  $::bdi_tools_reports::data_obj cellselection  set $cpt,0 $cpt,end
               }
               incr cpt
            }
            ::bdi_gui_reports::cmdButton1Click_data_obj ::bdi_tools_reports::data_obj

         }

      }

   }

   # Bouton OBJET enfonce
   if {[$wb_obj cget -relief] == "sunken"} {

      #gren_info "choose objects\n"

      if {![info exists ::bdi_tools_reports::list_obj]} {return}
      if {[llength $::bdi_tools_reports::list_obj]==0} {return}
      set cpt 0
      foreach obj $::bdi_tools_reports::list_obj {
         set n [split $obj "_"]
         set num  [string trim [lindex $n 1]]
         set name [string trim [lrange $n 2 end]]
         
         $::bdi_tools_reports::data_obj insert end [list $obj $num $name]
         if {[info exists ::bdi_gui_reports::selected_obj]} {
            if {$::bdi_gui_reports::selected_obj==$obj} {
               $::bdi_tools_reports::data_obj  cellselection  set $cpt,0 $cpt,end
            }
         }
         incr cpt
      }

      if {[info exists ::bdi_gui_reports::selected_obj]} {

         ::bdi_gui_reports::cmdButton1Click_data_obj ::bdi_tools_reports::data_obj

         if {[info exists ::bdi_gui_reports::selected_firstdate]} {

            set cpt 0
            foreach firstdate [$::bdi_tools_reports::data_firstdate get 0 end] {
               #gren_info "line // $firstdate\n"
               if  { $firstdate == $::bdi_gui_reports::selected_firstdate} {
                  $::bdi_tools_reports::data_firstdate cellselection  set $cpt,0 $cpt,end
               }
               incr cpt
            }
            ::bdi_gui_reports::cmdButton1Click_data_firstdate ::bdi_tools_reports::data_firstdate

         }

      }

   }


   # Bouton NUITEE enfonce
   if {[$wb_nui cget -relief] == "sunken"} {

      if {$savefile=="yes"} {
         set file_resume_reports [file join $bddconf(dirreports) "resume_nuitees.csv"]
         set chan_resume [open $file_resume_reports w]
         puts $chan_resume "firstdate,obj,iau_code,duration,fwhm_mean,fwhm_std,mag_mean,mag_std,mag_amp,mag_prec,ra_mean,ra_std,dec_mean,dec_std,residuals_mean,residuals_std,omc_mean,omc_std,submit_mpc,nb_dates,comment"
      }

      # Affichage
      $::bdi_tools_reports::data_nuitee delete 0 end

      set cpt 0
      foreach firstdate $::bdi_tools_reports::list_firstdate {

         foreach obj $::bdi_tools_reports::tab_obj($firstdate) {

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,iau_code) ]} {
               set iau_code "-"
            } else {
               set iau_code $::bdi_tools_reports::tab_nuitee($obj,$firstdate,iau_code)
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,duration) ]} {
               set duration 0
            } else {
               set duration [format "%.1f" $::bdi_tools_reports::tab_nuitee($obj,$firstdate,duration)]
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,fwhm_mean) ]} {
               set fwhm_mean 0
            } else {
               if {$::bdi_tools_reports::tab_nuitee($obj,$firstdate,fwhm_mean)==""} {
                  set fwhm_mean 0
               } else {
                  set fwhm_mean [format "%.2f" $::bdi_tools_reports::tab_nuitee($obj,$firstdate,fwhm_mean)]
               }
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,fwhm_std) ]} {
               set fwhm_std 0
            } else {
               if {$::bdi_tools_reports::tab_nuitee($obj,$firstdate,fwhm_std)==""} {
                  set fwhm_std 0
               } else {
                  set fwhm_std [format "%.2f" $::bdi_tools_reports::tab_nuitee($obj,$firstdate,fwhm_std)]
               }
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_mean) ]} {
               set mag_mean 0
            } else {
               set mag_mean [format "%.3f" $::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_mean)]
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_std) ]} {
               set mag_std 0
            } else {
               set mag_std [format "%.3f" $::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_std)]
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_amp) ]} {
               set mag_amp 0
            } else {
               set mag_amp [format "%.3f" $::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_amp)]
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_prec) ]} {
               set mag_prec 0
            } else {
               if {$::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_prec)=="-"} {
                  set mag_prec "-"
               } else {
                  set mag_prec [format "%.3f" $::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_prec)]
               }
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,ra_mean) ]} {
               set ra_mean "-"
            } else {
               set ra_mean $::bdi_tools_reports::tab_nuitee($obj,$firstdate,ra_mean)
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,ra_std) ]} {
               set ra_std 0
            } else {
               if {$::bdi_tools_reports::tab_nuitee($obj,$firstdate,ra_std) == ""} {
                  set ra_std 0
               } else {
                  set ra_std [format "%d" $::bdi_tools_reports::tab_nuitee($obj,$firstdate,ra_std)]
               }
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,dec_mean) ]} {
               set dec_mean "-"
            } else {
               set dec_mean $::bdi_tools_reports::tab_nuitee($obj,$firstdate,dec_mean)
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,dec_std) ]} {
               set dec_std 0
            } else {
               if {$::bdi_tools_reports::tab_nuitee($obj,$firstdate,dec_std) == ""} {
                  set dec_std 0
               } else {
                  set dec_std [format "%d" $::bdi_tools_reports::tab_nuitee($obj,$firstdate,dec_std)]
               }
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,residuals_mean) ]} {
               set residuals_mean 0
            } else {
               set residuals_mean [format "%d" $::bdi_tools_reports::tab_nuitee($obj,$firstdate,residuals_mean)]
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,residuals_std) ]} {
               set residuals_std 0
            } else {
               set residuals_std [format "%d" $::bdi_tools_reports::tab_nuitee($obj,$firstdate,residuals_std)]
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,omc_mean) ]} {
               set omc_mean 0
            } else {
               set omc_mean [format "%d" $::bdi_tools_reports::tab_nuitee($obj,$firstdate,omc_mean)]
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,omc_std) ]} {
               set omc_std 0
            } else {
               set omc_std [format "%d" $::bdi_tools_reports::tab_nuitee($obj,$firstdate,omc_std)]
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,photom,submit_mpc) ]} {
               set photom_submit_mpc "no"
            } else {
               set photom_submit_mpc $::bdi_tools_reports::tab_nuitee($obj,$firstdate,photom,submit_mpc)
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,photom,nb_dates) ]} {
               set photom_nb_dates "0"
            } else {
               set photom_nb_dates $::bdi_tools_reports::tab_nuitee($obj,$firstdate,photom,nb_dates)
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,astrom,submit_mpc) ]} {
               set astrom_submit_mpc "no"
            } else {
               set astrom_submit_mpc $::bdi_tools_reports::tab_nuitee($obj,$firstdate,astrom,submit_mpc)
            }

            if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,astrom,nb_dates) ]} {
               set astrom_nb_dates "0"
            } else {
               set astrom_nb_dates $::bdi_tools_reports::tab_nuitee($obj,$firstdate,astrom,nb_dates)
            }

            # Affichage du resultat

            set line [list $firstdate $obj $iau_code $duration $fwhm_mean $fwhm_std $mag_mean $mag_std $mag_amp\
                           $mag_prec $ra_mean $ra_std $dec_mean $dec_std $residuals_mean $residuals_std \
                           $omc_mean $omc_std $photom_submit_mpc $photom_nb_dates $astrom_submit_mpc $astrom_nb_dates ]

            $::bdi_tools_reports::data_nuitee  insert end $line

            if {$savefile=="yes"} {
               puts $chan_resume "$firstdate,$obj,$iau_code,$duration,$fwhm_mean,$fwhm_std,$mag_mean,$mag_std,$mag_amp,$mag_prec,$ra_mean,$ra_std,$dec_mean,$dec_std,$residuals_mean,$residuals_std,$omc_mean,$omc_std,$photom_submit_mpc,$photom_nb_dates,$astrom_submit_mpc,$astrom_nb_dates"
            }


            # Couleurs

#                  if {$photom == "Yes"} {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,18 -bg white -foreground darkgreen
#                  } else {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,18 -bg red -foreground white
#                  }
#                  if {$submit_p == "Yes"} {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,19 -bg white -foreground darkgreen
#                  } else {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,19 -bg white -foreground red
#                  }
#                  if {$nbpts_p > 0} {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,20 -bg white -foreground darkgreen
#                  } else {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,20 -bg red -foreground white
#                  }
#
#                  if {$astrom == "Yes"} {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,21 -bg white -foreground darkgreen
#                  } else {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,21 -bg red -foreground white
#                  }
#                  if {$submit_a == "Yes"} {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,22 -bg white -foreground darkgreen
#                  } else {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,22 -bg white -foreground red
#                  }
#                  if {$nbpts_a > 0} {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,23 -bg white -foreground darkgreen
#                  } else {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,23 -bg red -foreground white
#                  }

            incr cpt
         }

      }

      if {[info exists ::bdi_gui_reports::selected_firstdate]&&[info exists ::bdi_gui_reports::selected_obj] } {

         set cpt 0
         foreach data [$::bdi_tools_reports::data_nuitee get 0 end] {
            set firstdate [lindex $data 0]
            set obj  [lindex $data 1]
            if {$obj  == $::bdi_gui_reports::selected_obj && \
                $firstdate == $::bdi_gui_reports::selected_firstdate } {

               $::bdi_tools_reports::data_nuitee cellselection  set $cpt,0 $cpt,end
            }
            incr cpt
         }

         ::bdi_gui_reports::cmdButton1Click_data_nuitee ::bdi_tools_reports::data_nuitee
      }

      if {$savefile=="yes"} {
         close $chan_resume
      }
   }


   # Bouton TOTAL enfonce
   if {[$wb_tot  cget -relief] == "sunken"} {


      if {$savefile=="yes"} {
         set file_resume_reports [file join $bddconf(dirreports) "resume_total.csv"]
         set chan_resume [open $file_resume_reports w]
         puts $chan_resume "batch,firstdate,obj,type,iau_code,duration,fwhm_mean,fwhm_std,mag_mean,mag_std,mag_amp,mag_prec,ra_mean,ra_std,dec_mean,dec_std,residuals_mean,residuals_std,omc_mean,omc_std,submit_mpc,nb_dates,comment"
      }


      # Affichage
      $::bdi_tools_reports::data_total delete 0 end

      set cpt 0
      foreach firstdate $::bdi_tools_reports::list_firstdate {

         foreach obj $::bdi_tools_reports::tab_obj($firstdate) {

            foreach batch $::bdi_tools_reports::tab_batch($obj,$firstdate) {

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,type) ]} {
                  set type    "-"
               }  else {
                  set type    $::bdi_tools_reports::tab_batch($batch,$obj,type)
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,iau_code) ]} {
                  set iau_code "-"
               } else {
                  set iau_code $::bdi_tools_reports::tab_batch($batch,$obj,iau_code)
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,duration) ]} {
                  set duration 0
               } else {
                  set duration [format "%.1f" $::bdi_tools_reports::tab_batch($batch,$obj,duration)]
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,fwhm_mean) ]} {
                  set fwhm_mean 0
               } else {
                  if {$::bdi_tools_reports::tab_batch($batch,$obj,fwhm_mean)==""} {
                     set fwhm_mean 0
                  } else {
                     set fwhm_mean [format "%.2f" $::bdi_tools_reports::tab_batch($batch,$obj,fwhm_mean)]
                  }
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,fwhm_std) ]} {
                  set fwhm_std 0
               } else {
                  if {$::bdi_tools_reports::tab_batch($batch,$obj,fwhm_std)==""} {
                     set fwhm_std 0
                  } else {
                     set fwhm_std [format "%.2f" $::bdi_tools_reports::tab_batch($batch,$obj,fwhm_std)]
                  }
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,mag_mean) ]} {
                  set mag_mean 0
               } else {
                  set mag_mean [format "%.3f" $::bdi_tools_reports::tab_batch($batch,$obj,mag_mean)]
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,mag_std) ]} {
                  set mag_std 0
               } else {
                  set mag_std [format "%.3f" $::bdi_tools_reports::tab_batch($batch,$obj,mag_std)]
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,mag_amp) ]} {
                  set mag_amp 0
               } else {
                  set mag_amp [format "%.3f" $::bdi_tools_reports::tab_batch($batch,$obj,mag_amp)]
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,mag_prec) ]} {
                  set mag_prec 0
               } else {
                  if {$::bdi_tools_reports::tab_batch($batch,$obj,mag_prec)=="-"} {
                     set mag_prec "-"
                  } else {
                     set mag_prec [format "%.3f" $::bdi_tools_reports::tab_batch($batch,$obj,mag_prec)]
                  }
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,ra_mean) ]} {
                  set ra_mean "-"
               } else {
                  set ra_mean $::bdi_tools_reports::tab_batch($batch,$obj,ra_mean)
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,ra_std) ]} {
                  set ra_std 0
               } else {
                  set ra_std [format "%d" $::bdi_tools_reports::tab_batch($batch,$obj,ra_std)]
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,dec_mean) ]} {
                  set dec_mean "-"
               } else {
                  set dec_mean $::bdi_tools_reports::tab_batch($batch,$obj,dec_mean)
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,dec_std) ]} {
                  set dec_std 0
               } else {
                  set dec_std [format "%d" $::bdi_tools_reports::tab_batch($batch,$obj,dec_std)]
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,residuals_mean) ]} {
                  set residuals_mean 0
               } else {
                  set residuals_mean [format "%d" $::bdi_tools_reports::tab_batch($batch,$obj,residuals_mean)]
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,residuals_std) ]} {
                  set residuals_std 0
               } else {
                  set residuals_std [format "%d" $::bdi_tools_reports::tab_batch($batch,$obj,residuals_std)]
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,omc_mean) ]} {
                  set omc_mean 0
               } else {
                  set omc_mean [format "%d" $::bdi_tools_reports::tab_batch($batch,$obj,omc_mean)]
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,omc_std) ]} {
                  set omc_std 0
               } else {
                  set omc_std [format "%d" $::bdi_tools_reports::tab_batch($batch,$obj,omc_std)]
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,submit_mpc) ]} {
                  set submit_mpc "no"
               } else {
                  set submit_mpc $::bdi_tools_reports::tab_batch($batch,$obj,submit_mpc)
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,nb_dates) ]} {
                  set nb_dates "0"
               } else {
                  set nb_dates $::bdi_tools_reports::tab_batch($batch,$obj,nb_dates)
               }

               if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,comment) ]} {
                  set comment    ""
               }  else {
                  set comment    $::bdi_tools_reports::tab_batch($batch,$obj,comment)
               }

               # Affichage du resultat

               set line [list $batch $firstdate $obj $type $iau_code $duration $fwhm_mean $fwhm_std $mag_mean $mag_std $mag_amp\
                              $mag_prec $ra_mean $ra_std $dec_mean $dec_std $residuals_mean $residuals_std \
                              $omc_mean $omc_std $submit_mpc $nb_dates $comment ]

               $::bdi_tools_reports::data_total insert end $line

               if {$savefile=="yes"} {
                  puts $chan_resume "$batch,$firstdate,$obj,$type,$iau_code,$duration,$fwhm_mean,$fwhm_std,$mag_mean,$mag_std,$mag_amp,$mag_prec,$ra_mean,$ra_std,$dec_mean,$dec_std,$residuals_mean,$residuals_std,$omc_mean,$omc_std,$submit_mpc,$nb_dates,$comment"
               }


               # Couleurs

#                  if {$photom == "Yes"} {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,18 -bg white -foreground darkgreen
#                  } else {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,18 -bg red -foreground white
#                  }
#                  if {$submit_p == "Yes"} {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,19 -bg white -foreground darkgreen
#                  } else {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,19 -bg white -foreground red
#                  }
#                  if {$nbpts_p > 0} {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,20 -bg white -foreground darkgreen
#                  } else {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,20 -bg red -foreground white
#                  }
#
#                  if {$astrom == "Yes"} {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,21 -bg white -foreground darkgreen
#                  } else {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,21 -bg red -foreground white
#                  }
#                  if {$submit_a == "Yes"} {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,22 -bg white -foreground darkgreen
#                  } else {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,22 -bg white -foreground red
#                  }
#                  if {$nbpts_a > 0} {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,23 -bg white -foreground darkgreen
#                  } else {
#                     $::bdi_tools_reports::data_total  cellconfigure $cpt,23 -bg red -foreground white
#                  }

               incr cpt
            }
         }

      }
      $::bdi_tools_reports::data_total sortbycolumn 1 -decreasing

      if {[info exists ::bdi_gui_reports::selected_firstdate]&&[info exists ::bdi_gui_reports::selected_obj] } {

         set cpt 0
         foreach data [$::bdi_tools_reports::data_total  get 0 end] {
            set firstdate [lindex $data 0]
            set obj  [lindex $data 1]
            if {$obj  == $::bdi_gui_reports::selected_obj && \
                $firstdate == $::bdi_gui_reports::selected_firstdate } {

               $::bdi_tools_reports::data_total  cellselection  set $cpt,0 $cpt,end
            }
            incr cpt
         }

         ::bdi_gui_reports::cmdButton1Click_data_total  ::bdi_tools_reports::data_total
      }

      if {$savefile=="yes"} {
         close $chan_resume
      }
   }


   # Fin de visualisation des donnees
   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "Affichage complet en $tt sec \n"

}


proc ::bdi_gui_reports::view_reports_close {  } {

   global conf

   set conf(bddimages,view_reports,geometry) [wm geometry .view_reports]
   destroy .view_reports
}
