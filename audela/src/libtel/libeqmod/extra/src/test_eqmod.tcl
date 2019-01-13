
# - Positionner la monture tube en direction du pole celeste (contre poids vers le bas)
# - Connecter la monture dans Audela
# - Dans la console :

source [file join $audace(rep_install) src libtel libeqmod extra src eqmod.tcl]

::eqmod::ressource
::eqmod_control::init

# Mouvement en declinaison
::eqmod_control::test1 80
::eqmod_control::test1 0
::eqmod_control::park

# Mouvement en angle horaire
::eqmod_control::test2 200
::eqmod_control::test2 340
::eqmod_control::park

# Mouvements combines
::eqmod_control::test3 200 80
::eqmod_control::test3 340 80
::eqmod_control::park

# Pointer une etoile
::eqmod_control::test4 capella
::eqmod_control::test4 vega

# Suivi sideral
::eqmod_control::test5

# Suivi particulier en declinaison sens decroissant
::eqmod_control::test6 200 2 2
