#
# Fichier : cfgcgi.tcl
# Mise à jour $Id: cfgcgi.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

# --- repertoire de depot des requetes
set rep(req) d:/audela

# --- repertoire des images
set rep(visu) d:/audela

# --- definition du site d'observation
if {[info exists audace]==0} {
   # - Pas de contexte Aud'ACE
   set site {gps 2.1383 e 45.1234 125}
} else {
   # - Pour le contexte Aud'ACE
   set site "$audace(posobs,observateur,gps)"
}

# --- liste des utilisateurs autorises
set req(users) {robert alain}
set req(passwords) {audela audace}

