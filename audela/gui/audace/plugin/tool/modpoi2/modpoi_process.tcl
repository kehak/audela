#
# Fichier : modpoi_process.tcl
# Description : prodedure des calcul du pointage des etoiles
# Auteur : Michel Pujol
# Mise à jour $Id: modpoi_process.tcl 13696 2016-04-13 20:28:43Z michelpujol $
#

namespace eval ::modpoi2::process {

}

#-------------------------------------------------------------------------------
# computeCoefficient
# @private
# @param starList liste d'etoiles ( raadt decadt haDelta deDelta)
# @param home
# @param symbols
# @return ( vec chisq covar )
#-------------------------------------------------------------------------------
proc ::modpoi2::process::computeCoefficient { starList home symbols } {
   global audace
   variable private

   #--- creation de la matice
   set matrices [mc_compute_matrix_modpoi $starList EQUATORIAL $home $symbols { 0 1 2 3} ]
   set matX [lindex $matrices 0]
   set vecY [lindex $matrices 1]
   set vecW [lindex $matrices 2]

   #--- calcul des coefficients du modele
   set result [gsl_mfitmultilin $vecY $matX $vecW]

   return $result
}

#------------------------------------------------------------
# computeCoefficient1
#
# @private
#------------------------------------------------------------
proc ::modpoi2::process::computeCoefficient1 { {fileinp ""} } {
   global audace
   variable private

   #--- Ouvre la fenetre pour donner un nom au modele de pointage
   set err [catch {run_name_modpoi} msg]
   if {$err==1} {
      set private(filename) [file tail $fileinp]
   }

   #--- Analyse chaque ligne
   set vecY ""
   set matX ""
   set vecW ""
   set texte ""
   for {set k 1} {$k<=$private(stars,nb)} {incr k} {
      #--- Met en forme les valeurs
      set deltah [expr 60*[mc_anglescomp $private(star$k,ra_obs) - $private(star$k,ra_cal)]]
      set deltad [expr 60*[mc_anglescomp $private(star$k,dec_obs) - $private(star$k,de_cal)]]
      set dec $private(star$k,de_cal)
      set ha $private(star$k,ha_cal)
      set phi [lindex $private(home) 3]
      #--- Ajoute deux lignes à la matrice
      ::console::affiche_resultat "$deltah $deltad $dec $ha\n"
      set res [::modpoi2::process::addObs "$vecY" "$matX" "$vecW" $deltah $deltad $dec $ha $phi]
      set vecY [lindex $res 0]
      set matX [lindex $res 1]
      set vecW [lindex $res 2]
      #--- Dans un fichier
      append texte "$ha [mc_angle2deg $dec 90] $deltah $deltad\n"
   }
   #--- Cree un fichier de resultats o-c
   set output [ open [ file join $audace(rep_plugin) tool modpoi test_modpoi $private(filename)_inp.txt ] w ]
   puts -nonewline $output $texte
   close $output
   #--- Calcul des coefficients
   set res [gsl_mfitmultilin $vecY $matX $vecW]
   set output [ open [ file join $audace(rep_plugin) tool modpoi model_modpoi $private(filename).txt ] w ]
   puts -nonewline $output "$res $private(corrections,refraction)"
   close $output
   return $res
}

#------------------------------------------------------------
# testCoefficient
#   calcule les ecarts
# @private
#------------------------------------------------------------
proc ::modpoi2::process::testCoefficient { starList home vec { fileName ""} } {
   variable private

   #--- je recupere la latitude
   set phi [lindex $home 3]

   #--- Analyse chaque ligne
   set texte ""
   foreach star $starList  {
      set name    [lindex $star 0]
      set date    [lindex $star 1]
      set raadt   [lindex $star 2]
      set decadt  [lindex $star 3]
      set deltaha [lindex $star 4]
      set deltade [lindex $star 5]
      set haadt   [lindex $star 6]

      set vecY ""
      set matX ""
      set vecW ""
      #--- Ajoute deux lignes à la matrice
      set res  [::modpoi2::process::addObs "$vecY" "$matX" "$vecW" $deltaha $deltade $decadt $haadt $phi]
      set matX [lindex $res 1]
      #--- Calcul direct
      set res    [gsl_mmult $matX $vec]
      set dra_c  [lindex $res 0]
      set ddec_c [lindex $res 1]
      #--- Dans un fichier
      append texte "$haadt [mc_angle2deg $decadt 90] $deltaha $deltade $dra_c $ddec_c\n"
   }
   if { $fileName != ""} {
      #--- Cree un fichier de resultats o-c
      set input [ open [ file join $::audace(rep_plugin) tool modpoi test_modpoi $fileName_test.txt ] w ]
      puts -nonewline $input $texte
      close $input
   }
   return $texte
}

#------------------------------------------------------------
# addObs
#
# @private
#------------------------------------------------------------
proc ::modpoi2::process::addObs { vecY matX vecW deltah deltad dec h phi } {
   set tand   [expr tan([mc_angle2rad $dec]) ]
   set cosh   [expr cos([mc_angle2rad $h]) ]
   set sinh   [expr sin([mc_angle2rad $h]) ]
   set cosd   [expr cos([mc_angle2rad $dec]) ]
   set sind   [expr sin([mc_angle2rad $dec]) ]
   set secd   [expr 1./cos([mc_angle2rad $dec]) ]
   set sinphi [expr sin([mc_angle2rad $phi]) ]
   set cosphi [expr cos([mc_angle2rad $phi]) ]
   #---
   #--- dh
   set res ""
   lappend res 1                                              ; #--- IH
   lappend res 0                                              ; #--- ID
   lappend res $tand                                          ; #--- NP
   lappend res $secd                                          ; #--- CH
   lappend res [expr $sinh*$tand]                             ; #--- ME
   lappend res [expr -1.*$cosh*$tand]                         ; #--- MA
   lappend res 0                                              ; #--- FO  : Fork Flexure
   lappend res [expr -1.*$sinh*$secd]                         ; #--- MT  (=HF?) : Mount Flexure
   lappend res [expr -1.*$cosphi*$cosh-1.*$sinphi*$tand]      ; #--- DAF : Delta Axis Flexure
   lappend res [expr $cosphi*$sinh*$secd]                     ; #--- TF : Tube Flexure
   #---
   lappend matX $res
   lappend vecY $deltah
   lappend vecW 0.5
   #--- ddec
   set res ""
   lappend res 0                                              ; #--- IH
   lappend res 1                                              ; #--- ID
   lappend res 0                                              ; #--- NP
   lappend res 0                                              ; #--- CH
   lappend res $cosh                                          ; #--- ME
   lappend res $sinh                                          ; #--- MA
   lappend res $cosh                                          ; #--- FO : Fork Flexure
   lappend res 0                                              ; #--- MT(=HF?) : Mount Flexure
   lappend res 0                                              ; #--- DAF : Delta Axis Flexure
   lappend res [expr $cosphi*$cosh*$sind-$sinphi*$cosd]       ; #--- TF : Tube Flexure
   #---
   lappend matX $res
   lappend vecY $deltad
   lappend vecW [expr 1.+.00000005]
   #---
   return [list $vecY $matX $vecW]
}

#------------------------------------------------------------
# modpoi_catalogmean2apparent
#--- Input
#--- ra_cat,de_cat : coordinates J2000.0 (degrees)
#--- equinox  : equinox (example : J2000.0)
#--- date     : date en TU
#--- Output
#--- rav,decv : true coordinates (degrees)
#--- Hv  : true hour angle (degrees)
#--- hv  : true altitude altaz coordinate (degrees)
#--- azv : true azimut altaz coodinate (degrees)
# @private
#------------------------------------------------------------
proc ::modpoi2::process::modpoi_catalogmean2apparent { ra_cat de_cat equinox date { dra_dan "" } { ddec_dan "" } { epoch "" } } {
   variable private

   set pi $private(pi)
   set deg2rad $private(deg2rad)
   set rad2deg $private(rad2deg)
   #--- Aberration annuelle
   set radec [mc_aberrationradec annual [list $ra_cat $de_cat] $date ]
   #--- Correction de precession
   set radec [mc_precessradec $radec $equinox $date [list $dra_dan $ddec_dan $epoch]]
   #--- Correction de nutation
   set radec [mc_nutationradec $radec $date]
   #--- Aberration de l'aberration diurne
   set radec [mc_aberrationradec diurnal $radec $date $private(home)]
   #--- Calcul de l'angle horaire et de la hauteur vraie
   set rav   [lindex $radec 0]
   set decv  [lindex $radec 1]
   set dummy [mc_radec2altaz ${rav} ${decv} $private(home) $date]
   set azv   [lindex $dummy 0]
   set hv    [lindex $dummy 1]
   set Hv    [lindex $dummy 2]
   #--- Return
   return [list $rav $decv $Hv $hv $azv]
}

####------------------------------------------------------------
#### modpoi_apparent2observed
####
####------------------------------------------------------------
###proc ::modpoi2::process::modpoi_apparent2observed { listvdt { pressure 101325 } { temperature 290 } { date now } } {
####--- Input
####--- listvdt : true coodinates list from modpoi_catalogmean2apparent (degrees)
####--- Output
####--- raadt,decadt : observed coordinates (degrees)
####--- Hadt : observed hour angle (degrees)
####--- hadt : observed altitude altaz coordinate (degrees)
####--- azadt : observed azimut altaz coordinate (degrees)
###   variable private
###
###   set pi $private(pi)
###   set deg2rad $private(deg2rad)
###   set rad2deg $private(rad2deg)
###   #--- Extract angles from the listvd
###   set ravdt  [lindex $listvdt 0]
###   set decvdt [lindex $listvdt 1]
###   set Hvdt   [lindex $listvdt 2]
###   set hvdt   [lindex $listvdt 3]
###   set azvdt  [lindex $listvdt 4]
###   #--- Refraction correction
###   set azadt $azvdt
###   if {$hvdt>-1.} {
###      set refraction [mc_refraction $hvdt out2in $temperature $pressure]
###   } else {
###      set refraction 0.
###   }
###   set hadt   [expr $hvdt+$refraction]
###   set res    [mc_altaz2radec $azvdt $hadt $private(home) $date]
###   set raadt  [lindex $res 0]
###   set decadt [lindex $res 1]
###   set res    [mc_altaz2hadec $azvdt $hadt $private(home) $date]
###   set Hadt   [lindex $res 0]
###   return [list $raadt $decadt $Hadt $hadt $azadt]
###}

#------------------------------------------------------------
# computeCriticalChi2
#    Calcule le chi² critique pour un niveau de confiance
# Parameters : nb of stars, length of Symbols list, pConf
# @private
#------------------------------------------------------------
proc ::modpoi2::process::computeCriticalChi2 { nbValues nbParameters {pConf 0.95} } {

   set ddl [expr { 2*$nbValues-$nbParameters-1 }]
   return [gsl_cdf_chisq_Pinv $pConfiance $ddl]
}

#------------------------------------------------------------
# computePconf
#    Calcule le niveau de confiance (en %) d'un X² et l'intervalle en sigma
# Parameters : chisquare, nb of stars, length of Symbols list
# @private
#------------------------------------------------------------
proc ::modpoi2::process::computePconf { chisquare nbValues nbParameters } {

   #--   valeurs par defaut = confiance nulle
   set p "0 %"
   set kappa 0

   if {$chisquare ni [list 0 ""]} {
      set ddl [expr { 2*$nbValues-$nbParameters-1 }]
      set p [gsl_cdf_chisq_Q $chisquare $ddl]
      set Q [expr (1.-$p)/2.]
      set kappa [format "%0.2f" [gsl_cdf_ugaussian_Qinv $Q]]
      set p [format "%.2f" [expr { 100*$p }]]
      append p " %"
   }

   return [list $p $kappa]
}

