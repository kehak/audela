## @file bddimages_cdl.tcl
#  @brief     Cr&eacute;ation et manipulation des courbes photmom&eacute;triques
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bddimages_cdl.tcl]
#  @endcode

# $Id: bddimages_cdl.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bddimages_cdl
# @brief Cr&eacute;ation et manipulation des courbes photmom&eacute;triques
# @pre Requiert les ressources de bddimages
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bddimages_cdl {

   global audace
   global bddconf
   global caption

   variable interpol_aster interpol_star1
   variable img_list
   variable file_result_m1
   variable file_result_m2
   variable file_result_m3
   variable file_result_m3_tab
   variable stop
   variable delta_star
   variable delta_aster
   variable magstar
   variable filter
   variable telescop
   variable period
   variable object
   variable begin
   variable end  
   variable courbe  

   variable fhandler_mpc  

}

#--------------------------------------------------
#
#  Structure de la liste image
#
# {               -- debut de liste
#
#   {             -- debut d une image
#
#     {ibddimg 1}
#     {ibddcata 2}
#     {filename toto.fits.gz}
#     {dirfilename /.../}
#     {filenametmp toto.fit}
#     {cataexist 1}
#     {cataloaded 1}
#     ...
#     {tabkey {{NAXIS1 1024} {NAXIS2 1024}} }
#     {cata {{{IMG {ra dec ...}{USNO {...]}}}} { { {IMG {4.3 -21.5 ...}} {USNOA2 {...}} } {source2} ... } } }
#
#   }             -- fin d une image
#
# }               -- fin de liste
#
#--------------------------------------------------
#
#  Structure du tabkey
#
# { {NAXIS1 1024} {NAXIS2 1024} etc ... }
#
#--------------------------------------------------
#
#  Structure du cata
#
# {               -- debut structure generale
#
#  {              -- debut des noms de colonne des catalogues
#
#   { IMG   {list field crossmatch} {list fields}} 
#   { TYC2  {list field crossmatch} {list fields}}
#   { USNO2 {list field crossmatch} {list fields}}
#
#  }              -- fin des noms de colonne des catalogues
#
#  {              -- debut des sources
#
#   {             -- debut premiere source
#
#    { IMG   {crossmatch} {fields}}  -> vue dans l image
#    { TYC2  {crossmatch} {fields}}  -> vue dans le catalogue
#    { USNO2 {crossmatch} {fields}}  -> vue dans le catalogue
#
#   }             -- fin premiere source
#
#  }              -- fin des sources
#
# }               -- fin structure generale
#
#--------------------------------------------------
#
#  Structure intellilist_i (dite inteligente)
#
#
# {
#   {name               ...  }
#   {datemin            ...  }
#   {datemax            ...  }
#   {type_req_check     ...  }
#   {type_requ          ...  }
#   {choix_limit_result ...  }
#   {limit_result       ...  }
#   {type_result        ...  }
#   {type_select        ...  }
#   {reqlist           { 
#                        { valide     ... }
#                        { condition  ... }
#                        { champ      ... }
#                        { valeur     ... }
#                      }
#
#   }
#
# }
#
#--------------------------------------------------
#
#  Structure intellilist_n (dite normale)
#
#
# {
#   {name               ...  }
#   {datemin            ...  }
#   {datemax            ...  }
#   {type_req_check     ...  }
#   {type_requ          ...  }
#   {choix_limit_result ...  }
#   {limit_result       ...  }
#   {type_result        ...  }
#   {type_select        ...  }
#   {reqlist            { 
#                         {image_34 {134 345 677}}
#                         {image_38 {135 344 679}}
#                       }
#
#   }
#
# }
#
#--------------------------------------------------

proc cleanmark { } {

   $::audace(hCanvas) delete cadres

}


proc ::bddimages_cdl::run {  } {

   cleanmark
   
   ::bddimages_cdl::init
   if { $::bddimages_cdl::stop == 0} {
      ::bddimages_cdl::mesure_images
   }
   ::console::affiche_resultat "Fin script CdL... \n"   
   return

}


proc ::bddimages_cdl::init {  } {

   global bddconf
   
   set ::bddimages_cdl::magstar 13.69
   set ::bddimages_cdl::stop 0
   set ::bddimages_cdl::delta_star  0
   set ::bddimages_cdl::delta_aster 0
   
   # Recuperation des informations des images selectionnees
   set selection_list [::bddimages_imgcorrection::get_info_img]
   # Chargement de la liste IMG
   set ::bddimages_cdl::img_list [::bddimages_imgcorrection::select_img_list_by_type IMG CORR $selection_list]
   set nbimg  [llength $::bddimages_cdl::img_list]
   ::console::affiche_resultat "nbimg : $nbimg\n"
   set ::bddimages_cdl::img_list [::bddimages_imgcorrection::chrono_sort_img $::bddimages_cdl::img_list]
   
   # Chargement de la premiere image de la liste
   set img [::bddimages_imgcorrection::chrono_first_img $::bddimages_cdl::img_list]
   set filename [::bddimages_liste::lget $img "filename"]
   set dirfilename [::bddimages_liste::lget $img "dirfilename"]
   set tabkey  [::bddimages_liste::lget $img "tabkey"]
   set dateobs [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]
   set begin   $dateobs
   set commundatejj [::bddimages_liste::lget $img "commundatejj"]
   ::console::affiche_resultat "file : $dirfilename/$filename\n"
   ::console::affiche_resultat "first dateobs $dateobs \n"
   set file [file join $bddconf(dirbase) $dirfilename $filename]
   loadima $file
   set td $commundatejj
   
   # Selection de l etoile
   set star_deb [::bddimages_cdl::select_source "Selection de l etoile" 1]
   affich_un_rond_xy  [lindex $star_deb 0] [lindex $star_deb 1] "yellow" [lindex $star_deb 2] 1
   if {$::bddimages_cdl::stop} {return}
   lappend star_deb $commundatejj
   ::console::affiche_resultat "star : $star_deb\n"
   
   # Selection de l asteroide
   set aster_deb [::bddimages_cdl::select_source "Selection de l asteroide" 0]
   affich_un_rond_xy  [lindex $aster_deb 0] [lindex $aster_deb 1] "green"  [lindex $aster_deb 2] 1
   if {$::bddimages_cdl::stop} {return}
   lappend aster_deb $commundatejj
   ::console::affiche_resultat "aster : $aster_deb\n"

   ::console::affiche_resultat "\n** ESTIMATION ETOILE ** \n\n"
   set ::bddimages_cdl::delta_star  [::bddimages_cdl::estimation_fenetre [list $star_deb  ] ]
   ::console::affiche_resultat "\n** ESTIMATION ASTEROIDE ** \n\n"
   set ::bddimages_cdl::delta_aster [::bddimages_cdl::estimation_fenetre [list $aster_deb ] ]
   ::console::affiche_resultat "\n** ESTIMATION : $::bddimages_cdl::delta_aster $::bddimages_cdl::delta_star \n\n"

   # Chargement de la derniere image
   set img [::bddimages_imgcorrection::chrono_last_img $::bddimages_cdl::img_list]
   set filename [::bddimages_liste::lget $img "filename"]
   set dirfilename [::bddimages_liste::lget $img "dirfilename"]
   set tabkey  [::bddimages_liste::lget $img "tabkey"]
   set filter  [::bddimages_imgcorrection::cleanEntities [lindex [::bddimages_liste::lget $tabkey "filter"] 1] ]
   set dateobs [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]
   set end   $dateobs
   set commundatejj [::bddimages_liste::lget $img "commundatejj"]
   ::console::affiche_resultat "file : $dirfilename/$filename\n"
   ::console::affiche_resultat "last dateobs $dateobs \n"
   set file [file join $bddconf(dirbase) $dirfilename $filename]
   loadima $file
   set tf $commundatejj
   
   #Selection de l etoile
   set star_fin [::bddimages_cdl::select_source "Selection de l etoile" 0]
   affich_un_rond_xy  [lindex $star_fin 0] [lindex $star_fin 1] "yellow" [lindex $star_fin 2] 1
   if {$::bddimages_cdl::stop} {return}
   lappend star_fin $commundatejj
   
   ::console::affiche_resultat "star : $star_fin\n"
   #Selection de l asteroide
   set aster_fin [::bddimages_cdl::select_source "Selection de l asteroide" 0]
   affich_un_rond_xy  [lindex $aster_fin 0] [lindex $aster_fin 1] "green" [lindex $aster_fin 2] 1
   if {$::bddimages_cdl::stop} {return}
   lappend aster_fin $commundatejj
   ::console::affiche_resultat "aster : $aster_fin\n"

   set xd [lindex $aster_deb 0]
   set yd [lindex $aster_deb 1]
   set xf [lindex $aster_fin 0]
   set yf [lindex $aster_fin 1]
   
   set ::bddimages_cdl::interpol_aster [list $xd $yd $td $xf $yf $tf]
   
   set xd [lindex $star_deb 0]
   set yd [lindex $star_deb 1]
   set xf [lindex $star_fin 0]
   set yf [lindex $star_fin 1]
   
   set ::bddimages_cdl::interpol_star1 [list $xd $yd $td $xf $yf $tf]
   
   ::console::affiche_resultat "\n** ESTIMATION ETOILE ** \n\n"
   set ::bddimages_cdl::delta_star  [::bddimages_cdl::estimation_fenetre [list $star_fin  ] ]
   ::console::affiche_resultat "\n** ESTIMATION ASTEROIDE ** \n\n"
   set ::bddimages_cdl::delta_aster [::bddimages_cdl::estimation_fenetre [list $aster_fin ] ]
   ::console::affiche_resultat "\n** ESTIMATION : $::bddimages_cdl::delta_aster $::bddimages_cdl::delta_star \n\n"
   
   ::bddimages_cdl::box_fenetre
   
   set tabkey   [::bddimages_liste::lget $img "tabkey"]
   
   set telescop [lindex [::bddimages_liste::lget $tabkey telescop] 1]
   set object   [::bddimages_imgcorrection::cleanEntities [lindex [::bddimages_liste::lget $tabkey "object"] 1] ]
   set dateobs  [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
   set dateobs  [::bddimages_imgcorrection::isoDateToString $dateobs]
   
   set ::bddimages_cdl::period [expr ($tf - $td)*24.]
   set ::bddimages_cdl::telescop $telescop
   set ::bddimages_cdl::filter   $filter
   set ::bddimages_cdl::object   $object
   set ::bddimages_cdl::begin    $begin
   set ::bddimages_cdl::end      $end
   
   set ::bddimages_cdl::file_result  [file join $bddconf(dirtmp) "${object}_${telescop}_${filter}_${dateobs}.csv"]
   set ::bddimages_cdl::file_result_mpc [file join $bddconf(dirtmp) "${object}_${telescop}_${filter}_${dateobs}.mpc"]
   
   
   ::console::affiche_resultat "Results Files : \n"
   ::console::affiche_resultat "$::bddimages_cdl::file_result\n"
   ::console::affiche_resultat "$::bddimages_cdl::file_result_mpc\n"

   #set ::bddimages_cdl::file_result_m2  [file join $bddconf(dirtmp) "${telescop}_${dateobs}_${object}_m2.csv"]
   #::console::affiche_resultat "RESULTAT DANS FICHIER : $::bddimages_cdl::file_result_m2\n"
   #set ::bddimages_cdl::file_result_m3  [file join $bddconf(dirtmp) "${telescop}_${dateobs}_${object}_m3.csv"]
   #::console::affiche_resultat "RESULTAT DANS FICHIER : $::bddimages_cdl::file_result_m3\n"

}



proc ::bddimages_cdl::mesure_images {  } {

   global bddconf
   global audace
   global posxy
   global private
      
   set private(psf_toolbox,$::audace(visuNo),gui) 0
   array unset posxy
   set ::bddimages_cdl::delta_star 5
   
   set id 0
   foreach img $::bddimages_cdl::img_list {
   
      $audace(hCanvas) delete cadres
   
      set commundatejj [::bddimages_liste::lget $img "commundatejj"]
      set filename     [::bddimages_liste::lget $img "filename"]
      set dirfilename  [::bddimages_liste::lget $img "dirfilename"]
      set tabkey       [::bddimages_liste::lget $img "tabkey"]
      set exposure     [lindex [::bddimages_liste::lget $tabkey exposure] 1]
      set dateobs      [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
      set datejd       [ mc_date2jd $dateobs ]
      set datejd       [expr ($datejd + $exposure / 2. / 24. / 3600.)]
      set dateiso      [ mc_date2iso8601 $datejd ]
    
      set file [file join $bddconf(dirbase) $dirfilename $filename]
      loadima $file
      ::bddimages_cdl::interpol_to_verif $commundatejj $dateiso
      update
      
      incr id
   }
   
   set r [tk_messageBox -message "Verification terminer. Lancement de la mesure photometrique ?" -type yesno]      
   if {$r == "yes"} {
      set sortie 0
      while {$sortie==0} {
         $audace(hCanvas) delete cadres
         set fhandler [open $::bddimages_cdl::file_result "w"]
         puts $fhandler "#OBJECT   = $::bddimages_cdl::object"
         puts $fhandler "#TELESCOP = $::bddimages_cdl::telescop"
         puts $fhandler "#FILTER   = $::bddimages_cdl::filter"
         puts $fhandler "#BEGIN    = $::bddimages_cdl::begin"
         puts $fhandler "#END      = $::bddimages_cdl::end"
         puts $fhandler "#OBSTIME  = $::bddimages_cdl::period"
         puts $fhandler "dateiso,datejj,mag_aster,mag_instru_aster,mag_instru_star,fwhma,err_flux_pca,fwhms,err_flux_pcs"
   
         set id 0
         foreach img $::bddimages_cdl::img_list {
   
            $audace(hCanvas) delete cadres
   
            set filename     [::bddimages_liste::lget $img "filename"]
            set dirfilename  [::bddimages_liste::lget $img "dirfilename"]
            set tabkey       [::bddimages_liste::lget $img "tabkey"]
            set exposure     [lindex [::bddimages_liste::lget $tabkey exposure] 1]
            set dateobs      [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
            set datejd       [ mc_date2jd $dateobs ]
            set datejd       [expr ($datejd + $exposure / 2. / 24. / 3600.)]
            set dateiso      [ mc_date2iso8601 $datejd ]
   
            set file [file join $bddconf(dirbase) $dirfilename $filename]
            loadima $file
            ::bddimages_cdl::mesure_photocentre $fhandler $commundatejj $dateiso $datejd
            update
   
            incr id
         }
         close $fhandler
   
         set r [tk_messageBox -message "Satisfait du resultat ?" -type yesno]      
         if {$r == "yes"} {
            set sortie 1
         }
      }
   }
   
   $audace(hCanvas) delete cadres

}




proc ::bddimages_cdl::interpol_to_verif { commundatejj dateiso } {

   global posxy
   
   set ls [::bddimages_cdl::interpol $::bddimages_cdl::interpol_star1 $commundatejj]

   set err [catch {
      set valeurs  [photom_methode1 [lindex $ls 0] [lindex $ls 1] $::bddimages_cdl::delta_star]
   } msg ]
   if {$err!=0} {
      ::console::affiche_erreur "interpol_to_verif : mesure star impossible\n"
      return
   }
   set xsm [lindex $valeurs 0]
   set ysm [lindex $valeurs 1]
   set posxy($dateiso,star,x) $xsm
   set posxy($dateiso,star,y) $ysm
   affich_un_rond_xy  $xsm $ysm "yellow" 20 1

   set la [::bddimages_cdl::interpol $::bddimages_cdl::interpol_aster $commundatejj]

   set err [catch {
      set valeurs  [photom_methode1 [lindex $la 0] [lindex $la 1] $::bddimages_cdl::delta_aster]
   } msg ]
   if {$err!=0} {
      ::console::affiche_erreur "interpol_to_verif : mesure aster impossible\n"
      return
   }
   set xam [lindex $valeurs 0]
   set yam [lindex $valeurs 1]
   set posxy($dateiso,aster,x) $xam
   set posxy($dateiso,aster,y) $yam
   affich_un_rond_xy  $xam $yam "green" 20 1

}



proc ::bddimages_cdl::mesure_photocentre { f commundatejj dateiso datejd } {

   global posxy
   global private
   
   set pass 0
   set xsm  $posxy($dateiso,star,x)
   set ysm  $posxy($dateiso,star,y)
   set xam  $posxy($dateiso,aster,x)
   set yam  $posxy($dateiso,aster,y)

   # Effectue la mesure de l etoile
   if {$private(psf_toolbox,$::audace(visuNo),globale)} {
      set err [catch { ::audace::PSF_globale $::audace(visuNo) $xsm $ysm } msg ]
   } else {
      set err [catch { ::audace::PSF_one_radius $::audace(visuNo) $xsm $ysm } msg ]
   }

   if {$err} {
      gren_erreur "Err PSF: ($err) ($msg)\n"
   } else {
      incr pass
      # Met a jour les resultats
      set tabmes(star,xsm)        $private(psf_toolbox,$::audace(visuNo),psf,xsm)      
      set tabmes(star,ysm)        $private(psf_toolbox,$::audace(visuNo),psf,ysm)      
      set tabmes(star,err_xsm)    $private(psf_toolbox,$::audace(visuNo),psf,err_xsm)  
      set tabmes(star,err_ysm)    $private(psf_toolbox,$::audace(visuNo),psf,err_ysm)  
      set tabmes(star,fwhmx)      $private(psf_toolbox,$::audace(visuNo),psf,fwhmx)    
      set tabmes(star,fwhmy)      $private(psf_toolbox,$::audace(visuNo),psf,fwhmy)    
      set tabmes(star,fwhm)       $private(psf_toolbox,$::audace(visuNo),psf,fwhm)     
      set tabmes(star,flux)       $private(psf_toolbox,$::audace(visuNo),psf,flux)     
      set tabmes(star,err_flux)   $private(psf_toolbox,$::audace(visuNo),psf,err_flux) 
      set tabmes(star,pixmax)     $private(psf_toolbox,$::audace(visuNo),psf,pixmax)   
      set tabmes(star,intensity)  $private(psf_toolbox,$::audace(visuNo),psf,intensity)
      set tabmes(star,sky)        $private(psf_toolbox,$::audace(visuNo),psf,sky)      
      set tabmes(star,err_sky)    $private(psf_toolbox,$::audace(visuNo),psf,err_sky)  
      set tabmes(star,snint)      $private(psf_toolbox,$::audace(visuNo),psf,snint)    
      set tabmes(star,radius)     $private(psf_toolbox,$::audace(visuNo),psf,radius)   
      set tabmes(star,rdiff)      $private(psf_toolbox,$::audace(visuNo),psf,rdiff)  
      set tabmes(star,err_psf)    $private(psf_toolbox,$::audace(visuNo),psf,err_psf) 
      set tabmes(star,err_flux_pc) [expr $tabmes(star,err_flux)/$tabmes(star,flux)*100.]
      set posxy($dateiso,star,x)  $private(psf_toolbox,$::audace(visuNo),psf,xsm)   
      set posxy($dateiso,star,y)  $private(psf_toolbox,$::audace(visuNo),psf,ysm)   
      affich_un_rond_xy $private(psf_toolbox,$::audace(visuNo),psf,xsm)  $private(psf_toolbox,$::audace(visuNo),psf,ysm) "yellow" 20 1
   }

   # Effectue la mesure de l etoile
   if {$private(psf_toolbox,$::audace(visuNo),globale)} {
      set err [catch { ::audace::PSF_globale $::audace(visuNo) $xam $yam } msg ]
   } else {
      set err [catch { ::audace::PSF_one_radius $::audace(visuNo) $xsm $ysm } msg ]
   }

   if {$err} {
      gren_erreur "Err PSF: ($err) ($msg)\n"
   } else {
      incr pass
      # Met a jour les resultats
      set tabmes(aster,xsm)        $private(psf_toolbox,$::audace(visuNo),psf,xsm)      
      set tabmes(aster,ysm)        $private(psf_toolbox,$::audace(visuNo),psf,ysm)      
      set tabmes(aster,err_xsm)    $private(psf_toolbox,$::audace(visuNo),psf,err_xsm)  
      set tabmes(aster,err_ysm)    $private(psf_toolbox,$::audace(visuNo),psf,err_ysm)  
      set tabmes(aster,fwhmx)      $private(psf_toolbox,$::audace(visuNo),psf,fwhmx)    
      set tabmes(aster,fwhmy)      $private(psf_toolbox,$::audace(visuNo),psf,fwhmy)    
      set tabmes(aster,fwhm)       $private(psf_toolbox,$::audace(visuNo),psf,fwhm)     
      set tabmes(aster,flux)       $private(psf_toolbox,$::audace(visuNo),psf,flux)     
      set tabmes(aster,err_flux)   $private(psf_toolbox,$::audace(visuNo),psf,err_flux) 
      set tabmes(aster,pixmax)     $private(psf_toolbox,$::audace(visuNo),psf,pixmax)   
      set tabmes(aster,intensity)  $private(psf_toolbox,$::audace(visuNo),psf,intensity)
      set tabmes(aster,sky)        $private(psf_toolbox,$::audace(visuNo),psf,sky)      
      set tabmes(aster,err_sky)    $private(psf_toolbox,$::audace(visuNo),psf,err_sky)  
      set tabmes(aster,snint)      $private(psf_toolbox,$::audace(visuNo),psf,snint)    
      set tabmes(aster,radius)     $private(psf_toolbox,$::audace(visuNo),psf,radius)   
      set tabmes(aster,rdiff)      $private(psf_toolbox,$::audace(visuNo),psf,rdiff)  
      set tabmes(aster,err_psf)    $private(psf_toolbox,$::audace(visuNo),psf,err_psf) 
      set posxy($dateiso,aster,x)  $private(psf_toolbox,$::audace(visuNo),psf,xsm)   
      set posxy($dateiso,aster,y)  $private(psf_toolbox,$::audace(visuNo),psf,ysm)
      set tabmes(aster,err_flux_pc) [expr $tabmes(aster,err_flux)/$tabmes(aster,flux)*100.]
      affich_un_rond_xy $private(psf_toolbox,$::audace(visuNo),psf,xsm)  $private(psf_toolbox,$::audace(visuNo),psf,ysm) "green" 20 1
   }

   if {$pass==2} {
      set err [catch {
         set mag [expr $::bddimages_cdl::magstar - log10($tabmes(aster,flux)/$tabmes(star,flux))*2.5]
         set mag_instru_aster [expr log10($tabmes(aster,flux)/20000)*2.5]
         set mag_instru_star  [expr log10($tabmes(star,flux)/20000)*2.5]
      } msg ]
      if {$err!=0} {
         ::console::affiche_erreur "METHODE 1\n"
         ::console::affiche_erreur "err = $err\n"
         ::console::affiche_erreur "msg = $msg\n"
         ::console::affiche_erreur "flux aster = $tabmes(aster,flux)\n"
         ::console::affiche_erreur "flux star = $tabmes(star,flux)\n"
      }
      puts $f "$dateiso,$datejd,$mag,$mag_instru_aster,$mag_instru_star,$tabmes(aster,fwhm),$tabmes(aster,err_flux_pc),$tabmes(star,fwhm),$tabmes(star,err_flux_pc)"
   }
}



proc ::bddimages_cdl::interpol { interpol t} {
 
   set xd [lindex $interpol 0]
   set yd [lindex $interpol 1]
   set td [lindex $interpol 2]
   set xf [lindex $interpol 3]
   set yf [lindex $interpol 4]
   set tf [lindex $interpol 5]

   set x [expr ($xd-$xf)/($td-$tf)*$t + ($td * $xf - $tf * $xd) / ($td-$tf)]
   set y [expr ($yd-$yf)/($td-$tf)*$t + ($td * $yf - $tf * $yd) / ($td-$tf)]

   return [list $x $y]
}




proc ::bddimages_cdl::select_source { txt flag } {

   ::bddimages_cdl::box_source $txt $flag
   if { $::bddimages_cdl::stop == 1} {return}

   set rect [ ::confVisu::getBox $::audace(visuNo) ]
   set xsm [expr ([lindex $rect 0] + [lindex $rect 2]) / 2. ]
   set ysm [expr ([lindex $rect 1] + [lindex $rect 3]) / 2. ]
   set deltax [expr abs([lindex $rect 0] - [lindex $rect 2]) / 2.  ]
   set deltay [expr abs([lindex $rect 1] - [lindex $rect 3]) / 2.  ]
   if {$deltax < $deltay} {
      set delta $deltay
   } else {
      set delta $deltax
   }
   return [list $xsm $ysm $delta]
}

   

proc ::bddimages_cdl::box_source { txt flag } {

   set magstar $::bddimages_cdl::magstar
   
   set tl [ toplevel $::audace(base).bddimages_cdl \
       -class Toplevel -borderwidth 2 -relief groove ]
   wm title $tl titre
   wm resizable $tl 0 0
   wm protocol $tl WM_DELETE_WINDOW
   wm transient $tl .audace

   set tlfaide [ frame $tl.aide ]
   label $tlfaide.l -text  $txt
   pack $tlfaide.l

   if {$flag == 1} {
      set tlf1 [ frame $tl.f1 -borderwidth 2 -relief groove ]
      set tlf1l [ label $tlf1.l -text magnitude ]
      set tlf1e [ entry $tlf1.e -textvariable ::bddimages_cdl::magstar \
          -width -1 -relief sunken ]
      $tlf1.e delete 0 end
      $tlf1.e insert 0 $magstar
      grid $tlf1l $tlf1e
   }

   set tlf2 [ frame $tl.f2 -borderwidth 2 -relief groove ]
   set tlf2b1 [ button $tlf2.b1 -text ok -command { 
           update idletasks
           destroy $::audace(base).bddimages_cdl
           ::console::affiche_resultat "** MAGSTAR = $::bddimages_cdl::magstar\n"
       } ]
   set tlf2b2 [ button $tlf2.b2 -text arret -command {
           update idletasks
           destroy $::audace(base).bddimages_cdl
           set ::bddimages_cdl::stop 1
       } ]

   pack $tlf2b1 $tlf2b2 -side left -padx 10 -pady 10
   if {$flag == 1} {
      pack $tlfaide $tlf1 $tlf2
   } else {
      pack $tlfaide $tlf2
   }
   ::confColor::applyColor $tl
   tkwait window $tl
   return ""

}



proc ::bddimages_cdl::box_fenetre { } {

   set ::bddimages_cdl::delta_star   5
   set ::bddimages_cdl::delta_aster  5

   set deltas $::bddimages_cdl::delta_star
   set deltaa $::bddimages_cdl::delta_aster

   set tl [ toplevel $::audace(base).bddimages_cdl \
       -class Toplevel -borderwidth 2 -relief groove ]
   wm title $tl titre
   wm resizable $tl 0 0
   wm protocol $tl WM_DELETE_WINDOW
   wm transient $tl .audace

   set tlfaide [ frame $tl.aide ]
   label $tlfaide.l -text  "Taille de la fenetre pour le suivi des objets"
   pack $tlfaide.l

   set tlf1 [ frame $tl.f1 -borderwidth 2 -relief groove ]
   set tlf1l [ label $tlf1.l -text "box etoile" ]
   set tlf1e [ entry $tlf1.e -textvariable ::bddimages_cdl::delta_star \
       -width -1 -relief sunken ]
   $tlf1.e delete 0 end
   $tlf1.e insert 0 $deltas
   grid $tlf1l $tlf1e

   set tlf3 [ frame $tl.f3 -borderwidth 2 -relief groove ]
   set tlf3l [ label $tlf3.l -text "box aster" ]
   set tlf3e [ entry $tlf3.e -textvariable ::bddimages_cdl::delta_aster \
       -width -1 -relief sunken ]
   $tlf3.e delete 0 end
   $tlf3.e insert 0 $deltaa
   grid $tlf3l $tlf3e

   set tlf2 [ frame $tl.f2 -borderwidth 2 -relief groove ]
   set tlf2b1 [ button $tlf2.b1 -text ok -command { 
           update idletasks
           destroy $::audace(base).bddimages_cdl
           ::console::affiche_resultat "** DELTA STAR = $::bddimages_cdl::delta_star\n"
           ::console::affiche_resultat "** DELTA ASTER = $::bddimages_cdl::delta_aster\n"
       } ]
   set tlf2b2 [ button $tlf2.b2 -text arret -command {
           update idletasks
           destroy $::audace(base).bddimages_cdl
           set ::bddimages_cdl::stop 1
       } ]

   pack $tlf2b1 $tlf2b2 -side left -padx 10 -pady 10
   pack $tlfaide $tlf1 $tlf3 $tlf2
   ::confColor::applyColor $tl
   tkwait window $tl
   return ""

}




proc ::bddimages_cdl::photom_methode1 { xsm ysm delta } {

   set xs0 [expr int($xsm - $delta)]
   set ys0 [expr int($ysm - $delta)]
   set xs1 [expr int($xsm + $delta)]
   set ys1 [expr int($ysm + $delta)]

   set valeurs [  buf[ ::confVisu::getBufNo $::audace(visuNo) ] fitgauss [ list $xs0 $ys0 $xs1 $ys1 ] ]
   set fwhm [expr ([lindex $valeurs 2] + [lindex $valeurs 6])/2.]
   set xsm  [lindex $valeurs 1]
   set ysm  [lindex $valeurs 5]

   set xs0 [expr int($xsm - $delta)]
   set ys0 [expr int($ysm - $delta)]
   set xs1 [expr int($xsm + $delta)]
   set ys1 [expr int($ysm + $delta)]

   set err [catch {
      set valeurs [  buf[ ::confVisu::getBufNo $::audace(visuNo) ] photom [list $xs0 $ys0 $xs1 $ys1] square 20 25 35 ]
   } msg ]
   if {$err!=0} {
      return code error 1 $msg
   }
   set flux    [lindex $valeurs 0]
   set sigma   [lindex $valeurs 3]
   set errflux 0

   set err [catch {
      set sn [expr ($flux / $sigma)]
   } msg ]
   if {$err!=0} {
      set sn 0
      ::console::affiche_erreur "photom_methode1\n"
      ::console::affiche_erreur "err   = $err\n"
      ::console::affiche_erreur "msg   = $msg\n"
      ::console::affiche_erreur "flux  = $flux\n"
      ::console::affiche_erreur "sigma = $sigma\n"
   }

   #::console::affiche_erreur "M1 r1 r2 r3 flux sigma = 20 25 35 $flux $sigma\n"
   #::console::affiche_resultat "flux int photom = $flux \n"

   return [ list $xsm $ysm $flux $errflux $fwhm $sigma $sn]
}



proc ::bddimages_cdl::photom_methode2 { xm ym delta } {

   set gamma 2

   set xs0 [expr int($xm - $delta)]
   set ys0 [expr int($ym - $delta)]
   set xs1 [expr int($xm + $delta)]
   set ys1 [expr int($ym + $delta)]

   set valeurs [  buf[ ::confVisu::getBufNo $::audace(visuNo) ] fitgauss [ list $xs0 $ys0 $xs1 $ys1 ] ]
   set fwhm [expr ([lindex $valeurs 2] + [lindex $valeurs 6])/2.]
   set xsm  [lindex $valeurs 1]
   set ysm  [lindex $valeurs 5]
   set delta [expr int($gamma * $fwhm)+1]

   
   set r1  [expr int(2*$delta)]
   set r2  [expr int(2.5*$delta)]
   set r3  [expr int(3.5*$delta)]
   set xs0 [expr int($xsm - $r1)]
   set ys0 [expr int($ysm - $r1)]
   set xs1 [expr int($xsm + $r1)]
   set ys1 [expr int($ysm + $r1)]
   set valeurs [  buf[ ::confVisu::getBufNo $::audace(visuNo) ] photom [list $xs0 $ys0 $xs1 $ys1] square $r1 $r2 $r3 ]
   set flux    [lindex $valeurs 0]
   set sigma   [lindex $valeurs 3]
   set sn   [expr $flux/$sigma]
   set errflux 0
   #::console::affiche_erreur "M2 r1 r2 r3 flux sigma = $r1 $r2 $r3 $flux $sigma\n"

   return [ list $xsm $ysm $flux $errflux $fwhm $sigma $sn]
}



proc ::bddimages_cdl::photom_methode3 { xsm ysm delta } {

   set xs0 [expr int($xsm - $delta)]
   set ys0 [expr int($ysm - $delta)]
   set xs1 [expr int($xsm + $delta)]
   set ys1 [expr int($ysm + $delta)]

   set valeurs [  buf[ ::confVisu::getBufNo $::audace(visuNo) ] fitgauss [ list $xs0 $ys0 $xs1 $ys1 ] ]
   set fwhm [expr ([lindex $valeurs 2] + [lindex $valeurs 6])/2.]
   set xsm  [lindex $valeurs 1]
   set ysm  [lindex $valeurs 5]

   set xs0 [expr int($xsm - $delta)]
   set ys0 [expr int($ysm - $delta)]
   set xs1 [expr int($xsm + $delta)]
   set ys1 [expr int($ysm + $delta)]

   set r1  [expr int(1*$delta)]
   set r2  [expr int(1.25*$delta)]
   set r3  [expr int(1.75*$delta)]

   set valeurs [  buf[ ::confVisu::getBufNo $::audace(visuNo) ] photom [list $xs0 $ys0 $xs1 $ys1] square $r1 $r2 $r3 ]
   set flux    [lindex $valeurs 0]
   set sigma   [lindex $valeurs 3]
   set sn      [expr $flux/$sigma]
   set errflux 0
   #::console::affiche_erreur "M3 r1 r2 r3 flux sigma = $r1 $r2 $r3 $flux $sigma\n"

   #::console::affiche_resultat "flux int photom = $flux \n"

   return [ list $xsm $ysm $flux $errflux $fwhm $sigma $sn]
}



proc ::bddimages_cdl::estimation_fenetre { target_list } {

   set result_delta 1

   ::console::affiche_resultat "ESTIM delta_star = $::bddimages_cdl::delta_star\n"
   ::console::affiche_resultat "ESTIM delta_aster= $::bddimages_cdl::delta_aster\n"

   set result_delta $::bddimages_cdl::delta_star
   if {$result_delta<$::bddimages_cdl::delta_aster} {
      set result_delta $::bddimages_cdl::delta_aster
   }

   foreach target $target_list {

      set x [lindex $target 0]
      set y [lindex $target 1]
      set d [lindex $target 2]

      set xs0 [expr int($x - $d)]
      set ys0 [expr int($y - $d)]
      set xs1 [expr int($x + $d)]
      set ys1 [expr int($y + $d)]

      set valeurs [  buf[ ::confVisu::getBufNo $::audace(visuNo) ] fitgauss [ list $xs0 $ys0 $xs1 $ys1 ] ]
      set fwhm [expr ([lindex $valeurs 2] + [lindex $valeurs 6])/2.]
      set estimf [expr int($fwhm * 1.7)]
      set valeurs [photom_methode1 $x $y $estimf]
      set flux [lindex $valeurs 2]
      ::console::affiche_resultat "DELTA 1.7 delta = $estimf | flux = $flux\n"
      set estimf [expr int($fwhm * 2.3)]
      set valeurs [photom_methode1 $x $y $estimf]
      set flux [lindex $valeurs 2]
      ::console::affiche_resultat "DELTA 2.3 delta = $estimf | flux = $flux\n"
      set estimf [expr int($fwhm * 3.0)]
      set valeurs [photom_methode1 $x $y $estimf]
      set flux [lindex $valeurs 2]
      ::console::affiche_resultat "DELTA 3.0 delta = $estimf | flux = $flux\n"

      if {$result_delta<$estimf} {
         set result_delta $estimf
      }

      # fenetre croissante
#      ::console::affiche_resultat "ASC...\n"
#      set fluxsave 1
#      set cpt 0
#      for {set deltato 1} {$deltato<$d} {incr deltato} {
#         set valeurs [photom_methode1 $x $y $deltato]
#         set fluxs [lindex $valeurs 2]
#         if { $fluxs > 0 } {
#            set pourcent [expr abs(($fluxs - $fluxsave )/$fluxs*100)]
#            ::console::affiche_resultat "TAILLE=$deltato # FLUX : $fluxs # $pourcent %\n"
#            set fluxsave $fluxs
#         } else {
#            ::console::affiche_resultat "TAILLE=$deltato # FLUX : $fluxs \n"
#         }
#      }

   }

   ::console::affiche_resultat "ESTIM = $result_delta\n"
   
   return $result_delta

}



proc ::bddimages_cdl::mpc { valeurs } {

   set xam  [lindex $valeurs 0]
   set yam  [lindex $valeurs 1]
   set mag  [lindex $valeurs 2]
   set fwhm [lindex $valeurs 3]

   set radec [ buf[ ::confVisu::getBufNo $::audace(visuNo) ] xy2radec [ list $xam $yam ] ]
   set ra [ lindex $radec 0 ]
   set dec [ lindex $radec 1 ]
   set rah  [ mc_angle2hms $ra 360 zero 2 auto string ]
   set decd [ mc_angle2dms $dec 90 zero 2 + string ]

   ::console::affiche_resultat "RA DEC : ($ra $dec) ($rah $decd)\n"

   # 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
   #    Rab101    C2003 10 18.89848 01 33 53.74 +02 27 19.3          18.6        xxx
   #--- C2003 10 18.89848 : Indique la date du milieu de la pose pour l'image
   #--- (annee, mois, jour decimal --> qui permet d'avoir l'heure du milieu de la pose a la seconde pres)
   set mpc "$ra,$dec#     .        C"
   set demiexposure [ expr ( [ lindex [ buf[ ::confVisu::getBufNo $::audace(visuNo) ] getkwd EXPOSURE ] 1 ]+0. )/86400./2. ]
   set datecomp  [ mc_datescomp [ lindex [ buf[ ::confVisu::getBufNo $::audace(visuNo) ] getkwd DATE-OBS ] 1 ] + $demiexposure ]
   set mpc "[ format %15.7f $datecomp ],$ra,$dec,$fwhm,#     .        C"
   set d [mc_date2iso8601 $datecomp ]
   set annee [ string range $d 0 3 ]
   set mois  [ string range $d 5 6 ]
   set jour  [ string range $d 8 9 ]
   set h     [ string range $d 11 12 ]
   set m     [ string range $d 14 15 ]
   set s     [ string range $d 17 22 ]
   set hh    [ string trimleft $h 0 ] ; if { $hh == "" } { set hh "0" }
   set mm    [ string trimleft $m 0 ] ; if { $mm == "" } { set mm "0" }
   set ss    [ string trimleft $s 0 ] ; if { $ss == "" } { set ss "0" }
   set res   [ expr ($hh+$mm/60.+$ss/3600.)/24. ]
   set res   [ string range $res 1 6 ]
   append mpc "$annee $mois ${jour}${res} "
   set h     [ string range $rah 0 1 ]
   set m     [ string range $rah 3 4 ]
   set s     [ string range $rah 6 10 ]
   set s     [ string replace $s 2 2 . ]
   append mpc "$h $m $s "
   set d     [ string range $decd 0 2 ]
   set m     [ string range $decd 4 5 ]
   set s     [ string range $decd 7 10 ]
   set s     [ string replace $s 2 2 . ]
   append mpc "$d $m $s "
   append mpc "         "
   append mpc "[ format %04.1f $mag ]"
   set iau_code [ lindex [ buf[ ::confVisu::getBufNo $::audace(visuNo) ] getkwd IAU_CODE ] 1 ]
   if { $iau_code == "" } { set iau_code "xxx" }
   append mpc "        $iau_code"
   
   puts $::bddimages_cdl::fhandler_mpc $mpc
   #::console::affiche_resultat "$mpc\n"

}
