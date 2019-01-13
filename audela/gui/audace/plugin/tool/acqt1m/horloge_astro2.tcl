#
# Fichier : horloge_astro2.tcl
# Description : Horloge de l'astronome
# Auteur : Alain KLOTZ
# Mise à jour $Id: horloge_astro2.tcl 11138 2014-11-11 10:47:47Z robertdelmas $
#
namespace eval ::acqt1m_ha {
}


proc ::acqt1m_ha::fermer { } {

   set ::acqt1m_ha::paramhorloge(sortie) "1"
   destroy $::acqt1m_ha::base
}


proc ::acqt1m_ha::calcul { } {

   global caption

   if { $::acqt1m_ha::paramhorloge(sortie) != "1" } {
      set now [clock format [clock seconds] -timezone :UTC -format "%Y %m %d %H %M %S"]
      set tu  [mc_date2ymdhms $now ]
      set h   [format "%02d" [lindex $tu 3]]
      set m   [format "%02d" [lindex $tu 4]]
      set s   [format "%02d" [expr int(floor([lindex $tu 5]))]]
      $::acqt1m_ha::base.f.lab_tu configure -text "$caption(horloge_astro,tu) ${h}h ${m}mn ${s}s"
      set tsl [mc_date2lst $now $::acqt1m_ha::paramhorloge(home)]
      set h   [format "%02d" [lindex $tsl 0]]
      set m   [format "%02d" [lindex $tsl 1]]
      set s   [format "%02d" [expr int(floor([lindex $tsl 2]))]]
      $::acqt1m_ha::base.f.lab_tsl configure -text "$caption(horloge_astro,tsl) ${h}h ${m}mn ${s}s"
      set ::acqt1m_ha::paramhorloge(ra1) "[ lindex $::acqt1m_ha::paramhorloge(ra) 0 ]h[ lindex $::acqt1m_ha::paramhorloge(ra) 1 ]m[ lindex $::acqt1m_ha::paramhorloge(ra) 2 ]"
      set ::acqt1m_ha::paramhorloge(dec1) "[ lindex $::acqt1m_ha::paramhorloge(dec) 0 ]d[ lindex $::acqt1m_ha::paramhorloge(dec) 1 ]m[ lindex $::acqt1m_ha::paramhorloge(dec) 2 ]"
      set res [mc_radec2altaz "$::acqt1m_ha::paramhorloge(ra1)" "$::acqt1m_ha::paramhorloge(dec1)" "$::acqt1m_ha::paramhorloge(home)" $now]
      set az  [format "%5.2f" [lindex $res 0]]
      set alt [format "%5.2f" [lindex $res 1]]
      set ha  [lindex $res 2]
      set res [mc_angle2hms $ha]
      set h   [format "%02d" [lindex $res 0]]
      set m   [format "%02d" [lindex $res 1]]
      set s   [format "%02d" [expr int(floor([lindex $res 2]))]]
      $::acqt1m_ha::base.f.lab_ha configure -text "$caption(horloge_astro,angle_horaire) ${h}h ${m}mn ${s}s"
      $::acqt1m_ha::base.f.lab_altaz configure -text "$caption(horloge_astro,azimut) ${az}° - $caption(horloge_astro,hauteur) ${alt}°"
      if { $alt >= "0" } {
         set distanceZenithale [ expr 90.0 - $alt ]
         set distanceZenithale [ mc_angle2rad $distanceZenithale ]
         set secz [format "%5.2f" [ expr 1. / cos($distanceZenithale) ] ]
      } else {
         set secz "$caption(horloge_astro,horizon)"
      }
      set err [catch {$::acqt1m_ha::base.f.lab_secz configure -text "$caption(horloge_astro,secz) ${secz}"} msg]
      if {$err} {
         return
      }

      set t [lindex [mc_ephem sun now -equinox apparent] 0]
      set sunelev [lindex [mc_radec2altaz [lindex $t 1] [lindex $t 2] $::acqt1m_ha::paramhorloge(home) now] 1]
      set sunelev [mc_angle2dms $sunelev string 2]

      $::acqt1m_ha::base.f.lab_sunlev configure -text "Sun Elev =  ${sunelev}"
      update
      #--- An infinite loop to change the language interactively
      #after 1000 ::acqt1m_ha::calcul
   } else {
      #--- Rien
   }

   set err [catch {$::acqt1m_ha::base.f.lab_secz configure -text "$caption(horloge_astro,secz) ${secz}"} msg]
   if {$err} {
      return
   }

   set t [lindex [mc_ephem sun now -equinox apparent] 0]
   set sunelev [lindex [mc_radec2altaz [lindex $t 1] [lindex $t 2] $::acqt1m_ha::paramhorloge(home) now] 1]
   set sunelev [mc_angle2dms $sunelev 90 zero 2]


   $::acqt1m_ha::base.f.lab_sunlev configure -text "Sun Elev =  ${sunelev}"
   update
   #--- An infinite loop to change the language interactively
   after 1000 ::acqt1m_ha::calcul
}


proc ::acqt1m_ha::met_a_jour { } {

   set ::acqt1m_ha::paramhorloge(ra) "$::acqt1m_ha::paramhorloge(new,ra)"
   set ::acqt1m_ha::paramhorloge(dec) "$::acqt1m_ha::paramhorloge(new,dec)"
}


proc ::acqt1m_ha::horloge_astro2 {} {

global audace
global caption

#--- Chargement des captions
source [ file join $audace(rep_scripts) horloge_astro horloge_astro.cap ]

#--- Initialisation
set ::acqt1m_ha::paramhorloge(sortie)     "0"
set ::acqt1m_ha::paramhorloge(ra)         "21 44 11.2"
set ::acqt1m_ha::paramhorloge(dec)        "+09 52 30"
set ::acqt1m_ha::paramhorloge(home)       $audace(posobs,observateur,gps)
set ::acqt1m_ha::paramhorloge(color,back) #123456
set ::acqt1m_ha::paramhorloge(color,text) #FFFFAA
set ::acqt1m_ha::paramhorloge(font)       {times 30 bold}

set ::acqt1m_ha::paramhorloge(new,ra)     "$::acqt1m_ha::paramhorloge(ra)"
set ::acqt1m_ha::paramhorloge(new,dec)    "$::acqt1m_ha::paramhorloge(dec)"

#--- Create the toplevel window
set ::acqt1m_ha::base .horloge_astro
toplevel $::acqt1m_ha::base -class Toplevel
wm geometry $::acqt1m_ha::base 700x530+10+10
wm focusmodel $::acqt1m_ha::base passive
wm minsize $::acqt1m_ha::base 700 530
wm resizable $::acqt1m_ha::base 1 1
wm deiconify $::acqt1m_ha::base
wm title $::acqt1m_ha::base "$caption(horloge_astro,titre)"
wm protocol $::acqt1m_ha::base WM_DELETE_WINDOW ::acqt1m_ha::fermer
bind $::acqt1m_ha::base <Destroy> { destroy .horloge_astro }
$::acqt1m_ha::base configure -bg $::acqt1m_ha::paramhorloge(color,back)
wm withdraw .
focus -force $::acqt1m_ha::base
frame $::acqt1m_ha::base.f -bg $::acqt1m_ha::paramhorloge(color,back)
   #---
   label $::acqt1m_ha::base.f.lab_tu \
      -bg $::acqt1m_ha::paramhorloge(color,back) -fg $::acqt1m_ha::paramhorloge(color,text) \
      -font $::acqt1m_ha::paramhorloge(font)
   label $::acqt1m_ha::base.f.lab_tsl \
      -bg $::acqt1m_ha::paramhorloge(color,back) -fg $::acqt1m_ha::paramhorloge(color,text) \
      -font $::acqt1m_ha::paramhorloge(font)
   pack $::acqt1m_ha::base.f.lab_tu -fill none -pady 2
   pack $::acqt1m_ha::base.f.lab_tsl -fill none -pady 2
   #---
   frame $::acqt1m_ha::base.f.ra -bg $::acqt1m_ha::paramhorloge(color,back)
      label $::acqt1m_ha::base.f.ra.lab1 -text "$caption(horloge_astro,ad) " \
         -bg $::acqt1m_ha::paramhorloge(color,back) -fg $::acqt1m_ha::paramhorloge(color,text) \
         -font $::acqt1m_ha::paramhorloge(font)
      entry $::acqt1m_ha::base.f.ra.ent1 -textvariable ::acqt1m_ha::paramhorloge(new,ra) \
         -width 10  -font $::acqt1m_ha::paramhorloge(font) \
         -bg $::acqt1m_ha::paramhorloge(color,back) -fg $::acqt1m_ha::paramhorloge(color,text) \
         -relief flat
      pack $::acqt1m_ha::base.f.ra.lab1 -side left -fill none
      pack $::acqt1m_ha::base.f.ra.ent1 -side left -fill none
   pack $::acqt1m_ha::base.f.ra -fill none -pady 2
   frame $::acqt1m_ha::base.f.dec -bg $::acqt1m_ha::paramhorloge(color,back)
      label $::acqt1m_ha::base.f.dec.lab1 -text "$caption(horloge_astro,dec) " \
         -bg $::acqt1m_ha::paramhorloge(color,back) -fg $::acqt1m_ha::paramhorloge(color,text) \
         -font $::acqt1m_ha::paramhorloge(font)
      entry $::acqt1m_ha::base.f.dec.ent1 -textvariable ::acqt1m_ha::paramhorloge(new,dec) \
         -width 10  -font $::acqt1m_ha::paramhorloge(font) \
         -bg $::acqt1m_ha::paramhorloge(color,back) \
         -fg $::acqt1m_ha::paramhorloge(color,text) -relief flat
      pack $::acqt1m_ha::base.f.dec.lab1 -side left -fill none
      pack $::acqt1m_ha::base.f.dec.ent1 -side left -fill none
   pack $::acqt1m_ha::base.f.dec -fill none -pady 2
   button $::acqt1m_ha::base.f.but1 -text "$caption(horloge_astro,valider)" -command { ::acqt1m_ha::met_a_jour  }
   pack $::acqt1m_ha::base.f.but1 -ipadx 5 -ipady 5
   #---
   label $::acqt1m_ha::base.f.lab_ha \
      -bg $::acqt1m_ha::paramhorloge(color,back) -fg $::acqt1m_ha::paramhorloge(color,text) \
      -font $::acqt1m_ha::paramhorloge(font)
   label $::acqt1m_ha::base.f.lab_altaz \
      -bg $::acqt1m_ha::paramhorloge(color,back) -fg $::acqt1m_ha::paramhorloge(color,text) \
      -font $::acqt1m_ha::paramhorloge(font)
   pack $::acqt1m_ha::base.f.lab_ha -fill none -pady 2
   pack $::acqt1m_ha::base.f.lab_altaz -fill none -pady 2
   label $::acqt1m_ha::base.f.lab_secz \
      -bg $::acqt1m_ha::paramhorloge(color,back) -fg $::acqt1m_ha::paramhorloge(color,text) \
      -font $::acqt1m_ha::paramhorloge(font)
   pack $::acqt1m_ha::base.f.lab_secz -fill none -pady 2
   label $::acqt1m_ha::base.f.lab_sunlev \
      -bg $::acqt1m_ha::paramhorloge(color,back) -fg $::acqt1m_ha::paramhorloge(color,text) \
      -font $::acqt1m_ha::paramhorloge(font)
   pack $::acqt1m_ha::base.f.lab_sunlev -fill none -pady 2
pack $::acqt1m_ha::base.f -fill both

bind $::acqt1m_ha::base.f.ra.ent1 <Enter> { ::acqt1m_ha::met_a_jour  }
bind $::acqt1m_ha::base.f.dec.ent1 <Enter> { ::acqt1m_ha::met_a_jour  }

#---
::acqt1m_ha::calcul
}

