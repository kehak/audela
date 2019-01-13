#
## @file eye.funcs.display.tcl
#  @brief Pilotage d'un chercheur électronique asservissant une monture
#  @author Frederic Vachier
#  $Id: eye.funcs.display.tcl 14079 2016-10-19 16:19:58Z fredvachier $
#

   #------------------------------------------------------------
   ## Efface les repères des étoiles
   #
   proc ::eye::deleteStar { } {

      cleanmark
      efface_carre
      $::eye::hCanvas delete eyestar
      ::eye::cleanmark_simu
      ::eye::cleanmark_visu
   }

   #------------------------------------------------------------
   ## Efface les repères des étoiles calibrées
   #
   proc ::eye::delete_calib_star_obsolete { } {

      global private

      $::eye::hCanvas delete eye_calib_star
   }



   #------------------------------------------------------------
   ## Effacement des marques dans la visu de la simulation
   #
   proc ::eye::cleanmark_simu { } {

      # on decoche les bouton
      set ::eye::widget(marque,centerimg) 0
      set ::eye::widget(marque,celeste) 0
      
      catch {$::eye::fov_view_frame_button.but_centi configure -relief "raised"}
      catch {$::eye::fov_view_frame_button.but_centc configure -relief "raised"}
       
      
      # On efface les point particuliers
      catch {$::eye::fov_canvas delete cible_I }
      catch {$::eye::fov_canvas delete cible_M }
      catch {$::eye::fov_canvas delete cible_C }

      # On efface les etoiles de reference
      if {[info exists ::eye::list_star]} {
         foreach star $::eye::list_star {
            catch {$::eye::fov_canvas delete cible_$star }
         }
      }
   }

   proc ::eye::cleanmark_visu { } {

      # On efface les point particuliers
      catch {$::eye::hCanvas delete cible_I }
      catch {$::eye::hCanvas delete cible_M }
      catch {$::eye::hCanvas delete origine }
      catch {$::eye::hCanvas delete destination }
      catch {$::eye::hCanvas delete cible_J2000 }
      catch {$::eye::hCanvas delete cible_C }

      # On efface les etoiles de reference
      if {[info exists ::eye::list_star]} {
         foreach star $::eye::list_star {
            catch {$::eye::hCanvas delete cible_$star }
            catch {$::eye::hCanvas delete centre_$star }
            catch {$::eye::hCanvas delete mediatrice_$star }
            catch {$::eye::hCanvas delete arc_$star }

         }
      }


   }
   proc ::eye::cleanmark_force { } {
      catch {$::eye::fov_canvas delete cible_I }
      catch {$::eye::hCanvas delete cible_I }
      for {set i 1} {$i <=100} {incr i} {
         catch {$::eye::hCanvas delete cible_$star }
         catch {$::eye::fov_canvas delete cible_$star }
      }
   }

   #------------------------------------------------------------
   ## Affiche le résultat de la calibration astrométrique
   #
   proc ::eye::affiche_calibration { } {

      $::eye::hCanvas delete eyestar

      set listsources [get_ascii_txt]
      if {$listsources == -1} {
         set imageStarNb   0
         set matchedStarNb 0
      } else {
         gren_info "rollup : [::manage_source::get_nb_sources_rollup $listsources]\n"
         #affich_rond $listsources "USNOA2CALIB" "magenta" 1
         set imageStarNb   [::manage_source::get_nb_sources_by_cata $listsources "IMG"]
         set matchedStarNb [::manage_source::get_nb_sources_by_cata $listsources "USNOA2CALIB"]
      }


      set catalogueStarNb [::eye::get_catalogueStarNb]

      gren_info "nbstars = $imageStarNb | $catalogueStarNb | $matchedStarNb\n"

      set ::eye::widget(new,imageStarNb)     $imageStarNb
      set ::eye::widget(new,catalogueStarNb) $catalogueStarNb
      set ::eye::widget(new,matchedStarNb)   $matchedStarNb
      update

      ::eye::displayStars $imageStarNb $catalogueStarNb $matchedStarNb
   }

   #------------------------------------------------------------
   ## Affiche les etoiles
   # @pre si les données ne sont pas obtenues, l'affichage n'est pas modifié
   # @param imageStarNb
   # @param catalogueStarNb
   # @param matchedStarNb
   # @return void
   #
   proc ::eye::displayStars { imageStarNb catalogueStarNb matchedStarNb } {

      $::eye::hCanvas delete eyestar

      #--- j'affiche des cercles bleus autour des étoiles de l'image
      if { $imageStarNb > 1000 } {
         # j'ouvre le fichier des étoiles de l'image (obs.lst)
         set fcom [open "obs.lst" r]
         # j'affiche les etoiles de l'image
         while {-1 != [gets $fcom line1]} {
            set xpic   [expr [lindex $line1 0] + 1]
            set ypic   [expr [lindex $line1 1] + 1]

            #--- je convertis en coordonnes canvas
            set coord [::confVisu::picture2Canvas $::eye::visuNo [list $xpic $ypic ]]
            set xcan  [lindex $coord 0]
            set ycan  [lindex $coord 1]

            #--- je dessine des cercles autour des etoiles
            set radius 7
            $::eye::hCanvas create oval [expr $xcan-$radius] [expr $ycan-$radius] \
                                 [expr $xcan+$radius] [expr $ycan+$radius] \
                                 -fill {} -outline blue -width 2 -activewidth 3 \
                                 -tag "eyestar $xpic $ypic"
         }
         # je ferme le fichier de coordonnees
         close $fcom
         buf$::eye::bufNo setkwd [list "NBSTARS" $imageStarNb int "nb stars in picture" "" ]
      }

       #--- j'affiche des cercles verts autour des étoiles du catalogue
       if { 1 == 1 } {
       if { $catalogueStarNb > 0 } {
         # j'ouvre le fichier des étoiles du catalogue (usno.lst)
         set fcom [open "usno.lst" r]
         set catalogueStarNb 0
         while {-1 != [gets $fcom line1]} {
            # je decoupe la ligne en une liste de champs
            ###set line2 [split [regsub -all {[ \t\n]+} $line1 { }]]

            set xpic   [expr [lindex $line1 1] + 1]
            set ypic   [expr [lindex $line1 2] + 1]

            #--- je convertis en coordonnes canvas
            set coord [::confVisu::picture2Canvas $::eye::visuNo [list $xpic $ypic ]]
            set xima  [lindex $coord 0]
            set yima  [lindex $coord 1]

            #--- je dessine des cercles autour des etoiles
            set radius 7
            $::eye::hCanvas create oval [expr $xima-$radius] [expr $yima-$radius] \
                                 [expr $xima+$radius] [expr $yima+$radius] \
                                 -fill {} -outline blue -width 3 -activewidth 4 \
                                 -tag "eyestar $xpic $ypic "
            incr catalogueStarNb
         }
         # je ferme le fichier de coordonnees
         close $fcom
         buf$::eye::bufNo setkwd [list "NBCATASTARS" $catalogueStarNb int "nb stars in catalogue" "" ]
      }
      }

      #--- je trace des traits rouges entre les étoiles appreillées
      if { $matchedStarNb > 0 } {
         # j'ouvre le fichier resultat des étoiles appareillées
         set fcom [open "com.lst" r]
         set matchedStarNb 0
         # colonnes de com.lst
         #   x1/1 y1/1 mag1/1 x2/2 y2/2 mag2/2 mag1-2 qualite1 qualite2
         #     qualite=1= ok  , qualite=-1 =sature
         while {-1 != [gets $fcom line1]} {
            #--- je convertis en coordonnes picture
            set ximapic   [expr [lindex $line1 0] + 1]
            set yimapic   [expr [lindex $line1 1] + 1]
            set xobspic   [expr [lindex $line1 3] + 1]
            set yobspic   [expr [lindex $line1 4] + 1]
            set mag       [format "%.1f" [lindex $line1 5] ]

            set coord [::confVisu::picture2Canvas $::eye::visuNo [list $ximapic $yimapic ]]
            set ximacan  [lindex $coord 0]
            set yimacan  [lindex $coord 1]
            set coord [::confVisu::picture2Canvas $::eye::visuNo [list $xobspic $yobspic ]]
            set xobscan  [lindex $coord 0]
            set yobscan  [lindex $coord 1]

            ###$::eye::hCanvas create oval [expr $ximacan-5] [expr $yimacan-5] [expr $ximacan+5] [expr $yimacan+5] -fill {} -outline yellow -width 2 -activewidth 3 -tag "eyestar $ximapic $yimapic"
            ###::eye::hCanvas create oval [expr $xobscan-5] [expr $yobscan-5] [expr $xobscan+5] [expr $yobscan+5] -fill {} -outline yellow -width 2 -activewidth 3 -tag "eyestar $xobspic $yobspic"
#            $::eye::hCanvas create line $ximacan $yimacan $xobscan $yobscan \
#                                -fill red -width 2 -activewidth 3 \
#                                -tag "eyestar $ximapic $yimapic $xobspic $yobspic"
            set radius 7
            $::eye::hCanvas create oval [expr $xobscan-$radius] [expr $yobscan-$radius] \
                                 [expr $xobscan+$radius] [expr $yobscan+$radius] \
                                 -fill {} -outline magenta -width 1 -activewidth 3 \
                                 -tag "eyestar $ximapic $yimapic"
            $::eye::hCanvas create text [expr $xobscan+15] [expr $yobscan+15] \
                                   -text "$mag" -fill yellow -state normal -tag eyestar
            incr matchedStarNb
         }
         close $fcom
         buf$::eye::bufNo setkwd [list "CATASTARS" $matchedStarNb int "nb matched stars" "" ]
      }

      #--- j'affiche les coordonnees de l'objet cible
      set objname [lindex [buf$::eye::bufNo getkwd "OBJECT"] 1]
      set ra  [mc_angle2deg [lindex [buf$::eye::bufNo getkwd "RA"]  1]]
      set dec [mc_angle2deg [lindex [buf$::eye::bufNo getkwd "DEC"] 1]]
      set xy  [buf$::eye::bufNo radec2xy [list $ra $dec] 1]
      set xpic   [lindex $xy 0]
      set ypic   [lindex $xy 1]

      set coord [::confVisu::picture2Canvas $::eye::visuNo [list $xpic $ypic ]]
      set x   [lindex $coord 0]
      set y   [lindex $coord 1]

      #--- je dessine le cercle autour de l'etoile cible
      set radius 7
      $::eye::hCanvas create oval [expr $x-$radius] [expr $y-$radius] \
                           [expr $x+$radius] [expr $y+$radius] \
                           -fill {} -outline red -width 2 \
                           -activewidth 3 -tag "eyestar $xpic $ypic"
      #--- j'affiche ses coordonnees
      #set rahms   [mc_angle2hms $ra 360 zero 1 auto string ]
      #set decdms  [mc_angle2dms $dec 90 zero 0 + string ]
      #$::eye::hCanvas create text [expr $x-12] [expr $y+20] -text "$objname\n$rahms\n$decdms" -fill yellow -state normal -tag "eyestar $xpic $ypic"
      return
   }



   #------------------------------------------------------------
   ## onChangeDisplay
   # @pre si les donnees ne sont pas obtenues, l'affichage n'est pas modifie
   # @param args : valeurs fournies par le gestionnaire de listener
   #
   proc ::eye::onChangeDisplay { args } {

      if { [info command visu$::eye::visuNo] == ""} {
         #--- si la visu n'existe plus, je supprime le listener
         ::confVisu::removeMirrorListener $::eye::visuNo "::eye::onChangeDisplay"
         ::confVisu::removeSubWindowListener $::eye::visuNo "::eye::onChangeDisplay"
         ::confVisu::removeZoomListener $::eye::visuNo "::eye::onChangeDisplay"
         return
      }

      foreach itemId [$::eye::hCanvas find withtag "eyestar"] {
         switch [$::eye::hCanvas type $itemId] {
            "oval" {
               set tagValue [$::eye::hCanvas itemcget $itemId -tag]
               set xpic [lindex $tagValue 1]
               set ypic [lindex $tagValue 2]
               #--- je convertis en coordonnes canvas
               set coord [::confVisu::picture2Canvas $::eye::visuNo [list $xpic $ypic ]]
               set xcan  [lindex $coord 0]
               set ycan  [lindex $coord 1]
               #--- je dessine des cercles autour des etoiles
               set oldCoord [$::eye::hCanvas coords $itemId]
               set radius [expr ([lindex $oldCoord 2] - [lindex $oldCoord 0])/2]
               $::eye::hCanvas coords $itemId [expr $xcan-$radius] [expr $ycan-$radius] [expr $xcan+$radius] [expr $ycan+$radius]
            }
            "line" {
               set tagValue [$::eye::hCanvas itemcget $itemId -tag]
               set ximapic [lindex $tagValue 1]
               set yimapic [lindex $tagValue 2]
               set xobspic [lindex $tagValue 3]
               set yobspic [lindex $tagValue 4]
               #--- je convertis en coordonnes canvas
               set coord [::confVisu::picture2Canvas $::eye::visuNo [list $ximapic $yimapic ]]
               set ximacan  [lindex $coord 0]
               set yimacan  [lindex $coord 1]
               set coord [::confVisu::picture2Canvas $::eye::visuNo [list $xobspic $yobspic ]]
               set xobscan  [lindex $coord 0]
               set yobscan  [lindex $coord 1]
               #--- je change les coordonnees de la ligne
               $::eye::hCanvas coords $itemId $ximacan $yimacan $xobscan $yobscan
            }
            "text" {
               set tagValue [$::eye::hCanvas itemcget $itemId -tag]
               set xpic [lindex $tagValue 1]
               set ypic [lindex $tagValue 2]
               #--- je convertis en coordonnes canvas
               set coord [::confVisu::picture2Canvas $::eye::visuNo [list $xpic $ypic ]]
               set xcan  [lindex $coord 0]
               set ycan  [lindex $coord 1]
               #--- je dessine des cercles autour des etoiles
               $::eye::hCanvas coords $itemId [expr $xcan+12] [expr $ycan+24]
            }
         }
      }

   }



   #------------------------------------------------------------
   ## Affichage du réticule montrant la position de la camera installée au foyer du telescope
   # @param     x1    : position x du coin inferieur droit
   # @param     y1    : position y du coin inferieur droit
   # @param     x2    : position x du coin superieur gauche
   # @param     y2    : position y du coin superieur gauche
   # @param     xmax  : taille x du fov
   # @param     ymax  : taille y du fov
   # @param     color : couleur du reticule
   # @warning
   # @return 0
   #
   proc affich_un_reticule_carre_xy { x1 y1 x2 y2 xmax ymax color } {

      set can1_xy [ ::audace::picture2Canvas [list $x1 $y1] ]
      set can2_xy [ ::audace::picture2Canvas [list $x2 $y2] ]

      set x1 [lindex $can1_xy 0]
      set y1 [lindex $can1_xy 1]
      set x2 [lindex $can2_xy 0]
      set y2 [lindex $can2_xy 1]

      $::eye::hCanvas create line $x1 $y1 $x2 $y1 -fill "$color" -tags reticule -width 1.0
      $::eye::hCanvas create line $x2 $y1 $x2 $y2 -fill "$color" -tags reticule -width 1.0
      $::eye::hCanvas create line $x2 $y2 $x1 $y2 -fill "$color" -tags reticule -width 1.0
      $::eye::hCanvas create line $x1 $y2 $x1 $y1 -fill "$color" -tags reticule -width 1.0

      set xm [expr int(($x1+$x2)/2.0)]
      set ym [expr int(($y1+$y2)/2.0)]

      set can0_xy [ ::audace::picture2Canvas [list 0 0] ]
      set x0 [lindex $can0_xy 0]
      set y0 [lindex $can0_xy 1]
      set can3_xy [ ::audace::picture2Canvas [list $xmax $ymax] ]
      set x3 [lindex $can3_xy 0]
      set y3 [lindex $can3_xy 1]


      $::eye::hCanvas create line $x0 $ym $x1 $ym -fill "$color" -tags reticule -width 1.0
      $::eye::hCanvas create line $x2 $ym $x3 $ym -fill "$color" -tags reticule -width 1.0
      $::eye::hCanvas create line $xm $y0 $xm $y1 -fill "$color" -tags reticule -width 1.0
      $::eye::hCanvas create line $xm $y2 $xm $y3 -fill "$color" -tags reticule -width 1.0

      return 0
   }



   #------------------------------------------------------------
   ##  @brief displayWcs
   #   @details affiche les mots clés
   #   @param args liste d'arguments
   #
   proc ::eye::displayWcs { args } {

      set frm $::eye::frmbase

#      $frm.onglets.nb.f_meth.frmtable.nbstars.name_new_imageStarNb     configure -fg blue
#      $frm.onglets.nb.f_meth.frmtable.nbstars.new_imageStarNb          configure -fg blue
#      $frm.onglets.nb.f_meth.frmtable.nbstars.name_new_catalogueStarNb configure -fg green

#      $frm.onglets.nb.f_meth.frmtable.nbstars.new_catalogueStarNb    configure -fg green
#      $frm.onglets.nb.f_meth.frmtable.nbstars.name_new_matchedStarNb configure -fg red
#      $frm.onglets.nb.f_meth.frmtable.nbstars.new_matchedStarNb      configure -fg red

      if { [buf$::eye::bufNo imageready ] == 1 } {
         set private($::eye::visuNo,object)   [lindex [buf$::eye::bufNo getkwd "OBJECT"  ] 1]
         set private($::eye::visuNo,ra) [mc_angle2hms [lindex [buf$::eye::bufNo getkwd "RA"] 1] 360 nozero 1 auto string ]
         if { $private($::eye::visuNo,ra) == "" } {
            set private($::eye::visuNo,ra) [mc_angle2hms $private($::eye::visuNo,ra) 360 nozero 1 auto string ]
         }

         set private($::eye::visuNo,dec) [mc_angle2dms [lindex [buf$::eye::bufNo getkwd "DEC"] 1] 90 nozero 0 + string]
         if { $private($::eye::visuNo,dec) == "" } {
            set private($::eye::visuNo,dec) [mc_angle2dms $private($::eye::visuNo,dec)  90 nozero 0 + string]
         }
         set private($::eye::visuNo,equinox)  [lindex [buf$::eye::bufNo getkwd "EQUINOX"  ] 1]
         if { $private($::eye::visuNo,equinox) == "" } {
            set private($::eye::visuNo,equinox) "now"
         }

         set private($::eye::visuNo,dateObs)  [lindex [buf$::eye::bufNo getkwd "DATE-OBS"  ] 1]

         #--- je calcule les coordonnees J2000
         if { $private($::eye::visuNo,ra) != "" && $private($::eye::visuNo,dec) != "" && $private($::eye::visuNo,dateObs) != "" } {
            if { $private($::eye::visuNo,equinox) != 2000 } {
               set radec [list $private($::eye::visuNo,ra) $private($::eye::visuNo,dec) ]
               ####--- Position de l'observateur
               ###set gpsPosition $::audace(posobs,observateur,gps)
               ####--- Aberration de l'aberration diurne
               ####set radec [mc_aberrationradec diurnal [list $ra $dec] $date $gpsPosition -reverse]
               #--- Correction de nutation
               set radec [mc_nutationradec $radec $private($::eye::visuNo,dateObs) -reverse]
               #--- Correction de precession
               set radec [mc_precessradec $radec $private($::eye::visuNo,dateObs) "J2000" ]
               #--- Aberration annuelle
               set radec [mc_aberrationradec annual $radec $private($::eye::visuNo,dateObs) -reverse]
               set private($::eye::visuNo,new,raJ2000) [mc_angle2hms [lindex $radec 0] 360 nozero 1 auto string ]
               set private($::eye::visuNo,new,decJ2000) [mc_angle2dms [lindex $radec 1] 90 nozero 0 + string]
            } else {
               set private($::eye::visuNo,new,raJ2000)  $private($::eye::visuNo,ra)
               set private($::eye::visuNo,new,decJ2000) $private($::eye::visuNo,dec)
            }
         } else {
            set private($::eye::visuNo,new,raJ2000) ""
            set private($::eye::visuNo,new,decJ2000) ""
         }

         set private($::eye::visuNo,pixsize1) [lindex [buf$::eye::bufNo getkwd "PIXSIZE1"] 1]
         if { $private($::eye::visuNo,pixsize1) == "" } {
            set private($::eye::visuNo,pixsize1) [lindex [buf$::eye::bufNo getkwd "XPIXSZ"] 1]
         }
         set private($::eye::visuNo,pixsize2) [lindex [buf$::eye::bufNo getkwd "PIXSIZE2"] 1]
         if { $private($::eye::visuNo,pixsize2) == "" } {
            set private($::eye::visuNo,pixsize2) [lindex [buf$::eye::bufNo getkwd "YPIXSZ"] 1]
         }
         set private($::eye::visuNo,crpix1)   [lindex [buf$::eye::bufNo getkwd "CRPIX1"  ] 1]
         if { $private($::eye::visuNo,crpix1) == "" } {
            set private($::eye::visuNo,crpix1) [expr int([buf$::eye::bufNo getpixelswidth] / 2) ]
         }
         set private($::eye::visuNo,crpix2)   [lindex [buf$::eye::bufNo getkwd "CRPIX2"  ] 1]
         if { $private($::eye::visuNo,crpix2) == "" } {
            set private($::eye::visuNo,crpix2) [expr int([buf$::eye::bufNo getpixelsheight] / 2) ]
         }

         set private($::eye::visuNo,crval1) [lindex [buf$::eye::bufNo getkwd "CRVAL1"] 1]
         set private($::eye::visuNo,crval2) [lindex [buf$::eye::bufNo getkwd "CRVAL2"] 1]
         if { $private($::eye::visuNo,crval1) == "" || $private($::eye::visuNo,crval2) == "" } {
            if { $private($::eye::visuNo,new,raJ2000) != ""  && $private($::eye::visuNo,new,decJ2000) != "" } {
               set private($::eye::visuNo,crval1) $private($::eye::visuNo,new,raJ2000)
               set private($::eye::visuNo,crval2) $private($::eye::visuNo,new,decJ2000)
            } else {
               set private($::eye::visuNo,crval1) ""
               set private($::eye::visuNo,crval2) ""
            }
         } else {
            set private($::eye::visuNo,crval1)   [mc_angle2hms $private($::eye::visuNo,crval1) 360 nozero 1 auto string ]
            set private($::eye::visuNo,crval2)   [mc_angle2dms $private($::eye::visuNo,crval2) 90 nozero 0 + string]
         }
         set private($::eye::visuNo,foclen)   [lindex [buf$::eye::bufNo getkwd "FOCLEN"  ] 1]
         if { $private($::eye::visuNo,foclen) == "" } {
            set private($::eye::visuNo,foclen) 1
         }
         set private($::eye::visuNo,crota2)   [lindex [buf$::eye::bufNo getkwd "CROTA2"  ] 1]
         if { $private($::eye::visuNo,crota2) == "" } {
            set private($::eye::visuNo,crota2) 0
         }
      } else {
         set private($::eye::visuNo,object)   ""
         set private($::eye::visuNo,ra)       ""
         set private($::eye::visuNo,dec)      ""
         set private($::eye::visuNo,equinox)  ""
         set private($::eye::visuNo,pixsize1) ""
         set private($::eye::visuNo,pixsize2) ""
         set private($::eye::visuNo,crpix1)   ""
         set private($::eye::visuNo,crpix2)   ""
         set private($::eye::visuNo,crval1)   ""
         set private($::eye::visuNo,crval2)   ""
         set private($::eye::visuNo,foclen)   ""
         set private($::eye::visuNo,crota2)   ""
      }
      set ::eye::widget(new,imageStarNb)     "0"
      set ::eye::widget(new,catalogueStarNb) "0"
      set ::eye::widget(new,matchedStarNb)   "0"
      set private($::eye::visuNo,new,crval1)   "0"
      set private($::eye::visuNo,new,crval2)   "0"
      set private($::eye::visuNo,new,foclen)   "0"
      set private($::eye::visuNo,new,crota2)   "0"
   }


   #------------------------------------------------------------
   ## @brief affiche une cible à la position radec
   #  @param hcanvas : canvas pour l affichage
   #  @param bufNo   : buffer pour l affichage
   #  @param visuNo  : visu   pour l affichage
   #  @param ra      : coord ra
   #  @param dec     : coord dec
   #  @param color   : couleur de la cible
   #  @param name    : nom a afficher dans l image et pour designer le tag
   #  @return void
   #
   proc ::eye::fov_tools_point_radec { hcanvas bufNo visuNo ra dec color name } {

      set img0_xy [ buf$bufNo radec2xy [list $ra $dec] ]
      if {$name == "C" && $bufNo == $::eye::evt_bufNo} {
         gren_info "Pole Celeste xy = $ra $dec [lindex $img0_xy 0] [lindex $img0_xy 1]\n"
      }
      ::eye::fov_tools_point $hcanvas $visuNo [lindex $img0_xy 0] [lindex $img0_xy 1] $color $name
      return
   }


   #------------------------------------------------------------
   ## @brief affiche une cible à la position x y pixel de l'image
   #  @param hcanvas : canvas pour l'affichage
   #  @param visuNo  : visu   pour l'affichage
   #  @param xpic    : abscisse en pixel de l image
   #  @param ypic    : ordonn&e en pixel de l image
   #  @param color   : couleur de la cible
   #  @param name    : nom à afficher dans l'image et pour désigner le tag
   #  @return void
   #
   proc ::eye::fov_tools_point { hcanvas visuNo xpic ypic color name } {

      set err [catch {set coord [::confVisu::picture2Canvas $visuNo [list $xpic $ypic]]} msg]

      if {![info exists coord]} {
         gren_erreur "ERREUR Not exist : $xpic $ypic :: $err $msg\n"
         return
      }
      if {$err!=0} {
         gren_erreur "ERREUR : $xpic $ypic :: $err $msg\n"
         return
      }
      set x  [lindex $coord 0]
      set y  [lindex $coord 1]

      set tag cible_$name

      catch {$hcanvas delete $tag}
      set w 3
      set r 10
      set t 6
      $hcanvas create oval [expr $x-$r]    [expr $y-$r]    [expr $x+$r]    [expr $y+$r]    -outline $color -tag $tag -width $w
      $hcanvas create line [expr $x-$r-$t] $y              [expr $x-$r+$t] $y              -fill $color    -tag $tag -width $w
      $hcanvas create line [expr $x+$r-$t] $y              [expr $x+$r+$t] $y              -fill $color    -tag $tag -width $w
      $hcanvas create line $x              [expr $y-$r-$t] $x              [expr $y-$r+$t] -fill $color    -tag $tag -width $w
      $hcanvas create line $x              [expr $y+$r-$t] $x              [expr $y+$r+$t] -fill $color    -tag $tag -width $w
      $hcanvas create rectangle [expr $x + 10] [expr $y-17] [expr $x + 30 ] [expr $y-5]    -fill black     -tag $tag
      $hcanvas create text [expr $x + 20 ] [expr $y-10]                                    -fill $color    -tag $tag -text $name

      return
   }

