#
# Fichier : joystick1.tcl
# Description : Utilisation d'un joystick pour commander une monture
# Auteur : Alain KLOTZ
# Mise à jour $Id: joystick1.tcl 8698 2012-10-07 08:30:41Z robertdelmas  $
#
# source $audace(rep_install)/gui/audace/scripts/joystick1.tcl
# see functions in the folder audela/lib/mkLibsdl1.0
#

package require mkLibsdl

proc joy_event {} {
   global base

   set res [joystick event peek]
   catch {$base.f.lab_value configure -text "$res"}
}

proc joy_infos {} {
   set count [joystick count]
   if { $count > 1 } {
      ::console::affiche_resultat "There are $count joysticks connected.\n"
   } else {
      ::console::affiche_resultat "There is $count joystick connected.\n"
   }
   for {set joyindex 0} {$joyindex<$count} {incr joyindex} {
      ::console::affiche_resultat "=========================\n"
      ::console::affiche_resultat "joystick index = $joyindex\n"
      set name [joystick name $joyindex]
      ::console::affiche_resultat "joystick name $joyindex = $name\n"
      set opts {axe ball hat button}
      ::console::affiche_resultat "-----------------------\n"
      foreach opt $opts {
         set joy($opt) [joystick info $joyindex ${opt}s]
         ::console::affiche_resultat "joystick info $joyindex $opt = $joy($opt)\n"
      }
      ::console::affiche_resultat "-----------------------\n"
      foreach opt $opts {
         for {set control 0} {$control<$joy($opt)} {incr control} {
            if {$opt!="axe"} {
               set opt2 $opt
            } else {
               set opt2 axis
            }
            set value [joystick get $joyindex $opt2 $control]
            ::console::affiche_resultat "joystick get $joyindex $opt2 $control = $value\n"
         }
      }
   }
}

#--- Create the toplevel window
global base

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
pack $base.f -fill both

proc joysitck1_fermer { } {
   global base

   destroy $base
}

joystick event eval joy_event
joy_infos

