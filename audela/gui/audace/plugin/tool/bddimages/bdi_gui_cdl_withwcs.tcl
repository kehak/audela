## @file bdi_gui_cdl_withwcs.tcl
#  @brief     GUI d&eacute;di&eacute;e aux courbes de lumi&egrave;re avec WCS
#  @author    Jerome Berthier and Frederic Vachier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_cdl_withwcs.tcl]
#  @endcode

# $Id: bdi_gui_cdl_withwcs.tcl 13893 2016-05-23 17:12:26Z jberthier $

##
# @namespace bdi_gui_cdl_withwcs
# @brief GUI d&eacute;di&eacute;e aux courbes de lumi&egrave;re avec WCS
# @pre Requiert \c tools_cdl .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_gui_cdl_withwcs {

   global audace
   global bddconf

   variable fen
   variable stateback
   variable statenext
   variable nbstars
   variable nbstarssav
   variable analyser
   variable enregistrer
   variable block
   variable stoperreur

}


proc ::bdi_gui_cdl_withwcs::inittoconf {  } {

  global bddconf

   catch { unset ::tools_cdl::tabphotom                    }
   catch { unset ::tools_cdl::id_current_image             }
   catch { unset ::tools_cdl::current_image                }
   catch { unset ::tools_cdl::current_cata                 }
   catch { unset ::tools_cdl::current_image_name           }
   catch { unset ::tools_cdl::current_image_date           }
   catch { unset ::tools_cdl::current_image_jjdate         }
   catch { unset ::tools_cdl::img_list                     }
   catch { unset ::tools_cdl::nb_img_list                  }
   catch { unset ::tools_cdl::current_listsources          }
   catch { unset ::tools_cdl::tabsource                    }
   catch { unset ::tools_cdl::saturation                   }
   catch { unset ::tools_cdl::movingobject                 }
   catch { unset ::tools_cdl::bestdelta                    }
   catch { unset ::tools_cdl::deltamin                     }
   catch { unset ::tools_cdl::deltamax                     }
   catch { unset ::tools_cdl::magref                       }
   catch { unset ::tools_cdl::starref                      }
   catch { unset ::tools_cdl::firstrefstar                 }

   catch { unset ::bdi_gui_cdl_withwcs::nbstars                }
   catch { unset ::bdi_gui_cdl_withwcs::nbstarssav             }
   catch { unset ::bdi_gui_cdl_withwcs::analyser               }
   catch { unset ::bdi_gui_cdl_withwcs::enregistrer            }
   catch { unset ::bdi_gui_cdl_withwcs::block                  }
   catch { unset ::bdi_gui_cdl_withwcs::stoperreur             }
   catch { unset ::bdi_gui_cdl_withwcs::directaccess           }


   set ::tools_cdl::saturation 50000
   set ::tools_cdl::tabsource(star1,delta) 15
   set ::tools_cdl::tabsource(obj,delta) 15
   set ::tools_cdl::movingobject 1
   set ::tools_cdl::bestdelta 1
   set ::tools_cdl::deltamin 5
   set ::tools_cdl::deltamax 30
   set ::tools_cdl::nbporbit 5
   set ::tools_cdl::firstmagref 12.000

   set ::bdi_gui_cdl_withwcs::nbstars 1
   set ::bdi_gui_cdl_withwcs::nbstarssav 1
   set ::bdi_gui_cdl_withwcs::analyser disabled
   set ::bdi_gui_cdl_withwcs::enregistrer disabled
   set ::bdi_gui_cdl_withwcs::block 1
   set ::bdi_gui_cdl_withwcs::stoperreur 1
   set ::bdi_gui_cdl_withwcs::directaccess 1

# Penser a retirer d ici lorsque modif createcata
   ::bdi_gui_cata::inittoconf
# -----------------------------------------------

   set ::tools_cdl::nomobj ""
   if { ! [info exists bddconf(cdl_savedir)] } {
      set ::tools_cdl::savedir $bddconf(dirtmp)
   } else {
      set ::tools_cdl::savedir $bddconf(cdl_savedir)
   }

   set ::tools_cdl::uncosm_param1 0.8
   set ::tools_cdl::uncosm_param2 100
   set ::tools_cdl::uncosm        0

}




proc ::bdi_gui_cdl_withwcs::fermer {  } {

   cleanmark
   destroy $::bdi_gui_cdl_withwcs::fen
}




proc ::bdi_gui_cdl_withwcs::change_uncosm {  } {

global audace

   gren_info "UNCOSMIC = $::tools_cdl::uncosm : "
   if {$::tools_cdl::uncosm == 1} {
      gren_info "EFFECTUE UNCOSMIC\n"
      ::tools_cdl::myuncosmic $::audace(bufNo)
      ::audace::autovisu $::audace(visuNo)
   } else {
      gren_info "CHARGEMENT IMAGE DEPART\n"
      ::bdi_gui_cdl_withwcs::charge_current_image

   }
}




# Mesure photometrique d'une source sur l image courante.

proc ::bdi_gui_cdl_withwcs::mesure_une { sources starx } {

   set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,err) false
   set err [ catch {set valeurs [::tools_cdl::mesure_obj \
            $::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,x) \
            $::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,y) \
            $::tools_cdl::tabsource($starx,delta) $::audace(bufNo)]} msg ]

   gren_info "PHOTOM $starx : $valeurs \n "

   if { $valeurs == -1 } {
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,err) true
      $sources.ra.$starx configure -bg red
      $sources.dec.$starx configure -bg red
      return
   } else {

      $sources.ra.$starx configure -bg "#ffffff"
      $sources.dec.$starx configure -bg "#ffffff"

      set xsm      [lindex $valeurs 0]
      set ysm      [lindex $valeurs 1]

      set a [buf$::audace(bufNo) xy2radec [list $xsm $ysm]]
      set ra_deg  [lindex $a 0]
      set dec_deg [lindex $a 1]
      set ra_hms  [mc_angle2hms $ra_deg 360 zero 1 auto string]
      set dec_dms [mc_angle2dms $dec_deg 90 zero 1 + string]
      set ra_hms  [string map {h : m : s .} $ra_hms]
      set dec_dms [string map {d : m : s .} $dec_dms]
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,x)           $xsm
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,y)           $ysm
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,ra_deg)      $ra_deg
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,dec_deg)     $dec_deg
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,ra_hms)      $ra_hms
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,dec_dms)     $dec_dms

      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,fwhmx)       [lindex $valeurs 2]
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,fwhmy)       [lindex $valeurs 3]
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,fwhm)        [lindex $valeurs 4]
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,fluxintegre) [lindex $valeurs 5]
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,errflux)     [lindex $valeurs 6]
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,pixmax)      [lindex $valeurs 7]
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,intensite)   [lindex $valeurs 8]
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,sigmafond)   [lindex $valeurs 9]
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,snint)       [lindex $valeurs 10]
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,snpx)        [lindex $valeurs 11]
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,delta)       [lindex $valeurs 12]

      set err [ catch {set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,maginstru)   [expr -log10([lindex $valeurs 5]/20000.)*2.5] } msg ]
      if {$err} {::console::affiche_erreur "Calcul mag_instru $err $msg $starx : $valeurs\n"}

      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,jjdate)      $::tools_cdl::current_image_jjdate
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,isodate)     $::tools_cdl::current_image_date


      if { [lindex $valeurs 7] > $::tools_cdl::saturation} {

         set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,err) true
         set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,saturation) true
         #if { $starx != "star1" } {$sources.mag.$starx configure -text "Sature"}
         #$sources.mag.$starx configure -bg red
         set mesure "bad"

      } else {

         set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,saturation) false

         #set xsmdiff  [expr ($xsm - $::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,x))*0.44*1000.0]
         #set ysmdiff  [expr ($ysm - $::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,y))*0.44*1000.0]
         #gren_info "DIFF $starx (mas): $xsmdiff $ysmdiff \n"


         $sources.ra.$starx   delete 0 end
         $sources.ra.$starx   insert end $ra_hms
         $sources.dec.$starx  delete 0 end
         $sources.dec.$starx  insert end $dec_dms
         $sources.mag.$starx  configure -bg "#ece9d8"

      }



   }


# Recherche du Meilleur Delta


   if { $::tools_cdl::bestdelta == 1 } {


      for {set rdelta $::tools_cdl::deltamin} {$rdelta<=$::tools_cdl::deltamax} {incr rdelta} {

         set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,search_delta,$rdelta,err) false
         set err [ catch {set valeurs [::tools_cdl::mesure_obj \
            $::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,x) \
            $::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,y) \
            $rdelta $::audace(bufNo)]} msg ]

         if { $valeurs == -1 || [lindex $valeurs 5]<0} {
            set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,search_delta,$rdelta,err) true
         } else {

            set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,search_delta,$rdelta,fwhmx)       [lindex $valeurs 2]
            set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,search_delta,$rdelta,fwhmy)       [lindex $valeurs 3]
            set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,search_delta,$rdelta,fwhm)        [lindex $valeurs 4]
            set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,search_delta,$rdelta,fluxintegre) [lindex $valeurs 5]
            set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,search_delta,$rdelta,errflux)     [lindex $valeurs 6]
            set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,search_delta,$rdelta,pixmax)      [lindex $valeurs 7]
            set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,search_delta,$rdelta,intensite)   [lindex $valeurs 8]
            set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,search_delta,$rdelta,sigmafond)   [lindex $valeurs 9]
            set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,search_delta,$rdelta,snint)       [lindex $valeurs 10]
            set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,search_delta,$rdelta,snpx)        [lindex $valeurs 11]
            set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,search_delta,$rdelta,delta)       [lindex $valeurs 12]

            set err [ catch {set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,search_delta,$rdelta,maginstru) [expr -log10([lindex $valeurs 5]/20000.)*2.5] } msg ]
            if {$err} {
               ::console::affiche_erreur "calcul mag_instru  $err $msg OBJ=$starx DELTA=[lindex $valeurs 12] FLUX=[lindex $valeurs 5] : $valeurs\n"
            }



            if { [lindex $valeurs 7] > $::tools_cdl::saturation} {
               set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,search_delta,$rdelta,err) true
               set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,search_delta,$rdelta,saturation) true
            } else {
               set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,search_delta,$rdelta,saturation) false
            }

         # Fin  if valeur mesur�e est bonne ou pas
         }
      # fin boucle sur les delta
      }
   # fin if bestdelta
   }

   return
}




proc ::bdi_gui_cdl_withwcs::update_bdi { img result } {


    #gren_info "IMG = $img \n"
    #gren_info "RESULT = $result \n"

    set idbddimg    [::bddimages_liste::lget $img idbddimg]
    set tabname     [::bddimages_liste::lget $img tabname]
    #gren_info "IDBDDIMG = $idbddimg \n"
    #gren_info "TABNAME  = $tabname \n"



   set sqlcmd "UPDATE $tabname
                  SET bddimages_photometry='$result'
                WHERE idbddimg = $idbddimg;"

   set err [catch {set resultcount [::bddimages_sql::sql select $sqlcmd]} msg]
   if {$err} {
      ::console::affiche_erreur "Erreur maj de la table $tabname\n"
      ::console::affiche_erreur "       sqlcmd = $sqlcmd\n"
      ::console::affiche_erreur "       err = $err\n"
      ::console::affiche_erreur "       msg = $msg\n"
      return
   }

   return
}




proc ::bdi_gui_cdl_withwcs::mesure_tout { sources } {

   #gren_info "ZOOM: [::confVisu::getZoom $::audace(visuNo)] \n "

   if { [ $sources.select.obj cget -relief] == "sunken" } {
      ::bdi_gui_cdl_withwcs::mesure_une $sources obj
   }

   for {set x 1} {$x<=$::bdi_gui_cdl_withwcs::nbstars} {incr x} {
      if { [ $sources.select.star$x cget -relief] == "sunken" } {
         ::bdi_gui_cdl_withwcs::mesure_une $sources star$x
      }
   }

   ::bdi_gui_cdl_withwcs::calc_mag $sources
   ::bdi_gui_cdl_withwcs::gui_update_sources $sources

   return 0

}





proc ::bdi_gui_cdl_withwcs::get_stdev { magref starref star } {

   set mag ""

   for {set i 0} {$i<$::tools_cdl::nb_img_list} {incr i} {
      if {  [info exists ::tools_cdl::tabphotom($i,$starref,fluxintegre) ] } {
         set fluxref $::tools_cdl::tabphotom($i,$starref,fluxintegre)
         if {  [info exists ::tools_cdl::tabphotom($i,$star,fluxintegre) ] } {
            #gren_info "get_stdev : $magref $::tools_cdl::tabphotom($i,$star,fluxintegre) $fluxref\n"
            if {$::tools_cdl::tabphotom($i,$star,fluxintegre)>0 && $fluxref>0} {
               lappend mag [expr $magref - log10($::tools_cdl::tabphotom($i,$star,fluxintegre)/$fluxref)*2.5]
            }
         }
      }
   }
   set sum 0
   set cpt 0
   foreach m $mag  {
      set sum [expr $sum + $m]
      incr cpt
   }
   set moy [expr $sum / $cpt ]

   set sum 0
   foreach m $mag  {
      set sum [expr $sum + pow($m - $moy,2)]
   }
   set stdev [expr sqrt($sum/$cpt)]
   return [list $moy $stdev]
}




proc ::bdi_gui_cdl_withwcs::is_good { starx } {

   catch {
      if {0} {
         gren_info "**\n"
         gren_info "source : $starx\n"
         gren_info "err : $::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,err)\n"
         gren_info "select : $::tools_cdl::tabsource($starx,select)\n"
         gren_info "saturation : $::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,saturation)\n"
      }
   }


   if { ! [info exists ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,err) ] } { return false }
   if { $::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,err) } { return false }
   if { ! $::tools_cdl::tabsource($starx,select) } { return false }
   if { $::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,saturation) } { return false }

   return true
}


proc ::bdi_gui_cdl_withwcs::is_selected { starx } {

   if { ! [info exists ::tools_cdl::tabsource($starx,select) ] } { return false }
   if { ! $::tools_cdl::tabsource($starx,select) } { return false }
   return true
}






proc ::bdi_gui_cdl_withwcs::calc_mag { sources } {


   # test si l etoile de reference est encore d actualite
   set newref false
   if { ! [info exists ::tools_cdl::starref ] } {
      gren_info "star ref n existe pas !\n"
      set newref true
   } else {
      if { ! [::bdi_gui_cdl_withwcs::is_good $::tools_cdl::starref] } {
         gren_info "star ref $::tools_cdl::starref n est plus bonne !\n"
         set newref true
      }
   }
   if { $newref } {
      gren_info "Change star ref !\n"
      set found 0
      for {set x 1} {$x<=$::bdi_gui_cdl_withwcs::nbstars} {incr x} {
         if { [::bdi_gui_cdl_withwcs::is_good "star$x"] } {
            set ::tools_cdl::starref star$x
            if { [info exists ::tools_cdl::magref] } {unset ::tools_cdl::magref}
            set found 1
            break
         }
      }
      if { $found == 0 } {
         #tk_messageBox -message "Veuillez selectionner une etoile de reference et entrer sa magnitude" -type ok
         return
      } else {
         gren_info "new star ref : $::tools_cdl::starref \n"
      }
   } else {
      gren_info "star ref : $::tools_cdl::starref is GOOD  !\n"
   }

   if {  ! [info exists ::tools_cdl::magref ] } {
      set ::tools_cdl::magref [string trim [$sources.mag.$::tools_cdl::starref cget -text]]
      if { ! [string is double -strict $::tools_cdl::magref] } {
         #tk_messageBox -message "Veuillez entrer une magnitude valide pour l'etoile star$x" -type ok
         return
      }
   }

   # Mesure photometrique des etoiles
   set fluxref $::tools_cdl::tabphotom($::tools_cdl::id_current_image,$::tools_cdl::starref,fluxintegre)

   for {set x 1} {$x<=$::bdi_gui_cdl_withwcs::nbstars} {incr x} {
      if { "star$x" == "$::tools_cdl::starref" } {
         set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,mag) $::tools_cdl::magref
         if { $::tools_cdl::bestdelta == 1 } {
            for {set rdelta $::tools_cdl::deltamin} {$rdelta<=$::tools_cdl::deltamax} {incr rdelta} {
               set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,search_delta,$rdelta,mag) $::tools_cdl::magref
            }
         }
      }
      if {  [::bdi_gui_cdl_withwcs::is_good "star$x"] } {
         set flux $::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,fluxintegre)
         #gren_info "calc_mag : $::tools_cdl::magref $flux $fluxref\n"
         set m [expr $::tools_cdl::magref - log10($flux/$fluxref)*2.5]
         set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,mag) $m
         if { $::tools_cdl::bestdelta == 1 } {
            for {set rdelta $::tools_cdl::deltamin} {$rdelta<=$::tools_cdl::deltamax} {incr rdelta} {
               if {! [info exists ::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,search_delta,$rdelta,fluxintegre) ] } {
                  set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,search_delta,$rdelta,mag) 9999999
                  continue
               }
               set flux $::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,search_delta,$rdelta,fluxintegre)
               if {! [info exists ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$::tools_cdl::starref,search_delta,$rdelta,fluxintegre) ] } {
                  set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,search_delta,$rdelta,mag) 9999999
                  continue
               }
               set fluxrefd $::tools_cdl::tabphotom($::tools_cdl::id_current_image,$::tools_cdl::starref,search_delta,$rdelta,fluxintegre)
               set m [expr $::tools_cdl::magref - log10($flux/$fluxrefd)*2.5]
               set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,search_delta,$rdelta,mag) $m
            }
         }
      }
   }

   for {set x 1} {$x<=$::bdi_gui_cdl_withwcs::nbstars} {incr x} {
      if { "star$x" == "$::tools_cdl::starref" } { continue }
      if {[::bdi_gui_cdl_withwcs::is_good "star$x"] } {
         set val [::bdi_gui_cdl_withwcs::get_stdev $::tools_cdl::magref $::tools_cdl::starref star$x]
         $sources.mag.star$x configure -text [format "%2.3f" [lindex $val 0]]
         $sources.stdev.star$x configure -text [format "%2.3f" [lindex $val 1]]
      }
   }

   # Mesure photometrique de l objet
   if { [::bdi_gui_cdl_withwcs::is_good obj] } {
      gren_info "obj : is GOOD !\n"
      set flux $::tools_cdl::tabphotom($::tools_cdl::id_current_image,obj,fluxintegre)
      #gren_info "calc_mag : $::tools_cdl::magref $flux $fluxref\n"
      if {$flux < 0} {set flux 0}
      set m [expr $::tools_cdl::magref - log10($flux/$fluxref)*2.5]
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,obj,mag) $m
      #gren_info "ref=$flux $fluxref $m\n"
      if { $::tools_cdl::bestdelta == 1 } {
         for {set rdelta $::tools_cdl::deltamin} {$rdelta<=$::tools_cdl::deltamax} {incr rdelta} {
            if {$::tools_cdl::tabphotom($::tools_cdl::id_current_image,obj,search_delta,$rdelta,err)==true} {continue}
            set flux $::tools_cdl::tabphotom($::tools_cdl::id_current_image,obj,search_delta,$rdelta,fluxintegre)
            if {! [info exists ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$::tools_cdl::starref,search_delta,$rdelta,fluxintegre) ] } {
               continue
            }
            set fluxrefd $::tools_cdl::tabphotom($::tools_cdl::id_current_image,$::tools_cdl::starref,search_delta,$rdelta,fluxintegre)
            set m [expr $::tools_cdl::magref - log10($flux/$fluxrefd)*2.5]
            set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,obj,search_delta,$rdelta,mag) $m
            if {$rdelta == 15} {
               #gren_info "d15=$flux $fluxrefd $m\n"
            }
         }
      }
      set val [::bdi_gui_cdl_withwcs::get_stdev $::tools_cdl::magref $::tools_cdl::starref obj]
      $sources.mag.obj   configure -text [format "%2.3f" $::tools_cdl::tabphotom($::tools_cdl::id_current_image,obj,mag)]
      $sources.stdev.obj configure -text [format "%2.3f" [lindex $val 1]]
   }

   return
}





proc ::bdi_gui_cdl_withwcs::gui_update_sources { sources } {


   if { ! [info exists ::tools_cdl::starref ] } {
       for {set x 1} {$x<=$::bdi_gui_cdl_withwcs::nbstars} {incr x} {
          $sources.name.star$x configure -foreground black
          if { $x == 1 } {
          } else {
          }
       }
       return
   }

   for {set x 1} {$x<=$::bdi_gui_cdl_withwcs::nbstars} {incr x} {
      if { "star$x" == "$::tools_cdl::starref"} {
         if { [::bdi_gui_cdl_withwcs::is_good "star$x"] } {
            $sources.name.$::tools_cdl::starref configure -foreground blue
            set radius [expr floor ([::confVisu::getZoom $::audace(visuNo)] * $::tools_cdl::tabsource(star$x,delta)) / 2.0 ]
            affich_un_rond_xy $::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,x) \
                              $::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,y) \
                              blue $radius 2
         }
      } else {
         if { [::bdi_gui_cdl_withwcs::is_good "star$x"] } {
            $sources.name.star$x configure -foreground darkgreen
            set radius [expr floor ([::confVisu::getZoom $::audace(visuNo)] * $::tools_cdl::tabsource(star$x,delta)) / 2.0 ]
            affich_un_rond_xy $::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,x) \
                              $::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,y) \
                              green $radius 1
         } else {
            if { [::bdi_gui_cdl_withwcs::is_selected "star$x"] } {
               $sources.name.star$x configure -foreground red
               set radius [expr floor ([::confVisu::getZoom $::audace(visuNo)] * $::tools_cdl::tabsource(star$x,delta)) / 2.0]
               affich_un_rond_xy $::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,x) \
                                 $::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,y) \
                                 red $radius 1
            } else {
               $sources.name.star$x configure -foreground black

            }
         }
      }
   }

   if { [::bdi_gui_cdl_withwcs::is_good "obj"] } {
      $sources.name.obj configure -foreground darkgreen
      set radius [expr floor ([::confVisu::getZoom $::audace(visuNo)] * $::tools_cdl::tabsource(obj,delta)) / 2.0 ]
      affich_un_rond_xy $::tools_cdl::tabphotom($::tools_cdl::id_current_image,obj,x) \
                        $::tools_cdl::tabphotom($::tools_cdl::id_current_image,obj,y) \
                        yellow $radius 1
   } else {
      if { [::bdi_gui_cdl_withwcs::is_selected "obj"] } {
         $sources.name.obj configure -foreground red
         set radius [expr floor ([::confVisu::getZoom $::audace(visuNo)] * $::tools_cdl::tabsource(obj,delta)) / 2.0 ]
         affich_un_rond_xy $::tools_cdl::tabphotom($::tools_cdl::id_current_image,obj,x) \
                           $::tools_cdl::tabphotom($::tools_cdl::id_current_image,obj,y) \
                           red $radius 1
      } else {
         $sources.name.obj configure -foreground black

      }
   }



   return
}





proc ::bdi_gui_cdl_withwcs::change_refstars { sources } {

   gren_info "nb stars = $::bdi_gui_cdl_withwcs::nbstars \n"

   if {$::bdi_gui_cdl_withwcs::nbstars ==1 && $::bdi_gui_cdl_withwcs::nbstarssav == 1} {
      set ::bdi_gui_cdl_withwcs::nbstarssav $::bdi_gui_cdl_withwcs::nbstars
      return
   }


   if {$::bdi_gui_cdl_withwcs::nbstars<$::bdi_gui_cdl_withwcs::nbstarssav} {

      set x $::bdi_gui_cdl_withwcs::nbstarssav

      destroy $sources.name.star$x
      destroy $sources.ra.star$x
      destroy $sources.dec.star$x
      destroy $sources.mag.star$x
      destroy $sources.delta.star$x
      destroy $sources.select.star$x

   } else {

      set x $::bdi_gui_cdl_withwcs::nbstars

      label   $sources.name.star$x -text "Star$x :"
      entry   $sources.ra.star$x   -relief sunken -width 11
      entry   $sources.dec.star$x  -relief sunken -width 11
      label   $sources.mag.star$x  -width 9
      label   $sources.stdev.star$x -width 9
      spinbox $sources.delta.star$x -from 1 -to 100 -increment 1 -command "" -width 3 \
                -command "::bdi_gui_cdl_withwcs::mesure_tout $sources" \
                -textvariable ::tools_cdl::tabsource(star$x,delta)
      button  $sources.select.star$x -text "Select" -command "::bdi_gui_cdl_withwcs::select_source $sources star$x"

      pack $sources.name.star$x   -in $sources.name   -side top -pady 2 -ipady 2
      pack $sources.ra.star$x     -in $sources.ra     -side top -pady 2 -ipady 2
      pack $sources.dec.star$x    -in $sources.dec    -side top -pady 2 -ipady 2
      pack $sources.mag.star$x    -in $sources.mag    -side top -pady 2 -ipady 2
      pack $sources.stdev.star$x  -in $sources.stdev  -side top -pady 2 -ipady 2
      pack $sources.delta.star$x  -in $sources.delta  -side top -pady 2 -ipady 2
      pack $sources.select.star$x -in $sources.select -side top

      set ::tools_cdl::tabsource(star$x,delta) 15
   }

   set ::bdi_gui_cdl_withwcs::nbstarssav $::bdi_gui_cdl_withwcs::nbstars
   return
}





proc ::bdi_gui_cdl_withwcs::select_source { sources starx } {

   gren_info "source = $starx \n"
   gren_info "delta = $::tools_cdl::tabsource($starx,delta) \n"


   if {[ $sources.select.$starx cget -relief] == "raised"} {

      set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
      #buf$::audace(bufNo)
      if {$err>0 || $rect ==""} {
         ::console::affiche_erreur "$msg\n"
         ::console::affiche_erreur "      * * * *\n"
         ::console::affiche_erreur "Selectionnez un cadre dans l'image\n"
         ::console::affiche_erreur "      * * * *\n"

         return
      }
      set err [ catch {set valeurs [::tools_cdl::select_obj $rect $::audace(bufNo)]} msg ]
      if {$err>0} {
         ::console::affiche_erreur "$msg\n"
         ::console::affiche_erreur "      * * * *\n"
         ::console::affiche_erreur "Mesure Photometrique impossible\n"
         ::console::affiche_erreur "      * * * *\n"
         return
      }


      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,x) [lindex $valeurs 0]
      set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,$starx,y) [lindex $valeurs 1]
      set ::tools_cdl::tabsource($starx,select) true
      $sources.select.$starx  configure -relief sunken

   } else {
      $sources.select.$starx  configure -relief raised
      set ::tools_cdl::tabsource($starx,select) false
      if { "$::tools_cdl::starref" == "$starx" } {
         unset ::tools_cdl::starref
         unset ::tools_cdl::magref
      }
   }

   ::bdi_gui_cdl_withwcs::mesure_tout $sources

}




# random --
#
#  Return a number in the range 0 .. $range-1
#
# Arguments:
#  range    integer range constraint
#
# Results:
#  Number in range [0..$range)
#
proc ::bdi_gui_cdl_withwcs::random {{range 100}} {
   return [expr {int(rand()*$range)}]
}





proc ::bdi_gui_cdl_withwcs::mobile {  } {


   set log 0

   if {$log} {gren_info "\nExtrapolation d orbite\n"}

  set nbpt 0

   for {set i 0} {$i<$::tools_cdl::nb_img_list} {incr i} {

      if { [info exists ::tools_cdl::tabphotom($i,obj,ra_deg)  ] && [info exists ::tools_cdl::tabphotom($i,obj,dec_deg) ] && [info exists ::tools_cdl::tabphotom($i,obj,jjdate)  ] } {

         set tab($nbpt,date) $::tools_cdl::tabphotom($i,obj,jjdate)
         set tab($nbpt,ra)   $::tools_cdl::tabphotom($i,obj,ra_deg)
         set tab($nbpt,dec)  $::tools_cdl::tabphotom($i,obj,dec_deg)
         if {$log} {gren_info "param = $nbpt $tab($nbpt,date) $tab($nbpt,ra) $tab($nbpt,dec)  \n"}
         incr nbpt
      }

   }

   if {$log} {gren_info "nb points : $nbpt \n"}

   if { $nbpt == 0 } {
       # Avec zero point on peut rien faire
      return
   }

   if { $nbpt == 1 } {
       # Avec un point on peut rien faire
       set ra  $tab(0,ra)
       set dec $tab(0,dec)
   } else {

       #gren_info "nbporbit = $::tools_cdl::nbporbit\n"

       if { $nbpt < $::tools_cdl::nbporbit} {
          if {$nbpt == 2 } { set nbporbit 2}
          if {$nbpt == 3 } { set nbporbit 3}
          if {$nbpt == 4 } { set nbporbit 3}
          if {$nbpt == 5 } { set nbporbit 5}
          if {$nbpt == 6 } { set nbporbit 5}
          if {$nbpt == 7 } { set nbporbit 5}
          if {$nbpt == 8 } { set nbporbit 5}
       } else {
          set nbporbit $::tools_cdl::nbporbit
       }


       set c 0
       set part [ expr ($nbpt-1.0) / ($nbporbit-1.0) ]
       set i 0
       while { $i<$nbporbit } {
          #gren_info "$i -> [expr int($c)] ($c)\n"
          set id($i) [expr int($c)]
          set c [expr ($c + $part)]
          incr i
       }


       # A Partir de 2 points on peut interpoler
       set  aa ""
       set  ad ""
       for {set xi 0} {$xi<[ expr $nbporbit - 1]} {incr xi} {
          for {set xj [expr $xi +1 ] } {$xj<$nbporbit} {incr xj} {
              set i $id($xi)
              set j $id($xj)
              #gren_info "i j  =  $i $j\n"
              lappend aa [expr ( $tab($i,ra)  - $tab($j,ra)   ) / ( $tab($i,date) - $tab($j,date) )]
              lappend ad [expr ( $tab($i,dec) - $tab($j,dec)  ) / ( $tab($i,date) - $tab($j,date) )]
              #lappend ba [expr ( $tab($j,ra)  * $tab($i,date)  -  $tab($i,ra)   * $tab($j,date) ) / ( $tab($i,date) - $tab($j,date) ) ]
              #lappend bd [expr ( $tab($j,dec) * $tab($i,date)  -  $tab($i,dec)  * $tab($j,date) ) / ( $tab($i,date) - $tab($j,date) ) ]
          }
       }
       set  aa [lsort $aa]
       set  ad [lsort $ad]
       set aa [lindex $aa [format "%d" [expr int([llength $aa]/2)]]]
       set ad [lindex $ad [format "%d" [expr int([llength $ad]/2)]]]

       set  ba ""
       set  bd ""
       for {set xi 0} {$xi<[ expr $nbporbit - 1]} {incr xi} {
          for {set xj [expr $xi +1 ] } {$xj<$nbporbit} {incr xj} {
              set i $id($xi)
              set j $id($xj)
              #gren_info "i j  =  $i $j\n"
              lappend ba [expr $tab($i,ra) - $aa * $tab($i,date) ]
              lappend ba [expr $tab($j,ra) - $aa * $tab($j,date) ]
              lappend bd [expr $tab($i,dec) - $ad * $tab($i,date) ]
              lappend bd [expr $tab($j,dec) - $ad * $tab($j,date) ]
          }
       }

       set  ba [lsort $ba]
       set  bd [lsort $bd]

       set ba [lindex $ba [format "%d" [expr int([llength $ba]/2)]]]
       set bd [lindex $bd [format "%d" [expr int([llength $bd]/2)]]]

       gren_info "ra  =  $aa * jj + $ba \n"
       gren_info "dec =  $ad * jj + $bd \n"

       set ra  [expr $aa * $::tools_cdl::current_image_jjdate + $ba]
       set dec [expr $ad * $::tools_cdl::current_image_jjdate + $bd]
    }

    # Transformation en coordonnees XY
    if {$log} {gren_info "coord =  $ra $dec\n"}

    set xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
    set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,obj,x) [lindex $xy 0]
    set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,obj,y) [lindex $xy 1]

    if {$log} {gren_info "MOVING OBJ X Y =  [lindex $xy 0] [lindex $xy 1]\n"}

    return
}





proc ::bdi_gui_cdl_withwcs::extrapole {  } {


   if { ! [info exists ::tools_cdl::tabphotom($::tools_cdl::id_current_image,obj,x) ] \
     || ! [info exists ::tools_cdl::tabphotom($::tools_cdl::id_current_image,obj,y) ]  } {
      gren_info "obj n existe pas \n"

      if {$::tools_cdl::movingobject } {
         ::bdi_gui_cdl_withwcs::mobile
      } else {

         for {set i 0} {$i<$::tools_cdl::nb_img_list} {incr i} {

            if { [info exists ::tools_cdl::tabphotom($i,obj,ra_deg) ] && [info exists ::tools_cdl::tabphotom($i,obj,dec_deg) ] } {
               set ra_deg  $::tools_cdl::tabphotom($i,obj,ra_deg)
               set dec_deg $::tools_cdl::tabphotom($i,obj,dec_deg)
               set xy [ buf$::audace(bufNo) radec2xy [ list $ra_deg $dec_deg ] ]
               set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,obj,x) [lindex $xy 0]
               set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,obj,y) [lindex $xy 1]
               break
            }
         }
      }


   } else {
      gren_info "obj x y = $::tools_cdl::tabphotom($::tools_cdl::id_current_image,obj,x) $::tools_cdl::tabphotom($::tools_cdl::id_current_image,obj,y)\n"
   }


   for {set x 1} {$x<=$::bdi_gui_cdl_withwcs::nbstars} {incr x} {

      if { ! [info exists ::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,x) ] || ! [info exists ::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,y) ]  } {
         gren_info "star$x n existe pas \n"

         for {set i 0} {$i<$::tools_cdl::nb_img_list} {incr i} {

            if { [info exists ::tools_cdl::tabphotom($i,star$x,ra_deg) ] && [info exists ::tools_cdl::tabphotom($i,star$x,dec_deg) ] } {
               set ra_deg  $::tools_cdl::tabphotom($i,star$x,ra_deg)
               set dec_deg $::tools_cdl::tabphotom($i,star$x,dec_deg)
               set xy [ buf$::audace(bufNo) radec2xy [ list $ra_deg $dec_deg ] ]
               set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,x) [lindex $xy 0]
               set ::tools_cdl::tabphotom($::tools_cdl::id_current_image,star$x,y) [lindex $xy 1]
               break
            }

         }


      }

   }


}





proc ::bdi_gui_cdl_withwcs::next { sources } {

      set cpt 0

      while {$cpt<$::bdi_gui_cdl_withwcs::block} {

         if {$::tools_cdl::id_current_image < $::tools_cdl::nb_img_list} {
            incr ::tools_cdl::id_current_image
            ::bdi_gui_cdl_withwcs::charge_current_image
            ::bdi_gui_cdl_withwcs::extrapole
            set err [::bdi_gui_cdl_withwcs::mesure_tout $sources]
            if {$err==1 && $::bdi_gui_cdl_withwcs::stoperreur==1} {
               break
            }
         }
         incr cpt
      }
}

proc ::bdi_gui_cdl_withwcs::back { sources } {

      if {$::tools_cdl::id_current_image > 1 } {
         incr ::tools_cdl::id_current_image -1
         ::bdi_gui_cdl_withwcs::charge_current_image
         ::bdi_gui_cdl_withwcs::extrapole
         ::bdi_gui_cdl_withwcs::mesure_tout $sources
      }
}

proc ::bdi_gui_cdl_withwcs::go { sources } {

      set ::tools_cdl::id_current_image $::bdi_gui_cdl_withwcs::directaccess
      if {$::tools_cdl::id_current_image > $::tools_cdl::nb_img_list} {
         set ::tools_cdl::id_current_image $::tools_cdl::nb_img_list
      }
      if {$::tools_cdl::id_current_image < 1} {
         set ::tools_cdl::id_current_image 1
         set ::bdi_gui_cdl_withwcs::directaccess 1
      }
      set ::bdi_gui_cdl_withwcs::directaccess $::tools_cdl::id_current_image

      ::bdi_gui_cdl_withwcs::charge_current_image
      ::bdi_gui_cdl_withwcs::extrapole
      set err [::bdi_gui_cdl_withwcs::mesure_tout $sources]
}




proc ::bdi_gui_cdl_withwcs::charge_current_image { } {

   global audace
   global bddconf

      # Charge l image en memoire
      set ::tools_cdl::current_image [lindex $::tools_cdl::img_list [expr $::tools_cdl::id_current_image - 1] ]
      set tabkey      [::bddimages_liste::lget $::tools_cdl::current_image "tabkey"]
      set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
      set exposure    [string trim [lindex [::bddimages_liste::lget $tabkey "exposure"]   1] ]

      set idbddimg    [::bddimages_liste::lget $::tools_cdl::current_image idbddimg]
      set dirfilename [::bddimages_liste::lget $::tools_cdl::current_image dirfilename]
      set filename    [::bddimages_liste::lget $::tools_cdl::current_image filename   ]
      set file        [file join $bddconf(dirbase) $dirfilename $filename]
      set ::tools_cdl::current_image_name $filename
      set ::tools_cdl::current_image_jjdate [expr [mc_date2jd $date] + $exposure / 86400.0 / 2.0]
      set ::tools_cdl::current_image_date [mc_date2iso8601 $::tools_cdl::current_image_jjdate]

      gren_info "\nCharge Image cur: $date  ($exposure)\n"
      #gren_info "Charge Image cur: $::tools_cdl::current_image_date ($::tools_cdl::current_image_jjdate) \n"

      # Charge l image
      buf$::audace(bufNo) load $file
      cleanmark

      # EFFECTUE UNCOSMIC
      if {$::tools_cdl::uncosm == 1} {
         ::tools_cdl::myuncosmic $::audace(bufNo)
      }

      # VIsualisation par Sseuil automatique
      ::audace::autovisu $::audace(visuNo)

      # Mise a jour GUI
      $::bdi_gui_cdl_withwcs::fen.frm_cdlwcs.bouton.back configure -state disabled
      $::bdi_gui_cdl_withwcs::fen.frm_cdlwcs.bouton.back configure -state disabled
      $::bdi_gui_cdl_withwcs::fen.frm_cdlwcs.infoimage.nomimage    configure -text $::tools_cdl::current_image_name
      $::bdi_gui_cdl_withwcs::fen.frm_cdlwcs.infoimage.dateimage   configure -text $::tools_cdl::current_image_date
      $::bdi_gui_cdl_withwcs::fen.frm_cdlwcs.infoimage.stimage     configure -text "$::tools_cdl::id_current_image / $::tools_cdl::nb_img_list"

      gren_info " $::tools_cdl::current_image_name \n"

      if {$::tools_cdl::id_current_image == 1 && $::tools_cdl::nb_img_list > 1 } {
         $::bdi_gui_cdl_withwcs::fen.frm_cdlwcs.bouton.back configure -state disabled
      }
      if {$::tools_cdl::id_current_image == $::tools_cdl::nb_img_list && $::tools_cdl::nb_img_list > 1 } {
         $::bdi_gui_cdl_withwcs::fen.frm_cdlwcs.bouton.next configure -state disabled
      }
      if {$::tools_cdl::id_current_image > 1 } {
         $::bdi_gui_cdl_withwcs::fen.frm_cdlwcs.bouton.back configure -state normal
      }
      if {$::tools_cdl::id_current_image < $::tools_cdl::nb_img_list } {
         $::bdi_gui_cdl_withwcs::fen.frm_cdlwcs.bouton.next configure -state normal
      }


   # Affichage des asteroides dans l image
   set catafilenameexist [::bddimages_liste::lexist $::tools_cdl::current_image "catafilename"]
   if {$catafilenameexist==0} {return}
   set catafilename [::bddimages_liste::lget $::tools_cdl::current_image "catafilename"]
   set catadirfilename [::bddimages_liste::lget $::tools_cdl::current_image "catadirfilename"]
   set catafile [file join $bddconf(dirbase) $catadirfilename $catafilename]
   set errnum [catch {set catafile [::tools_cata::extract_cata_xml $catafile]} msg ]
   if {$errnum} { return -code $errnum $msg }
   set listsources [::tools_cata::get_cata_xml $catafile]
   set listsources [::bdi_tools_sources::set_common_fields $listsources IMG    { ra dec 5.0 calib_mag calib_mag_ss1}]
   #set listsources [::bdi_tools_sources::set_common_fields_skybot $listsources]
   affich_rond $listsources SKYBOT $::bdi_gui_cata::color_skybot 1
   catch { file delete -force  $catafile}

}




proc ::bdi_gui_cdl_withwcs::charge_list { img_list } {

   global audace
   global bddconf

   # Chargement de la liste
   set ::tools_cdl::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
   set ::tools_cdl::nb_img_list [llength $::tools_cdl::img_list]

   # Verification du WCS
   foreach ::tools_cdl::current_image $::tools_cdl::img_list {
      set tabkey     [::bddimages_liste::lget $::tools_cdl::current_image "tabkey"]
      set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
      set idbddimg    [::bddimages_liste::lget $::tools_cdl::current_image idbddimg]
      set bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs  ] 1]]
      gren_info " idbddimg : $idbddimg  - date : $date - WCS : bddimages_wcs\n"
   }

   # Chargement des variables
   set ::tools_cdl::id_current_image 1


   set ::tools_cdl::current_image [lindex $::tools_cdl::img_list 0]
   set tabkey         [::bddimages_liste::lget $::tools_cdl::current_image "tabkey"]
   set date           [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
   set exposure       [string trim [lindex [::bddimages_liste::lget $tabkey "exposure"]   1] ]
   set idbddimg       [::bddimages_liste::lget $::tools_cdl::current_image idbddimg]
   set dirfilename    [::bddimages_liste::lget $::tools_cdl::current_image dirfilename]
   set filename       [::bddimages_liste::lget $::tools_cdl::current_image filename   ]
   set file           [file join $bddconf(dirbase) $dirfilename $filename]
   set ::tools_cdl::current_image_name $filename
   set ::tools_cdl::current_image_date $date
   set ::tools_cdl::current_image_jjdate [expr [mc_date2jd $date] + $exposure / 86400.0 / 2.0]
   set ::tools_cdl::current_image_date [mc_date2iso8601 $::tools_cdl::current_image_jjdate]

   # Visualisation de l image
   cleanmark
   buf$::audace(bufNo) load $file
   ::audace::autovisu $::audace(visuNo)

   # Initialisation des boutons
   set ::bdi_gui_cdl_withwcs::stateback disabled
   if {$::tools_cdl::nb_img_list == 1} {
      set ::bdi_gui_cdl_withwcs::statenext disabled
   } else {
      set ::bdi_gui_cdl_withwcs::statenext normal
   }

   # Affichage des asteroides dans l image
   set catafilenameexist [::bddimages_liste::lexist $::tools_cdl::current_image "catafilename"]
   if {$catafilenameexist==0} {return}
   set catafilename [::bddimages_liste::lget $::tools_cdl::current_image "catafilename"]
   set catadirfilename [::bddimages_liste::lget $::tools_cdl::current_image "catadirfilename"]
   set catafile [file join $bddconf(dirbase) $catadirfilename $catafilename]
   set errnum [catch {set catafile [::tools_cata::extract_cata_xml $catafile]} msg ]
   if {$errnum} { return -code $errnum $msg }
   set listsources [::tools_cata::get_cata_xml $catafile]
   set listsources [::bdi_tools_sources::set_common_fields $listsources IMG    { ra dec 5.0 calib_mag calib_mag_ss1}]
   #set listsources [::bdi_tools_sources::set_common_fields_skybot $listsources]
   affich_rond $listsources SKYBOT $::bdi_gui_cata::color_skybot $::bdi_gui_cata::size_skybot

}




proc ::bdi_gui_cdl_withwcs::creation_cdlwcs { img_list } {

   global audace
   global bddconf

   ::bdi_gui_cdl_withwcs::inittoconf
   ::bdi_gui_cdl_withwcs::charge_list $img_list

   #--- Creation de la fenetre
   set ::bdi_gui_cdl_withwcs::fen .cdlwcs
   if { [winfo exists $::bdi_gui_cdl_withwcs::fen] } {
      wm withdraw $::bdi_gui_cdl_withwcs::fen
      wm deiconify $::bdi_gui_cdl_withwcs::fen
      focus $::bdi_gui_cdl_withwcs::fen
      return
   }
   toplevel $::bdi_gui_cdl_withwcs::fen -class Toplevel
   set posx_config [ lindex [ split [ wm geometry $::bdi_gui_cdl_withwcs::fen ] "+" ] 1 ]
   set posy_config [ lindex [ split [ wm geometry $::bdi_gui_cdl_withwcs::fen ] "+" ] 2 ]
   wm geometry $::bdi_gui_cdl_withwcs::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   wm resizable $::bdi_gui_cdl_withwcs::fen 1 1
   wm title $::bdi_gui_cdl_withwcs::fen "Creation du WCS"
   wm protocol $::bdi_gui_cdl_withwcs::fen WM_DELETE_WINDOW "destroy $::bdi_gui_cdl_withwcs::fen"
   set frm $::bdi_gui_cdl_withwcs::fen.frm_cdlwcs

   #--- Cree un frame general
   frame $frm -borderwidth 0 -cursor arrow -relief groove
   pack $frm -in $::bdi_gui_cdl_withwcs::fen -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


#--- Setup

     #--- Nom e l'Objet
     set nomobj [frame $frm.nomobj -borderwidth 0 -cursor arrow -relief groove]
     pack $nomobj -in $frm -anchor s -side top -expand 0 -fill x -padx 5 -pady 5
          label $nomobj.lab -text "Nom de l'objet"
          pack $nomobj.lab -in $nomobj -side left -padx 5 -pady 0
          entry $nomobj.val -relief sunken -textvariable ::tools_cdl::nomobj -width 25 \
          -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
          pack $nomobj.val -in $nomobj -side left -pady 1 -anchor w

     #--- Repertoire des resultats
     set savedir [frame $frm.savedir -borderwidth 0 -cursor arrow -relief groove]
     pack $savedir -in $frm -anchor s -side top -expand 0 -fill x -padx 5 -pady 5
          label $savedir.lab -text "Repertoire de sauvegarde"
          pack $savedir.lab -in $savedir -side left -padx 5 -pady 0
          entry $savedir.val -relief sunken -textvariable ::tools_cdl::savedir -width 50
          pack $savedir.val -in $savedir -side left -pady 1 -anchor w

     #--- Cree un frame pour afficher movingobject
     set move [frame $frm.move -borderwidth 0 -cursor arrow -relief groove]
     pack $move -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          #--- Cree un checkbutton
          checkbutton $move.check -highlightthickness 0 -text "Objet en mouvement" -variable ::tools_cdl::movingobject
          pack $move.check -in $move -side left -padx 5 -pady 0

     #--- Nb points pour deplacement
     set nbporbit [frame $frm.nbporbit -borderwidth 0 -cursor arrow -relief groove]
     pack $nbporbit -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
          label $nbporbit.lab -text "Nb points pour deplacement"
          pack $nbporbit.lab -in $nbporbit -side left -padx 5 -pady 0
          spinbox $nbporbit.val -values [ list 2 3 5 9] -command "" -width 3 -textvariable ::tools_cdl::nbporbit
          $nbporbit.val set 5
          pack  $nbporbit.val -in $nbporbit -side left -anchor w

     #--- Cree un frame pour afficher bestdelta
     set photom [frame $frm.photom -borderwidth 0 -cursor arrow -relief groove]
     pack $photom -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
          checkbutton $photom.check -highlightthickness 0 \
                     -text "Recherche meilleur delta (min/max)" -variable ::tools_cdl::bestdelta
          pack $photom.check -in $photom -side left -padx 5 -pady 0
          spinbox $photom.min -from 1 -to 100 -increment 1 -command "" -width 3  \
                -textvariable ::tools_cdl::deltamin
          pack  $photom.min -in $photom -side left -anchor w
          spinbox $photom.max -from 1 -to 100 -increment 1 -command "" -width 3  \
                -textvariable ::tools_cdl::deltamax
          pack  $photom.max -in $photom -side left -anchor w

     #--- Niveau de saturation (ADU)
     set saturation [frame $frm.saturation -borderwidth 0 -cursor arrow -relief groove]
     pack $saturation -in $frm -anchor s -side top -expand 0 -fill x -padx 5 -pady 5
          label $saturation.lab -text "Niveau de saturation (ADU)"
          pack $saturation.lab -in $saturation -side left -padx 5 -pady 0
          entry $saturation.val -relief sunken -textvariable ::tools_cdl::saturation -width 6
          pack $saturation.val -in $saturation -side left -pady 1 -anchor w

     #--- Nb etoiles de reference
     set nbstars [frame $frm.nbstars -borderwidth 0 -cursor arrow -relief groove]
     set sources [frame $frm.sources -borderwidth 0 -cursor arrow -relief groove]
     pack $nbstars -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
          label $nbstars.lab -text "Nb d etoiles de reference"
          pack $nbstars.lab -in $nbstars -side left -padx 5 -pady 0
          spinbox $nbstars.val -from 1 -to 100 -increment 1 \
                   -command "::bdi_gui_cdl_withwcs::change_refstars $sources " \
                   -width 3 -textvariable ::bdi_gui_cdl_withwcs::nbstars
          pack  $nbstars.val -in $nbstars -side left -anchor w

     #--- Cree un frame pour afficher movingobject
     set stoperreur [frame $frm.stoperreur -borderwidth 0 -cursor arrow -relief groove]
     pack $stoperreur -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          #--- Cree un checkbutton
          checkbutton $stoperreur.check -highlightthickness 0 -text "Arret en cas d'erreur" \
                   -variable ::bdi_gui_cdl_withwcs::stoperreur
          pack $stoperreur.check -in $stoperreur -side left -padx 5 -pady 0

     #--- Cree un frame pour afficher movingobject
     set uncosm [frame $frm.uncosm -borderwidth 0 -cursor arrow -relief groove]
     pack $uncosm -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          #--- Cree un checkbutton
          checkbutton $uncosm.check -highlightthickness 0 -text "Uncosmic" \
                   -command "::bdi_gui_cdl_withwcs::change_uncosm " \
                   -variable ::tools_cdl::uncosm
          pack $uncosm.check -in $uncosm -side left -padx 5 -pady 0
          entry $uncosm.p1 -relief sunken -textvariable ::tools_cdl::uncosm_param1 -width 6
          pack $uncosm.p1 -in $uncosm -side left -pady 1 -anchor w
          entry $uncosm.p2 -relief sunken -textvariable ::tools_cdl::uncosm_param2 -width 6
          pack $uncosm.p2 -in $uncosm -side left -pady 1 -anchor w


     #--- Cree un frame pour afficher la mag de la premiere etoile de reference
     set firstrefstar [frame $frm.firstrefstar -borderwidth 0 -cursor arrow -relief groove]
     pack $firstrefstar -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          #--- Cree un checkbutton
          label $firstrefstar.lab -text "Magnitude de la premiere etoile de reference : "
          pack $firstrefstar.lab -in $firstrefstar -side left -padx 5 -pady 0
          entry $firstrefstar.val -relief sunken -textvariable ::tools_cdl::firstmagref -width 6
          pack $firstrefstar.val -in $firstrefstar -side left -pady 1 -anchor w

     #--- Cree un frame pour afficher l acces direct a l image
     set directaccess [frame $frm.directaccess -borderwidth 0 -cursor arrow -relief groove]
     pack $directaccess -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          #--- Cree un checkbutton
          label $directaccess.lab -text "Access direct a l image : "
          pack $directaccess.lab -in $directaccess -side left -padx 5 -pady 0
          entry $directaccess.val -relief sunken \
             -textvariable ::bdi_gui_cdl_withwcs::directaccess -width 6 \
             -justify center
          pack $directaccess.val -in $directaccess -side left -pady 1 -anchor w
          button $directaccess.go -text "Go" -borderwidth 1 -takefocus 1 \
             -command "::bdi_gui_cdl_withwcs::go $sources"
          pack $directaccess.go -side left -anchor e \
             -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0


#--- Boutons


     #--- Cree un frame pour afficher les boutons
     set bouton [frame $frm.bouton -borderwidth 0 -cursor arrow -relief groove]
     pack $bouton -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          button $bouton.back -text "Precedent" -borderwidth 2 -takefocus 1 \
             -command "::bdi_gui_cdl_withwcs::back $sources" -state $::bdi_gui_cdl_withwcs::stateback
          pack $bouton.back -side left -anchor e \
             -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          button $bouton.next -text "Suivant" -borderwidth 2 -takefocus 1 \
             -command "::bdi_gui_cdl_withwcs::next $sources" -state $::bdi_gui_cdl_withwcs::statenext
          pack $bouton.next -side left -anchor e \
             -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          label $bouton.lab -text "Par bloc de :"
          pack $bouton.lab -in $bouton -side left
          entry $bouton.block -relief sunken -textvariable ::bdi_gui_cdl_withwcs::block -borderwidth 2 -width 6 -justify center
          pack $bouton.block -in $bouton -side left -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0 -anchor w


#--- Info etat avancement


     #--- Cree un frame pour afficher info image
     set infoimage [frame $frm.infoimage -borderwidth 0 -cursor arrow -relief groove]
     pack $infoimage -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         #--- Cree un label pour le Nom de l image
         label $infoimage.nomimage -text $::tools_cdl::current_image_name
         pack $infoimage.nomimage -in $infoimage -side top -padx 3 -pady 3

         #--- Cree un label pour la date de l image
         label $infoimage.dateimage -text $::tools_cdl::current_image_date
         pack $infoimage.dateimage -in $infoimage -side top -padx 3 -pady 3

         #--- Cree un label pour la date de l image
         label $infoimage.stimage -text "$::tools_cdl::id_current_image / $::tools_cdl::nb_img_list"
         pack $infoimage.stimage -in $infoimage -side top -padx 3 -pady 3


#--- Sources


     #--- Sources
     pack $sources -in $frm -anchor s -side top
        set name [frame $sources.name -borderwidth 0 -cursor arrow -relief groove]
        pack $name -in $sources -anchor s -side left
        set ra [frame $sources.ra -borderwidth 0 -cursor arrow -relief groove]
        pack $ra -in $sources -anchor s -side left
        set dec [frame $sources.dec -borderwidth 0 -cursor arrow -relief groove]
        pack $dec -in $sources -anchor s -side left
        set mag [frame $sources.mag -borderwidth 0 -cursor arrow -relief groove]
        pack $mag -in $sources -anchor s -side left
        set stdev [frame $sources.stdev -borderwidth 0 -cursor arrow -relief groove]
        pack $stdev -in $sources -anchor s -side left
        set delta [frame $sources.delta -borderwidth 0 -cursor arrow -relief groove]
        pack $delta -in $sources -anchor s -side left
        set select [frame $sources.select -borderwidth 0 -cursor arrow -relief groove]
        pack $select -in $sources -anchor s -side left


     #--- Objet

         label $name.obj    -text "Objet :"
         entry $ra.obj      -relief sunken -width 11
         entry $dec.obj     -relief sunken -width 11
         label $mag.obj     -width 9
         label $stdev.obj   -width 9
         spinbox $delta.obj -from 1 -to 100 -increment 1 -command "" -width 3 \
                -command "::bdi_gui_cdl_withwcs::mesure_tout $sources" \
                -textvariable ::tools_cdl::tabsource(obj,delta)
         button $select.obj -text "Select" -command "::bdi_gui_cdl_withwcs::select_source $sources obj" -height 1

         pack $name.obj   -in $name   -side top -pady 2 -ipady 2
         pack $ra.obj     -in $ra     -side top -pady 2 -ipady 2
         pack $dec.obj    -in $dec    -side top -pady 2 -ipady 2
         pack $mag.obj    -in $mag    -side top -pady 2 -ipady 2
         pack $stdev.obj  -in $stdev  -side top -pady 2 -ipady 2
         pack $delta.obj  -in $delta  -side top -pady 2 -ipady 2
         pack $select.obj -in $select -side top

         label $name.star1    -text "Star1 :"
         entry $ra.star1      -relief sunken -width 11
         entry $dec.star1     -relief sunken -width 11
         label $mag.star1     -width 9 -textvariable ::tools_cdl::firstmagref
         label $stdev.star1   -width 9
         spinbox $delta.star1 -from 1 -to 100 -increment 1 -width 3 \
                -command "::bdi_gui_cdl_withwcs::mesure_tout $sources" \
                -textvariable ::tools_cdl::tabsource(star1,delta)
         button $select.star1 -text "Select" -command "::bdi_gui_cdl_withwcs::select_source $sources star1"

         pack $name.star1   -in $name   -side top -pady 2 -ipady 2
         pack $ra.star1     -in $ra     -side top -pady 2 -ipady 2
         pack $dec.star1    -in $dec    -side top -pady 2 -ipady 2
         pack $mag.star1    -in $mag    -side top -pady 2 -ipady 2
         pack $stdev.star1  -in $stdev  -side top -pady 2 -ipady 2
         pack $delta.star1  -in $delta  -side top -pady 2 -ipady 2
         pack $select.star1 -in $select -side top


#--- Boutons Final

     #--- Cree un frame pour afficher les boutons finaux
     set boutonfinal [frame $frm.boutonfinal -borderwidth 0 -cursor arrow -relief groove]
     pack $boutonfinal -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          button $boutonfinal.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
             -command ::bdi_gui_cdl_withwcs::fermer \
             -state normal
          pack $boutonfinal.fermer -side right -anchor e \
             -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


          button $boutonfinal.enregistrer -text "Enregistrer" -borderwidth 2 -takefocus 1 \
             -command "" -state $::bdi_gui_cdl_withwcs::enregistrer
          pack $boutonfinal.enregistrer -side right -anchor e \
             -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          button $boutonfinal.analyser -text "Analyser" -borderwidth 2 -takefocus 1 \
             -command "" -state $::bdi_gui_cdl_withwcs::analyser
          pack $boutonfinal.analyser -side right -anchor e \
             -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          button $boutonfinal.stat_mag -text "Stat Mag" -borderwidth 2 -takefocus 1 \
             -command ::bdi_gui_cdl_withwcs::stat_mag2
          pack $boutonfinal.stat_mag -side right -anchor e \
             -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

}





proc ::bdi_gui_cdl_withwcs::stat_mag2 { } {

   global bddconf

   # creation des nom de fichier de sortie
   set ::tools_cdl::current_image [lindex $::tools_cdl::img_list 0 ]
   set tabkey      [::bddimages_liste::lget $::tools_cdl::current_image "tabkey"]
   set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
   set date [string range $date 0 9]

   if {${::tools_cdl::nomobj}==""} {
      set ::tools_cdl::nomobj "Unknown"
   }

   set dirsave [file join $::tools_cdl::savedir "CDL_${date}_${::tools_cdl::nomobj}"]
   createdir_ifnot_exist $dirsave

   # Exploration des valeurs de delta
   set ldelta ""
   if { $::tools_cdl::bestdelta == 1 } {
      for {set rdelta $::tools_cdl::deltamin} {$rdelta<=$::tools_cdl::deltamax} {incr rdelta} {
         set ldelta [lappend ldelta $rdelta]
      }
   }

   foreach delta $ldelta {
      gren_info "$delta "
   }

   # Definition des nom de fichier
   set file_std [file join $dirsave "CDL_${date}_${::tools_cdl::nomobj}_std.csv"]
   set file_cpt [file join $dirsave "CDL_${date}_${::tools_cdl::nomobj}_cpt.csv"]
   set file_mpc [file join $dirsave "CDL_${date}_${::tools_cdl::nomobj}_mpc.csv"]
   set file_exl [file join $dirsave "CDL_${date}_${::tools_cdl::nomobj}_excel_fr.csv"]
   foreach delta $ldelta {
      set file_delta($delta) [file join $dirsave "CDL_${date}_${::tools_cdl::nomobj}_delta_${delta}.csv"]
   }

   # Ouverture des fichiers
   set f_std [open $file_std "w"]
   set f_cpt [open $file_cpt "w"]
   set f_exl [open $file_exl "w"]
   foreach delta $ldelta {
      set f_delta($delta) [open $file_delta($delta) "w"]
   }

   # Entete

      # Standard
      set line "i,dateiso,datejj"
      append line [header_line_std obj]
      for {set x 1} {$x<=$::bdi_gui_cdl_withwcs::nbstars} {incr x} {
          append line [header_line_std star$x]
      }
      puts $f_std $line

      # Compact
      set line "i,dateiso,datejj"
      append line [header_line_cpt obj]
      for {set x 1} {$x<=$::bdi_gui_cdl_withwcs::nbstars} {incr x} {
          append line [header_line_cpt star$x]
      }
      puts $f_cpt $line

      # Excel Fr
      set line "i dateiso datejj"
      append line [header_line_exl obj]
      for {set x 1} {$x<=$::bdi_gui_cdl_withwcs::nbstars} {incr x} {
          append line [header_line_exl star$x]
      }
      puts $f_exl $line

      # Exploration du Delta
      set line "i,dateiso,datejj"
      append line [header_line_std obj]
      for {set x 1} {$x<=$::bdi_gui_cdl_withwcs::nbstars} {incr x} {
          append line [header_line_std star$x]
      }
      foreach delta $ldelta {
         puts $f_delta($delta) $line
      }



   # data
   for {set i 1} {$i<$::tools_cdl::nb_img_list} {incr i} {

      if { [info exists ::tools_cdl::tabphotom($i,obj,mag)] } {

         # Connexion SQL
         #::bdi_gui_cdl_withwcs::update_bdi [lindex $::tools_cdl::img_list [expr $i - 1]] "Y"

         # Header
         set line_std [index_line $i]
         set line_cpt [index_line $i]
         set line_exl [index_line_exl $i]
         foreach delta $ldelta {
            set line_delta($delta) [index_line $i]
         }

         # Objet
         append line_std [insert_line_std $i obj]
         append line_cpt [insert_line_cpt $i obj]
         append line_exl [insert_line_exl $i obj]
         foreach delta $ldelta {
            append line_delta($delta) [insert_line_delta $i obj $delta]
         }

         # Etoiles de Reference
         for {set x 1} {$x<=$::bdi_gui_cdl_withwcs::nbstars} {incr x} {
            append line_std [insert_line_std $i star$x]
            append line_cpt [insert_line_cpt $i star$x]
            append line_exl [insert_line_exl $i star$x]
            foreach delta $ldelta {
               append line_delta($delta) [insert_line_delta $i star$x $delta]
            }
         }

         # Ecrit dans le fichier
         puts $f_std $line_std
         puts $f_cpt $line_cpt
         puts $f_exl $line_exl
         foreach delta $ldelta {
            puts $f_delta($delta) $line_delta($delta)
         }
      }

   }

   # Fermeture des fichiers
   close $f_std
   close $f_cpt
   close $f_exl
   foreach delta $ldelta {
      close $f_delta($delta)
   }

   gren_info "Donnees enregistrees : nb date = $i\n"
   gren_info "Repertoire : $dirsave\n"

}


# Date et index
proc ::bdi_gui_cdl_withwcs::index_line { i } {
   set line "$i"
   append line ",$::tools_cdl::tabphotom($i,obj,isodate)"
   append line ",$::tools_cdl::tabphotom($i,obj,jjdate)"
   return $line
}



# Donnee Standard : comprend toute l information qu on peut en tirer

# Entete
proc ::bdi_gui_cdl_withwcs::header_line_std { n } {
   return ",${n}_mag,${n}_instru_mag,${n}_fwhmx,${n}_fwhmy,${n}_fwhm,${n}_integrated_flux,${n}_error_flux,${n}_pixel_max,${n}_intensity,${n}_sigma_deepsky,${n}_sn_int,${n}_sn_px,${n}_delta,${n}_x,${n}_y,${n}_ra_deg,${n}_dec_deg,${n}_ra_hms,${n}_dec_dms,${n}_error,${n}_saturated"
}

# Photom value pour la source n source a l index i
proc ::bdi_gui_cdl_withwcs::insert_line_std { i n } {
   set line ""
   if { [info exists ::tools_cdl::tabphotom($i,${n},mag)        ] } {append line ",$::tools_cdl::tabphotom($i,${n},mag)"        } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},maginstru)  ] } {append line ",$::tools_cdl::tabphotom($i,${n},maginstru)"  } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},fwhmx)      ] } {append line ",$::tools_cdl::tabphotom($i,${n},fwhmx)"      } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},fwhmy)      ] } {append line ",$::tools_cdl::tabphotom($i,${n},fwhmy)"      } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},fwhm)       ] } {append line ",$::tools_cdl::tabphotom($i,${n},fwhm)"       } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},fluxintegre)] } {append line ",$::tools_cdl::tabphotom($i,${n},fluxintegre)"} else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},errflux)    ] } {append line ",$::tools_cdl::tabphotom($i,${n},errflux)"    } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},pixmax)     ] } {append line ",$::tools_cdl::tabphotom($i,${n},pixmax)"     } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},intensite)  ] } {append line ",$::tools_cdl::tabphotom($i,${n},intensite)"  } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},sigmafond)  ] } {append line ",$::tools_cdl::tabphotom($i,${n},sigmafond)"  } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},snint)      ] } {append line ",$::tools_cdl::tabphotom($i,${n},snint)"      } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},snpx)       ] } {append line ",$::tools_cdl::tabphotom($i,${n},snpx)"       } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},delta)      ] } {append line ",$::tools_cdl::tabphotom($i,${n},delta)"      } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},x)          ] } {append line ",$::tools_cdl::tabphotom($i,${n},x)"          } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},y)          ] } {append line ",$::tools_cdl::tabphotom($i,${n},y)"          } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},ra_deg)     ] } {append line ",$::tools_cdl::tabphotom($i,${n},ra_deg)"     } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},dec_deg)    ] } {append line ",$::tools_cdl::tabphotom($i,${n},dec_deg)"    } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},ra_hms)     ] } {append line ",$::tools_cdl::tabphotom($i,${n},ra_hms)"     } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},dec_dms)    ] } {append line ",$::tools_cdl::tabphotom($i,${n},dec_dms)"    } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},err)        ] } {append line ",$::tools_cdl::tabphotom($i,${n},err)"        } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},saturation) ] } {append line ",$::tools_cdl::tabphotom($i,${n},saturation)" } else {append line ","}
   return $line
}

proc ::bdi_gui_cdl_withwcs::field_std { x } {
   return ",$x"
}


# Donnee Compacte : comprend le minimum pour faire une Courbe de lumiere

# Entete
proc ::bdi_gui_cdl_withwcs::header_line_cpt { n } {
   return ",${n}_mag,${n}_instru_mag,${n}_fwhm,${n}_integrated_flux,${n}_error_flux"
}

# Photom value pour la source n source a l index i
proc ::bdi_gui_cdl_withwcs::insert_line_cpt { i n } {
   set line ""
   if { [info exists ::tools_cdl::tabphotom($i,${n},mag)        ] } {append line ",$::tools_cdl::tabphotom($i,${n},mag)"        } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},maginstru)  ] } {append line ",$::tools_cdl::tabphotom($i,${n},maginstru)"  } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},fwhm)       ] } {append line ",$::tools_cdl::tabphotom($i,${n},fwhm)"       } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},fluxintegre)] } {append line ",$::tools_cdl::tabphotom($i,${n},fluxintegre)"} else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},errflux)    ] } {append line ",$::tools_cdl::tabphotom($i,${n},errflux)"    } else {append line ","}
   return $line
}

# Donnee Excel FR : meme champ que standard, mais lisible par tous Excel type version francaise qui ne comprend que la virgule pour les nombres decimaux

# Entete
proc ::bdi_gui_cdl_withwcs::header_line_exl { n } {
   return " ${n}_mag ${n}_instru_mag ${n}_fwhmx ${n}_fwhmy ${n}_fwhm ${n}_integrated_flux ${n}_error_flux ${n}_pixel_max ${n}_intensity ${n}_sigma_deepsky ${n}_sn_int ${n}_sn_px ${n}_delta ${n}_x ${n}_y ${n}_ra_deg ${n}_dec_deg ${n}_ra_hms ${n}_dec_dms ${n}_error ${n}_saturated"
}

# Photom value pour la source n source a l index i
proc ::bdi_gui_cdl_withwcs::insert_line_exl { i n } {
   set line ""
   if { [info exists ::tools_cdl::tabphotom($i,${n},mag)        ] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},mag)        ]} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},maginstru)  ] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},maginstru)  ]} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},fwhmx)      ] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},fwhmx)      ]} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},fwhmy)      ] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},fwhmy)      ]} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},fwhm)       ] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},fwhm)       ]} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},fluxintegre)] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},fluxintegre)]} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},errflux)    ] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},errflux)    ]} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},pixmax)     ] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},pixmax)     ]} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},intensite)  ] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},intensite)  ]} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},sigmafond)  ] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},sigmafond)  ]} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},snint)      ] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},snint)      ]} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},snpx)       ] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},snpx)       ]} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},delta)      ] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},delta)      ]} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},x)          ] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},x)          ]} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},y)          ] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},y)          ]} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},ra_deg)     ] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},ra_deg)     ]} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},dec_deg)    ] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},dec_deg)    ]} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},ra_hms)     ] } {append line " $::tools_cdl::tabphotom($i,${n},ra_hms)"} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},dec_dms)    ] } {append line " $::tools_cdl::tabphotom($i,${n},dec_dms)"} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},err)        ] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},err)        ]} else {append line " -"}
   if { [info exists ::tools_cdl::tabphotom($i,${n},saturation) ] } {append line [field_exl $::tools_cdl::tabphotom($i,${n},saturation) ]} else {append line " -"}
   return $line
}

# Date et index
proc ::bdi_gui_cdl_withwcs::index_line_exl { i } {
   set line "$i"
   append line " $::tools_cdl::tabphotom($i,obj,isodate)"
   append line [field_exl $::tools_cdl::tabphotom($i,obj,jjdate)]
   return $line
}


proc ::bdi_gui_cdl_withwcs::field_exl { x } {
   set x [regsub -all \[.\] $x ,]
   return " $x"
}

# Donnee Exploration du Delta

# Photom value pour la source n source a l index i
proc ::bdi_gui_cdl_withwcs::insert_line_delta { i n delta} {
   set line ""
   if { [info exists ::tools_cdl::tabphotom($i,${n},search_delta,$delta,mag)        ] } {append line ",$::tools_cdl::tabphotom($i,${n},search_delta,$delta,mag)"        } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},search_delta,$delta,maginstru)  ] } {append line ",$::tools_cdl::tabphotom($i,${n},search_delta,$delta,maginstru)"  } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},search_delta,$delta,fwhmx)      ] } {append line ",$::tools_cdl::tabphotom($i,${n},search_delta,$delta,fwhmx)"      } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},search_delta,$delta,fwhmy)      ] } {append line ",$::tools_cdl::tabphotom($i,${n},search_delta,$delta,fwhmy)"      } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},search_delta,$delta,fwhm)       ] } {append line ",$::tools_cdl::tabphotom($i,${n},search_delta,$delta,fwhm)"       } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},search_delta,$delta,fluxintegre)] } {append line ",$::tools_cdl::tabphotom($i,${n},search_delta,$delta,fluxintegre)"} else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},search_delta,$delta,errflux)    ] } {append line ",$::tools_cdl::tabphotom($i,${n},search_delta,$delta,errflux)"    } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},search_delta,$delta,pixmax)     ] } {append line ",$::tools_cdl::tabphotom($i,${n},search_delta,$delta,pixmax)"     } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},search_delta,$delta,intensite)  ] } {append line ",$::tools_cdl::tabphotom($i,${n},search_delta,$delta,intensite)"  } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},search_delta,$delta,sigmafond)  ] } {append line ",$::tools_cdl::tabphotom($i,${n},search_delta,$delta,sigmafond)"  } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},search_delta,$delta,snint)      ] } {append line ",$::tools_cdl::tabphotom($i,${n},search_delta,$delta,snint)"      } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},search_delta,$delta,snpx)       ] } {append line ",$::tools_cdl::tabphotom($i,${n},search_delta,$delta,snpx)"       } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},search_delta,$delta,delta)      ] } {append line ",$::tools_cdl::tabphotom($i,${n},search_delta,$delta,delta)"      } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},x)          ] } {append line ",$::tools_cdl::tabphotom($i,${n},x)"          } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},y)          ] } {append line ",$::tools_cdl::tabphotom($i,${n},y)"          } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},ra_deg)     ] } {append line ",$::tools_cdl::tabphotom($i,${n},ra_deg)"     } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},dec_deg)    ] } {append line ",$::tools_cdl::tabphotom($i,${n},dec_deg)"    } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},ra_hms)     ] } {append line ",$::tools_cdl::tabphotom($i,${n},ra_hms)"     } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},dec_dms)    ] } {append line ",$::tools_cdl::tabphotom($i,${n},dec_dms)"    } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},err)        ] } {append line ",$::tools_cdl::tabphotom($i,${n},err)"        } else {append line ","}
   if { [info exists ::tools_cdl::tabphotom($i,${n},saturation) ] } {append line ",$::tools_cdl::tabphotom($i,${n},saturation)" } else {append line ","}
   return $line
}

