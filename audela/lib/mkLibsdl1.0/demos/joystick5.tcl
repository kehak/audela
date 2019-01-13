#

# we need tk for the gui, not for mkLibdsl 
package require Tk
package require mkLibsdl

# the court
pack [label  .l -text "Use an analog joystick or a ball to control the racket"]
pack [canvas .c -width 300 -height 310 -bg white -relief sunken -border 1]
.c configure -scrollregion {-150 -150 150 160}
.c create line -140  140 -140 -140 -width 5 -tag left
.c create line -140 -140  140 -140 -width 5 -tag top
.c create line  140 -140  140  140 -width 5 -tag right
.c create line -200  160  200  160 -width 5 -tag bottom
.c create oval   -5   50    5   60 -width 0  -fill red  -tag ball
.c create line  -40  150   40  150 -width 10 -fill blue -tag racket
.c create text -120 -120 -text 0 -tag balls
.c create text  120 -120 -text 0 -tag hits

# initial ball direction
set fDx -2
set fDy -2

proc moveBall {} {
  .c move ball $::fDx $::fDy

  if { [llength [eval .c find overlapping [.c coords right]]] == 3 } {
    set ::fDx [expr { -1-rand()*2 }]
  }
  if { [llength [eval .c find overlapping [.c coords left]]] == 3 } {
    set ::fDx [expr { 1+rand()*2 }]
  }
  if { [llength [eval .c find overlapping [.c coords top]]] == 4 } {
    set ::fDy 2
  }
  if { [llength [eval .c find overlapping [.c coords racket]]] == 2 } {
    set ::fDy -2
    .c itemconfigure hits -text [expr { [.c itemcget hits -text] + 1 }]
  }
  if { [llength [eval .c find overlapping [.c coords bottom]]] == 2 } {
    set ::fDy -2
    .c coords ball -5 50 5 60
    .c itemconfigure balls -text [expr { [.c itemcget balls -text] + 1 }]
  }

  if { [llength [set lEvent [joystick event poll]]] } {
    foreach {x iJoystick sType iControl x iVal1 x iVal2 } $lEvent break
  
    switch $sType.$iControl {
      ball {
        set iDx [expr { $iVal1 / 2 }]
        .c move racket $iDx 0
      }
  
      axis.0 - axis.2 {
        set iX [expr { 100 * $iVal1 / 32768 }]
        .c coords racket [expr { $iX - 40 }] 150 [expr { $iX + 40 }] 150
      }
    }
  }

  after 10 moveBall
}

# start to move the ball
moveBall
