#
## @file sn_tarot_http.tcl
#  @brief Procédures pour la connexion à des sites http
#  @author Alain KLOTZ et Raymond ZACHANTKE
#  $Id: sn_tarot_http.tcl 12865 2016-01-24 13:59:07Z rzachantke $
#  @code source $audace(rep_install)/gui/audace/plugin/tool/sn_tarot/sn_tarot_http.tcl
#  @endcode

#--------------proc lancees par sn_tarot_go.tcl -------------

#------------------------------------------------------------
## @brief télécharge et vérifie un fichier zip
#  @param url0  url jusqu'au denier /
#  @param param ce qui suit le dernier / (nom du fichier zip)
#  @param file  nom complet sous lequel il faut enregistrer le fichier
#  @return 1
#
proc ::sn_tarot::downloadFile { url0 param file } {
   global panneau caption

   if { [catch { set tok [ ::http::geturl ${url0}$param ] } ErrInfo ] } {
      tk_messageBox -icon info -type ok \
         -message [ format $caption(sn_tarot_go,url_error) $url0 ]
      return 0
   }

   upvar #0 $tok state

  if { [ ::http::status $tok ] != "ok" } {
      #error "pb download"
      return 0
   }

   #--   verifie le contenu
   set key [ string range [ ::http::data $tok ] 0 4 ]

   if { $key == "<?xml" } {
      tk_messageBox -icon info -type ok \
         -message [ format $caption(sn_tarot_go,file_error) $param ]
      return 0
   }

   #--   nettoie l'ancien fichier
   if { [ file exists $file ] } {
      file delete $file
   }

   #--   enregistre le fichier vers le dossier
   set f [ open $file w ]
   fconfigure $f -translation binary
   puts -nonewline $f [ ::http::data $tok ]
   close $f
   ::http::cleanup $tok

   return 1
}

#------------------------------------------------------------
## @brief copie un fichier
#  @param prefix
#  @param url
#  @return code erreur et liste des 100 dates les plus récentes
#
proc ::sn_tarot::httpcopy { prefix url } {

   set error 0

   if { [ catch {set tok [ ::http::geturl $url ] } ErrInfo ] } {
      set error 1
      return [ list $error "" ]
   }

   upvar #0 $tok state

   if {[ ::http::status $tok ] != "ok"} {
      set error 1
      return [ list $error "" ]
   }

   #--   verifie le contenu
   if { [ string range [::http::data $tok ] 0 4 ] == "<?xml" } {
      set error 1
      return [ list $error "" ]
   }

   set lignes [ ::http::data $tok ]
   ::http::cleanup $tok

   regsub -all \" $lignes "" lignes
   set index [ llength $lignes ]
   set list_zip ""
   while { [ llength $list_zip ] != 100 && $index >=0 } {
      incr index -1
      #--   recherche l'existence du pattern
      regexp "${prefix}_(\[0-9\]\{8\})\.zip" [ lindex $lignes $index ] match date
      if { [ info exists date ] } {
         lappend list_zip $date
         unset date
      }
   }

   return [ list $error $list_zip ]
}

#--------  gestion des requetes DSS aupres de Skyview -------

#------------------------------------------------------------
## @brief formate et gère les requêtes des images DSS manquantes
#  @param files_to_load liste du nom des galaxies (sans extension)
#
proc ::sn_tarot::listRequest { files_to_load } {
   global caption rep snvisu

   set snvisu(dss) 1
   set ext $::conf(extension,defaut)
   set n 0
   set len [ llength $files_to_load ]

   #set url "http://skyview.gsfc.nasa.gov/cgi-bin/runquery.pl"
   set url "http://skyview.gsfc.nasa.gov/current/cgi/runquery.pl"
   set sentence  "Position=%s,%s&Size=%s,%s&Pixels=%s,%s&Rotation=%s&Survey=DSS&Scaling=Linear&Projection=Tan&Coordinates=J2000&Return=FITS"
   #  Size=size[,size] - The size[s] of the image in degrees.  If only one value is given the image is square.
   #  Pixels=n[,m] - The number of pixels in the image. If only one value is given the height and width are the same.
   #  brightness Scaling (Log, Linear, Sqrt, HistEq)
   #  map Projection (Tan, Sin, Car, Ait, Zea, Csc)
   #  Rotation (degres)
   #  pixel Resampling : Nearest Neighbor (NN), Bi-Linear (LI), Lanczos3, Spline3, Clip (Flux conserving), Clip (Intensive)
   #  Grid overlay : No grid, Coordinates same as image, J2000, B1950, Galatic, I2000, ICRS
   #  Plot color : e.g. green black, white
   #  Return {fits jpeg gif}

   set todestroy [ ::sn_tarot::createProgressBar ]

   foreach name $files_to_load {

      if {![catch { set kwds_list [ fitsheader [ file join $rep(name1) $name$ext ] ] } ] } {

         #--   extrait les valeurs des mots cles
         foreach kwd [ list CROTA2 CDELT1 CDELT2 CRPIX1 CRPIX2 CRVAL1 CRVAL2 FOCLEN NAXIS1 NAXIS2 ] {
            set index [ lsearch -index 0 -regexp -exact $kwds_list "$kwd" ]
            set [ string tolower $kwd ] [ lindex $kwds_list [ list $index 1 ] ]
         }

         lassign [ ::sn_tarot::getImgCenterRaDec $naxis1 $naxis2 $crota2 $cdelt1 $cdelt2 $crpix1 $crpix2 $crval1 $crval2 ] ra dec fov_x fov_y

         #--   formate la requete
         set query [ format $sentence $ra $dec $fov_x $fov_y $naxis1 $naxis2 $crota2 ]
         #::console::affiche_resultat "query=$query\n"

         #--   initialisation
         lassign [ list 0 "" ]  ok reason

         set snvisu(start_load) [ format $caption(sn_tarot,dss_galaxy) $name$ext ]

         #--   traitement des erreurs
         #console::affiche_resultat "$url $query\n"
         lassign [ ::sn_tarot::loadDSS "$url" "$query" $name ] ok reason
         if { $reason eq "" } {
            incr n
            set snvisu(progress) [ expr { $n*100./$len } ]
            update
         } else {
            switch -exact $reason {
               url_error   {set msg [ format $caption(sn_tarot_go,url_error) $url ]}
               default     {set msg [ format $caption(sn_tarot,dss_not_found) $name$ext $reason ]}
            }
            ::console::affiche_resultat "$msg\n"
            if {$reason eq "url_error"} {
               destroy $todestroy
            }
         }
      }
   }

   destroy $todestroy
   set snvisu(dss) 0
   unset snvisu(start_load)
}

#------------------------------------------------------------
## @brief télécharge les images DSS
#  @param url url
#  @param query requête formatée
#  @param name nom de la galaxie
#  @return code erreur
#
proc ::sn_tarot::loadDSS { url query name } {
   global rep

   set ok 0

   if { [catch { set tok [ ::http::geturl "$url" -query "$query" ] } ErrInfo ] } {
      return [ list $ok url_error ]
   }

   upvar #0 $tok state

   if { [ ::http::status $tok ] != "ok" } {
      set reason "pb download"
      return [ list $ok $reason ]
   }

   #--   verifie le contenu
   set key [ string range [ ::http::data $tok ] 0 4 ]

   if { $key == "<html" || $key == "<xmls" } {
      #--   identifie le motif de l'echec
      set texte [ lindex [ array get state body ] 1 ]
      set index [ string first "Reason:" $texte ]
      set texte [ string range $texte $index end ]
      set index [ string first < $texte ]
      incr index -1
      set reason [ string range $texte 8 $index ]
      return [ list $ok $reason ]
   }

   foreach { meta_name value } $state(meta) {
      if {[regexp -nocase ^content-disposition$ $meta_name]} {
         # Recherche l'ID de l'image attachee
         regsub -nocase -all "attachment; filename=" $value "" html_file
         if { $html_file ne "" } {
            set ok 1
            #::console::affiche_resultat "$name attachment=$html_file $ok\n"
         }
      }
   }

  if { $ok == 1 } {
      #--   sauve l'image dans le repertoire dss
      set filename [ file join $rep(name3) $name.fit ]
      if { [ file exists $filename ] == 1 } { file delete $filename }
      set f [ open $filename w ]
      fconfigure $f -translation binary
      puts -nonewline $f [ ::http::data $tok ]
      close $f
   }

   ::http::cleanup $tok
   return $ok
}

