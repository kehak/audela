#
## @file aud.tcl
#  @brief Fichier principal de l'application Aud'ACE
#  @author Denis MARCHAIS
#  $Id: aud.tcl 14521 2018-10-24 14:29:29Z rzachantke $
#  @todo traiter pour Doxygen
#

#--- Chargement du package BWidget
package require BWidget

#--- Chargement de script d'utilitaires
source menu.tcl

#--- Fichiers de audace
source aud_menu_1.tcl
source aud_menu_2.tcl
source aud_menu_3.tcl
source aud_menu_5.tcl
source aud_menu_7.tcl
source aud_menu_8.tcl
source aud_proc.tcl
source console.tcl
source confgene.tcl
source surchaud.tcl
source planetography.tcl
source ftp.tcl
source bifsconv.tcl
source compute_stellaire.tcl
source divers.tcl
source iris.tcl
source poly.tcl
source filtrage.tcl
source mauclaire.tcl
source help.tcl
source vo_tools.tcl
source sectiongraph.tcl
source polydraw.tcl
source ros.tcl
source socket_tools.tcl
source gcn_tools.tcl
source celestial_mechanics.tcl
source diaghr.tcl
source satel.tcl
source miscellaneous.tcl
source photompsf.tcl
source prtr.tcl
source photcal.tcl
source etc_tools.tcl
source meteosensor_tools.tcl
source photrel.tcl
source fly.tcl
source grb_tools.tcl
source speckle_tools.tcl
source focas.tcl
source alpy600_tools.tcl
source wcs_tools.tcl
source memory_tools.tcl
source catalog_tools.tcl
source joystick_tools.tcl

namespace eval ::audace {

   proc run { { this ".audace" } } {
      variable This
      global audace

      set This $this
      set audace(base) $This

      initEnv
      set visuNo [ createDialog ]
      ::confVisu::createMenu $visuNo
      initLastEnv $visuNo

      dispClock1
      ::confChoixOutil::afficheOutilF2

      if { [info exists ::audela(updateMessage) ] == 1 } {
         #--- j'affiche le compte rendu de mise a jour s'il existe
         tk_messageBox -icon info  -message $::audela(updateMessage) -title $::caption(audace,titre) -type ok
      }

   }

   proc initEnv { } {
      global audace caption conf confgene

      #--- Utilisation de la Console
      set audace(Console) ".console"

      #--- Initialisation de la variable de fermeture
      set audace(quitterEnCours) "0"

      #--- Initialisation de variables pour la fenetre Editeurs...
      set confgene(EditScript,error_script) "1"
      set confgene(EditScript,error_pdf)    "1"
      set confgene(EditScript,error_htm)    "1"
      set confgene(EditScript,error_viewer) "1"
      set confgene(EditScript,error_java)   "1"
      set confgene(EditScript,error_aladin) "1"
      set confgene(EditScript,error_iris)   "1"

      #--- Je recupere l'annee en cours pour la borne haute du Copyright
      set audace(endCopyright) [ clock format [ clock seconds ] -format "%Y" ]

      #--- On retourne dans le repertoire gui
      cd ..
      set audace(rep_gui) [pwd]

      #--- Repertoire des captions
      set audace(rep_caption) [ file join $audace(rep_gui) audace caption ]

      #--- Chargement des legendes et textes pour differentes langues
      source [ file join $audace(rep_caption) caption.cap ]
      source [ file join $audace(rep_caption) aud_menu_1.cap ]
      source [ file join $audace(rep_caption) aud_menu_2.cap ]
      source [ file join $audace(rep_caption) aud_menu_3.cap ]
      source [ file join $audace(rep_caption) aud_menu_5.cap ]
      source [ file join $audace(rep_caption) aud_menu_6.cap ]
      source [ file join $audace(rep_caption) aud_menu_7.cap ]
      source [ file join $audace(rep_caption) aud_menu_8.cap ]
      source [ file join $audace(rep_caption) confgene.cap ]
      source [ file join $audace(rep_caption) confgene_en-tete.cap ]
      source [ file join $audace(rep_caption) confgene_touche.cap ]
      source [ file join $audace(rep_caption) bifsconv.cap ]
      source [ file join $audace(rep_caption) compute_stellaire.cap ]
      source [ file join $audace(rep_caption) divers.cap ]
      source [ file join $audace(rep_caption) iris.cap ]
      source [ file join $audace(rep_caption) filtrage.cap ]
      source [ file join $audace(rep_caption) poly.cap ]
      source [ file join $audace(rep_caption) prtr.cap ]

      #--- Creation de la console
      ::console::create

      #--- Chargement du package Thread
      set catchError [ catch {
         package require Thread
         #--- Je redirige les eventuels messages d'erreur qui peuvent se produire
         #--- dans les threads secondaires vers la Console geree par le thread principal
         thread::errorproc {::console::disp "thread_id=$thread_id errorInfo=$::errorInfo\n"}
      } ]
      if { $catchError != 0 } {
         ::console::affiche_erreur "Thread Loading Error: $::errorInfo\n"
      }

      #--- Chargement de la configuration
      loadSetup

      #--- Répertoire Mes Documents (utile dans certains plugins)
      if { $::tcl_platform(os) == "Linux" } {
         set mesDocuments [ file join $::env(HOME) audela ]
      } else {
         set mesDocuments [ ::registry get "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders" Personal ]
         set mesDocuments [ file normalize [ file join $mesDocuments audela ] ]
      }
      set audace(rep_mesdocuments) $mesDocuments

      #--- Creation du repertoire de travail
      set catchError [ catch {
         if { ! [ info exists conf(rep_travail) ] } {
            set conf(rep_travail) $audace(rep_mesdocuments)
            if { ! [ file exists $conf(rep_travail) ] } {
               file mkdir $conf(rep_travail)
            }
            set audace(rep_travail) $conf(rep_travail)
         } else {
            if { ! [ file exists $conf(rep_travail) ] } {
               set errorFolder [ catch { file mkdir $conf(rep_travail) } ]
               if { $errorFolder != "0 " } {
                  set conf(rep_travail) $audace(rep_mesdocuments)
                  ::console::affiche_erreur "Redirection to $conf(rep_travail)\n\n"
               }
               if { ! [ file exists $conf(rep_travail) ] } {
                  file mkdir $conf(rep_travail)
               }
            }
            set audace(rep_travail) $conf(rep_travail)
         }
      } ]
      if { $catchError != "0" } {
         ::console::affiche_erreur "$::errorInfo\n"
      }

      #--- On se place dans le repertoire de travail
      cd $audace(rep_travail)

      #--- Repertoire d'installation
      set audace(rep_install) [ file normalize [ file join $audace(rep_gui) .. ] ]

      #--- Creation du repertoire des images
      set catchError [ catch {
         if { ! [ info exists conf(rep_images) ] } {
            set conf(rep_images) [ file join $audace(rep_travail) images ]
            if { ! [ file exists $conf(rep_images) ] } {
               file mkdir $conf(rep_images)
               set filelist [ glob -nocomplain -type f -join $audace(rep_install) images *.* ]
               foreach fileName $filelist {
                  file copy $fileName [ file join $conf(rep_images) [ file tail $fileName ] ]
               }
            }
            set audace(rep_images) $conf(rep_images)
         } else {
            if { ! [ file exists $conf(rep_images) ] } {
               set errorFolder [ catch { file mkdir $conf(rep_images) } ]
               if { $errorFolder != "0 " } {
                  set conf(rep_images) [ file join $audace(rep_travail) images ]
               }
               if { ! [ file exists $conf(rep_images) ] } {
                  file mkdir $conf(rep_images)
                  set filelist [ glob -nocomplain -type f -join $audace(rep_install) images *.* ]
                  foreach fileName $filelist {
                     file copy $fileName [ file join $conf(rep_images) [ file tail $fileName ] ]
                  }
               }
            }
            set audace(rep_images) $conf(rep_images)
         }
      } ]
      if { $catchError != "0" } {
         ::console::affiche_erreur "$::errorInfo\n"
      }

      #--- Initialisation du mode de creation du sous-repertoire des images
      if { ! [info exists conf(rep_images,mode) ] } {
         set conf(rep_images,mode) "none"
      }
      if { ! [info exists conf(rep_images,refModeAuto) ] } {
         set conf(rep_images,refModeAuto) "12"
      }
      if { ! [info exists conf(rep_images,subdir) ] } {
         set conf(rep_images,subdir) ""
      }

      #--- je calcule audace(rep_images) en fonction du mode choisi
      switch $::conf(rep_images,mode) {
         "none" {
            set audace(rep_images) $conf(rep_images)
         }
         "manual" {
            if { $::conf(rep_images,subdir) != "" } {
               set audace(rep_images) [file join $::conf(rep_images) $::conf(rep_images,subdir) ]
            } else {
               set audace(rep_images) $conf(rep_images)
            }
         }
         "date" {
            #--- Je calcule la date du jour (a partir de l'heure TU)
            if { $::conf(rep_images,refModeAuto) == "0" } {
               set heure_nouveau_repertoire "0"
            } else {
               set heure_nouveau_repertoire "12"
            }
            set dateCourante [ clock seconds ]
            if { [ clock format $dateCourante -format "%H" ] < $heure_nouveau_repertoire } {
               #--- Si on est avant l'heure de changement, je prends la date de la veille
               set subdir [ clock format [ expr $dateCourante - 86400 ] -format "%Y%m%d" ]
            } else {
               #--- Sinon, je prends la date du jour
               set subdir [ clock format $dateCourante -format "%Y%m%d" ]
            }
            set dirName [file join $::conf(rep_images) $subdir ]
            if { ![file exists $dirName] } {
               #--- je cree le repertoire
               set catchError [catch {
                  file mkdir $dirName
                  set audace(rep_images) $dirName
               }]
               if { $catchError != 0 } {
                  ::console::affiche_erreur "$::caption(cwdWindow,label_sous_rep) $::errorInfo\n"
                  set audace(rep_images) $conf(rep_images)
               }
            } else {
              set audace(rep_images) $dirName
            }
         }
      }

      #--- Si le repertoire de travail est egal au repertoire des images
      if { ! [info exists conf(rep_travail,travail_images) ] } {
         set conf(rep_travail,travail_images) "1"
      }
      if { $conf(rep_travail,travail_images) == "1" } {
         set conf(rep_travail)   $audace(rep_images)
         set audace(rep_travail) $audace(rep_images)
         #--- On se place dans le nouveau repertoire de travail
         cd $audace(rep_travail)
      }

      #--- Creation du repertoire des scripts
      set catchError [ catch {
         if { ! [ info exists conf(rep_scripts) ] } {
            set conf(rep_scripts) [ file join $audace(rep_home) scripts ]
         }
         if { ! [ file exists $conf(rep_scripts) ] } {
            file mkdir $conf(rep_scripts)
            set filelist [ glob -nocomplain -type f -join $audace(rep_gui) audace scripts *.* ]
            foreach fileName $filelist {
               file copy $fileName [ file join $conf(rep_scripts) [ file tail $fileName ] ]
            }
            set replist [ glob -nocomplain -type d -join $audace(rep_gui) audace scripts * ]
            foreach repName $replist {
               file mkdir [ file join $conf(rep_scripts) [ file tail $repName ] ]
               set filelist [ glob -nocomplain -type f -join $repName *.* ]
               foreach fileName $filelist {
                  file copy $fileName [ file join $conf(rep_scripts) [ file tail $repName ] [ file tail $fileName ] ]
               }
            }
         }
         set audace(rep_scripts) $conf(rep_scripts)
      } ]
      if { $catchError != "0" } {
         ::console::affiche_erreur "$::errorInfo\n"
      }

      #--- Repertoire des catalogues d'Aud'ACE
      set audace(rep_catalogues) [ file join $audace(rep_gui) audace catalogues ]

      #--- Creation du repertoire des catalogues
      set catchError [ catch {
         if { ! [ info exists conf(rep_userCatalog) ] } {
            set conf(rep_userCatalog) [ file join $audace(rep_home) catalog ]
         }
         if { ! [ file exists $conf(rep_userCatalog) ] } {
            file mkdir $conf(rep_userCatalog)
            file copy [ file join $audace(rep_catalogues) readme.txt ] [ file join $conf(rep_userCatalog) readme.txt ]
            file copy [ file join $audace(rep_catalogues) utilisateur1.txt ] [ file join $conf(rep_userCatalog) utilisateur1.txt ]
         }
         file copy -force [ file join $audace(rep_catalogues) obscodes.txt ] [ file join $audace(rep_home) obscodes.txt ]
         set audace(rep_userCatalog) $conf(rep_userCatalog)
      } ]
      if { $catchError != "0" } {
         ::console::affiche_erreur "$::errorInfo\n"
      }

      #--  Par defaut localise les repertoires de catalogues dans le repertoire catalog
      set base [file join $audace(rep_home) catalog]

      #--   Liste des catalogues perennes
      set listePerenne [list 2mass Bmk HIPP Gaia1 Gaia2 Loneos Microcat Nomad1 \
         Ppmx Ppmxl Tle Usnoa2 Usnosa2 Tycho2_fast Ucac2 Ucac3 Ucac4 Urat1]
      #--   Cree ou corrige la liste des catalogues perennes
      if {[info exists conf(rep_userCatalogList)] ==0 || $conf(rep_userCatalogList) ne "$listePerenne"} {
         set conf(rep_userCatalogList) $listePerenne
      }

      #--- Verifie l'existence des repertoires des catalogues
      foreach rep $conf(rep_userCatalogList) {
         set dir rep_userCatalog$rep
         if {[ catch {
            if {![ info exists conf($dir) ]} {
               #--   Definit la variable conf si elle n'existe pas
               set conf($dir)  $conf(rep_userCatalog)
            }
            set audace($dir) $conf($dir)
         } ] !=0 } {
            ::console::affiche_erreur "$::errorInfo\n"
         }
      }

      #--- Creation du repertoire des palettes
      set catchError [ catch {
         if { ! [ info exists conf(rep_userPalette) ] } {
            set conf(rep_userPalette) [ file join $audace(rep_home) palette ]
         }

         if { ! [ file exists $conf(rep_userPalette) ] } {
            file mkdir $conf(rep_userPalette)
            #--   nettoyage de conf(fonction_transfert,*)
            set param_to_destroy [list param2 param3 param4 "visu1,mode" "visu1,position" \
               "visu2,mode" "visu2,position" "visu3,mode" "visu3,position" \
               "visu4,mode" "visu4,position" "visu5,mode" "visu5,position"]
            foreach param $param_to_destroy  {
               if {[info exists conf(fonction_transfert,$param)]} {
                  unset conf(fonction_transfert,$param)
               }
            }
         }

         #--- Repertoire des palettes d'Aud'ACE
         set rep_palette [ file join $audace(rep_gui) audace palette ]

         #--   teste l'existence de chaque palette
         foreach palette [ list gray iris rainbow ] {
            set file [ file join $conf(rep_userPalette) $palette.pal ]
            if { ![file exists $file]} {
               file copy [ file join $rep_palette $palette.pal ] $file
            }
         }
         set audace(rep_userPalette) $conf(rep_userPalette)
      } ]
      if { $catchError != "0" } {
         ::console::affiche_erreur "$::errorInfo\n"
      }

      #--- Creation des filtres de convolution
      set catchError [ catch {
         if { ! [ info exists conf(rep_userFiltre) ] } {
            set conf(rep_userFiltre) [ file join $audace(rep_home) filter ]
         }

         if { ! [ file exists $conf(rep_userFiltre) ] } {
            file mkdir $conf(rep_userFiltre)
            #--- Repertoire des filtres de convolution
            set rep_filtres [ file join $audace(rep_gui) audace masterfilter ]
            set listFiltres [ glob -nocomplain -type f -join $rep_filtres * ]
            foreach file $listFiltres {
               file copy $file [ file join $conf(rep_userFiltre)  [ file tail $file ] ]
            }
         }
         set audace(rep_userFiltre) $conf(rep_userFiltre)
      } ]
      if { $catchError != "0" } {
         ::console::affiche_erreur "$::errorInfo\n"
      }

      #--- Creation du repertoire des archives
      set catchError [ catch {
         if { ! [ info exists conf(rep_archives) ] } {
            set repArchives $audace(rep_mesdocuments)
            set conf(rep_archives) [ file join $repArchives archives ]
         }
         if { ! [ file exists $conf(rep_archives) ] } {
            file mkdir $conf(rep_archives)
         }
         set audace(rep_archives) $conf(rep_archives)
      } ]
      if { $catchError != "0" } {
         ::console::affiche_erreur "$::errorInfo\n"
      }

      #--- Repertoire des plugins
      set audace(rep_plugin) [ file join $audace(rep_gui) audace plugin ]

      #--- Repertoire de la documentaion au format html
      set audace(rep_doc_html) [ file join $audace(rep_gui) audace doc_html ]

      #--- Repertoire de la documentaion au format pdf
      set audace(rep_doc_pdf) [ file join $audace(rep_gui) audace doc_pdf ]

      #--- Chargement des sources externes
      uplevel #0 "source \"[ file join $audace(rep_gui) audace activePluginTool.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace confcolor.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace conffont.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace tkutil.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace camera.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace telescope.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace focus.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace carte.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace conflink.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace confeqt.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace confcam.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace confcat.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace confoptic.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace confpad.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace conftel.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace catagoto.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace plotxy.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace movie.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace icones.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace confvisu.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace sextractor.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace fullscreen.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_gui) audace keyword.tcl ]\""
   }

   proc defaultExeUtils { } {
      global conf

      if { $::tcl_platform(os) == "Linux" } {
         set path [ file join / usr bin ]
      } else {
         set defaultpath [ file join C: "Program Files" ]
         catch {
            set testpath "$::env(ProgramFiles)"
            set kend [expr [string length $testpath]-1]
            for {set k 0} {$k<=$kend} {incr k} {
               set car [string index "$testpath" $k]
               if {$car=="\\"} {
                  set testpath [string replace "$testpath" $k $k /]
               }
            }
            set defaultpath "$testpath"
         }
         set path "$defaultpath"
         set drive [ lindex [ file split "$path" ] 0 ]
      }
      if { ! [ info exists conf(editnotice_pdf) ] } {
         if { $::tcl_platform(os) == "Linux" } {
            set defaultname [ file join ${path} xpdf ]
            set testnames [ list [ file join ${path} kpdf ] [ file join ${path} acroread ] ]
            foreach testname $testnames {
               if { [ file executable "$testname" ] == "1" } {
                  set defaultname "$testname"
                  break;
               }
            }
            set conf(editnotice_pdf) "$defaultname"
            if { ! [ file exist $conf(editnotice_pdf) ] } {
               set conf(editnotice_pdf) [ file join ${path} xpdf ]
            }
         } else {
            set defaultname [ file join ${path} Adobe "Acrobat 4.0" Reader AcroRd32.exe ]
            for { set k 10 } { $k > 1 } { incr k -1 } {
               set testname [ file join ${path} Adobe "Acrobat ${k}.0" Reader AcroRd32.exe ]
               if { [ file executable "$testname" ] == "1" } {
                  set defaultname "$testname"
                  break;
               }
            }
            set conf(editnotice_pdf) "$defaultname"
         }
      }
      if { ! [ info exists conf(editscript) ] } {
         if { $::tcl_platform(os) == "Linux" } {
            set defaultname [ file join ${path} gvim ]
            set testnames [ list [ file join ${path} kedit ] \
                                    [ file join ${path} kwrite ] \
                                    [ file join ${path} kate ]  \
                                    [ file join ${path} gedit ]  \
                                    [ file join ${path} jedit ] ]
            foreach testname $testnames {
               if { [ file executable "$testname" ] == "1" } {
                  set defaultname "$testname"
                  break;
               }
            }
            set conf(editscript) "$defaultname"
         } else {
            set conf(editscript) "write"
         }
      }
      if { ! [ info exists conf(editsite_htm) ] } {
         if { $::tcl_platform(os) == "Linux" } {
            set defaultname [ file join ${path} mozilla ]
            set testnames [ list [ file join ${path} konqueror ] \
                                    [ file join ${path} netscape ] ]
            foreach testname $testnames {
               if { [ file executable "$testname" ] == "1" } {
                  set defaultname "$testname"
                  break;
               }
            }
            set conf(editsite_htm) "$defaultname"
         } else {
            set defaultname [ file join ${path} "Internet Explorer" Iexplore.exe ]
            set testnames [ list [ file join ${path} Netscape Netscape Netscp.exe ] \
            [ file join ${path} Netscape Communicator Program Netscape.exe ] ]
            foreach testname $testnames {
               if { [ file executable "$testname" ] == "1" } {
                  set defaultname "$testname"
                  break;
               }
            }
            set conf(editsite_htm) "$defaultname"
         }
      }
      if { ! [ info exists conf(edit_viewer) ] } {
         if { $::tcl_platform(os) == "Linux" } {
            set conf(edit_viewer) ""
            set defaultname ""
            set testnames [ list [ file join ${path} xnview ] \
                                    [ file join ${path} display ] ]
            foreach testname $testnames {
               if { [ file executable "$testname" ] == "1" } {
                  set defaultname "$testname"
                  break;
               }
            }
            set conf(edit_viewer) "$defaultname"
         } else {
            set defaultname ""
            set testnames [ list [ file join ${path} "ACD Systems" "ACDSee" ACDSee.exe ] \
            [ file join ${path} IrfanView i_view32.exe ] [ file join ${path} XnView xnview.exe ] ]
            foreach testname $testnames {
               if { [ file executable "$testname" ] == "1" } {
                  set defaultname "$testname"
                  break;
               }
            }
            set conf(edit_viewer) "$defaultname"
         }
      }
      #--- Chargement du repertoire de l'interpreteur java
      if { ! [ info exists conf(exec_java) ] } {
         if { $::tcl_platform(os) == "Linux" } {
            if {[ catch {exec which java} exec_java ]} {
               set conf(exec_java) ""
            } else {
               set conf(exec_java) $exec_java
            }
         }
         if { $::tcl_platform(os) == "Windows NT" } {
            set exec_java [ file join ${path} java.exe ]
            if { ![ file executable "$exec_java" ] } {
               set conf(exec_java) ""
            } else {
               set conf(exec_java) $exec_java
            }
         }
         if { $::tcl_platform(os) == "Darwin" } {
            set conf(exec_java) ""
         }
      }
      #--- Chargement du repertoire de Aladin
      if { ! [ info exists conf(exec_aladin) ] } {
         if { $::tcl_platform(os) == "Linux" } {
             set conf(exec_aladin) [ file join [file nativename ~] Aladin Aladin]
         }
         if { $::tcl_platform(os) == "Windows NT" } {
            set exec_aladin [ file join ${path} Aladin Aladin.exe ]
            if { ![ file executable "$exec_aladin" ] } {
               set conf(exec_aladin) ""
            } else {
               set conf(exec_aladin) $exec_aladin
            }
         }
      }
      #--- Chargement du repertoire de l'interpreteur iris (pour Windows uniquement)
      if { ! [ info exists conf(exec_iris) ] } {
         if { $::tcl_platform(os) == "Windows NT" } {
            set exec_iris [ file join ${path} iris.exe ]
            if { ![ file executable "$exec_iris" ] } {
               set conf(exec_iris) ""
            } else {
               set conf(exec_iris) $exec_iris
            }
         }
      }
   }

   #
   # ::audace::repertPresent { repertoire }
   # Recherche des repertoires existants
   #
   proc repertPresent { repertoire } {
      set listrepertPresent [ lsort [ glob -nocomplain -type d -dir $repertoire * ] ]
      set nbre_repert [ llength $listrepertPresent ]
      return [ list $listrepertPresent $nbre_repert ]
   }

   #
   # ::audace::fichierPresent { fichier repertoire }
   # Recherche d'un fichier dans un repertoire donnee
   #
   proc fichierPresent { fichier repertoire } {
      set repertCourant "[pwd]"
      if { [ catch { cd $repertoire } erreur ] } {
         puts stderr $erreur
         return
      }
      set contenuRepert [ glob -nocomplain * ]
      if { [ lsearch -exact $contenuRepert $fichier ] != "-1" } {
         set resultat "1"
      } else {
         set resultat "0"
      }
      cd $repertCourant
      return $resultat
   }

   #
   # ::audace::fichier_partPresent { fichier_recherche repertoire }
   # Recherche d'un fichier particulier sur le disque dur dans une arborescence de 5 niveaux maxi
   #
   proc fichier_partPresent { fichier_recherche repertoire } {
      set a [ ::audace::fichierPresent "$fichier_recherche" "$repertoire" ]
      if { $a == "1" } {
         #--- Rien
      } else {
         set recherche1 [ ::audace::repertPresent "$repertoire" ]
         set listrepertPresent1 [ lindex $recherche1 0 ]
         set nbre_repert1 [ lindex $recherche1 1 ]
         for { set i1 0 } { $i1 < $nbre_repert1 } { incr i1 1 } {
            if { $a == "Fin" } {
               break
            }
            set repertoire [ lindex $listrepertPresent1 $i1 ]
            set a [ ::audace::fichierPresent "$fichier_recherche" "$repertoire" ]
            if { $a == "1" } {
               set a "Fin"
               break
            } else {
               set recherche2 [ ::audace::repertPresent "$repertoire" ]
               set listrepertPresent2 [ lindex $recherche2 0 ]
               set nbre_repert2 [ lindex $recherche2 1 ]
               for { set i2 0 } { $i2 < $nbre_repert2 } { incr i2 1 } {
                  if { $a == "Fin" } {
                     break
                  }
                  set repertoire [ lindex $listrepertPresent2 $i2 ]
                  set a [ ::audace::fichierPresent "$fichier_recherche" "$repertoire" ]
                  if { $a == "1" } {
                     set a "Fin"
                     break
                  } else {
                     set recherche3 [ ::audace::repertPresent "$repertoire" ]
                     set listrepertPresent3 [ lindex $recherche3 0 ]
                     set nbre_repert3 [ lindex $recherche3 1 ]
                     for { set i3 0 } { $i3 < $nbre_repert3 } { incr i3 1 } {
                        if { $a == "Fin" } {
                           break
                        }
                        set repertoire [ lindex $listrepertPresent3 $i3 ]
                        set a [ ::audace::fichierPresent "$fichier_recherche" "$repertoire" ]
                        if { $a == "1" } {
                           set a "Fin"
                           break
                        } else {
                           set recherche4 [ ::audace::repertPresent "$repertoire" ]
                           set listrepertPresent4 [ lindex $recherche4 0 ]
                           set nbre_repert4 [ lindex $recherche4 1 ]
                           for { set i4 0 } { $i4 < $nbre_repert4 } { incr i4 1 } {
                              if { $a == "Fin" } {
                                 break
                              }
                              set repertoire [ lindex $listrepertPresent4 $i4 ]
                              set a [ ::audace::fichierPresent "$fichier_recherche" "$repertoire" ]
                              if { $a == "1" } {
                                 set a "Fin"
                                 break
                              } else {
                                 set recherche5 [ ::audace::repertPresent "$repertoire" ]
                                 set listrepertPresent5 [ lindex $recherche5 0 ]
                                 set nbre_repert5 [ lindex $recherche5 1 ]
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      return $repertoire
   }

   proc loadSetup { { visuNo 1 } } {
      global audace conf

      #--- Initialisation
      if {[info exists conf]} {unset conf}

      #--- Changement du nom des fichiers de parametres
      set fichierIni [ file join $::audace(rep_home) config.ini ]
      if { [ file exists $fichierIni ] } { file rename -force "$fichierIni" [ file join $::audace(rep_home) audace.ini ] }
      set fichierBak [ file join $::audace(rep_home) config.bak ]
      if { [ file exists $fichierBak ] } { file rename -force "$fichierBak" [ file join $::audace(rep_home) audace.bak ] }

      #--- Ouverture du fichier de parametres
      set fichier [ file join $::audace(rep_home) audace.ini ]
      if { [ file exists $fichier ] } { uplevel #0 "source \"$fichier\"" }

      #--- Initialisation de la liste des binnings si aucune camera n'est connectee
      set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }

      #--- Initialisation indispensable ici de certaines variables de configuration
      ::seuilWindow::initConf
      ::confFichierIma::initConf
      ::confPosObs::initConf
      ::confTypeFenetre::initConf
      ::confNbreDecimales::initConf
      ::confEditScript::initConf

      #--- Je fixe la precision des nombres flottants a 12 decimales
      if { $conf(nbreDecimales) == "12" } {
         set ::tcl_precision 12
      } else {
         set ::tcl_precision 17
      }

      #--- Initialisation des executables
      ::audace::defaultExeUtils
   }

   proc verifip { ipinit } {
      #--- IP local
      set ip [lindex [hostaddress] 0]
      set ipmaskhost "[lindex $ip 0].[lindex $ip 1].[lindex $ip 2]"
      set ipnumhost  "[lindex $ip 3]"
      #--- IP device
      set ip [split $ipinit "."]
      set ipmask "[lindex $ip 0].[lindex $ip 1].[lindex $ip 2]"
      set ipnum  "[lindex $ip 3]"
      if {$ipmask!=$ipmaskhost} {
         set ipmask $ipmaskhost
      }
      if { ( $ipnum == $ipnumhost ) || ( $ipnum == "" ) } {
         set ipnum [expr $ipnumhost+10]
         if {$ipnum>255} {
            set ipnum [expr $ipnumhost-10]
         }
      }
      return "${ipmask}.${ipnum}"
   }

   proc createDialog { } {
      variable This
      global audace caption conf

      #---
      toplevel $This
      if { [ info exists conf(audace,visu1,wmgeometry) ] == "1" } {
         wm geometry $This $conf(audace,visu1,wmgeometry)
      } else {
         wm geometry $This 631x453+0+0
      }
      wm maxsize $This [winfo screenwidth .] [winfo screenheight .]
      wm minsize $This 631 453
      wm resizable $This 1 1
      wm deiconify $This

      #--- je cree la visu de la fenetre principale
      set visuNo [ ::confVisu::create $audace(base) ]

      #---
      wm title $This "$caption(audace,titre) (visu$visuNo)"
      wm protocol $This WM_DELETE_WINDOW "::audace::quitter"
      update

      #--- creation des variables audace dependant de la visu
      set audace(visuNo)  $visuNo
      set audace(bufNo)   [visu$visuNo buf]
      set audace(imageNo) [visu$visuNo image]
      set audace(hCanvas) $::confVisu::private($visuNo,hCanvas)

      #--- j'ajoute le repertoire des outils dans le chemin
      lappend ::auto_path [file join $audace(rep_plugin) tool]

      #--- je recherche les fichiers tool/*/pkgIndex.tcl
      set filelist [glob -nocomplain -type f -join "$audace(rep_plugin)" tool * pkgIndex.tcl ]
      #--- Chargement des differents outils
      set outilsActifsInactifs ""
      foreach pkgIndexFileName $filelist {
         if { [::audace::getPluginInfo $pkgIndexFileName pluginInfo] == 0 } {
            #--- je charge le plugin
            set catchResult [catch { package require $pluginInfo(name)} ]
            if { $catchResult == 1 } {
               #--- j'affiche l'erreur dans la console
               ::console::affiche_erreur "$::errorInfo\n"
            } else {
               foreach os $pluginInfo(os) {
                  if { $os == [ lindex $::tcl_platform(os) 0 ] } {
                     #--- j'execute la procedure initPlugin si elle existe
                     if { [info procs $pluginInfo(namespace)::initAudace] != "" } {
                        $pluginInfo(namespace)::initAudace $audace(base)
                     }
                     #--- je cree la liste des namespaces de tous les outils actifs et inactifs
                     ::confChoixOutil::addTool1 $pluginInfo(namespace) 1 ""
                     #--- j'affiche les outils dans la Console
                     set ::panneau(menu_name,[ string trimleft $pluginInfo(namespace) "::" ]) $pluginInfo(title)
                     ::console::affiche_prompt "#$caption(audace,tool) $pluginInfo(title) v$pluginInfo(version)\n"
                  }
               }
            }
         } else {
            ::console::affiche_erreur "Error loading tool $pkgIndexFileName \n$::errorInfo\n\n"
         }
      }
      #---
      ::console::disp "\n"
      return $visuNo
   }

   proc initLastEnv { visuNo } {
      variable This
      global audace conf

      #--- Mise a jour des couleurs des interfaces
      ::confColor::applyColor $audace(base)
      ::confColor::applyColor $audace(Console)

      #--- Prise en compte des dimensions et de la position de la Console
      if { [ info exists conf(console,wmgeometry) ] == "1" } {
         wm geometry $audace(Console) $conf(console,wmgeometry)
      } else {
         wm geometry $audace(Console) 360x200+220+180
      }
      update

      #--- Recherche des ports COMs disponibles dans un thread
      #--- Uniquement si le TCL est multithread
      ::serialport::searchPortsThread

      #--- Connexion au demarrage des cameras
      ::confCam::startPlugin

      #--- Connexion au demarrage de la monture
      ::confTel::startPlugin

      #--- Connexion au demarrage des equipements
      ::confEqt::startPlugin

      #--- Connexion au demarrage de la carte
      ::confCat::startPlugin
   }

   #
   # ::audace::giveFocusAudACE
   # Donne le focus a la fenetre principale Aud'ACE
   #
   proc giveFocusAudACE { } {
      variable This

      switch -- [ wm state $This ] {
         normal { raise $This }
         iconic { wm deiconify $This }
      }
      focus $This
   }

   #
   # ::audace::dispClock1
   # Fonction qui calcule et met a jour HL, TU et TSL
   # Cette fonction se re-appelle au bout d'une seconde
   #
   proc dispClock1 { } {
      global audace caption conf

      #--- Heure Locale
      set time1 [ clock format [ clock seconds ] -format "%Hh %Mm %Ss" -timezone :localtime ]
      set audace(hl,format,hmsint) $time1
      #--- Formatage heure TU
      set time2 [ clock format [ clock seconds ] -format "%Hh %Mm %Ss" -timezone :UTC ]
      set audace(tu,format,hmsint) $time2
      #--- Preparation affichage heure TSL
      set tsl [mc_date2lst [ ::audace::date_sys2ut now ] $conf(posobs,observateur,gps)]
      set audace(tsl) $tsl
      set tslsec [lindex $tsl 2]
      set tsl_hms [format "%02dh %02dm %02ds" [lindex $tsl 0] [lindex $tsl 1] [expr int($tslsec)]]
      set audace(tsl,format,hmsint) $tsl_hms
      #--- Formatage heure TSL pour un pointage au zenith
      set tsl_zenith [format "%02dh%02dm%02d" [lindex $tsl 0] [lindex $tsl 1] [expr int($tslsec)]]
      set audace(tsl,format,zenith) $tsl_zenith
      #--- Formatage et affichage de la date et de l'heure TU dans l'interface Aude'ACE
      set audace(tu,format,dmy) [ clock format [ clock seconds ] -format "%d/%m/%Y" -timezone :UTC ]
      set audace(tu,format,dmyhmsint) [ clock format [ clock seconds ] -format "%d/%m/%Y %H:%M:%S $caption(audace,temps_universel)" -timezone :UTC ]
      #--- Formatage heure HL pour timer
      set secondes [ clock seconds ]
      if { [expr { fmod($secondes,60) } ] == 0 } {
         set audace(hl,format,hm) [ clock format $secondes -format "%H %M" -timezone :localtime ]
      }
      after 1000 ::audace::dispClock1
   }

   proc date_sys2ut { { date now } } {
      if { $date == "now" } {
         set time [ clock format [ clock seconds ] -format "%Y %m %d %H %M %S" -timezone :UTC ]
      } else {
         set jjnow [ mc_date2jd $date ]
         set time  [ mc_date2ymdhms $jjnow ]
      }
      return $time
   }

   #------------------------------------------------------------
   #  autovisu
   #     rafraichit l'affichage
   #------------------------------------------------------------
   proc autovisu { { visuNo "1" } { force "-no" } } {
      ::confVisu::autovisu $visuNo $force
   }

   #
   # ::audace::lanceViewerImages
   # Lance le viewer pour visualiser les images d'un APN CoolPix
   #
   proc lanceViewerImages { filename } {
      global audace caption conf confgene

      menustate disabled
      set confgene(EditScript,error_script) "1"
      set confgene(EditScript,error_pdf)    "1"
      set confgene(EditScript,error_htm)    "1"
      set confgene(EditScript,error_viewer) "1"
      set confgene(EditScript,error_java)   "1"
      set confgene(EditScript,error_aladin) "1"
      set confgene(EditScript,error_iris)   "1"

      if [ string compare $filename "" ] {
         set a_effectuer "exec \"$conf(edit_viewer)\" \"$filename\" &"
         if [ catch $a_effectuer msg ] {
            #--- Vous devez choisir un viewer d'images
            ::console::affiche_erreur "$caption(audace,console_rate) \n"
            ::console::affiche_erreur "$msg \n\n"
            set confgene(EditScript,error_viewer) "0"
            ::confEditScript::run "$audace(base).confEditScript"
            set a_effectuer "exec \"$conf(edit_viewer)\" \"$filename\" &"
            if [ catch $a_effectuer msg ] {
               ::console::affiche_erreur "$caption(audace,console_rate) \n"
               ::console::affiche_erreur "$msg \n\n"
            } else {
               #--- Tout est OK : Ouverture du fichier
               ::console::affiche_erreur "$caption(audace,console_gagne) \n\n"
            }
         } else {
            #--- Tout est OK : Ouverture du fichier
            ::console::affiche_erreur "$caption(audace,console_gagne) \n\n"
         }
      } else {
         #--- Il n'y a pas de fichier a ouvrir
         ::console::affiche_erreur "$caption(audace,console_annule) \n\n"
      }
      menustate normal
   }

   proc shutdown_devices { } {
      #--- On coupe proprement les devices
      set camlist [::cam::list]
      foreach cam $camlist {
         ::cam::delete $cam
      }
      set tellist [::tel::list]
      foreach tel $tellist {
         ::tel::delete $tel
      }
      #--- Arret des fonctions lancees par l'outil "remotectrl"
      catch { wiz_del_client }
      catch { wiz_del_server }
   }

   proc rien { } {
      #--- Sert a bloquer l'affichage multiple de la fenetre Quitter
   }

   proc menustate { state } {
      global audace

      foreach menu [winfo children $audace(base).menubar] {
         set imax [$menu index end]
         for {set i 0} {$i <= $imax} {incr i} {
            catch {$menu entryconfigure $i -state $state}
         }
      }
      # Configuration de l'etat du menu Interop
      catch {::vo_tools::handleBroadcastBtnState}
   }

   proc cursor { curs } {
      global audace

      ::confVisu::cursor $audace(visuNo) $curs
   }

   proc bg { coul } {
      global audace

      ::confVisu::bg $audace(visuNo) $coul
   }

   # ::audace::screen2Canvas coord
   # Transforme des coordonnees ecran en coordonnees canvas. L'argument est une liste de deux entiers,
   # et retourne egalement une liste de deux entiers
   #
   proc screen2Canvas { coord } {
      global audace

      return [ ::confVisu::screen2Canvas $audace(visuNo) $coord ]
   }

   # ::audace::canvas2Picture coord {stick left}
   # Transforme des coordonnees canvas en coordonnees image. L'argument est une liste de deux entiers,
   # et retourne egalement une liste de deux entiers.
   # Les coordonnees canvas commencent a 0,0 dans le coin superieur gauche de l'image.
   # Les coordonnees image  commencent a 1,1 dans le coin inferieur gauche de l'image.
   # En passant un argument <> de left pour stick, calcule les coordonnees par arrondi superieur.
   #
   proc canvas2Picture { coord { stick left } } {
      global audace

      return [ ::confVisu::canvas2Picture $audace(visuNo) $coord $stick ]
   }

   #
   # ::audace::picture2Canvas coord
   # Transforme des coordonnees image en coordonnees canvas. L'argument est une liste de deux entiers,
   # et retourne egalement une liste de deux entiers
   #
   proc picture2Canvas { coord } {
      global audace

      return [ ::confVisu::picture2Canvas $audace(visuNo) $coord ]
   }

   #
   # f_a : tableau de configuration dans le fichier
   # m_a : tableau de configuration en memoire
   # Renvoie 1 si il faut reecrire le fichier de configuration
   # Renvoie 0 si les configurations dans le fichier et en memoire sont identiques
   #
   proc ini_fileNeedWritten { f_a m_a } {
      #---
      upvar $f_a file_array
      upvar $m_a mem_array
      #---
      set file_names [array names file_array]
      set mem_names [array names mem_array]
      foreach a $file_names {
         if {[lsearch -exact $mem_names $a]==-1} {
           ### ::console::affiche_erreur "$a not in memory\n"
            return 1
         }
      }
      foreach a $mem_names {
         if {[lsearch -exact $file_names $a]==-1} {
           ### ::console::affiche_erreur "$a not in file\n"
            return 1
         } else {
            if {[string compare [array get file_array $a] [array get mem_array $a]]!=0} {
              ### ::console::affiche_erreur "$a different between file and memory : \"[array get file_array $a]\" \"[array get mem_array $a]\"\n"
               return 1
            }
         }
      }
      return 0
   }

   #
   # filename : nom du fichier
   # Charge un fichier dans le tableau conf(...)
   #
   proc ini_getArrayFromFile { filename } {
      global conf

      set tempinterp [interp create]
      catch {interp eval $tempinterp "source \"$filename\""} m
      array set file_conf [interp eval $tempinterp "array get conf"]
      interp delete $tempinterp
      return [array get file_conf]
   }

   #
   # filename : nom du fichier
   # f_a : tableau de configuration dans le fichier
   # Enregistre le tableau conf(...) dans un fichier
   #
   proc ini_writeIniFile { filename f_a } {
      upvar $f_a file_array
      if {[catch {
         set fid [open $filename w]
         puts $fid "global conf"
         foreach a [lsort -dictionary [array names file_array]] {
            puts $fid "set conf($a) \"[lindex [array get file_array $a] 1]\""
         }
         close $fid
      } erreur ]} {
         tk_messageBox -icon error -message $erreur -type ok
      }
   }

   #------------------------------------------------------------
   #  getPluginInfo
   #    retourne les informations sur un plugin dans le tableau passe en parametre
   #      pluginInfo(name)      nom du plugin
   #      pluginInfo(version)   version du plugin
   #      pluginInfo(command)   commande pour charger le plugin
   #      pluginInfo(namespace) namespace principal du plugin
   #      pluginInfo(title)     titre du plugin dans la langue de l'utilisateur
   #      pluginInfo(type)      type du plugin
   #      pluginInfo(os)        os compatible avec le plugin
   #
   # parametres :
   #    pkgIndexFileName : nom complet du fichier pkgIndex.tcl (avec le repertoire)
   #    pluginInfo : tableau (array) des informations sur le plugin rempli par cette procedure
   # return :
   #     0 si pas d'erreur, le resultat est dans le tableau donne en parametre
   #    -1 si une erreur, le libelle de l'erreur est dans ::::errorInfo
   #
   # Exemple d'utilisation
   #    ::audace::getPluginInfo "$audace(rep_plugin)/equipment/focuserjmi/pkgIndex.tcl" pluginInfo
   #    retourne dans pluginInfo :
   #       pluginInfo(name)     = focuserjmi
   #       pluginInfo(version)  = 1.0
   #       pluginInfo(command)  = source c:/audela/gui/audace/plugin/equipment/focuserjmi/focuserjmi.tcl
   #       pluginInfo(namespace)= focuserjmi
   #       pluginInfo(title)    = Focaliseur JMI
   #       pluginInfo(type)     = focuser
   #       pluginInfo(os)       = Windows Linux Darwin
   #------------------------------------------------------------
   proc getPluginInfo { pkgIndexFileName pluginInfo } {
      upvar $pluginInfo pinfo

      #--- je cree un interpreteur temporaire pour charger le package sans pertuber AudeLA
      set interpTemp [interp create ]
      set catchResult [ catch {
         #--- j'autorise les commandes source et file pour pouvoir charger le plugin dans l'interpreteur temporaire
         #interp expose $interpTemp source
         #interp expose $interpTemp file
         #--- je transfere des variables globales a l'interpreteur temporaire
         $interpTemp eval [ list set audace(endCopyright) $::audace(endCopyright) ]
         $interpTemp eval [ list set langage $::langage ]
         $interpTemp eval [ list set pkgIndexFileName "$pkgIndexFileName" ]
         $interpTemp eval [ list set dir [file dirname "$pkgIndexFileName"] ]

         #--- je teste le plugin dans l'interpreteur temporaire
         $interpTemp eval {
            proc processUnknownRequiredPackage { packageName packageVersion } {
               if { $packageName == "audela" } {
                  set ::audelaRequiredVersion $packageVersion
               }
            }
            global caption
            set caption(test) ""
            set audelaRequiredVersion ""

            #--- je recupere la liste des package deja charges
            set loadedPackages1 [package names]
            set loadedNamespaces1 [namespace children ::]

            ###set dir "[file dirname $pkgIndexFileName]"
            source  "$pkgIndexFileName"
            #--- je recupere le nom du plugin
            set loadedPackages2 [package names]
            set pluginName ""
            foreach packageName $loadedPackages2 {
               if { [lsearch -exact $loadedPackages1 $packageName] == -1  } {
                  #--- j'ai trouve le package qui vient d'etre charge
                  set pluginName $packageName
                  break
               }
            }
            if { $pluginName != "" } {
               #--- je recupere la version du plugin
               set pluginVersion [package versions $pluginName]
               #--- je recupere la version de AudeLA requise par le plugin
               package unknown processUnknownRequiredPackage
               set sourceFile [package ifneeded $pluginName $pluginVersion]
               catch { eval "$sourceFile" }
               if { $audelaRequiredVersion != "" } {
                  package provide "audela" "$audelaRequiredVersion"
                  eval "$sourceFile"
               }
               #--- je recupere le namespace principal du plugin
               set pluginNamespace ""
               set loadedNamespaces2 [namespace children ::]
               foreach packageNamespace $loadedNamespaces2 {
                  if { [lsearch -exact $loadedNamespaces1 $packageNamespace] == -1  } {
                     #--- j'ai trouve le namespace qui vient d'etre charge
                     set pluginNamespace $packageNamespace
                     break
                  }
               }

               if { $pluginNamespace != "" } {
                  #error "pluginNamespace=$pluginNamespace  command=$pluginNamespace\::getPluginType res=[info commands $pluginNamespace\::getPluginType]\n"
                  #--- je recupere le titre du plugin dans la langue de l'utilisateur
                  if { [info commands $pluginNamespace\::getPluginTitle] != "" } {
                     set pluginTitle [$pluginNamespace\::getPluginTitle]
                  } else {
                     set pluginTitle "$pluginNamespace"
                  }
                  #--- je recupere le type du plugin
                  if { [info commands $pluginNamespace\::getPluginType] != "" } {
                     set pluginType [$pluginNamespace\::getPluginType]
                  } else {
                     set pluginType ""
                  }
                  #--- je recupere le ou les OS supporte(s) par le plugin
                  if { [info commands $pluginNamespace\::getPluginOS] != "" } {
                     set pluginOS [$pluginNamespace\::getPluginOS]
                  } else {
                     set pluginOS [ list Windows Linux Darwin ]
                  }
                } else {
                   error "plugin namespace not found in file $pkgIndexFileName"
                }
            } else {
               error "plugin name not found in file $pkgIndexFileName"
            }
         }

         #--- je recupere les informations du plugin
         set pinfo(name)          [$interpTemp eval { set pluginName } ]
         set pinfo(version)       [$interpTemp eval { set pluginVersion } ]
         set pinfo(command)       [$interpTemp eval { set sourceFile } ]
         set pinfo(audelaVersion) [$interpTemp eval { set audelaRequiredVersion } ]
         set pinfo(type)          [$interpTemp eval { set pluginType } ]
         set pinfo(title)         [$interpTemp eval { set pluginTitle } ]
         set pinfo(os)            [$interpTemp eval { set pluginOS } ]
         set namespaceList2 [$interpTemp eval { set pluginNamespace } ]
         if { [llength $namespaceList2 ] > 0 } {
            set pinfo(namespace) [lindex $namespaceList2 0]
         } else {
            error "Namespace not found in plugin $pinfo(name)"
         }
      } ]
      #--- je supprime l'interpreteur temporaire
      interp delete $interpTemp
      #--- je retourne -1 s'il y a eu une erreur
      if { $catchResult == 1 } {
         return "-1"
      } else {
         return "0"
      }
   }

   #------------------------------------------------------------
   #  getPluginTypeDirectory
   #    retourne le repertoire du plugin en fonction de son type
   #    Actuellement les types de plugins sont dans un repertoire
   #    dont le nom est identique au type, sauf le type "focuser"
   #    ou "spectroscope" qui est dans le repertoire "equipement"
   #------------------------------------------------------------
   proc getPluginTypeDirectory { pluginType } {
      if { $pluginType == "focuser" } {
         set typeDirectory "equipment"
      } elseif { $pluginType == "spectroscope" } {
         set typeDirectory "equipment"
      } else {
         set typeDirectory $pluginType
      }
      return $typeDirectory
   }

   #------------------------------------------------------------
   #  appendUpdateCommand
   #    Ajoute des commandes de mise a jour d'Audela
   #    a executer au prochain demarrage de Audela
   #    Les commandes sont enregistrees dans le fichier $::audela_start_dir/update.tcl
   #    qui est execute puis efface par audela.exe (voir lapin.c)
   #------------------------------------------------------------
   proc appendUpdateCommand { command } {
      set fileNo [open "$::audela_start_dir/update.tcl" a]
           puts -nonewline $fileNo "$command"
           close $fileNo
   }

   #------------------------------------------------------------
   #  appendUpdateMessage
   #    Ajoute un message de mise à jour
   #    a executer au prochain demarrage de Audela
   #------------------------------------------------------------
   proc appendUpdateMessage { updateMessage } {
      set fileNo [open "$::audela_start_dir/update.tcl" a]
           puts -nonewline $fileNo "append audela(updateMessage) \"$updateMessage\" \n"
           close $fileNo
   }

}

########################## Fin du namespace audace ##########################

# Scrolled_Canvas
# Cree un canvas scrollable, ainsi que les deux scrollbars pour le bouger
# Ref : Brent Welsh, Practical Programming in TCL/TK, rev.2, page 392
#
proc Scrolled_Canvas { c args } {
   frame $c
   eval {canvas $c.canvas \
      -xscrollcommand [list $c.xscroll set] \
      -yscrollcommand [list $c.yscroll set] \
      -highlightthickness 0 \
      -borderwidth 0} $args
   scrollbar $c.xscroll -orient horizontal -command [list $c.canvas xview]
   scrollbar $c.yscroll -orient vertical -command [list $c.canvas yview]
   grid $c.canvas $c.yscroll -sticky news
   grid $c.xscroll -sticky ew
   grid rowconfigure $c 0 -weight 1
   grid columnconfigure $c 0 -weight 1
   return $c.canvas
}

proc Scrolled_Text { f args } {
   frame $f
   text $f.list -xscrollcommand [list Scroll_Set $f.xscroll [list grid $f.xscroll -row 1 -column 0 -sticky we]] \
                -yscrollcommand [list Scroll_Set $f.yscroll [list grid $f.yscroll -row 0 -column 1 -sticky ns]]
   eval {$f.list configure} $args
   scrollbar $f.xscroll -orient horizontal -command [list $f.list xview]
   scrollbar $f.yscroll -orient vertical -command [list $f.list yview]
   grid $f.list -sticky news
   grid rowconfigure $f 0 -weight 1
   grid columnconfigure $f 0 -weight 1
   return $f.list
}

proc Scrolled_Listbox { f args } {
   frame $f
   listbox $f.list -xscrollcommand [list Scroll_Set $f.xscroll [list grid $f.xscroll -row 1 -column 0 -sticky we]] \
                   -yscrollcommand [list Scroll_Set $f.yscroll [list grid $f.yscroll -row 0 -column 1 -sticky ns]]
   eval {$f.list configure} $args
   scrollbar $f.xscroll -orient horizontal -command [list $f.list xview]
   scrollbar $f.yscroll -orient vertical -command [list $f.list yview]
   grid $f.list -sticky news
   grid rowconfigure $f 0 -weight 1
   grid columnconfigure $f 0 -weight 1
   return $f.list
}

proc Scroll_Set { scrollbar geoCmd offset size } {
   if { $offset != 0.0 || $size != 1.0 } {
      eval $geoCmd
   }
   $scrollbar set $offset $size
}

proc save_cursor { } {
   global audace busy

   set busy [ list "$audace(base)" "$audace(Console)" ]
   set window_list $busy
   while {$window_list != ""} {
      set next {}
      foreach w $window_list {
         catch {
            #--- Le catch permet de traiter le cas des fenetres qui n'ont pas l'option -cursor
            #--- en les ignorant (exemple BWidget)
            set cursor [lindex [$w configure -cursor] 4]
            if { [ winfo toplevel $w ] == $w || $cursor != "" } {
               lappend busy [list $w $cursor]
            }
         }
         set next [concat $next [winfo children $w]]
      }
      set window_list $next
   }
}

proc all_cursor { curs } {
   global busy

   foreach w $busy {
      catch {[lindex $w 0] config -cursor $curs}
   }
   update
}

proc restore_cursor { } {
   global busy

   foreach w $busy {
      catch {[lindex $w 0] config -cursor [lindex $w 1]}
   }
}

#------------------------------------------------------------
#  stackTrace
#     affiche la pile d'appel des procedures dans la console
#------------------------------------------------------------
proc stackTrace { {procedureFullName "" } } {

   set catchError [ catch {
      set stack "Stack trace:\n"
      for {set i 1} {$i < [info level]} {incr i} {
         set lvl [info level -$i]
         if { "[lrange $lvl 0 1]" == "namespace inscope"  } {
            set procedureName "[lindex $lvl 2]::[lindex $lvl 3]"
            set argNo 4
         } else {
           set procedureName [lindex $lvl 0]
            set argNo 1
         }
         set procedureFullName [uplevel [list namespace which -command $procedureName]]
         if { [info command $procedureFullName] == "" } {
            set procedureFullName "::audace::$procedureName"
         }

        ### ::console::disp "stackTrace level=$i lvl=$lvl procedureName=$procedureName procedureFullName=$procedureFullName\n"

         append stack [string repeat " " $i]$procedureFullName
         foreach value $argNo arg [info args $procedureFullName] {
            if {$value eq "" } {
               info default $procedureFullName $arg value
            } else {
               append stack " $arg='$value'"
            }
         }
         append stack "\n"
      }
      ::console::disp "$stack\n"
   } ]
   #--- je traite les erreur imprevues
   if { $catchError != 0 } {
      #--- je trace le message d'erreur
      ::console::affiche_erreur "$::errorInfo\n"
   }
}

#
#--- Execute en premier au demarrage
#

#--- On cache la fenetre mere
wm focusmodel . passive
wm withdraw .

::audace::run
focus -force $audace(Console)
::console::GiveFocus

#--- On execute eventuellement un script "MesDocuments/audela"/perso.tcl au lancement de AudeLA
#--- Cela permet a chacun de personnaliser l'initialisation de son interface graphique
if {[file exists [file join $audace(rep_mesdocuments) perso.tcl]]==1} {
   source [file join $audace(rep_mesdocuments) perso.tcl]
}

#--- je charge une image ou un script si les parametres optionnels sont presents
# usage :
#   audela <fichier image>
#   audela <fichier_tcl> <parametres argv0 argv1 ...>
if { [llength $::argv] >= 1 } {
   set catchResult [ catch {
      if { [file extension [lindex $::argv 0]] == ".tcl" || [lindex $::argv 0] == "" } {
         #--- j'execute le script tcl dont le nom est passe en parametre de Audel
         set scriptFileName [lindex $::argv 0]
         console::disp "argc=[llength $::argv]\n"
         console::disp "argv=$::argv\n"
         console::disp "scriptFileName=$scriptFileName \n"
         if { $scriptFileName != "" } {
            #--- je normalise les separateurs dans le nom complet du script TCL en fonction de l'OS
            set scriptFileName [file normalize $scriptFileName]
            #--- je supprime le parametre argv0 , et je decale les parametres suivants
            set ::argv [lreplace $::argv 0 0]
            uplevel #0 "source \"$scriptFileName\""
         }
      } elseif { [lsearch -regexp [::tkutil::getSaveFileType ] [file extension [lindex $::argv 0]]]!= -1 } {
         #--- j'affiche l'image dont le nom est passe en parametre de Audela
         set imageFileName [file normalize [lindex $::argv 0]]
         loadima $imageFileName
         set audace(rep_images) [file dirname $imageFileName]
      }
   } ]
   if { $catchResult != 0 } {
     ::console::affiche_erreur "$::errorInfo\n"
   }
}

