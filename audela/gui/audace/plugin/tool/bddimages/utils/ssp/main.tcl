
# source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/ssp/main.tcl

##
# @file
#
# @author fv
#
# @brief Traitement des archives dans bddimages a partir de la base de donnees SSP

source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/get_one_image.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/get_cata.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/imprimlist.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/visu.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/get_astrometric_catalog.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/photometry.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/identification.tcl
source /srv/develop/audela/gui/audace/vo_tools.tcl

::bddimagesXML::load_xml_config
::bddimagesXML::load_config bddimages_cador

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

gren_info "****************************************************************** \n"
# 100000
# 987144 a 23:37  980183 a 00:26


 for {set x 0} {$x<=$nbimg} {incr x} {
       # Recupere une image de la base de donnees
       set r [get_one_image]
       #gren_info "SSP_PLUGIN: result one_ssp   : $r \n"

       if {$r !=0 } {
          #gren_info "SSP_PLUGIN: idbddcata=$ssp_image(idbddcata) poubelle \n"
          #gren_info "x"
          set sqlcmd "UPDATE catas SET ssp_date='3000-01-01' WHERE idbddcata=$ssp_image(idbddcata)"
          set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
          if {$err} {
             gren_info "SSP_PLUGIN: ERREUR  \n"
             gren_info "SSP_PLUGIN:        NUM : <$err> \n" 
             gren_info "SSP_PLUGIN:        MSG : <$msg> \n"
             }
       }  else {
          gren_info "."
          set sqlcmd "UPDATE catas SET ssp_date=now() WHERE idbddcata=$ssp_image(idbddcata)"
          set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
          if {$err} {
             gren_info "SSP_PLUGIN: ERREUR  \n"
             gren_info "SSP_PLUGIN:        NUM : <$err> \n" 
             gren_info "SSP_PLUGIN:        MSG : <$msg> \n"
             }
       }
 }


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
