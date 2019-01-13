   proc get_date_sys2ut { { date now } } {
     if { $date == "now" } {
        set t [clock milliseconds]
        set time [format "%s.%03d" [clock format [expr {$t / 1000}] -format "%Y-%m-%dT%H:%M:%S" -timezone :UTC] [expr {$t % 1000}] ]
     } else {
        set jjnow [ mc_date2jd $date ]
        set time  [ mc_date2ymdhms $jjnow ]
     }
     return $time
   }

   proc date_iso2eproc { date } {
      set year   [string range $date 0 3]
      set month  [string range $date 5 6]
      set day    [string range $date 8 9]
      set hour   [string range $date 11 12]
      set minute [string range $date 14 15]
      set second [string range $date 17 18]
      return "$day $month $year $hour $minute $second"
   }

   proc date_iso2planif { date } {
      set year   [string range $date 0 3]
      set month  [string range $date 5 6]
      set day    [string range $date 8 9]
      set hour   [string range $date 11 12]
      set minute [string range $date 14 15]
      return "$day $month $year $hour $minute 0"
   }
