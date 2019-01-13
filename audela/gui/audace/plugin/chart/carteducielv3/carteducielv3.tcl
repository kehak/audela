#
## @file carteducielv3.tcl
#  @brief Plugin de communication avec "Cartes du Ciel" (communication TCP)
#  pour afficher la carte du champ des objets selectionnes dans Aud'ACE
#  @details Fonctionne avec Windows et Linux
#  @authors Michel PUJOL et Patrick CHEVALLEY
#  $Id: carteducielv3.tcl 14218 2017-06-05 18:51:53Z robertdelmas $
#

## @namespace carteducielv3
#  @brief Plugin de communication avec "Cartes du Ciel" (communication TCP)


namespace eval ::carteducielv3 {

   package provide carteducielv3 2.0
   source [ file join [file dirname [info script]] carteducielv3.cap ]

   #------------------------------------------------------------
   #  brief   retourne le titre du plugin dans la langue de l'utilisateur
   #
   proc getPluginTitle { } {
      global caption

      return "$caption(carteducielv3,titre)"
   }

   #------------------------------------------------------------
   #  brief  retourne le nom du fichier d'aide principal
   #
   proc getPluginHelp { } {
      return "carteducielv3.htm"
   }

   #------------------------------------------------------------
   #  brief retourne le répertoire du plugin
   #
   proc getPluginDirectory { } {
      return "carteducielv3"
   }

   #------------------------------------------------------------
   #  brief    retourne le type de plugin
   #
   proc getPluginType { } {
      return "chart"
   }

   #------------------------------------------------------------
   ## @brief   retourne le ou les OS de fonctionnement du plugin
   #  @return  liste des OS : "Windows Linux Darwin"
   #
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
   }

   #------------------------------------------------------------
   ## @brief retourne la valeur de la propriété
   #  @param propertyName : nom de la propriété
   #  @return rien (pas de propriété pour Cartes du Ciel)
   #
   proc getPluginProperty { propertyName } {
      return ""
   }

   #------------------------------------------------------------
   ## @brief démarre le plugin (rien a faire pour Cartes du Ciel)
   #
   proc createPluginInstance { } {
      return
   }

   #------------------------------------------------------------
   ## @brief arrête le plugin
   #
   proc deletePluginInstance { } {
      #--- rien a faire pour Cartes du Ciel
      return
   }

   #------------------------------------------------------------
   ## @brief informe de l'état de fonctionnement du plugin
   #  return
   #  - 0 (ready),
   #  - 1 (not ready)
   #
   proc isReady { } {

      set ready [ openConnection ]
      if { $ready == 0 } {
         closeConnection
      }
      return $ready
   }

   #------------------------------------------------------------
   ## @ brief initialise le plugin
   #
   proc initPlugin { } {
      #--- Je cree les variables dans conf(...)
      initConf
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de Cartes du Ciel
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini"
   #  - conf(carteducielv3,fixedfovstate)
   #  - conf(carteducielv3,fixedfovvalue)
   #  - conf(carteducielv3,binarypath)
   #  - conf(carteducielv3,localserver)
   #  - conf(carteducielv3,host)
   #  - conf(carteducielv3,port)
   #  @todo commenter les variables conf
   #
   proc initConf { } {
      variable private
      global conf

      if { ! [ info exists conf(carteducielv3,fixedfovstate) ] } { set conf(carteducielv3,fixedfovstate) "1" }
      if { ! [ info exists conf(carteducielv3,fixedfovvalue) ] } { set conf(carteducielv3,fixedfovvalue) "05d00m00s" }
      if { $::tcl_platform(os) == "Linux" } {
         if { ! [ info exists conf(carteducielv3,binarypath) ] } {
            if { [ catch { exec which $conf(carteducielv3,binaryname) } cdcv3 ] } {
               # soit skychart n'est pas installé, soit il n'est pas localisable, on prend /usr/bin faute de mieux
               set conf(carteducielv3,binarypath) [ file join / usr bin ]
            } else {
               # skychart est localisable, on récupère le chemin d'accès
               set conf(carteducielv3,binarypath) [ file dirname $cdcv3 ]
            }
         }
      } else {
         if { ! [ info exists conf(carteducielv3,binarypath) ] } { set conf(carteducielv3,binarypath)    "$::env(ProgramFiles)" }
      }
      if { ! [ info exists conf(carteducielv3,localserver) ] }   { set conf(carteducielv3,localserver)   "1" }
      if { ! [ info exists conf(carteducielv3,host) ] }          { set conf(carteducielv3,host)          "127.0.0.1" }
      if { ! [ info exists conf(carteducielv3,port) ] }          { set conf(carteducielv3,port)          "3292" }

      set private(socket) ""

      #--- Temoin de premier lancement (n'a jamais ete lance)
      set private(premierLancement) 0

      return
   }

   #------------------------------------------------------------
   # brief copie les paramètres du tableau conf() dans les variables des widgets
   #
   proc confToWidget { } {
      variable widget
      global conf

      set widget(fixedfovstate) "$conf(carteducielv3,fixedfovstate)"
      set widget(fixedfovvalue) "$conf(carteducielv3,fixedfovvalue)"
      set widget(binarypath)    "$conf(carteducielv3,binarypath)"
      set widget(localserver)   "$conf(carteducielv3,localserver)"
      set widget(cdchost)       "$conf(carteducielv3,host)"
      set widget(cdcport)       "$conf(carteducielv3,port)"

   }

   #------------------------------------------------------------
   #  brief copie les variable des widgets dans le tableau conf()
   #
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(carteducielv3,fixedfovstate) "$widget(fixedfovstate)"
      set conf(carteducielv3,fixedfovvalue) "$widget(fixedfovvalue)"
      set conf(carteducielv3,binarypath)    "$widget(binarypath)"
      set conf(carteducielv3,localserver)   "$widget(localserver)"
      set conf(carteducielv3,host)          "$widget(cdchost)"
      set conf(carteducielv3,port)          "$widget(cdcport)"
   }

   #------------------------------------------------------------
   #  brief créé la fenêtre de configuration du plugin
   #
   proc fillConfigPage { frm } {
      variable widget
      global audace caption

      #--- Je memorise la reference de la frame
      set widget(frm) $frm

      #--- J'initialise les valeurs
      confToWidget

      #--- Definition du champ (FOV)
      frame $frm.frame1 -borderwidth 0 -relief raised

         label $frm.frame1.labFOV -text "$caption(carteducielv3,fov_label)"
         pack $frm.frame1.labFOV -anchor center -side left -padx 10 -pady 10

         checkbutton $frm.frame1.fovState -text "$caption(carteducielv3,fov_state)" \
            -highlightthickness 0 -variable ::carteducielv3::widget(fixedfovstate)
         pack $frm.frame1.fovState -anchor center -side left -padx 10 -pady 5

         label $frm.frame1.labFovValue -text "$caption(carteducielv3,fov_value)"
         pack $frm.frame1.labFovValue -anchor center -side left -padx 10 -pady 10

         entry $frm.frame1.fovValue -textvariable ::carteducielv3::widget(fixedfovvalue) -width 10
         pack $frm.frame1.fovValue -anchor center -side left -padx 10 -pady 5

      pack $frm.frame1 -side top -fill x

      #--- Recherche manuelle de l'executable de Cartes du Ciel
      frame $frm.frame2 -borderwidth 0 -relief raised

         label $frm.frame2.recherche -text "$caption(carteducielv3,rechercher)"
         pack $frm.frame2.recherche -anchor center -side left -padx 10 -pady 7 -ipadx 10 -ipady 5

         entry $frm.frame2.chemin -textvariable ::carteducielv3::widget(binarypath)
         pack $frm.frame2.chemin -anchor center -side left -padx 10 -fill x -expand 1

         button $frm.frame2.explore -text "$caption(carteducielv3,parcourir)" -width 1 \
            -command "::carteducielv3::searchFile"
         pack $frm.frame2.explore -side right -padx 10 -pady 5 -ipady 5

      pack $frm.frame2 -side top -fill x

      #--- Adresse IP du serveur distant
      frame $frm.frame3 -borderwidth 0 -relief raised

         label $frm.frame3.labcdchost -text "$caption(carteducielv3,cdchost)"
         pack $frm.frame3.labcdchost -anchor center -side left -padx 10 -pady 7

         entry $frm.frame3.cdchost -width 17 -textvariable ::carteducielv3::widget(cdchost)
         pack $frm.frame3.cdchost -anchor center -side left -padx 15 -pady 10

         label $frm.frame3.labcdcport -text "$caption(carteducielv3,cdcport)"
         pack $frm.frame3.labcdcport -anchor center -side left -padx 10 -pady 7

         entry $frm.frame3.cdcport -width 5 -textvariable ::carteducielv3::widget(cdcport)
         pack $frm.frame3.cdcport -anchor center -side left -padx 5 -pady 7

         button $frm.frame3.ping -text "$caption(carteducielv3,testping)" -relief raised -state normal \
            -command {
               global caption

               set res  [::audace_ping $::carteducielv3::widget(cdchost) ]
               set res1 [lindex $res 0]
               set res2 [lindex $res 1]
               if {$res1==1} {
                  set tres1 "$caption(carteducielv3,appareil_connecte) $::carteducielv3::widget(cdchost)"
               } else {
                  set tres1 "$caption(carteducielv3,pas_appareil_connecte) $::carteducielv3::widget(cdchost)"
               }
               set tres2 "$caption(carteducielv3,message_ping)"
               tk_messageBox -message "$tres1.\n$tres2 $res2" -icon info
            }
         pack $frm.frame3.ping -anchor center -side top -pady 7 -ipadx 10 -ipady 5 -expand true

      pack $frm.frame3 -side top -fill both -expand 1

      #--- Site web officiel de Cartes du Ciel
      frame $frm.frame4 -borderwidth 0 -relief raised

         label $frm.frame4.labSite -text "$caption(carteducielv3,site_web)"
         pack $frm.frame4.labSite -side top -fill x -pady 2

         set labelName [ ::confCat::createUrlLabel $frm.frame4 "$caption(carteducielv3,site_web_ref)" \
            "$caption(carteducielv3,site_web_ref)" ]
         pack $labelName -side top -fill x -pady 2

      pack $frm.frame4 -side bottom -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $frm
   }

   #------------------------------------------------------------
   #  brief lancement de la recherche du fichier executable de Cartes du Ciel
   #
   proc searchFile { } {
      variable widget

      set widget(binarypath) [ ::tkutil::box_load $widget(frm) $widget(binarypath) $::audace(bufNo) "11" ]
      if { $widget(binarypath) == "" } {
         set widget(binarypath) $::conf(carteducielv3,binarypath)
      }
   }

   #==============================================================
   # Fonctions specifiques du plugin de la categorie "catalog"
   #==============================================================

   #------------------------------------------------------------
   ## @brief affiche la carte de champ de l'objet choisi
   #  @param nom_objet  : nom de l'objet   (ex : "NGC7000")
   #  @param ad         : ascension droite (ex : "16h41m42s")
   #  @param dec        : déclinaison      (ex : "+36d28m00s")
   #  @param zoom_objet : champ de 1 a 10
   #  @param avant_plan :
   #  - 1 = mettre la carte au premier plan,
   #  - 0 = ne pas mettre au premier plan
   #
   proc gotoObject { nom_objet ad dec zoom_objet avant_plan } {
      set result "0"
      #::console::disp "::carteducielv3::gotoObject $nom_objet, $ad, $dec, $zoom_objet, $avant_plan, \n"
      if { $nom_objet != "#etoile#" && $nom_objet != "" } {
         selectObject $nom_objet
      } else {
         moveCoord $ad $dec
      }
   }

   #------------------------------------------------------------
   ## @brief centre la fenêtre de Cartes du Ciel sur les coordonnées passées en paramètres
   #  et fixe le champ de diamètre fov
   #  @details envoie à Cartes du Ciel "MOVE RA: xxhxxmxxs.00s DEC:xxdxx'xx" FOV:xxdxx'xx"
   #  @return
   #  - 0 (OK)
   #  - 1 (error)
   #
   proc moveCoord { ra dec } {
      global conf

      #--- je fixe la taille du champ de la carte
      if { $conf(carteducielv3,fixedfovstate) != 0 } {
         #--- j'utilise le champ fixe
         set fov $conf(carteducielv3,fixedfovvalue)
         #--- je remplace les unites par des espaces
         if { [ sendRequest "SETFOV $fov" ] != "OK!" } {
            return 1
         }
      }

      set command "SETRA RA:$ra"
      if { [ sendRequest $command ] != "OK!" } {
         return 1
      }

      set command "SETDEC DEC:$dec"
      if { [ sendRequest $command ] != "OK!" } {
         return 1
      }

      if { [ sendRequest "REDRAW" ] != "OK!" } {
         return 1
      }

      return 0
   }

   #------------------------------------------------------------
   ## @brief sélectionne un objet dans CarteDuCiel
   #  @param objectName nom de l'objet
   #  @return
   #  - "0" (OK),
   #  - "1" error)
   #
   proc selectObject { objectName } {
      global conf

      #--- je fixe la taille du champ de la carte
      if { $conf(carteducielv3,fixedfovstate) == 1 } {
         #--- j'utilise le champ fixe
         set fov $conf(carteducielv3,fixedfovvalue)
         if { [ sendRequest "SETFOV $fov" ] != "OK!" } {
            return 1
         }
      }

      #--- j'envoie la requete vers Cartes du Ciel v3
      if { [ sendRequest "search $objectName" ] == "Not found!" } {
         return 1
      }

      return 0
   }

   #------------------------------------------------------------
   ## @brief récupère les coordonnées et le nom de l'objet sélectionné dans CarteDuCiel
   #  @return
   #  - [list $ra $dec $equinox $objName $magnitude] avec
   #   -# $ra        : right ascension        (ex : "16h41m42")
   #   -# $dec       : declinaison           (ex : "+36d28m00")
   #   -# $equinox   : equinoxe           (ex: "J2000.0" ou "now" )
   #   -# $objName   : object name       (ex : "M 13")
   #   -# $magnitude : object magnitude (ex: "5.6")
   #  - "" si erreur
   #
   #  Description de l'interface Audela / CarteDuCiel
   #  -------------------------------------
   #  Requête TCP envoyée a CarteDuCiel :
   #  @code
   #     puts socket "GETSELECTEDOBJECT"
   #  @endcode
   #  Réponse retournée par CarteDuCiel :
   #  - une ligne concernant le dernier objet sélectionné sur la carte, par exemple :
   #  @code
   #  OK!  18h46m04.48s  +26°39'43.7"     *   HD173780 mV: 4.83 HD:173780   BD:BD+26 3349  HIP: 92088  HR:7064  b-v: 1.20   mB: 6.03 sp:K2III                      pmRA:    18 [mas/y]  pmDE:    24 [mas/y]  px:  12.8 [mas]   Dist:254.8 [ly]   Comp:          Const:Lyr   RV:-17.06 [km/s]  mI:3.8      Equinox:J2000.0
   #  @endcode
   #
   #  - Les coordonnées et le nom de l'objet sont extraits de la ligne
   #  - Les autres lignes ne sont pas utilisées.
   #  - Tout les champs après OK! sont séparés par des tabulations.
   #
   #  Format de la ligne : OK! "$ra $dec $objType $detail", avec :
   #     - $ra      = right ascension  ex: "16h42m11.67s"
   #     - $dec     = declinaison      ex: "+36°26'18.9"
   #     - $objType = object type      ex: "Gb"
   #     - $detail  = object detail    ex :"M  13              m: 5.80  Name:NGC 6205           sbr:12.00   Dim: 23.2 x 23.2 '   pa: 90   class:VOliptical  desc:!!eB;vRi;vgeCM;*11...;Hercules cluster;Messier said round nebula contains no star                                        Const:HER      Equinox:now"
   #
   #  Mise en forme de la réponse
   #  ---------------------------
   #  1) Mise en forme de l'ascension droite $ra :
   #     - supprimer les fractions de secondes dans $ra
   #
   #  2) Mise en forme de la declinaison $dec :
   #     - remplacer "°" par "d"
   #     - remplacer "'" par "m"
   #     - remplacer """ par "s"
   #     - supprimer les fractions de secondes
   #
   #  3) Mise en forme du nom de l'objet $objName
   #     - On prend le nom par défaut de Cartes du Ciel dans le premier champ.
   #     - Un ou des noms supplémentaires sont parfois présent après la magnitude, on les ignore.
   #
   #  le catalogue externe UGC peut être trouvé sur :
   #     http://www.astrogeek.org/ftp/pub/cdc/ugc2001a.exe (version catgen)
   #
   proc getSelectedObject { } {
      global caption

      #--- nouvelle commande depuis la version 3.9, retourne la meme chaine qu'avant 3.6
      set result [ sendRequest "GETSELECTEDOBJECT" ]

      ##### Version du CdC trop ancienne
      if { $result == "Failed! Bad command name" } {
         ::console::affiche_erreur "$caption(carteducielv3,wrong_version)\n\n"
         tk_messageBox -icon error -message $caption(carteducielv3,wrong_version) -type ok
         return ""
      }
      #####

      if { $result == "" } {
         return ""
      }

      #--- je separe les coordonnees des autres donnees
      set ligne $result
      set cr  ""
      set ra  ""
      set dec ""
      set objType ""
      set detail ""
      set magnitude ""
      scan $ligne "%s %s\t%s\t%s\t%\[^\r\] " cr ra dec objType detail

      #::console::disp "CDC ----------------\n"
      #::console::disp "CDC entry cr=$cr\n"
      #::console::disp "CDC entry ra=$ra\n"
      #::console::disp "CDC entry dec=$dec\n"
      #::console::disp "CDC entry objType=$objType\n"
      #::console::disp "CDC entry detail=$detail \n"
      #::console::disp "CDC ----------------\n"

      if { $cr != "OK!" } {
         ::console::affiche_erreur "$caption(carteducielv3,no_object_select)\n\n"
         return ""
      }

      #--- Mise en forme de ra
      set ra [lindex [split $ra "."] 0]

      #--- Mise en forme de dec
      #--- je remplace les unites par d, m, s
      set dec [string map { "\°" d "ß" d "\'" m "\"" s } $dec ]
      #--- je remplace le quatrieme caractere par "d"
      set dec [string replace $dec 3 3 "d" ]
      #--- je supprime les diziemes de secondes apres le point decimal
      set dec [lindex [split $dec "."] 0]
      #--- j'ajoute l'unite des secondes
      append dec "s"

      #::console::disp "detail = |$detail|\n"

      #--- Equinox
      set index [string first "\tEquinox:" $detail]
      if { $index >= 0 } {
         #--- j'extrais l'equinoxe des coordonnees
         set equinox [lindex [split [string range $detail [expr $index+9] end] "\t"] 0]
      } else {
         set equinox "now"
      }

      #-- Nom de l'objet est le premier champ jusqu'a la tabulation
      set objName [string trim [lindex [split [string range $detail 0 end] "\t"] 0]]
      #::console::disp "objName par defaut $objName\n"

      #--- Mise en forme de la magnitude
      set index [string first "\tmV:" $detail]
      if { $index >= 0 } {
         #--- j'extrais la magnitude mV
         set magnitude [lindex [split [string range $detail [expr $index+4] end] "\t"] 0]
      } else {
         set index [string first "\tm:" $detail]
         if { $index >= 0 } {
            #--- j'extrais la magnitude m
            set magnitude [lindex [split [string range $detail [expr $index+3] end] "\t"] 0]
         } else {
            #--- etoiles variables, j'extrais les magnitudes mMax et mMin
            set index [string first "\tmMax:" $detail]
            if { $index >= 0 } {
               set mMax [lindex [split [string range $detail [expr $index+6] end] "\t"] 0]
               set index [string first "\tmMin:" $detail]
               set mMin [lindex [split [string range $detail [expr $index+6] end] "\t"] 0]
               set magnitude "$mMax - $mMin"
            } else {
               #--- etoiles doubles, j'extrais les magnitudes du premier et du second composant
               set index [string first "\tm1:" $detail]
               if { $index >= 0 } {
                  set m1 [lindex [split [string range $detail [expr $index+4] end] "\t"] 0]
                  set index [string first "\tm2:" $detail]
                  set m2 [lindex [split [string range $detail [expr $index+4] end] "\t"] 0]
                  set magnitude "$m1 - $m2"
               }
            }
         }
      }

      ::console::disp "CDC result objName=$objName\n"
      ::console::disp "CDC result ra=$ra\n"
      ::console::disp "CDC result dec=$dec\n"
      ::console::disp "CDC result equinox=$equinox\n"
      ::console::disp "CDC result magnitude=$magnitude\n\n"

      return [list $ra $dec $equinox $objName $magnitude]
   }

   #------------------------------------------------------------
   ## @brief lance le logiciel CarteDuciel V3
   #  @return
   #  - 0 (OK)
   #  - 1 (error)
   #
   proc launch { } {
      global audace caption conf

      #--- Initialisation
      #--- Recherche l'absence de l'entry conf(carteducielv3,binarypath)
      if { [info exists conf(carteducielv3,binarypath)] == 0 } {
         tk_messageBox -type ok -icon error -title "$caption(carteducielv3,attention)" \
            -message "$caption(carteducielv3,verification)"
         return "1"
      }
      #--- Stocke le nom du chemin courant et du programme dans une variable
      set filename $conf(carteducielv3,binarypath)
      #--- Stocke le nom du chemin courant dans une variable
      set pwd0 [pwd]
      #--- Extrait le nom du repertoire
      set dirname [file dirname "$conf(carteducielv3,binarypath)"]
      #--- Place temporairement AudeLA dans le dossier de CDC
      cd "$dirname"
      #--- Prepare l'ouverture du logiciel
      set a_effectuer "exec \"$filename\" &"

      #--- Ouvre le logiciel
      catch $a_effectuer pid
      if {[regexp -all {^[0-9]{1,5}} $pid] eq "1"} {
         set res 0
         #--- J'attends que Cartes du Ciel soit completement demarre
         after 4000
      } else {
         #--- Affichage du message d'erreur sur la console
         ::console::affiche_erreur "$caption(carteducielv3,rate)\n"
         ::console::affiche_saut "\n"
         #--- Ouvre la fenetre de configuration des cartes
         ::confCat::run "carteducielv3"
         set res 1
      }

      #--- Ramene AudeLA dans son repertoire
      cd "$pwd0"

      return $res
   }

   #==============================================================
   # Fonctions de communication avec Cartes du Ciel v3
   #==============================================================

   #------------------------------------------------------------
   #  brief envoie une commande sur la liaison TCP
   #  param req requête
   #  return
   #  - la réponse fournie par CDC
   #  - "" si erreur
   #
   proc sendRequest { req } {
      variable private
      global caption

      #--- j'ouvre la connexion vers CarteDuCiel
      if { [ openConnection ] == 1 } {
         #--- si erreur :
         set choix [tk_messageBox -type yesno -icon warning -title "$caption(carteducielv3,attention)" \
            -message "$caption(carteducielv3,option) $caption(carteducielv3,creation)\n\n$caption(carteducielv3,lance)"]
         if { $choix == "yes" } {
            set erreur [launch]
            if { $erreur == "1" } {
               tk_messageBox -type ok -icon error -title "$caption(carteducielv3,attention)" \
                  -message "$caption(carteducielv3,verification)"
               return ""
            }
            #--- nouvelle tentative apres le lancement
            if { [ openConnection ] == 1 } {
               ::console::affiche_erreur "$caption(carteducielv3,no_connect)\n\n"
               tk_messageBox -message "$caption(carteducielv3,no_connect)" -icon info
               return ""
            }
            #--- Temoin de premier lancement (n'a jamais ete lance)
            set private(premierLancement) 0
         } else {
            return ""
         }
      } else {
         #--- Temoin de premier lancement (a deja ete lance)
         set private(premierLancement) 1
      }

      set result ""
      catch {
         #::console::disp "sendRequest socket=$private(socket)\n"
         #::console::disp "sendRequest REQ= $req\n"
         puts  $private(socket) $req
         flush $private(socket)
         set result [gets $private(socket)]
         #::console::disp "sendRequest REP= $result\n"
      }

      #--- je ferme la connexion
      closeConnection
      return $result
   }

   #------------------------------------------------------------
   #  brief ouvre la connexion vers CarteDuCiel V3 (socket TCP)
   #  return
   #  - 0 (OK)
   #  - 1 (error)
   #
   proc openConnection { } {
      variable private
      global conf

      set result 1
      catch {
         #::console::disp "openConnection host=$conf(carteducielv3,host) port=$conf(carteducielv3,port)\n"
         set private(socket) [socket $conf(carteducielv3,host) $conf(carteducielv3,port)]
         #::console::disp "openConnection private(socket)=$private(socket)\n"
         if {[string compare -length 4 $private(socket) "sock"] == 0} {
            #::console::disp "CONNECT= $private(socket)\n"
            set result 0
         }
      } msg

      return $result
   }

   #------------------------------------------------------------
   #  brief ferme la liaison TCP
   #
   proc closeConnection { } {
      variable private

      puts  $private(socket) "QUIT"
      close $private(socket)
      #::console::disp "closeConnection socket=$private(socket)\n"
   }

}

