#
# Fichier : obscgi.tcl
# Mise à jour $Id: obscgi.tcl 13612 2016-04-04 16:34:15Z robertdelmas $
#

# - variables communes a tous les scripts
source scripts/cfgcgi.tcl

# - creation des instruments
if {[info exists audace]==0} {
   # - Pas de contexte Aud'ACE
   ::tel::create lx200 com2 -num 1
   ::buf::create 1
   ::cam::create audine lpt1 -num 1
   cam1 buf 1
} else {
   # - Pour le contexte Aud'ACE
   if {[::tel::list]==""} {
      ::confTel::run
      tkwait window .confTel
      update
   }
   if {[::cam::list]==""} {
      ::confCam::run
      tkwait window .confCam
      update
   }
}

# - gestionnaire des observations
set sortie no
while {$sortie=="no"} {
   after 1000
   update
   set now [clock format [clock seconds] -timezone :UTC -format "%Y %m %d %H %M %S"]
   # - Analyse les requêtes présentes sur le disque
   set list_file ""
   catch {set list_file [lsort -increasing [glob "$rep(req)/*.req"]]} result
   set observable no
   if {[llength $list_file]!=0} {
      foreach file $list_file {
         source "$file"
         set result [mc_radec2altaz $ra $dec {gps 2.1383 e 45.1234 125} $now]
         set h [lindex $result 2]
         set alt [lindex $result 1]
         if {((($h<60)||($h>300))&&($alt>30)&&($dec<50))} {
            set observable yes
            break
         }
      }
   }
   # - Traite la requete eventuellement choisie
   if {$observable=="yes"} {
      # - Nom du fichier image YYYMMDD_hhmmss_YYYMMDD_hhmmss_user.fit
      #                        |- date obs -| |- date req -|
      after 1000
      set reqname [file rootname [file tail $file]]
      set t [mc_date2iso8601 now]; # format YYYY-MM-DDThh:mm:ss
      set obsname "[string range $t 0 3][string range $t 5 6][string range $t 8 9]_"
      append obsname "[string range $t 11 12][string range $t 14 15][string range $t 17 18]_"
      set name "$obsname$reqname"
      set fullname "$rep(visu)/$name"
      # - Pointe le télescope
      tel1 radec goto [list $ra $dec]
      # - Réalise l'image CCD
      cam1 exptime $exptime
      cam1 bin [list $binning $binning]
      cam1 acq
      ::camera::waitStateStand 1
      # - Enregistre l'image sur le disque
      buf1 save "$fullname"
      # - detruit le fichier requete exécuté
      file delete "$file"
   }
}
if {[info exists audace]==0} {
   ::tel::delete 1
   ::buf::delete 1
   ::cam::delete 1
}

