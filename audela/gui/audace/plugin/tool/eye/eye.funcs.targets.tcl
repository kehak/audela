   proc ::eye::targets_perso { } {
      
      
      global audace
      set fen .targets_perso
      if { [winfo exists $fen] } {
         ::eye::targets_perso_load
         wm withdraw $fen
         wm deiconify $fen
         focus $fen
         return
      }
      toplevel $fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $fen ] "+" ] 2 ]

      wm geometry $fen "680x240+[expr $posx_config + 0]+[expr $posy_config + 371]"
      wm resizable $fen 1 1
      wm title $fen "Catalogue personnalisé"
      wm protocol $fen WM_DELETE_WINDOW "destroy $fen"

      set frm $fen.appli

      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

         frame $frm.champs -borderwidth 0 -cursor arrow -relief groove
         pack $frm.champs -in $frm -anchor s -side top -expand 1 -fill both -padx 10 -pady 5
            
               label  $frm.champs.lnm  -text "Name : " 
               entry  $frm.champs.vnm  -textvariable name -width 20
               label  $frm.champs.lra  -text "Ra : " 
               entry  $frm.champs.vra  -textvariable ra -width 12
               label  $frm.champs.lde  -text "Dec : " 
               entry  $frm.champs.vde  -textvariable dec -width 12
               label  $frm.champs.lma  -text "Mag : "
               entry  $frm.champs.vma  -textvariable mag -width 5
               Button $frm.champs.add   -text "+" -command "::eye::targets_add name ra dec mag"
            
            grid $frm.champs.lnm $frm.champs.vnm $frm.champs.lra $frm.champs.vra \
                 $frm.champs.lde $frm.champs.vde $frm.champs.lma $frm.champs.vma $frm.champs.add -in $frm.champs -sticky nws


         set liste [frame $frm.lst  -borderwidth 1 -relief groove]
         pack $liste -in $frm -expand yes -fill both

         set cols [list 0  "Id"            right \
                        0  "Name"          left  \
                        0  "RaJ2000"       left  \
                        0  "DecJ2000"      left  \
                        0  "Mag"           left  \
                  ]

         set ::eye::table_targets_perso $liste.tab
         tablelist::tablelist $::eye::table_targets_perso \
            -columns $cols \
            -labelcommand tablelist::sortByColumn \
            -yscrollcommand [ list $liste.vsb set ] \
            -selectmode extended \
            -activestyle none \
            -stripebackground "#e0e8f0" \
            -showseparators 1

         scrollbar $liste.vsb -orient vertical -command [list $::eye::table_targets_perso yview]
         pack $liste.vsb -in $liste -side left -fill y


         menu $liste.popupTbl -title "Actions"
         $liste.popupTbl add command -label "Supprime entree" \
             -command "::eye::targets_del "

         bind [$::eye::table_targets_perso bodypath] <ButtonPress-3> [ list tk_popup $liste.popupTbl %X %Y ]
         bind [$::eye::table_targets_perso bodypath] <Double-1> [list ::eye::targets_select]
         pack $::eye::table_targets_perso -in $liste -expand yes -fill both

         $::eye::table_targets_perso columnconfigure 0 -sortmode dictionary
         $::eye::table_targets_perso columnconfigure 1 -sortmode dictionary
         $::eye::table_targets_perso columnconfigure 2 -sortmode dictionary
         $::eye::table_targets_perso columnconfigure 3 -sortmode dictionary
         $::eye::table_targets_perso columnconfigure 4 -sortmode dictionary

      ::eye::targets_perso_load
   
      return 0
   }






# ::eye::ressource ; ::eye::targets_perso_load
# "StarOcc Chariklo 2016-08-08" 18h18m03.6927s -33d52m28.392s 14.3

   proc ::eye::targets_perso_load { } {

      global audace

      $::eye::table_targets_perso delete 0 end
      
      set userfile [file join $audace(rep_home) eye.conf]
      
      if {![file exists $userfile]} {
         set f [open $userfile "w"]
         close $f
         return
      }

      set f [open $userfile "r"]
      set id 0
      while {![eof $f]} {
         set l [gets $f]
         
         
         if {$l!=""} {
            incr id

            set lf [list $id]
            foreach x $l {
               set lf [linsert $lf end $x]
            }
         
            $::eye::table_targets_perso insert end $lf
         }
      }
      
      close $f
      
      
      #$::eye::table_targets_perso insert end [list 1 "StarOcc Daphne 2016-01-17" "04h26m25.9s" "+01d40m43.2s" "9.7"]
      
   }
   








   proc ::eye::targets_add { p_name p_ra p_dec p_mag} {

      global audace

      upvar $p_name name
      upvar $p_ra   ra
      upvar $p_dec  dec
      upvar $p_mag  mag

      gren_info "$name $ra $dec $mag\n"
      
      if {$name in [$::eye::table_targets_perso columncget 1 -text]} {
         gren_info "$name existe dans la table\n"
         return
      }
      
      set userfile [file join $audace(rep_home) eye.conf]
      set f [open $userfile a]
      puts $f "{$name} $ra $dec $mag"
      close $f
      ::eye::targets_perso_load 
      
   
      return 0
   }









   proc ::eye::targets_del { } {

      global audace

      set msg "Etes vous sur de vouloir supprimer:\n"
      set ltodel ""
      foreach select [$::eye::table_targets_perso curselection] {
        set name [lindex [$::eye::table_targets_perso get $select] 1]
        append msg "$name\n"
        lappend ltodel $name
      }
      
      set r [tk_messageBox -message $msg -type yesno]
      
      if {$r == "no"} {return}
      
      set completelist [$::eye::table_targets_perso get 0 end]
      
      set userfile [file join $audace(rep_home) eye.conf]
      set f [open $userfile w]

      foreach x $completelist {
         set name [lindex $x 1]
         set ra   [lindex $x 2]
         set dec  [lindex $x 3]
         set mag  [lindex $x 4]
         if {$name in $ltodel} {continue}
         gren_info "$name $ra $dec $mag\n"
         puts $f "{$name} $ra $dec $mag"
      }
      close $f
      ::eye::targets_perso_load 
      
      return 0
   }



   proc ::eye::targets_select { } {

      foreach select [$::eye::table_targets_perso curselection] {
        set ::eye::widget(coord,wanted,raJ2000)   [lindex [$::eye::table_targets_perso get $select] 2]
        set ::eye::widget(coord,wanted,decJ2000)  [lindex [$::eye::table_targets_perso get $select] 3]
        break
      }
      destroy .targets_perso
      return 0
   }

