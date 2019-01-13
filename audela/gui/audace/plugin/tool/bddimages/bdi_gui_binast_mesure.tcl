#------------------------------------------------------------
## Procedure lance la mesure du photocentre
#  @return void
proc ::bdi_gui_binast::box_mesure_differentielle { date compo orig } {

   set pi [::pi]
   #gren_info "box_mesure_differentielle: $date,$compo\n"
   #gren_info "test: $::bdi_gui_binast::widget(data,listref,$date,$compo)\n"
 
   # Verifie si la compo n est pas une reference
   
   if {$compo == ""} {return}
   if {$::bdi_gui_binast::widget(data,listref,$date,$compo)!=""} return

   #gren_info "test: ok\n"
    
   # Determination de la reference
   set compo_ref ""
   foreach  cpo $::bdi_gui_binast::widget(table,compos,list)  {
      if {$::bdi_gui_binast::widget(data,listref,$date,$cpo)=="x"} {
         set compo_ref $cpo
         break
      }
   }
   gren_info "set date $date\n"
   gren_info "set orig $orig\n"
   gren_info "set compo_ref $compo_ref\n"
   gren_info "set compo $compo\n"

   # Verification qu on a bien une reference
   if {$compo_ref == ""} return

   # Verification que la reference a bien ete mesuree
   if {![info exists ::bdi_gui_binast::widget(data,$date,$compo_ref,psf,xsm)] || 
       ![info exists ::bdi_gui_binast::widget(data,$date,$compo_ref,psf,ysm)] || 
       ![info exists ::bdi_gui_binast::widget(data,$date,$compo_ref,psf,err_xsm)] || 
       ![info exists ::bdi_gui_binast::widget(data,$date,$compo_ref,psf,err_ysm)] } return
   set xrpix $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,xsm)
   set yrpix $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,ysm)
   set xrerr $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,err_xsm)
   set yrerr $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,err_ysm)
   if {$xrpix == "" || $yrpix == "" || $xrerr == "" || $yrerr == "" } return

   # Verification que la compo a bien ete mesuree
   set xcpix ""
   set ycpix ""
   set xcerr ""
   set ycerr ""
   if {$orig=="mesure"} {
      if {![info exists ::bdi_gui_binast::widget(mesure,xsm)] || 
          ![info exists ::bdi_gui_binast::widget(mesure,ysm)] || 
          ![info exists ::bdi_gui_binast::widget(mesure,err_xsm)] || 
          ![info exists ::bdi_gui_binast::widget(mesure,err_ysm)] } return
      set xcpix $::bdi_gui_binast::widget(mesure,xsm)
      set ycpix $::bdi_gui_binast::widget(mesure,ysm)
      set xcerr $::bdi_gui_binast::widget(mesure,err_xsm)
      set ycerr $::bdi_gui_binast::widget(mesure,err_ysm)
   }
   if {$orig=="data"} {
      if {![info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,xsm)] || 
          ![info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,ysm)] || 
          ![info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,err_xsm)] || 
          ![info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,err_ysm)] } return
      set xcpix $::bdi_gui_binast::widget(data,$date,$compo,psf,xsm)
      set ycpix $::bdi_gui_binast::widget(data,$date,$compo,psf,ysm)
      set xcerr $::bdi_gui_binast::widget(data,$date,$compo,psf,err_xsm)
      set ycerr $::bdi_gui_binast::widget(data,$date,$compo,psf,err_ysm)
   }
   if {$xcpix == "" || $ycpix == "" || $xcerr == "" || $ycerr == "" } return
   if {$xcpix == "-" || $ycpix == "-" || $xcerr == "-" || $ycerr == "-" } return

   # Calculs            
   set adr [buf1 xy2radec [list $xrpix $yrpix] ]
   set adc [buf1 xy2radec [list $xcpix $ycpix] ]
   lassign $adr ar dr
   lassign $adc ac dc
   set dx [expr ($ac-$ar)*cos($dr*$pi/180.0)*3600000.0]
   set dy [expr ($dc-$dr)*3600000.0]
   set dr [expr sqrt(pow($dx,2)+pow($dy,2))]
   
   set ex [expr sqrt( pow($xcerr,2) + pow($xrerr,2) ) * abs($::bdi_gui_binast::widget(data,$date,xscale))]
   set ey [expr sqrt( pow($ycerr,2) + pow($yrerr,2) ) * abs($::bdi_gui_binast::widget(data,$date,yscale))]
   set er [expr sqrt( pow($ex,2) + pow($ey,2) )]
   
   set dx [format "%.1f" $dx ]
   set dy [format "%.1f" $dy ]
   set ex [format "%.1f" $ex ]
   set ey [format "%.1f" $ey ]  
   set dr [format "%.1f" $dr ]  
   set er [format "%.1f" $er ]
    
   # Positions & Erreurs derivees
   set ::bdi_gui_binast::widget(mesure,dx)      $dx
   set ::bdi_gui_binast::widget(mesure,dy)      $dy
   set ::bdi_gui_binast::widget(mesure,err_dx)  $ex
   set ::bdi_gui_binast::widget(mesure,err_dy)  $ey
   set ::bdi_gui_binast::widget(mesure,rho)     $dr
   set ::bdi_gui_binast::widget(mesure,err_rho) $er

   gren_info "Mesure de $compo % a $compo_ref\n"
   gren_info "Xscale = $::bdi_gui_binast::widget(data,$date,xscale)\n"
   gren_info "Yscale = $::bdi_gui_binast::widget(data,$date,yscale)\n"
   gren_info "DX = [format "%10.1f" $dx ] +- [format "%10.1f" $ex ]\n"
   gren_info "DY = [format "%10.1f" $dy ] +- [format "%10.1f" $ey ]\n"

   return
}



   #------------------------------------------------------------
   ## Procedure lance la mesure du photocentre
   #  @return void
   proc ::bdi_gui_binast::box_mag_compo { date compo } {

      # Existance de la mesure
      if { ! [info exists ::bdi_gui_binast::widget(mesure,flux)    ] } { return }
      if { ! [info exists ::bdi_gui_binast::widget(mesure,err_flux)] } { return }
      if { $::bdi_gui_binast::widget(mesure,flux)     == "-" } { return }
      if { $::bdi_gui_binast::widget(mesure,err_flux) == "-" } { return }
      if { $::bdi_gui_binast::widget(mesure,err_flux) > $::bdi_gui_binast::widget(mesure,flux) } { return }

      # Init
      set flux_total 0
      set flux_total_max 0
      set flux_total_min 0

      if { [info exists ::bdi_gui_binast::widget(data,ephem,$date,mag,barycentre)] } {
         set mag_bary $::bdi_gui_binast::widget(data,ephem,$date,mag,barycentre)
      } else {
         set mag_bary 0
      }

      # Selection de la reference
      set compo_ref ""
      foreach  cpo $::bdi_gui_binast::widget(table,compos,list)  {
         if {$::bdi_gui_binast::widget(data,listref,$date,$cpo)=="x"} {
            set compo_ref $cpo
            break
         }
      }
      if {$compo_ref == ""} {
         gren_erreur "Pas de compo ref\n" 
         return
      }

      # Calcul des flux totaux du barycentre (valeur, min et max)
      foreach  cpo $::bdi_gui_binast::widget(table,compos,list)  {
         if { $cpo == $compo } {
            set flux_total     [expr $flux_total     + $::bdi_gui_binast::widget(mesure,flux) ]
            set flux_total_max [expr $flux_total_max + $::bdi_gui_binast::widget(mesure,flux) + $::bdi_gui_binast::widget(mesure,err_flux)]
            set flux_total_min [expr $flux_total_min + $::bdi_gui_binast::widget(mesure,flux) - $::bdi_gui_binast::widget(mesure,err_flux)]
         } else {
            if { ! [info exists ::bdi_gui_binast::widget(data,$date,$cpo,psf,flux)]     } { continue }
            if { $::bdi_gui_binast::widget(data,$date,$cpo,psf,flux) == ""  } { continue }
            set flux_total     [expr $flux_total     + $::bdi_gui_binast::widget(data,$date,$cpo,psf,flux) ]
            if { ! [info exists ::bdi_gui_binast::widget(data,$date,$cpo,psf,err_flux)] } { continue }
            set flux_total_max [expr $flux_total_max + $::bdi_gui_binast::widget(data,$date,$cpo,psf,flux) + $::bdi_gui_binast::widget(data,$date,$cpo,psf,err_flux)]
            set flux_total_min [expr $flux_total_min + $::bdi_gui_binast::widget(data,$date,$cpo,psf,flux) - $::bdi_gui_binast::widget(data,$date,$cpo,psf,err_flux)]
         }
      }
      gren_info "flux_total $flux_total_min $flux_total $flux_total_max\n"
      gren_info "flux $::bdi_gui_binast::widget(mesure,flux) $::bdi_gui_binast::widget(mesure,err_flux)\n"
      # Calcul des mag (valeur, min et max)
      set mag     [expr $mag_bary - 2.5 * log(   $::bdi_gui_binast::widget(mesure,flux) / $flux_total )]
      set mag_max [expr $mag_bary - 2.5 * log( ( $::bdi_gui_binast::widget(mesure,flux) - $::bdi_gui_binast::widget(mesure,err_flux) ) / $flux_total_max )]
      set mag_min [expr $mag_bary - 2.5 * log( ( $::bdi_gui_binast::widget(mesure,flux) + $::bdi_gui_binast::widget(mesure,err_flux) ) / $flux_total_min )]
      set err_mag [expr ($mag_max - $mag_min)/2.0 ]

      # Calcul des mag de la reference
      if { $compo == $compo_ref } {
         set mag_ref     [expr $mag_bary - 2.5 * log(   $::bdi_gui_binast::widget(mesure,flux) / $flux_total)]
         set mag_ref_max [expr $mag_bary - 2.5 * log( ( $::bdi_gui_binast::widget(mesure,flux) - $::bdi_gui_binast::widget(mesure,err_flux) ) / $flux_total_max)]
         set mag_ref_min [expr $mag_bary - 2.5 * log( ( $::bdi_gui_binast::widget(mesure,flux) + $::bdi_gui_binast::widget(mesure,err_flux) ) / $flux_total_min)]
      } else {
         set mag_ref     [expr $mag_bary - 2.5 * log(   $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,flux) / $flux_total)]
         set mag_ref_max [expr $mag_bary - 2.5 * log( ( $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,flux) - $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,err_flux) ) / $flux_total_max)]
         set mag_ref_min [expr $mag_bary - 2.5 * log( ( $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,flux) + $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,err_flux) ) / $flux_total_min)]
      } 

      # Calcul des dmag 
      set dmag [expr $mag - $mag_ref ]
      set dmag_max [expr $mag_max - $mag_ref_min]
      set dmag_min [expr $mag_min - $mag_ref_max]
      set err_dmag [expr ($dmag_max - $dmag_min)/2.0]

      # Calcul de l erreur des dmag 
      set err_dmag $err_mag

      # formattage des resultats
      set mag      [format "%0.2f" $mag     ]  
      set err_mag  [format "%0.2f" $err_mag ]
      set dmag     [format "%0.2f" $dmag    ]  
      set err_dmag [format "%0.2f" $err_dmag]  

      return [list $mag $err_mag $dmag $err_dmag]

   }




   #------------------------------------------------------------
   ## Procedure lance la mesure du photocentre
   #  @return void
   proc ::bdi_gui_binast::box_mag { date } {
      
      gren_info "box_mag : $date\n"

      # initialisation des resultats
      foreach  compo $::bdi_gui_binast::widget(table,compos,list)  {
         set ::bdi_gui_binast::widget(data,$date,$compo,mesure,mag)       ""
         set ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_mag)   ""
         set ::bdi_gui_binast::widget(data,$date,$compo,mesure,dmag)      ""
         set ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_dmag)  ""
      }

      # Selection de la reference
      set compo_ref ""
      foreach  compo $::bdi_gui_binast::widget(table,compos,list)  {
         if {$::bdi_gui_binast::widget(data,listref,$date,$compo)=="x"} {
            set compo_ref $compo
            break
         }
      }
      if {$compo_ref == ""} {
         gren_erreur "Pas de compo ref a la date : $date\n"
         return
      }

      foreach  compo $::bdi_gui_binast::widget(table,compos,list)  {

         # Existance de la mesure
         if { ! [info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,flux)    ] } { continue }
         if { ! [info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,err_flux)] } { continue }
         if { $::bdi_gui_binast::widget(data,$date,$compo,psf,flux) == ""  } { continue }
         if { $::bdi_gui_binast::widget(data,$date,$compo,psf,err_flux) == ""  } { continue }

         # Init
         set flux_total     0
         set flux_total_max 0
         set flux_total_min 0

         if { [info exists ::bdi_gui_binast::widget(data,ephem,$date,mag,barycentre)] } {
            set mag_bary $::bdi_gui_binast::widget(data,ephem,$date,mag,barycentre)
         } else {
            set mag_bary 0
         }

         # Calcul des flux totaux du barycentre (valeur, min et max)
         foreach  cpo $::bdi_gui_binast::widget(table,compos,list)  {
            if { ! [info exists ::bdi_gui_binast::widget(data,$date,$cpo,psf,flux)]     } { continue }
            if { $::bdi_gui_binast::widget(data,$date,$cpo,psf,flux) == ""  } { continue }
            #gren_erreur "$date,$cpo flux_total = $flux_total psf,flux = $::bdi_gui_binast::widget(data,$date,$cpo,psf,flux)\n"
            set flux_total     [expr $flux_total     + $::bdi_gui_binast::widget(data,$date,$cpo,psf,flux) ]
            if { ! [info exists ::bdi_gui_binast::widget(data,$date,$cpo,psf,err_flux)] } { continue }
            set flux_total_max [expr $flux_total_max + $::bdi_gui_binast::widget(data,$date,$cpo,psf,flux) + $::bdi_gui_binast::widget(data,$date,$cpo,psf,err_flux)]
            set flux_total_min [expr $flux_total_min + $::bdi_gui_binast::widget(data,$date,$cpo,psf,flux) - $::bdi_gui_binast::widget(data,$date,$cpo,psf,err_flux)]
         }

         if { $::bdi_gui_binast::widget(data,$date,$compo,psf,flux) == ""  } { continue }

         
         if {$::bdi_gui_binast::widget(data,$date,$compo,psf,err_flux) > $::bdi_gui_binast::widget(data,$date,$compo,psf,flux)} {
            gren_erreur "Mesure des barres d erreur impossible : L erreur sur le flux est plus grande que la valeur du flux\n"
            continue
         }
 
         # Calcul des mag (valeur, min et max)
         set mag     [expr $mag_bary - 2.5 * log(   $::bdi_gui_binast::widget(data,$date,$compo,psf,flux) / $flux_total )]
         set mag_max [expr $mag_bary - 2.5 * log( ( $::bdi_gui_binast::widget(data,$date,$compo,psf,flux) - $::bdi_gui_binast::widget(data,$date,$compo,psf,err_flux) ) / $flux_total_max )]
         set mag_min [expr $mag_bary - 2.5 * log( ( $::bdi_gui_binast::widget(data,$date,$compo,psf,flux) + $::bdi_gui_binast::widget(data,$date,$compo,psf,err_flux) ) / $flux_total_min )]
         set err_mag [expr ($mag_max - $mag_min)/2.0 ]

         # Calcul des mag de la reference
         set mag_ref     [expr $mag_bary - 2.5 * log(   $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,flux) / $flux_total)]
         set mag_ref_max [expr $mag_bary - 2.5 * log( ( $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,flux) - $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,err_flux) ) / $flux_total_max)]
         set mag_ref_min [expr $mag_bary - 2.5 * log( ( $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,flux) + $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,err_flux) ) / $flux_total_min)]

         # Calcul des dmag 
         set dmag     [expr $mag - $mag_ref ]
         set dmag_max [expr $mag_max - $mag_ref_min]
         set dmag_min [expr $mag_min - $mag_ref_max]
         set err_dmag [expr ($dmag_max - $dmag_min)/2.0]

         # Calcul de l erreur des dmag 
         set err_dmag $err_mag

         # formattage des resultats
         set ::bdi_gui_binast::widget(data,$date,$compo,mesure,mag)      [format "%0.2f" $mag     ]  
         set ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_mag)  [format "%0.2f" $err_mag ]
         set ::bdi_gui_binast::widget(data,$date,$compo,mesure,dmag)     [format "%0.2f" $dmag    ]  
         set ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_dmag) [format "%0.2f" $err_dmag]  
      }
   
      return
   }



