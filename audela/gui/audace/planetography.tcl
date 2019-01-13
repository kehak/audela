#
## @file planetography.tcl
#  @brief Script dédié à la planétographie
#  @author Alain KLOTZ
#  $Id: planetography.tcl 13473 2016-03-23 15:25:46Z rzachantke $
#

#------------------------------------------------------------
## @brief calcule la position RA DEC et la visibilité dans une image d'une position (longitude, latitude) d'une planète
#  @details image de 500x500 pour un télescope de 1 m de focale
#  @param planet { Sun | Moon | Mercury | Venus | Mars | Jupiter | Saturn | Uranus | Neptune | Pluto }
#  @param lon longitude de la planète
#  @param lat latitude de la planète
#  @param date UTC, now par défaut
#  @param home coordonnées GPS de l'observateur
#  @return coordonnées RA et Dec et la visibilité (coeff -1 derrière la planète, 0 sur le bord , 1 au centre)
#
proc lonlat2radec { planet lon lat {date now} {home {GPS 0 E 42 150}} } {

   #--- Ephemerides physiques topocentriques de la planete
   set res [lindex [mc_ephem $planet [list [mc_date2tt $date]] \
   {LONGI LATI LONGI_SUN LATI_SUN POSNORTH APPDIAMPOL APPDIAMEQU RA DEC} \
   -topo $home] 0]
   set longi [lindex $res 0]
   set lati [lindex $res 1]
   set longi_sun [lindex $res 2]
   set lati_sun [lindex $res 3]
   set posnorth [lindex $res 4]
   set appdiampol [lindex $res 5]
   set appdiamequ [lindex $res 6]
   set ra0 [lindex $res 7]
   set dec0 [lindex $res 8]
   set f [expr 1.-$appdiampol/$appdiamequ]
   set power 0.1

   #--- Parametres astrometriques d'une l'image fictive
   set req 200
   #set ech [expr $appdiamequ/$req]
   set foclen 1.
   set pixsize1 [expr $foclen*atan($appdiamequ/2./$req*3.1415926535/180.)]
   set pixsize2 $pixsize1
   set naxis1 500
   set naxis2 500
   set crota2 0
   set field [list OPTIC NAXIS1 $naxis1 NAXIS2 $naxis2 FOCLEN $foclen PIXSIZE1 $pixsize1 PIXSIZE2 $pixsize2 CROTA2 $crota2 RA $ra0 DEC $dec0]
   set xc [expr $naxis1/2.]
   set yc [expr $naxis2/2.]

   #--- Calcule la position du point sur l'image fictive
   set res [mc_lonlat2xy $longi $lati $posnorth $f $xc $yc $req $lon $lat $longi_sun $lati_sun $power]
   set x [lindex $res 0]
   set y [lindex $res 1]
   set vis [lindex $res 2]

   #--- Calcule la position astrometrique de (x,y)
   set res [mc_xy2radec $x $y $field]
   set ra [lindex $res 0]
   set dec [lindex $res 1]
   return [list $ra $dec $vis]
}

#------------------------------------------------------------
## @brief calcule la position (longitude, latitude) d'une planète à partir de la position RA DEC dans une image
#  @details image de 500x500 pour un télescope de 1 m de focale
#  @param planet { Sun | Moon | Mercury | Venus | Mars | Jupiter | Saturn | Uranus | Neptune | Pluto }
#  @param ra  coordonnée RA
#  @param dec  coordonnée DEC
#  @param date UTC, now par défaut
#  @param home coordonnées GPS de l'observateur
#  @return longitude et latitude planétographique du point de coordonnées RA,Dec
#
proc radec2lonlat { planet ra dec {date now} {home {GPS 0 E 42 150}} } {

   #--- Ephemerides physiques topocentriques de la planete
   set res [lindex [mc_ephem $planet [list [mc_date2tt $date]] \
   {LONGI LATI LONGI_SUN LATI_SUN POSNORTH APPDIAMPOL APPDIAMEQU RA DEC} \
   -topo $home] 0]
   set longi [lindex $res 0]
   set lati [lindex $res 1]
   set longi_sun [lindex $res 2]
   set lati_sun [lindex $res 3]
   set posnorth [lindex $res 4]
   set appdiampol [lindex $res 5]
   set appdiamequ [lindex $res 6]
   set ra0 [lindex $res 7]
   set dec0 [lindex $res 8]
   set f [expr 1.-$appdiampol/$appdiamequ]
   set power 0.1
   ::console::affiche_resultat "ra0=$ra0 dec0=$dec0\n"

   #--- Parametres astrometriques d'une l'image fictive
   set req 200
   #set ech [expr $appdiamequ/$req]
   set foclen 1.
   set pixsize1 [expr $foclen*atan($appdiamequ/2./$req*3.1415926535/180.)]
   set pixsize2 $pixsize1
   set naxis1 500
   set naxis2 500
   set crota2 0
   set field [list OPTIC NAXIS1 $naxis1 NAXIS2 $naxis2 FOCLEN $foclen PIXSIZE1 $pixsize1 PIXSIZE2 $pixsize2 CROTA2 $crota2 RA $ra0 DEC $dec0]
   set xc [expr $naxis1/2.]
   set yc [expr $naxis2/2.]

   #--- Calcule la position astrometrique de (x,y)
   set ra [mc_angle2deg $ra]
   set dec [mc_angle2deg $dec]
   set res [mc_radec2xy $ra $dec $field]
   set x [lindex $res 0]
   set y [lindex $res 1]

   #--- Calcule la position du point sur l'image fictive
   set res [mc_xy2lonlat $longi $lati $posnorth $f $xc $yc $req $x $y $longi_sun $lati_sun $power]
   return $res
}

