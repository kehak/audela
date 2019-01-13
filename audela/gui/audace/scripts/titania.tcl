#
# Fichier : titania.tcl
# Description : Occultation de HD205829 par Titania (satellite d'Uranus) le 08 septembre 2001 a 2h TU environ
# Observation en automatique
# Camera : Script optimise pour une Audine Kaf-0400 pilotee par un port parallele
# Auteur : Alain KLOTZ
# Mise à jour $Id: titania.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

global audace

#--- Initialisation de la date
set debut now

#--- Attention heure en TU --> Ordinateur cale sur l'heure TU
set debut 2001-09-08T01:49:30

#--- Largeur du scan (en pixels)
set w 190

#--- Longueur du scan (en pixels)
set h 4500

#--- Binning 1x1 (1 en X et 1 en Y)
set binx 1
set biny 1

#--- Temps d'integration interligne (en ms) apres les calibrations avec l'outil Scan rapide
set dt 200.

#--- Indice du premier photosite de la largeur de l'image
set firstpix 270 ; #--- Valeur a adapter en temps reel

#--- Nombre de boucles apres les calibrations avec l'outil Scan rapide
set speed 20429

#--- Attente du debut de l'observation
set datejd [mc_date2jd $debut]
while {[mc_date2jd now]<$datejd} {
   after 1000
   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "Attente du début de l'observation.\n"
   ::console::affiche_resultat "Il est actuellement : [mc_date2ymdhms now] \n"
}
set name [mc_date2ymdhms now]
set name [format "%04d%02d%02d%02d%02d" [lindex $name 0] [lindex $name 1] [lindex $name 2] [lindex $name 3] [lindex $name 4]]

::console::affiche_resultat "\n"
::console::affiche_resultat "Scan en cours...\n"

#--- Acquisition du scan et gestion de l'obturateur
catch {cam$audace(camNo) shutter opened}
cam$audace(camNo) scan $w $h $binx $dt -biny $biny -firstpix $firstpix -fast $speed -tmpfile
bell
catch {cam$audace(camNo) shutter synchro}

#--- Visualisation de l'image
::audace::autovisu $audace(visuNo)

#--- Enregistrement du fichier FITS
buf$audace(bufNo) save "titania_$name"
buf$audace(bufNo) save "i0_$name"
::console::affiche_resultat "\n"
::console::affiche_resultat "Scan terminé.\n"
::console::affiche_resultat "\n"

#--- Fin du fichier script

