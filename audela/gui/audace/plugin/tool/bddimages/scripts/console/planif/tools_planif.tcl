## @file tools_planif.tcl
#  @brief     Planificateur d observation des asteroides pour un observatoire robotique
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages scripts console planif tools_planif.tcl]
#  @endcode

# $Id: tools_planif.tcl 14544 2018-11-27 06:56:33Z fredvachier $

##
# @namespace tools_planif
# @brief Outils d&eacute;di&eacute;s aux mesures astrom&eacute;triques et photom&eacute;triques en mode multithread automatique et no console
# @warning Outil en d&eacute;veloppement
#
namespace eval ::tools_planif {

   package require ftp
   variable uai_code
   variable fichier_lst       "planif.lst"
   variable fichier_spec      "planif.spec.lst"
   variable fichier_eph_tmp   "planif.eph.tmp"
   variable fichier_eph_final "planif.eph"

}


#------------------------------------------------------------
## Demarrage du programme de planification des observations
# @return void
#
proc ::tools_planif::run {  } {


   set ::tools_planif::files_to_delete ""

   cd $::tools_planif::tmpdir
   
   set debug   0
   set getftp  1
   set sendftp 1

   set ::tools_planif::home [::bdi_gui_cdl::uai2home $::tools_planif::uai_code]
   ::tools_planif::define_horizon_telescope

   set filelst  [file join $::tools_planif::tmpdir $::tools_planif::fichier_lst]
   set filespec [file join $::tools_planif::tmpdir $::tools_planif::fichier_spec]

   # 
   if {$getftp} {
      gren_info "+ Recuperation du fichier planif $::tools_planif::ftpfile"
      set err [catch {::tools_planif::get_lst $filelst} msg]
      if {$err != 0} { 
         return -code $err "Erreur de recuperation du fichier planif: $msg"
      }
   }

   # 
   if {$getftp} {
      gren_info "+ Recuperation du fichier planif SPEC $::tools_planif::ftpspec"
      set err [catch {::tools_planif::get_lst_spec $filespec} msg]
      if {$err != 0} { 
         return -code $err "Erreur de recuperation du fichier planif SPEC: $msg"
      }
   }

   # 
   gren_info "+ Lecture du fichier $filelst"
   set err [catch {::tools_planif::read_lst $filelst} msg]
   if {$err != 0} { 
      return -code $err "Erreur de lecture du fichier planif: $msg"
   }

   # 
   gren_info "+ Lecture du fichier $filespec"
   set err [catch {::tools_planif::read_spec $filespec} msg]
   if {$err != 0} { 
      return -code $err "Erreur de lecture du fichier planif SPEC: $msg"
   }

   # 
   gren_info "+ Calcul des ephemerides"
   if {$debug==0} {set err [catch {::tools_planif::calcul_ephem} msg]}
   if {$err!=0} { 
      return -code $err "Erreur de calcul des ephemerides: $msg"
   }

   # 
   gren_info "+ Lecture des ephemerides"
   set err [catch {::tools_planif::read_ephem} msg]
   if {$err!=0} { 
      return -code $err "Lecture des ephemerides: $msg"
   }

   # 
   gren_info "+ Planification pour $::tools_planif::tabephem(nb) objets"
   set err [catch {::tools_planif::planif} msg]
   if {$err!=0} { 
      return -code $err "Erreur planification : $msg"
   }

   # 
   gren_info "+ Detection des trous dans la planif"
   set err [catch {::tools_planif::search_hole} msg]
   if {$err!=0} { 
      return -code $err "Erreur de recherche des trous dans le planning : $msg"
   }

   # FTP Send
   if {$sendftp} {
      gren_info "+ Envoi le fichier $::tools_planif::fichier_eph_final contenant la planification"
      set err [catch {::tools_planif::send_ephem} msg]
      if {$err!=0} { 
         return -code $err "Erreur d envoi du fichier d'ephemeride : $msg"
      }
   }

   # Effacement des fichiers temporaires
   if {!$debug} {
      gren_info "+ Effacement des fichiers temporaires (NB=[llength $::tools_planif::files_to_delete])"
      foreach file $::tools_planif::files_to_delete {
         file delete -force $file 
      }
   }

   return -code 0 "Normal Exit"
}

#------------------------------------------------------------
## Cette fonction recupere le fichier lst contenant la liste des asteroides
# @return void
#
proc ::tools_planif::get_lst { filelst } {
   
   gren_info "     fichier .lst qui sera ecrit dans le repertoire temporaire = $filelst"
   
   if {$::tools_planif::get_ini_planif_by_ftp == 1} {

      gren_info "     fichier lu sur le serveur ftp = $::tools_planif::ftpdir/$::tools_planif::ftpfile"

      # Ouvre la connexion ftp
      set err [catch {set handle [::ftp::Open $::tools_planif::host $::tools_planif::login $::tools_planif::password -mode passive]} msg]
      if {$err == -1} {
         return -code 1 "   - ERREUR: Connexion au serveur ftp ($::tools_planif::host) impossible: $msg\n"
      }
      gren_info "   + Connexion au serveur ftp reussie"
      # Recupere le fichier
      ::ftp::Cd $handle $::tools_planif::ftpdir
      if {[file exists $filelst] == 1} {
         file delete -force $filelst
      }
      ::ftp::Reget $handle $::tools_planif::ftpfile $filelst
      # Ferme la connexion ftp
      ::ftp::Close $handle
      # Test de l'existence du fichier en local
      if {[file exists $filelst] == 0} {
         return -code 2 "   - ERREUR: Fichier planif ($filelst) inconnu\n"
      }

      # Definition des fichiers temporaires
      lappend ::tools_planif::files_to_delete $filelst

   } else {

      set err [ catch {file copy -force $::tools_planif::localfile $filelst} msg]
      if {$err != 0} {
         return -code 3 "   - ERREUR: Copie locale du fichier planif impossible: $msg"
      }

   }
   
   gren_info "   + Fichier .lst recuperation terminee"

}


#------------------------------------------------------------
## Cette fonction recupere le fichier lst contenant la liste des asteroides
# @return void
#
proc ::tools_planif::get_lst_spec { filespec } {
   
   gren_info "     fichier .spec.lst qui sera ecrit dans le repertoire temporaire = $filespec"

   if {$::tools_planif::get_ini_planif_by_ftp == 1} {

      gren_info "     fichier lu sur le serveur ftp = $::tools_planif::ftpdir/$::tools_planif::ftpspec"

      # Ouvre la connexion ftp
      set err [catch {set handle [::ftp::Open $::tools_planif::host $::tools_planif::login $::tools_planif::password -mode passive]} msg]
      if {$err == -1} {
         return -code 1 "   - ERREUR: Connexion au serveur ftp ($::tools_planif::host) impossible: $msg\n"
      }
      gren_info "   + Connexion au serveur ftp reussie"
      # Recupere le fichier
      ::ftp::Cd $handle $::tools_planif::ftpdir
      if {[file exists $filespec] == 1} {
         file delete -force $filespec
      }
      ::ftp::Reget $handle $::tools_planif::ftpspec $filespec
      # Ferme la connexion ftp
      ::ftp::Close $handle
      # Test de l'existence du fichier en local
      if {[file exists $filespec] == 0} {
         return -code 2 "   - ERREUR: Fichier planif SPEC ($filespec) inconnu\n"
      }

      # Definition des fichiers temporaires
      lappend ::tools_planif::files_to_delete $filespec

   } else {

      set err [ catch {file copy -force $::tools_planif::localspec $filespec} msg]
      if {$err != 0} {
         return -code 3 "   - ERREUR: Copie locale du fichier planif SPEC impossible: $msg"
      }

   }
    
   gren_info "   + Fichier .spec.lst recuperation terminee"

}



#------------------------------------------------------------
## Cette fonction calcule les ephemerides pour tous les corps
# @return void
#
proc ::tools_planif::calcul_ephem {  } {
   
   global audace
   
   
   gren_info "   + Effacement des fichiers temporaires : $::tools_planif::tmpdir/*.eph"
   set cpt 0
   foreach f [glob -nocomplain -directory $::tools_planif::tmpdir *.eph] {
      incr cpt
      file delete -force $f
   }
   gren_info "   + Nb fichiers effaces = $cpt"
   
   # construction de la date courante avec troncature a la minute
   set dateiso [get_date_sys2ut]
   set dateiso "[string range $dateiso 0 16]00.000"
   set date [date_iso2planif $dateiso ]
   gren_info "   + Date courante = $dateiso"
   gren_info "   + Calcul :"

   foreach key $::tools_planif::tabephem(lst,all) {

      set otype $::tools_planif::tabephem($key,otype)
      set ephfile "${key}.eph"

      switch $otype {

      "asteroid" - "sun" - "moon" {
         gren_info [format "       %-10s %-30s" $otype $key]
         set cmd "/usr/local/bin/ephemcc4 $otype --nom \"$::tools_planif::tabephem($key,cname)\""
         append cmd " -b $dateiso -p 1m -d $::tools_planif::nbdates"
         append cmd " --uai $::tools_planif::uai_code"
         append cmd " -r $::tools_planif::tmpdir"
         append cmd " -f ${ephfile}"
         append cmd " -s file:votext"
         append cmd " --iofile $audace(rep_plugin)/tool/bddimages/scripts/console/planif/t60_les_makes_planif_ephemcc.xml"
         append cmd " >/dev/null"

         gren_info "          + CMD=$cmd\n"
         set err [catch { eval exec $cmd } msg]
         if {$err != 0} {
            gren_info "CMD=$cmd\n"
            return -code 3 "Calcul ephem asteroide impossible: $err $msg"
         }
         
         # Definition des fichiers temporaires
         lappend ::tools_planif::files_to_delete ${ephfile}
      
      }

      "keplerian" {
         gren_info [format "       %-10s %-30s" $otype $key]

         set file_json [file join $::tools_planif::tmpdir "$::tools_planif::tabephem($key,cname).json"]
         file delete -force $file_json
         gren_info "          + Ecriture fichier json : $file_json"
         
         set jd [expr $::tools_planif::tabephem($key,mjd) + 2400000.5]    

         set f [open $file_json "w"]
         puts $f "{                                    "
         puts $f "  \"type\":\"asteroid\",             "
         puts $f "  \"name\": \"$::tools_planif::tabephem($key,cname)\",                   "
         puts $f "  \"dynamical_parameters\": {          "
         puts $f "    \"ref_epoch\": $jd,          "
         puts $f "    \"semi_major_axis\": $::tools_planif::tabephem($key,a),   "
         puts $f "    \"eccentricity\": $::tools_planif::tabephem($key,e),      "
         puts $f "    \"inclination\": $::tools_planif::tabephem($key,i),        "
         puts $f "    \"node_longitude\": $::tools_planif::tabephem($key,longnode),     "
         puts $f "    \"perihelion_argument\": $::tools_planif::tabephem($key,argperic),"
         puts $f "    \"mean_anomaly\": $::tools_planif::tabephem($key,meananomaly),      "
         puts $f "    \"ceu\": 0.000,                    "
         puts $f "    \"ceu_rate\": 0.00000,            "
         puts $f "    \"orbit_ref\": \"AUDELA_json\",      "
         puts $f "    \"author\": \"AUDELA\"        "
         puts $f "  }                                  "
         puts $f "}                                    "
         
         close $f
         
         if {! [file exists $file_json]} {
            return -code 3 "Erreur ecriture fichier json : $err $msg"
         }
         
         set cmd "/usr/local/bin/ephemcc4 --target \"$file_json\""
         append cmd " -b $dateiso"
         append cmd " -p 1m"
         append cmd " -d $::tools_planif::nbdates"
         append cmd " --uai $::tools_planif::uai_code"
         append cmd " -r $::tools_planif::tmpdir"
         append cmd " -f ${ephfile}"
         append cmd " -s file:votext"
         append cmd " --iofile $audace(rep_plugin)/tool/bddimages/scripts/console/planif/t60_les_makes_planif_ephemcc.xml"
         append cmd " >/dev/null"

         gren_info "          + CMD=$cmd\n"
         # gren_info "cmd= $cmd\n"
         set err [catch { eval exec $cmd } msg]
         if {$err != 0} {
            gren_info "CMD=$cmd\n"
            return -code 3 "Calcul ephem asteroide impossible: $err $msg"
         }

         # Definition des fichiers temporaires
         lappend ::tools_planif::files_to_delete ${ephfile} $file_json
      
      }

      "star" {
         gren_info [format "       %-10s %-30s" $otype $key]
         set cmd "/usr/local/bin/ephemcc $otype -a simbad -nom $::tools_planif::tabephem($key,cname)"
         append cmd " -b $date -p 1m -d $::tools_planif::nbdates"
         append cmd " -uai $::tools_planif::uai_code -te $::tools_planif::te -tc $::tools_planif::tc"
         append cmd " --iso -r $::tools_planif::tmpdir -f ${ephfile} -s votext >/dev/null"
         #gren_info "cmd= $cmd\n"
         set err [catch { eval exec $cmd } msg]
         if {$err != 0} {
            gren_info "CMD=cmd\n"
            return -code 3 "Calcul ephem etoile impossible: $err $msg"
         }
         # Definition des fichiers temporaires
         lappend ::tools_planif::files_to_delete ${ephfile}
      
      }

      }

   }

}




#------------------------------------------------------------
## Cette fonction calcule les ephemerides pour tous les corps
# @return void
#
proc ::tools_planif::read_ephem {  } {
   
   # Sun
   set ephfile [file join $::tools_planif::tmpdir "sun.eph"]
   if {[file exists $ephfile]} {
      ::tools_planif::read_eph_sun "sun" $ephfile
   } else {
      return -code 1 "Erreur sur l'ephemeride du Soleil. Fichier inexistant : $ephfile"
   }

   # Moon
   set ephfile [file join $::tools_planif::tmpdir "moon.eph"]
   if {[file exists $ephfile]} {
      ::tools_planif::read_eph_moon "moon" $ephfile
   } else {
      return -code 1 "Erreur sur l'ephemeride de la lune. Fichier inexistant : $ephfile"
   }
   
   # Targets
   foreach key $::tools_planif::tabephem(lst,target) {
   
      set ephfile [file join $::tools_planif::tmpdir "${key}.eph"]
      set otype $::tools_planif::tabephem($key,otype)

      switch $otype {

        "asteroid" - "sun" - "moon" {
           if {! [file exists $ephfile]} {return -code 1 "Fichier inexistant : $ephfile"}
           ::tools_planif::read_eph_sso $key $ephfile
        }
        "star" {
           if {! [file exists $ephfile]} {return -code 1 "Fichier inexistant : $ephfile"}
           ::tools_planif::read_eph_star $key $ephfile
        }
        "stationary" {
           gren_info [format "       CALC: %-10s %-30s" $otype $key]
           ::tools_planif::get_eph_stationary $key
        }
        "linear" {
           gren_info [format "       CALC: %-10s %-30s" $otype $key]
           ::tools_planif::get_eph_linear $key
        }
        "keplerian" {
           if {! [file exists $ephfile]} {return -code 1 "Fichier inexistant : $ephfile"}
           ::tools_planif::read_eph_sso $key $ephfile
        }

      }

   }

}

#------------------------------------------------------------
## Cette fonction calcule les ephemerides pour tous les corps
# @return void
#
proc ::tools_planif::planif {  } {
   
   set targets ""
   foreach key $::tools_planif::tabephem(lst,target) {
      if {![info exists ::tools_planif::tabephem($key,nbephem)]} {continue}
      if {$::tools_planif::tabephem($key,nbephem) == 0} {continue}
      lappend targets [list $key $::tools_planif::tabephem($key,priority) $::tools_planif::tabephem($key,nbephem)]
   }
   set targets [lsort -real -increasing -index 1  [lsort -integer -decreasing -index 2 $targets]]
   

   gren_info "   + Planification par intervalle"
   set newtargets ""
   foreach lkey $targets {

      set key [lindex $lkey 0]
      set otype $::tools_planif::tabephem($key,otype)
      switch $otype {

         "asteroid" - "star" {
            lappend newtargets [list $key $::tools_planif::tabephem($key,priority) $::tools_planif::tabephem($key,nbephem)]
         }
         "stationary" - "linear" - "keplerian" {
            set cptmin 0
            set nbminute [expr int((($::tools_planif::tabephem($key,exposure) + 60.0) * $::tools_planif::tabephem($key,nbimg)) / 60)]
            gren_info "      + $key : nbminute = $nbminute"
            
            if {[info exists nextdate]} {unset nextdate}
            foreach dateiso $::tools_planif::alldate {
               if { $::tools_planif::resume($dateiso,planified) } { continue }
               
               if { [info exists ::tools_planif::tabephem($key,ephem,$dateiso,ra)] } {
                  if {[info exists nextdate]} {
                     if {[mc_date2jd $dateiso] < $nextdate} {
                        continue
                     }
                  } else {
                     set cptmin 0
                  }
                  
                  if {$cptmin == 0} {
                     set debutblock [mc_date2jd $dateiso]
                     set nextdate $debutblock
                  }
                  
                  if {$cptmin < $nbminute} {
                     set mura  [format "%0.5f" $::tools_planif::tabephem($key,ephem,$dateiso,mura)]
                     set mudec [format "%0.5f" $::tools_planif::tabephem($key,ephem,$dateiso,mudec)]
                     set h     [format "%0.2f" $::tools_planif::tabephem($key,ephem,$dateiso,h)]
                     set vmag  [format "%0.2f" $::tools_planif::tabephem($key,ephem,$dateiso,vmag)]
                     set ::tools_planif::resume($dateiso,plan) "$dateiso, \
                              $::tools_planif::tabephem($key,ephem,$dateiso,ra), \
                              $::tools_planif::tabephem($key,ephem,$dateiso,dec), \
                              $mura, \
                              $mudec, \
                              $::tools_planif::tabephem($key,cnum), \
                              $::tools_planif::tabephem($key,cname), \
                              $vmag, \
                              $::tools_planif::tabephem($key,exposure), \
                              $::tools_planif::tabephem($key,binning), \
                              $h"
                     set ::tools_planif::resume($dateiso,planified) 1
                     incr cptmin
                  } else {
                     set nextdate [expr $debutblock + $::tools_planif::tabephem($key,hinterval) / 24.0]
                     set cptmin 0
                  }
                  
               }

            }

         }

      }
   
   }
   
   # Planification standard pour les asteroides en bouchant les trous
   gren_info "   + Planification standard"
   set targets [lsort -real -increasing -index 1  [lsort -integer -decreasing -index 2 $newtargets]]
   foreach dateiso $::tools_planif::alldate {
      if { $::tools_planif::resume($dateiso,planified) } { continue }
      foreach lkey $targets {
         set key [lindex $lkey 0]
         if {[info exists ::tools_planif::tabephem($key,ephem,$dateiso,ra)]} {
            set mura  [format "%0.5f" $::tools_planif::tabephem($key,ephem,$dateiso,mura)]
            set mudec [format "%0.5f" $::tools_planif::tabephem($key,ephem,$dateiso,mudec)]
            set h     [format "%0.2f" $::tools_planif::tabephem($key,ephem,$dateiso,h)]
            set vmag  [format "%0.2f" $::tools_planif::tabephem($key,ephem,$dateiso,vmag)]
            set ::tools_planif::resume($dateiso,plan) "$dateiso, \
                     $::tools_planif::tabephem($key,ephem,$dateiso,ra), \
                     $::tools_planif::tabephem($key,ephem,$dateiso,dec), \
                     $mura, \
                     $mudec, \
                     $::tools_planif::tabephem($key,cnum), \
                     $::tools_planif::tabephem($key,cname), \
                     $vmag, \
                     $::tools_planif::tabephem($key,exposure), \
                     $::tools_planif::tabephem($key,binning), \
                     $h"
            set ::tools_planif::resume($dateiso,planified) 1
            break
         }
      }
      
   }
   
   # Sauvegarde du fichier de planification
   gren_info "   + Sauvegarde du fichier de planification"
   set file [file join $::tools_planif::tmpdir $::tools_planif::fichier_eph_tmp]
   set f [open $file "w"]
   puts $f "Date_ISO, RA (hms), DEC (dms), dra*cos(DEC) (\"/s), dDEC (\"/s), num, nom, mag, exposure (s), bin, hauteur (deg)"
   foreach dateiso $::tools_planif::alldate {
      if { ! $::tools_planif::resume($dateiso,planified) } { continue }
      puts $f $::tools_planif::resume($dateiso,plan)
   }
   close $f

   # Definition des fichiers temporaires
   lappend ::tools_planif::files_to_delete $file
}

#------------------------------------------------------------
## Cette fonction envoi le fichier eph contenant la planification
# @return void
#
proc ::tools_planif::search_hole { } {

   set ishole 0
   set list_hole ""
   foreach dateiso $::tools_planif::alldate {

      set jdcurrent [ mc_date2jd $dateiso ]

      set sunrisecurrent $::tools_planif::resume($dateiso,sunrise)
      
      if {![info exists sunrisesav]} {
         set sunrisesav $sunrisecurrent
      }
      # Changement de nuit
      if {$sunrisecurrent!=$sunrisesav} {
         if {$ishole == 1} {
            lappend list_hole [list [ mc_date2iso8601 $jdholebegin ]  [ mc_date2iso8601 $jdholeend ] $diffminute]
         }
         set ishole 0
      }
      set sunrisesav $sunrisecurrent
      
      #if {[format "%.0f" [expr ($jdcurrentlast - $jdcurrent)*60]]} {}
      #set jdcurrentlast $jdcurrent
      
      
      if {$::tools_planif::resume($dateiso,planified)==0} {
         
         if {$ishole == 0} {
            set ishole 1
            set jdholebegin $jdcurrent
            set jdholeend $jdcurrent
         } else {
            set jdholeend $jdcurrent
         }
         set diffminute [format "%.0f" [expr ($jdholeend - $jdholebegin)*1440]]
         
         #gren_info "$dateiso :: $::tools_planif::resume($dateiso,planified) :: $ishole :: $diffminute"
      } else {
         # Fin de trou
         if {$ishole == 1} {
            lappend list_hole [list [ mc_date2iso8601 $jdholebegin ]  [ mc_date2iso8601 $jdholeend ] $diffminute]
         }
         set ishole 0
         #gren_info "$dateiso :: $::tools_planif::resume($dateiso,planified) :: $ishole :: -"
      }
   }

   
   set cpt 0
   set bodymail "Date debut              Date de fin              Duree          Alert\n"
   foreach l $list_hole {
      set deb [lindex $l 0]
      set fin [lindex $l 1]
      set dur [lindex $l 2]
      set ale ""
      if {$dur > $::tools_planif::holelimit} {
         set ale "Mail"
         incr cpt
      }
      append bodymail [format "%s %s %6s minutes %5s\n" $deb $fin $dur $ale]
   }
   gren_info ""
   
   if {$cpt>0} {

      gren_info $bodymail
      
      set filemail [file join $::tools_planif::tmpdir "mail.txt"]
      set chan0 [open $filemail w]
      
      puts $chan0 $bodymail
      close $chan0

      set cmd [format "cat %s | mail -s \"\\%cT60 Warning Planif\\%c Trou de plus de %s minutes\" %s;" $filemail 91 93 $::tools_planif::holelimit $::tools_planif::destmail]
      set err [catch { eval exec $cmd } msg]
      if {$err != 0} {
         return -code 1 "Envoi de mail impossible : $err $msg"
      } else {
         #gren_info "   $cmd"
         gren_info "Mail envoye a $::tools_planif::destmail"
      
      }

      # Definition des fichiers temporaires
      lappend ::tools_planif::files_to_delete $filemail

   }

}
#      set sun "sun"
#      if {[info exists ::tools_planif::tabephem($sun,ephem,$dateiso,h)]} {
#             gren_info "exist "
#          if {![info exists ephlinedate]} {set ephlinedate [ mc_date2jd $dateiso ]}
#          set diffminute [expr ([ mc_date2jd $dateiso ] - $ephlinedate)*1440]
#
#          if {$ephline == "no"} {
#             set istrou "yes"
#             gren_info "trou  : $dateiso : $diffminute"
#             if {$diffminute > 4.0} {
#                gren_info "GRAND trou  : $dateiso : $diffminute"
#             } else {
#                gren_info "trou  : $dateiso : $diffminute"
#             }
#          } else {
#             if {$istrou == "yes"} {
#                lappend ltrou [list [ mc_date2iso8601 $ephlinedate ] $dateiso [format "%.0f" $diffminute]]
#                set istrou "no"
#             }
#             set ephlinedate [ mc_date2jd $dateiso ]
#          }
#
#          #gren_info "trou  : $diffminute"
#          #  if {![info exists ephline]} {set ephline [ mc_date2jd $dateiso ]}
#          #  set diffminute [expr ([ mc_date2jd $dateiso ] - $ephline)*1440]
#          #  if {$diffminute > 4} {
#          #     gren_info "trou  : $diffminute"
#          #  }
#          #  set ephline [ mc_date2jd $dateiso ]
#         
#      }
#      gren_info "$dateiso :: $ephline"

#------------------------------------------------------------
## Cette fonction envoi le fichier eph contenant la planification
# @return void
#
proc ::tools_planif::send_ephem { } {

   set fileeph [file join $::tools_planif::tmpdir $::tools_planif::fichier_eph_tmp]
   
   if {$::tools_planif::set_planif_by_ftp == 1} {

      # Ouvre la connexion ftp
      set err [catch {set handle [::ftp::Open $::tools_planif::host $::tools_planif::login $::tools_planif::password -mode passive]} msg]
      if {$err == -1} {
         return -code 1 "Connexion au serveur ftp ($::tools_planif::host) impossible: $msg\n"
      }
      gren_info "   + Connexion au serveur ftp reussie"

      # Envoi le fichier
      ::ftp::Cd $handle $::tools_planif::ftpdir
      ::ftp::Put $handle $fileeph $::tools_planif::fichier_eph_final
      
      # Envoi du fichier de log
      set filelog [file join $::tools_planif::tmpdir $::tools_planif::logfile]
      if {[file exists $filelog]} {
         update
         ::ftp::Put $handle $filelog $::tools_planif::logfile
      }

      # Ferme la connexion ftp
      ::ftp::Close $handle

   } else {
      set filefinal [file join $::tools_planif::tmpdir $::tools_planif::fichier_eph_final]
      set err [ catch {file copy -force $fileeph $filefinal} msg]
      if {$err != 0} {
         return -code 3 "Copie locale du fichier planif impossible: $msg"
      }

   }

}




