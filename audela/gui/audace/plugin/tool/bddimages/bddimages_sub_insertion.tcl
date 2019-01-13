## @file bddimages_sub_insertion.tcl
#  @brief     Fonctions d&eacute;di&eacute;es &agrave; l'insertion des images dans la base de donn&eacute;es (no namespace)
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bddimages_sub_insertion.tcl]
#  @endcode

# $Id: bddimages_sub_insertion.tcl 14533 2018-11-13 17:00:23Z fredvachier $


#--------------------------------------------------
#  init_info { }
#--------------------------------------------------
#
#    fonction  :
#       Initialisation de la liste des fichiers
#       du repertoire "incoming" dans conf(dirinco)
#       pour l affichage dans la table.
#
#    procedure externe :
#             globrdk
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------
proc init_info { } {

   global bddconf
   global caption
   global maliste

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $bddconf(rep_plug) bddimages_insertion.cap ]\""

   set bddconf(liste) [list "$caption(bddimages_insertion,etat) \
                             $caption(bddimages_insertion,nom) \
                             $caption(bddimages_insertion,dateobs) \
                             $caption(bddimages_insertion,telescope)\
                             $caption(bddimages_insertion,taille) \
                             $caption(bddimages_insertion,erreur)" ]

   set listfile {}
   set maliste {}

   globrdk $bddconf(dirinco) $bddconf(limit)

   set err [catch {set list_file [lsort -increasing $maliste]} result]

   if {$err==0} {
      foreach fichier $list_file {
        set fic [file tail "$fichier"]
        lappend listfile [list "?" "$fichier" "NULL" "NULL" "NULL" "NULL"]
      }
   } else {
      bddimages_sauve_fich "init_info: pas de fichier"
   }

   lappend bddconf(liste) $listfile
   return
}

#--------------------------------------------------
#  init_info_non_recursif { }
#--------------------------------------------------
#
#    fonction  :
#       Initialisation de la liste des fichiers
#       du repertoire "incoming" dans conf(dirinco)
#       pour l affichage dans la table.
#       les fichiers sont extrait de maniere non
#       recursive
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------
proc init_info_non_recursif { } {

   global bddconf
   global caption
   global maliste

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $bddconf(rep_plug) bddimages_insertion.cap ]\""

   set bddconf(liste) [list "$caption(bddimages_insertion,etat) \
                             $caption(bddimages_insertion,nom) \
                             $caption(bddimages_insertion,dateobs) \
                             $caption(bddimages_insertion,telescope)\
                             $caption(bddimages_insertion,taille) \
                             $caption(bddimages_insertion,erreur)" ]

   set listfile {}
   set maliste {}

   globrdknr $bddconf(dirinco) $bddconf(limit)

   set err [catch {set list_file [lsort -increasing $maliste]} result]

   if {$err==0} {
      foreach fichier $list_file {
         set fic [file tail "$fichier"]
         lappend listfile [list "?" "$fichier" "NULL" "NULL" "NULL" "NULL"]
      }
   } else {
      bddimages_sauve_fich "init_info: pas de fichier"
   }

   lappend bddconf(liste) $listfile
   return
}

#--------------------------------------------------
#  info_fichier { nomfich dir }
#--------------------------------------------------
#
#    fonction  :
#       Lecture de la taille du fichier et de la
#       liste des Champs du header.
#       On charge l image en memoire ici
#
#    procedure externe :
#       buf1 : fonction audela de lecture de l'image
#
#       bddimages_entete_preminforecon : reconnaissance
#              des champs necessaires a l'insertion de
#              l'image dans la base
#
#    variables en entree :
#       nomfich = Nom de l image
#       dir     = repertoire de l image
#
#    variables en sortie :
#       list = $erreur $sizefich $list_keys
#
#--------------------------------------------------
proc info_fichier { nomfich } {

   global bddconf

   set erreur    0
   set err       0
   set etat      "X"
   set dateiso   "-"
   set site      "-"
   set sizefich  "Unknown"
   set tabkey    "-"
   set bufno $bddconf(bufno)

#gren_info "nomfich : $nomfich \n"
   # --- Recupere la taille de l'image
   set errnum [catch {set sizefich [file size $nomfich]} msg ]
   if {$errnum != 0} { 
      gren_erreur "Err sizefich : $errnum $msg \n"
      return [list 1 $etat $nomfich $dateiso $site $sizefich $tabkey] 
   }

   # --- Recupere l'extension du fichier
   set result     [bddimages_formatfichier $nomfich]
   set form2      [lindex $result 0]
   set racinefich [lindex $result 1]
   set form3      [lindex $result 2]

#gren_info "form3 : $form3 \n"
   # --- renomme le fichier pour que l'extension soit en minuscule
   if {$form3 == "img"} {
      set errnum [catch {file rename $nomfich "$racinefich.$form2"} msg]
   }
   if {$form3 == "cata"} {
      set errnum [catch {file rename $nomfich "$racinefich\_$form2"} msg]
   }
#gren_info "errnum : $errnum \n"

   # --- verifie si erreur lors du renommage
   if {$errnum != 0} {
      if {[string last "file already exists" $msg] <= 1} {
         bddimages_sauve_fich "info_fichier: ERREUR 9 : Renommage du fichier $nomfich impossible <err:$errnum> <msg:$msg>"
         return [list "9" $etat $nomfich $dateiso $site $sizefich $tabkey]
      }
   } else {
      switch $form3 {
         "img" { set nomfich "$racinefich.$form2" }
         "cata" { set nomfich "$racinefich\_$form2" }
      }
   }

   # --- dezippe le fichier s il est zippé
   if {$form2 == "fit.gz" || $form2 == "fits.gz" || $form2 == "cata.txt.gz" || $form2=="cata.xml.gz" } {
      set fileformat zipped
      set errnum [catch {file mkdir "$bddconf(dirfits)"} msg]
      if {$errnum==1} {
         bddimages_sauve_fich "info_fichier: ERREUR 9b :  <err:$errnum> <msg:$msg>"
      }

      set tmpfile [ file join $bddconf(dirfits) tmpbddimage.fits ]
      set nomfichdata $tmpfile

      lassign [::bdi_tools::gunzip $nomfich $tmpfile] errnum msgzip
      #file delete -force -- $tmpfile
      #if { $::tcl_platform(os) == "Linux" } {
      #   set errnum [catch {exec gunzip -c $nomfich > $tmpfile} msgzip ]
      #} else {
      #   set errnum [catch {file copy "$nomfich" "${tmpfile}.gz" ; gunzip "$tmpfile"} msgzip ]
      #}
      if {$errnum == 0} {
         set nomfichfits [string range $nomfich 0 [expr [string last .gz $nomfich] -1]]
      } else {
         file delete -force -- $tmpfile
         bddimages_sauve_fich "info_fichier: ERREUR 8 : Archive invalide <err:$errnum> <msg:$msgzip>"
         return [list "8" $etat $nomfich $dateiso $site $sizefich $tabkey]
      }
   } else {
      set fileformat unzipped
      set nomfichfits $nomfich
      set nomfichdata $nomfich
   }

   # --- Charge l'image en memoire
   if {$form3 == "img"} {
      set errnum [catch {buf$bufno load $nomfichdata} msg ]
      #gren_info "BGMEAN =[buf$bufno getkwd "BGMEAN"]\n"
      if { $errnum != 0 } {
         bddimages_sauve_fich "info_fichier: ERREUR 3 : Erreur de Chargement de l'image en memoire <err:$errnum> <msg:$msg>"
         return [list "3" $etat $nomfichfits $dateiso $site $sizefich $tabkey]
      }
      # --- verif si TELESCOP exist
      set key [buf$bufno getkwd "TELESCOP"]
      if {[lindex $key 0] == "" } {
         buf$bufno setkwd [list "TELESCOP" "Unknown" string "Telescop name" ""]
      }
      # --- nettoye comment= dans img ohp-120
      if {[string trim [lindex $key 1]] == "OHP-120" && [lindex [buf$bufno getkwd "COMMENT="] 0] != ""} {
         bddimages_sauve_fich "DEL KWD COMMENT du BUF OHP-120 -> $nomfich \n"
         buf$bufno delkwd COMMENT=
         buf$bufno save $nomfich
      }
   }

   # --- zip/rezip le fichier
   if {$fileformat == "unzipped"} {
      set nomfich "$nomfichfits.gz"
      lassign [::bdi_tools::gzip $nomfichdata $nomfich] errnum msg
      #if { $::tcl_platform(os) == "Linux" } {
      #   set errnum [catch {exec gzip -c $nomfichdata > $nomfich} msg ]
      #} else {
      #   set errnum [catch {gzip "$nomfichfits" } msgzip ]
      #}
      if {$errnum != 0} {
         file delete -force -- $nomfich
         bddimages_sauve_fich "info_fichier: ERREUR 2 : Erreur lors de la recompression de l'image $nomfichfits  <err:$errnum> <msg:$msg>"
         return [list "2" $etat $nomfichfits $dateiso $site $sizefich $tabkey]
      }
      file delete -force -- $nomfichdata
   }

   if {[ info exists tmpfile ]} then {
      file delete -force -- $tmpfile
   }

   # --- Recuperation des champs du header FITS
   if {$form3 == "img"} {
      ::bddimagesAdmin::bdi_setcompat $bufno
      set errnum [catch {set list_keys [buf$bufno getkwds]} msg ]
      if {$errnum != 0} {
         bddimages_sauve_fich "info_fichier: ERREUR 4 : Erreur lors de la lecture du header de l'image <err:$errnum> <msg:$msg>"
         return [list 4 $etat $nomfich $dateiso $site $sizefich $tabkey]
      }

      # creation du tabkey
      set tabkey [::bdi_tools_image::get_tabkey_from_buffer]

      # recupere le nom du telescope et la date de l'image
      set site    [lindex [::bddimages_liste::lget $tabkey "telescop"] 1]
      set dateiso [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]
   }

   if {$form3 == "cata"} {
      set tabkey  {}
      set site    {}
      set dateiso {}
   }

   switch $err {
      "0" { set etat  "!" }
      "1" { set erreur 5 }
      "2" { set erreur 6 }
      default { set erreur 7 }
   }

   return [list $erreur $etat $nomfich $dateiso $site $sizefich $tabkey $form3]
}

# ----------------------------------------
# Fonction : bddimages_insertion_unfich
# ----------------------------------------
# Insere une image
# ---------------------------------------
proc bddimages_insertion_unfich { ligne } {

   global bddconf

   uplevel #0 "source \"[ file join $bddconf(rep_plug) bddimages_sub_header.tcl ]\""

   set insert_idbddimg -1
   set msg ""

   set etat      [lindex $ligne 0]
   set nomfich   [lindex $ligne 1]
   set dateobs   [lindex $ligne 2]
   set site      [lindex $ligne 3]
   set sizefich  [lindex $ligne 4]
   set err       [lindex $ligne 5]
   set tabkey    [lindex $ligne 6]

   #gren_info "bddimages_insertion_unfich : etat       = $etat     \n"
   #gren_info "bddimages_insertion_unfich : nomfich    = $nomfich  \n"
   #gren_info "bddimages_insertion_unfich : dateobs    = $dateobs  \n"
   #gren_info "bddimages_insertion_unfich : site       = $site     \n"
   #gren_info "bddimages_insertion_unfich : sizefich   = $sizefich \n"
   #gren_info "bddimages_insertion_unfich : err        = $err      \n"
   #gren_info "bddimages_insertion_unfich : tabkey     = $tabkey   \n"

   # --- Recupere la taille de l'image pour verifier si elle n est pas en cours de transfert
   set errnum [catch {set sizefichcurrent [file size $nomfich]} msg ]
   if {$errnum!=0} {
     bddimages_sauve_fich "bddimages_insertion_unfich: Erreur taille de l image courante <$errnum> <$sizefichcurrent> <$msg>"
     if {$sizefichcurrent!=$sizefich} {
       return [list -1 $nomfich]
     }
   }

   set result      [bddimages_formatfichier $nomfich]
   set form2       [lindex $result 0]
   set racinefich  [lindex $result 1]
   set form3       [lindex $result 2]

   #gren_info "bddimages_insertion_unfich : form2      = $form2\n"
   #gren_info "bddimages_insertion_unfich : racinefich = $racinefich\n"
   #gren_info "bddimages_insertion_unfich : form3      = $form3\n"
   
   if {$form2=="fit"} {
      set racine [string range $nomfich 0 [expr [string length  $nomfich] - 5]]
      set nomfichdest "$racine.fits"
      bddimages_sauve_fich "bddimages_insertion_unfich: Deplacement de $nomfich vers $nomfichdest"
      set errnum [catch {file rename $nomfich $nomfichdest} msg]
      set nomfich $nomfichdest
      bddimages_sauve_fich "bddimages_insertion_unfich: Compression GZIP de $nomfich"
      ::bdi_tools::gzip $nomfich      
      #gzip $nomfich
      set nomfich "$nomfichdest.gz"
      set sizefich [file size $nomfich]
      set form2 "fits.gz"
   }

   if {$form2=="fit.gz"} {
      set racine [string range $nomfich 0 [expr [string length  $nomfich] - 8]]
      set nomfichdest "$racine.fits.gz"
      bddimages_sauve_fich "bddimages_insertion_unfich: Deplacement de $nomfich vers $nomfichdest"
      set errnum [catch {file rename $nomfich $nomfichdest} msg]
      set nomfich $nomfichdest
      set form2 "fits.gz"
   }

   if {$form2=="fits"} {
      bddimages_sauve_fich "bddimages_insertion_unfich: Compression GZIP de $nomfich"
      ::bdi_tools::gzip $nomfich      
      #gzip $nomfich
      set nomfich "$nomfich.gz"
      set sizefich [file size $nomfich]
      set form2 "fits.gz"
   }

   if {$form2=="fits.gz"} {

       set typefich "img"
       # --- Reconnaissance du header FITS dans la base
       set liste    [bddimages_header_id $tabkey]
       set err      [lindex $liste 0]
       set idheader [lindex $liste 1]
       #bddimages_sauve_fich "bddimages_insertion_unfich: type de header <IDHD=$idheader>"

       # --- Insertion des donnees dans la base
       if {$err==0} {
         set result    [bddimages_images_datainsert $tabkey $idheader $nomfich $site $dateobs $sizefich]
         set err       [lindex $result 0]
         set insert_id [lindex $result 1]
         set msg       [lindex $result 2]
       } else {
           set dirpb "$bddconf(direrr)"
           createdir_ifnot_exist $dirpb
           set dirpb "$bddconf(direrr)/$err"
           createdir_ifnot_exist $dirpb
           bddimages_sauve_fich "bddimages_insertion_unfich: Deplacement du fichier $nomfich dans $dirpb"
           set errnum [catch {file rename $nomfich $dirpb/} msg]
           if {$errnum!=0} {
              bddimages_sauve_fich "bddimages_insertion_unfich: ERREUR MV: Deplacement impossible"
              bddimages_sauve_fich "bddimages_insertion_unfich:      NUM : <$errnum>"
              bddimages_sauve_fich "bddimages_insertion_unfich:      MSG : <$msg>"
           }
           return [list $err $nomfich]
       }
   }

   if {$form2=="cata.txt"} {
      bddimages_sauve_fich "bddimages_insertion_unfich: Compression GZIP de $nomfich"
      ::bdi_tools::gzip $nomfich      
      #gzip $nomfich
      set nomfich "$nomfich.gz"
      set sizefich [file size $nomfich]
      set form2 "cata.txt.gz"
      set typefich "cata"
      }

   if {$form2=="cata.txt.gz"} {
      set result    [bddimages_catas_datainsert $nomfich $sizefich $form2]
      set err       [lindex $result 0]
      set insert_id [lindex $result 1]
      set msg       [lindex $result 2]
      set typefich "cata"
      }

   if {$form2=="cata.xml"} {
      bddimages_sauve_fich "bddimages_insertion_unfich: Compression GZIP de $nomfich"
      ::bdi_tools::gzip $nomfich      
      #gzip $nomfich
      set nomfich "$nomfich.gz"
      set sizefich [file size $nomfich]
      set form2 "cata.xml.gz"
      set typefich "cata"
      }

   if {$form2=="cata.xml.gz"} {

      set result    [bddimages_catas_datainsert $nomfich $sizefich $form2]
      set err       [lindex $result 0]
      set insert_id [lindex $result 1]
      set msg       [lindex $result 2]
      set typefich "cata"

      #if {[info exists ::bdi_tools_verif::test_file]} {
      #   if {[file exists $::bdi_tools_verif::test_file]} {
      #      gren_info "bddimages_insertion_unfich :4 EXIST\n"
      #   } else {
      #      gren_info "bddimages_insertion_unfich :4 NOT EXIST \n"
      #   }
      #}
      
   }

   return [list $err $nomfich $insert_id $msg $typefich]
}






# ---------------------------------------
# bddimages_images_datainsert
# Insere nouvelle image dans la BDD
# ---------------------------------------
proc bddimages_images_datainsert { tabkey idheader filename site dateobs sizefich } {

   global bddconf
  
   set bufno $bddconf(bufno)
   set etat 0
   set insert_idbddimg -1

   # Detection de la date et site

   set annee [string range $dateobs 0 3]
   set mois  [string range $dateobs 5 6]
   set jour  [string range $dateobs 8 9]

   set dirfilename "fits/$site/$annee/$mois/$jour"

   # Insere nouvelle image dans la table images
    set fic [file tail "$filename"]
    set sqlcmd "INSERT INTO images (idheader, tabname, filename, dirfilename,sizefich,datemodif) VALUES "
    append sqlcmd "('$idheader', 'images_$idheader', '$fic', '$dirfilename','$sizefich',NOW())"

      # -- Execute la ligne SQL

    set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]

    if {$err} {
    
       bddimages_sauve_fich "bddimages_images_datinsert: ERREUR : <$err> <$msg>"

      if {[string last "images' doesn't exist" $msg]>0} {
         set sqlcmdcrea ""
         append sqlcmdcrea "CREATE TABLE IF NOT EXISTS images ("
         append sqlcmdcrea "  idbddimg bigint(20) NOT NULL auto_increment,"
         append sqlcmdcrea "  idheader int(11) NOT NULL,"
         append sqlcmdcrea "  tabname varchar(20) NOT NULL,"
         append sqlcmdcrea "  filename varchar(128) NOT NULL,"
         append sqlcmdcrea "  dirfilename varchar(128) NOT NULL,"
         append sqlcmdcrea "  sizefich int(20) NOT NULL,"
         append sqlcmdcrea "  datemodif DATETIME NOT NULL,"
         append sqlcmdcrea "  PRIMARY KEY  (idbddimg)"
         append sqlcmdcrea ") ENGINE=MyISAM;"

         set err [catch {::bddimages_sql::sql query $sqlcmdcrea} msg]
         if {$err} {
            bddimages_sauve_fich "bddimages_images_datinsert: ERREUR 101 : Creation table images <err=$err> <msg=$msg> <sql=$sqlcmdcrea>"
            return 101
            } else {
            bddimages_sauve_fich "bddimages_images_datinsert: Creation table images..."
           set resultsql ""
           set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
           if {$err} {
             bddimages_sauve_fich "bddimages_images_datinsert: ERREUR 102 : Impossible d inserer un element dans la table images <err=$err> <msg=$msg>"
             return 102
             } else {

             }
           }
      } else {
            bddimages_sauve_fich "bddimages_images_datinsert: ERREUR 103 : Impossible d acceder aux informations de bddimages.images <err=$err> <msg=$msg>"
            return 103
            }
     }

     set err [catch {::bddimages_sql::sql insertid} insert_idbddimg]
     bddimages_sauve_fich "insert_idbddimg = $insert_idbddimg\n"
    # bddimages_sauve_fich "bddimages_images_datinsert: Insertion nouvel element dans la table images <$insert_idbddimg>"

   # -- Insere nouvelle image dans la table commun
    set datejj  [ mc_date2jd $dateobs ]
    set sqlcmd "INSERT INTO commun (idbddimg, datejj) VALUES "
    append sqlcmd "('$insert_idbddimg', '$datejj')"

      # -- Execute la ligne SQL

    set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
    if {$err} {
       bddimages_sauve_fich "bddimages_images_datinsert: ERREUR : <$err> <$msg>"

      if {[string last "commun' doesn't exist" $msg]>0} {
         set sqlcmdcrea ""
         append sqlcmdcrea "CREATE TABLE IF NOT EXISTS commun ("
         append sqlcmdcrea "  idbddimg bigint(20) NOT NULL,"
         append sqlcmdcrea "  datejj double NOT NULL,"
         append sqlcmdcrea "  exposure double NULL,"
         append sqlcmdcrea "  alphaj2000 double NULL,"
         append sqlcmdcrea "  deltaj2000 double NULL,"
         append sqlcmdcrea "  PRIMARY KEY  (idbddimg)"
         append sqlcmdcrea ") ENGINE=MyISAM;"

         set err [catch {::bddimages_sql::sql query $sqlcmdcrea} msg]
         if {$err} {
            bddimages_sauve_fich "bddimages_images_datinsert: ERREUR 104 : $caption(bddimages_insertion,err104) <err=$err> <msg=$msg> <sql=$sqlcmdcrea>"
            return 101
           } else {
            bddimages_sauve_fich "bddimages_images_datinsert: Creation table commun..."
            set resultsql ""
            set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$err} {
             bddimages_sauve_fich "bddimages_images_datinsert: ERREUR 105 : $caption(bddimages_insertion,err105) <err=$err> <msg=$msg>"
             return 102
             } else {

             }
           }
      } else {
         bddimages_sauve_fich "bddimages_images_datinsert: ERREUR 106 : $caption(bddimages_insertion,err106) <err=$err> <msg=$msg>"
         return 103
         }
     }



  # -- Insere nouvelle image dans la table images_$idheader

    # -- Creation ligne sql

  set sqlcmd  "`idbddimg`,"
  set sqlcmd2 "'$insert_idbddimg',"

  foreach info $tabkey {
    set var [lindex $info 0]
    append sqlcmd "`$var`,"
    set val [lindex $info { 1 1 } ]
    append sqlcmd2 "'$val',"
    }

  set sqlcmd  [string trimright $sqlcmd  ","]
  set sqlcmd2 [string trimright $sqlcmd2 ","]
  set sqlcmd "INSERT INTO images_$idheader ($sqlcmd) VALUES ($sqlcmd2);"

    # -- Execute la ligne SQL

  set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
#  bddimages_sauve_fich "bddimages_images_datinsert: $sqlcmd <$err> <$msg>"
  if {$err} {
    bddimages_sauve_fich "bddimages_images_datinsert: ERREUR XXX : Ne peut inserer une nouvelle image dans la table images_$idheader <$err> <$msg>"

    set sqlcmd "DELETE FROM images WHERE idbddimg = $insert_idbddimg"
    set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
    if {$err} {
      bddimages_sauve_fich "bddimages_images_datinsert: ERREUR 107 : Impossible de supprimer l'image de la table images <idbddimg=$insert_idbddimg> <err=$err> <msg=$msg>"
      return 107
      }
    } else {
#      bddimages_sauve_fich "bddimages_images_datinsert: Enregistrement insere dans la table images_$idheader"
    }


  # -- Deplacement de l image sur le DD

    # -- Verification de l existance des repertoires
    set dirfilename "$bddconf(dirbase)/fits"
    createdir_ifnot_exist $dirfilename

    set dirfilename "$dirfilename/$site"
    createdir_ifnot_exist $dirfilename

    set dirfilename "$dirfilename/$annee"
    createdir_ifnot_exist $dirfilename

    set dirfilename "$dirfilename/$mois"
    createdir_ifnot_exist $dirfilename

    set dirfilename "$dirfilename/$jour"
    createdir_ifnot_exist $dirfilename

    # --
      set errnum [catch {file rename $filename [file join $dirfilename $fic]} msgcp]

      if {$errnum!=0} {

        bddimages_sauve_fich "bddimages_images_datinsert: Le fichier $filename existe dans $dirfilename"

        # -- Le fichier existe dans $dirfilename
        set etat 1

        # -- -> on efface les enregistrements de la base
        set sqlcmd "DELETE FROM images WHERE idbddimg = $insert_idbddimg"
        set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
        if {$err} {
           bddimages_sauve_fich "bddimages_images_datinsert: ERREUR 108 : Impossible de supprimer l image de images <idbddimg=$insert_idbddimg> <err=$err> <msg=$msg>"
           return 108
           }
        bddimages_sauve_fich "bddimages_images_datinsert: Suppression de l'enregistrement dans images"

        # -- -> on efface les enregistrements de la base
        set sqlcmd "DELETE FROM commun WHERE idbddimg = $insert_idbddimg"
        set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
        if {$err} {
           bddimages_sauve_fich "bddimages_images_datinsert: ERREUR 109 : Impossible de supprimer l image de commun <idbddimg=$insert_idbddimg> <err=$err> <msg=$msg>"
           return 109
           }
        bddimages_sauve_fich "bddimages_images_datinsert: Suppression de l enregistrement dans commun"
        set sqlcmd "DELETE FROM images_$idheader WHERE idbddimg = $insert_idbddimg"
        set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
        if {$err} {
           bddimages_sauve_fich "bddimages_images_datinsert: ERREUR 110 : Impossible de supprimer l image de images_$idheader <idbddimg=$insert_idbddimg> <err=$err> <msg=$msg>"
           return 110
           }
        bddimages_sauve_fich "bddimages_images_datinsert: Suppression de l enregistrement dans images_$idheader"

        # -- -> on copie dans $bddconf(direrr)
        set errcp [string first "file already exists" $msgcp]
        if {$errcp>0} {

          set dirpb "$bddconf(direrr)"
          createdir_ifnot_exist $dirpb

          set dirpb "$bddconf(direrr)/filexist"
          set err [catch {set sizefichexist [file size $dirfilename/$fic]} msg ]
          if {!$err} {
            if {$sizefichexist<$sizefich} {
              set dirpb "$bddconf(direrr)/filexistsizebigger"
              bddimages_sauve_fich "bddimages_images_datinsert: Fichier $dirfilename/$fic dans la base ($sizefichexist octets) dans incoming $filename ($sizefich octets)"
              }
            if {$sizefichexist>$sizefich} {
              set dirpb "$bddconf(direrr)/filexistsizelower"
              bddimages_sauve_fich "bddimages_images_datinsert: Fichier $dirfilename/$fic dans la base ($sizefichexist octets) dans incoming $filename ($sizefich octets)"
              }
            }

          createdir_ifnot_exist $dirpb

          bddimages_sauve_fich "bddimages_images_datinsert: Copie du fichier $filename dans $dirpb"
          set errnum [catch {file rename $filename $dirpb/} msg]

          # -- le fichier existe dans $dirpb -> on efface $filename

          set errcp [string first "file already exists" $msg]
          if {$errcp>0||$errnum==0} {
            set errnum [catch {file delete $filename} msg]
            if {$errnum!=0} {
              bddimages_sauve_fich "bddimages_images_datinsert: ERREUR 111 : effacement de $filename impossible <err=$errnum> <msg=$msg>"
              return 111
              } else {
                bddimages_sauve_fich "bddimages_images_datinsert: Fichier $filename supprime"
                }
              # Fin if {$errnum!=0} ... file delete $filename
            }
            # Fin Le fichier existe dans $dirpb
          } else {
              bddimages_sauve_fich "bddimages_images_datinsert: ERREUR 112"
              bddimages_sauve_fich "bddimages_images_datinsert: 	NUM : <$errcp>"
              bddimages_sauve_fich "bddimages_images_datinsert: 	MSG : <$msgcp>"
              bddimages_sauve_fich "bddimages_images_datinsert:    Copie de $filename vers $dirfilename/ impossible"
              bddimages_sauve_fich "bddimages_images_datinsert: 	NUM : <$errnum>"
              bddimages_sauve_fich "bddimages_images_datinsert: 	MSG : <$msg>"
              return 112
            }
            # Fin if {$errcp>0} ... string first "file already exists"

        }  else {
           set newfile [file join $dirfilename $fic]
           set newsize [file size $newfile]
           set sqlcmd "UPDATE images SET sizefich=$newsize WHERE idbddimg=$insert_idbddimg;"
           set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
           if {$err} {
             bddimages_sauve_fich "bddimages_images_datinsert: ERREUR 113 : Impossible de mettre a jour la taille du fichier dans la table images <idbddimg=$insert_idbddimg> <err=$err> <msg=$msg>"
             return 113
           }
        }
        # Fin if {$errnum!=0} ... else ... file copy $filename $dirfilename/


      # ca marche 
#      set filename [file join $dirfilename $fic]
      # load l image copiee
#      set errnum [catch {buf$bufno load $filename} msg ]
#      if { $errnum != 0 } {
#         bddimages_sauve_fich "info_fichier: ERREUR 3 : Erreur de Chargement de l'image en memoire <err:$errnum> <msg:$msg>"
#         return [list "3" $etat $nomfichfits $dateiso $site $sizefich $tabkey]
#      }

      # on trafique le header en fonction du tabkey
#      ::bdi_tools_image::set_tabkey_in_buffer $bufno $tabkey

      # on sauve l image.
#      set errnum [catch {buf$bufno save $filename} msg ]
#      if { $errnum != 0 } {
#         bddimages_sauve_fich "info_fichier: ERREUR 3 : Erreur de Chargement de l'image en memoire <err:$errnum> <msg:$msg>"
#         return [list "3" $etat $nomfichfits $dateiso $site $sizefich $tabkey]
#      }

   return [list $etat $insert_idbddimg ""]
}



proc bddimages_delete_cata_ifexist { filename form } {

  global bddconf

  set etat 0

  # Detection de l'image coorespondante
  set fic [file tail "$filename"]
  set racinefich [string range $fic 0 [expr [string first $form $fic ] -2]]

  # -- ligne SQL
  set sqlcmd "SELECT idbddimg,dirfilename FROM images WHERE filename='$racinefich.fits.gz'"

  # -- Execute la ligne SQL
  set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
  if {$err} {
     bddimages_sauve_fich "bddimages_delete_catatxt_ifexist: ERREUR 300"
     bddimages_sauve_fich "bddimages_delete_catatxt_ifexist:        NUM : <$err>"
     bddimages_sauve_fich "bddimages_delete_catatxt_ifexist:        MSG : <$msg>"
     return 300
  }

  set idbddimg -1
  set cpt 0
  foreach line $resultsql {
     incr cpt
     set idbddimg [lindex $line 0]
     set dirfilename [lindex $line 1]
  }
  
  if {$cpt!=1} {
     bddimages_sauve_fich "bddimages_delete_catatxt_ifexist: ERREUR 301 il existe plusieurs nom de fichier image du meme nom : '$racinefich.fits.gz'" 
     return 301
  }

  # -- Cas ou l image n est pas encore inseree dans la base
  if {$idbddimg == -1} {
     bddimages_sauve_fich "bddimages_delete_catatxt_ifexist: ERREUR 302 l'image '$racinefich.fits.gz' est absente de la base" 
     return 302
  }

  set racinecata  [file tail $bddconf(dircata)]
  set racinecatafilename $racinecata/[string range $dirfilename 5 999]
  set dirfilename $bddconf(dircata)/[string range $dirfilename 5 999]

  set r  [file tail $filename]
  set f [file join $bddconf(dirbase) $racinecatafilename $r]

  if {[file exists $f]} {
     bddimages_sauve_fich "fichier existe $f ?\n"
     set err [catch {file delete $f} msg]
     bddimages_sauve_fich "Effacement de $f\n"
  }
  
  set sqlcmd "SELECT idbddcata FROM cataimage WHERE idbddimg=$idbddimg"
  set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
  if {$err} {
     bddimages_sauve_fich "bddimages_delete_catatxt_ifexist: ERREUR 303"
     bddimages_sauve_fich "bddimages_delete_catatxt_ifexist:        NUM : <$err>"
     bddimages_sauve_fich "bddimages_delete_catatxt_ifexist:        MSG : <$msg>"
     return 303
  }
  
  set idbddcata -1
  foreach line $resultsql {
     set idbddcata [lindex $line 0]
  }

  # -- Cas ou le cata n est pas encore inseree dans la base
  if {$idbddcata == -1} {
     return 304
  }
  
  set sqlcmd "DELETE FROM catas WHERE idbddcata=$idbddcata"
  set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
  if {$err} {
     bddimages_sauve_fich "bddimages_delete_catatxt_ifexist: ERREUR 305"
     bddimages_sauve_fich "bddimages_delete_catatxt_ifexist:        NUM : <$err>"
     bddimages_sauve_fich "bddimages_delete_catatxt_ifexist:        MSG : <$msg>"
     return 305
  }
  
  set sqlcmd "DELETE FROM cataimage WHERE idbddcata=$idbddcata"
  set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
  if {$err} {
     bddimages_sauve_fich "bddimages_delete_catatxt_ifexist: ERREUR 306"
     bddimages_sauve_fich "bddimages_delete_catatxt_ifexist:        NUM : <$err>"
     bddimages_sauve_fich "bddimages_delete_catatxt_ifexist:        MSG : <$msg>"
     return 306
  }

  return 0

}



# ---------------------------------------
# bddimages_catas_datainsert
# Insere nouveau cata dans la BDD
# ---------------------------------------
proc bddimages_catas_datainsert { filename sizefich form } {

  global bddconf

  set etat 0

  # gren_info "bddimages_catas_datainsert : filename = $filename\n"
  # gren_info "bddimages_catas_datainsert : sizefich = $sizefich\n"
  # gren_info "bddimages_catas_datainsert : form     = $form    \n"

  # Detection de l'image coorespondante
  set fic [file tail "$filename"]
  set racinefich [string range $fic 0 [expr [string first $form $fic ] -2]]

  # -- ligne SQL
  set sqlcmd "SELECT idbddimg,dirfilename FROM images WHERE filename='$racinefich.fits.gz' LIMIT 1"

  # -- Execute la ligne SQL
  set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
  if {$err} {
     bddimages_sauve_fich "bddimages_catas_datainsert: ERREUR 301"
     bddimages_sauve_fich "bddimages_catas_datainsert:        NUM : <$err>"
     bddimages_sauve_fich "bddimages_catas_datainsert:        MSG : <$msg>"
     return 301
  }

  set idbddimg -1
  foreach line $resultsql {
     set idbddimg [lindex $line 0]
     set dirfilename [lindex $line 1]
  }
  # gren_info "bddimages_catas_datainsert : idbddimg     = $idbddimg    \n"
  # gren_info "bddimages_catas_datainsert : dirfilename  = $dirfilename    \n"

  # -- Cas ou l image n est pas encore inseree dans la base
  if {$idbddimg == -1} {
     set dirfilename "$bddconf(dirbase)/unlinked"
     createdir_ifnot_exist $dirfilename
     set errnum [catch {file rename $filename $dirfilename/} msg]
     # -- le fichier existe dans $dirpb -> on efface $filename
     set errcp [string first "file already exists" $msg]
     if {$errcp>0||$errnum==0} {
        set errnum [catch {file delete $filename} msg]
        if {$errnum!=0} {
           bddimages_sauve_fich "bddimages_catas_datainsert: ERREUR 302 : effacement de $filename impossible <err=$errnum> <msg=$msg>"
           return 302
        } else {
           bddimages_sauve_fich "bddimages_catas_datainsert: Fichier $filename supprime"
        }
        # Fin if {$errnum!=0} ... file delete $filename
     }
     return 300
  }

  set racinecata  [file tail $bddconf(dircata)]
  set racinecatafilename $racinecata/[string range $dirfilename 5 999]
  set dirfilename $bddconf(dircata)/[string range $dirfilename 5 999]

  # -- Insertion dans la table catas

  # -- ligne SQL
  set sqlcmd "INSERT INTO catas (idbddcata,  filename, dirfilename, sizefich, datemodif) VALUES "
  append sqlcmd "(NULL, '$fic', '$racinecatafilename','$sizefich',NOW())"

  set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
  if {$err} {
    
      if {[string last "catas' doesn't exist" $msg]>0} {
          set sqlcmdcrea ""
          append sqlcmdcrea "CREATE TABLE catas (                                      "
          append sqlcmdcrea "  idbddcata bigint(20) unsigned NOT NULL auto_increment,  "
          append sqlcmdcrea "  filename varchar(128) NOT NULL,                         "
          append sqlcmdcrea "  dirfilename varchar(128) NOT NULL,                      "
          append sqlcmdcrea "  sizefich int(20) unsigned NOT NULL,                     "
          append sqlcmdcrea "  datemodif datetime NOT NULL,                            "
          append sqlcmdcrea "  istreated tinyint(3) unsigned default 0,                "
          append sqlcmdcrea "  ssp_date datetime default '0010-00-00 00:00:00',        "
          append sqlcmdcrea "  PRIMARY KEY  (idbddcata),                               "
          append sqlcmdcrea "  KEY istreated (istreated),                              "
          append sqlcmdcrea "  KEY ssp_date (ssp_date)                                 "
          append sqlcmdcrea ") ENGINE=MyISAM DEFAULT CHARSET=latin1;                   "
          set err [catch {::bddimages_sql::sql query $sqlcmdcrea} msg]
          if {$err} {
             bddimages_sauve_fich "bddimages_catas_datainsert: ERREUR 303 : Creation table catas <err=$err> <msg=$msg> <sql=$sqlcmdcrea>"
             return 303
             } else {
             bddimages_sauve_fich "bddimages_catas_datainsert: Creation table catas..."
            set resultsql ""
            set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$err} {
              bddimages_sauve_fich "bddimages_catas_datainsert: ERREUR 304 : Impossible d inserer un element dans la table catas <err=$err> <msg=$msg>"
              return 304
            } else {
            }
          }
        } else {
           bddimages_sauve_fich "bddimages_catas_datainsert: ERREUR 305 : Impossible d acceder aux informations de bddimages.catas <err=$err> <msg=$msg>"
           return 305
        }
    }

    # Recupere la valeur de l'autoincrement
    set err [catch {::bddimages_sql::sql insertid} idbddcata]
    #gren_info "idbddcata insertid : $idbddcata\n"

    # bddimages_sauve_fich "idbddcata = $idbddcata\n"

  # -- Insertion dans la table cataimage

  # -- ligne SQL
  set sqlcmd "INSERT INTO cataimage (idbddcata,  idbddimg) VALUES ('$idbddcata', '$idbddimg')"

  set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
  if {$err} {
      if {[string last "cataimage' doesn't exist" $msg]>0} {
         set sqlcmdcrea ""
         append sqlcmdcrea "CREATE TABLE cataimage (                  "
         append sqlcmdcrea "  idbddcata bigint(20) unsigned NOT NULL, "
         append sqlcmdcrea "  idbddimg bigint(20) unsigned NOT NULL,  "
         append sqlcmdcrea "  KEY idbddcata (idbddcata),              "
         append sqlcmdcrea "  KEY idbddimg (idbddimg)                 "
         append sqlcmdcrea ") ENGINE=MyISAM DEFAULT CHARSET=latin1;   "

         set err [catch {::bddimages_sql::sql query $sqlcmdcrea} msg]
         if {$err} {
            bddimages_sauve_fich "bddimages_catas_datainsert: ERREUR 306 : Creation table cataimage <err=$err> <msg=$msg> <sql=$sqlcmdcrea>"
            return 306
         } else {
            bddimages_sauve_fich "bddimages_catas_datainsert: Creation table cataimage..."
            set resultsql ""
            set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$err} {
              bddimages_sauve_fich "bddimages_catas_datainsert: ERREUR 307 : Impossible d inserer un element dans la table cataimage <err=$err> <msg=$msg>"
              return 307
            } else {

            }
         }
      } else {
         bddimages_sauve_fich "bddimages_catas_datainsert: ERREUR 308 : Impossible d acceder aux informations de bddimages.cataimage <err=$err> <msg=$msg>"
         return 308
      }
    }

  # Deplacement du fichier dans le repertoire cata

  createdir_ifnot_exist $dirfilename
  
  #if {[file exists $filename]} {
  #   gren_info "bddimages_catas_datainsert :1 EXIST \n"
  #} else {
  #   gren_info "bddimages_catas_datainsert :1 NOT EXIST   \n"
  #}
  
  set errnum [catch {file rename -force -- $filename $dirfilename} msgcp]

  #if {[file exists [file join $dirfilename $fic]]} {
  #   gren_info "bddimages_catas_datainsert :2 EXIST \n"
  #} else {
  #   gren_info "bddimages_catas_datainsert :2 NOT EXIST \n"
  #}

  bddimages_sauve_fich "Deplacement de $filename vers $dirfilename\n"

  # gren_info "bddimages_catas_datainsert : Deplacement de $filename vers $dirfilename/$fic   \n"
  # gren_info "bddimages_catas_datainsert : <err=$errnum> <msg=$msgcp>  \n"

  if {$errnum!=0} {

     bddimages_sauve_fich "deplacement erreur : $errnum - $msgcp\n"
     bddimages_sauve_fich "bddimages_catas_datainsert: Le fichier $filename existe dans $dirfilename"

     # -- Le fichier existe dans $dirfilename
     set etat 320

     # -- -> on efface les enregistrements de la table cata
     set sqlcmd "DELETE FROM catas WHERE idbddcata = $idbddcata"
     set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
     if {$err} {
        bddimages_sauve_fich "bddimages_catas_datainsert: ERREUR 309 : Impossible de supprimer le fichier cata de la table catas <idbddcata=$idbddcata> <err=$err> <msg=$msg>"
        return 309
     }
     bddimages_sauve_fich "bddimages_catas_datainsert: Suppression de l'enregistrement dans images"

     # -- -> on efface les enregistrements de la table cataimage
     set sqlcmd "DELETE FROM cataimage WHERE idbddcata = $idbddcata"
     set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
     if {$err} {
        bddimages_sauve_fich "bddimages_catas_datainsert: ERREUR 310 : Impossible de supprimer le fichier cata de la table cataimage <idbddcata=$idbddcata> <err=$err> <msg=$msg>"
        return 310
     }
     bddimages_sauve_fich "bddimages_catas_datainsert: Suppression de l'enregistrement dans images"

     # -- -> on copie dans $bddconf(direrr)
     set errcp [string first "file already exists" $msgcp]
     if {$errcp>0} {

        set dirpb "$bddconf(direrr)"
        createdir_ifnot_exist $dirpb

        set dirpb "$bddconf(direrr)/filexist"
        set err [catch {set sizefichexist [file size $dirfilename/$fic]} msg ]
        if {!$err} {
          if {$sizefichexist<$sizefich} {
            set dirpb "$bddconf(direrr)/filexistsizebigger"
            bddimages_sauve_fich "bddimages_catas_datainsert: Fichier $dirfilename/$fic dans la base ($sizefichexist octets) dans incoming $filename ($sizefich octets)"
          }
          if {$sizefichexist>$sizefich} {
            set dirpb "$bddconf(direrr)/filexistsizelower"
            bddimages_sauve_fich "bddimages_catas_datainsert: Fichier $dirfilename/$fic dans la base ($sizefichexist octets) dans incoming $filename ($sizefich octets)"
          }
        }

        createdir_ifnot_exist $dirpb

        bddimages_sauve_fich "bddimages_catas_datainsert: Copie du fichier $filename dans $dirpb"
        set errnum [catch {file rename $filename $dirpb/} msg]

        # -- le fichier existe dans $dirpb -> on efface $filename
        set errcp [string first "file already exists" $msg]
        if {$errcp>0||$errnum==0} {
          set errnum [catch {file delete $filename} msg]
          if {$errnum!=0} {
            bddimages_sauve_fich "bddimages_catas_datainsert: ERREUR 311 : effacement de $filename impossible <err=$errnum> <msg=$msg>"
            return 311
          } else {
            bddimages_sauve_fich "bddimages_catas_datainsert: Fichier $filename supprime"
          }
          # Fin if {$errnum!=0} ... file delete $filename
        }
     } else {
        bddimages_sauve_fich "bddimages_catas_datainsert: ERREUR 312"
        bddimages_sauve_fich "bddimages_catas_datainsert: 	NUM : <$errcp>"
        bddimages_sauve_fich "bddimages_catas_datainsert: 	MSG : <$msgcp>"
        bddimages_sauve_fich "bddimages_catas_datainsert:    Copie de $filename vers $dirfilename/ impossible"
        bddimages_sauve_fich "bddimages_catas_datainsert: 	NUM : <$errnum>"
        bddimages_sauve_fich "bddimages_catas_datainsert: 	MSG : <$msg>"
        return 312
     }

  } else {
  
        set newfile [file join $dirfilename $fic]
        set newsize [file size $newfile]
        set sqlcmd "UPDATE catas SET sizefich=$newsize WHERE idbddcata=$idbddcata;"
        set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
        if {$err} {
           bddimages_sauve_fich "bddimages_images_datinsert: ERREUR 313 : Impossible de mettre a jour la taille du fichier dans la table catas <idbddcata=$idbddcata> <err=$err> <msg=$msg>"
           return [list 313 $idbddcata "Impossible de mettre a jour la taille du fichier dans la table catas"]
        }
        #if {[file exists $newfile]} {
        #   gren_info "bddimages_catas_datainsert :3 EXIST $newfile\n"
        #   set ::bdi_tools_verif::test_file $newfile
        #} else {
        #   gren_info "bddimages_catas_datainsert :3 NOT EXIST \n"
        #}
  }

   return [list $etat $idbddcata ""]
}

#--------------------------------------------------
#  move_unlinked { }
#--------------------------------------------------
#
#    fonction  :
#       deplace le repertoire unlinked dans le repertoire incoming
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------
proc move_unlinked { } {

    global bddconf

    if {[file exists $bddconf(dirbase)/unlinked]==1} {
       set errnum [catch {file rename -force $bddconf(dirbase)/unlinked $bddconf(dirinco)/} msg]
       # -- le fichier existe dans $dirpb -> on efface $filename
       if {$errnum!=0} {
          bddimages_sauve_fich "move_unlinked: ERREUR : deplacement du repertoire unlinked impossible <err=$errnum> <msg=$msg>"
          return 320
       } else {
          bddimages_sauve_fich "move_unlinked: le repertoire unlinked est deplace"
       }
    } else {
       bddimages_sauve_fich "move_unlinked: le repertoire unlinked n existe pas"
    }
    return

}

#--------------------------------------------------
#  move_unlinked_non_recursif { }
#--------------------------------------------------
#
#    fonction  :
#       deplace les donnees du repertoire unlinked
#       dans le repertoire incoming
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------
proc move_unlinked_non_recursif { } {

   global bddconf
   set errnum [catch {set files [lsort [glob [file join $bddconf(dirbase) unlinked {*.*}]]]} msg]
   if {$errnum!=0} {
   } else {
      foreach cata $files {
         #bddimages_sauve_fich "rename '$cata' to '$bddconf(dirinco)/.'"
         file rename -force -- $cata $bddconf(dirinco)/.   ;# ! overwrites existing files !
      }
   }
    return

}



#--------------------------------------------------
#  ::bddimagesAdmin::bddimages_image_identification { idbddimg }
#--------------------------------------------------
# verifie la compatibilite de l image
# @return 1 si compatible 0 sinon
#--------------------------------------------------
proc bddimages_image_identification { idbddimg } {

   global bddconf

   set sqlcmd "SELECT dirfilename,filename,idheader
               FROM images
               WHERE images.idbddimg=$idbddimg 
               LIMIT 1"

   # -- Execute la ligne SQL
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      bddimages_sauve_fich "bddimages_image_delete: ERREUR 401"
      bddimages_sauve_fich "bddimages_image_delete: NUM : <$err>"
      bddimages_sauve_fich "bddimages_image_delete: MSG : <$msg>"
      return 401
   }

   set idheader -1
   set fileimg -1
   foreach line $resultsql {
      set dirfilename [lindex $line 0]
      set filename [lindex $line 1]
      set idheader [lindex $line 2]
      set fileimg [ file join $bddconf(dirbase) $dirfilename $filename]
   }

   set idbddcata -1
   set filecata -1

   set sqlcmd "SELECT catas.dirfilename,catas.filename,catas.idbddcata
               FROM images, catas,cataimage 
               WHERE images.idbddimg=$idbddimg 
               AND cataimage.idbddimg = $idbddimg 
               AND catas.idbddcata = cataimage.idbddcata
               LIMIT 1"

   # -- Execute la ligne SQL
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      bddimages_sauve_fich "WARNING: table cata inexistante"

      } else {
      foreach line $resultsql {
         set dirfilename [lindex $line 0]
         set filename [lindex $line 1]
         set idbddcata [lindex $line 2]
         set filecata [ file join $bddconf(dirbase) $dirfilename $filename]
      }
   }

   return [list $idbddimg $fileimg $idbddcata $filecata $idheader]
}





#--------------------------------------------------
#  ::bddimagesAdmin::bddimages_image_delete_fromsql { ident }
#--------------------------------------------------
# verifie la compatibilite de l image
# @return 1 si compatible 0 sinon
#--------------------------------------------------
proc bddimages_image_delete_fromsql { ident } {

   set idbddimg  [lindex $ident 0]
   set idbddcata [lindex $ident 2]
   set idheader  [lindex $ident 4]

   if {$idbddcata != -1 } {
      # Effacement dans la table cata
      set sqlcmd "DELETE FROM catas WHERE idbddcata = $idbddcata"
      set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
      if {$err} {
        bddimages_sauve_fich "bddimages_image_delete: ERREUR 407 : Impossible de supprimer l'image de la table images <idbddimg=$insert_idbddimg> <err=$err> <msg=$msg>"
        return 407
      }
      # Effacement dans la table cataimage
      set sqlcmd "DELETE FROM cataimage WHERE idbddcata = $idbddcata"
      set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
      if {$err} {
        bddimages_sauve_fich "bddimages_image_delete: ERREUR 407 : Impossible de supprimer l'image de la table images <idbddimg=$insert_idbddimg> <err=$err> <msg=$msg>"
        return 407
      }
   }

   if {$idheader != -1 } {
      # Effacement dans la table images
      set sqlcmd "DELETE FROM images_$idheader WHERE idbddimg = $idbddimg"
      set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
      if {$err} {
        bddimages_sauve_fich "bddimages_image_delete: ERREUR 407 : Impossible de supprimer l'image de la table images <idbddimg=$insert_idbddimg> <err=$err> <msg=$msg>"
        return 407
      }
      # Effacement dans la table images
      set sqlcmd "DELETE FROM images WHERE idbddimg = $idbddimg"
      set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
      if {$err} {
        bddimages_sauve_fich "bddimages_image_delete: ERREUR 407 : Impossible de supprimer l'image de la table images <idbddimg=$insert_idbddimg> <err=$err> <msg=$msg>"
        return 407
      }
   }
   return

}

proc bddimages_image_delete_fromdisk { ident } {

   set idbddimg  [lindex $ident 0]
   set fileimg   [lindex $ident 1]
   set idbddcata [lindex $ident 2]
   set filecata  [lindex $ident 3]
   set idheader  [lindex $ident 4]
   
   if {$idbddcata != -1 } {
      set err [catch {file delete -force -- $filecata} msg]
      if {$err} {
         gren_erreur "Impossible de supprimer le fichier cata du disque :"
         gren_erreur "<idbddimg=$idbddimg>"
         gren_erreur "<idbddcata=$idbddcata>"
         gren_erreur "<filecata=$filecata>"
         gren_erreur "<err=$err>"
         gren_erreur "<msg=$msg>"
         bddimages_sauve_fich "Impossible de supprimer le fichier cata du disque : <idbddimg=$idbddimg> <idbddcata=$idbddcata> <filecata=$filecata> <err=$err> <msg=$msg>"
         return
      }
   }
   if {$idheader != -1 } {
      set err [catch {file delete -force -- $fileimg} msg]
      if {$err} {
         gren_erreur "Impossible de supprimer le fichier image du disque :"
         gren_erreur "<idbddimg=$idbddimg>"
         gren_erreur "<fileimg=$fileimg>"
         gren_erreur "<err=$err>"
         gren_erreur "<msg=$msg>"
         bddimages_sauve_fich "Impossible de supprimer le fichier image du disque : <idbddimg=$idbddimg> <fileimg=$fileimg> <err=$err> <msg=$msg>"
         return
      }
   }

   return
}


#--------------------------------------------------
#  bddimages_images_delete { }
#--------------------------------------------------
#
#    fonction  :
#       Supprime l image de la base et du repertoire
#       Supprime le cata s il existe
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------
proc bddimages_image_delete { idbddimg } {

   set ident [bddimages_image_identification $idbddimg]
   bddimages_image_delete_fromsql $ident
   bddimages_image_delete_fromdisk $ident
   return

}

