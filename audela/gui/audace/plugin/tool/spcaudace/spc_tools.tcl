# Mise a jour $Id: spc_tools.tcl 14525 2018-11-09 18:22:10Z bmauclaire $


###############################################################################
# Description : aide au debugage, cree un nombre unique pour la pose de X millisecondes
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2017-03-19
# Date de mise a jour : 2017-03-19
# Arguments : aucun
###############################################################################

proc uniqkeye { } {
     set key   [ expr { pow(2,31) + [ clock clicks ] } ]
     set key   [ string range $key end-8 end-3 ]
     set key   [ clock seconds ]$key
     return $key
}
#-----------------------------------------------------------------------------#


###############################################################################
# Description : aide au debugage, fait une pose de X millisecondes
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2017-03-19
# Date de mise a jour : 2017-03-19
# Arguments : aucun
###############################################################################

proc sleepy { ms } {
     set uniq [ uniqkeye ]
     set ::__sleep__tmp__$uniq 0
     after $ms set ::__sleep__tmp__$uniq 1
     vwait ::__sleep__tmp__$uniq
     unset ::__sleep__tmp__$uniq
}
#-----------------------------------------------------------------------------#


###############################################################################
# Description : aide au debugage, fait apparaitre une boite et attend OK
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2017-03-19
# Date de mise a jour : 2017-03-19
# Arguments : aucun
###############################################################################

proc boxdebug {} {
    #global audace conf
    global flag_ok
	set flag_ok 0
	#-- Création de la fenêtre
	if { [ winfo exists .benji ] } {
	    destroy .benji
	}
	toplevel .benji
	wm geometry .benji
	wm title .benji "Debug"
	wm transient .benji .audace
	#-- Textes d'avertissement
	label .benji.lab -text "Debug box..."
	pack .benji.lab -expand true -expand true -fill both
	#-- Sous-trame pour boutons
	frame .benji.but
	pack .benji.but -expand true -fill both
	#-- Bouton "Ok"
	button .benji.but.1  -command {set flag_ok 1} -text "OK"
	pack .benji.but.1 -side left -expand true -fill both
	#-- Bouton "Annuler"
	button .benji.but.2 -command {set flag_ok 2} -text "Annuler"
	pack .benji.but.2 -side right -expand true -fill both
	#-- Attend que la variable $flag_ok change
	vwait flag_ok
	if { $flag_ok == "1" } {
	    set flag_ok 2
	    destroy .benji
	} elseif { $flag_ok == "2" } {
	    set flag_ok 2
	    destroy .benji
            return 0
	}
}
#-----------------------------------------------------------------------------#



###############################################################################
# Description : Calcule la fraction de jour et retourne une date JJ.jjj-mm-yyyy
# Auteur : Benjamin MAUCLAIRE
# Date creation : 28-08-2006
# Date de mise a jour : 31-07-2014
# Arguments : nom fichier fits
###############################################################################

proc spc_datefrac { args } {
   global audace
   global conf

   if { [llength $args] == 1 } {
      set fichier [lindex $args 0]

      #--- CApture la date de l'entete fits
      buf$audace(bufNo) load "$audace(rep_images)/$fichier"
      set ladate [lindex [buf$audace(bufNo) getkwd "DATE-OBS"] 1]
      #-- Exemple de date : 2006-08-22T01:37:34.46

      #--- Isole l'annee, le moi, le jour, l'heure, les minutes et les secondes
      #-- Meth1 :
      # regexp {([0-9][0-9][0-9][0-9])\-.} $ladate match y
      # regexp {[0-9][0-9][0-9][0-9]\-([0-9][0-9])\-.} $ladate match mo
      # regexp {[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-([0-9][0-9])T.} $ladate match d
      # regexp {[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]T([0-9][0-9]).} $ladate match h
      # regexp {[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]T[0-9][0-9]:([0-9][0-9]).} $ladate match mi
      # regexp {[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:([0-9][0-9]).} $ladate match s
      #-- Meth2 :
      set ldate [ mc_date2ymdhms $ladate ]
      set y [ lindex $ldate 0 ]
      set mo [ lindex $ldate 1 ]
      set d [ lindex $ldate 2 ]
      set h [ lindex $ldate 3 ]
      set mi [ lindex $ldate 4 ]
      set s [ lindex $ldate 5 ]

      #--- Calcul la fraction de jour :
      set dfrac [ expr $d+$h/24.0+$mi/1440.0+$s/86400.0 ]

      #-- Ne tient compte que des 3 premieres decimales
      # set cdfrac [ format "%2.3f" [ expr round($dfrac*1000.)/1000. ] ]
      set cdfrac [ format "%2.4f" $dfrac ]

      #--- Affichage du resultat :
      ::console::affiche_resultat "La fraction de date est : $cdfrac/$mo/$y\n"
      return "$cdfrac/$mo/$y"
   } else {
      ::console::affiche_erreur "Usage: spc_datefrac nom_fichier_fits.\n"
   }
}
#-----------------------------------------------------------------------------#


###############################################################################
# Description : Reconstitue la date jjmmyyyy de prise de vue d'un fichier fits
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-01-2007
# Date de mise a jour : 15-07-2014
# Arguments : nom fichier fits
###############################################################################

proc spc_datefile { args } {
   global audace
   global conf

   if { [llength $args] == 1 } {
      set fichier [lindex $args 0]

      #--- Capture la date de l'entete fits
      buf$audace(bufNo) load "$audace(rep_images)/$fichier"
      set ladate [lindex [buf$audace(bufNo) getkwd "DATE-OBS"] 1]
      #-- Exemple de date : 2006-08-22T01:37:34.46

      #-- Meth2 :
      set ldate [ mc_date2ymdhms $ladate ]
      set y [ lindex $ldate 0 ]
      set mo [ lindex $ldate 1 ]
      set d [ lindex $ldate 2 ]
      set h [ lindex $ldate 3 ]
      set mi [ lindex $ldate 4 ]
      set s [ lindex $ldate 5 ]

      #--- Gestion des valeurs <=9 :
      if { [ expr $d/10. ] < 1. } {
         set d "0$d"
      }
      if { $mo<10 } {
         set mo "0$mo"
      }

      #--- Calcul de la fraction du jour a 3 decimales :
      set smod [ expr $s/(3600*24.) ]
      set mmod [ expr $mi/(60*24.) ]
      set hmod [ expr $h/24. ]
      #set dfrac [ expr int(round(1000*($hmod+$mmod+$smod))) ]
      set dfr [ format "%0.4f" [ expr $hmod+$mmod+$smod ] ]
      # set dfr2 [ expr int(1000*$dfr) ]
      regexp {0\.([0-9][0-9][0-9][0-9])} $dfr match dfrac

      #--- Concatenation :
      set madate "$y$mo$d\_$dfrac"

      #--- Affichage du resultat :
      ::console::affiche_resultat "La date de prise de vue est : $madate\n"
      return $madate
   } else {
      ::console::affiche_erreur "Usage:spc_datefile nom_fichier_fits.\n"
   }
}
#-----------------------------------------------------------------------------#



###########################################################################
# Procedure pour changer un mot cle dans un header fits
# entrees : nom du fichier fits a changer, nom du mot cle, nouvelle valeur
# sortie : valeur donnee au nouveau mot cle
# NB : le nouveau fichier fits ecrase l'ancien...
# exemple pl_changekeywd fichier CRVAL1 6500.
###########################################################################

proc spc_selectstronglines { args } {
   global audace conf spcaudace
   set coeff_min 0.1

   #-- listeraie = { {x I} ... }
   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set listeraies [ lindex $args 0 ]
      set coeff_min 0.1
   } elseif { $nbargs==2 } {
      set listeraies [ lindex $args 0 ]
      set coeff_min [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage: spc_selectstronglines liste_couples_x_I ?pourcent_iraie_continuum(0.1)?\n"
      return ""
   }

   set listeraies [ lsort -increasing -real -index 0 $listeraies ]
   set imax_cal [ expr $coeff_min*[ lindex [ lindex $listeraies 0 ] 1 ] ]
   set listeraies_out [ list ]
   foreach raie $listeraies {
      if { [ lindex $raie 1 ]>=$imax_cal } {
         lappend listeraies_out $raie
      } else {
         continue
      }
   }
   return $listeraies_out
}
#************************************************************************#


###########################################################################
# Procedure pour changer un mot cle dans un header fits
# entrees : nom du fichier fits a changer, nom du mot cle, nouvelle valeur
# sortie : valeur donnee au nouveau mot cle
# NB : le nouveau fichier fits ecrase l'ancien...
# exemple pl_changekeywd fichier CRVAL1 6500.
###########################################################################

proc pl_changekeywd { args } {
  global audace conf spcaudace

  if { [ llength $args ] == 3 } {
     set nomfich [ lindex $args 0 ]
     set keyword [ lindex $args 1 ]
     set valeur [ lindex $args 2 ]
     buf$audace(bufNo) load $nomfich
     set listemotsclef [ buf$audace(bufNo) getkwds ]
     if { [ lsearch $listemotsclef $keyword ] !=-1 } {
        set motcle [ buf$audace(bufNo) getkwd $keyword ]
        set motcle [ lreplace $motcle 1 1 $valeur ]
        buf$audace(bufNo) delkwd $keyword
        buf$audace(bufNo) setkwd $motcle
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save $nomfich
        return [ lindex [ buf$audace(bufNo) getkwd $keyword ] 1 ]
     } else {
      	::console::affiche_erreur "pl_changekeywd : le mot cle $keyword n'est pas present dans le fichier $nomfich et celui ci reste inchange\n\n"
      	return 0
     }
  } else {
     ::console::affiche_erreur "Usage: pl_changekeywd : nom_fich nom_keywd valeur\n\n"
     return 0
  }
}
#************************************************************************#
