## @file bdi_tools_synchro.server.tcl
#  @brief     Fonctions de synchronisation d&eacute;d&eacute;es au serveur
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_synchro.server.tcl]
#  @endcode

# $Id: bdi_tools_synchro.server.tcl 13117 2016-05-21 02:00:00Z jberthier $

proc ::bdi_tools_synchro::launch_socket {  } {

#      catch { console show }
#      catch { wm protocol . WM_DELETE_WINDOW exit }

   set rc [catch {
     set channel [socket -server server $::bdi_tools_synchro::config_port]
     set ::bdi_tools_synchro::channel $channel

     #puts "$channel: [fconfigure $channel -sockname]"

     if {$::bdi_tools_synchro::config_port == 0} {
       set ::bdi_tools_synchro::config_port [lindex [fconfigure $channel -sockname] end]
       puts "--> server port: $::bdi_tools_synchro::config_port"
     }
   } msg]
   if {$rc == 1} {
     ::bdi_tools_synchro::log server <exiting>\n***$msg
     exit
   }
   set (server:host) server
   set (server:port) $::bdi_tools_synchro::config_port

   # enter event loop
   log $channel "Socket Ouvert"
   vwait forever

}


proc ::bdi_tools_synchro::close_socket { { channel ""} } {

  if {$channel == ""} {set channel $::bdi_tools_synchro::channel}
  log $channel "Socket Close "
  set err [catch { close $channel } msg ]
  if {$err} {
     #puts "Fermeture Socket : $err $msg\n"
  }
  
}




proc ::bdi_tools_synchro::reopen_socket { } {
   ::bddimages::ressource
   #gren_erreur "reopen_socket...\n"
   close_socket
   $::bdi_tools_synchro::rapport delete 0.0 end

   ::bdi_tools_synchro::launch_socket
}



proc ::bdi_tools_synchro::server {channel host port} {
 # save client info
 set ::($channel:host) $host
 set ::($channel:port) $port

 #puts "ici $channel $::($channel:host) $::($channel:port)"
 
 #set ::bdi_tools_synchro::config_port $port

 # log
 #log $channel <opened>
 set rc [catch {
   # set call back on reading
   fileevent $channel readable [list ::bdi_tools_synchro::input_server $channel]
 } msg]
 if {$rc == 1} {
   # i/o error -> log
   log server ***$msg
 }
 
}




proc ::bdi_tools_synchro::input_server { channel } {

   global message
   global bddconf


   if {[eof $channel]} {
     # client closed -> log & close
     log $channel <closeda>
     catch { ::bdi_tools_synchro::close_socket $channel}
   } else {


      set err [catch { set var [::bdi_tools_synchro::getline $channel] } msg ]
      if {$err} {
         puts "<error> $msg"
         log $channel "<error> $msg"
         return
      }

      if {$var == ""} {
         puts "var vide"
         return
      }

      if {$var != "file"} {
         set err [catch { set val [::bdi_tools_synchro::getline $channel] } msg ]
         if {$err} {
            addlog "<error> $msg"
            return
         }
#            set flog [open "/tmp/synchro.server.log" a]
#            puts $flog "[mc_date2iso8601 now] $var=$val"
#            close $flog
#            puts "[mc_date2iso8601 now] $var=$val"
      } else {
         
#            set flog [open "/tmp/synchro.server.log" a]
#            puts $flog "[mc_date2iso8601 now] ($var)"
#            puts $flog "demarrage du telechargement ?" 
#            close $flog
         
         #puts "[mc_date2iso8601 now] ($var)" 
         #gren_info "demarrage du telechargement ?\n"
         #puts "[mc_date2iso8601 now] demarrage du telechargement ?"
      }


#         set flog [open "/tmp/synchro.server.log" a]
#         puts $flog "[mc_date2iso8601 now] RE($var)"
#         close $flog

      switch $var {
         "PING" {
            set ::bdi_tools_synchro::tt0 [clock clicks -milliseconds]
            array unset message
            ::bdi_tools_synchro::I_send_var $channel "PING" 1
            set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $::bdi_tools_synchro::tt0)/1000.]]
            addlog "Ping receive in $tt sec"
         }
         "CHECK_SYNC_BDI" {
            array unset message
            set ::bdi_tools_synchro::tt0 [clock clicks -milliseconds]
            addlog "Analysing Server Database..."

            set err [catch {set r [::bdi_tools_synchro::build_file_table_images]} msg]
            if {$err} {

              set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $::bdi_tools_synchro::tt0)/1000.]]
              addlog "Analyse error: $msg, in $tt sec"
              ::bdi_tools_synchro::I_send_var $channel status "ERROR"

            } else {

              set message(md5) [lindex $r 0]
              set message(filename) [lindex $r 1]
              set message(filesize) [lindex $r 2]
             
              ::bdi_tools_synchro::I_send_var $channel status "PROCESSING"
              ::bdi_tools_synchro::I_send_var $channel md5      $message(md5)
              ::bdi_tools_synchro::I_send_var $channel filesize $message(filesize)
              ::bdi_tools_synchro::I_send_file $channel $message(filename) $message(filesize)

              set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $::bdi_tools_synchro::tt0)/1000.]]
              addlog "Analyse and send data ended in $tt sec"

            }
         }
         "SYNC_BDI" {
            set ::bdi_tools_synchro::tt0 [clock clicks -milliseconds]
            array unset message
            set message(synchro) $val
            #puts "R : $val"
            ::bdi_tools_synchro::I_send_var $channel status "PENDING"
         }
         "DEL_BDI" {
            set ::bdi_tools_synchro::tt0 [clock clicks -milliseconds]
            array unset message
            puts "R : DEL_BDI"
            ::bdi_tools_synchro::I_send_var $channel status "PENDING"
         }
         "CHECK_MATCH_FILE" {
            
            #$message(md5)
            #$message(filetype)
            #$message(filename)
            #$message(filesize)
            #$message(modifdate)
            
            set err [catch {set r [::bdi_tools_synchro::info_file $message(filename) $message(filetype)] } msg ]
            if {$err} {
               set txt "ERROR : $msg"
               addlog $txt
               ::bdi_tools_synchro::I_send_var $channel status $txt
               flush $channel ; return
            }
            set flagsize      [lindex $r 0]
            set filesize_sql  [lindex $r 1]
            set filesize_disk [lindex $r 2]
            set modifdate     [lindex $r 3]
            set md5           [lindex $r 4]
            
            if {$flagsize=="DIFF"} {

               # le fichier sur le serveur n a pas la meme taille sur disque et dans la base
               #set txt "ERROR : Le fichier sur le serveur n a pas la meme taille sur disque et dans la base"
               #addlog $txt
               #::bdi_tools_synchro::I_send_var $channel status $txt
               #flush $channel ; return

               # A Corriger ?
               # il suffit de mettre dans la base la valeur de la taille sur disque

               set df [file dirname $message(filename)]
               set fn [file tail $message(filename)]
               set sqlcmd "SELECT idbddimg FROM images WHERE filename='$fn' AND dirfilename='$df';"
               set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
               if {$err} {
                 addlog  "Erreur SQL on SERVER: find idbddimg - err = $err\nsql = $sqlcmd\nmsg = $msg"
                 ::bdi_tools_synchro::I_send_var $channel status "ERROR"
                 flush $channel ; return
               }
               set data [lindex $data 0]
               set idbddimg [lindex $data 0]

               set sqlcmd "UPDATE images SET sizefich=$filesize_disk WHERE idbddimg=$idbddimg;"
               set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
               if {$err} {
                 addlog  "Erreur SQL on SERVER: UPDATE idbddimg - err = $err\nsql = $sqlcmd\nmsg = $msg"
                 ::bdi_tools_synchro::I_send_var $channel status "ERROR"
                 flush $channel ; return
               }

            }

            if {$message(filesize)!=$filesize_disk} {
               addlog  "DIFFERENT SIZE : : C:$message(filesize) SDisk:$filesize_disk File: $message(filename)"
               ::bdi_tools_synchro::I_send_var $channel status "DIFFERENT"
               # ok le fichier est different donc on peut continuer la synchro
               flush $channel ; return
            }
            if {$message(md5)!=$md5} {
               addlog  "DIFFERENT MD5 File: $message(filename)"
               ::bdi_tools_synchro::I_send_var $channel status "DIFFERENT"
               # ok le fichier est different donc on peut continuer la synchro
               flush $channel ; return
            }
            
            # les fichiers sont strictements identiques

            if {$message(modifdate) != $modifdate} {
               # mise a jour de la date de modification sur la base sql du serveur
               set err [catch { ::bdi_tools_synchro::set_modifdate $message(filename) $message(filetype) $message(modifdate) } msg]
               if {$err} {
                  addlog "ERROR : set modifdate : $msg"
                  ::bdi_tools_synchro::I_send_var $channel status "ERROR : set modifdate : $msg"
                  flush $channel ; return
               }

               addlog "CORRECTED"
               ::bdi_tools_synchro::I_send_var $channel status "CORRECTED"
               flush $channel ; return

            } else {
                  addlog "ERROR : Le fichier a l air identique pourquoi le corriger ?"
               ::bdi_tools_synchro::I_send_var $channel status "ERROR : Le fichier a l air identique pourquoi le corriger ?"
               flush $channel ; return
            }
            
         }
         "filetype" {
            set message(filetype) $val
         }
         "filename" {
            set message(filename) $val
         }
         "md5" {
            set message(md5) $val
         }
         "modifdate" {
            set message(modifdate) $val
         }
         "filesize" {
            set message(filesize) $val
         }
         "exist" {
            set message(exist) $val
         }
         "file" {
#               addlog "File : $message(filename) Download..."
#               set flog [open "/tmp/synchro.server.log" a]
#               puts $flog "reception du fichier"
#               close $flog
            #puts "reception du fichier : $message(filename)"
            
            ::bdi_tools_synchro::I_receive_file $channel message(tmpfile) $message(filesize)
            #set message(tmpfile) [file join $bddconf(dirtmp) "tmp.[pid].fits.gz"]
            #puts "tmpfile: $message(tmpfile)\n"
            ::bdi_tools_synchro::I_send_var $channel status "UPLOADED"
         }
         "DELETE" {
            if {![info exists message(filename)] } {
                  set txt "Unknown filename"
                  addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                  flush $channel ; return
            }
            if {![info exists message(filetype)] } {
                  set txt "Unknown filetype"
                  addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                  flush $channel ; return
            }
            if {![info exists message(filesize)] } {
                  set txt "Unknown filesize"
                  addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                  flush $channel ; return
            }
            if {![info exists message(modifdate)] } {
                  set txt "Unknown modifdate"
                  addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                  flush $channel ; return
            }

            set df [file dirname $message(filename)]
            set fn [file tail $message(filename)]
            set sqlcmd "SELECT idbddimg,sizefich,datemodif FROM images WHERE filename='$fn' AND dirfilename='$df';"
            set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$err} {
               ::bdi_tools_synchro::set_error $id "Erreur : find idbddimg - err = $err\nsql = $sqlcmd\nmsg = $msg"
               if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
            }

            set data [lindex $data 0]
            set idbddimg [lindex $data 0]
            set sizefich [lindex $data 1]
            set datemodif [lindex $data 2]
            
            set pass 1
            if {$datemodif!=$message(modifdate)} {
               #gren_erreur "erreur modifdate on serveur : $datemodif != $message(modifdate)\n"
               #set pass 0
            }
            if {$sizefich!=$message(filesize)} {
               #gren_erreur "erreur filesize on serveur : $sizefich != $message(filesize)\n"
               #set pass 0
            }
            if {$pass} {
            
               set err [catch {set ident [bddimages_image_identification $idbddimg]} msg ]
               if {$err} {
                  gren_erreur "DELETE : erreur identification\n"
                  return
               }
               set idbddimg     [lindex $ident 0]
               set fileimg      [lindex $ident 1]
               set idbddcata    [lindex $ident 2]
               set catafilebase [lindex $ident 3]
               set idheader     [lindex $ident 4]

               gren_info "Effacement de $idbddimg ; $fileimg ; $idbddcata ; $catafilebase ; $idheader\n"
               bddimages_image_delete $idbddimg
               addlog "DELETE : $message(filename) $idbddimg"
               ::bdi_tools_synchro::I_send_var $channel status "DELETED"
            }
            
         }
         "work" {
            
            update


            # TEST existance des variables
            if {![info exists message(synchro)] } {
                  set txt "Unknown synchro"
                  addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                  flush $channel ; return
            }
            if {![info exists message(filename)] } {
                  set txt "Unknown filename"
                  addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                  flush $channel ; return
            }
            if {![info exists message(filetype)] } {
                  set txt "Unknown filetype"
                  addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                  flush $channel ; return
            }






            if {$message(synchro)=="S->C"} {
               #gren_info "work      : $val \n"

               #gren_info "File      : $message(filename) \n"
               set dirfilename [file dirname $message(filename)]
               set filename [file tail $message(filename)]


               switch $message(filetype) {

                  "FITS" {
                     set sqlcmd "SELECT sizefich,datemodif FROM images WHERE filename LIKE BINARY '$filename' AND dirfilename LIKE BINARY '$dirfilename';"
                  }
                  "CATA" {
                     set sqlcmd "SELECT sizefich,datemodif FROM catas WHERE filename LIKE BINARY '$filename' AND dirfilename LIKE BINARY '$dirfilename';"
                  }
                  default {
                     set txt "Unknown filetype : $filetype"
                     addlog $txt
                     ::bdi_tools_synchro::I_send_var $channel status $txt
                     flush $channel
                     return
                  }               
               }
                  
               set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
               if {$err} {
                  set txt "Erreur : find sizefich & datemodif - err = $err\nsql = $sqlcmd\nmsg = $msg"
                  addlog $txt
                  ::bdi_tools_synchro::I_send_var $channel status $txt
                  flush $channel
                  return
               }
               set data [lindex $data 0]
               set filesize_sql [lindex $data 0]
               set modifdate    [lindex $data 1]
               
               #puts "filesize_sql = $filesize_sql\n"
               #puts "modifdate = $modifdate\n"
               
               #puts "dirbase = $bddconf(dirbase)\n"
               #puts "filename = $message(filename)\n"
               
               set file [file join $bddconf(dirbase) $message(filename)]
               
               if {![file exists $file]} {
                  set txt "Erreur : file not exist : $file"
                  addlog $txt
                  ::bdi_tools_synchro::I_send_var $channel status $txt
                  flush $channel
                  return
               }
               
               set err [catch {set filesize_disk [file size $file]} msg]
               if {$err} {
                  set txt "Erreur : sizefich impossible - err = $err\nmsg = $msg"
                  addlog $txt
                  ::bdi_tools_synchro::I_send_var $channel status $txt
                  flush $channel
                  return
               }                  

               if {$filesize_disk!=$filesize_sql} {
                  #set txt "Bad file size on serveur $filesize_disk!=$filesize_sql"
                  #addlog $txt
                  #::bdi_tools_synchro::I_send_var $channel status $txt
                  #flush $channel
                  #return
                  
                  # On corrige l erreur : 
                  set sqlcmd "UPDATE catas SET sizefich=$filesize_disk WHERE dirfilename LIKE BINARY '$dirfilename' AND filename LIKE BINARY '$filename';"
                  set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
                  if {$err} {
                     set txt  "Erreur : UPDATE CATAS - correction sizefich - err = $err\nsql = $sqlcmd\nmsg = $msg"
                     addlog $txt
                     ::bdi_tools_synchro::I_send_var $channel status $txt
                     flush $channel
                     return
                  }
                  set filesize_sql $filesize_disk
                  
               }

               set md5 [::bdi_tools_synchro::get_md5 $file]
               set filesize $filesize_sql

               ::bdi_tools_synchro::I_send_var $channel status "FILEOK"
               
               ::bdi_tools_synchro::I_send_var  $channel md5       $md5
               
               #puts "filesize = $filesize"
               ::bdi_tools_synchro::I_send_var  $channel filesize  $filesize
               ::bdi_tools_synchro::I_send_var  $channel modifdate $modifdate
               ::bdi_tools_synchro::I_send_file $channel $file     $filesize
            }
            



            if {$message(synchro)=="C->S"} {


               # TEST existance des variables
               if {![info exists message(filesize)] } {
                     set txt "Unknown filesize"
                     addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                     flush $channel ; return
               }
               if {![info exists message(modifdate)] } {
                     set txt "Unknown modifdate"
                     addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                     flush $channel ; return
               }
               if {![info exists message(exist)] } {
                     set txt "Unknown exist"
                     addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                     flush $channel ; return
               }
               if {![info exists message(md5)] } {
                     set txt "Unknown md5"
                     addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                     flush $channel ; return
               }
               if {![info exists message(tmpfile)] } {
                     set txt "Unknown tmpfile"
                     addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                     flush $channel ; return
               }



               #gren_info "work      : $val \n"
               #gren_info "File      : $message(filename)  \n"
               #gren_info "Filesize  : $message(filesize)  \n"
               #gren_info "Modifdate : $message(modifdate) \n"
               #gren_info "Exist     : $message(exist)     \n"
               #gren_info "MD5       : $message(md5)       \n"
               #gren_info "tmpfile   : $message(tmpfile)   \n"

               set md5_r [::bdi_tools_synchro::get_md5 $message(tmpfile)]
               if {$message(md5) != $md5_r} {
                  set txt "Erreur : Bad MD5"
                  addlog $txt
                  ::bdi_tools_synchro::I_send_var $channel status $txt
                  flush $channel
                  return
               }

               set newfile [file join $bddconf(dirtmp) [file tail $message(filename)] ]
               set err [catch {file rename -force $message(tmpfile) $newfile} msg]
               if {$err} {
                  set txt "Erreur : rename file : $msg"
                  addlog $txt
                  ::bdi_tools_synchro::I_send_var $channel status $txt
                  flush $channel
                  return
               }

               set df [file dirname $message(filename)]
               set fn [file tail $message(filename)]

               switch $message(filetype) {

                  "FITS" {

                     # recuperation de idbddimg
                     set sqlcmd "SELECT idbddimg FROM images WHERE filename='$fn' AND dirfilename='$df';"
                     set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
                     if {$err} {
                        set txt "Erreur : find idbddimg - err = $err\nsql = $sqlcmd\nmsg = $msg"
                        addlog $txt
                        ::bdi_tools_synchro::I_send_var $channel status $txt
                        flush $channel
                        return
                     }

                     if {[llength $data]==0} {
                        #gren_info "data vide\n"
                        set exist 0
                     } else {

                        catch { unset idbddimg }
                        set err [ catch { 
                                          set data [lindex $data 0]
                                          #gren_info "data = $data\n"
                                          set idbddimg [lindex $data 0] 
                                          #gren_info "idbddimg = $idbddimg\n"
                                        } msg ]
                        if {![info exists idbddimg]} {
                           set exist 0
                        } else {
                           set exist 1
                        }                  
                     }

                     if {!$message(exist) && $exist} {
                        set txt "Erreur : le fichier existe et ne devrait pas."
                        addlog $txt
                        ::bdi_tools_synchro::I_send_var $channel status $txt
                        flush $channel
                        return
                     }

                     if {$message(exist) && !$exist} { 
                        set txt "Erreur : le fichier n'existe pas alors qu'il devrait."
                        addlog $txt
                        ::bdi_tools_synchro::I_send_var $channel status $txt
                        flush $channel
                        return
                     }

                     if {$message(exist) && $exist} {
                        bddimages_image_delete $idbddimg
                     }

                     set err [catch {set idbddimg [insertion_solo $newfile]} msg]
                     if {$err} {
                        set txt "Erreur : insertion file : $msg"
                        addlog $txt
                        ::bdi_tools_synchro::I_send_var $channel status $txt
                        flush $channel
                        return
                     }
                     # modif la datemodif de $idbddimg
                     set sqlcmd "UPDATE images SET datemodif='$message(modifdate)' WHERE idbddimg=$idbddimg;"
                     set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
                     if {$err} {
                        set txt  "Erreur : UPDATE IMAGES - err = $err\nsql = $sqlcmd\nmsg = $msg"
                        addlog $txt
                        ::bdi_tools_synchro::I_send_var $channel status $txt
                        flush $channel
                        return
                     }

                  }
                  "CATA" {

                     set err [catch {set idbddcata [insertion_solo $newfile]} msg]
                     if {$err} {
                        set txt "Erreur : insertion file : $msg"
                        addlog $txt
                        ::bdi_tools_synchro::I_send_var $channel status $txt
                        flush $channel
                        return
                     }
                     # modif la datemodif de $idbddimg
                     set sqlcmd "UPDATE catas SET datemodif='$message(modifdate)' WHERE idbddcata=$idbddcata;"
                     set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
                     if {$err} {
                        set txt  "Erreur : UPDATE CATAS - err = $err\nsql = $sqlcmd\nmsg = $msg"
                        addlog $txt
                        ::bdi_tools_synchro::I_send_var $channel status $txt
                        flush $channel
                        return
                     }

                  }
                  default {
                     set txt "Unknown filetype : $filetype"
                     addlog $txt
                     ::bdi_tools_synchro::I_send_var $channel status $txt
                     flush $channel
                     return
                  }               
               }


               ::bdi_tools_synchro::I_send_var $channel status SUCCESS

            }
            
            flush $channel

            set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $::bdi_tools_synchro::tt0)/1000.]]
            
            addlog "Finish in $tt sec" "\n" ""

         }
      }
   }
}



# Construction du fichier de donnee pour etre rapatrié sur le client
proc ::bdi_tools_synchro::build_file_table_images { } {

   global bddconf

   ::bdi_tools_synchro::get_table_fitscata data
   
   set nb [llength $data]

   set filename [file join $bddconf(dirtmp) "table_images.dat"]
   set h [open $filename "w"]
   set data "set data { $data }"
   puts $h $data
   close $h
   ::bdi_tools::gzip $filename
   set filename "$filename.gz"
   set md5      [::bdi_tools_synchro::get_md5 $filename]
   set err [catch {set filesize [file size $filename]} msg]
   if {$err} {
     return -code 1 "Unknown file size"
   }

   return [list $md5 $filename $filesize]
}

