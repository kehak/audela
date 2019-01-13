#

# get the package
package require mkLibsdl

# with wish on windows, raise the console
catch { console show }

# a little hint, if we happen to have tk loaded
catch { pack [label  .l -text "Play with the joysticks and\nwatch your console window!"] }

# print some info about each joystick
puts "*** [joystick count] joystick(s) found ***"
for { set i 0 } { $i < [joystick count] } { incr i } {
  puts "Joystick $i is '[joystick name $i]'"
}
puts "\nNow play with the joysticks and watch this window.\n"

# now we create an event handler
joystick event eval { puts [joystick event peek] }

# we must enter the event loop (if we don't have tk)
vwait forever
