#------------------------------------------------------------
## Deplacement sur l axe des Y en se basant sur les moyennes 
#  par paquet fournit par la solution.
#  @return void
#
proc ::bdi_gui_analysis::ymov_manual { } {

   global bddconf


   set ::bdi_gui_analysis::fenym .bdi_ymov_manual
   if { [winfo exists $::bdi_gui_analysis::fenym] } {
      wm withdraw $::bdi_gui_analysis::fenym
      wm deiconify $::bdi_gui_analysis::fenym
      focus $::bdi_gui_analysis::fenym
      return
   }

   toplevel $::bdi_gui_analysis::fenym -class Toplevel
   if {[ info exists bddconf(analysis_ymov_manual,geometry)]} {
      wm geometry $::bdi_gui_analysis::fenym $bddconf(analysis_ymov_manual,geometry)
   }
   wm resizable $::bdi_gui_analysis::fenym 1 1
   wm title $::bdi_gui_analysis::fenym "Analyse"
   wm protocol $::bdi_gui_analysis::fenym WM_DELETE_WINDOW "::bdi_gui_analysis::ymov_manual_close"

   set frm [frame $::bdi_gui_analysis::fenym.appli -borderwidth 1 -cursor arrow -relief groove]
   grid $frm -in $::bdi_gui_analysis::fenym -sticky news

      set actions [frame $frm.actions  -borderwidth 0 -cursor arrow -relief groove]
      grid $actions  -in $frm -sticky news 

         button $actions.recharge -text "Recharge" -borderwidth 2 -takefocus 1 -relief "raised" \
                     -command "::bdi_gui_analysis::ymov_manual_reload"
         grid $actions.recharge -in $actions -sticky news 

      set frmpk [TitleFrame $frm.pack -borderwidth 2 -text "Selection des donnees"]
      grid $frmpk -in $frm -sticky news 


         array unset data_pack
         set list_pack ""
         set all_res ""
         foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
            set id  [lindex $r 0]
            set pck $::bdi_gui_analysis::widget(data,$id,pack)
            lappend list_pack $pck
         } 
         set list_pack [lsort -uniq $list_pack]

         foreach pck $list_pack {
           gren_info "pack : $pck\n"

           button $frmpk.pck$pck -text "Pack $pck" -borderwidth 2 -takefocus 1 -relief "raised" \
                       -command "::bdi_gui_analysis::ymov_manual_select_pack $pck"
           grid $frmpk.pck$pck -in [$frmpk getframe] -sticky news 

         } 

      set frmof [TitleFrame $frm.offset -borderwidth 2 -text "Offset"]
      grid $frmof -in $frm -sticky news 

         button $frmof.selpck -text "Pack ->" -borderwidth 2 -takefocus 1 -relief "raised" \
                     -command "::bdi_gui_analysis::ymov_manual_grab_y 0"
         entry  $frmof.pck     -textvariable ::bdi_gui_analysis::widget(data,pack,offset0)  -width 15 -justify center
         button $frmof.selref -text "Ref ->" -borderwidth 2 -takefocus 1 -relief "raised" \
                     -command "::bdi_gui_analysis::ymov_manual_grab_y 1"
         entry  $frmof.ref     -textvariable ::bdi_gui_analysis::widget(data,pack,offset1)  -width 15 -justify center
         button $frmof.clear -text "C" -borderwidth 2 -takefocus 1 -relief "raised" \
                     -command "::bdi_gui_analysis::ymov_manual_clear"
         button $frmof.apply -text "Apply" -borderwidth 2 -takefocus 1 -relief "raised" \
                     -command "::bdi_gui_analysis::ymov_manual_apply"
         entry  $frmof.offset  -textvariable ::bdi_gui_analysis::widget(data,pack,offset)  -width 15 -justify center

         grid $frmof.selpck -in [$frmof getframe] -sticky news -row 0 -column 0
         grid $frmof.pck    -in [$frmof getframe] -sticky news -row 0 -column 1
         grid $frmof.selref -in [$frmof getframe] -sticky news -row 0 -column 2
         grid $frmof.ref    -in [$frmof getframe] -sticky news -row 0 -column 3
         grid $frmof.clear  -in [$frmof getframe] -sticky news -row 1 -column 0 
         grid $frmof.apply  -in [$frmof getframe] -sticky news -row 1 -column 1 -columnspan 2
         grid $frmof.offset -in [$frmof getframe] -sticky news -row 1 -column 3
         

   return
}
proc ::bdi_gui_analysis::ymov_manual_clear {  } {
   set ::bdi_gui_analysis::widget(data,pack,offset0) ""
   set ::bdi_gui_analysis::widget(data,pack,offset1) ""
   set ::bdi_gui_analysis::widget(data,pack,offset) ""
   return
}
proc ::bdi_gui_analysis::ymov_manual_apply {  } {
   
   foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
      set id  [lindex $r 0]
      if {$::bdi_gui_analysis::widget(data,$id,pack) in $::bdi_gui_analysis::widget(data,pack,selected)} {
         set ::bdi_gui_analysis::widget(data,$id,raw) [expr $::bdi_gui_analysis::widget(data,$id,raw) + $::bdi_gui_analysis::widget(data,pack,offset)]
      }
   }

   ::bdi_gui_analysis::ymov_manual_clear 
   ::bdi_gui_analysis::graph
   
   return
}

proc ::bdi_gui_analysis::ymov_manual_grab_y { c } {
   set err [ catch {set rect [::plotxy::get_selected_region]} msg]
   gren_info "rect = $rect\n"
   gren_info "err  = $err\n"
   gren_info "msg = $msg\n"
   
   if {$err==0} {
      set ymin [lindex $rect 1]
      set ymax [lindex $rect 3]
      set o [format "%0.3f" [expr ($ymin + $ymax)/ 2.0] ]
   
      if { $c == 0 } {
         set ::bdi_gui_analysis::widget(data,pack,offset0) $o
      }
      if { $c == 1 } {
         set ::bdi_gui_analysis::widget(data,pack,offset1) $o
      }
      
      if {$::bdi_gui_analysis::widget(data,pack,offset0) != "" && $::bdi_gui_analysis::widget(data,pack,offset1) != ""} {
        set ::bdi_gui_analysis::widget(data,pack,offset) [format "%+0.3f" [expr $::bdi_gui_analysis::widget(data,pack,offset1)-$::bdi_gui_analysis::widget(data,pack,offset0)]]
      }
   }
   return
}

# 11.6745
proc ::bdi_gui_analysis::ymov_manual_close { } {
   global bddconf
   set bddconf(analysis_ymov_manual,geometry) [wm geometry $::bdi_gui_analysis::fenym]
   destroy $::bdi_gui_analysis::fenym
   return
}



proc ::bdi_gui_analysis::ymov_manual_reload { } {
   ::bdi_gui_analysis::ymov_manual_close
   ::bdi_gui_analysis::ymov_manual
   return
}




proc ::bdi_gui_analysis::ymov_manual_select_pack { pck } {

   set frm $::bdi_gui_analysis::fenym.appli.pack.pck$pck
   
   gren_info "$frm configure\n"
   gren_info "[$frm configure]\n"
   
   set color [lindex [split [$frm configure -background]] end]
   if {$color == "#d9d9d9"} {
      $frm configure -background #4EDC4A
      set select "select"
   } else {
      $frm configure -background #d9d9d9
      set select "unselect"
   }
   
   if {$select == "select"} {
      lappend ::bdi_gui_analysis::widget(data,pack,selected) $pck
      set ::bdi_gui_analysis::widget(data,pack,selected) [lsort -uniq $::bdi_gui_analysis::widget(data,pack,selected)]
   } else {
      set l ""
      foreach p $::bdi_gui_analysis::widget(data,pack,selected) {
         if {$p != $pck} {
            lappend l $p
         }
      }
      set ::bdi_gui_analysis::widget(data,pack,selected) $l
   }
   
   ::bdi_gui_analysis::graph
   return
}
