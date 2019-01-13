## @file vo_tools.tcl
# @brief Outil pour l'Observatoire Virtuel
# @author A. Klotz, J. Berthier et F. Vachier
# @version 1.0
# @par Ressource
# @code source [file join $audace(rep_install) gui audace vo_tools.tcl]
# @endcode

# $Id: vo_tools.tcl 14545 2018-12-03 15:56:02Z fredvachier $


## @brief Lancement du logiciel Aladin depuis Audace
# @author A. Klotz
# @param args {load|object ?parameters?}
# @pre Requiert le langage java et le logiciel externe Aladin
# @par Exemple :
# @code
#   vo_aladin load m57 USNO-B1
#   vo_aladin load m57 { USNO-B1 DSS2 }
# @endcode
#
proc vo_aladin { args } {
   global audace
   global conf

   set argc [llength $args]
   if {$argc == 0} {
      error "Usage: method ?options?"
      return
   }

   set method [lindex $args 0]

   # --- Aladin
   set exec_java $conf(exec_java)
   if {$exec_java==""} {
      set exec_java java
   }
   set exec_aladin $conf(exec_aladin)
   set aladin_jar $conf(exec_aladin)
   if {($exec_aladin=="")||([file exists $exec_aladin]==0)} {
      if { $::tcl_platform(os) == "Linux" } {
         set exec_aladin $audace(rep_install)/bin/Aladin
      } elseif { $::tcl_platform(os) == "Darwin" } {
         set exec_aladin $audace(rep_install)/bin/Aladin
      } else {
         set exec_aladin $audace(rep_install)/bin/Aladin.exe
      }
   }
   if {($aladin_jar=="")||([file exists $aladin_jar]==0)} {
      set aladin_jar $audace(rep_install)/bin/Aladin.jar
   }

   if {$method=="load"} {
      # vo_aladin load j1 {USNO-B DSS2}
      if {$argc <= 1} {
         error "Usage: $method filename ?{catalogs}"
         return
      }

      set texte "#AJS\n"
      append texte "#Aladin Java Script created by AudeLA\n"

      set fname [lindex $args 1]
      set ftail [file tail $fname]
      set fdirname [file dirname $fname]
      set fextension [file extension $ftail]
      if {($fdirname=="")||($fdirname==".")} {
         set fdirname $audace(rep_images)
      }
      if {$fextension==""} {
         set fextension $conf(extension,defaut)
      }
      set fname [file join $fdirname ${ftail}${fextension}]
      append texte "load $fname \n"

      set catalogs [lindex $args 2]
      if {[llength $catalogs]>0} {
         buf$audace(bufNo) load "$fname"
         set naxis1 [lindex [buf$audace(bufNo) getkwd NAXIS1] 1]
         set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
         set res [buf$audace(bufNo) xy2radec [list [expr $naxis1/2] [expr $naxis2/2]] ]
         set ra [mc_angle2hms [lindex $res 0]]
         set dec [mc_angle2dms [lindex $res 1] 90]
         set coords "$ra $dec"
         set cdelt1 [lindex [buf$audace(bufNo) getkwd CDELT1] 1]
         set cdelt2 [lindex [buf$audace(bufNo) getkwd CDELT2] 1]
         set fieldx [expr $cdelt1*$naxis1*60.]
         set fieldy [expr $cdelt2*$naxis2*60.]
         if {$fieldx>$fieldy} {
            set fieldarcmin $fieldx
         } else {
            set fieldarcmin $fieldy
         }
         foreach catalog $catalogs {
            if {$catalog=="USNO-B1"} { set catalog Vizier(I/284) }
            if {$catalog=="DSS2"}    { set catalog Aladin(DSS2) }
            if {$catalog=="NOMAD1"} { set catalog Vizier(NOMAD1) }
            append texte "get $catalog $coords ${fieldarcmin}'\n"
         }
      }

      set fnameajs [file join $audace(rep_images) ${ftail}.ajs]
      set f [open "$fnameajs" w]
      puts -nonewline $f $texte
      close $f

      if {[file exists $exec_aladin]==1} {
         open "|\"$exec_aladin\" \"$fnameajs\" " w+
      } elseif {[file exists $aladin_jar]==1} {
         open "|\"$exec_java\" -jar \"$aladin_jar\" < \"$fnameajs\" " w+
      }
   } elseif {$method=="object"} {
      # vo_aladin object uranus {USNO-B DSS2}
      if {$argc <= 1} {
         error "Usage: $method objename ?{catalogs}"
         return
      }
      #
      set texte "#AJS\n"
      append texte "#Aladin Java Script created by AudeLA\n"
      #
      set fname [lindex $args 1]
      set ftail [file tail $fname]
      set fdirname [file dirname $fname]
      set fextension [file extension $ftail]
      #::console::affiche_resultat "fdirname=<$fdirname>\n"
      if {($fdirname=="")||($fdirname==".")} {
         set fdirname $audace(rep_images)
      }
      if {$fextension==""} {
         set fextension $conf(extension,defaut)
      }
      #set fname [file join $fdirname ${ftail}${fextension}]
      append texte "get SkyBot.IMCCE(now,511,\"120 arcsec\") $fname \n"
      #
      set catalogs [lindex $args 2]
      if {[llength $catalogs]>0} {
         foreach catalog $catalogs {
            if {$catalog=="USNO-B1"} { set catalog Vizier(I/284) }
            if {$catalog=="DSS2"}    { set catalog Aladin(DSS2) }
            append texte "get $catalog $coords ${fieldarcmin}'\n"
         }
      }
      #
      set fnameajs [file join $audace(rep_images) ${ftail}.ajs]
      set f [open "$fnameajs" w]
      puts -nonewline $f $texte
      close $f
      #
      if {[file exists $exec_aladin]==1} {
         open "|\"$exec_aladin\" \"$fnameajs\" " w+
      } elseif {[file exists $aladin_jar]==1} {
         open "|\"$exec_java\" -jar \"$aladin_jar\" < \"$fnameajs\" " w+
      }
   } else {
      #--- Exemple : vo_aladin load m57 USNO-B1
      #--- Exemple : vo_aladin load m57 { USNO-B1 DSS2 }
      error "Usage: load|object ?parameters?"
      return
   }
   return $texte
}


## @brief Lancement du logiciel Aladin dans le navigateur depuis Audace
#
# Ce script lance le client Aladin dans le navigateur par defaut
# et affiche l'image [survey] (par defaut DSS2) centree aux coordonnees
# [coord] +/- [radius] plus, eventuellement, les objets reconnus par
# VizieR(catalog)
# @author J. Berthier
# @param args {coord radius ?survey? ?catalog? ?epoch?}
# @par
# avec
# @verbatim
#  coord   : coordonnees du centre du FOV
#  radius  : rayon du FOV en arcmin
#  survey  : nom du survey-image
#  catalog : nom du catalogue d'objets pour la reconnaissance
#  epoch   : date de l'observation
# @endverbatim
# @pre Requiert le langage java et un navigateur Internet
# @par Exemple :
# @code
#   vo_launch_aladin "05 35 17.3 -05 23 28" 10 DSS2 USNO2
# @endcode
# @bug Pb sous Linux/KDE: The KDE libraries are not designed to run with suid privileges. Il faut mettre le user dans le bon groupe.
#
proc vo_launch_aladin { args } {

   set unit "arcmin"
   set url_aladin "http://aladin.u-strasbg.fr/java/nph-aladin.pl?from=Audela"

   set argc [llength $args]
   if {$argc >= 2} {
      regsub -all "\"" [lindex $args 0] "" coord
      set radius [lindex $args 1]
      set survey "DSS2"
      if {$argc >= 3} { set survey [lindex $args 2] }
      set catalog "USNO2"
      if {$argc >= 4} { set catalog [lindex $args 3] }
      set epoch "now"
      if {$argc >= 5} { set epoch [lindex $args 4] }

      #--- construction de l'URL
      set url_args [ concat "&script=get Aladin($survey) $coord $radius$unit;sync;get VizieR($catalog);get SkyBoT.IMCCE($epoch,500,'120 arcsec')" ]
      set goto_url [ concat $url_aladin$url_args ]
      #--- invocation de l'url
      ::audace::Lance_Site_htm $goto_url

   } else {

      error "Usage: vo_launch_aladin coord radius ?survey? ?catalog? ?epoch?"

   }

}


# ------------------------------------------------------------------------------------
# variable     : XML character mapping
# Auteur       : David Gravereaux
# Update       : 21 may 2006
# WARNING! May be incomplete
# ------------------------------------------------------------------------------------
variable entityMap [list & &amp\; < &lt\; > &gt\; \" &quot\;\
        \u0000 &#x0\; \u0001 &#x1\; \u0002 &#x2\; \u0003 &#x3\;\
        \u0004 &#x4\; \u0005 &#x5\; \u0006 &#x6\; \u0007 &#x7\;\
        \u0008 &#x8\; \u000b &#xB\; \u000c &#xC\; \u000d &#xD\;\
        \u000e &#xE\; \u000f &#xF\; \u0010 &#x10\; \u0011 &#x11\;\
        \u0012 &#x12\; \u0013 &#x13\; \u0014 &#x14\; \u0015 &#x15\;\
        \u0016 &#x16\; \u0017 &#x17\; \u0018 &#x18\; \u0019 &#x19\;\
        \u001A &#x1A\; \u001B &#x1B\; \u001C &#x1C\; \u001D &#x1D\;\
        \u001E &#x1E\; \u001F &#x1F\;]


## @brief Encodage des caracteres speciaux
# @param text string entite a encoder
# @return entite encodee
# @author J. Berthier
#
proc vo_entityEncode {text} {
   variable entityMap
   return [string map $entityMap $text]
}


## @brief Generic SkybBoT XML generation procedure to wrap up the method parameters for transport to the server.
# @param procVarName string SOAP methodName
# @param args all the parameters required for the method call
# @return the generated XML data for the RPC call
# @author J. Berthier
#
proc vo_skybotXML {procVarName args} {
   variable skybot_xml
   set procName [lindex [split $procVarName {_}] end]
   foreach {key val} $args {
      set $key [vo_entityEncode $val]
   }
   return [subst $skybot_xml($procName)]
}


## @brief Generic Miriade XML generation procedure to wrap up the method parameters for transport to the server.
# @param procVarName string SOAP methodName
# @param args all the parameters required for the method call
# @return the generated XML data for the RPC call
# @author J. Berthier
#
proc vo_miriadeXML {procVarName args} {
   variable miriade_xml
   set procName [lindex [split $procVarName {_}] end]
   foreach {key val} $args {
      set $key [vo_entityEncode $val]
   }
   return [subst $miriade_xml($procName)]
}


## @brief Appel du Webservice SkyBoT.conesearch fournissant la liste et les coordonnees
#         de tous les corps du systeme solaire contenus dans le FOV a l'epoque et aux
#         coordonnees RA,DEC considerees.
# @author J. Berthier
# @param args {JD RA DEC radius ?mime? ?output? ?observer? ?filter? ?objfilter?}
# @par
# avec
# @verbatim
#   JD        : jour julien de l'epoque consideree
#   RA,DEC    : coordonnees equatoriales J2000.0 du centre du FOV (degres)
#   radius    : rayon du FOV en arcsec
#   mime      : format de la reponse (text | votable | html), par defaut text
#   output    : choix des donnees en sortie (object | basic | all), par defaut basic
#   observer  : code UAI de l'observatoire, par defaut 500 (geocentre), ou code d'une sonde spatiale
#   filter    : filtre sur l'erreur de position, par defaut 0
#   objfilter : masque de filtrage des objets, par defaut 111
# @endverbatim
# @par
# Plus d'info: http://vo.imcce.fr/webservices/skybot/?conesearch
# @par
# Dans la console, une fois la cmde executee, on peut executer:
# @code
#   SOAP::dump -request skybotconesearch
#   SOAP::dump -reply skybotconesearch
# @endcode
# afin de visualiser le texte de la requete et de la reponse SOAP.
# @return resultat de la requete sous la forme d'une liste d'elements contenant les donnees. Le premier element de la liste est le nom des colonnees.
#
proc vo_skybotconesearch { args } {
   global audace
   global conf

   package require SOAP

   set argc [llength $args]
   if {$argc >= 4} {
      # reception des arguments
      set epoch [mc_date2jd [lindex $args 0]]
      set RA [mc_angle2deg [lindex $args 1]]
      set DEC [mc_angle2deg [lindex $args 2] 90]
      set radius [lindex $args 3]
      set mime "text"
      if {$argc >= 5} { set mime [lindex $args 4] }
      set out "basic"
      if {$argc >= 6} { set out [lindex $args 5] }
      set observer "500"
      if {$argc >= 7} { set observer [lindex $args 6] }
      set filter "0"
      if {$argc >= 8} { set filter [lindex $args 7] }
      set objfilter "111"
      if {$argc >= 9} { set objfilter [lindex $args 8] }

      # The XML below is ripped straight from the generated request
      set enveloppe "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<SOAP-ENV:Envelope
    xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"
    xmlns:ns1=\"http://vo.imcce.fr/webservices/skybot\"
    xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"
    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
    xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\"
    SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
  <SOAP-ENV:Header>
    <ns1:clientID><ns1:from>AudeLA</ns1:from><ns1:hostip></ns1:hostip></ns1:clientID>
  </SOAP-ENV:Header>
  <SOAP-ENV:Body>
    <ns1:skybotconesearch>
      <inputArray xsi:type=\"ns1:skybotConeSearchRequest\">
        <epoch xsi:type=\"xsd:string\">${epoch}</epoch>
        <alpha xsi:type=\"xsd:double\">${RA}</alpha>
        <delta xsi:type=\"xsd:double\">${DEC}</delta>
        <radius xsi:type=\"xsd:string\">$radius</radius>
        <mime xsi:type=\"xsd:string\">$mime</mime>
        <output xsi:type=\"xsd:string\">$out</output>
        <observer xsi:type=\"xsd:string\">$observer</observer>
        <filter xsi:type=\"xsd:double\">$filter</filter>
        <objFilter xsi:type=\"xsd:string\">$objfilter</objFilter>
      </inputArray>
    </ns1:skybotconesearch>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>"

      variable skybot_xml
      array set skybot_xml [list skybotconesearch $enveloppe]

      # instance du client soap
      SOAP::create skybotconesearch \
         -uri "http://vo.imcce.fr/webservices/skybot" \
         -proxy "http://vo.imcce.fr/webservices/skybot/skybot.php" \
         -name "skybotconesearch" \
         -wrapProc vo_skybotXML \
         -params { epoch string alpha double delta double radius string mime string output string observer string filter string objfilter string }

      # invocation du web service
      set erreur [ catch { skybotconesearch epoch $epoch RA $RA DEC $DEC radius $radius mime $mime out $out observer $observer filter $filter objfilter $objfilter } response ]

      # recuperation des resultats
      set flag [lindex $response 1]
      set result [lindex $response 5]

      # On traite 3 cas de figure :
      # 1- une erreur s'est produite
      # 2- pas d'erreur mais la liste des corps est vide
      # 3- pas d'erreur et la liste contient au moins un corps
      #
      # Ces trois cas sont traites differemment suivant le type de table demande
      #  - type text : lorsque la liste est vide on renvoit "no"
      #  - type mime : si la liste est vide pas de traitement particulier
      #
      # Valeur de $flag : 0 == liste vide , > 0 sinon
      #
      if { $erreur == 0 } {
         if { $flag > 0 || $mime eq "votable" } {
            return $result
         } else {
            return "no"
         }
      } else {
         if {[set nameofexecutable [file tail [file rootname [info nameofexecutable]]]]=="audela"} {
            tk_messageBox -title "error" -type ok -message [concat "skybotconesearch: error: " $response]
         }
         return "failed"
      }

   } else {

      error "Usage: vo_skybot Epoch RA_J2000 DEC_J2000 Radius(arcsec) ?text|votable|html? ?object|basic|all? Observer Filter(arcsec) objFilter(bitmask e.g. 110)"

   }
}


## @brief Appel du Webservice SkyBoT.resolver de resolution du nom des corps du
#         systeme solaire en leurs coordonnees celestes.
# @author J. Berthier
# @param args {JD name ?mime? ?output? ?observer?}
# @par
# avec
# @verbatim
#   JD        : jour julien de l'epoque consideree
#   name      : nom ou numero ou designation provisoire de l'objet
#   mime      : format de la reponse (text | votable | html), par defaut text
#   output    : choix des donnees en sortie (object | basic | all), par defaut basic
#   observer  : code UAI de l'observatoire, par defaut 500 (geocentre), ou code d'une sonde spatiale
# @endverbatim
# @par
# Plus d'info: http://vo.imcce.fr/webservices/skybot/?resolver
# @par
# Dans la console, une fois la cmde executee, on peut executer:
# @code
#   SOAP::dump -request skybotresolver
#   SOAP::dump -reply skybotresolver
# @endcode
# afin de visualiser le texte de la requete et de la reponse SOAP.
# @return resultat de la requete sous la forme d'une liste d'elements contenant les donnees. Le premier element de la liste est le nom des colonnees.
#
proc vo_skybotresolver { args } {
   global audace
   global conf

   package require SOAP

   set argc [llength $args]
   if {$argc >= 2} {
      # reception des arguments
      set epoch [mc_date2jd [lindex $args 0]]
      set name [lindex $args 1]
      set mime "text"
      if {$argc >= 3} { set mime [lindex $args 2] }
      set output "basic"
      if {$argc >= 4} { set output [lindex $args 3] }
      set observer "500"
      if {$argc >= 5} { set observer [lindex $args 4] }

      # The XML below is ripped straight from the generated request
      set enveloppe "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<SOAP-ENV:Envelope
    xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"
    xmlns:ns1=\"http://vo.imcce.fr/webservices/skybot\"
    xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"
    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
    xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\"
    SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
  <SOAP-ENV:Header>
    <ns1:clientID><ns1:from>AudeLA</ns1:from><ns1:hostip></ns1:hostip></ns1:clientID>
  </SOAP-ENV:Header>
  <SOAP-ENV:Body>
    <ns1:skybotresolver>
      <inputArray xsi:type=\"ns1:skybotResolverRequest\">
        <epoch xsi:type=\"xsd:string\">$epoch</epoch>
        <name xsi:type=\"xsd:string\">$name</name>
        <mime xsi:type=\"xsd:string\">$mime</mime>
        <output xsi:type=\"xsd:string\">$output</output>
        <observer xsi:type=\"xsd:string\">$observer</observer>
      </inputArray>
    </ns1:skybotresolver>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>"

      variable skybot_xml
      array set skybot_xml [list skybotresolver $enveloppe]

      # instance du client soap
      SOAP::create skybotresolver \
         -uri "http://vo.imcce.fr/webservices/skybot" \
         -proxy "http://vo.imcce.fr/webservices/skybot/skybot.php" \
         -name "skybotresolver" \
         -wrapProc vo_skybotXML \
         -params { epoch string name string mime string output string observer string }

      # invocation du web service
      set erreur [ catch { skybotresolver epoch $epoch name $name mime $mime output $output observer $observer } response ]

      # recuperation des resultats
      set flag [lindex $response 1]
      set result [lindex $response 5]

      # retour du resultat et gestion des cas d'erreur
      if { $erreur == "0" && $flag >= 1 } {
         return $result
      } else {
         if { $erreur == "0" && $flag == 0 } {
            return "no"
         } else {
            if {[set nameofexecutable [file tail [file rootname [info nameofexecutable]]]]=="audela"} {
               tk_messageBox -title "error" -type ok -message [concat "skybotresolver: error: " $response]
            }
            return "failed"
         }
      }

   } else {

      error "Usage: vo_skybotresolver Epoch Name ?text|votable|html? ?object|basic|all? Observer"

   }
}


## @brief Appel du Webservice SkyBoT.status fournissant le statut de la base de donnees SkyBoT
# @author J. Berthier
# @param args {JD name ?mime? ?output? ?observer?}
# @par
# avec
# @verbatim
#   mime  : format de la reponse (text | votable | html), par defaut text
#   epoch : epoque consideree au format JD ou ISO
# @endverbatim
# @par
# Plus d'info: http://vo.imcce.fr/webservices/skybot/?status
# @par
# Dans la console, une fois la cmde executee, on peut executer:
# @code
#   SOAP::dump -request skybotstatus
#   SOAP::dump -reply skybotstatus
# @endcode
# afin de visualiser le texte de la requete et de la reponse SOAP.
# @return resultat de la requete sous la forme d'une liste contenant : l'etat de la base (1 colonne),
# les dates de debut et de fin de la periode couverte par la base (2 colonnes), le nombre de corps dans
# la base pour les asteroides, les planetes, les satellites naturels et les cometes (4 colonnes) et
# la date de la derniere mise a jour.
#
proc vo_skybotstatus { args } {
   global audace
   global conf

   package require SOAP

   set argc [llength $args]
   if {$argc >= 0} {
      # reception des arguments
      set mime "text"
      if {$argc >= 1} { set mime [lindex $args 0] }
      set epoch ""
      if {$argc >= 2} { set epoch [lindex $args 1] }
      set epoch [regsub {T} $epoch " "]
      set epoch [regsub {\..*} $epoch ""]

      # The XML below is ripped straight from the generated request
      set enveloppe "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<SOAP-ENV:Envelope
   xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"
   xmlns:ns1=\"http://vo.imcce.fr/webservices/skybot\"
   xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"
   xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
   xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\"
   SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
 <SOAP-ENV:Header>
  <ns1:clientID><ns1:from>AudeLA</ns1:from><ns1:hostip></ns1:hostip></ns1:clientID>
 </SOAP-ENV:Header>
 <SOAP-ENV:Body>
  <ns1:skybotstatus>
   <mime xsi:type=\"xsd:string\">$mime</mime>
   <epoch xsi:type=\"xsd:dateTime\">$epoch</epoch>
  </ns1:skybotstatus>
 </SOAP-ENV:Body>
</SOAP-ENV:Envelope>"

      variable skybot_xml
      array set skybot_xml [list skybotstatus $enveloppe]

      # instance du client soap
      SOAP::create skybotstatus \
         -uri "http://vo.imcce.fr/webservices/skybot" \
         -proxy "http://vo.imcce.fr/webservices/skybot/skybot.php" \
         -name "skybotstatus" \
         -wrapProc vo_skybotXML \
         -params { "mime" "string" "epoch" "string" }

      # invocation du web service
      set erreur [ catch { skybotstatus mime $mime epoch $epoch } response ]

      # cas ou le serveur repond avec une erreur
#TODO
      if {[string range $response 0 11] == "SKYBOTStatus"} {
         set erreur 99
      }

      # construction de la reponse
      if {$erreur == "0"}  {
         return $response
      } else {
         if {[set nameofexecutable [file tail [file rootname [info nameofexecutable]]]]=="audela"} {
            tk_messageBox -title "error" -type ok -message [concat "skybotstatus: error: " $response]
         }
         if {$erreur == "99"} {
            return "error"
         } else {
            return "failed"
         }
      }

   } else {

      error "Usage: vo_skybotstatus ?text|votable|html? ?epoch?"

   }
}


## @brief Appel du Webservice SESAME (CDS) pour resoudre les noms des corps
#         celestes (hors objets du systeme solaire) reconnus de Simbad
# @author J. Berthier
# @param args {name ?resultType? ?server?}
# @par
# avec
# @verbatim
#   name       : nom du corps celeste (e.g. IC434)
#   resultType : u | H | x ? [p | i]
#   server     : source du serveur de donnees: CDS | ADAC | ADS | CADC
# @endverbatim
# @par
# Plus d'info: http://cdsweb.u-strasbg.fr/cdsws.gml
# @return resultat de la requete sous la forme d'une liste
#
proc vo_sesame { args } {
   global audace
   global conf

   package require SOAP

   set sesame(CDS)  "http://cdsws.u-strasbg.fr/axis/services/Sesame"
   set sesame(ADAC) "http://vizier.nao.ac.jp:8080/axis/services/Sesame"
   set sesame(ADS)  "http://vizier.cfa.harvard.edu:8080/axis/services/Sesame"
   set sesame(CADC) "http://vizier.hia.nrc.ca:8080/axis/services/Sesame"

   set argc [llength $args]
   if {$argc >=1 } {

      set name [lindex $args 0]
      set resultType "ui"
      if {$argc >= 2} { set resultType [lindex $args 1] }
      set server "CDS"
      if {$argc >= 3} { set server [lindex $args 2] }

      SOAP::create sesame \
         -uri $sesame($server) \
         -proxy $sesame($server) \
         -action "urn:sesame" \
         -params { "name" "string"  "resultType" "string"}

      set erreur [ catch { sesame $name $resultType } response ]

      if { $erreur == "0" } {
         return $response
      } else {
         if {[set nameofexecutable [file tail [file rootname [info nameofexecutable]]]]=="audela"} {
            tk_messageBox -title "error" -type ok -message $response
         }
         return "failed"
      }

   } else {

      error "Usage: vo_sesame name ?u|H|x?[p|i]? ?CDS|ADS|ADAC|CADC?"

   }
}


## @brief Appel du Webservice GLU (CDS) pour determiner l'URL d'un service Sesame accessible
# @author J. Berthier
# @param args {server}
# @par
# avec
# @verbatim
#   server : source du serveur de donnees: CDS | ADAC | ADS | CADC
# @endverbatim
# @par
# Plus d'info: http://cdsweb.u-strasbg.fr/cdsws.gml
# @return URL du serveur Sesame
#
proc vo_sesame_url { args } {
   package require SOAP

   set glu(CDS)  "http://cdsws.u-strasbg.fr/axis/services/Jglu"
   set glu(ADS)  "http://vizier.cfa.harvard.edu:8080/axis/services/Jglu"
   set glu(ADAC) "http://vizier.nao.ac.jp:8080/axis/services/Jglu"
   set glu(CADC) "http://vizier.hia.nrc.ca:8080/axis/services/Jglu"

   set argc [llength $args]
   if {$argc >= 1} {

      set server [lindex $args 0]
      set tag "Sesame"
      if {$argc >= 2} { set tag [lindex $args 1] }

      SOAP::create getURLfromTag \
         -uri $glu($server) \
         -proxy $glu($server) \
         -action "urn:getURLfromTag" \
         -params { "tag" "string" }

      return [ getURLfromTag $tag ]

   } else {
      error "Usage: vo_sesame_url ?CDS|ADS|ADAC|CADC?"
   }
}


## @brief Appel du Webservice VizieR (CDS) pour recuperer tous les objets d'un
#        (jeu de) catalogue(s) VizieR pour un champ de vue donne
# @author J. Berthier
# @param args {RA DEC radius unit criteria mime}
# @par
# avec
# @verbatim
#    RA DEC   : coordonnees equatoriales J2000.0 du centre du FOV (degres)
#    radius   : rayon du FOV
#    unit     : unite du rayon du FOV (e.g. deg | arcmin | arcsec)
#    criteria : citere de selection des catalogues VizieR (e.g. I/289/out)
#    mime     : type mime de la reponse (e.g. list (def.) | votable)
# @endverbatim
# @par
# Plus d'info: http://cdsweb.u-strasbg.fr/cdsws.gml
# @par
# Exemples de criteres VizieR:
#     UCAC3 : criteria = I/315/out
#     UCAC2 : criteria = I/289/out
#     UCAC2A: criteria = I/294A/ucac2bss
#     HIP   : criteria = I/239/hip_main
#     2MASS : criteria = II/246/out
#     TYCHO : criteria = I/239/tyc_main
# @par
# Dans la console, une fois la cmde executee, on peut executer:
# @code
#   SOAP::dump -request skybotstatus
#   SOAP::dump -reply skybotstatus
# @endcode
# afin de visualiser le texte de la requete et de la reponse SOAP.
# @par Exemple:
# @code
#   vo_vizier_query 105.0 +3.9 30 "arcmin" "I/239/tyc_main" "votable"
# @endcode
# @return resultat de la requete sous la forme d'une liste
#
proc vo_vizier_query { args } {
   package require SOAP
   package require dom

# TODO remonter dans variables Audace
   set vizier_url "http://cdsws.u-strasbg.fr/axis/services/VizieR"

   set argc [llength $args]
   if { $argc >=2 } {

      # reception des arguments
      set RA [mc_angle2deg [lindex $args 0]]
      set DEC [mc_angle2deg [lindex $args 1] 90]
      set target "[string trim $RA] [string trim [format %+.5f $DEC]]"
      set radius "5.0"
      if {$argc >= 3} { set radius [lindex $args 2] }
      set unit "arcmin"
      if {$argc >= 4} { set unit [lindex $args 3] }
      set criteria "I/315/out"
      if {$argc >= 5} { set criteria [lindex $args 4] }
      set mime "list"
      if {$argc >= 6} { set mime [lindex $args 5] }

      SOAP::create cataloguesData \
         -uri $vizier_url \
         -proxy $vizier_url \
         -action "urn:cataloguesData" \
         -params { "target" "string" "radius" "double" "unit" "string" "text" "string" }

      set erreur [ catch { cataloguesData $target $radius $unit $criteria } response ]

      if { $erreur == "0" } {
         if { $mime eq "votable" } {
            set vizier $response
         } else {
            # Parse la reponse VOTable
            set votable [::dom::parse $response]
            # Recupere les fields -> nom des colonnes
            set fields {}
            foreach n [::dom::selectNode $votable {descendant::FIELD/attribute::name}] {
               lappend fields "[::dom::node stringValue $n]"
            }
            # Recupere le nom du catalogue -> resource/description
            set catalog $criteria
            set catalogDesc [::dom::node stringValue [::dom::selectNode $votable {descendant::RESOURCE/DESCRIPTION/text()}]]
            lappend catalog $catalogDesc
            # Recupere toutes les lignes de la table
            set rows {}
            foreach tr [::dom::selectNode $votable {descendant::TR}] {
               set row {}
               foreach td [::dom::selectNode $tr {descendant::TD/text()}] {
                  lappend row [::dom::node stringValue $td]
               }
               lappend rows $row
            }
            # Cree la liste finale { {catalog} {fields} {rows} }
            set vizier {}
            lappend vizier [list $catalog $fields $rows]
         }
         return $vizier
      } else {
         if {[set nameofexecutable [file tail [file rootname [info nameofexecutable]]]]=="audela"} {
            tk_messageBox -title "error" -type ok -message $response
         }
         return "failed"
      }

   } else {

      error "Usage: vo_vizier_query ra dec ?radius? ?unit? ?VizieRCriteria?"

   }

}


## @brief Resolution du nom d'un corps celeste (hors objets du systeme solaire) en ses
#         coordonnees RA,DEC via le service Sesame (CDS)
# @author J. Berthier
# @param name nom du corps celeste
# @return coordonnees RA,DEC du corps
# @par
# Plus d'info: http://cdsweb.u-strasbg.fr/cdsws.gml
#
proc vo_name2coord { name } {
   package require SOAP
   set name "$name"
   set resultType "xp"
   set server "http://cdsws.u-strasbg.fr/axis/services/Sesame"
   SOAP::create sesame -uri $server -proxy $server \
      -action "urn:Sesame" \
      -params { "name" "string" "resultType" "string" }
   set xml_text [sesame $name $resultType]
   set ra [vo_xml_decode $xml_text {Sesame Target Resolver jradeg}]
   set dec [vo_xml_decode $xml_text {Sesame Target Resolver jdedeg}]
   return [list $ra $dec]
}


## @brief Recupere la liste des etoiles proches d'une coordonnees RA,DEC via le service VizieR (CDS)
# @author J. Berthier
# @param ra ascension droite du centre du champ
# @param dec declinaison du centre du champ
# @param radius rayon du champ de vue en arcmin (optionnel, defaut 0)
# @return coordonnees RA,DEC du corps
# @par
#   Si radius est different de zero, cette fonction recupere la liste de toutes les etoiles
#   dans un rayon de radius arcmin. Si radius=0 alors seule l'etoile la plus proche de cette
#   position est recuperee.
# @par Exemple:
# @code
#   set star [vo_neareststar 23.45678 +34.56742]
# @endcode
#
proc vo_neareststar { ra dec {radius 0} } {
   set target "[string trim [mc_angle2deg $ra]] [string trim [format %+.5f [mc_angle2deg $dec 90]]]"
   set rad 1
   if {$radius>0} {
      set rad $radius
   }
   set starlists ""
   if {1==0} {
      package require SOAP
      set server "http://cdsws.u-strasbg.fr/axis/services/VizieRBeta"
      SOAP::create vizier -uri $server -proxy $server \
         -action "urn:VizieRBeta" \
         -params { "target" "string" "radius" "double" "unit" "string" "text" "string"}
      set xml_text [vizier $target 3 arcmin " "]
   } else {
      set url "http://vizier.u-strasbg.fr/viz-bin/VizieR/VizieR-2"
      package require http
      set max 1000
      set query [::http::formatQuery "!-4c;" "Find Data" "-source" "I/297/out" "-c" "$target" "-c.eq" "J2000" "-c.r" "$rad" "-c.u" "arcmin" "-oc.form" "dec" "-c.geom" "r" "-out.add" "_r" "-sort" "_r" "-out.max" "$max"]
      set token [::http::geturl $url -query "$query"]
      upvar #0 $token state
      set html_text $state(body)
      # ----
      set kstar 1
      while {1==1} {
         set k1 [string first "<EM>$kstar</EM>" $html_text]
         if {$k1==-1} {
            break
         }
         set texte [string range $html_text $k1 end]
         set res [vo_html_decode1 $texte]
         set val [lindex $res 0]
         set texte [lindex $res 1]
         set res [vo_html_decode1 $texte <EM>]
         set id [lindex $res 0]
         set texte [lindex $res 1]
         set res [vo_html_decode1 $texte <EM>]
         set val [lindex $res 0]
         set texte [lindex $res 1]
         set res [vo_html_decode1 $texte <EM>]
         set ra [string trimleft [lindex $res 0] 0]
         set texte [lindex $res 1]
         set res [vo_html_decode1 $texte <EM>]
         set dec [lindex $res 0]
         set texte [lindex $res 1]
         for {set k 1} {$k<=5} {incr k} {
            set res [vo_html_decode1 $texte <EM>]
            set texte [lindex $res 1]
            set val [lindex $res 0]
         }
         set res [vo_html_decode1 $texte <EM>]
         set texte [lindex $res 1]
         set magb [lindex $res 0]
         if {[catch {expr $magb}]==1} { set magb ""}
         set res [vo_html_decode1 $texte <EM>]
         set val [lindex $res 0]
         set texte [lindex $res 1]
         set res [vo_html_decode1 $texte <EM>]
         set texte [lindex $res 1]
         set magv [lindex $res 0]
         if {[catch {expr $magv}]==1} { set magv ""}
         set res [vo_html_decode1 $texte <EM>]
         set val [lindex $res 0]
         set texte [lindex $res 1]
         set res [vo_html_decode1 $texte <EM>]
         set texte [lindex $res 1]
         set magr [lindex $res 0]
         if {[catch {expr $magr}]==1} { set magr ""}
         set res [vo_html_decode1 $texte <EM>]
         set val [lindex $res 0]
         set texte [lindex $res 1]
         set res [vo_html_decode1 $texte <EM>]
         set texte [lindex $res 1]
         set magj [lindex $res 0]
         if {[catch {expr $magj}]==1} { set magj ""}
         set res [vo_html_decode1 $texte <EM>]
         set texte [lindex $res 1]
         set magh [lindex $res 0]
         if {[catch {expr $magh}]==1} { set magh ""}
         set res [vo_html_decode1 $texte <EM>]
         set texte [lindex $res 1]
         set magk [lindex $res 0]
         if {[catch {expr $magk}]==1} { set magk ""}
         lappend starlists [list [list NOMAD-1 $id] $ra $dec $magb $magv $magr $magj $magh $magk]
         if {$radius==0} {
            break
         }
         incr kstar
      }
   }
   #set f [open $audace(rep_install)/bin/toto.html w]
   #puts $f $html_text
   #close $f
   return $starlists
}


## @brief Appel du Webservice Miriade.ephemcc fournissant les ephemerides des corps du systeme solaire
# @author J. Berthier
# @param args {name type epoch nbd step tscale observer theory teph tcoor rplane mime output extrap}
# @par
# avec
# @verbatim
#   name      : nom ou numero ou designation provisoire de l'objet au format: [prefix:]name[/X], avec prefix: 'a'steroide, 'p'lanete, 's'atellite, 'c'omet
#   type      : type du corps (aster | comet | planet | satellite)
#   epoch     : jour julien ou date ISO de l'epoque consideree
#   nbd       : nombre de date de calcul
#   step      : pas de calcul en jours
#   tscale    : echelle de temps (TT | UTC)
#   observer  : code UAI de l'observatoire, par defaut 500 (geocentre), ou code d'une sonde spatiale
#   theory    : choix de la theorie planetaire (INPOP | DE405)
#   teph      : type d'ephemerides:  1:astrometrique J2000, 2:apparente de la date, 3: moyenne de la date, 4: moyenne J2000
#   tcoor     : type de coordonnees calculees: 1=spherique, 2=rectangulaire, 3=coordonnees locales, 4=angle horaire, 5=didiees a l'observation, 6= dediees a l'observation OA
#   rplane    : choix du plan de reference (1=equateur, 2=ecliptique)
#   mime      : format de la reponse (text | votable | html)
#   output    : choix des donnees en sortie (object | basic | all), par defaut basic
#   extrap    : non utilise
# @endverbatim
# @par
# Plus d'info: http://vo.imcce.fr/webservices/miriade/?ephemcc
# @par
# Dans la console, une fois la cmde executee, on peut executer:
# @code
#   SOAP::dump -request ephemcc
#   SOAP::dump -reply ephemcc
# @endcode
# afin de visualiser le texte de la requete et de la reponse SOAP.
# @return resultat de la requete sous la forme d'une liste contenant l'ephemeride du corps demande
#
proc vo_miriade_ephemcc { args } {

   global audace
   global conf

   package require SOAP

   set argc [llength $args]
   if {$argc >= 4} {

      # reception des arguments
      # name  type  epoch  nbd  step  tscale  observer  theory  teph  tcoor  rplane  mime  output  extrap
      set name     [lindex $args 0]
      set type     [lindex $args 1]
      set epoch    [lindex $args 2]
      set nbd      [lindex $args 3]
      set step     [lindex $args 4]
      set tscale   [lindex $args 5]
      set observer [lindex $args 6]
      set theory   [lindex $args 7]
      set teph     [lindex $args 8]
      set tcoor    [lindex $args 9]
      set rplane   [lindex $args 10]
      set mime     [lindex $args 11]
      set output   [lindex $args 12]
      set extrap   ""
      if {$argc >= 14} { set extrap [lindex $args 13] }

      # The XML below is ripped straight from the generated request
      variable miriade_xml
      array set miriade_xml {
        ephemcc {<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns1="http://vo.imcce.fr/webservices/miriade"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
    SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <SOAP-ENV:Header>
    <ns1:clientID><ns1:from>AudeLA</ns1:from><ns1:hostip></ns1:hostip></ns1:clientID>
  </SOAP-ENV:Header>
  <SOAP-ENV:Body>
    <ns1:ephemcc>
      <inputArray xsi:type="ns1:ephemccRequest">
        <name xsi:type="xsd:string" >${name}</name>
        <type xsi:type="xsd:string" >${type}</type>
        <epoch xsi:type="xsd:string" >${epoch}</epoch>
        <nbd xsi:type="xsd:integer">${nbd}</nbd>
        <step xsi:type="xsd:string" >${step}</step>
        <tscale xsi:type="xsd:string" >${tscale}</tscale>
        <observer xsi:type="xsd:string" >${observer}</observer>
        <theory xsi:type="xsd:string" >${theory}</theory>
        <teph xsi:type="xsd:integer" >${teph}</teph>
        <tcoor xsi:type="xsd:integer" >${tcoor}</tcoor>
        <rplane xsi:type="xsd:integer" >${rplane}</rplane>
        <mime xsi:type="xsd:string" >${mime}</mime>
        <output xsi:type="xsd:string" >${output}</output>
        <extrap xsi:type="xsd:integer" >${extrap}</extrap>
      </inputArray>
    </ns1:ephemcc>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>}
      }

      # instance du client soap
      SOAP::create ephemcc \
         -uri "http://vo.imcce.fr/webservices/miriade" \
         -proxy "http://vo.imcce.fr/webservices/miriade/miriade.php" \
         -name "ephemcc" \
         -wrapProc vo_miriadeXML \
         -params { name string type string epoch string nbd integer step string tscale string observer string theory string teph integer tcoor integer rplane integer mime string output string extrap integer}

      # invocation du web service
      set erreur [ catch { ephemcc name $name type $type epoch $epoch nbd $nbd step $step tscale $tscale observer $observer theory $theory teph $teph tcoor $tcoor rplane $rplane mime $mime output $output extrap $extrap} response ]

      # recuperation des resultats
      set flag [lindex $response 1]
      set result [lindex $response 5]

      # On traite 3 cas de figure :
      # 1- une erreur s'est produite
      # 2- pas d'erreur mais la liste des corps est vide
      # 3- pas d'erreur et la liste contient au moins un corps
      #
      # Ces trois cas sont traites differemment suivant le type de table demande
      #  - type text : lorsque la liste est vide on renvoit "no"
      #  - type mime : si la liste est vide pas de traitement particulier
      #
      # Valeur de $flag : 0 == liste vide , > 0 sinon
      #
      if { $erreur == 0 } {
         if { $flag > 0 || $mime eq "votable" } {
            return $result
         } else {
            return "no"
         }
      } else {
         if {[set nameofexecutable [file tail [file rootname [info nameofexecutable]]]]=="audela"} {
            tk_messageBox -title "error" -type ok -message [concat "miriade: error: " $response]
         }
         return "failed"
      }

   } else {

     # error "Usage:skyb miriade Epoch RA_J2000 DEC_J2000 Radius(arcsec) ?text|votable|html? ?object|basic|all? Observer Filter(arcsec) objFilter(bitmask e.g. 110)"
      error "Usage: vo_miriade_ephemcc name  type  epoch(JD)  nbd  step  tscale  observer  theory  teph  tcoor  rplane  mime  output  extrap  from "

   }
}

## @brief Appel du Webservice Miriade.ephemsys fournissant les ephemerides des composantes d'un systeme asteroidal
# @author J. Berthier
# @param args {name epoch nbd step tscale gensol mime}
# @par
# avec
# @verbatim
#   name      : nom ou numero ou designation provisoire de l'objet au format: [prefix:]name[/X], avec prefix: 'a'steroide, 'p'lanete, 's'atellite, 'c'omet
#   epoch     : jour julien ou date ISO de l'epoque consideree
#   nbd       : nombre de date de calcul
#   step      : pas de calcul en jours
#   tscale    : echelle de temps (TT | UTC)
#   gensol    : Id of the Genoide orbital solution of the satellites
#   mime      : format de la reponse (text | votable | html)
# @endverbatim
# @par
# Plus d'info: http://ssp.localhost/webservices/miriade/api/ephemsys/
# @par
# Dans la console, une fois la cmde executee, on peut executer:
# @code
#   SOAP::dump -request ephemsys
#   SOAP::dump -reply ephemsys
# @endcode
# afin de visualiser le texte de la requete et de la reponse SOAP.
# @return resultat de la requete sous la forme d'une liste contenant l'ephemeride du corps demande
#
# Test:
# set ephemsys [vo_miriade_ephemsys "a:kalliope" "2018-11-16T01:21:00" 1 "1d" "UTC" 1 "votable"]
#
proc vo_miriade_ephemsys { args } {

   global audace
   global conf

   package require SOAP::https

   set argc [llength $args]
   if {$argc >= 4} {

      # reception des arguments
      # name epoch nbd step tscale gensol mime
      set name   [lindex $args 0]
      set epoch  [lindex $args 1]
      set nbd    [lindex $args 2]
      set step   [lindex $args 3]
      set tscale [lindex $args 4]
      set gensol [lindex $args 5]
      set mime   [lindex $args 6]

      # The XML below is ripped straight from the generated request

      # The XML below is ripped straight from the generated request
      set enveloppe "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<SOAP-ENV:Envelope
    xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"
    xmlns:ns1=\"https://ssp.imcce.fr/webservices/miriade\"
    xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"
    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
    xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\"
    SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
  <SOAP-ENV:Header>
    <ns1:clientID><ns1:from>AudeLA</ns1:from><ns1:hostip></ns1:hostip></ns1:clientID>
  </SOAP-ENV:Header>
  <SOAP-ENV:Body>
    <ns1:ephemsys>
      <inputArray xsi:type=\"ns1:ephemsysRequest\">
        <name xsi:type=\"xsd:string\" >${name}</name>
        <epoch xsi:type=\"xsd:string\" >${epoch}</epoch>
        <nbd xsi:type=\"xsd:integer\">${nbd}</nbd>
        <step xsi:type=\"xsd:string\" >${step}</step>
        <tscale xsi:type=\"xsd:string\" >${tscale}</tscale>
        <gensol xsi:type=\"xsd:integer\" >${gensol}</gensol>
        <mime xsi:type=\"xsd:string\" >${mime}</mime>
      </inputArray>
    </ns1:ephemsys>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>"

      variable miriade_xml
      array set miriade_xml [list ephemsys $enveloppe]

      # instance du client soap
      SOAP::create ephemsys \
         -uri "https://ssp.imcce.fr/webservices/miriade" \
         -proxy "https://ssp.imcce.fr/webservices/miriade/miriade.php" \
         -name "ephemsys" \
         -wrapProc vo_miriadeXML \
         -params { name string epoch string nbd integer step string tscale string gensol integer mime string }

      # invocation du web service
      set erreur [ catch { ephemsys name $name epoch $epoch nbd $nbd step $step tscale $tscale gensol $gensol mime $mime} response ]

      # recuperation des resultats
      set flag [lindex $response 1]
      set result [lindex $response 5]

      # On traite 3 cas de figure :
      # 1- une erreur s'est produite
      # 2- pas d'erreur mais la liste des corps est vide
      # 3- pas d'erreur et la liste contient au moins un corps
      #
      # Ces trois cas sont traites differemment suivant le type de table demande
      #  - type text : lorsque la liste est vide on renvoit "no"
      #  - type mime : si la liste est vide pas de traitement particulier
      #
      # Valeur de $flag : 0 == liste vide , > 0 sinon
      #
      if { $erreur == 0 } {
         if { $flag > 0 || $mime eq "votable" } {
            return $result
         } else {
            return "no"
         }
      } else {
         if {[set nameofexecutable [file tail [file rootname [info nameofexecutable]]]]=="audela"} {
            tk_messageBox -title "error" -type ok -message [concat "miriade: error: " $response]
         }
         return "failed"
      }

   } else {

     # error "Usage:skyb miriade Epoch RA_J2000 DEC_J2000 Radius(arcsec) ?text|votable|html? ?object|basic|all? Observer Filter(arcsec) objFilter(bitmask e.g. 110)"
      error "Usage: vo_miriade_ephemsys name type epoch nbd step tscale gensol mime from"

   }
}

## @brief Appel du Webservice Miriade.ephemsys fournissant les informations sur les solutions
# @author J. Berthier
# @param args {get name}
# @par
# avec
# @verbatim
#   get      : methode gensol ou systems
#   name     : nom ou numero ou designation provisoire de l'objet au format: [prefix:]name[/X], avec prefix: 'a'steroide, 'p'lanete, 's'atellite, 'c'omet
# @endverbatim
# @par
# Plus d'info: http://ssp.localhost/webservices/miriade/api/ephemsys/
# @par
# Dans la console, une fois la cmde executee, on peut executer:
# @code
#   SOAP::dump -request ephemsys
#   SOAP::dump -reply ephemsys
# @endcode
# afin de visualiser le texte de la requete et de la reponse SOAP.
# @return resultat de la requete sous la forme d'une liste contenant l'ephemeride du corps demande
#
# Test:
# set ephemsys [vo_miriade_ephemsys_get "gensol" "22"]
# set ephemsys [vo_miriade_ephemsys_get "systems" "kalliope"]
#
proc vo_miriade_ephemsys_get { args } {

   global audace
   global conf

   package require SOAP::https

   set argc [llength $args]

   if {$argc >= 2} {

      # reception des arguments
      # name epoch nbd step tscale gensol mime
      set get    [lindex $args 0]
      set name   [lindex $args 1]

      # The XML below is ripped straight from the generated request

      # The XML below is ripped straight from the generated request
      set enveloppe "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<SOAP-ENV:Envelope
    xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"
    xmlns:ns1=\"https://ssp.imcce.fr/webservices/miriade\"
    xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"
    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
    xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\"
    SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
  <SOAP-ENV:Header>
    <ns1:clientID><ns1:from>AudeLA</ns1:from><ns1:hostip></ns1:hostip></ns1:clientID>
  </SOAP-ENV:Header>
  <SOAP-ENV:Body>
    <ns1:ephemsys>
      <inputArray xsi:type=\"ns1:ephemsysRequest\">
        <get xsi:type=\"xsd:string\" >${get}</get>
        <name xsi:type=\"xsd:string\" >${name}</name>
      </inputArray>
    </ns1:ephemsys>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>"

      variable miriade_xml
      array set miriade_xml [list ephemsys $enveloppe]

      # instance du client soap
      SOAP::create ephemsys \
         -uri "https://ssp.imcce.fr/webservices/miriade" \
         -proxy "https://ssp.imcce.fr/webservices/miriade/miriade.php" \
         -name "ephemsys" \
         -wrapProc vo_miriadeXML \
         -params { get string name string }

      # invocation du web service
      set erreur [ catch { ephemsys get $get name $name } response ]

      # recuperation des resultats
      set flag [lindex $response 1]
      set result [lindex $response 5]

      # On traite 3 cas de figure :
      # 1- une erreur s'est produite
      # 2- pas d'erreur mais la liste des corps est vide
      # 3- pas d'erreur et la liste contient au moins un corps
      #
      # Ces trois cas sont traites differemment suivant le type de table demande
      #  - type text : lorsque la liste est vide on renvoit "no"
      #  - type mime : si la liste est vide pas de traitement particulier
      #
      # Valeur de $flag : 0 == liste vide , > 0 sinon
      #

      if { $erreur == 0 } {
         if { $flag > 0 } {
            return $result
         } else {
            return "no"
         }
      } else {
         if {[set nameofexecutable [file tail [file rootname [info nameofexecutable]]]]=="audela"} {
            tk_messageBox -title "error" -type ok -message [concat "miriade: error: " $response]
         }
         return "failed"
      }

   } else {

      error "Usage: vo_miriade_ephemsys_get get name"

   }
}
#============================================================
#  brief lecture d'une page HTML via http ou https
#  param url url
#  param fullfile_out nom du répertoire de stockage des fichiers
#
proc vo_read_url_contents { url query {fullfile_out ""} } {
   package require http
   set res ""
   set key [string first "http://" $url] 
   if {$key>=0} {
      # --- http
      if {$query==""} {
         # --- method GET
         set token [::http::geturl $url]
      } else {
         # --- method POST
         set token [::http::geturl $url -query $query]
      }
      upvar #0 $token state
      set res $state(body)
      set len [string length $res]
   } else {
      set key [string first "https://" $url] 
      if {$key>=0} {
         # --- https
         package require tls
         tls::init -tls1 true -ssl2 false -ssl3 false
         http::register https 443 tls::socket
         if {$query==""} {
            # --- method GET
            set token [::http::geturl $url -timeout 30000]
         } else {
            # --- method POST
            set token [::http::geturl $url -query $query -timeout 30000]
         }
         set status [http::status $token]
         set res [http::data $token]
         http::cleanup $token
         http::unregister https
      }
   }
   if {$fullfile_out!=""} {
      set f [open $fullfile_out w]
      puts -nonewline $f "$res"
      close $f
   }
   return $res
}

# proc vo_getmpcephem
# return ephemeris of a solar system object from a date to date+24h
# output : List of ephem where ephem is:
#          lassign $ephem obj_name obj_date obj_ra obj_dec obj_drift_ra obj_drift_dec obj_magv obj_az obj_elev obj_elong obj_phase obj_r obj_delta sun_elev
#
# source $audace(rep_install)/gui/audace/vo_tools.tcl ; vo_getmpcephem 2012DA14 2013-02-15T19:00:00 {GPS 6 E 43 1230}
proc vo_getmpcephem { object_id date_start home {incr_date 1} {incr_unit s} {incr_nb 1} } {
   #set url "http://scully.cfa.harvard.edu/cgi-bin/mpeph2.cgi"
   #set url "http://www.minorplanetcenter.net/cgi-bin/mpeph2.cgi"
   set url "https://cgi.minorplanetcenter.net/cgi-bin/mpeph2.cgi"
   set urlget ""
   set ids $object_id
   append urlget "\"$ids\" "
   append urlget "ty e "
   set a [mc_date2iso8601 $date_start]
   set date "[string range $a 0 3] [string range $a 5 6] [string range $a 8 9] [string range $a 11 12][string range $a 14 15][string range $a 17 18]"
   append urlget "d \"$date\" "
   append urlget "l $incr_nb "
   append urlget "i $incr_date "
   append urlget "u $incr_unit "
   append urlget "uto 0 "
   if {[llength $home]>1} {
      set home [mc_home2gps $home]
      lassign $home gps lon sense lat alt
      if {$sense=="W"} {
         set lon [expr $lon*-1.]
      }
      append urlget "long $lon lat $lat alt $alt "
   } else {
      append urlget "c $home "
   }
   append urlget "raty a "
   append urlget "s c "
   append urlget "m m "
   append urlget "igd n "
   append urlget "ibh n "
   append urlget "fp y "
   append urlget "e 0 "
   append urlget "tit \"\" "
   append urlget "bu \"\" "
   append urlget "adir S "
   append urlget "res n "
   append urlget "ch c "
   append urlget "oed \"\" "
   append urlget "js f "
   # console::affiche_resultat "$urlget\n"
   # ty = Return ephemerides (e=ephemeris)
   # d = date start (YYYY MM DD hh mm ss)
   # l = Number of dates to output (int)
   # i = Ephemeris interval (see "u" for units)
   # u = Ephemeris units (d=day h=hour m=minutes s=seconds)
   # uto = For daily ephemerides, enter desired offset from 0h UT (hours)
   # c = Observatory code (3 chars)
   # lon = longitude (deg)
   # lat = latitude (deg)
   # alt = altitude (m)
   # raty = coordinate display (a= Full sexa d=decimal)
   # s = motion mode (c=Separate R.A. and Decl. coordinate motions)
   # m = motion units (s="/sec m="/min h="/hour)
   # igd = Suppress output if sun above local horizon (y|n)
   # ibh = Suppress output if object below local horizon (y|n)
   # fp = Generate perturbed ephemerides for unperturbed orbits (y|n)
   # e = Format for elements output (0=MPC 8-line)
   # tit = Title for document (ascii)
   # bu = Base URL for document (ascii)
   package require http
   set toeval "::http::formatQuery TextArea $urlget"
   set login [eval $toeval]
   # ===
   set err [catch {vo_read_url_contents $url $login} msg]
   if {$err==1} {
      error "Error : $msg"
   } else {
      set res $msg
      set len [llength [split $res \n]]
      if {$len<15} {
         error [list "URL $url not found" $res]
      }
   }
   # ===
   if {1==0} {
      set err [catch {::http::geturl $url -query "$login"} token]
      if {$err==1} {
         error "$token"
      } else {
         upvar #0 $token state
         set res $state(body)
         set len [llength [split $res \n]]
         if {$len<15} {
            error [list "URL $url not found" $res]
         }
      }
      catch {
         set f [open c:/d/a/mpc.html w]
         puts -nonewline $f $res
         close $f
      }
   }
   #
   set resultats ""
   set lignes [split $res \n]
   set flagdeb 0
   set flagfin 0
   set nlig [llength $lignes]
   set comet_ephem ""
   set obj_name ""
   set obj_type ""
   for {set klig 0} {$klig<$nlig} {incr klig} {
      set ligne [lindex $lignes $klig]
      if {$flagdeb==0} {
         set key [string range $ligne 0 10]
         if {($key==" <p><hr><p>")&&($obj_name=="")} {
            set ligne2 [lindex $lignes [expr 1+$klig]]
            set k1 [string first <b>  $ligne2 ]
            if {$k1>=0} {
               set obj_type comet
            } else {
               set obj_type aster
               set ligne2 [lindex $lignes [expr 2+$klig]]
            }
            set k1 [expr [string first <b>  $ligne2 ]+3]
            set k2 [expr [string first </b> $ligne2 ]-1]
            set obj_name [string trim [string range $ligne2 $k1 $k2]]
         }
         set key [string range $ligne 0 36]
         #             123456789 123456789 123456789 123456789
         if {$key=="Date       UT      R.A. (J2000) Decl."} {
            set flagdeb $klig
            incr klig 1
            continue
         }
      }
      if {$flagdeb>0} {
         if {$ligne=="</pre>"} {
            set flagfin $klig
         }
      }
      if {($flagdeb>0)&&($flagfin==0)} {
         if {$ligne!="... Suppressed ..."} {
            set y [lindex $ligne 0]
            set m [lindex $ligne 1]
            set d [lindex $ligne 2]
            set hms [lindex $ligne 3]
            set obj_date [mc_date2iso8601 [list $y $m $d [string range $hms 0 1] [string range $hms 2 3] [string range $hms 4 5]]]
            set obj_ra  [string trim [mc_angle2deg [lindex $ligne 4]h[lindex $ligne 5]m[lindex $ligne 6]s ]]
            set obj_dec [string trim [mc_angle2deg [lindex $ligne 7]d[lindex $ligne 8]m[lindex $ligne 9]s 90]]
            set obj_delta [lindex $ligne 10]
            set obj_r [lindex $ligne 11]
            set obj_elong [lindex $ligne 12]
            set obj_phase [lindex $ligne 13]
            set obj_magv [string trim [string range $ligne 68 72]]
            set obj_drift_ra  [string trim [string range $ligne 73 81]]
            set obj_drift_dec [string trim [string range $ligne 82 89]]
            set ligne2 [string range $ligne 91 end]
            set obj_az [string trim [mc_angle2deg [lindex $ligne2 0] 360]]
            set obj_elev [string trim [mc_angle2deg [lindex $ligne2 1] 90]]
            set sun_elev [string trim [mc_angle2deg [lindex $ligne2 2] 90]]
            set res [list $obj_name $obj_date $obj_ra $obj_dec $obj_drift_ra $obj_drift_dec $obj_magv $obj_az $obj_elev $obj_elong $obj_phase $obj_r $obj_delta $sun_elev]
            #console::affiche_resultat "$ligne\n"
            lappend resultats $res
         }
      }
   }
   if {$obj_name==""} {
      error "Object $object_id not found"
   }
   return $resultats
}

# ------------------------------------------------------------------------------------
proc vo_html_decode1 { texte {taglim ""} } {
   # set tag "<TD ALIGN=RIGHT NOWRAP>"
   set tag "<TD"
   set k1 [string first "$tag" $texte]
   if {$taglim!=""} {
      set k1e [string first "$taglim" $texte]
      if {$k1e<$k1} {
         return [list "" ""]
      }
   }
   set texte [string range $texte $k1 end]
   set k1 [string first ">" $texte]
   set texte [string range $texte $k1 end]
   set k1 [string first ">" $texte]
   set k2 [string first "<" $texte]
   set res [string range $texte [expr $k1+1] [expr $k2-1]]
   return [list $res $texte]
}

# ------------------------------------------------------------------------------------
proc vo_xml_decode { xml tags {kdeb 0} } {
   set klast -1
   set n [llength $tags]
   set tag [lindex $tags 0]
   #::console::affiche_resultat "tag=$tag n=$n\n"
   set k1 [string first <$tag $xml $kdeb]
   set k11 [string first > $xml $k1]
   #::console::affiche_resultat "k1=$k1 k11=$k11\n"
   if {($k1>=0)&&($n==1)} {
      set k2 [string first </$tag $xml $kdeb]
      #::console::affiche_resultat "k2=$k2\n"
      if {($k2>=0)} {
         set value [string range $xml [expr $k11+1] [expr $k2-1]]
         return $value
      }
   } elseif {($k1>=0)&&($n>1)} {
      set tags [lrange $tags 1 end]
      #::console::affiche_resultat "appel vo_xml_decode xml $tags $k11\n"
      return [vo_xml_decode $xml $tags $k11]
   } else {
      return ""
   }
   return ""
}
