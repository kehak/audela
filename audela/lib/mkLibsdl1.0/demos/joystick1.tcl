#

# we need tk only for the little gui, not for mkLibdsl 
package require Tk
package require mkLibsdl

# with wish on windows, raise the console
catch { console show }

# a little help text
pack [label  .l -text "Click one of the buttons to print the joystick's state to the console"] -fill x

# create a button for each joystick to print its state
for { set i 0 } { $i < [joystick count] } { incr i } {
  puts "  Joystick '[joystick name $i]'"
  pack [button .j$i -text [joystick name $i] -command [list printState $i]] -fill x
}

# this proc prints the state of a joystick
proc printState { i } {
  puts "State of joystick '[joystick name $i]'"

  puts "  [joystick info $i buttons] buttons"
  for { set j 0 } { $j < [joystick info $i buttons] } { incr j } {
    puts "    Button $j has state [joystick get $i button $j]"
  }
  puts "  [joystick info $i balls] balls"
  for { set j 0 } { $j < [joystick info $i balls] } { incr j } {
    puts "    Ball $j made movement [joystick get $i ball $j]"
  }
  puts "  [joystick info $i hats] hats"
  for { set j 0 } { $j < [joystick info $i hats] } { incr j } {
    puts "    Hat $j has position [joystick get $i hat $j]"
  }
  puts "  [joystick info $i axes] axes"
  for { set j 0 } { $j < [joystick info $i axes] } { incr j } {
    puts "    Axis $j has position [joystick get $i axis $j]"
  }
}

