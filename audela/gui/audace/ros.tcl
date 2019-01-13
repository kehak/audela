#
#  file ros.tcl
#  brief Function to launch Robotic Observatory Software installation
#  author Alain KLOTZ
#  $Id: ros.tcl 13572 2016-04-02 19:13:43Z rzachantke $
#

proc ros { args } {
   global ros
   global meo
   global audace

   set ros(withtk) 1
   set err [catch {wm withdraw .} msg]
   if {$err==1} {
      set ros(withtk) 0
   }

   set action [lindex $args 0]
   set syntax "ros Software Keyword Action ?parameters?"

   if {$action=="install"} {
      source $audace(rep_install)/bin/ros_install.tcl
      ::ros_install::run
   } elseif {$action=="gardien"} {
      # source $audace(rep_install)/gui/audace/ros.tcl
      # ros gardien send SET init|roof_open|roof_close|flatfield_on|flatfield_off|dark_on|dark_off|native
      # case of native : ros gardien send SET native Power LCOUPOLE 1
      #set syntax "ros gardien send SET init|roof_open|roof_close|flatfield_on|flatfield_off|dark_on|dark_off|native ?params?"
      set action2 [lindex $args 1]
      set params [lrange $args 2 end]
      set err [catch {source [file join $::audela_start_dir ros_root.tcl]}]
      set ros(falsenameofexecutable) majordome
      source "$ros(root,ros)/src/common/macros.tcl"
      source "$ros(root,ros)/src/common/variables_globales.tcl"
      unset ros(falsenameofexecutable)
      set ros(req,gardien,gar,host) $ros(req,majordome,gar,host)
      set ros(req,gardien,gar,port) $ros(req,majordome,gar,port)
      set err [catch {source "$audace(rep_install)/gui/audace/socket_tools.tcl"}] ; if {$err==1} { source "$ros(root,audela)/gui/audace/socket_tools.tcl" }
      set err [catch {socket_client_open clientgar2 $ros(req,gardien,gar,host) [expr $ros(req,gardien,gar,port)+1]} msg]
      if {$err==1} {
         set texte $msg
         if {($ros(withtk)==0)||([info commands ::console::affiche_resultat]!="::console::affiche_resultat")} {
            puts "$texte"
         } else {
            ::console::affiche_resultat "$texte\n"
         }
         return
      }
      if {($action2=="send")} {
         socket_client_put clientgar2 "$params"
         set t0 [clock seconds]
         set sortie 0
         while {$sortie==0} {
            set msg [socket_client_get clientgar2]
            if {$msg!=""} { set sortie 1 ; break }
            if {[expr [clock seconds]-$t0]>15} {
               set sortie 2
               break
            }
            after 1000
         }
         if {$sortie==2} {
            set msg "No response after timeout."
         }
      } else {
         set msg "$syntax\nERROR: Action must be amongst send"
      }
      set texte $msg
      if {($ros(withtk)==0)||([info commands ::console::affiche_resultat]!="::console::affiche_resultat")} {
         puts "$texte"
      } else {
         ::console::affiche_resultat "$texte\n"
      }
      set ros(audela,gar_result) $texte
      socket_client_close clientgar2

   } elseif {$action=="telescope"} {
      # source ../gui/audace/ros.tcl
      # ros telescope send SET native ?params?
      # case of native : ros telescope send SET native #j-
      set action2 [lindex $args 1]
      set params [lrange $args 2 end]
      set err [catch {source [file join $::audela_start_dir ros_root.tcl]}] ; if {$err==1} { source "$ros(root,ros)/ros_root.tcl" }
      set ros(falsenameofexecutable) majordome
      source "$ros(root,ros)/src/common/macros.tcl"
      source "$ros(root,ros)/src/common/variables_globales.tcl"
      unset ros(falsenameofexecutable)
      set ros(req,telescope,tel,host) $ros(req,majordome,tel,host)
      set ros(req,telescope,tel,port) $ros(req,majordome,tel,port)
      set err [catch {source "$audace(rep_install)/gui/audace/socket_tools.tcl"}] ; if {$err==1} { source "$ros(root,audela)/gui/audace/socket_tools.tcl" }
      set err [catch {socket_client_open clienttel2 $ros(req,telescope,tel,host) [expr $ros(req,telescope,tel,port)+1]} msg]
      if {$err==1} {
         set texte $msg
         if {($ros(withtk)==0)||([info commands ::console::affiche_resultat]!="::console::affiche_resultat")} {
            puts "$texte"
         } else {
            ::console::affiche_resultat "$texte\n"
         }
         return
      }
      if {($action2=="send")} {
         socket_client_put clienttel2 "$params"
         after 2000
         set t0 [clock seconds]
         set sortie 0
         while {$sortie==0} {
            set msg [socket_client_get clienttel2]
            if {$msg!=""} { set sortie 1 ; break }
            if {[expr [clock seconds]-$t0]>15} {
               set sortie 2
               break
            }
            after 1000
         }
         if {$sortie==2} {
            set msg "No response after timeout."
         }
      } else {
         set msg "$syntax\nERROR: Action must be amongst send"
      }
      set texte $msg
      if {($ros(withtk)==0)||([info commands ::console::affiche_resultat]!="::console::affiche_resultat")} {
         puts "$texte"
      } else {
         ::console::affiche_resultat "$texte\n"
      }
      set ros(audela,tel_result) $texte
      socket_client_close clienttel2

   } elseif {$action=="camera"} {
      # source ../gui/audace/ros.tcl
      # ros telescope send SET native ?params?
      # case of native : ros telescope send SET native #j-
      set action2 [lindex $args 1]
      set params [lrange $args 2 end]
      set err [catch {source [file join $::audela_start_dir ros_root.tcl]}] ; if {$err==1} { source "$ros(root,ros)/ros_root.tcl" }
      set ros(falsenameofexecutable) majordome
      source "$ros(root,ros)/src/common/macros.tcl"
      source "$ros(root,ros)/src/common/variables_globales.tcl"
      unset ros(falsenameofexecutable)
      set ros(req,camera,cam,host) $ros(req,majordome,cam,host)
      set ros(req,camera,cam,port) $ros(req,majordome,cam,port)
      set err [catch {source "$audace(rep_install)/gui/audace/socket_tools.tcl"}] ; if {$err==1} { source "$ros(root,audela)/gui/audace/socket_tools.tcl" }
      set err [catch {socket_client_open clientcam2 $ros(req,camera,cam,host) [expr $ros(req,camera,cam,port)+1]} msg]
      if {$err==1} {
         set texte $msg
         if {($ros(withtk)==0)||([info commands ::console::affiche_resultat]!="::console::affiche_resultat")} {
            puts "$texte"
         } else {
            ::console::affiche_resultat "$texte\n"
         }
         return
      }
      if {($action2=="send")} {
         socket_client_put clientcam2 "$params"
         set t0 [clock seconds]
         set sortie 0
         while {$sortie==0} {
            set msg [socket_client_get clientcam2]
            if {$msg!=""} { set sortie 1 ; break }
            if {[expr [clock seconds]-$t0]>15} {
               set sortie 2
               break
            }
            after 1000
         }
         if {$sortie==2} {
            set msg "No response after timeout."
         }
      } else {
         set msg "$syntax\nERROR: Action must be amongst send"
      }
      set texte $msg
      if {($ros(withtk)==0)||([info commands ::console::affiche_resultat]!="::console::affiche_resultat")} {
         puts "$texte"
      } else {
         ::console::affiche_resultat "$texte\n"
      }
      set ros(audela,cam_result) $texte
      socket_client_close clientcam2

   } elseif {$action=="arduino"} {
      # source ../gui/audace/ros.tcl
      set action2 [lindex $args 1]
      set params [lrange $args 2 end]
      set err [catch {source [file join $::audela_start_dir ros_root.tcl]}]
      set ros(falsenameofexecutable) majordome
      source "$ros(root,ros)/src/common/macros.tcl"
      source "$ros(root,ros)/src/common/variables_globales.tcl"
      unset ros(falsenameofexecutable)
      set host $ros(req,majordome,gar,host)
      set port $ros(arduino,config,server,cgi,port)
      set err [catch {source "$audace(rep_install)/gui/audace/socket_tools.tcl"}] ; if {$err==1} { source "$ros(root,audela)/gui/audace/socket_tools.tcl" }
      set err [catch {socket_client_open clientard2 $host $port} msg]
      if {$err==1} {
         set texte $msg
         if {($ros(withtk)==0)||([info commands ::console::affiche_resultat]!="::console::affiche_resultat")} {
            puts "$texte"
         } else {
            ::console::affiche_resultat "$texte\n"
         }
         return
      }
      if {($action2=="send")} {
         socket_client_put clientard2 "$params"
         set t0 [clock seconds]
         set sortie 0
         while {$sortie==0} {
            set msg [socket_client_get clientard2]
            if {$msg!=""} { set sortie 1 ; break }
            if {[expr [clock seconds]-$t0]>15} {
               set sortie 2
               break
            }
            after 1000
         }
         if {$sortie==2} {
            set msg "No response after timeout."
         }
      } else {
         set msg "$syntax\nERROR: Action must be amongst send"
      }
      set texte $msg
      if {($ros(withtk)==0)||([info commands ::console::affiche_resultat]!="::console::affiche_resultat")} {
         puts "$texte"
      } else {
         ::console::affiche_resultat "$texte\n"
      }
      set ros(audela,gar_result) $texte
      socket_client_close clientard2

   } elseif {$action=="majordome"} {
      # source ../gui/audace/ros.tcl
      # ros majordome send DO ...
      set action2 [lindex $args 1]
      set params [lrange $args 2 end]
      set err [catch {source [file join $::audela_start_dir ros_root.tcl]}] ; if {$err==1} { source "$ros(root,ros)/ros_root.tcl" }
      set ros(falsenameofexecutable) majordome
      source "$ros(root,ros)/src/common/macros.tcl"
      source "$ros(root,ros)/src/common/variables_globales.tcl"
      unset ros(falsenameofexecutable)
      set ros(req,majordome,maj,host) $ros(req,majordome,maj,host)
      set ros(req,majordome,maj,port) $ros(req,majordome,maj,port)
      set err [catch {source "$audace(rep_install)/gui/audace/socket_tools.tcl"}] ; if {$err==1} { source "$ros(root,audela)/gui/audace/socket_tools.tcl" }
      set err [catch {socket_client_open clientmaj2 $ros(req,majordome,maj,host) [expr $ros(req,majordome,maj,port)+1]} msg]
      if {$err==1} {
         set texte $msg
         if {($ros(withtk)==0)||([info commands ::console::affiche_resultat]!="::console::affiche_resultat")} {
            puts "$texte"
         } else {
            ::console::affiche_resultat "$texte\n"
         }
         return
      }
      if {($action2=="send")} {
         socket_client_put clientmaj2 "$params"
         after 2000
         set t0 [clock seconds]
         set sortie 0
         while {$sortie==0} {
            set msg [socket_client_get clientmaj2]
            if {$msg!=""} { set sortie 1 ; break }
            if {[expr [clock seconds]-$t0]>15} {
               set sortie 2
               break
            }
            after 1000
         }
         if {$sortie==2} {
            set msg "No response after timeout."
         }
      } else {
         set msg "$syntax\nERROR: Action must be amongst send"
      }
      set texte $msg
      if {($ros(withtk)==0)||([info commands ::console::affiche_resultat]!="::console::affiche_resultat")} {
         puts "$texte"
      } else {
         ::console::affiche_resultat "$texte\n"
      }
      set ros(audela,maj_result) $texte
      socket_client_close clientmaj2

   } elseif {$action=="var"} {
      set action2 [lindex $args 1]
      set params [lrange $args 2 end]
      set err [catch {source [file join $::audela_start_dir ros_root.tcl]}] ; if {$err==1} { source "$ros(root,ros)/ros_root.tcl" }
      if {$action2=="files"} {
         set fout [lindex $params 0]
         global result
         set fichiers "$ros(root,audela)/gui/audace/ros.tcl\n"
         set filtre ""
         set result ""
         ros_analdir $ros(root,conf) $filtre
         append fichiers $result
         set result ""
         ros_analdir $ros(root,ros) $filtre
         append fichiers $result
         set fichiers [lsort [split $fichiers \n] ]
         set ros(audela,var,fichiers) [lrange $fichiers 0 end-1]
         set n [llength $ros(audela,var,fichiers)]
         if {$fout!=""} {
            set textes ""
            foreach fichier $ros(audela,var,fichiers) {
               append textes "$fichier\n"
            }
            set f [open $fout w]
            puts -nonewline $f $textes
            close $f
         }
         return $n
      } elseif {$action2=="find"} {
         # ros var find ros(toto)
         set var [lindex $params 0]
         if {$var==""} {
            set msg "$syntax\nERROR: Params must be: var ?file_out?"
            error $msg
         }
         set fout [lindex $params 1]
         ::console::affiche_resultat "Find $var:\n"
         set textes ""
         foreach fichier $ros(audela,var,fichiers) {
            set ext [file extension $fichier]
            if {($ext!=".tcl")&&($ext!=".ini")} {
               continue
            }
            set err [catch {set f [open $fichier r]}]
            if {$err==1} { continue }
            set lignes [split [read $f] \n]
            close $f
            set n [llength $lignes]
            #::console::affiche_resultat "$fichier : $n\n"
            for {set k 0} {$k<$n} {incr k} {
               set ligne [lindex $lignes $k]
               set col0 0
               set col [string first $var $ligne $col0]
               if {$col>=0} {
                  ::console::affiche_resultat "$fichier ($k) => $ligne\n"
                  append textes "$fichier ($k) => $ligne\n"
               }
            }
         }
         if {$fout!=""} {
            set f [open $fout w]
            puts -nonewline $f $textes
            close $f
         }
      } elseif {$action2=="findarray"} {
         # ros var findarray info => copier/coller dans globales.txt
         set var [lindex $params 0]
         if {$var==""} {
            set msg "$syntax\nERROR: Params must be: var ?file_out?"
            error $msg
         }
         set fout [lindex $params 1]
         ::console::affiche_resultat "Find $var:\n"
         set textes ""
         set thearrays ""
         foreach fichier $ros(audela,var,fichiers) {
            set ext [file extension $fichier]
            if {($ext!=".tcl")&&($ext!=".ini")} {
               continue
            }
            set err [catch {set f [open $fichier r]}]
            if {$err==1} { continue }
            set lignes [split [read $f] \n]
            close $f
            set n [llength $lignes]
            #::console::affiche_resultat "$fichier : $n\n"
            for {set k 0} {$k<$n} {incr k} {
               set ligne [lindex $lignes $k]
               set col0 0
               set col [string first "${var}(" $ligne $col0]
               if {$col>=0} {
                  set colfin [string first ) $ligne $col]
                  set thearray [string range $ligne $col $colfin]
                  ::console::affiche_resultat "$fichier ($k) $thearray => $ligne\n"
                  append textes "$fichier ($k) $thearray => $ligne\n"
                  lappend thearrays "$thearray"
               }
            }
         }
         set thearrays [lsort $thearrays]
         set thearray0 ""
         set textes ""
         foreach thearray $thearrays {
            if {$thearray!=$thearray0} {
               append textes "$thearray\n"
               ::console::affiche_resultat "ARRAY $thearray\n"
               set thearray0 $thearray
            }
         }
         if {$fout!=""} {
            set f [open $fout w]
            puts -nonewline $f $textes
            close $f
         }
      } elseif {$action2=="array2ros"} {
         # ros var array2ros globales.txt rosvar.txt
         set fin [lindex $params 0]
         set fout [lindex $params 1]
         if {($fin=="")||($fout=="")} {
            set msg "$syntax\nERROR: Params must be: file_in file_out"
            error $msg
         }
         set err [catch {set f [open $fin r]} msg]
         if {$err==1} {
            error $msg
         }
         set lignes [split [read $f] \n]
         close $f
         set n [llength $lignes]
         set textes ""
         for {set k 0} {$k<$n} {incr k} {
            set ligne [lindex $lignes $k]
            set nc [llength $ligne]
            if {$nc!=3} {
               append textes "$ligne\n"
               continue
            }
            set car [lindex $ligne 0]
            if {$car=="##"} {
               append textes "$ligne\n"
               continue
            }
            set var [lindex $ligne 2]
            set colfin [string first ( $var 0]
            set array0 [string range $var 0 [expr $colfin-1]]
            if {$array0=="ros"} {
               set var ""
            } elseif {$array0=="roc"} {
               regsub "${array0}\\(" $var common( a
               set var $a
            } elseif {$array0=="gren"} {
               regsub "${array0}\\(" $var common( a
               set var $a
            } elseif {$array0=="info"} {
               regsub "${array0}\\(" $var caption( a
               set var $a
            }
            #::console::affiche_resultat "var=$var\n"
            if {$var!=""} {
               regsub \\( $var , a
               set var "ros($a"
            }
            append textes "$ligne $var\n"
         }
         if {$fout!=""} {
            set f [open $fout w]
            puts -nonewline $f $textes
            close $f
         }
      } elseif {$action2=="ros2map"} {
         # ros var ros2map rosvar.txt
         set fin [lindex $params 0]
         if {($fin=="")} {
            set msg "$syntax\nERROR: Params must be: file_in"
            error $msg
         }
         set err [catch {set f [open $fin r]} msg]
         if {$err==1} {
            error $msg
         }
         set lignes [split [read $f] \n]
         close $f
         set ros(audela,var,map) ""
         set n [llength $lignes]
         set textes ""
         set array00 ""
         set ros(audela,var,arrays) ""
         for {set k 0} {$k<$n} {incr k} {
            set ligne [lindex $lignes $k]
            set nc [llength $ligne]
            if {$nc<=3} {
               append textes "$ligne\n"
               continue
            }
            set car [lindex $ligne 0]
            if {$car=="##"} {
               append textes "$ligne\n"
               continue
            }
            set varin [lindex $ligne 2]
            set varout [lindex $ligne 3]
            set colfin [string first ( $varin 0]
            set array0 [string range $varin 0 [expr $colfin-1]]
            if {$array0!=$array00} {
               lappend ros(audela,var,arrays) $array0
               set array00 $array0
            }
            append ros(audela,var,map) "$varin $varout "
         }
         foreach array0 $ros(audela,var,arrays) {
            append ros(audela,var,map) "\"global $array0\" \"global ros\" "
         }
         ::console::affiche_resultat "$ros(audela,var,map)\n"
      } elseif {$action2=="replacearrays"} {
         # ros var replacearrays
         if {[info exists ros(audela,var,map)]==0} {
            set msg "$syntax\nERROR: Execute ros var var ros2map before..."
            error $msg
         }
         set textes ""
         set thearrays ""
         foreach fichier $ros(audela,var,fichiers) {
            set ext [file extension $fichier]
            if {($ext!=".tcl")&&($ext!=".ini")} {
               continue
            }
            set err [catch {set f [open $fichier r]}]
            if {$err==1} { continue }
            set lignes [split [read $f] \n]
            close $f
            set n [llength $lignes]
            set nmap 0
            set ligne2s ""
            #::console::affiche_resultat "$fichier : $n\n"
            for {set k 0} {$k<$n} {incr k} {
               set ligne [lindex $lignes $k]
               set ligne2 [string map $ros(audela,var,map) $ligne]
               if {[string compare $ligne $ligne2]!=0} {
                  incr nmap
               }
               append ligne2s "$ligne2\n"
            }
            if {$nmap>0} {
               ::console::affiche_resultat "$fichier => $nmap\n"
               set f [open $fichier w]
               puts -nonewline $f "$ligne2s"
               close $f
            }
         }
      } elseif {$action2=="replaceword"} {
         # ros var replaceany old_work new_word
         set old_word [lindex $params 0]
         set new_word [lindex $params 1]
         if {$new_word==""} {
            set msg "$syntax\nERROR: ros var $action2 old_word new_word"
            error $msg
         }
         if {[info exists ros(audela,var,fichiers)]==0} {
            set msg "$syntax\nERROR: Execute ros var files before..."
            error $msg
         }
         set textes ""
         set thearrays ""
         foreach fichier $ros(audela,var,fichiers) {
            set ext [file extension $fichier]
            if {($ext!=".tcl")&&($ext!=".ini")} {
               continue
            }
            set err [catch {set f [open $fichier r]}]
            if {$err==1} { continue }
            set lignes [split [read $f] \n]
            close $f
            set n [llength $lignes]
            set nmap 0
            set ligne2s ""
            #::console::affiche_resultat "$fichier : $n\n"
            for {set k 0} {$k<$n} {incr k} {
               set ligne [lindex $lignes $k]
               set ligne2 [string map [list $old_word $new_word] $ligne]
               if {[string compare $ligne $ligne2]!=0} {
                  incr nmap
               }
               append ligne2s "$ligne2\n"
            }
            if {$nmap>0} {
               ::console::affiche_resultat "$fichier => $nmap\n"
               set f [open $fichier w]
               puts -nonewline $f "$ligne2s"
               close $f
            }
         }
      } else {
         set msg "$syntax\nERROR: Action must be amongst files find findarray ros2map replacearrays replaceword"
      }

   } elseif {$action=="modpoi"} {
      # source ../gui/audace/ros.tcl
      # ros modpoi make_doc
      set action2 [lindex $args 1]
      set params [lrange $args 2 end]
      set err [catch {source [file join $::audela_start_dir ros_root.tcl]}] ; if {$err==1} { source "$ros(root,ros)/ros_root.tcl" }
      set ros(falsenameofexecutable) trireq
      source "$ros(root,ros)/src/common/variables_globales.tcl"
      unset ros(falsenameofexecutable)
      set ros(rosmodpoi,home) $ros(common,home)
      set meo(home) $ros(common,home)
      # quid du UTC-TT ?
      set rosmodpoi_modpoi(var,home) $ros(rosmodpoi,home)
      set ros(rosmodpoi,cathipmain) hip_main.dat ; # catalogue Hipparcos original
      set ros(rosmodpoi,cathipshort) hip.txt ; # catalogue Hipparcos simplifie pour MEO
      set ros(rosmodpoi,path) "[pwd]"
      set ros(rosmodpoi,source) "$audace(rep_install)/gui/audace/ros.tcl"
      catch {load "$ros(rosmodpoi,path)/libmc[info sharedlibextension]"}
      catch {load "$ros(rosmodpoi,path)/libgsltcl[info sharedlibextension]"}
      set ros(rosmodpoi,file,log) "$ros(rosmodpoi,path)/rosmodpoi_log.txt"
      set ros(rosmodpoi,mount) "equatorial"
      if {$ros(rosmodpoi,mount)=="altaz"} {
         set ros(rosmodpoi,modpoi,coefs,symbs)     {IA                      IE                     NPAE                       CA                               AN                        AW                        ACEC                    ECEC                               ACES                     ECES NRX NRY ACEC2 ACES2 ACEC3 ACES3 AN2 AW2 AN3 AW3 ACEC4 ACES4 AN4 AW4 ACEC5 ACES5 AN5 AW5 ACEC6 ACES6 AN6 AW6}
         set ros(rosmodpoi,modpoi,coefs,intitules) {"Décalage du codeur A" "Décalage du codeur E" "Non perpendicularité A/E" "Non perpendicularité A/optique" "Décalage N-S de l'axe A" "Décalage E-W de l'axe A" "Décentrement A en cos" "Décentrement E en cos (flexion)"  "Décentrement A en sin"  "Décentrement E en sin" "Déplacement vertical du Nasmyth" "Déplacement vertical du Nasmyth" "Décentrement 2A en cos" "Décentrement 2A en sin" "Décentrement 3A en cos" "Décentrement 3A en sin" "décalage N-S de l'axe 2A" "Décalage E-W de l'axe 2A" "décalage N-S de l'axe 3A" "Décalage E-W de l'axe 3A" "Décentrement 4A en cos" "Décentrement 4A en sin" "décalage N-S de l'axe 4A" "Décalage E-W de l'axe 4A" "Décentrement 5A en cos" "Décentrement 5A en sin" "décalage N-S de l'axe 5A" "Décalage E-W de l'axe 5A" "Décentrement 6A en cos" "Décentrement 6A en sin" "décalage N-S de l'axe 6A" "Décalage E-W de l'axe 6A"}
      } else {
         set ros(rosmodpoi,modpoi,coefs,symbs)     {IH                      ID                     NP                         CH                               ME                              MA                              TF                          FO                    DAF                 HF                        TX                          DNP                              FARHC         FARHS         FARDC         FARDS         FARHC2         FARHS2         FARHC3         FARHS3         FARDC2         FARDS2         IHDEG               IHATAN         FARHCATAN           FARHSATAN           X1HS                    X1HC}
         set ros(rosmodpoi,modpoi,coefs,intitules) {"Décalage du codeur H" "Décalage du codeur D" "Non perpendicularité H/D" "Non perpendicularité D/optique" "Décalage N-S de l'axe polaire" "Décalage E-W de l'axe polaire" "Flexion de tube en sin(z)" "Flexion de fourche"  "Flexion de l'axe D" "Flexion du fer a cheval" "Flexion de tube en tan(z)" "Non perpendicularite dynamique" "FARO H cosh" "FARO H sinh" "FARO D cosh" "FARO D sinh" "FARO H cos2h" "FARO H sin2h" "FARO H cos3h" "FARO H sin3h" "FARO D cos2h" "FARO D sin2h" "FARO H drift/Hdeg" "FARO IH*atan" "FARO cos(ha)*atan" "FARO sin(ha)*atan" "effet sin(H) sur E-W" "effet cos(H) sur E-W"}
      }
      set ros(rosmodpoi,pi) [expr 4.*atan(1)]
      set argus [lrange $args 2 end]
      #
      if {$action2=="path"} {
         rosmodpoi_info "$ros(rosmodpoi,path)"
      } elseif {$action2=="hip"} {
         if {[llength $argus]<1} {
            error "Erreur: ros modpoi hip maglim."
         }
         set maglim [lindex $argus 0]
         rosmodpoi_convcat_hip "c:/d/faro/$ros(rosmodpoi,cathipmain)" "$ros(rosmodpoi,path)/hip.txt" 2 $maglim
      } elseif {$action2=="reset"} {
         # ros modpoi reset 3 7 ecarts.txt
         if {[llength $argus]<3} {
            error "Erreur: ros modpoi reset nsites ngisements fichier_ecarts."
         }
         set ros(rosmodpoi,nsites) [lindex $argus 0]
         set ros(rosmodpoi,ngisements) [lindex $argus 1]
         set ros(rosmodpoi,fichier_ecarts) [lindex $argus 2]
         set ros(rosmodpoi,index_etoile) -1
         rosmodpoi_info "ros(common,mode)=$ros(common,mode)"
         rosmodpoi_info "ngisements=$ros(rosmodpoi,ngisements)"
         rosmodpoi_info "nsites=$ros(rosmodpoi,nsites)"
         rosmodpoi_info "fichier_ecarts=$ros(rosmodpoi,path)/$ros(rosmodpoi,fichier_ecarts) EFFACE"
         rosmodpoi_modpoi_reset_stars "$ros(rosmodpoi,path)/$ros(rosmodpoi,fichier_ecarts)" ; # efface le fichier d'ecarts actuel
         rosmodpoi_info "Next function: ros modpoi star next"
      } elseif {$action2=="star"} {
         if {[llength $argus]<1} {
            error "Erreur: ros modpoi goto index(0...[expr $ros(rosmodpoi,ngisements)*$ros(rosmodpoi,nsites)])|next\nUse this function after ros modpoi reset."
         }
         set k [lindex $argus 0]
         if {$k!="next"} {
            set ros(rosmodpoi,index_etoile) $k
         }
         set n [expr $ros(rosmodpoi,ngisements)*$ros(rosmodpoi,nsites)]
         set sortie 0
         while {$sortie==0} {
            if {$k=="next"} {
               if {$ros(rosmodpoi,index_etoile)>$n} {
                  rosmodpoi_info "List complete !!!"
                  rosmodpoi_info "Next function: ros modpoi compute"
                  return
               } else {
                  incr ros(rosmodpoi,index_etoile)
               }
            }
            set etoile [rosmodpoi_modpoi_choose_star $ros(rosmodpoi,index_etoile) $ros(rosmodpoi,nsites) $ros(rosmodpoi,ngisements) "$ros(rosmodpoi,path)/hip.txt" now]
            #
            set etoile "[lindex $etoile 0]"
            set date_deb [mc_datescomp now + [expr 0/86400.]]
            set date_fin [mc_datescomp now + [expr 1/86400.]]
            set temperature 290
            set pression 101325
            set res [rosmodpoi_corrected_positions "" $date_deb $date_fin STAR_COORD_ONEPOS_TCL [lrange $etoile 2 end] $temperature $pression ""]
            rosmodpoi_info "res=$res"
            set site [lindex $res 1]
            set gise [lindex $res 2]
            set ha [lindex $res 7]
            set dec [lindex $res 8]
            rosmodpoi_info "SITE=[mc_angle2dms $site 90 auto 1 + string] GISEMENT=[mc_angle2dms $gise 360 auto 1 auto string] HA=[mc_angle2hms $ha 360 zero 1 auto string] DEC=[mc_angle2dms $dec 90 zero 1 + string]"
            set valid 1
            if {$site<15} {
               rosmodpoi_info "Problem: Star NON VISIBLE (site=$site)"
               set valid 0
            }
            if {$dec>=$ros(trireq,dec,lim_max)} {
               rosmodpoi_info "Problem: Star DEC > $ros(trireq,dec,lim_max)"
               set valid 0
            }
            if {$dec<=$ros(trireq,dec,lim_min)} {
               rosmodpoi_info "Problem: Star DEC < $ros(trireq,dec,lim_min)"
               set valid 0
            }
            if {($ha<=$ros(trireq,ha,lim_rise))&&($ha>=180)} {
               rosmodpoi_info "Problem: Star HA < $ros(trireq,ha,lim_rise)"
               set valid 0
            }
            if {($ha>=$ros(trireq,ha,lim_set))&&($ha<180)} {
               rosmodpoi_info "Problem: Star HA > $ros(trireq,ha,lim_set)"
               set valid 0
            }
            set ros(rosmodpoi,etoile) "$etoile"
            rosmodpoi_info "index=$ros(rosmodpoi,index_etoile): $ros(rosmodpoi,etoile) valid=$valid"
            if {$k!="next"} {
               set sortie 1
               break
            }
            if {$valid==1} {
               set sortie 1
               break
            }
         }
         if {$valid==1} {
            rosmodpoi_info "Next function: ros modpoi goto"
         } else {
            rosmodpoi_info "Next function: ros modpoi star next"
         }
      } elseif {$action2=="goto"} {
         # ros modpoi goto
         set date_deb [mc_datescomp now + [expr 0/86400.]]
         set date_fin [mc_datescomp now + [expr 1/86400.]]
         set temperature 290
         set pression 101325
         set res [rosmodpoi_corrected_positions "" $date_deb $date_fin STAR_COORD_ONEPOS_TCL [lrange $ros(rosmodpoi,etoile) 2 end] $temperature $pression ""]
         set ros(rosmodpoi,rao) [lindex $res 6]
         set ros(rosmodpoi,deco) [lindex $res 8]
         ros telescope send TEL radec motor on
         after 1000
         rosmodpoi_info "ros telescope send GOTO $ros(rosmodpoi,rao) $ros(rosmodpoi,deco)"
         ros telescope send GOTO $ros(rosmodpoi,rao) $ros(rosmodpoi,deco)
         rosmodpoi_info "index=$ros(rosmodpoi,index_etoile): $ros(rosmodpoi,etoile)"
         rosmodpoi_info "$res"
         rosmodpoi_info "NOW CENTER THE STAR WITH THE PAD..."
         rosmodpoi_info "Next function: ros modpoi add"
      } elseif {$action2=="add"} {
         ros telescope send TEL radec coord
         if {$ros(audela,tel_result)==""} {
            ros telescope send DO socket audela ; # reboot le socket si necessaire
         }
         #set ros(audela,tel_result) [list $ros(rosmodpoi,rao) $ros(rosmodpoi,deco)]
         set ra [lindex $ros(audela,tel_result) 0]
         set dec [lindex $ros(audela,tel_result) 1]
         rosmodpoi_info "calcul [mc_angle2hms $ros(rosmodpoi,rao) 360 zero 2 auto string] [mc_angle2dms $ros(rosmodpoi,deco) 90 zero 1 + string] ET observe $ra $dec"
         set dha  [expr ([mc_angle2deg $ra] -[mc_angle2deg $ros(rosmodpoi,rao)] )*60.]
         set ddec [expr ([mc_angle2deg $dec]-[mc_angle2deg $ros(rosmodpoi,deco)])*60.]
         set dsite [format %.5f $dha]
         set dgise [format %.5f $ddec]
         set temperature 290
         set pression 101325
         set res [rosmodpoi_modpoi_add_star "$ros(rosmodpoi,etoile)" $dsite $dgise "$ros(rosmodpoi,fichier_ecarts)" [mc_date2jd now] $temperature $pression]
         rosmodpoi_info "index=$ros(rosmodpoi,index_etoile): $ros(rosmodpoi,etoile)"
         rosmodpoi_info "Star shift recorded with success in $ros(rosmodpoi,fichier_ecarts)"
         set n [expr $ros(rosmodpoi,ngisements)*$ros(rosmodpoi,nsites)]]
         if {$ros(rosmodpoi,index_etoile)==$n} {
            rosmodpoi_info "Next function: ros modpoi compute modele.txt {ID IH ME MA HF FO}"
         } else {
            rosmodpoi_info "Next function: ros modpoi star next"
         }
      } elseif {$action2=="readfile"} {
         rosmodpoi_info "File $ros(rosmodpoi,fichier_ecarts):"
         set f [open "$ros(rosmodpoi,fichier_ecarts)" r]
         set contents [read $f]
         close $f
         rosmodpoi_info "\n$contents"
      } elseif {$action2=="compute"} {
         if {[llength $argus]<2} {
            error "Erreur: ros modpoi compute model_file symbols."
         }
         set fichier_ecarts "$ros(rosmodpoi,fichier_ecarts)"
         set ros(rosmodpoi,fichier_modele) [lindex $argus 0]
         set ros(rosmodpoi,model_symbols) [lindex $argus 1]
         rosmodpoi_modpoi_compute_model "$fichier_ecarts" "$ros(rosmodpoi,fichier_modele)" $ros(rosmodpoi,model_symbols)
      } else {
         set function [lindex $action2 0]
         rosmodpoi_info "function=$function"
         if {([info commands $function]==0)||($function=="")} {
            set functions [info commands rosmodpoi_*]
            set texte "Error, \"$action2\" not amongst make_doc"
            foreach function $functions {
               append texte ", $function"
            }
            append texte "."
            rosmodpoi_info "$texte"
         } else {
            set err [catch {eval $action2} $msg]
            if {$err==1} {
               rosmodpoi_info "Error, $msg."
            }
         }
      }

   } else {
      set texte "$syntax"
      append texte "\nERROR: Software must amongst install gardien telescope camera majordome var modpoi"
      if {$ros(withtk)==0} {
         puts "$texte"
      } else {
         ::console::affiche_resultat "$texte\n"
      }

   }
}

proc  ros_analdir { base {filefilter *} } {
   global result resultfile
   set listfiles ""
   set a [catch {set listfiles [glob ${base}/${filefilter}]} msg]
   if {$a==0} {
      # --- tri des fichiers dans l'ordre chrono decroissant
      set listdatefiles ""
      foreach thisfile $listfiles {
         set a [file isdirectory $thisfile]
         if {($a>=0) && ([file tail $thisfile] != ".svn") && ([file tail $thisfile] != "CVS")} {
            set datename [file mtime $thisfile]
            lappend listdatefiles [list $datename $thisfile]
         }
      }
      set listdatefiles [lsort -decreasing $listdatefiles]
      # --- isole les fichiers
      foreach thisdatefile $listdatefiles {
         set thisfile [lindex $thisdatefile 1]
         set a [file isdirectory $thisfile]
         if {($a>=0) && ([file tail $thisfile] != ".svn") && ([file tail $thisfile] != "CVS")} {
            append result "$thisfile\n"
         }
      }
      #set f [open $resultfile a]
      #puts -nonewline $f "$result"
      #close $f
      #set result ""
      # --- recursivite sur les dossiers
      foreach thisfile $listfiles {
         set a [file isdirectory $thisfile]
         if {$a==1} {
            if {([file tail $thisfile] != "CVS") && ([file tail $thisfile] != ".svn")} {
               ros_analdir $thisfile
            }
         }
      }
   }
}

####################################################################################"
####################################################################################"
# TOOLS
####################################################################################"
####################################################################################"

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_info
# ------------------------------------------------------------------------------------
#
# BUT : Utilitaire d'affichage dans la console pour debug (console de Aud'ACE s'il le faut)
#
# INPUTS : Chaine
#
# OUTPUTS : -
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_info { msg } {
   if {[info commands ::console::affiche_resultat]!=""} {
      ::console::affiche_resultat "$msg\n"
   } else {
      puts "$msg"
   }
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_log
# ------------------------------------------------------------------------------------
#
# BUT : Utilitaire de log pour MEO pour debug
#
# INPUTS : Chaine
#
# OUTPUTS : fichier ros(rosmodpoi,file,log)
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_log { msg } {
   global ros
   catch {
      set f [open "$ros(rosmodpoi,file,log)" a]
      set date [mc_date2jd now]
      puts $f "$date : $msg"
      close $f
   }
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_azimelev2sitegise
# ------------------------------------------------------------------------------------
#
# BUT : Transforme un couple azimut elevation en un couple site gisement
#
# INPUTS : azimut, elevation en degres
#
# OUTPUTS : site, gisement en degrees
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_azimelev2sitegise { azim elev } {
   #set gisement [expr 180.-$azim]
   set gisement [expr $azim-180.]
   if {$gisement<0} {
      set gisement [expr 360.+$gisement]
   }
   set site $elev
   return [list $site $gisement]
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_sitegise2azimelev
# ------------------------------------------------------------------------------------
#
# BUT : Transforme un couple site gisement en un couple azimut elevation
#
# INPUTS : site, gisement en degrees
#
# OUTPUTS : azimut, elevation en degres
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_sitegise2azimelev { site gisement } {
   #set azim [expr 180.-$gisement]
   set azim [expr $gisement-180.]
   if {$azim<0} {
      set azim [expr 360.+$azim]
   }
   set elev $site
   return [list $azim $elev]
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_make_doc
# ------------------------------------------------------------------------------------
#
# BUT : Fabrique la documentation ASCII de ce fichier
#
# INPUTS : Fichier de documentation
#
# OUTPUTS : Une doc simple.
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_make_doc { {fichier_doc ""} } {
   global ros
   if {$fichier_doc==""} {
      set fichier_doc "$ros(rosmodpoi,path)/rosmodpoi_doc.txt"
   }
   # --- on scane le fichier Tcl
   set f [open "$ros(rosmodpoi,source)" r]
   set lignes [split [read $f] \n]
   close $f
   set newproc 0
   set textes ""
   foreach ligne $lignes {
      set ligdeb [string range $ligne 0 0]
      #rosmodpoi_info "A ligdeb=<$ligdeb> newproc=$newproc"
      if {$ligdeb!="#"} {
         if {$newproc==1} {
            append textes "######################################################################################\n\n"
         }
         set newproc 0
         continue
      }
      #rosmodpoi_info "B ligdeb=<$ligdeb> newproc=$newproc"
      set ligdeb [string range $ligne 0 8]
      if {$ligdeb=="# PROC : "} {
         set newproc 1
         append txts "\n[string range $ligne 2 end]\n"
         append textes "######################################################################################\n"
      }
      #rosmodpoi_info "C ligdeb=<$ligdeb> newproc=$newproc"
      set ligdeb [string range $ligne 0 7]
      if {($ligdeb=="# BUT : ")&&($newproc==1)} {
         append txts "       [string range $ligne 8 end]\n"
      }
      #rosmodpoi_info "D ligdeb=<$ligdeb> newproc=$newproc"
      if {$newproc==1} {
         append textes "$ligne\n"
      }
   }
   set f [open ${fichier_doc} w]
   puts -nonewline $f "#####################################################\n"
   puts -nonewline $f "### GUIDE DE L'UTILISATEUR DE rosmodpoi_TOOLS\n"
   puts -nonewline $f "#####################################################\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "=> Ne pas oublier de commencer par \"source audace/ros.tcl\"\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "-----------------------------------------------------\n"
   puts -nonewline $f " Recuperer les infos sur le Soleil et la Lune\n"
   puts -nonewline $f " (positions, phase, lever, coucher).\n"
   puts -nonewline $f "-----------------------------------------------------\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "rosmodpoi_infoscelestes\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "-----------------------------------------------------\n"
   puts -nonewline $f " Generer un fichier de positions sans modele de pointage\n"
   puts -nonewline $f " d'une etoile proche d'une position site,gisement\n"
   puts -nonewline $f " entre maintenant + 1 min et maintenant + 1 min 1 s.\n"
   puts -nonewline $f "-----------------------------------------------------\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "set site 45\n"
   puts -nonewline $f "set gisement 300\n"
   puts -nonewline $f "set fichier_positions \"c:/d/meo/positions.txt\"\n"
   puts -nonewline $f "set date_deb \[mc_datescomp now + \[expr 60/86400.\]\]\n"
   puts -nonewline $f "set date_fin \[mc_datescomp \$date_deb + \[expr 1/86400.\]\]\n"
   puts -nonewline $f "set temperature 290\n"
   puts -nonewline $f "set pression 101325\n"
   puts -nonewline $f "set etoile \[rosmodpoi_close_star \$site \$gisement\]\n"
   puts -nonewline $f "rosmodpoi_corrected_positions \$fichier_positions \$date_deb \$date_fin STAR_COORD \[lrange \$etoile 2 end\] \$temperature \$pression \"\"\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "-----------------------------------------------------\n"
   puts -nonewline $f " Generer le fichier d'ecarts pour calculer un modèle de pointage.\n"
   puts -nonewline $f "-----------------------------------------------------\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "set ngisements 6 ; # nombre de gisements à pointer\n"
   puts -nonewline $f "set nsites 3 ; # nombre d'elevations a pointer pour un gisement donné\n"
   puts -nonewline $f "set nstars \[expr \$ngisements*\$nsites\] ; # nombre d'etoiles de réference à pointer\n"
   puts -nonewline $f "set fichier_ecarts \"c:/d/meo/ecarts.txt\"\n"
   puts -nonewline $f "rosmodpoi_modpoi_reset_stars \"\$fichier_ecarts\" ; # efface le fichier d'ecarts actuel\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "=> On fait une boucle sur k entre 0 et \$nstars-1 \n"
   puts -nonewline $f "set etoile \[rosmodpoi_modpoi_choose_star \$k \$nsites \$ngisements\]\n"
   puts -nonewline $f "set fichier_positions \"c:/d/meo/positions.txt\"\n"
   puts -nonewline $f "set date_deb \[mc_datescomp now + \[expr 60/86400.\]\]\n"
   puts -nonewline $f "set date_fin \[mc_datescomp \$date_deb + \[expr 1/86400.\]\]\n"
   puts -nonewline $f "set temperature 290\n"
   puts -nonewline $f "set pression 101325\n"
   puts -nonewline $f "rosmodpoi_corrected_positions \$fichier_positions \$date_deb \$date_fin STAR_COORD \[lrange \$etoile 2 end\] \$temperature \$pression \"\"\n"
   puts -nonewline $f "=> Le telescope pointe les positions\n"
   puts -nonewline $f "=> L'operateur fait les corrections de boule \$dsite et \$dgise\n"
   puts -nonewline $f "rosmodpoi_modpoi_add_star \$etoile \$dsite \$dgise \"\$fichier_ecarts\" \[mc_date2jd now\] \$temperature \$pression\n"
   puts -nonewline $f "=> On passe a l'etoile suivante\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "-----------------------------------------------------\n"
   puts -nonewline $f " Calculer le modèle de pointage.\n"
   puts -nonewline $f "-----------------------------------------------------\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "set fichier_ecarts \"c:/d/meo/ecarts.txt\"\n"
   puts -nonewline $f "set fichier_modele \"c:/d/meo/modele.txt\"\n"
   puts -nonewline $f "rosmodpoi_modpoi_compute_model \"\$fichier_ecarts\" \"\$fichier_modele\"\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "-----------------------------------------------------\n"
   puts -nonewline $f " Verifier le modèle de pointage.\n"
   puts -nonewline $f "-----------------------------------------------------\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "set fichier_ecarts \"c:/d/meo/ecarts.txt\"\n"
   puts -nonewline $f "set fichier_modele \"c:/d/meo/modele.txt\"\n"
   puts -nonewline $f "rosmodpoi_modpoi_verify_model \"\$fichier_ecarts\" \"\$fichier_modele\"\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "-----------------------------------------------------\n"
   puts -nonewline $f " Generer un fichier de positions avec modele de pointage\n"
   puts -nonewline $f " d'une etoile proche d'une position site,gisement\n"
   puts -nonewline $f " entre maintenant + 1 min et maintenant + 1 min 1 s.\n"
   puts -nonewline $f "-----------------------------------------------------\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "set fichier_modele \"c:/d/meo/modele.txt\"\n"
   puts -nonewline $f "set site 45\n"
   puts -nonewline $f "set gisement 300\n"
   puts -nonewline $f "set fichier_positions \"c:/d/meo/positions.txt\"\n"
   puts -nonewline $f "set date_deb \[mc_datescomp now + \[expr 60/86400.\]\]\n"
   puts -nonewline $f "set date_fin \[mc_datescomp \$date_deb + \[expr 1/86400.\]\]\n"
   puts -nonewline $f "set temperature 290\n"
   puts -nonewline $f "set pression 101325\n"
   puts -nonewline $f "set etoile \[rosmodpoi_close_star \$site \$gisement\]\n"
   puts -nonewline $f "rosmodpoi_corrected_positions \$fichier_positions \$date_deb \$date_fin STAR_COORD \[lrange \$etoile 2 end\] \$temperature \$pression \"\$fichier_modele\"\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "-----------------------------------------------------\n"
   puts -nonewline $f " Generer un fichier de positions avec modele de pointage\n"
   puts -nonewline $f " d'un satellite\n"
   puts -nonewline $f " entre maintenant + 1 min et maintenant + 1 min 1 s.\n"
   puts -nonewline $f "-----------------------------------------------------\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "set fichier_modele \"c:/d/meo/modele.txt\"\n"
   puts -nonewline $f "set fichier_satellite \"c:/d/meo/jas10805080703.txt\"\n"
   puts -nonewline $f "set fichier_positions \"c:/d/meo/positions.txt\"\n"
   puts -nonewline $f "set date_deb \[mc_datescomp now + \[expr 60/86400.\]\]\n"
   puts -nonewline $f "set date_fin \[mc_datescomp \$date_deb + \[expr 1/86400.\]\]\n"
   puts -nonewline $f "set temperature 290\n"
   puts -nonewline $f "set pression 101325\n"
   puts -nonewline $f "rosmodpoi_corrected_positions \$fichier_positions \$date_deb \$date_fin SATEL_EPHEM_FILE \"\$fichier_satellite\" \$temperature \$pression \"\$fichier_modele\"\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "#####################################################\n"
   puts -nonewline $f "### LISTE DES PROCS DE [file tail $ros(rosmodpoi,source)]\n"
   puts -nonewline $f "#####################################################\n\n"
   puts -nonewline $f $txts
   puts -nonewline $f "\n"
   puts -nonewline $f "\n"
   puts -nonewline $f "#####################################################\n"
   puts -nonewline $f "### DETAIL DES ENTREES/SORTIES DE CHAQUE PROC\n"
   puts -nonewline $f "#####################################################\n\n"
   puts -nonewline $f $textes
   close $f
   rosmodpoi_info "Documentation in $fichier_doc"
}

####################################################################################"
####################################################################################"
# TOOLS : Set and rise
####################################################################################"
####################################################################################"

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_nextlevercoucher
# ------------------------------------------------------------------------------------
#
# BUT : Caclule les heures de lever/coucher d'un astre
#
# INPUTS : ra,dec en coordonnees locales
#          date   en UTC
#          altmin en degrés (hauteur a laquelle on considere les levers/couchers)
#
# OUTPUTS : [jn1 jmer jn2] : JDs du lever/meridien/coucher
#                            avec JD du prochain meridien
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_nextlevercoucher {ra dec date {altmin 0} } {
   global ros
   # --- transcodage des arguments
   set ra [mc_angle2deg $ra]
   set dec [mc_angle2deg $dec 90]
   set altmin [mc_angle2deg $altmin]
   # --- parametres temporels
   set jminuit [mc_date2jd $date]
   set lst0 [mc_angle2deg "[mc_date2lst $jminuit $ros(rosmodpoi,home)] h" 360]
   set m0 [mc_angle2deg [expr $ra-$lst0] 360]
   if {$m0<0} {
      set m0 [expr $m0+360.]
   }
   # --- conditions d'invisibilite de l'astre
   set status visible
   set degrad [expr atan(1)/45.]
   set phideg [lindex $ros(rosmodpoi,home) 3]
   if {$phideg>0} {
      set dec_circ [expr 90.-$phideg] ; # circumpolaire
   } else {
      set dec_circ [expr -90.-$phideg] ; # circumpolaire
   }
   set dec_invi [expr -$dec_circ] ; # invisible
   if {$phideg>0} {
      if {$dec<[expr $dec_invi+$altmin]} {
         set jminuit 0.
         set m0 0.
         set H0 0.
         set status unvisible
      }
   } else {
      if {$dec>[expr $dec_invi-$altmin]} {
         set jminuit 0.
         set m0 0.
         set H0 0.
         set status unvisible
      }
   }
   # --- calcul de lever/meridien/coucher
   if {$status=="visible"} {
      #
      set sinphi [expr sin($phideg*$degrad)]
      set cosphi [expr cos($phideg*$degrad)]
      #
      set sindec [expr sin($dec*$degrad)]
      set cosdec [expr cos($dec*$degrad)]
      set h0 $altmin
      set sinh0 [expr sin($h0*$degrad)]
      set cosH0 [expr ($sinh0-$sinphi*$sindec)/($cosphi*$cosdec)]
      if {[expr abs($cosH0)]>1.} {
         set status circumpolaire
         set H0 180. ; # cas circumpolaire
      } else {
         set H0 [expr acos($cosH0)/$degrad]
      }
   }
   set jn2 [expr $jminuit+([mc_angle2deg [expr $m0+$H0] 360])/360.]
   set jn1 [expr $jminuit+([mc_angle2deg [expr $m0-$H0] 360])/360.]
   set jnmer [expr $jminuit+([mc_angle2deg $m0 360])/360.]
   #rosmodpoi_info "status=$status"
   #rosmodpoi_info "m0=$m0 H0=$H0"
   #rosmodpoi_info "jn1=[mc_date2iso8601 $jn1] jnmer=[mc_date2iso8601 $jnmer] jn2=[mc_date2iso8601 $jn2]"
   return [list $jn1 $jnmer $jn2]
   #return [list [mc_date2iso8601 $jn1] [mc_date2iso8601 $jnmer] [mc_date2iso8601 $jn2]]
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_sunmoon
# ------------------------------------------------------------------------------------
#
# BUT : Caclule les heures de lever/coucher de la Lune et du Soleil
#
# INPUTS : date   en UTC
#          altmin en degrés (hauteur a laquelle on considere les levers/couchers du Soleil)
#
# OUTPUTS : lev mer cou : JDs des lever/meridien/coucher
#                         on a toujours cou<lev.
#                         s'il fait jour : date<cou (cou et lev pour cette nuit)
#                                          mer pour ce jour
#                         s'il fait nuit : cou<date (cou et lev pour la prochaine nuit)
#                                          mer pour le jour prochain
#           midnextnight : instant du milieu de la nuit actuelle (s'il fait nuit) ou de la prochaine nuit (s'il fait jour)
#           ra_moon dec_moon : position de la Lune pour le minuit solaire
#
# ALGORITHME :
#     lev       mer        cou      mid
#                -                            coucher_sun   =====             coudeb
#                |                                            |
#                |                            midnight_sun    nuit
#                |                                            |
#      -         |          -        -        lever_sun     =====     ------- datedeb
#      |         |          |        |                        |          |
#      |         |->        |        |        meridien_sun    jour       | d
#      |         |          |        |                        |          | a
#      |         -          |->      |        coucher_sun   =====        | t  coufin
#      |                    |        |                        |          | e
#      |                    |        |->      midnight_sun    nuit       |
#      |                    |        |                        |          |
#      ->                   -        -        lever_sun     =====     ------- datefin
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_sunmoon {date {altmin 0} } {
   global ros
   set date [mc_date2jd $date]
   #
   set datex [expr $date-1.]
   set res [lindex [mc_ephem {sun} [list [list $datex]] {RA DEC ALTITUDE} -topo $ros(rosmodpoi,home)] 0]
   #rosmodpoi_info "rosmodpoi_nextlevercoucher [lindex $res 0] [lindex $res 1] $datex $altmin"
   set res [rosmodpoi_nextlevercoucher [lindex $res 0] [lindex $res 1] $datex $altmin]
   if {[lindex $res 0]>0} {
      set jd_lev0 [lindex $res 0]
      set jd_mer0 [lindex $res 1]
      set jd_cou0 [lindex $res 2]
   } else {
      # --- nuit perpetuelle
      set jd_lev0 [expr $datex-0.5]
      set jd_mer0 [expr $datex]
      set jd_cou0 [expr $datex+0.5]
   }
   #
   set datex [expr $date-0.0]
   set res [lindex [mc_ephem {sun} [list [list $datex]] {RA DEC ALTITUDE} -topo $ros(rosmodpoi,home)] 0]
   set h_sun [lindex $res 2]
   set res [rosmodpoi_nextlevercoucher [lindex $res 0] [lindex $res 1] $datex $altmin]
   if {[lindex $res 0]>0} {
      set jd_lev1 [lindex $res 0]
      set jd_mer1 [lindex $res 1]
      set jd_cou1 [lindex $res 2]
   } else {
      # --- nuit perpetuelle
      set jd_lev1 [expr $datex-0.5]
      set jd_mer1 [expr $datex]
      set jd_cou1 [expr $datex+0.5]
   }
   #
   set datex [expr $date+1.]
   set res [lindex [mc_ephem {sun} [list [list $datex]] {RA DEC ALTITUDE} -topo $ros(rosmodpoi,home)] 0]
   set res [rosmodpoi_nextlevercoucher [lindex $res 0] [lindex $res 1] $datex $altmin]
   if {[lindex $res 0]>0} {
      set jd_lev2 [lindex $res 0]
      set jd_mer2 [lindex $res 1]
      set jd_cou2 [lindex $res 2]
   } else {
      # --- nuit perpetuelle
      set jd_lev2 [expr $datex-0.5]
      set jd_mer2 [expr $datex]
      set jd_cou2 [expr $datex+0.5]
   }
   # --- lever
   #rosmodpoi_info "lever date=[mc_date2iso8601 $date] jd_lev1=[mc_date2iso8601 $jd_lev1]"
   if {($date<$jd_lev1)} {
      set datedeb $jd_lev0
      set datefin $jd_lev1
      set jd_lev  $jd_lev1
   } else {
      set datedeb $jd_lev1
      set datefin $jd_lev2
      set jd_lev  $jd_lev2
   }
   # --- coucher et meridien
   #rosmodpoi_info "jd_lev0=[mc_date2iso8601 $jd_lev0] jd_mer0=[mc_date2iso8601 $jd_mer0]  jd_cou0=[mc_date2iso8601 $jd_cou0]"
   #rosmodpoi_info "jd_lev1=[mc_date2iso8601 $jd_lev1] jd_mer1=[mc_date2iso8601 $jd_mer1]  jd_cou1=[mc_date2iso8601 $jd_cou1]"
   #rosmodpoi_info "jd_lev2=[mc_date2iso8601 $jd_lev2] jd_mer2=[mc_date2iso8601 $jd_mer2]  jd_cou2=[mc_date2iso8601 $jd_cou2]"
   #rosmodpoi_info "datedeb=[mc_date2iso8601 $datedeb] date   =[mc_date2iso8601 $date   ]  datefin=[mc_date2iso8601 $datefin]"

   if {($datedeb<=$jd_cou0)&&($jd_cou0<$datefin)} {
      set coudeb [expr $jd_cou0-1.]
      set coufin $jd_cou0
      set jd_cou $jd_cou0
      if {$date<$jd_cou} {
         set jd_mer $jd_mer0
      } else {
         set jd_mer $jd_mer1
      }
   }
   if {($datedeb<=$jd_cou1)&&($jd_cou1<$datefin)} {
      set coudeb $jd_cou0
      set coufin $jd_cou1
      set jd_cou $jd_cou1
      if {$date<$jd_cou} {
         set jd_mer $jd_mer1
      } else {
         set jd_mer $jd_mer2
      }
   }
   if {($datedeb<=$jd_cou2)&&($jd_cou2<$datefin)} {
      set coudeb $jd_cou1
      set coufin $jd_cou2
      set jd_cou $jd_cou2
      if {$date<$jd_cou} {
         set jd_mer $jd_mer2
      } else {
         set jd_mer [expr $jd_mer2+1.] ; # ce cas n'arrive jamais
      }
   }
   # --- Lune
   set datex [expr ($jd_lev+$jd_cou)/2.]
   set midnextnight $datex
   set res [mc_ephem {moon} [list [list $datex]] {RA DEC ALTITUDE} -topo $ros(rosmodpoi,home)]
   set ra_moon   [lindex [lindex $res 0] 0]
   set dec_moon  [lindex [lindex $res 0] 1]
   #return [list [mc_date2iso8601 $date] [mc_date2iso8601 $jd_lev] [mc_date2iso8601 $jd_mer] [mc_date2iso8601 $jd_cou] [mc_date2iso8601 $midnextnight] $h_sun]
   #return [list $jd_lev $jd_mer $jd_cou $midnextnight $ra_moon $dec_moon]
   return [list [mc_date2iso8601 $jd_lev] [mc_date2iso8601 $jd_mer] [mc_date2iso8601 $jd_cou] [mc_date2iso8601 $midnextnight] $ra_moon $dec_moon]
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_radeclevercoucher
# ------------------------------------------------------------------------------------
#
# BUT : Caclule les heures de lever/coucher d'un astre
#
# INPUTS : ra,dec en coordonnees locales
#          date en UTC
#          jd_sunset en UTC (debut de nuit)
#          jd_sunrise en UTC (fin de nuit)
#          altmin en degrés (hauteur a laquelle on considere les levers/couchers de l'astre)
#
# OUTPUTS : lev mer cou : JDs des lever/meridien/coucher
#                         lev mer et cou a l'interieur du domaine [sunset:sunrise]
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_radeclevercoucher { ra dec date jd_sunset jd_sunrise {altmin 0} } {
   global ros
   #
   set ra [mc_angle2deg $ra]
   set dec [mc_angle2deg $dec]
   set date [mc_date2jd $date]
   set jd_sunset  [mc_date2jd $jd_sunset]
   set jd_sunrise [mc_date2jd $jd_sunrise]
   #
   set datex [expr $date-1.]
   set res [rosmodpoi_nextlevercoucher $ra $dec $datex $altmin]
   set jd_lev0 [lindex $res 0]
   set jd_mer0 [lindex $res 1]
   set jd_cou0 [lindex $res 2]
   #
   set datex [expr $date-0.0]
   set res [rosmodpoi_nextlevercoucher $ra $dec $datex $altmin]
   set jd_lev1 [lindex $res 0]
   set jd_mer1 [lindex $res 1]
   set jd_cou1 [lindex $res 2]
   #
   set datex [expr $date+1.]
   set res [rosmodpoi_nextlevercoucher $ra $dec $datex $altmin]
   set jd_lev2 [lindex $res 0]
   set jd_mer2 [lindex $res 1]
   set jd_cou2 [lindex $res 2]
   # --- date1
   set datex [expr $date-0.0]
   set res [rosmodpoi_nextlevercoucher $ra $dec $datex $altmin]
   set jd_lev1 [lindex $res 0]
   set jd_mer1 [lindex $res 1]
   set jd_cou1 [lindex $res 2]
   # --- date0
   set datex [expr $date-1]
   set res [rosmodpoi_nextlevercoucher $ra $dec $datex $altmin]
   set jd_lev0 [lindex $res 0]
   set jd_mer0 [lindex $res 1]
   set jd_cou0 [lindex $res 2]
   #
   set dj [expr abs([mc_date2jd $jd_lev1]-[mc_date2jd $jd_lev0])]
   if {$dj<0.5} {
      set datex [expr $date-1.5]
      set res [rosmodpoi_nextlevercoucher $ra $dec $datex $altmin]
      set jd_lev0 [lindex $res 0]
      set jd_mer0 [lindex $res 1]
      set jd_cou0 [lindex $res 2]
   } elseif {$dj>1.5} {
      set datex [expr $date-0.5]
      set res [rosmodpoi_nextlevercoucher $ra $dec $datex $altmin]
      set jd_lev0 [lindex $res 0]
      set jd_mer0 [lindex $res 1]
      set jd_cou0 [lindex $res 2]
   }
   # --- date2
   set datex [expr $date+1]
   set res [rosmodpoi_nextlevercoucher $ra $dec $datex $altmin]
   set jd_lev2 [lindex $res 0]
   set jd_mer2 [lindex $res 1]
   set jd_cou2 [lindex $res 2]
   #
   set dj [expr abs([mc_date2jd $jd_lev2]-[mc_date2jd $jd_lev1])]
   if {$dj<0.5} {
      set datex [expr $date+1.5]
      set res [rosmodpoi_nextlevercoucher $ra $dec $datex $altmin]
      set jd_lev2 [lindex $res 0]
      set jd_mer2 [lindex $res 1]
      set jd_cou2 [lindex $res 2]
   } elseif {$dj>1.5} {
      set datex [expr $date-0.5]
      set res [rosmodpoi_nextlevercoucher $ra $dec $datex $altmin]
      set jd_lev2 [lindex $res 0]
      set jd_mer2 [lindex $res 1]
      set jd_cou2 [lindex $res 2]
   }
   # --- non visible par defaut
   set jd_lev $jd_sunrise
   set jd_cou $jd_sunset
   set jd_mer [expr ($jd_sunrise+$jd_sunset)/2.+0.5]
   #rosmodpoi_info ",, jd_sunset= [mc_date2iso8601 $jd_sunset] "
   #rosmodpoi_info ",, jd_sunrise=[mc_date2iso8601 $jd_sunrise] "
   #rosmodpoi_info ",, jd_lev0=[mc_date2iso8601 $jd_lev0] jd_mer0=[mc_date2iso8601 $jd_mer0] jd_cou0=[mc_date2iso8601 $jd_cou0]"
   #rosmodpoi_info ",, jd_lev1=[mc_date2iso8601 $jd_lev1] jd_mer1=[mc_date2iso8601 $jd_mer1] jd_cou1=[mc_date2iso8601 $jd_cou1]"
   #rosmodpoi_info ",, jd_lev2=[mc_date2iso8601 $jd_lev2] jd_mer2=[mc_date2iso8601 $jd_mer2] jd_cou2=[mc_date2iso8601 $jd_cou2]"
   # --- meridien
   if {($jd_sunset<=$jd_mer0)&&($jd_mer0<$jd_sunrise)} {
      set jd_mer $jd_mer0
      set jd_lev $jd_sunset
      set jd_cou $jd_sunrise
   }
   if {($jd_sunset<=$jd_mer1)&&($jd_mer1<$jd_sunrise)} {
      set jd_mer $jd_mer1
      set jd_lev $jd_sunset
      set jd_cou $jd_sunrise
   }
   if {($jd_sunset<=$jd_mer2)&&($jd_mer2<$jd_sunrise)} {
      set jd_mer $jd_mer2
      set jd_lev $jd_sunset
      set jd_cou $jd_sunrise
   }
   #rosmodpoi_info ",, MERIDIEN jd_lev=[mc_date2iso8601 $jd_lev] jd_mer=[mc_date2iso8601 $jd_mer] jd_cou=[mc_date2iso8601 $jd_cou]"
   # --- lever
   if {($jd_sunset<=$jd_lev0)&&($jd_lev0<$jd_sunrise)} {
      set jd_lev $jd_lev0
      set jd_cou $jd_sunrise
   }
   if {($jd_sunset<=$jd_lev1)&&($jd_lev1<$jd_sunrise)} {
      set jd_lev $jd_lev1
      set jd_cou $jd_sunrise
   }
   if {($jd_sunset<=$jd_lev2)&&($jd_lev2<$jd_sunrise)} {
      set jd_lev $jd_lev2
      set jd_cou $jd_sunrise
   }
   #rosmodpoi_info ",, LEVER jd_lev=[mc_date2iso8601 $jd_lev] jd_mer=[mc_date2iso8601 $jd_mer] jd_cou=[mc_date2iso8601 $jd_cou]"
   # --- coucher
   if {($jd_sunset<=$jd_cou0)&&($jd_cou0<$jd_sunrise)} {
      #rosmodpoi_info ",, etape1"
      set jd_cou $jd_cou0
      if {$jd_lev==$jd_sunrise} {
         #rosmodpoi_info ",, etape11"
         set jd_lev $jd_sunset
      }
   }
   if {($jd_sunset<=$jd_cou1)&&($jd_cou1<$jd_sunrise)} {
      #rosmodpoi_info ",, etape2"
      set jd_cou $jd_cou1
      if {$jd_lev==$jd_sunrise} {
         #rosmodpoi_info ",, etape22"
         set jd_lev $jd_sunset
      }
   }
   if {($jd_sunset<=$jd_cou2)&&($jd_cou2<$jd_sunrise)} {
      #rosmodpoi_info ",, etape3"
      set jd_cou $jd_cou2
      if {$jd_lev==$jd_sunrise} {
         #rosmodpoi_info ",, etape33"
         set jd_lev $jd_sunset
      }
   }
   #rosmodpoi_info ",, COUCHER jd_lev=[mc_date2iso8601 $jd_lev] jd_mer=[mc_date2iso8601 $jd_mer] jd_cou=[mc_date2iso8601 $jd_cou]"
   # --- cas circumpolaire
   if {[expr $jd_cou1-$jd_lev1]>0.9999999} {
      set jd_lev $jd_sunset
      set jd_cou $jd_sunrise
   }
   #rosmodpoi_info ",, CIRCUMPOLAIRE jd_lev=[mc_date2iso8601 $jd_lev] jd_mer=[mc_date2iso8601 $jd_mer] jd_cou=[mc_date2iso8601 $jd_cou]"
   # --- cas ou l'astre ne passe pas au meridien dans la nuit
   #     on calcule l'heure de meilleur visibilite
   if {$jd_mer>$jd_cou} {
      set hlev [lindex [mc_radec2altaz $ra $dec $ros(rosmodpoi,home) $jd_lev] 1]
      set hcou [lindex [mc_radec2altaz $ra $dec $ros(rosmodpoi,home) $jd_cou] 1]
      if {$hlev>$hcou} {
         set jd_mer $jd_lev
      } else {
         set jd_mer $jd_cou
      }
   }
   #rosmodpoi_info ",, PASSE PAS MERIDIEN jd_lev=[mc_date2iso8601 $jd_lev] jd_mer=[mc_date2iso8601 $jd_mer] jd_cou=[mc_date2iso8601 $jd_cou]"
   #
   #return [list $jd_lev $jd_mer $jd_cou]
   return [list [mc_date2iso8601 $jd_lev] [mc_date2iso8601 $jd_mer] [mc_date2iso8601 $jd_cou]]
}

####################################################################################"
####################################################################################"
# TOOLS : Pointing model
####################################################################################"
####################################################################################"

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_modpoi_load
# ------------------------------------------------------------------------------------
#
# BUT : Charge un fichier de modèle de pointage en mémoire
#
# INPUTS : PointingModelFile généré avec rosmodpoi_modpoi_compute_model
#
# OUTPUTS : Liste complexe: rosmodpoi_modpoi(modpoi,vec), rosmodpoi_modpoi(modpoi,chisq), rosmodpoi_modpoi(modpoi,covar)
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_modpoi_load { PointingModelFile } {
   global ros
   source "$PointingModelFile"
   set model $ros(rosmodpoi,modpoi,matrices)
   set ros(rosmodpoi,modpoi,vec) [lindex $model 0]
   set ros(rosmodpoi,modpoi,chisq) [lindex $model 1]
   set ros(rosmodpoi,modpoi,covar) [lindex $model 2]
   return $model
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_modpoi_obs2tel
# ------------------------------------------------------------------------------------
#
# BUT : Corrige les coordonnées observee par le modèle de pointage
#
# INPUTS : azimut et elevation observees
#
# OUTPUTS : azimut et elevation du telescope
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_modpoi_obs2tel { azimo elevo {rao ""} } {
   # --- observed to telescope
   set res [rosmodpoi_modpoi_passage $azimo $elevo cat2tel]
   set dazim [lindex $res 0]
   set delev [lindex $res 1]
   ::console::affiche_resultat "azim=$azimo elevo=$elevo"
   ::console::affiche_resultat "dazim=[expr 1.*$dazim] delev=[expr 1.*$delev]"
   set signe +
   set azim [mc_angle2deg [mc_anglescomp $azimo $signe $dazim] 360 nozero 1 auto string]
   set elev [mc_angle2deg [mc_anglescomp $elevo $signe $delev] 90 nozero 0 + string]
   if {$rao==""} {
      return [list $azim $elev]
   }
   set ra [mc_angle2deg [mc_anglescomp $rao $signe $dazim] 360 nozero 1 auto string]
   return [list $azim $elev $ra]
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_modpoi_passage
# ------------------------------------------------------------------------------------
#
# BUT : Calcule les corrections des coordonnées horaires dues au modèle de pointage
#
# INPUTS : Liste (Azim,Elev), sens (cat2tel ou tel2cat)
#
# OUTPUTS : Liste de dazim et delev
#
# Il faut avoir préalablement chargé un modele avec rosmodpoi_modpoi_load
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_modpoi_passage { azim elev sens } {
   global ros_modpoi gren
   global ros
   if {$sens=="cat2tel"} {
      set signe +
   } else {
      set signe -
   }
   # --- met en forme les valeurs
   set delev 0
   set dazim 0
   set azim0 $azim
   set elev0 $elev
   # --- ajoute deux lignes à la matrice
   set vecY ""
   set matX ""
   set vecW ""
   set res [rosmodpoi_modpoi_addobs "$vecY" "$matX" "$vecW" $delev $dazim $azim $elev]
   set matX [lindex $res 1]
   #gren_info "  vecY = $ros(rosmodpoi,modpoi,vec)"
   #gren_info "  matX = $matX"
   # --- calcul direct
   set res [gsl_mmult $matX $ros(rosmodpoi,modpoi,vec)]
   set dazim [expr [lindex $res 0]/60.]
   set delev [expr [lindex $res 1]/60.]
   set azim [mc_angle2deg [mc_anglescomp $azim0 $signe $dazim] 360 nozero 1 auto string]
   set elev [mc_angle2deg [mc_anglescomp $elev0 $signe $delev] 90 nozero 0 + string]
   if {$sens=="tel2cat"} {
      # On itere dans le sens inverse pour gagner la precision de
      # la derive lors de la difference tel/cat.
      # --- ajoute deux lignes à la matrice
      set vecY ""
      set matX ""
      set vecW ""
      set res [rosmodpoi_modpoi_addobs "$vecY" "$matX" "$vecW" $delev $dazim $azim $elev]
      set matX [lindex $res 1]
      # --- calcul direct
      set res [gsl_mmult $matX $ros(rosmodpoi,modpoi,vec)]
      set dazim [expr [lindex $res 0]/60.]
      set delev [expr [lindex $res 1]/60.]
      set azim [mc_angle2deg [mc_anglescomp $azim0 $signe $dazim] 360 nozero 1 auto string]
      set elev [mc_angle2deg [mc_anglescomp $elev0 $signe $delev] 90 nozero 0 + string]
      #
      set dazim [expr ($azim-$azim0)*60.]
      set delev [expr ($elev-$elev0)*60.]
   }
   #::console::affiche_resultat "===> dazim=[expr 60.*$dazim] delev=[expr 60.*$delev]\n"
   return [list $dazim $delev]
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_modpoi_symbols
# ------------------------------------------------------------------------------------
#
# BUT : Affiche les intitulés des symboles des coefficients disponibles pour le modèle de pointage
#
# INPUTS : -
#
# OUTPUTS : -
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_modpoi_symbols { } {
   global ros
   set k 0
   foreach sym $ros(rosmodpoi,modpoi,coefs,symbs) {
      set intitule [lindex $ros(rosmodpoi,modpoi,coefs,intitules) $k]
      rosmodpoi_info "[format %6s $sym] : $intitule"
      incr k
   }
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_modpoi_compute_model
# ------------------------------------------------------------------------------------
#
# BUT : Calcul des coefficients du modèle de pointage
#
# INPUTS :
#    FileObs : fichier des observations avec chaque ligne qui contient une etoile definie par:
#     starid :ID dans le catalogue d'etoiles de reference
#     date : Date UTC de la mesure
#     site : coord apparentes (degrees)
#     gise : coord apparentes (degrees)
#     dsiteo : siteo-site (arcmin)
#     dgiseo : giseo-gise (arcmin)
#     pressure : pression reelle (Pascal)
#     temperature : temperature (Kelvin)
#     dsitec : sitec-site calculé par cette fonction (residus du modele en arcmin)
#     dgisec : gisec-gise calculé par cette fonction (residus du modele en arcmin)
#    FileModel : fichier du model
#    symbos : Liste des coefficients du modele à calculer
#
# OUTPUTS : Un texte explicatif
#
# rosmodpoi_modpoi_compute_model c:/d/meo/Correction.txt c:/d/meo/model.txt {IA IE CA AN FSE AW AN2 AW2 AN3 AW3 ACEC2 ACES2 ACEC3 ACES3 }
#
# 04 93 40 54 28
# ------------------------------------------------------------------------------------
proc rosmodpoi_modpoi_compute_model { FileObs FileModel {symbos ""} } {
   global ros
   # --- Lecture des observations + decalages
   set f [open "$FileObs" r]
   set lignes [split [read $f] \n]
   close $f
   # --- Lecture des symbols a calculer
   if {$symbos==""} {
      if {$ros(rosmodpoi,mount)=="altaz"} {
         set ros(rosmodpoi,modpoi,coefs,symbos) {IA IE CA AN AW AN2 AW2 AN3 AW3 ACEC2 ACES2 ACEC3 ACES3 }
      } else {
         set ros(rosmodpoi,modpoi,coefs,symbos) {IH ID NP CH ME MA TF FO DAF}
      }
   } else {
      set ros(rosmodpoi,modpoi,coefs,symbos) $symbos
   }
   set textes ""
   # --- Mise en forme des commentaires en clair du modèle
   append textes "# POINTING MODEL $FileModel\n"
   append textes "#\n"
   append textes "# DATE [mc_date2iso8601 now]\n"
   append textes "# MOUNT $ros(rosmodpoi,mount)\n"
   append textes "# COEFS $ros(rosmodpoi,modpoi,coefs,symbos)\n"
   # --- Boucle d'iteration pour eliminer les valeurs aberrantes
   set sortie 0
   set iteration 0
   set nrej0 0
   while {$sortie==0} {
      incr iteration
      # --- Remplissage des matrices pour le calcul
      set vecY ""
      set matX ""
      set vecW ""
      set k 0
      set nval 0
      foreach ligne $lignes {
         if {$iteration==1} {
            set valid 1
            lappend valids $valid
         } else {
            set valid [lindex $valids $k]
         }
         incr k
         if {$valid==0} {
            continue
         }
         incr nval
         # --- decode la ligne
         set starid [lindex $ligne 0] ; # ID dans le catalogue d'etoiles de reference
         set date [lindex $ligne 1] ; # Date UTC de la mesure
         set site [lindex $ligne 2] ; # coord apparentes (degrees)
         set gise [lindex $ligne 3] ; # coord apparentes (degrees)
         set dsiteo [lindex $ligne 4] ; # siteo-site (arcmin)
         set dgiseo [lindex $ligne 5] ; # giseo-gise (arcmin)
         set pressure [lindex $ligne 6] ; # pression reelle (Pascal)
         set temperature [lindex $ligne 7] ; # temperature (Kelvin)
         if {$temperature==""} {
            continue
         }
         # --- conversion azim elev
         if {$ros(rosmodpoi,mount)=="altaz"} {
            set res [rosmodpoi_sitegise2azimelev $site $gise]
            set azim [lindex $res 0]
            set elev [lindex $res 1]
         } else {
            set azim $gise ; # HA
            set elev $site ; # DEC
         }
         set dazimo [expr 1.*$dgiseo]
         set delevo $dsiteo
         set res [rosmodpoi_modpoi_addobs $vecY $matX $vecW $dazimo $delevo $azim $elev]
         set vecY [lindex $res 0]
         set matX [lindex $res 1]
         set vecW [lindex $res 2]
      }
      # --- verifie qu'il y a assez d'etoiles
      set n $k
      if {[expr 2*$nval]<[llength $ros(rosmodpoi,modpoi,coefs,symbos)]} {
         append textes " PAS ASSEZ D'ETOILES VALIDES !!!\n"
         break
      }
      # --- Calcul des coefs du modele
      set resmodels [gsl_mfitmultilin $vecY $matX $vecW]
      set vec [lindex $resmodels 0]
      set chisq [lindex $resmodels 1]
      set covar [lindex $resmodels 2]
      #
      append textes "#\n"
      append textes "# COEFS (iteration $iteration)\n"
      set k 0
      foreach sym $ros(rosmodpoi,modpoi,coefs,symbos) {
         set kk [lsearch -exact $ros(rosmodpoi,modpoi,coefs,symbs) $sym]
         set intitule [lindex $ros(rosmodpoi,modpoi,coefs,intitules) $kk]
         set val [lindex $vec $k]
         set texte "[format %6s $sym] [format %+10.4f $val] arcmin (${intitule})"
         append textes "#  $texte\n"
         incr k
      }
      append textes "#\n"
      append textes "# RESIDUES (iteration $iteration)\n"
      # --- Calcul des decalages theoriques prevus par le modele
      set residus 0
      set n 0
      set texte2s ""
      set ecart_ras ""
      set ecart_decs ""
      set tot_sites 0
      set tot_gises 0
      foreach ligne $lignes {
         set vecY ""
         set matX ""
         set vecW ""
         # --- decode la ligne
         set starid [lindex $ligne 0] ; # ID dans le catalogue d'etoiles de reference
         set date [lindex $ligne 1] ; # Date UTC de la mesure
         set site [lindex $ligne 2] ; # coord apparentes (degrees)
         set gise [lindex $ligne 3] ; # coord apparentes (degrees)
         set dsiteo [lindex $ligne 4] ; # siteo-site (arcmin)
         set dgiseo [lindex $ligne 5] ; # giseo-gise (arcmin)
         set pressure [lindex $ligne 6] ; # pression reelle (Pascal)
         set temperature [lindex $ligne 7] ; # temperature (Kelvin)
         if {$temperature==""} {
            continue
         }
         # --- conversion azim elev
         if {$ros(rosmodpoi,mount)=="altaz"} {
            set res [rosmodpoi_sitegise2azimelev $site $gise]
            set azim [lindex $res 0]
            set elev [lindex $res 1]
         } else {
            set azim $gise ; # HA
            set elev $site; # DEC
         }
         set dazimc 0
         set delevc 0
         set res [rosmodpoi_modpoi_addobs $vecY $matX $vecW $dazimc $delevc $azim $elev ]
         set vecY [lindex $res 0]
         set matX [lindex $res 1]
         set vecW [lindex $res 2]
         # --- calcul du decalage prevu par le modele
         set res [gsl_mmult $matX $vec]
         set dazimc [lindex $res 0]
         set delevc [lindex $res 1]
         set dgisec [expr 1.*$dazimc]
         set dsitec $delevc
         set texte "$starid $date $site $gise $dsiteo $dgiseo $pressure $temperature $dsitec $dgisec"
         append texte2s "$texte\n"
         # --- calcul du residu
         set valid [lindex $valids $n]
         incr n
         set dsiteoc [expr $dsiteo-$dsitec]
         set dgiseoc [expr $dgiseo-$dgisec]
         if {$dgiseoc>180}  { set dgiseoc [expr $dgiseoc-360.] }
         if {$dgiseoc<-180} { set dgiseoc [expr $dgiseoc+360.] }
         lappend ecart_sites $dsiteoc
         lappend ecart_gises $dgiseoc
         set tot_sites [expr $tot_sites+$dsiteoc]
         set tot_gises [expr $tot_gises+$dgiseoc]
         set texte "#   Star-$n ($valid) [format %+7.3f $dsiteoc] [format %+7.3f $dgiseoc] (arcmin) [format %+7.1f [expr 60.*$dsiteoc]] [format %+7.1f [expr 60.*$dgiseoc]] (arcsec)"
         append textes "$texte\n"
         set coselev [expr cos($ros(rosmodpoi,pi)/180.*[mc_angle2deg $elev])]
         set dgiseoc [expr $dgiseoc*$coselev]
         set doc [expr sqrt($dsiteoc*$dsiteoc+$dgiseoc*$dgiseoc)]
         set residus [expr $residus+$doc*$doc]
      }
      set residus [expr sqrt(($residus)/($n-1))]
      set moy_sites [expr 1.*$tot_sites/$n]
      set moy_gises [expr 1.*$tot_gises/$n]
      append textes "# \n"
      append textes "#   Root Mean Square : [format %.3f $residus] arcmin = [format %.1f [expr 60.*$residus]] arcsec (iteration $iteration)\n"
      append textes "# \n"
      # --- Calcul des ecarts types
      set tot_sites 0
      set tot_gises 0
      for {set k 0} {$k<$n} {incr k} {
         set d [expr [lindex $ecart_sites $k]-$moy_sites]
         set tot_sites [expr $tot_sites+$d*$d]
         set d [expr [lindex $ecart_gises $k]-$moy_gises]
         set tot_gises [expr $tot_gises+$d*$d]
      }
      set std_sites [expr sqrt(($tot_sites)/($n-1))]
      set std_gises [expr sqrt(($tot_gises)/($n-1))]
      # --- exclusion des valeurs aberrantes
      set kappa 2.
      set lim_sites [expr $kappa*$std_sites]
      set lim_gises [expr $kappa*$std_gises]
      set valids ""
      set nrej 0
      for {set k 0} {$k<$n} {incr k} {
         set valid 1
         set comment ""
         set d [expr abs([lindex $ecart_sites $k]-$moy_sites)]
         if {$d>=$lim_sites} {
            set valid 0
            append comment " (ecart_site [format %.1f [expr 60.*$d]]>[format %.1f [expr 60.*$lim_sites]] arcsec)"
         }
         set d [expr abs([lindex $ecart_gises $k]-$moy_gises)]
         if {$d>=$lim_gises} {
            set valid 0
            append comment " (ecart_gisement [format %.1f [expr 60.*$d]]>[format %.1f [expr 60.*$lim_gises]] arcsec)"
         }
         if {$valid==0} {
            append textes "#   Star-[expr 1+$k] EXCLUDED $comment\n"
            incr nrej
         }
         lappend valids $valid
      }
      # --- Condition d'arret des iterations
      if {($iteration>3)||($nrej==$nrej0)} {
         break
      }
      set nrej0 $nrej
   }
   # --- Ecriture du fichier du modele
   rosmodpoi_info "$textes"
   append textes "# MATRIX\n"
   append textes "set ros(rosmodpoi,modpoi,matrices) \{$resmodels\}\n"
   append textes "set ros(rosmodpoi,modpoi,coefs,symbos) \{$ros(rosmodpoi,modpoi,coefs,symbos)\}\n"
   set f [open "$FileModel" w]
   puts -nonewline $f $textes
   close $f
   # --- Ecriture des observations + decalages calcules
   set f [open "$FileObs" w]
   puts -nonewline $f $texte2s
   close $f
   return $textes
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_modpoi_addobs
# ------------------------------------------------------------------------------------
#
# BUT : Ajoute une observation a une série pour préparer le calcul des coefficients du modèle de pointage
#
# INPUTS : vecY matX vecW dazim delev elev azim
#
# OUTPUTS : $vecY $matX $vecW
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_modpoi_addobs { vecY matX vecW dazim delev azim elev} {
   global ros
   rosmodpoi_log "rosmodpoi_modpoi_addobs : $dazim $delev $azim $elev"
   if {$ros(rosmodpoi,mount)=="altaz"} {
      set tane [expr tan([mc_angle2rad $elev]) ]
      set cosa [expr cos([mc_angle2rad $azim]) ]
      set sina [expr sin([mc_angle2rad $azim]) ]
      set cose [expr cos([mc_angle2rad $elev]) ]
      set sine [expr sin([mc_angle2rad $elev]) ]
      set sece [expr 1./cos([mc_angle2rad $elev]) ]
      set cos2a [expr cos(2.*[mc_angle2rad $azim]) ]
      set sin2a [expr sin(2.*[mc_angle2rad $azim]) ]
      set cos3a [expr cos(3.*[mc_angle2rad $azim]) ]
      set sin3a [expr sin(3.*[mc_angle2rad $azim]) ]
      set cos4a [expr cos(4.*[mc_angle2rad $azim]) ]
      set sin4a [expr sin(4.*[mc_angle2rad $azim]) ]
      set cos5a [expr cos(5.*[mc_angle2rad $azim]) ]
      set sin5a [expr sin(5.*[mc_angle2rad $azim]) ]
      set cos6a [expr cos(6.*[mc_angle2rad $azim]) ]
      set sin6a [expr sin(6.*[mc_angle2rad $azim]) ]
      #
      # --- dazim
      set res ""
      foreach sym $ros(rosmodpoi,modpoi,coefs,symbos) {
         if {$sym=="IA"}    { lappend res 1 }
         if {$sym=="IE"}    { lappend res 0 }
         if {$sym=="NPAE"}  { lappend res $tane }
         if {$sym=="CA"}    { lappend res $sece }
         if {$sym=="AN"}    { lappend res [expr $sina*$tane] }
         if {$sym=="AW"}    { lappend res [expr -$cosa*$tane] }
         if {$sym=="ACEC"}  { lappend res $cosa }
         if {$sym=="ECEC"}  { lappend res 0 }
         if {$sym=="ACES"}  { lappend res $sina }
         if {$sym=="ECES"}  { lappend res 0 }
         if {$sym=="NRX"}   { lappend res 1 }
         if {$sym=="NRY"}   { lappend res $tane }
         if {$sym=="ACEC2"} { lappend res $cos2a }
         if {$sym=="ACES2"} { lappend res $sin2a }
         if {$sym=="ACEC3"} { lappend res $cos3a }
         if {$sym=="ACES3"} { lappend res $sin3a }
         if {$sym=="ACEC4"} { lappend res $cos4a }
         if {$sym=="ACES4"} { lappend res $sin4a }
         if {$sym=="ACEC5"} { lappend res $cos5a }
         if {$sym=="ACES5"} { lappend res $sin5a }
         if {$sym=="ACEC6"} { lappend res $cos6a }
         if {$sym=="ACES6"} { lappend res $sin6a }
         if {$sym=="AN2"}   { lappend res [expr $sin2a*$tane] }
         if {$sym=="AW2"}   { lappend res [expr -$cos2a*$tane] }
         if {$sym=="AN3"}   { lappend res [expr $sin3a*$tane] }
         if {$sym=="AW3"}   { lappend res [expr -$cos3a*$tane] }
         if {$sym=="AN4"}   { lappend res [expr $sin4a*$tane] }
         if {$sym=="AW4"}   { lappend res [expr -$cos4a*$tane] }
         if {$sym=="AN5"}   { lappend res [expr $sin5a*$tane] }
         if {$sym=="AW5"}   { lappend res [expr -$cos5a*$tane] }
         if {$sym=="AN6"}   { lappend res [expr $sin6a*$tane] }
         if {$sym=="AW6"}   { lappend res [expr -$cos6a*$tane] }
      }
      #
      lappend matX $res
      lappend vecY $dazim
      lappend vecW 0.5
      # --- delev
      set res ""
      foreach sym $ros(rosmodpoi,modpoi,coefs,symbos) {
         if {$sym=="IA"}    { lappend res 0 }
         if {$sym=="IE"}    { lappend res 1 }
         if {$sym=="NPAE"}  { lappend res 0 }
         if {$sym=="CA"}    { lappend res 0 }
         if {$sym=="AN"}    { lappend res $cosa }
         if {$sym=="AW"}    { lappend res $sina }
         if {$sym=="ACEC"}  { lappend res 0 }
         if {$sym=="ECEC"}  { lappend res $cose}
         if {$sym=="ACES"}  { lappend res 0 }
         if {$sym=="ECES"}  { lappend res $sine }
         if {$sym=="NRX"}   { lappend res [expr -1.*$sine] }
         if {$sym=="NRY"}   { lappend res $cose }
         if {$sym=="ACEC2"} { lappend res 0 }
         if {$sym=="ACES2"} { lappend res 0 }
         if {$sym=="ACEC3"} { lappend res 0 }
         if {$sym=="ACES3"} { lappend res 0 }
         if {$sym=="ACEC4"} { lappend res 0 }
         if {$sym=="ACES4"} { lappend res 0 }
         if {$sym=="ACEC5"} { lappend res 0 }
         if {$sym=="ACES5"} { lappend res 0 }
         if {$sym=="ACEC6"} { lappend res 0 }
         if {$sym=="ACES6"} { lappend res 0 }
         if {$sym=="AN2"}   { lappend res $cos2a }
         if {$sym=="AW2"}   { lappend res $sin2a }
         if {$sym=="AN3"}   { lappend res $cos3a }
         if {$sym=="AW3"}   { lappend res $sin3a }
         if {$sym=="AN4"}   { lappend res $cos4a }
         if {$sym=="AW4"}   { lappend res $sin4a }
         if {$sym=="AN5"}   { lappend res $cos5a }
         if {$sym=="AW5"}   { lappend res $sin5a }
         if {$sym=="AN6"}   { lappend res $cos6a }
         if {$sym=="AW6"}   { lappend res $sin6a }
      }
      #
      #set k 0
      #foreach sym $ros(rosmodpoi,modpoi,coefs,symbos) {
      #  rosmodpoi_info "XXX $sym [lindex $ros(rosmodpoi,modpoi,vec) $k] [lindex $res $k]"
      #  incr k
      #}
      #
   } else {
      set tand [expr tan([mc_angle2rad $elev]) ]
      set cosh [expr cos([mc_angle2rad $azim]) ]
      set sinh [expr sin([mc_angle2rad $azim]) ]
      set cosd [expr cos([mc_angle2rad $elev]) ]
      set sind [expr sin([mc_angle2rad $elev]) ]
      set secd [expr 1./cos([mc_angle2rad $elev]) ]
      set lati [lindex $ros(rosmodpoi,home) 3]
      set cosl [expr cos([mc_angle2rad $lati]) ]
      set sinl [expr sin([mc_angle2rad $lati]) ]
      set cos2h [expr cos([mc_angle2rad [expr 2.*$azim]]) ]
      set sin2h [expr sin([mc_angle2rad [expr 2.*$azim]]) ]
      set cos3h [expr cos([mc_angle2rad [expr 3.*$azim]]) ]
      set sin3h [expr sin([mc_angle2rad [expr 3.*$azim]]) ]
      set hdeg [mc_angle2deg $azim 360]
      set decdeg [mc_angle2deg $elev 90]
      if {$hdeg>180} {
         set hdeg [expr $hdeg-360.]
      }
      #
      # --- dha
      set res ""
      foreach sym $ros(rosmodpoi,modpoi,coefs,symbos) {
         if {$sym=="IH"}    { lappend res 1 }
         if {$sym=="ID"}    { lappend res 0 }
         if {$sym=="NP"}    { lappend res $tand }
         if {$sym=="CH"}    { lappend res $secd }
         if {$sym=="ME"}    { lappend res [expr $sinh*$tand] }
         if {$sym=="MA"}    { lappend res [expr -$cosh*$tand] }
         if {$sym=="TF"}    { lappend res [expr $cosl*$sinh/$cosd] }
         if {$sym=="FO"}    { lappend res 0 }
         if {$sym=="DAF"}   { lappend res [expr $cosl*$cosh+$sinl*$tand] }
         if {$sym=="HF"}    { lappend res [expr $sinh/$cosd] }
         if {$sym=="TX"}    { lappend res [expr ($cosl*$sinh/$cosd)/($sind*$sinl+$cosd*$cosh*$cosl)] }
         if {$sym=="DNP"}   { lappend res [expr $sinh*$tand] }
         if {$sym=="FARHC"} { lappend res [expr $cosh] }
         if {$sym=="FARHS"} { lappend res [expr $sinh] }
         if {$sym=="IHDEG"} { lappend res $hdeg }
         if {$sym=="FARHC2"} { lappend res [expr $cos2h] }
         if {$sym=="FARHS2"} { lappend res [expr $sin2h] }
         if {$sym=="FARHC3"} { lappend res [expr $cos3h] }
         if {$sym=="FARHS3"} { lappend res [expr $sin3h] }
         if {$sym=="FARDC"} { lappend res 0 }
         if {$sym=="FARDS"} { lappend res 0 }
         if {$sym=="FARDC2"} { lappend res 0 }
         if {$sym=="FARDS2"} { lappend res 0 }
         if {$sym=="FARHCATAN"} { set coefha [expr 0.9+(1-0.9)*atan(3*($decdeg-30.)*$ros(rosmodpoi,pi)/180.)/($ros(rosmodpoi,pi)/2.)] ; lappend res [expr $cosh*$coefha] }
         if {$sym=="FARHSATAN"} { set coefha [expr 0.9+(1-0.9)*atan(3*($decdeg-30.)*$ros(rosmodpoi,pi)/180.)/($ros(rosmodpoi,pi)/2.)] ; lappend res [expr $sinh*$coefha] }
         if {$sym=="IHATAN"} { set coefih [expr (1.-1.*atan(3*($decdeg-10.)*$ros(rosmodpoi,pi)/180.)/($ros(rosmodpoi,pi)/2.))] ; lappend res [expr $coefih] }
         if {$sym=="X1HC"} { lappend res [expr $cosh/$cosd] }
         if {$sym=="X1HS"} { lappend res [expr $sinh/$cosd] }
      }
      #
      lappend matX $res
      lappend vecY $dazim
      lappend vecW 0.5
      # --- ddec
      set res ""
      foreach sym $ros(rosmodpoi,modpoi,coefs,symbos) {
         if {$sym=="IH"}    { lappend res 0 }
         if {$sym=="ID"}    { lappend res 1 }
         if {$sym=="NP"}    { lappend res 0 }
         if {$sym=="CH"}    { lappend res 0 }
         if {$sym=="ME"}    { lappend res $cosh }
         if {$sym=="MA"}    { lappend res $sinh }
         if {$sym=="TF"}    { lappend res [expr $cosl*$cosh*$sind-$sinl*$cosd] }
         if {$sym=="FO"}    { lappend res $cosh}
         if {$sym=="DAF"}   { lappend res 0 }
         if {$sym=="HF"}    { lappend res 0 }
         if {$sym=="TX"}    { lappend res [expr ($cosl*$cosh*$sind-$sinl*$cosd)/($sind*$sinl+$cosd*$cosh*$cosl)] }
         if {$sym=="DNP"}   { lappend res 0 }
         if {$sym=="FARHC"} { lappend res 0 }
         if {$sym=="FARHS"} { lappend res 0 }
         if {$sym=="IHDEG"} { lappend res 0 }
         if {$sym=="FARHC2"} { lappend res 0 }
         if {$sym=="FARHS2"} { lappend res 0 }
         if {$sym=="FARHC3"} { lappend res 0 }
         if {$sym=="FARHS3"} { lappend res 0 }
         if {$sym=="FARDC"} { lappend res [expr $cosh] }
         if {$sym=="FARDS"} { lappend res [expr $sinh] }
         if {$sym=="FARDC2"} { lappend res [expr $cos2h] }
         if {$sym=="FARDS2"} { lappend res [expr $sin2h] }
         if {$sym=="FARHCATAN"} { lappend res 0 }
         if {$sym=="FARHSATAN"} { lappend res 0 }
         if {$sym=="IHATAN"} { lappend res 0 }
         if {$sym=="X1HC"} { lappend res 0 }
         if {$sym=="X1HS"} { lappend res 0 }
      }
   }
   lappend matX $res
   lappend vecY $delev
   lappend vecW [expr 0.5]
   #
   return [list $vecY $matX $vecW]
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_modpoi_catalogmean2apparent
# ------------------------------------------------------------------------------------
#
# BUT : Transforme des coordonnées moyennes en coordonnées apparentes (=corrections abberations, precession, nutation)
#
# INPUTS : RA, DEC, Equinox, Date, Home, ?epoch mura mudec parallax?
#
# OUTPUTS : Liste de coordonnées apparentes
#            rav,decv : true coordinates (degrees)
#            Hv : true hour angle (degrees)
#            hv : true altitude altaz coordinate (degrees)
#            azv : true azimut altaz coodinate (degrees)
#           Il reste à appliquer rosmodpoi_modpoi_apparent2observed
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_modpoi_catalogmean2apparent { rae dece equinox date home {epoch ""} {mura ""} {mudec ""} {parallax ""} } {
# Input
# rae,dece : coordinates J2000.0 (degrees)
# Output
   global ros
   # --- aberration annuelle
   set radec [mc_aberrationradec annual [list $rae $dece] $date ]
   # --- correction de precession
   set cosdec [expr cos($ros(rosmodpoi,pi)/180.*[mc_angle2deg $dece])]
   if {($epoch=="")&&($mu_racosd=="")&&($mu_dec=="")} {
      set radec [mc_precessradec $radec $equinox $date]
   } else {

      set radec [mc_precessradec $radec $equinox $date [list $mura $mudec $epoch]]
   }
   # --- correction de parallaxe stellaire
   if {$parallax!=""} {
      set radec [mc_parallaxradec $radec $date $parallax]
   }
   # --- correction de nutation
   set radec [mc_nutationradec $radec $date]
   # --- aberration de l'aberration diurne
   set radec [mc_aberrationradec diurnal $radec $date $home]
   # --- calcul de l'angle horaire et de la hauteur vraie
   set rav [lindex $radec 0]
   set decv [lindex $radec 1]
   set dummy [mc_radec2altaz ${rav} ${decv} $home $date]
   set azv [lindex $dummy 0]
   set hv [lindex $dummy 1]
   set Hv [lindex $dummy 2]
   # --- return
   return [list $rav $decv $Hv $hv $azv]
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_modpoi_apparent2observed
# ------------------------------------------------------------------------------------
#
# BUT : Transforme des coordonnées apparentes en coordonnées observées (=correction de la refraction)
#
# INPUTS : Liste de coordonnées apparentes issues de rosmodpoi_modpoi_catalogmean2apparent
#
# OUTPUTS : Liste de coordonnées observées
#            raadt,decadt : observed coordinates (degrees)
#            Hadt : observed hour angle (degrees)
#            hadt : observed altitude altaz coordinate (degrees)
#            azadt : observed azimut altaz coordinate (degrees)
#           Il ne reste plus qu'à appliquer le modèle de pointage
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_modpoi_apparent2observed { listvdt {temperature 290} {pressure 101325} {date now} home } {
   # --- extract angles from the listvd
   set ravdt [lindex $listvdt 0]
   set decvdt [lindex $listvdt 1]
   set Hvdt [lindex $listvdt 2]
   set hvdt [lindex $listvdt 3]
   set azvdt [lindex $listvdt 4]
   # --- Refraction correction
   set azadt $azvdt
   if {$hvdt>-1.} {
      set refraction [mc_refraction $hvdt out2in $temperature $pressure]
   } else {
      set refraction 0.
   }
   set hadt [expr $hvdt+$refraction]
   set res [mc_altaz2radec $azvdt $hadt $home $date]
   set raadt [lindex $res 0]
   set decadt [lindex $res 1]
   set res [mc_altaz2hadec $azvdt $hadt $home $date]
   set Hadt [lindex $res 0]
   return [list $raadt $decadt $Hadt $hadt $azadt]
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_convcat_hip
# ------------------------------------------------------------------------------------
#
# BUT : Simplifie le catalogue Hipparcos pour les etoiles du modele de pointage
#
# INPUTS : Fichier Hipparcos brut et fichier Hipparcos simplifie
#          Method 0=tout le catalogue
#          Method 1=etoiles a faibles mouvements propres (<[lindex $params 1] en mas/yr) et faible parallaxe (<[lindex $params 0] en mas)
#          Method 2=etoiles brillantes magnitude < [lindex $params 0]
#          params : liste d'options (en fonction de Method).
#
# OUTPUTS : Lignes ASCII de type "ID magV RA(Deg) DEC(Deg) Equinox(JDTT) Epoch(JDTT) mu_alpha.cos(delta)(mas/yr) mu_delta(mas/yr) Plx(mas)\n"
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_convcat_hip { {fichier_in ""} {fichier_out ""} {method 1} {params ""} } {
   global ros
   if {$fichier_in==""} {
      set fichier_in "$ros(rosmodpoi,path)/$ros(rosmodpoi,cathipmain)"
   }
   if {$fichier_out==""} {
      set fichier_out "$ros(rosmodpoi,path)/$ros(rosmodpoi,cathipshort)"
   }
   set f [open ${fichier_in} r]
   set textes ""
   set k 0
   set ktot 0
   while {[eof $f]==0} {
      incr ktot
      set ligne0 [gets $f]
      set ligne [split $ligne0 |]
      if {[llength $ligne]<3} {
         continue
      }
      set Vmag [lindex $ligne 5]
      set plx [lindex $ligne 11]
      set pmRA [lindex $ligne 12]
      set pmDE [lindex $ligne 13]
      set MultFlag [lindex $ligne 59]
      set err [catch { expr $Vmag} msg]
      if {$err==1} {
         continue
      }
      if {$method==0} {
         if {($plx>200000.)||($plx<0)} {
            continue
         }
         if {([expr abs($pmRA)]>20000)} {
            continue
         }
         if {([expr abs($pmDE)]>20000)} {
            continue
         }
      }
      if {$method==1} {
         set plxmax [lindex $params 0] ; # mas
         if {$plxmax==""} {
            set plxmax 5
         }
         set pmmax [lindex $params 1] ; # mas/yr
         if {$pmmax==""} {
            set pmmax 5
         }
         if {($plx>$plxmax)||($plx<0)} {
            continue
         }
         if {([expr abs($pmRA)]>$pmmax)} {
            continue
         }
         if {([expr abs($pmDE)]>$pmmax)} {
            continue
         }
         if {($MultFlag!=" ")} {
            continue
         }
      }
      if {$method==2} {
         set Vmagmax [lindex $params 0]
         if {$Vmagmax==""} {
            set Vmagmax 3
         }
         if {($plx>200000.)||($plx<0)} {
            continue
         }
         if {([expr abs($pmRA)]>20000)} {
            continue
         }
         if {([expr abs($pmDE)]>20000)} {
            continue
         }
         if {$Vmag>$Vmagmax} {
            continue
         }
      }
      set id [lindex $ligne 1]
      set RAdeg [lindex $ligne 8]
      set DEdeg [lindex $ligne 9]
      set equinox [mc_date2jd J2000.0]
      set epoch 2448349.0625 ; # J1991.25 TT
      #::console::affiche_resultat "| $id | $Vmag | $RAdeg | $DEdeg | $equinox | $epoch | $pmRA | $pmDE | $plx |"
      set texte "[format %10s $id] [format %+5.1f $Vmag] [format %12.8f $RAdeg] [format %+12.8f $DEdeg] [format %13.5f $equinox] [format %13.5f $epoch] [format %8.2f $pmRA] [format %8.2f $pmDE] [format %7.2f $plx]"
      append textes "$texte\n"
      incr k
   }
   #rosmodpoi_info "k=$k ktot=$ktot"
   close $f
   set f [open ${fichier_out} w]
   puts -nonewline $f $textes
   close $f
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_modpoi_liste_amers
# ------------------------------------------------------------------------------------
#
# BUT : Calcul des points d'amer pour le modele de pointage
#
# INPUTS : nsite = nombre de points à pointer en site
#          ngise = nombre de points à pointer en gisement
#
# OUTPUTS : Liste Tcl { site gisement }
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_modpoi_liste_amers { {nsite 3} {ngise 4} } {
   global ros
   rosmodpoi_log "rosmodpoi_modpoi_liste_amers $ros(rosmodpoi,mount) : $nsite $ngise"
   if {$ros(rosmodpoi,mount)=="altaz"} {
      set smax 90.
      set smin 10.
      set gmin 0.
      set gmax 355.
      set ds [expr ($smax-$smin)/$nsite]
      set dg [expr ($gmax-$gmin)/$ngise]
      set res ""
      for {set kg 0} {$kg<$ngise} {incr kg} {
         set gise [expr $gmin+$dg*(0.5+$kg)]
         for {set ks 0} {$ks<$nsite} {incr ks} {
            set site [expr $smin+$ds*(0.5+$ks)]
            lappend res [list $site $gise]
         }
      }
   } else {
      set dmax 70.
      set dmin -30.
      set hmin -110
      set hmax 110
      set dd [expr ($dmax-$dmin)/$nsite]
      set dh [expr ($hmax-$hmin)/$ngise]
      set res ""
      for {set kh 0} {$kh<$ngise} {incr kh} {
         set ha [expr $hmin+$dh*(0.5+$kh)]
         for {set kd 0} {$kd<$nsite} {incr kd} {
            set dec [expr $dmin+$dd*(0.5+$kd)]
            set ress [mc_hadec2altaz $ha $dec $ros(rosmodpoi,home)]
            set azim [lindex $ress 0]
            set elev [lindex $ress 1]
            #if {$elev>15} { }
            set ress [rosmodpoi_azimelev2sitegise $azim $elev]
            set site [lindex $ress 0]
            set gise [lindex $ress 1]
            #::console::affiche_resultat "ha=$ha dec=$dec site=$site gise=$gise\n"
            lappend res [list $site $gise]
         }
      }
   }
   return $res
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_amer_hip
# ------------------------------------------------------------------------------------
#
# BUT : Recherche l'etoile du catalogue Hipparcos simplifie la plus proche d'un point d'amer
#
# INPUTS : Fichier Hipparcos simplifie, Liste d'amers (coordonnées site gisement), Index de l'amer, Nombre d'etoiles max, Separation max, Date
#
# OUTPUTS : Ligne ASCII de type "ID magV RA(Deg) DEC(Deg) Equinox(JDTT) Epoch(JDTT) mu_alpha.cos(delta)(mas/yr) mu_delta(mas/yr) Plx(mas)\n"
#
# REMARKS : This function is obsolete (replaced by mc_meo amer_hip in libmc)
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_amer_hip { {fichier_in ""} {amers {{45 180}}} {kamer 0} {nstars 1} {sepmax 180} {date now} } {
   global ros
   if {$fichier_in==""} {
      set fichier_in "$ros(rosmodpoi,path)/$ros(rosmodpoi,cathipshort)"
   }

   rosmodpoi_log "rosmodpoi_amer_hip : fichier_in=\"$fichier_in\" amers=$amers kamer=$kamer nstars=$nstars sepmax=$sepmax date=$date"
   set date [mc_date2jd $date]
   # --- on ramene le point d'amer en coordonnées RA,DEC J2000.0
   set amer [lindex $amers $kamer]
   set site [lindex $amer 0]
   set gise [lindex $amer 1]
   set res [rosmodpoi_sitegise2azimelev $site $gise]
   set azim [lindex $res 0]
   set elev [lindex $res 1]
   #rosmodpoi_info "site=$site gise=$gise"
   set res [mc_altaz2radec $azim $elev $ros(rosmodpoi,home) $date]
   set equinox [mc_date2jd J2000.0]
   #rosmodpoi_info "res=$res"
   set res [mc_precessradec $res $date $equinox]
   set ra0 [lindex $res 0]
   set dec0 [lindex $res 1]
   #rosmodpoi_info "ra0=$ra0 dec0=$dec0"
   # --- on scane le fichier hipparcos
   set f [open ${fichier_in} r]
   set lignes [split [read $f] \n]
   close $f
   set sepmin 360.
   set star ""
   set stars ""
   set k -1
   foreach ligne $lignes {
      incr k
      set ra [lindex $ligne 2]
      set dec [lindex $ligne 3]
      if {$ra==""} {
         continue
      }
      set res [mc_radec2altaz $ra $dec $ros(rosmodpoi,home) $date]
      set elev [lindex $res 1]
      if {$elev<10} {
         continue ; # on ne prend pas les etoiles trop basses
      }
      set res [mc_sepangle $ra0 $dec0 $ra $dec]
      set sep [lindex $res 0]
      if {$sep>$sepmax} {
         continue
      }
      if {$sep<$sepmin} {
         set sepmin $sep
         set star $ligne
      }
      lappend stars [list $sep $k]
      #::console::affiche_resultat "$ligne => $ra $dec => $sep (k=$k)\n"
   }
   set stars [lsort -increasing $stars]
   set stars [lrange $stars 0 [expr $nstars-1]]
   #::console::affiche_resultat "[lrange $stars 0 0]\n"
   set res ""
   foreach star $stars {
      set k [lindex $star 1]
      set ligne [lindex $lignes $k]
      lappend res $ligne
      #::console::affiche_resultat "star=star k=$k ligne=$ligne\n"
   }
   return $res
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_id_hip
# ------------------------------------------------------------------------------------
#
# BUT : Recherche l'etoile du catalogue Hipparcos simplifie a partir de son identifiant
#
# INPUTS : Fichier Hipparcos simplifie, Identifiant
#
# OUTPUTS : Ligne ASCII de type "ID magV RA(Deg) DEC(Deg) Equinox(JDTT) Epoch(JDTT) mu_alpha.cos(delta)(mas/yr) mu_delta(mas/yr) Plx(mas)\n"
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_id_hip { {fichier_in ""} {id0 ""} } {
   global ros
   if {$fichier_in==""} {
      set fichier_in "$ros(rosmodpoi,path)/$ros(rosmodpoi,cathipshort)"
   }
   # --- on scane le fichier hipparcos
   set f [open ${fichier_in} r]
   set lignes [split [read $f] \n]
   close $f
   set sepmin 360.
   set star ""
   foreach ligne $lignes {
      set id [lindex $ligne 0]
      if {[string compare $id $id0]==0} {
         set star $ligne
         break
      }
   }
   if {$star==""} {
      error "Star ID not found"
   }
   return $star
}

####################################################################################"
####################################################################################"
# FUNCTIONS
####################################################################################"
####################################################################################"

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_infoscelestes
# ------------------------------------------------------------------------------------
#
# BUT : Retourne des informations diverses sur la Lune et le Soleil (lever/coucher)
#
# INPUTS : Date
#
# OUTPUTS : Lignes ASCII de type "Motclé Valeur Unité\n"
#
# La liste des mots clé est:
#  DATE
#  SKYLIGHT
#  SUN_SET
#  SUN_RISE
#  SUN_RA2000
#  SUN_DEC2000
#  SUN_SITE
#  SUN_GISEMENT
#  SUN_DISTANCE
#  MOON_RA2000
#  MOON_DEC2000
#  MOON_SITE
#  MOON_GISEMENT
#  MOON_DISTANCE
#  MOON_PHASE
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_infoscelestes { {date now} {site 0} {gisement 0} } {

   global ros

   set result "[list DATE [mc_date2iso8601 $date] ISO8601]\n"
   set jdnow [mc_date2jd $date]
   set res1 [rosmodpoi_sunmoon $date]
   set lev [lindex $res1 0]
   set mer [lindex $res1 1]
   set cou [lindex $res1 2]
   set jdlev [mc_date2jd $lev]
   set jdmer [mc_date2jd $mer]
   set jdcou [mc_date2jd $cou]
   if { $jdnow<$jdcou } {
      set skylight DAY
   } else {
      set skylight NIGHT
   }
   append result "[list SKYLIGHT $skylight]\n"
   append result "[list SUN_SET $cou ISO8601]\n"
   append result "[list SUN_RISE $lev ISO8601]\n"

   set res [mc_ephem {sun moon} $date {RA DEC AZIMUT ALTITUDE DELTA PHASE} -topo $ros(rosmodpoi,home)]
   set sun_ephem [lindex $res 0]
   set moon_ephem [lindex $res 1]
   append result "[list SUN_RA2000 [lindex $sun_ephem 0] Deg]\n"
   append result "[list SUN_DEC2000 [lindex $sun_ephem 1] Deg]\n"
   set res [rosmodpoi_azimelev2sitegise [lindex $sun_ephem 2] [lindex $sun_ephem 3]]
   append result "[list SUN_SITE [lindex $res 0] Deg]\n"
   append result "[list SUN_GISEMENT [lindex $res 1] Deg]\n"
   append result "[list SUN_DISTANCE [lindex $sun_ephem 4] UA]\n"
   append result "[list MOON_RA2000 [lindex $moon_ephem 0] Deg]\n"
   append result "[list MOON_DEC2000 [lindex $moon_ephem 1] Deg]\n"
   set res [rosmodpoi_azimelev2sitegise [lindex $moon_ephem 2] [lindex $moon_ephem 3]]
   append result "[list MOON_SITE [lindex $res 0] Deg]\n"
   append result "[list MOON_GISEMENT [lindex $res 1] Deg]\n"
   append result "[list MOON_DISTANCE [lindex $moon_ephem 4] UA]\n"
   append result "[list MOON_PHASE [lindex $moon_ephem 5] -180:+180]\n"

   #rosmodpoi_info $result
   return $result
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_modpoi_reset_stars
# ------------------------------------------------------------------------------------
#
# BUT : Supprime le fichier des mesures d'etoiles de reference pour le modele de pointage
#
# INPUT : Fichier
#
# OUTPUT : -
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_modpoi_reset_stars { {fichier_stars ""} } {
   global ros
   if {$fichier_stars==""} {
      set fichier_stars "$ros(rosmodpoi,path)/stars.txt"
   }
   file delete -force -- "$fichier_stars"
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_modpoi_choose_star
# ------------------------------------------------------------------------------------
#
# BUT : Recherche l'etoile du catalogue Hipparcos la plus proche du point d'amer indicé
#
# INPUTS : Index de l'etoile, nombre d'etoiles à pointer en site, nombre d'etoile à pointer en gisement, Fichier Hipparcos simplifie, Date
#
# OUTPUTS : Ligne ASCII de type "ID magV RA(Deg) DEC(Deg) Equinox(JDTT) Epoch(JDTT) mu_alpha.cos(delta)(mas/yr) mu_delta(mas/yr) Plx(mas)\n"
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_modpoi_choose_star { starindex {nsite 3} {ngise 4} {fichier_in ""} {date now} } {
   global ros
   if {$fichier_in==""} {
      set fichier_in "$ros(rosmodpoi,path)/$ros(rosmodpoi,cathipshort)"
   }
   set date [mc_date2jd $date]
   rosmodpoi_log "rosmodpoi_modpoi_choose_star : starindex=$starindex nsite=$nsite ngise=$ngise fichier_in=\"$fichier_in\"  date=$date"
   set res [mc_meo amer_hip $fichier_in [rosmodpoi_modpoi_liste_amers $nsite $ngise] $starindex 1 180 $date]
   return $res
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_corrected_positions
# ------------------------------------------------------------------------------------
#
# BUT : Retourne le fichier sod-site-gisements-distance-rotation-valid corrigee de tous les effets
#
# INPUTS : OutputFile DateDeb DateFin InputType InputData temperature pressure FileModel
#   InputTypes = "STAR_COORD" (etoile fixe, entree en coordonnees)
#      InputData = string
#         "RA DEC Equinoxe Epoque muRA.cos(delta)(marcsec/yr) muDEC(marcsec/yr) parallaxe(mas)"
#   InputTypes = "STAR_ID" (etoile fixe, entree en identificateur)
#      InputData = string
#         "ID CatalogFileName"
#         Catalog file lines must be formatted as follow:
#         "ID magV RA DEC Equinoxe Epoque muRA.cos(delta)(marcsec/yr) muDEC(marcsec/yr) parallaxe(mas)"
#   InputTypes = "SATEL_EPHEM_FILE" (satellite format of type file)
#      InputData = string
#         "EphemerisFileName"
#         Lines must be formatted as follow:
#         4 first lines are the header
#         following lines are:
#         "SOD Site(refraction_corrected) Gisement(refraction_corrected) distance"
#   InputTypes = "OBJECT_EPHEM_FILE" (satellite format of type file)
#      InputData = string
#         "EphemerisFileName"
#         Lines must be formatted as follow:
#         1 first lines are the header: JD_start Increment_min
#         following lines are:
#         "RA DEC"
#
# OUTPUTS : Nombre de positions calculées dans OutputFile
#
# OutputFile : rempli de lignes ASCII de type "SOD Site Gisement Distance Rotation Valid\n"
#   Entete de trois lignes
#   Rotation est l'angle parallactique
#   Valid=0 si l'on est procedure d'evitement du Soleil ou de fin de courses
#
# EXAMPLES :
#   rosmodpoi_corrected_positions "c:/d/meo/positions.txt" [list 2008 05 30 12 34 50] [list 2008 05 30 12 34 51] STAR_COORD [list 12h45m15.34s +34°56'23.3 J2000.0 J2000.0 0.01 -0.03 34] 290 101325 c:/d/meo/model.txt
#
#   set etoile [rosmodpoi_modpoi_choose_star 1 3 4]
#   rosmodpoi_corrected_positions "c:/d/meo/positions.txt" [mc_date2jd now] [mc_datescomp now + [expr 1/86400.]] STAR_COORD [lrange $etoile 2 end]
#
#   set etoile [rosmodpoi_close_star 50 180]
#   rosmodpoi_corrected_positions "c:/d/meo/positions.txt" [mc_date2jd now] [mc_datescomp now + [expr 1/86400.]] STAR_COORD [lrange $etoile 2 end]
#
#   rosmodpoi_corrected_positions "c:/d/meo/positions.txt" [list 2008 05 30 12 34 50] [list 2008 05 30 12 36 00] STAR_ID [list 113 "c:/d/meo/hip.txt"]
#
#   rosmodpoi_corrected_positions "c:/d/meo/positions.txt" [list 2008 05 08 07 03 00] [list 2008 05 08 07 04 00] SATEL_EPHEM_FILE "c:/d/meo/jas10805080703.txt"
#
#   A VENIR : rosmodpoi_corrected_positions "c:/d/meo/positions.txt" [list 2008 05 30 12 34 50] [list 2008 05 30 12 36 00] OBJECT_EPHEM_FILE "c:/d/meo/moon20080530.txt"
# ------------------------------------------------------------------------------------
proc rosmodpoi_corrected_positions { OutputFile DateDeb DateFin InputType InputData {temperature 290} {pressure 101325} {PointingModelFile ""} } {

   global ros

   set result ""
   set jddeb [mc_date2jd $DateDeb]
   set jdfin [mc_date2jd $DateFin]

   set duree [expr $jdfin-$jddeb]
   if {$duree<=0} {
      error "DateDeb($DateDeb) > DateFin($DateFin)"
   }
   set date [expr ($jddeb+$jdfin)/2.]
   set res [mc_ephem {sun moon} $date {RA DEC AZIMUT ALTITUDE DELTA PHASE} -topo $ros(rosmodpoi,home)]
   set sun_ephem [lindex $res 0]
   set moon_ephem [lindex $res 1]
   set res [rosmodpoi_azimelev2sitegise [lindex $sun_ephem 2] [lindex $sun_ephem 3]]
   set sun_site [lindex $res 0]
   set sun_gise [lindex $res 1]
   set dt [expr 0.00016667*1200] ; # time sampling of the positions to calculate
   set nlignes [expr int(floor($duree*86400/$dt))]
   #rosmodpoi_info "nlignes=$nlignes"
   set nlig 0
   if {$PointingModelFile!=""} {
      rosmodpoi_modpoi_load "$PointingModelFile"
   }

   if {$InputType=="STAR_ID"} {
      set res [rosmodpoi_id_hip "[lindex $InputData 1]" "[lindex $InputData 0]"]
      set InputData [string range $res 2 end]
      set InputType "STAR_COORD"
   }
   if {$InputType=="STAR_COORD"} {
      set ra [lindex $InputData 0]
      set dec [lindex $InputData 1]
      set equinox [lindex $InputData 2]
      set epoch [lindex $InputData 3]
      #set mura [expr [lindex $InputData 4]*1e-3/86400/$cosdec]
      #set mudec [expr [lindex $InputData 5]*1e-3/86400]
      set parallax [lindex $InputData 6]
      # --- appel a la fonction C
      set nlig [mc_meo corrected_positions STAR_COORD "$OutputFile" $DateDeb $DateFin $ra $dec $equinox $epoch [lindex $InputData 4] [lindex $InputData 5] $parallax $ros(rosmodpoi,home) $temperature $pressure $PointingModelFile ]
   }
   if {$InputType=="STAR_COORD_TCL"} {
      #::console::affiche_resultat "InputData=$InputData"
      set ra [lindex $InputData 0]
      set dec [lindex $InputData 1]
      #::console::affiche_resultat "ra=$ra dec=$dec"
      set cosdec [expr cos($ros(rosmodpoi,pi)/180.*[mc_angle2deg $dec 90])]
      set equinox [lindex $InputData 2]
      set epoch [lindex $InputData 3]
      set mura [expr [lindex $InputData 4]*1e-3/86400/$cosdec]
      set mudec [expr [lindex $InputData 5]*1e-3/86400]
      set parallax [lindex $InputData 6]
      set date0 [mc_date2ymdhms $jddeb]
      set sod0 [expr ($jddeb-[mc_date2jd [list [lindex $date0 0] [lindex $date0 1] [lindex $date0 2]]])*86400.]
      append result "STAR_COORD\n"
      append result "STAR_COORD [expr $jddeb-2400000.5] \n"
      append result "  43.75463222   6.92157300 1323.338  43.75046555   6.92388042   .0000 3.9477997593 0. 0. 0. 6.300388098783  .5000\n"
      for {set kl 0} {$kl<$nlignes} {incr kl} {
         set djd [expr $dt*$kl/86400.]
         set jd [mc_datescomp $jddeb + $djd]
         # --- Transforme les coordonnées moyennes en coordonnees observées
         set listv [rosmodpoi_modpoi_catalogmean2apparent $ra $dec $equinox $jd $ros(rosmodpoi,home) $epoch $mura $mudec $parallax]
         set listo [rosmodpoi_modpoi_apparent2observed $listv $temperature $pressure $jd $ros(rosmodpoi,home)]
         set rao [lindex $listo 0]
         set deco [lindex $listo 1]
         set altaz [mc_radec2altaz $rao $deco $ros(rosmodpoi,home) $jd]
         set star_rotateur [lindex $altaz 3]
         # --- Calcule la sépration avec le Soleil
         set res [rosmodpoi_azimelev2sitegise [lindex $altaz 0] [lindex $altaz 1]]
         set star_site [lindex $res 0]
         set star_gise [lindex $res 1]
         set res [mc_sepangle $sun_site $sun_gise $star_site $star_gise]
         set sep [lindex $res 0]
         set valid 1
         if {$sep<10} {
            set valid 0
         }
         # --- Transforme les coordonnees observées en coordonnées télescope
         if {$PointingModelFile!=""} {
            set azim [lindex $altaz 0]
            set elev [lindex $altaz 1]
            set altaz [rosmodpoi_modpoi_obs2tel $azim $elev]
            set res [rosmodpoi_azimelev2sitegise [lindex $altaz 0] [lindex $altaz 1]]
            set star_site [lindex $res 0]
            set star_gise [lindex $res 1]
         }
         # --- Calcule le SOD
         set sod [expr $sod0+$dt*$kl]
         if {$sod>=86400} {
            set sod [expr $sod-86400.]
         }
         # --- Mise en forme finale de la ligne
         set distance -1
         set ligne "[format %9.3f $sod] [format %9.6f $star_site] [format %10.6f $star_gise] [format %13.6f $distance] [format %10.6f $star_rotateur] $valid"
         #rosmodpoi_info "$ligne\n"
         append result "$ligne\n"
         incr nlig
      }
      set f [open "$OutputFile" w]
      puts -nonewline $f $result
      close $f
   }
   if {$InputType=="STAR_COORD_ONEPOS_TCL"} {
      #::console::affiche_resultat "InputData=$InputData"
      set ra [lindex $InputData 0]
      set dec [lindex $InputData 1]
      #::console::affiche_resultat "ra=$ra dec=$dec"
      set cosdec [expr cos($ros(rosmodpoi,pi)/180.*[mc_angle2deg $dec 90])]
      set equinox [lindex $InputData 2]
      set epoch [lindex $InputData 3]
      set mura [expr [lindex $InputData 4]*1e-3/86400/$cosdec]
      set mudec [expr [lindex $InputData 5]*1e-3/86400]
      set parallax [lindex $InputData 6]
      set date0 [mc_date2ymdhms $jddeb]
      set sod0 [expr ($jddeb-[mc_date2jd [list [lindex $date0 0] [lindex $date0 1] [lindex $date0 2]]])*86400.]
      #append result "STAR_COORD\n"
      #append result "STAR_COORD [expr $jddeb-2400000.5] \n"
      #append result "  43.75463222   6.92157300 1323.338  43.75046555   6.92388042   .0000 3.9477997593 0. 0. 0. 6.300388098783  .5000\n"
      set nlignes 1
      for {set kl 0} {$kl<$nlignes} {incr kl} {
         set djd [expr $dt*$kl/86400.]
         set jd [mc_datescomp $jddeb + $djd]
         # --- Transforme les coordonnées moyennes en coordonnees observées
         set listv [rosmodpoi_modpoi_catalogmean2apparent $ra $dec $equinox $jd $ros(rosmodpoi,home) $epoch $mura $mudec $parallax]
         set listo [rosmodpoi_modpoi_apparent2observed $listv $temperature $pressure $jd $ros(rosmodpoi,home)]
         set rao [lindex $listo 0]
         set deco [lindex $listo 1]
         set hao [lindex $listo 2]
         set altaz [mc_radec2altaz $rao $deco $ros(rosmodpoi,home) $jd]
         set star_rotateur [lindex $altaz 3]
         # --- Calcule la sépration avec le Soleil
         set res [rosmodpoi_azimelev2sitegise [lindex $altaz 0] [lindex $altaz 1]]
         set star_site [lindex $res 0]
         set star_gise [lindex $res 1]
         set res [mc_sepangle $sun_site $sun_gise $star_site $star_gise]
         set sep [lindex $res 0]
         set valid 1
         if {$sep<10} {
            set valid 0
         }
         # --- Transforme les coordonnees observées en coordonnées télescope
         set res [rosmodpoi_azimelev2sitegise [lindex $altaz 0] [lindex $altaz 1]]
         set star_site [lindex $res 0]
         set star_gise [lindex $res 1]
         if {$PointingModelFile!=""} {
            if {$ros(rosmodpoi,mount)=="altaz"} {
               set azim [lindex $altaz 0]
               set elev [lindex $altaz 1]
               set altaz [rosmodpoi_modpoi_obs2tel $azim $elev]
               set res [rosmodpoi_azimelev2sitegise [lindex $altaz 0] [lindex $altaz 1]]
               set star_site [lindex $res 0]
               set star_gise [lindex $res 1]
            } else {
               #set er [catch {set hadec [rosmodpoi_modpoi_obs2tel $hao $deco $rao]} msg ]
               set hadec [rosmodpoi_modpoi_obs2tel $hao $deco $rao]
               set hao [lindex $hadec 0]
               set deco [lindex $hadec 1]
               set rao [lindex $hadec 2]
            }
         }
         # --- Calcule le SOD
         set sod [expr $sod0+$dt*$kl]
         if {$sod>=86400} {
            set sod [expr $sod-86400.]
         }
         # --- Mise en forme finale de la ligne
         set distance -1
         set ligne "[format %9.3f $sod] [format %9.6f $star_site] [format %10.6f $star_gise] [format %13.6f $distance] [format %10.6f $star_rotateur] $valid [format %10.6f $rao] [format %10.6f $hao] [format %+10.6f $deco]"
         #rosmodpoi_info "$ligne\n"
         append result "$ligne\n"
         incr nlig
      }
      #set f [open "$OutputFile" w]
      #puts -nonewline $f $result
      #close $f
      set nlig $result
   }
   if {$InputType=="SATEL_EPHEM_FILE"} {
      set InputFile [lindex $InputData 0]
      # --- appel a la fonction C
      set nlig [mc_meo corrected_positions SATEL_EPHEM_FILE "$OutputFile" $DateDeb $DateFin "$InputFile" $ros(rosmodpoi,home) $temperature $pressure $PointingModelFile ]
   }
   if {$InputType=="SATEL_EPHEM_FILE_TCL"} {
      set f [open $InputData r]
      set ligne1 [gets $f]
      append result "$ligne1\n"
      set ligne2 [gets $f]
      append result "$ligne2\n"
      set ligne3 [gets $f]
      append result "$ligne3\n"
      set date0 [mc_date2jd [lindex $ligne2 1]]
      set jd0ephem [mc_date2jd [list [lindex $date0 0] [lindex $date0 1] [lindex $date0 2]]])*86400.]
      while {[eof $f]==0} {
         set ligne [gets $f]
         set sod  [lindex $ligne 0]
         set site [lindex $ligne 1]
         set gise [lindex $ligne 2]
         set distance [lindex $ligne 3]
         if {$distance==""} {
            continue
         }
         set jd [mc_datescomp $jd0ephem + [expr $sod/86400.]]
         # --- Refraction correction
         if {$site>-1.} {
            set refraction [mc_refraction $site out2in $temperature $pressure]
         } else {
            set refraction 0.
         }
         set site [expr $site+$refraction]
         # --- calcul de l'angle parallactique du derotateur
         set res [rosmodpoi_sitegise2azimelev $site $gise]
         set azim [lindex $res 0]
         set elev [lindex $res 1]
         set radec [mc_altaz2radec $azim $elev $ros(rosmodpoi,home) $jd]
         set altaz [mc_radec2altaz [lindex $radec 0] [lindex $radec 1] $ros(rosmodpoi,home) $jd]
         set star_rotateur [lindex $altaz 3]
         # --- Calcule la sépration avec le Soleil
         set res [list $site $gise]
         set star_site [lindex $res 0]
         set star_gise [lindex $res 1]
         set res [mc_sepangle $sun_site $sun_gise $star_site $star_gise]
         set sep [lindex $res 0]
         set valid 1
         if {$sep<10} {
            set valid 0
         }
         # --- Transforme les coordonnees observées en coordonnées télescope
         if {$PointingModelFile!=""} {
            set azim [lindex $altaz 0]
            set elev [lindex $altaz 1]
            set altaz [rosmodpoi_modpoi_obs2tel $azim $elev]
            set res [rosmodpoi_azimelev2sitegise [lindex $altaz 0] [lindex $altaz 1]]
            set star_site [lindex $res 0]
            set star_gise [lindex $res 1]
         }
         #
         set ligne "[format %9.3f $sod] [format %9.6f $star_site] [format %10.6f $star_gise] [format %13.6f $distance] [format %10.6f $star_rotateur] $valid"
         #rosmodpoi_info "$ligne\n"
         append result "$ligne\n"
         incr nlig
      }
      set f [open "$OutputFile" w]
      puts -nonewline $f $result
      close $f
   }

   return $nlig
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_modpoi_add_star
# ------------------------------------------------------------------------------------
#
# BUT : Recherche l'etoile du catalogue Hipparcos la plus proche du point d'amer indicé
#
# INPUTS : Ligne ASCII de type "ID magV RA(Deg) DEC(Deg) Equinox(JDTT) Epoch(JDTT) mu_alpha.cos(delta)(mas/yr) mu_delta(mas/yr) Plx(mas)\n"
#          dsiteo dgiseo les ecarts observes (arcmin)
#          fichier_stars : le fichier des etoiles pointees
#          L'heure actuelle
#          Temperature
#          Pression
#
# EXAMPLE :
#  rosmodpoi_modpoi_reset_stars "c:/d/meo/modpoistars.txt"
#  set etoile [rosmodpoi_modpoi_choose_star 0 3 4]
#  rosmodpoi_corrected_positions "c:/d/meo/positions.txt" [mc_date2jd now] [mc_datescomp now + [expr 10/86400.]] STAR_COORD [lrange $etoile 2 end] 290 101325 ""
#  => Gilles "c:/d/meo/positions.txt"
#  => Boule dsite et dgise
#  rosmodpoi_modpoi_add_star $etoile 1.34 0.12 "c:/d/meo/modpoistars.txt" [mc_date2jd now] 300 101325
#  set etoile [rosmodpoi_modpoi_choose_star 1 3 4]
#  rosmodpoi_corrected_positions "c:/d/meo/positions.txt" [mc_date2jd now] [mc_datescomp now + [expr 10/86400.]] STAR_COORD [lrange $etoile 2 end] 290 101325 ""
#  => Gilles "c:/d/meo/positions.txt"
#  => Boule dsite et dgise
#  rosmodpoi_modpoi_add_star $etoile 1.42 0.28 "c:/d/meo/modpoistars.txt" [mc_date2jd now] 300 101325
#  ...
#  continuer jusqu'à set etoile [rosmodpoi_modpoi_choose_star 11 3 4]
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_modpoi_add_star { star dsiteo dgiseo fichier_stars {date now} {temperature 273} {pressure 101325} } {
   global ros
   if {$fichier_stars==""} {
      set fichier_stars "$ros(rosmodpoi,path)/stars.txt"
   }
   set jd [mc_date2jd $date]
   set starid [lindex $star 0]
   #
   set InputData [lrange $star 2 end]
   set ra [lindex $InputData 0]
   set dec [lindex $InputData 1]
   set cosdec [expr cos($ros(rosmodpoi,pi)/180.*[mc_angle2deg $dec 90])]
   set equinox [lindex $InputData 2]
   set epoch [lindex $InputData 3]
   set mura [expr [lindex $InputData 4]*1e-3/86400/$cosdec]
   set mudec [expr [lindex $InputData 5]*1e-3/86400]
   set parallax [lindex $InputData 6]
   # --- Transforme les coordonnées moyennes en coordonnees observées
   set listv [rosmodpoi_modpoi_catalogmean2apparent $ra $dec $equinox $jd $ros(rosmodpoi,home) $epoch $mura $mudec $parallax]
   set listo [rosmodpoi_modpoi_apparent2observed $listv $temperature $pressure $jd $ros(rosmodpoi,home)]
   set rao [lindex $listo 0]
   set deco [lindex $listo 1]
   set hao [lindex $listo 2]
   set altaz [mc_radec2altaz $rao $deco $ros(rosmodpoi,home) $jd]
   set res [rosmodpoi_azimelev2sitegise [lindex $altaz 0] [lindex $altaz 1]]
   set star_site [lindex $res 0]
   set star_gise [lindex $res 1]
   # --- Mise en forme de la ligne
   if {$ros(rosmodpoi,mount)=="altaz"} {
      set texte "$starid $date $star_site $star_gise $dsiteo $dgiseo $pressure $temperature 0 0"
   } else {
      set texte "$starid $date $deco $hao $dsiteo $dgiseo $pressure $temperature 0 0"
   }
   set f [open "$fichier_stars" a]
   puts -nonewline $f "$texte\n"
   close $f
   return
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_close_star
# ------------------------------------------------------------------------------------
#
# BUT : Recherche les etoiles du catalogue Hipparcos les plus proches du point site,gisement indiqué
#
# INPUTS : site, gisement, Fichier Hipparcos simplifie, Nombre d'étoile max, Séparation max (en degres), Date
#
# OUTPUTS : Ligne ASCII de type "ID magV RA(Deg) DEC(Deg) Equinox(JDTT) Epoch(JDTT) mu_alpha.cos(delta)(mas/yr) mu_delta(mas/yr) Plx(mas)\n"
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_close_star { site gisement {fichier_in ""} {nstars 1} {sepmax 360} {date now} } {
   global ros
   if {$fichier_in==""} {
      set fichier_in "$ros(rosmodpoi,path)/$ros(rosmodpoi,cathipshort)"
   }
   set date [mc_date2jd $date]
   set res [mc_meo amer_hip $fichier_in [list [list $site $gisement]] 0 $nstars $sepmax $date]
   return $res
}

# ------------------------------------------------------------------------------------
# PROC : rosmodpoi_modpoi_verify_model
# ------------------------------------------------------------------------------------
#
# BUT : Calcule une verification du modele
#
# INPUTS :
#    FileObs : fichier des observations avec chaque ligne qui contient une etoile definie par:
#     starid :ID dans le catalogue d'etoiles de reference
#     date : Date UTC de la mesure
#     site : coord apparentes (degrees)
#     gise : coord apparentes (degrees)
#     dsiteo : siteo-site (arcmin)
#     dgiseo : giseo-gise (arcmin)
#     pressure : pression reelle (Pascal)
#     temperature : temperature (Kelvin)
#     dsitec : sitec-site calculé par cette fonction (residus du modele en arcmin)
#     dgisec : gisec-gise calculé par cette fonction (residus du modele en arcmin)
#    FileModel : fichier du model
#    symbos : Liste des coefficients du modele à calculer
#
# OUTPUTS : Un texte explicatif
#
# rosmodpoi_modpoi_verify_model "c:/d/meo/Correction.txt" "c:/d/meo/model.txt"
#
# ------------------------------------------------------------------------------------
proc rosmodpoi_modpoi_verify_model { FileObs FileModel } {
   global ros
   # --- Lecture des observations + decalages
   set f [open "$FileObs" r]
   set lignes [split [read $f] \n]
   close $f
   set textes ""
   foreach ligne $lignes {
      if {[llength $ligne]<7} {
         continue
      }
      set id [lindex $ligne 0]
      set jd [lindex $ligne 1]
      set siteo [lindex $ligne 2]
      set giseo [lindex $ligne 3]
      set pressure [lindex $ligne 6]
      set temperature [lindex $ligne 7]
      set etoile [rosmodpoi_id_hip "" $id]
      rosmodpoi_corrected_positions "testpos.txt" [mc_date2jd $jd] [mc_datescomp $jd + [expr 1/86400.]] STAR_COORD [lrange $etoile 2 end] $temperature $pressure $FileModel
      set f [open "testpos.txt" r]
      set ligne [gets $f]
      set ligne [gets $f]
      set ligne [gets $f]
      set ligne [gets $f]
      close $f
      set sitec [lindex $ligne 1]
      set gisec [lindex $ligne 2]
      set dsite [expr ($siteo-$sitec)*60.]
      set dgise [expr ($giseo-$gisec)*60.]
      append textes "$id $dsite $dgise\n"
   }
   return $textes
}

####################################################################################"
####################################################################################"
# TESTS
####################################################################################"
####################################################################################"

# --- generer un modele
if {1==0} {
   source c:/d/meo/rosmodpoi_tools.tcl
   rosmodpoi_modpoi_reset_stars "c:/d/meo/modpoistars.txt"
   set dss { {0.28 1.23} {0.28 1.40} {0.28 1.23} {-0.28 1.23} {0.28 1.23} {0.28 -2.23} {0.28 1.23} {-0.18 3.23} {0.28 1.23} {-0.48 1.23} {0.28 1.23} {0.28 -2.23} }
   for {set k 0} {$k<12} {incr k} {
      set etoile [rosmodpoi_modpoi_choose_star $k 3 4]
      set ds [lindex $dss $k]
      rosmodpoi_modpoi_add_star $etoile [lindex $ds 0] [lindex $ds 1] "c:/d/meo/modpoistars.txt" [mc_date2jd now] 300 101325
   }
   rosmodpoi_modpoi_compute_model "c:/d/meo/modpoistars.txt" "c:/d/meo/model.txt"
}

# --- utiliser un modele
if {1==0} {
   set etoile [rosmodpoi_modpoi_choose_star 1 3 4]
   rosmodpoi_corrected_positions "c:/d/meo/positions.txt" [mc_date2jd now] [mc_datescomp now + [expr 1/86400.]] STAR_COORD [lrange $etoile 2 end] 290 10325  "c:/d/meo/model.txt"
}

