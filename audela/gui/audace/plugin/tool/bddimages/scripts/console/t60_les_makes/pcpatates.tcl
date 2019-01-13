# source [ file join $audace(rep_plugin) tool bddimages scripts console load_audela.tcl]

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
set tcl_precision 17

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
source $audace(rep_install)/gui/audace/plugin/tool/bddimages/bdi_tools_astroid.tcl ; # proc ::bdi_tools_astroid::set_own_env 
source $audace(rep_install)/gui/audace/plugin/tool/bddimages/bddimages_sql.tcl

load [file join $audace(rep_install) bin libmysqltcl[info sharedlibextension]]
 
::bddimages::ressource_tools

# Deplacement des donnees du repertoire agora vers incoming

puts  "[gren_date] Deplacement des donnees du repertoire agora vers incoming"

set dir_source "/mnt/agora_incoming"
set dir_dest   "/bddimages/bdi_t60_les_makes/incoming"

set sortie no

   while {$sortie == "no"} {

      set err [catch {set files [glob $dir_source/*fit*]} msg ]

      if {$err} {
         after 60000
      } else {
         if {[llength $files] == 0} {         
            after 60000
         } else {
            set sortie "yes"
         }
      }
   }



   foreach f $files {
      set err [catch {set size1 [file size $f]} msg ]
      if {$err} {
         gren_info "CMD    : set size1 "
         gren_info "ERREUR : $err "
         gren_info "MSG    : $msg "
         continue
      }
      
      after 500

      set err [catch {set size2 [file size $f]} msg ]
      if {$err} {
         gren_info "CMD    : set size1 "
         gren_info "ERREUR : $err "
         gren_info "MSG    : $msg "
         continue
      }

      if {$size1!=$size2} { continue }
      set f [file tail $f]
      gren_info "move $f size=$size1"
      set file_source [file join $dir_source $f]
      set file_dest   [file join $dir_dest   $f]

      set err [catch {file rename -force -- $file_source $file_dest} msg ]
      if {$err} {
         gren_info "CMD    : move "
         gren_info "ERREUR : $err "
         gren_info "MSG    : $msg "
      }
   }
   gren_info "DEPLACEMENT TERMINE. ON PASSE A LA SUITE...\n\n\n\n\n"


exit
