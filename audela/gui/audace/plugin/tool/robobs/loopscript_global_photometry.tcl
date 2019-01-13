# Script global_photometry
# This script will be sourced in the loop
# ---------------------------------------

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

set bufNo $audace(bufNo)

# === Body of script
if {($robobs(planif,mode)=="star_light_curve")&&($robobs(image,ffilenames)!="")} {
	foreach ffname $robobs(image,ffilenames) {
		loadima $ffname
		set objename [lindex [buf$bufNo getkwd OBJENAME] 1]
		# photrel_wcs2cat $objename $ni new mais pour une seule image a ajouter
		::robobs::log "Ajoute les etoiles dans le catalogue."
	}
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
