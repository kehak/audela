## @file bddimages_sql.tcl
#  @brief     Wrapper pour acc&eacute;der aux bases de donn&eacute;es SQL
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bddimages_sql.tcl]
#  @endcode

# $Id: bddimages_sql.tcl 13886 2016-05-22 21:55:06Z jberthier $

##
# @namespace bddimages_sql
# @brief Wrapper pour acc&eacute;der aux bases de donn&eacute;es SQL
# @pre Requiert \c mysql .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bddimages_sql {

   global bddconf

}


# ==========================================================================================
# ==========================================================================================
proc ::bddimages_sql::sql { args } {
   global sql

   set cmd [lindex $args 0]
   if {$cmd=="connect"} {
      set ipdb [lindex $args 1]
      set user [lindex $args 2]
      set pass [lindex $args 3]
      if {[info exists sql(h)]==1} {
         if {$sql(h)!=""} {
            ::mysql::close $sql(h)
            unset sql(h)
         }
      }
      set sql(h) [::mysql::connect -host $ipdb -user $user -password $pass]
   } elseif {$cmd=="disconnect"} {
      ::mysql::close $sql(h)
      unset sql(h)
   } elseif {$cmd=="selectdb"} {
      set db [lindex $args 1]
      ::bddimages_sql::ifnotexist_reconnect
      ::mysql::use $sql(h) $db
   } elseif {$cmd=="getcolname"} {
      ::bddimages_sql::ifnotexist_reconnect
      ::mysql::col $sql(h) -current name
   } elseif {$cmd=="select"} {
      ::bddimages_sql::ifnotexist_reconnect
      set texte [lindex $args 1]
      set row ""
      set row [::mysql::sel $sql(h) "$texte" -list]
      if {$row==""} {
         return ""
      }
      set col ""
      set col [::mysql::col $sql(h) -current name]
      set res ""
      lappend res $col
      lappend res $row
      return $res
   } elseif {$cmd=="query"} {
      ::bddimages_sql::ifnotexist_reconnect
      set texte [lindex $args 1]
      set sql(q) [::mysql::query $sql(h) "$texte"]
      if {$sql(q)==-1} {
         return ""
      }
      set res ""
      while {[set row [::mysql::fetch $sql(q)]]!=""} {
         lappend res $row
      }
      ::mysql::endquery $sql(q)
      return $res
   } elseif {$cmd=="insertid"} {
      ::bddimages_sql::ifnotexist_reconnect
      set nb [::mysql::insertid $sql(h)]
      return $nb
   } elseif {$cmd=="exec"} {
      ::bddimages_sql::ifnotexist_reconnect
      set texte [lindex $args 1]
      set sql(q) [::mysql::exec $sql(h) "$texte"]
      if {$sql(q)==-1} {
         return ""
      }
      return $sql(q)
   } else {
      error "usage : sql connect|disconnect|selectdb|query|insertid|getcolname"
   }
}

# ==========================================================================================
# -- Connexion a bddimages --
# ==========================================================================================
proc ::bddimages_sql::connect { } {

   global bddconf
   set connected "$bddconf(dbname) @ $bddconf(server)"

   set err [catch {sql query "use $bddconf(dbname);"} msg]
   if {$err} {
      set err [catch {sql connect $bddconf(server) $bddconf(login) $bddconf(pass)} msg]
      if {$err} {
         return -code error "Erreur de connexion a MySql <$err> <$msg>" 
      } else {
         set err [catch {sql query "use $bddconf(dbname);"} msg]
         if {$err} {
            return -code error "Erreur de connexion a  $bddconf(dbname) <$err> <$msg>"
         } else {
            return -code 0 $connected
         }
      }
   }
   return -code 0 $connected

}

proc ::bddimages_sql::ifnotexist_reconnect { } {

   global sql

   set ping [::mysql::ping $sql(h)]

   if {$ping!=1} { 
      set ::bdi_tools_config::ok_mysql_connect 0
      set errconn [catch {::bddimages_sql::connect} connectstatus]
      if { $errconn } {
         gren_erreur "Connexion perdue : Impossible de se reconnecter\n"
      } else {
         gren_erreur "Connexion perdue : reconnexion reussie \n"
         set ::bdi_tools_config::ok_mysql_connect 1
      }
   }
}



# ==========================================================================================
# -- Mysql init
# ==========================================================================================
proc ::bddimages_sql::mysql_init { } {

   global sql
   global audace

   #--- extension MySQL
   set lib [file join $audace(rep_install) bin "libmysqltcl[info sharedlibextension]"]
   set err [catch {load $lib} msg]
   if {$err == 1} {
      gren_erreur "Cannot load libmysqltcl[info sharedlibextension]\n"
   } else {
      set err [catch {package require mysqltcl} msg]
      gren_info "Mysql: mysqltcl $msg loaded\n"
   }

}
