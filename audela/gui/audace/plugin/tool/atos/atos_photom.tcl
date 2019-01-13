#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_photom.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_photom.tcl
# Description    : Effectue une mesure photometrique
# Auteur         : Frederic Vachier
# Mise à jour $Id: atos_photom.tcl 14424 2018-05-03 15:41:51Z fredvachier $
#


namespace eval ::atos_photom {

   variable rect_img
   variable rect_obj





   proc ::atos_photom::select_fullimg { visuNo this } {

      global color

      # Recuperation du Rectangle de l image
      set rect  [ ::confVisu::getBox $visuNo ]

      # Affichage de la taille de la fenetre
      if {$rect==""} {
         $this.v.r.fenetre configure -text "Error" -fg $color(red)
         set ::atos_photom::rect_img ""
      } else {
         set taillex [expr [lindex $rect 2] - [lindex $rect 0] ]
         set tailley [expr [lindex $rect 3] - [lindex $rect 1] ]
         $this.v.r.fenetre configure -text "${taillex}x${tailley}" -fg $color(blue)
         set ::atos_photom::rect_img $rect
      }
      get_fullimg $visuNo $this

   }









   proc ::atos_photom::select_obj { rect bufNo } {

      global color

      # Affichage de la taille de la fenetre
      if {$rect==""} {
         set ::atos_photom::pos_obj ""
      } else {

         set xsm [expr ([lindex $rect 0] + [lindex $rect 2]) / 2. ]
         set ysm [expr ([lindex $rect 1] + [lindex $rect 3]) / 2. ]
         set deltax [expr abs([lindex $rect 0] - [lindex $rect 2]) / 2.  ]
         set deltay [expr abs([lindex $rect 1] - [lindex $rect 3]) / 2.  ]
         if {$deltax < $deltay} {
            set delta $deltay
         } else {
            set delta $deltax
         }


         set xs0         [expr int($xsm - $delta)]
         set ys0         [expr int($ysm - $delta)]
         set xs1         [expr int($xsm + $delta)]
         set ys1         [expr int($ysm + $delta)]

         set valeurs     [buf$bufNo fitgauss [ list $xs0 $ys0 $xs1 $ys1 ] ]
         set xsm         [lindex $valeurs 1]
         set ysm         [lindex $valeurs 5]

      }

      return [list $xsm $ysm]
   }




   proc ::atos_photom::mesure_obj { xsm ysm delta bufNo } {

         set valeurs [::atos_photom::photom_methode $xsm $ysm $delta $bufNo]
         return $valeurs
   }



   proc ::atos_photom::get_obj { xsm ysm visuNo this } {

      #::console::affiche_resultat "rect_img = $::atos_photom::rect_obj \n"

      if {$::atos_photom::rect_obj==""} { 
         $this.v.r.int configure -text "?"
         $this.v.r.fwhm configure -text "?"
         $this.v.r.delta configure -text "?"
         $this.v.r.snb configure -text "?"

      } else {
         set bufNo [ ::confVisu::getBufNo $visuNo ]
       #  set stat [buf$bufNo stat $::atos_photom::rect_img]
        # $this.v.r.int configure -text [lindex $stat 3]
        # $this.v.r.fwhm configure -text [lindex $stat 2]
      }
   }





   proc ::atos_photom::photom_methode { xsm ysm delta bufNo} {

      global private

      set private(psf_toolbox,$::audace(visuNo),gui) 0

      if {$private(psf_toolbox,$::audace(visuNo),globale)} {
         set err [catch {::audace::PSF_globale $::audace(visuNo) $xsm $ysm} msg]
      } else {
         set err [catch {::audace::PSF_one_radius $::audace(visuNo) $xsm $ysm} msg]
      }

      if {$err} {
         gren_erreur "Erreur dans mesure de PSF (PSF ToolBox)\n"
         gren_erreur "Err= $err\n"
         gren_erreur "Msg= $msg\n"
      }

      set  xsm          $private(psf_toolbox,$::audace(visuNo),psf,xsm)
      set  ysm          $private(psf_toolbox,$::audace(visuNo),psf,ysm)
      set  fwhmx        $private(psf_toolbox,$::audace(visuNo),psf,fwhmx)
      set  fwhmy        $private(psf_toolbox,$::audace(visuNo),psf,fwhmy)
      set  fwhm         $private(psf_toolbox,$::audace(visuNo),psf,fwhm)
      set  fluxintegre  $private(psf_toolbox,$::audace(visuNo),psf,flux)
      set  errflux      $private(psf_toolbox,$::audace(visuNo),psf,err_flux)
      set  pixmax       $private(psf_toolbox,$::audace(visuNo),psf,pixmax)
      set  intensite    $private(psf_toolbox,$::audace(visuNo),psf,intensity)
      set  sigmafond    $private(psf_toolbox,$::audace(visuNo),psf,err_sky)
      set  snint        $private(psf_toolbox,$::audace(visuNo),psf,snint)
      set  delta        $private(psf_toolbox,$::audace(visuNo),psf,radius)

      if {$sigmafond != 0 && [string is double $sigmafond]} {
         set  snpx [expr $intensite / $sigmafond]
      } else {
         set snpx 0
         set sigmafond 0
      }
      
      return [ list $xsm $ysm $fwhmx $fwhmy $fwhm $fluxintegre $errflux $pixmax $intensite $sigmafond $snint $snpx $delta] 

   }


   proc ::atos_photom::photom_methode_obsolete { xsm ysm delta bufNo} {

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

      set xs0         [expr int($xsm - $delta)]
      set ys0         [expr int($ysm - $delta)]
      set xs1         [expr int($xsm + $delta)]
      set ys1         [expr int($ysm + $delta)]

      set r1          [expr int(1*$delta)]
      set r2          [expr int(1.25*$delta)]
      set r3          [expr int(1.75*$delta)]

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
      set nbpix       [lindex $valeurs 4]
      set errflux 0

      set valeurs     [buf$bufNo stat [list $xs0 $ys0 $xs1 $ys1] ]
      set pixmax      [lindex $valeurs 2]
      set intensite   [expr $pixmax - $fondmed]

      set snint       [expr $fluxintegre / sqrt ($fluxintegre +  $nbpix * $fondmoy)]
      set snpx        [expr $intensite / $sigmafond]

      #::console::affiche_erreur "M3 r1 r2 r3 flux sigma = $r1 $r2 $r3 $flux $sigma\n"

      #::console::affiche_resultat "flux int photom = $flux \n"
      #::console::affiche_resultat "photom : $xsm $ysm $fwhmx $fwhmy $fwhm $fluxintegre $errflux $pixmax $intensite $sigmafond $snint $snpx $delta\n"

      return [ list $xsm $ysm $fwhmx $fwhmy $fwhm $fluxintegre $errflux $pixmax $intensite $sigmafond $snint $snpx $delta] 
   }


}
