#
## @file  collector_init.tcl
#  @brief Scripts d'initalisation des variables
#  @author Raymond Zachantke
#  $Id: collector_init.tcl 12863 2016-01-24 13:12:20Z rzachantke $
#

   #--   Liste des proc                utilisee par
   # ::collector::onChangeImage        ::confVisu::addFileNameListener
   # ::collector::initLocal            onChangeImage
   # ::collector::initAtm              onChangeImage
   # ::collector::initTarget           onChangeImage
   # ::collector::initPose             onChangeImage
   # ::collector::onChangeOptic        ::confOptic::addOpticListener
   # ::collector::onChangeMount        ::confTel::addMountListener
   # ::collector::onChangeSuivi        trace add variable "::audace(telescope,controle) et onChangeMount
   # ::collector::onChangeCam          configAddRemoveListener
   # ::collector::onChangeObserver     ::confPosObs::addPosObsListener et conf(posobs,observateur,gps)
   # ::collector::onChangeObjName      onChangeMount

   #------------------------------------------------------------
   #  brief pilote l'initialisation lors du lancement et du chargement d'une image
   #  param visuNo numéro de la visu
   #  param args  arguments du listener
   #
   proc ::collector::onChangeImage { visuNo args } {
      variable This
      variable private
      global audace conf

      #--   inactive le bouton d'ecriture des mots cles
      $This.n.kwds.writeKwds state disabled

      set new_image [::confVisu::getFileName $visuNo]

      if {[info exists private(precedent)] && $new_image eq "$private(precedent)"} {return}

      set private(crota2) 0.
      set ext [file extension $new_image]
      set bufNo [visu$visuNo buf]

      #--   noms d'images a exclure
      set image [file join $audace(rep_images) dss$ext]
      if {$new_image eq "$image"} {
         #--   detection des images DSS
         ::collector::configCmd
         return
      }

      set listCam [list "GenikaAstro" "GENICAP-RECORD" "LUCAM-RECORDER" "PlxCapture"]
      if {[regexp {(Canon).+} [lindex [buf$bufNo getkwd CAMERA] 1]] == 1} {
         #--   detection des image issues de Canon
         set private(image) "type1"
      } elseif {[lindex [buf$bufNo getkwd SWCREATE] 1] in $listCam} {
         #--   detection des image SER
         set private(image) "type2"
      } else {
         #--   memorise le nom
         set private(image) $new_image
      }

      #--   active le bouton d'ecriture des mots cles
      if {$private(image) ni [list "$image" ""]} {
         $This.n.kwds.writeKwds state !disabled
      }

      ::collector::initLocal $bufNo
      ::collector::initAtm $bufNo
      ::collector::onChangeOptic $bufNo
      ::collector::onChangeMount $visuNo
      ::collector::onChangeCam $bufNo
      ::collector::initTarget $bufNo
      ::collector::initPose $bufNo
      ::collector::computeTelCoord
      ::collector::updateInfo naxis1
     ::collector::onChangeObserver $bufNo
      ::collector::onChangeObjName $bufNo
   }

   #------------------------------------------------------------
   #  brief met à jour l'onglet Local
   #  param bufNo numéro du buffer contenant l'image
   #
   proc ::collector::initLocal { bufNo } {
      variable private
      global audace

      switch -exact $private(image) {
         type1    {  set private(gps) $audace(posobs,observateur,gps)
                     lassign [getDateExposure $bufNo] private(t) private(tu) private(jd)
                  }
         type2    {  set private(gps) $audace(posobs,observateur,gps)
                     lassign [getDateExposure $bufNo] private(t) private(tu) private(jd)
                  }
         ""       {  set private(gps) $audace(posobs,observateur,gps)
                     set private(t) $audace(etc,input,ccd,t)
                     set date [::audace::date_sys2ut now]
                     lassign [getDateTUJD $date] private(tu) private(jd)
                  }
         default  {  set private(gps) [getTelPosition $bufNo]
                     lassign [getDateExposure $bufNo] private(t) private(tu) private(jd)
                  }
      }

      computeTslMoon

      set private(seeing) $audace(etc,param,local,seeing)
   }

   #------------------------------------------------------------
   #  brief met à jour l'onglet Météo
   #  param bufNo numéro du buffer contenant l'image
   #
   proc ::collector::initAtm { bufNo } {
      variable private

      if {[buf$bufNo imageready]} {
         lassign [getTPW $bufNo] private(temperature) private(temprose) private(humidity) \
            private(winddir) private(windsp) private(pressure)
      } else {
         ::collector::refreshMeteo
      }
   }

   #------------------------------------------------------------
   #  brief met à jour l'onglet Cible
   #  param bufNo numéro du buffer contenant l'image
   #
   proc ::collector::initTarget { bufNo } {
      variable private
      global audace

      set private(equinox) "J2000.0"
      set private(true) "J2000.0"

      switch -exact $private(image) {
         type1    {  if {$audace(telNo) != 0} {
                        #--   coordonnees rafraichies par le telescope
                     }
                  }
         type2    {  if {$audace(telNo) != 0} {
                        #--   coordonnees rafraichies par le telescope
                     }
                  }
         ""       {  if {$audace(telNo) == 0} {

                        #--   coordonnees azimutales du zenith
                        set az 0.0 ; set elev 90

                        #--   met a jour les coordonnees
                        refreshCoordsJ2000 $az $elev ALTAZ
                     }
                  }
         default  {  if {$audace(telNo) == 0} {
                        #--   collecte et assigne les donnees dans l'image
                        lassign [::collector::getImgData $bufNo] private(ra) private(dec) private(equinox) \
                           private(naxis1) private(naxis2) private(bin1) private(bin2) -> -> \
                           private(crota2) private(crval1) private(crval2) \
                           private(crpix1) private(crpix2) private(pixsize1) private(pixsize2)
                     }
                  }
      }
   }

   #------------------------------------------------------------
   #  brief met à jour l'onglet Vue
   #  param bufNo numéro du buffer contenant l'image
   #
   proc ::collector::initPose { bufNo } {
      variable private

      #--   raccourcis
      foreach v [list naxis1 naxis2 photocell1 photocell2] {
         set $v $private($v)
      }

      if {$private(image) eq ""} {

         set data [list $naxis1 $naxis2 $private(photocell1) $private(photocell2)]

         if {"-" ni $data} {
            #--   bin == 1; dim =naxis ; pixsize = photocell
            set result [linsert $data 0 1 1]
        } else {
            #--   configuration par defaut
            set result [list 1 1 - - - -]
         }

         lassign $result private(bin1) private(bin2) private(naxis1) private(naxis2) private(pixsize1) private(pixsize2)

         if {![string is double -strict $private(crota2)]} {
            set private(crota2) "0."
         }

         set t $::audace(etc,input,ccd,t)
         set audace(etc,param,ccd,bin1) 1
         set audace(etc,param,ccd,bin2) 1

      } elseif {$private(image) in [list type1 type2 ""]} {

         lassign [::collector::getImgData $bufNo] -> -> -> private(naxis1) private(naxis2) \
            private(bin1) private(bin2) photocell1 photocell2

         #--   ne change les valeurs que si elles sont connues
         foreach v [list photocell1 photocell2] {
            set value [set $v]
           if {$value ne "-"} {
               set private($v) $value
            }
         }
      }

      #computeCdeltFov
      ::collector::computeCenterPixVal

      #--   raccourcis
      foreach v [list ra dec pixsize1 pixsize2 foclen cdelt1 cdelt2 crpix1 crpix2 crval1 crval2] {
         set $v $private($v)
      }

      set private(match_wcs) [::collector::getMatchWCS $ra $dec $pixsize1 $pixsize2 $foclen $cdelt1 $cdelt2 $crpix1 $crpix2 $crval1 $crval2]

      set private(m) $::audace(etc,input,object,m)
      set private(snr) 3
      set private(error) [format %0.3f [expr { 1.09 / $private(snr) }]]
    }

   #------------------------------------------------------------
   #  brief met à jour l'onglet Optique
   #
   #  à partir des mots clés de l'image ou de la configuration de l'optique du télescope
   #  param bufNo numéro du buffer contenant l'image
   #  param args  arguments du listener
   #
   proc ::collector::onChangeOptic { bufNo args } {
      variable private
      global audace

      if {$private(image) ni [list type1 ""]} {

         lassign [::collector::getKwdOptic $bufNo] private(telescop) private(aptdia) private(foclen) private(filter)

      }  else {

         if {![info exists private(camItem)]} {
            set private(camItem) A
         }
         lassign [::confOptic::getConfOptic $private(camItem)] private(telescop) aptdia foclen
         set private(aptdia) [format %0.3f $aptdia]
         set private(foclen) [format %0.3f $foclen]
         set private(filter) C

      }

      #--   dans les deux cas, calcule et met a jour le ratio F/D et le pouvoir separateur
      ::collector::computeOptic

      set private(focus_pos) $::audace(focus,currentFocus)

      set private(psf)  [expr {$audace(etc,param,optic,Fwhm_psf_opt)*1e6}]

      #--   met a jour les parametres de etc_tools
      foreach {par val} [list D $private(aptdia) FonD $private(fond)] {
         if {$val ne "-"} {
            set audace(etc,param,optic,$par) $val
          }
      }
   }

   #------------------------------------------------------------
   #  brief met à jour l'onglet Monture
   #  param visuNo numéro de la visu
   #  param args  arguments du listener
   #
   proc ::collector::onChangeMount { visuNo args } {
      variable This
      variable private
      global audace

      set notebook $This.n

      if {![::confTel::isReady]} {
         #--   masque les onglets specifiques du telescope
         #     qui arrete le rafraichissement de la meteo
         ::collector::hideTel $notebook
         return
      }

      set telNo $audace(telNo)
      set bufNo [visu$visuNo buf]

      #--   affiche et selectionne l'onglet 'Telescope'
      $notebook add $notebook.tlscp
      $notebook select $notebook.tlscp

      lassign [::collector::getTelConnexion $telNo] private(product) private(telname) \
         hasCoordinates hasControlSuivi

      #--   active le suivi
      ::collector::configTraceSuivi $hasControlSuivi
      ::collector::onChangeSuivi

      #--   identifie une monture Allemande
      set private(german) [::confTel::getPluginProperty isGermanMount]
      if {$private(german) == 0 && $private(telname) eq "ASCOM (ScopeSim.Telescope)"} {
         set private(german) 1
      }

      #--   active les vitesses
      ::collector::configTraceRaDec $hasCoordinates

      #--   si necessaire, affiche l'onglet 'Allemande'
      if {$private(german) == "1"} {
         $notebook add $notebook.german
         #--   modifie la position
         ::collector::refreshMyTel
         #--   demasque le telescope
         ::collector::showTelescope $private(canvas) 1 $private(colTel) $private(colFond)
      }

      #--   met en place la trace du nom de l'objet selectionne dans le panneau telescope
      #     present et trace absente
      set visuNoTel [::confVisu::getToolVisuNo ::tlscp]
      if {$visuNoTel ne "" && $bufNo ne "" && \
         [trace info variable ::tlscp::private($visuNoTel,nomObjet)] eq "" } {
         trace add variable ::tlscp::private($visuNoTel,nomObjet) write "::collector::onChangeObjName $bufNo"
      }
   }

   #------------------------------------------------------------
   #  brief met à jour le témoin du suivi dans l'onglet Télescope
   #
   #  lancé par trace add variable "::audace(telescope,controle)" et onChangeMount
   #  param args  arguments du listener
   #
   proc ::collector::onChangeSuivi { args } {
      variable This
      variable private

      set indicator [regexp {.+(On)} $::audace(telescope,controle)]
      set suivi  $This.n.tlscp.suivi

      if {[winfo exists $suivi] && $indicator == 1} {
         $suivi configure -image $private(greenLed)
      } else {
         $suivi configure -image $private(redLed)
      }
   }

   #------------------------------------------------------------
   #  brief met à jour les spécifications de la caméra
   #
   #  à partir des kwd de l'image et de etc_tools ou de la caméra connectée
   #  param bufNo numéro du buffer contenant l'image
   #  param args  arguments du listener
   #
   proc ::collector::onChangeCam { bufNo args } {
      variable private

      #--   valeurs par defaut
      set camList $private(actualListOfCam)
      set detnam [lindex $camList 0]
      ::collector::modifyCamera

      set params [list photocell1 photocell2 eta noise therm gain ampli]
      set style "TEntry"

      if {$private(image) eq "" || $args ne ""} {

         #--   connexion d'une cam
         set data [::collector::getCamSpec]

         if {[lindex $data 0] ne "-"} {

            #--   cam avec nom + spec --> change le nom
            lassign $data detnam private(camItem) private(naxis1) private(naxis2) \
               private(photocell1) private(photocell2)
            updateEtc naxis1 $private(naxis1)
            updateEtc naxis2 $private(naxis2)
            updateEtc photocell1 $private(photocell1)
            updateEtc photocell2 $private(photocell2)

            set params [list eta noise therm gain ampli]
            set style "default.TEntry"
         }

      } elseif {$private(image) ne "" && $args eq ""} {

         if {$private(image) ni [list type1 type2]} {
            #--   chargement d'une image
            lassign [::collector::getCamName $bufNo] detnam photocell1 photocell2

            #--   ne change les valeurs que si elles sont connues
            foreach v [list photocell1 photocell2] {
               set value [set $v]
               if {$value ne "-"} {
                  set private($v) $value
                  set k [lsearch $params $v]
                  set params [lreplace $params $k $k]
               }
            }
         } else {
            switch -exact $private(image) {
               type1 { set detnam "Canon EOS 60D" }
               type2 { set detnam "BASLER 1300" }
            }
         }
      }

      if {$detnam eq "-"} {
         set detnam "$::caption(collector,newCam)"
      }

      set private(detnam) $detnam

      if {$detnam in $camList} {
         ::collector::modifyCamera
         if {[info exists private(newCam)]} {
            unset private(newCam)
            if {[winfo exists $::audace(base).newCam]} {
               destroy $::audace(base).newCam
            }
         }
      } else {
         ::collector::activeOnglet cam
         set private(newCam) $detnam
         set style "default.TEntry"
      }

      #--   gere la couleur des valeurs des parametres
      ::collector::changeEntryStyle $params $style
   }

   #------------------------------------------------------------
   #  brief met à jour le nom de l'observateur, etc.
   #
   #  lancée aussi par ::confPosObs::addPosObsListener
   #  param bufNo numéro du buffer contenant l'image
   #  param args  arguments du listener
   #
   proc ::collector::onChangeObserver { bufNo args } {
      variable private
      global conf

      #--   pm type1 --> nom Canon
      if {$private(image) ni [list type1 type2 ""]} {

         #--   a partir des mots cles d'une image
         lassign [::collector::getObserv $bufNo] private(observer) private(sitename)
         set private(gps) [getTelPosition $bufNo]

      } else {

        #--   a partir de la configuration d'Aud'ACE
         set private(observer) $conf(posobs,nom_observateur)
         set private(sitename) $conf(posobs,nom_observatoire)
         set private(origin) $conf(posobs,nom_organisation)
         set private(iau_code) $conf(posobs,station_uai)
         set private(gps) $conf(posobs,observateur,gps)
      }
   }

   #------------------------------------------------------------
   #  brief met à jour le type d'image et le nom de l'objet
   #
   #  lancée aussi par trace add variable ::tlscp::private($visuNoTel,nomObjet)
   #  param bufNo numéro du buffer contenant l'image
   #  param args  arguments du listener
   #
   proc ::collector::onChangeObjName { bufNo args } {
      variable private
      global caption

      #--   identifie le N° de la visu comportant le panneau telescope
      set visuNoTel [::confVisu::getToolVisuNo ::tlscp]

      #--   valeurs par defaut
      set result [list [lindex $caption(collector,imagetypes) 3] mySky] ; # valeurs par defaut

      if {[::confTel::isReady] ==1 && $visuNoTel ne ""} {

         #-- Rem : le panneau Telescope doit etre ouvert prealablement dans une visu
         #--   capture le nom de l'objet pointe si le telescope est en marche
         set result [list [lindex $caption(collector,imagetypes) 3] $::tlscp::private($visuNoTel,nomObjet)]

      } elseif {[buf$bufNo imageready] == 1} {

         #-- Cherche dans les mots cles de l'image
         set result1 [getObject $bufNo]
         if {"-" ni "$result1"} {
            set result $result1
         }

      }

      lassign $result private(imagetyp) private(objname)
   }


