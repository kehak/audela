proc main { } {
     
   global bddconf
   global dbname destdir
   global mysqlrootname mysqlrootpasswd

   main_init

   puts "\n******************************************************"
   puts "\n* CREATION DE LA BASE DE DONNEES IMAGES $dbname"
   puts "\n******************************************************"

   puts "\nCreation de la config XML de la nouvelle base ..."
   # Ajoute une config XML
   ::bdi_tools_xml::add_config $dbname $destdir
   # Defini la structure de la config courante a partir des champs de saisie
   set bddconf(default_config) $dbname
   ::bdi_tools_xml::set_config $dbname
   # Enregistre la config XML
   ::bdi_tools_xml::save_xml_config 

   # Creation de la BDD
   puts "\nCreation de la base de donnees images $dbname ..."
   set status "ok"
   if { [catch {::mysql::connect -host $bddconf(server) -user $mysqlrootname -password $mysqlrootpasswd} dblink] != 0 } {
      puts "$dblink\n"
      set status "Error: $dblink"
   } else {
      # Drop de la base
      if {$status == "ok"} {
         set sqlcmd "DROP DATABASE IF EXISTS $bddconf(dbname);"
         set err [catch {::mysql::query $dblink $sqlcmd} msg]
         if {$err} {
            set status "Failed : \n <$sqlcmd> \n <$err> \n <$msg>"
         }
      }
      # Creation de la base
      if {$status == "ok"} {
         set sqlcmd "CREATE DATABASE IF NOT EXISTS $bddconf(dbname);"
         set err [catch {::mysql::query $dblink $sqlcmd} msg]
         if {$err} {
            set status "Failed : \n <$sqlcmd> \n <$err> \n <$msg>"
         }
      }
      # Selection de la base mysql
      if {$status == "ok"} {
         set sqlcmd "USE mysql;"
         set err [catch {::mysql::query $dblink $sqlcmd} msg]
         if {$err} {
            set status "Failed : cannot select mysql database (err=<$err>; msg=<$msg>"
         }
      }
      # Droits sur la base (cree le user s'il n'existe pas)
      if {$status == "ok"} {
         set sqlcmd "GRANT ALL PRIVILEGES ON `$bddconf(dbname)`.* TO '$bddconf(login)'@'$bddconf(server)' IDENTIFIED BY '$bddconf(pass)' WITH GRANT OPTION;"
         set err [catch {::mysql::query $dblink $sqlcmd} msg]
         if {$err} {
            set status "Failed : \n <$sqlcmd> \n <$err> \n <$msg>"
         }
      }
      # Creation des tables (vides) de la base
      if {$status == "ok"} {
         set sqlcmd "USE $bddconf(dbname);"
         set err [catch {::mysql::query $dblink $sqlcmd} msg]
         if {$err} {
            set status "Failed : cannot connect to $bddconf(dbname) database (err=<$err>; msg=<$msg>"
         } else {
            set err [::bddimagesAdmin::create_tables $dblink]
            if {$err>0} {
               set status "Failed : cannot create one or more tables into de database"
            }
         }
      }
      # Fermeture connection
      ::mysql::close $dblink
      unset dblink
   }


   puts "Creation des repertoires de la base ..."
   # Creation du repertoire fits
   puts "  - repertoire $bddconf(dirfits)"
   set err [catch {file delete -force $bddconf(dirfits)} msg]
   if {$err == 0} {
      set err [catch {file mkdir $bddconf(dirfits)} msg]
      if {$err != 0} {
         puts "ERREUR: Creation du repertoire : $bddconf(dirfits) impossible <$err>"
      }
   } else {
      puts "ERREUR: Effacement du repertoire : $bddconf(dirfits) impossible <$err>"
   }
   
   # Creation du repertoire logs
   puts "  - repertoire $bddconf(dirlog)"
   set err [catch {file delete -force $bddconf(dirlog)} msg]
   if {$err == 0} {
      set err [catch {file mkdir $bddconf(dirlog)} msg]
      if {$err != 0} {
         puts "ERREUR: Creation du repertoire : $bddconf(dirlog) impossible <$err>"
      }
   } else {
      puts "ERREUR: Effacement du repertoire : $bddconf(dirlog) impossible <$err>"
   }
   
   # Creation du repertoire error
   puts "  - repertoire $bddconf(direrr)"
   set err [catch {file delete -force $bddconf(direrr)} msg]
   if {$err == 0} {
      set err [catch {file mkdir $bddconf(direrr)} msg]
      if {$err != 0} {
         puts "ERREUR: Creation du repertoire : $bddconf(direrr) impossible <$err>"
      }
   } else {
      puts "ERREUR: Effacement du repertoire : $bddconf(direrr) impossible <$err>"
   }

   # Creation du repertoire incoming
   puts "  - repertoire $bddconf(dirinco)"
   set err [catch {file delete -force $bddconf(dirinco)} msg]
   if {$err == 0} {
      set err [catch {file mkdir $bddconf(dirinco)} msg]
      if {$err != 0} {
         puts "ERREUR: Creation du repertoire : $bddconf(dirinco) impossible <$err>"
      }
   } else {
      puts "ERREUR: Effacement du repertoire : $bddconf(dirinco) impossible <$err>"
   }

   # Creation du repertoire cata
   puts "  - repertoire $bddconf(dircata)"
   set err [catch {file delete -force $bddconf(dircata)} msg]
   if {$err == 0} {
      set err [catch {file mkdir $bddconf(dircata)} msg]
      if {$err != 0} {
         puts "ERREUR: Creation du repertoire : $bddconf(dircata) impossible <$err>"
      }
   } else {
      puts "ERREUR: Effacement du repertoire : $bddconf(dircata) impossible <$err>"
   }

   # Creation du repertoire reports
   puts "  - repertoire $bddconf(dirreports)"
   set err [catch {file delete -force $bddconf(dirreports)} msg]
   if {$err == 0} {
      set err [catch {file mkdir $bddconf(dirreports)} msg]
      if {$err != 0} {
         puts "ERREUR: Creation du repertoire : $bddconf(dirreports) impossible <$err>"
      }
   } else {
      puts "ERREUR: Effacement du repertoire : $bddconf(dirreports) impossible <$err>"
   }

   # Creation du repertoire tmp
   puts "  - repertoire $bddconf(dirtmp)"
   set err [catch {file delete -force $bddconf(dirtmp)} msg]
   if {$err == 0} {
      set err [catch {file mkdir $bddconf(dirtmp)} msg]
      if {$err != 0} {
         puts "ERREUR: Creation du repertoire : $bddconf(dirtmp) impossible <$err>"
      }
   } else {
      puts "ERREUR: Effacement du repertoire : $bddconf(dirtmp) impossible <$err>"
   }

}


proc main_init { } {

   global audace
   global bddconf
   global dbname dbserver dbport
   global dblogin dbpasswd
   global mysqlrootname mysqlrootpasswd
   global limit destdir

   set ::tcl_precision 17

   # Config audace
   source [file join $audace(rep_home) audace.ini]

   if {$dbname == "?"} {
      puts "Erreur: veuillez fournir un nom pour la base de donnees.\n"
      exit
   }

   source $audace(rep_install)/gui/audace/plugin/tool/bddimages/bddimages_sql.tcl
   ::bddimages_sql::mysql_init

   #--- Charge les config bddimages depuis le fichier XML
   set err [::bdi_tools_xml::load_xml_config]
   #--- Recupere la liste des bddimages disponibles
   set bddconf(list_config) $::bdi_tools_xml::list_bddimages

   set bddconf(rep_plug) [file join $audace(rep_plugin) tool bddimages]
   set bddconf(astroid)  [file join $audace(rep_plugin) tool bddimages utils astroid]
   set bddconf(extension_bdd) ".fits.gz"
   set bddconf(extension_tmp) ".fit"

   set bddconf(name)       $dbname
   set bddconf(dbname)     $dbname
   set bddconf(server)     $dbserver
   set bddconf(login)      $dblogin
   set bddconf(pass)       $dbpasswd
   set bddconf(port)       $dbport
   set bddconf(limit)      $limit
   set bddconf(dirbase)    "$destdir"
   set bddconf(dirfits)    "$destdir/fits"
   set bddconf(dirlog)     "$destdir/log"
   set bddconf(direrr)     "$destdir/error"
   set bddconf(dirinco)    "$destdir/incoming"
   set bddconf(dircata)    "$destdir/cata"
   set bddconf(dirtmp)     "$destdir/tmp"
   set bddconf(dirreports) "$destdir/reports"

}
