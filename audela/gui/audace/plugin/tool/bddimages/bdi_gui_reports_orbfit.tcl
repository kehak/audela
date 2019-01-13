## @file bdi_gui_reports_orbfit.tcl
#  @brief     Ensemble de fonctions concernant l orbitagraphie des asteroides qui ont ete decouvert
#             Genere des solutions orbitale et des incertitudes
#  @author    Frederic Vachier
#  @version   1.0
#  @date      2018
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_reports_orbfit.tcl]
#  @endcode

# $Id: bdi_gui_reports.tcl 13117 2016-05-21 02:00:00Z fredvachier $






   #------------------------------------------------------------
   ## Cette fonction calcule la solution orbitale de tous les asteroides dans la liste
   #  @return void
   #
   proc ::bdi_gui_reports::fitobs_orbit_compute_all {  } {
   
      ::bdi_tools_orbfit::test_soft_work

      $::bdi_tools_reports::data_newaster_bodies configure -labelcommand ""
   
      set l [$::bdi_tools_reports::data_newaster_bodies get 0 end]
      set id -1
      foreach x $l {
         incr id
         lassign $x id_obj
         
         #gren_info "? $id_obj\n"
         #if {$id_obj != "K18N12N"} {continue}
         
         # creer le fichier d obs
         ::bdi_gui_reports::fitobs_obs_build $id_obj
         
         # lancer fitobs
         set err [ catch {set z [::bdi_tools_orbfit::get_orbit $id_obj]} msg ]
         if { $err } {
            set status "Error"
            gren_erreur "--- $id_obj : ERROR : (err=$err) (msg=$msg)\n"
         } else {

            lassign $z status file_eq0

            # Copie de la solution vers le repertoire rapport
            set dest [file join $::bdi_tools_reports::tab_newaster($id_obj,dir) $file_eq0]
            file delete -force $dest
            gren_info "CP $id_obj : copy de la soluce -> $dest \n"
            set err [ catch {file copy -force -- $file_eq0 $dest} msg ]
            if { $err } {
               set msg "Error creating orbit : error final copy $file_eq0 to $dest"
               gren_erreur "$msg\n"
               return -code 8 $msg
            }
      
            # Efface les fichiers temporaires
            set err [ catch { ::bdi_tools_orbfit::fitobs_clean $id_obj } msg ]
            if { $err } {
               gren_erreur "Delete temporary file Error \[$err\] : $msg\n"
               return -code 111 "Delete temporary file Error : $msg\n"
            }
      
            gren_info "+++ $id_obj : $status : $file_eq0\n"
         }
         
         # afficher les resultats
         set date [clock format [clock scan now] -format "%Y-%m-%d"]
         set y [lreplace $x 3 3 $status]
         set y [lreplace $y 4 4 $date]
         set y [lreplace $y 5 5 0]

         $::bdi_tools_reports::data_newaster_bodies delete $id $id
         $::bdi_tools_reports::data_newaster_bodies insert $id $y

         ::bdi_gui_reports::colorize $id

      }

      $::bdi_tools_reports::data_newaster_bodies configure -labelcommand tablelist::sortByColumn

   }



   #------------------------------------------------------------
   ## Calcule les incertitudes de tous les asteroides dans la liste
   #  @return void
   #
   proc ::bdi_gui_reports::fitobs_uncertainty {  } {

      ::bdi_tools_orbfit::test_soft_work
      $::bdi_tools_reports::data_newaster_bodies configure -labelcommand ""

      set curselection [$::bdi_tools_reports::data_newaster_bodies curselection]
      set nb [llength $curselection]
      foreach selection $curselection {
         set x [$::bdi_tools_reports::data_newaster_bodies get [lindex $selection 0] ]
         set id_obj [lindex $x 0]

         ::bdi_gui_reports::fitobs_calcul_uncertainty $id_obj


      }

      $::bdi_tools_reports::data_newaster_bodies configure -labelcommand tablelist::sortByColumn

      # afficher les resultats
      ::bdi_tools_reports::affiche_newaster

      return
      
   }


   #------------------------------------------------------------
   ## Regenere l orbite de tous les asteroides dans la liste
   #  @return void
   #
   proc ::bdi_gui_reports::fitobs_regen {  } {

      ::bdi_tools_orbfit::test_soft_work
      $::bdi_tools_reports::data_newaster_bodies configure -labelcommand ""

      set curselection [$::bdi_tools_reports::data_newaster_bodies curselection]
      set nb [llength $curselection]
      foreach selection $curselection {
         set x [$::bdi_tools_reports::data_newaster_bodies get [lindex $selection 0] ]
         set id_obj [lindex $x 0]
         gren_info "REGEN id_obj = $id_obj\n"
         
         # Construction du fichier d observation
         ::bdi_gui_reports::fitobs_obs_build $id_obj
         
         # Lancement FITOBS
         set err [ catch {set z [::bdi_tools_orbfit::get_orbit $id_obj]} msg ]
         if { $err } {
            set status "Error"
            gren_erreur "--- $id_obj : ERROR : (err=$err) (msg=$msg)\n"
         } else {

            lassign $z status file_eq0
            gren_erreur "--- $id_obj : (status= $status ) (file_eq0= $file_eq0 )\n"

            # Copie de la solution vers le repertoire rapport
            set dest [file join $::bdi_tools_reports::tab_newaster($id_obj,dir) $file_eq0]
            file delete -force $dest
            gren_info "CP $id_obj : copy de la soluce -> $dest \n"
            set err [ catch {file copy -force -- $file_eq0 $dest} msg ]
            if { $err } {
               set msg "Error creating orbit : error final copy $file_eq0 to $dest"
               gren_erreur "$msg\n"
               set ::bdi_tools_reports::tab_newaster($id_obj,action) "Regler probleme : $msg"
               return -code 8 $msg
            }
      
            # Efface les fichiers temporaires
            if {$status == "Success"} {
               set err [ catch { ::bdi_tools_orbfit::fitobs_clean $id_obj } msg ]
               if { $err } {
                  gren_erreur "Delete temporary file Error \[$err\] : $msg\n"
                  set ::bdi_tools_reports::tab_newaster($id_obj,action) "Regler probleme : $msg"
                  return -code 111 "Delete temporary file Error : $msg\n"
               }
            }
      
            gren_info "+++ $id_obj : $status : $file_eq0\n"
         }

         # Creation de la structure gfo
         if {[info exists ::bdi_tools_reports::tab_newaster($id_obj,gfo)]} {
            # les informations existent deja, on les lit
            gren_info "les informations existent deja, on les lit\n"
            array set gfo $::bdi_tools_reports::tab_newaster($id_obj,gfo)
            
         } else {
            # les informations n existent pas, on part de zero
            gren_info "les informations n existent pas, on part de zero\n"
            array unset gfo
            set gfo(designation,nb) 1
            set gfo(designation,1,name) $id_obj
            set gfo(designation,1,fdes) 1
            set gfo(designation,1,fmpc) 1
         }
         
         set gfo(ren)             -1
         set gfo(to_obs)          "-"
         set gfo(rto)             -1
         set gfo(oppo)            "-"
         set gfo(err_oppo)        "-"
         set gfo(reo)             -1
         
         
         # Calcul des incertitudes
         if {$status == "Success"} {

            # Copie de la solution depuis le repertoire rapport
            set file_eq0 "$id_obj.eq0"
            file delete -force $file_eq0
            set src $::bdi_tools_reports::tab_newaster($id_obj,solu_file)
            gren_info "CP $id_obj : copy de la soluce -> $file_eq0\n"
            set err [ catch { file copy -force -- $src $file_eq0 } msg ]
            if { $err } {
               set msg "Error creating orbit : error final copy $src to $file_eq0"
               set ::bdi_tools_reports::tab_newaster($id_obj,action) "Regler probleme : $msg"
               gren_erreur "$msg\n"
               return -code 8 $msg
            }
            
            # recherche des parametres
            set err [ catch {set z [::bdi_tools_orbfit::get_uncertainties $id_obj]} msg ]
            if { $err } {
               set status "Error"
               set ::bdi_tools_reports::tab_newaster($id_obj,status) $status
               gren_erreur "--- $id_obj : ERROR : (err=$err) (msg=$msg)\n"

            } else {
               set status "Success"
            
               # Efface les fichiers temporaires
               set err [ catch { ::bdi_tools_orbfit::fitobs_clean $id_obj } msg ]
               if { $err } {
                  gren_erreur "Delete temporary file Error \[$err\] : $msg\n"
                  set ::bdi_tools_reports::tab_newaster($id_obj,action) "Regler probleme : $msg"
                  return -code 111 "Delete temporary file Error : $msg\n"
               }
            
               gren_info "+++ $id_obj : $status : $z\n"
               
               set ::bdi_tools_reports::tab_newaster($id_obj,status) $status
               set crea_file [file atime $::bdi_tools_reports::tab_newaster($id_obj,solu_file)]
               set date_solu [clock format $crea_file -format "%Y-%m-%d"]
               set d1 [mc_date2jd [clock format $crea_file -format "%Y-%m-%dT%H:%M:%S"] ]
               set d2 [mc_date2jd [clock format [clock scan now] -format "%Y-%m-%dT%H:%M:%S"] ]
               set solu_age [expr int($d2 - $d1)]
               set ::bdi_tools_reports::tab_newaster($id_obj,date_solu) $date_solu
               set ::bdi_tools_reports::tab_newaster($id_obj,solu_age)  $solu_age
               
               lassign $z ::bdi_tools_reports::tab_newaster($id_obj,err_now) ::bdi_tools_reports::tab_newaster($id_obj,ren) gfo(to_obs) gfo(rto) gfo(oppo) gfo(err_oppo) gfo(reo)
              
            }

         } else {
               set ::bdi_tools_reports::tab_newaster($id_obj,status) $status
               set ::bdi_tools_reports::tab_newaster($id_obj,date_solu) "-"
               set ::bdi_tools_reports::tab_newaster($id_obj,solu_age)  "-"
         }
         




         # Creation du fichier gfo
         set ::bdi_tools_reports::tab_newaster($id_obj,gfo) [array get gfo]
         ::bdi_gui_reports::create_gfo $id_obj
 
 
         # on repart du fichier pour le relire
         gren_info "lecture du fichier $id_obj.gfo\n"
         set err [ catch {::bdi_tools_reports::read_gfo $::bdi_tools_reports::tab_newaster($id_obj,root_file_gfo) gfo} msg]
         if {$err} {
            set ::bdi_tools_reports::tab_newaster($id_obj,action) "Regler probleme : $msg"
            gren_erreur "Erreur : ($err) $msg\n"
            continue
         }
         set ::bdi_tools_reports::tab_newaster($id_obj,gfo) [array get gfo]
 
 
 
 
 
         # Affiche les resultats dans la tablelist
         #set date [clock format [clock scan now] -format "%Y-%m-%d"]
         #set y [lreplace $x 4 4 $status]
         #set y [lreplace $y 5 5 $date]
         #set y [lreplace $y 6 6 0]

         #$::bdi_tools_reports::data_newaster_bodies delete $id $id
         #$::bdi_tools_reports::data_newaster_bodies insert $id $y

         #::bdi_gui_reports::colorize $id
      }

      $::bdi_tools_reports::data_newaster_bodies configure -labelcommand tablelist::sortByColumn

      # afficher les resultats
      ::bdi_tools_reports::affiche_newaster

      return
      
   }





   proc ::bdi_gui_reports::create_gfo { id_obj } {

      array set gfo $::bdi_tools_reports::tab_newaster($id_obj,gfo)

      if {0} {
         
         # Designation
         gren_info "NB designation :: $gfo(designation,nb)\n"
         for {set i 1} {$i <= $gfo(designation,nb)} {incr i} {
            gren_info "designation => $gfo(designation,$i,name) (fdes=$gfo(designation,$i,fdes)) (fmpc=$gfo(designation,$i,fmpc))\n"
         }

         # Other Data
         foreach key [array names gfo] {
            if {$key=="err_oppo"} {continue}
            if {[string first "designation" $key]==-1} {
               gren_info "gfo($key)=$gfo($key)\n"
            }
         }
         
      }

      file delete -force $::bdi_tools_reports::tab_newaster($id_obj,root_file_gfo)
      set f [open $::bdi_tools_reports::tab_newaster($id_obj,root_file_gfo) w]

      set entete ""
      # Designation
      for {set i 1} {$i <= $gfo(designation,nb)} {incr i} {
         append entete [format "designation          := \{ %s %s \} %-62s := Designation\n" $gfo(designation,$i,fdes) $gfo(designation,$i,fmpc) $gfo(designation,$i,name)]
      }

      append entete [format "to_obs               := %-70s := todo comment\n" $gfo(to_obs) ]
      append entete [format "oppo                 := %-70s := todo comment\n" $gfo(oppo)   ]
      append entete [format "rto                  := %-70s := todo comment\n" $gfo(rto)    ]
      append entete [format "reo                  := %-70s := todo comment\n" $gfo(reo)    ]

      puts $f $entete
      close $f


      return
      
   }




   #------------------------------------------------------------
   ## Calcule les incertitudes de tous les asteroides dans la liste
   #  @return void
   #
   proc ::bdi_gui_reports::fitobs_err_compute_all {  } {
   
      $::bdi_tools_reports::data_newaster_bodies configure -labelcommand ""

      set l [$::bdi_tools_reports::data_newaster_bodies get 0 end]
      set id -1
      foreach x $l {
         incr id
         lassign $x id_obj a b c status

         #gren_info "? $id_obj\n"
         #if {$id_obj != "K18N12N"} {continue}

         if {$status != "Success"} {continue}
         gren_info "fitobs_err_compute : $id_obj $status\n"
         
         ::bdi_gui_reports::fitobs_calcul_uncertainty $id_obj
      }

      $::bdi_tools_reports::data_newaster_bodies configure -labelcommand tablelist::sortByColumn
      # afficher les resultats
      ::bdi_tools_reports::affiche_newaster

      return

   }

   #------------------------------------------------------------
   ## Calcule les incertitudes d un asteroide
   #  @return void
   #
   proc ::bdi_gui_reports::fitobs_calcul_uncertainty { id_obj } {

         array set gfo            $::bdi_tools_reports::tab_newaster($id_obj,gfo)
         set gfo(to_obs)          "-"
         set gfo(rto)             -1
         set gfo(oppo)            "-"
         set gfo(reo)             -1

         # Copie de la solution depuis le repertoire rapport
         set file_eq0 "$id_obj.eq0"
         file delete -force $file_eq0
         set src [file join $::bdi_tools_reports::tab_newaster($id_obj,dir) $file_eq0]
         gren_info "CP $id_obj : copy de la soluce -> $file_eq0\n"
         set err [ catch { file copy -force -- $src $file_eq0 } msg ]
         if { $err } {
            set msg "Error creating orbit : error final copy $src to $file_eq0"
            gren_erreur "$msg\n"
            return -code 8 $msg
         }

         # recherche des parametres
         set err [ catch {set z [::bdi_tools_orbfit::get_uncertainties $id_obj]} msg ]
         if { $err } {
            set status "Error"
            gren_erreur "--- $id_obj : ERROR : (err=$err) (msg=$msg)\n"

         } else {
            set status "Success"

            # Efface les fichiers temporaires
            set err [ catch { ::bdi_tools_orbfit::fitobs_clean $id_obj } msg ]
            if { $err } {
               gren_erreur "Delete temporary file Error \[$err\] : $msg\n"
               return -code 111 "Delete temporary file Error : $msg\n"
            }
      
            gren_info "+++ $id_obj : $status : $z\n"

            lassign $z ::bdi_tools_reports::tab_newaster($id_obj,err_now) ::bdi_tools_reports::tab_newaster($id_obj,ren) gfo(to_obs) gfo(rto) gfo(oppo) gfo(err_oppo) gfo(reo)

            # Creation du fichier gfo
            set ::bdi_tools_reports::tab_newaster($id_obj,gfo) [array get gfo]
            ::bdi_gui_reports::create_gfo $id_obj


            # on repart du fichier pour le relire
            gren_info "lecture du fichier $id_obj.gfo\n"
            set err [ catch {::bdi_tools_reports::read_gfo $::bdi_tools_reports::tab_newaster($id_obj,root_file_gfo) gfo} msg]
            if {$err} {
               set ::bdi_tools_reports::tab_newaster($id_obj,action) "Regler probleme : $msg"
               gren_erreur "Erreur : ($err) $msg\n"
               continue
            }
            set ::bdi_tools_reports::tab_newaster($id_obj,gfo) [array get gfo]

         }


      return

   }



   #------------------------------------------------------------
   ## Calcule les incertitudes de tous les asteroides dans la liste
   #  @return void
   #
   proc ::bdi_gui_reports::fitobs_err_compute_all_obsolete {  } {
   
      set l [$::bdi_tools_reports::data_newaster_bodies get 0 end]
      set id -1
      foreach x $l {
         incr id
         lassign $x id_obj a b status

         #gren_info "? $id_obj\n"
         #if {$id_obj != "K18N12N"} {continue}

         if {$status != "Success"} {continue}
         gren_info "fitobs_err_compute : $id_obj $status\n"
         
         # Copie de la solution depuis le repertoire rapport
         set file_eq0 "$id_obj.eq0"
         file delete -force $file_eq0
         set src [file join $::bdi_tools_reports::tab_newaster($id_obj,dir) $file_eq0]
         gren_info "CP $id_obj : copy de la soluce -> $file_eq0\n"
         set err [ catch { file copy -force -- $src $file_eq0 } msg ]
         if { $err } {
            set msg "Error creating orbit : error final copy $src to $file_eq0"
            gren_erreur "$msg\n"
            return -code 8 $msg
         }

         # recherche des parametres
         set err [ catch {set z [::bdi_tools_orbfit::get_uncertainties $id_obj]} msg ]
         if { $err } {
            set status "Error"
            gren_erreur "--- $id_obj : ERROR : (err=$err) (msg=$msg)\n"

            set y [lreplace $x 6 6 $status]
            $::bdi_tools_reports::data_newaster_bodies delete $id $id
            $::bdi_tools_reports::data_newaster_bodies insert $id $y

         } else {
            set status "Success"

            # Efface les fichiers temporaires
            set err [ catch { ::bdi_tools_orbfit::fitobs_clean $id_obj } msg ]
            if { $err } {
               gren_erreur "Delete temporary file Error \[$err\] : $msg\n"
               return -code 111 "Delete temporary file Error : $msg\n"
            }
      
            gren_info "+++ $id_obj : $status : $z\n"

            lassign $z err_now ren to_obs rto oppo err_oppo reo
            set y [lreplace $x  6  6 $err_now]
            set y [lreplace $y  7  7 $ren]
            set y [lreplace $y  8  8 $to_obs]
            set y [lreplace $y  9  9 $rto]
            set y [lreplace $y 10 10 $oppo]
            set y [lreplace $y 11 11 $err_oppo]
            set y [lreplace $y 12 12 $reo]
            $::bdi_tools_reports::data_newaster_bodies delete $id $id
            $::bdi_tools_reports::data_newaster_bodies insert $id $y
         }

         ::bdi_gui_reports::colorize $id
         update 
         #break
      }

   }






   #------------------------------------------------------------
   ## Construit le fichier d'observation pour un asteroide
   #  @param  id_obj designation de l objet
   #  @return 0 pas d erreur (sinon code erreur avec message) 
   #
   proc ::bdi_gui_reports::fitobs_obs_build { id_obj } {
   
      set file_obs "$id_obj.obs"
      
      file delete -force $file_obs
      set f [open $file_obs w]

      set form "%12s%1s%1s%1s%-17s%-12s%-12s        %6s      %3s"
      # Constant parameters
      # - Note 1: alphabetical publishable note or (those sites that use program codes) an alphanumeric
      #           or non-alphanumeric character program code => http://www.minorplanetcenter.net/iau/info/ObsNote.html
      set note1 " "
      # - C = CCD observations (default)
      set note2 "C"
      set flag " "
      
      foreach id_info $::bdi_tools_reports::tab_newaster($id_obj,index_info) {
         set csv      $::bdi_tools_reports::tab_newaster($id_obj,$id_info,csv)
         set iau_code $::bdi_tools_reports::tab_newaster($id_obj,$id_info,iau_code)
         ::bdi_tools_reports::read_mesure_csv $csv mesure
         
         # transformation au format mpc
         foreach jd $mesure(index_jd) {
            set ra     $mesure($jd,ra)
            set dec    $mesure($jd,dec)
            set mag    $mesure($jd,mag)
            set filtre "L"
            #gren_info "$jd  $ra  $dec  $mag  $filtre \n"

            set object  [::bdi_tools_mpc::convert_name $id_obj]
            set datempc [::bdi_tools_mpc::convert_jd   $jd]
            set ra_hms  [::bdi_tools_mpc::convert_hms  $ra]
            set dec_dms [::bdi_tools_mpc::convert_dms  $dec]
            set magmpc  [::bdi_tools_mpc::convert_mag  $mag $filtre]

            set txt [format $form $object $flag $note1 $note2 $datempc $ra_hms $dec_dms $magmpc $iau_code]
            puts $f $txt

         }

      }
      close $f
   
      if {[file exists $file_obs]} {
         #gren_info "$file_obs created\n"
      } else {
         set msg "$file_obs not exist"
         gren_erreur "$msg\n"
         return -code 1 $msg
      }
      
      return
   }






