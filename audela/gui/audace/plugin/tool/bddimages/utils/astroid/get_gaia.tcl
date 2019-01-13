# -- Requete d'u'un serveur TAP GAIA pour extraire les sources d'un champ de vue
# Le serveur appele est celui d'Heidelberg qui propose differents format de sortie.
# Appel: get_gaia 12.1234 23.1234 10.0
# Serveur (default): http://gaia.ari.uni-heidelberg.de/tap 
# Autre serveur (binary output): http://gea.esac.esa.int/tap-server/tap
#
# Parameter "format": It should be a String value among:
#   application/x-votable+xml (or votable),
#   application/x-votable+xml;serialization=BINARY2 (or votable/b2),
#   application/x-votable+xml;serialization=TABLEDATA (or votable/td),
#   application/x-votable+xml;serialization=FITS (or votable/fits),
#   application/fits (or fits),
#   application/json (or json),
#   text/csv (or csv),
#   text/tab-separated-values (or tsv),
#   text/plain (or text),
#   text/html (or html)

proc get_gaia { args } {

   package require base64
   # Compatibilite ascendante
   if { [ package require dom ] == "2.6" } {
      interp alias {} ::dom::parse {} ::dom::tcl::parse
      interp alias {} ::dom::selectNode {} ::dom::tcl::selectNode
      interp alias {} ::dom::node {} ::dom::tcl::node
   }

   global gaia_list
   
   # Lecture arguments
   set argc [llength $args]
   if {$argc >= 3} {
      set url    "http://gaia.ari.uni-heidelberg.de/tap"
      set ra     [lindex $args 0]
      set dec    [lindex $args 1]
      set radius [expr [lindex $args 2] / 60.0]
      set topnum 10000
      set maglimit_min 0
      set maglimit_max 20
      if {$argc >= 4} {
         for {set k 4} {$k<[expr $argc-1]} {incr k} {
            set key [lindex $args $k]
            if {$key == "-topnum"} {
               set topnum [lindex $args [expr $k+1]]
            }
            if {$key == "-mag_limit_min"} {
               set maglimit_min [lindex $args [expr $k+1]]
            }
            if {$key == "-mag_limit_max"} {
               set maglimit_max [lindex $args [expr $k+1]]
            }
         }
      }
   } else {
      set line "Usage: \n"
      append line "get_gaia ra dec radius ?-topnum n? ?-mag_limit_min mag? ?-mag_limit_max mag?\n"
      append line "# Parametres :\n"
      append line "#   ra                : RA du centre du FOV\n"
      append line "#   dec               : DEC du centre du FOV\n"
      append line "#   radius            : Rayon de recherche en arcmin\n"
      append line "# Parametres optionels :\n"
      append line "#   -topnum 10000     : Nombre d'etoiles maximum\n"
      append line "#   -mag_limit_min 0  : Magnitude Gaia minimum\n"
      append line "#   -mag_limit_max 23 : Magnitude Gaia maximum\n"
      error $line
      return -code 1
   }

   set no_answer 0
   set gaia_answered 0

   # Requete ADQL
   set adql_query "SELECT TOP $topnum source_id,ref_epoch,ra,ra_error,dec,dec_error,parallax,"
   append adql_query " parallax_error,pmra,pmra_error,pmdec,pmdec_error,astrometric_primary_flag,"
   append adql_query " astrometric_priors_used,phot_g_mean_flux,phot_g_mean_flux_error,"
   append adql_query " phot_g_mean_mag,phot_variable_flag FROM gaiadr1.gaia_source  "
   append adql_query " WHERE CONTAINS(POINT('ICRS',gaiadr1.gaia_source.ra,gaiadr1.gaia_source.dec),"
   append adql_query " CIRCLE('ICRS',$ra,$dec,$radius))=1"
   append adql_query " AND (phot_g_mean_mag>=$maglimit_min AND phot_g_mean_mag<=$maglimit_max)"

   # Definition de la requete TAP
   set query "${url}/sync?REQUEST=doQuery&LANG=ADQL&FORMAT=votable/td"
   append query "&" [::http::formatQuery QUERY ${adql_query}]

   gren_debug "  GAIA-CONESEARCH: $ra $dec $radius \n"
   gren_debug "           query = $query\n"

   # Soumet la requete
   while {$gaia_answered == 0} {
      set err [catch {::http::geturl $query} token]
      if {$err} {
         gren_info "get_gaia: ERREUR 7\n"
         gren_info "get_gaia:    NUM : <$err>\n" 
         gren_info "get_gaia:    MSG : [::http::data $token]\n"
         incr no_answer
         if {$no_answer > 10} {
            break
         }
      } else {
         set gaia_answered 1
      }
   }

   # Recupere la reponse
   set gaia_result [::http::data $token]
   set err [catch {::dom::parse $gaia_result} votable]
   if {$err != 0} {
      gren_info "Erreur d'analyse de la votable Gaia:"
      gren_info "  err = $err\n"
      gren_info "  msg = $votable\n"
      return -1
   }

   gren_debug "VOTABLE: $gaia_result\n"

   # -- Parse the votable and extract the stars from the parsed votable
   set gaia_error {}
   foreach n [::dom::selectNode $votable {descendant::INFO/attribute::name}] {
      if {[::dom::node stringValue $n] == "QUERY_STATUS"} {
         set nodeVal [::dom::selectNode $votable {descendant::INFO/attribute::value}]
         set gaia_error [::dom::node stringValue [lindex $nodeVal 0]]
         if { $gaia_error != "OK"} {
            gren_info "Error with GAIA query: $gaia_error\n"
            return -1
         }
      }
   }

   # Extraction des champs de la votable
   set gaia_fields {}
   foreach n [::dom::selectNode $votable {descendant::FIELD/attribute::name}] {
      lappend gaia_fields "[::dom::node stringValue $n]"
   }
   set voconf(fields) $gaia_fields
   set gaia_list {}
   set fields [list [list "GAIA1" {} $gaia_fields] ] 

   # Extraction des data
   set cpt 0
   foreach tr [::dom::selectNode $votable {descendant::TR}] {
      set row {}
      set urlNodeVal ""
      foreach td [::dom::selectNode $tr {descendant::TD/text()}] {
         set nodeVal [::dom::node stringValue $td]
         lappend row $nodeVal
      }
      # Gaia data from GAIA catalogue
      set row [list [list "GAIA1" {} $row]]
      lappend gaia_list $row
      incr cpt
   }

   # Destruction de l'objet DOM
   ::dom::destroy $votable

   # Definition du cata GAIA
   set gaia_cata [list $fields $gaia_list]

   # Retour de la reponse
   if {$cpt == 0} {
      return -1
   } else {
      return $gaia_cata
   }

}
