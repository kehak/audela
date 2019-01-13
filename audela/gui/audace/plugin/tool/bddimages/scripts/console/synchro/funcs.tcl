proc ::bdi_tools_synchro::log { channel msg {cend ""} } {
   set entete "[mc_date2iso8601 now]:"
   puts "$entete ${msg}"
}
proc ::bdi_tools_synchro::addlog { msg {cend ""} {cbeg "\n"}} {
   ::bdi_tools_synchro::log "" $msg
}

   proc server_init { } {

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




   proc server { } {
     
     server_init

     ::bdi_tools_synchro::launch_socket


   }




proc test_memoire { } {

   
   set info [exec cat /proc/[pid]/status ]
   set mem0 [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]

   for {set i 5} {$i<22} {incr i} {

      set info [exec cat /proc/[pid]/status ]
      set mem [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]
      gren_info "Test LibCatalog :: current memory = $mem Mo :: CMD = csucac4 $ucac4 117.461051 26.417708 5.3201769552120002 $i -5"

      csucac4 $ucac4 117.461051 26.417708 5.3201769552120002 $i -5
   
   }
   set info [exec cat /proc/[pid]/status ]
   set memf [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"]  / 1024.0 - $mem0 ] ]
   
   gren_info "Test LibCatalog : Perte differentielle = $memf Mo"

   exit

}
