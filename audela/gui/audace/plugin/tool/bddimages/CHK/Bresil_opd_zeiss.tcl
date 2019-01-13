##################################################################################################
# Telelescope du l ' Observatoire du Pico dos Dias Itajuba Brésil pour la 
# Camera IKON-L
##################################################################################################


##################################################################################################
# procedure de la derniere Chance !
# Elle permet de modifier les clés des headers en se basant sur le nom de l image.
# tres dangeureuse car modifie les images brutes
# cela est contraire a la philo de bddimages qui cherche a conserver les images brutes
#
# lancer dans la console le source suivant :
#
#  >  source [ file join $audace(rep_plugin) tool bddimages CHK Bresil_opd_zeiss.tcl]
#
##################################################################################################



   source [ file join $audace(rep_plugin) tool bddimages CHK modif_img_header.tcl]

   set path "/media/BLACK/astrodata/Observations/bddimages_black/tmp/12set18"
   set dest "/media/BLACK/astrodata/Observations/bddimages_black/tmp/CHK"

   ::console::affiche_resultat "Rep travail = $path\n"

   modif_img_header   "flat"          "FLAT"            $path $dest
   modif_img_header   "dark"          "DARK"            $path $dest
   modif_img_header   "bias"          "OFFSET"          $path $dest
   modif_img_header   "atroclus"      "617_Patroclus"   $path $dest
   modif_img_header   "2001QD94"      "2001QD94"      $path $dest

   return







