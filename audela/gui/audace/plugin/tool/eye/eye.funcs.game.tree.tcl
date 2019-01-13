
   proc ::eye::game_tree_view_all { } {

      
      set fen .game_tree
      if {[winfo exists $fen]} {
         destroy $fen
      }
      toplevel $fen -class Toplevel
      wm geometry $fen 1117x530+0+0
      wm focusmodel $fen passive
      wm overrideredirect $fen 0
      wm resizable $fen 1 1
      wm deiconify $fen
      wm title $fen "Arbre decisionnel"
      #bind $fen <Destroy> { ::main_gui::closewindow ; exit}
      wm protocol $fen WM_DELETE_WINDOW "destroy $fen"
      wm withdraw .
      focus -force $fen

      set frm $fen.frm

      #--- Cree le frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $fen -anchor s -side top -expand yes -fill both  -padx 10 -pady 5
         
         set width 4000
         set height 4000

         set hscroll $frm.hscroll
         set vscroll $frm.vscroll

         set ::eye::game_can [canvas $frm.chart -width $width -height $height -bd 1 -relief groove \
                              -xscrollcommand "$hscroll set" \
                              -yscrollcommand "$vscroll set"]
             

         scrollbar $hscroll -orient horiz -command "$::eye::game_can xview"
         scrollbar $vscroll               -command "$::eye::game_can yview"


         pack $hscroll -side bottom -fill x
         pack $vscroll -side right  -fill y
         
         pack $::eye::game_can -side top -anchor c

         $::eye::game_can create line 0 0 0      $height  -fill grey -tag "border"
         $::eye::game_can create line 0 0 $width 0        -fill grey -tag "border"
         $::eye::game_can configure -scrollregion [$::eye::game_can bbox all]
      
      ::eye::game_pdf_creation
      ::eye::game_lecture_arbre
      
      
   }

proc ::eye::game_focus_key { key } {
   
      set fen .game_tree
      gren_info "winfo exists [winfo exists $fen]\n"
      
      set ix1 0; set ix2 0 ;
      set iy1 0; set iy2 0 ;

      foreach item [$::eye::game_can find all] {
          
          #gren_info "  -- item $item\n"
          
          set ekey [$::eye::game_can gettags $item]
          if {$ekey != $key } {continue}
          gren_info "  -- ekey $ekey\n"
          
          set coords  [$::eye::game_can coords $item]
          set tt      [lindex [$::eye::game_can gettags $item] 0]
          gren_info "  -- items coords $tt ::    $coords\n"
          foreach {x y} $coords {                    
              if { $x < $ix1 } {set ix1 $x}
              if { $x > $ix2 } {set ix2 $x}
              if { $y < $iy1 } {set iy1 $y}
              if { $y > $iy1 } {set iy2 $y}
          }
      }
      set iy1 [expr $iy1 - 100]
      set iy2 [expr $iy2 - 100]
      gren_info "  -- ix1 iy1 ix2 iy2 ::   $ix1 $iy1 $ix2 $iy2\n" 
      
      # calculate x and y scrollregion
      foreach {sx1 sy1 sx2 sy2} [$::eye::game_can cget -scrollregion] break
      set xregion [expr {$sx2-$sx1}]
      set yregion [expr {$sy2-$sy1}]
      gren_info "  -- xregion $xregion, yregion $yregion\n" 
     
      # calculate x and y ratio !!!!!!!!!!!!!!!!!
      set xratio  [expr {$ix2/$xregion}]
      set yratio  [expr {$iy2/$yregion}]
      gren_info "  -- xratio $xratio, yratio $yratio\n"

      $::eye::game_can xview moveto $xratio
      $::eye::game_can yview moveto $yratio
      
   return

}





