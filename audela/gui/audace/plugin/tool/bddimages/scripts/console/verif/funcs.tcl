   proc main { } {
     
      global bddconf
      global maliste
      global repar
      global dbname

      main_init

   puts "\n***********************************"
   puts "\n* VERIFICATION DE LA BASE $dbname"
   puts "\n***********************************"


   puts "\n* Lecture des donnees du disque et de la base..."

      # Recupere la liste des images sur le disque
      set maliste {}
      get_files $bddconf(dirfits) 0
      set err [catch {set maliste [lsort -increasing $maliste]} msg]
      if {$err} {
         puts "Erreur liste des images sur le disque"
         return
      }
      set list_img_file $maliste
      puts "list_img_file  = [llength $list_img_file]"

      # Recupere la liste des catas sur le disque
      set maliste {}
      get_files $bddconf(dircata) 0
      set err [catch {set maliste [lsort -increasing $maliste]} msg]
      if {$err} {
         puts "Erreur liste des catas sur le disque"
         return
      }
      set list_cata_file $maliste
      puts "list_cata_file = [llength $list_cata_file]"

      # Recupere la liste des images sur le serveur sql
      set sqlcmd "SELECT dirfilename,filename,sizefich,idbddimg FROM images;"
      set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         puts "Erreur liste des images sur le serveur sql"
         return
      }
      foreach line $resultsql {
         set dir [lindex $line 0]
         set fic [lindex $line 1]
         set siz [lindex $line 2]
         set ibd [lindex $line 3]
         lappend list_img_sql "$bddconf(dirbase)/$dir/$fic"
         lappend list_img_size [list "$bddconf(dirbase)/$dir/$fic" $siz $ibd]
      }
      puts "list_img_sql   = [llength $list_img_sql]"

      # Recupere la liste des catas sur le serveur sql
      set sqlcmd "SELECT dirfilename,filename,sizefich,idbddcata FROM catas;"
      set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         puts "Erreur liste des catas sur le serveur sql"
         return
      }
      foreach line $resultsql {
         set dir [lindex $line 0]
         set fic [lindex $line 1]
         set siz [lindex $line 2]
         set ibd [lindex $line 3]
         lappend list_cata_sql "$bddconf(dirbase)/$dir/$fic"
         lappend list_cata_size [list "$bddconf(dirbase)/$dir/$fic" $siz $ibd]
      }
      puts "list_cata_sql  = [llength $list_cata_sql]"

      # Recupere la liste des images sur le serveur sql dans toutes les tables images_x
      
      set sqlcmd "SELECT DISTINCT idheader FROM images;"
      set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         puts "Erreur liste des header de l table image sur le serveur sql"
         return
      }
      set thead ""
      foreach line $resultsql {
         lappend thead [lindex $line 0]
      }
      puts "nb header different  = [llength $thead]"
      foreach idh $thead {
         set sqlcmd "SELECT idbddimg FROM images_$idh;"
         set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            puts "Erreur liste des id de la table image_$idh sur le serveur sql"
            return
         }
         foreach line $resultsql {
            lappend list_img_head_sql [list [lindex $line 0] $idh]
         }
      }
      puts "list_img_head_sql  = [llength $list_img_head_sql]"
      

   # Zombi SQL ?  (il ne peut pas y avoir de doublons sur disque)
   puts "\n* Recherche de Zombis dans les images de la base SQL"

      # Zombis IMAGE
      set tt0 [clock clicks -milliseconds]
      set zombis [::bdi_tools_verif::list_zombis list_img_sql IMG]
      if {[llength $zombis] > 0} {
         puts "   ERROR: Il y a [llength $zombis] zombis dans les images de la base SQL" 
         foreach elem $zombis {
            array set tab $elem
            puts "   ERROR \[$tab(err)\] \[$tab(type)\] \[reparable=$tab(reparable)\]" 
            puts "         idbddimg  = $tab(idbddimg)" 
            puts "         file      = $tab(file)" 
            puts "         msg       = $tab(msg)" 
         }
      } else {
         puts "   OK: Pas de zombis dans les images de la base SQL"
      }
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      puts "   in $tt_total sec"

      if {$repar == "yes"&&[llength $zombis]>0} { repar_and_exit $zombis }

      # Doublons CATA
      set tt0 [clock clicks -milliseconds]
      set zombis [::bdi_tools_verif::list_zombis list_cata_sql CATA]
      if {[llength $zombis] > 0} {
         puts "   ERROR: Il y a [llength $zombis] zombis dans les cata de la base SQL" 
         foreach elem $zombis {
            array set tab $elem
            puts "   ERROR \[$tab(err)\] \[$tab(type)\] \[reparable=$tab(reparable)\]" 
            puts "         idbddcata = $tab(idbddcata)" 
            puts "         file      = $tab(file)" 
            puts "         msg       = $tab(msg)" 
         }
      } else {
         puts "   OK: Pas de zombis dans les cata de la base SQL"
      }
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      puts "   in $tt_total sec"

      if {$repar == "yes"&&[llength $zombis]>0} { repar_and_exit $zombis }



   # Listes identiques ?
   puts "\n* Comparaison des listes des fichiers sur disque et dans la base..."

      # Listes IMAGE identiques ?
      set tt0 [clock clicks -milliseconds]
      set diff_list [::bdi_tools_verif::diff_list list_img_file list_img_sql list_img_size IMG]
      if {[llength $diff_list]>0} {
         puts "   ERROR: Les listes d'images sont differentes cela concerne [llength $diff_list] enregistrments"
         foreach elem $diff_list {
            array set tab $elem
            puts "   ERROR \[$tab(err)\] \[$tab(type)\] \[reparable=$tab(reparable)\]" 
            puts "         idbddimg  = $tab(idbddimg)" 
            puts "         location  = $tab(location)" 
            puts "         file      = $tab(file)" 
            puts "         msg       = $tab(msg)" 
         }
      } else {
         puts "   OK: Les listes d'images sont identiques"
      }
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      puts "   in $tt_total sec"

      if {$repar == "yes"&&[llength $diff_list]>0} { repar_and_exit $diff_list }

      # Listes CATA identiques ?
      set tt0 [clock clicks -milliseconds]
      set diff_list [::bdi_tools_verif::diff_list list_cata_file list_cata_sql list_cata_size CATA]
      if {[llength $diff_list]>0} {
         puts "   ERROR: Les listes des cata sont differentes"
         foreach elem $diff_list {
            array set tab $elem
            puts "   ERROR \[$tab(err)\] \[$tab(type)\] \[reparable=$tab(reparable)\]" 
            puts "         idbddcata = $tab(idbddcata)" 
            puts "         location  = $tab(location)" 
            puts "         file      = $tab(file)" 
            puts "         msg       = $tab(msg)" 
         }
      } else {
         puts "   OK: Les listes des cata sont identiques"
      }
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      puts "   in $tt_total sec"

      if {$repar == "yes"&&[llength $diff_list]>0} { repar_and_exit $diff_list }




   # Verifie que la taille des images et cata est identique sur le disque et dans la base SQL
   puts "\n* Verification de la taille des fichiers"

      # Tailles des IMAGES
      set tt0 [clock clicks -milliseconds]
      set err_size [::bdi_tools_verif::diff_size list_img_size IMG]
      if {[llength $err_size] > 0} {
         puts "   ERROR: Il y a [llength $err_size] images de la base SQL avec une taille erronee" 
         foreach elem $err_size {
            array set tab $elem
            puts "   ERROR \[$tab(err)\] \[$tab(type)\] \[reparable=$tab(reparable)\]" 
            puts "         idbddimg  = $tab(idbddimg)" 
            puts "         file      = $tab(file)" 
            puts "         newsize   = $tab(size)" 
         }
      } else {
         puts "   OK: Pas d erreur de taille dans les images de la base SQL"
      }
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      puts "   in $tt_total sec"

      if {$repar == "yes"&&[llength $err_size]>0} { repar_and_exit $err_size }


      # Tailles des CATA
      set tt0 [clock clicks -milliseconds]
      set err_size [::bdi_tools_verif::diff_size list_cata_size CATA]
      if {[llength $err_size] > 0} {
         puts "   ERROR: Il y a [llength $err_size] catas de la base SQL avec une taille erronee" 
         foreach elem $err_size {
            array set tab $elem
            puts "   ERROR \[$tab(err)\] \[$tab(type)\] \[reparable=$tab(reparable)\]" 
            puts "         idbddcata = $tab(idbddcata)" 
            puts "         file      = $tab(file)" 
            puts "         newsize   = $tab(size)" 
         }
      } else {
         puts "   OK: Pas d erreur de taille dans les catas de la base SQL"
      }
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      puts "   in $tt_total sec"

      if {$repar == "yes"&&[llength $err_size]>0} { repar_and_exit $err_size }

   # Verification de la structure des fichiers
   puts "\n* Verification de la structure des fichiers"

      # Structures des IMAGES
      set tt0 [clock clicks -milliseconds]
      set err_struct [::bdi_tools_verif::verif_file_structure list_img_size IMG]
      if {[llength $err_struct] > 0} {
         puts "   ERROR: Il y a [llength $err_size] images erronees" 
         foreach elem $err_struct {
            array set tab $elem
            puts "   ERROR \[$tab(err)\] \[$tab(type)\] \[reparable=$tab(reparable)\]" 
            puts "         idbddimg  = $tab(idbddimg)" 
            puts "         file      = $tab(file)" 
            puts "         size      = $tab(size)" 
         }
      } else {
         puts "   OK: Pas d erreur de structure dans les images"
      }
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      puts "   in $tt_total sec"

      if {$repar == "yes"&&[llength $err_struct]>0} { repar_and_exit $err_struct }

      # Structures des CATA
      set tt0 [clock clicks -milliseconds]
      set err_struct [::bdi_tools_verif::verif_file_structure list_cata_size CATA]
      if {[llength $err_struct] > 0} {
         puts "   ERROR: Il y a [llength $err_struct] catas errones" 
         foreach elem $err_struct {
            array set tab $elem
            puts "   ERROR \[$tab(err)\] \[$tab(type)\] \[reparable=$tab(reparable)\]" 
            puts "         idbddcata = $tab(idbddcata)" 
            puts "         file      = $tab(file)" 
            puts "         size      = $tab(size)" 
         }
      } else {
         puts "   OK: Pas d erreur de structure dans les catas"
      }
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      puts "   in $tt_total sec"

      if {$repar == "yes"&&[llength $err_struct]>0} { repar_and_exit $err_struct }

   # Verification des tables images_header
   puts "\n* Verification des tables images_header"

      set tt0 [clock clicks -milliseconds]
      set err_imghead [::bdi_tools_verif::verif_images_header list_img_size list_img_head_sql]
      if {[llength $err_imghead] > 0} {
         puts "   ERROR: Il y a [llength $err_imghead] images erronees" 
         foreach elem $err_imghead {
            array set tab $elem
            puts "   ERROR \[$tab(err)\] \[$tab(type)\] \[reparable=$tab(reparable)\]" 
            puts "         idbddimg  = $tab(idbddimg)" 
            puts "         file      = $tab(file)" 
            puts "         size      = $tab(size)" 
            puts "         idheader  = $tab(idheader)" 
            puts "         msg       = $tab(msg)" 
         }
      } else {
         puts "   OK: Pas d erreur dans les tables images_header"
      }
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      puts "   in $tt_total sec"

      if {$repar == "yes"&&[llength $err_imghead]>0} { repar_and_exit $err_imghead }

   # verifier la table commun

exit


      # Recherche les images de la base SQL qui n'existent pas sur le disque
      puts "\n* Verification des fichiers sur disque"
      set tt0 [clock clicks -milliseconds]
      set ::bdi_tools_status::new_list_imgsql [::bdi_tools_status::list_diff_shift $list_img_file $list_img_sql]
      set res ""
      set nbdir 0
      foreach elem $::bdi_tools_status::new_list_imgsql {
         set isd [file isdirectory $elem]
         if {$isd == 1} {
            incr nbdir
         } else {
            lappend res $elem        
         }
      }
      if {$nbdir > 0} {
         puts "   ERROR: Des images dans la base SQL ne sont pas un fichier mais un repertoire" 
      }
      set ::bdi_tools_status::new_list_imgsql $res 
      if {[llength $::bdi_tools_status::new_list_imgsql] > 0} { 
         set ::bdi_tools_status::err_imgsql "yes"
         puts "   ERROR: Nombre d'images dans la base SQL qui n'existent pas sur le disque = [llength $::bdi_tools_status::new_list_imgsql]" 
      } else {
         set ::bdi_tools_status::err_imgsql "no"
         puts "   Images OK"
      }
      foreach elemsql $::bdi_tools_status::new_list_imgsql {
         puts "      $elemsql"
         bddimages_sauve_fich $elemsql
      }
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      puts "   in $tt_total sec"

      # Recherche les catas de la base SQL qui n'existent pas sur le disque
      set tt0 [clock clicks -milliseconds]
      set ::bdi_tools_status::new_list_catasql [::bdi_tools_status::list_diff_shift $list_cata_file $list_cata_sql]
      set res ""
      set nbdir 0
      foreach elem $::bdi_tools_status::new_list_catasql {
         set isd [file isdirectory $elem]
         if {$isd == 1} {
            incr nbdir
         } else {
            lappend res $elem        
         }
      }
      if {$nbdir > 0} {
         puts "   ERROR: Des catas dans la base SQL ne sont pas un fichier mais un repertoire" 
      }
      set ::bdi_tools_status::new_list_catasql $res 
      if {[llength $::bdi_tools_status::new_list_catasql] > 0} { 
         set ::bdi_tools_status::err_catasql "yes"
         puts "   ERROR: Nombre de catas dans la base SQL qui n'existent pas sur le disque = [llength $::bdi_tools_status::new_list_catasql]" 
      } else {
         set ::bdi_tools_status::err_catasql "no"
         puts "   Cata OK"
      }
      foreach elemsql $::bdi_tools_status::new_list_catasql {
         puts "      $elemsql"
         bddimages_sauve_fich $elemsql
      }
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      puts "   in $tt_total sec"

      # Recherche les images sur le disque qui n'existent pas dans la base SQL
      set tt0 [clock clicks -milliseconds]
      puts "\n* Verification des fichiers dans la base"
      set ::bdi_tools_status::new_list_imgfile [::bdi_tools_status::list_diff_shift $list_img_sql $list_img_file]
      set res ""
      set nbdir 0
      foreach elem $::bdi_tools_status::new_list_imgfile {
         set isd [file isdirectory $elem]
         if {$isd == 1} {
            incr nbdir
         } else {
            lappend res $elem
         }
      }
      if {$nbdir > 0} {
         puts "   ERROR: Des images dans la base SQL ne sont pas un fichier mais un repertoire" 
      }
      set ::bdi_tools_status::new_list_imgfile $res 
      if {[llength $::bdi_tools_status::new_list_imgfile] > 0} { 
         set ::bdi_tools_status::err_imgfile "yes"
         puts "   ERROR: Nombre d'images sur le disque qui n'existent pas dans la base SQL = [llength $::bdi_tools_status::new_list_imgfile]" 
      } else {
         set ::bdi_tools_status::err_imgfile "no"
         puts "   Images OK"
      }
      foreach elemdir $::bdi_tools_status::new_list_imgfile {
         puts "      $elemsql"
         bddimages_sauve_fich $elemdir
      }
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      puts "   in $tt_total sec"

      # Recherche les catas sur le disque qui n'existent pas dans la base SQL
      set tt0 [clock clicks -milliseconds]
      set ::bdi_tools_status::new_list_catafile [::bdi_tools_status::list_diff_shift $list_cata_sql $list_cata_file]
      set res ""
      set nbdir 0
      foreach elem $::bdi_tools_status::new_list_catafile {
         set isd [file isdirectory $elem]
         if {$isd == 1} {
            incr nbdir
         } else {
            lappend res $elem
         }
      }
      if {$nbdir > 0} {
         puts "   ERROR: Des catas dans la base SQL ne sont pas un fichier mais un repertoire" 
      }
      set ::bdi_tools_status::new_list_catafile $res 
      if {[llength $::bdi_tools_status::new_list_catafile] > 0} { 
         set ::bdi_tools_status::err_catafile "yes"
         puts "   ERROR: Nombre de catas sur le disque qui n'existent pas dans la base SQL = [llength $::bdi_tools_status::new_list_catafile]" 
      } else {
         set ::bdi_tools_status::err_catafile "no"
         puts "   Cata OK"
      }
      foreach elemdir $::bdi_tools_status::new_list_catafile {
         puts "      $elemsql"
         bddimages_sauve_fich $elemdir
      }
      set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      puts "   in $tt_total sec"

      # Verification des autres tables de donnees sur le serveur SQL

   }


   proc repar_and_exit { err_list } {
   
      global bddconf
      
      puts "   REPARATION de [llength $err_list] erreurs"
      set action no
      set cpt 0
      
      foreach elem $err_list {
         array set tab $elem

         puts "   REPAR  \[$tab(type)\] err  =$tab(err) reparable=$tab(reparable)" 
         puts "         file =$tab(file)" 
         
         
         # reparable IMG ZOMBI
         if {$tab(reparable)=="yes" && $tab(type)=="IMG" && $tab(err)=="ZOMBI" } {

            set action yes
            set sqlcmd "DELETE FROM images WHERE idbddimg=$tab(idbddimg);"
            puts "   REPARATION ZOMBIS : $sqlcmd"
            set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$err} {
               puts "  ERROR : Impossible d'effacer les zombis : $msg"
            } else {
               puts "  SUCCESS"
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
            puts "   REPARATION  Diff_List: $sqlcmd"
            set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$err} {
               puts "  ERROR : Impossible d'effacer l entree SQL : $msg"
            } else {
               puts "  SUCCESS"
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
            puts "Deplacement dans $bddconf(dirinco)"
            set err [catch {file rename -force -- $tab(file) $bddconf(dirinco)} msg ]
            if {$err} {
               puts  "  ERROR - err = $err\cmd = file rename -force -- $tab(file) $bddconf(dirinco)\nmsg = $msg"
               
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
            puts "   REPARATION  Diff_List: $sqlcmd"
            set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$err} {
               puts "  ERROR : Impossible d'effacer l entree SQL : $msg"
            } else {
               puts "  SUCCESS"
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
            puts "Deplacement dans $bddconf(dirinco)"
            set err [catch {file rename -force -- $tab(file) $bddconf(dirinco)} msg ]
            if {$err} {
               puts  "  ERROR - err = $err\cmd = file rename -force -- $tab(file) $bddconf(dirinco)\nmsg = $msg"
               
            }
            
            incr cpt
            continue
         }

         # reparable CATA ERR_SIZE
         if {$tab(reparable)=="yes" && $tab(type)=="CATA" && $tab(err)=="ERR_SIZE" } {
         
            set action yes
            set sqlcmd "UPDATE catas SET sizefich=$tab(size) WHERE idbddcata=$tab(idbddcata);"
            set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$err} {
               puts  "  ERROR : UPDATE CATAS - correction sizefich - err = $err\nsql = $sqlcmd\nmsg = $msg"
            } else {
                puts "  SUCCESS"
            }
            incr cpt
            continue
         }
         
         # reparable IMG TABLE_HEADER 
         if { $tab(reparable)=="yes" && \
              $tab(type)=="IMG" && \
              $tab(err)=="TABLE_HEADER"} {
         
            set action yes
            puts "Deplacement dans $bddconf(dirinco)"
            set err [catch {file rename -force -- $tab(file) $bddconf(dirinco)} msg ]
            if {$err} {
               puts  "  ERROR - err = $err\cmd = file rename -force -- $tab(file) $bddconf(dirinco)\nmsg = $msg"
               continue
            }
            puts "Effacement dans la base pour idbddimg = $tab(idbddimg)"
            set ident [bddimages_image_identification $tab(idbddimg)]
            bddimages_image_delete_fromsql $ident
            bddimages_image_delete_fromdisk $ident
            
            
            incr cpt
            continue
         }
         

      }
      
      if {$action==yes} {
         puts "*************************************************************************"
         puts "* UNE ACTION DE REPARATION A ETE EFFECTUE SUR LA BASE. IL FAUT RELANCER *"
         puts "* LA VERIFICATION JUSQU'A CE QUE TOUTES LES ERREURS SOIENT CORRIGEES    *"
         puts "*************************************************************************"
         exit
      }

      puts "   FIN REPARATION $action : nb done = $cpt"
      
   }


   proc main_init { } {

      global audace
      global bddconf
      global dbname

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
