#
## @file logmonitor.tcl
#  @brief Affiche le contenu d'un fichier de trace
#  @author Michel Pujol
#  $Id: logmonitor.tcl 13707 2016-04-15 12:22:59Z robertdelmas $
#

##
# @brief Affiche le contenu d'un fichier de trace
# @details
# ::logmonitor::run  affiche le contenu d'un fichier de trace dans une fenêtre de surveillance
# et rafaichit l'affichage toutes le secondes.
#
# Si le fichier de trace n'existe pas, la fenêtre "Visu des traces" affiche "File not found"
# et vérifie périodiquement si le fichier est créé. Dès que le fichier est créé,
# la fenêtre affiche son contenu et rafaîchit l'affichage toutes le secondes.
#
# Le menu "Vider le fichier" permet de vider le contenu du fichier et d'effacer les traces existantes.
#
# La fermeture de la fenêtre est réalisée par l'utilisateur via le bouton "Fermer"
#
namespace eval ::logmonitor {

   #--- Charge le fichier caption
   source [ file join $::audace(rep_caption) logmonitor.cap ]
}

#------------------------------------------------------------
## @brief affiche la fenêtre
#  @param logFileName chemin complet du fichier
#  @return
#  - 0 si OK
#  - 1 si erreur (le message d'erreur est dans la variable globale \::errorInfo)
#
proc ::logmonitor::run { logFileName } {
   variable private

   set catchError [catch {
      set visuNo 1
      set private($visuNo,this) $::audace(base).logmonitor
      set private($visuNo,logFileName) $logFileName
      ::logmonitor::initConf
      ::confGenerique::run $visuNo $private($visuNo,this) "::logmonitor" -modal 0 -resizable 1
      ::logmonitor::openFile $visuNo
      return 0
   }]

   if { $catchError != 0 } {
      #--- je retourne le code d'erreur
      #--- le message d'erreur est dans la variable globale ::errorInfo
      return $catchError
   }
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'outil "Visu des traces"
#  @details la variables conf(...) suivante est sauvegardée dans le fichier de configuration "audace.ini" :
#  - \::conf(logmonitor,position) définit la position de la fenêtre
#  @private
proc ::logmonitor::initConf { } {

   if { ! [ info exists ::conf(logmonitor,position) ] }  { set ::conf(logmonitor,position)  "600x400+100+100" }
}

#------------------------------------------------------------
#  brief retourne le nom de la fenêtre de configuration
#
proc ::logmonitor::getLabel { } {

   return "$::caption(logmonitor,title)"
}

#------------------------------------------------------------
#  brief affiche l'aide de la fenêtre de configuration
#  @private
proc ::logmonitor::showHelp { } {

   ::audace::showHelpItem "$::help(dir,config)" "9999logmonitor.htm"
}

#------------------------------------------------------------
#  brief copie les paramètres du tableau conf() dans les variables des widgets
#  param visuNo numéro de la visu
#  @private
proc ::logmonitor::confToWidget { visuNo } {
   variable widget

   set widget(position) $::conf(logmonitor,position)
}


#------------------------------------------------------------
#  brief   crée la fenêtre de l'outil
#  param frm    chemin Tk de la fenêtre
#  param visuNo numéro de la visu
#  @private
proc ::logmonitor::fillConfigPage { frm visuNo } {
   variable widget
   variable private

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   #--- Je position la fenetre
   wm geometry [ winfo toplevel $widget(frm) ] $::conf(logmonitor,position)

   #--- J'initialise les variables des widgets
   confToWidget $visuNo

   #--- je cree le menu principal de la fenetre
   set private($visuNo,menu) "$private($visuNo,this).menubar"
   set menuNo "logmonitor${visuNo}"
   Menu_Setup $menuNo $private($visuNo,menu)
      #--- menu file
      Menu           $menuNo "$::caption(audace,menu,file)"
      Menu_Command   $menuNo "$::caption(audace,menu,file)" "$::caption(logmonitor,resetFile)" \
         "::logmonitor::clearFile $visuNo"
      ###Menu_Command   $menuNo "$::caption(audace,menu,file)" "$::caption(testaudela,ImageDirectory,installTitle)..." \
      ###   "::testaudela::downloadImageFile"
      Menu_Separator $menuNo "$::caption(audace,menu,file)"
      Menu_Command   $menuNo "$::caption(audace,menu,file)" "$::caption(audace,menu,quitter)" \
        "::confGenerique::cmdClose $visuNo [namespace current]"
  [MenuGet $menuNo $::caption(audace,menu,file)] configure -tearoff 0

   #--- je cree le widget text et la scollbar
   text $frm.text -yscrollcommand "$frm.scroll set"
   scrollbar $frm.scroll -command "$frm.text yview"
   pack $frm.scroll -side right -fill y
   pack $frm.text -side left -expand 1 -fill both
}

#------------------------------------------------------------
## @brief commande du bouton "Fermer"
#  @param visuNo numéro de la visu
#  @private
proc ::logmonitor::cmdClose { visuNo } {
   variable widget

   #--- je supprime le menubar et toutes ses entrees
   Menubar_Delete "logmonitor${visuNo}"

   #--- Je mets la position actuelle de la fenetre dans conf()
   set geom [ winfo geometry [winfo toplevel $widget(frm) ] ]
   set deb [ expr 1 + [ string first + $geom ] ]
   set fin [ string length $geom ]
   set ::conf(logmonitor,position) "+[ string range $geom $deb $fin ]"
}

#------------------------------------------------------------
## @brief affiche le fichier et lance la surveillance
#  @param visuNo numéro de la visu
#  @private
proc ::logmonitor::openFile { visuNo } {
   variable widget
   variable private

   set logFileName $private($visuNo,logFileName)
   wm title $private($visuNo,this) "[::logmonitor::getLabel] [file nativename $logFileName]"

   set catchError [catch {
      set logFile [open $logFileName]

      seek $logFile 0 end
      set currpos [tell $logFile]
      close $logFile
      set mtime [file mtime $logFileName]

   }]

   if { $catchError != 0 } {
      $widget(frm).text delete 0.0 end
      $widget(frm).text insert end "File not found $logFileName"
      $widget(frm).text see end
   }

   set currpos 0
   incr mtime -1000

   ::logmonitor::readFile $visuNo $mtime $currpos
}

#------------------------------------------------------------
## @brief lit le fichier et affiche les nouvelles lignes
#
#  @private
#  @param visuNo   numéro de la visu
#  @param oldmtime heure de dernière modification du fichier (nb de secondes depuis le 1er Janv 1970)
#  @param oldpos   ancienne position dans le fichier
#  @private
#
proc ::logmonitor::readFile { visuNo oldmtime oldpos } {
   variable widget
   variable private

   # check if the tail widget is not closed
   if {![winfo exists $widget(frm) ]} {
     # tail window closed
     return
   }
   set logFileName $private($visuNo,logFileName)

   set catchError [catch {
      set mtime [file mtime $logFileName]
      set currpos $oldpos
      if {$mtime != $oldmtime} {
        set logFile [open $logFileName r]
        seek $logFile $oldpos start
        set currpos [tell $logFile]
        if { $currpos <= $oldpos } {
           seek $logFile 0 start
           ###console::disp "::logmonitor::readFile reset currpos \n"
           $widget(frm).text delete 0.0 end
        }
        while {![eof $logFile]} {
          $widget(frm).text insert end [read $logFile]
        }
        $widget(frm).text see end
        set currpos [tell $logFile]

        close $logFile
        ###console::disp "::logmonitor::readFile oldpos=$oldpos currpos=$currpos oldmtime=$oldmtime mtime=$mtime\n"
      } else {
        ###console::disp "::logmonitor::readFile no change\n"
      }
      after 1000 [list ::logmonitor::readFile $visuNo $mtime $currpos]
   }]

   if { $catchError != 0 } {
      #--- j'affiche le message "File not found"
      $widget(frm).text delete 0.0 end
      $widget(frm).text insert end "File not found $logFileName"
      $widget(frm).text see end
      ###console::disp "::logmonitor::readFile File not found\n"
      set mtime $oldmtime
      set currpos $oldpos
      after 1000 [list ::logmonitor::readFile $visuNo $mtime $currpos]
   }
}

#------------------------------------------------------------
## @brief commande "Effacer le fichier" du menu "Fichier" de la fenêtre
#  @details efface le contenu de la fenêtre et vide le fichier
#
#  @private
#  @param visuNo numéro de la visu
#
proc ::logmonitor::clearFile { visuNo } {
   variable private
   variable widget

   set logFileName $private($visuNo,logFileName)

   #--- j'efface le contenu du widget text
   $widget(frm).text delete 0.0 end

   #-- j'efface le contenu du fichier
   set catchError [catch {
      close [open $logFileName w]
     }]

   if { $catchError != 0 } {
      #--- rien a faire (pas besoin de creer le fichier s'il n'existe pas
   }
}

