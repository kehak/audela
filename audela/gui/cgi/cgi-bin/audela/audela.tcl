# --- recupere les donnees du formulaire
# --- dans les arrays :
# --- cgi(cgiaudela,names)
# --- cgi(cgiaudela,values)
set cgiaudela_entete 0
set numerror [ catch {
   #source cgi_root.tcl
   source cgiutil.tcl
   # --- Verifie si le nom 'mode' existe
   # --- Cela est code dans le formulaire de la page HTML
   # --- par la ligne <input NAME="mode" TYPE=HIDDEN VALUE="test1">
   set num [lsearch $cgi(cgiaudela,names) mode]
   if {$num>=0} {
      set value [lindex $cgi(cgiaudela,values) $num]
      source ${value}.tcl
   }
} msgerror ]

if {$numerror==1} {
   # --- Identificateur de l'entete de la page HTML pour le client
   if {$cgiaudela_entete==0} {
      puts -nonewline "Content-type: text/html\n\n\n"
      puts "<HTML>"
      puts "<HEADER>"
      puts "</HEADER>"
      puts "<BODY>"
   }
   puts "Tarot CGI error<br>"
   puts "Report : $msgerror <br>"
   puts "</BODY>"
   puts "</HTML>"
}


# --- Fin du CGI
exit

