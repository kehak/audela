# Script correction_flat
# This script will be sourced in the loop
# ---------------------------------------

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script
set robobs(image,ffilenames) ""

set bufNo $audace(bufNo)
set dateobs [mc_date2iso8601 [::audace::date_sys2ut]]

if {($robobs(planif,mode)=="snresearch1")&&($robobs(image,dfilenames)!="")} {
   set fflat $robobs(conf_planif,snresearch1,fileflat)
   if {$robobs(cam,name)=="simulation"} {
      if {[file exists $fflat]==0} {
         buf$bufNo new CLASS_GRAY $simunaxis1 $simunaxis2 FORMAT_SHORT COMPRESS_NONE
      	set commande "buf$bufNo setkwd \{ \"DATE-OBS\" \"$dateobs\" \"string\" \"Begining of exposure UT\" \"Iso 8601\" \}"
      	set err1 [catch {eval $commande} msg]
      	set commande "buf$bufNo setkwd \{ \"NAXIS\" \"2\" \"int\" \"\" \"\" \}"
      	set err1 [catch {eval $commande} msg]
         # --- Complete the FITS header
         set exposure 120
         acq_set_fits_header $exposure
         set comment "Simulated bias"
      	set commande "buf$bufNo setkwd \{ \"COMMENT\" \"$comment\" \"string\" \"\" \"\" \}"
      	set err1 [catch {eval $commande} msg]   
      	set shutter synchro
      	set commande "buf$bufNo setkwd \{ \"SHUTTER\" \"$shutter\" \"string\" \"Shutter action\" \"\" \}"
      	set err1 [catch {eval $commande} msg]	   
         ::robobs::log "Simulate the dark image" 3
         set shut 3
         simulimage * * * * * $robobs(conf,astrometry,cat_name,value) $robobs(conf,astrometry,cat_folder,value) $exposure 3.5 $diamtel R $skylevel 0.07 2.5 12 $shut 0 0 1
         # --- Save the FITS file
         set date [mc_date2iso8601 [::audace::date_sys2ut]]
         set name $fflat
         ::robobs::log "Save image $name" 3
         saveima $name
      }
   }   
   if {[file exists $fflat]==1} {
      buf$bufNo load $fflat
      set mean [lindex [stat] 4]
      buf$bufNo load $robobs(image,dfilenames)
   	set commande "div $fflat $mean"
   	set err1 [catch {eval $commande} msg]
      ::robobs::log "FLAT division ($mean)"
   }
   if {$robobs(conf_planif,snresearch1,smearing)>0} {
   	set commande "unsmear $robobs(conf_planif,snresearch1,smearing)"
   	set err1 [catch {eval $commande} msg]
      ::robobs::log "$commande"
   }
   lappend robobs(image,ffilenames) "$robobs(conf,folders,rep_images,value)/tmp$robobs(conf,fichier_image,extension,value)"
   saveima $robobs(image,ffilenames)
}

if {(($robobs(planif,mode)=="asteroid_light_curve")||($robobs(planif,mode)=="star_light_curve")||($robobs(planif,mode)=="vachier_berthier"))&&($robobs(image,filenames)!="")} {
   set robobs(image,ffilenames) ""
	::robobs::log "Correction flat robobs(next_scene,action)=$robobs(next_scene,action)"
	if {$robobs(next_scene,action)=="science"} {
		set fbias $robobs(conf_planif,$robobs(planif,mode),filebias)
		set fdark $robobs(conf_planif,$robobs(planif,mode),filedark)
		set fflat $robobs(conf_planif,$robobs(planif,mode),fileflat)
		set valid 1
		if {($fflat=="")} {
			set valid 0
		} else {
			if {[file exists $fflat]==0} {
				set valid 0
			}
		}
		if {$robobs(planif,mode)=="vachier_berthier"} {
         set valid 1
      }
		if {$valid==1} {
			set index 0
			foreach dfname $robobs(image,dfilenames) {
				incr index
				loadima $dfname
				set bin [string trim [lindex [buf$bufNo getkwd BIN1] 1]]
            set fullflat $fflat
				if {$robobs(planif,mode)=="vachier_berthier"} {
				   set fi $robobs(conf_planif,$robobs(planif,mode),filter)
					set fflat superflat_bin${bin}_${fi}
               set fullflat $audace(rep_images)/${fflat}.fit
					if {[file exists $fullflat]==0} {
						set path $audace(rep_images)/../../darkflat/last
						set fflat $path/${fflat}.fit
                  set fullflat $fflat
					}
				}
            set dt [expr ([clock seconds]-[file mtime $fullflat])/86400.]
				::robobs::log "FLAT frame $fflat is [format %.1f $dt] day old"
				set commande "div $fflat 10000"
				set err1 [catch {eval $commande} msg]
				::robobs::log "FLAT division $dfname by the flat frame $fflat"
				set ffname "$robobs(conf,folders,rep_images,value)/tmp${index}$robobs(conf,fichier_image,extension,value)"
				buf$bufNo setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]					
				saveima $ffname
				lappend robobs(image,ffilenames) $ffname
				saveima test2
			}
		} else {
			foreach dfname $robobs(image,dfilenames) {
				lappend robobs(image,ffilenames) $dfname
			}
			::robobs::log "robobs(image,ffilenames)=$robobs(image,ffilenames)"
		}	
	} elseif {$robobs(next_scene,action)=="flat & dark"} {
		set fnames $robobs(image,filenames) ; # list of native FITS files acquired
		set ni [llength $robobs(next_scene,images)] ; # number of images requested
		set tobestackeds ""
		set ki 0
		while {$ki<$ni} {
			set image [lindex $robobs(next_scene,images) $ki] ; # one image requested
			set name [::robobs::key2val $image name] ; # extract the name as darkX or flatX
			::robobs::log "ki=$ki name=$name"
			if {$name=="flat1"} {
				set bin [::robobs::key2val $image binx] ; # 
				set nimages [::robobs::key2val $image nimages] ; # extract the number of flatX
				set kkbeg $ki
				set kkend [expr $ki+$nimages]
				# --- validation of the individual flats
				set valid 1
				for {set kki $kkbeg} {$kki<$kkend} {incr kki} {
					set fname [lindex $fnames $kki] ; # the FITS file
					loadima $fname
					set exp [string trim [lindex [buf1 getkwd EXPOSURE] 1]]
					set superdark superdark_bin${bin}_exp${exp}					
					sub $superdark 0
					ngain 10000
					set naxis1 [lindex [buf$bufNo getkwd NAXIS1] 1]
					set naxis2 [lindex [buf$bufNo getkwd NAXIS2] 1]
					set d 20
					set window [list $d $d [expr $naxis1-$d] [expr $naxis2-$d]]
					set res [buf$bufNo stat $window]
					lassign $res hicut locut maxi mini mean std backmean backstd contrast
					::robobs::log "Flat bin=$bin exp=$exp statistics std=$std mean=$mean"
					# --- superflat_bin1 mean=10017 std=231
					# --- superflat_bin2 mean=10017 std=183
					if {1==0} {
						if {$bin==1} {set std_mini 250 ; set std_maxi 500}
						if {$bin==2} {set std_mini 100 ; set std_maxi 250}
						if {$bin==3} {set std_mini 100 ; set std_maxi 250}
						if {($std>=$std_mini)&&($std<=$std_maxi)} {
							# --- Image is valid. Make the last/superflat
						} else {
							# --- Image is not valid. Do not make the superflat
							::robobs::log "Flat not valid. std=$std must be in the range $std_mini to $std_maxi"
							set valid 0
						}
					}
				}
				if {$valid==1} {
					# --- copy raw files into flat1 to flatn
					for {set kki $kkbeg} {$kki<$kkend} {incr kki} {
						set fname [lindex $fnames $kki] ; # the FITS file
						set dfname flat[expr $kki-$kkbeg+1]
						::robobs::log "FLAT copy $fname to $dfname"
						loadima $fname
						set exp [string trim [lindex [buf1 getkwd EXPOSURE] 1]]
						set superdark superdark_bin${bin}_exp${exp}					
						sub $superdark 0
						ngain 10000
						saveima $dfname
					}
					# --- make the superflat
				   set fi $robobs(conf_planif,$robobs(planif,mode),filter)
					set superflat superflat_bin${bin}_$fi
					::robobs::log "ssort flat $superflat $nimages 25"
					ssort flat $superflat $nimages 25
					# --- Image is valid. Make the last/superflat
					set path $audace(rep_images)/../../darkflat/last
					file mkdir $path
					file copy -force -- $audace(rep_images)/${superflat}.fit $path/${superflat}.fit
				}
			}
			incr ki
		}
	}
}

if {$robobs(planif,mode)=="trerrlyr"} {
	set object [lindex [buf$bufNo getkwd OBJECT] 1]  
	if {$object=="rrlyr"} {
		set robobs(image,ffilenames) $robobs(image,dfilenames)
	} else {
		set robobs(image,ffilenames) ""
		set robobs(conf_planif,$robobs(planif,mode),fileflat) C:/Data/darkflat/flat_1x1.fit
		set fflat $robobs(conf_planif,$robobs(planif,mode),fileflat)
		set valid 1
		if {($fflat=="")} {
			set valid 0
		} else {
			if {[file exists $fflat]==0} {
				set valid 0
			}
		}
		if {$valid==1} {
			set index 0
			foreach dfname $robobs(image,dfilenames) {
				incr index      
				loadima $dfname
				set commande "div $fflat 10000"
				set err1 [catch {eval $commande} msg]
				::robobs::log "FLAT division $dfname by the flat frame $fflat"
				set ffname "$robobs(conf,folders,rep_images,value)/tmp${index}$robobs(conf,fichier_image,extension,value)"
				buf$bufNo setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]					
				saveima $ffname
				lappend robobs(image,ffilenames) $ffname
			}
		} else {
			foreach dfname $robobs(image,dfilenames) {
				lappend robobs(image,ffilenames) $dfname
			}
			::robobs::log "robobs(image,ffilenames)=$robobs(image,ffilenames)"
		}	
	}
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
