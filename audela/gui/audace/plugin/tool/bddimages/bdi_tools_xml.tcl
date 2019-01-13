## @file bdi_tools_xml.tcl
#  @brief     M&eacute;thodes d&eacute;di&eacute;es &agrave; la manipulation des fichiers XML de configuration de bddimages
#  @author    Jerome Berthier and Frederic Vachier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_xml.tcl]
#  @endcode

# $Id: bdi_tools_xml.tcl 13117 2016-05-21 02:00:00Z jberthier $

#============================================================
## Declaration du namespace \c bdi_tools_xml .
# @brief     Manipulation des fichiers de config XML de bddimages
# @pre       Requiert bdi_tools_xml 1.0
# @warning   Pour developpeur seulement
#
namespace eval ::bdi_tools_xml {

   package provide bdi_tools_xml 1.0
   global audace

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_xml.cap ]\""

   # Compatibilite ascendante
   if { [ package require dom ] == "2.6" } {
      interp alias {} ::dom::parse {} ::dom::tcl::parse
      interp alias {} ::dom::selectNode {} ::dom::tcl::selectNode
      interp alias {} ::dom::node {} ::dom::tcl::node
   }

   # Structure contenant les config xml
   variable xmlConfig
   # Defini le nom du fichier de config XML
   variable xmlConfigFile [file join $audace(rep_home) bddimages_ini.xml]
   # Defini le fichier par defaut de config XML
   variable xmlDefaultConfigFile [file join $audace(rep_plugin) tool bddimages config bddimages_ini.xml]

   # Liste des bddimages lues dans la config : xmlConfig(i,name)
   variable list_bddimages
   variable list_bddimages_names
   # Nom de la config par defaut
   variable default_config
   # Nom de la config courante
   variable current_config
   variable is_config_loaded

   # Variable de definition du schema XML de config bddimages
   variable xml_config_docroot "config"
   variable xml_config_version "1.0"
   variable xml_nsxsi "http://www.w3.org/2001/XMLSchema-instance"

   #------------------------------------------------------------
   ## Methode privee pour construire le chemin d'un repertoire base/dir. Si base=='' alors le repertoire de base est audace(rep_images).
   # @param base string Repertoire de base
   # @param dir string Repertoire cible
   # @return fullpath le chemin complet du repertoire cible
   #
   proc get_default_dir { base dir } {
      global audace
      set fullpath ""
      if {[string length [string trim $base]] > 0} {
         set fullpath [file join $base]
      } else {
         set fullpath [file join $audace(rep_images) $dir]
      }
      return $fullpath
   }

   #------------------------------------------------------------
   ## Methode privee fournissant l'id d'une config a partir de son nom. Renvoie id=1 si la config demandee n'est pas trouvee.
   # @param name string Nom de la config
   # @return id de la config correspondante
   #
   proc get_id_from_name { name } {
      set id 1
      foreach l $::bdi_tools_xml::list_bddimages {
         if {[lindex $l 1] == $name} {
            set id [lindex $l 0]
         }
      }
      return $id
   }

   #------------------------------------------------------------
   ## Methode privee fournissant le nom d'une config a partir de son id. Renvoie name="?" si la config demandee n'est pas trouvee.
   # @param id int Id de la config
   # @return nom de la config correspondante
   #
   proc get_name_from_id { id } {
      set name ""
      foreach l $::bdi_tools_xml::list_bddimages {
         if {[lindex $l 0] == $id} {
            set name [lindex $l 1]
         }
      }
      return $name
   }

   #------------------------------------------------------------
   ## Methode privee fournissant l'id le plus grand. Renvoie id=1 si la config demandee n'est pas trouvee.
   # @return id le plus grand
   #
   proc get_last_id_config { } {
      set id 1
      foreach l $::bdi_tools_xml::list_bddimages {
         if {[lindex $l 0] >= $id} {
            set id [lindex $l 0]
         }
      }
      return $id
   }

}

#------------------------------------------------------------
## Chargement de la config XML de bddimages (lecture du fichier de config XML)
# @return -code err
#
proc ::bdi_tools_xml::load_xml_config {  } {

   # Verifie que le fichier xml existe, et s'il n'existe pas
   # on le cree a partir du fichier par defaut config/bddimages_ini.xml
   if { ! [file exists $::bdi_tools_xml::xmlConfigFile]} {
      gren_info "$::caption(bddimages_xml,defaultxml)\n"
      set err [catch {file copy $::bdi_tools_xml::xmlDefaultConfigFile $::bdi_tools_xml::xmlConfigFile} msg ]
      if {$err != 0} {
         gren_erreur "$::caption(bddimages_xml,nodefaultxml)\n"
         return $err
      }
   }

   # Charge la config xml
   set err [::bdi_tools_xml::read_xml_config $::bdi_tools_xml::xmlConfigFile]
   return -code $err ""

}

#------------------------------------------------------------
## Lecture de la config XML
# @param file_config nom du fichier de config XML
# @return 0
#
proc ::bdi_tools_xml::read_xml_config { file_config } {

   # Force la mise a null, car array set arrayName list ne le fait
   # que si la variable n'existe pas
   array unset ::bdi_tools_xml::xmlConfig

   # Structure contenant la config: force la mise a null
   array set ::bdi_tools_xml::xmlConfig {}
   # Par defaut on considere la config id=1
   set ::bdi_tools_xml::xmlConfigDef(default_id) 1
   # Par defaut il n'y a aucune config
   set ::bdi_tools_xml::xmlConfigDef(nb_id) 0
   # Structure contenant la liste des config sous la forme {id name}
   set ::bdi_tools_xml::list_bddimages {}
   set ::bdi_tools_xml::list_bddimages_names {}
   # Nom de la config par defaut
   set ::bdi_tools_xml::default_config ""
   # Nom de la config courante
   set ::bdi_tools_xml::current_config ""

   # Lecture du fichier
   set xmldoc ""
   set f [open $file_config r]
   while {![eof $f]} {
      append xmldoc [gets $f]
   }
   close $f

   # Analyse du doc XML pour charger la config dans xmlConfig
   set xml [::dom::parse $xmldoc]
   foreach node [::dom::selectNode $xml {descendant::bddimages}] {

      if { [catch {::dom::node stringValue [::dom::selectNode $node {attribute::id}]} val] == 0 } {
         # id de la config
         set id $val
         set ::bdi_tools_xml::xmlConfig($id,id) $id
         # compteur de config
         set ::bdi_tools_xml::xmlConfigDef(nb_id) [expr $::bdi_tools_xml::xmlConfigDef(nb_id) + 1]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {attribute::default}]} val] == 0 } {
         set ::bdi_tools_xml::xmlConfig($id,default) $val
         set ::bdi_tools_xml::xmlConfigDef(default_id) $id
      } else {
         set ::bdi_tools_xml::xmlConfig($id,default) "no"
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::name/text()}]} val] == 0 } {
         set ::bdi_tools_xml::xmlConfig($id,name) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::dbname/text()}]} val] == 0 } {
         set ::bdi_tools_xml::xmlConfig($id,dbname) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::login/text()}]} val] == 0 } {
         set ::bdi_tools_xml::xmlConfig($id,login) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::pass/text()}]} val] == 0 } {
         set ::bdi_tools_xml::xmlConfig($id,pass) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::server/text()}]} val] == 0 } {
         set ::bdi_tools_xml::xmlConfig($id,server) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::port/text()}]} val] == 0 } {
         set ::bdi_tools_xml::xmlConfig($id,port) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::root/text()}]} val] == 0 } {
         set ::bdi_tools_xml::xmlConfig($id,dirbase) [::bdi_tools_xml::get_default_dir $val "bddimages"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::incoming/text()}]} val] == 0 } {
         set ::bdi_tools_xml::xmlConfig($id,dirinco) [::bdi_tools_xml::get_default_dir $val "bddimages/incoming"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::fits/text()}]} val] == 0 } {
         set ::bdi_tools_xml::xmlConfig($id,dirfits) [::bdi_tools_xml::get_default_dir $val "bddimages/fits"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::cata/text()}]} val] == 0 } {
         set ::bdi_tools_xml::xmlConfig($id,dircata) [::bdi_tools_xml::get_default_dir $val "bddimages/cata"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::error/text()}]} val] == 0 } {
         set ::bdi_tools_xml::xmlConfig($id,direrr) [::bdi_tools_xml::get_default_dir $val "bddimages/error"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::log/text()}]} val] == 0 } {
         set ::bdi_tools_xml::xmlConfig($id,dirlog) [::bdi_tools_xml::get_default_dir $val "bddimages/log"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::reports/text()}]} val] == 0 } {
         set ::bdi_tools_xml::xmlConfig($id,dirreports) [::bdi_tools_xml::get_default_dir $val "bddimages/reports"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::tmp/text()}]} val] == 0 } {
         set ::bdi_tools_xml::xmlConfig($id,dirtmp) [::bdi_tools_xml::get_default_dir $val "bddimages/tmp"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::screenlimit/text()}]} val] == 0 } {
         set ::bdi_tools_xml::xmlConfig($id,limit) $val
      }

   }

   # Defini la liste des bddimages disponibles [list id name]
   set prev_k 0
   foreach key [lsort [array names ::bdi_tools_xml::xmlConfig]] {
      set k [lindex [split $key ","] 0]
      if {$k != $prev_k} {
         lappend ::bdi_tools_xml::list_bddimages [list $::bdi_tools_xml::xmlConfig($k,id) $::bdi_tools_xml::xmlConfig($k,name)]
         lappend ::bdi_tools_xml::list_bddimages_names $::bdi_tools_xml::xmlConfig($k,name)
         set prev_k $k
      }
   }

   # Charge la config par defaut
   set def_conf $::bdi_tools_xml::xmlConfig($::bdi_tools_xml::xmlConfigDef(default_id),name)
   set ::bdi_tools_xml::default_config [::bdi_tools_xml::load_config $def_conf]

   # Defini la config courante comme etant celle par defaut
   set ::bdi_tools_xml::current_config $::bdi_tools_xml::default_config

   return 0
}

#------------------------------------------------------------
## Chargement de la config bddimages definie par son nom
# @param name string Nom de la config a charger
# @return Nom de la config chargee
#
proc ::bdi_tools_xml::load_config { name } {

   global bddconf

   set ::bdi_tools_xml::is_config_loaded 0

   # Cherche l'id de la config demandee
   set id [::bdi_tools_xml::get_id_from_name $name]

   # Defini les parametres de la config demandee
   set err [catch {set bddconf(name)        $::bdi_tools_xml::xmlConfig($id,name)       }]
   set err [catch {set bddconf(dbname)      $::bdi_tools_xml::xmlConfig($id,dbname)     }]
   set err [catch {set bddconf(login)       $::bdi_tools_xml::xmlConfig($id,login)      }]
   set err [catch {set bddconf(pass)        $::bdi_tools_xml::xmlConfig($id,pass)       }]
   set err [catch {set bddconf(server)      $::bdi_tools_xml::xmlConfig($id,server)     }]
   set err [catch {set bddconf(port)        $::bdi_tools_xml::xmlConfig($id,port)       }]
   set err [catch {set bddconf(dirbase)     $::bdi_tools_xml::xmlConfig($id,dirbase)    }]
   set err [catch {set bddconf(dirinco)     $::bdi_tools_xml::xmlConfig($id,dirinco)    }]
   set err [catch {set bddconf(dirfits)     $::bdi_tools_xml::xmlConfig($id,dirfits)    }]
   set err [catch {set bddconf(dircata)     $::bdi_tools_xml::xmlConfig($id,dircata)    }]
   set err [catch {set bddconf(direrr)      $::bdi_tools_xml::xmlConfig($id,direrr)     }]
   set err [catch {set bddconf(dirlog)      $::bdi_tools_xml::xmlConfig($id,dirlog)     }]
   set err [catch {set bddconf(dirreports)  $::bdi_tools_xml::xmlConfig($id,dirreports) }]
   set err [catch {set bddconf(dirtmp)      $::bdi_tools_xml::xmlConfig($id,dirtmp)     }]
   set err [catch {set bddconf(limit)       $::bdi_tools_xml::xmlConfig($id,limit)      }]

   if {$err == 0} {
      set ::bdi_tools_xml::is_config_loaded 1
   } else {
      gren_erreur "  Config non chargee (err $err)\n"
   }

   # Retourne le nom de la config chargee
   return $bddconf(name)

}

#------------------------------------------------------------
## Ajoute une config XML
# @param name string Nom de la config XML a creer
# @param base ??
# @return nom de la config a charger
# @todo commenter param base
proc ::bdi_tools_xml::add_config { {name ""} {base ""} } {

   # Valeur de l'id existant le plus grand
   set max_id [::bdi_tools_xml::get_last_id_config]
   # Nouvel id = max + 1
   set new_id [expr $max_id + 1]
   # Defini un template de nom pour la nouvelle config
   if {[string length $name] > 0} {
      set new_name $name
   } else {
      set new_name "bddimages$new_id"
   }

   # Defini un repertoire de base -> rep_images | base
   set new_base [::bdi_tools_xml::get_default_dir $base $new_name]
   foreach d $::bdi_tools_config::bddimages_workdirs {
      switch $d {
         "cata"     { set new_dircata    [file join $new_base $d] }
         "fits"     { set new_dirfits    [file join $new_base $d] }
         "incoming" { set new_dirinco    [file join $new_base $d] }
         "error"    { set new_direrr     [file join $new_base $d] }
         "log"      { set new_dirlog     [file join $new_base $d] }
         "reports"  { set new_dirreports [file join $new_base $d] }
         "tmp"      { set new_dirtmp     [file join $new_base $d] }
      }
   }

   # Incremente le nombre de config
   set ::bdi_tools_xml::xmlConfigDef(nb_id) [expr $::bdi_tools_xml::xmlConfigDef(nb_id) + 1]
   # Defini le template de la nouvelle config
   set ::bdi_tools_xml::xmlConfig($new_id,id)         $new_id
   set ::bdi_tools_xml::xmlConfig($new_id,default)    "no"
   set ::bdi_tools_xml::xmlConfig($new_id,name)       $new_name
   set ::bdi_tools_xml::xmlConfig($new_id,dbname)     $new_name
   set ::bdi_tools_xml::xmlConfig($new_id,login)      ""
   set ::bdi_tools_xml::xmlConfig($new_id,pass)       ""
   set ::bdi_tools_xml::xmlConfig($new_id,server)     ""
   set ::bdi_tools_xml::xmlConfig($new_id,port)       ""
   set ::bdi_tools_xml::xmlConfig($new_id,dirbase)    $new_base
   set ::bdi_tools_xml::xmlConfig($new_id,dirinco)    $new_dirinco
   set ::bdi_tools_xml::xmlConfig($new_id,dirfits)    $new_dirfits
   set ::bdi_tools_xml::xmlConfig($new_id,dircata)    $new_dircata
   set ::bdi_tools_xml::xmlConfig($new_id,direrr)     $new_direrr
   set ::bdi_tools_xml::xmlConfig($new_id,dirlog)     $new_dirlog
   set ::bdi_tools_xml::xmlConfig($new_id,dirreports) $new_dirreports
   set ::bdi_tools_xml::xmlConfig($new_id,dirtmp)     $new_dirtmp
   set ::bdi_tools_xml::xmlConfig($new_id,limit)      "10"

   # Met a jour la liste des config
   set new_config [list $new_id $new_name]
   lappend ::bdi_tools_xml::list_bddimages $new_config
   lappend ::bdi_tools_xml::list_bddimages_names $new_name

   # Retourne le nom de la nouvelle config
   return $new_name
}

#------------------------------------------------------------
## Efface une config XML a partir de son nom
# @param name string Nom de la config XML a effacer
# @return Nom de la config XML courante
#
proc ::bdi_tools_xml::delete_config { name } {

   # S'il ne reste qu'une config alors impossible de l'effacer
   if {$::bdi_tools_xml::xmlConfigDef(nb_id) == 1} {
      return -code 1
   }

   # Cherche l'id de la config demandee
   set id [::bdi_tools_xml::get_id_from_name $name]

   # Creation d'une nouvelle structure des config
   array set new_xmlConfig {}
   # Recopie toutes les config sauf celle a effacer
   foreach key [lsort [array names ::bdi_tools_xml::xmlConfig]] {
      set k [split $key ","]
      if {[lindex $k 0] != $id} {
         set err [catch {set new_xmlConfig($key) $::bdi_tools_xml::xmlConfig($key)}]
      }
   }
   # Mise a jour de la structure des config
   array unset ::bdi_tools_xml::xmlConfig
   array set ::bdi_tools_xml::xmlConfig [array get new_xmlConfig]

   # Decremente le nombre de config
   set ::bdi_tools_xml::xmlConfigDef(nb_id) [expr $::bdi_tools_xml::xmlConfigDef(nb_id) - 1]

   # Re-initialise la liste des config
   set ::bdi_tools_xml::list_bddimages {}
   set ::bdi_tools_xml::list_bddimages_names {}
   # Defini la liste des bddimages disponibles [list id name]
   set prev_k 0
   foreach key [lsort [array names ::bdi_tools_xml::xmlConfig]] {
      set k [lindex [split $key ","] 0]
      if {$k != $prev_k} {
         lappend ::bdi_tools_xml::list_bddimages [list $::bdi_tools_xml::xmlConfig($k,id) $::bdi_tools_xml::xmlConfig($k,name)]
         lappend ::bdi_tools_xml::list_bddimages_names $::bdi_tools_xml::xmlConfig($k,name)
         set prev_k $k
      }
   }

# DEBUG
#puts "-- WRITE ------------------------------------------"
#foreach k [lsort [array names ::bdi_tools_xml::xmlConfig]] {
#   puts "xmlConfig: $k --> $::bdi_tools_xml::xmlConfig($k)"
#}

   # Defini la config chargee comme etant la derniere de la liste
   set last_id [::bdi_tools_xml::get_last_id_config]
   # Recupere le nom de cette config
   set new_name [::bdi_tools_xml::get_name_from_id $last_id]
   # Retourne le nom de la config chargee
   return $new_name
}


#------------------------------------------------------------
## Sauvegarde de la config XML de bddimages
# @return Code d'erreur: 0 si pas d'erreur, sinon 1
#
proc ::bdi_tools_xml::save_xml_config {  } {

   # Enregistre la config xml
   if {[catch {::bdi_tools_xml::write_xml_config $::bdi_tools_xml::xmlConfigFile} bck] != 0} {
      gren_erreur "$::caption(bddimages_xml,errorxml)\n"
      gren_erreur "Erreur: fichier de conf=$::bdi_tools_xml::xmlConfigFile -> $bck\n"
      return -code 1
   } else {
      gren_info "$::caption(bddimages_xml,successxml)\n"
      return -code 0
   }

}

#------------------------------------------------------------
## Ecriture de la config XML de bddimages dans un fichier
# @param file_config string Nom du fichier de config XML
# @return 0
#
proc ::bdi_tools_xml::write_xml_config { file_config  } {

# DEBUG
#puts "-- WRITE ------------------------------------------"
#foreach k [lsort [array names ::bdi_tools_xml::xmlConfig]] {
#   puts "xmlConfig: $k --> $::bdi_tools_xml::xmlConfig($k)"
#}

   # Verifie que 2 config ne portent pas le meme nom
#   if {[catch {} ok] != 0} {
#
#   }

   # Cree le doc xml
   set docxml [::dom::DOMImplementation create]

   # Cree la racine du document /config
   set root [::dom::document createElement $docxml $::bdi_tools_xml::xml_config_docroot]
   ::dom::element setAttribute $root "version" $::bdi_tools_xml::xml_config_version
   ::dom::element setAttribute $root "xmlns:xsi" $::bdi_tools_xml::xml_nsxsi

   # Cree l'element /config/document
   set node [::dom::document createElement $root "document"]
    # --- element /config/document/version
    set subnode [::dom::document createElement $node "version"]
    ::dom::document createTextNode $subnode "0.1"
    # --- element /config/document/date
    set subnode [::dom::document createElement $node "date"]
    ::dom::document createTextNode $subnode [::fitsdate]
    # --- element /config/document/ticket
    set subnode [::dom::document createElement $node "ticket"]
    ::dom::document createTextNode $subnode "1"
    # --- element /config/document/author
    set subnode [::dom::document createElement $node "author"]
    ::dom::document createTextNode $subnode "F. Vachier et J. Berthier"

   # Cree les elements /config/bddimages
   foreach conf $::bdi_tools_xml::list_bddimages {

      # id, name
      set i [lindex $conf 0]
      set n [lindex $conf 1]

      # Cree l'element /config/bddimages
      set node [::dom::document createElement $root "bddimages"]
      ::dom::element setAttribute $node "id" $::bdi_tools_xml::xmlConfig($i,id)
      if {$::bdi_tools_xml::xmlConfig($i,name) == $::bdi_tools_xml::default_config} {
         ::dom::element setAttribute $node "default" "yes"
      }

      # --- /config/bddimages/name
      set subnode [::dom::document createElement $node "name"]
      if {[info exists ::bdi_tools_xml::xmlConfig($i,name)]} {
         ::dom::document createTextNode $subnode $::bdi_tools_xml::xmlConfig($i,name)
      }

      # --- /config/bddimages/sql
      set subnode [::dom::document createElement $node "sql"]
        # --- /config/bddimages/sql/dbname
        set subsubnode [::dom::document createElement $subnode "dbname"]
        if {[info exists ::bdi_tools_xml::xmlConfig($i,dbname)]} {
           ::dom::document createTextNode $subsubnode $::bdi_tools_xml::xmlConfig($i,dbname)
        }
        # --- /config/bddimages/sql/login
        set subsubnode [::dom::document createElement $subnode "login"]
        if {[info exists ::bdi_tools_xml::xmlConfig($i,login)]} {
           ::dom::document createTextNode $subsubnode $::bdi_tools_xml::xmlConfig($i,login)
        }
        # --- /config/bddimages/sql/pass
        set subsubnode [::dom::document createElement $subnode "pass"]
        if {[info exists ::bdi_tools_xml::xmlConfig($i,pass)]} {
           ::dom::document createTextNode $subsubnode $::bdi_tools_xml::xmlConfig($i,pass)
        }
        # --- /config/bddimages/sql/ip
        set subsubnode [::dom::document createElement $subnode "server"]
        if {[info exists ::bdi_tools_xml::xmlConfig($i,server)]} {
           ::dom::document createTextNode $subsubnode $::bdi_tools_xml::xmlConfig($i,server)
        }
        # --- /config/bddimages/sql/port
        set subsubnode [::dom::document createElement $subnode "port"]
        if {[info exists ::bdi_tools_xml::xmlConfig($i,port)]} {
           ::dom::document createTextNode $subsubnode $::bdi_tools_xml::xmlConfig($i,port)
        }

      # --- /config/bddimages/files
      set subnode [::dom::document createElement $node "files"]
        # --- /config/bddimages/files/root
        set subsubnode [::dom::document createElement $subnode "root"]
        if {[info exists ::bdi_tools_xml::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bdi_tools_xml::xmlConfig($i,dirbase)
        }
        # --- /config/bddimages/files/incoming
        set subsubnode [::dom::document createElement $subnode "incoming"]
        if {[info exists ::bdi_tools_xml::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bdi_tools_xml::xmlConfig($i,dirinco)
        }
        # --- /config/bddimages/files/fits
        set subsubnode [::dom::document createElement $subnode "fits"]
        if {[info exists ::bdi_tools_xml::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bdi_tools_xml::xmlConfig($i,dirfits)
        }
        # --- /config/bddimages/files/cata
        set subsubnode [::dom::document createElement $subnode "cata"]
        if {[info exists ::bdi_tools_xml::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bdi_tools_xml::xmlConfig($i,dircata)
        }
        # --- /config/bddimages/files/error
        set subsubnode [::dom::document createElement $subnode "error"]
        if {[info exists ::bdi_tools_xml::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bdi_tools_xml::xmlConfig($i,direrr)
        }
        # --- /config/bddimages/files/log
        set subsubnode [::dom::document createElement $subnode "log"]
        if {[info exists ::bdi_tools_xml::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bdi_tools_xml::xmlConfig($i,dirlog)
        }
        # --- /config/bddimages/files/reports
        set subsubnode [::dom::document createElement $subnode "reports"]
        if {[info exists ::bdi_tools_xml::xmlConfig($i,dirbase)]} {
           if {[info exists ::bdi_tools_xml::xmlConfig($i,dirreports)]} {
              ::dom::document createTextNode $subsubnode $::bdi_tools_xml::xmlConfig($i,dirreports)
           } else {
              ::dom::document createTextNode $subsubnode ""
           }
        }
        # --- /config/bddimages/files/tmp
        set subsubnode [::dom::document createElement $subnode "tmp"]
        if {[info exists ::bdi_tools_xml::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bdi_tools_xml::xmlConfig($i,dirtmp)
        }

      # --- /config/bddimages/screenlimit
      set subnode [::dom::document createElement $node "screenlimit"]
      if {[info exists ::bdi_tools_xml::xmlConfig($i,limit)]} {
         ::dom::document createTextNode $subnode $::bdi_tools_xml::xmlConfig($i,limit)
      }
   }

   # Sauve le fichier XML de config
   set fxml [open $file_config "w"]
   puts $fxml [::dom::DOMImplementation serialize $docxml -indent true]
   close $fxml

   return 0
}

#------------------------------------------------------------
## Defini une config XML a partir de son nom
# @param name string Nom de la config XML a definir
# @return void
#
proc ::bdi_tools_xml::set_config { name } {

   global bddconf

   # Defini l'id de la config
   set id [::bdi_tools_xml::get_id_from_name $name]

   # Defini les parametres de la config demandee
   set err [catch {set ::bdi_tools_xml::xmlConfig($id,name)       $bddconf(name)       }]
   set err [catch {set ::bdi_tools_xml::xmlConfig($id,dbname)     $bddconf(dbname)     }]
   set err [catch {set ::bdi_tools_xml::xmlConfig($id,login)      $bddconf(login)      }]
   set err [catch {set ::bdi_tools_xml::xmlConfig($id,pass)       $bddconf(pass)       }]
   set err [catch {set ::bdi_tools_xml::xmlConfig($id,server)     $bddconf(server)     }]
   set err [catch {set ::bdi_tools_xml::xmlConfig($id,port)       $bddconf(port)       }]
   set err [catch {set ::bdi_tools_xml::xmlConfig($id,dirbase)    $bddconf(dirbase)    }]
   set err [catch {set ::bdi_tools_xml::xmlConfig($id,dirinco)    $bddconf(dirinco)    }]
   set err [catch {set ::bdi_tools_xml::xmlConfig($id,dirfits)    $bddconf(dirfits)    }]
   set err [catch {set ::bdi_tools_xml::xmlConfig($id,dircata)    $bddconf(dircata)    }]
   set err [catch {set ::bdi_tools_xml::xmlConfig($id,direrr)     $bddconf(direrr)     }]
   set err [catch {set ::bdi_tools_xml::xmlConfig($id,dirlog)     $bddconf(dirlog)     }]
   set err [catch {set ::bdi_tools_xml::xmlConfig($id,dirreports) $bddconf(dirreports) }]
   set err [catch {set ::bdi_tools_xml::xmlConfig($id,dirtmp)     $bddconf(dirtmp)     }]
   set err [catch {set ::bdi_tools_xml::xmlConfig($id,limit)      $bddconf(limit)      }]

   # Defini la config par defaut
   set ::bdi_tools_xml::default_config $bddconf(default_config)

}
