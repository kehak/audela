#--------------------------------------------------
# source $audace(rep_plugin)/tool/robobs/robobs_config.tcl
#--------------------------------------------------
#
# Fichier        : robobs_config.tcl
# Description    : Configuration de RobObs
# Auteur         : Alain Klotz
# Mise à jour $Id: robobs_config.tcl 14439 2018-06-08 12:51:06Z alainklotz $
#

namespace eval ::robobs_config {

   global audace
   global robobsconf
   global robobs

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool robobs robobs_config.cap ]\""

   #--------------------------------------------------
   # run { this }
   #--------------------------------------------------
   #
   #    fonction  :
   #        Creation de la fenetre
   #
   #    procedure externe :
   #
   #    variables en entree :
   #        this = chemin de la fenetre
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc run { this } {
      variable This
      global audace

      set This $this
      ::robobs_config::load_config
      ::robobs_config::createDialog
      return
   }

   #--------------------------------------------------
   # fermer { }
   #--------------------------------------------------
   #
   #    fonction  :
   #        Fonction appellee lors de l'appui
   #        sur le bouton 'Fermer'
   #
   #    procedure externe :
   #
   #    variables en entree :
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc fermer { } {
      variable This

      ::robobs_config::recup_position
      destroy $This
      return
   }

   #--------------------------------------------------
   #  recup_position { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       Permet de recuperer et de sauvegarder
   #       la position de la fenetre
   #
   #    procedure externe :
   #
   #    variables en entree :
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc recup_position { } {
      variable This
      global audace
      global conf
      global robobsconf

      set robobsconf(geometry_status) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $robobsconf(geometry_status) ] ]
      set fin [ string length $robobsconf(geometry_status) ]
      set robobsconf(position_status) "+[ string range $robobsconf(geometry_status) $deb $fin ]"
      #---
      set conf(robobs,position_status) $robobsconf(position_status)
      return
   }

   #--------------------------------------------------
   #  createDialog { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       Creation de l'interface graphique
   #
   #    procedure externe :
   #
   #    variables en entree :
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc createDialog { {ki 0} } {

      variable This
      global audace
      global caption
      global color
      global conf
      global robobsconf
      global robobs

      ::robobs_config::update
      set robobs(config,kitem) $ki
      set ni [llength $robobs(conf,items)]
      if {$ki<0} {
         return
      }
      if {$ki>=$ni} {
         return
      }
      set item [lindex $robobs(conf,items) $ki]
      #--- initConf
      if { ! [ info exists conf(robobs,position_status) ] } { set conf(robobs,position_status) "+80+40" }

      #--- confToWidget
      set robobsconf(position_status) $conf(robobs,position_status)

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         return
      }

      #---
      if { [ info exists robobsconf(geometry_status) ] } {
         set deb [ expr 1 + [ string first + $robobsconf(geometry_status) ] ]
         set fin [ string length $robobsconf(geometry_status) ]
         set robobsconf(position_status) "+[ string range $robobsconf(geometry_status) $deb $fin ]"
      }

      #---
      toplevel $This -class Toplevel
      wm geometry $This $robobsconf(position_status)
      wm resizable $This 1 1
      wm title $This $caption(robobs_config,main_title)
      wm protocol $This WM_DELETE_WINDOW { ::robobs_config::fermer }


      #--- Cree un frame pour afficher le status de la base
      frame $This.frame1 -borderwidth 0 -cursor arrow -relief groove
      pack $This.frame1 -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

      #--- Cree un label pour le titre
      label $This.frame1.titre \
           -text "$caption(robobs_config,titre) : $item"
      pack $This.frame1.titre \
          -in $This.frame1 -side top -padx 3 -pady 3

      set kdescr 0
      foreach descr $robobs(conf,$item,descr) {
         set val $robobs(conf,$item,$descr,value)
         #--- Cree un frame pour afficher le status de la base
         frame $This.frame$descr -borderwidth 1 -cursor arrow -relief groove
         #--- Cree un bouton de changement
         set commande "global robobs ; ::robobs_config::change $item $descr $ki $kdescr"
         button $This.frame$descr.but1 \
              -font $robobsconf(font,arial_8) \
              -text "$caption(robobs_config,but5)" -command $commande
         pack $This.frame$descr.but1 \
             -in $This.frame$descr -side left -padx 3 -pady 0
         #--- Cree un label pour le titre
         label $This.frame$descr.descr \
              -text "$descr =" -font $robobsconf(font,arial_8_b)
         pack $This.frame$descr.descr \
             -in $This.frame$descr -side left -padx 3 -pady 0
         #--- Cree un label pour le titre
         label $This.frame$descr.val \
              -text "$val" -font $robobsconf(font,arial_8_b) -fg #0000FF
         pack $This.frame$descr.val \
             -in $This.frame$descr -side left -padx 3 -pady 0
         #--- Cree un bouton d'aide
         set commande "global robobs ; ::robobs_config::infos $item $descr $ki $kdescr"
         button $This.frame$descr.but2 \
              -font $robobsconf(font,arial_8) \
              -text "$caption(robobs_config,but6)" -command $commande
         pack $This.frame$descr.but2 \
             -in $This.frame$descr -side right -padx 3 -pady 0
         #--- pack le frame pour afficher le status de la base
         pack $This.frame$descr -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 0
         incr kdescr
      }

      #--- Cree un frame pour afficher les deux boutons du bas
      frame $This.frame2 -borderwidth 0 -cursor arrow -relief groove
      pack $This.frame2 -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un bouton
        button $This.frame2.but1 \
              -text "$caption(robobs_config,but3)" -command { global robobs ; ::robobs_config::wizard [expr $robobs(config,kitem)-1] }
        pack $This.frame2.but1 \
             -in $This.frame2 -side left -padx 3 -pady 3

        #--- Cree un bouton
        button $This.frame2.but2 \
              -text "$caption(robobs_config,but4)" -command { global robobs ; ::robobs_config::wizard [expr $robobs(config,kitem)+1] }
        pack $This.frame2.but2 \
             -in $This.frame2 -side right -padx 3 -pady 3

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      #::confColor::applyColor $This
      $This.frame1.titre configure -font $robobsconf(font,arial_12_b)

   }

   proc save_config { } {
      global robobs
      global audace
      # Do not call ::robobs_config::update
      # enregistre les nouveaux parametres dans un fichier de configuration
      set texte ""
      foreach item $robobs(conf,items) {
         foreach descr $robobs(conf,$item,descr) {
            set val $robobs(conf,$item,$descr,value)
            append texte "set robobs(conf,$item,$descr,value) \"$val\"\n"
         }
      }
      set names [lsort [array names robobs]]
      foreach name $names {
         set namew [regsub -all , $name " "]
         set key [lindex $namew 0]
         if {$key=="conf_planif"} {
            set val $robobs($name)
            append texte "set robobs($name) \"$val\"\n"
         }
      }
      set fic "$audace(rep_home)/robobs.ini"
      catch {
         set f [open $fic w]
         puts -nonewline $f $texte
         close $f
      }
   }

   proc load_config { } {
      global robobs
      global audace
      #::robobs_config::update
      set fic "$audace(rep_home)/robobs.ini"
      set err [catch {
         source $fic
      } msg]
      if {$err==1} {
         ::console::affiche_resultat "$msg"
      }
   }

   proc change_fermer { } {
      global robobs
      global audace
      set base .robobs_change
      destroy $base
      ::robobs_config::save_config
      #
      set filename [ file join $::audace(rep_home) audace.ini ]
      set filebak  [ file join $::audace(rep_home) audace.bak ]
      set filename2 $filename
      catch {
         file copy -force $filename $filebak
      }
		::audace::ini_writeIniFile $filename2 conf
   }

   proc change { item descr kitem kdescr} {
      global robobs
      global caption
      global audace
      global robobsconf
      set texte ""
      append texte "CHANGE $item $descr $kitem $kdescr"
      set change [lindex $robobs(conf,$item,change) $kdescr]

      #--- Cree un toplevel
      set base .robobs_change
      if { [ winfo exists $base ] } {
         destroy $base
      }
      toplevel $base -class Toplevel
      wm geometry $base $robobsconf(position_status)
      wm resizable $base 1 1
      wm title $base "$caption(robobs_config,main_title) change"
      wm protocol $base WM_DELETE_WINDOW { ::robobs_config::change_fermer }

      #--- Cree un frame pour afficher le status de la base
      frame $base.frame1 -borderwidth 0 -cursor arrow -relief groove
      pack $base.frame1 -in $base -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

      #--- Cree un label pour le titre
      label $base.frame1.titre \
           -text "$caption(robobs_config,titre) change"
      pack $base.frame1.titre \
          -in $base.frame1 -side top -padx 3 -pady 3

      if {$change==""} {

         #--- Cree un label pour l'entry
         label $base.frame1.lab1 \
              -text "$descr = "
         pack $base.frame1.lab1 \
             -in $base.frame1 -side top -padx 3 -pady 3

         #--- Cree l'entry
         entry $base.frame1.ent1 \
              -textvariable robobs(conf,$item,$descr,value)
         pack $base.frame1.ent1 \
             -in $base.frame1 -side top -padx 3 -pady 3

      } else {

        #--- Cree un bouton
        button $base.frame1.but1 \
              -text "$caption(robobs_config,but5)" -command $change
        pack $base.frame1.but1 \
             -in $base.frame1 -side top -padx 3 -pady 3

      }

     #--- Cree un bouton valider
     set commande "::robobs_config::change_fermer ; ::robobs_config::wizard $kitem"
     button $base.frame1.butv \
           -text "$caption(robobs_config,but7)" -command $commande
     pack $base.frame1.butv \
          -in $base.frame1 -side top -padx 3 -pady 3

   }

   proc wizard { kitem } {
      ::robobs_config::fermer
      ::robobs_config::createDialog $kitem
   }

   proc infos { item descr kitem kdescr} {
      global robobs
      global caption
      global audace
      set textes ""
      set infos [lindex $robobs(conf,$item,infos) $kdescr]
      append textes "$caption(robobs_config,info1) ($item,$descr) :\n\n"
      set l 0
      set texte ""
      foreach i $infos {
         if {[string length $texte]>80} {
            apppend textes "\n"
         }
         append textes "$i "
      }
      tk_messageBox -message "$textes" -type ok -icon info
   }

   proc disp {} {
      global robobs
      global caption
      global audace

      ::robobs_config::update

      set texte ""
      foreach item $robobs(conf,items) {
         append texte "===== $robobs(conf,$item,title)\n"
         foreach descr $robobs(conf,$item,descr) {
            set val $robobs(conf,$item,$descr,value)
            append texte "$item $descr = $val\n"
         }
      }
      ::console::affiche_resultat "$texte"

   }

   proc update {} {
      global robobs
      global caption
      global audace
      global conf

      set robobs(conf,items) ""

      set item home
      lappend robobs(conf,items) "$item"
         #set robobs(conf,$item,title) "$caption(audace,menu,setup) $caption(audace,menu,position) Telescope_ID"
         set robobs(conf,$item,descr) "gps observer telescope_id"
         set robobs(conf,$item,read) {"variable audace(posobs,observateur,gps)" "variable conf(posobs,nom_observateur)" ""}
         set robobs(conf,$item,change) "{::confPosObs::run $audace(base).confPosObs} {::confPosObs::run $audace(base).confPosObs} {} "
         set robobs(conf,$item,default) [list $audace(posobs,observateur,gps) $conf(posobs,nom_observateur) makes_t60]
         set robobs(conf,$item,infos) "{Definition du lieu d'observation} {definition du nom de l'observateur} {designation du telescope pour personalisation des scripts}"

      set item skylight
      lappend robobs(conf,items) "$item"
         set robobs(conf,$item,descr) "elevsun skybrightness"
         set robobs(conf,$item,read) {"" ""}
         set robobs(conf,$item,change) ""
         set robobs(conf,$item,default) [list -10 16]
         set robobs(conf,$item,infos) "{Elevation du Soleil sous laquelle on commence les observations} {Brillance du ciel (en mag/arcsec2) au dela de laquelle on commence les observations}"

      set item local_horizon
      lappend robobs(conf,items) "$item"
         set robobs(conf,$item,descr) "altaz"
         set robobs(conf,$item,read) {""}
         set robobs(conf,$item,change) ""
         set robobs(conf,$item,default) [list {{0 0} {360 0}}]
         set robobs(conf,$item,infos) "{Definition des points d'amer {az,elev} des limites de pointages pour tenir compte des obstacles de silouette complexe}"

      set item security_angles
      lappend robobs(conf,items) "$item"
         set robobs(conf,$item,descr) "moon sun dec_max dec_min ha_set ha_rise elev_max elev_min"
         set robobs(conf,$item,change) ""
         set robobs(conf,$item,default) [list 30 30 90 -90 180 -180 90 0]
         set robobs(conf,$item,infos) "{Angle de garde au Soleil} {Angle de garde a la Lune} {Declinaison maximale autorisee} {Declinaison minimale autorisee} {Angle horaire de coucher autorise} {Angle horaire de lever autorise} {Elevation minimale autorisee} {Elevation maximale autorisee}"

      set item folders
      lappend robobs(conf,items) "$item"
         set robobs(conf,$item,descr) "rep_images rep_travail rep_personal_robobs"
         #set robobs(conf,$item,cap) "$caption(audace,menu,setup) $caption(audace,menu,rep_images)"
         set robobs(conf,$item,read) {{variable audace(rep_images)} {variable audace(rep_travail)} ""}
         set robobs(conf,$item,change) "{::cwdWindow::run $audace(base).cwdWindow} {::cwdWindow::run $audace(base).cwdWindow}"
         set robobs(conf,$item,default) [list $audace(rep_images) $audace(rep_travail) $audace(rep_travail)]
         set robobs(conf,$item,infos) "{Repertoire des images} {Repertoire de travail} {Repertoire des scripts personnels}"

      set item astrometry
      lappend robobs(conf,items) "$item"
         set robobs(conf,$item,descr) "cat_name cat_folder"
         #set robobs(conf,$item,cap) "$caption(audace,menu,setup) $caption(audace,menu,rep_images)"
         set robobs(conf,$item,read) {""}
         set robobs(conf,$item,change) ""
         set robobs(conf,$item,default) [list USNO c:/d/tycho2]
         set robobs(conf,$item,infos) "{Type du catalogue pour la calibration astrometrique} {Repertoire du catalogue pour la calibration astrometrique}"

      set item fichier_image
      lappend robobs(conf,items) "$item"
         set robobs(conf,$item,descr) "extension compress"
         #set robobs(conf,$item,cap) "$caption(audace,menu,setup) $caption(audace,menu,fichier_image)"
         set robobs(conf,$item,read) {"proc {buf$audace(bufNo) extension}" "proc {buf$audace(bufNo) compress}"}
         set robobs(conf,$item,change) "{::confFichierIma::run $audace(base).confFichierIma} {::confFichierIma::run $audace(base).confFichierIma}"
         set robobs(conf,$item,infos) "{Extension des fichiers images} {Mode de compression des fichiers images}"

      set item camera
      lappend robobs(conf,items) "$item"
         set robobs(conf,$item,descr) "camno"
         set robobs(conf,$item,cap) "$caption(audace,menu,setup) $caption(audace,menu,camera)"
         set robobs(conf,$item,read) {"variable audace(camNo)"}
         set robobs(conf,$item,change) "{::confCam::run}"
         set robobs(conf,$item,infos) "{Configuration de la camera. =0 pour une camera de simulation}"

      set item telescope
      lappend robobs(conf,items) "$item"
         set robobs(conf,$item,descr) "telno"
         #set robobs(conf,$item,cap) "$caption(audace,menu,setup) $caption(audace,menu,telescope)"
         set robobs(conf,$item,read) {"variable audace(telNo)"}
         set robobs(conf,$item,change) "{::confTel::run}"
         set robobs(conf,$item,infos) "{Configuration de la monture pour pointer le telescope =0 pour une monture de simulation}"

      set item link
      lappend robobs(conf,items) "$item"
         set robobs(conf,$item,descr) "linkno"
         set robobs(conf,$item,cap) "$caption(audace,menu,setup) $caption(audace,menu,liaison)"
         set robobs(conf,$item,change) "{::confLink::run}"
         set robobs(conf,$item,infos) "{Configuration du systeme de lie au telescope (roue a filtre, etc.)}"

      set item meteostation
      lappend robobs(conf,items) "$item"
         set robobs(conf,$item,descr) "type port params delay_security humidity_limit_max cloud_limit_max wind_limit_max water_limit_max"
         set robobs(conf,$item,read) {""}
         set robobs(conf,$item,change) ""
         set robobs(conf,$item,default) [list simulation com1 "" 600 92 VeryCloudy 10 Rain]
         set robobs(conf,$item,infos) "{Nom de la station meteo utilisée pour la sécurité meteo} {Port de communication PC poru la la station meteo} {Paramètres optionnels de connexion avec la station meteo} {Delais d'attente (en secondes) après retour à un état météorologique permettant d'observer. Une valeur de quelques centaines de secondes permet d'éviter d'ouvrir et de fermer sans cesse la protection de l'observatoire en cas de variations rapides.} {Limite d'humidité au delà de laquelle il faut proteger l'observatoire} {Limite de couverture nuageuse au delà de laquelle il faut proteger l'observatoire (Cloudy VeryCloudy)} {Limite de vitesse de vent au delà de laquelle il faut proteger l'observatoire} {Limite d'état de l'eau précipitable au delà de laquelle il faut proteger l'observatoire (Wet ou rain)}"

      set item optic
      lappend robobs(conf,items) "$item"
         set robobs(conf,$item,descr) "name diam foclen"
         set robobs(conf,$item,cap) "$caption(audace,menu,setup) Optic"
         set robobs(conf,$item,read) {"proc {lindex [::confOptic::getConfOptic A] 0}" "proc {lindex [::confOptic::getConfOptic A] 1}" "proc {lindex [::confOptic::getConfOptic A] 2}"}
         set robobs(conf,$item,change) "{::confOptic::run $audace(visuNo)} {::confOptic::run $audace(visuNo)} {::confOptic::run $audace(visuNo)}"
         set robobs(conf,$item,infos) "{Nom de la configuration optique} {Diametre d'ouverture de l'optique collectrice. La valeur doit etre exprimee en metres.} {Longueur focale equivalente au niveau du plan image de la camera}"
			#
			# ::keyword::run 1 ::conf(acqfc,keywordConfigName)
			# set conf [lindex [::keyword::getConfigurationList] 0]
			# ::keyword::getKeywords 1 $conf

      set item loopscripts
      lappend robobs(conf,items) "$item"
         set robobs(conf,$item,descr) ""
         set robobs(conf,$item,default) ""
         set robobs(conf,$item,infos) ""
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "load_config"
         lappend robobs(conf,$item,infos) {Charge la configuration de l'observatoire robotique}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "check_night"
         lappend robobs(conf,$item,infos) {Calcule s'il fait jour ou s'il fait nuit}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "check_camera"
         lappend robobs(conf,$item,infos) {Verifie si la camera est connectee ou non. Si aucune camera n'est definie alors RobObs generera des images simulees au cours de l'acquisition}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "check_telescope"
         lappend robobs(conf,$item,infos) {Verifie si le telescope est connectee ou non. Si aucun telescope n'est defini alors RobObs simulera un pointage au cours des acquisitions}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "check_security"
         lappend robobs(conf,$item,infos) {Verifie si les retours d'etat des securites de l'observatoire sont OK}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "next_scene"
         lappend robobs(conf,$item,infos) {Calcule la prochaine scene a observer. Une scene consiste en un pointage suivi d'un petit nombre de poses}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "setup_scene"
         lappend robobs(conf,$item,infos) {Met en place les appareils de l'observatoire avant de commencer la scene (ex. extinction des lumieres)}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "goto_telescope"
         lappend robobs(conf,$item,infos) {Pointage de la monture vers les coordonnees definies dans la scene a observer}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "goto_dome"
         lappend robobs(conf,$item,infos) {Pointage eventuel du dome pour placer son ouverture en concordance avec le telescope}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "setup_intruments"
         lappend robobs(conf,$item,infos) {Met en place les instruments avant de lancer la pose (ex. roue a filtre, spectro)}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "check_pointing"
         lappend robobs(conf,$item,infos) {Verification du pointage avant de commencer les acquisitions}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "acquisition_camera"
         lappend robobs(conf,$item,infos) {Acquisition des images et enregistrement sur le disque}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "correction_dark"
         lappend robobs(conf,$item,infos) {Correction des effets thermiques}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "correction_flat"
         lappend robobs(conf,$item,infos) {Correction des variations de sensibilite}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "correction_cosmetic"
         lappend robobs(conf,$item,infos) {Correction des artefacts connus}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "calibration_astrometry"
         lappend robobs(conf,$item,infos) {Analyse de l'image avec un catalogue astrometrique et complete l'entete FITS avec les mots cle WCS}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "calibration_photometry"
         lappend robobs(conf,$item,infos) {Analyse de l'image avec un catalogue photometrique et complete l'entete FITS. Cree un catalogue des sources.}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "image_archive"
         lappend robobs(conf,$item,infos) {Archivage des images et des catalogues de sources}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "light_curve"
         lappend robobs(conf,$item,infos) {Extraction eventuelle de la courbe de lumiere d'une source}
         lappend robobs(conf,$item,default) "RobObs"
         lappend robobs(conf,$item,descr) "global_photometry"
         lappend robobs(conf,$item,infos) {Analyse eventuelle du catalogue des sources pour en extraire les sources variables}
         lappend robobs(conf,$item,default) "RobObs"
         set robobs(conf,$item,cap) "$caption(audace,menu,setup) Scripts for robotic observations"
         #'

      # --- charge la derniere configuration enregistree
      ::robobs_config::load_config

      # --- update
      foreach item $robobs(conf,items) {
         if {[info exists robobs(conf,$item,title)]==0} {
            set robobs(conf,$item,title) "$caption(audace,menu,setup) $item"
         }
         if {[info exists robobs(conf,$item,descr)]==0} {
            continue
         }
         if {[info exists robobs(conf,$item,read)]==0} {
            set robobs(conf,$item,read) ""
         }
         if {[info exists robobs(conf,$item,default)]==0} {
            set robobs(conf,$item,default) ""
         }
         if {[info exists robobs(conf,$item,infos)]==0} {
            set robobs(conf,$item,infos) ""
         }
         set rs ""
         set ds ""
         set ri ""
         set k 0
         foreach descr $robobs(conf,$item,descr) {
            set r [lindex $robobs(conf,$item,read) $k]
            if {$r==""} {
               lappend rs [list variable robobs(conf,$item,$descr,value)]
            } else {
               lappend rs $r
            }
            set d [lindex $robobs(conf,$item,default) $k]
            if {$d==""} {
               lappend ds not_defined
            } else {
               lappend ds $d
            }
            set r [lindex $robobs(conf,$item,infos) $k]
            if {$r==""} {
               lappend ri "Sorry. No information about this topic"
            } else {
               lappend ri $r
            }
            incr k
         }
         set robobs(conf,$item,read) $rs
         set robobs(conf,$item,default) $ds
         set robobs(conf,$item,infos) $ri
         set k 0
         foreach descr $robobs(conf,$item,descr) {
            set action [lindex $robobs(conf,$item,read) $k]
            set type  [lindex $action 0]
            set param [lrange $action 1 end]
            #::console::affiche_resultat "k=$k type=$type param=$param\n"
            set val ""
            if {$type=="variable"} {
               set err [catch {eval set val \$${param}} msg]
               if {$err==1} {
                  #::console::affiche_resultat "ERROR VAR msg=$msg\n"
                  set val [lindex $robobs(conf,$item,default) $k]
               }
            } elseif {$type=="proc"} {
               set err [catch {eval $param} msg]
               if {$err==1} {
                  set err [catch {eval [lindex $param 0]} msg]
               }
               if {$err==0} {
                  set val $msg
               } else {
                  #::console::affiche_resultat "ERROR PROC msg=$msg\n"
                  set val [lindex $robobs(conf,$item,default) $k]
               }
            }
            set robobs(conf,$item,$descr,value) $val
            #::console::affiche_resultat "descr=$descr val=$val\n"
            incr k
         }
         #::console::affiche_resultat "robobs(conf,$item,$descr,value)=$robobs(conf,$item,$descr,value)\n"
      }
      # --- Create empty files if they do not exists
      set item loopscripts
      foreach descr $robobs(conf,$item,descr) {
         set fic $audace(rep_install)/gui/audace/plugin/tool/robobs/loopscript_${descr}.tcl
         if {[file exists $fic]==0} {
            set f [open $fic w]
            puts $f "# Script $descr"
            puts $f "# This script will be sourced in the loop"
            puts $f "# ---------------------------------------"
            puts $f ""
            puts $f "# === Beginning of script"
            puts $f "::robobs::log \"\$caption(robobs,start_script) RobObs \[info script\]\" 50"
            puts $f ""
            puts $f "# === Body of script"
            if {$descr=="load_config"} {
               puts $f "::robobs_config::update"
            }
            puts $f ""
            puts $f "# === End of script"
            puts $f "::robobs::log \"\$caption(robobs,exit_script) RobObs \[info script\]\" 50"
            puts $f "return \"\""
            close $f
         }
      }

   }

}