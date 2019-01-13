## @file bdi_tools_status.tcl
#  @brief     Outils de gestion des images et catas dans bddimages
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_status.tcl]
#  @endcode

# $Id: bdi_tools_status.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_tools_status
# @brief Outils de gestion des images et catas dans bddimages
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_tools_status {

   variable err_nbimg

   variable err_imgsql
   variable do_err_imgsql
   variable new_list_imgsql

   variable err_imgfile
   variable do_err_imgfile
   variable new_list_imgfile

   variable err_imgsize
   variable do_err_imgsize
   variable new_list_imgsize

   variable err_nbcata

   variable err_catasql
   variable do_err_catasql
   variable new_list_catasql

   variable err_catafile
   variable do_err_catafile
   variable new_list_catafile

   variable err_catasize
   variable do_err_catasize
   variable new_list_catasize

   variable err_imgnull
   variable do_err_imgnull

   variable err_catanull
   variable do_err_catanull

   variable err_doublon
   variable do_err_doublon
   variable list_doublon

   variable err_img
   variable do_err_img
   variable list_img

   variable err_img_hd
   variable do_err_img_hd
   variable list_img_hd
   
   variable repair_dir

}


#------------------------------------------------------------
## Retourne l'intersection de deux listes
# @param ref list Liste de reference
# @param test list Deuxieme list
# @return Liste representant l'intersection des deux listes
#
proc ::bdi_tools_status::list_diff_shift { ref test }  {

   foreach elemref $ref {
      set new_test ""
      foreach elemtest $test {
         if {$elemref != $elemtest} {lappend new_test $elemtest}
      }
      set test $new_test
   }
   return $test

}


# Impression au choix sur la console de bdi_status ou dans la console d'audela
proc ::bdi_tools_status::echo { chaine {console ""} {tag ""} } {

   set echo2console [expr {[string length $console] > 0 ? 1 : 0}]
   if {$echo2console == 1} {
      $console insert end "$chaine" $tag
   } else {
      gren_info "$chaine"
   }
   update

}


proc ::bdi_tools_status::log { log logfilename } {

   global bddconf

   # log dedie actions verif->repare
   createdir_ifnot_exist $bddconf(dirlog)
   set fichlog "$bddconf(dirlog)/$logfilename"
   catch { 
      set bddfileout [open $fichlog a]
      puts $bddfileout $log
      close $bddfileout 
   }

   # Ajout log bddimages
   bddimages_sauve_fich "Repare verif : $log"

}


proc ::bdi_tools_status::uncheck_do_err { } {

   set ::bdi_tools_status::do_err_imgnull  0
   set ::bdi_tools_status::do_err_catanull 0
   set ::bdi_tools_status::do_err_imgsql   0
   set ::bdi_tools_status::do_err_imgfile  0
   set ::bdi_tools_status::do_err_imgsize  0
   set ::bdi_tools_status::do_err_catasql  0
   set ::bdi_tools_status::do_err_catafile 0
   set ::bdi_tools_status::do_err_catasize 0
   set ::bdi_tools_status::do_err_img      0
   set ::bdi_tools_status::do_err_img_hd   0
   set ::bdi_tools_status::do_err_doublon  0
   return

}


proc ::bdi_tools_status::actionTodo { } {

   if { $::bdi_tools_status::err_imgnull == "yes" || $::bdi_tools_status::err_catanull == "yes" || \
        $::bdi_tools_status::err_imgsql  == "yes" || $::bdi_tools_status::err_imgfile  == "yes" || $::bdi_tools_status::err_imgsize  == "yes" || \
        $::bdi_tools_status::err_catasql == "yes" || $::bdi_tools_status::err_catafile == "yes" || $::bdi_tools_status::err_catasize == "yes" || \
        $::bdi_tools_status::err_img     == "yes" || $::bdi_tools_status::err_img_hd   == "yes" || $::bdi_tools_status::err_doublon  == "yes" } {
      return 1
   } else {
      return 0
   }

}


proc ::bdi_tools_status::actionChecked { } {

   if { $::bdi_tools_status::do_err_imgnull == 1 || $::bdi_tools_status::do_err_catanull == 1 || \
        $::bdi_tools_status::do_err_imgsql  == 1 || $::bdi_tools_status::do_err_imgfile  == 1 || $::bdi_tools_status::do_err_imgsize  == 1 || \
        $::bdi_tools_status::do_err_catasql == 1 || $::bdi_tools_status::do_err_catafile == 1 || $::bdi_tools_status::do_err_catasize == 1 || \
        $::bdi_tools_status::do_err_img     == 1 || $::bdi_tools_status::do_err_img_hd   == 1 || $::bdi_tools_status::do_err_doublon  == 1 } {
      return 1
   } else {
      return 0
   }

}


proc ::bdi_tools_status::get_idbddcata { idimg } {

   set sqlcmd "SELECT idbddcata FROM cataimage where idbddimg = $idimg;"
   set err [catch {set idbddcata [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      return -code 1 "ERROR SQL: ::bdi_tools_status::get_idbddcata: $msg"
   }
   if {$idbddcata == ""} { set idbddcata -1 }
   return $idbddcata

}



proc ::bdi_tools_status::get_img_name { idbddimg } {

   global bddconf

   set sqlcmd "SELECT dirfilename,filename FROM images where idbddimg = $idbddimg;"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      return -code 1 "ERROR SQL: ::bdi_tools_status::get_img_name: $msg"
   }

   set name ""
   if { $resultsql != "" } {
      set dirfilename [lindex $resultsql 0]
      set filename    [lindex $resultsql 1]
      set src         [file join $bddconf(dirfits) $dirfilename $filename]
      set name [list $bddconf(dirfits) $bddconf(dirfits) $dirfilename $src]
   }
   return $name

}



proc ::bdi_tools_status::get_cata_name { idcata } {

   global bddconf

   set sqlcmd "SELECT dirfilename,filename FROM catas where idbddcata = $idcata;"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      return -code 1 "ERROR SQL: ::bdi_tools_status::get_cata_name: $msg"
   }

   set name ""
   if { $resultsql != "" } {
      set dirfilename [lindex $resultsql 0]
      set filename    [lindex $resultsql 1]
      set src         [file join $bddconf(dircata) $dirfilename $filename]
      set name [list $bddconf(dircata) $dirfilename $filename $src]
   }
   return $name

}



# Backup d un fichier quelconque existant sur le disque
proc ::bdi_tools_status::backup_file { name } {

   gren_debug "Copie de $name dans le repertoire incoming\n"

   set base        [lindex $name 0]
   set dirfilename [lindex $name 1]
   set filename    [lindex $name 2]
   set src         [lindex $name 3]
   
   if { [file exists  $src] } {
      set dest [file join $::bdi_tools_status::repair_dir $filename]
      set errmv [catch {[file copy $src $dest]} msg]
      if {$errmv == 1} {
         return -code 0 "Copie ok"
      } else {
         return -code 1 "ERROR: ::bdi_tools_status::backup_file: $msg"
      }
   }

}



# Backup d un fichier cata existant sur le disque
proc ::bdi_tools_status::backup_cata { idbddcata } {

   gren_debug "Sauvegarde du cata $idbddcata\n"

   set err [catch {set name [::bdi_tools_status::get_cata_name $idbddcata]} msg]
   if {$err} {
      gren_erreur "ERROR: ::bdi_tools_status::backup_cata: $msg\n"
      return -code 1
   }

   if { $name != "" } {
      set errbck [catch {::bdi_tools_status::backup_file $name} msg]
      if {$errbck} {
         gren_erreur "$msg\n"
         return -code 1
      }
   }

}



# Backup d un fichier fits existant sur le disque
proc ::bdi_tools_status::backup_img { idbddimg } {

   gren_debug "Sauvegarde de l'image $idbddimg\n"

   # regarde s'il existe un cata
   set err [catch {set idbddcata [::bdi_tools_status::get_idbddcata $idbddimg]} msg]
   if { $idbddcata == -1 } {
      # n existe pas
   } else {
      if {[llength $idbddcata] > 1} {
         foreach id $idbddcata {
            # backup du cata
            gren_debug "... backup_img : backup_cata $id \n"
            ::bdi_tools_status::backup_cata $id
         }
      } else {
         # backup du cata
         gren_debug "... backup_img : backup_cata $idbddcata \n"
         ::bdi_tools_status::backup_cata $idbddcata
      }
   }
   # traite l'image
   set err [catch {set name [::bdi_tools_status::get_img_name $idbddimg]} msg]
   if {$err} {
      gren_erreur "$msg\n"
      return -code 1
   }

   if { $name != "" } {
      set errbck [catch {::bdi_tools_status::backup_file $name} msg]
      if {$errbck} {
         gren_erreur "$msg\n"
         return -code 1
      }
   }

}



# Effacement d un fichier quelconque existant sur le disque
proc ::bdi_tools_status::delete_file { file } {

   if { [file exists $file] } {
      set errmv [catch {[file delete $file]} msg]
      if {$errmv == 1} {
         return -code 0 "Effacement ok"
      } else {
         return -code 1 "ERROR: delete_file: $msg"
      }
   } else {
      return -code 0 "Le fichier n'existe pas"
   }

}



proc ::bdi_tools_status::delete_cata { idcata } {

   gren_debug "Effacement du cata $idcata\n"

   set err [catch {set name [::bdi_tools_status::get_cata_name $idcata]} msg]
   if { $name != "" } {
      set errdel [catch {::bdi_tools_status::delete_file $name} msg]
      if {$errdel} {
         return -code 1 "ERROR: effacement du fichier $name : $msg"
      }
   }

   set sqlcmd "DELETE FROM catas WHERE idbddcata = $idcata;"  
   set err [catch {set line [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      return -code 1 "ERROR SQL: effacement dans la table 'catas': $msg"
   }

   set sqlcmd "DELETE FROM cataimage WHERE idbddcata = $idcata;"  
   set err [catch {set line [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      return -code 1 "ERROR SQL: effacement dans la table 'cataimage': $msg"
   }

}



# Effacement d un fichier image dans la base et sur le disque
proc ::bdi_tools_status::delete_img { idimg } {

   gren_debug "Effacement de l'image $idimg\n"

   # Regarde s il existe un cata, et l'efface
   set err [catch {set idbddcata [::bdi_tools_status::get_idbddcata $idimg]} msg]
   if {$err} {
      ::bdi_tools_status::echo "Error: get_idbddcata: $msg\n" $console ACT1
   } else {
      gren_debug "  -> ok cata idbddcata = $idbddcata \n"
      if { $idbddcata == -1 } {
          # n'existe pas
         gren_debug "  -> ok pas de cata a effacer \n"
      } else {
         foreach id $idbddcata {
            gren_debug "... delete_img : delete_cata $id \n"
            # Effacement du cata
            set errdel [catch {::bdi_tools_status::delete_cata $id} msg]
            if {$errdel} {
               gren_erreur "Error: delete_cata: $msg\n"
            }
         }
      }
   }

   # Effacement de l'image
   set err [catch {set name [::bdi_tools_status::get_img_name $idimg]} msg]
   if {$err} {
      ::bdi_tools_status::echo "Error: get_img_name: $msg\n" $console ACT1
   } else {
      if { $name != "" } {
         set errdel [catch {::bdi_tools_status::delete_file $name} msg]
         if {$errdel} {
            gren_erreur "$msg\n"
         }
      }
   }

   # Mise a jour de la bdd
   set sqlcmd "SELECT idheader FROM images where idbddimg = $idimg;"
   set err [catch {set line [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      return -code 1 "ERROR SQL: Selection de idbddimg = $idimg dans la table 'images'"
   }
   set idheader [lindex $line 0]
   set sqlcmd "DELETE FROM images WHERE idbddimg = $idimg;"  
   set err [catch {set line [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      return -code 1 "ERROR SQL: Effacement de idbddimg = $idimg dans la table 'images'"
   }
   set sqlcmd "DELETE FROM images_$idheader WHERE idbddimg = $idimg;"  
   set err [catch {set line [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      return -code 1 "ERROR SQL: Effacement de idbddimg = $idimg dans la table 'images_$idheader'"
   }

   return -code 0 ""

}


# Test une image ou un cata
# input: f string image or cata filename or id in bddimages
#        t string 'img' (default) or 'cata'
# return code 0 ok
#             1 L'image n'existe pas dans la table 'images'
#             2 L'image existe dans la table 'images' mais n'existe pas sur le disque
#             3 L'image existe dans la table 'images' mais n'existe pas dans la table 'images_idhead'
#             4 Il existe plusieurs occurences de l'image dans la table 'images'
#             5 Le nom de l'image n'est pas coherent avec celui de la table 'images'
#             6 Erreur SQL
proc ::bdi_tools_status::file_is_ok { f {t "img"} } {

   global bddconf

   if {[string is double -strict $f]} {  

      gren_debug "FILE_IS_OK ? id = $f\n"

      if {$t == "img"} {
         set sqlcmd "SELECT filename,dirfilename,sizefich,datemodif,idheader FROM images WHERE idbddimg = $f;"
      } else {
         set sqlcmd "SELECT filename,dirfilename,sizefich,datemodif FROM catas WHERE idbddcata = $f;"
      }
      set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         set msge [expr {$t == "image" ? "Erreur SQL dans la requete sur la table 'catas', msg: $msg" : "Erreur SQL dans la requete sur la table 'catas', msg: $msg"}]
         return -code 6 "$msge"
      }
      set nb [llength $data]
      # Si l'image ou le cata n'est pas dans la table images ou catas ...
      if {$nb == 0} {
         set msge [expr {$t == "image" ? "L'image ($f) n'existe pas dans la table 'images'" : "Le cata ($f) n'existe pas dans la table 'catas'"}]
         return -code 1 "$msge"
      }
      # Sinon
      if {$nb > 1} {
         set msge [expr {$t == "image" ? "Il existe plusieurs occurences ($nb) de l'image dans la table 'images'" : "Il existe plusieurs occurences ($nb) du Cata dans la table 'catas'"}]
         return -code 4 "$msge"
      }
      set line        [lindex $data 0]
      set filename    [lindex $line 0]
      set dirfilename [lindex $line 1]
      if {$t == "img"} {
         set idheader [lindex $line 4]
         # verif images_$idheader
         set sqlcmd "SELECT * FROM images_$idheader where idbddimg = $f;"
         set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            return -code 6 "Erreur SQL dans la requete sur la table 'images_$idheader', msg: $msg"
         }
         set nb [llength $data]
         if {$nb == 0} {
            return -code 1 "L'image ($r.fits.gz) n'existe pas dans la table 'images_$idheader'"
         }
         if {$nb > 1} {
            return -code 4 "Il existe plusieurs occurences ($nb) de l'image dans la table 'images_$idheader'"
         }
      }
      # verif file
      set fname [file join $bddconf(dirbase) $dirfilename $filename]
      if { ! [file exists fname]} {
         set msge [expr {$t == "image" ? "L'image $fname n'existe pas sur le disque" : "Le cata $fname n'existe pas sur le disque"}]
         return -code 2 "$msge"
      }

   } else {

      gren_debug "FILE_IS_OK ? file = $f\n"

      set r [file tail [file rootname [file rootname $f]]]
      if {$t == "img"} {
         set sqlcmd "SELECT idbddimg,filename,dirfilename,sizefich,datemodif,idheader FROM images WHERE filename like '${r}.fits.gz';"
      } else {
         set sqlcmd "SELECT idbddcata,filename,dirfilename,sizefich,datemodif FROM catas WHERE filename like '${r}.xml.gz';"
      }
      set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         set msge [expr {$t == "image" ? "Erreur SQL dans la requete sur la table 'images', msg: $msg" : "Erreur SQL dans la requete sur la table 'catas', msg: $msg"}]
         return -code 6 "$msge"
      }
      # Si l'image ou le cata n'est pas dans la table images ou catas ...
      if {[llength $data] == 0} {
         set msge [expr {$t == "image" ? "L'image ($r.fits.gz) n'existe pas dans la table 'images'" : "Le cata ($r.xml.gz) n'existe pas dans la table 'catas'"}]
         return -code 1 "$msge"
      }
      # Sinon
      set cpt 0
      set pass "no"
      foreach line $data {
         set id          [lindex $line 0]
         set filename    [lindex $line 1]
         set dirfilename [lindex $line 2]
         set sizefich    [lindex $line 3]
         set datemodif   [lindex $line 4]
         set fname [file join $bddconf(dirbase) $dirfilename $filename]
         if {$t == "img"} {
            set idheader [lindex $line 5]
            gren_debug "idbddimg :: image -> $id :: $fname\n"
         } else {
            gren_debug "idbddcata :: cata -> $id :: $fname\n"
         }
         # Si c'est l'image demandee
         if {$fname == $f} {
            incr cpt
            set pass "yes"
            if {! [file exists fname]} {
               set msge [expr {$t == "image" ? "L'image existe dans la table 'images' mais n'existe pas sur le disque" : "Le cata existe dans la table 'catas' mais n'existe pas sur le disque"}]
               return -code 2 "$msge"
            }
            if {$t == "img"} {
               set sqlcmd "SELECT idbddimg FROM images_$idheader where idbddimg = $id;"
               set err [catch {set result [::bddimages_sql::sql query $sqlcmd]} msg]
               if {$err} {
                  return -code 6 "Erreur SQL dans la requete sur la table 'images_$idheader', msg = $msg"
               }
               if {[llength $result] == ""} {
                  return -code 3 "L'image existe dans la table 'images' mais n'existe pas dans la table 'images_$idheader'"
               }
            }
         }
      }
      if {$cpt > 1 } {
         set msge [expr {$t == "image" ? "Il existe plusieurs occurences ($cpt) de l'image dans la table 'images'" : "Il existe plusieurs occurences ($cpt) du cata dans la table 'catas'"}]
         return -code 4 "$msge"
      }
      if {$pass == "no" } {
         set msge [expr {$t == "image" ? "Le nom de l'image n'est pas coherent avec celui de la table 'images'" : "Le nom du cata n'est pas coherent avec celui de la table 'catas'"}]
         return -code 5 "$msge"
      }

   }

   return code 0 "ok"

}



proc ::bdi_tools_status::repare { {console ""} } {
   
   global bddconf
   global getnamenewlist

   if {[file isdirectory $::bdi_tools_status::repair_dir] == 0} {
      set err [catch {file mkdir "$::bdi_tools_status::repair_dir"} msg]
      if {err} {
         gren_erreur "Error: $msg"
         return -code 1
      }
   }

   if { $::bdi_tools_status::err_imgnull == "yes" && $::bdi_tools_status::do_err_imgnull == 1 } {

      ::bdi_tools_status::echo "\n----------------------------------------------------------------\n" $console ACT1
      ::bdi_tools_status::echo "Repare: nettoyage de la base SQL\n" $console ACT1
      ::bdi_tools_status::echo "Action: efface les images de la table 'images' dont le nom du fichier est vide\n" $console ACT1
      ::bdi_tools_status::echo "----------------------------------------------------------------\n" $console ACT1

      set sqlcmd "DELETE FROM images WHERE filename ='';"
      set errdel [catch {set res_null [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$errdel} {
         ::bdi_tools_status::echo "\nERROR SQL: $msg\n" $console ACTERR
         return -code 1
      }
      gren_info "RES_IMG_NULL = $res_null\n"
      ::bdi_tools_status::echo "\nOK, les images dont le champ filename est vide ont ete supprimees\n" $console ACT1

   }

   if { $::bdi_tools_status::err_catanull == "yes" && $::bdi_tools_status::do_err_catanull == 1 } {

      ::bdi_tools_status::echo "\n----------------------------------------------------------------\n" $console ACT1
      ::bdi_tools_status::echo "Repare: nettoyage de la base SQL\n" $console ACT1
      ::bdi_tools_status::echo "Action: efface les catas de la table 'catas' dont le nom du fichier est vide\n" $console ACT1
      ::bdi_tools_status::echo "----------------------------------------------------------------\n" $console ACT1

      set sqlcmd "DELETE FROM catas WHERE filename ='';"
      set errdel [catch {set res_null [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$errdel} {
         ::bdi_tools_status::echo "\nERROR SQL: $msg\n" $console ACTERR
         return -code 1
      }
      gren_info "RES_CATA_NULL = $res_null\n"
      ::bdi_tools_status::echo "\nOK, les catas dont le champ filename est vide ont ete supprimes\n" $console ACT1

   }

   if { $::bdi_tools_status::err_imgsize == "yes" && $::bdi_tools_status::do_err_imgsize == 1} {

      ::bdi_tools_status::echo "\n----------------------------------------------------------------\n" $console ACT1
      ::bdi_tools_status::echo "Repare: [llength $::bdi_tools_status::new_list_imgsize] images dans la base n'ont pas la meme taille sur le disque\n" $console ACT1
      ::bdi_tools_status::echo "Action: Met a jour la taille des images dans la base SQL\n" $console ACT1
      ::bdi_tools_status::echo "----------------------------------------------------------------\n" $console ACT1

      set new_list_imgsize_back $::bdi_tools_status::new_list_imgsize

      foreach elem $::bdi_tools_status::new_list_imgsize {

         set img [lindex $elem 0]
         set siz [lindex $elem 1]
         set ibd [lindex $elem 2]
         set true_size [file size $img]
         ::bdi_tools_status::echo "... Mise a jour de $img ($ibd) dans la base\n" $console ACT1
         ::bdi_tools_status::log "update \"$img\" ($ibd)" "repare_err_imgsize.log"
         set sqlcmd "UPDATE images SET sizefich=$true_size WHERE idbddimg=$ibd;"
         set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            ::bdi_tools_status::echo "Error SQL: msg = $msg\n" $console ACTERR
            return -code 1 "$msg"
         }
         set new_list_imgsize_back [lrange $new_list_imgsize_back 1 end]

      }
      set ::bdi_tools_status::new_list_imgsize $new_list_imgsize_back
      if {[llength $::bdi_tools_status::new_list_imgsize] == 0} {
         ::bdi_tools_status::echo "\nOK, toutes les images ont ete traitees\n" $console ACT1
      } else {
         ::bdi_tools_status::echo "\nNOP, [llength $::bdi_tools_status::new_list_imgsize] images n'ont pas ete traitees\n" $console ACTERR
      }

   }

   if { $::bdi_tools_status::err_catasize == "yes" && $::bdi_tools_status::do_err_catasize == 1} {

      ::bdi_tools_status::echo "\n----------------------------------------------------------------\n" $console ACT1
      ::bdi_tools_status::echo "Repare: [llength $::bdi_tools_status::new_list_catasize] catas dans la base n'ont pas la meme taille sur le disque\n" $console ACT1
      ::bdi_tools_status::echo "Action: Met a jour la taille des catas dans la base SQL\n" $console ACT1
      ::bdi_tools_status::echo "----------------------------------------------------------------\n" $console ACT1

      set new_list_catasize_back $::bdi_tools_status::new_list_catasize

      foreach elem $::bdi_tools_status::new_list_catasize {

         set cata [lindex $elem 0]
         set siz [lindex $elem 1]
         set ibd [lindex $elem 2]
         set true_size [file size $cata]
         ::bdi_tools_status::echo "... Mise a jour de $cata ($ibd) dans la base\n" $console ACT1
         ::bdi_tools_status::log "update \"$cata\" ($ibd)" "repare_err_catasize.log"
         set sqlcmd "UPDATE catas SET sizefich=$true_size WHERE idbddcata=$ibd;"
         set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            ::bdi_tools_status::echo "Error SQL: msg = $msg\n" $console ACTERR
            return -code 1 "$msg"
         }
         set new_list_catasize_back [lrange $new_list_catasize_back 1 end]

      }
      set ::bdi_tools_status::new_list_catasize $new_list_catasize_back
      if {[llength $::bdi_tools_status::new_list_catasize] == 0} {
         ::bdi_tools_status::echo "\nOK, tous les catas ont ete traites\n" $console ACT1
      } else {
         ::bdi_tools_status::echo "\nNOP, [llength $::bdi_tools_status::new_list_catasize] catas n'ont pas ete traitees\n" $console ACTERR
      }

   }

   if { $::bdi_tools_status::err_imgsql == "yes" && $::bdi_tools_status::do_err_imgsql == 1} {

      ::bdi_tools_status::echo "\n----------------------------------------------------------------\n" $console ACT1
      ::bdi_tools_status::echo "Repare: [llength $::bdi_tools_status::new_list_imgsql] images dans la base SQL n'existent par sur le disque\n" $console ACT1
      ::bdi_tools_status::echo "Action: les images sont effacees de la base SQL\n" $console ACT1
      ::bdi_tools_status::echo "----------------------------------------------------------------\n" $console ACT1

      set new_list_imgsql_back $::bdi_tools_status::new_list_imgsql

      foreach elem $::bdi_tools_status::new_list_imgsql {

         # Nom de l'image
         set filename [file tail $elem]

         # Statut de l'image:
         set err [catch {::bdi_tools_status::file_is_ok $elem "img"} msg]
         if {$err == 0} {

            ::bdi_tools_status::echo "... Rien a reparer pour l'image $filename\n" $console ACT1

         } elseif {$err == 2} {

            # L'image existe dans la base mais n'existe pas sur le disque
            # => on efface l'image de la base

            set sqlcmd "SELECT idbddimg,filename,dirfilename FROM images where filename like '$filename';"
            set errsel [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$errsel} {
               ::bdi_tools_status::echo "Error SQL: msg = $msg\n" $console ACTERR
               return -code 1 "$msg"
            }

            set idbddimg [lindex [lindex $data 0] 0]
            ::bdi_tools_status::echo "... Effacement de $filename ($idbddimg) dans la base\n" $console ACT1
            ::bdi_tools_status::log "delete \"$filename\" ($idbddimg)" "repare_err_imgsql.log"
            set err [catch {::bdi_tools_status::delete_img $idbddimg} msg]
            if {$err} {
               ::bdi_tools_status::echo "   -> erreur d'effacement de $filename, msg = $msg\n" $console ACTERR
               ::bdi_tools_status::log "error delete \"$filename\": $msg" "repare_err_imgsql.log"
            }
            set new_list_imgsql_back [lrange $new_list_imgsql_back 1 end]
         }

      }
      set ::bdi_tools_status::new_list_imgsql $new_list_imgsql_back
      if {[llength $::bdi_tools_status::new_list_imgsql] == 0} {
         ::bdi_tools_status::echo "\nOK, toutes les images ont ete traitees\n" $console ACT1
      } else {
         ::bdi_tools_status::echo "\nNOP, [llength $::bdi_tools_status::new_list_imgsql] images n'ont pas ete traitees\n" $console ACTERR
      }

   }

   if { $::bdi_tools_status::err_catasql == "yes" && $::bdi_tools_status::do_err_catasql == 1} {

      ::bdi_tools_status::echo "\n----------------------------------------------------------------\n" $console ACT1
      ::bdi_tools_status::echo "Repare: [llength $::bdi_tools_status::new_list_catasql] catas dans la base SQL n'existent par sur le disque\n" $console ACT1
      ::bdi_tools_status::echo "Action: les catas sont effaces de la base SQL\n" $console ACT1
      ::bdi_tools_status::echo "----------------------------------------------------------------\n" $console ACT1

      set new_list_catasql_back $::bdi_tools_status::new_list_catasql

      foreach elem $::bdi_tools_status::new_list_catasql {

         # Nom de l'image
         set filename [file tail $elem]

         # Statut de l'image:
         set err [catch {::bdi_tools_status::file_is_ok $elem "cata"} msg]
         if {$err == 0} {

            ::bdi_tools_status::echo "... Rien a reparer pour l'image $filename\n" $console ACT1

         } elseif {$err == 2} {

            # Le cata existe dans la base mais n'existe pas sur le disque
            # => on efface le cata de la base

            set sqlcmd "SELECT idbddcata,filename,dirfilename FROM catas where filename like '$filename';"
            set errsel [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$errsel} {
               ::bdi_tools_status::echo "Error SQL: msg = $msg\n" $console ACTERR
               return -code 1 "$msg"
            }

            set idbddcata [lindex [lindex $data 0] 0]
            ::bdi_tools_status::echo "... Effacement de $filename ($idbddcata) dans la base\n" $console ACT1
            ::bdi_tools_status::log "delete \"$filename\" ($idbddcata)" "repare_err_catasql.log"
            set err [catch {::bdi_tools_status::delete_cata $idbddcata} msg]
            if {$err} {
               ::bdi_tools_status::echo "   -> erreur d'effacement de $filename, msg = $msg\n" $console ACTERR
               ::bdi_tools_status::log "error delete \"$filename\": $msg" "repare_err_catasql.log"
            }
            set new_list_catasql_back [lrange $new_list_catasql_back 1 end]
         }

      }
      set ::bdi_tools_status::new_list_catasql $new_list_catasql_back
      if {[llength $::bdi_tools_status::new_list_catasql] == 0} {
         ::bdi_tools_status::echo "\nOK, tous les catas ont ete traites\n" $console ACT1
      } else {
         ::bdi_tools_status::echo "\nNOP, [llength $::bdi_tools_status::new_list_catasql] catas n'ont pas ete traites\n" $console ACTERR
      }

   }

   if { $::bdi_tools_status::err_imgfile == "yes" && $::bdi_tools_status::do_err_imgfile == 1 } {

      ::bdi_tools_status::echo "\n----------------------------------------------------------------\n" $console ACT1
      ::bdi_tools_status::echo "Repare: [llength $::bdi_tools_status::new_list_imgfile] images sur le disque n'existent pas dans la base SQL \n" $console ACT1
      ::bdi_tools_status::echo "Action: les images sont deplacees dans le repertoire $::bdi_tools_status::repair_dir\n" $console ACT1
      ::bdi_tools_status::echo "----------------------------------------------------------------\n" $console ACT1

      set new_list_imgfile_back $::bdi_tools_status::new_list_imgfile

      foreach elem $::bdi_tools_status::new_list_imgfile {

         # Statut de l'image:
         set err [catch {::bdi_tools_status::file_is_ok $elem "img"} msg]
         if {$err == 0} {

            ::bdi_tools_status::echo "... Rien a reparer pour l'image $elem\n" $console ACT1

         } elseif {$err == 1} {

            # L'image n'existe pas dans la base mais existe sur le disque
            # => on deplace l'image dans incoming pour re-insertion A FAIRE par l'utilisateur

            set f [file tail $elem]
            set dest [file join $::bdi_tools_status::repair_dir $f]
            ::bdi_tools_status::echo "... Deplacement de $elem vers $dest\n" $console ACT1
            if {[file exists $dest] == 1} {
               ::bdi_tools_status::echo "   -> le fichier destination existe deja!\n" $console ACT1
               catch {set size1 [file size $elem]}
               catch {set size2 [file size $dest]}
               if {$size1 == $size2} {
                  set errdel [catch {[file delete $elem]} msg]
                  if {$errdel == 1} {
                     # Elimine l'image traitee de la liste
                     ::bdi_tools_status::log "delete_from_disk \"$elem\"" "repare_err_imgfile.log"
                     set new_list_imgfile_back [lrange $new_list_imgfile_back 1 end]
                  } else {
                     ::bdi_tools_status::echo "   -> erreur d'effacement de $elem : err = $errdel ; msg = $msg\n" $console ACTERR
                     ::bdi_tools_status::log "error delete \"$elem\"" "repare_err_imgfile.log"
                  }
               } else {
                  ::bdi_tools_status::echo "   -> les fichiers sont differents : $elem ($size1 octets) :: $dest ($size2 octets)\n" $console ACTERR
                  ::bdi_tools_status::echo "   -> deplacement annule\n" $console ACTERR
                  ::bdi_tools_status::log "error distinct \"$elem\" \"$dest\"" "repare_err_imgfile.log"
               }
            } else {
               set errmv [catch {[file rename -force -- $elem $dest]} msg]
               if {$errmv == 1} {
                  # Elimine l'image traitee de la liste
                 ::bdi_tools_status::log "rename \"$elem\" \"$dest\"" "repare_err_imgfile.log"
                  set new_list_imgfile_back [lrange $new_list_imgfile_back 1 end]
               } else {
                  ::bdi_tools_status::echo "   -> erreur de deplacement de $elem vers $dest, msg = $msg\n" $console ACTERR
                  ::bdi_tools_status::log "error rename \"$elem\" \"$dest\"" "repare_err_imgfile.log"
               }
            }

         }
      }
      set ::bdi_tools_status::new_list_imgfile $new_list_imgfile_back
      if {[llength $::bdi_tools_status::new_list_imgfile] == 0} {
         ::bdi_tools_status::echo "\nOK, toutes les images ont ete traitees\n" $console ACT1
      } else {
         ::bdi_tools_status::echo "\nNOP, [llength $::bdi_tools_status::new_list_imgfile] images n'ont pas ete traitees\n" $console ACTERR
      }

   }

   if { $::bdi_tools_status::err_catafile == "yes" && $::bdi_tools_status::do_err_catafile == 1 } {

      ::bdi_tools_status::echo "\n----------------------------------------------------------------\n" $console ACT1
      ::bdi_tools_status::echo "Repare: [llength $::bdi_tools_status::new_list_catafile] catas sur le disque n'existent pas dans la base SQL \n" $console ACT1
      ::bdi_tools_status::echo "Action: les catas sont deplaces dans le repertoire $::bdi_tools_status::repair_dir\n" $console ACT1
      ::bdi_tools_status::echo "----------------------------------------------------------------\n" $console ACT1

      set new_list_catafile_back $::bdi_tools_status::new_list_catafile

      foreach elem $::bdi_tools_status::new_list_catafile {

         # Statut de l'image:
         set err [catch {::bdi_tools_status::file_is_ok $elem "cata"} msg]
         if {$err == 0} {

            ::bdi_tools_status::echo "... Rien a reparer pour le cata $elem\n" $console ACT1

         } elseif {$err == 1} {

            # Le cata n'existe pas dans la base mais existe sur le disque
            # => on deplace le cata dans incoming pour re-insertion A FAIRE par l'utilisateur

            set f [file tail $elem]
            set dest [file join $::bdi_tools_status::repair_dir $f]
            ::bdi_tools_status::echo "... Deplacement de $elem vers $dest\n" $console ACT1
            if {[file exists $dest] == 1} {
               ::bdi_tools_status::echo "   -> le fichier destination existe deja!\n" $console ACT1
               catch {set size1 [file size $elem]}
               catch {set size2 [file size $dest]}
               if {$size1 == $size2} {
                  set errdel [catch {[file delete $elem]} msg]
                  if {$errdel == 1} {
                     # Elimine l'image traitee de la liste
                     ::bdi_tools_status::log "delete_from_disk \"$elem\"" "repare_err_catafile.log"
                     set new_list_catafile_back [lrange $new_list_catafile_back 1 end]
                  } else {
                     ::bdi_tools_status::echo "   -> erreur d'effacement de $elem : err = $errdel ; msg = $msg\n" $console ACTERR
                     ::bdi_tools_status::log "error delete \"$elem\"" "repare_err_catafile.log"
                  }
               } else {
                  ::bdi_tools_status::echo "   -> les fichiers sont differents : $elem ($size1 octets) :: $dest ($size2 octets)\n" $console ACTERR
                  ::bdi_tools_status::echo "   -> deplacement annule\n" $console ACTERR
                  ::bdi_tools_status::log "error distinct \"$elem\" \"$dest\"" "repare_err_catafile.log"
               }
            } else {
               set errmv [catch {[file rename -force -- $elem $dest]} msg]
               if {$errmv == 1} {
                  # Elimine l'image traitee de la liste
                 ::bdi_tools_status::log "rename \"$elem\" \"$dest\"" "repare_err_catafile.log"
                  set new_list_catafile_back [lrange $new_list_catafile_back 1 end]
               } else {
                  ::bdi_tools_status::echo "   -> erreur de deplacement de $elem vers $dest, msg = $msg\n" $console ACTERR
                  ::bdi_tools_status::log "error rename \"$elem\" \"$dest\"" "repare_err_catafile.log"
               }
            }

         }
      }
      set ::bdi_tools_status::new_list_catafile $new_list_catafile_back
      if {[llength $::bdi_tools_status::new_list_catafile] == 0} {
         ::bdi_tools_status::echo "\nOK, tous les catas ont ete traites\n" $console ACT1
      } else {
         ::bdi_tools_status::echo "\nNOP, [llength $::bdi_tools_status::new_list_catafile] catas n'ont pas ete traites\n" $console ACTERR
      }

   }

   if { $::bdi_tools_status::err_img == "yes" && $::bdi_tools_status::do_err_img == 1 } {

      ::bdi_tools_status::echo "\n----------------------------------------------------------------\n" $console ACT1
      ::bdi_tools_status::echo "Repare: [llength $::bdi_tools_status::list_img] images dans la base SQL n'ont pas d'entete\n" $console ACT1
      ::bdi_tools_status::echo "Action: TODO\n" $console ACT1
      ::bdi_tools_status::echo "----------------------------------------------------------------\n" $console ACT1

      #foreach elem $::bdi_tools_status::list_img {
      #   ::console::affiche_resultat "($elem)\n"
      #    set isd [file isdirectory $elem]
      #    set isf [file isfile $elem]
      #    #::console::affiche_resultat "$isd $isf $elem \n"
      #    if {$isd == 1} {
      #       ::console::affiche_erreur "repertoire : $elem \n"
      #       continue
      #    } else {
      #       if {$isf == 1} {
      #          ::console::affiche_resultat "file ($elem)\n"
      #       }
      #    }
      #}
      #::console::affiche_resultat "NB IMG : [llength $::bdi_tools_status::list_img]\n"
      #::console::affiche_resultat "LIST IMG : PROCEDE  \n"
      #
      #foreach elem $::bdi_tools_status::list_img {
      #   ::console::affiche_resultat "*** SQL:($elem) is_ok ? -> \n"
      #   set err [catch {::bdi_tools_status::file_is_ok $elem "img"} msg]
      #   ::console::affiche_resultat "*** ($elem) is_ok ! (err $err msg $msg)\n"
      #
      #   if {$err} {
      #      # Backup
      #      ::bdi_tools_status::backup_img $elem
      #      # Delete
      #      ::bdi_tools_status::delete_img $elem
      #   }
      #   #set ::bdi_tools_status::list_img [lrange $::bdi_tools_status::list_img 1 end]
      #   #break
      #}

   }


   if { $::bdi_tools_status::err_img_hd == "yes" && $::bdi_tools_status::do_err_img_hd == 1 } {

      ::bdi_tools_status::echo "\n----------------------------------------------------------------\n" $console ACT1
      ::bdi_tools_status::echo "Repare: [llength $::bdi_tools_status::list_img_hd] entetes ne correspondent pas a une image\n" $console ACT1
      ::bdi_tools_status::echo "Action: TODO\n" $console ACT1
      ::bdi_tools_status::echo "----------------------------------------------------------------\n" $console ACT1

      #foreach elem $::bdi_tools_status::list_img_hd {
      #   ::console::affiche_resultat "($elem)\n"
      #   set isd [file isdirectory $elem]
      #   set isf [file isfile $elem]
      #   #::console::affiche_resultat "$isd $isf $elem \n"
      #   if {$isd == 1} {
      #      ::console::affiche_erreur "repertoire : $elem \n"
      #      continue
      #   } else {
      #      if {$isf == 1} {
      #         ::console::affiche_resultat "file ($elem)\n"
      #      }
      #   }
      #}
      #
      #foreach elem $::bdi_tools_status::list_img_hd {
      #   ::console::affiche_resultat "*** SQL:($elem) is_ok ? -> \n"
      #   set err [catch {::bdi_tools_status::file_is_ok $elem "img"} msg]
      #   ::console::affiche_resultat "*** ($elem) is_ok ! (err $err msg $msg)\n"
      #
      #   if {$err} {
      #      set sqlcmd "SELECT DISTINCT idheader FROM header;"
      #      set errsel [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
      #      if {$errsel} {
      #         tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
      #         return
      #      }
      #      if {$errsel==1 || $data==""} {
      #         ::console::affiche_erreur "pas de header ($errsel) ($msg) ($data)\n"
      #      }
      #      if {$data!=""} {
      #         foreach idhd $data {
      #            set sqlcmd "DELETE FROM images_$idhd where idbddimg = $elem;"
      #            set errdel [catch {::bddimages_sql::sql query $sqlcmd} msg]
      #            if {$errdel} {
      #               tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
      #               return
      #            }
      #         }
      #      }
      #   }
      #   #set ::bdi_tools_status::list_img [lrange $::bdi_tools_status::list_img 1 end]
      #   #break
      #}

   }


   if { $::bdi_tools_status::err_doublon == "yes" && $::bdi_tools_status::do_err_doublon == 1 } {

      ::bdi_tools_status::echo "\n----------------------------------------------------------------\n" $console ACT1
      ::bdi_tools_status::echo "Repare: [llength $::bdi_tools_status::list_doublon] doublons dans la base SQL\n" $console ACT1
      ::bdi_tools_status::echo "Action: creation d'une liste normale 'doublons' contenant les doublons\n" $console ACT1
      ::bdi_tools_status::echo "----------------------------------------------------------------\n" $console ACT1

      # Creation d'une liste normale dediee aux doublons (si elle n'existe pas deja)
      if {[::bddimages_liste_gui::get_intellilist_by_name "doublons"] < 0} {
         ::bdi_tools_status::echo "... creation de la liste normale \"doublons\"\n" $console ACT1
         set getnamenewlist(result) 1
         set getnamenewlist(name) "doublons"
         ::bddimages_liste_gui::build_normallist
      } else {
         # purge la liste existante
         ::bdi_tools_status::echo "... purge de la liste normale \"doublons\"\n" $console ACT1
         set nlistnum [::bddimages_liste_gui::get_intellilist_by_name "doublons"]
         set ::intellilisttotal($nlistnum) [::bddimages_liste_gui::purge_normallist $::intellilisttotal($nlistnum)]
      }

      set nlistnum [::bddimages_liste_gui::get_intellilist_by_name "doublons"]
      set list_doublon_back $::bdi_tools_status::list_doublon

      # Association des doublons a la liste normale
      foreach doublon $::bdi_tools_status::list_doublon {
         ::bdi_tools_status::echo "... traitement de l'image en doublon $doublon \n" $console ACT1

         # Selection des doublons dans la bdd
         set f [file tail $doublon]
         set r [file tail [file rootname [file rootname $doublon]]]
         set sqlcmd "SELECT idbddimg,filename,dirfilename FROM images where filename like '${r}.fits.gz';"
         set errsel [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$errsel} {
            tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
            return
         }

         # Construction de la liste des idbddimg des doublons
         set lid {}
         foreach d $data {
            lappend lid [lindex $d 0]
         }

         # Ajout des doublons dans la liste normale
         set normallist $::intellilisttotal($nlistnum)
         set ::intellilisttotal($nlistnum) [::bddimages_liste_gui::add_to_normallist 0 $normallist $lid]
         set normallist $::intellilisttotal($nlistnum)
         ::bdi_tools_status::echo "    ... ajout de $lid dans la liste \"doublons\"\n" $console ACT1
         set list_doublon_back [lrange $list_doublon_back 1 end]
      }
gren_info "APRES normalist = $normallist\n"

      ::bddimages_liste_gui::conf_save_intellilists

      set ::bdi_tools_status::list_doublon $list_doublon_back
      if {[llength $::bdi_tools_status::list_doublon] == 0} {
         ::bdi_tools_status::echo "\nOK, tous les doublons ont ete traites\n" $console ACT1
      } else {
         ::bdi_tools_status::echo "\nNOP, [llength $::bdi_tools_status::list_doublon] doublons n'ont pas ete traites\n" $console ACTERR
      }

   }

}
