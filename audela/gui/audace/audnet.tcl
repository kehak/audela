#
## @file audnet.tcl
#  @brief Network functions using RPC or simple TCP sockets
#  @author Alain KLOTZ
#  $Id: audnet.tcl 13599 2016-04-04 10:24:37Z rzachantke $
#  @todo traiter pour Doxygen

# ====================================================================
# ====================================================================
# Select TCP Sockets
# ====================================================================
# ====================================================================

proc send { args } {
   sock_send [lindex $args 0]
}

proc create_server { {args ""} } {
   if {$args==""} {
      sock_create_server
   } else {
      sock_create_server $args
   }
}

proc delete_server { {args ""} } {
   if {$args==""} {
      sock_delete_server
   } else {
      sock_delete_server $args
   }
}

proc create_client { {args ""} } {
   # create_client 195.83.102.71 5000 195.83.102.71 5001
   # create_client localhost 5000 localhost 5001
   if {$args==""} {
      sock_create_client
   } else {
      if { [lindex $args 2]==""} {
         sock_create_client [lindex $args 0] [lindex $args 1] [lindex $args 2] [lindex $args 3]
      } else {
         sock_create_client [lindex $args 0] [lindex $args 1]
      }
   }
}

proc delete_client { {args ""} } {
   if {$args==""} {
      sock_delete_client
   } else {
      sock_delete_client $args
   }
}

# ====================================================================
# ====================================================================
# TCP Sockets Serveurs
# ====================================================================
# ====================================================================

# --- ouvre un socket serveur et attend un ordre
proc sock_create_server { {port 5000} } {
   global rpcid

   if {$rpcid(serveur)!=""} {
      return
   }
   # --- Cree un port serveur numero $port
   set rpcid(serveur) [socket -server sock_accept $port]
   set rpcid(state) "server"
   return $rpcid(serveur)
}

# --- proc qui est appellee pour l'ecoute du socket serveur
proc sock_accept { fidsockc ip port } {
   global caption

   ::console::affiche_saut "\n"
   ::console::affiche_resultat "====================================\n"
   ::console::affiche_resultat "[mc_date2iso8601 now] : $caption(audace,reseau_connexion_client) $fidsockc (IP = $ip - Port = $port)\n"
   fconfigure $fidsockc -buffering line
   fileevent $fidsockc readable [list sock_respons $fidsockc]
}

# --- proc qui est appelee lorsque le socket serveur a reçu un message termine par \n
proc sock_respons { fidsockc } {
   if {[eof $fidsockc] || [catch {gets $fidsockc line}]} {
      close $fidsockc
   } else {
      if {$line!=""} {
         # ::console::affiche_resultat "eval $line\n"
         catch {uplevel $line} texte
         catch {puts $fidsockc "$texte"}
         ::console::affiche_resultat "$texte\n"
         ::console::affiche_resultat "====================================\n"
      }
   }
}

proc sock_delete_server { {id "?"} } {
   global caption rpcid

   if {$rpcid(state)!="server"} {
      return
   }
   if {$rpcid(serveur)==""} {
      return
   }
   if {$id=="?"} {
      set id $rpcid(serveur)
   }
   close $id
   set rpcid(serveur) ""
   set rpcid(state) ""
   ::console::affiche_resultat "$caption(audace,reseau_detruit) $id\n"
}

# ====================================================================
# ====================================================================
# TCP Sockets Clients
# ====================================================================
# ====================================================================

proc sock_create_client { {ip_serveur 192.168.0.1} {port_serveur 5000} {ip_client "?"} {port_client 5000} } {
   # sock_create_client 195.83.102.71 5000 195.83.102.71 5001
   # sock_create_client localhost 5000 localhost 5001
   global caption rpcid

   if {$rpcid(client)!=""} {
      return
   }
   set rpcid(client) [socket $ip_serveur $port_serveur]
   ::console::affiche_resultat "$caption(audace,reseau_client) $rpcid(client)\n"
   fconfigure $rpcid(client) -buffering line -blocking 1
   # --- Envoi un message de connexion a afficher sur la console du serveur
   puts $rpcid(client) "::console::affiche_resultat \"$caption(audace,reseau_connecte) $rpcid(client)\\n\""
   set res [gets $rpcid(client)]
   ::console::affiche_resultat "res=$res\n"
   if {$ip_client!="?"} {
      # --- Cree un serveur sur le client pour recuperer les appels en retour
      sock_create_server $port_client
      # --- Demande au serveur de se connecter au "serveur" du client
      sock_send "set rpcid(client) \[socket $ip_client $port_client\]"
      set rpcid(state) "client/server"
      ::console::affiche_resultat "$caption(audace,reseau_serveur_retour) $rpcid(serveur)\n"
   } else {
      set rpcid(state) "client"
   }
   return $rpcid(client)
}

proc sock_delete_client { {id "?"} } {
   global caption rpcid

   if {$rpcid(client)==""} {
      return
   }
   # --- Demande au "client" du serveur de se deconnecter du "serveur" du client
   #     cree eventuellement.
   set status 0
   if {$rpcid(state)=="client/server"} {
      set status 1
      set rpcid(state) "client"
      sock_send {catch {delete_client} }
   }
   # --- On avertit le serveur de la fermeture
   if {$id=="?"} {
      set id $rpcid(client)
   }
   puts $id "::console::affiche_resultat \"$caption(audace,reseau_deconnecte) $id\\n\""
   ::console::affiche_resultat "$caption(audace,reseau_deconnexion) $id\n"
   # --- On elimine physiquement le client
   set rpcid(client) ""
   if {$rpcid(state)=="client"} {
      set rpcid(state) ""
   }
   close $id
   # --- On elimine l'eventuel serveur de retour
   if {$status==1} {
      if {$rpcid(serveur)!=""} {
         sock_delete_serveur $rpcid(serveur)
         close $rpcid(serveur)
         set rpcid(serveur) ""
         set rpcid(state) ""
         ::console::affiche_resultat "$caption(audace,reseau_detruit) $id\n"
      }
   }

}

proc sock_send { arg } {
   # --- Fonction pour renvoyer des messages a executer
   global caption rpcid

   ::console::affiche_resultat "$caption(audace,reseau_execute) $arg \n"
   puts $rpcid(client) "$arg"
   set res [gets $rpcid(client)]
   ::console::affiche_resultat "$res\n"
   return $res
}

# --- proc pour tester la communication depuis une autre console Aud'ACE
proc sock_client { } {
   set fidsockc [socket localhost 5000]
   ::console::affiche_resultat "fidsockc=$fidsockc\n"
   fconfigure $fidsockc -buffering line -blocking 1
   set texte "set a 5"
   puts $fidsockc "$texte"
   set res [gets $fidsockc]
   close $fidsockc
   set res
}

# ====================================================================
# ====================================================================
# RPC
# ====================================================================
# ====================================================================

# --- Charge le module dp
catch {package require dp}

global rpcid

set rpcid(serveur) ""
set rpcid(client)  ""
set rpcid(state)   ""

proc rpc_eval_client { arg } {
   # --- Fonction d'analyse du message du client
   uplevel $arg
}

proc rpc_eval_serveur { arg } {
   # --- Fonction d'analyse du message de retour eventuel du serveur
   uplevel $arg
}

proc rpc_send { arg } {
   # --- Fonction pour renvoyer des messages a executer
   global caption rpcid

   dp_RPC $rpcid(client) ::console::affiche_resultat "$caption(audace,reseau_execute) $arg \n"
   set message "dp_RPC $rpcid(client) rpc_eval_serveur \{ $arg \}"
   eval $message
}

proc rpc_create_server { {port 5000} } {
   global rpcid

   if {$rpcid(serveur)!=""} {
      return
   }
   # --- Cree un port serveur numero $port
   set rpcid(serveur) [dp_MakeRPCServer $port]
   dp_admin register $rpcid(serveur)
   set rpcid(state) "server"
   return $rpcid(serveur)
}

proc rpc_delete_server { {id "?"} } {
   global caption rpcid

   if {$rpcid(state)!="server"} {
      return
   }
   if {$rpcid(serveur)==""} {
      return
   }
   if {$id=="?"} {
      set id $rpcid(serveur)
   }
   dp_admin delete $id
   close $id
   set rpcid(serveur) ""
   set rpcid(state) ""
   ::console::affiche_resultat "$caption(audace,reseau_detruit) $id\n"
}

proc rpc_create_client { {ip_serveur 192.168.0.1} {port_serveur 5000} {ip_client "?"} {port_client 5000} } {
   #create_client 192.168.0.202 5000 192.168.0.1 5001
   global caption rpcid

   if {$rpcid(client)!=""} {
      return
   }
   set rpcid(client) [dp_MakeRPCClient $ip_serveur $port_serveur]
   # --- Envoi un message de connexion a afficher sur la console du serveur
   dp_RPC $rpcid(client) ::console::affiche_resultat "$caption(audace,reseau_connecte) $rpcid(client)\n"
   if {$ip_client!="?"} {
      # --- Cree un serveur sur le client pour recuperer les appels en retour
      rpc_create_server $port_client
      # --- Demande au serveur de se connecter au "serveur" du client
      rpc_send "set rpcid(client) \[dp_MakeRPCClient $ip_client $port_client\]"
      set rpcid(state) "client/server"
      ::console::affiche_resultat "$caption(audace,reseau_serveur_retour) $rpcid(serveur)\n"
   } else {
      set rpcid(state) "client"
   }
   return $rpcid(client)
}

proc rpc_delete_client { {id "?"} } {
   global caption rpcid

   if {$rpcid(client)==""} {
      return
   }
   # --- Demande au "client" du serveur de se deconnecter du "serveur" du client
   #     cree eventuellement.
   set status 0
   if {$rpcid(state)=="client/server"} {
      set status 1
      set rpcid(state) "client"
      rpc_send {catch {delete_client} }
   }
   # --- On avertit le serveur de la fermeture
   if {$id=="?"} {
      set id $rpcid(client)
   }
   dp_RPC $id ::console::affiche_resultat "$caption(audace,reseau_deconnecte) $id\n"
   ::console::affiche_resultat "$caption(audace,reseau_deconnexion) $id\n"
   # --- On elimine physiquement le client
   set rpcid(client) ""
   if {$rpcid(state)=="client"} {
      set rpcid(state) ""
   }
   dp_admin delete $id
   close $id
   # --- On elimine l'eventuel serveur de retour
   if {$status==1} {
      if {$rpcid(serveur)!=""} {
         dp_admin delete $rpcid(serveur)
         close $rpcid(serveur)
         set rpcid(serveur) ""
         set rpcid(state) ""
         ::console::affiche_resultat "$caption(audace,reseau_detruit) $id\n"
      }
   }

}

proc lan_goto { radec } {
   global audace

   send "tel$audace(telNo) radec goto $radec -equinox J2000.0 ; tel$audace(telNo) radec coord -equinox J2000.0"
}

proc lan_match { radec } {
   global audace

   send "tel$audace(telNo) radec init $radec ; tel$audace(telNo) radec coord -equinox J2000.0"
}

proc lan_move { way ms } {
   global audace

   send "tel$audace(telNo) radec move $way 0.33 ; after $ms ; tel$audace(telNo) radec stop ; tel$audace(telNo) radec coord -equinox J2000.0"
}

proc lan_acq { exptime bin fullname } {
   send "acq $exptime $bin"
   send "saveima \"$fullname\""
}

# ====================================================================
# ====================================================================
# TCP AScii file transfert from a RCP client
# ====================================================================
# ====================================================================

set rpcid(ftp,client) ""
set rpcid(ftp,chanel) ""
set rpcid(ftp,server) ""

proc audnet_createChannelServer { {port 1234} } {
   global rpcid

   set server [dp_connect tcp -server 1 -myport $port]
   set rpcid(ftp,server) $server
   dp_admin register $server
   fileevent $server readable "audnet_acceptConnection $server"
   dp_atexit appendUnique "close $server"
   dp_atclose $server append "dp_ShutdownServer $server"
   return $server
}

proc audnet_acceptConnection { file } {
   global rpcid

   set connection [dp_accept $file]
   ::console::affiche_resultat "file=$file, connection=$connection\n";
   set newFile [lindex $connection 0]
   set inetAddr [lindex $connection 1]
   ::console::affiche_resultat "newFile=$newFile, inetAddr=$inetAddr\n";
   ::console::affiche_resultat "Talk on $newFile\n";
   puts $newFile "Connection accepted"
   set rpcid(ftp,chanel) $newFile
   dp_admin register $newFile
}

proc audnet_connectChannel { {host "127.0.0.1"} {port 1234} } {
   global rpcid

   ::console::affiche_resultat "attempting to connect\n";
   set client [dp_connect tcp -host $host -port $port];
   ::console::affiche_resultat "connected -- waiting for reply\n";
   ::console::affiche_resultat "[gets $client]\n";
   set rpcid(ftp,client) $client
   return $client
}

proc audnet_put { filename } {
   global rpcid

   if {$rpcid(ftp,chanel)!=""} {
      set f [open "$filename" r]
      dp_send $rpcid(ftp,chanel) [read $f]
      close $f
   }
}

proc audnet_get { filename } {
   global rpcid

   if {$rpcid(ftp,client)!=""} {
      set f [open "$filename" w]
      puts $f [dp_recv $rpcid(ftp,client)]
      close $f
   }
}

proc audnet_deleteChannel { } {
   global rpcid

   close $rpcid(ftp,client)
   set rpcid(ftp,client) ""
   set rpcid(ftp,chanel) ""
   set rpcid(ftp,server) ""
}

proc audnet_deleteChannelServer { } {
   global rpcid

   dp_admin delete $rpcid(ftp,server)
   close $rpcid(ftp,server)
   set rpcid(ftp,client) ""
   set rpcid(ftp,chanel) ""
   set rpcid(ftp,server) ""
}

