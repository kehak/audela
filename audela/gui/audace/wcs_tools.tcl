#
## @file wcs_tools.tcl
#  @brief procs de manipulation des mots clés WCS et transformation de coordonnéees
#  @author Alain KLOTZ
#  $Id: wcs_tools.tcl 14168 2017-02-09 10:34:40Z alainklotz $
#  @code source $audace(rep_install)/gui/audace/wcs_tools.tcl
#  @endcode
#
# Background:
# --------------
#
#  WCS stands for World Coordinate System. This corresponds
#  to the parameters that allow to transform cartesian (x,y)
#  coordinates into celestial coordinates (i.e. ra,dec).
#  The procs written in this file read and save WCS keywords
#  and allow to calibrate astrometry.
#
# 1) WCS keyword
# --------------
#
# The WCS keywords are defined in:
# Calabretta & Greisen (2002) A&A 395, 1077
#
# The middle of the first pixel is (1,1) in the FITS stansdard.
# This is the same case for Sextractor and AudeLA.
#
# 2) WCS structure
# ----------------
#
# WCS structure is the internal variable that allows to use
# WCS transformations in procs in this file.
#
# WCS structure is a list of FITS header keywords as:
# {CRPIX1 212 float {X pole along NAXIS1} pix} {CRPIX2 270 float {Y pole along NAXIS2} pix} ...
#
# The elements of the list have the same definition than
# result of "buf1 getkwd":
# element 1 : FITS keyword
# element 2 : Value
# element 3 : type
# element 4 : comment
# element 5 : unit
#
# Amongst the WCS structure one can find type=private for
# internal variables used for coordinate computation. Only
# non private type keywords have to be recorded in the
# FITS header at the end of the process (cf. wcs_wcs2buf).
#
# ===============================================================
# User guide with an example to calibrate from optical parameters
# ---------------------------------------------------------------
#
# To set WCS from optical parameters (no catalog needed):
# @code
# loadima a
# set wcs [wcs_optic2wcs 360 288 10 89.5 8.6 8.4 0.135 0]
# wcs_wcs2buf $wcs 1
# saveima aa
#
# One can display the updated WCS keywords:
# wcs_dispkwd $wcs "" public
# @endcode
#
# ===============================================================
#  User guide with an example to calibrate with a star catalog
# ---------------------------------------------------------------
#
#  To set WCS from an image with approximate WCS and a catalog
#  (cf. focas_imagedb2pairs guide to match stars with the catalog):
#  @code
#  set couples [focas_imagedb2pairs cc USNOA2 c:/d/usno 1 20]
#  set wcs [wcs_focaspairs2wcs $couples 1]
#  wcs_wcs2buf $wcs 1
#  set wcs [wcs_buf2wcs 1]
#  set wcs [wcs_update_optic $wcs]
#  wcs_wcs2buf $wcs 1
#  saveima aa
#
#  One can display the updated WCS keywords:
#  wcs_dispkwd $wcs "" public
#  @endcode
#
# ===============================================================
#  User guide with an example to convert (x,y)->(ra,dec)
# ---------------------------------------------------------------
#
#  When WCS keywords are presents in a FITS header, use wcs_buf2wcs
#  to generate the wcs list. Then it is possible to convert from
#  cartesian (x,y) to celestial coordinates (ra,dec):
#  @code
#  loadima aa
#  set wcs [wcs_buf2wcs]
#  wcs_xy2radec $wcs 1024.2 57.8
#  @endcode
#
# ===============================================================
#  User guide with an example to convert (ra,dec)->(x,y)
# ---------------------------------------------------------------
#
#  When WCS keywords are presents in a FITS header, use wcs_buf2wcs
#  to generate the wcs list. Then it is possible to convert from
#  celestial coordinates (ra,dec) to cartesian (x,y):
#  @code
#  loadima aa
#  set wcs [wcs_buf2wcs]
#  wcs_radec2xy $wcs 12h35m21s -34d03m05s
#  @endcode
#
# =================================================================

# =================================================================
# =================================================================
# === Create or read WCS keys
# =================================================================
# =================================================================

# =================================================================
## @brief construit la structure wcs à partir des valeurs des mots clés
#  @details paramètres dans l'ordre CRPIX1 CRPIX2 CRVAL1 CRVAL2 EQUINOX RADESYS CDELT1 CDELT2 CROTA2 CD1_1 CD1_2 CD2_1 CD2_2
#  @return structure (liste de liste) des mots clés
#
proc wcs_builder { CRPIX1 CRPIX2 CRVAL1 CRVAL2 EQUINOX RADESYS CDELT1 CDELT2 CROTA2 CD1_1 CD1_2 CD2_1 CD2_2 }  {
   set pi [expr 4*atan(1)]
   # -- public
   set wcs ""
   #
   lappend wcs [list CRPIX1 $CRPIX1 float "X pole along NAXIS1" "pix"]
   lappend wcs [list CRPIX2 $CRPIX2 float "Y pole along NAXIS2" "pix"]
   lappend wcs [list CRVAL1 $CRVAL1 double "alpha pole" "deg"]
   lappend wcs [list CRVAL2 $CRVAL2 double "delta pole" "deg"]
   lappend wcs [list EQUINOX $EQUINOX string "Equinox" "date"]
   lappend wcs [list RADESYS $RADESYS string "Reference" "date"]
   #
   lappend wcs [list CDELT1 $CDELT1 double "X scale" "deg/pix"]
   lappend wcs [list CDELT2 $CDELT2 double "Y scale" "deg/pix"]
   lappend wcs [list CROTA2 $CROTA2 double "rotation" "deg"]
   lappend wcs [list CD1_1  $CD1_1 double "CD matrix 11" "deg/pix"]
   lappend wcs [list CD1_2  $CD1_2 double "CD matrix 12" "deg/pix"]
   lappend wcs [list CD2_1  $CD2_1 double "CD matrix 21" "deg/pix"]
   lappend wcs [list CD2_2  $CD2_2 double "CD matrix 22" "deg/pix"]
   # --- public+
   lappend wcs [list WCSAXES 2        int "WCS dimensionality" ""]
   lappend wcs [list LONPOLE 180      float "Long. of the celest.NP in native coor.syst." deg]
   lappend wcs [list CTYPE1 RA---TAN  string "Gnomonic projection" ""]
   lappend wcs [list CTYPE2 DEC--TAN  string "Gnomonic projection" ""]
   lappend wcs [list CUNIT1 deg       string "Angles are degrees always" ""]
   lappend wcs [list CUNIT2 deg       string "Angles are degrees always" ""]
   # --- private
   lappend wcs [list pi      $pi private "Pi number" ""]
   lappend wcs [list dr      [expr $pi/180] private "deg->rad factor" ""]
   lappend wcs [list phip    $pi private "Phi pole gnomonic" "rad"]
   #
   lappend wcs [list r1      $CRPIX1 private "X pole along NAXIS1" "pix"]
   lappend wcs [list r2      $CRPIX2 private "X pole along NAXIS1" "pix"]
   #
   #lappend wcs [list wcs_ref cat     private "cat | app" ""]
   set rap [expr $CRVAL1*$pi/180]
   set decp [expr $CRVAL2*$pi/180]
   set cosdecp [expr cos($decp)]
   set sindecp [expr sin($decp)]
   lappend wcs [list rap     $rap private "alpha pole" "rad"]
   lappend wcs [list decp    $decp private "delta pole" "rad"]
   lappend wcs [list cosdecp $cosdecp private "cos delta pole" ""]
   lappend wcs [list sindecp $sindecp private "sin delta pole" ""]
   #
   lappend wcs [list sm11   [expr $CD1_1*$pi/180] private "CD matrix 11" "rad/pix"]
   lappend wcs [list sm12   [expr $CD1_2*$pi/180] private "CD matrix 12" "rad/pix"]
   lappend wcs [list sm21   [expr $CD2_1*$pi/180] private "CD matrix 21" "rad/pix"]
   lappend wcs [list sm22   [expr $CD2_2*$pi/180] private "CD matrix 22" "rad/pix"]
   #
   return $wcs
}

# =================================================================
## @brief complète la structure wcs avec les paramètres pour les coordonnées apparentes
#  @remarks To add to wcs after wcs_builder
#  @param wcs structure wcs
#  @param date date au format ISO8601
#  @param home coordonnées GPS de l'observateur
#  @param pressure_Pa pression atmosphérique en Pa
#  @param temperature_K température °K
#  @param humidity_percent humidité en %
#  @param wavelength_nm longueur d'onde en nm
#  @return structure wcs complétée
#
proc wcs_apparent_parameters { wcs date home {pressure_Pa 101325} {temperature_K 290} {humidity_percent 40} {wavelength_nm 550} } {

   lassign [wcs_getkwd $wcs {pi dr} ] pi dr CRVAL1 CRVAL2
   if {$pi==""} { return }
   set wcs [wcs_setkwd $wcs [list date  $date private "Date of mid exposure" "ISO8601"]]
   set wcs [wcs_setkwd $wcs [list home  $home private "Home" "GPS"]]
   set wcs [wcs_setkwd $wcs [list pressure_Pa 101325 private "Atm. Pressure" "Pa"]]
   set wcs [wcs_setkwd $wcs [list temperature_K 290 private "Atm. Temperature" "K"]]
   set wcs [wcs_setkwd $wcs [list humidity_percent 40 private "Atm. humidity" "percent"]]
   set wcs [wcs_setkwd $wcs [list wavelength_nm 550 private "Wavelength" "nm"]]
   #
   #set wcs [wcs_setkwd $wcs [list wcs_ref app]]
   return $wcs
}

# =================================================================
## @brief extrait les valeurs des mots clés d'une structure wcs
#  @param wcs  structure wcs
#  @param kwds liste des mots clés à extraire
#  @return
#  -liste des valeurs des mots clés
#  -si un mot clé n'est pas trouvé, sa valeur est ""
#
proc wcs_getkwd { wcs kwds } {

   set vals ""
   foreach kwd $kwds {
      set k [lsearch -exact -index 0 $wcs $kwd]
      if {$k>=0} {
         lappend vals [lindex [lindex $wcs $k] 1]
      } else {
         lappend vals ""
      }
   }
   return $vals
}

# =================================================================
## @brief ajoute/modifie un mot clé dans une structure de mots clés
#  @code
#  set kwd_descr [list home $audace(posobs,observateur,gps) private "Home" "GPS"]
#  set new_wcs [wcs_setkwd $wcs $kwd_descr]
#  @endcode
#  @param wcs structure wcs (liste de liste) de mots clés existante
#  @param kwd_descr description du mot clé (une liste)
#  @return liste wcs complétée/modifiée
#
proc wcs_setkwd { wcs kwd_descr } {

   set kwd [lindex $kwd_descr 0]
   set k [lsearch -exact -index 0 $wcs $kwd]
   if {$k>=0} {
      set n [llength $kwd_descr]
      if {$n==2} {
         set old_descr [lindex $wcs $k]
         set res ""
         lappend res [lindex $kwd_descr 0]
         lappend res [lindex $kwd_descr 1]
         lappend res [lindex $old_descr 2]
         lappend res [lindex $old_descr 3]
         lappend res [lindex $old_descr 4]
         set kwd_descr $res
      }
      set wcs [lreplace $wcs $k $k $kwd_descr]
   } else {
      set n [llength $kwd_descr]
      if {$n>=2} {
         lappend wcs $kwd_descr
      } else {
         error "wcs_setkwd, not enough parameters for $kwd_descr\n"
      }
   }
   return $wcs
}

# =================================================================
## @brief édite sélectivement les mots clés vers la console
#  @param wcs  structure wcs (liste de liste) de mots clés
#  @param kwds liste des mots clés à éditer, par défaut tous
#  @param type type de mots clés {all | public | private }, par défaut all
#
proc wcs_dispkwd { wcs {kwds ""} {type all} } {

   if {$kwds==""} {
      set kwds ""
      foreach wc $wcs {
         lappend kwds [lindex $wc 0]
      }
   }
   foreach kwd $kwds {
      set k [lsearch -exact -index 0 $wcs $kwd]
      if {$k>=0} {
         set res [lindex $wcs $k]
         set t [lindex $res 2]
         if {$type=="public"} {
            if {$t!="private"} {
               console::affiche_resultat "$res\n"
            }
         } elseif {$type=="private"} {
            if {$t=="private"} {
               console::affiche_resultat "$res\n"
            }
         } else {
            console::affiche_resultat "$res\n"
         }
      }
   }
}

# =================================================================
## @brief définit les mots clés à partir des données optiques
#  @details utilise wcs_cdelt2cd, wcs_builder, wcs_update_optic et wcs_setkwd
#  @param pixref1_pix pixel de référence en x
#  @param pixref2_pix pixel de référence en y
#  @param Angle_ra    angle RA en HMS ou en degrés
#  @param Angle_dec   angle DEC en DMS ou en degrés
#  @param pixsize1_mu taille en x des pixels, en micron
#  @param pixsize2_mu taille en y des pixels, en micron
#  @param foclen_m    longueur focale, en m
#  @param Angle_rotation_field angle de rotation
#  @return structure wcs de mots clés suivants :
#  - CRPIX1 CRPIX2 CRVAL1 CRVAL2 RA DEC
#  - CDELT1 CDELT2 CD1_1 CD1_2 CD2_1 CD2_2
#  - PIXSIZE1 PIXESIZE2 FOCLEN CROTA2
#  - EQUINOX RADESYS WCSMATCH
#
proc wcs_optic2wcs { pixref1_pix pixref2_pix Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m Angle_rotation_field} {

   set pi [expr 4*atan(1)]
   # --
   set CRPIX1 $pixref1_pix
   set CRPIX2 $pixref2_pix
   set CRVAL1 [mc_angle2deg $Angle_ra 360]
   set CRVAL2 [mc_angle2deg $Angle_dec 90]
   set EQUINOX J2000
   set RADESYS FK5
   # --
   set mult 1e-6
   set CDELT1 [expr -2*atan($pixsize1_mu/$foclen_m*$mult/2.)*180/$pi]
   set CDELT2 [expr  2*atan($pixsize2_mu/$foclen_m*$mult/2.)*180/$pi]
   set CROTA2 [mc_angle2deg $Angle_rotation_field]
   lassign [wcs_cdelt2cd $CDELT1 $CDELT2 $CROTA2] CD1_1 CD1_2 CD2_1 CD2_2
   set wcs [wcs_builder $CRPIX1 $CRPIX2 $CRVAL1 $CRVAL2 $EQUINOX $RADESYS $CDELT1 $CDELT2 $CROTA2 $CD1_1 $CD1_2 $CD2_1 $CD2_2 ]
   set wcs [wcs_setkwd $wcs [list RA [mc_angle2deg $Angle_ra 360] double "RA J2000" "deg"]]
   set wcs [wcs_setkwd $wcs [list DEC [mc_angle2deg $Angle_dec 90] double "Dec J2000" "deg"]]
   set wcs [wcs_update_optic $wcs $pixsize1_mu $pixsize2_mu $foclen_m]
   set wcs [wcs_setkwd $wcs [list WCSMATCH 0 int "Nb catalog stars matched" ""]]
   return $wcs
}

# =================================================================
## @brief extrait et traite les mots clés d'une image vers une structure wcs ;
#  image buffer -> WCS structure
#  @details utilise wcs_builder, wcs_cdelt2cd, wcs_cd2cdelt, wcs_update_optic, getkwd et setkwd
#  @param bufNo numéro du buffer de l'image
#  @return structure wcs avec les mots clés de l'image
#
proc wcs_buf2wcs { {bufNo 1} } {

   set pi [expr 4*atan(1)]
   # -- coordinates
   set CRPIX1  [lindex [buf$bufNo getkwd CRPIX1] 1]
   if {$CRPIX1==""} { error "Keyword CRPIX1 not found in the FITS header" }
   set CRPIX2  [lindex [buf$bufNo getkwd CRPIX2] 1]
   if {$CRPIX2==""} { error "Keyword CRPIX2 not found in the FITS header" }
   set CRVAL1  [lindex [buf$bufNo getkwd CRVAL1] 1]
   if {$CRVAL1==""} { error "Keyword CRVAL1 not found in the FITS header" }
   set CRVAL2  [lindex [buf$bufNo getkwd CRVAL2] 1]
   if {$CRVAL2==""} { error "Keyword CRVAL1 not found in the FITS header" }
   set EQUINOX [string trim [lindex [buf$bufNo getkwd EQUINOX] 1]]
   if {$EQUINOX==""} {
      set EQUINOX J2000
   }
   set RADESYS [string trim [lindex [buf$bufNo getkwd RADESYS] 1]]
   if {$RADESYS==""} {
      set RADESYS FK5
   }
   # -- scale
   set kcd 0
   set CD1_1  [lindex [buf$bufNo getkwd CD1_1] 1]
   if {$CD1_1!=""} { incr kcd }
   set CD1_2  [lindex [buf$bufNo getkwd CD1_2] 1]
   if {$CD1_2!=""} { incr kcd }
   set CD2_1  [lindex [buf$bufNo getkwd CD2_1] 1]
   if {$CD2_1!=""} { incr kcd }
   set CD2_2  [lindex [buf$bufNo getkwd CD2_2] 1]
   if {$CD2_2!=""} { incr kcd }
   set kc 0
   set CDELT1 [lindex [buf$bufNo getkwd CDELT1] 1]
   if {$CDELT1!=""} { incr kc }
   set CDELT2 [lindex [buf$bufNo getkwd CDELT2] 1]
   if {$CDELT2!=""} { incr kc }
   set CROTA2 [lindex [buf$bufNo getkwd CROTA2] 1]
   if {$CROTA2!=""} { set CROTA2 0 }
   #console::affiche_resultat "kcd=$kcd kc=$kc\n"
   if {$kcd<4} {
      if {$kc<2} {
         error "Lack of scale keywords"
      }
      lassign [wcs_cdelt2cd $CDELT1 $CDELT2 $CROTA2] CD1_1 CD1_2 CD2_1 CD2_2
   } else {
      #console::affiche_resultat "wcs_cd2cdelt $CD1_1 $CD1_2 $CD2_1 $CD2_2\n"
      lassign [wcs_cd2cdelt $CD1_1 $CD1_2 $CD2_1 $CD2_2] CDELT1 CDELT2 CROTA2
   }
   set wcs [wcs_builder $CRPIX1 $CRPIX2 $CRVAL1 $CRVAL2 $EQUINOX $RADESYS $CDELT1 $CDELT2 $CROTA2 $CD1_1 $CD1_2 $CD2_1 $CD2_2 ]
   # ---
   set FOCLEN [lindex [buf$bufNo getkwd FOCLEN] 1]
   set PIXSIZE1 [lindex [buf$bufNo getkwd PIXSIZE1] 1]
   set PIXSIZE2 [lindex [buf$bufNo getkwd PIXSIZE2] 1]
   set wcs [wcs_update_optic $wcs $PIXSIZE1 $PIXSIZE2 $FOCLEN]
   # ---
   set res [buf$bufNo getkwd WCSMATCH]
   if {[lindex $res 1]!=""} {
      set wcs [wcs_setkwd $wcs [list [string trim [lindex $res 0]] [string trim [lindex $res 1]] [string trim [lindex $res 2]] [string trim [lindex $res 3]] [string trim [lindex $res 4]]]]
   }
   # ---
   set res [buf$bufNo getkwd CTYPE1]
   if {[lindex $res 1]!=""} {
      set wcs [wcs_setkwd $wcs [list [string trim [lindex $res 0]] [string trim [lindex $res 1]] [string trim [lindex $res 2]] [string trim [lindex $res 3]] [string trim [lindex $res 4]]]]
   }
   set res [buf$bufNo getkwd CTYPE2]
   if {[lindex $res 1]!=""} {
      set wcs [wcs_setkwd $wcs [list [string trim [lindex $res 0]] [string trim [lindex $res 1]] [string trim [lindex $res 2]] [string trim [lindex $res 3]] [string trim [lindex $res 4]]]]
   }
   # --- distortion
   for {set axis 1} {$axis<=2} {incr axis} {
      for {set k 0} {$k<=11} {incr k} {
         set res [buf$bufNo getkwd PV${axis}_${k}]
         if {[lindex $res 1]!=""} {
            set wcs [wcs_setkwd $wcs [list [string trim [lindex $res 0]] [string trim [lindex $res 1]] [string trim [lindex $res 2]] [string trim [lindex $res 3]] [string trim [lindex $res 4]]]]
         }
      }
   }
   return $wcs
}

# =================================================================
## @brief focas pair list -> WCS structure
#  @param pairs   résdultats de focas_catastars2pairs
#  @param polydeg degré du polynôme
#  @param xoptc  (optionnel) coordonnées x du centre optique
#  @param yoptc  (optionnel) coordonnées y du centre optique
#  @param date   (optionnel) date TU
#  @param home   (optionnel) coordonnées GPS
#  @return wcs
#
proc wcs_focaspairs2wcs { pairs polydeg {xoptc ""} {yoptc ""} {date ""} {home ""} } {

   #set res [focas_pairs2poly $pairs $polydeg]
   #lassign $res polydeg polys sigma dcoords

   # === determine le centre optique s'il n'a pas ete precise
   # --- on recherche le lieu du centre optique
   set pair [lindex $pairs 1]
   if {($xoptc=="")||($yoptc=="")} {
      # --- on trie par x
      set pair [lsort -real -decreasing -index 0 $pair]
      set xmini [lindex [lindex $pair   0] 0]
      set xmaxi [lindex [lindex $pair end] 0]
      # --- on trie par y
      set pair [lsort -real -decreasing -index 1 $pair]
      set ymini [lindex [lindex $pair   0] 1]
      set ymaxi [lindex [lindex $pair end] 1]
      # --- on calcule le meilleur centre
      set xoptc [expr $xmini+($xmaxi-$xmini)/2]
      set yoptc [expr $ymini+($ymaxi-$ymini)/2]
   }
   #console::affiche_resultat " Optical center = $xoptc $yoptc\n"

   #set methode three_stars ; # three_stars = on prend les trois meilleures etoiles
   set methode morethree_stars ; # morethree_stars = ajustement aux moindres carrÃ©s sur toutes les etoiles avec elminination kappa*sigma
   if {$methode=="three_stars"} {
      # === trouve les trois etoiles les mieux situÃ©es pour calculer le WCS
      # --- on trie par nombre de quartets decroissant
      set couples [lsort -real -decreasing -index 12 $pair]
      # --- on cherche l'Ã©toile la plus proche du centre optique (=fiducial)
      set dist2s ""
      set k 0
      foreach couple $couples {
         lassign $couple x y
         set dx [expr $x-$xoptc]
         set dy [expr $y-$yoptc]
         set dist2 [expr $dx*$dx+$dy*$dy]
         #console::affiche_resultat " k=$k x=$x y=$y dist2=$dist2 [lindex $couple 12]\n"
         lappend dist2s [list $k $dist2]
         incr k
      }
      # --- on trie par distance au centre croissante
      set dist2s [lsort -real -increasing -index 1 $dist2s]
      # --- indice $couples de l'Ã©toile la plus proche du centre (=1 =pole)
      set k1 [lindex [lindex $dist2s 0] 0]
      set couple [lindex $couples $k1]
      lassign $couple xp1 yp1
      #console::affiche_resultat " xp1=$xp1 yp1=$yp1\n"
      # --- on elimine l'Ã©toile la plus centrale de la liste
      set dist2s [lrange $dist2s 1 end]
      # --- on trie par distance au centre dÃ©croissante
      set dist2s [lsort -real -decreasing -index 1 $dist2s]
      # --- indice $couples de l'Ã©toile la plus Ã©loignÃ©e du centre (=2)
      set k2 [lindex [lindex $dist2s 0] 0]
      set couple [lindex $couples $k2]
      lassign $couple xp2 yp2
      set dx2 [expr $xp2-$xoptc]
      set dy2 [expr $yp2-$yoptc]
      set d2 [expr sqrt($dx2*$dx2+$dy2*$dy2)]
      # --- on calcule la perpendicularitÃ© des Ã©toile par rapport Ã  pole-2
      set orthos ""
      for {set k 0} {$k<[llength $couples]} {incr k} {
         set couple [lindex $couples $k]
         lassign $couple x y
         set dx3 [expr $x-$xoptc]
         set dy3 [expr $y-$yoptc]
         set d3 [expr sqrt($dx3*$dx3+$dy3*$dy3)]
         set prod_scal [expr $dx2*$dx3+$dy2*$dy3]
         set cosa [expr $prod_scal/$d2/$d3]
         #console::affiche_resultat " k=$k x=$x y=$y cosa=$cosa d3=$d3\n"
         if {$k==$k1} { continue }
         if {$k==$k2} { continue }
         lappend orthos [list $k [expr abs($cosa)] $d3]
      }
      # --- on trie par perpendicularitÃ© decroissante et distance decroissante pour l'Ã©toile 3
      set orthos [lsort -real -increasing -index 1 $orthos]
      set k3 ""
      for { set r32lim 0.9 } {$r32lim>=0} { set r32lim [expr $r32lim-0.1] } {
         foreach ortho $orthos {
            lassign $ortho k cosa d3
            set r32 [expr $d3/$d2]
            if {($r32>0.5)} {
               set k3 $k
               break
            }
         }
         if {$k3!=""} {
            break
         }
      }
      set couple [lindex $couples $k3]
      lassign $couple xp3 yp3
      # --- on isole les trois etoiles (k1,k2,k3)
      set coords ""
      foreach k [list $k1 $k2 $k3] {
         set couple [lindex $couples $k]
         set x [lindex $couple 0]
         set y [lindex $couple 1]
         lassign [lindex $couple 2] ra_cat dec_cat mag id equinox epoch mura_masyr mudec_masyr plx_mas
         set ra_cat  [lindex [lindex $couple 2] 0]
         set dec_cat [lindex [lindex $couple 2] 1]
         set equinox [lindex [lindex $couple 2] 2]
         if {$equinox==""} {
            set equinox J2000
         }
         if {($date=="")||($home=="")||($epoch=="")||($mura_masyr=="")||($mudec_masyr=="")||($plx_mas=="")} {
            set ra $ra_cat
            set dec $dec_cat
         } else {
            set res [wcs_radec_cat2app $ra_cat $dec_cat $equinox $date $home $epoch 0 0 0 101325 290 40 550]
            lassign $res ra dec
         }
         set ra $ra_cat
         set dec $dec_cat
         lappend coords [list $x $y $ra $dec]
      }

      # === extrait les trois etoiles
      set pi [expr 4*atan(1)]
      set coord [lindex $coords 0]
      lassign $coord px1 py1 ra1 dec1
      set coord [lindex $coords 1]
      lassign $coord px2 py2 ra2 dec2
      set coord [lindex $coords 2]
      lassign $coord px3 py3 ra3 dec3

      # Ref : Calabretta & Greisen (2002) A&A 395, 1077
      set phip $pi
      for {set step 0} {$step<=2} {incr step} {
         if {$step==0} {
            # (xp1,yp1) pris comme pole (fiducial)
            set rap  [expr $ra1*$pi/180]
            set decp [expr $dec1*$pi/180]
            set xp   $px1
            set yp   $py1
         } elseif {$step>=1} {
            # on calcule nouveau le pole avec le coordonnees du centre optique
            lassign  [wcs_p2radec $wcs $xoptc $yoptc] ra dec
            set rap  [expr $ra*$pi/180]
            set decp [expr $dec*$pi/180]
            set xp   $xoptc
            set yp   $yoptc
         }
         #console::affiche_resultat "==== couples\n"
         #console::affiche_resultat "xp=$xp yp=$yp rap=[expr $rap*180/$pi] decp=[expr $decp*180/$pi]\n"
         #console::affiche_resultat "px1=$px1 py1=$py1 ra1=$ra1 dec1=$dec1\n"
         #console::affiche_resultat "px2=$px2 py2=$py2 ra2=$ra2 dec2=$dec2\n"
         #console::affiche_resultat "px3=$px3 py3=$py3 ra3=$ra3 dec3=$dec3\n"
         set sindecp [expr sin($decp)]
         set cosdecp [expr cos($decp)]
         # etoile nÂ°2
         set rar2 [expr $ra2*$pi/180]
         set decr [expr $dec2*$pi/180]
         set sindec2 [expr sin($decr)]
         set cosdec2 [expr cos($decr)]
         set ra $rar2
         set sindec $sindec2
         set cosdec $cosdec2
         set phi21 [expr $phip + atan2( -$cosdec*sin($ra-$rap) , $sindec*$cosdecp-$cosdec*$sindecp*cos($ra-$rap) ) ]
         set theta21 [expr asin( $sindec*$sindecp + $cosdec*$cosdecp*cos($ra-$rap)) ]
         set rth [expr 1./tan($theta21)]
         set x21 [expr  $rth*sin($phi21)]
         set y21 [expr -$rth*cos($phi21)]
         set dpx21 [expr $px2-$xp]
         set dpy21 [expr $py2-$yp]
         # etoile nÂ°3
         set rar3 [expr $ra3*$pi/180]
         set decr [expr $dec3*$pi/180]
         set sindec3 [expr sin($decr)]
         set cosdec3 [expr cos($decr)]
         set ra $rar3
         set sindec $sindec3
         set cosdec $cosdec3
         set phi31 [expr $phip + atan2( -$cosdec*sin($ra-$rap) , $sindec*$cosdecp-$cosdec*$sindecp*cos($ra-$rap) ) ]
         set theta31 [expr asin( $sindec*$sindecp + $cosdec*$cosdecp*cos($ra-$rap)) ]
         set rth [expr 1./tan($theta31)]
         set x31 [expr  $rth*sin($phi31)]
         set y31 [expr -$rth*cos($phi31)]
         set dpx31 [expr $px3-$xp]
         set dpy31 [expr $py3-$yp]
         #
         set b1  $x21
         set a11 $dpx21
         set a12 $dpy21
         set b2  $x31
         set a21 $dpx31
         set a22 $dpy31
         set m [list [list $a11 $a12 ] [list $a21 $a22 ] ]
         set detm [wcs_matrice2x2_determinant $m]
         #console::affiche_resultat "(etoiles 1-2) $b1 = aa * $a11 + bb * $a12\n"
         set m1 [list [list $b1 $a12 ] [list $b2 $a22 ] ]
         set detm1 [wcs_matrice2x2_determinant $m1]
         #console::affiche_resultat "(etoiles 1-3) $b2 = aa * $a21 + bb * $a22\n"
         set m2 [list [list $a11 $b1 ] [list $a21 $b2 ] ]
         set detm2 [wcs_matrice2x2_determinant $m2]
         #console::affiche_resultat "detm=$detm\n"
         if {$detm!=0} {
            set sm11 [expr 1.*$detm1/$detm]
            set sm12 [expr 1.*$detm2/$detm]
         }
         #
         set b1  $y21
         set a11 $dpx21
         set a12 $dpy21
         set b2  $y31
         set a21 $dpx31
         set a22 $dpy31
         set m [list [list $a11 $a12 ] [list $a21 $a22 ] ]
         set detm [wcs_matrice2x2_determinant $m]
         #console::affiche_resultat "(etoiles 1-2) $b1 = aa * $a11 + bb * $a12\n"
         set m1 [list [list $b1 $a12 ] [list $b2 $a22 ] ]
         set detm1 [wcs_matrice2x2_determinant $m1]
         #console::affiche_resultat "(etoiles 1-3) $b2 = aa * $a21 + bb * $a22\n"
         set m2 [list [list $a11 $b1 ] [list $a21 $b2 ] ]
         set detm2 [wcs_matrice2x2_determinant $m2]
         #console::affiche_resultat "detm=$detm\n"
         if {$detm!=0} {
            set sm21 [expr 1.*$detm1/$detm]
            set sm22 [expr 1.*$detm2/$detm]
         }
         #
         #console::affiche_resultat "sm11=$sm11 sm12=$sm12\n"
         #console::affiche_resultat "sm21=$sm21 sm22=$sm22\n"
         # formule (1)
         set CD1_1 [expr $sm11*180/$pi]
         set CD1_2 [expr $sm12*180/$pi]
         set CD2_1 [expr $sm21*180/$pi]
         set CD2_2 [expr $sm22*180/$pi]
         lassign [wcs_cd2cdelt $CD1_1 $CD1_2 $CD2_1 $CD2_2] CDELT1 CDELT2 CROTA2
         set CRPIX1 $xp
         set CRPIX2 $yp
         set CRVAL1 [expr $rap*180/$pi]
         set CRVAL2 [expr $decp*180/$pi]
         set EQUINOX $equinox
         set RADESYS FK5
         set wcs [wcs_builder $CRPIX1 $CRPIX2 $CRVAL1 $CRVAL2 $EQUINOX $RADESYS $CDELT1 $CDELT2 $CROTA2 $CD1_1 $CD1_2 $CD2_1 $CD2_2]
         set wcs [wcs_setkwd $wcs [list WCSMATCH 3 int "Nb catalog stars matched" ""]]
         #wcs_dispkwd $wcs "" public
         # calcule les residus
         lassign [wcs_p2radec $wcs $px1 $py1] ra1c dec1c
         set oc1 [lindex [mc_sepangle $ra1 $dec1 $ra1c $dec1c] 0]
         lassign [wcs_p2radec $wcs $px2 $py2] ra2c dec2c
         #console::affiche_resultat "ra2c=$ra2c dec2c=$dec2c\n"
         set oc2 [lindex [mc_sepangle $ra2 $dec2 $ra2c $dec2c] 0]
         lassign [wcs_p2radec $wcs $px3 $py3] ra3c dec3c
         #console::affiche_resultat "ra3c=$ra3c dec3c=$dec3c\n"
         set oc3 [lindex [mc_sepangle $ra3 $dec3 $ra3c $dec3c] 0]
         #console::affiche_resultat "oc1=[format %.2f [expr $oc1*3600]]\n"
         #console::affiche_resultat "oc2=[format %.2f [expr $oc2*3600]]\n"
         #console::affiche_resultat "oc3=[format %.2f [expr $oc3*3600]]\n"
         set ocs [list [list $k1 $oc1] [list $k2 $oc2] [list $k3 $oc3]]
      }
   }
   if {$methode=="morethree_stars"} {
      # === trouve les trois etoiles les mieux situÃ©es pour calculer le WCS
      # --- on trie par nombre de quartets decroissant
      set couples [lsort -real -decreasing -index 12 $pair]
      # --- on cherche l'Ã©toile la plus proche du centre optique (=fiducial)
      set dist2s ""
      set k 0
      foreach couple $couples {
         lassign $couple x y
         set dx [expr $x-$xoptc]
         set dy [expr $y-$yoptc]
         set dist2 [expr $dx*$dx+$dy*$dy]
         #console::affiche_resultat " k=$k x=$x y=$y dist2=$dist2 [lindex $couple 12]\n"
         lappend dist2s [list $k $dist2]
         incr k
      }
      # --- on trie par distance au centre croissante
      set dist2s [lsort -real -increasing -index 1 $dist2s]
      # --- indice $couples de l'Ã©toile la plus proche du centre (=1 =pole)
      set k1 [lindex [lindex $dist2s 0] 0]
      #console::affiche_resultat " k1=$k1\n"
      # === extrait les etoiles
      # --- on isole toutes les etoiles
      set nc [llength $couples]
      set coords ""
      for {set kc 0} {$kc<$nc} {incr kc} {
         set couple [lindex $couples $kc]
         set x [lindex $couple 0]
         set y [lindex $couple 1]
         lassign [lindex $couple 2] ra_cat dec_cat mag id equinox epoch mura_masyr mudec_masyr plx_mas
         set ra_cat  [lindex [lindex $couple 2] 0]
         set dec_cat [lindex [lindex $couple 2] 1]
         set equinox [lindex [lindex $couple 2] 2]
         set w [lindex $couple 10]
         if {$equinox==""} {
            set equinox J2000
         }
         if {($date=="")||($home=="")||($epoch=="")||($mura_masyr=="")||($mudec_masyr=="")||($plx_mas=="")} {
            set ra $ra_cat
            set dec $dec_cat
         } else {
            set res [wcs_radec_cat2app $ra_cat $dec_cat $equinox $date $home $epoch 0 0 0 101325 290 40 550]
            lassign $res ra dec
         }
         set ra $ra_cat
         set dec $dec_cat
         lappend coords [list $x $y $ra $dec $w]
      }
      set pi [expr 4*atan(1)]
      # Ref : Calabretta & Greisen (2002) A&A 395, 1077
      set phip $pi
      set kbadstars ""
      set stepmax 2
      for {set step 0} {$step<=$stepmax} {incr step} {
         if {$step==0} {
            # (xp1,yp1) pris comme pole (fiducial)
            set coord [lindex $coords $k1]
            lassign $coord px1 py1 ra1 dec1
            set rap  [expr $ra1*$pi/180]
            set decp [expr $dec1*$pi/180]
            set xp   $px1
            set yp   $py1
         } elseif {$step>=1} {
            # on calcule nouveau le pole avec le coordonnees du centre optique
            lassign  [wcs_p2radec $wcs $xoptc $yoptc] ra dec
            set rap  [expr $ra*$pi/180]
            set decp [expr $dec*$pi/180]
            set xp   $xoptc
            set yp   $yoptc
            set k1 -1
         }
         set sindecp [expr sin($decp)]
         set cosdecp [expr cos($decp)]
         set matX ""
         set vecX ""
         set vecY ""
         set vecW ""
         for {set kc 0} {$kc<$nc} {incr kc} {
            if {($kc==$k1)&&($step==0)} {
               continue
            }
            if {[lsearch -integer $kbadstars $kc]>=0} {
               continue
            }
            # etoile nÂ°kc
            set coord [lindex $coords $kc]
            lassign $coord px py ra dec w
            set rar  [expr $ra*$pi/180]
            set decr [expr $dec*$pi/180]
            set sindec [expr sin($decr)]
            set cosdec [expr cos($decr)]
            set ra $rar
            set phi [expr $phip + atan2( -$cosdec*sin($ra-$rap) , $sindec*$cosdecp-$cosdec*$sindecp*cos($ra-$rap) ) ]
            set arg [expr $sindec*$sindecp + $cosdec*$cosdecp*cos($ra-$rap)]
            if {$arg>1.0} {set arg 1.0 }
            if {$arg<-1.0} {set arg -1.0 }
            set theta [expr asin( $arg ) ]
            set rth [expr 1./tan($theta)]
            set x [expr  $rth*sin($phi)]
            set y [expr -$rth*cos($phi)]
            set dpx [expr $px-$xp]
            set dpy [expr $py-$yp]
            # --- Equation dans la matrice
            #console::affiche_resultat "(etoile 1    ) $x1 = aa * $a11 + bb * $a12\n"
            #console::affiche_resultat "(etoile i=$kc) $xi = aa * $ai1 + bb * $ai2\n"
            # trouver aa et bb
            set bi  $x
            set ai1 $dpx
            set ai2 $dpy
            set mat [list $dpx $dpy]
            lappend matX $mat
            lappend vecX $x
            lappend vecY $y
            lappend vecW [expr 1./(0.1+$w)]
         }
         #--- calcul des coefficients du modele
         set resX [gsl_mfitmultilin $vecX $matX $vecW]
         set resY [gsl_mfitmultilin $vecY $matX $vecW]
         #console::affiche_resultat "resX=$resX\n"
         #console::affiche_resultat "resY=$resY\n"
         set reX [lindex $resX 0]
         set sm11 [lindex $reX 0]
         set sm12 [lindex $reX 1]
         set reY [lindex $resY 0]
         set sm21 [lindex $reY 0]
         set sm22 [lindex $reY 1]
         #
         #console::affiche_resultat "sm11=$sm11 sm12=$sm12\n"
         #console::affiche_resultat "sm21=$sm21 sm22=$sm22\n"
         # formule (1)
         set CD1_1 [expr $sm11*180/$pi]
         set CD1_2 [expr $sm12*180/$pi]
         set CD2_1 [expr $sm21*180/$pi]
         set CD2_2 [expr $sm22*180/$pi]
         lassign [wcs_cd2cdelt $CD1_1 $CD1_2 $CD2_1 $CD2_2] CDELT1 CDELT2 CROTA2
         set CRPIX1 $xp
         set CRPIX2 $yp
         set CRVAL1 [expr $rap*180/$pi]
         set CRVAL2 [expr $decp*180/$pi]
         set EQUINOX $equinox
         set RADESYS FK5
         set wcs [wcs_builder $CRPIX1 $CRPIX2 $CRVAL1 $CRVAL2 $EQUINOX $RADESYS $CDELT1 $CDELT2 $CROTA2 $CD1_1 $CD1_2 $CD2_1 $CD2_2]
         #wcs_dispkwd $wcs "" public
         # calcule les residus
         set ocs ""
         set oc2s ""
         for {set kc 0} {$kc<$nc} {incr kc} {
            set coord [lindex $coords $kc]
            lassign $coord px py ra dec w
            lassign [wcs_p2radec $wcs $px $py] rac decc
            set oc [lindex [mc_sepangle $ra $dec $rac $decc] 0]
            lappend ocs [list $kc $oc]
            lappend oc2s $oc
            #console::affiche_resultat "oc$kc=[format %.2f [expr $oc*3600]]\n"
         }
         if {($step>=1)&&($step<=[expr $stepmax-1])} {
            # elimine les etoiles aberrantes
            set sigma [::math::statistics::stdev $oc2s]
            set kappa 3
            set limit [expr $kappa*$sigma]
            set ocs [lsort -real -index 1 -increasing $ocs]
            set cdelt [expr sqrt($CDELT1*$CDELT1+$CDELT2*$CDELT2)] ; # deg/pix
            set nvalid 0
            set oc2s ""
            # console::affiche_resultat "Limit = [format %.2f [expr $limit*3600]]\n"
            foreach loc $ocs {
               lassign $loc kc oc ; # oc (deg)
               set ocpix [expr $oc/$cdelt] ; # oc (pix)
               # console::affiche_resultat "oc = [format %.2f [expr $oc*3600]]  ocpix=$ocpix nvalid=$nvalid\n"
               if {($oc<$limit)||($ocpix<=0)} {
                  incr nvalid
               } else {
                  if {$nvalid>=3} {
                     if {[lsearch -integer $kbadstars $kc]==-1} {
                        # index of a new bad star for astrometry
                        #console::affiche_resultat "Elimine oc$kc=[format %.2f [expr $oc*3600]]\n"
                        lappend kbadstars $kc
                     }
                  }
               }
            }
         }
      }
   }
   set wcsmatch [llength $ocs]
   set wcs [wcs_setkwd $wcs [list WCSMATCH $wcsmatch int "Nb catalog stars matched" ""]]
   # === Distorsions
   if {($polydeg>1)&&($wcsmatch>10)} {
      # ref http://fits.gsfc.nasa.gov/registry/tpvwcs/tpv.html
      # The TPV projection is evaluated as follows.
      #
      # 1. Compute the first order standard coordinates xi and eta from the linear part
      #    of the solution stored in CRPIX and the CD matrix.
      #
      #       xi = CD1_1 * (x - CRPIX1) + CD1_2 * (y - CRPIX2)
      #      eta = CD2_1 * (x - CRPIX1) + CD2_2 * (y - CRPIX2)
      #
      # 2. Apply the distortion transformation using the coefficients in the PV keywords as described below.
      #
      #      xi' = f_xi (xi, eta)
      #     eta' = f_eta (xi, eta)
      #
      # 3. Apply the tangent plane projection to xi' and eta' as described in Calabretta and Greisen .
      #    The reference tangent point given by the CRVAL values lead to the final RA and DEC in degrees.
      #    Note that the units of xi, eta, f_xi, and f_eta are also degrees.
      #
      # The distortion functions shown as f_xi and f_eta above are defined as follows where
      # the variable r is sqrt(xi^2+eta^2). In this convention there are only odd powers of r.
      #
      # xi' = PV1_0 + PV1_1 * xi + PV1_2 * eta + PV1_3 * r +
      #     PV1_4 * xi^2 + PV1_5 * xi * eta + PV1_6 * eta^2 +
      #     PV1_7 * xi^3 + PV1_8 * xi^2 * eta + PV1_9 * xi * eta^2 + PV1_10 * eta^3 + PV1_11 * r^3 +
      #     PV1_12 * xi^4 + PV1_13 * xi^3 * eta + PV1_14 * xi^2 * eta^2 + PV1_15 * xi * eta^3 + PV1_16 * eta^4 +
      #     PV1_17 * xi^5 + PV1_18 * xi^4 * eta + PV1_19 * xi^3 * eta^2 +
      #     PV1_20 * xi^2 * eta^3 + PV1_21 * xi * eta^4 + PV1_22 * eta^5 + PV1_23 * r^5 +
      #     PV1_24 * xi^6 + PV1_25 * xi^5 * eta + PV1_26 * xi^4 * eta^2 + PV1_27 * xi^3 * eta^3 +
      #     PV1_28 * xi^2 * eta^4 + PV1_29 * xi * eta^5 + PV1_30 * eta^6
      #     PV1_31 * xi^7 + PV1_32 * xi^6 * eta + PV1_33 * xi^5 * eta^2 + PV1_34 * xi^4 * eta^3 +
      #     PV1_35 * xi^3 * eta^4 + PV1_36 * xi^2 * eta^5 + PV1_37 * xi * eta^6 + PV1_38 * eta^7 + PV1_39 * r^7
      #
      # eta' = PV2_0 + PV2_1 * eta + PV2_2 * xi + PV2_3 * r +
      #     PV2_4 * eta^2 + PV2_5 * eta * xi + PV2_6 * xi^2 +
      #     PV2_7 * eta^3 + PV2_8 * eta^2 * xi + PV2_9 * eta * xi^2 + PV2_10 * xi^3 + PV2_11 * r^3 +
      #     PV2_12 * eta^4 + PV2_13 * eta^3 * xi + PV2_14 * eta^2 * xi^2 + PV2_15 * eta * xi^3 + PV2_16 * xi^4 +
      #     PV2_17 * eta^5 + PV2_18 * eta^4 * xi + PV2_19 * eta^3 * xi^2 +
      #     PV2_20 * eta^2 * xi^3 + PV2_21 * eta * xi^4 + PV2_22 * xi^5 + PV2_23 * r^5 +
      #     PV2_24 * eta^6 + PV2_25 * eta^5 * xi + PV2_26 * eta^4 * xi^2 + PV2_27 * eta^3 * xi^3 +
      #     PV2_28 * eta^2 * xi^4 + PV2_29 * eta * xi^5 + PV2_30 * xi^6
      #     PV2_31 * eta^7 + PV2_32 * eta^6 * xi + PV2_33 * eta^5 * xi^2 + PV2_34 * eta^4 * xi^3 +
      #     PV2_35 * eta^3 * xi^4 + PV2_36 * eta^2 * xi^5 + PV2_37 * eta * xi^6 + PV2_38 * xi^7 + PV2_39 * r^7
      #
      # Note that missing PV keywords default to 0 except for PV1_1 and PV2_1 which default to 1.
      # With these defaults if there are no PV keywords the transformation is the identity
      # and the TPV WCS is equivalent to the standard TAN projection.
      # Also the defaults mean that the provider need only include the coefficients to the order desired.
      # Similarly, the function may use only terms in powers of r which then mimics the standard ZPN projection.
      #
      # This convention only defines coefficients up to 39 corresponding to a maximum polynomial order of 7.
      #
      # To implement the inverse transformation requires inverting the distortion functions.
      # But using a standard iterative numerical inversion based on the first derivative of the functions
      # is not difficult. The derivatives of these functions are straightforward to express and evaluate.
      set vecXip ""
      set vecEtap ""
      set matX ""
      set vecW ""
      if {($nc<10)&&($polydeg>1)} {
         set polydeg 1
      } elseif {($nc<15)&&($polydeg>2)} {
         set polydeg 2
      } else {
         set polydeg 2
      }
      if {$polydeg>1} {
         for {set kc 0} {$kc<$nc} {incr kc} {
            if {[lsearch -integer $kbadstars $kc]>=0} {
               continue
            }
            # etoile nÂ°kc
            set coord [lindex $coords $kc]
            lassign $coord px py ra dec w
            set rar  [expr $ra*$pi/180]
            set decr [expr $dec*$pi/180]
            set sindec [expr sin($decr)]
            set cosdec [expr cos($decr)]
            set ra $rar
            set phi [expr $phip + atan2( -$cosdec*sin($ra-$rap) , $sindec*$cosdecp-$cosdec*$sindecp*cos($ra-$rap) ) ]
            set theta [expr asin( $sindec*$sindecp + $cosdec*$cosdecp*cos($ra-$rap)) ]
            set rth [expr 1./tan($theta)]
            set x [expr  $rth*sin($phi)*180./$pi] ; # deg
            set y [expr -$rth*cos($phi)*180./$pi] ; # deg
            set dpx [expr $px-$xp]
            set dpy [expr $py-$yp]
            set xi  [expr $CD1_1*$dpx + $CD1_2*$dpy]
            set eta [expr $CD2_1*$dpx + $CD2_2*$dpy]
            set r [expr sqrt($xi*$xi+$eta*$eta)]
            if {$polydeg>=2} {
               set xi2 [expr $xi*$xi]
               set eta2 [expr $eta*$eta]
               set xieta [expr $xi*$eta]
               set r2 [expr $r*$r]
            }
            if {$polydeg>=3} {
               set xi3 [expr $xi2*$xi]
               set eta3 [expr $eta2*$eta]
               set xieta2 [expr $xi*$eta2]
               set xi2eta [expr $xi2*$eta]
               set r3 [expr $r2*$r]
            }
            # --- Equation dans la matrice
            lappend vecXip $x
            lappend vecEtap $y
            set ligX ""
            if {$polydeg>=2} {
               lappend ligX       1 ; # PV1_0 PV2_0
               lappend ligX     $xi ; # PV1_1 PV2_2
               lappend ligX    $eta ; # PV1_2 PV2_1
               lappend ligX      $r ; # PV1_3 PV2_3
               lappend ligX    $xi2 ; # PV1_4 PV2_6
               lappend ligX  $xieta ; # PV1_5 PV2_5
               lappend ligX   $eta2 ; # PV1_6 PV2_4
            }
            if {$polydeg>=3} {
               lappend ligX    $xi3 ; # PV1_7   PV2_10
               lappend ligX $xi2eta ; # PV1_8   PV2_9
               lappend ligX $xieta2 ; # PV1_9   PV2_8
               lappend ligX   $eta3 ; # PV1_10  PV2_7
               lappend ligX     $r3 ; # PV1_11  PV2_11
            }
            lappend matX $ligX
            lappend vecW [expr 1./(1.)]
         }
         #--- calcul des coefficients de distorsion
         set resXi  [gsl_mfitmultilin $vecXip $matX $vecW]
         set resEta [gsl_mfitmultilin $vecEtap $matX $vecW]
         set reXi [lindex $resXi 0]
         set reEta [lindex $resEta 0]
         # --- add kwd
         set wcs [wcs_setkwd $wcs [list CTYPE1 RA---TPV]]
         set wcs [wcs_setkwd $wcs [list CTYPE2 DEC--TPV]]
         if {$polydeg>=2} {
            set wcs [wcs_setkwd $wcs [list PV1_0 [lindex $reXi 0] double "cst" ""]]
            set wcs [wcs_setkwd $wcs [list PV1_1 [lindex $reXi 1] double "x" ""]]
            set wcs [wcs_setkwd $wcs [list PV1_2 [lindex $reXi 2] double "y" ""]]
            set wcs [wcs_setkwd $wcs [list PV1_3 [lindex $reXi 3] double "r" ""]]
            set wcs [wcs_setkwd $wcs [list PV1_4 [lindex $reXi 4] double "x2" ""]]
            set wcs [wcs_setkwd $wcs [list PV1_5 [lindex $reXi 5] double "xy" ""]]
            set wcs [wcs_setkwd $wcs [list PV1_6 [lindex $reXi 6] double "y2" ""]]
            set wcs [wcs_setkwd $wcs [list PV2_0 [lindex $reEta 0] double "cst" ""]]
            set wcs [wcs_setkwd $wcs [list PV2_2 [lindex $reEta 1] double "x" ""]]
            set wcs [wcs_setkwd $wcs [list PV2_1 [lindex $reEta 2] double "y" ""]]
            set wcs [wcs_setkwd $wcs [list PV2_3 [lindex $reEta 3] double "r" ""]]
            set wcs [wcs_setkwd $wcs [list PV2_6 [lindex $reEta 4] double "x2" ""]]
            set wcs [wcs_setkwd $wcs [list PV2_5 [lindex $reEta 5] double "xy" ""]]
            set wcs [wcs_setkwd $wcs [list PV2_4 [lindex $reEta 6] double "y2" ""]]
         }
         if {$polydeg>=3} {
            set wcs [wcs_setkwd $wcs [list PV1_7  [lindex $reXi  7] double "x3" ""]]
            set wcs [wcs_setkwd $wcs [list PV1_8  [lindex $reXi  8] double "x2y" ""]]
            set wcs [wcs_setkwd $wcs [list PV1_9  [lindex $reXi  9] double "xy2" ""]]
            set wcs [wcs_setkwd $wcs [list PV1_10 [lindex $reXi 10] double "y3" ""]]
            set wcs [wcs_setkwd $wcs [list PV1_11 [lindex $reXi 11] double "r3" ""]]
            set wcs [wcs_setkwd $wcs [list PV2_10  [lindex $reEta  7] double "x3" ""]]
            set wcs [wcs_setkwd $wcs [list PV2_9   [lindex $reEta  8] double "x2y" ""]]
            set wcs [wcs_setkwd $wcs [list PV2_8   [lindex $reEta  9] double "xy2" ""]]
            set wcs [wcs_setkwd $wcs [list PV2_7   [lindex $reEta 10] double "y3" ""]]
            set wcs [wcs_setkwd $wcs [list PV2_11  [lindex $reEta 11] double "r3" ""]]
         }
      }
   }
   # ===
   return $wcs
}

# =================================================================
## @brief focas pair list -> WCS structure
#  @param pairs   résdultats de focas_catastars2pairs
#  @param polydeg degré du polynôme
#  @return wcs
#
proc wcs_focaspairswcs2pv { wcs pairs polydeg } {
   lassign [wcs_getkwd $wcs {pi dr CDELT1 CDELT2 PIXSIZE1 PIXSIZE2 FOCLEN}] pi dr CDELT1 CDELT2 PIXSIZE1 PIXSIZE2 FOCLEN
   lassign [wcs_getkwd $wcs {CRPIX1 CRPIX2 CRVAL1 CRVAL2 EQUINOX RADESYS CDELT1 CDELT2 CROTA2 CD1_1 CD1_2 CD2_1 CD2_2}] CRPIX1 CRPIX2 CRVAL1 CRVAL2 EQUINOX RADESYS CDELT1 CDELT2 CROTA2 CD1_1 CD1_2 CD2_1 CD2_2
   set xp $CRPIX1
   set yp $CRPIX2   
   set pair [lindex $pairs 1]
   set couples [lsort -real -decreasing -index 12 $pair]
   set nc [llength $couples]
console::affiche_resultat "ETAPE 1\n"
   if {($polydeg>1)&&($nc>10)} {
      for {set kc 0} {$kc<$nc} {incr kc} {
console::affiche_resultat "ETAPE 10 kc=$kc / $nc\n"
         lassign $couple xs ys coordc idc xc yc fluxs fluxc ks kc totweight ntotvotes ntotquartet
         set px $xs
         set py $ys
         set dpx  [expr $px-$xp]
         set dpy  [expr $py-$yp]
         set xip  [expr $CD1_1*$dpx + $CD1_2*$dpy]
         set etap [expr $CD2_1*$dpx + $CD2_2*$dpy]
         set px $xc
         set py $yc
         set dpx [expr $px-$xp]
         set dpy [expr $py-$yp]
         set xi  [expr $CD1_1*$dpx + $CD1_2*$dpy]
         set eta [expr $CD2_1*$dpx + $CD2_2*$dpy]
         set r [expr sqrt($xi*$xi+$eta*$eta)]
         if {$polydeg>=2} {
            set xi2 [expr $xi*$xi]
            set eta2 [expr $eta*$eta]
            set xieta [expr $xi*$eta]
            set r2 [expr $r*$r]
         }
         if {$polydeg>=3} {
            set xi3 [expr $xi2*$xi]
            set eta3 [expr $eta2*$eta]
            set xieta2 [expr $xi*$eta2]
            set xi2eta [expr $xi2*$eta]
            set r3 [expr $r2*$r]
         }
         # --- Equation dans la matrice
         lappend vecXip $xip
         lappend vecEtap $etap
         set ligX ""
         if {$polydeg>=2} {
            lappend ligX       1 ; # PV1_0 PV2_0
            lappend ligX     $xi ; # PV1_1 PV2_2
            lappend ligX    $eta ; # PV1_2 PV2_1
            lappend ligX      $r ; # PV1_3 PV2_3
            lappend ligX    $xi2 ; # PV1_4 PV2_6
            lappend ligX  $xieta ; # PV1_5 PV2_5
            lappend ligX   $eta2 ; # PV1_6 PV2_4
         }
         if {$polydeg>=3} {
            lappend ligX    $xi3 ; # PV1_7   PV2_10
            lappend ligX $xi2eta ; # PV1_8   PV2_9
            lappend ligX $xieta2 ; # PV1_9   PV2_8
            lappend ligX   $eta3 ; # PV1_10  PV2_7
            lappend ligX     $r3 ; # PV1_11  PV2_11
         }
         lappend matX $ligX
         lappend vecW [expr 1./(1.)]
      }
      #--- calcul des coefficients de distorsion
      set resXi  [gsl_mfitmultilin $vecXip $matX $vecW]
      set resEta [gsl_mfitmultilin $vecEtap $matX $vecW]
      set reXi [lindex $resXi 0]
      set reEta [lindex $resEta 0]
      # --- add kwd
      set wcs [wcs_setkwd $wcs [list CTYPE1 RA---TPV]]
      set wcs [wcs_setkwd $wcs [list CTYPE2 DEC--TPV]]
      if {$polydeg>=2} {
         set wcs [wcs_setkwd $wcs [list PV1_0 [lindex $reXi 0] double "cst" ""]]
         set wcs [wcs_setkwd $wcs [list PV1_1 [lindex $reXi 1] double "x" ""]]
         set wcs [wcs_setkwd $wcs [list PV1_2 [lindex $reXi 2] double "y" ""]]
         set wcs [wcs_setkwd $wcs [list PV1_3 [lindex $reXi 3] double "r" ""]]
         set wcs [wcs_setkwd $wcs [list PV1_4 [lindex $reXi 4] double "x2" ""]]
         set wcs [wcs_setkwd $wcs [list PV1_5 [lindex $reXi 5] double "xy" ""]]
         set wcs [wcs_setkwd $wcs [list PV1_6 [lindex $reXi 6] double "y2" ""]]
         set wcs [wcs_setkwd $wcs [list PV2_0 [lindex $reEta 0] double "cst" ""]]
         set wcs [wcs_setkwd $wcs [list PV2_2 [lindex $reEta 1] double "x" ""]]
         set wcs [wcs_setkwd $wcs [list PV2_1 [lindex $reEta 2] double "y" ""]]
         set wcs [wcs_setkwd $wcs [list PV2_3 [lindex $reEta 3] double "r" ""]]
         set wcs [wcs_setkwd $wcs [list PV2_6 [lindex $reEta 4] double "x2" ""]]
         set wcs [wcs_setkwd $wcs [list PV2_5 [lindex $reEta 5] double "xy" ""]]
         set wcs [wcs_setkwd $wcs [list PV2_4 [lindex $reEta 6] double "y2" ""]]
      }
      if {$polydeg>=3} {
         set wcs [wcs_setkwd $wcs [list PV1_7  [lindex $reXi  7] double "x3" ""]]
         set wcs [wcs_setkwd $wcs [list PV1_8  [lindex $reXi  8] double "x2y" ""]]
         set wcs [wcs_setkwd $wcs [list PV1_9  [lindex $reXi  9] double "xy2" ""]]
         set wcs [wcs_setkwd $wcs [list PV1_10 [lindex $reXi 10] double "y3" ""]]
         set wcs [wcs_setkwd $wcs [list PV1_11 [lindex $reXi 11] double "r3" ""]]
         set wcs [wcs_setkwd $wcs [list PV2_10  [lindex $reEta  7] double "x3" ""]]
         set wcs [wcs_setkwd $wcs [list PV2_9   [lindex $reEta  8] double "x2y" ""]]
         set wcs [wcs_setkwd $wcs [list PV2_8   [lindex $reEta  9] double "xy2" ""]]
         set wcs [wcs_setkwd $wcs [list PV2_7   [lindex $reEta 10] double "y3" ""]]
         set wcs [wcs_setkwd $wcs [list PV2_11  [lindex $reEta 11] double "r3" ""]]
      }
   }
}

# =================================================================
## @brief transfère les mots clés non "private" vers l'image
#  @param wcs structure wcs
#  @param bufNo numéro du buffer, 1 par défaut
#
proc wcs_wcs2buf { wcs {bufNo 1} } {

   foreach wc $wcs {
      set t [lindex $wc 2]
      if {$t!="private"} {
         set err [catch { buf$bufNo setkwd $wc } msg ]
         if {$err==1} {
            error "Keyword $wc. $msg"
         }
      }
   }
}

# =================================================================
# =================================================================
# === Keyword conversions
# =================================================================
# =================================================================

# =================================================================
## @brief convertit CDELT et CROTA2 en CD
#  @details paramètres dans l'ordre CDELT1 CDELT2 CROTA2
#  @remarks conversion inverse de wcs_cd2cdelt
#  @return liste des valeurs de CD1_1 CD1_2 CD2_1 CD2_2
#
proc wcs_cdelt2cd { CDELT1 CDELT2 CROTA2 } {

   set pi [expr 4*atan(1)]
   # formule (193)
   set rho [expr $CROTA2*$pi/180]
   set cosrho [expr cos($rho)]
   set sinrho [expr sin($rho)]
   set CD1_1 [expr  $CDELT1*$cosrho]
   set CD1_2 [expr -$CDELT1*$sinrho]
   set CD2_1 [expr  $CDELT2*$sinrho]
   set CD2_2 [expr  $CDELT2*$cosrho]
   return [list $CD1_1 $CD1_2 $CD2_1 $CD2_2]
}

# =================================================================
## @brief convertit les CD en CDELT et CROTA2
#  @details paramètres dans l'ordre CD1_1 CD1_2 CD2_1 CD2_2
#  @remarks conversion inverse de wcs_cdelt2cd
#  @return liste des valeurs CDELT1 CDELT2 CROTA2
#
proc wcs_cd2cdelt { CD1_1 CD1_2 CD2_1 CD2_2 } {

   # formule (191)
   if {$CD2_1==0} {
      set rhoa 0
   } elseif {$CD2_1<0} {
      set rhoa [expr atan2( -$CD2_1 , -$CD1_1 )]
   } else {
      set rhoa [expr atan2(  $CD2_1 ,  $CD1_1 )]
   }
   if {$CD1_2==0} {
      set rhob 0
   } elseif {$CD1_2<0} {
      set rhob [expr atan2( -$CD1_2 ,  $CD2_2 )]
   } else {
      set rhob [expr atan2(  $CD1_2 , -$CD2_2 )]
   }
   # cas +/-pi
   set drho [expr abs($rhob-$rhoa)]
   set pi [expr 4*atan(1)]
   set pisur2 [expr $pi/2.]
   if {$drho>$pisur2} {
      set rhob [expr $rhob+$pi]
   }
   # formule (192)
   set cosrho [expr (cos($rhoa) + cos($rhob))/2.]
   set sinrho [expr (sin($rhoa) + sin($rhob))/2.]
   set rho [expr atan2( $sinrho , $cosrho )]
   # formule (193)
   set pi [expr 4*atan(1)]
   set CDELT1 [expr $CD1_1 / $cosrho ]
   #console::affiche_resultat "CDELT1=$CDELT1 expr $CD1_1 / $cosrho (rho=$rho)\n"
   set CDELT2 [expr $CD2_2 / $cosrho ]
   set CROTA2 [expr $rho*180/$pi]
   if {$CDELT1>0} {
      set CDELT1 [expr -1*$CDELT1]
      set CDELT2 [expr -1*$CDELT2]
      set CROTA2 [expr $CROTA2+180]
      if {$CROTA2>180} {
         set CROTA2 [expr $CROTA2-360]
      }
   }
   return [list $CDELT1 $CDELT2 $CROTA2]
}

# =================================================================
## @brief complète/modifie une structure wcs avec les mots clés FOCLEN ou PIXSIZE1, PIXSIZE2 ;
#  WCS structure -> update FOCLEN or PIXSIZE1, PIXSIZE2 keywords
#  @details utilise wcs_getkwd et wcs_setkwd
#  @param wcs structure wcs (liste de liste) de mots clés
#  @param pixsize1_mu taille en x des pixels, en microns
#  @param pixsize2_mu taille en y des pixels, en microns
#  @param foclen_m    longueur focale en m
#  @return structure wcs complétée
#
proc wcs_update_optic { wcs {pixsize1_mu ""} {pixsize2_mu ""} {foclen_m ""} } {

   lassign [wcs_getkwd $wcs {pi dr CDELT1 CDELT2 PIXSIZE1 PIXSIZE2 FOCLEN}] pi dr CDELT1 CDELT2 PIXSIZE1 PIXSIZE2 FOCLEN
   set mult 1e-6
   if {($PIXSIZE1!="")&&($PIXSIZE2!="")&&($pixsize1_mu=="")&&($pixsize2_mu=="")&&($foclen_m=="")} {
      set pixsize1_mu $PIXSIZE1
      set pixsize2_mu $PIXSIZE2
      set foclen1_m [expr $pixsize1_mu*$mult/(2.*tan(abs($CDELT1)*$pi/180/2))]
      set foclen2_m [expr $pixsize2_mu*$mult/(2.*tan(abs($CDELT2)*$pi/180/2))]
      set foclen_m [expr ($foclen1_m+$foclen2_m)/2.]
   }
   if {($FOCLEN!="")&&($pixsize1_mu!="")&&($pixsize2_mu!="")&&($foclen_m=="")} {
      set foclen_m $FOCLEN
      set pixsize1_mu [expr $foclen_m/$mult*(2.*tan(abs($CDELT1)*$pi/180/2))]
      set pixsize2_mu [expr $foclen_m/$mult*(2.*tan(abs($CDELT2)*$pi/180/2))]
   }
   if {($pixsize1_mu!="")&&($pixsize2_mu!="")&&($foclen_m!="")} {
      set wcs [wcs_setkwd $wcs [list FOCLEN $foclen_m float "Equivalent focal length" "m"]]
      set wcs [wcs_setkwd $wcs [list PIXSIZE1 $pixsize1_mu float "X Pixel size after binning" "um"]]
      set wcs [wcs_setkwd $wcs [list PIXSIZE2 $pixsize2_mu float "Y Pixel size after binning" "um"]]
   }
   return $wcs
}

# =================================================================
# =================================================================
# === Coordinate transformations
# =================================================================
# =================================================================
## @brief calcule le déterminant de la matrice
#  @param m matrice
#  @return déterminant
#  @private
#
proc wcs_matrice2x2_determinant { m } {

   lassign $m l1 l2
   lassign $l1 a11 a12
   lassign $l2 a21 a22
   set det [expr $a11*$a22-$a21*$a12]
   return $det
}

# =================================================================
## @brief calcule les coordonnées apparentes à partir des coordonnées catalog
#  @code
#  source $audace(rep_install)/gui/audace/wcs_tools.tcl
#  wcs_radec_cat2app 12h45m23s -6d25m32s J2000 now {GPS 5 E 43 1230} 1992.5 0 0 0 101325 290 40 550
#  @endcode
#  @param ra               angle ra HMS
#  @param dec              angle DEC DMS
#  @param equinox          date equinox (J2000)
#  @param date             date ISO 8601, "now" par défaut
#  @param home             cordonnées GPS de l'observateur
#  @param epoch            "" par défaut
#  @param mura_masyr       0 par défaut
#  @param mudec_masyr      0 par défaut
#  @param plx_mas          0 par défaut
#  @param pressure_Pa      pression atmosphérique Pa, 101325 par défaut
#  @param temperature_K    température °K, 290 par défaut
#  @param humidity_percent % humidité, 40 par défaut
#  @param wavelength_nm    longueur d'onde, 550 par défaut
#  @return liste ra dec ha az elev corrigées
#
proc wcs_radec_cat2app { ra dec equinox date home {epoch ""} {mura_masyr 0} {mudec_masyr 0} {plx_mas 0} {pressure_Pa 101325} {temperature_K 290} {humidity_percent 40} {wavelength_nm 550} } {

   if {$epoch==""} {
      set epoch $date
   }
   set hip [list 1 0 [mc_angle2deg $ra] [mc_angle2deg $dec 90] $equinox $epoch $mura_masyr $mudec_masyr $plx_mas]
   set res [mc_hip2tel $hip $date $home $pressure_Pa $temperature_K ] ; #-humidity $humidity_percent -wavelength $wavelength_nm]
   lassign $res ra dec ha az elev
   return [list $ra $dec $ha $az $elev]
}

# =================================================================
## @brief transforme les coordonnées ra et dec en coordonnées catalogue
#  pour un TypeObs=EQUATORIAL
#  @code
#  source $audace(rep_install)/gui/audace/wcs_tools.tcl
#  wcs_radec_app2cat 12h45m23s -6d25m32s now {GPS 5 E 43 1230} 101325 290 40 550
#  @endcode
#  @param ra               angle ra
#  @param dec              angle DEC
#  @param date             date ISO 8601
#  @param home             cordonnées GPS de l'observateur
#  @param pressure_Pa      pression atmosphérique Pa, 101325 par défaut
#  @param temperature_K    température °K, 290 par défaut
#  @param humidity_percent % humidité, 40 par défaut
#  @param wavelength_nm    longueur d'onde, 550 par défaut
#  @return liste ra dec
#
proc wcs_radec_app2cat { ra dec date home {pressure_Pa 101325} {temperature_K 290} {humidity_percent 40} {wavelength_nm 550} } {

   set res [mc_tel2cat [list $ra $dec] EQUATORIAL $date $home $pressure_Pa $temperature_K -humidity $humidity_percent -wavelength $wavelength_nm]
   return [list $ra $dec]
}

# =================================================================
# Transform (xi,eta) ---(PV*_*)---> (xip,etap)
# -----------------------------------------------------------------
proc wcs_distorsion_compute { wcs xi eta} {

   lassign [wcs_getkwd $wcs {CTYPE1 CTYPE2}] CTYPE1 CTYPE2
   set xip $xi
   set etap $eta
   if {($CTYPE1=="RA---TPV")&&($CTYPE2=="DEC--TPV")} {
      #
      lassign [wcs_getkwd $wcs {PV1_0 PV1_1 PV1_2 PV1_3 PV1_4 PV1_5 PV1_6}] PV1_0 PV1_1 PV1_2 PV1_3 PV1_4 PV1_5 PV1_6
      lassign [wcs_getkwd $wcs {PV2_0 PV2_1 PV2_2 PV2_3 PV2_4 PV2_5 PV2_6}] PV2_0 PV2_1 PV2_2 PV2_3 PV2_4 PV2_5 PV2_6
      if {($PV1_0!="")&&($PV1_1!="")&&($PV1_2!="")&&($PV1_3!="")&&($PV1_4!="")&&($PV1_5!="")&&($PV1_6!="")&&($PV2_0!="")&&($PV2_1!="")&&($PV2_2!="")&&($PV2_3!="")&&($PV2_4!="")&&($PV2_5!="")&&($PV2_6!="")} {
         set xip 0
         set etap 0
         set xi  $x1
         set eta $x2
         set r [expr sqrt($xi*$xi+$eta*$eta)]
         set xi2 [expr $xi*$xi]
         set eta2 [expr $eta*$eta]
         set xieta [expr $xi*$eta]
         set r2 [expr $r*$r]
         set xip  [expr $xip + $PV1_0 + $PV1_1*$xi+ $PV1_2*$eta + $PV1_3*$r]
         set xip  [expr $xip + $PV1_4*$xi2 + $PV1_5*$xieta + $PV1_6*$eta2]
         set etap [expr $etap + $PV2_0 + $PV2_1*$xi+ $PV2_2*$eta + $PV2_3*$r]
         set etap [expr $etap + $PV2_6*$xi2 + $PV2_5*$xieta + $PV2_4*$eta2]
         #
         lassign [wcs_getkwd $wcs {PV1_7 PV1_8 PV1_9 PV1_10 PV1_11}] PV1_7 PV1_8 PV1_9 PV1_10 PV1_11
         lassign [wcs_getkwd $wcs {PV2_7 PV2_8 PV2_9 PV2_10 PV2_11}] PV2_7 PV2_8 PV2_9 PV2_10 PV2_11
         if {($PV1_7!="")&&($PV1_8!="")&&($PV1_9!="")&&($PV1_10!="")&&($PV1_11!="")&&($PV2_7!="")&&($PV2_8!="")&&($PV2_9!="")&&($PV2_10!="")&&($PV2_11!="")} {
            set xi3 [expr $xi2*$xi]
            set eta3 [expr $eta2*$eta]
            set xieta2 [expr $xi*$eta2]
            set xi2eta [expr $xi2*$eta]
            set r3 [expr $r2*$r]
            set xip  [expr $xip  + $PV1_7*$xi3 + $PV1_8*$xi2eta + $PV1_9*$xieta2 + $PV1_10*$eta3 + $PV1_11*$r3]
            set etap [expr $etap + $PV2_10*$xi3 + $PV2_9*$xi2eta + $PV2_8*$xieta2 + $PV2_7*$eta3 + $PV2_11*$r3]
         }
      }
   }
   return [list $xip $etap]
}

# =================================================================
## @brief convertit les coordonnées {x,y} en coordonnées apparentes {ra,dec}
#  pixel -> apparent radec
#  @details utilise wcs_distorsion_compute
#  @remarks conversion inverse de wcs_radec2p
#  @param wcs structure wcs complète
#  @param p1 coordonnées pixels en x
#  @param p2 coordonnées pixels en y
#  @return liste RA et DEC en degrés
#
proc wcs_p2radec { wcs p1 p2 } {
   lassign [wcs_getkwd $wcs {rap decp r1 r2 sm11 sm12 sm21 sm22 pi dr cosdecp sindecp phip}] rap decp r1 r2 sm11 sm12 sm21 sm22 pi dr cosdecp sindecp phip
   #
   set x1 [expr $sm11*($p1-$r1) + $sm12*($p2-$r2)]
   set x2 [expr $sm21*($p1-$r1) + $sm22*($p2-$r2)]
   lassign [wcs_distorsion_compute $wcs $x1 $x2] x1 x2
   set phi [expr atan2($x1,-$x2)]
   set rth [expr sqrt($x1*$x1+$x2*$x2)]
   set theta [expr atan(1./$rth)]
   set sinth [expr sin($theta)]
   set costh [expr cos($theta)]
   set sindec [expr $sinth*$sindecp+$costh*$cosdecp*cos($phi-$phip)]
   set cosdec [expr sqrt(1.-$sindec*$sindec)]
   set dec [expr asin($sindec)]
   set cosdecsinrarap [expr -$costh*sin($phi-$phip)]
   set cosdeccosrarap [expr ($sinth*$cosdecp-$costh*$sindecp*cos($phi-$phip))]
   set rarap [expr atan2($cosdecsinrarap,$cosdeccosrarap)]
   set ra [expr $rarap + $rap]
   set ra [expr fmod(${ra}*180/$pi+720,360)]
   set dec [mc_angle2deg ${dec}r 90]
   return [list $ra $dec] ; # deg
}

# =================================================================
## @brief convertit les coordonnées apparentes {ra,dec} en coordonnées {x,y}
#  apparent radec -> pixel
#  @details utilise wcs_distorsion_compute
#  @remarks conversion inverse de wcs_p2radec
#  @param wcs structure wcs complète
#  @param ra angle ra HMS ou degrés
#  @param dec angle dec DMS ou degrés
#  @return liste des coordonnées x et y, en pixels
#
proc wcs_radec2p { wcs ra dec } {
   lassign [wcs_getkwd $wcs {rap decp r1 r2 sm11 sm12 sm21 sm22 pi dr cosdecp sindecp phip}] rap decp r1 r2 sm11 sm12 sm21 sm22 pi dr cosdecp sindecp phip
   #
   set ra [mc_angle2rad ${ra}]
   set dec [mc_angle2rad ${dec} 90]
   set cosdec [expr cos($dec)]
   set sindec [expr sin($dec)]
   set sinth [expr $sindec*$sindecp+$cosdec*$cosdecp*cos($ra-$rap)]
   set costh [expr sqrt(1.-$sinth*$sinth)]
   set costhsinphiphip [expr -$cosdec*sin($ra-$rap)]
   set costhcosphiphip [expr ($sindec*$cosdecp-$cosdec*$sindecp*cos($ra-$rap))]
   set phiphip [expr atan2($costhsinphiphip,$costhcosphiphip)]
   set phi [expr $phiphip + $phip]
   set theta [expr atan2($sinth,$costh)]
   set tantheta [expr $sinth/$costh]
   set rth [expr 1./$tantheta]
   set x1 [expr  $rth*sin($phi)]
   set x2 [expr -$rth*cos($phi)]
   lassign [wcs_distorsion_compute $wcs $x1 $x2] xx1 xx2
   if {($x1==$xx1)&&($x2==$xx2)} {
   } else {
      # --- iteration
      set dx1 [expr $xx1-$x1]
      set dx2 [expr $xx2-$x2]
      set x1 [expr $x1-$dx1]
      set x2 [expr $x2-$dx2]
      lassign [wcs_distorsion_compute $wcs $x1 $x2] x1 x2
   }
   #set x1 [expr $sm11*($p1-$r1) + $sm12*($p2-$r2)]
   #set x2 [expr $sm21*($p1-$r1) + $sm22*($p2-$r2)]
   # ===
   # m21*x1 = m21*m11 *pr1 + m21*m12 *pr2
   # m11*x2 = m21*m11 *pr1 + m11*m22 *pr2
   # ---
   # m21*x1 - m11*x2 = (m21*m12 - m11*m22) * pr2
   # ===
   # m22*x1 = m22*m11 *pr1 + m22*m12 *pr2
   # m12*x2 = m12*m21 *pr1 + m12*m22 *pr2
   # ---
   # m22*x1 - m12*x2 = (m22*m11 - m12*m21) * pr1
   set pr1 [expr ($sm22*$x1 - $sm12*$x2) / ($sm22*$sm11 - $sm12*$sm21) ]
   set pr2 [expr ($sm21*$x1 - $sm11*$x2) / ($sm21*$sm12 - $sm11*$sm22) ]
   set p1 [expr $pr1+$r1]
   set p2 [expr $pr2+$r2]
   return [list $p1 $p2] ; # pix
}

# =================================================================
## @brief convertit les coordonnées pixels en coordonnées catalogue {ra dec}
#  pixel -> catalog radec
#  @details utilise wcs_getkwd, wcs_p2radec et wcs_radec_app2cat
#  @remarks conversion inverse de wcs_xy2radec
#  @param wcs structure wcs complète
#  @param p1 coordonnées pixels en x
#  @param p2 coordonnées pixels en y
#  @param equinox J2000 par défaut
#  @return liste des coordonnées ra et dec en degrés
#
proc wcs_xy2radec { wcs p1 p2 {equinox J2000} } {

   lassign [wcs_getkwd $wcs {EQUINOX }] EQUINOX
   lassign [wcs_p2radec $wcs $p1 $p2] ra dec
   if {$EQUINOX!=$equinox} {
      lassign [wcs_getkwd $wcs {date home pressure_Pa temperature_K humidity_percent wavelength_nm}] date home pressure_Pa temperature_K humidity_percent wavelength_nm
      lassign [wcs_radec_app2cat $ra $dec $date $home $pressure_Pa $temperature_K $humidity_percent $wavelength_nm] ra dec
   }
   return [list $ra $dec]
}

# =================================================================
## @brief convertit les coordonnées catalogue {ra,dec} en coordonnées apparentes {x,y}
#  catalog radec -> pixel
#  @details utilise wcs_getkwd, wcs_radec_cat2app et wcs_radec2p
#  @remarks conversion inverse de wcs_xy2radec
#  @param wcs structure wcs complète
#  @param ra angle ra HMS ou degrés
#  @param dec angle dec DMS ou degrés
#  @param equinox J2000 par défaut
#  @return liste des coordonnées x et y, en pixels
#
proc wcs_radec2xy { wcs ra dec {equinox J2000} } {

   lassign [wcs_getkwd $wcs {EQUINOX }] EQUINOX
   if {$EQUINOX!=$equinox} {
      lassign [wcs_getkwd $wcs {date home pressure_Pa temperature_K humidity_percent wavelength_nm}] date home pressure_Pa temperature_K humidity_percent wavelength_nm
      lassign [wcs_radec_cat2app $ra $dec $EQUINOX $date $home "" 0 0 0 $pressure_Pa $temperature_K $humidity_percent $wavelength_nm]
   }
   lassign [wcs_radec2p $wcs $ra $dec] p1 p2
   return [list $p1 $p2]
}

# =================================================================
# =================================================================
# === miscelaneous
# =================================================================
# =================================================================

# =================================================================
## @brief édite la liste des étoiles et créé un graphique
#  wcs + buf + catalog -> star list + plot
#  @code
#  set ra 0 ; set dec 90; # @pole N at internbal date now
#  set wcs [wcs_optic2wcs 30 120 $ra $dec 8.6 8.4 0.140 0]
#  wcs_plot_catalog $wcs 1 1024 1024 usnoa2 c:/d/usno/ 5
#  @endcode
#  @param wcs structure wcs
#  @param bufNo numéro du buffer
#  @param naxis1 dimension de l'image en x
#  @param naxis2 dimension de l'image en y
#  @param catalog nom du catalogue
#  @param path chemin du catalogue
#  @param mag_faint magnitude minimale
#
proc wcs_plot_catalog { wcs bufNo naxis1 naxis2 catalog path mag_faint } {

   # ------
   buf$bufNo new CLASS_GRAY $naxis1 $naxis2 FORMAT_SHORT COMPRESS_NONE
   set dateobs [mc_date2iso8601 now]
   set commande "buf$bufNo setkwd \{ \"DATE-OBS\" \"$dateobs\" \"string\" \"Begining of exposure UT\" \"Iso 8601\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufNo setkwd \{ \"NAXIS\" \"2\" \"int\" \"\" \"\" \}"
   set err1 [catch {eval $commande} msg]
   wcs_wcs2buf $wcs $bufNo

   # ------
   set xc [expr $naxis1/2.]
   set yc [expr $naxis2/2.]
   set radec [wcs_p2radec $wcs $xc $yc]
   lassign $radec ra0 dec0
   set corners [list [list 0 0] [list $naxis1 0] [list 0 $naxis2] [list $naxis1 $naxis2]]
   set sepangles ""
   foreach corner $corners {
      set xc [lindex $corner 0]
      set yc [lindex $corner 1]
      set radec [wcs_p2radec $wcs $xc $yc]
      lassign $radec ra dec
      set sepangle [lindex [mc_sepangle $ra0 $dec0 $ra $dec] 0]
      lappend sepangles $sepangle
   }
   set radius [expr 60.*[lindex [lsort -real -decreasing $sepangles] 0] ]
   # ------
   set mag_bright -10
   #-- securite
   set catalog [string tolower $catalog]
   #-- indispensable
   load [file join $::audace(rep_install) bin libcatalog_tcl[info sharedlibextension]]
   set command "cs${catalog} $path $ra0 $dec0 $radius $mag_faint $mag_bright"
   set res [eval $command]
   lassign $res infos stars
   #console::affiche_resultat "$infos\n"
   # ------
   set star0s ""
   foreach star $stars {
      set res [lindex [lindex $star 0] 2]
      #console::affiche_resultat "$res\n"
      set id [lindex $res 0]
      set ra [lindex $res 1]
      set dec [lindex $res 2]
      set magr [lindex $res 7]
      set magb [lindex $res 6]
      lassign [wcs_radec2p $wcs $ra $dec] x y
      set star0 [list $x $y $ra $dec $magb $magr]
      # console::affiche_resultat "$ra $dec $magb $magr"
      if {($magb=="0.10")&&($magr=="0.10")} {
         set magb $mag_faint
         set magr $mag_faint
         console::affiche_resultat "$id ${star0} *\n"
      }
      if {($x<0)||($x>$naxis1)||($y<0)||($y>$naxis2)} {
         console::affiche_resultat "$id ${star0} >\n"
         continue
      }
      set star0 [list $x $y $ra $dec $magb $magr]
      console::affiche_resultat "$id ${star0} **\n"
      lappend star0s $star0
   }
   set stars $star0s
   # ------
   plotxy::clf 1
   plotxy::figure 1
   set ns [llength $stars]
   for {set k1 0} {$k1<$ns} {incr k1} {
      lassign [lindex $stars $k1] x1 y1 ra1 dec1 magb magr
      set mag $magr
      set rayon [expr 1+int((21-$mag)/2.)]
      plotxy::plot $x1 $y1 "or" $rayon
      plotxy::hold on
   }
   plotxy::xlabel "columns (pixels)"
   plotxy::ylabel "lines (pixels)"
}

