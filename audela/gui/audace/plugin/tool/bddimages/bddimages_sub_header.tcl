## @file bddimages_sub_header.tcl
#  @brief     Fonctions de manipulation des ent&ecirc;tes des images dans la base de donn&eacute;es (no namespace)
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bddimages_sub_header.tcl]
#  @endcode

# $Id: bddimages_sub_header.tcl 14498 2018-09-27 21:49:42Z jberthier $


# transforme un mot cle du header en
# variable pour la BDD

# ---------------------------------------
proc bddimages_keywd_to_variable { key } {

#  set tmp [string map {"-" "_"} [string tolower $key]]
  set tmp [string map {" " "_"} [string tolower $key]]
  return $tmp

}

proc bddimages_convert_type_variable_buf_to_sql { type } {

   # -- Creation de la ligne sql pour la creation d une nouvelle table header
   switch $type {
      "string" {
         return "TEXT"
      }
      "float" {
         return "FLOAT"
      }
      "double" {
         return "DOUBLE"
      }
      "int" {
         return "INT"
      }
      "" {
         bddimages_sauve_fich "bddimages_header_id: ERREUR 203 : type de champ du header vide"
         return -code error "203"
      }
      default {
         bddimages_sauve_fich "bddimages_header_id: ERREUR 204 : type de champ du header inconnu <$type>"
         return -code error "204"
      }
   }

}


proc bddimages_convert_type_variable_sql_to_buf { type } {

   # -- Creation de la ligne sql pour la creation d une nouvelle table header
   switch $type {
      "TEXT" {
         return "string"
      }
      "FLOAT" {
         return "float"
      }
      "DOUBLE" {
         return "double"
      }
      "INT" {
         return "int"
      }
      "" {
         bddimages_sauve_fich "bddimages_header_id: ERREUR 203 : type de champ du header vide"
         return -code error "203"
      }
      default {
         bddimages_sauve_fich "bddimages_header_id: ERREUR 204 : type de champ du header inconnu <$type>"
         return -code error "204"
      }
   }

}


# ---------------------------------------

# bddimages_header_id

# Determine le type de header de l image
# créé les structures de table si besoin

# ---------------------------------------
proc bddimages_header_id { tabkey } {

   global bddconf

   # --- Recuperation des champs des header de la base
   set sqlcmd ""
   append sqlcmd "SELECT idheader,keyname,type FROM header;"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]

   if {$err} {
      bddimages_sauve_fich "bddimages_header_id: ERREUR : <$err> <$msg>"

      if {[string last "header' doesn't exist" $msg]>0} {
          unset sqlcmd
          append sqlcmd "CREATE TABLE header ("
          append sqlcmd "idheader INT NOT NULL,"
          append sqlcmd "keyname VARCHAR(40) NOT NULL,"
          append sqlcmd "type VARCHAR(20) NOT NULL,"
          append sqlcmd "variable VARCHAR(40) NOT NULL,"
          append sqlcmd "unit VARCHAR(40) NULL,"
          append sqlcmd "comment VARCHAR(256) NULL"
          append sqlcmd ") ENGINE = MyISAM ;"
          set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
          if {$err} {
             bddimages_sauve_fich "bddimages_header_id: ERREUR 201 : Creation table header <$err> <$msg>"
             bddimages_sauve_fich "bddimages_header_id: SQL : $sqlcmd"
             return [list 201 0]
          } else {
             bddimages_sauve_fich "bddimages_header_id: Creation table header..."
             set resultsql ""
          }
      } elseif {[string last "::mysql::query/db server: MySQL server has gone away" $msg]>=0} {
          set err [catch {::bddimages_sql::connect} msg]
          set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
          if {$err} { return [list 208 0] }
      } else {
          bddimages_sauve_fich "bddimages_header_id: ERREUR 202 : Impossible d acceder aux informations de header"
          bddimages_sauve_fich "bddimages_header_id:    NUM : <$err>"
          bddimages_sauve_fich "bddimages_header_id:    MSG : <$msg>"
          bddimages_sauve_fich "bddimages_header_id:    SQL : <$sqlcmd>"
          return [list 202 0]
      }
   }

   # -- Construction de chaque liste de mot-cles des header de la base
   foreach line $resultsql {
     set idheader [lindex $line 0]
     set key [lindex $line 1]
     set type [lindex $line 2]
     lappend header($idheader) $key
     #::console::affiche_resultat "$key = $type \n"
     lappend matchkey($idheader) [concat $key $type ]
   }

   # -- Comparaison des mot-cles des header de la base avec le header de l image
   set arrnames [array names matchkey]
   set keynames [array names header]
   set listidentique "no"
   #::console::affiche_resultat "arrnames = $arrnames"

   foreach idhd $arrnames {

     #::console::affiche_resultat "idheader = $idhd"
     set listbase [lsort -ascii $matchkey($idhd)]
     set listidentique "yes"
     set list_keys ""
     #::console::affiche_resultat "listbase = $listbase"

     foreach key $tabkey {
       #::console::affiche_resultat "key = $key"
       set bufname [lindex $key {1 0} ] 
       set err [catch {set sqltype [bddimages_convert_type_variable_buf_to_sql [lindex $key {1 2}] ]} msg]
       if {$err} {
          gren_erreur "ERROR : $key (err=$err) (msg=$msg)\n"
       }
       #::console::affiche_resultat "list_keys = $bufname T $sqltype"
       lappend list_keys [concat $bufname $sqltype ]
     }
       
     set list_keys [lsort -ascii $list_keys]
     if {[llength $list_keys]==[llength $listbase]} {
       foreach key $listbase {
         if {[lsearch -exact $list_keys $key]<0} {
           set listidentique "no"
         }
       }
       if {$listidentique=="yes"} {
          set idheader $idhd
       }
     } else {
       set listidentique "no"
     }
     if {$listidentique=="yes"} {
       break
     }
   }

   # -- Creation d un nouveau type de header
   if {$listidentique=="no"} {

     # -- determination du nouveau id (bouche les trous)
     set idhdder [lindex [lsort -integer -decreasing $keynames] 0]
     set idheader 0
     for {set x 1} {$x<=$idhdder} {incr x} {
       if {[lsearch -exact $keynames $x]<0} {
         set idheader $x
         break
       }
     }

 #    bddimages_sauve_fich "bddimages_header_id: idheader = $idheader"
     if {$idheader==0} {
       set idhdder [expr $idhdder + 1]
       set idheader $idhdder
 #      bddimages_sauve_fich "bddimages_header_id: Ajoute un nouveau header en fin de liste <IDHD=$idheader>"
     }

     # -- Creation de la ligne sql pour l insertion du nouvel header
     set sqlcmd ""
     set sqlcmd2 ""

     append sqlcmd "INSERT INTO header (idheader, keyname, type, variable, unit, comment) VALUES \n"
     append sqlcmd2 "CREATE TABLE images_$idheader (\n"
     append sqlcmd2 "`idbddimg` bigint(20) NOT NULL,\n"

     foreach keyval $tabkey {
       
       set var     [lindex $keyval 0]
       set info    [lindex $keyval 1]

       set key     [lindex $info 0]
       set typebuf [lindex $info 2]
       set unit    [lindex $info 4]
       set comment [lindex $info 3]

       set err [catch {set typesql [bddimages_convert_type_variable_buf_to_sql $typebuf]} msg]
       if {$err} {
          bddimages_sauve_fich "bddimages_header_id: ERREUR $err : Insertion table header <$err> <$msg> <$keyval>"
          return [list $err 0]
       }

       append sqlcmd2 "`$var` $typesql NULL,\n"

       # -- Creation de la ligne sql pour l insertion d un nouvel enregistrement de la table header
       if {$unit==""} {
         set unit "NULL"
       } else {
         set unit "'$unit'"
       }
      if {$comment==""} {
        set comment "NULL"
      } else {
        # attention au caractere ' dans la chaine de caractere
        # on remplace par le caractere blanc
        set comment [string map {"'" " "} $comment]
        set comment "'$comment'"
      }
      append sqlcmd "($idheader, '$key', '$typesql','$var', $unit, $comment),\n"

     }
     #-- fin de foreach keyval $tabkey

     set sqlcmd "$sqlcmd"
     set sqlcmd [string trimright $sqlcmd ",\n"]

     set sqlcmd2 [string trimright $sqlcmd2 ",\n"]
     append sqlcmd2 ") ENGINE = MyISAM ;"

   #  bddimages_sauve_fich "bddimages_header_id: sqlcmd <$sqlcmd>"
   #  bddimages_sauve_fich "bddimages_header_id: sqlcmd2 <$sqlcmd2>"

   # -- Acces a la base

      # --Insertion d un nouvel enregistrement de la table header
      set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
      if {$err} {
         bddimages_sauve_fich "bddimages_header_id: ERREUR 205 : Insertion table header <$err> <$msg>"
         return [list 205 0]
      } else {
 #        bddimages_sauve_fich "bddimages_header_id: Insertion d un nouveau type de header dans la base <IDHD=$idheader>"
      }
      # -- Creation d une nouvelle table header
      set err [catch {::bddimages_sql::sql query $sqlcmd2} msg]
      if {$err} {
        bddimages_sauve_fich "bddimages_header_id: ERREUR 206 : Creation table images_$idheader <$err> <$msg> <$sqlcmd2> "
        set sqlcmd "DELETE FROM header WHERE idheader=$idheader"
        set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
        if {$err} {
          bddimages_sauve_fich "bddimages_header_id: ERREUR 207 : Effacement impossible dans la table header pour l id = $idheader  <$err> <$msg> "
          return [list 207 0]
        } else {
          bddimages_sauve_fich "bddimages_header_id: Effacement dans la table header pour IDHD=$idheader "
        }
        return [list 206 0]
      } else {
#          bddimages_sauve_fich "bddimages_header_id: Insertion d un nouveau type de header dans la base <IDHD=$idheader> "
      }

   }
   # -- Fin Creation d un nouveau type de header

   return [list 0 $idheader]
}
