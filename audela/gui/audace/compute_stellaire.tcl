#
## @file compute_stellaire.tcl
#  @brief Fonction de prétraitement automatique
#  @author Benoit MAUGIS
#  $Id: compute_stellaire.tcl 13515 2016-03-28 14:05:23Z rzachantke $
#

## @brief prétraite complètement une série d'images brutes
#  @param args liste d'arguments (CF @ref stellaire)
#
proc compute_stellaire {args} {
   global audace caption conf

   if {[syntaxe_args $args 1 3 [list [list "-altaz"] [list "-buf" "-rep" "-ext" "-polyNo" "-tri" "-typeStack"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set brutes [lindex $args 0]

      # Configuration des options
      set options [lrange $args 1 [expr [llength $args]-1]]
      set range_options [range_options $options]

      # Configuration des paramètres optionnels
      set params_optionnels [lindex $range_options 0]
      if {[llength $params_optionnels] >= 1} {
         set noirs [lindex $params_optionnels 0]
      } else {
         set noirs "pas_de_noirs"
      }
      if {[llength $params_optionnels] >= 2} {
         set PLUs [lindex $params_optionnels 1]
      } else {
         set PLUs "pas_de_PLUs"
      }
      if {[llength $params_optionnels] == 3} {
         set noirsdePLUs [lindex $params_optionnels 2]
      } else {
         set noirsdePLUs "pas_de_noirsdePLUs"
      }

      # Configuration des options sans paramètre
      set options_0param [lindex $range_options 1]

      set altaz_index [lsearch -regexp $options_0param "-altaz"]

      if {$altaz_index>=0} {
         set altaz 1
      } else {
         set altaz 0
      }

      # Configuration des options à 1 paramètre
      set options_1param [lindex $range_options 2]

      set buf_index [lsearch -regexp $options_1param "-buf"]
      set rep_index [lsearch -regexp $options_1param "-rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]
      set polyNo_index [lsearch -regexp $options_1param "-polyNo"]
      set tri_index [lsearch -regexp $options_1param "-tri"]
      set typeStack_index [lsearch -regexp $options_1param "-typeStack"]

      if {$buf_index>=0} {
         set buf [lindex [lindex $options_1param $buf_index] 1]
      } else {
         set buf $audace(bufNo)
      }
      if {$rep_index>=0} {
         set rep [lindex [lindex $options_1param $rep_index] 1]
      } else {
         set rep $audace(rep_images)
      }
      if {$ext_index>=0} {
         set ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set ext $conf(extension,defaut)
      } else {
         set ext $conf(extension,defaut).gz
      }
      if {$polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
         set ex_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      } else {
         set in_polyNo 1
         set ex_polyNo 1
      }
      if {$tri_index>=0} {
         set tri [lindex [lindex $options_1param $tri_index] 1]
      } else {
         set tri 80
      }
      if {$typeStack_index>=0} {
         set typeStack [lindex [lindex $options_1param $typeStack_index] 1]
      } else {
         set typeStack "SK"
      }

      # Procédure principale
      console::affiche_resultat "$caption(compute,debut)"

      # On vérifie que la série d'images brutes existe bien
      set index_brutes [lsort [liste_index $brutes -rep "$rep" -ext $ext]]
      # Si possible on trie par ordre croissant (sauf dans le cas d'indexation XXX par ex.)
      if [catch {set index_brutes [lsort -integer $index_brutes]}] {}
      if {[llength $index_brutes]==0} {
         tk_messageBox -title $caption(compute,pb) -type ok -message $caption(compute,nobrutes)
         console::affiche_resultat "$caption(compute,fin)"
         return
      } else {
         console::affiche_resultat "$caption(compute,brutesok) [llength $index_brutes]\n"
      }

      # On vérifie que la série d'images de noir existe bien
      if {$noirs!="pas_de_noirs"} {
         set index_noirs [lsort [liste_index $noirs -rep "$rep" -ext $ext]]
         # Si possible on trie par ordre croissant (sauf dans le cas d'indexation XXX par ex.)
         if [catch {set index_noirs [lsort -integer $index_noirs]}] {}
         if {[llength $index_noirs]==0} {
            tk_messageBox -title $caption(compute,pb) -type ok -message $caption(compute,nonoirs)
            console::affiche_resultat "$caption(compute,fin)"
            return
         } else {
            console::affiche_resultat "$caption(compute,noirsok) [llength $index_noirs]\n"
         }
      }

      # On vérifie que la série d'images de PLU existe bien
      if {$PLUs!="pas_de_PLUs"} {
         set index_PLUs [lsort [liste_index $PLUs -rep "$rep" -ext $ext]]
         # Si possible on trie par ordre croissant (sauf dans le cas d'indexation XXX par ex.)
         if [catch {set index_PLUs [lsort -integer $index_PLUs]}] {}
         if {[llength $index_PLUs]==0} {
            tk_messageBox -title $caption(compute,pb) -type ok -message $caption(compute,noPLUs)
            console::affiche_resultat "$caption(compute,fin)"
            return
         } else {
            console::affiche_resultat "$caption(compute,PLUsok) [llength $index_PLUs]\n"
         }
      }

      # On vérifie que la série d'images de noirs de PLUs existe bien
      if {$noirsdePLUs!="pas_de_noirsdePLUs"} {
         set index_noirsdePLUs [lsort [liste_index $noirsdePLUs -rep "$rep" -ext $ext]]
         # Si possible on trie par ordre croissant (sauf dans le cas d'indexation XXX par ex.)
         if [catch {set index_noirsdePLUs [lsort -integer $index_noirsdePLUs]}] {}
         if {[llength $index_noirsdePLUs]==0} {
            tk_messageBox -title $caption(compute,pb) -type ok -message $caption(compute,nonoirsdePLUs)
            console::affiche_resultat "$caption(compute,fin)"
            return
         } else {
            console::affiche_resultat "$caption(compute,noirsdePLUsok) [llength $index_noirsdePLUs]\n"
         }
      }

      # On vérifie que le pourcentage d'images à conserver pour le compositage est cohérent
      # (réel strictement positif inférieur à 100)
      if {[TestReel $tri] == 0} {
         tk_messageBox -title $caption(compute,pb) -type ok -message $caption(compute,pbpourcentage)
         console::affiche_resultat "$caption(compute,fin)"
         return
      }
      if {$tri>100} {
         tk_messageBox -title $caption(compute,pb) -type ok -message $caption(compute,pbpourcentage)
         console::affiche_resultat "$caption(compute,fin)"
         return
      }
      if {$tri<0} {
         tk_messageBox -title $caption(compute,pb) -type ok -message $caption(compute,pbpourcentage)
         console::affiche_resultat "$caption(compute,fin)"
         return
      }

      # Création du répertoire temporaire
      set rep_tmp [cree_sousrep -nom_base tmp_compute_stellaire -rep $rep]

      # Création du buffer temporaire
      set num_buf_tmp [buf::create]
      buf$num_buf_tmp extension $conf(extension,defaut)

      if {$noirs!="pas_de_noirs"} {
         # Création de l'image de noir (par médiane) dans le buffer temporaire
         console::affiche_resultat "$caption(compute,tmp_noir)"
         mediane $noirs -rep "$rep" -ext $ext -buf $num_buf_tmp -polyNo $in_polyNo

         # Soustraction du noir
         console::affiche_resultat "$caption(compute,tmp_brute-noir_X)"
         serie_soustrait $brutes tmp_brute-noir_ -buf $num_buf_tmp -in_rep $rep -ex_rep $rep_tmp -in_ext $ext -ex_ext [lindex [decomp $ext] 3] -in_polyNo $in_polyNo

         if {$PLUs!="pas_de_PLUs"} {

            if {$noirsdePLUs!="pas_de_noirsdePLUs"} {
               # Création de l'image de noir de PLUs (par médiane)
               console::affiche_resultat "$caption(compute,tmp_noirdePLUs)"
               # NB : on ne refait explicitement le calcul de médiane que si les noirs de PLUs sont différents des noirs,
               # sinon le noir a déjà été calculé précédemment et figure toujours dans le buffer temporaire
               if {$noirs != $noirsdePLUs } {
                  mediane $noirsdePLUs -rep "$rep" -ext $ext -buf $num_buf_tmp -polyNo $in_polyNo
               }

               # Soustraction du noir de PLUs
               console::affiche_resultat "$caption(compute,tmp_PLU-noir_X)"
               serie_soustrait $PLUs tmp_PLU-noir_ -buf $num_buf_tmp -in_rep $rep -ex_rep $rep_tmp -in_ext $ext -ex_ext [lindex [decomp $ext] 3] -in_polyNo $in_polyNo

               # Normalisation du gain des PLUs
               console::affiche_resultat "$caption(compute,tmp_PLUnorm_X)"
               normalise_gain tmp_PLU-noir_ tmp_PLUnorm_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

               # Suppression de la série temporaire de PLUs nettoyées du noir
               suppr_serie tmp_PLU-noir_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

            } else {
               # Normalisation du gain des PLUs
               console::affiche_resultat "$caption(compute,tmp_PLUnorm_X)"
               normalise_gain $PLUs tmp_PLUnorm_ -in_rep $rep -ex_rep $rep_tmp -in_ext $ext -ex_ext [lindex [decomp $ext] 3] -in_polyNo $in_polyNo
            }

            # Création de l'image de PLUs (par médiane)
            console::affiche_resultat "$caption(compute,tmp_PLU)"
            mediane tmp_PLUnorm_ -rep "$rep_tmp" -ext [lindex [decomp $ext] 3] -buf $num_buf_tmp

            # Suppression de la série temporaire de PLUs normalisées
            suppr_serie tmp_PLUnorm_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

            # Normalisation par PLU
            console::affiche_resultat "$caption(compute,tmp_pret_X)"
            serie_normalise tmp_brute-noir_ tmp_pret_ -buf $num_buf_tmp -rep $rep_tmp -ext [lindex [decomp $ext] 3]

            # Suppression des images temporaires nettoyées du noir
            suppr_serie tmp_brute-noir_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

            # On indique dans la variable serie_a_recaler le nom de la
            # série sur laquelle il faut faire le recalage stellaire
            set serie_a_trier "tmp_pret_"
            set ext_serie_a_trier [lindex [decomp $ext] 3]
            set rep_serie_a_trier $rep_tmp
            # On indique dans la variable suppr_apres_recalage s'il faut
            # supprimer ou pas cette série après avoir effectué l'alignement
            set suppr_apres_tri 1

            # Registration
            #console::affiche_resultat "$caption(compute,tmp_registr_X)"
            #aligne tmp_pret_ tmp_registr_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]
            # Suppression des images prétraitées
            #suppr_serie tmp_pret_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

         } else {

            # On indique dans la variable serie_a_recaler le nom de la
            # série sur laquelle il faut faire le recalage stellaire
            set serie_a_trier "tmp_brute-noir_"
            set ext_serie_a_trier [lindex [decomp $ext] 3]
            set rep_serie_a_trier $rep_tmp
            # On indique dans la variable suppr_apres_recalage s'il faut
            # supprimer ou pas cette série après avoir effectué l'alignement
            set suppr_apres_tri 1

            # En l'absence de PLUs : on fait l'alignement sur les images nettoyées du noir
            #aligne tmp_brute-noir_ tmp_registr_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

            # Suppression des images prétraitées
            #suppr_serie tmp_brute-noir_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]
         }

      } else {

         # On indique dans la variable serie_a_recaler le nom de la
         # série sur laquelle il faut faire le recalage stellaire
         set serie_a_trier $brutes
         set ext_serie_a_trier $ext
         set rep_serie_a_trier $rep
         # On indique dans la variable suppr_apres_recalage s'il faut
         # supprimer ou pas cette série après avoir effectué l'alignement
         set suppr_apres_tri 0

         # En l'absence d'images de noir : on fait la registration sur les images brutes.
         #aligne $brutes tmp_registr_ -in_rep $rep -ex_rep $rep_tmp -in_ext $ext -ex_ext [lindex [decomp $ext] 3] -in_polyNo $in_polyNo
      }

      # Tri par FWHM
      if {$tri == 100} {
         # Pas besoin de trier (on garde tout)
         if {$suppr_apres_tri == 1} {
            renomme $serie_a_trier "tmp_tri_" -rep $rep_tmp -ext $ext_serie_a_trier
         } else {
            copie $serie_a_trier "tmp_tri_" -in_rep $rep_serie_a_trier -ex_rep $rep_tmp -in_ext $ext_serie_a_trier -ex_ext [lindex [decomp $ext] 3]
         }

      } else {
         console::affiche_resultat "$caption(compute,tri_FWHM)"
         foreach index [liste_index $serie_a_trier -rep $rep_serie_a_trier -ext $ext_serie_a_trier] {
            charge $serie_a_trier$index -rep $rep_serie_a_trier -ext $ext_serie_a_trier -buf $num_buf_tmp
            set fwhm [lmax [buf$num_buf_tmp fwhm [list 1 1 [lindex [buf$num_buf_tmp getkwd "NAXIS1"] 1] [lindex [buf$num_buf_tmp getkwd "NAXIS2"] 1]]]]
            lappend fwhm_list $fwhm
            lappend NoFwhm_list [list $index $fwhm]
         }
         set fwhm_list [lsort -increasing $fwhm_list]
         set NoMax [expr int(0.01*[llength $index_brutes]*$tri)]
         set fwhmMax [lindex $fwhm_list $NoMax]
         console::affiche_resultat "$caption(compute,FWHM_max) [string range $fwhmMax 0 3]...\n"
         foreach NoFwhm $NoFwhm_list {
            if { [lindex $NoFwhm 1] <= $fwhmMax } {
               set index [lindex $NoFwhm 0]
               if {$suppr_apres_tri == 1} {
                  file rename [file join $rep_serie_a_trier $serie_a_trier$index[lindex [decomp $ext] 3]] [file join $rep_tmp tmp_tri_$index[lindex [decomp $ext] 3]]
               } else {
                  # file copy [file join $rep_serie_a_trier $serie_a_trier$index[lindex [decomp $ext] 3]] [file join $rep_tmp tmp_tri_$index[lindex [decomp $ext] 3]]
                  charge [file join $rep_serie_a_trier $serie_a_trier$index$ext] -buf $num_buf_tmp
                  sauve [file join $rep_tmp tmp_tri_$index[lindex [decomp $ext] 3]] -buf $num_buf_tmp
               }
            }
         }
         # Suppression éventuelle de fichiers intermédiaires
         if {$suppr_apres_tri == 1} {
            suppr_serie $serie_a_trier -rep $rep_serie_a_trier -ext $ext_serie_a_trier
         }
      }

      # Recalage des images
      console::affiche_resultat "$caption(compute,tmp_registr_X)"
      # Si les images ont été prises par un instrument équatorial :
      # pas besoin de corriger la rotation de champ
      if {$altaz == 0} {
         aligne tmp_tri_ tmp_registr_ -rep $rep_tmp -ext [lindex [decomp $ext] 3] -in_polyNo $in_polyNo

         # Suppression des images prétraitées
         suppr_serie tmp_tri_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

      } else {
         # Si les images ont été prises par un instrument altazimultal :
         # on corrige ici la rotation de champ

         # Position de l'observateur
         # ATTENTION IL VAUDRAIT MIEUX RÉCUPÉRER CETTE INFO DANS LES EN-TÊTES DES IMAGES !!!
         set posit_obs $audace(posobs,observateur,gps)
         set latit_obs [lindex $posit_obs 3]

         # Date/Heure moyenne de l'observation
         # ATTENTION MÉTHODE UN PEU BRUTE POUR L'INSTANT, ON SE CONTENTE DE
         # RÉCUPÉRER L'INFO POUR LA PREMIÈRE IMAGE QUI TOMBE SOUS LA MAIN
         charge $brutes[lindex $index_brutes 0] -rep $rep -ext $ext -polyNo $in_polyNo -buf $num_buf_tmp
         set date_obs [buf$num_buf_tmp getkwd "DATE-OBS"]

         # On récupère les infos utiles dans l'en-tête de la première image concernant
         # la localisation de l'objet
         charge $brutes[lindex $index_brutes 0] -rep $rep -ext $ext -polyNo $in_polyNo -buf $num_buf_tmp
         set ascdr [lindex [buf$num_buf_tmp getkwd "CRVAL1"] 1]
         set decli [lindex [buf$num_buf_tmp getkwd "CRVAL2"] 1]

         # On calcule ainsi l'azimut et la hauteur de l'objet observé
         set coord_altaz [mc_radec2altaz $ascdr $decli $posit_obs $date_obs]
         set az_obj [lindex $coord_altaz 0]
         set hau_obj [lindex $coord_altaz 1]

         # On en déduit la vitesse angulaire de rotation du champ
         set vit_rotation [expr 15.04 * cos($latit_obs) * cos($az_obj) / cos($hau_obj)]

         # Rotation des images
         foreach index [liste_index tmp_tri_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]] {
            charge tmp_tri_$index -rep $rep_tmp -ext [lindex [decomp $ext] 3] -buf $num_buf_tmp
            set date_ima [buf$num_buf_tmp getkwd "DATE-OBS"]
            set angle_rot [expr ([mc_date2jd $date_obs] - [mc_date2jd $date_ima]) * $vit_rotation / 24]
            buf$num_buf_tmp rot [expr 0.5*[lindex [buf$num_buf_tmp getkwd "NAXIS1"] 1]] [expr 0.5*[lindex [buf$num_buf_tmp getkwd "NAXIS2"] 1]] $angle_rot
            sauve tmp_altaz_$index -rep $rep_tmp -ext [lindex [decomp $ext] 3] -buf $num_buf_tmp
         }

         # Suppression des images prétraitées
         suppr_serie tmp_tri_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

         # Alignement des images corrigées de la rotation de champ
         aligne tmp_altaz_ tmp_registr_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

         # Suppression des images prétraitées
         suppr_serie tmp_altaz_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]
      }

      # Suppression du buffer temporaire
      buf::delete $num_buf_tmp

      # Renumérotation des images sélectionnées
      renumerote tmp_registr_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

      # Compositage
      if {$typeStack == "SK"} {
         # Sigma-Kappa (défaut)
         console::affiche_resultat "$caption(compute,compositage)"
         ttscript2 "IMA/STACK \"$rep_tmp\" tmp_registr_ 1 [llength [liste_index tmp_registr_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]]] [lindex [decomp $ext] 3] \"$rep_tmp\" tmp_finale . [lindex [decomp $ext] 3] SK kappa=3 bitpix=-32"
      } else {
         # Moyenne
         # TODO : rajouter un caption spécifique pour indiquer qu'un compositage par moyenne est en cours
         ttscript2 "IMA/STACK \"$rep_tmp\" tmp_registr_ 1 [llength [liste_index tmp_registr_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]]] [lindex [decomp $ext] 3] \"$rep_tmp\" tmp_finale . [lindex [decomp $ext] 3] MEAN bitpix=-32"
      }

      # Suppression des images triées temporaires
      suppr_serie tmp_registr_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

      # Chargement de l'image finale
      charge tmp_finale -rep $rep_tmp -ext [lindex [decomp $ext] 3]

      # Mise à jour du titre
      ::confVisu::setFileName $audace(visuNo) $caption(compute,imafinale)

      # Suppression de l'image finale sauvée sur le disque
      file delete [file join $rep_tmp tmp_finale[lindex [decomp $ext] 3]]

      # Suppression du répertoire temporaire
      file delete $rep_tmp

      console::affiche_resultat "$caption(compute,fin)"

   } else {

      error $caption(compute,syntax,stellaire)

   }

}

########## The end ##########

