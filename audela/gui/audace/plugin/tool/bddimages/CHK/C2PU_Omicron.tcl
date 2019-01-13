##################################################################################################
# Telelescope C2PU / OMICRON
##################################################################################################

##################################################################################################
# procedure de la derniere Chance !
# Elle permet de modifier les cl�s des headers en se basant sur le nom de l image.
# tres dangeureuse car modifie les images brutes
# cela est contraire a la philo de bddimages qui cherche a conserver les images brutes
#
# lancer dans la console le source suivant :
#
#  >  source [ file join $audace(rep_plugin) tool bddimages CHK C2PU_Omicron.tcl]
#
##################################################################################################


    proc modif_img_header_c2pu { path dest} {
        
      global maliste
      set maliste {}
      globrdk ${path} 0

      foreach fichier $maliste {

         # charge l image
         loadima $fichier
         set dateobs [string trim [lindex [buf1 getkwd "DATE-OBS"] 1 ]]

         buf1 setkwd [list "IAU_CODE" "010" "string" "Observatory IAU Code" ""]

         set exposure [string trim [lindex [buf1 getkwd "EXPTIME"] 1 ]]
         buf1 setkwd [list "EXPOSURE" $exposure  "double" "exposure duration (seconds)" ""]

         set ra_sexa [string trim [lindex [buf1 getkwd "RA"] 1 ]]
         buf1 setkwd [list "RA_SEXA" $ra_sexa "string" "Mount RA (sexa)" ""]
         set ra_deci [string trim [lindex [buf1 getkwd "RA_D"] 1 ]]
         buf1 setkwd [list "RA" $ra_deci "double" "Mount RA" "deg"]

         set dec_sexa [string trim [lindex [buf1 getkwd "DEC"] 1 ]]
         buf1 setkwd [list "DEC_SEXA" $dec_sexa "string" "Mount DEC (sexa)" ""]
         set dec_deci [string trim [lindex [buf1 getkwd "DEC_D"] 1 ]]
         buf1 setkwd [list "DEC" $dec_deci "double" "Mount DEC" "deg"]

         set filter [string trim [lindex [buf1 getkwd "INSTFILT"] 1 ]]
         buf1 setkwd [list "FILTER" $filter "string" "Instrument filter" ""]

         set foclen [string trim [lindex [buf1 getkwd "FLENGTH"] 1 ]]
         buf1 setkwd [list "FOCLEN" $foclen "double" "Focal length" "m"]

         set bin1 [string trim [lindex [buf1 getkwd "BINX"] 1 ]]
         buf1 setkwd [list "BIN1" $bin1 "int" "Number of binned pixels in X" ""]
         set bin2 [string trim [lindex [buf1 getkwd "BINY"] 1 ]]
         buf1 setkwd [list "BIN2" $bin2 "int" "Number of binned pixels in Y" ""]

         set pixsize1 [string trim [lindex [buf1 getkwd "PIXSIZEX"] 1 ]]
         buf1 setkwd [list "PIXSIZE1" $pixsize1 "double" "Physical X pixel size" "um"]
         set pixsize2 [string trim [lindex [buf1 getkwd "PIXSIZEY"] 1 ]]
         buf1 setkwd [list "PIXSIZE2" $pixsize2 "double" "Physical Y pixel size" "um"]

         ::bddimagesAdmin::bdi_setcompat 1
         buf1 setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]   
         buf1 setkwd [list "BDDIMAGES TYPE"  "IMG" "string" "IMG | FLAT | DARK | OFFSET | ?" ""]

         # sauve l image
         set f [file tail $fichier]
         set f [string range $f 0 [expr [string last .fits $f] -1]]
         set newfile [file join $dest "C2PUOmicron_${dateobs}_${filter}_CHK.fits"]
         ::console::affiche_resultat "sauve image : $newfile\n"
         saveima $newfile

      }

      return
   }

# ----------------------------------------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool bddimages CHK C2PU_Omicron.tcl]
# set path "/data/tmp/xxx"
# set dest "/data/bddimages/bdi_xxx/incoming"
# modif_img_header_c2pu $path $dest
# ----------------------------------------------------------------------------------------------------
