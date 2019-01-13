

# source [ file join $audace(rep_plugin) tool bddimages utils astroid statistics.tcl]

namespace eval ::statbox {

proc ::statbox::clear { frm } {

      set ::statbox::nb     ""
      set ::statbox::min    ""
      set ::statbox::max    ""
      set ::statbox::mean   ""
      set ::statbox::stdev  ""
      set ::statbox::median ""
      set ::statbox::var    ""

      $frm.values delete 1.0 end

}

proc ::statbox::statgo { frm } {
      
      package require math::statistics
      
      set values [split [$frm.values get 1.0 end] "\n" ]
      gren_info "$values\n"

      set nb 0
      set vals ""
      foreach line $values {
         if {[string bytelength [string trim $line]]==0} {continue}
         lappend vals [string trim $line]
      }
      
      set ::statbox::nb     [llength $vals]
      set ::statbox::min    [::math::statistics::min $vals]
      set ::statbox::max    [::math::statistics::max $vals]
      set ::statbox::mean   [::math::statistics::mean $vals]
      set ::statbox::stdev  [::math::statistics::stdev $vals]
      set ::statbox::median [::math::statistics::median $vals]
      set ::statbox::var    [::math::statistics::var $vals]
      
      return

#::math::statistics::min 
#::math::statistics::max 
#::math::statistics::mean
#::math::statistics::stdev
#::math::statistics::median
#::math::statistics::var

}

proc ::statbox::close { fen } {
      destroy $fen
}

proc ::statbox::go {  } {

   global bddconf
   global audace

      #--- Creation de la fenetre
      set fen .statbox
      if { [winfo exists $fen] } {
         wm withdraw $fen
         wm deiconify $fen
         focus $fen
         return
      }
      toplevel $fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $fen ] "+" ] 2 ]
      wm geometry $fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $fen 1 1
      wm title $fen "Binast Box"
      wm protocol $fen WM_DELETE_WINDOW "destroy $fen"
      set frm $fen.frm

      #--- Cree un frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $fen -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


           text $frm.values -width 30 -height 10 
           pack $frm.values -side top -padx 3 -pady 1 -fill x

           frame $frm.buttons -borderwidth 0 -cursor arrow -relief groove
           pack $frm.buttons -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                button $frm.buttons.go -text "Go" -borderwidth 1 -takefocus 1 -command "::statbox::statgo $frm" 
                pack $frm.buttons.go -side left -anchor e -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0

                button $frm.buttons.clear -text "Clear" -borderwidth 1 -takefocus 1 -command "::statbox::clear $frm" 
                pack $frm.buttons.clear -side left -anchor e -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0

                button $frm.buttons.close -text "Close" -borderwidth 1 -takefocus 1 -command "::statbox::close $fen" 
                pack $frm.buttons.close -side right -anchor e -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0

           frame $frm.nb 
           pack $frm.nb -in $frm -side top
           
              label $frm.nb.lab -text "Nb : " -width 5
              pack  $frm.nb.lab -side left -padx 5 -pady 0
              entry $frm.nb.res -textvariable ::statbox::nb
              pack  $frm.nb.res -side left -padx 5 -pady 0

           frame $frm.min 
           pack $frm.min -in $frm -side top
           
              label $frm.min.lab -text "min : " -width 5
              pack  $frm.min.lab -side left -padx 5 -pady 0
              entry $frm.min.res -textvariable ::statbox::min
              pack  $frm.min.res -side left -padx 5 -pady 0

           frame $frm.max 
           pack $frm.max -in $frm -side top
           
              label $frm.max.lab -text "max : " -width 5
              pack  $frm.max.lab -side left -padx 5 -pady 0
              entry $frm.max.res -textvariable ::statbox::max
              pack  $frm.max.res -side left -padx 5 -pady 0

           frame $frm.mean 
           pack $frm.mean -in $frm -side top
           
              label $frm.mean.lab -text "Mean : " -width 5
              pack  $frm.mean.lab -side left -padx 5 -pady 0
              entry $frm.mean.res -textvariable ::statbox::mean
              pack  $frm.mean.res -side left -padx 5 -pady 0

           frame $frm.stdev 
           pack $frm.stdev -in $frm -side top
           
              label $frm.stdev.lab -text "stdev : " -width 5
              pack  $frm.stdev.lab -side left -padx 5 -pady 0
              entry $frm.stdev.res -textvariable ::statbox::stdev
              pack  $frm.stdev.res -side left -padx 5 -pady 0

           frame $frm.median 
           pack $frm.median -in $frm -side top
           
              label $frm.median.lab -text "median : " -width 5
              pack  $frm.median.lab -side left -padx 5 -pady 0
              entry $frm.median.res -textvariable ::statbox::median
              pack  $frm.median.res -side left -padx 5 -pady 0

           frame $frm.var 
           pack $frm.var -in $frm -side top
           
              label $frm.var.lab -text "var : " -width 5
              pack  $frm.var.lab -side left -padx 5 -pady 0
              entry $frm.var.res -textvariable ::statbox::var
              pack  $frm.var.res -side left -padx 5 -pady 0


              
}



}

