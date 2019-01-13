#
## @file divers.tcl
#  @brief Ces scripts regroupent diverses petites fonctions
#  @note Documentation : @ref divers (fichier divers.htm dans le dossier doc_html)
#  @author Benoit MAUGIS
#  $Id: divers.tcl 13545 2016-03-30 15:18:03Z rzachantke $
#

######################################################
###############   Fonctions basiques   ###############
######################################################

## @brief charge un fichier
#  @details documentation de cette fonction : @ref divers
#
proc charge {args} {
   global audace caption conf

   if {[syntaxe_args $args 0 1 [list [list "-novisu" "-dovisu"] [list "-buf" "-rep" "-ext" "-polyNo"]]]=="1"} {

      # Configuration des options
      set range_options [range_options $args]

      # Configuration des paramètres optionnels
      set params_optionnels [lindex $range_options 0]
      if {[llength $params_optionnels] == "0"} {
         set fichier "?"
      } else {
         set fichier [lindex $params_optionnels 0]
      }

      # Configuration des options sans paramètre
      set options_0param [lindex $range_options 1]
      set novisu_index [lsearch $options_0param "-novisu"]
      if {$novisu_index>=0} {
         set novisu "-novisu"
      } else {
         set novisu "-dovisu"
      }

      # Configuration des options à 1 paramètre
      set options_1param [lindex $range_options 2]

      set buf_index [lsearch -regexp $options_1param "-buf"]
      set rep_index [lsearch -regexp $options_1param "-rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]
      set polyNo_index [lsearch -regexp $options_1param "-polyNo"]

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

      # Procédure principale
      # 1er cas : pas de nom de fichier donné, on doit donc afficher une boîte de dialogue
      if {$fichier == "?"} {
         #--- Fenetre parent
         set fenetre "$audace(base)"
         #--- Ouvre la boite de choix des images
         set nom_complet [ ::tkutil::box_load $fenetre $rep $buf "1" ]
       # 2nd cas : selon $fichier, on rajoute ou pas les infos de nom de
       # répertoire et d'extension pour former le nom complet.
      } else {
         # Nom relatif ou absolu...
         if {[file pathtype $fichier] == "absolute"} {
            set nom_complet $fichier
         } else {
            set nom_complet [file join "$rep" "$fichier"]
         }
         # Extension comprise ou pas...
         if {[file extension $fichier] == ""} {
            set nom_complet $nom_complet$ext
         }
      }

      # On n'ajoute le n° de plan couleur à ouvrir que si celui-ci est distinct du 1er
      if {$in_polyNo != "1"} {
         set nom_complet "$nom_complet;$in_polyNo"
      }

      if {[string compare $nom_complet ""] != 0 } {

         # Si le fichier est compressé par bzip2, on le copie dans le répertoire
         # temporaire pour le décompresser

         if {[file extension $nom_complet] == ".bz2"} {

            switch $::tcl_platform(os) {
               "Linux" {
                  # Sous Linux, on copie le fichier dans un sous-répertoire de /tmp/.audela
                  # on le décompresse et on essaie de le recharger à partir de là
                  set dossier_tmp [cree_sousrep -nom_base [suppr_accents [file tail $fichier]] -rep "/tmp/.audela"]
                  set fichier_tmp [file join $dossier_tmp [file tail $nom_complet]]
                  file copy $nom_complet $fichier_tmp
                  exec bunzip2 $fichier_tmp
                  # rustine
                  catch {file rename [file rootname $fichier_tmp] [file rootname [file rootname $fichier_tmp]]$conf(extension,defaut)}
                  charge [file rootname [file rootname $fichier_tmp]] -ext $conf(extension,defaut) -buf $buf -novisu
                  file delete [file rootname [file rootname $fichier_tmp]]$conf(extension,defaut)
                  file delete $dossier_tmp
                  # Si chargement dans le buffer Aud'ACE :
                  # on rafraîchit (éventuellement) l'affichage du bandeau
                  if {[string compare $buf $audace(bufNo)] == 0} {
                     if {$novisu != "-novisu"} {
                        ::confVisu::setFileName $audace(visuNo) "$nom_complet"
                        ::audace::autovisu $audace(visuNo)
                     }
                  }
               }
               "Darwin" {
                  # Sous MacOS : idem Linux, on copie le fichier
                  # dans un sous-répertoire de /tmp/.audela
                  # on le décompresse et on essaie de le recharger à partir de là.
                  set dossier_tmp [cree_sousrep -nom_base [suppr_accents [file tail $fichier]] -rep "/tmp/.audela"]
                  set fichier_tmp [file join $dossier_tmp [file tail $nom_complet]]
                  file copy $nom_complet $fichier_tmp
                  exec bunzip2 $fichier_tmp
                  # rustine
                  catch {file rename [file rootname $fichier_tmp] [file rootname [file rootname $fichier_tmp]]$conf(extension,defaut)}
                  charge [file rootname [file rootname $fichier_tmp]] -ext $conf(extension,defaut) -buf $buf -novisu
                  file delete [file rootname [file rootname $fichier_tmp]]$conf(extension,defaut)
                  file delete $dossier_tmp
                  # Si chargement dans le buffer Aud'ACE :
                  # on rafraîchit (éventuellement) l'affichage du bandeau
                  if {[string compare $buf $audace(bufNo)] == 0} {
                     if {$novisu != "-novisu"} {
                        ::confVisu::setFileName $audace(visuNo) "$nom_complet"
                        ::audace::autovisu $audace(visuNo)
                     }
                  }
               }
               default {
                  # Sous les autres systèmes d'exploitation (dont Windows)
                  # les fichiers .fit.bz2 ne sont pas pris en charge.
               }
            }

         } else {

            # On vérifie que le nom de fichier est valide, ie ne comporte
            # pas d'accents, sinon la librairie fitsio sera incapable de
            # de le charger.

            if {[nom_valide $nom_complet]==1} {

               if {[string compare $buf $audace(bufNo)] == 0} {
                  loadima "$nom_complet" $audace(visuNo) $novisu
               } else {
                  buf$buf load "$nom_complet"
               }

            } else {

               # Le nom complet de fichier comporte des caractères accentués.
               switch $::tcl_platform(os) {
                  "Linux" {
                     # Sous Linux, on copie le fichier dans /tmp/.audela
                     # en supprimant les caractères accentués et on essaie
                     # de le recharger à partir de là.
                     set fichier_tmp [cree_fichier -nom_base [suppr_accents [file tail $fichier]] -rep "/tmp/.audela"]
                     file delete $fichier_tmp
                     file copy $fichier $fichier_tmp
                     charge $fichier_tmp -buf $buf -novisu
                     file delete $fichier_tmp
                     # Si chargement dans le buffer Aud'ACE :
                     # on rafraîchit (éventuellement) l'affichage du bandeau
                     if {[string compare $buf $audace(bufNo)] == 0} {
                        if {$novisu != "-novisu"} {
                           ::confVisu::setFileName $audace(visuNo) "$nom_complet"
                           ::audace::autovisu $audace(visuNo)
                        }
                     }
                  }
                  default {
                     # Sous les autres systèmes d'exploitation (dont Windows)
                     # faute d'un dossier temporaire bien défini, on signale
                     # le problème sans y remédier.
                     console::affiche_resultat "${caption(divers,nom_invalide)}\n $nom_complet\n"
                  }
               }
            }
         }
      }
   } else {
      error $caption(divers,syntax,charge)
   }
}

## @brief sauve un fichier
#  @details documentation de cette fonction : @ref divers
#
proc sauve {args} {
   global audace caption conf

   if {[syntaxe_args $args 0 1 [list "" [list "-buf" "-rep" "-ext" "-polyNo"]]]=="1"} {

      # Configuration des options
      set range_options [range_options $args]

      # Configuration des paramètres optionnels
      set params_optionnels [lindex $range_options 0]
      if {[llength $params_optionnels] == "0"} {
         set fichier "?"
      } else {
         set fichier [lindex $params_optionnels 0]
      }

      # Configuration des options à 1 paramètre
      set options_1param [lindex $range_options 2]

      set buf_index [lsearch -regexp $options_1param "-buf"]
      set rep_index [lsearch -regexp $options_1param "-rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]
      set polyNo_index [lsearch -regexp $options_1param "-polyNo"]

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
         set polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      } else {
         set polyNo 1
      }

      #--- Les mots cles NAXIS, NAXIS1 et NAXIS2 sont obligatoires pour executer la commande save
      buf$buf setkwd [ list NAXIS 2 int "" "" ]
      buf$buf setkwd [ list NAXIS1 [ buf$buf getpixelswidth ] int "" "" ]
      buf$buf setkwd [ list NAXIS2 [ buf$buf getpixelsheight ] int "" "" ]

      # Procédure principale
      # 1er cas : pas de nom de fichier donné, on doit donc afficher une boîte de dialogue
      if {$fichier == "?"} {
         #--- Fenetre parent
         set fenetre "$audace(base)"
         #--- Ouvre la boite de choix des images
         set nom_complet [ ::tkutil::box_save $fenetre $rep $buf "1" ]

         # 2nd cas : selon $fichier, on rajoute ou pas les infos de nom de
         # répertoire et d'extension pour former le nom complet.
      } else {
         # Nom relatif ou absolu...
         if {[file pathtype $fichier] == "absolute"} {
            set nom_complet $fichier
         } else {
            set nom_complet [file join "$rep" "$fichier"]
         }
         # Extension comprise ou pas...
         if {[file extension $fichier] == ""} {
            set nom_complet $nom_complet$ext
         }
      }

      if {[string compare $nom_complet ""] != 0 } {
         if { [ buf$buf imageready ] == "1" } {
            # Si le fichier de destination n'existe pas, on ne tient pas compte du n° de buffer dans lequel sauvegarder
            if {[file exist $nom_complet] == "0"} {
               set result [buf$buf save "$nom_complet"]
            } else {
               # Fichier existant avec éventuellement plusieurs plans couleurs :

               # 1er cas : on veut sauvegarder sur un numéro de plan couleur
               # supérieur à tous ceux existants : pas de problèmes.
               set dern_num_buf [buf::create]
               buf$dern_num_buf extension $conf(extension,defaut)
               if [catch {charge $nom_complet -buf $dern_num_buf -polyNo $polyNo}] {
                  buf::delete $dern_num_buf
                  set result [buf$buf save "$nom_complet;$polyNo"]
               } else {

                  buf::delete $dern_num_buf

                  # Second cas : on veut enregistrer sur un plan couleur
                  # déjà existant, por éviter un bug on doit charger tous les plans couleurs,
                  # effacer le fichier existant et tout réenregistrer dans l'ordre.

                  # Chargement des plans couleurs dans des buffers temporaires
                  set liste_buf_tmp ""
                  set no_plan 1
                  while {$continuer==1} {
                  set continuer "1"
                     set dern_num_buf [buf::create]
                     buf$dern_num_buf extension $conf(extension,defaut)
                     if [catch {charge $nom_complet -buf $dern_num_buf -polyNo $no_plan}] {
                        set continuer 0
                        buf::delete $dern_num_buf
                     } else {
                        lappend liste_buf_tmp $dern_num_buf
                     }
                     incr no_plan
                  }

                  # Effacement du fichier
                  file delete $nom_complet
                  # Enregistrement des plans couleurs successifs et libération des
                  # tampons images correspondant

                  # On fait le premier plan à part...
                  if {"1" == $polyNo} {
                     set result [buf$buf save "$nom_complet"]
                  } else {
                     set result [buf[lindex $liste_buf_tmp 0] save "$nom_complet"]
                  }
                  buf::delete [lindex $liste_buf_tmp 0]

                  # ... puis les autres.
                  for {set no_plan 2} {$no_plan <= [llength $liste_buf_tmp]} {incr no_plan} {
                     if {$no_plan == $polyNo} {
                        set result [buf$buf save "$nom_complet;$no_plan"]
                     } else {
                        set result [buf[lindex $liste_buf_tmp [expr $no_plan-1]] save "$nom_complet;$no_plan"]
                     }
                     buf::delete [lindex $liste_buf_tmp [expr $no_plan-1]]
                  }
               }
               set nom_complet "nom_complet;$polyNo"
            }
            if {$result == "" && [string compare $buf $audace(bufNo)] == 0} {
               ::confVisu::setFileName $audace(visuNo) "$nom_complet"
            }
         }
      }

   } else {
      error $caption(divers,syntax,sauve)
   }
}


## @brief sauve une image au format jpeg
#  @details documentation de cette fonction : @ref divers
#
proc sauve_jpeg {args} {
   global audace caption conf

   if {[syntaxe_args $args 0 1 [list "" [list "-buf" "-rep" "-ext"]]]=="1"} {

      # Configuration des options
      set range_options [range_options $args]

      # Configuration des paramètres optionnels
      set params_optionnels [lindex $range_options 0]
      if {[llength $params_optionnels] == "0"} {
         set fichier "?"
      } else {
         set fichier [lindex $params_optionnels 0]
      }

      # Configuration des options à 1 paramètre
      set options_1param [lindex $range_options 2]

      set buf_index [lsearch -regexp $options_1param "-buf"]
      set rep_index [lsearch -regexp $options_1param "-rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]

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
      } else {
         set ext ".jpg"
      }

      # Procédure principale
      # 1er cas : pas de nom de fichier donné, on doit donc afficher une boîte de dialogue
      if {$fichier == "?"} {
         #--- Fenetre parent
         set fenetre "$audace(base)"
         #--- Ouvre la boite de choix des images
         set nom_complet [ ::tkutil::box_save $fenetre $rep $buf "2" ]
      } else {
         set nom_complet [ file join "$rep" [ file rootname [ file tail "$fichier$ext" ] ] ]
      }

      if {[string compare $nom_complet ""] != 0 } {
         if { [ buf$buf imageready ] == "1" } {

            # On récupère la fonction de transfert
            set palette [file join [visu$audace(visuNo) paldir] [visu$audace(visuNo) pal].pal]
            set fileId [open $palette r]
            set palette_R ""
            set palette_V ""
            set palette_B ""
            for {set k 0} {$k<256} {incr k} {
               gets $fileId ligne
               lappend palette_R [lindex $ligne 0]
               lappend palette_V [lindex $ligne 1]
               lappend palette_B [lindex $ligne 2]
            }
            close $fileId

            # Création du buffer temporaire
            set num_buf_tmp [buf::create]
            buf$num_buf_tmp extension $conf(extension,defaut)

            # Création d'un répertoire temporaire
            set rep_tmp [cree_sousrep -nom_base "tmp_sauve_jpeg"]

            # Enregistrement des plans R, V et B
            # plan R
            buf$buf copyto $num_buf_tmp
            set catchError [ catch { bm_hard2visu $num_buf_tmp [lindex [visu$audace(visuNo) cut] 0] [lindex [visu$audace(visuNo) cut] 1] ${palette_R} } ]
            if { $catchError == "1" } {
               # Affichage d'un message d'erreur
               ::tkutil::displayErrorInfo "$caption(divers,copyjpeg)" "$caption(divers,libgsl)"
               # Suppression du buffer temporaire
               buf::delete $num_buf_tmp
               # Suppression du répertoire temporaire
               file delete $rep_tmp
               # Sortie de la procedure
               return
            }
            sauve plan_R -buf $num_buf_tmp -rep "$rep_tmp" -ext $conf(extension,defaut)
            # plan V
            buf$buf copyto $num_buf_tmp
            bm_hard2visu $num_buf_tmp [lindex [visu$audace(visuNo) cut] 0] [lindex [visu$audace(visuNo) cut] 1] ${palette_V}
            sauve plan_V -buf $num_buf_tmp -rep "$rep_tmp" -ext $conf(extension,defaut)
            # plan B
            buf$buf copyto $num_buf_tmp
            bm_hard2visu $num_buf_tmp [lindex [visu$audace(visuNo) cut] 0] [lindex [visu$audace(visuNo) cut] 1] ${palette_B}
            sauve plan_B -buf $num_buf_tmp -rep "$rep_tmp" -ext $conf(extension,defaut)

            # Suppression du buffer temporaire
            buf::delete $num_buf_tmp

            # Enregistrement de l'image
            fits2colorjpeg [file join $rep_tmp plan_R$conf(extension,defaut)] [file join $rep_tmp plan_V$conf(extension,defaut)] [file join $rep_tmp plan_B$conf(extension,defaut)] $nom_complet $conf(jpegquality,defaut) [lindex [visu$audace(visuNo) cut] 1] [lindex [visu$audace(visuNo) cut] 0] [lindex [visu$audace(visuNo) cut] 1] [lindex [visu$audace(visuNo) cut] 0] [lindex [visu$audace(visuNo) cut] 1] [lindex [visu$audace(visuNo) cut] 0]

            # Suppression des fichiers temporaires
            file delete [file join $rep_tmp plan_R$conf(extension,defaut)]
            file delete [file join $rep_tmp plan_V$conf(extension,defaut)]
            file delete [file join $rep_tmp plan_B$conf(extension,defaut)]
            file delete $rep_tmp
         }
      }

   } else {
      error $caption(divers,syntax,sauve_jpeg)
   }
}

## @brief soustrait d'une image sauvegardée sur disque à une image en mémoire tampon (buffer)
#  @details documentation de cette fonction : @ref divers
#
proc soustrait {args} {
   global audace caption conf

   if {[syntaxe_args $args 1 0 [list "" [list "-buf" "-rep" "-ext" "-polyNo"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set fichier_aux [lindex $args 0]

      # Configuration des options
      set options [lrange $args 1 [expr [llength $args]-1]]
      set range_options [range_options $options]

      # Configuration des options à 1 paramètre
      set options_1param [lindex $range_options 2]

      set buf_index [lsearch -regexp $options_1param "-buf"]
      set rep_index [lsearch -regexp $options_1param "-rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]
      set polyNo_index [lsearch -regexp $options_1param "-polyNo"]

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
         set aux_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      } else {
         set aux_polyNo 1
      }

      # Procédure principale
      buf$buf sub [file join "$rep" "$fichier_aux$ext;$aux_polyNo"] 0

      # Si le buffer de travail est le buffer Aud'ACE, on refraîchit l'affichage
      if {$audace(bufNo) == $buf} {
         ::audace::autovisu $audace(visuNo)
      }

   } else {
      error $caption(divers,syntax,soustrait)
   }
}

## @brief normalise une image en mémoire tampon (buffer) par une image sauvegardée sur disque
#  @details documentation de cette fonction : @ref divers
#
proc normalise {args} {
   global audace caption conf

   if {[syntaxe_args $args 1 0 [list "" [list "-buf" "-rep" "-ext" "-polyNo"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set fichier_aux [lindex $args 0]

      # Configuration des options
      set options [lrange $args 1 [expr [llength $args]-1]]
      set range_options [range_options $options]

      # Configuration des options à 1 paramètre
      set options_1param [lindex $range_options 2]

      set buf_index [lsearch -regexp $options_1param "-buf"]
      set rep_index [lsearch -regexp $options_1param "-rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]
      set polyNo_index [lsearch -regexp $options_1param "-polyNo"]

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
         set aux_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      } else {
         set aux_polyNo 1
      }

      # Procédure principale
      # Création d'un tampon image temporaire
      set num_buf_tmp [buf::create]
      buf$num_buf_tmp extension $conf(extension,defaut)
      # On charge l'image auxiliaire pour déterminer la moyenne de son fond de ciel
      charge $fichier_aux -buf $num_buf_tmp -rep "$rep" -ext $ext -polyNo $aux_polyNo
      set moy [lindex [buf$num_buf_tmp stat] 6]
      # Suppression du buffer temporaire
      buf::delete $num_buf_tmp

      # Normalisation
      buf$buf div [file join "$rep" "$fichier_aux$ext;$aux_polyNo"] $moy

      # Si le buffer de travail est le buffer Aud'ACE, on rafraîchit l'affichage
      if {$audace(bufNo) == $buf} {
         ::audace::autovisu $audace(visuNo)
      }

   } else {
      error $caption(divers,syntax,normalise)
   }
}

######################################################
###############   Fonctions de séries  ###############
######################################################

## @brief supprime des fichiers de type "nom_generique1", "nom_generique2", etc
#  @details documentation de cette fonction : @ref divers
#
proc suppr_serie {args} {
   global audace caption conf

   if {[syntaxe_args $args 1 0 [list "" [list "-rep" "-ext"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set nom_generique [lindex $args 0]

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
      set index_corbeille [liste_index $nom_generique -rep "$rep" -ext $ext]
      foreach index $index_corbeille {file delete [file join "$rep" $nom_generique$index$ext]}
   } else {
      error $caption(divers,syntax,suppr_serie)
   }
}

## @brief supprime la fin d'une série (fichiers dont l'index est strictement supérieur à "index_fin")
#  @details documentation de cette fonction : @ref divers
#
proc suppr_fin_serie {args} {
   global audace caption conf

   if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set nom_generique [lindex $args 0]
      set index_fin [lindex $args 1]

      # Configuration des options
      set options [lrange $args 2 [expr [llength $args]-1]]

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
      set index_cibles [lsort [liste_index $nom_generique -rep "$rep" -ext $ext]]
      catch {set index_cibles [lsort -integer $index_cibles]}
      set index_fin [lsearch -regexp -exact $index_cibles $index_fin]
      if {$index_fin>=0} {
         set index_1 [expr $index_fin+1]
         set index_2 [expr [llength $index_cibles-1]]
         set index_corbeille [lrange $index_cibles $index_1 $index_2]
         foreach index $index_corbeille {file delete [file join "$rep" $nom_generique$index$ext]}
      }
   } else {
      error $caption(divers,syntax,suppr_fin_serie)
   }
}

## @brief supprime du début d'une série (fichiers dont l'index est strictement inférieur à "index_debut")
#  @details documentation de cette fonction : @ref divers
#
proc suppr_debut_serie {args} {
   global audace caption conf

   if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set nom_generique [lindex $args 0]
      set index_debut [lindex $args 1]

      # Configuration des options
      set options [lrange $args 2 [expr [llength $args]-1]]

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
      set index_cibles [lsort [liste_index $nom_generique -rep "$rep" -ext $ext]]
      catch {set index_cibles [lsort -integer $index_cibles]}
      set index_debut [lsearch -exact $index_cibles $index_debut]
      if {$index_debut>=0} {
         set index_2 [expr $index_debut-1]
         set index_corbeille [lrange $index_cibles 0 $index_2]
         foreach index $index_corbeille {file delete [file join "$rep" $nom_generique$index$ext]}
      }
   } else {
      error $caption(divers,syntax,suppr_debut_serie)
   }
}

## @brief renumérote la série "nom_generiquenombre" en "nom_generique1", "nom_generique_2", etc
#  @details documentation de cette fonction : @ref divers
#
proc renumerote {args} {
   global audace caption conf

   if {[syntaxe_args $args 1 0 [list "" [list "-rep" "-ext"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set nom_generique [lindex $args 0]

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
      set index_serie [lsort [liste_index $nom_generique -rep "$rep" -ext $ext]]
      # Si possible on trie par ordre croissant (sauf dans le cas d'indexation 01, 02 .... par ex.)
      set error [ catch { set index_serie [ lsort -integer $index_serie ] } msg ]
      if { $error == "0" } {
         if [catch [set index_serie [lsort -integer $index_serie]]] {}
      } else {
         if [catch [set index_serie [lsort -ascii $index_serie]]] {}
      }
      set k 1
      foreach oldindex $index_serie {
         if {[string compare $k $oldindex]!=0} {
            set oldfichier [file join "$rep" $nom_generique$oldindex$ext]
            set newfichier [file join "$rep" $nom_generique$k$ext]
            file rename $oldfichier $newfichier
         }
         incr k
      }
   } else {
      error $caption(divers,syntax,renumerote)
   }
}

## @brief renomme la série "ancien_nom_generiquenombre" en "nouveau_nom_generiquenombre"
#  @details documentation de cette fonction : @ref divers
#
proc renomme {args} {
   global audace caption conf

   if {[syntaxe_args $args 1 1 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep" "-in_ext" "-ex_ext"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set ancien_nom_generique [lindex $args 0]

      # Configuration des options
      set options [lrange $args 1 [expr [llength $args]-1]]
      set range_options [range_options $options]

      # Configuration des paramètres optionnels
      set params_optionnels [lindex $range_options 0]
      if {[llength $params_optionnels] >= 1} {
         set nouveau_nom_generique [lindex $params_optionnels 0]
      } else {
         set nouveau_nom_generique [lindex $args 0]
      }

      # Configuration des options à 1 paramètre
      set options_1param [lindex [range_options $options] 2]
      set rep_index [lsearch -regexp $options_1param "-rep"]
      set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
      set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]
      set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
      set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
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
         set in_ext [lindex [lindex $options_1param $ext_index] 1]
         set ex_ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set in_ext $conf(extension,defaut)
         set ex_ext $conf(extension,defaut)
      } else {
         set in_ext $conf(extension,defaut).gz
         set ex_ext $conf(extension,defaut).gz
      }
      if {$in_ext_index>=0} {
         set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
      if {$ex_ext_index>=0} {
         set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      }

      # Procédure principale
      # On ne continue que si l'on n'écrase pas la série...
      if {[string compare $in_rep$ancien_nom_generique$in_ext $ex_rep$nouveau_nom_generique$ex_ext] != 0} {

         # On cherche si le nom de la série courante existe déjà.
         set index_newserie [liste_index $nouveau_nom_generique -rep "$ex_rep" -ext $ex_ext]
         set index_oldserie [lsort [liste_index $ancien_nom_generique -rep "$in_rep" -ext $in_ext]]
         catch {set index_oldserie [lsort -integer $index_oldserie]}
         # 1er cas : le nom de la série courante n'existe pas. On renomme sans se poser de questions
         if {[llength $index_newserie]==0} {
            # Deux cas sont possibles : 1) les deux séries ont le même type de compression, et alors pas de problème. 2) les deux séries n'ont pas le même type de compression, et alors il faut passer par un répertoire temporaire pour gérer les compressions / décompressions.

            if {[lindex [decomp $in_ext] 4] == [lindex [decomp $ex_ext] 4]} {
               foreach index $index_oldserie {
                  file rename [file join $in_rep $ancien_nom_generique$index$in_ext] [file join $ex_rep $nouveau_nom_generique$index$ex_ext]
               }
            } else {
               # Création d'un répertoire temporaire
               set rep_tmp [cree_sousrep -nom_base "tmp_renomme" -rep $ex_rep]

               renomme $ancien_nom_generique $nouveau_nom_generique -in_rep $in_rep -ex_rep $rep_tmp -ext $in_ext
               switch [lindex [decomp $in_ext] 4] {
                  "" {
                     # Rien à faire (...)
                  }
                  ".gz" {
                     foreach index [liste_index $nouveau_nom_generique -rep "$rep_tmp" -ext $in_ext] {
                        gunzip [file join $rep_tmp $nouveau_nom_generique$index$in_ext]
                     }
                  }
                  ".bz2" {
                     foreach index [liste_index $nouveau_nom_generique -rep "$rep_tmp" -ext $in_ext] {
                        exec bunzip2 [file join $rep_tmp $nouveau_nom_generique$index$in_ext]
                     }
                  }
               }

               switch [lindex [decomp $ex_ext] 4] {
                  "" {
                     # Rien à faire (...)
                  }
                  ".gz" {
                     foreach index [liste_index $nouveau_nom_generique -rep "$rep_tmp" -ext [lindex [decomp $in_ext] 3]] {
                        gzip [file join $rep_tmp $nouveau_nom_generique$index[lindex [decomp $in_ext] 3]]
                     }
                  }
                  ".bz2" {
                     foreach index [liste_index $nouveau_nom_generique -rep "$rep_tmp" -ext [lindex [decomp $in_ext] 3]] {
                        exec bzip2 [file join $rep_tmp $nouveau_nom_generique$index[lindex [decomp $in_ext] 3]]
                     }
                  }
               }

               renomme $nouveau_nom_generique -in_rep $rep_tmp -ex_rep $ex_rep -in_ext [lindex [decomp $in_ext] 3][lindex [decomp $ex_ext] 4] -ex_rep $ex_rep

               # Suppression du répertoire temporaire (qui est vide car on vient d'en déplacer les fichiers qui y étaient temporairement).
               file delete [file join $rep_tmp]

            }
         } else {
            # 2nd cas : le nom de la série courante existe déjà. Il va donc falloir réindexer
            # les deux séries et les concaténer

            # On réindexe la série cible :
            renumerote $nouveau_nom_generique -rep "$ex_rep" -ext $ex_ext

            # On détermine à quel index on continue la copie
            set index [expr [llength $index_newserie]+1]

            # Si possible on trie par ordre croissant (sauf dans le cas d'indexation 01, 02 .... par ex.)
            catch {set index_oldserie [lsort -integer $index_oldserie]}
            foreach k $index_oldserie {
               set oldfichier [file join $in_rep $ancien_nom_generique$k$in_ext]
               set newfichier [file join $ex_rep $nouveau_nom_generique$index$ex_ext]
               file rename $oldfichier $newfichier
               incr index
            }
         }

         # Si la série de destination est en lecture seule, on autorise l'utilisateur
         # en écriture
         switch $::tcl_platform(os) {
            "Linux" {
               foreach index [liste_index $nouveau_nom_generique -rep "$ex_rep" -ext $ex_ext] {
                  if {[file writable [file join $ex_rep $nouveau_nom_generique$index$ex_ext]] == 0} {
                     exec chmod u+w [file join $ex_rep $nouveau_nom_generique$index$ex_ext]
                  }
               }
            }
            default {
            }
         }
      }
   } else {
      error $caption(divers,syntax,renomme)
   }
}

## @brief copie la série "ancien_nom_generiquenombre" en "nouveau_nom_generiquenombre"
#  @details documentation de cette fonction : @ref divers
#
proc copie {args} {
   global audace caption conf

   if {[syntaxe_args $args 1 1 [list "" [list "-rep" "-in_rep" "-ex_rep" "-ext" "-in_ext" "-ex_ext"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set ancien_nom_generique [lindex $args 0]

      # Configuration des options
      set options [lrange $args 1 [expr [llength $args]-1]]
      set range_options [range_options $options]

      # Configuration des paramètres optionnels
      set params_optionnels [lindex $range_options 0]
      if {[llength $params_optionnels] >= 1} {
         set nouveau_nom_generique [lindex $params_optionnels 0]
      } else {
         set nouveau_nom_generique [lindex $args 0]
      }

      # Configuration des options à 1 paramètre
      set options_1param [lindex $range_options 2]
      set rep_index [lsearch -regexp $options_1param "-rep"]
      set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
      set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]
      set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
      set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
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
         set in_ext [lindex [lindex $options_1param $ext_index] 1]
         set ex_ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
        set in_ext $conf(extension,defaut)
        set ex_ext $conf(extension,defaut)
      } else {
         set in_ext $conf(extension,defaut).gz
         set ex_ext $conf(extension,defaut).gz
      }
      if {$in_ext_index>=0} {
         set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
      if {$ex_ext_index>=0} {
         set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      }

      # Procédure principale
      # On ne continue que si l'on n'écrase pas la série...
      if {[string compare $in_rep$ancien_nom_generique$in_ext $ex_rep$nouveau_nom_generique$ex_ext] != 0} {

         # On cherche si le nom de la série courante existe déjà.
         set index_newserie [liste_index $nouveau_nom_generique -rep "$ex_rep" -ext $ex_ext]
         set index_oldserie [lsort [liste_index $ancien_nom_generique -rep "$in_rep" -ext $in_ext]]
         catch {set index_oldserie [lsort -integer $index_oldserie]}
         # 1er cas : le nom de la série courante n'existe pas. On renomme sans se poser de questions
         if {[llength $index_newserie]==0} {
            # Deux cas sont possibles : 1) les deux séries ont le même type de compression, et alors pas de problème. 2) les deux séries n'ont pas le même type de compression, et alors il faut passer par un répertoire temporaire pour gérer les compressions / décompressions.

            if {[lindex [decomp $in_ext] 4] == [lindex [decomp $ex_ext] 4]} {
               foreach index $index_oldserie {
                  file copy [file join $in_rep $ancien_nom_generique$index$in_ext] [file join $ex_rep $nouveau_nom_generique$index$ex_ext]
               }
            } else {
               # Création d'un répertoire temporaire
               set rep_tmp [cree_sousrep -nom_base "tmp_renomme" -rep $ex_rep]

               copie $ancien_nom_generique $nouveau_nom_generique -in_rep $in_rep -ex_rep $rep_tmp -ext $in_ext
               switch [lindex [decomp $in_ext] 4] {
                  "" {
                     # Rien à faire (...)
                  }
                  ".gz" {
                     foreach index [liste_index $nouveau_nom_generique -rep "$rep_tmp" -ext $in_ext] {
                        gunzip [file join $rep_tmp $nouveau_nom_generique$index$in_ext]
                     }
                  }
                  ".bz2" {
                     foreach index [liste_index $nouveau_nom_generique -rep "$rep_tmp" -ext $in_ext] {
                        exec bunzip2 [file join $rep_tmp $nouveau_nom_generique$index$in_ext]
                     }
                  }
               }

               switch [lindex [decomp $ex_ext] 4] {
                  "" {
                     # Rien à faire (...)
                  }
                  ".gz" {
                     foreach index [liste_index $nouveau_nom_generique -rep "$rep_tmp" -ext [lindex [decomp $in_ext] 3]] {
                        gzip [file join $rep_tmp $nouveau_nom_generique$index[lindex [decomp $in_ext] 3]]
                     }
                  }
                  ".bz2" {
                     foreach index [liste_index $nouveau_nom_generique -rep "$rep_tmp" -ext [lindex [decomp $in_ext] 3]] {
                        exec bzip2 [file join $rep_tmp $nouveau_nom_generique$index[lindex [decomp $in_ext] 3]]
                     }
                  }
               }

               renomme $nouveau_nom_generique -in_rep $rep_tmp -ex_rep $ex_rep -in_ext [lindex [decomp $in_ext] 3][lindex [decomp $ex_ext] 4] -ex_ext $ex_ext

               # Suppression du répertoire temporaire (qui est vide car on vient d'en déplacer les fichiers qui y étaient temporairement).
               file delete [file join $rep_tmp]

            }
         } else {
            # 2nd cas : le nom de la série courante existe déjà. Il va donc falloir réindexer
            # les deux séries et les concaténer

            # On réindexe la série cible :
            renumerote $nouveau_nom_generique -rep "$ex_rep" -ext $ex_ext

            # On détermine à quel index on continue la copie
            set index [expr [llength $index_newserie]+1]

           # Si possible on trie par ordre croissant (sauf dans le cas d'indexation 01, 02 .... par ex.)
            catch {set index_oldserie [lsort -integer $index_oldserie]}
            foreach k $index_oldserie {
               set oldfichier [file join $in_rep $ancien_nom_generique$k$in_ext]
               set newfichier [file join $ex_rep $nouveau_nom_generique$index$ex_ext]
               file rename $oldfichier $newfichier
               incr index
            }
         }

         # Si la série de destination est en lecture seule, on autorise l'utilisateur
         # en écriture
         switch $::tcl_platform(os) {
            "Linux" {
               foreach index [liste_index $nouveau_nom_generique -rep "$ex_rep" -ext $ex_ext] {
                  if {[file writable [file join $ex_rep $nouveau_nom_generique$index$ex_ext]] == 0} {
                     exec chmod u+w [file join $ex_rep $nouveau_nom_generique$index$ex_ext]
                  }
               }
            }
            default {
            }
         }

      }
   } else {
     error $caption(divers,syntax,copie)
   }
}

## @brief copie du "debut"ième fichier au "fin"ième fichier de la série "ancien_nom_generiquenombre", en "nouveau_nom_generiquenombre"
#  @details documentation de cette fonction : @ref divers
#
proc copie_partielle {args} {
   global audace caption conf

   if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-in_rep" "-ex_rep" "-ext" "-in_ext" "-ex_ext"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set ancien_nom_generique [lindex $args 0]
      set nouveau_nom_generique [lindex $args 1]
      set debut [lindex $args 2]
      set fin [lindex $args 3]

      # Configuration des options
      set options [lrange $args 4 [expr [llength $args]-1]]
      set range_options [range_options $options]

      # Configuration des options à 1 paramètre
      set options_1param [lindex $range_options 2]
      set rep_index [lsearch -regexp $options_1param "-rep"]
      set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
      set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]
      set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
      set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]

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
         set in_ext [lindex [lindex $options_1param $ext_index] 1]
         set ex_ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set in_ext $conf(extension,defaut)
         set ex_ext $conf(extension,defaut)
      } else {
         set in_ext $conf(extension,defaut).gz
         set ex_ext $conf(extension,defaut).gz
      }
      if {$in_ext_index>=0} {
         set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
      if {$ex_ext_index>=0} {
         set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      }

      # Procédure principale
      # On ne continue que si le vieux nom générique et le nouveau sont différents
      if {$ancien_nom_generique!=$nouveau_nom_generique} {
         # On cherche si le nom de la série courante existe déjà.
         set index_newserie [liste_index $nouveau_nom_generique -rep "$ex_rep" -ext $ex_ext]
         set index_oldserie [lsort [liste_index $ancien_nom_generique -rep "$in_rep" -ext $ex_ext]]
         catch {set index_oldserie [lsort -integer $index_oldserie]}
         # On ne garde de la vieille série que les index que l'on veut copier
         set index_oldserie [lrange $index_oldserie [expr $debut-1] [expr $fin-1]]

         # Création d'un répertoire temporaire
         set rep_tmp [cree_sousrep -nom_base "tmp_renomme"]

         # On copie la sous-série vers ce répertoire temporaire
         foreach index $index_oldserie {
            file copy [file join $in_rep $ancien_nom_generique$index$in_ext] [file join $rep_tmp $ancien_nom_generique$index$in_ext]
         }

         # On copie la sous-série
         renomme $ancien_nom_generique $nouveau_nom_generique -in_rep $rep_tmp -ex_rep $ex_rep -in_ext $in_ext -ex_ext $ex_ext

         # Suppression du répertoire temporaire (qui est vide car on vient d'en déplacer les fichiers qui y étaient temporairement).
         file delete [file join $rep_tmp]

      }
   } else {
      error $caption(divers,syntax,copie_partielle)
   }
}

## @brief charge une série d'images. La fonction renvoie la liste des tampons images créés, qui contiennent les images chargées
#  @details documentation de cette fonction : @ref divers
#
proc serie_charge {args} {
   global audace caption conf

   if {[syntaxe_args $args 1 0 [list "" [list "-rep" "-ext"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set nom_generique [lindex $args 0]

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
      set index_serie [liste_index $nom_generique -rep "$rep" -ext $ext]
      set index_buffers ""
      foreach index $index_serie {
         set num_buf [buf::create]
         buf$num_buf extension $conf(extension,defaut)
         lappend index_buffers $num_buf
         charge [file join "$rep" $nom_generique$index$ext] -buf $num_buf
      }
      return $index_buffers
   } else {
      error $caption(divers,syntax,serie_charge)
  }
}

## @brief fenêtrage d'une série de fichiers. La série résultante est "ex". "coord" est une liste des coordonnées de 2 coins extrêmes de la zone de fenêtrage.
#  @details documentation de cette fonction : @ref divers
#
proc serie_fenetre {args} {
   global audace caption conf

   if {[syntaxe_args $args 3 0 [list "" [list "-rep" "-ext" "-in_ext" "-ex_ext" "-in_rep" "-ex_rep" "-polyNo" "-in_polyNo" "-ex_polyNo"]]]=="1"} {

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
      set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
      set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
      set polyNo_index [lsearch -regexp $options_1param "-polyNo"]
      set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]
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
         set in_ext [lindex [lindex $options_1param $ext_index] 1]
         set ex_ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set in_ext $conf(extension,defaut)
         set ex_ext $conf(extension,defaut)
      } else {
         set in_ext $conf(extension,defaut).gz
         set ex_ext $conf(extension,defaut).gz
      }
      if {$in_ext_index>=0} {
         set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
      if {$ex_ext_index>=0} {
         set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      }
      if {$polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
         set ex_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      } else {
         set in_polyNo 1
         set ex_polyNo 1
      }
      if {$in_polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
      }
      if {$ex_polyNo_index>=0} {
         set ex_polyNo [lindex [lindex $options_1param $ex_polyNo_index] 1]
      }

      # Procédure principale
      # On récupère la liste des index de la série initiale...
      set liste_index [liste_index $in -rep "$in_rep" -ext $in_ext]

      # Création du buffer temporaire
      set num_buf_tmp [buf::create]
      buf$num_buf_tmp extension $conf(extension,defaut)

      # Fenêtrage des fichiers
      foreach index $liste_index {
         charge $in$index -buf $num_buf_tmp -rep "$in_rep" -ext $in_ext -polyNo $in_polyNo
         buf$num_buf_tmp window $coord
         sauve $ex$index -polyNo $ex_polyNo -buf $num_buf_tmp -rep "$ex_rep" -ext $ex_ext
      }

      # Suppression du buffer temporaire
      buf::delete $num_buf_tmp
   } else {
      error $caption(divers,syntax,serie_fenetre)
   }
}

## @brief idem serie_fenetre sauf que les coordonnées de la fenêtre sont à faire préalablement à la souris sur l'image Aud'ACE
#  @details documentation de cette fonction : @ref divers
#
proc souris_fenetre {args} {
   global audace caption conf

   if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep" "-polyNo" "-in_polyNo" "-ex_polyNo"]]]=="1"} {

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
      set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
      set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
      set polyNo_index [lsearch -regexp $options_1param "-polyNo"]
      set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]
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
         set in_ext [lindex [lindex $options_1param $ext_index] 1]
         set ex_ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set in_ext $conf(extension,defaut)
         set ex_ext $conf(extension,defaut)
      } else {
         set in_ext $conf(extension,defaut).gz
         set ex_ext $conf(extension,defaut).gz
      }
      if {$in_ext_index>=0} {
         set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
      if {$ex_ext_index>=0} {
         set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      }
      if {$polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
         set ex_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      } else {
         set in_polyNo 1
         set ex_polyNo 1
      }
      if {$in_polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
      }
      if {$ex_polyNo_index>=0} {
         set ex_polyNo [lindex [lindex $options_1param $ex_polyNo_index] 1]
      }

      # Procédure principale
      set rect [ ::confVisu::getBox 1 ]
      serie_fenetre $in $ex $rect -in_rep $in_rep -ex_rep $ex_rep -in_ext $in_ext -ex_ext $ex_ext -in_polyNo $in_polyNo -ex_polyNo $ex_polyNo
   } else {
      error $caption(divers,syntax,souris_fenetre)
   }
}

## @brief transforme une série d'images par rotation d'angle "angle" et de centre ("x0", "y0")
#  @details documentation de cette fonction : @ref divers
#
proc serie_rot {args} {
   global audace caption conf

   if {[syntaxe_args $args 5 0 [list "" [list "-rep" "-in_rep" "-ex_rep" "-ext" "-in_ext" "-ex_ext" "-polyNo" "-in_polyNo" "-ex_polyNo"]]]=="1"} {

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
      set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
      set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
      set polyNo_index [lsearch -regexp $options_1param "-polyNo"]
      set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]
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
         set in_ext [lindex [lindex $options_1param $ext_index] 1]
         set ex_ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set in_ext $conf(extension,defaut)
         set ex_ext $conf(extension,defaut)
      } else {
         set in_ext $conf(extension,defaut).gz
         set ex_ext $conf(extension,defaut).gz
      }
      if {$in_ext_index>=0} {
         set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
      if {$ex_ext_index>=0} {
         set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      }
      if {$polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
         set ex_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      } else {
         set in_polyNo 1
         set ex_polyNo 1
      }
      if {$in_polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
      }
      if {$ex_polyNo_index>=0} {
         set ex_polyNo [lindex [lindex $options_1param $ex_polyNo_index] 1]
      }

      # Procédure principale
      # On récupère la liste des index de la série initiale...
      set liste_index [liste_index $in -rep "$in_rep" -ext $in_ext]

      # Création du buffer temporaire
      set num_buf_tmp [buf::create]
      buf$num_buf_tmp extension $conf(extension,defaut)

      # Rotation des fichiers
      foreach index $liste_index {
         charge $in$index -buf $num_buf_tmp -rep "$in_rep" -ext $in_ext -polyNo $in_polyNo
         buf$num_buf_tmp rot $x0 $y0 $angle
         sauve $ex$index -polyNo $ex_polyNo -buf $num_buf_tmp -rep "$ex_rep" -ext $ex_ext
      }

      # Suppression du buffer temporaire
      buf::delete $num_buf_tmp
   } else {
      error $caption(divers,syntax,serie_rot)
   }
}

## @brief transforme une série d'images par translation
#  @details documentation de cette fonction : @ref divers
#
proc serie_trans {args} {
   global audace caption conf

   if {[syntaxe_args $args 4 0 [list "" [list "-rep" "-in_rep" "-ex_rep" "-ext" "-in_ext" "-ex_ext" "-polyNo" "-in_polyNo" "-ex_polyNo"]]]=="1"} {

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
      set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
      set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
      set polyNo_index [lsearch -regexp $options_1param "-polyNo"]
      set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]
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
         set in_ext [lindex [lindex $options_1param $ext_index] 1]
         set ex_ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set in_ext $conf(extension,defaut)
         set ex_ext $conf(extension,defaut)
      } else {
         set in_ext $conf(extension,defaut).gz
         set ex_ext $conf(extension,defaut).gz
      }
      if {$in_ext_index>=0} {
         set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
      if {$ex_ext_index>=0} {
         set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      }
      if {$polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
         set ex_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      } else {
         set in_polyNo 1
         set ex_polyNo 1
      }
      if {$in_polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
      }
      if {$ex_polyNo_index>=0} {
         set ex_polyNo [lindex [lindex $options_1param $ex_polyNo_index] 1]
      }

      # Procédure principale
      # On récupère la liste des index de la série initiale...
      set liste_index [liste_index $in -rep "$in_rep" -ext $in_ext]

      # Création du buffer temporaire
      set num_buf_tmp [buf::create]
      buf$num_buf_tmp extension $conf(extension,defaut)

      # Rotation des fichiers
      foreach index $liste_index {
         charge $in$index -buf $num_buf_tmp -rep "$in_rep" -ext $ext -polyNo $in_polyNo
         buf$num_buf_tmp imaseries "TRANS trans_x=$dx trans_y=$dy"
         sauve $ex$index -polyNo $ex_polyNo -buf $num_buf_tmp -rep "$ex_rep" -ext $ext
      }

      # Suppression du buffer temporaire
      buf::delete $num_buf_tmp
   } else {
      error $caption(divers,syntax,serie_trans)
   }
}

## @brief registration manuelle entre plusieurs séries d'images par translation et rotation
#  @details documentation de cette fonction : @ref divers
#
proc series_traligne {args} {
   global audace caption conf script

   if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep" "-in_polyNo"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set liste_in [lindex $args 0]
      set ex [lindex $args 1]

      # Configuration des options
      set options [lrange $args 2 [expr [llength $args]-1]]

      # Configuration des options à 1 paramètre
      set options_1param [lindex [range_options $options] 2]

      set rep_index [lsearch -regexp $options_1param "-rep"]
      set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
      set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]
      set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]

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
      if {$in_polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
      } else {
         set in_polyNo 1
      }

      # Procédure principale
      # On supprime d'éventuels fichiers déjà présents de la série-cible
      suppr_serie $ex -rep "$ex_rep" -ext $ext

      # La série de référence est recopiée sans modifications
      set serie_ref [lindex $liste_in 0]
      poly2serie $serie_ref $in_polyNo $ex -in_rep $in_rep -ex_rep $ex_rep -ext $ext
      # Tex au plus on la renumérote.
      renumerote $ex -rep "$ex_rep" -ext $ext

      # On garde en mémoire le nom du dernier fichier de cette série, qui servira de
      # référence pour recaler la série suivante
      set liste_index_ref [lsort [liste_index $ex -rep "$ex_rep" -ext $ext]]
      catch {set liste_index_ref [lsort -integer $liste_index_ref]}
      set index_ref [lindex $liste_index_ref [expr [llength $liste_index_ref]-1]]
      set fichier_ref [file join $ex_rep $ex$index_ref$ext]

      # A présent, on fait les transformations sur les autres séries :
      set series_amodif [lrange $liste_in 1 [expr [llength $liste_in]-1]]

      # Les fichiers temporaires sont stockés dans un répertoire temporaire
      set rep_tmp [cree_sousrep -rep "$ex_rep" -nom_base "tmp_poly_series_traligne"]

      foreach serie $series_amodif {

         # On détermine le cadre de référence ;
         console::affiche_resultat "$caption(divers,series_trreg_cadre-ref) $serie\n"
         loadima "$fichier_ref"

         # Création de la fenêtre
         set script(series_traligne,attente) 0
         toplevel .series_traligne
         label .series_traligne.lab -text $caption(divers,tracebox)
         pack .series_traligne.lab -expand true
         button .series_traligne.but -command {set script(series_traligne,attente) 0} -text "ok"
         pack .series_traligne.but -expand true

         # On attend que l'utilisateur ait validé
         vwait script(series_traligne,attente)

         # On supprime la fenêtre
         destroy .series_traligne

         # On enregistre les coordonnées du cadre
         set cadre_ref [ ::confVisu::getBox 1 ]

         console::affiche_resultat "$caption(divers,series_trreg_cadre-a-rec) $serie\n"
         # Chargement du premier fichier de la série courante
         set liste_index [liste_index $serie -rep $in_rep -ext $ext]
         catch {set liste_index [lsort -integer $liste_index]}
         loadima [file join $in_rep "$serie[lindex $liste_index 0]$ext;$in_polyNo"]

         # Création de la fenêtre
         set script(series_traligne,attente) 0
         toplevel .series_traligne
         label .series_traligne.lab -text $caption(divers,tracebox)
         pack .series_traligne.lab -expand true
         button .series_traligne.but -command {set script(series_traligne,attente) 0} -text "ok"
         pack .series_traligne.but -expand true
         # On attend que l'utilisateur ait validé
         vwait script(series_traligne,attente)
         # On supprime la fenêtre
         destroy .series_traligne
         # On enregistre les coordonnées du cadre
         set cadre_amodif [ ::confVisu::getBox 1 ]
         # Calcul des modifications de translation / rotation
         set modifs [calcul_trzaligne $cadre_ref $cadre_amodif]

         # Translation (en entiers pour éviter de dégrader la résolution)
         console::affiche_resultat "$caption(divers,series_trreg_transl) $serie\n"
         serie_trans $serie tmp_trans_$serie [expr round([lindex $modifs 0])] [expr round([lindex $modifs 1])] -in_rep $in_rep -ex_rep $rep_tmp -ext $ext -in_polyNo $in_polyNo
         # Rotation
         console::affiche_resultat "$caption(divers,series_trreg_rot) $serie\n"
         serie_rot tmp_trans_$serie tmp_rot_$serie [lindex $modifs 2] [lindex $modifs 3] [lindex $modifs 4] -rep "$rep_tmp" -ext $ext
         # Suppression de la série temporaire de translation (si on n'avait pas cette série temporaire,
         # l'auto-écrasement bugge)
         suppr_serie tmp_trans_$serie -rep "$rep_tmp" -ext $ext
         # On renomme vers la série de destination
         renomme tmp_rot_$serie $ex -in_rep $rep_tmp -ex_rep $ex_rep -ext $ext

         # On garde en mémoire le nom du dernier fichier de cette série, qui servira de
         # référence pour recaler la série suivante
         set liste_index_ref [lsort [liste_index $ex -rep "$ex_rep" -ext $ext]]
         catch {set liste_index_ref [lsort -integer $liste_index_ref]}
         set index_ref [lindex $liste_index_ref [expr [llength $liste_index_ref]-1]]
         set fichier_ref [file join $ex_rep $ex$index_ref$ext]
      }

      # Suppression du répertoire temporaire
      file delete $rep_tmp
   } else {
      error $caption(divers,syntax,series_traligne)
   }
}

## @brief convertit une série d'images au format jpeg
#  @details documentation de cette fonction : @ref divers
#
proc serie_sauvejpeg {args} {
   global audace caption conf

   if {[syntaxe_args $args 1 0 [list "" [list "-ex_name" "-qualitejpeg" "-seuils_type" "-rep" "-in_rep" "-ex_rep" "-in_ext" "-ex_ext" "-in_polyNo"] [list "-seuils_haut_bas" "-histo_haut_bas"]]] =="1"} {

      # Configuration des paramètres obligatoires
      set in [lindex $args 0]

      # Configuration des options
      set options [lrange $args 1 [expr [llength $args]-1]]
      set range_options [range_options $options]

      # Configuration des options à 1 paramètre
      set options_1param [lindex $range_options 2]

      set ex_name_index [lsearch -regexp $options_1param "-ex_name"]
      set qualitejpeg_index [lsearch -regexp $options_1param "-qualitejpeg"]
      set seuils_type_index [lsearch -regexp $options_1param "-seuils_type"]
      set rep_index [lsearch -regexp $options_1param "-rep"]
      set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
      set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
      set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
      set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
      set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]

      if {$ex_name_index>=0} {
         set ex_name [lindex [lindex $options_1param $ex_name_index] 1]
      } else {
         set ex_name $in
      }
      if {$qualitejpeg_index>=0} {
         set qualitejpeg [lindex [lindex $options_1param $qualitejpeg_index] 1]
      } else {
         set qualitejpeg $conf(jpegquality,defaut)
      }
      if {$seuils_type_index>=0} {
         set seuils_type [lindex [lindex $options_1param $seuils_type_index] 1]
      } else {
         set seuils_type "loadima"
      }
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
      if {$in_ext_index>=0} {
         set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set in_ext $conf(extension,defaut)
      } else {
         set in_ext $conf(extension,defaut).gz
      }
      if {$ex_ext_index>=0} {
         set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      } else {
         set ex_ext ".jpg"
      }
      if {$in_polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
      } else {
         set in_polyNo 1
      }

      # Configuration des options à 2 paramètres
      set options_2param [lindex $range_options 3]

      set seuils_haut_bas_index [lsearch -regexp $options_2param "-seuils_haut_bas"]
      set histo_haut_bas_index [lsearch -regexp $options_2param "-histo_haut_bas"]

      if {$seuils_haut_bas_index>=0} {
         set seuils_type "fixe"
         set seuil_haut [lindex [lindex $options_2param $seuils_haut_bas_index] 1]
         set seuil_bas [lindex [lindex $options_2param $seuils_haut_bas_index] 2]
      }
      if {$histo_haut_bas_index>=0} {
         set seuils_type "histoauto"
         set histo_haut [lindex [lindex $options_2param $histo_haut_bas_index] 1]
         set histo_bas [lindex [lindex $options_2param $histo_haut_bas_index] 2]
      }

      # Procédure principale
      # On récupère la liste des index de la série initiale...
      set liste_index [liste_index $in -rep "$in_rep" -ext $in_ext]

      # Création du buffer temporaire
      set num_buf_tmp [buf::create]
      buf$num_buf_tmp extension $conf(extension,defaut)

      # Sauvegarde des fichiers
      foreach index $liste_index {
         buf$num_buf_tmp load [file join $in_rep "$in$index$in_ext;$in_polyNo"]
         # Si on n'est pas en seuillage fixe, il faut calculer les seuils adaptés.
         if {$seuils_type!="fixe"} {
            switch -exact -- $seuils_type {
               loadima {
                  set list_seuils [lrange [buf$num_buf_tmp stat] 0 1]
               }
               autovisu {
                  set list_seuils [lrange [buf$num_buf_tmp autocuts] 0 1]
               }
               iris {
                  set moyenne [lindex [buf$num_buf_tmp stat] 4]
                  set list_seuils [list [expr $moyenne+1000] [expr $moyenne-200]]
               }
               histoauto {
                  buf$num_buf_tmp imaseries "CUTS lofrac=[expr 0.01 * $histo_bas] hifrac=[expr 0.01 * $histo_haut]"
                  set list_seuils [list [lindex [buf$num_buf_tmp getkwd MIPS-HI] 1] [lindex [buf$num_buf_tmp getkwd MIPS-LO] 1]]
               }
            }
            set seuil_haut [lindex $list_seuils 0]
            set seuil_bas [lindex $list_seuils 1]
         }

         buf$num_buf_tmp savejpeg [file join $ex_rep $ex_name$index$ex_ext] $qualitejpeg $seuil_bas $seuil_haut
      }

      # Suppression du buffer temporaire
      buf::delete $num_buf_tmp
   } else {
      error $caption(divers,syntax,serie_sauvejpeg)
   }
}

## @brief renvoie l'image médiane de la série d'images d'entrée
#  @details documentation de cette fonction : @ref divers
#
proc mediane {args} {
   global audace caption conf

   if {[syntaxe_args $args 1 0 [list "" [list "-buf" "-rep" "-ext" "-polyNo"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set serie [lindex $args 0]

      # Configuration des options
      set options [lrange $args 1 [expr [llength $args]-1]]
      set range_options [range_options $options]

      # Configuration des options à 1 paramètre
      set options_1param [lindex $range_options 2]

      set buf_index [lsearch -regexp $options_1param "-buf"]
      set rep_index [lsearch -regexp $options_1param "-rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]
      set polyNo_index [lsearch -regexp $options_1param "-polyNo"]

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
         set aux_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      } else {
         set aux_polyNo 1
      }

      # Procédure principale

      # On vérifie que la série de départ existe bien
      if {[serie_existe $serie -rep "$rep" -ext $ext] == 0} {
         return
      }

      # Création d'un répertoire temporaire
      set rep_tmp [cree_sousrep -nom_base "tmp_mediane" -rep $rep]

      # Création sur le disque de l'image médiane
      if {[isRaw $ext] == 1} {
         # Cas particulier d'une série de fichiers RAW
         raw2fits $serie "tmpfits_" -in_rep $rep -ex_rep $rep_tmp -in_ext $ext
         mediane "tmpfits_" -buf $buf -rep $rep_tmp
         suppr_serie "tmpfits_" -rep $rep_tmp

      } else {
         # Série de fichiers non-Raw
         set nb_images [llength [liste_index $serie -rep "$rep" -ext $ext]]
         # Série "bien" numérotée
         if {[numerotation_usuelle $serie -rep "$rep" -ext $ext] == 1} {
            # Cas d'une série compressée .bz2
            if {[file extension $ext] == ".bz2"} {
               copie $serie $serie -in_rep "$rep" -ex_rep $rep_tmp -ext $ext
               foreach fichier [glob [file join $rep_tmp ${serie}*$ext]] {
                  exec chmod u+w $fichier
                  exec bunzip2 $fichier
               }
               ttscript2 "IMA/STACK \"$rep_tmp\" $serie 1 $nb_images [file rootname $ext] \"$rep_tmp\" mediane . $conf(extension,defaut) MED"
               suppr_serie $serie -rep "$rep_tmp" -ext [file rootname $ext]
            } else {
               ttscript2 "IMA/STACK \"$rep\" $serie 1 $nb_images $ext \"$rep_tmp\" mediane . $conf(extension,defaut) MED"
            }
         # Série "mal" numérotée
         } else {
            copie $serie $serie -in_rep "$rep" -ex_rep $rep_tmp -ext $ext
            # Cas d'une série compressée .bz2
            if {[file extension $ext] == ".bz2"} {
               foreach fichier [glob [file join $rep_tmp ${serie}*$ext]] {
                  exec chmod a+w $fichier
               }
               renumerote $serie -rep "$rep_tmp" -ext $ext
               foreach fichier [glob [file join $rep_tmp ${serie}*$ext]] {
                  exec bunzip2 $fichier
               }
               # exec bunzip2 [file join $rep_tmp ${serie}*$ext]
               ttscript2 "IMA/STACK \"$rep_tmp\" $serie 1 $nb_images [file rootname $ext] \"$rep_tmp\" mediane . $conf(extension,defaut) MED"
               suppr_serie $serie -rep "$rep_tmp" -ext [file rootname $ext]
            } else {
               renumerote $serie -rep "$rep_tmp" -ext $ext
               ttscript2 "IMA/STACK \"$rep_tmp\" $serie 1 $nb_images $ext \"$rep_tmp\" mediane . $conf(extension,defaut) MED"
               suppr_serie $serie -rep "$rep_tmp" -ext $ext
            }
         }

         # Chargement de l'image dans le buffer désiré
         charge mediane -rep "$rep_tmp" -ext $conf(extension,defaut) -buf $buf

         # Suppression de fichier temporaire
         file delete [file join $rep_tmp mediane$conf(extension,defaut)]
      }

      # Suppression du répertoire temporaire
      file delete [file join $rep_tmp]

   } else {
      error $caption(divers,syntax,mediane)
   }
}

## @brief soustrait l'image contenue dans le tampon mémoire spécifié (par défaut, l'image affichée dans Aud'ACE) à une série d'images
#  @details documentation de cette fonction : @ref divers
#
proc serie_soustrait {args} {
   global audace caption conf

   if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep" "-in_ext" "-ex_ext" "-polyNo" "-in_polyNo" "-ex_polyNo" "-buf"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set in_serie [lindex $args 0]
      set ex_serie [lindex $args 1]

      # Configuration des options
      set options [lrange $args 2 [expr [llength $args]-1]]
      set range_options [range_options $options]

      # Configuration des options à 1 paramètre
      set options_1param [lindex $range_options 2]

      set rep_index [lsearch -regexp $options_1param "-rep"]
      set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
      set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]
      set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
      set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
      set polyNo_index [lsearch -regexp $options_1param "-polyNo"]
      set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]
      set ex_polyNo_index [lsearch -regexp $options_1param "-ex_polyNo"]
      set buf_index [lsearch -regexp $options_1param "-buf"]

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
         set in_ext [lindex [lindex $options_1param $ext_index] 1]
         set ex_ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set in_ext $conf(extension,defaut)
         set ex_ext $conf(extension,defaut)
      } else {
         set in_ext $conf(extension,defaut).gz
         set ex_ext $conf(extension,defaut).gz
      }
      if {$in_ext_index>=0} {
         set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
      if {$ex_ext_index>=0} {
         set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      }
      if {$polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
         set ex_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      } else {
         set in_polyNo 1
         set ex_polyNo 1
      }
      if {$in_polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
      }
      if {$ex_polyNo_index>=0} {
         set ex_polyNo [lindex [lindex $options_1param $ex_polyNo_index] 1]
      }
      if {$buf_index>=0} {
         set buf [lindex [lindex $options_1param $buf_index] 1]
      } else {
         set buf $audace(bufNo)
      }

      # Procédure principale

      # On vérifie que la série de départ existe bien
      if {[serie_existe $in_serie -rep "$in_rep" -ext $in_ext] == 0} {
         return
      }

      # Création d'un répertoire temporaire
      set rep_tmp [cree_sousrep -nom_base "tmp_serie_soustrait"]

      # On enregistre sur le disque l'image à soustraire
      sauve soustrait -buf $buf -rep "$rep_tmp" -ext [lindex [decomp $ex_ext] 3]

      # On récupère la liste des index de la série initiale...
      set liste_index [liste_index $in_serie -rep "$in_rep" -ext $in_ext]

      # Création du buffer temporaire
      set num_buf_tmp [buf::create]
      buf$num_buf_tmp extension $conf(extension,defaut)

      # Soustraction
      foreach index $liste_index {
         charge $in_serie$index -rep "$in_rep" -ext $in_ext -polyNo $in_polyNo -buf $num_buf_tmp
         soustrait soustrait -buf $num_buf_tmp -rep "$rep_tmp" -ext [lindex [decomp $ex_ext] 3]
         sauve $ex_serie$index -rep "$ex_rep" -ext $ex_ext -polyNo $ex_polyNo -buf $num_buf_tmp
      }

      # Suppression du buffer temporaire
      buf::delete $num_buf_tmp

      # Suppression de fichier / répertoire temporaire
      file delete [file join $rep_tmp soustrait$ex_ext]
      file delete [file join $rep_tmp]

   } else {
     error $caption(divers,syntax,serie_soustrait)

   }
}

## @brief normalise une série d'images par l'image contenue dans le tampon mémoire spécifié (par défaut, l'image affichée dans Aud'ACE)
#  @details documentation de cette fonction : @ref divers
#
proc serie_normalise {args} {
   global audace caption conf

   if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep" "-in_ext" "-ex_ext" "-polyNo" "-in_polyNo" "-ex_polyNo" "-buf"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set in_serie [lindex $args 0]
      set ex_serie [lindex $args 1]

      # Configuration des options
      set options [lrange $args 2 [expr [llength $args]-1]]
      set range_options [range_options $options]

      # Configuration des options à 1 paramètre
      set options_1param [lindex $range_options 2]

      set rep_index [lsearch -regexp $options_1param "-rep"]
      set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
      set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]
      set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
      set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
      set polyNo_index [lsearch -regexp $options_1param "-polyNo"]
      set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]
      set ex_polyNo_index [lsearch -regexp $options_1param "-ex_polyNo"]
      set buf_index [lsearch -regexp $options_1param "-buf"]

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
         set in_ext [lindex [lindex $options_1param $ext_index] 1]
         set ex_ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set in_ext $conf(extension,defaut)
         set ex_ext $conf(extension,defaut)
      } else {
         set in_ext $conf(extension,defaut).gz
         set ex_ext $conf(extension,defaut).gz
      }
      if {$in_ext_index>=0} {
         set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
      if {$ex_ext_index>=0} {
         set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      }
      if {$polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
         set ex_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      } else {
         set in_polyNo 1
         set ex_polyNo 1
      }
      if {$in_polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
      }
      if {$ex_polyNo_index>=0} {
         set ex_polyNo [lindex [lindex $options_1param $ex_polyNo_index] 1]
      }
      if {$buf_index>=0} {
         set buf [lindex [lindex $options_1param $buf_index] 1]
      } else {
         set buf $audace(bufNo)
      }

      # Procédure principale

      # On vérifie que la série de départ existe bien
      if {[serie_existe $in_serie -rep "$in_rep" -ext $in_ext] == 0} {
         return
      }

      # Création d'un répertoire temporaire
      set rep_tmp [cree_sousrep -nom_base "tmp_serie_soustrait"]

      # On enregistre sur le disque l'image à soustrairepar laquelle normaliser
      sauve normalise -buf $buf -rep "$rep_tmp" -ext [lindex [decomp $ex_ext] 3]

      # On récupère la liste des index de la série initiale...
      set liste_index [liste_index $in_serie -rep "$in_rep" -ext $in_ext]

      # Création du buffer temporaire
      set num_buf_tmp [buf::create]
      buf$num_buf_tmp extension $conf(extension,defaut)

      # Soustraction
      foreach index $liste_index {
         charge $in_serie$index -rep "$in_rep" -ext $in_ext -polyNo $in_polyNo -buf $num_buf_tmp
         normalise normalise -buf $num_buf_tmp -rep "$rep_tmp" -ext $ex_ext
         sauve  $ex_serie$index -rep "$ex_rep" -ext $ex_ext -polyNo $ex_polyNo -buf $num_buf_tmp
      }

      # Suppression du buffer temporaire
      buf::delete $num_buf_tmp

      # Suppression de fichier / répertoire temporaire
      file delete [file join $rep_tmp normalise$ex_ext]
      file delete [file join $rep_tmp]

   } else {
      error $caption(divers,syntax,serie_normalise)

   }
}

## @brief normalise le gain d'une série d'images
#  @details documentation de cette fonction : @ref divers
#
proc normalise_gain {args} {
   global audace caption conf

   if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep" "-in_ext" "-ex_ext" "-polyNo" "-in_polyNo" "-ex_polyNo"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set in_serie [lindex $args 0]
      set ex_serie [lindex $args 1]

      # Configuration des options
      set options [lrange $args 2 [expr [llength $args]-1]]
      set range_options [range_options $options]

      # Configuration des options à 1 paramètre
      set options_1param [lindex $range_options 2]

      set rep_index [lsearch -regexp $options_1param "-rep"]
      set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
      set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]
      set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
      set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
      set polyNo_index [lsearch -regexp $options_1param "-polyNo"]
      set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]
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
         set in_ext [lindex [lindex $options_1param $ext_index] 1]
         set ex_ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set in_ext $conf(extension,defaut)
         set ex_ext $conf(extension,defaut)
      } else {
         set in_ext $conf(extension,defaut).gz
         set ex_ext $conf(extension,defaut).gz
      }
      if {$in_ext_index>=0} {
         set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
      if {$ex_ext_index>=0} {
         set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      }
      if {$polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
         set ex_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      } else {
         set in_polyNo 1
         set ex_polyNo 1
      }
      if {$in_polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
      }
      if {$ex_polyNo_index>=0} {
         set ex_polyNo [lindex [lindex $options_1param $ex_polyNo_index] 1]
      }

      # Procédure principale

      # On vérifie que la série de départ existe bien
      if {[serie_existe $in_serie -rep "$in_rep" -ext $in_ext] == 0} {
         return
      }

      # On récupère la liste des index de la série initiale...
      set liste_index [liste_index $in_serie -rep "$in_rep" -ext $in_ext]

      # Création du buffer temporaire
      set num_buf_tmp [buf::create]
      buf$num_buf_tmp extension $conf(extension,defaut)

      # On enregistre le niveau de fond de ciel de la première image
      set premier_index [lindex $liste_index 0]
      charge $in_serie$premier_index -rep "$in_rep" -ext $in_ext -polyNo $in_polyNo -buf $num_buf_tmp
      set stats [buf$num_buf_tmp stat]
      set gain_ref [lindex $stats 6]
      sauve $ex_serie$premier_index -rep "$ex_rep" -ext $ex_ext -polyNo $ex_polyNo -buf $num_buf_tmp

      # Normalisation du gain de chaque image en se calant sur la première
      foreach index [lrange $liste_index 1 [expr [llength $liste_index]-1]] {
         charge $in_serie$index -rep "$in_rep" -ext $in_ext -polyNo $in_polyNo -buf $num_buf_tmp
         set stats [buf$num_buf_tmp stat]
         set gain_encours [lindex $stats 6]
         buf$num_buf_tmp mult [expr 1.0*$gain_ref/$gain_encours]
         sauve $ex_serie$index -rep "$ex_rep" -ext $ex_ext -polyNo $ex_polyNo -buf $num_buf_tmp
      }

      # Suppression du buffer temporaire
      buf::delete $num_buf_tmp

   } else {
      error $caption(divers,syntax,normalise_gain)

   }
}

## @brief aligne des images par translation
#  @details documentation de cette fonction : @ref divers
#
proc aligne {args} {
   global audace caption conf

   if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext" "-in_ext" "-ex_ext" "-in_rep" "-ex_rep" "-polyNo" "-in_polyNo" "-ex_polyNo"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set in_serie [lindex $args 0]
      set ex_serie [lindex $args 1]

      # Configuration des options
      set options [lrange $args 2 [expr [llength $args]-1]]
      set range_options [range_options $options]

      # Configuration des options à 1 paramètre
      set options_1param [lindex $range_options 2]

      set rep_index [lsearch -regexp $options_1param "-rep"]
      set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
      set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]
      set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
      set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
      set polyNo_index [lsearch -regexp $options_1param "-polyNo"]
      set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]
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
         set in_ext [lindex [lindex $options_1param $ext_index] 1]
         set ex_ext [lindex [lindex $options_1param $ext_index] 1]
      } elseif {$conf(fichier,compres)==0} {
         set in_ext $conf(extension,defaut)
         set ex_ext $conf(extension,defaut)
      } else {
         set in_ext $conf(extension,defaut).gz
         set ex_ext $conf(extension,defaut).gz
      }
      if {$in_ext_index>=0} {
         set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
      if {$ex_ext_index>=0} {
         set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      }
      if {$polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
         set ex_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      } else {
         set in_polyNo 1
         set ex_polyNo 1
      }
      if {$in_polyNo_index>=0} {
         set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
      }
      if {$ex_polyNo_index>=0} {
         set ex_polyNo [lindex [lindex $options_1param $ex_polyNo_index] 1]
      }

      # Procédure principale

      # On vérifie que la série de départ existe bien
      if {[serie_existe $in_serie -rep "$in_rep" -ext $in_ext] == 0} {
         return
      }

      # On récupère la liste des index de la série initiale...
      set liste_index [liste_index $in_serie -rep "$in_rep" -ext $in_ext]

      # Création d'un répertoire temporaire
      set rep_tmp [cree_sousrep -nom_base "tmp_aligne" -rep "$in_rep"]

      # En cas de compression .bz2 : on décompresse dans le répertoire temporaire
      if {[lindex [decomp $in_ext] 4] ==".bz2" } {
         copie $in_serie tmp_ima_ -in_rep $in_rep -ex_rep $rep_tmp -in_ext $in_ext -ex_ext [lindex [decomp $in_ext] 3]
         # On sauve dans le répertoire temporaire les images associées chacune à un catalogue d'objet qu'elles contiennent
         foreach index $liste_index {
           # ttscript2 "IMA/SERIES \"$rep_tmp\" tmp_ima_ $index $index [lindex [decomp $in_ext] 3] \"$rep_tmp\" tmp_ima_ $index [lindex [decomp $in_ext] 3] STAT objefile"
            ttscript2 "IMA/SERIES \"$rep_tmp\" tmp_ima_$index . . [lindex [decomp $in_ext] 3] \"$rep_tmp\" tmp_ima_$index . [lindex [decomp $in_ext] 3] STAT objefile"
         }
      } else {
         # On sauve dans le répertoire temporaire les images associées chacune à un catalogue d'objet qu'elles contiennent
         foreach index $liste_index {
           # ttscript2 "IMA/SERIES \"$in_rep\" $in_serie $index $index $in_ext \"$rep_tmp\" tmp_ima_ $index [lindex [decomp $in_ext] 3] STAT objefile"
            ttscript2 "IMA/SERIES \"$in_rep\" $in_serie$index . . $in_ext \"$rep_tmp\" tmp_ima_$index . [lindex [decomp $in_ext] 3] STAT objefile"
         }
      }

      # Création du buffer temporaire
      set num_buf_tmp [buf::create]
      buf$num_buf_tmp extension $conf(extension,defaut)

      if {[numerotation_usuelle $in_serie -rep "$in_rep" -ext $in_ext] == "1"} {
         # Registration
         ttscript2 "IMA/SERIES \"$rep_tmp\" tmp_ima_ 1 [llength $liste_index] [lindex [decomp $in_ext] 3] \"$rep_tmp\" tmp_ima2_ 1 [lindex [decomp $ex_ext] 3] REGISTER translate=only"

         # Fenêtrage des images
         set depl_x ""
         set depl_y ""
         foreach index $liste_index {
            charge tmp_ima2_$index -ext [lindex [decomp $ex_ext] 3] -rep "$rep_tmp" -buf $num_buf_tmp
            set TT_num 1
            while {[lindex [buf$num_buf_tmp getkwd TT${TT_num}] 1] != "IMA/SERIES REGISTER"} {
               incr TT_num
            }
            lappend depl_x [lindex [lindex [buf$num_buf_tmp getkwd TT[expr ${TT_num}+1]] 1] 2]
            lappend depl_y [lindex [lindex [buf$num_buf_tmp getkwd TT[expr ${TT_num}+2]] 1] 2]
         }
         set naxis1 [lindex [buf$num_buf_tmp getkwd NAXIS1] 1]
         set naxis2 [lindex [buf$num_buf_tmp getkwd NAXIS2] 1]
         serie_fenetre tmp_ima2_ tmp_ima2_ [list [expr -round([lmin $depl_x])] [expr -round([lmin $depl_y])] [expr $naxis1 - round([lmax $depl_x])] [expr $naxis2 - round([lmax $depl_y])]] -ext [lindex [decomp $ex_ext] 3] -rep "$rep_tmp"

         # Déplacement des fichiers
         renomme tmp_ima2_ $ex_serie -in_rep $rep_tmp -ex_rep $ex_rep -in_ext [lindex [decomp $in_ext] 3] -ex_ext $ex_ext

      } else {

         renumerote tmp_ima_ -rep "$rep_tmp" -ext [lindex [decomp $in_ext] 3]

         # Registration
         ttscript2 "IMA/SERIES \"$rep_tmp\" tmp_ima_ 1 [llength $liste_index] [lindex [decomp $in_ext] 3] \"$rep_tmp\" tmp_ima2_ 1 [lindex [decomp $in_ext] 3] REGISTER translate=only"

         # Fenêtrage des images
         set depl_x ""
         set depl_y ""
         for {set index 1} {$index <= [llength $liste_index]} {incr index} {
            charge tmp_ima2_$index -ext [lindex [decomp $ex_ext] 3] -rep "$rep_tmp" -buf $num_buf_tmp
            set TT_num 1
            while {[lindex [buf$num_buf_tmp getkwd TT${TT_num}] 1] != "IMA/SERIES REGISTER"} {
               incr TT_num
            }
            lappend depl_x [lindex [lindex [buf$num_buf_tmp getkwd TT[expr ${TT_num}+1]] 1] 2]
            lappend depl_y [lindex [lindex [buf$num_buf_tmp getkwd TT[expr ${TT_num}+2]] 1] 2]
         }
         set naxis1 [lindex [buf$num_buf_tmp getkwd NAXIS1] 1]
         set naxis2 [lindex [buf$num_buf_tmp getkwd NAXIS2] 1]
         serie_fenetre tmp_ima2_ tmp_ima2_ [list [expr -round([lmin $depl_x])] [expr -round([lmin $depl_y])] [expr $naxis1 - round([lmax $depl_x])] [expr $naxis2 - round([lmax $depl_y])]] -ext [lindex [decomp $ex_ext] 3] -rep "$rep_tmp"

         # Déplacement des fichiers
         renomme tmp_ima2_ $ex_serie -in_rep $rep_tmp -ex_rep $ex_rep -in_ext [lindex [decomp $in_ext] 3] -ex_ext $ex_ext
      }

      # Suppression du buffer temporaire
      buf::delete $num_buf_tmp

      # Suppression de fichier / répertoire temporaire
      suppr_serie tmp_ima_ -rep "$rep_tmp" -ext [lindex [decomp $in_ext] 3]
      file delete $rep_tmp

   } else {

      error $caption(divers,syntax,aligne)

   }
}

## @brief convertit des images RAW en FITS
#  @details documentation de cette fonction : @ref divers
#
proc raw2fits {args} {
    global audace caption conf

    if {[syntaxe_args $args 1 1 [list "" [list "-rep" "-in_ext" "-ex_ext" "-in_rep" "-ex_rep"]]]=="1"} {

        # Configuration du paramètre obligatoire
        set in_serie [lindex $args 0]

       # Configuration des options
        set options [lrange $args 1 [expr [llength $args]-1]]
        set range_options [range_options $options]

        # Configuration du paramètre optionnel
        if {[llength [lindex $range_options 0]] > 0} {
            set ex_serie [lindex $args 1]
        } else {
            set ex_serie $in_serie
        }

        # Configuration des options à 1 paramètre
        set options_1param [lindex $range_options 2]

        set rep_index [lsearch -regexp $options_1param "-rep"]
        set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
        set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
        set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
        set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]

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
        if {$in_ext_index>=0} {
            set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
        } else {
            # si rien n'est précisé, choix arbitraire d'un type de fichier RAW
            set in_ext ".cr2"
        }

        if {$ex_ext_index>=0} {
            set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
        } elseif {$conf(fichier,compres)==0} {
            set ex_ext $conf(extension,defaut)
        } else {
            set ex_ext $conf(extension,defaut).gz
        }

        # Procédure principale

        # On vérifie que la série de départ existe bien
        if {[serie_existe $in_serie -rep "$in_rep" -ext $in_ext] == 0} {
            return
        }

        # On récupère la liste des index de la série initiale...
        set liste_index [liste_index $in_serie -rep "$in_rep" -ext $in_ext]

        # Création du buffer temporaire
        set num_buf_tmp [buf::create]
        buf$num_buf_tmp extension $conf(extension,defaut)

        # Conversion de chaque image
        foreach index [lrange $liste_index 1 [expr [llength $liste_index]-1]] {
            charge $in_serie$index -rep "$in_rep" -ext $in_ext -buf $num_buf_tmp
            sauve $ex_serie$index -rep "$ex_rep" -ext $ex_ext -buf $num_buf_tmp
        }

        # Suppression du buffer temporaire
        buf::delete $num_buf_tmp

    } else {
        error "error function raw2fits"
        #    error $caption(divers,syntax,raw2fits)
    }
}

######################################################
###############   Fonctions avancées   ###############
######################################################

## @brief analyse le nom d'un fichier
#  @details documentation de cette fonction : @ref divers
#
proc decomp {args} {
   global audace caption conf

   if {[syntaxe_args $args 1 0 ""]=="1"} {

      # Configuration des paramètres obligatoires
      set filename [lindex $args 0]

      # Procédure principale
      if { [ string range $filename 0 0 ] == "." } {
         # Cas ou filename ne contient que l'extension avec ou sans compression
         set dossier "."
         # On détermine quelle est l'extension du fichier
         set ext [file extension $filename]
         switch $ext {
            ".gz" {
               # Cas où le fichier est compressé
               set gz ".gz"
               # On enregistre l'extension
               set extension [file rootname $filename]
            }
            ".bz2" {
               # Cas où le fichier est compressé
               set gz ".bz2"
               # On enregistre l'extension
               set extension [file rootname $filename]
            }
            default {
               # Cas où le fichier n'est pas compressé
               set gz ""
               set extension $ext
            }
         }
         # On ne garde que le nom du fichier
         set nom_fichier ""
         set index ""
      } else {
         # A tout nom de fichier (avec ou sans le chemin) cette procédure renvoie [dossier nom_generique index extension compression]
         set dossier [file dirname $filename]
         # On ne garde que le nom du fichier
         set filename [file tail $filename]
         # On détermine quelle est l'extension du fichier
         set ext [file extension $filename]
         switch $ext {
            ".gz" {
               # Cas où le fichier est compressé
               set gz ".gz"
               # On tronque de l'extension .gz
               set filename [file rootname $filename]
               # On enregistre l'extension
               set extension [file extension $filename]
            }
            ".bz2" {
               # Cas où le fichier est compressé
               set gz ".bz2"
               # On tronque de l'extension .bz2
               set filename [file rootname $filename]
               # On enregistre l'extension
               set extension [file extension $filename]
            }
           default {
               # Cas où le fichier n'est pas compressé
               set gz ""
               set extension $ext
            }
         }
         set nom_fichier [file rootname $filename]
         # On sépare à présent le nom générique et l'index
         set index ""
         set continue [dernier_est_chiffre $nom_fichier]
         while {$continue==1} {
            set index [string index $nom_fichier [expr [string length $nom_fichier]-1]]$index
            set nom_fichier [string range $nom_fichier 0 [expr [string length $nom_fichier]-2]]
            set continue [dernier_est_chiffre $nom_fichier]
         }
      }
      return [list $dossier $nom_fichier $index $extension $gz]
   } else {
      error $caption(divers,syntax,decomp)
   }
}

## @brief retourne une  liste indexée
#  @details documentation de cette fonction : @ref divers
#
proc liste_index {args} {
   global audace caption conf

   if {[syntaxe_args $args 1 0 [list "" [list "-rep" "-ext"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set nom_generique [lindex $args 0]

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

      # NB : On renvoie les index des fichiers dont le nom générique correspond à {nom_generique}
      # Sous-entendu : on s'occupe d'une série indexée...
      # On fait une première sélection
      set panier [glob -nocomplain [file join "$rep" $nom_generique*$ext]]
      # Attention ! Dans la liste référencée "panier" on a trop de fichiers ! En effet on a en plus :
      # 1) Un éventuel fichier nom_generique$ext (non indexé)
      # 2) Les fichiers dont le nom générique commence pareil mais est plus long
      # 3) Et même : des fichiers dont le nom générique commence pareil mais comprend des majuscules !!!!!!!!!!!!

      # On solutionne le point n°1 :
      # Pour que la fonction lsearch ne se mélange pas les crayons entre les extensions .FIT et .fit (par exemple)
      # on créée une nouvelle liste où les noms de fichiers sont tronqués de l'extension

      set new_panier ""
      foreach name $panier {
         lappend new_panier [string range $name 0 [expr [string length $name]-[string length $ext]-1]]
      }
      set no_index [lsearch -exact $new_panier [file join "$rep" $nom_generique]]
      if {$no_index>=0} {
         set panier [concat [lrange $panier 0 [expr $no_index-1]] [lrange $panier [expr $no_index+1] [expr [llength $panier]-1]]]
      }

      # Pour éviter des problèmes dans les cas où le nom générique se termine par un chiffre, on rajoute dans ce cas
      # un "_" dans tous les noms de fichiers
      if {[dernier_est_chiffre $nom_generique]=="1"} {
         set new_panier ""
         set borneinter [string length [file join "$rep" $nom_generique]]
         foreach name $panier {
            lappend new_panier [string range $name 0 [expr $borneinter-1]]_[string range $name $borneinter [expr [string length $name]-1]]
         }
         set panier $new_panier
         set nom_generique ${nom_generique}_
      }

      # On termine en résolvant les points 2 et 3 :
      set index_list ""
      foreach fichier $panier {
         set decomp [decomp $fichier]
         if {[lindex $decomp 1]==$nom_generique} {
            lappend index_list [lindex $decomp 2]
         }
      }
      return $index_list
   } else {
      error $caption(divers,syntax,liste_index)
   }
}

## @brief retourne une liste constituée des noms de séries du répertoire courant
#  @return
#  - message d'erreur en cas d'erreur de syntaxe
#
proc liste_series {args} {
   global audace caption conf

   if {[syntaxe_args $args 0 0 [list "" [list "-rep" "-ext"]]]=="1"} {

      # Configuration des paramètres obligatoires

      # Configuration des options
      set options $args

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

      # On récupère la liste des fichiers du répertoire courant
      set panier [glob -nocomplain [file join "$rep" *$ext]]

      # On parcours cette liste en enregistrant chaque nouvelle série
      set liste_series ""

      foreach fichier $panier {
         set decomp [decomp $fichier]
         if {[lsearch $liste_series [lindex $decomp 1]]==-1} {
            lappend liste_series [lindex $decomp 1]
         }
      }
      return $liste_series
   } else {
      error $caption(divers,syntax,liste_series)
   }
}

## @brief fait l'inventaire des sous-répertoires
#  @details documentation de cette fonction : @ref divers
#
proc liste_sousreps {args} {
   global audace caption conf

   if {[syntaxe_args $args 0 0 [list "" [list "-rep"]]]=="1"} {

      # Configuration des paramètres obligatoires

      # Configuration des options
      set options $args

      # Configuration des options à 1 paramètre
      set options_1param [lindex [range_options $options] 2]

      set rep_index [lsearch -regexp $options_1param "-rep"]

      if {$rep_index>=0} {
         set rep [lindex [lindex $options_1param $rep_index] 1]
      } else {
         set rep $audace(rep_images)
      }

      # Procédure principale

      # On récupère la liste des fichiers du répertoire courant
      set panier [glob -nocomplain [file join "$rep" *]]

      # On parcours cette liste en enregistrant chaque nouvelle série
      set liste_repertoires ""

      foreach entree $panier {
         if {[file isdirectory $entree]==1} {
            lappend liste_repertoires [file tail $entree]
         }
      }
      return $liste_repertoires
   } else {
      error $caption(divers,syntax,liste_sousreps)
   }
}

## @brief vérifie l'existence d'une série
#  @details documentation de cette fonction : @ref divers
#
proc serie_existe {args} {
   global audace caption conf

   if {[syntaxe_args $args 1 0 [list "" [list "-rep" "-ext"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set nom_generique [lindex $args 0]

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
      if {[liste_index $nom_generique -rep "$rep" -ext $ext] == ""} {
         console::affiche_resultat "$caption(divers,erreur,serie_existe) [file join $rep $nom_generique*$ext]\n"
         return "0"
      } else {
         return "1"
      }
   } else {
      error $caption(divers,syntax,serie_existe)
   }
}

## @brief teste la numérotation d'une série
#  @details documentation de cette fonction : @ref divers
#
proc numerotation_usuelle {args} {
   global audace caption conf

   if {[syntaxe_args $args 1 0 [list "" [list "-rep" "-ext"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set nom_generique [lindex $args 0]

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
      # On récupère les index
      set liste [liste_index $nom_generique -rep "$rep" -ext $ext]
      # On essaie de les ranger par ordre croissant
      set error [ catch { set liste [lsort -integer $liste] } msg ]
      if { $error == "0" } {
         catch [set liste [lsort -integer $liste]] {}
      } else {
         catch [set liste [lsort -ascii $liste]] {}
      }

      set k 1
      foreach index $liste {
         if {[string compare $k $index] != 0} {
            return 0
         }
         incr k
      }
      return 1
   } else {
      error $caption(divers,syntax,numerotation_usuelle)
   }
}

## @brief compare deux séries d'index
#  @param args
#  @return
#  - 1 si toutes les séries ont les mêmes index
#  - sinon 0
#  - message d'erreur en cas d'erreur de syntaxe
#
proc compare_index_series {args} {
   global audace caption conf

   if {[syntaxe_args $args 1 0 [list "" [list "-rep" "-ext"]]]=="1"} {

      # Configuration des paramètres obligatoires
      set liste_series [lindex $args 0]

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
      set nb_series [llength $liste_series]
      # On ne continue que si au moins deux noms de séries ont été indiqués
      if {$nb_series<2} {
         return 0
      } else {
         set sortie 1
         set liste_index_ref [lsort [liste_index [lindex $liste_series 0] -rep "$rep" -ext $ext]]
         foreach serie [lrange $liste_series 1 [expr $nb_series-1]] {
            if {$liste_index_ref != [lsort [liste_index $serie -rep "$rep" -ext $ext]]} {
               set sortie 0
               break
            }
         }
         return $sortie
      }
   } else {
      error $caption(divers,syntax,compare_index_series)
   }
}

## @brief créé un sous-dossier temporaire
#  @details documentation de cette fonction : @ref divers
#
proc cree_sousrep {args} {
   global audace caption

   if {[syntaxe_args $args 0 0 [list "" [list "-nom_base" "-rep"]]]=="1"} {

      # Configuration des paramètres obligatoires

      # Configuration des options
      set options $args

      # Configuration des options à 1 paramètre
      set options_1param [lindex [range_options $options] 2]

      set nom_base_index [lsearch -regexp $options_1param "-nom_base"]
      set rep_index [lsearch -regexp $options_1param "-rep"]

      if {$nom_base_index>=0} {
         set nom_base [lindex [lindex $options_1param $nom_base_index] 1]
      } else {
         set nom_base "tmp"
      }
      if {$rep_index>=0} {
         set rep [lindex [lindex $options_1param $rep_index] 1]
      } else {
         set rep $audace(rep_images)
      }

      # Si le répertoire indiqué est protégé en écriture :
      if {[file writable $rep] == 0} {
         switch $::tcl_platform(os) {
            "Linux" {
               # Pour linux : le sous-répertoire est créé dans /tmp/.audela
               set rep [file join /tmp .audela]
            }
            "Darwin" {
               # Pour MacOS : le sous-répertoire est créé dans /tmp/.audela
               set rep [file join /tmp .audela]
            }
            default {
               # Sous les autres OS, pas de solution pour l'instant !
            }
         }
      }

      # Procédure principale
      set subdir [file join "$rep" $nom_base]
      set k 0
      while {[file exist $subdir]=="1"} {
         incr k
         set subdir [file join "$rep" ${nom_base}_$k]
      }
      file mkdir $subdir
      return $subdir
   } else {
      error $caption(divers,syntax,cree_sousrep)
   }
}

## @brief créé un fichier vide dans un répertoire
#  @details documentation de cette fonction : @ref divers
#
proc cree_fichier {args} {
   global audace caption

   if {[syntaxe_args $args 0 0 [list "" [list "-nom_base" "-rep" "-ext"]]]=="1"} {

      # Configuration des paramètres obligatoires

      # Configuration des options
      set options $args

      # Configuration des options à 1 paramètre
      set options_1param [lindex [range_options $options] 2]

      set nom_base_index [lsearch -regexp $options_1param "-nom_base"]
      set rep_index [lsearch -regexp $options_1param "-rep"]
      set ext_index [lsearch -regexp $options_1param "-ext"]

      if {$nom_base_index>=0} {
         set nom_base [lindex [lindex $options_1param $nom_base_index] 1]
      } else {
         set nom_base "tmp"
      }
      if {$rep_index>=0} {
         set rep [lindex [lindex $options_1param $rep_index] 1]
      } else {
         set rep $audace(rep_images)
      }
      if {$ext_index>=0} {
         set ext [lindex [lindex $options_1param $ext_index] 1]
      } else {
         set ext ""
      }

      # Si le répertoire de destination n'existe pas, on le crée.
      if {[file exist $rep]=="0"} {
         file mkdir $rep
      }

      # Cas où le répertoire indiqué est protégé en écriture :
      if {[file writable $rep] == 0} {
         switch $::tcl_platform(os) {
            "Linux" {
               # Pour linux : le fichier est créé dans /tmp/.audela
               if {[file exist [file join /tmp .audela]]=="0"} {
                  file mkdir [file join /tmp .audela]
                  exec "chmod a+w [file join /tmp .audela]"
               }
               set rep [file join /tmp .audela]
            }
            default {
               # Sous les autres OS, pas de solution pour l'instant !
            }
         }
      }

      # Procédure principale
      set fichier [file join "$rep" $nom_base$ext]
      set k 0
      while {[file exist $fichier]=="1"} {
         incr k
         set fichier [file join "$rep" ${nom_base}_$k$ext]
      }
      set f [open $fichier w]
      close $f
      return $fichier
   } else {
      error $caption(divers,syntax,cree_fichier)
   }
}

## @brief teste la validité d'une liste d'arguments
#  @details documentation de cette fonction : @ref divers
#
proc syntaxe_args {args} {
   global caption

   if {[llength $args]==4} {

      # Configuration des paramètres obligatoires
      set list_args_averifier [lindex $args 0]
      set nb_args_obligatoires [lindex $args 1]
      set nb_args_optionnels [lindex $args 2]
      set list_options_valides [lindex $args 3]

      # Procédure principale
      # On vérifie que l'on a suffisamment d'arguments à se mettre sous la dent
      if {[llength $list_args_averifier]<$nb_args_obligatoires} {
         return 0
      }
      # On détermine le nombre d'arguments optionnels
      set args_optionnels_en_cours 0
      while {$args_optionnels_en_cours<$nb_args_optionnels} {
         if {[string index [lindex $list_args_averifier [expr $nb_args_obligatoires+$args_optionnels_en_cours]] 0]=="-"} {
            break
         } else {
            incr args_optionnels_en_cours
         }
      }
      # On passe à présent aux options
      set list_opts_averifier [lrange $list_args_averifier [expr $nb_args_obligatoires+$args_optionnels_en_cours] [expr [llength $list_args_averifier]-1]]
      set index 0
      set ind_max [expr [llength $list_opts_averifier]-1]
      while {$index<=$ind_max} {
         # On vérifie que l'on pointe sur une option qui existe bien
         set ou_est_loption [lsearch -regexp $list_options_valides [lindex $list_opts_averifier $index]]
         if {$ou_est_loption == "-1"} {
            console::affiche_resultat "$caption(divers,invalide_opt)[lindex $list_opts_averifier $index]\n"
            return 0
         } else {
            # Donc l'option existe.
            # On vérifie que :
            # 1) la liste des options à vérifier est assez longue pour contenir tous les paramètres de l'option
            if {[expr $index+$ou_est_loption]>$ind_max} {
               console::affiche_resultat "$caption(divers,oubli_param_opt)[lindex $list_opts_averifier $index]\n"
               return 0
               # 2) parmi les paramètres de l'option, il n'y a pas un truc qui commence par un "-" et qui serait donc une option
            } else {
               set k 0
               while {$k<$ou_est_loption} {
                  if {[string index [lindex $list_opts_averifier [expr $index+$k+1]] 0]=="-"} {
                     console::affiche_resultat "$caption(divers,oubli_param_opt)[lindex $list_opts_averifier $index]\n"
                     return 0
                  }
                  incr k
               }
               # Si on en est là, c'est que c'est bon. On incrémente l'index en conséquence.
               incr index [expr $ou_est_loption+1]
            }
         }
      }
      # Tout s'est bien passé !
      return 1
   } else {
      error $caption(divers,syntax,syntaxe_args)
   }
}

## @brief trie une liste d'options
#  @details documentation de cette fonction : @ref divers
#
proc range_options {args} {
   global caption

   if {[syntaxe_args $args 1 0 ""]=="1"} {

      # Configuration des paramètres obligatoires
      set list_opts [lindex $args 0]

      # Procédure principale
      set index 0
      set ind_max [expr [llength $list_opts]-1]
      # On commence par mettre dans une liste "list_args_opt" les arguments optionnels qui peuvent être présents en début de liste
      while {$index<=$ind_max} {
         if {[string index [lindex $list_opts $index] 0]=="-"} {
            break
         }
         incr index
      }
      set list_args_opt [lrange $list_opts 0 [expr $index-1]]

      set option_en_cours ""
      # Une option et ses arguments consitue une sous-liste que l'on enregistre dans la liste list_X, où X est le nombre
      # d'entrées pour l'option

      # On garde en mémoire dans la variable X le Xmax atteint.
      set X "-1"

      while {$index<=$ind_max} {
         set option_en_cours [lappend option_en_cours [lindex $list_opts $index]]

         # Si l'élément en position index+1 commence par "-", ou si l'on est dans la dernière boucle :
         # on enregistre l'option en cours dans la liste list_X qui lui convient.
         if {([string index [lindex $list_opts [expr $index+1]] 0]=="-")||($index==$ind_max)} {
            set type_option [expr [llength $option_en_cours]-1]
            # Si besoin on initialise la liste list_X, et les sous-listes list_Y où Y < X
            if {[info exist list_$type_option]==0} {
               for {set k [expr $X+1]} {$k<=$type_option} {incr k} {
                  set list_$k ""
               }
               set X $type_option
            }
            lappend list_$type_option $option_en_cours
            set option_en_cours ""
         }
         # Sinon, on poursuit.

         # Dans tous les cas on incrémente l'index.
         incr index
      }

      # On retourne une liste dont les éléments sont les listes list_X
      if {$X>10} {
         console::affiche_resultat "Option avec trop d'arguments, contacter B. Maugis pour mettre à jour la fontion range_options.\n"
      }
      switch -exact -- $X {
         "-1" {return [list $list_args_opt]}
         "0"  {return [list $list_args_opt $list_0]}
         "1"  {return [list $list_args_opt $list_0 $list_1]}
         "2"  {return [list $list_args_opt $list_0 $list_1 $list_2]}
         "3"  {return [list $list_args_opt $list_0 $list_1 $list_2 $list_3]}
         "4"  {return [list $list_args_opt $list_0 $list_1 $list_2 $list_3 $list_4]}
         "5"  {return [list $list_args_opt $list_0 $list_1 $list_2 $list_3 $list_4 $list_5]}
         "6"  {return [list $list_args_opt $list_0 $list_1 $list_2 $list_3 $list_4 $list_5 $list_6]}
         "7"  {return [list $list_args_opt $list_0 $list_1 $list_2 $list_3 $list_4 $list_5 $list_6 $list_7]}
         "8"  {return [list $list_args_opt $list_0 $list_1 $list_2 $list_3 $list_4 $list_5 $list_6 $list_7 $list_8]}
         "9"  {return [list $list_args_opt $list_0 $list_1 $list_2 $list_3 $list_4 $list_5 $list_6 $list_7 $list_8 $list_9]}
         "10" {return [list $list_args_opt $list_0 $list_1 $list_2 $list_3 $list_4 $list_5 $list_6 $list_7 $list_8 $list_9 $list_10]}
         default {return ""}
      }
      # fin -)
   } else {
      error $caption(divers,syntax,range_options)
   }
 }
## @brief calcule les paramètres de translation, rotation et zoom permettant de superposer au plus près deux boîtes de sélection
#  @details documentation de cette fonction : @ref divers
#
proc calcul_trzaligne {args} {
   global caption

   if {[syntaxe_args $args 2 0 ""]=="1"} {

      # Configuration des paramètres obligatoires
      set liste_coord1 [lindex $args 0]
      set liste_coord2 [lindex $args 1]

      # Procédure principale
      # On appelle (x1,y1) les coordonnées du 1er point de la 1ère liste,
      # (x2,y2) les coordonnées du 2nd point de la 1ère liste, (x'1,y'1) les
      # coordonnées du 1er point de la seconde liste, (x'2,y'2) les coordonnées
      # du 2nd point de la seconde liste.
      set x1 [lindex $liste_coord1 0]
      set y1 [lindex $liste_coord1 1]
      set x2 [lindex $liste_coord1 2]
      set y2 [lindex $liste_coord1 3]
      set x'1 [lindex $liste_coord2 0]
      set y'1 [lindex $liste_coord2 1]
      set x'2 [lindex $liste_coord2 2]
      set y'2 [lindex $liste_coord2 3]

      # Soient (xI,yI) les coordonnées du milieu du segment (x1,y1), (x2,y2)
      set xI [expr 0.5*($x1+$x2)]
      set yI [expr 0.5*($y1+$y2)]

      # Soient (x'I,y'I) les coordonnées du milieu du segment (x'1,y'1), (x'2,y'2)
      set x'I [expr 0.5*(${x'1}+${x'2})]
      set y'I [expr 0.5*(${y'1}+${y'2})]

      # Soient (v1,v2) les coordonnées d'un vecteur directeur de la médiatrice du 1er segment,
      set v1 [expr $y2-$y1]
      set v2 [expr $x1-$x2]
      # On norme ce vecteur.
      set N [expr sqrt( pow( $v1 , 2) + pow( $v2 , 2) )]
      set v1 [expr 1.0 * $v1 / $N]
      set v2 [expr 1.0 * $v2 / $N]

      # Soient (v'1,v'2) les coordonnées d'un vecteur directeur de la médiatrice du 1er segment,
      # que l'on norme
      set v'1 [expr ${y'2}-${y'1}]
      set v'2 [expr ${x'1}-${x'2}]
      # On norme ce vecteur.
      set N [expr sqrt( pow( ${v'1} , 2) + pow( ${v'2} , 2) )]
      set v'1 [expr 1.0 * ${v'1} / $N]
      set v'2 [expr 1.0 * ${v'2} / $N]

      # Alors la correction de translation consiste à déplacer (x'I,y'I) sur (xI,yI) :
      set translx [expr $xI - ${x'I}]
      set transly [expr $yI - ${y'I}]

      # L'angle de rotation theta s'obtient par le produit scalaire de (v1,v2) et (v'1,v'2) qui vaut
      # cos(theta) puisque les vecteurs sont normés. On convertit directement theta en degrés décimaux.
      set theta [expr 180*acos( $v1 * ${v'1} + $v2 * ${v'2} ) / 3.14159265359]

      # On a obtenu pour theta la solution comprise entre 0 et 180 degrés. Pour traiter le cas d'un
      # theta négatif, on calcule le produit vectoriel de (v1,v2) et (v'1,v'2) qui est un vecteur
      # orthogonal de norme 1. Sa composante orthogonale vaut donc -1 (theta entre 0 et 180 degrés) ou +1
      # (theta entre -180 et 0 degrés).
      set prodvect [expr $v1 * ${v'2} - $v2 * ${v'1}]

      # On corrige theta en conséquence
      if {$prodvect>0} {
         set theta [expr -1.0*$theta]
      }

      # Calcul du facteur de zoom : c'est la norme du 1er segment divisée par la norme du 2nd.
      set zoom [expr sqrt( 1.0 *  ( pow( $x2 - $x1 , 2) + pow( $y2 - $y1 , 2) ) / ( pow( ${x'2} - ${x'1} , 2) + pow( ${y'2} - ${y'1} , 2) ) ) ]

      # On renvoie le résultat des corrections à apporter.
      return [list $translx $transly $xI $yI $theta $zoom]

   } else {
      error $caption(divers,syntax,calcul_trzaligne)
   }
}

## @brief teste si la valeur est un nombre entier
#  @details documentation de cette fonction : @ref divers
#
proc TestEntier {args} {
   global caption

   if {[syntaxe_args $args 1 0 ""]=="1"} {
      set chaine [lindex $args 0]
      set result 0
      if { $chaine != "" } {
         set result [ string is integer $chaine ]
      }
      return $result
   } else {
      error $caption(divers,syntax,TestEntier)
   }
}

## @brief teste si la valeur est un nombre réel
#  @details documentation de cette fonction : @ref divers
#
proc TestReel {args} {
   global caption

   if {[syntaxe_args $args 1 0 ""]=="1"} {
      set valeur [lindex $args 0]
      if { $valeur != "" } {
         set pattern {^([-+]?[0-9]*\.?[0-9]+)([eE][-+]?[0-9]+)?$}
         regexp $pattern $valeur whole
         if { [ info exists whole ] && $valeur eq $whole } {
            return 1
         } else {
            return 0
         }
      }
   } else {
      error $caption(divers,syntax,TestReel)
   }
}

## @brief teste si le dernier caractère d'une chaîne est un nombre décimal
#  @details documentation de cette fonction : @ref divers
#
proc dernier_est_chiffre {args} {
   global caption

    if {[syntaxe_args $args 1 0 ""]=="1"} {
      set dernier [ string index [lindex $args 0] end ]
      # cas particulier d'une chaîne vide
       if {$dernier==""} {
          return 0
       } else {
          return [ string is digit $dernier ]
       }
   } else {
      error $caption(divers,syntax,dernier_est_chiffre)
   }
}

## @brief teste la présence de caractères accentués
#  @details documentation de cette fonction : @ref divers
#
proc nom_valide {args} {
   global caption

   if {[syntaxe_args $args 1 0 ""]=="1"} {

      if { [ regexp -all {[àâçéèêëîïôöùüû]} [lindex $args 0] ] } {
         return 0
      } else {
         return 1
      }
   } else {
      error $caption(divers,syntax,nom_valide)
   }
}

## @brief supprime les accents dans une chaîne de caractères
#  @details documentation de cette fonction : @ref divers
#
proc suppr_accents {args} {
   global caption

   if {[syntaxe_args $args 1 0 ""]=="1"} {
      set entities [list à a â a ç c é e è e ê e ë e î i ï i ô o ö o û u ü u ü u]
      return [string map -nocase $entities [lindex $args 0]]
   } else {
      error $caption(divers,syntax,suppr_accents)
   }
}

## @brief transforme une date au format "année mois jour" en date "jour mois_civil année"
#  @code
#  date_chiffresAlettres [list 99 08 15]
#  #15 août 99
#  @endcode
#  @details documentation de cette fonction : @ref divers
#
proc date_chiffresAlettres {args} {
   global caption

   set err 0
   if {[syntaxe_args $args 1 0 ""]=="1"} {

      # Configuration des paramètres obligatoires
      set date_chiffres [lindex $args 0]

      # Procédure principale
      set annee [lindex ${date_chiffres} 0]

      set mois_chiffre [lindex ${date_chiffres} 1]
      set mois_chiffre [string trimleft $mois_chiffre 0]
      if {$mois_chiffre < "1" || $mois_chiffre > "12"} {
         set err 1
      } elseif {[regexp {1|2|3|4|5|6|7|8|9|10|11|12} $mois_chiffre]} {
         set liste_mois [ list nihil janvier février mars avril mai \
         juin juillet août septembre octobre novembre décembre ]
         set mois_lettres [ lindex $liste_mois $mois_chiffre ]
      }

      set jour [lindex ${date_chiffres} 2]
      set jour [string trimleft $jour 0]
      if {$jour < "1" || $jour > "31"} {
         set err 1
      }
      if {$jour == "1"} {set jour "1er"}
   } else {
      set err 1
   }
   if {$err eq 0} {
      return "$jour $mois_lettres $annee"
   } else {
      error $caption(divers,syntax,date_chiffresAlettres)
   }
}

## @brief retourne le minimum d'une liste de nombres
#  @details documentation de cette fonction : @ref divers
#
proc lmin {liste} {
   global caption

   ::blt::vector create test -watchunset 1
   if ![ catch { test append $liste } ] {
      set index [ lindex [ test search $test(min) ] 0 ]
      set result [ lindex $liste $index ]
   } else {
      set result ""
      tk_messageBox -title "$caption(divers,attention)" -type ok \
         -message [ format "$caption(divers,err_list_of_number)" $liste ]
  }
   ::blt::vector destroy test
   return $result
}

## @brief retourne le maximum d'une liste de nombres
#  @details documentation de cette fonction : @ref divers
#
proc lmax {liste} {
   global caption

   ::blt::vector create test -watchunset 1
   if ![ catch { test append $liste } ] {
      set index [ lindex [ test search $test(max) ] 0 ]
      set result [ lindex $liste $index ]
   } else {
      set result ""
      tk_messageBox -title "$caption(divers,attention)" -type ok \
         -message [ format "$caption(divers,err_list_of_number)" $liste ]
   }
   ::blt::vector destroy test
   return $result
}

## @brief teste si un fichier ou une extension de fichier est au format APN "RAW"
#  @param args nom du fichier
#  @return
#  - 1 si lextension est .crw , .CRW, .cr2, .CR2, .nef, .NEF, .dng ou .DNG
#  - sinon 0
#  - message d'erreur en cas d'erreur de syntaxe
#
proc isRaw {args} {
   global caption

   if {[syntaxe_args $args 1 0 ""]=="1"} {
      set fichier [lindex $args 0]
       if {[lsearch [list ".crw" ".CRW" ".cr2" ".CR2" ".nef" ".NEF" ".dng" ".DNG"] [file extension $fichier]] >= 0} {
          return 1
       } else {
          return 0
       }
   } else {
#      error $caption(divers,syntax,isRaw)
       error "Error isRaw: wrong syntax"
   }
}

########## The end ##########

