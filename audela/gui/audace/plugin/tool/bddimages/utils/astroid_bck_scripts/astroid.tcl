
# source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/astroid.tcl
#package require Itcl
#namespace import -force itcl::*

##
# @file
#
# @author fv,jb,bc
#
# @brief Traitement des archives dans bddimages

##
# creation de fonctions utiles pour socreq
#
source ../common/macros.tcl
source subroutine_ssp.tcl
source get_one_image.tcl
source get_cata.tcl
source get_skybot.tcl
source identification_ovni_skybot.tcl
source final.tcl
source vo_cds_query.tcl
source calc_magconst.tcl
source calcul_gauss.tcl
source correction_cador_list.tcl


#--- cree les variables globales de socreq
source variables_globales.tcl

lappend auto_path $ros(root,audela) lib

#--- cree l'interface de socreq
source interface_ihm.tcl

#--- mise en place des liaisons (bindings)
source liaisons.tcl

package require xml
package require dom

package require http
package require tls
http::register https 443 ::tls::socket

# Ouverture du modele de document xml a envoyer a podet/majordome
set file [open {template_podet_ssp.xml}]
set xmlmajordometemplate [read $file]
close $file
unset file

# ==========================================================================================

gren_info "$ros(caption,title,1)"
gren_info "$ros(caption,title,2)"
gren_info "$ros(caption,title,3)"

# ==========================================================================================

gren_info "Mode de gestion des disques : $ros(common,mode)\n"

# --- Open MySQL connections and update ros variable with ROS table contents
ros_sql_open_init

# --- initialisations (creation du buffer image, etc...)
gren_create
set logdate0 0.

# --- grande boucle de scandisk. c'est le coeur de socreq.
set ros(common,status_prev) ""
set sortie "no"
set lastfiledate0 0
set lastfiledate $lastfiledate0
set nficreq0 0
set date0 [clock seconds]


# --- redirection des variables
gren_info " dirbase = $ros(common,bddimages,dirbase)"
gren_info " dirfits = $ros(common,bddimages,dirfits)"
gren_info " dircata = $ros(common,bddimages,dircata)"
gren_info " dirinco = $ros(common,bddimages,dirinco)"
gren_info " direrr  = $ros(common,bddimages,direrr)"
gren_info " dirlog  = $ros(common,bddimages,dirlog)"
gren_info " limit   = $ros(common,bddimages,limit)"
gren_info " login   = $ros(common,bddimages,login)"
gren_info " pass    = $ros(common,bddimages,pass)"
gren_info " serv    = $ros(common,bddimages,serv)"
gren_info " repplug = $ros(common,bddimages,rep_plug)"
gren_info "--------------------------------------------------------"
global bddconf

set bddconf(dirbase)  $ros(common,bddimages,dirbase)
set bddconf(dirfits)  $ros(common,bddimages,dirfits)
set bddconf(dircata)  $ros(common,bddimages,dircata)
set bddconf(dirinco)  $ros(common,bddimages,dirinco)
set bddconf(direrr)   $ros(common,bddimages,direrr) 
set bddconf(dirlog)   $ros(common,bddimages,dirlog) 
set bddconf(limit)    $ros(common,bddimages,limit)  
set bddconf(login)    $ros(common,bddimages,login)  
set bddconf(pass)     $ros(common,bddimages,pass)   
set bddconf(serv)     $ros(common,bddimages,serv)   
set bddconf(rep_plug) $ros(common,bddimages,rep_plug)   
set bddconf(bufno)    1
# --
gren_info "Chargement de bddimages_sql.tcl"
source [ file join $ros(common,bddimages,rep_plug) bddimages_sql.tcl ]
set bddimages $ros(common,bddimages,database)
set err [catch {::bddimages_sql::sql query "use $bddimages;"} msg]
if {$err} {
  gren_info "Erreur de connexion à $bddimages <$err> <$msg>\n"        
  } else {
  gren_info "Connecté à $bddimages\n"            
  }

gren_info "ok"




gren_info "Chargement de vo_tools.tcl"
set err [catch {source [ file join $ros(root,audela) gui audace vo_tools.tcl ]} msg]
gren_info "solarsystemprocess:        NUM : <$err>" 
gren_info "solarsystemprocess:        MSG : <$msg>"


# Log     
set log 1

# --

set ros(common,private,wait) 0

while {$sortie=="no"} {

# -- Debut Boucle de travail --------------------------------------------------------------------




test avec idbddimg = 860144
IM_20091214_041139519_230749_59396301.fits.gz

fits/tarot_calern/2009/12/14



 # -- Debut Boucle de travail --------------------------------------------------------------------

    set voconf(taille_champ_calcul) 6744x6744
    set voconf(filter) 0
    set voconf(objfilter) 110

    gren_info "\n"
    gren_info "- Current date [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]"
    if {[ file exists "$bddconf(dirlog)/ssp.quit" ]} {
     gren_info "- Ending main loop by user request $bddconf(dirlog)/ssp.quit"
     break
    }

    # -- Recupere une image

    if { $log == 1 } {
      gren_info "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Appel sql catas "
      }

                       get_one_image

    if { $log == 1 } {
       gren_info "idbddcata  = $ssp_image(idbddcata)"
       gren_info "idbddimage = $ssp_image(idbddimg)"
       gren_info "cata       = $ssp_image(dir_cata_file)/$ssp_image(cata_filename)"
       gren_info "image      = $ssp_image(fits_filename)"
       gren_info "idheader   = $ssp_image(idheader)"
       gren_info "dateobs    = $ssp_image(dateobs)"
       gren_info "ra         = $ssp_image(ra)"
       gren_info "dec        = $ssp_image(dec)"
       gren_info "telescop   = $ssp_image(telescop)"
       gren_info "exposure   = $ssp_image(exposure)"
       gren_info "filter     = $ssp_image(filter)"
       }

   # -- Extraction_sources du fichier cata.txt.gz des sources non identifiees

    if { $log == 1 } {
      gren_info "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Extraction du fichier cata"
      }

                       get_cata



   # calcul_gauss $usno_list2

   # -- Selection des etoiles solaires du catalogue photometrique
   if { 1 == 1 } {
   
     if { $log == 1 } {
      gren_info "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Extraction de TYCHO"
      }
   #$ssp_image(ra) en heure
   set star_list [vo_vizier_query $ssp_image(ra) $ssp_image(dec) 100 arcmin I/239/tyc_main]
   # transformation de star_list

    if { $log == 1 } {
       #gren_info "stellar_list = $stellar_list"
       gren_info "num_star_sources =  [llength $star_list]"
       }
















    set sunlike_list [extract_sun_star $star_list]


    if { $log == 1 } {
       #gren_info "stellar_list = $stellar_list"
       gren_info "num_star_sunlike_sources =  [llength $sunlike_list]"
       }

   

    }


   # -- Star Identification
   if { 1 == 1 } {

      if { $log == 1 } {
        gren_info "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Identification des types Solaires"
        }

                  set staridentification [ identification1 $sunlike_list $usno_list2 50.0 20.0 50.0 ]

     # gren_info "staridentification = $staridentification"


      set accepted [llength $staridentification] 
      set rejected [expr [llength $sunlike_list] - $accepted] 
      gren_info "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: accepted=$accepted rejected=$rejected"
      #gren_info "star_list = $star_list"

      #set sunlike_list [extract_sun_star $staridentification]

      set magconst [calc_magconst $staridentification]
      gren_info "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: magconst=$magconst"
    }



   # -- Correction par la constante des magnitudes

     set ovni_list2 [correction_cador_list $ovni_list2 $magconst]










   # -- Selection des etoiles du catalogue astrometrique
 if { 0 == 1 } {
   
     if { $log == 1 } {
      gren_info "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Extraction de TYCHO"
      }
   
   set star_list [vo_cds_query "UCAC3" $ssp_image(ra) $ssp_image(dec) 10]

    if { $log == 1 } {
       #gren_info "stellar_list = $stellar_list"
       gren_info "num_star_sources =  [llength $star_list]"
       }

  }










   # -- Requete skybot

    if { $log == 1 } {
      gren_info "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Skybot Status"
      }

                       get_skybot

    if { $log == 1 } {
      gren_info "observer UAI code  = $voconf(observer)"
      gren_info "num_skybot_sources = [llength $skybot_list] elements"
      }


   # -- Identification

    if { $log == 1 } {
      gren_info "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Identification"
      }

                     set allidentifications [ identification1 $ovni_list2 $skybot_list2 50.0 20.0 50.0]
   
   set accepted [llength $allidentifications] 
   set rejected [expr [llength $skybot_list] - $accepted] 
   gren_info "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: accepted=$accepted rejected=$rejected idc=$ssp_image(idbddcata) idi=$ssp_image(idbddimg)"










   # -- Stockage des resultats

    # La date courante UTC en format ISO qui apparaitra dans la table ssp_astrometric et dans le fichier XML
    set isodate_now [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]

    if { $log == 1 } { gren_info "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Insertion des donnees sql" }

    insert_data_sql $isodate_now

    if { 0 == 1 } {
    if { $log == 1 } { gren_info "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Envoi a Podet" }

    send_podet $isodate_now 
    } 

   # Mise a jour table bddimages.catas

    if { $log == 1 } { gren_info "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Mise a jour de la table catas" }

    update_table_catas




















    gren_info "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Fin de traitement" 
    if { $log == 1 } { 
       after 1000
       #exit
       }


# -- Fin Boucle de travail --------------------------------------------------------------------

   after 1000 { global ros ; if {$ros(common,private,wait)==0} { set ros(common,private,wait) 1 } else { set ros(common,private,wait) 0 } }
   vwait ros(common,private,wait)
   set ros(common,status) $ros(caption,pas_d_image)

   # --- gestion du fichier log
   archive_log

   # --- affichage eventuel du status s'il n'y pas rien a traiter
   if { ($ros(common,status)==$ros(caption,pas_d_image))&&($ros(common,status)!=$ros(common,status_prev))} {
      # --- aucune image trouvée
      #gren_info "\n$ros(caption,rien_a_traiter) ([gren_date])"
   }
   update

   # --- traite le cas d'une suspension ou de la sortie du programme
   if {$ros(withtk)==1} {
       if {[lindex [.gren.fra2.but1 configure -text] 4]==$caption(cont)} {
         gren_info "$ros(caption,stop) ([gren_date])"
         vwait avance
         gren_info "$ros(caption,cont) ([gren_date])"
       }
   }
   set ros(common,status_prev) $ros(common,status)

}

bell

