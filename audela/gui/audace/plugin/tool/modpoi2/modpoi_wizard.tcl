# @file : modpoi_wizard.tcl
# @brief assistant à la mise è jour d'un modele de pointage
# @author : Michel Pujol
# $Id: modpoi_wizard.tcl 13696 2016-04-13 20:28:43Z michelpujol $
#

namespace eval ::modpoi2::wizard {

}

# @brief initialise les variables de l'assistant de modele de pointage
#     
# @private
# @param visuNo
# @param starList  ( amerAz amerEl name raCat deCat equinoxCat date raObs deObs pressure temperature )
# @private
proc ::modpoi2::wizard::modpoi_wiz { visuNo { starList "" } } {
   variable private
   variable hip_catalog

   #--- je supprime les variables de la session precedente
   if { [info exists private] == 1} {
      unset private
   }
   set private(visuNo) $visuNo

   load libgsltcl[info sharedlibextension]

   if { ! [ info exists ::conf(modpoi,wizard,position) ] }           { set ::conf(modpoi,wizard,position)           "+250+75" }
   if { ! [ info exists ::conf(modpoi,wizard,haNb) ] }               { set ::conf(modpoi,wizard,haNb)               "4" }
   if { ! [ info exists ::conf(modpoi,wizard,deNb) ] }               { set ::conf(modpoi,wizard,deNb)               "3" }
   if { ! [ info exists ::conf(modpoi,wizard,minMagnitude) ] }       { set ::conf(modpoi,wizard,minMagnitude)       "0" }
   if { ! [ info exists ::conf(modpoi,wizard,maxMagnitude) ] }       { set ::conf(modpoi,wizard,maxMagnitude)       "7" }

   if { ! [ info exists ::conf(modpoi,wizard,centering,xc) ] }       { set ::conf(modpoi,wizard,centering,xc)       "0" }
   if { ! [ info exists ::conf(modpoi,wizard,centering,yc) ] }       { set ::conf(modpoi,wizard,centering,yc)       "0" }
   if { ! [ info exists ::conf(modpoi,wizard,centering,accuracy) ] } { set ::conf(modpoi,wizard,centering,accuracy) "1.5" }
   if { ! [ info exists ::conf(modpoi,wizard,centering,t0) ] }       { set ::conf(modpoi,wizard,centering,t0)       "2000" }
   if { ! [ info exists ::conf(modpoi,wizard,centering,binning) ] }  { set ::conf(modpoi,wizard,centering,binning)  "1" }
   if { ! [ info exists ::conf(modpoi,wizard,centering,exptime) ] }  { set ::conf(modpoi,wizard,centering,exptime)  "1" }
   if { ! [ info exists ::conf(modpoi,wizard,centering,nbmean) ] }   { set ::conf(modpoi,wizard,centering,nbmean)   "1" }

   #--- Initialisation des variables
   set private(stars,haNb)           $::conf(modpoi,wizard,haNb)
   set private(stars,deNb)           $::conf(modpoi,wizard,deNb)
   set private(minMagnitude)         $::conf(modpoi,wizard,minMagnitude)
   set private(maxMagnitude)         $::conf(modpoi,wizard,maxMagnitude)
   set private(symbols)              "IH ID NP CH ME MA FO HF DAF TF"
   set private(home)                 $::audace(posobs,observateur,gps)
   set private(horizons)             [::horizon::getHorizon $private(home)]
   set private(amerIndex)            "0"
   #--- Mode de centrage (automatique ou manuel)
   set private(centering,check)      0
   set private(centering,star_index) 0
   set private(centering,accuracy)   $::conf(modpoi,wizard,centering,accuracy)
   #--- Initial delay of slew for calibration
   set private(centering,t0)         $::conf(modpoi,wizard,centering,t0)
   set private(centering,nbmean)     "$::conf(modpoi,wizard,centering,nbmean)"

   if {$private(centering,check)==0} {
       set private(centering,mode) manu
    } else {
       set private(centering,mode) auto
    }

   set private(g,base) $::audace(base).modpoi_fntr
   set private(wm_geometry) $::conf(modpoi,wizard,position)
   if { [winfo exists $private(g,base)] } {
      set private(wm_geometry) [wm geometry $private(g,base)]
      destroy $private(g,base)
   }
   #---
   if { [ info exists private(wm_geometry) ] } {
      set deb [ expr 1 + [ string first + $private(wm_geometry) ] ]
      set fin [ string length $private(wm_geometry) ]
      set ::conf(modpoi,wizard,position) "+[ string range $private(wm_geometry) $deb $fin ]"
   }
   #--- New toplevel
   toplevel $private(g,base) -class Toplevel
   wm geometry $private(g,base) $private(wm_geometry)
   wm protocol $private(g,base) WM_DELETE_WINDOW ":::modpoi2::wizard::closeWindow $private(visuNo)"
   if { $::tcl_platform(os) == "Linux" } {
      wm minsize $private(g,base) 560 680
   } else {
      wm minsize $private(g,base) 440 500
   }
   wm resizable $private(g,base) 1 1

   if { [info exists hip_catalog ] == 0 } {
      set hip_catalog ""
   }

   if { $starList == "" } {
      #--- cas d'un nouveau modele
      set private(stars,nb) 0
      modpoi_wiz1
   } else {
      #--- cas d'un modele deja existant
      #--- je cree la liste des points d'amer et la liste des etoiles
      set k 0
      foreach star $starList {
         #--- je charge les 11 valeurs associées au point d'amer.
         ###  ( amerAz amerEl name raCat deCat equinoxCat date raObs deObs pressure temperature )
         set private(star$k,amerAz)      [lindex $star 0]
         set private(star$k,amerEl)      [lindex $star 1]
         set private(star$k,starname)    [lindex $star 2]
         set private(star$k,raCat)       [lindex $star 3]
         set private(star$k,deCat)       [lindex $star 4]
         set private(star$k,eqCat)       [lindex $star 5]
         set private(star$k,date)        [lindex $star 6]
         set private(star$k,raObs)       [lindex $star 7]
         set private(star$k,deObs)       [lindex $star 8]
         set private(star$k,pressure)    [lindex $star 9]
         set private(star$k,temperature) [lindex $star 10]

         #--- si le nom de l'etoile est renseigné, je calcule les ecarts raShift et deShift
         if { $private(star$k,starname) != "" } {
            set hipRecord [list $private(star$k,starname) "0" \
               [mc_angle2deg $private(star$k,raCat)] \
               [mc_angle2deg $private(star$k,deCat)] \
               $private(star$k,eqCat) 0 0 0 0 \
            ]
            #--- je calcule l'ecart en arcmin a la date d'observation sans le modèle de pointage
            set coords [mc_hip2tel $hipRecord $private(star$k,date) $private(home) $private(star$k,pressure) $private(star$k,temperature) ]
            set private(star$k,raApp)   [lindex $coords 0]
            set private(star$k,deApp)   [lindex $coords 1]
            set private(star$k,haApp)   [lindex $coords 2]
            set private(star$k,azApp)   [lindex $coords 3]
            set private(star$k,elApp)   [lindex $coords 4]
            set private(star$k,raShift) [expr 60.0 * [mc_anglescomp [mc_angle2deg $private(star$k,raObs)] - [mc_angle2deg $private(star$k,raApp)] ]]
            set private(star$k,deShift) [expr 60.0 * [mc_anglescomp [mc_angle2deg $private(star$k,deObs)] - [mc_angle2deg $private(star$k,deApp)] ]]

            ###if { $k < 6} {
            ###   ::console::disp "mc_hip2tel { $hipRecord } $private(star$k,date) { $private(home) } $private(star$k,pressure) $private(star$k,temperature)\n"
            ###   ::console::disp "coords=$coords \n"
            ###   ::console::disp "ra=[lindex $coords 0] dec=[lindex $coords 1] ha=[lindex $coords 2] az=[lindex $coords 3] el=[lindex $coords 4]\n"
            ###}

            set private(star$k,selected)  1
         } else {
            set private(star$k,raApp)     ""
            set private(star$k,deApp)     ""
            set private(star$k,haApp)     ""
            set private(star$k,azApp)     ""
            set private(star$k,elApp)     ""
            set private(star$k,raShift)   ""
            set private(star$k,deShift)   ""
            set private(star$k,selected)  0
         }
         incr k
      }
      set private(stars,nb) $k

      #--- je prepare la liste des données pour mc_compute_matrix_modpoi
      set starList ""
      for {set k 0} {$k < $private(stars,nb)} {incr k} {
         if { $private(star$k,starname) != "" } {
            lappend starList [list $private(star$k,haApp) $private(star$k,deApp) \
            [expr - $private(star$k,raShift)] $private(star$k,deShift) ]
         }
      }
      #--- je calcule les coefficients du modele de pointage
      set matrices [mc_compute_matrix_modpoi $starList EQUATORIAL $private(home) $private(symbols) { 0 1 2 3} ]
      set matX [lindex $matrices 0]
      set vecY [lindex $matrices 1]
      set vecW [lindex $matrices 2]
      #--- calcul des coefficients du modele
      set result [gsl_mfitmultilin $vecY $matX $vecW]
      set private(coefficients) [lindex $result 0]
      set private(chisquare) [lindex $result 1]
      set private(covar) [lindex $result 2]

      #--- je calcule des ecarts (obs- calculé) en appliquant le modele
      for {set k 0} {$k < $private(stars,nb)} {incr k} {
         if { $private(star$k,starname) != "" } {
            set hipRecord [list $private(star$k,starname) "0" \
               [mc_angle2deg $private(star$k,raCat)] \
               [mc_angle2deg $private(star$k,deCat)] \
               $private(star$k,eqCat) 0 0 0 0 \
            ]
            set coords [mc_hip2tel $hipRecord $private(star$k,date) $private(home) \
               $private(star$k,pressure) $private(star$k,temperature) \
               $private(symbols) $private(coefficients) \
            ]
            ###if { $k < 6} {
            ###   ::console::disp "mc_hip2tel { $hipRecord } $private(star$k,date) { $private(home) } $private(star$k,pressure) $private(star$k,temperature) { $private(symbols) } { $private(coefficients) }\n"
            ###   ::console::disp "coords=$coords \n"
            ###   ::console::disp "dra=[expr  60.0 * [lindex $coords 5]] ddec=[expr  60.0 * [lindex $coords 6]] dha=[expr  60.0 * [lindex $coords 7]] daz=[expr  60.0 * [lindex $coords 8]] del=[expr  60.0 * [lindex $coords 9]]\n"
            ###}
            #--- je recupere l'ecart en arcmin
            set private(star$k,raShiftTest) [expr  60.0 * [lindex $coords 5]] ; #--- dra
            set private(star$k,deShiftTest) [expr  60.0 * [lindex $coords 6]] ; #--- ddec
         } else {
            set private(star$k,raShiftTest) ""
            set private(star$k,deShiftTest) ""
         }
      }

      #--- j'affiche la liste des etoiles
      modpoi_wiz2
   }
}

#------------------------------------------------------------
#  modpoi_wiz1
#     affiche la page de garde
# @private
#------------------------------------------------------------
proc ::modpoi2::wizard::modpoi_wiz1 { } {
   global caption
   variable private

   if { [winfo exists $private(g,base)] } {
      foreach children [winfo children $private(g,base)] {
          destroy $children
      }
   }

   wm title $private(g,base) $caption(modpoi2,wiz1,title)

   #--- Title
   label $private(g,base).lab_title2 \
      -text $caption(modpoi2,wiz1,title2) \
      -borderwidth 2 -padx 20 -pady 10
      pack $private(g,base).lab_title2 \
      -side top -anchor center \
      -padx 5 -pady 3 -expand 0
   #--- Describe
   label $private(g,base).lab_desc \
      -text $caption(modpoi2,wiz1,desc) -borderwidth 2 \
      -padx 20 -pady 10
      pack $private(g,base).lab_desc \
      -side top -anchor center \
      -padx 5 -pady 3 -expand 0
   #--- NEXT button
   button $private(g,base).but_next \
      -text $caption(modpoi2,wiz1,next) -borderwidth 2 \
      -padx 20 -pady 10 -command { ::modpoi2::wizard::modpoi_wiz1b }
   pack $private(g,base).but_next \
      -side bottom -anchor center \
      -padx 5 -pady 10 -expand 0
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private(g,base)
}

#------------------------------------------------------------
#  modpoi_wiz1b
#     choix des limites et du catalogue
# @private
#------------------------------------------------------------
proc ::modpoi2::wizard::modpoi_wiz1b { } {
   variable private
   global caption

   if { [winfo exists $private(g,base)] } {
      foreach children [winfo children $private(g,base)] {
          destroy $children
      }
   }

   wm title $private(g,base) $caption(modpoi2,wiz1b,title)
   #--- Title
   label $private(g,base).lab_title1b \
      -text $caption(modpoi2,wiz1b,title2) \
      -borderwidth 2 -padx 20 -pady 10
   pack $private(g,base).lab_title1b \
      -side top -anchor center \
      -padx 5 -pady 3 -expand 0

   frame $private(g,base).amer
      #--- Label haNb
      label $private(g,base).amer.haNbLabel -text $caption(modpoi2,wiz1b,haNb)
      grid  $private(g,base).amer.haNbLabel -row 0 -column 0 -sticky w
      #--- Entry haNb
      entry $private(g,base).amer.haNbEntry -width 3 -justify center \
         -textvariable ::modpoi2::wizard::private(stars,haNb)
      grid  $private(g,base).amer.haNbEntry -row 0 -column 1 -sticky w
      #--- Label deNb
      label $private(g,base).amer.deNbLabel -text $caption(modpoi2,wiz1b,deNb)
      grid  $private(g,base).amer.deNbLabel -row 1 -column 0 -sticky w
      #--- Entry deNb
      entry $private(g,base).amer.deNbEntry -width 3 -justify center \
         -textvariable ::modpoi2::wizard::private(stars,deNb)
      grid  $private(g,base).amer.deNbEntry -row 1 -column 1 -sticky w
   pack $private(g,base).amer -side top -anchor center -padx 5 -pady 3 -expand 0

   #--- Check if mount take refraction correction into account
   frame $private(g,base).fra_refr
      if { [ ::confTel::getPluginProperty hasRefractionCorrection ] == "1" } {
         label $private(g,base).fra_refr.lab_refraction_1 \
            -text $caption(modpoi2,wiz1b,refraction_1) -borderwidth 2 \
            -padx 0 -pady 3
         pack $private(g,base).fra_refr.lab_refraction_1 \
            -side left -anchor center \
            -padx 0 -pady 3 -fill x
         set private(corrections,refraction) "1"
      } else {
         label $private(g,base).fra_refr.lab_refraction_2 \
            -text $caption(modpoi2,wiz1b,refraction_2) -borderwidth 2 \
            -padx 0 -pady 3
         pack $private(g,base).fra_refr.lab_refraction_2 \
            -side left -anchor center \
            -padx 0 -pady 3 -fill x
         set private(corrections,refraction) "0"
      }
   pack $private(g,base).fra_refr -side top -anchor center -padx 5 -pady 3 -expand 0

   #--- Check if centering will be auto or not
   frame $private(g,base).fra_auto
      checkbutton $private(g,base).fra_auto.chk -text $caption(modpoi2,wiz1b,acqauto) \
         -highlightthickness 0 -variable ::modpoi2::wizard::private(centering,check) \
         -command { ::modpoi2::wizard::checkCamera }
      pack $private(g,base).fra_auto.chk -side left -padx 0 -pady 3 -fill x -anchor center
   pack $private(g,base).fra_auto \
      -side top -anchor center \
      -padx 5 -pady 3 -expand 0

   #--- Frame for bottom buttons
   set wiz wiz1b
   frame $private(g,base).fra_bottom
      #--- PREVIOUS button
      button $private(g,base).fra_bottom.but_prev \
         -text $caption(modpoi2,$wiz,prev) -borderwidth 2 \
         -padx 20 -pady 10 -command { ::modpoi2::wizard::modpoi_wiz1 }
      pack $private(g,base).fra_bottom.but_prev \
         -side left -anchor se \
         -padx 5 -pady 5 -expand 0
      #--- NEXT button
      button $private(g,base).fra_bottom.but_next \
         -text $caption(modpoi2,$wiz,next) -borderwidth 2 \
         -padx 20 -pady 10 \
         -command { ::modpoi2::wizard::checkStarNb }
      pack $private(g,base).fra_bottom.but_next \
      -side right -anchor se \
      -padx 5 -pady 5 -expand 0
   pack $private(g,base).fra_bottom \
   -side bottom -anchor center \
   -padx 5 -pady 5 -expand 0

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private(g,base)
}

#-------------------------------------------------------------------------------
# modpoi_wiz1c
#   intialise les parametres de centrage de la camera
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::modpoi_wiz1c { } {
   global caption
   variable private

   if { [winfo exists $private(g,base)] } {
      foreach children [winfo children $private(g,base)] {
          destroy $children
      }
   }
   wm title $private(g,base) $caption(modpoi2,wiz1c,title)
   #--- Title
   label $private(g,base).lab_title1b \
      -text $caption(modpoi2,wiz1c,title2) \
      -borderwidth 2 -padx 20 -pady 10
   pack $private(g,base).lab_title1b \
      -side top -anchor center \
      -padx 5 -pady 3 -expand 0
   #---
   #--- Binning, exptime
   #--- Coordonnées du centre de l'image (x,y)
   #--- Limite angle horaire est, west
   #--- Coordinates to center
   frame $private(g,base).fra_c0
      #--- Label xyc
      label $private(g,base).fra_c0.lab_xyc \
         -text "   $caption(modpoi2,wiz1c,xyc) " -borderwidth 2 \
         -padx 0 -pady 0
      pack $private(g,base).fra_c0.lab_xyc \
         -side left -anchor center \
         -padx 0 -pady 3 -expand 0
   pack $private(g,base).fra_c0 \
      -side top -anchor center \
      -padx 5 -pady 0 -expand 0

   frame $private(g,base).fra_c
      #--- Label xc
      label $private(g,base).fra_c.lab_xc \
         -text "   $caption(modpoi2,wiz1c,xc) " -borderwidth 2 \
         -padx 0 -pady 0
      pack $private(g,base).fra_c.lab_xc \
         -side left -anchor center \
         -padx 0 -pady 3 -expand 0
      #--- Entry xc
      entry $private(g,base).fra_c.ent_xc \
         -textvariable ::modpoi2::wizard::private(centering,xc) \
         -borderwidth 2 -width 6 -justify center
      pack $private(g,base).fra_c.ent_xc \
         -side left -anchor center \
         -padx 0 -pady 3 -expand 0
      #--- Label yc
      label $private(g,base).fra_c.lab_yc \
         -text "    $caption(modpoi2,wiz1c,yc) " -borderwidth 2 \
         -padx 0 -pady 0
      pack $private(g,base).fra_c.lab_yc \
         -side left -anchor center \
         -padx 0 -pady 3 -expand 0
      #--- Entry yc
      entry $private(g,base).fra_c.ent_yc \
         -textvariable ::modpoi2::wizard::private(centering,yc) \
         -borderwidth 2 -width 6 -justify center
      pack $private(g,base).fra_c.ent_yc \
         -side left -anchor center \
         -padx 0 -pady 3 -expand 0
      pack $private(g,base).fra_c \
         -side top -anchor center \
         -padx 5 -pady 0 -expand 0

   #--- Accuracy of automatic centering
   frame $private(g,base).fra_a
   #--- Label accuraccy
   label $private(g,base).fra_a.lab \
      -text "   $caption(modpoi2,wiz1c,accuracy) " -borderwidth 2 \
      -padx 0 -pady 0
   pack $private(g,base).fra_a.lab \
      -side left -anchor center \
      -padx 0 -pady 0 -expand 0
   #--- Entry accuracy
   entry $private(g,base).fra_a.ent \
      -textvariable ::modpoi2::wizard::private(centering,accuracy) \
      -borderwidth 2 -width 6 -justify center
   pack $private(g,base).fra_a.ent \
      -side left -anchor center \
      -padx 0 -pady 0 -expand 0
   pack $private(g,base).fra_a \
      -side top -anchor center \
      -padx 5 -pady 0 -expand 0

   #--- Initial delay for drift calibration
   frame $private(g,base).fra_r
      #--- Label initial delay
      label $private(g,base).fra_r.lab \
         -text "   $caption(modpoi2,wiz1c,initial_delay) " -borderwidth 2 \
         -padx 0 -pady 0
      pack $private(g,base).fra_r.lab \
         -side left -anchor center \
         -padx 0 -pady 0 -expand 0
      #--- Entry initial delay
      entry $private(g,base).fra_r.ent \
         -textvariable ::modpoi2::wizard::private(centering,t0) \
         -borderwidth 2 -width 6 -justify center
      pack $private(g,base).fra_r.ent \
         -side left -anchor center \
         -padx 0 -pady 0 -expand 0
   pack $private(g,base).fra_r \
      -side top -anchor center \
      -padx 5 -pady 3 -expand 0
   #--- Binning et temps de pose
   frame $private(g,base).fra_cam
      #--- Label binning
      label $private(g,base).fra_cam.lab_bin \
         -text "   $caption(modpoi2,wiz1c,binning) " -borderwidth 2 \
         -padx 0 -pady 10
      pack $private(g,base).fra_cam.lab_bin \
         -side left -anchor center \
         -padx 0 -pady 3 -expand 0
      #--- Entry binning
      entry $private(g,base).fra_cam.ent_bin \
         -textvariable ::modpoi2::wizard::private(centering,binning) \
         -borderwidth 2 -width 3 -justify center
      pack $private(g,base).fra_cam.ent_bin \
         -side left -anchor center \
         -padx 0 -pady 3 -expand 0
      #--- Label temps de pose
      label $private(g,base).fra_cam.lab_exp \
         -text "    $caption(modpoi2,wiz1c,exptime) " -borderwidth 2 \
         -padx 0 -pady 10
      pack $private(g,base).fra_cam.lab_exp \
         -side left -anchor center \
         -padx 0 -pady 3 -expand 0
      #--- Entry temps de pose
      entry $private(g,base).fra_cam.ent_exp \
         -textvariable ::modpoi2::wizard::private(centering,exptime) \
         -borderwidth 2 -width 6 -justify center
      pack $private(g,base).fra_cam.ent_exp \
         -side left -anchor center \
         -padx 0 -pady 3 -expand 0
   pack $private(g,base).fra_cam \
      -side top -anchor center \
      -padx 5 -pady 3 -expand 0
   #--- Nombre d'images a moyenner
   frame $private(g,base).fra_comp
      #--- Label nombre d'images a moyenner
      label $private(g,base).fra_comp.lab \
         -text "   $caption(modpoi2,wiz1c,compositage) " -borderwidth 2 \
         -padx 0 -pady 0
      pack $private(g,base).fra_comp.lab \
         -side left -anchor center \
         -padx 0 -pady 0 -expand 0
      #--- Entry nombre d'images a moyenner
      entry $private(g,base).fra_comp.ent \
         -textvariable ::modpoi2::wizard::private(centering,nbmean) \
         -borderwidth 2 -width 3 -justify center
      pack $private(g,base).fra_comp.ent \
         -side left -anchor center \
         -padx 0 -pady 0 -expand 0
   pack $private(g,base).fra_comp \
      -side top -anchor center \
      -padx 5 -pady 3 -expand 0

   #--- Frame for bottom buttons
   set wiz wiz1c
   frame $private(g,base).fra_bottom
      #--- PREVIOUS button
      button $private(g,base).fra_bottom.but_prev \
         -text $caption(modpoi2,$wiz,prev) -borderwidth 2 \
         -padx 20 -pady 10 -command { ::modpoi2::wizard::modpoi_wiz1b }
      pack $private(g,base).fra_bottom.but_prev \
         -side left -anchor se \
         -padx 5 -pady 5 -expand 0
      #--- NEXT button
      button $private(g,base).fra_bottom.but_next \
         -text $caption(modpoi2,$wiz,next) -borderwidth 2 \
         -padx 20 -pady 10 -command {::modpoi2::wizard::modpoi_wiz2 }
      pack $private(g,base).fra_bottom.but_next \
         -side right -anchor se \
         -padx 5 -pady 5 -expand 0
   pack $private(g,base).fra_bottom \
      -side bottom -anchor center \
      -padx 5 -pady 5 -expand 0

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private(g,base)
}

#-------------------------------------------------------------------------------
# modpoi_wiz2
#   affiche la liste des points d'amer
#
# donnees en entree
#   private(stars,nb)
#   private(star$k,starname)
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::modpoi_wiz2 { } {
   global caption color
   variable private

   if { [winfo exists $private(g,base)] } {
      foreach children [winfo children $private(g,base)] {
          destroy $children
      }
   }
   wm title $private(g,base) $caption(modpoi2,wiz2,title)
   #--- Title
   label $private(g,base).lab_title2 \
      -text $caption(modpoi2,wiz2,title2) \
      -borderwidth 2 -padx 20 -pady 10
   pack $private(g,base).lab_title2 \
      -side top -anchor center \
      -padx 5 -pady 3 -expand 0
   #--- Buttons
   set colonne 0
   set private(nbMesured) 0
   set private(nbSelected) 0

   #--- liste des points d'amer
   TitleFrame $private(g,base).amer -borderwidth 2 -relief ridge -text $::caption(modpoi2,starList)
      set tkAmerTable $private(g,base).amer.table
      scrollbar $private(g,base).amer.xsb -command "$tkAmerTable xview" -orient horizontal
      scrollbar $private(g,base).amer.ysb -command "$tkAmerTable yview"

      #--- Table des reference
      ::tablelist::tablelist $tkAmerTable \
         -columns [list \
            0 $::caption(modpoi2,star,amerNum)    center \
            0 $::caption(modpoi2,azimutEtoile)    right \
            0 $::caption(modpoi2,elevationEtoile) right \
            0 $::caption(modpoi2,star,name)       center \
            0 $::caption(modpoi2,star,raShift)    right \
            0 $::caption(modpoi2,star,deShift)    right \
            0 $::caption(modpoi2,star,haApp)      right \
            0 $::caption(modpoi2,star,deApp)      right \
            0 $::caption(modpoi2,star,select)     center \
            0 $::caption(modpoi2,star,raShiftOC)  right \
            0 $::caption(modpoi2,star,deShiftOC)  right \
          ] \
         -xscrollcommand [list $private(g,base).amer.xsb set] \
         -yscrollcommand [list $private(g,base).amer.ysb set] \
         -exportselection 0 \
         -activestyle none

      #--- je donne un nom a chaque colonne
      #--- j'ajoute l'option -stretchable pour que la colonne s'etire jusqu'au bord droit de la table
      #--- j'ajoute l'option -sortmode dictionary pour le tri soit independant de la casse
      $tkAmerTable columnconfigure 0 -name amerNum
      $tkAmerTable columnconfigure 1 -name amerAz
      $tkAmerTable columnconfigure 2 -name amerEl
      $tkAmerTable columnconfigure 3 -name starName
      $tkAmerTable columnconfigure 4 -name raShift
      $tkAmerTable columnconfigure 5 -name deShift
      $tkAmerTable columnconfigure 6 -name haApp
      $tkAmerTable columnconfigure 7 -name deApp
      $tkAmerTable columnconfigure 8 -name state -editwindow checkbutton
      $tkAmerTable columnconfigure 9 -name raShiftTest
      $tkAmerTable columnconfigure 10 -name deShiftTest

      bind $tkAmerTable <<ListboxSelect>>  [list ::modpoi2::wizard::onSelectAmer $tkAmerTable]

      #--- je place la table et les scrollbars dans la frame
      grid $tkAmerTable -in [$private(g,base).amer getframe] -row 0 -column 0 -sticky ewns
      grid $private(g,base).amer.ysb -in [$private(g,base).amer getframe] -row 0 -column 1 -sticky nsew
      grid $private(g,base).amer.xsb -in [$private(g,base).amer getframe] -row 1 -column 0 -sticky ew
      grid rowconfig    [$private(g,base).amer getframe] 0 -weight 1
      grid columnconfig [$private(g,base).amer getframe] 0 -weight 1
   pack $private(g,base).amer -side top -fill both -expand 1

   TitleFrame $private(g,base).magnitude  -borderwidth 2 -relief ridge

      #--- Label min magnitude
      label $private(g,base).magnitude.minLabel -text $::caption(modpoi2,wiz2,minMagnitude)
      grid  $private(g,base).magnitude.minLabel -in [$private(g,base).magnitude getframe] -row 0 -column 0 -sticky w
      #--- Entry min magnitude
      entry $private(g,base).magnitude.minValue -width 8 -justify center \
         -textvariable ::modpoi2::wizard::private(minMagnitude) \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double -3.0 20.0 }
      grid  $private(g,base).magnitude.minValue -in [$private(g,base).magnitude getframe] -row 0 -column 1 -sticky w

      #--- Label max magnitude
      label $private(g,base).magnitude.maxLabel -text $::caption(modpoi2,wiz2,maxMagnitude)
      grid  $private(g,base).magnitude.maxLabel -in [$private(g,base).magnitude getframe] -row 1 -column 0 -sticky w
      #---  Entry max magnitude
      entry $private(g,base).magnitude.maxValue -width 8 -justify center \
         -textvariable ::modpoi2::wizard::private(maxMagnitude) \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double -3.0 20.0 }
      grid  $private(g,base).magnitude.maxValue -in [$private(g,base).magnitude getframe] -row 1 -column 1 -sticky w

      #--- nb amer
      label $private(g,base).magnitude.amerLabel -text $::caption(modpoi2,wiz2,nbrePointAmer)
      grid  $private(g,base).magnitude.amerLabel -in [$private(g,base).magnitude getframe] -row 0 -column 3 -sticky w
      entry $private(g,base).magnitude.amerValue -width 8 -justify center -state readonly \
        -textvariable ::modpoi2::wizard::private(stars,nb)
      grid  $private(g,base).magnitude.amerValue -in [$private(g,base).magnitude getframe] -row 0 -column 4 -sticky w

      #--- nb mesured
      label $private(g,base).magnitude.mesuredLabel -text $::caption(modpoi2,wiz2,nbreEtoileMes)
      grid  $private(g,base).magnitude.mesuredLabel -in [$private(g,base).magnitude getframe] -row 1 -column 3 -sticky w
      entry $private(g,base).magnitude.mesuredValue -width 8 -justify center -state readonly \
        -textvariable ::modpoi2::wizard::private(nbMesured)
      grid  $private(g,base).magnitude.mesuredValue -in [$private(g,base).magnitude getframe] -row 1 -column 4 -sticky w

      #--- nb selected
      label $private(g,base).magnitude.selectedLabel -text $::caption(modpoi2,wiz2,nbreEtoileSelect)
      grid  $private(g,base).magnitude.selectedLabel -in [$private(g,base).magnitude getframe] -row 2 -column 3 -sticky w
      entry $private(g,base).magnitude.selectedValue -width 8 -justify center -state readonly \
        -textvariable ::modpoi2::wizard::private(nbSelected)
      grid  $private(g,base).magnitude.selectedValue -in [$private(g,base).magnitude getframe] -row 2 -column 4 -sticky w

   pack $private(g,base).magnitude -side top -fill x -expand 0

   #--- je remplis la liste des points d'amer et l'etoiles
   for {set k 0} {$k < $private(stars,nb) } { incr k} {
      set amerAz [format "%.3f" $private(star$k,amerAz)]
      set amerEl [format "%.3f" $private(star$k,amerEl)]

      if { $private(star$k,starname)!="" } {
         #--- Si un ecart a deja ete mesure , j'affiche l'ecart
         set starName    $private(star$k,starname)
         set raShift     [format "%.3f" $private(star$k,raShift)]
         set deShift     [format "%.3f" $private(star$k,deShift)]
         set haApp       [mc_angle2hms $private(star$k,haApp) 360 zero 0 auto string]
         set deApp       [mc_angle2dms $private(star$k,deApp) 90  zero 0 + string]
         set raShiftTest [format "%.3f" [expr $private(star$k,raShiftTest) - $private(star$k,raShift)] ]
         set deShiftTest [format "%.3f" [expr $private(star$k,deShiftTest) - $private(star$k,deShift)] ]
         #--- j'incremente le compteur des mesures
         incr private(nbMesured)
         if { $private(star$k,selected) == 1 } {
           incr private(nbSelected)
         }
         set checkButtonState "normal"
      } else {
         set starName         ""
         set raShift          ""
         set deShift          ""
         set haApp            ""
         set deApp            ""
         set raShiftTest      ""
         set deShiftTest      ""
         set checkButtonState "disabled"
      }
      $tkAmerTable insert end [list [expr $k+1] $amerAz $amerEl "" \
         $raShift $deShift $haApp $deApp "" $raShiftTest $deShiftTest ]

      #--- je donne un nom a la ligne (numero de la ligne, avec l'origine a 0)
      $tkAmerTable rowconfigure end -name $k
      #--- je configure la colonne contenant le bouton
      $tkAmerTable cellconfigure end,starName \
         -window [ list ::modpoi2::wizard::createButton ] \
         -windowdestroy [ list ::modpoi2::wizard::deleteButton ]
      #--- je configure la colonne contenant le chekbutton
      $tkAmerTable cellconfigure end,state \
            -window [ list ::modpoi2::wizard::createCheckbutton $checkButtonState ] \
            -windowdestroy [ list ::modpoi2::wizard::deleteCheckbutton ]
      #--- je coche le checkButton
      setCheckbutton $tkAmerTable end "state" $private(star$k,selected)
   }

   #--- j'affiche la carte des points d'amer
   displayMap $private(visuNo)
   #--- je redonne le focus a la fentre du wizard
   focus $private(g,base)

   #--- je selectionne le premier point d'amer
   $private(g,base).amer.table selection clear 0 end
   $tkAmerTable selection set $private(amerIndex)
   onSelectAmer $tkAmerTable

   #--- Frame for bottom buttons
   if {$private(centering,mode)=="manu"} {
      frame $private(g,base).fra_bottom
      ####--- PREVIOUS button
      ###button $private(g,base).fra_bottom.but_prev \
      ###   -text $caption(modpoi2,wiz2,prev) -borderwidth 2 \
      ###   -padx 20 -pady 10 -command { ::modpoi2::wizard::modpoi_wiz1 }
      ###pack $private(g,base).fra_bottom.but_prev \
      ###   -side left -anchor se \
      ###   -padx 5 -pady 5 -expand 0
      #--- NEXT button
      if {$private(nbMesured) >= 6} {
         button $private(g,base).fra_bottom.but_next \
            -text $caption(modpoi2,wiz2,next) -borderwidth 2 \
            -padx 20 -pady 10 -command { ::modpoi2::wizard::modpoi_wiz5 }
         pack $private(g,base).fra_bottom.but_next \
            -side right -anchor se \
            -padx 5 -pady 5 -expand 0
      }
      pack $private(g,base).fra_bottom \
         -side bottom -anchor center \
         -padx 5 -pady 5 -expand 0
   }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private(g,base)

   if {$private(centering,mode)=="auto"} {
      #--- Automatic centering procedure
      update
      after 1000
      if {$private(centering,star_index)==$private(stars,nb)} {
         ::modpoi2::wizard::modpoi_wiz5
         return
      }
      incr private(centering,star_index)
      set command "::modpoi2::wizard::modpoi_wiz3 $private(centering,star_index)"
      eval $command
      return
   }
}

#------------------------------------------------------------------------------
# createButton
#    cree un checkbutton dans la table des points d'amer
#
# Parametres :
#    tkTable      : nom Tk de la table
#    row          : numero de ligne
#    col          : numero de colonne
#    w            : nom Tk du bouton
# @private
#------------------------------------------------------------------------------
proc ::modpoi2::wizard::createButton { tkTable row col w } {
   variable private

   if { $private(star$row,starname) == "" } {
      set activebackground $::color(lightred)
   } else {
      set activebackground $::color(lightgreen)
   }

   button $w -text $private(star$row,starname) -activebackground $activebackground \
      -bg $activebackground -width 10 -command "::modpoi2::wizard::modpoi_wiz3 $row"
}

#------------------------------------------------------------------------------
# deleteButton
#    supprime un checkbutton dans la table des points d'amer
#
# Parametres :
#    tkTable      : nom Tk de la table
#    row          : numero de ligne
#    col          : numero de colonne
#    w            : nom Tk du bouton
# @private
#------------------------------------------------------------------------------
proc ::modpoi2::wizard::deleteButton { tkTable row col w } {
   destroy $w
}

#------------------------------------------------------------------------------
# createCheckbutton
#    cree un checkbutton dans la table
#
# @private
# Parametres :
#    state        : etat {normal|disabled}
#    tkTable      : nom Tk de la table
#    row          : numero de ligne
#    col          : numero de colonne
#    w            : nom Tk du bouton
#------------------------------------------------------------------------------
proc ::modpoi2::wizard::createCheckbutton { state tkTable row col w } {
   variable private
   set k [$tkTable rowcget $row -name ]
   #--- je cree le checkbutton avec une variable qui porte le nom du checkbutton
   checkbutton $w -highlightthickness 0 -takefocus 0 \
      -state $state \
      -variable ::modpoi2::wizard::private(star$k,selected) \
      -command "::modpoi2::wizard::onSelectCheckButton $w $k"
   if { $state == "normal" && $private(star$k,selected) == 0 } {
      $w configure -background red
   }
}

#------------------------------------------------------------------------------
# onSelectCheckButton
#   configure la couleur d'un ChekButton dans il est coché ou décoché
#   et met à jour le compteur d'étoiles cochées.
#
# @private
# Parametres :
#    w            : nom Tk du bouton
#    lineNo       : numero de la ligne
#------------------------------------------------------------------------------
proc ::modpoi2::wizard::onSelectCheckButton { w k} {
   variable private

   #--- je recupere le nom de la varible qui contient l'etat du bouton
   set variableName [$w cget -variable]
   set selected [set $variableName]

   if { $selected == 1 } {
      incr private(nbSelected) +1
      $w configure -background SystemButtonFace
   } else {
      incr private(nbSelected) -1
      $w configure -background $::color(lightred)
   }

}

#------------------------------------------------------------------------------
# deleteCheckbutton
#    supprime un checkbutton dans la table
#
# @private
# Parametres :
#    tkTable      : nom Tk de la table
#    row          : numero de ligne
#    col          : numero de colonne
#    w            : nom Tk du bouton
#------------------------------------------------------------------------------
proc ::modpoi2::wizard::deleteCheckbutton { tkTable row col w } {
   destroy $w
}

#------------------------------------------------------------------------------
# setCheckbutton
#    change l'etat du checkbutton dans la table
#
# @private
# Parametres :
#    tkTable      : nom Tk de la table
#    lineName     : nom de ligne
#    columnName   : nom de la colonne
#    value        : 0 ou 1 ou -1 (inactif)
#------------------------------------------------------------------------------
proc ::modpoi2::wizard::setCheckbutton { tkTable lineName columnName value } {

   set w [ $tkTable windowpath $lineName,$columnName]
   switch $value {
       1    { $w select }
       0    { $w deselect }
   }
}

#-------------------------------------------------------------------------------
# onSelectAmer
#   affiche un cercle bleu autour du point selectionne dans la carte
#
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::onSelectAmer { tkAmerTable } {
   variable private

   #--- je recupere la ligne slectionnee par l'utilisateur
   set k [lindex [$tkAmerTable curselection] 0]
   if { $k != "" } {
      #--- je recupere les coordonnees du point d'amer
      set amerAz $private(star$k,amerAz)
      set amerEl $private(star$k,amerEl)
      if { $private(star$k,starname)!="" } {
         set starAz $private(star$k,azApp)
         set starEl $private(star$k,elApp)
      } else {
         set starAz ""
         set starEl ""
      }

      #--- j'affiche un cercle autour du point d'amer selectionne
      showSelectedAmer $amerAz $amerEl $starAz $starEl
   }
}

#-------------------------------------------------------------------------------
# modpoi_wiz3
#   selection d'une etoile proche du point d'amer
#   et affiche les boutons faire un centrage
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::modpoi_wiz3 { amerIndex } {
   variable private
   variable hip_catalog
   global caption

   if { [winfo exists $private(g,base)] } {
      foreach children [winfo children $private(g,base)] {
          destroy $children
      }
   }

   #--- j'affiche dans la carte un cercle autour du point d'amer selectionne
   set amerAz [format "%.3f" $private(star$amerIndex,amerAz)]
   set amerEl [format "%.3f" $private(star$amerIndex,amerEl)]
   if { $private(star$amerIndex,starname)!="" } {
      set starAz $private(star$amerIndex,azApp)
      set starEl $private(star$amerIndex,elApp)
   } else {
      set starAz ""
      set starEl ""
   }
   showSelectedAmer $amerAz $amerEl $starAz $starEl

   #--- New toplevel
   set wiz wiz3
   wm title $private(g,base) "$caption(modpoi2,$wiz,title) [expr $amerIndex +1]"
   #--- Title
   label $private(g,base).lab_title2 \
      -text "$caption(modpoi2,$wiz,title2) [expr $amerIndex +1] : $caption(modpoi2,azimut) $amerAz - $caption(modpoi2,elevation) $amerEl" \
      -borderwidth 2 -padx 20 -pady 10
   pack $private(g,base).lab_title2 \
      -side top -anchor center \
      -padx 5 -pady 3 -expand 0

   #--- liste 5 etoiles les plus proches du point d'amer
   TitleFrame $private(g,base).star -borderwidth 2 -relief ridge -text $::caption(modpoi2,starList)
      set tkStarTable $private(g,base).star.table
      scrollbar $private(g,base).star.xsb -command "$tkStarTable xview" -orient horizontal
      scrollbar $private(g,base).star.ysb -command "$tkStarTable yview"

      #--- Table des 5 etoiles
      ::tablelist::tablelist $tkStarTable \
         -columns [list \
            0 $::caption(modpoi2,star,name)      left \
            0 $::caption(modpoi2,star,magnitude) left \
            0 $::caption(modpoi2,star,RA)        left \
            0 $::caption(modpoi2,star,Dec)       left \
            0 $::caption(modpoi2,star,raShift)   left \
            0 $::caption(modpoi2,star,deShift)   left \
          ] \
         -xscrollcommand [list $private(g,base).star.xsb set] \
         -yscrollcommand [list $private(g,base).star.ysb set] \
         -exportselection 0 \
         -activestyle none

      #--- je donne un nom a chaque colonne
      #--- j'ajoute l'option -stretchable pour que la colonne s'etire jusqu'au bord droit de la table
      #--- j'ajoute l'option -sortmode dictionary pour le tri soit independant de la casse
      $tkStarTable columnconfigure 0 -name hipNum
      $tkStarTable columnconfigure 1 -name magnitude
      $tkStarTable columnconfigure 2 -name ra
      $tkStarTable columnconfigure 3 -name dec
      $tkStarTable columnconfigure 4 -name starRaShift
      $tkStarTable columnconfigure 5 -name starDeShift

      bind $tkStarTable <<ListboxSelect>>  [list ::modpoi2::wizard::onSelectStar $tkStarTable]

      #--- je place la table et les scrollbars dans la frame
      grid $tkStarTable -in [$private(g,base).star getframe] -row 0 -column 0 -sticky ewns
      grid $private(g,base).star.ysb  -in [$private(g,base).star getframe] -row 0 -column 1 -sticky nsew
      grid $private(g,base).star.xsb  -in [$private(g,base).star getframe] -row 1 -column 0 -sticky ew
      grid rowconfig    [$private(g,base).star getframe] 0 -weight 1
      grid columnconfig [$private(g,base).star getframe] 0 -weight 1
   pack $private(g,base).star -side top -fill both -expand 1

   #--- Label for the comment
   if { [ ::confTel::getPluginProperty hasRefractionCorrection ] == "0" } {
      label $private(g,base).lab_comment_1 \
         -text $caption(modpoi2,$wiz,comment_1) -borderwidth 2 \
         -padx 20 -pady 10
      pack $private(g,base).lab_comment_1 \
         -side top -anchor center \
         -padx 5 -pady 3 -expand 0
   } else {
      label $private(g,base).lab_comment_2 \
         -text $caption(modpoi2,$wiz,comment_2) -borderwidth 2 \
         -padx 20 -pady 10
      pack $private(g,base).lab_comment_2 \
         -side top -anchor center \
         -padx 5 -pady 3 -expand 0
   }

   if {$private(centering,mode)=="manu"} {
      #--- Frame for bottom buttons
      frame $private(g,base).fra_bottom
         #--- PREVIOUS button
         button $private(g,base).fra_bottom.but_prev \
            -text $caption(modpoi2,$wiz,prev) -borderwidth 2 \
            -padx 20 -pady 10 -command { ::modpoi2::wizard::modpoi_wiz2 }
         pack $private(g,base).fra_bottom.but_prev \
            -side left -anchor se \
            -padx 5 -pady 5 -expand 0
         #--- NEXT button (pointer)
         button $private(g,base).fra_bottom.but_next \
            -text $caption(modpoi2,$wiz,next) -borderwidth 2 \
            -padx 20 -pady 10 -command ::modpoi2::wizard::modpoi_wiz4
         pack $private(g,base).fra_bottom.but_next \
            -side right -anchor se \
            -padx 5 -pady 5 -expand 0
      pack $private(g,base).fra_bottom \
         -side bottom -anchor center \
         -padx 5 -pady 5 -expand 0

      #--- NON VISIBLE button
      ###button $private(g,base).but_cannot \
      ###   -text $caption(modpoi2,$wiz,cannot) -borderwidth 2 \
      ###   -padx 20 -pady 3 -command "::modpoi2::wizard::modpoi_wiz3 $amerIndex"
      ###pack $private(g,base).but_cannot \
      ###   -side bottom -anchor center \
      ###   -padx 10 -pady 0 -expand 0 -fill x
   }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private(g,base)
   #--- Case of autocentering
   if {$private(centering,mode)=="auto"} {
      update
      after 1000
      eval $com_next
   }

   set private(amerIndex) $amerIndex

   #--- si l'utilisateur a change les magnitudes limtes, je vide
   #--- la variable du catalogue pour forcer un nouveau chargement
   if { $private(minMagnitude) != $::conf(modpoi,wizard,minMagnitude)
      || $private(maxMagnitude) != $::conf(modpoi,wizard,maxMagnitude) } {

      set hip_catalog ""
      set ::conf(modpoi,wizard,minMagnitude)  $private(minMagnitude)
      set ::conf(modpoi,wizard,maxMagnitude)  $private(maxMagnitude)
   }
   if { [llength $hip_catalog] == 0 } {
      set fileName [ file join $::audace(rep_catalogues) hip_main.dat]
      #--- je verifie l'existance du catalogue hip_main.dat dans le repertoire des catalogues de l'utilisateur
      if { [file exists $fileName ] == 0 } {
         tk_messageBox -type yesno -icon error -title $caption(modpoi2,wiz3,title) \
            -message [format $::caption(modpoi2,wiz3,catalogNotFound) $fileName ]
         #--- je reviens a l'étape precedente (wiz2 affichage des points d'amer)
         ::modpoi2::wizard::modpoi_wiz2
         return
      }

      #--- je charge le catalogue hip_main.dat
      set hip_catalog [mc_readhip $fileName -double_stars 0 -plx_max 100 -mu_max 100 \
         -mag_min $::conf(modpoi,wizard,minMagnitude) \
         -mag_max $::conf(modpoi,wizard,maxMagnitude)]
      set len [llength $hip_catalog]
   }

   #--- je recupere les 5 etoiles les plus proches du point d'amer
   set date [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]
   set amerRadec [mc_altaz2radec $amerAz $amerEl $private(home) $date]
   set amerRa [lindex $amerRadec 0]
   set amerDe [lindex $amerRadec 1]
   set private(hipList) [mc_nearesthip $amerRa $amerDe $hip_catalog -max_nbstars 7]

   #--- j'affiche les etoiles proches du point d'amer dans le tableau
   set private(selectedHip) 0
   for { set k 0} { $k < [llength $private(hipList)] } { incr k} {
      set hipRecord [lindex $private(hipList) $k]
      # contenu de hipRecord :
      #    id       : identifiant hypparcos de l'etoile (nombre entier >0)
      #    mag      : magnitude, si non utilisee = 0.0 (nombre decimal)
      #    ra       : ascension droite (en degres decimaux)
      #    dec      : declinaison (en degres decimaux)
      #    equinox  : date de l'equinoxe, date du jour=now ou date au format ISO8601 des coordonnees de l'objet
      #    epoch    : date de l'epoque d'origine des mouvements propres, inutilisee si mura et mudec sont nuls
      #    mura     : mouvement propre ra, =0 si inconnu (en degres par an)
      #    mudec    : mouvement propre dec, =0 si inconnu (en degres par an)
      #    plx      : parallaxe, =0 si inconnu (en mas=millisecondes d'arc)
      #    dist     : distance de l'etoile a la coordonnee nominale (degres)

      #--- je prepare le resultat
      set name [lindex $hipRecord 0]
      set magnitude [lindex $hipRecord 1]
      set ra_cat [mc_angle2hms [lindex $hipRecord 2] 360 zero 0 auto string]
      set de_cat [mc_angle2dms [lindex $hipRecord 3] 90  zero 0 + string]
      if { $private(star$amerIndex,starname) == $name} {
           set raShift $private(star$amerIndex,raShift)
           set deShift $private(star$amerIndex,deShift)
           set private(selectedHip) $k
      } else {
         set raShift ""
         set deShift ""
      }

      #--- j'ajoute l'etoile dans la table des etoiles
      $tkStarTable insert $k [list $name $magnitude $ra_cat $de_cat $raShift $deShift]
   }

   if { [llength $private(hipList)] > 0 } {
      #--- je selectionne l'etoile dans la liste
      $tkStarTable select set $private(selectedHip)
      onSelectStar  $tkStarTable
   } else {
      #--- si pas d'etoile trouvee , je reste sur la meme etoile
      set over [tk_messageBox -type ok -message $caption(modpoi2,wiz3,pas_etoile)]
   }
}

#-------------------------------------------------------------------------------
# onSelectStar
#   selection d'une etoile proche
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::onSelectStar { tkStarTable } {
   variable private

   #--- je recupere la ligne slectionnee par l'utilisateur
   set rowIndex [lindex [$tkStarTable curselection] 0]
   if { $rowIndex == "" } {
      #--- Pas de reference selectionnee
      set private(selectedHip) ""
      return
   } else {
      set private(selectedHip) $rowIndex
   }
}

#-------------------------------------------------------------------------------
# modpoi_wiz4
#   pointage et centrage d'une etoile
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::modpoi_wiz4 { } {
   variable private
   global caption

   if { [winfo exists $private(g,base)] } {
      foreach children [winfo children $private(g,base)] {
          destroy $children
      }
   }

   #--- recupere les information de l'etoile selectionnee
   # contenu de hipRecord :
   #    id       : identifiant hypparcos de l'etoile (nombre entier >0)
   #    mag      : magnitude, si non utilisee = 0.0 (nombre decimal)
   #    ra       : ascension droite (en degres decimaux)
   #    dec      : declinaison (en degres decimaux)
   #    equinox  : date de l'equinoxe, date du jour=now ou date au format ISO8601 des coordonnees de l'objet
   #    epoch    : date de l'epoque d'origine des mouvements propres, inutilisee si mura et mudec sont nuls
   #    mura     : mouvement propre ra, =0 si inconnu (en degres par an)
   #    mudec    : mouvement propre dec, =0 si inconnu (en degres par an)
   #    plx      : parallaxe, =0 si inconnu (en mas=millisecondes d'arc)
   set hipRecord [lindex $private(hipList) $private(selectedHip)]
   set starname [lindex $hipRecord 0]
   set private(starname,actual)  $starname

   set amerIndex $private(amerIndex)
   #--- j'initiale les ecart a zero
   set private(deltah) 0
   set private(deltad) 0

   wm title $private(g,base) "$caption(modpoi2,wiz4,title) [expr $amerIndex +1] : $starname"
   #--- Title
   label $private(g,base).lab_title2 \
      -text "$caption(modpoi2,wiz4,title2) [expr $amerIndex +1] : HIP $starname" \
      -borderwidth 2 -padx 20 -pady 10
   pack $private(g,base).lab_title2 \
      -side top -anchor center \
      -padx 5 -pady 3 -expand 0

   frame $private(g,base).coord -borderwidth 1 -relief ridge
      label $private(g,base).coord.catalogueLabel -text $::caption(modpoi2,wiz4,catalogCoord)
      label $private(g,base).coord.telescopeLabel -text $::caption(modpoi2,wiz4,telescopeCoord)
      label $private(g,base).coord.diffLabel      -text $::caption(modpoi2,wiz4,diff)

      label $private(g,base).coord.raLabel      -width  4 -text $::caption(modpoi2,wiz4,RA)
      entry $private(g,base).coord.catalogueRa  -width 12 -state readonly -justify center \
         -textvariable ::modpoi2::wizard::private(star$amerIndex,raCat)
      entry $private(g,base).coord.telescopeRa  -width 12 -state readonly -justify center \
         -textvariable ::audace(telescope,getra)
      entry $private(g,base).coord.diffRa       -width  8 -state readonly -justify center \
         -textvariable ::modpoi2::wizard::private(deltah)

      label $private(g,base).coord.decLabel     -width  4 -text $::caption(modpoi2,wiz4,Dec)
      entry $private(g,base).coord.catalogueDec -width 12 -state readonly -justify center \
         -textvariable ::modpoi2::wizard::private(star$amerIndex,deCat)
      entry $private(g,base).coord.telescopeDec -width 12 -state readonly -justify center \
         -textvariable ::audace(telescope,getdec)
      entry $private(g,base).coord.diffDec      -width  8 -state readonly -justify center \
         -textvariable ::modpoi2::wizard::private(deltad)

      grid $private(g,base).coord.catalogueLabel -row 0 -column 1 -sticky ew
      grid $private(g,base).coord.telescopeLabel -row 0 -column 2 -sticky ew
      grid $private(g,base).coord.diffLabel      -row 0 -column 3 -sticky ew

      grid $private(g,base).coord.raLabel     -row 1 -column 0 -sticky ew
      grid $private(g,base).coord.catalogueRa -row 1 -column 1 -sticky ew
      grid $private(g,base).coord.telescopeRa -row 1 -column 2 -sticky ew
      grid $private(g,base).coord.diffRa      -row 1 -column 3 -sticky ew

      grid $private(g,base).coord.decLabel     -row 2 -column 0 -sticky ew
      grid $private(g,base).coord.catalogueDec -row 2 -column 1 -sticky ew
      grid $private(g,base).coord.telescopeDec -row 2 -column 2 -sticky ew
      grid $private(g,base).coord.diffDec      -row 2 -column 3 -sticky ew

      grid columnconfig $private(g,base).coord 1 -weight 1
      grid columnconfig $private(g,base).coord 2 -weight 1
      grid columnconfig $private(g,base).coord 3 -weight 1
   pack $private(g,base).coord -side top -anchor center -padx 5 -pady 3 -expand 0

   #--- bouton GOTO / STOP_GOTO
   button $private(g,base).goto -borderwidth 2 -anchor center \
     -text $caption(modpoi2,wiz4,goto)
   pack $private(g,base).goto -side top -anchor center -padx 5 -pady 3 -ipadx 4 -ipady 4 -expand 0

   #--- Label for the comment
   if {$private(centering,mode)=="manu"} {
      set labtext "$caption(modpoi2,wiz4,comment)"
   } else {
      set labtext "$caption(modpoi2,wiz4,comment_auto)"
   }
   label $private(g,base).lab_comment \
      -text "$labtext" -borderwidth 2 \
      -padx 20 -pady 10
   pack $private(g,base).lab_comment \
      -side top -anchor center \
      -padx 5 -pady 3 -expand 0

   if {$private(centering,mode)=="manu"} {
      #--- Frame for direction boutons
      frame $private(g,base).fra -relief flat
      pack $private(g,base).fra -anchor center
      #--- Create the button 'N'
      frame $private(g,base).fra.n -width 54 -borderwidth 0 -relief flat
      pack $private(g,base).fra.n -side top -fill x
      #--- Button-design 'N'
      button $private(g,base).fra.n.canv1PoliceInvariant -borderwidth 4 \
         -text $caption(modpoi2,north) \
         -width 2 \
         -anchor center \
         -relief ridge
      pack $private(g,base).fra.n.canv1PoliceInvariant -in $private(g,base).fra.n -expand 1
      #--- Create the buttons 'E W'
      frame $private(g,base).fra.we -width 54 -borderwidth 0 -relief flat
      pack $private(g,base).fra.we -in $private(g,base).fra -side top -fill x
      #--- Button-design 'E'
      button $private(g,base).fra.we.canv1PoliceInvariant -borderwidth 4 \
         -text $caption(modpoi2,east) \
         -width 2 \
         -anchor center \
         -relief ridge
      pack $private(g,base).fra.we.canv1PoliceInvariant -in $private(g,base).fra.we -expand 1 -side left
      #--- Write the label of speed
      label $private(g,base).fra.we.labPoliceInvariant \
         -textvariable ::audace(telescope,labelspeed) -borderwidth 0 -relief flat -padx 20
      pack $private(g,base).fra.we.labPoliceInvariant -in $private(g,base).fra.we -expand 1 -side left
      #--- Button-design 'W'
      button $private(g,base).fra.we.canv2PoliceInvariant -borderwidth 4 \
         -text $caption(modpoi2,west) \
         -width 2 \
         -anchor center \
         -relief ridge
      pack $private(g,base).fra.we.canv2PoliceInvariant -in $private(g,base).fra.we -expand 1 -side right
      #--- Create the button 'S'
      frame $private(g,base).fra.s -width 54 -borderwidth 0 -relief flat
      pack $private(g,base).fra.s -in $private(g,base).fra -side top -fill x
      #--- Button-design 'S'
      button $private(g,base).fra.s.canv1PoliceInvariant -borderwidth 4 \
         -text $caption(modpoi2,south) \
         -width 2 \
         -anchor center \
         -relief ridge
      pack $private(g,base).fra.s.canv1PoliceInvariant -in $private(g,base).fra.s -expand 1
      #---
      set zone(n) $private(g,base).fra.n.canv1PoliceInvariant
      set zone(e) $private(g,base).fra.we.canv1PoliceInvariant
      set zone(w) $private(g,base).fra.we.canv2PoliceInvariant
      set zone(s) $private(g,base).fra.s.canv1PoliceInvariant
      bind $private(g,base).fra.we.labPoliceInvariant <ButtonPress-1> { ::modpoi2::wizard::modpoi_speed }
      #--- Cardinal moves
      bind $zone(e) <ButtonPress-1>   { ::modpoi2::wizard::modpoi_move e }
      bind $zone(e) <ButtonRelease-1> { ::modpoi2::wizard::modpoi_stop e }
      bind $zone(w) <ButtonPress-1>   { ::modpoi2::wizard::modpoi_move w }
      bind $zone(w) <ButtonRelease-1> { ::modpoi2::wizard::modpoi_stop w }
      bind $zone(s) <ButtonPress-1>   { ::modpoi2::wizard::modpoi_move s }
      bind $zone(s) <ButtonRelease-1> { ::modpoi2::wizard::modpoi_stop s }
      bind $zone(n) <ButtonPress-1>   { ::modpoi2::wizard::modpoi_move n }
      bind $zone(n) <ButtonRelease-1> { ::modpoi2::wizard::modpoi_stop n }

      #--- Frame for bottom buttons
      frame $private(g,base).fra_bottom
      #--- PREVIOUS button
      button $private(g,base).fra_bottom.but_prev \
         -text $caption(modpoi2,wiz4,prev) -borderwidth 2 \
         -padx 10 -pady 10 -command { ::modpoi2::wizard::modpoi_wiz2 }
      pack $private(g,base).fra_bottom.but_prev \
         -side left -anchor se \
         -padx 5 -pady 5 -expand 0
      #--- NEXT button
      button $private(g,base).fra_bottom.but_next \
         -text $caption(modpoi2,wiz4,next) -borderwidth 2 \
         -padx 10 -pady 10 -command { ::modpoi2::wizard::modpoi_coord ; ::modpoi2::wizard::modpoi_wiz2 }
      pack $private(g,base).fra_bottom.but_next \
         -side right -anchor se \
         -padx 5 -pady 5 -expand 0
      pack $private(g,base).fra_bottom \
         -side bottom -anchor center \
         -padx 5 -pady 5 -expand 0
      #--- NON VISIBLE button
      ###button $private(g,base).but_cannot \
      ###   -text $caption(modpoi2,wiz4,cannot) -borderwidth 2 \
      ###   -padx 20 -pady 3 -command "::modpoi2::wizard::modpoi_wiz3 $amerIndex"
      ###pack $private(g,base).but_cannot \
      ###   -padx 10 -pady 0 -expand 0 -fill x
   } else {
      label $private(g,base).lab_dist \
         -text " " -borderwidth 2 \
         -padx 10 -pady 10
      pack $private(g,base).lab_dist \
         -side top -anchor center \
         -padx 5 -pady 3 -expand 0
   }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private(g,base)

   #--   inhibe les commandes (liberees si un tel est actif)
   $private(g,base).goto configure -state disabled
   ::modpoi2::wizard::modpoi_setState disabled

   set pressure    $::audace(meteo,obs,pressure)
   set temperature [ expr $::audace(meteo,obs,temperature) + 273.15 ]
   set humidity    $::audace(meteo,obs,humidity)
   set date        [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]

   #--- je calcule les coordonnées apparentes
   #-- mc_hip2tel List_coords Date_UTC Home Pressure Temperature ?Type List_ModelSymbols List_ModelValues
   # @param
   #    List_coords =
   #       id       : identifiant hypparcos de l'etoile (nombre entier >0)
   #       mag      : magnitude, si non utilisee = 0.0 (nombre decimal)
   #       ra       : ascension droite (en degres decimaux)
   #       dec      : declinaison (en degres decimaux)
   #       equinox  : date de l'equinoxe, date du jour=now ou date au format ISO8601 des coordonnees de l'objet
   #       epoch    : date de l'epoque d'origine des mouvements propres, inutilisee si mura et mudec sont nuls
   #       mura     : mouvement propre ra, =0 si inconnu (en degres par an)
   #       mudec    : mouvement propre dec, =0 si inconnu (en degres par an)
   #       plx      : parallaxe, =0 si inconnu (en mas=millisecondes d'arc)
   #    Date_UTC    : date TU de l'observation : [::audace::date_sys2ut now]
   #    Home        : position GPS de l'observatoire
   #    Pressure    : pression atmospherique, 101325 Pa, audace(meteo,obs,pressure)
   #    Temperature : temperature de l'air, 290 K, audace(meteo,obs,temperature)
   #    Humidité    : hygrometrie de l'air, %, audace(meteo,obs,humidity)
   #    List_ModelSymbols
   #    List_ModelValues
   # @return
   #  0  rat   RA  apparent
   #  1  det   DEC apparent
   #  2  hat   HA  apparent
   #  3  azt   AZ  apparent
   #  4  ht    EL  apparent
   #  5  dra   delta apres correction modele de pointage
   #  6  ddec  delta apres correction modele de pointage
   #  7  dha   delta apres correction modele de pointage
   #  8  daz   delta apres correction modele de pointage
   #  9  dh    delta apres correction modele de pointage
   #  10 ra    RA  apres correction modele de pointage
   #  11 dec   DEC apres correction modele de pointage
   #  12 ha    HA  apres correction modele de pointage
   #  13 az    AZ  apres correction modele de pointage
   #  14 h     EL  apres correction modele de pointage

   set coords [mc_hip2tel $hipRecord $date $private(home) $pressure $temperature -humidity $humidity]
   set raApp [lindex $coords 0]
   set deApp [lindex $coords 1]
   set haApp [lindex $coords 2]
   set azApp [lindex $coords 3]
   set elApp [lindex $coords 4]

   #--- je memorise les coordonnees catalogue pour les afficher
   set private(star$amerIndex,raCat) [mc_angle2hms [lindex $hipRecord 2] 360 zero 0 auto string]
   set private(star$amerIndex,deCat) [mc_angle2dms [lindex $hipRecord 3] 90  zero 0 + string]
   set private(star$amerIndex,eqCat) [lindex $hipRecord 4]
   #--- je memorise les coordonnes apparentes pour le GOTO
   set private(star$amerIndex,date)  $date
   set private(star$amerIndex,raApp) [mc_angle2hms $raApp 360 zero 0 auto string]
   set private(star$amerIndex,deApp) [mc_angle2dms $deApp 90  zero 0 + string]
   set private(star$amerIndex,haApp) [mc_angle2dms $haApp 90  zero 0 + string]
   set private(star$amerIndex,azApp) $azApp
   set private(star$amerIndex,elApp) $elApp
   #--- je memorie les conditions d'observation
   set private(star$amerIndex,pressure)    $pressure
   set private(star$amerIndex,temperature) $temperature

   if {$::audace(telNo) ==0} {
      ::confTel::run
      vwait ::audace(telNo)
   }
   #--   libere les commandes
   $private(g,base).goto configure -state normal
   ::modpoi2::wizard::modpoi_setState normal

   #--- pointage de l'étoile
   ::modpoi2::wizard::modpoi_goto

   #--- Case of autocentering
   if {$private(centering,mode)=="auto"} {
      #--- Automatic centering procedure
      update
      after 1000
      #--- Call the procedure...
      ::modpoi2::wizard::modpoi_autocentering
      #--- Call back the main menu
      ::modpoi2::wizard::modpoi_coord
      ::modpoi2::wizard::modpoi_wiz2
   }
}

#-------------------------------------------------------------------------------
# modpoi_wiz5
#   calcule les coefficients
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::modpoi_wiz5 { } {
   variable private
   global caption

   if { [winfo exists $private(g,base)] } {
      foreach children [winfo children $private(g,base)] {
          destroy $children
      }
   }
   wm title $private(g,base) $caption(modpoi2,wiz5,title)

   set starList ""
   for {set k 0} {$k < $private(stars,nb)} {incr k} {
      if { $private(star$k,starname) != "" && $private(star$k,selected) == 1 } {
         #--- je cree la liste  HA DEC dHA dDEC ( attention : dHA = -dRA )
         lappend starList [list $private(star$k,haApp) $private(star$k,deApp) \
         [expr - $private(star$k,raShift)] $private(star$k,deShift) ]
      }
   }

   if { [llength $starList ] < 6 } {
       #--- nombre incorrect d'etoiles
       set choice [ tk_messageBox -message "$::caption(modpoi2,wiz1b,nstars1) : $private(stars,nb)" \
          -title $::caption(modpoi2,wiz1b,warning) -icon question -type ok ]
       return
   }

   #--- Compute the coefficients
   set res [::modpoi2::process::computeCoefficient $starList $private(home) $private(symbols) ]
   lassign $res private(coefficients) private(chisquare) private(covar)

   #--   interprete le X²
   set nbValues $private(stars,nb)
   set nbParameters [llength $private(symbols)]
   lassign [::modpoi2::process::computePconf $private(chisquare) $nbValues $nbParameters] p kappa

   lassign $private(coefficients) ih id np ch me ma fo mt daf tf
   set res1 "\
   [lindex $private(symbols) 0] = [format "%.2f" $ih] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 1 1],2)]])\n\
   ($caption(modpoi2,wiz5,IH))\n\n\
   [lindex $private(symbols) 1] = [format "%.2f" $id] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 2 2],2)]])\n\
   ($caption(modpoi2,wiz5,ID))\n\n\
   [lindex $private(symbols) 2] = [format "%.2f" $np] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 3 3],2)]])\n\
   ($caption(modpoi2,wiz5,NP))\n\n\
   [lindex $private(symbols) 3] = [format "%.2f" $ch] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 4 4],2)]])\n\
   ($caption(modpoi2,wiz5,CH))\n\n\
   [lindex $private(symbols) 4] = [format "%.2f" $me] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 5 5],2)]])\n\
   ($caption(modpoi2,wiz5,ME))\n\n\
   [lindex $private(symbols) 5] = [format "%.2f" $ma] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 6 6],2)]])\n\
   ($caption(modpoi2,wiz5,MA))\n\n\
   [lindex $private(symbols) 6] = [format "%.2f" $fo] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 7 7],2)]])\n\
   ($caption(modpoi2,wiz5,FO))\n\n\
   [lindex $private(symbols) 7] = [format "%.2f" $mt] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 8 8],2)]])\n\
   ($caption(modpoi2,wiz5,MT))\n\n\
   [lindex $private(symbols) 8] = [format "%.2f" $daf] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 9 9],2)]])\n\
   ($caption(modpoi2,wiz5,DAF))\n\n\
   [lindex $private(symbols) 9] = [format "%.2f" $tf] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 10 10],2)]])\n\
   ($caption(modpoi2,wiz5,TF))\n\n\
   [format $caption(modpoi2,interp) $private(chisquare) $p $kappa]\n\n"

   #--- je calcule des ecarts en appliquant le modele
   for {set k 0} {$k < $private(stars,nb)} {incr k} {
      if { $private(star$k,starname) != "" && $private(star$k,selected) == 1 } {
         set hipRecord [list $private(star$k,starname) "0" \
            [mc_angle2deg $private(star$k,raCat)] \
            [mc_angle2deg $private(star$k,deCat)] \
            $private(star$k,eqCat) 0 0 0 0 \
         ]
         set coords [mc_hip2tel $hipRecord $private(star$k,date) $private(home) \
            $private(star$k,pressure) $private(star$k,temperature) \
            $private(symbols) $private(coefficients) \
         ]
         set private(star$k,raShiftTest) [expr  60.0 * [lindex $coords 5]] ; #--- dra
         set private(star$k,deShiftTest) [expr  60.0 * [lindex $coords 6]] ; #--- ddec
      } else {
         set private(star$k,raShiftTest) ""
         set private(star$k,deShiftTest) ""
      }
   }

   #--- Display name
   ###label $private(g,base).lab_name \
   ###   -text "[ file rootname [ file tail $private(filename) ] ]" -borderwidth 2 \
   ###   -padx 20 -pady 10
   ###pack $private(g,base).lab_name \
   ###   -side top -anchor center \
   ###   -padx 5 -pady 3 -expand 0
   #--- Display the results
   label $private(g,base).lab_res1 \
      -text "$res1" -borderwidth 2 \
      -padx 20 -pady 10
   pack $private(g,base).lab_res1 \
      -side top -anchor center \
      -padx 5 -pady 3 -expand 0
   #--- Frame for bottom buttons
   frame $private(g,base).fra_bottom
   #--- PREVIOUS button
   button $private(g,base).fra_bottom.but_prev \
      -text $caption(modpoi2,wiz5,prev) -borderwidth 2 \
      -padx 10 -pady 10 -command { ::modpoi2::wizard::modpoi_wiz2 }
   pack $private(g,base).fra_bottom.but_prev \
      -side left -anchor se \
      -padx 5 -pady 5 -expand 0
   #--- NEXT button
   button $private(g,base).fra_bottom.but_next \
      -text $caption(modpoi2,wiz5,next) -borderwidth 2 \
      -padx 10 -pady 10 -command { ::modpoi2::wizard::modpoi_wiz6 }
   pack $private(g,base).fra_bottom.but_next \
      -side right -anchor se \
      -padx 5 -pady 5 -expand 0
   pack $private(g,base).fra_bottom \
      -side bottom -anchor center \
      -padx 5 -pady 5 -expand 0
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private(g,base)
}

#-------------------------------------------------------------------------------
# modpoi_wiz5b
#   affiche le resultat du calcul du modele de pointage
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::modpoi_wiz5b { } {
   variable private
   global caption

::console::disp "modpoi_wiz5b\n"

   if { [winfo exists $private(g,base)] } {
      foreach children [winfo children $private(g,base)] {
          destroy $children
      }
   }
   #--- New toplevel
   wm title $private(g,base) $caption(modpoi2,wiz5,title1)
   #--- Compute the coefficients
::console::disp "$private(coefficients)\n"
   #set res [::modpoi2::process::computeCoefficient ]
#::console::disp "res $res\n"
   #set private(coefficients) [lindex $res 0]
   #set private(chisquare) [lindex $res 1]
   #set private(covar) [lindex $res 2]

   #--   interprete le X²
   set nbValues $private(stars,nb)
   set nbParameters [llength $private(symbols)]
   lassign [::modpoi2::process::computePconf $private(chisquare) $nbValues $nbParameters] p kappa

   lassign $private(coefficients) ih id np ch me ma fo mt daf tf
   set num [catch {
       set res1 "\
       IH = [format "%.2f" $ih] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 1 1],2)]])\n\
       ($caption(modpoi2,wiz5,IH))\n\n\
       ID = [format "%.2f" $id] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 2 2],2)]])\n\
       ($caption(modpoi2,wiz5,ID))\n\n\
       NP = [format "%.2f" $np] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 3 3],2)]])\n\
       ($caption(modpoi2,wiz5,NP))\n\n\
       CH = [format "%.2f" $ch] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 4 4],2)]])\n\
       ($caption(modpoi2,wiz5,CH))\n\n\
       ME = [format "%.2f" $me] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 5 5],2)]])\n\
       ($caption(modpoi2,wiz5,ME))\n\n\
       MA = [format "%.2f" $ma] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 6 6],2)]])\n\
       ($caption(modpoi2,wiz5,MA))\n\n\
       FO = [format "%.2f" $fo] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 7 7],2)]])\n\
       ($caption(modpoi2,wiz5,FO))\n\n\
       HF = [format "%.2f" $mt] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 8 8],2)]])\n\
       ($caption(modpoi2,wiz5,MT))\n\n\
       DAF = [format "%.2f" $daf] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 9 9],2)]])\n\
       ($caption(modpoi2,wiz5,DAF))\n\n\
       TF = [format "%.2f" $tf] arcmin ([format "%.2f" [expr pow([gsl_mindex $private(covar) 10 10],2)]])\n\
       ($caption(modpoi2,wiz5,TF))\n\n\
       [format $caption(modpoi2,interp) $private(chisquare) $p $kappa]\n\n"
    } msg]
   if { $num!="1"} {
      #--- Display name
      if { [ info exists private(modpoi_choisi) ] == "1" } {
         set name $private(modpoi_choisi)
      } else {
         set name $private(filename)
      }
      label $private(g,base).lab_name \
         -text "[ file rootname [ file tail $name ] ]" -borderwidth 2 \
         -padx 20 -pady 10
      pack $private(g,base).lab_name \
         -side top -anchor center \
         -padx 5 -pady 3 -expand 0
      #--- Display the results
      label $private(g,base).lab_res1 \
         -text "$res1" -borderwidth 2 \
         -padx 20 -pady 10
      pack $private(g,base).lab_res1 \
         -side top -anchor center \
         -padx 5 -pady 3 -expand 0
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $private(g,base)
   } else {
      destroy $private(g,base)
      tk_messageBox -title "$caption(modpoi2,wiz1b,warning)" -message "$caption(modpoi2,modele,editer)" -icon error
   }
}

#-------------------------------------------------------------------------------
# modpoi_wiz6
#   termine le widzard
#   copie les resultats dans la fenetre principale
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::modpoi_wiz6 { } {
   variable private

   #--- je copie la liste des points d'amer dans le fenetre principale
   #---    ( amerAz amerEl name raCat deCat equinoxCat date raObs deObs pressure temperature )
   set starList ""
   for {set k 0} {$k < $private(stars,nb)} {incr k} {
      lappend starList [list \
         $private(star$k,amerAz) $private(star$k,amerEl) \
         $private(star$k,starname) \
         $private(star$k,raCat) $private(star$k,deCat) $private(star$k,eqCat) \
         $private(star$k,date) $private(star$k,raObs) $private(star$k,deObs) \
         $private(star$k,pressure) $private(star$k,temperature) \
      ]
   }

   #--- j'affiche les coefficients dans la fenetre principale
   ::modpoi2::main::modifyModel $private(visuNo) $starList $private(symbols) $private(coefficients) $private(covar) $private(chisquare)

   hideMap $private(visuNo)
   #--- je ferme la fenetre
   ::modpoi2::wizard::closeWindow $private(visuNo)
}

#------------------------------------------------------------
# checkCamera
#    verifie les parametres de la camera
# @private
#------------------------------------------------------------
proc ::modpoi2::wizard::checkCamera {  } {
   variable private

   if { $private(centering,check) == "1" } {
      if { [ ::cam::list ] == "" } {
         #--- Ouverture de la fenetre de selection des cameras
         ::confCam::run
         tkwait window $::audace(base).confCam
      }
      #---
      if {[::cam::list]!=""} {
         set dimxy [cam$::audace(camNo) nbpix]
         set private(centering,xc) [expr int([lindex $dimxy 0]/2.)]
         set private(centering,yc) [expr int([lindex $dimxy 1]/2.)]
         set private(centering,binning) $::conf(modpoi,wizard,centering,binning)
         set private(centering,exptime) $::conf(modpoi,wizard,centering,exptime)
      } else {
         set private(centering,xc) 0
         set private(centering,yc) 0
         set private(centering,binning) 1
         set private(centering,exptime) 1
      }
   }
}

#------------------------------------------------------------
# checkStarNb
#    recherche les points d'amer
#    et verifie le nombre d'etoiles
# @private
#------------------------------------------------------------
proc ::modpoi2::wizard::checkStarNb { } {
   variable private

   #--- Calcule le nombre de points d'amer
   #  chaque point d'amer contient : { ra dec ha az el }
   set date [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]
   set amerList [mc_listamers EQUATORIAL $private(stars,haNb) $private(stars,deNb) $date $private(home) * * * * $private(horizons)]
   set private(stars,nb) [llength $amerList]

   for { set k 0 } { $k < $private(stars,nb) } { incr k } {
      set private(star$k,amerAz)      [lindex [lindex $amerList $k] 3]
      set private(star$k,amerEl)      [lindex [lindex $amerList $k] 4]
      set private(star$k,starname)    ""
      set private(star$k,raCat)       ""
      set private(star$k,deCat)       ""
      set private(star$k,eqCat)       ""
      set private(star$k,date)        ""
      set private(star$k,raObs)       ""
      set private(star$k,deObs)       ""
      set private(star$k,pressure)    ""
      set private(star$k,temperature) ""

      set private(star$k,raApp)       ""
      set private(star$k,deApp)       ""
      set private(star$k,azApp)       ""
      set private(star$k,elApp)       ""
      set private(star$k,haApp)       ""
      set private(star$k,raShift)     ""
      set private(star$k,deShift)     ""
      set private(star$k,raShiftTest) ""
      set private(star$k,deShiftTest) ""
      set private(star$k,selected)    0
   }

   set private(coefficients)          ""
   set private(chisquare)             ""
   set private(covar)                 ""

   if { ( $private(stars,nb) >= "6" ) && ( $private(stars,nb) <= "400" ) } {
      set ::conf(modpoi,wizard,haNb) $private(stars,haNb)
      set ::conf(modpoi,wizard,deNb) $private(stars,deNb)

      if { $private(centering,check) == "1" } {
         set ::conf(modpoi,wizard,centering,xc)       $private(centering,xc)
         set ::conf(modpoi,wizard,centering,yc)       $private(centering,yc)
         set ::conf(modpoi,wizard,centering,accuracy) $private(centering,accuracy)
         set ::conf(modpoi,wizard,centering,t0)       $private(centering,t0)
         set ::conf(modpoi,wizard,centering,binning)  $private(centering,binning)
         set ::conf(modpoi,wizard,centering,exptime)  $private(centering,exptime)
         set ::conf(modpoi,wizard,centering,nbmean)   $private(centering,nbmean)
      }

      if { $private(centering,check)==0 } {
         modpoi_wiz2
      } else {
         modpoi_wiz1c
      }
   } else {
      #--- nombre incorrect d'etoiles
      set choice [ tk_messageBox -message "$::caption(modpoi2,wiz1b,nstars1) : $private(stars,nb)" \
         -title $::caption(modpoi2,wiz1b,warning) -icon question -type ok ]
      if { $choice == "ok" } {
         set private(stars,nb) ""
      }
   }
}

#-------------------------------------------------------------------------------
# displayMap
#   affiche la carte d'horizon avec les etoiles
# parametre : N° visu
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::displayMap { visuNo } {
   variable private

   #--- Visualise la carte des points d'amer
   set figureNo [::plotxy::figure $visuNo]
   ::plotxy::clf $figureNo

   set num 0
   for {set k 0} {$k < $private(stars,nb)} {incr k} {
      if { $private(star$k,starname) != "" } {
         #--- Visualise les etoiles pointees si elle existe
         ::plotxy::plot $private(star$k,azApp) $private(star$k,elApp) g* 8
         ::plotxy::hold on
         #--- j'ajoute le numero du point d'amer dans le label
         $::plotxy(fig$figureNo,parent).xy element configure line_fig${figureNo}_${num} -label $k
         #--- bind de l'evenement  <ButtonPress-1>
         $::plotxy(fig$figureNo,parent).xy element bind line_fig${figureNo}_${num} <ButtonPress-1> { ::modpoi2::wizard::onButtonPressMap %x %y   }
         incr num
      }
      #--- Visualise le point d'amer
      ::plotxy::plot $private(star$k,amerAz) $private(star$k,amerEl) ro- 8
      ::plotxy::hold on

      #--- j'ajoute le numero du point d'amer dans le label
      $::plotxy(fig$figureNo,parent).xy element configure line_fig${figureNo}_${num} -label $k
      #--- bind de l'evenement  <ButtonPress-1>
      $::plotxy(fig$figureNo,parent).xy element bind line_fig${figureNo}_${num} <ButtonPress-1> { ::modpoi2::wizard::onButtonPressMap %x %y   }
      incr num
   }

   #--- visualisation de l'horizon
   set x [lindex $private(horizons) 0]
   set y [lindex $private(horizons) 1]
   ::plotxy::plot $x $y r
   set horizonName [::horizon::getHorizonName]
   ::plotxy::title "$horizonName $::audace(posobs,observateur,gps)"
   ::plotxy::xlabel "$::caption(modpoi2,azimutDeg)"
   ::plotxy::ylabel "$::caption(modpoi2,elevationDeg)"
   ::plotxy::position {20 20 800 400}

   $::plotxy(fig$figureNo,parent).xy axis configure x -stepsize 45
   $::plotxy(fig$figureNo,parent).xy grid configure -hide no -dashes { 1 2 }
   $::plotxy(fig$figureNo,parent).xy axis configure y -stepsize 15 -min 0 -max 90
   $::plotxy(fig$figureNo,parent).xy axis configure x2 -stepsize 45
   $::plotxy(fig$figureNo,parent).xy axis configure y2 -stepsize 15 -min 0 -max 90
}

#-------------------------------------------------------------------------------
# hideMap
#   ferme la carte d'horizon avec les etoiles
# parametre : N° visu
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::hideMap { visuNo } {
   ::plotxy::clf $visuNo
}

#-------------------------------------------------------------------------------
# onButtonPressMap
#
# @private
# parametre :
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::onButtonPressMap { x y } {
   variable private

   if { [winfo exists $private(g,base).amer.table ] } {
      #--- je cherche l'element qui est pres du curseur de la souris
      if {[$::audace(base).plotxy1.xy element closest $x $y click]} {
          #--- je recupere le numero point d'amer qui est dans le label de l'element
          set k [$::audace(base).plotxy1.xy element cget $click(name) -label]
          if { $k != "" } {
             #--- je recupere les coordonnees du point d'amer
             set amerAz $private(star$k,amerAz)
             set amerEl $private(star$k,amerEl)
             if { $private(star$k,starname)!="" } {
                set starAz $private(star$k,azApp)
                set starEl $private(star$k,elApp)
             } else {
                set starAz ""
                set starEl ""
             }

             #--- je selectionne le point d'amer dans la table
             $private(g,base).amer.table selection clear 0 end
             $private(g,base).amer.table selection set $k
             onSelectAmer $private(g,base).amer.table
             $private(g,base).amer.table see $k

             #--- j'affiche un cercle autour du point d'amer dans le graphe
             showSelectedAmer $amerAz $amerEl $starAz $starEl
         }
      }
   }
}

#------------------------------------------------------------
# showSelectedAmer
#   trace un cercle bleu autour du point d'amer
#   et trace un cercle bleu autour de l'étoile associée
#
# @private
# @param amerAz azimuth du point d'amer (en degres)
# @param amerEl hauteur du point d'amer (en degres)
# @param starAz azimuth de l'etoile associée (en degres)
# @param starEl hauteur de l'etoile associée  (en degres)
#------------------------------------------------------------
proc ::modpoi2::wizard::showSelectedAmer { amerAz amerEl starAz starEl} {
   if { [winfo exists $::audace(base).plotxy1] == 1 } {
      if { [$::audace(base).plotxy1.xy element exists selectedAmer ] == 1 } {
         $::audace(base).plotxy1.xy element  delete selectedAmer
      }
      if { [$::audace(base).plotxy1.xy element exists selectedStar ] == 1 } {
         $::audace(base).plotxy1.xy element  delete selectedStar
      }
         $::audace(base).plotxy1.xy element create selectedAmer -xdata $amerAz -ydata $amerEl  \
         -outline blue  -fill "" -outlinewidth  3

      if { $starAz != "" && $starEl != "" } {
         $::audace(base).plotxy1.xy element create selectedStar -xdata $starAz -ydata $starEl  \
         -outline blue  -fill "" -outlinewidth  3
      }
   }
}

#------------------------------------------------------------
# hideSelectedAmer
#   efface le cercle bleu autour du point d'amer et de l'étoile associée
# @private
# @param azimut azimuth du point d'amer (en degres)
# @param elevation hauteur du point d'amer (en degres)
#------------------------------------------------------------
proc ::modpoi2::wizard::hideSelectedAmer { } {

   if { [$::audace(base).plotxy1.xy element exists selectedAmer ] == 1 } {
      $::audace(base).plotxy1.xy element  delete selectedAmer
   }
   if { [$::audace(base).plotxy1.xy element exists selectedStar ] == 1 } {
      $::audace(base).plotxy1.xy element  delete selectedStar
   }
}

################################################################################
#  Commandes du telescope
################################################################################

#-------------------------------------------------------------------------------
# modpoi_goto
#   demarre un GOTO du telescope
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::modpoi_goto { } {
   variable private

   #--- je transforme le bouton GOTO en bouton STOP GOTO
   $private(g,base).goto configure -text $::caption(modpoi2,wiz4,stopGoto) \
      -command "::modpoi2::wizard::modpoi_stopGoto"
   ::modpoi2::wizard::modpoi_setState disabled

   set amerIndex $private(amerIndex)
   if { $::audace(telNo) != 0} {
      #--- je recupere les coordonnees catlogue
      set raCat $private(star$amerIndex,raCat)
      set deCat $private(star$amerIndex,deCat)
      set blocking 0
      #--- je lance la commande goto en mode non bloquant
      set catchError [ catch {
         ::telescope::goto [list $raCat $deCat] $blocking
      } ]
      if { $catchError != 0 } {
         ::tkutil::displayErrorInfoTelescope "GOTO Error"
      }
   } else {
      ::confTel::run
      vwait ::audace(telNo)
   }

   #--- je transforme le bouton STOP GOTO en bouton GOTO
   $private(g,base).goto configure -text $::caption(modpoi2,wiz4,goto) \
      -command "::modpoi2::wizard::modpoi_goto"
   #--- j'active les boutons N S E W
   ::modpoi2::wizard::modpoi_setState normal
   ::telescope::afficheCoord

   #--- j'affiche l'ecart en arcminute (ecart enre les coordonnees J2000.0 du catalogue et du telescope pour avoir un apercu)
   set radecObs [tel$::audace(telNo) radec coord -equinox NOW]
   set private(deltah) [format "%.3f" [expr 60.0 * [mc_anglescomp [lindex $radecObs 0] - $private(star$amerIndex,raApp)]]]
   set private(deltad) [format "%.3f" [expr 60.0 * [mc_anglescomp [lindex $radecObs 1] - $private(star$amerIndex,deApp)]]]

}

#-------------------------------------------------------------------------------
# modpoi_stopGoto
#   arret un GOTO du telescope
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::modpoi_stopGoto {  } {
   variable private
   global caption

   #--- j'arrete le goto
   ::telescope::stopGoto ""

   #--- je transforme le bouton STOP GOTO en bouton GOTO
   $private(g,base).goto configure -text $caption(modpoi2,wiz4,goto) \
      -command "::modpoi2::wizard::modpoi_goto"
   ::modpoi2::wizard::modpoi_setState normal

   #--- j'affiche l'ecart en arcminute (ecart enre les coordonnees J2000.0 du catalogue et du telescope pour avoir un apercu)
   set radecObs [tel$::audace(telNo) radec coord -equinox NOW]
   set amerIndex $private(amerIndex)
   set private(deltah) [format "%.3f" [expr 60.0 * [mc_anglescomp [lindex $radecObs 0] - $private(star$amerIndex,raApp)]]]
   set private(deltad) [format "%.3f" [expr 60.0 * [mc_anglescomp [lindex $radecObs 1] - $private(star$amerIndex,deApp)]]]
}

#-------------------------------------------------------------------------------
# modpoi_setState
#   gere l'etat des boutons de la raquette
# @private
# parametre : state (normal|disabled}
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::modpoi_setState { state } {
   variable private

   set base $private(g,base)

   $base.fra.n.canv1PoliceInvariant  configure -state $state
   $base.fra.we.canv1PoliceInvariant configure -state $state
   $base.fra.we.canv2PoliceInvariant configure -state $state
   $base.fra.s.canv1PoliceInvariant  configure -state $state
   $base.fra.we.labPoliceInvariant   configure -state $state
   $base.fra_bottom.but_prev         configure -state $state
   $base.fra_bottom.but_next         configure -state $state
}

#-------------------------------------------------------------------------------
# modpoi_move
#   demarre un deplacement manuel du telescope
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::modpoi_move { { direction E } } {
   ::telescope::move $direction
}

#-------------------------------------------------------------------------------
# modpoi_stop
#   arrete un deplacement manuel du telescope
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::modpoi_stop { { direction "" } } {
   variable private

   ::telescope::stop $direction

   #--- j'affichage l'ecart (ecart entre les coordonnees apparentes du catalogue et du telescope pour avoir un apercu)
   set amerIndex $private(amerIndex)
   set radecObs [tel$::audace(telNo) radec coord -equinox NOW]
   set private(deltah) [format "%.3f" [expr 60.0 * [mc_anglescomp [lindex $radecObs 0] - $private(star$amerIndex,raApp)]]]
   set private(deltad) [format "%.3f" [expr 60.0 * [mc_anglescomp [lindex $radecObs 1] - $private(star$amerIndex,deApp)]]]

}

#-------------------------------------------------------------------------------
# modpoi_speed
#   incremente la vitesse de correction du telescope
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::modpoi_speed { } {
   ::telescope::incrementSpeed
}

#-------------------------------------------------------------------------------
# modpoi_coord
#   recupere les coordonnées observees (sans modele de pointage actif)
#   calcule les ecarts des coordonnees
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::modpoi_coord { } {
   variable private

   set k $private(amerIndex)
   if { [ ::tel::list ] == "" } {
      #--- le telescope n'est pas connecte, je recupere les coordonnees apparentes
      set private(star$k,raObs)  $private(star$k,raApp)
      set private(star$k,deObs) $private(star$k,deApp)
   } else {
      set radecObs [tel$::audace(telNo) radec coord -equinox NOW]
      set private(star$k,raObs) [lindex $radecObs 0]
      set private(star$k,deObs) [lindex $radecObs 1]
   }

   #--- je calcule l'ecart en arcmin entre les coordonnees apparentes de l'etoile et du télescope
   set private(star$k,raShift) [expr 60.0 * [mc_anglescomp $private(star$k,raObs)  - $private(star$k,raApp) ]]
   set private(star$k,deShift) [expr 60.0 * [mc_anglescomp $private(star$k,deObs)  - $private(star$k,deApp) ]]

   #--- je renseigne le nom dans le tableau.
   #--- ATTENTION: la presence du nom dans de tableau sert de repere pour savoir si la mesure d'ecart est faite
   set private(star$k,starname) $private(starname,actual)
   set private(star$k,selected) 1

   #--- je calcule l'ecart de test
   if { $private(coefficients) != "" } {
      set hipRecord [list $private(star$k,starname) "0" \
                        [mc_angle2deg $private(star$k,raCat)] \
                        [mc_angle2deg $private(star$k,deCat)] \
                        $private(star$k,eqCat) 0 0 0 0 \
                     ]
      set coords [mc_hip2tel $hipRecord $private(star$k,date) $private(home) \
         $private(star$k,pressure) $private(star$k,temperature) \
         $private(symbols) $private(coefficients) \
      ]
      #--- je recupere l'ecart en arcmin
      set private(star$k,raShiftTest) [expr  60.0 * [lindex $coords 5]] ; #--- dra
      set private(star$k,deShiftTest) [expr  60.0 * [lindex $coords 6]] ; #--- ddec
   } else {
      set private(star$k,raShiftTest) ""
      set private(star$k,deShiftTest) ""
   }

   #--- j'enregistre la liste des étoiles et le modèle dans un fichier temporaire
   saveModel
}

#-------------------------------------------------------------------------------
# closeWindow
#   memorise la position de la fenetre avant da fermeture
#  parametre : N° visu
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::closeWindow { visuNo } {
   variable private

   #--- j'enregistre la position courante de la fenetre
   set geometry [ wm geometry $private(g,base) ]
   set deb [ expr 1 + [ string first + $private(wm_geometry) ] ]
   set fin [ string length $private(wm_geometry) ]
   set ::conf(modpoi,wizard,position) "+[ string range $private(wm_geometry) $deb $fin ]"

   #--- je ferme la fenetre de la carte
   ::modpoi2::wizard::hideMap $visuNo
   #--- je supprime la fenetre
   destroy $private(g,base)

}

#-------------------------------------------------------------------------------
# saveModel
#   enregistre le modele dans un fichier temporaire temp.xml
# @private
#-------------------------------------------------------------------------------
proc ::modpoi2::wizard::saveModel { } {
   variable private

   set fileName [ file join $::audace(rep_home) modpoi temp.xml ]
   set date [clock format [clock seconds] -timezone :UTC -format "%Y-%m-%dT%H:%M:%S"]
   set comment "sauvegarde temporaire automatique"
   set starList ""
   set refraction 0
   for {set k 0} {$k < $private(stars,nb)} {incr k} {
      lappend starList [list \
         $private(star$k,amerAz) $private(star$k,amerEl) \
         $private(star$k,starname) \
         $private(star$k,raCat) $private(star$k,deCat) $private(star$k,eqCat) \
         $private(star$k,date) $private(star$k,raObs) $private(star$k,deObs) \
         $private(star$k,pressure) $private(star$k,temperature) \
      ]
   }

   ::modpoi2::main::saveModel $fileName \
      $date  \
      $comment \
      $starList \
      $private(symbols) $private(coefficients) \
      $private(covar) $private(chisquare) \
      $refraction

}

