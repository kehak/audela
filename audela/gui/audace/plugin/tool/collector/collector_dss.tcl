#
## @file collector_dss.tcl
#  @brief Gère les téléchargements auprès de SkyView
#  @author Raymond Zachantke
#  $Id: collector_dss.tcl 14409 2018-04-12 21:13:45Z robertdelmas $
#

   #--   Liste des proc de la gestion des requetes DSS aupres de SkyView
   # nom proc                             utilisee par
   # ::collector::cmdApplyRequestSkyView  Commande du bouton 'Image DSS'
   # ::collector::loadDSS                 requestSkyView
   # ::collector::updateDSSData           requestSkyView
   # ::collector::extractDataFromComment  updateDSSData

   #------------------------------------------------------------
   ## @brief commande du bouton 'Image DSS'
   #
   #         formate et gère la requête aupres de SkyView
   #         l'en-tête de l'image calibrée sera complétée
   #  @param filename nom complet de l'image
   #  @param visuNo numéro de la visu
   #
   proc ::collector::cmdApplyRequestSkyView { filename {visuNo 1} } {
      variable This
      variable private
      global caption

      #--   change le bouton 'Image DSS'
      $This.cmd.dss configure -text $caption(collector,loading)

      #--   inhibe les boutons
      ::collector::configButtons disabled
      update

      #--   efface l'image existante
      if {[buf[visu$visuNo buf] imageready]} {visu$visuNo clear}

      set url "http://stdatu.stsci.edu/cgi-bin/dss_search/"

      set catal quickv

      #--   collecte les infos de la requete
      foreach var [list crval1 crval2 fov1 fov2 naxis1 naxis2 crota2] {
         set $var $private($var)
      }

      #--   limite la taille et le temps de telechargement, sans modification de FOV
      if {$naxis1 > 15} {
         set naxis2 [expr { int($naxis2 * 15. / $naxis1 ) } ]
         set naxis1 15
      }

      #--   formate la requete
      #--- set query [::http::formatQuery v poss2ukstu_red r 00+31+45.00 d -05+09+11.0 e J2000 h 15.0 w 15.0 f fits c none fov NONE v3 ""]
      set query [::http::formatQuery v $catal r $crval1 d $crval2 e J2000 h $naxis2 w $naxis1 f fits c none fov NONE v3 ""]

      #--   initialisation
      lassign [list 0 ""] ok reason

      #--   traitement des erreurs
      lassign [::collector::loadDSS "$url" "$query" "$filename"] ok reason

      if {$reason eq ""} {
         loadima $filename
         #::collector::updateDSSData $visuNo [list $crval1 $crval2 $naxis1 $naxis2 $crota2]
      } else {
        switch -exact $reason {
            urlError {set msg [format $caption(collector,urlError) $url]}
            default  {set msg [format $caption(collector,dssNotFound) $filename $reason]}
         }
         ::console::affiche_erreur "$msg\n"
      }

      #--   change le bouton 'Image DSS'
      $This.cmd.dss configure -text $caption(collector,dss)

      #--   desinhibe les boutons
      ::collector::configButtons !disabled
      update
   }

   #------------------------------------------------------------
   #  brief          télécharge l'image
   #  param url      adresse http
   #  param query    requête formatée
   #  param filename nom complet de l'image
   #  param chunk    4096 par défaut
   #
   proc ::collector::loadDSS { url query filename {chunk 4096} } {

      set ok 0

      if { [catch {set tok [::http::geturl $url -query $query -blocksize $chunk]} ErrInfo]} {
         return [ list $ok urlError ]
      }

      if {[::http::status $tok] != "ok"} {
         set reason "No access at URL $url."
         return [list $ok $reason]
      }

      set html [::http::data $tok]
      #--   verifie le contenu
      if {[regexp -nocase ^Error$ $html] eq "0"} {
         set ok 1

         #--   sauve la nouvelle image
         catch {
            set f [open $filename w]
            fconfigure $f -translation binary
            puts -nonewline $f $html
         close $f
         }

      } else {
         #--   debug
         #catch {K [puts [set fi [open [file join $::audace(rep_images) dss.shtml] w]] $tok] [close $fi]}
         set error "Request error"
         return [list $ok $reason]
      }

      ::http::cleanup $tok

      return $ok
   }

   #------------------------------------------------------------
   #  brief met à jour collector avec les valeurs de l'en-tete FITS de l'image
   #  param visuNo numéro de la visu
   #  param data
   #
   proc ::collector::updateDSSData { visuNo data } {
      variable private
      global audace

      set ext $::conf(extension,defaut)
      lassign $data crval1 crval2 naxis1 naxis2 crota2

      #--   Rem : respecter l'ordre
      #--   actualise la taille des pixels (NAXIS réduit avec FOV (constant) de l'image
      set private(photocell1) [expr { $private(photocell1) * $private(naxis1) / $naxis1 }]
      set private(pixsize1) $private(photocell1)
      set private(photocell2) [expr { $private(photocell2) * $private(naxis2) / $naxis2 }]
      set private(pixsize2) $private(photocell2)

      #--   actualise l'affichage des naxis (susceptibles d'etre modifies)
      set private(naxis1) $naxis1
      set private(naxis2) $naxis2

      #--   actualise private(cdelt) en arcsec
      set private(cdelt1) [expr { [lindex [buf[visu$visuNo buf] getkwd CDELT1] 1] * 3600 }]
      set private(cdelt2) [expr { [lindex [buf[visu$visuNo buf] getkwd CDELT2] 1] * 3600 }]

      #-- complete l'en-tete FITS
      set bufNo [visu$visuNo buf]
      buf$bufNo delkwd RADESYS
      foreach {kwd val} [list \
         CROTA2 $private(crota2) \
         PIXSIZE1 $private(pixsize1) \
         PIXSIZE2 $private(pixsize2) \
         EQUINOX J2000.0 \
         RADECSYS FK5 \
         DEC "$private(dec)" \
         RA "$private(ra)" ] {
         buf$bufNo setkwd [format [formatKeyword $kwd] $val]
      }

      ::collector::calibrationAstro $bufNo $ext $private(catAcc) $private(catname)
      saveima [file join $::audace(rep_images) dss$ext]
      #::collector::extractDataFromComment $bufNo

      #--   il faut recharger l'image pour que le changement de coordonnees opere
      loadima [file join $::audace(rep_images) dss$ext]
   }

   #------------------------------------------------------------
   #  brief met à jour les variables correspondantes si le mot clé COMMENT contient le nom et les caractéristiques du télescope
   #  param bufNo numéro du buffer contenant l'image DSS
   #
   proc ::collector::extractDataFromComment { bufNo } {

      #--   extrait le nom du telescope
      set comment [buf$bufNo getkwd COMMENT]

      if {[lindex $comment 1] ne ""} {
         set comment [string map [list "\}" "" "\{" "" "COMMENT" "" string "" "*" ""] $comment]
         regexp -all {.+(TELESCOP=[[:space:]]\'.+\').+(TELESCOP=[[:space:]]\'.+\').+} $comment match south north
         if {[string index $private(dec) 0] eq "+"} {
            set result $north
        } else {
            set result $south
         }
         set k [string first "'" $result]
         set result [string range $result [incr k] end]
         set k [string first "'" $result]
         set private(telescop) [string range $result 0 [incr k -1]]

         #--   calcule les parametres optiques
         switch -exact $private(telescop) {
            "Palomar 48-inch Schmidt"  {  set aptdia 1.2
                                          set fond 2.5
                                          set foclen [expr {$fond*$aptdia}]
                                       }
            "UK Schmidt (new optics)"  {  set aptdia 1.2
                                          set foclen 3.07
                                       }
         }
         set private(aptdia) $aptdia
         set private(foclen) $foclen
         buf$bufNo setkwd [list APTDIA "$private(aptdia)" float Diameter m]
         buf$bufNo setkwd [list FOCLEN "$private(foclen)" float {Resulting Focal length} m]

        lassign [::collector::getFonDResolution $aptdia $foclen] private(fond) private(resolution)
      }
   }

