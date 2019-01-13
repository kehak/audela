# TCL Test for CAGIRE protocol

proc envoi { f msg } {
   puts -nonewline $f "$msg" ; flush $f
   ::console::affiche_resultat "ENVOIE <$msg>\n"
   after 200
   set msg [read $f]
   ::console::affiche_resultat "RECOI <$msg>\n"
   return $msg
}

set ip 192.168.0.1
set port 5000
set f [socket $ip $port]
fconfigure $f -buffering none -translation {binary binary} -blocking 0
envoi $f "Initialize2" ; # 

=============================================================================================================
socket_server_open cagire 5000

cam::create cagire tcp -port 5000
cam1 put PING
cam1 read

::cam::create cagire -ip 127.0.0.1 -port 5000 -impath "c:/d/a" -simu 1
cam1 buf 2
cam1 acq

# ==========================================================================================
# socket_server_open : to open a named socket server that calls a proc_accept
# e.g. source audace/socket_tools.tcl ; socket_server_open server1 60000 socket_server_accept
proc socket_server_open { name port {proc_accept socket_server_accept} } {
   global audace
   if {[info exists audace(socket,server,$name)]==1} {
      error "server $name already opened"
   }
   set errno [catch {
      set audace(socket,server,$name) [socket -server $proc_accept $port]
   } msg]
   if {$errno==1} {
      error $msg
   }
}
# ==========================================================================================

# ==========================================================================================
# socket_server_accept : this is the default proc_accept of a socket server
# Please use this proc as a canvas to write those dedicaded to your job.
proc socket_server_accept {fid ip port} {
   global audace
   fconfigure $fid -buffering line
   fileevent $fid readable [list socket_server_respons $fid]
}
# ==========================================================================================

# ==========================================================================================
# socket_server_respons : this is the default proc_accept of a socket server
# Please use this proc as a canvas to write those dedicaded to your job.
proc socket_server_respons {fid} {
   global audace
   set errsoc [ catch {
      gets $fid line
      if {[eof $fid]} {
         close $fid
      } elseif {![fblocked $fid]} {
         ::console::affiche_resultat "$fid received \"$line\" and returned it to the client\n"
         #puts $fid "$line"
         puts -nonewline $fid "A" ; after 1000
         puts -nonewline $fid "B" ; after 1000
         puts -nonewline $fid "C" ; after 1000
         puts -nonewline $fid "D" ; after 1000
         puts -nonewline $fid "E" ; after 1000
         puts -nonewline $fid "\n" ; after 1000
      }
   } msgsoc]
   if {$errsoc==1} {
      ::console::affiche_resultat "socket error : $msgsoc\n"
   }
}
# ==========================================================================================

# ==========================================================================================
# socket_server_respons : this is the default proc_accept of a socket server
# Please use this proc as a canvas to write those dedicaded to your job.
proc socket_server_respons_debug {fid} {
   global audace
   set stepsoc 0
   set errsoc [ catch {
      if {[info exists audace(socket,server,connected)]==0} {
         set audace(socket,server,connected) 1
      } else {
         incr audace(socket,server,connected)
      }
      set stepsoc 1
      gets $fid line
      if {[eof $fid]} {
         ::console::affiche_resultat "close the connexion : connected=$audace(socket,server,connected)\n"
         incr audace(socket,server,connected) -1
         set stepsoc 2
         close $fid
      } elseif {![fblocked $fid]} {
         if {$audace(socket,server,connected)>20} {
            ::console::affiche_resultat " connected=$audace(socket,server,connected) DEPASSE\n"
            #incr audace(socket,server,connected) -1
            ::console::affiche_resultat "connected=$audace(socket,server,connected)\n"
            #set stepsoc 3
            #return
         }
         ::console::affiche_resultat "($audace(socket,server,connected)) $fid received \"$line\" and returned it to the client\n"
         set stepsoc 4
         set errno [catch { puts $fid "$line" } msg ]
         if {$errno==1} {
            ::console::affiche_resultat "socket put error : $msg\n"
         }
      }
      ::console::affiche_resultat "connected=$audace(socket,server,connected)\n"
      incr audace(socket,server,connected) -1
   } msgsoc]
   if {$errsoc==1} {
      ::console::affiche_resultat "socket error $stepsoc : $msgsoc\n"
   }
}
# ==========================================================================================

# ==========================================================================================
# socket_server_close : to close a named socket server
proc socket_server_close { name } {
   global audace
   set errno [catch {
      close $audace(socket,server,$name)
   } msg]
   if {$errno==0} {
      unset audace(socket,server,$name)
      catch {unset audace(socket,server,connected)}
   } else {
      error $msg
   }
}
