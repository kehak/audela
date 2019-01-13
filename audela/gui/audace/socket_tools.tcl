#
## @file socket_tools.tcl
#  @brief This tool box allow to connect ASCII sockets where messages termination is \n
#  $Id: socket_tools.tcl 13633 2016-04-07 12:19:06Z rzachantke $
#  @code
#  source "$audace(rep_install)/gui/audace/socket_tools.tcl"
#  socket_client_open client1 127.0.0.1 60000
#  socket_client_put client1 "Blabla"
#  set res [socket_client_get client1]
#  socket_client_close client1
#  @endcode
#

#---------------------------------------------------------
## @brief to open a named socket server that calls a proc_accept
#  @code socket_server_open server1 60000 socket_server_accept
#  @endcode
#  @param name client name
#  @param port port
#  @param proc_accept (default) socket_server_accept
#
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

#---------------------------------------------------------
## @brief this is the default proc_accept of a socket server
#  @note Please use this proc as a canvas to write those dedicaded to your job
#  @param fid
#  @param ip
#  @param port
#
proc socket_server_accept {fid ip port} {
   global audace

   fconfigure $fid -buffering line
   fileevent $fid readable [list socket_server_respons $fid]
}

#---------------------------------------------------------
## @brief this is the default socket_server_respons of a socket server
#  $note Please use this proc as a canvas to write those dedicaded to your job
#  @param fid
#
proc socket_server_respons {fid} {
   global audace

   set errsoc [ catch {
      gets $fid line
      if {[eof $fid]} {
         close $fid
      } elseif {![fblocked $fid]} {
         ::console::affiche_resultat "$fid received \"$line\" and returned it to the client\n"
         puts $fid "$line"
      }
   } msgsoc]
   if {$errsoc==1} {
      ::console::affiche_resultat "socket error : $msgsoc\n"
   }
}

#---------------------------------------------------------
## @brief this is the default proc_accept of a socket server
#  $note Please use this proc as a canvas to write those dedicaded to your job
#  @param fid file ID
#
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

#---------------------------------------------------------
## @brief to close a named socket server
#  @param name client name
#
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

#---------------------------------------------------------
## @brief to open a named socket client
#  @code
#  socket_client_open client1 127.0.0.1 60000
#  socket_client_put client1 "Blabla"
#  set res [socket_client_get client1]
#  socket_client_close client1
#  @endcode
#  @param name client name
#  @param host IP
#  @param port port
#
proc socket_client_open { name host port } {
   global audace
   if {[info exists audace(socket,client,$name)]==1} {
      error "client $name already opened"
   }
   set errno [catch {
      set audace(socket,client,$name) [socket $host $port]
      fconfigure $audace(socket,client,$name) -buffering line -blocking 0
   } msg]
   if {$errno==1} {
      error $msg
   }
}

#---------------------------------------------------------
## @brief send msg from the named socket client
#  @param name client name
#  @param msg message
#
proc socket_client_put { name msg } {
   global audace

   if {[info exists audace(socket,client,$name)]==0} {
      error "client $name does not exists"
   }
   set errno [catch {
      puts $audace(socket,client,$name) "$msg"
      flush $audace(socket,client,$name)
   } msg]
   if {$errno==1} {
      error $msg
   }
}

#---------------------------------------------------------
## @brief receive msg from the server linked with the named socket client
#  @param name client name
#
proc socket_client_get { name } {
   global audace

   if {[info exists audace(socket,client,$name)]==0} {
      error "client $name does not exists"
   }
   set errno [catch {
      gets $audace(socket,client,$name)
   } msg]
   if {$errno==1} {
      error $msg
   } else {
      return $msg
   }
}

#---------------------------------------------------------
## @brief to close a named socket client
#  @param name client name
#
proc socket_client_close { name } {
   global audace
   set errno [catch {
      close $audace(socket,client,$name)
   } msg]
   if {$errno==0} {
      unset audace(socket,client,$name)
   } else {
      error $msg
   }
}

