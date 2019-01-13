
# source /usr/local/src/audela/gui/audace/plugin/tool/bddimages/utils/ssp_ident_eros/main.tcl

##
# @file
#
# @author fv
#
# @brief Traitement des archives dans bddimages a partir de la base de donnees SSP


# {UCAC2 {267.86183250 -30.73224889 -0.00003083 13.860 0.5} {267.86183250 -30.73224889 13.860 -0.00003111 -0.00002778 4 -0.00003083 2 1 0.00666778 0.00647111 -7.40000000 -16.40000000 -8.10000000 -8.10000000 -8.10000000 -5.35000 -5.35000 0 30.000 30.000 30.000 95 95}}



   source [file join $bddconf(astroid) libastroid.tcl]

   set racine "/usr/local/src/audela/gui/audace/plugin/tool/bddimages/utils/ssp_ident_eros"

#   source /usr/local/src/audela/gui/audace/vo_tools.tcl

   ::bddimagesXML::load_xml_config
   ::bddimagesXML::load_config bddimages_cador

   cleanmark
   set tt0 [clock clicks -milliseconds]

   gren_info "\n****************************************************************** \n"

   source [file join $racine eros2tcl.tcl]

   ::manage_source::imprim_3_sources $mylist

   set mylist [::manage_source::set_common_fields $mylist eros { ra dec err_pos mag err_mag }]
   ::manage_source::imprim_3_sources $mylist
   gren_info "rollup = [::manage_source::get_nb_sources_rollup $mylist]\n"

   set ucac2 [csucac2 /astrodata/UCAC2 268.43677537847 -30.267479135417 30]
   gren_info "rollup = [::manage_source::get_nb_sources_rollup $ucac2]\n"
   set ucac2 [::manage_source::set_common_fields $ucac2 UCAC2 { ra_deg dec_deg e_pos_deg U2Rmag_mag 0.5 }]
   ::manage_source::imprim_3_sources $ucac2
   return

   gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Identification\n"
#   set a [buf$bddconf(bufno) xy2radec {680 1801}]
#   set b [buf$bddconf(bufno) xy2radec {713 1826}]
#   set f [list [lindex $a 0] [lindex $a 1] [lindex $b 0] [lindex $b 1] ]
   set f [list 268.152716378 -30.518527135 268.720834378 -30.016431135]
   set log 1
   set mylist [ identification $mylist eros $ucac2 UCAC2  30.0 -30.0 $f $log] 
   gren_info "rollup = [::manage_source::get_nb_sources_rollup $mylist]\n"

   return







   gren_info "\n****************************************************************** \n"
   gren_info "** info de la configuration \n"

   gren_info "SSP_PLUGIN: name    : $bddconf(name)    \n"
   gren_info "SSP_PLUGIN: dbname  : $bddconf(dbname)  \n"
   gren_info "SSP_PLUGIN: login   : $bddconf(login)   \n"
   gren_info "SSP_PLUGIN: pass    : $bddconf(pass)    \n"
   gren_info "SSP_PLUGIN: server  : $bddconf(server)  \n"
   gren_info "SSP_PLUGIN: port    : $bddconf(port)    \n"
   gren_info "SSP_PLUGIN: dirbase : $bddconf(dirbase) \n"
   gren_info "SSP_PLUGIN: dirinco : $bddconf(dirinco) \n"
   gren_info "SSP_PLUGIN: dirfits : $bddconf(dirfits) \n"
   gren_info "SSP_PLUGIN: dircata : $bddconf(dircata) \n"
   gren_info "SSP_PLUGIN: direrr  : $bddconf(direrr)  \n"
   gren_info "SSP_PLUGIN: dirlog  : $bddconf(dirlog)  \n"
   gren_info "SSP_PLUGIN: dirtmp  : $bddconf(dirtmp)  \n"
   gren_info "SSP_PLUGIN: limit   : $bddconf(limit)   \n"

   gren_info "\n****************************************************************** \n"
   gren_info "** info de la visu \n"
   gren_info "****************************************************************** \n"

   #set bddconf(visuno) [::visu::create $bddconf(bufno) 1]
   set bddconf(visuno) 1
   set bddconf(bufno) [::confVisu::getBufNo $bddconf(visuno)]
   gren_info "SSP_PLUGIN: bufNo   : $bddconf(bufno)   \n"
   gren_info "SSP_PLUGIN: visuNo  : $bddconf(visuno)   \n"

   gren_info "\n****************************************************************** \n"
   gren_info "** info de la base \n"
   gren_info "****************************************************************** \n"

   # Selection de la bdd
   set err [catch {::bddimages_sql::sql query "use $bddconf(dbname);"} msg]
   if {$err} {
      gren_info "SSP_PLUGIN: ERREUR 1 \n"
      gren_info "SSP_PLUGIN:        NUM : <$err> \n" 
      gren_info "SSP_PLUGIN:        MSG : <$msg> \n"
      }

   # Nombre d image dans bddimages
   set sqlcmd "select count(*) from images;"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      gren_info "SSP_PLUGIN: ERREUR 2 \n"
      gren_info "SSP_PLUGIN:        NUM : <$err> \n" 
      gren_info "SSP_PLUGIN:        MSG : <$msg> \n"
      }
   gren_info "SSP_PLUGIN: NB IMAGE SUR $bddconf(dbname) =<$resultsql>\n\n"

   set sqlcmd    "select count(*) from catas where ssp_date<now()"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      gren_info "SSP_PLUGIN: ERREUR 2 \n"
      gren_info "SSP_PLUGIN:        NUM : <$err> \n" 
      gren_info "SSP_PLUGIN:        MSG : <$msg> \n"
      }
   gren_info "SSP_PLUGIN: NB IMAGE a traiter SUR $bddconf(dbname) =<$resultsql>\n\n"

   set nbimg $resultsql

   gren_info "\n****************************************************************** \n"
   gren_info "** Chargement d'une image \n"
   gren_info "****************************************************************** \n"


   set r [get_one_image 1071388]
   gren_info "SSP_PLUGIN: result one_ssp   : $r \n"

   gren_info "SSP_PLUGIN:idbddcata  = $ssp_image(idbddcata)\n"
   gren_info "SSP_PLUGIN:idbddimage = $ssp_image(idbddimg)\n"
   gren_info "SSP_PLUGIN:cata       = $ssp_image(dir_cata_file)/$ssp_image(cata_filename)\n"
   gren_info "SSP_PLUGIN:image      = $ssp_image(fits_dir)/$ssp_image(fits_filename)\n"
   gren_info "SSP_PLUGIN:idheader   = $ssp_image(idheader)\n"
   gren_info "SSP_PLUGIN:dateobs    = $ssp_image(dateobs)\n"
   gren_info "SSP_PLUGIN:ra         = $ssp_image(ra)\n"
   gren_info "SSP_PLUGIN:dec        = $ssp_image(dec)\n"
   gren_info "SSP_PLUGIN:telescop   = $ssp_image(telescop)\n"
   gren_info "SSP_PLUGIN:exposure   = $ssp_image(exposure)\n"
   gren_info "SSP_PLUGIN:filter     = $ssp_image(filter)\n"


   gren_info "\n****************************************************************** \n"
   gren_info "** Lecture du CATA \n"
   gren_info "****************************************************************** \n"

   # Recupere les noms des fichiers
   set fitsfile "$bddconf(dirbase)/$ssp_image(fits_dir)/$ssp_image(fits_filename)"
   ::console::affiche_resultat "FILE : $fitsfile\n"
   set catafile "$bddconf(dirbase)/$ssp_image(dir_cata_file)/$ssp_image(cata_filename)"
   ::console::affiche_resultat "CATA : $catafile\n"

   # Recupere le catalogue des sources correspondant a l image
   set listsources [get_cata_txt $catafile]

   # Affichage de l image
   affich_image $fitsfile
   ::console::affiche_resultat "IMAGE AFFICHEE\n"

   # Affichage centre champ de l image
   set centre [list {"CENTRE" {} {} } [list [list [list "CENTRE" [list $ssp_image(ra) $ssp_image(dec)] {}]]]]
   affich_rond $centre "CENTRE" "red" 1

   gren_info "\n****************************************************************** \n"
   gren_info "** Mesures photometriques \n"
   gren_info "****************************************************************** \n"

   set  listsources [::analyse_source::test2 $listsources 1]

   gren_info "rollup = [::manage_source::get_nb_sources_rollup $listsources]\n"

   gren_info "\n****************************************************************** \n"
   gren_info "** SkyBot \n"
   gren_info "****************************************************************** \n"
   
   set datejd  [ mc_date2jd $ssp_image(dateobs) ]
   set datejd  [ expr $datejd + $ssp_image(exposure)/86400.0/2.0 ]
   set dateiso [ mc_date2iso8601 $datejd ]
   gren_info "dateiso = $dateiso \n"
#   set listskybot [ get_skybot $dateiso $ssp_image(ra) $ssp_image(dec) 1000 809 ]
#   gren_info "rollup skybot= [::manage_source::get_nb_sources_rollup $listskybot]\n"

   gren_info "\n****************************************************************** \n"
   gren_info "** Impressions \n"
   gren_info "****************************************************************** \n"

#   ::manage_source::imprim_3_sources $listskybot
   ::manage_source::imprim_3_sources $listsources

   gren_info "\n****************************************************************** \n"
   gren_info "** [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: "
   gren_info " Identification \n"
   gren_info "****************************************************************** \n"

#   gren_info "rollup skybot= [::manage_source::get_nb_sources_rollup $listsources]\n"
#   set listsources [ identification $listsources "OVNI" $listskybot "SKYBOT" 30.0 10.0 10.0] 
   gren_info "rollup skybot= [::manage_source::get_nb_sources_rollup $listsources]\n"

   ::manage_source::imprim_sources $listsources "SKYBOT"
#   affich_rond $listskybot "SKYBOT" "green" 1
   #affich_rond $listsources "OVNI" "blue" 1

   gren_info "\n****************************************************************** \n"
   gren_info "** [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: "
   gren_info " Champs 'common' \n"
   gren_info "****************************************************************** \n"

   #set listsources [::manage_source::set_common_fields $listsources IMG { ra dec 5 calib_mag err_mag }]
   set listsources [::manage_source::set_common_fields $listsources IMG { ra dec 5 calib_mag err_mag }]
   ::manage_source::imprim_3_sources $listsources







   if {1==1} {
      gren_info "\n****************************************************************** \n"
      gren_info "** [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: "
      gren_info " Chargement TYCHO2 \n"
      gren_info "****************************************************************** \n"

      set tycho2 [cstycho2 /astrodata/Catalog/TYCHO-2 $ssp_image(ra) $ssp_image(dec) 70]
      gren_info "rollup = [::manage_source::get_nb_sources_rollup $tycho2]\n"
      set tycho2 [::manage_source::set_common_fields $tycho2 TYCHO2 { RAdeg DEdeg 5 VT e_VT }]
      ::manage_source::imprim_3_sources $tycho2

      gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Identification\n"
      set a [buf$bddconf(bufno) xy2radec {680 1801}]
      set b [buf$bddconf(bufno) xy2radec {713 1826}]
      set f [list [lindex $a 0] [lindex $a 1] [lindex $b 0] [lindex $b 1] ]
      set log 0
      set listsources [ identification $listsources IMG $tycho2 TYCHO2 30.0 -30.0 $f $log] 

      affich_rond $tycho2      TYCHO2 "blue"   2
      affich_rond $listsources TYCHO2 "red"    1
   }


   if {1==0} {
      gren_info "\n****************************************************************** \n"
      gren_info "** [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: "
      gren_info " Chargement UCAC2 \n"
      gren_info "****************************************************************** \n"

      set ucac2 [csucac2 /astrodata/Catalog/UCAC2 $ssp_image(ra) $ssp_image(dec) 70]
      gren_info "rollup = [::manage_source::get_nb_sources_rollup $ucac2]\n"
      set ucac2 [::manage_source::set_common_fields $ucac2 UCAC2 { ra_deg dec_deg e_pos_deg U2Rmag_mag 0.5 }]
      ::manage_source::imprim_3_sources $ucac2

      gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Identification\n"
      set a [buf$bddconf(bufno) xy2radec {680 1801}]
      set b [buf$bddconf(bufno) xy2radec {713 1826}]
      set f [list [lindex $a 0] [lindex $a 1] [lindex $b 0] [lindex $b 1] ]
      set log 0
      set listsources [ identification $listsources IMG $ucac2 UCAC2  30.0 -30.0 $f $log] 

      affich_rond $ucac2       UCAC2 "blue"   2
      affich_rond $listsources UCAC2 "red"    1
   }

   if {1==0} {
      gren_info "\n****************************************************************** \n"
      gren_info "** [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: "
      gren_info " Chargement UCAC3 \n"
      gren_info "****************************************************************** \n"

      set ucac3 [csucac3 /astrodata/Catalog/UCAC3 $ssp_image(ra) $ssp_image(dec) 60]
      gren_info "rollup = [::manage_source::get_nb_sources_rollup $ucac3]\n"
      set ucac3 [::manage_source::set_common_fields $ucac3 UCAC3 { ra_deg dec_deg sigra_deg im2_mag sigmag_mag }]
      ::manage_source::imprim_3_sources $ucac3

      gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Identification\n"
      set a [buf$bddconf(bufno) xy2radec {680 1801}]
      set b [buf$bddconf(bufno) xy2radec {713 1826}]
      set f [list [lindex $a 0] [lindex $a 1] [lindex $b 0] [lindex $b 1] ]
      set log 0
      set listsources [ identification $listsources IMG $ucac3  UCAC3  30.0 -30.0 $f $log] 

      affich_rond $ucac3       UCAC3 "blue"   2
      affich_rond $listsources UCAC3 "red"    1
   }


   #gren_info "\n****************************************************************** \n"
   #gren_info "** [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: "
   #gren_info " Affichage des Etoiles \n"
   #gren_info "****************************************************************** \n"

   #affich_rond $tycho2      TYCHO2 "blue"   2
   #affich_rond $listsources TYCHO2 "red"    1
   #affich_rond $ucac2      UCAC2 "blue"   2
   #affich_rond $listsources UCAC2  "red" 3
   #affich_rond $listsources UCAC3  "blue"   3
   #affich_rond $listsources SKYBOT "green"  3


   #gren_info "\n****************************************************************** \n"
   #gren_info "** [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: "
   #gren_info " Extraction des Etoiles de type Solaire\n"
   #gren_info "****************************************************************** \n"



   # FIN
   gren_info "****************************************************************** \n"
   gren_info "** [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: "
   gren_info "FIN de script\n"
   
   set tt1 [clock clicks -milliseconds]
   set tt [expr ($tt1 - $tt0)/1000.]
   gren_info "Total duration $tt sec \n"

   


