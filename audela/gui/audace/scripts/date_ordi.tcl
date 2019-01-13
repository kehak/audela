# Permet d'afficher sur la console la date et l'heure systême
# date_ordi.tcl

   set date [mc_date2ymdhms now]
   ::console::affiche_resultat "Heure et date de votre micro ordinateur :\n"
   ::console::affiche_resultat "$date\n"

