   proc ::eye::game_pdf_creation { } {
      
      package require pdf4tcl

      set ::readpdf "/usr/bin/evince"

      set date [string range [mc_date2iso8601 now] 0 9]
      set ::eye::game_pdf_filename [file join $::audace(rep_travail) "${date}_storyboard.pdf"]
      gren_info "File = $::eye::game_pdf_filename \n"

      catch {::mypdf destroy}

      pdf4tcl::new ::mypdf
      ::mypdf startPage -paper a4
      
      ::mypdf setFont 9 Helvetica
      set x 50
      set y 50
      set newligne 12
      set dureetotale 0
      for {set cpt 0} {$cpt<[$::eye::game_tab size]} {incr cpt} {
         lassign [$::eye::game_tab get $cpt] i title status duree last
         set y [expr $y + $newligne]
         set d [lindex [split [string trim $duree] " "] 0]
         if {$d == ""} {set d 0}
         gren_info "$duree / $dureetotale\n"
         set dureetotale [expr $dureetotale + $d]
         ::mypdf text "$i : \[$status\] \[$duree\] $title" -align left -x $x -y $y
      }

      set y [expr $y + $newligne]
      set dureetotale [expr int($dureetotale / 60)]
      ::mypdf text "Duree totale : $dureetotale min" -align left -x $x -y $y
      
      ::mypdf startPage -paper a4

      #::mypdf startPage -paper a4 -landscape 1

   }
