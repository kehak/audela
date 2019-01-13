# Script correction_dark
# This script will be sourced in the loop
# ---------------------------------------

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script
set robobs(image,dfilenames) ""

set bufNo $audace(bufNo)
set dateobs [mc_date2iso8601 [::audace::date_sys2ut]]

if {$robobs(planif,mode)=="geostat1"} {

   # --- correction par le dark
   set fname [lindex $robobs(image,filenames) 0]
	loadima $fname
	set k [string last _ $fname]
	set name [string range $fname [expr $k+1] end]
	if {$name=="geo"} {
	   set dname [lindex $robobs(image,filenames) 1]
      sub $dname 0
      ::robobs::log "Dark correction: sub $dname 0"
	}
   set robobs(image,dfilenames) "$robobs(conf,folders,rep_images,value)/prt1$robobs(conf,fichier_image,extension,value)"
   saveima $robobs(image,dfilenames)
	
}

if {$robobs(planif,mode)=="vttrrlyr"} {
   
	# --- recherche le temps de pose de l'image a corriger
   foreach fname $robobs(image,filenames) {
	   
	   # --- Charge l'image (obj ou darkobj)
      set fullfname "$robobs(conf,folders,rep_images,value)/${fname}$robobs(conf,fichier_image,extension,value)"
      buf$bufNo load $fullfname
      set objename [string trim [lindex [buf$bufNo getkwd OBJENAME] 1]]
		::robobs::log "The file to process has OBJENAME = $objename."
      if {[string first dark $objename]>=0} {
	      set isdark 1
			::robobs::log "The file to process is a dark frame ($objename)."
      } else {
	      set isdark 0
			::robobs::log "The file to process is a sky frame ($objename)."
      }

	   # --- On ne retient que les images de cette nuit
	   set fics ""
	   set fichiers [lsort [glob -nocomplain $robobs(conf,folders,rep_images,value)/IM*_${objename}*]]
	   foreach fichier $fichiers {	      
	      set fic [file rootname [file tail $fichier] ]
	      set k1 [string first _ $fic]
	      set k2 [string first _ $fic [expr $k1+2]]
	      set date [string range $fic [expr $k1+1] [expr $k2-1]]
	      set k3 [string first _ $fic [expr $k2+2]]
	      set time [string range $fic [expr $k2+1] [expr $k3-1]]
	      set dateobs [string range $date 0 3]-[string range $date 4 5]-[string range $date 6 7]T[string range $time 0 1]:[string range $time 2 3]:[string range $time 4 5]
	      set jdobs [mc_date2jd $dateobs]
	      if {($jdobs>$robobs(private,prev_sun_rise))&&($jdobs<$robobs(private,next_sun_rise))} {
	         lappend fics $fichier
	      }
	   }
	   set fichiers [lsort $fics]  
		::robobs::log "[llength $fichiers] files of type ${objename} to check."
   
	   if {$isdark==1} {
		   # verifie l'existance de tous les darks medians
		   set kd 1
		   foreach fichier $fichiers {
		   	set kd1 [expr $kd-4]
		   	set kd2 [expr $kd  ]
		   	if {$kd1<1} {
			   	set kd1 1
			   	set kd2 5
		   	}
			   # Name of medianized dark to check is it exists
		      set dfichier $robobs(conf,folders,rep_images,value)/${objename}_$robobs(private,nightdate)-${kd}$robobs(conf,fichier_image,extension,value)
		      if {[file exists $dfichier]==0} {
			     	set kddd 1
		         for {set kdd $kd1} {$kdd<=$kd2} {incr kdd} {
		            set fichier [lindex $fichiers [expr $kdd-1]]
		            if {$fichier==""} {
				         ::robobs::log "Not enough darks to medianize (${kddd}/5)."
			            break
		            }
		            set fichier2 $robobs(conf,folders,rep_images,value)/i${kddd}$robobs(conf,fichier_image,extension,value)
		            file copy -force -- $fichier $fichier2
		            ::robobs::log "DARK copy [file rootname [file tail $fichier]] -> [file rootname [file tail $fichier2]]"
		            incr kddd
		         }
		         if {$fichier!=""} {
			         smedian i ${objename}_$robobs(private,nightdate)-${kd} 5
			         ::robobs::log "DARK smedian i ${objename}_$robobs(private,nightdate)-${kd} 5"
		         }
	         }
		   	incr kd
	   	}		   
	   }
	   
	   if {$isdark==0} {
		   set ki 1
		   foreach fichier $fichiers {
		      set ifichier $robobs(conf,folders,rep_images,value)/${objename}_$robobs(private,nightdate)-${ki}$robobs(conf,fichier_image,extension,value)
		      if {[file exists $ifichier]==0} {
			      # --- charge l'image non corrigee
	            ::robobs::log "Load [file tail $fichier] for dark correction."      
			      buf$bufNo load $fichier
			      set kd [expr 1+($ki-1)/5]
            	set dname dark${objename}_$robobs(private,nightdate)-${kd}
			      set dfichier $robobs(conf,folders,rep_images,value)/${dname}$robobs(conf,fichier_image,extension,value)
			      if {[file exists $dfichier]==0} {
			         ::robobs::log "DARK $dfichier does not exist."
			         break
			      } else {
				      set exposure [string trim [lindex [buf$bufNo getkwd EXPOSURE] 1]]
				      set dname dark${exposure}s ; # debug panne d'obturateur
	            	::robobs::log "Dark correction: sub $dname 0"      
						sub $dname 0
				      buf$bufNo save $ifichier
	            	::robobs::log "Save image $ifichier"      
		            lappend robobs(image,dfilenames) $ifichier
					}
				}
				incr ki
		   }
	   }
   }
   
}

if {$robobs(planif,mode)=="trerrlyr"} {
   
	# --- correction du dark
	set ki 0
   foreach fname $robobs(image,filenames) {

	   # --- Charge l'image (obj ou darkobj)
      set fullfname "$robobs(conf,folders,rep_images,value)/${fname}$robobs(conf,fichier_image,extension,value)"
      buf$bufNo load $fullfname
		::robobs::log "The file to process is $fullfname."
      set objename [string trim [lindex [buf$bufNo getkwd OBJENAME] 1]]
      if {[string first dark $objename]>=0} {
	      set isdark 1
			::robobs::log "The file to process is a dark frame ($objename)."
         saveima dark
      } else {
	      set isdark 0
			::robobs::log "The file to process is a sky frame ($objename)."
         sub dark 0
			incr ki
			set dfname "$robobs(conf,folders,rep_images,value)/tmp${ki}$robobs(conf,fichier_image,extension,value)"
			::robobs::log "The file processed is $dfname."
			saveima $dfname
			lappend robobs(image,dfilenames) $dfname
      }

   }
}

if {($robobs(planif,mode)=="snresearch1")&&($robobs(image,filenames)!="")} {
   saveima tmp
   set fbias $robobs(conf_planif,snresearch1,filebias)
   set fdark $robobs(conf_planif,snresearch1,filedark)
   set fflat $robobs(conf_planif,snresearch1,fileflat)
   if {$robobs(cam,name)=="simulation"} {
      if {[file exists $fbias]==0} {
         buf$bufNo new CLASS_GRAY $simunaxis1 $simunaxis2 FORMAT_SHORT COMPRESS_NONE
      	set commande "buf$bufNo setkwd \{ \"DATE-OBS\" \"$dateobs\" \"string\" \"Begining of exposure UT\" \"Iso 8601\" \}"
      	set err1 [catch {eval $commande} msg]
      	set commande "buf$bufNo setkwd \{ \"NAXIS\" \"2\" \"int\" \"\" \"\" \}"
      	set err1 [catch {eval $commande} msg]
         # --- Complete the FITS header
         set exposure 0
         acq_set_fits_header $exposure
         set comment "Simulated bias"
      	set commande "buf$bufNo setkwd \{ \"COMMENT\" \"$comment\" \"string\" \"\" \"\" \}"
      	set err1 [catch {eval $commande} msg]   
      	set shutter closed
      	set commande "buf$bufNo setkwd \{ \"SHUTTER\" \"$shutter\" \"string\" \"Shutter action\" \"\" \}"
      	set err1 [catch {eval $commande} msg]	   
         ::robobs::log "Simulate the bias image" 3
         set shut 0
         simulimage * * * * * $robobs(conf,astrometry,cat_name,value) $robobs(conf,astrometry,cat_folder,value) $exposure 3.5 $diamtel R $skylevel 0.07 2.5 12 $shut 1000 100 1
         # --- Save the FITS file
         set date [mc_date2iso8601 [::audace::date_sys2ut]]
         set name $fbias
         ::robobs::log "Save image $name" 3
         saveima $name
      }
      if {[file exists $fdark]==0} {
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
      	set shutter closed
      	set commande "buf$bufNo setkwd \{ \"SHUTTER\" \"$shutter\" \"string\" \"Shutter action\" \"\" \}"
      	set err1 [catch {eval $commande} msg]	   
         ::robobs::log "Simulate the dark image" 3
         set shut 0
         simulimage * * * * * $robobs(conf,astrometry,cat_name,value) $robobs(conf,astrometry,cat_folder,value) $exposure 3.5 $diamtel R $skylevel 0.07 2.5 12 $shut 1000 100 1
         # --- Save the FITS file
         set date [mc_date2iso8601 [::audace::date_sys2ut]]
         set name $fdark
         ::robobs::log "Save image $name" 3
         saveima $name
      }
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
   if {[file exists $fbias]==1} {
      if {[file exists $fdark]==1} {
      	set commande "opt $fdark $fbias"
      	set err1 [catch {eval $commande} msg]
         ::robobs::log "DARK optimized correction $msg"
      } else {
      	set commande "sub $fbias 0"
      	set err1 [catch {eval $commande} msg]
         ::robobs::log "BIAS substraction"
      }
   }
   lappend robobs(image,dfilenames) "$robobs(conf,folders,rep_images,value)/tmp$robobs(conf,fichier_image,extension,value)"
   saveima $robobs(image,dfilenames)
}

if {(($robobs(planif,mode)=="asteroid_light_curve")||($robobs(planif,mode)=="star_light_curve")||($robobs(planif,mode)=="vachier_berthier"))&&($robobs(image,filenames)!="")} {
   set robobs(image,dfilenames) ""
	::robobs::log "Correction dark robobs(next_scene,action)=$robobs(next_scene,action)"
	if {$robobs(next_scene,action)=="science"} {
		set fbias $robobs(conf_planif,$robobs(planif,mode),filebias)
		set fdark $robobs(conf_planif,$robobs(planif,mode),filedark)
		set fflat $robobs(conf_planif,$robobs(planif,mode),fileflat)
		set valid 1
		if {($fdark=="")} {
			set valid 0
		} else {
			if {[file exists $fdark]==0} {
				set valid 0
			}
		}
		if {$robobs(planif,mode)=="vachier_berthier"} {
         set valid 1
      }
		if {$valid==1} {
			set index 0
			foreach fname $robobs(image,filenames) {
				incr index
				loadima $fname
				set bin [string trim [lindex [buf$bufNo getkwd BIN1] 1]]
				set exp [string trim [lindex [buf$bufNo getkwd EXPOSURE] 1]]
            set fulldark $fdark
				if {$robobs(planif,mode)=="vachier_berthier"} {
					set fdark superdark_bin${bin}_exp${exp}
               set fulldark $audace(rep_images)/${fdark}.fit
					if {[file exists $fulldark]==0} {
						set path $audace(rep_images)/../../darkflat/last
						set fdark $path/${fdark}.fit
                  set fulldark $fdark
					}
				}
				set commande "sub $fdark 0"
				set err1 [catch {eval $commande} msg]
				set dfname "$robobs(conf,folders,rep_images,value)/tmp${index}$robobs(conf,fichier_image,extension,value)"
            set dt [expr ([clock seconds]-[file mtime $fulldark])/86400.]
				::robobs::log "DARK frame $fdark is [format %.1f $dt] day old"
				::robobs::log "DARK substraction $fname by the dark frame $fdark to give $dfname"
				saveima $dfname
				lappend robobs(image,dfilenames) $dfname
				saveima test1
			}
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
			if {$name=="dark1"} {
				set bin [::robobs::key2val $image binx] ; # 				
				set nimages [::robobs::key2val $image nimages] ; # extract the number of darkX
				set kkbeg $ki
				set kkend [expr $ki+$nimages]
				# --- validation of the individual darks
				set valid 1
				for {set kki $kkbeg} {$kki<$kkend} {incr kki} {
					set fname [lindex $fnames $kki] ; # the FITS file
					loadima $fname
					set naxis1 [lindex [buf$bufNo getkwd NAXIS1] 1]
					set naxis2 [lindex [buf$bufNo getkwd NAXIS2] 1]
					set d 20
					set window [list $d $d [expr $naxis1-$d] [expr $naxis2-$d]]
					set res [buf$bufNo stat $window]
					lassign $res hicut locut maxi mini mean std backmean backstd contrast
					# --- superdark_bin1_exp10  mean=2726 std=111
					# --- superdark_bin1_exp120 mean=2727 std=211
					# --- superdark_bin2_exp10  mean=1429 std=64
					# --- superdark_bin2_exp120 mean=1433 std=204
					if {$bin==1} {
                  set mean_mini 2500 ; set mean_maxi 3000 ; set std_mini 100 ; set std_maxi 300
               } elseif {$bin==2} {
                  set mean_mini 1400 ; set mean_maxi 1500 ; set std_mini  50 ; set std_maxi 300
               } else {
                  set mean_mini 1400 ; set mean_maxi 1500 ; set std_mini  50 ; set std_maxi 300
               }
					if {($mean>=$mean_mini)&&($mean<=$mean_maxi)&&($std>=$std_mini)&&($std<=$std_maxi)} {
						# --- Image is valid. Make the last/superdark
					} else {
						# --- Image is not valid. Do not make the superdark
						set valid 1
					}
				}
				if {$valid==1} {
					# --- copy raw files into dark1 to darkn
					for {set kki $kkbeg} {$kki<$kkend} {incr kki} {
						set fname [lindex $fnames $kki] ; # the FITS file
						set dfname dark[expr $kki-$kkbeg+1]
						::robobs::log "DARK copy $fname to $dfname"
						loadima $fname
						saveima $dfname
					}
					# --- make the superdark
					set exp [string trim [lindex [buf1 getkwd EXPOSURE] 1]]
					set superdark superdark_bin${bin}_exp${exp}					
					::robobs::log "ssort dark $superdark $nimages 25"
					ssort dark $superdark $nimages 25
					# --- Image is valid. Make the last/superdark
					set path $audace(rep_images)/../../darkflat/last
					file mkdir $path
					file copy -force -- $audace(rep_images)/${superdark}.fit $path/${superdark}.fit
				}
			}
			incr ki
		}
	}
	
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
