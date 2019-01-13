#------------------------------------------------------------
## Definit un objet MATRIX comme etant l horizon local
# @return void
#
proc ::tools_planif::define_horizon_telescope {  } {

   package require math::interpolate
   
   # Pour detruire la Matrix : 
   # ::math::interpolate::__horizon destroy
   
   set ::tools_planif::horizon [::math::interpolate::defineTable horizon {az h} { 0 7
              10 7
              73.0785634225 7.19977623252
              83.4601765356 7.8236793082 
              109.296924563 11.351195867 
              126.268399581 12.1853538808 
              135.779989225 17.868953926 
              133.496333576 31.4866605585 
              180 47.8 
              225.904984595 31.9682879441 
              234.840374417 19.6489977001 
              241.0815867 20.0755101709 
              253.240653979 20.7078231797 
              260.05325643 22.78 
              270.260073544 20.0950778366 
              280.174162716 21.3693603376 
              289.72525419 22.1055412469 
              300.346630227 17.8451185263 
              313.115512904 18.6258585161 
              314.087509714 14.7424445164 
              324.920524708 11.3308648969 
              350.630124497 19.2664467308 
              360 7 } ]

}


#------------------------------------------------------------
## Definit un objet MATRIX comme etant l horizon local
# @return bool : 1 l objet est visible, 0 sinon
#
proc ::tools_planif::horizon_telescope { az h } {

   lassign [::math::interpolate::interp-1d-table $::tools_planif::horizon $az] az hh
   if {$h > $hh} {
      return 1
   } else {
      return 0
   }

}

