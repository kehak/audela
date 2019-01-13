#
# Fichier : correctionfc.tcl
# Description : Fonction pour nettoyer mes images (portions de lignes verticales mauvaises)
# Auteur : Francois COCHARD
# Mise à jour $Id: correctionfc.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

proc corrigefc { } {
#--- Cette procedure est utilisee par l'outil Pretraitement pour faire une correction cosmetique
global audace

#--- Je dois regarder quel est le type et la taille de l'image
set NAXIS    [ lindex [ buf$audace(bufNo) getkwd NAXIS ] 1 ]
set taille_X [ lindex [ buf$audace(bufNo) getkwd NAXIS1 ] 1 ]
set taille_Y [ lindex [ buf$audace(bufNo) getkwd NAXIS2 ] 1 ]

#--- Type d'image : N&B ou Couleur
if { $NAXIS == "2" } {
   tk_messageBox -title "Type d'image" -type ok -message "C'est une image Noir & Blanc."
} elseif { $NAXIS == "3" } {
   tk_messageBox -title "Type d'image" -type ok -message "Correction cosmétique impossible : C'est une image Couleur."
   return
}

#--- On ne traite que les cas des binning 1x1 et 2x2
set bin "0"
if { $taille_X == "384" && $taille_Y == "256" } {
   set bin 2
   tk_messageBox -title "Recherche du binning" -type ok -message "On est en binning 2x2."
} elseif { $taille_X == "768" && $taille_Y == "512" } {
   set bin 1
   tk_messageBox -title "Recherche du binning" -type ok -message "On est en binning 1x1."
}
if { $bin == "0" } {
   tk_messageBox -title "Attention" -type ok -message "Correction cosmétique impossible : Format inconnu.\n"
   return
}

# Il y a trois defauts a corriger sur mon Kaf-0400
# Valable uniquement si les images sont faites avec AudeLA et sans aucun miroir
# La colonne de gauche (bin 1 : X=97, y=231 à 512 - bin2 : X=50, y=116 à 256)
# La colonne du milieu (bin 1 : X=310, y=453 à 512 - bin2 : X=156, y=227 à 256)
# La colonne de droite (bin 1 : X=480, y=387 à 512 - bin2 : X=241, y=193 à 256)

#--- Image en binning 1x1
if { $bin == "1" } {
   #--- Correction colonne gauche
   for {set y 231} {$y <= 512} {incr y} {
      set pixel_droit  [ lindex [ buf$audace(bufNo) getpix [ list 98 $y ] ] 1 ]
      set pixel_gauche [ lindex [ buf$audace(bufNo) getpix [ list 96 $y ] ] 1 ]
      buf$audace(bufNo) setpix [ list 97 $y ] [ expr ($pixel_droit + $pixel_gauche) / 2 ]
   }
   #--- Correction colonne milieu
   for {set y 453} {$y <= 512} {incr y} {
      set pixel_droit  [ lindex [ buf$audace(bufNo) getpix [ list 311 $y ] ] 1 ]
      set pixel_gauche [ lindex [ buf$audace(bufNo) getpix [ list 309 $y ] ] 1 ]
      buf$audace(bufNo) setpix [ list 310 $y ] [ expr ($pixel_droit + $pixel_gauche) / 2 ]
   }
   #--- Correction colonne droite
   for {set y 387} {$y <= 512} {incr y} {
      set pixel_droit  [ lindex [ buf$audace(bufNo) getpix [ list 481 $y ] ] 1 ]
      set pixel_gauche [ lindex [ buf$audace(bufNo) getpix [ list 479 $y ] ] 1 ]
      buf$audace(bufNo) setpix [ list 480 $y ] [ expr ($pixel_droit + $pixel_gauche) / 2 ]
   }
   #--- Correction terminee
   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "Correction cosmétique terminée. \n"
   ::console::affiche_resultat "\n"
#--- Image en binning 2x2
} elseif { $bin == "2" } {
   #--- Correction colonne gauche
   for {set y 116} {$y <= 256} {incr y} {
      set pixel_droit  [ lindex [ buf$audace(bufNo) getpix [list 51 $y] ] 1 ]
      set pixel_gauche [ lindex [ buf$audace(bufNo) getpix [list 49 $y] ] 1 ]
      buf$audace(bufNo) setpix [ list 50 $y ] [ expr ($pixel_droit + $pixel_gauche) / 2 ]
   }
   #--- Correction colonne milieu
   for {set y 227} {$y <= 256} {incr y} {
      set pixel_droit  [ lindex [ buf$audace(bufNo) getpix [ list 157 $y ] ] 1 ]
      set pixel_gauche [ lindex [ buf$audace(bufNo) getpix [ list 155 $y ] ] 1 ]
      buf$audace(bufNo) setpix [ list 156 $y ] [ expr ($pixel_droit + $pixel_gauche) / 2 ]
   }
   #--- Correction colonne droite
   for {set y 193} {$y <= 256} {incr y} {
      set pixel_droit  [ lindex [ buf$audace(bufNo) getpix [ list 242 $y ] ] 1 ]
      set pixel_gauche [ lindex [ buf$audace(bufNo) getpix [ list 240 $y ] ] 1 ]
      buf$audace(bufNo) setpix [ list 241 $y ] [ expr ($pixel_droit + $pixel_gauche) / 2 ]
   }
   #--- Correction terminee
   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "Correction cosmétique terminée. \n"
   ::console::affiche_resultat "\n"
}

#--- Affichage du resultat
::audace::autovisu $audace(visuNo)

}

