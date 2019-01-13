## @file bdi_gui_cdl_basic.tcl
#  @brief     GUI d&eacute;di&eacute;e aux courbes de lumi&egrave;re basiques
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_cdl_basic.tcl]
#  @endcode

# $Id: bdi_gui_cdl_basic.tcl 9215 2013-03-15 15:36:44Z jberthier $

##
# @namespace bdi_gui_cdl_basic
# @brief GUI d&eacute;di&eacute;e aux courbes de lumi&egrave;re basiques - choix d'une seule &eacute;toile de r&eacute;f&eacute;rence
# @pre Requiert \c tools_cdl .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_gui_cdl_basic {

}

#------------------------------------------------------------
## Creation de la GUI de gestion des configurations
#  @return void
#
proc ::bdi_gui_cdl_basic::inittoconf {  } {

   global bddconf
   
   array unset ::bdi_gui_cdl_basic::tabsource
   array unset ::bdi_gui_cdl_basic::tabphotom
   
   set ::bdi_gui_cdl_basic::nomobj ""
   if { ! [info exists bddconf(cdl_savedir)] } {
      set ::bdi_gui_cdl_basic::savedir $bddconf(dirtmp)
   } else {
      set ::bdi_gui_cdl_basic::savedir $bddconf(cdl_savedir)
   }
   set ::bdi_gui_cdl_basic::movingobject 1
   set ::bdi_gui_cdl_basic::nbporbit 5
   
   set ::bdi_gui_cdl_basic::nbstars 1
   set ::bdi_gui_cdl_basic::nbstarssav 1
   
   set ::bdi_gui_cdl_basic::stoperreur 1

   set ::bdi_gui_cdl_basic::firstmagref 12.000

   set ::bdi_gui_cdl_basic::directaccess 1

   set ::bdi_gui_cdl_basic::block 1

   set ::bdi_gui_cdl_basic::current_image_name ""
   set ::bdi_gui_cdl_basic::current_image_date ""

   set ::bdi_gui_cdl_basic::tabsource(obj,delta)   15
   set ::bdi_gui_cdl_basic::tabsource(star1,delta) 15



}

#------------------------------------------------------------
## Fermeture et destruction de la GUI
#  @return void
#
proc ::bdi_gui_cdl_basic::fermer { } {

   #::bdi_gui_reports::closetoconf
   ::bdi_gui_cdl_basic::recup_position
   destroy $::bdi_gui_cdl_basic::fen

}

#------------------------------------------------------------
## Recuperation de la position d'affichage de la GUI
#  @return void
#
proc ::bdi_gui_cdl_basic::recup_position { } {

   global conf bddconf

   set bddconf(geometry_cdl_basic) [ wm geometry $::bdi_gui_cdl_basic::fen ]
   set conf(bddimages,geometry_cdl_basic) $bddconf(geometry_cdl_basic)

}

#----------------------------------------------------------------------------
## Relance l outil
# Les variables utilisees sont affectees a la variable globale
# \c conf
proc ::bdi_gui_cdl_basic::relance {  } {

   ::bddimages::ressource
   ::bdi_gui_cdl_basic::fermer
   ::bdi_gui_cdl_basic::run

}


#----------------------------------------------------------------------------
## Arrete le processus d avancement de centrage des sources
#  @return void
proc ::bdi_gui_cdl_basic::stop {  } {
   
   set ::bdi_gui_cdl_basic::stop_next 1
}

#----------------------------------------------------------------------------
## Passe a l image suivante
#  @return void
proc ::bdi_gui_cdl_basic::next { sources } {

   set cpt 0

   set ::bdi_gui_cdl_basic::stop_next 0
   
   while {$cpt<$::bdi_gui_cdl_basic::block} {
      
      if {$::bdi_gui_cdl_basic::stop_next==1} {break}
      if {$::tools_cdl::id_current_image < $::tools_cdl::nb_img_list} {
         incr ::tools_cdl::id_current_image
         ::bdi_gui_cdl_basic::charge_current_image
         ::bdi_gui_cdl_basic::extrapole
         set err [::bdi_gui_cdl_basic::mesure_tout $sources]
         if {$err==1 && $::bdi_gui_cdl_withwcs::stoperreur==1} {
            break
         }
      }
      incr cpt
   }
}

#----------------------------------------------------------------------------
## Revient a l image precedente
#  @return void
proc ::bdi_gui_cdl_basic::back { sources } {

      if {$::tools_cdl::id_current_image > 1 } {
         incr ::tools_cdl::id_current_image -1
         ::bdi_gui_cdl_basic::charge_current_image
         ::bdi_gui_cdl_basic::extrapole
         set err [::bdi_gui_cdl_basic::mesure_tout $sources]
      }
}

#----------------------------------------------------------------------------
## Passe directement a une image en donnant l id de celle ci 
#  @return void
proc ::bdi_gui_cdl_basic::go { sources } {

      set ::tools_cdl::id_current_image $::bdi_gui_cdl_basic::directaccess
      if {$::tools_cdl::id_current_image > $::tools_cdl::nb_img_list} {
         set ::tools_cdl::id_current_image $::tools_cdl::nb_img_list
      }
      if {$::tools_cdl::id_current_image < 1} {
         set ::tools_cdl::id_current_image 1
         set ::bdi_gui_cdl_basic::directaccess 1
      }
      set ::bdi_gui_cdl_basic::directaccess $::tools_cdl::id_current_image

      ::bdi_gui_cdl_basic::charge_current_image
      ::bdi_gui_cdl_basic::extrapole
      set err [::bdi_gui_cdl_basic::mesure_tout $sources]
}



#----------------------------------------------------------------------------
## Charge l image courante
#  @return void
proc ::bdi_gui_cdl_basic::charge_current_image { } {

   global audace
   global bddconf

      #ï¿½Charge l image en memoire
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

      gren_info "\nCharge Image cur: $date  ($exposure sec)\n"

      #ï¿½Charge l image
      buf$::audace(bufNo) load $file
      cleanmark

      # EFFECTUE UNCOSMIC
      if {$::tools_cdl::uncosm == 1} {
         ::tools_cdl::myuncosmic $::audace(bufNo)
      }

      # VIsualisation par Sseuil automatique
      ::audace::autovisu $::audace(visuNo)

      #ï¿½Mise a jour GUI
      $::bdi_gui_cdl_basic::fen.appli.bouton.back configure -state disabled
      $::bdi_gui_cdl_basic::fen.appli.bouton.back configure -state disabled
      $::bdi_gui_cdl_basic::fen.appli.infoimage.nomimage    configure -text $::tools_cdl::current_image_name
      $::bdi_gui_cdl_basic::fen.appli.infoimage.dateimage   configure -text $::tools_cdl::current_image_date
      $::bdi_gui_cdl_basic::fen.appli.infoimage.stimage     configure -text "$::tools_cdl::id_current_image / $::tools_cdl::nb_img_list"

      gren_info " $::tools_cdl::current_image_name \n"

      if {$::tools_cdl::id_current_image == 1 && $::tools_cdl::nb_img_list > 1 } {
         $::bdi_gui_cdl_basic::fen.appli.bouton.back configure -state disabled
      }
      if {$::tools_cdl::id_current_image == $::tools_cdl::nb_img_list && $::tools_cdl::nb_img_list > 1 } {
         $::bdi_gui_cdl_basic::fen.appli.bouton.next configure -state disabled
      }
      if {$::tools_cdl::id_current_image > 1 } {
         $::bdi_gui_cdl_basic::fen.appli.bouton.back configure -state normal
      }
      if {$::tools_cdl::id_current_image < $::tools_cdl::nb_img_list } {
         $::bdi_gui_cdl_basic::fen.appli.bouton.next configure -state normal
      }

}






proc ::bdi_gui_cdl_basic::select_source { sources starx } {


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


      set ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,$starx,x) [lindex $valeurs 0]
      set ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,$starx,y) [lindex $valeurs 1]
      set ::bdi_gui_cdl_basic::tabsource($starx,select) true
      $sources.select.$starx  configure -relief sunken

   } else {

      $sources.select.$starx  configure -relief raised
      set ::bdi_gui_cdl_basic::tabsource($starx,select) false

   }

   ::bdi_gui_cdl_basic::mesure_tout $sources

}






proc ::bdi_gui_cdl_basic::maj_source { sources starx } {

   if {[ $sources.select.$starx cget -relief] == "sunken"} {

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


      set ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,$starx,x) [lindex $valeurs 0]
      set ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,$starx,y) [lindex $valeurs 1]
      set ::bdi_gui_cdl_basic::tabsource($starx,select) true

      ::bdi_gui_cdl_basic::mesure_tout $sources
   }


}






proc ::bdi_gui_cdl_basic::mesure_tout { sources } {

   #gren_info "ZOOM: [::confVisu::getZoom $::audace(visuNo)] \n "

   if { [ $sources.select.obj cget -relief] == "sunken" } {
      ::bdi_gui_cdl_basic::mesure_une $sources obj
   }

   for {set x 1} {$x<=$::bdi_gui_cdl_basic::nbstars} {incr x} {
      if { [ $sources.select.star$x cget -relief] == "sunken" } {
         ::bdi_gui_cdl_basic::mesure_une $sources star$x
      }
   }

   ::bdi_gui_cdl_basic::gui_update_sources $sources

   return 0

}

proc ::bdi_gui_cdl_basic::mesure_une { sources starx } {

   set ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,$starx,err) false
   set err [ catch {set valeurs [::tools_cdl::mesure_obj \
            $::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,$starx,x) \
            $::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,$starx,y) \
            $::bdi_gui_cdl_basic::tabsource($starx,delta) $::audace(bufNo)]} msg ]


   if { $valeurs == -1 } {
      set ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,$starx,err) true
      gren_erreur "Erreur de mesure pour $starx\n"
      return

   } else {

      set xsm      [lindex $valeurs 0]
      set ysm      [lindex $valeurs 1]

      set ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,$starx,x)           $xsm
      set ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,$starx,y)           $ysm

      set ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,$starx,jjdate)      $::tools_cdl::current_image_jjdate
      set ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,$starx,isodate)     $::tools_cdl::current_image_date

      $sources.x.$starx configure -text [format "%.2f" $xsm]
      $sources.y.$starx configure -text [format "%.2f" $ysm]

   }

   return
}




proc ::bdi_gui_cdl_basic::extrapole {  } {

   # X Obj 
   if { ! [info exists ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,obj,x) ] } {
      for {set i [expr $::tools_cdl::id_current_image -1]} {$i>=1} {incr i -1} {
         if { [info exists ::bdi_gui_cdl_basic::tabphotom($i,obj,x) ] } {
            set ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,obj,x) $::bdi_gui_cdl_basic::tabphotom($i,obj,x)
            break
         }
      }
   }
   # Y Obj 
   if { ! [info exists ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,obj,y) ] } {
      for {set i [expr $::tools_cdl::id_current_image -1]} {$i>=1} {incr i -1} {
         if { [info exists ::bdi_gui_cdl_basic::tabphotom($i,obj,y) ] } {
            set ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,obj,y) $::bdi_gui_cdl_basic::tabphotom($i,obj,y)
            break
         }
      }
   }

   for {set x 1} {$x<=$::bdi_gui_cdl_basic::nbstars} {incr x} {
      # X Star 
      if { ! [info exists ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,star$x,x) ] } {
         for {set i [expr $::tools_cdl::id_current_image -1]} {$i>=1} {incr i -1} {
            if { [info exists ::bdi_gui_cdl_basic::tabphotom($i,star$x,x) ] } {
               set ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,star$x,x) $::bdi_gui_cdl_basic::tabphotom($i,star$x,x)
               break
            }
         }
      }
      # Y Star 
      if { ! [info exists ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,star$x,y) ] } {
         for {set i [expr $::tools_cdl::id_current_image -1]} {$i>=1} {incr i -1} {
            if { [info exists ::bdi_gui_cdl_basic::tabphotom($i,star$x,y) ] } {
               set ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,star$x,y) $::bdi_gui_cdl_basic::tabphotom($i,star$x,y)
               break
            }
         }
      }
   }


}


proc ::bdi_gui_cdl_basic::gui_update_sources { sources } {
   
   cleanmark
   for {set x 1} {$x<=$::bdi_gui_cdl_basic::nbstars} {incr x} {

      if { [::bdi_gui_cdl_basic::is_good "star$x"] } {
         #$sources.name.$::tools_cdl::starref configure -foreground blue
         affich_un_rond_xy $::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,star$x,x) \
                           $::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,star$x,y) \
                           blue  $::bdi_gui_cdl_basic::tabsource(star$x,delta) 2
      } else {

         if { [::bdi_gui_cdl_basic::is_selected "star$x"] } {
            $sources.name.star$x configure -foreground red
            affich_un_rond_xy $::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,star$x,x) \
                              $::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,star$x,y) \
                              red $::bdi_gui_cdl_basic::tabsource(star$x,delta) 1
         } else {
            $sources.name.star$x configure -foreground black
         }

      }

   }

   if { [::bdi_gui_cdl_basic::is_good "obj"] } {
      $sources.name.obj configure -foreground darkgreen
      affich_un_rond_xy $::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,obj,x) \
                        $::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,obj,y) \
                        green $::bdi_gui_cdl_basic::tabsource(obj,delta) 2
   } else {
      if { [::bdi_gui_cdl_basic::is_selected "obj"] } {
         $sources.name.obj configure -foreground red
         affich_un_rond_xy $::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,obj,x) \
                           $::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,obj,y) \
                           red $::bdi_gui_cdl_basic::tabsource(obj,delta) 1
      } else {
         $sources.name.obj configure -foreground black

      }
   }

   return
}

proc ::bdi_gui_cdl_basic::is_good { starx } {

   catch {
      if {0} {
         gren_info "**\n"
         gren_info "source : $starx\n"
         gren_info "err : $::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,$starx,err)\n"
         gren_info "select : $::bdi_gui_cdl_basic::tabsource($starx,select)\n"
         gren_info "saturation : $::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,$starx,saturation)\n"
      }
   }


   if { ! [info exists ::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,$starx,err) ] } { return false }
   if { $::bdi_gui_cdl_basic::tabphotom($::tools_cdl::id_current_image,$starx,err) } { return false }
   if { ! $::bdi_gui_cdl_basic::tabsource($starx,select) } { return false }

   return true
}

proc ::bdi_gui_cdl_basic::is_selected { starx } {

   if { ! [info exists ::bdi_gui_cdl_basic::tabsource($starx,select) ] } { return false }
   if { ! $::bdi_gui_cdl_basic::tabsource($starx,select) } { return false }
   return true
}



proc ::bdi_gui_cdl_basic::photometry { } {

   global posxy
   global private
   
   ::audace::psf_init $::audace(visuNo)

   if {[$::bdi_gui_cdl_basic::frame(boutonfinal).photometry cget -relief]=="sunken"} {
      set ::bdi_gui_cdl_basic::photometry_stop 1
      return
   }

   set ::bdi_gui_cdl_basic::photometry_stop 0


   set tt0 [clock clicks -milliseconds]

   set private(psf_toolbox,$::audace(visuNo),gui) 0

   $::bdi_gui_cdl_basic::frame(boutonfinal).enregistrer configure -state disabled
   $::bdi_gui_cdl_basic::frame(boutonfinal).photometry configure -relief sunken 

   if {![info exists private(psf_toolbox,1,globale)]} {
      tk_messageBox -message "Utilisez psf_toolbox au moins une fois ce qui permmetra de fixer les parametres pour la mesure" -type ok
      return    
   }


   set ::tools_cdl::current_image [lindex $::tools_cdl::img_list 0 ]
   set tabkey      [::bddimages_liste::lget $::tools_cdl::current_image "tabkey"]
   set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
   set date [string range $date 0 9]
   
   if {${::bdi_gui_cdl_basic::nomobj}==""} {
      set ::bdi_gui_cdl_basic::nomobj "Unknown"
   }


   gren_info "Mesures : \n "
   for {set i 1} {$i<$::tools_cdl::nb_img_list} {incr i} {
            
      set tt1 [clock clicks -milliseconds]

      if {$::bdi_gui_cdl_basic::photometry_stop==1} { break }
      gren_info "\nIMG $i/$::tools_cdl::nb_img_list : "
      
      if { [info exists ::bdi_gui_cdl_basic::tabphotom($i,obj,x)] && [info exists ::bdi_gui_cdl_basic::tabphotom($i,obj,y)]} {
         gren_info "Obj : $::bdi_gui_cdl_basic::tabphotom($i,obj,x) $::bdi_gui_cdl_basic::tabphotom($i,obj,y)  "
      } else {
         continue
      }
      
      set pass 0
      for {set x 1} {$x<=$::bdi_gui_cdl_basic::nbstars} {incr x} {
         if { [info exists ::bdi_gui_cdl_basic::tabphotom($i,star$x,x)] && [info exists ::bdi_gui_cdl_basic::tabphotom($i,star$x,y)]} {
            gren_info "star$x : $::bdi_gui_cdl_basic::tabphotom($i,star$x,x) $::bdi_gui_cdl_basic::tabphotom($i,star$x,y) "
            incr pass
         }
      }
      
      if {$pass > 0} {
         
         
         # On charge l image
         set ::tools_cdl::id_current_image $i
         ::bdi_gui_cdl_basic::charge_current_image

         # On peut effectuer la mesure du photocentre
         # car on a la position de l objet 
         # ainsi que la position d au moins 1 etoile de reference 

         set xsm  $::bdi_gui_cdl_basic::tabphotom($i,obj,x)
         set ysm  $::bdi_gui_cdl_basic::tabphotom($i,obj,y)

         # Effectue la mesure de l objet
         if {$private(psf_toolbox,$::audace(visuNo),globale)} {
            set err [catch { ::audace::PSF_globale $::audace(visuNo) $xsm $ysm } msg ]
         } else {
            set err [catch { ::audace::PSF_one_radius $::audace(visuNo) $xsm $ysm } msg ]
         }
         if {$err} {
            if {$private(psf_toolbox,$::audace(visuNo),globale)} {
               gren_erreur "\nErr PSF Globale: ($err) ($msg) IMG $i obj $xsm $ysm\n"
            } else {
               gren_erreur "\nErr PSF : ($err) ($msg) IMG $i obj $xsm $ysm\n"
            }
            affich_un_rond_xy $xsm $ysm red  10 2

         } else {
            set ::bdi_gui_cdl_basic::tabphotom($i,obj,x)          $private(psf_toolbox,$::audace(visuNo),psf,xsm)      
            set ::bdi_gui_cdl_basic::tabphotom($i,obj,y)          $private(psf_toolbox,$::audace(visuNo),psf,ysm)      
            set ::bdi_gui_cdl_basic::tabphotom($i,obj,err_xsm)    $private(psf_toolbox,$::audace(visuNo),psf,err_xsm)  
            set ::bdi_gui_cdl_basic::tabphotom($i,obj,err_ysm)    $private(psf_toolbox,$::audace(visuNo),psf,err_ysm)  
            set ::bdi_gui_cdl_basic::tabphotom($i,obj,fwhmx)      $private(psf_toolbox,$::audace(visuNo),psf,fwhmx)    
            set ::bdi_gui_cdl_basic::tabphotom($i,obj,fwhmy)      $private(psf_toolbox,$::audace(visuNo),psf,fwhmy)    
            set ::bdi_gui_cdl_basic::tabphotom($i,obj,fwhm)       $private(psf_toolbox,$::audace(visuNo),psf,fwhm)     
            set ::bdi_gui_cdl_basic::tabphotom($i,obj,flux)       $private(psf_toolbox,$::audace(visuNo),psf,flux)     
            set ::bdi_gui_cdl_basic::tabphotom($i,obj,err_flux)   $private(psf_toolbox,$::audace(visuNo),psf,err_flux) 
            set ::bdi_gui_cdl_basic::tabphotom($i,obj,pixmax)     $private(psf_toolbox,$::audace(visuNo),psf,pixmax)   
            set ::bdi_gui_cdl_basic::tabphotom($i,obj,intensity)  $private(psf_toolbox,$::audace(visuNo),psf,intensity)
            set ::bdi_gui_cdl_basic::tabphotom($i,obj,sky)        $private(psf_toolbox,$::audace(visuNo),psf,sky)      
            set ::bdi_gui_cdl_basic::tabphotom($i,obj,err_sky)    $private(psf_toolbox,$::audace(visuNo),psf,err_sky)  
            set ::bdi_gui_cdl_basic::tabphotom($i,obj,snint)      $private(psf_toolbox,$::audace(visuNo),psf,snint)    
            set ::bdi_gui_cdl_basic::tabphotom($i,obj,radius)     $private(psf_toolbox,$::audace(visuNo),psf,radius)   
            set ::bdi_gui_cdl_basic::tabphotom($i,obj,rdiff)      $private(psf_toolbox,$::audace(visuNo),psf,rdiff)  
            set ::bdi_gui_cdl_basic::tabphotom($i,obj,err_psf)    $private(psf_toolbox,$::audace(visuNo),psf,err_psf) 
            set ::bdi_gui_cdl_basic::tabphotom($i,obj,err_flux_pc) [expr $::bdi_gui_cdl_basic::tabphotom($i,obj,err_flux)/$::bdi_gui_cdl_basic::tabphotom($i,obj,flux)*100.]

            affich_un_rond_xy $::bdi_gui_cdl_basic::tabphotom($i,obj,x) \
                              $::bdi_gui_cdl_basic::tabphotom($i,obj,y) \
                              green  $::bdi_gui_cdl_basic::tabphotom($i,obj,radius) 2
         }
         
            
         # Effectue la mesure des etoiles de reference
         
         for {set x 1} {$x<=$::bdi_gui_cdl_basic::nbstars} {incr x} {

            if { [info exists ::bdi_gui_cdl_basic::tabphotom($i,star$x,x)] && [info exists ::bdi_gui_cdl_basic::tabphotom($i,star$x,y)]} {

               set xsm  $::bdi_gui_cdl_basic::tabphotom($i,star$x,x)
               set ysm  $::bdi_gui_cdl_basic::tabphotom($i,star$x,y)

               # Effectue la mesure 
               if {$private(psf_toolbox,$::audace(visuNo),globale)} {
                  set err [catch { ::audace::PSF_globale $::audace(visuNo) $xsm $ysm } msg ]
               } else {
                  set err [catch { ::audace::PSF_one_radius $::audace(visuNo) $xsm $ysm } msg ]
               }
               if {$err} {
                  if {$private(psf_toolbox,$::audace(visuNo),globale)} {
                     gren_erreur "\nErr PSF Globale: ($err) ($msg) IMG $i star$x $xsm $ysm\n"
                  } else {
                     gren_erreur "\nErr PSF : ($err) ($msg)\n"
                  }
                  affich_un_rond_xy $xsm $ysm red 10 2
               } else {
                  set ::bdi_gui_cdl_basic::tabphotom($i,star$x,x)          $private(psf_toolbox,$::audace(visuNo),psf,xsm)      
                  set ::bdi_gui_cdl_basic::tabphotom($i,star$x,y)          $private(psf_toolbox,$::audace(visuNo),psf,ysm)      
                  set ::bdi_gui_cdl_basic::tabphotom($i,star$x,err_xsm)    $private(psf_toolbox,$::audace(visuNo),psf,err_xsm)  
                  set ::bdi_gui_cdl_basic::tabphotom($i,star$x,err_ysm)    $private(psf_toolbox,$::audace(visuNo),psf,err_ysm)  
                  set ::bdi_gui_cdl_basic::tabphotom($i,star$x,fwhmx)      $private(psf_toolbox,$::audace(visuNo),psf,fwhmx)    
                  set ::bdi_gui_cdl_basic::tabphotom($i,star$x,fwhmy)      $private(psf_toolbox,$::audace(visuNo),psf,fwhmy)    
                  set ::bdi_gui_cdl_basic::tabphotom($i,star$x,fwhm)       $private(psf_toolbox,$::audace(visuNo),psf,fwhm)     
                  set ::bdi_gui_cdl_basic::tabphotom($i,star$x,flux)       $private(psf_toolbox,$::audace(visuNo),psf,flux)     
                  set ::bdi_gui_cdl_basic::tabphotom($i,star$x,err_flux)   $private(psf_toolbox,$::audace(visuNo),psf,err_flux) 
                  set ::bdi_gui_cdl_basic::tabphotom($i,star$x,pixmax)     $private(psf_toolbox,$::audace(visuNo),psf,pixmax)   
                  set ::bdi_gui_cdl_basic::tabphotom($i,star$x,intensity)  $private(psf_toolbox,$::audace(visuNo),psf,intensity)
                  set ::bdi_gui_cdl_basic::tabphotom($i,star$x,sky)        $private(psf_toolbox,$::audace(visuNo),psf,sky)      
                  set ::bdi_gui_cdl_basic::tabphotom($i,star$x,err_sky)    $private(psf_toolbox,$::audace(visuNo),psf,err_sky)  
                  set ::bdi_gui_cdl_basic::tabphotom($i,star$x,snint)      $private(psf_toolbox,$::audace(visuNo),psf,snint)    
                  set ::bdi_gui_cdl_basic::tabphotom($i,star$x,radius)     $private(psf_toolbox,$::audace(visuNo),psf,radius)   
                  set ::bdi_gui_cdl_basic::tabphotom($i,star$x,rdiff)      $private(psf_toolbox,$::audace(visuNo),psf,rdiff)  
                  set ::bdi_gui_cdl_basic::tabphotom($i,star$x,err_psf)    $private(psf_toolbox,$::audace(visuNo),psf,err_psf) 
                  set ::bdi_gui_cdl_basic::tabphotom($i,star$x,err_flux_pc) [expr $::bdi_gui_cdl_basic::tabphotom($i,star$x,err_flux)/$::bdi_gui_cdl_basic::tabphotom($i,star$x,flux)*100.]

                  affich_un_rond_xy $::bdi_gui_cdl_basic::tabphotom($i,star$x,x) \
                                    $::bdi_gui_cdl_basic::tabphotom($i,star$x,y) \
                                    blue  $::bdi_gui_cdl_basic::tabphotom($i,star$x,radius) 2
               }
            

            }
         } 
         
      }
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt1)/1000.]]
      gren_info "fini en $tt sec"
      # break
   }
   ::audace::psf_clean_mark $::audace(visuNo)
   
   $::bdi_gui_cdl_basic::frame(boutonfinal).photometry configure -relief groove 
   $::bdi_gui_cdl_basic::frame(boutonfinal).enregistrer configure -state normal
   
   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "\nAnalyse photometrique en $tt sec\n"
   
}

proc ::bdi_gui_cdl_basic::save_results { } {

   global bddconf

   set tt0 [clock clicks -milliseconds]

   set img      [::bddimages_imgcorrection::chrono_first_img $::tools_cdl::img_list]
   set td       [::bddimages_liste::lget $img "commundatejj"]
   set tabkey   [::bddimages_liste::lget $img "tabkey"]
   set dateobs  [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]
   set telescop [lindex [::bddimages_liste::lget $tabkey telescop] 1]
   set filter   [::bddimages_imgcorrection::cleanEntities [lindex [::bddimages_liste::lget $tabkey "filter"] 1] ]
   set begin    $dateobs

   set img      [::bddimages_imgcorrection::chrono_last_img $::tools_cdl::img_list]
   set tf       [::bddimages_liste::lget $img "commundatejj"]
   set tabkey   [::bddimages_liste::lget $img "tabkey"]
   set dateobs  [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]
   set end      $dateobs

   set period [format "%.2f h" [expr ($tf - $td)*24.]]
   
   # fichiers de sortie
   if {${::bdi_gui_cdl_basic::nomobj}==""} {
      set ::bdi_gui_cdl_basic::nomobj "Unknown"
   }
   set dirsave [file join $::bdi_gui_cdl_basic::savedir "CDL_${dateobs}_${::bdi_gui_cdl_basic::nomobj}"]
   createdir_ifnot_exist $dirsave
   set file_result [file join $dirsave "${::bdi_gui_cdl_basic::nomobj}_${telescop}_${filter}_${dateobs}.csv"]

   set fhandler [open $file_result "w"]
   puts $fhandler "#OBJECT   = $::bdi_gui_cdl_basic::nomobj"
   puts $fhandler "#TELESCOP = $telescop"
   puts $fhandler "#FILTER   = $filter"
   puts $fhandler "#BEGIN    = $begin"
   puts $fhandler "#END      = $end"
   puts $fhandler "#OBSTIME  = $period"
   puts $fhandler "dateiso,datejj,fluxnorm,errfluxnorm,mag_aster,mag_instru_aster,mag_instru_star,fwhma,err_flux_pca,fwhms,err_flux_pcs"


   set i 0
   foreach img $::tools_cdl::img_list {
      incr i
      
      if {![info exists ::bdi_gui_cdl_basic::tabphotom($i,obj,flux)]} {continue}
      if {![info exists ::bdi_gui_cdl_basic::tabphotom($i,obj,fwhm)]} {continue}
      if {![info exists ::bdi_gui_cdl_basic::tabphotom($i,obj,err_flux_pc)]} {continue}
      if {![info exists ::bdi_gui_cdl_basic::tabphotom($i,star1,flux)]} {continue}
      if {![info exists ::bdi_gui_cdl_basic::tabphotom($i,star1,fwhm)]} {continue}
      if {![info exists ::bdi_gui_cdl_basic::tabphotom($i,star1,err_flux_pc)]} {continue}
      
      set tabkey  [::bddimages_liste::lget $img "tabkey"]
      set dateobs [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]
      set exposure     [lindex [::bddimages_liste::lget $tabkey exposure] 1]

      set datejd       [ mc_date2jd $dateobs ]
      set datejd       [expr ($datejd + $exposure / 2. / 24. / 3600.)]
      set dateiso      [ mc_date2iso8601 $datejd ]

      set fluxobj $::bdi_gui_cdl_basic::tabphotom($i,obj,flux)
      set fwhmobj $::bdi_gui_cdl_basic::tabphotom($i,obj,fwhm)
      set errobj  $::bdi_gui_cdl_basic::tabphotom($i,obj,err_flux_pc)

      set fluxref $::bdi_gui_cdl_basic::tabphotom($i,star1,flux)
      set fwhmref $::bdi_gui_cdl_basic::tabphotom($i,star1,fwhm)
      set errref  $::bdi_gui_cdl_basic::tabphotom($i,star1,err_flux_pc)
      
      if {$fluxobj<0} { continue }
      if {$fluxref<0} { continue }
      
      set fluxnorm [expr $fluxobj / $fluxref * 10000.0]

      # En calculant la derivée : 
      set errfluxnorm [expr abs($fluxnorm * ( $errobj/$fluxobj - $errref/$fluxref )) ]
      # Calcul simple pessimiste
      set errfluxnorm [expr $fluxnorm * sqrt( pow($errobj/$fluxobj,2) + pow($errref/$fluxref,2)) ]

      set mag [expr $::bdi_gui_cdl_basic::firstmagref - log10($fluxobj/$fluxref)*2.5]
      set mag_instru_aster [expr log10($fluxobj/20000)*2.5]
      set mag_instru_star  [expr log10($fluxref/20000)*2.5]
      
      puts $fhandler "$dateiso,$datejd,$fluxnorm,$errfluxnorm,$mag,$mag_instru_aster,$mag_instru_star,$fwhmobj,$errobj,$fwhmref,$errref"
      
   }


   close $fhandler
   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "\nEnregistrement du rapport $file_result en $tt sec"

}



#------------------------------------------------------------
## Lancement de la GUI
#  @return void
#
proc ::bdi_gui_cdl_basic::run { } {


   global audace caption color
   global conf bddconf 

   set widthlab 30
   set widthentry 30
   set ::bdi_gui_cdl_basic::fen .cdl_basic
   #--- Initialisation des parametres
   ::bdi_gui_cdl_basic::inittoconf
   set ::tools_cdl::id_current_image 1

   #--- Geometry
   if { ! [ info exists conf(bddimages,geometry_cdl_basic) ] } {
      set conf(bddimages,geometry_cdl_basic) "+400+800"
   }
   set bddconf(geometry_cdl_basic) $conf(bddimages,geometry_cdl_basic)

   #--- Declare la GUI
   if { [ winfo exists $::bdi_gui_cdl_basic::fen ] } {
      wm withdraw $::bdi_gui_cdl_basic::fen
      wm deiconify $::bdi_gui_cdl_basic::fen
      #focus $::bdi_gui_cdl_basic::fen.buttons.but_fermer
      return
   }

   #--- GUI
   toplevel $::bdi_gui_cdl_basic::fen -class Toplevel
   wm geometry $::bdi_gui_cdl_basic::fen $bddconf(geometry_cdl_basic)
   wm resizable $::bdi_gui_cdl_basic::fen 1 1
   wm title $::bdi_gui_cdl_basic::fen "Analyse photometrique basique"
   wm protocol $::bdi_gui_cdl_basic::fen WM_DELETE_WINDOW { ::bdi_gui_cdl_basic::fermer }

   set frm $::bdi_gui_cdl_basic::fen.appli
   frame $frm  -cursor arrow -relief groove
   pack $frm -in $::bdi_gui_cdl_basic::fen -anchor s -side top -expand yes -fill both -padx 10 -pady 5



#--- Setup

     #--- Nom e l'Objet
     set nomobj [frame $frm.nomobj -borderwidth 0 -cursor arrow -relief groove]
     pack $nomobj -in $frm -anchor s -side top -expand 0 -fill x -padx 5 -pady 5
          label $nomobj.lab -text "Nom de l'objet"
          pack $nomobj.lab -in $nomobj -side left -padx 5 -pady 0
          entry $nomobj.val -relief sunken -textvariable ::bdi_gui_cdl_basic::nomobj -width 25 \
          -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
          pack $nomobj.val -in $nomobj -side left -pady 1 -anchor w

     #--- Repertoire des resultats
     set savedir [frame $frm.savedir -borderwidth 0 -cursor arrow -relief groove]
     pack $savedir -in $frm -anchor s -side top -expand 0 -fill x -padx 5 -pady 5
          label $savedir.lab -text "Repertoire de sauvegarde"
          pack $savedir.lab -in $savedir -side left -padx 5 -pady 0
          entry $savedir.val -relief sunken -textvariable ::bdi_gui_cdl_basic::savedir -width 50
          pack $savedir.val -in $savedir -side left -pady 1 -anchor w

     #--- Cree un frame pour afficher movingobject
     set move [frame $frm.move -borderwidth 0 -cursor arrow -relief groove]
     pack $move -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          #--- Cree un checkbutton
          checkbutton $move.check -highlightthickness 0 -text "Objet en mouvement" -variable ::bdi_gui_cdl_basic::movingobject
          pack $move.check -in $move -side left -padx 5 -pady 0

     #--- Nb points pour deplacement
     set nbporbit [frame $frm.nbporbit -borderwidth 0 -cursor arrow -relief groove]
     pack $nbporbit -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
          label $nbporbit.lab -text "Nb points pour deplacement"
          pack $nbporbit.lab -in $nbporbit -side left -padx 5 -pady 0
          spinbox $nbporbit.val -values [ list 2 3 5 9] -command "" -width 3 -textvariable ::bdi_gui_cdl_basic::nbporbit
          $nbporbit.val set 5
          pack  $nbporbit.val -in $nbporbit -side left -anchor w

     #--- Nb etoiles de reference
     set nbstars [frame $frm.nbstars -borderwidth 0 -cursor arrow -relief groove]
     set sources [frame $frm.sources -borderwidth 0 -cursor arrow -relief groove]
     pack $nbstars -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
          label $nbstars.lab -text "Nb d etoiles de reference"
          pack $nbstars.lab -in $nbstars -side left -padx 5 -pady 0
          spinbox $nbstars.val -from 1 -to 100 -increment 1 \
                   -command "::bdi_gui_cdl_basic::change_refstars $sources " \
                   -width 3 -textvariable ::bdi_gui_cdl_basic::nbstars
          pack  $nbstars.val -in $nbstars -side left -anchor w

     #--- Cree un frame pour afficher movingobject
     set stoperreur [frame $frm.stoperreur -borderwidth 0 -cursor arrow -relief groove]
     pack $stoperreur -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          #--- Cree un checkbutton
          checkbutton $stoperreur.check -highlightthickness 0 -text "Arret en cas d'erreur" \
                   -variable ::bdi_gui_cdl_basic::stoperreur
          pack $stoperreur.check -in $stoperreur -side left -padx 5 -pady 0

     #--- Cree un frame pour afficher movingobject
     set uncosm [frame $frm.uncosm -borderwidth 0 -cursor arrow -relief groove]
     pack $uncosm -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          #--- Cree un checkbutton
          checkbutton $uncosm.check -highlightthickness 0 -text "Uncosmic" \
                   -command "::bdi_gui_cdl_basic::change_uncosm " \
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
          entry $firstrefstar.val -relief sunken -textvariable ::bdi_gui_cdl_basic::firstmagref -width 6
          pack $firstrefstar.val -in $firstrefstar -side left -pady 1 -anchor w

     #--- Cree un frame pour afficher l acces direct a l image
     set directaccess [frame $frm.directaccess -borderwidth 0 -cursor arrow -relief groove]
     pack $directaccess -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          #--- Cree un checkbutton
          label $directaccess.lab -text "Access direct a l image : "
          pack $directaccess.lab -in $directaccess -side left -padx 5 -pady 0
          entry $directaccess.val -relief sunken \
             -textvariable ::bdi_gui_cdl_basic::directaccess -width 6 \
             -justify center
          pack $directaccess.val -in $directaccess -side left -pady 1 -anchor w
          button $directaccess.go -text "Go" -borderwidth 1 -takefocus 1 \
             -command "::bdi_gui_cdl_basic::go $sources"
          pack $directaccess.go -side left -anchor e \
             -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0


#--- Boutons


     #--- Cree un frame pour afficher les boutons
     set bouton [frame $frm.bouton -borderwidth 0 -cursor arrow -relief groove]
     pack $bouton -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          button $bouton.back -text "Precedent" -borderwidth 2 -takefocus 1 \
             -command "::bdi_gui_cdl_basic::back $sources" -state disabled
          pack $bouton.back -side left -anchor e \
             -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          button $bouton.next -text "Suivant" -borderwidth 2 -takefocus 1 \
             -command "::bdi_gui_cdl_basic::next $sources" -state disabled
          pack $bouton.next -side left -anchor e \
             -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          label $bouton.lab -text "Par bloc de :"
          pack $bouton.lab -in $bouton -side left
          entry $bouton.block -relief sunken -textvariable ::bdi_gui_cdl_basic::block -borderwidth 2 -width 6 -justify center
          pack $bouton.block -in $bouton -side left -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0 -anchor w

          button $bouton.stop -text "Stop" -borderwidth 2 -takefocus 1 \
             -command "::bdi_gui_cdl_basic::stop" -state normal
          pack $bouton.stop -side left -anchor e \
             -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


#--- Info etat avancement


     #--- Cree un frame pour afficher info image
     set infoimage [frame $frm.infoimage -borderwidth 0 -cursor arrow -relief groove]
     pack $infoimage -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         #--- Cree un label pour le Nom de l image
         label $infoimage.nomimage -text $::bdi_gui_cdl_basic::current_image_name
         pack $infoimage.nomimage -in $infoimage -side top -padx 3 -pady 3

         #--- Cree un label pour la date de l image
         label $infoimage.dateimage -text $::bdi_gui_cdl_basic::current_image_date
         pack $infoimage.dateimage -in $infoimage -side top -padx 3 -pady 3

         #--- Cree un label pour la date de l image
         label $infoimage.stimage -text "$::tools_cdl::id_current_image / $::tools_cdl::nb_img_list"
         pack $infoimage.stimage -in $infoimage -side top -padx 3 -pady 3


#--- Sources


     #--- Sources
     pack $sources -in $frm -anchor s -side top
        set name [frame $sources.name -borderwidth 0 -cursor arrow -relief groove]
        pack $name -in $sources -anchor s -side left
        set x [frame $sources.x -borderwidth 0 -cursor arrow -relief groove]
        pack $x -in $sources -anchor s -side left
        set y [frame $sources.y -borderwidth 0 -cursor arrow -relief groove]
        pack $y -in $sources -anchor s -side left
        set mag [frame $sources.mag -borderwidth 0 -cursor arrow -relief groove]
        pack $mag -in $sources -anchor s -side left
        set stdev [frame $sources.stdev -borderwidth 0 -cursor arrow -relief groove]
        pack $stdev -in $sources -anchor s -side left
        set delta [frame $sources.delta -borderwidth 0 -cursor arrow -relief groove]
        pack $delta -in $sources -anchor s -side left
        set select [frame $sources.select -borderwidth 0 -cursor arrow -relief groove]
        pack $select -in $sources -anchor s -side left
        set maj [frame $sources.maj -borderwidth 0 -cursor arrow -relief groove]
        pack $maj -in $sources -anchor s -side left

     #--- Objet

         label $name.obj    -text "Objet :"
         label $x.obj       -width 9
         label $y.obj       -width 9
         label $mag.obj     -width 9
         label $stdev.obj   -width 9
         spinbox $delta.obj -from 1 -to 100 -increment 1 -command "" -width 3 \
                -command "::bdi_gui_cdl_basic::mesure_tout $sources" \
                -textvariable ::bdi_gui_cdl_basic::tabsource(obj,delta)
         button $select.obj -text "Select" -command "::bdi_gui_cdl_basic::select_source $sources obj" -height 1
         button $maj.obj    -text "Maj" -command "::bdi_gui_cdl_basic::maj_source $sources obj" -height 1

         pack $name.obj   -in $name   -side top -pady 2 -ipady 2
         pack $x.obj      -in $x      -side top -pady 2 -ipady 2
         pack $y.obj      -in $y      -side top -pady 2 -ipady 2
         pack $mag.obj    -in $mag    -side top -pady 2 -ipady 2
         pack $stdev.obj  -in $stdev  -side top -pady 2 -ipady 2
         pack $delta.obj  -in $delta  -side top -pady 2 -ipady 2
         pack $select.obj -in $select -side top
         pack $maj.obj    -in $maj    -side top

         label $name.star1    -text "Star1 :"
         label $x.star1       -width 9
         label $y.star1       -width 9
         label $mag.star1     -width 9 -textvariable ::bdi_gui_cdl_basic::firstmagref
         label $stdev.star1   -width 9
         spinbox $delta.star1 -from 1 -to 100 -increment 1 -width 3 \
                -command "::bdi_gui_cdl_basic::mesure_tout $sources" \
                -textvariable ::bdi_gui_cdl_basic::tabsource(star1,delta)
         button $select.star1 -text "Select" -command "::bdi_gui_cdl_basic::select_source $sources star1"
         button $maj.star1 -text "Maj" -command "::bdi_gui_cdl_basic::maj_source $sources star1"

         pack $name.star1   -in $name   -side top -pady 2 -ipady 2
         pack $x.star1      -in $x      -side top -pady 2 -ipady 2
         pack $y.star1      -in $y      -side top -pady 2 -ipady 2
         pack $mag.star1    -in $mag    -side top -pady 2 -ipady 2
         pack $stdev.star1  -in $stdev  -side top -pady 2 -ipady 2
         pack $delta.star1  -in $delta  -side top -pady 2 -ipady 2
         pack $select.star1 -in $select -side top
         pack $maj.star1    -in $maj    -side top


#--- Boutons Final


     #--- Cree un frame pour afficher les boutons finaux
     set boutonfinal [frame $frm.boutonfinal -borderwidth 0 -cursor arrow -relief groove]
     set ::bdi_gui_cdl_basic::frame(boutonfinal) $boutonfinal
     pack $boutonfinal -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          button $boutonfinal.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
             -command ::bdi_gui_cdl_basic::fermer \
             -state normal
          pack $boutonfinal.fermer -side right -anchor e \
             -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


          button $boutonfinal.enregistrer -text "Enregistrer" -borderwidth 2 -takefocus 1 \
             -command "::bdi_gui_cdl_basic::save_results" -state disabled
          pack $boutonfinal.enregistrer -side right -anchor e \
             -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          button $boutonfinal.analyser -text "Analyser" -borderwidth 2 -takefocus 1 \
             -command "" -state disabled
          pack $boutonfinal.analyser -side right -anchor e \
             -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          button $boutonfinal.photometry -text "Photometrie" -borderwidth 2 -takefocus 1 \
             -command ::bdi_gui_cdl_basic::photometry -state normal
          pack $boutonfinal.photometry -side right -anchor e \
             -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


   set buttonsdev [frame $frm.buttonsdev -borderwidth 0 -cursor arrow -relief groove]
   pack $buttonsdev -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
   #grid $buttons -sticky nsw

       button $buttonsdev.ressource -text "Ressource les scripts" -borderwidth 2 -takefocus 1 \
          -command "::bddimages::ressource"
       button $buttonsdev.relance -text "Relance la GUI" -borderwidth 2 -takefocus 1 \
          -command "::bdi_gui_cdl_basic::relance"
       button $buttonsdev.clean -text "Efface le contenu de la console" -borderwidth 2 -takefocus 1 \
          -command "console::clear"


      grid $buttonsdev.ressource $buttonsdev.relance $buttonsdev.clean -sticky news


   ::bdi_gui_cdl_basic::charge_current_image
}
