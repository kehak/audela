gui/cgi directory is used to use AudeLA as a CGI

Prerequesites:
Install Apache server
Launch the Apache server

Install AudeLA as CGI using the command:
source $audace(rep_install)/bin/cgi_install.tcl ; ::cgi_install::run

Try a simple example:
http://127.0.0.1/audela/ephem1.html

Usefull files:
* The file $audace(rep_install)/bin/cgi_root.tcl
contains the directories where to write files to share on web.