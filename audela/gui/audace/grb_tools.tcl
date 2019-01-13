#
## @file grb_tools.tcl
#  @brief Outil pour les sursauts gamma
#  @author Alain KLOTZ
#  $Id: grb_tools.tcl 14209 2017-04-21 02:09:05Z alainklotz $
#  @todo compléter la documentation des procs
#

#  source "$audace(rep_install)/gui/audace/grb_tools.tcl"
#

## @defgroup grb_notice  Gamma Ray Burst
# AudeLA comporte des fonctions de Console qui permettent d'analyser les données publiées sur les sursauts gamma :
# - un tutoriel @ref tuto_sursaut_gamma
# - les fichiers @ref grb_tools.tcl et @ref world_tools.tcl
# @code
# --- Pour télécharger les GCN circulars :
# grb_gcnc update 100
# grb_gcnc id_telescope
# grb_gcnc list_telescopes
# --- Pour télécharger les GRB de Greiner
# grb_greiner update
# grb_greiner prompt_map ?
# grb_greiner redshifts
# --- Pour télécharger les GRB de Swift seul
# grb_swift update
# grb_swift prompt_map ?
# --- Pour analyser les alertes Antares
# grb_antares triggers
# grb_antares update
# grb_antares html
# --- Charger l'image localisée dans grb/promptmaps/World-Coloured.bmp
# @endcode
#

#============================================================
#  brief lecture d'une page HTML via http
#  param url url
#  param fullfile_out nom du répertoire de stockage des fichiers
#
proc grb_read_url_contents { url {fullfile_out ""} } {
   package require http
   set res ""
   set key [string first "http://" $url] 
   if {$key>=0} {
      set token [::http::geturl $url]
      upvar #0 $token state
      set res $state(body)
      set len [string length $res]
   } else {
      set key [string first "https://" $url] 
      if {$key>=0} {
         package require tls
         tls::init -tls1 true -ssl2 false -ssl3 false
         http::register https 443 tls::socket
         set token [::http::geturl $url -timeout 30000]
         set status [http::status $token]
         set res [http::data $token]
         http::cleanup $token
         http::unregister https
      }
   }
   if {$fullfile_out!=""} {
      set f [open $fullfile_out w]
      puts -nonewline $f "$res"
      close $f
   }
   return $res
}


#============================================================
## @brief télécharge les GRB de Swift seul
#  @param args liste de paramètres
#  - methode { update | prompt_map }
#
proc grb_swift { args } {
   global audace

   set methode [lindex $args 0]
   set grbpath [ file join $::audace(rep_userCatalog) grb swift]

   if {$methode=="update"} {

      file mkdir "$grbpath"
      set url0 "https://swift.gsfc.nasa.gov/archive/grb_table/tmp/"
      set lignes [grb_read_url_contents "$url0"]
      set f [open ${grbpath}/files.txt w]
      puts -nonewline $f $lignes
      close $f
      set f [open ${grbpath}/files.txt r]
      set lignes [read $f]
      close $f
      set lignes [split $lignes \n]
      set nl [llength $lignes]
      set fsizemax 0
      for {set kl 8} {$kl<$nl} {incr kl} {
         set ligne [lindex $lignes $kl]
         set keyligne [lindex $ligne 4]
         set key "href=\""
         set k [string first $key $keyligne]
         if {$k>=0} {
            set keyligne [regsub -all \" $keyligne " "]
            set fname [lindex $keyligne 1]
            set fsize [lindex $ligne 7]
            set fsize [string trim [regsub -all K $fsize "000"]]
            if {$fsize>$fsizemax} { set fsizemax $fsize }
            #::console::affiche_resultat "$fname $fsize $fsizemax\n"
         }
      }
      for {set kl 8} {$kl<$nl} {incr kl} {
         set ligne [lindex $lignes $kl]
         set keyligne [lindex $ligne 4]
         set key "href=\""
         set k [string first $key $keyligne]
         if {$k>=0} {
            set keyligne [regsub -all \" $keyligne " "]
            set fname [lindex $keyligne 1]
            set fsize [lindex $ligne 7]
            set fsize [string trim [regsub -all K $fsize "000"]]
            if {$fsize==$fsizemax} {
               ::console::affiche_resultat "$fname $fsize\n"
               break
            }
         }
      }
      set url0 "https://swift.gsfc.nasa.gov/archive/grb_table/tmp/$fname"
      set lignes [grb_read_url_contents "$url0"]
      set f [open ${grbpath}/raw.txt w]
      puts -nonewline $f $lignes
      close $f
      set f [open ${grbpath}/raw.txt r]
      set lignes [read $f]
      close $f
      set lignes [split $lignes \n]
      set nl [llength $lignes]
      set k 0
      set ligne90s ""
      catch {unset grbs}
      for {set kl 1} {$kl<$nl} {incr kl} {
         set a1 [lindex $lignes $kl]
         regsub -all "\{" $a1 ( a2
         regsub -all "\}" $a2 ) a1
         set ligne [split $a1 \t]
         set grbname [lindex $ligne 0]
         if {[catch {expr [string trimleft [string range $grbname 0 5] 0]}]==1} {
            continue
         }
         lappend grbs(name) $grbname
         set ra [lindex $ligne 3]
         lappend grbs(ra) [string trim [mc_angle2deg $ra]]
         set dec [lindex $ligne 4]
         lappend grbs(dec) [string trim [mc_angle2deg $dec 90]]
         set res [lindex $ligne 2]
         if {[catch {expr [string range $res 0 2]}]==0} {
            set res Swift
         } elseif {[string range $res 0 5]=="Ground"} {
            set res Swift
         }
         lappend grbs(satellite) $res

         set ra [lindex $ligne 23]
         set dec [lindex $ligne 24]
         set redshift -1
         set obsoptic  0
         if {($ra!="n/a")} {
            #::console::affiche_resultat "$grbname => [lindex $ligne 30]\n"
            set obsoptic 1
            set obs [split [lindex $ligne 30] |]
            set z 0
            set nz 0
            foreach ob $obs {
               set res [lindex $ob 0] ; # redshift
               #::console::affiche_resultat "$grbname res=$res z=$z\n"
               if {[catch {expr [string trimleft $res 0]}]==0} {
                  if {[string length $res]>=[string length $z]} {
                     set z $res
                  }
               }
            }
            if {$z!="0"} {
               set redshift $z
            }
         }
         #::console::affiche_resultat "$grbname <$ra> <$dec> <$obsoptic> >>>>$redshift>>>>>\n"
         lappend grbs(obsoptic) $obsoptic
         lappend grbs(redshift) $redshift

         set t90 [lindex [lindex $ligne 6] 0] ; # BAT T90 [sec]
         #console::affiche_resultat "ligne = <$ligne>\n"
         #console::affiche_resultat "t90 = <$t90>\n"
         regsub -all "~" $t90 "" a1
         regsub -all ">" $a1 "" a2
         set t90 $a2
         set fluence [lindex $ligne 7] ; # BAT Fluence (15-150 keV) [10^-7 erg/cm^2]
         #console::affiche_resultat "fluence = <$fluence>\n"
         if {[string first n/a $fluence]>=0} {
            set fluence n/a
         }
         regsub -all "~" $fluence "" a1
         regsub -all ">" $a1 "" a2
         set fluence $a2
         if {($t90!="n/a")&&($fluence!="n/a")&&($t90!="TBD")&&($fluence!="TBD")} {
            set ra [lindex $grbs(ra) end]
            set dec [lindex $grbs(dec) end]
            #console::affiche_resultat "$grbname $ra $dec $redshift $t90 $fluence\n"
            append ligne90s "[format "%9s %08.4f %+08.4f %+07.3f %8.3f %8.3e" $grbname $ra $dec $redshift $t90 $fluence]\n"
         }

         set a [string range $grbname 0 1]
         set m [string range $grbname 2 3]
         set d [string range $grbname 4 5]
         if {$a>70} {
            set a [expr 1900+[string trimleft $a 0]]
         } else {
            set a [expr 2000+[string trimleft $a 0]]
         }
         set grbtime [lindex $ligne 1]
         if {$grbtime=="n/a"} {
            set grbdateiso 1800-01-01T00:00:00.000
         } else {
            set grbdateiso [mc_date2iso8601 ${a}-${m}-${d}T${grbtime}]
         }
         lappend grbs(date) [mc_date2iso8601 ${grbdateiso}]
         #
         set name [lindex $grbs(name) $k]
         set ra [lindex $grbs(ra) $k]
         set dec [lindex $grbs(dec) $k]
         set satellite [lindex $grbs(satellite) $k]
         set date [lindex $grbs(date) $k]
         set obsoptic [lindex $grbs(obsoptic) $k]
         set redshift [lindex $grbs(redshift) $k]
         #::console::affiche_resultat "<$name><$satellite><$date> <$ra> <$dec> <$obsoptic> >>>>$redshift>>>>>\n"
         incr k

      }
      set lignes ""
      set n [llength $grbs(name)]
      for {set k 0} {$k<$n} {incr k} {
         set name [lindex $grbs(name) $k]
         set ra [lindex $grbs(ra) $k]
         set dec [lindex $grbs(dec) $k]
         set satellite [lindex $grbs(satellite) $k]
         set date [lindex $grbs(date) $k]
         set obsoptic [lindex $grbs(obsoptic) $k]
         set redshift [lindex $grbs(redshift) $k]
         set err [catch {format %f $redshift} msg]
         if {$err==1} {
            set nr [string length $redshift]
            set redshift2 ""
            for {set kr 0} {$kr<$nr} {incr kr} {
               set car [string index $redshift $kr]
               if {($car=="0")||($car=="1")||($car=="2")||($car=="3")||($car=="4")||($car=="5")||($car=="6")||($car=="7")||($car=="8")||($car=="9")||($car==".")} {
                  append redshift2 $car
               }
            }
            set redshift -1
            set err [catch {format %f $redshift2} msg]
            if {$err==1} {
               set redshift2 $redshift
            }
         } else {
            set redshift2 $redshift
         }
         set ligne [format "%9s %12s %20s %08.4f %+08.4f %1d %+07.3f %+07.3f" $name $satellite $date $ra $dec $obsoptic $redshift $redshift2]
         append lignes "${ligne}\n"
      }
      set f [open ${grbpath}/grboptic.txt w]
      puts -nonewline $f $lignes
      close $f
      ::console::affiche_resultat "GRB Swift file ${grbpath}/grboptic.txt\n"
      set f [open ${grbpath}/t90_fluence.txt w]
      puts -nonewline $f $ligne90s
      close $f
      ::console::affiche_resultat "GRB Swift file ${grbpath}/t90_fluence.txt\n"

   } elseif {$methode=="prompt_map"} {

      set err [catch {open ${grbpath}/grboptic.txt r} f]
      if {$err==1} {
         error "File ${grbpath}/grboptic.txt not found. Please use the function \"grb_greiner update\" before"
      }
      set lignes [split [read $f] \n]
      close $f
      set satellites ""
      set tsatellites ""
      set grbs ""
      set tgrbs ""
      foreach ligne $lignes {
         set grb [lindex $ligne 0]
         if {$grb==""} { continue }
         lappend grbs $grb
         append tgrbs "$grb "
         set satellite [lindex $ligne 1]
         set k [lsearch -exact $satellites $satellite]
         if {$k==-1} {
            lappend satellites $satellite
            append tsatellites "$satellite "
         }
      }

      set onesatellite [lindex $args 1]
      if {$onesatellite==""} {
         set onesatellite Swift
      } elseif {$onesatellite=="?"} {
         ::console::affiche_resultat "Available satellites are: $tsatellites.\n\nAvailable GRBs are: $tgrbs\n"
         return
      }
      set onegrb ""
      set onegrb [lindex $args 2]
      set k [lsearch -exact $satellites $onesatellite]
      if {$k==-1} {
         # - l'argument est un numero de GRB
         set onegrb $onesatellite
         set k [lsearch -exact $grbs $onegrb]
         if {$k==-1} {
            set onegrb [string range $onesatellite 3 end]
            set k [lsearch -exact $grbs $onegrb]
            if {$k==-1} {
               ::console::affiche_resultat "$onesatellite not found. Available satellites are: $tsatellites\n\nAvailable GRBs are: $tgrbs\n"
               return
            }
         }
      }

      #::console::affiche_resultat "onesatellite=$onesatellite\n"
      #::console::affiche_resultat "onegrb=$onegrb\n"
      set n 0
      set tgrbs ""
      set jdlim [mc_date2jd 1900-01-01T00:00:00]
      foreach ligne $lignes {
         set grb [lindex $ligne 0]
         set satellite [lindex $ligne 1]
         if {$onegrb!=""} {
            if {$onegrb!=$grb} {
               continue
            }
         } else {
            if {$satellite!=$onesatellite} {
               continue
            }
         }
         set jd [mc_date2jd [lindex $ligne 2]]
         if {$jd<$jdlim} {
            continue
         }
         set optic [lindex $ligne 5]
         append tgrbs "$grb "
         lappend jds $jd
         lappend ras [lindex $ligne 3]
         lappend decs [lindex $ligne 4]
         lappend equinoxs J2000
         incr n
      }
      ::console::affiche_resultat "$n GRB found: $tgrbs\n"
      if {$n==0} {
         return
      }
      set t0 [clock seconds]

      set fname "$audace(rep_images)/tmp[buf$audace(bufNo) extension]"
      set method 0
      set minobjelev 10
      set maxsunelev -10
      set minmoondist 5
      #::console::affiche_resultat "mc_lightmap $jds $ras $decs $equinoxs $fname 1 1 $method $minobjelev $maxsunelev $minmoondist\n"
      mc_lightmap $jds $ras $decs $equinoxs $fname 1 1 $method $minobjelev $maxsunelev $minmoondist
      loadima $fname

      set t [expr [clock seconds]-$t0]
      ::console::affiche_resultat "Map computed in $t seconds for $n GRBs.\n"

   } else {

      error "Error: First element must be a method amongst update, prompt_map"

   }
}

#============================================================
## @brief télécharge les GRB de Greiner
#  @param args liste des paramètres
#  - methode { update | prompt_map | redshifts }
#
proc grb_greiner { args } {
   global audace

   set methode [lindex $args 0]
   set grbpath [ file join $::audace(rep_userCatalog) grb greiner]

   if {$methode=="update"} {

      set force [lindex $args 1]
      if {$force!=""} {
         set force 1
      } else {
         set force 0
      }
      file mkdir "$grbpath"
      set url0 "http://www.mpe.mpg.de/~jcg/grbgen.html"
      set lignes [split [grb_read_url_contents "$url0"] \n]
      set nl [llength $lignes]

      set id1 "<TR VALIGN=\"TOP\"><TD NOWRAP><a href=\"grb"
      set id2 ".html\">"
      set nid2 [string length $id2]
      set id3 "</a></TD>"
      set nid3 [string length $id3]
      set id4 ">"
      set nid4 [string length $id4]
      set id5 "<SUP>"
      set nid5 [string length $id5]
      set id6 "</SUP>"
      set nid6 [string length $id6]
      set id7 "&#"
      set nid7 [string length $id7]
      set id8 "; "
      set nid8 [string length $id8]
      set id9 "'</TD>"
      set nid9 [string length $id9]
      set id10 "</TD>"
      set nid10 [string length $id10]
      set id11 "{"
      set nid11 [string length $id11]
      set id12 "}"
      set nid12 [string length $id12]
      set id13 "DOY;"
      set nid13 [string length $id13]

      catch {unset grbs}
      for {set kl 0} {$kl<$nl} {incr kl} {
         set ligne [lindex $lignes $kl]
         if {[string first $id1 $ligne]==0} {
            set k1 [expr [string first "$id2" $ligne]+$nid2]
            set k2 [expr [string last "$id3" $ligne]-1]
            set grbname [string range $ligne $k1 $k2]
            set grbname [string trim $grbname ?]
            ::console::affiche_resultat "GRBNAME=$grbname\n"
            lappend grbs(name) $grbname
            # ---
            set l [lindex $lignes [expr $kl+1]]
            set k1 [expr [string first "$id4" $l]+$nid4]
            set k2 [expr [string first "$id5" $l]-1]
            set res [string range $l $k1 $k2]
            set ra ${res}h
            #::console::affiche_resultat "h=$res\n"
            set l [string range $l [expr $k2+17] end]
            set k1 [expr [string first "$id4" $l]+$nid4]
            set k2 [expr [string first "$id5" $l]-1]
            set res [string range $l $k1 $k2]
            append ra ${res}m
            #::console::affiche_resultat "m=$res\n"
            set l [string range $l [expr $k2+17] end]
            set k1 [expr [string first "$id4" $l]+$nid4]
            set k2 [expr [string first "$id5" $l]-1]
            set res [string range $l $k1 $k2]
            append ra ${res}s
            #::console::affiche_resultat "s=$res\n"
            lappend grbs(ra) [mc_angle2deg $ra]
            # ---
            set l [lindex $lignes [expr $kl+2]]
            set k1 [expr [string first "$id6" $l]+$nid6]
            set k2 [expr [string first "$id7" $l]-1]
            set res [string range $l $k1 $k2]
            set dec ${res}d
            #::console::affiche_resultat "d=$res\n"
            set k1 [expr [string first "$id8" $l]+$nid8]
            set k2 [expr [string first "$id9" $l]-1]
            set res [string range $l $k1 $k2]
            append dec ${res}m
            #::console::affiche_resultat "m=$res\n"
            lappend grbs(dec) [mc_angle2deg $dec 90]
            # ---
            set l [lindex $lignes [expr $kl+3]]
            set k1 [expr [string first "$id4" $l]+$nid4]
            set k2 [expr [string first "$id10" $l]-1]
            set res [string range $l $k1 $k2]
            lappend grbs(error) $res
            # ---
            set l [lindex $lignes [expr $kl+4]]
            set k1 [expr [string first "$id4" $l]+$nid4]
            set k2 [expr [string first "$id10" $l]-1]
            set res [string range $l $k1 $k2]
            lappend grbs(satellite) $res
            # ---
            set l [lindex $lignes [expr $kl+7]]
            set k1 [expr [string first "$id4" $l]+$nid4]
            set k2 [expr [string first "$id10" $l]-1]
            set res [string range $l $k1 $k2]
            if {[string compare $res "y"]==0} {
               set res "1"
            } else {
               set res "0"
            }
            lappend grbs(obsoptic) $res
            # ---
            set l [lindex $lignes [expr $kl+10]]
            set k1 [expr [string first "$id4" $l]+$nid4]
            set k2 [expr [string first "$id10" $l]-1]
            set res [string range $l $k1 $k2]
            if {[string compare $res "&nbsp;"]==0} {
               set res "-1"
            }
            lappend grbs(redshift) $res
            #if {$grbname=="061007"} {
            #   dfdfgdsf
            #}
            # ---
            set grbfile [ file join $grbpath grb${grbname}.html]
            if {([file exists $grbfile]==0)||($force==1)} {
               set url1 "http://www.mpe.mpg.de/~jcg/grb${grbname}.html"
               set contents ""
               for {set k 0} {$k<10} {incr k} {
                  set err [ catch {
                     set contents [grb_read_url_contents "$url1"]
                  } msg ]
                  if {$err==0} {
                     break
                  }
               }
               set f [open $grbfile w]
               puts -nonewline $f $contents
               close $f
               set ligne2s [split $contents \n]
            } else {
               set f [open $grbfile r]
               set ligne2s [split [read $f] \n]
               close $f
               set err 0
            }
            set nl2 [llength $ligne2s]
            set grbtime ""
            set grbdate ""
            set grbdateiso 1800-01-01T00:00:00
            if {($nl2<5)||($err==1)} {
               lappend grbs(date) [mc_date2iso8601 ${grbdateiso}]
               continue;
            }
            for {set kl2 0} {$kl2<$nl2} {incr kl2} {
               set l [lindex $ligne2s $kl2]
               set res [string range $l 0 8]
               if {[string compare $res "GRB_TIME:"]==0} {
                  set k1 [expr [string first "$id11" $l]+$nid11]
                  set k2 [expr [string first "$id12" $l]-1]
                  set res [string range $l $k1 $k2]
                  set grbtime $res
               } elseif {[string compare $res "GRB_DATE:"]==0} {
                  set k1 [expr [string first "$id13" $l]+$nid13]
                  set k2 end
                  set res [string trim [string range $l $k1 $k2]]
                  set res [regsub -all / $res -]
                  set y [string range $res 0 0]
                  if {$y<7} {
                     set res 20$res
                  } else {
                     set res 19$res
                  }
                  set grbdate $res
               }
               if {([string compare $grbtime ""]!=0)&&([string compare $grbdate ""]!=0)} {
                  set grbdateiso [mc_date2iso8601 ${grbdate}T${grbtime}]
                  break;
               }
            }
            lappend grbs(date) [mc_date2iso8601 ${grbdateiso}]
         }
      }
      set lignes ""
      set n [llength $grbs(name)]
      for {set k 0} {$k<$n} {incr k} {
         set name [lindex $grbs(name) $k]
         set ra [lindex $grbs(ra) $k]
         set dec [lindex $grbs(dec) $k]
         set satellite [lindex $grbs(satellite) $k]
         set date [lindex $grbs(date) $k]
         set obsoptic [lindex $grbs(obsoptic) $k]
         set redshift [lindex $grbs(redshift) $k]
         set err [catch {format %f $redshift} msg]
         if {$err==1} {
            set nr [string length $redshift]
            set redshift2 ""
            for {set kr 0} {$kr<$nr} {incr kr} {
               set car [string index $redshift $kr]
               if {($car=="0")||($car=="1")||($car=="2")||($car=="3")||($car=="4")||($car=="5")||($car=="6")||($car=="7")||($car=="8")||($car=="9")||($car==".")} {
                  append redshift2 $car
               }
            }
            set redshift -1
            set err [catch {format %f $redshift2} msg]
            if {$err==1} {
               set redshift2 $redshift
            }
         } else {
            set redshift2 $redshift
         }
         set ligne [format "%9s %12s %20s %08.4f %+08.4f %1d %+07.3f %+07.3f" $name $satellite $date $ra $dec $obsoptic $redshift $redshift2]
         append lignes "${ligne}\n"
      }
      set f [open ${grbpath}/grboptic.txt w]
      puts -nonewline $f $lignes
      close $f
      ::console::affiche_resultat "GRB Greiner file ${grbpath}/grboptic.txt\n"

   } elseif {$methode=="prompt_map"} {

      set err [catch {open ${grbpath}/grboptic.txt r} f]
      if {$err==1} {
         error "File ${grbpath}/grboptic.txt not found. Please use the function \"grb_greiner update\" before"
      }
      set lignes [split [read $f] \n]
      close $f
      set satellites ""
      set tsatellites ""
      set grbs ""
      set tgrbs ""
      foreach ligne $lignes {
         set grb [lindex $ligne 0]
         if {$grb==""} { continue }
         lappend grbs $grb
         append tgrbs "$grb "
         set satellite [lindex $ligne 1]
         set k [lsearch -exact $satellites $satellite]
         if {$k==-1} {
            lappend satellites $satellite
            append tsatellites "$satellite "
         }
      }

      set onesatellite [lindex $args 1]
      if {$onesatellite==""} {
         set onesatellite Swift
      } elseif {$onesatellite=="?"} {
         ::console::affiche_resultat "Available satellites are: $tsatellites.\n\nAvailable GRBs are: $tgrbs\n"
         return
      }
      set onegrb ""
      set onegrb [lindex $args 2]
      set k [lsearch -exact $satellites $onesatellite]
      if {$k==-1} {
         # - l'argument est un numero de GRB
         set onegrb $onesatellite
         set k [lsearch -exact $grbs $onegrb]
         if {$k==-1} {
            set onegrb [string range $onesatellite 3 end]
            set k [lsearch -exact $grbs $onegrb]
            if {$k==-1} {
               ::console::affiche_resultat "$onesatellite not found. Available satellites are: $tsatellites\n\nAvailable GRBs are: $tgrbs\n"
               return
            }
         }
      }

      #::console::affiche_resultat "onesatellite=$onesatellite\n"
      #::console::affiche_resultat "onegrb=$onegrb\n"
      set n 0
      set tgrbs ""
      set jdlim [mc_date2jd 1900-01-01T00:00:00]
      foreach ligne $lignes {
         set grb [lindex $ligne 0]
         set satellite [lindex $ligne 1]
         if {$onegrb!=""} {
            if {$onegrb!=$grb} {
               continue
            }
         } else {
            if {$satellite!=$onesatellite} {
               continue
            }
         }
         set jd [mc_date2jd [lindex $ligne 2]]
         if {$jd<$jdlim} {
            continue
         }
         set optic [lindex $ligne 5]
         append tgrbs "$grb "
         lappend jds $jd
         lappend ras [lindex $ligne 3]
         lappend decs [lindex $ligne 4]
         lappend equinoxs J2000
         incr n
      }
      ::console::affiche_resultat "$n GRB found: $tgrbs\n"
      if {$n==0} {
         return
      }
      set t0 [clock seconds]

      set fname "$audace(rep_images)/tmp[buf$audace(bufNo) extension]"
      set method 0
      set minobjelev 10
      set maxsunelev -10
      set minmoondist 5
      #::console::affiche_resultat "mc_lightmap $jds $ras $decs $equinoxs $fname 1 1 $method $minobjelev $maxsunelev $minmoondist\n"
      mc_lightmap $jds $ras $decs $equinoxs $fname 1 1 $method $minobjelev $maxsunelev $minmoondist
      loadima $fname

      set t [expr [clock seconds]-$t0]
      ::console::affiche_resultat "Map computed in $t seconds for $n GRBs.\n"

   } elseif {$methode=="redshifts"} {

      set err [catch {open ${grbpath}/grboptic.txt r} f]
      if {$err==1} {
         error "File ${grbpath}/grboptic.txt not found. Please use the function \"grb_greiner update\" before"
      }
      set lignes [split [read $f] \n]
      close $f
      set satellites ""
      set tsatellites ""
      set grbs ""
      set tgrbs ""
      foreach ligne $lignes {
         set grb [lindex $ligne 0]
         if {$grb==""} { continue }
         lappend grbs $grb
         append tgrbs "$grb "
         set satellite [lindex $ligne 1]
         set k [lsearch -exact $satellites $satellite]
         if {$k==-1} {
            lappend satellites $satellite
            append tsatellites "$satellite "
         }
      }

      set onesatellite [lindex $args 1]
      if {$onesatellite==""} {
         set onesatellite Swift
      } elseif {$onesatellite=="?"} {
         ::console::affiche_resultat "Available satellites are: $tsatellites.\n\nAvailable GRBs are: $tgrbs\n"
         return
      }
      set onegrb ""

      #::console::affiche_resultat "onesatellite=$onesatellite\n"
      #::console::affiche_resultat "onegrb=$onegrb\n"
      set t0 [clock seconds]
      set n 0
      set tgrbs ""
      set redshifts ""
      set textes ""
      foreach ligne $lignes {
         set grb [lindex $ligne 0]
         set satellite [lindex $ligne 1]
         if {$satellite!=""} {
            if {$satellite!=$onesatellite} {
               continue
            }
         }
         set optic [lindex $ligne 5]
         set redshift [lindex $ligne 6]
         if {$redshift=="-01.000"} {
            continue
         }
         append tgrbs "$grb "
         lappend redshifts $redshift
         # --- start of analysis
         set fname "${grbpath}/grb${grb}.html"
         set err [catch {open $fname r} f]
         if {$err==1} {
            error "File $fname not found. Please use the function \"grb_greiner update\" before"
         }
         set lignes [split [read $f] \n]
         close $f
         set nl [llength $lignes]
         # --- Date: 110731A, 100418A, 100724A, 091208B, 090715B, 080604, 080603B, 080413, 080319C, 071122
         # --- Ref to previous: 100302A
         # --- autres problemes: 090423 (exposure), 090407 (pas de redshift), 081203 (photom), 080430 (photom+date), 080207 (photom), 080129 (article)
         ::console::affiche_resultat "===== GRB $grb =====\n"
         if {($grb=="080430")||($grb=="080207")||($grb=="080129")} {
            continue
         }
         for {set kl 0} {$kl<$nl} {incr kl} {
            set ligne [string tolower [lindex $lignes $kl]]
            set kkey [string first "redshift smaller" $ligne]
            if {$kkey>=0} { continue}
            set kkey [string first "redshift of the afterglow is at least" $ligne]
            if {$kkey>=0} { continue}
            set kkey [string first "redshift of less than" $ligne]
            if {$kkey>=0} { continue}
            set kkey [string first "redshift event." $ligne]
            if {$kkey>=0} { continue}
            set kkey [string first "redshift of about 6." $ligne]
            if {$kkey>=0} { continue}
            set kkey [string first "redshift greater than" $ligne]
            if {$kkey>=0} { continue}
            set kkey [string first "the redshift using spectroscopy and the relation from grupe et al" $ligne]
            if {$kkey>=0} { continue}
            set kkey [string first "the object is detected in all seven bands, implying a redshift" $ligne]
            if {$kkey>=0} { continue}
            set kkey [string first "redshift constraints using x-ray spectroscopy" $ligne]
            if {$kkey>=0} { continue}
            set kkey [string first "in addition to the redshift and 1-sigma error" $ligne]
            if {$kkey>=0} { continue}
            set kkey [string first "in the three ultraviolet filters may indicate that the redshift is" $ligne]
            if {$kkey>=0} { continue}
            set kkey [string first redshift $ligne]
            set delay 0
            if {$kkey>=0} {
               set yy [string range $grb 0 1]
               if {$yy<90} {
                  set year 20${yy}
               } else {
                  set year 19${yy}
               }
               set kl2 $kl
               set kl1 [expr $kl-250]
               set unit ""
               for {set kkl $kl2} {$kkl>=$kl1} {incr kkl -1} {
                  set ligne [string tolower [lindex $lignes $kkl]]
                  set ligne [regsub -all \[()\] $ligne ""]
                  set ligne [regsub -all \~ $ligne ""]
                  set ligne [regsub -all "h after" $ligne " hr after"]
                  set ligne [regsub -all "6s after" $ligne "6 sec after"]
                  append ligne " $unit"
                  #::console::affiche_resultat "ETAPE  5: $ligne\n"
                  set kkey [string first "<li> gcn circular" $ligne]
                  if {$kkey>=0} {
                     if {$delay>0} {
                        set ligne [regsub -all # $ligne ""]
                        set ligne [split $ligne]
                        set gcnc [lindex $ligne 3]
                        ::console::affiche_resultat "<<valid=$valid hour=$delay z=$redshift GCNC=$gcnc\n"
                        append textes "$gcnc $redshift $delay\n"
                     }
                     break
                  }
                  if {$delay>0} {
                     continue
                  }
                  set ligne [split $ligne]
                  #::console::affiche_resultat "ETAPE 10: $ligne\n"
                  set valid 0
                  set kkey [lsearch -ascii $ligne $year]
                  if {$kkey>=0} { set valid 1 ; set kkey0 $kkey ; set unit date }
                  set kkey [lsearch -ascii $ligne UT]
                  if {$kkey>=0} { set valid 2 ; set kkey0 $kkey ; set unit date }
                  set kkey [lsearch -ascii $ligne hr]
                  if {$kkey>=0} { set valid 3 ; set kkey0 $kkey ; set unit hours }
                  set kkey [lsearch -ascii $ligne hour]
                  if {$kkey>=0} { set valid 4 ; set kkey0 $kkey ; set unit hours }
                  set kkey [lsearch -ascii $ligne day]
                  if {$kkey>=0} { set valid 5 ; set kkey0 $kkey ; set unit days }
                  set kkey [lsearch -ascii $ligne mins]
                  if {$kkey>=0} { set valid 6 ; set kkey0 $kkey ; set unit minutes }
                  set kkey [lsearch -ascii $ligne hours]
                  if {$kkey>=0} { set valid 7 ; set kkey0 $kkey ; set unit hours }
                  set kkey [lsearch -ascii $ligne days]
                  if {$kkey>=0} { set valid 8 ; set kkey0 $kkey ; set unit days }
                  set kkey [lsearch -ascii $ligne minutes]
                  if {$kkey>=0} { set valid 9 ; set kkey0 $kkey ; set unit minutes }
                  set kkey [lsearch -ascii $ligne hrs]
                  if {$kkey>=0} { set valid 10 ; set kkey0 $kkey ; set unit hours }
                  set kkey [lsearch -ascii $ligne sec]
                  if {$kkey>=0} { set valid 11 ; set kkey0 $kkey ; set unit seconds }
                  set kkey [lsearch -ascii $ligne min]
                  if {$kkey>=0} { set valid 12 ; set kkey0 $kkey ; set unit minutes }
                  if {$valid>0} {
                     if {$kkey0==0} { continue }
                     set delay 0
                     set mult 1.
                     if {$unit=="hours"} {
                        set delay [string trim [lindex $ligne [expr $kkey0-1]]]
                        set delay [regsub -all : $delay "."]
                        if {$delay=="one"} { set delay 1 }
                     }
                     if {$unit=="days"} {
                        set delay [string trim [lindex $ligne [expr $kkey0-1]]]
                        set delay [regsub -all : $delay "."]
                        if {$delay=="one"} { set delay 1 }
                        set mult 24.
                     }
                     if {$unit=="minutes"} {
                        set delay [string trim [lindex $ligne [expr $kkey0-1]]]
                        set delay [regsub -all : $delay "."]
                        if {$delay=="one"} { set delay 1 }
                        set mult [expr 1./60]
                     }
                     if {$unit=="seconds"} {
                        set delay [string trim [lindex $ligne [expr $kkey0-1]]]
                        set delay [regsub -all : $delay "."]
                        if {$delay=="one"} { set delay 1 }
                        set mult [expr 1./3600]
                     }
                     ::console::affiche_resultat "<$valid ($kkey0)=$delay ($mult)> $ligne\n"
                     if {[catch {expr $delay} ]==1} {
                        set delay 0
                     }
                     set delay [expr $delay*$mult]
                     if {$delay>0} { continue }
                  }
                  set unit ""
               }
            }
            if {$delay>0} { break }
         }
         ::console::affiche_resultat "-----------\n"
         # --- end of analysis
         incr n
         if {$n>110} { break }
      }
      ::console::affiche_resultat "$n GRB found: $tgrbs\n"
      if {$n==0} {
         return
      }
      set t [expr [clock seconds]-$t0]
      set err [catch {open ${grbpath}/grbredshifts.txt w} f]
      puts -nonewline $f $textes
      close $f
      ::console::affiche_resultat "Redshift analysis computed in $t seconds for $n GRBs.\n"

   } else {

      error "Error: First element must be a method amongst update, prompt_map"

   }
}

#============================================================
## @brief télécharge les GCN circulars
#  @remark valid header since GCNC 31
#  @param args liste de paramètres
#  - methode { update | id_telescope | list_telescopes | histogram_telescopes }
#
proc grb_gcnc { args } {
   global audace

   set methode [lindex $args 0]
   set t0 [clock seconds]

   set sats {\
   {"ASM" "Beppo-SAX" 0} \
   {"BAT" "Swift-BAT" 0} \
   {"BATSE" "BATSE" 0} \
   {"BEPPO" "Beppo-SAX" 0} \
   {"CALET " "CALET-GBM" 0} \
   {"CHANDRA" "Chandra" 0} \
   {"CZTI" "CZTI" 0} \
   {"FERMI" "Fermi" 0} \
   {"FREGATE" "HETE-Fregate" 0} \
   {"GRBM" "GRBM" 0} \
   {"HERSCHEL" "Herschel" 0} \
   {"HETE" "HETE" 0} \
   {"IBAS" "Integral-IBAS" 0} \
   {"INTEGRAL" "Integral" 0} \
   {"IPN" "IPN" 0} \
   {"KONUS" "KONUS-Wind" 0} \
   {"KONUS-WIND" "KONUS-Wind" 0} \
   {"LOMONOSOV" "Lomonosov" 0} \
   {"MAXI" "MAXI-GSC" 0} \
   {"NFI" "Beppo-SAX" 0} \
   {"POLAR" "POLAR" 0} \
   {"ROSAT" "ROSAT" 0} \
   {"SAX" "Beppo-SAX" 0} \
   {"SPITZER" "Spitzer" 0} \
   {"SuperAGILE" "AGILE" 0} \
   {"SUZAKU" "Suzaku" 0} \
   {"SWIFT" "Swift" 0} \
   {"TEST " "" 0} \
   {"WAM" "Suzaku-WAM" 0} \
   {"WIND" "KONUS-Wind" 0} \
   {"XMM" "XMM-Newton" 0} \
   {"XRT" "Swift-XRT" 0} \
   {"XRTE" "XRTE" 0} \
   }

   set miscs {\
   {"AMI" "AMI" -1} \
   {"APEX" "APEX" -1} \
   {"ATCA" "ATCA" -1} \
   {"CARMA" "CARMA" -1} \
   {"CORRECTION" "" -1} \
   {"EVLA" "VLA" -1} \
   {"IRAM" "IRAM" -1} \
   {"GMRT" "GMRT" -1} \
   {"JCMT" "JCMT" -1} \
   {"LOFAR" "LOFAR" -1} \
   {"MAMBO" "MAMBO" -1} \
   {"MILAGRO" "MILAGRO" -1} \
   {"RHESSI" "RHESSI" -1} \
   {"SDSS" "SDSS" -1} \
   {"SMA" "SMA" -1} \
   {"VLA" "VLA" -1} \
   {"WSRT" "WSRT" -1} \
   }

   set tels {\
   {"AAO " "AAO_AS-32" 70} \
   {"ABAO " "AAO_AS-32" 70} \
   {"ANU " "ANU_2.3m" 230} \
   {"APO " "ARC_3.5m" 350} \
   {" ARC " "ARC_3.5m" 350 } \
   {"AROMA" "AROMA" 30} \
   {"AROMA-N " "AROMA" 30} \
   {"AROMA-S " "AROMA" 30} \
   {"ART-" "ART-3" 35} \
   {"AZT-33IK" "AZT-33IK" 150} \
   {"BART " "BART" 25.4} \
   {"BOAO " "BOAO" 180} \
   {"BOOTES" "BOOTES*" 30} \
   {"BOOTES1A" "BOOTES1A" 5} \
   {"BOOTES1B" "BOOTES1B" 30} \
   {"BOOTES2" "BOOTES2" 30} \
   {"BOOTES3" "BOOTES3" 60} \
   {"BOOTES-3" "BOOTES3" 60} \
   {" BTA " "BTA" 600} \
   {"CASSINI" "CASSINI" 152} \
   {"CAHA" "CAHA-1.23m" 123} \
   {"CFHT" "CFHT" 360} \
   {"CHUGUEV" "Chuguev" 70} \
   {"CONCAM" "CONCAM" 0.16} \
   {"CQUEAN" "McDonald-2.1m" 210} \
   {"CRAO" "Shajn" 260} \
   {"CRNI VRH" "PIKA" 60} \
   {"D50" "D50" 50} \
   {"DANISH" "ESO/Danish" 154} \
   {"DANISH/DFOSC" "ESO/Danish" 154} \
   {"DFOSC" "ESO/Danish" 154} \
   {" EST " "EST" 80} \
   {"Etelman" "VIRT" 50} \
   {"FAULKES" "FT*" 200} \
   {"FRAM " "FRAM" 20} \
   {"FTN" "FTN" 200} \
   {"FTS" "FTS" 200} \
   {"GAO" "GAO" 150} \
   {"GEMINI" "Gemini-*" 810} \
   {"GETS " "GETS" 25} \
   {"GMOS" "Gemini-*" 810} \
   {"GMG" "GMG_240" 240} \
   {"GORT " "GORT" 35} \
   {"GROND" "GROND" 220} \
   {"GTC" "GTC" 1040} \
   {"HCT " "HCT" 1040} \
   {"HST " "HST" 240} \
   {"IAC " "IAC-80" 80} \
   {"IAC80" "IAC-80" 80} \
   {" INT " "INT" 250} \
   {"IPTF" "P60" 150} \
   {"ISAS " "ISAS" 130} \
   {"IRSF " "IRSF" 140} \
   {"ISON-NM" "ISON-NM" 45} \
   {"ISON/Terskol" "ISON-80cm" 80} \
   {"ITELESCOPE " "iTelescope-*" 43} \
   {"K-380" "K-380" 380} \
   {"KAIT" "KAIT" 76} \
   {"KANAZAWA" "Kanazawa" 30} \
   {"KANATA" "Kanata" 150} \
   {"KECK" "Keck" 1000} \
   {"KHURELTOGOT" "Khureltogot" 40} \
   {"KISO" "Kiso" 105} \
   {"KONKOLY" "Konkoly" 90} \
   {"KOTTAMIA" "KAO-1.88m" 188} \
   {"LCO FTN" "FT*" 200} \
   {"LCO-FT" "FT*" 200} \
   {"LCO " "LCOGT*" 100} \
   {"LCOGT" "LCOGT*" 100} \
   {"LICK OBSERV" "Lick_Shane" 300} \
   {"LICK 3m" "Lick_Shane" 300} \
   {"LIVERPOOL" "Liverpool" 200} \
   {" LT " "Liverpool" 200} \
   {"LNA" "LNA_60" 60} \
   {"LOAO" "LOAO" 100} \
   {" LOT " "LOT" 100} \
   {"LOTIS" "*LOTIS" 60} \
   {"LULIN" "LOT" 100} \
   {"MAGELLAN" "Magellan" 650} \
   {"MAGIC" "Magellan" 650} \
   {"MAIDANAK" "Maidanak" 150} \
   {"MAISONCELLES" "Maisoncelles" 30} \
   {"MARGE" "MARGE_AEOS" 367} \
   {"MASCOT" "MASCOT" 0.16} \
   {"MASTER" "MASTER" 40} \
   {"MASTGlobal" "MASTER" 40} \   
   {"MDM" "MDM_*" 130} \
   {"MIKE " "Gemini-*" 810} \
   {"MINITAO" "MiniTAO" 100} \
   {"MIRO" "MIRO" 120} \
   {"MITSUME" "MITSuME" 50} \
   {"MIYAZAKI" "Miyazaki" 30} \
   {"MMT" "MMT" 650} \
   {"MONDY" "SAYAN-1.5m" 150} \
   {" MOA " "MOA_61" 61} \
   {"MOSFIRE" "Keck" 1000} \
   {"NANSHAN" "Nanshan" 100} \
   {"NAYUTA" "NAYUTA" 200} \
   {"NORDIC" "NOT" 256} \
   {"NTT" "NTT" 358} \
   {"OHP" "OHP" 80} \
   {"OPTIMA" "OPTIMA" 130} \
   {" OSN " "OSN_150" 150} \
   {"PAIRITEL" "PAIRITEL" 130} \
   {"P200" "P200" 510} \
   {"P60" "P60" 150} \
   {"PIKA" "PIKA" 60} \
   {"PI OF THE SKY" "PI-OF-THE-SKY" 8.5} \
   {"PI-OF-THE-SKY" "PI-OF-THE-SKY" 8.5} \
   {"RAPTOR" "RAPTOR" 40} \
   {"RATIR" "RATIR" 150} \
   {"R-COP" "R-COP" 35} \
   {" REM " "REM" 60} \
   {"ROTSE" "ROTSE" 45} \
   {"RTT150" "RTT150" 150} \
   {"SALT" "SALT" 920} \
   {"SAO RAS" "SAO-1m" 102} \
   {" SARA " "SARA" 90} \
   {"SHAJN" "Shajn" 260} \
   {"SHANE " "Lick_Shane" 300} \
   {"SMARTS" "SMARTS_130" 130} \
   {" SOAR " "SOAR" 410} \
   {"SQUEAN" "McDonald-2.1m" 210} \
   {" SSO " "SSO_1m" 100} \
   {"SUBARU" "Subaru" 820} \
   {"SKYNET/PROMPT " "PROMPT" 41} \
   {"T100" "Tubitak_T100" 100} \
   {"TAROT" "TAROT" 25} \
   {"TAUTENBURG" "Tautenburg" 134} \
   {"TERSKOL" "Terskol_200" 200} \
   {" THO " "THO" 35} \
   {"TNG" "TNG" 358} \
   {"TNT" "TNT" 80} \
   {"TORTORA" "TORTORA" 12} \
   {"TSHAO" "TSHAO-1m" 100} \
   {"TTT" "TTT" 37} \
   {"UKIRT" "UKIRT" 380} \
   {"UVOT" "Swift-UVOT" 30} \
   {"VATICAN" "VATT" 180} \
   {" VATT " "VATT" 180} \
   {"VERY LARGE TELESCOPE" "VLT" 820} \
   {"VLT" "VLT" 820} \
   {"WATCHER" "Watcher" 40} \
   {"WEIHAI" "Weihai" 100} \
   {"WHT" "WHT" 420} \
   {"WIDGET" "WIDGET" 5} \
   {"WIYN" "WIYN" 350} \
   {"XINGLONG" "TNT" 80} \
   {"XINGLONG 2.16M" "Xinglong-216cm" 216} \
   {"X-shooter " "VLT" 820} \
   {"ZADKO" "Zadko" 100} \
   }

   set sat0s ""
   set sat1s ""
   set sat2s ""
   foreach sat $sats {
      lappend sat0s [lindex $sat 0]
      lappend sat1s [lindex $sat 1]
      lappend sat2s [lindex $sat 2]
   }
   set misc0s ""
   set misc1s ""
   set misc2s ""
   foreach misc $miscs {
      lappend misc0s [lindex $misc 0]
      lappend misc1s [lindex $misc 1]
      lappend misc2s [lindex $misc 2]
   }
   set tel0s ""
   set tel1s ""
   set tel2s ""
   foreach tel $tels {
      lappend tel0s [lindex $tel 0]
      lappend tel1s [lindex $tel 1]
      lappend tel2s [lindex $tel 2] ; # diameter
   }

   if {$methode=="update"} {

      set gcncpath [ file join $::audace(rep_userCatalog) grb gcnc]
      file mkdir "$gcncpath"
      # --- rechercher l'indice du plus grand GCNC deja telecharge
      set gcncfolders [lsort [ glob -nocomplain [ file join $gcncpath * ] ]]
      set gcncdeb 0
      set gcncfolder [lindex $gcncfolders end]
      if {$gcncfolder!=""} {
         set gcncfiles [lsort [ glob -nocomplain [ file join $gcncfolder *.gcn3 ] ]]
         set gcncfile [lindex $gcncfiles end]
         if {$gcncfile!=""} {
            set gcncdeb [string trimleft [file rootname [file tail $gcncfile]] 0]
         }
      }
      ::console::affiche_resultat "GCN circulars ever downloaded until $gcncdeb\n"
      incr gcncdeb
      if {[llength $args]>1} {
         set nc [lindex $args 1]
         set gcncfin [expr $gcncdeb+$nc]
         ::console::affiche_resultat "Download GCN circulars from $gcncdeb to $gcncfin\n"
      } else {
         set nc 0
         ::console::affiche_resultat "Download GCN circulars from $gcncdeb\n"
      }
      # --- download GCN circulars
      set url0 "https://gcn.gsfc.nasa.gov/gcn3"
      set sortie 0
      set kl $gcncdeb
      set superfound 0
      while {$sortie==0} {
         set kll [format %03d ${kl}]
         set url1 "${url0}/${kll}.gcn3"
         set found 0
         for {set k 0} {$k<5} {incr k} {
            set err [ catch {
               set texte [grb_read_url_contents "$url1"]
            } msg ]
            #console::affiche_resultat "<<<< $url1 >>>>\n$texte\n---------------\n"
            set t [expr [clock seconds]-$t0]
            if {$err==0} {
               set msg2 [string first "<title>404 Not Found</title>" $texte]
               # --- Test if the (kl) GCNC exists and is not a 404
               if {$msg2==-1} {
                  set found 1
                  break
               }
            }
         }
         incr superfound
         if {$found==0} {
            ::console::affiche_resultat "$t sec.: GCNC $url1 retry $k times\n"
            incr kl
            if {$superfound<50} {
               ::console::affiche_resultat "$t sec.: GCNC $url1 was not edited. Skip it.\n"
               continue
            } else {
               ::console::affiche_resultat "$t sec.: GCNC $url1 not found. Exit update.\n"
               break
            }
         }
         set superfound 0
         set gcncfolder [ file join $gcncpath gcnc[format %04d [expr $kl/100]]]
         file mkdir "$gcncfolder"
         set f [open "${gcncfolder}/${kll}.gcn3" w]
         puts -nonewline $f "$texte"
         close $f
         ::console::affiche_resultat "$t sec.: GCNC $url1 downloaded\n"
         if {$nc>0} {
            if {$kl>=$gcncfin} {
               break
            }
         }
         incr kl
      }

   } elseif {$methode=="id_telescope"} {

      set gcncpath [ file join $::audace(rep_userCatalog) grb gcnc]
      file mkdir "$gcncpath"
      # --- rechercher l'indice du plus grand GCNC deja telecharge
      set gcncfolders [lsort [ glob -nocomplain [ file join $gcncpath * ] ]]
      set gcncfin 0
      set gcncfolder [lindex $gcncfolders end]
      if {$gcncfolder!=""} {
         set gcncfiles [lsort [ glob -nocomplain [ file join $gcncfolder *.gcn3 ] ]]
         set gcncfile [lindex $gcncfiles end]
         if {$gcncfile!=""} {
            set gcncfin [string trimleft [file rootname [file tail $gcncfile]] 0]
         }
      }
      ::console::affiche_resultat "GCN circulars ever downloaded until $gcncfin\n"
      set gcncdeb 1
      #set gcncdeb 10307
      #set gcncfin 12100
      #
      set textes ""
      for {set kl $gcncdeb} {$kl<=$gcncfin} {incr kl} {
         set kll [format %03d ${kl}]
         set gcncfolder [ file join $gcncpath gcnc[format %04d [expr $kl/100]]]
         file mkdir "$gcncfolder"
         if {[file exists "${gcncfolder}/${kll}.gcn3"]==0} {
            continue
         }
         set f [open "${gcncfolder}/${kll}.gcn3" r]
         set lignes [split [read $f] \n]
         close $f
         set texte "GCNC [format %5d $kl] : "
         set kk 0
         set subject nonpassed
         foreach ligne $lignes {
            set ligne [regsub -all \" "$ligne" " "]
            set ligne [regsub -all \{ "$ligne" " "]
            set ligne [regsub -all \} "$ligne" " "]
            set ligne [regsub -all / "$ligne" " "]
            set ligne [regsub -all , "$ligne" " "]
            set ligneup [string toupper $ligne]
            set keyword [lindex $ligneup 0]
            if {($keyword=="SUBJECT:")} {
               set ligne2 [regsub -all : "$ligne" " "]
               set ligneup2 [string toupper $ligne2]
               set k [string first "GRB" $ligneup2]
               set grb ------
               if {$k>=0} {
                  set k1 [expr $k+3]
                  set l [string range $ligneup2 $k1 end]
                  set k [string first " " $l 3]
                  if {$k==-1} {
                     set k 1
                  }
                  set grb [string trim [string range $l 0 [expr $k-1]]]
               }
               append texte "$grb : "
            }
            if {($keyword=="SUBJECT:")||($subject=="passed")} {
               set ls $sat0s
               set ls1 $sat1s
               set k1 -1 ; foreach l $ls { incr k1 ; set k [string first " $l " $ligneup]; if {$k>=0} { incr kk ; append texte "[lindex $ls1 $k1] : " } }
               set ls $misc0s
               set ls1 $misc1s
               set k1 -1 ; foreach l $ls { incr k1 ; set k [string first " $l " $ligneup]; if {$k>=0} { incr kk ; append texte "[lindex $ls1 $k1] : " } }
               set ls { PROMPT }
               set ls1 $ls
               set k1 -1 ; foreach l $ls { incr k1 ; set k [string first "$l" $ligne]; if {$k>=0} { incr kk ; append texte "[lindex $ls1 $k1] : " } }
               if {$k<0} {
                  set ls $tel0s
                  set ls1 $tel1s
                  #::console::affiche_resultat "ligneup=$ligneup\n"
                  set k1 -1 ; foreach l $ls { incr k1 ; set k [string first "$l" $ligneup]; if {$k>=0} { incr kk ; append texte "[lindex $ls1 $k1] : " } }
                  #::console::affiche_resultat "texte=$texte\n"
               } else {
                  #::console::affiche_resultat "texte=$texte\n"
               }
            }
            if {($keyword=="SUBJECT:")&&($kk>0)} {
               break
            }
            if {($keyword=="SUBJECT:")&&($kk==0)} {
               #append texte "<$ligne>"
            }
            if {($keyword=="SUBJECT:")} {
               set subject "passed"
            }
            #::console::affiche_resultat " ligne=$ligne\n"
         }
         append texte "\n"
         #::console::affiche_resultat "$kl / $gcncfin : $texte"
         append textes "$texte"
      }
      set f [open "${gcncpath}/../gcncs.txt" w]
      puts -nonewline $f "$textes"
      close $f

   } elseif {$methode=="list_telescopes"} {

      lappend tels {" PROMPT " "PROMPT" 41}
      set gcncpath [ file join $::audace(rep_userCatalog) grb gcnc]
      file mkdir "$gcncpath"
      #
      set textes ""
      catch {unset obss}
      #
      set f [open "${gcncpath}/../gcncs.txt" r]
      set lignes [split [read $f] \n]
      close $f
      #set lignes [lrange $lignes 1 2865]
      foreach ligne $lignes {
         set gcnc [lindex $ligne 1]
         set k1 [string first : $ligne]
         set k2 [string first : $ligne [expr $k1+1]]
         if {($k1==-1)||($k2==-1)} {
            continue
         }
         set grb [string range $ligne [expr $k1+1] [expr $k2-1]]
         set grb [regsub -all \[()\] "$grb" " "]
         set grb [string trim [lindex $grb 0]]
         set valid1 0
         set valid2 0
         if {[string length $grb]>=6} { set valid1 1 }
         if {[string index $grb 0]=="9"} { set valid2 1 }
         if {[string index $grb 0]=="0"} { set valid2 1 }
         if {[string index $grb 0]=="1"} { set valid2 1 }
         if {($valid1==0)||($valid2==0)} {
            set grb ------
         }
         set k3 $k2
         set k4 [string first : $ligne [expr $k3+1]]
         if {($k3==-1)||($k4==-1)} {
            continue
         }
         set obs [string trim [string range $ligne [expr $k3+1] [expr $k4-1]]]
         lappend obss($obs) [list $gcnc $grb]
      }
      set names [array names obss]
      set ordres ""
      set k 0
      foreach name $names {
         set n [llength $obss($name)]
         #::console::affiche_resultat "name=$name $n $k\n"
         lappend ordres [list $n $k]
         incr k
      }
      set ordres [lsort -index 0 -real -decreasing $ordres]
      set nn [llength $names]
      for {set kk 0} {$kk<$nn} {incr kk} {
         set kkk [lindex [lindex $ordres $kk] 1]
         set name [lindex $names $kkk]
         set kn [lsearch -exact $sat1s $name]
         set ls $sat2s
         if {$kn<0} {
            set kn [lsearch -exact $misc1s $name]
            set ls $misc2s
            if {$kn<0} {
               set kn [lsearch -exact $tel1s $name]
               set ls $tel2s
            }
         }
         if {$kn>=0} {
            set diameter [lindex $ls $kn]
         } else {
            set diameter 0
         }
         set texte "[format %15s $name] : "
         set n [llength $obss($name)]
         append texte "[format %4d $n] : "
         append texte "[format %6.1f $diameter] : "
         set telname [regsub -all \[*/\] "$name" "_"]
         set fichier ${gcncpath}/../tel_${telname}.txt
         if {[file exists $fichier]==1} {
            file delete $fichier
         }
         for {set k 0} {$k<$n} {incr k} {
            set res [lindex $obss($name) $k]
            set gcnc [lindex $res 0]
            set grb  [lindex $res 1]
            append texte "GCNC$gcnc GRB$grb : "
            #
            set kll [format %03d ${gcnc}]
            set gcncfolder [ file join $gcncpath gcnc[format %04d [expr $gcnc/100]]]
            set f [open "${gcncfolder}/${kll}.gcn3" r]
            set textegcnc [read $f]
            close $f
            set f [open "${gcncpath}/../tel_${telname}.txt" a]
            puts -nonewline $f "$textegcnc"
            close $f
         }
         append textes "$texte\n"
      }
      set f [open "${gcncpath}/../observatories.txt" w]
      puts -nonewline $f "$textes"
      close $f
      set f [open "${gcncpath}/../observatories.txt" r]
      set lignes [split [read $f] \n]
      close $f
      set textes ""
      foreach ligne $lignes {
         set k1 0
         set k2 [string first : $ligne $k1]
         set telname [string range $ligne $k1 $k2]
         set k1 [expr $k2+1]
         set k2 [string first : $ligne $k1]
         set telno [string range $ligne $k1 $k2]
         set k1 [expr $k2+1]
         set k2 [string first : $ligne $k1]
         set diam [string range $ligne $k1 $k2]
         set k1 [expr $k2+1]
         set k2 [string first : $ligne $k1]
         set telgcn1 [string range $ligne $k1 $k2]
         set k1 [string last GCNC $ligne]
         set telgcn2 [string range $ligne $k1 end]
         set texte "${telname}${telno}${diam}${telgcn1} ${telgcn2}"
         append textes "$texte\n"
      }
      set f [open "${gcncpath}/../observatories_short.txt" w]
      puts -nonewline $f "$textes"
      close $f

   } elseif {$methode=="histogram_telescopes"} {

      set ymin 1998
      set ymax [lindex [mc_date2ymdhms now] 0]
      set gcncpath [ file join $::audace(rep_userCatalog) grb gcnc]
      file mkdir "$gcncpath"
      #
      set textes ""
      catch {unset obss}
      #
      set f [open "${gcncpath}/../observatories.txt" r]
      set lignes [split [read $f] \n]
      close $f
      #
      set histo "[format %20s {Observatories}] Diam "
      for {set y $ymin} {$y<=$ymax} {incr y} {
         append histo "[format %4d $y] "
      }
      append histo "\n"
      #
      foreach ligne $lignes {
         set tel_name [lindex $ligne 0]
         set tel_nb_gcnc [lindex $ligne 2]
         if {$tel_nb_gcnc<=20} {
            continue
         }
         set tel_diam [lindex $ligne 4]
         if {$tel_diam==":"} {
            continue
         }
         if {$tel_diam<=0} {
            #continue
         }
         set yys ""
         set ligne [lrange $ligne 6 end]
         set sortie 0
         while {$sortie==0} {
            set k [string first GRB $ligne]
            if {$k==-1} {
               break
            }
            set yy [string range $ligne [expr $k+3] [expr $k+4]]
            if {[string is digit $yy]==1} {
               lappend yys $yy
            }
            set ligne [string range $ligne [expr $k+5] end]
         }
         set yys [lsort -increasing $yys]
         catch {unset hist}
         foreach yy $yys {
            if {[info exists hist($yy)]==0} {
               set hist($yy) 1
            } else {
               incr hist($yy)
            }
         }
         append histo "[format %20s $tel_name] [format %4.0f $tel_diam] "
         for {set y $ymin} {$y<=$ymax} {incr y} {
            set y0 [string range $y 2 3]
            if {[info exists hist($y0)]==0} {
               set h 0
            } else {
               set h $hist($y0)
            }
            append histo "[format %4d $h] "
         }
         append histo "\n"
      }
      set f [open "${gcncpath}/../observatories_histogram.txt" w]
      puts -nonewline $f "$histo"
      close $f

   } else {

      ::console::affiche_resultat "Error: First element must be a method amongst update, id_telescope, list_telescopes histogram_telescopes\n"

   }

}

#============================================================
## @brief analyse les alertes Antares
#  @pre please copy your input file in "$::audace(rep_userCatalog)/grb/antares"
#  @param args liste de paramètres
#  - methode { triggers | update | html }
#
proc grb_antares { args } {
   global audace

   set methode [lindex $args 0]
   set t0 [clock seconds]

   if {$methode=="triggers"} {

      set lignes ""
      append lignes "RunNumber NFrame	TS	        Ra	Decli	\n"
      append lignes "38474	33754	2009-01-13 12:02:05.0	274.324	14.3594	\n"
      append lignes "38526	30951	2009-01-16 11:15:53.0	239.189	-58.2088\n"
      append lignes "38582	54179	2009-01-19 06:55:12.0	123.919	-50.3933\n"
      append lignes "41560	109757	2009-06-27 15:51:26.0	21.1833	-53.0185\n"
      append lignes "43234	133523	2009-09-18 09:50:06.0	308.665	-2.0513	\n"
      append lignes "43678	120394	2009-10-07 00:38:49.0	214.352	-18.6701\n"
      append lignes "43745	99263	2009-10-10 16:14:57.0	294.96	-50.4331\n"
      append lignes "43748	69944	2009-10-10 20:25:30.0	296.979	-57.244	\n"
      append lignes "44025	16457	2009-10-23 02:59:00.0	276.227	11.3079	\n"
      append lignes "44035	95955	2009-10-23 18:23:21.0	218.425	-65.8129\n"
      append lignes "44338	43054	2009-11-06 19:53:20.0	177.661	-68.1464\n"
      append lignes "44383	12575	2009-11-09 04:19:59.0	14.966	-34.7708\n"
      append lignes "44385	21010	2009-11-09 08:45:32.0	35.14	-75.126	\n"
      append lignes "45006	100989	2009-12-08 17:37:44.0	320.99	-6.4918	\n"
      append lignes "45169	108135	2009-12-14 19:35:58.0	314.227	-6.5202	\n"
      append lignes "45668	10694	2010-01-07 15:52:42.0	176.53	-21.69	\n"
      append lignes "45860	24054	2010-01-16 23:42:17.0	249.69	-4.82	\n"
      append lignes "46001	16331	2010-01-22 17:20:21.0	186.27	-5.71	\n"
      append lignes "46014	3766	2010-01-23 07:16:45.0	73.07	-2.99	\n"
      append lignes "46959	53194	2010-03-02 03:51:06.0	152.77	-28.17	\n"
      append lignes "49901	9656	2010-07-06 17:22:30.0	81.4813	15.2799	\n"
      append lignes "51967	5265	2010-09-13 21:55:25.0	165.142	41.3913	\n"
      append lignes "52119	15718	2010-09-22 11:24:23.0	43.5778	13.4577	\n"
      append lignes "53749	68550	2010-12-11 08:12:21.0	320.423	-50.9129\n"
      append lignes "55010	35971	2011-02-02 01:51:34.0	258.68	-34.7687\n"
      append lignes "55728	13625	2011-03-05 12:57:20.0	295.517	-48.1927\n"
      append lignes "55839	27448	2011-03-08 21:52:39.0	288.935	-20.2131\n"
      append lignes "55894	106093	2011-03-11 01:47:38.0	3.0568	23.6749	\n"
      append lignes "56125	76786	2011-03-22 00:48:04.0	346.754	-15.3361\n"
      append lignes "56264	35634	2011-03-24 00:50:54.0	318.491	-0.933	\n"
      append lignes "57551	83895	2011-05-21 04:56:15.0	180.124	-13.1555\n"
      append lignes "57106	22791	2011-04-28 14:09:39.0	314.595	-42.6364\n"
      append lignes "56711	40866	2011-04-09 04:47:50.0	129.365	-40.2075\n"
      append lignes "57705	37939	2011-05-29 00:29:02.0	110.872	-26.7783\n"
      append lignes "57797	32762	2011-05-31 21:45:16.0	326.944	-8.7954	\n"
      append lignes "58022	84457	2011-06-13 06:22:40.0	179.638	-59.0521\n"
      append lignes "58078	392	2011-06-15 15:54:46.0	290.247	-12.3458\n"
      append lignes "58638	43202	2011-07-13 22:16:04.0	260.765	-47.4991\n"
      append lignes "59876	94926	2011-09-23 08:26:33.0	285.194	10.2438	\n"
      append lignes "50530	122387	2010-07-25 01:16:40.0	257.224	-63.1883\n"
      append lignes "53674	59222	2010-12-07 08:27:46.0	290.237	13.9424	\n"
      append lignes "54210	51350	2010-12-29 23:55:53.0	302.187	-31.0058\n"
      append lignes "59912	7597	2011-09-25 11:38:17.0	50.3852	-52.8936\n"
      append lignes "59918	531	2011-09-25 20:27:38.0	70.9977	15.5066	\n"
      append lignes "60164	14627	2011-10-08 10:45:40.0	248.17	-25.8336\n"
      append lignes "60193	1057	2011-10-10 03:43:34.0	124.983	-45.1254\n"
      append lignes "60380	17976	2011-10-19 08:56:15.0	321.165	-0.6916	\n"
      append lignes "60686	5714	2011-11-01 12:30:52.0	345.917	-5.6983	\n"
      append lignes "60715	2173	2011-11-02 22:06:45.0	83.0485	-40.9647\n"
      append lignes "60736	1915	2011-11-03 21:40:35.0	155.939	-30.6284\n"
      append lignes "60761	16000	2011-11-05 03:40:31.0	136.004	-45.1404\n"
      append lignes "61023	10375	2011-11-17 13:13:04.0	238.136	-57.2048\n"
      append lignes "61173	82082	2011-11-24 16:13:52.0	102.041	-51.7955\n"
      append lignes "61375	48896	2011-12-05 21:33:11.0	146.411	-32.8298\n"
      append lignes "61431	9421	2011-12-08 15:15:42.0	187.385	12.6291\n"
      append lignes "61544	16256	2011-12-13 17:37:09.0	124.723	14.2998\n"
      append lignes "61835	44003	2011-12-28 09:18:42.0	27.0252	32.3234\n"
      append lignes "61864	11640	2011-12-29 18:54:59.0	191.31	-0.7204\n"
      append lignes "61924	78463	2012-01-02 01:24:21.0	72.1298	-59.7099\n"
      append lignes "61997	36706	2012-01-05 18:02:53.0	228.824	-26.1214\n"
      append lignes "63367	56423	2012-03-19 21:51:39.0	353.778	5.203	\n"
      append lignes "62657	88204	2012-02-10 08:48:15.0	42.711	-28.22	\n"
      append lignes "65719	53149	2012-07-26 02:01:33.0	105.984	21.499	\n"
      append lignes "65811	20990	2012-07-30 00:14:33.0	178.088	-40.096	\n"
      append lignes "66548	84783	2012-09-07 01:25:10.0	220.17	-11.595	\n"
      append lignes "66555	38609	2012-09-07 10:12:41.0	344.75	30.933	\n"
      append lignes "66853	102831	2012-09-23 10:00:16.0	318.596	-51.071	\n"
      append lignes "67213	65554	2012-10-10 06:31:01.0	52.841	-29.216	\n"
      append lignes "67215	4376	2012-10-10 07:05:47.0	248.801	14.102	\n"
      append lignes "67252	69808	2012-10-12 04:42:49.0	239.512	-10.226	\n"
      append lignes "67348	57225	2012-10-16 13:48:12.0	17.579	1.452	\n"
      append lignes "67566	23876	2012-10-27 18:47:58.0	105.552	-4.01	\n"
      append lignes "67575	9293	2012-10-28 06:11:38.0	248.708	-58.727	\n"
      append lignes "67661	30393	2012-11-02 17:02:09.0	355.916	-67.103	\n"
      append lignes "67703	91244	2012-11-05 09:32:24.0	315.027	-18.31	\n"
      append lignes "67873	7960	2012-11-14 02:25:07.0	261.01	-29.074	\n"
      append lignes "68239	5538	2012-12-06 10:02:42.0	62.001	2.434	\n"
      append lignes "68354	51258	2012-12-12 01:13:10.0	206.703	-36.688	\n"
      append lignes "68368	18928	2012-12-12 20:33:51.0	203.237	24.885	\n"
      append lignes "68640	113447	2012-12-28 18:18:11.0	191.467	3.019	\n"
      append lignes "68883	33383	2013-01-12 18:31:00.0	139.323	-33.102	\n"
      append lignes "69154	34323	2013-01-28 16:49:09.0	314.545	-21.024	\n"
      append lignes "69338	88910	2013-02-08 10:10:31.0	197.275	-38.475	\n"
      append lignes "69344	39014	2013-02-08 18:08:31.0	204.165	-17.474	\n"
      append lignes "69375	78931	2013-02-10 14:00:10.0	185.433	5.897	\n"
      append lignes "70595	221736	2013-04-30 21:20:11.0	283.429	-57.196	\n"
      append lignes "71889	369184	2013-07-22 20:38:24.0	74.57	3.411	\n"
      append lignes "71908	353279	2013-07-24 02:07:20.0	199.295	11.938	\n"
      append lignes "72127	155958	2013-08-07 02:25:45.0	215.477	-19.972	\n"
      append lignes "72696	113956	2013-09-15 06:24:58.0	311.314	-51.603	\n"
      append lignes "72747	89879	2013-09-18 22:21:41.0	21.622	-51.57	\n"
      append lignes "72867	145860	2013-09-27 18:22:56.0	106.948	-68.578	\n"
      append lignes "72882	40936	2013-09-28 20:03:18.0	121.865	-3.156	\n"
      append lignes "73058	135465	2013-10-09 17:31:34.0	104.522	-43.748	\n"
      append lignes "73079	198770	2013-10-11 01:37:39.0	183.902	19.012	\n"
      append lignes "73345	80643	2013-10-27 12:13:35.0	105.124	6.422	\n"
      append lignes "73420	34675	2013-10-31 20:02:10.0	192.134	-11.166	\n"
      append lignes "73443	161011	2013-11-02 15:57:27.0	8.607	-16.705	\n"
      append lignes "73522	301733	2013-11-08 20:16:00.0	244.632	-11.55	\n"
      append lignes "73727	8866	2013-11-21 14:58:28.0	53.495	-35.105	\n"
      append lignes "73912 168540    2013-12-02 19:25:41.0   188.9810  0.0930\n"
      append lignes "74012 64765     2013-12-09 01:56:24.0   197.2350 -13.3450 \n"
      append lignes "74194 201146    2013-12-21 08:43:36.0   138.0150 -23.9300\n"
      append lignes "74307 51252     2013-12-28 18:46:45.0   174.3780  15.9530 \n"
      append lignes "74354 199622    2014-01-01 06:11:59.0   340.7310 -45.0370\n"
      append lignes "74360 287307    2014-01-01 20:14:08.0   254.3850 -15.9870\n"
      append lignes "74445 132368    2014-01-08 05:15:41.0   25.6910 -22.2800\n"
      append lignes "74476 220419    2014-01-10 16:00:49.0   135.9240 -64.6760\n"
      append lignes "74651 324256    2014-01-23 11:53:45.0   105.4400   0.8110 \n"
      append lignes "74673 171299    2014-01-25 03:27:08.0   53.0020 -49.4910 \n"
      append lignes "74695 48774     2014-01-26 21:41:36.0  240.5100 -55.3980\n"
      append lignes "74771 129877    2014-02-02 07:27:04.0   95.1610 -60.8300 \n"
      append lignes "74785 2831      2014-02-03 06:48:06.0   89.7300 -23.3940 \n"
      append lignes "74843 250509    2014-02-05 17:25:57.0   186.3110 -72.3530 \n"
      append lignes "75075 120919    2014-02-23 01:01:20.0  43.7120 -10.8020 \n"
      append lignes "75128 123593    2014-02-27 05:13:49.0 284.6930 -77.1700 \n"
      append lignes "75138 143848    2014-02-28 01:18:05.0 306.2250 -55.5340 \n"
      append lignes "75154 311899    2014-03-01 18:59:18.0 216.8680 -64.2850 \n"
      append lignes "75189 105332    2014-03-04 05:19:15.0 117.9300 -44.9440 \n"
      append lignes "75257 134086    2014-03-09 00:40:10.0  52.5100 -12.9550 \n"
      append lignes "75301 46438     2014-03-11 13:16:20.0 237.4160  31.8260 \n"
      append lignes "75463 2253      2014-03-23 15:31:01.0 150.9190 -27.3700 \n"
      append lignes "75646 307663    2014-04-05 04:29:51.0 351.9860 -30.1200 \n"
      append lignes "75700 154650    2014-04-08 11:10:09.0 177.4610  -3.3010 \n"
      append lignes "76057 206464    2014-05-05 11:54:47.0 203.3590  14.4500 \n"
      append lignes "76190 124408    2014-05-15 04:35:16.0  39.4710 -19.7310 \n"
      append lignes "76752 139017    2014-06-19 18:08:45.0 339.2430  -2.9260 \n"
      append lignes "76893 166517    2014-06-30 14:23:27.0  20.9330   1.2800 \n"
      append lignes "77365 8975      2014-08-02 20:07:12   277.6310 -62.7190 \n"
      append lignes "77581 49060     2014-08-18 11:21:43   139.8170 -53.2210 \n"
      append lignes "77959 140076    2014-09-14 05:13:35   298.4240   2.6770 \n"
      append lignes "78005 353182    2014-09-17 20:23:26   163.2520  -2.4340 \n"
      append lignes "78107 337327    2014-09-25 15:06:59    64.1010 -62.7310 \n"
      append lignes "78483 192415    2014-10-27 16:32:27   173.1440 -14.0480 \n"
      append lignes "78647 126736    2014-11-12 00:10:59   127.8870 -22.9110 \n"
      append lignes "78960 308537    2014-12-06 16:49:33   245.9210 -13.3280 \n"
      append lignes "79101 395491    2014-12-20 14:53:59    71.6790 -45.9680 \n"
      append lignes "79106 269450    2014-12-20 23:15:00   345.7230 -35.3700 \n"
      append lignes "79216 261551    2014-12-31 17:39:44   261.0560 -58.7460 \n"
      append lignes "79270 254426    2015-01-05 17:31:01   205.7080  38.3790 \n"
      append lignes "\n"
      set finp list_coordonnees_radec_alerts_tatoo.txt
      set antarespath [ file join $::audace(rep_userCatalog) grb antares]
      file mkdir $antarespath
      set fichier ${antarespath}/${finp}
      set f [open $fichier w]
      puts -nonewline $f $lignes
      close $f
      console::affiche_resultat "File $fichier created\n"

   } elseif {$methode=="update"} {

      set finp [lindex $args 1]
      if {$finp==""} {
         set finp list_coordonnees_radec_alerts_tatoo.txt
      }
      set antarespath [ file join $::audace(rep_userCatalog) grb antares]
      set fichier ${antarespath}/${finp}
      if {[file exists $fichier]==0} {
         error "Input file $fichier not found."
      }

      set f [open $fichier r]
      set lignes [split [read $f] \n]
      close $f
      set ras ""
      set decs ""
      set jds ""
      set equinoxs ""
      set textes ""
      set superlignes ""
      foreach ligne $lignes {
         append superlignes "      append lignes \"$ligne\\n\"\n"
         set d1 [string range $ligne 0 9]
         if {[string length $d1]<5} {
            continue
         }
         set d2 [lindex $ligne 0]
         set err [catch {expr $d2} msg]
         if {$err==1} {
            continue
         }
         set run_number [lindex $ligne 0]
         set nframe [lindex $ligne 1]
         set date [lindex $ligne 2]
         set time [lindex $ligne 3]
         set ra [lindex $ligne 4]
         set dec [lindex $ligne 5]
         set date ${date}T${time}
         set jd [mc_date2jd $date]
         lappend ras $ra
         lappend decs $dec
         lappend jds $jd
         lappend equinoxs J2000
         set texte "$date [format %8.4f $ra] [format %+8.4f $dec]\n"
         append textes $texte
         ::console::affiche_resultat $texte
      }

      set n [llength $jds]
      set mult [expr 100./$n]

      ::console::affiche_resultat "$n Antares alerts\n"
      set fname "$audace(rep_images)/tmp[buf$audace(bufNo) extension]"
      set method 0
      set minobjelev 5
      set maxsunelev -10
      set minmoondist 5
      mc_lightmap $jds $ras $decs $equinoxs $fname 1 1 $method $minobjelev $maxsunelev $minmoondist
      loadima $fname
      mult $mult
      ::console::affiche_resultat "Map is displayed in percents\n"
      set sites ""
      lappend sites [list GFT 31.05 -115.45]
      lappend sites [list TAROT-Chili -29.259917 -70.7326]
      lappend sites [list TAROT-Calern 43.75203 6.92353]
      lappend sites [list Zadko -31.356667 115.713611]
      foreach site $sites {
         set obs [lindex $site 0]
         set lat [lindex $site 1]
         set lon [lindex $site 2]
         set y [expr 90+$lat]
         if {$lon<0} {
            set x [expr 360+$lon]
         } else {
            set x $lon
         }
         set res [lindex [buf$audace(bufNo) getpix [list [expr round($x)] [expr round($y)]]] 1]
         ::console::affiche_resultat "Telescope ${obs}: $x $y => $res %\n"
      }

      set fichier ${antarespath}/antares_triggers.txt
      set f [open $fichier w]
      puts -nonewline $f $textes
      close $f
      set fname "${antarespath}/antares_triggers[buf$audace(bufNo) extension]"
      buf$audace(bufNo) save $fname
      # ::console::affiche_resultat "\n$superlignes\n"

   } elseif {$methode=="html"} {

      source "$audace(rep_install)/gui/audace/world_tools.tcl"
      set finp [lindex $args 1]
      if {$finp==""} {
         set finp antares_triggers.txt
      }
      set antarespath [ file join $::audace(rep_userCatalog) grb antares]
      set fichier ${antarespath}/${finp}
      if {[file exists $fichier]==0} {
         error "Input file $fichier not found. Use grb_antares update before."
      }

      set antarespath [ file join $::audace(rep_userCatalog) grb antares html]
      file mkdir $antarespath

      set f [open $fichier r]
      set lignes [split [read $f] \n]
      close $f

      set htmltextes ""
      append htmltextes "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n"
      append htmltextes "<html>\n"
      append htmltextes "<head>\n"
      append htmltextes "  <meta content=\"text/html; charset=ISO-8859-1\" http-equiv=\"content-type\">\n"
      append htmltextes "  <title>Antares Trigger prompt maps</title>\n"
      append htmltextes "</head>\n"
      append htmltextes "<body>\n"
      append htmltextes "<div style=\"text-align: center;\"><big style=\"font-weight: bold;\"><big>Antares Trigger prompt maps</big></big><br></div>\n"

      # --- map parameters
      set method 0
      set minobjelev 5
      set maxsunelev -10
      set minmoondist 5
      set dlon 1
      set dlat 1

      # --- global map
      set ras ""
      set decs ""
      set jds ""
      set equinoxs ""
      append htmltextes "<pre>\n"
      append htmltextes "Date_of_trigger      RA      DEC\n"
      foreach ligne $lignes {
         set date [lindex $ligne 0]
         set ra [lindex $ligne 1]
         set dec [lindex $ligne 2]
         if {$dec==""} {
            continue
         }
         set equinox J2000
         set jd [mc_date2jd $date]
         lappend ras $ra
         lappend decs $dec
         lappend jds $jd
         lappend equinoxs J2000
         set texte "$date [format %8.4f $ra] [format %+8.4f $dec]\n"
         ::console::affiche_resultat $texte
         append htmltextes "$texte"
      }
      set n [llength $jds]
      set mult [expr 100./$n]
      append htmltextes "</pre>\n"
      set fname "$antarespath/pmap[buf$audace(bufNo) extension]"
      set method 0
      set minobjelev 5
      set maxsunelev -10
      set minmoondist 5
      mc_lightmap $jds $ras $decs $equinoxs $fname 1 1 $method $minobjelev $maxsunelev $minmoondist
      buf$audace(bufNo) load $fname
      mult $mult
      buf$audace(bufNo) save $fname
      buf$audace(bufNo) scale {2 2} 1
      set res [buf$audace(bufNo) stat]
      lassign $res hicut locut
      visu [list $hicut $locut]
      world_jpegmap "$antarespath/pmap.jpg" 1 0
      set px [expr 2*(1+360/$dlon)]
      set py [expr 2*(1+180/$dlat)]
      append htmltextes "<img style=\"width: ${px}px; height: ${py}px;\" alt=\"\" src=\"pmap.jpg\"><br>\n"
      append htmltextes "This map displays the percents of trigger prompt visibility from gound.<br>\n"

      # --- individual maps
      set km 0
      foreach ligne $lignes {
         set date [lindex $ligne 0]
         set ra [lindex $ligne 1]
         set dec [lindex $ligne 2]
         if {$dec==""} {
            continue
         }
         incr km
         set equinox J2000
         set jd [mc_date2jd $date]
         append htmltextes "<br>\n"
         append htmltextes "<hr style=\"width: 100%; height: 2px;\">\n"
         append htmltextes "Trigger date : $date<br>\n"
         append htmltextes "Coordinates : ${ra} ${dec} ${equinox}<br>\n"
         ::console::affiche_resultat "$ligne ...\n"
         set fname "$antarespath/map${km}[buf$audace(bufNo) extension]"
         mc_lightmap $jd $ra $dec $equinox $fname $dlon $dlat $method $minobjelev $maxsunelev $minmoondist
         buf$audace(bufNo) load $fname
         buf$audace(bufNo) scale {2 2} 1
         visu {1 0}
         world_jpegmap "$antarespath/map${km}.jpg" 1 0
         set px [expr 2*(1+360/$dlon)]
         set py [expr 2*(1+180/$dlat)]
         append htmltextes "<img style=\"width: ${px}px; height: ${py}px;\" alt=\"\" src=\"map${km}.jpg\">\n"
      }
      append htmltextes "</body>\n"
      append htmltextes "</html>\n"

      set fichier ${antarespath}/index.html
      set f [open $fichier w]
      puts -nonewline $f $htmltextes
      close $f

   } else {

      ::console::affiche_resultat "Error: First element must be a method amongst update, html\n"

   }
}

