# Fonctions de calculs numeriques : interpolation, ajustement...
# source $audace(rep_scripts)/spcaudace/spc_numeric.tcl

# Mise a jour $Id: spc_numeric.tcl 14525 2018-11-09 18:22:10Z bmauclaire $


####################################################################
# Resolution de d'un polynôme de deg 3 par la méthode de Newton
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 6-04-2011
# Date modification : 6-04-2011
# Arguments : seconde_membre, a, b, c, d (a+bx+cx^2+dx^3=lambda)
####################################################################

proc spc_deg3sol { args } {
   global audace conf
   set precision 0.0001
   set nb_boucles 10000

   if { [ llength $args ]==5 } {
      set lambda [ lindex $args 0 ]
      set a [ lindex $args 1 ]
      set b [ lindex $args 2 ]
      set c [ lindex $args 3 ]
      set d [ lindex $args 4 ]

      #--- Execute la commande sur tous les fichiers fits du repertoire :
      for { set i 0 } { $i<$nb_boucles } { incr i } {
         if { $i==0 } { set x1 10000 } else { set x1 $x2 }
         set x2 [ expr $x1-($a-$lambda+$b*$x1+$c*pow($x1,2)+$d*pow($x1,3))/($b+2*$c*$x1+3*$d*pow($x1,2)) ]
         #- Meth point fixe :
         #set x2 [ expr $a-$lambda+($b-1.)*$x1+$c*pow($x1,2)+$d*pow($x1,3) ]
         if { [ expr abs($x2-$x1)/abs($x2) ]<=$precision } {
            ::console::affiche_resultat "La solution trouvée en $i itérations est $x2\n"
            return $x2
         } elseif { $x2>=1e+250 } {
            ::console::affiche_resultat "Solution infinie (supérieure à 1e+250)\n"
            break
         }
      }
      ::console::affiche_resultat "La solution trouvée au bout du maximum d'itérations est $x2\n"
      return $x2
   } else {
      ::console::affiche_erreur "Usage: spc_deg3sol lambda a b c d (a+bx+cx^2+dx^3=lambda)\n"
   }
}
#**********************************************************************************#



####################################################################
# Retourne la partie fractionnaire d'un nombre decimal
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20160421
# Date modification : 20160421
# Arguments : nombre
####################################################################

proc spc_fpart { args } {
   global audace conf
   if { [ llength $args ]==1 } {
      set lenombre [ lindex $args 0 ]

      set intpart [ expr int($lenombre) ]
      set fpart [ expr fmod($lenombre,$intpart) ]
      ::console::affiche_resultat "La partie fractionnaire vaut $fpart\n"
      return $fpart
   } else {
      ::console::affiche_erreur "Usage: spcfpart nombre_decimal\n"
   }
}
#**********************************************************************************#


####################################################################
# Bouclage d'une commande sur les tous les fichiers du repertoire de travail
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 12-12-2010
# Date modification : 12-12-2010
# Arguments : commande a exectuer sous forme de chaine de carcateres
# Exemple : bm_cmd "spc_ew4 %s 6530 6600 1000000 o"
####################################################################

proc bm_cmd { args } {
   global audace conf
   if { [ llength $args ]==1 } {
      set cmde [ lindex $args 0 ]

      #--- Execute la commande sur tous les fichiers fits du repertoire :
      ::console::affiche_prompt "\n**** DEBUT DE BOUCLE... ****\n\n"
      set listefichiers [ lsort -dictionary [ glob -dir $audace(rep_images) -tail *$conf(extension,defaut) ] ]
      foreach fichier $listefichiers {
         eval [ format $cmde "$fichier" ]
      }
      ::console::affiche_prompt "**** FIN DE BOUCLE. ****\n"
   } else {
      ::console::affiche_erreur "Usage: bm_cmd \"la commande audela a executer sur les fichiers notes %s\"\nExemple : bm_cmd \"spc_ew4 %s 6530 6600 1000000 o\"\n"
   }
}
#**********************************************************************************#



#############################################################################
# Procedure : retourne une liste echantillonnant une gaussienne, cette liste depend des arguments fournis
# arguments : liste abscisse, decalage, sigma, lambda du pic
#############################################################################
proc spc_gausslist { args } {
   if { [ llength $args ] == 4 } {
      set listlambda [ lindex $args 0 ]
      set decal [ lindex $args 1 ]
      set sigma [ lindex $args 2 ]
      set lpeak [ lindex $args 3 ]
      set intens [ list ]
      set pi [ expr 2. * asin (1.) ]
      set denom1 [ expr $sigma * sqrt (2. * $pi) ]
      set denom1 [ expr 1. / $denom1 ]
      set denom2 [ expr 2. * $sigma * $sigma ]
      set denom2 [ expr 1. / $denom2 ]
      foreach lambda $listlambda {
	 set lamb2 [ expr -1. *$denom2 * ($lambda-$lpeak + $decal)*($lambda-$lpeak + $decal) ]
	 set inten [ expr  $denom1* exp ( $lamb2 ) ]
	 lappend intens $inten
      }
      return $intens
   } else {
      ::console::affiche_erreur "Usage: spc_gausslist \{lambda_list\} sigma lambda_peak\n\n"
      return 0
   }
}
#***************************************************************************#


#############################################################################
# Auteur : Patrick LAILLY
# Date de création : 22-07-12
# Date de modification : 22-07-12
# cette procédure recherche les maxima d'un profil represente par un fichier .dat
# 3 arguments  d'entree obligatoires : le nom du fichier dat contenant les donnees mesurees, valeur_continuum, valeur_snr
# Les maxima detectes sont censes etre marques c-a-d que leur amplitude est au moins egale a $continuum * (1. + $coef_snr / $snr )
# Le nombre de maxima recherches est borne par la varible d'environnement nb_pics
# la procedure retourne une liste de listes donnant les abscisses des echantillons correspondant aux maxima ainsi que les ordonnees correspondantes. Cette liste est ordonnee par valeur decroissante de l'intensite des maximas.
# algo : adaptation de spc_maxsearch
# Exemple : spc_maxcorr fichier_dat valeur_continuum valeur_snr
#
#############################################################################

proc spc_maxcorr { args } {
   global audace spcaudace
   set nb_args [ llength $args ]
   if { $nb_args ==3 } {
      set nom_dat [ lindex $args 0 ]
      set continuum [ lindex $args 1 ]
      set snr [ lindex $args 2 ]
      set coef_snr $spcaudace(coef_snr)
      set nb_pics $spcaudace(nb_pics)
      #set nb_pics 50
      #set coef_snr 5.
      ::console::affiche_resultat " nb_pics $nb_pics \n"
      # lecture du fichier dat
      set input [open "$audace(rep_images)/$nom_dat" r]
      set contents [split [read $input] \n]
      close $input
      set nb_echant [llength $contents]
      set nb_echant_1 [ expr $nb_echant - 1 ]
      set periods [ list ]
      set density [ list ]
      for {set k 0} { $k < $nb_echant } {incr k} {
	 set ligne [lindex $contents $k]
	 set x [lindex $ligne 0]
	 set y [lindex $ligne 1]
	 lappend periods [lindex $ligne 0]
	 lappend density [lindex $ligne 1]
      }
      set cdelt1 [ expr [ lindex $periods 1] - [ lindex $periods 0 ] ]
      set crval1 [ lindex $periods 0 ]
      set nb_echant_periodo [ llength $density ]
      set nb_echant_periodo [ expr $nb_echant_periodo -1 ]
      set detected_max 0
      set liste_max [ list ]
      for {set k 1} { $k < $nb_echant_periodo } {incr k} {
	 set kk [ expr $nb_echant_periodo - $k ]
	 set kk_1 [ expr $kk - 1 ]
	 set deriv [ expr [ lindex $density $kk ] - [ lindex $density $kk_1 ] ]
	 set deriv_sign 1
	 if { $deriv < 0. } {
	    set deriv_sign -1
	 }
	 if { $k != 1 } {
	    if { $prev_sign == -1 && $deriv_sign == 1 } {
	       # recherche de la parabole passant par les 3 points encadrant le max
	       set lx [ list ]
	       set ly [ list ]
	       lappend lx [ lindex $periods $kk_1 ]
	       lappend lx [ lindex $periods $kk ]
	       lappend lx [ lindex $periods [ expr $kk +1 ] ]
	       lappend ly [ lindex $density $kk_1 ]
	       lappend ly [ lindex $density $kk ]
	       lappend ly [ lindex $density [ expr $kk +1 ] ]
	       # construction du systeme lineaire pour la recherche du maximum
	       set A [ list ]
	       for { set ii 0 } { $ii < 3 } { incr ii } {
		  set ligne [ list ]
		  for { set jj 0 } { $jj < 3 } { incr jj } {
		     lappend ligne [ expr pow([ lindex $lx $ii ],$jj) ]
		  }
		  lappend A $ligne
	       }
	       set lcoef [ gsl_msolvelin $A $ly ]
	       # max d ela parabole
	       lappend liste_max [ expr -.5 * [ lindex $lcoef 1 ] / [ lindex $lcoef 2 ] ]
	       set detected_max [ expr $detected_max +1 ]
	    }
	 }
	 set prev_sign $deriv_sign
      }

      # calcule de l'amplitude mininum des amximas
      set amplit_min [ expr $continuum * (1. + $coef_snr / $snr) ]
      # selection et mise en forme des maxima detectes
      set ldens [ list ]
      set lperiod [ list ]
      set nb_max [ llength $liste_max ]
      for {set k 0} { $k < $nb_max } {incr k} {
	 set kk [ expr $k + 1 ]
	 set period [ lindex $liste_max $k ]
	 # interpolationd ela  densite...............
	 set ikl  [ expr int( ( $period - $crval1 )/$cdelt1) ]
	 set densm [ lindex $density $ikl ]
	 set densp [ lindex $density [ expr $ikl +1 ] ]
	 set dens [ expr $densm + ($densp-$densm)*($period-$ikl) ]
	 if { $dens < $amplit_min } {
	    continue
	 }
	 lappend lperiod $period
	 lappend ldens $dens
      }
      set ord_dens [ lsort -decreasing -real $ldens ]
      set result [ list ]
      set nb_max [ llength $ord_dens ]
      for {set k 0} { $k < $nb_max } {incr k} {
	 set ligne [ list ]
	 set dens [ lindex $ord_dens $k ]
	 set kk [ lsearch -exact $ldens $dens ]
	 lappend ligne [ lindex $lperiod $kk ]
	 lappend ligne $dens
	 lappend result $ligne
      }
      set result [ lrange $result 0 [ expr $nb_pics -1 ] ]
      return $result
   } else {
      ::console::affiche_erreur "Usage: spc_maxcorr data_filename.dat fichier_dat valeur_continuum valeur_snr \n\n"
      return ""
   }
}




#############################################################################
# Auteur : Patrick LAILLY
# Date de création : 1-09-10
# Date de modification : 1-09-10
# cette procédure recherche les maxima les plus a droite d'une fonction representee par un fichier .dat
# 2 arguments  d'entree obligatoires : le nom du fichier dat contenant les donnees mesurees, nombre de maxima recherches
# la procedure retourne une liste donnant les abscisses des echantillons correspondant aux maxima. Cette liste est ordonnee par valeur decroissante de l'intensite des maximas.
# si la fonction varie rapidement dans sa partie droite, le resultat peut ne pas etre significatif et il convient d'appliquer prealablement un filtre coupe haut aux donnees supposees ici echantillonees regulierement.
# Exemple : spc_maxsearch periodogramme.dat 3
#
#############################################################################

proc spc_maxsearch { args } {
   global audace
   set nb_args [ llength $args ]
   if { $nb_args ==2 } {
      set nom_dat [ lindex $args 0 ]
      set nb_max [ lindex $args 1 ]
      # lecture du fichier dat
      set input [open "$audace(rep_images)/$nom_dat" r]
      set contents [split [read $input] \n]
      close $input
      set nb_echant [llength $contents]
      set nb_echant_1 [ expr $nb_echant - 1 ]
      set periods [ list ]
      set density [ list ]
      for {set k 0} { $k < $nb_echant } {incr k} {
	 set ligne [lindex $contents $k]
	 set x [lindex $ligne 0]
	 set y [lindex $ligne 1]
	 #::console::affiche_resultat " x= $x   y= $y \n"
	 lappend periods [lindex $ligne 0]
	 lappend density [lindex $ligne 1]
      }
      set nb_echant_periodo [ llength $density ]
      set nb_echant_periodo [ expr $nb_echant_periodo -1 ]
      set detected_max 0
      set liste_max [ list ]
      for {set k 1} { $k < $nb_echant_periodo } {incr k} {
	 set kk [ expr $nb_echant_periodo - $k ]
	 set kk_1 [ expr $kk - 1 ]
	 set deriv [ expr [ lindex $density $kk ] - [ lindex $density $kk_1 ] ]
	 set deriv_sign 1
	 if { $deriv < 0. } {
	    set deriv_sign -1
	 }
	 if { $k != 1 } {
	    if { $prev_sign == -1 && $deriv_sign == 1 } {
	       lappend liste_max $kk_1
	       set detected_max [ expr $detected_max +1 ]
	    }
	 }
	 set prev_sign $deriv_sign
	 if { $detected_max >= $nb_max } {
	    ::console::affiche_resultat " Le nombre de maxima  $detected_max trouves est inferieur au nombre demande \n"
	    break
	 }
      }
      if { $detected_max < $nb_max } {
	 ::console::affiche_resultat " Le nombre de maxima  $detected_max trouves est inferieur au nombre demande \n"
	 set nbmax $detected_max
	 }

      # mise en forme des maxima detectes
      set ldens [ list ]
      set lperiod [ list ]
      if { $nb_max > [ llength $liste_max ] } {
	 set nb_max [ llength $liste_max ]
      }
      for {set k 0} { $k < $nb_max } {incr k} {
	 set kk [ expr $k + 1 ]
	 set period [ lindex $periods [ lindex $liste_max $k ] ]
	 set dens [ lindex $density [ lindex $liste_max $k ] ]
	 #::console::affiche_resultat "Maximum N°$kk trouve ($dens) pour une periode de $period\n"
	 lappend lperiod $period
	 lappend ldens $dens
      }
      set ord_dens [ lsort -decreasing -real $ldens ]
      set ord_period [ list ]
      set ord_kk [ list ]
      for {set k 0} { $k < $nb_max } {incr k} {
	 set dens [ lindex $ord_dens $k ]
	 set kk [ lsearch -exact $ldens $dens ]
	 # ::console::affiche_resultat "Maximum N°[ expr $k+1 ] trouve pour une periode de [ lindex $lperiod $kk ] avec une valeur de $dens\n"
	 ::console::affiche_resultat "Maximum N°[ expr $k+1 ] : période valant [ lindex $lperiod $kk ] et d'intensité $dens\n"
	 lappend ord_kk $kk
	 lappend ord_period [ lindex $lperiod $kk ]
      }
      return $ord_period
   } else {
      ::console::affiche_erreur "Usage: spc_maxsearch data_filename.dat? nombre_max_recherches? \n\n"
      return ""
   }
}
#***************************************************************************#


#############################################################################
# Auteur : Patrick LAILLY
# Date de création : 1-09-10
# Date de modification : 1-09-10
# cette procédure analyse l'ajustement d'une fonction sinusoidale de periode donnes sur une quantite physique mesuree en fonction du temps calendaire : elle calcule la phase et l'amplitude donnant le meilleur ajustement.
# 3 arguments  d'entree obligatoires : le nom du fichier dat contenant les donnees mesurees, l'unite utilisee pour la
# mesure du temps calendaire, la periode de la fonction sinusoidale.
# la procedure retourne une liste constitue de l'amplitude et du decalage temporel caracterisant la sinusoide optimale et affiche le graphique illustrant l'ajustement des donnees par la fonction sinusoidale.  L'amplitude et le decalage temporel caracterisant la sinusoide optimale sont affiches a la console.
# Exemple : spc_sinefit data.dat "jours juliens" "vitesse radiale (m/s)" period
# reste a regler : pb lecture fichier dat
#############################################################################
proc spc_sinefit { args } {
   global audace
   if { [ llength $args ] ==4 } {
      set nom_dat [ lindex $args 0 ]
      set unit_temps  [ lindex $args 1 ]
      set measured_quantity [ lindex $args 2 ]
      set period  [ lindex $args 3 ]
      #lecture du fichier dat
      set input [open "$audace(rep_images)/$nom_dat" r]
      set contents [split [read $input] \n]
      close $input
      set nb_echant [llength $contents]
      # modification ad hoc : a comprendre !!!!!!!!!!!!!!!!!!!!!!!!
      set nb_echant [ expr $nb_echant -1 ]
      set nb_echant_1 [ expr $nb_echant - 1 ]
      #::console::affiche_resultat " donnees spc_sinefit : $nom_dat $unit_temps $period \n"
      set pi [ expr acos(-1.) ]
      set abscisses [ list ]
      set ordonnees_orig [ list ]
      for {set k 0} { $k < $nb_echant } {incr k} {
	 set ligne [lindex $contents $k]
	 set x [lindex $ligne 0]
	 set y [lindex $ligne 1]
	 #::console::affiche_resultat " x= $x   y= $y \n"
	 lappend abscisses [lindex $ligne 0]
	 lappend ordonnees_orig [lindex $ligne 1]
      }
      set temps_max [ expr [ lindex $abscisses $nb_echant_1 ] - [ lindex $abscisses 0 ] ]
      # elimination de la composante continue
      set dc 0.
      for {set k 0} { $k < $nb_echant } {incr k} {
	 set dc [ expr $dc + [ lindex $ordonnees_orig $k ] ]
      }
      set dc [ expr $dc / $nb_echant ]
      set ordonnees [ list ]
      for {set k 0} { $k < $nb_echant } {incr k} {
	 lappend ordonnees [ expr [ lindex $ordonnees_orig $k ] - $dc ]
      }
      # calcul de l'amplitude
      set omega [ expr 2. *$pi / $period ]
      set num 0.
      set den 0.
      for { set j 0 } { $j < $nb_echant } { incr j } {
	 set phase [ expr $omega * [ lindex $abscisses $j ] ]
	 set num [ expr $num + sin($phase) ]
	 set den [ expr $den + cos($phase) ]
      }
      set ratio [ expr $num / $den ]
      # solution 1
      set tau1 [ expr atan($ratio) ]
      set tau1 [ expr .5 * $tau1 / $omega ]
      set num 0.
      set den 0.
      for { set j 0 } { $j < $nb_echant } { incr j } {
	 set phase [ expr $omega * ( [ lindex $abscisses $j ] -$tau1 ) ]
	 set si [ expr sin($phase) ]
	 set num [ expr $num + [ lindex $ordonnees $j ] * $si ]
	 set den [ expr $den + $si * $si ]
      }
      set amplitude1 [ expr $num / $den ]
      #::console::affiche_resultat " estimated amplitude : $amplitude1 (Figure 2) \n"
      # solution 2
      set tau2 [ expr atan($ratio) + $pi ]
      set tau2 [ expr .5 * $tau2 / $omega ]
      set num 0.
      set den 0.
      for { set j 0 } { $j < $nb_echant } { incr j } {
	 set phase [ expr $omega * ( [ lindex $abscisses $j ] -$tau2 ) ]
	 set si [ expr sin($phase) ]
	 set num [ expr $num + [ lindex $ordonnees $j ] * $si ]
	 set den [ expr $den + $si * $si ]
      }
      set amplitude2 [ expr $num / $den ]
      # verification des estimations et elimination de la solution aberrante

      # evaluation du carre de la norme des ecarts synthetiques - mesures pour la solution 1
      set l21 0.
      for { set j 0 } { $j < $nb_echant } { incr j } {
	 set synth [ expr $dc + $amplitude1 * sin($omega * ( [ lindex $abscisses $j ] - $tau1) ) ]
	 set l21 [ expr $l21 + ( $synth - [ lindex $ordonnees_orig $j ] ) * ( $synth - [ lindex $ordonnees_orig $j ] ) ]
      }
      # evaluation du carre de la norme des ecarts synthetiques - mesures pour la solution 2
      set l22 0.
      for { set j 0 } { $j < $nb_echant } { incr j } {
	 set synth [ expr $dc + $amplitude2 * sin($omega * ( [ lindex $abscisses $j ] - $tau2) ) ]
	 set l22 [ expr $l22 + ( $synth - [ lindex $ordonnees_orig $j ] ) * ( $synth - [ lindex $ordonnees_orig $j ] ) ]
      }
      set tau $tau2
      set amplitude $amplitude2
      set rms $l22
      if { $l21 < $l22 } {
      set rms $l21
	 set tau $tau1
	 set amplitude $amplitude1
      }
      set dt [ expr $temps_max / 100. ]
      set ltemps [ list ]
      set lintens [ list ]
      set temps_deb [ lindex $abscisses 0 ]
      for { set k 0 } { $k <= 100 } { incr k } {
	 set temps [ expr $temps_deb + $k * $dt ]
	 lappend ltemps $temps
	 lappend lintens [ expr $dc + $amplitude * sin($omega * ( $temps - $tau) ) ]
      }
      ::plotxy::figure 1
      ::plotxy::plot $abscisses $ordonnees_orig *b
      ::plotxy::hold on
      ::plotxy::plot $ltemps $lintens r

      #::plotxy::plot $abscisses $newintens b 1
      ::plotxy::plotbackground #FFFFFF
      ::plotxy::xlabel "Time ($unit_temps)"
      ::plotxy::ylabel $measured_quantity
      ::plotxy::title "Fit of data $nom_dat on estimated sine function \n "
      # fin de la proc
      set time_shift $tau
      if { $amplitude < 0. } {
	 set time_shift [ expr $tau - .5 * $period ]
      }
      set phase [ expr  [ lindex $abscisses 0 ] - $time_shift ]
      set nbperiod [ expr int ($phase/$period) ]
      set phase [ expr ( $phase - $nbperiod * $period ) / $period ]
      set amplit [ expr .01 * round(100. * $amplitude) ]
      set phase [ expr .01 * round(100. * $phase) ]
      set period [ expr .01 * round(100. * $period) ]
      set dc [ expr .01 * round(100. * $dc) ]
      ::console::affiche_resultat "  Sinefit : RMS= $rms\n Estimated amplitude : [ expr abs($amplit) ]\n Phase : $phase\n Form of the fitting function:y(t)=$dc+$amplitude*sin(2pi*t/$period-$phase)\n"
      set liste_caract [ list ]
      lappend liste_caract $amplitude
      lappend liste_caract $tau
      return $liste_caract
   } else {
      ::console::affiche_erreur "Usage: spc_sinefit data_filename.dat time_unit measured_quantity period \n\n"
      return ""
   }
}
#***************************************************************************#



##########################################################
# Procedure de calcul de la valeur du polynome de calibration a un pixel donné
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 28-11-2009
# Date de mise à jour : 28-11-2009
# Arguments : pixelval crpix1 a b c d
# Exemples :
#  Coefs bon sens : spc_calpoly $k $crpix1 $spc_a $spc_b $spc_c $spc_d
#  Coefs lineaires: spc_calpoly $k $crpix1 $lambda0 $dispersion 0 0
#  Coefs inverses : spc_calpoly $k $crpix1 $spc_c $spc_b $spc_a 0
# Remarque : dans une boucle pour calculer tous les lambdas, les pixels commencent à 1.
#
##########################################################
# buf$audace(bufNo) setkwd [ list "CRPIX1" $crpix1 double "Reference pixel" "pixel" ]

proc spc_calpoly { args } {

   set nbargs [ llength $args ]
   if { $nbargs==6 } {
      set xval [lindex $args 0 ]
      set crpix1 [ lindex $args 1 ]
      set a [lindex $args 2 ]
      set b [lindex $args 3 ]
      set c [lindex $args 4 ]
      set d [lindex $args 5 ]

      return [ expr $a*1.0+$b*($xval-$crpix1)*1.0+$c*pow($xval-$crpix1,2)*1.0+$d*pow($xval-$crpix1,3)*1.0 ]
   } elseif { $nbargs==7 } {
      set xval [lindex $args 0 ]
      set crpix1 [ lindex $args 1 ]
      set a [lindex $args 2 ]
      set b [lindex $args 3 ]
      set c [lindex $args 4 ]
      set d [lindex $args 5 ]
      set e [lindex $args 6 ]

      return [ expr $a*1.0+$b*($xval-$crpix1)*1.0+$c*pow($xval-$crpix1,2)*1.0+$d*pow($xval-$crpix1,3)*1.0+$e*pow($xval-$crpix1,4)*1.0 ]
   } else {
      ::console::affiche_erreur "Usage : spc_calpoly pixelval crpix1 a b c d ?e?\n\n"
   }
}
#*********************************************************************#



##########################################################
# Procedure de division de nombres pris deux a deux dans deux listes
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 10-11-2009
# Date de mise à jour : 10-11-2009
# Arguments : liste de nombres 1, liste de nombres 2
##########################################################

proc spc_divlist { args } {

   if { [ llength $args ]==2 } {
      set numerateur [ lindex $args 0 ]
      set denominateur [lindex $args 1 ]

      set quotien [ list ]
      foreach ordo1 $numerateur ordo2 $denominateur {
         if { $ordo2 == 0.0 } {
            lappend quotien 0.0
         } else {
            lappend quotien [ expr 1.*$ordo1/$ordo2 ]
         }
      }
      return $quotien
   } else {
      ::console::affiche_erreur "Usage : spc_divlist \{liste valeurs du numerateur\} \{liste valeurs du denominateur\}\n\n"
   }
}
#*********************************************************************#



####################################################################
# Procédure de calcul de la valeur moyenne et de l'ecart-type d'une liste de nombres
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 08-10-2009
# Date modification : 08-10-2009
# Arguments : liste d'intensites
####################################################################

proc spc_statlist { args } {

   set nbargs [ llength $args ]
   if { $nbargs<=3 } {
      if { $nbargs==1 } {
         set intensites [ lindex $args 0 ]
         set xinf 0
         set xsup [ expr [ llength $intensites ]-1 ]
      } elseif { $nbargs==3 } {
         set intensites [ lindex $args 0 ]
         set xinf [ lindex $args 1 ]
         set xsup [ lindex $args 2 ]
      } else {
         ::console::affiche_erreur "Usage: spc_statlist liste_intensites ?x_inf x_sup?\n"
         return
      }

      #--- Decoupage de la plage de donnees :
      set intensites [ lrange $intensites $xinf $xsup ]
      set len [ llength $intensites ]

      #--- Calcul de la valeur moyenne :
      set imean 0.0
      for {set i 0} {$i<$len} {incr i} {
         set imean [ expr $imean+[ lindex $intensites $i ] ]
      }
      set imean [ expr $imean/$len ]

      #--- Calcul de l'ecart type non biaisé (http://fr.wikipedia.org/wiki/Écart_type) :
      set ecarttype 0.
      for {set i 0} {$i<$len} {incr i} {
         #set ecarttype [ expr $ecarttype+pow([ lindex $intensites $i ],2)-pow($imean,2) ]
         set ecarttype [ expr $ecarttype+pow([ lindex $intensites $i ]-$imean,2) ]
      }
      set ecarttype [ expr sqrt($ecarttype/($len-1)) ]

      #--- Affichage des résultats :
      set results [ list $imean $ecarttype ]
      #::console::affiche_resultat "Valeur moyenne $imean, ecart-type $ecarttype\n"
      return $results
   } else {
      ::console::affiche_erreur "Usage: spc_statlist liste_intensites ?x_inf x_sup?\n"
   }
}
#***************************************************************************#


####################################################################
# Procédure de calcul de la valeur moyenne du continuum d'une liste de nombre
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 18-03-2007
# Date modification : 07-10-2009
# Arguments : liste d'intensites
####################################################################

proc spc_icontilist { args } {
    global conf
    global audace
    set nbtranches 10
    #- demi-largeur d'etude en pixels :
    set dlargeur_etude 5

    if { [ llength $args ]==1 } {
       set intensites [ lindex $args 0 ]

       #--- Détermine les limites gauche et droite d'etude (valeurs != 0) :
       #- set limits [ spc_findnnul [ lindex [ spc_fits2data "$fichier" ] 1 ] ]
       #-- Initialisations :
       set len [ llength $intensites ]
       set i_inf 0
       set i_sup [ expr $len-1 ]
       #-- Recherche de i_inf :
       for {set i 0} {$i<$len} {incr i} {
          if { [ lindex $intensites $i ]>0 } {
             set i_inf $i
             break
          }
       }
       #-- Recherche de i_sup :
       for {set i [ expr $len-1 ]} {$i>=0} {incr i -1} {
          if { [ lindex $intensites $i ]>0 } {
             set i_sup $i
             break
          }
       }
       #::console::affiche_resultat "$i_inf, $i_sup\n"

       #-- Selelctionne la tranche d'intensites non nulles :
       #buf$audace(bufNo) window [ list [ lindex $limits 0 ] 1 [ lindex $limits 1 ] 1 ]
       set selectintensites [ lrange $intensites $i_inf $i_sup ]
       set naxis1 [ expr $i_sup-$i_inf+1 ]
       set largeur [ expr int($naxis1/$nbtranches) ]

       #--- Détermine l'intensité moyenne sur chaque tranches :
       set listresults ""
       #- i : compteur du numero de la tranche de largeur "largeur".
       for {set i 0} {$i<$nbtranches} {incr i} {
          if { $i==0 } {
             set zone [ list 0 [ expr $largeur-1 ] ]
          } else {
             set zone [ list [ expr $i*$largeur ] [ expr ($i+1)*$largeur ] ]
          }
          set result [ spc_statlist $selectintensites [ lindex $zone 0] [ lindex $zone 1 ] ]
          lappend listresults [ list [ lindex $result 0 ] [ lindex $result 1 ] ]
       }

       #--- Tri par ecart-type :
       set listresults [ lsort -increasing -real -index 1 $listresults ]
       set icontinuum [ lindex [ lindex $listresults 0 ] 0 ]

       #--- Affichage des résultats :
       ::console::affiche_resultat "Le continuum vaut $icontinuum\n"
       return $icontinuum
    } else {
        ::console::affiche_erreur "Usage: spc_icontilist liste_intensites\n"
    }
}
#***************************************************************************#



####################################################################
# Procedure déterminant les bornes (indice) inf et sup d'un ensemble de valeurs où elles sont différentes de 0
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 14-07-2007
# Date modification : 14-07-2007, 07-10-2009
# Algo : base sur l'aglo de spc_rmedges
# Arguments : liste valeurs
# Sortie : les indices inf et sup de la liste
####################################################################

proc spc_findnnul { args } {
    global conf
    global audace spcaudace

    set nbargs [ llength $args ]
    if { $nbargs==1 } {
       set intensites [ lindex $args 0 ]
       set frac_conti 0.85
    } elseif { $nbargs==2 } {
       set intensites [ lindex $args 0 ]
       set frac_conti [ lindex $args 1 ]
    } else {
       ::console::affiche_erreur "Usage : spc_findnnul liste_intensites ?fraction de continuum (0.85)?\n\n"
       return ""
    }

   #--- Chargement des paramètres du spectre :
   set conti_min [ expr $frac_conti*[ spc_icontilist $intensites ] ]
   set naxis1 [ llength $intensites ]
   set dnaxis1 [ expr int(0.5*$naxis1) ]
   set xgauche [ expr int($naxis1*$spcaudace(pourcent_bord_run)) ]
   set xdroite [ expr int($naxis1*(1.-$spcaudace(pourcent_bord_run))) ]


   #--- Détermine lambda_min et lambda_max :
   set xlistdeb1 0
   for { set i 1 } { $i<$xgauche } { incr i } {
      set intA [ lindex $intensites $i ]
      set intB [ lindex $intensites [ expr $i+4 ] ]
      set pente [ expr (abs($intB)-abs($intA))/4. ]
      #-- Teste si il y a une pente assez croissante :
      if { $pente >= $spcaudace(croissbord) } {
         #-- Gestion des pentes douces (met de la souplesse a spcaudace(croissbord)) :
         if { [ lindex $intensites [ expr $i+2 ] ] >= $conti_min } {
            set xlistdeb1 [ expr $i+2 ]
            break
         } elseif { [ lindex $intensites [ expr $i+3 ] ] >= $conti_min } {
            set xlistdeb1 [ expr $i+3 ]
            break
         }
      }
   }
   set xlistfin1 [ expr $naxis1-1 ]
   for { set i [ expr $naxis1-1 ] } { $i>$xdroite } { incr i -1 } {
      set intA [ lindex $intensites [ expr $i-4 ] ]
      set intB [ lindex $intensites $i ]
      set pente [ expr abs(abs($intA)-abs($intB))/4. ]
      #-- Teste si il y a une pente assez croissante :
      if { $pente >= $spcaudace(croissbord) } {
         #-- Gestion des pentes douces (met de la souplesse a spcaudace(croissbord)) :
         if { [ lindex $intensites [ expr $i-2 ] ] >= $conti_min } {
            set xlistfin1 [ expr $i-2 ]
            break
         } elseif { [ lindex $intensites [ expr $i-3 ] ] >= $conti_min }  {
            set xlistfin1 [ expr $i-3 ]
            break
         }
      }
   }

   #--- Seconde passe pour effacer les irréductibles échantillons vraiment nuls, sinon teste la validite des limites trouvees :
   #-- Bord gauche :
   set xlistdeb $xlistdeb1
   if { $xlistdeb1<=$xgauche } {
      for { set i $xlistdeb1 } { $i <= $dnaxis1 } { incr i } {
         if { [ lindex $intensites $i ] != 0.} {
            set xlistdeb $i
            break
         }
      }
   } else {
      for {set i 0} {$i<$dnaxis1} {incr i} {
         if { [ lindex $intensites $i ]>0 } {
            set xlistdeb $i
            break
         }
      }
      #- Si trop a l'interieur, calcul avec valeurs nulles, sinon prend la valeur 0 :
      if { $xlistdeb>$xgauche } {
         set xlistdeb 0
      }
   }
   #-- Bord droit :
   set xlistfin $xlistfin1
   if { $xlistfin1>=$xdroite } {
      for { set i $xlistdeb1 } { $i >= $dnaxis1 } { incr i -1 } {
         if { [ lindex $intensites $i ] != 0. } {
            set xlistfin $i
            break
         }
      }
   } else {
      for {set i [ expr $naxis1-1 ]} {$i>=$dnaxis1} {incr i -1} {
         if { [ lindex $intensites $i ]>0 } {
            set xlistfin $i
            break
         }
      }
      #- Si trop a l'interieur, calcul avec valeurs nulles, sinon prend la valeur naxis1-1 :
      if { $xlistfin<$xdroite } {
         set xlistfin [ expr $naxis1-1 ]
      }
   }

   #--- Verification que les echantillons extremes sont bien nuls :
   if { [ lindex $intensites 0 ]>0 } { set xlistdeb 0 }
   if { [ lindex $intensites [ expr $naxis1-1 ] ]>0 } { set xlistfin [ expr $naxis1-1 ] }

   #--- Exploitation des resultats :
   set results [ list $xlistdeb $xlistfin ]
   ::console::affiche_resultat "Les limites non nulles sont $xlistdeb ; $xlistfin\n"
   return $results
}
#***************************************************************************#




#############################################################################################
# Procedure de reechantillonage d'unn profil spectral decrit sous forme de listes
# Auteur : Patrick LAILLY
# Date de crÃ©ation : 12-12-08
# Date de modification : 25-08-12
# Cette procÃ©dure rÃ©Ã©chantillone, selon un pas d'echantillonage spÃ©cifiÃ© en Angstroems et
# commencant Ã  une longueur d'onde (variable crvalnew) spÃ©cifiÃ©ee en angstroems, un
# profil de raies (censÃ© Ãªtre calibrÃ© linÃ©airement) decrit via une liste de lambdas et une
# liste d'intensitÃ©s  et retourne un liste donnant la liste des lambdas et la liste des
# intensitÃ©s du profil ainsi rÃ©Ã©chantillonnÃ©. crvalnew est cense etre compris dans l'intervalle
# des lambdas donnÃ©s en argument.
# Il serait peut Ãªtre bon de prevoir des arguments optionnels pour le design du filtre dans le
# cas d'un sous-Ã©chantillonage
# Exemple
# spc_resample_start naxis1 list_lambdas list_intensites .001 crvalnew
##############################################################################################
proc spc_resample { args } {

   set nbargs [ llength $args ]
   if { $nbargs == 4 } {
      set abscisses [ lindex $args 0 ]
      set ordonnees [ lindex $args 1 ]
      set newsamplingrate [ lindex $args 2 ]
      set crvalnew [ lindex $args 3 ]
      set crpix1 1

      #--- Test calibration linéaire du profil entrée :
      set crval1 [ lindex $abscisses 0 ]
      set naxis1 [ llength $abscisses ]
      set naxis1_1 [ expr $naxis1 -1 ]
      set ecartlambda [ expr ( [ lindex $abscisses  $naxis1_1] -$crval1 ) ]
      set dlambda_glob [ expr  $ecartlambda / $naxis1_1  ]
      set dlambda_first [ expr ( [ lindex $abscisses  1] -$crval1 ) ]
      if { [ expr abs ( $dlambda_glob - $dlambda_first ) ] > .0000001 } {
         ::console::affiche_erreur "spc_resample : le profil entré n'est pas calibré linéairement et la mise en oeuvre de la procedure n'a pas de sens \n\n"
         return ""
      }


      #--- Test sur validite de crvalnew :
      if { [ lindex $abscisses  $naxis1_1] < $crvalnew || $crval1 > $crvalnew } {
         ::console::affiche_erreur " spc_resample : Le parametre crvalnew = $crvalnew n'est pas compris dans l'intervalle des lambdas donnees en argument \n\n"
         return ""
      }
      set cdelt1 $dlambda_glob
      set precision 0.05
      #set oversampling 2
      set lambdamax [ expr $crval1 + $ecartlambda ]
      #set lambdamin $crvalnew
      set ecartlambda [ expr $lambdamax -$crvalnew ]
      set newnaxis1 [ expr int ( $ecartlambda / $newsamplingrate ) + 1 ]
      ::console::affiche_resultat "Avant rééchantillonage : naxis1=$naxis1, cdelt1=$cdelt1, crval1=$crval1\n\# Après : naxis1=$newnaxis1, cdelt1=$newsamplingrate, crval1=$crvalnew\n"
      if { $cdelt1 > $newsamplingrate } {
         #--- Cas surééchantillonage :
         ::console::affiche_resultat "Surééchantillonage des données...\n"
         #-- Reechantillonage du fichier selon newsamplingrate :
         set lambda [ list ]
         set profile [ list ]
         set ndeb 0
         set ndebp1 [ expr $ndeb + 1 ]
         #- for { set i 1 } { $i<=$newnaxis1 } {incr i}
         for { set i 0 } { $i<$newnaxis1 } {incr i} {
            set lambdai [ expr $crvalnew + $i * $newsamplingrate ]
            #- set lambdai [ spc_calpoly $i $crpix1 $crvalnew $newsamplingrate 0 0 ]
            lappend lambda $lambdai
            while { $lambdai > [ expr $crval1 + $ndebp1 * $cdelt1] } {
            #- while { $lambdai > [ spc_calpoly $ndebp1 $crpix1 $crval1 $cdelt1 0 0 ] }
               incr ndebp1
               incr ndeb
            }
            #-- Interpolation lineaire entre les donnees associees a ndeb et ndebp1 :
            set lambdamoins [ lindex $abscisses $ndeb ]
            set lambdaplus [ lindex $abscisses $ndebp1 ]
            set intensmoins [ lindex $ordonnees $ndeb ]
            set intensplus [ lindex $ordonnees $ndebp1 ]
            set num  [ expr  ($intensplus - $intensmoins)*1. ]
            set den  [ expr ($lambdaplus - $lambdamoins)*1. ]
            set pente [ expr $num / $den ]
            set inten [ expr $intensmoins*1. + $pente * ( $lambdai - $lambdamoins ) ]
            #::console::affiche_resultat " ndeb= $ndeb lambda1= [ lindex $intensites_orig $ndeb ] lambda2= [ lindex $intensites_orig $ndebp1 ]\n"
            lappend profile $inten
         }
         ::console::affiche_resultat "Sortie echant_base \n"
         set result [ list ]
         lappend result $lambda
         lappend result $profile
         return $result
      } else {
         #--- Cas souseechantillonage :
         ::console::affiche_resultat "Sous échantillonage des données...\n"
         #-- Application d'un filtre adequat aux donnees
         #-- alpha est la proportion par rapport a la frequence de Nyquist
         set alpha 0.8
         set coupure [ expr int ( 2.*$newsamplingrate / ( $alpha *$cdelt1 ) ) ]
         set demilargeur [ expr int ($coupure / 2) +1 ]
         set filteredata [ spc_passebas_pat $ordonnees $demilargeur $coupure ]
         #-- Attention aux effets de bord !!!!!!!!!!!!!

         #-- Reechantillonage des donnees filtrees
         #-- Reechantillonage du fichier selon newsamplingrate
         set lambda [ list ]
         set profile [ list ]
         set ndeb 0
         set ndebp1 [ expr $ndeb + 1 ]
         #- for { set i 1 } { $i<=$newnaxis1 } {incr i}
         for { set i 0 } { $i<$newnaxis1 } {incr i} {
            set lambdai [ expr $crvalnew + $i * $newsamplingrate ]
            #- set lambdai [ spc_calpoly $i $crpix1 $crvalnew $newsamplingrate 0 0 ]
            lappend lambda $lambdai
            while { $lambdai > [ expr $crval1 + $ndebp1 * $cdelt1] } {
            #- while { $lambdai > [ spc_calpoly $ndebp1 $crpix1 $crval1 $cdelt1 0 0 ] }
               incr ndebp1
               incr ndeb
            }
            #-- Interpolation lineaire entre les donnees associees a ndeb et ndebp1
            set lambdamoins [ lindex $abscisses $ndeb ]
            set lambdaplus [ lindex $abscisses $ndebp1 ]
            set intensmoins [ lindex $filteredata $ndeb ]
            set intensplus [ lindex $filteredata $ndebp1 ]
            set num  [ expr  ($intensplus - $intensmoins)*1. ]
            set den  [ expr ($lambdaplus - $lambdamoins)*1. ]
            set pente [ expr $num / $den ]
            set inten [ expr $intensmoins*1. + $pente * ( $lambdai - $lambdamoins ) ]
            #- ::console::affiche_resultat " ndeb= $ndeb ndebp1= $ndebp1 ]\n"
            lappend profile $inten
         }
      }
      set result [ list ]
      lappend result $lambda
      lappend result $profile
      return $result
   } else {
      ::console::affiche_erreur "Usage: spc_resample list_lambdas_linéaires list_intensites newsamplingrate \n\n"
   }
}
#****************************************************************#



###################################################################
#  Procedure de determination du minimum entre 2 valeurs
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 01-06-08
# Date modification : 01-06-08
# Arguments : valeur 1, valeur 2
#####################################################################
proc bm_min { args } {

    if { [llength $args] == 2 } {
	set a [lindex $args 0]
	set b [lindex $args 1]

	if { $a>$b } {
	    return $b
	} else {
	    return $a
	}
    } else {
	::console::affiche_erreur "Usage: bm_min valeur_1 valeur_2\n\n"
    }
}
#****************************************************************#


####################################################################
#  Procedure de détermination du maximum entre 2 valeurs
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 11-12-2005
# Date modification : 11-12-2005
# Arguments : valeur 1, valeur 2
####################################################################
proc bm_max { args } {

    if { [llength $args] == 2 } {
	set a [lindex $args 0]
	set b [lindex $args 1]

	if { $a<$b } {
	    return $b
	} else {
	    return $a
	}
    } else {
	::console::affiche_erreur "Usage: bm_max valeur_1 valeur_2\n\n"
    }
}
#****************************************************************#

####################################################################
#  Procedure de détermination de la valeur maximum contenue dans une liste
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 11-12-2005
# Date modification : 11-12-2005
# Arguments : liste de valeurs
####################################################################
proc bm_lmax { args } {

    if { [llength $args] == 1 } {
	set liste [lindex $args 0]
	lsort $liste
	set len [llength $liste]
	return [lindex $liste $len]
    } else {
	::console::affiche_erreur "Usage: bm_lmax liste_valeurs\n\n"
    }
}
#****************************************************************#


####################################################################
# Calcul la partie fractionnelle d'un reel
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 19-09-2006
# Date modification : 19-06-2006
# Arguments : nombre
####################################################################
proc bm_frac { args } {

    if { [llength $args] == 1 } {
	set nombre [lindex $args 0]
	return [ expr $nombre-int($nombre) ]
    } else {
	::console::affiche_erreur "Usage: bm_frac nombre_reel\n\n"
    }
}
#****************************************************************#




####################################################################
# Calcul les coéfficients du polynôme interpolateur de Lagrange de degré 2
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-2005
# Arguments : 3 couples (x,y)
####################################################################

proc bm_pil2 { { x1 ""} { y1 ""} { x2 ""} { y2 ""} { x3 ""} { y3 ""} } {

    # Calcul les coefficients du polynôme interpolateur de Lagrange : lambda=a*x^2+b*x+c
    set a [expr $y1/(($x1-$x2)*($x1-$x2))+$y2/(($x2-$x1)*($x2-$x3))+$y3/(($x3-$x1)*($x3-$x2))]
    set b [expr -$y1*($x3+$x2)/(($x1-$x2)*($x1-$x2))-$y2*($x3+$x1)/(($x2-$x1)*($x2-$x3))-$y3*($x1+$x2)/(($x3-$x1)*($x3-$x2))]
    set c [expr $y1*$x3*$x2/(($x1-$x2)*($x1-$x2))+$y2*$x3*$x1/(($x2-$x1)*($x2-$x3))+$y3*$x1*$x2/(($x3-$x1)*($x3-$x2))]

    set listecoefs [list $a $b $c]
    return $listecoefs
}
#****************************************************************#


####################################################################
# Calcul la valeur du polynôme interpolateur de Lagrange de degré 3 au point x
# Auteur : Benjamin MAUCLAIRE
# Date creation : 25-02-2006
# Date modification : 25-02-2006
# Arguments : 4 couples (x,y) et x
####################################################################

proc bm_pil3c { { x0 ""} { y0 ""} { x1 ""} { y1 ""} { x2 ""} { y2 ""} { x3 ""} { y3 ""} { x ""}} {

    set y [ expr $y0*($x-$x1)*($x-$x2)*($x-$x3)/(($x0-$x1)*($x0-$x2)*($x0-$x3))+$y1*($x-$x0)*($x-$x2)*($x-$x3)/(($x1-$x0)*($x1-$x2)*($x1-$x3))+$y2*($x-$x0)*($x-$x1)*($x-$x3)/(($x2-$x0)*($x2-$x1)*($x2-$x3))+$y3*($x-$x0)*($x-$x1)*($x-$x2)/(($x3-$x0)*($x3-$x1)*($x3-$x2)) ]

    return $y
}
#****************************************************************#



####################################################################
# Procedure d'ajustement d'un nuage de points
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 15-12-2005
# Arguments : fichier .fit du profil de raie, erreur
####################################################################

proc spc_ajust { args } {
    global conf
    global audace

    if {[llength $args] == 2} {
	set filenamespc [ lindex $args 0 ]
	set erreur [ lindex $args 1 ]
	set contenu [spc_openspcfits $filenamespc]
	set abscisses [lindex $contenu 0]
	set ordonnees [lindex $contenu 1]
	set len [llength $ordonnees]

	#--- Calcul des coefficients du polynôme d'ajustement
	# - calcul de la matrice X
	set n [llength $abscisses]
	set x ""
	set X ""
	for {set i 0} {$i<$n} {incr i} {
	    set xi [lindex $abscisses $i]
	    set ligne_i 1
	    lappend erreurs $erreur
	    lappend ligne_i $xi
	    lappend ligne_i [expr $xi*$xi]
	    #lappend ligne_i [expr $xi*$xi*$xi]
	    lappend X $ligne_i
	}
	# - calcul de l'ajustement
	set result [gsl_mfitmultilin $ordonnees $X $erreurs]
	# - extrait le resultat
	set coeffs [lindex $result 0]
	set chi2 [lindex $result 1]
	set covar [lindex $result 2]

	set a [lindex $coeffs 0]
	set b [lindex $coeffs 1]
	set c [lindex $coeffs 2]
	#set d [lindex $coeffs 3]
	::console::affiche_resultat "Coefficients : $a+$b*x+$c*x^2\n"

	#--- Crée les vecteur à tracer
	blt::vector create x($len) y($len) yn($len)
	for {set i $len} {$i >= 1} {incr i -1} {
	    set x($i-1) [lindex $abscisses [expr $i-1]]
	    set y($i-1) [lindex $ordonnees [expr $i-1]]
	    set yn($i-1) [expr $a+$b*$x($i-1)+$c*$x($i-1)*$x($i-1)]
	    #set yn($i-1) [expr $a+$b*$x($i-1)+$c*$x($i-1)*$x($i-1)+$d*$x($i-1)*$x($i-1)*$x($i-1)]
	    #lappend yadj $yn($i-1)
	    lappend listeyn $yn($i-1)
	}
	#set yadj $listeyn

	#--- Remet les valeurs calculees de listeyn dans l'ordre des abscisses (inverse)
	for {set j 0} {$j<$len} {incr j} {
	    lappend yadj [ lindex $listeyn [expr $len-$j-1] ]
	}


	#--- Remet les valeurs calculees de listeyn dans l'ordre des abscisses (inverse)
	#set yadj ""
	#for {set j 0} {$j<$len} {incr j} {
	#    lappend yadj [ lindex $listeyn [expr $len-$j-1] ]
	#}
	##for {set j $len} {$j>0} {incr j -1} {
	##    lappend yadj [ lindex $listeyn [expr $j-$len-1] ]
	##}

	#--- Affichage du graphe
	#--- Meth1
	::plotxy::clf
	::plotxy::plot $abscisses $yadj r 1
	::plotxy::hold on
	::plotxy::plot $abscisses $ordonnees ob 0
	::plotxy::plotbackground #FFFFFF
	#::plotxy::xlabel "x"
	#::plotxy::ylabel "y"
	::plotxy::title "bleu : orginal ; rouge : interpolation deg 2"

	#--- Meth2
	set flaga 0
	if { $flaga == 1} {
	destroy .testblt
	toplevel .testblt
	blt::graph .testblt.g
	pack .testblt.g -in .testblt
	.testblt.g legend configure -position bottom
	set ly [lsort $yadj]
	#set ly [lsort $ordonnees]
	#set ymax [ bm_max [bm_lmax $ordonnees] [bm_lmax $yadj] ]
	.testblt.g axis configure x -min [lindex $abscisses 0] -max [lindex $abscisses $len]
	#.testblt.g axis configure y -min 1000 -max 5000
	##.testblt.g axis configure y -min 1000 -max [lindex $ly $len]
	.testblt.g axis configure y -min [lindex $ly 0] -max [lindex $ly $len]
	.testblt.g element create original -symbol none -x x -y y -color blue
	.testblt.g element create interpolation_deg2 -symbol none -x x -y yn -color red

	#--- Enregistrement des points du polynôme d'ajustement
	#set fileetalonnespc [ file rootname $filenamespc ]
	##set filename ${fileetalonnespc}_dat$extsp
	#set filename ${fileetalonnespc}$extsp
	#set file_id [open "$audace(rep_images)/$filename" w+]
	#for {set k 0} {$k<$naxis1} {incr k} {
	    #--- Ecrit les couples "Lambda Intensite" dans le fichier de sortie
	#    puts $file_id "$lambda\t$intensite"
	#}
	}
        blt::vector destroy x y yn
	set adj_vals [list $abscisses $yadj]
	return $adj_vals
    } else {
	::console::affiche_erreur "Usage: spc_ajust fichier_profil.fit erreur (1)\n\n"
    }
}
#****************************************************************#


####################################################################
#  Procedure de calibration en longueur d'onde par une loi lineaire a+b*x
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-05 / 09-12-05 / 26-12-05 / 11-11-09
# Arguments : crpix1 pixel1 lambda1 pixel2 lambda2
####################################################################

proc spc_ajustdeg1cal { args } {

  if { [llength $args]==3 } {
     set pixelRef [ lindex $args 0 ]
     set xvals [ lindex $args 1 ]
     set lambdas [ lindex $args 2 ]

     #--- Tri des raies par ordre coissant des abscisses :
     set coords [ list [ lindex $xvals 0 ] [ lindex $lambdas 0 ] [ lindex $xvals 1 ] [ lindex $lambdas 1 ] ]
     set couples [ list  ]
     set len 4
     for {set i 0} {$i<[expr $len-1]} { set i [ expr $i+2 ] } {
        lappend couples [ list [ lindex $coords $i ] [ lindex $coords [ expr $i+1 ] ] ]
     }
     set couples [ lsort -index 0 -increasing -real $couples ]

     #--- Réaffecte les couples pixels,lambda :
     set i 1
     foreach element $couples {
        set pixel$i [ lindex $element 0 ]
        set lambda$i [ lindex $element 1 ]
        incr i
     }

    #--- Calcul des parametres spectraux
    set deltax [expr 1.0*($pixel2-$pixel1)]
    set dispersion [expr 1.0*($lambda2-$lambda1)/$deltax]
    set lambdaRef [expr 1.0*($lambda1-$dispersion*($pixel1-$pixelRef))]
    #set lambdaRef [expr 1.0*($lambda1-$dispersion*($pixel1-$pixelRef)-$dispersion)]

    #--- Initialisation des mots clefs du fichier fits de sortie
    ::console::affiche_resultat "\nLoi de calibration : $lambdaRef+$dispersion*x\n"
    set results [ list $lambdaRef $dispersion ]
    return $results
  } else {
    ::console::affiche_erreur "Usage: spc_ajustdeg1cal pixel_reference liste_abscisses liste_ordonnees \n\n"
  }
}
#****************************************************************#



####################################################################
#  Procedure d'ajustement d'un nuage de points par une fonction affine (hp : nombre reels longs)
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 28-12-2008
# Arguments : liste abscisses, liste ordonnees, erreur
####################################################################
#spc_ajustdeg1 {218.67 127.32 16.67} {211 208 210.1} 1
#{218.67 127.32 16.67} {211.022333817 208.007561837 210.100127057}

proc spc_ajustdeg1hp { args } {
    global conf
    global audace

    set nbargs [llength $args]
    if { $nbargs==3 } {
       set abscisses_orig [lindex $args 0]
       set ordonnees [lindex $args 1]
       set erreur [lindex $args 2]
    } elseif { $nbargs==4 } {
       set abscisses_orig [lindex $args 0]
       set ordonnees [lindex $args 1]
       set erreur [lindex $args 2]
       set crpix1 [ lindex $args 3 ]
    } else {
	::console::affiche_erreur "Usage: spc_ajustdeg1hp liste_abscisses liste_ordonnees erreur (ex. 1) ?crpix1?\n\n"
       return ""
    }

    #--- Passage des absicsses avec une origine a 0 :
    if { $nbargs==4 } {
       set abscisses_new [ list ]
       foreach absi $abscisses_orig {
          lappend abscisses_new [ expr $absi-$crpix1 ]
       }
       set abscisses_orig $abscisses_new
    }


       #--- Initialisation de donnees :
       set len [llength $ordonnees]
       set n [ llength $abscisses_orig ]
       set abscisses_rangees [ lsort -real -increasing $abscisses_orig ]
       set abs_min [ lindex $abscisses_rangees 0 ]
       set abs_max [ lindex $abscisses_rangees [ expr $n -1 ] ]
       ::console::affiche_resultat "Xmin=$abs_min ; Xmax=$abs_max\n"

       #--- Changement de variable (preconditionnement du systeme lineaire) :
       set aa [ expr 2. / ($abs_max - $abs_min ) ]
       #::console::affiche_resultat "aa= $aa\n"
       set bb [ expr 1. - $aa * $abs_max ]
       #::console::affiche_resultat "bb= $bb\n"
       set abscisses [ list ]
       for { set i 0 } { $i<$n } {incr i} {
          set xi [ expr $aa * [ lindex $abscisses_orig $i ] +$bb ]
          lappend abscisses $xi
       }

	#--- Calcul des coefficients du polynôme d'ajustement
	# - calcul de la matrice X
	set n [llength $abscisses]
	set x ""
	set X ""
	for {set i 0} {$i<$n} {incr i} {
	    set xi [lindex $abscisses $i]
	    set ligne_i 1
	    lappend erreurs $erreur
	    lappend ligne_i $xi
	    lappend X $ligne_i
	}
	# - calcul de l'ajustement
	set result [ gsl_mfitmultilin $ordonnees $X $erreurs ]
	# - extrait le resultat
	set coeffs [lindex $result 0]
	set chi2 [lindex $result 1]
	set covar [lindex $result 2]

	set a0 [lindex $coeffs 0]
	set b0 [lindex $coeffs 1]
        #--- Retour aux variables d'origine :
        set a [ expr $a0 + $b0 * $bb ]
        set b [ expr $aa * $b0 ]
	::console::affiche_resultat "Coefficients : $a+$b*x \nChi2=$chi2, Covar=$covar\n"

	set coefs [ list $a $b ]
	# set adj_vals [list $coefs $abscisses $yadj]
	set adj_vals [ list $coefs $chi2 $covar ]
	#set adj_vals [ list $coefs ]
	return $adj_vals
}
#****************************************************************#



####################################################################
#  Procedure d'ajustement d'un nuage de points par une fonction affine
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 01-10-2006
# Arguments : liste abscisses, liste ordonnees, erreur
# Exemple :
# spc_ajustdeg1 {218.67 127.32 16.67} {211 208 210.1} 1
#  {209.259939 0.003640} 209.259939+0.003640*x
#  4.46881729484 {  { 1.047442 -0.005907 }  { -0.005907 0.000049 }  }
# spc_ajustdeg1 {218.67 127.32 16.67} {211 208 210.1} 1 1
#  Coefficients : 209.263579+0.003640*x
###################################################################

proc spc_ajustdeg1 { args } {
    global conf
    global audace

    set nbargs [llength $args]
    if { $nbargs==3 } {
       set abscisses [lindex $args 0]
       set ordonnees [lindex $args 1]
       set erreur [lindex $args 2]
    } elseif { $nbargs==4 } {
       set abscisses [lindex $args 0]
       set ordonnees [lindex $args 1]
       set erreur [lindex $args 2]
       set crpix1 [ lindex $args 3 ]
    } else {
	::console::affiche_erreur "Usage: spc_ajustdeg1 liste_abscisses liste_ordonnees erreur (ex. 1) ?crpix1?\n\n"
       return ""
    }

       #--- Passage des absicsses avec une origine a 0 :
       if { $nbargs==4 } {
          set abscisses_new [ list ]
          foreach absi $abscisses {
             lappend abscisses_new [ expr $absi-$crpix1 ]
          }
          set abscisses $abscisses_new
       }


	#--- Calcul des coefficients du polynôme d'ajustement
	# - calcul de la matrice X
	set n [llength $abscisses]
	set x ""
	set X ""
	for {set i 0} {$i<$n} {incr i} {
	    set xi [lindex $abscisses $i]
	    set ligne_i 1
	    lappend erreurs $erreur
	    lappend ligne_i $xi
	    lappend X $ligne_i
	}
	# - calcul de l'ajustement
	set result [ gsl_mfitmultilin $ordonnees $X $erreurs ]
	# - extrait le resultat
	set coeffs [lindex $result 0]
	set chi2 [lindex $result 1]
	set covar [lindex $result 2]

	set a [lindex $coeffs 0]
	set b [lindex $coeffs 1]
	::console::affiche_resultat "Coefficients : $a+$b*x\nChi2=$chi2, Covar=$covar\n"

	set coefs [ list $a $b ]
	# set adj_vals [list $coefs $abscisses $yadj]
	set adj_vals [ list $coefs $chi2 $covar ]
	#set adj_vals [ list $coefs ]
	return $adj_vals
}
#****************************************************************#


####################################################################
#  Procedure d'ajustement d'un nuage de points par un polynôme de degré 2
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 26-05-2005/14-09-2008-Lailly
# Arguments : liste abscisses, liste ordonnees, erreur
####################################################################
#spc_ajustdeg2 {218.67 127.32 16.67} {211 208 210.1} 1
#{218.67 127.32 16.67} {211.022333817 208.007561837 210.100127057}

proc spc_ajustdeg2 { args } {
   global conf
   global audace

   set nbargs [ llength $args ]
   if { $nbargs==3 } {
      set abscisses_orig [ lindex $args 0 ]
      set ordonnees [ lindex $args 1 ]
      set erreur [ lindex $args 2 ]
   } elseif { $nbargs==4 } {
      set abscisses_orig [ lindex $args 0 ]
      set ordonnees [ lindex $args 1 ]
      set erreur [ lindex $args 2 ]
      set crpix1 [ lindex $args 3 ]
   } else {
      ::console::affiche_erreur "Usage: spc_ajustdeg2 liste_abscisses liste_ordonnees erreur (ex. 1) ?crpix1?\n\n"
      return ""
   }

   #--- Passage des absicsses avec une origine a 0 :
   if { $nbargs==4 } {
      set abscisses_new [ list ]
      foreach absi $abscisses_orig {
         lappend abscisses_new [ expr $absi-$crpix1 ]
      }
      set abscisses_orig $abscisses_new
   }

   #--- Initialisation de variables :
   set len [llength $ordonnees]
   set n [llength $abscisses_orig]
   set abscisses_rangees [ lsort -real -increasing $abscisses_orig ]
   set abs_min [ lindex $abscisses_rangees 0 ]
   set abs_max [ lindex $abscisses_rangees [ expr $n -1 ] ]
   ## ::console::affiche_resultat "$abs_min $abs_max\n"

   #--- Changement de variable (preconditionnement du systeme lineaire pour libgsl) :
   set aa [ expr 2. / ($abs_max - $abs_min ) ]
   ## ::console::affiche_resultat "aa= $aa\n"
   set bb [ expr 1. - $aa * $abs_max ]
   ## ::console::affiche_resultat "bb= $bb\n"
   set abscisses [ list ]
   for { set i 0 } { $i<$n } {incr i} {
      set xi [ expr $aa * [ lindex $abscisses_orig $i ] +$bb ]
      lappend abscisses $xi
   }


   #--- Calcul des coefficients du polynôme d'ajustement :
   #-- Calcul de la matrice X :
   set n [ llength $abscisses ]
   set x ""
   set X ""
   for {set i 0} {$i<$n} {incr i} {
      set xi [lindex $abscisses $i]
      set ligne_i 1
      lappend erreurs $erreur
      lappend ligne_i $xi
      lappend ligne_i [expr $xi*$xi]
      #lappend ligne_i [expr $xi*$xi*$xi]
      lappend X $ligne_i
   }
   #-- Calcul de l'ajustement :
   set result [ gsl_mfitmultilin $ordonnees $X $erreurs ]
   #-- Extrait le resultat :
   set coeffs [lindex $result 0]
   set chi2 [lindex $result 1]
   set covar [lindex $result 2]
   ::console::affiche_resultat "Chi2=$chi2, Covar=$covar\n"
   set a0 [lindex $coeffs 0]
   set b0 [lindex $coeffs 1]
   set c0 [lindex $coeffs 2]

   #--- Retour aux variables d'origine :
   set a [ expr $a0 + $b0 * $bb + $c0 * $bb* $bb ]
   set b [ expr $aa * ( $b0 + 2. * $c0 * $bb ) ]
   set c [ expr $aa * $aa * $c0 ]
   ::console::affiche_resultat "Coefficients : $a+$b*x+$c*x^2\n"
   set coefs [ list $a $b $c ]

   #--- Retour a des abscisses d'origine crpix1 : ERRONE LE RESULTAT
   if { 1==0 } {
      set an [ expr $a+$b*$crpix1+$c*pow($crpix1,2) ]
      set bn [ expr $b+2*$c*$crpix1 ]
      set a $an
      set b $bn
   }


   #-----------------------------------------------------------------------#
   #--- Crée les vecteur à tracer
   set flag 0
   if { $flag==1 } {
      blt::vector create x($len) y($len) yn($len)
      for {set i $len} {$i > 0} {incr i -1} {
         set x($i-1) [lindex $abscisses [expr $i-1]]
         set y($i-1) [lindex $ordonnees [expr $i-1]]
         set yn($i-1) [expr $a+$b*$x($i-1)+$c*$x($i-1)*$x($i-1)]
         #set yn($i-1) [expr $a+$b*$x($i-1)+$c*$x($i-1)*$x($i-1)+$d*$x($i-1)*$x($i-1)*$x($i-1)]
         #lappend yadj $yn($i-1)
         lappend listeyn $yn($i-1)
      }
      #set yadj $listeyn

      #--- Remet les valeurs calculees de listeyn dans l'ordre des abscisses (inverse)
      for {set j 0} {$j<$len} {incr j} {
         lappend yadj [ lindex $listeyn [expr $len-$j-1] ]
      }
      blt::vector destroy x y yn
   }
   #-----------------------------------------------------------------------#

   #--- Remet les valeurs calculees de listeyn dans l'ordre des abscisses (inverse)
   #set yadj ""
   #for {set j 0} {$j<$len} {incr j} {
   #    lappend yadj [ lindex $listeyn [expr $len-$j-1] ]
   #}
   ##for {set j $len} {$j>0} {incr j -1} {
   ##    lappend yadj [ lindex $listeyn [expr $j-$len-1] ]
   ##}


   #--- Affichage du graphe
   #  ::plotxy::plot $abscisses $yadj

   set coefs [ list $a $b $c ]
   # set adj_vals [list $coefs $abscisses $yadj]
   set adj_vals [ list $coefs $chi2 $covar ]
   #set adj_vals [ list $coefs ]
   return $adj_vals
}
#****************************************************************#



####################################################################
#  Procedure d'ajustement d'un nuage de points par un polynôme de degré 3
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 26-05-2005/14-09-2008-Lailly
# Arguments : liste abscisses, liste ordonnees, erreur
# Condition : il faut 4 couples de points !
####################################################################
#spc_ajustdeg3 {218.67 127.32 16.67} {211 208 210.1} 1
#{218.67 127.32 16.67} {211.022333817 208.007561837 210.100127057}

proc spc_ajustdeg3 { args } {
   global conf
   global audace

   set nbargs [ llength $args ]
   if { $nbargs==3} {
      set abscisses_orig [lindex $args 0]
      set ordonnees [lindex $args 1]
      set erreur [lindex $args 2]
   } elseif { $nbargs==4 } {
      set abscisses_orig [ lindex $args 0 ]
      set ordonnees [ lindex $args 1 ]
      set erreur [ lindex $args 2 ]
      set crpix1 [ lindex $args 3 ]
   } else {
      ::console::affiche_erreur "Usage: spc_ajustdeg3 liste_abscisses liste_ordonnees erreur (ex. 1) ?crpix1?\n\n"
      return ""
   }

   #--- Passage des absicsses avec une origine a 0 :
   if { $nbargs==4 } {
      set abscisses_new [ list ]
      foreach absi $abscisses_orig {
         lappend abscisses_new [ expr $absi-$crpix1 ]
      }
      set abscisses_orig $abscisses_new
   }


      #--- Initialisation de variables :
      set n [llength $abscisses_orig]
      set len [llength $ordonnees]
      set abscisses_rangees [ lsort -real -increasing $abscisses_orig ]
      set abs_min [ lindex $abscisses_rangees 0 ]
      set abs_max [ lindex $abscisses_rangees [ expr $n -1 ] ]
      ::console::affiche_resultat "$abs_min $abs_max\n"

      #--- Changement de variable (preconditionnement du systeme lineaire) :
      set aa [ expr 2. / ($abs_max - $abs_min ) ]
      #::console::affiche_resultat "aa= $aa\n"
      set bb [ expr 1. - $aa * $abs_max ]
      #::console::affiche_resultat "bb= $bb\n"
      set abscisses [ list ]
      for { set i 0 } { $i<$n } {incr i} {
	 set xi [ expr $aa * [ lindex $abscisses_orig $i ] +$bb ]
	 lappend abscisses $xi
      }

      #--- Calcul des coefficients du polynôme d'ajustement :
      #-- Calcul de la matrice X : calcul les monônes correspondant aux différents degrés à l'abscisse xi
      set x ""
      set X ""
      for {set i 0} {$i<$n} {incr i} {
	 set xi [lindex $abscisses $i]
         set ligne_i 1
	 lappend erreurs $erreur
	 lappend ligne_i $xi
	 lappend ligne_i [expr $xi*$xi]
	 lappend ligne_i [expr $xi*$xi*$xi]
	 lappend X $ligne_i
      }
      #-- Calcul de l'ajustement :
      set result [gsl_mfitmultilin $ordonnees $X $erreurs]
      #-- Extrait le resultat :
      set coeffs [lindex $result 0]
      set chi2 [lindex $result 1]
      set covar [lindex $result 2]
      set a0 [lindex $coeffs 0]
      set b0 [lindex $coeffs 1]
      set c0 [lindex $coeffs 2]
      set d0 [lindex $coeffs 3]
      ::console::affiche_resultat "Chi2=$chi2, Covar=$covar\n"

      #--- Retour aux variables d'origine :
      set a [ expr $a0 + $b0 * $bb + $c0 * $bb* $bb + $d0 * $bb* $bb * $bb ]
      set b [ expr $aa * ( $b0 + 2. * $c0 * $bb + 3. * $d0 * $bb *$bb ) ]
      set c [ expr $aa * $aa * ($c0 + 3. * $d0 * $bb) ]
      set d [ expr $d0 * $aa * $aa *$aa ]

      #--- Retour a des abscisses d'origine crpix1 : ERRONE LE RESULTAT
      if { 0==1 } {
         set an [ expr $a+$b*$crpix1+$c*pow($crpix1,2)+$d*pow($crpix1,3) ]
         set bn [ expr $b+2*$c*$crpix1+3*$d*pow($crpix1,2) ]
         set cn [ expr $c+3*$d*$crpix1 ]
         set a $an
         set b $bn
         set c $cn
      }

      ::console::affiche_resultat "Coefficients B : $a+$b*x+$c*x^2+$d*x^3\n"
      set coefs [ list $a $b $c $d ]
      # set adj_vals [list $coefs $abscisses $yadj]
      set adj_vals [ list $coefs $chi2 $covar ]
      #set adj_vals [ list $coefs ]
      return $adj_vals
}
#****************************************************************#



####################################################################
#  Procedure d'ajustement d'un nuage de points par un polynôme de degré 2
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 26-05-2005
# Arguments : liste abscisses, liste ordonnees, erreur
####################################################################
#spc_ajustdeg2 {218.67 127.32 16.67} {211 208 210.1} 1
#{218.67 127.32 16.67} {211.022333817 208.007561837 210.100127057}

proc spc_ajustdeg2v1 { args } {
    global conf
    global audace

    if {[llength $args] == 3} {
	set abscisses [lindex $args 0]
	set ordonnees [lindex $args 1]
	set erreur [lindex $args 2]
	set len [llength $ordonnees]

	#--- Calcul des coefficients du polynôme d'ajustement
	# - calcul de la matrice X
	set n [llength $abscisses]
	set x ""
	set X ""
	for {set i 0} {$i<$n} {incr i} {
	    set xi [lindex $abscisses $i]
	    set ligne_i 1
	    lappend erreurs $erreur
	    lappend ligne_i $xi
	    lappend ligne_i [expr $xi*$xi]
	    #lappend ligne_i [expr $xi*$xi*$xi]
	    lappend X $ligne_i
	}
	# - calcul de l'ajustement
	set result [ gsl_mfitmultilin $ordonnees $X $erreurs ]
	# - extrait le resultat
	set coeffs [lindex $result 0]
	set chi2 [lindex $result 1]
	set covar [lindex $result 2]

	set a [lindex $coeffs 0]
	set b [lindex $coeffs 1]
	set c [lindex $coeffs 2]
	#set d [lindex $coeffs 3]
	::console::affiche_resultat "Coefficients : $a+$b*x+$c*x^2\nChi2=$chi2\n"

     #-----------------------------------------------------------------------#
	#--- Crée les vecteur à tracer
	set flag 0
	if { $flag==1 } {
	blt::vector create x($len) y($len) yn($len)
	for {set i $len} {$i > 0} {incr i -1} {
	    set x($i-1) [lindex $abscisses [expr $i-1]]
	    set y($i-1) [lindex $ordonnees [expr $i-1]]
	    set yn($i-1) [expr $a+$b*$x($i-1)+$c*$x($i-1)*$x($i-1)]
	    #set yn($i-1) [expr $a+$b*$x($i-1)+$c*$x($i-1)*$x($i-1)+$d*$x($i-1)*$x($i-1)*$x($i-1)]
	    #lappend yadj $yn($i-1)
	    lappend listeyn $yn($i-1)
	}
	#set yadj $listeyn

	#--- Remet les valeurs calculees de listeyn dans l'ordre des abscisses (inverse)
	for {set j 0} {$j<$len} {incr j} {
	    lappend yadj [ lindex $listeyn [expr $len-$j-1] ]
	}
        blt::vector destroy x y yn
     }
     #-----------------------------------------------------------------------#

	#--- Remet les valeurs calculees de listeyn dans l'ordre des abscisses (inverse)
	#set yadj ""
	#for {set j 0} {$j<$len} {incr j} {
	#    lappend yadj [ lindex $listeyn [expr $len-$j-1] ]
	#}
	##for {set j $len} {$j>0} {incr j -1} {
	##    lappend yadj [ lindex $listeyn [expr $j-$len-1] ]
	##}

	#--- Affichage du graphe
	#  ::plotxy::plot $abscisses $yadj

	set coefs [ list $a $b $c ]
	# set adj_vals [list $coefs $abscisses $yadj]
	set adj_vals [ list $coefs $chi2 $covar ]
	#set adj_vals [ list $coefs ]
	return $adj_vals
    } else {
	::console::affiche_erreur "Usage: spc_ajustdeg2 liste_abscisses liste_ordonnees erreur (ex. 1)\n\n"
    }
}
#****************************************************************#




####################################################################
#  Procedure d'ajustement d'un nuage de points par un polynôme de degré 3
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 26-05-2005
# Arguments : liste abscisses, liste ordonnees, erreur
# Condition : il faut 4 couples de points !
####################################################################
#spc_ajustdeg3 {218.67 127.32 16.67} {211 208 210.1} 1
#{218.67 127.32 16.67} {211.022333817 208.007561837 210.100127057}

proc spc_ajustdeg3v1 { args } {
    global conf
    global audace

    if {[llength $args] == 3} {
	set abscisses [lindex $args 0]
	set ordonnees [lindex $args 1]
	set erreur [lindex $args 2]
	set len [llength $ordonnees]

	#--- Calcul des coefficients du polynôme d'ajustement :
	# - calcul de la matrice X : calcul les monônes correspondant aux différents degrés à l'abscisse xi
	set n [llength $abscisses]
       set lingne_i [ list ]
	#set X ""
       set X [ list ]
	for {set i 0} {$i<$n} {incr i} {
	    set xi [lindex $abscisses $i]
	    set ligne_i 1
	    lappend erreurs $erreur
	    lappend ligne_i $xi
	    lappend ligne_i [expr $xi*$xi]
	    lappend ligne_i [expr $xi*$xi*$xi]
	    lappend X $ligne_i
	}
	# - calcul de l'ajustement
	set result [gsl_mfitmultilin $ordonnees $X $erreurs]
	# - extrait le resultat
	set coeffs [lindex $result 0]
	set chi2 [lindex $result 1]
	set covar [lindex $result 2]

	set a [lindex $coeffs 0]
	set b [lindex $coeffs 1]
	set c [lindex $coeffs 2]
       set d [expr {double([lindex $coeffs 3])} ]
	::console::affiche_resultat "Coefficients : $a+$b*x+$c*x^2+$d*x^3\nChi2=$chi2, Covar=$covar\n"
  # ::console::affiche_resultat "[ expr $d*1000000000000000000000000.0 ]\n"
	set coefs [ list $a $b $c $d ]
	# set adj_vals [list $coefs $abscisses $yadj]
	set adj_vals [ list $coefs $chi2 $covar ]
	#set adj_vals [ list $coefs ]
	return $adj_vals
    } else {
	::console::affiche_erreur "Usage: spc_ajustdeg3 liste_abscisses liste_ordonnees erreur (ex. 1)\n\n"
    }
}
#****************************************************************#


############################################################
# Procedure de calcul de factorielle
# Auteur : Patrick Lailly
############################################################

proc spc_fac {n} {
	set prod 1
	for {set i 1} {$i<=$n} {incr i} {
		set prod [ expr $prod * $i ]
	}
	return $prod
}
#****************************************************************#


####################################################################
# Procedure d'ajustement d'un nuage de points par un polynôme de degré N
#
# Auteur : Patrick LAILLY
# Date creation : 23-01-2012
# Date modification : 10-06-2014
# Cette procedure generalise les procedures d'ajustement d'un nuage de points par un polynôme de degré 3
# on utilise ici un autre preconditionnement du systeme lineaire a resoudre rendant la programmation plus aisee
# Arguments : liste abscisses, liste ordonnees, erreur, degre polynome
# Condition : il faut N+2 couples de points !
####################################################################
#spc_ajustdegN {24.3 61.62 118.71 145.34 175.25 243.87 588.4 763.52 876.26 976.19 1218. 1299.} {3974. 4065. 4200.67 4272.17 4348.06 4522.72 5400.56 5852.49 6143.06 6402.25 7032.41 7245.17} 1 4 1

proc spc_ajustdegn { args } {
   global conf
   global audace

   set nbargs [ llength $args ]
   if { $nbargs==4} {
      set abscisses_orig [lindex $args 0]
      set ordonnees [lindex $args 1]
      set erreur [lindex $args 2]
      set Ndeg [lindex $args 3]
   } elseif { $nbargs==5 } {
      set abscisses_orig [ lindex $args 0 ]
      set ordonnees [ lindex $args 1 ]
      set erreur [ lindex $args 2 ]
      set Ndeg [lindex $args 3]
      set crpix1 [ lindex $args 4 ]
   } else {
      ::console::affiche_erreur "Usage: spc_ajustdegn liste_abscisses liste_ordonnees erreur (ex. 1) degre_polyn ?crpix1?\n"
      return ""
   }
   set abscisses_new $abscisses_orig
   #--- Prise en compte de crpix1 :
   if { $nbargs==5 } {
      set abscisses_new [ list ]
      foreach absi $abscisses_orig {
         lappend abscisses_new [ expr $absi-$crpix1 ]
      }
      #set abscisses_orig $abscisses_new
   }


   #--- Initialisation de variables :
   set n [llength $abscisses_orig]
   set len [llength $ordonnees]
   set ordonnees_rangees [ lsort -real -increasing $ordonnees ]
   set abscisses_rangees [ lsort -real -increasing $abscisses_new ]
   set abs_min [ lindex $abscisses_rangees 0 ]
   set abs_max [ lindex $abscisses_rangees [ expr $n -1 ] ]
   ::console::affiche_resultat "$abs_min $abs_max\n"

   #--- Changement de variable ( autre preconditionnement du systeme lineaire) :
   set aa [ expr 1./ ($abs_max - $abs_min) ]
   set bb [ expr -$aa ]
   #::console::affiche_resultat "aa= $aa\n"
   #::console::affiche_resultat "bb= $bb\n"
   set abscisses [ list ]
   for { set i 0 } { $i<$n } {incr i} {
      set xi [ expr $aa * ([ lindex $abscisses_new $i ]-$abs_min) ]
      lappend abscisses $xi
   }

   #--- Calcul des coefficients du polynôme d'ajustement :
   #-- Calcul de la matrice X : calcul les monônes correspondant aux différents degrés à l'abscisse xi
   set x ""
   set X ""
   for {set i 0} {$i<$n} {incr i} {
      set xi [lindex $abscisses $i]
      set ligne_i 1
      lappend erreurs $erreur
      for {set k 1} {$k<=$Ndeg} {incr k} {
	 lappend ligne_i [ expr pow($xi,$k) ]
      }
      lappend X $ligne_i
   }
   #-- Calcul de l'ajustement :
   set result [gsl_mfitmultilin $ordonnees $X $erreurs]
   #-- Extrait le resultat :
   set coeffs [lindex $result 0]
   set chi2 [lindex $result 1]
   set covar [lindex $result 2]
   #::console::affiche_resultat "Chi2=$chi2, Covar=$covar\n"
   #analyse des residus
   set calc [ gsl_mmult $X $coeffs ]
   set res [ gsl_msub $ordonnees $calc ]
   set RMS 0.
   ::console::affiche_resultat "\nLambda (A) : Résidu (A)\n"
   for { set k 0 } {$k< $n} {incr k} {
      set r [ lindex [ lindex $res $k ] 0 ]
      set RMS [ expr $RMS + $r * $r ]
      # ::console::affiche_resultat "pour l'abscisse [ lindex $abscisses_rangees $k ] le residu (en ordonnee) vaut $r \n"
      ::console::affiche_resultat "[ lindex $ordonnees_rangees $k ] : $r \n"
   }
   set RMS [ expr sqrt($RMS/$n) ]
   ::console::affiche_resultat "RMS des résidus : $RMS\n\n"
   #--- Determination des coefficients associes aux abscisses d'origine :
   set coefs [ list ]
   for { set k 0 } {$k<=$Ndeg} {incr k} {
      set coef 0.
      set ak [ expr pow($aa,$k) ]
      for { set kk $k } {$kk<=$Ndeg} {incr kk} {
	 #::console::affiche_resultat "kk= $kk\n"
	 set k_kk [expr $kk-$k]
	 #ci dessous interviennent les combinaisons comme dans la formule du binome
	 set Ck_kk [ expr [ spc_fac $kk ]/([ spc_fac $k ] * [ spc_fac $k_kk ]) ]
	 set coef [ expr $coef + $ak * pow($bb,$k_kk) * $Ck_kk * pow($abs_min,$k_kk) * [lindex $coeffs $kk] ]
      }
      lappend coefs $coef
   }


   ::console::affiche_resultat "Coefficients de polynome: $coefs\n"
   # set adj_vals [list $coefs $abscisses $yadj]
   set adj_vals [ list $coefs $chi2 $covar ]
   #set adj_vals [ list $coefs ]
   set a [ lindex $coefs 0 ]
   set b [ lindex $coefs 1 ]
   set c [ lindex $coefs 2 ]
   set d [ lindex $coefs 3 ]
   if { $Ndeg <= 4 } {
      set rms [ spc_calibrms $crpix1 $a $b $c $d $abscisses_orig $ordonnees ]
   } else {
      set e [ lindex $coefs 4 ]
      set rms [ spc_calibrms $crpix1 $a $b $c $d $e $abscisses_orig $ordonnees ]
   }
   ::console::affiche_resultat "RMS=$rms angstrom\n"
   return $adj_vals
}
#****************************************************************#




####################################################################
#  Procédure d'ajustement d'un nuage de points (le continuum en genereal).
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20-12-2005
# Date modification : 20-12-2005
# Arguments : fichier .fit du profil de raie, erreur
####################################################################

proc spc_ajustfin { args } {
    global conf
    global audace

    if {[llength $args] == 2} {
	set fichier [ lindex $args 0 ]
	set erreur [ lindex $args 1 ]

	#--- Extraction des données et 1ier ajustement :
	set coordonnees_cont [ spc_ajust $fichier 1 ]
	set abscisses_cont [ lindex $coordonnees_cont 0 ]
	set ordonnees_cont [ lindex $coordonnees_cont 1 ]
	set len [ llength $ordonnees_cont ]

	#--- Calcul la difference entre le continuum et le profil a ajuster (normaliser)
	set nom_fichier [ file rootname $fichier ]
	set nom_continuum [ spc_data2fits ${nom_fichier}_conti $coordonnees_cont "double" ]
	buf$audace(bufNo) load $audace(rep_images)/$fichier
	buf$audace(bufNo) sub $audace(rep_images)/$nom_continuum 0
	buf$audace(bufNo) save $audace(rep_images)/${nom_fichier}_diffconti

	#--- Affinement de l'ajustement : enlève les valeurs abérantes de la différence et ajoute la différence au continuum
	set coords_diffconti [ spc_fits2data ${nom_fichier}_diffconti ]
	set ordonnees [lindex [ spc_fits2data $fichier] 1 ]
	set abs_diffconti [ lindex $coords_diffconti 0 ]
	set ord_diffconti [ lindex $coords_diffconti 1 ]
	set yajuste [ list ]
	for {set k 0} {$k<$len} {incr k} {
	    set y_dc [ lindex $ord_diffconti $k ]
	    set y [ lindex $ordonnees $k ]
	    #if {$y_dc == $y} { lappend y_aspline $y }
	    if {$y_dc == $y} {
		lappend yajuste $y
	    } else {
		lappend yajuste [ lindex [ lindex $coordonnees_cont 1 ] $k ]
	    }
	}


	#--- Affichage du graphique :
	set flag_o 0
	if {$flag_o != 0} {
	destroy .testblt
	toplevel .testblt
	blt::graph .testblt.g
	pack .testblt.g -in .testblt
	.testblt.g legend configure -position bottom
	set ly [ lsort $yajuste ]
	#set ly [lsort $ordonnees]
	#set ymax [ bm_max [bm_lmax $ordonnees] [bm_lmax $yadj] ]
	.testblt.g axis configure x -min [lindex $abscissescont 0] -max [lindex $abscisses_cont $len]
	#.testblt.g axis configure y -min 1000 -max 5000
	##.testblt.g axis configure y -min 1000 -max [lindex $ly $len]
	.testblt.g axis configure y -min [lindex $ly 0] -max [lindex $ly $len]
	.testblt.g element create original -symbol none -x x -y y -color blue
	.testblt.g element create interpolation_deg2 -symbol none -x x -y yn -color red
	}

	::plotxy::clf
	::plotxy::plot $abscisses_cont $yajuste r 1
	::plotxy::hold on
	::plotxy::plot $abscisses_cont $ordonnees ob 0
	::plotxy::plotbackground #FFFFFF
	#::plotxy::xlabel "x"
	#::plotxy::ylabel "y"
	::plotxy::title "bleu : orginal ; rouge : interpolation deg 2"


	#--- Enregistrement des points du polynôme d'ajustement
	#set fileetalonnespc [ file rootname $filenamespc ]
	##set filename ${fileetalonnespc}_dat$extsp
	#set filename ${fileetalonnespc}$extsp
	#set file_id [open "$audace(rep_images)/$filename" w+]
	#for {set k 0} {$k<$naxis1} {incr k} {
	    #--- Ecrit les couples "Lambda Intensite" dans le fichier de sortie
	#    puts $file_id "$lambda\t$intensite"
	#}

	set adj_vals [ list $abscisses_cont $yajuste ]
	return $adj_vals
    } else {
	::console::affiche_erreur "Usage: spc_ajustfin fichier_profil.fit erreur (1)\n\n"
    }
}
#***************************************************************************#



####################################################################
# Procédure de calcul de la droite de régression linéaire par les moindres carrés
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 1-09-2006
# Date modification : 1-09-2006
# Arguments : {liste xi} {liste yi}
# Exemple : spc_reglin {0  0.1  0.4  1} {12 11 7 1} doit trouver : -11.0699588477*x+11.9012345679
# Algo : droite de régression linéaire par les moindres carrés
# http://www.bibmath.net/dico/index.php3?action=affiche&quoi=./r/reglin.html
#
####################################################################

proc spc_reglin { args } {
    global conf
    global audace

    set nbargs [llength $args]
    if { $nbargs==2 } {
	set valx [ lindex $args 0 ]
	set valy [ lindex $args 1 ]
    } elseif { $nbargs==3 } {
	set valx [ lindex $args 0 ]
	set valy [ lindex $args 1 ]
        set crpix1 [ lindex $args 2 ]
    } else {
	::console::affiche_erreur "Usage: spc_reglin {liste xi} {liste yi} ?crpix1?\n"
        return ""
    }

   #--- Passage des absicsses avec une origine a 0 :
   if { $nbargs==3 } {
      set nvlax [ list ]
      foreach absi $valx {
         lappend nvalx [ expr $absi-$crpix1 ]
      }
      set valx $nvalx
   }

	#--- Calcul des termes intervenant dans les coéfficients :
	set len [ llength $valx ]
	set somme_x 0
	set somme_y 0
	set somme_x2 0
	set somme_xy 0
	for {set i 0} { $i<$len } {incr i} {
	    set xi [ lindex $valx $i ]
	    set yi [ lindex $valy $i ]

	    set somme_x [ expr $somme_x+$xi ]
	    set somme_y [ expr $somme_y+$yi ]
	    set somme_x2 [ expr $somme_x2+$xi*$xi ]
	    set somme_xy [ expr $somme_xy+$xi*$yi ]
	}

	#--- Calcul des coéficients a et b :
	set a [ expr ($len*$somme_xy-$somme_x*$somme_y)/($len*$somme_x2-$somme_x*$somme_x) ]
	set b [ expr ($somme_y*$somme_x2-$somme_x*$somme_xy)/($len*$somme_x2-$somme_x*$somme_x) ]

	#--- Fin du script :
	::console::affiche_resultat "La droite de régression est : $b+$a*x\n"
	set coeffs [ list $a $b ]
	return $coeffs
}
#***************************************************************************#



####################################################################
#  Procedure de linératisation par spline.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 11-12-2005
# Date modification : 28-03-2006 ; 05-12-2009 ; 21-12-2017 ; 2018-01-11
# Arguments : liste abscisses et liste ordonnées à rééchantillonner, liste absisses modèle d'échantilonnage, (o/n) représentation graphique
####################################################################

proc spc_spline { args } {
    global conf
    global audace

    if {[llength $args] == 4} {
       set abscisses [ lindex $args 0 ]
       set ordonnees [ lindex $args 1 ]
       set nabscisses [ lindex $args 2 ]
       set gflag [ lindex $args 3 ]
    } else {
       ::console::affiche_erreur "Usage: spc_spline absisses ordonnées abscisses_modèles représentation_graphique (o/n)\n"
       return ""
    }


   #--- Nombre d'éléments :
   set len [ llength $ordonnees ]
   set nlen [ llength $nabscisses ]

   #--- Creation des vecteurs :
   blt::vector create xvar
   xvar set $abscisses
   blt::vector create yvar
   yvar set $ordonnees
   blt::vector create sxvar
   sxvar set $nabscisses
   #-- Création du vecteur syvar :
   #- M1 :
   #blt::vector create syvar($nlen)
   #- M2 : vector create ne fonctionne pas pour syvar, donc mettre $ordonnees :
   #blt::vector create syvar
   #syvar set $ordonnees   
   #- M3 : vector create ne fonctionne pas pour syvar, donc boucle d'initialisation :
   #for {set i 0} {$i<$nlen} {incr i} {
   #   #set syvar($i) 0.0
   #   set syvar($i) [ lindex $ordonnees $i ]
   #}
   #- M3 : c'est bien la commande blt:spline qui cree le vecteur syvar !
    
   #-- Evite le pb de monoticaly ("# x vector "x" must be monotonically increasing") :
   xvar sort yvar

   #-- Syntaxe generale :
   # blt::spline natural x y sx sy
   # blt::spline quadratic x y sx sy
   # The spline command computes a spline fitting a set of data points (x and y vectors) and produces a vector of the interpolated images (y-coordinates) at a given set of x-coordinates.

   #-- Syntaxe tcl8.4 :
   blt::spline natural xvar yvar sxvar syvar
   #- Cree la variable TCL syvar_elements qui donne acces aux valeurs :
   syvar variable syvar_elements
   
   #- Exportation des vecteurs coordonnées interpolées en liste puis fichier dat
   for {set i 0} {$i<$nlen} {incr i} {
      #lappend nordonnees $syvar($i)
      lappend nordonnees $syvar_elements($i)
   }

   #-- Syntaxe tcl8.5 (Audela 1.6.0) :
   # set nordonnees [ list ]
   # blt::spline natural $abscisses $ordonnees $nabscisses $nordonnees
   
   #-- Resultat :
   set ncoordonnees [ list $nabscisses $nordonnees ]

   #--- Affichage
   if { [ string compare $gflag "o" ] == 0 } {
      #-- Meth1 : plotxy Tcl
      #set no_fig [ expr int([ lindex [ mc_date2ymdhms now  ] 5 ]) ]
      #::plotxy::clf $no_fig
      #::plotxy::figure $no_fig
      #::plotxy::plot $nabscisses $nordonnees
      #::plotxy::plotbackground #FFFFFF

      #-- Meth2 : BLT
      #- Détermination de l'échelle :
      set xmin $xvar(min)
      set xmax $xvar(max)
      set ymin $yvar(min)
      set ymax $yvar(max)   
      ##::console::affiche_resultat "xmin=$xmin ; xmax=$xmax ; ymin=$ymin ; ymax=$ymax\n"
      #- BLT window :
      destroy .splineblt
      toplevel .splineblt
      blt::graph .splineblt.g ; # -title "Interpolation par spline cubique"
      pack .splineblt.g -in .splineblt
      .splineblt.g legend configure -position bottom
      .splineblt.g axis configure x -min $xmin -max $xmax
      .splineblt.g axis configure y -min $ymin -max $ymax
      .splineblt.g element create "spline_interpolation" -symbol none -xdata sxvar -ydata syvar -color blue ; # -smooth natural 
      .splineblt.g element create " mes_points" -symbol splus -xdata xvar -ydata yvar -color red -linewidth 0
   }


   #--- Fin du script :
   if { "$gflag"!="o" } {
      blt::vector destroy xvar yvar sxvar syvar
   }
   return $ncoordonnees
}
#****************************************************************#


####################################################################
#  Procedure de linératisation par spline.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 11-12-2005
# Date modification : 28-03-2006
# Arguments : liste abscisses et liste ordonnées à rééchantillonner, liste absisses modèle d'échantilonnage, (o/n) représentation graphique
# Bug : a la premiere execution "# x vector "x" must be monotonically increasing"
####################################################################

proc spc_spline85 { args } {
    global conf
    global audace

    if {[llength $args] == 4} {
	set abscisses [ lindex $args 0 ]
	set ordonnees [ lindex $args 1 ]
	set nabscisses [ lindex $args 2 ]
	set gflag [ lindex $args 3 ]

        #-- Syntaxe generale :
	# blt::spline natural x y sx sy
	# blt::spline quadratic x y sx sy
	# The spline command computes a spline fitting a set of data points (x and y vectors) and produces a vector of the interpolated images (y-coordinates) at a given set of x-coordinates.

        #-- Syntaxe tcl8.5 (Audela 1.6.0) :
        set nordonnees [ list ]
	blt::spline natural $abscisses $ordonnees $nabscisses $nordonnees
	set ncoordonnees [ list $nabscisses $nordonnees ]

	#--- Affichage
	if { [ string compare $gflag "o" ] == 0 } {
	    ::plotxy::plot $nabscisses $nordonnees
	    ::plotxy::plotbackground #FFFFFF
	}

	return $ncoordonnees
    } else {
	::console::affiche_erreur "Usage: spc_spline absisses ordonnées abscisses_modèles représentation_graphique (o/n)\n\n"
    }
}
#****************************************************************#



####################################################################
#  Procédure de construction d'une gaussienne.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 18-04-2006
# Date modification : 18-07-2011
# Arguments : nom_fichier_fit_modèle lambda_centre imax fwhm type_raie(a/e) ?icontinuum?
# Remarque : focntionne surr les spectres calibrés et non calibrés
####################################################################

proc spc_gaussienne { args } {
    global conf
    global audace
    set len 100
    #set imax 10.0
    #set xm 50
    #set sigma 5

   if { [ llength $args ] == 5 } {
      set filename [ file rootname [ lindex $args 0 ] ]
      set lambda_c [ lindex $args 1 ]
      set imax [ lindex $args 2 ]
      set lfwhm [ lindex $args 3 ]
      set typeline [ lindex $args 4 ]
      #--- Determine la valeur du continuum :
      set icont [ spc_icontinuum $filename ]
   } elseif { [ llength $args ] == 6 } {
      set filename [ file rootname [ lindex $args 0 ] ]
      set lambda_c [ lindex $args 1 ]
      set imax [ lindex $args 2 ]
      set lfwhm [ lindex $args 3 ]
      set typeline [ lindex $args 4 ]
      set icont [ lindex $args 5 ]
   } else {
      ::console::affiche_erreur "Usage: spc_gaussienne nom_fichier_fit_modèle lambda_centre imax fwhm type_raie(a/e) ?icontinuum?.\n\n"
      return ""
   }



      #--- CAlcul les valeurs de la guaisiien :
      buf$audace(bufNo) load "$audace(rep_images)/$filename"
      set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]

      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
         set crpix1 [ lindex [ buf$audace(bufNo) getkwd "CRPIX1" ] 1 ]
      } else {
         set crpix1 1
      }
      if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
         set flag_cal 1
         set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
         set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
         set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
         set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
      } elseif { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
         set flag_cal 1
         set spc_a [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
         set spc_b [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
         set spc_c 0
         set spc_d 0
      } else {
         set flag_cal 0
      }

      #--- Traduit en pixels les valeurs fournies en arguments :
   if { $flag_cal==1 } {
      set xc [ expr ($lambda_c-$spc_a)/$spc_b+$crpix1 ]
      set fwhm [ expr $lfwhm/$spc_b ]
   } else {
      set xc $lambda_c
      set fwhm $lfwhm
   }

      #--- Calcul les valeurs dela gaussienne entre [+-4 fhhm ] :
      set coef 1.5
      set xdeb [ expr $xc-$coef*$fwhm ]
      set xfin [ expr $xc+$coef*$fwhm ]
      if { $xdeb < 1 } { set xdeb 1 }
      if { $xfin > $naxis1 } { set xfin $naxis1 }

      if { $typeline == "e" } {
         for { set x 1 } { $x <= $naxis1 } { incr x } {
            if { ($x >= $xdeb) && ($x <= $xfin) } {
               # set y [ expr $imax*exp(-1.0*(($x-$xm)*($x-$xm))/(2.0*$sigma*$sigma)) ]
               # set y [ expr ($imax-$icont)*exp(-0.5*pow(($x-$xc)*2*sqrt(2*log(2))/$fwhm,2))+$icont ]
               #-- pour fwhm de spc_fwhm non multipliee par 2 et plus realiste :
               # set y [ expr ($imax-$icont)*exp(-1.0*($x-$xc)*($x-$xc)/$fwhm)+$icont ]
               set y [ expr ($imax-$icont)*exp(-0.5*($x-$xc)*($x-$xc)/$fwhm)+$icont ]
            } else {
               set y $icont
            }
            buf$audace(bufNo) setpix [ list $x 1 ] $y
         }
      } elseif { $typeline == "a" } {
         for { set x 1 } { $x <=$naxis1 } { incr x } {
            #::console::affiche_resultat "point n° $x\n"

            if { ($x >= $xdeb) && ($x <= $xfin) } {
               # set y [ expr $imax*exp(-1.0*(($x-$xm)*($x-$xm))/(2.0*$sigma*$sigma)) ]
               # set y [ expr -(-$imax+$icont)*exp(-0.5*pow(($x-$xc)*2*sqrt(2*log(2))/$fwhm,2))+$icont ]
               # set y [ expr -(-$imax+$icont)*exp(-1.0*($x-$xc)*($x-$xc)/$fwhm)+$icont ]
               #-- pour fwhm de spc_fwhm non multipliee par 2 et plus realiste :
               # set y [ expr -(-$imax+$icont)*exp(-0.5*($x-$xc)*($x-$xc)/$fwhm)+$icont ]
               #-- 21120103 :
               #set y [ expr $icont-($imax-$icont)*exp(-0.5*($x-$xc)*($x-$xc)/$fwhm) ]
               set y [ expr $icont-($imax+$icont)*exp(-0.5*($x-$xc)*($x-$xc)/$fwhm) ]
            } else {
               set y $icont
            }
            buf$audace(bufNo) setpix [ list $x 1 ] $y
         }
      }


      #--- Sauvegarde du profil calibré
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/${filename}_gauss"
      buf$audace(bufNo) bitpix short
      ::console::affiche_resultat "Courbe gaussienne sauvée sous ${filename}_gauss\n"
      return "${filename}_gauss"
}
#****************************************************************#



####################################################################
#  Procédure de construction d'une gaussienne.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 18-04-2006
# Date modification : 18-04-2006
# Arguments : nom du fichier de sortie
####################################################################

proc spc_gaussienne0 { args } {
    global conf
    global audace
    set len 100
    #set imax 10.0
    #set xm 50
    #set sigma 5

    if {[llength $args] == 4} {
	set filename [ lindex $args 0 ]
	set imax [ lindex $args 1 ]
	set xm [ lindex $args 2 ]
	set sigma [ lindex $args 3 ]

	buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_FLOAT COMPRESS_NONE 0
	#-- Pas
	buf$audace(bufNo) setkwd [list "CRPIX1" 1 double "" ""]
	#-- Longueur d'onde de départ
	buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 double "" ""]
	#-- Dispersion
	buf$audace(bufNo) setkwd [list "CDELT1" 1.0 double "" ""]

	for {set x 1} {$x <= $len} {incr x} {
	    #set y [ expr $imax*exp(-1.0*($x-$xm)^2/$sigma^2) ]
	    set y [ expr $imax*exp(-1.0*(($x-$xm)*($x-$xm))/(2.0*$sigma*$sigma)) ]
	    #set deltax2 [ expr ($x-$xm)*($x-$xm) ]
	    buf$audace(bufNo) setpix [list [expr $x] 1] $y
	    #::console::affiche_resultat "y=$y\n"
	}

	#--- Sauvegarde du profil calibré
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/$filename"
	::console::affiche_resultat "Courbe gaussienne sauvée sous $filename\n"
    } else {
	::console::affiche_erreur "Usage: spc_gaussienne nom_fichier_fit_sortie imax xmoy sigma.\n\n"
    }
}
#****************************************************************#




####################################################################
# Procédure de calcul de la différence 2 à 2 de 2 liste de valeurs.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 14-10-2006
# Date modification : 14-=10-2006
# Arguments : 2 listes de valeurs
####################################################################

proc spc_ajustverif { args } {
    global conf
    global audace

    set nbargs [ llength $args ]
    if { $nbargs <= 3 } {
	if { $nbargs == 2 } {
	    set liste1 [ lindex $args 0 ]
	    set liste2 [ lindex $args 1 ]
	} elseif { $nbargs == 3 } {
	    set liste1 [ lindex $args 0 ]
	    set liste2 [ lindex $args 1 ]
	    set dispersion_spectrale [ lindex $args 2 ]
	} else {
	    ::console::affiche_erreur "Usage: spc_ajustverif liste_valeurs_1 liste_valeurs_2 ?dispersion_spectrale?\n\n"
	    return 0
	}


	#-- Calcul la différence 2 à 2 :
	foreach xa $liste1 xb $liste2 {
	    set difference [ expr $xa-$xb ]
	    lappend diffs $difference
	    lappend sqdiffs [ expr $difference*$difference ]
	}

	#--- Calcul la moyenne et la norme des différence :
	set len [ llength $diffs ]
	set moy 0
	set norme 0
	foreach xd $diffs sqxd $sqdiffs {
	    set moy [ expr $moy+$xd ]
	    set norme [ expr $norme+$sqxd ]
	}
	set moy [ expr $moy/$len ]
	set normem [ expr $norme/$len ]

	#--- Calcul du  Chi2 et du RMS lors de la regression lineaire :
	set results1 [ spc_ajustdeg1 $liste1 $liste2 1 ]
	set chi2 [ lindex $results1 1 ]
	if { $nbargs == 3 } {
	    set rms [ expr $dispersion_spectrale*sqrt($chi2/$len) ]
	    ::console::affiche_resultat "RMS=$rms\n"
	}

	::console::affiche_resultat "Différences : $diffs\nValeur moyenne : $moy\nNorme : $normem\nChi2=$chi2\n"
	set result [ list $moy $norme ]
	return $result
    } else {
	::console::affiche_erreur "Usage: spc_ajustverif liste_valeurs_1 liste_valeurs_2 ?dispersion_spectrale?\n\n"
    }
}
#****************************************************************#



####################################################################
# Procédure d'intégration d'une fonction numérique par la méthode des trapèzes
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 1-09-2006
# Date modification : 1-09-2006
# Arguments : {{liste xi} {liste yi}}
####################################################################

proc spc_aire { args } {
    global conf
    global audace

    if { [llength $args] == 1 } {
       set listevals [ lindex $args 0 ]
       set valx [ lindex $listevals 0 ]
       set valy [ lindex $listevals 1 ]
       set len  [ llength $valx ]
       set nmax [ expr $len-2 ]

       set aire 0
       for {set i 0} { $i<=$nmax } {incr i} {
          set yi [ lindex $valy $i ]
          set yii [ lindex $valy [ expr $i+1 ] ]
          set aire [ expr $aire+($yii+$yi) ]
          # ::console::affiche_resultat "aire $i : $aire\n"
       }
       set xdeb [ lindex $valx 0 ]
       set xfin [ lindex $valx [ expr $len-1 ] ]
       set aire [ expr ($xfin-$xdeb)/(2*$len)*$aire ]
       ::console::affiche_resultat "L'aire vaut : $aire\n"
       return $aire
    } else {
       ::console::affiche_erreur "Usage: spc_aire {{liste xi} {liste yi}}\n"
    }
}
#***************************************************************************#


####################################################################
# Procédure d'intégration d'une fonction numérique par la méthode des trapèzes
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 1-09-2006
# Date modification : 1-09-2006
# Arguments : {{liste xi} {liste yi}}
####################################################################

proc spc_aire1 { args } {
    global conf
    global audace

    if { [llength $args] == 1 } {
	set listevals [ lindex $args 0 ]
	set valx [ lindex $listevals 0 ]
	set valy [ lindex $listevals 1 ]
	set len [ expr [ llength $valx ]-1 ]

	set aire 0
	for {set i 0} { $i<$len } {incr i} {
	    set xi [ lindex $valx $i ]
	    set xii [ lindex $valx [ expr $i+1 ] ]
	    set yi [ lindex $valy $i ]
	    set yii [ lindex $valy [ expr $i+1 ] ]
	    set aire [ expr $aire+($xii-$xi)*0.5*($yii+$yi) ]
	    # ::console::affiche_resultat "aire $i : $aire\n"
	}
	::console::affiche_resultat "L'aire vaut : $aire\n"
	return $aire
    } else {
	::console::affiche_erreur "Usage: spc_aire {{liste xi} {liste yi}}\n"
    }
}
#***************************************************************************#



####################################################################
# Procédure de dérivation d'une fonction numérique
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 1-09-2006
# Date modification : 1-09-2006
# Arguments : {{liste xi} {liste yi}}
####################################################################

proc spc_derivation { args } {
    global conf
    global audace

    if { [llength $args] == 1 } {
	set listevals [ lindex $args 0 ]
	set valx [ lindex $listevals 0 ]
	set valy [ lindex $listevals 1 ]
	set len [ expr [ llength $valx ]-1 ]

	for {set i 0} { $i<$len } {incr i} {
	    set xi [ lindex $valx $i ]
	    set xii [ lindex $valx [ expr $i+1 ] ]
	    set yi [ lindex $valy $i ]
	    set yii [ lindex $valy [ expr $i+1 ] ]
	    lappend derivey [ expr ($yii-$yi)/($xii-$xi) ]
	    lappend valxi $xi
	}
	set derivee [ list $valxi $derivey ]
	return $derivee
    } else {
	::console::affiche_erreur "Usage: spc_derivation {{liste xi} {liste yi}}\n"
    }
}
#***************************************************************************#


####################################################################
# Interpolation par b-spline
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 25-11-2006
# Date modification : 25-11-2006
# Arguments : {{liste xi} {liste yi} {liste Xi}}
####################################################################

# valx : 0.9 1.3 1.9 2.1 2.6 3.0 3.9 4.4 4.7 5.0 6.0 7.0 8.0 9.2 10.5 11.3 11.6 12.0 12.6 13.0 13.3
# valy : 1.3 1.5 1.85 2.1 2.6 2.7 2.4 2.15 2.05 2.1 2.25 2.3 2.25 1.95 1.4 0.9 0.7 0.6 0.5 0.4 0.25

proc spc_bspline { args } {
    global conf
    global audace

    set Nu 20.

    if { [llength $args] == 1 } {
	set listevals [ lindex $args 0 ]
	set valx [ lindex $listevals 0 ]
	set valy [ lindex $listevals 1 ]
	#set valxs [ lindex $listevals 2 ]

	#--- Initialise les longueurs de listes :
	#-- Nombre de valeurs à interpoler
	set N [ llength $valx ]
	set Nu [ expr $N-3 ]
	#-- Nombre de valeurs qui seront calculées : échantillonnage de du spline
	set n [ expr 1+($N-3)*$Nu ]
	#-- du=x(i+1)-x(i)
	set du [ expr [ lindex $valx 1 ] - [ lindex $valx 0 ] ]


	#--- Calcul des valaurs interpolées :
	for {set i 1} { $i<[ expr $N-2] } {incr i} {
	    #-- Valeurs utilisées par le spline :
	    set x0 [ lindex $valx [ expr $i-1 ] ]
	    set x1 [ lindex $valx $i ]
 	    set x2 [ lindex $valx [ expr $i+1 ] ]
	    set x3 [ lindex $valx [ expr $i+2 ] ]
	    set y0 [ lindex $valy [ expr $i-1 ] ]
	    set y1 [ lindex $valy $i ]
 	    set y2 [ lindex $valy [ expr $i+1 ] ]
	    set y3 [ lindex $valy [ expr $i+2 ] ]

	    for {set j 0} { $j<=$Nu } {incr j} {
		#-- Initialise :
		set u [ expr $du*$j ]
		set v [ expr 1.0-$u ]

		#-- Initialise :
		set u2 [ expr $u*$u ]
		set u3 [ expr $u*$u*$u ]
		set v2 [ expr $v*$v ]
		set v3 [ expr $v*$v*$v ]

		#-- Calcul des valeurs interpolées :
		lappend xspline [ expr $x0*$v3/6.+$x1*(3.*$u3-6.*$u2+4.)/6.+$x2*(-3.*$u3+3.*$u2+3.*$u+1.)/6.+$x3*$u3/6. ]
		lappend yspline [ expr $y0*$v3/6.+$y1*(3.*$u3-6.*$u2+4.)/6.+$y2*(-3.*$u3+3.*$u2+3.*$u+1.)/6.+$y3*$u3/6. ]
	    }
	}

	#--- Affichage du plot :
	#::plotxy::plot $valx $valy
	## ::plotxy::plot $xspline $yspline
       #::plotxy::plotbackground #FFFFFF
       ::plotxy::figure [ expr int([ lindex [ mc_date2ymdhms now  ] 5 ]) ]
       ::plotxy::clf
	::plotxy::plot $valx $valy r 1
	::plotxy::hold on
	##::plotxy::plot $xspline $yspline ob 0
	::plotxy::plot $valx $yspline ob 0
	::plotxy::plotbackground #FFFFFF
	::plotxy::title "rouge : orginal - bleu : interpolation B-spline"

	set interpolee [ list $xspline $yspline ]
	return $interpolee
    } else {
	::console::affiche_erreur "Usage: spc_bspline {{liste xi} {liste yi}}\n"
    }
}
#***************************************************************************#


#======================================================================#


#****************************************************************#
proc spc_ajust_ok_mais_sans_inversion { args } {
    global conf
    global audace

    if {[llength $args] == 2} {
	set filenamespc [ lindex $args 0 ]
	set erreur [ lindex $args 1 ]
	set contenu [spc_openspcfits $filenamespc]
	set abscisses [lindex $contenu 0]
	set ordonnees [lindex $contenu 1]
	set len [llength $ordonnees]

	#--- Calcul des coefficients du polynôme d'ajustement
	# - calcul de la matrice X
	set n [llength $abscisses]
	set x ""
	set X ""
	for {set i 0} {$i<$n} {incr i} {
	    set xi [lindex $abscisses $i]
	    set ligne_i 1
	    lappend erreurs $erreur
	    lappend ligne_i $xi
	    lappend ligne_i [expr $xi*$xi]
	    #lappend ligne_i [expr $xi*$xi*$xi]
	    lappend X $ligne_i
	}
	# - calcul de l'ajustement
	set result [gsl_mfitmultilin $ordonnees $X $erreurs]
	# - extrait le resultat
	set coeffs [lindex $result 0]
	set chi2 [lindex $result 1]
	set covar [lindex $result 2]

	set a [lindex $coeffs 0]
	set b [lindex $coeffs 1]
	set c [lindex $coeffs 2]
	#set d [lindex $coeffs 3]
	::console::affiche_resultat "Coefficients : $a+$b*x+$c*x^2\n"

	#--- Crée les vecteur à tracer
	blt::vector create x($len) y($len) yn($len)
	for {set i $len} {$i > 0} {incr i -1} {
	    set x($i-1) [lindex $abscisses [expr $i-1]]
	    set y($i-1) [lindex $ordonnees [expr $i-1]]
	    set yn($i-1) [expr $a+$b*$x($i-1)+$c*$x($i-1)*$x($i-1)]
	    #set yn($i-1) [expr $a+$b*$x($i-1)+$c*$x($i-1)*$x($i-1)+$d*$x($i-1)*$x($i-1)*$x($i-1)]
	    lappend yadj $yn($i-1)
	}

	#--- Remet les valeurs calculees de listeyn dans l'ordre des abscisses (inverse)
	#set yadj ""
	#for {set j 0} {$j<$len} {incr j} {
	#    lappend yadj [ lindex $listeyn [expr $len-$j-1] ]
	#}
	##for {set j $len} {$j>0} {incr j -1} {
	##    lappend yadj [ lindex $listeyn [expr $j-$len-1] ]
	##}

	#--- Affichage du graphe
	destroy .testblt
	toplevel .testblt
	blt::graph .testblt.g
	pack .testblt.g -in .testblt
	.testblt.g legend configure -position bottom
	set ly [lsort $yadj]
	#set ly [lsort $ordonnees]
	#set ymax [ bm_max [bm_lmax $ordonnees] [bm_lmax $yadj] ]
	.testblt.g axis configure x -min [lindex $abscisses 0] -max [lindex $abscisses $len]
	#.testblt.g axis configure y -min 1000 -max 5000
	##.testblt.g axis configure y -min 1000 -max [lindex $ly $len]
	.testblt.g axis configure y -min [lindex $ly 0] -max [lindex $ly $len]
	.testblt.g element create original -symbol none -x x -y y -color blue
	.testblt.g element create interpolation_deg2 -symbol none -x x -y yn -color red

	#--- Enregistrement des points du polynôme d'ajustement
	#set fileetalonnespc [ file rootname $filenamespc ]
	##set filename ${fileetalonnespc}_dat$extsp
	#set filename ${fileetalonnespc}$extsp
	#set file_id [open "$audace(rep_images)/$filename" w+]
	#for {set k 0} {$k<$naxis1} {incr k} {
	    #--- Ecrit les couples "Lambda Intensite" dans le fichier de sortie
	#    puts $file_id "$lambda\t$intensite"
	#}
        blt::vector destroy x y yn
	set adj_vals [list $abscisses $yadj]
	return $adj_vals
    } else {
	::console::affiche_erreur "Usage: spc_ajust fichier_profil.fit erreur (1)\n\n"
    }
}
#****************************************************************#


proc spc_ajust_051215a { args } {
    global conf
    global audace

    if {[llength $args] == 2} {
	set filenamespc [ lindex $args 0 ]
	set erreur [ lindex $args 1 ]
	set contenu [spc_openspcfits $filenamespc]
	set abscisses [lindex $contenu 0]
	set ordonnees [lindex $contenu 1]
	set len [llength $ordonnees]

	#--- Calcul des coefficients du polynôme d'ajustement
	# - calcul de la matrice X
	set n [llength $abscisses]
	set x ""
	set X ""
	for {set i 0} {$i<$n} {incr i} {
	    set xi [lindex $abscisses $i]
	    set ligne_i 1
	    lappend erreurs $erreur
	    lappend ligne_i $xi
	    lappend ligne_i [expr $xi*$xi]
	    #lappend ligne_i [expr $xi*$xi*$xi]
	    lappend X $ligne_i
	}
	# - calcul de l'ajustement
	set result [gsl_mfitmultilin $ordonnees $X $erreurs]
	# - extrait le resultat
	set coeffs [lindex $result 0]
	set chi2 [lindex $result 1]
	set covar [lindex $result 2]

	set a [lindex $coeffs 0]
	set b [lindex $coeffs 1]
	set c [lindex $coeffs 2]
	#set d [lindex $coeffs 3]
	::console::affiche_resultat "Coefficients : $a+$b*x+$c*x^2\n"

	#--- Crée les vecteur à tracer
	blt::vector create x($len) y($len) yn($len)
	set listeyn ""
	for {set i $len} {$i > 0} {incr i -1} {
	    set x($i-1) [lindex $abscisses [expr $i-1]]
	    set y($i-1) [lindex $ordonnees [expr $i-1]]
	    set yn($i-1) [expr $a+$b*$x($i-1)+$c*$x($i-1)*$x($i-1)]
	    #set yn($i-1) [expr $a+$b*$x($i-1)+$c*$x($i-1)*$x($i-1)+$d*$x($i-1)*$x($i-1)*$x($i-1)]
	    lappend listeyn $yn($i-1)
	}
	#set yadj $listeyn

	#--- Remet les valeurs calculees de listeyn dans l'ordre des abscisses (inverse)
	set yadj ""
	for {set j 0} {$j<$len} {incr j} {
	    lappend yadj [ lindex $listeyn [expr $len-$j-1] ]
	}
	##for {set j $len} {$j>0} {incr j -1} {
	##    lappend yadj [ lindex $listeyn [expr $j-$len-1] ]
	##}

	#--- Affichage du graphe
	destroy .testblt
	toplevel .testblt
	blt::graph .testblt.g
	pack .testblt.g -in .testblt
	.testblt.g legend configure -position bottom
	set ly [lsort $yadj]
	#set ly [lsort $ordonnees]
	#set ymax [ bm_max [bm_lmax $ordonnees] [bm_lmax $yadj] ]
	.testblt.g axis configure x -min [lindex $abscisses 0] -max [lindex $abscisses $len]
	#.testblt.g axis configure y -min 1000 -max 5000
	##.testblt.g axis configure y -min 1000 -max [lindex $ly $len]
	.testblt.g axis configure y -min [lindex $ly 0] -max [lindex $ly $len]
	.testblt.g element create original -symbol none -x x -y y -color blue
	.testblt.g element create interpolation_deg2 -symbol none -x x -y yn -color red

	#--- Enregistrement des points du polynôme d'ajustement
	#set fileetalonnespc [ file rootname $filenamespc ]
	##set filename ${fileetalonnespc}_dat$extsp
	#set filename ${fileetalonnespc}$extsp
	#set file_id [open "$audace(rep_images)/$filename" w+]
	#for {set k 0} {$k<$naxis1} {incr k} {
	    #--- Ecrit les couples "Lambda Intensite" dans le fichier de sortie
	#    puts $file_id "$lambda\t$intensite"
	#}
        blt::vector destroy x y yn
	set adj_vals [list $abscisses $yadj]
	return $adj_vals
    } else {
	::console::affiche_erreur "Usage: spc_ajust fichier_profil.fit erreur (1)\n\n"
    }
}
#****************************************************************#



###################################################################
# Procedure de determination du minimum entre 2 valeurs
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 01-06-08
# Date modification : 01-06-08
# Arguments : valeur 1, valeur 2
#####################################################################

proc spc_resample0 { args } {


   if { [ llength $args ] == 3 } {
      set xvals [ lindex $args 0 ]
      set yvals [ lindex $args 1 ]
      set nxvals [ lindex $args 2 ]

      #--- Recupere les informations sur l'echantillon :
      set len [ llength $xvals ]
      set x_0 [ lindex $xvals 0 ]

      #--- Calcul
      set new_xvals [ list ]
      for {set i 0} {$i<$len} {incr i} {
         lappend new_xvals [ expr $pas*$i+$lambda_deb ]
      }

      #-- Rééchantillonne par spline les intensités sur la nouvelle échelle en longueur d'onde :
      #-- Verifier les valeurs des lambdas pour eviter un "monoticaly error de BLT".
      set new_intensities [ lindex  [ spc_spline $xvals $yvals $nxvals n ] 1 ]
      return $new_coordonnees
   } else {

   }
}

#******************************************************************************#

####################################################################
# Procedure déterminant les bornes (indice) inf et sup d'un ensemble de valeurs où elles sont différentes de 0
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 14-07-2007
# Date modification : 14-07-2007
# Arguments : liste valeurs
# Sortie : les indices inf et sup de la liste
####################################################################

proc spc_findnnul_1 { args } {
    global conf
    global audace

    if { [llength $args] == 1 } {
        set liste_intensites [ lindex $args 0 ]

        #--- Initialisations :
        set len [ llength $liste_intensites ]
        set i_inf 0
        set i_sup [ expr $len-1 ]

        #--- Recherche de i_inf :
        for {set i 0} {$i<$len} {incr i} {
            if { [ lindex $liste_intensites $i ]>0 } {
                set i_inf $i
                break
            }
        }

        #--- Recherche de i_sup :
        for {set i [ expr $len-1 ]} {$i>=0} {incr i -1} {
            if { [ lindex $liste_intensites $i ]>0 } {
                set i_sup $i
                break
            }
        }

        #--- Traitement des résultats :
        set results [ list $i_inf $i_sup ]
        return $results
    } else {
        ::console::affiche_erreur "Usage: spc_findnnul liste_intensites\n"
    }
}
#***************************************************************************#
