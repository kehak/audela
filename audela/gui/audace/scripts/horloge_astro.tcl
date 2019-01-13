#
# Fichier : horloge_asro.tcl
# Description : Horloge de l'astronome
# Auteur : Alain KLOTZ
# Mise à jour $Id: horloge_astro.tcl 9719 2013-07-09 21:43:12Z robertdelmas $
#

#---
global audace
global caption
global base
global paramhorloge

#--- Chargement des captions
source [ file join $audace(rep_scripts) horloge_astro horloge_astro.cap ]

#--- Initialisation
set paramhorloge(sortie)     "0"
set paramhorloge(ra)         "21 44 11.2"
set paramhorloge(dec)        "+09 52 30"
set paramhorloge(home)       $audace(posobs,observateur,gps)
set paramhorloge(color,back) #123456
set paramhorloge(color,text) #FFFFAA
set paramhorloge(font)       {times 30 bold}

set paramhorloge(new,ra)     "$paramhorloge(ra)"
set paramhorloge(new,dec)    "$paramhorloge(dec)"

#--- Create the toplevel window
set base .horloge_astro
toplevel $base -class Toplevel
wm geometry $base 700x480+10+10
wm focusmodel $base passive
wm minsize $base 700 480
wm resizable $base 1 1
wm deiconify $base
wm title $base "$caption(horloge_astro,titre)"
wm protocol $base WM_DELETE_WINDOW fermer
bind $base <Destroy> { destroy .horloge_astro }
$base configure -bg $paramhorloge(color,back)
wm withdraw .
focus -force $base

proc fermer { } {
   global base
   global paramhorloge

   set paramhorloge(sortie) "1"
   destroy $base
}

proc calcul { } {
   global caption
   global base
   global paramhorloge

   if { $paramhorloge(sortie) != "1" } {
      set now [clock format [clock seconds] -timezone :UTC -format "%Y %m %d %H %M %S"]
      set tu  [mc_date2ymdhms $now ]
      set h   [format "%02d" [lindex $tu 3]]
      set m   [format "%02d" [lindex $tu 4]]
      set s   [format "%02d" [expr int(floor([lindex $tu 5]))]]
      $base.f.lab_tu configure -text "$caption(horloge_astro,tu) ${h}h ${m}mn ${s}s"
      set tsl [mc_date2lst $now $paramhorloge(home)]
      set h   [format "%02d" [lindex $tsl 0]]
      set m   [format "%02d" [lindex $tsl 1]]
      set s   [format "%02d" [expr int(floor([lindex $tsl 2]))]]
      $base.f.lab_tsl configure -text "$caption(horloge_astro,tsl) ${h}h ${m}mn ${s}s"
      set paramhorloge(ra1) "[ lindex $paramhorloge(ra) 0 ]h[ lindex $paramhorloge(ra) 1 ]m[ lindex $paramhorloge(ra) 2 ]"
      set paramhorloge(dec1) "[ lindex $paramhorloge(dec) 0 ]d[ lindex $paramhorloge(dec) 1 ]m[ lindex $paramhorloge(dec) 2 ]"
      set res [mc_radec2altaz "$paramhorloge(ra1)" "$paramhorloge(dec1)" "$paramhorloge(home)" $now]
      set az  [format "%5.2f" [lindex $res 0]]
      set alt [format "%5.2f" [lindex $res 1]]
      set ha  [lindex $res 2]
      set res [mc_angle2hms $ha]
      set h   [format "%02d" [lindex $res 0]]
      set m   [format "%02d" [lindex $res 1]]
      set s   [format "%02d" [expr int(floor([lindex $res 2]))]]
      $base.f.lab_ha configure -text "$caption(horloge_astro,angle_horaire) ${h}h ${m}mn ${s}s"
      $base.f.lab_altaz configure -text "$caption(horloge_astro,azimut) ${az}° - $caption(horloge_astro,hauteur) ${alt}°"
      if { $alt >= "0" } {
         set distanceZenithale [ expr 90.0 - $alt ]
         set distanceZenithale [ mc_angle2rad $distanceZenithale ]
         set secz [format "%5.2f" [ expr 1. / cos($distanceZenithale) ] ]
      } else {
         set secz "$caption(horloge_astro,horizon)"
      }
      $base.f.lab_secz configure -text "$caption(horloge_astro,secz) ${secz}"
      update
      #--- An infinite loop to change the language interactively
      after 1000 ::calcul
   } else {
      #--- Rien
   }
}

proc met_a_jour { } {
   global paramhorloge

   set paramhorloge(ra) "$paramhorloge(new,ra)"
   set paramhorloge(dec) "$paramhorloge(new,dec)"
}

frame $base.f -bg $paramhorloge(color,back)
   label $base.f.lab_titre \
      -bg $paramhorloge(color,back) -fg $paramhorloge(color,text) \
      -font $paramhorloge(font) -text "$caption(horloge_astro,titre)"
   pack $base.f.lab_titre
   #---
   label $base.f.lab_tu \
      -bg $paramhorloge(color,back) -fg $paramhorloge(color,text) \
      -font $paramhorloge(font)
   label $base.f.lab_tsl \
      -bg $paramhorloge(color,back) -fg $paramhorloge(color,text) \
      -font $paramhorloge(font)
   pack $base.f.lab_tu -fill none -pady 2
   pack $base.f.lab_tsl -fill none -pady 2
   #---
   frame $base.f.ra -bg $paramhorloge(color,back)
      label $base.f.ra.lab1 -text "$caption(horloge_astro,ad) " \
         -bg $paramhorloge(color,back) -fg $paramhorloge(color,text) \
         -font $paramhorloge(font)
      entry $base.f.ra.ent1 -textvariable paramhorloge(new,ra) \
         -width 10  -font $paramhorloge(font) \
         -bg $paramhorloge(color,back) -fg $paramhorloge(color,text) \
         -relief flat
      pack $base.f.ra.lab1 -side left -fill none
      pack $base.f.ra.ent1 -side left -fill none
   pack $base.f.ra -fill none -pady 2
   frame $base.f.dec -bg $paramhorloge(color,back)
      label $base.f.dec.lab1 -text "$caption(horloge_astro,dec) " \
         -bg $paramhorloge(color,back) -fg $paramhorloge(color,text) \
         -font $paramhorloge(font)
      entry $base.f.dec.ent1 -textvariable paramhorloge(new,dec) \
         -width 10  -font $paramhorloge(font) \
         -bg $paramhorloge(color,back) \
         -fg $paramhorloge(color,text) -relief flat
      pack $base.f.dec.lab1 -side left -fill none
      pack $base.f.dec.ent1 -side left -fill none
   pack $base.f.dec -fill none -pady 2
   button $base.f.but1 -text "$caption(horloge_astro,valider)" -command { met_a_jour }
   pack $base.f.but1 -ipadx 5 -ipady 5
   #---
   label $base.f.lab_ha \
      -bg $paramhorloge(color,back) -fg $paramhorloge(color,text) \
      -font $paramhorloge(font)
   label $base.f.lab_altaz \
      -bg $paramhorloge(color,back) -fg $paramhorloge(color,text) \
      -font $paramhorloge(font)
   pack $base.f.lab_ha -fill none -pady 2
   pack $base.f.lab_altaz -fill none -pady 2
   label $base.f.lab_secz \
      -bg $paramhorloge(color,back) -fg $paramhorloge(color,text) \
      -font $paramhorloge(font)
   pack $base.f.lab_secz -fill none -pady 2
pack $base.f -fill both

bind $base.f.ra.ent1 <Enter> { met_a_jour }
bind $base.f.dec.ent1 <Enter> { met_a_jour }

#---
::calcul

