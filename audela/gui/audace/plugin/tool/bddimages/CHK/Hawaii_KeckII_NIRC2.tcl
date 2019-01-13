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
#  >  source [ file join $audace(rep_plugin) tool bddimages CHK Hawaii_KeckII_NIRC2.tcl]
#
##################################################################################################


    proc modif_img_header_keck { name path dest} {


      set fichiers [lsort [glob -nocomplain ${path}/*${name}*]]

      foreach fichier $fichiers {

         # charge l image
         loadima $fichier

         set dateobs [buf1 getkwd "DATE-OBS"]
         set utc     [buf1 getkwd "UTC"]
         set date    [string trim [lindex $dateobs 1]]
         set ti      [string trim [lindex $utc 1]]
         set date "${date}T${ti}"

         set exposure [string trim [lindex [buf1 getkwd "ELAPTIME"] 1 ]]

         # modifi les header
         buf1 setkwd [list "DATE-OBS"  $date "string" "UT date of start of observation" ""]
         buf1 setkwd [list "EXPOSURE" $exposure  "double" "exposure duration (seconds)" ""]
         buf1 setkwd [list "OBJECT" "136108_Haumea" "string" "Object name inside field" ""]
         buf1 setkwd [list "IAU_CODE" "568" "string" "Observatory IAU Code" ""]



         ::bddimagesAdmin::bdi_setcompat 1
         buf1 setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]   
         buf1 setkwd [list "BDDIMAGES TYPE"  "IMG" "string" "IMG | FLAT | DARK | OFFSET | ?" ""]
         buf1 setkwd [list "BIN1"  "1" "int" "Binning X" ""]
         buf1 setkwd [list "BIN2"  "1" "int" "Binning Y" ""]

         buf1 delkwd "CAMDIST"
         buf1 delkwd "CAMNAME"
         buf1 delkwd "CAMRAW"
         buf1 delkwd "CAMSTAT"
         buf1 delkwd "COMMENT"
         buf1 delkwd "FWIANGLE"
         buf1 delkwd "FWIANGL"
         buf1 delkwd "FWINAME"
         buf1 delkwd "FWIRAW"
         buf1 delkwd "FWISTAT"
         buf1 delkwd "FWOANGL"
         buf1 delkwd "FWONAME"
         buf1 delkwd "FWORAW"
         buf1 delkwd "FWOSTAT"
         buf1 delkwd "GRSDIST"
         buf1 delkwd "GRSNAME"
         buf1 delkwd "GRSRAW"
         buf1 delkwd "GRSSTAT"
         buf1 delkwd "PMRANGL"
         buf1 delkwd "PMSANGL"
         buf1 delkwd "PMSNAME"
         buf1 delkwd "PMSRAW"
         buf1 delkwd "PMSSTAT"
         buf1 delkwd "PSIDIST"
         buf1 delkwd "PSINAME"
         buf1 delkwd "PSIRAW"
         buf1 delkwd "PSISTAT"
         buf1 delkwd "PSODIST"
         buf1 delkwd "PSONAME"
         buf1 delkwd "PSORAW"
         buf1 delkwd "PSOSTAT"
         buf1 delkwd "SHRDIST"
         buf1 delkwd "SHRNAME"
         buf1 delkwd "SHRRAW"
         buf1 delkwd "SHRSTAT"
         buf1 delkwd "SLMDIST"
         buf1 delkwd "SLMNAME"
         buf1 delkwd "SLMRAW"
         buf1 delkwd "SLMSTAT"
         buf1 delkwd "SLSDIST"
         buf1 delkwd "SLSNAME"
         buf1 delkwd "SLSRAW"
         buf1 delkwd "SLSSTAT"

         # sauve l image
         set f [file tail $fichier]
         set f [string range $f 0 [expr [string last .fits $f] -1]]
         set newfile [file join $dest "KECKII_${date}_${f}_CHK.fits"]
         ::console::affiche_resultat "sauve image : $newfile\n"
         saveima $newfile

         # take a look
         # set lh [buf1 getkwds]
         #::console::affiche_resultat "$lh\n"
          #break
      }

      return
   }


# --
#  >  source [ file join $audace(rep_plugin) tool bddimages CHK Hawaii_KeckII_NIRC2.tcl]

# ----------------------------------------------------------------------------------------------------

#  set path "/work/AsterOA/136108_Haumea/Observations/HST/science/drz"
#  set dest "/work/Observations/bddimages/incoming"
#   set path "/data/astrodata/Observations/Images/bddimages/bddimages_local/tmp/img"
#   set dest "/data/astrodata/Observations/Images/bddimages/bddimages_local/tmp/CHK"

#
#   ::console::affiche_resultat "Rep travail = $path\n"

#   modif_img_header_keck "SnA"  $path $dest

#   return
# modif_img_header_keck camilla.H.01-DC.fits /data/astrodata/Observations/Images/bddimages/bdi_OA/redim.raw /data/astrodata/Observations/Images/bddimages/bdi_OA/incoming

# ----------------------------------------------------------------------------------------------------

