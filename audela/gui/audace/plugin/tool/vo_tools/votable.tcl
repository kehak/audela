## @file votable.tcl
# @brief Implementation du schema VOTable de l'IVOA (http://www.ivoa.net/Documents/latest/VOT.html)
# @author J. Berthier (berthier@imcce.fr)
# @par Ressource
# @code source [file join $audace(rep_install) gui audace plugin tool vo_tools votable.tcl]
# @endcode

# $Id: votable.tcl 14553 2019-01-09 16:37:12Z fredvachier $

##
# @namespace votable
# @brief Implementation du schema VOTable de l'IVOA (http://www.ivoa.net/Documents/latest/VOT.html)
#
namespace eval ::votable {
   package provide votable 1.0

   # #############################################################################
   #
   # Implementation des attributs de l'espace de nom votable
   #
   # #############################################################################

   # @var string name-space du schema XML
   variable xmlSchemaNs "http://www.w3.org/2001/XMLSchema-instance"
   # @var string URI du schema VOTable
   variable votableSchemaNS
   # @var string URI de la feuille XSL (vide par defaut)
   variable xsluri
   # @var string Definition de l'espace de nom du data model
   variable dataModelNS
   # @var string Definition du prefixe de l'espace de nom du data model
   variable dataModelPrefix
   # @var string Version du schema VOTable
   variable votableVersion
   # @var string Prefixe des elements VOTable
   variable votablePrefix
   # @var string URL pointant sur le schema XML de la VOTable
   variable votableSchemaFile

   # #############################################################################
   #
   # Implementation de la grammaire VOTable dans l'espace de nom votable
   #
   # #############################################################################

   ## @namespace Element
   # @brief Definition des elements hierarchiques du schema VOTable, prefixe avec 'vot:'
   #
   namespace eval Element {
      variable VOTABLE     "VOTABLE"     ;#< Nom de l'element VOTABLE
      variable RESOURCE    "RESOURCE"    ;#< Nom de l'element RESOURCE   
      variable TABLE       "TABLE"       ;#< Nom de l'element TABLE      
      variable DATA        "DATA"        ;#< Nom de l'element DATA       
      variable TABLEDATA   "TABLEDATA"   ;#< Nom de l'element TABLEDATA  
      variable BINARY      "BINARY"      ;#< Nom de l'element BINARY     
      variable FITS        "FITS"        ;#< Nom de l'element FITS       
      variable GROUP       "GROUP"       ;#< Nom de l'element GROUP      
      variable PARAM       "PARAM"       ;#< Nom de l'element PARAM      
      variable FIELD       "FIELD"       ;#< Nom de l'element FIELD      
      variable VALUES      "VALUES"      ;#< Nom de l'element VALUES     
      variable DESCRIPTION "DESCRIPTION" ;#< Nom de l'element DESCRIPTION
      variable COOSYS      "COOSYS"      ;#< Nom de l'element COOSYS     
      variable INFO        "INFO"        ;#< Nom de l'element INFO       
      variable LINK        "LINK"        ;#< Nom de l'element LINK       
      variable TR          "TR"          ;#< Nom de l'element TR         
      variable TD          "TD"          ;#< Nom de l'element TD         
      variable STREAM      "STREAM"      ;#< Nom de l'element STREAM     
      variable FIELDREF    "FIELDref"    ;#< Nom de l'element FIELDREF   
      variable PARAMREF    "PARAMref"    ;#< Nom de l'element PARAMREF   
      variable MIN         "MIN"         ;#< Nom de l'element MIN        
      variable MAX         "MAX"         ;#< Nom de l'element MAX        
      variable OPTION      "OPTION"      ;#< Nom de l'element OPTION     
   }

   ## @namespace Resource
   # @brief Definition des attributs de l'element RESOURCE
   #
   namespace eval Resource {
      variable ID          "ID"          ;#< Nom de l'attribut ID    de l'element RESOURCE
      variable NAME        "name"        ;#< Nom de l'attribut NAME  de l'element RESOURCE
      variable UTYPE       "utype"       ;#< Nom de l'attribut UTYPE de l'element RESOURCE
      variable TYPE        "type"        ;#< Nom de l'attribut TYPE  de l'element RESOURCE
   }

   ## @namespace Table
   # @brief Definition des attributs de l'element TABLE
   #
   namespace eval Table {
      variable ID          "ID"          ;#< Nom de l'attribut ID    de l'element TABLE
      variable NAME        "name"        ;#< Nom de l'attribut NAME  de l'element TABLE
      variable UTYPE       "ucd"         ;#< Nom de l'attribut UTYPE de l'element TABLE
      variable TYPE        "utype"       ;#< Nom de l'attribut TYPE  de l'element TABLE
      variable REF         "ref"         ;#< Nom de l'attribut REF   de l'element TABLE
      variable NROWS       "nrows"       ;#< Nom de l'attribut NROWS de l'element TABLE
   }

   ## @namespace Stream
   # @brief Definition des attributs de l'element STREAM
   #
   namespace eval Stream {
      variable TYPE        "type"        ;#< Nom de l'attribut TYPE     de l'element STREAM
      variable HREF        "href"        ;#< Nom de l'attribut HREF     de l'element STREAM
      variable ACTUATE     "actuate"     ;#< Nom de l'attribut ACTUATE  de l'element STREAM
      variable ENCODING    "encoding"    ;#< Nom de l'attribut ENCODING de l'element STREAM
      variable EXPIRES     "expires"     ;#< Nom de l'attribut EXPIRES  de l'element STREAM
      variable RIGHTS      "rights"      ;#< Nom de l'attribut RIGHTS   de l'element STREAM
   }

   ## @namespace Fits
   # @brief Definition des attributs de l'element FITS
   #
   namespace eval Fits {
      variable EXTNUM      "extnum"      ;#< Nom de l'attribut EXTNUM de l'element FITS
   }

   ## @namespace CooSys
   # @brief Definition des attributs de l'element COOSYS
   #
   namespace eval CooSys {
      variable ID          "ID"          ;#< Nom de l'attribut ID      de l'element COOSYS (required)
      variable EQUINOX     "equinox"     ;#< Nom de l'attribut EQUINOX de l'element COOSYS
      variable EPOCH       "epoch"       ;#< Nom de l'attribut EPOCH   de l'element COOSYS
      variable SYSTEM      "system"      ;#< Nom de l'attribut SYSTEM  de l'element COOSYS
   }

   ## @namespace Group
   # @brief Definition des attributs de l'element GROUP
   #
   namespace eval Group {
      variable ID          "ID"          ;#< Nom de l'attribut ID    de l'element GROUP
      variable NAME        "name"        ;#< Nom de l'attribut NAME  de l'element GROUP
      variable REF         "ref"         ;#< Nom de l'attribut REF   de l'element GROUP
      variable UCD         "ucd"         ;#< Nom de l'attribut UCD   de l'element GROUP
      variable UTYPE       "utype"       ;#< Nom de l'attribut UTYPE de l'element GROUP
   }

   ## @namespace Param
   # @brief Definition des attributs de l'element PARAM
   #
   namespace eval Param {
      variable ID          "ID"           ;#< Nom de l'attribut ID        de l'element PARAM
      variable UNIT        "unit"         ;#< Nom de l'attribut UNIT      de l'element PARAM
      variable DATATYPE    "datatype"     ;#< Nom de l'attribut DATATYPE  de l'element PARAM (required)
      variable PRECISION   "precision"    ;#< Nom de l'attribut PRECISION de l'element PARAM
      variable WIDTH       "width"        ;#< Nom de l'attribut WIDTH     de l'element PARAM
      variable REF         "ref"          ;#< Nom de l'attribut REF       de l'element PARAM
      variable NAME        "name"         ;#< Nom de l'attribut NAME      de l'element PARAM (required)
      variable UCD         "ucd"          ;#< Nom de l'attribut UCD       de l'element PARAM
      variable UTYPE       "utype"        ;#< Nom de l'attribut UTYPE     de l'element PARAM
      variable ARRAYSIZE   "arraysize"    ;#< Nom de l'attribut ARRAYSIZE de l'element PARAM
      variable VALUE       "value"        ;#< Nom de l'attribut VALUE     de l'element PARAM (required)
   }

   ## @namespace ParamRef
   # @brief Definition des attributs de l'element PARAMREF
   #
   namespace eval ParamRef {
      variable REF         "ref"          ;#< Nom de l'attribut REF de l'element PARAMREF (required)
   }

   ## @namespace Field
   # @brief Definition des attributs de l'element FIELD
   #
   namespace eval Field {
      variable ID          "ID"           ;#< Nom de l'attribut ID        de l'element FIELD
      variable UNIT        "unit"         ;#< Nom de l'attribut UNIT      de l'element FIELD
      variable DATATYPE    "datatype"     ;#< Nom de l'attribut DATATYPE  de l'element FIELD (required)
      variable PRECISION   "precision"    ;#< Nom de l'attribut PRECISION de l'element FIELD
      variable WIDTH       "width"        ;#< Nom de l'attribut WIDTH     de l'element FIELD
      variable REF         "ref"          ;#< Nom de l'attribut REF       de l'element FIELD
      variable NAME        "name"         ;#< Nom de l'attribut NAME      de l'element FIELD (required)
      variable UCD         "ucd"          ;#< Nom de l'attribut UCD       de l'element FIELD
      variable UTYPE       "utype"        ;#< Nom de l'attribut UTYPE     de l'element FIELD
      variable ARRAYSIZE   "arraysize"    ;#< Nom de l'attribut ARRAYSIZE de l'element FIELD
      variable TYPE        "type"         ;#< Nom de l'attribut TYPE      de l'element FIELD
   }

   ## @namespace FieldRef
   # @brief Definition des attributs de l'element FIELDREF
   #
   namespace eval FieldRef {
      variable REF         "ref"          ;#< Nom de l'attribut REF de l'element FIELDREF (required)
   }

   ## @namespace Values
   # @brief Definition des attributs de l'element VALUES
   #
   namespace eval Values {
      variable ID          "ID"           ;#< Nom de l'attribut ID   de l'element VALUES
      variable TYPE        "type"         ;#< Nom de l'attribut TYPE de l'element VALUES
      variable NULL        "null"         ;#< Nom de l'attribut NULL de l'element VALUES
      variable REF         "ref"          ;#< Nom de l'attribut REF  de l'element VALUES
   }

   ## @namespace Info
   # @brief Definition des attributs de l'element INFO
   #
   namespace eval Info {
      variable ID          "ID"           ;#< Nom de l'attribut ID    de l'element INFO
      variable NAME        "name"         ;#< Nom de l'attribut NAME  de l'element INFO
      variable VALUE       "value"        ;#< Nom de l'attribut VALUE de l'element INFO
   }

   ## @namespace Link
   # @brief Definition des attributs de l'element LINK
   #
   namespace eval Link {
      variable ID          "ID"           ;#< Nom de l'attribut ID          de l'element LINK
      variable CONTENTROLE "content-role" ;#< Nom de l'attribut CONTENTROLE de l'element LINK
      variable CONTENTTYPE "content-type" ;#< Nom de l'attribut CONTENTTYPE de l'element LINK
      variable TITLE       "title"        ;#< Nom de l'attribut TITLE       de l'element LINK
      variable VALUE       "value"        ;#< Nom de l'attribut VALUE       de l'element LINK
      variable HREF        "href"         ;#< Nom de l'attribut HREF        de l'element LINK
      variable ACTION      "action"       ;#< Nom de l'attribut ACTION      de l'element LINK
   }

   ## @namespace Min
   # @brief Definition des attributs de l'element MIN
   #
   namespace eval Min {
      variable VALUE       "value"        ;#< Nom de l'attribut VALUE     de l'element MIN (required)
      variable INCLUSIVE   "inclusive"    ;#< Nom de l'attribut INCLUSIVE de l'element MIN
   }

   ## @namespace Max
   # @brief Definition des attributs de l'element MAX
   #
   namespace eval Max {
      variable VALUE       "value"        ;#< Nom de l'attribut VALUE     de l'element MAX (required)
      variable INCLUSIVE   "inclusive"    ;#< Nom de l'attribut INCLUSIVE de l'element MAX
   }

   ## @namespace Option
   # @brief Definition des attributs de l'element OPTION
   #
   namespace eval Option {
      variable NAME        "name"         ;#< Nom de l'attribut NAME  de l'element OPTION
      variable VALUE       "value"        ;#< Nom de l'attribut VALUE de l'element OPTION (required)
   }

}

# #############################################################################
#
# Implementation des methodes de l'espace de nom votable
#
# #############################################################################

## @brief Constructeur de classe
# @param version string versionnage de la VOTable (default 1.1)
# @param prefix  string prefixe des elements de la VOTable (default vot:)
# @param xsluri  string URI de la feuille de style XSL (default null)
# @param dmNS    string namespace du data model utilise (default null)
#
proc ::votable::init { {version 1.1} {prefix "vot:"} {xsluri ""} {dmNS ""} } {
   # Version VOTable
   set ::votable::votableVersion $version
   # Prefixe VOTable
   set ::votable::votablePrefix $prefix
   # Namespace VOTable
   set ::votable::votableSchemaNS [join [list "http://www.ivoa.net/xml/VOTable/v" $version] ""]
   # Schema VOTable
   set ::votable::votableSchemaFile [join [list "http://www.ivoa.net/xml/VOTable/VOTable-" $version ".xsd"] ""]
   # XSL stylesheet URI
   set ::votable::xsluri $xsluri
   # Definition du prefixe de l'espace de nom du data model
   set ::votable::dataModelNS $dmNS
}


## @brief Macro-fonction d'ouverture de la VOTable
# @return string element d'ouverture de la VOTable (jusqu'a l'element VOTABLE)
#
proc ::votable::openVOTable { } {
   set v [::votable::addXMLHeader]
   if [string length $::votable::xsluri] {
      set v [join [list $v [::votable::addXSLSheet]] ""]
   }
   set v [join [list $v [::votable::openVOTableElement]] ""]
   return $v;
}


## @brief Macro-fonction de fermeture de la VOTable
# @return string elements de fermeture de la VOTable
#
proc ::votable::closeVOTable { } {
   return [::votable::closeVOTableElement]
}


## @brief Definition du type de contenu d'une VOTable (Content-type: text/xml)
# @return string entete text/xml
#
proc ::votable::getHeader { } {
   return "header(\"Content-type: application/x-votable+xml\")"
}


## @brief Declaration de l'entete XML du document
# @return string entete xml du document
#
proc ::votable::addXMLHeader { } {
   return "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"
}


## @brief Declaration de l'utilisation du feuille XSL
# @return string element xml-stylesheet pour l'utilisation d'une feuille XSL
#
proc ::votable::addXSLSheet { } {
   return [join [list "<?xml-stylesheet href=\"" $::votable::xsluri "\" type=\"text/xsl\"?>\n"] ""]
}


## @brief Ouverture de l'element VOTABLE (element ouvert qui doit etre ferme avec la methode closeVOTableElement)
# @return string ouverture de l'element VOTABLE
#
proc ::votable::openVOTableElement { } {
   set o [join [list "<" $::votable::votablePrefix "VOTABLE version=\"" $::votable::votableVersion "\""] ""]
   set o [join [list $o " xmlns:xsi=\"" $::votable::xmlSchemaNs "\""] ""]
   if {[string length $::votable::votablePrefix] > 0} {
      set o [join [list $o " xmlns:" [string range $::votable::votablePrefix 0 [expr [string length $::votable::votablePrefix]-2]] "=\"" $::votable::votableSchemaNS "\""] ""]
      set o [join [list $o " xsi:schemaLocation=\"" $::votable::votableSchemaNS " " $::votable::votableSchemaFile "\""] ""]
   } else {
      set o [join [list $o " xsi:noNamespaceSchemaLocation=\"" $::votable::votableSchemaNS "/v" $::votable::votableVersion "\""] ""]
   }
   if {[string length $::votable::dataModelNS] > 0} {
      set o [join [list $o " xmlns:" $::votable::dataModelPrefix "=\"" $::votable::dataModelNS "\""] ""]
   }
   set o [join [list $o ">\n"] ""]
   return $o
}


## @brief Fermeture de l'element VOTABLE
# @return string fermeture de l'element VOTABLE
#
proc ::votable::closeVOTableElement { } {
   return [::votable::closeElement $::votable::Element::VOTABLE]
}


## @brief Ouverture de l'element RESOURCE (element ouvert a fermer avec la methode closeResourceElement)
# @param attributes list liste des attributs de l'element RESOURCE sous forme de listes (e.g. [list "$::votable::Resource::NAME" "ResourceName"])
# @return string ouverture de l'element RESOURCE
#
proc ::votable::openResourceElement { attributes } {
   return [::votable::attributesUnclosedElement $::votable::Element::RESOURCE $attributes]
}


## @brief Fermeture de l'element RESOURCE
# @return string fermeture de l'element RESOURCE
#
proc ::votable::closeResourceElement { } {
   return [::votable::closeElement $::votable::Element::RESOURCE]
}


## @brief Ajout d'un element INFO
# @param id    string valeur de l'attribut ID de l'element Info
# @param name  string valeur de l'attribut NAME de l'element Info
# @param value string valeur de l'attribut VALUE de l'element Info
# @return string
#
proc ::votable::addInfoElement { id name value } {
   return [::votable::attributesClosedElement $::votable::Element::INFO [list "$::votable::Info::ID $id" "$::votable::Info::NAME $name" "$::votable::Info::VALUE $value"]]
}


## @brief Ajout d'un element PARAM
# @param attributes  list   liste des attributs de l'element PARAM (e.g. [list "$::votable::Param::ID" "idParam"])
# @param description string description a ajouter dans l'element PARAM (optionnel)
# @param values      string valeur a ajouter dans l'element PARAM (optionnel)
# @param link        list   liste des attributs de l'element LINK a ajouter dans l'element FIELD (optionnel)
# @return string
#
proc ::votable::addParamElement { attributes description values link } {
   if {[string length $description] == 0 &&
        [string length $values] == 0 &&
        [string length $link] == 0} {
      set p [::votable::attributesClosedElement $::votable::Element::PARAM $attributes]
   } else {
      set p [::votable::attributesUnclosedElement $::votable::Element::PARAM $attributes]
      if {[string length $description] > 0} {
         set p [join [list $p [::votable::addElement $::votable::Element::DESCRIPTION "" $description]] ""]
      }
      if {[string length $values] > 0} {
         set p [join [list $p [::votable::addElement $::votable::Element::VALUES "" $values]] ""]
      }
      if {[string length $link] > 0} {
         set p [join [list $p [::votable::addElement $::votable::Element::LINK $link ""]] ""]
      }
      set p [join [list $p [::votable::closeElement $::votable::Element::PARAM]] ""]
   }
   return $p
}


## @brief Ouverture de l'element TABLE (element ouvert a fermer avec la methode closeTableElement)
# @param attributes list liste des attributs de l'element TABLE (e.g. [list "$::votable::Table::ID" "idTable"])
# @return string ouverture de l'element TABLE
#
proc ::votable::openTableElement { attributes } {
   return [::votable::openElement $::votable::Element::TABLE $attributes]
}


## @brief Fermeture de l'element TABLE
# @return string fermeture de l'element TABLE
#
proc ::votable::closeTableElement { } {
   return [::votable::closeElement $::votable::Element::TABLE]
}


## @brief Ajout d'un element FIELD
# @param attributes  list   liste des attributs de l'element FIELD (e.g. [list "$::votable::Field::ID" "idField"])
# @param description string description a ajouter dans l'element FIELD (optionnel)
# @param values      string valeur a ajouter dans l'element FIELD (optionnel)
# @param link        list   liste des attributs de l'element LINK a ajouter dans l'element FIELD (optionnel)
# @return string element FIELD
#
proc ::votable::addFieldElement { attributes description values link } {
   if {[string length $description] == 0 &&
        [string length $values] == 0 &&
        [string length $link] == 0} {
      set p [::votable::attributesClosedElement $::votable::Element::FIELD $attributes]
    } else {
      set p [::votable::attributesUnclosedElement $::votable::Element::FIELD $attributes]
      if {[string length $description] > 0} {
         set p [join [list $p [::votable::addElement $::votable::Element::DESCRIPTION "" $description]] ""]
      }
      if {[string length $values] > 0} {
         set p [join [list $p [::votable::addElement $::votable::Element::VALUES "" $values]] ""]
      }
      if {[string length $link] > 0} {
         set p [join [list $p [::votable::addElement $::votable::Element::LINK $link ""]] ""]
      }
      set p [join [list $p [::votable::closeElement $::votable::Element::FIELD]] ""]
    }
    return $p
}


## @brief Ajout d'un element GROUP
# @param attributes  list   liste des attributs de l'element GROUP (e.g. [list "$::votable::Group::ID" "idGroup"])
# @param description string description (optionnelle) de l'element FIELD
# @param fieldRef    list   liste des references aux elements FIELD (e.g. [list [list "$::votable::FieldRef::REF" "x"] [list "$::votable::FieldRef::REF" "y"] ...])
# @param param       list   liste des attributs d'un element PARAM a ajouter dans l'element GROUP
# @param paramRef    list   liste des references a des parametres (e.g. [list [list "$::votable::ParamRef::REF" "x"] [list "$::votable::ParamRef::REF" "y"] ...])
# @return string element GROUP
#
proc ::votable::addGroupElement { attributes description fieldRef param paramRef } {
   set p [::votable::attributesUnclosedElement $::votable::Element::GROUP $attributes]
   if {[string length $description] > 0} {
      set p [join [list $p [::votable::addElement $::votable::Element::DESCRIPTION "" $description]] ""]
   }
   if {[string length $param] > 0} {
      set p [join [list $p [::votable::addParamElement $param "" "" ""]] ""]
   }
   foreach f $fieldRef {
      set p [join [list $p [::votable::attributesClosedElement $::votable::Element::FIELDREF [lindex $f 1]]] ""]
   }
   if {[string length $paramRef] > 0} {
      foreach p $paramRef {
         set p [join [list $p [::votable::attributesClosedElement $::votable::Element::PARAMREF [lindex $p 1]]] ""]
      }
   }
   set p [join [list $p [::votable::closeElement $::votable::Element::GROUP]] ""]
   return $p
}


## @brief Ajout d'un element avec ou sans attribut et avec ou sans valeur
# @param elementName string nom de l'element (e.g. "$::votable::Element::<VAR>")
# @param attributes  list   liste des attributs de l'element elementName (e.g. [list "$::votable::Element::ID" "idElem"])
# @param value       string valeur a inserer dans l'element
# @return string element ferme
#
proc ::votable::addElement { elementName attributes value } {
   if {[string length $value] > 0} {
      set p [join [list [::votable::attributesUnclosedElement $elementName $attributes] $value [::votable::closeElement $elementName]] ""]
   } else {
      set p [join [list [::votable::attributesClosedElement $elementName $attributes]] ""]
   }
   return $p
}


## @brief Ouverture d'un element avec ou sans attribut (element ouvert a fermer avec la methode closeElement)
# @param elementName string nom de l'element a ouvrir (e.g. "$::votable::Element::<VAR>")
# @param attributes  list   liste des attributs de l'element elementName (e.g. [list "$::votable::Element::ID" "idElem"])
# @return string element ouvert
#
proc ::votable::openElement { elementName attributes } {
   if {[info exists attributes]} {
      set p [join [list [::votable::attributesUnclosedElement $elementName $attributes]] ""]
   } else {
      set p [join [list "<" $::votable::votablePrefix $elementName ">"] ""]
   }
   return $p
}


## @brief Fermeture d'un element (ouvert avec la methode openElement)
# @param elementName string nom de l'element a fermer (e.g. "$::votable::Element::<VAR>")
# @return string fermeture de l'element
#
proc ::votable::closeElement { elementName } {
   return [join [list "</" $::votable::votablePrefix $elementName ">"] ""]
}


## @brief Ajout d'un element TD
# @param content string valeur a inserer dans une cellule de la table
# @return string element TD
#
proc ::votable::addTD { content } {
   return [join [list [::votable::openElement $::votable::Element::TD ""] $content [::votable::closeElement $::votable::Element::TD]] ""]
}


## @brief Construction partielle d'un element avec ses attributs
# @param elementName string nom de l'element a affecter (e.g. "$::votable::Element::<VAR>")
# @param attributes  list   liste des attributs de l'element $elementNameE (e.g. [list "$::votable::Element::ID" "idElem"])
# @return string element partiel
#
proc ::votable::attributes { elementName attributes } {
   set element [join [list "<" $::votable::votablePrefix $elementName] ""]
   if {[info exists attributes]} {
      foreach a $attributes {
         set element [join [list $element " " [lindex $a 0] "=\"" [lindex $a 1] "\" "] ""]
      }
   }
   return [string trim $element]
}


## @brief Construction d'un element ouvert avec ses attributs
# @param elementName string nom de l'element a affecter (e.g. "$::votable::Element::<VAR>")
# @param attributes  list   liste des attributs de l'element $elementName (e.g. [list "$::votable::Element::ID" "idElem"])
# @return string element ouvert
#
proc ::votable::attributesUnclosedElement { elementName attributes } {
   return [join [list [::votable::attributes $elementName $attributes] ">"] ""]
}


## @brief Construction d'un element ferme avec ses attributs
# @param elementName string nom de l'element a affecter (e.g. "$::votable::Element::<VAR>")
# @param attributes  list   liste des attributs de l'element $elementName (e.g. [list "$::votable::Element::ID" "idElem"])
# @return string element ferme
#
proc ::votable::attributesClosedElement { elementName attributes } {
   return [join [list [::votable::attributes $elementName $attributes] "/>"] ""]
}


## @brief Construction des elements FIELDS en fonction de la cle de la colonne
# @param table string nom de la table contenant la cle
# @param key   string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey { table key } {
   switch $table {
      IMG       { set f [::votable::getFieldFromKey_IMG $key] }      
      USNOA2    { set f [::votable::getFieldFromKey_USNOA2 $key] }      
      NOMAD1    { set f [::votable::getFieldFromKey_NOMAD1 $key] }      
      TYCHO2    { set f [::votable::getFieldFromKey_TYCHO2 $key] }      
      UCAC2     { set f [::votable::getFieldFromKey_UCAC2 $key] }      
      UCAC3     { set f [::votable::getFieldFromKey_UCAC3 $key] }
      UCAC4     { set f [::votable::getFieldFromKey_UCAC4 $key] }
      PPMX      { set f [::votable::getFieldFromKey_PPMX $key] }
      PPMXL     { set f [::votable::getFieldFromKey_PPMXL $key] }
      2MASS     { set f [::votable::getFieldFromKey_2MASS $key] }
      WFIBC     { set f [::votable::getFieldFromKey_WFIBC $key] }
      SDSS      { set f [::votable::getFieldFromKey_SDSS $key] }
      PANSTARRS { set f [::votable::getFieldFromKey_PANSTARRS $key] }
      GAIA1     { set f [::votable::getFieldFromKey_GAIA1 $key] }
      SKYBOT    { set f [::votable::getFieldFromKey_SKYBOT $key] }
      OVNI      { set f [::votable::getFieldFromKey_OVNI $key] }
      ASTROID   { set f [::votable::getFieldFromKey_ASTROID $key] }
      BINAST    { set f [::votable::getFieldFromKey_BINAST $key] }
      USER      { set f [::votable::getFieldFromKey_USER $key] }
      default   { set f [::votable::getFieldFromKey_DEFAULT $key] }
   }
}


## @brief Construction des elements FIELDS en fonction de la cle de la colonne
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey_DEFAULT { key } {
   set keyval [split $key "."]
   switch [lindex $keyval 0] {
      idcataspec {
         set description "Source index"
         set idk "[lindex $keyval 0].[string toupper [lindex $keyval 1]]"
         set field [ list "$::votable::Field::ID $idk" \
                          "$::votable::Field::NAME $idk" \
                          "$::votable::Field::UCD \"meta.id;meta.number\"" \
                          "$::votable::Field::DATATYPE \"int\"" \
                          "$::votable::Field::WIDTH \"6\"" ]
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set description ""
         set field ""
      }
   }
   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}


## @brief Construction des elements FIELDS en fonction de la cle de la colonne pour le cataloguye IMG
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey_IMG { key } {
   # Id et Nom du champ
   set field [list "$::votable::Field::ID ${key}.IMG" "$::votable::Field::NAME $key"]
   # Autres infos 
   switch $key {
      id {
         set description "Source identifier"
         lappend field "$::votable::Field::UCD \"meta.id;meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"6\""
      }
      flag {
         set description "Matching flag: 1=seen on image only, 3=seen on image+catalog, 2=seen on catalog only"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"6\""
      }
      xpos -
      ypos {
         set description "Cartesian coordinate of the source in the image (add 1 to be in image coordinates)"
         lappend field "$::votable::Field::UCD \"pos.cartesian.[string index $key 0]\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"pixel\""
      }
      instr_mag {
         set description "Instrumental magnitude -2.5*log(flux) by Sextractor"
         lappend field "$::votable::Field::UCD \"phot.mag\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\""
      }
      err_mag {
         set description "Uncertainty of the instrumental measured magnitude by Sextractor"
         lappend field "$::votable::Field::UCD \"stat.error;phot.mag\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\""
      }
      flux_sex {
         set description "Measured flux of the source by Sextractor"
         lappend field "$::votable::Field::UCD \"phot.count\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"ADU\""
      }
      err_flux_sex {
         set description "Uncertainty of the measured source flux by Sextractor"
         lappend field "$::votable::Field::UCD \"stat.error;phot.count\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"ADU\""
      }
      ra -
      dec {
         if {[string equal -nocase $key "ra"]} {
            set description "Astrometric J2000 right ascension"
         } else {
            set description "Astrometric J2000 declination"
         }
         lappend field "$::votable::Field::UCD \"pos.eq.$key;meta.main\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"9\"" \
                       "$::votable::Field::PRECISION \"5\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      calib_mag -
      calib_mag_ss1 -
      calib_mag_ss2 {
         set description "Calibrated magnitude (relative to R band) with a superstar method "
         if {[string equal -nocase $key "calib_mag"]} { set description "Calibrated magnitude (relative to R band) with a simple constant " }
         if {[string equal -nocase $key "calib_mag_ss1"]} { append description " 1" }
         if {[string equal -nocase $key "calib_mag_ss2"]} { append description " 2" }
         lappend field "$::votable::Field::UCD \"phot.mag\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"4\""
      }
      err_calib_mag_ss1 -
      err_calib_mag_ss2 {
         set description "Uncertainty of the calibrated magnitude of the superstar method "
         if {[string equal -nocase $key "err_calib_mag_ss1"]} { append description " 1" }
         if {[string equal -nocase $key "err_calib_mag_ss2"]} { append description " 2" }
         lappend field "$::votable::Field::UCD \"stat.error;phot.mag\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"4\""
      }
      nb_neighbours {
         set description "Nb neighbours for superstar methods"
         lappend field "$::votable::Field::UCD \"\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"4\""
      }
      radius {
         set description "Radius around star where superstar is computed"
         lappend field "$::votable::Field::UCD \"\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"4\"" \
                       "$::votable::Field::UNIT \"pixel\""
      }
      background_sex {
         set description "Background estimated by Sextractor"
         lappend field "$::votable::Field::UCD \"\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"adu\""
      }
      x2_momentum_sex -
      y2_momentum_sex -
      xy_momentum_sex {
         if {[string equal -nocase $key "x2_momentum_sex"]} { set description "x2 momentum estimated by Sextractor" }
         if {[string equal -nocase $key "y2_momentum_sex"]} { set description "y2 momentum estimated by Sextractor" }
         if {[string equal -nocase $key "xy_momentum_sex"]} { set description "xy momentum estimated by Sextractor" }
         lappend field "$::votable::Field::UCD \"\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\""
      }
      minor_axis_sex -
      major_axis_sex {
         set description [expr [string equal -nocase $key "minor_axis_sex"] ? {"Minor axis of ellipse estimated by Sextractor"} : {"Major axis of ellipse estimated by Sextractor"}]
         set ucd [expr [string equal -nocase $key "minor_axis_sex"] ? {"stat.stdev;stat.min;pos.errorEllipse"} : {"stat.stdev;stat.max;pos.errorEllipse"}]
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"pixel\""
      }
      position_angle_sex {
         set description "Position angle of ellipse estimated by Sextractor"
         lappend field "$::votable::Field::UCD \"pos.posAng\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      fwhm_sex {
         set description "FWHM of the source measured by Sextractor"
         lappend field "$::votable::Field::UCD \"phys.angSize\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"pixel\""
      }
      flag_sex {
         set description "Sextractor flag (0=no problem, +1=neighbor, +2=linked, +4=satured, +8=border, +16=badpix, >=+32=memory)"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"short\"" \
                       "$::votable::Field::WIDTH \"2\""
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set field ""
         set description ""
      }
   }
   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}


## @brief Construction des elements FIELDS en fonction de la cle de la colonne pour le cataloguye USNO-A2
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey_USNOA2 { key } {
   # Id et Nom du champ
   set field [list "$::votable::Field::ID ${key}.USNOA2" "$::votable::Field::NAME $key"]
   # Autres infos  ID ra_deg dec_deg sign qflag field magB magR
   switch $key {
      ID {
         set description "USNOA2 identifier"
         lappend field "$::votable::Field::UCD \"meta.id;meta.number\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"13\"" 
      }
      ra_deg -
      dec_deg {
         if {[string equal -nocase $key "ra_deg"]} {
            set description "Astrometric J2000 right ascension"
         } else {
            set description "Astrometric J2000 declination"
         }
         lappend field "$::votable::Field::UCD \"pos.eq.$key;meta.main\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"9\"" \
                       "$::votable::Field::PRECISION \"5\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      sign {
         set description "Sign is 1 if this entry is correlated with an ACT star"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"2\"" \
                       "$::votable::Field::UNIT \"-\""
      }
      qflag {
         set description "Indicates that the magnitude(s) might be in error (0 if things looked OK)"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"3\"" \
                       "$::votable::Field::UNIT \"-\""
      }
      field {
         set description "Field on which this object was detected."
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"3\"" \
                       "$::votable::Field::UNIT \"-\""
      }
      magB -
      magR {
         set description "[string range $key end end] magnitude"
         lappend field "$::votable::Field::UCD \"phot.mag;em.opt.[string range $key end end]\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set field ""
         set description ""
      }
   }
   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}



## @brief Construction des elements FIELDS en fonction de la cle de la colonne pour le cataloguye NOMAD1
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
proc ::votable::getFieldFromKey_NOMAD1 { key } {
   # Id et Nom du champ
   set field [list "$::votable::Field::ID ${key}.NOMAD1" "$::votable::Field::NAME $key"]
   # Autres infos 
   switch $key {
      ID {
         set description "NOMAD-identifier"
         lappend field "$::votable::Field::UCD \"meta.id;meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"12\""
      }
      oriAstro {
         set description "?"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"1\"" 
      }
      RAJ2000 -
      DECJ2000 {
         if {[string equal -nocase $key "RAJ2000"]} {
            set description "Right ascension in ICRS, Ep=J2000"
         } else {
            set description "Declination in ICRS, Ep=J2000"
         }
         lappend field "$::votable::Field::UCD \"pos.eq.$key;meta.main\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"11\"" \
                       "$::votable::Field::PRECISION \"7\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      errRa -
      errDec {
         if {[string equal -nocase $key "errRa"]} {
            set description "Mean error on RAJ2000 (at epRAJ2000)"
            set ucd "stat.error;pos.eq.ra"
         } else {
            set description "Mean error on DECJ2000 (at epDECJ2000)"
            set ucd "stat.error;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"10\"" \
                       "$::votable::Field::PRECISION \"6\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      pmRA -
      pmDE {
         if {[string equal -nocase $key "pmRA"]} {
            set description "Proper Motion in RAJ2000*cos(DECJ2000)"
            set ucd "pos.pm;pos.eq.ra"
         } else {
            set description "Proper motion in DECJ2000"
            set ucd "pos.pm;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas/yr\""
      }
      errPmRa -
      errPmDec {
         if {[string equal -nocase $key "errPmRa"]} {
            set description "Mean error pmRA)"
            set ucd "stat.error;pos.pm;pos.eq.ra"
         } else {
            set description "Mean error on pmDE"
            set ucd "stat.error;pos.pm;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas/yr\""
      }
      epochRa -
      epochDec {
         if {[string equal -nocase $key "epochRa"]} {
            set description "Mean epoch of RAJ2000"
         } else {
            set description "Mean epoch of DECJ2000"
         }
         lappend field "$::votable::Field::UCD \"time.epoch\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"7\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"yr\""
      }
      oriMagB -
      oriMagV -
      oriMagR {
         set description "Origin of [string index $key end] magnitude"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"1\"" 
      }
      magB -
      magV -
      magR -
      magJ -
      magH -
      magK {
         switch $key {
            "magR" { 
               set description "Red magnitude" 
               set ucd "phot.mag;em.opt.R"
            }
            "magB" { 
               set description "Blue magnitude" 
               set ucd "phot.mag;em.opt.B"
            }
            "magV" { 
               set description "Visual magnitude" 
               set ucd "phot.mag;em.opt.V"
            }
            "magJ" { 
               set description "Infrared J magnitude from 2MASS" 
               set ucd "phot.mag;em.IR.J"
            }
            "magH" { 
               set description "Infrared H magnitude from 2MASS" 
               set ucd "phot.mag;em.IR.H"
            }
            "magK" { 
               set description "Infrared Ks magnitude from 2MASS" 
               set ucd "phot.mag;em.IR.K"
            }
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      idUCAC2 {
         set description "Number in UCAC2 (Cat. I/289)" 
         lappend field "$::votable::Field::UCD \"meta.id.part;meta.main\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"8\""
      }
      idHIP - 
      idTYC1 -
      idTYC2 -
      idTYC3 {
         switch $key {
            "idHIP" { 
               set description "Identification in Hipparcos" 
            }
            "idTYC1" { 
               set description "Identification in Tycho-2 (TYC1)" 
            }
            "idTYC2" { 
               set description "Identification in Tycho-2 (TYC2)" 
            }
            "idTYC3" { 
               set description "Identification in Tycho-2 (TYC3)" 
            }
         }
         lappend field "$::votable::Field::UCD \"meta.id.part;meta.main\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"12\"" 
      }
      flagDistTYC {
         set description "When distance NOMAD1/Tycho-2 > 1arcsec"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"1\""
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set field ""
         set description ""
      }
   }
   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}


## @brief Construction des elements FIELDS en fonction de la cle de la colonne pour le cataloguye TYCHO2
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey_TYCHO2 { key } {

   # Id et Nom du champ
   set field [list "$::votable::Field::ID ${key}.TYCHO2" "$::votable::Field::NAME $key"]
   # Autres infos 
   switch $key {
      ID {
         set description "Tycho-2 identifier"
         lappend field "$::votable::Field::UCD \"meta.id;meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"6\""
      }
      TYC1 -
      TYC2 - 
      TYC3 {
         set description "$key from TYC or GSC"
         lappend field "$::votable::Field::UCD \"meta.id.part;meta.main\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"6\""
      }
      pflag {
         set description "Mean position flag"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"6\"" 
      }
      mRAdeg -
      mDEdeg {
         if {[string equal -nocase $key "mRAdeg"]} {
            set description "Mean Right Asc, ICRS, epoch=J2000"
            set ucd "pos.eq.ra;meta.main"
         } else {
            set description "Mean Decl, ICRS, at epoch=J2000"
            set ucd "pos.eq.dec;meta.main"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"9\"" \
                       "$::votable::Field::PRECISION \"5\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      pmRA -
      pmDE {
         if {[string equal -nocase $key "pmRA"]} {
            set description "Prop. mot. in RA*cos(dec)"
            set ucd "pos.pm;pos.eq.ra"
         } else {
            set description "Prop. mot. in DEC"
            set ucd "pos.pm;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas/yr\""
      }
      e_mRA -
      e_mDE {
         if {[string equal -nocase $key "e_mRA"]} {
            set description "s.e. RA*cos(dec), at mean epoch"
         } else {
            set description "s.e. DEC, at mean epoch"
         }
         lappend field "$::votable::Field::UCD \"stat.error\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      e_pmRA -
      e_pmDE {
         if {[string equal -nocase $key "e_pmRA"]} {
            set description "s.e. prop mot in RA*cos(dec)"
         } else {
            set description "s.e. prop mot in DEC"
         }
         lappend field "$::votable::Field::UCD \"stat.error\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas/yr\""
      }
      mepRA -
      mepDE {
         if {[string equal -nocase $key "mepRA"]} {
            set description "Mean epoch of RA"
         } else {
            set description "Mean epoch of DEC"
         }
         lappend field "$::votable::Field::UCD \"time.epoch\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"yr\""
      }
      Num {
         set description "Number of positions used"
         lappend field "$::votable::Field::UCD \"meta.id\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"8\""
      }
      g_mRA -
      g_mDE -
      g_pmRA -
      g_pmDE {
         if {[string equal -nocase $key "g_mRA"]}  { set description "Goodness of fit for mean RA" }
         if {[string equal -nocase $key "g_mDE"]}  { set description "Goodness of fit for mean DEC" }
         if {[string equal -nocase $key "g_pmRA"]} { set description "Goodness of fit for pmRA" }
         if {[string equal -nocase $key "g_pmDE"]} { set description "Goodness of fit for pmDEC" }
         lappend field "$::votable::Field::UCD \"meta.code.qual\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\""
      }
      BT {
         set description "Tycho-2 BT magnitude"
         lappend field "$::votable::Field::UCD \"phot.mag;em.opt.B\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      e_BT {
         set description "s.e. of BT"
         lappend field "$::votable::Field::UCD \"stat.error\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      VT {
         set description "Tycho-2 VT magnitude"
         lappend field "$::votable::Field::UCD \"phot.mag;em.opt.V\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      e_VT {
         set description "s.e. of VT"
         lappend field "$::votable::Field::UCD \"stat.error\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      prox {
         set description "Proximity indicator"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"3\""
      }
      TYC {
         set description "Tycho-1 star"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"1\"" 
      }
      HIP {
         set description "Hipparcos number"
         lappend field "$::votable::Field::UCD \"meta.id\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"6\""
      } 
      CCDM {
         set description "CCDM component identifier for HIP stars"
         lappend field "$::votable::Field::UCD \"meta.code.multip\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"32\"" 
      }
      RAdeg -
      DEdeg {
         if {[string equal -nocase $key "RAdeg"]} {
            set description "Observed Tycho-2 Right Ascension, ICRS"
            set ucd "pos.eq.ra;meta.main"
         } else {
            set description "Observed Tycho-2 Declination, ICRS"
            set ucd "pos.eq.dec;meta.main"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"12\"" \
                       "$::votable::Field::PRECISION \"8\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      epRA -
      epDE {
         if {[string equal -nocase $key "epRA"]} {
            set description "Epoch-1990 of RAdeg"
         } else {
            set description "Epoch-1990 of DEdeg"
         }
         lappend field "$::votable::Field::UCD \"time.epoch\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"yr\""
      }
      e_RA -
      e_DE {
         if {[string equal -nocase $key "e_RA"]} {
            set description "s.e. RA*cos(dec), of observed Tycho-2 RA"
         } else {
            set description "s.e. DEC, of observed Tycho-2 DEC"
         }
         lappend field "$::votable::Field::UCD \"stat.error\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      posflg {
         set description "Type of Tycho-2 solution"
         lappend field "$::votable::Field::UCD \"meta.id;stat.fit\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"1\"" 
      }
      corr {
         set description "Correlation (RAdeg,DEdeg)"
         lappend field "$::votable::Field::UCD \"stat.correlation\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::WIDTH \"4\""
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set field ""
         set description ""
      }
   }
   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}


## @brief Construction des elements FIELDS en fonction de la cle de la colonne pour le cataloguye UCAC2
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey_UCAC2 { key } {

   # Id et Nom du champ
   set field [list "$::votable::Field::ID ${key}.UCAC2" "$::votable::Field::NAME $key"]
   # Autres infos 
   switch $key {
      ID {
         set description "UCAC2 identifier"
         lappend field "$::votable::Field::UCD \"meta.id;meta.number\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"10\""
      }
      ra_deg -
      dec_deg {
         if {[string equal -nocase $key "ra"]} {
            set description "Astrometric J2000 right ascension"
         } else {
            set description "Astrometric J2000 declination"
         }
         lappend field "$::votable::Field::UCD \"pos.eq.$key;meta.main\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"9\"" \
                       "$::votable::Field::PRECISION \"5\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      U2Rmag_mag {
         set description "Internal UCAC magnitude (red bandpass)"
         lappend field "$::votable::Field::UCD \"phot.mag;em.opt.V\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      e_RAm_deg -
      e_DEm_deg {
         if {[string equal -nocase $key "e_RAm_deg"]} {
            set description "s.e. at central epoch in RA (*cos DEm)"
         } else {
            set description "s.e. at central epoch in Dec"
         }
         lappend field "$::votable::Field::UCD \"stat.error\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      nobs {
         set description "Number of UCAC observations of this star"
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"6\""
      }
      e_pos_deg {
         set description "Error of original UCAC observation"
         lappend field "$::votable::Field::UCD \"stat.error\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      ncat {
         set description "Number of catalog positions used for pmRA, pmDC"
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"6\""
      }
      cflg {
         set description "ID of major catalogs used in pmRA, pmDE"
         lappend field "$::votable::Field::UCD \"meta.id;meta.dataset\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"6\""
      }
      EpRAm_deg -
      EpDEm_deg {
         if {[string equal -nocase $key "EpRAm_deg"]} {
            set description "Central epoch for mean RA, minus 1975"
         } else {
            set description "Central epoch for mean DE, minus 1975"
         }
         lappend field "$::votable::Field::UCD \"time.epoch\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"yr\""
      }
      pmRA_masperyear -
      pmDEC_masperyear {
         if {[string equal -nocase $key "pmRA_masperyear"]} {
            set description "Proper motion in RA (no cos DE)"
            set ucd "pos.pm;pos.eq.ra"
         } else {
            set description "Proper motion in DE"
            set ucd "pos.pm;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas/yr\""
      }
      e_pmRA_masperyear -
      e_pmDE_masperyear {
         if {[string equal -nocase $key "e_pmRA_masperyear"]} {
            set description "s.e. of pmRA*cos(DEm)"
         } else {
            set description "s.e. of pmDE"
         }
         lappend field "$::votable::Field::UCD \"stat.error\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas/yr\""
      }
      q_pmRA -
      q_pmDE {
         if {[string equal -nocase $key "q_pmRA"]}  { 
            set description "Goodness of fit for pmRA" 
         } else {
            set description "Goodness of fit for pmDE" 
         }
         lappend field "$::votable::Field::UCD \"stat.fit.goodness\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\""
      }
      2m_id {
         set description "2MASS (II/246) Unique source identifier"
         lappend field "$::votable::Field::UCD \"meta.id.cross\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"12\""
      }
      2m_J -
      2m_H -
      2m_Ks {
         if {[string equal -nocase $key "2m_J"]} { 
            set description "J magnitude (1.2um) from 2MASS" 
            set ucd "phot.mag;em.IR.J"
         }
         if {[string equal -nocase $key "2m_H"]} { 
            set description "H magnitude (1.6um) from 2MASS" 
            set ucd "phot.mag;em.IR.H"
         }
         if {[string equal -nocase $key "2m_Ks"]} { 
            set description "K magnitude (2.2um) from 2MASS" 
            set ucd "phot.mag;em.IR.K"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      2m_ph -
      2m_cc {
         if {[string equal -nocase $key "2m_ph"]} { 
            set description "2MASS photometric quality flag (Note 9)"
            set ucd "meta.code.qual"
         } else { 
            set description "2MASS confusion flag (Note 10)"
            set ucd "meta.code"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"4\""
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set field ""
         set description ""
      }
   }
   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}


## @brief Construction des elements FIELDS en fonction de la cle de la colonne pour le cataloguye UCAC3
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey_UCAC3 { key } {

   # Id et Nom du champ
   set field [list "$::votable::Field::ID ${key}.UCAC3" "$::votable::Field::NAME $key"]
   # Autres infos 
   switch $key {
      ID {
         set description "UCAC3 identifier"
         lappend field "$::votable::Field::UCD \"meta.id;meta.number\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"12\""
      }
      ra_deg -
      dec_deg {
         if {[string equal -nocase $key "ra"]} {
            set description "Right ascension at epoch J2000.0 (ICRS)"
         } else {
            set description "Declination at epoch J2000.0 (ICRS)"
         }
         lappend field "$::votable::Field::UCD \"pos.eq.$key;meta.main\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"9\"" \
                       "$::votable::Field::PRECISION \"5\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      im1_mag -
      im2_mag {
      set description "UCAC fit model magnitude"
      if {[string equal -nocase $key "im1_mag"]} {
         set description "UCAC fit model magnitude"
      } else {
         set description "UCAC aperture magnitude"
      }
      lappend field "$::votable::Field::UCD \"phot.mag;em.opt\"" \
                    "$::votable::Field::DATATYPE \"float\"" \
                    "$::votable::Field::WIDTH \"6\"" \
                    "$::votable::Field::PRECISION \"2\"" \
                    "$::votable::Field::UNIT \"mag\""
      }
      sigmag_mag {
         set description "UCAC error on magnitude (larger of sc.mod)"
         lappend field "$::votable::Field::UCD \"stat.error;phot.mag\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      objt -
      dsf {
         if {[string equal -nocase $key "objt"]} {
            set description "UCAC object classification flag"
         } else {
            set description "Double star flag"
         }
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"2\"" 
      }
      sigra_deg -
      sigdc_deg {
         if {[string equal -nocase $key "sigra_deg"]} {
            set description "Minimal mean error on RAdeg (at EpRA)"
            set ucd "stat.error;pos.eq.ra"
         } else {
            set description "Minimal mean error on DEdeg (at EpDE)"
            set ucd "stat.error;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      na1 -
      nu1 -
      us1 -
      cn1 {
         if {[string equal -nocase $key "na1"]} { set description "UCAC object classification flag" }
         if {[string equal -nocase $key "nu1"]} { set description "Number of used UCAC observations" }
         if {[string equal -nocase $key "us1"]} { set description "Number of catalog positions used for pm's" }
         if {[string equal -nocase $key "cn1"]} { set description "Number of catalog positions" }
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"2\""
      }
      cepra_deg -
      cepdc_deg {
         if {[string equal -nocase $key "cepra_deg"]} {
            set description "Central epoch for mean RA "
         } else {
            set description "Central epoch for mean Declination"
         }
         lappend field "$::votable::Field::UCD \"time.epoch\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"yr\""
      }
      pmrac_masperyear -
      pmdc_masperyear {
         if {[string equal -nocase $key "pmrac_masperyear"]} {
            set description "Proper motion in RA(*cos(Dec))"
            set ucd "pos.pm;pos.eq.ra"
         } else {
            set description "Proper motion in DEC"
            set ucd "pos.pm;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas/yr\""
      }
      sigpmr_masperyear -
      sigpmd_masperyear {
         if {[string equal -nocase $key "sigpmr_masperyear"]} {
            set description "Mean error on pmRA"
            set ucd "stat.error;pos.pm;pos.eq.ra"
         } else {
            set description "Mean error on pmDE"
            set ucd "stat.error;pos.pm;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas/yr\""
      }
      id2m {
         set description "2MASS (Cat. II/246) Unique source identifier"
         lappend field "$::votable::Field::UCD \"meta.id.cross\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"4\""
      }
      jmag_mag -
      hmag_mag -
      kmag_mag {
         if {[string equal -nocase $key "jmag_mag"]} { 
            set description "J magnitude (1.2um) from 2MASS" 
            set ucd "phot.mag;em.IR.J"
         }
         if {[string equal -nocase $key "hmag_mag"]} { 
            set description "H magnitude (1.6um) from 2MASS" 
            set ucd "phot.mag;em.IR.H"
         }
         if {[string equal -nocase $key "kmag_mag"]} { 
            set description "K magnitude (2.2um) from 2MASS" 
            set ucd "phot.mag;em.IR.K"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      jicqflg -
      hicqflg -
      kicqflg {
         if {[string equal -nocase $key "jicqflg"]} { set description "2MASS cc_flg*10 + phot.qual.flag for J magnitude (note 7)" }
         if {[string equal -nocase $key "hicqflg"]} { set description "2MASS cc_flg*10 + phot.qual.flag for H magnitude (note 7)" }
         if {[string equal -nocase $key "kicqflg"]} { set description "2MASS cc_flg*10 + phot.qual.flag for K magnitude (note 7)" }
         lappend field "$::votable::Field::UCD \"meta.code.qual\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"2\""
      }
      je2mpho -
      he2mpho -
      ke2mpho {
         if {[string equal -nocase $key "je2mpho"]} { set description "2MASS error photom. (1/100 mag) for J magnitude (note 8)" }
         if {[string equal -nocase $key "he2mpho"]} { set description "2MASS error photom. (1/100 mag) for H magnitude (note 8)" }
         if {[string equal -nocase $key "ke2mpho"]} { set description "2MASS error photom. (1/100 mag) for K magnitude (note 8)" }
         lappend field "$::votable::Field::UCD \"meta.code.qual\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"2\""
      }
      smB_mag -
      smR2_mag -
      smI_mag {
         if {[string equal -nocase $key "smB_mag"]} { 
            set description "SuperCosmos Bmag" 
            set ucd "phot.mag;em.opt.B"
         }
         if {[string equal -nocase $key "smR2_mag"]} { 
            set description "SuperCosmos R2mag" 
            set ucd "phot.mag;em.opt.R"
         }
         if {[string equal -nocase $key "smI_mag"]} { 
            set description "SuperCosmos Kmag" 
            set ucd "phot.mag;em.opt.I"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      clbl {
         set description "SuperCosmos star/galaxy classif./quality flag"
         lappend field "$::votable::Field::UCD \"src.class.starGalaxy\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"2\""
      }
      qfB -
      qfR2 -
      qfI {
         if {[string equal -nocase $key "qfB"]}  { set description "B-band quality-confusion flag" }
         if {[string equal -nocase $key "qfR2"]} { set description "R-band quality-confusion flag" }
         if {[string equal -nocase $key "qfI"]}  { set description "I-band quality-confusion flag" }
         lappend field "$::votable::Field::UCD \"meta.code.qual\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"3\"" 
      }
      catflg1 -
      catflg2 -
      catflg3 -
      catflg4 -
      catflg5 -
      catflg6 -
      catflg7 -
      catflg8 -
      catflg9 -
      catflg10 {
         set i [string replace $key 0 5 ""]
         set description "Matching flags for catalogue $i"
         lappend field "$::votable::Field::UCD \"meta.code.qual\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"3\"" 
      }
      g1 -
      c1 {
         if {[string equal -nocase $key "g1"]}  { set description "Yale SPM object type (g-flag)" }
         if {[string equal -nocase $key "c1"]}  { set description "Yale SPM input cat. (c-flag) " }
         lappend field "$::votable::Field::UCD \"meta.code.qual\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"3\"" 
      }
      leda -
      x2m {
         if {[string equal -nocase $key "leda"]}  { set description "LEDA galaxy match flag" }
         if {[string equal -nocase $key "x2m"]}  { set description "2MASS extend.source flag" }
         lappend field "$::votable::Field::UCD \"meta.code.qual\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"3\"" 
      }
      rn {
         set description "mean position (MPOS) number"
         lappend field "$::votable::Field::UCD \"meta.id\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"9\"" 
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set field ""
         set description ""
      }
   }
   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}


## @brief Construction des elements FIELDS en fonction de la cle de la colonne pour le cataloguye UCAC4
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey_UCAC4 { key } {

   # Id et Nom du champ
   set field [list "$::votable::Field::ID ${key}.UCAC4" "$::votable::Field::NAME $key"]
   # Autres infos 
   switch $key {
      ID {
         set description "UCAC4 identifier"
         lappend field "$::votable::Field::UCD \"meta.id;meta.number\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"12\""
      }
      ra_deg -
      dec_deg {
         if {[string equal -nocase $key "ra"]} {
            set description "Right ascension at epoch J2000.0 (ICRS)"
         } else {
            set description "Declination at epoch J2000.0 (ICRS)"
         }
         lappend field "$::votable::Field::UCD \"pos.eq.$key;meta.main\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"9\"" \
                       "$::votable::Field::PRECISION \"5\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      im1_mag -
      im2_mag {
      set description "UCAC fit model magnitude"
      if {[string equal -nocase $key "im1_mag"]} {
         set description "UCAC fit model magnitude"
      } else {
         set description "UCAC aperture magnitude"
      }
      lappend field "$::votable::Field::UCD \"phot.mag;em.opt\"" \
                    "$::votable::Field::DATATYPE \"float\"" \
                    "$::votable::Field::WIDTH \"6\"" \
                    "$::votable::Field::PRECISION \"2\"" \
                    "$::votable::Field::UNIT \"mag\""
      }
      sigmag_mag {
         set description "UCAC error on magnitude (larger of sc.mod)"
         lappend field "$::votable::Field::UCD \"stat.error;phot.mag\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      objt -
      dsf {
         if {[string equal -nocase $key "objt"]} {
            set description "UCAC object classification flag"
         } else {
            set description "Double star flag"
         }
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"2\"" 
      }
      sigra_deg -
      sigdc_deg {
         if {[string equal -nocase $key "sigra_deg"]} {
            set description "Minimal mean error on RAdeg (at EpRA)"
            set ucd "stat.error;pos.eq.ra"
         } else {
            set description "Minimal mean error on DEdeg (at EpDE)"
            set ucd "stat.error;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      na1 -
      nu1 -
      us1 {
         if {[string equal -nocase $key "na1"]} { set description "UCAC object classification flag" }
         if {[string equal -nocase $key "nu1"]} { set description "Number of used UCAC observations" }
         if {[string equal -nocase $key "us1"]} { set description "Number of catalog positions used for pm's" }
         if {[string equal -nocase $key "cn1"]} { set description "Number of catalog positions" }
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"2\""
      }
      cepra_deg -
      cepdc_deg {
         if {[string equal -nocase $key "cepra_deg"]} {
            set description "Central epoch for mean RA "
         } else {
            set description "Central epoch for mean Declination"
         }
         lappend field "$::votable::Field::UCD \"time.epoch\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"yr\""
      }
      pmrac_masperyear -
      pmdc_masperyear {
         if {[string equal -nocase $key "pmrac_masperyear"]} {
            set description "Proper motion in RA(*cos(Dec))"
            set ucd "pos.pm;pos.eq.ra"
         } else {
            set description "Proper motion in DEC"
            set ucd "pos.pm;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas/yr\""
      }
      sigpmr_masperyear -
      sigpmd_masperyear {
         if {[string equal -nocase $key "sigpmr_masperyear"]} {
            set description "Mean error on pmRA"
            set ucd "stat.error;pos.pm;pos.eq.ra"
         } else {
            set description "Mean error on pmDE"
            set ucd "stat.error;pos.pm;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas/yr\""
      }
      id2m {
         set description "2MASS (Cat. II/246) Unique source identifier"
         lappend field "$::votable::Field::UCD \"meta.id.cross\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"4\""
      }
      jmag_mag -
      hmag_mag -
      kmag_mag {
         if {[string equal -nocase $key "jmag_mag"]} { 
            set description "J magnitude (1.2um) from 2MASS" 
            set ucd "phot.mag;em.IR.J"
         }
         if {[string equal -nocase $key "hmag_mag"]} { 
            set description "H magnitude (1.6um) from 2MASS" 
            set ucd "phot.mag;em.IR.H"
         }
         if {[string equal -nocase $key "kmag_mag"]} { 
            set description "K magnitude (2.2um) from 2MASS" 
            set ucd "phot.mag;em.IR.K"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      jicqflg -
      hicqflg -
      kicqflg {
         if {[string equal -nocase $key "jicqflg"]} { set description "2MASS cc_flg*10 + phot.qual.flag for J magnitude (note 7)" }
         if {[string equal -nocase $key "hicqflg"]} { set description "2MASS cc_flg*10 + phot.qual.flag for H magnitude (note 7)" }
         if {[string equal -nocase $key "kicqflg"]} { set description "2MASS cc_flg*10 + phot.qual.flag for K magnitude (note 7)" }
         lappend field "$::votable::Field::UCD \"meta.code.qual\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"2\""
      }
      je2mpho -
      he2mpho -
      ke2mpho {
         if {[string equal -nocase $key "je2mpho"]} { set description "2MASS error photom. (1/100 mag) for J magnitude (note 8)" }
         if {[string equal -nocase $key "he2mpho"]} { set description "2MASS error photom. (1/100 mag) for H magnitude (note 8)" }
         if {[string equal -nocase $key "ke2mpho"]} { set description "2MASS error photom. (1/100 mag) for K magnitude (note 8)" }
         lappend field "$::votable::Field::UCD \"meta.code.qual\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"2\""
      }
      apassB_mag -
      apassV_mag -
      apassG_mag -
      apassR_mag -
      apassI_mag {
         switch $key {
            "apassB_mag" {
               set description "B magnitude from APASS" 
               set ucd "phot.mag;em.opt.B"
            }
            "apassV_mag" {
               set description "V magnitude from APASS" 
               set ucd "phot.mag;em.opt.V"
            }
            "apassG_mag" {
               set description "G magnitude from APASS" 
               set ucd "phot.mag;em.opt.G"
            }
            "apassR_mag" {
               set description "R magnitude from APASS" 
               set ucd "phot.mag;em.opt.R"
            }
            "apassI_mag" {
               set description "I magnitude from APASS" 
               set ucd "phot.mag;em.opt.I"
            }
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      apassB_errmag -
      apassV_errmag -
      apassG_errmag -
      apassR_errmag -
      apassI_errmag {
         switch $key {
            "apassB_errmag" {
               set description "Estimated error on B magnitude from APASS" 
               set ucd "stat.error;phot.mag;em.opt.B"
            }
            "apassV_errmag" {
               set description "Estimated error on V magnitude from APASS" 
               set ucd "stat.error;phot.mag;em.opt.V"
            }
            "apassG_errmag" {
               set description "Estimated error on G magnitude from APASS" 
               set ucd "stat.error;phot.mag;em.opt.G"
            }
            "apassR_errmag" {
               set description "Estimated error on R magnitude from APASS" 
               set ucd "stat.error;phot.mag;em.opt.R"
            }
            "apassI_errmag" {
               set description "Estimated error on I magnitude from APASS" 
               set ucd "stat.error;phot.mag;em.opt.I"
            }
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      catflg1 -
      catflg2 -
      catflg3 -
      catflg4 {
         set i [string replace $key 0 5 ""]
         set description "Matching flags for catalogue $i"
         lappend field "$::votable::Field::UCD \"meta.code.qual\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"3\"" 
      }
      starId -
      zoneUcac2 -
      idUcac2 {
         switch $key {
            "starId"    { set description "Unique star ID number" }
            "zoneUcac2" { set description "UCAC2 zone number (ZZZ)" }
            "idUcac2"   { set description "UCAC2 number (NNNNNN)" }
         }
         lappend field "$::votable::Field::UCD \"meta.id;meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"10\""
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set field ""
         set description ""
      }
   }
   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}



## @brief Construction des elements FIELDS en fonction de la cle de la colonne pour le catalogue PPMX
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey_PPMX { key } {
   # Id et Nom du champ
   set field [list "$::votable::Field::ID ${key}.PPMX" "$::votable::Field::NAME $key"]
   # Autres infos 
   switch $key {
      ID {
         set description "PPMX identifier (IAU convention HHMMSS.S+DDMMSS)"
         lappend field "$::votable::Field::UCD \"meta.id;meta.number\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"16\""
      }
      RAJ2000 -
      DECJ2000 {
         if {[string equal -nocase $key "RAJ2000"]} {
            set description "Right ascension at epoch J2000.0"
         } else {
            set description "Declination at epoch J2000.0"
         }
         lappend field "$::votable::Field::UCD \"pos.eq.$key;meta.main\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"9\"" \
                       "$::votable::Field::PRECISION \"5\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      errRa -
      errDec {
         if {[string equal -nocase $key "errRa"]} {
            set description "Mean error in RAJ2000*cos(DECJ2000) at epRA"
            set ucd "stat.error;pos.eq.ra"
         } else {
            set description "Mean error in DE at epDE"
            set ucd "stat.error;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"10\"" \
                       "$::votable::Field::PRECISION \"6\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      pmRA -
      pmDE {
         if {[string equal -nocase $key "pmRA"]} {
            set description "Proper Motion in RAJ2000*cos(DECJ2000)"
            set ucd "pos.pm;pos.eq.ra"
         } else {
            set description "Proper motion in DEC"
            set ucd "pos.pm;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas/yr\""
      }
      errPmRa -
      errPmDec {
         if {[string equal -nocase $key "errPmRa"]} {
            set description "Mean error in RA proper motion (pmRA*cos(DECJ2000))"
            set ucd "stat.error;pos.pm;pos.eq.ra"
         } else {
            set description "Mean error in DEC proper motion"
            set ucd "stat.error;pos.pm;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas/yr\""
      }
      Cmag -
      Rmag -
      Bmag -
      Vmag -
      Jmag -
      Hmag -
      Kmag {
         switch $key {
            "Cmag" { 
               set description "Catalogue magnitude from source" 
               set ucd "phot.mag"
            }
            "Rmag" { 
               set description "Calculated Ru magnitude (579-642nm) from source" 
               set ucd "phot.mag"
            }
            "Bmag" { 
               set description "B magnitude in Johnson system" 
               set ucd "phot.mag;em.opt.B"
            }
            "Vmag" { 
               set description "V magnitude in Johnson system" 
               set ucd "phot.mag;em.opt.V"
            }
            "Jmag" { 
               set description "J magnitude from 2MASS" 
               set ucd "phot.mag;em.IR.J"
            }
            "Hmag" { 
               set description "H magnitude from 2MASS" 
               set ucd "phot.mag;em.IR.H"
            }
            "Kmag" { 
               set description "Ks magnitude from 2MASS" 
               set ucd "phot.mag;em.IR.K"
            }
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      ErrBmag -
      ErrVmag -
      ErrJmag -
      ErrHmag -
      ErrKmag {
         switch $key {
            "ErrBmag" { 
               set description "Standard error on B magnitude"
               set ucd "phot.mag;em.opt.B"
            }
            "ErrVmag" { 
               set description "Standard error on V magnitude"
               set ucd "phot.mag;em.opt.V"
            }
            "ErrJmag" { 
               set description "Standard error on J magnitude"
               set ucd "phot.mag;em.IR.J"
            }
            "ErrHmag" { 
               set description "Standard error on H magnitude" 
               set ucd "phot.mag;em.IR.H"
            }
            "ErrKmag" { 
               set description "Standard error on Ks magnitude" 
               set ucd "phot.mag;em.IR.K"
            }
         }
         lappend field "$::votable::Field::UCD \"stat.error;$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      Nobs {
         set description "Number of observation in LSQ fit"
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"2\""
      }
      P {
         set description "P if LSQ fit is bad"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"1\""
      }
      sub {
         set description "Subset flag"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"1\""
      }
      refCatalog {
         set description "Source catalogue flag"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"1\""
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set field ""
         set description ""
      }
   }
   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}



## @brief Construction des elements FIELDS en fonction de la cle de la colonne pour le catalogue PPMXL
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey_PPMXL { key } {
   # Id et Nom du champ
   set field [list "$::votable::Field::ID ${key}.PPMXL" "$::votable::Field::NAME $key"]
   # Autres infos 
   switch $key {
      ID {
         set description "PPMXL identifier (IAU convention HHMMSS.S+DDMMSS)"
         lappend field "$::votable::Field::UCD \"meta.id;meta.number\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"16\""
      }
      RAJ2000 -
      DECJ2000 {
         if {[string equal -nocase $key "RAJ2000"]} {
            set description "Right ascension at epoch J2000.0"
         } else {
            set description "Declination at epoch J2000.0"
         }
         lappend field "$::votable::Field::UCD \"pos.eq.$key;meta.main\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"9\"" \
                       "$::votable::Field::PRECISION \"5\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      errRa -
      errDec {
         if {[string equal -nocase $key "errRa"]} {
            set description "Mean error in RAJ2000*cos(DECJ2000) at epRA"
            set ucd "stat.error;pos.eq.ra"
         } else {
            set description "Mean error in DE at epDE"
            set ucd "stat.error;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"10\"" \
                       "$::votable::Field::PRECISION \"6\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      pmRA -
      pmDE {
         if {[string equal -nocase $key "pmRA"]} {
            set description "Proper Motion in RAJ2000*cos(DECJ2000)"
            set ucd "pos.pm;pos.eq.ra"
         } else {
            set description "Proper motion in DEC"
            set ucd "pos.pm;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas/yr\""
      }
      errPmRa -
      errPmDec {
         if {[string equal -nocase $key "errPmRa"]} {
            set description "Mean error in RA proper motion (pmRA*cos(DECJ2000))"
            set ucd "stat.error;pos.pm;pos.eq.ra"
         } else {
            set description "Mean error in DEC proper motion"
            set ucd "stat.error;pos.pm;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas/yr\""
      }
      epochRa -
      epochDec {
         if {[string equal -nocase $key "epochRa"]} {
            set description "Mean epoch of RAJ2000"
         } else {
            set description "Mean epoch of DECJ2000"
         }
         lappend field "$::votable::Field::UCD \"time.epoch\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"7\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"yr\""
      }
      magB1 -
      magB2 -
      magR1 -
      magR2 -
      magI -
      magJ -
      magH -
      magK {
         switch $key {
            "magB1" { 
               set description "B mag from USNO-B, first epoch" 
               set ucd "phot.mag;em.opt.B"
            }
            "magB2" { 
               set description "B mag from USNO-B, second epoch" 
               set ucd "phot.mag;em.opt.B"
            }
            "magR1" { 
               set description "R mag from USNO-B, first epoch" 
               set ucd "phot.mag;em.opt.R"
            }
            "magR2" { 
               set description "R mag from USNO-B, second epoch" 
               set ucd "phot.mag;em.opt.R"
            }
            "magI" { 
               set description "I mag from USNO-B" 
               set ucd "phot.mag;em.IR.I"
            }
            "magJ" { 
               set description "J magnitude from 2MASS" 
               set ucd "phot.mag;em.IR.J"
            }
            "magH" { 
               set description "H magnitude from 2MASS" 
               set ucd "phot.mag;em.IR.H"
            }
            "magK" { 
               set description "Ks magnitude from 2MASS" 
               set ucd "phot.mag;em.IR.K"
            }
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      errMagJ -
      errMagH -
      errMagK {
         switch $key {
            "errMagJ" { 
               set description "J total magnitude uncertainty"
               set ucd "phot.mag;em.IR.J"
            }
            "errMagH" { 
               set description "H total magnitude uncertainty"
               set ucd "phot.mag;em.IR.H"
            }
            "errMagK" { 
               set description "Ks total magnitude uncertainty"
               set ucd "phot.mag;em.IR.K"
            }
         }
         lappend field "$::votable::Field::UCD \"stat.error;$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      Nobs {
         set description "Number of observation used"
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"2\""
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set field ""
         set description ""
      }
   }
   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}



## @brief Construction des elements FIELDS en fonction de la cle de la colonne pour le catalogue 2MASS
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey_2MASS { key } {
   # Id et Nom du champ
   set field [list "$::votable::Field::ID ${key}.2MASS" "$::votable::Field::NAME $key"]
   # Autres infos 
   switch $key {
      ID {
         set description "2MASS identifier"
         lappend field "$::votable::Field::UCD \"meta.id;meta.number\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"16\""
      }
      ra_deg -
      dec_deg {
         if {[string equal -nocase $key "ra_deg"]} {
            set description "Right ascension at epoch J2000.0 (ICRS)"
         } else {
            set description "Declination at epoch J2000.0 (ICRS)"
         }
         lappend field "$::votable::Field::UCD \"pos.eq.$key;meta.main\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"9\"" \
                       "$::votable::Field::PRECISION \"5\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      err_ra -
      err_dec {
         if {[string equal -nocase $key "err_ra"]} {
            set description "Uncertainty on RA position"
            set ucd "stat.error;pos.eq.ra"
         } else {
            set description "Uncertainty on DEC position"
            set ucd "stat.error;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"10\"" \
                       "$::votable::Field::PRECISION \"6\"" \
                       "$::votable::Field::UNIT \"arcsec\""
      }
      jMag -
      hMag -
      kMag {
         if {[string equal -nocase $key "jMag"]} { 
            set description "2MASS J magnitude (1.2um)" 
            set ucd "phot.mag;em.IR.J"
         }
         if {[string equal -nocase $key "hMag"]} { 
            set description "2MASS H magnitude (1.6um)" 
            set ucd "phot.mag;em.IR.H"
         }
         if {[string equal -nocase $key "kMag"]} { 
            set description "2MASS K magnitude (2.2um)" 
            set ucd "phot.mag;em.IR.K"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      jMagError -
      hMagError -
      kMagError {
         if {[string equal -nocase $key "jMagError"]} { 
            set description "1-sigma total error on Jmag"
            set ucd "stat.error;phot.mag;em.IR.J"
         }
         if {[string equal -nocase $key "hMagError"]} { 
            set description "1-sigma total error on Hmag"
            set ucd "stat.error;phot.mag;em.IR.H"
         }
         if {[string equal -nocase $key "kMagError"]} { 
            set description "1-sigma total error on Kmag"
            set ucd "stat.error;phot.mag;em.IR.K"
         }
         lappend field "$::votable::Field::UCD \"stat.error;phot.mag\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      jd {
         set description "Julian Date of observation"
         lappend field "$::votable::Field::UCD \"time.epoch\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"12\"" \
                       "$::votable::Field::PRECISION \"4\"" \
                       "$::votable::Field::UNIT \"d\""
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set field ""
         set description ""
      }
   }
   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}



## @brief Construction des elements FIELDS en fonction de la cle de la colonne pour le catalogue WFIBC
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey_WFIBC { key } {
   # Id et Nom du champ
   set field [list "$::votable::Field::ID ${key}.WFIBC" "$::votable::Field::NAME $key"]
   # Autres infos 
   switch $key {
      ID {
         set description "WFIBC identifier (IAU convention HHMMSS.S+DDMMSS)"
         lappend field "$::votable::Field::UCD \"meta.id;meta.number\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"16\""
      }
      RA_deg -
      DEC_deg {
         if {[string equal -nocase $key "RA_deg"]} {
            set description "ICRF Right ascension"
         } else {
            set description "ICRF Declination"
         }
         lappend field "$::votable::Field::UCD \"pos.eq.$key;meta.main\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"9\"" \
                       "$::votable::Field::PRECISION \"5\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      error_AlphaCosDelta -
      error_Delta {
         if {[string equal -nocase $key "error_AlphaCosDelta"]} {
            set description "Mean error in RA*cos(DEC) at JD"
            set ucd "stat.error;pos.eq.ra"
         } else {
            set description "Mean error in DEC at JD"
            set ucd "stat.error;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"10\"" \
                       "$::votable::Field::PRECISION \"6\"" \
                       "$::votable::Field::UNIT \"arcsec\""
      }
      JD {
         set description "Julian Date of observation"
         lappend field "$::votable::Field::UCD \"time.epoch\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"12\"" \
                       "$::votable::Field::PRECISION \"4\"" \
                       "$::votable::Field::UNIT \"d\""
      }
      PM_AlphaCosDelta -
      PM_Delta {
         if {[string equal -nocase $key "PM_AlphaCosDelta"]} {
            set description "Proper Motion in RA*cos(DEC) (99.999 when not determined)"
            set ucd "pos.pm;pos.eq.ra"
         } else {
            set description "Proper motion in DEC (99.999 when not determined)"
            set ucd "pos.pm;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"arcsec/yr\""
      }
      error_PM_AlphaCosDelta -
      error_PM_Delta {
         if {[string equal -nocase $key "error_PM_AlphaCosDelta"]} {
            set description "Mean error in RA proper motion (pmRA*cos(DEC)) (99.999 when not determined)"
            set ucd "stat.error;pos.pm;pos.eq.ra"
         } else {
            set description "Mean error in DEC proper motion (99.999 when not determined)"
            set ucd "stat.error;pos.pm;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"arcsec/yr\""
      }
      magR {
         set description "Observed R magnitude" 
         set ucd "phot.mag;em.opt.R"
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      error_magR {
         set description "Observed R magnitude uncertainty"
         set ucd "phot.mag;em.IR.R"
         lappend field "$::votable::Field::UCD \"stat.error;$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set field ""
         set description ""
      }
   }
   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}



## @brief Construction des elements FIELDS en fonction de la cle de la colonne pour le catalogue SDSS
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey_SDSS { key } {
   # Id et Nom du champ
   set field [list "$::votable::Field::ID ${key}.SDSS" "$::votable::Field::NAME $key"]

   # Autres infos 
   switch $key {
      objid {
         set description "SDSS identifier"
         lappend field "$::votable::Field::UCD \"meta.id;meta.number\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"20\""
      }
      run {
         set description "Run number"
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"2\""
      }
      rerun {
         set description "Rerun number"
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"2\""
      }
      camcol {
         set description "Imaging camcol"
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"1\""
      }
      field {
         set description "Imaging field"
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"4\""
      }
      obj {
         set description "Imaging object Id"
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"4\""
      }
      type {
         set description "Type classification of the object: 0: Unknown: Object type is not known ; 1: Cosmic-ray track (not used) ; 2: Defect: Object is caused by a defect in the telescope or processing pipeline (not used) ; 3: Galaxy: An extended object composed of many stars and other matter ; 4: Ghost: Object created by reflected or refracted light (not used) ; 5: KnownObject: Object came from some other catalog (not the SDSS catalog, not yet used) ; 6: Star: A a self-luminous gaseous celestial body ; 7: Trail: A satellite or asteriod or meteor trail (not yet used) ; 8: Sky: Blank sky spectogram (no objects in this arcsecond area) ; 9: NotAType"
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"2\""
      }
      ra -
      dec {
         if {[string equal -nocase $key "ra"]} {
            set description "Right ascension at epoch J2000.0"
         } else {
            set description "Declination at epoch J2000.0"
         }
         lappend field "$::votable::Field::UCD \"pos.eq.$key;meta.main\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"9\"" \
                       "$::votable::Field::PRECISION \"5\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      u -
      g -
      r -
      i -
      z {
         switch $key {
            "u" { 
               set description "SDSS U-band magnitude" 
               set ucd "phot.mag;em.opt.U"
            }
            "g" { 
               set description "SDSS G-band magnitude" 
               set ucd "phot.mag;em.opt.B"
            }
            "r" { 
               set description "SDSS R-band magnitude" 
               set ucd "phot.mag;em.opt.R"
            }
            "i" { 
               set description "SDSS I-band magnitude" 
               set ucd "phot.mag;em.opt.I"
            }
            "z" { 
               set description "SDSS Z-band magnitude" 
               set ucd "phot.mag;em.opt.I"
            }
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      Err_u -
      Err_g -
      Err_r -
      Err_i -
      Err_z {
         switch $key {
            "Err_u" { 
               set description "Standard error on SDSS U-band magnitude"
               set ucd "phot.mag;em.opt.U"
            }
            "Err_g" { 
               set description "Standard error on SDSS G-band magnitude"
               set ucd "phot.mag;em.opt.B"
            }
            "Err_r" { 
               set description "Standard error on SDSS R-band magnitude"
               set ucd "phot.mag;em.opt.R"
            }
            "Err_i" { 
               set description "Standard error on SDSS I-band magnitude" 
               set ucd "phot.mag;em.opt.I"
            }
            "Err_z" { 
               set description "Standard error on SDSS Z-band magnitude" 
               set ucd "phot.mag;em.opt.I"
            }
         }
         lappend field "$::votable::Field::UCD \"stat.error;$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set field ""
         set description ""
      }
   }
   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}


## @brief Construction des elements FIELDS en fonction de la cle de la colonne pour le catalogue PANSTARRS
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey_PANSTARRS { key } {
   # Id et Nom du champ
   set field [list "$::votable::Field::ID ${key}.PANSTARRS" "$::votable::Field::NAME $key"]

   # Autres infos
   switch $key {
      objname {
         set description "IAU name for this object"
         lappend field "$::votable::Field::UCD \"meta.id\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"*\""
      }
      objid {
         set description "PANSTARRS identifier"
         lappend field "$::votable::Field::UCD \"meta.id;meta.number\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"*\""
      }
      ramean -
      decmean {
         if {[string equal -nocase $key "ramean"]} {
            set k "ra"
            set description "Right ascension from single epoch detections (weighted mean)"
         } else {
            set k "dec"
            set description "Declination from single epoch detections (weighted mean)"
         }
         lappend field "$::votable::Field::UCD \"pos.eq.$k;meta.main\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      rameanerr -
      decmeanerr {
         if {[string equal -nocase $key "rameanerr"]} {
            set k "ra"
            set description "Right ascension standard deviation from single epoch detections"
         } else {
            set k "dec"
            set description "Declination standard deviation from single epoch detections"
         }
         lappend field "$::votable::Field::UCD \"stat.error;pos.eq.$k\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"arcsec\""
      }
      ndetections {
         set description "Number of single epoch detections in all filters"
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" 
      }
      randomid {
         set description "Random value drawn from the interval between zero and one"
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"double\"" 
      }
      projectionid {
         set description "Projection cell identifier"
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" 
      }
      skycellid {
         set description "Skycell region identifier"
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" 
      }
      objinfoflag {
         set description "Information flag bitmask indicating details of the photometry (see ObjectInfoFlags)"
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" 
      }
      qualityflag {
         set description "Subset of objInfoFlag denoting whether this object is real or a likely false positive (see ObjectQualityFlags)"
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" 
      }
      rastack -
      decstack {
         if {[string equal -nocase $key "rastack"]} {
            set k "ra"
            set description "Right ascension from stack detections (J2000)"
         } else {
            set k "dec"
            set description "Declination from stack detections (J2000)"
         }
         lappend field "$::votable::Field::UCD \"pos.eq.$k\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"*\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      rastackerr -
      decstackerr {
         if {[string equal -nocase $key "rastackerr"]} {
            set k "ra"
            set description "Right ascension standard deviation from stack detections"
         } else {
            set k "dec"
            set description "Declination standard deviation from stack detections"
         }
         lappend field "$::votable::Field::UCD \"stat.error;pos.eq.$k\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"*\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      epochmean {
         set description "Modified Julian Date of the mean epoch for raMean"
         lappend field "$::votable::Field::UCD \"time.epoch\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"d\""
      }
      nstackdetections {
         set description "Number of stack detections"
         lappend field "$::votable::Field::UCD \"meta.number\"" \
                       "$::votable::Field::DATATYPE \"int\"" 
      }
      ng -
      nr -
      ni -
      nz -
      ny {
         set description "Number of single epoch detections in [string index $key 1] filter"
         lappend field "$::votable::Field::DATATYPE \"int\"" 
      }
      gqfperfect {
         set description "Maximum PSF weighted fraction of pixels totally unmasked from g filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" 
      }
      gmeanpsfmag {
         set description "Mean PSF magnitude from g filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      gmeanpsfmagerr {
         set description "Error in mean PSF magnitude from g filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      gmeankronmag {
         set description "Mean Kron magnitude from g filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      gmeankronmagerr {
         set description "Error in mean Kron magnitude from g filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      gmeanapmag {
         set description "Mean aperture magnitude from g filter detections"
         lappend field "$::votable::Field::UCD \"phot.mag;em.opt.G\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      gmeanapmagerr {
         set description "Error in mean aperture magnitude from g filter detections"
         lappend field "$::votable::Field::UCD \"stat.error;phot.mag;em.opt.G\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      gflags {
         set description "Information flag bitmask for mean object from g filter detections"
         lappend field "$::votable::Field::DATATYPE \"int\"" 
      }
      rqfperfect {
         set description "Maximum PSF weighted fraction of pixels totally unmasked from r filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" 
      }
      rmeanpsfmag {
         set description "Mean PSF magnitude from r filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      rmeanpsfmagerr {
         set description "Error in mean PSF magnitude from r filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      rmeankronmag {
         set description "Mean Kron magnitude from r filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      rmeankronmagerr {
         set description "Error in mean Kron magnitude from r filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      rmeanapmag {
         set description "Mean aperture magnitude from r filter detections"
         lappend field "$::votable::Field::UCD \"phot.mag;em.opt.R\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      rmeanapmagerr {
         set description "Error in mean aperture magnitude from r filter detections"
         lappend field "$::votable::Field::UCD \"stat.error;phot.mag;em.opt.R\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      rflags {
         set description "Information flag bitmask for mean object from r filter detections"
         lappend field "$::votable::Field::DATATYPE \"int\"" 
      }
      iqfperfect {
         set description "Maximum PSF weighted fraction of pixels totally unmasked from i filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" 
      }
      imeanpsfmag {
         set description "Mean PSF magnitude from i filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      imeanpsfmagerr {
         set description "Error in mean PSF magnitude from i filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      imeankronmag {
         set description "Mean Kron magnitude from i filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      imeankronmagerr {
         set description "Error in mean Kron magnitude from i filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      imeanapmag {
         set description "Mean aperture magnitude from i filter detections"
         lappend field "$::votable::Field::UCD \"phot.mag;em.opt.I\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      imeanapmagerr {
         set description "Error in mean aperture magnitude from i filter detections"
         lappend field "$::votable::Field::UCD \"stat.error;phot.mag;em.opt.I\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      iflags {
         set description "Information flag bitmask for mean object from i filter detections"
         lappend field "$::votable::Field::DATATYPE \"int\"" 
      }
      zqfperfect {
         set description "Maximum PSF weighted fraction of pixels totally unmasked from z filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" 
      }
      zmeanpsfmag {
         set description "Mean PSF magnitude from z filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      zmeanpsfmagerr {
         set description "Error in mean PSF magnitude from z filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      zmeankronmag {
         set description "Mean Kron magnitude from z filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      zmeankronmagerr {
         set description "Error in mean Kron magnitude from z filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      zmeanapmag {
         set description "Mean aperture magnitude from z filter detections"
         lappend field "$::votable::Field::UCD \"phot.mag;em.opt.Z\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      zmeanapmagerr {
         set description "Error in mean aperture magnitude from z filter detections"
         lappend field "$::votable::Field::UCD \"stat.error;phot.mag;em.opt.Z\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      zflags {
         set description "Information flag bitmask for mean object from z filter detections"
         lappend field "$::votable::Field::DATATYPE \"int\"" 
      }
      yqfperfect {
         set description "Maximum PSF weighted fraction of pixels totally unmasked from y filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" 
      }
      ymeanpsfmag {
         set description "Mean PSF magnitude from y filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      ymeanpsfmagerr {
         set description "Error in mean PSF magnitude from y filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      ymeankronmag {
         set description "Mean Kron magnitude from y filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      ymeankronmagerr {
         set description "Error in mean Kron magnitude from y filter detections"
         lappend field "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\"" 
      }
      ymeanapmag {
         set description "Mean aperture magnitude from y filter detections"
         lappend field "$::votable::Field::UCD \"phot.mag;em.opt.Y\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      ymeanapmagerr {
         set description "Error in mean aperture magnitude from y filter detections"
         lappend field "$::votable::Field::UCD \"stat.error;phot.mag;em.opt.Y\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      yflags {
         set description "Information flag bitmask for mean object from y filter detections"
         lappend field "$::votable::Field::DATATYPE \"int\"" 
      }
      ang_sep {
         set description "Angular Separation"
         lappend field "$::votable::Field::UCD \" pos.angDistance\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::UNIT \"arcmin\""
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set field ""
         set description ""
      }
   }
   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}


## @brief Construction des elements FIELDS en fonction de la cle de la colonne pour le catalogue GAIA1
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey_GAIA1 { key } {
   # Id et Nom du champ
   set field [list "$::votable::Field::ID ${key}.GAIA1" "$::votable::Field::NAME $key"]

   # Autres infos 
   switch $key {
      hip {
         set description "Hipparcos number"
         lappend field "$::votable::Field::UCD \"meta.id.cross\"" \
                       "$::votable::Field::DATATYPE \"int\""
      }
      tycho2_id {
         set description "Tycho 2 identifier"
         lappend field "$::votable::Field::UCD \"meta.id.cross\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"*\""
      }
      source_id {
         set description "Unique source identifier"
         lappend field "$::votable::Field::UCD \"meta.id;meta.main\"" \
                       "$::votable::Field::DATATYPE \"long\""
      }
      ref_epoch {
         set description "Reference epoch"
         lappend field "$::votable::Field::UCD \"meta.ref;time.epoch\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"yr\""
      }
      ra -
      dec {
         if {[string equal -nocase $key "ra"]} {
            set description "Right ascension"
         } else {
            set description "Declination"
         }
         lappend field "$::votable::Field::UCD \"pos.eq.$key;meta.main\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      ra_error -
      dec_error {
         if {[string equal -nocase $key "ra_error"]} {
            set description "Standard error of right ascension"
            set ucd "stat.error;pos.eq.ra"
         } else {
            set description "Standard error of declination"
            set ucd "stat.error;pos.eq.dec"
         }
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      parallax {
         set description "Parallax"
         lappend field "$::votable::Field::UCD \"pos.parallax\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      parallax_error {
         set description "Standard error of parallax"
         lappend field "$::votable::Field::UCD \"stat.error;pos.parallax\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      pmra {
         set description "Proper motion in right ascension direction"
         lappend field "$::votable::Field::UCD \"pos.pm;pos.eq.ra\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"mas/yr\""
      }
      pmra_error {
         set description "Standard error of proper motion in right ascension direction"
         lappend field "$::votable::Field::UCD \"stat.error;pos.pm;pos.eq.ra\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"mas/yr\""
      }
      pmdec {
         set description "Proper motion in declination direction"
         lappend field "$::votable::Field::UCD \"pos.pm;pos.eq.dec\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"mas/yr\""
      }
      pmdec_error {
         set description "Standard error of proper motion in declination direction"
         lappend field "$::votable::Field::UCD \"stat.error;pos.pm;pos.eq.dec\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"mas/yr\""
      }
      astrometric_primary_flag {
         set description "Primary or secondary"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"short\""
      }
      astrometric_priors_used {
         set description "Type of prior used in the astrometric solution"
         lappend field "$::votable::Field::DATATYPE \"int\""
      }
      phot_g_mean_flux {
         set description "G-band mean flux" 
         lappend field "$::votable::Field::UCD \"phot.flux;stat.mean;em.opt\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"e-/s\""
      }
      phot_g_mean_flux_error {
         set description "Error on G-band mean flux"
         lappend field "$::votable::Field::UCD \"stat.error;phot.flux;stat.mean;em.opt\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"e-/s\""
      }
      phot_g_mean_mag {
         set description "G-band mean magnitude" 
         lappend field "$::votable::Field::UCD \"phot.mag;stat.mean;em.opt\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      phot_variable_flag {
         set description "Photometric variability flag" 
         lappend field "$::votable::Field::UCD \"meta.code;src.var\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"*\""
      }
      l {
         set description "Galactic longitude" 
         lappend field "$::votable::Field::UCD \"pos.galactic.lon\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      b {
         set description "Galactic latitude" 
         lappend field "$::votable::Field::UCD \"pos.galactic.lat\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      ecl_lon {
         set description "Ecliptic longitude" 
         lappend field "$::votable::Field::UCD \"pos.ecliptic.lon\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      ecl_lat {
         set description "Ecliptic latitude" 
         lappend field "$::votable::Field::UCD \"pos.ecliptic.lat\"" \
                       "$::votable::Field::DATATYPE \"double\"" \
                       "$::votable::Field::UNIT \"deg\""
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set field ""
         set description ""
      }
   }
   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}


## @brief Construction des elements FIELDS en fonction de la cle de la colonne pour le catalogue SKYBOT
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey_SKYBOT { key } {
   # Id et Nom du champ
   set field [list "$::votable::Field::ID ${key}.SKYBOT"]
   # Autres infos 
   switch $key {
      num {
         set lkey $key
         set description "Solar system object number"
         set ucd "meta.id;meta.number"
         lappend field "$::votable::Field::NAME $key" \
                       "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"6\"" 
      }
      name {
         set lkey $key
         set description "Solar system object name or designation"
         set ucd "meta.id;meta.main"
         lappend field "$::votable::Field::NAME $key" \
                       "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"32\"" 
      }
      ra -
      de {
         if {[string equal -nocase $key "ra"]} {
            set lkey "ra"
            set description "Astrometric J2000 right ascension"
            set unit "deg"
         } else {
            set lkey "dec"
            set description "Astrometric J2000 declination"
            set unit "deg"
         }
         lappend field "$::votable::Field::NAME $key" \
                       "$::votable::Field::UCD \"pos.eq.$lkey;meta.main\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"9\"" \
                       "$::votable::Field::PRECISION \"5\"" \
                       "$::votable::Field::UNIT \"$unit\""
      }
      class {
         set lkey $key
         set description "Object classification"
         set ucd "meta.code.class;src.class"
         lappend field "$::votable::Field::NAME $key" \
                       "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"10\"" 
      }
      magV {
         set lkey $key
         set description "Visual magnitude"
         lappend field "$::votable::Field::NAME $key" \
                       "$::votable::Field::UCD \"phot.mag;em.opt.V\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"13\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      errpos {
         set lkey $key
         set description "Uncertainty on the (RA,DEC) coordinates"
         set ucd "stat.error.sys"
         lappend field "$::votable::Field::NAME $key" \
                       "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"10\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"arcsec\""
      }
      angdist {
         set lkey $key
         set description "Body-to-center angular distance"
         lappend field "$::votable::Field::NAME $key" \
                       "$::votable::Field::UCD \"pos.ang\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"arcsec\""
      }
      _raj2000 -
      _decj2000 {
         if {[string equal -nocase $key "_raj2000"]} {
            set lkey "ra"
            set nkey "_RAJ2000"
            set description "Astrometric J2000 right ascension"
            set unit "deg"
         } else {
            set lkey "dec"
            set nkey "_DECJ2000"
            set description "Astrometric J2000 declination"
            set unit "deg"
         }
         lappend field "$::votable::Field::NAME $nkey" \
                       "$::votable::Field::UCD \"pos.eq.$lkey\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"9\"" \
                       "$::votable::Field::PRECISION \"5\"" \
                       "$::votable::Field::UNIT \"$unit\"" \
                       "$::votable::Field::TYPE \"hidden\""
      }
      externallink {
         set lkey $key
         set description "External link to hint the target"
         set ucd "meta.ref.url"
         lappend field "$::votable::Field::NAME $key" \
                       "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"*\"" \
                       "$::votable::Field::TYPE \"hidden\""
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set lkey $key
         set field ""
         set description ""
      }
   }

   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}


## @brief Construction des elements FIELDS en fonction de la cle de la colonne pour le catalogue ASTROID
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey_ASTROID { key } {
   # Id et Nom du champ
   set field [list "$::votable::Field::ID ${key}.ASTROID" "$::votable::Field::NAME $key"]
   # Autres infos 
   switch $key {
      xsm -
      ysm {
         set description "Cartesian coordinate of the source in the image (add 1 to be in image coordinates)"
         lappend field "$::votable::Field::UCD \"pos.cartesian.[string index $key 0]\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"pixel\""
      }
      err_xsm -
      err_ysm {
         set description "Uncertainty on the cartesian coordinate of the source in the image"
         lappend field "$::votable::Field::UCD \"stat.error;pos.cartesian.[string index $key 4]\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"5\"" \
                       "$::votable::Field::UNIT \"pixel\""
      }
      fwhmx -
      fwhmy -
      fwhm {
         if {[string equal -nocase $key "fwhmx"]} {
            set description "X component of the FWHM of the source measured"
         } elseif {[string equal -nocase $key "fwhmy"]} {
            set description "Y component of the FWHM of the source measured"
         } else {
            set description "FWHM of the source measured"
         }
         lappend field "$::votable::Field::UCD \"phys.angSize\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"pixel\""
      }
      flux {
         set description "Measured flux of the source"
         lappend field "$::votable::Field::UCD \"phot.count\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"ADU\""
      }
      err_flux {
         set description "Uncertainty on the measured source flux"
         lappend field "$::votable::Field::UCD \"stat.error;phot.count\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"ADU\""
      }
      pixmax {
         set description "Flux of the pixel of maximum intensity"
         lappend field "$::votable::Field::UCD \"phot.count\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"ADU\""
      }
      intensity {
         set description "Flux of the pixel of maximum intensity minus the background intensity"
         lappend field "$::votable::Field::UCD \"phot.count\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"ADU\""
      }
      sky {
         set description "Measured flux of the sky level"
         lappend field "$::votable::Field::UCD \"phot.count\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"ADU\""
      }
      err_sky {
         set description "Standard deviation on the sky level"
         lappend field "$::votable::Field::UCD \"stat.error;phot.count\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"ADU\""
      }
      snint {
         set description "Integrated flux divided by the background sigma"
         lappend field "$::votable::Field::UCD \"stat.value\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"-\""
      }
      radius {
         set description "Radius of the window used to measure the photocenter (pix)"
         lappend field "$::votable::Field::UCD \"stat.value\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"px\""
      }
      rdiff {
         set description "Distance between the requested and the measured photocenter (pix)"
         lappend field "$::votable::Field::UCD \"stat.value\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"px\""
      }
      err_psf {
         set description "Flag about the measure of the PSF"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"16\"" 
      }
      psf_method {
         set description "Name of the method used to measure the PSF of sources"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"32\"" 
      }
      globale {
         set description "Values of the radii interval (as rad1:rad2) used in the global PSF method"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"32\"" 
      }
      ra -
      dec {
         if {[string equal -nocase $key "ra"]} {
            set description "Astrometric J2000 right ascension"
            set unit "deg"
         } else {
            set description "Astrometric J2000 declination"
            set unit "deg"
         }
         lappend field "$::votable::Field::UCD \"pos.eq.$key;meta.main\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"9\"" \
                       "$::votable::Field::PRECISION \"5\"" \
                       "$::votable::Field::UNIT \"$unit\""
      }
      res_ra -
      res_dec {
         if {[string equal -nocase $key "res_ra"]} {
            set description "Uncertainty on the right ascension"
         } else {
            set description "Uncertainty on the declination"
         }
         set ucd "stat.error.sys"
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"10\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"arcsec\""
      }
      omc_ra -
      omc_dec {
         if {[string equal -nocase $key "omc_ra"]} {
            set description "O-C on the right ascension"
         } else {
            set description "O-C on the declination"
         }
         lappend field "$::votable::Field::UCD \"pos.ang\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"arcsec\""
      }
      mag {
         set description "Apparent magnitude measured by Bddimages"
         lappend field "$::votable::Field::UCD \"phot.mag\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"13\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      err_mag {
         set description "Uncertainty of the apparent magnitude measured by Bddimages"
         lappend field "$::votable::Field::UCD \"stat.error;phot.mag\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      name {
         set description "Source name or designation"
         set ucd "meta.id;meta.main"
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"32\"" 
      }
      flagastrom {
         set description "Astrometric flag: R for reference, S for science"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"2\"" 
      }
      flagphotom {
         set description "Photometric flag: R for reference, S for science"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"2\"" 
      }
      cataastrom {
         set description "Astrometric reference catalogue name"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"32\"" 
      }
      cataphotom {
         set description "Photometric reference catalogue name"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"32\"" 
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set field ""
         set description ""
      }
   }
   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}


## @brief Construction des elements FIELDS en fonction de la cle de la colonne pour le catalogue BINAST
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey_BINAST { key } {
   # Id et Nom du champ
   set field [list "$::votable::Field::ID ${key}.BINAST" "$::votable::Field::NAME $key"]
   # Autres infos 
   switch $key {
      system_id {
         set description "Id or num of the asteroidal system"
         set ucd "meta.id;meta.number"
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"6\"" 
      }
      system_name {
         set description "Name or designation of the asteroidal system"
         set ucd "meta.id;meta.main"
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"32\"" 
      }
      target_name {
         set description "Name of the measured component"
         set ucd "meta.id;meta.main"
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"32\"" 
      }
      compo_ref {
         set description "Name of the reference component to which differential coordinates are attached"
         set ucd "meta.id;meta.main"
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"32\"" 
      }
      tjj {
         set description "Julian period of observation"
         lappend field "$::votable::Field::UCD \"time.epoch\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"15\"" \
                       "$::votable::Field::PRECISION \"7\"" \
                       "$::votable::Field::UNIT \"d\""
      }
      tiso {
         set description "ISO date of observation"
         lappend field "$::votable::Field::UCD \"time.epoch\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"24\"" 
      }
      xsm -
      ysm {
         set description "Cartesian coordinate of the source in the image (add 1 to be in image coordinates)"
         lappend field "$::votable::Field::UCD \"pos.cartesian.[string index $key 0]\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"pixel\""
      }
      err_xsm -
      err_ysm {
         set description "Uncertainty on the cartesian coordinate of the source in the image"
         lappend field "$::votable::Field::UCD \"stat.error;pos.cartesian.[string index $key 4]\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"5\"" \
                       "$::votable::Field::UNIT \"pixel\""
      }
      fwhmx -
      fwhmy -
      fwhm {
         if {[string equal -nocase $key "fwhmx"]} {
            set description "X component of the FWHM of the source measured"
         } elseif {[string equal -nocase $key "fwhmy"]} {
            set description "Y component of the FWHM of the source measured"
         } else {
            set description "FWHM of the source measured"
         }
         lappend field "$::votable::Field::UCD \"phys.angSize\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"6\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"pixel\""
      }
      flux {
         set description "Measured flux of the source"
         lappend field "$::votable::Field::UCD \"phot.count\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"ADU\""
      }
      err_flux {
         set description "Uncertainty on the measured source flux"
         lappend field "$::votable::Field::UCD \"stat.error;phot.count\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"ADU\""
      }
      pixmax {
         set description "Flux of the pixel of maximum intensity"
         lappend field "$::votable::Field::UCD \"phot.count\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"ADU\""
      }
      intensity {
         set description "Flux of the pixel of maximum intensity minus the background intensity"
         lappend field "$::votable::Field::UCD \"phot.count\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"ADU\""
      }
      sky {
         set description "Measured flux of the sky level"
         lappend field "$::votable::Field::UCD \"phot.count\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"ADU\""
      }
      err_sky {
         set description "Standard deviation on the sky level"
         lappend field "$::votable::Field::UCD \"stat.error;phot.count\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"ADU\""
      }
      snint {
         set description "Integrated flux divided by the background sigma"
         lappend field "$::votable::Field::UCD \"stat.value\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"-\""
      }
      radius {
         set description "Radius of the window used to measure the photocenter (pix)"
         lappend field "$::votable::Field::UCD \"stat.value\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"1\"" \
                       "$::votable::Field::UNIT \"px\""
      }
      err_psf {
         set description "Flag about the measure of the PSF"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"16\"" 
      }
      dynamic {
         set description "TODO"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"*\"" 
      }
      mag {
         set description "Apparent magnitude determined by Binast toolbox"
         lappend field "$::votable::Field::UCD \"phot.mag\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"13\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      err_mag {
         set description "Uncertainty of the apparent magnitude determined by Binast toolbox"
         lappend field "$::votable::Field::UCD \"stat.error;phot.mag\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      dmag {
         set description "Differential magnitude between the component and the reference"
         lappend field "$::votable::Field::UCD \"phot.mag\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"13\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      err_dmag {
         set description "Uncertainty of the differential magnitude between the component and the reference"
         lappend field "$::votable::Field::UCD \"stat.error;phot.mag\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mag\""
      }
      x_ephem -
      y_ephem {
         set description "Differential coordinate of the component wrt the reference computed by the ephemeris"
         lappend field "$::votable::Field::UCD \"pos.ang\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      ra_ephem -
      dec_ephem {
         if {[string equal -nocase $key "ra_ephem"]} {
            set description "Right ascension of component computed by the ephemeris"
            set unit "deg"
         } else {
            set description "Declination of the component computed by the ephemeris"
            set unit "deg"
         }
         lappend field "$::votable::Field::UCD \"pos.eq.$key;meta.main\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"9\"" \
                       "$::votable::Field::PRECISION \"5\"" \
                       "$::votable::Field::UNIT \"$unit\""
      }
      poserr {
         set description "Uncertainty on the celestial position of the component computed by the ephemeris"
         set ucd "stat.error.sys"
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"10\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"arcsec\""
      }
      dx -
      dy {
         set description "Differential coordinate of the component wrt the reference"
         lappend field "$::votable::Field::UCD \"pos.ang\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      err_dx -
      err_dy {
         set description "Uncertainty on the differential coordinate of the component wrt the reference"
         lappend field "$::votable::Field::UCD \"stat.error;pos.ang\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      rho {
         set description "Quadratic distance between the component and the reference"
         lappend field "$::votable::Field::UCD \"pos.ang\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      err_rho {
         set description "Uncertainty on the quadratic distance between the component and the reference"
         lappend field "$::votable::Field::UCD \"stat.error;pos.ang\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      xomc -
      yomc {
         if {[string equal -nocase $key "xomc"]} {
            set description "O-C on the x coordinate"
         } else {
            set description "O-C on the y coordinate"
         }
         lappend field "$::votable::Field::UCD \"pos.ang\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"3\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      psf_method {
         set description "Name of the method used to measure the PSF of sources"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"*\"" 
      }
      globale {
         set description "Values of the radii interval (as rad1:rad2) used in the global PSF method"
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"*\"" 
      }
      input_radius {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      radius_min {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      radius_max {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      globale_min {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      globale_max {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      globale_confidence {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      saturation {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      threshold {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      globale {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      ecretage {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      methode {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      precision {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      photom_r1 {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      photom_r2 {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      photom_r3 {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      marks_cercle {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      globale_arret {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      globale_nberror {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      gaussian_statistics {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      read_out_noise {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      beta {
         set description "todo"
         lappend field "$::votable::Field::UCD \"meta.note\"" \
                       "$::votable::Field::DATATYPE \"float\"" \
                       "$::votable::Field::WIDTH \"8\"" \
                       "$::votable::Field::PRECISION \"2\"" \
                       "$::votable::Field::UNIT \"mas\""
      }
      author {
         set description "Name of the person who measure the image"
         set ucd "meta.id"
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"*\"" 
      }
      quality {
         set description "Quality of mesure"
         set ucd "meta.id"
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"*\"" 
      }
      when {
         set description "Date of the reduction (ISO)"
         set ucd "time.epoch"
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"24\"" 
      }
      bibitem {
         set description "Bibliographic reference"
         set ucd "meta.id"
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"*\"" 
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set field ""
         set description "oops"
      }
   }
   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}

## @brief Construction des elements FIELDS en fonction de la cle de la colonne
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @param val list   liste des valeurs de la cle (e.g. {cle data datatype description unit})
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getBinastParam { key val } {
   # Definition du param
   switch $key {
      timescale {
         set description "Time scale of the timing"
         set ucd "time.scale"
         set datatype "char"
         set unit ""
      }
      centerframe {
         set description "Center of the reference frame: 1: Heliocentric, 2: Geocentric, 3: Topocentric, 4: Spacecraft"
         set ucd "meta.code"
         set datatype "int"
         set unit ""
      }
      typeframe {
         set description "Type of the reference frame: 1: Astrometrique J2000, 2: Apparent, 3: Moyenne de la date, 4: Moyenne J2000"
         set ucd "meta.code"
         set datatype "int"
         set unit ""
      }
      coordtype {
         set description "Type of coordinates: 1: Spherical, 2: Rectangular, 3: Local, 4: Horizontal, 5: For observers, 6: For AO observers, 7: For computation (mean heliocentric J2000 frame) 8: For ESO Phase II Observing Blocks"
         set ucd "meta.code"
         set datatype "int"
         set unit ""
      }
      refframe {
         set description "Reference plane: 1: Equateur, 2:Ecliptic"
         set ucd "meta.code"
         set datatype "int"
         set unit ""
      }
      quality {
         set description "Quality code: A+ | A | B | C | D"
         set ucd "meta.code.qual"
         set datatype "char"
         set unit ""
      }
   }
   # Id et Nom du champ
   set param [list "$::votable::Field::ID \"${key}\"" "$::votable::Field::NAME \"${key}\""]
   if {[string length ${datatype}] > 0} { lappend param "$::votable::Param::DATATYPE ${datatype}" }
   if {[string length ${unit}] > 0}     { lappend param "$::votable::Param::UNIT ${unit}" }
   if {[string length ${ucd}] > 0}      { lappend param "$::votable::Param::UCD ${ucd}" }
   lappend param "$::votable::Param::VALUE ${val}"; # attribut value doit toijours etre present

   return [list $param [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}



## @brief Construction des elements FIELDS en fonction de la cle de la colonne pour le catalogue USER
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getFieldFromKey_USER { key } {
   # Id et Nom du champ
   set field [list "$::votable::Field::ID ${key}.USER" "$::votable::Field::NAME $key"]
   # Autres infos 

gren_info "key = $key\n"
   switch $key {
      name {
         set description "Source name or designation"
         set ucd "meta.id;meta.main"
         lappend field "$::votable::Field::UCD \"$ucd\"" \
                       "$::votable::Field::DATATYPE \"char\"" \
                       "$::votable::Field::ARRAYSIZE \"32\"" 
      }
      mobile {
         set description "Set to 1 to define a mobile object, else 0."
         lappend field "$::votable::Field::UCD \"meta.code\"" \
                       "$::votable::Field::DATATYPE \"int\"" \
                       "$::votable::Field::WIDTH \"1\"" \
                       "$::votable::Field::UNIT \"-\""
      }
      default {
         # si $key n'est pas reconnu alors on renvoie des listes vides
         set field ""
         set description ""
      }
   }
   return [list $field [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}


## @brief Construction des elements FIELDS en fonction de la cle de la colonne
# @param key string nom de la colonne dont on veut construire l'element FIELD
# @param val list   liste des valeurs de la cle (e.g. {cle data datatype description unit})
# @return list liste contenant la definition du champ et sa description
#
proc ::votable::getParamFromTabkey { key val } {
   # Definition du tabkey a inserer
   set cle [join [lindex $val 0] "."]
   set data [string trim [lindex $val 1]]
   set datatype [string tolower [string trim [lindex $val 2]]]
   if {[string equal $datatype "string"]} { set datatype "char" }
   if {[string equal $datatype "text"]} { set datatype "char" }
   set description [string trim [lindex $val 3]]
   set unit [lindex $val 4]
   # Defini l'UCD 
   switch [string toupper $key] {
      DATE-PC -
      DATE-GPS -
      DATE-OBS { set ucd "time.epoch" }
      CD1_1 -
      CD1_2 -
      CD2_1 -
      CD2_2    { set ucd "pos.wcs.cdmatrix" }
      CRPIX1 -
      CRPIX2   { set ucd "pos.wcs.crpix" }
      CRVAL1 -
      CRVAL2   { set ucd "pos.wcs.crval" }
      CTYPE1 -
      CTYPE2   { set ucd "pos.wcs.crtype" }
      NAXIS    { set ucd "pos.wcs.crnaxes" }
      NAXIS1 -
      NAXIS2   { set ucd "pos.wcs.crnaxis" }
      default  { set ucd "meta.note" }
   }
   # Id et Nom du champ
   set param [list "$::votable::Field::ID \"${cle}\"" "$::votable::Field::NAME \"${cle}\""]
   if {[string length ${datatype}] > 0} { lappend param "$::votable::Param::DATATYPE ${datatype}" }
   if {[string length ${unit}] > 0}     { lappend param "$::votable::Param::UNIT ${unit}" }
   if {[string length ${ucd}] > 0}      { lappend param "$::votable::Param::UCD ${ucd}" }
   lappend param "$::votable::Param::VALUE ${data}"; # attribut value doit toijours etre present

   return [list $param [::votable::addElement $::votable::Element::DESCRIPTION {} $description]]
}
