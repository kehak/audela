#
## @file collector_gui.tcl
#  @brief Scripts de construction et de gestion de l'interface graphique
#  @author Raymond Zachantke
#  $Id: collector_gui.tcl 13033 2016-02-01 19:10:41Z rzachantke $
#

   #--   Liste des proc de configuration de la fenetre de l'outil
   # nom proc                             utilisee par
   # ::collector::initCollector           createPluginInstance
   # ::collector::createMyNoteBook        initCollector
   # ::collector::configLigne             createMyNoteBook
   # ::collector::configCmd
   # ::collector::configButtons
   # ::collector::confToWidget            initCollector
   # ::collector::configAddRemoveListener initCollector et closeMyNoteBook
   # ::collector::configTraceSuivi        onChangeMount
   # ::collector::configTraceRaDec        onChangeMount
   # ::collector::hideTel                 onChangeMount

   #------------------------------------------------------------
   #  brief   prépare la création de l'interface graphique
   #
   proc ::collector::initCollector { visuNo } {
      variable This
      variable private
      global audace cameras

      #--   precaution
      array unset cameras

      #--   cree les images d'icones
      foreach icon {baguette chaudron greenLed redLed} {
         if {[winfo exists $This.newCam] ==0} {
            ::collector::createIcon $icon
         }
      }

      ::collector::confToWidget

      #--  lance etc_tools
      etc_init

      #--   liste les cameras dans etc_tools
      set private(etcCam) [lsort -dictionary [etc_set_camera]]

      #--   ajoute les cameras utilisateurs
      set l [llength $private(cam)]
      if {$l > 0} {
         for {set i 0} {$i < $l} {incr i} {
            array set cameras [lindex $private(cam) $i]
         }
      }

      set private(actualListOfCam) [lsort -dictionary [array names cameras]]

      #--   liste equivalente a celle de etc_tools : naxis1 naxis2 photocell1 photocell2 C_th G N_ro eta Em
      set private(paramsList) [list naxis1 naxis2 photocell1 photocell2 therm gain noise eta ampli]

      #--   liste les couples de variables 'etc_tools' et 'collector'
      set private(etc_variables) [list {aptdia D} {fond FonD} {foclen Foclen} {filter band} \
         {psf Fwhm_psf_opt} {seeing seeing} {naxis1 naxis1} {naxis2 naxis2} \
         {bin1 bin1} {bin2 bin2} {t t} {m m} {snr snr} \
         {eta eta} {noise N_ro} {therm C_th} {gain G} {ampli Em} \
         {photocell1 photocell1} {photocell2 photocell2}]

      #--   liste les variables exclusivement label (resultat de calculs ou affichage simple)
      #--   non modifiables par l'utilisateur
      set private(labels) [list equinox true raTel decTel azTel elevTel haTel error \
         telescop fov1 fov2 cdelt1 cdelt2 gps jd tsl moonphas moonalt ncfz focus_pos \
         temprose humidity winddir windsp fwhm secz airmass aptdia foclen fond resolution \
         telname connexion suivi vra vdec vxPix vyPix observer sitename origin iau_code catAcc]

      #--   liste les variables 'entry' avec binding, modifiables par l'utilisateur
      set private(entry) [list ra dec bin1 bin2 naxis1 naxis2 crota2 m snr t \
         tu seeing temperature pressure psf photocell1 photocell2 eta gain noise therm ampli isospeed objname]

      #--   liste les variables necessaires pour synthetiser une image
      set private(syn_variables) [list snr m t aptdia foclen fond psf filter \
         bin1 bin2 naxis1 naxis2 photocell1 photocell2 eta gain noise therm ampli]

      #--   liste les variables necessaires pour synthetiser une image, sans image dans la visu
      set private(special_variables) [list ra dec gps t tu jd tsl telescop aptdia foclen fwhm \
         bin1 bin2 naxis1 naxis2 cdelt1 cdelt2 crota2 filter detnam photocell1 photocell2 \
         pixsize1 pixsize2 crval1 crval2 crpix1 crpix2 temperature pressure \
         observer sitename imagetyp objname]

      #--   liste les variables necessaires pour activer le bouton 'image DSS'
      set private(dss_variables) [list crval1 crval2 fov1 fov2 naxis1 naxis2 crota2]

      #--   liste les boutons
      set private(buttonList) [list cmd.syn cmd.special cmd.dss cmd.close cmd.hlp \
         n.local.modifGps n.optic.modifOptic n.optic.modifFocus \
         n.kwds.modifObs n.kwds.editKwds n.kwds.writeKwds \
         n.config.modifRep n.config.dispEtc n.config.simulimage]

      #--  cree la fenetre
      ::collector::createMyNoteBook $visuNo

      #--   initialise les listener permanents
      ::collector::configAddRemoveListener $visuNo add
   }

   #------------------------------------------------------------
   #  brief   créé l'interface graphique
   #
   proc ::collector::createMyNoteBook { visuNo } {
      variable This
      variable private
      global audace caption conf color

      if {[winfo exists $This]} {
         ::collector::cmdClose $visuNo
      }

      toplevel $This -class Toplevel
      wm title $This "$caption(collector,title)"
      wm geometry $This "$private(position)"
      wm resizable $This 0 0
      wm protocol $This WM_DELETE_WINDOW "::collector::cmdClose $visuNo"

      ttk::style configure my.TEntry -foreground $audace(color,entryTextColor)
      ttk::style configure default.TEntry -foreground red

      pack [ttk::notebook $This.n]

      #--   liste des variables de chaque onglet, affichees dans cet ordre
      set targetChildren [list equinox ra dec separator1 true raTel decTel azTel elevTel haTel]
      set dynamicChildren [list m error snr t prior]
      set poseChildren [list bin1 bin2 cdelt1 cdelt2 naxis1 naxis2 fov1 fov2 crota2]
      set localChildren [list gps modifGps tu jd tsl moonphas moonalt]
      set atmChildren [list temperature temprose humidity pressure winddir windsp seeing fwhm secz airmass]
      set opticChildren [list telescop modifOptic aptdia foclen fond resolution ncfz focus_pos modifFocus psf filter]
      set camChildren [list detnam photocell1 photocell2 eta noise therm gain ampli isospeed]
      set tlscpChildren [list telname suivi vra vdec vxPix vyPix]
      set kwdsChildren [list observer modifObs sitename origin iau_code imagetyp objname separator1 editKwds writeKwds]
      set configChildren [list catname catAcc modifRep separator1 dispEtc simulimage]

      #--   construit le notebook dans cet ordre
      foreach topic [list target dynamic pose local atm optic cam tlscp german kwds config] {
         set fr [frame $This.n.$topic]
         #--   ajoute un onglet
         $This.n add $fr -text "$caption(collector,$topic)"
         if {$topic ne "german"} {
            #--   ajoute les lignes dans l'onglet
            set children [set ${topic}Children]
            set len [llength $children]
            for {set k 0} {$k < $len} {incr k} {
               set child [lindex $children $k]
               ::collector::configLigne $topic $child $k
            }
            grid columnconfigure $fr {1} -pad 5 -weight 1
         } else {
            #--   construit l'onglet pour une monture allemande
            ::collector::buildOngletGerman $This.n.german $visuNo
         }
     }

     #--   boutons de commande principaux
     frame $This.cmd

       foreach {but side} [list syn left dss left close right hlp right]  {
            pack [ttk::button $This.cmd.$but -text "$caption(collector,$but)" -width 10] \
               -side $side -padx 10 -pady 5 -ipady 5
       }
       ttk::button $This.cmd.special -image $private(baguette) -width 4 -compound image
         pack $This.cmd.special -after $This.cmd.syn -side left -padx 10 -pady 5 -ipadx 4 -ipady 4

         #-- specialisation des boutons
         $This.cmd.syn configure -command "::collector::cmdApplySynthetiser $visuNo"
         $This.cmd.special configure -command "::collector::cmdApplyMagic $visuNo $This.cmd.special"
         $This.cmd.dss configure -command "::collector::cmdApplyRequestSkyView \"[file join $::audace(rep_images) dss$::conf(extension,defaut)]\" "
         $This.cmd.hlp configure -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::collector::getPluginType ] ] [ ::collector::getPluginDirectory ] collector.htm"
         $This.cmd.close configure -command "::collector::cmdClose $visuNo"

      pack $This.cmd -in $This -side bottom -fill x

      $This.cmd.special state disabled
      $This.cmd.syn state disabled
      $This.cmd.dss state disabled

      #--   initialisation partielle
      lassign [list "" 0] private(suivi) private(german)
      $This.n.tlscp.suivi configure -image $private(redLed) \
         -compound right -textvariable ""
      set private(image) ""

      $This.n.dynamic.prior current 0
      $This.n.kwds.imagetyp current 3
      set private(objname) "mySky"
      set private(telInitialise) 0

      ::collector::onChangeImage $visuNo
      ::collector::modifyRep

      #--- La fenetre est active
      focus $This

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #------------------------------------------------------------
   #  brief   construit une ligne d'un onglet
   #  param topic  nom de longlet
   #  param child  nom de l'enfant
   #  param row    numéro de la ligne (row)
   #  param visuNo numéro de la visu
   #
   proc ::collector::configLigne { topic child row {visuNo 1} } {
      variable This
      variable private
      global audace caption

      set onglet $This.n.$topic
      set w $onglet.$child

      #--   corrige row pour certaines lignes
      if {$child in [list tu aptdia foclen modifFocus sitename]} {incr row -1}

      if {[regexp {(separator).} $child] == 1} {

         grid [ttk::separator $w -orient horizontal] \
           -row $row -column 0 -columnspan 3 -padx 10 -pady 5 -sticky news
         $w state !disabled
         return

      } elseif {$child in [list modifGps modifOptic modifFocus modifObs editKwds writeKwds modifRep dispEtc simulimage]} {

         ttk::button $w -text "$caption(collector,$child)"
         switch -exact $child {
            modifGps   {$w configure -command "::confPosObs::run $audace(base).confPosObs" -width 7 -padding {2 2}
                        grid $w -row 0 -column 2
                       }
            modifOptic {$w configure -command "::confOptic::run $visuNo" -width 7 -padding {2 30}
                        grid $w -row 0 -column 2 -rowspan 3
                       }
            modifFocus {$w configure -command "::collector::callFocuser"
                        grid $w -row $row -column 2
                       }
            modifObs   {$w configure -command "::confPosObs::run $audace(base).confPosObs" -width 7 -padding {2 2}
                        grid $w -row 0 -column 2 -rowspan 5
                       }
            editKwds   {$w configure -command "::collector::createKeywords ; ::collector::editKeywords"
                        grid $w -row $row -column 1
                       }
            writeKwds  {$w configure -command "::collector::setKeywords"
                        grid $w -row $row -column 1
                       }
            modifRep   {$w configure -command "::cwdWindow::run \"$audace(base).cwdWindow\"" -width 7 -padding {2 2}
                        grid $w -row 1 -column 2
                       }
            dispEtc    {$w configure -command "etc_disp"
                        grid $w -row $row -column 1
                       }
            simulimage {$w configure -command "::audace::showHelpItem \"$::audace(rep_doc_html)/french/12tutoriel\" \"1030tutoriel_simulimage1.htm\""
                        grid $w -row $row -column 1
                       }
         }
         grid configure $w -padx 5 -pady 5 -sticky news
         return

      }

      #--   nomme la ligne
      label $onglet.lab_$child -text "$caption(collector,$child)" -justify left
      grid $onglet.lab_$child -row $row -column 0 -sticky w -padx 10 -pady 3

      if {$child in $private(labels)} {

        label $w -textvariable ::collector::private($child)

      } elseif {$child in $private(entry)} {

         set width 7
         if {$child in [list gps tu ]} {
            set width 30
         } elseif {$child in [list ra dec objname]} {
            set width 15
         }

         ttk::entry $w -textvariable ::collector::private($child) \
            -width $width -justify right
         set private(prev,$child) ""

         #--   configure la validation de la saisie
         if {$child ni [list equinox gps ra dec tu objname]} {
            bind $w <Leave> [list ::collector::testNumeric $child] ; # pattern de la variable , variables numeriques (dont etc_tools)
          } else {
            bind $w <Leave> [list ::collector::testPattern $child] ; # pattern de la variable
         }

      } elseif {$child in [list prior filter detnam imagetyp catname]} {

         #--   combobox
         #--   liste et commande du binding
         switch -exact $child {
            prior    {  set values $caption(collector,prior_combo)
                        set cmd "::collector::modifyPriority"
                     }
            filter   {  set values $caption(collector,band)
                        set cmd "::collector::modifyBand"
                     }
            detnam   {  set values [linsert $private(actualListOfCam) end $caption(collector,newCam)]
                        set cmd "::collector::modifyCamera"
                     }
            imagetyp {  set values $caption(collector,imagetypes)
                        set cmd "return"
                     }
            catname  {  set values $caption(collector,catalog)
                        set cmd "::collector::modifyRep"
                     }
         }

         #--   largeur
         set width [::tkutil::lgEntryComboBox $values]
         if {$width < 4} {set width 4}

         ttk::combobox $w -width $width -justify center -values $values \
            -textvariable ::collector::private($child)
         $w state !disabled

         #--   binding
         bind $w <<ComboboxSelected>> [list $cmd]

         #--   positionnement initial
         #if {$child eq "catname"} {
         #   $w set [lindex $values 0]
         #}
      }

      grid $w -row $row -column 1 -sticky e -padx 10

      #--   initialise la variable
      if {![info exists private($child)]} {set private($child) "-"}
      if {$child eq "crota2"} {set private($child) "0."}
   }

   #------------------------------------------------------------
   #  brief   configure chaque bouton {syn|dss|special} en fonction des infos disponibles
   #
   proc ::collector::configCmd { } {
      variable This
      variable private

      foreach but [list dss syn special] {

         #--   empeche une erreur si la fenetre a ete fermee
         if {![winfo exists $This.cmd.$but] ==1} {return}

         set state !disabled
         if {$but ne "syn" || $private(image) ne ""} {
            if {"-" in [::struct::list map $private(${but}_variables) ::collector::getValue]} {
               set state disabled
            }
         } else {
            set state disabled
         }
         $This.cmd.$but state $state
      }
   }

   #------------------------------------------------------------
   #  brief   inhibe/désinhibe tous les boutons
   #  param    state normal ou disabled
   #
   proc ::collector::configButtons { state } {
      variable This
      variable private

      foreach b $private(buttonList) {
         $This.$b state $state
      }
      if {$state eq "!disabled"} {
         ::collector::configCmd
      }
   }

   #------------------------------------------------------------
   #  brief   configure les listener
   #  param   visuNo nuémro de la visu
   #  param   op {add|remove}
   #
   proc ::collector::configAddRemoveListener { visuNo op } {

      set bufNo [visu$visuNo buf]

      #---  trace les changements d'image
      ::confVisu::${op}FileNameListener $visuNo "::collector::onChangeImage $visuNo"
      #---  trace les changements de Cam
      ::confVisu::${op}CameraListener $visuNo "::collector::onChangeCam $bufNo"
      #---  trace les changements de configuration optique
      ::confOptic::${op}OpticListener "::collector::onChangeOptic $bufNo"
      #---  trace les changements de position du focuser
      trace $op variable ::audace(focus,currentFocus) write "::collector::onChangeOptic $bufNo"
      #---  trace la connexion d'un telescope
      ::confTel::${op}MountListener "::collector::onChangeMount $visuNo"
      #---  trace les changements de Observateur et de la position de l'observateur
      ::confPosObs::${op}PosObsListener "::collector::onChangeObserver $bufNo"
      trace $op variable conf(posobs,observateur,gps) write "::collector::onChangeObserver $bufNo"

   }

   #------------------------------------------------------------
   #  brief   configure la trace du contrôle du suivi en cas de connexion/déconnexion du télescope
   #  param   suiviState {0|1}
   #
   proc ::collector::configTraceSuivi { suiviState } {
      variable This

      set trace 0
      if {[trace info variable ::audace(telescope,controle)] ne ""} {
         set trace 1
      }

      #--   configure la trace
      if {$suiviState != 0 && $trace == 0} {
         trace add variable ::audace(telescope,controle) write "::collector::onChangeSuivi"
      } elseif {$suiviState == 0 && $trace == 1} {
         trace remove variable ::audace(telescope,controle) write "::collector::onChangeSuivi"
      }

      #--   configure la ligne
      set w $This.n.tlscp

      if {$suiviState == 1} {
         grid $w.lab_suivi -row 1 -column 0 -sticky w -padx 10 -pady 3
         grid $w.suivi -row 1 -column 1 -sticky e -padx 10
      } else {
         if {[winfo exists $w.lab_suivi]} {
            grid forget $w.lab_suivi $w.suivi
         }
      }
   }

   #------------------------------------------------------------
   #  brief   configure la trace en cas des coordonnées du télescope
   #  param   hasCoordinates {0|1}
   #
   proc ::collector::configTraceRaDec { hasCoordinates } {
      variable This
      variable private

      set trace 0
      if {[trace info variable ::audace(telescope,getra)] ne ""} {
         set trace 1
      }

      #--   configure la trace
      if {$hasCoordinates == 1 && $trace == 0} {
         trace add variable ::audace(telescope,getra) write "::collector::refreshNotebook"
      } elseif {$hasCoordinates == 0 && $trace == 1} {
         trace remove variable ::audace(telescope,getra) write "::collector::refreshNotebook"
      }

      #--   configure les lignes
      set w $This.n.tlscp

      if {$hasCoordinates == 1} {
         #--   affiche les lignes
         set r 2
         foreach v [list vra vdec vxPix vyPix] {
            grid $w.lab_$v -row $r -column 0 -sticky w -padx 10 -pady 3
            grid $w.$v -row $r -column 1 -sticky e -padx 10
            incr r
         }
      } else {
         #--   supprime les lignes
         if {[winfo exists ${w}.lab_vra]} {
            grid forget $w.lab_vra $w.vra $w.lab_vdec $w.vdec $w.lab_vxPix $w.vxPix $w.lab_vyPix $w.vyPix
         }
      }
   }

   #------------------------------------------------------------
   #  brief   commande du bouton 'Modifier' (focuser)
   #
   proc ::collector::callFocuser {} {

      set focuserNamespace $::confEqt::private(selectedFocuser)
      set isReady 0
      if {$focuserNamespace ne "Pas de focuser" && [::$focuserNamespace\::isReady]} {
         #--   ouvre le panneau du fcosuer actif
         set ::panneau(foc,focuser) $focuserNamespace
         ::confEqt::run ::panneau(foc,focuser) focuser
      } else {
         #--   ouvre le panneau des Focuser sur AudeCom
         ::confEqt::run "" focuser
      }
   }

   #------------------------------------------------------------
   #  brief   masque les onglets Monture et Equatorial
   #  param   notebook chemin de l'onglet
   #
   proc ::collector::hideTel { notebook } {
      variable private

      $notebook hide $notebook.tlscp
      $notebook hide $notebook.german

      #--   supprime le suivi
      ::collector::configTraceSuivi 0

      #--   supprime l'affichage des vitesses
      ::collector::configTraceRaDec 0

      #--   reinitialise les variables
      set private(vra) [format %0.5f 0]
      set private(vdec) [format %0.5f 0]
      set private(vxPix) [format %0.1f 0]
      set private(vyPix) [format %0.1f 0]

      set visuNoTel [::confVisu::getToolVisuNo ::tlscp]
      if {$visuNoTel ne ""} {
         set bufNo [::confVisu::getBufNo $visuNoTel]
      } else {
         set bufNo [::confVisu::getBufNo 1]
      }
      #--   si trace presente et telescope deconnecte
      if {[trace info variable ::tlscp::private($visuNoTel,nomObjet)] ne ""} {
         trace remove variable ::tlscp::private($visuNoTel,nomObjet) write "::collector::onChangeObjName $bufNo"
      }
   }


   #  brief retourne la liste des valeurs d'une liste de variables
   #  remarks  associée à des fonctions ::struct::list
   #
   proc ::collector::getValue {var} {variable private ; return $private($var)" }

   #  brief extrait tous les éléments d'index n dans une liste de listes
   #  remarks  associée à des fonctions ::struct::list
   #
   proc ::collector::extractIndex {n list} {::lindex $list $n}

