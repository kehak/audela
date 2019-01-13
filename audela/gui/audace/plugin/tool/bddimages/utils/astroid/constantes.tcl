
proc pi { } {
   return 3.141592653589793
}

proc deg2rad { x } {
   return [expr $x / 180.0 * [pi] ]
}

proc rad2deg { x } {
   return [expr $x / 180.0 * [pi] ]
}
