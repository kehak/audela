## @file bdi_tools_verif.tcl
#  @brief     M&eacute;thodes d&eacute;&eacute;es &agrave; la verification de la structure des bdd de Bddimages
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_verif.tcl]
#  @endcode

# $Id: bdi_tools_verif.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_tools_verif 
# @brief M&eacute;thodes d&eacute;&eacute;es &agrave; la verification de la structure des bdd de Bddimages
# @pre Requiert bdi_tools_reports, bdi_tools_reports_v0_v1, bdi_tools_xml bdi_tools_config
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_tools_verif {

}

#------------------------------------------------------------
## Retourne la liste des zombis d'une liste
# @param p_l list Liste a analyser
# @param type
# @return Liste fournissant les doublons et le nombre d'occurences
#
proc ::bdi_tools_verif::list_zombis { p_l type} {

   global bddconf

   upvar $p_l l

   set l1 [lsort -ascii $l]
   set lres ""
   array unset tab
   array unset tres

   foreach elem $l1 {
      if {[info exists tab($elem)]} {
         if {[info exists tres($elem)]} {
            incr tres($elem)
         } else {
            set tres($elem) 1
         }
      } else {
         set tab($elem) 1
      }
   }


   set lres ""
   if {[llength [array get tres]]>0} {

      # il y a des zombis
      foreach {file nb} [array get tres] {

         set filename    [file tail    $file]
         set dirfilename [file dirname $file]

         set d "$bddconf(dirbase)/"
         set nbb [string length $d]
         set pos [string first $d $dirfilename]
         if {$pos == 0} {
            set dirfilename [string range $dirfilename $nbb end]
         } else {
            set msg "Impossible d'extraire le repertoire"
            lappend lres [list err ZOMBI reparable no type $type file $file idbddimg Unknown msg $msg]
            continue
         }

         set sqlcmd "SELECT idbddimg,idheader FROM images WHERE filename='$filename' AND dirfilename='$dirfilename';"
         set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            set msg "Impossible d'extraire les infos de la table images"
            lappend lres [list err ZOMBI reparable no type $type file $file idbddimg $idbddimg msg $msg]
            continue
         }

         foreach line $resultsql {
            set idbddimg [lindex $line 0]
            set idheader [lindex $line 1]
            set sqlcmd "SELECT idbddimg FROM images_$idheader WHERE idbddimg=$idbddimg;"
            set err [catch {set resultsql2 [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$err} {
               set msg "Impossible d'extraire les infos de la table images_$idheader"
               lappend lres [list err ZOMBI reparable no type $type file $file idbddimg $idbddimg msg $msg]
               continue
            }
            if {[llength $resultsql2]==0} {
               set line [lindex $resultsql2 0]
               # se repare par la cmd sql : "DELETE FROM images WHERE idbddimg=$idbddimg"
               set msg "Fichier inexistant dans la table images_$idheader"
               lappend lres [list err ZOMBI reparable yes type $type file $file idbddimg $idbddimg msg $msg]
               continue
            }
            if {[llength $resultsql2]>1} {
               set msg "Plusieurs entrees dans table images_$idheader"
               foreach line $resultsql2 {
                  lappend lres [list err ZOMBI reparable no type $type file $file idbddimg $idbddimg msg $msg]
               }
               continue
            }
            continue
         }

      }
   }
   return $lres

}

#------------------------------------------------------------
## Retourne la liste des fichiers solitaires
# @param p_l1 list Liste DISK a analyser
# @param p_l2 list Liste SQL  a analyser
# @param p_l3
# @param type
# @return Liste fournissant les fichiers qui ne sont pas present dans les 2 listes
#
proc ::bdi_tools_verif::diff_list { p_l1 p_l2 p_l3 type } {

   upvar $p_l1 l1
   upvar $p_l2 l2
   upvar $p_l3 l3

   array unset tab
   if {$type == "IMG"}  {set idbddtype idbddimg}
   if {$type == "CATA"} {set idbddtype idbddcata}

   foreach file $l1 {
      set tab($file) SQL
   }
   foreach file $l2 {
      if {[info exists tab($file)]} {
         unset tab($file)
      } else {
         set tab($file) DISK
      }
   }
   array unset tabu
   foreach elem $l3 {
      set tabu([lindex $elem 0],size) [lindex $elem 1]
      set tabu([lindex $elem 0],$idbddtype) [lindex $elem 2]
   }

   set lres ""
   foreach {file loc} [array get tab] {
      switch $loc {
         DISK {
            set msg "Fichier inexistant sur le Disque"
            set rep yes
         }
         SQL {
            set tabu($file,$idbddtype) "Unknown"
            set msg "Fichier inexistant dans la base"
            set rep yes
         }
         default {
            set msg "Erreur inconnue"
            set rep no
         }
      }
      lappend lres [list err DIFF_LIST reparable $rep type $type location $loc file $file $idbddtype $tabu($file,$idbddtype) msg $msg]
   }
   return $lres

}

#------------------------------------------------------------
## Retourne la liste des fichiers dont la taille differe entre le disque et la base
# @param p_list_img_size
# @param type = IMG ou CATA
# @return Liste fournissant les fichiers a mettre a jour dans la base
#
proc ::bdi_tools_verif::diff_size { p_list_img_size type} {

   upvar $p_list_img_size list_img_size

   set lres ""
   if {$type == "IMG"}  {set idbddtype idbddimg}
   if {$type == "CATA"} {set idbddtype idbddcata}

   foreach elem $list_img_size {
      set file    [lindex $elem 0]
      set size_db [lindex $elem 1]
      set idbdd   [lindex $elem 2]

      if {[file exists $file]} {
         set err [catch {set size_disk [file size $file]} msg]
         if {$err}  {
               lappend lres [list err ERR_READ_SIZE reparable no type $type file $file size -1]
         } else {
            if {$size_db != $size_disk} {
               lappend lres [list err ERR_SIZE reparable yes type $type $idbddtype $idbdd file $file size $size_disk ]
            }
         }
      } else {
         lappend lres [list err NOT_EXIST reparable yes type $type $idbddtype $idbdd file $file size -1 ]
      }
   }
   return $lres
}

#------------------------------------------------------------
## Retourne la liste des fichiers erronnes
# c est a dire :
#       filename==""
#       filename est un repertoire
#       size == 0
# @param p_list_size Liste avec taille a analyser
# @param type
# @return Liste fournissant les fichiers a mettre a jour dans la base
#
proc ::bdi_tools_verif::verif_file_structure { p_list_size type } {

   upvar $p_list_size list_size

   set lres ""
   if {$type == "IMG"}  {set idbddtype idbddimg}
   if {$type == "CATA"} {set idbddtype idbddcata}

   foreach elem $list_size {

      set file    [lindex $elem 0]
      set size_db [lindex $elem 1]
      set idbdd   [lindex $elem 2]

      if {$file==""} {
         lappend lres [list err FILENAME_IS_NULL reparable no type $type $idbddtype $idbdd size $size_db file $file]
      }
      if {$size_db==0} {
         lappend lres [list err BAD_SIZE reparable no type $type $idbddtype $idbdd size $size_db file $file]
      }
      if {[file isdirectory $file]} {
         lappend lres [list err IS_DIR reparable no type $type $idbddtype $idbdd size $size_db file $file]
      }
      if {![file exists $file]} {
         lappend lres [list err NOT_EXIST reparable no type $type $idbddtype $idbdd size $size_db file $file]
      }
   }

   return $lres
}

#------------------------------------------------------------
## Retourne la liste des fichiers dont il y a un probleme entre
# la table images et les tables images_x
# @param p_list_img_size Liste de la table images avec taille et idbddimg a analyser
# @param p_list_img_head_sql Liste des tables images_x avec idbddimg et idheader
# @return Liste fournissant les fichiers erronnes
#
proc ::bdi_tools_verif::verif_images_header { p_list_img_size p_list_img_head_sql } {

   upvar $p_list_img_size     list_img_size
   upvar $p_list_img_head_sql list_img_head_sql

   set lres ""
   array unset tfile
   array unset tsize
   array unset thead
   array unset tabid

   foreach elem $list_img_size {
      set fic [lindex $elem 0]
      set siz [lindex $elem 1]
      set ibd [lindex $elem 2]
      set tfile($ibd) $fic
      set tsize($ibd) $siz
      set tabid($ibd) "not in images_x"
   }
   foreach elem $list_img_head_sql {
      set ibd [lindex $elem 0]
      set idh [lindex $elem 1]
      set thead($ibd) $idh
      if {[info exists tabid($ibd)]} {
         unset tabid($ibd)
      } else {
         set tabid($ibd) "not in images"
      }
   }

   set lres ""
   foreach {ibd msg} [array get tabid] {
      set file "unknown"
      set idh  "unknown"
      set tsi  "unknown"
      if {[info exists tfile($ibd)]} {set file $tfile($ibd)}
      if {[info exists thead($ibd)]} {set idh  $thead($ibd)}
      if {[info exists tsize($ibd)]} {set tsi  $tsize($ibd)}
      lappend lres [list err TABLE_HEADER reparable yes type IMG idbddimg $ibd size $tsi file $file msg $msg idheader $idh]
   }
   return $lres
}











#------------------------------------------------------------
## Retourne la liste des fichiers dont il y a un probleme entre
# la table images et les tables images_x
# @return Liste fournissant les fichiers erronnes
#
proc ::bdi_tools_verif::verif_rapport { } {

   global bddconf

   set errbadfile "Fichiers ou repertoires non conformes a la structure des rapports de bddimages.\n"
   append errbadfile "Veuillez deplacer ces fichiers manuellement...\n\n"

   set err [catch {set liste [glob -directory [file join $bddconf(dirreports) ASTROPHOTOM] *]} msg ]
   if {$err} {
      gren_erreur "$msg\n"
      return
   }

   # Recupere la liste des objets
   gren_info "Recupere la liste des objets\n"
   set badfile ""
   set list_objects ""
   foreach i $liste {
      if {[file type $i]=="directory"} {
         #gren_info "[file tail $i]\n"
         lappend list_objects [file tail $i]
      } else {
         if {[file tail $i] == "resume_total.csv" } { continue }
         if {[file tail $i] == "resume_nuitees.csv" } { continue }
         gren_erreur "BadFile:[file tail $i]\n"
         lappend badfile $i
      }
   }

   # Recupere la liste des dates
   gren_info "Recupere la liste des dates\n"
   array unset tab_dates
   array unset tab_obj
   set list_dates ""
   foreach obj $list_objects {
      set dir [file join $bddconf(dirreports) ASTROPHOTOM $obj]
      set err [catch {set liste [glob -directory $dir *]} msg ]
      if {$err==0} {
         foreach i $liste {
            if {[file type $i]=="directory"} {
               #gren_info "[file tail $i]\n"
               set date [file tail $i]

               if { ! [regexp {(\d+)-(\d+)-(\d+)} $date dateiso aa mm jj] } {
                  gren_erreur "BadDirectory:[file tail $i]\n"
                  lappend badfile $i
                  continue
               }
               lappend list_dates $date
               lappend tab_dates($obj) $date
               lappend tab_obj($date) $obj
            } else {
               gren_erreur "BadFile:[file tail $i]\n"
               lappend badfile $i
            }
         }
      }
   }

   if {[llength $badfile]>0} {
      foreach f $badfile {
         append errbadfile "$f\n"
      }
      return -code 1 $errbadfile
   }

   # Recupere la liste des batchs
   gren_info "Recupere la liste des batchs\n"
   foreach obj $list_objects {

      foreach date $tab_dates($obj) {

         set dir [file join $bddconf(dirreports) ASTROPHOTOM $obj $date]
         set err [ catch {set liste [glob -directory $dir *]} msg ]
         if {$err==0} {
            foreach i $liste {

               if {[file type $i]=="directory"} {

                  #gren_info "[file tail $i]\n"

                  switch [file tail $i] {
                     "astrom_txt" -
                     "astrom_mpc" -
                     "astrom_xml" -
                     "photom_txt" -
                     "photom_xml" {
                        return -code 2 "\nAncienne version des rapports detectee.\nLa reparation permettra la mise a jour dans le nouveau format"
                     }
                  }

                  # le repertoire n est pas un batch dans rapports/$obj/$date/
                  if { ! [regexp {Audela_BDI_(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)} [file tail $i] dateiso aa mm jj h m s] } {
                     lappend badfile $i
                     continue
                  }

                  # il ly a un fichier readme dans le repertoire

                  set dir [file join $bddconf(dirreports) ASTROPHOTOM $obj $date [file tail $i]]
                  set err [catch {set liste [glob -directory $dir *readme*]} msg ]
                  if {$err==0} {
                     gren_info "$i\n"
                     return -code 2 "Les fichiers infos sont mal formés, veuillez reparer"
                  }

               } else {
                  # fichier solitaire dans rapports/$obj/$date/
                  gren_erreur "BadFile:[file tail $i]\n"
                  lappend badfile $i
               }

            }
         }

      }

   }

   if {[llength $badfile]>0} {
      foreach f $badfile {
         append errbadfile "$f\n"
      }
      return -code 1 $errbadfile
   }

   return
}




proc ::bdi_tools_verif::verif_header { mode { repar 0 }  } {

   gren_info "mode = $mode\n"
   gren_info "repar = $repar\n"

   set sqlcmd "SELECT * FROM header limit 1000;"
   set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      return -code 6 "Erreur SQL dans la requete sur la table 'header', msg: $msg"
   }
   set nb [llength $data]
   array unset tab
   array unset tab_id
   foreach d $data {

      #gren_info "d = $d\n"
      set r [split $d " "]
      set idh [lindex $r 0]
      set var [lindex $r 1]
      #gren_info "idh var = $idh $var\n"
      if {![info exists tab($idh)]} {set tab($idh) ""}
      lappend tab($idh) $var
      if {[string first "\{" $var]!=-1} {
         gren_info "ERREUR $idh => $var\n"
      }
      gren_info "ERREUR $idh => $var\n"
      set tab_id($idh) 1
   }

   set list_all ""
   foreach { idh y } [array get tab_id] {
      gren_info "idh = $idh"
      lappend list_all $tab($idh)
   }

   set list_all [ lsort $list_all ]
   set nb [llength $list_all]

   set ::bdi_tools_verif::list_all $list_all
   for { set i 0 } {$i < [expr $nb -1] } { incr i } {
      set li [lindex $list_all $i]
      set lj [lindex $list_all [expr $i + 1]]
      foreach vi $li {
         if {[lsearch $lj $vi]==-1} {
            gren_info "l = $i var = $vi not in [expr $i + 1]"
         }
      }
   }

   return
}








#------------------------------------------------------------
## Transforme l ancienne version des rapports dans la nouvelle structure
#  Mais ne renomme pas les fichiers s ils sont anciennement formé
# @param mode
# @return void
#
proc ::bdi_tools_verif::repar_rapport_code_22  { mode } {

   global bddconf

   set err [catch {set liste [glob -directory [file join $bddconf(dirreports) ASTROPHOTOM] *]} msg ]
   if {$err} {
      gren_erreur "$msg\n"
      return
   }

   # Recupere la liste des objets
   set badfile ""
   set list_objects ""
   foreach i $liste {
      if {[file type $i]=="directory"} {
         lappend list_objects [file tail $i]
      }
   }

   # Recupere la liste des dates
   array unset tab_dates
   array unset tab_obj
   set list_dates ""
   foreach obj $list_objects {
      set dir [file join $bddconf(dirreports) ASTROPHOTOM $obj]
      set err [catch { set liste [glob -directory $dir *] } msg ]
      if {$err == 0} {
         foreach i $liste {
            if {[file type $i]=="directory"} {
               set date [file tail $i]
               lappend list_dates $date
               lappend tab_dates($obj) $date
               lappend tab_obj($date) $obj
            }
         }
      }
   }

   # Recupere la liste des batchs
   foreach obj $list_objects {

      foreach date $tab_dates($obj) {

         set dir [file join $bddconf(dirreports) ASTROPHOTOM $obj $date]
         set err [catch { set liste [glob -directory $dir *] } msg ]
         if { $err == 0 } {

            foreach dirbatch $liste {

               # Dans l ancien format c est forcement un readme
               if {[file type $dirbatch]=="file"} {

                  set file [file tail $dirbatch]
                  gren_info "dirbatch = $dirbatch\n"
                  gren_info "file = $file\n"

                  set batch ""
                  if {[::bdi_tools_reports_v0_v1::v0_is_filename $file]} {
                     #gren_info "is old filename\n"
                     set batch [::bdi_tools_reports_v0_v1::v0_get_batch $file]
                  } else {
                     gren_erreur "ATTENTION TODOS $dirbatch\n"
                     continue
                  }
                  #gren_info "batch = $batch\n"

                  set destdir [file join $bddconf(dirreports) ASTROPHOTOM $obj $date $batch]
                  #gren_info "destdir = $destdir\n"

                  # mkdir batch
                  if {![file exists $destdir]} {
                     ::bdi_tools_verif::print_line $mode H3 "Creation du repertoire $destdir"
                     file mkdir $destdir
                  }

                  # deplacement du fichier
                  set dest [file join $destdir $file]
                  catch { file rename -force -- $dirbatch $dest }

                  #gren_erreur "TODO file\n"
                  continue
               }

               if {[file type $dirbatch]=="directory"} {
                  gren_info "dir =  $dirbatch\n"

                  set dirtail [file tail $dirbatch]
                  if {$dirtail == "astrom_xml" || $dirtail == "astrom_txt" || $dirtail == "astrom_mpc" || $dirtail == "photom_txt" || $dirtail == "photom_xml" } {


                     # c est un repertoire batch on continue
                     if { [::bdi_tools_reports::is_batch $dirtail] } {
                        continue
                     }

                     # recherche les fichiers old format dans ce repertoire et les deplace
                     gren_info "*** recherche dans : $dirbatch\n"
                     set err [catch {set dliste [glob -directory $dirbatch *]} msg ]
                     if {$err==0} {
                        foreach d $dliste {

                           gren_info "d : $d\n"
                           set dtail [ file tail $d]
                           gren_info "dtail : $dtail\n"

                           if {[file type $d]=="file"} {

                              # Dans l ancien format c est forcement un readme
                              set batch ""
                              if {[::bdi_tools_reports_v0_v1::v0_is_filename $dtail]} {
                                 set batch [::bdi_tools_reports_v0_v1::v0_get_batch $dtail]
                              } else {
                                 gren_erreur "ATTENTION TODOC $d\n"
                                 continue
                              }
                              #gren_info "batch = $batch\n"

                              set destdir [file join $bddconf(dirreports) ASTROPHOTOM $obj $date $batch]
                              #gren_info "destdir = $destdir\n"

                              # mkdir batch
                              if {![file exists $destdir]} {
                                 ::bdi_tools_verif::print_line $mode H3 "Creation du repertoire $destdir"
                                 file mkdir $destdir
                              }

                              # deplacement du fichier
                              set dest [file join $destdir $dtail]
                              catch { file rename -force -- $dirbatch $dest }
                           } else {
                              gren_erreur "ATTENTION TODO DIR $d\n"
                           }

                        }
                     }

                  }
                  continue

return
               }

             }
          }

          # effacement des anciens repertoires s il sont vides
          set err [catch {set liste [glob -directory $dir *]} msg ]
          if {$err==0} {
             foreach i $liste {
                if {[file type $i]=="directory"} {
                   switch [file tail $i] {
                      "astrom_txt" -
                      "astrom_mpc" -
                      "astrom_xml" -
                      "photom_txt" -
                      "photom_xml" {
                         # a effacer s il est vide
                         set err [catch { file delete $i } msg ]
                         if {$err} {
                            gren_erreur "Erreur dans l'effacement de repertoire :\n"
                            gren_erreur "dir = $i\n"
                            gren_erreur "err = $err\n"
                            gren_erreur "msg = $msg\n"
                            continue
                         }
                      }
                   }

                }
             }
          }

       }

    }

   return
}

#------------------------------------------------------------
## Transforme l ancienne version des rapports en nouveau format
# @param mode
# @return Liste fournissant les fichiers erronnes
#
proc ::bdi_tools_verif::repar_rapport_code_3  { mode } {

   global bddconf

   set err [catch {set liste [glob -directory [file join $bddconf(dirreports) ASTROPHOTOM] *]} msg ]
   if {$err} {
      gren_erreur "$msg\n"
      return
   }

   # Recupere la liste des objets
   set badfile ""
   set list_objects ""
   foreach i $liste {
      if {[file type $i]=="directory"} {
         lappend list_objects [file tail $i]
      }
   }

   # Recupere la liste des dates
   array unset tab_dates
   array unset tab_obj
   set list_dates ""
   foreach obj $list_objects {
      set dir [file join $bddconf(dirreports) ASTROPHOTOM $obj]
      set err [catch { set liste [glob -directory $dir *] } msg ]
      if {$err == 0} {
         foreach i $liste {
            if {[file type $i]=="directory"} {
               set date [file tail $i]
               lappend list_dates $date
               lappend tab_dates($obj) $date
               lappend tab_obj($date) $obj
            }
         }
      }
   }

   # Recupere la liste des batchs
   foreach obj $list_objects {

      foreach date $tab_dates($obj) {

         set dir [file join $bddconf(dirreports) ASTROPHOTOM $obj $date]
         set err [catch { set liste [glob -directory $dir *] } msg ]
         if { $err == 0 } {
            foreach dirbatch $liste {

               if {[file type $dirbatch]=="file"} {

                  set file [file tail $dirbatch]
                  gren_info "$file\n"
                  set batch [::bdi_gui_reports::get_batch $file]
                  set destdir [file join $bddconf(dirreports) ASTROPHOTOM $obj $date $batch]

                  # mkdir batch
                  if {![file exists $destdir]} {
                     ::bdi_tools_verif::print_line $mode H3 "Creation du repertoire $destdir"
                     file mkdir $destdir
                  }

                  # copie des fichiers "info_txt"
                  set dest [file join $destdir $file]
                  catch { file rename -force -- $dirbatch $dest }


                  # copie des fichiers "astrom_txt"
                  set d2  [file join $bddconf(dirreports) ASTROPHOTOM $obj $date "astrom_txt"]
                  set err [ catch { set l2 [glob -directory $d2 *${batch}*] } msg ]
                  if {!$err} {
                     foreach sou $l2 {
                        set dest "[file rootname $sou].astrom.txt"
                        set dest [file join $destdir [file tail $dest]]
                        catch { file rename -force -- $sou $dest }
                     }
                  }

                  # copie des fichiers "astrom_mpc"
                  set d2  [file join $bddconf(dirreports) ASTROPHOTOM $obj $date "astrom_mpc"]
                  set err [ catch { set l2 [glob -directory $d2 *${batch}*] } msg ]
                  if {!$err} {
                     foreach sou $l2 {
                        set dest "[file rootname $sou].astrom.mpc"
                        set dest [file join $destdir [file tail $dest]]
                        catch { file rename -force -- $sou $dest }
                     }
                  }

                  # copie des fichiers "astrom_xml"
                  set d2  [file join $bddconf(dirreports) ASTROPHOTOM $obj $date "astrom_xml"]
                  set err [ catch { set l2 [glob -directory $d2 *${batch}*] } msg ]
                  if {!$err} {
                     foreach sou $l2 {
                        set dest "[file rootname $sou].astrom.xml"
                        set dest [file join $destdir [file tail $dest]]
                        catch { file rename -force -- $sou $dest }
                     }
                  }

                  # copie des fichiers "photom_txt"
                  set d2  [file join $bddconf(dirreports) ASTROPHOTOM $obj $date "photom_txt"]
                  set err [ catch { set l2 [glob -directory $d2 *${batch}*] } msg ]
                  if {!$err} {
                     foreach sou $l2 {
                        set dest "[file rootname $sou].photom.txt"
                        set dest [file join $destdir [file tail $dest]]
                        catch { file rename -force -- $sou $dest }
                     }
                  }

                  # copie des fichiers "photom_xml"
                  set d2  [file join $bddconf(dirreports) ASTROPHOTOM $obj $date "photom_xml"]
                  set err [ catch { set l2 [glob -directory $d2 *${batch}*] } msg ]
                  if {!$err} {
                     foreach sou $l2 {
                        set dest "[file rootname $sou].photom.xml"
                        set dest [file join $destdir [file tail $dest]]
                        catch { file rename -force -- $sou $dest }
                     }
                  }


                  continue
               }

               if {[file type $dirbatch]=="directory"} {

                  # il ly a un fichier readme dans le repertoire
                  set err [catch {set liste [glob -directory $dirbatch *readme*]} msg ]
                  if {$err==0} {
                     foreach d $liste {
                        set rxp {^DateObs\.(.+)\.Obj\.(.+)\.submit\.(.+)\.Batch\.([^\.]+)\.(.+)}
                        set r [regexp -inline -- $rxp [file tail $d]]
                        set date   [lindex $r 1]
                        set obj    [lindex $r 2]
                        set submit [lindex $r 3]
                        set batch  [lindex $r 4]
                        set ext    [lindex $r 5]

                        gren_info "FILE=[file tail $dirbatch]\n"
                        gren_info "BATCH=$batch\n"

                        set newf [::bdi_tools_reports::build_filename $date $obj $submit $batch "info" "txt"]
                        gren_info "newf $newf\n"
                        set newfile [file join $dirbatch $newf]

                        file rename -force -- $d $newfile
                        ::bdi_tools_verif::print_line $mode H3 "Reparation INFO : $newf"

                     }
                  }
               }

            }
         }

         # effacement des anciens repertoires s il sont vides
         set err [catch {set liste [glob -directory $dir *]} msg ]
         if {$err==0} {
            foreach i $liste {
               if {[file type $i]=="directory"} {
                  switch [file tail $i] {
                     "astrom_txt" -
                     "astrom_mpc" -
                     "astrom_xml" -
                     "photom_txt" -
                     "photom_xml" {
                        # a effacer s il est vide
                        set err [catch { file delete $i } msg ]
                        if {$err} {
                           gren_erreur "Erreur dans l'effacement de repertoire :\n"
                           gren_erreur "dir = $i\n"
                           gren_erreur "err = $err\n"
                           gren_erreur "msg = $msg\n"
                           return
                        }
                     }
                  }

               }
            }
         }

      }

   }

   return
}



proc ::bdi_tools_verif::print_line { mode type msg } {

   if { $mode == "GUI" } {

      global reportConsole
      $reportConsole.text insert end " $msg\n" $type
      $reportConsole.text see end
      update

   } else {

      puts $msg

   }

}


proc ::bdi_tools_verif::verif_init { mode } {

   global audace
   global bddconf
   global dbname
   global repar
   global reportConsole


   if {$mode == "GUI"} {

      set dbname $bddconf(dbname)
      catch {$reportConsole.text delete 0.0 end}

   } else {

      set ::tcl_precision 17

      # Config audace
      source [file join $audace(rep_home) audace.ini]

      # Fichier de config XML a charger
      set ::bdi_tools_xml::xmlConfigFile [file join $audace(rep_home) bddimages_ini.xml]
      set bddconf(current_config) [::bdi_tools_config::load_config $dbname]

      source $audace(rep_install)/gui/audace/plugin/tool/bddimages/bddimages_sql.tcl
      ::bddimages_sql::mysql_init

      gren_info "xml_config_is_loaded : $::bdi_tools_xml::is_config_loaded"
      gren_info "mysql_connect        : $::bdi_tools_config::ok_mysql_connect"

      set bddconf(bufno)    $audace(bufNo)
      set bddconf(visuno)   $audace(visuNo)
      set bddconf(rep_plug) [file join $audace(rep_plugin) tool bddimages]
      set bddconf(astroid)  [file join $audace(rep_plugin) tool bddimages utils astroid]
      set bddconf(extension_bdd) ".fits.gz"
      set bddconf(extension_tmp) ".fit"
   }
}


proc ::bdi_tools_verif::verif_all { mode } {

   global bddconf
   global maliste
   global repar
   global dbname

   ::bdi_tools_verif::verif_init $mode

   if {1==0} {
      ::bdi_tools_verif::print_line $mode BODY   "BODY   "
      ::bdi_tools_verif::print_line $mode TITLE  "TITLE  "
      ::bdi_tools_verif::print_line $mode H1     "H1     "
      ::bdi_tools_verif::print_line $mode H2     "H2     "
      ::bdi_tools_verif::print_line $mode H3     "H3     "
      ::bdi_tools_verif::print_line $mode LISTE0 "LISTE0 "
      ::bdi_tools_verif::print_line $mode LISTE1 "LISTE1 "
      ::bdi_tools_verif::print_line $mode GREEN  "GREEN  "
      ::bdi_tools_verif::print_line $mode RED    "RED    "
      ::bdi_tools_verif::print_line $mode OK     "OK     "
      ::bdi_tools_verif::print_line $mode ERROR  "ERROR  "
      ::bdi_tools_verif::print_line $mode ACT0   "ACT0   "
      ::bdi_tools_verif::print_line $mode ACT1   "ACT1   "
      ::bdi_tools_verif::print_line $mode ACTERR "ACTERR "
   }

   ::bdi_tools_verif::print_line $mode TITLE  "VERIFICATION DE LA BASE $dbname"

   if {$repar == 1} { ::bdi_tools_verif::print_line $mode TITLE  "*** MODE REPARATION ***" }

   # Construction des listes
   ::bdi_tools_verif::print_line $mode H1 "\n* Lecture des donnees du disque et de la base..."

   # Recupere la liste des images sur le disque
   set maliste {}
   get_files $bddconf(dirfits) 0
   set err [catch {set maliste [lsort -increasing $maliste]} msg]
   if {$err} {
      ::bdi_tools_verif::print_line $mode ERROR "Erreur liste des images sur le disque"
      return
   }
   set list_img_file $maliste
   ::bdi_tools_verif::print_line $mode H2 "   Nombre de fichiers images = [llength $list_img_file]"

   # Recupere la liste des catas sur le disque
   set maliste {}
   get_files $bddconf(dircata) 0
   set err [catch {set maliste [lsort -increasing $maliste]} msg]
   if {$err} {
      ::bdi_tools_verif::print_line $mode ERROR  "Erreur liste des catas sur le disque"
      return
   }
   set list_cata_file $maliste
   ::bdi_tools_verif::print_line $mode H2 "   Nombre de fichiers catas = [llength $list_cata_file]"

   # Recupere la liste des images sur le serveur sql
   set sqlcmd "SELECT dirfilename,filename,sizefich,idbddimg FROM images;"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      ::bdi_tools_verif::print_line $mode ERROR  "Erreur liste des images sur le serveur sql"
      return
   }
   set list_img_sql ""
   set list_img_size ""
   foreach line $resultsql {
      set dir [lindex $line 0]
      set fic [lindex $line 1]
      set siz [lindex $line 2]
      set ibd [lindex $line 3]
      lappend list_img_sql "$bddconf(dirbase)/$dir/$fic"
      lappend list_img_size [list "$bddconf(dirbase)/$dir/$fic" $siz $ibd]
   }
   ::bdi_tools_verif::print_line $mode H2 "   Nombre d'image dans la base = [llength $list_img_sql]"

   # Recupere la liste des catas sur le serveur sql
   set sqlcmd "SELECT dirfilename,filename,sizefich,idbddcata FROM catas;"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      ::bdi_tools_verif::print_line $mode ERROR  "Erreur liste des catas sur le serveur sql"
      return
   }
   set list_cata_sql ""
   set list_cata_size ""
   foreach line $resultsql {
      set dir [lindex $line 0]
      set fic [lindex $line 1]
      set siz [lindex $line 2]
      set ibd [lindex $line 3]
      lappend list_cata_sql "$bddconf(dirbase)/$dir/$fic"
      lappend list_cata_size [list "$bddconf(dirbase)/$dir/$fic" $siz $ibd]
   }
   ::bdi_tools_verif::print_line $mode H2 "   Nombre de catas dans la base = [llength $list_cata_sql]"

   # Recupere la liste des images sur le serveur sql dans toutes les tables images_x

   set sqlcmd "SELECT DISTINCT idheader FROM images;"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      ::bdi_tools_verif::print_line $mode ERROR  "Erreur liste des header de l table image sur le serveur sql"
      return
   }
   set thead ""
   foreach line $resultsql {
      lappend thead [lindex $line 0]
   }
   ::bdi_tools_verif::print_line $mode H2 "   Nombre de header differents = [llength $thead]"

   set list_img_head_sql ""
   foreach idh $thead {
      set sqlcmd "SELECT idbddimg FROM images_$idh;"
      set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         ::bdi_tools_verif::print_line $mode ERROR  "Erreur liste des id de la table image_$idh sur le serveur sql"
         return
      }
      foreach line $resultsql {
         lappend list_img_head_sql [list [lindex $line 0] $idh]
      }
   }
   ::bdi_tools_verif::print_line $mode H2 "   Nombre d'image dans les tables header = [llength $list_img_head_sql]"


# Zombi SQL ?  (il ne peut pas y avoir de doublons sur disque)
   ::bdi_tools_verif::print_line $mode H1 "\n* Recherche de Zombis dans les images de la base SQL"

   # Zombis IMAGE
   set tt0 [clock clicks -milliseconds]
   set zombis [::bdi_tools_verif::list_zombis list_img_sql IMG]
   if {[llength $zombis] > 0} {
      ::bdi_tools_verif::print_line $mode ERROR  "   ERROR: Il y a [llength $zombis] zombis dans les images de la base SQL"
      foreach elem $zombis {
         array set tab $elem
         ::bdi_tools_verif::print_line $mode LISTE1  "   ERROR \[$tab(err)\] \[$tab(type)\] \[reparable=$tab(reparable)\]"
         ::bdi_tools_verif::print_line $mode LISTE1  "         idbddimg  = $tab(idbddimg)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         file      = $tab(file)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         msg       = $tab(msg)"
      }
   } else {
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      ::bdi_tools_verif::print_line $mode H3 "   OK: Pas de zombis dans les images de la base SQL (in $tt_total sec)"
   }

   if { $repar == 1 &&[llength $zombis]>0} { ::bdi_tools_verif::repar_and_exit $zombis $mode ; return}

   # Doublons CATA
   set tt0 [clock clicks -milliseconds]
   set zombis [::bdi_tools_verif::list_zombis list_cata_sql CATA]
   if {[llength $zombis] > 0} {
      ::bdi_tools_verif::print_line $mode ERROR  "   ERROR: Il y a [llength $zombis] zombis dans les cata de la base SQL"
      foreach elem $zombis {
         array set tab $elem
         ::bdi_tools_verif::print_line $mode LISTE1  "   ERROR \[$tab(err)\] \[$tab(type)\] \[reparable=$tab(reparable)\]"
         ::bdi_tools_verif::print_line $mode LISTE1  "         idbddcata = $tab(idbddcata)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         file      = $tab(file)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         msg       = $tab(msg)"
      }
   } else {
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      ::bdi_tools_verif::print_line $mode H3 "   OK: Pas de zombis dans les catas de la base SQL (in $tt_total sec)"
   }

   if { $repar == 1 &&[llength $zombis]>0} { ::bdi_tools_verif::repar_and_exit $zombis $mode ; return }



# Listes identiques ?

   ::bdi_tools_verif::print_line $mode H1 "\n* Comparaison des listes des fichiers sur disque et dans la base..."

   # Listes IMAGE identiques ?
   set tt0 [clock clicks -milliseconds]
   set diff_list [::bdi_tools_verif::diff_list list_img_file list_img_sql list_img_size IMG]
   if {[llength $diff_list]>0} {
      ::bdi_tools_verif::print_line $mode ERROR  "   ERROR: Les listes d'images sont differentes cela concerne [llength $diff_list] enregistrments"
      foreach elem $diff_list {
         array set tab $elem
         ::bdi_tools_verif::print_line $mode LISTE1  "   ERROR \[$tab(err)\] \[$tab(type)\] \[reparable=$tab(reparable)\]"
         ::bdi_tools_verif::print_line $mode LISTE1  "         idbddimg  = $tab(idbddimg)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         location  = $tab(location)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         file      = $tab(file)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         msg       = $tab(msg)"
      }
   } else {
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      ::bdi_tools_verif::print_line $mode H3 "   OK: Les listes d'images sont identiques (in $tt_total sec)"
   }

   if { $repar == 1 &&[llength $diff_list]>0} { ::bdi_tools_verif::repar_and_exit $diff_list $mode ; return }

   # Listes CATA identiques ?
   set tt0 [clock clicks -milliseconds]
   set diff_list [::bdi_tools_verif::diff_list list_cata_file list_cata_sql list_cata_size CATA]
   if {[llength $diff_list]>0} {
      ::bdi_tools_verif::print_line $mode ERROR  "   ERROR: ERROR: Les listes des cata sont differentes"
      foreach elem $diff_list {
         array set tab $elem
         ::bdi_tools_verif::print_line $mode LISTE1  "   ERROR \[$tab(err)\] \[$tab(type)\] \[reparable=$tab(reparable)\]"
         ::bdi_tools_verif::print_line $mode LISTE1  "         idbddcata = $tab(idbddcata)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         location  = $tab(location)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         file      = $tab(file)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         msg       = $tab(msg)"
      }
   } else {
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      ::bdi_tools_verif::print_line $mode H3 "   OK: Les listes des cata sont identiques (in $tt_total sec)"
   }

   if { $repar == 1 &&[llength $diff_list]>0} { ::bdi_tools_verif::repar_and_exit $diff_list $mode ; return }




# Verifie que la taille des images et cata est identique sur le disque et dans la base SQL

   ::bdi_tools_verif::print_line $mode H1 "\n* Verification de la taille des fichiers"

   # Tailles des IMAGES
   set tt0 [clock clicks -milliseconds]
   set err_size [::bdi_tools_verif::diff_size list_img_size IMG]
   if {[llength $err_size] > 0} {
      ::bdi_tools_verif::print_line $mode ERROR  "   ERROR: Il y a [llength $err_size] images de la base SQL avec une taille erronee"
      foreach elem $err_size {
         array set tab $elem
         ::bdi_tools_verif::print_line $mode LISTE1  "   ERROR \[$tab(err)\] \[$tab(type)\] \[reparable=$tab(reparable)\]"
         ::bdi_tools_verif::print_line $mode LISTE1  "         idbddimg  = $tab(idbddimg)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         file      = $tab(file)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         newsize   = $tab(size)"
      }
   } else {
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      ::bdi_tools_verif::print_line $mode H3 "   OK: Pas d erreur de taille dans les images de la base SQL (in $tt_total sec)"
   }

   if { $repar == 1 &&[llength $err_size]>0} { ::bdi_tools_verif::repar_and_exit $err_size $mode ; return }


   # Tailles des CATA
   set tt0 [clock clicks -milliseconds]
   set err_size [::bdi_tools_verif::diff_size list_cata_size CATA]
   if {[llength $err_size] > 0} {
      ::bdi_tools_verif::print_line $mode ERROR  "   ERROR: Il y a [llength $err_size] catas de la base SQL avec une taille erronee"
      foreach elem $err_size {
         array set tab $elem
         ::bdi_tools_verif::print_line $mode LISTE1  "   ERROR \[$tab(err)\] \[$tab(type)\] \[reparable=$tab(reparable)\]"
         ::bdi_tools_verif::print_line $mode LISTE1  "         idbddcata = $tab(idbddcata)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         file      = $tab(file)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         elem   = $elem"
         ::bdi_tools_verif::print_line $mode LISTE1  "         newsize   = $tab(size)"
      }
   } else {
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      ::bdi_tools_verif::print_line $mode H3 "   OK: Pas d erreur de taille dans les catas de la base SQL (in $tt_total sec)"
   }

   if { $repar == 1 &&[llength $err_size]>0} { ::bdi_tools_verif::repar_and_exit $err_size $mode ; return }

# Verification de la structure des fichiers

   ::bdi_tools_verif::print_line $mode H1 "\n* Verification de la structure des fichiers"

   # Structures des IMAGES
   set tt0 [clock clicks -milliseconds]
   set err_struct [::bdi_tools_verif::verif_file_structure list_img_size IMG]
   if {[llength $err_struct] > 0} {
      ::bdi_tools_verif::print_line $mode ERROR  "   ERROR: Il y a [llength $err_size] images erronees"
      foreach elem $err_struct {
         array set tab $elem
         ::bdi_tools_verif::print_line $mode LISTE1  "   ERROR \[$tab(err)\] \[$tab(type)\] \[reparable=$tab(reparable)\]"
         ::bdi_tools_verif::print_line $mode LISTE1  "         idbddimg  = $tab(idbddimg)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         file      = $tab(file)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         size      = $tab(size)"
      }
   } else {
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      ::bdi_tools_verif::print_line $mode H3 "   OK: Pas d erreur de structure dans les images (in $tt_total sec)"
   }

   if { $repar == 1 &&[llength $err_struct]>0} { ::bdi_tools_verif::repar_and_exit $err_struct $mode ; return }

   # Structures des CATA
   set tt0 [clock clicks -milliseconds]
   set err_struct [::bdi_tools_verif::verif_file_structure list_cata_size CATA]
   if {[llength $err_struct] > 0} {
      ::bdi_tools_verif::print_line $mode ERROR  "   ERROR: Il y a [llength $err_struct] catas errones"
      foreach elem $err_struct {
         array set tab $elem
         ::bdi_tools_verif::print_line $mode LISTE1  "   ERROR \[$tab(err)\] \[$tab(type)\] \[reparable=$tab(reparable)\]"
         ::bdi_tools_verif::print_line $mode LISTE1  "         idbddcata = $tab(idbddcata)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         file      = $tab(file)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         size      = $tab(size)"
      }
   } else {
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      ::bdi_tools_verif::print_line $mode H3 "   OK: Pas d erreur de structure dans les catas (in $tt_total sec)"
   }

   if { $repar == 1 &&[llength $err_struct]>0} { ::bdi_tools_verif::repar_and_exit $err_struct $mode ; return }

# Verification des tables images_header

   ::bdi_tools_verif::print_line $mode H1 "\n* Verification des tables images_header"

   set tt0 [clock clicks -milliseconds]
   set err_imghead [::bdi_tools_verif::verif_images_header list_img_size list_img_head_sql]
   if {[llength $err_imghead] > 0} {
      ::bdi_tools_verif::print_line $mode ERROR  "   ERROR: Il y a [llength $err_imghead] images erronees"
      foreach elem $err_imghead {
         array set tab $elem
         ::bdi_tools_verif::print_line $mode LISTE1  "   ERROR \[$tab(err)\] \[$tab(type)\] \[reparable=$tab(reparable)\]"
         ::bdi_tools_verif::print_line $mode LISTE1  "         idbddimg  = $tab(idbddimg)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         file      = $tab(file)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         size      = $tab(size)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         idheader  = $tab(idheader)"
         ::bdi_tools_verif::print_line $mode LISTE1  "         msg       = $tab(msg)"
      }
   } else {
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      ::bdi_tools_verif::print_line $mode H3 "   OK: Pas d erreur dans les tables images_header (in $tt_total sec)"
   }

   if { $repar == 1 &&[llength $err_imghead]>0} { ::bdi_tools_verif::repar_and_exit $err_imghead $mode ; return }



# Verification de la structure des rapports

   ::bdi_tools_verif::print_line $mode H1 "\n* Verification de la structure des rapports"
   set tt0 [clock clicks -milliseconds]

   set err_rapport [catch {::bdi_tools_reports_v0_v1::is_v0 $mode 0} msg ]
   if {$err_rapport} {
      ::bdi_tools_verif::print_line $mode ERROR  "   ERROR: Stucture du repertoire des rapports :\n$msg"

   } else {
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      ::bdi_tools_verif::print_line $mode H3 "   OK: Pas d erreur dans les rapports (in $tt_total sec)"
   }

   # $err_rapport == 1 si necessite une reparation manuelle
   # $err_rapport > 1  alors une erreur a ete detectee, et reparable automatiquement
   if { $repar == 1 && $err_rapport==2} { ::bdi_tools_reports_v0_v1::is_v0 $mode 1 ; return }




   # TODO




   # verifier la table header

   #      ::bdi_tools_verif::print_line $mode H1 "\n* Verification des header"
   #      set tt0 [clock clicks -milliseconds]
   #      set err_header [catch {::bdi_tools_verif::verif_header $mode 0} msg ]
   #      if {$err_rapport} {
   #         ::bdi_tools_verif::print_line $mode ERROR  "   ERROR: Verification des header :\n$msg"
   #      } else {
   #         set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
   #         ::bdi_tools_verif::print_line $mode H3 "   OK: Pas d erreur dans les header (in $tt_total sec)"
   #      }
   #      if { $repar == 1 && $err_header==1} { ::bdi_tools_verif::verif_header $mode 1 ; return }


   # verifier la table commun




   # Fin
   ::bdi_tools_verif::print_line $mode H1 "\n\n   *** Fin de la verification ***"

}



proc ::bdi_tools_verif::repar_and_exit { err_list mode } {

   global bddconf

   ::bdi_tools_verif::print_line $mode H2 "   REPARATION de [llength $err_list] erreurs"
   set action no
   set cpt 0

   foreach elem $err_list {
      array set tab $elem

      ::bdi_tools_verif::print_line $mode H2 "   REPAR  \[$tab(type)\] err  =$tab(err) reparable=$tab(reparable)"
      ::bdi_tools_verif::print_line $mode H2 "         file =$tab(file)"

      # reparable IMG ZOMBI
      if {$tab(reparable)=="yes" && $tab(type)=="IMG" && $tab(err)=="ZOMBI" } {

         set action yes
         set sqlcmd "DELETE FROM images WHERE idbddimg=$tab(idbddimg);"
         ::bdi_tools_verif::print_line $mode H2 "   REPARATION ZOMBIS : $sqlcmd"
         set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            ::bdi_tools_verif::print_line $mode ERROR "  ERROR : Impossible d'effacer les zombis : $msg"
         } else {
            ::bdi_tools_verif::print_line $mode H3 "  SUCCESS"
         }
         incr cpt
         continue
      }

      # reparable IMG DIFF_LIST DISK
      if { $tab(reparable)=="yes" && \
           $tab(type)=="IMG" && \
           $tab(err)=="DIFF_LIST" && \
           $tab(location)=="DISK"} {

         set action yes
         set sqlcmd "DELETE FROM images WHERE idbddimg=$tab(idbddimg);"
         ::bdi_tools_verif::print_line $mode H2 "   REPARATION  Diff_List: $sqlcmd"
         set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            ::bdi_tools_verif::print_line $mode ERROR "  ERROR : Impossible d'effacer l entree SQL : $msg"
         } else {
            ::bdi_tools_verif::print_line $mode H3 "  SUCCESS"
         }
         incr cpt
         continue
      }

      # reparable IMG DIFF_LIST SQL
      if { $tab(reparable)=="yes" && \
           $tab(type)=="IMG" && \
           $tab(err)=="DIFF_LIST" && \
           $tab(location)=="SQL"} {

         set action yes
         ::bdi_tools_verif::print_line $mode H2 "Deplacement dans $bddconf(dirinco)"
         set err [catch {file rename -force -- $tab(file) $bddconf(dirinco)} msg ]
         if {$err} {
            ::bdi_tools_verif::print_line $mode ERROR "  ERROR - err = $err\cmd = file rename -force -- $tab(file) $bddconf(dirinco)\nmsg = $msg"
         } else {
            ::bdi_tools_verif::print_line $mode H3 "  SUCCESS"
         }
         incr cpt
         continue
      }

      # reparable CATA DIFF_LIST DISK
      if { $tab(reparable)=="yes" && \
           $tab(type)=="CATA" && \
           $tab(err)=="DIFF_LIST" && \
           $tab(location)=="DISK"} {

         set action yes
         set sqlcmd "DELETE FROM catas WHERE idbddcata=$tab(idbddcata);"
         ::bdi_tools_verif::print_line $mode H2 "   REPARATION  Diff_List: $sqlcmd"
         set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            ::bdi_tools_verif::print_line $mode ERROR "  ERROR : Impossible d'effacer l entree SQL : $msg"
         } else {
            ::bdi_tools_verif::print_line $mode H3 "  SUCCESS"
         }
         set sqlcmd "DELETE FROM cataimage WHERE idbddcata=$tab(idbddcata);"
         ::bdi_tools_verif::print_line $mode H2 "   REPARATION  Diff_List: $sqlcmd"
         set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            ::bdi_tools_verif::print_line $mode ERROR "  ERROR : Impossible d'effacer l entree SQL : $msg"
         } else {
            ::bdi_tools_verif::print_line $mode H3 "  SUCCESS"
         }
         incr cpt
         continue
      }

      # reparable CATA DIFF_LIST SQL
      if { $tab(reparable)=="yes" && \
           $tab(type)=="CATA" && \
           $tab(err)=="DIFF_LIST" && \
           $tab(location)=="SQL"} {

         set action yes
         ::bdi_tools_verif::print_line $mode H2 "Deplacement dans $bddconf(dirinco)"
         set err [catch {file rename -force -- $tab(file) $bddconf(dirinco)} msg ]
         if {$err} {
            ::bdi_tools_verif::print_line $mode ERROR "  ERROR - err = $err\cmd = file rename -force -- $tab(file) $bddconf(dirinco)\nmsg = $msg"
         } else {
            ::bdi_tools_verif::print_line $mode H3 "  SUCCESS"
         }
         incr cpt
         continue
      }

      # reparable IMG ERR_SIZE
      if {$tab(reparable)=="yes" && $tab(type)=="IMG" && $tab(err)=="ERR_SIZE" } {

         set action yes
         set sqlcmd "UPDATE images SET sizefich=$tab(size) WHERE idbddimg=$tab(idbddimg);"
         ::bdi_tools_verif::print_line $mode H2 "Mise a jour de la table images"
         set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            ::bdi_tools_verif::print_line $mode ERROR "  ERROR : UPDATE IMAGES - correction sizefich - err = $err\nsql = $sqlcmd\nmsg = $msg"
         } else {
            ::bdi_tools_verif::print_line $mode H3 "  SUCCESS"
         }
         incr cpt
         continue
      }

      # reparable CATA ERR_SIZE
      if {$tab(reparable)=="yes" && $tab(type)=="CATA" && $tab(err)=="ERR_SIZE" } {

         set action yes
         set sqlcmd "UPDATE catas SET sizefich=$tab(size) WHERE idbddcata=$tab(idbddcata);"
         ::bdi_tools_verif::print_line $mode H2 "Mise a jour de la table catas"
         set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            ::bdi_tools_verif::print_line $mode ERROR "  ERROR : UPDATE CATAS - correction sizefich - err = $err\nsql = $sqlcmd\nmsg = $msg"
         } else {
            ::bdi_tools_verif::print_line $mode H3 "  SUCCESS"
         }
         incr cpt
         continue
      }

      # reparable CATA DIFF_LIST DISK
      if { $tab(reparable)=="yes" && \
           $tab(type)=="CATA" && \
           $tab(err)=="NOT_EXIST" } {

         set action yes
         set sqlcmd "DELETE FROM catas WHERE idbddcata=$tab(idbddcata);"
         ::bdi_tools_verif::print_line $mode H2 "   REPARATION  Diff_List: $sqlcmd"
         set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            ::bdi_tools_verif::print_line $mode ERROR "  ERROR : Impossible d'effacer l entree SQL : $msg"
         } else {
            ::bdi_tools_verif::print_line $mode H3 "  SUCCESS"
         }
         set sqlcmd "DELETE FROM cataimage WHERE idbddcata=$tab(idbddcata);"
         ::bdi_tools_verif::print_line $mode H2 "   REPARATION  Diff_List: $sqlcmd"
         set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            ::bdi_tools_verif::print_line $mode ERROR "  ERROR : Impossible d'effacer l entree SQL : $msg"
         } else {
            ::bdi_tools_verif::print_line $mode H3 "  SUCCESS"
         }
         incr cpt
         continue
      }



      # reparable IMG TABLE_HEADER
      if { $tab(reparable)=="yes" && \
           $tab(type)=="IMG" && \
           $tab(err)=="TABLE_HEADER"} {

         if {$tab(file)!="unknown"} {

            ::bdi_tools_verif::print_line $mode H2 "Deplacement dans $bddconf(dirinco)"
            set action yes
            set err [catch {file rename -force -- $tab(file) $bddconf(dirinco)} msg ]
            if {$err} {
               ::bdi_tools_verif::print_line $mode ERROR "  ERROR - err = $err\cmd = file rename -force -- $tab(file) $bddconf(dirinco)\nmsg = $msg"
               continue
            }
            ::bdi_tools_verif::print_line $mode H2  "Effacement dans la base pour idbddimg = $tab(idbddimg)"
            set ident [bddimages_image_identification $tab(idbddimg)]
            bddimages_image_delete_fromsql $ident
            bddimages_image_delete_fromdisk $ident
            incr cpt

         } else {

            set action yes
            set idheader $tab(idheader)
            set idbddimg $tab(idbddimg)

            ::bdi_tools_verif::print_line $mode H2 "Effacement de idbddimg = $idbddimg dans images_$idheader"
            set sqlcmd "DELETE FROM images_$idheader WHERE idbddimg = $idbddimg"
            set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
            if {$err} {
               ::bdi_tools_verif::print_line $mode ERROR "Err = $err Msg=$msg "
               }
            incr cpt

         }
         continue
      }


   }

   if {$action==yes} {
      ::bdi_tools_verif::print_line $mode LISTE1 "*************************************************************************"
      ::bdi_tools_verif::print_line $mode LISTE1 "* UNE ACTION DE REPARATION A ETE EFFECTUE SUR LA BASE. IL FAUT RELANCER *"
      ::bdi_tools_verif::print_line $mode LISTE1 "* LA VERIFICATION JUSQU'A CE QUE TOUTES LES ERREURS SOIENT CORRIGEES    *"
      ::bdi_tools_verif::print_line $mode LISTE1 "*************************************************************************"
   }

   ::bdi_tools_verif::print_line $mode OK "   FIN REPARATION $action : nb done = $cpt"

}
