#

# we need tk for the gui, not for mkLibdsl 
package require Tk
package require mkLibsdl

# create a button for each joystick to print its state
for { set i 0 } { $i < [joystick count] } { incr i } {
  pack [button .b$i -text [joystick name $i] -command [list showStick $i]] -fill x
}

# display the elements of the joystick i, if its button was pressed
proc showStick { i } {
  set sWin .j$i
  destroy  $sWin
  toplevel $sWin
  wm title $sWin [joystick name $i]

  # buttons
  pack [frame $sWin.u] -fill x
  pack [labelframe $sWin.u.f -text " Buttons " -padx 5 -pady 5] -fill x
  for { set j 0 } { $j < [joystick info $i buttons] } { incr j } {
    pack [checkbutton $sWin.u.f.c$j -text $j -variable ::aButtons($i.$j) -width 2 -border 1 -indicatoron 0] -side left
  }

  # hats
  pack [frame $sWin.h] -fill x
  for { set j 0 } { $j < [joystick info $i hats] } { incr j } {
    pack [labelframe $sWin.h.f$j -text " Hat $j " -padx 5 -pady 5] -side left
    pack [checkbutton $sWin.h.f$j.n -text N -variable ::aHats($i.$j.n) -width 2 -border 1 -indicatoron 0] -side top
    pack [checkbutton $sWin.h.f$j.s -text S -variable ::aHats($i.$j.s) -width 2 -border 1 -indicatoron 0] -side bottom
    pack [checkbutton $sWin.h.f$j.e -text E -variable ::aHats($i.$j.e) -width 2 -border 1 -indicatoron 0] -side right
    pack [checkbutton $sWin.h.f$j.w -text W -variable ::aHats($i.$j.w) -width 2 -border 1 -indicatoron 0] -side left
    pack [label $sWin.h.f$j.c -textvariable ::aHats($i.$j) -width 2] -side left
  }

  # axes
  pack [frame $sWin.a] -fill x
  for { set j 0 } { $j < [joystick info $i axes] } { incr j } {
    pack [labelframe $sWin.a.f$j -text " Axis $j " -padx 5 -pady 5] -fill x
    pack [scale $sWin.a.f$j.s -from -32768 -to 32768 -variable ::aAxes($i.$j) -orient horizontal -width 8 -border 1 -highlightthickness 0] -fill x
  }
}

proc showEvent {} {
  set lEvent [joystick event peek]

  foreach {x iJoystick sType iControl x iValue} $lEvent break

  switch $sType {
    button {
      set ::aButtons($iJoystick.$iControl) $iValue
    }

    hat {
      set ::aHats($iJoystick.$iControl) $iValue
      set ::aHats($iJoystick.$iControl.n) [expr { $iValue >> 0 & 1 }]
      set ::aHats($iJoystick.$iControl.e) [expr { $iValue >> 1 & 1 }]
      set ::aHats($iJoystick.$iControl.s) [expr { $iValue >> 2 & 1 }]
      set ::aHats($iJoystick.$iControl.w) [expr { $iValue >> 3 & 1 }]
    }

    axis {
      set ::aAxes($iJoystick.$iControl) $iValue
    }
  }
}

# now we create an event handler
joystick event eval showEvent
