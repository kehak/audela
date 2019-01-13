#
## @file catalogexplorer_tech.tcl
#  @brief Traitement des catalogues pour catalogexplorer
#  @author Raymond Zachantke
#  $Id: catalogexplorer_tech.tcl 14523 2018-10-25 14:59:39Z rzachantke $
#

#------------------------------------------------------------
#  brief   calcule le champe en deg et le rayon du champ en arcmin
#  details usage des commandes wcs et mise à jour les varaibles correspondantes
#
proc ::catalogexplorer::computeRadius { } {
   variable This
   variable widget

   #--   raccourcis
   foreach item [list naxis1 naxis2 crval1 crval2 pixsize1 pixsize2 foclen crota2] {
      set $item $widget(catalogexplorer,$item)
   }

   #--   Substitue les angles aux valeurs HMS et DMS
   set crval1 [mc_angle2deg $crval1]
   set crval2 [mc_angle2deg $crval2 90]

   set wcs [wcs_optic2wcs [expr { $naxis1/2 }] [expr { $naxis1/2 }] $crval1 $crval2 $pixsize1 $pixsize2 $foclen $crota2]

   #--- Calcul du champ diagonal de l'image
   lassign [wcs_p2radec $wcs 1 1] ra1 dec1
   lassign [wcs_p2radec $wcs $naxis1 $naxis2] ra2 dec2
   lassign [mc_sepangle $ra1 $dec1 $ra2 $dec2] fov_deg posangle
   set fov_arcmin [expr $fov_deg*60]
   set radius_arcmin [expr $fov_arcmin/2.]

   set widget(catalogexplorer,fov_deg) $fov_deg
   set widget(catalogexplorer,radius_arcmin) $radius_arcmin

   update
}

#------------------------------------------------------------
#  brief  sélectionne la proc à utiliser et normalise les niveaux de couleur avant de créer l'image SVG
#
proc ::catalogexplorer::getStars { } {
   variable widget

   set catalogName $widget(catalogexplorer,catalog)

   #--   Definit la proc a utiliser
   switch -exact $catalogName {
      "I/280B" {  set procName readI/280B }
      "B/wds"  {  set procName readB/wds }
      "AAVSO"  {  set procName readAAVSO }
      default  {  # pour tous les catalogues installes :
                  # 2MASS BMK GAIA1 LONEOS NOMAD1 PPMX PPMXL TYCHO2 TYCHO2_FAST UCAC2 UCAC3 UCAC4 URAT1 USNOA2
                  set procName readCatalog
               }
   }

   #--   Lance la commande specifique
   ::catalogexplorer::$procName

   #----------------------- Traitement des resultats en vu d'affichage -------------------------

   #--   Initialise la matrice pour les catalogues
   if {$catalogName in [list NOMAD1 PPMX] && [info exists sptypeMatrix] == 0} {
      ::catalogexplorer::init_spectral_type [ file join $::audace(rep_plugin) tool catalogexplorer sptypes.csv ]
   }

   set starFinal {}
   set msgLength {}
   set minMag ""
   set maxMag ""

   #--   Recupere le resultat des diverses proc
   set stars $widget(catalogexplorer,stars)

   set len [llength $stars]
   if {$len ne "0" && $len <= 1000} {

      #--   Definit l'espace des magnitudes
      ::blt::vector create Vmag -watchunset 1
      Vmag set $widget(catalogexplorer,magList)
      set minMag $Vmag(min)
      set maxMag $Vmag(max)
      ::blt::vector destroy Vmag

      foreach starinfo $stars {
         set mag       [lindex $starinfo 2]
         #--   Substitue la valeur de magnitude par la couleur grise RGB
         #     pour ajuster le niveau de gris
         set color [::catalogexplorer::getColor $minMag $maxMag $mag]
         set starinfo [lreplace $starinfo 2 2 "$color"]
         #--   Extrait le message a afficher
         set msg [lindex $starinfo 3]
         #--   Liste la longueur du contenu a afficher
         lappend msgLength [string length $msg]
         #--   Ajoute le type spectral
         if {$catalogName in [list NOMAD1 PPMX]} {
            regsub -all "=" [lrange $msg 2 end] " " listMag
            set spType [lindex [ ::catalogexplorer::get_spectral_type $listMag ] end]
            if {$spType ne [list "" "?"]} {
               lappend msg "type=$spType"
               set starinfo [lreplace $starinfo 3 3 "$msg"]
            }
         }
         lappend starFinal $starinfo
      }

      #--   Pour usage dans svg
      set widget(catalogexplorer,stars) $starFinal
      set widget(catalogexplorer,msgLen) [lmax $msgLength]
      set widget(catalogexplorer,radius) [format "%0.2f" [expr { $widget(catalogexplorer,fov_deg)/2 }]]
      ::catalogexplorer::createsvg

   } elseif {$len eq "0"} {
      ::console::affiche_erreur "[format $::caption(catalogexplorer,no_star) $catalogName]\n"
   } else {
      ::console::affiche_erreur "[format $::caption(catalogexplorer,excess_star) $len]\n"
   }
}

#------------------------------------------------------------
#  brief  explore les catalogues classiques
#  details variable d'entrée : widget(catalogexplorer,data)
#  details variables de sortie : widget(catalogexplorer,stars) et widget(catalogexplorer,magList)
#
proc ::catalogexplorer::readCatalog { } {
   variable widget

   lassign $widget(catalogexplorer,data) catalogName catalogPath naxis1 naxis2 crval1 crval2 mag_bright mag_faint radius_arcmin field zoom

   load [file join $::audace(rep_install) bin libcatalog_tcl[info sharedlibextension]]
   set command "cs[string tolower $catalogName] $catalogPath $crval1 $crval2 $radius_arcmin $mag_faint $mag_bright"

   #--   Debug de  la commande
   #::console::disp "command $command\n"

   lassign [eval $command] infos cataStars

   #--   Debug du format
   #::console::disp "catalogue $catalogName\n$infos\n"
   #update

   set starList {}
   set magList {}
   foreach star $cataStars {
      set infs [lindex [lindex $star 0] 2]
      switch -exact $catalogName {
         2MASS       {  #--   en tete : ID ra_deg dec_deg err_ra err_dec jMag jMagError hMag hMagError kMag kMagError jd
                        lassign [lrange $infs 1 9] ra_deg dec_deg -> -> magJ -> magH -> magK
                        set msg "J=$magJ H=$magH K=$magK"
                        set magSelected [lmin [list $magJ $magH $magK]]
                     }
         BMK         {  #--   en tete : ID RA DEC SOURCE_OF_COORDINATES STAR_NAME BIBCODE MAGNITUDE PASSBAND SPECTRAL_TYPE
                        lassign [lrange $infs 1 2] ra_deg dec_deg
                        lassign [lrange $infs 6 end] mag passband SpType
                        set msg "${passband}=[format "%0.2f" $mag] type=$SpType"
                        set magSelected $mag
                     }
         LONEOS      {  #--   en tete : ID starName ra_deg dec_deg sourceOfCoordinates nameInGSC  sourceOfCoordinates isStandard magnitudeV colorBV uncertaintyColorBV  colorUB uncertaintyColorUB colorVR colorVI
                        lassign [lrange $infs 1 3] starName ra_deg dec_deg
                        lassign [lrange $infs 7 end] magV magBV -> magUB -> magVR magVI
                        set msg "$starName"
                        foreach {title item} [list "V" "$magV" "(B-V)" "$magBV" "(U-B)" "$magUB" "(V-R)" "$magVR" "(V-I)" "$magVI"] {
                           if {$item ni [list "_" "99.999"]} {
                              append msg " ${title}=$item"
                           }
                        }
                        #set msg "name=$starName V=$magV (B-V)=$magBV (U-B)=$magUB (V-R)=$magVR (V-I)=$magVI"
                        set magSelected $magV
                     }
         NOMAD1      {  #--   en tete : ID oriAstro RAJ2000 DECJ2000 errRa errDec pmRA pmDE errPmRa errPmDec epochRa epochDec oriMagB magB oriMagV magV oriMagR magR magJ magH magK idUCAC2 idHIP idTYC1 idTYC2 idTYC3 flagDistTYC
                        lassign [lrange $infs 2 3] ra_deg dec_deg
                        set magB [lindex $infs 13]
                        set magV [lindex $infs 15]
                        set magR [lindex $infs 17]
                        set magJ [lindex $infs 18]
                        set magH [lindex $infs 19]
                        set magK [lindex $infs 20]
                        set msg "B=$magB R=$magR V=$magV J=$magJ H=$magH K=$magK"
                        set magSelected [lmin [list $magB $magR $magV $magJ $magH $magK]]
                     }
         PPMX        {  #--   en tete : ID RAJ2000 DECJ2000 errRa errDec pmRA pmDE errPmRa errPmDec Cmag Rmag Bmag ErrBmag Vmag ErrVmag Jmag ErrJmag Hmag ErrHmag Kmag ErrKmag Nobs P sub refCatalog
                        lassign [lrange $infs 1 2] ra_deg dec_deg
                        lassign [lrange $infs 9 19] magC magR magB -> magV -> magJ -> magH -> magK
                        set msg "C=$magC B=$magB R=$magR V=$magV J=$magJ H=$magH K=$magK"
                        set magSelected [lmin [list $magC $magR $magB $magV $magJ $magH $magK]]
                     }
         PPMXL       {  #--   en tete : ID RAJ2000 DECJ2000 errRa errDec pmRA pmDE errPmRa errPmDec epochRa epochDec magB1 magB2 magR1 magR2 magI magJ errMagJ magH errMagH magK errMagK Nobs
                        lassign [lrange $infs 1 2] ra_deg dec_deg
                        lassign [lrange $infs 11 20] magB1 magB2 magR1 magR2 magI magJ -> magH -> magK
                        set msg "B1=$magB1  R1=$magR1 I=$magI J=$magJ H=$magH K=$magK"
                        set magSelected [lmin [list $magR1 $magB1 $magI $magJ $magH $magK]]
                     }
        TYCHO2       {  #--   en tete : ID TYC1 TYC2 TYC3 pflag mRAdeg mDEdeg pmRA pmDE e_mRA e_mDE e_pmRA e_pmDE mepRA mepDE Num g_mRA g_mDE g_pmRA g_pmDE BT e_BT VT e_VT prox TYC HIP CCDM RAdeg DEdeg epRA epDE e_RA e_DE posflg corr
                        lassign [lrange $infs 20 22] magB -> magR
                        lassign [lrange $infs 28 29] ra_deg dec_deg
                        set msg "B=$magB R=$magR"
                        set magSelected [lmin [list $magB $magR]]
                     }
        TYCHO2_FAST  {  #--   en tete : ID TYC1 TYC2 TYC3 pflag mRAdeg mDEdeg pmRA pmDE e_mRA e_mDE e_pmRA e_pmDE mepRA mepDE Num g_mRA g_mDE g_pmRA g_pmDE BT e_BT VT e_VT prox TYC HIP CCDM RAdeg DEdeg epRA epDE e_RA e_DE posflg corr
                        lassign [lrange $infs 20 22] magB -> magR
                        lassign [lrange $infs 28 29] ra_deg dec_deg
                        set msg "B=$magB R=$magR"
                        set magSelected [lmin [list $magB $magR]]
                     }
        UCAC2        {  #--   en tete : ID ra_deg dec_deg U2Rmag_mag e_RAm_deg e_DEm_deg nobs e_pos_deg ncat cflg EpRAm_deg EpDEm_deg pmRA_masperyear pmDEC_masperyear e_pmRA_masperyear e_pmDE_masperyear q_pmRA q_pmDE 2m_id 2m_J 2m_H 2m_Ks 2m_ph 2m_cc
                        lassign [lrange $infs 1 2] ra_deg dec_deg
                        lassign [lrange $infs 19 21] magJ magH magK
                        set msg "J=$magJ H=$magH K=$magK"
                        set magSelected [lmin [list $magJ $magH $magK]]
                     }
        UCAC3        {  #--   en tete : ID ra_deg dec_deg im1_mag im2_mag sigmag_mag objt dsf sigra_deg sigdc_deg na1 nu1 us1 cn1 cepra_deg cepdc_deg pmrac_masperyear pmdc_masperyear sigpmr_masperyear sigpmd_masperyear id2m jmag_mag hmag_mag kmag_mag jicqflg hicqflg kicqflg je2mpho he2mpho ke2mpho smB_mag smR2_mag smI_mag clbl qfB qfR2 qfI catflg1 catflg2 catflg3 catflg4 catflg5 catflg6 catflg7 catflg8 catflg9 catflg10 g1 c1 leda x2m rn
                        lassign [lrange $infs 1 2] ra_deg dec_deg
                        lassign [lrange $infs 21 23] magJ magH magK
                        set msg "J=$magJ H=$magH K=$magK"
                        set magSelected [lmin [list $magJ $magH $magK]]
                     }
        UCAC4        {  #--   en tete : ID ra_deg dec_deg im1_mag im2_mag sigmag_mag objt dsf sigra_deg sigdc_deg na1 nu1 us1 cepra_deg cepdc_deg pmrac_masperyear pmdc_masperyear sigpmr_masperyear sigpmd_masperyear id2m jmag_mag hmag_mag kmag_mag jicqflg hicqflg kicqflg je2mpho he2mpho ke2mpho apassB_mag apassV_mag apassG_mag apassR_mag apassI_mag apassB_errmag apassV_errmag apassG_errmag apassR_errmag apassI_errmag catflg1 catflg2 catflg3 catflg4 starId zoneUcac2 idUcac2
                        lassign $infs -> ra_deg dec_deg magB magR
                        set msg "B=$magB R=$magR"
                        set magSelected [lmin [list $magB $magR]]
                     }
        URAT1        {  #--   en tete : ID ra_deg dec_deg sigs nst nsu epoc magnitude sigmaMagnitude nsm ref nit niu ngt ngu pmr pmd pme mf2 mfa id2 jmag hmag kmag ejmag ehmag ekmag iccj icch icck phqj phqh phqk abm avm agm arm aim ebm evm egm erm eim ann ano
                        lassign [lrange $infs 1 2] ra_deg dec_deg
                        set mag [lindex $infs 7]
                        set msg "mag=$mag"
                        set magSelected [lmin [list $mag]]
                     }
        USNOA2       {  #--   en tete : ID ra_deg dec_deg sign qflag field magB magR
                        lassign [lrange $infs 1 2] ra_deg dec_deg
                        lassign [lrange $infs 6 7] magB magR
                        set msg "B=$magB R=$magR"
                        set magSelected [lmin [list $magB $magR]]
                     }
        GAIA1        {  #--   en tete : source_id ref_epoch ra ra_error dec dec_error parallax parallax_error pmra pmra_error pmdec pmdec_error astrometric_primary_flag astrometric_priors_used phot_g_mean_flux phot_g_mean_flux_error phot_g_mean_mag phot_variable_flag
                        lassign [lrange $infs 1 4] epoch ra_deg -> dec_deg
                        set magG [lindex $infs 16]
                        set msg "epoch=$epoch G=$magG"
                        set magSelected [lmin [list $magG]]
                     }
		GAIA2        {  #--   en tete : source_id ref_epoch ra ra_error dec dec_error parallax parallax_error pmra pmra_error pmdec pmdec_error phot_g_mean_mag phot_g_mean_mag_error phot_bp_mean_mag phot_bp_mean_mag_error phot_rp_mean_mag phot_rp_mean_mag_error phot_bprp_color temerature_apsis extinction_apsis
                        lassign [lrange $infs 1 4] epoch ra_deg -> dec_deg
                        set magG [lindex $infs 12]
                        set msg "epoch=$epoch G=$magG"
                        set magSelected [lmin [list $magG]]
                     }			 		 
      }

      lassign [mc_radec2xy $ra_deg $dec_deg $field] x y
      set y [expr { $naxis2-$y }]

      #--   Filtre les valeurs hors champ ou non conformes et fixe la magnitude
      if {$x >=1 && $x <= $naxis1 && $y >= 1 && $y <= $naxis2 && $magSelected >= $mag_bright && $magSelected <= $mag_faint} {
         set y [format "%0.1f" $y]
         set x [format "%0.1f" $x]
         set ra [mc_angle2hms $ra_deg 360 zero 0 auto string]
         set dec [mc_angle2dms $dec_deg 90 zero 0 + string]
         set msg [linsert $msg 0 $ra $dec]
         lappend magList $magSelected
         lappend starList [list $x $y $magSelected $msg]
      }
   }

   set widget(catalogexplorer,stars) $starList
   set widget(catalogexplorer,magList) $magList
}

#------------------------------------------------------------
#  brief  explore les catalogues apass
#
#         paramètres : widget(catalogexplorer,data) ;
#         sortie : widget(catalogexplorer,stars) et widget(catalogexplorer,magList)
#         pour un fichier apass variable, la matrice aavsoMatrix est créée et détruite dans la proc
#
proc ::catalogexplorer::readAAVSO { } {
   variable widget

   #pm : package require struct::matrix

   lassign $widget(catalogexplorer,data) -> catalogPath naxis1 naxis2 -> -> \
      mag_bright mag_faint radius_arcmin field

   #--   extrait le catalogue avec les titres
   regsub -all {\{\}} [split [K [read [set fi [open $catalogPath]]] [close $fi]] "\n"] "" catalog

   #--   Definit le nombre de colonnes et de lignes
   set nbRow [llength $catalog]

   catch { aavsoMatrix destroy }
   catch { struct::matrix aavsoMatrix }

   aavsoMatrix add columns 15

   for {set k 0} {$k < $nbRow} {incr k} {
      aavsoMatrix add row  [split [lindex $catalog $k] ","]
   }

   #--   La premiere ligne contient le nom des rubriques
   #--   radeg,raerr,decdeg,decerr,number_of_Obs,Johnson_V,Verr,Johnson_B,B_err,Sloan_g,gerr,Sloan_r,r_err,Sloan_i,i_err
   #set titles [aavsoMatrix get row 0]
   #--   Supprime les colonnes inutiles (err)
   foreach col [list 14 12 10 8 6 4 3 1] {
      aavsoMatrix delete column $col
   }

   set starList {}
   set magList {}
   for {set r 1} {$r < $nbRow} {incr r} {
      set lmag {}
      set dat [aavsoMatrix get row $r]
      lassign [lrange $dat 0 1] ra_deg dec_deg
      #--   Teste les magnitudes en decimal
      foreach mag [lrange $dat 2 end] filtre [list V B g r i] {
         if {[regexp -all {^([-+]?[0-9]*\.?[0-9]+)$} $mag] ==1} {
            lappend lmag $mag
            set filtre [string toupper $filtre]
            set msg [list ${filtre}=$mag]
         }
      }
      set msg [string trimright $msg " "]

      if {$lmag ne ""} {

         set magSelected [lmin $lmag]
         lassign [mc_radec2xy $ra $dec $field] x y
         set y [expr { $naxis2-$y }]

         #--   Filtre les valeurs hors champ ou non conformes et fixe la magnitude
         if {$x >=1 && $x <= $naxis1 && $y >= 1 && $y <= $naxis2 && $magSelected >= $mag_bright && $magSelected <= $mag_faint} {
            set y [format "%0.1f" $y]
            set x [format "%0.1f" $x]
            set ra [mc_angle2hms $ra_deg 360 zero 0 auto string]
            set dec [mc_angle2dms $dec_deg 90 zero 0 + string]
            set msg [linsert $msg 0 $ra $dec]
            lappend magList $magSelected
            lappend starList [list $x $y $magSelected $msg]
         }
      }
   }

   set widget(catalogexplorer,stars) $starList
   set widget(catalogexplorer,magList) $magList

   #--   Nettoyage
   aavsoMatrix destroy
}

#------------------------------------------------------------
#  brief  calcule le niveau d'intensité
#  param  minMag magnitude minimale de la liste des étoiles
#  param  maxMag magnitude maximale de la liste des étoiles
#  param  mag magnitude de l'étoile
#  return couleur sous forme \#abcdef
#
proc ::catalogexplorer::getColor { minMag maxMag mag } {

   set talon 80                                             ; #-- talon de visibilite
   set delta [expr { pow(10,-0.4*($minMag-$maxMag)) }]
   if {$delta != "0"} {
      set d [expr { pow(10,-0.4*($mag-$maxMag))/$delta }]   ; #--   proportion
      set v [expr { int($talon+(255-$talon)*$d) }]          ; #--   niveau entre le talon et 255
   } else {
      #--   Cas d'une seule etoile ou ecart de magnitude nul
      set v 255
   }

   return [format "#%02x%02x%02x" $v $v $v]
}

