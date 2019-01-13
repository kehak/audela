## @file bdi_tools_orbfit.tcl
#  @brief     Ensemble de fonctions concernant l orbitagraphie des asteroides qui ont ete decouvert
#             Genere des solutions orbitale et des incertitudes
#             Fonctions de base ne necessitant pas de GUI
#  @author    Frederic Vachier
#  @version   1.0
#  @date      2018
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_orbfit.tcl]
#  @endcode

# $Id: bdi_tools_orbfit.tcl 13117 2016-05-21 02:00:00Z fredvachier $






   #------------------------------------------------------------
   ## @namespace bdi_tools_orbfit
   #  @brief Espace de nom dedie  a la communication avec orbfit
   #  @pre Requiert une installation prealable d orbfit sur la machine
   #  @warning Outil en d&eacute;veloppement
   #
   namespace eval ::bdi_tools_orbfit {
      
      variable ephem
      
   }






   #------------------------------------------------------------
   ## Procedure de Test sur l existence des outils Orbfit
   #  @return void
   #
   proc ::bdi_tools_orbfit::test_soft_exist {  } {
      
      global bddconf audace
      
      set ::bdi_tools_orbfit::orbfit_install_dir "/usr/local/src/OrbFit"
      
      set lfiles [list [list "AST17.bai" "AST17.bai_431_fcct"] [list "AST17.bep" "AST17.bep_431_fcct"]]
      
      if {[pwd] != $bddconf(dirtmp)} {
         gren_erreur "Vous etes dans le repertoire : [pwd]\n"
         gren_erreur "Changement de repertoire courant : $bddconf(dirtmp)\n"
         cd $bddconf(dirtmp)
      }
      
      foreach x $lfiles {
   
         lassign $x file to_link
         
         if { ! [file exists $file] } {
            gren_erreur "Ceate link for $file \n"
            set file_to_link [file join $::bdi_tools_orbfit::orbfit_install_dir tests bineph testout $to_link]
            if { ! [file exists $file_to_link] } {
               gren_erreur "input file $file_to_link not exist. Quit with Error \n"
               return -code 1 "input file $file_to_link not exist. Quit with Error \n"
            }
    
            set err [ catch {file link -symbolic $file $file_to_link } msg ]
            if { $err } {
               gren_erreur "Ceate link Error \[$err\] : $msg\n"
               return -code 2 "Ceate link Error : $msg\n"
            }
            
            if { ! [file exists $file] } {
               gren_erreur "Ceate link Error : $file not exist\n"
               return -code 3 "Ceate link Error : $file not exist\n"
            }
            gren_info "Link created\n"
            
         }
         
      }
   
      set lfiles [list "test.eq0"  "test.fop" "test.eph.res" "test.working.cfo"]
      
      foreach file $lfiles {
         if { ! [file exists $file] } {
            gren_erreur "Ceate link for $file \n"
            set file_to_link [file join $audace(rep_install) gui audace plugin tool bddimages scripts console orbfit $file]
            if { ! [file exists $file_to_link] } {
               gren_erreur "input file $file_to_link not exist. Quit with Error \n"
               return -code 1 "input file $file_to_link not exist. Quit with Error \n"
            }
            set err [ catch {file link -symbolic $file $file_to_link } msg ]
            if { $err } {
               gren_erreur "Ceate link Error \[$err\] : $msg\n"
               return -code 2 "Ceate link Error : $msg\n"
            }
            
            if { ! [file exists $file] } {
               gren_erreur "Ceate link Error : $file not exist\n"
               return -code 3 "Ceate link Error : $file not exist\n"
            }
            gren_info "Link created\n"
         }
      }
   
      # test de lancement de fitobs
      set launch "test.exist.cfo"
      set f [open $launch w]
      puts $f "test"
      puts $f "0"
      close $f
      
      if { ! [file exists $file] } {
         gren_erreur "Error creating launch data : $launch not exist\n"
         return -code 4 "Error creating launch data : $launch not exist\n"
      }
      
      set cmd "fitobs.x < $launch | grep \"input orbit file correctly read\""
      set err [catch {eval exec $cmd} msg]
      if { $err } {
         gren_erreur "Testing Launch fitobs Error \[$err\] : $msg\n"
         return -code 2 "Testing Launch fitobs Error \[$err\] : $msg\n"
      }
      
      return 0
   
   }






   #------------------------------------------------------------
   ## Procedure de Test sur le fonctionnement des outils Orbfit
   #  et compare des resultats
   #  @return void
   #
   proc ::bdi_tools_orbfit::test_soft_work {  } {
   
      set err [catch {::bdi_tools_orbfit::test_soft_exist} msg]
      
      # integrite structurelle
      if { $err } {
         gren_erreur "test_soft_work: Error in existing software \[$err\] : $msg\n"
         return -code 11 "test_soft_work: Error in existing software \[$err\] : $msg\n"
      }
   
     
      # lancement de fitobs
      set cmd "fitobs.x < test.working.cfo | grep \"input orbit file correctly read\""
      set err [catch {eval exec $cmd} msg]
      if { $err } {
         gren_erreur "Testing Launch fitobs Error \[$err\] : $msg\n"
         return -code 12 "Testing Launch fitobs Error \[$err\] : $msg\n"
      }
      
      
      set cmd "diff test.eph test.eph.res"
      set err [catch {eval exec $cmd} msg]
      if { $err || $msg != ""} {
         gren_erreur "Testing fitobs Error : Different results \[$err\] : $msg\n"
         return -code 13 "Testing fitobs Error : Different results \[$err\] : $msg\n"
      }

      ::bdi_tools_orbfit::test_clean
   
      gren_info "FITOBS : Integrity Test : SUCCESS\n"
      return
   }






   #------------------------------------------------------------
   ## Effacement des fichiers temporaires generes par les tests de fonctionnement
   #  et compare des resultats
   #  @return void
   #
   proc ::bdi_tools_orbfit::test_clean {  } {
      
      set lfiles [list test.eq0 test.eph test.fop test.eph.res test.working.cfo test.pro test.fou test.fga test.exist.cfo]
      foreach file $lfiles {
         set err [ catch {file delete -force $file} msg ]
         if { $err } {
            gren_erreur "Delete file Error \[$err\] : $msg\n"
            return -code 111 "Delete file Error : $msg\n"
         }
      }
      
   }






   #------------------------------------------------------------
   ## Effacement des fichiers temporaires generes par les calculs 
   #  @param  id_obj : identifiant de l objet
   #  @return void
   #
   proc ::bdi_tools_orbfit::fitobs_clean { id_obj } {
      # "$id_obj.eph" 
      set lfiles [list "$id_obj.cfo" "$id_obj.pro" "$id_obj.fou" "$id_obj.fga" \
                       "$id_obj.eq0" "$id_obj.fop" "$id_obj.err" \
                       "$id_obj.fel" "$id_obj.obs" "$id_obj.rms" "$id_obj.rwo" \
                 ]
      foreach file $lfiles {
         set err [ catch {file delete -force $file} msg ]
         if { $err } {
            gren_erreur "Delete file Error \[$err\] : $msg\n"
            return -code 111 "Delete file Error : $msg\n"
         }
      }
      
   }






   #------------------------------------------------------------
   ## Retourne le statut d'une solution d orbite genere
   #  @param  file   : fichier d orbite
   #  @return status : Success Planif Error
   #
   proc ::bdi_tools_orbfit::get_status { file } {
   
      set cmd "grep \"Keplerian elements\" $file"
      set err [catch {eval exec $cmd} msg]
      if { $err } { 
         set kep "no"
      } else {
         if {$msg == ""} {set kep "no"} else {set kep "yes"}
      }
   
      set cmd "grep \"Equinoctial elements\" $file"
      set err [catch {eval exec $cmd} msg]
      if { $err } { 
         set equ "no"
      } else {
         if {$msg == ""} {set equ "no"} else {set equ "yes"}
      }
   
      set cmd "grep \"COV\" $file"
      set err [catch {eval exec $cmd} msg]
      if { $err } { 
         set cov "no"
      } else {
         if {$msg == ""} {set cov "no"} else {set cov "yes"}
      }
   
      if {$kep=="yes" && $equ=="yes" && $cov=="yes" } { 
         set status "Success"
      } else {
         if {$kep=="yes"} {
            set status "Planif"
         } else {
            set status "Error"
            return -code 1 "No solution found"
         }
      }
      return $status
   }






   #------------------------------------------------------------
   ## lecture de la ligne du fichier d ephemerides et rempli
   #  la table de donnee : variable de namespace : ephem
   #  @param  line : ligne du fichier txt
   #  @return 
   #
   #
   #  Lecture de la ligne d ephemeride fournit par fitobs
   #
   #    GOOD                        BAD 
   #
   # 0 22                       # 0 21                      
   # 1 Dec                      # 1 Sep                     
   # 2 2018                     # 2 2018                    
   # 3 0.000                    # 3 0.000                   
   # 4 58474.000000   mjd       # 4 58382.000000     mjd    
   # 5 22                       # 5 20                      
   # 6 29                       # 6 19                      
   # 7 36.609                   # 7 19.728                  
   # 8 +10                      # 8 +                       
   # 9 3                        # 9 0                       
   # 10 57.67                   # 10 43                     
   # 11 -10.0         mag       # 11 31.24                  
   # 12 -74.2                   # 12 -10.0           mag    
   # 13 INF                     # 13 -19.0                  
   # 14 -19.7                   # 14 INF                    
   # 15 -74.1         solel     # 15 -30.8                  
   # 16 96.4                    # 16 -126.9          solel  
   # 17 -39.4                   # 17 20.1                   
   # 18 75.3                    # 18 -19.1                  
   # 19 1.7275                  # 19 44.0                   
   # 20 1.7158                  # 20 1.6882                 
   # 21 1.3306                  # 21 0.8821                 
   # 22 0.3945                  # 22 0.0858                 
   # 23 1.025'        err1      # 23 0.2148                 
   # 24 0.220'        err2      # 24 17.169\"        err1   
   # 25 106.0         phase     # 25 1.693\"         err2   
   #                            # 26 126.5           phase
   #
   proc ::bdi_tools_orbfit::read_ephem_line { line } {
      
      set rd [regexp -inline -all -- {\S+} $line]
      set tab [split $rd " "]
      
      set c [lindex $tab 8]
      if {$c=="+" || $c=="-"} {
         set tab2 ""
         foreach val [lrange $tab 0 7] { lappend tab2 $val }
         lappend tab2 "[lindex $tab 8][lindex $tab 9]"
         foreach val [lrange $tab 10 end] { lappend tab2 $val }
         set tab $tab2
      }
      
      set c [lindex $tab 24]
      if {[string first "-" $c]>0} {
         #gren_erreur "signe -\n"
         set t [split $c "-"]
         lassign $t a b
         #gren_erreur "signe - : ($c) ($a) ($b)\n"
         
         set tab2 ""
         foreach val [lrange $tab 0 end-1] { lappend tab2 $val }
         lappend tab2 $a
         lappend tab2 $b
         set tab $tab2
         
      }
            
      # erreur grave
      if {[llength $tab] != 26} {
         gren_erreur "Erreur de lecture de ligne d ephem => tab contient [llength $tab]\n"
         gren_erreur "tab=$tab\n"
         set i -1
         foreach x $tab {
            incr i
            gren_info "$i $x\n"
         }
         return -code 1 "Erreur de lecture de ligne d ephem"
      }
      
      # Lecture des parametres
      set mjd [lindex $tab 4]
      lappend ::bdi_tools_orbfit::ephem(listmjd) $mjd
      set ::bdi_tools_orbfit::ephem($mjd,mag) [lindex $tab 11]
      set ::bdi_tools_orbfit::ephem($mjd,solel) [lindex $tab 15]
      set ::bdi_tools_orbfit::ephem($mjd,phase) [lindex $tab 25]

      # Lecture et calcul de l erreur
      set lerr [catch {set err1 [ ::bdi_tools_orbfit::convert_error [string trim [lindex $tab 23] ] ]} msg ]
      if {$lerr} { 
         gren_erreur "E1 line = $line\n"
         set i -1
         foreach x $tab {
            incr i
            gren_info "$i $x\n"
         }
         return -code 1 $msg
      }
      
      set lerr [catch {set err2 [ ::bdi_tools_orbfit::convert_error [string trim [lindex $tab 24] ] ]} msg ]
      if {$lerr} {
         gren_erreur "E2 line = $line\n"
         set i -1
         foreach x $tab {
            incr i
            gren_info "$i $x\n"
         }
         return -code 1 $msg
      }

      set ::bdi_tools_orbfit::ephem($mjd,err)   [expr sqrt(pow($err1,2)+pow($err2,2)) * 3.0]
      return
   }






   #------------------------------------------------------------
   ## Lecture du fichier d ephemerides
   #  @param  file_eph : fichier d ephemerides
   #  @return status   : Success Planif Error
   #
   proc ::bdi_tools_orbfit::read_ephem { file_eph } {

      # Vidage du tableau de donnees des ephemerides
      array unset ::bdi_tools_orbfit::ephem
      set ::bdi_tools_orbfit::ephem(listmjd) ""

      # Lecture du fichier
      set f [open $file_eph "r"]
      set data ""
      set i -1
      while {![eof $f]} {
         incr i
         set line [string trim [gets $f] ]
         if {$i<=3} {continue}
         if {$line == ""} {continue}
          
         set err [catch {::bdi_tools_orbfit::read_ephem_line $line} msg ]
         if {$err} { return -code 1 $msg }
      }
      close $f
      
      gren_info "Nb Date lues in $file_eph = [llength $::bdi_tools_orbfit::ephem(listmjd)]\n"
   }




   #------------------------------------------------------------
   ## Cree le fichier fop 
   #  @param  id_obj : identifiant de l objet
   #  @return void
   #
   proc ::bdi_tools_orbfit::create_fop { id_obj } {

      set log 0

      set file_fop "$id_obj.fop"
      file delete -force $file_fop

      # Fichier d initialisation
      set f [open $file_fop w]
      puts $f  "! input file for fitobs"
      puts $f  "fitobs."
      puts $f  "! first arc"
      puts $f  "        .astna0='$id_obj'           ! Asteroid name"
      puts $f  "        .ons_name=.T.               ! F = known asteroid, T = unknown asteroid"
      puts $f  "        .obsdir0='.'                ! directory of observation file"
      puts $f  "        .elefi0='$id_obj.eq0'       ! directory of orbit/orbit file"
      puts $f  "        .error_model='fcct14'       ! error model file name (defaults to ' ')"
      puts $f  "! bizarre control; "
      puts $f  "        .ecclim=     0.9999d0       ! max eccentricity for non bizarre orbit "
      puts $f  "        .samin=      0.5d0          ! min a for non bizarre orbit "
      puts $f  "        .samax=      100.d0         ! max a for non bizarre orbit "
      puts $f  "        .phmin=      0.001d0        ! min q for non bizarre orbit "
      puts $f  "        .ahmax=     200.d0          ! max Q for non bizarre orbit"
      puts $f  "propag."
      puts $f  "        .iast=17                    ! 0=no asteroids with mass n=no. of massive asteroids "
      puts $f  "        .filbe='AST17'              ! Asteroid file"
      puts $f  "        .npoint=600                 ! minimum number of data points for a deep close appr"
      puts $f  "        .dmea=0.2d0                 ! min. distance for control close-app. to Earth only"
      puts $f  "        .dter=0.05d0                ! min. distance for control close-app. to M, V, M"
      puts $f  "reject."
      puts $f  "        .rejopp = .T.               ! reject entire oppositions"
      puts $f  "        .rej_fudge= .F.             ! fudge not used"
      puts $f  "IERS."
      puts $f  "        .extrapolation=.T.          ! extrapolation of Earth rotation"
      close $f

      if { ! [file exists $file_fop] } {
         set msg "Error creating launch data : $file_fop not exist"
         if {$log} {gren_erreur "$msg\n"}
         return -code 2 $msg
      } else {
         if {$log} {gren_info "File created : $file_fop\n"}
      }
   
      return
   }

   #------------------------------------------------------------
   ## Calcule les solution d orbite de l asteroide 
   #  @param  id_obj : identifiant de l objet
   #  @return void
   #
   proc ::bdi_tools_orbfit::get_orbit { id_obj } {

      set log 0

      if {$log} {gren_info "DEMARRAGE\n"}

      set file_cfo "$id_obj.cfo"
      set file_fel "$id_obj.fel"
      set file_eq0 "$id_obj.eq0"

      file delete -force $file_cfo
      file delete -force $file_fel
      file delete -force $file_eq0
            
      # Fichier de commande
      set f [open $file_cfo w]
      puts $f $id_obj
      puts $f 2
      puts $f 4
      puts $f 1
      puts $f 3
      puts $f 1
      puts $f 0
      close $f

      if { ! [file exists $file_cfo] } {
         set msg "Error creating launch data : $file_cfo not exist"
         if {$log} {gren_erreur "$msg\n"}
         return -code 1 $msg
      } else {
         if {$log} {gren_info "File created : $file_cfo\n"}
      }
      
      # Fichier d initialisation fop
      set err [catch {::bdi_tools_orbfit::create_fop $id_obj} msg]
      if { $err } {
         set msg "Error creating fop"
         if {$log} {gren_erreur "$msg\n"}
         return -code 2 $msg
      } else {
         if {$log} {gren_info "File fop created\n"}
      }

      # Lancement de fitobs
      set cmd "fitobs.x < $file_cfo | grep \"input orbit file correctly read\""
      set err [catch {eval exec $cmd} msg]
      if { $err } {
         if {[string trim $msg] == "Note: The following floating-point exceptions are signalling: IEEE_DENORMAL"} {
            # Warning !
            set msg "Warning : Testing Launch fitobs Warning ? Error ? \[$err\] \n $msg"
            #gren_erreur "$msg\n"
         } else {
            # Error
            set msg "Warning : Testing Launch fitobs Warning ? Error ? \[$err\] \n $msg"
            return -code 3 $msg
         }
      }

      # teste l existence de resultat
      if { ! [file exists $file_fel] } {
         set msg "Error creating orbit : $file_fel not exist"
         if {$log} {gren_erreur "$msg\n"}
         return -code 4 $msg
      } else {
         if {$log} {gren_info "File created : $file_fel\n"}
      }
      
      # Analyse du resultat
      set err [ catch {::bdi_tools_orbfit::get_status $file_fel} msg ]
      if { $err } {
         return -code 5 $msg
      } else {
         set status $msg
      }

      # Copy du resultat si tout est ok
      set err [ catch {file copy -force -- $file_fel $file_eq0} msg ]
      if { $err } {
         set msg "Error creating orbit : error copy $file_fel to $file_eq0"
         if {$log} {gren_erreur "$msg\n"}
         return -code 6 $msg
      }
      
      # teste l existence de resultat
      if { ! [file exists $file_eq0] } {
         set msg "Error creating orbit : $file_eq0 not exist"
         if {$log} {gren_erreur "$msg\n"}
         return -code 7 $msg
      } else {
         if {$log} {gren_info "File created : $file_eq0\n"}
      }

      #gren_info "Success\n"
      return -code 0 [list $status $file_eq0]
   }






   #------------------------------------------------------------
   ## lecture de l erreur dans la ligne du fichier ephem d orbfit
   # @param  err : Erreur lue en chaine de caractere
   # @return err : sous forme d un reel exprime en minute d arc
   #
   proc ::bdi_tools_orbfit::convert_error { err } {
   
      set motif  "^(.+?)\\\\\""
      set res [regexp -all -inline -- $motif $err]
      if { [llength $res] == 2} {
         return [ expr [lindex $res 1]/60.0 ]
      } else {
         set motif  "^(.+?)\\\'"
         set res [regexp -all -inline -- $motif $err]
         if { [llength $res] == 2} {
            return [ expr [lindex $res 1]]
         } else {
            set motif  "^(.+?)d"
            set res [regexp -all -inline -- $motif $err]
            if { [llength $res] == 2} {
               return [ expr [lindex $res 1]*60.0 ]
            } else {
               return -code 1 "not recognize error ($err)"
            }
         }
      }
   
   }






   #------------------------------------------------------------
   ## converti une erreur ren en chaine de caractere pour affichage dans la table
   # @param  ren : erreur en minute decimale
   # @return err : erreur en chaine de caractere formattee
   # @warning  l erreur exprimee en chaine de caractere n est pas similaire 
   #           a la chaine lue dans le fichier d ephemeride
   #
   proc ::bdi_tools_orbfit::convert_error_text { ren } {
     if {$ren < 0} { return "-" }
     
     if {$ren > 60} { 
        set err [format "%d°" [expr int($ren/60.0)] ]
     } elseif {$ren > 10} { 
        set err [format "%d'" [expr int($ren)] ]
     } elseif { $ren > 0.5 } {
        set err [format "%.1f'" $ren ]
     } elseif { $ren > [expr 1./60.*5.] } {
        set err [format "%d\"" [expr int($ren*60.)] ]
     } elseif { $ren > [expr 1./60.] } {
        set err [format "%.1f\"" [expr $ren*60.] ]
     } else { 
        set err [format "%.3f\"" [expr $ren*60.] ]
     }
     return $err
   }






   #------------------------------------------------------------
   ## Calcule les parametres de date et d incertitudes de l asteroide 
   #  a partir de la varaible de namespace ephem
   #  @return list : err_now ren to_obs rto oppo err_oppo reo
   #
   #  err_now  : Erreur de l asteroide a la date courante en chaine de caratere
   #  ren      : Erreur de l asteroide a la date courante en minute decimale
   #  to_obs   : date a laquelle l erreur depasse 1 minute d arc
   #  rto      : nb de jour qu il reste avant que l erreur depasse 1 minute d arc
   #  oppo     : date de l opposition
   #  err_oppo : erreur a l opposition en chaine de caratere
   #  reo      : erreur a l opposition en minute decimale
   #
   proc ::bdi_tools_orbfit::eval_ephem { } {
     
      # set critere arret date To Obs
      set critere_erreur 1.0

      lassign { ErrorCode -1 - -1 - - - -1 } err_now ren to_obs rto oppo err_oppo reo

      # information date courante
      set mjd_now [lindex $::bdi_tools_orbfit::ephem(listmjd) 0]
      set ren $::bdi_tools_orbfit::ephem($mjd_now,err)
      set err_now [::bdi_tools_orbfit::convert_error_text $ren]
      set solel_sav $::bdi_tools_orbfit::ephem($mjd_now,solel)
      set mjd_sav   $mjd_now

      # information critere d incertitude
      set day $mjd_now
      foreach mjd $::bdi_tools_orbfit::ephem(listmjd) {
         set err $::bdi_tools_orbfit::ephem($mjd,err)
         if {$err > $critere_erreur} {break}
      }
      set rto [expr $mjd - $day]
      if {$rto == 0} {
         set to_obs "Now"
      } else {
         set jd [expr $mjd + 2400000.5]
         set to_obs [string range [mc_date2iso8601 $jd] 0 9]
      }

      # information opposition
      set mjd1 [lindex $::bdi_tools_orbfit::ephem(listmjd) 0]
      set mjd2 [lindex $::bdi_tools_orbfit::ephem(listmjd) 1]
      set solel1 $::bdi_tools_orbfit::ephem($mjd1,solel)
      set solel2 $::bdi_tools_orbfit::ephem($mjd2,solel)

      if {$solel1 <= $solel2} {
        set pente "+"
      } else {
        set pente "-"
      }

      set solel_sav $solel2
      set mjd_sav   $mjd2

      foreach mjd [lrange $::bdi_tools_orbfit::ephem(listmjd) 2 end] {
         set solel $::bdi_tools_orbfit::ephem($mjd,solel)

         if {$pente == "+"} {

            # Croissant
            if {($solel - $solel_sav) <= -90.0} {
              set solel $solel_sav
              set mjd   $mjd_sav          
              break
            } else {
              set solel_sav $solel
              set mjd_sav   $mjd
              continue        
            }

         } else {

            # Decroissant
            return -code 1 "TODO Decroissant"
            
         }
        
      }
      set jd       [expr $mjd + 2400000.5]
      set oppo     [string range [mc_date2iso8601 $jd] 0 9]
      set reo      $::bdi_tools_orbfit::ephem($mjd,err)
      set err_oppo [::bdi_tools_orbfit::convert_error_text $reo]

      return [list $err_now $ren $to_obs $rto $oppo $err_oppo $reo]
   }





# ::bddimages::ressource ; ::bdi_tools_orbfit::clean_eq0 K18N12N.eq0
   #------------------------------------------------------------
   ## Nettoyage du fichier eq0, car le bloc kepler fait planter
   #  @param  file_eq0 : fichier d element
   #  @return void
   #
   proc ::bdi_tools_orbfit::clean_eq0 { file_eq0 } {
   
      set f [open $file_eq0 "r"]
      set data ""
      set i 0
      while {![eof $f]} {
         set line [gets $f]
         #gren_info "line ($i) = $line\n"

         if {[string trim $line] == ""} { continue }
         if {$i > 0} { incr i }

         if {$i > 0 && $i < 6} {
            #gren_erreur "RM\n"
            continue
         }

         if {[string first "Keplerian" $line]>0} {
            #gren_erreur "Keplerian\n"
            incr i
            continue
         }

         lappend data $line
      }
      close $f
      
      #gren_erreur "CORRECTED FILE\n"
      #foreach line $data {
      #   gren_info "line=$line\n"
      #}

      set f [open $file_eq0 "w"]
      foreach line $data {
         puts $f $line
      }
      close $f

      return
   }








   proc ::bdi_tools_orbfit::read_eq0 { file_eq0 } {
      
      
      set pass "no"
      set f [open $file_eq0 "r"]
      set i 0
      while {![eof $f]} {
         set line [gets $f]
         #gren_info "line ($i) = $line\n"

         if {[string trim $line] == ""} { continue }
         if {$i > 0} { incr i }

         if {$i > 0 && $i < 6} {
            #gren_erreur "RM\n"
            continue
         }

         if {[string first "Keplerian" $line]>0} {

            set line [gets $f]
            set rd [regexp -inline -all -- {\S+} $line]
            set tab [split $rd " "]
            lassign $tab com a e i longnode argperic meananomaly
            
            set line [gets $f]
            set rd [regexp -inline -all -- {\S+} $line]
            set tab [split $rd " "]
            lassign $tab com mjd

            set line [gets $f]
            set rd [regexp -inline -all -- {\S+} $line]
            set tab [split $rd " "]
            lassign $tab com mag

            set pass "yes"
            break
         }

      }
      close $f

      gren_info "$file_eq0 => $pass\n"
      if {$pass == "yes"} {
         return [list $mag $mjd $a $e $i $longnode $argperic $meananomaly]
      }
      
      return 
      
   }     




   #------------------------------------------------------------
   ## Calcule lesparametres de date et d incertitudes de l asteroide 
   #  @param  id_obj : identifiant de l objet
   #  @return void
   #
   proc ::bdi_tools_orbfit::get_uncertainties { id_obj } {

      set uaicode 181
      set log 0

      if {$log} {gren_info "DEMARRAGE\n"}

      set file_cfo "$id_obj.cfo"
      set file_eq0 "$id_obj.eq0"
      set file_eph "$id_obj.eph"

      file delete -force $file_cfo
      file delete -force $file_eph
      
      
      set err [catch {::bdi_tools_orbfit::clean_eq0 $file_eq0} msg]
      if { $err } {
         set msg "Error cleaning eq0"
         if {$log} {gren_erreur "$msg\n"}
         return -code 2 $msg
      } else {
         if {$log} {gren_info "File $file_eq0 cleaned\n"}
      }

      
      # Fichier d initialisation fop
      set err [catch {::bdi_tools_orbfit::create_fop $id_obj} msg]
      if { $err } {
         set msg "Error creating fop"
         if {$log} {gren_erreur "$msg\n"}
         return -code 2 $msg
      } else {
         if {$log} {gren_info "File fop created\n"}
      }

      # Calcul des dates
      set mjd1 [expr int([mc_date2jd now]-  2400000.5 ) ] 
      set mjd2 [expr $mjd1+1000]
      #gren_info "mjd = $mjd1 $mjd2\n"

      # Fichier de commande
      set f [open $file_cfo w]
      puts $f $id_obj
      puts $f 6
      puts $f 6
      puts $f $mjd1
      puts $f $mjd2
      puts $f 1
      puts $f 181
      puts $f 0
      close $f

      if { ! [file exists $file_cfo] } {
         set msg "Error creating launch data : $file_cfo not exist"
         if {$log} {gren_erreur "$msg\n"}
         return -code 1 $msg
      } else {
         if {$log} {gren_info "File created : $file_cfo\n"}
      }

      # Lancement de fitobs
      set cmd "fitobs.x < $file_cfo | grep \"input orbit file correctly read\""
      set err [catch {eval exec $cmd} msg]
      if { $err } {
         if {[string trim $msg] == "Note: The following floating-point exceptions are signalling: IEEE_DENORMAL"} {
            # Warning !
            set msg "Warning : Testing Launch fitobs Warning ? Error ? \[$err\] \n $msg"
            #gren_erreur "$msg\n"
         } else {
            # Error
            set msg "Warning : Testing Launch fitobs Warning ? Error ? \[$err\] \n $msg"
            return -code 3 $msg
         }
      }
      
      # Fichier d ephemeride
      if { ! [file exists $file_eph] } {
         set msg "Error creating ephem data : $file_eph not exist"
         if {$log} {gren_erreur "$msg\n"}
         return -code 2 $msg
      } else {
         if {$log} {gren_info "File exist : $file_eph\n"}
      }
      
      # Lecture du fichier d ephemerides
      ::bdi_tools_orbfit::read_ephem $file_eph

      set err [catch {set res [::bdi_tools_orbfit::eval_ephem]} msg ]
      if {$err} { return -code 1 $msg }

      return $res
   }






