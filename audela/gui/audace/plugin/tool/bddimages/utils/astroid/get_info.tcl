proc get_info {  } {

   global bddconf

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





}
