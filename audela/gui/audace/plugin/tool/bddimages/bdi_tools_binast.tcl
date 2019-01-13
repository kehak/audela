## @file bdi_tools_binast.tcl
#  @brief     Outils d'analyse des observations des satellites d'ast&eacute;ro&iuml;des en optique adaptative
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_binast.tcl]
#  @endcode

# Mise à jour $Id: bdi_tools_binast.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_tools_binast
# @brief Outils d'analyse des observations des satellites d'ast&eacute;ro&iuml;des en optique adaptative
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_tools_binast {

   variable img_list
   variable current_image
   variable current_image_name
   variable nb_img_list

}

## @brief Transforme une liste au format Binast en VOTable
# @param listsources list liste des sources au format Binast
# @param tabkey      list liste des tabkey
# @param tabparams   list liste des params de table
# @return string une VOTable
#
proc ::bdi_tools_binast::list2votable { listsources tabkey tabparams } {

   # Init VOTable: defini la version et le prefix (mettre "" pour supprimer le prefixe)
   ::votable::init "1.1" "vot:"
   # Ouvre une VOTable
   set votable [::votable::openVOTable]
   # Ajoute l'element INFO pour definir le QUERY_STATUS = "OK" | "ERROR"
   append votable [::votable::addInfoElement "status" "QUERY_STATUS" "OK"] "\n"
   # Ouvre l'element RESOURCE
   append votable [::votable::openResourceElement {} ] "\n"

   # Construit les champs PARAM de la ressource
   set votParams ""
   foreach keyval $tabkey {
      set key [lindex $keyval 0]
      set val [lindex $keyval 1]
      set param [::votable::getParamFromTabkey $key $val]
      append votParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"
   }
   append votable $votParams 

   # Construit les champs PARAM des tables
   set votTableParams ""
   foreach keyval $tabparams {
      set key [lindex $keyval 0]
      set val [lindex $keyval 1]
      set param [::votable::getBinastParam $key $val]
      append votTableParams [::votable::addElement $::votable::Element::PARAM [lindex $param 0] [lindex $param 1]] "\n"
   }

   # Extrait les tables et les sources
   set tables  [lindex $listsources 0]
   set sources [lindex $listsources 1]

   # Pour chaque catalogue de la liste des sources -> TABLE
   foreach t $tables {
      foreach {tableName commun col} $t {
         set tableName [string toupper $tableName]
         set nbCommonFields [llength $commun]
         set nbColumnFields [llength $col]
         set votFields ""

         # Si le catalogue n'a pas de colonne alors on enregistre les common
         if {$nbColumnFields < 1} {
            set col2save $commun
            set catidx 1
         } else {
            set col2save $col
            set catidx 2
         }

         # Construit la liste des champs du catalogue
         # -- ajoute le champ idcataspec = index de source (0 .. n)
         set field [::votable::getFieldFromKey "default" "idcataspec.$tableName"]
         append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"
         # -- ajoute les champs definis par le catalogue
         foreach key $col2save {
            set field [::votable::getFieldFromKey $tableName $key]
            if {[llength [lindex $field 0]] > 0} {
               append votFields [::votable::addElement $::votable::Element::FIELD [lindex $field 0] [lindex $field 1]] "\n"
            }
         }

         # Construit la table des donnees
         set nrows 0
         set idcataspec 0
         set votSources ""
         foreach s $sources {
            foreach catalog $s {
               if {[string toupper [lindex $catalog 0]] == $tableName} {
                  # Extrait la liste des valeurs correspondant aux colonnes
                  set data [lindex $catalog $catidx]
                  append votSources [::votable::openElement $::votable::Element::TR {}]
                  # On ajoute la colonne de l'index des sources
                  append votSources [::votable::addElement $::votable::Element::TD {} $idcataspec]
                  foreach d $data {
                     append votSources [::votable::addElement $::votable::Element::TD {} $d]
                  }
                  append votSources [::votable::closeElement $::votable::Element::TR] "\n"
                  incr nrows
               } 
            }
            incr idcataspec
         }

         # Ouvre l'element TABLE
         append votable [::votable::openTableElement [list "$::votable::Table::NAME $tableName" "$::votable::Table::NROWS $nrows"]] "\n"
         #  Ajoute un element de description de la table
         append votable [::votable::addElement $::votable::Element::DESCRIPTION {} "Table of sources detected in the image"] "\n"
         #  Ajoute les definitions des params
         append votable $votTableParams
         #  Ajoute les definitions des colonnes
         append votable $votFields
         #  Ouvre l'element DATA
         append votable [::votable::openElement $::votable::Element::DATA {}] "\n"
         #   Ouvre l'element TABLEDATA
         append votable [::votable::openElement $::votable::Element::TABLEDATA {}] "\n"
         #    Ajoute les sources
         append votable $votSources
         #   Ferme l'element TABLEDATA
         append votable [::votable::closeElement $::votable::Element::TABLEDATA] "\n"
         #  Ferme l'element DATA
         append votable [::votable::closeElement $::votable::Element::DATA] "\n"
         # Ferme l'element TABLE
         append votable [::votable::closeTableElement] "\n"
      }
   }

   # Ferme l'element RESOURCE
   append votable [::votable::closeResourceElement] "\n"
   # Ferme la VOTable
   append votable [::votable::closeVOTable]

   return $votable
}










## @brief Transforme une liste au format Binast en VOTable
# @param catafile  cata BINAST au format  xml
# @return list des params sous la forme d'une liste de key val
#
proc ::bdi_tools_binast::get_tab_param { catafile } {
   # Initialisations
   set tabparams ""
   #array set params {}

   # Recupere la VOTable BINAST
   set fxml [open $catafile "r"]
   set dxml [read $fxml]
   close $fxml
   # Retourne false si erreur ou si la chaine est vide
   if {[string length $dxml] < 1} {
      return -1
   }

   # Parse la votable
   set votable [::dom::parse $dxml]

   #-- Lecture des tables contenues dans la VOTable
   foreach table [::dom::selectNode $votable {descendant::TABLE}] {
      #-- Initialisations
      array set name {}
      array set value {}
      #-- Recupere le nom et la description de la table
      set err [ catch {::dom::node stringValue [::dom::selectNode $table {attribute::name}]} tableName]
      if { $err != "0" } { set tableName "?" }
      #-- Verifie que c'est bien une table BINAST
      if {[string compare -nocase $tableName "BINAST"] != 0} {
         continue
      }
      #-- Recupere les params names
      set cpt 0
      foreach n [::dom::selectNode $table {PARAM/attribute::name}] {
         set name($cpt) "[::dom::node stringValue $n]"
         incr cpt
      }
      #-- Recupere les valeurs des params
      set cpt 0
      foreach p [::dom::selectNode $table {PARAM/attribute::value}] {
         set value($cpt) [::dom::node stringValue $p]
         incr cpt
      }
      # Construit le tableau des params (key value)
      foreach i [array names name] {
         set params($name($i)) $value($i)
         lappend tabparams $name($i) $value($i)
      }
      #-- Sauve les params de la table courante
      #lappend tabparams [array get params]
   }

   # Retourne la VOTable sous forme de liste
   return $tabparams

}


