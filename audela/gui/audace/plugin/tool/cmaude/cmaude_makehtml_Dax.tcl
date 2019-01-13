#
## @file cmaude_makehtml_Dax.tcl
#  @brief Ecrit une page HTML au fur et à mesure de la nuit, où sont disponibles les images JPG et FITS pour l'observatoire de Dax
#  @author Sylvain RONDI
#  @details Spécial DAX mis à jour par F. LOSSE Janvier 2012
#  $Id: cmaude_makehtml_Dax.tcl 13597 2016-04-03 19:52:12Z robertdelmas $
#

variable cmconf

#--- Initialisation de l'heure TU ou TL
set now [::audace::date_sys2ut now]
#--- Acquisition of an image
set actuel [mc_date2jd $now]
#---
set folder [ file join $::audace(rep_images) ]
set namehtml [string range [mc_date2iso8601 $actuel] 0 9].html
::console::affiche_erreur "\n"
::console::affiche_erreur "$::caption(cmaude,fichier_html) $namehtml\n"
::console::affiche_erreur "\n\n"

set existence [ file exists [ file join $folder $namehtml ] ]
if { $existence == "0" } {
   #--- Here is made the html page header
   set texte "<!doctype html public \"-//w3c//dtd html 4.0 transitional//en\">\n"
   append texte "<html>\n"
   append texte "<head>\n"
   append texte "   <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n"
   append texte "   <meta name=\"GENERATOR\" content=\"AudeLA\">\n"
   append texte "   <meta name=\"Author\" content=\"S. Rondi\">\n"
   append texte "   <title>Images MASCOT - [string range [mc_date2iso8601 $actuel] 0 9]</title>\n"
   append texte "</head>\n"
   append texte "<body bgcolor=\"#000000\" background=\"astrofon.gif\" > <font color=\"#FFFFFF\">  \n"
   append texte "<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" align=\"center\"> \n"
   append texte "<tr valign=\"top\"><td rowspan=\"2\" align=\"left\"> <img align=\"top\" "
   append texte " src=\"daxlogo.gif\" > </td> \n"
   append texte "<td align=\"right\"><h1><font color=\"#FFFFFF\">Images MASCOT</font></h1></td></tr></table> "
   append texte "<hr size=\"1\" noshade>\n"
   append texte "<h2><center>\n"
   append texte "Nuit du [string range [mc_date2iso8601 $actuel] 0 9]<br>\n"
   append texte "Jour Julien [string range [mc_date2jd now] 0 6]</h2></center>\n"
   append texte "<h2>\n"
   append texte "1. Instrument MASCOT</h2>\n"
   append texte "<b>MASCOT</b> signifie <b>M</b>ini <b>A</b>ll-<b>S</b>ky <b>C</b>loud <b>O</b>bservation <b>T</b>ool. <br>"
   append texte "Son objectif est de faire chaque nuit des images du ciel de l'observatoire de Dax  "
   append texte "afin d'&eacute;valuer la qualit&eacute; du ciel nocturne et de guider les observations. <br>\n"
   append texte "Les observations sont automatiques et les images sont disponibles dans les formats FITS et JPEG.\n"
   append texte "Cette page contient les liens vers les images dans les deux formats et affiche la derni&egrave;re image acquise.\n"
   append texte "<h2>2. Eph&eacute;m&eacute;rides locales de DAX</h2>\n"
   append texte "$cmconf(resultbhtml)<br>\n"
   append texte "$cmconf(resultehtml)<br>\n"
   set localite "$cmconf(localite)"
   append texte "Phase de la Lune en d&eacute;but de nuit : [string range $cmconf(phaslun) 0 5]&deg;<br>\n"
   append texte "Fraction illumin&eacute;e de la Lune en d&eacute;but de nuit : ~[expr int($cmconf(illufrac))]%<br>\n"
   append texte "<h2>3. Derni&egrave;re image</h2>\n"
   append texte " <img src=\"last.jpg\" > \n"
   append texte "<h2>4. Liste des images de la nuit</h2>\n"

   set fileId [ open [ file join $folder $namehtml ] w ]
   puts $fileId $texte
   close $fileId
}

if { $::loopexit == "0" } {
   set texte "Image <b>[ file rootname [ file tail $cmconf(nameima) ] ]</b> faite le [string range $cmconf(date_debut_pose) 0 9] "
   append texte "&agrave; <b>[string range $cmconf(date_debut_pose) 11 18] TU</b> "
   append texte "(Temps Sid&eacute;ral Local $sidertime) - "
   append texte "<a href=\"[ file rootname [ file tail $cmconf(nameima) ] ].jpg\">| JPG |</a> - "
   append texte " <a href=\"[ file rootname [ file tail $cmconf(nameima) ] ]$cmconf(extension)\">| FITS |</a> <br>"
} else {
   set texte "Image <b>[ file rootname [ file tail $cmconf(nameima) ] ]</b> faite le [string range $cmconf(date_debut_pose) 0 9] "
   append texte "&agrave; <b>[string range $cmconf(date_debut_pose) 11 18] TU</b> "
   append texte "(Temps Sid&eacute;ral Local $sidertime) - "
   append texte "<a href=\"[ file rootname [ file tail $cmconf(nameima) ] ].jpg\">| JPG |</a> - "
   append texte " <a href=\"[ file rootname [ file tail $cmconf(nameima) ] ]$cmconf(extension)\">| FITS |</a> <br>"
   set nbtotimages $::compteur
   append texte "<p>Fin des observations du [string range [mc_date2iso8601 $actuel] 0 9] &agrave; "
   append texte "[string range [mc_date2iso8601 $actuel] 11 20] TU <br>"
   append texte "<b>$nbtotimages images</b> acquisent dans la nuit.<br>"
   append texte "MASCOT est fatigu&eacute; et va dormir du sommeil du juste en attendant la nuit prochaine..."
   append texte "</p> <hr>\n"

   append texte "<CENTER>\n"
   append texte "<FORM ACTION=\"\" METHOD=POST\n>"
   append texte "<SCRIPT LANGUAGE=JavaScript>\n"
   append texte "<!--\n"
   append texte "var current = 0;\n"
   append texte "function imageArray() {\n"
   append texte "    this.length = imageArray.arguments.length;\n"
   append texte "    for (var i=0; i<this.length; i++)\n"
   append texte "    {\n"
   append texte "       this\[i\] = imageArray.arguments\[i\];\n"
   append texte "    }\n"
   append texte "}\n"

   append texte "// All images in same dir, same size\n"
   append texte "var imgz = new imageArray("
   for { set k 1 } { $k <= [expr $::compteur-1] } { incr k } {
      append texte "\"[string range [mc_date2jd now] 0 6]-$::compteur$cmconf(extension).jpg\","
   }
   append texte "\"[string range [mc_date2jd now] 0 6]-$::compteur$cmconf(extension).jpg\");\n"
   append texte "document.write('<img name=\"myImages\" border=\"3\" src=\"'+imgz\[0\]+'\">');\n"
   append texte "function getPosition(val) {\n"
   append texte "   var goodnum = current+val;\n"
   append texte "   //Wrap around\n"
   append texte "   if (goodnum < 0) goodnum = imgz.length-1;\n"
   append texte "   else if (goodnum > imgz.length-1) goodnum = 0;\n"
   append texte "   document.myImages.src = imgz\[goodnum\];\n"
   append texte "   current = goodnum; }\n"
   append texte "//-->\n"

   append texte "</body>\n"
   append texte "</html>\n"
}

set fileId [ open [ file join $folder $namehtml ] a ]
puts $fileId $texte
close $fileId

