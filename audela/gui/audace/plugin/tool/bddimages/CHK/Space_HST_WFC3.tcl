##################################################################################################
# Telelescope du l ' Observatoire du Pico dos Dias Itajuba Br�sil pour la 
# Camera IKON-L
##################################################################################################


##################################################################################################
# procedure de la derniere Chance !
# Elle permet de modifier les cl�s des headers en se basant sur le nom de l image.
# tres dangeureuse car modifie les images brutes
# cela est contraire a la philo de bddimages qui cherche a conserver les images brutes
#
# lancer dans la console le source suivant :
#
#  >  source [ file join $audace(rep_plugin) tool bddimages CHK Space_HST_WFC3.tcl]
#
##################################################################################################

    proc modif_img_header_hst { name path dest} {


      set fichiers [lsort [glob -nocomplain ${path}/*${name}*]]

      foreach fichier $fichiers {

         # charge l image
         loadima $fichier

         ::console::affiche_resultat "FILE= $fichier\n"
         set cmd "gunzip -cd $fichier > i.fits"
         ::console::affiche_resultat "CMD= $cmd\n"
         lassign [::bdi_tools::gunzip $xml $tmpfile] errnum msgzip         
         #set errnum [catch {exec gunzip -cd $fichier > i.fits} msg ]
         ::console::affiche_resultat "ERR= $errnum\n"
         ::console::affiche_resultat "MSG= $msg\n"
         set errnum [catch {exec gethead i.fits TELESCOP DATE-OBS TIME-OBS INSTRUME EXPTIME} msg ]
         ::console::affiche_resultat "ERR= $errnum\n"
         ::console::affiche_resultat "MSG= $msg\n"

         set tab [ split $msg]
         set tel [lindex $tab 0]
         set date [lindex $tab 1]
         set ti [lindex $tab 2]
         set instrum [lindex $tab 3]
         set exposure [lindex $tab 4]

         # modifi les header
         set date "${date}T${ti}"
         buf1 setkwd [list "DATE-OBS"  $date "string" "UT date of start of observation" ""]
         buf1 setkwd [list "EXPOSURE" $exposure  "double" "exposure duration (seconds)--calculated" ""]
         buf1 setkwd [list "TELESCOP" $tel  "string" "Object name inside field" ""]
         buf1 setkwd [list "INSTRUME" $instrum  "string" "identifier for instrument used to acquire data" ""]
         buf1 setkwd [list "OBJECT" "136108_Haumea" "string" "Object name inside field" ""]
         buf1 setkwd [list "IAU_CODE" "@HST" "string" "Observatory IAU Code" ""]

         ::bddimagesAdmin::bdi_setcompat 1
         buf1 setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]   
         buf1 setkwd [list "BDDIMAGES TYPE"  "IMG" "string" "IMG | FLAT | DARK | OFFSET | ?" ""]

         # sauve l image
         set f [file tail $fichier]
         set f [string range $f 0 [expr [string last .fits $f] -1]]
         set newfile [file join $dest "${f}_CHK.fits"]
         ::console::affiche_resultat "sauve image : $newfile\n"
         saveima $newfile

         # take a look
         # set lh [buf1 getkwds]
         #::console::affiche_resultat "$lh\n"
          #break
      }

      return
   }









# ----------------------------------------------------------------------------------------------------

# --
#  >  source [ file join $audace(rep_plugin) tool bddimages CHK Space_HST_WFC3.tcl]

# ----------------------------------------------------------------------------------------------------

#  set path "/work/AsterOA/136108_Haumea/Observations/HST/science/drz"
#  set dest "/work/Observations/bddimages/incoming"
   set path "/data/astrodata/Observations/Images/bddimages/bddimages_local/tmp/img"
   set dest "/data/astrodata/Observations/Images/bddimages/bddimages_local/tmp/CHK"

   ::console::affiche_resultat "Rep travail = $path\n"

   modif_img_header_hst "drz"  $path $dest

   return

