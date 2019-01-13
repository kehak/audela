#
## @file catalogexplorer_vizier.tcl
#  @brief Interrogation de VizieR pour catalogexplorer
#  @author Raymond Zachantke
#  $Id: catalogexplorer_vizier.tcl 14133 2016-11-10 11:30:28Z rzachantke $


#------------------------------------------------------------
#  brief   exploite le catalogue B/wds retourné par le service VizieR
#
#          paramètre : widget(catalogexplorer,data) ;
#          sortie : widget(catalogexplorer,stars) et widget(catalogexplorer,magList)
#
proc ::catalogexplorer::readB/wds { } {
   variable widget
   variable myMatrix

   set starList {}
   set magList {}
   lassign [lrange $widget(catalogexplorer,data) 2 end] \
      naxis1 naxis2 crval1 crval2 mag_bright mag_faint radius_arcmin field

   set indexes [::catalogexplorer::httpGetVizieR [list $crval1 $crval2] $radius_arcmin "B/wds" $mag_bright $mag_faint]

   if {$indexes ne ""} {

      foreach index $indexes {

         lassign [myMatrix get row $index] ra dec name mag1 mag2 SpType
         lassign $ra rah ramin rasec
         lassign $dec decdeg decmin decsec
         set ra [mc_angle2deg ${rah}h${ramin}m${rasec}s]
         set dec [mc_angle2deg ${decdeg}d${decmin}m${decsec}s 90]
         set mag1 [string trim $mag1]
         set mag2 [string trim [lindex $mag2 0]]
         set msg [list [string trimright $name] mag1=$mag1 mag2=$mag2]
         set SpType [string trimright $SpType]
         if {$SpType ne ""} {
            lappend msg "type=$SpType"
         }
         set mag [lmin [list $mag1 $mag2]]

         lassign [mc_radec2xy $ra $dec $field] x y
         set y [expr { $naxis2-$y }]

         #--   Filtre les valeurs hors champ ou non conformes et fixe la magnitude
         if {$x >=1 && $x <= $naxis1 && $y >= 1 && $y <= $naxis2 && $mag >= $mag_bright && $mag <= $mag_faint} {
            set y [format "%0.1f" $y]
            set x [format "%0.1f" $x]
            set ra [mc_angle2hms $ra 360 zero 0 auto string]
            set dec [mc_angle2dms $dec 90 zero 0 + string]
            set msg [linsert $msg 0 $ra $dec]
            lappend magList $mag
            lappend starList [list $x $y $mag $msg]
         }
      }
   }

   set widget(catalogexplorer,stars) $starList
   set widget(catalogexplorer,magList) $magList

   catch { myMatrix destroy }
}

#------------------------------------------------------------
#  brief   exploite le catalogue I/280B retourné par le service VizieR
#
#          paramètre : widget(catalogexplorer,data) ;
#          sortie : widget(catalogexplorer,stars) et widget(catalogexplorer,magList)
#
proc ::catalogexplorer::readI/280B { } {
   variable widget
   variable myMatrix

   set starList {}
   set magList {}
   lassign [lrange $widget(catalogexplorer,data) 2 end] \
      naxis1 naxis2 crval1 crval2 mag_bright mag_faint radius_arcmin field

   set indexes [::catalogexplorer::httpGetVizieR [list $crval1 $crval2] $radius_arcmin "I/280B" $mag_bright $mag_faint]

   if {$indexes ne ""} {

      foreach index $indexes {
         set msg ""
         set lmags ""
         lassign [myMatrix get row $index] ra dec magB magV magJ magH magK SpType
         foreach c [list B V J H K] {
            set val [string trim [lindex [set mag$c] 0]]
            if {$val ne ""} {
               set mag$c [string trim $val]
               lappend msg "${c}=$val"
               lappend lmags $val
            }
         }
         set SpType [string trimright $SpType]
         if {$SpType ne ""} {
            lappend msg "type=$SpType"
         }
         set mag [lmin $lmags]

         lassign [mc_radec2xy $ra $dec $field] x y
         set y [expr { $naxis2-$y }]

         #--   Filtre les valeurs hors champ ou non conformes et fixe la magnitude
         if {$x >=1 && $x <= $naxis1 && $y >= 1 && $y <= $naxis2 && $mag >= $mag_bright && $mag <= $mag_faint} {
            set y [format "%0.1f" $y]
            set x [format "%0.1f" $x]
            set ra [mc_angle2hms $ra 360 zero 0 auto string]
            set dec [mc_angle2dms $dec 90 zero 0 + string]
            set msg [linsert $msg 0 $ra $dec]
            lappend magList $mag
            lappend starList [list $x $y $mag $msg]
         }
      }
   }

   set widget(catalogexplorer,stars) $starList
   set widget(catalogexplorer,magList) $magList

   catch { myMatrix destroy }
}

#------------------------------------------------------------
#  brief   exploite un catalogue retourné par le service VizieR
#
#          transforme les données en matrice ; filtre les magnitudes
#  param   coords        liste de coordonnées, en angle
#  param   radius_arcmin rayon en arcmin
#  param   catalog       nom du catalogue
#  param   mag_bright    magnitude la plus brillante (basse)
#  param   mag_faint     magnitude la moins brillante (諥v裩
#  return  listes des indices de lignes �nalyser
#
proc ::catalogexplorer::httpGetVizieR { coords radius_arcmin catalog mag_bright mag_faint } {
   variable myMatrix

   package require http

   set indexes ""
   set result ""
   set chunk 4096
   set output "csv"

   #--  -oc.form=d   decimal degrees
   #--  -oc.form=s   sexagesimal
   #--  -c    center
   #--  -c.r  radius in deg
   #--  -c.rd radius in degrees
   #--  -c.rm radius in arcmin
   #--  -c.rs radius in arcsec
   #--  -c.bm box    in arcmin  ; # 8x6
   #--  -c.bd box    in degrees
   #--  -c.bs box    in arcsec

   # Empirisme : 1 s par minute d'arc
   set attente_max [expr { int($radius_arcmin*1000) }]

   if {$catalog eq "Loneos" } {
      set request [ ::http::formatQuery "-source" "$catalog" "-c" $coords "-c.rm" "$radius_arcmin" "-mime" "csv" "-oc.form" "D." "-out" "RAJ2000"  "-out" "DEJ2000" "-out" "Name" "-out" "Vmag" "-out" "B-V" "-out" "U-B" "-out" "V-R" "-out" "V-I"]
   } elseif {$catalog eq "B/wds" } {
      set request [ ::http::formatQuery "-source" "$catalog" "-c" $coords "-c.rm" "$radius_arcmin" "-mime" "csv" "-oc.form" "D." "-out" "RAJ2000"  "-out" "DEJ2000" "-out" "WDS" "-out" "mag1" "-out" "mag2" "-out" "SpType" ]
   } elseif {$catalog eq "I/280B" } {
      set request [ ::http::formatQuery "-source" "$catalog" "-c" $coords "-c.rm" "$radius_arcmin" "-mime" "csv" "-oc.form" "D." "-out" "RAJ2000" "-out" "DEJ2000" "-out" "Bmag" "-out" "Vmag" "-out" "Jmag" "-out" "Hmag" "-out" "Kmag" "-out" "SpType" ]
   }

   #--   debug
   #::console::disp "request $request\n\n"

   set vizier_url "http://vizier.u-strasbg.fr/viz-bin/asu-tsv"
   set token [::http::geturl $vizier_url -query $request -blocksize $chunk -timeout $attente_max]

   upvar #0 $token state

   if {[::http::status $token] eq "ok"} {

      set texte  [split $state(body) "\n"]
      set len [llength $texte]
      #--   debug
      #::console::disp "$texte\n"

      #--   Cherche l'index de la ligne commencant par un pattern
      set pattern "#Column"
      for {set line 0} {$line < $len} {incr line} {
         if {[regexp -all $pattern [lindex $texte $line]] eq "1"} {
            break
         }
      }

      #--   Saute les lignes de definition
      switch -exact $catalog {
         "I/280B" { incr line 11 }
         "B/wds"  { incr line 9 }
         "Loneos" { incr line 11 }
      }

      #--   Extrait le texte contenant les donnees, sans ligne vide
      regsub -all {\{\}} [lrange $texte $line end] "" result

      #--   Definit le nombre de colonnes et de lignes
      set nbRow [llength $result]
      set nbCol [llength [split [lindex $result 0] ";"]]

      #--   debug
      #::console::disp "nbRow $nbRow nbCol $nbCol\n"

      if {$nbRow > 0} {

         #--   Cree une matrice
         catch { myMatrix destroy }
         catch { struct::matrix myMatrix }

         #--   Cree le nombre de colonnes
         myMatrix add columns $nbCol

         #--   Remplit la matrice
         for {set k 0} {$k < $nbRow} {incr k} {
            myMatrix add row  [split [lindex $result $k] ";"]
         }

         ::blt::vector create Vmagnitude -watchunset 1
         #--   readLoneos : col3 = VMag
         #--   readB/wds  : col3 = Mag1
         #--   readI/280B : col3 = VMag
         foreach m [myMatrix get column 3] {
            #--   Elimine les { } autour de certaines valeurs
            Vmagnitude append [string trim [lindex $m 0] ]
         }
         #--   Filtre les lignes avec une magnitude correcte
         set indexes [Vmagnitude search $mag_bright $mag_faint]
         ::blt::vector destroy Vmagnitude

      }

   } else {
      ::console::affiche_erreur "Erreur : pb download.\n"
   }

   ::http::cleanup $token

   return $indexes
}

