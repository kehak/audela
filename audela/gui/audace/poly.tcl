#
## @file poly.tcl
#  @brief Ensemble de scripts regroupent des fonctions pour gérer des images FITS polychromes
#  @note Documentation @ref poly (fichier poly.htm dans le dossier doc_html)
#  @author Benoit MAUGIS
#  $Id: poly.tcl 13134 2016-02-12 12:30:24Z rzachantke

## @brief Créé une série d'images polychrome à partir de plusieurs séries monochromes
#
proc seriesApoly {args} {
   global audace caption conf

   if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set liste_series [lindex $args 0]
      set nom_poly [lindex $args 1]

      # Configuration des options
      set options [lrange $args 2 [expr [llength $args]-1]]

      # Configuration des options à 1 paramètre
      set options_1param [lindex [range_options $options] 2]

      set rep_index [lsearch -regexp $options_1param "-rep"]
      set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
      set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]

      if {$rep_index>=0} {
         set in_rep [lindex [lindex $options_1param $rep_index] 1]
         set ex_rep [lindex [lindex $options_1param $rep_index] 1]
      } else {
         set in_rep $audace(rep_images)
         set ex_rep $audace(rep_images)
      }
      if {$in_rep_index>=0} {
         set in_rep [lindex [lindex $options_1param $in_rep_index] 1]
      }
      if {$ex_rep_index>=0} {
         set ex_rep [lindex [lindex $options_1param $ex_rep_index] 1]
      }
      if {$ext_index>=0} {
         set ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set ext $conf(extension,defaut)
      } else {
         set ext $conf(extension,defaut).gz
      }

      # Procédure principale
      if {[compare_index_series $liste_series -rep $in_rep]==1} {

         # Création du buffer temporaire
         set num_buf_tmp [buf::create]
         buf$num_buf_tmp extension $conf(extension,defaut)
         set index_serie_max [llength $liste_series]
         foreach index [liste_index [lindex $liste_series 0] -rep $in_rep -ext $ext] {
            for {set k 1} {$k<$index_serie_max} {incr k} {
               buf$num_buf_tmp load [file join $in_rep [lindex $liste_series $k]$index$ext]
               sauve $nom_poly$index -polyNo $k -rep $ex_rep -ext $ext -buf buf$num_buf_tmp
            }
         }
         # Suppression du buffer temporaire
         buf::delete $num_buf_tmp
      } else {
         console::affiche_resultat $caption(poly,erreur_seriesApoly)
      }
   } else {
      error $caption(poly,syntax,seriesApoly)
   }
}

## @brief extrait une série monochrome à partir d'une série d'images polychromes
#
proc polyAserie {args} {
   global audace caption conf

   if {[syntaxe_args $args 3 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep" "-ex_polyNo"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set nom_poly [lindex $args 0]
      set plan_couleur [lindex $args 1]
      set ex [lindex $args 2]

      # Configuration des options
      set options [lrange $args 3 [expr [llength $args]-1]]

      # Configuration des options à 1 paramètre
      set options_1param [lindex [range_options $options] 2]

      set rep_index [lsearch -regexp $options_1param "-rep"]
      set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
      set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]
      set ex_polyNo_index [lsearch -regexp $options_1param "-ex_polyNo"]

      if {$rep_index>=0} {
         set in_rep [lindex [lindex $options_1param $rep_index] 1]
         set ex_rep [lindex [lindex $options_1param $rep_index] 1]
      } else {
         set in_rep $audace(rep_images)
         set ex_rep $audace(rep_images)
      }
      if {$in_rep_index>=0} {
         set in_rep [lindex [lindex $options_1param $in_rep_index] 1]
      }
      if {$ex_rep_index>=0} {
         set ex_rep [lindex [lindex $options_1param $ex_rep_index] 1]
      }
      if {$ext_index>=0} {
         set ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set ext $conf(extension,defaut)
      } else {
         set ext $conf(extension,defaut).gz
      }
      if {$ex_polyNo_index>=0} {
         set ex_polyNo [lindex [lindex $options_1param $ex_polyNo_index] 1]
      } else {
         set ex_polyNo 1
      }

      # Procédure principale
      if {[poly_nbcouleurs $nom_poly -rep $in_rep -ext $ext]>=$plan_couleur} {

         # Création du buffer temporaire
         set num_buf_tmp [buf::create]
         buf$num_buf_tmp extension $conf(extension,defaut)
         foreach index [liste_index $nom_poly -rep $in_rep -ext $ext] {
            buf$num_buf_tmp load [file join $in_rep "$nom_poly$index$ext;$plan_couleur"]
            sauve $ex$index -polyNo $ex_polyNo -buf $num_buf_tmp -rep $ex_rep -ext $ext
         }
         # Suppression du buffer temporaire
         buf::delete $num_buf_tmp
      }
   } else {
      error $caption(poly,syntax,polyAserie)
   }
}

## @brief convertit une série d'images polychromes en plusieurs séries monochromes
#
proc polyAseries {args} {
   global audace caption conf

   if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set nom_poly [lindex $args 0]
      set liste_series [lindex $args 1]

      # Configuration des options
      set options [lrange $args 2 [expr [llength $args]-1]]

      # Configuration des options à 1 paramètre
      set options_1param [lindex [range_options $options] 2]

      set rep_index [lsearch -regexp $options_1param "-rep"]
      set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
      set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]

      if {$rep_index>=0} {
         set in_rep [lindex [lindex $options_1param $rep_index] 1]
         set ex_rep [lindex [lindex $options_1param $rep_index] 1]
      } else {
         set in_rep $audace(rep_images)
         set ex_rep $audace(rep_images)
      }
      if {$in_rep_index>=0} {
         set in_rep [lindex [lindex $options_1param $in_rep_index] 1]
      }
      if {$ex_rep_index>=0} {
         set ex_rep [lindex [lindex $options_1param $ex_rep_index] 1]
      }
      if {$ext_index>=0} {
         set ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set ext $conf(extension,defaut)
      } else {
         set ext $conf(extension,defaut).gz
      }

      # Procédure principale
      if {[poly_nbcouleurs $nom_poly -rep $in_rep -ext $ext]==[llength $liste_series]} {

         set index_serie_max [llength $liste_series]
         for {set k 0} {$k<=$index_serie_max} {incr k} {
            polyAserie ${nom_poly} [expr $k+1] [lindex $liste_series $k] -in_rep $in_rep -ex_rep $ex_rep -ext $ext
         }
      } else {
         console::affiche_resultat $caption(poly,erreur_polyAseries)
      }
   } else {
      error $caption(poly,syntax,polyAseries)
   }
}

## @brief retourne le nombre de plans couleurs de la série
#
proc poly_nbcouleurs {args} {
   global audace caption conf

   if {[syntaxe_args $args 1 0 [list "" [list "-rep" "-ext"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set serie [lindex $args 0]

      # Configuration des options
      set options [lrange $args 1 [expr [llength $args]-1]]

      # Configuration des options à 1 paramètre
      set options_1param [lindex [range_options $options] 2]

      set rep_index [lsearch -regexp $options_1param "-rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]

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

      # Procédure principale
      # On sélectionne le fichier que l'on va tester (le dernier de la série)
      set liste_index [liste_index $serie -rep $rep -ext $ext]
      set index [lindex $liste_index [expr [llength $liste_index]-1]]
      set fichier [file join $rep $serie$index$ext]
      set k 1
      set continuer 1
      # Création du buffer temporaire
      set num_buf_tmp [buf::create]
      buf$num_buf_tmp extension $conf(extension,defaut)
      # Tests
      while {$continuer==1} {
         if [catch {buf$num_buf_tmp load "$fichier;[expr $k+1]"}] {
            set continuer 0
         } else {
            incr k
         }
      }

      # Suppression du buffer temporaire
      buf::delete $num_buf_tmp

      return $k
   } else {
      error $caption(poly,syntax,poly_nbcouleurs)
   }
}

## @brief fenêtrage d'une série de fichiers polychromes
#
proc poly_fenetre {args} {
   global audace caption conf

   if {[syntaxe_args $args 3 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set in [lindex $args 0]
      set ex [lindex $args 1]
      set coord [lindex $args 2]

      # Configuration des options
      set options [lrange $args 3 [expr [llength $args]-1]]

      # Configuration des options à 1 paramètre
      set options_1param [lindex [range_options $options] 2]

      set rep_index [lsearch -regexp $options_1param "-rep"]
      set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
      set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]

      if {$rep_index>=0} {
         set in_rep [lindex [lindex $options_1param $rep_index] 1]
         set ex_rep [lindex [lindex $options_1param $rep_index] 1]
      } else {
         set in_rep $audace(rep_images)
         set ex_rep $audace(rep_images)
      }
      if {$in_rep_index>=0} {
         set in_rep [lindex [lindex $options_1param $in_rep_index] 1]
      }
      if {$ex_rep_index>=0} {
         set ex_rep [lindex [lindex $options_1param $ex_rep_index] 1]
      }
      if {$ext_index>=0} {
         set ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set ext $conf(extension,defaut)
      } else {
         set ext $conf(extension,defaut).gz
      }

      # Procédure principale
      for {set k 1} {$k<=[poly_nbcouleurs $in -rep $in_rep]} {incr k} {
         serie_fenetre $in $ex $coord -in_rep $in_rep -ex_rep $ex_rep -ext $ext -polyNo $k
      }
   } else {
      error $caption(poly,syntax,poly_fenetre)
   }
}

## @brief fenêtrage d'une série de fichiers polychromes avec la souris
#
proc poly_souris_fenetre {args} {
   global audace caption conf

   if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set in [lindex $args 0]
      set ex [lindex $args 1]

      # Configuration des options
      set options [lrange $args 2 [expr [llength $args]-1]]

      # Configuration des options à 1 paramètre
      set options_1param [lindex [range_options $options] 2]

      set rep_index [lsearch -regexp $options_1param "-rep"]
      set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
      set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]

      if {$rep_index>=0} {
         set in_rep [lindex [lindex $options_1param $rep_index] 1]
         set ex_rep [lindex [lindex $options_1param $rep_index] 1]
      } else {
         set in_rep $audace(rep_images)
         set ex_rep $audace(rep_images)
      }
      if {$in_rep_index>=0} {
         set in_rep [lindex [lindex $options_1param $in_rep_index] 1]
      }
      if {$ex_rep_index>=0} {
         set ex_rep [lindex [lindex $options_1param $ex_rep_index] 1]
      }
      if {$ext_index>=0} {
         set ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set ext $conf(extension,defaut)
      } else {
         set ext $conf(extension,defaut).gz
      }

      # Procédure principale
      set rect [ ::confVisu::getBox 1 ]
      poly_fenetre $in $ex $rect -in_rep $in_rep -ex_rep $ex_rep -ext $ext
   } else {
      error $caption(poly,syntax,poly_souris_fenetre)
   }
}

## @brief transforme une série d'images polychromes
# par rotation d'angle "angle" et de centre ("x0", "y0")
#
proc poly_rot {args} {
   global audace caption conf

   if {[syntaxe_args $args 5 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set in [lindex $args 0]
      set ex [lindex $args 1]
      set x0 [lindex $args 2]
      set y0 [lindex $args 3]
      set angle [lindex $args 4]

      # Configuration des options
      set options [lrange $args 5 [expr [llength $args]-1]]

      # Configuration des options à 1 paramètre
      set options_1param [lindex [range_options $options] 2]

      set rep_index [lsearch -regexp $options_1param "-rep"]
      set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
      set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]

      if {$rep_index>=0} {
         set in_rep [lindex [lindex $options_1param $rep_index] 1]
         set ex_rep [lindex [lindex $options_1param $rep_index] 1]
      } else {
         set in_rep $audace(rep_images)
         set ex_rep $audace(rep_images)
      }
      if {$in_rep_index>=0} {
         set in_rep [lindex [lindex $options_1param $in_rep_index] 1]
      }
      if {$ex_rep_index>=0} {
         set ex_rep [lindex [lindex $options_1param $ex_rep_index] 1]
      }
      if {$ext_index>=0} {
         set ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set ext $conf(extension,defaut)
      } else {
         set ext $conf(extension,defaut).gz
      }

      # Procédure principale
      for {set k 1} {$k<=[poly_nbcouleurs $in -rep $in_rep]} {incr k} {
         serie_rot $in $ex $x0 $y0 $angle -in_rep $in_rep -ex_rep $ex_rep -ext $ext -polyNo $k
      }
   } else {
      error $caption(poly,syntax,poly_rot)
   }
}

## @brief transforme une série d'images polychromes par translation
#
proc poly_trans {args} {
   global audace caption conf

   if {[syntaxe_args $args 4 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set in [lindex $args 0]
      set ex [lindex $args 1]
      set dx [lindex $args 2]
      set dy [lindex $args 3]

      # Configuration des options
      set options [lrange $args 4 [expr [llength $args]-1]]

      # Configuration des options à 1 paramètre
      set options_1param [lindex [range_options $options] 2]

      set rep_index [lsearch -regexp $options_1param "-rep"]
      set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
      set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]

      if {$rep_index>=0} {
         set in_rep [lindex [lindex $options_1param $rep_index] 1]
         set ex_rep [lindex [lindex $options_1param $rep_index] 1]
      } else {
         set in_rep $audace(rep_images)
         set ex_rep $audace(rep_images)
      }
      if {$in_rep_index>=0} {
         set in_rep [lindex [lindex $options_1param $in_rep_index] 1]
      }
      if {$ex_rep_index>=0} {
         set ex_rep [lindex [lindex $options_1param $ex_rep_index] 1]
      }
      if {$ext_index>=0} {
         set ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set ext $conf(extension,defaut)
      } else {
         set ext $conf(extension,defaut).gz
      }

      # Procédure principale
      for {set k 1} {$k<=[poly_nbcouleurs $in -rep $in_rep]} {incr k} {
         serie_trans $in $ex $dx $dy -in_rep $in_rep -ex_rep $ex_rep -ext $ext -polyNo $k
      }
   } else {
      error $caption(poly,syntax,poly_trans)
   }
}

## @brief registration manuelle entre plusieurs séries d'images polychromes par translation et rotation
#
proc poly_series_traligne {args} {
   global audace caption conf script

   if {[syntaxe_args $args 3 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set liste_in [lindex $args 0]
      set No_ref [lindex $args 1]
      set ex [lindex $args 2]

      # Configuration des options
      set options [lrange $args 3 [expr [llength $args]-1]]

      # Configuration des options à 1 paramètre
      set options_1param [lindex [range_options $options] 2]

      set rep_index [lsearch -regexp $options_1param "-rep"]
      set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
      set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]

      if {$rep_index>=0} {
         set in_rep [lindex [lindex $options_1param $rep_index] 1]
         set ex_rep [lindex [lindex $options_1param $rep_index] 1]
      } else {
         set in_rep $audace(rep_images)
         set ex_rep $audace(rep_images)
      }
      if {$in_rep_index>=0} {
         set in_rep [lindex [lindex $options_1param $in_rep_index] 1]
      }
      if {$ex_rep_index>=0} {
         set ex_rep [lindex [lindex $options_1param $ex_rep_index] 1]
      }
      if {$ext_index>=0} {
         set ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set ext $conf(extension,defaut)
      } else {
         set ext $conf(extension,defaut).gz
      }

      # Procédure principale
      # On supprime d'éventuels fichiers déjà présents de la série-cible
      suppr_serie $ex -rep $ex_rep -ext $ext

      # La série de référence est recopiée sans modifications
      set serie_ref [lindex $liste_in 0]
      copie $serie_ref $ex -in_rep $in_rep -ex_rep $ex_rep -ext $ext
      # Tout au plus on la renumérote.
      renumerote $ex -rep $ex_rep -ext $ext

      # On garde en mémoire le nom du dernier fichier de cette série, qui servira de
      # référence pour recaler la série suivante
      set liste_index_ref [lsort -integer [liste_index $ex -rep $ex_rep -ext $ext]]
      set index_ref [lindex $liste_index_ref [expr [llength $liste_index_ref]-1]]
      set fichier_ref [file join $ex_rep "$ex$index_ref$ext;$No_ref"]

      # A présent, on fait les transformations sur les autres séries :
      set series_amodif [lrange $liste_in 1 [expr [llength $liste_in]-1]]

      # Les fichiers temporaires sont stockés dans un répertoire temporaire
      set rep_tmp [cree_sousrep -rep $ex_rep -nom_base "tmp_poly_series_traligne"]

      foreach serie $series_amodif {

         # On détermine le cadre de référence ;
         console::affiche_resultat "$caption(poly,series_trreg_cadre-ref) $serie\n"
         loadima $fichier_ref

         # Création de la fenêtre
         set script(poly_series_traligne,attente) 0
         toplevel .poly_series_traligne
         label .poly_series_traligne.lab -text $caption(poly,tracebox)
         pack .poly_series_traligne.lab -expand true
         button .poly_series_traligne.but -command {set script(poly_series_traligne,attente) 0} -text "ok"
         pack .poly_series_traligne.but -expand true

         # On attend que l'utilisateur ait validé
         vwait script(poly_series_traligne,attente)

         # On supprime la fenêtre
         destroy .poly_series_traligne

         # On enregistre les coordonnées du cadre
         set cadre_ref [ ::confVisu::getBox 1 ]

         console::affiche_resultat "$caption(poly,series_trreg_cadre-a-rec) $serie\n"
         # Chargement du premier fichier de la série courante
         set liste_index [lsort -integer [liste_index $serie -rep $in_rep -ext $ext]]
         loadima [file join $in_rep "$serie[lindex $liste_index 0]$ext;$No_ref"]

         # Création de la fenêtre
         set script(poly_series_traligne,attente) 0
         toplevel .poly_series_traligne
         label .poly_series_traligne.lab -text $caption(poly,tracebox)
         pack .poly_series_traligne.lab -expand true
         button .poly_series_traligne.but -command {set script(poly_series_traligne,attente) 0} -text "ok"
         pack .poly_series_traligne.but -expand true
         # On attend que l'utilisateur ait validé
         vwait script(poly_series_traligne,attente)
         # On supprime la fenêtre
         destroy .poly_series_traligne
         # On enregistre les coordonnées du cadre
         set cadre_amodif [ ::confVisu::getBox 1 ]
         # Calcul des modifications de translation / rotation
         set modifs [calcul_trzaligne $cadre_ref $cadre_amodif]

         # Translation (en entiers pour éviter de dégrader la résolution)
         console::affiche_resultat "$caption(poly,series_trreg_transl) $serie\n"
         poly_trans $serie tmp_trans_$serie [expr round([lindex $modifs 0])] [expr round([lindex $modifs 1])] -in_rep $in_rep -ex_rep $rep_tmp -ext $ext
         # Rotation
         console::affiche_resultat "$caption(poly,series_trreg_rot) $serie\n"
         poly_rot tmp_trans_$serie tmp_rot_$serie [lindex $modifs 2] [lindex $modifs 3] [lindex $modifs 4] -rep $rep_tmp -ext $ext
         # Suppression de la série temporaire de translation (si on n'avait pas cette série temporaire,
         # l'auto-écrasement bugge)
         suppr_serie tmp_trans_$serie -rep $rep_tmp -ext $ext
         # On renomme vers la série de destination
         renomme tmp_rot_$serie $ex -in_rep $rep_tmp -ex_rep $ex_rep -ext $ext

         # On garde en mémoire le nom du dernier fichier de cette série, qui servira de
         # référence pour recaler la série suivante
         set liste_index_ref [lsort -integer [liste_index $ex -rep $ex_rep -ext $ext]]
         set index_ref [lindex $liste_index_ref [expr [llength $liste_index_ref]-1]]
         set fichier_ref [file join $ex_rep "$ex$index_ref$ext;$No_ref"]
      }

      # Suppression du répertoire temporaire
      file delete $rep_tmp
   } else {
      error $caption(poly,syntax,poly_series_traligne)
   }
}

########## The end ##########

