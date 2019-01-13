#
## @file help.tcl
#  @brief Aide d'Aud'ACE
#  @author Michel PUJOL
#  @namespace audace
#  @brief Aide d'Aud'ACE
#  $Id: help.tcl 13695 2016-04-13 19:23:32Z rzachantke $
#

###########################################################################################
# namespace audace
#
#   ::audace::showHelpItem    affiche l'aide sur un sujet hors plugin
#   ::audace::showHelpPlugin  affiche l'aide sur un plugin
#
#   ::audace::showMain        affiche la page d'accueil de l'aide
#   ::audace::showFunctions   affiche la page de l'inventaire des fonctions du logiciel
#
##########################################################################################

global help

#--- sous-repertoire invariant de l'aide
set help(dir,docLibaudela)  [ file join doc libaudela ]
set help(dir,docLibgsltcl)  [ file join doc libgsltcl ]
set help(dir,docLibgzip)    [ file join doc libgzip ]
set help(dir,docLibmc)      [ file join doc libmc ]
set help(dir,docLibrgb)     [ file join doc librgb ]
set help(dir,docLibtt)      [ file join doc libtt ]

#--- sous-repertoires de l'aide (par langue)
set help(dir,intro)         "01presentation"
set help(dir,prog)          "02programming"
set help(dir,fichier)       "03file"
set help(dir,affichage)     "04view"
set help(dir,images)        "05images"
set help(dir,analyse)       "07analysis"
set help(dir,cameras)       "08camera"
set help(dir,telescopes)    "09telescope"
set help(dir,config)        [ file join 10setup 01audace ]
set help(dir,camera)        [ file join 10setup 02camera ]
set help(dir,mount)         [ file join 10setup 03mount ]
set help(dir,optic)         [ file join 10setup 04optic ]
set help(dir,equipment)     [ file join 10setup 05equipment ]
set help(dir,pad)           [ file join 10setup 06pad ]
set help(dir,chart)         [ file join 10setup 07chart ]
set help(dir,config+)       "10setup"
set help(dir,aide)          "11help"
set help(dir,tutoriel)      "12tutorial"

# *************** Version française ***************************
if { [ string compare $langage "french" ] == "0" } {
   set help(dir,intro)      "01presentation"
   set help(dir,prog)       "02programmation"
   set help(dir,fichier)    "03fichier"
   set help(dir,affichage)  "04affichage"
   set help(dir,images)     "05images"
   set help(dir,analyse)    "07analyse"
   set help(dir,cameras)    "08camera"
   set help(dir,telescopes) "09telescope"
   set help(dir,config)     [ file join 10configuration 01audace ]
   set help(dir,camera)     [ file join 10configuration 02camera ]
   set help(dir,mount)      [ file join 10configuration 03monture ]
   set help(dir,optic)      [ file join 10configuration 04optique ]
   set help(dir,equipment)  [ file join 10configuration 05equipement ]
   set help(dir,pad)        [ file join 10configuration 06raquette ]
   set help(dir,chart)      [ file join 10configuration 07carte ]
   set help(dir,config+)    "10configuration"
   set help(dir,aide)       "11aide"
   set help(dir,tutoriel)   "12tutoriel"
}

namespace eval ::audace {

   #----------------------------------------------------------------------------------------
   ## @brief  ouvre la fenetre d'aide si elle n'est pas déjà ouverte
   #  puis affiche la page HTML demandee
   #  @code
   #  ::audace::showHelpDocLibrairy "$help(dir,docLibtt)" "ttus1-fr.htm" "ADD"
   #  @endcode
   #  @param  folderRelativeFileName nom du répertoire du fichier d'aide
   #  @param  relativeFileName nom court du fichier d'aide
   #  @param  tag  balise anchor dans la page HTML (optionel)
   #  @note : ne pas rajouter # devant le tag, il est rajouté automatiquement
   #
   proc ::audace::showHelpDocLibrairy { { folderRelativeFileName "" } { relativeFileName "" } { tag "" } } {
      global audace help

      #--- J'affiche l'aide avec le navigateur selectionne
      if { $::conf(editsite_htm,selectHelp) == "1" } {
         #--- Je prepare le nom du repertoire de l'aide en fonction de la langue
         if { ( $::langage != "french" ) && ( $::langage != "english" ) } {
            set audace(help_langage) "english"
         } else {
            set audace(help_langage) $::langage
         }
         if { $relativeFileName != "" } {
            #--- J'affiche le fichier d'aide avec le navigateur selectionne
            ::audace::Lance_Site_htm [ file join file:///[ file join $audace(rep_install) \
               $folderRelativeFileName $relativeFileName ] ]#$tag
         } else {
            #--- Si le nom du fichier est absent, j'affiche le sommaire de l'aide
            ::audace::Lance_Site_htm [ file join file:///[ file join $audace(rep_doc_html) $audace(help_langage) \
               $help(dir,intro) "1010presentation.htm" ] ]
         }
         return
      }

      #--- J'affiche la fenetre si ce n'est pas deja fait
      if { ! [ info exists audace(help_window) ] || ! [ winfo exists $audace(help_window) ] } {
         ::audace::initHelp
      }

      if { [ winfo exists $audace(base).help ] } {
         wm deiconify $audace(base).help
      }

      #--- J'attends que la fenetre d'aide soit creee
      update

      if { $relativeFileName != "" } {
         #--- J'affiche le fichier d'aide
         ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(rep_install) \
            $folderRelativeFileName $relativeFileName ] 1 $tag
      } else {
         #--- Si le nom du fichier est absent, j'affiche le sommaire de l'aide
         ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(help_dir) $help(dir,intro) \
            "1010presentation.htm" ] 1 ""
      }

      #--- Focus
      focus $audace(help_window)

   }
   #----------------------------------------------------------------------------------------
   ## @brief  ouvre la fenêtre d'aide si elle n'est pas déjà ouverte
   #  puis affiche la page HTML demandée
   #  @code
   #  ::audace::showHelpItem "$help(dir,images)" "1170kernel.htm" "conv_spatiale"
   #  @endcode
   #  @param folderRelativeFileName nom du répertoire du fichier d'aide
   #  @param relativeFileName  nom court du fichier d'aide
   #  @param tag               balise anchor dans la page HTML (optionel)
   #  @note ne pas rajouter # devant le tag, il est rajouté automatiquement
   #
   proc ::audace::showHelpItem { { folderRelativeFileName "" } { relativeFileName "" } { tag "" } } {
      global audace help

      #--- J'affiche l'aide avec le navigateur selectionne
      if { $::conf(editsite_htm,selectHelp) == "1" } {
         #--- Je prepare le nom du repertoire de l'aide en fonction de la langue
         if { ( $::langage != "french" ) && ( $::langage != "english" ) } {
            set audace(help_langage) "english"
         } else {
            set audace(help_langage) $::langage
         }
         if { $relativeFileName != "" } {
            #--- J'affiche le fichier d'aide avec le navigateur selectionne
            ::audace::Lance_Site_htm [ file join file:///[ file join $audace(rep_doc_html) $audace(help_langage) \
               $folderRelativeFileName $relativeFileName ] ]#$tag
         } else {
            #--- Si le nom du fichier est absent, j'affiche le sommaire de l'aide
            ::audace::Lance_Site_htm [ file join file:///[ file join $audace(rep_doc_html) $audace(help_langage) \
               $help(dir,intro) "1010presentation.htm" ] ]
         }
         return
      }

      #--- J'affiche la fenetre si ce n'est pas deja fait
      if { ! [ info exists audace(help_window) ] || ! [ winfo exists $audace(help_window) ] } {
         ::audace::initHelp
      }

      if { [ winfo exists $audace(base).help ] } {
         wm deiconify $audace(base).help
      }

      #--- J'attends que la fenetre d'aide soit creee
      update

      if { $relativeFileName != "" } {
         #--- J'affiche le fichier d'aide
         ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(rep_doc_html) $audace(help_langage) \
            $folderRelativeFileName $relativeFileName ] 1 $tag
      } else {
         #--- Si le nom du fichier est absent, j'affiche le sommaire de l'aide
         ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(help_dir) $help(dir,intro) \
            "1010presentation.htm" ] 1 ""
      }

      #--- Focus
      focus $audace(help_window)

   }

   #----------------------------------------------------------------------------------------
   ## @brief ouvre la fenêtre d'aide d'un plugin si elle n'est pas déjà ouverte
   #  puis affiche la page HTML demandée
   #  @code
   #  ::audace::showHelpPlugin tool supernovae supernovae.htm
   #  @endcode
   #  @param pluginType        type de plugin
   #  @param pluginName        nom du répertoire du plugin
   #  @param relativeFileName  nom court du fichier d'aide
   #  @param tag               balise anchor dans la page HTML (optionel)
   #  @note ne pas rajouter # devant le tag, il est rajouté automatiquement
   #
   proc ::audace::showHelpPlugin { { pluginType } { pluginName } { relativeFileName "" } { tag "" } } {
      global audace help

      #--- J'affiche l'aide avec le navigateur selectionne
      if { $::conf(editsite_htm,selectHelp) == "1" } {
         #--- Je prepare le nom du repertoire de l'aide en fonction de la langue
         if { ( $::langage != "french" ) && ( $::langage != "english" ) } {
            set audace(help_langage) "english"
         } else {
            set audace(help_langage) $::langage
         }
         #--- Je lance l'aide avec le navigateur selectionne
         if { $relativeFileName != "" } {
            #--- J'affiche le fichier d'aide avec le navigateur selectionne
            ::audace::Lance_Site_htm [ file join file:///[ file join $::audace(rep_plugin) \
               $pluginType $pluginName $::audace(help_langage) $relativeFileName ] ]#$tag
         } else {
            #--- Si le nom du fichier est absent, j'affiche le sommaire de l'aide
            ::audace::Lance_Site_htm [ file join file:///[ file join $audace(rep_doc_html) $audace(help_langage) \
               $help(dir,intro) "1010presentation.htm" ] ]
         }
         return
      }

      #--- J'affiche la fenetre si ce n'est pas deja fait
      if { ! [ info exists audace(help_window) ] || ! [ winfo exists $audace(help_window) ] } {
         ::audace::initHelp
      }

      if { [ winfo exists $audace(base).help ] } {
         wm deiconify $audace(base).help
      }

      #--- J'attends que la fenetre d'aide soit creee
      update

      if { $relativeFileName != "" } {
         #--- J'affiche le fichier d'aide
         ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(rep_plugin) $pluginType $pluginName \
            $audace(help_langage) $relativeFileName ] 1 $tag
      } else {
         #--- Si le nom du fichier est absent, j'affiche le sommaire de l'aide
         ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(help_dir) $help(dir,intro) \
            "1010presentation.htm" ] 1 ""
      }

      #--- Focus
      focus $audace(help_window)

   }

   #----------------------------------------------------------------------------------------
   ## @brief  affiche l'aide d'un script quelconque
   #  @pre le fichier d'aide doit être dans le répertoire
   #  scriptDirectory/langage/xxx.htm
   #  @code
   #  ::audace::showHelpScript $audace(rep_scripts) testaudela.htm
   #  @endcode
   #  @param scriptDirectory nom du répertoire du fichier d'aide
   #  @param relativeFileName nom court du fichier d'aide
   #  @param tag balise anchor dans la page HTML (optionel)
   #  @note ne pas rajouter # devant le tag, il est rajouté automatiquement
   #
   proc ::audace::showHelpScript { scriptDirectory  { relativeFileName "" } { tag "" } } {
      global audace help

      #--- J'affiche l'aide avec le navigateur selectionne
      if { $::conf(editsite_htm,selectHelp) == "1" } {
         #--- Je prepare le nom du repertoire de l'aide en fonction de la langue
         if { ( $::langage != "french" ) && ( $::langage != "english" ) } {
            set audace(help_langage) "english"
         } else {
            set audace(help_langage) $::langage
         }
         #--- Je lance l'aide avec le navigateur selectionne
         if { $relativeFileName != "" } {
            #--- J'affiche le fichier d'aide avec le navigateur selectionne
            ::audace::Lance_Site_htm [ file join file:///[ file join $scriptDirectory \
               $audace(help_langage) $relativeFileName ] ]#$tag
         } else {
            #--- Si le nom du fichier est absent, j'affiche le sommaire de l'aide
            ::audace::Lance_Site_htm [ file join file:///[ file join $audace(rep_doc_html) $audace(help_langage) \
               $help(dir,intro) "1010presentation.htm" ] ]
         }
         return
      }

      #--- J'affiche la fenetre si ce n'est pas deja fait
      if { ! [ info exists audace(help_window) ] || ! [ winfo exists $audace(help_window) ] } {
         ::audace::initHelp
      } else {
         if { [ winfo exists $audace(base).help ] } {
            wm deiconify $audace(base).help
         }
      }

      #--- J'attends que la fenetre d'aide soit creee
      update

      if { $scriptDirectory != "" } {
         #--- J'affiche le fichier d'aide
         ::HelpViewer::LoadFile $audace(help_window) [ file join $scriptDirectory \
            $audace(help_langage) $relativeFileName ] 1 $tag
      } else {
         #--- Si le nom du fichier est absent, j'affiche le sommaire de l'aide
         ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(help_dir) $help(dir,intro) \
            "1010presentation.htm" ] 1 ""
      }

      #--- Focus
      focus $audace(help_window)

   }

   #------------------------------------------------------------
   ## @brief  ouvre la fenêtre du sommaire de l'aide
   #
   proc ::audace::showMain { } {
      global audace help

      #--- J'affiche l'aide avec le navigateur selectionne
      if { $::conf(editsite_htm,selectHelp) == "1" } {
         #--- Je prepare le nom du repertoire de l'aide en fonction de la langue
         if { ( $::langage != "french" ) && ( $::langage != "english" ) } {
            set audace(help_langage) "english"
         } else {
            set audace(help_langage) $::langage
         }
         #--- Je lance l'aide avec le navigateur selectionne
         ::audace::Lance_Site_htm [ file join file:///[ file join $audace(rep_doc_html) $audace(help_langage) \
            $help(dir,intro) "1010presentation.htm" ] ]
         return
      }

      #--- J'affiche la fenetre si ce n'est pas deja fait
      if { ! [ info exists audace(help_window) ] || ! [ winfo exists $audace(help_window) ] } {
         ::audace::initHelp
      }

      if { [ winfo exists $audace(base).help ] } {
         wm deiconify $audace(base).help
      }

      #--- J'attends que la fenetre d'aide soit creee
      update

      ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(help_dir) $help(dir,intro) \
         "1010presentation.htm" ] 1 ""

      #--- Focus
      focus $audace(help_window)

   }

   #------------------------------------------------------------
   ## @brief ouvre la fenêtre de l'inventaire des fonctions
   #
   proc ::audace::showFunctions { } {
      global audace help

      #--- J'affiche l'aide avec le navigateur selectionne
      if { $::conf(editsite_htm,selectHelp) == "1" } {
         #--- Je prepare le nom du repertoire de l'aide en fonction de la langue
         if { ( $::langage != "french" ) && ( $::langage != "english" ) } {
            set audace(help_langage) "english"
         } else {
            set audace(help_langage) $::langage
         }
         #--- Je lance l'aide avec le navigateur selectionne
         ::audace::Lance_Site_htm [ file join file:///[ file join $audace(rep_doc_html) $audace(help_langage) \
            $help(dir,prog) "interfa5c.htm" ] ]
         return
      }

      #--- J'affiche la fenetre si ce n'est pas deja fait
      if { ! [ info exists audace(help_window) ] || ! [ winfo exists $audace(help_window) ] } {
         ::audace::initHelp
      }

      if { [ winfo exists $audace(base).help ] } {
         wm deiconify $audace(base).help
      }

      #--- J'attends que la fenetre d'aide soit creee
      update

      ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(help_dir) $help(dir,prog) "interfa5c.htm" ] 1 ""

      #--- Focus
      focus $audace(help_window)

   }

   #------------------------------------------------------------
   ## @brief ouvre la fenêtre de l'inventaire des pages de programmation
   #
   proc ::audace::showProgramming { } {
      global audace help

      #--- J'affiche l'aide avec le navigateur selectionne
      if { $::conf(editsite_htm,selectHelp) == "1" } {
         #--- Je prepare le nom du repertoire de l'aide en fonction de la langue
         if { ( $::langage != "french" ) && ( $::langage != "english" ) } {
            set audace(help_langage) "english"
         } else {
            set audace(help_langage) $::langage
         }
         #--- Je lance l'aide avec le navigateur selectionne
         ::audace::Lance_Site_htm [ file join file:///[ file join $audace(rep_doc_html) $audace(help_langage) \
            $help(dir,prog) "1000programmation.htm" ] ]
         return
      }

      #--- J'affiche la fenetre si ce n'est pas deja fait
      if { ! [ info exists audace(help_window) ] || ! [ winfo exists $audace(help_window) ] } {
         ::audace::initHelp
      }

      if { [ winfo exists $audace(base).help ] } {
         wm deiconify $audace(base).help
      }

      #--- J'attends que la fenetre d'aide soit creee
      update

      ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(help_dir) $help(dir,prog) "1000programmation.htm" ] 1 ""

      #--- Focus
      focus $audace(help_window)

   }

   #------------------------------------------------------------
   ## @brief  ouvre la fenêtre de l'inventaire des menus
   #
   proc ::audace::showMenus { } {
      global audace help

      #--- J'affiche l'aide avec le navigateur selectionne
      if { $::conf(editsite_htm,selectHelp) == "1" } {
         #--- Je prepare le nom du repertoire de l'aide en fonction de la langue
         if { ( $::langage != "french" ) && ( $::langage != "english" ) } {
            set audace(help_langage) "english"
         } else {
            set audace(help_langage) $::langage
         }
         #--- Je lance l'aide avec le navigateur selectionne
         ::audace::Lance_Site_htm [ file join file:///[ file join $audace(rep_doc_html) $audace(help_langage) \
            $help(dir,aide) "1020menus.htm" ] ]
         return
      }

      #--- J'affiche la fenetre si ce n'est pas deja fait
      if { ! [ info exists audace(help_window) ] || ! [ winfo exists $audace(help_window) ] } {
         ::audace::initHelp
      }

      if { [ winfo exists $audace(base).help ] } {
         wm deiconify $audace(base).help
      }

      #--- J'attends que la fenetre d'aide soit creee
      update

      ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(help_dir) $help(dir,aide) "1020menus.htm" ] 1 ""

      #--- Focus
      focus $audace(help_window)

   }

   #------------------------------------------------------------
   ## @brief  ouvre les tutoriels de type html
   #
   proc ::audace::showTutorials { tutorial } {
      global audace help

      #--- J'affiche l'aide avec le navigateur selectionne
      if { $::conf(editsite_htm,selectHelp) == "1" } {
         #--- Je prepare le nom du repertoire de l'aide en fonction de la langue
         if { ( $::langage != "french" ) && ( $::langage != "english" ) } {
            set audace(help_langage) "english"
         } else {
            set audace(help_langage) $::langage
         }
         #--- Je lance l'aide avec le navigateur selectionne
         ::audace::Lance_Site_htm [ file join file:///[ file join $audace(rep_doc_html) $audace(help_langage) \
            $help(dir,tutoriel) "$tutorial" ] ]
         return
      }

      #--- J'affiche la fenetre si ce n'est pas deja fait
      if { ! [ info exists audace(help_window) ] || ! [ winfo exists $audace(help_window) ] } {
         ::audace::initHelp
      }

      if { [ winfo exists $audace(base).help ] } {
         wm deiconify $audace(base).help
      }

      #--- J'attends que la fenetre d'aide soit creee
      update

      ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(help_dir) $help(dir,tutoriel) "$tutorial" ] 1 ""

      #--- Focus
     focus $audace(help_window)

   }

   #------------------------------------------------------------
   #  ::audace::initHelp
   ## @brief initalise l'accès au répertoire d'aide
   #  et créé les variables audace(help_dir) et audace(help_window)
   #
   proc ::audace::initHelp { } {
      global audace caption langage

      #--- Je verifie que les packages necessaires sont la
      package require helpviewer

      #--- Je prepare le nom du repertoire de l'aide en fonction de la langue
      if { ( $langage != "french" ) && ( $langage != "english" ) } {
         set audace(help_langage) "english"
      } else {
         set audace(help_langage) $langage
      }
      set audace(help_dir) [ file join $audace(rep_doc_html) $audace(help_langage) ]

      if { ! [ file exists $audace(help_dir) ] } {
         set message "$caption(audace,pas_repertoire_aide)\n$audace(help_dir)"
         ::console::affiche_erreur "$message \n"
         tk_messageBox -icon error -message $message -type ok
         return
      }

      #--- Je cree la fenetre d'aide
      set audace(help_window) [ ::HelpViewer::HelpWindow $audace(help_dir) "$audace(base).help" \
         "630x450+100+50" "$caption(audace,aide)" ]

      #--- J'attends que la fenetre d'aide soit creee
      update

      #--- Focus
      focus $audace(help_window)

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $audace(base).help <Key-F1> { ::console::GiveFocus }

   }

}

