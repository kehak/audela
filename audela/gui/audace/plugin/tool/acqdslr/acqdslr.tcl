#
# Fichier : acqdslr.tcl
# Description : Outil d'acquisition pour APN Canon
# Auteur : Raymond Zachantke
# Mise à jour $Id: acqdslr.tcl 13000 2016-01-30 23:10:32Z robertdelmas $
#

#============================================================
# Declaration du namespace acqdslr
#    initialise le namespace
#============================================================
namespace eval ::acqdslr {
   package provide acqdslr 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]]  acqdslr.cap ]

   #------------------------------------------------------------
   # getPluginTitle
   #    retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(acqdslr,title)"
   }

   #------------------------------------------------------------
   # getPluginHelp
   #    retourne le nom du fichier d'aide principal
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "acqdslr.htm"
   }

   #------------------------------------------------------------
   # getPluginType
   #    retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   # getPluginDirectory
   #    retourne le repertoire du plugin
   #------------------------------------------------------------
   proc getPluginDirectory { } {
      return "acqdslr"
   }

   #------------------------------------------------------------
   # getPluginOS
   #    retourne le ou les OS de fonctionnement du plugin
   #------------------------------------------------------------
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
   }

   #------------------------------------------------------------
   # getPluginProperty
   #    retourne la valeur de la propriete
   #
   # parametre :
   #    propertyName : nom de la propriete
   # return : valeur de la propriete ou "" si la propriete n'existe pas
   #------------------------------------------------------------
   proc getPluginProperty { propertyName } {
      switch $propertyName {
         function     { return "acquisition" }
         subfunction  { return "dslr" }
         display      { return "panel" }
      }
   }

   #------------------------------------------------------------
   # createPluginInstance
   #    cree une nouvelle instance de l'outil
   #------------------------------------------------------------
   proc createPluginInstance { base { visuNo 1 } } {
      global panneau

      #--- Mise en place de l'interface graphique
      createPanel $base.acqdslr
      #---
      return $base.acqdslr
   }

   #------------------------------------------------------------
   # deletePluginInstance
   #    suppprime l'instance du plugin
   #------------------------------------------------------------
   proc deletePluginInstance { visuNo } {

   }

   #------------------------------------------------------------
   # createPanel
   #    prepare la creation de la fenetre de l'outil
   #------------------------------------------------------------
   proc createPanel { this } {
      global audace panneau caption color
      variable This
      variable Dslr

      #---
      set This $this
      #---
      set panneau(acqdslr,base)  "$this"

      #---
      frame $This -borderwidth 2 -relief groove
      pack $This
      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove
         #--- Bouton du titre
         Button $This.fra1.but -borderwidth 1 \
            -text "$caption(acqdslr,help_titre1)\n$caption(acqdslr,title)" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::acqdslr::getPluginType ] ] \
               [ ::acqdslr::getPluginDirectory ] [ ::acqdslr::getPluginHelp ]"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
      DynamicHelp::add $This.fra1.but -text $caption(acqdslr,help_titre)
      pack $This.fra1 -side top -fill x

      #--   le nom du frame cantonnant le DSLR et le bouton GO
      set Dslr $This.dslr

      searchInfoDslr

      #--- Mise ajour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #########################################################################
   #--   Au lancement collecte les donnees sur la camera et les memorise   #
   #########################################################################
   proc searchInfoDslr {} {
      global audace panneau caption

      #--   ouvre la liste des types de declenchement
      set panneau(acqdslr,poseLabels) [ list "<30" ]

      #--   complete l'etat
      lappend panneau(acqdslr,status) [ list "0" ]

      #--   valeur par defaut de la liste des formats
      set panneau(acqdslr,qualityLabels) [ list "RAW" ]

      #--   liste les modes de prise de vue
      set panneau(acqdslr,bracketLabels) \
         [ list "$caption(acqdslr,bracket,one)" \
            "$caption(acqdslr,bracket,serie)" \
            "$caption(acqdslr,bracket,continu)" ]

      #--   liste les pas du bracketing
      set panneau(acqdslr,stepLabels) \
         [ list "+6" "+5" "+4" "+3" "+2" "+1" \
            0 "-1" "-2" "-3" "-4" "-5" "-6" ]

      #--   liste les vitesses standards
      set panneau(acqdslr,exptimeLabels) [ list "30" "25" "20" "15" "13" \
         "10" "8" "6" "5" "4" "3.2" "2.5" "2.0" "1.6" "1.3" \
         "1.0"  "0.8" "0.6" "0.5" "0.4" "0.3" "1/4" "1/5" "1/6" "1/8" \
         "1/10" "1/13" "1/15" "1/20" "1/25" "1/30" "1/40" "1/50" "1/60" "1/80" \
         "1/100" "1/125" "1/160" "1/200" "1/250" "1/320" "1/400" "1/500" "1/640" "1/800" \
         "1/1000" "1/1250" "1/1600" "1/2000" "1/2500" "1/3200" "1/4000" "1/5000" "1/6400" "1/8000" ]

      set panneau(acqdslr,exptimeValues) [ list "30" "25" "20" \
         "15" "13" "10" "8" "6" "5" "4" "3.2" "2.5" "2" "1.6" "1.3" \
         "1" "0.8" "0.6" "0.5" "0.4" "0.3" "0.25" "0.2" "0.16667" "0.125" \
         "0.1" "0.076923" "0.06667" "0.05" "0.04" "0.03333" "0.025" "0.02" \
         "0.01667" "0.0125" "0.01" "0.008" "0.00625" "0.005" "0.004" \
         "0.003125" "0.0025" "0.002" "0.0015625" "0.00125" ".001" "0.0008" \
         "0.000625" "0.0005" "0.0004" "0.0003125" "0.00025" "0.0002" "0.00015625" "0.000125" ]

      set panneau(acqdslr,longueposeexptimeValues) [ list "40" "50" "60" \
         "70" "80" "90" "100" "110" "120" "130" "140" "150" "160" "170" "180" \
         "240" "300" "360" "420" "480" "540" "600" ]

      setCamProperty

      apnBuildIF
   }

   ######################################################################
   #--   Recupere les donnees de la cam                                 #
   ######################################################################
   proc setCamProperty { } {
      global panneau caption

      set panneau(acqdslr,camNo) "0"
      set cam_list [ ::cam::list ]

      #--   arrete si pas de cam
      if { $cam_list == "" } {
         return
      }

      #--   cherche une cam DSLR
      foreach camNo $cam_list {
         if { [ cam$camNo name ] == "DSLR" } {
            set panneau(acqdslr,camNo) $camNo
         }
      }

      #--   arrete si pas de DSLR
      if { $panneau(acqdslr,camNo) == "0" } {
         return
      }

      set camNo $panneau(acqdslr,camNo)

      #--   fixe drivemode a 0
      cam$camNo drivemode 0

      #--   liste les formats possibles
      set panneau(acqdslr,qualityLabels) [ cam$camNo quality list ]
      set panneau(acqdslr,quality) [ cam$camNo quality ]

      #--   si la camera est connectee en mode longue pose
      if [ cam$camNo longuepose ] {

         #--   complete la liste des types de declenchement
         lappend panneau(acqdslr,poseLabels) ">30"

         set panneau(acqdslr,longuepose) [ list $camNo \
            [ cam$camNo longueposelinkno ] \
            [ cam$camNo longueposelinkbit ] \
            [ cam$camNo longueposestartvalue ] \
            [ cam$camNo longueposestopvalue ] ]

         #--   ajoute le mode Rafale si la longuepose existe
         lappend panneau(acqdslr,bracketLabels) "$caption(acqdslr,bracket,rafale)"

         #--   memorise l'etat
         set panneau(acqdslr,status) [ lreplace $panneau(acqdslr,status) 0 0 "1" ]
         lappend panneau(acqdslr,status) "0"
      }
   }

   ######################################################################
   #--   Propose de connecter la cam et de reconfigurer le panneau      #
   ######################################################################
   proc connectCam  { } {
      global audace panneau caption
      variable Dslr

      ::confCam::run
      ::confCam::selectNotebook A dslr
      vwait audace(camNo)

      #--   rapatrie les donnes sur la connexion
      setCamProperty

      if { $panneau(acqdslr,camNo) != "0" } {
         #--   reconfigure le panneau
         destroy $Dslr
         apnBuildIF
      }
   }

   ######################################################################
   #--   Complete le panneau d'acquisition                              #
   ######################################################################
   proc apnBuildIF {} {
      global panneau caption
      variable Dslr

      #--   le frame cantonnant le DSLR et le bouton GO
      frame $Dslr -borderwidth 1 -relief sunken
      pack $Dslr -side top -fill x

      ::blt::table $Dslr

      #---   construit les menubutton
      foreach var { quality step bracket pose } {
         buildMenuButton $var
      }
      $Dslr.step configure -textvar "" -text $caption(acqdslr,step) -width 2
      $Dslr.pose configure -width 2

      #--   label pour afficher le format de l'image
      label $Dslr.format -textvariable panneau(acqdslr,format) \
         -width 4 -borderwidth 1

      #--   construit le bouton 'Test'
      button $Dslr.test -relief raised -width 10 -borderwidth 2 \
         -text $caption(acqdslr,test) -command "::acqdslr::testTime"

      #--   construit les entrees de donnees
      foreach var { nom nb_poses delai intervalle iter } {
         buildLabelEntry $var
      }
      $Dslr.nom configure -labelwidth 6 -width 10

      #--   la combobox pour le temps de pose
      ComboBox $Dslr.exptime -borderwidth 1 -width 8 -relief sunken \
         -height 10 -justify center -textvariable panneau(acqdslr,time) \
         -modifycmd "::acqdslr::test_bracketing ; ::acqdslr::convertExptime"

      #--   label pour afficher les etapes
      label $Dslr.state -textvariable panneau(acqdslr,action) \
         -width 14 -borderwidth 2 -relief sunken

      #--   configure le bouton de lancement d'acquisition
      button $Dslr.but1 -borderwidth 2 -text "$caption(acqdslr,go)" \
         -command "::acqdslr::shoot"

      #--   packaging des widgets
      ::blt::table $Dslr \
         $Dslr.format 1,0 \
         $Dslr.quality 1,1 \
         $Dslr.step 2,0 \
         $Dslr.bracket 2,1 \
         $Dslr.test 3,0 -cspan 2 \
         $Dslr.state 4,0 -cspan 2 \
         $Dslr.nom 5,0 -cspan 2 \
         $Dslr.nb_poses 6,0 -cspan 2 \
         $Dslr.pose 7,0 \
         $Dslr.exptime 7,1 \
         $Dslr.delai 8,0 -cspan 2 \
         $Dslr.intervalle 9,0 -cspan 2 \
         $Dslr.iter 10,0 -cspan 2 \
         $Dslr.but1 11,0 -cspan 2 -ipadx 15 -ipady 3 -fill x
         ::blt::table configure $Dslr r* -pady 2

      #--   ajoute les bulles d'aide
      foreach child { step test nom nb_poses pose delai iter } {
         DynamicHelp::add $Dslr.$child -text $caption(acqdslr,help$child)
      }

      initPar

      #--   demarre sur la configuration 'Une image'
      configImg
   }

   ######################################################################
   #--   Initialise les variables                                       #
   ######################################################################
   proc initPar {} {
      global audace panneau caption

      lassign { "" "0" "0" "1" "0" " " "" "0" } ::acqdslr::nom ::acqdslr::delai \
         panneau(acqdslr,intervalle_mini) ::acqdslr::iter panneau(acqdslr,test) \
         panneau(acqdslr,action) panneau(acqdslr,msgbox) panneau(acqdslr,serieNo)

      #--   selectionne le format actuel d'image
      set panneau(acqdslr,quality) [ lindex $panneau(acqdslr,qualityLabels) end ]

      #--   indique le format (jpeg ou fits)
      configFormat

      #--   selectionne le mode de prise de vue 'Une image"
      set panneau(acqdslr,bracket) [ lindex $panneau(acqdslr,bracketLabels) 0 ]

      #--   selectionne le nombre de pas "0"
      set panneau(acqdslr,step) [ lindex $panneau(acqdslr,stepLabels) 6 ]

      #--   selectionne le mode de declenchement de niveau le plus eleve
      set l [ llength  $panneau(acqdslr,poseLabels) ]
      incr l "-1"
      set panneau(acqdslr,pose) [ lindex $panneau(acqdslr,poseLabels) $l ]

      #--   selectionne la gamme de temps d'exposition
      configTimeScale $l

      #--   initalise le fichier log
      set rep "$audace(rep_images)"
      set nom "DSLR acqdslr "
      set date [clock format [clock seconds] -format "%A %d %B %Y"]
      set date [ ::tkutil::transalteDate $date ]
      append nom $date ".log"
      set panneau(acqdslr,log) [ file join $rep $nom ]
      #writeLog $panneau(acqdslr,log) "$caption(acqdslr,ouvsess)"
   }

   ######################################################################
   #--   Module de construction des boutons de menu avec les commandes  #
   ######################################################################
   proc buildMenuButton { var } {
      global panneau
      variable Dslr

      #--   raccourcis
      set data $panneau(acqdslr,${var}Labels)
      set camNo $panneau(acqdslr,camNo)

      menubutton $Dslr.$var -menu $Dslr.$var.m -relief raised \
         -width 10 -borderwidth 2 -textvar panneau(acqdslr,$var)
      menu $Dslr.$var.m -tearoff 0

      #--   specifie les commandes associees a chaque item du menu
      foreach label $data {
         set indice [ lsearch $data $label ]
         switch -exact $var {
          "bracket"     {  switch $indice {
                              "0"   {  set cmd "::acqdslr::configImg" }
                              "1"   {  set cmd "::acqdslr::configSerie" }
                              "2"   {  set cmd "::acqdslr::configContinu" }
                              "3"   {  set cmd "::acqdslr::configRafale" }
                           }
                        }
          "pose"        {  switch $indice {
                              "0"  {  set cmd "::acqdslr::switchExpTime 0" }
                              "1"  {  set cmd "::acqdslr::switchExpTime 1" }
                           }
                        }
          "quality"     {  set cmd "::acqdslr::configFormat" }
          "step"        {  set cmd "::acqdslr::test_bracketing" }
         }

         $Dslr.$var.m add radiobutton -label $label -indicatoron "1" \
            -value $label -variable panneau(acqdslr,$var) -command $cmd
      }
   }

   ######################################################################
   #--   Cree une entree avec un label                                  #
   #     parametre : nom descendant                                     #
   ######################################################################
   proc buildLabelEntry { child } {
      global caption
      variable Dslr

      LabelEntry $Dslr.$child -label $caption(acqdslr,$child) \
         -textvariable ::acqdslr::$child -labelanchor w -labelwidth 8 \
         -borderwidth 1 -relief flat -padx 2 -justify right \
         -width 8 -relief sunken
      bind $Dslr.$child <Leave> "::acqdslr::test_$child $Dslr $child"
   }

   #####################################################################
   #--   Configure l'entree du temps d'exposition                      #
   #     parametre : camNo choix ( si USB s =0 sinon s=1 )             #
   #####################################################################
   proc  configTimeScale { s } {
      global panneau
      variable Dslr

      switch $s {
         "0"   {  #--   met en place la liste standard
                  $Dslr.exptime configure -editable 0 -height 10 \
                     -values "$panneau(acqdslr,exptimeLabels)"
                  #--   selectionne 1 seconde
                  $Dslr.exptime setvalue @15
               }
         "1"   {  #--   met en place la liste ouverte
                  $Dslr.exptime configure -editable 0 -height 10 \
                     -values $panneau(acqdslr,longueposeexptimeValues)
                  #--   selectionne 31
                  $Dslr.exptime setvalue @0
               }
      }

      #--   transfert la valeur
      set ::acqdslr::exptime $panneau(acqdslr,time)
      update
   }

   ######################################################################
   #--   Configure le bouton USB/Longuepose                             #
   ######################################################################
   proc configPose {} {
      global panneau caption
      variable Dslr

      if { [ llength $panneau(acqdslr,poseLabels) ] == "2" \
         && $panneau(acqdslr,bracket) != "$caption(acqdslr,bracket,continu)" \
         && $panneau(acqdslr,bracket) != "$caption(acqdslr,bracket,rafale)" } {
            set etat "normal"
      } else {
         $Dslr.pose.m invoke 0
         set etat "disabled"
      }
      $Dslr.pose configure -state $etat
   }

   ######################################################################
   #--   Configure l'entree Intervalle                                  #
   ######################################################################
   proc configIntervalle { n } {
      global panneau caption
      variable Dslr

      set var "intervalle"
      set state "disabled"
      set val " "

      if { $n == "4" } {
         set var "duree"
         set val "1"
      }
      set ::acqdslr::intervalle $val

      if { ( $n == "2" && $panneau(acqdslr,test) == "1" ) || $n == "4" } {
         set state "normal"
      }

      $Dslr.intervalle configure -label "$caption(acqdslr,$var)" -state $state
      DynamicHelp::add $Dslr.intervalle -text $caption(acqdslr,help$var)
      update
   }

   ######################################################################
   #--   Configure le format et l'extension                             #
   ######################################################################
   proc configFormat { } {
      global panneau conf

      if { $panneau(acqdslr,quality) == "RAW" } {
         set panneau(acqdslr,format) "fits"
         set panneau(acqdslr,extension) "$conf(extension,defaut)"
      } else {
         set panneau(acqdslr,format) "jpeg"
         set panneau(acqdslr,extension) ".jpg"
      }
   }

   ######################################################################
   #--   Commute USB/Longuepose                                         #
   #     parametres : camNo choix ( si USB ul =0 sinon ul=1 )           #
   ######################################################################
   proc switchExpTime { ul } {
      global panneau
      variable Dslr

      set etat_anterieur [ lindex $panneau(acqdslr,status) 0 ]

      if { $etat_anterieur != $ul } {
         set status [ cam$panneau(acqdslr,camNo) longuepose $ul ]
         #--   memorise le nouvel etat
         set panneau(acqdslr,status) \
            [ lreplace $panneau(acqdslr,status) 0 0 "$status" ]
      }

      #--   adapte l'entree du temps d'exposition
      if { $etat_anterieur != $ul } {
         configTimeScale $ul
         #--   transfert la valeur
         set ::acqdslr::exptime $panneau(acqdslr,time)
         update
      }
   }

   ######################################################################
   #--   Gere l'etat des widgets lies a DSLR                            #
   ######################################################################
   proc setWindowState { state } {
      global panneau
      variable This
      variable Dslr

      foreach child [ list stock quality step bracket test \
         nom nb_poses pose exptime delai intervalle iter but1 ] {
         $Dslr.$child configure -state $state
      }

      if { $state == "normal" } {
         set k [ lsearch $panneau(acqdslr,bracketLabels) $panneau(acqdslr,bracket) ]
         switch -exact  $k {
            "0"   { configImg }
            "1"   { configSerie }
            "2"   { configContinu }
            "3"   { configRafale }
         }
      }
   }

   ######################################################################
   #--   Configure le panneau pour une image seule                      #
   #     appelee par le bouton de mode de prise de vue et setWindowState#
   ######################################################################
   proc configImg {} {
      global panneau
      variable Dslr

      configPose
      configIntervalle "1"

      set ::acqdslr::nb_poses "1"
      set panneau(acqdslr,test) "0"

      foreach child { test but1 } {
         $Dslr.$child configure -state normal
      }

      foreach child { step nb_poses } {
         $Dslr.$child configure -state disabled
      }
   }

   ######################################################################
   #--   Configure le panneau pour une serie d'images                   #
   #     appele par le bouton de mode de prise de vue et setWindowState #
   ######################################################################
   proc configSerie { } {
      global panneau
      variable Dslr

      configPose
      configIntervalle "2"

      #--   valeur par defaut
      set ::acqdslr::nb_poses "2"

      foreach child { test nb_poses } {
         $Dslr.$child configure -state normal
      }

      set etat "normal"
      if { $panneau(acqdslr,pose) == ">31" } {
         set etat "disabled"
      }
      $Dslr.step configure -state $etat
      set panneau(acqdslr,test) "0"

      #--   inactive le bouton GO
      $Dslr.but1 configure -state disabled
   }

   ######################################################################
   #--   Configure le panneau pour une serie continue d'images          #
   #     appele par le bouton de mode de prise de vue et setWindowState #
   ######################################################################
   proc configContinu { } {
      variable Dslr

      configPose
      configIntervalle "3"

      #--   valeur par defaut
      set ::acqdslr::nb_poses "2"

      foreach child { step nb_poses but1 } {
         $Dslr.$child configure -state normal
      }
      foreach child { test } {
         $Dslr.$child configure -state disabled
      }
   }

   ######################################################################
   #--   Configure le panneau pour une rafale d'images                  #
   #     appele par le bouton de mode de prise de vue et setWindowState #
   ######################################################################
   proc configRafale { } {
      variable Dslr

      configPose
      configIntervalle "4"

      $Dslr.but1  configure -state normal

      foreach child { step test nb_poses } {
         $Dslr.$child configure -state disabled
      }
   }

   ######################################################################
   #--   Teste le nom si l'entree est active                            #
   #     enleve les carateres non alphanumeriques ou underscore         #
   ######################################################################
   proc test_nom { w child } {

      if { [ $w.$child cget -state ] != "disabled" } {
         set nom_var [ LabelEntry::cget $w.$child -textvariable ]
         set value [ set $nom_var ]
         #-- seuls les caracteres alphanumeriques (non accentues)
         # et le underscore sont autorises
         regsub -all {[^a-zA-Z_]} $value {} resultat
         if { $value != "" && $value != $resultat } {
            avertiUser help$child
            set $nom_var $resultat
         }
      }
   }

   ######################################################################
   #--   Teste le nombre de poses si l'entree est active                #
   #     fixe a 1 si pas entier                                         #
   ######################################################################
   proc test_nb_poses { w child } {

      if { [ $w.$child cget -state ] != "disabled" } {
         set nom_var [ LabelEntry::cget $w.$child -textvariable ]
         if ![ TestEntier [ set $nom_var ] ] {
            avertiUser help$child
            set $nom_var "1"
         }
      } else {
         return
      }
      test_bracketing
   }

   ######################################################################
   #--   Teste l'intervalle si l'entree est active                      #
   #--   Si pas un entier ou < l'intervalle minimum                     #
   #     il est fixe a l'intervalle minimum                             #
   ######################################################################
   proc test_intervalle { w child } {
      global panneau

      if { [ $w.$child cget -state ] != "disabled" } {
         set nom_var [ LabelEntry::cget $w.$child -textvariable ]
         set intervalle [ set $nom_var ]
         regsub -all {[^0-9]} $intervalle {} resultat
         if { $intervalle != $resultat || $resultat < $panneau(acqdslr,intervalle_mini) } {
            avertiUser help$child
            set $nom_var $panneau(acqdslr,intervalle_mini)
         }
      }
   }

   ######################################################################
   #--   Teste le delai                                                 #
   #--   fixe a 0 si pas entier                                         #
   ######################################################################
   proc test_delai { w child } {

      set nom_var [ LabelEntry::cget $w.$child -textvariable ]
      if ![ TestEntier [ set $nom_var ] ] {
         avertiUser help$child
         set $nom_var "0"
      }
   }

   ######################################################################
   #--   Teste le nombre d'iterations si l'entree est active            #
   #--   fixe a 1 si pas entier                                         #
   ######################################################################
   proc test_iter { w child } {

      if { [ $w.$child cget -state ] != "disabled" } {
         set nom_var [ LabelEntry::cget $w.$child -textvariable ]
         if ![ TestEntier [ set $nom_var ] ] {
            avertiUser help$child
            set $nom_var "1"
         }
      }
   }

   #########################################################################
   #--   Teste si la valeur d'exposition finale est dans la plage          #
   #--   appelee par le bouton Pas, le nb de poses et le temps d'exposition#
   #--   s'applique uniquement a 'Une serie' ou 'En continu'               #
   #--   le test est effectue si step est different de 0                   #
   #########################################################################
   proc test_bracketing {} {
      global panneau caption

      set index_bracket [ lsearch $panneau(acqdslr,bracketLabels) $panneau(acqdslr,bracket) ]

      if { $panneau(acqdslr,step) == "0" || $panneau(acqdslr,pose) == ">30" \
         || $index_bracket == 0 || $index_bracket == 3 } {
         return
      }

      #--   recherche l'indice du temps affiche
      set i_initial [ lsearch $panneau(acqdslr,exptimeLabels) $panneau(acqdslr,time) ]

      #--   calcule l'indice de la valeur finale
      set i_final [ expr { $i_initial+$panneau(acqdslr,step)*(1-$::acqdslr::nb_poses) } ]

      if { $i_final < 0 || $i_final > [ llength $panneau(acqdslr,exptimeLabels) ] } {
         #--   message d'alerte si hors plage
         avertiUser "out_of_limits"
      }
   }

   ######################################################################
   #--   Mesure l'intervalle mini dans les conditions de reglages       #
   ######################################################################
   proc testTime { } {
      global audace panneau caption
      variable Dslr

      if { $panneau(acqdslr,camNo) == "0" } {
         return
      }

      #--   annule le delai
      set ::acqdslr::delai "0"

      #--   affiche le nom
      set ::acqdslr::nom "$caption(acqdslr,test)"

      #--   inhibe les commandes
      setWindowState disabled

      #--   fixe le nb de pose a 1
      set ::acqdslr::nb_poses "1"

      #--   le temps maintenant
      set t0 [clock milliseconds]

      #--   lance une acquisition
      shoot

      #--   calcule la duree de la sequence
      set duree [ expr { int(([clock milliseconds ]-$t0)/1000.0) } ]

      #--   memorise l'intervalle
      set panneau(remotecrtl,intervalle_mini) "$duree"

      #--   definit le nom du fichier
      set file ${::acqdslr::nom}1$panneau(acqdslr,extension)

      #--   supprime le nom affiche
      set ::acqdslr::nom " "

      #--   supprime le fichier test
      file delete [ file join $audace(rep_images) $file ]

      #--   memorise le test
      set panneau(acqdslr,test) "1"

      #--   libere les commandes
      setWindowState normal

      #--   fixe l'intervalle mini a afficher
      set ::acqdslr::intervalle "$duree"

      #--   active le bouton GO
      $Dslr.but1 configure -state normal
   }

   ######################################################################
   #--   Formate le temps de courte pose en decimal                     #
   ######################################################################
   proc convertExptime {} {
      global panneau

      set ::acqdslr::exptime $panneau(acqdslr,time)
      if { $panneau(acqdslr,pose) == "<30" } {
         #--   en mode USB, cherche l'index de la valeur
         set i [ lsearch $panneau(acqdslr,exptimeLabels) $panneau(acqdslr,time) ]
         #--   lit le resultat dans la liste de conversion
         set ::acqdslr::exptime [ lindex $panneau(acqdslr,exptimeValues) $i ]
      }
   }

   ######################################################################
   #--   Gere les prises de vue a partir des reglages de l'utilisateur  #
   ######################################################################
   proc shoot {} {
      global panneau caption

      #--   si pas de cam connectee
      if { $panneau(acqdslr,camNo) == "0" } {
         connectCam
         return
      }

      #--   memorise les parametres affiches
      set panneau(acqdslr,param) [ list $::acqdslr::nom $::acqdslr::nb_poses \
         $panneau(acqdslr,time) $::acqdslr::intervalle \
         $panneau(acqdslr,step) $panneau(acqdslr,action) ]

      #--   gele les commandes
      setWindowState disabled

      #--   affiche le status 'Attente'
      set panneau(acqdslr,action) $caption(acqdslr,action,wait)

      #---  si la pose est differee, affichage du temps restant
      if { $::acqdslr::delai != 0 } {
            delay "delai"
      }

      #--   compteur de shoot
      incr panneau(acqdslr,serieNo) "1"
      ::console::affiche_resultat "\n[ format $caption(acqdslr,prisedevue) $panneau(acqdslr,serieNo) ]\n"

      set k 1
      set iter $::acqdslr::iter
      while { $k <= $iter } {

         if { $iter != "1" } {
            #--   affiche le N° de l'iteration s'il y en a plusieurs
            ::console::affiche_resultat "[ format $caption(acqdslr,iteration) $k ]\n"
         }

         #--   fixe la qualite de l'image
         cam$panneau(acqdslr,camNo) quality $panneau(acqdslr,quality)

         if { $panneau(acqdslr,bracket) == $caption(acqdslr,bracket,rafale) } {
            shootRafale
         } else {
            shootImg
         }

         #--   retablit les parametres affiches initiaux
         lassign $panneau(acqdslr,param) ::acqdslr::nom ::acqdslr::nb_poses \
            panneau(acqdslr,time) ::acqdslr::intervalle \
            panneau(acqdslr,step) panneau(acqdslr,action)

         incr k 1
         incr ::acqdslr::iter "-1"
      }

      set ::acqdslr::iter $iter

      #--   degele les commandes
      setWindowState normal

      #--   retablit les parametres affiches initiaux après WindowState
      lassign $panneau(acqdslr,param) ::acqdslr::nom ::acqdslr::nb_poses \
         panneau(acqdslr,time) ::acqdslr::intervalle \
         panneau(acqdslr,step) panneau(acqdslr,action)
   }

   ######################################################################
   #--   Commande les prises de vue autres que le mode Rafale de l'APN  #
   ######################################################################
   proc shootImg { } {
      global panneau caption
      variable Dslr

      #--   raccourcis
      set camNo $panneau(acqdslr,camNo)
      set type [ lsearch $panneau(acqdslr,bracketLabels) $panneau(acqdslr,bracket) ]
      set stock "$panneau(acqdslr,stock)"
      set exptime $::acqdslr::exptime

      #--   memorise
      set nb_poses $::acqdslr::nb_poses
      set timer $::acqdslr::intervalle
      set n [ lsearch $panneau(acqdslr,exptimeValues) $exptime ]
      set delta [ expr { -1*$panneau(acqdslr,step) } ]

      #--   compte les images restant a prendre
      set i 1

      while { $::acqdslr::nb_poses > 0 } {

         #--   recherche la valeur affichee du temps d'exposition
         set exposition $panneau(acqdslr,time)

         #--  affiche le status 'Acquisition'
         set panneau(acqdslr,action) $caption(acqdslr,action,acq)

         #--- le temps maintenant
         set time_now [ clock seconds ]
         set time [ clock format [ clock seconds ] -format "%Y/%m/%d %H:%M:%S" -timezone :UTC ]

         #--- Alarme sonore de fin de pose
         #::camera::alarmeSonore $exptime

         #--  definit la commande
         if { $type == "2" } {

            #--  regle le temps d'exposition
            cam$camNo exptime $exptime
            #--   En Continu : retard pour valider le changement de temps d'exposition
            if { $delta != "0" } {
               after 1500
            }
            catch { cam$camNo acq -blocking } msg

         } elseif { $type != "2" && $exptime < "31" } {

            #--  regle le temps d'exposition
            cam$camNo exptime $exptime
            #--   Une image ou Une serie
            catch { cam$camNo acq
                    ::camera::waitStateStand $camNo } msg

         } elseif { $type == "0" && $exptime > "30" } {

            shootLonguePose
            set msg ""

         }

         if ![ regexp "Dialog error" $msg ] {
            if { $acqdslr::nom != "Test" } {
               infLog $time "$acqdslr::nom" "$panneau(acqdslr,time)"
            }
         } else {
           avertiUser "cam_pb"
         }

         #--   message sur la console
         ::console::affiche_resultat "$time $panneau(acqdslr,bracket) \
            N°$i $::acqdslr::nom $exposition sec.\n"

         #--  charge et visualise l'image si stockage autre que carte CF
         if { $stock != "$caption(acqdslr,stock,cf)" } {
            loadandseeImg $i
         }

         #--- decremente et affiche le nombre de poses qui reste a prendre
         incr ::acqdslr::nb_poses "-1"

         #--   si ce n'est pas la derniere image
         if { $nb_poses > $i && $type != 0 } {

            #--   recalcule et affiche exptime pour serie et rafale
            if { $delta != "0" } {

               #--   incremente l'index = regresse dans la liste
               incr n "$delta"

               #--   extrait le temps de pose
               set exptime [ lindex  $panneau(acqdslr,exptimeValues) $n ]

               #--   actualise le temps de pose sur le panneau
               $Dslr.exptime setvalue @$n
               update
            }

            #--   met a jour l'intervalle pour Une serie
            if { $type == 1 } {

               if { $i == "1" } {
                  set time_first $time_now
               }

               #--   si ce n'etait pas la derniere image
               if { $i < $nb_poses } {
                  set ::acqdslr::intervalle [ expr { $time_first + $timer*$i -[ clock seconds ] } ]
                  delay intervalle
               }
            }
         }

         #-- incremente l'index de l'image
         incr i
      }
   }

   ######################################################################
   #--   Commande le mode LonguePose de l'APN                           #
   ######################################################################
   proc shootLonguePose {} {
       global panneau

      lassign $panneau(acqdslr,longuepose) camNo linkNo bitNo startvalue stopvalue

      #--   passe en mode longuepose
      cam$camNo longuepose 1

      #--   actionne le bit
      link$linkNo bit $bitNo $startvalue

      #--   decompte le temps de pose
      while { $panneau(acqdslr,time) > "0" } {
         after 1000
         incr panneau(acqdslr,time) "-1"
         update
      }
      set panneau(acqdslr,time) "0"
      update

      link$linkNo bit $bitNo $stopvalue

      #--   repasse en mode USB
      cam$camNo longuepose 0
   }

   ######################################################################
   #--   Commande le mode Rafale de l'APN                               #
   ######################################################################
   proc shootRafale {} {
      global panneau caption

      lassign $panneau(acqdslr,longuepose) camNo linkNo bitNo startvalue stopvalue

      #--   affiche le status 'Acquisition'
      set panneau(acqdslr,action) $caption(acqdslr,action,acq)

      set time [ clock format [ clock seconds ] -format "%Y/%m/%d/%H:%M:%S" -timezone :UTC ]

      #--  regle le temps d'exposition
      cam$camNo exptime $::acqdslr::exptime

      #--   passe en mode 'rafale'
      cam$camNo drivemode 1

      #--   prend une photo juste pour passer les parametres
      catch {  cam$camNo acq -blocking } msg

      if [ regexp "Dialog error" $msg ] {
         avertiUser "cam_pb"
      }

      #--   passe en mode 'rafale'
      cam$camNo drivemode 1

      #--   passe en mode longuepose
      cam$camNo longuepose 1

      #--   actionne le bit
      link$linkNo bit $bitNo $startvalue
      delay "intervalle"
      link$linkNo bit $bitNo $stopvalue

      #--   repasse en mode USB
      cam$camNo longuepose 0

      #--   repasse en mode normal
      cam$camNo drivemode 0

      #--   complete le fichier log+message sur la console
      set exposition "$panneau(acqdslr,time) $caption(acqdslr,duree) \
         [ lindex $panneau(acqdslr,param) 3 ] sec."
      infLog "$time" "$::acqdslr::nom" "$exposition"
      ::console::affiche_resultat "$time $panneau(acqdslr,bracket) $exposition\n"
   }

   ######################################################################
   #--   Nomme, sauvegarde, transfert et affiche l'image                #
   #--   parametre : index de l'image                                   #
   ######################################################################
   proc loadandseeImg { k } {
      global audace panneau caption

      set visuNo $audace(visuNo)

      #--   affiche le status 'Sauvegarde'
      set panneau(acqdslr,action) $caption(acqdslr,action,load)

      #--   visualise l'image
      confVisu::autovisu $visuNo

      #--   nomme l'image
      set name $acqdslr::nom
      if { $name == "" } { set name "tmp" }

      #---  compose le nom de l'image
      append name $k $panneau(acqdslr,extension)
      set nom_complet [ file join $audace(rep_images) $name ]

      #--   recupere les stats
      set stat [ stat ]

      #--   sauve l'image
      saveima $nom_complet

      #--   fait apparaitre le nom dans la visu
      ::confVisu::setFileName $visuNo $nom_complet

      #--   envoie les valeurs vers la console pour une image RAW
      if { $panneau(acqdslr,format) == "fits" } {
         ::console::affiche_resultat "\n$name\n\
            $caption(acqdslr,maxi) [ lindex $stat 2 ]\n\
            $caption(acqdslr,moyenne) [ lindex $stat 4 ]\n\
            $caption(acqdslr,mini) [ lindex $stat 3 ]\n\n"
      }
   }

   ######################################################################
   #--   Decompte les secondes                                          #
   #     parametre : nom de la variable a decompter                     #
   ######################################################################
   proc delay { var } {

      upvar 1 ::acqdslr::$var t
      while { $t > "0" } {
         after 1000
         incr t "-1"
         update
      }
      set t "0"
      update
   }

   ######################################################################
   #--   Complete le fichier log                                        #
   #--   parametre : nom de l'image                                     #
   ######################################################################
   proc infLog { time name exptime } {
      global panneau

      set texte [ list $time \
         "$panneau(acqdslr,stock)" \
         "$panneau(acqdslr,bracket)" \
         "$panneau(acqdslr,quality)" \
         $exptime \
         "$name" ]
      writeLog $panneau(acqdslr,log) $texte
   }

   ######################################################################
   #--   Ecriture du fichier log                                        #
   #     parametre : nom du fichier texte                               #
   ######################################################################
   proc writeLog { f m } {

      set err [ catch {
         set fd [ open $f a+ ]
         puts $fd $m
         close $fd
      } msg ]
      return $err
   }

   ######################################################################
   #--   Fenetre d'avertissement                                        #
   #     parametre : variable de caption                                #
   ######################################################################
   proc avertiUser { v } {
      global panneau caption

      #--   pour eviter les ouvertures multiples
      if { $panneau(acqdslr,msgbox) != "$v" } {

         #--   memorise l'affichage de l'erreur
         set panneau(acqdslr,msgbox) $v

         tk_messageBox -title $caption(acqdslr,attention)\
            -icon error -type ok -message $caption(acqdslr,$v)

         #--   au retour annule la memoire
         set panneau(acqdslr,msgbox) ""
     }
   }

#--   fin du namespace
}

