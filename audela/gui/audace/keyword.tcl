#
## @file keyword.tcl
#  @brief Procédures autour de l'en-tete FITS
#  @authors Robert DELMAS et Michel PUJOL
#  @namespace keyword
#  @brief Procédures autour de l'en-tete FITS
#  $Id: keyword.tcl 13759 2016-04-27 10:31:17Z rzachantke $
#

namespace eval ::keyword {
}

#------------------------------------------------------------------------------
## @brief affiche l'en-tete FITS d'un fichier
#  @param visuNo : numéro de la visu
#  @param args   : valeurs fournies par le gestionnaire de listener
#  (car cette procédure peut être appelée par un listener)
#  @todo il faudrait remplacer \::confVisu::private($visuNo,mode) par l'appel d'une
#  procédure pour éviter d'utiliser ici une variable privée
#
proc ::keyword::header { visuNo args } {
   variable private

   #--- Initialisation
   set base [ ::confVisu::getBase $visuNo ]
   if { ! [ info exists ::conf(geometry_header_$visuNo) ] } { set ::conf(geometry_header_$visuNo) "632x303+3+75" }
   #---
   set private(geometry_header_$visuNo) $::conf(geometry_header_$visuNo)
   #---
   if { [ winfo exists $base.header ] == 0 } {
      toplevel $base.header
      wm transient $base.header $base
      if { [ buf[ ::confVisu::getBufNo $visuNo ] imageready ] == "1" } {
         wm minsize $base.header 632 303
      }
      wm resizable $base.header 1 1
      wm geometry $base.header $private(geometry_header_$visuNo)
      wm protocol $base.header WM_DELETE_WINDOW "::keyword::closeHeader $visuNo"
      Scrolled_Text $base.header.slb -width 150 -height 20
      pack $base.header.slb -fill y -expand true
      #--- Je declare le rafraichissement automatique des mots-cles si on charge une image
      ::confVisu::addFileNameListener $visuNo "::keyword::header $visuNo"
      #--- Je declare le rafraichissement automatique des mots-cles si on change de HDU de l'image FITS
      ::confVisu::addHduListener $visuNo "::keyword::header $visuNo"
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $base.header <Key-F1> { ::console::GiveFocus }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $base.header
   } else {
      $base.header.slb.list delete 1.0 end
   }
   #---
   wm title $base.header "$::caption(keyword,header_title) (visu$visuNo) - [::confVisu::getFileName $visuNo]"
   #---
   if { [ buf[ ::confVisu::getBufNo $visuNo ] imageready ] == "1" } {
      $base.header.slb.list tag configure keyw -foreground $::color(blue)
      $base.header.slb.list tag configure egal -foreground $::color(black)
      $base.header.slb.list tag configure valu -foreground $::color(red)
      $base.header.slb.list tag configure comm -foreground $::color(green1)
      $base.header.slb.list tag configure unit -foreground $::color(orange)
      foreach kwd [ lsort -dictionary [ buf[ ::confVisu::getBufNo $visuNo ] getkwds ] ] {
         set liste [ buf[ ::confVisu::getBufNo $visuNo ] getkwd $kwd ]
         #--- je fais une boucle pour traiter les mots cles a valeur multiple
         foreach { name value type comment unit } $liste {
            if { $name == "EXPOSURE" || $name == "EXPTIME" } {
               #--- Pour une meilleure lisibilite transforme la notation avec
               #--- exposant en un nombre decimal Exemple : 2.5000e-004 --> 0.00025
               set value [ expr $value ]
            }
            $base.header.slb.list insert end "[format "%8s" $name] " keyw
            $base.header.slb.list insert end "= "                    egal
            $base.header.slb.list insert end "$value "               valu
            $base.header.slb.list insert end "$comment "             comm
            $base.header.slb.list insert end "$unit\n"               unit
         }
      }
   } else {
      set fileName [ ::confVisu::getFileName $visuNo ]
      if { $fileName != "" && $::confVisu::private($visuNo,mode) == "table" } {
         #--- je charge les mots cles du HDU de la table
         set catchResult [ catch {
             #--- j'ouvre le fichier d'entree
             set hFile [fits open $fileName 0]
             set hduNo [::confVisu::getCurrentHduNo $visuNo]
             #--- je pointe le HDU courant
             $hFile move [::confVisu::getCurrentHduNo $visuNo]
             #--- je lis les mot cles du HDU
             set keywords [$hFile get keyword ]
             $hFile close
             $base.header.slb.list tag configure keyw -foreground $::color(blue)
             $base.header.slb.list tag configure egal -foreground $::color(black)
             $base.header.slb.list tag configure valu -foreground $::color(red)
             $base.header.slb.list tag configure comm -foreground $::color(green1)
             $base.header.slb.list tag configure unit -foreground $::color(orange)
             #--- je cherche le mot cle qui a exactement le nom requis
             foreach keyword [ lsort -dictionary $keywords ] {
                set name [lindex $keyword 0]
                #--- je supprime les apostrophes et les espaces qui entourent la valeur
                set value [string trim [string map {"'" ""} [lindex $keyword 1] ]]
                set comment [lindex $keyword 2]
                set unit ""
                #--- j'affiche les mots cles
                $base.header.slb.list insert end "[format "%8s" $name] " keyw
                $base.header.slb.list insert end "= "                    egal
                $base.header.slb.list insert end "$value "               valu
                $base.header.slb.list insert end "$comment "             comm
                $base.header.slb.list insert end "$unit\n"               unit
             }
          }]

         if { $catchResult !=0 } {
            #--- je transmets l'erreur en ajoutant le nom du mot clé
            error "load keywords hduNo=[::confVisu::getCurrentHduNo $visuNo]\n$::errorInfo"
         }

      } else {
         $base.header.slb.list insert end "$::caption(keyword,header_noimage)"

      }
   }
}

#------------------------------------------------------------------------------
## @brief ferme la fenêtre de l'en-tête FITS d'un fichier
#  @param visuNo numéro de la visu
#
proc ::keyword::closeHeader { visuNo } {
   if { [ winfo exists [::confVisu::getBase $visuNo].header] == 1 } {
      ::keyword::headerRecupPosition $visuNo
      ::confVisu::removeFileNameListener $visuNo "::keyword::header $visuNo"
      ::confVisu::removeHduListener $visuNo "::keyword::header $visuNo"
      destroy [ ::confVisu::getBase $visuNo ].header
   }
}

#------------------------------------------------------------------------------
#  brief récupère et sauvegarde les dimensions et la position de la fenêtre de l'en-tête FITS d'un fichier
#  param visuNo numéro de la visu
#
proc ::keyword::headerRecupPosition { visuNo } {
   variable private

   #---
   set private(geometry_header_$visuNo) [ wm geometry [ ::confVisu::getBase $visuNo ].header ]
   #---
   set ::conf(geometry_header_$visuNo) $private(geometry_header_$visuNo)
}

#########################################################################################################

#------------------------------------------------------------------------------
## @brief ajoute les mots clés JDAY-OBS et JDAY-END à une en-tête FITS d'un fichier
#
proc ::keyword::addJDayOBSandEND { } {
   #--- Rajoute la date de debut de pose en jour julien dans l'en-tete FITS
   set date_obs [ lindex [ buf$::audace(bufNo) getkwd DATE-OBS ] 1 ]
   set date_obs [ mc_date2jd $date_obs ]
   buf$::audace(bufNo) setkwd [list JDAY-OBS $date_obs double "Julian Day for begin of scan exposure" ""]

   #--- Rajoute la date de fin de pose en jour julien dans l'en-tete FITS
   set date_end [ lindex [ buf$::audace(bufNo) getkwd DATE-END ] 1 ]
   set date_end [ mc_date2jd $date_end ]
   buf$::audace(bufNo) setkwd [list JDAY-END $date_end double "Julian Day for end of scan exposure" ""]
}

#########################################################################################################

#------------------------------------------------------------------------------
# brief initialisation de variables
#
proc ::keyword::init { } {
   variable private

   #--- Charge le fichier caption
   source [ file join "$::audace(rep_caption)" keyword.cap ]

   #--- Creation de la variable de la boite de configuration de l'en-tete FITS si elle n'existe pas
   ::keyword::initConf

   #--- Initialisation de variables
   set private(nom_observateur)     ""
   set private(nom_observatoire)    ""
   set private(nom_organisation)    ""
   set private(temperature_site)    ""
   set private(pression_site)       ""
   set private(humidite_site)       ""
   set private(setMeteoData)        "$::caption(keyword,stationMeteo)"
   set private(instrument)          ""
   set private(diametre)            ""
   set private(focale_resultante)   ""
   set private(angleCamera)         ""
   set private(cell_dim_x)          ""
   set private(cell_dim_y)          ""
   set private(pix_dim_x)           ""
   set private(pix_dim_y)           ""
   set private(set_temperature_ccd) ""
   set private(temperature_ccd)     ""
   set private(equipement)          ""
   set private(detectorName)        ""
   set private(confName)            ""
   set private(CRVAL1)              ""
   set private(CRVAL2)              ""
   set private(CRPIX1)              ""
   set private(CRPIX2)              ""
   set private(object)              ""
   set private(objName)             ""
   set private(GotoManuelAuto)      "$::caption(keyword,manuel)"
   set private(ra)                  ""
   set private(dec)                 ""
   set private(GotoManuelAutoBis)   "$::caption(keyword,manuel)"
   set private(equinoxe)            ""
   set private(GotoManuelAutoTer)   "$::caption(keyword,manuel)"
   set private(airmass)             ""
   set private(radecsys)            ""
   set private(typeImage)           "Object"
   set private(typeImageSelected)   "Object"
   set private(seriesId)            ""
   set private(raMean)              ""
   set private(raRms)               ""
   set private(decMean)             ""
   set private(decRms)              ""
   set private(seeing)              ""
   set private(skylevel)            ""
   set private(name_software)       "[ ::audela::getPluginTitle ] $::audela(version)"
   set private(name_software)       "[ ::keyword::headerFitsCompliant $::keyword::private(name_software) ]"
   set private(commentaire)         ""

   #--- Liste pour les combobox
   set private(listTypeImage)       "$::conf(keyword,listTypeImage)"
   lappend private(listTypeImage)   "$::caption(keyword,newValue)"
   set private(listOutilsGoto)      [ list $::caption(keyword,manuel) $::caption(keyword,automatic) ]
   set private(listMeteoData)       [ list $::caption(keyword,manuel) $::caption(keyword,stationMeteo) ]

   #--- On cree la liste des caracteristiques (nom, categorie, variable, procedure, etc.) des mots cles
   set private(infosMotsClefs) ""
   lappend private(infosMotsClefs) [ list "OBSERVER" $::caption(keyword,lieu)        ::keyword::private(nom_observateur)     readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs" ""                                  ""                                        "" "" "string"  "Observer name"                                   "" ]
   lappend private(infosMotsClefs) [ list "SITENAME" $::caption(keyword,lieu)        ::keyword::private(nom_observatoire)    readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs" ""                                  ""                                        "" "" "string"  "Observatory name"                                "" ]
   lappend private(infosMotsClefs) [ list "ORIGIN"   $::caption(keyword,lieu)        ::keyword::private(nom_organisation)    readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs" ""                                  ""                                        "" "" "string"  "Origin place of FITS image"                      "" ]
   lappend private(infosMotsClefs) [ list "IAU_CODE" $::caption(keyword,lieu)        ::conf(posobs,station_uai)              readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs" ""                                  ""                                        "" "" "string"  "Observatory IAU Code"                            "" ]
   lappend private(infosMotsClefs) [ list "SITELONG" $::caption(keyword,lieu)        ::conf(posobs,estouest_long)            readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs" ""                                  ""                                        "" "" "string"  "Observatory longitude"                           "degrees, minutes, seconds" ]
   lappend private(infosMotsClefs) [ list "SITELAT"  $::caption(keyword,lieu)        ::conf(posobs,nordsud_lat)              readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs" ""                                  ""                                        "" "" "string"  "Observatory latitude"                            "degrees, minutes, seconds" ]
   lappend private(infosMotsClefs) [ list "SITEELEV" $::caption(keyword,lieu)        ::conf(posobs,altitude)                 readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs" ""                                  ""                                        "" "" "float"   "Observatory elevation above the sea level"       "m: meter" ]
   lappend private(infosMotsClefs) [ list "GEODSYS"  $::caption(keyword,lieu)        ::conf(posobs,ref_geodesique)           readonly $::caption(keyword,parcourir)  "::confPosObs::run $::audace(base).confPosObs" ""                                  ""                                        "" "" "string"  "Geodetic datum for observatory position"         "" ]
   lappend private(infosMotsClefs) [ list "TEMP"     $::caption(keyword,lieu)        ::keyword::private(temperature_site)    readonly $::caption(keyword,parcourir)  "::confEqt::run \"\" weather_station"          $::keyword::private(listMeteoData)  ::keyword::private(setMeteoData)          1  "" "float"   "Site temperature"                                "degrees Celsius" ]
   lappend private(infosMotsClefs) [ list "PRESSURE" $::caption(keyword,lieu)        ::keyword::private(pression_site)       readonly $::caption(keyword,parcourir)  "::confEqt::run \"\" weather_station"          $::keyword::private(listMeteoData)  ::keyword::private(setMeteoData)          1  "" "float"   "Air pressure"                                    "Pa" ]
   lappend private(infosMotsClefs) [ list "HUMIDITY" $::caption(keyword,lieu)        ::keyword::private(humidite_site)       readonly $::caption(keyword,parcourir)  "::confEqt::run \"\" weather_station"          $::keyword::private(listMeteoData)  ::keyword::private(setMeteoData)          1  "" "float"   "Relative humidity "                              "percent" ]
   lappend private(infosMotsClefs) [ list "TELESCOP" $::caption(keyword,instrument)  ::keyword::private(instrument)          readonly $::caption(keyword,parcourir)  "::confOptic::run 1"                           ""                                  ""                                        "" "" "string"  "Telescop name"                                   "" ]
   lappend private(infosMotsClefs) [ list "APTDIA"   $::caption(keyword,instrument)  ::keyword::private(diametre)            readonly $::caption(keyword,parcourir)  "::confOptic::run 1"                           ""                                  ""                                        "" "" "float"   "Telescop diameter"                               "m: meter" ]
   lappend private(infosMotsClefs) [ list "FOCLEN"   $::caption(keyword,instrument)  ::keyword::private(focale_resultante)   readonly $::caption(keyword,parcourir)  "::confOptic::run 1"                           ""                                  ""                                        "" "" "float"   "Resulting focal length of the telescop"          "m: meter" ]
   lappend private(infosMotsClefs) [ list "CROTA2"   $::caption(keyword,instrument)  ::keyword::private(angleCamera)         normal   ""                             ""                                             ""                                  ""                                        "" "" "double"  "Position angle"                                  "degrees" ]
   lappend private(infosMotsClefs) [ list "XPIXSZ"   $::caption(keyword,instrument)  ::keyword::private(cell_dim_x)          readonly $::caption(keyword,parcourir)  "::confCam::run"                               ""                                  ""                                        "" "" "float"   "Pixel width"                                     "mum: micron" ]
   lappend private(infosMotsClefs) [ list "YPIXSZ"   $::caption(keyword,instrument)  ::keyword::private(cell_dim_y)          readonly $::caption(keyword,parcourir)  "::confCam::run"                               ""                                  ""                                        "" "" "float"   "Pixel height"                                    "mum: micron" ]
   lappend private(infosMotsClefs) [ list "PIXSIZE1" $::caption(keyword,instrument)  ::keyword::private(pix_dim_x)           readonly $::caption(keyword,parcourir)  "::confCam::run"                               ""                                  ""                                        "" "" "float"   "Pixel size along naxis1"                         "mum: micron" ]
   lappend private(infosMotsClefs) [ list "PIXSIZE2" $::caption(keyword,instrument)  ::keyword::private(pix_dim_y)           readonly $::caption(keyword,parcourir)  "::confCam::run"                               ""                                  ""                                        "" "" "float"   "Pixel size along naxis2"                         "mum: micron" ]
   lappend private(infosMotsClefs) [ list "SET_TEMP" $::caption(keyword,instrument)  ::keyword::private(set_temperature_ccd) readonly $::caption(keyword,parcourir)  "::keyword::openSetTemperature"                ""                                  ""                                        "" "" "float"   "Set CCD temperature"                             "degrees Celsius" ]
   lappend private(infosMotsClefs) [ list "CCD_TEMP" $::caption(keyword,instrument)  ::keyword::private(temperature_ccd)     readonly $::caption(keyword,rafraichir) "::keyword::onChangeTemperature"               ""                                  ""                                        "" "" "float"   "Actual CCD temperature"                          "degrees Celsius" ]
   lappend private(infosMotsClefs) [ list "INSTRUME" $::caption(keyword,instrument)  ::keyword::private(equipement)          normal   ""                             ""                                             ""                                  ""                                        "" "" "string"  "Instrument"                                      "" ]
   lappend private(infosMotsClefs) [ list "DETNAM"   $::caption(keyword,instrument)  ::keyword::private(detectorName)        normal   ""                             ""                                             ""                                  ""                                        "" "" "string"  "Detector"                                        "" ]
   lappend private(infosMotsClefs) [ list "CONFNAME" $::caption(keyword,instrument)  ::keyword::private(confName)            normal   ""                             ""                                             ""                                  ""                                        "" "" "string"  "Configuration name"                              "" ]
   lappend private(infosMotsClefs) [ list "CRVAL1"   $::caption(keyword,instrument)  ::keyword::private(CRVAL1)              readonly ""                             ""                                             ""                                  ""                                        "" "" "double"  "Reference coordinate for naxis1"                 "degrees" ]
   lappend private(infosMotsClefs) [ list "CRVAL2"   $::caption(keyword,instrument)  ::keyword::private(CRVAL2)              readonly ""                             ""                                             ""                                  ""                                        "" "" "double"  "Reference coordinate for naxis2"                 "degrees" ]
   lappend private(infosMotsClefs) [ list "CRPIX1"   $::caption(keyword,instrument)  ::keyword::private(CRPIX1)              readonly ""                             ""                                             ""                                  ""                                        "" "" "double"  "Reference pixel for naxis1"                      "pixel" ]
   lappend private(infosMotsClefs) [ list "CRPIX2"   $::caption(keyword,instrument)  ::keyword::private(CRPIX2)              readonly ""                             ""                                             ""                                  ""                                        "" "" "double"  "Reference pixel for naxis2"                      "pixel" ]
   lappend private(infosMotsClefs) [ list "OBJECT"   $::caption(keyword,cible)       ::keyword::private(object)              normal   ""                             ""                                             $::keyword::private(listOutilsGoto) ::keyword::private(GotoManuelAuto)        0  "" "string"  "Object observed"                                 "" ]
   lappend private(infosMotsClefs) [ list "OBJNAME"  $::caption(keyword,cible)       ::keyword::private(objName)             normal   ""                             ""                                             $::keyword::private(listOutilsGoto) ::keyword::private(GotoManuelAuto)        0  "" "string"  "Object observed"                                 "" ]
   lappend private(infosMotsClefs) [ list "RA"       $::caption(keyword,cible)       ::keyword::private(ra)                  normal   ""                             ""                                             $::keyword::private(listOutilsGoto) ::keyword::private(GotoManuelAutoBis)     0  "" "double"  "Object Right Ascension"                          "degrees" ]
   lappend private(infosMotsClefs) [ list "DEC"      $::caption(keyword,cible)       ::keyword::private(dec)                 normal   ""                             ""                                             $::keyword::private(listOutilsGoto) ::keyword::private(GotoManuelAutoBis)     0  "" "double"  "Object Declination"                              "degrees" ]
   lappend private(infosMotsClefs) [ list "EQUINOX"  $::caption(keyword,cible)       ::keyword::private(equinoxe)            normal   ""                             ""                                             $::keyword::private(listOutilsGoto) ::keyword::private(GotoManuelAutoTer)     0  "" "string"  "Coordinates equinox"                             "" ]
   lappend private(infosMotsClefs) [ list "AIRMASS"  $::caption(keyword,cible)       ::keyword::private(airmass)             readonly ""                             ""                                             ""                                  ""                                        "" "" "float"   "Air mass"                                        "" ]
   lappend private(infosMotsClefs) [ list "RADECSYS" $::caption(keyword,cible)       ::keyword::private(radecsys)            normal   ""                             ""                                             ""                                  ""                                        "" "" "string"  "Coordinates system"                              "" ]
   lappend private(infosMotsClefs) [ list "IMAGETYP" $::caption(keyword,acquisition) ::keyword::private(typeImage)           readonly ""                             ""                                             $::keyword::private(listTypeImage)  ::keyword::private(typeImageSelected)     0  "" "string"  "Image type"                                      "" ]
   lappend private(infosMotsClefs) [ list "SERIESID" $::caption(keyword,acquisition) ::keyword::private(seriesId)            normal   ""                             ""                                             ""                                  ""                                        "" "" "string"  "Series identifiant"                              "" ]
   lappend private(infosMotsClefs) [ list "RA_MEAN"  $::caption(keyword,acquisition) ::keyword::private(raMean)              normal   ""                             ""                                             ""                                  ""                                        "" "" "float"   "RA mean correction"                              "arsec" ]
   lappend private(infosMotsClefs) [ list "RA_RMS"   $::caption(keyword,acquisition) ::keyword::private(raRms)               normal   ""                             ""                                             ""                                  ""                                        "" "" "float"   "RA rms correction"                               "arsec" ]
   lappend private(infosMotsClefs) [ list "DEC_MEAN" $::caption(keyword,acquisition) ::keyword::private(decMean)             normal   ""                             ""                                             ""                                  ""                                        "" "" "float"   "DEC mean correction"                             "arsec" ]
   lappend private(infosMotsClefs) [ list "DEC_RMS"  $::caption(keyword,acquisition) ::keyword::private(decRms)              normal   ""                             ""                                             ""                                  ""                                        "" "" "float"   "DEC rms correction"                              "arsec" ]
   lappend private(infosMotsClefs) [ list "SEEING"   $::caption(keyword,acquisition) ::keyword::private(seeing)              normal   ""                             ""                                             ""                                  ""                                        "" "" "float"   "Seeing as stellar full-width at half-maximum"    "arsec" ]
   lappend private(infosMotsClefs) [ list "SKYLEVEL" $::caption(keyword,acquisition) ::keyword::private(skylevel)            normal   ""                             ""                                             ""                                  ""                                        "" "" "float"   "Sky backgound level"                             "ADU" ]
   lappend private(infosMotsClefs) [ list "SWCREATE" $::caption(keyword,logiciel)    ::keyword::private(name_software)       readonly ""                             ""                                             ""                                  ""                                        "" "" "string"  "Acquisition software: http://www.audela.org/"    "" ]
   lappend private(infosMotsClefs) [ list "SWMODIFY" $::caption(keyword,logiciel)    ::keyword::private(name_software)       readonly ""                             ""                                             ""                                  ""                                        "" "" "string"  "Processing software: http://www.audela.org/"     "" ]
   lappend private(infosMotsClefs) [ list "COMMENT"  $::caption(keyword,divers)      ::keyword::private(commentaire)         normal   ""                             ""                                             ""                                  ""                                        "" "" "string"  ""                                                "" ]
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'outil "Mots Clés :"
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - conf(keyword,geometry)                  définit les dimensions et la position de la fenêtre
#  - conf(keyword,listTypeImage)             définit le type d'image
#  - conf(keyword,default,setMeteoData)      définit si la mise à jour des mots clés TEMP, PRESSURE et/ou HUMIDITY est manuelle ou automatique à partir des stations météo
#  - conf(keyword,default,GotoManuelAuto)    définit si la mise à jour des mots clés OBJECT et/ou OBJNAME est manuelle ou automatique
#  - conf(keyword,default,GotoManuelAutoBis) définit si la mise à jour des mots clés RA et/ou DEC est manuelle ou automatique
#  - conf(keyword,default,GotoManuelAutoTer) définit si la mise à jour du mot clé EQUINOX est manuelle ou automatique
#  - conf(keyword,default,configName)        définit le nom de la configuration par défaut
#  - conf(keyword,default,check)             définit les mots clés sélectionnés de la configuration par défaut
#
proc ::keyword::initConf { } {
   #--- Creation de la variable de la boite de configuration de l'en-tete FITS si elle n'existe pas
   if { ! [ info exists ::conf(keyword,geometry) ] }                  { set ::conf(keyword,geometry)                  "650x240+350+15" }
   if { ! [ info exists ::conf(keyword,listTypeImage) ] }             { set ::conf(keyword,listTypeImage)             [ list Offset Dark Flat Object Lamp ] }
   if { ! [ info exists ::conf(keyword,default,setMeteoData) ] }      { set ::conf(keyword,default,setMeteoData)      "$::caption(keyword,manuel)" }
   if { ! [ info exists ::conf(keyword,default,GotoManuelAuto) ] }    { set ::conf(keyword,default,GotoManuelAuto)    "$::caption(keyword,manuel)" }
   if { ! [ info exists ::conf(keyword,default,GotoManuelAutoBis) ] } { set ::conf(keyword,default,GotoManuelAutoBis) "$::caption(keyword,manuel)" }
   if { ! [ info exists ::conf(keyword,default,GotoManuelAutoTer) ] } { set ::conf(keyword,default,GotoManuelAutoTer) "$::caption(keyword,manuel)" }

   #--- Configuration par defaut
   if { ! [ info exists ::conf(keyword,default,configName) ] }        { set ::conf(keyword,default,configName)        "default" }

   if { ! [ info exists ::conf(keyword,default,check) ] } {
      if { [ info exists ::conf(keyword,visu1,check) ] } {
         set ::conf(keyword,default,check) $::conf(keyword,visu1,check)
         unset ::conf(keyword,visu1,check)
      } else {
         set ::conf(keyword,default,check) "1,check,CRPIX1 1,check,CRPIX2 1,check,DETNAM 1,check,SWMODIFY 1,check,SWCREATE"
      }
   }
}

#------------------------------------------------------------------------------
## @brief ouvre la fenêtre de configuration de l'en-tête FITS d'un outil d'acquisition sélectionné
#  @param visuNo             numéro de la visu
#  @param configNameVariable nom de la variable contenant la configuration de l'outil d'acquisition sélectionné
#
proc ::keyword::run { visuNo configNameVariable } {
   variable private

   #--- je charge le package Tablelist
   package require Tablelist

   #--- j'initialise le nom de la configuration
   #--- par exemple : private($visuNo,configName)        --> "Acquisition"
   #--- par exemple :private($visuNo,configNameVariable) --> "::conf(acqfc,keywordConfigName) "
   set private($visuNo,configName)         [ set $configNameVariable ]
   set private($visuNo,configNameVariable) $configNameVariable

   #--- Creation des variables de la boite de configuration de l'en-tete FITS si elles n'existent pas
   if { ! [ info exists private($visuNo,disabled) ] } { set private($visuNo,disabled) "" }

   #--- j'ajoute un listener sur la configuration de l'observatoire
   ::confPosObs::addPosObsListener [list ::keyword::onChangeConfPosObs $visuNo]

   #--- j'ajoute un listener sur la configuration optique
   ::confOptic::addOpticListener [list ::keyword::onChangeConfOptic $visuNo]

   #--- j'ajoute des listeners sur la camera et sa temperature
   ::confVisu::addCameraListener $visuNo [list ::keyword::onChangeConfOptic $visuNo]
   ::confVisu::addCameraListener $visuNo [list ::keyword::onChangeCellDim $visuNo]
   ::confVisu::addCameraListener $visuNo [list ::keyword::onChangeCRPIXCRVAL $visuNo]
   ::confVisu::addCameraListener $visuNo [list ::keyword::onChangeTemperature $visuNo]

   #--- je recupere la configuration de l'observateur et de l'observatoire
   onChangeConfPosObs $visuNo

   #--- je recupere la configuration optique
   onChangeConfOptic $visuNo

   #--- je recupere les dimensions des photosites
   onChangeCellDim $visuNo

   #--- je recupere les mots cles CRPIX1, CRPIX2, CRVAL1 et CRVAL2
   onChangeCRPIXCRVAL $visuNo

   #--- je recupere la consigne et la temperature du CCD
   onChangeTemperature $visuNo

   #--- je recupere la temperature du site, la pression atmospherique
   #--- et l'humidite relative (si une station meteo est connectee)
   onChangeMeteoData $visuNo

   #--- je recupere le nom de l'objet (si mode automatique)
   onChangeObjname $visuNo

   #--- je recupere l'ascension droite et la declinaison l'objet (si mode automatique)
   onChangeRaDec $visuNo

   #--- je recupere l'equinoxe des coordonnees de l'objet  (si mode automatique)
   onChangeEquinox $visuNo

   #--- je calcule la masse d'air
   calculateAirMass $visuNo

   #--- je mets a jour la procedure a appeler pour rafraichir CCD_TEMP
   for { set i 0 } { $i < [ llength $private(infosMotsClefs) ] } { incr i } {
      set ligne [ lindex $private(infosMotsClefs) $i ]
      if { [ lindex $ligne 0 ] == "CCD_TEMP" } {
         set ligne [ lreplace $ligne 5 5 "::keyword::onChangeTemperature $visuNo" ]
         set private(infosMotsClefs) [ lreplace $private(infosMotsClefs) $i $i $ligne ]
         break
      }
   }

   #--- je mets a jour la procedure a appeler pour ouvrir la fenetre de consigne de temperature
   for { set i 0 } { $i < [ llength $private(infosMotsClefs) ] } { incr i } {
      set ligne [ lindex $private(infosMotsClefs) $i ]
      if { [ lindex $ligne 0 ] == "SET_TEMP" } {
         set ligne [ lreplace $ligne 5 5 "::keyword::openSetTemperature $visuNo" ]
         set private(infosMotsClefs) [ lreplace $private(infosMotsClefs) $i $i $ligne ]
         break
      }
   }

   #--- Creation de l'interface graphique
   set tkParent [ ::confVisu::getBase $visuNo ]
   set private($visuNo,frm) $tkParent.keyword
   if { [ winfo exists $private($visuNo,frm) ] } {
      wm withdraw $private($visuNo,frm)
      wm deiconify $private($visuNo,frm)
      focus $private($visuNo,frm)
   } else {
      ::keyword::createDialog $visuNo
   }

   #--- Configuration relative aux combobox
   ::keyword::onChangeValueComboBox $visuNo
}

#------------------------------------------------------------------------------
## @brief calcule et met à jour le mot clé de la masse d'air
#  @param visuNo numéro de la visu
#
proc ::keyword::calculateAirMass { visuNo } {
   variable private
   global audace

   #--- Je calcule la masse d'air si les mots cles suivants existent :
   #--- DATE-OBS, EXPOSURE, SITELONG, SITELAT, SITEELEV, RA et DEC

   #--- Je regarde si le mot cle DATE-OBS n'est pas vide
   set date [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd DATE-OBS ] 1 ]
   if { $date == "" } {
      set private(airmass) ""
      return $private(airmass)
   }

   #--- Je regarde si le mot cle EXPOSURE n'est pas vide
   set expo [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd EXPOSURE ] 1 ]
   if { $expo == "" } {
      set private(airmass) ""
      return $private(airmass)
   }

   set jd [ expr [ mc_date2jd $date ]+0.5*$expo/86400 ]

   #--- Je regarde si les mots cles SITELONG, SITELAT et SITEELEV sont coches
   set a 0
   set b 0
   set c 0
   set listeMotsClesCoches $::conf(keyword,$private($visuNo,configName),check)
   set longListe [ llength $listeMotsClesCoches ]
   for { set i 0 } { $i < $longListe } { incr i 1 } {
      if { [ lindex $listeMotsClesCoches $i ] == "1,check,SITELONG" } {
         set a 1
      }
      if { [ lindex $listeMotsClesCoches $i ] == "1,check,SITELAT" } {
         set b 1
      }
      if { [ lindex $listeMotsClesCoches $i ] == "1,check,SITEELEV" } {
         set c 1
      }
   }
   if { [ expr $a + $b + $c ] != "3" } {
      set private(airmass) ""
      return $private(airmass)
   }

   set home $audace(posobs,observateur,gps)

   #--- Je regarde si les mots cles RA et DEC sont coches
   set d 0
   set e 0
   set listeMotsClesCoches $::conf(keyword,$private($visuNo,configName),check)
   set longListe [ llength $listeMotsClesCoches ]
   for { set i 0 } { $i < $longListe } { incr i 1 } {
      if { [ lindex $listeMotsClesCoches $i ] == "1,check,RA" } {
         set d 1
      }
      if { [ lindex $listeMotsClesCoches $i ] == "1,check,DEC" } {
         set e 1
      }
   }
   if { [ expr $d + $e ] != "2" } {
      set private(airmass) ""
      return $private(airmass)
   }

   #--- Je regarde si le mot cle RA n'est pas vide
   set ra $private(ra)
   if { $ra == "" } {
      set private(airmass) ""
      return $private(airmass)
   } else {
      set ra [ mc_angle2deg $ra ]
   }

   #--- Je regarde si le mot cle DEC n'est pas vide
   set dec $private(dec)
   if { $dec == "" } {
      set private(airmass) ""
      return $private(airmass)
   } else {
      set dec [ mc_angle2deg $dec ]
   }

   #--- Je calcule l'elevation de l'astre
   set hip  [ list 1 0.0 $ra $dec J2000.0 now 0 0 0 ]
   set res  [ mc_hip2tel $hip $jd $home $audace(meteo,obs,pressure) [ expr $audace(meteo,obs,temperature) + 273.15 ] ]
   set elev [ lindex $res 14 ]

   #--- Je calcule la masse d'air
   set z    [ expr 90.-$elev ]
   set z    [ mc_angle2rad $z ]
   if { $elev>0 } {
      set secz [ expr 1./cos($z) ]
      set airmass [ expr $secz-0.0018167*$secz+0.02875*$secz*$secz+0.0008083*$secz*$secz*$secz ]
   } else {
      set airmass -1
   }
   set private(airmass) $airmass
}

#------------------------------------------------------------------------------
## @brief met à jour les mots clés des noms des observateurs, de l'observatoire et de l'organisation
#  @param visuNo numéro de la visu
#  @param args   valeurs fournies par le gestionnaire de listener
#
proc ::keyword::onChangeConfPosObs { visuNo args } {
   variable private

   set private(nom_observateur)  [ ::keyword::headerFitsCompliant $::conf(posobs,nom_observateur) ]
   set private(nom_observatoire) [ ::keyword::headerFitsCompliant $::conf(posobs,nom_observatoire) ]
   set private(nom_organisation) [ ::keyword::headerFitsCompliant $::conf(posobs,nom_organisation) ]
}

#------------------------------------------------------------------------------
## @brief met à jour les mots clés liés à la configuration optique
#  @param visuNo numéro de la visu
#  @param args   valeurs fournies par le gestionnaire de listener
#
proc ::keyword::onChangeConfOptic { visuNo args } {
   variable private

   set camItem [ ::confVisu::getCamItem $visuNo ]
   if { $camItem != "" } {
      set combinaison [ ::confOptic::getConfOptic $camItem ]
      set private(instrument)        [ ::keyword::headerFitsCompliant [lindex $combinaison 0] ]
      set private(diametre)          [lindex $combinaison 1]
      set private(focale_resultante) [lindex $combinaison 2]
   } else {
      set private(instrument)        ""
      set private(diametre)          ""
      set private(focale_resultante) ""
   }
}

#------------------------------------------------------------------------------
## @brief met à jour les mots clés de la temperature de consigne et de la température réelle du CCD
#  @param visuNo numéro de la visu
#  @param args   valeurs fournies par le gestionnaire de listener
#
proc ::keyword::onChangeTemperature { visuNo args } {
   variable private

   set camItem [ ::confVisu::getCamItem $visuNo ]

   set private(set_temperature_ccd) [ ::confCam::setTempCCD $camItem ]
   set private(temperature_ccd)     [ ::confCam::getTempCCD $camItem ]
}

#------------------------------------------------------------------------------
## @brief met à jour les mots clés des dimensions des photosites
#  @param visuNo numéro de la visu
#  @param args   valeurs fournies par le gestionnaire de listener
#
proc ::keyword::onChangeCellDim { visuNo args } {
   variable private

   set camItem [ ::confVisu::getCamItem $visuNo ]
   set camNo   [ ::confCam::getCamNo $camItem ]

   if { $camNo != 0 } {
      set private(cell_dim_x) [ expr [ lindex [ cam$camNo celldim ] 0 ] * 1e6 ]
      set private(cell_dim_y) [ expr [ lindex [ cam$camNo celldim ] 1 ] * 1e6 ]
      set private(pix_dim_x)  [ expr [ lindex [ cam$camNo pixdim ] 0 ] * 1e6 ]
      set private(pix_dim_y)  [ expr [ lindex [ cam$camNo pixdim ] 1 ] * 1e6 ]
   } else {
      set private(cell_dim_x) ""
      set private(cell_dim_y) ""
      set private(pix_dim_x)  ""
      set private(pix_dim_y)  ""
   }
}

#------------------------------------------------------------------------------
## @brief met à jour les mots clés CRPIX1, CRPIX2,CRVAL1 et CRVAL2
#  @param visuNo numéro de la visu
#  @param args   valeurs fournies par le gestionnaire de listener
#
proc ::keyword::onChangeCRPIXCRVAL { visuNo args } {
   variable private

   set camItem [ ::confVisu::getCamItem $visuNo ]
   set camNo   [ ::confCam::getCamNo $camItem ]

   if { $camNo != 0 } {
      set private(CRPIX1) [ expr [ lindex [ cam$camNo nbpix ] 0 ] / 2.0 ]
      set private(CRPIX2) [ expr [ lindex [ cam$camNo nbpix ] 1 ] / 2.0 ]
   } else {
      set private(CRPIX1) ""
      set private(CRPIX2) ""
   }

   set telNo [ ::confCam::getCamNo $camItem ]

   if { [ ::confTel::isReady ] == 1 } {
      set private(CRVAL1) $::audace(telescope,getra)
      set private(CRVAL2) $::audace(telescope,getdec)
   } else {
      set private(CRVAL1) ""
      set private(CRVAL2) ""
   }
}

#------------------------------------------------------------------------------
## @brief met à jour les mots clés TEMP, PRESSURE et HUMIDITY
#  @param visuNo numéro de la visu
#
proc ::keyword::onChangeMeteoData { visuNo } {
   variable private

   if { $private(setMeteoData) == "$::caption(keyword,stationMeteo)" } {
      set private(temperature_site) [ format "%3.1f" $::audace(meteo,obs,temperature) ]
      set private(pression_site)    [ format "%6.1f" $::audace(meteo,obs,pressure) ]
      set private(humidite_site)    [ format "%3.1f" $::audace(meteo,obs,humidity) ]
   }
}

#------------------------------------------------------------------------------
## @brief met à jour les mots clés OBJECT et OBJNAME du nom de l'objet
#  @param visuNo numéro de la visu
#
proc ::keyword::onChangeObjname { visuNo } {
   variable private

   if { $private(GotoManuelAuto) == "$::caption(keyword,automatic)" } {
      set private(object)  $::audace(telescope,targetName)
      set private(objName) $::audace(telescope,targetName)
   }
}

#------------------------------------------------------------------------------
## @brief met à jour les mots clés RA et DEC de l'ascension droite et de la déclinaison de l'objet
#  @param visuNo numéro de la visu
#
proc ::keyword::onChangeRaDec { visuNo } {
   variable private

   if { $private(GotoManuelAutoBis) == "$::caption(keyword,automatic)" } {
      set private(ra)  $::audace(telescope,targetRa)
      set private(dec) $::audace(telescope,targetDec)
   }
}

#------------------------------------------------------------------------------
## @brief met à jour le mot clé EQUINOX de l'équinoxe des coordonnées de l'objet
#  @param  visuNo numéro de la visu
#
proc ::keyword::onChangeEquinox { visuNo } {
   variable private

   if { $private(GotoManuelAutoTer) == "$::caption(keyword,automatic)" } {
      set private(equinoxe) $::audace(telescope,targetEquinox)
   }
}

#------------------------------------------------------------------------------
## @brief ouvre la fenêtre pour mettre à jour la consigne de température du CCD
#  @param  visuNo numéro de la visu
#
proc ::keyword::openSetTemperature { visuNo } {
   set camItem [ ::confVisu::getCamItem $visuNo ]

   if { [ ::confCam::getPluginProperty $camItem hasSetTemp ] == "1" } {
      if { [ ::confLink::getLinkNamespace $::conf(audine,port) ] == "ethernaude" } {
         ::AlAudineNT::run $::audace(base).alimAlAudineNT
      } else {
         ::confCam::run
      }
   }
}

#------------------------------------------------------------------------------
#  brief commande associée au changement de valeur dans la combobox
#  param visuNo numéro de la visu
#
proc ::keyword::onChangeValueComboBox { visuNo } {
   variable private

   #--- Mots cles TEMP, PRESSURE et HUMIDITY
   if { $private(setMeteoData) == "$::caption(keyword,stationMeteo)" } {
      #--- Je recupere le nomTK des entry
      set wTEMP     [$::keyword::private($visuNo,table) windowpath TEMP,valeur ]
      set wPRESSURE [$::keyword::private($visuNo,table) windowpath PRESSURE,valeur ]
      set wHUMIDITY [$::keyword::private($visuNo,table) windowpath HUMIDITY,valeur ]
      #--- Je configure l'etat des entry
      $wTEMP     configure -state disabled
      $wPRESSURE configure -state disabled
      $wHUMIDITY configure -state disabled
      #--- Je recupere les TEMP, PRESSURE et HUMIDITY du site
      set private(temperature_site) [ format "%3.1f" $::audace(meteo,obs,temperature) ]
      set private(pression_site)    [ format "%6.1f" $::audace(meteo,obs,pressure) ]
      set private(humidite_site)    [ format "%3.1f" $::audace(meteo,obs,humidity) ]
   } elseif { $private(setMeteoData) == "$::caption(keyword,manuel)" } {
      #--- Je recupere le nomTK des entry
      set wTEMP     [$::keyword::private($visuNo,table) windowpath TEMP,valeur ]
      set wPRESSURE [$::keyword::private($visuNo,table) windowpath PRESSURE,valeur ]
      set wHUMIDITY [$::keyword::private($visuNo,table) windowpath HUMIDITY,valeur ]
      #--- Je configure l'etat des entry
      $wTEMP     configure -state normal
      $wPRESSURE configure -state normal
      $wHUMIDITY configure -state normal
      #--- Je vide les champs correspondants
      set private(temperature_site) ""
      set private(pression_site)    ""
      set private(humidite_site)    ""
   }

   #--- Mots cles OBJECT et OBJNAME
   if { $private(GotoManuelAuto) == "$::caption(keyword,automatic)" } {
      #--- Je recupere le nomTK de l'entry
      set wOBJECT  [$::keyword::private($visuNo,table) windowpath OBJECT,valeur ]
      set wOBJNAME [$::keyword::private($visuNo,table) windowpath OBJNAME,valeur ]
      #--- Je configure l'etat de l'entry
      $wOBJECT  configure -state disabled
      $wOBJNAME configure -state disabled
      #--- Je recupere OBJNAME
      set private(object)  $::audace(telescope,targetName)
      set private(objName) $::audace(telescope,targetName)
   } elseif { $private(GotoManuelAuto) == "$::caption(keyword,manuel)" } {
      #--- Je recupere le nomTK de l'entry
      set wOBJECT  [$::keyword::private($visuNo,table) windowpath OBJECT,valeur ]
      set wOBJNAME [$::keyword::private($visuNo,table) windowpath OBJNAME,valeur ]
      #--- Je configure l'etat de l'entry
      $wOBJECT  configure -state normal
      $wOBJNAME configure -state normal
      #--- Je vide les champs correspondants
      set private(object)  ""
      set private(objName) ""
   }

   #--- Mots cles RA et DEC
   if { $private(GotoManuelAutoBis) == "$::caption(keyword,automatic)" } {
      #--- Je recupere le nomTK des entry
      set wRA  [$::keyword::private($visuNo,table) windowpath RA,valeur ]
      set wDEC [$::keyword::private($visuNo,table) windowpath DEC,valeur ]
      #--- Je configure l'etat des entry
      $wRA  configure -state disabled
      $wDEC configure -state disabled
      #--- Je recupere les RA et DEC de la cible
      set private(ra)  $::audace(telescope,targetRa)
      set private(dec) $::audace(telescope,targetDec)
   } elseif { $private(GotoManuelAutoBis) == "$::caption(keyword,manuel)" } {
      #--- Je recupere le nomTK des entry
      set wRA  [$::keyword::private($visuNo,table) windowpath RA,valeur ]
      set wDEC [$::keyword::private($visuNo,table) windowpath DEC,valeur ]
      #--- Je configure l'etat des entry
      $wRA  configure -state normal
      $wDEC configure -state normal
      #--- Je vide les champs correspondants
      set private(ra)  ""
      set private(dec) ""
   }

   #--- Mot cle EQUINOX
   if { $private(GotoManuelAutoTer) == "$::caption(keyword,automatic)" } {
      #--- Je recupere le nomTK de l'entry
      set wEQUINOX [$::keyword::private($visuNo,table) windowpath EQUINOX,valeur ]
      #--- Je configure l'etat de l'entry
      $wEQUINOX configure -state disabled
      #--- Je recupere l'equinoxe
      set private(equinoxe) $::audace(telescope,targetEquinox)
   } elseif { $private(GotoManuelAutoTer) == "$::caption(keyword,manuel)" } {
      #--- Je recupere le nomTK de l'entry
      set wEQUINOX [$::keyword::private($visuNo,table) windowpath EQUINOX,valeur ]
      #--- Je configure l'etat de l'entry
      $wEQUINOX configure -state normal
     #--- Je vide le champ correspondant
      set private(equinoxe) ""
   }

   #--- Mot cle IMAGETYP
   if { $private(typeImageSelected) == "$::caption(keyword,newValue)" } {
      #--- Je choisis une valeur non disponible dans la liste
      set private(tempTypeImage) $private(typeImage)
      set private(typeImage)     ""
      ::keyword::newValueTypeImage $visuNo
   } else {
      if { [ info exists private(base) ] == 1 } {
         if { [ winfo exists $private(base) ] == 1 } {
            destroy $private(base)
         }
      }
      set private(typeImage) $private(typeImageSelected)
   }
}

#------------------------------------------------------------------------------
## @brief permet d'ajouter un type d'image non proposé dans la liste
#  @param visuNo numéro de la visu
#
proc ::keyword::newValueTypeImage { visuNo } {
   variable private

   #--- Initialisation
   set private(base)              $::audace(base).newValue
   set private(newValueTypeImage) ""

   #--- Verifie si la Toplevel existe deja
   if { [ winfo exists $private(base) ] } {
      wm withdraw $private(base)
      wm deiconify $private(base)
      focus $private(base)
      return
   }

   #--- Toplevel
   toplevel $private(base) -class Toplevel
   wm title $private(base) $::caption(keyword,newValue)
   wm transient $private(base) $private($visuNo,frm)
   set posx [ lindex [ split [ wm geometry $private($visuNo,frm) ] "+" ] 1 ]
   set posy [ lindex [ split [ wm geometry $private($visuNo,frm) ] "+" ] 2 ]
   wm geometry $private(base) +[ expr $posx + 140 ]+[ expr $posy + 500 ]
   wm resizable $private(base) 0 0
   wm protocol $private(base) WM_DELETE_WINDOW "::keyword::cmdCancelNewValueTypeImage"
   #--- Label et entry
   frame $private(base).newValue -borderwidth 2 -relief raised
      label $private(base).newValue.lab1 -text "$::caption(keyword,saisirNewValue)"
      pack $private(base).newValue.lab1 -side left -anchor se -padx 5 -pady 5 -expand 0
      entry $private(base).newValue.ent1 -textvariable ::keyword::private(newValueTypeImage) \
         -width 15 -relief groove -justify center
      pack $private(base).newValue.ent1 -side left -anchor se -padx 5 -pady 5 -expand 0
   pack $private(base).newValue -side top -fill x -expand 0
   #--- Boutons
   frame $private(base).button -borderwidth 2 -relief raised
      #--- Button OK
      button $private(base).button.ok -text $::caption(keyword,ok) -borderwidth 2 \
         -command "::keyword::cmdOKNewValueTypeImage $visuNo"
      pack $private(base).button.ok -side left -anchor center -padx 10 -pady 5 \
         -ipadx 10 -ipady 5 -expand 0
      #--- Button Annuler
      button $private(base).button.annuler -text $::caption(keyword,annuler) -borderwidth 2 \
         -command "::keyword::cmdCancelNewValueTypeImage"
      pack $private(base).button.annuler -side right -anchor center -padx 10 -pady 5 \
         -ipadx 10 -ipady 5 -expand 0
   pack $private(base).button -side top -anchor center -fill x -expand 0

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private(base)
}

#------------------------------------------------------------------------------
#  brief commande associée au boutton "OK" de la fenêtre d'ajout d'un type d'image
#  param visuNo nuémro de la visu
#
proc ::keyword::cmdOKNewValueTypeImage { visuNo } {
   variable private

   if { $private(newValueTypeImage) != "" } {
      destroy $private(base)
      set private(typeImage)          $private(newValueTypeImage)
      set private(typeImageSelected)  $private(newValueTypeImage)
      #--- Je reconstitue la liste de la combobox
      lappend ::conf(keyword,listTypeImage) $private(newValueTypeImage)
      set private(listTypeImage)      $::conf(keyword,listTypeImage)
      lappend private(listTypeImage)  $::caption(keyword,newValue)
      set w [ $private($visuNo,table) windowpath IMAGETYP,modification ]
      $w configure -values $private(listTypeImage)
   }
}

#------------------------------------------------------------------------------
#  brief commande associée au bouton "Annuler" de la fenêtre d'ajout d'un type d'image
#
proc ::keyword::cmdCancelNewValueTypeImage { } {
   variable private

   destroy $private(base)
   set private(typeImage)         $private(tempTypeImage)
   set private(typeImageSelected) $private(tempTypeImage)
}

#------------------------------------------------------------------------------
#  brief fonction appelée pour rendre la capture des mots clés OBJNAME, RA et DEC automatique
#
proc ::keyword::setKeywordsObjRaDecAuto { visuNo } {
   variable private

   set ::conf(keyword,$private($visuNo,configName),GotoManuelAuto)    "$::caption(keyword,automatic)"
   set ::conf(keyword,$private($visuNo,configName),GotoManuelAutoBis) "$::caption(keyword,automatic)"
   set private(GotoManuelAuto)                                        $::conf(keyword,$private($visuNo,configName),GotoManuelAuto)
   set private(GotoManuelAutoBis)                                     $::conf(keyword,$private($visuNo,configName),GotoManuelAutoBis)
}

#------------------------------------------------------------------------------
#  brief fonction appelée pour rendre la capture des mots clés OBJNAME, RA et DEC manuelle
#
#
proc ::keyword::setKeywordsObjRaDecManuel { visuNo } {
   variable private

   set ::conf(keyword,$private($visuNo,configName),GotoManuelAuto)    "$::caption(keyword,manuel)"
   set ::conf(keyword,$private($visuNo,configName),GotoManuelAutoBis) "$::caption(keyword,manuel)"
   set private(GotoManuelAuto)                                        $::conf(keyword,$private($visuNo,configName),GotoManuelAuto)
   set private(GotoManuelAutoBis)                                     $::conf(keyword,$private($visuNo,configName),GotoManuelAutoBis)
}

#------------------------------------------------------------------------------
#  brief fonction appelée pour rendre la capture des mots clés RA et DEC automatique
#
proc ::keyword::setKeywordsRaDecAuto { visuNo } {
   variable private

   set ::conf(keyword,$private($visuNo,configName),GotoManuelAutoBis) "$::caption(keyword,automatic)"
   set private(GotoManuelAutoBis)                                     $::conf(keyword,$private($visuNo,configName),GotoManuelAutoBis)
}

#------------------------------------------------------------------------------
#  brief fonction appelée pour rendre la capture des mots clés RA et DEC manuelle
#
proc ::keyword::setKeywordsRaDecManuel { visuNo } {
   variable private

   set ::conf(keyword,$private($visuNo,configName),GotoManuelAutoBis) "$::caption(keyword,manuel)"
   set private(GotoManuelAutoBis)                                     $::conf(keyword,$private($visuNo,configName),GotoManuelAutoBis)
}

#------------------------------------------------------------------------------
#  brief fonction appelée pour rendre la capture du mot clé EQUINOX automatique
#
proc ::keyword::setKeywordsEquinoxAuto { visuNo } {
   variable private

   set ::conf(keyword,$private($visuNo,configName),GotoManuelAutoTer) "$::caption(keyword,automatic)"
   set private(GotoManuelAutoTer)                                     $::conf(keyword,$private($visuNo,configName),GotoManuelAutoTer)
}

#------------------------------------------------------------------------------
#  brief fonction appelée pour rendre la capture du mot clé EQUINOX manuelle
#
proc ::keyword::setKeywordsEquinoxManuel { visuNo } {
   variable private

   set ::conf(keyword,$private($visuNo,configName),GotoManuelAutoTer) "$::caption(keyword,manuel)"
   set private(GotoManuelAutoTer)                                     $::conf(keyword,$private($visuNo,configName),GotoManuelAutoTer)
}

#------------------------------------------------------------------------------
## @brief retourne la liste de valeurs des mots clés cochés
#  @param visuNo          numéro de la visu:
#  @param configName      nom de la configuration des mots clés
#  @param keywordNameList liste des mots clés demandés (paramètre optionnel)
#  Si le paramètre n'est pas précisé ou s'il vaut une chaîne vide
#  la fonction retourne les valeurs de tous les mots clés qui sont cochés
#  @return  liste de liste des valeurs des mots clés
#  @details la valeur de chaque mot clé est une liste de 5 elements
#    { {nom valeur type commentaire unite } {nom valeur type commentaire unite } ...}
#  @code
#  Exemple 1:
#  ::keyword::getKeywords 1 default
#  # { {SITENAME {Haute Provence} string {Observatory name} {}} {GEODSYS WGS84 string {Geodetic datum for observatory position} {}} ...}
#  Exemple 2:
#  ::keyword::getKeywords 1 default {IMAGETYP SITENAME }
#  # {{IMAGETYP Object string {Image type} {}} {SITENAME {Haute Provence} string {Observatory name} {}} }
#  @endcode
#
proc ::keyword::getKeywords { visuNo configName { keywordNameList "" } } {
   variable private

   #--- je verifie que la variable existe
   if { ! [ info exists ::conf(keyword,$configName,check) ] } { set ::conf(keyword,$configName,check) "default" }

   #--- j'initialise le nom de la configuration
   set private($visuNo,configName) $configName

   #--- je verifie que la visu existe
   ::confVisu::getBase $visuNo

   #--- je recupere la configuration de l'observateur et de l'observatoire
   onChangeConfPosObs $visuNo

   #--- je recupere la configuration optique
   onChangeConfOptic $visuNo

   #--- je recupere les dimensions des photosites
   onChangeCellDim $visuNo

   #--- je recupere les mots cles CRPIX1, CRPIX2, CRVAL1 et CRVAL2
   onChangeCRPIXCRVAL $visuNo

   #--- je recupere la temperature du site, la pression atmospherique
   #--- et l'humidite relative (si une station meteo est connectee)
   onChangeMeteoData $visuNo

   #--- je recupere le nom de l'objet (si mode automatique)
   onChangeObjname $visuNo

   #--- je recupere l'ascension droite et la declinaison l'objet (si mode automatique)
   onChangeRaDec $visuNo

   #--- je recupere l'equinoxe des coordonnees de l'objet (si mode automatique)
   onChangeEquinox $visuNo

   #--- je calcule la masse d'air
   calculateAirMass $visuNo

   if { [llength $keywordNameList] == 0 } {
      #--- je recupere les mots cles coches
      set result ""
      foreach name $::conf(keyword,$private($visuNo,configName),check) {
         set motclef [lindex [split $name ","] 2]
         foreach infosMotClef $private(infosMotsClefs) {
            if { [ lindex $infosMotClef 0 ] == $motclef } {
               #--- je recupere la temperature du CCD
               if { $motclef == "CCD_TEMP" } {
                  onChangeTemperature $visuNo
               }
               set textVariable [lindex $infosMotClef 2]
               set valeur       [set $textVariable]
               set type         [lindex $infosMotClef 10]
               set commentaire  [lindex $infosMotClef 11]
               set unite        [lindex $infosMotClef 12]
               #--- je convertis CRVAL1 et CRVAL2 en degres decimaux
               if { $motclef == "CRVAL1" } {
                  set valeur [ mc_angle2deg $valeur ]
               }
               if { $motclef == "CRVAL2" } {
                  set valeur [ mc_angle2deg $valeur ]
               }
               #--- je convertis RA et DEC en degres decimaux
               if { $motclef == "RA" } {
                  set valeur [ mc_angle2deg $valeur ]
               }
               if { $motclef == "DEC" } {
                  set valeur [ mc_angle2deg $valeur ]
               }
               #--- je mets en forme l'equinoxe
               if { $motclef == "EQUINOX" } {
                  set valeur [ ::keyword::equinoxCompliant $valeur ]
                  if { $valeur == "now" } {
                     set type "string"
                  } else {
                     set type "float"
                  }
               }
               #--- je mets en forme le commentaire
               if { $motclef == "COMMENT" } {
                  set commentaire [ ::keyword::headerFitsCompliant $valeur ]
                  set valeur      ""
               }
               #--- j'ajoute les mots cles dans le resultat
               lappend result [list $motclef $valeur $type $commentaire $unite]
               break
            }
         }
      }
   } else {
      #--- je recupere les mots cles de la liste fournie en parametre
      set result ""
      foreach keywordName $keywordNameList {
         foreach infosMotClef $private(infosMotsClefs) {
            if { [ lindex $infosMotClef 0 ] == $keywordName } {
               if { $keywordName == "CCD_TEMP" } {
                  #--- je recupere la temperature du CCD
                  onChangeTemperature $visuNo
               }
               set textVariable [lindex $infosMotClef 2]
               set valeur       [set $textVariable]
               set type         [lindex $infosMotClef 10]
               set commentaire  [lindex $infosMotClef 11]
               set unite        [lindex $infosMotClef 12]
               #--- j'ajoute les mots cles dans le resultat
               lappend result [list $keywordName $valeur $type $commentaire $unite]
               break
            }
         }
      }
   }
   return $result
}

#------------------------------------------------------------------------------
#  brief rend les mots clés FITS conformes à la norme
#  details supprime les accents, les cédilles, etc.
#  param stringInput : mots clés FITS
#  return stringOutput : mots clés FITS conformes
#
proc ::keyword::headerFitsCompliant { stringInput } {
   set res $stringInput
   set res [regsub -all {[é;ê;è;ë]} $res e]
   set res [regsub -all {[à;â;ä]} $res a]
   set res [regsub -all {[ï;î]} $res i]
   set res [regsub -all {[ö;ô]} $res o]
   set res [regsub -all {[ü;û;ù]} $res u]
   set res [regsub -all {[ç]} $res c]
   set res [regsub -all {[']} $res " "]
   set stringOutput $res
   return $stringOutput
}

#------------------------------------------------------------------------------
#  brief rend l'équinoxe conforme à la norme
#  param stringInput : mots clés FITS
#  return stringOutput : mots clés FITS conformes

proc ::keyword::equinoxCompliant { stringInput } {
   set res $stringInput
   set res [ regsub -all {[J]} $res "" ]
   set res [ regsub -all {[B]} $res "" ]
   set stringOutput $res
   return $stringOutput
}

#------------------------------------------------------------------------------
#  brief crée l'interface graphique de tous les mots clés sélectionnables
#  param visuNo numéro de la visu
#
proc ::keyword::createDialog { visuNo } {
   variable private

   set frm $private($visuNo,frm)

   #--- Recupere la configuration dans le tableau private(...)
   set private($visuNo,geometry)                   $::conf(keyword,geometry)
   set private($private($visuNo,configName),check) $::conf(keyword,$private($visuNo,configName),check)
   set private(setMeteoData)                       $::conf(keyword,$private($visuNo,configName),setMeteoData)
   set private(GotoManuelAuto)                     $::conf(keyword,$private($visuNo,configName),GotoManuelAuto)
   set private(GotoManuelAutoBis)                  $::conf(keyword,$private($visuNo,configName),GotoManuelAutoBis)
   set private(GotoManuelAutoTer)                  $::conf(keyword,$private($visuNo,configName),GotoManuelAutoTer)

   #--- Toplevel
   toplevel $frm
   wm geometry $frm $private($visuNo,geometry)
   wm minsize $frm 450 150
   wm resizable $frm 1 1
   wm title $frm "$::caption(keyword,titre) (visu$visuNo - $::caption(keyword,camera) [ ::confVisu::getCamItem $visuNo ])"
   wm protocol $frm WM_DELETE_WINDOW "::keyword::cmdClose $visuNo"

   #--- Frame de gestion de la configuration des mots cles
   frame $frm.config -borderwidth 1 -relief raised

      #--- Frame de la combobox de choix de la configuration des mots cles
      frame $frm.config.choix -borderwidth 0 -relief raised

         #--- Liste des configurations
         set configList [ ::keyword::getConfigurationList ]

         #--- Nom de la configuration
         label $frm.config.choix.labconfig -text "$::caption(keyword,nom_config)"
         pack $frm.config.choix.labconfig -anchor w -side left -padx 10 -pady 5

         ComboBox $frm.config.choix.configHeader \
            -width 42         \
            -height 10        \
            -relief sunken    \
            -borderwidth 2    \
            -editable 0       \
            -modifycmd "::keyword::cbCommand $visuNo" \
            -values $configList
         pack $frm.config.choix.configHeader -anchor w -side left -padx 10 -pady 5

         if { [info exists ::conf(keyword,$private($visuNo,configName),configName)] != 0 } {
            set index [ lsearch $configList $::conf(keyword,$private($visuNo,configName),configName) ]
            if { $index == -1 } {
               #--- je selectionne la premiere configuration, si celle de la derniere utilisee n'existe plus
               set index 0
            }
         } else {
            #--- je selectionne la premiere configuration, si celle de la derniere utilisee n'existe plus
            set index 0
         }

         #--- je selectionne la configuration dans la combobox
         $frm.config.choix.configHeader setvalue "@$index"

      pack $frm.config.choix -side top -fill x -expand 0

      #--- Frame des boutons
      frame $frm.config.but -borderwidth 0 -relief raised

         #--- Gestion des noms des configurations
         button $frm.config.but.add -text "$::caption(keyword,ajouter_config)" -borderwidth 2 \
            -command "::keyword::addConfig $visuNo"
         pack $frm.config.but.add -anchor center -side left -padx 5 -pady 5 -ipadx 5
         button $frm.config.but.del -text "$::caption(keyword,supprimer_config)" -borderwidth 2 \
            -command "::keyword::delConfig $visuNo"
         pack $frm.config.but.del -anchor center -side left -padx 5 -pady 5 -ipadx 5
         button $frm.config.but.copy -text "$::caption(keyword,copier_config)" -borderwidth 2 \
            -command "::keyword::copyConfig $visuNo"
         pack $frm.config.but.copy -anchor center -side left -padx 5 -pady 5 -ipadx 5

         #--- Decocher tous les mots cles de la configuration courante
         button $frm.config.but.decheck -text "$::caption(keyword,selectDeselectAll)" -borderwidth 2 \
            -command "::keyword::selectDeselectAllKeywords $visuNo $private($visuNo,configName)"
         pack $frm.config.but.decheck -anchor center -side right -padx 5 -pady 5 -ipadx 5

      pack $frm.config.but -side bottom -fill x -expand 0

   pack $frm.config -side top -fill x -expand 0

   #--- Frame des boutons
   frame $frm.cmd -borderwidth 1 -relief raised

      button $frm.cmd.ok -text "$::caption(keyword,ok)" -width 7 \
         -command "::keyword::cmdOk $visuNo"
      if { $::conf(ok+appliquer)=="1" } {
        pack $frm.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
      }
      button $frm.cmd.appliquer -text "$::caption(keyword,appliquer)" -width 8 \
         -command "::keyword::cmdApply $visuNo"
      pack $frm.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
      button $frm.cmd.fermer -text "$::caption(keyword,fermer)" -width 7 \
         -command "::keyword::cmdClose $visuNo"
      pack $frm.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
      button $frm.cmd.aide -text "$::caption(keyword,aide)" -width 7 \
         -command { ::keyword::afficheAide }
      pack $frm.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

   pack $frm.cmd -side bottom -fill x -expand 0

   #--- Frame des mots cles
   frame $frm.fra1 -borderwidth 0 -relief raised
      set private($visuNo,table) $frm.fra1.table
      scrollbar $frm.fra1.ysb -command "$private($visuNo,table) yview"
      scrollbar $frm.fra1.xsb -command "$private($visuNo,table) xview" -orient horizontal
      ::tablelist::tablelist $private($visuNo,table) \
         -columns [ list \
            0  ""                                      center \
            11 $::caption(keyword,colonne,categorie)   center \
            29 $::caption(keyword,colonne,description) left \
            11 $::caption(keyword,colonne,motclef)     left \
            35 $::caption(keyword,colonne,valeur)      left \
            0  ""                                      center \
            ] \
         -xscrollcommand [list $frm.fra1.xsb set] -yscrollcommand [list $frm.fra1.ysb set] \
         -labelcommand "tablelist::sortByColumn" \
         -exportselection 0 \
         -setfocus 1 \
         -activestyle none

      #--- je donne un nom a chaque colonne
      $private($visuNo,table) columnconfigure 0 -name available
      $private($visuNo,table) columnconfigure 1 -name categorie
      $private($visuNo,table) columnconfigure 2 -name description
      $private($visuNo,table) columnconfigure 3 -name motclef
      $private($visuNo,table) columnconfigure 4 -name valeur
      $private($visuNo,table) columnconfigure 5 -name modification

      #--- je place la table et les scrollbars dans la frame
      grid $private($visuNo,table) -row 0 -column 0 -sticky ewns
      grid $frm.fra1.ysb -row 0 -column 1 -sticky nsew
      grid $frm.fra1.xsb -row 1 -column 0 -sticky ew
      grid rowconfig    $frm.fra1 0 -weight 1
      grid columnconfig $frm.fra1 0 -weight 1

      #--- ajoute les mots cles dans la table
      foreach motClef $private(infosMotsClefs) {
         ajouteLigne $visuNo [ lindex $motClef 0 ] [ lindex $motClef 1 ] [ lindex $motClef 2 ] [ lindex $motClef 3 ] [ lindex $motClef 4 ] [ lindex $motClef 5 ] [ lindex $motClef 6 ] [ lindex $motClef 7 ] [ lindex $motClef 8 ] [ lindex $motClef 9 ]
      }

   pack $frm.fra1 -side top -fill both -expand 1

   #--- La fenetre est active
   focus $frm

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $frm <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm

   #--- je donne le temps au TK de creer les checkbutton dans la tablelist
   update

   #--- je mets a jour l'etat des checkbutton
   ::keyword::setCheckButtonState $visuNo

   #--- je mets a jour l'etat des widgets de la colonne modification
   ::keyword::setWidgetColumnModificationState $visuNo

   #--- je coche les mots cles de la configuration
   ::keyword::cbCommand $visuNo
}

#------------------------------------------------------------------------------
#  brief ajoute une ligne dans la table
#  param visuNo            : numéro de la visu
#  param motclef           : nom du mot clé
#  param categorie         : catégorie du mot clé
#  param textvariable      : variable contenant la valeur du mot clé
#  param stateVariable     : état de l'entry
#  param caption           : étiquette du bouton
#  param command           : procédure à appeler quand on clique sur le bouton
#  param listCombobox      : liste des valeurs de la combobox
#  param textvarComboBox   : nom de la variable contenant la valeur affichée
#  param editable          : combobox éditable ou non
#  param cmdComboBox       : fonction appellée quand on change la valeur
#
proc ::keyword::ajouteLigne { visuNo motclef categorie textvariable stateVariable caption command listCombobox textvarComboBox editable cmdComboBox } {
   variable private

   #--- je cree la ligne
   $private($visuNo,table) insert end [ list "" $categorie $::caption(keyword,description,$motclef) $motclef "" "" ]
   #--- je nomme la ligne
   $private($visuNo,table) rowconfigure end -name $motclef
   #--- je cree le checkbutton (non coche par defaut)
   set private($visuNo,check,$motclef) 0
   $private($visuNo,table) cellconfigure end,available -window [ list ::keyword::createCheckbutton $visuNo $motclef ]
   #--- je cree l'entry
   $private($visuNo,table) cellconfigure end,valeur -window [ list ::keyword::createEntry $textvariable $stateVariable ]
   #--- je cree le bouton
   if { $command != "" } {
      $private($visuNo,table) cellconfigure end,modification -window [ list ::keyword::createButton $caption $command ]
   }
   #--- je cree la combobox
   if { $listCombobox != "" } {
      $private($visuNo,table) cellconfigure end,modification -window [ list ::keyword::createComboBox $visuNo $listCombobox $textvarComboBox $editable $cmdComboBox ]
   }
}

#------------------------------------------------------------------------------
#  brief crée un checkbutton dans la table
#  param visuNo   : numéro de la visu
#  param motclef  : nom du mot clé
#  param tbl      : nom Tk de la table
#  param row      : numéro de ligne
#  param col      : numéro de colonne
#  param w        : nom Tk du checkbutton
#
proc ::keyword::createCheckbutton { visuNo motclef tbl row col w } {
   variable private

   if { $motclef == "OBJECT" } {
      checkbutton $w -highlightthickness 0 -takefocus 0 -variable ::keyword::private($visuNo,check,$motclef) \
         -command "::keyword::deselectOneKeyword $visuNo $private($visuNo,configName) OBJNAME"
   } elseif { $motclef == "OBJNAME" } {
      checkbutton $w -highlightthickness 0 -takefocus 0 -variable ::keyword::private($visuNo,check,$motclef) \
         -command "::keyword::deselectOneKeyword $visuNo $private($visuNo,configName) OBJECT"
   } else {
      checkbutton $w -highlightthickness 0 -takefocus 0 -variable ::keyword::private($visuNo,check,$motclef)
   }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $w
}

#------------------------------------------------------------------------------
#  brief crée une entry dans la table
#  param textvariable : nom de la variable contenant la valeur affichée
#  param state        : état de l'entry (normal ou readonly)
#  param tbl          : nom Tk de la table
#  param row          : numéro de ligne
#  param col          : numéro de colonne
#  param w            : nom Tk de l'entry
#
proc ::keyword::createEntry { textvariable state tbl row col w } {
   entry $w -textvariable $textvariable -takefocus 0 -width 35 -state $state

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $w
}

#------------------------------------------------------------------------------
#  brief crée un bouton dans la table
#  param caption : étiquette du bouton
#  param command : fonction appellée quand on clique sur le bouton
#  param tbl     : nom Tk de la table
#  param row     : numéro de ligne
#  param col     : numéro de colonne
#  param w       : nom Tk du bouton
#
proc ::keyword::createButton { caption command tbl row col w } {
   button $w -text $caption -highlightthickness 0 -takefocus 0 -command $command

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $w
}

#------------------------------------------------------------------------------
#  brief crée une combobox dans la table
#  param visuNo           : numéro de la visu
#  param listCombobox     : liste des valeurs de la combobox
#  param textvarComboBox  : nom de la variable contenant la valeur affichée
#  param editable         : combobox éditable (1) ou non (0)
#  param cmdComboBox      : fonction appellée quand on change la valeur
#  param tbl              : nom Tk de la table
#  param row              : numéro de ligne
#  param col              : numéro de colonne
#  param w                : nom Tk de la combobox
#
proc ::keyword::createComboBox { visuNo listCombobox textvarComboBox editable cmdComboBox tbl row col w } {
   ComboBox $w \
      -width [ ::tkutil::lgEntryComboBox $listCombobox ] \
      -height 6 \
      -relief sunken      \
      -borderwidth 1      \
      -textvariable $textvarComboBox \
      -editable $editable \
      -modifycmd "::keyword::onChangeValueComboBox $visuNo" \
      -values $listCombobox

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $w
}

#------------------------------------------------------------------------------
#  brief commande associée au bouton "OK"
#  param visuNo numéro de la visu
#
proc ::keyword::cmdOk { visuNo } {
   ::keyword::cmdApply $visuNo
   ::keyword::cmdClose $visuNo
}

#------------------------------------------------------------------------------
## @brief commande associée au bouton "Appliquer"
#  @param visuNo numéro de la visu
#
proc ::keyword::cmdApply { visuNo} {
   variable private

   #--- je mets en forme le mot cle COMMENT
   set private(commentaire) [ ::keyword::headerFitsCompliant $::keyword::private(commentaire) ]

   #--- je recupere le nom de la configuration (attention il faut 2 $ !!!)
   set $private($visuNo,configNameVariable) $private($visuNo,configName)

   #--- je memorise la configuration dans le tableau conf(...)
   set ::conf(keyword,geometry) $private($visuNo,geometry)

   #--- je definis le nom de la configuration des mots cles FITS de l'outil
   #--- uniquement pour les outils qui configurent les mots cles selon des
   #--- exigences propres a eux
   set catchError [ catch {
      ::[ ::confVisu::getTool $visuNo ]::getNameKeywords $visuNo $private($visuNo,configName)
   } m ]
   if { $catchError == "1" } {
      #--- S'il n'y a pas d'exigences, on passe...
   }

   #--- je sauvegarde la liste des mots cles coches
   set private($private($visuNo,configName),check) ""
   foreach name [array names private $visuNo,check,*] {
      if { $private($name) == 1 } {
         lappend private($private($visuNo,configName),check) [list $name]
      }
   }

   #--- je sauvegarde la configuration et mets en forme les variables conf
   set ::conf(keyword,$private($visuNo,configName),check)             [ string trimleft $private($private($visuNo,configName),check) "{} " ]
   set ::conf(keyword,$private($visuNo,configName),setMeteoData)      $private(setMeteoData)
   set ::conf(keyword,$private($visuNo,configName),GotoManuelAuto)    $private(GotoManuelAuto)
   set ::conf(keyword,$private($visuNo,configName),GotoManuelAutoBis) $private(GotoManuelAutoBis)
   set ::conf(keyword,$private($visuNo,configName),GotoManuelAutoTer) $private(GotoManuelAutoTer)
}

#------------------------------------------------------------------------------
#  brief commande associée au bouton "Aide"
#
proc ::keyword::afficheAide { } {
   ::audace::showHelpItem "$::help(dir,camera)" "1030keyword.htm"
}

#------------------------------------------------------------------------------
## @brief commande associée au bouton "Fermer"
#  @param visuNo numéro de la visu
#
proc ::keyword::cmdClose { visuNo } {
   variable private

   #--- je supprime des listeners sur la camera et l'AlAudine
   ::confVisu::removeCameraListener $visuNo [list ::keyword::onChangeTemperature $visuNo]
   ::confVisu::removeCameraListener $visuNo [list ::keyword::onChangeCRPIXCRVAL $visuNo]
   ::confVisu::removeCameraListener $visuNo [list ::keyword::onChangeCellDim $visuNo]
   ::confVisu::removeCameraListener $visuNo [list ::keyword::onChangeConfOptic $visuNo]

   #--- je supprime un listener sur la configuration optique
   ::confOptic::removeOpticListener [list ::keyword::onChangeConfOptic $visuNo]

   #--- je supprime un listener sur la configuration de l'observatoire
   ::confPosObs::removePosObsListener [list ::keyword::onChangeConfPosObs $visuNo]

   #--- je recupere la geometrie de la fenetre
   ::keyword::recupPosDim $visuNo

   #--- je ferme la fenetre
   destroy $private($visuNo,frm)
}

#------------------------------------------------------------------------------
#  brief récupère et sauvegarde les dimensions et la position de la fenêtre
#  param visuNo numéro de la visu
#
proc ::keyword::recupPosDim { visuNo } {
   variable private

   set private($visuNo,geometry) [ wm geometry $private($visuNo,frm) ]
   set ::conf(keyword,geometry) $private($visuNo,geometry)
}

#------------------------------------------------------------------------------
#  brief récupère la valeur d'un mot clé lorsque la fenêtre des mots clés est ouverte
#  param visuNo           : numéro de la visu
#  param configName       : nom de la configuration
#  param valueKeywordName : nom du mot clé dont la valeur est à lire
#
proc ::keyword::getValueOneKeyword { visuNo configName valueKeywordName } {
   variable private

   #--- Si la fenetre est fermee, je sors par anticipation
   if { ! [ winfo exists $private($visuNo,frm) ] } {
      return
   }

   #--- je cherche le nomTK de l'entry a lire
   for {set i 0 } { $i < [$private($visuNo,table) size] } { incr i } {
      set keywordName [ $private($visuNo,table) rowcget $i -name ]
      #--- je recupere le nomTK de l'entry
      set w [ $::keyword::private($visuNo,table) windowpath $i,valeur ]
      #--- je m'arrete lorsque j'ai trouve le mot cle
      if { $keywordName == $valueKeywordName } {
         break
      }
   }

   #--- je recupere la variable de l'entry
   set variableNomTK [ $w cget -textvariable ]
   #--- je lis le contenu de la variable de l'entry
   set value [ expr $$variableNomTK ]
}

#------------------------------------------------------------------------------
## @brief retourne le type courant de l'image
#
proc ::keyword::getTypeImage { } {
   return $::keyword::private(typeImage)
}

#------------------------------------------------------------
## @brief retourne la liste des configurations
#
proc ::keyword::getConfigurationList { } {
   #--- Liste des configurations
   set configList [list]
   foreach configPath [array names ::conf keyword,*,configName] {
      set configId [lindex [split $configPath "," ] 1]
      lappend configList $::conf(keyword,$configId,configName)
   }
   #--- je trie par ordre alphabetique (l'option -dictionary est equivalente a nocase)
   return [lsort -dictionary $configList ]
}

#------------------------------------------------------------
#  brief retourne l'identifiant d'une configuration en fonction de son nom
#  param name : nom de la configuration
#  return identifiant de la configuration
#
proc ::keyword::getConfigurationIdentifiant { name } {
   variable private

   #--- je fabrique l'identifiant a partir du nom en remplacant les caracteres interdits pas un "_"
   set configId ""
   for { set i 0 } { $i < [string length $name] } { incr i } {
      set c [string index $name $i]
      if { [string is wordchar $c ] == 0 } {
         #--- je remplace le caractere par underscore, si le caractere n'est pas une lettre, un chiffre ou underscore
         set c "_"
      }
      append configId $c
   }
   return $configId
}

#------------------------------------------------------------------------------
## @brief change la valeur d'un mot clé
#  @param visuNo       numéro de la visu
#  @param configName   nom de la confuguration
#  @param keywordName  nom du mot clé
#  @param keywordValue valeur du mot clé
#
proc ::keyword::setKeywordValue { visuNo configName keywordName keywordValue} {
   variable private

   #--- j'initialise le nom de la configuration
   set private($visuNo,configName) $configName

   foreach infosMotClef $private(infosMotsClefs) {
      if { [ lindex $infosMotClef 0 ] == $keywordName } {
         set textVariable [lindex $infosMotClef 2]
         set $textVariable $keywordValue
         return
      }
   }
   #--- je retourne un message d'erreur si le mot cle n'a pas ete trouve
   error "keyword $keywordName unknown"
}

#------------------------------------------------------------------------------
## @brief sélectionne les mots clés à mettre dans une image
#  @param visuNo          : numéro de la visu
#  @param configName      : nom de la configuration
#  @param keywordNameList : liste des mots clés
#
proc ::keyword::selectKeywords { visuNo configName keywordNameList } {
   variable private

   #--- je verifie que la variable existe
   ::keyword::initConfConfigName $configName

   #--- Creation des variables de la boite de configuration de l'en-tete FITS si elles n'existent pas
   if { ! [ info exists private($visuNo,disabled) ] } { set private($visuNo,disabled) "" }

   foreach keywordName $keywordNameList {
      if { [ lsearch $::conf(keyword,$configName,check) "1,check,$keywordName" ] == -1 } {
         lappend ::conf(keyword,$configName,check) "1,check,$keywordName"
      }
   }
}

#------------------------------------------------------------
## @brief initialise les paramètres de chaque configuration spécifiée par son nom
#  @param configName nom de la configuration
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - conf(keyword,$configName,check)             définit les mots clés sélectionnés de la configuration "configName"
#  - conf(keyword,$configName,setMeteoData)      définit si la mise à jour des mots clés TEMP, PRESSURE et/ou HUMIDITY est manuelle ou automatique à partir des stations météo
#  - conf(keyword,$configName,GotoManuelAuto)    définit si la mise à jour des mots clés OBJECT et/ou OBJNAME est manuelle ou automatique
#  - conf(keyword,$configName,GotoManuelAutoBis) définit si la mise à jour des mots clés RA et/ou DEC est manuelle ou automatique
#  - conf(keyword,$configName,GotoManuelAutoTer) définit si la mise à jour du mot clé EQUINOX est manuelle ou automatique
#
proc ::keyword::initConfConfigName { configName } {
   if { ! [ info exists ::conf(keyword,$configName,check) ] }             { set ::conf(keyword,$configName,check)             "default" }
   if { ! [ info exists ::conf(keyword,$configName,setMeteoData) ] }      { set ::conf(keyword,$configName,setMeteoData)      $::conf(keyword,default,setMeteoData) }
   if { ! [ info exists ::conf(keyword,$configName,GotoManuelAuto) ] }    { set ::conf(keyword,$configName,GotoManuelAuto)    $::conf(keyword,default,GotoManuelAuto) }
   if { ! [ info exists ::conf(keyword,$configName,GotoManuelAutoBis) ] } { set ::conf(keyword,$configName,GotoManuelAutoBis) $::conf(keyword,default,GotoManuelAutoBis) }
   if { ! [ info exists ::conf(keyword,$configName,GotoManuelAutoTer) ] } { set ::conf(keyword,$configName,GotoManuelAutoTer) $::conf(keyword,default,GotoManuelAutoTer) }
}

#------------------------------------------------------------------------------
#  brief désélectionne les mots clés contenus dans "keywordNameList"
#  param visuNo          : numéro de la visu
#  param configName      : nom de la configuration
#  param keywordNameList : liste des mots cles
#
proc ::keyword::deselectKeywords { visuNo configName keywordNameList } {
   variable private

   #--- je verifie que la variable existe
   if { ! [ info exists ::conf(keyword,$configName,check) ] } { set ::conf(keyword,$configName,check) "default" }

   foreach keywordName $keywordNameList {
      set var "1,check,$keywordName"
      set idx [ lsearch -exact $::conf(keyword,$configName,check) $var ]
      set ::conf(keyword,$configName,check) [ lreplace $::conf(keyword,$configName,check) $idx $idx "" ]
      #--- je mets en forme la variable conf
      set ::conf(keyword,$configName,check) [ string trimleft $::conf(keyword,$configName,check) "{} " ]
   }
}

#------------------------------------------------------------------------------
#  brief désélectionne un mot clé
#  param visuNo              : numéro de la visu
#  param configName          : nom de la configuration
#  param keywordNameDeselect : mot clé à désélectionner
#
proc ::keyword::deselectOneKeyword { visuNo configName keywordNameDeselect } {
   variable private

   #--- je cherche le nomTK du checkbutton a deselectionner
   for {set i 0 } { $i < [$private($visuNo,table) size] } { incr i } {
      set keywordName [ $private($visuNo,table) rowcget $i -name ]
      #--- je recupere le nomTK du checkbutton
      set w [ $::keyword::private($visuNo,table) windowpath $i,available ]
      #--- je m'arrete lorsque j'ai trouve le mot cle
      if { $keywordName == $keywordNameDeselect } {
         break
      }
   }

   #--- je recupere la variable du checkbutton a deselectionner
   set variableNomTK [ $w cget -variable ]

   #--- je consulte la valeur de la variable
   if { [ set $variableNomTK ] == "1" } {
      set variable "0"
      #--- j'affecte la bonne valeur a la variable si necessaire
      set $variableNomTK $variable
   }
}

#------------------------------------------------------------------------------
#  brief désélectionne tous les mots clés
#  param visuNo  numéro de la visu
#  param configName          : nom de la configuration
#
proc ::keyword::selectDeselectAllKeywords { visuNo configName } {
   variable private

   #--- je recupere le nomTK du premier checkbutton (indice 0)
   set w0 [ $private($visuNo,table) windowpath 0,available ]
   #--- je recupere la variable du premier checkbutton (indice 0)
   set variableNomTK [ $w0 cget -variable ]
   #--- j'affecte la bonne valeur a la variable
   if { [ set $variableNomTK ] == "0" } {
      set variable "1"
   } else {
      set variable "0"
   }
   #--- je selectionne ou deselectionne tous les mots cles
   for {set i 0 } { $i < [ $private($visuNo,table) size ] } { incr i } {
      #--- je recupere le nomTK du checkbutton d'indice i
      set w [ $private($visuNo,table) windowpath $i,available ]
      #--- je recupere l'etat du checkbutton d'indice i
      set state [ $w cget -state ]
      #--- je ne modifie que ceux qui sont a l'etat normal
      if { $state == "normal" } {
         #--- je recupere la variable du checkbutton d'indice i
         set variableNomTK [ $w cget -variable ]
         #--- j'affecte la bonne valeur a la variable du checkbutton d'indice i
         set $variableNomTK $variable
      }
   }
}

#------------------------------------------------------------------------------
#  brief définit les mots clés qui ne peuvent pas être supprimés par l'utilisateur
#  param visuNo          : numéro de la visu
#  param keywordNameList : liste des mots clés
#
proc ::keyword::setKeywordState { visuNo configName keywordNameList } {
   variable private

   #--- j'initialise le nom de la configuration
   set private($visuNo,configName) $configName

   set private($visuNo,disabled) ""
   foreach keywordName $keywordNameList {
      lappend private($visuNo,disabled) "$keywordName"
   }

   if { [info exists private($visuNo,frm)] == 1 } {
      if { [winfo exists $private($visuNo,frm)] == 1 } {
         ::keyword::setCheckButtonState $visuNo
      }
   }
}

#------------------------------------------------------------------------------
#  brief met les checkbuttons à l'état disabled si leur nom est dans la variable
#  private($visuNo,disabled) sinon met les checkbuttons à l'etat normal
#  param visuNo numéro de la visu
#
proc ::keyword::setCheckButtonState { visuNo } {
   variable private

   for {set i 0 } { $i < [$private($visuNo,table) size] } { incr i } {
      set keywordName [$private($visuNo,table) rowcget $i -name ]
      #--- je recupere le nomTK du checkbutton
      set w [$::keyword::private($visuNo,table) windowpath $i,available ]
      #--- je recupere la valeur
      if { [ lsearch $private($visuNo,disabled) $keywordName ] == -1 } {
         $w configure -state normal
      } else {
         $w configure -state disabled
      }
   }
}

#------------------------------------------------------------------------------
#  brief met les widgets de la colonne modification à l'état disabled si leur nom est
#  dans la variable private($visuNo,disabled)
#  sinon met les widgets de la colonne modification à l'état normal
#  param visuNo numéro de la visu
#
proc ::keyword::setWidgetColumnModificationState { visuNo } {
   variable private

   for {set i 0 } { $i < [$private($visuNo,table) size] } { incr i } {
      set keywordName [$private($visuNo,table) rowcget $i -name ]
      #--- je recupere le nomTK de la combobox
      set w [$::keyword::private($visuNo,table) windowpath $i,modification ]
      #--- je recupere la valeur
      if { $w != "" } {
         if { [ lsearch $private($visuNo,disabled) $keywordName ] == -1 } {
            $w configure -state normal
        } else {
            $w configure -state disabled
         }
      }
   }
}

#------------------------------------------------------------------------------
#  brief ajoute une nouvelle configuration dans la liste
#  param visuNo numéro de la visu
#
proc ::keyword::addConfig { visuNo } {
   variable private

   ::keyword::config::run $visuNo "add" $private($visuNo,configName)
}

#------------------------------------------------------------------------------
#  brief supprime une configuration dans la liste
#  param visuNo numéro de la visu
#
proc ::keyword::delConfig { visuNo } {
   variable private

   set ::keyword::config::private(action) "del"
   ::keyword::config::cmdApply $visuNo
}

#------------------------------------------------------------------------------
#  brief copie une configuration de la liste
#  param visuNo numéro de la visu
#
proc ::keyword::copyConfig { visuNo } {
   variable private

   ::keyword::config::run $visuNo "copy" $private($visuNo,configName)
}

#------------------------------------------------------------------------------
#  brief affiche les valeurs dans les widgets pour la configuration choisie
#  (appelée par la combobox à chaque changement de sélection)
#  param visuNo numéro de la visu
#
proc ::keyword::cbCommand { visuNo } {
   variable private

   #--- je recupere l'identifiant de la configuration correspondant a la ligne selectionnee dans la combobox
   set tkCombo $private($visuNo,frm).config.choix.configHeader
   set configId [ ::keyword::getConfigurationIdentifiant [ $tkCombo get ] ]
   set private($visuNo,configName) $configId

   #--- je decoche toutes les lignes
   foreach check [ array names ::keyword::private $visuNo,check,* ] {
      #--- on considere que la configuration des mots cles est la meme pour un nom donne quelque soit visuNo
      set check [ string replace $check 0 0 $visuNo ]
      set private($check) 0
   }

   #--- je configure les mots cles selon les exigences de l'outil
   set catchError [ catch {
      ::[ ::confVisu::getTool $visuNo ]::configToolKeywords $visuNo $private($visuNo,configName)
   } m ]
   if { $catchError == "1" } {
      #--- S'il n'y a pas d'exigences, on passe...
   }

   #--- je mets en forme la variable conf
   set ::conf(keyword,$configId,check) [ string trimleft $::conf(keyword,$configId,check) "{} " ]
   set private($configId,check)        $::conf(keyword,$configId,check)

   #--- je coche les lignes en conformite avec la configuration choisie
   foreach check $private($configId,check) {
      #--- on considere que la configuration des mots cles est la meme pour un nom donne quelque soit visuNo
      set check [ string replace $check 0 0 $visuNo ]
      set private($check) 1
   }
}

## namespace keyword::config
#  @brief Namespace pour la fenêtre de gestion des noms de configuration

namespace eval ::keyword::config {
}

#------------------------------------------------------------------------------
#  brief crée la fenêtre de gestion des noms de configuration
#  param visuNo   : numéro de la visu
#  param action   : add ou copy
#  param configId : identifiant de la configuration
#
proc ::keyword::config::run { visuNo action configId } {
   variable private

   set private(action)   $action
   set private(configId) $configId
   ::confGenerique::run "1" "$::audace(base).manageHeader" "::keyword::config" -modal 0
   set posx_config [ lindex [ split [ wm geometry $::keyword::private($visuNo,frm) ] "+" ] 1 ]
   set posy_config [ lindex [ split [ wm geometry $::keyword::private($visuNo,frm) ] "+" ] 2 ]
   wm geometry $::audace(base).manageHeader +[ expr $posx_config + 0 ]+[ expr $posy_config + 90 ]
   wm transient $::audace(base).manageHeader $::keyword::private($visuNo,frm)
}

#------------------------------------------------------------------------------
## @brief retourne le titre de la fenêtre de gestion des noms de configuration
#
proc ::keyword::config::getLabel { } {
   variable private

   if { $private(action) == "add" } {
      return "$::caption(keyword,ajouter_config)"
   } elseif { $private(action) == "del" } {
      return "$::caption(keyword,supprimer_config)"
   } elseif { $private(action) == "copy" } {
      return "$::caption(keyword,copier_config)"
   }
}

#------------------------------------------------------------------------------
#  brief crée l'interface graphique de la fenêtre de gestion des noms de configuration
#  param frm    chemin Tk
#  param visuNo numéro de la visu
#
proc ::keyword::config::fillConfigPage { frm visuNo } {
   variable private

   #--- Initialisation de variables
   set private(frame)              $frm
   set private(newNameConfig)      ""
   set private(nameConfigCopied)   ""
   set private($visuNo,applyError) "0"

   #--- Frame de la gestion des noms de configuration
   frame $frm.setup -borderwidth 0 -relief raised

      if { $private(action) == "add" } {

         label $frm.setup.addConfig -text $::caption(keyword,config_a_ajouter)
         pack $frm.setup.addConfig -anchor nw -side left -padx 10 -pady 10

         entry $frm.setup.nameAddConfig -textvariable ::keyword::config::private(newNameConfig) \
            -width 42
         pack $frm.setup.nameAddConfig  -anchor w -side left -padx 10 -pady 5

         focus $frm.setup.nameAddConfig

      } elseif { $private(action) == "copy" } {

         label $frm.setup.nameConfig -text $::caption(keyword,nom_nouvelle_config)
         pack $frm.setup.nameConfig -anchor nw -side left -padx 10 -pady 10

         entry $frm.setup.nameConfigCopied -textvariable ::keyword::config::private(nameConfigCopied) \
            -width 42
         pack $frm.setup.nameConfigCopied -anchor w -side left -padx 10 -pady 5

         focus $frm.setup.nameConfigCopied

      }

   pack $frm.setup -side top -fill both -expand 1
}

#------------------------------------------------------------------------------
## @brief commande associée au bouton "Appliquer" de la fenêtre de gestion des
#  noms de configuration pour mémoriser et appliquer la configuration
#  @param visuNo numéro de la visu
#
proc ::keyword::config::cmdApply { visuNo } {
   variable private

   if { $private(action) == "add" } {

      #--- je verifie que le nom n'est pas vide
      if { $private(newNameConfig) == "" } {
         tk_messageBox -message $::caption(keyword,errorEmptyName) \
            -icon error -title $::caption(keyword,header_title)
         set private($visuNo,applyError) "1"
         return
      }

      #--- je fabrique l'identifiant a partir du nom en remplacant les caracteres interdits pas un "_"
      set configId [ ::keyword::getConfigurationIdentifiant $private(newNameConfig) ]

      #--- je verifie que l'identifiant n'est pas deja attribue a une autre configuration
      if { [info exists ::conf(keyword,$configId,configName)] == 1 } {
         tk_messageBox -message $::caption(keyword,errorExistingName) \
            -icon error -title $::caption(keyword,header_title)
         set private($visuNo,applyError) "1"
         return
      }

      set ::conf(keyword,$configId,configName) $private(newNameConfig)
      set ::conf(keyword,$configId,check) ""

      #--- je configure les mots cles selon les exigences de l'outil
      set catchError [ catch {
         ::[ ::confVisu::getTool $visuNo ]::configToolKeywords $visuNo $private(newNameConfig)
      } m ]
      if { $catchError == "1" } {
         #--- S'il n'y a pas d'exigences, on passe...
      }

      #--- j'ajoute le nom de la configuration
      set ::keyword::private($visuNo,configName) $configId

      #--- j'ajoute la nouvelle configuration dans la combobox
      set tkCombo $::keyword::private($visuNo,frm).config.choix.configHeader
      set configList [$tkCombo cget -values]
      lappend configList $private(newNameConfig)
      set configList [lsort $configList]
      $tkCombo configure -values $configList -height [ llength $configList ]

      #--- je selectionne la nouvelle liste dans la combobox
      set index [ lsearch $configList $private(newNameConfig) ]
      $tkCombo setvalue "@$index"
      ::keyword::cbCommand $visuNo

   } elseif { $private(action) == "del" } {

      #--- je recupere l'identifiant de la configuration correspondant a la ligne selectionnee dans la combobox
      set tkCombo $::keyword::private($visuNo,frm).config.choix.configHeader
      set configId [ ::keyword::getConfigurationIdentifiant [ $tkCombo get ] ]
      set private(configId) $configId

      #--- je verifie que ce n'est pas la configuration par defaut
      if { $private(configId) == "default" } {
         #--- j'abandonne la suppression s'il s'agit de la configuration par defaut
         tk_messageBox -message $::caption(keyword,errorDefaultName) \
            -icon error -title $::caption(keyword,header_title)
         return
      }

      #--- je demande la confirmation de la suppression
      set result [ tk_messageBox -message "$::caption(keyword,confirmDeleteConfig) $::conf(keyword,$private(configId),configName)" \
          -type okcancel -icon question -title $::caption(keyword,supprimer_config)]

      if { $result == "ok" } {
         #--- je supprime le nom de la configuration dans la combobox
         set tkCombo $::keyword::private($visuNo,frm).config.choix.configHeader
         set configList [$tkCombo cget -values]
         set index [ lsearch $configList $::conf(keyword,$private(configId),configName) ]
         set configList [lreplace $configList $index $index]
         $tkCombo configure -values $configList -height [ llength $configList ]

         #--- je supprime les parametres de la configuration
         unset ::conf(keyword,$private(configId),configName)
         unset ::conf(keyword,$private(configId),check)

         #--- je selectionne l'item suivant a la place de celui qui vient d'etre supprime
         if { $index == [llength $configList] } {
            #--- je decremente l'index si l'element supprime etait le dernier de la liste
            incr index -1
         }
         $tkCombo setvalue "@$index"
         ::keyword::cbCommand $visuNo

         #--- je recupere le nom de la nouvelle configuration (attention il faut 2 $ !!!)
         #--- pour eviter un bug, si je quitte Aud'ACE sans appuyer sur le bouton OK ou
         #--- Appliquer de la fenetre de configuration des mots cles
         set $::keyword::private($visuNo,configNameVariable) $::keyword::private($visuNo,configName)

      }

   } elseif { $private(action) == "copy" } {

      #--- je verifie que le nom n'est pas vide
      if { $private(nameConfigCopied) == "" } {
         tk_messageBox -message $::caption(keyword,errorEmptyName) \
            -icon error -title $::caption(keyword,header_title)
         set private($visuNo,applyError) "1"
         return
      }

      #--- je fabrique l'identifiant a partir du nom en remplacant les caracteres interdits pas un "_"
      set configId [ ::keyword::getConfigurationIdentifiant $private(nameConfigCopied) ]

      #--- je verifie que l'identifiant n'est pas deja attribue a une autre configuration
      if { [info exists ::conf(keyword,$configId,configName)] == 1 } {
         tk_messageBox -message $::caption(keyword,errorExistingName) \
            -icon error -title $::caption(keyword,header_title)
         set private($visuNo,applyError) "1"
         return
      }

      #--- je recopie la variable
      set ::conf(keyword,$configId,configName) $private(nameConfigCopied)
      set ::conf(keyword,$configId,check) $::conf(keyword,$private(configId),check)

      #--- je mets en forme la variable conf
      set ::conf(keyword,$configId,check) [ string trimleft $::conf(keyword,$configId,check) "{} " ]

      #--- j'ajoute le nom de la configuration
      set ::keyword::private($visuNo,configName) $configId

      #--- j'ajoute la nouvelle configuration dans la combobox
      set tkCombo $::keyword::private($visuNo,frm).config.choix.configHeader
      set configList [$tkCombo cget -values]
      lappend configList $private(nameConfigCopied)
      set configList [lsort $configList]
      $tkCombo configure -values $configList -height [ llength $configList ]

      #--- je selectionne la nouvelle liste dans la combobox
      set index [ lsearch $configList $private(nameConfigCopied) ]
      $tkCombo setvalue "@$index"
      ::keyword::cbCommand $visuNo

   }
}

#------------------------------------------------------------------------------
## @brief commande associée au bouton "Fermer" de la fenêtre de gestion
#  des noms de configuration
#  @param visuNo numéro de la visu
#
proc ::keyword::config::cmdClose { visuNo } {
   variable private

   #--- Retourne 0 pour empecher de fermer la fenetre
   if { $private($visuNo,applyError) == "1" } {
      set private($visuNo,applyError) 0
      return 0
   }
}

#--- Initialisation
::keyword::init

