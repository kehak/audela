#
## @file catalogexplorer_svg.tcl
#  @brief Création de l'image SVG et de la page HTML pour catalogexplorer
#  @author Raymond Zachantke
#  $Id: catalogexplorer_svg.tcl 13253 2016-02-22 16:23:25Z rzachantke $
#

#------------------------------------------------------------
#  brief  créé le fichier catalogsky.svg
#
proc ::catalogexplorer::createsvg { } {
   variable widget
   global caption

   #--   Extraction des parametres
   lassign $widget(catalogexplorer,data) catalog -> naxis1 naxis2 -> -> mag_bright mag_faint -> -> scale
   set radius [format %0.2f [expr { $widget(catalogexplorer,fov_deg)/2 }]]
   set svgfile "[file join $::audace(rep_images) catalogsky.svg]"
   set starList $widget(catalogexplorer,stars)
   set len [llength $starList]

   set title "$catalog : $len $caption(catalogexplorer,star) - Mag $mag_bright/$mag_faint - [format $caption(catalogexplorer,radius) $radius] - [format $caption(catalogexplorer,scale) $scale]"

   set convsigma 1.5
   set shadow 10
   set wBorder 20
   set hBorder 30
   set fontsize 10

   #--   Calcule la largeur theorique de la box d'affichage
   #     sans tenir compte de la longueur du message
   set tipwidth [expr { $naxis1*$scale }]

   #--   Maximum du nombre de caracteres dans le titre et dans le commentaire
   set maxCar [lmax [list [string length $title] $widget(catalogexplorer,msgLen)]]
   #--   Calcul empirique de la largeur minimale de la box pour contenir le message
   #--   Largeur minimale en pixels de la boite d'affichage
   set tipWidthMin [expr { $maxCar*$fontsize*0.65+20 }]

   if {$tipWidthMin > $tipwidth} {
      set scale [format %0.2f [expr { 1.*$tipWidthMin/$naxis1 }]]
      set tipwidth [expr {$naxis1*$scale }]
      #--   Met a jour le titre
      set title [lreplace $title end end $scale]
   }

   set width [expr { $naxis1*$scale+2*$wBorder+2*$shadow }]
   set height [expr { $naxis2*$scale+2*$hBorder+2*$shadow }]
   set sigma [expr { $convsigma*$scale }]

   set htm "<?xml version='1.0' encoding='utf-8' standalone='no'?>"
   append htm "<svg width='$width' height='$height' viewport='0 0 $width $height' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' onload='Init(evt)' >"
   append htm "<desc>visualisation des etoiles d'un catalogue</desc>"
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
   append htm "var star=''; var targetElement=evt.target;"
   append htm "if (lastElement!=targetElement) {"
   append htm "star=targetElement.getAttributeNS(null,'id');"
   append htm "tipText.firstChild.nodeValue=star;"
   append htm "tipText.setAttributeNS(null,'display','inline');"
   append htm "}"
   append htm "toolTip.setAttributeNS(null,'visibility','visible');"
   append htm "};"
   append htm "\]\]>"
   append htm "</script>"
   append htm "<style>"
   append htm ".cover{fill:none;stroke:grey;stroke-width:5}"
   append htm ".star{filter:url(#blur)}"
   append htm ".star:hover{stroke:red;stroke-width:2}"
   append htm ".tipbox{fill:white;stroke:black;stroke-width:1}"
   append htm ".border{fill:lightgrey;stroke:silver;stroke-width:5}"
   append htm "text{font-family:Arial;fill:black;text-anchor:middle;font-size:${fontsize}px}"
   append htm "</style>"
   append htm "<filter id='shadow' x='0' y='0' width='200%' height='200%'>"
   append htm "<feOffset result='offOut' in='SourceAlpha' dx='$shadow' dy='$shadow'/>"
   append htm "<feGaussianBlur result='blurOut' in='offOut' stdDeviation='2'/>"
   append htm "<feBlend in='SourceGraphic' in2='blurOut' mode='normal'/>"
   append htm "</filter>"
   append htm "<filter id='blur'><feGaussianBlur stdDeviation='$sigma'/></filter>"
   append htm "</defs>"

   #--   Contour global
   append htm "<rect class='border' x='0' y='0' width='[expr { $width-2*$shadow }]' height='[expr { $height-2*$shadow }]' rx='15' ry='15' filter='url(#shadow)'/>"
   #--   Texte en tete
   append htm "<text x='[expr { $wBorder+$naxis1*$scale/2 }]' y='18'>$title</text>"
   #--   Screen
   append htm "<rect x='$wBorder' y='$hBorder' width='[expr { $naxis1*$scale }]' height='[expr { $naxis2*$scale }]' rx='10' ry='10'/>"
   #--   Stars
   foreach star $starList {
      lassign $star x y color msg
      #--   Remplace les caracteres svg par des espaces
      regsub -all {[\<\>\'\"\/]} $msg " " msg
      append htm "<circle class='star' id='$msg' cx='[expr { $x*$scale+$wBorder }]' cy='[expr { $y*$scale+$hBorder }]' r='3' style='fill:$color;'/>"
   }
   #--   Ligne d'affichage
   set tipy [expr { $hBorder+$naxis2*$scale+6 }]
   append htm "<rect class='tipbox' x='$wBorder' y='$tipy' rx='5' ry='5' width='$tipwidth' height='20'/>"
   #--   Texte
   append htm "<g id='ToolTip' visibility='hidden' pointer-events='none'>"
   append htm "<text id='tipText' x='[expr { $wBorder+$naxis1*$scale/2 }]' y='[expr { $tipy+14 }]'><!\[CDATA\[\]\]></text>"
   append htm "</g>"
   #--   Joint
   append htm "<rect class='cover' x='[expr { $wBorder-2 }]' y='[expr { $hBorder-2 }]' width='[expr { $naxis1*$scale+2}]' height='[expr { $naxis2*$scale+2}]' rx='10' ry='10'/>"
   append htm "</svg>"

   set fid [open $svgfile w]
   puts $fid $htm
   close $fid

   #--   Cree la page HTML
   set dest [file join $::audace(rep_images) catalogsky.htm]
   ::catalogexplorer::createHtm $width $height $dest catalogsky.svg
}

#------------------------------------------------------------
#  brief  créé et ouvre la page html
#  param  width  largeur de l'iframe en pixels
#  param  height hauteur de l'iframe en pixels
#  param  dest   chemin de la page html
#  param  img    nom de l'imag svg
#
proc ::catalogexplorer::createHtm { width height dest img } {

   puts -nonewline "Content-type: text/html\n\n"
   append html "<!DOCTYPE html> <html lang=\"fr\">"
   append html "<head>"
   append html "<meta charset=\"utf-8\" />"
   append html "<meta name=\"author\" content=\"AudeLA software\"/>"
   append html "<style>body{margin-left:10px;text-align:left;background:#e6e6fa;serif;font-size:12px}</style>"
   append html "</head>"
   append html "<body>"
   #--   l'image
   append html "<iframe src=\"$img\" width=\"${width}px\" height=\"${height}px\" frameBorder=\"0\">Your browser does not support iframes</iframe><br><br>"

   #--   pied de page
   set date [clock format [clock seconds] -format "%Y-%m-%dT%H:%M:%S" -timezone :UTC ]
   set year [lindex [split $date "-"] 0]
   append html "<footer>Copyright 2015 - $year  AudeLA software &nbsp;Page created : $date UTC</footer>"
   append html "</body></html>"

   #--   Ecrit la page
   set f [open $dest w]
   puts $f $html
   close $f

   #--   Affiche la page
   exec $::conf(editsite_htm) [file join file:///$dest] &
}

