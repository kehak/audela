proc main { } {
     
   global bddconf
   global maliste
   global dbname destdir

   main_init

   puts "\n******************************************************"
   puts "\n* EXPORT DES IMAGES ET CATA DE LA BASE $dbname"
   puts "\n******************************************************"

   # Recupere la liste des images sur le disque
   puts "\n* Chargement de la liste des images sur le disque..."

   set maliste {}
   get_files $bddconf(dirfits) 0
   set err [catch {set maliste [lsort -increasing $maliste]} msg]
   if {$err} {
      puts "Erreur: impossible d'etablir la liste des images sur le disque"
      return
   }
   set list_img_file $maliste
   puts "list_img_file  = [llength $list_img_file]"

   # Export des images et des catas dans le repertoire de destination
   puts "\n* Export des images dans le repertoire de destination..."

   foreach img $list_img_file {
      puts "cp $img -> $destdir"
      set err [catch {file copy -force -- $img $destdir} msg]
      if {$err != 0} {
         ::console::affiche_erreur "cp image impossible : $img avec erreur $err (msg= $msg)\n"
         continue
      }
   }

   # Recupere la liste des catas sur le disque
   puts "\n* Chargement de la liste des catas sur le disque..."

   set maliste {}
   get_files $bddconf(dircata) 0
   set err [catch {set maliste [lsort -increasing $maliste]} msg]
   if {$err} {
      puts "Erreur liste des catas sur le disque"
      return
   }
   set list_cata_file $maliste
   puts "list_cata_file = [llength $list_cata_file]"

   puts "\n* Export des catas dans le repertoire de destination..."

   foreach cata $list_cata_file {
      puts "cp $cata -> $destdir"
      set err [catch {file copy -force -- $cata $destdir} msg]
      if {$err != 0} {
         ::console::affiche_erreur "cp cata impossible : $cata avec erreur $err (msg= $msg)\n"
         continue
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
