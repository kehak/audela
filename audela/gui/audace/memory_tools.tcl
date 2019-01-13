#
#  file memory_tools.tcl
#  brief Read memory state of the application
#  author Alain KLOTZ
#  $Id: memory_tools.tcl 13694 2016-04-13 19:22:12Z rzachantke $
#

#  source "$audace(rep_install)/gui/audace/memory_tools.tcl"
#

# --- Reference guide
# memory_init ?comment?
# memory_get ?comment?
# memory_print ?string|num?
# memory_returnlast ?string|num?
# memory_plot ?diff|abs?
# memory_save filename ?string|num?
# #

proc memory_tool_parse { string_to_parse key } {
   #upvar $string_to_parse info
   set info $string_to_parse
   set a [string first $key $info]
   set a [ string range $info [expr $a + [string length $key]] [expr $a + 30] ]
   set b [expr [string first "kB" $a] -1]
   set a [ string range $a 0 $b ]
   set a [ string trim $a]
   return $a
}

proc memory_init { {comment ""} } {
   global memory_state
   set ps [array names memory_state]
   if {$ps!=""} {
      unset memory_state
   }
   set memory_state(vmsize,last_index) 0
   set k $memory_state(vmsize,last_index)
   set memory_state(vmsize,date,$k) [clock seconds] ; # date
   set memory_state(vmsize,comment,$k) $comment ; # comment
   if { $::tcl_platform(os) == "Linux" } {
      set pid [exec pidof audela]
      set info [exec cat /proc/[pid]/status ]
      set virtualkbytes [memory_tool_parse $info "VmSize:"] ; # Total
      set datakb [memory_tool_parse $info "VmData:"] ; # Validation
      set workingsetkb [memory_tool_parse $info "VmHWM:"] ; # Plage de travail
      set privatebyteskb [memory_tool_parse $info "VmLib:"] ; # Private
      set info [exec cat /proc/meminfo ]
      set memtotal [memory_tool_parse $info "MemTotal:"]
      set memfree [memory_tool_parse $info "MemFree:"]
      set swaptotal [memory_tool_parse $info "SwapTotal:"]
      set swapfree [memory_tool_parse $info "SwapFree:"]
      #console::affiche_resultat "Validation = [expr $datakb] KB\n"
      #console::affiche_resultat "Plage de travail = [expr $workingsetkb] KB\n"
      #console::affiche_resultat "Private = [expr $privatebyteskb] KB\n"
      #console::affiche_resultat "TOTAL = [expr $datakb+$workingsetkb+$privatebyteskb] KB / [expr $virtualkbytes] KB\n"
      set memory_state(vmsize,byte,$k) [expr $virtualkbytes*1024] ; # bytes
   } else {
      package require twapi
      set pid [twapi::get_current_process_id]
      set res [twapi::get_process_info $pid -all]
      #console::affiche_resultat "$res\n"
      set kk [lsearch -exact $res -virtualbytes] ; # Total = Plage de travail + Validation + Private
      set virtualbytes [lindex $res [expr 1+$kk]]
      set kk [lsearch -exact $res -pagefilebytes] ; # Validation
      set pagefilebytes [lindex $res [expr 1+$kk]]
      set kk [lsearch -exact $res -workingset] ; # Plage de travail
      set workingset [lindex $res [expr 1+$kk]]
      set kk [lsearch -exact $res -privatebytes] ; # Validation + Private (?!)
      set privatebytes [lindex $res [expr 1+$kk]]
      set private [expr $privatebytes - $pagefilebytes] ; # Private seul ?
      #console::affiche_resultat "Validation = [expr $pagefilebytes/1024] KB\n"
      #console::affiche_resultat "Plage de travail = [expr $workingset/1024] KB\n"
      #console::affiche_resultat "Private = [expr $privatebytes/1024] KB\n"
      #console::affiche_resultat "TOTAL = [expr ($pagefilebytes+$workingset+$privatebytes)/1024] KB / [expr $virtualbytes/1024] KB\n"
      set memory_state(vmsize,byte,$k) [expr $virtualbytes] ; # bytes
   }
   return $memory_state(vmsize,byte,$k)
}

proc memory_get { {comment ""} } {
   global memory_state
   set ps [array names memory_state]
   if {$ps==""} {
      return [memory_init]
   }
   set k $memory_state(vmsize,last_index)
   incr k
   incr memory_state(vmsize,last_index)
   set memory_state(vmsize,date,$k) [clock seconds] ; # date
   set memory_state(vmsize,comment,$k) $comment ; # comment
   if { $::tcl_platform(os) == "Linux" } {
      set pid [exec pidof audela]
      set info [exec cat /proc/[pid]/status ]
      set mempid [memory_tool_parse $info "VmSize:"]
      set info [exec cat /proc/meminfo ]
      set memtotal [memory_tool_parse $info "MemTotal:"]
      set memfree [memory_tool_parse $info "MemFree:"]
      set swaptotal [memory_tool_parse $info "SwapTotal:"]
      set swapfree [memory_tool_parse $info "SwapFree:"]
      set memory_state(vmsize,byte,$k) [expr $mempid*1024] ; # bytes
   } else {
      package require twapi
      set pid [twapi::get_current_process_id]
      set res [twapi::get_process_info $pid -handlecount -threadcount -virtualbytes -privatebytes -workingset -workingsetpeak]
      set kk [lsearch -exact $res -virtualbytes]
      set virtualbytes [lindex $res [expr 1+$kk]]
      set memory_state(vmsize,byte,$k) [expr $virtualbytes] ; # bytes
   }
   return $memory_state(vmsize,byte,$k)
}

proc memory_print { {outputs string} } {
   global memory_state
   set ps [array names memory_state]
   if {$ps==""} {
      return
   }
   set n $memory_state(vmsize,last_index)
   for {set k 0} {$k<=$n} {incr k} {
      set sec $memory_state(vmsize,date,$k)
      set byte $memory_state(vmsize,byte,$k)
      set dsec [expr $sec - $memory_state(vmsize,date,0) ]
      set dbyte [expr $byte - $memory_state(vmsize,byte,0) ]
      set texte "$sec $byte $dsec $dbyte"
      if {$outputs=="string"} {
         lappend texte $memory_state(vmsize,comment,$k)
      }
      console::affiche_resultat "$texte\n"
   }
   return
}

proc memory_returnlast { {outputs string} } {
   global memory_state
   set ps [array names memory_state]
   if {$ps==""} {
      return
   }
   set texte ""
   set k $memory_state(vmsize,last_index)
   set sec $memory_state(vmsize,date,$k)
   set byte $memory_state(vmsize,byte,$k)
   set dsec [expr $sec - $memory_state(vmsize,date,0) ]
   set dbyte [expr $byte - $memory_state(vmsize,byte,0) ]
   set texte "$sec $byte $dsec $dbyte"
   if {$outputs=="string"} {
      lappend texte $memory_state(vmsize,comment,$k)
   }
   return $texte
}

proc memory_plot { {mode diff} } {
   global memory_state
   set ps [array names memory_state]
   if {$ps==""} {
      return
   }
   set n $memory_state(vmsize,last_index)
   for {set k 0} {$k<=$n} {incr k} {
      set sec $memory_state(vmsize,date,$k)
      set byte $memory_state(vmsize,byte,$k)
      set dsec [expr $sec - $memory_state(vmsize,date,0) ]
      set dbyte [expr $byte - $memory_state(vmsize,byte,0) ]
      lappend secs $sec
      lappend kbytes [expr $byte/1024.]
      lappend dsecs $dsec
      lappend dkbytes [expr $dbyte/1024.]
   }
   if {$mode=="diff"} {
      plotxy::plot $dsecs $dkbytes "+b"
      plotxy::xlabel "seconds since [clock format $memory_state(vmsize,date,0) -format {%Y-%m-%d %H:%M:%S} ]"
      plotxy::ylabel "Kilo bytes since the first measure"
   } else {
      plotxy::plot $secs $kbytes "+b"
      plotxy::xlabel "seconds since 1970-01-01"
      plotxy::ylabel "Total kilo bytes"
   }
   return
}

proc memory_save { fname {outputs string} } {
   global memory_state
   set ps [array names memory_state]
   if {$ps==""} {
      return
   }
   set texte [memory_print $outputs]
   set f [open $fname w]
   puts -nonewline $f $texte
   close $f
   return
}

proc memory_get_direct { } {
   global memory_state
   if { $::tcl_platform(os) == "Linux" } {
      set pid [exec pidof audela]
      set info [exec cat /proc/[pid]/status ]
      set mempid [memory_tool_parse $info "VmSize:"]
      set info [exec cat /proc/meminfo ]
      set memtotal [memory_tool_parse $info "MemTotal:"]
      set memfree [memory_tool_parse $info "MemFree:"]
      set swaptotal [memory_tool_parse $info "SwapTotal:"]
      set swapfree [memory_tool_parse $info "SwapFree:"]
      set memory_state(vmsize,direct,current) [expr $mempid*1024] ; # bytes
   } else {
      package require twapi
      set pid [twapi::get_current_process_id]
      set res [twapi::get_process_info $pid -handlecount -threadcount -virtualbytes -privatebytes -workingset -workingsetpeak]
      set kk [lsearch -exact $res -virtualbytes]
      set virtualbytes [lindex $res [expr 1+$kk]]
      set memory_state(vmsize,direct,current) [expr $virtualbytes] ; # bytes
   }
   if {[info exists memory_state(vmsize,direct,last)]==0} {
      set memory_state(vmsize,direct,last) $memory_state(vmsize,direct,current)
   }
   set dmem [expr $memory_state(vmsize,direct,current) - $memory_state(vmsize,direct,last)]
   return [list $memory_state(vmsize,direct,current) $dmem]
}
