#
## @file console.tcl
#  @brief Création de la Console
#  $Id: console.tcl 13695 2016-04-13 19:23:32Z rzachantke $
#  @namespace console
#  @brief Création de la Console

#  source $audace(rep_install)/gui/audace/console.tcl
#

namespace eval ::console {

   #------------------------------------------------------------------------------
   #  brief créé l'interface
   #  param this "" par défaut ""
   #
   proc create { { this "" } } {
      variable This
      global audace audela caption color

      if { $this == "" } {
         set This $audace(Console)
      } else {
         set This $this
      }

      if { [winfo exists $This] } {
         wm deiconify $This
         return
      }

      toplevel $This
      wm geometry $This 370x200+220+180
      wm maxsize $This [winfo screenwidth .] [winfo screenheight .]
      wm minsize $This 370 200
      wm resizable $This 1 1
      wm deiconify $This
      wm title $This "$caption(console,titre)"
      wm protocol $This WM_DELETE_WINDOW "::audace::quitter"

      scrollbar $This.scr1 -orient vert -command console::onScr1Scroll
      entry $This.ent1 -bg #FFFFFF -fg #000000 -textvariable console::CmdLine
      text $This.txt1 -bg #DDDDFF -yscrollcommand console::onTxt1Scroll -wrap word

      grid $This.txt1 -row 0 -column 0 -sticky news
      grid $This.scr1 -row 0 -column 1 -sticky ns
      grid $This.ent1 -row 1 -column 0 -sticky ew

      grid rowconfigure $This 0 -weight 1
      grid columnconfigure $This 0 -weight 1

      #--- Polices de caracteres de la Console
      if {[string compare $::tcl_platform(platform) windows]==0} {
         set font(console) "Verdana 8"
      } else {
         set font(console) "Arial 12 bold"
      }
      $This.txt1 configure -font $font(console)
      $This.ent1 configure -font $font(console)

      #--- Initialisation des couleurs de la Console
      set color(textConsoleEntete)   #007F00
      set color(textConsoleResultat) "azure4"
      set color(textConsoleCmd)      "black"
      set color(textConsoleErreur)   "red"
      set color(textConsolePrompt)   "purple"

      #--- Couleurs des messages de la Console
      $This.txt1 tag configure style_entete   -foreground $color(textConsoleEntete)
      $This.txt1 tag configure style_resultat -foreground $color(textConsoleResultat)
      $This.txt1 tag configure style_cmd      -foreground $color(textConsoleCmd)
      $This.txt1 tag configure style_erreur   -foreground $color(textConsoleErreur)
      $This.txt1 tag configure style_prompt   -foreground $color(textConsolePrompt)

      #--- Affichage de l'en-tete dans la Console
      $This.txt1 insert end "#\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,interface_audace_audela) $audela(version)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright1)\n" style_entete
      $This.txt1 insert end "#\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright2)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright3)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright4)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright5)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright6)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright7)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright8)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright9)\n" style_entete
      $This.txt1 insert end "#\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright10)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright11)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright12)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright13)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright14)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright15)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright16)\n" style_entete
      $This.txt1 insert end "#\n" style_entete
      $This.txt1 insert end "\n"

      bind $This.txt1 <Key-Return> {console::onTxt1KeyReturn %W; break;}
      bind $This.ent1 <Key-Return> {console::onEnt1KeyReturn %W; break;}
      bind $This.ent1 <Key-Escape> {console::onEnt1KeyEsc %W; break;}
      bind $This.ent1 <Key-Up>     {console::onEnt1KeyUp %W; break;}
      bind $This.ent1 <Key-Down>   {console::onEnt1KeyDown %W; break;}
      bind $This.txt1 <Key-F1>     {console::onTxt1KeyF1 %W; break;}

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }
   }

   #------------------------------------------------------------------------------
   ## @brief donne le focus a la Console et positionne le curseur dans la ligne de commande ;
   #  si une raquette est utilisée, elle vient au premier plan
   #
   proc GiveFocus {} {
      variable This

      #--- Donne le focus a la Console et positionne le curseur dans la ligne de commande
      switch -- [wm state $This] {
         normal {raise $This}
         iconic {wm deiconify $This}
      }
      focus $This.ent1
      #--- Si la raquette LX200 est utilisee, elle vient au premier plan
      if { [ winfo exists .lx200pad ] } {
         raise .lx200pad
      }
      #--- Si la raquette SuperPad est utilisee, elle vient au premier plan
      if { [ winfo exists .superpad ] } {
         raise .superpad
      }
      #--- Si la raquette T193Pad est utilisee, elle vient au premier plan
      if { [ winfo exists .t193pad ] } {
         raise .t193pad
      }
      #--- Si la raquette TelPad est utilisee, elle vient au premier plan
      if { [ winfo exists .telpad ] } {
         raise .telpad
      }
   }

   #------------------------------------------------------------------------------
   ## @brief affiche le message avec le style "erreur"
   #  @param ligne contenu à afficher
   #
   proc affiche_erreur {ligne} {
      variable This

      $This.txt1 insert end "# $ligne" style_erreur
      $This.txt1 see insert
      update
   }

   #------------------------------------------------------------------------------
   ## @brief affiche le message avec une couleur à spécifier
   #  @param ligne contenu à afficher
   #  @param freecolor spécifie la couleur, "" par défaut
   #
   proc affiche_resultat {ligne {freecolor ""} } {
      variable This

      if {$freecolor==""} {
         $This.txt1 insert end "# $ligne" style_resultat
      } else {
         $This.txt1 tag configure style_libre_[string range $freecolor 1 end] -foreground $freecolor
         $This.txt1 insert end "# $ligne" style_libre_[string range $freecolor 1 end]
      }
      $This.txt1 see insert
      update
   }

   #------------------------------------------------------------------------------
   ## @brief affiche le message ???????????????
   #  @param ligne contenu à afficher
   #
   proc affiche_resultat_bis {ligne} {
      variable This

      $This.txt1 insert end $ligne style_resultat
      $This.txt1 see insert
      update
   }

   #------------------------------------------------------------------------------
   ## @brief affiche le message suivi d'un saut de ligne
   #  @param ligne contenu à afficher
   #
   proc affiche_saut {ligne} {
      variable This

      $This.txt1 insert end "$ligne" style_resultat
      $This.txt1 see insert
      update
   }

   #------------------------------------------------------------------------------
   ## @brief traite la ligne comme une commande
   #  @code ::console::affiche_debug hello
   #  # Débug>hello -> # invalid command name "hello"
   #  @endcode
   #  @param ligne contenu à afficher
   #
   proc affiche_debug {ligne} {
      variable This
      global caption

      $This.txt1 insert end "# $caption(console,debug)>" style_entete
      $This.txt1 insert end "$ligne -> "
      $This.txt1 see insert
      update
      $This.txt1 insert end "[uplevel $ligne]\n" style_resultat
   }

   #------------------------------------------------------------------------------
   ## @brief affiche le message avec le style "entête"
   #  @param ligne contenu à afficher
   #
   proc affiche_entete {ligne} {
      variable This

      $This.txt1 insert end $ligne style_entete
      $This.txt1 see insert
   }

   #------------------------------------------------------------------------------
   ## @brief affiche le message avec le style "prompt"
   #  @param ligne contenu à afficher
   #
   proc affiche_prompt {ligne} {
      variable This

      $This.txt1 insert end $ligne style_prompt
      $This.txt1 see insert
   }


   #------------------------------------------------------------------------------
   ## @brief affiche le message avec le style "cmd"
   #  @param line contenu à afficher
   #
   proc disp {line} {
      variable This

      $This.txt1 insert end $line style_cmd
      $This.txt1 see insert
   }

   proc marqueDebut {} {
      variable This

      $This.txt1 mark set debut "insert -1 l lineend"
   }

   proc onTxt1KeyF1 {w} {
      variable This

      focus $This.ent1
   }

   proc onScr1Scroll {args} {
      variable This

      uplevel #0 "$This.txt1 yview $args"
   }

   proc onTxt1Scroll {args} {
      variable This

      uplevel #0 "$This.scr1 set $args"
   }

   proc onTxt1KeyReturn {w} {
      set ligneCmd [$w get "insert linestart" "insert lineend"]
      $w mark set insert "insert lineend"
      $w insert end "\n"
      execute "$ligneCmd"
      $w see insert
   }

   proc onEnt1KeyReturn {w} {
      variable This
      variable CmdLine
      variable LastSpace

      set Cmd $CmdLine
      $This.txt1 mark set insert end
      ::console::disp "$Cmd\n"
      ::console::execute $Cmd
      $This.txt1 see insert
      historik add "$Cmd"
      set CmdLine ""
      set LastSpace 0
   }

   proc onEnt1KeyEsc {w} {
      variable This
      variable CmdLine

      set CmdLine [historik synchro]
      $This.ent1 icursor end
   }

   proc onEnt1KeyUp {w} {
      variable This
      variable CmdLine

      set CmdLine [historik before]
      $This.ent1 icursor end
   }

   proc onEnt1KeyDown {w} {
      variable This
      variable CmdLine

      set CmdLine [historik after]
      $This.ent1 icursor end
   }

   proc execute {cmd} {
      variable This
      variable Res

      if { [catch {uplevel #0 $cmd} res] != 0} {
         $This.txt1 insert end "# $res\n" style_erreur
         regsub -all {;} $res "," res2
         regsub -all \n $res2 " " res
         set Res [list 1 $res]
         #$This.txt1 insert end "## $res\n" style_erreur
      } else {
         if { [string compare $res ""] != 0} {
            $This.txt1 insert end "# $res\n" style_resultat
            regsub -all {;} $res "," res2
            regsub -all \n $res2 " " res
            set Res [list 0 $res]
         } else {
            set Res [list 0 ""]
         }
      }
      $This.txt1 insert end "\n"
   }

   #------------------------------------------------------------------------------
   ## @brief efface le contenu de la console
   #
   proc clear { } {
      variable This

      $This.txt1 delete 0.0 end
   }

   proc server { action { port 5555 } } {
      global audace

      set name console_server
      if {$action=="open"} {
         if {[info exists audace(socket,server,$name)]==1} {
            error "server $name already opened"
         }
         console::socket_server_open $name $port console::socket_server_accept
         set audace(console,server,port) $port
      } elseif {$action=="close"} {
         console::socket_server_close $name
         catch {unset audace(console,server,port)}
      } elseif {$action=="status"} {
         if {([info exists audace(socket,server,$name)]==1)&&([info exists audace(console,server,port)]==1)} {
            return opened
         } else {
            return closed
         }
      } elseif {$action=="port"} {
         if {([info exists audace(socket,server,$name)]==1)&&([info exists audace(console,server,port)]==1)} {
            return $audace(console,server,port)
         } else {
            return ""
         }
      } else {
         error "action must be open|status|port|close"
      }
   }

   proc client { args } {
      global audace

      set n [llength $args]
      if {$n>=1} {
         set action [lindex $args 0]
         set name console_client
         if {$action=="open"} {
            set ip 127.0.0.1
            set port 5555
            if {$n>=2} { set ip [lindex $args 1] }
            if {$n>=3} { set port [lindex $args 2] }
            if {[info exists audace(socket,client,$name)]==1} {
               error "client $name already opened"
            }
            console::socket_client_open $name $ip $port
            set sname $audace(socket,client,$name)
            return "Socket ${name} ($sname) opened to ${ip}:${port}\n"
         } elseif {$action=="close"} {
            set sname $audace(socket,client,$name)
            console::socket_client_close $name
            return "Socket ${name} ($sname) is closed\n"
         } elseif {$action=="put"} {
            console::socket_client_put $name [lrange $args 1 end]
            return ""
         } elseif {$action=="get"} {
            set res [console::socket_client_get $name]
            flush $audace(socket,client,$name)
            lassign $res err msg
            if {($err==1)} {
               error $msg
            } else {
               return $msg
            }
         } elseif {$action=="putget"} {
            console::socket_client_put $name [lrange $args 1 end]
            set errmsg ""
            set res $errmsg
            while {($res==$errmsg)||($res=="")} {
               set res [console::socket_client_get $name]
               #console::affiche_resultat "res=<$res>\n"
               after 100
            }
            flush $audace(socket,client,$name)
            lassign $res err msg
            if {($err==1)} {
               error $msg
            } else {
               return $msg
            }
         } else {
            error "action must be open|close|put|get|putget"
         }
      } else {
         error "Usage: console::client open|close|put|get|putget args"
      }
   }

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
      fileevent $fid readable [list console::socket_server_respons $fid]
   }
   # ==========================================================================================

   # ==========================================================================================
   # socket_server_respons : this is the default proc_accept of a socket server
   # Please use this proc as a canvas to write those dedicaded to your job.
   proc socket_server_respons {fid} {
      variable This
      variable CmdLine
      variable Res
      global audace

      set errsoc [ catch {
         gets $fid line
         if {$line!=""} {
            ::console::affiche_resultat "Remote command received: ${line}\n"
         }
         if {[eof $fid]} {
            close $fid
         } elseif {![fblocked $fid]} {
            if {[llength $line]==1} {
               set line [lindex $line 0]
            }
            set CmdLine $line
            console::onEnt1KeyReturn $This.ent1
            puts -nonewline $fid "${Res}"
            flush $fid
         }
      } msgsoc]
      if {$errsoc==1} {
         ::console::affiche_resultat "socket error : $msgsoc\n"
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
   # ==========================================================================================

   # ==========================================================================================
   # socket_client_open : to open a named socket client
   # e.g. socket_client_open client1 127.0.0.1 60000
   #      socket_client_put client1 "Blabla" ; set res [socket_client_get client1]
   #      socket_client_close client1
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
   # ==========================================================================================

   # ==========================================================================================
   # socket_client_put : send msg from the named socket client
   proc socket_client_put { name msg } {
      global audace

      if {[info exists audace(socket,client,$name)]==0} {
         error "client $name does not exists. Use before: console::client open "
      }
      set errno [catch {
         #console::affiche_resultat "ETAPE 1 audace(socket,client,$name)=$audace(socket,client,$name)\n"
         puts $audace(socket,client,$name) "${msg}"
         flush $audace(socket,client,$name)
      } msg]
      if {$errno==1} {
         error $msg
      }
   }
   # ==========================================================================================

   # ==========================================================================================
   # socket_client_get : receive msg from the server linked with the named socket client
   proc socket_client_get { name } {
      global audace

      if {[info exists audace(socket,client,$name)]==0} {
         error "client $name does not exists. Use before: console::client open "
      }
      #console::affiche_resultat "ETAPE 2 audace(socket,client,$name)=$audace(socket,client,$name)\n"
      set errno [catch {
         read $audace(socket,client,$name)
      } msg]
      flush $audace(socket,client,$name)
      #console::affiche_resultat "ETAPE 3 errno=$errno msg=<$msg>\n"
      if {$errno==1} {
         error $msg
      } else {
         return $msg
      }
   }
   # ==========================================================================================

   # ==========================================================================================
   # socket_client_close : to close a named socket client
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
   # ==========================================================================================
}

