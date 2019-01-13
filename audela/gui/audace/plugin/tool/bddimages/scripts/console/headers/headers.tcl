# source [ file join $audace(rep_plugin) tool bddimages utils traitement_auto_no_console_multithread main.tcl]

global audace

set langage english

#--- Taking into account the coding UTF-8 (caractères accentués pris en compte)
encoding system utf-8

#--- Use standard C precision
#--- New default tcl_precision=0 of TCL 8.5 using 17 digits produces differents and
#--- less intuitive results than TCl 8.4 which used default tcl_precision=12
#--- For example  expr -3*0.05 return -0.15000000000000002
#--- So Audela uses tcl_precision=12 for simpler results and for compatibility with legacy code
#--- For example  expr -3*0.05 = -0.15

#--- Add audela/lib directory to ::auto_path if it doesn't already exist
set audelaLibPath [file join [file join [file dirname [file dirname [info nameofexecutable]] ] lib]]
if { [lsearch $::auto_path $audelaLibPath] == -1 } {
   lappend ::auto_path $audelaLibPath
}

source [file join $::audela_start_dir version.tcl]

#--- Creation du repertoire de configuration d'Aud'ACE
if { $::tcl_platform(platform) == "unix" } {
   set ::audace(rep_home) [ file join $::env(HOME) .audela ]
} else {
   #--- ajout de la commande "package require registry" pour Vista et Win7
   #--- car cette librairie n'est pas chargee automatiquement au demarrage
   #--- bien qu'elle fasse partie du coeur du TCL
   package require registry
   set applicationData [ ::registry get "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders" AppData ]
   set ::audace(rep_home) [ file normalize [ file join $applicationData AudeLA ] ]
}
if { ! [ file exist $::audace(rep_home) ] } {
   file mkdir $::audace(rep_home)
}
#--- Creation du repertoire des traces
set ::audace(rep_log) [ file join $::audace(rep_home) log ]
if { ! [ file exist $::audace(rep_log) ] } {
   file mkdir $::audace(rep_log)
}

#--- Indication aux bibliothèques de l'emplacement des fichiers logs
#---  si la blibliotheque est presente
if { [info command jm_repertoire_log ] != "" } {
   jm_repertoire_log $::audace(rep_log)
}

#--- Creation du repertoire des fichiers temporaires
if { $::tcl_platform(platform) == "unix" } {
   set ::audace(rep_temp) [ file join /tmp ".audace.$::env(USER)"]
} else {
   set ::audace(rep_temp) [ file join $::env(TMP) .audace ]
}
if { ! [ file exists $::audace(rep_temp) ] } {
   file mkdir $::audace(rep_temp)
}

namespace eval ::console {
   proc affiche_resultat { msg } { puts "$msg" }
   proc affiche_erreur { msg } { puts "$msg" }
   proc affiche_debug { msg } { puts "$msg" }
}

if { [ file exists [ file join $::audace(rep_home) audace.txt ] ] == 1 } {
   set langage english
   set fichierLangage [ file join $::audace(rep_home) langage.tcl ]
   if { [ file exists $fichierLangage ] } { file rename -force "$fichierLangage" [ file join $::audace(rep_home) langage.ini ] }
   catch { source [ file join $::audace(rep_home) langage.ini ] }
}

set ligne "proc bell \{ \{args \"\"\} \} \{ \}"
eval $ligne
set ligne "proc bind \{ \{args \"\"\} \} \{ \}"
eval $ligne
set ligne "proc update \{ \{args \"\"\} \} \{ \}"
eval $ligne

cd [file join $::audela_start_dir ../gui/audace]

# --- set audace array
set audace(rep_install) [file normalize [pwd]/../..] ; # /srv/develop/audela
set audace(rep_gui) [file normalize [pwd]/..]
set audace(rep_caption) [ file join $audace(rep_gui) audace caption ]
set audace(rep_plugin) [ file join $audace(rep_gui) audace plugin ]

set audace(bufNo) [::buf::create] ;  # --- buf::create
set audace(visuNo) 0

# --- source env
puts "audace(rep_install)=$audace(rep_install)\n"
#package provide bddimages
source $audace(rep_install)/gui/audace/plugin/tool/bddimages/bddimages_go.tcl ; # proc gren_info
#source $audace(rep_install)/gui/audace/plugin/tool/bddimages/bddimages_sql.tcl

::bddimages::ressource


# Demarrage
   gren_info "Demarrage:"
   set err [catch { ::bdi_tools_headers::go } msg ]
   gren_info "Erreur de fin : $err"
   gren_info "Message de fin : $msg"

   exit $err
