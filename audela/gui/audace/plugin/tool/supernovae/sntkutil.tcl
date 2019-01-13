#
# Fichier : sntkutil.tcl
# Description : Utilitaires pour la recherche de supernovae
# Auteur : Alain KLOTZ
# Mise à jour $Id: sntkutil.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

#--- Conventions pour ce script :
#--- Les indices 1 se rapportent a l'image de gauche
#--- Les indices 2 se rapportent a l'image de droite

#
# Scrolled_Canvas
# Cree un canvas scrollable, ainsi que les deux scrollbars pour le deplacer
# Ref: Brent Welsh, Practical Programming in TCL/TK, rev.2, page 392
#
proc snScrolledCanvas { c yscroll args } {
   frame $c
   if { $yscroll == "right" } {
      set grille { 0 0 0 1 1 0 }
   } elseif { $yscroll == "left" } {
      set grille { 0 1 0 0 1 1 }
   }
   eval { canvas $c.canvas \
      -xscrollcommand [ list $c.xscroll set ] \
      -yscrollcommand [ list $c.yscroll set ] \
      } $args
   scrollbar $c.xscroll -orient horizontal -command [ list $c.canvas xview ]
   scrollbar $c.yscroll -orient vertical -command [ list $c.canvas yview ]
   grid $c.canvas  -column [ lindex $grille 1 ] -row [ lindex $grille 0 ] -sticky news
   grid $c.yscroll -column [ lindex $grille 3 ] -row [ lindex $grille 2 ] -sticky news
   grid $c.xscroll -column [ lindex $grille 5 ] -row [ lindex $grille 4 ] -sticky ew
   grid rowconfigure $c 0 -weight 1
   grid columnconfigure $c 0 -weight 1
   return $c.canvas
}

#
# Transforme des coordonnees ecran en coordonnees canvas. L'argument est une liste de
# deux entiers, et retourne egalement une liste de deux entiers. Pour l'image de gauche
#
proc snScreen2Canvas1 { coord } {
   global zone

   set x [ $zone(image1) canvasx [ lindex $coord 0 ] ]
   set y [ $zone(image1) canvasy [ lindex $coord 1 ] ]
   return [ list $x $y ]
}

#
# Transforme des coordonnees ecran en coordonnees canvas. L'argument est une liste de
# deux entiers, et retourne egalement une liste de deux entiers. Pour l'image de droite
#
proc snScreen2Canvas2 { coord } {
   global zone

   set x [ $zone(image2) canvasx [ lindex $coord 0 ] ]
   set y [ $zone(image2) canvasy [ lindex $coord 1 ] ]
   return [ list $x $y ]
}

#
# Transforme des coordonnees canvas en coordonnees image. L'argument est une liste de
# deux entiers, et retourne egalement une liste de deux entiers. Pour l'image de gauche
#
proc snCanvas2Picture1 { coord } {
   global zone

   set xx [ expr [ lindex $coord 0 ] + 1 ]
   set point [ string first . $xx ]
   if { $point != "-1" } {
      set xx [ string range $xx 0 [ incr point -1 ] ]
   }
   set yy 0
   catch {
      set yy [ expr $zone(naxis2) - [ lindex $coord 1 ] ]
   }
   set point [ string first . $yy ]
   if { $point != "-1" } {
      set yy [ string range $yy 0 [ incr point -1 ] ]
   }
   return [ list $xx $yy ]
}

#
# Transforme des coordonnees canvas en coordonnees image. L'argument est une liste de
# deux entiers, et retourne egalement une liste de deux entiers. Pour l'image de droite
#
proc snCanvas2Picture2 { coord } {
   global zone

   set xx [ expr [ lindex $coord 0 ] + 1 ]
   set point [ string first . $xx ]
   if { $point != "-1" } {
      set xx [ string range $xx 0 [ incr point -1 ] ]
   }
   set yy 0
   catch {
      set yy [ expr $zone(naxis2_2) - [ lindex $coord 1 ] ]
   }
   set point [ string first . $yy ]
   if { $point != "-1" } {
      set yy [ string range $yy 0 [ incr point -1 ] ]
   }
   return [ list $xx $yy ]
}

#
# Lancement de la recherche du fichier image au format .cpa sur le DVD
#
proc searchFileDVD { filename } {
   global snconfvisu

   #--- Recherche du fichier image
   if { ( $snconfvisu(rep_dss_dvd) != "" ) && ( $filename != "" ) } {
      set repertoire [ ::audace::fichier_partPresent "$filename" "$snconfvisu(rep_dss_dvd)" ]
      set repertoire [ glob -nocomplain -type f -dir "$repertoire" "$filename" ]
      set repertoire [ string trimleft $repertoire "{" ]
      set repertoire [ string trimright $repertoire "}" ]
      if { $repertoire != "." } {
         set snconfvisu(binarypath) $repertoire
      } else {
         set snconfvisu(binarypath) ""
      }
   }
   return
}

#
# Convertion et affichage d'une image .cpa en .fit
#
proc snLoadimaNofits { { fichier } { rep } } {
   global num

   #--- Creation du repertoire temporaire
   set rep_tmp [cree_sousrep]
   #--- Copie de l'image dans le repertoire temporaire
   file copy [ file join $rep $fichier ] [ file join $rep_tmp $fichier ]
   #--- Conversion de l'image au format FITS
   bifsconv_full [ file join $rep_tmp $fichier ]
   set fichierfits [ file join $rep_tmp [ file rootname $fichier ].fit ]
   #--- Chargement de l'image
   buf$num(buffer2) load $fichierfits
   #--- Visualisation automatique
   visu$num(visu2) disp
   #--- Suppression de l'image copiee
   file delete [ file join $rep_tmp $fichier ]
   #--- Suppression de l'image FITS temporaire
   file delete $fichierfits
   #--- Suppression du repertoire temporaire
   file delete $rep_tmp
}

