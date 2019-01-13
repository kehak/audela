

# Mise a jour $Id: spc_filter2.tcl 14525 2018-11-09 18:22:10Z bmauclaire $
# Mise a jour Patrick Lailly 29 mai 2009


####################################################################
# Procedure de la fonction d'apodisation pour filtre passe bas a reponse impulsionnelle finie
# Auteur : Patrick LAILLY
# Date creation : 18-4-07
# Date modification : 1-5-07
# Arguments : demilargeur de la reponse impulsionnelle du filtre, nombre d'echantillon du profil a # filtrer, type de fonction d'apodisation
# Algo : reprod. des formules donnees dans "Digital Signal Processing" par Oppenheim et Schafer
# La reponse impulsionnelle du filtre aura un nombre impair d'echantillons (2 * demilargeur + 1)
####################################################################

proc fonc_apod  { demilargeur nlen type_apod } {

   set nlarg [ expr 2*$demilargeur+1 ]
   set apod [ list ]
   for {set i 0} {$i<$nlen} {incr i} {
      lappend apod 0.
   }

   switch $type_apod {
      #set amplit [ expr 1./$nlarg ]
      #::console::affiche_resultat "nlen= $nlen\n"
      #::console::affiche_resultat "longueur filtre= [llength $filtr ]\n"

      rectangle {
	 for {set i 0} {$i<=$demilargeur} {incr i} {
	    set apod [ lreplace $apod $i $i 1 ]
	 }
	 #::console::affiche_resultat "longueur filtre= [llength $filtr ]\n"
	 set redemar [ expr $nlen-$demilargeur ]
	 #::console::affiche_resultat "redemar=$redemar\n"
	 for {set i $redemar} {$i<$nlen} {incr i} {
	    set apod [ lreplace $apod $i $i 1 ]
	 }
      }

      blackman {
	 set pi [ expr 2.*asin(1.) ]
	 for {set i 0} {$i<=$demilargeur} {incr i} {
	    set amplit [ expr 0.42-0.5*cos($pi*($i+$demilargeur)/$demilargeur)+0.08*cos(2.*$pi*($i+$demilargeur)/$demilargeur) ]
	    set apod [ lreplace $apod $i $i $amplit ]
	 }
	 set redemar [ expr $nlen-$demilargeur ]
	 for {set i $redemar} {$i<$nlen} {incr i} {
	    set amplit [ expr 0.42-0.5*cos($pi*($i-$redemar)/$demilargeur)+0.08*cos(2.*$pi*($i-$redemar)/$demilargeur) ]
	    set apod [ lreplace $apod $i $i $amplit ]
	 }
      }

      hanning {
	 set pi [ expr 2.*asin(1.) ]
	 for {set i 0} {$i<=$demilargeur} {incr i} {
	    set amplit [ expr 0.5-0.5*cos($pi*($i+$demilargeur)/$demilargeur) ]
	    set apod [ lreplace $apod $i $i $amplit ]
	 }
	 set redemar [ expr $nlen-$demilargeur ]
	 for {set i $redemar} {$i<$nlen} {incr i} {
	    set amplit [ expr 0.5-0.5*cos($pi*($i-$redemar)/$demilargeur) ]
	    set apod [ lreplace $apod $i $i $amplit ]
	 }
      }
   }
   return $apod

}
#****************************************************************#


####################################################################
# Procedure de filtrage passe bas (filtre a reponse impulsionnelle
# finie avec fonctions d'apodisation diverses)
#
# Auteur : Patrick LAILLY
# Date creation : 18-4-07
# Date modification : 1-5-07
# Arguments : liste d'ordonnees, demilargeur de la
# fonction d'apodisation, periode maximale autorisee (en nb d'echantillons)
# c-a-d periode de coupure, type de fonction d'aposisation
# Algo : application (par passage dans l'espace de Fourier) d'un filtre
# passe-bas de r?ponse impulsionnelle finie. Trois types de filtres sont
# propos?s : rectangle, Hanning ou Blackman. Les donn?es filtr?es sont
# calcul?es sauf aux bords (dont l'?tendue est, de chaque cot?, ?gale ? la
# demi-largeur du filtre). Sur ces bords on reproduit les donn?es d'entr?e.
####################################################################
proc spc_passebas_pat { args } {
    global conf
    global audace
    if { [llength $args] <= 4  &&  [llength $args] > 0 } {
	if { [llength $args] == 4 } {
	    set ordonnees [ lindex $args 0 ]
	    set demilargeur [ lindex $args 1 ]
	    set period_max [ lindex $args 2 ]
	    set type_apod [ lindex $args 3 ]
	    #if { { $type_apod != blackman } || { $type_apod != rectangle } || { $type_apod != hanning } } {
	    #::console::affiche_erreur "Usage spc_passebas_pat : seules fonctions d'apodisation admises : blackman,
	    #hanning ou rectangle\n\n"
	    #return 0
	    #}
	} elseif { [llength $args] == 3 } {
	    set ordonnees [ lindex $args 0 ]
	    set demilargeur [ lindex $args 1 ]
	    set period_max [ lindex $args 2 ]
	    set type_apod blackman
	} elseif { [llength $args] == 2 } {
	    set ordonnees [ lindex $args 0 ]
	    set demilargeur [ lindex $args 1 ]
	    set period_max $demilargeur
	    set type_apod blackman
	} elseif { [llength $args] == 1 } {
	    set ordonnees [ lindex $args 0 ]
	    set demilargeur 25
            set period_max $demilargeur
	    set type_apod blackman
	}

#tests sur la compatibilite des donnees
	if { $period_max > [ expr 2.*$demilargeur+1 ] } {
	::console::affiche_erreur "Usage: spc_passebas la periode max doit etre plus petite que 2*demilargeur+1 \n\n"
	return 0
	} else {
	set nordonnees $ordonnees

# prolongement du spectre si le nombre d'echantillons est pair
	set len [ llength $ordonnees ]
	set nlen $len

	if {[ expr $len%2 ]==0} {
		lappend nordonnees  [ lindex $ordonnees [ expr $len-1 ] ]
		set nlen [ expr $nlen +1 ]
	}
	if { $nlen < [ expr 2.*$demilargeur+1 ] } {
		::console::affiche_erreur "Usage: spc_passebas le nombre d'echantillons doit etre plus grand que 2*demilargeur+1 \n\n"
		return 0
	} else {

# construction de la fonction d'apodisation
	set apod [ fonc_apod $demilargeur $nlen $type_apod ]
	#::console::affiche_resultat "longueur apod [ llength $apod ]\n"

# calcul reponse impulsionnelle filtre passe-bas
 	#set omega_coup [ expr 4.*$nlen*[ expr asin(1) ]/$period_max ]
	set omega_coup [ expr 4.*[ expr asin(1) ]/$period_max ]
	set nlarg [ expr 2*$demilargeur+1 ]

	set demilongueur [ expr $nlen/2 ]
	set impuls [ list ]
	lappend impuls [ expr $omega_coup/(2*[ expr asin(1) ]) ]
	for {set i 1} {$i<=$demilongueur} {incr i} {
		lappend impuls [ expr sin($omega_coup*$i) ]/(2*$i*[ expr asin(1) ])
	}
	for {set i 1} {$i<=$demilongueur} {incr i} {
		lappend impuls [ lindex $impuls [ expr $demilongueur - $i + 1 ] ]
	}

	# constructtion du noyau de convolution
	set filtr [ list ]
	set temps ""
	set lignezeros ""
	for {set i 0} {$i<$nlen} {incr i} {
		lappend filtr [ expr [ lindex $impuls $i ] * [ lindex $apod $i ] ]
		lappend lignezeros 0.
		lappend temps [ expr $i*1. ]
	}

	set filtrfft [ gsl_fft $filtr $temps]
	set refiltrfft [ lindex $filtrfft 0 ]
	set imfiltrfft [ lindex $filtrfft 1 ]
	if {$imfiltrfft != $lignezeros} {
		#::console::affiche_resultat "erreur (en general pas grave) part imag filtr\n"
	}

	#normalisation du filtre (conservation de la DC)
	set normal [ expr 1./ [ lindex $refiltrfft 0 ] ]
	#for {set i 0} {$i<$nlen} {incr i} {
	#	set refiltrfft [ lreplace $refiltrfft $i $i [ expr [ lindex $refiltrfft $i ] * $normal ] ]
	#}
        set refiltrfftold $refiltrfft
        set refiltrfft [ list ]
        for {set i 0} {$i<$nlen} {incr i} {
           set elemi [ expr [ lindex $refiltrfftold $i ] * $normal ]
           lappend refiltrfft $elemi
        }

	# filtrage des donnees

	set amplitfft [ gsl_fft $nordonnees $temps]
 	set reamplitfft [ lindex $amplitfft 0 ]
	set imamplitfft [ lindex $amplitfft 1 ]
	set reprod ""
	set improd ""
	for {set i 0} {$i<$nlen} {incr i} {
 		set prod1 [ expr [ lindex $refiltrfft $i ]*[ lindex $reamplitfft $i ] ]
		set prod2 [ expr [ lindex $refiltrfft $i ]*[ lindex $imamplitfft $i ] ]
		lappend reprod $prod1
		lappend improd $prod2
	}
	set result [ gsl_ifft $reprod $improd $temps ]
	set reconvol [ lindex $result 0 ]
	set imconvol [ lindex $result 1 ]
	if {$imconvol != $lignezeros} {
		#::console::affiche_resultat "erreur part (en general pas grave) imag filtr \n"
	}
	#::console::affiche_resultat "longueur r?sultat convolution= [ llength $reconvol ]\n"
	#?limination des effets de bord (remplacement par les valeurs d'origine)

	for {set i 0} {$i<$demilargeur} {incr i} {
		set reconvol [ lreplace $reconvol $i $i [ lindex $ordonnees $i ] ]
	}
	for {set i [expr $len-$demilargeur ]} {$i<$len} {incr i} {
		set reconvol [ lreplace $reconvol $i $i [ lindex $ordonnees $i ] ]
	}
	# retour aux dimensions d'origine
	if { $nlen != $len } {
		set reconvol [ lrange $reconvol 0  [expr $len-1 ] ]
	}

	#::console::affiche_resultat "longueur r?sultat filtrage= [ llength $reconvol ]\n"
	#::console::affiche_resultat "longueur ordonnees= [ llength $ordonnees ]\n"


	}
	}
	return $reconvol

} else {
	    ::console::affiche_erreur "Usage: spc_passebas liste d'ordonnees ? demilargeur du filtre (25)? , periode de coupure ? type fonction d'apodisation (blackmann) ?\n\n"
	    return 0
	}

}
#****************************************************************#


#########################################################################################################
# Procedure de lissage d'un profil basse resolution typiquement un résultat de division,
# supposé calibré linéairement, via une fonction linéaire par morceaux en considerant comme
# donnee aberrante les echantillons situes a proximite de raies bien connues (raies
# telluriques, dioxygene,...)
# Auteur : Patrick LAILLY
# Date creation : 01-12-2008
# Date modification :01-12-2008
# Algo : ajustement par moindres carrés des données (résultat division) par une fonction
# lineaire par morceaux. La procedure fonctionne ici en mode automatique : elle ne prend pas en compte les echantillons
# situes dans des intervalles de longueurs d'ondes definis dans le fichier forgetlambda.dat : ces echantillons sont
# censes etre potentiellement contamines par des raies d'absorbtion ou, de facon plus générale contenir des données
# aberrantes. Un coefficient d'extension de la largeur de ces intervalles donne la souplesse requise en cas de calibration # imprecise.
# Le parametre nechant definit la largeur des intervalles sur lesquels la fonction est lineaire
# (ce parametre n'a pas beaucoup d'importance tant qu'il n'est pas trop grand, la valeur 20
# semblant pouvoir traiter l'essentiel des situations; donner a ce parametre une valeur
# petite n'a pas d'autre incidence que d'augmenter le temps de calcul) : d'ailleurs l'algorithme
# modifie legerement la valeur choisie au depart afin de minimiser les effets de bord. Ne pas
# donner cependant une valeur inferieure a 18. Le
# filtrage est fondamentalement assure par l'application d'une regularisation (precisement on
# penalise la norme L^2 de la fonction derivee seconde du profil lisse), la "force" de cette
# regularisation etant definie par le parametre regul_weight ( plus sa valeur est grande plus on
# lisse). La valeur 1. correspond a un faible lissage et la valeur 10000. a un fort lissage.
# Si l'on souhaite un lissage variable en fonction de la longueur d'onde on peut utiliser
# l'argument liste_regul : cette liste donne les valeurs relatives du poids de regularisation
# pour differentes longueurs d'ondes. Soulignons qu'il s'agit de valeurs relatives : seules
# sont pris en compte le rapport entre les differentes valeurs de la liste, la force globale de
# la regularisation etant geree par le parametre regul_weight. A titre d'exemple
# - une liste a un element correspond a une regularisation uniforme
# - une liste a deux elements correspond a une regularisation variable lineairement, les valeurs
# dans la liste definissant les variations relatives du poids de regularisation aux bornes de
# l'intervalle de longueurs d'ondes considerees
# - une liste a trois elements correspond a une regularisation variable, les valeurs
# dans la liste definissant les variations relatives du poids de regularisation pour la longueur
# d'onde minimum, pour la longueur d'onde centrale et pour la longueur d'onde maximale
# - etc.
#
# Le parametre visu permet de s'assurer visuellement de la qualite du resultat et donne
# les échantillons pris en compte (ce sont ceux pour lesquels  la courbe verte prend une valeur
# non nulle.
#
# Arguments obligatoires : fichier .fit du profil de raie, nom du fichier.dat (avec chemin d'acces si ce fichier n'est
# pas dans le répertoire images d'Audela) donnant les intervalles de longueur d'ondes ou sont localisees
# les raies perturbatrices coefficient d'extension de la largeur de ces intervalles, poids de régularisation
# Arguments facultatifs : liste_regul, visu ('o' ou 'n'), nechant
#
# Exemples :
# spc_lowresfilterfile resultat_division_150t "$audace(rep_images)/forgetlambda.dat" 1.1 2.5
# spc_lowresfilterfile resultat_division_150t "$audace(rep_images)/forgetlambda.dat" 1.1 2.5 {1. 2.} o 18
# La version tunée Benji pour le lissage de la RI ne demande que le nom du fichier de cette RI
####################################################################

proc spc_lowresfilterfile { args } {
   global conf
   global audace spcaudace
   if { [ llength $args ] == 7 || [ llength $args ] == 4 || [ llength $args ] == 1 } {
      set profile [ lindex $args 0 ]
      #set forgetlambda forgetlambda.dat
      set catalog_file "$spcaudace(reptelluric)/forgetlambda.dat"
      #set catalog_file $forgetlambda"
      #::console::affiche_resultat "$catalog_file\n"
      set ext_coef 1.1
      set regul_weight 10.
      set regul_list {1. 2.}
      lappend regul_list 1.
      set visu o
      set nechant 18
      if { [ llength $args ] > 1 } {
	 set catalog_file [ lindex $args 1 ]
	 set ext_coef [ lindex $args 2 ]
	 set regul_weight [ lindex $args 3 ]
	 if { [ llength $args ] == 4 } {
	    set regul_list [ list ]
	    lappend regul_list 1.
	    set visu o
	    set nechant 18
	 } else {
	    set regul_list [ lindex $args 4 ]
	    set visu [ lindex $args 5 ]
	    set nechant [ lindex $args 6 ]
	 }
      }

      #--- Ajustement du parametre de consideration des bords :
      if { [ spc_testbr $profile ] } { set spcaudace(pourcent_bord_run) $spcaudace(pourcent_bord_br) }

      #--- Ajoute a catalog_file la tranche de longueur d'onde de 0.5% du bleu :
      #-- Determine le lam_deb et lamb_fin pour selectionner en inverse le cote dans forgetlambda.dat :
      set flag_new_fl 1
      set pourcent_bord_bleu1 1.001
      # bleu2 : 1.02 ; 1.04
      set pourcent_bord_bleu2 1.01
      # lim_inf : 3500.
      set lamb_lim_inf 3600.
      # lim_sup : 4000. ; 3800.
      set lamb_lim_sup 3810.
      buf$audace(bufNo) load "$audace(rep_images)/$profile"
      set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      #-- Strategie inutilisee pour l'instant, mais interessante :
      set quotien [ expr $lamb_lim_sup/$crval1 ]
      if { $quotien<=1. } {
         set flag_new_fl 0
      } elseif { $quotien>$pourcent_bord_bleu2 } {
         # ::console::affiche_erreur "ICI\n"
         set lamb2 [ expr $pourcent_bord_bleu2*$lamb_lim_inf ]
      } else {
         set pourcent_bord_bleu2 [ expr 0.99*$quotien ]
         set lamb2 [ expr $pourcent_bord_bleu2*$lamb_lim_inf ]
      }

      #-- Modifie forgetlambda.dat en ajoutant les lignes dynamiques :
      #-- crval1--crval1*1.001 ; crval1*1.01--3810:
      if { $flag_new_fl==1 } {
         set cata_local "$audace(rep_images)/forget_lambda.dat"
         set file_in [ open "$catalog_file" r ]
         set file_out [ open "$cata_local" w+ ]
         fconfigure $file_out -translation crlf
         while { [ eof $file_in ] != 1 } {
            set ligne [ gets $file_in ]
            if { [ string first "3500" $ligne ] != 0 } {
               puts $file_out $ligne
            } else {
               set lamb1 [ expr $crval1*$pourcent_bord_bleu1 ]
               set lamb2 [ expr $crval1*$pourcent_bord_bleu2 ]
               if { $crval1<3600. } {
                  puts $file_out "$crval1 $lamb1"
                  puts $file_out "$lamb2 3600."
                  puts $file_out "3665. $lamb_lim_sup"
               } else {
                  puts $file_out "$crval1 $lamb1"
                  puts $file_out "$lamb2 $lamb_lim_sup"
               }
            }
         }
         close $file_out
         close $file_in
      }

      # ::console::affiche_erreur "coeff regul : $regul_weight ; liste : $regul_list\n"
      #--- Filtrage du profil :
      if { $flag_new_fl==1 } {
         set resultat1 [ spc_piecewiselinearfilter $profile $ext_coef $regul_weight auto $cata_local $nechant $regul_list $visu ]
         file delete -force "$cata_local"
      } else {
         set resultat1 [ spc_piecewiselinearfilter $profile $ext_coef $regul_weight auto $catalog_file $nechant $regul_list $visu ]
      }
      set filename [ spc_rmneg "$resultat1" ]
      file delete -force "$audace(rep_images)/$resultat1$conf(extension,defaut)"
      set spcaudace(pourcent_bord_run) $spcaudace(pourcent_bord)
      return $filename
   } else {
      ::console::affiche_erreur "Usage: spc_lowresfilterfile profile ? fichier_catalogue ? ext_coef ? regul_weight ?  options : regul_list ? visu ? nechant ?\n\n"
      return ""
   }
}
#***************************************************************************************#



########################################################################################
# Procedure de lissage d'un profil basse resolution typiquement un résultat de division, supposé calibré linéairement,
# via une fonction linéaire par morceaux en ne retenant que les données correspondant à des longueurs d'ondes spécifiées
# via une liste (lambda_list) donnée en argument.
# Auteur : Patrick LAILLY
# Date creation : 01-12-2008
# Date modification : 01-12-2008
# Algo : ajustement par moindres carrés des données (résultat division) par une fonction
# lineaire par morceaux.
# Le parametre nechant definit la largeur des intervalles sur lesquels la fonction est lineaire
# (ce parametre n'a pas beaucoup d'importance tant qu'il n'est pas trop grand, la valeur 20
# semblant pouvoir traiter l'essentiel des situations; donner a ce parametre une valeur
# petite n'a pas d'autre incidence que d'augmenter le temps de calcul) : d'ailleurs l'algorithme
# modifie legerement la valeur choisie au depart afin de minimiser les effets de bord. Ne pas
# donner cependant une valeur inferieure a 18. Le
# filtrage est fondamentalement assure par l'application d'une regularisation (precisement on
# penalise la norme L^2 de la fonction derivee seconde du profil lisse), la "force" de cette
# regularisation etant definie par le parametre regul_weight ( plus sa valeur est grande plus on
# lisse). La valeur 1. correspond a un faible lissage et la valeur 10000. a un fort lissage.
# Si l'on souhaite un lissage variable en fonction de la longueur d'onde on peut utiliser
# l'argument liste_regul : cette liste donne les valeurs relatives du poids de regularisation
# pour differentes longueurs d'ondes. Soulignons qu'il s'agit de valeurs relatives : seules
# sont pris en compte le rapport entre les differentes valeurs de la liste, la force globale de
# la regularisation etant geree par le parametre regul_weight. A titre d'exemple
# - une liste a un element correspond a une regularisation uniforme
# - une liste a deux elements correspond a une regularisation variable lineairement, les valeurs
# dans la liste definissant les variations relatives du poids de regularisation aux bornes de
# l'intervalle de longueurs d'ondes considerees
# - une liste a trois elements correspond a une regularisation variable, les valeurs
# dans la liste definissant les variations relatives du poids de regularisation pour la longueur
# d'onde minimum, pour la longueur d'onde centrale et pour la longueur d'onde maximale
# - etc.
#
# Le parametre visu permet de s'assurer visuellement de la qualite du resultat et donne
# les échantillons pris en compte (ce sont ceux pour lesquels  la courbe verte prend une valeur
# non nulle.
#
# Arguments : fichier .fit du profil de raie, liste donnant les longueurs d'ondes à prendre en compte, regul_weight,
# liste_regul, visu (o ou n), nechant
#
# Exemple: spc_lowresfilterlist resultat_division_150t_linear.fit {3660. 3688. 3847. 3909. 3989. 4158. 4246. 4415. 4583. 4743. 4965. 5346. 5745. 5807. 6300. 6640. 7013. 7386. 7538. 7740. } 2.5 {1. 1. 10000. 1000000. 500000. 10000. 1000.} o 18
####################################################################

proc spc_lowresfilterlist {args } {
   global conf
   global audace
   if { [ llength $args ] == 6 } {
      set profile [ lindex $args 0 ]
      set lambda_list [ lindex $args 1 ]
      set regul_weight [ lindex $args 2 ]
      set regul_list [ lindex $args 3 ]
      if { [ llength $args ] == 4 } {
	 set visu o
	 set nechant 18
      } else {
	 set visu [ lindex $args 4 ]
	 set nechant [ lindex $args 5 ]
      }
      set ext_coef 1.
      set filename [ spc_piecewiselinearfilter $profile $ext_coef $regul_weight manu $lambda_list $nechant $regul_list $visu ]
      return [ file rootname $filename ]
   } else {
      ::console::affiche_erreur "Usage: spc_lowresfilterfile profile ? lambda_list ? regul_weight ? regul_list ? options : visu ? nechant ?\n\n"
      return ""
   }
}

####################################################################
# Procedure d'ajustement de la largeur (nechant) des morceaux utilis?s
# dans spc_pwlri et spc_pwlfilter pour minimiser les effets de bords
# Auteur : Patrick LAILLY
# Date creation : 08-05-2007
# Date modification : 1-11-2008
# Arguments : longueur liste intensite non nulle, valeur approx nechant
# cette derniere est supposee superieure ou egale a 18
####################################################################

proc ajust_interv {args } {
   global conf
   global audace
   if { [ llength $args ]==2 } {
      set len [ lindex $args 0 ]
      set nechant [ lindex $args 1 ]
      if { $nechant < 18 } {
	 ::console::affiche_erreur "Usage:  dans ajust_interv le 2e arg doit etre superieur ou egal a 18 par securite\n\n"
	 return ""
      }
      set reste [ list ]
      for { set k [ expr $nechant - 6 ] } { $k <= [ expr $nechant + 6 ] } {incr k } {
	 set restek [ expr $len % $k ]
	 lappend reste $restek
      }
      set restetri [ lsort -integer -increasing $reste ]
      if { [ lindex $restetri 0 ] == 0 } {
	 set npos [ lsearch -exact $reste 0 ]
      } else {
	 set reste_max [ lindex $restetri 12 ]
	 set npos [ lsearch -exact $reste $reste_max ]
      }
      set nechant [ expr $npos + $nechant - 6 ]
      ::console::affiche_resultat "nechant ajuste = $nechant reste [ lindex $reste $npos ]\n"
      #::console::affiche_resultat "restes $restetri\n "
      return $nechant
   } else {
      ::console::affiche_erreur "Usage: ajust_interv nb echant profil ?largeur morceaux?\n\n"
      return ""
   }
}

####################################################################
# Procedure de calcul de la matrice B utilisee dans les algorithmes de
# lissage par des fonctions linÃ©aires morceaux (spc_pwl...)
#
# Auteur : Patrick LAILLY
# Date creation : 15-05-2007
# Date modification : 23-07-2007
#
#     ***************************************************
# l'appel de cette procedure meriterait d'etre sortie de la partie algo
# on s'epargnerait ainsi plusieurs calculs de la matrice B dans spc_pwlri
####################################################################

proc spc_calcmatB {args} {
   global conf
   global audace

   if { [ llength $args ]==2 } {
      set nechant [ lindex $args 0 ]
      set nbase [ lindex $args 1 ]
      #::console::affiche_resultat "fonc gener\n"

      #-- calcul de la fonction generatrice
      set vpre [ list ]
      set vtop [ list ]
      set vpost [ list ]
      lappend vtop 1.
      #lappend vpre 0.
      #set nechant1 [ expr $nechant-1 ]
      for {set i 0} {$i<$nechant} {incr i} {
	 set vi [ expr 1.*$i/$nechant ]
         lappend vpre $vi
      }
      for {set i 0} {$i<$nechant} {incr i} {
	 set vi [ lindex $vpre [ expr $nechant - $i -1] ]
         lappend vpost $vi
      }
      #lappend vpost 0.
      #::console::affiche_resultat "vpre=$vpre\n"
      #::console::affiche_resultat "vtop=$vtop\n"
      #::console::affiche_resultat "vpost=$vpost\n"
      #-- calcul de la matrice BT (B transposee)
      set listezeros [ list ]
      for {set i 0} {$i<$nechant} {incr i} {
	 lappend listezeros 0.
      }
      set B [ list ]
      #set BT [ list ]
      set listdeb [ list ]
      set listfin [ list ]
      for {set i 1} {$i<= [ expr $nbase -2 ]} {incr i} {
	 set listfin [ concat $listfin $listezeros ]
      }
      set BTi [ concat $vtop $vpost $listfin ]
      lappend B $BTi
      #::console::affiche_resultat "long 0 eme ligne BT [llength $BTi] \n"
      set JJ [ expr $nbase -2 ]
      for {set i 1} {$i<= $JJ} {incr i} {
	 set listdeb [ list ]
	 set listfin [ list ]
	 if { $i != 1 } {
	    for {set j 1} {$j<= [ expr $i - 1 ]} {incr j} {
	       set listdeb [ concat $listdeb $listezeros ]
	    }
	 }
	 if { $i != $JJ } {
	    for {set j 1} {$j<= [ expr $JJ - $i ]} {incr j} {
	       set listfin [ concat $listfin $listezeros ]
	    }
	 }
	 set BTi [concat $listdeb $vpre $vtop $vpost $listfin ]
	 #::console::affiche_resultat "long $i eme ligne BT [llength $listdeb] [llength $vpre] [llength $vtop] [llength $vpost] [llength $listfin]\n"
	 lappend B $BTi
      }
      # derniere ligne de B*
      set listdeb [ list ]
      set listfin [ list ]
      for {set i 1} {$i<= [ expr $nbase -2 ]} {incr i} {
	 set listdeb [ concat $listdeb $listezeros ]
      }
      set BTi [ concat $listdeb $vpre $vtop ]
      #::console::affiche_resultat "long derniere ligne BT [llength $BTi] \n"
      lappend B $BTi
      #::console::affiche_resultat "longueur BT : [llength $BT]\n"
      #::console::affiche_resultat "longueur ligne de BT : [llength [lindex $BT 1]]\n"

      # transposition de B*
      set B [ gsl_mtranspose $B ]
      #::console::affiche_resultat "longueur B : [llength $B]\n"
      #::console::affiche_resultat "longueur ligne de B : [llength [lindex $B 1]]\n"
      return $B
   } else {
      ::console::affiche_erreur "Usage: spc_calcmatB 2 arguments requis\n\n"
      return ""
   }
}
#*********************************************************************************#



####################################################################
# Procedure de lissage d'un profil basse resolution typiquement un résultat de division, #supposé calibré linéairement, via une fonction linéaire par morceaux en considerant comme
# donnee aberrante les echantillons situes a proximite de raies bien connues (raies
# telluriques, dioxygene,...)
# Auteur : Patrick LAILLY
# Date creation : 07-02-2008
# Date modification : 8-10-2010 (changement de definition du poids de regularisation)
# Algo : ajustement par moindres carrés des données (résultat division) par une fonction
# lineaire par morceaux. La procedure fonctionne

# ou bien en mode automatique auquel cas elle ne prend pas en compte les echantillons situes
# dans des intervalles de longueurs d'ondes definis dans le fichier forgetlambda.dat : ces echantillons sont censes etre potentiellement contamines par des raies d'absorbtion ou, de
# facon plus générale contenir des données aberrantes. Un coefficient d'extension de la largeur de ces intervalles donne la souplesse requise en cas de calibration imprecise.

# ou bien en mode manuel auquel cas l'utilisteur spécifie la liste des longueurs d'ondes (en
# Angstroems) où il souhaite prendre en compte l'information

# Le parametre nechant definit la largeur des intervalles sur lesquels la fonction est lineaire
# (ce parametre n'a pas beaucoup d'importance tant qu'il n'est pas trop grand, la valeur 20
# semblant pouvoir traiter l'essentiel des situations; donner a ce parametre une valeur
# petite n'a pas d'autre incidence que d'augmenter le temps de calcul) : d'ailleurs l'algorithme
# modifie legerement la valeur choisie au depart afin de minimiser les effets de bord. Ne pas
# donner cependant une valeur inferieure a 18. Le
# filtrage est fondamentalement assure par l'application d'une regularisation (precisement on
# penalise la norme L^2 de la fonction derivee seconde du profil lisse), la "force" de cette
# regularisation etant definie par le parametre regul_weight ( plus sa valeur est grande plus on
# lisse). La valeur 1. correspond a un faible lissage et la valeur 10000. a un fort lissage.
# Si l'on souhaite un lissage variable en fonction de la longueur d'onde on peut utiliser
# l'argument liste_regul : cette liste donne les valeurs relatives du poids de regularisation
# pour differentes longueurs d'ondes. Soulignons qu'il s'agit de valeurs relatives : seules
# sont pris en compte le rapport entre les differentes valeurs de la liste, la force globale de
# la regularisation etant geree par le parametre regul_weight. A titre d'exemple
# - une liste a un element correspond a une regularisation uniforme
# - une liste a deux elements correspond a une regularisation variable lineairement, les valeurs
# dans la liste definissant les variations relatives du poids de regularisation aux bornes de
# l'intervalle de longueurs d'ondes considerees
# - une liste a trois elements correspond a une regularisation variable, les valeurs
# dans la liste definissant les variations relatives du poids de regularisation pour la longueur
# d'onde minimum, pour la longueur d'onde centrale et pour la longueur d'onde maximale
# - etc.
#
# Le parametre visu permet de s'assurer visuellement de la qualite du resultat et donne
# les échantillons pris en compte (ce sont ceux pour lesquels  la courbe verte prend une valeur
# non nulle.
# Arguments : fichier .fit du profil de raie, coefficient d'extension de la
# largeur de ces intervalles, regul_weight, mode, (fichier .dat donnant les intervalles de
# longueur d'ondes ou sont localisees les raies perturbatrices (mode auto) ou bien liste des
# longueurs d'ondes a prendre en compte(mode manu), nechant, liste_regul, visu)
# Les parametre entre parentheses peuvent etre en bloc omis.
####################################################################

proc spc_piecewiselinearfilter { args } {
   global conf
   global audace spcaudace
   #global spc_audace(nul_pcent_intens)
   #- Depuis 8-10-2010
   # set nul_pcent_intens .65
   #- Depuis de 20140622 :
   set nul_pcent_intens 0.25


   # regul_weight est le poids de régularisation
   # nechant est le nombre d'intervalles contenus dans un macro intervalle (morceau linéaire de la fonction d'ajustemet)
   # visu (=o ou n) indique si l'on veut ou non une visualisation du resultat

   # Exemples :

   # spc_piecewiselinearfilter resultat_division_150t_linear.fit 1.1 1.

   # spc_piecewiselinearfilter resultat_division_150t_linear.fit 1.1 2.5 auto "$audace(rep_images)/forgetlambda.dat" 18 {1. 1. 10000. 1000000. 500000. 10000. 1000.} o
   # spc_piecewiselinearfilter resultat_division_150t_linear.fit 1.1 2.5 auto "$spcaudace(reptelluric)/forgetlambda.dat" 18 {1. 1. 10000. 1000000. 500000. 10000. 1000.} o

   # spc_piecewiselinearfilter resultat_division_150t_linear.fit 1.1 2.5 manu {3660. 3688. 3847. 3909. 3989. 4158. 4246. 4415. 4583. 4743. 4965. 5346. 5745. 5807. 6300. 6640. 7013. 7386. 7538. 7740. } 18 {1. 1. 10000. 1000000. 500000. 10000. 1000.} o


   set nb_args [ llength $args ]
   #set mode1 "auto"
   set mode1 auto
   set mode2 manu
   if { $nb_args==8 || $nb_args==3 } {

      set filenamespc [ lindex $args 0 ]
      set coefextens [ lindex $args 1 ]
      set regul_weight [ lindex $args 2 ]
      if { $nb_args==8 } {
	 set mode [ lindex $args 3 ]
	 if { $mode == $mode1} {
	    set fileforgetlambda [ lindex $args 4 ]
	    ::console::affiche_resultat "spc_piecewiselinearfilter : fichier forgetlambda : $fileforgetlambda\n"
	    #set fileforgetlambda "$audace(rep_images)/$fileforgetlambda"
	    #::console::affiche_resultat "spc_piecewiselinearfilter : fichier forgetlambda : $fileforgetlambda\n"
	 } elseif { $mode == $mode2} {
	    set listepoints [ lindex $args 4 ]
	    set nbpoints [ llength $listepoints ]
	 } else {
	    ::console::affiche_erreur "Usage: dans spc_piecewiselinearfilter le 4eme parametre doit etre manu ou auto  \n\n"
	 }
	 set nechant [ lindex $args 5 ]
	 set listeregul [ lindex $args 6 ]
	 set visu [ lindex $args 7 ]
      }
      if { $nb_args==3 } {
	 set mode auto
	 #set fileforgetlambda "$audace(rep_images)/forgetlambda.dat"
	 set nechant 20
	 set listeregul [ list ]
	 lappend listeregul 1.
	 set visu o
      }
      if { $regul_weight < 0. } {
      	 ::console::affiche_erreur "Usage: dans spc_piecewiselinearfilter le poids de regularisation doit etre positif \n\n"
      	 return ""
      }
      set regul_weight [ expr exp(log(10.) * $regul_weight) -1. ]
      ::console::affiche_resultat "spc_piecewiselinearfilter : poids de regularisation : $regul_weight\n"
      #--- Extraction des donnees :
      #--- Gestion des profils selon la loi de calibration :
      buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      #-- Renseigne sur les parametres de l'image :
      set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
      set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
      if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
         set crpix1 [ lindex [ buf$audace(bufNo) getkwd "CRPIX1" ] 1 ]
      } else {
         set crpix1 1
      }
      set contenu [ spc_fits2data $filenamespc ]
      set abscissesorig [ lindex $contenu 0 ]
      set ordonneesorig [ lindex $contenu 1 ]
      set lenorig [llength $ordonneesorig ]
      ::console::affiche_resultat "dispersion = $cdelt1  [ expr [lindex $abscissesorig 1 ]- [lindex $abscissesorig 0 ]]\n"
      ::console::affiche_resultat "crval1= $crval1 [lindex $abscissesorig 0 ]\n"
      if { $naxis1 != $lenorig } {
         ::console::affiche_erreur "naxis1 = $naxis1 doit etre egal a $lenorig\n"
      }

      #--- Supprimer l'appel a spc_findnul quand on est en mode manuel (appel qui n'a pas sa raison d'etre et qui provient du poids du passe :
      if { $mode=="auto" } {
         #-- elimination des termes nuls au bord : spc_findnnul liste_intensites ?fraction de continuum (0.85)?
         set limits [ spc_findnnul $ordonneesorig ]
         # i_inf est le No (suivant la numerotation des listes Tcl) du premier element non nul
         # i_sup est le No (suivant la numerotation des listes Tcl) du dernier element non nul
         set i_inf [ lindex $limits 0 ]
         set i_sup [ lindex $limits 1 ]
      } else {
         set i_inf 0
         set i_sup [ expr $naxis1-1 ]
      }

      # set nechant_util [ expr $i_sup - $i_inf +1 ]
      #::console::affiche_resultat "limites profil utile $i_inf $i_sup\n"
      set nmilieu0 [ expr $i_sup -$i_inf +1 ]
      #-- nmilieu0 est le nb d'echantillons non nuls dans la partie effective du profil
      set lambdamin [ lindex $abscissesorig $i_inf ]
      set lambdamax [ lindex $abscissesorig $i_sup ]
      set ecartlambda [ expr $lambdamax-$lambdamin ]
      ::console::affiche_resultat "lambdamin= $lambdamin ; lambdamax= $lambdamax\n"

      # modification des listes pour se limiter a l'intervalle lambdamin lambdamax et calcul de l'intensite moyenne
      set abscisses [ list ]
      set ordonnees [ list ]
      #set poids [ list ]
      set intens_moy 0.
      for { set i $i_inf } { $i<=$i_sup } { incr i } {
	 set xi [ lindex $abscissesorig $i ]
  	 set yi [ lindex $ordonneesorig $i ]
  	 lappend abscisses $xi
  	 lappend ordonnees $yi
	 #lappend poids 1.
  	 set intens_moy [ expr $intens_moy +$yi ]
      }
      set intens_moy [ expr $intens_moy/($nmilieu0*1.) ]
      # intens_moy est la valeur moyenne de l'intensite
      ::console::affiche_resultat "intensite moyenne : $intens_moy \n"
      # normalisation de regul_weight en fonction de l'intensite moyenne du profil
      set regul_weight [ expr $regul_weight * $intens_moy / 600000. ]

      #-- ajustement de nechant pour minimiser les effets de bord et prolongement "accordingly" du profil
      #- Court-circuit de ajust_interv pour gerer de plus petits intervalles $nechant (20140622) :
      # set nechant [ ajust_interv [ expr $nmilieu0-1 ] $nechant ]
      ## set ordmoyen [ lindex $ordonnees [ expr $nmilieu0 -1 ] ]
      set o1 [ lindex $ordonnees [ expr $nmilieu0 -1 ] ]
      set o2 [ lindex $ordonnees [ expr $nmilieu0 -2 ] ]
      set ordmoyen [ expr .5*( $o1+ $o2 ) ]

      if { [ expr ( $nmilieu0 - 1 ) % $nechant ] !=0  } {
	 set nmilieu [ expr (( $nmilieu0 -1 ) /$nechant + 1 ) * $nechant +1]
	 for { set i 1 } { $i<= [ expr $nmilieu - $nmilieu0 ] } { incr i } {
	    lappend abscisses [ expr [ lindex $abscisses [ expr $lenorig - 1 ] ] + $cdelt1 ]
	    lappend ordonnees $ordmoyen
	 }
      } else {
	 set nmilieu $nmilieu0
      }

      set len [ llength $ordonnees ]
      set len_1 [ expr $len -1 ]
      if {$len != $nmilieu } {
	 ::console::affiche_erreur "Longueur profil utile $len $nmilieu\n"
	 return ""
      }
      ::console::affiche_resultat "Augmentation de la partie utile du profil $len au lieu de $nmilieu0 echantillons\n"
      set lambdamax [ expr $lambdamin+$len_1*$cdelt1 ]
      set ninter [expr int($len/$nechant)]
      set nbase [expr $ninter+1]

      #calcul matrice B

      set B [ spc_calcmatB $nechant $nbase ]

      #construction des poids sur les intensites
      set poids [ list ]
      if { $mode== $mode1 } {
	 for { set i 0} { $i<$len } { incr i } {
	    lappend poids 1.
	 }
	 ::console::affiche_resultat "spc_piecewiselinearfilter : fichier forgetlambda : $fileforgetlambda\n"
	 set inputfile [open "$fileforgetlambda" r]
	 set contents [split [read $inputfile] \n]
	 close $inputfile

	 set kk 0
	 foreach ligne $contents {
	    set lambda1 [ lindex $ligne 0 ]
	    set lambda2 [ lindex $ligne 1 ]
	    #::console::affiche_resultat " $lambda1 $lambda2   $lambdamax \n"
	    if { $lambda1!="" } {
	       # for { set kk 0 } { $kk< $lforgetlambda } { incr kk } {}
	       #::console::affiche_resultat " $kk $lambda1 $lambda2 \n"
	       # prise en compte de l'extension des intervalles
	       set lambdacentre [ expr ( $lambda1 + $lambda2 )*.5 ]
	       set larginter [ expr ( $lambda2 - $lambda1 ) * $coefextens ]
	       set lambda1 [ expr $lambdacentre - $larginter * .5 ]
	       set lambda2 [ expr $lambdacentre + $larginter * .5 ]
	       if { $lambda2 >= $lambdamin && $lambda1 <= $lambdamax } {
		  set deb [ expr max ($lambda1,$lambdamin) ]
		  set fin [ expr min ($lambda2,$lambdamax) ]
		  set iideb [ expr int (($deb - $lambdamin)/$cdelt1) ]
		  #set iideb [ expr int (($deb - $lambdamin)/$cdelt1) +1 ]
		  #set iifin [ expr int (($fin - $lambdamin)/$cdelt1) ]
		  set iifin [ expr min ( $len_1, int (($fin - $lambdamin)/$cdelt1) +1) ]
		  #::console::affiche_resultat " $iideb $iifin \n"
		  for { set i $iideb } { $i <= $iifin } { incr i } {
		     set poids [ lreplace $poids $i $i 0. ]
		  }
	       }
	       incr kk
	    }
	 }
	 set lforgetlambda $kk
	 #::console::affiche_resultat "nb d'intervalles forgetlambda $lforgetlambda \n"
      } else {
	 for { set i 0 } { $i<$len } { incr i } {
	    lappend poids 0.
	 }
	 ::console::affiche_resultat "lambdamin= $lambdamin lambdamax=$lambdamax \n"
	 ::console::affiche_resultat "liste des longueurs d'ondes definies par l'utilisateur :\n"
	 for { set i 0 } { $i < $nbpoints } { incr i } {
	    set lambda_i [ lindex $listepoints $i ]
	    #::console::affiche_resultat "$lambda_i \n"
	    if { $lambda_i > $lambdamax || $lambda_i < $lambdamin } {
	       ::console::affiche_erreur "dans la liste de points la valeur $lambda_i n'appartient pas à la partie exploitable du spectre\n\n"
	       return ""
	    }
	    # ci-dessous le calcul n'est valide que pour un spectre calibre lineairement
	    set j [ expr round (($lambda_i-$lambdamin)*$nmilieu / $ecartlambda) -1 ]
	    # modif Pat 8 mai 2011
	    if { $j < $len } {
	       if { $j >= 0 } {
	 	   set poids [ lreplace $poids $j $j 1. ]
	       } else {
	 	   set poids [ lreplace $poids 0 0 1. ]
	 	   }
	    } else {
	       ::console::affiche_erreur "j= $j len= $len\n\n"
	       return ""
	    }
	    # fin modif Pat

	 }
      }
      # prise en compte de la regularisation

      # normalisation de listeregul
      set longregul [ llength $listeregul ]
      #::console::affiche_resultat "longueur listeregul $longregul \n"

      if { $longregul > 1 } {
	 set somregul 0.
	 for {set i 0} {$i<$longregul} {incr i} {
	    set somregul [ expr $somregul + [ lindex $listeregul $i ] ]
	 }
	 for {set i 0} {$i<$longregul} {incr i} {
	    set regulnorm [ expr [ lindex $listeregul $i ] / $somregul ]
	    set listeregul [ lreplace $listeregul $i $i $regulnorm ]
	 }

	 # calcul des poids de regularisation sur les nbase noeuds des macrointervalles
	 set nlongregul [ expr $longregul -1 ]
	 #set undersampling [ expr ($ninter*1.)/($nlonginter*1.) ]
	 set undersampling [ expr ($ninter*1.)/($nlongregul*1.) ]
	 set ilonginter 0
	 set ilonginterp1 1
	 set listeregulfin [list ]
	 for { set ibase 0 } { $ibase<$nbase } {incr ibase} {
	    if {$ibase > [ expr ($ilonginter +1) * $undersampling ] } {
	       incr ilonginter
	       incr ilonginterp1
	    }
	    # interpolation lineaire entre les donnees associees a ilonginter et ilonginterp1
	    set intensmoins [ lindex $listeregul $ilonginter ]
	    set intensplus [ lindex $listeregul $ilonginterp1 ]
	    set num  [ expr  ($intensplus - $intensmoins)*1. ]
	    set den  $undersampling
	    set pente [ expr $num / $den ]
	    set inten [ expr $intensmoins*1. + $pente * ( $ibase*1. - $ilonginter * $undersampling ) ]
	    #::console::affiche_resultat " ndeb= $ndeb lambda1= [ lindex $intensites_orig $ndeb ] lambda2= [ lindex $intensites_orig $ndebp1 ]\n"
	    lappend listeregulfin $inten
	 }
      }

      set yy $ordonnees
      set listezeros [ list ]
      for {set i 0} {$i<=$ninter} {incr i} {
	 lappend listezeros 0.
      }
      if { $longregul > 1 } {
	 for { set i 0} { $i< [expr $ninter-1] } { incr i } {
	    set ip1 [ expr $i + 1 ]
	    set ip2 [ expr $i + 2 ]
	    lappend poids [ expr  $regul_weight * [ lindex $listeregulfin $ip1 ] ]
	    set Bi $listezeros
	    set Bi [ lreplace $Bi $i $i -1. ]
	    set Bi [ lreplace $Bi $ip1 $ip1 2. ]
	    set Bi [ lreplace $Bi $ip2 $ip2 -1. ]
	    lappend B $Bi
	    lappend yy 0.
	 }

      } else {
	 for { set i 0} { $i< [expr $ninter-1] } { incr i } {
	    set ip1 [ expr $i + 1 ]
	    set ip2 [ expr $i + 2 ]
	    lappend poids $regul_weight
	    set Bi $listezeros
	    set Bi [ lreplace $Bi $i $i -1. ]
	    set Bi [ lreplace $Bi $ip1 $ip1 2. ]
	    set Bi [ lreplace $Bi $ip2 $ip2 -1. ]
	    lappend B $Bi
	    lappend yy 0.
	 }
      }

      ::console::affiche_resultat "longueur B : [llength $B] [llength $yy] [llength $poids]\n"

      #-- calcul de l'ajustement
      set result [ gsl_mfitmultilin $yy $B $poids ]
      #-- extrait le resultat
      set coeffs [ lindex $result 0 ]
      set chi2 [ lindex $result 1 ]
      set covar [ lindex $result 2 ]
      set riliss [ gsl_mmult $B $coeffs ]
      #set riliss0 [ gsl_mmult $B $coeffs ]
      set riliss1 [ list ]
      for {set i 0} {$i<$len} {incr i} {
	 lappend riliss1 [ lindex $riliss $i ]
	 #lappend riliss1 [ lindex $riliss0 $i ]
      }

      #-- mise a zero d'eventuels echantillons tres petits
      set zero 0.
      set seuil_min [ expr $intens_moy*$nul_pcent_intens/100. ]
      for { set i 0 } {$i<$nmilieu0} {incr i} {
	 if { [ lindex $riliss $i ] < $seuil_min } { set riliss [ lreplace $riliss $i $i $zero ] }
      }

      #--- Rajout des valeurs nulles en début et en fin pour retrouver la dimension initiale du fichier de départ :
      set len_ini $lenorig
      set len_cut $nmilieu0
      set nb_insert_sup [ expr $lenorig-$i_inf-$nmilieu0 ]
      for { set i 1 } { $i<=$nb_insert_sup } { incr i } {
	 set riliss [ linsert $riliss [ expr $len_cut+$i ] 0.0 ]
	 #set riliss1 [ linsert $riliss1 [ expr $len_cut+$i ] 0.0 ]
	 #set poids2 [ linsert $poids2 [ expr $len_cut+$i ] 0.0 ]
	 set poids [ linsert $poids [ expr $len_cut+$i ] 0.0 ]
      }
      for { set i 0 } { $i<$i_inf } { incr i } {
	 set riliss [ linsert $riliss 0 0.0 ]
	 #set riliss1 [ linsert $riliss1 0 0.0 ]
	 set poids [ linsert $poids 0 0.0 ]
	 #set poids2 [ linsert $poids2 0 0.0 ]
      }
      set intmoy [ expr $intens_moy *.1 ]
      for { set i 0 } { $i< [ llength $riliss ] } { incr i } {
	 set poidsi [ expr [ lindex $poids $i ] * $intmoy ]
	 set poids [ lreplace $poids $i $i $poidsi ]
      }
      #set lriliss_1 [ expr [ llength $riliss ] -1 ]
      #set poids [ lreplace $poids $lriliss_1 $lriliss_1 0 ]
      ::console::affiche_resultat "Nombre d'éléments traités : [ llength $riliss ]\n"

      #--- Affichage du resultat :
      if { $visu=="o" } {
	 ::plotxy::clf
	 ::plotxy::figure 1
	 ::plotxy::plot $abscissesorig $riliss r 1
         ::plotxy::hold on
	 #::plotxy::plot $abscissesorig $riliss1 g 1
	 ::plotxy::hold on
         ::plotxy::plot $abscissesorig $ordonneesorig b 0
	 ::plotxy::hold on
	 ::plotxy::plot $abscissesorig $poids g 0
         ::plotxy::plotbackground #FFFFFF
         ##::plotxy::xlabel "x"
	 ##::plotxy::ylabel "y"
         ::plotxy::title "bleu : original; rouge : lissage; vert : poids"
      }
      #--- Crée le fichier fits de sortie
      set abscisses $abscissesorig
      set filename [ file rootname $filenamespc ]

      buf$audace(bufNo) load "$audace(rep_images)/$filename"
      buf$audace(bufNo) setkwd [ list "CRPIX1" $crpix1 double "Reference pixel" "pixel" ]
      set k 1
      foreach x $abscisses {
	 buf$audace(bufNo) setpix [list $k 1] [ lindex $riliss [ expr $k-1 ] ]
         incr k
      }
      #-- Sauvegarde du résultat :
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/${filename}_lin$conf(extension,defaut)"
      buf$audace(bufNo) bitpix short
      ::console::affiche_resultat "Fichier fits sauvé sous ${filename}_lin$conf(extension,defaut)\n"
      set file_result [ spc_passebas ${filename}_lin$conf(extension,defaut) 3 ]
      file delete -force "$audace(rep_images)/${filename}_lin$conf(extension,defaut)"
      # return ${filename}_lin_pbas$conf(extension,defaut)
      return $file_result
   } else {
      ::console::affiche_erreur "Usage: spc_piecewiselinearfilter fichier_profil.fit ? coef_extension ? poids regularisation ? forgetlambda.dat ? nechant ? liste_regul ? visualisation (o/n)? \n\n"
      return ""
   }
}
#**********************************************************************************************#




####################################################################
# Procedure d'extraction du continuum
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-10-2010
# Date modification : 03-10-2010
# Arguments : fichier .fit du profil de raies
# Algo : utilise
####################################################################

proc spc_extractcontew { args } {
   global conf
   global audace spcaudace
   set nbtranches 10

   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set fichier [ file rootname [ lindex $args 0 ] ]
      set taux_doucissage $spcaudace(taux_doucissage)
   } elseif { $nbargs==2 } {
      set fichier [ file rootname [ lindex $args 0 ] ]
      set taux_doucissage [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage : spc_extractcontew nom_profil_de_raies ?taux_doucissage_continuum(0.-10.)?\n\n"
      return ""
   }


   #--- Loi de calibration :
   buf$audace(bufNo) load "$audace(rep_images)/$fichier"
   set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
   set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
   set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
   set crpix1 [ lindex [ buf$audace(bufNo) getkwd "CRPIX1" ] 1 ]
   set largeur [ expr int($naxis1/$nbtranches) ]


   #--- Détermine 2 lmabdas du continuum ou sigma est petit :
   #-- Détermine les limites gauche et droite d'etude (valeurs != 0) :
   set limits [ spc_findnnul [ lindex [ spc_fits2data "$fichier" ] 1 ] ]
   set lambda_min [ spc_calpoly [ lindex $limits 0 ] $crpix1 $crval1 $cdelt1 0 0 ]
   set lambda_max [ spc_calpoly [ lindex $limits 1 ] $crpix1 $crval1 $cdelt1 0 0 ]

   #-- Filtrage passe bas :
   #set spectre_pbas [ spc_passebas "$fichier" ]
   #buf$audace(bufNo) load "$audace(rep_images)/$spectre_pbas"
   buf$audace(bufNo) load "$audace(rep_images)/$fichier"
   buf$audace(bufNo) window [ list [ lindex $limits 0 ] 1 [ lindex $limits 1 ] 1 ]

   #-- Détermine les écart-types de chaque tranches :
   set listresults ""
   for {set i 0} {$i<$nbtranches} {incr i} {
      if { $i==0 } {
         set zone [ list 1 1 $largeur 1 ]
      } else {
         set zone [ list [ expr $i*$largeur ] 1 [ expr ($i+1)*$largeur ] 1 ]
      }
      set result [ buf$audace(bufNo) stat $zone ]
      lappend listresults [ list [ lindex $result 4 ] [ lindex $result 5 ] $i ]
   }

   #-- Tri par ecart-type :
   set listresults [ lsort -increasing -real -index 1 $listresults ]
   set icontinuum [ lindex [ lindex $listresults 0 ] 0 ]

   #-- Calcul de la longueur d'onde de la tranche selectionnee :
   set no_tranche [ lindex [ lindex $listresults 0 ] 2 ]
   set no_pixel [ expr round($no_tranche*$largeur*1.) ]
   set lambdac1 [ expr round([ spc_calpoly $no_pixel $crpix1 $crval1 $cdelt1 0 0 ]) ]
   if { $lambdac1<$lambda_min } {
      set lambdac1 [ expr ceil([ spc_calpoly $no_pixel $crpix1 $crval1 $cdelt1 0 0 ]) ]
   } elseif { $lambdac1>$lambda_max } {
      set lambdac1 [ expr floor([ spc_calpoly $no_pixel $crpix1 $crval1 $cdelt1 0 0 ]) ]
   } else {
      set lambdac1 [ expr round([ spc_calpoly $no_pixel $crpix1 $crval1 $cdelt1 0 0 ]+10*$cdelt1) ]
      #-- Benji 20111005
   }

   set no_tranche [ lindex [ lindex $listresults 1 ] 2 ]
   set no_pixel [ expr round($no_tranche*$largeur*1.) ]
   set lambdac2 [ expr round([ spc_calpoly $no_pixel $crpix1 $crval1 $cdelt1 0 0 ]) ]
   if { $lambdac2<$lambda_min } {
      set lambdac2 [ expr ceil([ spc_calpoly $no_pixel $crpix1 $crval1 $cdelt1 0 0 ]) ]
   } elseif { $lambdac2>$lambda_max } {
      set lambdac2 [ expr floor([ spc_calpoly $no_pixel $crpix1 $crval1 $cdelt1 0 0 ]) ]
   } else {
      set lambdac2 [ expr round([ spc_calpoly $no_pixel $crpix1 $crval1 $cdelt1 0 0 ]+10*$cdelt1) ]
      #-- Benji 20111005
   }


   #--- Calcul deux longueurs proches des extrémités :
   set lambdab1 [ expr $crval1*1.0004 ]
   set lambdab2 [ expr $crval1*1.0007 ]
   set pixelr1 [ expr round($naxis1*0.979) ]
   set lambdar1 [ expr round([ spc_calpoly $pixelr1 $crpix1 $crval1 $cdelt1 0 0 ]) ]
   if { $lambdar1<$lambda_min } {
      set lambdar1 [ expr ceil([ spc_calpoly $pixelr1 $crpix1 $crval1 $cdelt1 0 0 ]) ]
   } elseif { $lambdar1>$lambda_max } {
      set lambdar1 [ expr floor([ spc_calpoly $pixelr1 $crpix1 $crval1 $cdelt1 0 0 ]) ]
   }
   set pixelr2 [ expr round($naxis1*0.993) ]
   set lambdar2 [ expr round([ spc_calpoly $pixelr2 $crpix1 $crval1 $cdelt1 0 0 ]) ]
   if { $lambdar2<$lambda_min } {
      set lambdar2 [ expr ceil([ spc_calpoly $pixelr2 $crpix1 $crval1 $cdelt1 0 0 ]) ]
   } elseif { $lambdar2>$lambda_max } {
      set lambdar2 [ expr floor([ spc_calpoly $pixelr2 $crpix1 $crval1 $cdelt1 0 0 ]) ]
   }


   #--- Extrait le continuum :
   ::console::affiche_prompt "Longueurs d'ondes retenues pour le continuum : $lambdab1, $lambdab2, $lambdac1, $lambdac2, $lambdar1, $lambdar2.\n"
   set spectre_result [ spc_piecewiselinearfilter "$fichier" 1. $taux_doucissage manu [ list $lambdab1 $lambdab2 $lambdac1 $lambdac2 $lambdar1 $lambdar2 ] 100 {1. 1.} 'n' ]

   #--- Traitement des résultats :
   set conti_spectre "${fichier}_conti"
   file rename -force "$audace(rep_images)/$spectre_result$conf(extension,defaut)" "$audace(rep_images)/$conti_spectre$conf(extension,defaut)"
   return $conti_spectre
}
#**********************************************************************************************#



####################################################################
# Procedure de lissage d'un profil spectral via une fonction polynomiale
# Auteur : Patrick LAILLY
# Date creation : 07-02-2008
# Date modification : 6-04-2008
# Algo : ajustement par moindres carrés des données (résultat division) par une fonction polynomiale
# L'ajustement se fait en 2 étapes : dans la premiere on estime l'ordre de grandeur des résidus (RMS des résidus).
# Ceci permet de détecter les données aberrantes (et notammant les restes de raies) : celles-ci sont recherchees automatiquement (absence de specification du dernier parametre taux_RMS) ou
# conformément aux spécifications de l'utilisateur (via la specification du dernier parametre
# taux_RMS). Dans ce cas  les données aberrantes sont définies  comme les données dont les résidus # sont en valeur absolue supérieurs au RMS précédemment calculé multiplié
# par le parametre tauxRMS.
# Les données aberrantes ne sont pas prises en compte dans la deuxième étape du lissage qui
# fournit alors la réponse instrumentale.
# elim en pour mille...................................3 erniers argument optionels
#si derlier arg specifie :pas de calcul automatique et les 2 arguments precedents n'ont pas #d'imporatnce
# Le parametre visu_RMS permet de controler visuellement la procedure de selection automatique des # donnees aberrantes. Enfin le controle de la qualite du resultat est donne via la courbe verte :
# les échantillons non pris en compte dans la deuxieme etape du lissage sont ceux pour lesquels la # la courbe verte prend une valeur nulle.
# Arguments : fichier .fit du profil de raie ndeg visus elim nbiter tauxRMS
####################################################################

proc spc_extractcont { args } {
    global conf
    global audace spcaudace
    #global spc_audace(nul_pcent_intens)
    set nul_pcent_intens .65
   # ndeg est le degré choisi pour le polynome (ce nombre doit etre inferieur a 5)

   # visu_RMS (=o ou n) indique si l'on veut ou non une visualisation du resultat
   # tauxRMS specifie l'amplitude des residus (en % de la moyenne RMS) a partir de laquelle
   # les echantillons sont consirérés comme associés à des résidus de raies (cas ou
   # l'utilisateur ne veut pas faire appel a la procedure automatique et specifier lui meme
   # le seuil de tri des données aberrantes)
   # Exemples :
   # spc_polynfilter resultat_division.fit 4 n 15 20 200


    set nb_args [ llength $args ]
    if { $nb_args<=6 } {
       if { $nb_args == 1 } {
          set filenamespc [ lindex $args 0 ]
          set ndeg $spcaudace(degpoly_cont)
          set visus "n"
          set elim 15
          set nbiter 20
       } elseif { $nb_args == 2 } {
          set filenamespc [ lindex $args 0 ]
          set ndeg [ lindex $args 1 ]
          set visus "n"
          set elim 15
          set nbiter 20
       } elseif { $nb_args == 3 } {
          set filenamespc [ lindex $args 0 ]
          set ndeg [ lindex $args 1 ]
          set visus [ lindex $args 2 ]
          set elim 15
          set nbiter 20
       } elseif { $nb_args==5 } {
          set filenamespc [ lindex $args 0 ]
          set ndeg [ lindex $args 1 ]
          set visus [ lindex $args 2 ]
          set elim [ lindex $args 3 ]
          set nbiter [ lindex $args 4 ]
       } elseif { $nb_args==6 } {
          set filenamespc [ lindex $args 0 ]
          set ndeg [ lindex $args 1 ]
          set visus [ lindex $args 2 ]
          set elim [ lindex $args 3 ]
          set nbiter [ lindex $args 4 ]
          set tauxRMS [ lindex $args 5 ]
       } else {
          ::console::affiche_erreur "Usage: spc_extractcont fichier_profil.fit ?degre polynome? ?visualisation (o/n)? ?taux pour 1000 d'echantillon eliminz (15)? ?nb iteration (20)? ?tauxRMS?\n\n"
          return ""
       }


       #--- Test des arguments :
	if { $ndeg>5 } {
           ::console::affiche_erreur "Le degré du polynome doit etre <=5.\nUsage: spc_extractcont fichier_profil.fit ?degre polynome? ?visualisation (o/n)? ?tauxRMS?\n\n"
           return 0
        }
	if { [ expr pow ([ expr (1000-$elim)*.001 ],$nbiter) ]<0.7 } {
           ::console::affiche_erreur "Le nb d'echantillons qui seront elimines est trop grand : diminuer elim et/ou nbiter.\nUsage: spc_extractcont fichier_profil.fit ?degre polynome? ?visualisation (o/n)? ?tauxRMS?\n\n"
           return 0
        }

        #--- Extraction des donnees :
        set contenu [ spc_fits2data $filenamespc ]
        set abscissesorig [ lindex $contenu 0 ]
        set ordonneesorig [ lindex $contenu 1 ]
        set lenorig [llength $ordonneesorig ]


	#-- elimination des termes nuls au bord
	set limits [ spc_findnnul $ordonneesorig ]
	set i_inf [ lindex $limits 0 ]
	set i_sup [ lindex $limits 1 ]
	set nmilieu0 [ expr $i_sup -$i_inf +1 ]
	#-- nmilieu0 est le nb d'echantillons non nuls dans la partie effective du profil
	set lambdamin [ lindex $abscissesorig $i_inf ]
	set lambdamax [ lindex $abscissesorig $i_sup ]
	set ecartlambda [ expr $lambdamax-$lambdamin ]
	set abscisses [ list ]
	set ordonnees [ list ]
	set xx [ list ]
	#set poids [ list ]
	set intens_moy 0.
	for { set i $i_inf } { $i<=$i_sup } { incr i } {
	   set xi [ lindex $abscissesorig $i ]
	   set xxi [ expr ($xi-$lambdamin)/$ecartlambda ]
	   set yi [ lindex $ordonneesorig $i ]
	   lappend abscisses $xi
	   lappend xx $xxi
	   lappend ordonnees $yi
	   #lappend poids 1.
	   set intens_moy [ expr $intens_moy +$yi ]
        }
	set intens_moy [ expr $intens_moy/($nmilieu0*1.) ]
	set intens_moy_2 [ expr $intens_moy*.5 ]
	# intens_moy est la valeur moyenne de l'intensite
	# ::console::affiche_resultat "intensite moyenne : $intens_moy \n"

	#calcul matrice B
	set B [ list ]
	for { set i 0 } { $i<$nmilieu0 } { incr i } {
	   set Bi [ list ]
	   for { set j 0 } { $j<=1 } { incr j } {
	      lappend Bi [ expr pow([ lindex $xx $i ],$j) ]
	   }
	   lappend B $Bi
        }
       # initialisation des poids
       set poids [ list ]
       for { set i $i_inf } { $i<=$i_sup } { incr i } {
	  lappend poids 1.
       }


       #-- calcul du 1er ajustement
       set result [ gsl_mfitmultilin $ordonnees $B $poids ]
       #-- extrait le resultat
       set coeffs [ lindex $result 0 ]
       set chi2 [ lindex $result 1 ]
       set covar [ lindex $result 2 ]
       set riliss1 [ gsl_mmult $B $coeffs ]
       set resid [ gsl_msub $ordonnees $riliss1 ]

       #-- evaluation et analyse des residus
       # ::console::affiche_resultat "longueur B : [llength $B]\n"
       # ::console::affiche_resultat "longueur riliss : [llength $riliss1]\n"
       set residtransp [ gsl_mtranspose $resid ]
       set rms_pat1  [ gsl_mmult $residtransp $resid ]
       set rms_pat [ lindex $rms_pat1 0 ]
       set rms_pat [ expr ($rms_pat/($nmilieu0*1.)) ]
       set rms_pat [expr sqrt($rms_pat)]
	set chi2init $chi2
       set constinit [ lindex $coeffs 0 ]
	set penteinit [ lindex $coeffs 1 ]
       set RMSinit $rms_pat
       set som_poids 0.
       set RMS_iter [ list ]
       set chi2_iter [ list ]
       set const_iter [ list ]
       set pente_iter [ list ]
       set num_iter [ list ]
       lappend RMS_iter 1.
       lappend chi2_iter 1.
       lappend const_iter 1.
       lappend pente_iter 1.
       lappend num_iter 0
       for {set i 0} {$i<$nmilieu0} {incr i} {
	  set som_poids [ expr $som_poids + [ lindex $poids $i ] ]
       }
       # ::console::affiche_resultat " $som_poids\n"
	# ::console::affiche_resultat "residu moyen (RMS) apres premiere etape : $rms_pat\n"

       if { $nb_args<=6 } {
	  for { set niter 1 } { $niter<=$nbiter } { incr niter } {
	     set resid_pond [ list ]
	     for {set i 0} {$i<$nmilieu0} {incr i} {
		set residi [ expr abs([ lindex $poids $i ]*[ lindex $resid $i ]) ]
		lappend resid_pond $residi
	     }

	     set residtri [ lsort -decreasing -real $resid_pond ]
	     set R [ list ]
	     set nnn [ list ]
	     #calcul fonction R(n)
	     #doit pouvoir etre simplifie : on ne veut que le dernier terme de R
	     for {set nn 0} {$nn<=$elim} {incr nn} {
		set n1 [ expr int($nn*$nmilieu0*.001)]
		# ::console::affiche_resultat " $n1\n"
		lappend nnn $nn
		lappend R [ expr [ lindex $residtri $n1 ]*100./$rms_pat ]
	     }


	     #selection du seuil de troncature

	     if { $nb_args < 6 } {
		set tauxRMS [ lindex $R $elim ]
	     }
	     # ::console::affiche_resultat " $tauxRMS\n"
	     #--calcul des nouveaux poids censes eliminer les residus de raies
	     set seuilres [ expr $rms_pat*$tauxRMS*.01 ]
	     #set poids [ list ]
	     set som_poids 0.
	     for {set i 0} {$i<$nmilieu0} {incr i} {
		#set poidsi [ expr $intens_moy*.5 ]
		set residi [ lindex $resid $i ]
		if { [ expr abs($residi) ]>=$seuilres } {
		   set poids [ lreplace $poids $i $i 0. ]
		   #::console::affiche_resultat " $som_poids\n"
		}
		set som_poids [ expr $som_poids + [ lindex $poids $i ] ]
	     }
	     # ::console::affiche_resultat " $som_poids\n"
	     set result [ gsl_mfitmultilin $ordonnees $B $poids ]
	     #-- extrait le resultat
	     set coeffs [ lindex $result 0 ]
	     set chi2 [ lindex $result 1 ]
	     set covar [ lindex $result 2 ]
	     set riliss1 [ gsl_mmult $B $coeffs ]
	     set resid [ gsl_msub $ordonnees $riliss1 ]
	     lappend chi2_iter [ expr $chi2/$chi2init ]
	     #lappend RMS_iter [ expr $chi2/$chi2init ]
	     lappend const_iter [ expr [ lindex $coeffs 0 ]/$constinit ]
	     lappend pente_iter [ expr [ lindex $coeffs 1 ]/$penteinit ]
	     lappend num_iter $niter
	  }
       }


       if { $visus == "o" } {
	  # graphique des QC
	  ::plotxy::clf
	  ::plotxy::figure 1
	  ::plotxy::plot $num_iter $chi2_iter r 0
	  ::plotxy::hold on
	  ::plotxy::plot $num_iter $const_iter b 0
	  ::plotxy::hold on
	  ::plotxy::plot $num_iter $pente_iter g 0
	  ::plotxy::xlabel " iterations "
	  ::plotxy::ylabel "evolution normalisee"
	  ::plotxy::title "QC : chi2 (r), constante (b), pente (v)"
       }


       #-- derniere etape du lissage
       for {set i 0} {$i<$nmilieu0} {incr i} {
	  #set poidsi [ expr $intens_moy*.5 ]
	  set residi [ lindex $resid $i ]
	  if { [ expr abs($residi) ]>=$seuilres } {
	     set poids [ lreplace $poids $i $i 0. ]
	  }
       }
       #calcul matrice B
       set B [ list ]
       # ::console::affiche_resultat "\n"

       for { set i 0 } { $i<$nmilieu0 } { incr i } {
	  set Bi [ list ]
	  for { set j 0 } { $j<=$ndeg } { incr j } {
	     lappend Bi [ expr pow([ lindex $xx $i ],$j) ]
	  }
	  lappend B $Bi
       }
       set riliss [ list ]
       set result [ gsl_mfitmultilin $ordonnees $B $poids ]
       #-- extrait le resultat
       set coeffs [ lindex $result 0 ]
       set chi2 [ lindex $result 1 ]
       set covar [ lindex $result 2 ]
       set riliss [ gsl_mmult $B $coeffs ]

       #-- evaluation et analyse des residus
       set resid [ gsl_msub $ordonnees $riliss ]
       # ::console::affiche_resultat "longueur B : [llength $B]\n"
       # ::console::affiche_resultat "longueur riliss : [llength $riliss]\n"
       set residtransp [ gsl_mtranspose $resid]

       for { set i 0 } { $i<$nmilieu0 } { incr i } {
	  set residi [ expr [ lindex $resid $i ]*[ lindex $poids $i ] ]
	  set resid [ lreplace $resid $i $i $residi ]
       }

       #il serait peut etre judicieux de faire intervenir le chi2

       set rms_pat1  [ gsl_mmult $residtransp $resid ]
       set rms_pat [ lindex $rms_pat1 0 ]
       set rms_pat [ expr ($rms_pat/($som_poids)) ]
       set rms_pat [expr sqrt($rms_pat)]
       # ::console::affiche_resultat "Residu moyen (RMS) apres deuxieme etape : $rms_pat\n"

       #normalisation des poids pour la visu
       for { set i 0 } { $i<$nmilieu0 } { incr i } {
	  set poidsi [ expr [ lindex $poids $i ]*$intens_moy ]
	  set poids [ lreplace $poids $i $i $poidsi ]
       }

	#-- mise a zero d'eventuels echantillons tres petits
	set zero 0.
	set seuil_min [ expr $intens_moy*$nul_pcent_intens/100. ]
	for { set i 0 } {$i<$nmilieu0} {incr i} {
	   if { [ lindex $riliss $i ] < $seuil_min } {
	      set riliss [ lreplace $riliss $i $i $zero ]
	   }
        }


       #--- Rajout des valeurs nulles en début et en fin pour retrouver la dimension initiale du fichier de départ :
       set len_ini $lenorig
       set len_cut $nmilieu0
       set nb_insert_sup [ expr $lenorig-$i_inf-$nmilieu0 ]
       for { set i 1 } { $i<=$nb_insert_sup } { incr i } {
	  set riliss [ linsert $riliss [ expr $len_cut+$i ] 0.0 ]
	  #set nouvpoids1 [ linsert $nouvpoids1 [ expr $len_cut+$i ] 0.0 ]
       }
       for { set i 0 } { $i<$i_inf } { incr i } {
	  set riliss [ linsert $riliss 0 0.0 ]
	  #set nouvpoids1 [ linsert $nouvpoids1 0 0.0 ]
       }

       # ::console::affiche_resultat "Nombre d'éléments traités : [ llength $riliss ]\n"



       #--- CrÃ©e le fichier fits de sortie
       set abscisses $abscissesorig
       set filename [ file rootname $filenamespc ]

       buf$audace(bufNo) load "$audace(rep_images)/$filename"
       set k 1
       foreach x $abscisses {
	  buf$audace(bufNo) setpix [list $k 1] [ lindex $riliss [ expr $k-1 ] ]
	  incr k
       }
       #-- Sauvegarde du rÃ©sultat :
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save "$audace(rep_images)/${filename}_conti$conf(extension,defaut)"
       buf$audace(bufNo) bitpix short
       ::console::affiche_resultat "Fichier fits sauvé sous ${filename}_conti$conf(extension,defaut)\n"


       #--- Affichage du resultat :
       if { $visus == "o" } {
	  #::plotxy::clf
	  ::plotxy::figure 2
	  ::plotxy::plot $abscissesorig $riliss r 1
	  #::plotxy::plot $abscissesorig $riliss1 o 1
	  ::plotxy::hold on
	  ::plotxy::plot $abscissesorig $ordonneesorig ob 0
	  ::plotxy::hold on
	  ::plotxy::plot $abscissesorig $poids g 0
	  ::plotxy::plotbackground #FFFFFF
	  ##::plotxy::xlabel "x"
	  ##::plotxy::ylabel "y"
	  ::plotxy::title "bleu : original ; rouge : lissage par polynome de degre $ndeg"
       }

       #--- Traitement des resultats :
       return ${filename}_conti
    } else {
       ::console::affiche_erreur "Usage: spc_extractcont fichier_profil.fit ?degre polynome? ?visualisation (o/n)? ?tauxRMS?\n\n"
    }
}
#****************************************************************#



#================================ SPC_DRY ===========================================#


####################################################################
# Procedure de modelisation du spectre de l'eau
# Auteur : Patrick LAILLY
# Date creation : 18-10-07
# Date modification : 05-06-08

# Description :
# Cette procedure cree un fichier .fit modelisant le spectre en absorbtion de l'eau sur un
# continuum d'amplitude 1. Ce fichier est echantillone en conformite avec le profil donne par
# l'utilisateur. Il fait apparaitre des raies de l'eau creusees en conformite avec les rÃ©sultats
# donnÃ©s, sur le profil utilisateur, par spc_fwhmo. Le profil utilisateur doit bien
# entendu avoir ete prealablement calibre sur les raies de l'eau...
#
# Arguments :
# nom fichier spectre utilisateur, 1ere (sous)liste resultat de fwhmo, 2eme (sous)liste
# resultat de fwhmo, nom du fichier de sortie et, optionnel, nom du fichier contenant les
# infos  (longueur d'onde centrale et intensite de chaque raie) sur le spectre de l'eau tel que
# celui construit par Ch. Buil. Ce fichier est suppose etre dans le repertoire des images.

# Sorties :
# fichier donnant le spectre de l'eau modelisÃ© (et donc pret a servir de denominateur
# en vue de l'adoucissement des raies de l'eau)


# Remarques diverses
# On utilise ici une definition un peu particuliere (definition de fwhm) de la gaussienne
# servant a modeliser les raies
# Cette procÃ©dure, bien qu'autonome, est utilisÃ©e surtout appelÃ©e par spc_dryprofile.
# Reste a faire : gerer les largeurs de raies variables dans fichier Ch. Buil, calculer des
# profondeurs de raies a partir d'estimation sur l'ensemble du spectre donc par une procÃ©dure
# autre que fwhmo

# Exemple : model_H2O profile.fit liste1 liste_mots_cles profil_eau.fit

####################################################################


proc model_H2O  { args } {
   global conf
   global audace spcaudace
   set nbargs [ llength $args ]

   # extraction des parametres
   if { $nbargs == 4 } {
      set nom_fich_data [ lindex $args 0 ]
      set results1_fwhmo [ lindex $args 1 ]
      #set fwhm [ expr $fwhm*1. ]
      set liste_mots_cles [ lindex $args 2 ]
      #set denom1 [ lindex $args 2 ]
      set nom_fich_output [ lindex $args 3 ]
      #set lambdamin [ lindex $args 4 ]
      #set nax1 [ lindex $args 5 ]
      #set dispersion [ lindex $args 6 ]
      set nom_fich_default "$spcaudace(reptelluric)/H2O5.dat"
   } elseif { $nbargs == 5 } {
      set nom_fich_data [ lindex $args 0 ]
      set results1_fwhmo [ lindex $args 1 ]
      #set fwhm [ expr $fwhm*1. ]
      set liste_mots_cles [ lindex $args 2 ]
      #set denom1 [ lindex $args 2 ]
      set nom_fich_output [ lindex $args 3 ]
      #set lambdamin [ lindex $args 4 ]
      #set nax1 [ lindex $args 5 ]
      #set dispersion [ lindex $args 6 ]
      set nom_fich [ lindex $args 4 ]
   } else {
      affiche_erreur "usage: model_H2O nom_fich_input results1_fwhmo liste_mots_cles nom_fich_denom H2O5.dat \n\n"
   }

   set dispersion [ lindex $liste_mots_cles 0 ]
   set lambdamin [ lindex $liste_mots_cles 1 ]
   set nax1 [ lindex $liste_mots_cles 2 ]
   set lambda_best [ lindex $results1_fwhmo 0 ]
   set profondeur [ lindex $results1_fwhmo 1 ]
   # Ci-dessous il faut comprendre que fwhmo renvoie sigma2 (et non fwhm) meme si, a la
   # console, on parle de de fwhm exprimee en angstroems
   set sigma2 [ lindex $results1_fwhmo 2 ]
   set sigma2 [ expr $sigma2 * $dispersion ]
   set sigma [ expr sqrt ( $sigma2 ) ]

   #set fwhm [ expr $sigma *  2. * sqrt ( 2. * log (2.) ) ]
   set fwhm [ expr $sigma * 2.354820045 ]
   ::console::affiche_resultat " fwhm modelisation $fwhm \n"
   # le parametre ci dessous est un coefficient d'adoucissement redondant avec le coeff. utilisÃ©
   # comme argument dans spc_dryprofile
   set coefadouc 1.025

	#calculs preliminaires
	set lambdamax [ expr $lambdamin + ($nax1 - 1 ) *$dispersion ]
	::console::affiche_resultat " lambdamin= $lambdamin  lambdamax= $lambdamax \n"
	#rajouter test dispersion assez petite notamment par rapport a fwhm
	#set scalingfactor [ expr $fwhm/.1 ]
	set scalingfactor [ expr $fwhm/.1 ]
	set cent 100.
	set cent [ expr $cent/$scalingfactor ]
	set mille 1000.
	set mille [ expr $mille/$scalingfactor ]
	set unsurcent [ expr 1./$cent ]
	set unsurmille [ expr 1./$mille ]
	# la philosophie : si la largeur des raies observÃ©es Ã  l'instrument (cette largeur
	# caractÃ©rise la rÃ©solution du dit instrument) Ã©tait de .1 Angstroems, on creerait um profil
	# modÃ¨le Ã©chantillonÃ© au pas de 1/100 Angstroem (un tel Ã©chantillonage est motivÃ© par un
	# souci de prÃ©cision) en ayant habilllÃ© les raies par des gaussiennes analytiques centrÃ©es
	# sur les longueurs d'ondes d'absorbtion arrondies au milliÃ¨me d'Angstroem. On voit donc
	# apparaitre 2 Ã©chelles de travail (dans un rapport de 1 Ã  10). Si la fwhm donnÃ©e par
	# l'instrument est autre, on utilise la meme stratÃ©gie Ã  un facteur d'Ã©chelle
	# (scalingfactor) prÃ¨s. Dans un deuxime temps on reechantillone modelise selon la dispersion
	# indiquee dans le header du profil utilisateur.

	set ideb [ expr int($lambdamin*$cent+$unsurmille) ]
	set ifin [ expr int($lambdamax*$cent+$unsurmille) +1 ]
	set nechant [ expr $ifin-$ideb ]
	set deltalambdaref [ expr ($nechant-1)/$cent ]
	set deltalambdainit [ expr $lambdamax -$lambdamin ]
	::console::affiche_resultat "dlamdref= $deltalambdaref dlambdinit= $deltalambdainit \n"

	#creation du profile de reference

	#calculs preliminaires
	set profileref [ list ]
	set lambdaref [ list ]
	# la longueur d'onde (exprimee en centieme d'angstroem si fwhm=.1A ) d'un
	# echant de profileref est le nÂ° d'echant (avec la convention premier indice nul) + ideb

	for {set k 0} { $k<$nechant} { incr k } {
		lappend profileref 0.
		set lambda_i [ expr $lambdamin + $k * $unsurcent ]
		lappend lambdaref $lambda_i
	}
	set lprofileref [ llength $profileref ]
	::console::affiche_resultat " longueur en echantillons du profil de reference modelise= $lprofileref \n"
	# dans l'echelle de reference (fwhm=0.1A) ninterv_raie serait la largeur, exprimee en
	# millieme d'A , du support de la raie modelisee
	set ninterv_raie [ expr int (5.*$fwhm*$cent) ]
	set fwhm_old $fwhm

	if {[ expr $ninterv_raie%2 ]!=0 } {
		#::console::affiche_erreur "ninterv_raie cense etre pair !\n\n"
		#return 0
		set ninterv_raie  [ expr $ninterv_raie + 1 ]
		set fwhm [ expr $ninterv_raie * $unsurcent * .2 ]
		::console::affiche_resultat " fwhm modifiee : ancien : $fwhm_old ; nouveau : $fwhm \n"
		}
	set ninterv_raie_2 [ expr $ninterv_raie/2 ]
	set sigma [ expr $fwhm*$mille/2.354820045 ]


# calcul des raies elementaires sous forme de tableau a 2 indices k et i. Dans l'Ã©chelle de
# rÃ©fÃ©rence l'ecnatillonage en i est au centieme d'angstrom, le passage d'une ligne du tableau
# a l'autre (indice k) correspond a un dÃ©calage de un millieme d'angstrom)
# Toujours dans l'Ã©chelle de rÃ©fÃ©rence et en adoptant la convention de numÃ©rotation Tcl, les
# Ã©chantillons, indexÃ©s par i de la liste k donnent une gaussienne centrÃ©e sur
# (i-nintervraie_2)*10-k en milliÃ¨mes d'Angstroems.
	set raies_elem [ list ]
	set denom1 -1.
	set denom2 [ expr 2. * $sigma * $sigma ]
	set denom2 [ expr 1. / $denom2 ]
	::console::affiche_resultat " denom1=$denom1 denom2=$denom2 \n"
	for {set k 0} { $k<10} { incr k } {
		set raie_k [ list ]
		set l [list ]

		for {set i 0} { $i<=$ninterv_raie } { incr i } {
			set intens_i [ expr $denom1*exp(-$denom2*(($i-$ninterv_raie_2)*10-$k)*(($i-$ninterv_raie_2)*10-$k)) ]
			lappend l $i
			lappend raie_k $intens_i
		#::console::affiche_resultat " k= $k i=$i intens_i=$intens_i \n"
		}

		lappend raies_elem $raie_k
	}



#construction du profil de reference

## === Lecture du fichier de donnees du profil de raie ===
	if { $nbargs == 4 } {
   	set inputfile [open "$nom_fich_default" r]
	} else {
   	set inputfile [open "$audace(rep_images)/$nom_fich" r]
	}
	set contents [split [read $inputfile] \n]
	close $inputfile



## === Extraction des numeros des pixels et des intensites ===
	set abscisses_lin [ list ]
	set abscisses [ list ]
	set intensites [ list ]
	set kk 0
	foreach ligne $contents {
		set abscisse [ lindex $ligne 0 ]
		set intensite [ lindex $ligne 1 ]
		if { $abscisse!="" } {
	   	if {$abscisse>=$lambdamin&&$abscisse<=$lambdamax} {
	    	# on ajoute ici la contribution de chaque raie
	    		set peak [ expr int ($abscisse*$cent) ]
	    		set reste [ expr int ($abscisse*$mille)% 10]
	    	#::console::affiche_resultat " reste= $reste peak= $peak  \n"
				if {$reste>=5} {
			#::console::affiche_resultat " $reste \n"
			#peak correspond donc l'echantillon ninter_raie/2 +1 + deb (a ideb pres)
					set deb1 [ expr $peak -$ninterv_raie_2 -1 -$ideb ]
					set fin1 [ expr $peak +$ninterv_raie_2 -1-$ideb ]
					set deb [ bm_max 0 $deb1 ]
					set fin [ bm_min $fin1 $lprofileref ]
			#::console::affiche_resultat "  deb= $deb fin= $fin \n"
					for { set j $deb} { $j<=$fin } { incr j} {
						set jj [ expr $j- $deb ]
						set j1 [expr $j-1 ]
				# prendre en compte la contrib de raie(reste,jj)
				#::console::affiche_resultat " $reste $j $jj \n"
						set contrib_j [ lindex $raies_elem $reste $jj ]
						set contrib_j [ expr [ lindex $profileref $j1 ] + $intensite*$contrib_j ]
						set profileref [ lreplace $profileref $j1 $j1 $contrib_j ]
					}
				} else {
			#::console::affiche_resultat " $reste \n"
			#peak correspond donc l'echantillon ninter_raie/2 + deb (a ideb pres)
					set deb1 [ expr $peak -$ninterv_raie_2 -$ideb ]
					set fin1 [ expr $peak +$ninterv_raie_2 - $ideb ]
					set deb [ bm_max 0 $deb1 ]
					set fin [ bm_min $fin1 $lprofileref ]
					for { set j $deb} { $j<=$fin } { incr j} {
						set jj [ expr $j- $deb ]
						set j1 [expr $j-1 ]
				# prendre en compte la contrib de raie(reste,jj)
				#::console::affiche_resultat " $reste $j $jj \n"
						set contrib_j [ lindex $raies_elem $reste $jj ]
						set contrib_j [ expr [ lindex $profileref $j1 ] + $intensite*$contrib_j ]
						set profileref [ lreplace $profileref $j1 $j1 $contrib_j ]
					}
				}

			}
		#lappend abscisses_lin [ expr $k+1 ]
		#lappend abscisses $abscisse
		#lappend intensites $intensite
			incr kk
		#::console::affiche_resultat " $kk \n"
		}
	}
	::console::affiche_resultat " [ llength $lambdaref] [ llength $profileref ] \n"
	# calcul de l'amplitude du profil de reference pour lambda_best
	set ibestmoins [ expr int( ( $lambda_best - $lambdamin) / $unsurcent ) ]
	set ibestplus [ expr $ibestmoins + 1 ]
	set lambdamoins [ lindex $lambdaref $ibestmoins ]
	set lambdaplus [ lindex $lambdaref $ibestplus ]
	set intensmoins [ lindex $profileref $ibestmoins ]
	set intensplus [ lindex $profileref $ibestplus ]
	set num  [ expr  $intensplus - $intensmoins ]
	set den  [ expr $lambdaplus - $lambdamoins ]
	set pente [ expr $num / $den ]
	set ampli_best [ expr $intensmoins + $pente * ( $lambda_best - $lambdamoins ) ]

	# reechantillonage du fichier selon dispersion indiquee par l'utilisateur : on passe ainsi
	# de (lambdaref, profileref) a (lambda, profile)
	set lambda [ list ]
	set profile [ list ]
	for { set i 0 } { $i<$nax1 } {incr i} {
		set dlambda [ expr $i * $dispersion ]
		lappend lambda [ expr $lambdamin + $dlambda ]
		set imoins [ expr ( $dlambda / $unsurcent ) ]
		set imoins [ expr int ( $imoins ) ]
		set iplus [ expr $imoins + 1 ]
		#::console::affiche_resultat "  $i $imoins \n"
		set lambdamoins [ lindex $lambdaref $imoins ]
		set lambdaplus [ lindex $lambdaref $iplus ]
		set intensmoins [ lindex $profileref $imoins ]
		set intensplus [ lindex $profileref $iplus ]
		set num  [ expr  $intensplus - $intensmoins ]
		set den  [ expr $lambdaplus - $lambdamoins ]
		set pente [ expr $num / $den ]
		set inten [ expr $intensmoins + $pente * ( $lambdamin + $dlambda - $lambdamoins ) ]
		lappend profile $inten
	}
	set lambdamax [ expr $lambdamin + $dlambda ]
	::console::affiche_resultat " lambdamin= $lambdamin  lambdamax= $lambdamax \n"
# creation du profil d'absorption en ajustant les amplitudes sur la profondeur donnee par fwhmo


	set ratio [ expr $profondeur / ( $ampli_best * $coefadouc ) ]
	for {set k 0} { $k < $nax1 } {incr k} {
		set contrib_k [ expr 1. - $ratio * [ lindex $profile $k ] ]
		set profile [ lreplace $profile $k $k $contrib_k ]
	}




	::console::affiche_resultat " [ llength $lambda] [ llength $profile ]  \n"

        #fin programme patrick
#debut programme benji
 #--- CrÃ©ation du fichier fits
 	set nbunit "float"
 	set nbunit1 "double"
   buf$audace(bufNo) setpixels CLASS_GRAY $nax1 1 FORMAT_FLOAT COMPRESS_NONE 0
   buf$audace(bufNo) setkwd [ list "NAXIS" 1 int "" "" ]
   buf$audace(bufNo) setkwd [list "NAXIS1" $nax1 int "" ""]
   buf$audace(bufNo) setkwd [list "NAXIS2" 1 int "" ""]
        #-- Valeur minimale de l'abscisse (xdepart) : =0 si profil non Ã©talonnÃ©
   set xdepart [ expr 1.0*[lindex $lambda 0]]
   buf$audace(bufNo) setkwd [list "CRVAL1" $xdepart $nbunit1 "" "angstrom"]
        #-- Dispersion
        #set dispersion $unsurcent
   buf$audace(bufNo) setkwd [list "CDELT1" $dispersion $nbunit1 "Axis1 increment" "angstrom/pixel"]
        #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
        # Une liste commence Ã  0 ; Un vecteur fits commence Ã  1
        #set intensite [ list ]
   ::console::affiche_resultat " lambdamin= $lambdamin  lambdamax= $lambdamax \n"
   for {set k 0} { $k < $nax1 } {incr k} {
            #append intensite [lindex $profileref $k]
            #::console::affiche_resultat "$intensite\n"
            #if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {}
   	buf$audace(bufNo) setpix [list [expr $k+1] 1] [lindex $profile $k ]
                #set intensite 0
   }
        #--- Sauvegarde du fichier fits ainsi crÃ©Ã©
   buf$audace(bufNo) setkwd [ list "BSS_TELL" "yes" string "Tellurics lines correction" "" ]
   buf$audace(bufNo) bitpix float
   buf$audace(bufNo) save "$audace(rep_images)/$nom_fich_output"
   # ::console::affiche_resultat " nom fichier sortie $nom_fich_output \n"
   buf$audace(bufNo) bitpix short
   return $nom_fich_output
}


# ProcÃ©dure de caractÃ©risation de raies de l'eau prÃ©sentes sur un profil
# Les raies sont supposÃ©es isolÃ©es (par opposition Ã  une superposition de raies voisines et
# rendues non sÃ©parables par manque de rÃ©solution)
proc spc_fwhmo { args } {
	global conf
	global audace spcaudace
    # set pas 10
    #-- Demi-largeur de recherche des raies telluriques (Angstroms)
    #set ecart 4.0
    #set ecart 1.2
    #set ecart 1.5
    # set ecart 1.0
    set ecart $spcaudace(dlargeur_eau)
    set marge_bord 2.5
    #set erreur 0.01

    #--- Rappels des raies pour resneignements :
    #-- Liste C.Buil :
    ### set listeraies [ list 6532.359 6542.313 6548.622 6552.629 6574.852 6586.597 ]
    ##set listeraies [ list 6532.359 6543.912 6548.622 6552.629 6574.852 6586.597 ]
    # GOOD : set listeraies [ list 6532.359 6543.907 6548.622 6552.629 6572.072 6574.847 ]
    #-- Liste ESO-Pollman :
    ##set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6574.880 6586.730 ]
    #set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 6574.880 ]
    ##set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 ]

    set nbargs [ llength $args ]
    if { $nbargs <= 2 } {
        if { $nbargs == 1 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur $spcaudace(largeur_savgol)
        } elseif { $nbargs == 2 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur [ lindex $args 1 ]
        } else {
            ::console::affiche_erreur "Usage: spc_fwhmo profil_de_raies_a_calibrer ?largeur_raie (pixels)?\n"
            return ""
        }

        #--- Gestion des profils selon la loi de calibration :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        #-- Renseigne sur les parametres de l'image :
        set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
        set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
        set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
        #- Cas non-lineaire :
        set listemotsclef [ buf$audace(bufNo) getkwds ]
        if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
            set flag_spccal 1
            set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
            set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
            set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
            if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
                set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
            } else {
                set spc_d 0.
            }
            set lmin_spectre [ expr $spc_a+$spc_b+$spc_c+$spc_d ]
            set lmax_spectre [ expr $spc_a+$spc_b*$naxis1+$spc_c*pow($naxis1,2)+$spc_d*pow($naxis1,3) ]
        } else {
            set flag_spccal 0
            set lmin_spectre $crval1
            set lmax_spectre [ expr $crval1+$cdelt1*($naxis1 -1) ]
        }
        #-- Incertitude sur mesure=1/nbpix*disp, nbpix_incertitude=1 :

        ### modif michel (mes_incertitude avait une valeur beaucoup trop elevee)
        set mes_incertitude [ expr 1.0/($cdelt1*$cdelt1) ]


        #--- Charge la liste des raies de l'eau :
        set file_id [ open "$spcaudace(filetelluric)" r ]
        set contents [ split [ read $file_id ] \n ]
        close $file_id
        set nbraiesbib 0
        foreach ligne $contents {
            lappend listeraieseau [ lindex $ligne 1 ]
            incr nbraiesbib
        }
        set nbraiesbib [ expr $nbraiesbib-2 ]
        set listeraieseau [ lrange $listeraieseau 0 $nbraiesbib ]
        set lmin_bib [ lindex $listeraieseau 0 ]
        set lmax_bib [ lindex $listeraieseau $nbraiesbib ]
        # ::console::affiche_resultat "$nbraiesbib ; Lminbib=$lmin_bib ; Lmaxbib=$lmax_bib\n"
        # ::console::affiche_resultat "Lminsp=$lmin_spectre ; Lmaxsp=$lmax_spectre\n"


        #--- CreÃÂ©e la liste de travail des raies de l'eau pour le spectre :
        if { [ expr $lmin_bib+$marge_bord ]<$lmin_spectre || [ expr $lmax_bib-$marge_bord ]<$lmax_spectre } {
            #-- Recherche la longueur minimum des raies raies telluriques utilisables (2 A) :
            set index_min 0
            foreach raieo $listeraieseau {
                if { [ expr $lmin_spectre-$raieo ]<=-$marge_bord } {
                    break
                } else {
                    incr index_min
                }
            }
            # ::console::affiche_resultat "$index_min ; [ lindex $listeraieseau $index_min ]\n"
            #-- Recherche la longueur maximum des raies raies telluriques utilisables (2 A) :
            set index_max $nbraiesbib
            for { set index_max $nbraiesbib } { $index_max>=0 } { incr index_max -1 } {
                if { [ expr [ lindex $listeraieseau $index_max ]-$lmax_spectre ]<=-$marge_bord } {
                    break
                }
            }
            # ::console::affiche_resultat "$index_max ; [ lindex $listeraieseau $index_max ]\n"
            #-- Liste des raies telluriques utilisables :
            #- Enleve une raie sur chaque bords : 070910
            # set index_min [ expr $index_min+1 ]
            # set index_max [ expr $index_max-1 ]
            set listeraies [ lrange $listeraieseau $index_min $index_max ]
            # ::console::affiche_resultat "$listeraies\n"
        } else {
            ::console::affiche_erreur "Plage de longueurs d'onde incompatibles avec la calibration tellurique\n"
            return "$filename"
        }


        #--- Filtrage pour isoler le continuum :
        #-- Retire les petites raies qui seraient des pixels chauds ou autre :
        #buf$audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=0.9"
        set ffiltered [ spc_smoothsg $filename $largeur ]
        set fcont1 [ spc_div $filename $ffiltered ]

        #--- Inversion et mise a 0 du niveau moyen :
        buf$audace(bufNo) load "$audace(rep_images)/$fcont1"
        set icontinuum [ expr 2*[ lindex [ buf$audace(bufNo) stat ] 4 ] ]
        buf$audace(bufNo) mult -1.0
        buf$audace(bufNo) offset $icontinuum
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filename}_conti"
        buf$audace(bufNo) bitpix short

        #--- Recherche des raies telluriques en absorption :
        ::console::affiche_resultat "Recherche des raies d'absorption de l'eau...\n"
        #set pas [ expr int($largeur/2) ]
        #buf$audace(bufNo) scale {1 3} 1
        #buf$audace(bufNo) load "$audace(rep_images)/${filename}_conti"
        #buf$audace(bufNo) load "$audace(rep_images)/$filename"
        set nbraies [ llength $listeraies ]
        set listexraies [list ]
        set listexmesures [list ]
        set listelmesurees [list ]
        set listeldiff [list ]
        foreach raie $listeraies {
            if { $flag_spccal } {
                set x  [ expr (-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie))*$spc_c))/(2*$spc_c) ]
                set x1 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie-$ecart))*$spc_c))/(2*$spc_c)) ]
                set x2 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie+$ecart))*$spc_c))/(2*$spc_c)) ]
                set coords [ list $x1 1 $x2 1 ]
                #-- Meth 2 : centre gaussien
		set infosline [ buf$audace(bufNo) fitgauss $coords ]
		set xcenter [ lindex $infosline 1 ]
		set intensity [ lindex $infosline 0 ]
                set lambda_mes [ expr ($xcenter -1)*$cdelt1+$crval1 ]
                set ldiff [ expr $lambda_mes-$raie ]
                lappend listexraies $x
                lappend listexmesures $xcenter
                lappend listelmesurees [ list $lambda_mes $intensity ]
                lappend listeldiff $ldiff
            } else {
                set x  [ expr ($raie-$crval1)/$cdelt1 + 1 ]
                set x1 [ expr round(($raie-$ecart-$crval1)/$cdelt1 +1 ) ]
                set x2 [ expr round(($raie+$ecart-$crval1)/$cdelt1 +1 ) ]
                set coords [ list $x1 1 $x2 1 ]
                #-- Meth 2 : centre gaussien
		set infosline [ buf$audace(bufNo) fitgauss $coords ]
                set xcenter [ lindex $infosline 1 ]
                set intensity [ lindex $infosline 0 ]
                set lambda_mes [ expr  ($xcenter -1) *$cdelt1+$crval1 ]
                set ldiff [ expr $lambda_mes-$raie ]
                lappend listexraies    $x
                lappend listexmesures  $xcenter
                lappend listelmesurees [ list $lambda_mes $intensity ]
                lappend listeldiff     $ldiff

            }
            lappend errors $mes_incertitude
        }
        ::console::affiche_resultat "Liste des raies trouvÃ©es :\n$listelmesurees\n"
        #::console::affiche_resultat "Liste des x mesures :\n$listexmesures\n"
        ::console::affiche_resultat "Liste des raies du catalogue :\n$listeraies\n"
        #::console::affiche_resultat "Liste des x du catalogue :\n$listexraies\n"

        #--- Effacement des fichiers temporaires :
        file delete -force "$audace(rep_images)/$ffiltered$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$fcont1$conf(extension,defaut)"


	#--- Selection de la plus profonde :
	set bestline [ lindex [ lsort -real -index 1 -decreasing $listelmesurees ] 0 ]

	#--- Mesure de la fwhm :
        #set dwidth [ expr 1.1*$ecart ]
        set dwidth $ecart
	set lambdabest [ lindex $bestline 0 ]
	set lambda_imax [ lindex $bestline 1 ]
	set ldeb [ expr $lambdabest-$dwidth ]
	set lfin [ expr $lambdabest+$dwidth ]

        # ::console::affiche_resultat "$bestline ; dw=$dwidth ; ldeb=$ldeb ; lfin=$lfin\n"
	set fwhm [ spc_fwhm $filename $ldeb $lfin a ]
        file delete -force "$audace(rep_images)/${filename}_conti$conf(extension,defaut)"

	#--- Traitement des resultats :
       set results1 [ list $lambdabest $lambda_imax $fwhm ]
       set liste_mots_cles [ list $cdelt1 $crval1 $naxis1 ]
       set results [ list $results1 $liste_mots_cles ]

	return $results
    } else {
       ::console::affiche_erreur "Usage: spc_fwhmo profil_de_raies_a_calibrer ?largeur_raie (pixels)?\n\n"
    }
}




####################################################################
# La procÃ©dure ci-dessous a Ã©tÃ© testÃ©e sur un certain nombre de profils Ã  haute resolution
# (Lhires 3 2400 traits). Son comportement sur des donnÃ©es Ã  moins haute rÃ©solution (Lhires 3
# 1200 traits par exemple) reste Ã  Ã©tudier. Par ailleurs un bon rapport signal sur bruit ne
# nuit pas...



# Procedure d'elimination (adoucissement) dans un profil des raies du spectre de l'eau
# Auteurs : Benjamin Mauclaire et Patrick LAILLY
# Date creation : 01-05-08
# Date modification : 05-06-08
# Cette procedure cree un fichier .fit adoucissant, dans un profil, les raies d'absorption
# correspondant au spectre de l'eau. Le fichier resultat est echantillone en conformite avec le
# profil donne par l'utilisateur.  Le profil utilisateur doit bien entendu avoir ete
# prealablement calibre sur les raies de l'eau... En option, un coefficient permet de moduler
# l'adoucissement (en multipliant le denominateur par ce coeff.), la valeur par defaut est 1.
# Arguments : nom fichier profil utilisateur, coefficient de modulation
#
# Sorties : fichier profil sans les raies de l'eau (denomme comme le fichier de donnÃ©es avec le
# suffixe_rmo) et fichier "profil_eau.fit" Ce dernier fichier, utilisÃ© pour la division du
# profil utilisateur, peut etre visualise pour verification

# Remarque : le fichier denominateur est cense s'appeler profil_eau.fit, Ãªtre situÃ© dans le
# rÃ©pertoire des images. Il est cense permettre la division par spc_div. L'utilisation
# habituelle est la fabrication de ce fichier par la procÃ©dure model_H2O. A prevoir : un
# suffixe spÃ©cifique pour fichier apres Ã©limination des raies de l'eau.
# Exemple : spc_dryprofile profile_input.fit .8
####################################################################

proc spc_dry { args } {
   global conf
   global audace

   set nbargs [ llength $args ]
   if { $nbargs == 1 } {
      set nom_fich_input [ file rootname [ lindex $args 0 ] ]
      set coef_profondeur 1.0
      set flag_rmo "o"
   } elseif { $nbargs == 2 } {
      set nom_fich_input [ file rootname [ lindex $args 0 ] ]
      set coef_profondeur [ lindex $args 1 ]
      set flag_rmo "o"
   } elseif { $nbargs == 3 } {
      set nom_fich_input [ file rootname [ lindex $args 0 ] ]
      set coef_profondeur [ lindex $args 1 ]
      set flag_rmo [ lindex 2 ]
   } else {
      ::console::affiche_erreur "Usage: spc_dry profil_de_raies_calibre_avec_eau ?coeff multiplicateur profondeur (1.0)? ?effacement_fichier_eau (o)?\n\n"
      return ""
   }

   # set nom_fich_output [ lindex $args 1 ]
   set results_fwhmo [ spc_fwhmo $nom_fich_input ]
   set results1_fwhmo [ lindex $results_fwhmo 0 ]

   set lambdabest [ lindex $results1_fwhmo 0 ]
   set imax [ expr $coef_profondeur*[ lindex $results1_fwhmo 1 ] ]
   set fwhm [ lindex $results1_fwhmo 2 ]
   set results1_fwhmo [ list $lambdabest $imax $fwhm ]

   set liste_mots_cles [ lindex $results_fwhmo 1 ]
   set nom_fich_denom "profil_eau"
   set nom_fich_denom [ model_H2O $nom_fich_input $results1_fwhmo $liste_mots_cles $nom_fich_denom ]
   set sortie_rmo [ spc_div $nom_fich_input $nom_fich_denom ]
   file copy -force "$audace(rep_images)/$sortie_rmo$conf(extension,defaut)" "$audace(rep_images)/${nom_fich_input}-rmo$conf(extension,defaut)"
   file delete -force "$audace(rep_images)/$sortie_rmo$conf(extension,defaut)"
   if { $flag_rmo == "o" } {
      file delete -force "$audace(rep_images)/$nom_fich_denom$conf(extension,defaut)"
   }
   ::console::affiche_resultat "Profil nettoye des raies de l'eau sauve sous ${nom_fich_input}-rmo \n"
   return ${nom_fich_input}-rmo
}
