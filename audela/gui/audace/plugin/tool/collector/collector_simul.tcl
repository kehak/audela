#
## @file collector_simul.tcl
#  @brief Créé des images de synthèse à l'aide de simulimage (surchaud.tcl)
#  @author Raymond Zachantke
#  $Id: collector_simul.tcl 13294 2016-03-02 21:09:48Z rzachantke $
#

   #--   Liste des proc liees a la simulation
   # nom proc                       utilisee par
   # ::collector::cmdSynthetiser    Commande du bouton 'Synthetiser' et magic
   # ::collector::cmdMagic          Commande du bouton 'Baguette magique'
   # ::collector::createImg         synthetiser
   # ::collector::magic             createSpecial
   # ::collector::createKeywords    magic et setKeywords
   # ::collector::formatKeyword     createKeywords
   # ::collector::setKeywords       magic
   # ::collector::calibrationAstro  magic et updateDSSData
   # ::collector::editKeywords      Commande du bouton 'Editer les mots cles dans la console'

   #------------------------------------------------------------
   ## @brief commande du bouton 'Synthétiser'
   #  @param visuNo numéro de la visu
   #
   proc ::collector::cmdApplySynthetiser { visuNo } {
      variable private

      #--   inhibe les boutons
      ::collector::configButtons disabled
      update

      #--   force Observer
      set private(observer) "Simulimage"

      lassign $private(match_wcs) match_wcs ra dec pixsize1 pixsize2 foclen

      if {$match_wcs != 0} {
         if {[catch {createImg $ra $dec $pixsize1 $pixsize2 $foclen $private(fwhm) $private(catname) $private(catAcc) } ErrInfo]} {
            #--   efface le buffer
            ::confVisu::deleteImage $visuNo
            ::console::affiche_resultat "$ErrInfo"
         }
      }

      #--   desinhibe les boutons
      ::collector::configButtons !disabled
      update
   }

   #------------------------------------------------------------
   ## @brief commande du bouton 'Baguette magique'
   #  @param visuNo numéro de la visu
   #  @param w      chemin du bouton
   #
   proc ::collector::cmdApplyMagic { visuNo w } {
      variable private

      $w configure -image $private(chaudron)
      update

      ::collector::magic $visuNo

      $w configure -image $private(baguette)
      ::collector::configButtons !disabled
      update
   }

   #------------------------------------------------------------
   #  brief créé l'image de synthèse
   #
   #          paramètres de simulimage dans surchaud.tcl
   #  param Angle_ra
   #  param Angle_dec
   #  param valpixsize1
   #  param valpixsize2
   #  param valfoclen
   #  param fwhm
   #  param cat_format
   #  param cat_folder
   #
   proc ::collector::createImg { Angle_ra Angle_dec valpixsize1 valpixsize2 valfoclen fwhm cat_format cat_folder } {
      global audace conf

      set shutter_mode 1
      set bias_level 0
      set flat_type 0

      simulimage $Angle_ra $Angle_dec $valpixsize1 $valpixsize2 $valfoclen \
         $cat_format $cat_folder $audace(etc,input,ccd,t) $fwhm $audace(etc,param,optic,D) \
         $audace(etc,param,object,band) $audace(etc,param,local,msky) \
         $audace(etc,param,ccd,eta) $audace(etc,param,ccd,G) \
         $audace(etc,param,ccd,N_ro) $shutter_mode $bias_level \
         $audace(etc,param,ccd,C_th) $audace(etc,comp1,Tatm) \
         $audace(etc,param,optic,Topt) $audace(etc,param,ccd,Em) $flat_type

      convgauss 2.0
      buf[visu$audace(visuNo) buf] bitpix float

      #--   sauve l'image myImg
      saveima [file join $audace(rep_images) myImg$::conf(extension,defaut)]
   }

   #------------------------------------------------------------
   #  brief gère la création de l'image
   #  param visuNo numéro de la visu
   #
   proc ::collector::magic { visuNo } {
      variable private
      variable myKeywords
      global audace caption

      set bufNo [visu$audace(visuNo) buf]
      set ext $::conf(extension,defaut)
      set naxis1 $private(naxis1)
      set naxis2 $private(naxis2)
      set img_name [file join $audace(rep_images) myImg$ext]

      ::collector::createKeywords

      visu$audace(visuNo) clear
      ::confVisu::setZoom 1 0.5

      buf$bufNo setpixels CLASS_GRAY $naxis1 $naxis2 FORMAT_USHORT COMPRESS_NONE 0
      ::collector::setKeywords $bufNo

      saveima $img_name
      ::confVisu::setFileName $visuNo $img_name
      #visu$audace(visuNo) disp

      set private(match_wcs) [list 2 * * * * * ]

      ::collector::cmdApplySynthetiser $visuNo

      #--   Reinhibe les boutons
      ::collector::configButtons disabled
      update

      #--   pm simulimage cree les mots cles EQUINOX RADESYS CTYPE1 CTYPE2 CUNIT1 CUNIT2 LONPOLE CATASTAR
      #--   pb avec RADESYS dans surchaud
      catch {buf$bufNo delkwd RADESYS}
      ::collector::calibrationAstro $bufNo $ext $private(catAcc) $private(catname)
   }

   #------------------------------------------------------------
   #  brief créé un array avec tous les mots clés
   #
   proc ::collector::createKeywords { } {
      variable private
      variable myKeywords

      set list_of_kwd [list BIN1 BIN2 NAXIS1 NAXIS2 RA DEC CRVAL1 CRVAL2 CRPIX1 CRPIX2 \
         DATE-OBS MJD-OBS EXPOSURE FOCLEN CROTA2 FILTER FILTERNU FWHM \
         PIXSIZE1 PIXSIZE2 CDELT1 CDELT2 CD1_1 CD1_2 CD2_1 CD2_2 \
         PRESSURE TEMP HUMIDITY DETNAM CONFNAME IMAGETYP OBJNAME SWCREATE]

      #--   raccourcis
      foreach var [list ra dec gps t tu jd tsl telescop aptdia foclen fwhm \
         bin1 bin2 naxis1 naxis2 cdelt1 cdelt2 crota2 filter \
         detnam photocell1 photocell2 isospeed pixsize1 pixsize2 \
         crval1 crval2 crpix1 crpix2 \
         pressure temperature temprose humidity winddir windsp \
         observer sitename origin iau_code imagetyp objname] {
         set $var $private($var)
         #::console::affiche_resultat "$var \"$private($var)\"\n"
      }

      set ra [mc_angle2deg $ra]
      set dec [mc_angle2deg $dec]
      set pressure [expr { $pressure / 100. }]
      set temp $temperature

      #--   passe de arcsec en degres
      set cdelt1 [expr { $cdelt1 / 3600. }]
      set cdelt2 [expr { $cdelt2 / 3600. }]

      set filternu 1

      if {$gps ne "-"} {
         lassign $gps -> obs-long sens obs-lat obs-elev
         if {$sens eq "W"} {
            set obs-long -${obs-long}
         }
         lassign [obsCoord2SiteCoord "$gps"] sitelong sitelat siteelev
         set geodsys WGS84
         lappend list_of_kwd OBS-ELEV OBS-LAT OBS-LONG SITELONG SITELAT SITEELEV GEODSYS
      }

      set date-obs $tu
      set mjd-obs [expr { $jd-2400000.5 }]
      set exposure $t

      lassign [mc_radec2altaz $ra $dec $gps ${date-obs}] elev
      lassign [getCD $cdelt1 $cdelt2 $crota2] cd1_1 cd1_2 cd2_1 cd2_2

      set swcreate "[::audela::getPluginTitle] $::audela(version)"
      set confname "myConf"

      #--   complete la liste des mots cles si leur valeur significative
      set optKwd [list aptdia "-" isospeed "-" humidity "-" iau_code "" \
         observer "-" origin "" sitename "-" telescop "-" temprose "-" \
         winddir "-" windsp "-"]
      foreach {var val} $optKwd {
         if {[set $var] ne "$val"} {
            lappend list_of_kwd [string toupper $var]
         }
      }

      #--   liste les caracteres a substituer
      set entities [list à a â a ç c é e è e ê e ë e î i ï i ô o ö o û u ü u ü u ' ""]

      foreach kwd $list_of_kwd {
         set val [set [string tolower ${kwd}]]
         set sentence [formatKeyword $kwd]
         if {[lindex $sentence 2] eq "string"} {
            #--   remplace la caracteres accentues par les non accentues
            #--   et transforme le string en liste
            set val [list [string map -nocase $entities $val]]
         }
         array set myKeywords [list $kwd [format $sentence $val] ]
      }
   }

   #------------------------------------------------------------
   #  brief formate un mot clé à partir du dictionnaire
   #  param kwd nom du mot clé ; renvoie la liste si kwd est égal à ""
   #
   proc ::collector::formatKeyword { {kwd " "} } {

      dict set dicokwd APTDIA    {APTDIA %s float Diameter m}
      dict set dicokwd BIN1      {BIN1 %s int {} {}}
      dict set dicokwd BIN2      {BIN2 %s int {} {}}
      dict set dicokwd CD1_1     {CD1_1 %s double {Coord. transf. matrix CD11} deg/pixel}
      dict set dicokwd CD1_2     {CD1_2 %s double {Coord. transf. matrix CD12} deg/pixel}
      dict set dicokwd CD2_1     {CD2_1 %s double {Coord. transf. matrix CD21} deg/pixel}
      dict set dicokwd CD2_2     {CD2_2 %s double {Coord. transf. matrix CD22} deg/pixel}
      dict set dicokwd CDELT1    {CDELT1 %s double {Scale along Naxis1} deg/pixel}
      dict set dicokwd CDELT2    {CDELT2 %s double {Scale along Naxis2} deg/pixel}
      dict set dicokwd CONFNAME  {CONFNAME %s string {Instrument Setup} {}}
      dict set dicokwd CROTA2    {CROTA2 %s double {Position angle of North} deg}
      dict set dicokwd CRPIX1    {CRPIX1 %s double {Reference pixel for Naxis1} pixel}
      dict set dicokwd CRPIX2    {CRPIX2 %s double {Reference pixel for Naxis2} pixel}
      dict set dicokwd CRVAL1    {CRVAL1 %s double {Reference coordinate for Naxis1} deg}
      dict set dicokwd CRVAL2    {CRVAL2 %s double {Reference coordinate for Naxis2} deg}
      dict set dicokwd DATE-OBS  {DATE-OBS %s string {Start of exposure.FITS standard} {ISO 8601}}
      dict set dicokwd DEC       {DEC %s double {Expected DEC asked to telescope} {deg}}
      dict set dicokwd DETNAM    {DETNAM %s string {Camera used} {}}
      dict set dicokwd EGAIN     {EGAIN %s float {electronic gain in} {e/ADU}}
      dict set dicokwd EQUINOX   {EQUINOX %s string {System of equatorial coordinates} {}}
      dict set dicokwd EXPOSURE  {EXPOSURE %s float {Total time of exposure} s}
      dict set dicokwd EXPTIME   {EXPTIME %s float {Exposure Time} s}
      dict set dicokwd FILTER    {FILTER %s string {C U B V R I J H K z} {}}
      dict set dicokwd FILTERNU  {FILTERNU %s int {Filter number} {}}
      dict set dicokwd FOCLEN    {FOCLEN %s float {Resulting Focal length} m}
      dict set dicokwd FWHM      {FWHM %s float {Full Width at Half Maximum} pixels}
      dict set dicokwd GEODSYS   {GEODSYS %s string {Geodetic datum for observatory position} {}}
      dict set dicokwd HUMIDITY  {HUMIDITY %s float {Hygrometry} percent}
      dict set dicokwd IAU_CODE  {IAU_CODE %s string {IAU Code for the observatory} {}}
      dict set dicokwd IMAGETYP  {IMAGETYP %s string {Image Type} {}}
      dict set dicokwd INSTRUME  {INSTRUME %s string {Camera used} {}}
      dict set dicokwd ISOSPEED  {ISOSPEED %s int {ISO camera setting} {ISO}}
      dict set dicokwd MJD-OBS   {MJD-OBS %s double {Start of exposure} d}
      dict set dicokwd NAXIS1    {NAXIS1 %s int {Length of data axis 1} {}}
      dict set dicokwd NAXIS2    {NAXIS2 %s int {Length of data axis 2} {}}
      dict set dicokwd NBSTARS   {NBSTARS %s int {Nb of stars detected by Sextractor} {}}
      dict set dicokwd OBJECT    {OBJECT %s string {Object observed} {}}
      dict set dicokwd OBJEKEY   {OBJEKEY %s string {Link key for objefile} {}}
      dict set dicokwd OBJNAME   {OBJNAME %s string {Object Name} {}}
      dict set dicokwd OBS-ELEV  {OBS-ELEV %s float {Elevation above sea of observatory} m}
      dict set dicokwd OBS-LAT   {OBS-LAT %s float {Geodetic observatory latitude} deg}
      dict set dicokwd OBS-LONG  {OBS-LONG %s float {East-positive observatory longitude} deg}
      dict set dicokwd OBSERVER  {OBSERVER %s string {Observers Names} {}}
      dict set dicokwd ORIGIN    {ORIGIN %s string {Organization Name} {}}
      dict set dicokwd PEDESTAL  {PEDESTAL %s int {add this value to each pixel value} {}}
      dict set dicokwd PIXSIZE1  {PIXSIZE1 %s float {Pixel Width (with binning)} mum}
      dict set dicokwd PIXSIZE2  {PIXSIZE2 %s float {Pixel Height (with binning)} mum}
      dict set dicokwd PRESSURE  {PRESSURE %s float {[hPa] Atmospheric Pressure} hPa}
      dict set dicokwd RA        {RA %s double {Expected RA asked to telescope} {deg}}
      dict set dicokwd RADESYS   {RADESYS %s string {Mean Place IAU 1984 system} {}}
      dict set dicokwd RADECSYS  {RADECSYS %s string {Mean Place IAU 1984 system} {}}
      dict set dicokwd SEEING    {SEEING %s float {Average FWHM} pixels}
      dict set dicokwd SITENAME  {SITENAME %s string {Observatory Name} {}}
      dict set dicokwd SITEELEV  {SITEELEV %s float {Elevation above sea of observatory} m}
      dict set dicokwd SITELAT   {SITELAT %s string {Geodetic observatory latitude} deg}
      dict set dicokwd SITELONG  {SITELONG %s string {East-positive observatory longitude} deg}
      dict set dicokwd SWCREATE  {SWCREATE %s string {Acquisition Software} {}}
      dict set dicokwd TELESCOP  {TELESCOP %s string {Telescope (name barlow reducer)} {}}
      dict set dicokwd TEMP      {TEMP %s float {Air temperature} Celsius}
      dict set dicokwd TEMPROSE  {TEMPROSE %s float {Dew temperature} Celsius}
      dict set dicokwd WINDDIR   {WINDDIR %s float {Wind direction (0=S 90=W 180=N 270=E)} deg}
      dict set dicokwd WINDSP    {WINDSP %s float {Windspeed} {km/h}}

      set kwd_list [dict keys $dicokwd]
      if {$kwd eq " "} {return $kwd_list}
      if {$kwd ni "$kwd_list"} {return "keyword \"$kwd\" {not in dictionnary}"}
      return [dict get $dicokwd $kwd]
   }

   #------------------------------------------------------------
   #  brief modifie l'entête de l'image
   #
   #  pm simulimage cree les mots cles EQUINOX RADECSYS CTYPE1 CTYPE2 CUNIT1 CUNIT2 LONPOLE CATASTAR
   #  @param bufNo numéro du buffer contenant l'image
   #
   proc ::collector::setKeywords { {bufNo 1} } {
      variable myKeywords

      #--   pour l'appel de cette proc a partir d'un autre plugin
      #     si collector est ouvert
      #--   cree l'array s'il existe pas
      if {[array exists myKeywords] == 0} {
         ::collector::createKeywords
      }

      if {[buf$bufNo imageready]} {
         foreach kwd [lsort -dictionary [array names myKeywords]] {
            if {[catch {
               buf$bufNo setkwd [lindex [array get myKeywords $kwd] 1]
            } ErrInfo]} {
               ::console::affiche_resultat "$kwd $ErrInfo\n"
            }
         }
      }
   }

   #------------------------------------------------------------
   #  brief calibration astrométrique de l'image
   #
   #         inscrit le nombre d'étoiles et les coefficients secondaires dans l'entête
   #  param bufNo  numéro du buffer contenant l'image
   #  param ext    extension de l'image
   #  param cdpath
   #  param cattype
   #
   proc ::collector::calibrationAstro { bufNo ext cdpath cattype } {
      global audace

      set rep $audace(rep_images)
      set mypath "."
      set sky0 dummy0
      set sky dummy
      catch {buf$bufNo delkwd CATASTAR}
      buf$bufNo save [ file join ${mypath} ${sky0}$ext ]
      createFileConfigSextractor
      buf$bufNo save [ file join ${mypath} ${sky}$ext ]
      sextractor [ file join $mypath $sky0$ext ] -c [ file join $mypath config.sex ]
      ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"$sky\" . \"$ext\" CATCHART \"path_astromcatalog=$cdpath\" astromcatalog=$cattype \"catafile=${mypath}/c$sky$ext\" "
      ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"$sky\" . \"$ext\" ASTROMETRY objefile=catalog.cat nullpixel=-10000 delta=5 epsilon=0.0002 file_ascii=ascii.txt"
      ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"z$sky\" . \"$ext\" CATCHART \"path_astromcatalog=$cdpath\" astromcatalog=$cattype \"catafile=${mypath}/c$sky$ext\" "
      buf$bufNo load [file join ${mypath} ${sky}$ext ]

      buf$bufNo setkwd [list EQUINOX J2000.0 string "System of equatorial coordinates" ""]

      #-- Nettoie
      set toDelete [list $sky0$ext x$sky$ext c$sky$ext z$sky$ext ascii.txt dummy.fit\
         catalog.cat com.lst dif.lst eq.lst obs.lst pointzero.lst usno.lst xy.lst \
         ${sky}a.jpg ${sky}b.jpg signal.sex config.sex config.param default.nnw file.fit]

      ttscript2 "IMA/SERIES \"$mypath\" \"$toDelete\" * * . . . * . DELETE"
   }

   #------------------------------------------------------------
   #  brief Commande du bouton 'Editer les mots clés'
   #
   proc ::collector::editKeywords {} {
      variable This
      variable myKeywords
      variable private
      global caption

      set kwdThis $This.kwd

      if {[winfo exists $kwdThis]} {destroy $kwdThis}

      toplevel $kwdThis
      wm resizable $kwdThis 1 1
      wm title $kwdThis "$caption(collector,kwds)"
      wm minsize $kwdThis 400 115
      wm transient $kwdThis $This
      wm geometry $kwdThis $::conf(collector,kwdgeometry)
      wm protocol $kwdThis WM_DELETE_WINDOW "::collector::close $kwdThis"

      frame $kwdThis.usr -borderwidth 0 -relief raised
      pack $kwdThis.usr -fill both -expand 1

      set tbl $kwdThis.usr.choix
      scrollbar $kwdThis.usr.vscroll -command "$tbl yview"
      scrollbar $kwdThis.usr.hscroll -orient horizontal -command "$tbl xview"

      #--- definit la structure et les caracteristiques de la tablelist des mots cles
      ::tablelist::tablelist $tbl -borderwidth 2 \
         -columns [list \
            0 "$caption(collector,kwds)" left \
            0 "$caption(collector,kwdvalue)" left \
            0 "$caption(collector,kwdtype)" center \
            0 "$caption(collector,kwdcmt)" left \
            0 "$caption(collector,kwdunit)" center] \
         -xscrollcommand [list $kwdThis.usr.hscroll set] \
         -yscrollcommand [list $kwdThis.usr.vscroll set] \
         -exportselection 0 -setfocus 1 \
         -activestyle none -stretch {1}

      #--   positionne et formate les widgets
      grid $tbl -row 0 -column 0 -sticky news
      #--   seule la liste occupe l'espace disponible
      grid columnconfigure $kwdThis.usr 0 -weight 1
      grid rowconfigure $kwdThis.usr 0 -weight 1
      #--   contraint les dimensions
      grid $kwdThis.usr.vscroll -row 0 -column 1 -sticky ns
      grid columnconfigure $kwdThis.usr 1 -minsize 18
      grid $kwdThis.usr.hscroll -row 1 -column 0 -sticky news
      grid rowconfigure $kwdThis.usr 1 -minsize 18

      #--   remplit la tablelist
      foreach cible [lsort -dictionary [array names myKeywords]] {
         $tbl insert end [lindex [array get myKeywords $cible] 1]
      }

      #--- Focus
      focus $kwdThis

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $kwdThis
   }

   #------------------------------------------------------------
   #  brief commande du bouton de fermeture de la fenêtre Mots Clés
   #
   proc ::collector::close { kwdThis } {

      set ::conf(collector,kwdgeometry) [wm geometry $kwdThis]
      destroy $kwdThis
   }

