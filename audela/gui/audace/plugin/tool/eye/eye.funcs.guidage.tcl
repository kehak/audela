   proc todo {

      # Trace du repere E/N dans l'image
      set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set cdelt1 [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
      set cdelt2 [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
      ::gui_cata::trace_repere [list $cdelt1 $cdelt2]
      unset tabkey cdelt1 cdelt2

      # Trace reticule
      # dans bdi_gui_cata.tcl
      ::gui_cata::trace_reticule


      # Trace repere
      # dans bdi_gui_cata.tcl
      ::gui_cata::trace_reticule
   
   }
