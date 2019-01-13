# ==========================================================================================
#--- cree les variables globales
# ==========================================================================================
global ros

source ../common/variables_globales.tcl

# --- Definition des intitulés pour l'interface graphique
if {$ros(common,langage)=="fr"} {
	set caption(main_title) "SSP : Robotic Observatory Software"
	set caption(stop) "Suspendre"
	set caption(cont) "Reprendre"
	set caption(exit) "Tuer SSP"
	set caption(fichiers_d_entree) "fichiers d'entree"
} else {
	set caption(main_title) "SSP : Robotic Observatory Software"
	set caption(stop) "Stop"
	set caption(cont) "Continue"
	set caption(exit) "Kill SSP"
	set caption(fichiers_d_entree) "input files"
}

# --- Definition des couleurs de l'interface graphique
set color(back) #67c686
set color(backlist) #fbc77d
set color(forelist) #1840b1

# --- Definition des commentaires a paraitre au cours des traitements
if {$ros(common,langage)=="fr"} {
	set ros(caption,title,1) "                      SSP\n"
	set ros(caption,title,2) "            Robotic Observatory Software"
	set ros(caption,title,3) "             Tri des images et des cata \n"
	set ros(caption,stop) "SSP est suspendu"
	set ros(caption,cont) "SSP reprend le travail"
	set ros(caption,exit) "SSP est tué"
	set ros(caption,traite_une_copie) "Commence une copie"
	set ros(caption,pas_d_image) "Pas de fichier catalogue"
	#
	set ros(caption,traite_une_image_normale) "Traite"
	set ros(caption,image_traitee_sans_probleme) "Fichier traité sans probleme"
	#
	set ros(caption,sortie_de_la_grenouille) "Sortie de SSP"
	set ros(caption,rien_a_traiter) "Pas de connexion a analyser"
} else {
	set ros(caption,title,1) "                      SSP\n"
	set ros(caption,title,2) "            Robotic Observatory Software"
	set ros(caption,title,3) "              Distribution of requests \n"
	set ros(caption,stop) "SSP is stopped"
	set ros(caption,cont) "SSP start again"
	set ros(caption,exit) "SSP is killed"
	set ros(caption,traite_une_copie) "Commence une copie"
	set ros(caption,pas_d_image) "Pas de fichier catalogue"
	#
	set ros(caption,traite_une_image_normale) "Traite"
	set ros(caption,image_traitee_sans_probleme) "Fichier traité sans probleme"
	#
	set ros(caption,sortie_de_la_grenouille) "Exit of SSP"
	set ros(caption,rien_a_traiter) "No connection to analyze"
}

