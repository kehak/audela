# -- Procedure get_one_image
# Recupere une image de la base de donnees

proc get_one_image { } {

 global env
 global ssp_image
 global bddconf

 if {[info exists env(SSP_ID)]} {
   # pour ne traiter qu'une seule image
   # par exemple : SSP_ID=176 ./solarsystemprocess --console --file ros.tcl
   set id $env(SSP_ID)
   gren_info "::::::::::DEBUG::::::: Looping with SSP_ID=$id"
   set sqlcmd    "SELECT catas.idbddcata,catas.filename,catas.dirfilename,"
   append sqlcmd " cataimage.idbddimg,images.idheader, "
   append sqlcmd " images.filename,images.dirfilename "
   append sqlcmd " FROM catas,cataimage,images "
   append sqlcmd " WHERE cataimage.idbddcata=catas.idbddcata "
   append sqlcmd " AND cataimage.idbddimg=images.idbddimg "
   append sqlcmd " AND cataimage.idbddimg='$id' "
   append sqlcmd " LIMIT 1 "
   } else {
   # -- recuperation de la date de traitement la plus petite
   # gren_info "- Recuperation de la date de traitement la plus petite"
   set sqlcmd    "select min(ssp_date) from catas"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      gren_info "ASTROID: ERREUR 1"
      gren_info "ASTROID: NUM : <$err>" 
      gren_info "ASTROID: MSG : <$msg>"
      }
   set mindate  [lindex  [lindex $resultsql 0] 0]
   #gren_info "    mindate=$mindate\n"

   # -- recuperation d un fichier cata
   # gren_info "- Recuperation d un fichier cata"
   set sqlcmd    "SELECT catas.idbddcata,catas.filename,catas.dirfilename,"
   append sqlcmd " cataimage.idbddimg,images.idheader, "
   append sqlcmd " images.filename,images.dirfilename "
   append sqlcmd " FROM catas,cataimage,images "
   append sqlcmd " WHERE cataimage.idbddcata=catas.idbddcata "
   append sqlcmd " AND cataimage.idbddimg=images.idbddimg "
#   append sqlcmd " AND catas.ssp_date='$mindate' ORDER BY images.datemodif DESC"
   append sqlcmd " AND catas.ssp_date<now()-1"
   append sqlcmd " LIMIT 1 "
   }

   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      gren_info "ASTROID: ERREUR 2"
      gren_info "ASTROID: NUM : <$err>" 
      gren_info "ASTROID: MSG : <$msg>"
      }

   if {[llength $resultsql] <= 0} then { return 1 }

   set idbddcata -1

   foreach line $resultsql {
      set idbddcata      [lindex $line 0]
      set cata_filename  [lindex $line 1]
      set dir_cata_file  [lindex $line 2]
      set idbddimg       [lindex $line 3]
      set idheader       [lindex $line 4]
      set fits_filename  [lindex $line 5]
      set fits_dir       [lindex $line 6]
      set header_tabname  "images_$idheader"
      }


# gren_info "- Recuperation d info table imagex\n"

   set sqlcmd    "select `date-obs`,`ra`,`dec`,`telescop`,`exposure`,`filter` from $header_tabname where idbddimg='$idbddimg'"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      gren_info "ASTROID: ERREUR 3"
      gren_info "ASTROID: NUM : <$err>" 
      gren_info "ASTROID: MSG : <$msg>"
      }

   set line     [lindex $resultsql 0] 
   set dateobs  [lindex $line 0]
   set ra       [lindex $line 1]
   set dec      [lindex $line 2]
   set telescop [lindex $line 3]
   set exposure [lindex $line 4]
   set filter   [lindex $line 5]

   foreach n { idbddcata cata_filename dir_cata_file idbddimg idheader 
                fits_filename fits_dir header_tabname dateobs ra dec telescop 
                exposure filter } { set ssp_image($n) [set $n] }

   set fullname [file join $bddconf(dirbase) $fits_dir $fits_filename]
   if { ! [file exists  $fullname] } {
       #gren_info "ASTROID: $fullname doesn't exist\n"
       return 2;
   } 

   set fullname [file join $bddconf(dirbase) $dir_cata_file $cata_filename]
   if { ! [file exists  $fullname] } {
       #gren_info "ASTROID: $fullname doesn't exist\n"
       return 3;
   } 





 return 0
 }
