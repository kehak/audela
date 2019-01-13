
namespace eval ::bdi_tools_thread {

}




   proc ::bdi_tools_thread::create { } {
         
      # Create 1 thread
      set threadName [thread::create {

         namespace eval ::console {
            proc affiche_resultat { msg } { puts "$msg" }
            proc affiche_erreur   { msg } { puts "$msg" }
            proc affiche_debug    { msg } { puts "$msg" }
         }

         thread::wait
      }]
      
      ::bdi_tools_thread::setenv $threadName

      return $threadName
   }



   proc ::bdi_tools_thread::nbexist {  } {
      return [llength [thread::names]]
   }



   proc ::bdi_tools_thread::exists { threadName } {
      return [thread::exists $threadName]
   }



   proc ::bdi_tools_thread::release { threadName } {
      set ex [::bdi_tools_thread::exists $threadName]
      if {$ex} {
         ::thread::release $threadName
      }
   }







   proc ::bdi_tools_thread::setenv { threadName } {

      # audela
      global audela
      set a [array get audela]
      ::thread::send $threadName [list array set audela $a]

      # Audace
      global audace
      set a [array get audace]
      ::thread::send $threadName [list array set audace $a]

      # conf
      global conf
      set a [array get conf]
      ::thread::send $threadName [list array set conf $a]

      # Bddconf
      global bddconf
      set a [array get bddconf]
      ::thread::send $threadName [list array set bddconf $a]

      # private
      global private
      set a [array get private]
      ::thread::send $threadName [list array set private $a]

      # langage
      global langage
      ::thread::send $threadName [list set langage $langage]

      ::thread::send $threadName [list uplevel #0 source \"[ file join $audace(rep_gui) audace console.tcl ]\"] msg

      set sourceFileName [file join $audace(rep_plugin) tool bddimages bddimages_go.tcl ]
      ::thread::send $threadName [list uplevel #0 source \"$sourceFileName\"] msg

      ::thread::send $threadName [list package require bddimages] msg

      ::thread::send $threadName [list ::bddimages::ressource_tools] msg

      if {1} {
         # mode debug
         thread::send $threadName [list proc gren_info   { l } { puts $l }]
         thread::send $threadName [list proc gren_erreur { l } { puts $l }]
      } else {
         # mode prod
         thread::send $threadName [list proc gren_info   { l } { }]
         thread::send $threadName [list proc gren_erreur { l } { }]
      }

      # permet le passage du nom de la bdd aussi bien en mode GUI qu en script console
      if {[info exists bddconf(dbname)]} { 
         global dbname
         set dbname $bddconf(dbname)
      }
      ::thread::send $threadName [list set dbname $dbname]
      ::thread::send $threadName [list ::bdi_tools_thread::init_thread] msg
      return
   }

   
   
   
   
   
   






   proc ::bdi_tools_thread::init_thread { } {

      global conf
      global private
      global audace
      global bddconf
      global dbname

      package require math::statistics
      set ::tcl_precision 17

      set ::audela_start_dir [file join $audace(rep_install) bin]
      cd $::audela_start_dir

      set audelaLibPath [file join [file join [file dirname [file dirname [info nameofexecutable]] ] lib]]
      if { [lsearch $::auto_path $audelaLibPath] == -1 } {
         lappend ::auto_path $audelaLibPath
      }

      set err [catch {load libgzip[info sharedlibextension]} msg]
      set err [catch {load libaudela[info sharedlibextension]} msg]
      set err [catch {load libfitstcl[info sharedlibextension]} msg]
      set err [catch {load libmc[info sharedlibextension]} msg]
      set err [catch {load libgsltcl[info sharedlibextension]} msg]
      set err [catch {load libtcltt[info sharedlibextension]} msg]

      set dir [file join $audace(rep_gui) audace]

      uplevel #0 "source \"[ file join $dir menu.tcl                ]\""
      uplevel #0 "source \"[ file join $dir aud_menu_1.tcl          ]\""
      uplevel #0 "source \"[ file join $dir aud_menu_2.tcl          ]\""
      uplevel #0 "source \"[ file join $dir aud_menu_3.tcl          ]\""
      uplevel #0 "source \"[ file join $dir aud_menu_5.tcl          ]\""
      uplevel #0 "source \"[ file join $dir aud_menu_7.tcl          ]\""
      uplevel #0 "source \"[ file join $dir aud_menu_8.tcl          ]\""
      uplevel #0 "source \"[ file join $dir aud_proc.tcl            ]\""
    #  uplevel #0 "source \"[ file join $dir console.tcl             ]\""
      uplevel #0 "source \"[ file join $dir confgene.tcl            ]\""
      uplevel #0 "source \"[ file join $dir surchaud.tcl            ]\""
      uplevel #0 "source \"[ file join $dir planetography.tcl       ]\""
      uplevel #0 "source \"[ file join $dir ftp.tcl                 ]\""
      uplevel #0 "source \"[ file join $dir bifsconv.tcl            ]\""
      uplevel #0 "source \"[ file join $dir compute_stellaire.tcl   ]\""
      uplevel #0 "source \"[ file join $dir divers.tcl              ]\""
      uplevel #0 "source \"[ file join $dir iris.tcl                ]\""
      uplevel #0 "source \"[ file join $dir poly.tcl                ]\""
      uplevel #0 "source \"[ file join $dir filtrage.tcl            ]\""
      uplevel #0 "source \"[ file join $dir mauclaire.tcl           ]\""
      uplevel #0 "source \"[ file join $dir help.tcl                ]\""
      uplevel #0 "source \"[ file join $dir vo_tools.tcl            ]\""
      uplevel #0 "source \"[ file join $dir sectiongraph.tcl        ]\""
      uplevel #0 "source \"[ file join $dir polydraw.tcl            ]\""
      uplevel #0 "source \"[ file join $dir ros.tcl                 ]\""
      uplevel #0 "source \"[ file join $dir socket_tools.tcl        ]\""
      uplevel #0 "source \"[ file join $dir gcn_tools.tcl           ]\""
      uplevel #0 "source \"[ file join $dir celestial_mechanics.tcl ]\""
      uplevel #0 "source \"[ file join $dir diaghr.tcl              ]\""
      uplevel #0 "source \"[ file join $dir satel.tcl               ]\""
      uplevel #0 "source \"[ file join $dir miscellaneous.tcl       ]\""
      uplevel #0 "source \"[ file join $dir photompsf.tcl           ]\""
      uplevel #0 "source \"[ file join $dir prtr.tcl                ]\""
      uplevel #0 "source \"[ file join $dir photcal.tcl             ]\""
      uplevel #0 "source \"[ file join $dir etc_tools.tcl           ]\""
      uplevel #0 "source \"[ file join $dir meteosensor_tools.tcl   ]\""
      uplevel #0 "source \"[ file join $dir photrel.tcl             ]\""
      uplevel #0 "source \"[ file join $dir fly.tcl                 ]\""
      uplevel #0 "source \"[ file join $dir grb_tools.tcl           ]\""
      uplevel #0 "source \"[ file join $dir speckle_tools.tcl       ]\""

      #--- Chargement des legendes et textes pour differentes langues
      set audace(rep_caption) [ file join $audace(rep_gui) audace caption ]
      uplevel #0 "source \"[ file join $audace(rep_caption) aud_menu_5.cap      ]\""

      source [file join $audace(rep_home) audace.ini]
      
      # Init Mysql
     ::bddimages_sql::mysql_init

      # Fichier de config XML a charger
      set ::bdi_tools_xml::xmlConfigFile [file join $audace(rep_home) bddimages_ini.xml]

      # Chargement et connection a la bdd
      set bddconf(current_config) [::bdi_tools_config::load_config $dbname]

      set bddconf(bufno)    $audace(bufNo)
      set bddconf(visuno)   $audace(visuNo)
      set bddconf(rep_plug) [file join $audace(rep_plugin) tool bddimages]
      set bddconf(astroid)  [file join $audace(rep_plugin) tool bddimages utils astroid]
      set bddconf(extension_bdd) ".fits.gz"
      set bddconf(extension_tmp) ".fit"

      # Connexion Mysql
#      ::bddimages_sql::mysql_init
#      set errconn [catch {::bddimages_sql::connect} connectstatus]
#      if { $errconn } {
#         puts "Connexion MYSQL echouee : $connectstatus\n"
#      } else {
#         set ::bdi_tools_config::ok_mysql_connect 1
#         # puts "Connexion MYSQL reussie : $connectstatus\n"
#      }

      cd $bddconf(dirtmp)


   }
