## @file tools_cdl.tcl
#  @brief     Fonctions d&eacute;di&eacute;es aux courbes photmom&eacute;triques
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages tools_cdl.tcl]
#  @endcode

# $Id: tools_cdl.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace tools_cdl
# @brief Fonctions d&eacute;di&eacute;es aux courbes photmom&eacute;triques
# @warning Outil en d&eacute;veloppement
#
namespace eval ::tools_cdl {

   variable id_current_image
   variable current_image
   variable current_cata
   variable current_image_name
   variable current_image_date
   variable current_image_jjdate
   variable img_list
   variable nb_img_list
   variable current_listsources
   variable tabphotom
   variable tabsource
   variable saturation
   variable movingobject 
   variable bestdelta  
   variable deltamin 
   variable deltamax 
   variable magref 
   variable starref 
   variable firstrefstar 

   variable uncosm
   variable uncosm_param1
   variable uncosm_param2

}



proc ::tools_cdl::select_obj { rect bufNo } {

   # Affichage de la taille de la fenetre
   if {$rect!=""} {

       set xsm [expr ([lindex $rect 0] + [lindex $rect 2]) / 2. ]
       set ysm [expr ([lindex $rect 1] + [lindex $rect 3]) / 2. ]
       set deltax [expr abs([lindex $rect 0] - [lindex $rect 2]) / 2.  ]
       set deltay [expr abs([lindex $rect 1] - [lindex $rect 3]) / 2.  ]
       if {$deltax < $deltay} {
          set delta $deltay
       } else {
          set delta $deltax
       }

      set valeurs  [::tools_cdl::photom_methode $xsm $ysm $delta $bufNo]
      set xsm      [lindex $valeurs 0]
      set ysm      [lindex $valeurs 1]

      return [list $xsm $ysm]
   }

   return false
}




proc ::tools_cdl::mesure_obj { xsm ysm delta bufNo } {

      set valeurs [::tools_cdl::photom_methode $xsm $ysm $delta $bufNo]
      return $valeurs
}




proc ::tools_cdl::photom_methode { xsm ysm delta bufNo} {

      set xs0         [expr int($xsm - $delta)]
      set ys0         [expr int($ysm - $delta)]
      set xs1         [expr int($xsm + $delta)]
      set ys1         [expr int($ysm + $delta)]

      set valeurs     [buf$bufNo fitgauss [ list $xs0 $ys0 $xs1 $ys1 ] ]
      set fwhmx       [lindex $valeurs 2]
      set fwhmy       [lindex $valeurs 6]
      set fwhm        [expr ($fwhmx + $fwhmy)/2.]
      set xsm         [lindex $valeurs 1]
      set ysm         [lindex $valeurs 5]
      set err_xsm     0.0
      set err_ysm     0.0

      set xs0         [expr int($xsm - $delta)]
      set ys0         [expr int($ysm - $delta)]
      set xs1         [expr int($xsm + $delta)]
      set ys1         [expr int($ysm + $delta)]

      set r1          [expr int(1*$delta)]
      set r2          [expr int(2*$delta)]
      set r3          [expr int(2.6*$delta)]

      if {0} {
         if {$r1<1} {set r1 1}
         if {$r2<$r1} {set r2 $r1}
         if {$r3<[expr $r2+1]} {set r3 [expr $r2+1]}
         gren_info "--- photom --- \n"
         gren_info "xs0  = $xs0 \n"
         gren_info "ys0  = $ys0 \n"
         gren_info "xs1  = $xs1 \n"
         gren_info "ys1  = $ys1 \n"
         gren_info "r1   = $r1  \n"
         gren_info "r2   = $r2  \n"
         gren_info "r3   = $r3  \n"
         gren_info "--- \n"
      }

      set err [ catch { set valeurs [buf$bufNo photom [list $xs0 $ys0 $xs1 $ys1] square $r1 $r2 $r3 ] } msg ]
      if {$err} {
         return -1
      }

      set fluxintegre [lindex $valeurs 0]
      set fondmed     [lindex $valeurs 1]
      set fondmoy     [lindex $valeurs 2]
      set sigmafond   [lindex $valeurs 3]
      set errflux 0
     
      set npix [expr ($xs1 - $xs0 + 1) * ($ys1 - $ys0 + 1)]

      set valeurs     [buf$bufNo stat [list $xs0 $ys0 $xs1 $ys1] ]
      set pixmax      [lindex $valeurs 2]
      set intensite   [expr $pixmax - $fondmed]

      set snint       [expr $fluxintegre / sqrt ( $fluxintegre + $npix * $fondmed )]
      set snpx        [expr $intensite / $sigmafond]

      return [ list $xsm $ysm $err_xsm $err_ysm $fwhmx $fwhmy $fwhm $fluxintegre $errflux $pixmax $intensite $sigmafond $snint $snpx $delta] 


      # Calcul du signal sur bruit : 
      # S/N = fluxintegre / sqrt (fluxintegre + npix ( sky + offset + readnoise^2) )
      # avec
      # npix = nombre de pixel dans la fenetre de calcul du flux
      # sky  = (par pixel) valeur mediane du fond du ciel r2<r<r3
      # offset = (par pixel) valeur mediane de l'offset
      # readnoise = single pixel noise (electron RMS)


}



proc ::tools_cdl::myuncosmic { bufNo } {

   ::tools_cdl::myuncosmic_2 $bufNo

}



proc ::tools_cdl::myuncosmic_2 { bufNo } {

   buf$bufNo save a
   set bf [buf::create]
   buf$bf load a
   buf$bf imaseries "FILTER kernel_width=3 kernel_type=med kernel_coef=[lindex $::tools_cdl::uncosm_param1 0]"
   buf$bf save b
   buf$bf load a
   buf$bf sub b 0
   buf$bf clipmin $::tools_cdl::uncosm_param2
   buf$bf clipmax [expr $::tools_cdl::uncosm_param2+1]
   buf$bf offset [expr -$::tools_cdl::uncosm_param2]
   buf$bf save dirac
   buf$bf load b
   buf$bf imaseries "PROD \"file=dirac\" constant=1"
   buf$bf save bb

   buf$bf load a
   buf$bf imaseries "PROD \"file=dirac\" constant=1"
   buf$bf save aa

   buf$bf load a
   buf$bf sub aa 0
   buf$bf add bb 0
   buf$bf copyto $bufNo
   buf::delete $bf 
   
   catch { file delete -force  aa.fit a.fit bb.fit b.fit dirac.fit }

}

proc ::tools_cdl::myuncosmic_1 { bufNo } {

   set bf    [buf::create]
   set b     [buf::create]
   set dirac [buf::create]

   buf$bufNo copyto $a
   buf$bufNo copyto $b
   buf$bufNo copyto $dirac

   buf$a save a

   set seuil_cosmic $::tools_cdl::uncosm_param1
   set seuil_bin $::tools_cdl::uncosm_param2

   # uncosmic standard sur le buffer b
   buf$b imaseries "FILTER kernel_width=3 kernel_type=med kernel_coef=[lindex $::tools_cdl::uncosm_param1 0]"
   buf$b save b

   # soustrait : A - B
   buf$dirac sub b 0

   buf$dirac clipmin $seuil_bin
   buf$dirac clipmax [expr $seuil_bin+1]
   set sb [expr $seuil_bin+0]
   set sh [expr $seuil_bin+1]
   #visu [list $sh $sb]
   buf$dirac offset [expr -$seuil_bin]
   buf$dirac save dirac

   buf$b imaseries "PROD \"file=dirac\" constant=1"
   saveima bb

   buf$a imaseries "PROD \"file=dirac\" constant=1"
   saveima aa

   loadima a
   sub aa 0
   add bb 0
   saveima final

}
