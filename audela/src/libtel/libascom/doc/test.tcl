# source ../src/libtel/libascom/src/test.tcl


::console::affiche_resultat "LIST OF SUPPORTED DEVICES BY ASCOM\n"
set resultat ""
foreach key [ ::registry keys "HKEY_LOCAL_MACHINE\\Software\\ASCOM\\Telescope Drivers" ] {
	if { [ catch { ::registry get "HKEY_LOCAL_MACHINE\\Software\\ASCOM\\Telescope Drivers\\$key" "" } r ] == 0 } {
		lappend resultat $r $key
		::console::affiche_resultat "$key ===> $r\n"
	}
}

set name ScopeSim.Telescope
#set name ACL.Telescope ; # for DFM telescopes

::console::affiche_resultat "\n"
::console::affiche_resultat "TEST OF DRIVER $name\n"
set teno [tel::create ascom $name]

::console::affiche_resultat "Telescope number $teno connected\n"

set res [tel1 radec coord]
::console::affiche_resultat "RADEC = $res\n"

#tel::delete  $teno
#::console::affiche_resultat "Telescope number $teno deconnected\n"

#tel1 radec goto {7h 3d}

# tel1 home $conf(posobs,observateur,gps)