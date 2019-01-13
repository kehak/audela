# * Initial author : Fred Vachier <fv@imcce.fr>
#   avec l aide et conseil de Alain KLOTZ <alain.klotz@free.fr>

# source /srv/develop/audela/src/libtel/libeqmod/extra/src/lowlevel_funcs.tcl
# source [file join $audace(rep_install) src libtel libeqmod extra src eqmod_move.tcl]

namespace eval eqmod_move {



   proc ::eqmod_move::move_to_north_pole_counterweight_bottom { } {
      ::eqmod::move_to_coord_celestial -90 90
      return 0
   }

   proc ::eqmod_move::move_to_north_pole_counterweight_east { } {
      ::eqmod::move_to_coord_celestial -180 90
      return 0
   }

   proc ::eqmod_move::move_to_north_pole_counterweight_west { } {
      ::eqmod::move_to_coord_celestial 0 90
      return 0
   }

   proc ::eqmod_move::move_to_east_counterweight_top { } {
      ::eqmod::move_to_coord_celestial -90 0
      return 0
   }

   proc ::eqmod_move::move_to_east_counterweight_bottom { } {
      ::eqmod::move_to_coord_celestial 90 180
      return 0
   }

   proc ::eqmod_move::move_to_west_counterweight_top { } {
      ::eqmod::move_to_coord_celestial -90 180
      return 0
   }

   proc ::eqmod_move::move_to_west_counterweight_bottom { } {
      ::eqmod::move_to_coord_celestial 90 0
      return 0
   }

   proc ::eqmod_move::move_to_south { } {
      set l [lindex $::eqmod::home 3]
      set d [expr $l -90]
      ::eqmod::move_to_coord_celestial 0 $d
      return 0
   }

   proc ::eqmod_move::move_to_zenith { } {
      set l [lindex $::eqmod::home 3]
      ::eqmod::move_to_coord_celestial 0 $l
      return 0
   }

   proc ::eqmod_move::move_to_north { } {
      set l [lindex $::eqmod::home 3]
      set d [expr $l + 90]
      ::eqmod::move_to_coord_celestial 0 $d
      return 0
   }

   proc ::eqmod_move::move_to_equator_south { } {
      ::eqmod::move_to_coord_celestial 0 0
      return 0
   }

   proc ::eqmod_move::move_to_equator_south_m1H { } {
      ::eqmod::move_to_coord_celestial -15 0
      return 0
   }
   proc ::eqmod_move::move_to_equator_south_p1H { } {
      ::eqmod::move_to_coord_celestial 15 0
      return 0
   }

   proc ::eqmod_move::diurnal_motion { a } {
   
      if {$a=="start"} {
         tel$::eqmod::telno put :K1
         tel$::eqmod::telno put :G110
         tel$::eqmod::telno put :I16C0200
         tel$::eqmod::telno put :J1
      }
      if {$a=="stop"} {
         tel$::eqmod::telno put :K1
         after 50
      }
   }



   proc ::eqmod_move::move_to_coord_equatorial { ra_deg dec_deg } {

      set r       [::eqmod::coord_equatorial_to_hour $ra_deg $dec_deg]
      set h_deg   [lindex $r 0]
      set dec_deg [lindex $r 1]
      
      ::eqmod::move_to_coord_celestial $h_deg $dec_deg

   }


}
