#--------------------------------------------------
# source [file join $audace(rep_install) gui audace plugin tool bddimages analyse_source.tcl]
#--------------------------------------------------
#
# Fichier        : analyse_source.tcl
# Description    : Utilitaires de communcation avec un flux (video ou lot d'image)
# Auteur         : Frederic Vachier
# Mise à jour $Id: analyse_source.tcl 6795 2011-02-26 16:05:27Z fredvachier $
#

namespace eval ::analyse_source {


   #
   # ::analyse_source::test
   # 
   #
   proc ::analyse_source::test { listsources } {

      global bddconf
   
      ::console::affiche_resultat "[lindex $listsources 0]  \n"

      set unesource [lindex [lindex $listsources 1] 10]
      ::console::affiche_resultat "$unesource \n"
      set ra  [lindex [lindex [lindex $unesource 0] 1] 0]
      set dec [lindex [lindex [lindex $unesource 0] 1] 1]
      set x [lindex [lindex [lindex $unesource 0] 2] 2]
      set y [lindex [lindex [lindex $unesource 0] 2] 3]
      set fwhm [lindex [lindex [lindex $unesource 0] 2] 24]
      ::console::affiche_resultat "X $x / Y $y / FWHM $fwhm\n"

      set source [list {"SOURCE" {} {} } [list [list [list "SOURCE" [list $ra $dec] {}]]]]
      affich_rond $source "SOURCE" "green" 1

      gren_info "[::confVisu::screen2Canvas  $bddconf(visuno) [list $x $y]]\n"
      gren_info "[::confVisu::canvas2Picture $bddconf(visuno) [list $x $y]]\n"

      affich_un_rond_xy $x $y "green" 5  4

      set results [ ::av4l_photom::photom_methode $x $y $fwhm $bddconf(bufno) ]
      set x2 [lindex $results 0]
      set y2 [lindex $results 1]
      ::console::affiche_resultat "X $x2 / Y $y2 \n"
      affich_un_rond_xy $x2 $y2 "blue" 5  2
      ::console::affiche_resultat "diff X [expr abs($x2-$x)] / Y [expr abs($y2-$y)] \n"

      gren_info "$results\n"
   }




   #
   # Get Astroid fields
   #    xsm         : Position x du photocentre (px)
   #    ysm         : Position y du photocentre (px)
   #    err_xsm     : Incertitude sur la position x du photocentre (px)
   #    err_ysm     : Incertitude sur la position y du photocentre (px)
   #    fwhmx       : FWHM le long de l'axe x (px)
   #    fwhmy       : FWHM le long de l'axe y (px) 
   #    fwhm        : FWHM totale (px)
   #    fluxintegre : Flux integre 
   #    errflux     : Incertitude sur le flux integre
   #    pixmax      : Valeur du pixel maximum
   #    intensite   : Valeur du pixel maximum - valeur du fond de ciel
   #    sigmafond   : sigma du fond de ciel
   #    snint       : Signal/bruit de l'intensite
   #    snpx        : Signal/bruit du pixel max (obsolete)
   #    delta       : Taille de la fenetre de calcul de la PSF
   #    rdiff       : Difference entre (x,y) pixel demande et (x,y) pixel obtenu par la PSF
   #    ra          : RA de la source (deg)
   #    dec         : DEC de la source (deg)
   #    res_ra      : Residu en RA (arcsec)
   #    res_dec     : Residu en DEC (arcsec)
   #    omc_ra      : O-C(RA) (arcsec)
   #    omc_dec     : O-C(DEC) (arcsec)
   #    mag         : Magnitude mesuree (mag)
   #    err_mag     : Incertitude sur la magnitude mesuree (mag)
   #    name        : Designation de la source
   #    flagastrom  : 'r'eference ou 's'cience ou '-'
   #    flagphotom  : 'r'eference ou 's'cience ou '-'
   #    cataastrom  : Nom du catalogue de reference astrometrique associe a la source
   #    cataphotom  : Nom du catalogue de reference photometrique associe a la source
   #
   proc ::analyse_source::get_fieldastroid { } {

      return [list "ASTROID" [list "ra" "dec" "poserr" "mag" "magerr"] \
                             [list "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux" \
                                   "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" \
                                   "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "mag" "err_mag" \
                                   "name" "flagastrom" "flagphotom" "cataastrom" "cataphotom"] ]

   }

#  0   xsm             "0"
#  1   ysm             "0"
#  2   err_xsm         "0"
#  3   err_ysm         "0"
#  4   fwhmx           "0"
#  5   fwhmy           "0"
#  6   fwhm            "0"
#  7   fluxintegre     "0"
#  8   errflux         "0"
#  9   pixmax          "0"
# 10   intensite       "0"
# 11   sigmafond       "0"
# 12   snint           "0"
# 13   snpx            "0"
# 14   delta           "0"
# 15   rdiff           "0"
# 16   ra              "0"
# 17   dec             "0"
# 18   res_ra          "0"
# 19   res_dec         "0"
# 20   omc_ra          "0"
# 21   omc_dec         "0"
# 22   mag             "0"
# 23   err_mag         "0"
# 24   name            "0"
# 25   flagastrom      "-"
# 26   flagphotom      "-"
# 27   cataastrom      "-"
# 28   cataphotom      "-"
   proc ::analyse_source::get_astroid_null { } {

      return [list "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "0" \
                   "-" \
                   "-" \
                   "-" \
                   "-" \
                   ]
   }








}
