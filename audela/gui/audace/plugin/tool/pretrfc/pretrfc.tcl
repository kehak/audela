#
# Fichier : pretrfc.tcl
# Description : Outil pour le pretraitement automatique
# Auteurs : Francois COCHARD et Jacques MICHELET
# Mise à jour $Id: pretrfc.tcl 12648 2016-01-14 18:19:02Z robertdelmas $
#

#============================================================
# Declaration du namespace pretrfc
#    initialise le namespace
#============================================================
namespace eval ::pretrfc {

   #--- Chargement du package
   package provide pretrfc 1.40

   #--- Chargement des captions pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] pretrfc.cap ]

#***** Procedure DemarragePretraitFC *********************************
   proc DemarragePretraitFC { } {
      global audace caption panneau

      #--- Lecture du fichier de configuration
      ::pretrfc::RecuperationParametres

      #--- Initialisation des variables de la boite de configuration
      ::pretrfcSetup::confToWidget

      #--- Ouverture du fichier historique
      if { $panneau(pretrfc,save_file_log) == "1" } {
         if { $panneau(pretrfc,session_ouverture) == "1" } {
            #--- Gestion du fichier de log
            #--- Creation du nom de fichier log
            set nom_generique "pretrfc-"
            #--- Heure a partir de laquelle on passe sur un nouveau fichier de log
            if { $::conf(rep_images,refModeAuto) == "0" } {
               set heure_nouveau_fichier "0"
            } else {
               set heure_nouveau_fichier "12"
            }
            set heure_courante [lindex [split $audace(tu,format,hmsint) h] 0]
            if {$heure_courante < $heure_nouveau_fichier} {
               #--- Si avant l'heure de changement... Je prends la date de la veille
               set formatdate [clock format [expr {[clock seconds] - 86400}] -format "%Y-%m-%d"]
            } else {
               #--- Sinon, je prends la date du jour
               set formatdate [clock format [clock seconds] -format "%Y-%m-%d"]
            }
            set ::pretrfc::fichier_log [ file join $audace(rep_images) "$nom_generique$formatdate.log" ]

            #--- Ouverture
            if {[catch {open $::pretrfc::fichier_log a} ::pretrfc::log_id]} {
               Message console $caption(pretrfc,pbouvfichcons)
               tk_messageBox -title $caption(pretrfc,pb) -type ok \
                  -message $caption(pretrfc,pbouvfich)
               #--- Note importante: Je detecte si j'ai un pb a l'ouverture du fichier, mais je ne sais pas traiter ce cas :
               #--- Il faudrait interdire l'ouverture du panneau, mais le processus est deja lance a ce stade...
               #--- Tout ce que je fais, c'est inviter l'utilisateur a changer d'outil !
            } else {
               #--- En-tete du fichier
               Message log $caption(pretrfc,ouvsess) [ package version pretrfc ]
               set date [clock format [clock seconds] -format "%A %d %B %Y"]
               set date [ ::tkutil::transalteDate $date ]
               set heure $audace(tu,format,hmsint)
               Message consolog $caption(pretrfc,affheure) $date $heure
            }
            #--- Re-initialisation
            set panneau(pretrfc,session_ouverture) "0"
         }
      }
   }
#***** Fin de la procedure DemarragePretraitFC ***********************

#***** Procedure ArretPretraitFC *************************************
   proc ArretPretraitFC { } {
      variable This
      global audace caption conf_pt_fc panneau

      #--- Fermeture du fichier de log
      if { [ info exists ::pretrfc::log_id ] } {
         set heure $audace(tu,format,hmsint)
         #--- Je m'assure que le fichier se termine correctement, en particulier pour le cas ou il y
         #--- a eu un probleme a l'ouverture (C'est un peu une rustine...)
         if { [ catch { Message log $caption(pretrfc,finsess) $heure } bug ] } {
            Message console $caption(pretrfc,pbfermfichcons)
         } else {
            close $::pretrfc::log_id
            unset ::pretrfc::log_id
         }
      }

      #--- Re-initialisation de la session
      set panneau(pretrfc,session_ouverture) "1"
      #--- Recuperation de la position de la fenetre de reglages
      ::pretrfc::recup_position
      set conf_pt_fc(position) $panneau(pretrfc,position)
      #--- Sauvegarde des parametres dans le fichier de config
      ::pretrfc::SauvegardeParametres
      #--- Fermeture de la fenetre de pretraitement
      destroy $This
   }
#***** Fin de la procedure ArretPretraitFC ***************************

#***** Procedure getPluginTitle***************************************
   proc getPluginTitle { } {
      global caption

      return "$caption(pretrfc,menu)"
   }
#***** Fin de la procedure getPluginTitle ****************************

#***** Procedure getPluginHelp****************************************
proc getPluginHelp { } {
   return "pretrfc.htm"
}
#***** Fin de la procedure getPluginHelp *****************************

#***** Procedure getPluginType****************************************
   proc getPluginType { } {
      return "tool"
   }
#***** Fin de la procedure getPluginType******************************

#***** Procedure getPluginDirectory***********************************
   proc getPluginDirectory { } {
      return "pretrfc"
   }
#***** Fin de la procedure getPluginDirectory*************************

#***** Procedure getPluginOS******************************************
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
   }
#***** Fin de la procedure getPluginOS********************************

#***** Procedure getPluginProperty************************************
   proc getPluginProperty { propertyName } {
      switch $propertyName {
         function     { return "images" }
         subfunction1 { return "" }
         display      { return "window" }
      }
   }
#***** Fin de la procedure getPluginProperty**************************

#***** Procedure createPluginInstance ********************************
   proc createPluginInstance { base { visuNo 1 } } {
      variable This
      global audace panneau

      #--- Chargement des fichiers auxiliaires
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool pretrfc pretrfcSetup.tcl ]\""

      #--- Initialisation
      set panneau(pretrfc,session_ouverture) "1"

      #--- Inititalisation du nom de la fenetre
      set This "$base.fenetrePretr"

      #--- J'ouvre la fenetre
      ::pretrfc::fenetrePretr

      #---
      return $This
   }
#***** Fin de la procedure createPluginInstance **********************

#***** Procedure deletePluginInstance ********************************
   proc deletePluginInstance { visuNo } {
      variable This

      if { [winfo exists $This] ==1} {
         #--- je ferme la fenetre si l'utilisateur ne l'a pas deja fait
         ::pretrfc::ArretPretraitFC
      }
   }
#***** Fin de la procedure deletePluginInstance **********************

#***** Procedure recup_position **************************************
   proc recup_position { } {
      variable This
      global panneau

      set panneau(pretrfc,geometry) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $panneau(pretrfc,geometry) ] ]
      set fin [ string length $panneau(pretrfc,geometry) ]
      set panneau(pretrfc,position) "+[string range $panneau(pretrfc,geometry) $deb $fin]"
   }
#***** Fin de la procedure recup_position ****************************

#***** Procedure fenetrePretr ****************************************
   proc fenetrePretr { } {
      variable This
      global caption conf_pt_fc panneau

      DemarragePretraitFC

      #---
      if { ! [ info exists conf_pt_fc(position) ] } { set conf_pt_fc(position) "+100+5" }

      set panneau(pretrfc,position) $conf_pt_fc(position)

      if { [ info exists panneau(pretrfc,geometry) ] } {
         set deb [ expr 1 + [ string first + $panneau(pretrfc,geometry) ] ]
         set fin [ string length $panneau(pretrfc,geometry) ]
         set panneau(pretrfc,position) "+[string range $panneau(pretrfc,geometry) $deb $fin]"
      }

      #---
      toplevel $This -class Toplevel -borderwidth 2 -relief groove
      wm geometry $This $panneau(pretrfc,position)
      wm resizable $This 1 1
      wm title $This $caption(pretrfc,menu)

      wm protocol $This WM_DELETE_WINDOW ::pretrfc::ArretPretraitFC

      creeFenetrePrFC $This
   }
#***** Fin de la procedure fenetrePretr ******************************

#***** Procedure RecuperationParametres ******************************
   proc RecuperationParametres { } {
      global conf_pt_fc

      #--- Initialisation
      if {[info exists conf_pt_fc]} {unset conf_pt_fc}
      #--- Ouverture du fichier de parametres
      set fichier [file join $::audace(rep_home) pretrfc.ini]
      if {[file exists $fichier]} {source $fichier}
      #--- Creation des variables si elles n'existent pas
      if { ! [ info exists conf_pt_fc(nbPLU) ]  }          { set conf_pt_fc(nbPLU)           "5" }
      if { ! [ info exists conf_pt_fc(nbNrPLU) ] }         { set conf_pt_fc(nbNrPLU)         "5" }
      if { ! [ info exists conf_pt_fc(modeBrut) ] }        { set conf_pt_fc(modeBrut)        "simple" }
      if { ! [ info exists conf_pt_fc(nmBrutRes) ] }       { set conf_pt_fc(nmBrutRes)       "objet_result" }
      if { ! [ info exists conf_pt_fc(cosmNoir) ] }        { set conf_pt_fc(cosmNoir)        "1" }
      if { ! [ info exists conf_pt_fc(nmBrutSce) ] }       { set conf_pt_fc(nmBrutSce)       "objet" }
      if { ! [ info exists conf_pt_fc(cosmPLU) ] }         { set conf_pt_fc(cosmPLU)         "1" }
      if { ! [ info exists conf_pt_fc(cosmNrPLU) ] }       { set conf_pt_fc(cosmNrPLU)       "1" }
      if { ! [ info exists conf_pt_fc(nbNoirs) ] }         { set conf_pt_fc(nbNoirs)         "5" }
      if { ! [ info exists conf_pt_fc(nbBrut) ] }          { set conf_pt_fc(nbBrut)          "5" }
      if { ! [ info exists conf_pt_fc(nmNoirRes) ] }       { set conf_pt_fc(nmNoirRes)       "noir30s_result" }
      if { ! [ info exists conf_pt_fc(modePLU) ] }         { set conf_pt_fc(modePLU)         "simple" }
      if { ! [ info exists conf_pt_fc(nmNrSce) ] }         { set conf_pt_fc(nmNrSce)         "noir30s" }
      if { ! [ info exists conf_pt_fc(filtrage) ] }        { set conf_pt_fc(filtrage)        "1" }
      if { ! [ info exists conf_pt_fc(nmNrPLURes) ] }      { set conf_pt_fc(nmNrPLURes)      "noir25s_result" }
      if { ! [ info exists conf_pt_fc(nmPLURes) ] }        { set conf_pt_fc(nmPLURes)        "flat_result" }
      if { ! [ info exists conf_pt_fc(nmPrechRes) ] }      { set conf_pt_fc(nmPrechRes)      "offset_result" }
      if { ! [ info exists conf_pt_fc(nmNrPLUSce) ] }      { set conf_pt_fc(nmNrPLUSce)      "noir25s" }
      if { ! [ info exists conf_pt_fc(nmPLUSce) ] }        { set conf_pt_fc(nmPLUSce)        "flat" }
      if { ! [ info exists conf_pt_fc(cosmBrut) ] }        { set conf_pt_fc(cosmBrut)        "1" }
      if { ! [ info exists conf_pt_fc(nmPrechSce) ] }      { set conf_pt_fc(nmPrechSce)      "offset" }
      if { ! [ info exists conf_pt_fc(medFiltree) ] }      { set conf_pt_fc(medFiltree)      "0" }
      if { ! [ info exists conf_pt_fc(nbPrech) ] }         { set conf_pt_fc(nbPrech)         "7" }
      if { ! [ info exists conf_pt_fc(procCorr) ] }        { set conf_pt_fc(procCorr)        "corrige" }
      if { ! [ info exists conf_pt_fc(cosmPrech) ] }       { set conf_pt_fc(cosmPrech)       "1" }
      if { ! [ info exists conf_pt_fc(NrContientPrech) ] } { set conf_pt_fc(NrContientPrech) "1" }
      if { ! [ info exists conf_pt_fc(FichScript) ] }      { set conf_pt_fc(FichScript)      "correction" }
      #--- Creation des variables de la boite de configuration si elles n'existent pas
      ::pretrfcSetup::initToConf
   }
#***** Fin de la procedure RecuperationParametres ********************

#***** Procedure SauvegardeParametres ********************************
    proc SauvegardeParametres { } {
       global caption conf_pt_fc

       catch {
          set nom_fichier [file join $::audace(rep_home) pretrfc.ini]
          if [catch {open $nom_fichier w} fichier] {
             Message console "%s\n" $caption(pretrfc,PbSauveConfig)
          } else {
             foreach {a b} [array get conf_pt_fc] {
                puts $fichier "set conf_pt_fc($a) \"$b\""
             }
             close $fichier
          }
       }
    }
#***** Fin de la procedure SauvegardeParametres **********************

#***** Procedure rechargeCosm ****************************************
   proc rechargeCosm { } {
      #--- Cette procedure a pour fonction de recharger le script de correction
      #---    cosmetique (pour permettre a l'utilisateur de faire du debug sans
      #---    sortir de Audela !
      global audace caption conf_pt_fc

      #--- Verifie validite du nom du fichier de script
      if {[TestNomFichier $conf_pt_fc(FichScript)] == 0} {
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomFichScr)
      } else {
         #--- Teste si le fichier de script existe
         set nomFich [ file join $audace(rep_scripts) "$conf_pt_fc(FichScript).tcl" ]
         if {[file exists $nomFich] == 0} {
            set integre(cosm) non
            tk_messageBox -title $caption(pretrfc,pb) -type ok \
               -message $caption(pretrfc,FichScrAbs)
         } else {
            #--- Alors dans ce cas, je charge le fichier
            source $nomFich
         }
      }
   }
#***** Fin de la procedure rechargeCosm ******************************

#***** Procedure goCosm***********************************************
   proc goCosm { } {
      global integre

      #--- Dans un premier temps, je teste l'integrite de l'operation
      testCosm
      #--- Si tout est Ok, je lance le traitement
      if {$integre(cosm) == "oui"} {
         traiteCosm
      }
   }
#***** Fin de la procedure goCosm*************************************

#***** Procedure testCosm*********************************************
   proc testCosm { } {
      global audace caption conf_pt_fc integre

      desactiveBoutons
      set integre(cosm) oui

      if {[TestNomFichier $conf_pt_fc(procCorr)] == 0} {
         #--- Teste si le nom de la procedure est Ok (un seul champ, pas de caractere interdit...)
         set integre(cosm) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbProcCorr)
      } elseif {[info procs $conf_pt_fc(procCorr)] == ""} {
         #--- Teste si la procedure de correction cosmetique existe
         #--- Alors je dois regarder si j'ai de quoi charger le fichier contenant le script
         #--- Teste si le nom de fichier est Ok (un seul champ, pas de caractere interdit...)
         if {[TestNomFichier $conf_pt_fc(FichScript)] == 0} {
            set integre(cosm) non
            tk_messageBox -title $caption(pretrfc,pb) -type ok \
               -message $caption(pretrfc,pbNomFichScr)
         } else {
            #--- Teste si le fichier de script existe
            set nomFich [ file join $audace(rep_scripts) "$conf_pt_fc(FichScript).tcl" ]
            if {[file exists $nomFich] == 0} {
               set integre(cosm) non
               tk_messageBox -title $caption(pretrfc,pb) -type ok \
                  -message $caption(pretrfc,FichScrAbs)
            } else {
               #--- Alors dans ce cas, je charge le fichier
               source $nomFich
               #--- et je me repose la question de l'existence de la procedure:
               if {[info procs $conf_pt_fc(procCorr)] == ""} {
                  tk_messageBox -title $caption(pretrfc,pb) -type ok \
                     -message $caption(pretrfc,procCorrIntrouv)
                  set integre(cosm) non
               }
            }
         }
      }
      activeBoutons
   }
#***** Fin de la procedure testCosm***********************************

#***** Procedure traiteCosm*******************************************
   proc traiteCosm { } {
      global conf_pt_fc

      desactiveBoutons
      #--- Applique la procedure de correction cosmetique a l'image en cours
      eval $conf_pt_fc(procCorr)
      activeBoutons
   }
#***** Fin de la procedure traiteCosm*********************************

#***** Procedure goPrecharge *****************************************
   proc goPrecharge { } {
      global integre

      #--- Dans un premier temps, je teste l'integrite de l'operation
      testPrecharge
      #--- Si tout est Ok, je lance le traitement
      if {$integre(precharge) == "oui"} {
         traitePrecharge
      }
   }
#***** Fin de la procedure goPrecharge *******************************

#***** Procedure testPrecharge ***************************************
   proc testPrecharge { } {
      global audace caption conf_pt_fc integre

      #--- Initialisation du drapeau d'integrite
      set integre(precharge) oui

      #--- Enregistrement de l'extension des fichiers
      set ext $::conf(extension,defaut)

      #--- Je commence par regarder si la correction cosmetique est demandee...
      if {$conf_pt_fc(cosmPrech) == 1} {
         #--- Alors je teste si la definition de la correction cosmetique est Ok
         testCosm
         if {$integre(cosm) != "oui"} {
            set integre(precharge) non
            return
         }
      }

       desactiveBoutons

      #--- Teste si le nom de fichier source est Ok (un seul champ, pas de caractere interdit...)
      if {[TestNomFichier $conf_pt_fc(nmPrechSce)] == 0} {
         set integre(precharge) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomPrechSrce)
      } elseif {[TestNomFichier $conf_pt_fc(nmPrechRes)] == 0} {
         #--- Teste si le nom de fichier resultant est Ok (un seul champ, pas de caractere interdit...)
         set integre(noir) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomPrechRes)
      } elseif {[TestEntier $conf_pt_fc(nbPrech)] == 0} {
         #--- Teste si le nombre est Ok
         set integre(precharge) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNbPrech)
      } else {
         #--- Teste si les fichiers sources existent
         for {set i 1} {$i <= $conf_pt_fc(nbPrech)} {incr i} {
            set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmPrechSce)$i$ext" ]
            if {[file exists $nomFich] == 0} {
               set integre(precharge) non
            }
         }
         if {$integre(precharge) == "non"} {
            tk_messageBox -title $caption(pretrfc,pb) -type ok \
               -message $caption(pretrfc,fichPrechAbs)
         } else {
            #--- Teste si le fichier resultant existe deja
            set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmPrechRes)$ext" ]
            if {[file exists $nomFich] == 1} {
               set confirmation [tk_messageBox -title $caption(pretrfc,conf) -type yesno \
                  -message $caption(pretrfc,fichPrechResDeja)]
               if {$confirmation == "no" } {
                  set integre(precharge) non
                  activeBoutons
                  return
               }
            }
            #--- Dans le cas ou le filtrage est demande, je verifie que le nb est valide
            if {$conf_pt_fc(medFiltree) == 1} {
               if {[TestEntier $conf_pt_fc(filtrage)] == 0} {
                  tk_messageBox -title $caption(pretrfc,pb) -type ok \
                     -message $caption(pretrfc,pbNbFiltrage)
                  set integre(precharge) non
               }
            }
         }
      }
      activeBoutons
   }
#***** Fin de la procedure testPrecharge *****************************

#***** Procedure traitePrecharge *************************************
   proc traitePrecharge { } {
      variable This
      global audace caption conf_pt_fc

      desactiveBoutons
      #--- Affichage du message de demarrage du pretraitement des noirs
      Message consolog $caption(pretrfc,debPrech)

      #--- Enregistrement de l'extension des fichiers
      set ext $::conf(extension,defaut)

      if {$conf_pt_fc(cosmPrech) == 1} {
         #--- Dans le cas ou la correction cosmetique est demandee
         Message consolog $caption(pretrfc,lanceCosmPrech)
         for {set i 1} {$i <= $conf_pt_fc(nbPrech)} {incr i} {
            set instr "loadima $conf_pt_fc(nmPrechSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "eval $conf_pt_fc(procCorr)"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "saveima $conf_pt_fc(nmPrechSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
         }
      }
      #--- Affichage de la premiere image de noir
      set nomFich $conf_pt_fc(nmPrechSce)
      append nomFich "1"
      Message consolog $caption(pretrfc,chargPremPrech)
      set instr "loadima "
      append instr $nomFich
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      #--- Calcul de la mediane des images
      set instr "smedian $conf_pt_fc(nmPrechSce) $conf_pt_fc(nmPrechRes) $conf_pt_fc(nbPrech)"
      Message consolog $caption(pretrfc,CalcMedPrech)
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      #--- Operation eventuelle de filtrage
      if {$conf_pt_fc(medFiltree) == 1} {
         Message consolog $caption(pretrfc,filtrage)
         set taille $conf_pt_fc(filtrage)
         set instr "ttscript2 \{IMA/SERIES \"$audace(rep_images)\" \"$conf_pt_fc(nmPrechRes)\" . . \"$ext\" \
            \"$audace(rep_images)\" \"$conf_pt_fc(nmPrechRes)\" . \"$ext\" FILTER threshold=0 type_threshold=0 \
            kernel_width=$taille kernel_type=fb kernel_coef=0 nullpixel=-5000\}"
         Message consolog $instr
         Message consolog "\n"
         eval $instr
      }

      #--- Affichage de l'image de precharge resultante
      set nomFich $conf_pt_fc(nmPrechRes)
      Message consolog $caption(pretrfc,chargPrechRes)
      set instr "loadima $nomFich"
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      #--- Affichage du message de fin du pretraitement de la precharge
      Message consolog $caption(pretrfc,finPrech)

      activeBoutons
      focus $This
   }
#***** Fin de la procedure traitePrecharge ***************************

#***** Procedure goNoir **********************************************
   proc goNoir { } {
      global integre

      #--- Dans un premier temps, je teste l'integrite de l'operation
      testNoir
      #--- Si tout est Ok, je lance le traitement
      if {$integre(noir) == "oui"} {
         traiteNoir
      }
   }
#***** Fin de la procedure goNoir ************************************

#***** Procedure testNoir ********************************************
   proc testNoir { } {
      global audace caption conf_pt_fc integre

      #--- Initialisation du drapeau d'integrite
      set integre(noir) oui

      #--- Enregistrement de l'extension des fichiers
      set ext $::conf(extension,defaut)

      #--- Je commence par regarder si la correction cosmetique est demandee...
      if {$conf_pt_fc(cosmNoir) == 1} {
         #--- Alors je teste si la definition de la correction cosmetique est Ok
         testCosm
         if {$integre(cosm) != "oui"} {
            set integre(noir) non
            return
         }
      }

      desactiveBoutons

      #--- Teste si le nom de fichier source est Ok (un seul champ, pas de caractere interdit...)
      if {[TestNomFichier $conf_pt_fc(nmNrSce)] == 0} {
         set integre(noir) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomNoirSrce)
      } elseif {[TestNomFichier $conf_pt_fc(nmNoirRes)] == 0} {
         #--- Teste si le nom de fichier resultant est Ok (un seul champ, pas de caractere interdit...)
         set integre(noir) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomNoirRes)
      } elseif {[TestEntier $conf_pt_fc(nbNoirs)] == 0} {
         #--- Teste si le nombre est Ok
         set integre(noir) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNbNr)
      } else {
         #--- Teste si les fichiers sources existent
         for {set i 1} {$i <= $conf_pt_fc(nbNoirs)} {incr i} {
            set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmNrSce)$i$ext" ]
            if {[file exists $nomFich] == 0} {
               set integre(noir) non
            }
         }
         if {$integre(noir) == "non"} {
            tk_messageBox -title $caption(pretrfc,pb) -type ok \
               -message $caption(pretrfc,fichNoirAbs)
         } else {
            #--- Teste si le fichier resultant existe deja
            set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmNoirRes)$ext" ]
            if {[file exists $nomFich] == 1} {
               set confirmation [tk_messageBox -title $caption(pretrfc,conf) -type yesno \
                  -message $caption(pretrfc,fichNoirResDeja)]
               if {$confirmation == "no" } {
                  set integre(noir) non
               }
            }
         }
      }
      activeBoutons
   }
#***** Fin de la procedure testNoir **********************************

#***** Procedure traiteNoir ******************************************
   proc traiteNoir { } {
      variable This
      global caption conf_pt_fc

      desactiveBoutons
      #--- Affichage du message de demarrage du pretraitement des noirs
      Message consolog $caption(pretrfc,debNoir)

      if {$conf_pt_fc(cosmNoir) == 1} {
         #--- Dans le cas ou la correction cosmetique est demandee
         Message consolog $caption(pretrfc,lanceCosmNoir)
         for {set i 1} {$i <= $conf_pt_fc(nbNoirs)} {incr i} {
            set instr "loadima $conf_pt_fc(nmNrSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "eval $conf_pt_fc(procCorr)"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "saveima $conf_pt_fc(nmNrSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
         }
      }
      #--- Affichage de la premiere image de noir
      set nomFich $conf_pt_fc(nmNrSce)
      append nomFich "1"
      Message consolog $caption(pretrfc,chargPremNoir)
      set instr "loadima "
      append instr $nomFich
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      #--- Calcul de la mediane des images
      set instr "smedian $conf_pt_fc(nmNrSce) $conf_pt_fc(nmNoirRes) $conf_pt_fc(nbNoirs)"
      Message consolog $caption(pretrfc,CalcMedNoir)
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      #--- Affichage de l'image noire resultante
      set nomFich $conf_pt_fc(nmNoirRes)
      Message consolog $caption(pretrfc,chargNoirRes)
      set instr "loadima $nomFich"
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      #--- Affichage du message de fin du pretraitement des noirs
      Message consolog $caption(pretrfc,finNoir)

      activeBoutons
      focus $This
   }
#***** Fin de la procedure traiteNoir ********************************

#***** Procedure goNoirDePLU *****************************************
   proc goNoirDePLU { } {
      global integre

      #--- Dans un premier temps, je teste l'integrite de l'operation
      testNoirDePLU
      #--- Si tout est Ok, je lance le traitement
      if {$integre(noir_PLU) == "oui"} {
         traiteNoirDePLU
      }
   }
#***** Fin de la procedure goNoirDePLU *******************************

#***** Procedure testNoirDePLU ***************************************
   proc testNoirDePLU { } {
      global audace caption conf_pt_fc integre

      #--- Initialisation du drapeau d'integrite
      set integre(noir_PLU) oui

      #--- Enregistrement de l'extension des fichiers
      set ext $::conf(extension,defaut)

      #--- Je commence par regarder si la correction cosmetique est demandee...
      if {$conf_pt_fc(cosmNrPLU) == 1} {
         #--- Alors je teste si la definition de la correction cosmetique est Ok
         testCosm
         if {$integre(cosm) != "oui"} {
            set integre(noir_PLU) non
            return
         }
      }

      desactiveBoutons

      #--- Teste si le nom de fichier source est Ok (un seul champ, pas de caractere interdit...)
      if {[TestNomFichier $conf_pt_fc(nmNrPLUSce)] == 0} {
         set integre(noir_PLU) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomNrPLUSrce)
      } elseif {[TestNomFichier $conf_pt_fc(nmNrPLURes)] == 0} {
         #--- Teste si le nom de fichier resultant est Ok (un seul champ, pas de caractere interdit...)
         set integre(noir_PLU) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomNrPLURes)
      } elseif {[TestEntier $conf_pt_fc(nbNrPLU)] == 0} {
         #--- Teste si le nombre est Ok
         set integre(noir_PLU) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNbNrPLU)
      } else {
         #--- Teste si les fichiers sources existent
         for {set i 1} {$i <= $conf_pt_fc(nbNrPLU)} {incr i} {
            set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmNrPLUSce)$i$ext" ]
            if {[file exists $nomFich] == 0} {
               set integre(noir_PLU) non
            }
         }
         if {$integre(noir_PLU) == "non"} {
            tk_messageBox -title $caption(pretrfc,pb) -type ok \
               -message $caption(pretrfc,fichNrPLUAbs)
         } else {
            #--- Teste si le fichier resultant existe deja
            set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmNrPLURes)$ext" ]
            if {[file exists $nomFich] == 1} {
               set confirmation [tk_messageBox -title $caption(pretrfc,conf) -type yesno \
                  -message $caption(pretrfc,fichNrPLUResDeja)]
               if {$confirmation == "no" } {
                  set integre(noir_PLU) non
               }
            }
         }
      }
      activeBoutons
   }
#***** Fin de la procedure testNoirDePLU *****************************

#***** Procedure traiteNoirDePLU *************************************
   proc traiteNoirDePLU { } {
      variable This
      global caption conf_pt_fc

      desactiveBoutons
      #--- Affichage du message de demarrage du pretraitement des noir de PLU
      Message consolog $caption(pretrfc,debNrPLU)

      if {$conf_pt_fc(cosmNrPLU) == 1} {
         #--- Dans le cas ou la correction cosmetique est demandee
         Message consolog $caption(pretrfc,cosmNoirDePLU)
         for {set i 1} {$i <= $conf_pt_fc(nbNrPLU)} {incr i} {
            set instr "loadima $conf_pt_fc(nmNrPLUSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "eval $conf_pt_fc(procCorr)"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "saveima $conf_pt_fc(nmNrPLUSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
         }
      }

      #--- Affichage de la premiere image de noir de PLU
      set nomFich $conf_pt_fc(nmNrPLUSce)
      append nomFich "1"
      Message consolog $caption(pretrfc,chargPremNrPLU)
      set instr "loadima $nomFich"
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      #--- Calcul de la mediane des images
      set instr "smedian $conf_pt_fc(nmNrPLUSce) $conf_pt_fc(nmNrPLURes) $conf_pt_fc(nbNrPLU)"
      Message consolog $caption(pretrfc,CalcMedNrPLU)
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      #--- Affichage de l'image de noir de PLU resultante
      set nomFich $conf_pt_fc(nmNrPLURes)
      Message consolog $caption(pretrfc,chargNrPLURes)
      set instr "loadima $nomFich"
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      #--- Affichage du fin de demarrage du pretraitement des noirs de PLU
      Message consolog $caption(pretrfc,finNrPLU)
      activeBoutons
      focus $This
   }
#***** Fin de la procedure traiteNoirDePLU ***************************

#***** Procedure goPLU ***********************************************
   proc goPLU { } {
      global integre

      #--- Dans un premier temps, je teste l'integrite de l'operation
      testPLU
      #--- Si tout est Ok, je lance le traitement
      if {$integre(PLU) == "oui"} {
         traitePLU
      }
   }
#***** Fin de la procedure goPLU *************************************

#***** Procedure testPLU *********************************************
   proc testPLU { } {
      global audace caption conf_pt_fc integre

      #--- Initialisation du drapeau d'integrite
      set integre(PLU) oui

      #--- Enregistrement de l'extension des fichiers
      set ext $::conf(extension,defaut)

      #--- Je commence par regarder si la correction cosmetique est demandee...
      if {$conf_pt_fc(cosmPLU) == 1} {
         #--- Alors je teste si la definition de la correction cosmetique est Ok
         testCosm
         if {$integre(cosm) != "oui"} {
            set integre(PLU) non
            return
         }
      }
      desactiveBoutons
      set conf_pt_fc(fich_pour_PLU_ok) non
      set conf_pt_fc(noir_de_PLU_a_faire_pl) non
      set conf_pt_fc(precharge_a_faire_pl) non
      set conf_pt_fc(noir_a_faire_pl) non

      #--- Teste si le nom de fichier source est Ok (un seul champ, pas de caractere interdit...)
      if {[TestNomFichier $conf_pt_fc(nmPLUSce)] == 0} {
         set integre(PLU) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomPLUSrce)
      } elseif {[TestNomFichier $conf_pt_fc(nmPLURes)] == 0} {
         #--- Teste si le nom de fichier resultant est Ok (un seul champ, pas de caractere interdit...)
         set integre(PLU) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomPLURes)
      } elseif {[TestEntier $conf_pt_fc(nbPLU)] == 0} {
         #--- Teste si le nombre est Ok
         set integre(PLU) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNbPLU)
      } else {
         #--- Teste si les fichiers sources existent
         for {set i 1} {$i <= $conf_pt_fc(nbPLU)} {incr i} {
            set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmPLUSce)$i$ext" ]
            if {[file exists $nomFich] == 0} {
               set integre(PLU) non
            }
         }
         if {$integre(PLU) == "non"} {
            tk_messageBox -title $caption(pretrfc,pb) -type ok \
               -message $caption(pretrfc,fichPLUAbs)
         } else {
            #--- Teste si le fichier resultant existe deja
            set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmPLURes)$ext" ]
            if {[file exists $nomFich] == 1} {
               set confirmation [tk_messageBox -title $caption(pretrfc,conf) -type yesno \
                  -message $caption(pretrfc,fichPLUResDeja)]
               if {$confirmation == "no"} {
                  set integre(PLU) non
                  activeBoutons
                  return
               }
            }
            if {$conf_pt_fc(modePLU) == "simple"} {
               #--- A partir de la, c'est selon le mode de traitement de la PLU retenue
               #--- Teste si le fichier de noir de PLU existe bien
               set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmNrPLURes)$ext" ]
               if {[file exists $nomFich] == 0} {
                  testNoirDePLU
                  if {$integre(noir_PLU) == "non"} {
                     tk_messageBox -title $caption(pretrfc,pb) -type ok \
                        -message $caption(pretrfc,fichNrPLUPLUAbs)
                     set integre(PLU) non
                     set conf_pt_fc(fich_pour_PLU_ok) non
                  } else {
                     #--- J'ai tout pour faire le noir de PLU
                     set conf_pt_fc(fich_pour_PLU_ok) oui
                     #--- Alors je memorise que je dois le faire
                     set conf_pt_fc(noir_de_PLU_a_faire_pl) oui
                  }
               } else {
                  set conf_pt_fc(fich_pour_PLU_ok) oui
               }
            } elseif {$conf_pt_fc(modePLU) != ""} {
               #--- Dans ce cas, on a choisit les options rapp tps pose ou optimisation
               #--- Teste si le fichier de precharge existe bien
               set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmPrechRes)$ext" ]
               if {[file exists $nomFich] == 0} {
                  testPrecharge
                  if {$integre(precharge) == "non"} {
                     tk_messageBox -title $caption(pretrfc,pb) -type ok \
                        -message $caption(pretrfc,fichPrechPLUAbs)
                     set integre(PLU) non
                     set conf_pt_fc(fich_pour_PLU_ok) non
                  } else {
                     #--- J'ai tout pour faire la precharge
                     set conf_pt_fc(fich_pour_PLU_ok) oui
                     #--- Alors je memorise que je dois le faire
                     set conf_pt_fc(precharge_a_faire_pl) oui
                  }
               } else {
                   set conf_pt_fc(fich_pour_PLU_ok) oui
               }
               if {$conf_pt_fc(fich_pour_PLU_ok) == "oui"} {
                  #--- Teste si le fichier de noir existe bien
                  set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmNoirRes)$ext" ]
                  if {[file exists $nomFich] == 0} {
                     testNoir
                     if {$integre(noir) == "non"} {
                        tk_messageBox -title $caption(pretrfc,pb) -type ok \
                           -message $caption(pretrfc,fichNrtoPLUAbs)
                        set integre(PLU) non
                        set conf_pt_fc(fich_pour_PLU_ok) non
                     } else {
                        #--- J'ai tout pour faire le noir
                        set conf_pt_fc(fich_pour_PLU_ok) oui
                        #--- Alors je memorise que je dois le faire
                        set conf_pt_fc(noir_a_faire_pl) oui
                     }
                  } else {
                     set conf_pt_fc(fich_pour_PLU_ok) oui
                  }
               }
            } else {
               #--- Verifie qu'un mode de traitement est bien selectionne
               tk_messageBox -title $caption(pretrfc,pb) -type ok \
                  -message $caption(pretrfc,choisir_mode_PLU)
               set integre(PLU) non
            }
         }
      }
      activeBoutons
   }
#***** Fin de la procedure testPLU ***********************************

#***** Procedure traitePLU *******************************************
   proc traitePLU { } {
      variable This
      global audace caption conf_pt_fc

      if {$conf_pt_fc(noir_de_PLU_a_faire_pl) == "oui"} {
         traiteNoirDePLU
      }
      if {$conf_pt_fc(precharge_a_faire_pl) == "oui"} {
         traitePrecharge
      }
      if {$conf_pt_fc(noir_a_faire_pl) == "oui"} {
         traiteNoir
      }

      update idletasks

      #--- Enregistrement de l'extension des fichiers
      set ext $::conf(extension,defaut)

      desactiveBoutons

      #--- Affichage du message de demarrage du pretraitement des noirs
      Message consolog $caption(pretrfc,debPLU)
      switch -exact $conf_pt_fc(modePLU) {
         simple {
            Message consolog $caption(pretrfc,ModePLUSimple)
         }
         rapTps {
            Message consolog $caption(pretrfc,ModePLURapTps)
         }
         opt {
            Message consolog $caption(pretrfc,ModePLUOpt)
         }
      }

      if {$conf_pt_fc(cosmPLU) == 1} {
         #--- Dans le cas ou la correction cosmetique est demandee
         Message consolog $caption(pretrfc,lanceCosmPLU)
         for {set i 1} {$i <= $conf_pt_fc(nbPLU)} {incr i} {
            set instr "loadima $conf_pt_fc(nmPLUSce)$i"
            Message consolog "%s\n" $instr
            eval $instr
            set instr "eval $conf_pt_fc(procCorr)"
            Message consolog "%s\n" $instr
            eval $instr
            set instr "saveima $conf_pt_fc(nmPLUSce)$i"
            Message consolog "%s\n" $instr
            eval $instr
         }
      }

      #--- Affichage de la premiere image de PLU
      set nomFich $conf_pt_fc(nmPLUSce)
      append nomFich "1"
      Message consolog $caption(pretrfc,chargPremPLU)
      set instr "loadima $nomFich"
      Message consolog "%s\n" $instr
      eval $instr

      #--- Traitement proprement dit des PLU, selon le mode choisi
      switch -exact $conf_pt_fc(modePLU) {
         simple {
            #--- Soustraction du noir de PLU de chaque image de PLU
            set instr "sub2 $conf_pt_fc(nmPLUSce) $conf_pt_fc(nmNrPLURes) $conf_pt_fc(nmPLUSce)"
            append instr "_moinsnoir_ 0 $conf_pt_fc(nbPLU)"
            Message consolog $caption(pretrfc,SoustrNrPLUPLU)
            Message consolog "%s\n" $instr
            eval $instr
         }
         rapTps {
            #--- Lecture du temps de pose de l'image PLU
            #--- Je verifie que le champ exposure est bien present dans l'en-tete FITS
            if {[lsearch [buf$audace(bufNo) getkwds] EXPOSURE] != -1} {
               set motCle EXPOSURE
            } else {
               set motCle EXPTIME
            }
            set instr "set temps_plu [lindex [buf$audace(bufNo) getkwd $motCle] 1]"
            Message consolog $caption(pretrfc,LitTpsPLU)
            Message consolog "%s\n" $instr
            eval $instr
            #--- Chargement de l'image de noir
            set instr "loadima $conf_pt_fc(nmNoirRes)"
            Message consolog $caption(pretrfc,ChargeNoir)
            Message consolog "%s\n" $instr
            eval $instr
            #--- Lecture du temps de pose du noir
            #--- Je verifie que le champ exposure est bien present dans l'en-tete FITS
            if {[lsearch [buf$audace(bufNo) getkwds] EXPOSURE] != -1} {
               set motCle EXPOSURE
            } else {
               set motCle EXPTIME
            }
            set instr "set temps_noir [lindex [buf$audace(bufNo) getkwd $motCle] 1]"
            Message consolog $caption(pretrfc,LitTpsNoir)
            Message consolog "%s\n" $instr
            eval $instr
            #--- Calcul du rapport de temps entre noir et PLU
            set instr "set rapport [expr double($temps_plu) / double($temps_noir)]"
            Message consolog $caption(pretrfc,calcRapp)
            Message consolog "%s\n" $instr
            eval $instr
            #--- Retire l'offset du noir (si besoin)
            if {$conf_pt_fc(NrContientPrech) == 1} {
               set instr "sub $conf_pt_fc(nmPrechRes) 0"
               Message consolog $caption(pretrfc,soustrPrechDuNoir)
               Message consolog "%s\n" $instr
               eval $instr
            }
            #--- Multiplie le noir par le rapport de tps d'exp.
            set instr "mult $rapport"
            Message consolog $caption(pretrfc,multNoir)
            Message consolog "%s\n" $instr
            eval $instr
            #--- Sauvegarde le noir pondere
            set instr "saveima noir_pondere_temp"
            Message consolog $caption(pretrfc,SauveNoirPond)
            Message consolog "%s\n" $instr
            eval $instr
            #--- Retire l'offset de toutes les images de PLU
            set nom_fich $conf_pt_fc(nmPLUSce)
            append nom_fich "_moinsnoir_"
            set instr "sub2 $conf_pt_fc(nmPLUSce) $conf_pt_fc(nmPrechRes) $nom_fich 0 $conf_pt_fc(nbPLU)"
            Message consolog $caption(pretrfc,SoustrPrechPLUProv)
            Message consolog "%s\n" $instr
            eval $instr
            #--- Retire le noir pondere de toutes les images de PLU
            set instr "sub2 $nom_fich noir_pondere_temp $nom_fich 0 $conf_pt_fc(nbPLU)"
            Message consolog $caption(pretrfc,SoustrNoirPondPLU)
            Message consolog "%s\n" $instr
            eval $instr
         }
         opt {
            if {$conf_pt_fc(NrContientPrech) == 0} {
               #--- Chargement de l'image de noir
               set instr "loadima $conf_pt_fc(nmNoirRes)"
               Message consolog $caption(pretrfc,ChargeNoir)
               Message consolog "%s\n" $instr
               eval $instr
               #--- Addition de la precharge
               set instr "add $conf_pt_fc(nmPrechRes) 0"
               Message consolog $caption(pretrfc,ajoutePrechNoir)
               Message consolog "%s\n" $instr
               eval $instr
               #--- Sauvegarde le noir contenant la precharge
               set instr "saveima noir_avec_prech"
               Message consolog $caption(pretrfc,SauveNoirAvecPrech)
               Message consolog "%s\n" $instr
               eval $instr
               #--- Astuce pour traiter correctement les fichiers de noir...
               set noir_avec_prech noir_avec_prech
               } else {
               #--- Suite et fin de l'astuce pour traiter correctement les fichiers de noir...
               set noir_avec_prech $conf_pt_fc(nmNoirRes)
            }
            set nom_fich_sortie $conf_pt_fc(nmPLUSce)
            append nom_fich_sortie "_moinsnoir_"
            set instr "opt2 $conf_pt_fc(nmPLUSce) $noir_avec_prech $conf_pt_fc(nmPrechRes) \
               $nom_fich_sortie $conf_pt_fc(nbPLU)"
            Message consolog $caption(pretrfc,OptPLU)
            Message consolog "%s\n" $instr
            eval $instr
         }
      }

      #--- Affichage de la premiere image de PLU, corrigee du noir
      set nomFich $conf_pt_fc(nmPLUSce)
      append nomFich "_moinsnoir_1"
      Message consolog $caption(pretrfc,chargPremPLUCorrNrPLU)
      set instr "loadima "
      append instr $nomFich
      Message consolog "%s\n" $instr
      eval $instr

      #--- Calcul de la valeur moyenne de la premiere image:
      set instr "set valMoyenne \[lindex \[stat\] 4\]"
      Message consolog $caption(pretrfc,calcMoyPremIm)
      Message consolog "%s\n" $instr
      eval $instr

      #--- Mise au meme niveau de tous les PLU
      set instr "ngain2 "
      append instr $conf_pt_fc(nmPLUSce)
      append instr "_moinsnoir_ "
      append instr $conf_pt_fc(nmPLUSce)
      append instr "_auniveau " $valMoyenne " " $conf_pt_fc(nbPLU)
      Message consolog $caption(pretrfc,MiseNiveauPLU)
      Message consolog "%s\n" $instr
      eval $instr

      #--- Calcul de la mediane des images
      set instr "smedian "
      append instr $conf_pt_fc(nmPLUSce)
      append instr _auniveau " " $conf_pt_fc(nmPLURes) " " $conf_pt_fc(nbPLU)
      Message consolog $caption(pretrfc,CalcMedPLU)
      Message consolog "%s\n" $instr
      eval $instr

      #--- Affichage de l'image noire resultante
      set nomFich $conf_pt_fc(nmPLURes)
      Message consolog $caption(pretrfc,chargPLURes)
      set instr "loadima $nomFich"
      Message consolog "%s\n" $instr
      eval $instr

      #--- Effacement du disque des images generees par le pretraitement:
      Message consolog $caption(pretrfc,effacePLUInter)
      for {set i 1} {$i <= $conf_pt_fc(nbPLU)} {incr i} {
         set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmPLUSce)_moinsnoir_$i$ext" ]
         file delete $nomFich
         set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmPLUSce)_auniveau$i$ext" ]
         file delete $nomFich
      }
      set nomFich [ file join $audace(rep_images) "noir_pondere_temp$ext" ]
      if {[file exists $nomFich]} {
         file delete $nomFich
      }
      set nomFich [ file join $audace(rep_images) "noir_avec_prech$ext" ]
      if {[file exists $nomFich]} {
         file delete $nomFich
      }

      #--- Affichage du message de fin du pretraitement des noirs
      Message consolog $caption(pretrfc,finPLU)
      activeBoutons
      focus $This
   }
#***** Fin de la procedure traitePLU *********************************

#***** Procedure goBrut **********************************************
   proc goBrut { } {
      global integre

      #--- Dans un premier temps, je teste l'integrite de l'operation
      testBrut
      #--- Si tout est Ok, je lance le traitement
      if {$integre(brut) == "oui"} {
         traiteBrut
      }
   }
#***** Fin de la procedure goBrut ************************************

#***** Procedure testBrut ********************************************
   proc testBrut { } {
      global audace caption conf_pt_fc integre

      #--- Initialisation du drapeau d'integrite
      set integre(brut) oui

      #--- Enregistrement de l'extension des fichiers
      set ext $::conf(extension,defaut)

      #--- Je commence par regarder si la correction cosmetique est demandee...
      if {$conf_pt_fc(cosmBrut) == 1} {
         #--- Alors je teste si la definition de la correction cosmetique est Ok
         testCosm
         if {$integre(cosm) != "oui"} {
            set integre(brut) non
            return
         }
      }
      desactiveBoutons
      set conf_pt_fc(noir_a_faire_br) non
      set conf_pt_fc(PLU_a_faire_br) non
      set conf_pt_fc(precharge_a_faire_br) non
      set conf_pt_fc(noir_ok) non
      set conf_pt_fc(PLU_ok) non
      set conf_pt_fc(precharge_ok) non

      #--- Teste si le nom de fichier source est Ok (un seul champ, pas de caractere interdit...)
      if {[TestNomFichier $conf_pt_fc(nmBrutSce)] == 0} {
         set integre(brut) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomBrutSrce)
      } elseif {[TestNomFichier $conf_pt_fc(nmBrutRes)] == 0} {
         #--- Teste si le nom de fichier resultant est Ok (un seul champ, pas de caractere interdit...)
         set integre(brut) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomBrutRes)
      } elseif {[TestEntier $conf_pt_fc(nbBrut)] == 0} {
         #--- Teste si le nombre est Ok
         set integre(brut) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNbBrut)
      } else {
         #--- Teste si les fichiers sources existent
         for {set i 1} {$i <= $conf_pt_fc(nbBrut)} {incr i} {
            set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmBrutSce)$i$ext" ]
            if {[file exists $nomFich] == 0} {
               set integre(brut) non
            }
         }
         if {$integre(brut) == "non"} {
            tk_messageBox -title $caption(pretrfc,pb) -type ok \
               -message $caption(pretrfc,fichBrutAbs)
         } else {
            #--- Teste si le fichier de noir existe bien
            set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmNoirRes)$ext" ]
            if {[file exists $nomFich] == 0} {
               #--- Dans ce cas, je regarde si je peux calculer le noir...
               testNoir
               if {$integre(noir) == "non"} {
                  #--- Je n'ai pas les elements pour faire le noir
                  tk_messageBox -title $caption(pretrfc,pb) -type ok \
                     -message $caption(pretrfc,fichNoirBrutAbs)
                  set integre(brut) non
                  set conf_pt_fc(noir_ok) non
                  } else {
                  #--- Alors je dois prevoir de faire le calcul du noir pendant le traitement
                  set conf_pt_fc(noir_a_faire_br) oui
                  #--- Et je memorise que c'est Ok pour les noirs
                  set conf_pt_fc(noir_ok) oui
               }
            } else {
               set conf_pt_fc(noir_ok) oui
            }
            if {$conf_pt_fc(noir_ok) == "oui"} {
               #--- Teste si le fichier de PLU existe bien
               set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmPLURes)$ext" ]
               if {[file exists $nomFich] == 0} {
                  #--- Dans ce cas, je regarde si je peux calculer le PLU...
                  testPLU
                  if {$integre(PLU) == "non"} {
                  #--- Je n'ai pas les elements pour faire le PLU
                     tk_messageBox -title $caption(pretrfc,pb) -type ok \
                        -message $caption(pretrfc,fichPLUBrutAbs)
                     set integre(brut) non
                     set conf_pt_fc(PLU_ok) non
                  } else {
                     #--- Alors je dois prevoir de faire le calcul du PLU pendant le traitement
                     set conf_pt_fc(PLU_a_faire_br) oui
                     set conf_pt_fc(PLU_ok) oui
                  }
               } else {
                  set conf_pt_fc(PLU_ok) oui
               }
            }
            if {$conf_pt_fc(PLU_ok) == "oui" && $conf_pt_fc(noir_ok) == "oui"} {
               #--- Teste si les fichiers resultants existent deja
               for {set i 1} {$i <= $conf_pt_fc(nbBrut)} {incr i} {
                  set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmBrutRes)$i$ext" ]
                  if {[file exists $nomFich] == 1} {
                     set integre(brut) non
                  }
               }
               if {$integre(brut) == "non"} {
                  set confirmation [tk_messageBox -title $caption(pretrfc,conf) -type yesno \
                     -message $caption(pretrfc,fichBrutResDeja)]
                  if {$confirmation == "yes" } {
                     set integre(brut) oui
                  }
               }
            }
            if {$conf_pt_fc(PLU_ok) == "oui" && $conf_pt_fc(noir_ok) == "oui"} {
               if {$conf_pt_fc(modeBrut) != "simple" || $conf_pt_fc(NrContientPrech) == 0} {
                  #--- Teste si le fichier de precharge existe bien (dans le cas ou l'option
                  #---   retenue est optimisation ou rapp. tps de pose) ou bien si le noir
                  #---   ne contient pas la precharge: J'ai alors besoin de la precharge
                  set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmPrechRes)$ext" ]
                  if {[file exists $nomFich] == 0} {
                     #--- Dans ce cas, je regarde si je peux calculer la precharge...
                     testPrecharge
                     if {$integre(precharge) == "non"} {
                     #--- Je n'ai pas les elements pour faire la precharge
                        tk_messageBox -title $caption(pretrfc,pb) -type ok \
                           -message $caption(pretrfc,fichPrechBrutAbs)
                        set integre(brut) non
                        set conf_pt_fc(precharge_ok) non
                        } else {
                        #--- Alors je dois prevoir de faire le calcul du PLU pendant le traitement
                        set conf_pt_fc(precharge_a_faire_br) oui
                        set conf_pt_fc(precharge_ok) oui
                     }
                  } else {
                     set conf_pt_fc(precharge_ok) oui
                  }
               }
            }
            #--- Teste qu'un mode est bien selectionne
            if {$conf_pt_fc(modeBrut) == ""} {
               tk_messageBox -title $caption(pretrfc,pb) -type ok \
                  -message $caption(pretrfc,fichModeBrutAbs)
               set integre(brut) non
            }
         }
      }
      activeBoutons
   }
#***** Fin de la procedure testBrut **********************************

#***** Procedure traiteBrut ******************************************
   proc traiteBrut { } {
      variable This
      global audace caption conf_pt_fc

      #--- Enregistrement de l'extension des fichiers
      set ext $::conf(extension,defaut)

      #--- Le cas echeant, je lance les operation prelimineires
      if {$conf_pt_fc(PLU_a_faire_br) == "oui"} {
         traitePLU
      }
      if {$conf_pt_fc(precharge_a_faire_br) == "oui"} {
         #--- Je verifie que le fichier n'existe pas deja (il a pu etre cree par le traitement de PLU...)
         set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmPrechRes)$ext" ]
         if {[file exists $nomFich] == 0} {
            traitePrecharge
         }
      }
      if {$conf_pt_fc(noir_a_faire_br) == "oui"} {
         #--- Je verifie que le fichier n'existe pas deja (il a pu etre cree par le traitement de PLU...)
         set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmNoirRes)$ext" ]
         if {[file exists $nomFich] == 0} {
            traiteNoir
         }
      }

      desactiveBoutons

      #--- Affichage du message de demarrage du pretraitement des noirs
      Message consolog $caption(pretrfc,debBrut)
      switch -exact $conf_pt_fc(modeBrut) {
         simple {
            Message consolog $caption(pretrfc,ModeBrutSimple)
         }
         rapTps {
            Message consolog $caption(pretrfc,ModeBrutRapTps)
         }
         opt {
            Message consolog $caption(pretrfc,ModeBrutOpt)
         }
      }

      if {$conf_pt_fc(cosmBrut) == 1} {
         #--- Dans le cas ou la correction cosmetique est demandee
         Message consolog $caption(pretrfc,lanceCosmStellaire)
         for {set i 1} {$i <= $conf_pt_fc(nbBrut)} {incr i} {
            set instr "loadima $conf_pt_fc(nmBrutSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "eval $conf_pt_fc(procCorr)"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "saveima $conf_pt_fc(nmBrutSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
         }
      }

      #--- Affichage de la premiere image stellaire
      set nomFich $conf_pt_fc(nmBrutSce)
      append nomFich "1"
      Message consolog $caption(pretrfc,chargPremBrut)
      set instr "loadima $nomFich"
      Message consolog "%s\n" $instr
      eval $instr
      #--- Soustraction du noir, selon le mode choisi
      switch -exact $conf_pt_fc(modeBrut) {
         simple {
            #--- Soustraction du noir de chaque image stellaire
            set instr "sub2 $conf_pt_fc(nmBrutSce) $conf_pt_fc(nmNoirRes) $conf_pt_fc(nmBrutSce)"
            append instr "_moinsnoir_ 0 $conf_pt_fc(nbBrut)"
            Message consolog $caption(pretrfc,SoustrNoirBrut)
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            #--- Si le noir ne contient pas la precharge, soustraction de la precharge
            if {$conf_pt_fc(NrContientPrech) == 0} {
               set instr "sub2 $conf_pt_fc(nmBrutSce)"
               append instr "_moinsnoir_ $conf_pt_fc(nmPrechRes) $conf_pt_fc(nmBrutSce)"
               append instr "_moinsnoir_ 0 $conf_pt_fc(nbBrut)"
               Message consolog $caption(pretrfc,SoustrPrechBrut)
               Message consolog $instr
               Message consolog "\n"
               eval $instr
            }
         }
         rapTps {
            #--- Lecture du temps de pose des images stellaires
            #--- Je verifie que le champ exposure est bien present dans l'en-tete FITS
            if {[lsearch [buf$audace(bufNo) getkwds] EXPOSURE] != -1} {
               set motCle EXPOSURE
            } else {
               set motCle EXPTIME
            }
            set instr "set temps_stellaire [lindex [buf$audace(bufNo) getkwd $motCle] 1]"
            Message consolog $caption(pretrfc,LitTpsStellaire)
            Message consolog "%s\n" $instr
            eval $instr
            #--- Chargement de l'image de noir
            set instr "loadima $conf_pt_fc(nmNoirRes)"
            Message consolog $caption(pretrfc,ChargeNoir)
            Message consolog "%s\n" $instr
            eval $instr
            #--- Lecture du temps de pose du noir
            #--- Je verifie que le champ exposure est bien present dans l'en-tete FITS
            if {[lsearch [buf$audace(bufNo) getkwds] EXPOSURE] != -1} {
               set motCle EXPOSURE
            } else {
               set motCle EXPTIME
            }
            set instr "set temps_noir [lindex [buf$audace(bufNo) getkwd $motCle] 1]"
            Message consolog $caption(pretrfc,LitTpsNoir)
            Message consolog "%s\n" $instr
            eval $instr
            #--- Calcul du rapport de temps entre noir et PLU
            set instr "set rapport [expr double($temps_stellaire) / double($temps_noir)]"
            Message consolog $caption(pretrfc,calcRapp)
            Message consolog "%s\n" $instr
            eval $instr
            #--- Retire l'offset du noir (si besoin)
            if {$conf_pt_fc(NrContientPrech) == 1} {
               set instr "sub $conf_pt_fc(nmPrechRes) 0"
               Message consolog $caption(pretrfc,soustrPrechDuNoir)
               Message consolog "%s\n" $instr
               eval $instr
            }
            #--- Multiplie le noir par le rapport de tps d'exp.
            set instr "mult $rapport"
            Message consolog $caption(pretrfc,multNoir)
            Message consolog "%s\n" $instr
            eval $instr
            #--- Sauvegarde le noir pondere
            set instr "saveima noir_pondere_temp"
            Message consolog $caption(pretrfc,SauveNoirPond)
            Message consolog "%s\n" $instr
            eval $instr
            #--- Retire l'offset de toutes les images stellaires
            set nom_fich $conf_pt_fc(nmBrutSce)
            append nom_fich "_moinsnoir_"
            set instr "sub2 $conf_pt_fc(nmBrutSce) $conf_pt_fc(nmPrechRes) $nom_fich 0 $conf_pt_fc(nbBrut)"
            Message consolog $caption(pretrfc,SoustrPrechStelProv)
            Message consolog "%s\n" $instr
            eval $instr
            #--- Retire le noir pondere de toutes les images stellaires
            set instr "sub2 $nom_fich noir_pondere_temp $nom_fich 0 $conf_pt_fc(nbBrut)"
            Message consolog $caption(pretrfc,SoustrNoirPondStel)
            Message consolog "%s\n" $instr
            eval $instr
         }
         opt {
            #--- Verifie si le noir contient la precharge... et agit en consequence
            if {$conf_pt_fc(NrContientPrech) == 0} {
               #--- Si offset non inclus... chargement de l'image de noir
               set instr "loadima $conf_pt_fc(nmNoirRes)"
               Message consolog $caption(pretrfc,ChargeNoir)
               Message consolog "%s\n" $instr
               eval $instr
               #--- Addition de la precharge
               set instr "add $conf_pt_fc(nmPrechRes) 0"
               Message consolog $caption(pretrfc,ajoutePrechNoir)
               Message consolog "%s\n" $instr
               eval $instr
               #--- Sauvegarde le noir contenant la precharge
               set instr "saveima noir_avec_prech"
               Message consolog $caption(pretrfc,SauveNoirAvecPrech)
               Message consolog "%s\n" $instr
               eval $instr
               #--- Astuce pour traiter correctement les fichiers de noir...
               set noir_avec_prech noir_avec_prech
            } else {
               #--- Suite et fin de l'astuce pour traiter correctement les fichiers de noir...
               set noir_avec_prech $conf_pt_fc(nmNoirRes)
            }
            set nom_fich_sortie $conf_pt_fc(nmBrutSce)
            append nom_fich_sortie "_moinsnoir_"
            #--- Lancement de l'optimisation; le noir doit contenir la precharge !
            set instr "opt2 $conf_pt_fc(nmBrutSce) $noir_avec_prech $conf_pt_fc(nmPrechRes) \
               $nom_fich_sortie $conf_pt_fc(nbBrut)"
            Message consolog $caption(pretrfc,OptBrutes)
            Message consolog "%s\n" $instr
            eval $instr
         }
      }

      #--- Affichage de la PLU
      set nomFich $conf_pt_fc(nmPLURes)
      Message consolog $caption(pretrfc,chargePLU)
      set instr "loadima $nomFich"
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      #--- Calcul de la valeur moyenne de la PLU
      set instr "set valMoyenne \[lindex \[stat\] 4\]"
      Message consolog $caption(pretrfc,calcMoyPLU)
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      #--- Division des images par le PLU
      set instr "div2 $conf_pt_fc(nmBrutSce)"
      append instr "_moinsnoir_ $conf_pt_fc(nmPLURes)\
         $conf_pt_fc(nmBrutRes) $valMoyenne $conf_pt_fc(nbBrut)"
      Message consolog $caption(pretrfc,divBrutPLU)
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      #--- Affichage de la premiere image resultante
      set nomFich $conf_pt_fc(nmBrutRes)
      append nomFich "1"
      Message consolog $caption(pretrfc,chargBrutRes)
      set instr "loadima $nomFich"
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      #--- Effacement du disque des images generees par le pretraitement:
      Message consolog $caption(pretrfc,effaceBrutsInter)
      for {set i 1} {$i <= $conf_pt_fc(nbBrut)} {incr i} {
         set nomFich [ file join $audace(rep_images) "$conf_pt_fc(nmBrutSce)_moinsnoir_$i$ext" ]
         file delete $nomFich
      }
      set nomFich [ file join $audace(rep_images) "noir_pondere_temp$ext" ]
      if {[file exists $nomFich]} {
         file delete $nomFich
      }
      set nomFich [ file join $audace(rep_images) "noir_avec_prech$ext" ]
      if {[file exists $nomFich]} {
         file delete $nomFich
      }

      #--- Affichage du message de fin du pretraitement des noirs
      Message consolog $caption(pretrfc,finBrut)
      activeBoutons
      focus $This
   }
#***** Fin de la procedure traiteBrut ********************************

#***** Procedure de desactivation des boutons de la fenetre **********
   proc desactiveBoutons { } {
      variable This

      $This.et1.test configure -state disabled
      $This.et1.recharge configure -state disabled
      $This.et1.ligne1.entnmFichScr configure -state disabled
      $This.et1.ligne2.ent1 configure -state disabled
      $This.et2.titre.case configure -state disabled
      $This.et2.go configure -state disabled
      $This.et2.ligne1.entnmPrechSce configure -state disabled
      $This.et2.ligne1.entNbPrech configure -state disabled
      $This.et2.ligne2.ent1 configure -state disabled
      $This.et2.ligne2.case configure -state disabled
      $This.et2.ligne2.ent2 configure -state disabled
      $This.et3.titre.case configure -state disabled
      $This.et3.go configure -state disabled
      $This.et3.ligne1.entnmNrSce configure -state disabled
      $This.et3.ligne1.entNbNr configure -state disabled
      $This.et3.ligne2.ent1 configure -state disabled
      $This.et3.ligne2.case configure -state disabled
      $This.et4.titre.case configure -state disabled
      $This.et4.go configure -state disabled
      $This.et4.ligne1.entnmNrPLUSce configure -state disabled
      $This.et4.ligne1.entNbNrPLU configure -state disabled
      $This.et4.ligne2.ent1 configure -state disabled
      $This.et5.titre.case configure -state disabled
      $This.et5.go configure -state disabled
      $This.et5.ligne1.entnmPLUSce configure -state disabled
      $This.et5.ligne1.entNbPLU configure -state disabled
      $This.et5.ligne2.ent1 configure -state disabled
      $This.et5.ligne3.rad1 configure -state disabled
      $This.et5.ligne3.rad2 configure -state disabled
      $This.et5.ligne3.rad3 configure -state disabled
      $This.et6.titre.case configure -state disabled
      $This.et6.go configure -state disabled
      $This.et6.ligne1.entnmBrutSce configure -state disabled
      $This.et6.ligne1.entNbBrut configure -state disabled
      $This.et6.ligne2.ent1 configure -state disabled
      $This.et6.ligne3.rad1 configure -state disabled
      $This.et6.ligne3.rad2 configure -state disabled
      $This.et6.ligne3.rad3 configure -state disabled
   }
#***** Fin procedure de desactivation des boutons de la fenetre ******

#***** Procedure d'activation des boutons de la fenetre **************
   proc activeBoutons { } {
      variable This

      $This.et1.test configure -state normal
      $This.et1.recharge configure -state normal
      $This.et1.ligne1.entnmFichScr configure -state normal
      $This.et1.ligne2.ent1 configure -state normal
      $This.et2.titre.case configure -state normal
      $This.et2.go configure -state normal
      $This.et2.ligne1.entnmPrechSce configure -state normal
      $This.et2.ligne1.entNbPrech configure -state normal
      $This.et2.ligne2.ent1 configure -state normal
      $This.et2.ligne2.case configure -state normal
      $This.et2.ligne2.ent2 configure -state normal
      $This.et3.titre.case configure -state normal
      $This.et3.go configure -state normal
      $This.et3.ligne1.entnmNrSce configure -state normal
      $This.et3.ligne1.entNbNr configure -state normal
      $This.et3.ligne2.ent1 configure -state normal
      $This.et3.ligne2.case configure -state normal
      $This.et4.titre.case configure -state normal
      $This.et4.go configure -state normal
      $This.et4.ligne1.entnmNrPLUSce configure -state normal
      $This.et4.ligne1.entNbNrPLU configure -state normal
      $This.et4.ligne2.ent1 configure -state normal
      $This.et5.titre.case configure -state normal
      $This.et5.go configure -state normal
      $This.et5.ligne1.entnmPLUSce configure -state normal
      $This.et5.ligne1.entNbPLU configure -state normal
      $This.et5.ligne2.ent1 configure -state normal
      $This.et5.ligne3.rad1 configure -state normal
      $This.et5.ligne3.rad2 configure -state normal
      $This.et5.ligne3.rad3 configure -state normal
      $This.et6.titre.case configure -state normal
      $This.et6.go configure -state normal
      $This.et6.ligne1.entnmBrutSce configure -state normal
      $This.et6.ligne1.entNbBrut configure -state normal
      $This.et6.ligne2.ent1 configure -state normal
      $This.et6.ligne3.rad1 configure -state normal
      $This.et6.ligne3.rad2 configure -state normal
      $This.et6.ligne3.rad3 configure -state normal
   }
#***** Fin de la procedure d'activation des boutons de la fenetre ****

#***** Procedure de test de validite d'un nom de fichier *************
#--- Cette procedure (copiee de methking.tcl) verifie que la chaine passee en argument est un
#--- nom de fichier valide.
   proc TestNomFichier { valeur } {
      set test 1
      #--- Teste qu'il y a bien un nom de fichier
      if {$valeur == ""} {
         set test 0
      }
      #--- Teste que le nom de fichier n'a pas d'espace
      if {[llength $valeur] > 1} {
         set test 0
      }
      #--- Teste que le nom des images ne contient pas de caracteres interdits
      if {[TestChaine $valeur] == 0} {
         set test 0
      }
      return $test
   }
#***** Fin de la procedure de test de validite d'un nom de fichier ***

#***** Procedure de test de validite d'un entier *********************
#--- Cette procedure (copiee de methking.tcl) verifie que la chaine passee en argument decrit
#--- bien un entier. Elle retourne 1 si c'est la cas, et 0 si ce n'est pas un entier.
   proc TestEntier { valeur } {
      set test 1
      if {$valeur == ""} {
         set test 0
      }
      for {set i 0} {$i < [string length $valeur]} {incr i} {
         set a [string index $valeur $i]
         if {![string match {[0-9]} $a]} {
            set test 0
         }
      }
      return $test
   }
#***** Fin de la procedure de test de validite d'un entier ***********

#***** Procedure de test de validite d'une chaine de caracteres ******
#--- Cette procedure verifie que la chaine passee en argument ne contient que des caracteres
#--- valides. Elle retourne 1 si c'est la cas, et 0 si ce n'est pas valable.
   proc TestChaine { valeur } {
      set test 1
      for {set i 0} {$i < [string length $valeur]} {incr i} {
         set a [string index $valeur $i]
         if {![string match {[-a-zA-Z0-9_]} $a]} {
            set test 0
         }
      }
      return $test
   }
#***** Fin procedure de test de validite d'une chaine de caracteres **

#***** Procedure d'affichage des messages ****************************
#--- Cette procedure est recopiee de methking.tcl, elle permet l'affichage de differents
#--- messages (dans la console, le fichier log, etc.)
   proc Message { niveau args } {
      global caption panneau

      switch -exact -- $niveau {
         console {
            ::console::disp [eval [concat {format} $args]]
            update idletasks
         }
         log {
            set temps [clock format [clock seconds] -format %H:%M:%S]
            append temps " "
            catch {
               puts -nonewline $::pretrfc::log_id [eval [concat {format} $args]]
               #--- Force l'ecriture immediate sur le disque
               flush $::pretrfc::log_id
            }
         }
         consolog {
            if { $panneau(pretrfc,messages) == "1" } {
               ::console::disp [eval [concat {format} $args]]
               update idletasks
            }
            set temps [clock format [clock seconds] -format %H:%M:%S]
            append temps " "
            catch {
               puts -nonewline $::pretrfc::log_id [eval [concat {format} $args]]
               #--- Force l'ecriture immediate sur le disque
               flush $::pretrfc::log_id
            }
         }
         default {
            set b [ list "%s\n" $caption(pretrfc,pbmesserr) ]
            ::console::disp [ eval [ concat {format} $b ] ]
            update idletasks
         }
      }
   }
#***** Fin de la procedure d'affichage des messages ******************

}
#=====================================================================
#   Fin de la declaration du Namespace pretrfc
#=====================================================================

#---------------------------------------------------------------------------------------------
proc creeFenetrePrFC { This } {
   global caption conf_pt_fc

#--- Note du 21 mars 2002: Comme j'ajoute la partie offset, je mets un peu le bazar
#--- dans les numerotations...

   #--- Trame de l'etape 1
   frame $This.et1 -borderwidth 2 -relief groove
      #--- Titre de l'etape 1: Pretraitement des noirs & option cosmetique
      frame $This.et1.titre -borderwidth 1 -relief groove
         #--- Affichage du titre
         label $This.et1.titre.nom -text $caption(pretrfc,titret1) -justify left
         pack $This.et1.titre.nom -side left -in $This.et1.titre
      pack $This.et1.titre -side top -fill x
      #--- Bouton TEST
      button $This.et1.test -borderwidth 2 -width 5 -text $caption(pretrfc,test) \
         -command {
            #--- Sauvegarde des parametres dans le fichier de config
            ::pretrfc::SauvegardeParametres
            #--- Traitement etape 1
            ::pretrfc::goCosm
         }
      pack $This.et1.test -side right -anchor sw -in $This.et1 \
         -padx 3 -pady 3 -ipady 3
      #--- Bouton Recharge
      button $This.et1.recharge -borderwidth 2 -width 12 -text $caption(pretrfc,recharge) \
         -command {
            #--- Sauvegarde des parametres dans le fichier de config
            ::pretrfc::SauvegardeParametres
            #--- Traitement etape 1
            ::pretrfc::rechargeCosm
         }
      pack $This.et1.recharge -side right -anchor sw -in $This.et1 \
         -padx 3 -pady 3 -ipady 3
      #--- Premiere ligne de l'etape 1
      frame $This.et1.ligne1
         #--- Affichage du label "Fichier du script"
         label $This.et1.ligne1.nmFichScr -text $caption(pretrfc,FichScript) -width 29
         pack $This.et1.ligne1.nmFichScr -side left
         #--- Affichage du champ de saisie "Fichier du script"
         entry $This.et1.ligne1.entnmFichScr -width 16 -relief flat \
            -textvariable conf_pt_fc(FichScript) -justify left -borderwidth 1 -relief groove
         pack $This.et1.ligne1.entnmFichScr -side left
      pack $This.et1.ligne1 -side top -fill x
      #--- Seconde ligne de l'etape 1
      frame $This.et1.ligne2
         #--- Affichage du label "Procedure de correction cosmetique"
         label $This.et1.ligne2.lab1 -text $caption(pretrfc,procCorr) \
            -width 29 -justify right
         pack $This.et1.ligne2.lab1 -side left
         #--- Affichage du champ de saisie "Procedure de correction cosmetique"
         entry $This.et1.ligne2.ent1 -width 16 -relief flat\
            -textvariable conf_pt_fc(procCorr) -justify left -borderwidth 1 -relief groove
         pack $This.et1.ligne2.ent1 -side left
      pack $This.et1.ligne2 -side top -fill x
   pack $This.et1 -side top -fill x

   #--- Trame de l'etape 2
   frame $This.et2 -borderwidth 2 -relief groove
      #--- Titre de l'etape 2: Pretraitement des noirs & option cosmetique
      frame $This.et2.titre -borderwidth 1 -relief groove
         #--- Affichage du titre
         label $This.et2.titre.nom -text $caption(pretrfc,titret2) -justify left
         pack $This.et2.titre.nom -side left -in $This.et2.titre
         #--- Affichage de la case a cocher pour l'activation de la correction cosmetique
         checkbutton $This.et2.titre.case -text $caption(pretrfc,corcosm) \
            -variable conf_pt_fc(cosmPrech)
         pack $This.et2.titre.case -side right -in $This.et2.titre
      pack $This.et2.titre -side top -fill x
      #--- Bouton GO
      button $This.et2.go -borderwidth 2 -width 4 -text $caption(pretrfc,goet) \
         -command {
            #--- Sauvegarde des parametres dans le fichier de config
            ::pretrfc::SauvegardeParametres
            #--- Traitement etape 2
            ::pretrfc::goPrecharge
         }
      pack $This.et2.go -side right -anchor sw -in $This.et2 \
         -padx 3 -pady 3 -ipady 3
      #--- Premiere ligne de l'etape 2
      frame $This.et2.ligne1
         #--- Affichage du label "Nom des fichiers source"
         label $This.et2.ligne1.nmPrechSce -text $caption(pretrfc,nmPrechSce) -width 29
         pack $This.et2.ligne1.nmPrechSce -side left
         #--- Affichage du champ de saisie "Nom des fichiers source"
         entry $This.et2.ligne1.entnmPrechSce -width 16 -relief flat\
            -textvariable conf_pt_fc(nmPrechSce) -justify left -borderwidth 1 -relief groove
         pack $This.et2.ligne1.entnmPrechSce -side left
         #--- Affichage du label "Nombre de fichiers source"
         label $This.et2.ligne1.nbPrech -text $caption(pretrfc,nb)
         pack $This.et2.ligne1.nbPrech -side left
         #--- Affichage du champ de saisie "Nombre de fichiers source"
         entry $This.et2.ligne1.entNbPrech -width 3 -relief flat\
            -textvariable conf_pt_fc(nbPrech) -justify center -borderwidth 1 -relief groove
         pack $This.et2.ligne1.entNbPrech -side left
      pack $This.et2.ligne1 -side top -fill x
      #--- Seconde ligne de l'etape 2
      frame $This.et2.ligne2
         #--- Affichage du label "Nom du fichier destination"
         label $This.et2.ligne2.lab1 -text $caption(pretrfc,nmPrechRes) \
            -width 29 -justify right
         pack $This.et2.ligne2.lab1 -side left
         #--- Affichage du champ de saisie "Nom du fichier destination"
         entry $This.et2.ligne2.ent1 -width 16 -relief flat\
            -textvariable conf_pt_fc(nmPrechRes) -justify left -borderwidth 1 -relief groove
         pack $This.et2.ligne2.ent1 -side left
         #--- Affichage de la case a cocher pour filtrer la mediane
         checkbutton $This.et2.ligne2.case -text $caption(pretrfc,medFiltree) \
            -variable conf_pt_fc(medFiltree)
         pack $This.et2.ligne2.case -side left -in $This.et2.ligne2
         #--- Affichage du champ de saisie "Filtrage"
         entry $This.et2.ligne2.ent2 -width 3 -relief flat\
            -textvariable conf_pt_fc(filtrage) -justify center -borderwidth 1 -relief groove
         pack $This.et2.ligne2.ent2 -side left
      pack $This.et2.ligne2 -side top -fill x
   pack $This.et2 -side top -fill x

   #--- Trame de l'etape 3
   frame $This.et3 -borderwidth 2 -relief groove
      #--- Titre de l'etape 3: Pretraitement des noirs & option cosmetique
      frame $This.et3.titre -borderwidth 1 -relief groove
         #--- Affichage du titre
         label $This.et3.titre.nom -text $caption(pretrfc,titret3) -justify left
         pack $This.et3.titre.nom -side left -in $This.et3.titre
         #--- Affichage de la case a cocher pour l'activation de la correction cosmetique
         checkbutton $This.et3.titre.case -text $caption(pretrfc,corcosm) \
            -variable conf_pt_fc(cosmNoir)
         pack $This.et3.titre.case -side right -in $This.et3.titre
      pack $This.et3.titre -side top -fill x
      #--- Bouton GO
      button $This.et3.go -borderwidth 2 -width 4 -text $caption(pretrfc,goet) \
         -command {
            #--- Sauvegarde des parametres dans le fichier de config
            ::pretrfc::SauvegardeParametres
            #--- Traitement etape 3
            ::pretrfc::goNoir
         }
      pack $This.et3.go -side right -anchor sw -in $This.et3 \
         -padx 3 -pady 3 -ipady 3
      #--- Premiere ligne de l'etape 3
      frame $This.et3.ligne1
         #--- Affichage du label "Nom des fichiers source"
         label $This.et3.ligne1.nmNrSce -text $caption(pretrfc,nmNrSce) -width 29
         pack $This.et3.ligne1.nmNrSce -side left
         #--- Affichage du champ de saisie "Nom des fichiers source"
         entry $This.et3.ligne1.entnmNrSce -width 16 -relief flat \
            -textvariable conf_pt_fc(nmNrSce) -justify left -borderwidth 1 -relief groove
         pack $This.et3.ligne1.entnmNrSce -side left
         #--- Affichage du label "Nombre de fichiers source"
         label $This.et3.ligne1.nbNr -text $caption(pretrfc,nbNr)
         pack $This.et3.ligne1.nbNr -side left
         #--- Affichage du champ de saisie "Nombre de fichiers source"
         entry $This.et3.ligne1.entNbNr -width 3 -relief flat\
            -textvariable conf_pt_fc(nbNoirs) -justify center -borderwidth 1 -relief groove
         pack $This.et3.ligne1.entNbNr -side left
      pack $This.et3.ligne1 -side top -fill x
      #--- Seconde ligne de l'etape 3
      frame $This.et3.ligne2
         #--- Affichage du label "Nom du fichier destination"
         label $This.et3.ligne2.lab1 -text $caption(pretrfc,nmNrRes) \
            -width 29 -justify right
         pack $This.et3.ligne2.lab1 -side left
         #--- Affichage du champ de saisie "Nom du fichier source"
         entry $This.et3.ligne2.ent1 -width 16 -relief flat\
            -textvariable conf_pt_fc(nmNoirRes) -justify left -borderwidth 1 -relief groove
         pack $This.et3.ligne2.ent1 -side left
         #--- Affichage de la case a cocher pour indiquer si le noir contient la precharge
         checkbutton $This.et3.ligne2.case -text $caption(pretrfc,NrContientPrech) \
            -variable conf_pt_fc(NrContientPrech)
         pack $This.et3.ligne2.case -side left -in $This.et3.ligne2
      pack $This.et3.ligne2 -side top -fill x
   pack $This.et3 -side top -fill x

   #--- Trame de l'etape 4
   frame $This.et4 -borderwidth 2 -relief groove
      #--- Titre de l'etape 4: Pretraitement des noirs & option cosmetique
      frame $This.et4.titre -borderwidth 1 -relief groove
         #--- Affichage du titre
         label $This.et4.titre.nom -text $caption(pretrfc,titret4) -justify left
         pack $This.et4.titre.nom -side left -in $This.et4.titre
         #--- Affichage de la case a cocher pour l'activation de la correction cosmetique
         checkbutton $This.et4.titre.case -text $caption(pretrfc,corcosm) \
            -variable conf_pt_fc(cosmNrPLU)
         pack $This.et4.titre.case -side right -in $This.et4.titre
      pack $This.et4.titre -side top -fill x
      #--- Bouton GO
      button $This.et4.go -borderwidth 2 -width 4 -text $caption(pretrfc,goet) \
         -command {
            #--- Sauvegarde des parametres dans le fichier de config
            ::pretrfc::SauvegardeParametres
            #--- Traitement etape 4
            ::pretrfc::goNoirDePLU
         }
      pack $This.et4.go -side right -anchor sw -in $This.et4 \
         -padx 3 -pady 3 -ipady 3
      #--- Premiere ligne de l'etape 4
      frame $This.et4.ligne1
         #--- Affichage du label "Nom des fichiers source"
         label $This.et4.ligne1.nmNrPLUSce -text $caption(pretrfc,nmNrPLUSce) \
            -width 29
         pack $This.et4.ligne1.nmNrPLUSce -side left
         #--- Affichage du champ de saisie "Nom des fichiers source"
         entry $This.et4.ligne1.entnmNrPLUSce -width 16 -relief flat\
            -textvariable conf_pt_fc(nmNrPLUSce) -justify left -borderwidth 1 -relief groove
         pack $This.et4.ligne1.entnmNrPLUSce -side left
         #--- Affichage du label "Nombre de fichiers source"
         label $This.et4.ligne1.nbNrPLU -text $caption(pretrfc,nb)
         pack $This.et4.ligne1.nbNrPLU -side left
         #--- Affichage du champ de saisie "Nombre de fichiers source"
         entry $This.et4.ligne1.entNbNrPLU -width 3 -relief flat\
            -textvariable conf_pt_fc(nbNrPLU) -justify center -borderwidth 1 -relief groove
         pack $This.et4.ligne1.entNbNrPLU -side left
      pack $This.et4.ligne1 -side top -fill x
      #--- Seconde ligne de l'etape 4
      frame $This.et4.ligne2
         #--- Affichage du label "Nom du fichier destination"
         label $This.et4.ligne2.lab1 -text $caption(pretrfc,nmNrPLURes) \
            -width 29 -justify right
         pack $This.et4.ligne2.lab1 -side left
         #--- Affichage du champ de saisie "Nom du fichier destination"
         entry $This.et4.ligne2.ent1 -width 16 -relief flat\
            -textvariable conf_pt_fc(nmNrPLURes) -justify left -borderwidth 1 -relief groove
         pack $This.et4.ligne2.ent1 -side left
         #--- Affichage des boutons radio pour le mode de noir
      pack $This.et4.ligne2 -side top -fill x
   pack $This.et4 -side top -fill x

   #--- Trame de l'etape 5
   frame $This.et5 -borderwidth 2 -relief groove
      #--- Titre de l'etape 5: Pretraitement des PLU
      frame $This.et5.titre -borderwidth 1 -relief groove
         #--- Affichage du titre
         label $This.et5.titre.nom -text $caption(pretrfc,titret5) -justify left
         pack $This.et5.titre.nom -side left -in $This.et5.titre
         #--- Affichage de la case a cocher pour l'activation de la correction cosmetique
         checkbutton $This.et5.titre.case -text $caption(pretrfc,corcosm) \
            -variable conf_pt_fc(cosmPLU)
         pack $This.et5.titre.case -side right -in $This.et5.titre
      pack $This.et5.titre -side top -fill x
      #--- Bouton GO
      button $This.et5.go -borderwidth 2 -width 4 -text $caption(pretrfc,goet) \
         -command {
            #--- Sauvegarde des parametres dans le fichier de config
            ::pretrfc::SauvegardeParametres
            #--- Traitement etape 5
            ::pretrfc::goPLU
         }
      pack $This.et5.go -side right -anchor sw -in $This.et5 \
         -padx 3 -pady 3 -ipady 3
      #--- Premiere ligne de l'etape 5
      frame $This.et5.ligne1
         #--- Affichage du label "Nom des fichiers source"
         label $This.et5.ligne1.nmPLUSce -text $caption(pretrfc,nmPLUSce) -width 29
         pack $This.et5.ligne1.nmPLUSce -side left
         #--- Affichage du champ de saisie "Nom des fichiers source"
         entry $This.et5.ligne1.entnmPLUSce -width 16 -relief flat\
            -textvariable conf_pt_fc(nmPLUSce) -justify left -borderwidth 1 -relief groove
         pack $This.et5.ligne1.entnmPLUSce -side left
         #--- Affichage du label "Nombre de fichiers source"
         label $This.et5.ligne1.nbPLU -text $caption(pretrfc,nb)
         pack $This.et5.ligne1.nbPLU -side left
         #--- Affichage du champ de saisie "Nombre de fichiers source"
         entry $This.et5.ligne1.entNbPLU -width 3 -relief flat\
            -textvariable conf_pt_fc(nbPLU) -justify center -borderwidth 1 -relief groove
         pack $This.et5.ligne1.entNbPLU -side left
      pack $This.et5.ligne1 -side top -fill x
      #--- Seconde ligne de l'etape 5
      frame $This.et5.ligne2
         #--- Affichage du label "Nom du fichier resultant"
         label $This.et5.ligne2.lab1 -text $caption(pretrfc,nmPLURes) \
            -width 29 -justify right
         pack $This.et5.ligne2.lab1 -side left
         #--- Affichage du champ de saisie "Nom du fichier resultant"
         entry $This.et5.ligne2.ent1 -width 16 -relief flat\
            -textvariable conf_pt_fc(nmPLURes) -justify left -borderwidth 1 -relief groove
         pack $This.et5.ligne2.ent1 -side left
      pack $This.et5.ligne2 -side top -fill x
      #--- Troisieme ligne de l'etape 5
      frame $This.et5.ligne3
         label $This.et5.ligne3.lab1 -text $caption(pretrfc,SoustrNrPLU)
         pack $This.et5.ligne3.lab1 -side left
         radiobutton $This.et5.ligne3.rad1 -variable conf_pt_fc(modePLU) \
            -text $caption(pretrfc,NrPLUBut1) -value simple
         pack $This.et5.ligne3.rad1 -side left
         radiobutton $This.et5.ligne3.rad2 -variable conf_pt_fc(modePLU) \
            -text $caption(pretrfc,NrPLUBut2) -value rapTps
         pack $This.et5.ligne3.rad2 -side left
         radiobutton $This.et5.ligne3.rad3 -variable conf_pt_fc(modePLU) \
            -text $caption(pretrfc,NrPLUBut3) -value opt
         pack $This.et5.ligne3.rad3 -side left
      pack $This.et5.ligne3 -side top -fill x
      #--- Quatrieme ligne de l'etape 5
      frame $This.et5.ligne4
         label $This.et5.ligne4.lab1 -text $caption(pretrfc,NoteSoustrNrPLU)
         pack $This.et5.ligne4.lab1 -side left
      pack $This.et5.ligne4 -side top -fill x
   pack $This.et5 -side top -fill x

   #--- Trame de l'etape 6
   frame $This.et6 -borderwidth 2 -relief groove
      #--- Titre de l'etape 6: Pretraitement des PLU
      frame $This.et6.titre -borderwidth 1 -relief groove
         #--- Affichage du titre
         label $This.et6.titre.nom -text $caption(pretrfc,titret6) -justify left
         pack $This.et6.titre.nom -side left -in $This.et6.titre
         #--- Affichage de la case a cocher pour l'activation de la correction cosmetique
         checkbutton $This.et6.titre.case -text $caption(pretrfc,corcosm) \
            -variable conf_pt_fc(cosmBrut)
         pack $This.et6.titre.case -side right -in $This.et6.titre
      pack $This.et6.titre -side top -fill x
      #--- Bouton GO
      button $This.et6.go -borderwidth 2 -width 5 -text $caption(pretrfc,goet) \
         -command {
            #--- Sauvegarde des parametres dans le fichier de config
            ::pretrfc::SauvegardeParametres
            #--- Traitement etape 6
            ::pretrfc::goBrut
         }
      pack $This.et6.go -side right -anchor sw -in $This.et6 \
         -padx 3 -pady 3 -ipady 3
      #--- Premiere ligne de l'etape 6
      frame $This.et6.ligne1
         #--- Affichage du label "Nom des fichiers source"
         label $This.et6.ligne1.nmBrutSce -text $caption(pretrfc,nmBrutSce) \
            -width 29
         pack $This.et6.ligne1.nmBrutSce -side left
         #--- Affichage du champ de saisie "Nom des fichiers source"
         entry $This.et6.ligne1.entnmBrutSce -width 16 -relief flat\
            -textvariable conf_pt_fc(nmBrutSce) -justify left -borderwidth 1 -relief groove
         pack $This.et6.ligne1.entnmBrutSce -side left
         #--- Affichage du label "Nombre de fichiers source"
         label $This.et6.ligne1.nbBrut -text $caption(pretrfc,nb)
         pack $This.et6.ligne1.nbBrut -side left
         #--- Affichage du champ de saisie "Nombre de fichiers source"
         entry $This.et6.ligne1.entNbBrut -width 3 -relief flat\
            -textvariable conf_pt_fc(nbBrut) -justify center -borderwidth 1 -relief groove
         pack $This.et6.ligne1.entNbBrut -side left
      pack $This.et6.ligne1 -side top -fill x
      #--- Seconde ligne de l'etape 6
      frame $This.et6.ligne2
         #--- Affichage du label "Nom du fichier resultant"
         label $This.et6.ligne2.lab1 -text $caption(pretrfc,nmBrutRes) \
            -width 29 -justify right
         pack $This.et6.ligne2.lab1 -side left
         #--- Affichage du champ de saisie "Nom du fichier resultant"
         entry $This.et6.ligne2.ent1 -width 16 -relief flat\
            -textvariable conf_pt_fc(nmBrutRes) -justify left -borderwidth 1 -relief groove
         pack $This.et6.ligne2.ent1 -side left
      pack $This.et6.ligne2 -side top -fill x
      #--- Troisieme ligne de l'etape 6
      frame $This.et6.ligne3
         label $This.et6.ligne3.lab1 -text $caption(pretrfc,SoustrNr)
         pack $This.et6.ligne3.lab1 -side left
         radiobutton $This.et6.ligne3.rad1 -variable conf_pt_fc(modeBrut) \
            -text $caption(pretrfc,NrBut1) -value simple
         pack $This.et6.ligne3.rad1 -side left
         radiobutton $This.et6.ligne3.rad2 -variable conf_pt_fc(modeBrut) \
            -text $caption(pretrfc,NrBut2) -value rapTps
         pack $This.et6.ligne3.rad2 -side left
         radiobutton $This.et6.ligne3.rad3 -variable conf_pt_fc(modeBrut) \
            -text $caption(pretrfc,NrBut3) -value opt
         pack $This.et6.ligne3.rad3 -side left
      pack $This.et6.ligne3 -side top -fill x
      #--- Quatrieme ligne de l'etape 6
      frame $This.et6.ligne4
         label $This.et6.ligne4.lab1 -text $caption(pretrfc,NoteSoustrNr)
         pack $This.et6.ligne4.lab1 -side left
      pack $This.et6.ligne4 -side top -fill x
   pack $This.et6 -side top -fill x

   #--- Trame pour la configuration et l'aide
   frame $This.but -borderwidth 2 -relief groove
      #--- Bouton Configuration
      button $This.but.config -borderwidth 2 -width 15 -text $caption(pretrfc,configuration) \
         -command "::pretrfcSetup::run 1 $This.pretrfcSetup"
      pack $This.but.config -side left -anchor sw -in $This.but \
         -padx 3 -pady 3 -ipady 3
      #--- Bouton Fermer
      button $This.but.fermer -borderwidth 2 -width 9 -text $caption(pretrfc,fermer) \
         -command { ::pretrfc::ArretPretraitFC }
      pack $This.but.fermer -side right -anchor w -in $This.but \
         -padx 3 -pady 3 -ipady 3
      #--- Bouton Aide
      button $This.but.aide -borderwidth 2 -width 5 -text $caption(pretrfc,aide) \
         -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::pretrfc::getPluginType ] ] \
            [ ::pretrfc::getPluginDirectory ] [ ::pretrfc::getPluginHelp ]"
      pack $This.but.aide -side right -anchor sw -in $This.but \
         -padx 3 -pady 3 -ipady 3
   pack $This.but -side top -fill x

   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#---------------------------------------------------------------------------------------------
# Fin du fichier pretrfc.tcl
#---------------------------------------------------------------------------------------------

