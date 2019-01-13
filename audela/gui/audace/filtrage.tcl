##
# @file filtrage.tcl
# @brief Scripts pour un usage aise des fonctions d'AudeLA
# @author Benjamin MAUCLAIRE (bma.ova@mail.com)
# $Id: filtrage.tcl 13989 2016-06-21 10:56:43Z rzachantke $
#

#--------------------- Liste des fonctions -----------------------------------#
#
# bm_masque_flou     : Convolution par un filtre passe-bas effectuant un masque flou d'une image
# bm_passe_bas       : Convolution par un filtre passe-bas "éliminant le bruit"
# bm_passe_haut      : Convolution par un filtre passe-haut "éliminant les formes"
# bm_filtre_median   : Convolution par un filtre median effectuant un genre de "moyenne"
# bm_filtre_min      : Convolution par un filtre minimum
# bm_filtre_max      : Convolution par un filtre maximum
# bm_filtre_gauss    : Convolution d'image par un filtre de forme gaussienne (lisse l'image)
# bm_ondelette_mor   : Convolution d'image par un filtre de forme chapeau type morlet
#                      (met en evidence les details noyes dans la nebulosite)
# bm_ondelette_mex   : Convolution d'image par un filtre de forme chapeau type mexicain
#                      (met en evidence les details noyes dans la nebulosite)
# bm_logima          : Logarithme d'une image avec des coefficients adaptes a une image brillante
# gradient_nose      : Maximum des 4 gradients N,O,S et E.
#-----------------------------------------------------------------------------#

#---------------------- Artifice ---------------------------------------------#
#
#--- La variable "audace(artifice)" vaut toujours "@@@@" c'est un artifice qui
#--- permet d'attribuer cette valeur a la variable "fichier" dans le cas d'une
#--- image chargee en memoire
#--- Cette variable "audace(artifice)" est definie dans le script "aud_menu_4.tcl"
#
#-----------------------------------------------------------------------------#


## @brief calcule le gradient
#  @details : le calcul est fait suivant les 4 directions N,O,S et E,
#  puis chaque pixel est affecté du pixel maximal de chaque image
#  @param args liste contenant :
#  - le nom de l'image à traiter
#  - la taille du noyau à appliquer sur les gradients
proc gradient_nose { args } {

    global audace
    global conf
    global caption
    global traiteFilters

    if { ([llength $args] == 1) || ([llength $args] == 2) } {
        set fichier [ lindex $args 0 ]
        set taille_noyau 3
        if {[llength $args] == 2} {
            set taille_noyau [ lindex $args 1 ]
        }
        if { ($fichier == "") } {
            ::console::affiche_erreur "Usage: gradient_nose filename \[kernel size\]\n"
        } else {
            #--- Verif existence
            set filein   "$fichier$conf(extension,defaut)"
            set filetmp "${fichier}_tmp$conf(extension,defaut)"
            set filetmp0 "${fichier}_tmp0$conf(extension,defaut)"
            set filetmp1 "${fichier}_tmp1$conf(extension,defaut)"
            set filetmp2 "${fichier}_tmp2$conf(extension,defaut)"
            set filetmp3 "${fichier}_tmp3$conf(extension,defaut)"
            set filetmp4 "${fichier}_tmp4$conf(extension,defaut)"

            #--- Algo
            if { ( ![info exists audace(artifice)] ) || ( $fichier != "$audace(artifice)" ) } {
                if { [ file exist $filein ] == "1" } {
                    ::console::affiche_resultat "$caption(filtrage,chargement) $fichier$conf(extension,defaut)\n\n"
                    buf$audace(bufNo) load "$filein"
                    buf$audace(bufNo) imaseries "FILTER kernel_type=gradup kernel_coef=0 kernel_width=$taille_noyau"
                    buf$audace(bufNo) save "$filetmp1"
                    buf$audace(bufNo) load "$filein"
                    buf$audace(bufNo) imaseries "FILTER kernel_type=graddown kernel_coef=0 kernel_width=$taille_noyau"
                    buf$audace(bufNo) save "$filetmp2"
                    buf$audace(bufNo) load "$filein"
                    buf$audace(bufNo) imaseries "FILTER kernel_type=gradleft kernel_coef=0 kernel_width=$taille_noyau"
                    buf$audace(bufNo) save "$filetmp3"
                    buf$audace(bufNo) load "$filein"
                    buf$audace(bufNo) imaseries "FILTER kernel_type=gradright kernel_coef=0 kernel_width=$taille_noyau"
                    buf$audace(bufNo) save "$filetmp4"

                    set rep [file dirname $filetmp]
                    set nom [file rootname [file tail $filetmp]]
                    ttscript2 "IMA/STACK \"$rep\" \"$nom\" \"1\" \"4\" \".fit\" \"$rep\" \"$nom\" \"0\" \".fit\" SORT percent=100 nullpixel=-5000"
                    buf$audace(bufNo) load "$filetmp0"
                    ::audace::autovisu $audace(visuNo)
                    catch {file delete -force "$filetmp0"}
                    catch {file delete -force "$filetmp1"}
                    catch {file delete -force "$filetmp2"}
                    catch {file delete -force "$filetmp3"}
                    catch {file delete -force "$filetmp4"}
                    set traiteFilters(avancement) $caption(filtrage,fin_traitement)
                } else {
                    tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_de_fichier)
                    set traiteFilters(avancement) ""
                }
            } else {
                if { [ buf[ ::confVisu::getBufNo $audace(visuNo) ] imageready ] == "0" } {
                    tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_image_memoire)
                    set traiteFilters(avancement) ""
                } else {
                    buf$audace(bufNo) save "$filein"
                    buf$audace(bufNo) imaseries "FILTER kernel_type=gradup kernel_coef=0 kernel_width=$taille_noyau"
                    buf$audace(bufNo) save "$filetmp1"
                    buf$audace(bufNo) load "$filein"
                    buf$audace(bufNo) imaseries "FILTER kernel_type=graddown kernel_coef=0 kernel_width=$taille_noyau"
                    buf$audace(bufNo) save "$filetmp2"
                    buf$audace(bufNo) load "$filein"
                    buf$audace(bufNo) imaseries "FILTER kernel_type=gradleft kernel_coef=0 kernel_width=$taille_noyau"
                    buf$audace(bufNo) save "$filetmp3"
                    buf$audace(bufNo) load "$filein"
                    buf$audace(bufNo) imaseries "FILTER kernel_type=gradright kernel_coef=0 kernel_width=$taille_noyau"
                    buf$audace(bufNo) save "$filetmp4"

                    set rep [file dirname $filetmp]
                    set nom [file rootname [file tail $filetmp]]
                    ttscript2 "IMA/STACK \"$rep\" \"$nom\" \"1\" \"4\" \".fit\" \"$rep\" \"$nom\" \"0\" \".fit\" SORT percent=100 nullpixel=-5000"
                    buf$audace(bufNo) load "$filetmp0"
                    ::audace::autovisu $audace(visuNo)
                    catch {file delete -force "$filetmp0"}
                    catch {file delete -force "$filetmp1"}
                    catch {file delete -force "$filetmp2"}
                    catch {file delete -force "$filetmp3"}
                    catch {file delete -force "$filetmp4"}
                    catch {file delete -force "$filein"}
                    set traiteFilters(avancement) $caption(filtrage,fin_traitement)
                }
            }
        }

    } else {
        ::console::affiche_erreur "Usage: gradient_nose filename \[kernel size\]\n"
    }
}

#*****************************************************************************#
#
# Description : Convolution par un filtre passe-bas effectuant un masque flou d'une image
#
#*****************************************************************************#

#--- Dans ce fichier, les commandes des messages en console/caption sont commentes lorsqu'il est dans
#--- le repertoire des scripts
proc bm_masque_flou { args } {
   #--- arg : fichier coefg coefm
   #--- Arguments : coefg = coefficient du filtre gaussien (0.8 en general), coefm = coefficient de multiplication
   #--- des "details" (en general 1.3)
   #--- Les variables nommees audace_* sont globales
   global audace
   global conf
   global caption
   global traiteFilters

   if { [llength $args] == 3 } {
      set fichier [ lindex $args 0 ]
      set coefg [ lindex $args 1 ]
      set coefm [ lindex $args 2 ]

      if { ($fichier == "") || ($coefg == "") || ($coefm == "") } {
         ::console::affiche_erreur "Usage: bm_masque_flou filename coef_gauss mult\n"
      } else {
         #--- Verif existence
         set filein   "$fichier$conf(extension,defaut)"
         set filetmp  "${fichier}_tmp$conf(extension,defaut)"
         set filetmp1 "${fichier}_tmp1$conf(extension,defaut)"
         #--- Algo
         if { ( ![info exists audace(artifice)] ) || ( $fichier != "$audace(artifice)" ) } {
            if { [ file exist $filein ] == "1" } {
               ::console::affiche_resultat "$caption(filtrage,chargement) $fichier$conf(extension,defaut)\n\n"
               buf$audace(bufNo) load "$filein"
               convgauss $coefg
               buf$audace(bufNo) save "$filetmp"
               buf$audace(bufNo) load "$filein"
               buf$audace(bufNo) sub $filetmp 0
               buf$audace(bufNo) mult $coefm
               buf$audace(bufNo) add "$filein" 0
               ::audace::autovisu $audace(visuNo)
               catch {file delete -force "$filetmp"}
               set traiteFilters(avancement) $caption(filtrage,fin_traitement)
            } else {
               tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_de_fichier)
               set traiteFilters(avancement) ""
            }
         } else {
            if { [ buf[ ::confVisu::getBufNo $audace(visuNo) ] imageready ] == "0" } {
               tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_image_memoire)
               set traiteFilters(avancement) ""
            } else {
               buf$audace(bufNo) save "$filetmp1"
               convgauss $coefg
               buf$audace(bufNo) save "$filetmp"
               buf$audace(bufNo) load "$filetmp1"
               buf$audace(bufNo) sub $filetmp 0
               buf$audace(bufNo) mult $coefm
               buf$audace(bufNo) add "$filetmp1" 0
               ::audace::autovisu $audace(visuNo)
               catch {file delete -force "$filetmp"}
               catch {file delete -force "$filetmp1"}
               set traiteFilters(avancement) $caption(filtrage,fin_traitement)
            }
         }
      }
   } else {
      ::console::affiche_erreur "Usage: bm_masque_flou filename coef_gauss mult\n"
   }
}

#-----------------------------------------------------------------------------#
## @brief calcule la taille du noyau de convolution
#  @param noyau_demande taille demandée pour le noyau
#  @return taille du noyau
proc contraint_noyau { noyau_demande } {
    set naxis1 [ lindex [ buf$::audace(bufNo) getkwd NAXIS1 ] 1 ]
    set naxis2 [ lindex [ buf$::audace(bufNo) getkwd NAXIS2 ] 1 ]
    set rapport_max 3
    if { $naxis1 > $naxis2 } {
        set taille_max [ expr $naxis2 / $rapport_max ]
    } else {
        set taille_max [ expr $naxis1 / $rapport_max ]
    }
    set noyau $noyau_demande
    if { $noyau_demande > $taille_max } {
        set noyau $taille_max
        ::console::affiche_erreur "The kernel size is too big and has been clipped to $noyau\n"
    }
    if { $noyau < 3 } {
        set noyau 3
        ::console::affiche_erreur "The kernel_size is set to 3"
    }
    return $noyau
}


## @brief Filtres passe-bas, passe-haut, median, min, max
#  @param args liste contenant :
#  - le type du filtre
#  - le nom du fichier
#  - l'efficacité :
#    - 0=intense
#    - 1=aucun effet
#  - la taille du noyau
proc bm_filter { args } {
   #--- arg : type_filtre fichier efficacite
   #--- Arguments : efficacite = efficacite du filtre (0=intense, 1=aucun effet)
   #--- Les variables nommees audace_* sont globales
   global audace
   global conf
   global caption
   global traiteFilters

   if { ( [llength $args] == 3 ) || ( [llength $args] == 4 ) } {
      set type_filtre [ lindex $args 0 ]
      set fichier [ lindex $args 1 ]
      set efficacite [ lindex $args 2 ]

      set taille_noyau_demande 3
      if { [llength $args] == 4 } {
         set taille_noyau_demande [ lindex $args 3 ]
      }

      if { ($fichier == "") || ($efficacite == "") } {
         if { $type_filtre == "fb" } {
            ::console::affiche_erreur "Usage: bm_passe_bas filename \[efficiency 0...1 \[kernel_size\]\]\n"
         } elseif { $type_filtre == "fh" } {
            ::console::affiche_erreur "Usage: bm_passe_haut filename \[efficiency 0...1 \[kernel_size\]\]\n"
         } elseif { $type_filtre == "med" } {
            ::console::affiche_erreur "Usage: bm_filtre_median filename \[efficiency 0...1 \[kernel_size\]\]\n"
         } elseif { $type_filtre == "min" } {
            ::console::affiche_erreur "Usage: bm_filtre_min filename \[efficiency 0...1 \[kernel_size\]\]\n"
         } elseif { $type_filtre == "max" } {
            ::console::affiche_erreur "Usage: bm_filtre_max filename \[efficiency 0...1 \[kernel_size\]\]\n"
         }
      } else {
         if { $type_filtre == "fb" } {
            set filter "filtre_passe-bas"
         } elseif { $type_filtre == "fh" } {
            set filter "filtre_passe-haut"
         } elseif { $type_filtre == "med" } {
            set filter "filtre_median"
         } elseif { $type_filtre == "min" } {
            set filter "filtre_minimum"
         } elseif { $type_filtre == "max" } {
            set filter "filtre_maximum"
         }

         #--- Verif existence
         set filein  "$fichier$conf(extension,defaut)"
         #--- Algo

         if {  ( ![info exists audace(artifice)] ) || ( $fichier != "$audace(artifice)" ) } {
            if { [ file exist $filein ] == "1" } {
               ::console::affiche_resultat "$caption(filtrage,chargement) $fichier$conf(extension,defaut)\n\n"
               buf$audace(bufNo) load "$filein"
               set taille_noyau [ contraint_noyau $taille_noyau_demande ]
               buf$audace(bufNo) imaseries "FILTER kernel_type=$type_filtre kernel_coef=$efficacite kernel_width=$taille_noyau"
               ::audace::autovisu $audace(visuNo)
               set traiteFilters(avancement) $caption(filtrage,fin_traitement)
            } else {
               tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_de_fichier)
               set traiteFilters(avancement) ""
            }
         } else {
            if { [ buf[ ::confVisu::getBufNo $audace(visuNo) ] imageready ] == "0" } {
               tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_image_memoire)
               set traiteFilters(avancement) ""
            } else {
               set taille_noyau [ contraint_noyau $taille_noyau_demande ]
               buf$audace(bufNo) imaseries "FILTER kernel_type=$type_filtre kernel_coef=$efficacite kernel_width=$taille_noyau"
               ::audace::autovisu $audace(visuNo)
               set traiteFilters(avancement) $caption(filtrage,fin_traitement)
            }
         }
      }
   } else {
      ::console::affiche_erreur "Usage: bm_filter filter_type filename efficiency\n"
   }
}

#-----------------------------------------------------------------------------#
## @brief filtre passe-bas
#  @param args liste contenant :
#  - le nom du fichier
#  - l'efficacité du filtre :
#    - 0=intense
#    - 1=aucun effet
#  - la taille du noyau
proc bm_passe_bas { args } {
   if { ( [llength $args] == 2 ) || ( [llength $args] == 3 ) } {
      set fichier [ lindex $args 0 ]
      set efficacite [ lindex $args 1 ]
      set taille_noyau 3
      if { [llength $args] == 3 } {set taille_noyau [lindex $args 2]}
      bm_filter fb $fichier $efficacite $taille_noyau
   } else {
      ::console::affiche_erreur "Usage: bm_passe_bas filename \[efficiency 0...1 \[kernel size\]\]\n"
   }
}
#-----------------------------------------------------------------------------#

## @brief filtre passe-haut
#  @param args liste contenant :
#  - le nom du fichier
#  - l'efficacité du filtre :
#    - 0=intense
#    - 1=aucun effet
#  - la taille du noyau
proc bm_passe_haut { args } {

   if { ( [llength $args] == 2 ) || ( [llength $args] == 3 ) } {
      set fichier [ lindex $args 0 ]
      set efficacite [ lindex $args 1 ]
      set taille_noyau 3
      if { [llength $args] == 3 } {set taille_noyau [lindex $args 2]}
      bm_filter fh $fichier $efficacite $taille_noyau
   } else {
      ::console::affiche_erreur "Usage: bm_passe_haut filename \[efficiency 0...1 \[kernel size\]\]\n"
   }
}
#-----------------------------------------------------------------------------#

## @brief filtre median
#  @param args liste contenant :
#  - le nom du fichier
#  - l'efficacité du filtre :
#    - 0=intense
#    - 1=aucun effet
#  - la taille du noyau
proc bm_filtre_median { args } {

   if { ( [llength $args] == 2 ) || ( [llength $args] == 3 ) } {
      set fichier [ lindex $args 0 ]
      set efficacite [ lindex $args 1 ]
      set taille_noyau 3
      if { [llength $args] == 3 } {set taille_noyau [lindex $args 2]}
      bm_filter med $fichier $efficacite $taille_noyau
   } else {
      ::console::affiche_erreur "Usage: bm_filtre_median filename \[efficiency 0...1 \[kernel size\]\]\n"
   }
}
#-----------------------------------------------------------------------------#

## @brief filtre minimal (érosion en morphologie mathématique)
#  @param args liste contenant :
#  - le nom du fichier
#  - l'efficacité du filtre :
#    - 0=intense
#    - 1=aucun effet
#  - la taille du noyau
proc bm_filtre_min { args } {

   if { ( [llength $args] == 2 ) || ( [llength $args] == 3 ) } {
      set fichier [ lindex $args 0 ]
      set efficacite [ lindex $args 1 ]
      set taille_noyau 3
      if { [llength $args] == 3 } {set taille_noyau [lindex $args 2]}
      bm_filter min $fichier $efficacite $taille_noyau
   } else {
      ::console::affiche_erreur "Usage: bm_filtre_min filename \[efficiency 0...1 \[kernel size\]\]\n"
   }
}
#-----------------------------------------------------------------------------#

## @brief filtre minimal (dilatation en morphologie mathématique)
#  @param args liste contenant :
#  - le nom du fichier
#  - l'efficacité du filtre :
#    - 0=intense
#    - 1=aucun effet
#  - la taille du noyau
proc bm_filtre_max { args } {

   if { ( [llength $args] == 2 ) || ( [llength $args] == 3 ) } {
      set fichier [ lindex $args 0 ]
      set efficacite [ lindex $args 1 ]
      set taille_noyau 3
      if { [llength $args] == 3 } {set taille_noyau [lindex $args 2]}
      bm_filter max $fichier $efficacite $taille_noyau
   } else {
      ::console::affiche_erreur "Usage: bm_filtre_max filename \[efficiency 0.1 \[kernel size\]\]\n"
   }
}
#-----------------------------------------------------------------------------#

#*****************************************************************************#
#
# Description : Filtres de convolution gaussian, morlet, mexican
#
#*****************************************************************************#

proc bm_convo { args } {
   #--- arg : fichier efficacite
   #--- Arguments : efficacite = efficacite du filtre (0=intense, 1=aucun effet)
   #--- Les variables nommees audace_* sont globales
   global audace
   global conf
   global caption
   global traiteFilters

   if { [llength $args] == 3 } {
      set type_filtre [ lindex $args 0 ]
      set fichier [ lindex $args 1 ]
      set largeur [ lindex $args 2 ]

      if { ($fichier == "") || ($largeur == "")} {
         if { $type_filtre == "gaussian" } {
            ::console::affiche_erreur "Usage: bm_filtre_gauss filename \[width 0.5\]\n"
         } elseif { $type_filtre == "morlet" } {
            ::console::affiche_erreur "Usage: bm_ondelette_mor filename \[width 2\]\n"
         } elseif { $type_filtre == "mexican" } {
            ::console::affiche_erreur "Usage: bm_ondelette_mex filename \[width 2\]\n"
         }
      } else {
         if { $type_filtre == "gaussian" } {
            set filter "filtre_gaussien"
         } elseif { $type_filtre == "morlet" } {
            set filter "ond_morlet"
         } elseif { $type_filtre == "mexican" } {
            set filter "ond_mexicain"
         }
         #--- Verif existence
         set filein  "$fichier$conf(extension,defaut)"
         #--- Algo
         if { ( ![info exists audace(artifice)] ) || ( $fichier != "$audace(artifice)" ) } {
            if { [ file exist $filein ] == "1" } {
               ::console::affiche_resultat "$caption(filtrage,chargement) $fichier$conf(extension,defaut)\n\n"
               buf$audace(bufNo) load "$filein"
               if { [ lindex $args 2 ] == 0 } {
                  buf$audace(bufNo) imaseries "CONV kernel_type=$type_filtre"
               } else {
                  buf$audace(bufNo) imaseries "CONV kernel_type=$type_filtre sigma=$largeur"
               }
               ::audace::autovisu $audace(visuNo)
               set traiteFilters(avancement) $caption(filtrage,fin_traitement)
            } else {
               tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_de_fichier)
               set traiteFilters(avancement) ""
            }
         } else {
            if { [ buf[ ::confVisu::getBufNo $audace(visuNo) ] imageready ] == "0" } {
               tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_image_memoire)
               set traiteFilters(avancement) ""
            } else {
               if { [ lindex $args 2 ] == 0 } {
                  buf$audace(bufNo) imaseries "CONV kernel_type=$type_filtre"
               } else {
                  buf$audace(bufNo) imaseries "CONV kernel_type=$type_filtre sigma=$largeur"
               }
               ::audace::autovisu $audace(visuNo)
               set traiteFilters(avancement) $caption(filtrage,fin_traitement)
            }
         }
      }
   } else {
      ::console::affiche_erreur "Usage: bm_convo filter_type filename width\n"
   }
}
#-----------------------------------------------------------------------------#

proc bm_filtre_gauss { args } {
   #--- arg : fichier largeur
   #--- Arguments : largeur = largeur du filtre

   if { [llength $args] == 2 } {
      set fichier [ lindex $args 0 ]
      set largeur [ lindex $args 1 ]
      bm_convo gaussian $fichier $largeur
   } elseif { [llength $args] == 1 } {
      set fichier [ lindex $args 0 ]
      set largeur 0
      bm_convo gaussian $fichier $largeur
   } else {
      ::console::affiche_erreur "Usage: bm_filtre_gauss filename \[width 0.5\]\n"
   }
}
#-----------------------------------------------------------------------------#

proc bm_ondelette_mor { args } {
   #--- arg : fichier largeur
   #--- Arguments : largeur = largeur du filtre

   if { [llength $args] == 2 } {
      set fichier [ lindex $args 0 ]
      set largeur [ lindex $args 1 ]
      bm_convo morlet $fichier $largeur
   } elseif { [llength $args] == 1 } {
      set fichier [ lindex $args 0 ]
      set largeur 0
      bm_convo morlet $fichier $largeur
   } else {
      ::console::affiche_erreur "Usage: bm_ondelette_mor filename \[width 2\]\n"
   }
}
#-----------------------------------------------------------------------------#

proc bm_ondelette_mex { args } {
   #--- arg : fichier largeur
   #--- Arguments : largeur = largeur du filtre

   if { [llength $args] == 2 } {
      set fichier [ lindex $args 0 ]
      set largeur [ lindex $args 1 ]
      bm_convo mexican $fichier $largeur
   } elseif { [llength $args] == 1 } {
      set fichier [ lindex $args 0 ]
      set largeur 0
      bm_convo mexican $fichier $largeur
   } else {
      ::console::affiche_erreur "Usage: bm_ondelette_mex filename \[width 2\]\n"
   }
}
#-----------------------------------------------------------------------------#

#*****************************************************************************#
#
# Description : Logarithme d'une image avec des coefficients adaptes a une image
# brillante
# Evolution future : Fenetre avec reglage des coefficients a l'aide d'ascenseurs
#
#*****************************************************************************#

proc bm_logima { args } {
   #chaque pixel (intensit? p) prend la valeur coef*log10(p-offset).
   global audace
   global conf
   global caption
   global traiteFilters

   if { [llength $args] == 3 } {
      set fichier [ lindex $args 0 ]
      set mult [ lindex $args 1 ]
      set attenuation [ lindex $args 2 ]
      if { ($fichier == "") || ($mult == "") || ($attenuation == "") } {
         ::console::affiche_erreur "Usage: bm_logima mult attenuation\n"
      } else {
         #--- Verif existence
         set filein  "$fichier$conf(extension,defaut)"
         #--- Algo
         if { ( ![info exists audace(artifice)] ) || ( $fichier != "$audace(artifice)" ) } {
            if { [ file exist $filein ] == "1" } {
               ::console::affiche_resultat "$caption(filtrage,chargement) $fichier$conf(extension,defaut)\n\n"
               buf$audace(bufNo) load "$filein"
               set erreur [ catch { log $mult $attenuation } msg ]
               if { $erreur == "1" } {
                  ::console::affiche_erreur "$caption(filtrage,charge_image)\n"
               } else {
                  ::audace::autovisu $audace(visuNo)
                  set traiteFilters(avancement) $caption(filtrage,fin_traitement)
               }
            } else {
               tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_de_fichier)
               set traiteFilters(avancement) ""
            }
         } else {
            if { [ buf[ ::confVisu::getBufNo $audace(visuNo) ] imageready ] == "0" } {
               tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_image_memoire)
               set traiteFilters(avancement) ""
            } else {
               set erreur [ catch { log $mult $attenuation } msg ]
               if { $erreur == "1" } {
                  ::console::affiche_erreur "$caption(filtrage,charge_image)\n"
               } else {
                  ::audace::autovisu $audace(visuNo)
                  set traiteFilters(avancement) $caption(filtrage,fin_traitement)
               }
            }
         }
      }
   } else {
      ::console::affiche_erreur "Usage: bm_logima mult attenuation\n"
   }
}
#-----------------------------------------------------------------------------#

