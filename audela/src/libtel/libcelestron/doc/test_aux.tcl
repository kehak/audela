# TCL Test for Celestron AUX protocol
# source c:/d/audela/src/libtel/libcelestron/doc/test_aux.tcl

proc envoi { f msg } {
   puts -nonewline $f "$msg" ; flush $f
   ::console::affiche_resultat "ENVOIE <$msg>\n"
   after 200
   set msg [read $f]
   ::console::affiche_resultat "RECOI <$msg>\n"
   return $msg
}

proc hexa2bin { hexa } {
   set nn [string length $hexa]
   set n [expr $nn/2]
   set bb ""
   set integ 0
   for {set k 0} {$k<$n} {incr k} {
      set hex [string range $hexa [expr $k*2] [expr $k*2+1]]
      set ligne "binary scan \\x$hex c1 b"
      eval $ligne
      if {$b<0} { incr b 256 }
      append bb "[format %c $b]"
   }
   return $bb
}

proc checksum { hexa } {
   set nn [string length $hexa]
   set n [expr $nn/2]
   set bb ""
   set sum 0
   for {set k 0} {$k<$n} {incr k} {
      set hex [string range $hexa [expr $k*2] [expr $k*2+1]]
      set ligne "binary scan \\x$hex c1 b"
      eval $ligne      
      if {$b<0} { incr b 256 }
      incr sum $b
      append bb "$b "
   }
   set b [expr pow(2,16)-$sum]
   set b [expr int($b-256*int($b/256))]
   binary scan [format %c $b] H* checksum
   return $checksum
}

proc encode { {source_device MainBoard} {dest_device AZMController} {ID MC_GET_VER} {data ""} {output binary}} {
   # --- preambule
   set preambule 3b
   # --- sdev
   set devices { {MainBoard 01} {HandController 04} {AZMController 10} {ALTController 11} {GPS B0} }
   set sdev ""
   foreach device $devices {
      if {$source_device==[lindex $device 0]} { 
         set sdev [lindex $device 1] 
         break
      }
   }
   if {$sdev==""} {
      error "source_device must be amongst $devices"
   }
   # --- ddev
   set ddev ""
   foreach device $devices {
      if {$dest_device==[lindex $device 0]} { 
         set ddev [lindex $device 1] 
         break
      }
   }
   if {$ddev==""} {
      error "dest_device must be amongst $devices"
   }
   # --- cid
   set ids ""
   lappend ids {MC_GET_POSITION 01} 
   lappend ids {MC_GOTO_FAST 02} 
   lappend ids {MC_SET_POSITION 04} 
   lappend ids {MC_SET_POS_GUIDERATE 06}
   lappend ids {MC_GET_VER fe}
   set cid ""
   foreach id $ids {
      if {$ID==[lindex $id 0]} { 
         set cid [lindex $id 1] 
         break
      }
   }
   if {$cid==""} {
      error "ID must be amongst $ids"
   }
   # --- data
   set data ""
   # --- checksum
   set hexa "${sdev}${ddev}${cid}${data}"
   set dlen [expr [string length $hexa]/2]
   binary scan [format %c $dlen] H* len
   set hexa "${len}${hexa}"
   set chk [checksum $hexa]
   # --- encode
   set hexa "${preambule}${hexa}${chk}"
   set bin [hexa2bin $hexa]
   if {$output=="binary"} {
      return $bin
   } else {
      return $hexa
   }
}

set f [open com1 w+]
fconfigure $f -mode "19200,n,8,1" -handshake rtscts -buffering none -translation {binary binary} -blocking 0
set hexa [encode MainBoard AZMController MC_GET_VER "" hexa]
set bin [encode MainBoard AZMController MC_GET_VER "" binary]
#set hexa 500111fe00000002
::console::affiche_resultat "hexa=$hexa\n"
set bin [hexa2bin $hexa]
envoi $f "$bin" 
close $f
