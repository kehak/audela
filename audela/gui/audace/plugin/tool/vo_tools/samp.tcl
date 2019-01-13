## @file samp.tcl
# @brief Implementation du protocole SAMP de communication entre applications (http://ivoa.net/documents/SAMP/index.html)
# @author J. Berthier (berthier@imcce.fr) et S. Vaillant (stephane.vaillant@obspm.fr)
# @par Ressource
# @code source [file join $audace(rep_install) gui audace plugin tool vo_tools samp.tcl]
# @endcode

# $Id: samp.tcl 13890 2016-05-23 16:35:52Z jberthier $

##
# @namespace Samp
# @brief Implementation du protocole SAMP de communication entre applications (http://ivoa.net/documents/SAMP/index.html)
# @pre Requiert le fichier d'internationalisation \c sampTools.cap .
#
namespace eval ::Samp {

   package require SOAP
   package require XMLRPC
   package require rpcvar
   namespace import ::rpcvar::typedef

   # Samp metadata structure
   typedef {
      samp.name string
      samp.description.text string
      samp.icon.url string
      samp.documentation.url string
      audela.version string
      home.page string
   } declareMetadataStruct

   typedef { } emptymap

   # Samp msg subscription
   typedef {
      samp.hub.event.register struct
      samp.hub.event.shutdown struct
      samp.hub.event.unregister struct
      samp.hub.event.metadata struct
      samp.hub.disconnect struct
      samp.app.ping struct
      image.load.fits struct
      table.load.votable struct
      spectrum.load.ssa-generic struct
      table.highlight.row struct
      coord.pointAt.sky struct
      table.select.rowList struct
      script.aladin.send struct
   } declareSubscriptions

   # Samp msg load.image.fits
   typedef {
      name string
      image-id string
      url string
   } imageLoadFits

   typedef {
      samp.mtype string
      samp.params imageLoadFits
   } imageLoadFitsWrapper

   # Samp msg table.load.votable
   typedef {
      name string
      table-id string
      url string
   } tableLoadVotable

   typedef {
      samp.mtype string
      samp.params tableLoadVotable
   } tableLoadVotableWrapper

   # Samp msg spectrum.load.ssa-generic
   typedef {
      name string
      spectrum-id string
      url string
   } spectrumLoadSsaGeneric

   typedef {
      samp.mtype string
      samp.params spectrumLoadSsaGeneric
   } spectrumLoadSsaGenericWrapper

   # Samp msg coord.pointAt.sky
   typedef {
      ra string
      dec string
   } coordPointAtSky

   typedef {
      samp.mtype string
      samp.params coordPointAtSky
   } coordPointAtSkyWrapper

   # Samp msg script.aladin.send
   typedef {
      script string
   } sendAladinScript

   typedef {
      samp.mtype string
      samp.params sendAladinScript
   } sendAladinScriptWrapper

   # Internationalisation
   source [ file join [file dirname [info script]] samp.cap ]
}

# #############################################################################
#
# Implementation des methodes de l'espace de nom samp
#
# #############################################################################

## @brief Implementation du protocol SAMP (attributs, methodes)
# @param nsp nom du namespace (e.g. "::samp")
#
proc ::Samp::build { nsp } {

   namespace eval $nsp {
      variable params
      variable key
   }

   # Recherche et chargement du fichier $HOME/.samp
   set path [file join $::env(HOME) ".samp"]
   if { ! ([file exists $path] && [file isfile $path]) } { return 0 }
   set chan [open $path]
   while {[gets $chan line] >= 0} {
      if {[string first "#" $line] >= 0} { continue }
      set l [split $line "="]
      set ${nsp}::params([lindex $l 0]) [lindex $l 1]
   }
   close $chan

   # Declaration des methodes SAMP
   XMLRPC::create ${nsp}::m_register \
            -uri [set ${nsp}:::params(samp.hub.xmlrpc.url)] \
            -proxy [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -params { arg string } \
            -name "samp.hub.register"

   XMLRPC::create ${nsp}::m_unregister \
            -uri [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -proxy [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -params { arg string } \
            -name "samp.hub.unregister"

   XMLRPC::create ${nsp}::m_disconnect \
            -uri [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -proxy [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -params { arg string } \
            -name "samp.hub.disconnect"

   XMLRPC::create ${nsp}::m_declare \
            -uri [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -proxy [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -params { arg1 string arg2 declareMetadataStruct } \
            -name "samp.hub.declareMetadata"

   XMLRPC::create ${nsp}::m_setXmlrpcCallback \
            -uri [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -proxy [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -params { arg1 string arg2 string } \
            -name "samp.hub.setXmlrpcCallback"

   XMLRPC::create ${nsp}::m_declareSubscriptions \
            -uri [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -proxy [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -params { arg1 string arg2 declareSubscriptions } \
            -name "samp.hub.declareSubscriptions"

   XMLRPC::create ${nsp}::m_imageLoadFits \
            -uri [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -proxy [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -params { arg1 string arg2 imageLoadFitsWrapper } \
            -name "samp.hub.notifyAll"

   XMLRPC::create ${nsp}::m_tableLoadVotable \
            -uri [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -proxy [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -params { arg1 string arg2 tableLoadVotableWrapper } \
            -name "samp.hub.notifyAll"

   XMLRPC::create ${nsp}::m_spectrumLoadSsaGeneric \
            -uri [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -proxy [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -params { arg1 string arg2 spectrumLoadSsaGenericWrapper } \
            -name "samp.hub.notifyAll"

   XMLRPC::create ${nsp}::m_coordPointAtSky \
            -uri [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -proxy [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -params { arg1 string arg2 coordPointAtSkyWrapper } \
            -name "samp.hub.notifyAll"

   XMLRPC::create ${nsp}::m_sendAladinScript \
            -uri [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -proxy [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -params { arg1 string arg2 sendAladinScriptWrapper } \
            -name "samp.hub.notifyAll"

   # Implementation des methodes SAMP

   # Register AudeLA to Samp hub
   proc ${nsp}::register {} {
      global caption
      variable params
      variable key
      set msg [ m_register [set params(samp.secret)] ]
      array set iparams $msg
      set key $iparams(samp.private-key)
      set err [catch { package present audela } audelaVersion ]
      if {$err != 0} { set audelaVersion "?" }
      set registerInfo [list samp.name AudeLA]
      lappend registerInfo samp.description.text $caption(samp,description_text)
      lappend registerInfo samp.icon.url {http://audela.org/download/audela-logo.png}
      lappend registerInfo samp.documentation.url {http://www.audela.org/dokuwiki/doku.php?do=index&id=start}
      lappend registerInfo audela.version $audelaVersion
      lappend registerInfo home.page http://www.audela.org/
      m_declare $key $registerInfo
   }

   # Unregister AudeLA from Samp hub
   proc ${nsp}::unregister {} {
      variable key
      m_unregister $key
   }

   # Samp Handler: analyse et decoupe les msg administratifs du hub
   proc ${nsp}::handler {msg} {
      variable key
      set evt [lindex $msg 0]
      set a [lindex $msg 1]
      set la [llength $a]
      set k [lindex $a 0]
      if { ! ($k eq $key) } {
         return 0
      }
      set hub [lindex $a 1]
      set b [lindex $a 2]
      array set p [lindex $a [expr [llength $a] - 1]]
      set hndlr h_$p(samp.mtype)
      if {[info proc $hndlr] eq $hndlr} {
         $hndlr $p(samp.params)
      }
   }

   #
   proc ${nsp}::chanreadheader {chan} {
      variable buf
      variable datalen
      variable state
      if { ! [eof $chan] } {
         set line [gets $chan]
         if { $line eq ""} {
            fileevent $chan readable [list [namespace current]::chanread $chan]
            puts $chan "HTTP/1.1 200 OK\r\n\r"
            return
         }
         if {[regexp -nocase {^content-length:\s*(\d+)\s*$} $line allmatch len]} {
            set datalen($chan) $len
         }
      } else {

      }
   }

   #
   proc ${nsp}::chanread {chan} {
      variable buf
      variable datalen
      variable state
      if { ! [eof $chan] } {
         set line [gets $chan]
         set buf($chan) "$buf($chan)\n$line"
         set datalen($chan) [expr $datalen($chan) - [string length $line] - 1]
         if {$datalen($chan) == 0} {
            set resp [::SOAP::parse_xmlrpc_request $buf($chan)]
            set buf($chan) ""
            set state($chan) 0
            set datalen($chan) 0
            fileevent $chan readable {}
            close $chan
            handler $resp
         } elseif {$datalen($chan) < 0 } {

         }
      } else {

      }
   }

   # Samp server
   proc ${nsp}::Server {channel clientaddr clientport} {
      variable buf
      variable datalen
      variable state
      fconfigure $channel -blocking 0 -buffering line
      namespace eval ::chan { }
      set buf($channel) ""
      set state($channel) 0
      set datalen($channel) 0
      fileevent $channel readable [list [namespace current]::chanreadheader $channel]
   }

   # Samp hub shutdown
   proc ${nsp}::h_samp.hub.event.shutdown {args} {
      global caption
      set [namespace current]::initialized 0
      close [ set "[namespace current]::sockserver" ]
      ::console::affiche_erreur "$caption(samp,hub_shutdown) \n"
      ::vo_tools::handleInteropBtnState "disabled"
      ::vo_tools::handleBroadcastBtnState
   }

   # Samp msg samp.hub.disconnect
   proc ${nsp}::h_samp.hub.disconnect {args} {
      global caption
      set [namespace current]::initialized 0
      close [ set "[namespace current]::sockserver" ]
      ::console::affiche_erreur "$caption(samp,hub_disconnect) \n"
      ::vo_tools::handleInteropBtnState "disabled"
      ::vo_tools::handleBroadcastBtnState
   }

   # Samp msg samp.hub.event.register
   proc ${nsp}::h_samp.hub.event.register {args} {
#      puts "REGISTER: $args"
   }

   # Samp msg samp.hub.event.unregister
   proc ${nsp}::h_samp.hub.event.unregister {args} {
#      puts "UNREGISTER: $args"
   }

   # Samp msg samp.hub.event.register
   proc ${nsp}::h_samp.hub.event.metadata {args} {
#      puts "METADATA: $args"
   }

   # Samp msg image.load.fits
   proc ${nsp}::h_image.load.fits {args} {
      global caption
      # Recupere les infos broadcastees par les applis VO
      array set p [lindex $args 0]
      set name ""
      set imageid ""
      set url ""
      foreach element [array names p] {
         switch $element {
            "name" {
               set name $p(name)
            }
            "image-id" {
               set imageid [::Samp::expandEntities $p(image-id)]
            }
            "url" {
               set url [::Samp::expandEntities $p(url)]
            }
         }
      }
      ::console::affiche_resultat "$caption(samp,reception_image) $name ($url)\n"
      # Extrait le chemin pour charger l'image a partir des infos fournies
      set paths {}
      foreach param [list $imageid $url] {
         if {[regexp {^file:((.:)*/ *(/.*))} $param allmatch path]} {
            lappend paths $path
         }
         if {[regexp {^file:/*[^/]+/*((.:)*(/.*))} $param allmatch path]} {
            lappend paths $path
         }
         if {[regexp {sampfile:((.:)*(/.*))} $param allmatch path]} {
            lappend paths $path
         }
      }
      # Essaye d'afficher une image
      set isLoaded 0
      foreach path $paths {
         if {[file exists $path]} {
            loadima "$path"
            set isLoaded 1
            break
         }
      }
      # Si aucune image n'a pu etre chargee, envoie d'un msg
      if {! $isLoaded} {
         tk_messageBox -title "Error" -type ok -message $caption(samp,image_failed)
      }
      # Mise a jour du statut du menu
      ::vo_tools::handleBroadcastBtnState
   }

   # Samp msg table.load.votable
   proc ${nsp}::h_table.load.votable {args} {
      global audace caption
      # Recupere les infos broadcastees par les applis VO
      array set p [lindex $args 0]
      set name ""
      set tableid ""
      set url ""
      foreach element [array names p] {
         switch $element {
            "name" {
               set name $p(name)
            }
            "table-id" {
               set tableid [::Samp::expandEntities $p(table-id)]
            }
            "url" {
               set url [::Samp::expandEntities $p(url)]
            }
         }
      }
      ::console::affiche_resultat "$caption(samp,reception_votable) $name ($url)\n"
      # Extrait le chemin pour charger la votable a partir des infos fournies
      set paths {}
      foreach param [list $tableid $url] {
         if {[regexp {^file:((.:)*/*(/.*))} $param allmatch path]} {
            lappend paths $path
         }
         if {[regexp {^file:/*[^/]+/*((.:)*(/.*))} $param allmatch path]} {
            lappend paths $path
         }
         if {[regexp {sampfile:((.:)*(/.*))} $param allmatch path]} {
            lappend paths $path
         }
      }
      # Essaye d'afficher la votable
      set isLoaded 0
      foreach path $paths {
         if {[file exists $path]} {
            if {[::votableUtil::loadVotable "$path" $::audace(visuNo)]} {
               ::votableUtil::displayVotable [::votableUtil::votable2list] $::audace(visuNo) "orange" "oval"
               set isLoaded 1
               break
            }
         }
      }
      # Si aucune votable n'a pu etre chargee, envoie d'un msg
      if {! $isLoaded} {
         tk_messageBox -title "Error" -type ok -message $caption(samp,votable_failed)
      }
      # Mise a jour du statut du menu
      ::vo_tools::handleBroadcastBtnState
   }

   # Samp msg spectrum.load.ssa-generic
   proc ${nsp}::h_spectrum.load.ssa-generic {args} {
      global caption
      # Recupere les infos broadcastees par les applis VO
      array set p [lindex $args 0]
      set name ""
      set spectrumid ""
      set url ""
      foreach element [array names p] {
         switch $element {
            "name" {
               set name $p(name)
            }
            "spectrum-id" {
               set spectrumid [::Samp::expandEntities $p(spectrum-id)]
            }
            "url" {
               set url [::Samp::expandEntities $p(url)]
            }
         }
      }
      ::console::affiche_resultat "$caption(samp,reception_spectrum) $name ($url)\n"
      # Extrait le chemin pour charger le spectre a partir des infos fournies
      set paths {}
      foreach param [list $spectrumid $url] {
         if {[regexp {^file:((.:)*/*(/.*))} $param allmatch path]} {
            lappend paths $path
         }
         if {[regexp {^file:/*[^/]+/*((.:)*(/.*))} $param allmatch path]} {
            lappend paths $path
         }
         if {[regexp {sampfile:((.:)*(/.*))} $param allmatch path]} {
            lappend paths $path
         }
      }
      # Essaye d'afficher le spectre
      set isLoaded 0
      foreach path $paths {
         if {[file exists $path]} {
            loadima "$path"
            set isLoaded 1
            break
         }
      }
      # Si aucun spectre n'a pu etre charge, envoie d'un msg
      if {! $isLoaded} {
         tk_messageBox -title "Error" -type ok -message $caption(samp,spectrum_failed)
      }
      # Mise a jour du statut du menu
      ::vo_tools::handleBroadcastBtnState
   }

   # Samp msg coord.pointAt.sky
   proc ${nsp}::h_coord.pointAt.sky {args} {
      global caption
      set coords [split [lindex $args 0] " "]
      set ::Samp::ra [lindex $coords 1]
      set ::Samp::de [lindex $coords 3]
      ::console::affiche_resultat "$caption(samp,pointatsky) \n RA = $::Samp::ra \n DEC = $::Samp::de \n"
      ::votableUtil::pointAtSky [lindex $coords 1] [lindex $coords 3]
   }

   namespace eval $nsp {
      global caption
      variable key
      variable port sockserver msg initialized
      register
      set sockserver [socket -server [namespace current]::Server 0]
      set port [ lindex [fconfigure $sockserver -sockname] 2 ]
      ::console::disp "$caption(samp,connection) \n"
      ::console::disp "$caption(samp,tcpport) $port \n"
      set msg [m_setXmlrpcCallback $key "http://127.0.0.1:$port/"]
      set msg [m_declareSubscriptions $key { samp.app.ping {}
                                             samp.hub.event.register {}
                                             samp.hub.event.shutdown {}
                                             samp.hub.event.unregister {}
                                             samp.hub.event.metadata {}
                                             samp.hub.disconnect {}
                                             coord.pointAt.sky {}
                                             script.aladin.send {}
                                             image.load.fits {}
                                             table.load.votable {}
                                             spectrum.load.ssa-generic {}
                                             table.highlight.row {}
                                             table.select.rowList {} }]
      set [namespace current]::initialized 1
   }

   return 1
}


## @brief Verifie la connexion au hub SAMP
# @return 1 ou 0 selon que le hub est connecte ou non
#
proc ::Samp::isConnected { } {
   if { [info exists ::samp::initialized] && [expr $::samp::initialized == 1]} {
      # yes, connected
      return 1
   } else {
      # no, not connected
      return 0
   }
}


## @brief Verifie la connexion au hub SAMP, sinon cree cette connexion
# @return 1 ou 0 selon que le hub est connecte ou non
#
proc ::Samp::check { } {
   if { [::Samp::isConnected]} {
      # connection already established
      return 1
   } else {
      if { [::Samp::build ::samp] } {
         # connected to samp hub
         return 1
      } else {
         # samp hub not found
         return 0
      }
   }
}


## @brief Deconnexion du hub SAMP
#
proc ::Samp::destroy { } {
   global caption
   if { [::Samp::isConnected]} {
      if { [catch { ::samp::unregister } result ] } {
         set ::samp::initialized 0
         ::console::affiche_erreur "$caption(samp,unregerror) \n"
         ::console::affiche_resultat "$caption(samp,disconnected) \n"
      } else {
         set ::samp::initialized 0
         close $::samp::sockserver
         ::console::affiche_resultat "$caption(samp,disconnected) \n"
      }
   } else {
      ::console::affiche_erreur "$caption(samp,notconnected) \n"
   }
}


## @brief expand hexadecimal entities into ascii characters
# @param chunk chaîne a convertir
# @return chunk chaîne convertie
#
proc ::Samp::expandEntities { chunk } {
   regsub -all {\+}  $chunk { }  chunk
   regsub -all {%20} $chunk { }  chunk
   regsub -all {%21} $chunk {!}  chunk
   regsub -all {%22} $chunk {\"} chunk
   regsub -all {%23} $chunk {#}  chunk
   regsub -all {%24} $chunk {$}  chunk
   regsub -all {%25} $chunk {%}  chunk
   regsub -all {%26} $chunk {&}  chunk
   regsub -all {%27} $chunk {'}  chunk
   regsub -all {%28} $chunk {(}  chunk
   regsub -all {%29} $chunk {)}  chunk
   regsub -all {%2A} $chunk {*}  chunk
   regsub -all {%2B} $chunk {+}  chunk
   regsub -all {%2C} $chunk {,}  chunk
   regsub -all {%2D} $chunk {-}  chunk
   regsub -all {%2E} $chunk {.}  chunk
   regsub -all {%2F} $chunk {/}  chunk
   regsub -all {%30} $chunk {0}  chunk
   regsub -all {%31} $chunk {1}  chunk
   regsub -all {%32} $chunk {2}  chunk
   regsub -all {%33} $chunk {3}  chunk
   regsub -all {%34} $chunk {4}  chunk
   regsub -all {%35} $chunk {5}  chunk
   regsub -all {%36} $chunk {6}  chunk
   regsub -all {%37} $chunk {7}  chunk
   regsub -all {%38} $chunk {8}  chunk
   regsub -all {%39} $chunk {9}  chunk
   regsub -all {%3A} $chunk {:}  chunk
   regsub -all {%3B} $chunk {;}  chunk
   regsub -all {%3C} $chunk {<}  chunk
   regsub -all {%3D} $chunk {=}  chunk
   regsub -all {%3E} $chunk {>}  chunk
   regsub -all {%3F} $chunk {?}  chunk
   regsub -all {%40} $chunk {@}  chunk
   regsub -all {%41} $chunk {A}  chunk
   regsub -all {%42} $chunk {B}  chunk
   regsub -all {%43} $chunk {C}  chunk
   regsub -all {%44} $chunk {D}  chunk
   regsub -all {%45} $chunk {E}  chunk
   regsub -all {%46} $chunk {F}  chunk
   regsub -all {%47} $chunk {G}  chunk
   regsub -all {%48} $chunk {H}  chunk
   regsub -all {%49} $chunk {I}  chunk
   regsub -all {%4A} $chunk {J}  chunk
   regsub -all {%4B} $chunk {K}  chunk
   regsub -all {%4C} $chunk {L}  chunk
   regsub -all {%4D} $chunk {M}  chunk
   regsub -all {%4E} $chunk {N}  chunk
   regsub -all {%4F} $chunk {O}  chunk
   regsub -all {%50} $chunk {P}  chunk
   regsub -all {%51} $chunk {Q}  chunk
   regsub -all {%52} $chunk {R}  chunk
   regsub -all {%53} $chunk {S}  chunk
   regsub -all {%54} $chunk {T}  chunk
   regsub -all {%55} $chunk {U}  chunk
   regsub -all {%56} $chunk {V}  chunk
   regsub -all {%57} $chunk {W}  chunk
   regsub -all {%58} $chunk {X}  chunk
   regsub -all {%59} $chunk {Y}  chunk
   regsub -all {%5A} $chunk {Z}  chunk
   regsub -all {%5B} $chunk {[}  chunk
   regsub -all {%5C} $chunk {\\} chunk
   regsub -all {%5D} $chunk {]}  chunk
   regsub -all {%5E} $chunk {^}  chunk
   regsub -all {%5F} $chunk {_}  chunk
   regsub -all {%60} $chunk {`}  chunk
   regsub -all {%61} $chunk {a}  chunk
   regsub -all {%62} $chunk {b}  chunk
   regsub -all {%63} $chunk {c}  chunk
   regsub -all {%64} $chunk {d}  chunk
   regsub -all {%65} $chunk {e}  chunk
   regsub -all {%66} $chunk {f}  chunk
   regsub -all {%67} $chunk {g}  chunk
   regsub -all {%68} $chunk {h}  chunk
   regsub -all {%69} $chunk {i}  chunk
   regsub -all {%6A} $chunk {j}  chunk
   regsub -all {%6B} $chunk {k}  chunk
   regsub -all {%6C} $chunk {l}  chunk
   regsub -all {%6D} $chunk {m}  chunk
   regsub -all {%6E} $chunk {n}  chunk
   regsub -all {%6F} $chunk {o}  chunk
   regsub -all {%70} $chunk {p}  chunk
   regsub -all {%71} $chunk {q}  chunk
   regsub -all {%72} $chunk {r}  chunk
   regsub -all {%73} $chunk {s}  chunk
   regsub -all {%74} $chunk {t}  chunk
   regsub -all {%75} $chunk {u}  chunk
   regsub -all {%76} $chunk {v}  chunk
   regsub -all {%77} $chunk {w}  chunk
   regsub -all {%78} $chunk {x}  chunk
   regsub -all {%79} $chunk {y}  chunk
   regsub -all {%7A} $chunk {z}  chunk
   regsub -all {%7B} $chunk {\{} chunk
   regsub -all {%7C} $chunk {|}  chunk
   regsub -all {%7D} $chunk {\}} chunk
   regsub -all {%7E} $chunk {~}  chunk
   return $chunk
}

## @brief convert ascii characters into hexadecimal entities
# @param chunk chaîne a convertir
# @return chunk chaîne convertie
#
proc ::Samp::convertEntities { chunk } {
   regsub -all { }  $chunk {%20} chunk
   regsub -all {!}  $chunk {%21} chunk
   regsub -all {"}  $chunk {%22} chunk
   regsub -all {#}  $chunk {%23} chunk
   regsub -all {\$} $chunk {%24} chunk
   regsub -all {\&} $chunk {%26} chunk
   regsub -all {'}  $chunk {%27} chunk
   regsub -all {\(} $chunk {%28} chunk
   regsub -all {\)} $chunk {%29} chunk
   regsub -all {\*} $chunk {%2A} chunk
   regsub -all {\+} $chunk {%2B} chunk
   regsub -all {,}  $chunk {%2C} chunk
   regsub -all {=}  $chunk {%3D} chunk
   regsub -all {\?} $chunk {%3F} chunk
   regsub -all {@}  $chunk {%40} chunk
   regsub -all {\[} $chunk {%5B} chunk
   regsub -all {\]} $chunk {%5D} chunk
   regsub -all {\^} $chunk {%5E} chunk
   regsub -all {`}  $chunk {%60} chunk
   regsub -all {\{} $chunk {%7B} chunk
   regsub -all {\|} $chunk {%7C} chunk
   regsub -all {\}} $chunk {%7D} chunk
   regsub -all {~}  $chunk {%7E} chunk
   return $chunk
}
