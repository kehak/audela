#--------------------------------------------------
# source [ file join $audace(rep_plugin) tool bddimages utils pgsql_json main.json_notab.tcl]
#--------------------------------------------------
#
# Fichier        : main.tcl
# Description    : lecture d un fichier de mesure pour calculer les offset sur l asteroide
# Auteur         : Frederic Vachier
# Mise Ã  jour $Id: main.json_notab.tcl 13228 2016-02-20 12:14:00Z fredvachier $
#


   source [ file join $audace(rep_plugin) tool bddimages utils pgsql_json funcs.tcl]

   package require json
   package require tdbc::postgres 1.0 
   tdbc::postgres::connection create dbbdi -user postgres -db bdi
   catch {
      set stmt [dbbdi prepare {
         DROP TABLE json_data
      } ] 
      $stmt execute
      $stmt close
   }

   catch {
      set stmt [dbbdi prepare {
         CREATE TABLE json_data (data JSONB)
      } ] 
      $stmt execute
      $stmt close
   }

   set chan0 [open [ file join $audace(rep_plugin) tool bddimages utils pgsql_json insert.json_notab.csv] w]
   puts $chan0 "index,tms,cumulms"
   set cumulms 0
   
   
   # recupere les donnees

   set sqlcmd "SELECT * FROM images;"
   set err [catch {set rimages [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      gren_erreur "Erreur de lecture de la liste des header par SQL"
   }

   set nbimgtoinsert [llength $rimages]
   set nbimg 0

   set tt0 [clock clicks -milliseconds]   
   foreach limages $rimages {
   
   
      set idbddimg    [lindex $limages 0]
      set idheader    [lindex $limages 1]
      set tabname     [lindex $limages 2]
      set filename    [lindex $limages 3]
      set dirfilename [lindex $limages 4]
      set sizefich    [lindex $limages 5]
      set datemodif   [lindex $limages 6]
      #gren_info "$nbimg / $nbimgtoinsert\n"
      #gren_info "$nbimg / $nbimgtoinsert : $idbddimg $tabname $filename\n"

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

      #for {set i 1} {$i<=$cpt} {incr i} {
      #   set a [lindex $head($i) 1]
      #   gren_info "TEST : $head($i) = $vals($i) => $a\n"
      #   break
      #}

      set tabkeyjson "{\"idbddimg\":$idbddimg, \"tabkey\":\{"
      set c 0
      #set cpt 3
      for {set i 1} {$i<=$cpt} {incr i} {
         #gren_info "$head($i) = $vals($i)\n"
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

         set value   "      \"value\": \"$value\""
         set type    "      \"type\": \"$type\""
         set unit    "      \"unit\": \"$unit\""
         
         regsub -all {\"} $comment {}  comment
         set comment [string trim $comment]
         set comment "      \"comment\": \"$comment\""
         append tabkeyjson "   \n\"$key\":{\n$value,\n$type,\n$unit,\n$comment\n }  "
         incr c
      }
      append tabkeyjson "\n\}}"    

      #gren_info "$tabkeyjson\n"
      
      set err [catch {
         set tti0 [clock clicks -milliseconds]
         set stmt [dbbdi prepare {
             INSERT INTO json_data (data) VALUES (:jjson)
         }]
         set jjson $tabkeyjson
         $stmt execute
         $stmt close
         set tti  [format "%.0f" [expr ([clock clicks -milliseconds]   - $tti0)]]
         set cumulms [expr $cumulms + $tti]
         puts $chan0 "$nbimg,$tti,[format {%.0f} $cumulms]"
      } msg ]
      
      if {$err!=0} {
         gren_info "tabkeyjson = $tabkeyjson \n"
         gren_erreur "err = $err ; msg = $msg\n"
         return
      }
      
      incr nbimg
      #break
   }
   set tt_total  [format "%.3f" [expr ([clock clicks -milliseconds]   - $tt0) / 1000.0]]

   gren_info "NB img = $nbimg\n"
   gren_info "Temps de Lecture Mysql + Insertion Postgres en $tt_total sec\n"
   gren_info "Temps d'Insertion Postgres en [format {%.3f} [expr $cumulms/1000.0]] sec\n"
   gren_info "Insertion terminée\n"
   dbbdi close
   close $chan0

return

# Select type 1

   # Tous les objets distinct
   set tt0 [clock clicks -milliseconds]   
   dbbdi foreach row {
      SELECT DISTINCT data->'tabkey'->'OBJECT'->>'value' as object FROM json_data
   }  { gren_info "[dict get $row]\n"}
   set tt_total  [format "%5.1f" [expr ([clock clicks -milliseconds]   - $tt0) / 1000.0]]
   gren_info "requete en $tt_total sec\n"

   # Nb d images de 2008 FU6
   set tt0 [clock clicks -milliseconds]   
   dbbdi foreach row {
      SELECT count(*) as nb FROM json_data WHERE data->'tabkey'->'OBJECT'->>'value'='2008_FU6'
   }  { gren_info "[dict get $row]\n"}
   set tt_total  [format "%5.1f" [expr ([clock clicks -milliseconds]   - $tt0) / 1000.0]]
   gren_info "requete en $tt_total sec\n"

   # Nb d images du t1m%
   set tt0 [clock clicks -milliseconds]   
   dbbdi foreach row {
      SELECT count(*) as nb FROM json_data WHERE data->'tabkey'->'TELESCOP'->>'value' like 't1m%'
   }  { gren_info "[dict get $row]\n"}
   set tt_total  [format "%5.1f" [expr ([clock clicks -milliseconds]   - $tt0) / 1000.0]]
   gren_info "requete en $tt_total sec\n"

# Select type 2

   # Tous les objets 
   set tt0 [clock clicks -milliseconds]   
   dbbdi foreach row {
      SELECT DISTINCT data#>>'{tabkey,OBJECT,value}' as object FROM json_data
   }  { gren_info "[dict get $row]\n"}
   set tt_total  [format "%5.1f" [expr ([clock clicks -milliseconds]   - $tt0) / 1000.0]]
   gren_info "requete en $tt_total sec\n"

   # Nb d images de 2008 FU6
   set tt0 [clock clicks -milliseconds]   
   dbbdi foreach row {
      SELECT count(*) as nb FROM json_data WHERE data#>>'{tabkey,OBJECT,value}'='2008_FU6'
   }  { gren_info "[dict get $row]\n"}
   set tt_total  [format "%5.1f" [expr ([clock clicks -milliseconds]   - $tt0) / 1000.0]]
   gren_info "requete en $tt_total sec\n"

  # Nb d images du t1m%
   set tt0 [clock clicks -milliseconds]   
   dbbdi foreach row {
      SELECT count(*) as nb FROM json_data WHERE data#>>'{tabkey,TELESCOP,value}' like 't1m%'
   }  { gren_info "[dict get $row]\n"}
   set tt_total  [format "%5.1f" [expr ([clock clicks -milliseconds]   - $tt0) / 1000.0]]
   gren_info "requete en $tt_total sec\n"

  # toutes les images du t1m% dans un tableau memoire
   array unset tab
   set tt0 [clock clicks -milliseconds]   
   dbbdi foreach row {
      SELECT *  FROM json_data WHERE data#>>'{tabkey,TELESCOP,value}' like 't1m%'
   }  { set tab[] [dict get $row]}
   set tt_total  [format "%5.1f" [expr ([clock clicks -milliseconds]   - $tt0) / 1000.0]]
   gren_info "requete en $tt_total sec\n"
#
   dbbdi foreach row {
      SELECT * FROM json_data 
   }  { gren_info "[dict get $row]\n"}

   dbbdi foreach row {
      SELECT data->'tabkey'->'APTDIA'->>'value' FROM json_data
   }  { gren_info "[dict get $row]\n"}

   dbbdi foreach row {
      SELECT data->'idbddimg' as idbddimg FROM json_data WHERE data->'tabkey'->'APTDIA'->>'value'='0.6'
   }  { gren_info "[dict get $row]\n"}

   set tt0 [clock clicks -milliseconds]   
   dbbdi foreach row {
      SELECT count(*) as idbddimg FROM json_data WHERE data->'tabkey'->'OBJECT'->>'value'='2008_FU6'
   }  { gren_info "[dict get $row]\n"}
   set tt_total  [format "%5.1f" [expr ([clock clicks -milliseconds]   - $tt0) / 1000.0]]
   gren_info "requete en $tt_total sec\n"

#
