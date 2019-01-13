proc main { } {
     
   global bddconf
   global maliste
   global dbname
   global infini waitTime
   global update_header
   global keys2add keys2update keys2delete
   global MAX_TT_KEYS

   main_init

   puts "\n***********************************************************"
   puts "\n* IMPORT DES IMAGES ET CATA DANS LA BASE $dbname"
   puts "\n***********************************************************"

   set stopWork 0
   set stopFile [file join $bddconf(dirtmp) import.stop]

   while {$stopWork == 0} {

      # Arret demande
      if { [file exists $stopFile]} {
         puts "\n[gren_date] *** Arret demande ***"
         file delete $stopFile
         set stopWork 1
         break
      }

      # Recupere la liste des images a importer
      puts "\n[gren_date] Chargement de la liste des images a importer..."
   
      set maliste {}
      get_files $bddconf(dirinco) 0
      set err [catch {set maliste [lsort -increasing $maliste]} msg]
      if {$err != 0} {
         puts "Erreur: impossible d'etablir la liste des images a importer: err=$err ; msg: $msg"
         return
      }
      set list_img $maliste
      puts "=> nombre de fichiers a importer = [llength $list_img]"
   
      # Import des images
      puts "\n[gren_date] Importation des fichiers..."
   
      set count 0
      foreach img $list_img {
   
         set fifo     [info_fichier $img]
         set erreur   [lindex $fifo 0]
         set etat     [lindex $fifo 1]
         set fileimg  [lindex $fifo 2]
         set dateiso  [lindex $fifo 3]
         set site     [lindex $fifo 4]
         set sizefich [lindex $fifo 5]
         set tabkey   [lindex $fifo 6]
         set form     [lindex $fifo 7]

         if {$erreur!=0} {
            puts "\n[gren_date] Fichier $fileimg en erreur numerr=$erreur"
            puts "\n                    ERREUR : $erreur"
            puts "\n                    MSG    : $msg"

            set dirpb $bddconf(direrr)
            createdir_ifnot_exist $dirpb
            set dirpb [file join $bddconf(direrr) "err$erreur"]
            createdir_ifnot_exist $dirpb

            puts "\n                    Deplacement vers le dossier $dirpb"
            set errmove [catch {file rename -force -- $fileimg $dirpb} msg ]

            set errcp [string first "file already exists" $msg]

            if {$errcp>0||$errmove==0} {
               set errdel [catch {file delete $fileimg} msg]
               if {$errdel!=0} {
                  puts "\n[gren_date] effacement de $fileimg impossible <err=$errdel> <msg=$msg>"
               } else {
                  puts "\n[gren_date] Fichier $fileimg supprime"
               }
            }
            continue
         }
         
         switch $form {
            "img"  { set w "de l'image" }
            "cata" { set w "du cata"    }
         }

         puts "\n[gren_date] traitement $w $fileimg ($count / [llength $list_img])"
   
         # Change l'entete de l'image si demande
         if {$update_header == "yes" && $form == "img"} {
   
            set bufno [::buf::create]
            buf$bufno load $fileimg
   
            # Delete keys
            foreach {i del_key} [array get keys2delete] {
   
               if {$del_key == "TTx"} {
                  set del_key "TT"
                  puts "   ... delete key TT1 to TT$MAX_TT_KEYS"
                  for {set i 1} {$i <= $MAX_TT_KEYS} {incr i} {
                     set err [catch {buf$bufno delkwd "$del_key$i"} msg]
                     if {$err != 0} {
                        puts "Erreur d'effacement de la cle $del_key$i: err=$err ; msg: $msg"
                     }
                  }
               } else {
                  puts "   ... delete key $del_key"
                  # verifie si le mot cle debute par HIERARCH, et le supprime
                  if {[string range $del_key 0 7] == "HIERARCH"} {
                     set del_key [string range $del_key 9 end]
                  }
                  set err [catch {buf$bufno delkwd "$del_key"} msg]
                  if {$err != 0} {
                     puts "       => Erreur d'effacement de la cle $del_key: err=$err ; msg: $msg"
                  }
               }
   
            }
   
            # Add keys
            foreach {i add_key} [array get keys2add] {
               puts "   ... add key [lindex $add_key 0]"
               buf$bufno setkwd $add_key
            }
   
            # Update keys
            foreach {i new_key} [array get keys2update] {

               # verifie si le mot cle debute par HIERARCH, et le supprime
               if {[string range [lindex $new_key 0] 0 7] == "HIERARCH"} {
                  set new_key [lreplace $new_key 0 0 [string range [lindex $new_key 0] 9 end]]
               }

               set current_key [buf$bufno getkwd [lindex $new_key 0]]
               if {[string length [lindex $current_key 1]] > 0} {
                  puts "   ... update key [lindex $new_key 0]"
                  if {[string length [lindex $new_key 1]] > 0} {
                     set current_key [lreplace $current_key 1 1 [lindex $new_key 1]]
                  }
                  if {[string length [lindex $new_key 2]] > 0} {
                     set current_key [lreplace $current_key 2 2 [lindex $new_key 2]]
                  }
                  if {[string length [lindex $new_key 3]] > 0} {
                     set current_key [lreplace $current_key 3 3 [lindex $new_key 3]]
                  }
                  if {[string length [lindex $new_key 4]] > 0} {
                     # update key
                     set current_key [lreplace $current_key 4 4 [lindex $new_key 4]]
                  } else {
                     # clean key si composee de caracteres blancs
                     if {[string length [lindex $current_key 4]] > 0 && [string length [string trim [lindex $current_key 4]]] == 0} {
                        set current_key [lreplace $current_key 4 4 ""]
                     }
                  }
                  buf$bufno setkwd $current_key
               } else {
                  # La cle n'existe pas -> on la creee
                  puts "   ... add key [lindex $new_key 0]"
                  buf$bufno setkwd $new_key
               }
            }
   
            # Enregistre les modif dans l'image
            set fichtmpunzip [unzipedfilename $fileimg]
            set filetmp   [file join $::bddconf(dirtmp)  [file tail $fichtmpunzip]]
            set filefinal [file join $::bddconf(dirinco) [file tail $fileimg]]
            createdir_ifnot_exist $bddconf(dirtmp)
            buf$bufno save $filetmp
            lassign [::bdi_tools::gzip $filetmp $filefinal] err msg
            if {$err != 0} {
               puts "Erreur de gzip $filetmp -> $filefinal: err=$err ; msg: $msg"
            }
   
            buf$bufno clear
         }
   
         puts "   ... insertion solo"
         set err [catch {set newid [insertion_solo $fileimg]} msg]
         if {$err != 0} {
            puts "Erreur: insertion impossible du fichier $fileimg: err=$err ; msg: $msg\n"
         }

         incr count

      }
   
      puts "=> nombre de fichiers traites = $count"

      if {$infini == 1} {
         puts "\n[gren_date] Traitement infini, en attente pour [expr $waitTime/1000.0] s"
         after $waitTime
         continue 
      } else {
         set stopWork 1
      }

   }

}


proc main_init { } {

   global audace
   global bddconf
   global dbname

   set ::tcl_precision 17

   # Config audace
   source [file join $audace(rep_home) audace.ini]

   if {$dbname == "?"} {
      ::console::affiche_erreur "Base de donnees inconnue.\n"
      exit
   }

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
