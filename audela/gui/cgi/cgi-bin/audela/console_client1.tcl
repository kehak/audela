#
# Fichier : console_client1.tcl
#

# --- entete HTML
cgiaudela_entete
puts "<BODY>"

set script ""
set num [lsearch $cgi(cgiaudela,names) script]
if {$num>=0} {
   set script [lindex $cgi(cgiaudela,values) $num]
}
set host 127.0.0.1
set port 5555
set err [catch {
   set sock [socket $host $port]
} msg]
if {$err==1} {
   puts "Error: Audela terminal not found !<br>"
   puts "You must launch AudeLA on this computer and write <i>console::server open</i> in the terminal.<br>"
} else {
   fconfigure $sock -buffering line -blocking 0
   puts $sock "${script}"
   flush $sock
   after 500
   set errmsg ""
   set res $errmsg
   while {($res==$errmsg)||($res=="")} {
      set res [read $sock]
      flush $sock
      after 100
   }
   flush $sock
   lassign $res err msg
   close $sock
   puts "<PRE>"
   if {$err==0} { 
      set color green
   } else { 
      set color red
   }
   puts "$script"
   puts "<font color=$color> $msg </font>"
   puts "</PRE>"
}

# --- fin HTML
puts "</BODY>"
cgiaudela_fin
