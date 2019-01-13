####################################################################################
#
# Creation d'un profil de raie a partir du spectre spatial x,y
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 31-01-2005
# Arguments : nom du fichier du spectre spatial
# Remarque 1 : necessite le repere de coordonnnees a l'aide de la souris
# Remarque 2 : utilise la librairie blt pour le trace final du profil de raie
#
# Chargement en ligne :
# A130 : source $audace(rep_scripts)/spcaudace/spc_profil.tcl
# A140 : source [ file join $audace(rep_plugin) tool spcaudace spc_profil.tcl ]
#
#####################################################################################


# Remarque : il faut mettre remplacer toutes les variables textes par des variables caption(mauclaire,...)
# qui seront initialisées dans le fichier cap_mauclaire.tcl
# et renommer ce fichier mauclaire.tcl ;-)


# Mise a jour $Id: spc_profil.tcl 14525 2018-11-09 18:22:10Z bmauclaire $


###############################################################################
# Procédure de changement du mode d'affichage des profils
# Auteur : Benjamin MAUCLAIRE
# Date création :  28-12-2013
# Date de mise à jour : 28-12-2013
################################################################################

proc spc_displaymode { args } {
   global spcaudace

   if { [ llength $args ]==1 } {
      set mode [ lindex $args 0 ]
   } else {
      ::console::affiche_erreur "Usage: spc_displaymode spline/real\n"
      return
   }

   if { $mode=="spline" } {
      set spcaudace(display_real) 0
      ::console::affiche_resultat "Mode lissé activé pour les prochains affichages.\n"
   } elseif { $mode=="real" } {
      set spcaudace(display_real) 1
      ::console::affiche_resultat "Mode réél (escaliers) activé pour les prochains affichages.\n"
   }
}
#*********************************************************#



####################################################################
# Nettoie les mots clefs finissant en 2 :
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 11-10-2011
# Date modification : 11-04-2011
# Arguments : numero du buffer
####################################################################

proc spc_header1d { args } {
   global conf
   global audace

   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set numbuf [ lindex $args 0 ]

      #--- Recupere les infos du spectre :
      set totkwd [ buf$numbuf getkwds ]
      set listkwd_index [ lsearch -all $totkwd "*2" ]

      #--- Initialise les intensites a yval :
      foreach kwdind $listkwd_index {
         set keywd [ lindex $totkwd $kwdind ]
         if { $keywd!="TT2" && $keywd!="SPC_SLX2" && $keywd!="TT12" && $keywd!="TT22" } {
            buf$numbuf delkwd "$keywd"
         }
      }

      #--- Traitement des autres cas :
      if { [ lsearch $totkwd "CD1_1" ] != -1 } {
         buf$numbuf delkwd "CD1_1"
      }
      if { [ lsearch $totkwd "CD2_1" ] != -1 } {
         buf$numbuf delkwd "CD2_1"
      }
   } else {
      ::console::affiche_erreur "Usage: spc_header1d numoero_buffer\n"
   }
}
#****************************************************************#



####################################################################
# Cree un profil de raies fits d'une varleur y donee
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 02-11-2010
# Date modification : 02-11-2010
# Arguments : nom_profil_raies_modele yval
####################################################################

proc spc_syntherule { args } {
   global conf
   global audace

   set nbargs [ llength $args ]
   if { $nbargs==2 } {
      set filename [ lindex $args 0 ]
      set yval [ lindex $args 1 ]

      #--- Recupere les infos du spectre :
      buf$audace(bufNo) load "$audace(rep_images)/$filename"
      set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]

      #--- Initialise les intensites a yval :
      for {set k 0} {$k<$naxis1} {incr k} {
         buf$audace(bufNo) setpix [ list [ expr $k+1 ] 1 ] $yval
      }

      #--- Enregistrement du resultat :
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/${filename}_conti$conf(extension,defaut)"
      buf$audace(bufNo) bitpix short
      return "${filename}_conti"
   } else {
      ::console::affiche_erreur "Usage: spc_syntherule nom_profil_raies_modele yval\n"
   }
}
#****************************************************************#



###############################################################
#
# Extraction du profil a partir du spectre x,y
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 31-01-2005
# Arguments : fichier fits du spectre spatial
###############################################################

proc spc_extract_profil_zone { args } {

    #****************************************************************#
    ## Chargement : source $audace(rep_scripts)/profil_raie.tcl
    ## Les var nommees audace_* sont globales
    global audace caption
    global audela
    ## flag audace
    global conf
    global flag_ok

    if { [ llength $args ]<=1 } {
	if { [ llength $args ]==1 } {
	    set filespacialspc [ file tail [ file rootname [ lindex $args 0 ] ] ]
	} elseif { [llength $args]==0 } {
	    set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	    if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
		set filespacialspc "$spctrouve"
	    } else {
		::console::affiche_erreur "Usage: spc_extract_profil_zone spectre_2D\n\n"
		return 0
	    }
	} else {
	    ::console::affiche_erreur "Usage: spc_extract_profil_zone spectre_2D\n\n"
	    return 0
	}


	#--- Sélection de la zone à binner :
	loadima "$filespacialspc"
	#-- Algo :
	::console::affiche_resultat "Sélection de la fenetre d'etude.\n"
	## On affiche un message demandant de sélectionner la zone d'étude
	## Lecture des coordonnees de la ligne centrale du spectre
	## Cree une liste de nom coords contenant les coordonnes d'un rectangle scroole avec la souris (demarre a 0)
	set flag_ok 0

	#-- Création de la fenêtre :
	if { [ winfo exists .benji ] } {
	    destroy .benji
	}
	toplevel .benji
	wm geometry .benji
	wm title .benji "Get zone"
	wm transient .benji .audace

	#--- Textes d'avertissement
	label .benji.lab -text "Sélectionnez la zone du spectre..."
	pack .benji.lab -expand true -expand true -fill both

	#--- Sous-trame pour boutons
	frame .benji.but
	pack .benji.but -expand true -fill both

	#--- Bouton "Ok"
	button .benji.but.1  -command {set flag_ok 1} -text "Ok"
	pack .benji.but.1 -side left -expand true -fill both
	#--- Bouton "Annuler"
	button .benji.but.2 -command {set flag_ok 2} -text "Annuler"
	pack .benji.but.2 -side right -expand true -fill both

	## Attend que la variable $flag_ok change
	vwait flag_ok

	if { $flag_ok == "1" } {
	    set coords_zone [ ::confVisu::getBox 1 ]
	    set flag_ok 2
	    destroy .benji
	} elseif { $flag_ok == "2" } {
	    set flag_ok 2
	    destroy .benji
            return 0
	    #### Bug ici - Affiche un profil quand on appuie sur le bouton Annuler de la boite "Get zone"
	}

	#::console::affiche_resultat "$flag_ok\n"
	## coords contient : { x1 y1 x2 y2 }
	##  -----------B
	##  |          |
	##  A-----------
	## set coords { 1 50 599 24 }

	## On initialise :
	## ysup=ordonnée max. de la boîte sélectionnée
	## yinf=aordonnée min. de la boîte sélectionnée
	## ht_spectre="hauteur" en pixels du spectre
	## ht_dessus=hauteur d'image au dessus du spectre
	## ht_dessous=hauteur d'image au dessous du spectre
	## xmax_zone=abscisse max. de la zonne sélectionnée
	## xmin_zone=abscisse min. de la zonne sélectionnée
	## naxis2=hauteur de l'image.
	if {[lindex $coords_zone 1]<[lindex $coords_zone 3]} {
	    set ysup [lindex $coords_zone 3]
	    set yinf [lindex $coords_zone 1]
	} else {
	    set yinf [lindex $coords_zone 3]
	    set ysup [lindex $coords_zone 1]
	}
	set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
	set ht_spectre [expr $ysup-$yinf]
	set ht_dessus [expr $naxis2-$ysup]
	set ht_dessous [expr $yinf]
	set xsup_zone [lindex $coords_zone 0]
	set xinf_zone [lindex $coords_zone 2]

	## creation d'un fichier contenant la zone selectionnee
	# buf$audace(bufNo) window $coords_zone
	if { [::confVisu::getBox 1] != "" } {
	    buf$audace(bufNo) window $coords_zone
	    #--- Suppression de la zone selectionnee avec la souris
	    ::confVisu::deleteBox 1
	} else {
	    ::console::affiche_erreur "Usage: Select zone with mouse\n\n"
	}

	# ::console::affiche_resultat "$coords_zone ; ${filespacialspc}_zone\n"
	# ::audace::conserve_seuils
       buf$audace(bufNo) save "$audace(rep_images)/${filespacialspc}_zone"

	##--------------- Traitement de la zone selectionnee -------------------#
	set listcoords [ list $ht_spectre $yinf $ysup $xinf_zone $xsup_zone $ht_dessous $ht_dessus ]
	set listeargs [ list "${filespacialspc}_zone" "$filespacialspc" $listcoords ]
	set fileout [ spc_bin "${filespacialspc}_zone" "$filespacialspc" $listcoords ]

	#--- Traitement des résultats :
	::console::affiche_resultat "Profil de raies de la zone sélectionnéé sauvé sous $fileout\n"
	return "$fileout"
    } else {
	::console::affiche_erreur "Usage: spc_extract_profil_zone spectre_2D\n\n"
    }
}
###############################################################


###############################################################
# Extrait une zone d'un spectre 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 04-03-2006
# Date de mise a jour : 04-03-2006
# Arguments : fichier fits du spectre spatial
###############################################################
proc spc_extract_zone { args } {

    global audace caption
    global conf
    global flag_ok

    if {[llength $args] <= 1} {
	if {[llength $args] == 1} {
	    set filespacialspc [ file rootname [lindex $args 0] ]
	} elseif { [llength $args]==0 } {
	    set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	    if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
		set filespacialspc $spctrouve
	    } else {
		::console::affiche_erreur "Usage: spc_extract_zone spectre_2D_fits\n\n"
	       return 0
	    }
	} else {
	    ::console::affiche_erreur "Usage: spc_extract_zone spectre_2D_fits\n\n"
	    return 0
	}

	#--- Traitement :
	# Retire l'extension .fit du nom du fichier
	# regsub -all .fit $filespacialspc - filespatialspc
	## Verif existence
	#if {[file exist [file join $audace(rep_images)/$filespacialspc.$conf(extension,defaut)]]==1}
	# buf$audace(bufNo) load "$audace(rep_images)/$filespacialspc"
	loadima "$filespacialspc"
	::console::affiche_resultat "Sélection de la fenetre d'etude.\n"

	## On affiche un message demandant de sélectionner la zone d'étude
	## Lecture des coordonnees de la ligne centrale du spectre
	## Cree une liste de nom coords contenant les coordonnes d'un rectangle scroole avec la souris (demarre a 0)
	set flag_ok 0
	# Création de la fenêtre
	if { [ winfo exists .benji ] } {
	    destroy .benji
	}
	toplevel .benji
	wm geometry .benji
	wm title .benji "Get zone"
	wm transient .benji .audace

	#--- Textes d'avertissement
	label .benji.lab -text "Sélectionnez la zone du spectre..."
	pack .benji.lab -expand true -expand true -fill both

	#--- Sous-trame pour boutons
	frame .benji.but
	pack .benji.but -expand true -fill both

	#--- Bouton "Ok"
	button .benji.but.1  -command {set flag_ok 1} -text "Ok"
	pack .benji.but.1 -side left -expand true -fill both
	#--- Bouton "Annuler"
	button .benji.but.2 -command {set flag_ok 2} -text "Annuler"
	pack .benji.but.2 -side right -expand true -fill both

	## Attend que la variable $flag_ok change
	vwait flag_ok

	if { $flag_ok == "1" } {
	    set coords_zone [::confVisu::getBox 1]
	    set flag_ok 2
	    destroy .benji
	} elseif { $flag_ok == "2" } {
	    set flag_ok 2
	    destroy .benji
            return 0
	    #### Bug ici - Affiche un profil quand on appuie sur le bouton Annuler de la boite "Get zone"
	}

	#::console::affiche_resultat "$flag_ok\n"
	## coords contient : { x1 y1 x2 y2 }
	##  -----------B
	##  |          |
	##  A-----------
	## set coords { 1 50 599 24 }

	## Création d'un fichier contenant la zone selectionnee
	if { [::confVisu::getBox 1] != "" } {
	    buf$audace(bufNo) window $coords_zone
	    #--- Suppression de la zone selectionnee avec la souris
	    ::confVisu::deleteBox 1
	} else {
	    ::console::affiche_erreur "Usage: Select zone with mouse\n\n"
	}

        #--- Nettoie les mots clefs finissant en 2 :
        spc_header1d $audace(bufNo)

        buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${filespacialspc}_zone"
        buf$audace(bufNo) bitpix short
	return "${filespacialspc}_zone"
    } else {
	::console::affiche_erreur "Usage: spc_extract_zone spectre_2D_fits\n\n"
    }
}
###############################################################


###############################################################
# Soustrait le fond de ciel avec BACK et crée le profil de raie d'une zone d'un spectre 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 04-03-2006
# Date de mise a jour : 04-03-2006
# Arguments : fichier fits du spectre spatial
###############################################################

proc spc_profil_zone { args } {

    global audace caption
    global conf

    if {[llength $args] <= 1} {
	if {[llength $args] == 1} {
	    set filespacialspc [ file rootname [lindex $args 0] ]
	} elseif { [llength $args]==0 } {
	    set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	    if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
		set filespacialspc $spctrouve
	    } else {
		::console::affiche_erreur "Usage: spc_profil_zone spectre_2D_fits\n\n"
	       return 0
	    }
	} else {
	    ::console::affiche_erreur "Usage: spc_profil_zone spectre_2D_fits\n\n"
	    return 0
	}

	#--- Détermination de la zone du spectre :
	set results [ spc_detect $filespacialspc ]
	set ycenter [ lindex $results 0 ]
	set hauteur [ lindex $results 1 ]

	#--- Soustrait le fond de ciel
	set sp_propre [ spc_subsky $filespacialspc $ycenter $hauteur med ]
	#--- Sélectionne la zone à étudier
	set sp_zone [ spc_extract_zone $sp_propre ]
	file delete -force "$audace(rep_images)/$sp_propre$conf(extension,defaut)"
	#--- Crée le profil de raies
	buf$audace(bufNo) load "$audace(rep_images)/$sp_zone"
	set ht_spectre [ lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
	set listeargs [ list "$sp_zone" $ht_spectre ]
	#set fileout [ spc_bins $listeargs ]
	set fileout [ spc_bins "$sp_zone" ]

	#--- Traitement des résultats :
	::console::affiche_resultat "Profil de raies sauvé sous $fileout\n"
	return $fileout
    } else {
	::console::affiche_erreur "Usage: spc_profil_zone spectre_2D_fits\n\n"
    }
}
###############################################################



###############################################################
# Détermine le centre vertical et la largeur d'un spectre 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 27-08-2005
# Date de mise a jour : 27-08-2005
# Arguments : fichier fits du spectre spatial
###############################################################

proc spc_detect { args } {

    global audace spcaudace
    global conf
    #-- Fraction des bords coupée :
    set fraction_bord 0.05

    if { [ llength $args ] == 1 } {
	set filenamespc_spacial [ lindex $args 0 ]

	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_spacial"
	set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1]
	set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1]
	set x1 [ expr int($fraction_bord*$naxis1) ]
	set x2 [ expr int((1.-$fraction_bord)*$naxis1) ]
	set y1 [ expr int($fraction_bord*$naxis2) ]
	set y2 [ expr int((1.-$fraction_bord)*$naxis2) ]
	#- Meth1 :
	# set windowcoords [ list 1 $y1 1 $y2 ]
	set windowcoords [ list $x1 $y1 $x2 $y2 ]

	#buf$audace(bufNo) binx 1 $naxis1 3
	#set ycentre [lindex [ buf$audace(bufNo) centro $windowcoords ] 1]

	#- Meth1 :
	# buf$audace(bufNo) binx 1 $naxis1 1
	#buf$audace(bufNo) imaseries "binx x1=$x1 x2=$x2 width=1"
	buf$audace(bufNo) imaseries "medianx x1=$x1 x2=$x2 width=1"
	set gparams [ buf$audace(bufNo) fitgauss $windowcoords ]
	set ycenter [ lindex $gparams 5 ]
	# Choix : la largeur de la gaussienne est de 3*FWHM
	set largeur [ expr $spcaudace(clfwhm_binning)*[ lindex $gparams 6 ] ]
	return [ list $ycenter $largeur ]
    } else {
	::console::affiche_erreur "Usage: spc_detect spectre_2D_fits\n\n"
    }
}
###############################################################




###############################################################
# Détermine le centre vertical et la largeur d'un spectre 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 11-04-2008
# Date de mise a jour : 11-04-2008
# Arguments : fichier fits du spectre spatial
###############################################################

proc spc_detectmoy { args } {

    global audace spcaudace
    global conf
    #-- Fraction des bords coupée :
    set fraction_bord 0.05

    if { [ llength $args ] == 1 } {
	set filenamespc_spacial [ lindex $args 0 ]

	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_spacial"
	set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1]
	set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1]
	set x1 [ expr int($fraction_bord*$naxis1) ]
	set x2 [ expr int((1.-$fraction_bord)*$naxis1) ]
	set y1 [ expr int($fraction_bord*$naxis2) ]
	set y2 [ expr int((1.-$fraction_bord)*$naxis2) ]
	#- Meth1 :
	# set windowcoords [ list 1 $y1 1 $y2 ]
	set windowcoords [ list $x1 $y1 $x2 $y2 ]

	#buf$audace(bufNo) binx 1 $naxis1 3
	#set ycentre [lindex [ buf$audace(bufNo) centro $windowcoords ] 1]

	#- Meth1 :
	# buf$audace(bufNo) binx 1 $naxis1 1
	#buf$audace(bufNo) imaseries "binx x1=$x1 x2=$x2 width=1"
	buf$audace(bufNo) imaseries "medianx x1=$x1 x2=$x2 width=1"
	set gparams [ buf$audace(bufNo) fitgauss $windowcoords ]
	set ycenter [ lindex $gparams 5 ]
	# Choix : la largeur de la gaussienne est de 1.7*FWHM
	set largeur [ expr $spcaudace(cmfwhm_binning)*[ lindex $gparams 6 ] ]
	return [ list $ycenter $largeur ]
    } else {
	::console::affiche_erreur "Usage: spc_detectmoy spectre_2D_fits\n\n"
    }
}
###############################################################


###############################################################
# Détermine le centre vertical et la largeur d'un spectre 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 11-04-2008
# Date de mise a jour : 12-04-2008
# Arguments : fichier fits du spectre spatial
###############################################################

proc spc_detectserre2 { args } {

    global audace
    global conf
    #-- Fraction des bords coupée :
    set fraction_bord 0.05

    if { [ llength $args ] == 1 } {
	set filenamespc_spacial [ lindex $args 0 ]

	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_spacial"
	set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1]
	set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1]
	set x1 [ expr int($fraction_bord*$naxis1) ]
	set x2 [ expr int((1.-$fraction_bord)*$naxis1) ]
	set y1 [ expr int($fraction_bord*$naxis2) ]
	set y2 [ expr int((1.-$fraction_bord)*$naxis2) ]
	#- Meth1 :
	# set windowcoords [ list 1 $y1 1 $y2 ]
	set windowcoords [ list $x1 $y1 $x2 $y2 ]

	#buf$audace(bufNo) binx 1 $naxis1 3
	#set ycentre [lindex [ buf$audace(bufNo) centro $windowcoords ] 1]

	#- Meth1 :
	# buf$audace(bufNo) binx 1 $naxis1 1
	buf$audace(bufNo) imaseries "binx x1=$x1 x2=$x2 width=1"
	set gparams [ buf$audace(bufNo) fitgauss $windowcoords ]
	set ycenter [ lindex $gparams 5 ]
	# Choix : la largeur de la gaussienne est de 1.7*FWHM
	set largeur [ expr 1.6*[ lindex $gparams 6 ] ]
	return [ list $ycenter $largeur ]
    } else {
	::console::affiche_erreur "Usage: spc_detecserre2 spectre_2D_fits\n\n"
    }
}
###############################################################



###############################################################
# Détermine le centre vertical et la largeur d'un spectre 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 23-06-2006
# Date de mise a jour : 8-02-2011
# Arguments : fichier fits du spectre 2D
###############################################################

proc spc_detectasym { args } {

    global audace spcaudace
    global conf

    #-- Rappel des valeurs des paramètres par defaut :
    set largeur_binning 1
    # set epaisseur_detect 0.05
    # set nb_coupes 10
    # set nb_coupes 5
    #-- 20 % des bords ecartes :
    set pourcent_bord [ expr $spcaudace(epaisseur_detect)*4 ]


    if { [ llength $args ] == 1 } {
       set filenamespc [ file rootname [lindex $args 0 ] ]

       #--- Binning de toute l'image :
       buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
       set xmid [ expr round($naxis1/2.) ]
       set naxis2 [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
       set xfin [ expr int((1-$pourcent_bord)*$naxis1) ]
       #set xdeb [ expr int($naxis1/$spcaudace(nb_coupes)) ]
       set xdeb [ expr int($pourcent_bord*$naxis1) ]
       #buf$audace(bufNo) imaseries "binx x1=$xdeb x2=$xfin height=1"
       buf$audace(bufNo) imaseries "medianx x1=$xdeb x2=$xfin width=1"
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_spcx"
       #set icont [ lindex [ buf$audace(bufNo) stat ] 4 ]
       #buf$audace(bufNo) bitpix short

       #--- Détermination des paramètres du de l'épaisseur du spectre sur la coupe verticale :
       if { [ lsearch $listemotsclef "SPC_YBIN" ] !=-1 } {
          set ycenter [ lindex [ buf$audace(bufNo) getkwd "SPC_YBIN" ] 1 ]
          set yinf [ expr int($ycenter-5*$spcaudace(epaisseur_bin)/2.) ]
          if { $yinf<1 } { set yinf 3 }
          set ysup [ expr int($ycenter+5*$spcaudace(epaisseur_bin)/2.) ]
          if { $ysup>$naxis2 } { set ysup [ expr $naxis2-3 ] }
          set gparams [ buf$audace(bufNo) fitgauss [ list 1 $yinf 1 $ysup ] ]
          set hauteur [ expr $spcaudace(cafwhm_binning)*[ lindex $gparams 6 ] ]
       } else {
          #set y1 [ expr int(.03*$naxis2) ]
          #set y2 [ expr int(.97*$naxis2) ]
          set y1 [ expr int($pourcent_bord*$naxis2) ]
          set y2 [ expr int((1-$pourcent_bord)*$naxis2) ]
          set windowcoords [ list 1 $y1 1 $y2 ]
          set gparams [ buf$audace(bufNo) fitgauss $windowcoords ]
          set ycenter [ lindex $gparams 5 ]
          # set ycenter [ lindex [ buf$audace(bufNo) centro $windowcoords ] 1 ]
          #-- Choix : la largeur de la gaussienne est de 1.9*FWHM
          set hauteur [ expr $spcaudace(cafwhm_binning)*[ lindex $gparams 6 ] ]
       }

       #--- Traitement des resultats :
       file delete -force "$audace(rep_images)/${filenamespc}_spcx$conf(extension,defaut)"
       return [ list $ycenter $hauteur ]
    } else {
       ::console::affiche_erreur "Usage: spc_detectasym spectre_2D_fits\n\n"
    }
}
###############################################################


###############################################################
# Détermine le centre vertical et la largeur d'un spectre 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 23-06-2006
# Date de mise a jour : 23-06-2006
# Arguments : fichier fits du spectre 2D
###############################################################

proc spc_detectasym1 { args } {

    global audace spcaudace
    global conf

    #-- Rappel des valeurs des paramètres par defaut :
    set largeur_binning 1
    # set epaisseur_detect 0.05
    # set nb_coupes 10
    # set nb_coupes 5


    if { [ llength $args ] == 1 } {
	set fichier [ file rootname [lindex $args 0 ] ]
	buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1]
	set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1]
	set x_fin [ expr (1-$spcaudace(epaisseur_detect))*$naxis1 ]

	#--- Creations de profils de plusieurs colonnes
	set xpas [ expr int($naxis1/$spcaudace(nb_coupes)) ]
	#-- n° du profil resultant
	::console::affiche_resultat "Pas entre chaque point de détection : $xpas\n"
	set i 1
	for {set k $xpas} {$k <= $x_fin} {incr k} {
	    set fsortie [ file rootname [ spc_profilx $fichier $k $largeur_binning ] ]
	    # ::console::affiche_resultat "$fsortie\n"
	    file rename -force "$audace(rep_images)/$fsortie$conf(extension,defaut)" "$audace(rep_images)/profil-$i$conf(extension,defaut)"
	    set k [ expr $k+$xpas-1 ]
	    incr i
	}
	set nbimg [ expr $i-1 ]
	#sadd profil- ${fichier}_spcx $nbimg
	smean profil- ${fichier}_spcx $nbimg
	delete2 profil- $nbimg

	#--- Détermination des paramètres du de l'épaisseur du spectre sur la coupe verticale
	buf$audace(bufNo) load "$audace(rep_images)/${fichier}_spcx"
	##set windowcoords [ list 1 1 $naxis2 1 ]
        #set y1 [ expr int(.03*$naxis2) ]
        #set y2 [ expr int(.97*$naxis2) ]
        set y1 [ expr int($spcaudace(epaisseur_detect)*$naxis2) ]
        set y2 [ expr int((1-$spcaudace(epaisseur_detect))*$naxis2) ]
	set windowcoords [ list 1 $y1 1 $y2 ]
	set gparams [ buf$audace(bufNo) fitgauss $windowcoords ]
	set ycenter [ lindex $gparams 5 ]
	#-- Choix : la largeur de la gaussienne est de 1.9*FWHM
	set largeur [ expr 1.9*[ lindex $gparams 6 ] ]
	file delete -force "$audace(rep_images)/${fichier}_spcx$conf(extension,defaut)"
	return [ list $ycenter $largeur ]
    } else {
	::console::affiche_erreur "Usage: spc_detectasym spectre_2D_fits\n\n"
    }
}
###############################################################



###############################################################
# Détermine le centre vertical et la largeur d'un spectre 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 23-06-2006
# Date de mise a jour : 23-06-2006
# Arguments : fichier fits du spectre 2D
###############################################################

proc spc_detectasym0 { args } {

    global audace spcaudace
    global conf

    #-- Rappel des valeurs des paramètres par defaut :
    set largeur_binning 1
    # set epaisseur_detect 0.05
    # set nb_coupes 10
    # set nb_coupes 5


    if { [ llength $args ] == 1 } {
	set fichier [ file rootname [lindex $args 0 ] ]
	buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1]
	set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1]
	set x_fin [ expr (1-$spcaudace(epaisseur_detect))*$naxis1 ]

	#--- Creations de profils de plusieurs colonnes
	set xpas [ expr int($naxis1/$spcaudace(nb_coupes)) ]
	#-- n° du profil resultant
	::console::affiche_resultat "Pas entre chaque point de détection : $xpas\n"
	set i 1
	for {set k $xpas} {$k <= $x_fin} {incr k} {
	    set fsortie [ file rootname [ spc_profilx $fichier $k $largeur_binning ] ]
	    # ::console::affiche_resultat "$fsortie\n"
	    file rename -force "$audace(rep_images)/$fsortie$conf(extension,defaut)" "$audace(rep_images)/profil-$i$conf(extension,defaut)"
	    set k [ expr $k+$xpas-1 ]
	    incr i
	}
	set nbimg [ expr $i-1 ]
	#sadd profil- ${fichier}_spcx $nbimg
	smean profil- ${fichier}_spcx $nbimg
	delete2 profil- $nbimg

	#--- Détermination des paramètres du de l'épaisseur du spectre sur la coupe verticale
	buf$audace(bufNo) load "$audace(rep_images)/${fichier}_spcx"
	##set windowcoords [ list 1 1 $naxis2 1 ]
        #set y1 [ expr int(.03*$naxis2) ]
        #set y2 [ expr int(.97*$naxis2) ]
        set y1 [ expr int($spcaudace(epaisseur_detect)*$naxis2) ]
        set y2 [ expr int((1-$spcaudace(epaisseur_detect))*$naxis2) ]
	set windowcoords [ list 1 $y1 1 $y2 ]
	set gparams [ buf$audace(bufNo) fitgauss $windowcoords ]
	set ycenter [ lindex $gparams 5 ]
	#-- Choix : la largeur de la gaussienne est de 1.9*FWHM
	set largeur [ expr 1.9*[ lindex $gparams 6 ] ]
	file delete -force "$audace(rep_images)/${fichier}_spcx$conf(extension,defaut)"
	return [ list $ycenter $largeur ]
    } else {
	::console::affiche_erreur "Usage: spc_detectasym spectre_2D_fits\n\n"
    }
}
###############################################################



###############################################################
# Soustrait le fond de ciel à un spectre 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 04-03-2006
# Date de mise a jour : 04-03-2006
# Arguments : fichier fits du spectre spatial
###############################################################

proc spc_subskyfrac { args } {

    global audace
    global conf

    if {[llength $args] == 1} {
	set filespacialspc [ file rootname [lindex $args 0] ]
	buf$audace(bufNo) load "$audace(rep_images)/$filespacialspc"
	buf$audace(bufNo) imaseries "BACK back_kernek=15 back_threshold=0.2 sub"
	# buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${filespacialspc}_fc"
	buf$audace(bufNo) bitpix short
	return ${filespacialspc}_fc
    } else {
	::console::affiche_erreur "Usage: spc_subskyfrac spectre_2D_fits\n\n"
    }
}
###############################################################


###############################################################
# Soustrait le fond de ciel sur une série de spectres 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 06-03-2006
# Date de mise a jour : 06-03-2006
# Arguments : nom gégérique des fichiers fits du spectre spatial
###############################################################

proc spc_subskiesfrac { args } {

    global audace
    global conf

    if {[llength $args] == 1} {
	set nom_generique [lindex $args 0]
	set liste_fichiers [ lsort -dictionary [glob ${nom_generique}\[0-9\]*$conf(extension,defaut)] ]
	set nbimg [ llength $liste_fichiers ]
	::console::affiche_resultat "$nbimg fichiers à traiter.\n"
	set i 1

	foreach fichier $liste_fichiers {
	    buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	    buf$audace(bufNo) imaseries "BACK back_kernek=15 back_threshold=0.2 sub"
	    buf$audace(bufNo) save "$audace(rep_images)/${nom_generique}fc-$i"
	    incr i
	}
	return ${nom_generique}fc-
    } else {
	::console::affiche_erreur "Usage: spc_subskies nom générique spectres_2D_fits\n\n"
    }
}
#*********************************************************************#



###############################################################
# Soustrait le fond de ciel sur une série de spectres 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 26-07-2006
# Date de mise a jour : 26-07-2006
# Arguments : nom du spectre 2D netoye du fond de ciel à binner
###############################################################

proc spc_binlopt { args } {

    global audace
    global conf

    if { [llength $args] == 3 } {
	set spectre2d [ lindex $args 0 ]
	set ycentre [ expr round([ lindex $args 1 ]) ]
	set ylargeur [ lindex $args 2 ]

	#--- Détermine les limites adaptées du binning :
	set dy [ expr int($ylargeur*.5-1)+1 ]
	set yinf [ expr $ycentre-int($dy) ]
	set ysup [ expr $ycentre+int($dy) ]
	set htr [ expr $dy*2 ]
	if { $dy != 0.5 } {
	    ::console::affiche_resultat "Hauteur de binning : $htr\n"
	}

	#--- Effectue le binning optimise par la mathode de Roberval (lopt de tt_user2.c)
	set yepaisseur [ expr $ylargeur-3 ]
	if { $yepaisseur<=4. } {
	    ::console::affiche_resultat "Épaisseur de binning de Roberval trop faible. Mise à 5 pixels.\n"
	    #return ""
	    set ylargeur 5.
	    set dy [ expr int($ylargeur*.5-1)+1 ]
	    set yinf [ expr $ycentre-int($dy) ]
	    set ysup [ expr $ycentre+int($dy) ]
	}
	buf$audace(bufNo) load "$audace(rep_images)/$spectre2d"
	buf$audace(bufNo) imaseries "LOPT y1=$yinf y2=$ysup height=1"

        #--- Nettoie les mots clefs finissant en 2 :
        spc_header1d $audace(bufNo)

	#--- SAuvegarde du profil 1D
	buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 double "" ""]
	buf$audace(bufNo) setkwd [list "CDELT1" 1.0 double "" ""]
        buf$audace(bufNo) setkwd [ list "CRPIX1" 1 double "Reference pixel" "pixel" ]
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${spectre2d}_spc"
	buf$audace(bufNo) bitpix short
	::console::affiche_resultat "Profil de raies sauvé sous ${spectre2d}_spc$conf(extension,defaut)\n"
	return ${spectre2d}_spc
    } else {
	::console::affiche_erreur "Usage: spc_binlopt nom_spectres_2D_fits ycentre ylargeur_a_binner\n\n"
    }
}
#*********************************************************************#


###############################################################
# Procédure : soustrait le fond de ciel à la zone du spectre détectée
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 05-07-2006
# Date de modification : 05-07-2006 ; 9-5-2018
# Arguments : spectre_2D_fits y_centre_spectre hauteur_spectre méthode_soustraction_fond_de_ciel (moy, moy2, med, inf, sup, none, back) ?flag_nebula?
###############################################################

proc spc_subsky { args } {

    global audace spcaudace
    global conf

    if { [ llength $args ] == 4 } {
	set spectre [ lindex $args 0 ]
	set ycenter [ lindex $args 1 ]
	set hauteur [ lindex $args 2 ]
	set methodemoy [ lindex $args 3 ]

	::console::affiche_resultat "ycenter : $ycenter ; hauteur : $hauteur\n"
	#--- Initialisation de paramètres
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
	set naxis2 [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]

	#--- Passe en entier ycenter et hauteur pour le decoupage de zones de meme taille :
	## [ expr $ycenter+0.5*$hauteur-(int($ycenter+0.5*$hauteur)+1) ] >= 0.5
	#if { [ expr $ycenter-int($ycenter) ] > 0.5 } {
	#    set ycenter [ expr int($ycenter)+1 ]
	#} else {
	#    set ycenter [ expr int($ycenter) ]
	#}
	#if { [ expr $hauteur-int($hauteur) ] > 0.5 } {
	#    set hauteur [ expr int($hauteur)+1 ]
	#} else {
	#    set hauteur [ expr int($hauteur) ]
	#}
	set ycenter [ expr round($ycenter) ]
	set hauteur [ expr round($hauteur) ]

	#--- Découpage de zone où se trouve le spectre :
	#--  -----------B
	#--  |          |
	#--  A-----------
	set coords_zone_spectre [ list 1 [expr round($ycenter-0.5*$hauteur)] $naxis1 [expr round($ycenter+0.5*$hauteur)] ]
	::console::affiche_resultat "Zone du spectre : $coords_zone_spectre\n"
	#--- Découpage de la zone où se trouve le spectre
	buf$audace(bufNo) window $coords_zone_spectre
        buf$audace(bufNo) setkwd [ list "SPC_HBIN" $hauteur float "Binning thickness" "pixel" ]
        buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone"
	set hauteurzone [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
       
	#--- Découpage de la zone supérieure pour le fond de ciel :
	set coords_zone_sup [ list 1 [expr round($ycenter+1.5*$hauteur)] $naxis1 [expr round($ycenter+2.5*$hauteur)] ]
	::console::affiche_resultat "Zone supérieure : $coords_zone_sup\n"
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	buf$audace(bufNo) window $coords_zone_sup
        buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zonesup"

	#--- Découpage de la zone inférieure pour le fond de ciel :
	set coords_zone_inf [ list 1 [expr round($ycenter-1.5*$hauteur)] $naxis1 [expr round($ycenter-2.5*$hauteur)] ]
	::console::affiche_resultat "Zone inférieure : $coords_zone_inf\n"
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	buf$audace(bufNo) window $coords_zone_inf
        buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zoneinf"
        buf$audace(bufNo) bitpix short

	#--- Calcul de la moyenne du fond de ciel et la soustrait :
	if { $methodemoy == "moy" } {

	    #--- Somme moyenne des zones sup et inf :
	    ::console::affiche_resultat "Soustraction du fond de ciel : moyenne des 2 zones.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zoneinf" 0
	    buf$audace(bufNo) mult -0.5
	    uncosmic $spcaudace(uncosmic)
	    uncosmic $spcaudace(uncosmic)
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
            buf$audace(bufNo) bitpix float
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
            buf$audace(bufNo) bitpix short
            #ttscript2 "IMA/STACK . \"zone_inf zone_sup\" * * .fit \"./\" zone_fdc_med . .fit MED  bitpix=32"
	} elseif { $methodemoy == "med" } {

	    #--- Somme médiane des colonne pour chaque zone puis moyenne :
	    ::console::affiche_resultat "Soustraction du fond de ciel : médiane des colonnes de chaque zone.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set haut [ lindex [ buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
	    buf$audace(bufNo) imaseries "MEDIANY y1=1 y2=$haut height=$hauteurzone"
            buf$audace(bufNo) bitpix float
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zonesupmed"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zoneinf"
	    set haut [ lindex [ buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
	    buf$audace(bufNo) imaseries "MEDIANY y1=1 y2=$haut height=$hauteurzone"
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zonesupmed" 0
	    buf$audace(bufNo) mult -0.5
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
            buf$audace(bufNo) bitpix float
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	    file delete -force "$audace(rep_images)/${spectre}_zonesupmed$conf(extension,defaut)"
            buf$audace(bufNo) bitpix short
	} elseif { $methodemoy == "moy2" } {

	    #--- Moyenne de la valeur des fonds de ciel tirés des 2 zones :
	    ::console::affiche_resultat "Soustraction du fond de ciel : moyenne des 2 fonds.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set moysup [ lindex [ buf$audace(bufNo) stat ] 6 ]
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zoneinf"
	    set moyinf [ lindex [ buf$audace(bufNo) stat ] 6 ]
	    set moy [ expr -0.5*($moysup+$moyinf) ]
	    #-- Crée une image uniforme d'intensité égale à la moyenne des fonds de ciel
	    #buf$audace(bufNo) clear
	    set haut [ expr int($hauteur)+1 ]
	    buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 $haut FORMAT_USHORT COMPRESS_NONE 0
	    buf$audace(bufNo) setkwd [ list "NAXIS" 2 int "" "" ]
	    buf$audace(bufNo) setkwd [ list "NAXIS1" $naxis1 int "" "" ]
	    buf$audace(bufNo) setkwd [ list "NAXIS2" $haut int "" "" ]
	    buf$audace(bufNo) offset $moy
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
            buf$audace(bufNo) bitpix float
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
            buf$audace(bufNo) bitpix short
	} elseif { $methodemoy == "back" } {

	    #--- Méthode du BACK :
	    ::console::affiche_resultat "Soustraction du fond de ciel : méthode fraction.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	    buf$audace(bufNo) imaseries "BACK back_kernek=30 back_threshold=0.2 sub"
	    buf$audace(bufNo) window $coords_zone_spectre
            buf$audace(bufNo) bitpix float
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
            buf$audace(bufNo) bitpix short
	} elseif { $methodemoy == "sup" } {

	    #--- Soustraction du fond de ciel d'une zone dessus le spectre :
	    ::console::affiche_resultat "Soustraction du fond de ciel d'une zone dessus le spectre.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set moy [expr -1.*[ lindex [ buf$audace(bufNo) stat ] 6 ] ]
	    #-- Crée une image uniforme d'intensité égale à la moyenne des fonds de ciel
	    set haut [ expr int($hauteur)+1 ]
	    buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 $haut FORMAT_USHORT COMPRESS_NONE 0
	    buf$audace(bufNo) setkwd [ list "NAXIS" 2 int "" "" ]
	    buf$audace(bufNo) setkwd [ list "NAXIS1" $naxis1 int "" "" ]
	    buf$audace(bufNo) setkwd [ list "NAXIS2" $haut int "" "" ]
	    buf$audace(bufNo) offset $moy
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
            buf$audace(bufNo) bitpix float
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
            buf$audace(bufNo) bitpix short
	} elseif { $methodemoy == "inf" } {

	    #--- Soustraction du fond de ciel d'une zone dessus le spectre :
	    ::console::affiche_resultat "Soustraction du fond de ciel d'une zone dessous le spectre.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zoneinf"
	    set moy [expr -1.*[ lindex [ buf$audace(bufNo) stat ] 6 ] ]
	    #-- Crée une image uniforme d'intensité égale à la moyenne des fonds de ciel
	    set haut [ expr int($hauteur)+1 ]
	    buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 $haut FORMAT_USHORT COMPRESS_NONE 0
	    buf$audace(bufNo) setkwd [ list "NAXIS" 2 int "" "" ]
	    buf$audace(bufNo) setkwd [ list "NAXIS1" $naxis1 int "" "" ]
	    buf$audace(bufNo) setkwd [ list "NAXIS2" $haut int "" "" ]
	    buf$audace(bufNo) offset $moy
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
            buf$audace(bufNo) bitpix float
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
            buf$audace(bufNo) bitpix short
	} elseif { $methodemoy == "none" } {

	    #--- Aucune soustraction du fond de ciel
	    ::console::affiche_resultat "Aucune soustraction du fond de ciel.\n"
	    file copy -force "$audace(rep_images)/${spectre}_zone$conf(extension,defaut)" "$audace(rep_images)/${spectre}_zone_fc$conf(extension,defaut)"
	} else {
	    ::console::affiche_resultat "Mauvaise option de calcul du fond de ciel.\n"
	}

	#--- Sauvegarde et netoyages :
	::console::affiche_resultat "Spectre 2D nettoyé du fond de ciel sauvé sous ${spectre}_zone_fc.\n"
	file delete $audace(rep_images)/${spectre}_zone$conf(extension,defaut)
	file delete $audace(rep_images)/${spectre}_zonesup$conf(extension,defaut)
	file delete $audace(rep_images)/${spectre}_zoneinf$conf(extension,defaut)
	return ${spectre}_zone_fc
    } else {
	::console::affiche_erreur "Usage: spc_subsky spectre_2D_fits y_centre_spectre hauteur_spectre méthode_soustraction_fond_de_ciel (moy, moy2, med, sup, inf, none, back)\n\n"
    }
}
#***************************************************************************#



###############################################################
# Extraction du profil a partir du spectre 2D en mode texte et autosélection de zone
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 26-02-2006
# Date de modification : 05-07-2006/2007-06-19/2014-01-01
# Arguments : fichier fits du spectre spatial ?méthode soustraction fond de ciel (moy, moy2, med, sup, inf, none, back)? ?méthode de détection du spectre (large, serre)? ?méthode de bining (add)?
###############################################################

proc spc_profil { args } {

    global audace spcaudace
    global audela
    global conf

    #-- Rappel des options par defaut : $spcaudace(methsky)=med, $spcaudace(methsel)=serre, $spcaudace(methbin)=rober
    # Retire l'extension .fit du nom du fichier
    # regsub -all .fit $filespacialspc - filespatialspc
    if { [llength $args] <= 4 && [llength $args] != 0 } {
	if { [llength $args] == 1 } {
	    #--- Gestion avec options par défaut :
	    set spectre2d [ file rootname [lindex $args 0] ]
	    set methodefc "$spcaudace(methsky)"
	    set methodedetect "$spcaudace(methsel)"
	    set methodebin "$spcaudace(methbin)"
	} elseif { [llength $args] == 2 } {
	    set spectre2d [ file rootname [lindex $args 0] ]
	    set methodefc [ lindex $args 1 ]
	    set methodedetect "$spcaudace(methsel)"
	    set methodebin "$spcaudace(methbin)"
	} elseif { [llength $args] == 3 } {
	    set spectre2d [ file rootname [lindex $args 0] ]
	    set methodefc [ lindex $args 1 ]
	    set methodedetect [ lindex $args 2 ]
	    set methodebin "$spcaudace(methbin)"
	} elseif { [llength $args] == 4} {
	    set spectre2d [ file rootname [lindex $args 0] ]
	    set methodefc [ lindex $args 1 ]
	    set methodedetect [ lindex $args 2 ]
	    set methodebin [ lindex $args 3 ]
	} else {
	    ::console::affiche_erreur "Usage: spc_profil spectre_2D_fits ?méthode soustraction fond de ciel (moy, moy2, med, sup, none, frac)? ?méthode de détection du spectre (large, serre, moy)? ?méthode de bining (add, rober, horne)?\n\n"
	}

	#--- Chargement du spectre 2D :
	if { [file exists "$audace(rep_images)/$spectre2d$conf(extension,defaut)" ] == 1 } {
	    buf$audace(bufNo) load "$audace(rep_images)/$spectre2d"
	    set listemotsclef [ buf$audace(bufNo) getkwds ]
	    if { [ lsearch $listemotsclef "NAXIS2" ] ==-1 } {
		::console::affiche_erreur "Le spectre doit être à 2 dimensions\n\n"
		return ""
	    }
	} else {
	    ::console::affiche_resultat "Le fichier $spectre2d n'existe pas.\n"
	    return 0
	}

	#--- Détection de la zone où se trouve le spectre :
	if { $methodedetect == "large" } {
	    set gauss_params [ spc_detect $spectre2d ]
	} elseif { $methodedetect == "serre" } {
	    set gauss_params [ spc_detectasym $spectre2d ]
	} elseif { $methodedetect == "moy" } {
	    set gauss_params [ spc_detectmoy $spectre2d ]
	} else {
	    set gauss_params [ spc_detect $spectre2d ]
	}

	#--- Découpage de la zone à binner et retrait du fond de ciel :
	set ycenter [ lindex $gauss_params 0 ]
        if { $spcaudace(hauteur_binning)==0 } {
           set hauteur [ lindex $gauss_params 1 ]
        } else {
           set hauteur $spcaudace(hauteur_binning)
        }

	#-- Algo : set coords_zone [list 1 [expr int($ycenter-0.5*$largeur)] $naxis1 [expr int($ycenter+0.5*$largeur)]]
	set spectre_zone_fc [ spc_subsky $spectre2d $ycenter $hauteur $methodefc ]

	#--- Bining :
	if { $methodebin == "add" } {
	    set profil_fc [ spc_bins $spectre_zone_fc ]
	    file delete -force "$audace(rep_images)/$spectre_zone_fc$conf(extension,defaut)"
	} elseif { $methodebin == "rober" || $methodebin == "horne" } {
	    #-- Cas particulier de zone de binning : elle est decoupée et c'est $spectre_zone_fc
	    #-- au lieu de faire : [ spc_binlopt $spectre_zone_fc $ycenter $hauteur ]
	    buf$audace(bufNo) load "$audace(rep_images)/$spectre_zone_fc"
	    set ylargeur [ expr [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]-1 ]
	    #-- Bizarement, lopt ne peut prendre la dimension totale d'une image :
	    set yepaisseur [ expr $ylargeur-3 ]
	    if { $yepaisseur<=4. } {
		::console::affiche_erreur "\nÉpaisseur de binning de Roberval trop faible.\nSélection large du spectre (9 pixels)\n"
		set gauss_params [ spc_detect $spectre2d ]
		set ycenter [ lindex $gauss_params 0 ]
		set hauteur [ lindex $gauss_params 1 ]
		set hauteur 9
		#-- Algo : set coords_zone [list 1 [expr int($ycenter-0.5*$largeur)] $naxis1 [expr int($ycenter+0.5*$largeur)]]
		set spectre_zone_fc [ spc_subsky $spectre2d $ycenter $hauteur $methodefc ]
		buf$audace(bufNo) load "$audace(rep_images)/$spectre_zone_fc"
		set ylargeur [ expr [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]-1 ]


		#-- Bizarement, lopt ne peut prendre la dimension totale d'une image :
		set yepaisseur [ expr $ylargeur-3. ]
		if { $yepaisseur<=4. } {
		    ::console::affiche_erreur "\nÉpaisseur de binning de Roberval trop faible. Fin de procédure\n.\n"
		    return ""
		}
	    }

            #--- Binning :
	    buf$audace(bufNo) bitpix float
            if { $methodebin == "rober" } {
               buf$audace(bufNo) imaseries "LOPT y1=3 y2=$ylargeur height=1"
               #-- J. G. Robertson, PASP 98, 1220-1231, November 1986, Version simpliflie sans rejection des pixels aberrants.
            } elseif { $methodebin == "horne" } {
               buf$audace(bufNo) imaseries "LOPT5 y1=3 y2=$ylargeur height=1 COSMIC_THRESHOLD=$spcaudace(hornethreshold)"
               #-- Horne, K. An optimal extraction algorithm for ccd spectroscopy. Pub. Astron. Soc. Pac. 98, 609, Jun (1986).
               #-- buf1 load rr_lyrae-a--spectre2D-traite-1 ; buf1  imaseries "LOPT5 y1=613 y2=625 height=1 COSMIC_THRESHOLD=40 FILE=$audace(rep_images)/rr_lyrae-a--spectre2D-traite--smd6.fit"
               #**** REVOIR application algo de Horne !! argument file=somme mediane des spectres 2D
               #-- L'utilistion de FILE a peu d'effet. Le code de LOPT5 semble ne pas gerer la detection des cosmics. 20140101

            }
            buf$audace(bufNo) setkwd [ list "SPC_HBIN" $ylargeur float "Binning thickness" "pixel" ]
	    buf$audace(bufNo) setkwd [ list "CRVAL1" 1.0 double "" "" ]
	    buf$audace(bufNo) setkwd [ list "CDELT1" 1.0 double "" "" ]
            buf$audace(bufNo) setkwd [ list "CRPIX1" 1 double "Reference pixel" "pixel" ]
            buf$audace(bufNo) setkwd [ list "CREATOR" "SpcAudACE $spcaudace(version)" string "Software that create this FITS file" "" ]


            #--- Nettoie les mots clefs finissant en 2 :
            spc_header1d $audace(bufNo)


            #--- Sauve le profil :
	    if { [regexp {1.3.0} $audela(version) match resu ] } {
		buf$audace(bufNo) save "$audace(rep_images)/${spectre_zone_fc}_spc"
	    } else {
		buf$audace(bufNo) save1d "$audace(rep_images)/${spectre_zone_fc}_spc"
	    }
	    buf$audace(bufNo) bitpix short
	    set profil_fc "${spectre_zone_fc}_spc"
	    file delete -force "$audace(rep_images)/$spectre_zone_fc$conf(extension,defaut)"
	} else {
	    set profil_fc [ spc_bins $spectre_zone_fc ]
	    file delete -force "$audace(rep_images)/$spectre_zone_fc$conf(extension,defaut)"
	}

	#--- Message de fin et nettoyage :
	::console::affiche_resultat "Profil de raies sauvé sous $profil_fc\n"
	file delete -force "$audace(rep_images)/${spectre2d}_zone$conf(extension,defaut)"
	return $profil_fc
   } else {
	::console::affiche_erreur "Usage: spc_profil spectre_2D_fits ?méthode soustraction fond de ciel (moy, moy2, med, sup, inf, none, back)? ?méthode de détection du spectre (large, serre, moy)? ?méthode de bining (add, rober, horne)?\n\n"
   }
}
#**************************************************************************#


###############################################################
# Extraction du profil sur un astre etendu a partir du spectre 2D en mode texte
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 07-30-2007
# Date de modification : 07-30-2007
# Arguments : fichier_fits_du_spectre_2D liste_corrdonnées_zone ?méthode soustraction fond de ciel (moy, moy2, med, sup, inf, none, back)?  ?méthode de bining (add)?
###############################################################

proc spc_profilzone { args } {

    global audace
    global audela
    global conf

    # Retire l'extension .fit du nom du fichier
    # regsub -all .fit $filespacialspc - filespatialspc
    if { [llength $args] <= 4 && [llength $args] != 0 } {
	if { [llength $args] == 2 } {
	    #--- Gestion avec options par défaut :
	    set spectre2d [ file rootname [ lindex $args 0 ] ]
	    set wincoords [ lindex $args 1 ]
	    set methodefc "med"
	    set methodebin "rober"
	} elseif { [llength $args] == 3 } {
	    set spectre2d [ file rootname [ lindex $args 0 ] ]
	    set wincoords [ lindex $args 1 ]
	    set methodefc [ lindex $args 2 ]
	    set methodebin "rober"
	} elseif { [llength $args] == 4 } {
	    set spectre2d [ file rootname [ lindex $args 0 ] ]
	    set wincoords [ lindex $args 1 ]
	    set methodefc [ lindex $args 2 ]
	    set methodebin [ lindex $args 3 ]
	} else {
	    ::console::affiche_erreur "Usage: spc_profilzone spectre_2D_fits liste_coordonnées_zone ?méthode soustraction fond de ciel (moy, moy2, med, sup, none, frac)? ?méthode de bining (add, rober, horne)?\n\n"
	}

	#--- Chargement du spectre 2D :
	if { [file exists "$audace(rep_images)/$spectre2d$conf(extension,defaut)" ] == 1 } {
	    buf$audace(bufNo) load "$audace(rep_images)/$spectre2d"
	    set listemotsclef [ buf$audace(bufNo) getkwds ]
	    if { [ lsearch $listemotsclef "NAXIS2" ] ==-1 } {
		::console::affiche_erreur "Le spectre doit être à 2 dimensions\n\n"
		return ""
	    }
	} else {
	    ::console::affiche_erreur "Le fichier $spectre2d n'existe pas.\n\n"
	    return ""
	}

	#--- Découpage vertical de la zone à binner :
	set xdeb [ lindex $wincoords 0 ]
	set xfin [ lindex $wincoords 2 ]
	set naxis2 [ lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
	buf$audace(bufNo) window [ list $xdeb 1 $xfin $naxis2 ]
	buf$audace(bufNo) save "$audace(rep_images)/${spectre2d}_zoneselect"

        #--- Retrait du fond de ciel :
        #- hauteur_binning=ysup_zone_bin-yinf_zone_bin :
        set hauteur [ expr [ lindex $wincoords 3 ] - [ lindex $wincoords 1 ] ]
        #- ycenter_zone_bin=0.5(ysup_zone_bin+yinf_zone_bin) :
	set ycenter [ expr round(0.5*$hauteur)+[ lindex $wincoords 1 ] ]
	set spectre_zone_fc [ spc_subsky ${spectre2d}_zoneselect $ycenter $hauteur $methodefc ]

	#--- Binning :
	if { $methodebin == "add" } {
	    set profil_fc [ spc_bins $spectre_zone_fc ]
	    file delete -force "$audace(rep_images)/$spectre_zone_fc$conf(extension,defaut)"
	} elseif { $methodebin == "rober" } {
	    #-- Cas particulier de zone de binning : elle est decoupée et c'est $spectre_zone_fc
	    #-- au lieu de faire : [ spc_binlopt $spectre_zone_fc $ycenter $hauteur ]

	    buf$audace(bufNo) load "$audace(rep_images)/$spectre_zone_fc"
	    set ylargeur [ expr [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]-1 ]
	    #-- Bizarement, lopt ne peut prendre la dimension totale d'une image :
	    set yepaisseur [ expr $ylargeur-3 ]
	    if { $yepaisseur<=4. } {
		#set ylargeur 5.
		::console::affiche_resultat "\nÉpaisseur de binning de Roberval trop faible.\nSélection large du spectre\n"
		set hauteur [ expr [ lindex $wincoords 3 ] - [ lindex $wincoords 1 ] ]
		set ycenter [ expr round(0.5*$hauteur)+[ lindex $wincoords 1 ] ]
		#-- Algo : set coords_zone [list 1 [expr int($ycenter-0.5*$largeur)] $naxis1 [expr int($ycenter+0.5*$largeur)]]
		set spectre_zone_fc [ spc_subsky ${spectre2d}_zoneselect $ycenter $hauteur $methodefc ]
		buf$audace(bufNo) load "$audace(rep_images)/$spectre_zone_fc"
		set ylargeur [ expr [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]-1 ]
		#-- Bizarement, lopt ne peut prendre la dimension totale d'une image :
		set yepaisseur [ expr $ylargeur-3 ]
		if { $yepaisseur<=4. } {
		    ::console::affiche_resultat "\nÉpaisseur de binning de Roberval trop faible. \nFin de procédure.\n"
		    return ""
		}
	    }

            #--- Binning :
	    buf$audace(bufNo) imaseries "LOPT y1=3 y2=$ylargeur height=1"
	    buf$audace(bufNo) setkwd [ list "CRVAL1" 1.0 double "" "" ]
	    buf$audace(bufNo) setkwd [ list "CDELT1" 1.0 double "" "" ]
	    buf$audace(bufNo) setkwd [ list "CRPIX1" 1 double "Reference pixel" "pixel" ]
            #--- Nettoie les mots clefs finissant en 2 :
            spc_header1d $audace(bufNo)

	    buf$audace(bufNo) bitpix float
	    if { [regexp {1.3.0} $audela(version) match resu ] } {
		buf$audace(bufNo) save "$audace(rep_images)/${spectre_zone_fc}_spc"
	    } else {
		buf$audace(bufNo) save1d "$audace(rep_images)/${spectre_zone_fc}_spc"
	    }
	    buf$audace(bufNo) bitpix short
	    set profil_fc ${spectre_zone_fc}_spc
	    file delete -force "$audace(rep_images)/$spectre_zone_fc$conf(extension,defaut)"
	} else {
	    set profil_fc [ spc_bins $spectre_zone_fc ]
	    file delete -force "$audace(rep_images)/$spectre_zone_fc$conf(extension,defaut)"
	}


	#--- Message de fin et nettoyage :
	::console::affiche_resultat "Profil de raies sauvé sous $profil_fc\n"
	file delete -force "$audace(rep_images)/${spectre2d}_zoneselect$conf(extension,defaut)"
	file delete -force "$audace(rep_images)/${spectre2d}_zone$conf(extension,defaut)"
	return $profil_fc
   } else {
       ::console::affiche_erreur "Usage: spc_profilzone spectre_2D_fits liste_coordonnées_zone ?méthode soustraction fond de ciel (moy, moy2, med, sup, none, frac)? ?méthode de bining (add, rober, horne)?\n\n"
   }
}
#**************************************************************************#






###############################################################
# Effectue le binning de la zone selectionnee sur le spectre et soustrait le fond du ciel.
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour n-2 : 31-01-2005
# Date de mise a jour n-1 : 29-11-2005 (buf1 load en loadima)
# Date de mise a jour : 27-12-05 (buf1 load rep/img
# Date MAJ : 07-01-24 (saisie des arguments avec la variable args)
# Arguments :
#  * fichier fits de la zone selectionnee du spectre spatial
#  * fichier fits du spectre spatial
###############################################################

proc spc_bin { args } {

    global audace
    global audela
    global conf
    set extsp ".dat"

    ::console::affiche_resultat "[ llength $args ] ; $args\n"

    if { [ llength $args ]==3 } {
	set filenamespc_zone_rep [ lindex $args 0 ]
	set filenamespc_spatial_rep [ lindex $args 1 ]
	set listcoords [ lindex $args 2 ]

	#--- Initialisation des variables :
	set ht_spectre [lindex $listcoords 0]
	set yinf [lindex $listcoords 1]
	set ysup [lindex $listcoords 2]
	set xinf_zone [lindex $listcoords 3]
	set xsup_zone [lindex $listcoords 4]
	set ht_dessous [lindex $listcoords 5]
	set ht_dessus [lindex $listcoords 6]
	set filenamespc_zone [file tail $filenamespc_zone_rep]
	set filenamespc_spatial [file tail $filenamespc_spatial_rep]

	## On binne sur les colonnes dans la region de l'image correspondant au spectre et on sauvegarde le résultat dans ${filespacialspc}_sp :
	::console::affiche_resultat "Binning des colonnes de la région sélectionnée...\n"
	## Exemple de binning sur la totatlite de la totalite de la hauteur de l'image initiale
	##
	##set ysup2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
	##buf$audace(bufNo) biny 1 $ysup2

	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_zone"
	#buf$audace(bufNo) biny 1 [expr $ysup-$yinf]
	buf$audace(bufNo) imaseries "biny y1=1 y2=$ht_spectre height=1"
	## Pondération par la hauteur en pixels
	#buf$audace(bufNo) mult [expr 1.0/$ht_spectre]
	buf$audace(bufNo) bitpix float
	if { [regexp {1.3.0} $audela(version) match resu ] } {
	    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_sp"
	} else {
	    buf$audace(bufNo) save1d "$audace(rep_images)/${filenamespc_spatial}_sp"
	}
	buf$audace(bufNo) bitpix short

	#******** Calcul une moyenne du fond du ciel prit dessus et dessous le spectre ********#
	#--- Traitement d'une zone de longueur egale a la selection et de hauteur egale a celle de l'image initiale (par la suite ce sera sur une hauteur decidee a l'avance) -------------------#

        #-- Creation de l'image totale sur laquelle seront fait les binning zone_sup et zone_inf du fond de ciel :
        #- Largeur limiteée par xinf_zone et xsup_zone et d'une hauteur ysup-yinf+ht_dessus+ht_dessous :
	set coords_zonev [list $xsup_zone [expr int($ysup+$ht_dessus)] [expr int($xinf_zone)] [expr int($yinf-$ht_dessous)+1]]
	## ::console::affiche_resultat "Coords_zone : $coords_zone\n"
	#::console::affiche_resultat "${filenamespc_spatial} ; Coords_zonev : $coords_zonev, ht_sup : $ht_dessus, ht_inf : $ht_dessous\n"
	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_spatial"
	buf$audace(bufNo) window $coords_zonev
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_zonev"
	buf$audace(bufNo) bitpix short

        #-- Binning zone superieure de fond de ciel :
	#- On binne sur les colonnes dans la région de l'image au dessus du spectre et on sauvegarde le résultat dans ${filenamespc_spatial}_spsup
	buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_zonev"
	buf$audace(bufNo) imaseries "biny y1=$ysup y2=[expr $ysup+$ht_dessus-1] height=1"
	#- Pondération par la hauteur en pixels
        buf$audace(bufNo) mult [expr 1.0/$ht_dessus]
       	#buf$audace(bufNo) mult [expr 1.0*$ht_spectre/$ht_dessus]
	buf$audace(bufNo) bitpix float
	if { [regexp {1.3.0} $audela(version) match resu ] } {
	    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_spsup"
	} else {
	    buf$audace(bufNo) save1d "$audace(rep_images)/${filenamespc_spatial}_spsup"
	}
	buf$audace(bufNo) bitpix short

        #-- Binning zone inferieure de fond de ciel :
	#- On binne sur les colonnes dans la région de l'image au dessous du spectre et on sauvegarde le résultat dans ${filenamespc_spatial}_spinf
	::console::affiche_resultat "Binning des colonnes.\n"
	buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_zonev"
	buf$audace(bufNo) imaseries "biny y1=$yinf y2=[expr $yinf-$ht_dessous+1] height=1"
	#- Pondération par la hauteur en pixels
        buf$audace(bufNo) mult [expr 1.0/$ht_dessous]
        #buf$audace(bufNo) mult [expr 1.0*$ht_spectre/$ht_dessous]
	buf$audace(bufNo) bitpix float
	if { [regexp {1.3.0} $audela(version) match resu ] } {
	    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_spinf"
	} else {
	    buf$audace(bufNo) save1d "$audace(rep_images)/${filenamespc_spatial}_spinf"
	}
	buf$audace(bufNo) bitpix short

	#-- Calcul une moyenne du fond du ciel prit dessus et dessous le spectre :
	::console::affiche_resultat "Calcul de la moyenne du fond du ciel pris dessus et dessous l'image...\n"
	buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_spsup"
	##~~~~~ BUG ICI : 25/04/2006 NON, PAS DE BUG
	buf$audace(bufNo) add "$audace(rep_images)/${filenamespc_spatial}_spinf" 0
        #- Petites feintes : on multiplie l'image précédente par -0.5 pour avoir une moyenne, le chiffre négatif permettant d'obtenir spectre-fond de ciel simplement en ajoutant à cette image : le spectre !
	buf$audace(bufNo) mult -0.5

        #--- Soustraction du fond de ciel :
	buf$audace(bufNo) add "$audace(rep_images)/${filenamespc_spatial}_sp" 0
	## Initialisation des mots-clef spectroscopie
	buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 double "" ""]
	buf$audace(bufNo) setkwd [list "CDELT1" 1.0 double "" ""]
        buf$audace(bufNo) setkwd [ list "CRPIX1" 1 double "Reference pixel" "pixel" ]

	#--- On sauvegarde le spectre avec correction du fond du ciel
        #-- Nettoie les mots clefs finissant en 2 :
        spc_header1d $audace(bufNo)
	::console::affiche_resultat "Profil de raies sauvé sous ${filenamespc_spatial}_spc$conf(extension,defaut)\n"
	buf$audace(bufNo) bitpix float
	if { [regexp {1.3.0} $audela(version) match resu ] } {
	    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_spc"
	} else {
	    buf$audace(bufNo) save1d "$audace(rep_images)/${filenamespc_spatial}_spc"
	}
	buf$audace(bufNo) bitpix short

	#--- Export au format dat :
	# ::console::affiche_resultat "Extraction des valeurs et écriture du fichier ascii $filenamespc_spatial${extsp}\n"
	# buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_spc"
	# buf$audace(bufNo) imaseries "PROFILE filename=$audace(rep_images)/${filenamespc_spatial}_spc$extsp direction=x offset=1"

	#buf1 imaseries "PROFILE filename=$audace(rep_images)/${filenamespc_spatial}.$extsp direction=x offset=1"

	##------- Effacement des fichiers temporaires ----------##
	## ${filenamespc_spatial}_zone ${filenamespc_spatial}_sp ${filenamespc_spatial}_spsup ${filenamespc_spatial}_spinf ${filenamespc_spatial}_profil
	# catch {file delete -force "${filenamespc_spatial}_zone ${filenamespc_spatial}_sp ${filenamespc_spatial}_spsup ${filenamespc_spatial}_spinf ${filenamespc_spatial}_profil"}
	#--- Suppression des fichiers intermediaires
	## $conf(extension_default)
	::console::affiche_resultat "Effacement des fichiers temporaires...\n"
	file delete -force "$audace(rep_images)/${filenamespc_spatial}_sp$conf(extension,defaut)"
	file delete -force "$audace(rep_images)/${filenamespc_spatial}_spinf$conf(extension,defaut)"
	file delete -force "$audace(rep_images)/${filenamespc_spatial}_spsup$conf(extension,defaut)"
	file delete -force "$audace(rep_images)/${filenamespc_spatial}_zone$conf(extension,defaut)"
	file delete -force "$audace(rep_images)/${filenamespc_spatial}_zonev$conf(extension,defaut)"
	return ${filenamespc_spatial}_spc
    } else {
	::console::affiche_erreur "Usage: spc_bin spectre_2D_zone spectre_2D_entier liste_coordonnées_zone\n\n"
    }
}
###############################################################



###############################################################
# Effectue le binning de la zone selectionnee sur le spectre SANS soustraire le fond du ciel.
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 26-02-2006
# Date de mise a jour n-2 : 31-01-2005
# Arguments :
#  * fichier fits de la zone selectionnee du spectre spatial
#  * fichier fits du spectre spatial
###############################################################

proc spc_bins { args } {

  global audace
  global audela
  global conf
  set extsp ".dat"

  if { [llength $args] == 1 } {
      set filenamespc_zone [ lindex $args 0 ]

      #--- Binning
      ::console::affiche_resultat "Binning des colonnes de la région sélectionnée...\n"
      buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_zone"
      set ht_spectre [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
      buf$audace(bufNo) imaseries "biny y1=1 y2=$ht_spectre height=1"
      buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 double "" ""]
      buf$audace(bufNo) setkwd [list "CDELT1" 1.0 double "" ""]
      buf$audace(bufNo) setkwd [ list "CRPIX1" 1 double "Reference pixel" "pixel" ]
      buf$audace(bufNo) bitpix float

      #--- Nettoie les mots clefs finissant en 2 :
      spc_header1d $audace(bufNo)

      if { [regexp {1.3.0} $audela(version) match resu ] } {
	  buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_zone}_spc"
      } else {
	  buf$audace(bufNo) save1d "$audace(rep_images)/${filenamespc_zone}_spc"
      }
      buf$audace(bufNo) bitpix short

      ::console::affiche_resultat "\nProfil de raies sauvé sous ${filenamespc_zone}_spc$conf(extension,defaut)\n"

      #--- Export au format dat
      # ::console::affiche_resultat "Extraction des valeurs et écriture du fichier ascii $filenamespc_zone${extsp}\n"
      # spc_fits2dat ${filenamespc_zone}_spc
      #buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_zone}_spc"
      # buf$audace(bufNo) imaseries "PROFILE filename=${filenamespc_zone}_spc$extsp direction=x offset=1"
      # buf$audace(bufNo) imaseries "PROFILE filename=$audace(rep_images)/${filenamespc_zone}_spc$extsp direction=x offset=1"

      #--- Efface les fichiers temporaires :
      file delete -force "$audace(rep_images)/$filenamespc_zone$conf(extension,defaut)"
      buf$audace(bufNo) bitpix short
      return ${filenamespc_zone}_spc
   } else {
	::console::affiche_erreur "Usage: spc_bins spectre_2D_zone\n\n"
   }
}
###############################################################



###############################################################
# Effectue le binning de la zone selectionnee sur le spectre et soustrait le fond du ciel de la partie supérieure.
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour n-2 : 31-01-2005
# Date de mise a jour n-1 : 29-11-2005 (buf1 load en loadima)
# Date de mise a jour : 27-12-05 (buf1 load rep/img)
# Date de mise a jour : 26-02-06 (soustrait que la partie supérieure du fond de ciel)
# Arguments :
#  * fichier fits de la zone selectionnee du spectre spatial
#  * fichier fits du spectre spatial
###############################################################

proc spc_binsup { {filenamespc_zone_rep ""} {filenamespc_spatial_rep ""} {listcoords ""} } {

    global audace
    global audela
    global conf
    set extsp ".dat"

    set ht_spectre [lindex $listcoords 0]
    set yinf [lindex $listcoords 1]
    set ysup [lindex $listcoords 2]
    set xinf_zone [lindex $listcoords 3]
    set xsup_zone [lindex $listcoords 4]
    set ht_dessous [lindex $listcoords 5]
    set ht_dessus [lindex $listcoords 6]
    set filenamespc_zone [file tail $filenamespc_zone_rep]
    set filenamespc_spatial [file tail $filenamespc_spatial_rep]

    ## On binne sur les colonnes dans la region de l'image correspondant au spectre et on sauvegarde le résultat dans ${filespacialspc}_sp :
    ::console::affiche_resultat "Binning des colonnes de la région sélectionnée...\n"
    ## Exemple de binning sur la totatlite de la totalite de la hauteur de l'image initiale
    ##
    ##set ysup2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
    ##buf$audace(bufNo) biny 1 $ysup2

    buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_zone"
    #buf$audace(bufNo) biny 1 [expr $ysup-$yinf]
    buf$audace(bufNo) imaseries "biny y1=1 y2=$ht_spectre height=1"
    ## Pondération par la hauteur en pixels
    #buf$audace(bufNo) mult [expr 1.0/$ht_spectre]
    buf$audace(bufNo) bitpix float
    if { [regexp {1.3.0} $audela(version) match resu ] } {
	buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_sp"
    } else {
	buf$audace(bufNo) save1d "$audace(rep_images)/${filenamespc_spatial}_sp"
    }
    buf$audace(bufNo) bitpix short


    ## ******** Calcul une moyenne du fond du ciel prit dessus et dessous le spectre ****** ##
    ##-- Traitement d'une zone de longueur egale a la selection et de hauteur egale a celle de l'image initiale (par la suite ce sera sur une hauteur decidee a l'avance) -------------------#

    ## Creation d'une image de largeur limiteée par xinf_zone et xsup_zone et d'une hauteur ysup-yinf+ht_dessus+ht_dessous
    set coords_zonev [list $xsup_zone [expr int($ysup+$ht_dessus)] [expr int($xinf_zone)] [expr int($yinf-$ht_dessous)+1]]
    ## ::console::affiche_resultat "Coords_zone : $coords_zone\n"
    #::console::affiche_resultat "${filenamespc_spatial} ; Coords_zonev : $coords_zonev, ht_sup : $ht_dessus, ht_inf : $ht_dessous\n"
    buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_spatial"
    buf$audace(bufNo) window $coords_zonev
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_zonev"
    buf$audace(bufNo) bitpix short

    ## On binne sur les colonnes dans la région de l'image au dessus du spectre et on sauvegarde le résultat dans ${filenamespc_spatial}_spsup
    buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_zonev"
    buf$audace(bufNo) imaseries "biny y1=$ysup y2=[expr $ysup+$ht_dessus-1] height=1"
    ## Pondération par la hauteur en pixels
    buf$audace(bufNo) mult [expr 1.0/$ht_dessus]
    buf$audace(bufNo) bitpix float
    if { [regexp {1.3.0} $audela(version) match resu ] } {
	buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_spsup"
    } else {
	buf$audace(bufNo) save1d "$audace(rep_images)/${filenamespc_spatial}_spsup"
    }
    buf$audace(bufNo) bitpix short


    ## Calcul une moyenne du fond du ciel prit dessus et dessous le spectre.
    ::console::affiche_resultat "Calcul de la moyenne du fond du ciel pris dessus et dessous l'image...\n"
    buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_spsup"
    ##~~~~~ BUG ICI
    # buf$audace(bufNo) add "$audace(rep_images)/${filenamespc_spatial}_spinf" 0

    ## Petites feintes : on multiplie l'image précédente par -0.5 pour avoir une moyenne, le chiffre négatif permettant d'obtenir spectre-fond de ciel simplement en ajoutant à cette image : le spectre !
    buf$audace(bufNo) mult -1
    buf$audace(bufNo) add "$audace(rep_images)/${filenamespc_spatial}_sp" 0
    ## Initialisation des mots-clef spectroscopie
    buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 double "" ""]
    buf$audace(bufNo) setkwd [list "CDELT1" 1.0 double "" ""]
    buf$audace(bufNo) setkwd [ list "CRPIX1" 1 double "Reference pixel" "pixel" ]
    buf$audace(bufNo) bitpix float

    #--- Nettoie les mots clefs finissant en 2 :
    spc_header1d $audace(bufNo)

    ## On sauvegarde le spectre avec correction du fond du ciel
    ::console::affiche_resultat "Profil de raies sauvé sous ${filenamespc_spatial}_spc$conf(extension,defaut)\n"
    if { [regexp {1.3.0} $audela(version) match resu ] } {
	buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_spc"
    } else {
	buf$audace(bufNo) save1d "$audace(rep_images)/${filenamespc_spatial}_spc"
    }
    buf$audace(bufNo) bitpix short

    ::console::affiche_resultat "Extraction des valeurs et écriture du fichier ascii $filenamespc_spatial${extsp}\n"
    #loadima ${filenamespc_spatial}_spc
    buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_spc"
    buf$audace(bufNo) imaseries "PROFILE filename=${filenamespc_spatial}_spc$extsp direction=x offset=1"
    #buf1 imaseries "PROFILE filename=$audace(rep_images)/${filenamespc_spatial}.$extsp direction=x offset=1"

    ##------- Effacement des fichiers temporaires ----------##
    ::console::affiche_resultat "Effacement des fichiers temporaires...\n"

    file delete $audace(rep_images)/${filenamespc_spatial}_sp$conf(extension,defaut)
    file delete $audace(rep_images)/${filenamespc_spatial}_spsup$conf(extension,defaut)
    file delete $audace(rep_images)/${filenamespc_spatial}_zone$conf(extension,defaut)
    file delete $audace(rep_images)/${filenamespc_spatial}_zonev$conf(extension,defaut)

    buf$audace(bufNo) bitpix short
    return ${filenamespc_spatial}_spc
}
###############################################################




###############################################################
#
# Profil d'intensité d'une ligne de pixels d'ordonnée y
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 13-05-2006
# Date de mise a jour : 13-05-2006
# Arguments : fichier fits du spectre spatial, ordonnée y de la ligne, ?hauteur à binner?
###############################################################

proc spc_profily { args } {
    global audace
    global audela
    global conf

    if { [llength $args] <= 3 } {
	if { [llength $args] == 2 } {
	    set fichier [ file rootname [ lindex $args 0 ] ]
	    set y [ expr int([ lindex $args 1 ]) ]
	    set dy 0.5
	} elseif { [llength $args] == 3 } {
	    set fichier [ file rootname [ lindex $args 0 ] ]
	    # set y [ expr int([ lindex $args 1 ]) ]
	    set y [ expr round([ lindex $args 1 ]) ]
	    # set hauteur [ expr int([ lindex $args 2 ]) ]
	    set hauteur [ expr round([ lindex $args 2 ]) ]
	    # set dy [ expr int($hauteur*.5-1)+1 ]
	    set dy [ expr round($hauteur*.5) ]
	} else {
	    ::console::affiche_erreur "Usage: spc_profily image_fits ordonnée_y_de_la_ligne ?hauteur à binner?\n\n"
	    return 0
    	}

	#--- Découpage de la ligne
	buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1]
	#set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1]
	## coords contient : { x1 y1 x2 y2 }
	##  -----------B
	##  |          |
	##  A-----------
	set coords_zone [ list 1 [ expr $y-int($dy) ] $naxis1 [ expr $y+int($dy) ] ]
	buf$audace(bufNo) window $coords_zone
	#--- Binning
	set htr [ expr $dy*2 ]
	if { $dy != 0.5 } {
	    ::console::affiche_resultat "Hauteur de binning : $htr\n"
	    buf$audace(bufNo) imaseries "biny y1=1 y2=$htr height=1"
	}

	#--- Sauvegarde du profil
	buf$audace(bufNo) setkwd [ list NAXIS 1 int "" "" ]
	buf$audace(bufNo) setkwd [ list NAXIS1 $naxis1 int "" "" ]
	buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 double "" ""]
	buf$audace(bufNo) setkwd [list "CDELT1" 1.0 double "" ""]
        buf$audace(bufNo) setkwd [ list "CRPIX1" 1 double "Reference pixel" "pixel" ]
	buf$audace(bufNo) bitpix float

        #--- Nettoie les mots clefs finissant en 2 :
        spc_header1d $audace(bufNo)

	if { [regexp {1.3.0} $audela(version) match resu ] } {
	    buf$audace(bufNo) save "$audace(rep_images)/${fichier}_spcy"
	} else {
	    buf$audace(bufNo) save1d "$audace(rep_images)/${fichier}_spcy"
	}
	buf$audace(bufNo) bitpix short

	::console::affiche_resultat "Profil d'intensité de la ligne sauvé sous ${fichier}_spcy$conf(extension,defaut)\n"
	return ${fichier}_spcy
    } else {
	::console::affiche_erreur "Usage: spc_profily image_fits ordonnée_y_de_la_ligne ?hauteur à binner?\n\n"
    }
}
###############################################################


###############################################################
#
# Profil d'intensité d'une colonne de pixels d'abscisse x et d'epaisseur dx
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 07-06-2006
# Date de mise a jour : 07-06-2006
# Arguments : fichier fits du spectre spatial, abscisse x de la colonne, ?largeur à binner?
###############################################################

proc spc_profilx { args } {
    global audace
    global conf
    set extsp ".dat"
    set nomprofil "profil_spcx"

    if { [llength $args] == 3 } {
	set fichier [ file rootname [ lindex $args 0 ] ]
	set x [ lindex $args 1 ]
	set dx [ lindex $args 2 ]

	#--- Binning
	buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	#- Les commandes PROFILE et PROFILE2 n'accèptent pas les noms de fichier compliqués
	#buf$audace(bufNo) imaseries "PROFILE2 filename=$audace(rep_images)/$nomprofil$extsp direction=y offset=$x"
	#buf$audace(bufNo) imaseries "BINX x1=$x x2=$x width=1"
	set x1 [ expr $x-$dx+1 ]
	if { $x1<1 } { set x1 1 }
	set x2 [ expr $x+$dx-1 ]
	if { $x2>$naxis1 } { set x2 $naxis1 }
	buf$audace(bufNo) imaseries "BINX x1=$x1 x2=$x2 width=1"
	#--- Sauvegarde du profil
	#-- Enlève la première ligne du fichier dat (label des colonnes)
	#- J'ai modifié tt_user3 ligne 350 de la libtt.
	#set fsortie [ file rootname [ spc_dat2fits $nomprofil$extsp ] ]
	#file rename -force "$audace(rep_images)/$fsortie$conf(extension,defaut)" "$audace(rep_images)/${fichier}_spcx$conf(extension,defaut)"
	#file delete -force "$audace(rep_images)/$nomprofil$extsp"
	buf$audace(bufNo) save "$audace(rep_images)/${fichier}_spcx"
	::console::affiche_resultat "Profil d'intensité de la ligne sauvé sous ${fichier}_spcx$conf(extension,defaut)\n"
	return ${fichier}_spcx
    } else {
	::console::affiche_erreur "Usage: spc_profilx image_fits abscisse_x_de_la_ligne demi_epaisseur_binning\n\n"
    }
}
###############################################################




###############################################################
#
# Extraction du profil a partir du spectre 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 31-01-2005
# Arguments : fichier fits du spectre spatial
###############################################################

proc extract_profil_col { {filenamespc_spacial ""} } {
    ::console::affiche_resultat "Rien.\n"
}
###############################################################




##########################################################
#  Procedure du trace du profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 16-02-2005
# Date de mise à jour : 16-02-2005 / 17-12-2005
# Arguments : fichier .fit du profil de raie
##########################################################

proc spc_loadfit_051217 { {filenamespc ""} } {

   global profilspc
   global caption
   global colorspc
   global audace
   global conf
    set rep_et_filename ""

   ## === Interfacage de l'ouverture du fichier profil de raie ===
   if {$filenamespc==""} {
      # set idir ./
      # set ifile *.spc
      set idir $audace(rep_images)
      set ifile *.fit

      if {[info exists profilspc(initialdir)] == 1} {
         set idir "$profilspc(initialdir)"
      }
      if {[info exists profilspc(initialfile)] == 1} {
         set ifile "$profilspc(initialfile)"
      }
      #--- Mémorise le répertoire et nom du fichier accolés dans la variable filenamespc
      ## set filenamespc [tk_getOpenFile -title $caption(loadspc) -filetypes [list [list "$caption(spcaudace,gui,spc_profile)" {.spc}]] -initialdir $idir -initialfile $ifile ]
      # set filenamespc [tk_getOpenFile -title $caption(loadspcfit) -filetypes [list [list "$caption(spcaudace,gui,spc_profile)" {$conf(extension,defaut)}]] -initialdir $idir -initialfile $ifile ]
      set rep_et_filename [tk_getOpenFile -title $caption(spcaudace,gui,loadspcfit) -filetypes [list [list "$caption(spcaudace,gui,spc_profile)" {.fit}]] -initialdir $idir -initialfile $ifile ]

      if {[string compare $rep_et_filename ""] == 0 } {
	  return 0
      }
   } else {
       #set repertoire [pwd]
       set repertoire $audace(rep_images)
       set rep_et_filename "$repertoire/$filenamespc"
   }
   #::console::affiche_resultat "$rep_et_filename\n"

   # $spectre = liste contenant : la liste des valeurs de l'intensité, NAXIS1, CRVAL1, CDELT1, CRPIX1, CTYPE1.
   set spectre [openspc $rep_et_filename]

   #-- Ouverture meth 2 : Ajouté le 16/12/2005
   #set filename [ file tail $filenamespc ]
   #set spectre [openspc $filename]
   #--
   set profilspc(naxis2) [lindex $spectre 1]
   set profilspc(intensite) [lindex $spectre 0]
   set profilspc(pixels) ""
   set profilspc(object) "$filenamespc"

     buf$audace(bufNo) load "$rep_et_filename"
     set listemotsclef [ buf$audace(bufNo) getkwds ]
     if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
	 set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
     }
     if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
	 set dispersion [ lindex [buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
     }
     if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	 set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
     }
     if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
	 set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
     }
     if { [ lsearch $listemotsclef "SPC_C" ] !=-1 } {
	 set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
     }

   if { [llength $spectre] == 2 } {
       # Spectre non calibré
       for {set k 1} {$k <= $profilspc(naxis2)} {incr k} {
	   append profilspc(pixels) "$k "
       }
   } else {
       if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	   for {set k 0} {$k<$profilspc(naxis2)} {incr k} {
	       set pixel [expr $spc_a*$k*$k+$spc_b*$k+$spc_c ]
	       append profilspc(pixels) "$pixel "
	   }
	   #-- Calibration linéaire :
       } else {
	   # Spectre calibré linéairement
	   set xdepart [lindex $spectre 2]
	   set xincr [lindex $spectre 3]
	   for {set k 0} {$k < $profilspc(naxis2)} {incr k} {
	       set pixel [expr $xdepart+$k*$xincr]
	       append profilspc(pixels) "$pixel "
	   }
       }
   }

   ## Appel de la procedure d'affichage de graphique "pvisu" dans le fichier spc_gui.tcl
   pvisu2 $spectre
}



##########################################################
# Procedure du trace du profil de raies
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 23-07-2007
# Date de mise à jour : 23-07-2007/20080307
# Arguments : fichier .fit/.dat/(.spc) du profil de raie
##########################################################

proc spc_load { args } {
    global audace spcaudace
    global conf
    global caption

    set nbargs [ llength $args ]
    if { $nbargs<=1 } {
	#--- Un fichier donné en argument :
	if { $nbargs==1 } {
	    set file_et_rep [ lindex $args 0 ]
	    set filegiven [ file tail "$file_et_rep" ]
	    set file_rep [ file dirname "$file_et_rep" ]
	    if { $file_rep=="." } {
		set file_rep "$audace(rep_images)"
	    }
	    set file_extension [ file extension "$filegiven" ]

	    #-- Détermine l'extension et sinon le fichier a charger :
	    if { $file_extension != "" } {
		set filename "$file_et_rep"
	    } elseif { [ llength [ file extension $filegiven ] ] == 0 } {
		if { [ catch { glob -dir $file_rep -tails $filegiven$conf(extension,defaut) $filegiven$spcaudace(extdat) } ] } {
		    ::console::affiche_erreur "Le fichier $filegiven n'existe pas.\n\n"
		    return ""
		} else {
		    set listname [ lsort -dictionary [ glob -dir $file_rep -tails $filegiven$conf(extension,defaut) $filegiven$spcaudace(extdat) ] ]
		    if { [ llength $listname ]==1 } {
			# set filename [ lindex $listname 0 ]
			set filename "$file_et_rep"
			set file_extension [ file extension [ lindex $listname 0 ] ]
		    } elseif { [ llength $listname ]>1 } {
			set filename [ lindex [ lsort -dictionary [ glob -dir $file_rep -tails $filegiven$conf(extension,defaut) ] ] 0 ]
			set file_extension $conf(extension,defaut)
		    }
		}
	    } else {
		set filename "$filegiven"
		set file_extension [ file extension $filegiven ]
	    }
	#--- Ouvre un navigateur de fichier pour choisir un fichier :
	} elseif { $nbargs==0 } {
	    set filegiven [ tk_getOpenFile -filetypes [ list [ list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz [buf$audace(bufNo)  $spcaudace(extdat) ]" ] ] -initialdir $audace(rep_images) ]
	    set filename [ file tail $filegiven ]
	    set file_extension [ file extension $filegiven ]
	}

	#::console::affiche_resultat "name=$filename ; ext=$extension\n"
	#--- Affiche le profil de rais selon l'extension :
	if { "$file_extension"=="$conf(extension,defaut)" || "$file_extension"==".fits" } {
	    spc_loadfit "$filename"
	} elseif { "$file_extension"=="$spcaudace(extdat)" } {
	    spc_loaddat "$filename"
	} else {
	    ::console::affiche_erreur "Usage: spc_load <file_name.fit/.dat>\n\n"
	}
    } else {
	::console::affiche_erreur "Usage: spc_load <file_name.fit/.dat>\n\n"
    }
}
#*******************************************************************************#




##########################################################
# Procedure du trace du profil de raies FITS
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 16-02-2005
# Date de mise à jour : 16-02-2005 / 17-12-2005/20080307
# Arguments : fichier .fit du profil de raie
##########################################################

proc spc_loadfit { {filenamespc ""} } {

   global profilspc
   global caption
   global colorspc
   global audace
   global conf
   #global confVersion
   global audela
   set rep_et_filename ""

   ## === Interfacage de l'ouverture du fichier profil de raie ===
   if {$filenamespc==""} {
      # set idir ./
      # set ifile *.spc
      set idir $audace(rep_images)
      set ifile *.fit

      if {[info exists profilspc(initialdir)] == 1} {
         set idir "$profilspc(initialdir)"
      }
      if {[info exists profilspc(initialfile)] == 1} {
         set ifile "$profilspc(initialfile)"
      }
      #--- Mémorise le répertoire et nom du fichier accolés dans la variable filenamespc
      ## set filenamespc [tk_getOpenFile -title $caption(loadspc) -filetypes [list [list "$caption(spcaudace,gui,spc_profile)" {.spc}]] -initialdir $idir -initialfile $ifile ]
      ## set filenamespc [tk_getOpenFile -title $caption(spcaudace,gui,loadspcfit) -filetypes [list [list "$caption(spcaudace,gui,spc_profile)" {$conf(extension,defaut)}]] -initialdir $idir -initialfile $ifile ]
      # set rep_et_filename [ tk_getOpenFile -title $caption(spcaudace,gui,loadspcfit) -filetypes [list [list "$caption(spcaudace,gui,spc_profile)" {.fit}]] -initialdir $idir -initialfile $ifile ]
      set rep_et_filename [ tk_getOpenFile -title $caption(spcaudace,gui,loadspcfit) -filetypes [list [list "$caption(spcaudace,gui,spc_profile)" [ list $conf(extension,defaut) .fits .fts ]]] -initialdir $idir -initialfile $ifile ]

      if {[string compare $rep_et_filename ""] == 0 } {
	  return 0
      }

   } else {
       #set repertoire "$audace(rep_images)"
       #set profilspc(initialdir) "$audace(rep_images)"
       #set rep_et_filename "$repertoire/$filenamespc"
       set rep_et_file "$filenamespc"
       set repertoire [ file dirname "$filenamespc" ]
       if { $repertoire == "." } {
	   set repertoire "$audace(rep_images)"
       }
       set nom_fichier [ file tail "$filenamespc" ]
       set rep_et_filename "$repertoire/$nom_fichier"
   }

   #============================================================================#
   #-- $spectre = liste contenant : la liste des valeurs de l'intensité, NAXIS1, CRVAL1, CDELT1, CRPIX1, CTYPE1.
   #set spectre [openspc $rep_et_filename]

   #-- Ouverture meth 2 : Ajouté le 16/12/2005
   ##set filename [ file tail $filenamespc ]
   ##set spectre [openspc $filename]
   #--
   #set profilspc(naxis2) [lindex $spectre 1]
   #set profilspc(intensite) [lindex $spectre 0]
   #set intensites [lindex $spectre 0]
   #============================================================================#

   #--- Initialise les variables d'environnement :
   #catch {unset profilspc} {}
   set filenamespc [ file rootname [ file tail $rep_et_filename ] ]
   set profilspc(initialdir) [file dirname $rep_et_filename ]
   #set profilspc(initialfile) [file tail $filenamespc]

   #--- Détermine les éléments de calcul des longueurs d'onde :
   buf$audace(bufNo) load "$rep_et_filename"
   set profilspc(pixels) ""
   set profilspc(intensite) ""
   set profilspc(object) "$filenamespc"
   set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
   set listemotsclef [ buf$audace(bufNo) getkwds ]
   if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
      set crpix1 [ lindex [ buf$audace(bufNo) getkwd "CRPIX1" ] 1 ]
   } else {
      set crpix1 1
   }
   if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
      set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      # set flag_noncal 0
   }
   if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
      set dispersion [ lindex [buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
      if { $dispersion != 0 } {
         set flag_noncal 0
      } else { set flag_noncal 1 }
   } else {
      set flag_noncal 1
   }


   if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
      set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
      set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
      set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
      if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
         set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
      } else {
         set spc_d 0.0
      }
      if { [ lsearch $listemotsclef "SPC_E" ] !=-1 } {
         set spc_e [ lindex [ buf$audace(bufNo) getkwd "SPC_E" ] 1 ]
      } else {
         set spc_e 0.0
      }
   }

  #--- Gestion de la commande getpix selon la version d'Audela :
  if { [regexp {1.3.0} $audela(version) match resu ] } {
   #- if { [ lsearch $listemotsclef "CRVAL1" ] ==-1 || $dispersion == 1. }
   if { $lambda0==1. || $flag_noncal==1 } {
       # Spectre non calibré
       ::console::affiche_resultat "Ouverture d'un profil de raies non calibré...\n$filenamespc\n"
       #for {set k 1} {$k <= $naxis1} {incr k} {
	#   append profilspc(pixels) "$k "
	#   append profilspc(intensite) [ buf$audace(bufNo) getpix [list $k 1] ]
       #}
       for {set k 1} {$k<=$naxis1} {incr k} {
	   lappend profilspc(pixels) $k
	   lappend profilspc(intensite) [ buf$audace(bufNo) getpix [list $k 1] ]
       }
   } else {
       if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	   ::console::affiche_resultat "Ouverture d'un profil de raies calibré nonlinéairement...\n$filenamespc\n"
	   if { $spc_a < 0.01 } {
	       for {set k 1} {$k<=$naxis1} {incr k} {
		   #- Ancienne formulation < 070104 :
		   set pixel [expr $spc_a*$k*$k+$spc_b*$k+$spc_c ]
		   lappend profilspc(pixels) $pixel
		   lappend profilspc(intensite) [ buf$audace(bufNo) getpix [list $k 1] ]
	       }
	   } else {
	       for {set k 1} {$k<=$naxis1} {incr k} {
		   set pixel [expr $spc_d*$k*$k*$k+$spc_c*$k*$k+$spc_b*$k+$spc_a ]
		   lappend profilspc(pixels) $pixel
		   lappend profilspc(intensite) [ buf$audace(bufNo) getpix [list $k 1] ]
	       }
	   }
	   #-- Calibration linéaire :
       } else {
	   # Spectre calibré linéairement
	   ::console::affiche_resultat "Ouverture d'un profil de raies calibré linéairement...\n$filenamespc\n"
	   for {set k 1} {$k<=$naxis1} {incr k} {
	       set pixel [expr $lambda0+$k*$dispersion]
	       lappend profilspc(pixels) $pixel
	       lappend profilspc(intensite) [ buf$audace(bufNo) getpix [list $k 1] ]
	   }
       }
   }
  } else {
  #-- Versions Audela >= 1.4.0 :
     if { $flag_noncal==1 } {
       # Spectre non calibré
        ::console::affiche_resultat "Ouverture d'un profil de raies non calibré...\n $filenamespc\n"
        for {set k 1} {$k<=$naxis1} {incr k} {
	   lappend profilspc(pixels) $k
	   lappend profilspc(intensite) [ lindex [ buf$audace(bufNo) getpix [list $k 1] ] 1 ]
        }
     } else {
       if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	   ::console::affiche_resultat "Ouverture d'un profil de raies calibré nonlinéairement...\n$filenamespc\n"
	   if { $spc_a < 0.01 && $spc_a > 0.0 } {
	       for {set k 1} {$k<=$naxis1} {incr k} {
                  #- Ancienne formulation < 070104 :
                  #- lappend profilspc(pixels) [expr $spc_a*$k*$k+$spc_b*$k+$spc_c ]
                  lappend profilspc(pixels) [ spc_calpoly $k $crpix1 $spc_c $spc_b $spc_a 0 ]
                  lappend profilspc(intensite) [ lindex [ buf$audace(bufNo) getpix [list $k 1] ] 1 ]
	       }
	   } else {
	       # for {set k 0} {$k<$naxis1} {incr k}
	       for {set k 1} {$k<=$naxis1} {incr k} {
                  #- lappend profilspc(pixels) [ expr $spc_d*pow($k-$crpix1,3)+$spc_c*pow($k-$crpix1,2)+$spc_b*($k-$crpix1)+$spc_a ]
                  lappend profilspc(pixels) [ spc_calpoly $k $crpix1 $spc_a $spc_b $spc_c $spc_d $spc_e ]
                  lappend profilspc(intensite) [ lindex [ buf$audace(bufNo) getpix [list $k 1] ] 1 ]
	       }
	   }
	   #-- Calibration linéaire :
       } else {
	   # Spectre calibré linéairement
	   ::console::affiche_resultat "Ouverture d'un profil de raies calibré linéairement...\n$filenamespc\n"
	   for {set k 1} {$k<=$naxis1} {incr k} {
              #- lappend profilspc(pixels) [expr $lambda0+($k-$crpix1)*$dispersion]
              lappend profilspc(pixels) [ spc_calpoly $k $crpix1 $lambda0 $dispersion 0 0 ]
              lappend profilspc(intensite) [ lindex [ buf$audace(bufNo) getpix [list $k 1] ] 1 ]
	   }
       }
   }
  }
   #::console::affiche_resultat "$profilspc(intensite)\n"
   ## Appel de la procedure d'affichage de graphique "pvisu" dans le fichier spc_gui.tcl
   #pvisu2 $intensites
   pvisu
}




##########################################################
#  Procedure du trace du profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 31-01-2005
# Arguments : fichier .dat du profil de raie
##########################################################

proc spc_loaddat { {filenamespc ""} } {

   global profilspc
   global caption
   global colorspc
   global audace spcaudace
   global conf

   ## === Interfacage de l'ouverture du fichier profil de raie ===
   if {$filenamespc==""} {
      # set idir ./
      # set ifile *.spc
      set idir $audace(rep_images)
      set ifile $spcaudace(extdat)

      if {[info exists profilspc(initialdir)] == 1} {
         set idir "$profilspc(initialdir)"
      }
      if {[info exists profilspc(initialfile)] == 1} {
         set ifile "$profilspc(initialfile)"
      }
      # set filenamespc [tk_getOpenFile -title $caption(loadspc) -filetypes [list [list "$caption(spcaudace,gui,spc_profile)" {.spc}]] -initialdir $idir -initialfile $ifile ]
      set rep_et_filename [ tk_getOpenFile -title $caption(spcaudace,gui,loadspctxt) -filetypes [list [list "$caption(spcaudace,gui,spc_profile)" [ list $spcaudace(extdat) ] ] ] -initialdir $idir -initialfile $ifile ]
      set profilspc(initialdir) [ file dirname $rep_et_filename ]
      set filenamespc [ file tail $rep_et_filename ]
      if {[string compare $filenamespc ""] == 0 } {
         return 0
      }
  } else {
      set profilspc(initialdir) "$audace(rep_images)"
      set filenamespc "$filenamespc"
  }

   ## === Lecture du fichier de profil de raie ===
   #catch {unset profilspc} {}
   ##set profilspc(initialfile) [file tail $filenamespc]
   set input [open "$profilspc(initialdir)/$filenamespc" r]
   set contents [split [read $input] \n]
   close $input
   # set profilspc(naxis2) [expr [lindex $contents 2]]
   set profilspc(naxis2) [expr [llength $contents]-2]
   set profilspc(exptime) "?"
   set profilspc(object) "$filenamespc"
   set profilspc(intensite) ""
   set profilspc(pixels) ""

   set offset 1
   for {set k 1} {$k <= $profilspc(naxis2)} {incr k} {
      set ligne [lindex $contents $offset]
      append profilspc(pixels) "[lindex $ligne 0] "
      # append profilspc(lambda) "[lindex $ligne 1] "
      # append profilspc(intensite) "[lindex $ligne 2] "
      append profilspc(intensite) "[lindex $ligne 1] "
      # append profilspc(argon1) "[lindex $ligne 3] "
      # append profilspc(argon2) "[lindex $ligne 4] "
      # append profilspc(noir) "[lindex $ligne 5] "
      # append profilspc(repere) "[lindex $ligne 6] "
      incr offset
   }

   ## Appel de la procedure d'affichage de graphique "pvisu" dans le fichier spc_gui.tcl
   pvisu
}



#####################################################################
#  Procedure d'ouverture d'un profil de raie au format ascii
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 31-01-2005
# Arguments : fichier .dat du profil de raie
#####################################################################


proc open_profil {{filenamespc ""}} {
    ::console::affiche_resultat "Rien.\n"
}




#####################################################################
#  Procedure du trace du profil de raie dans la fenetre graphique
# Autre methode
# **** Inutilisee *****
# Arguments : fichier .dat du profil de raie
#####################################################################


proc spc_trace_profil {{filenamespc ""}} {

   global audace
   global conf
   global profilspc
   global caption
   global colorspc
   set extsp "dat"

   ## === Lecture du fichier de donnees du profil de raie ===
   catch {unset profilspc} {}
   set profilspc(initialdir) [file dirname $audace(rep_images)]
   set profilspc(initialfile) [file tail $filenamespc]
   set input [open "$audace(rep_images)/$filenamespc" r]
   set contents [split [read $input] \n]
   close $input

   ## === Extraction des numeros des pixels et des intensites ===
   #::console::affiche_resultat "ICI :\n $contents.\n"
   set profilspc(naxis2) [expr [llength $contents]-2]
   #::console::affiche_resultat "$profilspc(naxis2)\n"
   set offset 1
   for {set k 1} {$k <= $profilspc(naxis2)} {incr k} {
      set ligne [lindex $contents $offset]
      append profilspc(pixels) "[lindex $ligne 0] "
      append profilspc(intensite) "[lindex $ligne 1] "
      incr offset
   }
   #::console::affiche_resultat "$profilspc(pixels)\n"

   # === On prepare les vecteurs a afficher ===
   set len [llength $profilspc(pixels)]
   set pp ""
   set yy ""
   set kk 0
   for {set k 1} {$k<=$len} {incr k} {
         append pp " [lindex $profilspc(pixels) $k]"
         append yy " [lindex $profilspc(intensite) $k]"
         incr kk
   }
   blt::vector create vx
   blt::vector create vy


   ## Tracer du profil de raie
   toplevel .profil_ix
   # blt::graph .profil_ix.g -title "Profil de raie spatial de $filenamespc"
   blt::graph .profil_ix.g -title "Profil de raie spatial de $profilspc(initialfile)"
   .profil_ix.g configure -width 7.87i -height 5.51i
   .profil_ix.g legend configure -hide yes
   pack .profil_ix.g -in .profil_ix
   vx set $pp
   vy set $yy
   .profil_ix.g element create "Profil spatial" -symbol none -xdata vx -ydata vy -smooth natural

   set div_x 10
   set div_y 5
   #set echellex [expr $len/10]
   set echellex [expr int($len/($div_x*10))*10]
   .profil_ix.g axis configure x -stepsize $echellex
   #scrollbar .hors -command {.profil_ix.g axis view x } -orient horizontal
   #.profil_ix.g axis configure x -stepsize $echellex -scrollcommand { .hors set }

   set tmp_i [lsort -real -decreasing $profilspc(intensite)]
   set i_max [lindex $tmp_i 0]
   #set echelley [expr $i_max/5]
   set echelley [expr int($i_max/($div_y*10))*10]
   .profil_ix.g axis configure y -stepsize $echelley
   ##blt::vector destroy vx vy
}
#****************************************************************#


#########################################################
# Créée le profil de raies de spectre d'une lampe de calibration adapte à la position du spectre d'une etoile
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 17-09-2006
# Date de mise à jour : 17-09-2006/15-08-2007
# Arguments : spectre_2D_objet spectre_2D_lampe
##########################################################

proc spc_profillampe { args } {

   global audace spcaudace
   global conf
   set nbargs [ llength $args ]

   if { $nbargs <= 3 } {
       if { $nbargs == 2 } {
          set spectre_objet [ file rootname [ lindex $args 0 ] ]
          set spectre_lampe [ file rootname [ lindex $args 1 ] ]
          set methraie "n"
       } elseif { $nbargs == 3 } {
          set spectre_objet [ file rootname [ lindex $args 0 ] ]
          set spectre_lampe [ file rootname [ lindex $args 1 ] ]
          set methraie [ lindex $args 2 ]
       } else {
	   ::console::affiche_erreur "Usage: spc_profillampe spectre_2D_objet spectre_2D_lampe ?methraie (o/n)?\n\n"
	   return ""
       }

      #--- Oriente vers un binning large en base resolution :
      if { $nbargs==2 && $spcaudace(br)==1 } {
         set methraie "o"
      }

       #--- Détermine les paramètres de binning :
       set linecoords [ spc_detectasym "$spectre_objet" ]
       set ycenter [ lindex $linecoords 0 ]
       buf$audace(bufNo) load "$audace(rep_images)/$spectre_lampe"
       set naxis2 [ lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
       if { $methraie=="n" } {
          set ysup [ expr round($ycenter+0.5*[ lindex $linecoords 1 ]) ]
          set yinf [ expr round($ycenter-0.5*[ lindex $linecoords 1 ]) ]
       } elseif { $methraie=="o" } {
          if { $spcaudace(epaisseur_bin)>$naxis2 } {
             set epaisseur [ expr $naxis2/4. ]
          } else {
             set epaisseur $spcaudace(epaisseur_bin)
          }
          set ysup [ expr round($ycenter+0.5*$epaisseur) ]
          set yinf [ expr round($ycenter-0.5*$epaisseur) ]
       }
       # ::console::affiche_resultat "Ordonnées etat : $yinf - $ysup\n"
       if { $yinf<=0} { set yinf [ expr int($ycenter-($ycenter-1)/3.) ] }
       if { $ysup>$naxis2 } { set ysup [ expr int(($naxis2-$ycenter)/3.+$ycenter) ] }
       ::console::affiche_resultat "Ordonnées de binning de lampe : $yinf - $ysup\n"

       #--- Crée le profil de raie du spectre de la lampe de étalon :
       buf$audace(bufNo) imaseries "BINY y1=$yinf y2=$ysup height=1"
       buf$audace(bufNo) setkwd [ list NAXIS 1 int "" "" ]
       buf$audace(bufNo) delkwd "NAXIS2"
       buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 double "" ""]
       buf$audace(bufNo) setkwd [list "CDELT1" 1.0 double "" ""]
       buf$audace(bufNo) setkwd [ list "CRPIX1" 1 double "Reference pixel" "pixel" ]
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save $audace(rep_images)/${spectre_lampe}_spc
       buf$audace(bufNo) bitpix short
       ::console::affiche_resultat "\nProfil de raie de la lampe de calibration sauvé sous ${spectre_lampe}_spc\n"
       return ${spectre_lampe}_spc
   } else {
       ::console::affiche_erreur "Usage: spc_profillampe spectre_2D_objet spectre_2D_lampe ?methraie (o/n)?\n\n"
   }
}
#****************************************************************#


#########################################################
# Créée le profil de raies de spectre d'une lampe de calibration adapté à la zone précisée
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 31-07-2007
# Date de mise à jour : 31-07-2007
# Arguments : spectre_2D_lampe liste_coordonnées_zone
##########################################################

proc spc_profillampezone { args } {

   global audace
   global conf
   if { [llength $args] == 2 } {
       set spectre_lampe [ lindex $args 0 ]
       set wincoords [ lindex $args 1 ]

       #--- Découpe la zone à binner :
       buf$audace(bufNo) load "$audace(rep_images)/$spectre_lampe"
       buf$audace(bufNo) window $wincoords
       set y1 1
       set y2 [ lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]

       #--- Crée le profil de raie du spectre de la lampe de étalon :
       buf$audace(bufNo) imaseries "BINY y1=$y1 y2=$y2 height=1"
       buf$audace(bufNo) setkwd [ list NAXIS 1 int "" "" ]
       buf$audace(bufNo) delkwd "NAXIS2"
       buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 double "" ""]
       buf$audace(bufNo) setkwd [list "CDELT1" 1.0 double "" ""]
       buf$audace(bufNo) setkwd [ list "CRPIX1" 1 double "Reference pixel" "pixel" ]
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save1d $audace(rep_images)/${spectre_lampe}_spc
       buf$audace(bufNo) bitpix short
       ::console::affiche_resultat "\nProfil de raie de la lampe de calibration sauvé sous ${spectre_lampe}_spc\n"
       return ${spectre_lampe}_spc
   } else {
       ::console::affiche_erreur "Usage: spc_profillampezone spectre_2D_lampe liste_coordonnées_zone\n\n"
   }
}
#****************************************************************#









#=====================================================================#
#                 Anciennes version des fonctions                     #
#=====================================================================#

#****************************************************************#
proc spc_profilx_060607 { args } {
    global audace
    global conf
    set extsp ".dat"
    set nomprofil "profil_spcx"

    if { [llength $args] == 2 } {
	set fichier [ file rootname [ lindex $args 0 ] ]
	set x [ lindex $args 1 ]

	#--- Binning
	buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	#- Les commandes PROFILE et PROFILE2 n'accèptent pas les noms de fichier compliqués
	buf$audace(bufNo) imaseries "PROFILE2 filename=$audace(rep_images)/$nomprofil$extsp direction=y offset=$x"
	#--- Sauvegarde du profil
	#-- Enlève la première ligne du fichier dat (label des colonnes)
	#- J'ai modifié tt_user3 ligne 350 de la libtt.
	set fsortie [ file rootname [ spc_dat2fits $nomprofil$extsp ] ]
	file rename -force "$audace(rep_images)/$fsortie$conf(extension,defaut)" "$audace(rep_images)/${fichier}_spcx$conf(extension,defaut)"
	file delete -force "$audace(rep_images)/$nomprofil$extsp"
	::console::affiche_resultat "Profil d'intensité de la ligne sauvé sous ${fichier}_spcx$conf(extension,defaut)\n"
	return ${fichier}_spcx
    } else {
	::console::affiche_erreur "Usage: spc_profilx image_fits abscisse_x_de_la_ligne\n\n"
    }
}
###############################################################



proc spc_profilx_07062006 { args } {
    global audace
    global conf
    set extsp ".dat"

    if { [llength $args] <= 3 } {
	if { [llength $args] == 2 } {
	    set fichier [ lindex $args 0 ]
	    set x [ lindex $args 1 ]
	    set dx 0.5
	} elseif { [llength $args] == 3 } {
	    set fichier [ lindex $args 0 ]
	    set x [ lindex $args 1 ]
	    set largeur [ lindex $args 2 ]
	    set dx [ expr int($largeur*.5-1)+1 ]
	} else {
	    ::console::affiche_erreur "Usage: spc_profilx image_fits abscisse_x_de_la_ligne ?largeur à binner?\n\n"
	    return 0
    	}

	#*** Meth 1
	set flag 0
	if { $flag == 1 } {
	    #--- Découpage de la ligne
	    buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	    set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1]
	    set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1]
	    ## coords contient : { x1 y1 x2 y2 }
	    ##  -----------B
	    ##  |          |
	    ##  A-----------
	    set coords_zone [ list [ expr $x-int($dx) ] 1 [ expr $x+int($dx) ] $naxis2 ]
	    buf$audace(bufNo) window $coords_zone
	    #--- Binning
	    set lgr [ expr $dx*2 ]
	    if { $dx != 0.5 } {
		::console::affiche_resultat "Hauteur de binning : $lgr\n"
		buf$audace(bufNo) binx 1 $lgr 1
	    }
	} else {
	    set lgr [ expr $dx*2 ]
	    if { $dx != 0.5 } {
		::console::affiche_resultat "Hauteur de binning : $lgr\n"
		set x1 [ expr $x-$dx ]
		set x2 [ expr $x+$dx ]
		buf$audace(bufNo) load "$audace(rep_images)/$fichier"
		#-- L'image résultante de la somme n'est pas un fichier FITS 1D : naxis1=1 naxis2=old_naxis2 !
		# buf$audace(bufNo) binx $x1 $x2 1
		buf$audace(bufNo) imaseries "PROFILE filename=$audace(rep_images)/${fichier}_spcx$extsp direction=x offset=1"
	    } else {
		::console::affiche_resultat "Hauteur de binning : $lgr\n"
		set x1 [ expr $x-$dx ]
		set x2 [ expr $x+$dx ]
		buf$audace(bufNo) load "$audace(rep_images)/$fichier"
		# buf$audace(bufNo) binx $x1 $x2 1
		buf$audace(bufNo) imaseries "PROFILE filename=$audace(rep_images)/${fichier}_spcx$extsp direction=x offset=1"
	    }
	}
	#--- Sauvegarde du profil
	set sortie [ spc_dat2fits ${fichier}_spcx$extsp ]
	#buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 double "" ""]
	#buf$audace(bufNo) setkwd [list "CDELT1" 1.0 double "" ""]
	#buf$audace(bufNo) bitpix float
	#buf$audace(bufNo) save "$audace(rep_images)/${fichier}_spcx"
	::console::affiche_resultat "Profil d'intensité de la ligne sauvé sous ${fichier}_spcx$conf(extension,defaut)\n"
	return ${fichier}_spcx
    } else {
	::console::affiche_erreur "Usage: spc_profilx image_fits abscisse_x_de_la_ligne ?largeur?\n\n"
    }
}
###############################################################



proc spc_detectasym_060623 { args } {

    global audace
    global conf

    if { [ llength $args ] == 1 } {
	set fichier [ file rootname [lindex $args 0 ] ]
	buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1]
	set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1]

	#--- Creations de profils de plusieurs colonnes
	set xpas [ expr int($naxis1/5) ]
	#-- n° du profil resultant
	::console::affiche_resultat "Pas entre chaque point de détection : $xpas\n"
	set i 1
	for {set k $xpas} {$k <= $naxis1} {incr k} {
	    set fsortie [ file rootname [ spc_profilx $fichier $k ] ]
	    # ::console::affiche_resultat "$fsortie\n"
	    file rename -force "$audace(rep_images)/$fsortie$conf(extension,defaut)" "$audace(rep_images)/profil-$i$conf(extension,defaut)"
	    set k [ expr $k+$xpas-1 ]
	    incr i
	}
	set nbimg [ expr $naxis1/$xpas ]
	sadd profil- ${fichier}_spcx $nbimg ]
	delete2 profil- $nbimg

	#--- Détermination des paramètres du de l'épaisseur du spectre
	buf$audace(bufNo) load "$audace(rep_images)/${fichier}_spcx"
	#set windowcoords [ list 1 1 $naxis2 1 ]
        set y1 [ expr int(.03*$naxis2) ]
        set y2 [ expr int(.97*$naxis2) ]
	set windowcoords [ list 1 $y1 1 $y2 ]
	set gparams [ buf$audace(bufNo) fitgauss $windowcoords ]
	set ycenter [ lindex $gparams 1 ]
	#-- Choix : la largeur de la gaussienne est de 1.9*FWHM
	set largeur [ expr 1.9*[ lindex $gparams 2 ] ]
	return [ list $ycenter $largeur ]
    } else {
	::console::affiche_erreur "Usage: spc_detectasym spectre_2D_fits\n\n"
    }
}
###############################################################



proc spc_subsky_050700 { args } {

    global audace spcaudace
    global conf

    if { [ llength $args ] == 4 } {
	set spectre [ lindex $args 0 ]
	set ycenter [ lindex $args 1 ]
	set hauteur [ lindex $args 2 ]
	set methodemoy [ lindex $args 3 ]

	::console::affiche_resultat "ycenter : $ycenter ; hauteur : $hauteur\n"
	#--- Initialisation de paramètres
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
	set naxis2 [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]

	#--- Passe en entier ycenter et hauteur pour le decoupage de zones de meme taille :
	## [ expr $ycenter+0.5*$hauteur-(int($ycenter+0.5*$hauteur)+1) ] >= 0.5
	#if { [ expr $ycenter-int($ycenter) ] > 0.5 } {
	  #  set ycenter [ expr int($ycenter)+1 ]
	#} else {
	#    set ycenter [ expr int($ycenter) ]
	#}
	#if { [ expr $hauteur-int($hauteur) ] > 0.5 } {
	#    set hauteur [ expr int($hauteur)+1 ]
	#} else {
	#    set hauteur [ expr int($hauteur) ]
	#}
	set ycenter [ expr round($ycenter) ]
	set hauteur [ expr round($hauteur) ]

	#--- Découpage de zone où se trouve le spectre :
	#--  -----------B
	#--  |          |
	#--  A-----------
	set coords_zone_spectre [ list 1 [expr int($ycenter-0.5*$hauteur)] $naxis1 [expr int($ycenter+0.5*$hauteur)] ]
	::console::affiche_resultat "Zone du spectre : $coords_zone_spectre\n"
	#--- Découpage de la zone où se trouve le spectre
	buf$audace(bufNo) window $coords_zone_spectre
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone"


	#--- Découpage de la zone supérieure pour le fond de ciel :
	set coords_zone_sup [ list 1 [expr int($ycenter+1.5*$hauteur)] $naxis1 [expr int($ycenter+2.5*$hauteur)] ]
	::console::affiche_resultat "Zone supérieure : $coords_zone_sup\n"
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	buf$audace(bufNo) window $coords_zone_sup
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zonesup"

	#--- Découpage de la zone inférieure pour le fond de ciel :
	set coords_zone_inf [ list 1 [expr int($ycenter-1.5*$hauteur)] $naxis1 [expr int($ycenter-2.5*$hauteur)] ]
	::console::affiche_resultat "Zone inférieure : $coords_zone_inf\n"
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	buf$audace(bufNo) window $coords_zone_inf
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zoneinf"

	#--- Calcul de la moyenne du fond de ciel et la soustrait :
	if { $methodemoy == "moy" } {

	    #--- Somme moyenne des zones sup et inf :
	    ::console::affiche_resultat "Soustraction du fond de ciel : moyenne des 2 zones.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zoneinf" 0
	    buf$audace(bufNo) mult -0.5
	    uncosmic $spcaudace(uncosmic)
	    uncosmic $spcaudace(uncosmic)
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	} elseif { $methodemoy == "med" } {

	    #--- Somme médiane des colonne pour chaque zone puis moyenne :
	    ::console::affiche_resultat "Soustraction du fond de ciel : médiane des colonnes de chaque zone.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set haut [ lindex [ buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
	    buf$audace(bufNo) imaseries "MEDIANY y1=1 y2=$haut height=$hauteur"
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zonesupmed"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set haut [ lindex [ buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
	    buf$audace(bufNo) imaseries "MEDIANY y1=1 y2=$haut height=$hauteur"
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zonesupmed" 0
	    buf$audace(bufNo) mult -0.5
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	    file delete -force "$audace(rep_images)/${spectre}_zonesupmed$conf(extension,defaut)"
	} elseif { $methodemoy == "moy2" } {

	    #--- Moyenne de la valeur des fonds de ciel tirés des 2 zones :
	    ::console::affiche_resultat "Soustraction du fond de ciel : moyenne des 2 fonds.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set moysup [ lindex [ buf$audace(bufNo) stat ] 6 ]
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zoneinf"
	    set moyinf [ lindex [ buf$audace(bufNo) stat ] 6 ]
	    set moy [ expr -0.5*($moysup+$moyinf) ]
	    #-- Crée une image uniforme d'intensité égale à la moyenne des fonds de ciel
	    #buf$audace(bufNo) clear
	    set haut [ expr int($hauteur)+1 ]
	    buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 $haut FORMAT_USHORT COMPRESS_NONE 0
	    buf$audace(bufNo) setkwd [ list NAXIS 2 int "" "" ]
	    buf$audace(bufNo) setkwd [ list NAXIS1 $naxis1 int "" "" ]
	    buf$audace(bufNo) setkwd [ list NAXIS2 $haut int "" "" ]
	    buf$audace(bufNo) offset $moy
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	} elseif { $methodemoy == "back" } {

	    #--- Méthode du BACK :
	    ::console::affiche_resultat "Soustraction du fond de ciel : méthode fraction.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	    buf$audace(bufNo) imaseries "BACK back_kernek=30 back_threshold=0.2 sub"
	    buf$audace(bufNo) window $coords_zone_spectre
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	} elseif { $methodemoy == "sup" } {

	    #--- Soustraction du fond de ciel d'une zone dessus le spectre :
	    ::console::affiche_resultat "Soustraction du fond de ciel d'une zone dessus le spectre.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set moy [expr -1.*[ lindex [ buf$audace(bufNo) stat ] 6 ] ]
	    #-- Crée une image uniforme d'intensité égale à la moyenne des fonds de ciel
	    set haut [ expr int($hauteur)+1 ]
	    buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 $haut FORMAT_USHORT COMPRESS_NONE 0
	    buf$audace(bufNo) setkwd [ list NAXIS 2 int "" "" ]
	    buf$audace(bufNo) setkwd [ list NAXIS1 $naxis1 int "" "" ]
	    buf$audace(bufNo) setkwd [ list NAXIS2 $haut int "" "" ]
	    buf$audace(bufNo) offset $moy
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	} elseif { $methodemoy == "inf" } {

	    #--- Soustraction du fond de ciel d'une zone dessus le spectre :
	    ::console::affiche_resultat "Soustraction du fond de ciel d'une zone dessous le spectre.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zoneinf"
	    set moy [expr -1.*[ lindex [ buf$audace(bufNo) stat ] 6 ] ]
	    #-- Crée une image uniforme d'intensité égale à la moyenne des fonds de ciel
	    set haut [ expr int($hauteur)+1 ]
	    buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 $haut FORMAT_USHORT COMPRESS_NONE 0
	    buf$audace(bufNo) setkwd [ list NAXIS 2 int "" "" ]
	    buf$audace(bufNo) setkwd [ list NAXIS1 $naxis1 int "" "" ]
	    buf$audace(bufNo) setkwd [ list NAXIS2 $haut int "" "" ]
	    buf$audace(bufNo) offset $moy
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	} elseif { $methodemoy == "none" } {

	    #--- Aucune soustraction du fond de ciel
	    ::console::affiche_resultat "Aucune soustraction du fond de ciel.\n"
	    file copy -force "$audace(rep_images)/${spectre}_zone$conf(extension,defaut)" "$audace(rep_images)/${spectre}_zone_fc$conf(extension,defaut)"
	} else {
	    ::console::affiche_resultat "Mauvaise option de calcul du fond de ciel.\n"
	}

	#--- Sauvegarde et netoyages :
	::console::affiche_resultat "Spectre 2D nettoyé du fond de ciel sauvé sous ${spectre}_zone_fc.\n"
	# file delete $audace(rep_images)/${spectre}_zone$conf(extension,defaut)
	file delete $audace(rep_images)/${spectre}_zonesup$conf(extension,defaut)
	file delete $audace(rep_images)/${spectre}_zoneinf$conf(extension,defaut)
	return ${spectre}_zone_fc
    } else {
	::console::affiche_erreur "Usage: spc_subsky spectre_2D_fits y_centre_spectre hauteur_spectre méthode_soustraction_fond_de_ciel (moy, moy2, med, sup, inf, none, back)\n\n"
    }
}
#***************************************************************************#

