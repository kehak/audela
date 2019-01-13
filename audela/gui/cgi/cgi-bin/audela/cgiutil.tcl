#
# Fichier : gciutil.tcl
#

# ================================
# ==== PROC pour decodage CGI ====
# ================================
proc cgiaudela_transcode { chaine } {
   # --- remplace %XX par la valeur ASCII de l'hexadecimal XX
   #     par exemple : %2B est remplacé par le caractere ASCII decimal 43 (+)
   set chaine_out ""
   set n [string length $chaine]
   for {set k 0} {$k<$n} {incr k} {
      set car [string index $chaine $k]
      if {$car=="%"} {
         set cars "\\x[string range $chaine [expr $k+1] [expr $k+2]]"
         if {($cars=="\\x0A")&&($cars0=="\\x0D")} {
            set car "\n"
         } else {
            set car [subst "$cars" ]
         }
         incr k 2
         set cars0 $cars
      } else {
         set cars0 ""
      }
      append chaine_out $car
   }
   return $chaine_out
}

# ===============================
# ==== PROC pour entete HTML ====
# ===============================
proc cgiaudela_entete { } {
   # --- Identification d'une page HTML pour le client
   puts "Content-type: text/html\n\n\n"
   # --- Debut du texte HTML
   puts "<HTML>"
}

# ===============================
# ==== PROC pour entete HTML ====
# ===============================
proc cgiaudela_fin { } {
   # --- fin du texte HTML
   puts "</HTML>"
}

# ================================================
# ==== DECODAGE des donnees du formulaire CGI ====
# ================================================

set cgi(cgiaudela,names)  {}
set cgi(cgiaudela,values) {}
set cgi(cgiaudela,listenv) [array names env]

# --- decode le type de methode ---
set cgi(cgiaudela,REQUEST_METHOD) ""
if {[lsearch $cgi(cgiaudela,listenv) REQUEST_METHOD]!=-1} {
   set cgi(cgiaudela,REQUEST_METHOD) $env(REQUEST_METHOD)
}

# --- s'il n'y a pas de methode alors on sort ---
if {$cgi(cgiaudela,REQUEST_METHOD)==""} {
   return
}

# --- detecte Netscape 6.0 pour signaler la presence du bug TARGET
# --- qui change la methode POST en GET !
set cgi(cgiaudela,bug,target) "no"
catch {
   if {[string first "Netscape6/6.0" $env(HTTP_USER_AGENT)]!=-1} {
      set cgi(cgiaudela,bug,target) "yes"
   }
}

# --- extrait la chaine des champs d'entree selon la methode ---
set cgi(cgiaudela,QUERY_STRING) ""
if {$cgi(cgiaudela,REQUEST_METHOD)=="GET"} {
   set cgi(cgiaudela,error) [catch { \
     set cgi(cgiaudela,QUERY_STRING) $env(QUERY_STRING) \
   } ]
   if {$cgi(cgiaudela,error)==1} {
      return
   }
}
if {$cgi(cgiaudela,REQUEST_METHOD)=="POST"} {
   set cgi(cgiaudela,CONTENT_LENGTH) $env(CONTENT_LENGTH)
   catch {set cgi(cgiaudela,QUERY_STRING) \
      [read stdin $cgi(cgiaudela,CONTENT_LENGTH)]} cgi(cgiaudela,error)
   if {$cgi(cgiaudela,error)==1} {
      catch {set cgi(cgiaudela,tty) [open "../stdin.txt" "r"]} cgi(cgiaudela,error)
      if {$cgi(cgiaudela,error)==1} {
         return
      }
      catch {set cgi(cgiaudela,QUERY_STRING) [read $cgi(cgiaudela,tty) \
         $cgi(cgiaudela,CONTENT_LENGTH)]} cgi(cgiaudela,error)
      close $cgi(cgiaudela,tty)
   }
}

# --- fractionne la chaine en une liste (separateur &)
#set ttyf [open "c:/env.txt" w]
#puts $ttyf "$cgi(cgiaudela,QUERY_STRING)"
#close $ttyf
set cgi(cgiaudela,liste) [split $cgi(cgiaudela,QUERY_STRING) "&"]

# --- transcode tous les caracteres et genere les deux listes
foreach cgi(cgiaudela,champ) $cgi(cgiaudela,liste) {
   # --- les + sont convertis en espaces
   regsub -all  {[+]} [lindex $cgi(cgiaudela,champ) 0] " " cgi(cgiaudela,champ)
   # --- le champ est partage en deux
   set cgi(cgiaudela,champ) [split $cgi(cgiaudela,champ) "="]
   # --- les champs sont transcodes
   lappend cgi(cgiaudela,names)  "[cgiaudela_transcode [lindex $cgi(cgiaudela,champ) 0]]"
   lappend cgi(cgiaudela,values) "[cgiaudela_transcode [lindex $cgi(cgiaudela,champ) 1]]"
}

