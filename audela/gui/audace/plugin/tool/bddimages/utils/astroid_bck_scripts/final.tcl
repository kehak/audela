# -- Procedure d'insertion des corps identifies dans la table ros.ssp_astrometric
proc sql_ssp_identification_insert { fields } {

 global bddconf

 set params {}
 foreach field $fields {
  set x [string map {{'} {\'}} $field]
  lappend params "'$x'"
 }
 set sqlcmd "INSERT INTO ros.ssp_astrometric VALUES ([join $params ,])"

 set err [catch {set sqlresult [::bddimages_sql::sql query $sqlcmd]} msg]
 if {$err} {
  switch $msg {
    "::mysql::query/db server: Table 'ros.ssp_astrometric' doesn't exist" {
      set sqlcmdcrea ""
      append sqlcmdcrea "CREATE TABLE IF NOT EXISTS ros.ssp_astrometric ("
      append sqlcmdcrea " idbddimg bigint(20) NOT NULL,"
      append sqlcmdcrea " idbddcata bigint(20) NOT NULL,"
      append sqlcmdcrea " datemodif DATETIME NOT NULL,"
      append sqlcmdcrea " dateobsjd double,"
      append sqlcmdcrea " num bigint(20),"
      append sqlcmdcrea " name varchar(128),"
      append sqlcmdcrea " ira double NOT NULL,"
      append sqlcmdcrea " idec double NOT NULL,"
      append sqlcmdcrea " sra double NOT NULL,"
      append sqlcmdcrea " sdec double NOT NULL,"
      append sqlcmdcrea " iradialerrpos double NOT NULL,"
      append sqlcmdcrea " sradialerrpos double NOT NULL,"
      append sqlcmdcrea " deltapos double NOT NULL,"
      append sqlcmdcrea " scorepos double NOT NULL,"
      append sqlcmdcrea " irmag double NOT NULL,"
      append sqlcmdcrea " svmag double NOT NULL,"
      append sqlcmdcrea " irmagerr double NOT NULL,"
      append sqlcmdcrea " svmagerr double NOT NULL,"
      append sqlcmdcrea " deltamag double NOT NULL,"
      append sqlcmdcrea " scoremv double NOT NULL,"
      append sqlcmdcrea " score double NOT NULL,"
      append sqlcmdcrea " scoreposlimit double NOT NULL,"
      append sqlcmdcrea " scoremvlimit double NOT NULL,"
      append sqlcmdcrea " scorelimit double NOT NULL,"
      append sqlcmdcrea " idcatasrc bigint(20) NOT NULL,"
      append sqlcmdcrea " flagsex integer NOT NULL"
      append sqlcmdcrea ") ENGINE=MyISAM;"

      set err [catch {::bddimages_sql::sql query $sqlcmdcrea} msg]
      if {$err} {
        gren_info "sql_ssp_identification_insert: ERREUR 101 :Creation table images <err=$err> <msg=$msg> <sql=$sqlcmdcrea>"
        return 101
      } else {
        set resultsql ""
        set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
        if {$err} {
          gren_info  "sql_ssp_identification_insert: ERREUR 102 : Impossible d inserer un element dans la table ssp_astrometric <err=$err> <msg=$msg> <sql=$sqlcmd>"
          return 102
        } else {
        }
      }
    }

    default {
      gren_info "sql_ssp_identification_insert: ERREUR 103 : Impossible d acceder aux informations de ssp_astrometric <err=$err> <msg=$msg>"
      return 103
    }
  }
  # Fin switch
 }

 }



# -- Stockage des resultats 
proc insert_data_sql { isodate_now } {

 global ros
 global allidentifications
 global ssp_image

   if { [info exists ros(common,ssp,sql_insert)] && $ros(common,ssp,sql_insert) } {

    # gren_info "- Insertion des identifications dans la base locale"

    # On efface les eventuelles precedentes identifications pour la
    # combinaison de cette image avec ce cata
    set sqlcmd "DELETE FROM ros.ssp_astrometric WHERE idbddimg=$ssp_image(idbddimg) AND idbddcata=$ssp_image(idbddcata)"

    set err [catch {set sqlresult [::bddimages_sql::sql query $sqlcmd]} msg]
    if {$err} {
      gren_info "solarsystemprocess: ERREUR x"
      gren_info "solarsystemprocess:        NUM : <$err>" 
      gren_info "solarsystemprocess:        MSG : <$msg>"
      gren_info "solarsystemprocess:        SQL : $sqlcmd"
    }

    foreach cata_source $allidentifications {

      foreach cata $cata_source {
#         gren_info "cata  = $cata"
         set namecata [lindex $cata 0]
#         gren_info "namecata  = $namecata"
         if {$namecata == "skybot"} {
            set sbotnum       [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "num"] ]
            set sbotname      [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "name"] ]
            set sra           [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "ra"] ]
            set sdec          [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "de"] ]
            set sradialerrpos [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "errpos"] ]
            set svmag         [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "magV"] ]
            set svmagerr      1.
            }
         if {$namecata == "cador_cata"} {
            set ira           [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "ra"] ]
            set idec          [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "dec"] ]
            set iradialerrpos 0.5
            set irmag         [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "calib_mag"] ]
            set irmagerr      [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "err_mag"] ]
            set idcatasrc     [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "id"] ]
            set flag_sex      [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "flag_sex"] ]
            }
         }

      set deltapos       0
      set scorepos       0
      set scoremv        0
      set deltamag       0
      set score          0
      set scoreposlimit  0
      set scoremvlimit   0
      set scorelimit     0
         
      set values { }
      lappend values $ssp_image(idbddimg) $ssp_image(idbddcata) $isodate_now
      lappend values [mc_date2jd $ssp_image(dateobs)]
      lappend values $sbotnum $sbotname $ira $idec $sra $sdec $iradialerrpos 
      lappend values $sradialerrpos $deltapos $scorepos $irmag $svmag $irmagerr
      lappend values $svmagerr $deltamag $scoremv $score $scoreposlimit
      lappend values $scoremvlimit $scorelimit $idcatasrc $flag_sex
      sql_ssp_identification_insert $values
      }

   }

 }




# -- Envoi des resultats a PODET
proc send_podet { isodate_now } {

 global ros
 global allidentifications
 global ssp_image
 global voconf
 global ident_ovni_skybot
 global xmlmajordometemplate

   # -- construction d un fichier XML de resultat et soumission a l IMCCE
   if { $ident_ovni_skybot(accepted) <= 0 } {
   } else {
   # -- construction d un fichier XML de resultat
   #gren_info "- Construction d un fichier XML de resultat"
   set xmlparams {}
   lappend xmlparams %DOCUMENT_DATE% $isodate_now
   lappend xmlparams %DOCUMENT_TICKET% 0
   lappend xmlparams %DOCUMENT_AUTHOR% "ROS::SolarSystemProcess"
   lappend xmlparams %IMAGE_NAME% $ssp_image(fits_filename)
   lappend xmlparams %IMAGE_IDBDDIMG% $ssp_image(idbddimg)
   lappend xmlparams %IMAGE_TELESCOPE% $ssp_image(telescop)
   lappend xmlparams %IMAGE_LOCATION% $voconf(observer)
   lappend xmlparams %IMAGE_EXPOSURE% $ssp_image(exposure)
   lappend xmlparams %IMAGE_FILTRE% [string trim $ssp_image(filter) { }]
   lappend xmlparams %PARAM_EPOCH% $ssp_image(dateobs)

    # Construction du message XML
    set tabledata {}
    foreach params $allidentifications {
     array set p $params
     append tabledata "<vot:TR>"
     foreach n { sbotnum sbotname sra sdec iradialerrpos sradialerrpos srmag srmagerr deltamag deltapos scorepos scoremv score scoreposlimit scoremvlimit scorelimit } { 
       append tabledata "<vot:TD>$p($n)</vot:TD>"
     }
     foreach value $p(sextractor) {
       append tabledata "<vot:TD>$value</vot:TD>"
     }
     append tabledata "</vot:TR>\n"
    }
    lappend xmlparams %TABLEDATA% $tabledata
    set xmlmessage [string map $xmlparams $xmlmajordometemplate]
    unset tabledata
    unset xmlparams

#   puts $xmlmessage

   # -- soumission du fichier XML a l'imcce
   # TODO ne pas envoyer le fichier si aucune identification
   #gren_info "- Soumission du fichier XML a l'imcce"

   set boundary "-----NEXT_PART_[clock seconds].[pid]"
   set formdata {}
   append formdata "--$boundary\nContent-Disposition: form-data; name=\"file\"; filename=\"ssp.xml\"\n"
   append formdata "Content-Type: text/xml\n\n"
   append formdata $xmlmessage
   append formdata "\n"
   append formdata "--$boundary\n"

   set exit_loop 0
   # Si aucune identification alors on n'effectue pas la boucle
   # c'est a dire : pas d'envoi du message xml
   set exit_loop [expr [llength $allidentifications] == 0]
   if { ! $ros(common,ssp,xml_submit) } {
     gren_info "xml submission disabled by configuration"
     set exit_loop 1
   }
   while { ! $exit_loop } {
   set err [catch { http::geturl $ros(common,ssp,xml_submit_url) -type "multipart/form-data, boundary=$boundary" -query $formdata } token]
   if { $err } {
     gren_info "- Submission : socket error"
   } else {
    set status [::http::status $token]
    #gren_info "- http status : $status"
    if { $status eq "ok" } {
     # TODO verification de la valeur de retour
     set httpdata [::http::data $token]
     #gren_info "- http data : $httpdata"
     if { [string match "*PENDING*" $httpdata] } {
     # gren_info "- Result of submission : request pending"
      set err 0
      set exit_loop 1
     } else {
      gren_info "- Submission : error"
#      gren_info [::http::data $token]
      set err 1
     }
    } else {
      gren_info "- Submission : http error $status"
      set err 1
    }
    ::http::cleanup $token
   }
   if {$err} {
    gren_info "- Error during submission of the results"
   }
   if { ! $exit_loop } { after 1000 }
   }

   unset xmlmessage

   }

 }
 
 
 
# -- Mise a jour table bddimages.catas
proc update_table_catas {  } {

 global ssp_image
 global ident_ovni_skybot

   if { $ident_ovni_skybot(err) >= 1 } {
    gren_info "- Erreur : $ident_ovni_skybot(msg)"
   # -- on met a jour le champ catas.ssp_date
   gren_info "- Mise a jour du champ catas.ssp_date : 3000-01-01"
   set sqlcmd "UPDATE catas SET ssp_date='3000-01-01' WHERE idbddcata=$ssp_image(idbddcata)"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      gren_info "solarsystemprocess: ERREUR 8"
      gren_info "solarsystemprocess:        NUM : <$err>" 
      gren_info "solarsystemprocess:        MSG : <$msg>"
      }

   } else {
   # -- on met a jour le champ catas.ssp_date
   #gren_info "- Mise a jour du champ catas.ssp_date"
   set sqlcmd "UPDATE catas SET ssp_date=NOW() WHERE idbddcata=$ssp_image(idbddcata)"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      gren_info "solarsystemprocess: ERREUR 8"
      gren_info "solarsystemprocess:        NUM : <$err>" 
      gren_info "solarsystemprocess:        MSG : <$msg>"
      }

   }

 }
 
