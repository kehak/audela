##################################################################################################
# procedure de la derniere Chance !
# Elle permet de modifier les clés des headers en se basant sur le nom de l image.
# tres dangeureuse car modifie les images brutes
# cela est contraire a la philo de bddimages qui cherche a conserver les images brutes
##################################################################################################

    proc modif_img_header {  name newname path dest} {

      if { $newname == "OFFSET" || $newname == "DARK" || $newname == "FLAT"} {
         set key $newname
      } else {
         set key "IMG"
      }

      set fichiers [lsort [glob -nocomplain ${path}/*${name}*.fits]]
      ::console::affiche_resultat "Nb $key -> $newname = [llength $fichiers]\n"

      foreach fichier $fichiers {

         # charge l image
         loadima $fichier

         # modifi les header
         buf1 setkwd [list "OBJECT" $newname "string" "Object name inside field" ""]

         buf1 setkwd [list "BIN1" [lindex  [buf1 getkwd "HBIN"] 1] "int" "binning" ""]
         buf1 setkwd [list "BIN2" [lindex  [buf1 getkwd "VBIN"] 1] "int" "binning" ""]

         buf1 setkwd [list "RA" [expr [mc_angle2deg [lindex  [buf1 getkwd "RA"] 1] ] * 15.] "double" "ra" "deg"]
         buf1 setkwd [list "DEC" [mc_angle2deg [lindex  [buf1 getkwd "DEC"] 1] 90] "double" "dec" "deg"]

         buf1 setkwd [list "FOCLEN" 7.973 "double" "Focal length" ""]

         if {[lindex  [buf1 getkwd "NAXIS1"] 1]==1} {buf1 setkwd [list "PIXSIZE1" 13.5 "double" "pixel size" "mum"]}
         if {[lindex  [buf1 getkwd "NAXIS1"] 2]==1} {buf1 setkwd [list "PIXSIZE1" 27   "double" "pixel size" "mum"]}
         if {[lindex  [buf1 getkwd "NAXIS1"] 3]==1} {buf1 setkwd [list "PIXSIZE1" 40.5 "double" "pixel size" "mum"]}
         if {[lindex  [buf1 getkwd "NAXIS1"] 4]==1} {buf1 setkwd [list "PIXSIZE1" 54   "double" "pixel size" "mum"]}
         if {[lindex  [buf1 getkwd "NAXIS2"] 1]==1} {buf1 setkwd [list "PIXSIZE2" 13.5 "double" "pixel size" "mum"]}
         if {[lindex  [buf1 getkwd "NAXIS2"] 2]==1} {buf1 setkwd [list "PIXSIZE2" 27   "double" "pixel size" "mum"]}
         if {[lindex  [buf1 getkwd "NAXIS2"] 3]==1} {buf1 setkwd [list "PIXSIZE2" 40.5 "double" "pixel size" "mum"]}
         if {[lindex  [buf1 getkwd "NAXIS2"] 4]==1} {buf1 setkwd [list "PIXSIZE2" 54   "double" "pixel size" "mum"]}

         ::bddimagesAdmin::bdi_setcompat 1
         buf1 setkwd [list "BDDIMAGES STATE" "RAW" "string" "RAW | CORR | CATA | ?" ""]
         buf1 setkwd [list "BDDIMAGES TYPE"  $key "string" "IMG | FLAT | DARK | OFFSET | ?" ""]

         # sauve l image
         set f [file tail $fichier]
         set f [string range $f 0 [expr [string last .fits $f] -1]]
         set newfile [file join $dest "${f}_CHK.fits"]
         #::console::affiche_resultat "sauve image : $newfile\n"
         saveima $newfile

         # take a look
         #set lh [buf1 getkwds]
         #::console::affiche_resultat "$lh\n"
      }

      return
   }


