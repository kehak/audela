#
# Fichier : joystick2.tcl
# Description : Utilisation d'un joystick pour simuler une souris
# Auteur : Alain KLOTZ
# Mise à jour $Id: joystick2.tcl 8705 2012-10-08 17:06:41Z robertdelmas  $
#
# source $audace(rep_install)/gui/audace/scripts/joystick2.tcl
# see functions in the folder audela/lib/mkLibsdl1.0
#

package require mkLibsdl
package require twapi

proc joy_event {} {
   global base

   set res [joystick event peek]
   catch {$base.f.lab_value configure -text "$res"}
   set k [lsearch -ascii $res joystick ]
   if {$k>=0} {
      set joystick [lindex $res [expr $k+1]]
      set opt      [lrange $res [expr $k+2] [expr $k+3]]
   }
   set k [lsearch -ascii $res value]
   if {$k>=0} { set value [lindex $res [expr $k+1]] }
   set opts "joystick $joystick $opt"
   set val 0
   if {$opts=="joystick 0 axis 0"} {
      set val  [expr round($value/5000.0)]
      twapi::move_mouse $val 0 -relative
   }
   if {$opts=="joystick 0 axis 1"} {
      set val  [expr round($value/5000.0)]
      twapi::move_mouse 0 $val -relative
   }
   if {($opts=="joystick 0 button 4")&&($value==1)} {
      set val [twapi::get_mouse_location]
      twapi::click_mouse_button left
   }
   if {($opts=="joystick 0 button 5")&&($value==1)} {
      set val [twapi::get_mouse_location]
      twapi::click_mouse_button right
   }
   catch {$base.f.lab_value2 configure -text "$opts => $value ==> $val"}
}

proc joy_infos {} {
   global base

   set count [joystick count]
   console::affiche_resultat "There are $count joysticks connected\n"
   for {set joyindex 0} {$joyindex<$count} {incr joyindex} {
      console::affiche_resultat "=========================\n"
      console::affiche_resultat "joystick index = $joyindex\n"
      set name [joystick name $joyindex]
      console::affiche_resultat "joystick name $joyindex = $name\n"
      set opts {axe ball hat button}
      console::affiche_resultat "-----------------------\n"
      foreach opt $opts {
         set joy($opt) [joystick info $joyindex ${opt}s]
         console::affiche_resultat "joystick info $joyindex $opt = $joy($opt)\n"
      }
      console::affiche_resultat "-----------------------\n"
      foreach opt $opts {
         for {set control 0} {$control<$joy($opt)} {incr control} {
            if {$opt!="axe"} {
               set opt2 $opt
            } else {
               set opt2 axis
            }
            set value [joystick get $joyindex $opt2 $control]
            console::affiche_resultat "joystick get $joyindex $opt2 $control = $value\n"
         }
      }
   }
}

#--- Create the toplevel window
set base .joystick1
catch {destroy .joystick1}
toplevel $base -class Toplevel
wm geometry $base 300x100+10+10
wm focusmodel $base passive
wm minsize $base 300 100
wm resizable $base 1 1
wm deiconify $base
wm title $base "Joystick"
wm protocol $base WM_DELETE_WINDOW joysitck1_fermer
bind $base <Destroy> { destroy .joystick1 }
$base configure -bg #123456
wm withdraw .
focus -force $base

frame $base.f -bg #123456
   label $base.f.lab_titre \
      -bg #123456 -fg #AAAA00 \
      -text "The last joystick event is"
   pack $base.f.lab_titre
   label $base.f.lab_value \
      -bg #123456 -fg #FFFF00 \
      -text "nothing"
   pack $base.f.lab_value
   label $base.f.lab_value2 \
      -bg #123456 -fg #FFFF00 \
      -text "nothing"
   pack $base.f.lab_value2
pack $base.f -fill both

proc joysitck1_fermer { } {
   global base
   destroy $base
}

joystick event eval joy_event
joy_infos

