#
## @file satellites_radar.tcl
#  @brief Radar de satellites artificiels dans un cône
#  @author Raymond Zachantke
#  $Id: satellites_radar.tcl 13318 2016-03-09 08:25:42Z rzachantke $
#

#------------------------------------------------------------
#  brief     calcule les coordonnées des satellites dont la hauteur est supérieure à un seuil
#  details   invoque la proc ::satel_names2 dans satel.tcl
#  param     date date TU iso 8601
#  param     gps_zen  coordonnées GPS du zénith de l'observateur
#  param     elevMin élévation minimale en degrés
#  return    liste ra dec ha az elev
#
proc ::satellites::satel_radar { date gps_zen elevMin } {

   #--   Cree la liste sans doublon si elle n'existe  pas
   if {[info exists ::audace(satel,shortList)] eq "0"} {
      satel_names2 "" "1" 0
   }

   #--   Definit les coordonnees RADEC du lieu
   set az 0.0
   set elev 90.0
   lassign [mc_altaz2radec $az $elev $gps_zen $date] ra dec ha

   set result ""

   foreach satelname $::audace(satel,shortList) {

      #--   Identifie le nom court du fichier contenant les donnes du satellite
      lassign [lsearch -inline -index 0 $::audace(satel,satel_names) [string trim $satelname \"]*] satname satfile

      #--   Esquive les satellites (tels les debris) hors fichier
      if {$satfile eq ""} {
         #::console::affiche_erreur "Satellite \"$satelname\" not found in current TLEs.<br>"
         continue
      }
      #--   Definit le chemin complet
      #set tlefile [ file join $::audace(rep_userCatalog) tle $satfile]
      set tlefile [ file join $::audace(rep_userCatalogTle) $satfile]
      #::console::disp "tlefile $tlefile\n"
      #::console::disp "mc_tle2ephem $date \"$tlefile\" $gps_zen -name \"$satname\" -sgp 4\n"
      set res [lindex [mc_tle2ephem $date $tlefile $gps_zen -name $satname -sgp 4] 0]
      lassign  $res name rasat decsat -> -> -> ill -> azsat elevsat

      #--   Esquive les donnes invalides
      if {[string compare $ra -nan] eq "0"} {
         continue
      }

      lassign [::satellites::getApparentCoords $rasat $decsat $date $gps_zen] rasat decsat hasat azsat elevsat

      if {$elevsat > $elevMin} {
         lappend result [list $satelname $rasat $decsat $ill $hasat $azsat $elevsat]
      }
   }

   return $result
}

#------------------------------------------------------------
#  brief     retourne une liste d'étoiles brillantes
#  param     date date TU
#  param     gpsObs  coordonnées GPS de l'observateur
#  param     elevMin élévation minimale en degrés
#  return    liste de coordonnnées (nom trivial, premier, constellation, azimuth, élévation, magnitude)
#
proc ::satellites::getMyBrightStars { date gpsObs elevMin } {

   set path [file join $::audace(rep_catalogues) catagoto etoiles_brillantes.txt]
   regsub -all {\{\}} [split [K [read [set fi [open $path]]] [close $fi]] "\n"] "" catalog

   lappend catalog [list "" Gamma Cas 00 56 42.581 +60 43 00.20 2.47]
   lappend catalog [list Ruchbah Delta Cas 01 25 49.539 +60 14 06.30 2.68]

   set stars {}
   foreach line $catalog {
      lassign $line trivial first constellation adh adm ads decd decm decs mag
      set ra "${adh}h${adm}m${ads}s"
      set dec "${decd}d${decm}m${decs}s"
      lassign [lrange [::satellites::getApparentCoords $ra $dec $date $gpsObs] 3 end] azTel elevTel
      if {$elevTel >= $elevMin} {
         lappend stars [list "$trivial $first $constellation" $azTel $elevTel $mag]
      }
   }

   return $stars
}

#------------------------------------------------------------
#  brief    calcule les coordonnées sur le canvas
#  param    az azimuth en degrés
#  param    elev élévation en degrés
#  return   liste des coordonnées x et y dans le canvas
#
proc ::satellites::computeTranslation { az elev } {

   set anglerad [mc_angle2rad $az]
   set tx [expr { ($elev-90)*sin($anglerad) }]
   set ty [expr { (90.-$elev)*cos($anglerad) }]
   set tx [format "%0.2f" $tx]
   set ty [format "%0.2f" $ty]

   return [list $tx $ty]
}

#------------------------------------------------------------
#  brief    créé le fichier radar.svg
#  param    date date tu
#  param    gpsObs coordonnées GPS de l'observateur
#  param    elevMin élévation minimale en degrés
#
proc ::satellites::createRadar { {date ""} {gpsObs ""} {elevMin 50} } {
   variable private

   #--   filtre les entrees
   if {$date eq ""} {
      set date [clock format [clock seconds] -format "%Y-%m-%dT%H:%H:%S" -timezone :UTC]
   }

   if {$gpsObs eq ""} {
      set gpsObs $::audace(posobs,observateur,gps)
   }

   #--   Definit le chemin de l'image
   set svgfile [file join $::audace(rep_images) radar.svg]

   #--   Definit le rayon de recherche
   set cone [expr { 90-$elevMin }]

   #--   Definit la hauteur de l'equateur
   set elevEquat [expr { 90.-[lindex $gpsObs 3] }]

   #--   Liste les satellites repondant aux conditions
   set private(results) [::satellites::satel_radar $date $gpsObs $elevMin]
   set nb [llength $private(results)]

   set zoom 2.
   set radius 90
   set marge 30
   set width [expr { 2*($radius+$marge) }]
   set height $width
   set viewBox "0 0 $width $height"
   set xc [expr { $width/2 }]
   set yc [expr { $height/2+8 }]
   set boxwidth [expr { $width-2*$marge }]

   set htm "<?xml version='1.0' encoding='utf-8' standalone='no'?>"
   append htm "<svg width='[expr { $width*$zoom }]' height='[expr { $height*$zoom }]' viewBox='$viewBox' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' onload='Init(evt)'>"
   append htm "<desc>radar of satellites</desc>"
   append htm "<defs>"
   append htm "<script type='application/ecmascript'>"
   append htm "<!\[CDATA\["
   append htm "var SVGDocument=null; var SVGRoot=null; var toolTip=null; var tipText=null; var lastElement=null;"
   append htm "function Init(evt) {"
   append htm "SVGDocument=evt.target.ownerDocument;"
   append htm "SVGRoot=SVGDocument.documentElement;"
   append htm "toolTip=SVGDocument.getElementById('ToolTip');"
   append htm "tipText=SVGDocument.getElementById('tipText');"
   append htm "SVGRoot.addEventListener('mousemove',ShowTooltip,false);"
   append htm "SVGRoot.addEventListener('mouseout',HideTooltip,false);"
   append htm "};"
   append htm "function HideTooltip(evt) { toolTip.setAttributeNS(null,'visibility','hidden'); };"
   append htm "function ShowTooltip(evt) {"
   append htm "var satName=''; var targetElement=evt.target;"
   append htm "if (lastElement!=targetElement) {"
   append htm "satName=targetElement.getAttributeNS(null,'id');"
   append htm "tipText.firstChild.nodeValue=satName;"
   append htm "tipText.setAttributeNS(null,'display','inline');"
   append htm "}"
   append htm "toolTip.setAttributeNS(null,'visibility','visible');"
   append htm "};"
   append htm "\]\]>"
   append htm "</script>"
   append htm "<style type=\"text/css\">"
   append htm "text{font-family:Arial;fill:black;text-anchor:middle;font:bold;font-size:6px}"
   append htm "rect{fill:lightgrey}"
   append htm ".line{stroke:#7FFF00;stroke-width:0.3;stroke-dasharray:2,2}"
   append htm ".grid{fill:black;fill-opacity:0.2;stroke:#7FFF00;stroke-width:0.3}"
   append htm ".ill{fill:red;stroke:black;stroke-width:0.04}"
   append htm ".noill{fill:black;stroke:black;stroke-width:0.04}"
   append htm ".tipbox{fill:white;stroke:black;stroke-width:1}"
   append htm ".equat{fill:none;stroke:red;stroke-width:0.4}"
   append htm ".sat{stroke:black;stroke-width:0.3}"
   append htm ".star{fill:skyblue}"
   append htm "</style>"

   #--   modele de satellite et d'etoile
   append htm "<circle class='sat' id='sat' cx='$xc' cy='$yc' r='1.5'/>"
   append htm "<circle class='star' id='star' cx='$xc' cy='$yc' r='1'/>"
   append htm "</defs>"

   append htm "<g transform='scale($zoom)'>"

   append htm "<rect x='0' y='0' width='$width' height='$height'/>"

   #--   le premiere boite
   set y 3
   append htm "<rect class='tipbox' x='$marge' y='$y' rx='5' ry='5' width='$boxwidth' height='27'/>"
   set msg1 "$::caption(satellites,tu) $date"
   set msg2 "$::caption(satellites,gps)"
   set msg3 "[list $gpsObs]"
   set msg4 "$nb satellites dans un rayon de $cone deg."
   foreach item [list msg1 msg2 msg3 msg4] {
      set val [set $item]
      incr y 6
      append htm "<text x='[expr { $xc-[string length $val]/2+$marge }]' y='$y'>$val</text>"
   }

   #--   les points cardinaux
   append htm "<text x='$xc' y='[expr { $yc-$radius-1 }]'>N</text>"
   append htm "<text x='$xc' y='[expr { $yc+$radius+6 }]'>S</text>"
   append htm "<text x='[expr { $xc-$radius-5 }]' y='[expr { $yc+2 }]'>W</text>"
   append htm "<text x='[expr { $xc+$radius+3 }]' y='[expr { $yc+2 }]'>E</text>"

   #--   les cercles
   append htm "<circle class='grid' cx='$xc' cy='$yc' r='0.1'/>"
   for {set k $radius} {$k >= 10} {incr k -10} {
      append htm "<circle class='grid' cx='$xc' cy='$yc' r='$k'/>"
   }

   #--   les lignes croisees
   append htm "<path class='line' d='M $marge,$yc h [expr {2*$radius}]'/>"
   append htm "<path class='line' d='M $xc,[expr {$yc+$radius }] v [expr { -2*$radius }]'/>"

   #--   l'equateur celeste
   append htm "<path class='equat' d='M $marge,$yc a $radius,[expr { 90-$elevEquat }] 0 1,0 [expr { 2*$radius }],0 a $radius,[expr { 90-$elevEquat }]'/>"

   #--   les etoiles brillantes
   set stars [::satellites::getMyBrightStars $date $gpsObs $elevMin]
   foreach star $stars {
      lassign $star starname az elev mag
      lassign [::satellites::computeTranslation $az $elev] tx ty
      append htm "<use xlink:href='#star' id='$starname mag=$mag' transform='translate($tx,$ty)'/>"
   }

   #--   les satellites
   foreach r $private(results) {
      lassign $r name ra dec ill -> az elev
      lassign [::satellites::computeTranslation $az $elev] tx ty
      regsub -all "\&" $name "and" satname
      if {$ill == 1} {
         set clas "ill"
      } else {
         set clas "noill"
      }
      append htm "<use xlink:href='#sat' id='$satname RA=$ra DEC=$dec' class='$clas' transform='translate($tx,$ty)'/>"
   }

   #--   la derniere boite
   append htm "<rect class='tipbox' x='5' y='[expr { $height-13 }]' rx='5' ry='5' width='[expr { $width-10 }]' height='10'/>"
   append htm "<g id='ToolTip' visibility='hidden' pointer-events='none'>"
   append htm "<text id='tipText' x='[expr { $width/2 }]' y='[expr { $height-6 }]'><!\[CDATA\[\]\]></text>"
   append htm "</g>"

   append htm "</g>"
   append htm "Sorry, your browser does not support SVG.</svg>"

   #--   ecrit le fihcier svg
   set fid [open $svgfile w]
   puts $fid $htm
   close $fid

   #--   Cree la page HTML
   ::satellites::createHtm [file join $::audace(rep_images) radar.htm] radar.svg
}

#------------------------------------------------------------
## @brief    créé la page html du radar
#  @param    dest chemin complet de la page
#  @param    img  nom court de l'image
#
proc ::satellites::createHtm { dest img } {
   variable private

   puts -nonewline "Content-type: text/html\n\n"
   append html "<!DOCTYPE html> <html lang=\"fr\">"
   append html "<head>"
   append html "<meta charset=\"utf-8\" />"
   append html "<meta name=\"author\" content=\"AudeLA software\"/>"
   append html "<style>body{margin-left:10px;text-align:left;background:#e6e6fa;serif;font-size:12px}header{font-weight:bold;font-size:14px}\
      iframe{width:480px;height:480px;margin:10px 0;border:outset 2px silver;border-radius:10px;box-shadow:5px 5px 12px #444;} \
      table{float:left;border:1px solid black;margin:10px 0}table thead th{text-align:center}footer{clear:both;height:20px}table td{text-align:center}</style>"
   append html "<title>Radar</title>"
   append html "</head>"
   append html "<body>"

   #--   ligne de titre
   append html "<header>$::caption(satellites,title)</header>"

   append html "<div>"

   #--   l'image
   append html "<iframe src=\"$img\">Your browser does not support iframes</iframe><br><br>"

   #--   les donnees
   append html "<table>"
   append html "<thead><tr><th>$::caption(satellites,satellite)</th><th>$::caption(satellites,ra)</th><th>$::caption(satellites,dec)</th><th>$::caption(satellites,ill)</th><th>$::caption(satellites,ha)</th><th>$::caption(satellites,az)</th><th>$::caption(satellites,elev)</th></tr></thead>"
   append html "<tbody>"
   foreach item $private(results) {
      lassign $item name ad dec ill ha az elev
      append html "<tr><th>$name</th><td>$ad</td><td>$dec</td><td>$ill</td><td>$ha</td><td>$az</td><td>$elev</td></tr>"
   }
   append html "</tbody></table>"
   append html "</div>"

   #--   pied de page
   set date [clock format [clock seconds] -format "%Y-%m-%dT%H:%M:%S" -timezone :UTC ]
   set year [lindex [split $date "-"] 0]
   if {$year eq "2015"} {
      append html "<footer>Copyright 2015  AudeLA software &nbsp;Page modified : $date</footer>"
   } else {
      append html "<footer>Copyright 2015 - $year  AudeLA software &nbsp;Page created : $date UTC</footer>"
   }
   append html "</body></html>"

   #--   Ecrit la page
   set f [open $dest w]
   puts $f $html
   close $f

   #--   Affiche la page
   exec $::conf(editsite_htm) [file join file:///$dest] &
}

