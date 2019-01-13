#
# Fichier : skybot_status_example.tcl
# Description : Exemple de requete pour connaitre le statut d'une tranche de temps de Skybot
#     source /usr/local/src/audela/gui/audace/plugin/tool/vo_tools/Examples/skybot_status_example.tcl
# Auteur : Jerome BERTHIER
# Mise à jour $Id: skybot_status.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

# Defini l'epoque demadee
set epoch "2008-01-01 03:48:04"

# Epoque couvert par Skybot - inconnue
set uptodate 0

# Interrogation de SKtbot status
set erreur [ catch { vo_skybotstatus votable $epoch } statut ]

# Recupere le flag de retour
set flag [lindex $statut 1]

# ok, pas d'erreur
if { $erreur == "0" && $flag == "1" } {

   # Recupere le ticket et la votable
   set ticket [lindex $statut 3]
   set xml [lindex $statut 5]
   #--- Parse la votable
   set votable [::dom::parse $xml]
   # La table ne comporte qu'une seule ligne
   set row {}
   # Cherche dans la ligne la presence du mot cle uptodate
   foreach td [::dom::selectNode $tr "descendant::TD/text()"] {
      if {[string match -nocase "uptodate" [::dom::node stringValue $td]]} {
         set uptodate 1
      }
   }

} else {

   #--- ooopps, erreur...
   if { $flag == "-1" } {
      set msgError "La date demandee n'est pas couverte par Skybot"
   } else {
      set msgError "oopps, erreur"
   }
   ::console::affiche_resultat $msgError

}

::console::affiche_resultat [concat "Uptodate = " $uptodate]
