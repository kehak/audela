#--------------------------------------------------
# source [ file join $audace(rep_plugin) tool bddimages bdi_psf_tools.tcl ]
#--------------------------------------------------
#
# Fichier        : bdi_psf_tools.tcl
# Description    : Traitement des psf des images sans GUI
# Auteur         : Frederic Vachier
# Mise Ã  jour $Id: bdi_psf_tools.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------
#
# - namespace psf_tools
#
#--------------------------------------------------


namespace eval psf_tools {






   proc ::psf_tools::inittoconf { } {

      global conf

      if {! [info exists ::psf_tools::use_psf] } {
         if {[info exists conf(bddimages,cata,psf,create)]} {
            set ::psf_tools::use_psf $conf(bddimages,cata,psf,create)
         } else {
            set ::psf_tools::use_psf 0
         }
      }
      if {! [info exists ::psf_tools::use_global] } {
         if {[info exists conf(bddimages,cata,psf,globale)]} {
            set ::psf_tools::use_global $conf(bddimages,cata,psf,globale)
         } else {
            set ::psf_tools::use_global 0
         }
      }
      if {! [info exists ::psf_tools::psf_saturation] } {
         if {[info exists conf(bddimages,cata,psf,saturation)]} {
            set ::psf_tools::psf_saturation $conf(bddimages,cata,psf,saturation)
         } else {
            set ::psf_tools::psf_saturation 50000
         }
      }
      if {! [info exists ::psf_tools::psf_radius] } {
         if {[info exists conf(bddimages,cata,psf,radius)]} {
            set ::psf_tools::psf_radius $conf(bddimages,cata,psf,radius)
         } else {
            set ::psf_tools::psf_radius 15
         }
      }
      if {! [info exists ::psf_tools::psf_threshold] } {
         if {[info exists conf(bddimages,cata,psf,threshold)]} {
            set ::psf_tools::psf_threshold $conf(bddimages,cata,psf,threshold)
         } else {
            set ::psf_tools::psf_threshold 2
         }
      }
      if {! [info exists ::psf_tools::psf_limitradius] } {
         if {[info exists conf(bddimages,cata,psf,limitradius)]} {
            set ::psf_tools::psf_limitradius $conf(bddimages,cata,psf,limitradius)
         } else {
            set ::psf_tools::psf_limitradius 50
         }
      }

   }






   proc ::psf_tools::closetoconf { } {

      global conf
   
      # Conf cata psf
      set conf(bddimages,cata,psf,create)       $::psf_tools::use_psf
      set conf(bddimages,cata,psf,globale)      $::psf_tools::use_global
      set conf(bddimages,cata,psf,saturation)   $::psf_tools::psf_saturation
      set conf(bddimages,cata,psf,radius)       $::psf_tools::psf_radius
      set conf(bddimages,cata,psf,threshold)    $::psf_tools::psf_threshold
      set conf(bddimages,cata,psf,limitradius)  $::psf_tools::psf_limitradius
   }
   









# Anciennement ::gui_cata::psf_box 
# Effectue l analyse d'une psf pour un rayon donné 
# en entrée :
# - soit on donne le rectangle
# - soit on donne le xcent et ycent
# cette fonction est appelé depuis ::psf_gui::one_psf
# pour l analyse d'une psf pour un rayon fixe


   proc ::psf_tools::psf_box { { a "" } { b "" } } {

      global bddconf

      if { $a == "" && $b==""} { 
         ::psf_tools::result_photom_methode "err" 
         ::psf_tools::result_fitgauss "err" 
         return -code 1
      }

      if { $b == "" } {

         #     fit gauss
         set result_fitgauss [buf$bddconf(bufno) fitgauss $a]
         ::psf_tools::result_fitgauss $result_fitgauss
         set xcent  [lindex $result_fitgauss 1]  
         set ycent  [lindex $result_fitgauss 5]  

         #     photom_methode
         set err [catch {set result [::tools_cdl::photom_methode $xcent $ycent $::gui_cata::psf_radius $bddconf(bufno)]} msg]
         if {$err} {
            ::console::affiche_erreur "PSF_BUTTON_PSF : Photom error ($err) ($msg)\n" 
            ::psf_tools::result_photom_methode "err" 
         } else {
            ::psf_tools::result_photom_methode $result
            set xd [expr abs($::gui_cata::current_psf(xsm)-$::gui_cata::current_psf(xcent))]
            set yd [expr abs($::gui_cata::current_psf(ysm)-$::gui_cata::current_psf(ycent))]
            set rdiff [expr sqrt (pow($xd,2) + pow($yd ,2))]
            set ::gui_cata::current_psf(rdiff) [format "%.4f" $rdiff ]
         }
         
      } else {
         set xcent  $a 
         set ycent  $b 

         #     photom_methode
         set err [catch {set result [::tools_cdl::photom_methode $xcent $ycent $::gui_cata::psf_radius $bddconf(bufno)]} msg]
         if {$err} {
            ::console::affiche_erreur "PSF_BUTTON_PSF : Photom error ($err) ($msg)\n" 
            ::psf_tools::result_photom_methode "err" 
         
         } else {
            gren_info "result = $result $xcent $ycent\n"
            ::psf_tools::result_photom_methode $result

            set xcent [expr int([lindex $result 0])]
            set ycent [expr int([lindex $result 1])]
            set delta [expr int([lindex $result 14])]
            set rect [list [expr $xcent - $delta] [expr $ycent - $delta] [expr $xcent + $delta]  [expr $ycent + $delta] ] 
            
            set result_fitgauss [buf$bddconf(bufno) fitgauss $rect]
            ::psf_tools::result_fitgauss $result_fitgauss
            
            set xd [expr abs($::gui_cata::current_psf(xsm)-$::gui_cata::current_psf(xcent))]
            set yd [expr abs($::gui_cata::current_psf(ysm)-$::gui_cata::current_psf(ycent))]
            set rdiff [expr sqrt (pow($xd,2) + pow($yd ,2))]
            set ::gui_cata::current_psf(rdiff) [format "%.4f" $rdiff ]
         
         }
      
      }
      
   }






   proc ::psf_tools::psf_box_crop { xcent ycent } {

      global bddconf


      #gren_info "xcent ycent = $xcent $ycent\n"

      #     photom_methode
      #gren_info "CMD = ::tools_cdl::photom_methode $xcent $ycent $::gui_cata::psf_radius $::psf_gui::bufcrop\n"
      
      set err [catch {set result [::tools_cdl::photom_methode $xcent $ycent $::gui_cata::psf_radius $::psf_gui::bufcrop]} msg]
      if {$err} {
         gren_erreur "PSF_BUTTON_PSF : Photom error ($err) ($msg)\n" 
         ::psf_tools::result_photom_methode "err" 
      
      } else {
         #gren_info "result = $result\n"
         
         ::psf_tools::result_photom_methode $result

         set xcent [expr int([lindex $result 0])]
         set ycent [expr int([lindex $result 1])]
         set delta [expr int([lindex $result 14])]
         set rect  [list [expr $xcent - $delta] [expr $ycent - $delta] [expr $xcent + $delta]  [expr $ycent + $delta] ] 

         #gren_info "xcent = $xcent\n"
         #gren_info "ycent = $ycent\n"
         #gren_info "delta = $delta\n"
         #gren_info "rect  = $rect \n"
         
         set result_fitgauss [buf$::psf_gui::bufcrop fitgauss $rect]
         ::psf_tools::result_fitgauss $result_fitgauss
         #gren_info "result_fitgauss  = $result_fitgauss \n"
         
         set ::gui_cata::current_psf(xsm)   [format "%.4f" [expr $::gui_cata::current_psf(xsm)   + $::psf_gui::xref] ]
         set ::gui_cata::current_psf(ysm)   [format "%.4f" [expr $::gui_cata::current_psf(ysm)   + $::psf_gui::yref] ]
         set ::gui_cata::current_psf(xcent) [format "%.4f" [expr $::gui_cata::current_psf(xcent) + $::psf_gui::xref] ]
         set ::gui_cata::current_psf(ycent) [format "%.4f" [expr $::gui_cata::current_psf(ycent) + $::psf_gui::yref] ]
         
         
         set xd [expr abs($::gui_cata::current_psf(xsm)-$::gui_cata::current_psf(xcent))]
         set yd [expr abs($::gui_cata::current_psf(ysm)-$::gui_cata::current_psf(ycent))]
         set rdiff [expr sqrt (pow($xd,2) + pow($yd ,2))]
         set ::gui_cata::current_psf(rdiff) [format "%.4f" $rdiff ]
      
      }
      
      
   }



# Anciennement ::gui_cata::psf_gui_results_fg
# inscrit dans la variable de namespace le resultat d'une psf par la methode : FITGAUSS
# en entrée : le resultat d un fitgauss
# cette fonction est appelé depuis :
#    ::psf_tools::psf_box
#    ::psf_gui::box_global
#    ::psf_gui::gestion_mode_manuel_grab
#    
#    
#
# fit gauss = 
#  0   xflux
#  1   xcent
#  2   xfwhm
#  3   xfond
#  4   yflux
#  5   ycent 
#  6   yfwhm
#  7   yfond

   proc ::psf_tools::result_fitgauss { result } {
   
      if {$result=="err"} {
         set ::gui_cata::current_psf(xflux) "Nan"
         set ::gui_cata::current_psf(xcent) "Nan"
         set ::gui_cata::current_psf(xfwhm) "Nan"
         set ::gui_cata::current_psf(xfond) "Nan"
         set ::gui_cata::current_psf(yflux) "Nan"
         set ::gui_cata::current_psf(ycent) "Nan"
         set ::gui_cata::current_psf(yfwhm) "Nan"
         set ::gui_cata::current_psf(yfond) "Nan"
      } else {
         set ::gui_cata::current_psf(xflux) [lindex $result 0]
         set ::gui_cata::current_psf(xcent) [lindex $result 1]
         set ::gui_cata::current_psf(xfwhm) [lindex $result 2]
         set ::gui_cata::current_psf(xfond) [lindex $result 3]
         set ::gui_cata::current_psf(yflux) [lindex $result 4]
         set ::gui_cata::current_psf(ycent) [lindex $result 5]
         set ::gui_cata::current_psf(yfwhm) [lindex $result 6]
         set ::gui_cata::current_psf(yfond) [lindex $result 7]
      }

   }









# Anciennement ::gui_cata::psf_gui_results_pm
# inscrit dans la variable de namespace le resultat d'une psf par la methode : PHOTOM_METHODE
# en entrée : le resultat d un photom_methode
# cette fonction est appelé depuis :
#    ::psf_tools::psf_box
#    ::psf_gui::box_global
#    ::psf_gui::gestion_mode_manuel_grab
#    
#    
# photom_methode = 
#   {$xsm $ysm $err_xsm $err_ysm $fwhmx $fwhmy $fwhm $fluxintegre $errflux $pixmax $intensite $sigmafond $snint $snpx $delta}
#   {xsm ysm err_xsm err_ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta}
#    0   xsm 
#    1   ysm 
#    2   err_xsm 
#    3   err_ysm 
#    4   fwhmx 
#    5   fwhmy 
#    6   fwhm 
#    7   fluxintegre 
#    8   errflux 
#    9   pixmax 
#   10   intensite 
#   11   sigmafond 
#   12   snint 
#   13   snpx
#   14   delta
   proc ::psf_tools::result_photom_methode { result } {
   
      if {$result=="err"} {
         set ::gui_cata::current_psf(xsm)         "Nan"
         set ::gui_cata::current_psf(ysm)         "Nan"
         set ::gui_cata::current_psf(err_xsm)     "Nan"
         set ::gui_cata::current_psf(err_ysm)     "Nan"
         set ::gui_cata::current_psf(fwhmx)       "Nan"
         set ::gui_cata::current_psf(fwhmy)       "Nan"
         set ::gui_cata::current_psf(fwhm)        "Nan"
         set ::gui_cata::current_psf(fluxintegre) "Nan"
         set ::gui_cata::current_psf(errflux)     "Nan"
         set ::gui_cata::current_psf(pixmax)      "Nan"
         set ::gui_cata::current_psf(intensite)   "Nan"
         set ::gui_cata::current_psf(sigmafond)   "Nan"
         set ::gui_cata::current_psf(snint)       "Nan"
         set ::gui_cata::current_psf(snpx)        "Nan"
         set ::gui_cata::current_psf(delta)       "Nan"
         set ::gui_cata::current_psf(rdiff)       "Nan"
      } else {
         set ::gui_cata::current_psf(xsm)         [format "%.4f" [lindex $result  0] ]
         set ::gui_cata::current_psf(ysm)         [format "%.4f" [lindex $result  1] ]
         set ::gui_cata::current_psf(err_xsm)     [format "%.4f" [lindex $result  2] ]
         set ::gui_cata::current_psf(err_ysm)     [format "%.4f" [lindex $result  3] ]
         set ::gui_cata::current_psf(fwhmx)       [format "%.4f" [lindex $result  4] ]
         set ::gui_cata::current_psf(fwhmy)       [format "%.4f" [lindex $result  5] ]
         set ::gui_cata::current_psf(fwhm)        [format "%.4f" [lindex $result  6] ]
         set ::gui_cata::current_psf(fluxintegre) [format "%.4f" [lindex $result  7] ]
         set ::gui_cata::current_psf(errflux)     [format "%.4f" [lindex $result  8] ]
         set ::gui_cata::current_psf(pixmax)      [format "%.4f" [lindex $result  9] ]
         set ::gui_cata::current_psf(intensite)   [format "%.4f" [lindex $result 10] ]
         set ::gui_cata::current_psf(sigmafond)   [format "%.4f" [lindex $result 11] ]
         set ::gui_cata::current_psf(snint)       [format "%.4f" [lindex $result 12] ]
         set ::gui_cata::current_psf(snpx)        [format "%.4f" [lindex $result 13] ]
         set ::gui_cata::current_psf(delta)       [format "%.4f" [lindex $result 14] ]
      }
   }




   proc ::psf_tools::result_global_methode { send_result } {
      
      upvar $send_result result

      set result [list [format "%.4f" [lindex $result  0] ]  \
                       [format "%.4f" [lindex $result  1] ]  \
                       [format "%.4f" [lindex $result  2] ]  \
                       [format "%.4f" [lindex $result  3] ]  \
                       [format "%.4f" [lindex $result  4] ]  \
                       [format "%.4f" [lindex $result  5] ]  \
                       [format "%.4f" [lindex $result  6] ]  \
                       [format "%.4f" [lindex $result  7] ]  \
                       [format "%.4f" [lindex $result  8] ]  \
                       [format "%.4f" [lindex $result  9] ]  \
                       [format "%.4f" [lindex $result 10] ]  \
                       [format "%.4f" [lindex $result 11] ]  \
                       [format "%.4f" [lindex $result 12] ]  \
                       [format "%.4f" [lindex $result 13] ]  \
                       [format "%.4f" [lindex $result 14] ]  \
                       [format "%.4f" [lindex $result 15] ]  \
                       [format "%.8f" [lindex $result 16] ]  \
                       [format "%.8f" [lindex $result 17] ]  \
                 ]
   }









   proc ::psf_tools::method_global_stat { send_results radiuslimit log } {

      upvar $send_results results 

      if {$log} { gren_info "METHODE GLOBALE STAT \n" }

      set listfield [list xsm ysm err_xsm err_ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta rdiff ra dec]
      set i 0
      foreach field $listfield {
         set tab ""
         for {set radius 1} {$radius < $radiuslimit} {incr radius} {
            if {$results($radius,err)==0} {
               lappend tab [lindex $results($radius) $i]
            }
         }
         # Stat FWHM
         set sol($field,mean)   [::math::statistics::mean $tab]
         set sol($field,median) [::math::statistics::median $tab]
         set sol($field,stdev)  [::math::statistics::stdev $tab]
         set sol($field,err1s)  $sol($field,stdev)
         set sol($field,err2s)  [ expr 2.0 * $sol($field,stdev) ]
         set sol($field,err3s)  [ expr 3.0 * $sol($field,stdev) ]
         incr i
      }
      set sol(err_xsm,1)   $sol(xsm,stdev)
      set sol(err_xsm,2)   [ expr 2.0 * $sol(xsm,stdev) ]
      set sol(err_xsm,3)   [ expr 3.0 * $sol(xsm,stdev) ]
      set sol(err_ysm,1)   $sol(ysm,stdev)
      set sol(err_ysm,2)   [ expr 2.0 * $sol(ysm,stdev) ]
      set sol(err_ysm,3)   [ expr 3.0 * $sol(ysm,stdev) ]
      set sol(errflux,1)   $sol(fluxintegre,stdev)
      set sol(errflux,2)   [ expr 2.0 * $sol(fluxintegre,stdev) ]
      set sol(errflux,3)   [ expr 3.0 * $sol(fluxintegre,stdev) ]

      return [array get sol]

   }






   proc ::psf_tools::method_global_sol { send_sol { err 2 } } {
   
      upvar $send_sol sol 

      set result_global [list $sol(xsm,mean) \
                              $sol(ysm,mean) \
                              $sol(err_xsm,$err) \
                              $sol(err_ysm,$err) \
                              $sol(fwhmx,mean) \
                              $sol(fwhmy,mean) \
                              $sol(fwhm,mean) \
                              $sol(fluxintegre,mean) \
                              $sol(errflux,$err) \
                              $sol(pixmax,mean) \
                              $sol(intensite,mean) \
                              $sol(sigmafond,mean) \
                              $sol(snint,mean) \
                              $sol(snpx,mean) \
                              $sol(delta,mean) \
                              $sol(rdiff,mean) \
                              $sol(ra,mean) \
                              $sol(dec,mean) \
                         ]
      return [::psf_tools::result_global_methode result_global]
   }



   proc ::psf_tools::log_diff { result_global radius_fwhm radius_fluxintegre radius_posmean} {

      set xsm       [lindex $result_global 0]
      set ysm       [lindex $result_global 1]
      set stdev_xsm [lindex $result_global 2]
      set stdev_ysm [lindex $result_global 3]
      set pra       [lindex $result_global 16]
      set pdec      [lindex $result_global 17]

      if {$log} { gren_info "xsm = $xsm +- $stdev_xsm\n" }
      if {$log} { gren_info "ysm = $ysm +- $stdev_ysm\n" }


      set dx [expr abs( $xsm - $xsm_fwhm)]
      set dy [expr abs( $ysm - $ysm_fwhm)]
      set diff [expr sqrt( ( pow($dx,2) + pow($dy,2) ) / 2.0 )]
      if {$log} { gren_info "diff_fwhm ($radius_fwhm) = $diff\n" }
      set diffmin $diff
      set best_radius $radius_fwhm

      set dx [expr abs( $xsm - $xsm_fluxintegre)]
      set dy [expr abs( $ysm - $ysm_fluxintegre)]
      set diff [expr sqrt( ( pow($dx,2) + pow($dy,2) ) / 2.0 )]
      if {$log} { gren_info "diff_fluxintegre ($radius_fluxintegre) = $diff\n" }
      if {$diff<$diffmin} {
         set diffmin $diff
         set best_radius $radius_fluxintegre
      }

      set dx [expr abs( $xsm - $xsm_posmean)]
      set dy [expr abs( $ysm - $ysm_posmean)]
      set diff [expr sqrt( ( pow($dx,2) + pow($dy,2) ) / 2.0 )]
      if {$log} { gren_info "diff_posmean ($radius_posmean) = $diff\n" }
      if {$diff<$diffmin} {
         set diffmin $diff
         set best_radius $radius_posmean
      }


      if {$log} { gren_info "-----\n" }
      if {$log} { gren_info "RADIUS SELECTED    = $best_radius\n" }
      set result_selected    [lreplace $results($best_radius) 2 3 $stdev_xsm $stdev_ysm]
      set xsm_selected       [lindex $result_selected 0]
      set ysm_selected       [lindex $result_selected 1]
      set stdev_xsm_selected [lindex $result_selected 2]
      set stdev_ysm_selected [lindex $result_selected 3]
      if {$log} { gren_info "xsm_selected = $xsm_selected +- $stdev_xsm_selected\n" }
      if {$log} { gren_info "ysm_selected = $ysm_selected +- $stdev_ysm_selected\n" }

      set dx [expr abs( $xsm - $xsm_selected)]
      set dy [expr abs( $ysm - $ysm_selected)]
      set diff [expr sqrt( ( pow($dx,2) + pow($dy,2) ) / 2.0 )]
      if {$log} { gren_info "diff_selected ($best_radius) = $diff\n" }

      if {$log} { gren_info "-----\n" }

      return $best_radius
   }




           ###                                ###

           #    Ajout de ASTROID dans le cata   #  

           ###                                ###

#      ::psf_tools::add_astroid s $name_source
      #gren_info "ASTROID CATA   = [lindex $astroid 0]\n"
      #gren_info "ASTROID COMMON = [lindex $astroid 1]\n"
      ##gren_info "ASTROID OTHERF = [lindex $astroid 2]\n"

   proc ::psf_tools::add_astroid { send_s send_result_global name_source } {

      upvar $send_s s 
      upvar $send_result_global result_global 
      
      set xsm       [lindex $result_global 0]
      set ysm       [lindex $result_global 1]
      set stdev_xsm [lindex $result_global 2]
      set stdev_ysm [lindex $result_global 3]
      set pra       [lindex $result_global 16]
      set pdec      [lindex $result_global 17]
      
      set flagastroid "Failure"
      set pos [lsearch -index 0 $s "ASTROID"]
         set flagastroid "pos=$pos"
      if {$pos!=-1} {
         set astroid [lindex $s $pos]

         set comf   [lindex $astroid 1]
         set comf   [lreplace $comf 0 1 $pra $pdec]

         set otherf  [lindex $astroid 2]
         set i 0
         foreach val $result_global {
            set otherf [lreplace $otherf $i $i $val]
            incr i
         }
         set otherf [lreplace $otherf 24 24 $name_source]
         set astroid [ list "ASTROID" $comf $otherf]
         set s [lreplace $s $pos $pos $astroid]
         set flagastroid "Modif Success"
      } else {
         set cata "ASTROID"
         set comf [list $pra $pdec 5 0 0]
         set othf [linsert $result_global end "0" "0" "0" "0" "0" "0" $name_source "-" "-" "-" "-"]
         set astroid [list "ASTROID" $comf $othf]
         set s [linsert $s end $astroid]
         set flagastroid "Add Success"
      }
      return $flagastroid
   }

# Anciennement ::gui_cata::psf_box_auto_no_gui
# Effectue une analyse de psf, en methode globale
# cad qu il fait une statistique sur une multitude de rayon de recherche
# en analysant les psf pour un rayon de 1 pixel a radiuslimit
# en filtrant les resultats dont la position pixel x,y est inferieur a la position attendue de "threshold" pixel
#
# En entree : 
#   s           : correspondant a une source dont la structure provient de listsources
#   threshold   : correspondant a un rayon en pixel dans lequel le resultat doit etre contenu
#                 le centre de cette zone est donné par le centre de la zone de recherche
#   radiuslimit : correspondant a limit sup du rayon de recherche
#
# cette fonction est appelé depuis :
#    
#    
#    
   proc ::psf_tools::method_global { sent_s threshold radiuslimit saturation bufNo } {
      
     upvar $sent_s s

      global bddconf
      
      set log 0
      set save_file "no"
      set save_graph "yes"

      if {$log} { gren_info "entree dans ::psf_tools::method_global \n"}
      
      # Nom de la source 
      
      set name_cata [::manage_source::namable $s]
      if {$name_cata==""} {
         if {$log} { gren_info "s=$s\n" }
         set ::gui_cata::psf_name_source "Unnamable"
         return -code 1
      }
      set name_source [::manage_source::naming $s $name_cata]
      
      set pass "no"


      # On recupere les x y alpha delta de chaque source
      # afin d initialiser le probleme

      foreach mycata $s {
      
         if {[lindex $mycata 0] == $name_cata } {
            
            if {$log} { gren_info "name_cata = $name_cata\n" }
            if {$log} { gren_info "common = [lindex $mycata 1]\n" }
            
            set ra  [lindex [lindex $mycata 1] 0]
            set dec [lindex [lindex $mycata 1] 1]

            if {$log} { gren_info "ra dec $ra $dec\n" }
            
            set xy [ buf$bufNo radec2xy [list $ra $dec ] ]
            set x [lindex $xy 0]
            set y [lindex $xy 1]
            set pass "yes"
         }
      }
      if {$pass=="no"} {
         return -code 2
      }


      # On applique la methode photometrique mais on jette 
      # les sources a l'exterieur du threshold

      for {set radius 1} {$radius < $radiuslimit} {incr radius} {

         set results($radius,err) [catch {set result [::tools_cdl::photom_methode $x $y $radius $bufNo]} msg]
         if {$result==-1} {
            set results($radius,err) 2
         }
         if {$results($radius,err)==0} {
         
            set xsm [lindex $result 0]
            set ysm [lindex $result 1]
            set pixmax [lindex $result 9]

            if {$pixmax > $saturation} {
               set results($radius,err) 4
               continue
            }
            
            set radec [ buf$bufNo xy2radec [list $xsm $ysm ] ]
            set pra   [lindex $radec 0] 
            set pdec  [lindex $radec 1]
            
            set radiff   [expr ($ra - $pra ) * cos($dec * 3.141592653589793 / 180.0)]
            set decdiff  [expr $dec - $pdec ]
            set rsecdiff [expr sqrt ( pow($radiff,2) + pow($decdiff,2) ) * 3600.0]
            
            if {$rsecdiff > $threshold} {
               set results($radius,err) 3
               continue
            }

            set result [linsert $result end $rsecdiff $pra $pdec]
            set results($radius) $result
         }

      }


      # Sauve fichier
      if {$save_file=="yes"} {
         set file [file join $bddconf(dirtmp) "psf_all.csv"]
         if {$log} { gren_info "Sauve Fichier = $file\n" }
         set chan [open $file w]
         #   {xsm ysm err_xsm err_ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta rdiff ra dec}
         puts $chan "#xsm ysm err_xsm err_ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta rdiff ra dec"

         for {set radius 1} {$radius < $radiuslimit} {incr radius} {
            if {$results($radius,err)==0} {
                puts $chan $results($radius)
            }
         }
         close $chan
      }

      # Statistiques



      if {$log} { gren_info "statistiques\n" }
      if {$log} { gren_info "NB POP $radiuslimit : start\n" }

      set rdiff ""
      set fluxintegre ""
      set intensite ""
      set fwhm ""
      for {set radius 1} {$radius < $radiuslimit} {incr radius} {
         if {$results($radius,err)==0} {
            lappend fwhm         [lindex $results($radius) 6]
            lappend fluxintegre  [lindex $results($radius) 7]
            lappend intensite    [lindex $results($radius) 10]
            lappend rdiff        [lindex $results($radius) 15]
         }
      }
      set nb  [llength $rdiff]
      if {$log} { gren_info "NB POP $nb : tri erreur\n" }
      
      set max_fwhm           [::math::statistics::max $fwhm       ]

      set median_fwhm        [::math::statistics::median $fwhm       ]
      set median_fluxintegre [::math::statistics::median $fluxintegre]
      set median_intensite   [::math::statistics::median $intensite  ]
      set median_rdiff       [::math::statistics::median $rdiff      ]

      set stdev_fluxintegre  [::math::statistics::stdev $fluxintegre]
      set stdev_intensite    [::math::statistics::stdev $intensite  ]

      set diffmin 1000000000
      set radius_rdiff 0
      for {set radius 1} {$radius < $radiuslimit} {incr radius} {
         if {$results($radius,err)==0} {
            set rdiff  [lindex $results($radius) 15]
            set diff [expr abs($rdiff - $max_fwhm)]
            if {$diff < $diffmin } {
               set radius_rdiff [lindex $radius]
               set diffmin $diff 
            }
         }
      }


                      ###               ###

                      #    fluxintegre    #  

                      ###               ###


      for {set i 0} {$i<1} {incr i} {

         # statistiques on selectionne tous les radius dont le flux est superieur a une limite
         # CROP autour des plus hautes valeur de flux
         #gren_info "CROP\n"
         set fluxintegre ""
         set fluxmin  [expr  $median_fluxintegre - $stdev_fluxintegre]
         for {set radius 1} {$radius < $radiuslimit} {incr radius} {
            if {$results($radius,err)==0} {
               set flux  [lindex $results($radius) 7]
               if {$flux < $fluxmin } {
                  set results($radius,err) 4
               } else {
                  lappend fluxintegre  $flux
               }
            }
         }
         set median_fluxintegre [::math::statistics::median $fluxintegre]
         set stdev_fluxintegre  [::math::statistics::stdev $fluxintegre]
      }

      if {$save_file=="yes"} {
         # Sauve fichier
         set file [file join $bddconf(dirtmp) "psf_crop_flux_$i.csv"]
         if {$log} { gren_info "Sauve Fichier = $file\n" }
         set chan [open $file w]
         puts $chan "#xsm ysm err_xsm err_ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta rdiff ra dec"
         for {set radius 1} {$radius < $radiuslimit} {incr radius} {
            if {$results($radius,err)==0} {
                puts $chan $results($radius)
            }
         }
         close $chan
      }


                      ###        ###

                      #    FWHM    #  

                      ###        ###

      # CROP autour des plus hautes valeur de fwhm
      set fwhm ""
      for {set radius 1} {$radius < $radiuslimit} {incr radius} {
         if {$results($radius,err)==0} {
            lappend fwhm  [lindex $results($radius) 6]
         }
      }
      # Stat FWHM
      set median_fwhm [::math::statistics::median $fwhm]
      set stdev_fwhm  [::math::statistics::stdev  $fwhm]

      for {set i 0} {$i<1} {incr i} {

         # CROP FWHM
         set fwhmmin  [expr  $median_fwhm - $stdev_fwhm]
         set fwhmmax  [expr  $median_fwhm + $stdev_fwhm]
         for {set radius 1} {$radius < $radiuslimit} {incr radius} {
            if {$results($radius,err)==0} {
               set fwhm [lindex $results($radius) 6]
               if {$fwhm < $fwhmmin || $fwhm > $fwhmmax} {
                  set results($radius,err) 5
               }
            }
         }

         # Charge FWHM
         set fwhm ""
         for {set radius 1} {$radius < $radiuslimit} {incr radius} {
            if {$results($radius,err)==0} {
               lappend fwhm  [lindex $results($radius) 6]
            }
         }
         # Stat FWHM
         set median_fwhm [::math::statistics::median $fwhm]
         set stdev_fwhm  [::math::statistics::stdev $fwhm]
      }

      # recherche de valeur key,val -> delta
      # pour fwhm
      set myidval 6           
      # Valeur a retrouver
      set valeur  $median_fwhm 

      set dmin 1000000000
      set myfwhm  0
      for {set radius 1} {$radius < $radiuslimit} {incr radius} {
         if {$results($radius,err)==0} {
            set r  [lindex $results($radius) $myidval]
            set d [expr abs($r - $valeur)]
            if {$d < $dmin } {
               set myfwhm $radius
               set dmin $d 
            }
         }
      }

      if {$save_file=="yes"} {
         # Sauve fichier
         set file [file join $bddconf(dirtmp) "psf_crop_radius_fwhm_$i.csv"]
         if {$log} { gren_info "Sauve Fichier = $file\n" }
         set chan [open $file w]
         puts $chan "#xsm ysm err_xsm err_ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta rdiff ra dec"
         for {set radius 1} {$radius < $radiuslimit} {incr radius} {
            if {$results($radius,err)==0} {
                puts $chan $results($radius)
            }
         }
         close $chan
      }

      # Sauve Graph
      if {$save_graph=="yes"} {
         array set ::psf_tools::graph_results [array get results]
      }

   ###                       ###
  
      set radius_fwhm $myfwhm

   ###                       ###

      set xsm_fwhm       [lindex $results($radius_fwhm) 0]
      set ysm_fwhm       [lindex $results($radius_fwhm) 1]
      set stdev_xsm_fwhm [lindex $results($radius_fwhm) 2]
      set stdev_ysm_fwhm [lindex $results($radius_fwhm) 3]
      if {$log} { gren_info "xsm_fwhm = $xsm_fwhm +- $stdev_xsm_fwhm\n" }
      if {$log} { gren_info "ysm_fwhm = $ysm_fwhm +- $stdev_ysm_fwhm\n" }






      set diffmin 1000000000
      set radius_fluxintegre 0
      for {set radius 1} {$radius < $radiuslimit} {incr radius} {
         if {$results($radius,err)==0} {
            set rdiff  [lindex $results($radius) 7]
            set diff [expr abs($rdiff - $median_fluxintegre)]
            if {$diff < $diffmin } {
               set radius_fluxintegre [lindex $radius]
               set diffmin $diff 
            }
         }
      }

      set xsm_fluxintegre       [lindex $results($radius_fluxintegre) 0]
      set ysm_fluxintegre       [lindex $results($radius_fluxintegre) 1]
      set stdev_xsm_fluxintegre [lindex $results($radius_fluxintegre) 2]
      set stdev_ysm_fluxintegre [lindex $results($radius_fluxintegre) 3]
      if {$log} { gren_info "xsm_fluxintegre = $xsm_fluxintegre +- $stdev_xsm_fluxintegre\n" }
      if {$log} { gren_info "ysm_fluxintegre = $ysm_fluxintegre +- $stdev_ysm_fluxintegre\n" }



                      ###                ###

                      #     XSM et YSM     #  

                      ###                ###


      # Moyenne sur les positions 
      set tabxsm ""
      set tabysm ""
      for {set radius 1} {$radius < $radiuslimit} {incr radius} {
         if {$results($radius,err)==0} {
            lappend tabxsm [lindex $results($radius) 0]
            lappend tabysm [lindex $results($radius) 1]
         }
      }
      set nb  [llength $tabxsm]
      if {$log} { gren_info "NB POP $nb : tri crop flux\n" }


      set mean_xsm [::math::statistics::mean $tabxsm]
      set mean_ysm [::math::statistics::mean $tabysm]
      set mean_diff [expr sqrt(pow($mean_xsm,2)+pow($mean_ysm,2))]

      set stdev_xsm [::math::statistics::stdev $tabxsm]
      set stdev_ysm [::math::statistics::stdev $tabysm]

      set diffmin 1000000000
      set radius_posmean 0
      for {set radius 1} {$radius < $radiuslimit} {incr radius} {
         if {$results($radius,err)==0} {
            set eachdiff [expr sqrt((pow([lindex $results($radius) 0],2)+pow([lindex $results($radius) 1],2))/2.0)]
            set diff [expr abs($eachdiff - $mean_diff)]
            if {$diff < $diffmin } {
               set radius_posmean [lindex $radius]
               set diffmin $diff 
            }
         }
      }

      set xsm_posmean       [lindex $results($radius_posmean) 0]
      set ysm_posmean       [lindex $results($radius_posmean) 1]
      set stdev_xsm_posmean [lindex $results($radius_posmean) 2]
      set stdev_ysm_posmean [lindex $results($radius_posmean) 3]
      if {$log} { gren_info "xsm_posmean = $xsm_posmean +- $stdev_xsm_posmean\n" }
      if {$log} { gren_info "ysm_posmean = $ysm_posmean +- $stdev_ysm_posmean\n" }


                      ###         ###

                      #    FINAL    #  

                      ###         ###




      # Choix du bon delta
      set best_radius $radius_fluxintegre


      if {$log} { gren_info "-----\n" }
      if {$log} { gren_info "radius_rdiff       = $radius_rdiff\n" }
      if {$log} { gren_info "radius_fwhm        = $radius_fwhm\n" }
      if {$log} { gren_info "radius_fluxintegre = $radius_fluxintegre\n" }
      if {$log} { gren_info "radius_posmean     = $radius_posmean\n" }
      if {$log} { gren_info "-----\n" }


      # gren_info "result = $best_radius :: $result   \n"

         #set field [linsert $field [::analyse_source::get_fieldastroid] ]
         
#      return [list "ASTROID" [list "ra" "dec" "poserr" "mag" "magerr"] \
#                             [list "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux" \
#                                   "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" \
#                                   "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "mag" "err_mag" \
#                                   "name" "flagastrom" "flagphotom" "cataastrom" "cataphotom"] ]

#    459.650415 245.682162 3.179304 4.009941 3.5946225000000003 4683.000000 0       9104.000000 2561.0    806.214999 5.8086242575598623 3.1765720101667321 2     194.127106 2.201661 0.47884649992695094
#    {xsm       ysm        fwhmx    fwhmy    fwhm               fluxintegre errflux pixmax      intensite sigmafond  snint             snpx                delta alpha      delta    rdiff}


       
   
           ###                         ###

           #      Solution globale     #  

           ###                         ###



      # Statistiques

      array set sol [::psf_tools::method_global_stat results $radiuslimit 0]

      # Solution

      set result_global [::psf_tools::method_global_sol sol]
      
      if {$save_file=="yes"} {
         # Sauve fichier
         set file [file join $bddconf(dirtmp) "psf_global_soluce.csv"]
         if {$log} { gren_info "Sauve Fichier = $file\n" }
         set chan [open $file w]
         puts $chan "#xsm ysm err_xsm err_ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta rdiff ra dec"
         puts $chan $result_global
         close $chan
      }
      

      if {$log} {
         set best_radius [::psf_tools::log_diff $result_global $radius_fwhm $radius_fluxintegre $radius_posmean]
      }

#      if {$dxsm>$stdev_xsm||$dysm>$stdev_ysm} {
#         ::console::affiche_erreur "WARNING = incertitude sur la position X et Y fournit\n"
#      }




      #    Ajout de ASTROID dans le cata   #  
      set flagastroid [::psf_tools::add_astroid s result_global $name_source]

      return -code 0 [list $result_global $best_radius $flagastroid]
      

   }




   proc ::psf_tools::set_mag { send_listsources } {

      upvar $send_listsources listsources
      ::psf_tools::set_mag_usno_r2 listsources

   }




   proc ::psf_tools::set_mag_usno_r2 { send_listsources } {
      
      upvar $send_listsources listsources

      #set ::psf_tools::debug $listsources


      set fields  [lindex $listsources 0]
      set sources [lindex $listsources 1]
      set nd_sources [llength $sources]

      set tabmaginst ""
      set tabmagcata ""
      foreach s $sources {
         foreach cata $s {
            if {[lindex $cata 0] == "USNOA2"} {
               set pos [lsearch -index 0 $s "ASTROID"]
               if {$pos!=-1} {
                  set usnoa2 $cata
                  set usnoa2_oth [lindex $usnoa2 2]
                  set astroid [lindex $s $pos]
                  set astroid_com [lindex $astroid 1]
                  set astroid_oth [lindex $astroid 2]
                  set flux [lindex $astroid_oth 7 ]
                  set magcata  [lindex $usnoa2_oth  7]
                  if {$flux!="" && $magcata != "" && $flux>0} {        
                     set maginst  [expr -log10($flux)*2.5]
                     lappend tabmaginst  $maginst 
                     lappend tabmagcata  $magcata  
                  }
                  
               }
            }
         }
      }
      #gren_info "nb data = [llength $tabflux] == [llength $tabmag] \n"
      set median_maginst [::math::statistics::median $tabmaginst ]
      set median_magcata [::math::statistics::median $tabmagcata ]
      set const_mag      [expr $median_magcata - $median_maginst]
      #gren_info "median_maginst = $median_maginst\n"
      #gren_info "median_magcata = $median_magcata\n"
      #gren_info "const_mag = $const_mag\n"

      set tabmaginst ""
      set tabmagcata ""
      set tabflux ""
      set tabmag  ""
      foreach s $sources {
         foreach cata $s {
            if {[lindex $cata 0] == "USNOA2"} {
               set pos [lsearch -index 0 $s "ASTROID"]
               if {$pos!=-1} {
                  set usnoa2      $cata
                  set usnoa2_oth  [lindex $usnoa2 2]
                  set astroid     [lindex $s $pos]
                  set astroid_com [lindex $astroid 1]
                  set astroid_oth [lindex $astroid 2]
                  set flux        [::bdi_tools_psf::get_val astroid_oth "flux" ]
                  set magcata     [lindex $usnoa2_oth  7 ]

                  if {$flux!="" && $magcata != ""  && $flux>0} {
                     set maginst  [expr -log10($flux)*2.5]
                     set magcalc  [expr -log10($flux)*2.5 + $const_mag]
                     if {[expr abs($magcata - $magcalc) ] < 1.} {
                        lappend tabmaginst  $maginst 
                        lappend tabmagcata  $magcata  
                        #gren_info "mag cata = $magcata ; maginstru = $maginst ; diff = [expr abs($magcata - $maginst) ] ; macalc = $magcalc ; diff = [expr abs($magcalc - $magcata) ]\n"
                        #gren_info "flux = $flux ; mag cata = $magcata ; magcalc = $magcalc ; diff = [expr abs($magcata - $magcalc) ] \n"
                        lappend tabmag  [expr abs($magcalc - $magcata) ]
                     }
                  }
               }
            }
         }
      }

      set median_maginst [::math::statistics::median $tabmaginst ]
      set median_magcata [::math::statistics::median $tabmagcata ]
      set const_mag      [expr $median_magcata - $median_maginst]
      set mag_err [format "%.3f" [::math::statistics::mean $tabmag] ]
      #gren_info "mag_err = $mag_err\n"

  # calcul toutes les sources

      #gren_info "MAG 3 = [::manage_source::get_nb_sources_rollup [list $fields $sources]]\n"
  
      set spos 0
      foreach s $sources {
         set cpos [lsearch -index 0 $s "ASTROID"]
         if {$cpos != -1} {
         
               set astroid [lindex $s $cpos]
               set astroid_com [lindex $astroid 1]
               set astroid_oth [lindex $astroid 2]
               set flux [::bdi_tools_psf::get_val astroid_oth "flux" ]
               
               set err [catch {set mag [format "%.3f" [expr -log10($flux)*2.5 + $const_mag] ]} msg ]
               if {$err} {
                  #gren_info "ERREUR MAG : s = $s \n"
                  #gren_info "ERREUR MAG : flux = $flux ; const_mag = $const_mag\n"
                  incr spos
                  continue
               }
               if {$flux < 0 } {
                  incr spos
                  continue
               }
               set astroid_com [lreplace  $astroid_com 3 4 $mag $mag_err ]
               ::bdi_tools_psf::set_by_key astroid_oth "mag" $mag
               ::bdi_tools_psf::set_by_key astroid_oth "mag_err" $mag_err
               
               set s [lreplace $s $cpos $cpos [list "ASTROID" $astroid_com $astroid_oth]]
               set sources [lreplace $sources $spos $spos $s]
         }
         incr spos
         
      }
      
      #gren_info "MAG 4 = [::manage_source::get_nb_sources_rollup [list $fields $sources]]\n"

#      foreach s $sources {
#         set cpos [lsearch -index 0 $s "SKYBOT"]
#         if {$cpos != -1} {
#            set cpos [lsearch -index 0 $s "ASTROID"]
#            if {$cpos != -1} {
#               set astroid [lindex $s $cpos]
#               set astroid_oth [lindex $astroid 2]
#               set mag [lindex $astroid_oth 22]
#               gren_info "mag SKYBOT = $mag\n"
#
#               set flux [lindex $astroid_oth 7 ]
#               gren_info "Flux = $flux\n"
#               set err [catch {set mag [format "%.3f" [expr -log10($flux)*2.5 + $const_mag] ]} msg ]
#               if {$err} {
#                  gren_erreur "ERREUR MAG : flux = $flux ; const_mag = $const_mag\n"
#                  continue
#               }
#               if {$flux < 0 } {
#                  gren_erreur "Flux Negatif\n"
#                  continue
#               }
#               gren_info "mag = $mag\n"
#            }
#         }
#      }

      set listsources [list $fields $sources]
      return
   }












   #
   # ::analyse_source::psf
   # Mesure de PSF d'une source
   #
   proc ::psf_tools::psf_listsources_auto { sent_listsources threshold limitradius saturation} {
   
      upvar $sent_listsources listsources

      global bddconf

      set log 0

      set fields  [lindex $listsources 0]
      set sources [lindex $listsources 1]

      set nbs [::manage_source::get_nb_sources_by_cata $listsources "IMG"]
      if {$log} {gren_info "nb sources to work : $nbs \n"}

      lappend fields [::analyse_source::get_fieldastroid]

      set newsources {}

      foreach s $sources {
         set a [llength $s]
         set err [ catch {set r [::psf_tools::method_global s $threshold $limitradius $saturation $::audace(bufNo)]} msg ]
         if {$err} {
            ::console::affiche_erreur "ERREUR PSF psf_listsources_auto: $msg\n"
         }
         lappend newsources $s
      }

      set listsources [list $fields $newsources]

   }







#- Fin du namespace -------------------------------------------------
}
