#
## @file aud_proc.tcl
#  @brief Fonctions de chargement, sauvegarde et traitement d'images
#  @remarks Les fonctions qui suivent sont dans le namespace ::
#  Elles peuvent être exécutées directement dans la Console d'Aud'ACE.
#  $Id: aud_proc.tcl 13491 2016-03-25 14:49:22Z rzachantke $
#  @todo documentation à compléter

#------------------------------------------------------------------------------
##@brief charge une image dans une visu
# @param filename (facultatif)  valeur par défaut = ""
#   - nom du fichier contenant une image. Si le nom du fichier est relatif, le fichier est recherché dans
#     le répertoire audace(rep_image)
#   - ou si égal a "" pour effacer l'image et ne pas charger de fichier,
#   - ou si egal a "?" pour ouvrir une fenêtre de sélection et demander le nom du fichier à charger
# @param visuNo (facultatif) Numéro de la visu, valeur par défaut = 1
# @param affichage (facultatif)  valeur par défaut = -dovisu
#   - "-dovisu" l'image est chargée dans le buffer associé à la visu et elle est pas affichée dans la visu
#   - "-novisu" l'image est chargée dans le buffer associé à la visu, mais elle n'est pas affichée dans la visu
#      ( Voir @ref ::confVisu::autovisu pour afficher l'image plus tard)
#
# @return
# - nom du fichier si le chargement est OK
# - "" si le chargement n'est pas fait
#
# @code
# Exemples :
# #--- Ouvre une fenetre de selection, et affiche l'image dans la visu numero 1
# loadima
# #--- Ouvre une fenetre de selection, et affiche l'image dans la visu numero 1
# loadima ?
# #--- Charge l'image m57.fit (extension par defaut = fit) et affiche l'image dans la visu numero 1
# loadima m57
# #--- Charge l'image n4565.fits et affiche l'image dans la visu numero 1
# loadima n4565.fits
# #--- Charge l'image n4565.fits et affiche l'image dans la visu numero 2
# loadima n4565.fits 2
# #--- Charge l'image n4565.fits dans le buffer associe a la visu 1 sans afficher l'image
# loadima n4565.fits 1 -novisu
# @endcode
#
proc loadima { { filename "?" } { visuNo 1 } { affichage "-dovisu" } } {
   global audace conf

   #--- On capture le numero du buffer de la visu
   set bufNo [ visu$visuNo buf ]

   #--- Fixe le nom de l'extension par defaut des fichiers FITS
   buf$bufNo extension $conf(extension,defaut)

   #--- Recuperation de l'information de compression ou non
   if { $conf(fichier,compres) == "1" } {
      buf$bufNo compress gzip
   } else {
      buf$bufNo compress none
   }

   if { $filename != "" } {
      #--- Ouvre ou non l'interface graphique
      if { $filename == "?" } {
         #--- Fenetre parent
         set fenetre [::confVisu::getBase $visuNo]
         #--- Ouvre la fenetre de choix des images
         set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $bufNo "1" $visuNo ]
      } else {
         if {[file pathtype $filename] == "relative"} {
            set filename [file join $audace(rep_images) $filename]
         }
      }
      if { $filename != "" } {
         ::confVisu::autovisu $visuNo $affichage $filename
      }
   } else {
      #--- si le nom du fichier est une chaine vide, j'efface l'image
      ::confVisu::clear $visuNo
   }

   return ""
}

#
# saveima [filename] [visuNo]
# Sauvegarde d'une image
# [filename] : Sans argument ou egal a "?" comme nom de fichier, ouvre une fenetre de selection
# pour demander le nom de fichier, ou egal a un nom de fichier, si le nom du fichier est relatif,
# le fichier est enregistre dans le repertoire audace(rep_image), si le nom du fichier est absolu,
# il est enregistre dans le repertoire designe
# [visuNo] : Numero de la visu
#
# Exemples :
# saveima             #--- Ouvre une fenetre de selection
# saveima ?           #--- Ouvre une fenetre de selection
# saveima m57         #--- Enregistre l'image sous le nom m57.fit (extension par defaut)
# saveima n4565.fits  #--- Enregistre l'image sous le nom n4565.fits
#
proc saveima { { filename "?" } { visuNo 1 } } {
   global audace conf

   #--- On capture le numero du buffer de la visu
   set bufNo [ visu$visuNo buf ]

   #--- On sort immediatement s'il n'y a pas d'image dans le buffer
   if { [ buf$bufNo imageready ] == "0" } {
      return
   }

   #--- Fixe le nom de l'extension par defaut des fichiers FITS
   buf$bufNo extension $conf(extension,defaut)

   #--- Recuperation de l'information de compression ou non
   if { $conf(fichier,compres) == "1" } {
      buf$bufNo compress gzip
   } else {
      buf$bufNo compress none
   }

   #--- Sauvegarde des seuils dans les mots cles
   if { $conf(save_seuils_visu) == "1" } {
      #--- Pour une image couleur
      if { [ lindex [ buf$bufNo getkwd NAXIS ] 1 ] == "3" } {
         ::colorRGB::saveKWD $visuNo
      #--- Pour une image N&B
      } elseif { [ lindex [ buf$bufNo getkwd NAXIS ] 1 ] == "2" } {
         set mycuts [ visu$visuNo cut ]
         buf$bufNo setkwd [ list "MIPS-HI" [ lindex $mycuts 0 ] float "" "" ]
         buf$bufNo setkwd [ list "MIPS-LO" [ lindex $mycuts 1 ] float "" "" ]
      }
   }

   #--- Fenetre parent
   set fenetre [::confVisu::getBase $visuNo]

   #--- Ouvre ou non l'interface graphique
   if { $filename == "?" } {
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_save $fenetre $audace(rep_images) $bufNo "1" $visuNo ]
   } else {
      if { [ file pathtype $filename ] == "relative" } {
         set filename [ file join $audace(rep_images) $filename ]
      }
   }

   #--- Sauvegarde de l'image
   if { [ string compare $filename "" ] != "0" } {
      if { [ file extension $filename ] == ".jpg" || [ file extension $filename ] == ".jpeg" } {
         set quality $conf(jpegquality,defaut)
         set err [ catch { set quality [ expr $quality ] } ]
         if { $err == "1" } {
            set quality 80
         }
         #--- j'ajoute l'option -quality pour les images jpg
         buf$bufNo save $filename -quality $quality
      } else {
         #--- pas d'option pour les autres types d'images
         buf$bufNo save $filename
      }
   }

   return
}

#
# savejpeg [filename]
# Sauvegarde d'une image
# [filename] : Sans argument ou egal a "?" comme nom de fichier, ouvre une fenetre de selection
# pour demander le nom de fichier, ou egal a un nom de fichier, si le nom du fichier est relatif,
# le fichier est enregistre dans le repertoire audace(rep_image), si le nom du fichier est absolu,
# il est enregistre dans le repertoire designe
#
# Exemples :
# savejpeg             #--- Ouvre une fenetre de selection
# savejpeg ?           #--- Ouvre une fenetre de selection
# savejpeg m57         #--- Enregistre l'image sous le nom m57.jpg
#
proc savejpeg { { filename "?" } { visuNo 1 } } {
   global audace conf

   #--- On capture le numero du buffer de la visu
   set bufNo [ visu$visuNo buf ]

   #--- On sort immediatement s'il n'y a pas d'image dans le buffer
   if { [ buf$bufNo imageready ] == "0" } {
      return
   }

   #--- Sauvegarde des seuils dans les mots cles
   if { $conf(save_seuils_visu) == "1" } {
      #--- Pour une image couleur
      if { [ lindex [ buf$bufNo getkwd NAXIS ] 1 ] == "3" } {
         ::colorRGB::saveKWD $visuNo
      #--- Pour une image N&B
      } elseif { [ lindex [ buf$bufNo getkwd NAXIS ] 1 ] == "2" } {
         set mycuts [ visu$visuNo cut ]
         buf$bufNo setkwd [ list "MIPS-HI" [ lindex $mycuts 0 ] float "" "" ]
         buf$bufNo setkwd [ list "MIPS-LO" [ lindex $mycuts 1 ] float "" "" ]
      }
   }

   #--- Fenetre parent
   set fenetre "$audace(base)"

   #--- Ouvre ou non l'interface graphique
   if { $filename == "?" } {
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_save $fenetre $audace(rep_images) $bufNo "2" $visuNo ]
   } else {
      if { [ file pathtype $filename ] == "relative" } {
          set filename [ file join $audace(rep_images) $filename ]
      }
   }
   set filename "[ file rootname $filename ].jpg"

   #--- Sauvegarde de l'image
   if { [ string compare $filename "" ] != 0 } {
      set quality $conf(jpegquality,defaut)
      set err [ catch { set quality [ expr $quality ] } ]
      if { $err == "1" } {
         set quality 80
      }
     ### buf$bufNo savejpeg $filename $quality
      buf$bufNo save $filename -quality $quality
   }

   return
}

#
# visu [cuts]
# Visualisation du buffer : Eventuellement on peut changer les seuils en passant
# une liste de deux elements entiers par plan image, le seuil haut et le seuil bas
# liste de 2 elements pour une image naxis 2 et de 6 elements pour une image naxis 3
#
# Exemple :
# visu
# visu {500 0}
#
proc visu { { cuts "autocuts" } } {
   global audace

   ::confVisu::visu $audace(visuNo) $cuts
}

## @brief retorune une liste des statistiques de l'image :
#  dans l'ordre : hicut, locut, datamax, datamin, mean, sigma, bgmean, bgsigma et contrast
#
proc stat { } {
   global audace

   buf$audace(bufNo) stat
}


## @brief réalise un offset sur l'image, tous les pixels de l'image sont decalés de la valeur de args
#  @param args valeur de l'offset
#
proc offset { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) offset [lindex $args 0]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: offset value"
   }
}

## @brief multiplie tous les pixels de l'image en mémoire une valeur
#  @param args coefficient multiplicateur
#
proc mult { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) mult [lindex $args 0]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: mult value"
   }
}

## @brief normalise le fond du ciel par un offset
#  @param args valeur de normalisation
#
proc noffset { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) noffset [lindex $args 0]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: noffset value"
   }
}

# ngain value
# Normalise le fond du ciel a la valeur value
#
proc ngain { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) ngain [lindex $args 0]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: ngain value"
   }
}

## @brief ajoute l'image contenue dans fichier à l'image du buffer et ajoute un offset
#  @param args liste de :
#  -# chemin de l'image
#  -# valeur de l'offset
#
proc add { args } {
   global audace

   if {[llength $args] == 2} {
      buf$audace(bufNo) add [lindex $args 0] [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: add image value"
   }
}

## @brief soustrait une image contenue dans fichier à l'image du buffer et ajoute un offset
#  @param args liste de :
#  -# chemin de l'image
#  -# valeur de l'offset
#
proc sub { args } {
   global audace

   if {[llength $args] == 2} {
      buf$audace(bufNo) sub [lindex $args 0] [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: sub image value"
   }
}

#
# div image value
# Divise l'image courante par l'image contenue dans le fichier nom,
# et multiplie par la constante numerique value
#
proc div { args } {
   global audace

   if {[llength $args] == 2} {
      buf$audace(bufNo) div [lindex $args 0] [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: div image value"
   }
}

#
# opt dark offset
# Optimise le noir sur le buffer
#
proc opt { args } {
   global audace

   if {[llength $args] == 2} {
      buf$audace(bufNo) opt [lindex $args 0] [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: opt dark offset"
   }
}

#
# deconvflat coef
# Retire l'effet de smearing d'une image
# Le coefficient coef correspond au rapport du temps de lecture d'une
# ligne par rapport a l'image entiere
#
proc deconvflat { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) unsmear [lindex $args 0]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: deconvflat coef"
   }
}

#
## @brief tourne l'image autour du centre (x0,y0) d'un angle
#  @param args liste de  :
#  -# x0 abscisse du centre de rotation
#  -# y0 ordonnée du centre de rotation
#  -# angle de rotation en degrés décimaux
#
proc rot { args } {
   global audace

   if {[llength $args] == 3} {
      buf$audace(bufNo) rot [lindex $args 0] [lindex $args 1] [lindex $args 2]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: rot x0 y0 angle"
   }
}

#
# log coef [offset]
# Applique une transformation logarithmique a l'image
#
proc log { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) log [lindex $args 0]
      ::audace::autovisu $audace(visuNo)
   } elseif {[llength $args] == 2} {
      buf$audace(bufNo) log [lindex $args 0] [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: log coef ?offset?"
   }
}

## @brief créé une nouvelle image de dimensions width*NAXIS2 dont toutes les colonnes sont identiques
# et égales à la somme de toutes les colonnes comprises entre les abscisses x1 et x2 de l'image
#
proc binx { args } {
   global audace

   if {[llength $args] == 2} {
      buf$audace(bufNo) binx [lindex $args 0] [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } elseif {[llength $args] == 3} {
      buf$audace(bufNo) binx [lindex $args 0] [lindex $args 1] [lindex $args 2]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: binx x1 x2 ?width?"
   }
}

## @brief créé une nouvelle image de dimensions height*NAXIS1 dont toutes les lignes sont identiques
# et égales à la somme de toutes les lignes comprises entre les ordonnees y1 et y2 de l'image
#
proc biny { args } {
   global audace

   if {[llength $args] == 2} {
      buf$audace(bufNo) biny [lindex $args 0] [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } elseif {[llength $args] == 3} {
      buf$audace(bufNo) biny [lindex $args 0] [lindex $args 1] [lindex $args 2]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: biny y1 y2 ?height?"
   }
}

## @brief extrait une sous-image de l'image du buffer
#  @param args liste de quatre valeurs numériques indiquant les coordonnées
#  de deux des coins opposés : [list $x1 $y1 $x2 $y2]
#
proc window { { args "" } } {
   global audace caption

   if { [ lindex [ list [ ::confVisu::getBox $audace(visuNo) ] ] 0 ] != "" } {
      if {$args == ""} {
         set args [ list [ ::confVisu::getBox $audace(visuNo) ] ]
      }
      if {[llength $args] == 1} {
         buf$audace(bufNo) window [lindex $args 0]
         ::confVisu::deleteBox $audace(visuNo)
         ::audace::autovisu $audace(visuNo)
      } else {
         error "Usage: window {x1 y1 x2 y2}"
      }
   } else {
      tk_messageBox -title $caption(confVisu,attention) -type ok -message $caption(confVisu,tracer_boite)
   }
}

## @brief remplace toutes les valeurs inférieures à args par sa veleur
#  @param args valeur du seuil
#
proc clipmin { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) clipmin [lindex $args 0]
      ::confVisu::deleteBox $audace(visuNo)
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: clipmin value"
   }
}

## @brief remplace toutes les valeurs supérieures à args par sa valeur (écrêtage)
#  @param args valeur d'écrêtage
#
proc clipmax { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) clipmax [lindex $args 0]
      ::confVisu::deleteBox $audace(visuNo)
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: clipmax value"
   }
}

# resample Factor_x Factor_y [NormaFlux]
# Reechantillonne (bilineaire) l'image en tenant compte de facteurs d'echelle sur chaque axe
#
proc resample { args } {
   global audace

   if {[llength $args] >= 1} {
      if {[llength $args] >= 2} {
         buf$audace(bufNo) scale [ list [lindex $args 0] [lindex $args 1] ]
      } else {
         buf$audace(bufNo) scale [lindex $args 0] 1
      }
      ::confVisu::deleteBox $audace(visuNo)
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: resample Factor_x Factor_y ?NormaFlux?"
   }
}

## @brief retourne l'image par un effet de miroir horizontal
#
proc mirrorx { args } {
   global audace

   if {[llength $args] == 0} {
      buf$audace(bufNo) mirrorx
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: mirrorx"
   }
}

## @brief retourne l'image par un effet de miroir vertical
#
proc mirrory { args } {
   global audace

   if {[llength $args] == 0} {
      buf$audace(bufNo) mirrory
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: mirrory"
   }
}

## @brief supprime les fichiers de "$in1" à "$in$nb"
#  @code Exemple :
#  delete2 i 3 --> Supprime les fichiers i1.fit, i2.fit et i3.fit
#  @endcode
#  @param args : liste de la racine du nom du fichier et de l'index de la dernière image à supprimer
#
proc delete2 { args } {
   global audace conf

   #--- Fixe le nom de l'extension par defaut des fichiers FITS
   buf$audace(bufNo) extension $conf(extension,defaut)
   set ext $conf(extension,defaut)

   if {[llength $args] == 2} {
      set in [lindex $args 0]
      set nb [lindex $args 1]
      for {set i 1} {$i <= $nb} {incr i} {file delete -force $in$i$ext}
   } else {
      error "Usage: delete2 in nb"
   }
}

# extract_flat in dark offset out nb
# Calcule un flat directement a partir des images de la nuit
# Il est necessaire d'avoir un offset et un noir
#
# Exemple :
# extract_flat sky dark offset flat 5
# Extrait une image flat.fit des 5 images sky1.fit to sky5.fit en utilisant
# un noir dark.fit et un offset off.fit
# Temporairement les fichiers flat-tmp-1.fit a flat-tmp-5.fit sont crees puis supprimes
#
proc extract_flat { args } {
   if {[llength $args] == 5} {
      set in [lindex $args 0]
      set dark [lindex $args 1]
      set offset [lindex $args 2]
      set out [lindex $args 3]
      set nb [lindex $args 4]
      #---
      set tmp "$out-tmp-"; #--- Temporary files prototype
      opt2 $in $dark $offset $tmp $nb
      ngain2 $tmp $tmp 10000 $nb
      smedian $tmp $out $nb
      delete2 $tmp $nb
   } else {
      error "Usage: extract_flat in dark offset out nb"
   }
}

## @brief renvoie la date courante au format FITS
#
proc fitsdate { args } {
   if {[llength $args] == 0} {
      clock format [clock seconds] -format "%Y-%m-%dT%H:%M:%S.00"
   } else {
      error "Usage: fitsdate"
   }
}

## @brief liste le contenu d'un répertoire, comme la commande DOS DIR
#  @details pour lister les images du sous repertoire nuit, il faut utiliser la commande "dir nuit/*.fit"
#  @param rgxp * par défaut
#
proc dir { { rgxp "*" } } {

   set res [glob $rgxp]
   set maxlen 0
   foreach elem $res {
      if {[string length $elem]>$maxlen} {
         set maxlen [string length $elem]
      }
   }
   foreach elem $res {
      if {[file isdirectory $elem]} {
         set comment "<DIR>"
      } else {
         set comment "([file size $elem])"
      }
      ::console::affiche_resultat [format "%-[subst $maxlen]s  %s\n" $elem $comment]
   }
}

## @brief créé une animation d'images
#  @param filename      : nom générique des fichiers image filename*.fit à animer
#  @param nb            : nombre d'images (1 a nb)
#  @param millisecondes : délai entre chaque image affichée, 200 ms par défaut
#  @param nbtours       : nombre de boucles sur les nb images, 10 par défaut
#  @param liste_index   : liste des index des nb images
#
proc animate { filename nb {millisecondes 200} {nbtours 10} {liste_index ""} } {
   global audace

   #--- Repertoire des images
   set len [ string length $audace(rep_images) ]
   set folder "$audace(rep_images)"

   #--- Je sauvegarde le canvas
   set basecanvas $audace(base).can1.canvas

   #--- Je sauvegarde le numero de l'image associe a la visu
   set imageNo [visu$audace(visuNo) image]

   #--- Initialisation des visu
   set off 100

   #--- Creation de nb visu a partir de la visu numero 101 (100 + 1) et des Tk_photoimage
   for {set k 1} {$k<=$nb} {incr k} {
      set index [ lindex $liste_index [ expr $k - 1 ] ]
      set kk [expr $k+$off]
      #--- Creation de l'image et association a la visu
      visu$audace(visuNo) image $kk
      #--- Affichage de l'image avec gestion des erreurs
      set error [ catch { buf$audace(bufNo) load [ file join $folder $filename$index ] } msg ]
      ::audace::autovisu $audace(visuNo)
   }

   #--- Animation
   if { $error == "0" } {
      for {set t 1} {$t<=$nbtours} {incr t} {
         for {set k 1} {$k<=$nb} {incr k} {
            set kk [expr $k+$off]
            $basecanvas itemconfigure display -image imagevisu$kk
            #--- Chargement de l'image associee a la visu
            visu$audace(visuNo) image $kk
            update
            after $millisecondes
         }
      }
   }

   #--- Destruction des Tk_photoimage
   for {set k 1} {$k<=$nb} {incr k} {
      set kk [expr $k+$off]
      image delete imagevisu$kk
   }

   #--- Reconfiguration pour Aud'ACE normal
   $basecanvas itemconfigure display -image imagevisu$imageNo
   update

   #--- Restauration du numero de l'image associe a la visu
   visu$audace(visuNo) image $imageNo

   #--- Affichage de la premiere image de l'animation si elle existe
   if { $error == "0" } {
      set index1 [ lindex $liste_index 0 ]
      buf$audace(bufNo) load [ file join $folder ${filename}$index1 ]
      ::audace::autovisu $audace(visuNo)
   }

   #--- Variable error pour la gestion des erreurs
   return $error
}

## @brief ping qui fonctionne aussi avec Linux non root
#  @param ip adresse IP à tester
#
proc audace_ping { ip } {
   global caption

   set res ""
   if { $::tcl_platform(os) == "Windows NT" } {
      set res [ping $ip]
   } else {
      set user [exec whoami]
      if {$user=="root"} {
         set res [ping $ip]
      } else {
         set err [ catch {exec ping $ip -c 1 -W 1} msg ]
         if {$err==0} {
            lappend res 1
            lappend res "$caption(ping,appareil_connecte) $ip"
         } else {
            lappend res 0
            lappend res "$caption(ping,pas_appareil_connecte) $ip"
         }
      }
   }
   return $res
}

