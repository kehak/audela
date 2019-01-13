#
## @file astrometry.tcl
#  @brief Fonctions de calibration astrométrique des images ;
#  Functions to calibrate astrometry on images
#  @author Alain KLOTZ
#  $Id: astrometry.tcl 13610 2016-04-04 14:37:59Z rzachantke $
#  @pre cet outil exige la présence d'une image dans le buffer de la visu

#============================================================
# Declaration du namespace astrometry
#    initialise le namespace
#============================================================

## @namespace astrometry
#  @brief Fonctions de calibration astrométrique des images ;
namespace eval ::astrometry {
   package provide astrometry 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] astrometry.cap ]

   #------------------------------------------------------------
   # brief     retourne le titre du plugin dans la langue de l'utilisateur
   # return    titre du plugin
   #
   proc getPluginTitle { } {
      global caption

      return "$caption(astrometry,title)"
   }

   #------------------------------------------------------------
   # brief     retourne le nom du fichier d'aide principal
   # return    nom du fichier d'aide principal
   #
   proc getPluginHelp { } {
      return "astrometry.htm"
   }

   #------------------------------------------------------------
   # brief     retourne le type de plugin
   # return    type de plugin
   #
   proc getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   # brief     retourne le nom du répertoire du plugin
   # return    nom du répertoire du plugin : "astrometry"
   #
   proc getPluginDirectory { } {
      return "astrometry"
   }

   #------------------------------------------------------------
   ## @brief    retourne le ou les OS de fonctionnement du plugin
   #  @return   liste des OS : "Windows Linux Darwin"
   #
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
   }

   #------------------------------------------------------------
   ## @brief    retourne les propriétés de l'outil
   #
   #            cet outil s'ouvre dans une fenêtre indépendante à partir du menu Analyse
   #  @param    propertyName nom de la propriété
   #  @return   valeur de la propriété ou "" si la propriété n'existe pas
   #
   proc getPluginProperty { propertyName } {
      switch $propertyName {
         function     { return "analysis" }
         subfunction1 { return "astrometry" }
         display      { return "window" }
         default      { return "" }
      }
   }

   #------------------------------------------------------------
   ## @brief   créé une nouvelle instance de l'outil
   #  @param   base   base tk
   #  @param   visuNo numéro de la visu
   #  @return  chemin de la fenêtre ou NOP (CF avertissement)
   #  @warning retourne un message si pas d'image dans le buffer
   #  ou si l'image est un spectre ; la fenêtre n'est pas créée
   #
   proc createPluginInstance { base { visuNo 1 } } {
      variable astrom
      global audace caption conf

      #--- Recherche une image dans le buffer
      if { [ buf$audace(bufNo) imageready ] == "0" } {
         #--- Sortie anticipee
         tk_messageBox -message "$caption(astrometry,error_no_image)" -title "$caption(astrometry,title)" -icon error
         return "NOP"
      }

      #--- Recherche le type de l'image
      if { [lindex [buf$audace(bufNo) getkwd NAXIS ] 1] == "1" } {
         #--- Sortie anticipee
         tk_messageBox -message "$caption(astrometry,error_spectrum)" -title "$caption(astrometry,title)" -icon error
         return "NOP"
      }

      #--- Inititalisation du nom de la fenetre
      set astrom(This) "$base.astrometry"

      #--- j'initialise les variable des widgets
      ::astrometry::confToWidget

      #--- Inititalisation de variables de configuration
      set astrom(typewcs)  {optic classic matrix}
      set astrom(typecal)  {catalog file manual delwcs}
      set astrom(kwds)     {RA                       DEC                       CRPIX1        CRPIX2        CRVAL1          CRVAL2           CDELT1    CDELT2    CROTA2                    CD1_1         CD1_2         CD2_1         CD2_2         FOCLEN         PIXSIZE1                        PIXSIZE2}
      set astrom(units)    {deg                      deg                       pixel         pixel         deg             deg              deg/pixel deg/pixel deg                       deg/pixel     deg/pixel     deg/pixel     deg/pixel     m              mum                             mum}
      set astrom(types)    {double                   double                    double        double        double          double           double    double    double                    double        double        double        double        float          float                           float}
      set astrom(values)   {""                       ""                        ""            ""            ""              ""               ""        ""        ""                        ""            ""            ""            ""            ""             ""                              ""}
      set astrom(comments) {"RA expected for CRPIX1" "DEC expected for CRPIX2" "X ref pixel" "Y ref pixel" "RA for CRPIX1" "DEC for CRPIX2" "X scale" "Y scale" "Position angle of North" "Matrix CD11" "Matrix CD12" "Matrix CD21" "Matrix CD22" "Focal length" "X pixel size binning included" "Y pixel size binning included"}

      #--- Je declare le rafraichissement automatique des mots-cles si on charge une image
      ::confVisu::addFileNameListener $visuNo "::astrometry::updatewcs"
      ::confVisu::addFileNameListener $visuNo "::astrometry::update_keywords"

      #--- J'ouvre la fenetre
      ::astrometry::create $visuNo

      #---
      return $astrom(This)
   }

   #------------------------------------------------------------
   ## @brief   suppprime l'instance du plugin
   #  @param   visuNo numéro de la visu
   #
   proc deletePluginInstance { visuNo } {
      variable astrom

      if [winfo exists $astrom(This) ] {
         #--- Je ferme la fenetre si l'utilisateur ne l'a pas deja fait
         ::astrometry::cmdClose $visuNo
      }
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de l'outil "Calibration WCS d'une seule image"
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(astrometry,position)        définit la position de la fenêtre
   #  - conf(astrometry,cattype)         index de la sélection du catalogue
   #  - conf(astrometry,personnalfolder) chemin d'accès à un catalogue utilisateur
   #  - conf(astrometry,catfolder)       chemin d'accès au catalogue
   #  - conf(astrometry,delete_files)    option de "Suppression des fichiers temporaires"
   #  - conf(astrometry,delete_images)   option de "Suppression des images temporaires"
   #
   proc initConf { } {
      global audace conf

      if { ! [ info exists conf(astrometry,position) ] }        { set conf(astrometry,position)        "+150+100" }
      if { ! [ info exists conf(astrometry,cattype) ] }         { set conf(astrometry,cattype)         "1" }
      if { ! [ info exists conf(astrometry,personnalfolder) ] } { set conf(astrometry,personnalfolder) "" }
      if { ! [ info exists conf(astrometry,catfolder) ] }       { set conf(astrometry,catfolder)       "$audace(rep_userCatalogMicrocat)" }
      if { ! [ info exists conf(astrometry,delete_files) ] }    { set conf(astrometry,delete_files)    "1" }
      if { ! [ info exists conf(astrometry,delete_images) ] }   { set conf(astrometry,delete_images)   "1" }
   }

   #------------------------------------------------------------
   #  brief   charge les variables de configuration dans des variables locales
   #
   proc confToWidget { } {
      variable astrom
      global conf caption

      initConf

      set astrom(list_combobox) [ list $caption(astrometry,cat,usno) $caption(astrometry,cat,microcat) \
         $caption(astrometry,cat,personal) ]

      set astrom(catfolder)     $conf(astrometry,catfolder)
      set astrom(cattype)       [ lindex $astrom(list_combobox) $conf(astrometry,cattype) ]
      set astrom(position)      $conf(astrometry,position)
      set astrom(delete_files)  $conf(astrometry,delete_files)
      set astrom(delete_images) $conf(astrometry,delete_images)
   }

   #------------------------------------------------------------
   #  brief   charge les variables locales dans des variables de configuration
   #
   proc widgetToConf { } {
      variable astrom
      global conf

      #-- recupère la position
      set astrom(geometry) [ wm geometry $astrom(This) ]
      set deb [ expr 1 + [ string first + $astrom(geometry) ] ]
      set fin [ string length $astrom(geometry) ]

      set conf(astrometry,position)      "+[ string range $astrom(geometry) $deb $fin ]"
      set conf(astrometry,catfolder)     $astrom(catfolder)
      set conf(astrometry,cattype)       [ lsearch $astrom(list_combobox) $astrom(cattype) ]
      set conf(astrometry,delete_files)  $astrom(delete_files)
      set conf(astrometry,delete_images) $astrom(delete_images)
   }

   #------------------------------------------------------------
   #  brief   créé l'interface graphique
   #  param visuNo numéro de la visu
   #
   proc create { visuNo } {
      variable astrom
      global audace caption

      if { [info commands $astrom(This)]=="$astrom(This)" } {
         wm deiconify $astrom(This)
         return
      }

      toplevel $astrom(This)
      wm geometry $astrom(This) $astrom(position)
      wm maxsize $astrom(This) [winfo screenwidth .] [winfo screenheight .]
      wm minsize $astrom(This) 500 400
      wm resizable $astrom(This) 1 1
      wm deiconify $astrom(This)
      wm title $astrom(This) "$caption(astrometry,title)"
      wm protocol $astrom(This) WM_DELETE_WINDOW "::astrometry::cmdClose $visuNo"
      #--- Button for choosing the WCS type displayed
      button $astrom(This).but1 -text "$caption(astrometry,wcs,[lindex $astrom(typewcs) 0])" \
         -command {::astrometry::wcs_pack +}
      pack $astrom(This).but1 -in $astrom(This) -anchor center -fill x -pady 10 -ipadx 15 -padx 5 -ipady 5
      #--- Frames from the differents type of WCS
      frame $astrom(This).wcs
      pack $astrom(This).wcs -in $astrom(This) -anchor center -fill x
      foreach wcs $astrom(typewcs) {
         frame $astrom(This).wcs.${wcs}
      }
      #--- Read the values of header keywords
      ::astrometry::updatewcs
      #--- Update the keywords that are voids
      ::astrometry::update_keywords
      #--- Button for choosing the Method for calibration
      button $astrom(This).but2 -text "$caption(astrometry,cal,[lindex $astrom(typecal) 0])" \
         -command {::astrometry::cal_pack +}
      pack $astrom(This).but2 -in $astrom(This) -anchor center -fill x -pady 10 -ipadx 15 -padx 5 -ipady 5
      #--- Frames from the differents type of methods of calibration
      frame $astrom(This).cal
      pack $astrom(This).cal -in $astrom(This) -anchor center -fill x
      foreach cal $astrom(typecal) {
         frame $astrom(This).cal.${cal}
      }
      #--- Calibration from a catalog
      set cal catalog
      frame $astrom(This).cal.${cal}.fra_0
         label $astrom(This).cal.${cal}.fra_0.lab -text "$caption(astrometry,cal,catname)"
         pack $astrom(This).cal.${cal}.fra_0.lab -side left
         set list_combobox $astrom(list_combobox)
         ComboBox $astrom(This).cal.${cal}.fra_0.cat \
            -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
            -height [llength $list_combobox ] \
            -relief sunken    \
            -borderwidth 1    \
            -editable 0       \
            -textvariable ::astrometry::astrom(cattype) \
            -values $list_combobox \
            -modifycmd "::astrometry::modifydirname"
         pack $astrom(This).cal.${cal}.fra_0.cat -side left
      pack $astrom(This).cal.${cal}.fra_0 -anchor center -fill x
      frame $astrom(This).cal.${cal}.fra_1
         label $astrom(This).cal.${cal}.fra_1.lab -text "$caption(astrometry,cal,catfolder)"
         pack $astrom(This).cal.${cal}.fra_1.lab -side left
         if { [ string length $astrom(catfolder) ] < 50 } {
            set width "50"
         } else {
            set width [ string length $astrom(catfolder) ]
         }
         entry $astrom(This).cal.${cal}.fra_1.ent -textvariable ::astrometry::astrom(catfolder) -width $width
         pack $astrom(This).cal.${cal}.fra_1.ent -fill x -expand 1 -side left -padx 5
         button $astrom(This).cal.${cal}.fra_1.but -text "$caption(astrometry,cal,parcourir)" \
            -command "::astrometry::exploredirname"
         pack $astrom(This).cal.${cal}.fra_1.but -side left -padx 5 -ipady 5
      pack $astrom(This).cal.${cal}.fra_1 -anchor center -fill x
      #--- Calibration from a file
      set cal file
      frame $astrom(This).cal.${cal}.fra_1
         label $astrom(This).cal.${cal}.fra_1.lab -text "$caption(astrometry,cal,filename)"
         pack $astrom(This).cal.${cal}.fra_1.lab -side left
         entry $astrom(This).cal.${cal}.fra_1.ent -textvariable ::astrometry::astrom(reffile) -width 40
         pack $astrom(This).cal.${cal}.fra_1.ent -side left
         button $astrom(This).cal.${cal}.fra_1.but -text "$caption(astrometry,cal,parcourir)" \
            -command {
               set d [ ::tkutil::box_load $::astrometry::astrom(This) $audace(rep_images) $audace(bufNo) "1" ]
               if {$d!=""} {set ::astrometry::astrom(reffile) $d ; update ; focus $::astrometry::astrom(This)}
            }
         pack $astrom(This).cal.${cal}.fra_1.but -side left -padx 2 -ipady 5
      pack $astrom(This).cal.${cal}.fra_1 -anchor center -fill x
      #--- Button to start the calibration and help
      frame $astrom(This).cal.fra_2
         button $astrom(This).cal.fra_2.but3 -text "$caption(astrometry,start)" \
            -command "::astrometry::cmdApplyStart"
         pack $astrom(This).cal.fra_2.but3 -in $astrom(This).cal.fra_2 -side left -anchor center \
            -fill x -expand true -pady 10 -ipadx 15 -padx 5 -ipady 5
         button $astrom(This).cal.fra_2.but4 -text "$caption(astrometry,help)" -width 7 \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::astrometry::getPluginType ] ] \
               [ ::astrometry::getPluginDirectory ] [ ::astrometry::getPluginHelp ]"
         pack $astrom(This).cal.fra_2.but4 -in $astrom(This).cal.fra_2 -side left -anchor center \
            -pady 5 -ipadx 15 -padx 5 -ipady 5
         button $astrom(This).cal.fra_2.but5 -text "$caption(astrometry,close)" -width 7 \
            -command "::astrometry::cmdClose $visuNo"
         pack $astrom(This).cal.fra_2.but5 -in $astrom(This).cal.fra_2 -side left -anchor center \
            -pady 5 -ipadx 15 -padx 5 -ipady 5
      pack $astrom(This).cal.fra_2 -side bottom -anchor center -fill x
      #---
      frame $astrom(This).status
         label $astrom(This).status.labURL -text ""
         pack $astrom(This).status.labURL -side left
      pack $astrom(This).status -anchor center -fill x
      #---
      frame $astrom(This).delete_files
         checkbutton $astrom(This).delete_files.chk -text "$caption(astrometry,delete_files)" \
            -highlightthickness 0 -variable ::astrometry::astrom(delete_files)
         pack $astrom(This).delete_files.chk -side left -pady 3
      pack $astrom(This).delete_files -anchor center -fill x
      #---
      frame $astrom(This).delete_images
         checkbutton $astrom(This).delete_images.chk -text "$caption(astrometry,delete_image)" \
            -highlightthickness 0 -variable ::astrometry::astrom(delete_images)
         pack $astrom(This).delete_images.chk -side left -pady 3
      pack $astrom(This).delete_images -anchor center -fill x

      #--- Gestion de l'etat de l'entry du chemin du catalogue
      if { $astrom(cattype) == "$caption(astrometry,cat,personal)" } {
         $astrom(This).cal.catalog.fra_1.ent configure -state normal
      } else {
         $astrom(This).cal.catalog.fra_1.ent configure -state disabled
      }

      #---
      set astrom(currenttypewcs) [lindex $astrom(typewcs) 0]
      ::astrometry::wcs_pack $astrom(currenttypewcs)

      #---
      set astrom(currenttypecal) [lindex $astrom(typecal) 0]
      ::astrometry::cal_pack $astrom(currenttypecal)

      #--- Focus
      focus $astrom(This)

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $astrom(This) <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $astrom(This)
   }

   #------------------------------------------------------------
   ## @brief  commande du bouton "Fermer"
   #  @param visuNo numéro de la visu
   #
   proc cmdClose { visuNo } {
      variable astrom

      #--- Supprime les procedures appelees si on charge une image
      ::confVisu::removeFileNameListener $visuNo "::astrometry::update_keywords"
      ::confVisu::removeFileNameListener $visuNo "::astrometry::updatewcs"
      #--- Supprime les fichiers de configuration necessaire a Sextractor
      deleteFileConfigSextractor
      #--- Sauvegarde la configuration
      ::astrometry::widgetToConf
      #--- Detruit la fenetre Toplevel
      destroy $astrom(This)
      #--- Ferme la fenetre de resultat
      ::astrometry::closeJpeg
   }

   #------------------------------------------------------------
   #  brief  lit les valeurs des mots clés de l'en-tête de l'image
   #  param args
   #
   proc updatewcs { args } {
      variable astrom
      global audace

      #--- Read the values of header keywords
      set k 0
      foreach kwd $astrom(kwds) {
         set d [buf$audace(bufNo) getkwd $kwd]
         if {[lindex $d 1]==""} {
            #--- The value does not exists in image, we take the default value
            set ::astrometry::astrom(wcsvalues,$kwd) [lindex $astrom(values) $k]
            set ::astrometry::astrom(wcsunits,$kwd) [lindex $astrom(units) $k]
            set ::astrometry::astrom(wcscomments,$kwd) [lindex $astrom(comments) $k]
            set ::astrometry::astrom(wcstypes,$kwd) [lindex $astrom(types) $k]
         } else {
            #--- The value does exists, we take the image header value
            set ::astrometry::astrom(wcsvalues,$kwd) [lindex $d 1]
            set ::astrometry::astrom(wcsunits,$kwd) [lindex $d 4]
            set ::astrometry::astrom(wcscomments,$kwd) [lindex $d 3]
            set ::astrometry::astrom(wcstypes,$kwd) [lindex $d 2]
         }
         incr k
      }

      #--- Update the CRPIX1 & CRPIX2 keywords
      set dimx [lindex [buf$audace(bufNo) getkwd NAXIS1 ] 1]
      set dimy [lindex [buf$audace(bufNo) getkwd NAXIS2 ] 1]
      if {$::astrometry::astrom(wcsvalues,CRPIX1)==""} {
         set ::astrometry::astrom(wcsvalues,CRPIX1) [expr $dimx /2.]
      }
      if {$::astrometry::astrom(wcsvalues,CRPIX2)==""} {
         set ::astrometry::astrom(wcsvalues,CRPIX2) [expr $dimy /2.]
      }

      #--- Fenetre active
      focus $astrom(This)
   }

   #------------------------------------------------------------
   #  brief  vérifie l'existance ou non des mots clés en fonction de l'option choisie
   #
   proc wcsempty { } {
      variable astrom
      global caption

      if { $astrom(currenttypewcs) == "optic" } {
         set kwdscan { RA DEC FOCLEN PIXSIZE1 PIXSIZE2 CROTA2 CRPIX1 CRPIX2 }
         #--- Read the values of header keywords
         set k 0
         foreach kwd $kwdscan {
            if { $astrom(wcsvalues,$kwd) == "" } {
               tk_messageBox -message "$caption(astrometry,empty_keywords)" -title "$caption(astrometry,title)" -icon error
               return 1
            }
            incr k
         }
         return 0
      } elseif { $astrom(currenttypewcs) == "classic" } {
         set kwdscan { CRVAL1 CRVAL2 CDELT1 CDELT2 CROTA2 CRPIX1 CRPIX2 }
         #--- Read the values of header keywords
         set k 0
         foreach kwd $kwdscan {
            if { $astrom(wcsvalues,$kwd) == "" } {
               tk_messageBox -message "$caption(astrometry,empty_keywords)" -title "$caption(astrometry,title)" -icon error
               return 1
            }
            incr k
         }
         return 0
      } elseif { $astrom(currenttypewcs) == "matrix" } {
         set kwdscan { CRVAL1 CRVAL2 CD1_1 CD1_2 CD2_1 CD2_2 CRPIX1 CRPIX2 }
         #--- Read the values of header keywords
         set k 0
         foreach kwd $kwdscan {
            if { $astrom(wcsvalues,$kwd) == "" } {
               tk_messageBox -message "$caption(astrometry,empty_keywords)" -title "$caption(astrometry,title)" -icon error
               return 1
            }
            incr k
         }
         return 0
      }
   }

   #------------------------------------------------------------
   #  brief met à jour les mots clés qui sont vides
   #  param args
   #
   proc update_keywords { args } {
      variable astrom
      global audace

      #--- Update the keywords that are voids
      set dimx [lindex [buf$audace(bufNo) getkwd NAXIS1 ] 1]
      set dimy [lindex [buf$audace(bufNo) getkwd NAXIS2 ] 1]
      if {$::astrometry::astrom(wcsvalues,CRPIX1)==""} {
         set ::astrometry::astrom(wcsvalues,CRPIX1) [expr $dimx /2.]
      }
      if {$::astrometry::astrom(wcsvalues,CRPIX2)==""} {
         set ::astrometry::astrom(wcsvalues,CRPIX2) [expr $dimy /2.]
      }
      #---
      if {($::astrometry::astrom(wcsvalues,CRVAL1)=="")&&($::astrometry::astrom(wcsvalues,RA)!="")} {
         set ::astrometry::astrom(wcsvalues,CRVAL1) $::astrometry::astrom(wcsvalues,RA)
      } elseif {($::astrometry::astrom(wcsvalues,CRVAL1)!="")&&($::astrometry::astrom(wcsvalues,RA)=="")} {
         set ::astrometry::astrom(wcsvalues,RA) $::astrometry::astrom(wcsvalues,CRVAL1)
      }
      if {($::astrometry::astrom(wcsvalues,CRVAL2)=="")&&($::astrometry::astrom(wcsvalues,DEC)!="")} {
         set ::astrometry::astrom(wcsvalues,CRVAL2) $::astrometry::astrom(wcsvalues,DEC)
      } elseif {($::astrometry::astrom(wcsvalues,CRVAL2)!="")&&($::astrometry::astrom(wcsvalues,DEC)=="")} {
         set ::astrometry::astrom(wcsvalues,DEC) $::astrometry::astrom(wcsvalues,CRVAL2)
      }
      #---
      set valid_optic 2
      set valid_matrix 2
      set valid_classic 2
      #---
      if { $::astrometry::astrom(wcsvalues,RA) != "" }       { incr valid_optic }
      if { $::astrometry::astrom(wcsvalues,DEC) != "" }      { incr valid_optic }
      if { $::astrometry::astrom(wcsvalues,CRVAL1) != "" }   { incr valid_matrix ; incr valid_classic ; incr valid_optic }
      if { $::astrometry::astrom(wcsvalues,CRVAL2) != "" }   { incr valid_matrix ; incr valid_classic ; incr valid_optic }
      if { $::astrometry::astrom(wcsvalues,CDELT1) != "" }   { incr valid_classic ; incr valid_optic }
      if { $::astrometry::astrom(wcsvalues,CDELT2) != "" }   { incr valid_classic ; incr valid_optic }
      if { $::astrometry::astrom(wcsvalues,CROTA2) != "" }   { incr valid_optic ; incr valid_classic }
      if { $::astrometry::astrom(wcsvalues,PIXSIZE1) != "" } { incr valid_optic }
      if { $::astrometry::astrom(wcsvalues,PIXSIZE2) != "" } { incr valid_optic }
      if { $::astrometry::astrom(wcsvalues,FOCLEN) != "" }   { incr valid_optic }
      if { $::astrometry::astrom(wcsvalues,CD1_1) != "" }    { incr valid_matrix }
      if { $::astrometry::astrom(wcsvalues,CD2_1) != "" }    { incr valid_matrix }
      if { $::astrometry::astrom(wcsvalues,CD1_2) != "" }    { incr valid_matrix }
      if { $::astrometry::astrom(wcsvalues,CD2_2) != "" }    { incr valid_matrix }
      #---
      set ufoclen 1.
      set upixsize1 1.
      set upixsize2 1.
      if {($valid_optic>=8)} {
         if {$::astrometry::astrom(wcsunits,FOCLEN)=="mum" || $::astrometry::astrom(wcsunits,FOCLEN)=="um"} {
            set ufoclen 1e-6
         }
         if {$::astrometry::astrom(wcsunits,FOCLEN)=="mm"} {
            set ufoclen 1e-3
         }
         if {$::astrometry::astrom(wcsunits,FOCLEN)=="m"} {
            set ufoclen 1.
         }
         if {$::astrometry::astrom(wcsunits,PIXSIZE1)=="mum" || $::astrometry::astrom(wcsunits,PIXSIZE1)=="um"} {
            set upixsize1 1e-6
         }
         if {$::astrometry::astrom(wcsunits,PIXSIZE1)=="mm"} {
            set upixsize1 1e-3
         }
         if {$::astrometry::astrom(wcsunits,PIXSIZE1)=="m"} {
            set upixsize1 1.
         }
         if {$::astrometry::astrom(wcsunits,PIXSIZE2)=="mum" || $::astrometry::astrom(wcsunits,PIXSIZE2)=="um"} {
            set upixsize2 1e-6
         }
         if {$::astrometry::astrom(wcsunits,PIXSIZE2)=="mm"} {
            set upixsize2 1e-3
         }
         if {$::astrometry::astrom(wcsunits,PIXSIZE2)=="m"} {
            set upixsize2 1.
         }
      }
      #::console::affiche_resultat "valid_classic=$valid_classic valid_optic=$valid_optic valid_matrix=$valid_matrix\n"
      if {($valid_optic>=8)&&($valid_classic<7)} {
         set ::astrometry::astrom(wcsvalues,CDELT1) [expr -2*atan($::astrometry::astrom(wcsvalues,PIXSIZE1)*$upixsize1/2./$::astrometry::astrom(wcsvalues,FOCLEN)/$ufoclen)];
         set ::astrometry::astrom(wcsvalues,CDELT2) [expr  2*atan($::astrometry::astrom(wcsvalues,PIXSIZE2)*$upixsize2/2./$::astrometry::astrom(wcsvalues,FOCLEN)/$ufoclen)];
      }
      #if {(valid_matrix>=8)} {}
      if {($valid_optic>=8)&&($valid_classic<7)} {
         set pi [expr 4*atan(1.)]
         if { $::astrometry::astrom(wcsvalues,CROTA2) != "" } {
            set cosr [expr cos($::astrometry::astrom(wcsvalues,CROTA2)*$pi/180.)]
            set sinr [expr sin($::astrometry::astrom(wcsvalues,CROTA2)*$pi/180.)]
            set ::astrometry::astrom(wcsvalues,CD1_1) [expr $::astrometry::astrom(wcsvalues,CDELT1)*$cosr ]
            set ::astrometry::astrom(wcsvalues,CD1_2) [expr  abs($::astrometry::astrom(wcsvalues,CDELT2))*$::astrometry::astrom(wcsvalues,CDELT1)/abs($::astrometry::astrom(wcsvalues,CDELT1))*$sinr ]
            set ::astrometry::astrom(wcsvalues,CD2_1) [expr -abs($::astrometry::astrom(wcsvalues,CDELT1))*$::astrometry::astrom(wcsvalues,CDELT2)/abs($::astrometry::astrom(wcsvalues,CDELT2))*$sinr ]
            set ::astrometry::astrom(wcsvalues,CD2_2) [expr $::astrometry::astrom(wcsvalues,CDELT2)*$cosr ]
         }
      }
      #--- Display the values of header keywords
      ::astrometry::keyword optic RA
      ::astrometry::keyword optic DEC
      ::astrometry::keyword optic FOCLEN
      ::astrometry::keyword optic PIXSIZE1
      ::astrometry::keyword optic PIXSIZE2
      ::astrometry::keyword optic CROTA2
      ::astrometry::keyword optic CRPIX1
      ::astrometry::keyword optic CRPIX2
      #---
      ::astrometry::keyword classic CRVAL1
      ::astrometry::keyword classic CRVAL2
      ::astrometry::keyword classic CDELT1
      ::astrometry::keyword classic CDELT2
      ::astrometry::keyword classic CROTA2
      ::astrometry::keyword classic CRPIX1
      ::astrometry::keyword classic CRPIX2
      #---
      ::astrometry::keyword matrix CRVAL1
      ::astrometry::keyword matrix CRVAL2
      ::astrometry::keyword matrix CD1_1
      ::astrometry::keyword matrix CD1_2
      ::astrometry::keyword matrix CD2_1
      ::astrometry::keyword matrix CD2_2
      ::astrometry::keyword matrix CRPIX1
      ::astrometry::keyword matrix CRPIX2
   }

   #------------------------------------------------------------
   ## @brief commande du bouton "Démarrer le calcul de la calibration"
   #  @param sextractor no par défaut
   #  @param silent     no par défaut
   #
   proc cmdApplyStart { { sextractor no } { silent no } } {
      variable astrom
      global audace caption color conf

      #--- Search empty header keywords
      if { [ ::astrometry::wcsempty ] == "1" } {
         return
      }
      #---
      set sextractor yes
      set starfile no
      #::console::affiche_resultat "=====> astrom(currenttypewcs)=$astrom(currenttypewcs) \n"
      if {$astrom(currenttypecal)=="delwcs"} {
         set kwddels {CD1_1 CD1_2 CD2_1 CD2_2 CRVAL1 CRVAL2 CDELT1 CDELT2 CROTA2 FOCLEN CRPIX1 CRPIX2}
         set kwdnews {}
      } else {
         if {$astrom(currenttypewcs)=="optic"} {
            set kwddels {CD1_1 CD1_2 CD2_1 CD2_2 CRVAL1 CRVAL2 CDELT1 CDELT2}
            set kwdnews {FOCLEN PIXSIZE1 PIXSIZE2 CROTA2 CRPIX1 CRPIX2 RA DEC CRVAL1 CRVAL2 CDELT1 CDELT2}
         }
         if {$astrom(currenttypewcs)=="classic"} {
            set kwddels {FOCLEN CD1_1 CD1_2 CD2_1 CD2_2}
            set kwdnews {CRVAL1 CRVAL2 CDELT1 CDELT2 CROTA2 CRPIX1 CRPIX2}
         }
         if {$astrom(currenttypewcs)=="matrix"} {
            set kwddels {FOCLEN CDELT1 CDELT2 CROTA2}
         set kwdnews {CRVAL1 CRVAL2 CD1_1 CD1_2 CD2_1 CD2_2 CRPIX1 CRPIX2}
         }
      }
      foreach kwd $kwddels {
         catch {buf$audace(bufNo) delkwd $kwd}
         #::console::affiche_resultat " DEL $kwd\n"
      }
       foreach kwd $kwdnews {
         set d [list $kwd "$::astrometry::astrom(wcsvalues,$kwd)" "$::astrometry::astrom(wcstypes,$kwd)" "$::astrometry::astrom(wcscomments,$kwd)" "$::astrometry::astrom(wcsunits,$kwd)"]
         set kwd0 [lindex $d 0]
         set val [lindex $d 1]
         #::console::affiche_resultat " set d=$d\n"
         if {$kwd0!=""} {
            if {$kwd0=="RA"}     { set val [mc_angle2deg $val 360] }
            if {$kwd0=="DEC"}    { set val [mc_angle2deg $val 90] }
            if {$kwd0=="CRVAL1"} { set val [mc_angle2deg $val 360] }
            if {$kwd0=="CRVAL2"} { set val [mc_angle2deg $val 90] }
            if {$kwd0=="CROTA2"} { set val [mc_angle2deg $val 360] }
            set d [lreplace $d 1 1 $val]
            buf$audace(bufNo) setkwd $d
         }
         #::console::affiche_resultat " SET $d\n"
      }
      if {$astrom(currenttypewcs)=="optic"} {
         set valra 0.0
         set valdec 0.0
         foreach kwd $kwdnews {
            set d [list $kwd "$::astrometry::astrom(wcsvalues,$kwd)" "$::astrometry::astrom(wcstypes,$kwd)" "$::astrometry::astrom(wcscomments,$kwd)" "$::astrometry::astrom(wcsunits,$kwd)"]
            set kwd0 [lindex $d 0]
            set val [lindex $d 1]
            set unit [lindex $d 4]
            #::console::affiche_resultat " set d1=$d\n"
            if {$kwd0!=""} {
               if {$kwd0=="RA"}       { set valra [mc_angle2deg $val 360] }
               if {$kwd0=="DEC"}      { set valdec [mc_angle2deg $val 90] }
               if {$kwd0=="FOCLEN"}   { set valfoclen $val }
               if {$kwd0=="PIXSIZE1"} {
                  set mult 1.
                  if {$unit=="m"} {
                     set mult 1e6
                  }
                  set valpixsize1 [expr $val*$mult] ; # mum
               }
               if {$kwd0=="PIXSIZE2"} {
                  set mult 1.
                  if {$unit=="m"} {
                     set mult 1e6
                  }
                  set valpixsize2 [expr $val*$mult] ; # mum
               }
            }
         }
         set pi [expr 4*atan(1.)]
         foreach kwd $kwdnews {
            set d [list $kwd "$::astrometry::astrom(wcsvalues,$kwd)" "$::astrometry::astrom(wcstypes,$kwd)" "$::astrometry::astrom(wcscomments,$kwd)" "$::astrometry::astrom(wcsunits,$kwd)"]
            set kwd0 [lindex $d 0]
            set val [lindex $d 1]
            #::console::affiche_resultat " set d2=$d ($valdec)\n"
            if {$kwd0!=""} {
               if {$kwd0=="CRVAL1"} { set val $valra }
               if {$kwd0=="CRVAL2"} { set val $valdec }
               if {$kwd0=="CDELT1"} {
                  set mult 1e-6
                  set val [expr -2*atan($valpixsize1/$valfoclen*$mult/2.)*180/$pi]
               }
               if {$kwd0=="CDELT2"} {
                  set mult 1e-6
                  set val [expr 2*atan($valpixsize2/$valfoclen*$mult/2.)*180/$pi]
               }
               set d [lreplace $d 1 1 $val]
               buf$audace(bufNo) setkwd $d
            }
         }
      }
      $astrom(This).status.labURL configure -text "$caption(astrometry,start,0)" -fg $color(blue)
      update
      set ext $conf(extension,defaut)
      #--- Remplacement de "$audace(rep_images)" par "." dans "mypath" - Cela permet a
      #--- Sextractor de ne pas etre sensible aux noms de repertoire contenant des
      #--- espaces et ayant une longueur superieure a 70 caracteres
      set mypath "."
      set sky0 dummy0
      if {$astrom(currenttypecal)=="catalog"} {
         set cattype $astrom(cattype)
         set cdpath "$astrom(catfolder)"
         if { ( [ string length $cdpath ] > 0 ) && ( [ string index "$cdpath" end ] != "/" ) } {
            append cdpath "/"
         }
         set sky dummy
         catch {buf$audace(bufNo) delkwd CATASTAR}
         buf$audace(bufNo) save [ file join ${mypath} ${sky0}$ext ]
         $astrom(This).status.labURL configure -text "$caption(astrometry,start,1)" -fg $color(blue) ; update
         if {$sextractor=="no"} {
            ttscript2 "IMA/SERIES \"$mypath\" \"$sky0\" . . \"$ext\" \"$mypath\" \"$sky\" . \"$ext\" STAT \"objefile=${mypath}/x$sky$ext\" detect_kappa=20"
         } else {
            createFileConfigSextractor
            buf$audace(bufNo) save [ file join ${mypath} ${sky}$ext ]
            sextractor [ file join $mypath $sky0$ext ] -c [ file join $mypath config.sex ]
         }
         $astrom(This).status.labURL configure -text "$caption(astrometry,start,2) $cattype : $::astrometry::astrom(catfolder) ..." -fg $color(blue) ; update
         set erreur [ catch { ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"$sky\" . \"$ext\" CATCHART \"path_astromcatalog=$cdpath\" astromcatalog=$cattype \"catafile=${mypath}/c$sky$ext\" \"jpegfile_chart2=$mypath/${sky}a.jpg\" " } msg ]
         if { $erreur == "1" } {
            if {$silent=="no"} {
               if { $astrom(cattype) == "$caption(astrometry,cat,usno)" } {
                  ::astrometry::search_cata_USNO
               } else {
                  tk_messageBox -message "$caption(astrometry,erreur_catalog)" -title "$caption(astrometry,title)" -icon error
               }
            }
            #--- Suppression des fichiers temporaires
            if { $astrom(delete_files) == "1" } {
               ::astrometry::delete_lst
            }
            #--- Suppression des images temporaires
            if { $astrom(delete_images) == "1" } {
               ::astrometry::delete_dummy
            }
            #---
            $astrom(This).status.labURL configure -text ""
            update
            return
         } else {
            $astrom(This).status.labURL configure -text "$caption(astrometry,start,3)" -fg $color(blue) ; update
            if {$sextractor=="no"} {
               ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"$sky\" . \"$ext\" ASTROMETRY delta=5 epsilon=0.0002"
            } else {
               ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"$sky\" . \"$ext\" ASTROMETRY objefile=catalog.cat nullpixel=-10000 delta=5 epsilon=0.0002 file_ascii=ascii.txt"
            }
            $astrom(This).status.labURL configure -text "$caption(astrometry,start,4) $cattype : $::astrometry::astrom(catfolder) ..." -fg $color(blue) ; update
            ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"z$sky\" . \"$ext\" CATCHART \"path_astromcatalog=$cdpath\" astromcatalog=$cattype \"catafile=${mypath}/c$sky$ext\" \"jpegfile_chart2=$mypath/${sky}b.jpg\" "
            ttscript2 "IMA/SERIES \"$mypath\" \"x$sky\" . . \"$ext\" . . . \"$ext\" DELETE"
            ttscript2 "IMA/SERIES \"$mypath\" \"c$sky\" . . \"$ext\" . . . \"$ext\" DELETE"
            buf$audace(bufNo) load [file join ${mypath} ${sky}$ext ]
            #---
            set catastar [lindex [buf$audace(bufNo) getkwd CATASTAR] 1]
            if {$catastar>=3} {
               $astrom(This).status.labURL configure -text [ format $caption(astrometry,start,6) $catastar ] -fg $color(blue) ; update
               ::astrometry::visu_result
            } else {
               $astrom(This).status.labURL configure -text "$caption(astrometry,start,7) " -fg $color(red) ; update
            }
         }
      } elseif {$astrom(currenttypecal)=="file"} {
         set erreur [ catch { calibrate_from_file $::astrometry::astrom(reffile) } msg ]
         if { $erreur == "1" } {
            if {$silent=="no"} {
               tk_messageBox -message "$caption(astrometry,erreur_file)" -title "$caption(astrometry,title)" -icon error
            }
            #--- Suppression des fichiers temporaires
            if { $astrom(delete_files) == "1" } {
               ::astrometry::delete_lst
            }
            #--- Suppression des images temporaires
            if { $astrom(delete_images) == "1" } {
               ::astrometry::delete_dummy
            }
            #---
            $astrom(This).status.labURL configure -text ""
            update
            return
         } else {
            buf$audace(bufNo) save [ file join ${mypath} ${sky0}$ext ]
            buf$audace(bufNo) load [ file join ${mypath} ${sky0}$ext ]
            $astrom(This).status.labURL configure -text "$caption(astrometry,start,8) $::astrometry::astrom(reffile)" -fg $color(blue)
            set catastar 4
         }
      } elseif {$astrom(currenttypecal)=="manual"} {
         catch {buf$audace(bufNo) delkwd CATASTAR}
         buf$audace(bufNo) save [ file join ${mypath} ${sky0}$ext ]
         buf$audace(bufNo) load [ file join ${mypath} ${sky0}$ext ]
         $astrom(This).status.labURL configure -text "$caption(astrometry,start,9)" -fg $color(blue)
         set catastar 4
      } elseif {$astrom(currenttypecal)=="delwcs"} {
         catch {buf$audace(bufNo) delkwd CATASTAR}
         buf$audace(bufNo) save [ file join ${mypath} ${sky0}$ext ]
         buf$audace(bufNo) load [ file join ${mypath} ${sky0}$ext ]
         $astrom(This).status.labURL configure -text "$caption(astrometry,start,11)" -fg $color(blue)
         set catastar 0
         ::astrometry::updatewcs
      }
      if {$catastar<3} {
         return
      }

      #--- je configure confVisu pour gerer les deux echelles
      ::confVisu::setAvailableScale $::audace(visuNo) "xy_radec"

      #---
      if {$starfile=="yes"} {
         set stars [mc_readcat [ list BUFFER $audace(bufNo) ] [ list * ASTROMMICROCAT $astrom(catfolder) ] {LIST} -objmax 10000 -magr< 14 -magr> 10]
         set texte ""
         foreach re $stars {
            append texte "$re\n"
         }
         set f [open "microcat.txt" w ]
         puts -nonewline $f "$texte"
         close $f
         set texte ""
         set texte2 ""
         foreach re $stars {
            set dimx [lindex [buf$audace(bufNo) getkwd NAXIS1 ] 1]
            set dimy [lindex [buf$audace(bufNo) getkwd NAXIS2 ] 0]
            set racat [lindex $re 0]
            set deccat [lindex $re 1]
            set racat0 [lindex $re 0]
            set deccat0 [lindex $re 1]
            set xcat0 [lindex $re 4]
           # if {($xcat0>1030)&&($xcat0<1040)} {
              # continue
           # }
            set ycat0 [lindex $re 5]
            set err [catch {set xycat [buf$audace(bufNo) radec2xy [list $racat $deccat]]}]
            if {$err==1} {
               break
            }
            #::console::affiche_resultat "$re\n $xycat\n"
            set xcat [lindex $xycat 0]
            #if {$xcat>1035} {
               # set xcat [expr $xcat-4.]
            #}
            set ycat [lindex $xycat 1]
            set fen 4
            set x1 [expr int($xcat-$fen)]
            set y1 [expr int($ycat-$fen)]
            set x2 [expr int($xcat+$fen)]
            set y2 [expr int($ycat+$fen)]
            if {$x1<1} {set x1 1}
            if {$y1<1} {set y1 1}
            if {$x2>$dimx} {set x2 $dimx}
            if {$y2>$dimy} {set y2 $dimy}
            set box [list $x1 $y1 $x2 $y2]
            set d [buf$audace(bufNo) fitgauss $box]
            set xmes [lindex $d 1]
            #if {$xmes>1035} {
               # set xmes [expr $xmes+4.]
            #}
            set ymes [lindex $d 5]
            set radecmes [buf$audace(bufNo) xy2radec [list $xmes $ymes] 1]
            set rames [lindex $radecmes 0]
            set decmes [lindex $radecmes 1]
            set d [mc_anglesep [list $rames $decmes $racat0 $deccat0 ]]
            #::console::affiche_resultat "$xmes $ymes $d  $xcat0 $ycat0 \n"
            append texte "$xmes $ymes $d $xcat0 $ycat0 $rames $decmes $racat0 $deccat0\n"
            #---
            set radecmes [buf$audace(bufNo) xy2radec [list $xmes $ymes] 2]
            set rames [lindex $radecmes 0]
            set decmes [lindex $radecmes 1]
            set d [mc_anglesep [list $rames $decmes $racat0 $deccat0 ]]
            append texte2 "$xmes $ymes $d $xcat0 $ycat0 $rames $decmes $racat0 $deccat0\n"
         }
         set f [open "compare1.txt" w ]
         puts -nonewline $f "$texte"
         close $f
         set f [open "compare2.txt" w ]
         puts -nonewline $f "$texte2"
         close $f
         #---
         set texte ""
         for {set k1 1} {$k1<=2} {incr k1} {
            for {set k2 0} {$k2<=10} {incr k2} {
               append texte "[lindex [buf$audace(bufNo) getkwd PV${k1}_${k2}] 1] \n"
            }
         }
         set f [open "pv.txt" w ]
         puts -nonewline $f "$texte"
         close $f
      }
      #---
      update
   }

   #------------------------------------------------------------
   ## @brief configure l'interface graphique en fonction du choix des mots clés sélectionnés
   #  @param wcs définit le choix des mots clés sélectionnés
   #
   proc wcs_pack { { wcs + } } {
      variable astrom
      global caption

      foreach xwcs $astrom(typewcs) {
         pack forget $astrom(This).wcs.${xwcs}
      }
      set n [llength $astrom(typewcs)]
      if {$wcs=="+"} {
         set k [lsearch $astrom(typewcs) $astrom(currenttypewcs)]
         incr k
         if {$k>=$n} { set k 0 }
      } else {
         set k [lsearch $astrom(typewcs) $wcs]
         if {$k<0} { set k 0 }
         if {$k>$n} { set k [expr $n-1] }
      }
      set astrom(currenttypewcs) [lindex $astrom(typewcs) $k]
      pack $astrom(This).wcs.$astrom(currenttypewcs) -in $astrom(This).wcs -anchor center -fill x
      $astrom(This).but1 configure -text "$caption(astrometry,wcs,$astrom(currenttypewcs))"
      update
   }

   #------------------------------------------------------------
   ## @brief configure l'interface graphique en fonction du choix de la méthode de calibration
   #  @param cal définit la méthode de calibration sélectionnée
   #
   proc cal_pack { { cal + } } {
      variable astrom
      global caption

      foreach xcal $astrom(typecal) {
         pack forget $astrom(This).cal.${xcal}
      }
      set n [llength $astrom(typecal)]
      if {$cal=="+"} {
         set k [lsearch $astrom(typecal) $astrom(currenttypecal)]
         incr k
         if {$k>=$n} { set k 0 }
      } else {
         set k [lsearch $astrom(typecal) $cal]
         if {$k<0} { set k 0 }
         if {$k>$n} { set k [expr $n-1] }
      }
      set astrom(currenttypecal) [lindex $astrom(typecal) $k]
      pack $astrom(This).cal.$astrom(currenttypecal) -in $astrom(This).cal -anchor center -fill x
      $astrom(This).but2 configure -text "$caption(astrometry,cal,$astrom(currenttypecal))"
      $astrom(This).status.labURL configure -text ""
      update
   }

   #------------------------------------------------------------
   #  brief affichage du contenu des mots clés
   #  param wcs
   #  param kwd
   #
   proc keyword { wcs kwd } {
      variable astrom

      if [ winfo exists $astrom(This).wcs.${wcs}.fra_${kwd} ] {
         $astrom(This).wcs.${wcs}.fra_${kwd}.lab2 configure \
            -text "$astrom(wcsunits,${kwd}) ($astrom(wcscomments,${kwd}))"
      } else {
         frame $astrom(This).wcs.${wcs}.fra_${kwd}
            label $astrom(This).wcs.${wcs}.fra_${kwd}.lab1 -text ${kwd} -width 10
            pack $astrom(This).wcs.${wcs}.fra_${kwd}.lab1 -side left
            entry $astrom(This).wcs.${wcs}.fra_${kwd}.ent \
               -textvariable ::astrometry::astrom(wcsvalues,${kwd}) -width 26
            pack $astrom(This).wcs.${wcs}.fra_${kwd}.ent -side left
            label $astrom(This).wcs.${wcs}.fra_${kwd}.lab2 \
               -text "$astrom(wcsunits,${kwd}) ($astrom(wcscomments,${kwd}))"
            pack $astrom(This).wcs.${wcs}.fra_${kwd}.lab2 -side left
         pack $astrom(This).wcs.${wcs}.fra_${kwd} -anchor center -fill x
      }
   }

   #------------------------------------------------------------
   #  brief commande associée au choix du catalogue
   #
   proc modifydirname { } {
      variable astrom
      global audace caption conf

      if { $astrom(cattype) == "$caption(astrometry,cat,usno)" } {
         set astrom(catfolder) "$audace(rep_userCatalogUsnoa2)/"
         $astrom(This).cal.catalog.fra_1.ent configure -textvariable ::astrometry::astrom(catfolder) -state disabled
      } elseif { $astrom(cattype) == "$caption(astrometry,cat,microcat)" } {
         set astrom(catfolder) "$audace(rep_userCatalogMicrocat)/"
         $astrom(This).cal.catalog.fra_1.ent configure -textvariable ::astrometry::astrom(catfolder) -state disabled
      } elseif { $astrom(cattype) == "$caption(astrometry,cat,personal)" } {
         set astrom(catfolder) "$conf(astrometry,personnalfolder)"
         $astrom(This).cal.catalog.fra_1.ent configure -textvariable ::astrometry::astrom(catfolder) -state normal
      }
      $astrom(This).cal.catalog.fra_1.ent xview end
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "..." (parcourir)
   #
   proc exploredirname { } {
      variable astrom
      global audace caption conf

      if { $astrom(cattype) == "$caption(astrometry,cat,usno)" } {
         ::cwdWindow::run "$audace(base).cwdWindow"
         #::cwdWindow::changeRepUserCatalog cata_usnoa2
         set ::cwdWindow::cwdWindow(selected) "USNOA2"
         #--   Affiche le chemin dans l'entry
         ::cwdWindow::displayRep $::cwdWindow::cwdWindow(selected) $audace(base).cwdWindow.usr.4
         update
         $astrom(This).cal.catalog.fra_1.ent configure -textvariable ::audace(rep_userCatalogUsnoa2)
      } elseif { $astrom(cattype) == "$caption(astrometry,cat,microcat)" } {
         ::cwdWindow::run "$audace(base).cwdWindow"
         #::cwdWindow::changeRepUserCatalog cata_microcat
         set ::cwdWindow::cwdWindow(selected) "MICROCAT"
         update
         #--   Affiche le chemin dans l'entry
         ::cwdWindow::displayRep $::cwdWindow::cwdWindow(selected) $audace(base).cwdWindow.usr.4
         $astrom(This).cal.catalog.fra_1.ent configure -textvariable ::audace(rep_userCatalogMicrocat)
      } elseif { $astrom(cattype) == "$caption(astrometry,cat,personal)" } {
         set dirname [::astrometry::getdirname]
         set astrom(catfolder)                $dirname
         set conf(astrometry,personnalfolder) $dirname
         focus $astrom(This)
      }

      $astrom(This).cal.catalog.fra_1.ent xview end
   }

   #------------------------------------------------------------
   #  brief sélection du répertoire
   #
   proc getdirname { } {
      variable astrom
      global audace caption conf

      set dirname [tk_chooseDirectory -title "$caption(astrometry,cal,catfolder)" \
         -initialdir $audace(rep_userCatalog) -parent $astrom(This)]
      set len [ string length $dirname ]
      set folder "$dirname"
      if { $len > "0" } {
         set car [ string index "$dirname" [ expr $len-1 ] ]
         if { $car != "/" } {
            append folder "/"
         }
         set dirname $folder
      }
      if { $dirname == "" } {
         set dirname $conf(astrometry,catfolder)
      }
      return $dirname
   }

   #------------------------------------------------------------
   ## @brief calibration à partir d'une autre image
   #  @param fullfilename définit le nom de l'image
   #
   proc calibrate_from_file { fullfilename } {
      variable astrom
      global audace conf

      set k [::buf::create]
      buf$k extension $conf(extension,defaut)
      buf$k load $fullfilename
      foreach kwd $astrom(kwds) {
         set d [buf$k getkwd $kwd]
         catch {buf$audace(bufNo) delkwd $kwd}
         if {[lindex $d 0]!=""} {
            buf$audace(bufNo) setkwd $d
         }
      }
      set kwds {CMAGR CATASTAR}
      foreach kwd $kwds {
         set d [buf$k getkwd $kwd]
         if {[lindex $d 0]!=""} {
            buf$audace(bufNo) setkwd $d
         }
      }
      ::buf::delete $k
   }

   #------------------------------------------------------------
   ## @brief mise en forme d'une désignation MPC
   #  @details la désignation '2000EL118' devient 'K00EB8L'
   #  @param designation désignation MPC
   #  @param format définit le format
   #  @return désignation formatée
   #
   proc mpc_provisional2packed { designation { format old } } {
      #               1222345   122233335
      # 2000EL118 <=> K00EB8L   K00E0118L
      #--- On met en majuscules
      set designation [string toupper $designation]
      #--- On supprime les espaces
      regsub -all " " $designation "" a
      #--- Verifie la longueur de la chaine
      set len [string length $a]
      if {$len<6} {
         return ""
      }
      #--- Decode le siecle
      set yy [string range $a 0 1]
      set a1 [format %c [expr 65+$yy-10]]
      #--- Decode l'annee et la premiere lettre
      set a2 [string range $a 2 4]
      #--- Decode l'annee et la seconde lettre
      set a5 [string range $a 5 5]
      #--- Decode le nombre
      set numorder [string range $a 6 end]
      if {$numorder==""} {
         set a3 0
         set a4 0
      } else {
         set len [string length $numorder]
         if {$format=="old"} {
            if {$len==1} {
               set a3 0
               set a4 [string index $numorder 0]
            } elseif {$len==2} {
               set a3 [string index $numorder 0]
               set a4 [string index $numorder 1]
            } else {
               set yy [string range $numorder 0 1]
               set a3 [format %c [expr 65+$yy-10]]
               set a4 [string index $numorder 2]
            }
         } else {
            set a3 [format %04d $numorder]
            set a4 ""
         }
      }
      #--- Chaine finale
      set designation "${a1}${a2}${a3}${a4}${a5}"
      return $designation
   }

   #------------------------------------------------------------
   ## @brief mise en forme d'une désignation MPC
   #  @details la désignation 'K00EB8L' devient '2000EL118'
   #  @param designation désignation MPC
   #  @param format définit le format
   #  @return désignation formatée
   #
   proc mpc_packed2provisional { designation { format old } } {
      #               1222345   122233335
      # 2000EL118 <=> K00EB8L   K00E0118L
      #--- On supprime les espaces
      regsub -all " " $designation "" a
      #--- Verifie la longueur de la chaine
      set len [string length $a]
      if {$len<7} {
         return ""
      }
      #--- Table de conversion
      set table ""
      for {set k 1} {$k<=26} {incr k} {
         lappend table [format %c [expr 64+$k]]
      }
      #--- Decode le siecle
      set yy [string range $a 0 0]
      set a1 [expr 10+[lsearch $table $yy]]
      #--- Decode l'annee et la premiere lettre
      set a2 [string range $a 1 3]
      #--- Decode la lettre et le nombre
      if {$format=="old"} {
         #--- Decode l'annee et la seconde lettre
         set a5 [string range $a 6 6]
         #--- Decode le nombre
         set numorder [string range $a 4 4]
         set a3 [expr 10+[lsearch $table $numorder]]
         if {$a3==9} {
            set a3 [expr $numorder]
         }
         if {$a3==0} {
            set a3 ""
         }
         set numorder [string range $a 5 5]
            set a4 [expr $numorder]
         if {$a4==0} {
            if {$a3==""} {
               set a4 ""
            } else {
               set a4 "0"
            }
         }
      } else {
         #--- Decode l'annee et la seconde lettre
         set a5 [string range $a 8 8]
         #--- Decode le nombre
         set a3 [string trimleft [string range $a 4 7] 0]
         set a4 ""
      }
      #--- Chaine finale
      set designation "${a1}${a2}${a5}${a3}${a4}"
      return $designation
   }

   #------------------------------------------------------------
   #  brief crée un canvas scrollable, ainsi que les deux scrollbars pour le déplacer
   #
   #  Ref : Brent Welsh, Practical Programming in TCL/TK, rev.2, page 392
   #
   proc Astrom_Scrolled_Canvas { c args } {
      frame $c
      eval {canvas $c.canvas \
         -xscrollcommand [list $c.xscroll set] \
         -yscrollcommand [list $c.yscroll set] \
         -highlightthickness 0 \
         -borderwidth 0} $args
      scrollbar $c.xscroll -orient horizontal -command [list $c.canvas xview]
      scrollbar $c.yscroll -orient vertical -command [list $c.canvas yview]
      grid $c.canvas $c.yscroll -sticky news
      grid $c.xscroll -sticky ew
      grid rowconfigure $c 0 -weight 1
      grid columnconfigure $c 0 -weight 1
      return $c.canvas
   }

   #------------------------------------------------------------
   #  brief affichage de la fenêtre de contrôle avec l'image jpg
   #
   proc visu_result { } {
      variable astrom
      global caption

      #--- Nom de la fenetre
      set astrom(This_check) "$astrom(This).check_astro"

      #--- Remplacement de "$audace(rep_images)" par "." dans "mypath" - Cela permet a
      #--- Sextractor de ne pas etre sensible aux noms de repertoire contenant des
      #--- espaces et ayant une longueur superieure a 70 caracteres
      set mypath "."

      #--- Initialisation du fichier image du controle de la calibration
      set sky "dummy"

      #--- Je cree le buffer qui va etre associe a la visu
      set astrom(bufNo) [ ::buf::create ]

      #--- Je cree la photo qui va etre associee a la visu
      image create photo imagevisu1000

      #--- Je cree la visu qui va etre associee au buffer et a l'image
      set astrom(visuNo) [ ::visu::create $astrom(bufNo) 1000 ]

      #--- Je charge l'image dans le buffer
      buf$astrom(bufNo) load [ file join $mypath ${sky}b.jpg ]

      #--- Je calcule ses dimensions
      set largeur [ buf$astrom(bufNo) getpixelswidth ]
      set hauteur [ buf$astrom(bufNo) getpixelsheight ]

      #--- Je ferme la fenetre si elle existe deja
      if [ winfo exists $astrom(This_check) ] {
         destroy $astrom(This_check)
      }

      #--- Fenetre de visualisation en fonction de la dimension de l'image
      if { $largeur < "390" || $hauteur < "260" } {
         toplevel $astrom(This_check) -borderwidth 1 -width $largeur -height $hauteur -relief sunken
         wm geometry $astrom(This_check) +20+20
      } else {
         toplevel $astrom(This_check) -borderwidth 1 -relief sunken
         wm geometry $astrom(This_check) 640x480+20+20
      }
      wm resizable $astrom(This_check) 1 1
      wm title $astrom(This_check) "$caption(astrometry,start,10)"
      wm protocol $astrom(This_check) WM_DELETE_WINDOW "::astrometry::closeJpeg"

      #--- Affichage du commentaire
      message $astrom(This_check).legende -text "$caption(astrometry,comment)" -justify center \
         -width [ expr 0.9 * $largeur ]
      pack $astrom(This_check).legende -in $astrom(This_check) -side top -anchor center -fill both -padx 10 -pady 10

      #--- Cree le canevas pour l'affichage de l'image
      ::astrometry::Astrom_Scrolled_Canvas $astrom(This_check).result -borderwidth 0 -relief flat \
         -width $largeur -height $hauteur -scrollregion {0 0 0 0} -cursor crosshair
      $astrom(This_check).result.canvas configure -borderwidth 0
      $astrom(This_check).result.canvas configure -relief flat
      pack $astrom(This_check).result \
         -in $astrom(This_check) -expand 1 -side left -anchor center -fill both -padx 0 -pady 0

      #--- Affichage de l'image dans le canvas
      $astrom(This_check).result.canvas create image 0 0 -anchor nw -tag display
      $astrom(This_check).result.canvas itemconfigure display -image imagevisu1000
      $astrom(This_check).result.canvas configure -scrollregion [list 0 0 $largeur $hauteur ]
      visu$astrom(visuNo) cut { 255 0 255 0 255 0 }
      visu$astrom(visuNo) disp

      #--- Focus
      focus $astrom(This_check)

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $astrom(This_check) <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $astrom(This_check)
   }

   #------------------------------------------------------------
   #  brief destruction de la fenêtre de contrôle avec l'image jpg
   #
   proc closeJpeg { } {
      variable astrom

      #--- Supprime les fichiers temporaires
      if { $astrom(delete_files) == "1" } {
         ::astrometry::delete_lst
      }
      #--- Supprime les images temporaires
      if { $astrom(delete_images) == "1" } {
         ::astrometry::delete_dummy
      }
      #--- Verifie si la variable existe
      if { ! [ info exists astrom(This_check) ] } {
         return
      }
      #--- Verifie si la fenetre existe
      if { ! [ winfo exist $astrom(This_check) ] } {
         return
      }
      #--- Supprime la visu
      visu::delete $astrom(visuNo)
      #--- Supprime la photo
      image delete imagevisu1000
      #--- Supprime le buffer
      buf::delete $astrom(bufNo)
      #--- Detruit la fenetre
      destroy $astrom(This_check)
   }

   #------------------------------------------------------------
   #  brief commande associée au checkbutton "Suppression des fichiers temporaires"
   #  param tmp_dir répertoire des fichiers temporaires
   #
   proc delete_lst { {tmp_dir .} } {
      if {$tmp_dir=="."} {
         set tmp_dir [pwd]
      }
      #--- Suppression des fichiers temporaires
      if { [ file exists [ file join $tmp_dir ascii.txt ] ] } {
         file delete [ file join $tmp_dir ascii.txt ]
      }
      if { [ file exists [ file join $tmp_dir catalog.cat ] ] } {
         file delete [ file join $tmp_dir catalog.cat ]
      }
      if { [ file exists [ file join $tmp_dir com.lst ] ] } {
         file delete [ file join $tmp_dir com.lst ]
      }
      if { [ file exists [ file join $tmp_dir dif.lst ] ] } {
         file delete [ file join $tmp_dir dif.lst ]
      }
      if { [ file exists [ file join $tmp_dir eq.lst ] ] } {
         file delete [ file join $tmp_dir eq.lst ]
      }
      if { [ file exists [ file join $tmp_dir matrix.txt ] ] } {
         file delete [ file join $tmp_dir matrix.txt ]
      }
      if { [ file exists [ file join $tmp_dir obs.lst ] ] } {
         file delete [ file join $tmp_dir obs.lst ]
      }
      if { [ file exists [ file join $tmp_dir pointzero.lst ] ] } {
         file delete [ file join $tmp_dir pointzero.lst ]
      }
      if { [ file exists [ file join $tmp_dir usno.lst ] ] } {
         file delete [ file join $tmp_dir usno.lst ]
      }
      if { [ file exists [ file join $tmp_dir signal.sex ] ] } {
         file delete [ file join $tmp_dir signal.sex ]
      }
      if { [ file exists [ file join $tmp_dir xy.lst ] ] } {
         file delete [ file join $tmp_dir xy.lst ]
      }
      if { [ file exists [ file join $tmp_dir file.fit ] ] } {
         file delete [ file join $tmp_dir file.fit ]
      }
   }

   #------------------------------------------------------------
   #  brief commande associée au checkbutton "Suppression des images temporaires"
   #  param tmp_dir répertoire des images temporaires
   #
   proc delete_dummy { {tmp_dir .} } {
      global conf

      #--- Remplacement de "$audace(rep_images)" par "." dans "mypath" - Cela permet a
      #--- Sextractor de ne pas etre sensible aux noms de repertoire contenant des
      #--- espaces et ayant une longueur superieure a 70 caracteres
      if {$tmp_dir=="."} {
         set tmp_dir [pwd]
      }
      set sky "dummy"

      #--- Suppression des images temporaires
      set ext $conf(extension,defaut)
      if { [ file exists [ file join $tmp_dir ${sky}a.jpg ] ] } {
         file delete [ file join $tmp_dir ${sky}a.jpg ]
      }
      if { [ file exists [ file join $tmp_dir ${sky}b.jpg ] ] } {
         file delete [ file join $tmp_dir ${sky}b.jpg ]
      }
      if { [ file exists [ file join $tmp_dir ${sky}$ext ] ] } {
         file delete [ file join $tmp_dir ${sky}$ext ]
      }
      if { [ file exists [ file join $tmp_dir ${sky}0$ext ] ] } {
         file delete [ file join $tmp_dir ${sky}0$ext ]
      }
      if { [ file exists [ file join $tmp_dir c${sky}$ext ] ] } {
         file delete [ file join $tmp_dir c${sky}$ext ]
      }
      if { [ file exists [ file join $tmp_dir x${sky}$ext ] ] } {
         file delete [ file join $tmp_dir x${sky}$ext ]
      }
      if { [ file exists [ file join $tmp_dir z${sky}$ext ] ] } {
         file delete [ file join $tmp_dir z${sky}$ext ]
      }
   }

   #------------------------------------------------------------
   #  brief calibration à partir des étoiles du catalogue USNO
   #
   proc search_cata_USNO { } {
      variable astrom
      global audace caption

      #--- Recuperation de la declinaison du centre du champ
      if { $astrom(currenttypewcs) == "optic" } {
         set astrom(dec_centre_image) $astrom(wcsvalues,DEC)
      } elseif { $astrom(currenttypewcs) == "classic" } {
         set astrom(dec_centre_image) $astrom(wcsvalues,CRVAL2)
      } elseif { $astrom(currenttypewcs) == "matrix" } {
         set astrom(dec_centre_image) $astrom(wcsvalues,CRVAL2)
      }
      #--- Recuperation des donnees et calcul du champ de l'image sur l'axe de declinaison en minutes d'angle
      if { $astrom(currenttypewcs) == "optic" } {
         set nb_pix_y [ expr $astrom(wcsvalues,CRPIX2) * 2 ]
         set pix_dim_y [ expr $astrom(wcsvalues,PIXSIZE2) ]
         set foclen $astrom(wcsvalues,FOCLEN)
         set astrom(champ_image_Dec) [ expr 206265 * $nb_pix_y * $pix_dim_y * 1e-6 / ( $foclen * 60. ) ]
      } elseif { $astrom(currenttypewcs) == "classic" } {
         set scale_y [ expr $astrom(wcsvalues,CDELT2) ]
         set nb_pix_y [ expr $astrom(wcsvalues,CRPIX2) * 2 ]
         set astrom(champ_image_Dec) [ expr abs($scale_y) * $nb_pix_y * 60.0 ]
      } elseif { $astrom(currenttypewcs) == "matrix" } {
         set scale_y $astrom(wcsvalues,CD2_2)
         set naxis2 [ lindex [ buf$audace(bufNo) getkwd NAXIS2 ] 1 ]
         set astrom(champ_image_Dec) [ expr abs($scale_y) * $naxis2 * 60.0 ]
      }
      #--- Initialisation des variables
      set cata_USNO_1      ""
      set nb_CD_USNO_1     ""
      set cata_USNO_2      ""
      set nb_CD_USNO_2     ""
      set cata_USNO_3      ""
      set nb_CD_USNO_3     ""
      #--- Declinaisons inferieure et superieure de l'image
      set dec_inf_image [ expr $astrom(dec_centre_image) - ( $astrom(champ_image_Dec) / ( 60.0 * 2.0 ) ) * 1.1 ]
      set dec_sup_image [ expr $astrom(dec_centre_image) + ( $astrom(champ_image_Dec) / ( 60.0 * 2.0 ) ) * 1.1 ]
      #--- Determination de la reference du ou des catalogues USNO necessaires
      if { $astrom(dec_centre_image) != "" && $astrom(champ_image_Dec) != "" } {
         for { set k 0 } { $k < 24 } { incr k } {
            set borne_inf [ expr -90.0 + ( $k * 7.5 ) ]
            set borne_sup [ expr -90.0 + ( ( $k + 1 ) * 7.5 ) ]
            if { $astrom(dec_centre_image) < "$borne_sup" && $astrom(dec_centre_image) >= "$borne_inf" } {
               if { $dec_sup_image <= "$borne_sup" && $dec_inf_image >= "$borne_inf" } {
                  #--- 1 seul catalogue USNO
                  set cata_USNO_1 "ZONE[ format "%04.0f" [ expr $k * 7.5 *10 ] ]"
                  set nb_CD_USNO_1 [ ::astrometry::search_cd $cata_USNO_1 ]
                  tk_messageBox \
                     -message [ eval [ concat { format } { $caption(astrometry,erreur_USNO) \
                        $cata_USNO_1 $nb_CD_USNO_1 } ] ] \
                     -icon error
               } elseif { $dec_sup_image > "$borne_sup" && $dec_inf_image >= "$borne_inf" } {
                  #--- 1er catalogue USNO
                  set cata_USNO_1 "ZONE[ format "%04.0f" [ expr $k * 7.5 *10 ] ]"
                  set nb_CD_USNO_1 [ ::astrometry::search_cd $cata_USNO_1 ]
                  #--- 2ieme catalogue USNO
                  if { [ expr ( $k + 1 ) ] < "24" } {
                     set cata_USNO_2 "ZONE[ format "%04.0f" [ expr ( $k + 1 ) * 7.5 *10 ] ]"
                     set nb_CD_USNO_2 [ ::astrometry::search_cd $cata_USNO_2 ]
                     tk_messageBox \
                        -message "[ eval [ concat { format } { $caption(astrometry,erreur_USNO_1) \
                           $cata_USNO_1 $nb_CD_USNO_1 $cata_USNO_2 $nb_CD_USNO_2 } ] ] \
                           \n$caption(astrometry,erreur_USNO_2) \n$caption(astrometry,erreur_USNO_3)" \
                        -icon error
                  } else {
                     #--- Sinon il n'y a pas de 2ieme catalogue USNO
                     tk_messageBox \
                        -message [ eval [ concat { format } { $caption(astrometry,erreur_USNO) \
                           $cata_USNO_1 $nb_CD_USNO_1 } ] ] \
                        -icon error
                  }
               } elseif { $dec_sup_image <= "$borne_sup" && $dec_inf_image < "$borne_inf" } {
                  #--- 1er catalogue USNO
                  set cata_USNO_2 "ZONE[ format "%04.0f" [ expr $k * 7.5 *10 ] ]"
                  set nb_CD_USNO_2 [ ::astrometry::search_cd $cata_USNO_2 ]
                  #--- 2ieme catalogue USNO
                  if { [ expr ( $k - 1 ) ] >= "0" } {
                     set cata_USNO_1 "ZONE[ format "%04.0f" [ expr ( $k - 1 ) * 7.5 *10 ] ]"
                     set nb_CD_USNO_1 [ ::astrometry::search_cd $cata_USNO_1 ]
                     tk_messageBox \
                        -message "[ eval [ concat { format } { $caption(astrometry,erreur_USNO_1) \
                           $cata_USNO_1 $nb_CD_USNO_1 $cata_USNO_2 $nb_CD_USNO_2 } ] ] \
                           \n$caption(astrometry,erreur_USNO_2) \n$caption(astrometry,erreur_USNO_3)" \
                       -icon error
                  } else {
                     #--- Sinon il n'y a pas de 2ieme catalogue USNO
                     tk_messageBox \
                        -message [ eval [ concat { format } { $caption(astrometry,erreur_USNO) \
                           $cata_USNO_2 $nb_CD_USNO_2 } ] ] \
                        -icon error
                  }
               } elseif { $dec_sup_image > "$borne_sup" && $dec_inf_image < "$borne_inf" } {
                  set flag(nbre_cata) "0"
                  #--- 1er catalogue USNO
                  if { [ expr ( $k - 1 ) ] >= "0" } {
                     set cata_USNO_1 "ZONE[ format "%04.0f" [ expr ( $k - 1 ) * 7.5 *10 ] ]"
                     set nb_CD_USNO_1 [ ::astrometry::search_cd $cata_USNO_1 ]
                  } else {
                     #--- Sinon il n'y a pas de 1er catalogue USNO
                     set flag(nbre_cata) "1"
                  }
                  #--- 2ieme catalogue USNO
                  set cata_USNO_2 "ZONE[ format "%04.0f" [ expr $k * 7.5 *10 ] ]"
                  set nb_CD_USNO_2 [ ::astrometry::search_cd $cata_USNO_2 ]
                  #--- 3ieme catalogue USNO
                  if { [ expr ( $k + 1 ) ] < "24" } {
                     set cata_USNO_3 "ZONE[ format "%04.0f" [ expr ( $k + 1 ) * 7.5 *10 ] ]"
                     set nb_CD_USNO_3 [ ::astrometry::search_cd $cata_USNO_3 ]
                  } else {
                     #--- Sinon il n'y a pas de 3ieme catalogue USNO
                     set flag(nbre_cata) "2"
                  }
                  if { $flag(nbre_cata) == "0" } {
                    tk_messageBox \
                       -message "[ eval [ concat { format } { $caption(astrometry,erreur_USNO_4) \
                          $cata_USNO_1 $nb_CD_USNO_1 $cata_USNO_2 $nb_CD_USNO_2 $cata_USNO_3 $nb_CD_USNO_3 } ] ] \
                          \n$caption(astrometry,erreur_USNO_2) \n$caption(astrometry,erreur_USNO_3)" \
                       -icon error
                  } elseif { $flag(nbre_cata) == "1" } {
                     tk_messageBox \
                        -message "[ eval [ concat { format } { $caption(astrometry,erreur_USNO_1) \
                           $cata_USNO_2 $nb_CD_USNO_2 $cata_USNO_3 $nb_CD_USNO_3 } ] ] \
                           \n$caption(astrometry,erreur_USNO_2) \n$caption(astrometry,erreur_USNO_3)" \
                       -icon error
                  } elseif { $flag(nbre_cata) == "2" } {
                     tk_messageBox \
                        -message "[ eval [ concat { format } { $caption(astrometry,erreur_USNO_1) \
                           $cata_USNO_1 $nb_CD_USNO_1 $cata_USNO_2 $nb_CD_USNO_2 } ] ] \
                           \n$caption(astrometry,erreur_USNO_2) \n$caption(astrometry,erreur_USNO_3)" \
                       -icon error
                  }
               }
            }
         }
      } else {
         return
      }
   }

   #------------------------------------------------------------
   #  brief recherche le catalogue USNO à utiliser
   #
   proc search_cd { cata_USNO } {
      switch -exact -- $cata_USNO {
         ZONE0000 { return "1" }
         ZONE0075 { return "1" }
         ZONE0150 { return "9" }
         ZONE0225 { return "7" }
         ZONE0300 { return "5" }
         ZONE0375 { return "4" }
         ZONE0450 { return "3" }
         ZONE0525 { return "2" }
         ZONE0600 { return "1" }
         ZONE0675 { return "6" }
         ZONE0750 { return "7" }
         ZONE0825 { return "10" }
         ZONE0900 { return "9" }
         ZONE0975 { return "8" }
         ZONE1050 { return "8" }
         ZONE1125 { return "11" }
         ZONE1200 { return "10" }
         ZONE1275 { return "11" }
         ZONE1350 { return "6" }
         ZONE1425 { return "4" }
         ZONE1500 { return "2" }
         ZONE1575 { return "3" }
         ZONE1650 { return "3" }
         ZONE1725 { return "2" }
      }
   }

}

