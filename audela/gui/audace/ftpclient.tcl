#
## @file ftpclient.tcl
#  @brief Connexion à un serveur FTP
#  @author Michel PUJOL
#  $Id: ftpclient.tcl 13573 2016-04-02 19:14:14Z rzachantke $
#

##############################################################################
# namespace ftpclient
#  ::ftpclient::selectConnection                 : affiche une fenetre de demande de connexion FTP et ouvre la connexion
#  ::ftpclient::open                             : ouvre la connexion FTP selectionnee
#  ::ftpclient::closeCnx                         : ferme la connexion FTP
#  ::ftpclient::getFileList (fullpath)           : retourne la liste des fichiers d'un repertoire distant
#  ::ftpclient::get ( sourceFile targetDir size) : copie un fichier du serveur distant sur le disque local
#############################################################################

## namespace ftpclient
#  @brief Connexion à un serveur FTP

namespace eval ::ftpclient {
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_caption) ftpclient.cap ]

   #------------------------------------------------------------
   #  brief initialise l'environnement
   #
   proc init { } {
      variable private

      #--- je cree les variables par defaut
      set private(connection) ""
      #--- je charge les parametres par defaut
      initVar
   }

   #------------------------------------------------------------
   ## @brief affiche la fenêtre des paramètres de connexion FTP
   #  @param visuNo numéro de la visu
   #  @return
   #  -  1 si la connexion a réussi
   #  -  0 si la connexion a échoué
   #  - -1 si la connexion est abandonnée
   #
   proc selectConnection { visuNo } {
      variable private
      global audace

      #--- je verifie que le package ftp est present
      set result [catch { package require ftp } msg]
      if { $result == 1} {
         set message "error : package \"ftp\" not found"
         console::affiche_erreur "$message \n"
         tk_messageBox -title "ftpclient" -type ok -message "$message" -icon error
         return 0
      }

      set private(connection)  ""
      set private(password)    ""
      set private(targetsize)  0
      set private(hostname)    ""
      set private(port)        ""
      set private(user)        ""
      set private(directory)   ""
      set private(password)    ""

      #--- affiche la fenetre de connexion
      set confResult [::confGenerique::run $visuNo "$audace(base).ftpclient" "::ftpclient" -modal 1]

      if { $confResult == 1 } {
         if { $private(connection) != "" } {
            #--- la connexion est etablie
            return 1
         } else {
            #--- erreur de connexion
            return 0
         }
      } else {
         #--- connexion volontairement abondonnee
         return -1
      }
   }

   #------------------------------------------------------------
   ## @brief ouvre la connexion ftp
   #
   proc openConnection { } {
      variable private
      global caption conf

      #--- server ftpd pour tester le client ftp
      package require ftp

      if {  "$private(connection)" != "" } {
         #--- je ferme la connexion en cours si elle existe
         closeCnx
      }

      set private(connection) [ftp::Open \
         $private(hostname)  $private(user)  $private(password) \
         -port $private(port) -blocksize 4096 -timeout $conf(ftpclient,timeout) -progress ::ftpclient::progress]

      if {$private(connection) == -1} {
         set private(connection) ""
         console::affiche_erreur "$caption(ftpclient,connection_error) [getUrl] \n"
         return 0
      }
      ftp::Type $private(connection) binary
      console::affiche_resultat  "$caption(ftpclient,connection_ok) [getUrl] \n"
      return 1
   }

   #------------------------------------------------------------
   ## @brief commande du bouton "Fermeture connexion"
   #  @note ferme la connexion ftp
   #
   proc closeCnx { } {
      variable private
      global caption

      if { "$private(connection)" != "" } {
         console::affiche_resultat  "$caption(ftpclient,connection_close) [getUrl] \n"
         ftp::Close $private(connection)
         set private(connection) ""
      }
   }

   #------------------------------------------------------------
   ## @brief retourne le répertoire courant
   #  @return nom du répertoire courant
   #
   proc getDirectory { } {
      variable private

      return "$private(directory)"
   }

   #------------------------------------------------------------
   ## @brief retourne l'URL du serveur FTP
   #  @return URL du serveur FTP
   #
   proc getUrl { } {
      variable private

      return "ftp://$private(hostname):$private(port)"
   }

   #------------------------------------------------------------
   #  brief retourne l'état de la connexion
   #  return
   #  - 1 si la connexion est déja ouverte
   #  - 0 si la connexion n'existe pas
   #
   proc isOpened { } {
      variable private

      if { "$private(connection)" != "" } {
         return 1
      } else {
         return 0
      }
   }

   #------------------------------------------------------------
   ## @brief retourne la liste des fichiers du répertoire
   #  @param fullPath chemin complet
   #  @param cnx vaut \$private(connection) par défault
   #  @return
   #  - liste des fichiers contenu dans un répertoire
   #  - "" si erreur
   #
   proc getFileList { fullPath { cnx $private(connection) } } {
      variable private

      #--- je recupere la liste des des fichiers
      set var [ftp::List $private(connection) "$fullPath"]

      set filenames ""
      foreach ligne $var {
         set n [string length $ligne]
         #::console::disp "   ligne=$ligne n=$n\n"
         if {$n>10} {
            set id [string range $ligne 0 1]
            #::console::disp "n=$n id=$id ligne $ligne \n"
            if {$id=="dr" } {
               set isdir 1
               set date " "
               set size " "
               set name [lrange $ligne $private(namePositionBegin) end]
               if { $name != ".." && $name != "."} {
                 ### ::console::disp "   append name=$name \n"
                  lappend filenames [list "$isdir" "$name" "$date" "$size" ]
               }
            } elseif { $id == "-r" } {
               set isdir 0
               set date "1000000"
               set size [lindex $ligne $private(sizePosition)]
               set name [lrange $ligne $private(namePositionBegin)   end]
               lappend filenames [list "$isdir" "$name" "$date" "$size" ]
            }
         }
      }
      return $filenames
   }

   #------------------------------------------------------------
   ## @brief copie le fichier du server distant sur le poste local
   #  @param sourceFile
   #  @param targetDir
   #  @param size
   #
   proc get { sourceFile targetDir { size } } {
      variable private

      #--- j'affiche une barre de progression
      showProgressWindow $size $sourceFile

      #--- je verifie que le fichier est bien sur le server distant
      #--- (risque de blocage du "get" si le fichier n'existe plus)
      # ne pas utiliser NList  car non implemente sur tous les serveurs
      #set result [ftp::NList $private(connection) "$sourceFile" ]
      #set test [string equal "$result" "$sourceFile"]
      #if { $test == 0 } {
      #   console::affiche_erreur "ftpclient::get [getUrl]$sourceFile not found !\n"
      #   return 0
      #}

      #--- je copie le fichier dans le repertoire local
      set temp "[pwd]"
      cd "$targetDir"
      catch {
         set result [ftp::Get $private(connection) "$sourceFile" "."]
      }

      #--- il faut absolument revenir dans le repertoire de base
      cd "$temp"

      return
   }

   #------------------------------------------------------------
   #  brief affiche une barre de progression dans une fenêtre indépendante
   #  param targetsize
   #  param sourceFile
   #
   proc showProgressWindow { targetsize sourceFile } {
      variable private
      global audace caption color

      if { ![string is integer $targetsize] } {
         set targetsize "0"
      }

      #--- je memorise la taille du fichier a copier
      set private(targetsize) $targetsize

      if [ winfo exists $audace(base).ftpprogress ] {
         destroy $audace(base).ftpprogress
      }

      toplevel $audace(base).ftpprogress
      wm transient $audace(base).ftpprogress $audace(base)
      wm resizable $audace(base).ftpprogress 0 0
      wm title $audace(base).ftpprogress "$caption(ftpclient,file_copy) $sourceFile"
      wm geometry $audace(base).ftpprogress +140+315

      #--- Cree le widget et le label du temps ecoule
      label $audace(base).ftpprogress.lab_status -text " 0 / $targetsize" -justify center
      pack $audace(base).ftpprogress.lab_status -side top -fill x -expand true -pady 5

      set cpt "0"
      #--- Cree le widget pour la barre de progression
      frame $audace(base).ftpprogress.cadre -width 300 -height 30 -borderwidth 2 -relief groove -bg $color(white)
      pack $audace(base).ftpprogress.cadre -in $audace(base).ftpprogress -side top -anchor center -fill x \
         -expand true -padx 8 -pady 8

      #--- Affiche de la barre de progression
      frame $audace(base).ftpprogress.cadre.barre_color_invariant -height 26 -bg $color(blue)
      place $audace(base).ftpprogress.cadre.barre_color_invariant -in $audace(base).ftpprogress.cadre -x 0 -y 0 \
         -relwidth [ expr $cpt/100.0 ]

      #--- bouton OK
      button $audace(base).ftpprogress.but_ok -text " OK " -width 12  -justify center -state disabled \
         -command "ftpclient::stopProgress"
      pack $audace(base).ftpprogress.but_ok -side bottom  -fill none -expand true -pady 5 -ipady 5

      #--- La nouvelle fenetre est active
      focus $audace(base).ftpprogress

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).ftpprogress
   }

   #------------------------------------------------------------
   #  brief met à jour la barre de progression
   #  warning cette procédure est appellée automatiquement pendant le transfert d'un fichier (voir ::ftp::Open)
   #
   proc progress { total } {
      variable private
      global audace

      #--- calcule le pourcentage de donnees copiees
      if { $private(targetsize) != 0 } {
         set cpt [expr ($total*100 / $private(targetsize)) ]
      } else {
         set cpt 100
      }

      if { ![ winfo exists $audace(base).ftpprogress ] } {
         #--- si la fenetre de la barre de progression n'existe pas
         return
      }

      #--- j'affiche la nouvelle valeur
      $audace(base).ftpprogress.lab_status configure -text "$total / $private(targetsize)"

      #--- je fais avancer la barre de progresssion
      place $audace(base).ftpprogress.cadre.barre_color_invariant -in $audace(base).ftpprogress.cadre -x 0 -y 0 \
         -relwidth [ expr $cpt/100.0 ]

      #--- j'active le bouton OK quand la copie est terminee
      if { "$cpt" == "100" } {
         $audace(base).ftpprogress.but_ok configure -state normal
      }
   }

   #------------------------------------------------------------
   #  brief ferme la fenêtre de progression et arrête le transfert
   #  warning pas encore trouvé de solution satisfaisante
   #
   proc stopProgress { } {
      variable private
      global audace

      destroy $audace(base).ftpprogress

      #::ftp::stopCopy $private(connection) $private(targetsize)
      #set ::ftp::ftp(Total) $::ftpclient::private(targetsize)
      #closeCnx $::ftp::ftp$private(connection)(SourceCI)
      #unset ::ftp::ftp(get:channel)
      #--- fermer et re ouvrir la connexion
      #closeCnx
      #openConnection
   }

   #------------------------------------------------------------
   #  ftpclient::initVar
   #  initialise les parametres dans le tableau conf()
   #
   proc initVar { } {
      global conf

      if {![info exists conf(ftpclient,connection,0)]} {
      #--- je prepare un exemple de connexion par defaut
         array set connection {}
         set connection(hostname)          "localhost"
         set connection(port)              "21"
         set connection(user)              "anonymous"
         set connection(directory)         "/mesdoc~1"
         set connection(sizePosition)      "4"
         set connection(namePositionBegin) "8"

         set conf(ftpclient,connection,0) [array get connection]
      }

      if {![info exists conf(ftpclient,connection,1)]} {
         #--- je prepare un exemple de connexion par defaut
         array set connection {}
         set connection(hostname)          "ftp.globetrotter.net"
         set connection(port)              "21"
         set connection(user)              "anonymous"
         set connection(directory)         "/astroccd"
         set connection(sizePosition)      "4"
         set connection(namePositionBegin) "8"

         set conf(ftpclient,connection,1) [array get connection]
      }

      if {![info exists conf(ftpclient,connection,2)]} {
         #--- je prepare un exemple de connexion par defaut
         array set connection {}
         set connection(hostname)          "ftp.sunet.se"
         set connection(port)              "21"
         set connection(user)              "anonymous"
         set connection(directory)         "/pub/pictures/astro-images"
         set connection(sizePosition)      "4"
         set connection(namePositionBegin) "8"

         set conf(ftpclient,connection,2) [array get connection]
      }

      initConf
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de l'outil "Serveur FTP"
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(ftpclient,connection,0)
   #  - conf(ftpclient,connection,1)
   #  - conf(ftpclient,connection,2)
   #  - conf(ftpclient,connection,3)
   #  - conf(ftpclient,connection,4)
   #  - conf(ftpclient,connection,5)
   #  - conf(ftpclient,connection,6)
   #  - conf(ftpclient,connection,7)
   #  - conf(ftpclient,connection,8)
   #  - conf(ftpclient,connection,9)
   #  - conf(ftpclient,timeout)
   #  @todo définir la signification des paramètres
   proc initConf { } {
      global conf

      #if {![info exists conf(ftpclient,connection,3)]} { set conf(ftpclient,connection,0) "" } ; # défini avant
      #if {![info exists conf(ftpclient,connection,4)]} { set conf(ftpclient,connection,1) "" } ; # défini avant
      #if {![info exists conf(ftpclient,connection,5)]} { set conf(ftpclient,connection,2) "" } ; # défini avant
      if {![info exists conf(ftpclient,connection,3)]} { set conf(ftpclient,connection,3) "" }
      if {![info exists conf(ftpclient,connection,4)]} { set conf(ftpclient,connection,4) "" }
      if {![info exists conf(ftpclient,connection,5)]} { set conf(ftpclient,connection,5) "" }
      if {![info exists conf(ftpclient,connection,6)]} { set conf(ftpclient,connection,6) "" }
      if {![info exists conf(ftpclient,connection,7)]} { set conf(ftpclient,connection,7) "" }
      if {![info exists conf(ftpclient,connection,8)]} { set conf(ftpclient,connection,8) "" }
      if {![info exists conf(ftpclient,connection,9)]} { set conf(ftpclient,connection,9) "" }
      if {![info exists conf(ftpclient,timeout)]}      { set conf(ftpclient,timeout) 10 }
   }

   #==============================================================
   # Fonctions de configuration generiques
   #
   # fillConfigPage  affiche la fenetre de config
   # getLabel        retourne le titre de la fenetre de config
   # cmdApply        applique les modifications
   # showHelp        affiche l'aide
   #==============================================================

   #------------------------------------------------------------
   #  brief retourne le label de la fenêtre de configuration
   #  note utilisée par ::confGenerique
   #  return ftpclient
   #
   proc getLabel { } {
       return "ftpclient"
   }

   #------------------------------------------------------------
   #  brief copie les paramètres du tableau conf() dans les variables des widgets
   #  note utilisée par ::confGenerique
   #
   proc confToWidget { } {
      variable private
      variable widget
      global conf

      #--- je prepare les valeurs de la combobox
      set widget(cbprev)   ""
      foreach {key value} [array get conf ftpclient,connection,*] {
         if { "$value" == "" } continue
         #--- je mets les valeurs dans un array (de-serialisation)
         array set connection $value
         #--- je prepare la ligne a afficher dans la combobox
         set line [format "ftp://%s:%s%s " $connection(hostname) $connection(port) $connection(directory) ]
         #--- j'ajoute la ligne
         lappend widget(cbprev) "$line"
      }

      #--- autre widget sauvegarde dans conf()
      set widget(timeout)  $conf(ftpclient,timeout)

      #--- valeur non sauvegardee dans conf()
      set widget(password) $private(password)
   }

   #------------------------------------------------------------
   #  brief copie les variables des widgets dans le tableau conf() ou private()
   #  et ouvre la connexion ftp
   #  note appelée par ::confGenerique quand on termine avec le bouton OK ou APPLIQUER
   #  param visuNo numéro de la visu
   #
   proc cmdApply { visuNo } {
      variable private
      variable widget
      global caption conf

      #--- je copie les valeurs des widgets
      set private(hostname)          $widget(hostname)
      set private(port)              $widget(port)
      set private(user)              $widget(user)
      set private(directory)         $widget(directory)
      set private(sizePosition)      $widget(sizePosition)
      set private(namePositionBegin) $widget(namePositionBegin)
      set conf(ftpclient,timeout)    $widget(timeout)
      set private(password)          $widget(password)

      if { $private(namePositionBegin) == "" } { set private(namePositionBegin) "0" }

      #--- j'ouvre la connexion ftp
      set result [openConnection]

      #--- si la connexion est OK
      if { $result == 1 } {
         #--- j'ajoute la nouvelle connexion en tete dans le tableau des connexions precedentes si elle n'y est pas deja
         array set connection {}
         set connection(hostname)          "$private(hostname)"
         set connection(port)              "$private(port)"
         set connection(user)              "$private(user)"
         set connection(directory)         "$private(directory)"
         set connection(sizePosition)      "$private(sizePosition)"
         set connection(namePositionBegin) "$private(namePositionBegin)"

         #--- je copie conf dans templist en mettant la connexion courante en premier
         array set templist {}
         set templist(0) [array get connection]
         set j 1
         foreach {key value} [array get conf ftpclient,connection,*] {
            if { "$value" == "" } {
               set templist($j) ""
               incr j
            } else {
               array set temp1 $value
               if { "$temp1(hostname)"!= "$connection(hostname)"
                  || "$temp1(port)" != "$connection(port)" } {
                  set templist($j) [array get temp1]
                  incr j
               }
            }
         }

         #-- je copie templist dans conf
         for {set i 0} {$i < 10 } {incr i } {
            set conf(ftpclient,connection,$i) $templist($i)
         }

      } else {
         #--- erreur de connexion
         set message "$caption(ftpclient,connection_error) ftp://$widget(user)@$widget(hostname):$widget(port)"
         tk_messageBox -title "ftpclient" -type ok -message "$message" -icon error
       }
   }

   #------------------------------------------------------------
   #  brief affiche les widgets dans la fenêtre de configuration
   #  note appelée par ::confGenerique à l'ouverture de la fenêtre de configuration
   #  param frm chemin Tk
   #  param visuNo numéro de la visu
   #
   proc fillConfigPage { frm visuNo } {
      variable widget
      variable private
      global caption

      #--- je memorise la reference de la frame
      set widget(frm) $frm
      #--- quelques raccourcis utiles
      set private(cbprev) $widget(frm).frameprev.cbprev

      #--- j'initialise les valeurs des widgets
      confToWidget

      #--- frame previous connections
      frame $widget(frm).frameprev -borderwidth 1 -relief raised
      pack $widget(frm).frameprev -side top -fill both -expand 1

      #--- combobox
      ComboBox $widget(frm).frameprev.cbprev
      $widget(frm).frameprev.cbprev configure -relief sunken
      $widget(frm).frameprev.cbprev configure -borderwidth 1
      $widget(frm).frameprev.cbprev configure -editable 0
      $widget(frm).frameprev.cbprev configure -takefocus 0
      $widget(frm).frameprev.cbprev configure -modifycmd "::ftpclient::cbCommand $widget(frm).frameprev.cbprev"
      $widget(frm).frameprev.cbprev configure -values $widget(cbprev)

      pack $widget(frm).frameprev.cbprev -in $widget(frm).frameprev -anchor center -expand 0 -fill x -side top -padx 10 -pady 5

      #--- frame connection
      frame $widget(frm).framecnx -borderwidth 1 -relief raised
      pack $widget(frm).framecnx -side top -fill both -expand 1

      #--- frame host
      frame $widget(frm).framecnx.framehost -borderwidth 0 -relief raised
      pack $widget(frm).framecnx.framehost -side top -fill both -expand 1

      #--- hostname
      label $widget(frm).framecnx.framehost.labelHost -text "$caption(ftpclient,hostname)"
      pack $widget(frm).framecnx.framehost.labelHost -in $widget(frm).framecnx.framehost -anchor center -side left -padx 10 -pady 10
      entry $widget(frm).framecnx.framehost.entHost -textvariable ftpclient::widget(hostname) -width 30
      pack $widget(frm).framecnx.framehost.entHost -in $widget(frm).framecnx.framehost -anchor center -side left -padx 10 -pady 5

      #--- port
      label $widget(frm).framecnx.framehost.labelPort -text "$caption(ftpclient,port)"
      pack $widget(frm).framecnx.framehost.labelPort -in $widget(frm).framecnx.framehost -anchor center -side left -padx 10 -pady 10
      entry $widget(frm).framecnx.framehost.entPort -textvariable ftpclient::widget(port) -width 4 -justify right \
         -validatecommand {string is integer %P} -validate key -invcmd bell
      pack $widget(frm).framecnx.framehost.entPort -in $widget(frm).framecnx.framehost -anchor center -side left -padx 10 -pady 5

      #--- frame login
      frame $widget(frm).framecnx.framelogin -borderwidth 0 -relief raised
      pack $widget(frm).framecnx.framelogin -side top -fill both -expand 1

      #--- user
      label $widget(frm).framecnx.framelogin.labelUser -text "$caption(ftpclient,user)"
      pack $widget(frm).framecnx.framelogin.labelUser -in $widget(frm).framecnx.framelogin -anchor center -side left -padx 10 -pady 10
      entry $widget(frm).framecnx.framelogin.entUser -textvariable ftpclient::widget(user) -width 20
      pack $widget(frm).framecnx.framelogin.entUser -in $widget(frm).framecnx.framelogin -anchor center -side left -padx 10 -pady 5

      #--- password
      label $widget(frm).framecnx.framelogin.labelPassword -text "$caption(ftpclient,password)"
      pack $widget(frm).framecnx.framelogin.labelPassword -in $widget(frm).framecnx.framelogin -anchor center -side left \
            -padx 10 -pady 10
      entry $widget(frm).framecnx.framelogin.entPassword -textvariable ftpclient::widget(password) -width 20 -show "*"
      pack $widget(frm).framecnx.framelogin.entPassword -in $widget(frm).framecnx.framelogin -anchor center -side left \
            -padx 10 -pady 5

      #--- frame dir
      frame $widget(frm).framecnx.framedir -borderwidth 0 -relief raised
      pack $widget(frm).framecnx.framedir -side top -fill both -expand 1

      #--- directory
      label $widget(frm).framecnx.framedir.labelDir -text "$caption(ftpclient,directory)"
      pack $widget(frm).framecnx.framedir.labelDir -in $widget(frm).framecnx.framedir -anchor center -side left -padx 10 -pady 10
      entry $widget(frm).framecnx.framedir.entDir -textvariable ftpclient::widget(directory) -width 40
      pack $widget(frm).framecnx.framedir.entDir -in $widget(frm).framecnx.framedir -anchor center -side left -padx 10 -pady 5

      #--- timeout
      label $widget(frm).framecnx.framedir.labelTimeout -text "$caption(ftpclient,timeout)"
      pack $widget(frm).framecnx.framedir.labelTimeout -anchor center -side left -padx 10 -pady 10
      entry $widget(frm).framecnx.framedir.entTimeout -textvariable ftpclient::widget(timeout) -width 4 -justify right \
         -validatecommand {string is integer %P} -validate key -invcmd bell
      pack $widget(frm).framecnx.framedir.entTimeout -anchor center -side left -padx 10 -pady 5

      #--- frame position
      frame $widget(frm).framecnx.framePosition -borderwidth 0 -relief raised
      pack $widget(frm).framecnx.framePosition -side top -fill both -expand 1

      #--- sizePosition
      label $widget(frm).framecnx.framePosition.labelSize -text "$caption(ftpclient,sizePosition)"
      pack $widget(frm).framecnx.framePosition.labelSize -anchor center -side left -padx 10 -pady 10
      entry $widget(frm).framecnx.framePosition.entSize -textvariable ftpclient::widget(sizePosition) -width 4 -justify right \
         -validatecommand {string is integer %P} -validate key -invcmd bell
      pack $widget(frm).framecnx.framePosition.entSize -anchor center -side left -padx 10 -pady 5

      #--- namePositionBegin
      label $widget(frm).framecnx.framePosition.labelNameBegin -text "$caption(ftpclient,namePositionBegin)"
      pack  $widget(frm).framecnx.framePosition.labelNameBegin -anchor center -side left -padx 10 -pady 10
      entry $widget(frm).framecnx.framePosition.entNameBegin -textvariable ftpclient::widget(namePositionBegin) -width 4 \
         -justify right -validatecommand {string is integer %P} -validate key -invcmd bell
      pack $widget(frm).framecnx.framePosition.entNameBegin -anchor center -side left -padx 2 -pady 2

      #--- preview button
      button $widget(frm).framecnx.framePosition.butPreview -text "$caption(ftpclient,preview)" \
         -command "ftpclient::preview $widget(frm).framepreview.listpreview $widget(frm).framepreview.detail.name $widget(frm).framepreview.detail.size"
      pack $widget(frm).framecnx.framePosition.butPreview -anchor center -side left -padx 10 -pady 10 -ipady 5

      #--- frame preview (cette frame est affcihee quand on clique sur le bouton preview)
      frame $widget(frm).framepreview -borderwidth 1 -relief raised
      #pack $widget(frm).framepreview -side top -fill both -expand 1

      #--- listpreview
      label $widget(frm).framepreview.listpreview -justify left
      pack $widget(frm).framepreview.listpreview -anchor center -side top -padx 2 -pady 2 -fill both -expand 1

      #--- frame preview detail
      frame $widget(frm).framepreview.detail -borderwidth 1 -relief raised
      pack $widget(frm).framepreview.detail -side top -fill both -expand 1

      #--- name preview
      label $widget(frm).framepreview.detail.name -justify left
      pack $widget(frm).framepreview.detail.name -anchor center -side left -padx 2 -pady 2 -fill both -expand 1

      #--- size preview
      label $widget(frm).framepreview.detail.size -justify left
      pack $widget(frm).framepreview.detail.size -anchor center -side left -padx 2 -pady 2 -fill both -expand 1

      #--- je selectionne le premier element de la combobox
      $widget(frm).frameprev.cbprev setvalue first
      cbCommand $widget(frm).frameprev.cbprev
   }

   #------------------------------------------------------------
   #  brief affiche les valeurs dans les widgets
   #  note appelée par la combobox à chaque changement de sélection
   #  param cb
   #
   proc cbCommand { cb } {
      variable widget
      global conf

      #--- je recupere l'index de l'element selectionne
      set index [$cb getvalue ]
      if { "$index" == "" } {
         set index 0
      }

      #--- je recupere les attributs de la connexion de conf()
      array set connection $conf(ftpclient,connection,$index)

      #--- je copie les valeurs dans les widgets
      set widget(hostname)          $connection(hostname)
      set widget(port)              $connection(port)
      set widget(user)              $connection(user)
      set widget(directory)         $connection(directory)
      set widget(sizePosition)      $connection(sizePosition)
      set widget(namePositionBegin) $connection(namePositionBegin)
   }

   #------------------------------------------------------------
  #   brief affiche les valeurs dans les autres widgets
   #   note appelée par le bouton de pre-visualisation
   #   param listpreview
   #   param namepreview
   #   param sizepreview
   #
   proc preview { listpreview namepreview sizepreview } {
      variable widget
      global caption

      #--- j'ouvre la connexion ftp avc les parametres temporaires
      set cnx [ftp::Open $widget(hostname) $widget(user) $widget(password) -port $widget(port) -timeout $widget(timeout) ]

      if {$cnx == -1} {
        set message "$caption(ftpclient,connection_error) ftp://$widget(hostname):$widget(port)"
         tk_messageBox -title "ftpclient" -type ok -message "$message" -icon error
         return 0
      }

      #--- je lis le contenu du repertoire
      set listResult [ftp::List $cnx "$widget(directory)" ]

      if { $listResult == "" } {
         set message "$caption(ftpclient,directory_error) \"$widget(directory)\" "
         tk_messageBox -title "ftpclient" -type ok -message "$message" -icon error
         return 0
      }

      #--- je compte le nombre de colonnes dans la premiere ligne
      set nbcol [string length "[lindex $listResult 0]"]
      set nbline [llength  $listResult ]

      set lines ""
      set names "name\n"
      set sizes  "size\n"

      #--- j'affiche les 4 premieres lignes
      for {set i 0} {$i < 10 && $i < $nbline } {incr i } {
        set line     [lindex $listResult $i]
        append lines "$line\n"
        append names "[lrange $line $widget(namePositionBegin)  end]\n"
        append sizes "[lindex $line $widget(sizePosition) ]\n"
       # console::disp "nbcol=$nbcol $i line=$line \n"
      }
      if { $nbline > $i } {
         append lines "..."
      }

      #--- je copie les donnes dans les widgets
      $listpreview configure -text "$lines"
      $namepreview configure -text "$names"
      $sizepreview configure -text "$sizes"

      #--- j'affiche le resultat
      pack  [winfo parent $listpreview] -side top -fill both -expand 1
      ftp::Close $cnx
   }

}

################################################################
# namespace ftpdserver  (pour les tests)
################################################################

namespace eval ::ftpserver {

   proc start { } {
      package require ftpd

      ::ftpd::config -authUsrCmd ::ftpserver::noauth -logCmd ::ftpserver::log

      ::ftpd::server
   }

   proc noauth { args } {
      return 1
   }

   proc log { args } {
     # ::console::disp "ftpd $args\n"
   }

}

::ftpclient::init
#::ftpserver::start

