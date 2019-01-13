#--------------------------------------------------
# source [ file join $audace(rep_plugin) tool bddimages utils pgsql_json main.tcl]
#--------------------------------------------------
#
# Fichier        : main.tcl
# Description    : lecture d un fichier de mesure pour calculer les offset sur l asteroide
# Auteur         : Frederic Vachier
# Mise à jour $Id: main.tcl 13218 2016-02-19 09:04:31Z jberthier $
#


   source [ file join $audace(rep_plugin) tool bddimages utils pgsql_json funcs.tcl]

   package require json
   package require tdbc::postgres 1.0 
   set db [tdbc::postgres::connection create dbbdi -user postgres -db bdi]
   set stmt [dbbdi prepare {
      DELETE FROM json_data
   } ]
   $stmt execute
   $stmt close

   # recupere les donnees

   set sqlcmd "SELECT * FROM images LIMIT 2;"
   set err [catch {set rimages [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      gren_erreur "Erreur de lecture de la liste des header par SQL"
   }

   foreach limages $rimages {
   
   
      set idbddimg    [lindex $limages 0]
      set idheader    [lindex $limages 1]
      set tabname     [lindex $limages 2]
      set filename    [lindex $limages 3]
      set dirfilename [lindex $limages 4]
      set sizefich    [lindex $limages 5]
      set datemodif   [lindex $limages 6]
      gren_info "$idbddimg $tabname $filename\n"

      array unset head
      array unset vals

      set sqlcmd "SELECT * FROM header WHERE idheader=$idheader;"
      set err [catch {set rid [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         gren_erreur "Erreur de lecture de la table $tabname"
      }
      set cpt 0
      foreach x $rid {
         incr cpt
         set head($cpt) $x
         #gren_info "head($cpt) = $x\n"
      }
    
      set sqlcmd "SELECT * FROM $tabname where idbddimg=$idbddimg LIMIT 1;"
      set err [catch {set rid [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         gren_erreur "Erreur de lecture de la table $tabname"
      }
      set cpt -1
      foreach x [lindex $rid 0] {
         incr cpt
         set vals($cpt) $x
         #gren_info "vals($cpt) = $x\n"
      }

      for {set i 1} {$i<=$cpt} {incr i} {
         set a [lindex $head($i) 1]
         gren_info "TEST : $head($i) = $vals($i) => $a\n"
         break
      }

      set tabkeyjson "{\"idbddimg\":$idbddimg, \"tabkey\":\["
      set c 0
      for {set i 1} {$i<=$cpt} {incr i} {
         gren_info "$head($i) = $vals($i)\n"
         if {$c==0} {
            append tabkeyjson "\n"
         } else {
            append tabkeyjson ",\n"
         }
         set key     [lindex $head($i) 1]
         set value   $vals($i)
         set type    [lindex $head($i) 2]
         set unit    [lindex $head($i) 4]
         set comment [lindex $head($i) 5]

         set key     "      \"key\": \"$key\""
         set value   "      \"value\": \"$value\""
         set type    "      \"type\": \"$type\""
         set unit    "      \"unit\": \"$unit\""
         set comment "      \"comment\": \"$comment\""
         append tabkeyjson "   {\n$key,\n$value,\n$type,\n$unit,\n$comment\n   }"
         incr c
      }
      append tabkeyjson "\n\]}"    

      gren_info "$tabkeyjson\n"
      
   set stmt [dbbdi prepare {
       INSERT INTO json_data (data) VALUES (:jjson)
   }]
   set jjson $tabkeyjson
   $stmt execute
   $stmt close
      
      break
   }
   dbbdi close

return

   dbbdi foreach row {
      SELECT * FROM json_data WHERE data->'tabkey'->>'key' = 'WCSAXES' AND data->'tabkey'->>'value' = '2' 
   }  { gren_info "[dict get $row]\n"}

   dbbdi foreach row {
      SELECT * FROM json_data 
   }  { gren_info "[dict get $row]\n"}

   dbbdi close

   dbbdi foreach row {
      SELECT * FROM json_data WHERE data->>'{tabkey,key}'
   }  { gren_info "[dict get $row]\n"}

return
# vendredi

   dbbdi foreach row {
      SELECT * FROM json_data 
   }  { gren_info "[dict get $row]\n"}


return

   gren_info "to dict\n"
   set tabkeydict [::json::json2dict $tabkeyjson]
   #gren_info "tabkeydict = $tabkeydict"

return

# Par TDBC

   # connect
   package require tdbc::postgres 1.0 
   set db [tdbc::postgres::connection create dbbdi -user postgres -db bdi]

   # insert
   set stmt [dbbdi prepare {
       INSERT INTO json_data (data) VALUES (:jjson)
   }]
   set jjson {{"name": "Apple Phone 3A", "type": "phone", "brand": "ACME", "price": 700, "available": false, "warranty_years": 1}}
   $stmt execute
   $stmt close
   
   # insert
   set json {"name": "Apple Phone 4A", "type": "phone", "brand": "ACME", "price": 700, "available": false, "warranty_years": 1}
   set stmt [dbbdi prepare [format {INSERT INTO json_data (data) VALUES ('{%s}')} $json]]
   $stmt execute
   $stmt close



   set stmt [dbbdi prepare {
       INSERT INTO json_data (data) VALUES ('{"name": "Apple Phone 4A", "type": "phone", "brand": "ACME", "price": 700, "available": false, "warranty_years": 1}')
   }]
   $stmt execute
   $stmt close



   # select
   dbbdi foreach row {
      SELECT DISTINCT data->>'name' as products FROM json_data
   }  { gren_info "[dict get $row products]\n"}
   # ou
   dbbdi foreach row {
      SELECT DISTINCT data->>'name' as products FROM json_data
   }  { gren_info " [dict get $row]\n"}

   # select
   set stmt [dbbdi prepare {
       SELECT DISTINCT data->>'name' as products FROM json_data
   }]
   $stmt foreach row {gren_info "[dict get $row]\n"}
   $stmt close

   # disconnect
   dbbdi close
   
# Par PgTCL

   # connect
   package require Pgtcl
   set db [pg_connect -conninfo [list user = postgres dbname = bdi]]
   pg_select $db "CREATE TABLE json_data (data JSON);" user {
       parray user
   }

   # insert
   set json {"name": "Apple Phone", "type": "phone", "brand": "ACME", "price": 200, "available": true, "warranty_years": 1}
   pg_select $db "INSERT INTO json_data (data) VALUES ('{$json}');" user {
       parray user
   }

   # select
   pg_select $db "SELECT DISTINCT data->>'name' as products FROM json_data;" user {
       gren_info "[array get user]\n"
       gren_info "products=$user(products)\n"
   }

   # select
   set tt0 [clock clicks -milliseconds]   
   pg_select $db "SELECT count(*) as nb FROM json_data WHERE data#>>'{tabkey,TELESCOP,value}' like 't60%';" user {
       gren_info "[array get user]\n"
   }
   set tt_total  [format "%5.1f" [expr ([clock clicks -milliseconds]   - $tt0) / 1000.0]]
   gren_info "requete en $tt_total sec\n"

   # disconnect
   pg_disconnect $db

return

   set stmt [dbbdi prepare {
       INSERT INTO json_data (data) VALUES (:jjson)
   }]
   set jjson {{"name": "Apple Phone 5A", "type": { "phone" : "noir", "clavier":"blanc", "aspect":"mat" }, "brand": "ACME", "price": 700, "available": false, "warranty_years": 1}}
   $stmt execute
   set jjson {{"name": "Apple Phone 6A", "type": { "phone" : "blanc", "clavier":"noir", "aspect":"mat" }, "brand": "ACME", "price": 700, "available": false, "warranty_years": 1}}
   $stmt execute
   set jjson {{"a": {"b":{"c": "foo"}}}}
   $stmt execute
   $stmt close

   set stmt [dbbdi prepare [format {SELECT DISTINCT data->>'{type,phone}' FROM json_data} ]]
   $stmt foreach row {gren_info "[dict get $row]\n" }
   $stmt close

   set stmt [dbbdi prepare {
      DELETE FROM json_data
   } ]
   $stmt execute
   $stmt close

   set stmt [dbbdi prepare {
      SELECT  data->'type'->>'phone' as p FROM json_data
   } ]
   $stmt foreach row {gren_info "[dict get $row]\n" }
   $stmt close

   set stmt [dbbdi prepare {
      SELECT  *  FROM json_data WHERE data->'type'->>'phone' = 'blanc' OR data->'type'->>'aspect' = 'mat' 
   } ]
   $stmt foreach row {gren_info "[dict get $row]\n" }
   $stmt close


   set stmt [dbbdi prepare {
       SELECT data::json#>'{type,phone}' FROM json_data
   }]
   $stmt foreach row {gren_info "[dict get $row]\n" }
   $stmt close

   set stmt [dbbdi prepare {
       SELECT '{"a": {"b":{"c": "foo"}}}'::json#>'{a,b}'
   }]
   $stmt foreach row {gren_info "[dict get $row]\n" }
   $stmt close

   set stmt [dbbdi prepare {
       SELECT DISTINCT data::json->>'a' FROM json_data
   }]
   $stmt foreach row {gren_info "[dict get $row]\n" }
   $stmt close

   set stmt [dbbdi prepare {
       SELECT data#>'{a,b}' FROM json_data
   }]
   $stmt foreach row {gren_info "[dict get $row]\n" }
   $stmt close

   set stmt [dbbdi prepare {
       SELECT data#>'{type,phone}' FROM json_data
   }]
   $stmt foreach row {gren_info "[dict get $row]\n" }
   $stmt close

   set stmt [dbbdi prepare {
       SELECT data#>'{type,phone}' as p FROM json_data
   }]
   $stmt foreach row {gren_info "[dict get $row]\n" }
   $stmt close

   set stmt [dbbdi prepare {
       SELECT * FROM json_data WHERE data->'type'->>'phone' = 'blanc'
   }]
   $stmt foreach row {gren_info "[dict get $row]\n" }
   $stmt close

   set stmt [dbbdi prepare {
       SELECT  data->'type'->>'phone' as p FROM json_data 
   }]
   $stmt foreach row {gren_info "[dict get $row]\n" }
   $stmt close






