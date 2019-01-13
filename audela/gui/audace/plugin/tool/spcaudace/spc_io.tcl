####################################################################################
#
# Procedures d'entree-sortie gérant des spectres
# Auteur : Benjamin MAUCLAIRE
# Date de création : 31-01-2005
# Date de mise a jour : 21-02-2005
# Chargement en script :
# A130 : source $audace(rep_scripts)/spcaudace/spc_io.tcl
# A140 : source [ file join $audace(rep_plugin) tool spcaudace spc_io.tcl ]
#
#####################################################################################

# Mise a jour $Id: spc_io.tcl 14525 2018-11-09 18:22:10Z bmauclaire $



# Remarque (par Benoît) : il faut mettre remplacer toutes les variables textes par des variables caption(mauclaire,...)
# qui seront initialisées dans le fichier cap_mauclaire.tcl
# et renommer ce fichier mauclaire.tcl ;-)

#global audace


####################  Liste des fonctions ###############################
#
# spc_spc2png : converti un profil de raies format fits en une image format png avec gnuplot
#
#######################################################


####################################################################
# Construit une page web avec les images PNG des profils normalises en 3 colonnes
# triés par ordre antichronologique
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 16-05-2005/20-09-06
# Arguments : fichier .fit du profil de raie ?fichier_sortie.dat?\
####################################################################

proc spc_buildhtml { args } {
   global conf
   global audace spcaudace
   #-- Nb colonnes du tableau :
   set nbcols 3

   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set flagnav [ lindex $args 0 ]
      set nb_cols $nbcols
   } elseif { $nbargs==2 } {
      set flagnav [ lindex $args 0 ]
      set nb_cols [ lindex $args 1 ]
   } elseif { $nbargs==4 } {
      set flagnav [ lindex $args 0 ]
      set nb_cols [ lindex $args 1 ]
      set lambda_min [ lindex $args 2 ]
      set lambda_max [ lindex $args 3 ]
   } else {
      ::console::affiche_erreur "Usage: spc_buildhtml affichage par navigateur (o/n) ?nb_colonnes (3)? ?lambda_min lambda_max?\n\n"
      return ""
   }


   #--- Informations sur les spectres :
   ::console::affiche_prompt "\nNormalisation, et détermination de lambda_min, lambda_max, ymin, ymax...\n"
   set listefile [ lsort -dictionary [ glob -tail -dir $audace(rep_images) *$conf(extension,defaut) ] ]
   set listefile [ spc_ldatesort $listefile ]
   set objname ""
   set listefilescaled [ list ]
   set bande_liste [ list ]
   set intensity_liste [ list ]
   foreach fichier $listefile {
      buf$audace(bufNo) load "$audace(rep_images)/$fichier"
      #-- Recherche du nom de l'objet :
      if { $objname == "" } {
         set listemotsclef [ buf$audace(bufNo) getkwds ]
         if { [ lsearch $listemotsclef "OBJNAME" ] !=-1 } {
            set objname [ lindex [ buf$audace(bufNo) getkwd "OBJNAME" ] 1 ]     
            if { [ regexp {(\w+\s?\w+)\s*} $objname match objnamef ] } {
               set objname "$objnamef"
            }
         }
      }

      #-- Determination de lambda_min et lambda_max :
      if { $nbargs<=2 } {
         set resultats [ spc_info $fichier ]
         set lmin [ lindex $resultats 3 ]
         set lmax [ lindex $resultats 4 ]
         lappend bande_liste [ list $fichier $lmin $lmax ]
      }

      #-- Normalisdation :
      #set fichier_norma [ spc_autonorma "$fichier" ]
      set fichier_norma [ spc_rescalecont "$fichier" ]
      lappend listefilescaled "$fichier_norma"

      #--  Determination de ymin et ymax :
      buf$audace(bufNo) load "$audace(rep_images)/$fichier_norma"
      buf$audace(bufNo) mult 1000
      set resultats [ buf$audace(bufNo) stat ]
      set ymin [ lindex $resultats 3 ]
      set ymax [ lindex $resultats 2 ]
      lappend intensity_liste [ list "$fichier_norma" $ymin $ymax ]
   }


   #--- Calculs ymin, ymax, lambda_min, lambda_max :
   set ymin [ expr 0.97*[ lindex [ lindex [ lsort -real -increasing -index 1 $intensity_liste ] 0 ] 1 ]/1000. ]
   set ymax [ expr 1.03*[ lindex [ lindex [ lsort -real -decreasing -index 2 $intensity_liste ] 0 ] 2 ]/1000. ]
   ::console::affiche_resultat "\nYmin=$ymin et Ymax=$ymax\n"
   #-- Lmin et Lmax :
   if { $nbargs<=2 } {
      set lambda_min [ lindex [ lindex [ lsort -real -decreasing -index 1 $bande_liste ] 0 ] 1 ]
      set lambda_max [ lindex [ lindex [ lsort -real -increasing -index 2 $bande_liste ] 0 ] 2 ]
      ::console::affiche_resultat "Lambda_min=$lambda_min et Lambda_max=$lambda_max\n"
   }


   #--- Conversion des profils spectraux fits en PNG :
   #-- Conversion png :
   ::console::affiche_prompt "\nConversion en PNG...\n"
   if { [ file exists "$audace(rep_images)/weboutput" ] } { file delete -force "$audace(rep_images)/weboutput" }
   file mkdir "$audace(rep_images)/weboutput"
   set repimgdflt "$audace(rep_images)"
   set audace(rep_images) "$audace(rep_images)/weboutput"
   set listepng [ list ]
   foreach spectre_rescaled $listefilescaled {
      #-- Cropping ses profils :
      file copy -force "$repimgdflt/$spectre_rescaled$conf(extension,defaut)" "$audace(rep_images)/$spectre_rescaled$conf(extension,defaut)"
      set spectre_cropped [ spc_select "$spectre_rescaled" $lambda_min $lambda_max ]
      lappend listepng [ spc_autofit2png "$spectre_cropped" "$objname" $lambda_min $lambda_max $ymin $ymax jpeg ]
      file delete -force "$audace(rep_images)/$spectre_rescaled$conf(extension,defaut)"
      file delete -force "$repimgdflt/$spectre_rescaled$conf(extension,defaut)"
      file delete -force "$audace(rep_images)/$spectre_cropped$conf(extension,defaut)"
   }
   set audace(rep_images) "$repimgdflt"


   #--- Creation du repertoire et ouverture de index.html :
   #-- Preambule HTML :
   set dateproduct [ mc_date2ymdhms now ]
   set year [ lindex $dateproduct 0 ]
   set mounth [ lindex $dateproduct 1 ]
   set day [ lindex $dateproduct 2 ]
   set fileout "index.html"
   set file_id [ open "$audace(rep_images)/weboutput/$fileout" w+ ]
   #- configure le fichier de sortie avec les fin de ligne "xODx0A"
   #- independamment du systeme LINUX ou WINDOWS
   fconfigure $file_id -translation crlf
   #-- Entete web :
   puts $file_id "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/ loose.dtd\">"
   puts $file_id "<html>"
   puts $file_id "<head>"
   puts $file_id "  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">"
   puts $file_id "  <title>$objname</title>"
   puts $file_id "  <meta name=\"generator\" content=\"SpcAudace, see http://wsdiscovery.free.fr/spcaudace/\">"
   puts $file_id "</head>"
   puts $file_id "<body bgcolor=\"#ffffff\">"
   puts $file_id "<br>"
   puts $file_id "<center><h1><span style=\"color: #1e3eff\">Chronological catalog of $objname spectra</span></h1><p>Updated: $day/$mounth/$year</p></center><br>"
   puts $file_id "<center>"
   puts $file_id "<table border=\"0\" cellpadding=\"0\" cellspacing=\"10\">"

   #-- Construction du tableau :
   ::console::affiche_prompt "\nConstruction du tableau HTML...\n"
   #- 340x260 -> 320x240
   set nbimg [ expr [ llength $listepng ]-1 ]
   for { set i $nbimg } { $i>=0 } { incr i -1 } {
      puts $file_id "  <tr>"
      for { set j 1 } { $j<=$nb_cols } { incr j } {
         set fichier [ lindex $listepng $i ]
         set fichier_jpg [ file rootname $fichier ]
         set fichier_jpg "${fichier_jpg}.jpg"
         # puts $file_id "    <td><a href=\"$fichier\"><img border=\"0\" src=\"$fichier\" width=\"320\" heigh=\"240\" alt=\"$fichier\" title=\"Clic to enlarge $fichier\"></a></td>"
         puts $file_id "    <td><a href=\"$fichier\"><img border=\"0\" src=\"$fichier_jpg\" alt=\"$fichier\" title=\"Clic to enlarge $fichier\"></a></td>"
         set fichierfit [ file rootname "$fichier" ]
         file delete -force "$audace(rep_images)/weboutput/$fichierfit$conf(extension,defaut)"
         if { $j!=$nb_cols } { incr i -1 }
      }
      puts $file_id "  </tr>"
      #set fichierfit [ file rootname "$fichier" ]
      #file delete -force "$audace(rep_images)/weboutput/$fichierfit$conf(extension,defaut)"
   }

   #--- Traitement de fin de script :
   puts $file_id "</table>"
   puts $file_id "</center>"
   puts $file_id "<br>"
   puts $file_id "</body>"
   puts $file_id "</html>"
   close $file_id
   if { $nbargs==1 || $nbargs==2 || $nbargs==4 } {
      if { $conf(editsite_htm)!="" && [ file exists "$audace(rep_images)/weboutput/$fileout" ] } {
         set answer [ catch { exec $conf(editsite_htm) "$audace(rep_images)/weboutput/$fileout" & } ]
      } else {
         ::console::affiche_resultat "Veuillez configurer \"Editeurs/Navigateur web\" pour permettre l'affichage de la page générée.\n"
      }
   }
   ::console::affiche_resultat "Page web sauvegardée sous $audace(rep_images)/weboutput/$fileout\n"
   return $fileout
}
#****************************************************************#

################################################################################################
# Procedure pour mise en conformite de deux profiis spectraux
# Auteur : Patrick LAILLY
# Date de creation : 25-08-12
# Date de modification : 25-08-12
# Cette procedure retourne la liste de deux fichiers apres leur mise en conformite en vue de leur
# division via spc_divbrut. La mise en conformite consiste decire les profils suivant les memes mots cles
# NAXIS1, CDELT1, CRPIX1 et CRVAL1. Plus precisement les 2 CRPIX1 vaudront 1, CDELT1 sera celui du
# premier profil (fichier modele), CRVAL1 sera la longueur de depart du 2eme profil apres elimination d'eventuels
# zeros. Quant a NAXIS1 il correspondra a l'intervalle effectif (apres elimination d'eventuels
# zeros) de longueurs d'ondes commun aux 2 profils.
# La procedure retourne la liste des 2 fichiers (dans l'ordre d'entree) contenant les profils ainsi modifies.
# Les deux fichiers d'entree sont cense etre calibres
# lineairement. Les fichiers de sortie seront reperes le suffixe _conform.
# Exemple spc_conform profile_model.fit profile_data.fit
#################################################################################################

proc spc_conform { args } {
   global audace spcaudace conf
   set nbargs [ llength $args ]
   if { $nbargs == 2 } {
      set nom_fich_input [ lindex $args 1 ]
      set nom_fich_input [ file rootname $nom_fich_input ]
      set nom_fich_model [ lindex $args 0 ]
      set nom_fich_model [ file rootname $nom_fich_model ]
      set nbunit "double"
      if { [ spc_testlincalib $nom_fich_input ] == -1 } {
      	::console::affiche_resultat "spc_echantmodel1 : ATTENTION le profil a reechantilloner n'est pas calibré linéairement on tente cependant d'executer la procedure apres avoir linearise la loi de calibration \n\n"
	 set nom_fich_input [ spc_linearcal $nom_fich_input ]
      }
      if { [ spc_testlincalib $nom_fich_model ] == -1 } {
	 ::console::affiche_erreur "spc_echantmodel1 : le profil modele n'est pas calibré linéairement et la mise en oeuvre de la procedure n'a pas de sens \n\n"
	 return ""
      }

      #--- Elimination d'eventuels zeros dans le profil modele
      set nom_fich_model [ spc_rmedges $nom_fich_model 0. ]
      #--- Caracteristiques du profil modele:
      buf$audace(bufNo) load "$audace(rep_images)/$nom_fich_model"
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
      #::console::affiche_resultat "caractÃ©ristiques fichier modÃ¨le cdelt1= $cdelt1 naxis1= $naxis1 crval1= $crval1 \n"
      #buf$audace(bufNo) delkwds
      #buf$audace(bufNo) clear
      #--- Elimination d'eventuels zeros dans le 2eme profil
      set nom_fich_input [ spc_rmedges $nom_fich_input 0. ]
      #--- Renseigne sur les parametres du 2 eme profil
      buf$audace(bufNo) load "$audace(rep_images)/$nom_fich_input"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      set naxis2 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
      set crval2 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      set cdelt2 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
      if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
          set crpix2 [ lindex [ buf$audace(bufNo) getkwd "CRPIX1" ] 1 ]
      } else {
         set crpix2 1
      }
      #--- Calcul de l'intervalle de longueurs d'ondes commun aux 2 profils
      set lambdamin1 [ expr $crval1 + (1 - $crpix1) * $cdelt1 ]
      set lambdamin2 [ expr $crval2 + (1 - $crpix2) * $cdelt2 ]
      set lambdamax2 [ expr $crval2 + ($naxis2 - $crpix2) * $cdelt2 ]
      set lambdamax1 [ expr $crval1 + ($naxis1 - $crpix1) * $cdelt1 ]
      set lambdamin [ expr max($lambdamin1, $lambdamin2) ]
      set lambdamax [ expr min($lambdamax1, $lambdamax2) ]
      ::console::affiche_resultat "$lambdamin1 $lambdamin2 $lambdamin $lambdamax1 $lambdamax2 $lambdamax\n"
      # calcul de la longueur d'onde de depart des 2 profils mis en conformite
      set nn 0
      if { $lambdamin > $lambdamin1 } {
	 # alors il faut caler la d'onde de depart de facon a ce qu'elle tombe sur un echantillon du 1er profil
	 set nn [ expr int ( ($lambdamin - $lambdamin1) / $cdelt1 ) +1 ]
	 # si, par hasard, la division ci dessus tombait juste, le degat consisterait a perdre un echantillon => pas grave
	 set lambdamin [ expr $lambdamin1 + $nn * $cdelt1 ]
      }
      if { $lambdamin >= $lambdamax } {
	 ::console::affiche_erreur "spc_conform : l' intervalle de longueurs d'onde commun aux 2 profils est vide, on ne peut donner suite...\n\n"
	 return ""
      } else {
	 set crvalnew $lambdamin
	 set cdeltnew $cdelt1
	 set naxisnew [ expr int ( ($lambdamax - $lambdamin )  / $cdelt1 ) +1 ]
	 set naxisnew [ expr $naxisnew -1 ]
	 # l'instruction ci dessus est une precaution au cas ou la division ci-dessus tomberait juste

	 if { [ expr $lambdamin + $naxisnew * $cdelt1 ] == $lambdamax } {
	    set naxisnew [ expr $naxisnew - 1 ]
	    if { [ expr $lambdamin + $naxisnew * $cdelt1 ] > $lambdamax1 } {
	       # dans ce cas il n'aurait pas fallu arrondir a l'echantillon superieur pour le calcul de nn
	       set nn [ expr $nn - 1 ]
	    }
	 }
	 #::console::affiche_resultat " cracteristiques des profils conformes : crvalnew= $crvalnew  cdelt= $cdeltnew naxis= $naxisnew $nn\n"
	 set fich2 [ spc_echantdelt $nom_fich_input $cdeltnew $crvalnew ]
	 set fich2new [ spc_selectpixels $fich2 1 $naxisnew ]
	 set fich1new [ spc_selectpixels $nom_fich_model [ expr $nn + 1 ] [ expr $naxisnew +$nn ] ]
	 set suff _conform
	 set ext $conf(extension,defaut)
	 file rename -force "$audace(rep_images)/$fich1new$ext" "$audace(rep_images)/$nom_fich_model$suff$ext"
	 file rename -force "$audace(rep_images)/$fich2new$ext" "$audace(rep_images)/$nom_fich_input$suff$ext"
	 ::console::affiche_resultat " les 2 profils ont ete, apres mise en conformite, sauvegardes sous $nom_fich_model$suff et $nom_fich_input$suff\n"
	 set lresult [list ]
	 lappend lresult $nom_fich_model$suff
	 lappend lresult $nom_fich_input$suff
	 # effacement des fichiers temporaires
	 file delete -force "$audace(rep_images)/$fich2$conf(extension,defaut)"
	 # ::console::affiche_resultat " effacement du fichier $fich2 \n"
	 return $lresult
      }

   } else {
      ::console::affiche_erreur "Usage: spc_conform profile_model.fits(calibre lineairement)  autre_profil.fits\n\n"
      return ""
   }
}
#*****************************************************************#

####################################################################
# Procedure de mise a jour des intensites d'un profil fits
# (cas ou les nouvelles intensites sont echantillonees lineairement)
#
# Auteur : Patrick LAILLY
# Date creation : 09-09-12
# Date modification : 09-09-12
# Contrairement a l'ancienne version, on cree ici un nouveau fichier, avec le suffixe donne en argument, qui herite
# des mots cles inchanges du fichier d'origine
# Arguments : nom fichier fits, CRVAL1, CDELT1, liste nouvelles intensites, suffixe
# exemple : spc_fileupdate nom_fich 6237.54321 0.312765 list_intensites suffixe
####################################################################

proc spc_fileupdate { args } {
   global audace spcaudace conf

   set nbargs [ llength $args ]
   if { $nbargs == 5 } {
      set nomfich [ lindex $args 0 ]
      set crval1 [ lindex $args 1 ]
      set cdelt1 [ lindex $args 2 ]
      set listeintens [ lindex $args 3 ]
      set suffixe [ lindex $args 4 ]
      if { [ spc_testlincalib $nomfich ] != 1 } {
	 ::console::affiche_erreur "spc_fileupdate : le profil $nomfich n'est pas calibre lineairement et la mise en oeuvre de la procedure n'a pas de sens\n\n"
         return ""
      }
      buf$audace(bufNo) load "$audace(rep_images)/$nomfich"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	 buf$audace(bufNo) delkwd "SPC_A"
      }
      if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
	 buf$audace(bufNo) delkwd "SPC_B"
      }
      if { [ lsearch $listemotsclef "SPC_C" ] !=-1 } {
	 buf$audace(bufNo) delkwd "SPC_C"
      }
      if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
	 buf$audace(bufNo) delkwd "SPC_D"
      }
      if { [ lsearch $listemotsclef "SPC_DESC" ] !=-1 } {
	 buf$audace(bufNo) delkwd "SPC_DESC"
      }
      set lintens [ llength $listeintens ]
      set naxis1 $lintens
      #--- Creation du nouveau profil de raies :
      set newBufNo [ buf::create ]
      buf$newBufNo setpixels CLASS_GRAY $naxis1 1 FORMAT_FLOAT COMPRESS_NONE 0
      buf$newBufNo copykwd $audace(bufNo)
      buf$newBufNo setkwd [list "NAXIS1" $naxis1 int "" ""]
      buf$newBufNo setkwd [list "CRVAL1" $crval1 double "Wavelength at reference pixel" "angstrom"]
      #-- Dispersion
      buf$newBufNo setkwd [list "CDELT1" $cdelt1 double "Wavelength increment" "angstrom/pixel"]
      #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
      for {set k 0} { $k < $naxis1 } {incr k} {
	 buf$newBufNo setpix [list [expr $k+1] 1] [lindex $listeintens $k ]
      }
      #--- Sauvegarde du fichier fits ainsi cree
      buf$newBufNo bitpix float
      set suff "$suffixe"
      set nom_fich_output "$nomfich$suff"
      buf$newBufNo save "$audace(rep_images)/$nom_fich_output"
      ::console::affiche_resultat " spc_fileupdate sauvegarde du fichier $nom_fich_output \n"
      #buf$audace(bufNo) bitpix short

       buf::delete $newBufNo
      return $nom_fich_output
   } else {
      ::console::affiche_erreur "Usage: spc_fileupdate nom_fich crval1 cdelt1 liste_intensites suffixe \n\n"
      return 0
   }
}
#*************************************************************************




####################################################################
# Procedure de mise a jour des intensites d'un profil fits
# (cas ou les nouvelles intensites sont echantillonees lineairement)
#
# Auteur : Patrick LAILLY
# Date creation : 25-11-09
# Date modification : 25-11-09
# Arguments : nom fichier fits, CRVAL1, CDELT1, liste nouvelles intensites, (suffixe, option effacement ancien fichier (oui/non))
# exemple : spc_fileupdate nom_fich 6237.54321 0.312765 list_intensites
# exemple : spc_fileupdate nom_fich 6237.54321 0.312765 list_intensites suffixe oui
####################################################################

proc spc_fileupdate_old { args } {
   global audace spcaudace conf

   set nbargs [ llength $args ]
   if { $nbargs ==6 || $nbargs ==4 } {
      set nomfich [ lindex $args 0 ]
      set crval1 [ lindex $args 1 ]
      set cdelt1 [ lindex $args 2 ]
      set listeintens [ lindex $args 3 ]
      set suffixe new
      if { $nbargs ==6 } {
	 set suffixe [ lindex $args 4 ]
	 set delopt [ lindex $args 5 ]
      }
      buf$audace(bufNo) load "$audace(rep_images)/$nomfich"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	 buf$audace(bufNo) delkwd "SPC_A"
      }
      if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
	 buf$audace(bufNo) delkwd "SPC_B"
      }
      if { [ lsearch $listemotsclef "SPC_C" ] !=-1 } {
	 buf$audace(bufNo) delkwd "SPC_C"
      }
      if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
	 buf$audace(bufNo) delkwd "SPC_D"
      }
      if { [ lsearch $listemotsclef "SPC_DESC" ] !=-1 } {
	 buf$audace(bufNo) delkwd "SPC_DESC"
      }
      set lintens [ llength $listeintens ]
      set naxis1 [ lindex [ buf$audace(bufNo) getkwd NAXIS1 ] 1 ]
      #set nbunit "float"
      #set nbunit1 "double"
      #buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 1 FORMAT_FLOAT COMPRESS_NONE 0
      set naxis [ lindex [ buf$audace(bufNo) getkwd NAXIS ] 1 ]
      #if { $naxis != 1 } {
	# ::console::affiche_erreur "spc_fileupdate : le fichier fits $nomfich n'est pas un profil\n\n"
	 #return ""
      #}
      if { $lintens != $naxis1 } {
         ::console::affiche_erreur "spc_fileupdate : mise a jour du fichier fits $nomfich impossible : les longueurs des intensites du fichier $naxis1 et de la liste $lintens sont differentes\n\n"
         return ""
      }
      buf$audace(bufNo) setkwd [list "NAXIS1" $naxis1 int "" ""]
      #buf$audace(bufNo) setkwd [list "NAXIS2" 1 int "" ""]
      buf$audace(bufNo) setkwd [list "CRVAL1" $crval1 double "Wavelength at reference pixel" "angstrom"]
      #-- Dispersion
      buf$audace(bufNo) setkwd [list "CDELT1" $cdelt1 double "Wavelength increment" "angstrom/pixel"]
      #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
      for {set k 0} { $k < $naxis1 } {incr k} {
	 		buf$audace(bufNo) setpix [list [expr $k+1] 1] [lindex $listeintens $k ]
      }
      #--- Sauvegarde du fichier fits ainsi cree
      buf$audace(bufNo) bitpix float
      set suff "_$suffixe"
      set nom_fich_output "$nomfich$suff"
      buf$audace(bufNo) save "$audace(rep_images)/$nom_fich_output"
      ::console::affiche_resultat " sauvegarde du fichier $nom_fich_output \n"
      buf$audace(bufNo) bitpix short
      set yes oui
      if { $delopt == $yes } {
	 file delete -force "$audace(rep_images)/$nomfich$conf(extension,defaut)"
      	::console::affiche_resultat " effacement du fichier $nomfich \n"
      }
      return $nom_fich_output
   } else {
      ::console::affiche_erreur "Usage: spc_fileupdate nom_fich_fits ? liste_param_header ? liste_intensites ? suffixe ? option effacement ?\n\n"
      return 0
   }
}
#*************************************************************************



#######################################################
#  Procedure d'ouverture de fichiers
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-2005
# Arguments : nom du fichier
########################################################

proc openfile { args } {
   global conf
   global audace

 if {[llength $args] == 1} {
   set filenamespc [ lindex $args 0 ]
   catch {unset profilspc} {}
   set profilspc(initialdir) [file dirname $audace(rep_images)]
   set profilspc(initialfile) [file tail $filenamespc]
   set input [open "$audace(rep_images)/$filenamespc" r]
   close input
   return $input
 } else {
   ::console::affiche_erreur "Usage: openfile fichier.fit\n\n"
 }
}
#****************************************************************#


#######################################################
#  Procedure d'ouverture de fichiers .dat avec interface graphique
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-2005
# Arguments : nom du fichier
########################################################

proc openfileg { {filename ""} } {
   global conf
   global audace
   global caption

   ## === Interfacage de l'ouverture du fichier profil de raie ===
   if {$filename==""} {
      # set idir ./
      # set ifile *.spc
      set idir $audace(rep_images)
      set ifile $conf(extension,defaut)

      if {[info exists profilspc(initialdir)] == 1} {
         set idir "$profilspc(initialdir)"
      }
      if {[info exists profilspc(initialfile)] == 1} {
         set ifile "$profilspc(initialfile)"
      }
      set filenamespc [tk_getOpenFile -title $caption(spcaudace,gui,loadspctxt) -filetypes [list [list "$caption(spcaudace,gui,spc_profile)" {.dat .$conf(extension,defaut)}]] -initialdir $idir -initialfile $ifile ]
      if {[string compare $filenamespc ""] == 0 } {
         return 0
      }
   }
   return $filenamespc
}
#****************************************************************#


#######################################################
#  Procedure d'ouverture de spectre au format fits
#
# Auteur : Benjamin MAUCLAIRE
# Date création : 15-02-2005
# Date modification : 15-02-2005 / 17-12-2005 / 20-12-2005
# Arguments : nom du repertoire/fichier
# Sortie :
#  Si calibré : liste contenant la liste des valeurs de l'intensité, NAXIS1, CRVAL1, CDELT1, CRPIX1, CTYPE1.
#  Si non calibre : liste contenant la liste des valeurs de l'intensité, NAXIS1
# Remarque : fonction appelée par spc_loadfit (spc_profil.tcl)
########################################################

proc openspc { args } {
    global conf
    global audace
    #global profilspc

 if {[llength $args] == 1} {
   set filenamespc [ lindex $args 0 ]
   catch {unset profilspc} {}
   #set profilspc(initialdir) [file dirname $audace(rep_images)]
   #set profilspc(initialfile) [file tail $filenamespc]
   #set repertoire [file dirname $audace(rep_images)]
   #- Modif bug le 051221 : FIN BUG !
   set repertoire [file dirname $filenamespc]
   set fichier [file tail $filenamespc]

   #-- Remis le 16/12/2005
   #buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
   #-- Remis le 15/02/2005
   #buf$audace(bufNo) load "$filenamespc"
   #-- Mis le 17/12/2005
   #cd $repertoire
   #loadima $filenamespc -nodisp
   #-- Mis le 20/12/2005
   buf$audace(bufNo) load $repertoire/$fichier

   # Determine si c'est un spectre etalonne ou non etalonne en longueur d'onde
   set mot ""
   set flagcalib 0
   set motsheader [buf$audace(bufNo) getkwds]
   set len [llength $motsheader]
   for {set k 0} {$k<$len} {incr k} {
       set mot [lindex $motsheader $k]
       if { [string compare $mot "CRVAL1"] == 0 } {
           set flagcalib 1
           break
       } else {
           set flagcalib 0
       }
   }

   if { $flagcalib == 0 } {
       ::console::affiche_resultat "Ouverture d'un spectre non calibré $filenamespc\n"
       set spectre [openspcncal $repertoire $fichier]
   } else {
       ::console::affiche_resultat "Ouverture d'un spectre calibré $filenamespc\n"
       set spectre [openspccal $repertoire $fichier]
   }
   return $spectre
 } else {
   ::console::affiche_erreur "Usage: openspc fichier_profil.fit\n\n"
 }
}
#****************************************************************#


#######################################################
#  Procedure d'ouverture de spectre non calibré (lambda) au format fits
#
# Auteur : Benjamin MAUCLAIRE
# Date création : 15-02-2005
# Date modification : 20-12-2005
# Arguments : nom du répertoire, nom du fichier
# Sortie : liste contenant la liste des valeurs de l'intensité, NAXIS1
########################################################

proc openspcncal { args } {
   global conf
   global audace audela

 if {[llength $args] == 2} {
   set repertoire [ lindex $args 0 ]
   set filenamespc [ lindex $args 1 ]
   #catch {unset profilspc} {}
   #set profilspc(initialdir) [file dirname $audace(rep_images)]
   #set profilspc(initialfile) [file tail $filenamespc]
   buf$audace(bufNo) load $repertoire/$filenamespc
   #buf$audace(bufNo) load $filenamespc

   set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]

   if { [regexp {1.3.0} $audela(version) match resu ] } {
       for {set k 1} {$k<=$naxis1} {incr k} {
           # Lit la valeur des elements du fichier fit
           lappend intensites [buf$audace(bufNo) getpix [list $k 1]]
       }
   } else {
       for {set k 1} {$k<=$naxis1} {incr k} {
           lappend intensites [ lindex [buf$audace(bufNo) getpix [list $k 1]] 1 ]
       }
   }
   set spectre [list $intensites $naxis1]
   return $spectre
 } else {
   ::console::affiche_erreur "Usage: openspcncal répertoire fichier_profil.fit\n\n"
 }
}
#****************************************************************#



#######################################################
#  Procedure d'ouverture de spectre calibré (lambda) au format fits
#
# Auteur : Benjamin MAUCLAIRE
# Date création : 15-02-2005
# Date modification : 15-02-2005
# Arguments : répertoire nom du fichier
# Sortie : liste contenant la liste des valeurs de l'intensité, NAXIS1, CRVAL1, CDELT1, CRPIX1, CTYPE1.
########################################################

proc openspccal { args } {
   global conf
   global audace audela

 if {[llength $args] == 2} {
   set repertoire [ lindex $args 0 ]
   set filenamespc [ lindex $args 1 ]
   #catch {unset profilspc} {}
   #set profilspc(initialdir) [file dirname $audace(rep_images)]
   ##set profilspc(initialfile) [file tail $filenamespc]
   ##buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
   #buf$audace(bufNo) load "$filenamespc"
   buf$audace(bufNo) load $repertoire/$filenamespc

   set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
   # Valeur minimale de l'abscisse : =0 si profil non étalonné
   set xdepart [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
   # Dispersion du spectre : =1 si profil non étalonné
   set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
   # Pixel de l'abscisse centrale
   set xcenter [lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1]
   # Type de spectre : LINEAR ou NONLINEAR
   set dtype [lindex [buf$audace(bufNo) getkwd "CTYPE1"] 1]

   if { [regexp {1.3.0} $audela(version) match resu ] } {
       for {set k 1} {$k<=$naxis1} {incr k} {
           #-- Lit la valeur des elements du fichier fit
           # lappend intensites [buf$audace(bufNo) getpix [list $k 1]]
           #-- Gestion des valeurs "nan" de l'intensite
           set ival [ buf$audace(bufNo) getpix [list $k 1] ]
           #if { $ival == "nan" } {
           #   lappend intensites 0
           #   ::console::affiche_resultat "Cas nan : $ival\n"
           #} else {
           lappend intensites $ival
           #}
       }
   } else {
       set ival [ lindex [ buf$audace(bufNo) getpix [list $k 1] ] 1 ]
   }
   set spectre [list $intensites $naxis1 $xdepart $xincr $xcenter "$dtype"]
   return $spectre
 } else {
   ::console::affiche_erreur "Usage: openspccal répertoire fichier_profil.fit\n\n"
 }
}
#****************************************************************#



#######################################################
#  Procedure d'ouverture d'un profil spectral au format fits
#
# Auteur : Benjamin MAUCLAIRE
# Date création : 11-12-2005
# Date modification : 11-12-2005
# Arguments : nom du fichier profil de raies calibré
# Sortie : liste contenant la liste des valeurs des abscisses et intensités
########################################################

proc spc_openspcfits { args } {

    global conf
    global audace audela

    if {[llength $args] == 1} {
        set filenamespc [ lindex $args 0 ]
        set erreur [ lindex $args 1 ]
        buf$audace(bufNo) load $audace(rep_images)/$filenamespc
        #buf$audace(bufNo) load $filenamespc
        set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
        #--- Valeur minimale de l'abscisse : =0 si profil non étalonné
        set xdepart [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
        #--- Dispersion du spectre : =1 si profil non étalonné
        set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
        ::console::affiche_resultat "$naxis1 points à traiter\n"
        if { [regexp {1.3.0} $audela(version) match resu ] } {
            #--- Une liste commence à 0 ; Un vecteur fits commence à 1
           for {set k 0} {$k<$naxis1} {incr k} {
                #--- Donne les bonnes valeurs aux abscisses si le spectre est étalonné en longueur d'onde
                lappend abscisses [expr $xdepart+($k)*$xincr*1.0]
                #--- Lit la valeur (intensite) des elements du fichier fit
                lappend ordonnees [buf$audace(bufNo) getpix [list [expr $k+1] 1]]
            }
       } else {
           for {set k 0} {$k<$naxis1} {incr k} {
                #--- Donne les bonnes valeurs aux abscisses si le spectre est étalonné en longueur d'onde
                lappend abscisses [expr $xdepart+($k)*$xincr*1.0]
                #--- Lit la valeur (intensite) des elements du fichier fit
                lappend ordonnees [ lindex [buf$audace(bufNo) getpix [list [expr $k+1] 1]] 1 ]
            }
       }
       set sortie [list $abscisses $ordonnees]
       return $sortie
    } else {
        ::console::affiche_erreur "Usage: spc_openspcfits fichier_profil.fit\n\n"
    }
}
#****************************************************************#



###################################################################
#  Procedure de conversion de fichier profil de raies linéaire .dat en .fit
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 04-09-2008
# Date modification : 04-09-2008
# Arguments : fichier .dat du profil de raie ?fichier_sortie.fit?
###################################################################

proc spc_dat2fitslin { args } {

   global conf caption
   global audace spcaudace

   if { [llength $args] <= 2 } {
      if { [llength $args] == 1 } {
         set filenamespc [ file tail [ lindex $args 0 ] ]
      } elseif { [llength $args] == 2 } {
         set filenamespc [ file tail [ lindex $args 0 ] ]
         set filenameout [ lindex $args 1 ]
      } elseif { [llength $args]==0 } {
         set spctrouve [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "$spcaudace(extdat) $spcaudace(exttxt)" ] ] -initialdir $audace(rep_images) ] ]
         if { [ file exists "$audace(rep_images)/$spctrouve" ] == 1 } {
            set filenamespc $spctrouve
         } else {
            ::console::affiche_erreur "Usage: spc_dat2fits fichier_profil.dat ?fichier_sortie.fit?\n\n"
            return 0
         }
      } else {
         ::console::affiche_erreur "Usage: spc_dat2fits fichier_profil.dat ?fichier_sortie.fit?\n\n"
         return 0
      }

      #--- Lecture du fichier de donnees du profil de raie ===
      set input [open "$audace(rep_images)/$filenamespc" r]
      set contents [split [read $input] \n]
      close $input
      set k 0
      foreach ligne $contents {
         set abscisse [ lindex $ligne 0 ]
         if { $abscisse!="" } {
            lappend abscisses_lin [ expr $k+1 ]
            lappend abscisses $abscisse
            append intensites "[ lindex $ligne 1 ] "
            incr k
         }
      }
      set naxis1 $k

      #--- Verfiei que les elements des intensites sont bien des nombres :
      set intensite 0
      set good_intensites [ list ]
      for {set k 0} {$k<$naxis1} {incr k} {
         set intensite [ lindex $intensites $k ]
         if { [ regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite ] || [regexp {(\.*[0-9]*)} $intensite match mintensite] } {
            lappend good_intensites $mintensite
            set intensite 0
         }
      }
      #-- Détermine la première longueur d'onde :
      foreach abscisse $abscisses {
         if { [ regexp {([0-9]+\.*[0-9]*)} $abscisse match mabscisse ] } {
            set lambda_deb $mabscisse
            break
         }
      }
      if { $lambda_deb != 1. } {
         #-- Profil calibré en longueur d'onde :
         set flag_spccal 1
      } else {
         #-- Profil non calibré en longueur d'onde :
         set flag_spccal 0
      }
      #-- Détermine la derniere longueur d'onde :
      set lambda_fin [ lindex $abscisses [ expr $naxis1-1 ] ]

      #--- Calcul les longueurs éspacées d'un pas constant :
      if { $flag_spccal } {
         #-- Calcul le pas del calibration linéaire :
         set dispersion [ expr ($lambda_fin-$lambda_deb)/($naxis1 +1) ]

         #-- Calcul les longueurs d'onde (linéaires) associées a chaque pixel :
         set lambdas [ list ]
         for {set i 0} {$i<$naxis1} {incr i} {
            lappend lambdas [ expr $dispersion*$i+$lambda_deb ]
         }
         #-- Rééchantillonne par spline les intensités sur la nouvelle échelle en longueur d'onde :
         #-- Verifier les valeurs des lambdas pour eviter un "monoticaly error de BLT".
         set new_intensites [ lindex  [ spc_spline $abscisses $good_intensites $lambdas n ] 1 ]
      }

      #--- Crée le fichier FITS :
      set newBufNo [ buf::create ]
      buf$newBufNo setpixels CLASS_GRAY $naxis1 1 FORMAT_FLOAT COMPRESS_NONE 0
      #-- Creation des mots clef :
      buf$newBufNo setkwd [ list "NAXIS" 1 int "" "" ]
      buf$newBufNo setkwd [ list "NAXIS1" $naxis1 int "" "" ]
      buf$newBufNo setkwd [list "DATE-OBS" "0000-00-00T00:00:00.00" string "Start of exposure. FITS standard" "Iso 8601"]
      buf$newBufNo setkwd [list "EXPOSURE" 0. float "Exposure duration" "second"]
      if { $flag_spccal } {
         buf$newBufNo setkwd [list "CRPIX1" 1 double "Reference pixel" "pixel"]
         buf$newBufNo setkwd [list "CRVAL1" $lambda_deb double "Wavelength at reference pixel" "angstrom"]
         buf$newBufNo setkwd [list "CDELT1" $dispersion double "Wavelength increment" "angstrom/pixel"]
         buf$newBufNo setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
         #-- Corrdonnée représentée sur l'axe 1 (ie X) :
         buf$newBufNo setkwd [list "CTYPE1" "Wavelength" string "" ""]
      } else {
         buf$newBufNo setkwd [list "CRVAL1" $lambda_deb double "" "pixel"]
         buf$newBufNo setkwd [list "CDELT1" $dispersion double "" "pixel"]
         buf$newBufNo setkwd [list "CRPIX1" 1 double "Reference pixel" "pixel"]
         buf$newBufNo setkwd [list "CTYPE1" "position" string "" ""]
      }
      #-- Initalise les intensites :
      if { $flag_spccal } {
         #-- Profil calibré en longueur d'onde :
         for {set k 1} {$k<=$naxis1} {incr k} {
            buf$newBufNo setpix [list $k 1] [ lindex $new_intensites [ expr $k-1 ] ]
         }
      } else {
         #-- Profil non calibré en longueur d'onde :
         for {set k 1} {$k<=$naxis1} {incr k} {
            buf$newBufNo setpix [list $k 1] [ lindex $good_intensites [ expr $k-1 ] ]
         }
      }

      #--- Sauve le fichier fits ainsi constitué :
      buf$newBufNo bitpix float
      if { [llength $args]==1 || [llength $args]==0 } {
         set nom [ file rootname $filenamespc ]
         buf$newBufNo bitpix float
         buf$newBufNo save "$audace(rep_images)/${nom}$conf(extension,defaut)"
         buf$newBufNo bitpix short
         ::console::affiche_resultat "Fichier fits sauvé sous $audace(rep_images)/${nom}$conf(extension,defaut)\n"
         buf::delete $newBufNo
         return ${nom}
      } elseif { [llength $args]==2 } {
         set nom [ file rootname $filenameout ]
         buf$newBufNo bitpix float
         buf$newBufNo save "$audace(rep_images)/${filenameout}$conf(extension,defaut)"
         buf$newBufNo bitpix short
         ::console::affiche_resultat "Fichier fits sauvé sous $audace(rep_images)/${filenameout}$conf(extension,defaut)\n"
         buf::delete $newBufNo
         return ${filenameout}
      }
   } else {
      ::console::affiche_erreur "Usage: spc_dat2fitslin fichier_profil.dat ?fichier_sortie.fit?\n\n"
   }
}
#****************************************************************#




###################################################################
#  Procedure de conversion de fichier profil de raies .dat en .fit
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 31-01-2005
# Date modification : 15-02-2005/27-04-2006
# Arguments : fichier .dat du profil de raie ?fichier_sortie.fit?
###################################################################

proc spc_dat2fits { args } {

    global conf caption
    global audace spcaudace

    #set nbunit "float"
    set nbunit "double"
    set precision 0.05

    if { [llength $args] <= 2 } {
       if { [llength $args] == 1 } {
          set filenamespc [ file tail [ lindex $args 0 ] ]
       } elseif { [llength $args] == 2 } {
          set filenamespc [ file tail [ lindex $args 0 ] ]
          set filenameout [ lindex $args 1 ]
       } elseif { [llength $args]==0 } {
          set spctrouve [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "$spcaudace(extdat) $spcaudace(exttxt)" ] ] -initialdir $audace(rep_images) ] ]
          if { [ file exists "$audace(rep_images)/$spctrouve" ] == 1 } {
             set filenamespc $spctrouve
          } else {
             ::console::affiche_erreur "Usage: spc_dat2fits fichier_profil.dat ?fichier_sortie.fit?\n\n"
             return ""
          }
       } else {
          ::console::affiche_erreur "Usage: spc_dat2fits fichier_profil.dat ?fichier_sortie.fit?\n\n"
          return ""
       }

       #--- Lecture du fichier de donnees du profil de raie :
       set input [open "$audace(rep_images)/$filenamespc" r]
       set contents [split [read $input] \n]
       close $input

       #--- Extraction des numeros des pixels et des intensites :
       set k 0
       foreach ligne $contents {
            set abscisse [ lindex $ligne 0 ]
          if { $abscisse!="" } {
             lappend abscisses_lin [ expr $k+1 ]
             lappend abscisses $abscisse
             append intensites "[ lindex $ligne 1 ] "
             incr k
          }
       }
       set naxis1 $k

       #--- Creation du fichier fits :
       #-- Initialisation à blanc d'un fichier fits :
       buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 1 FORMAT_FLOAT COMPRESS_NONE 0
       buf$audace(bufNo) setkwd [ list "NAXIS" 1 int "" "" ]
       buf$audace(bufNo) setkwd [ list "NAXIS1" $naxis1 int "" "" ]
       set crpix1 1
       buf$audace(bufNo) setkwd [ list "CRPIX1" $crpix1 double "Reference pixel" "pixel" ]

       #-- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie :
       #- Une liste commence à 0 ; Un vecteur fits commence à 1
       set intensite 0
       for {set k 1} {$k<=$naxis1} {incr k} {
          append intensite [ lindex $intensites [ expr $k-1 ] ]
          if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] || [regexp {(\.*[0-9]*)} $intensite match mintensite] } {
             buf$audace(bufNo) setpix [list $k 1] $mintensite
             set intensite 0
          }
       }

       #--- Détermine la première longueur d'onde :
       foreach abscisse $abscisses {
          if { [ regexp {([0-9]+\.*[0-9]*)} $abscisse match mabscisse ] } {
             set lambdadeb $mabscisse
             break
          }
       }


       #---- Calcul du polynôme de la loi de dispersion :
       if { $lambdadeb == 1.0 } {
          set dispersion 1.
       } else {
          #--- Determine si la calibration est lineaire ou non :
          if { $naxis1>=10 } {
             set l1 [ lindex $abscisses 2 ]
             set l2 [ lindex $abscisses 3 ]
             set dispe [ expr $l2-$l1 ]
             set x1 [ expr int($naxis1*.1) ]
             set l1 [ lindex $abscisses $x1 ]
             set x2 [ expr int($naxis1*.2) ]
             set l2 [ lindex $abscisses $x2 ]
             set delta1 [ expr ($l2-$l1)/($x2-$x1) ]
             set x1 [ expr int($naxis1*.6) ]
             set l1 [ lindex $abscisses $x1 ]
             set x2 [ expr int($naxis1*.7) ]
             set l2 [ lindex $abscisses $x2 ]
             set delta2 [ expr ($l2-$l1)/($x2-$x1) ]
             ::console::affiche_resultat "Dispersion depart=$dispe, Disp1=$delta1, Disp2=$delta2\n"
             if { [ expr abs($delta2-$delta1) ]<=[ expr 0.001*$dispe ] } {
                #-- Calibration lineaire :
                ::console::affiche_resultat "Calcul d'une loi de calibration linéaire :\n"
                set flagnl 0
                set results [ spc_ajustdeg1hp $abscisses_lin $abscisses 1 $crpix1 ]
                set coeffs [ lindex $results 0 ]
                set chi2 [ lindex $results 1 ]
                set spc_d 0.
                set spc_c 0.
                set spc_b [ lindex $coeffs 1 ]
                set spc_a [ lindex $coeffs 0 ]
                set rms [ expr $lambdadeb*sqrt($chi2/$naxis1) ]
             } else {
                #-- Calibration non lineaire :
                ::console::affiche_resultat "Calcul d'une loi de calibration non-linéaire :\n"
                set flagnl 1
                set results [ spc_ajustdeg3 $abscisses_lin $abscisses 1 $crpix1 ]
                set spc_a [ lindex [ lindex $results 0 ] 0 ]
                set spc_b [ lindex [ lindex $results 0 ] 1 ]
                set coeffs [ lindex $results 0 ]
                set chi2 [ lindex $results 1 ]
                set spc_d [ lindex $coeffs 3 ]
                set spc_c [ lindex $coeffs 2 ]
                set spc_b [ lindex $coeffs 1 ]
                set spc_a [ lindex $coeffs 0 ]
                set rms [ expr $lambdadeb*sqrt($chi2/$naxis1) ]
                if { $rms>=[ expr 0.25*$spc_b ] } {
                   #-- DEG2 meilleur souvent :
                   set results [ spc_ajustdeg2 $abscisses_lin $abscisses 1 $crpix1 ]
                   set coeffs [ lindex $results 0 ]
                   set chi2 [ lindex $results 1 ]
                   set spc_d 0.
                   set spc_c [ lindex $coeffs 2 ]
                   set spc_b [ lindex $coeffs 1 ]
                   set spc_a [ lindex $coeffs 0 ]
                   set rms [ expr $lambdadeb*sqrt($chi2/$naxis1) ]
                }
             }
             set lambdafin [ spc_calpoly $naxis1 $crpix1 $spc_a $spc_b $spc_c $spc_d ]
             set dispersion [ expr 1.0*($lambdafin-$lambdadeb)/($naxis1-1) ]
          }
       }


       #--- Affecte une valeur aux mots cle liés à la spectroscopie :
       ::console::affiche_resultat "Dispersion : $dispersion ; RMS=$rms\n"
       buf$audace(bufNo) setkwd [ list "DATE-OBS" "0000-00-00T00:00:00.00" string "Start of exposure. FITS standard" "Iso 8601"]
       buf$audace(bufNo) setkwd [ list "EXPOSURE" 0. float "Exposure duration" "second" ]
       if { $lambdadeb == 1.0 } {
          buf$audace(bufNo) setkwd [ list "CRVAL1" $lambdadeb double "" "pixel" ]
          buf$audace(bufNo) setkwd [ list "CDELT1" $dispersion double "" "pixel" ]
       } else {
          buf$audace(bufNo) setkwd [ list "CUNIT1" "angstrom" string "Wavelength unit" "" ]
          #-- Corrdonnée représentée sur l'axe 1 (ie X) :
          buf$audace(bufNo) setkwd [ list "CTYPE1" "Wavelength" string "" "" ]
          buf$audace(bufNo) setkwd [ list "CRVAL1" $lambdadeb double "Wavelength at reference pixel" "angstrom" ]
          buf$audace(bufNo) setkwd [ list "CDELT1" $dispersion double "Wavelength increment" "angstrom/pixel" ]
          buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms double "" "angstrom" ]
          if { $flagnl==1 } {
             #-- Mots clefs du polynôme :
             buf$audace(bufNo) setkwd [list "SPC_DESC" "A+B.x+C.x.x+D.x.x.x" string "" ""]
             buf$audace(bufNo) setkwd [list "SPC_A" $spc_a double "" "angstrom"]
             buf$audace(bufNo) setkwd [list "SPC_B" $spc_b double "" "angstrom/pixel"]
             buf$audace(bufNo) setkwd [list "SPC_C" $spc_c double "" "angstrom.angstrom/pixel.pixel"]
             buf$audace(bufNo) setkwd [list "SPC_D" $spc_d double "" "angstrom.angstrom.angstrom/pixel.pixel.pixel"]
          }
       }

       #--- Sauve le fichier fits ainsi constitué :
       set ldernier [ lindex $abscisses [expr $naxis1-1] ]
       ::console::affiche_resultat "Xdep : $lambdadeb ; Xfin : $ldernier\n"
       ::console::affiche_resultat "$naxis1 lignes affectées\n"
       buf$audace(bufNo) bitpix float
       if { [llength $args]==1 || [llength $args]==0 } {
          set nom [ file rootname $filenamespc ]
          buf$audace(bufNo) bitpix float
          buf$audace(bufNo) save "$audace(rep_images)/${nom}$conf(extension,defaut)"
          buf$audace(bufNo) bitpix short
          ::console::affiche_resultat "Fichier fits sauvé sous $audace(rep_images)/${nom}$conf(extension,defaut)\n"
          return ${nom}
       } elseif { [llength $args]==2 } {
          set nom [ file rootname $filenameout ]
          buf$audace(bufNo) bitpix float
          buf$audace(bufNo) save "$audace(rep_images)/${filenameout}$conf(extension,defaut)"
          buf$audace(bufNo) bitpix short
          ::console::affiche_resultat "Fichier fits sauvé sous $audace(rep_images)/${filenameout}$conf(extension,defaut)\n"
          return ${filenameout}
       }
       buf$audace(bufNo) bitpix short
    } else {
       ::console::affiche_erreur "Usage: spc_dat2fits fichier_profil.dat ?fichier_sortie.fit?\n\n"
    }
}
#****************************************************************#







####################################################################
#  Procedure de conversion de fichier profil de raie spatial .fit en .dat
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 16-05-2005/20-09-06
# Arguments : fichier .fit du profil de raie ?fichier_sortie.dat?\
####################################################################

proc spc_fits2dat { args } {

  global conf
  global audace spcaudace
  global audela caption
  #global profilspc
  # global caption
  # global colorspc

  set nbargs [ llength $args ]
  if { $nbargs<=2 } {
     if  { $nbargs==1 } {
        set filenamespc [ lindex $args 0 ]
     } elseif { $nbargs==2 } {
        set filenamespc [ lindex $args 0 ]
        set filenameout [ lindex $args 1 ]
     } elseif { $nbargs==0 } {
        set spctrouve [ file tail [ file rootname [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
        if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
           set filenamespc $spctrouve
        } else {
           ::console::affiche_erreur "Usage: spc_fits2dat fichier_profil.fit ?fichier_sortie.dat?\n\n"
           return ""
        }
     }

     buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
     set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
     set listemotsclef [ buf$audace(bufNo) getkwds ]

    #-- Traite crpix1 :
     if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
        set crpix1 [ lindex [buf$audace(bufNo) getkwd "CRPIX1" ] 1 ]
     } else {
        set crpix1 1
     }  
     
    #-- Calibration on lineaire :
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
        set flag_noncal 0
     } else {
        set flag_noncal 1
     }  
     
    #-- Critere final mais mis en 2ieme, gere la calibration lineaire si elle esl la seule :
    if { $flag_noncal==1 } {
       if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
          set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
          if { $lambda0==1. } {
             set flag_noncal 1
          } else {
             set flag_noncal 0
          }
       }  
       if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
          set dispersion [ lindex [buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
          if { $dispersion != 0 } {
             set flag_noncal 0
          } else { set flag_noncal 1 }
       } else {
          set flag_noncal 1
       }  
    }  



     #--- Type de spectre : LINEAR ou NONLINEAR (elinine les espaces dans la valeur du mot clef.
     #set len [ expr int($naxis1/$dispersion) ]
     #::console::affiche_resultat "$naxis1 intensités à traiter\n"

     if { $nbargs==1 || $nbargs==0 } {
        set fileetalonnespc [ file rootname $filenamespc ]
        set fileout ${fileetalonnespc}$spcaudace(extdat)
        set file_id [open "$audace(rep_images)/$fileout" w+]
     } elseif { $nbargs==2 } {
        set fileout $filenameout
        set file_id [open "$audace(rep_images)/$fileout" w+]
     }

     #--- configure le fichier de sortie avec les fin de ligne "xODx0A"
     #-- independamment du systeme LINUX ou WINDOWS
     fconfigure $file_id -translation crlf

     if { [regexp {1.3.0} $audela(version) match resu ] } {
        #--- Lecture pixels Audela 130 :
        if { $flag_noncal==0 } {
           if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
              #-- Calibration non-linéaire :
              if { $spc_a < 0.01 } {
                 for {set k 1} {$k<=$naxis1} {incr k} {
                    #- Ancienne formulation < 070104 :
                    set lambda [ expr $spc_a*$k*$k+$spc_b*$k+$spc_c ]
                    set intensite [ buf$audace(bufNo) getpix [list $k 1] ]
                    puts $file_id "$lambda\t$intensite"
                 }
              } else {
                 for {set k 1} {$k<=$naxis1} {incr k} {
                    set lambda [ expr $spc_d*$k*$k*$k+$spc_c*$k*$k+$spc_b*$k+$spc_a ]
                    set intensite [ buf$audace(bufNo) getpix [list $k 1] ]
                    puts $file_id "$lambda\t$intensite"
                 }
              }
           } else {
              #-- Calibration linéaire :
              #-- Une liste commence à 0 ; Un vecteur fits commence à 1
              for {set k 1} {$k<=$naxis1} {incr k} {
                 #-- Donne les bonnes valeurs aux abscisses si le spectre est étalonné en longueur d'onde
                 set lambda [ expr $lambda0+($k-1)*$dispersion*1.0 ]
                 #-- Lit la valeur des elements du fichier fit
                 set intensite [ buf$audace(bufNo) getpix [list $k 1] ]
                 ##lappend profilspc(intensite) $intensite
                 #-- Ecrit les couples "Lambda Intensite" dans le fichier de sortie
                 puts $file_id "$lambda\t$intensite"
              }
           }
        } else {
           #-- Profil non calibré :
           for {set k 1} {$k<=$naxis1} {incr k} {
              set pixel $k
              set intensite [ buf$audace(bufNo) getpix [list $k 1] ]
              puts $file_id "$pixel\t$intensite"
           }
        }
     } else {
        #--- Lecture pixels Audela 140 :
        if { $flag_noncal==1 } {
           #-- Profil non calibré :
           for {set k 1} {$k<=$naxis1} {incr k} {
              set pixel $k
              set intensite [ lindex [ buf$audace(bufNo) getpix [list $k 1] ] 1 ]
              puts $file_id "$pixel\t$intensite"
           }
        } else {
           if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
              #-- Calibration non-linéaire :
              if { $spc_a < 0.01 && $spc_a > 0.0 } {
                 for {set k 1} {$k<=$naxis1} {incr k} {
                    #- Ancienne formulation < 070104 :
                    set lambda [ spc_calpoly $k $crpix1 $spc_c $spc_b $spc_a 0 ]
                    set intensite [ lindex [ buf$audace(bufNo) getpix [list $k 1] ] 1 ]
                    puts $file_id "$lambda\t$intensite"
                 }
              } else {
                 for {set k 1} {$k<=$naxis1} {incr k} {
                    set lambda [ spc_calpoly $k $crpix1 $spc_a $spc_b $spc_c $spc_d $spc_e ]
                    set intensite [ lindex [ buf$audace(bufNo) getpix [list $k 1] ] 1 ]
                    #puts $file_id "$lambda\t$intensite\r"
                    puts $file_id "$lambda\t$intensite"
                 }
              }
           } else {
              #-- Calibration linéaire :
              #-- Une liste commence à 0 ; Un vecteur fits commence à 1
              for {set k 1} {$k<=$naxis1} {incr k} {
                 #-- Donne les bonnes valeurs aux abscisses si le spectre est étalonné en longueur d'onde (attention : lambda0=crval!=a+b) :
                 set lambda [ spc_calpoly $k $crpix1 $lambda0 $dispersion 0 0 ]
                 #-- Lit la valeur des elements du fichier fit
                 set intensite [ lindex [ buf$audace(bufNo) getpix [list $k 1] ] 1 ]
                 #-- Ecrit les couples "Lambda Intensite" dans le fichier de sortie
                 puts $file_id "$lambda\t$intensite"
              }
           }
        }
     }

     if { $nbargs<=2 } {
        close $file_id
     }
     ::console::affiche_resultat "Fichier fits exporté sous $audace(rep_images)/$fileout\n"
     #--- Renvoie le nom du fichier avec l'extension $extsp :
     return $fileout
  } else {
     ::console::affiche_erreur "Usage: spc_fits2dat fichier_profil_fit ?fichier_sortie.dat?\n\n"
  }
}
#****************************************************************#



####################################################################
#  Procedure de conversion de fichier profil de raies .fit en .dat avec une echelle en vitesse radiale
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 24-09-2011
# Date modification : 24-09-2011
# Inspire de spc_fits2dat
# Arguments : fichier .fit du profil de raie lon,gueur de dreference\
####################################################################

proc spc_fits2datvel { args } {

  global conf
  global audace spcaudace
  global audela caption

  set nbargs [ llength $args ]
  if { $nbargs==2 } {
     set filenamespc [ lindex $args 0 ]
     set lambda_ref [ lindex $args 1 ]
  } else {
     ::console::affiche_erreur "Usage: spc_fits2dat fichier_profil.fit ?fichier_sortie.dat?\n\n"
     return ""
  }

  buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
  set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
  set listemotsclef [ buf$audace(bufNo) getkwds ]

  if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
     set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
     if { $lambda0==1. } {
        set flag_noncal 1
     } else {
        set flag_noncal 0
     }
  }  
  if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
     set dispersion [ lindex [buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
     if { $dispersion != 0 } {
        set flag_noncal 0
     } else { set flag_noncal 1 }
  } else {
     set flag_noncal 1
  }

  if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
     set crpix1 [ lindex [buf$audace(bufNo) getkwd "CRPIX1" ] 1 ]
  } else {
     set crpix1 1
  }
  if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
     ::console::affiche_erreur "Le profils de raies doit être calibré linérairement en longueur d'onde"
     return ""
  }

  if { $flag_noncal==1 } {
     ::console::affiche_erreur "Le profils de raies doit être calibré linérairement en longueur d'onde"
     return ""
  }

  #--- Type de spectre : LINEAR ou NONLINEAR (elinine les espaces dans la valeur du mot clef.
  set fileetalonnespc [ file rootname $filenamespc ]
  set fileout ${fileetalonnespc}$spcaudace(extdat)
  set file_id [open "$audace(rep_images)/$fileout" w+]

  #--- configure le fichier de sortie avec les fin de ligne "xODx0A"
  #-- independamment du systeme LINUX ou WINDOWS
  fconfigure $file_id -translation crlf
  #--- Lecture pixels Audela 140 :
  #-- Calibration linéaire :
  #-- Une liste commence à 0 ; Un vecteur fits commence à 1
  for {set k 1} {$k<=$naxis1} {incr k} {
     #-- Donne les bonnes valeurs aux abscisses si le spectre est étalonné en longueur d'onde (attention : lambda0=crval!=a+b) :
     set lambda [ spc_calpoly $k $crpix1 $lambda0 $dispersion 0 0 ]
     set vitesse [ expr ($lambda-$lambda_ref)*$spcaudace(vlum)/$lambda_ref ]
     #-- Lit la valeur des elements du fichier fit
     set intensite [ lindex [ buf$audace(bufNo) getpix [list $k 1] ] 1 ]
     #-- Ecrit les couples "Lambda Intensite" dans le fichier de sortie
     puts $file_id "$vitesse\t$intensite"
  }


  close $file_id
  ::console::affiche_resultat "Fichier fits exporté sous $audace(rep_images)/$fileout\n"
  #--- Renvoie le nom du fichier avec l'extension $extsp :
  return $fileout
}
#****************************************************************#





####################################################################
# Procedure de création d'un fichier profil de raie fits à partir des données x et y
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 15-12-2005
# Arguments : nom fichier fit de sortie, une liste de coordonnées x puis y, unité des données
####################################################################

proc spc_data2fits { args } {
   global audace
   global conf
   set precision 0.0001

   if { [llength $args] <= 3 } {
      if { [llength $args] == 3 } {
         #set nom_fichier [ file rootname [lindex 0] ]
         set nom_fichier [lindex $args 0]
         set coordonnees [lindex $args 1]
         set nbunit [lindex $args 2]
      } elseif { [llength $args] == 2 } {
         set nom_fichier [lindex $args 0]
         set coordonnees [lindex $args 1]
         set nbunit "float"
      } else {
         ::console::affiche_erreur "Usage: spc_data2fits nom_fichier_fits_sortie liste_coordonnées_x_et_y unitée_intensités (short/float/double)\n\n"
         return ""
      }

      #--- Initialise les informations :
      set abscisses [lindex $coordonnees 0]
      set intensites [lindex $coordonnees 1]
      set naxis1 [llength $abscisses]
      set crpix1 1
      set lambdadeb [ lindex $abscisses 0 ]

      #--- Cree la liste de numeros de pixel :
      set abscisses_lin [ list ]
      for { set i 1 } { $i<=$naxis1 } { incr i } {
         lappend abscisses_lin $i
      }

      #---- Calcul du polynôme de la loi de dispersion :
      if { $lambdadeb == 1.0 } {
         set dispersion 1.
      } else {
         #--- Determine si la calibration est lineaire ou non :
         if { $naxis1>=10 } {
             set l1 [ lindex $abscisses 2 ]
             set l2 [ lindex $abscisses 3 ]
             set dispe [ expr $l2-$l1 ]
             set x1 [ expr int($naxis1*.1) ]
             set l1 [ lindex $abscisses $x1 ]
             set x2 [ expr int($naxis1*.2) ]
             set l2 [ lindex $abscisses $x2 ]
             set delta1 [ expr ($l2-$l1)/($x2-$x1) ]
             set x1 [ expr int($naxis1*.6) ]
             set l1 [ lindex $abscisses $x1 ]
             set x2 [ expr int($naxis1*.7) ]
             set l2 [ lindex $abscisses $x2 ]
             set delta2 [ expr ($l2-$l1)/($x2-$x1) ]
             ::console::affiche_resultat "Dispersion depart=$dispe, Disp1=$delta1, Disp2=$delta2\n"
             if { [ expr abs($delta2-$delta1) ]<=[ expr 0.001*$dispe ] } {
                #-- Calibration lineaire :
                ::console::affiche_resultat "Calcul d'une loi de calibration linéaire :\n"
                set flagnl 0
                set results [ spc_ajustdeg1hp $abscisses_lin $abscisses 1 $crpix1 ]
                set coeffs [ lindex $results 0 ]
                set chi2 [ lindex $results 1 ]
                set spc_d 0.
                set spc_c 0.
                set spc_b [ lindex $coeffs 1 ]
                set spc_a [ lindex $coeffs 0 ]
                set rms [ expr $lambdadeb*sqrt($chi2/$naxis1) ]
             } else {
                #-- Calibration non lineaire :
                ::console::affiche_resultat "Calcul d'une loi de calibration non-linéaire :\n"
                set flagnl 1
                set results [ spc_ajustdeg3 $abscisses_lin $abscisses 1 $crpix1 ]
                set spc_a [ lindex [ lindex $results 0 ] 0 ]
                set spc_b [ lindex [ lindex $results 0 ] 1 ]
                set coeffs [ lindex $results 0 ]
                set chi2 [ lindex $results 1 ]
                set spc_d [ lindex $coeffs 3 ]
                set spc_c [ lindex $coeffs 2 ]
                set spc_b [ lindex $coeffs 1 ]
                set spc_a [ lindex $coeffs 0 ]
                set rms [ expr $lambdadeb*sqrt($chi2/$naxis1) ]
                if { $rms>=[ expr 0.25*$spc_b ] } {
                   #-- DEG2 meilleur souvent :
                   set results [ spc_ajustdeg2 $abscisses_lin $abscisses 1 $crpix1 ]
                   set coeffs [ lindex $results 0 ]
                   set chi2 [ lindex $results 1 ]
                   set spc_d 0.
                   set spc_c [ lindex $coeffs 2 ]
                   set spc_b [ lindex $coeffs 1 ]
                   set spc_a [ lindex $coeffs 0 ]
                   set rms [ expr $lambdadeb*sqrt($chi2/$naxis1) ]
                }
             }
             set lambdafin [ spc_calpoly $naxis1 $crpix1 $spc_a $spc_b $spc_c $spc_d ]
             set dispersion [ expr 1.0*($lambdafin-$lambdadeb)/($naxis1-1) ]
         }
         ::console::affiche_resultat "Dispersion : $dispersion ; RMS=$rms\n"
      }


      #--- Affecte une valeur aux mots cle liés à la spectroscopie :
      buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 1 FORMAT_FLOAT COMPRESS_NONE 0
      #-- Ecrit les intensites :
      set intensite 0
      for {set k 0} {$k<$naxis1} {incr k} {
         append intensite [lindex $intensites $k]
         if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {
            buf$audace(bufNo) setpix [list [expr $k+1] 1] $mintensite
            set intensite 0
         }
      }
      #-- Ecrit les mots clef :
      buf$audace(bufNo) setkwd [ list "NAXIS" 1 int "" "" ]
      buf$audace(bufNo) setkwd [ list "NAXIS1" $naxis1 int "" "" ]
      buf$audace(bufNo) setkwd [ list "DATE-OBS" "0000-00-00T00:00:00.00" string "Start of exposure. FITS standard" "Iso 8601"]
      buf$audace(bufNo) setkwd [ list "EXPOSURE" 0. float "Exposure duration" "second" ]
      buf$audace(bufNo) setkwd [ list "CRPIX1" $crpix1 double "Reference pixel" "pixel" ]
      if { $lambdadeb == 1.0 } {
         buf$audace(bufNo) setkwd [ list "CRVAL1" $lambdadeb double "" "pixel" ]
         buf$audace(bufNo) setkwd [ list "CDELT1" $dispersion double "" "pixel" ]
      } else {
         buf$audace(bufNo) setkwd [ list "CUNIT1" "angstrom" string "Wavelength unit" "" ]
         #-- Corrdonnée représentée sur l'axe 1 (ie X) :
         buf$audace(bufNo) setkwd [ list "CTYPE1" "Wavelength" string "" "" ]
         buf$audace(bufNo) setkwd [ list "CRVAL1" $lambdadeb double "Wavelength at reference pixel" "angstrom" ]
         buf$audace(bufNo) setkwd [ list "CDELT1" $dispersion double "Wavelength increment" "angstrom/pixel" ]
         buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms double "RMS" "angstrom" ]
         if { $flagnl==1 } {
            #-- Mots clefs du polynôme :
            buf$audace(bufNo) setkwd [list "SPC_DESC" "A+B.x+C.x.x+D.x.x.x" string "" ""]
            buf$audace(bufNo) setkwd [list "SPC_A" $spc_a double "" "angstrom"]
            buf$audace(bufNo) setkwd [list "SPC_B" $spc_b double "" "angstrom/pixel"]
            buf$audace(bufNo) setkwd [list "SPC_C" $spc_c double "" "angstrom.angstrom/pixel.pixel"]
            buf$audace(bufNo) setkwd [list "SPC_D" $spc_d double "" "angstrom.angstrom.angstrom/pixel.pixel.pixel"]
         }
      }


      #--- Sauvegarde du fichier fits ainsi créé
      if { $nbunit == "double" || $nbunit == "float" } {
         buf$audace(bufNo) bitpix float
      } elseif { $nbunit == "short" } {
         buf$audace(bufNo) bitpix short
      }
      buf$audace(bufNo) save "$audace(rep_images)/$nom_fichier$conf(extension,defaut)"
      buf$audace(bufNo) bitpix short
      return $nom_fichier
   } else {
      ::console::affiche_erreur "Usage: spc_data2fits nom_fichier_fits_sortie liste_coordonnées_x_et_y unitées_intensités (double/float/short)\n\n"
   }
}
#**********************************************************************#




####################################################################
#  Procedure de conversion de fichier profil de raie fits en une liste contenant les listes valeurs X et Y.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20-12-2005
# Date modification : 20-12-2005/20-09-06
# Arguments : fichier .fit du profil de raie
####################################################################

proc spc_fits2data { args } {

 global conf
 global audace audela

 if {[llength $args] == 1} {
     set filenamespc [ lindex $args 0 ]

     if { [llength [file split $filenamespc]] == 1 } {
        #--- j'ajoute le repertoire par defaut devant le nom du fichier
        set filenamespc [file join $audace(rep_images) $filenamespc]
     }
     buf$audace(bufNo) load $filenamespc
     set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
     set listemotsclef [ buf$audace(bufNo) getkwds ]


    #--- Detecte si un profil est calibre ou non et recupere les mots clef de calibration :
    #-- Traite crpix1 :
     if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
        set crpix1 [ lindex [buf$audace(bufNo) getkwd "CRPIX1" ] 1 ]
     } else {
        set crpix1 1
     }

    #-- Calibration on lineaire :
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
        set flag_noncal 0
     } else {
        set flag_noncal 1
     }

    #-- Critere final mais mis en 2ieme, gere la calibration lineaire si elle esl la seule :
    if { $flag_noncal==1 } {
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
    }


     #--- Valeur minimale de l'abscisse : =0 si profil non étalonné
     #::console::affiche_resultat "spc_fits2data: $naxis1 intensités à traiter...\n"

     #---- Pour Audela
     if { [regexp {1.3.0} $audela(version) match resu ] } {
         #--- Spectre calibré en lambda
         if { $flag_noncal==0 } {
             #-- Calibration non-linéaire :
             if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
                 if { $spc_a < 0.01 } {
                     for {set k 1} {$k<=$naxis1} {incr k} {
                         #- Ancienne formulation < 070104 :
                         #- Une liste commence à 0 ; Un vecteur fits commence à 1
                         lappend abscisses [ expr $spc_a*$k*$k+$spc_b*$k+$spc_c ]
                         lappend intensites [ buf$audace(bufNo) getpix [list $k 1] ]
                     }
                 } else {
                     for {set k 1} {$k<=$naxis1} {incr k} {
                         #- Une liste commence à 0 ; Un vecteur fits commence à 1
                         lappend abscisses [ expr $spc_d*$k*$k*$k+$spc_c*$k*$k+$spc_b*$k+$spc_a ]
                         lappend intensites [ buf$audace(bufNo) getpix [list $k 1] ]
                     }
                 }
                 #-- Calibration linéaire :
             } else {
                 for {set k 1} {$k<=$naxis1} {incr k} {
                     lappend abscisses [ expr $lambda0+($k-1)*$dispersion*1.0 ]
                     lappend intensites [ buf$audace(bufNo) getpix [list $k 1] ]
                 }
             }
         } else {
             #--- Spectre non calibré en lambda :
             for {set k 1} {$k<=$naxis1} {incr k} {
                 lappend abscisses [ expr $k+1 ]
                 lappend intensites [ buf$audace(bufNo) getpix [list $k 1] ]
             }
         }
     #---- Audela 140 :
     } else {
        #--- Spectre calibré en lambda
        if { $flag_noncal==0 } {
           #-- Calibration non-linéaire :
           if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
              if { $spc_a < 0.01 && $spc_a > 0.0 } {
                 ### modif michel
                 ### {set k 0} {$k<$naxis1}
                 for {set k 1} {$k<=$naxis1} {incr k} {
                    #- Ancienne formulation < 070104 :
                    #- Une liste commence à 0 ; Un vecteur fits commence à 1
                    #- LENT : lappend abscisses [ spc_calpoly $k $crpix1 $spc_c $spc_b $spc_a 0 ]
                    lappend abscisses [ expr $spc_c+$spc_b*($k-$crpix1)+$spc_a*pow($k-$crpix1,2) ]
                    lappend intensites [ lindex [ buf$audace(bufNo) getpix [list [ expr $k ] 1] ] 1 ]
                 }
              } else {
                 ### modif michel
                 ###  {set k 0} {$k<$naxis1}
                 for {set k 1} {$k<=$naxis1} {incr k} {
                    #- Une liste commence à 0 ; Un vecteur fits commence à 1
                    #- LENT : lappend abscisses [ spc_calpoly $k $crpix1 $spc_a $spc_b $spc_c $spc_d ]
                    lappend abscisses [ expr $spc_a+$spc_b*($k-$crpix1)+$spc_c*pow($k-$crpix1,2)+$spc_d*pow($k-$crpix1,3)+$spc_e*pow($k-$crpix1,4) ]
                    lappend intensites [ lindex [ buf$audace(bufNo) getpix [list [ expr $k ] 1] ] 1 ]
                 }
              }
              #-- Calibration linéaire :
           } else {
              for {set k 1} {$k<=$naxis1} {incr k} {
                 #- LENT : lappend abscisses [ spc_calpoly $k $crpix1 $lambda0 $dispersion 0 0 ]
                 lappend abscisses [ expr 1.0*($lambda0+$dispersion*($k-$crpix1)) ]
                 lappend intensites [ lindex [ buf$audace(bufNo) getpix [list $k 1] ] 1 ]
              }
           }
        } else {
           #--- Spectre non calibré en lambda :
           for {set k 1} {$k<=$naxis1} {incr k} {
              lappend abscisses $k
              lappend intensites [ lindex [ buf$audace(bufNo) getpix [list $k 1] ] 1 ]
           }
        }
     }
    set coordonnees [list $abscisses $intensites]
    return $coordonnees
 } else {
     ::console::affiche_erreur "Usage: spc_fits2data fichier_fits_profil.fit\n\n"
 }
}
#****************************************************************#


####################################################################
#  Procedure de conversion de fichier profil de raie fits en une liste contenant les listes valeurs X et Y.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 24-09-2006
# Date modification : 20-12-2005/24-09-06
# Arguments : fichier .fit du profil de raie
####################################################################

proc spc_fits2datadlin { args } {

 global conf
 global audace audela

 if {[llength $args] == 1} {
     set filenamespc [ lindex $args 0 ]

     buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
     set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
     set listemotsclef [ buf$audace(bufNo) getkwds ]
     if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
        set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
     } else {
        set lambda0 1
     }
     if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
         set dispersion [ lindex [buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
     }
     if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
         set crpix1 [ lindex [buf$audace(bufNo) getkwd "CRPIX1" ] 1 ]
     } else {
        set crpix1 1
     }
     #--- Valeur minimale de l'abscisse : =0 si profil non étalonné
     ::console::affiche_resultat "$naxis1 intensités à traiter...\n"

     #---- Audela 130 :
     if { [regexp {1.3.0} $audela(version) match resu ] } {
         #--- Spectre calibré en lambda de dispersion imposée linéaire :
         if { $lambda0 != 1 } {
             for {set k 1} {$k<=$naxis1} {incr k} {
                 lappend abscisses [ spc_calpoly $k $crpix1 $lambda0 $dispersion 0 0 ]
                 lappend intensites [ buf$audace(bufNo) getpix [list $k 1] ]
             }
         } else {
             #--- Spectre non calibré en lambda :
             for {set k 1} {$k<=$naxis1} {incr k} {
                 lappend abscisses $k
                 lappend intensites [ buf$audace(bufNo) getpix [list $k 1] ]
             }
         }
     #---- Audela 140 :
     } else {
         #--- Spectre calibré en lambda de dispersion imposée linéaire :
         if { $lambda0 != 1 } {
             for {set k 1} {$k<=$naxis1} {incr k} {
                 lappend abscisses [ spc_calpoly $k $crpix1 $lambda0 $dispersion 0 0 ]
                 lappend intensites [ lindex [ buf$audace(bufNo) getpix [list $k 1] ] 1 ]
             }
         } else {
             #--- Spectre non calibré en lambda :
             for {set k 1} {$k<=$naxis1} {incr k} {
                 lappend abscisses $k
                 lappend intensites [ lindex [ buf$audace(bufNo) getpix [list $k 1] ] 1 ]
             }
         }
     }
     set coordonnees [list $abscisses $intensites]
     return $coordonnees
 } else {
     ::console::affiche_erreur "Usage: spc_fits2datadlin fichier_fits_profil.fit\n\n"
 }
}
#****************************************************************#



####################################################################
#  Procedure de conversion de fichier profil de raie .fit en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 14-08-2005
# Date modification : 26-04-2006
# Arguments : fichier .fit du profil de raie, légende axe X, légende axe Y, pas
####################################################################

proc spc_fit2pngman { args } {
    global audace spcaudace
    global conf tcl_platform

    if { [llength $args] == 5 } {
        set fichier [ lindex $args 0 ]
        set titre [ lindex $args 1 ]
        set legendex [ lindex $args 2 ]
        set legendey [ lindex $args 3 ]
        set pas [ lindex $args 4 ]

        spc_fits2dat $fichier
        # Retire l'extension .fit du nom du fichier
        set spcfile [ file rootname $fichier ]

        #--- Prepare le script pour gnuplot
        set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
        puts $file_id "call \"$spcaudace(repgp)/gp_spc.cfg\" \"${spcfile}$spcaudace(extdat)\" \"$titre\" * * * * $pas \"${spcfile}.png\" \"$legendex\" \"$legendey\" "
        close $file_id

        #--- Execute Gnuplot pour l'export en png
        if { $tcl_platform(platform)=="unix" } {
            set answer [ catch { exec gnuplot $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "Reponse Gnuplot (0=OK) : $answer\n"
        } else {
            set answer [ catch { exec ${repertoire_gp}/gpwin32/pgnuplot.exe $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "Reponse Gnuplot (0=OK) : $answer\n"
        }
        ::console::affiche_resultat "Profil de raie exporté sous ${spcfile}.png\n"
        return "${spcfile}.png"
   } else {
       ::console::affiche_erreur "Usage: spc_fit2pngman fichier_fits \"titre\" \"légende_axeX\" \"légende_axeY\" intervalle_graduations_verticales\n\n"
   }
}
####################################################################



####################################################################
#  Procedure de conversion de fichier profil de raie calibré .fit en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 14-08-2005
# Date modification : 26-04-2006
# Arguments : fichier .fit du profil de raie, titre, ?xdeb, xfin?
####################################################################

proc spc_fit2png { args } {
    global audace spcaudace
    global conf
    global tcl_platform

    #-- 3%=0.03
    set lpart 0

    if { [llength $args] == 4 || [llength $args] == 2 } {
        if { [llength $args] == 2 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            #set xdeb "*"
            #set xfin "*"
            buf$audace(bufNo) load "$audace(rep_images)/$fichier"
            set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
            #-- Demarre et fini le graphe en deçca de 3% des limites pour l'esthetique
            set largeur [ expr $lpart*$naxis1 ]
            set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
            set xdeb [ expr $xdeb0+$largeur ]
            set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
            set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
        } elseif { [llength $args] == 4 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            set xdeb [ lindex $args 2 ]
            set xfin [ lindex $args 3 ]
            buf$audace(bufNo) load "$audace(rep_images)/$fichier"
            set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
        } else {
            ::console::affiche_erreur "Usage: spc_fit2png fichier_fits \"Titre\" ?xdébut xfin?\n\n"
            return 0
        }


        #--- Adapte la légende de l'abscisse
        if { $xdeb0 == 1.0 } {
            set legendex "Position (Pixel)"
        } else {
            set legendex "Wavelength (Å)"
        }

        set legendey "Relative flux"

        spc_fits2dat $fichier
        #-- Retire l'extension .fit du nom du fichier
        set spcfile [ file rootname $fichier ]

        #--- Créée le fichier script pour gnuplot :
        ## exec echo "call \"$spcaudace(repgp)/gpx11.cfg\" \"${spcfile}$ext\" \"$titre\" * * $xdeb $xfin $pas \"${spcfile}.png\" \"$legendex\" \"$legendey\" " > $repertoire_gp/run_gp
        # exec echo "call \"$spcaudace(repgp)/gp_novisu.cfg\" \"${spcfile}$ext\" \"$titre\" * * $xdeb $xfin * \"${spcfile}.png\" \"$legendex\" \"$legendey\" " > $repertoire_gp/run_gp
        set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
        puts $file_id "call \"$spcaudace(repgp)/gp_novisu.cfg\" \"$audace(rep_images)/${spcfile}$spcaudace(extdat)\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/${spcfile}.png\" \"$legendex\" \"$legendey\" "
        close $file_id

        #--- Détermine le chemin de l'executable Gnuplot selon le système d'exploitation :
        #exec gnuplot "$audace(rep_images)/${spcfile}.gp"
        # exec gnuplot $repertoire_gp/run_gp
        # exec rm -f $repertoire_gp/run_pg
        if { $tcl_platform(platform)=="unix" } {
            # set gnuplotex "/usr/bin/gnuplot"
            # catch { exec $gnuplotex "$audace(rep_images)/${spcfile}.gp" }
            set answer [ catch { exec gnuplot $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "gnuplot résultat : $answer\n"
        } else {
            # set gnuplotex "C:\Programms Files\gnuplot\gnuplot.exe"
            # exec $gnuplotex "$audace(rep_images)/${spcfile}.gp"
            # exec gnuplot "$audace(rep_images)/${spcfile}.gp"
            #-- wgnuplot et pgnuplot doivent etre dans le rep gp de spcaudace
            set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "gnuplot résultat : $answer\n"
        }

        #--- Effacement des fichiers de batch :
        after 1000 ; #-- Evite l'erreur "permission denied" lors de l'effacement
        file delete -force "$audace(rep_images)/${spcfile}$spcaudace(extdat)"
        file delete -force "$audace(rep_images)/${spcfile}.gp"
        ::console::affiche_resultat "Profil de raie exporté sous ${spcfile}.png\n"
        return "${spcfile}.png"
    } else {
        ::console::affiche_erreur "Usage: spc_fit2png fichier_fits \"Titre\" ?xdébut xfin?\n\n"
    }
}
####################################################################



####################################################################
#  Procedure de conversion d'une série de fichiers profil de raie calibré .fit en .png evec précision de la légende
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-01-2007
# Date modification : 16-02-2007
# Arguments : fichier .fit du profil de raie, titre, ?legende_x legende_y?
####################################################################

proc spc_fit2pngopt { args } {
    global audace spcaudace
    global conf
    global tcl_platform
    set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
    #-- 3%=0.03
    set lpart 0

    if { [llength $args] == 8 || [llength $args] == 6 || [llength $args] == 4 || [llength $args] == 2 } {
        if { [llength $args] == 2 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]

            #-- Détermine les bornes du graphique :
            buf$audace(bufNo) load "$audace(rep_images)/$fichier"
            set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
            #-- Demarre et fini le graphe en deçca de "lpart" % des limites pour l'esthetique
            set largeur [ expr $lpart*$naxis1 ]
            set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
            set xdeb [ expr $xdeb0+$largeur ]
            set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
            set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
            set ydeb "*"
            set yfin "*"
            #-- Adapte la légende de l'abscisse
            if { $xdeb0 == 1.0 && $legendex=="" } {
                set legendex "Position (Pixel)"
            } else {
                set legendex "Wavelength (Å)"
            }
            set legendey "Relative flux"
        } elseif { [llength $args] == 4 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            set legendex [ lindex $args 2 ]
            set legendey [ lindex $args 3 ]

            #-- Détermine les bornes du graphique :
            buf$audace(bufNo) load "$audace(rep_images)/$fichier"
            set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
            #-- Demarre et fini le graphe en deçca de "lpart" % des limites pour l'esthetique
            set largeur [ expr $lpart*$naxis1 ]
            set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
            set xdeb [ expr $xdeb0+$largeur ]
            set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
            set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
            set ydeb "*"
            set yfin "*"
        } elseif { [llength $args] == 6 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            set legendex [ lindex $args 2 ]
            set legendey [ lindex $args 3 ]
            set xdeb [ lindex $args 4 ]
            set xfin [ lindex $args 5 ]
        } elseif { [llength $args] == 8 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            set legendex [ lindex $args 2 ]
            set legendey [ lindex $args 3 ]
            set xdeb [ lindex $args 4 ]
            set xfin [ lindex $args 5 ]
            set ydeb [ lindex $args 6 ]
            set yfin [ lindex $args 7 ]
        } else {
            ::console::affiche_erreur "Usage: spc_fit2pngopt fichier_fits \"Titre\" ?legende_x lende_y? ?xdeb xfin? ?ydeb yfin?\n\n"
            return 0
        }

        #-- spc_fits2dat renvoie un nom avec une extension : fichier.dat
        set fileout [ spc_fits2dat $fichier ]
        #-- Retire l'extension .fit du nom du fichier
        set spcfile [ file rootname $fichier ]

        #--- Créée le fichier script pour gnuplot :
        set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
        puts $file_id "call \"$spcaudace(repgp)/gp_novisu.cfg\" \"$audace(rep_images)/${spcfile}$spcaudace(extdat)\" \"$titre\" $ydeb $yfin $xdeb $xfin * \"$audace(rep_images)/${spcfile}.png\" \"$legendex\" \"$legendey\" "
        close $file_id

        #--- Détermine le chemin de l'executable Gnuplot selon le système d'exploitation :
        if { $tcl_platform(platform)=="unix" } {
            set answer [ catch { exec gnuplot $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "gnuplot résultat (0=OK) : $answer\n"
        } else {
            set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "gnuplot résultat (0=OK) : $answer\n"
        }

        #--- Effacement des fichiers de batch :
        after 1000 ; #-- Evite l'erreur "permission denied" lors de l'effacement
        file delete -force "$audace(rep_images)/${spcfile}$spcaudace(extdat)"
        file delete -force "$audace(rep_images)/${spcfile}.gp"

        #--- Fin du script :
        ::console::affiche_resultat "Profil de raie exporté sous ${spcfile}.png\n"
        return "${spcfile}.png"
    } else {
        ::console::affiche_erreur "Usage: spc_fit2pngopt fichier_fits \"Titre\" ?legende_x lende_y? ?xdeb xfin? ?ydeb yfin?\n\n"
    }
}
####################################################################



####################################################################
#  Procedure de conversion d'une série de fichiers profil de raie calibré .fit en .jpg evec précision de la légende
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-01-2007
# Date modification : 16-02-2007
# Arguments : fichier .fit du profil de raie, titre, ?legende_x legende_y?
####################################################################

proc spc_fit2tnjpg { args } {
    global audace spcaudace
    global conf
    global tcl_platform
    set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
    #-- 3%=0.03
    set lpart 0

    if { [llength $args] == 8 || [llength $args] == 6 || [llength $args] == 4 || [llength $args] == 2 } {
        if { [llength $args] == 2 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]

            #-- Détermine les bornes du graphique :
            buf$audace(bufNo) load "$audace(rep_images)/$fichier"
            set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
            #-- Demarre et fini le graphe en deçca de "lpart" % des limites pour l'esthetique
            set largeur [ expr $lpart*$naxis1 ]
            set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
            set xdeb [ expr $xdeb0+$largeur ]
            set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
            set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
            set ydeb "*"
            set yfin "*"
            #-- Adapte la légende de l'abscisse
            if { $xdeb0 == 1.0 && $legendex=="" } {
                set legendex "Position (Pixel)"
            } else {
                set legendex "Wavelength (Å)"
            }
            set legendey "Relative flux"
        } elseif { [llength $args] == 4 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            set legendex [ lindex $args 2 ]
            set legendey [ lindex $args 3 ]

            #-- Détermine les bornes du graphique :
            buf$audace(bufNo) load "$audace(rep_images)/$fichier"
            set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
            #-- Demarre et fini le graphe en deçca de "lpart" % des limites pour l'esthetique
            set largeur [ expr $lpart*$naxis1 ]
            set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
            set xdeb [ expr $xdeb0+$largeur ]
            set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
            set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
            set ydeb "*"
            set yfin "*"
        } elseif { [llength $args] == 6 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            set legendex [ lindex $args 2 ]
            set legendey [ lindex $args 3 ]
            set xdeb [ lindex $args 4 ]
            set xfin [ lindex $args 5 ]
        } elseif { [llength $args] == 8 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            set legendex [ lindex $args 2 ]
            set legendey [ lindex $args 3 ]
            set xdeb [ lindex $args 4 ]
            set xfin [ lindex $args 5 ]
            set ydeb [ lindex $args 6 ]
            set yfin [ lindex $args 7 ]
        } else {
            ::console::affiche_erreur "Usage: spc_fit2tnjpg fichier_fits \"Titre\" ?legende_x lende_y? ?xdeb xfin? ?ydeb yfin?\n\n"
            return 0
        }

        #-- spc_fits2dat renvoie un nom avec une extension : fichier.dat
        set fileout [ spc_fits2dat $fichier ]
        #-- Retire l'extension .fit du nom du fichier
        set spcfile [ file rootname $fichier ]

        #--- Créée le fichier script pour gnuplot :
        set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
        puts $file_id "call \"$spcaudace(repgp)/gp_tnjpg.cfg\" \"$audace(rep_images)/${spcfile}$spcaudace(extdat)\" \"$titre\" $ydeb $yfin $xdeb $xfin * \"$audace(rep_images)/${spcfile}.jpg\" \"$legendex\" \"$legendey\" "
        close $file_id

        #--- Détermine le chemin de l'executable Gnuplot selon le système d'exploitation :
        if { $tcl_platform(platform)=="unix" } {
            set answer [ catch { exec gnuplot $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "gnuplot résultat (0=OK) : $answer\n"
        } else {
            set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "gnuplot résultat (0=OK) : $answer\n"
        }

        #--- Effacement des fichiers de batch :
        after 1000 ; #-- Evite l'erreur "permission denied" lors de l'effacement
        file delete -force "$audace(rep_images)/${spcfile}$spcaudace(extdat)"
        file delete -force "$audace(rep_images)/${spcfile}.gp"

        #--- Fin du script :
        ::console::affiche_resultat "Profil de raie exporté sous ${spcfile}.jpg\n"
        return "${spcfile}.jpg"
    } else {
        ::console::affiche_erreur "Usage: spc_fit2tnjpg fichier_fits \"Titre\" ?legende_x lende_y? ?xdeb xfin? ?ydeb yfin?\n\n"
    }
}
####################################################################



####################################################################
#  Procedure de conversion d'une série de fichiers profil de raie calibré .fit en .png evec précision de la légende
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-01-2007
# Date modification : 16-02-2007
# Arguments : fichier .fit du profil de raie, titre, ?legende_x legende_y?
####################################################################

proc spc_fit2pnglarge { args } {
    global audace spcaudace
    global conf
    global tcl_platform
    set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
    #-- 3%=0.03
    set lpart 0

    if { [llength $args] == 8 || [llength $args] == 6 || [llength $args] == 4 || [llength $args] == 2 } {
        if { [llength $args] == 2 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            #-- Détermine les bornes du graphique :
            buf$audace(bufNo) load "$audace(rep_images)/$fichier"
            set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
            #-- Demarre et fini le graphe en deçca de "lpart" % des limites pour l'esthetique
            set largeur [ expr $lpart*$naxis1 ]
            set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
            set xdeb [ expr $xdeb0+$largeur ]
            set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
            set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
            set ydeb "*"
            set yfin "*"
            #-- Adapte la légende de l'abscisse
            if { $xdeb0 == 1.0 && $legendex=="" } {
                set legendex "Position (Pixel)"
            } else {
                set legendex "Wavelength (Å)"
            }
            set legendey "Relative flux"
        } elseif { [llength $args] == 4 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            set legendex [ lindex $args 2 ]
            set legendey [ lindex $args 3 ]

            #-- Détermine les bornes du graphique :
            buf$audace(bufNo) load "$audace(rep_images)/$fichier"
            set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
            #-- Demarre et fini le graphe en deçca de "lpart" % des limites pour l'esthetique
            set largeur [ expr $lpart*$naxis1 ]
            set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
            set xdeb [ expr $xdeb0+$largeur ]
            set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
            set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
            set ydeb "*"
            set yfin "*"
        } elseif { [llength $args] == 6 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            set legendex [ lindex $args 2 ]
            set legendey [ lindex $args 3 ]
            set xdeb [ lindex $args 4 ]
            set xfin [ lindex $args 5 ]
        } elseif { [llength $args] == 8 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            set legendex [ lindex $args 2 ]
            set legendey [ lindex $args 3 ]
            set xdeb [ lindex $args 4 ]
            set xfin [ lindex $args 5 ]
            set ydeb [ lindex $args 6 ]
            set yfin [ lindex $args 7 ]
        } else {
            ::console::affiche_erreur "Usage: spc_fit2pngopt fichier_fits \"Titre\" ?legende_x lende_y? ?xdeb xfin? ?ydeb yfin?\n\n"
            return 0
        }

        #-- spc_fits2dat renvoie un nom avec une extension : fichier.dat
        set fileout [ spc_fits2dat $fichier ]
        #-- Retire l'extension .fit du nom du fichier
        set spcfile [ file rootname $fichier ]

        #--- Créée le fichier script pour gnuplot :
        set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
        puts $file_id "call \"$spcaudace(repgp)/gp_novisularge.cfg\" \"$audace(rep_images)/${spcfile}$spcaudace(extdat)\" \"$titre\" $ydeb $yfin $xdeb $xfin * \"$audace(rep_images)/${spcfile}.png\" \"$legendex\" \"$legendey\" "
        close $file_id

        #--- Détermine le chemin de l'executable Gnuplot selon le système d'exploitation :
        if { $tcl_platform(platform)=="unix" } {
            set answer [ catch { exec gnuplot $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "gnuplot résultat : $answer\n"
        } else {
            set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "gnuplot résultat : $answer\n"
        }

       #--- Effacement des fichiers de batch :
       after 1000 ; #-- Evite l'erreur "permission denied" lors de l'effacement
       file delete -force "$audace(rep_images)/${spcfile}$spcaudace(extdat)"
       file delete -force "$audace(rep_images)/${spcfile}.gp"

       #--- Fin du script :
       ::console::affiche_resultat "Profil de raie exporté sous ${spcfile}.png\n"
       return "${spcfile}.png"
    } else {
        ::console::affiche_erreur "Usage: spc_fit2pnglarge fichier_fits \"Titre\" ?legende_x legende_y? ?xdeb xfin? ?ydeb yfin?\n\n"
    }
}
####################################################################


####################################################################
#  Procedure de conversion d'une série de fichiers profil de raie calibré .fit en .png evec précision de la légende
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-01-2007
# Date modification : 4-08-2013
# Arguments : fichier .fit du profil de raie, titre, ?legende_x legende_y?
####################################################################

proc spc_fit2pngvlarge { args } {
    global audace spcaudace
    global conf
    global tcl_platform
    set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
    #-- 3%=0.03
    set lpart 0

    if { [llength $args] == 8 || [llength $args] == 6 || [llength $args] == 4 || [llength $args] == 2 } {
        if { [llength $args] == 2 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            #-- Détermine les bornes du graphique :
            buf$audace(bufNo) load "$audace(rep_images)/$fichier"
            set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
            #-- Demarre et fini le graphe en deçca de "lpart" % des limites pour l'esthetique
            set largeur [ expr $lpart*$naxis1 ]
            set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
            set xdeb [ expr $xdeb0+$largeur ]
            set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
            set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
            set ydeb "*"
            set yfin "*"
            #-- Adapte la légende de l'abscisse
            if { $xdeb0 == 1.0 && $legendex=="" } {
                set legendex "Position (Pixel)"
            } else {
                set legendex "Wavelength (Å)"
            }
            set legendey "Relative flux"
        } elseif { [llength $args] == 4 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            set legendex [ lindex $args 2 ]
            set legendey [ lindex $args 3 ]

            #-- Détermine les bornes du graphique :
            buf$audace(bufNo) load "$audace(rep_images)/$fichier"
            set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
            #-- Demarre et fini le graphe en deçca de "lpart" % des limites pour l'esthetique
            set largeur [ expr $lpart*$naxis1 ]
            set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
            set xdeb [ expr $xdeb0+$largeur ]
            set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
            set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
            set ydeb "*"
            set yfin "*"
        } elseif { [llength $args] == 6 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            set legendex [ lindex $args 2 ]
            set legendey [ lindex $args 3 ]
            set xdeb [ lindex $args 4 ]
            set xfin [ lindex $args 5 ]
        } elseif { [llength $args] == 8 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            set legendex [ lindex $args 2 ]
            set legendey [ lindex $args 3 ]
            set xdeb [ lindex $args 4 ]
            set xfin [ lindex $args 5 ]
            set ydeb [ lindex $args 6 ]
            set yfin [ lindex $args 7 ]
        } else {
            ::console::affiche_erreur "Usage: spc_fit2pngvlarge fichier_fits \"Titre\" ?legende_x lende_y? ?xdeb xfin? ?ydeb yfin?\n\n"
            return 0
        }

        #-- spc_fits2dat renvoie un nom avec une extension : fichier.dat
        set fileout [ spc_fits2dat $fichier ]
        #-- Retire l'extension .fit du nom du fichier
        set spcfile [ file rootname $fichier ]

        #--- Créée le fichier script pour gnuplot :
        set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
        puts $file_id "call \"$spcaudace(repgp)/gp_novisuvlarge.cfg\" \"$audace(rep_images)/${spcfile}$spcaudace(extdat)\" \"$titre\" $ydeb $yfin $xdeb $xfin * \"$audace(rep_images)/${spcfile}.png\" \"$legendex\" \"$legendey\" "
        close $file_id

        #--- Détermine le chemin de l'executable Gnuplot selon le système d'exploitation :
        if { $tcl_platform(platform)=="unix" } {
            set answer [ catch { exec gnuplot $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "gnuplot résultat : $answer\n"
        } else {
            set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "gnuplot résultat : $answer\n"
        }

       #--- Effacement des fichiers de batch :
       after 1000 ; #-- Evite l'erreur "permission denied" lors de l'effacement
       file delete -force "$audace(rep_images)/${spcfile}$spcaudace(extdat)"
       file delete -force "$audace(rep_images)/${spcfile}.gp"

       #--- Fin du script :
       ::console::affiche_resultat "Profil de raie exporté sous ${spcfile}.png\n"
       return "${spcfile}.png"
    } else {
        ::console::affiche_erreur "Usage: spc_fit2pngvlarge fichier_fits \"Titre\" ?legende_x lende_y? ?xdeb xfin? ?ydeb yfin?\n\n"
    }
}
####################################################################




####################################################################
#  Procedure de conversion de fichier profil de raie calibré .fit en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2007
# Date modification : 29-01-2007
# Arguments : fichiers .fit du profil de raie
####################################################################

proc spc_multifit2png { args } {
    global audace spcaudace
    global conf
    global tcl_platform

    #-- 3%=0.03
    set lpart 0

    if { [llength $args] != 0 } {
        set nbfiles [ llength $args ]
        set listefile $args

        #--- Adapte la légende de l'abscisse :
        set fichier1 [ lindex $args 0 ]
        buf$audace(bufNo) load "$audace(rep_images)/$fichier1"
        set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
        set listemotsclef [ buf$audace(bufNo) getkwds ]
        if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
           set flag_cal 1
           set xdeb [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
           set disp [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
           if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
              set crpix1 [ lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1 ]
           } else {
              set crpix1 1
           }
           set xfin [ spc_calpoly $naxis1 $crpix1 $xdeb $disp 0 0 ]
        } else {
           set falg_cal 0
           set xdeb 1
           set xfin $naxis1
        }
        if { $flag_cal==0 } {
           set legendex "Position (Pixel)"
        } else {
            set legendex "Wavelength (Å)"
        }
        set titre ""
        set legendey ""

        #--- Conversion en dat :
        set i 1
        set listedat ""
        set plotcmd ""
        foreach fichier $listefile {
            set filedat [ spc_fits2dat "$fichier" ]
            lappend listedat $filedat
            if { $i != $nbfiles } {
                #append plotcmd "'$audace(rep_images)/$filedat' w l, "
                append plotcmd "'$filedat' w l, "
                #append plotcmd "'$filedat' using 1:($2+$i) w l, "
            } elseif { $i==1 } {
                append plotcmd "'$filedat' w l, "
            } else {
                #append plotcmd "'$audace(rep_images)/$filedat' w l"
                append plotcmd "'$filedat' w l"
            }
            incr i
        }

        #--- Construction du fichier btach de Gnuplot :
        #set file_id [open "$audace(rep_images)/multiplot.gp" w+]
        # set xdeb "*"
        # set xfin "*"
        ## puts $file_id "call \"$spcaudace(repgp)/gp_multi.cfg\" \"$plotcmd\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/multiplot.png\" \"$legendex\" \"$legendey\" "
        #puts $file_id "call \"$spcaudace(repgp)/gp_multi.cfg\" \"$plotcmd\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/multiplot.png\" \"$legendex\" "
        #close $file_id
       set file_id [open "$audace(rep_images)/multiplot.gp" w+]
       set largeur [ expr $xfin-$xdeb ]
       if { $naxis1<=3500 } {
          if { $largeur<=2000 && $flag_cal==1 } {
             puts $file_id "call \"$spcaudace(repgp)/gp_multi.cfg\" \"$plotcmd\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/multiplot.png\" \"$legendex\" "
          } elseif { $largeur>2000 && $flag_cal==1 } {
             puts $file_id "call \"$spcaudace(repgp)/gp_multilarge.cfg\" \"$plotcmd\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/multiplot.png\" \"$legendex\" "
          } elseif { $flag_cal==0 } {
             puts $file_id "call \"$spcaudace(repgp)/gp_multi.cfg\" \"$plotcmd\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/multiplot.png\" \"$legendex\" "
          }
       } else {
          puts $file_id "call \"$spcaudace(repgp)/gp_multilarge.cfg\" \"$plotcmd\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/multiplot.png\" \"$legendex\" "
       }
       close $file_id

        #=================== Gestion d'echelles differentes selon l'abscisse :
        if { 0>1 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            #set xdeb "*"
            #set xfin "*"
            buf$audace(bufNo) load "$audace(rep_images)/$fichier"
            set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
            #-- Demarre et fini le graphe en deçca de 3% des limites pour l'esthetique
            set largeur [ expr $lpart*$naxis1 ]
            set xdeb0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set xdeb [ expr $xdeb0+$largeur ]
            set xincr [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
        #} elseif { [llength $args] == 4 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            set xdeb [ lindex $args 2 ]
            set xfin [ lindex $args 3 ]
            buf$audace(bufNo) load "$audace(rep_images)/$fichier"
            set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
        }
        #============================

        #--- Détermine le chemin de l'executable Gnuplot selon le système d'exploitation :
        set repdflt [ bm_goodrep ]
        if { $tcl_platform(platform)=="unix" } {
            set answer [ catch { exec gnuplot $audace(rep_images)/multiplot.gp } ]
            ::console::affiche_resultat "gnuplot résultat : $answer\n"
        } else {
            set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/multiplot.gp } ]
            ::console::affiche_resultat "gnuplot résultat (0=OK) : $answer\n"
        }
        cd $repdflt

        #--- Effacement des fichiers de batch :
        #if { 1==0 } {
        after 1000 ; #-- Evite l'erreur "permission denied" lors de l'effacement
        file delete -force "$audace(rep_images)/multiplot.gp"
        foreach fichier $listedat {
            file delete -force "$audace(rep_images)/$fichier"
        }
        #}
        ::console::affiche_resultat "Profils de raie exporté sous multiplot.png\n"
        return "multiplot.png"
    } else {
        ::console::affiche_erreur "Usage: spc_multifit2png fichier_fits1 fichier_fits2 ... fichier_fitsn\n\n"
    }
}
####################################################################





####################################################################
#  Procedure de conversion de fichier profil de raie calibré .fit en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2007
# Date modification : 29-01-2007/16-02-2010
# Arguments : xdeb xfin ydeb yfin fichiers .fit du profil de raie
####################################################################

proc spc_multifit2pngopt { args } {
    global audace spcaudace
    global conf
    global tcl_platform

    #-- 3%=0.03
    set lpart 0

    set nbargs [ llength $args ]
    if { $nbargs != 0 } {
        set nbargs [ llength $args ]
        set coords [ lrange $args 0 3 ]
        set listefichiers [ lrange $args 4 [ expr $nbargs-1 ] ]
        set nbfiles [ expr $nbargs-4 ]

        #--- Coordonnees des extremes du graphe :
        set xdeb [ lindex $coords 0 ]
        set xfin [ lindex $coords 1 ]
        set ydeb [ lindex $coords 2 ]
        set yfin [ lindex $coords 3 ]


        #--- Adapte la légende de l'abscisse :
        set fichier1 [ lindex $listefichiers 0 ]
        buf$audace(bufNo) load "$audace(rep_images)/$fichier1"
        set listemotsclef [ buf$audace(bufNo) getkwds ]
        if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
            set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
        } else {
            set xdeb 1.0
        }
        if { $xdeb0 == 1.0 } {
            set legendex "Position (Pixel)"
        } else {
            set legendex "Wavelength (Å)"
        }
        set titre ""
        set legendey ""

        #--- Conversion en dat :
        set i 1
        set listedat ""
        set plotcmd ""
        foreach fichier $listefichiers {
            set filedat [ spc_fits2dat "$fichier" ]
            lappend listedat $filedat
            if { $i != $nbfiles } {
                #append plotcmd "'$audace(rep_images)/$filedat' w l, "
                append plotcmd "'$filedat' w l, "
                #append plotcmd "'$filedat' using 1:($2+$i) w l, "
            } elseif { $i==1 } {
                append plotcmd "'$filedat' w l, "
            } else {
                #append plotcmd "'$audace(rep_images)/$filedat' w l"
                append plotcmd "'$filedat' w l"
            }
            incr i
        }

        #--- Construction du fichier btach de Gnuplot :
        set file_id [open "$audace(rep_images)/multiplot.gp" w+]
        # puts $file_id "call \"$spcaudace(repgp)/gp_multi.cfg\" \"$plotcmd\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/multiplot.png\" \"$legendex\" \"$legendey\" "
        puts $file_id "call \"$spcaudace(repgp)/gp_multi.cfg\" \"$plotcmd\" \"$titre\" $ydeb $yfin $xdeb $xfin * \"$audace(rep_images)/multiplot.png\" \"$legendex\" "
        close $file_id


        #--- Détermine le chemin de l'executable Gnuplot selon le système d'exploitation :
        set repdflt [ bm_goodrep ]
        if { $tcl_platform(platform)=="unix" } {
            set answer [ catch { exec gnuplot $audace(rep_images)/multiplot.gp } ]
           ::console::affiche_resultat "gnuplot résultat (0=OK) : $answer\n"
        } else {
            set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/multiplot.gp } ]
           ::console::affiche_resultat "gnuplot résultat (0=OK) : $answer\n"
        }
        cd $repdflt

        #--- Effacement des fichiers de batch :
        after 1000 ; #-- Evite l'erreur "permission denied" lors de l'effacement
        file delete -force "$audace(rep_images)/multiplot.gp"
        foreach fichier $listedat {
            file delete -force "$audace(rep_images)/$fichier"
        }
        ::console::affiche_resultat "Profils de raie exporté sous multiplot.png\n"
        return "multiplot.png"
    } else {
        ::console::affiche_erreur "Usage: spc_multifit2pngopt xdeb xfin ydeb yfin fichier_fits1 fichier_fits2 ... fichier_fitsn\n\n"
    }
}
####################################################################


####################################################################
#  Procedure de conversion de fichier profil de raie calibré .fit en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20-09-2011
# Date modification : 28-12-2013
# Arguments : offset vertical entre les profils, travaille sur les spectres du répertoire de travail
####################################################################

proc spc_multifit2pngdec { args } {
   global audace spcaudace
   global conf
   global tcl_platform

   #-- 3%=0.03
   set lpart 0
   #set coef_conv_gp 7.8
   #set yheight_graph 600
   #- Pour png :
   #set xpos_png 68
   #- Pour pngcairo :
   set xpos_png 58
   #- Pour ps :
   #set xpos_ps 58
   set nbargs [ llength $args ]

   if { $nbargs==1 } {
      set offset [ lindex $args 0 ]
      set lambda_notee "none"
      set lambda_ref 0
   } elseif { $nbargs==2 } {
      set offset [ lindex $args 0 ]
      set lambda_notee [ lindex $args 1 ]
      set lambda_ref 0
   } elseif { $nbargs==3 } {
      set offset [ lindex $args 0 ]
      set xsdeb [ lindex $args 1 ]
      set xsfin [ lindex $args 2 ]
      set lambda_ref 0
      set lambda_notee "none"
   } elseif { $nbargs==4 } {
      set offset [ lindex $args 0 ]
      set xsdeb [ lindex $args 1 ]
      set xsfin [ lindex $args 2 ]
      set lambda_notee [ lindex $args 3 ]
      set lambda_ref 0
   } elseif { $nbargs==5 } {
      set offset [ lindex $args 0 ]
      set xsdeb [ lindex $args 1 ]
      set xsfin [ lindex $args 2 ]
      set lambda_notee [ lindex $args 3 ]
      set lambda_ref [ format "%4.3f" [ lindex $args 4 ] ]
   } else {
      # ::console::affiche_erreur "Usage: spc_multifit2pngdec offset_vertical_entre_profils ??lambda_spotted or ?lambda_begin lambda_end?? ??velocity_spotted(\"none\", number)? ?lambda_reference_velocity??\n"
      ::console::affiche_erreur "Usage: spc_multifit2pngdec vertical_offset_between_profils\n
spc_multifit2pngdec vertical_offset_between_profils lambda_spotted \(A\)\n
spc_multifit2pngdec vertical_offset_between_profils lambda_begin lambda_end\n
spc_multifit2pngdec vertical_offset_between_profils lambda_begin lambda_end lambda_spotted \(A\)\n
spc_multifit2pngdec vertical_offset_between_profils lambda_begin lambda_end none lambda_reference_for_velocity\n
spc_multifit2pngdec vertical_offset_between_profils lambda_begin lambda_end velocity_spotted \(km/s\) lambda_reference_for_velocity\n
"
      return ""
   }


   #--- Liste des fichiers du répertoire :
   set listefile [ lsort -dictionary [ glob -tail -dir $audace(rep_images) *$conf(extension,defaut) ] ]
   set listefile [ spc_ldatesort $listefile ]

   #--- Verification que lambda_deb, lambda_fin et lambda_notee se trouve dans la plage de longueur d'onde de travail :
   if { $nbargs>=2 } {
      set file1 [ lindex $listefile 0 ]
      buf$audace(bufNo) load "$audace(rep_images)/$file1"
      set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
         set flag_cal 1
         set xdeb [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
         set disp [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
         if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
            set crpix1 [ lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1 ]
         } else {
            set crpix1 1
         }
         set xfin [ spc_calpoly $naxis1 $crpix1 $xdeb $disp 0 0 ]
      } else {
         set falg_cal 0
         set xdeb 1
         set xfin $naxis1
      }

      #-- Teste le decoupage est dans les limites du 1ier spectre :
      if { $nbargs==2 } {
         if { $lambda_notee<=$xdeb || $lambda_notee>=$xfin } {
            ::console::affiche_erreur "Lambda_spotted must be in spectra wavelength bandwidth/dimensions ($xdeb ; $xfin)\n"
            return
         }
      } elseif { $nbargs>=3 } {
         if { $xsdeb<=$xdeb || $xsfin>=$xfin } {
            ::console::affiche_erreur "Lambda_begin and Lambda_end must be in spectra wavelength bandwidth/dimensions ($xdeb ; $xfin)\n"
            return
         } else {
            if { $nbargs==4 } {
               if { $lambda_notee<=$xsdeb || $lambda_notee>=$xsfin } {
                  ::console::affiche_erreur "Lambda_spotted must be in spectra wavelength bandwidth/dimensions ($xsdeb ; $xsfin)\n"
                  return
               }
            } elseif { $nbargs==5 && $lambda_notee!="none" } {
               set xdeb [ expr ($xsdeb-$lambda_ref)*$spcaudace(vlum)/$lambda_ref ]
               set xfin [ expr ($xsfin-$lambda_ref)*$spcaudace(vlum)/$lambda_ref ]
               if { $lambda_notee<=$xdeb || $lambda_notee>=$xfin } {
                  ::console::affiche_erreur "Velocity_spotted must be in spectra velocity bandwidth ($xdeb ; $xfin) km/s\n"
                  return
               }
            }
         }
      }
   }


   #--- Verifie si les spectres sont tous normalisés et recupere la date JD :
   set listejd [ list ]
   set listefiledec [ list ]
   set yoffset 0
   set objname ""
   foreach fichier $listefile {
      buf$audace(bufNo) load "$audace(rep_images)/$fichier"

      #-- Calcul le JD reduit du spectre :
      # set dateobs [ mc_date2jd [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ] ]
      ## lappend listejd [ format "%4.4f" [ expr 0.0001*round(10000*([ mc_date2jd [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ] ]-2450000.)) ] ]
      lappend listejd [ format "%5.4f" [ expr 0.0001*round(10000*([ mc_date2jd [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ] ]-2400000.)) ] ]
      #lappend listejd [ format "%5.4f" [ expr [ mc_date2jd [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ] ]-2400000. ] ]


      #-- Recherche du nom de l'objet :
      if { "$objname"=="" || [ regexp {\s+} "$objname" match objnamef ] } {
         set listemotsclef [ buf$audace(bufNo) getkwds ]
         if { [ lsearch $listemotsclef "OBJNAME" ] !=-1 } {
            set objname [ lindex [ buf$audace(bufNo) getkwd "OBJNAME" ] 1 ]
         }
         if { [ regexp {(\w+\s?\w+)\s*} "$objname" match objnamef ] } {
            set objname "$objnamef"            
         }
      }

      #-- Selection de la zone si des longueurs d'ondes sont données :
      if { $nbargs>=3 } {
         set fichier_sel [ spc_select $fichier $xsdeb $xsfin ]
      } elseif { $nbargs<=2 } {
         set fichier_sel "$fichier"
      }

      #-- Verifie si le spectre est mis a l'echelle du continuum à 1 et decale les intensites de $yoffset :
      set icont [ spc_icontinuum $fichier_sel ]
      if { [ expr abs($icont-1.) ]>0.2 } {
         set fileout1 [ spc_rescalecont $fichier_sel ]
         set fileout2 [ spc_offset $fileout1 $yoffset ]
         lappend listefiledec $fileout2
         file delete -force "$audace(rep_images)/$fileout1$conf(extension,defaut)"
      } else {
         set fileout [ spc_offset $fichier_sel $yoffset ]
         lappend listefiledec $fileout
      }
      if { $nbargs>=3 } {
         file delete -force "$audace(rep_images)/$fichier_sel$conf(extension,defaut)"
      }
      set yoffset [ expr $yoffset+$offset ]
   }

   #--- Formatage nom objet :
   set rout [ catch { regsub "_" "$objname" "-" resultat } ]
   set objname "$resultat"

   
   #--- Adapte la légende de l'abscisse :
   set fichier1 [ lindex $listefiledec 0 ]
   buf$audace(bufNo) load "$audace(rep_images)/$fichier1"
   set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
   set listemotsclef [ buf$audace(bufNo) getkwds ]
   if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
      set flag_cal 1
      set xdeb [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
      set disp [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
      if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
         set crpix1 [ lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1 ]
      } else {
         set crpix1 1
      }
      set xfin [ spc_calpoly $naxis1 $crpix1 $xdeb $disp 0 0 ]
   } else {
      set falg_cal 0
      set xdeb 1
      set xfin $naxis1
   }
   if { $flag_cal==0 } {
      set legendex "Position (Pixel)"
   } else {
      if { $lambda_ref==0 } {
         #set legendex "Wavelength (Å)"
         set legendex "Wavelength (Å)"
      } else {
         set legendex "Radial velocity (km/s) with respect to the wavelength $lambda_ref A"
         set xdeb [ expr ($xdeb-$lambda_ref)*$spcaudace(vlum)/$lambda_ref ]
         set xfin [ expr ($xfin-$lambda_ref)*$spcaudace(vlum)/$lambda_ref ]
      }
   }
   #-- Determination du continuum a l'extreme droite du premier spectre :
   if { $flag_cal==0 } {
      set x1_legende [ expr $xfin*0.87 ]
   } else {
      set lfin [ expr round($naxis1*.87) ]
      set x1_legende [ spc_calpoly $lfin $crpix1 $xdeb $disp 0 0 ]
   }
   set y1_legende 0
   set y1_legende [ spc_icontinuum $fichier1 $x1_legende ]
   set y1_legende [ expr $y1_legende+$offset*0.3 ]
   if { $y1_legende==0 } { set y1_legende 1.3 }

   #--- Initialisation des legendes :
   set nbfiles [ llength $listefiledec ]
   set jd_deb [ format "%7.4f" [ expr [ lindex $listejd 0 ]+2400000. ] ]
   set jd_fin [ format "%7.4f" [ expr [ lindex $listejd [ expr $nbfiles-1 ] ]+2400000. ] ]


   if { $objname == "" } {
      set titre "Time evolution from $jd_deb to $jd_fin"
   } else {
      set titre "Time evolution of $objname from $jd_deb to $jd_fin"
   }
   if { $offset==0. } {
      set legendey "Relative flux"
   } else {
      set legendey "Spectra shifted by $offset unit along intensity axis"
   }


   #--- Conversion en dat :
   set i 1
   set listedat [ list ]
   set plotcmd ""
   foreach fichier $listefiledec jd $listejd {
      if { $lambda_ref==0 } {
         set filedat [ spc_fits2dat "$fichier" ]
      } else {
         set filedat [ spc_fits2datvel "$fichier" $lambda_ref ]
      }
      lappend listedat $filedat
      if { $i != $nbfiles } {
         #append plotcmd "'$audace(rep_images)/$filedat' w l, "
         #append plotcmd "'$filedat' using 1:($2+$i) w l, "
         #append plotcmd "'$filedat' w l, "
         append plotcmd "'$filedat' w l title 'MJD $jd', "
      } elseif { $i==1 } {
         append plotcmd "'$filedat' w l title 'MJD $jd', "
      } else {
         #append plotcmd "'$audace(rep_images)/$filedat' w l"
         append plotcmd "'$filedat' w l title 'MJD $jd'"
      }
      incr i
   }

   #--- Modification du fichier de config :
   #-- Modification de dla position des legendes dans le fichier de config de gnuplot :
   #set ypos1 [ expr $y1_legende+$offset/10. ]
   set ypos1 [ expr $y1_legende*(1+$offset/10.) ]
   if { $ypos1<1 } { set ypos1 [ expr $ypos1+1. ] }

   # set file_idin [ open "$spcaudace(repgp)/gp_multiover_ps.cfg" r+ ]
   # set xpos $xpos_ps
   set file_idin [ open "$spcaudace(repgp)/gp_multiover.cfg" r+ ]
   set xpos $xpos_png
   set file_id [ open "$audace(rep_images)/gp_multiover.cfg" w+ ]
   fconfigure $file_id -translation crlf
   #-- Ajout d'une ligne en pointilles verticale :
   #puts $file_id "set x2tics (\"\" 6676)"
   #puts $file_id "set grid noxtics x2tics"

   set contents [ split [ read $file_idin ] \n ]
   #-- Pour tous les profils a tracer :
   foreach ligne $contents {
      if { [ regexp "set key invert" $ligne match ligne_modif ]  } {
         # regsub -all "set key invert" $ligne "set key invert bottom samplen 0 height -13 spacing $moffset at $xfin, first $ypremier" ligne_modif
         regsub -all "set key invert" $ligne "set key off" ligne_modif
         puts $file_id "$ligne_modif"
         set nofile 0
         foreach jd $listejd {
            set ypos [ expr $ypos1+$offset*$nofile ]
            puts $file_id "set label \"MJD $jd\" right at character $xpos, first $ypos front"
            incr nofile
         }
      } elseif { $lambda_notee!="none" && [ regexp "set nogrid" $ligne match ligne_modif ]  } {
         regsub -all "set nogrid" $ligne "set x2tics (\"\" $lambda_notee) ; set grid noxtics x2tics" ligne_modif
         puts $file_id "$ligne_modif"
      } elseif { $lambda_notee!="none" && [ regexp "set title" $ligne match ligne_modif ]  } {
         #regsub -all "set title '\$1' offset 0,-0.5" $ligne "set x2label '\$1' offset 0,-1.5" ligne_modif
         set ligne_modif "set x2label '\$1' offset 0,-1.5"
         puts $file_id "$ligne_modif"
      } else {
         puts $file_id "$ligne"
      }
   }
   close $file_id
   close $file_idin

   #--- Construction du fichier btach de Gnuplot :
   #set file_id [open "$audace(rep_images)/multiplot.gp" w+]
   # set xdeb "*"
   # set xfin "*"
   ## puts $file_id "call \"$spcaudace(repgp)/gp_multi.cfg\" \"$plotcmd\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/multiplot.png\" \"$legendex\" \"$legendey\" "
   #puts $file_id "call \"$spcaudace(repgp)/gp_multi.cfg\" \"$plotcmd\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/multiplot.png\" \"$legendex\" "
   #close $file_id
   set file_id [ open "$audace(rep_images)/multiplot.gp" w+ ]
   fconfigure $file_id -translation crlf
   set largeur [ expr $xfin-$xdeb ]
   if { $naxis1<=3500 } {
      if { $largeur<=2000 && $flag_cal==1 } {
         #puts $file_id "call \"$spcaudace(repgp)/gp_multiover.cfg\" \"$plotcmd\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/multiplot.png\" \"$legendex\" \"$legendey\" "
         puts $file_id "call \"$audace(rep_images)/gp_multiover.cfg\" \"$plotcmd\" \"$titre\" * * '$xdeb' '$xfin' * \"$audace(rep_images)/multiplot.png\" \"$legendex\" \"$legendey\" "
      } elseif { $largeur>2000 && $flag_cal==1 } {
         puts $file_id "call \"$spcaudace(repgp)/gp_multilarge.cfg\" \"$plotcmd\" \"$titre\" * * '$xdeb' '$xfin' * \"$audace(rep_images)/multiplot.png\" \"$legendex\" \"$legendey\" "
      } elseif { $flag_cal==0 } {
         puts $file_id "call \"$audace(rep_images)/gp_multiover.cfg\" \"$plotcmd\" \"$titre\" * * '$xdeb' '$xfin' * \"$audace(rep_images)/multiplot.png\" \"$legendex\" \"$legendey\" "
      }
   } else {
      puts $file_id "call \"$spcaudace(repgp)/gp_multilarge.cfg\" \"$plotcmd\" \"$titre\" * * '$xdeb' '$xfin' * \"$audace(rep_images)/multiplot.png\" \"$legendex\" "
   }
   close $file_id

   #--- Détermine le chemin de l'executable Gnuplot selon le système d'exploitation :
   set repdflt [ bm_goodrep ]
   if { $tcl_platform(platform)=="unix" } {
      set answer [ catch { exec gnuplot $audace(rep_images)/multiplot.gp } ]
      ::console::affiche_resultat "gnuplot résultat (0=OK) : $answer\n"
   } else {
      set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/multiplot.gp } ]
      ::console::affiche_resultat "gnuplot résultat (0=OK) : $answer\n"
   }
   cd $repdflt

   #--- Effacement des fichiers de batch :
   if { 1==1 } {
   after 1000 ; #-- Evite l'erreur "permission denied" lors de l'effacement
   file delete -force "$audace(rep_images)/multiplot.gp"
   file delete -force "$audace(rep_images)/gp_multiover.cfg"
   foreach fichier $listedat {
      file delete -force "$audace(rep_images)/$fichier"
      set fichierfit [ file rootname $fichier ]
      set fichierfit "$fichierfit$conf(extension,defaut)"
      file delete -force "$audace(rep_images)/$fichierfit"
   }
   }
   ::console::affiche_resultat "\nGraphique sauvé sous multiplot.png\n"
   return "multiplot.png"
}
####################################################################


####################################################################
#  Procedure de conversion de fichier profil de raie calibré .fit en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20-09-2011
# Date modification : 20-09-2011
# Arguments : offset vertical entre les profils, travaille sur les spectres du répertoire de travail
####################################################################

proc spc_multifit2pngdec1 { args } {
   global audace spcaudace
   global conf
   global tcl_platform

   #-- 3%=0.03
   set lpart 0
   #set coef_conv_gp 7.8
   #set yheight_graph 600
   #- Pour png :
   set xpos 68
   #- Pour ps :
   #set xpos 60
   set nbargs [ llength $args ]

   if { $nbargs==1 } {
      set offset [ lindex $args 0 ]
      set lambda_ref 0
   } elseif { $nbargs==3 } {
      set offset [ lindex $args 0 ]
      set xsdeb [ lindex $args 1 ]
      set xsfin [ lindex $args 2 ]
      set lambda_ref 0
   } elseif { $nbargs==4 } {
      set offset [ lindex $args 0 ]
      set xsdeb [ lindex $args 1 ]
      set xsfin [ lindex $args 2 ]
      set lambda_ref [ lindex $args 3 ]
   } else {
      ::console::affiche_erreur "Usage: spc_multifit2pngdec offset_vertical_entre_profils ?xdeb xfin? ?lambda_reference?\n"
      return ""
   }

   #--- Liste des fichiers du répertoire :
   set listefile [ lsort -dictionary [ glob -tail -dir $audace(rep_images) *$conf(extension,defaut) ] ]
   set listefile [ spc_ldatesort $listefile ]

   #--- Verifie si les spectres sont tous normalisés et recupere la date JD :
   set listejd [ list ]
   set listefiledec [ list ]
   set yoffset 0
   set objname ""
   foreach fichier $listefile {
      buf$audace(bufNo) load "$audace(rep_images)/$fichier"

      #-- Calcul le JD reduit du spectre :
      # set dateobs [ mc_date2jd [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ] ]
      # lappend listejd [ format "%4.4f" [ expr 0.0001*round(10000*([ mc_date2jd [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ] ]-2450000.)) ] ]
      lappend listejd [ format "%5.4f" [ expr 0.0001*round(10000*([ mc_date2jd [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ] ]-2400000.)) ] ]

      #-- Recherche du nom de l'objet :
      if { $objname == "" } {
         set listemotsclef [ buf$audace(bufNo) getkwds ]
         if { [ lsearch $listemotsclef "OBJNAME" ] !=-1 } {
            set objname [ lindex [ buf$audace(bufNo) getkwd "OBJNAME" ] 1 ]
         }
      }

      #-- Selection de la zone si des longueurs d'ondes sont données :
      if { $nbargs==3 || $nbargs==4 } {
         set fichier_sel [ spc_select $fichier $xsdeb $xsfin ]
      } elseif { $nbargs==1 } {
         set fichier_sel "$fichier"
      }

      #-- Verifie si le spectre est mis a l'echelle du continuum à 1 et decale les intensites de $yoffset :
      set icont [ spc_icontinuum $fichier_sel ]
      if { [ expr abs($icont-1.) ]>0.2 } {
         set fileout1 [ spc_rescalecont $fichier_sel ]
         set fileout2 [ spc_offset $fileout1 $yoffset ]
         lappend listefiledec $fileout2
         file delete -force "$audace(rep_images)/$fileout1$conf(extension,defaut)"
      } else {
         set fileout [ spc_offset $fichier_sel $yoffset ]
         lappend listefiledec $fileout
      }
      if { $nbargs==3 || $nbargs==4 } {
         file delete -force "$audace(rep_images)/$fichier_sel$conf(extension,defaut)"
      }
      set yoffset [ expr $yoffset+$offset ]
   }

   #--- Adapte la légende de l'abscisse :
   set fichier1 [ lindex $listefiledec 0 ]
   buf$audace(bufNo) load "$audace(rep_images)/$fichier1"
   set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
   set listemotsclef [ buf$audace(bufNo) getkwds ]
   if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
      set flag_cal 1
      set xdeb [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
      set disp [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
      if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
         set crpix1 [ lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1 ]
      } else {
         set crpix1 1
      }
      set xfin [ spc_calpoly $naxis1 $crpix1 $xdeb $disp 0 0 ]
   } else {
      set falg_cal 0
      set xdeb 1
      set xfin $naxis1
   }
   if { $flag_cal==0 } {
      set legendex "Position (Pixel)"
   } else {
      if { $lambda_ref==0 } {
         set legendex "Wavelength (Å)"
      } else {
         set legendex "Radial velocity with respect to the wavelength $lambda_ref A (km/s)"
         set xdeb [ expr ($xdeb-$lambda_ref)*$spcaudace(vlum)/$lambda_ref ]
         set xfin [ expr ($xfin-$lambda_ref)*$spcaudace(vlum)/$lambda_ref ]
      }
   }
   #-- Determination du continuum a l'extreme droite du premier spectre :
   if { $flag_cal==0 } {
      set x1_legende [ expr $xfin*0.87 ]
   } else {
      set lfin [ expr round($naxis1*.87) ]
      set x1_legende [ spc_calpoly $lfin $crpix1 $xdeb $disp 0 0 ]
   }
   set y1_legende 0
   set y1_legende [ spc_icontinuum $fichier1 $x1_legende ]
   set y1_legende [ expr $y1_legende+$offset*0.3 ]
   if { $y1_legende==0 } { set y1_legende 1.3 }

   #--- Initialisation des legendes :
   set nbfiles [ llength $listefiledec ]
   set jd_deb [ format "%7.4f" [ expr [ lindex $listejd 0 ]+2400000. ] ]
   set jd_fin [ format "%7.4f" [ expr [ lindex $listejd [ expr $nbfiles-1 ] ]+2400000. ] ]
   #regsub " " "$objname" "" objname
   if { [ regexp {(\w+\s?\w+)\s*} $objname match objnamef ] } {
      set objname "$objnamef"
   }

   if { $objname == "" } {
      set titre "Time evolution from $jd_deb to $jd_fin"
   } else {
      set titre "Time evolution of $objname from $jd_deb to $jd_fin"
   }
   if { $offset==0. } {
      set legendey "Relative flux"
   } else {
      set legendey "Spectra shifted by $offset unit along intensity axis"
   }

   #--- Conversion en dat :
   set i 1
   set listedat [ list ]
   set plotcmd ""
   foreach fichier $listefiledec jd $listejd {
      if { $lambda_ref==0 } {
         set filedat [ spc_fits2dat "$fichier" ]
      } else {
         set filedat [ spc_fits2datvel "$fichier" $lambda_ref ]
      }
      lappend listedat $filedat
      if { $i != $nbfiles } {
         #append plotcmd "'$audace(rep_images)/$filedat' w l, "
         #append plotcmd "'$filedat' using 1:($2+$i) w l, "
         #append plotcmd "'$filedat' w l, "
         append plotcmd "'$filedat' w l title 'MJD $jd', "
      } elseif { $i==1 } {
         append plotcmd "'$filedat' w l title 'MJD $jd', "
      } else {
         #append plotcmd "'$audace(rep_images)/$filedat' w l"
         append plotcmd "'$filedat' w l title 'MJD $jd'"
      }
      incr i
   }

   #--- Modification du fichier de config :
   #-- Modification de dla position des legendes dans le fichier de config de gnuplot :
   #set ypos1 [ expr $y1_legende+$offset/10. ]
   set ypos1 [ expr $y1_legende*(1+$offset/10.) ]
   # set file_idin [ open "$spcaudace(repgp)/gp_multiover_ps.cfg" r+ ]
   set file_idin [ open "$spcaudace(repgp)/gp_multiover.cfg" r+ ]
   set file_id [ open "$audace(rep_images)/gp_multiover.cfg" w+ ]
   fconfigure $file_id -translation crlf
   set contents [ split [ read $file_idin ] \n ]
   foreach ligne $contents {
      if { [ regexp "set key invert" $ligne match ligne_modif ]  } {
         # regsub -all "set key invert" $ligne "set key invert bottom samplen 0 height -13 spacing $moffset at $xfin, first $ypremier" ligne_modif
         regsub -all "set key invert" $ligne "set key off" ligne_modif
         puts $file_id "$ligne_modif"
         set nofile 0
         foreach jd $listejd {
            set ypos [ expr $ypos1+$offset*$nofile ]
            puts $file_id "set label \"MJD $jd\" right at character $xpos, first $ypos front"
            incr nofile
         }
      } else {
         puts $file_id "$ligne"
      }
   }
   close $file_id
   close $file_idin

   #--- Construction du fichier btach de Gnuplot :
   #set file_id [open "$audace(rep_images)/multiplot.gp" w+]
   # set xdeb "*"
   # set xfin "*"
   ## puts $file_id "call \"$spcaudace(repgp)/gp_multi.cfg\" \"$plotcmd\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/multiplot.png\" \"$legendex\" \"$legendey\" "
   #puts $file_id "call \"$spcaudace(repgp)/gp_multi.cfg\" \"$plotcmd\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/multiplot.png\" \"$legendex\" "
   #close $file_id
   set file_id [ open "$audace(rep_images)/multiplot.gp" w+ ]
   fconfigure $file_id -translation crlf
   set largeur [ expr $xfin-$xdeb ]
   if { $naxis1<=3500 } {
      if { $largeur<=2000 && $flag_cal==1 } {
         #puts $file_id "call \"$spcaudace(repgp)/gp_multiover.cfg\" \"$plotcmd\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/multiplot.png\" \"$legendex\" \"$legendey\" "
         puts $file_id "call \"$audace(rep_images)/gp_multiover.cfg\" \"$plotcmd\" \"$titre\" * * '$xdeb' '$xfin' * \"$audace(rep_images)/multiplot.png\" \"$legendex\" \"$legendey\" "
      } elseif { $largeur>2000 && $flag_cal==1 } {
         puts $file_id "call \"$spcaudace(repgp)/gp_multilarge.cfg\" \"$plotcmd\" \"$titre\" * * '$xdeb' '$xfin' * \"$audace(rep_images)/multiplot.png\" \"$legendex\" \"$legendey\" "
      } elseif { $flag_cal==0 } {
         puts $file_id "call \"$audace(rep_images)/gp_multiover.cfg\" \"$plotcmd\" \"$titre\" * * '$xdeb' '$xfin' * \"$audace(rep_images)/multiplot.png\" \"$legendex\" \"$legendey\" "
      }
   } else {
      puts $file_id "call \"$spcaudace(repgp)/gp_multilarge.cfg\" \"$plotcmd\" \"$titre\" * * '$xdeb' '$xfin' * \"$audace(rep_images)/multiplot.png\" \"$legendex\" "
   }
   close $file_id

   #--- Détermine le chemin de l'executable Gnuplot selon le système d'exploitation :
   set repdflt [ bm_goodrep ]
   if { $tcl_platform(platform)=="unix" } {
      set answer [ catch { exec gnuplot $audace(rep_images)/multiplot.gp } ]
      ::console::affiche_resultat "gnuplot résultat (0=OK) : $answer\n"
   } else {
      set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/multiplot.gp } ]
      ::console::affiche_resultat "gnuplot résultat (0=OK) : $answer\n"
   }
   cd $repdflt

   #--- Effacement des fichiers de batch :
   #if { 1==0 } {

   file delete -force "$audace(rep_images)/multiplot.gp"
   file delete -force "$audace(rep_images)/gp_multiover.cfg"
   foreach fichier $listedat {
      file delete -force "$audace(rep_images)/$fichier"
      set fichierfit [ file rootname $fichier ]
      set fichierfit "$fichierfit$conf(extension,defaut)"
      file delete -force "$audace(rep_images)/$fichierfit"
   }
   #}
   ::console::affiche_resultat "\nGraphique sauvé sous multiplot.png\n"
   return "multiplot.png"
}
####################################################################



####################################################################
#  Procedure de conversion de fichier profil de raie calibré .fit en .png evec précision de la légende
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-01-2007
# Date modification : 03-01-2007
# Arguments : fichier .fit du profil de raie, titre, ?legende_x legende_y? ?xdeb xfin?
####################################################################

proc spc_fit2ps { args } {
    global audace spcaudace
    global conf
    global tcl_platform

    #-- 3%=0.03
    set lpart 0
   set ydeb "*"
   set yfin "*"

    if { [llength $args] == 8 || [llength $args] == 6 || [llength $args] == 4 || [llength $args] == 2 } {
        if { [llength $args] == 2 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            set legendey "Relative flux"
            set legendex "Wavelength (\305)"
            #--- Détermination de xdeb et xfin :
            buf$audace(bufNo) load "$audace(rep_images)/$fichier"
            set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
            #-- Demarre et fini le graphe en deçca de "lpart" % des limites pour l'esthetique
            set largeur [ expr $lpart*$naxis1 ]
            set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
            set xdeb [ expr $xdeb0+$largeur ]
            set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
            set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
        } elseif { [llength $args] == 4 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            set legendex [ lindex $args 2 ]
            set legendey [ lindex $args 3 ]
            #--- Détermination de xdeb et xfin :
            buf$audace(bufNo) load "$audace(rep_images)/$fichier"
            set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
            #-- Demarre et fini le graphe en deçca de "lpart" % des limites pour l'esthetique
            set largeur [ expr $lpart*$naxis1 ]
            set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
            set xdeb [ expr $xdeb0+$largeur ]
            set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
            set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
        } elseif { [llength $args] == 6 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            set legendex [ lindex $args 2 ]
            set legendey [ lindex $args 3 ]
            set xdeb [ lindex $args 4 ]
            set xfin [ lindex $args 5 ]
        } elseif { [llength $args] == 8 } {
            set fichier [ file rootname [ lindex $args 0 ] ]
            set titre [ lindex $args 1 ]
            set legendex [ lindex $args 2 ]
            set legendey [ lindex $args 3 ]
            set xdeb [ lindex $args 4 ]
            set xfin [ lindex $args 5 ]
            set ydeb [ lindex $args 6 ]
            set yfin [ lindex $args 7 ]
        } else {
            ::console::affiche_erreur "Usage: spc_fit2ps fichier_fits \"Titre\" ?legende_x lende_y? ?xdeb xfin?\n\n"
        }


        #-- spc_fits2dat renvoie un nom avec une extension : fichier.dat
        set fileout [ spc_fits2dat $fichier ]
        #-- Retire l'extension .fit du nom du fichier
        set spcfile [ file rootname $fichier ]

        #--- Créée le fichier script pour gnuplot :
        set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
        puts $file_id "call \"$spcaudace(repgp)/gp_ps.cfg\" \"$audace(rep_images)/${spcfile}$spcaudace(extdat)\" \"$titre\" $ydeb $yfin $xdeb $xfin * \"$audace(rep_images)/${spcfile}.ps\" \"$legendex\" \"$legendey\" "
        close $file_id

        #--- Détermine le chemin de l'executable Gnuplot selon le système d'exploitation :
        if { $tcl_platform(platform)=="unix" } {
            set answer [ catch { exec gnuplot $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "gnuplot résultat : $answer\n"
        } else {
            set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "gnuplot résultat : $answer\n"
        }

        #--- Effacement des fichiers de batch :
        after 1000 ; #-- Evite l'erreur "permission denied" lors de l'effacement
        file delete -force "$audace(rep_images)/${spcfile}$spcaudace(extdat)"
        file delete -force "$audace(rep_images)/${spcfile}.gp"

        #--- Fin du script :
        ::console::affiche_resultat "Profil de raie exporté sous ${spcfile}.ps\n"
        return "${spcfile}.ps"
    } else {
        ::console::affiche_erreur "Usage: spc_fit2ps fichier_fits \"Titre\" ?legende_x lende_y? ?xdeb xfin?\n\n"
    }
}
####################################################################




####################################################################
#  Procedure de création du fichier batch pour gnuplot afin de convertir un fichier profil de raie calibré .fit en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-09-2005
# Date modification : 03-09-2005
# Arguments : fichier .fit du profil de raie, titre, ?xdeb, xfin?
####################################################################

proc spc_fit2pngbat { args } {
   global audace spcaudace
   global conf
   set ecart 0.005

   if { [llength $args] == 4 || [llength $args] == 2 } {
       if { [llength $args] == 2 } {
           set fichier [ lindex $args 0 ]
           set titre [ lindex $args 1 ]
           #set xdeb "*"
           #set xfin "*"
           buf$audace(bufNo) load "$audace(rep_images)/$fichier"
           set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
           #-- Demarre et fini le graphe en deçca de 3% des limites pour l'esthetique
           set largeur [ expr $ecart*$naxis1 ]
           set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
           set xdeb [ expr $xdeb0+$largeur ]
           set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
           #set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
           set xfin [ expr $naxis1*$xincr+$xdeb0-1*$largeur ]
       } elseif { [llength $args] == 4 } {
           set fichier [ lindex $args 0 ]
           set titre [ lindex $args 1 ]
           set xdeb [ lindex $args 2 ]
           set xfin [ lindex $args 3 ]
           buf$audace(bufNo) load "$audace(rep_images)/$fichier"
           set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
       }

       #--- Adapte la légende de l'abscisse
       if { $xdeb0 == 1.0 } {
           set legendex "Position (Pixel)"
       } else {
           set legendex "Wavelength (Å)"
       }
       set legendey "Intensity (ADU)"

       set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
       set ext ".dat"

       spc_fits2dat $fichier
       # Retire l'extension .fit du nom du fichier
       set spcfile [ file rootname $fichier ]
       #exec echo "call \"$spcaudace(repgp)/gpx11.cfg\" \"${spcfile}$ext\" \"$titre\" * * $xdeb $xfin $pas \"${spcfile}.png\" \"$legendex\" \"$legendey\" " > $repertoire_gp/run_gp
       set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
       puts $file_id "call \"$spcaudace(repgp)/gp_visu.cfg\" \"${spcfile}$ext\" \"$titre\" * * $xdeb $xfin * \"${spcfile}.png\" \"$legendex\" \"$legendey\" "
       close $file_id
       set file_id [open "$audace(rep_images)/trace_gp.bat" w+]
       puts $file_id "gnuplot \"${spcfile}.gp\" "
       close $file_id
       # exec gnuplot $repertoire_gp/run_gp
       ::console::affiche_resultat "Exécuter dans un terminal : trace_gp.bat\n"
   } else {
       ::console::affiche_erreur "Usage: spc_fit2pngbat fichier_fits \"Titre\" ?xdébut xfin?\n\n"
   }
}
####################################################################



####################################################################
#  Procedure de conversion de fichier profil de raie calibré .dat en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 27-04-2006
# Date modification : 27-04-2006
# Arguments : fichier .dat du profil de raie, titre, ?xdeb, xfin?
####################################################################

proc spc_dat2png { args } {
    global audace spcaudace
    global conf
    global tcl_platform

    if { [llength $args] == 4 || [llength $args] == 2 } {
        if { [llength $args] == 2 } {
            set fichier [ lindex $args 0 ]
            set titre [ lindex $args 1 ]
            #set xdeb "*"
            #set xfin "*"
            set fichierfit [ spc_dat2fits $fichier ${fichier}_fittmp ]
            buf$audace(bufNo) load "$audace(rep_images)/$fichierfit"
            set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
            #-- Demarre et fini le graphe en deçca de 3% des limites pour l'esthetique
            set largeur [ expr 0.03*$naxis1 ]
            set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
            set xdeb [ expr $xdeb0+$largeur ]
            set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
            set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
        } elseif { [llength $args] == 4 } {
            set fichier [ lindex $args 0 ]
            set titre [ lindex $args 1 ]
            set xdeb [ lindex $args 2 ]
            set xfin [ lindex $args 3 ]
            set fichierfit [ spc_dat2fits $fichier ${fichier}_fittmp ]
            buf$audace(bufNo) load "$audace(rep_images)/$fichierfit"
            set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
        }

        #--- Adapte la légende de l'abscisse
        if { $xdeb0 == 1.0 } {
            set legendex "Position (Pixel)"
        } else {
            set legendex "Wavelength (Å)"
        }
        set legendey "Intensity (ADU)"

        #spc_fits2dat $fichier
        #-- Retire l'extension .fit du nom du fichier
        set spcfile [ file rootname $fichier ]

        #--- Créée le fichier script pour gnuplot :
        set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
        puts $file_id "call \"$spcaudace(repgp)/gp_novisu.cfg\" \"$audace(rep_images)/${spcfile}$spcaudace(extdat)\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/${spcfile}.png\" \"$legendex\" \"$legendey\" "
        close $file_id

        #--- Détermine le chemin de l'executable Gnuplot selon le système d'exploitation :
        if { $tcl_platform(platform)=="unix" } {
            set answer [ catch { exec gnuplot $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "$answer\n"
        } else {
            set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "$answer\n"
        }

        ::console::affiche_resultat "Profil de raie exporté sous ${spcfile}.png\n"
        return ${spcfile}.png
    } else {
        ::console::affiche_erreur "Usage: spc_dat2png spectre_dat \"Titre\" ?xdébut xfin?\n\n"
    }
}
####################################################################



####################################################################
#  Procedure de conversion de fichier profil de raie calibré .dat en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 25-02-2011
# Date modification : 25-02-2011
# Arguments : fichier .dat du profil de raie, titre, ?xdeb, xfin?
####################################################################

proc spc_txt2png { args } {
   global audace spcaudace
   global conf
   global tcl_platform

   set nbargs [ llength $args ]
   if { $nbargs==4 } {
      set fichier [ lindex $args 0 ]
      set titre [ lindex $args 1 ]
      set legendex [ lindex $args 2 ]
      set legendey [ lindex $args 3 ]
      set joined "o"
      set xdeb "*"
      set xfin "*"
      set ydeb "*"
      set yfin "*"
   } elseif { $nbargs==5 } {
      set fichier [ lindex $args 0 ]
      set titre [ lindex $args 1 ]
      set legendex [ lindex $args 2 ]
      set legendey [ lindex $args 3 ]
      set joined [ lindex $args 4 ]
      set xdeb "*"
      set xfin "*"
      set ydeb "*"
      set yfin "*"
   } elseif { $nbargs==7 } {
      set fichier [ lindex $args 0 ]
      set titre [ lindex $args 1 ]
      set legendex [ lindex $args 2 ]
      set legendey [ lindex $args 3 ]
      set joined [ lindex $args 4 ]
      set xdeb [ lindex $args 5 ]
      set xfin [ lindex $args 6 ]
      set ydeb "*"
      set yfin "*"
   } elseif { $nbargs==9 } {
      set fichier [ lindex $args 0 ]
      set titre [ lindex $args 1 ]
      set legendex [ lindex $args 2 ]
      set legendey [ lindex $args 3 ]
      set joined [ lindex $args 4 ]
      set xdeb [ lindex $args 5 ]
      set xfin [ lindex $args 6 ]
      set ydeb [ lindex $args 7 ]
      set yfin [ lindex $args 8 ]
   } else {
      ::console::affiche_erreur "Usage: spc_txt2png fichier_data \"Titre\" \"Légende axe x\" \"Légende axe y\" ?joined_points (o/n)? ?xdébut xfin? ?ydeb yfin?\n"
      return ""
   }

   #--- Recherche de xdeb et xfin :
   if { $nbargs<=5 } {
      set fileid [ open "$audace(rep_images)/$fichier" r+ ]
      set contents [ split [read $fileid] \n]
      close $fileid
      set abscisses [ list ]
      foreach ligne $contents {
         set abscisse [ lindex $ligne 0 ]
         if { $abscisse!="" } { lappend abscisses $abscisse }
      }
      set xdeb1 [ lindex $abscisses 0 ]
      set xfin1 [ lindex $abscisses [ expr [ llength $abscisses ]-1 ] ]
      set abscisses [ lsort -dictionary -increasing $abscisses ]
      set xdeb [ lindex $abscisses 0 ]
      if { $xdeb=="" } { set xdeb [ lindex $abscisses 1 ] }
      set xfin [ lindex $abscisses [ expr [ llength $abscisses ]-1 ] ]
      if { $xfin=="" } {
         set xfin $xfin1
      } elseif { $xfin1<$xfin } { set xfin $xfin }
      if { $xdeb>$xdeb1 } { set xdeb $xdeb1 }
      if { $xfin<$xfin1 } { set xfin $xfin1 }
      # ::console::affiche_resultat "Xdeb=$xdeb ; Xfin=$xfin\n"
   }

   #--- Créée le fichier script pour gnuplot :
   set fichier_nm [ file rootname $fichier ]
   set file_id [open "$audace(rep_images)/${fichier_nm}.gp" w+]
   if { $joined=="n" } {
      puts $file_id "call \"$spcaudace(repgp)/gp_points.cfg\" \"$audace(rep_images)/$fichier\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/${fichier_nm}.png\" \"$legendex\" \"$legendey\" "
   } else {
      puts $file_id "call \"$spcaudace(repgp)/gp_novisu.cfg\" \"$audace(rep_images)/$fichier\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/${fichier_nm}.png\" \"$legendex\" \"$legendey\" "
   }
   close $file_id

   #--- Détermine le chemin de l'executable Gnuplot selon le système d'exploitation :
   if { $tcl_platform(platform)=="unix" } {
      set answer [ catch { exec gnuplot $audace(rep_images)/${fichier_nm}.gp } ]
      ::console::affiche_resultat "Export Gnuplot (0=OK) : $answer\n"
   } else {
      set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/${fichier_nm}.gp } ]
      ::console::affiche_resultat "Export Gnuplot (0=OK) : $answer\n"
   }

   ::console::affiche_resultat "Graphique sauvé sous ${fichier_nm}.png\n"
   return ${fichier_nm}.png
}
####################################################################


####################################################################
#  Procedure de conversion de fichier profil de raie calibré .dat en .ps
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 25-02-2011
# Date modification : 25-02-2011
# Arguments : fichier .dat du profil de raie, titre, ?xdeb, xfin?
####################################################################

proc spc_txt2ps { args } {
   global audace spcaudace
   global conf
   global tcl_platform

   set nbargs [ llength $args ]
   if { $nbargs==4 } {
      set fichier [ lindex $args 0 ]
      set titre [ lindex $args 1 ]
      set legendex [ lindex $args 2 ]
      set legendey [ lindex $args 3 ]
      set joined "o"
      set xdeb "*"
      set xfin "*"
      set ydeb "*"
      set yfin "*"
   } elseif { $nbargs==5 } {
      set fichier [ lindex $args 0 ]
      set titre [ lindex $args 1 ]
      set legendex [ lindex $args 2 ]
      set legendey [ lindex $args 3 ]
      set joined [ lindex $args 4 ]
      set xdeb "*"
      set xfin "*"
      set ydeb "*"
      set yfin "*"
   } elseif { $nbargs==7 } {
      set fichier [ lindex $args 0 ]
      set titre [ lindex $args 1 ]
      set legendex [ lindex $args 2 ]
      set legendey [ lindex $args 3 ]
      set joined [ lindex $args 4 ]
      set xdeb [ lindex $args 5 ]
      set xfin [ lindex $args 6 ]
      set ydeb "*"
      set yfin "*"
   } elseif { $nbargs==9 } {
      set fichier [ lindex $args 0 ]
      set titre [ lindex $args 1 ]
      set legendex [ lindex $args 2 ]
      set legendey [ lindex $args 3 ]
      set joined [ lindex $args 4 ]
      set xdeb [ lindex $args 5 ]
      set xfin [ lindex $args 6 ]
      set ydeb [ lindex $args 7 ]
      set yfin [ lindex $args 8 ]
   } else {
      ::console::affiche_erreur "Usage: spc_txt2ps fichier_data \"Titre\" \"Légende axe x\" \"Légende axe y\" ?joined_points (o/n)? ?xdébut xfin? ?ydeb yfin?\n"
      return ""
   }

   #--- Recherche de xdeb et xfin :
   if { $nbargs<=5 } {
      set fileid [ open "$audace(rep_images)/$fichier" r+ ]
      set contents [ split [read $fileid] \n]
      close $fileid
      set abscisses [ list ]
      foreach ligne $contents {
         set abscisse [ lindex $ligne 0 ]
         if { $abscisse!="" } { lappend abscisses $abscisse }
      }
      set xfin1 [ lindex $abscisses [ expr [ llength $abscisses ]-1 ] ]
      set abscisses [ lsort -dictionary -increasing $abscisses ]
      set xdeb [ lindex $abscisses 0 ]
      if { $xdeb=="" } { set xdeb [ lindex $abscisses 1 ] }
      set xfin [ lindex $abscisses [ expr [ llength $abscisses ]-1 ] ]
      if { $xfin=="" } {
         set xfin $xfin1
      } elseif { $xfin1<$xfin } { set xfin $xfin }
      #::console::affiche_resultat "Xdeb=$xdeb ; Xfin=$xfin\n"
   }

   #--- Créée le fichier script pour gnuplot :
   set fichier_nm [ file rootname $fichier ]
   set file_id [open "$audace(rep_images)/${fichier_nm}.gp" w+]
   if { $joined=="n" } {
      puts $file_id "call \"$spcaudace(repgp)/gp_pointsps.cfg\" \"$audace(rep_images)/$fichier\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/${fichier_nm}.ps\" \"$legendex\" \"$legendey\" "
   } else {
      puts $file_id "call \"$spcaudace(repgp)/gp_dataps.cfg\" \"$audace(rep_images)/$fichier\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/${fichier_nm}.ps\" \"$legendex\" \"$legendey\" "
   }
   close $file_id

   #--- Détermine le chemin de l'executable Gnuplot selon le système d'exploitation :
   if { $tcl_platform(platform)=="unix" } {
      set answer [ catch { exec gnuplot $audace(rep_images)/${fichier_nm}.gp } ]
      ::console::affiche_resultat "Export Gnuplot (0=OK) : $answer\n"
   } else {
      set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/${fichier_nm}.gp } ]
      ::console::affiche_resultat "Export Gnuplot (0=OK) : $answer\n"
   }

   ::console::affiche_resultat "Graphique sauvé sous ${fichier_nm}.ps\n"
   return ${fichier_nm}.ps
}
####################################################################


####################################################################
#  Procedure de conversion de fichier profil de raie calibré .dat en .ps
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 3-04-2011
# Date modification : 3-04-2011
# Arguments : fichier .dat du profil de raie, titre, ?xdeb, xfin?
####################################################################

proc spc_txt2pserr { args } {
   global audace spcaudace
   global conf
   global tcl_platform

   set nbargs [ llength $args ]
   if { $nbargs==4 } {
      set fichier [ lindex $args 0 ]
      set titre [ lindex $args 1 ]
      set legendex [ lindex $args 2 ]
      set legendey [ lindex $args 3 ]
      set xdeb "*"
      set xfin "*"
      set ydeb "*"
      set yfin "*"
   } elseif { $nbargs==6 } {
      set fichier [ lindex $args 0 ]
      set titre [ lindex $args 1 ]
      set legendex [ lindex $args 2 ]
      set legendey [ lindex $args 3 ]
      set xdeb [ lindex $args 4 ]
      set xfin [ lindex $args 5 ]
      set ydeb "*"
      set yfin "*"
   } elseif { $nbargs==8 } {
      set fichier [ lindex $args 0 ]
      set titre [ lindex $args 1 ]
      set legendex [ lindex $args 2 ]
      set legendey [ lindex $args 3 ]
      set xdeb [ lindex $args 4 ]
      set xfin [ lindex $args 5 ]
      set ydeb [ lindex $args 6 ]
      set yfin [ lindex $args 7 ]
   } else {
      ::console::affiche_erreur "Usage: spc_txt2pserr fichier_data \"Titre\" \"Légende axe x\" \"Légende axe y\" ?xdébut xfin? ?ydeb yfin?\n"
      return ""
   }

   #--- Recherche de xdeb et xfin :
   if { $nbargs<=4 } {
      set fileid [ open "$audace(rep_images)/$fichier" r+ ]
      set contents [ split [read $fileid] \n]
      close $fileid
      set abscisses [ list ]
      foreach ligne $contents {
         set abscisse [ lindex $ligne 0 ]
         if { $abscisse!="" } { lappend abscisses $abscisse }
      }
      set xfin1 [ lindex $abscisses [ expr [ llength $abscisses ]-1 ] ]
      set abscisses [ lsort -dictionary -increasing $abscisses ]
      set xdeb [ lindex $abscisses 0 ]
      if { $xdeb=="" } { set xdeb [ lindex $abscisses 1 ] }
      set xfin [ lindex $abscisses [ expr [ llength $abscisses ]-1 ] ]
      if { $xfin=="" } {
         set xfin $xfin1
      } elseif { $xfin1<$xfin } { set xfin $xfin }
      #::console::affiche_resultat "Xdeb=$xdeb ; Xfin=$xfin\n"
   }

   #--- Créée le fichier script pour gnuplot :
   set fichier_nm [ file rootname $fichier ]
   set file_id [open "$audace(rep_images)/${fichier_nm}_werr.gp" w+]
   puts $file_id "call \"$spcaudace(repgp)/gp_points_err_ps.cfg\" \"$audace(rep_images)/$fichier\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/${fichier_nm}_werr.ps\" \"$legendex\" \"$legendey\" "
   close $file_id

   #--- Détermine le chemin de l'executable Gnuplot selon le système d'exploitation :
   if { $tcl_platform(platform)=="unix" } {
      set answer [ catch { exec gnuplot $audace(rep_images)/${fichier_nm}_werr.gp } ]
      ::console::affiche_resultat "Export Gnuplot (0=OK) : $answer\n"
   } else {
      set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/${fichier_nm}werr.gp } ]
      ::console::affiche_resultat "Export Gnuplot (0=OK) : $answer\n"
   }

   ::console::affiche_resultat "Graphique sauvé sous ${fichier_nm}_werr.ps\n"
   return ${fichier_nm}_werr.ps
}
####################################################################



####################################################################
#  Procedure de conversion de fichier profil de raie .dat en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 27-04-2006
# Date modification : 26-04-2006
# Arguments : fichier .dat du profil de raie, légende axe X, légende axe Y, pas
####################################################################

proc spc_dat2pngman { args } {
    global audace spcaudace
    global conf

    if { [llength $args] == 5 } {
        set fichier [ lindex $args 0 ]
        set titre [ lindex $args 1 ]
        set legendex [ lindex $args 2 ]
        set legendey [ lindex $args 3 ]
        set pas [ lindex $args 4 ]

        # Retire l'extension .fit du nom du fichier
        set spcfile [ file rootname $fichier ]

        #--- Prepare le script pour gnuplot
        set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
        put $file_id "call \"$spcaudace(repgp)/gp_spc.cfg\" \"${spcfile}$spcaudace(extdat)\" \"$titre\" * * * * $pas \"${spcfile}.png\" \"$legendex\" \"$legendey\" "
        close $file_id

        #--- Execute Gnuplot pour l'export en png
        if { $tcl_platform(platform)=="unix" } {
            set answer [ catch { exec gnuplot $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "$answer\n"
        } else {
            set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "$answer\n"
        }
        ::console::affiche_resultat "Profil de raie exporté sous ${spcfile}.png\n"
        return ${spcfile}.png
   } else {
       ::console::affiche_erreur "Usage: spc_dat2pngman fichier_fits \"titre\" \"légende_axeX\" \"légende_axeY\" intervalle_graduations\n\n"
   }
}
####################################################################




###################################################################
#  Procedure de conversion de fichier profil de raies .spc (VisualSpec) en .fit
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 09-12-2005
# Date modification : 09-12-2005
# Arguments : fichier .spc du profil de raie
###################################################################
proc spc_spc2fits { args } {

 global conf spcaudace
 global audace caption
 #global profilspc
 global caption
 global colorspc

#    set profilspc(xunit) "Position"
#    set profilspc(yunit) "ADU"



 if {[llength $args] <= 1} {
     if {[llength $args] == 1} {
         set filenamespc [ lindex $args 0 ]
     } elseif { [llength $args]==0 } {
         # set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
         set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "SPC file" "$spcaudace(extvspec)"] ] -initialdir $audace(rep_images) ] ] ]
         if { [ file exists "$audace(rep_images)/$spctrouve$spcaudace(extvspec)" ] == 1 } {
             set filenamespc "$spctrouve$spcaudace(extvspec)"
         } else {
             ::console::affiche_erreur "Usage: spc_spc2fits fichier_spc\n\n"
             return 0
         }
     } else {
             ::console::affiche_erreur "Usage: spc_spc2fits fichier_spc\n\n"
             return 0
     }

    ## === Lecture du fichier de donnees du profil de raie ===
    catch {unset profilspc} {}
    set profilspc(initialdir) [file dirname $audace(rep_images)]
    set profilspc(initialfile) [file tail $filenamespc]
    set input [open "$audace(rep_images)/$filenamespc" r]

    #--- Charge le contenu du fichier et enleve l'entête
    #-- Retourne une chaîne
    set contents [split [read $input] \n]
    close $input
    set profilspc(naxis1) [expr [lindex $contents 2]]
    set profilspc(exptime) [expr [lindex $contents 2]]
    set dateobs [lindex $contents 4]
    set profilspc(object) [lindex $contents 7]

    #-- Initialise les longueurs :
    #set offset [expr [lindex $contents 1]+3]
    set offset [expr [lindex $contents 1]+15]
    set len $profilspc(naxis1)
    ## === Extraction des numeros des pixels et des intensites ===
    for {set k 1} {$k <= $profilspc(naxis1)} {incr k} {
       set ligne [lindex $contents $offset]
       append profilspc(pixels) "[lindex $ligne 1] "
       append profilspc(intensite) "[lindex $ligne 2] "
       #append profilspc(argon1) "[lindex $ligne 3] "
       #append profilspc(argon2) "[lindex $ligne 4] "
       #append profilspc(noir) "[lindex $ligne 5] "
       #append profilspc(repere) "[lindex $ligne 6] "
       incr offset
    }


    #--- Initialisation à blanc d'un fichier fits
    buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_FLOAT COMPRESS_NONE 0
    buf$audace(bufNo) setkwd [ list "NAXIS" 1 int "" "" ]
    buf$audace(bufNo) setkwd [ list "NAXIS1" $len int "" "" ]
    set crpix1 1
    buf$audace(bufNo) setkwd [ list "CRPIX1" $crpix1 double "Reference pixel" "pixel" ]


    #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
    #-- Une liste commence à 0 ; Un vecteur fits commence à 1
    set intensite 0
    for {set k 0} {$k<$len} {incr k} {
       append intensite [lindex $profilspc(intensite) $k]
       #-- Vérifie que l'intensité est bien un nombre
       if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {
          buf$audace(bufNo) setpix [list [expr $k+1] 1] $mintensite
          set intensite 0
       }
    }

    #--- Calcule la loi de calibration supposée linéaire :
    set lambdadeb [ expr 1.0*[ lindex $profilspc(pixels) 0 ] ]
    set lambdafin [ expr 1.0*[ lindex $profilspc(pixels) [ expr $len-1 ] ] ]
    set dispersion [ expr 1.0*($lambdafin-$lambdadeb)/($len-1) ]
    ::console::affiche_resultat "Xdep=$lambdadeb ; Xfin=$lambdafin ; Dispersion=$dispersion\n"


    #------- Affecte une valeur aux mots cle liés à la spectroscopie ----------
    #- Modele :  buf$audace(bufNo) setkwd [list "INSTRU" "T310" string "mon télescope" ""]
    buf$audace(bufNo) setkwd [list "OBJNAME" "$profilspc(object)" string "" ""]
    buf$audace(bufNo) setkwd [list "DATE-OBS" "$dateobs" string "" ""]
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambdadeb double "Wavelength at reference pixel" "angstrom"]
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion double "Wavelength increment" "angstrom/pixel"]

    #--- Sauve le fichier fits ainsi constitué
    buf$audace(bufNo) bitpix float
    set filename [file root $filenamespc]
    buf$audace(bufNo) save "$audace(rep_images)/${filename}$conf(extension,defaut)"
    buf$audace(bufNo) bitpix short
    ::console::affiche_resultat "$len lignes affectées\n"
    ::console::affiche_resultat "Fichier spc exporté sous ${filename}$conf(extension,defaut)\n"
    return "$filename"
 } else {
   ::console::affiche_erreur "Usage: spc_spc2fits fichier_spc\n\n"
 }
}
#****************************************************************#



###################################################################
#  Procedure de conversion d'une série defichiers profil de raies .spc (VisualSpec) en .fit
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 09-12-2005
# Date modification : 02-04-2006
# Arguments : répertoire contenant les fichiers .spc
###################################################################
proc spc_spcs2fits { args } {

    global conf
    global audace spcaudace


    if {[llength $args] == 1} {
        set repertoire [ lindex $args 0 ]
        set rep_img_dflt $audace(rep_images)
        set rep_courant [ pwd ]
        set audace(rep_images) $repertoire
        cd $repertoire
        set liste_fichiers [ lsort -dictionary [ glob *$spcaudace(extvspec) ] ]
        foreach fichier $liste_fichiers {
            ::console::affiche_resultat "$fichier\n"
            spc_spc2fits $fichier
            ::console::affiche_resultat "\n"
        }
        set audace(rep_images) $rep_img_dflt
        cd $rep_courant
    } else {
        ::console::affiche_erreur "Usage: spc_spcs2fits chemin_du_répertoire\n\n"
    }
}
###########################################################################


###################################################################
# Procedure de conversion d'une série de fichiers profil de raies .dat en .fit
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 02-04-2006
# Date modification : 02-04-2006
# Arguments : répertoire contenant les fichiers .dat
###################################################################
proc spc_dats2fits { args } {

    global conf
    global audace spcaudace

    if {[llength $args] == 1} {
        set repertoire [ lindex $args 0 ]
        set rep_img_dflt $audace(rep_images)
        set rep_courant [ pwd ]
        set audace(rep_images) $repertoire
        cd $repertoire
        set liste_fichiers [ lsort -dictionary [ glob *$spcaudace(extdat) ] ]
        foreach fichier $liste_fichiers {
            ::console::affiche_resultat "$fichier\n"
            spc_dat2fits $fichier
            ::console::affiche_resultat "\n"
        }
        set audace(rep_images) $rep_img_dflt
        cd $rep_courant
    } else {
        ::console::affiche_erreur "Usage: spc_dats2fits chemin_du_répertoire\n\n"
    }
}
#**********************************************************************************#



###################################################################
# Lecture des fichiers contenant le nom et la longueur d'onde d'especes chimiques
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 17-09-2006
# Date modification : 04-06-2011
# Arguments : aucun
###################################################################
proc spc_readchemfiles { args } {

    global conf
    global audace spcaudace
    set extdata ".txt"
    set fileelements "stellar_lines.txt"
    set fileneon "neon.txt"
    set fileeau "h2o.txt"
    set fileargon "argon.txt"
    set listefichierschem [ list stellar_lines.txt h2o.txt argon.txt neon.txt ]

    set nbargs [ llength $args ]
    if { $nbargs==1 } {
       set fichierchem [ lindex $args 0 ]

       #--- Lecture du fichier des raies stellaires
       if { [ file exists "$spcaudace(repchimie)/$fichierchem" } {
          set input [ open "$spcaudace(repchimie)/$fichierchem" r ]
          set contents [split [read $input] \n]
          close $input
          set listelambdaschem ""
          foreach ligne $contents {
             set element [ lindex $ligne 0 ]
             set lambda [ lindex $ligne 1 ]
             append listelambdaschem "$element:$lambda "
             # lappend listelambdaschem "$ligne"
          }
       }

       #--- Fin du script :
       set listelambdaschem [ split $listelambdaschem " " ]
       return $listelambdaschem
    } elseif { $nbargs==0 } {
       set listelambdaschem ""
       foreach fichier $listefichierschem {
          set input [ open "$spcaudace(repchimie)/$fichier" r ]
          set contents [split [read $input] \n]
          close $input
          foreach ligne $contents {
             set element [ lindex $ligne 0 ]
             set lambda [ lindex $ligne 1 ]
             append listelambdaschem "$element:$lambda "
             # lappend listelambdaschem "$ligne"
          }
       }

       #--- Fin du script :
       set listelambdaschem [ split $listelambdaschem " " ]
       return $listelambdaschem
    } else {
       ::console::affiche_erreur "Usage: spc_readchemfiles ?fichier_texte_catalogue_chimique?\n"
       return ""
    }
}
#**********************************************************************************#




###################################################################
# Export en png et ps de profil avec légende automatique
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 3-01-2007
# Date modification : 3-01-2007
# Arguments : fichier_config_matérielle.txt profil_de_raies_à_tracer \"Nom objet\" ?[[?xdeb xfin?] ?ydeb yfin?]?
###################################################################

proc spc_autofit2png { args } {

    global conf
    global audace

    set labely "Relative flux"
    set extimg ".png"

    set nbargs [ llength $args ]
    if { $nbargs==2 || $nbargs==4 || $nbargs==6 || $nbargs==7 } {
        if { $nbargs==2 } {
            set spectre [ file rootname [ lindex $args 0 ] ]
            set nom_objet [ lindex $args 1 ]
            set xdeb "*"
            set xfin "*"
            set ydeb "*"
            set yfin "*"
            set flagjpeg 0
        } elseif { $nbargs==4 } {
            set spectre [ file rootname [ lindex $args 0 ] ]
            set nom_objet [ lindex $args 1 ]
            set xdeb [ lindex $args 2 ]
            set xfin [ lindex $args 3 ]
            set ydeb "*"
            set yfin "*"
            set flagjpeg 0
        } elseif { $nbargs==6 } {
            set spectre [ file rootname [ lindex $args 0 ] ]
            set nom_objet [ lindex $args 1 ]
            set xdeb [ lindex $args 2 ]
            set xfin [ lindex $args 3 ]
            set ydeb [ lindex $args 4 ]
	    if { $ydeb<0 } { set ydeb "*" }
            set yfin [ lindex $args 5 ]
            set flagjpeg 0
        } elseif { $nbargs==7 } {
            set spectre [ file rootname [ lindex $args 0 ] ]
            set nom_objet [ lindex $args 1 ]
            set xdeb [ lindex $args 2 ]
            set xfin [ lindex $args 3 ]
            set ydeb [ lindex $args 4 ]
	    if { $ydeb<0 } { set ydeb "*" }
            set yfin [ lindex $args 5 ]
            set flagjpeg [ lindex $args 6 ]
        } else {
            ::console::affiche_erreur "Usage: spc_autofit2png profil_de_raies_à_tracer \"Nom objet\" ??xdeb xfin? ?ydeb yfin? ?jpeg?\n\n"
            return 0
        }

        #--- Liste les mots de l'entête fits :
        buf$audace(bufNo) load "$audace(rep_images)/$spectre"
        set listemotsclef [ buf$audace(bufNo) getkwds ]

        #--- Détermination du télescope :
        if { [ lsearch $listemotsclef "TELESCOP" ] !=-1 } {
            set telescope [ lindex [ buf$audace(bufNo) getkwd "TELESCOP" ] 1 ]
            set telescope [ string trim $telescope " " ]
        } else {
            set telescope  "Telescope"
        }

        #--- Détermination de l'équipement spectroscopique :
        if { [ lsearch $listemotsclef "EQUIPMEN" ] !=-1 } {
            set equipement [ lindex [ buf$audace(bufNo) getkwd "EQUIPMEN" ] 1 ]
            set equipement [ string trim $equipement " " ]
        } else {
            set equipement  "Spectrographe"
        }

        #--- Détermination de l'équipement :
        if { $telescope=="Telescope" && $equipement=="Spectrographe" && [ lsearch $listemotsclef "BSS_INST" ] !=-1 } {
          set equipement [ lindex [ buf$audace(bufNo) getkwd "BSS_INST" ] 1 ]
        }

        #--- Détermination de la date de prise de vue : $cdfrac/$mo/$y
        if { [ lsearch $listemotsclef "DATE-OBS" ] !=-1 } {
           set ladate [ spc_datefrac $spectre ]
           #-- Impose 3 decimales a la fraction de jour :
           regexp {([0-9]+\.[0-9]+)/.+} $ladate match fracjour
           set fracjour [ format "%2.4f" $fracjour ]
           regexp {[0-9]+\.[0-9]+(/.+)} $ladate match restedate
           set ladate "$fracjour$restedate"
        }

        #--- Détermination des paramètres d'exposition :
        #-- Recherche du nombre d'occurence du nombre "99" dans un des mots clefs TT :
       if { [ lsearch $listemotsclef "SPC_NBF" ] !=-1 } {
          set nombre_poses [ lindex [ buf$audace(bufNo) getkwd "SPC_NBF" ] 1 ]
       } else {
          set nombre_poses 0
          if { $nombre_poses == 0 } {
             foreach mot $listemotsclef {
                set valeur_mot [ lindex [ buf$audace(bufNo) getkwd "$mot" ] 1 ]
                if { [ regexp {\s[0-9]{1,3}\s} $valeur_mot match resul ] } {
                   set nombre_poses [ llength $valeur_mot ]
                }
             }
          }
          if { $nombre_poses == 0 } {
             foreach mot $listemotsclef {
                set valeur_mot [ lindex [ buf$audace(bufNo) getkwd "$mot" ] 1 ]
                if { [ regexp {\s99\s} $valeur_mot match resul ] } {
                   set nombre_poses [ llength $valeur_mot ]
                }
             }
          }
          if { $nombre_poses == 0 } {
             foreach mot $listemotsclef {
		set valeur_mot [ lindex [ buf$audace(bufNo) getkwd "$mot" ] 1 ]
		if { [ regexp {\s[8-9]\s} $valeur_mot match resul ] } {
		    set nombre_poses [ llength $valeur_mot ]
		}
             }
          }
          if { $nombre_poses == 0 } {
             foreach mot $listemotsclef {
		set valeur_mot [ lindex [ buf$audace(bufNo) getkwd "$mot" ] 1 ]
		if { [ regexp {\s[1-9][1-9]\s} $valeur_mot match resul ] } {
		    set nombre_poses [ llength $valeur_mot ]
		}
             }
          }
        }

        #-- Recherche de la duree totale :
        #- EXPOSURE : est sensé contenir la durée d'une pose unitaire * nb poses  -> duree_exposition
       #- EXPTIME  : est sensé contenir la durée totale d'observation -> duree_totale
       #- Donc : dans spc_somme, tester dans un pretraite unitaire la presencede EXPOSURE, sinon prendre EXPTIME
#       ::console::affiche_prompt "ICI\n"
        if { [ lsearch $listemotsclef "EXPOSURE" ] !=-1 } {
           set duree_exposition [ format "%4.1f" [ lindex [ buf$audace(bufNo) getkwd "EXPOSURE" ] 1 ] ]
           if { [ lsearch $listemotsclef "EXPTIME" ] !=-1 } {
              #-- Usuellement, EXPTIME est le mot clef BESS : total duration.
              set duree_totale [ format "%4.1f" [ lindex [ buf$audace(bufNo) getkwd "EXPTIME" ] 1 ] ]
              set diff_exp [ expr $duree_totale-$duree_exposition ]
              #-- Cas incoherant ou EXPOSURE est mal renseigne :
              if { $duree_totale<$duree_exposition } {
                 set duree_exposition_buff $duree_exposition
                 set duree_exposition $duree_totale
                 set duree_totale $duree_exposition_buff
              }
              if { $diff_exp<[ expr 0.05*$duree_totale ] && $diff_exp>0 && $nombre_poses!=0 } {
                 set duree_exposition [ format "%4.1f" [ expr $duree_exposition/$nombre_poses ] ]
              }
           } else {
              set duree_totale [ expr $nombre_poses*$duree_exposition ]   
           }
        } else {
           #-- EXPOSURE non renseigné ! :
           if { [ lsearch $listemotsclef "EXPTIME" ] !=-1 } {
              set duree_totale [ expr round([ lindex [ buf$audace(bufNo) getkwd "EXPTIME" ] 1 ]) ]
              if { $nombre_poses!=0 } {
                 set duree_exposition [ format "%4.1f" [ expr $duree_totale/$nombre_poses ] ]
              }
           } else {
              #-- EXPOSURE et EXPTIME non renseignés ! :
              set duree_totale 0.
              set duree_exposition 0.
           }
        }



        #--- Récupération de la dispersion :
        set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
        if { [ lsearch $listemotsclef "CDELT1" ] !=-1 && [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
            set flag_cal 1
            if { $nbargs==2 } {
               set xdeb [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            }
            if { $xdeb != 1. } {
               set dispersion_precise [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
               set dispersion [ format "%3.4f" [ expr round($dispersion_precise*10000.)/10000. ] ]
               if { $nbargs==2 } {
                  set xfin [ spc_calpoly $naxis1 1 $xdeb $dispersion_precise 0 0 ]
               }
               #set labelx "Wavelength (Å)"
               set labelx "Wavelength (Å)"
            } else {
               set dispersion 0
               if { $nbargs==2 } {
                 set xfin $naxis1
               }
               set labelx "Position (pixel)"
            }
        } else {
           set flag_cal 0
           set dispersion 0
           if { $nbargs==2 } {
              set xfin $naxis1
           }
           set labelx "Position (pixel)"
        }

        #--- Conversion des "_" en espace pour le titre du graphique :
        if { [ regsub -all {(_)} "$nom_objet" " " resul ]>=1 } {
            set nom_objet "$resul"
        }

       
        #--- Suppression des accents dans les variables :
        set nom_objet [ suppr_accents $nom_objet ]
        set telescope [ suppr_accents $telescope ]
        set equipement [ suppr_accents $equipement ]
        if { $telescope=="Telescope" && $equipement!="Spectrographe" } {
           set matos "$equipement"
        } else {
           set matos "$telescope + $equipement"
        }


        #--- Élaboration du titre du graphique :
        if { $dispersion == 0.0 } {
            if { $nombre_poses==0 || $nombre_poses=="" } {
                set titre_graphique "$nom_objet - $ladate - $matos - $duree_totale s"
            } else {
                #set duree_exposition [ expr int($duree_totale/$nombre_poses) ]
                set titre_graphique "$nom_objet - $ladate - $matos - ${nombre_poses}x$duree_exposition s"
            }
        } else {
            if { $nombre_poses == 0 || $nombre_poses=="" } {
                set titre_graphique "$nom_objet - $ladate - $matos - $dispersion Å/pixel - $duree_totale s"
            } else {
                #set duree_exposition [ expr int($duree_totale/$nombre_poses) ]
                set titre_graphique "$nom_objet - $ladate - $matos - $dispersion Å/pixel - ${nombre_poses}x$duree_exposition s"
            }
        }

        #--- Tracé du graphique :
       set largeur [ expr $xfin-$xdeb ]
       #----------------------------------------------------------------#
       if { 1==0 } {
       if { $naxis1<=3500 } {
          if { $largeur<=2000 && $flag_cal==1 } {
             set fileout [ spc_fit2pngopt "$spectre" "$titre_graphique" "$labelx" "$labely" $xdeb $xfin $ydeb $yfin ]
          } elseif { $largeur>2000 && $flag_cal==1 } {
             set fileout [ spc_fit2pnglarge "$spectre" "$titre_graphique" "$labelx" "$labely" $xdeb $xfin $ydeb $yfin ]
          } elseif { $flag_cal==0 } {
             set fileout [ spc_fit2pngopt "$spectre" "$titre_graphique" "$labelx" "$labely" $xdeb $xfin $ydeb $yfin ]
          }
       } else {
		  if { $dispersion>=2 } {
	         set fileout [ spc_fit2pnglarge "$spectre" "$titre_graphique" "$labelx" "$labely" $xdeb $xfin $ydeb $yfin ]
	      } else {
             set fileout [ spc_fit2pngopt "$spectre" "$titre_graphique" "$labelx" "$labely" $xdeb $xfin $ydeb $yfin ]
	      }
       }
       }
       #-----------------------------------------------------#

       if { $flag_cal==1 } {
          if { $largeur<=1000 } {
             if { $dispersion<=0.4 } {
                set fileout [ spc_fit2pngopt "$spectre" "$titre_graphique" "$labelx" "$labely" $xdeb $xfin $ydeb $yfin ]
                if { $flagjpeg=="jpeg" } { set fileout_jpg [ spc_fit2tnjpg "$spectre" "$titre_graphique" "$labelx" "$labely" $xdeb $xfin $ydeb $yfin ] }
             } else {
                set fileout [ spc_fit2pnglarge "$spectre" "$titre_graphique" "$labelx" "$labely" $xdeb $xfin $ydeb $yfin ]
             }
          } elseif { $naxis1>=10000 && $dispersion<=0.2 } {
             set fileout [ spc_fit2pngvlarge "$spectre" "$titre_graphique" "$labelx" "$labely" $xdeb $xfin $ydeb $yfin ]
          } else {
             set fileout [ spc_fit2pnglarge "$spectre" "$titre_graphique" "$labelx" "$labely" $xdeb $xfin $ydeb $yfin ]
          }
       } else {
          if { $naxis1<=3500 } {
             set fileout [ spc_fit2pngopt "$spectre" "$titre_graphique" "$labelx" "$labely" $xdeb $xfin $ydeb $yfin ]
             if { $flagjpeg=="jpeg" } { set fileout_jpg [ spc_fit2tnjpg "$spectre" "$titre_graphique" "$labelx" "$labely" $xdeb $xfin $ydeb $yfin ] }
          } else {
             set fileout [ spc_fit2pnglarge "$spectre" "$titre_graphique" "$labelx" "$labely" $xdeb $xfin $ydeb $yfin ]
          }
       }

        #--- Fabrication de la date du fichier :
        set datefile [ spc_datefile $spectre ]

        #--- Fabrication du nom de fichier graphique (pas d'espace...) :
        set nom_objet_lower [ string tolower "$nom_objet" ]
        if { [ regsub -all {(\s)} "$nom_objet_lower" "_" resul ]>=1 } {
            set nom_sans_espaces "$resul"
        } else {
            set nom_sans_espaces "$nom_objet_lower"
        }
        #if { [ regexp {.+(\.[a-zA-Z]{3})} "$fileout" match extimg ] } 
        if { [ file exists "$audace(rep_images)/$fileout" ] } {
           file rename -force "$audace(rep_images)/$fileout" "$audace(rep_images)/${nom_sans_espaces}_$datefile$extimg"
           if { $flagjpeg=="jpeg" } { file rename -force "$audace(rep_images)/$fileout_jpg" "$audace(rep_images)/${nom_sans_espaces}_${datefile}.jpg" }
        } else {
           ::console::affiche_erreur "Echec de l'exportation en PNG. Vérifiez l'absence d'espaces et d'accents dans les noms de fichiers et de répertoires.\n"
           return 0
        }

        #--- Fin du script :
        file copy -force "$audace(rep_images)/$spectre$conf(extension,defaut)" "$audace(rep_images)/${nom_sans_espaces}_$datefile$conf(extension,defaut)"
        return "${nom_sans_espaces}_$datefile$extimg"
    } else {
        ::console::affiche_erreur "Usage: spc_autofit2png profil_de_raies_à_tracer \"Nom objet\" ??xdeb xfin? ?ydeb yfin? ?jpeg??\n\n"
    }
}
#**********************************************************************************#



###################################################################
# Export en png et ps de profil avec légende automatique
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 3-01-2007
# Date modification : 3-01-2007
# Arguments : fichier_config_matérielle.txt profil_de_raies_à_tracer \"Nom objet\" ?[[?xdeb xfin?] ?ydeb yfin?]?
###################################################################

proc spc_autofit2pngps { args } {

    global conf
    global audace

    set labelx "Wavelength (Å)"
    set labely "Relative flux"

    if { [ llength $args ]==2 || [llength $args ]==4 || [llength $args ]==6 } {
        if { [ llength $args ] == 2 } {
            set spectre [ file rootname [ lindex $args 0 ] ]
            set nom_objet [ lindex $args 1 ]
            set xdeb "*"
            set xfin "*"
            set ydeb "*"
            set yfin "*"
        } elseif { [ llength $args ] == 4 } {
            set spectre [ file rootname [ lindex $args 0 ] ]
            set nom_objet [ lindex $args 1 ]
            set xdeb [ lindex $args 2 ]
            set xfin [ lindex $args 3 ]
            set ydeb "*"
            set yfin "*"
        } elseif { [ llength $args ] == 6 } {
            set spectre [ file rootname [ lindex $args 0 ] ]
            set nom_objet [ lindex $args 1 ]
            set xdeb [ lindex $args 2 ]
            set xfin [ lindex $args 3 ]
            set ydeb [ lindex $args 4 ]
	    if { $ydeb<0 } { set ydeb "*" }
            set yfin [ lindex $args 5 ]
        } else {
            ::console::affiche_erreur "Usage: spc_autofit2png profil_de_raies_à_tracer \"Nom objet\" ?[[?xdeb xfin?] ?ydeb yfin?]?\n\n"
            return 0
        }

        #--- Liste les mots de l'entête fits :
        buf$audace(bufNo) load "$audace(rep_images)/$spectre"
        set listemotsclef [ buf$audace(bufNo) getkwds ]


        #--- Détermination du télescope :
        if { [ lsearch $listemotsclef "TELESCOP" ] !=-1 } {
            set telescope [ lindex [ buf$audace(bufNo) getkwd "TELESCOP" ] 1 ]
        } else {
            set telescope  "Télescope"
        }

        #--- Détermination de l'équipement spectroscopique :
        if { [ lsearch $listemotsclef "EQUIPMEN" ] !=-1 } {
            set equipement [ lindex [ buf$audace(bufNo) getkwd "EQUIPMEN" ] 1 ]
        } else {
            set equipement  "Spectrescope reseau"
        }


        #--- Détermination de la date de prise de vue :
        if { [ lsearch $listemotsclef "DATE-OBS" ] !=-1 } {
            set ladate [ spc_datefrac $spectre ]
        }

        #--- Détermination des paramètres d'exposition :
        if { [ lsearch $listemotsclef "EXPOSURE" ] !=-1 } {
            set duree_totale [ expr round([ lindex [ buf$audace(bufNo) getkwd "EXPOSURE" ] 1 ]) ]
        } else {
            set duree_totale [ expr round([ lindex [ buf$audace(bufNo) getkwd "EXPTIME" ] 1 ]) ]
        }
        #-- Recherche du nombre d'occurence du nombre "99" dans un des mots clefs TT :
        set nombre_poses 0
        foreach mot $listemotsclef {
            set valeur_mot [ lindex [ buf$audace(bufNo) getkwd "$mot" ] 1 ]
            if { [ regexp {\s99\s} $valeur_mot match resul ] } {
                set nombre_poses [ llength $valeur_mot ]
            }
        }

        #--- Récupération de la dispersion :
        if { [ lsearch $listemotsclef "CDELT1" ] !=-1 && [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
            if { [ llength $args ] == 3 } {
                set xdeb [  lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            }
            if { $xdeb != 1. } {
                set dispersion_precise [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
                set dispersion [ expr round($dispersion_precise*1000.)/1000. ]
            } else {
                set dispersion 0
            }
        } else {
            set dispersion 0
        }

        #--- Suppression des accents dans les variables :
        set nom_objet [ suppr_accents $nom_objet ]
        set telescope [ suppr_accents $telescope ]
        set equipement [ suppr_accents $equipement ]


        #--- Élaboration du titre du graphique :
        if { $dispersion == 0.0 } {
            if { $nombre_poses == 0 } {
                set titre_graphique "$nom_objet - $ladate - $telescope + $equipement - $duree_totale s"
            } else {
                set duree_exposition [ expr int($duree_totale/$nombre_poses) ]
                set titre_graphique "$nom_objet - $ladate - $telescope + $equipement - ${nombre_poses}x$duree_exposition s"
            }
        } else {
            if { $nombre_poses == 0 } {
                set titre_graphique "$nom_objet - $ladate - $telescope + $equipement - $dispersion Å/pixel - $duree_totale s"
            } else {
                set duree_exposition [ expr int($duree_totale/$nombre_poses) ]
                set titre_graphique "$nom_objet - $ladate - $telescope + $equipement - $dispersion Å/pixel - ${nombre_poses}x$duree_exposition s"
            }
        }

        #--- Tracé du graphique :
        set fileout [ spc_fit2pngopt "$spectre" "$titre_graphique" "$labelx" "$labely" $xdeb $xfin $ydeb $yfin ]

        #--- Fabrication de la date du fichier :
        set datefile [ spc_datefile $spectre ]

        #--- Fabrication du nom de fichier graphique (pas d'espace...) :
        set nom_objet_lower [ string tolower "$nom_objet" ]
        if { [ regsub {(\s)} "$nom_objet_lower" "_" resul ] } {
            set nom_sans_espaces "$resul"
            if { [ regsub {(\s)} "$nom_sans_espaces" "_" resul ] } {
                set nom_sans_espaces "$resul"
                if { [ regsub {(\s)} "$nom_sans_espaces" "_" resul ] } {
                    set nom_sans_espaces "$resul"
                }
            }
        } else {
            set nom_sans_espaces "$nom_objet_lower"
        }
        if { [ regexp {.+(\.[a-zA-Z]{3})} "fileout" match extimg ] } {
            file rename -force "$audace(rep_images)/$fileout" "$audace(rep_images)/${nom_sans_espaces}_$datefile$extimg"
        } else {
            set extimg ".png"
            file rename -force "$audace(rep_images)/$fileout" "$audace(rep_images)/${nom_sans_espaces}_$datefile$extimg"
        }

        #--- Production optionnelle d'un fichier Postscript :
        set fileout2 [ spc_fit2ps "$spectre" "$titre_graphique" "Wavelength (\305)" "$labely" $xdeb $xfin ]
        file rename -force "$audace(rep_images)/$fileout2" "$audace(rep_images)/${nom_sans_espaces}_${datefile}.ps"

        #--- Fin du script :
        file copy -force "$audace(rep_images)/$spectre$conf(extension,defaut)" "$audace(rep_images)/${nom_sans_espaces}_$datefile$conf(extension,defaut)"
        return "${nom_sans_espaces}_$datefile$extimg"
    } else {
        ::console::affiche_erreur "Usage: spc_autofit2pngps profil_de_raies_à_tracer \"Nom objet\" ?[[?xdeb xfin?] ?ydeb yfin?]?\n\n"
    }
}
#**********************************************************************************#




####################################################################
#  Procedure de conversion de fichier profil de raies calibré .fit en .jpeg 2D coloré
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-03-2007
# Date modification : 03-03-2007
# Arguments : fichier .fit du profil_de_raies, ?lambda_deb lambda_fin?
####################################################################

proc spc_fit2colors { args } {
    global audace
    global conf

    set nbargs [ llength $args ]
    if { $nbargs == 1 || $nbargs == 3 } {
        if { $nbargs == 1 } {
            set fichier [ file tail [ file rootname [ lindex $args 0 ] ] ]
        } elseif { $nbargs == 3 } {
            set fichier [ file tail [ file rootname [ lindex $args 0 ] ] ]
            set ldeb [ lindex $args 1 ]
            set lfin [ lindex $args 2 ]
        } else {
            ::console::affiche_erreur "Usage: spc_fit2colors fichier_fits ?lambda_début lambda_fin?\n\n"
            return 0
        }


        #--- Rééchantillonnage linéaire du spectre :
        set spectre_lin [ spc_linearcal "$fichier" ]

        #--- Extraction des mots clés :
        buf$audace(bufNo) load "$audace(rep_images)/$spectre_lin"
        set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
        set crval1 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
        set cdelt1 [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
        set crpix1 [lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1]

        #--- Calcul des paramètres du spectre :
        if { $nbargs==1 } {
            set lfin [ spc_calpoly $naxis1 $crpix1 $crval1 $cdelt1 0 0 ]
            set ldeb $crval1
            set xdeb 1
            set xfin $naxis1
        } elseif { $nbargs==3 } {
            set xdeb [ expr round(($ldeb-$crval1)/$cdelt1+$crpix1) ]
            set xfin [ expr round(($lfin-$crval1)/$cdelt1+$crpix1) ]
            #-- Gestion de mauvais paramètres ldeb, lfin :
            if { $xdeb<=0 || $xfin<=0 } {
                ::console::affiche_resultat "Mauvaises longueurs d'onde données.\n"
                return 0
            }
        }

        #--- Découpage de la zone du spectre :
	set xfinal [ expr $xfin-$xdeb+1 ]
	if { $xdeb>1 || $xfin<$naxis1 } {
	    buf$audace(bufNo) window [ list $xdeb 1 $xfin 1 ]
	}

        #--- Colorisation du spectre :
        # buf$audace(bufNo) imaseries "COLORSPECTRUM wavelengthmin=$ldeb wavelengthmax=$lfin"
        # buf$audace(bufNo) imaseries "COLORSPECTRUM WAVELENGTHMIN=$ldeb WAVELENGTHMAX=$lfin XMIN=$xdeb XMAX=$xfin"
        buf$audace(bufNo) imaseries "COLORSPECTRUM WAVELENGTHMIN=$ldeb WAVELENGTHMAX=$lfin XMIN=1 XMAX=$xfinal"
        # buf$audace(bufNo) scale {1 40} 1
        buf$audace(bufNo) scale { 0.6 40 } 1
        #buf$audace(bufNo) scale { 0.6 40 } 2
        visu1 thickness 80
        #- Seuils -3 ; 70 fcontionne bien.
        ::confVisu::autovisu 1
        #visu1 disp {70 -3}
        ##visu1 cut {90 -10 90 -10 90 -10}
        ##::audace::changeHiCut 70
        ##::audace::changeLoCut -3
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${fichier}_color.jpg"
        buf$audace(bufNo) bitpix short

        #--- Retour du résultat :
	if { "$fichier" != "$spectre_lin" } {
	    file delete "$audace(rep_images)/$spectre_lin$conf(extension,defaut)"
	}
        ::console::affiche_resultat "Profil de raies exporté sous ${fichier}_color.jpg\n"
        return "${fichier}_color.jpg"
    } else {
        ::console::affiche_erreur "Usage: spc_fit2colors fichier_fits ?lambda_début lambda_fin?\n\n"
    }
}
####################################################################



##########################################################
# Effectue l'exportation au format PNG avec génération d'un titre du graphique
# Attention : GUI présente !
# Se sert indirectement de spc_autofit2png
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 05-03-2007
# Date de mise à jour : 05-03-2007
# Arguments : profil_de_raies_fits
##########################################################

proc spc_export2png { args } {

   global audace spcaudace
   global conf tcl_platform
   global caption

   #- nomprofilpng : nom de la variable retournee par la gui param_spc_audace_export2png
   global nomprofilpng

   if { [llength $args] <= 1 } {
       if { [llength $args] == 1 } {
           set spectre [ file rootname [ lindex $args 0 ] ]
       } elseif { [llength $args]==0 } {
           set spectre [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
       } else {
           ::console::affiche_erreur "Usage: spc_export2png ?profil_de_raies_fits?\n\n"
           return 0
       }

       #--- Test d'existence et création des mots clef de l'entête FITS :
       if { [file exists "$audace(rep_images)/$spectre$conf(extension,defaut)" ] == 1 } {
           buf$audace(bufNo) load "$audace(rep_images)/$spectre"
       } else {
           return 0
       }
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       set listevalmots [ list ]
       foreach mot $spcaudace(motsheader) def $spcaudace(motsheaderdef) {
           if { [ lsearch $listemotsclef "$mot" ] !=-1 } {
               lappend listevalmots [ lindex [ buf$audace(bufNo) getkwd "$mot" ] 1 ]
           } else {
               #buf$audace(bufNo) setkwd [list "$mot" "" string "$def" "" ]
               lappend listevalmots ""
           }
       }
       #buf$audace(bufNo) bitpix float
       #buf$audace(bufNo) save "$audace(rep_images)/$spectre"
       #buf$audace(bufNo) bitpix short

       #--- Détermine lambda_min et lambda_max :
       set contenu [ spc_fits2data $spectre ]
       set lambdas [ lindex $contenu 0 ]
       set intensites [ lindex $contenu 1 ]
       set i 1
       set dnaxis1 [ expr int(0.5*[ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]) ]
       foreach lambda $lambdas intensite $intensites {
           if { $intensite!=0. && $i<=$dnaxis1 } {
               set ldeb $lambda
               break
           }
           incr i
       }
       set i 1
       set lfin ""
       foreach lambda $lambdas intensite $intensites {
           if { $intensite==0. && $i>=$dnaxis1 } {
               set lfin [ lindex $lambdas [ expr $i-2 ] ]
               break
           }
           incr i
       }
       if { $lfin=="" } {
           set lfin [ lindex $lambdas [ expr $i-2 ] ]
       }
       set lambdarange [ list $ldeb $lfin ]


       #--- Boîte de dialogue pour saisir les paramètres d'exportation :
       spc_loadfit $spectre
       set listeargs [ list $spectre $lambdarange $listevalmots ]
       set err [ catch {
           ::param_spc_audace_export2png::run $listeargs
           tkwait window .param_spc_audace_export2png
       } msg ]
       if {$err==1} {
           ::console::affiche_erreur "$msg\n"
       }

       set nom_profil [ file tail $nomprofilpng ]
       #--- Affichage du graphe PNG :
       if { $nomprofilpng!="" } {
          loadima "$nom_profil"
          visu1 zoom 1
          visu1 disp {251 -15}
       }

       #--- Traitement du résultat :
       set nom_profil  [ file rootname $nom_profil ]
       return "$nom_profil"
   } else {
       ::console::affiche_erreur "Usage: spc_export2png ?profil_de_raies_fits?\n\n"
   }
}
#****************************************************************#















#==============================================================================#
#==============================================================================#
#"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""#
#  Ancienne implémentation des fonction
#
#"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""#
#==============================================================================#
#==============================================================================#

####################################################################
#  Procedure de conversion de fichier profil de raie calibré .dat en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 27-04-2006
# Date modification : 27-04-2006
# Arguments : fichier .dat du profil de raie, titre, ?xdeb, xfin?
####################################################################

proc spc_dat2png_27042006 { args } {
    global audace
    global conf
    global tcl_platform

    if { [llength $args] == 4 || [llength $args] == 2 } {
        if { [llength $args] == 2 } {
            set fichier [ lindex $args 0 ]
            set titre [ lindex $args 1 ]
            #set xdeb "*"
            #set xfin "*"
            set fichierfit [ spc_dat2fits $fichier ${fichier}_fittmp ]
            buf$audace(bufNo) load "$audace(rep_images)/$fichierfit"
            set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
            #-- Demarre et fini le graphe en deçca de 3% des limites pour l'esthetique
            set largeur [ expr 0.03*$naxis1 ]
            set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
            set xdeb [ expr $xdeb0+$largeur ]
            set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
            set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
        } elseif { [llength $args] == 4 } {
            set fichier [ lindex $args 0 ]
            set titre [ lindex $args 1 ]
            set xdeb [ lindex $args 2 ]
            set xfin [ lindex $args 3 ]
            set fichierfit [ spc_dat2fits $fichier ${fichier}_fittmp ]
            buf$audace(bufNo) load "$audace(rep_images)/$fichierfit"
            set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
        }

        #--- Adapte la légende de l'abscisse
        if { $xdeb0 == 1.0 } {
            set legendex "Position (Pixel)"
        } else {
            set legendex "Wavelength (Å)"
        }
        set legendey "Intensity (ADU)"

        set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
        set ext ".dat"

        #spc_fits2dat $fichier
        #-- Retire l'extension .fit du nom du fichier
        set spcfile [ file rootname $fichier ]

        #--- Créée le fichier script pour gnuplot :
        set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
        puts $file_id "call \"$spcaudace(repgp)/gp_novisu.cfg\" \"$audace(rep_images)/${spcfile}$ext\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/${spcfile}.png\" \"$legendex\" \"$legendey\" "
        close $file_id

        #--- Détermine le chemin de l'executable Gnuplot selon le système d'exploitation :
        if { $tcl_platform(platform)=="unix" } {
            set answer [ catch { exec gnuplot $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "$answer\n"
        } else {
            set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/${spcfile}.gp } ]
            ::console::affiche_resultat "$answer\n"
        }

        ::console::affiche_resultat "Profil de raie exporté sous ${spcfile}.png\n"
    } else {
        ::console::affiche_erreur "Usage: spc_dat2png fichier_fits \"Titre\" ?xdébut xfin?\n\n"
    }
}
####################################################################



####################################################################
#  Procedure de conversion de fichier profil de raie spatial .fit en .dat
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-2005
# Arguments : fichier .fit du profil de raie
####################################################################

proc spc_fits2dat0 { {filenamespc ""} } {

   global conf
   global audace
   global profilspc
   #global caption
   global colorspc
   set extsp ".dat"

   #buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
   buf$audace(bufNo) load $filenamespc
   set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
   # Valeur minimale de l'abscisse : =0 si profil non étalonné
   set xdepart [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
   # Dispersion du spectre : =1 si profil non étalonné
   set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
   # Pixel de l'abscisse centrale
   set xcenter [lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1]
   # Type de spectre : LINEAR ou NONLINEAR (elinine les espaces dans la valeur du mot cle.
   #set dtype [string trim [lindex [buf$audace(bufNo) getkwd "CTYPE1"] 1]]
   #if { $dtype != "LINEAR" || $dtype == "" } {
   #    ::console::affiche_resultat "Le spectre ne possède pas une disersion linéaire. Pas de conversion possible.\n"
   #    break
   #}
   set len [expr int($naxis1/$xincr)]
   ::console::affiche_resultat "$len intensités à traiter\n"

   if { $xdepart != 1 } {
       set fileetalonnespc [ file rootname $filenamespc ]
       #set filename ${fileetalonnespc}_dat$extsp
       set filename ${fileetalonnespc}$extsp
       set file_id [open "$audace(rep_images)/$filename" w+]

   ## Une liste commence à 0 ; Un vecteur fits commence à 1
   #for {set k 0} {$k<$len} {incr k}
   #        append intensite [lindex $intensites $k]
        #::console::affiche_resultat "$intensite\n"
        # buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
        # set intensite 0
   #

       for {set k 1} {$k<=$len} {incr k} {
           # Donne les bonnes valeurs aux abscisses si le spectre est étalonné en longueur d'onde
           set lambda [expr int($xdepart+($k-1)*$xincr)]
           ##lappend profilspc(pixels) $lambda
           #set lambda 0

           # Lit la valeur des elements du fichier fit
           set intensite [buf$audace(bufNo) getpix [list $k 1]]
           ##lappend profilspc(intensite) $intensite
           #set intensite 0

           # Ecrit les couples "Lambda Intensite" dans le fichier de sortie
           ::console::affiche_resultat "$lambda\t$intensite\n"
           puts $file_id "$lambda\t$intensite"
       }
       close $file_id
   } else {
       # Retire l'extension .dat du nom du fichier
       set filespacialspc [ file rootname $filenamespc ]
       #buf$audace(bufNo) imaseries "PROFILE filename=${filespacialspc}_dat$extsp direction=x offset=1"
       buf$audace(bufNo) imaseries "PROFILE filename=${filespacialspc}$extsp direction=x offset=1"
       ::console::affiche_resultat "Fichier fits exporté sous $profilspc(initialfile)$extsp\n"
   }

}
#****************************************************************#



###################################################################
#  Procedure de conversion de fichier profil de raies .dat en .fit
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 31-01-2005
# Date modification : 15-02-2005/27-04-2006
# Arguments : fichier .dat du profil de raie ?fichier_sortie.fit?
###################################################################

proc spc_dat2fits_150205 { args } {

 global conf
 global audace
 global profilspc
 #global caption
 global colorspc
 set extsp ".dat"
 set nbunit "float"
 #set nbunit "double"
 set precision 0.05

 if { [llength $args] <= 2 } {
     if {[llength $args] == 1} {
         set filenamespc [ lindex $args 0 ]
     } elseif { [llength $args] == 2 } {
         set filenamespc [ lindex $args 0 ]
         set filenameout [ lindex $args 1 ]
     }
     ## === Lecture du fichier de donnees du profil de raie ===
     catch {unset profilspc} {}
     set profilspc(initialdir) [file dirname $audace(rep_images)]
     set profilspc(initialfile) [file tail $filenamespc]
     set input [open "$audace(rep_images)/$filenamespc" r]
     set contents [split [read $input] \n]
     close $input

     ## === Extraction des numeros des pixels et des intensites ===
     #::console::affiche_resultat "ICI :\n $contents.\n"
     #set profilspc(naxis1) [expr [llength $contents]-2]
     set profilspc(naxis1) [ expr [llength $contents]-1]
     #::console::affiche_resultat "$profilspc(naxis1)\n"
     set offset 1
     # Une liste commence à 0
     for {set k -1} {$k < $profilspc(naxis1)} {incr k} {
         set ligne [lindex $contents $k]
         append profilspc(pixels) "[lindex $ligne 0] "
         append profilspc(intensite) "[lindex $ligne 1] "
         #incr $k
     }
     #::console::affiche_resultat "$profilspc(pixels)\n"

     # === On prepare les vecteurs a afficher ===
     # len : longueur du profil (NAXIS1)
     #set len [llength $profilspc(pixels)]
     set len $profilspc(naxis1)
     set intensites ""
     for {set k 0} {$k<=$len} {incr k} {
         append intensites " [lindex $profilspc(intensite) $k]"
     }

     # Initialisation à blanc d'un fichier fits
     #buf$audace(bufNo) format $len 1
     buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_FLOAT COMPRESS_NONE 0

     set intensite 0
     #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
     # Une liste commence à 0 ; Un vecteur fits commence à 1
     for {set k 0} {$k<$len} {incr k} {
         append intensite [lindex $intensites $k]
         #::console::affiche_resultat "$intensite\n"
         if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {
             buf$audace(bufNo) setpix [list [expr $k+1] 1] $mintensite
             set intensite 0
         }
     }

     set profilspc(xunit) "Position"
     set profilspc(yunit) "ADU"
     #------- Affecte une valeur aux mots cle liés à la spectroscopie ----------
     #-- buf$audace(bufNo) setkwd [list "INSTRU" "T310" string "mon télescope" ""]
     #buf$audace(bufNo) setkwd [list "NAXIS1" "$len" int "" ""]
     #buf$audace(bufNo) setkwd [list "NAXIS2" "1" int "" ""]
     #--- Valeur minimale de l'abscisse (xdepart) : =0 si profil non étalonné
     set xdepart [ expr 0.0+1.0*[lindex $profilspc(pixels) 0] ]
     buf$audace(bufNo) setkwd [list "CRVAL1" $xdepart $nbunit "" ""]
     #--- Valeur de la longueur d'onde/pixel central(e)
     set xdernier [lindex $profilspc(pixels) [expr $profilspc(naxis1)-1]]
     ::console::affiche_resultat "Xdep : $xdepart ; Xfin : $xdernier\n"
     #set xcentre [expr int(0.5*($xdernier-$xdepart))]
     #buf$audace(bufNo) setkwd [list "CRPIX1" "$xcentre" double "" ""]
     #--- Dispersion du spectre :
     #-- Calcul dans le cas d'une dispersion non linéaire
     set l1 [lindex $profilspc(pixels) 1]
     set l2 [lindex $profilspc(pixels) [expr int($len/10)]]
     set l3 [lindex $profilspc(pixels) [expr int(2*$len/10)]]
     set l4 [lindex $profilspc(pixels) [expr int(3*$len/10)]]
     set dl1 [expr ($l2-$l1)/(int($len/10)-1.0)]
     set dl2 [expr ($l4-$l3)/(int($len/10)-1.0)]
     set xincr [expr 0.5*($dl2+$dl1)]
     #-- Mesure de la dispersion supposée linéaire
     set l1 [lindex $profilspc(pixels) 1]
     set l2 [lindex $profilspc(pixels) 2]
     set xincr [expr 1.0*abs($l2-$l1)]

     #-- Meth2 : erreur si spectre de moins de 4 pixels
     #set l2 [lindex $profilspc(pixels) 4]
     #set l3 [lindex $profilspc(pixels) [expr 1+int($len/2)]]
     #set l4 [lindex $profilspc(pixels) [expr 4+int($len/2)]]
     #set dl1 [expr ($l2-$l1)/3]
     #set dl2 [expr ($l4-$l3)/3]
     #set xincr [expr 0.5*($dl2+$dl1)]

     ::console::affiche_resultat "Dispersion : $xincr\n"
     buf$audace(bufNo) setkwd [list "CDELT1" $xincr $nbunit "" ""]
     #--- Type de dispersion : LINEAR, NONLINEAR

     #--- Sauve le fichier fits ainsi constitué
     ::console::affiche_resultat "$len lignes affectées\n"
     buf$audace(bufNo) bitpix float
     if {[llength $args] == 1} {
         set nom [ file rootname $filenamespc ]
         buf$audace(bufNo) save "$audace(rep_images)/${nom}$conf(extension,defaut)"
         buf$audace(bufNo) bitpix short
         ::console::affiche_resultat "Fichier fits sauvé sous $audace(rep_images)/${nom}$conf(extension,defaut)\n"
     } elseif {[llength $args] == 2} {
         set nom [ file rootname $filenameout ]
         buf$audace(bufNo) save "$audace(rep_images)/${filenameout}$conf(extension,defaut)"
         buf$audace(bufNo) bitpix short
         ::console::affiche_resultat "Fichier fits sauvé sous $audace(rep_images)/${filenameout}$conf(extension,defaut)\n"
     }
     buf$audace(bufNo) bitpix short
 } else {
     ::console::affiche_erreur "Usage: spc_dat2fits fichier_profil.dat ?fichier_sortie.fit?\n\n"
 }
}
#****************************************************************#



proc spc_fits2dat_160505 { args } {

 global conf
 global audace
 global profilspc
 #global caption
 global colorspc
 set extsp ".dat"

 if {[llength $args] == 1} {
   set filenamespc [ lindex $args 0 ]
   buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
   #buf$audace(bufNo) load $filenamespc
   set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
   #--- Valeur minimale de l'abscisse : =0 si profil non étalonné
   set xdepart [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
   #--- Dispersion du spectre : =1 si profil non étalonné
   set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
   #--- Pixel de l'abscisse centrale
   set xcenter [lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1]
   #--- Type de spectre : LINEAR ou NONLINEAR (elinine les espaces dans la valeur du mot cle.
   set dtype [string trim [lindex [buf$audace(bufNo) getkwd "CTYPE1"] 1]]
   #::console::affiche_resultat "Ici 1\n"
   #if { $dtype != "LINEAR" || $dtype == "" } {
   #    ::console::affiche_resultat "Le spectre ne possède pas une disersion linéaire. Pas de conversion possible.\n"
   #    break
   #}
   #::console::affiche_resultat "Ici 2\n"
   set len [expr int($naxis1/$xincr)]
   ::console::affiche_resultat "$naxis1 intensités à traiter\n"

   if { $xdepart != 1 } {
       set fileetalonnespc [ file rootname $filenamespc ]
       #set filename ${fileetalonnespc}_dat$extsp
       set filename ${fileetalonnespc}$extsp
       set file_id [open "$audace(rep_images)/$filename" w+]

       #--- Une liste commence à 0 ; Un vecteur fits commence à 1
       for {set k 0} {$k<$naxis1} {incr k} {
           #-- Donne les bonnes valeurs aux abscisses si le spectre est étalonné en longueur d'onde
           set lambda [expr $xdepart+($k)*$xincr*1.0]
           #-- Lit la valeur des elements du fichier fit
           set intensite [buf$audace(bufNo) getpix [list [expr $k+1] 1]]
           ##lappend profilspc(intensite) $intensite
           #-- Ecrit les couples "Lambda Intensite" dans le fichier de sortie
           puts $file_id "$lambda\t$intensite"
       }
       close $file_id
       ::console::affiche_resultat "Fichier fits exporté sous $audace(rep_images)/${fileetalonnespc}$extsp\n"
   } else {
       #--- Retire l'extension .dat du nom du fichier
       set filespacialspc [ file rootname $filenamespc ]
       #buf$audace(bufNo) imaseries "PROFILE filename=${filespacialspc}_dat$extsp direction=x offset=1"
       buf$audace(bufNo) imaseries "PROFILE filename=$audace(rep_images)/${filespacialspc}$extsp direction=x offset=1"
       ::console::affiche_resultat "Fichier fits exporté sous $audace(rep_images)/${filespacialspc}$extsp\n"
   }
 } else {
   ::console::affiche_erreur "Usage: spc_fits2dat fichier_profil.fit\n\n"
 }
}
#****************************************************************#



proc spc_data2fits_051219a { args } {
    global audace
    global conf
    set precision 0.05
    set nbunit "float"
    #set nbunit "double"

    if { [llength $args] == 2 } {
        #set nom_fichier [ file rootname [lindex 0] ]
        set nom_fichier [lindex $args 0]
        set coordonnees [lindex $args 1]
        set abscisses [lindex $coordonnees 0]
        set intensites [lindex $coordonnees 1]
        set len [llength $abscisses]

        #--- Création du fichier fits
        buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_FLOAT COMPRESS_NONE 0
        buf$audace(bufNo) setkwd [list "NAXIS1" $len int "" ""]
        buf$audace(bufNo) setkwd [list "NAXIS2" 1 int "" ""]
        #-- Valeur minimale de l'abscisse (xdepart) : =0 si profil non étalonné
        set xdepart [expr 1.0*[lindex $abscisses 0] ]
        buf$audace(bufNo) setkwd [list "CRVAL1" $xdepart $nbunit "" "Angstrom"]
        #-- Dispersion
        #set dispersion [spc_dispersion_moy $abscisses]
        set l1 [lindex $abscisses 1]
        set l2 [lindex $abscisses [expr int($len/10)]]
        set l3 [lindex $abscisses [expr int(2*$len/10)]]
        set l4 [lindex $abscisses [expr int(3*$len/10)]]
        set dl1 [expr ($l2-$l1)/(int($len/10)-1)]
        set dl2 [expr ($l4-$l3)/(int($len/10)-1)]
        set dispersion [expr 0.5*($dl2+$dl1)]
        buf$audace(bufNo) setkwd [list "CDELT1" $dispersion $nbunit "Wavelength increment" "angstrom/pixel"]

        #--- Type de dispersion : LINEAR, NONLINEAR
        #if { [expr abs($dl2-$dl1)] <= $precision } {
        #    buf$audace(bufNo) setkwd [list "CTYPE1" "LINEAR" string "" ""]
        #} elseif { [expr abs($dl2-$dl1)] > $precision } {
        #    buf$audace(bufNo) setkwd [list "CTYPE1" "NONLINEAR" string "" ""]
        #}

        #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
        # Une liste commence à 0 ; Un vecteur fits commence à 1
        set intensite 0
        for {set k 0} {$k<$len} {incr k} {
            append intensite [lindex $intensites $k]
            #::console::affiche_resultat "$intensite\n"
            if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {
                buf$audace(bufNo) setpix [list [expr $k+1] 1] $mintensite
                set intensite 0
            }
        }

        #--- Sauvegarde du fichier fits ainsi créé
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/$nom_fichier"
        buf$audace(bufNo) bitpix short
        return $nom_fichier
    } else {
       ::console::affiche_erreur "Usage: spc_data2fits nom_fichier_fits_sortie liste_coordonnées_x_et_y\n\n"
    }
}
#**********************************************************************#


proc spc_data2fits_051215a { args } {
    global audace
    global conf
    set precision 0.05
    set nbunit "float"
    #set nbunit "double"

    if { [llength $args] == 2 } {
        #set nom_fichier [ file rootname [lindex 0] ]
        set nom_fichier [lindex $args 0]
        set coordonnees [lindex $args 1]
        set abscisses [lindex $coordonnees 0]
        set intensites [lindex $coordonnees 1]
        set len [llength $abscisses]

        #--- Création du fichier fits
        buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_FLOAT COMPRESS_NONE 0
        buf$audace(bufNo) setkwd [list "NAXIS1" $len int "" ""]
        buf$audace(bufNo) setkwd [list "NAXIS2" 1 int "" ""]
        #-- Valeur minimale de l'abscisse (xdepart) : =0 si profil non étalonné
        set xdepart [ expr 1.0*[lindex $abscisses 0]]
        buf$audace(bufNo) setkwd [list "CRVAL1" $xdepart $nbunit "" "Angstrom"]
        #-- Dispersion
        #set dispersion [spc_dispersion_moy $abscisses]
        set l1 [lindex $abscisses 1]
        set l2 [lindex $abscisses [expr int($len/10)]]
        set l3 [lindex $abscisses [expr int(2*$len/10)]]
        set l4 [lindex $abscisses [expr int(3*$len/10)]]
        set dl1 [expr ($l2-$l1)/(int($len/10)-1)]
        set dl2 [expr ($l4-$l3)/(int($len/10)-1)]
        set dispersion [expr 0.5*($dl2+$dl1)]
        buf$audace(bufNo) setkwd [list "CDELT1" $dispersion $nbunit "Wavelength increment" "angstrom/pixel"]

        #--- Type de dispersion : LINEAR, NONLINEAR
        #if { [expr abs($dl2-$dl1)] <= $precision } {
        #    buf$audace(bufNo) setkwd [list "CTYPE1" "LINEAR" string "" ""]
        #} elseif { [expr abs($dl2-$dl1)] > $precision } {
        #    buf$audace(bufNo) setkwd [list "CTYPE1" "NONLINEAR" string "" ""]
        #}

        #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
        # Une liste commence à 0 ; Un vecteur fits commence à 1
        set intensite 0
        for {set k 0} {$k<$len} {incr k} {
            append intensite [lindex $intensites $k]
            #::console::affiche_resultat "$intensite\n"
            if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {
                buf$audace(bufNo) setpix [list [expr $k+1] 1] $mintensite
                set intensite 0
            }
        }

        #--- Sauvegarde du fichier fits ainsi créé
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/$nom_fichier"
        buf$audace(bufNo) bitpix short
        return $nom_fichier
    } else {
       ::console::affiche_erreur "Usage: spc_data2fits nom_fichier_fits_sortie liste_coordonnées_x_et_y\n\n"
    }
}
#****************************************************************#



proc spc_dat2fits_27042006 { args } {

    global conf
    global audace spcaudace

    #set nbunit "float"
    set nbunit "double"
    set precision 0.05

    if { [llength $args] <= 2 } {
        if { [llength $args] == 1 } {
            set filenamespc [ lindex $args 0 ]
        } elseif { [llength $args] == 2 } {
            set filenamespc [ lindex $args 0 ]
            set filenameout [ lindex $args 1 ]
        } else {
            ::console::affiche_erreur "Usage: spc_dat2fits fichier_profil.dat ?fichier_sortie.fit?\n\n"
            return 0
        }
        ## === Lecture du fichier de donnees du profil de raie ===
        set input [open "$audace(rep_images)/$filenamespc" r]
        set contents [split [read $input] \n]
        close $input
        ## === Extraction des numeros des pixels et des intensites ===
        #::console::affiche_resultat "ICI :\n $contents.\n"
        #set profilspc(naxis1) [expr [llength $contents]-2]
        set naxis1 [ expr [llength $contents]-1 ]
        #::console::affiche_resultat "$profilspc(naxis1)\n"
        set offset 1
        # Une liste commence à 0
        for {set k -1} {$k < $naxis1} {incr k} {
            set ligne [lindex $contents $k]
            append pixels "[lindex $ligne 0] "
            append intensites "[lindex $ligne 1] "
            #incr $k
        }
        #::console::affiche_resultat "$profilspc(pixels)\n"

        # === On prepare les vecteurs a afficher ===
        # len : longueur du profil (NAXIS1)
        #set len [llength $profilspc(pixels)]
        set nintensites ""
        for {set k 0} {$k<=$naxis1} {incr k} {
            append nintensites " [lindex $intensites $k]"
        }

        #--- Initialisation à blanc d'un fichier fits
        buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 1 FORMAT_FLOAT COMPRESS_NONE 0
        buf$audace(bufNo) setkwd [ list NAXIS 1 int "" "" ]
        buf$audace(bufNo) setkwd [ list NAXIS1 $naxis1 int "" "" ]

        #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
        # Une liste commence à 0 ; Un vecteur fits commence à 1
        set intensite 0
        for {set k 0} {$k<$naxis1} {incr k} {
            append intensite [lindex $nintensites $k]
            #::console::affiche_resultat "$intensite\n"
            if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {
                buf$audace(bufNo) setpix [list [expr $k+1] 1] $mintensite
                set intensite 0
            }
        }

        #=============================

        set flag 0
        if { $flag == 1 } {
            #--- Type de dispersion : LINEAR, NONLINEAR

            #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
            # Une liste commence à 0 ; Un vecteur fits commence à 1
            set intensite 0
            for {set k 0} {$k<$naxis1} {incr k} {
                append intensite [lindex $nintensites $k]
                #::console::affiche_resultat "$intensite\n"
                if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {
                    buf$audace(bufNo) setpix [list [expr $k+1] 1] $mintensite
                    set intensite 0
                }
            }
        }
        #==============================

        #------- Affecte une valeur aux mots cle liés à la spectroscopie ----------
        #-- buf$audace(bufNo) setkwd [list "INSTRU" "T310" string "mon télescope" ""]
        #buf$audace(bufNo) setkwd [list "NAXIS1" "$len" int "" ""]
        #buf$audace(bufNo) setkwd [list "NAXIS2" "1" int "" ""]
        #--- Valeur minimale de l'abscisse (xdepart) : =0 si profil non étalonné
        set xdepart [ expr 0.0+1.0*[lindex $pixels 0] ]
        buf$audace(bufNo) setkwd [list "CRVAL1" $xdepart $nbunit "" ""]

        #--- Valeur de la longueur d'onde/pixel de fin ***** naxis1ici-1=naxis1-2 A VERFIFIER ****
        set xdernier [lindex $pixels [expr $naxis1-1]]
        ::console::affiche_resultat "Xdep : $xdepart ; Xfin : $xdernier\n"
        #set xcentre [expr int(0.5*($xdernier-$xdepart))]
        #buf$audace(bufNo) setkwd [list "CRPIX1" "$xcentre" double "" ""]

        #--- Dispersion du spectre :
        #-- Calcul dans le cas d'une dispersion non linéaire
        set l1 [lindex $pixels 1]
        set l2 [lindex $pixels [expr int($naxis1/10)]]
        set l3 [lindex $pixels [expr int(2*$naxis1/10)]]
        set l4 [lindex $pixels [expr int(3*$naxis1/10)]]
        set dl1 [expr ($l2-$l1)/(int($naxis1/10)-1.0)]
        set dl2 [expr ($l4-$l3)/(int($naxis1/10)-1.0)]
        set dispersion [expr 0.5*($dl2+$dl1)]
        #-- Mesure de la dispersion supposée linéaire
        set l1 [lindex $pixels 1]
        set l2 [lindex $pixels 2]
        set dispersion [expr 1.0*abs($l2-$l1)]

        #-- Meth2 : erreur si spectre de moins de 4 pixels
        #set l2 [lindex $profilspc(pixels) 4]
        #set l3 [lindex $profilspc(pixels) [expr 1+int($len/2)]]
        #set l4 [lindex $profilspc(pixels) [expr 4+int($len/2)]]
        #set dl1 [expr ($l2-$l1)/3]
        #set dl2 [expr ($l4-$l3)/3]
        #set xincr [expr 0.5*($dl2+$dl1)]

        #-- Ecriture du mot clef
        ::console::affiche_resultat "Dispersion : $dispersion\n"
        if { $xdepart == 1.0 } {
            buf$audace(bufNo) setkwd [list "CDELT1" $dispersion $nbunit "" "pixel"]
        } else {
            buf$audace(bufNo) setkwd [list "CDELT1" $dispersion $nbunit "Wavelength increment" "angstrom/pixel"]
        }

        #--- Type de dispersion : LINEAR, NONLINEAR

        #--- Sauve le fichier fits ainsi constitué
        ::console::affiche_resultat "$naxis1 lignes affectées\n"
        buf$audace(bufNo) bitpix float
        if {[llength $args] == 1} {
            set nom [ file rootname $filenamespc ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${nom}$conf(extension,defaut)"
            buf$audace(bufNo) bitpix short
            ::console::affiche_resultat "Fichier fits sauvé sous $audace(rep_images)/${nom}$conf(extension,defaut)\n"
            return ${nom}
        } elseif {[llength $args] == 2} {
            set nom [ file rootname $filenameout ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filenameout}$conf(extension,defaut)"
            buf$audace(bufNo) bitpix short
            ::console::affiche_resultat "Fichier fits sauvé sous $audace(rep_images)/${filenameout}$conf(extension,defaut)\n"
            return ${filenameout}
        }
        #buf$audace(bufNo) bitpix short
    } else {
        ::console::affiche_erreur "Usage: spc_dat2fits fichier_profil.dat ?fichier_sortie.fit?\n\n"
    }
}
#****************************************************************#



proc spc_spc2fits2 { args } {

 global conf
 global audace spcaudace
 global profilspc
 global caption
 global colorspc


 if {[llength $args] == 1} {
   set filenamespc [ lindex $args 0 ]
   ## === Lecture du fichier de donnees du profil de raie ===
   catch {unset profilspc} {}
   set profilspc(initialdir) [file dirname $audace(rep_images)]
   set profilspc(initialfile) [file tail $filenamespc]
   set input [open "$audace(rep_images)/$filenamespc" r]

   #--- Charge le contenu du fichier et enleve l'entête
   #-- Retourne une chaîne
   set total_contents [read $input]
   set contents [regexp {(.+)repere\r\n(.+)$} $total_contents match]
   set liste_lignes [split $contents \n]
   close $input
   #::console::affiche_resultat "ICI :\n $contents\n"
   ## === Extraction des numeros des pixels et des intensites ===
   ##set profilspc(naxis1) [expr [llength $contents]-2]
   set profilspc(naxis1) [ expr [llength $liste_lignes]-1]
   #::console::affiche_resultat "$profilspc(naxis1)\n"
   set offset 1
   #--- Une liste commence à 0
   for {set k -1} {$k < $profilspc(naxis1)} {incr k} {
      set ligne [lindex $liste_lignes $k]
      append profilspc(pixels) "[lindex $ligne 1] "
      append profilspc(intensite) "[lindex $ligne 2] "
      #incr $k
   }
   ::console::affiche_resultat "$profilspc(pixels)\n"
   #::console::affiche_resultat "ICI :\n $profilspc(intensite)\n"

   # === On prepare les vecteurs a afficher ===
   # len : longueur du profil (NAXIS1)
   #set len [llength $profilspc(pixels)]
   set len $profilspc(naxis1)
   set intensites ""
   for {set k 0} {$k<=$len} {incr k} {
         append intensites " [lindex $profilspc(intensite) $k]"
   }

   # Initialisation à blanc d'un fichier fits
   #buf$audace(bufNo) format $len 1
   buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_FLOAT COMPRESS_NONE 0
   buf$audace(bufNo) setkwd [ list NAXIS 1 int "" "" ]
   buf$audace(bufNo) setkwd [ list NAXIS1 $len int "" "" ]

   set intensite 0
   #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
   # Une liste commence à 0 ; Un vecteur fits commence à 1
   for {set k 0} {$k<$len} {incr k} {
       append intensite [lindex $intensites $k]
       #::console::affiche_resultat "$intensite\n"
       buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
       set intensite 0
   }

   set profilspc(xunit) "Position"
   set profilspc(yunit) "ADU"
   #------- Affecte une valeur aux mots cle liés à la spectroscopie ----------
   # buf$audace(bufNo) setkwd [list "INSTRU" "T310" string "mon télescope" ""]
   buf$audace(bufNo) setkwd [list "NAXIS1" "$len" int "" ""]
   buf$audace(bufNo) setkwd [list "NAXIS2" "1" int "" ""]
   # Valeur minimale de l'abscisse (xdepart) : =0 si profil non étalonné
   set xdepart [ expr 1.0*[lindex $profilspc(pixels) 0] ]
   buf$audace(bufNo) setkwd [list "CRVAL1" $xdepart double "Wavelength at reference pixel" "angstrom"]
   # Valeur de la longueur d'onde/pixel central(e)
   set xdernier [lindex $profilspc(pixels) [expr $profilspc(naxis1)-1]]
   ::console::affiche_resultat "Xdep : $xdepart ; Xfin : $xdernier\n"
   #set xcentre [expr int(0.5*($xdernier-$xdepart))]
   #buf$audace(bufNo) setkwd [list "CRPIX1" "$xcentre" double "" ""]
   # Dispersion du spectre : =1 si profil non étalonné
   set l1 [lindex $profilspc(pixels) 1]
   set l2 [lindex $profilspc(pixels) [expr int($len/10)]]
   set l3 [lindex $profilspc(pixels) [expr int(2*$len/10)]]
   set l4 [lindex $profilspc(pixels) [expr int(3*$len/10)]]
   set dl1 [expr ($l2-$l1)/(int($len/10)-1)]
   set dl2 [expr ($l4-$l3)/(int($len/10)-1)]
   set xincr [expr 0.5*($dl2+$dl1)]
   # Meth2 : erreur si spectre de moins de 4 pixels
   #set l2 [lindex $profilspc(pixels) 4]
   #set l3 [lindex $profilspc(pixels) [expr 1+int($len/2)]]
   #set l4 [lindex $profilspc(pixels) [expr 4+int($len/2)]]
   #set dl1 [expr ($l2-$l1)/3]
   #set dl2 [expr ($l4-$l3)/3]
   #set xincr [expr 0.5*($dl2+$dl1)]

   ::console::affiche_resultat "Dispersion : $xincr\n"
   buf$audace(bufNo) setkwd [list "CDELT1" $xincr double "Wavelength increment" "angstrom/pixel"]
   # Type de dispersion : LINEAR, NONLINEAR
   #if { [expr abs($dl2-$dl1)] <= 0.001 } {
   #    buf$audace(bufNo) setkwd [list "CTYPE1" "LINEAR" string "" ""]
   #} elseif { [expr abs($dl2-$dl1)] > 0.001 } {
   #    buf$audace(bufNo) setkwd [list "CTYPE1" "NONLINEAR" string "" ""]
   #}

   # Sauve le fichier fits ainsi constitué
   buf$audace(bufNo) bitpix float
   buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_fit$conf(extension,defaut)"
   buf$audace(bufNo) bitpix short
   ::console::affiche_resultat "$len lignes affectées\n"
   ::console::affiche_resultat "Fichier spc exporté sous ${filenamespc}_fit$conf(extension,defaut)\n"
   return ${filenamespc}_fit
 } else {
   ::console::affiche_erreur "Usage: spc_spc2fits fichier_spc\n\n"
 }
}
###########################################################################



####################################################################
# Procedure de création d'un fichier profil de raie fits à partir des données x et y
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 15-12-2005
# Arguments : nom fichier fit de sortie, une liste de coordonnées x puis y, unité des données
####################################################################

proc spc_data2fits_2005 { args } {
   global audace
   global conf
   set precision 0.0001

   if { [llength $args] <= 3 } {
     if { [llength $args] == 3 } {
        #set nom_fichier [ file rootname [lindex 0] ]
        set nom_fichier [lindex $args 0]
        set coordonnees [lindex $args 1]
        set nbunit [lindex $args 2]
     } elseif { [llength $args] == 2 } {
        set nom_fichier [lindex $args 0]
        set coordonnees [lindex $args 1]
        set nbunit "float"
     } else {
        ::console::affiche_erreur "Usage: spc_data2fits nom_fichier_fits_sortie liste_coordonnées_x_et_y unitées_coordonnées (float/double)\n\n"
        return ""
     }

     set abscisses [lindex $coordonnees 0]
     set intensites [lindex $coordonnees 1]
     set naxis1 [llength $abscisses]
     set crpix1 1

     #--- Création du fichier fits
     buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 1 FORMAT_FLOAT COMPRESS_NONE 0
     buf$audace(bufNo) setkwd [ list "NAXIS" 1 int "" "" ]
     buf$audace(bufNo) setkwd [ list "NAXIS1" $naxis1 int "" "" ]
     buf$audace(bufNo) setkwd [ list "CUNIT1" "angstrom" string "Wavelength unit" "" ]
     #-- Corrdonnée représentée sur l'axe 1 (ie X) :
     buf$audace(bufNo) setkwd [ list "CTYPE1" "Wavelength" string "" "" ]
     #-- Valeur minimale de l'abscisse (xdepart) : =0 si profil non étalonné
     set xdepart [expr 1.0*[lindex $abscisses 0] ]
     buf$audace(bufNo) setkwd [ list "CRVAL1" $xdepart double "" "angstrom" ]


     #--- Calcul de la dispersion par régression linéaire :
      set dispersion [ expr ([ lindex $abscisses [ expr $naxis-1 ] ]-$xdepart)/($naxis-1) ]
     #-- Mise à jour fichier fits
     buf$audace(bufNo) setkwd [ list "CDELT1" $dispersion double "Wavelength increment" "angstrom/pixel" ]
     buf$audace(bufNo) setkwd [ list "CRPIX1" $crpix1 double "Reference pixel" "pixel" ]

     #--- Calcul de la loi de calibration non-linéaire :
     set results [ spc_ajustdeg3 $xpos $abscisses 1 $crpix1 ]
     set coeffs [ lindex $results 0 ]
     set chi2 [ lindex $results 1 ]
     set spc_d [ lindex $coeffs 3 ]
     set spc_c [ lindex $coeffs 2 ]
     set spc_b [ lindex $coeffs 1 ]
     set spc_a [ lindex $coeffs 0 ]
     set rms [ expr $lambda0deg3*sqrt($chi2/$naxis1) ]


     #--- Mise a jour des mots clef :
     if { [ expr abs($spc_a) ] >=0.00000001 } {
        buf$audace(bufNo) setkwd [list "SPC_DESC" "A+B.x+C.x.x+D.x.x.x" string "" ""]
        buf$audace(bufNo) setkwd [list "SPC_A" $spc_a double "" "angstrom"]
        buf$audace(bufNo) setkwd [list "SPC_B" $spc_b double "" "angstrom/pixel"]
        buf$audace(bufNo) setkwd [list "SPC_C" $spc_c double "" "angstrom.angstrom/pixel.pixel"]
        buf$audace(bufNo) setkwd [list "SPC_D" $spc_d double "" "angstrom.angstrom.angstrom/pixel.pixel.pixel"]
     }


     #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
     #-- Une liste commence à 0 ; Un vecteur fits commence à 1
     set intensite 0
     for {set k 0} {$k<$naxis1} {incr k} {
        append intensite [lindex $intensites $k]
        if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {
           buf$audace(bufNo) setpix [list [expr $k+1] 1] $mintensite
           set intensite 0
        }
     }

     #--- Sauvegarde du fichier fits ainsi créé
     if { $nbunit == "double" || $nbunit == "float" } {
        buf$audace(bufNo) bitpix float
     } elseif { $nbunit == "int" } {
        buf$audace(bufNo) bitpix short
     }
     buf$audace(bufNo) save "$audace(rep_images)/$nom_fichier$conf(extension,defaut)"
     buf$audace(bufNo) bitpix short
     return $nom_fichier
  } else {
     ::console::affiche_erreur "Usage: spc_data2fits nom_fichier_fits_sortie liste_coordonnées_x_et_y unitées_intensités (float/double)\n\n"
  }
}
#**********************************************************************#
