## @file bdi_tools_synchro.client.tcl
#  @brief     Fonctions de synchronisation d&eacute;d&eacute;es au client
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_synchro.client.tcl]
#  @endcode

# $Id: bdi_tools_synchro.client.tcl 13117 2016-05-21 02:00:00Z jberthier $

proc ::bdi_tools_synchro::connect_to_socket {  } {
   
   ::bddimages::ressource
   $::bdi_tools_synchro::rapport delete 0.0 end
   $::bdi_gui_synchro::liste delete 0 end


   set host $::bdi_tools_synchro::config_ip
   set rc [catch { set ::bdi_tools_synchro::channel [socket $host $::bdi_tools_synchro::config_port] } msg]
   if {$rc == 1} { 
      ::bdi_tools_synchro::log "" $msg
      return 
   } else {
      ::bdi_tools_synchro::log $::bdi_tools_synchro::channel "Connection reussi sur $host :$::bdi_tools_synchro::config_port socket=$::bdi_tools_synchro::channel"
      
   }
}




proc ::bdi_tools_synchro::ping_socket { } {
  
   set ::bdi_tools_synchro::tt0 [clock clicks -milliseconds]
   if {![info exists ::bdi_tools_synchro::channel]} {
      addlog "Socket not connected"
      return -code 3
   }

   ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel "PING" 0
   set err [::bdi_tools_synchro::I_receive_var $::bdi_tools_synchro::channel "PING" val]
   
   if {$err} { 
      addlog "Ping Error."
      ::bdi_tools_synchro::free_channel $::bdi_tools_synchro::channel
      return -code 2
   }

   if {$val==1} {
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $::bdi_tools_synchro::tt0)/1000.]]
      addlog "Ping finish $tt sec"
      return 0
   } else {
      addlog "Ping Error."
      ::bdi_tools_synchro::free_channel $::bdi_tools_synchro::channel
      return -code 1
   }
}




proc ::bdi_tools_synchro::check_synchro { } {

   global bddconf

   set ::bdi_tools_synchro::tt0 [clock clicks -milliseconds]
   if {![info exists ::bdi_tools_synchro::channel]} {
      addlog "Socket not connected"
      return
   }

   set tt0 [clock clicks -milliseconds]

   #::bdi_tools_synchro::free_channel $::bdi_tools_synchro::channel




   # Envoie de l action sur le serveur
   ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel "CHECK_SYNC_BDI" 0

   # status
   set err [catch {::bdi_tools_synchro::I_receive_var $::bdi_tools_synchro::channel status status} msg]
   if {$err} { 
      ::bdi_tools_synchro::free_channel $::bdi_tools_synchro::channel
      return -code 1 
   }
   #gren_info "status = $status\n"

   if {$status == "ERROR"} {
      addlog "Error: init CHECK_SYNC_BDI"
      return
   }

   # MD5
   set err [catch {::bdi_tools_synchro::I_receive_var $::bdi_tools_synchro::channel md5 md5} msg]
   if {$err} { 
      ::bdi_tools_synchro::free_channel $::bdi_tools_synchro::channel
      return -code 1 
   }
   #gren_info "md5 = $md5\n"

   # filesize
   set err [catch {::bdi_tools_synchro::I_receive_var $::bdi_tools_synchro::channel filesize filesize} msg]
   if {$err} { 
      ::bdi_tools_synchro::free_channel $::bdi_tools_synchro::channel
      return -code 1 
   }
   #gren_info "filesize = $filesize\n"

   # file
   ::bdi_tools_synchro::I_receive_file $::bdi_tools_synchro::channel tmpfile $filesize

   set err [ catch { set md5receive [::bdi_tools_synchro::get_md5 $tmpfile] } msg ]
   if {$err} {
      addlog $msg
      return
   }

   if {$md5receive!=$md5} {
      addlog "Error : bad file comparison."
      return
   }

   ::bdi_tools::gunzip $tmpfile
   set ext  [file extension $tmpfile]
   set pos  [expr [string last $ext $tmpfile] -1]
   set tmpfile [string range $tmpfile 0 $pos]
   if {[file exists $tmpfile]} {
      #gren_info "tmpfile = $tmpfile\n"
      source $tmpfile
      set data_server $data
      unset data
   } else {
      addlog "Erreur durant l'analyse. Mauvais fichier serveur."
      return
   }
   # Recupere les donnees du client
   ::bdi_tools_synchro::get_table_fitscata data_client
   
   set ::bdi_tools_synchro::data_client $data_client
   set ::bdi_tools_synchro::data_server $data_server

   ::bdi_tools_synchro::search_todo data_client data_server

   set ::bdi_tools_synchro::data_client $data_client
   set ::bdi_tools_synchro::data_server $data_server

   set ::bdi_tools_synchro::todolist [concat $data_client $data_server]
   
   set nb_maj_client [llength $::bdi_tools_synchro::data_client]
   set nb_maj_server [llength $::bdi_tools_synchro::data_server]
   addlog "$nb_maj_client $nb_maj_server"
   set nb_maj        [llength $::bdi_tools_synchro::todolist]
   
   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   addlog "Analyse finished in $tt sec. TOTAL FILES TO UPDATE = $nb_maj, on Client $nb_maj_client and on server $nb_maj_server."
}










proc ::bdi_tools_synchro::search_todo { p_data_client p_data_server } {
   
   upvar $p_data_client data_client
   upvar $p_data_server data_server

   set tt0 [clock clicks -milliseconds]

   array unset tab_server
   array unset tab_client
   
   #gren_info "data serveur \n"
   foreach line $data_server {
      set f [file join [lindex $line 0] [lindex $line 1]]
      set tab_server($f)   1
      set tab_server_f_m($f) [lindex $line 3]
      set tab_server_f_s($f) [lindex $line 2]
      if {[llength $line]==8} {
         set c [file join [lindex $line 4] [lindex $line 5]]
         set tab_server($f)     2
         set tab_server_c($f)   $c
         set tab_server_c_s($f) [lindex $line 6]
         set tab_server_c_m($f) [lindex $line 7]
      }
      #gren_info "$f : $tab_server($f)\n"
   }

   #gren_info "data client \n"
   foreach line $data_client {
      set f [file join [lindex $line 0] [lindex $line 1]]
      set tab_client($f)   1
      set tab_client_f_m($f) [lindex $line 3]
      set tab_client_f_s($f) [lindex $line 2]
      if {[llength $line]==8} {
         set c [file join [lindex $line 4] [lindex $line 5]]
         set tab_client($f)     2
         set tab_client_c($f)   $c
         set tab_client_c_s($f) [lindex $line 6]
         set tab_client_c_m($f) [lindex $line 7]
      }
      #gren_info "$f : $tab_client($f)\n"
   }

   set maj_sur_client ""
   set maj_sur_server ""
   set cpt -1
   set log 0

   #gren_info "--------------------------\n"
   foreach { f y } [array get tab_client] {


      # on regarde d abords le fichier FITS
      #gren_info "*** ($y) *** $f\n"
      set fpass ""
      set cpass ""
      set f_e 0 
      set c_e 0 

      if {[info exists tab_server($f)]} {
      
         set f_e 1

         if {[string equal [file tail $f] "sat-B-10.fits.gz"]} {
            gren_info "YES : $f\n"
            gren_info "Date Client : $tab_client_f_m($f)\n"
            gren_info "Date Serveur : $tab_server_f_m($f)\n"
            set log 1
         }


         if {$log} {gren_info "Log -- \n"}

         if { [string equal $tab_client_f_m($f) $tab_server_f_m($f)]} {
            if {$tab_client_f_s($f) != $tab_server_f_s($f)} {
               #gren_erreur "# synchronisation impossible\n"
               set fpass "ERROR"
            } else {
               #gren_info "# fichier fits de meme taille\n"
               set fpass "EQUAL"
            }
            
         } else {
            set jd_f_client [mc_date2jd $tab_client_f_m($f)]
            set jd_f_server [mc_date2jd $tab_server_f_m($f)]
            
            if {$jd_f_client < $jd_f_server} {
               if {$log} {gren_info "fichier fits plus recent sur serveur $tab_client_f_m($f) < $tab_server_f_m($f)\n"}
               #gren_info "# fichier fits plus recent sur serveur $tab_client_f_m($f) < $tab_server_f_m($f)\n"
               set fpass "CLIENT"
            } else {
               if {$log} {gren_info "fichier fits plus recent sur client $tab_client_f_m($f) > $tab_server_f_m($f)\n"}
               #gren_info "# fichier fits plus recent sur client $tab_client_f_m($f) > $tab_server_f_m($f)\n"
               set fpass "SERVER"
            }
         }

         # on regarde le fichier CATA

         if {$y==2 && $tab_server($f)==1} {
            # Le cata existe sur le client mais pas sur le serveur
            set cpass "SERVER"
         }

         if {$y==1 && $tab_server($f)==2} {
            # Le cata existe sur le serveur mais pas sur le client
            set cpass "CLIENT"
         }
         
         if {$y==2 && $tab_server($f)==2} {

            # Le cata existe sur le serveur et sur le client
            if { [string equal $tab_client_c_m($f) $tab_server_c_m($f)]} {

               if {$tab_client_c_s($f) != $tab_server_c_s($f)} {
                  #gren_erreur "# synchronisation impossible\n"
                  set cpass "ERROR"
                  set cerror "cata filesize not match"
               } else {
                  #gren_info "# fichier cata de meme taille\n"
                  set cpass "EQUAL"
               }

            } else {
               set jd_c_client [mc_date2jd $tab_client_c_m($f)]
               set jd_c_server [mc_date2jd $tab_server_c_m($f)]

               if {$jd_c_client < $jd_c_server} {
                  #gren_info "# fichier cata plus recent sur serveur $tab_client_c_m($f) < $tab_server_c_m($f)\n"
                  set cpass "CLIENT"
               } else {
                  #gren_info "# fichier cata plus recent sur client $tab_client_c_m($f) > $tab_server_c_m($f)\n"
                  set cpass "SERVER"
               }
            }
         }

         if {$log} {
            gren_info "cpass=$cpass fpass=$fpass\n"
         }

         if {$log} {set log 0}

      } else {
         #gren_info "# fichier manquant sur serveur\n"
         set fpass "SERVER"
         if {$y==2} {set cpass "SERVER"}
      }

#       id   todo   sens   duree errlog fitsexist fitsdate            fitssize            cataexist catadate            catasize             fits  cata
# [list $cpt "TODO" "S->C" ""    ""     $fexist   $tab_client_f_m($f) $tab_client_f_s($f) $cexist   $tab_client_c_m($f) $tab_client_c_s($f)  $f    $c    ]
# [list $cpt "TODO" "C->S" ""    ""     $fexist   $tab_client_f_m($f) $tab_client_f_s($f) $cexist   $tab_client_c_m($f) $tab_client_c_s($f)  $f    $c    ]
# [list $cpt "TODO" "C->S" ""    ""     $f_e      $f_m                $f_s                $c_e      $c_m                $c_s                 $f    $c    ]
      
      if {[info exists tab_client($f)]} {set tc $tab_client($f)} else {set tc -1}
      if {[info exists tab_server($f)]} {set ts $tab_server($f)} else {set ts -1}

      
      if {$fpass == "ERROR"||$cpass == "ERROR"} {
         #gren_erreur "Synchronisation : ($fpass) ($cpass) ($tc) ($ts)\n"
      } else {
         #gren_info "Synchronisation : ($fpass) ($cpass) ($tc) ($ts)\n"
      }

      if {$fpass == "CLIENT" && $cpass == ""} {
         # Synchronisation du fits vers CLIENT
         #gren_info "Synchronisation du fits vers CLIENT\n"
         if {!($::bdi_tools_synchro::param_check_exist && $f_e)} {
            incr cpt
            lappend maj_sur_client [list $cpt "TODO" "S->C" "FITS" $f_e $tab_server_f_m($f) $tab_server_f_s($f) $f "" "" ]
         }
      }

      if {$fpass == "SERVER" && $cpass == ""} {
         # Synchronisation du fits vers SERVER
         #gren_info "Synchronisation du fits vers SERVER\n"
         if {!($::bdi_tools_synchro::param_check_exist && $f_e)} {
            incr cpt
            lappend maj_sur_server [list $cpt "TODO" "C->S" "FITS" $f_e $tab_client_f_m($f) $tab_client_f_s($f) $f "" "" ]
         }
      }
      
      if {$fpass == "CLIENT" && $cpass == "CLIENT"} {
         # Synchronisation du fits et du cata vers CLIENT
         #gren_info "Synchronisation du fits et du cata vers CLIENT\n"
         if {!($::bdi_tools_synchro::param_check_exist && $f_e)} {
            incr cpt
            lappend maj_sur_client [list $cpt "TODO" "S->C" "FITS" $f_e $tab_server_f_m($f) $tab_server_f_s($f) $f "" "" ]
         }
         
         if {$tc==2} {set c_e 1}
         if {!($::bdi_tools_synchro::param_check_exist && $c_e)} {
            incr cpt
            lappend maj_sur_client [list $cpt "TODO" "S->C" "CATA" $c_e $tab_server_c_m($f) $tab_server_c_s($f) $tab_server_c($f) "" "" ]
         }
      }

      if {$fpass == "SERVER" && $cpass == "SERVER"} {
         # Synchronisation du fits et du cata vers SERVER
         #gren_info "Synchronisation du fits et du cata vers SERVER\n"
         if {!($::bdi_tools_synchro::param_check_exist && $f_e)} {
            incr cpt
            lappend maj_sur_server [list $cpt "TODO" "C->S" "FITS" $f_e $tab_client_f_m($f) $tab_client_f_s($f) $f "" "" ]
         }
         
         if {$ts==2} {set c_e 1}
         if {!($::bdi_tools_synchro::param_check_exist && $c_e)} {
            incr cpt
            lappend maj_sur_server [list $cpt "TODO" "C->S" "CATA" $c_e $tab_client_c_m($f) $tab_client_c_s($f) $tab_client_c($f) "" "" ]
         }
      }


      if {$fpass == "CLIENT" && $cpass == "ERROR"} {
         # Synchronisation du fits vers CLIENT
         #gren_info "Synchronisation du fits vers CLIENT\n"
         if {!($::bdi_tools_synchro::param_check_exist && $f_e)} {
            incr cpt
            lappend maj_sur_client [list $cpt "TODO" "S->C" "FITS" $f_e $tab_server_f_m($f) $tab_server_f_s($f) $f "" "" ]
         }
         
         if {!($::bdi_tools_synchro::param_check_exist && $c_e)} {
            incr cpt
            lappend maj_sur_client [list $cpt "TODO" "S->C" "CATA" $c_e $tab_server_c_m($f) $tab_server_c_s($f) $tab_server_c($f) "" $cerror ]
         }
      }

      if {$fpass == "SERVER" && $cpass == "ERROR"} {
         # Synchronisation du fits vers SERVER
         #gren_info "Synchronisation du fits vers SERVER\n"
         if {!($::bdi_tools_synchro::param_check_exist && $f_e)} {
            incr cpt
            lappend maj_sur_server [list $cpt "TODO" "C->S" "FITS" $f_e $tab_client_f_m($f) $tab_client_f_s($f) $f "" "" ]
         }

         if {!($::bdi_tools_synchro::param_check_exist && $c_e)} {
            incr cpt
            lappend maj_sur_server [list $cpt "TODO" "C->S" "CATA" $c_e $tab_client_c_m($f) $tab_client_c_s($f) $tab_client_c($f) "" $cerror ]
         }
      }


      if {$fpass == "CLIENT" && $cpass == "EQUAL"} {
         # Synchronisation du fits vers CLIENT
         #gren_info "Synchronisation du fits vers CLIENT\n"
         if {!($::bdi_tools_synchro::param_check_exist && $f_e)} {
            incr cpt
            lappend maj_sur_client [list $cpt "TODO" "S->C" "FITS" $f_e $tab_server_f_m($f) $tab_server_f_s($f) $f "" "" ]
         }
      }

      if {$fpass == "SERVER" && $cpass == "EQUAL"} {
         # Synchronisation du fits vers SERVER
         #gren_info "Synchronisation du fits vers SERVER\n"
         if {!($::bdi_tools_synchro::param_check_exist && $f_e)} {
            incr cpt
            lappend maj_sur_server [list $cpt "TODO" "C->S" "FITS" $f_e $tab_client_f_m($f) $tab_client_f_s($f) $f "" "" ]
         }
      }


      if {$fpass == "EQUAL" && $cpass == "CLIENT"} {
         # Synchronisation du cata vers CLIENT
         #gren_info "Synchronisation du cata vers CLIENT\n"
         if {$tc==2} {set c_e 1} else {set c_e 0}
         if {!($::bdi_tools_synchro::param_check_exist && $c_e)} {
            incr cpt
            lappend maj_sur_client [list $cpt "TODO" "S->C" "CATA" $c_e $tab_server_c_m($f) $tab_server_c_s($f) $tab_server_c($f) "" "" ]
         }
      }

      if {$fpass == "EQUAL" && $cpass == "SERVER"} {
         # Synchronisation du cata vers SERVER
         #gren_info "Synchronisation du cata vers SERVER\n"
         if {$ts==2} {set c_e 1} else {set c_e 0}
         if {!($::bdi_tools_synchro::param_check_exist && $c_e)} {
            incr cpt
            lappend maj_sur_server [list $cpt "TODO" "C->S" "CATA" $c_e $tab_client_c_m($f) $tab_client_c_s($f) $tab_client_c($f) "" "" ]
         }
      }

      if {[info exists tab_server($f)]} { unset tab_server($f) }

      if {$fpass == "EQUAL" && $cpass == ""} {
         #gren_info "Auncune Synchronisation necessaire\n"
         continue
      }
      if {$fpass == "EQUAL" && $cpass == "EQUAL"} {
         #gren_info "Auncune Synchronisation necessaire EQUALEQUAL \n"
         continue
      }



      
   }

   set nb [expr [llength [array get tab_server]] /2]
   #gren_info "nb = $nb\n"
   if {$nb!=0} {
      foreach { f y } [array get tab_server] {
         #gren_info "$f # fichier manquant sur client\n"
         incr cpt
         lappend maj_sur_client [list $cpt "TODO" "S->C" "FITS" 0 $tab_server_f_m($f) $tab_server_f_s($f) $f "" "" ]
         if {$y==2} {
            #gren_info "$tab_server_c($f) # fichier manquant sur client\n"
            incr cpt
            lappend maj_sur_client [list $cpt "TODO" "S->C" "CATA" 0 $tab_server_c_m($f) $tab_server_c_s($f) $tab_server_c($f) "" "" ]
         }
      }
   }

   set nb_maj_client [llength $maj_sur_client]
   set nb_maj_server [llength $maj_sur_server]

   #gren_info "------------------------------------------\n"
   #gren_info "nb maj client = $nb_maj_client\n"
   #gren_info "nb maj server = $nb_maj_server\n"
   #gren_info "------------------------------------------\n"

   if {$nb_maj_client >0 &&  $::bdi_tools_synchro::param_check_maj_client == 1} {
      set data_client $maj_sur_client
   } else {
      set data_client ""
   }
   if {$nb_maj_server >0 &&  $::bdi_tools_synchro::param_check_maj_server == 1} {
      set data_server $maj_sur_server
   } else {
      set data_server ""
   }

   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "analyse du travail a faire finie en $tt sec\n"

}







proc ::bdi_tools_synchro::stop_synchro { } {
   $::bdi_tools_synchro::buttons_synchro configure -state "normal"
   set ::bdi_tools_synchro::stop 1
}





proc ::bdi_tools_synchro::set_column { id status {txt ""} {duration ""} } {


   switch $status {
      "ERROR" {
         set bg red
         set fg white
      }
      "DELETED" {
         set bg white
         set fg red
      }
      "DONE" {
         set bg darkgreen
         set fg white
      }
      "CORRECTED" {
         set bg darkgreen
         set fg white
      }
      default {
         set bg white
         set fg darkgreen
      }
   }

   catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg $bg -foreground $fg -text $status}
   
   if {$duration != ""} {
      catch  {$::bdi_gui_synchro::liste cellconfigure $id,8 -text $duration}
   }
   if {$txt != ""} {
      addlog $txt
      catch  {$::bdi_gui_synchro::liste cellconfigure $id,9 -text $txt}
   }
   
}




proc ::bdi_tools_synchro::set_focus { id } {
   catch  {$::bdi_gui_synchro::liste see $id}

}



proc ::bdi_tools_synchro::set_duration { id tt } {
   catch  {$::bdi_gui_synchro::liste cellconfigure $id,8 -text $tt}

}



proc ::bdi_tools_synchro::set_error { id txt } {

   set line [lindex $::bdi_tools_synchro::todolist $id]
   set line [lreplace $line 1 1 "ERROR"]
   set line [lreplace $line 9 9 $txt]
   set ::bdi_tools_synchro::todolist [lreplace $::bdi_tools_synchro::todolist $id $id $line]

   ::bdi_tools_synchro::set_column $id "ERROR" $txt

   puts "ERROR $txt"
}




proc ::bdi_tools_synchro::set_status { id status } {

   set line [lindex $::bdi_tools_synchro::todolist $id]
   set line [lreplace $line 1 1 $status]
   set ::bdi_tools_synchro::todolist [lreplace $::bdi_tools_synchro::todolist $id $id $line]

   ::bdi_tools_synchro::set_column $id $status
}






proc ::bdi_tools_synchro::test_sql { } {

   set sqlcmd "SELECT idbddimg FROM images WHERE filename LIKE BINARY '$fn' AND dirfilename LIKE BINARY '$df';"

   set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      gren_erreur "*** SQL CMD ******** \n"
      gren_erreur "err = $err\n"
      gren_erreur "sql = $sqlcmd\n"
      gren_erreur "msg = $msg\n"
      gren_erreur "************************* \n"
   }
}



proc ::bdi_tools_synchro::launch_synchro { } {

   global bddconf

   set tt0 [clock clicks -milliseconds]
   addlog "Synchronisation begin"
   set ::bdi_tools_synchro::stop 0
   $::bdi_tools_synchro::buttons_synchro configure -state "disabled"

   #$::bdi_tools_synchro::param_check_nothing
   #$::bdi_tools_synchro::param_check_maj_client
   #$::bdi_tools_synchro::param_check_maj_server
   #$::bdi_tools_synchro::param_check_exist

   # Constitution de la liste 
   # ::bdi_tools_synchro::build_synchro mylist
   # catch {::bdi_gui_synchro::affich_synchro mylist}

   # Button Action
   if {$::bdi_tools_synchro::param_check_nothing==1||[llength $::bdi_tools_synchro::todolist]==0} {
      $::bdi_tools_synchro::buttons_synchro configure -state "normal"
      addlog "Nothing to do ! Check parameters...\n"
      return
   }
   
   
   set err [catch {::bdi_tools_synchro::ping_socket} msg ]
   if {$err} {
      puts "Ping erreur : ($err) $msg"
      return
   }
   

   set id -1

   gren_info "NB img todo = [llength $::bdi_tools_synchro::todolist ]\n"
   
   foreach l $::bdi_tools_synchro::todolist {

      if {$id != -1} {
         set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt1)/1000.]]
         ::bdi_tools_synchro::set_duration $id $tt
      }
      set tt1 [clock clicks -milliseconds]

      update
      if {$::bdi_tools_synchro::stop} {break}
      incr id

      set todo [lindex $l 1]
      
      # on met le focus 
      ::bdi_tools_synchro::set_focus $id
      
      if {$todo!="TODO"} {
         continue
      }
      
      set synchro   [lindex $l 2 ]
      set filetype  [lindex $l 3 ]
      set exist     [lindex $l 4 ]
      set modifdate [lindex $l 5 ]
      set filesize  [lindex $l 6 ]
      set filename  [lindex $l 7 ]

      #gren_info "flush\n"      
      #::bdi_tools_synchro::free_channel $::bdi_tools_synchro::channel
         
      gren_info "id=$id  E=$exist Sy=$synchro D=$modifdate S=$filesize F=$filename\n"
      
      if {$synchro=="S->C"} {

         #gren_info "ok c est parti $synchro\n"
         ::bdi_tools_synchro::set_status $id PENDING

         # Envoie de l action sur le serveur
         ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel "SYNC_BDI" $synchro
         #gren_info "SYNC_BDI = $synchro\n"

         # Reception du status
         ::bdi_tools_synchro::I_receive_var $::bdi_tools_synchro::channel status status
         #gren_info "Status = $status\n"

         # Ok le serveur est dispo on passe en PROCESSING
         if {$status=="PENDING"} {
            ::bdi_tools_synchro::set_status $id PROCESSING
         } else {
            ::bdi_tools_synchro::set_error $id $status
            if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
         }
         update
         
         # Envoie le nom du fichier
         ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel filetype $filetype
         # Envoie le nom du fichier
         ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel filename $filename
         #gren_info "filename send\n"
         ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel work     1
         #gren_info "work send\n"

         ::bdi_tools_synchro::I_receive_var  $::bdi_tools_synchro::channel status status inf
         #gren_info "status       = $status \n"

         if {$status!="FILEOK"} {
            ::bdi_tools_synchro::set_error $id "Error : $status"
            if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
         }

         # Reception 
         ::bdi_tools_synchro::I_receive_var  $::bdi_tools_synchro::channel md5 md5_r 
         #gren_info "md5       = $md5_r \n"
         ::bdi_tools_synchro::I_receive_var  $::bdi_tools_synchro::channel filesize  filesize_r
         #gren_info "filesize  = TODO:$filesize SERV:$filesize_r\n"
         ::bdi_tools_synchro::I_receive_var  $::bdi_tools_synchro::channel modifdate modifdate_r
         #gren_info "modifdate = $modifdate $modifdate_r\n"
         
         ::bdi_tools_synchro::set_status $id DOWNLOAD
         update

         ::bdi_tools_synchro::I_receive_file $::bdi_tools_synchro::channel tmpfile $filesize_r

         # fin transaction ave serveur
         
         if {$exist} {
            if {$filesize!=$filesize_r} {
               switch $filetype {
                  "FITS" {
                     ::bdi_tools_synchro::set_error $id "Error : Bad file size on client $filesize != $filesize_r"
                     if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
                  }
                  "CATA" {
                     ::bdi_tools_synchro::set_error $id "Error : Bad file size on client $filesize != $filesize_r"
                     if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
                  }
                  default {
#                     set filesize != $filesize_r
                  }
               }
            }
         }
         if {$modifdate!=$modifdate_r} {
            ::bdi_tools_synchro::set_error $id "Error : Bad modif date on client $modifdate != $modifdate_r"
            if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
         }

         set err [ catch { set md5 [::bdi_tools_synchro::get_md5 $tmpfile] } msg ]
         if {$err} {
            ::bdi_tools_synchro::set_error $id $msg
            if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
         }

         if {$md5 != $md5_r} {
            ::bdi_tools_synchro::set_error $id "Error : Bad MD5"
            if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
         }
         
         ::bdi_tools_synchro::set_status $id INSERT
         set newfile [file join $bddconf(dirtmp) [file tail $filename] ]
         #gren_info "newfile   = $newfile  \n"
         
         set err [catch {file rename -force $tmpfile $newfile} msg]
         if {$err} {
            ::bdi_tools_synchro::set_error $id "Error rename file : $msg"
            if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
         }
         
         set df [file dirname $filename]
         set fn [file tail $filename]

         switch $filetype {

            "FITS" {

               if {$exist} {

                  # Effacement du fichier FITS
                  set sqlcmd "SELECT idbddimg FROM images WHERE filename LIKE BINARY '$fn' AND dirfilename LIKE BINARY '$df';"
                  set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
                  if {$err} {
                     ::bdi_tools_synchro::set_error $id "Erreur : find idbddimg - err = $err\nsql = $sqlcmd\nmsg = $msg"
                     if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
                  }

                  set data [lindex $data 0]
                  set idbddimg [lindex $data 0]

                  set err [catch {set ident [bddimages_image_identification $idbddimg]} msg ]
                  if {$err} {
                     ::bdi_tools_synchro::set_error $id "Error bddimages_image_identification : idbddimg = $idbddimg"
                     if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
                  }
                  set idbddimg     [lindex $ident 0]
                  set fileimg      [lindex $ident 1]
                  set idbddcata    [lindex $ident 2]
                  set catafilebase [lindex $ident 3]
                  set idheader     [lindex $ident 4]

                  bddimages_image_delete $idbddimg

               }

               # Insertion du nouveau fichier
               set err [catch {set idbddimg [insertion_solo $newfile]} msg]
               #gren_info "idbddimg = $idbddimg\n"
               if {$err} {
                  ::bdi_tools_synchro::set_error $id "Error insertion file : $msg"
                  if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
               }

               # Mise a jour de datemodif dans IMAGES pour $idbddimg
               set sqlcmd "UPDATE images SET datemodif='$modifdate' WHERE idbddimg=$idbddimg;"
               set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
               if {$err} {
                  ::bdi_tools_synchro::set_error $id "Erreur : UPDATE IMAGES - err = $err\nsql = $sqlcmd\nmsg = $msg"
                  if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
               }

            }

            "CATA" {
               # Pas besoin d effacer le fichier cata, il sera ecrasé a la prochaine insertion

               # Insertion du nouveau fichier
               set err [catch {set idbddcata [insertion_solo $newfile]} msg]
               #gren_erreur "idbddcata = $idbddcata\n"
               if {$err} {
                  ::bdi_tools_synchro::set_error $id "Erreur : insertion CATA : msg = $msg"
                  if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
               }

               # Mise a jour de datemodif dans CATA pour $idbddcata
               set sqlcmd "UPDATE catas SET datemodif='$modifdate' WHERE idbddcata=$idbddcata;"
               set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
               if {$err} {
                  ::bdi_tools_synchro::set_error $id "Erreur : UPDATE CATAS - err = $err\nsql = $sqlcmd\nmsg = $msg"
                  if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
               }

            }

            default {
               ::bdi_tools_synchro::set_error $id "Unknown filetype : $filetype\n"
            }               
         }
         
         ::bdi_tools_synchro::set_status $id DONE
         
      }




      if {$synchro=="C->S"} {

         set file [file join $bddconf(dirbase) $filename]

#            gren_info "ok c est parti $synchro\n"
         #puts "ok c est parti $synchro"
         ::bdi_tools_synchro::set_status $id PENDING

         # Envoie de l action sur le serveur
         ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel "SYNC_BDI" $synchro
#            gren_info "SYNC_BDI = $synchro\n"
         #puts "SYNC_BDI = $synchro"

         # Reception du status
         ::bdi_tools_synchro::I_receive_var $::bdi_tools_synchro::channel status status
         #puts "Status = $status"
#            gren_info "Status = $status\n"

         # Ok le serveur est dispo on passe en PROCESSING
         if {$status=="PENDING"} {
            ::bdi_tools_synchro::set_status $id PROCESSING
         } else {
            ::bdi_tools_synchro::set_error $id $status
            if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
         }


         ::bdi_tools_synchro::set_status $id UPLOAD

         # Envoie le type du fichier
         ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel filetype $filetype
         #puts "Envoie le type du fichier : $filetype"

         # Envoie le nom du fichier
         ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel filename $filename
#            gren_info "filename send\n"
         #puts "Envoie le nom du fichier : $filename"

         # Envoie de la taille
         set size [file size $file]
         if {$size!=$filesize} {
            gren_erreur "taille du fichier differe : sur disque $size != sur database $filesize\n"
            gren_erreur "file = $file\n"
            set filesize $size
            
         }
         ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel filesize $filesize
#            gren_info "filesize send\n"
         #puts "Envoie la taille du fichier : $filesize"

         # Envoie de la date
         ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel modifdate $modifdate
#            gren_info "modifdate send\n"
         #puts "Envoie la date du fichier : $modifdate"

         # Envoie si le fichier existe ?
         ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel exist $exist
#            gren_info "exist send\n"
         #puts "Envoie l existance du fichier : $exist"

         # Envoie du md5
         
         set err [ catch { set md5 [::bdi_tools_synchro::get_md5 $file] } msg ]
         if {$err} {
            ::bdi_tools_synchro::set_error $id $msg
            if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
         }
         
         # set md5 "toto"
         ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel md5 $md5
#            gren_info "md5 send\n"
         #puts "Envoie le md5 du fichier : $md5"

         if {$exist && $filetype=="FITS"} {
            ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel CHECK_MATCH_FILE 1
            ::bdi_tools_synchro::I_receive_var $::bdi_tools_synchro::channel status status

            switch $status {
               "DIFFERENT" {
                  
               }
               "CORRECTED" {
                  ::bdi_tools_synchro::set_status $id "CORRECTED"
                  continue
               }
               default {
                  ::bdi_tools_synchro::set_error $id $status
                  if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
               }
            }
         }
         
         # Envoie du fichier
         ::bdi_tools_synchro::set_status $id UPLOAD
         update
         ::bdi_tools_synchro::I_send_file $::bdi_tools_synchro::channel $file $filesize "file"
#            gren_info "file send\n"
         #puts "Envoie le fichier : $file "
         
         # reception fichier recu
         ::bdi_tools_synchro::I_receive_var $::bdi_tools_synchro::channel status status
#            gren_info "Status = $status\n"
         #puts "recoit le status : $status "

         if {$status=="UPLOADED"} {
            ::bdi_tools_synchro::set_status $id UPLOADED
         } else {
            ::bdi_tools_synchro::set_error $id $status
            if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
         }

         # Envoie de l action work
         ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel work 1
#            gren_info "work send\n"

         # Reception du status
         ::bdi_tools_synchro::I_receive_var $::bdi_tools_synchro::channel status status
#            gren_info "Status = $status\n"

         # Ok le serveur est dispo on passe en PROCESSING
         if {$status=="SUCCESS"} {
            ::bdi_tools_synchro::set_status $id DONE
         } else {
            ::bdi_tools_synchro::set_error $id $status
            if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
         }

      }

   }
   
   # Fin
   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   addlog "Synchronisation finished in $tt sec."
   $::bdi_tools_synchro::buttons_synchro configure -state "normal"
   

}

