# Script image_archive
# This script will be sourced in the loop
# ---------------------------------------

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script
set robobs(image,xfilenames) ""
set bufNo $audace(bufNo)

proc transf_allsky { azim elev width height} {
   set Cx 498.
   set Cy 380.
   set PI [expr 4*atan(1)]
   set dr [expr $PI/180.]
   set rd [expr 180./$PI]
   set azim [expr $azim*$dr]
   set elev [expr $elev*$dr]
   # position Zenith en x
   set Zx 498.
   # position Zenith en y
   set Zy 380.
   # position Sud en x
   set Sx 922.
   # position Sud en y
   set Sy 410.
   # Calcul vectuer Zenith Sud
   set ZSx [expr $Sx-$Zx]
   set ZSy [expr -$Sy+$Zy]
   set te [expr atan2($ZSy,$ZSx)]
   set R [expr sqrt(pow(498.-71.,2)+pow(380.-350.,2))]
   set r [expr $R*((90.-$elev/$dr)/90.)]
   set a [expr $azim+$te]
   set xp [expr $r*cos($a)]
   set yp [expr $r*sin($a)]
   set x [expr $xp+$Cx]
   set y [expr -$yp+$Cy]
   set x [expr $x/1024.*$width]
   set y [expr $y/768.*$height]
   return [list [format "%0.2f" $x] [format "%0.2f" $y]] 
}

proc make_svg { coord_from_images } {
	global robobs
	global audace
	set bufNo $audace(bufNo)	
	if {$coord_from_images==1} {
		set date_obs [string range [lindex [buf$bufNo getkwd DATE-OBS] 1] 0 15]
		set elev [::robobs::key2val $robobs(next_scene,www_infos) elev]
		set az   [::robobs::key2val $robobs(next_scene,www_infos) az]
		set label_color labeldate
		set circle_color skycircle
	} else {
		set date_obs "Not imaging"
		set date [::audace::date_sys2ut]
		set jd [mc_date2jd $date]
		set home $robobs(conf,home,gps,value)
		lassign [tel1 radec coord] ra dec
      set res [mc_radec2altaz $ra $dec $home $jd]
      set az [lindex $res 0]
      set elev [lindex $res 1]   
		set label_color labelpark
		set circle_color parkcircle
	}
	if {($elev!="")&&($az!="")} {
		set label "sky"
		set width 640 ; #1024
		set height 480 ; #768
		lassign [transf_allsky 0 0 $width $height] xs ys
		lassign [transf_allsky 0 90 $width $height] xz yz
		lassign [transf_allsky $az $elev $width $height] x y
		if {$label_color=="labeldate"} {
			set xt [expr $x-75]
		} else {
			set xt [expr $x-38]
		}
		set yt [expr $y-15]
		set texte_svg ""
		append texte_svg "<?xml version='1.0' encoding='utf-8' standalone='no'?>\n"
		append texte_svg "<svg width='${width}px' height='${height}px' preserveAspectRatio='xMinYMin meet' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'>\n"
		append texte_svg "<defs><style type='text/css'>\n"
		append texte_svg "<!\[CDATA\[.astercircle{fill:none;stroke:#fc9600;stroke-width:2.0}\n"
		append texte_svg ".verifcircle{fill:none;stroke:#00ff00;stroke-width:2.0}\n"
		append texte_svg ".skycircle{fill:none;stroke:#fc9600;stroke-width:2.0}\n"
		append texte_svg ".parkcircle{fill:none;stroke:#FC00E7;stroke-width:2.0}\n"
		append texte_svg ".labeldate{fill:#fc9600;text-anchor:start;font-family:Courgette;font-size:16px;font-weight: bold}\n"
		append texte_svg ".labelpark{fill:#FC00E7;text-anchor:start;font-family:Courgette;font-size:16px;font-weight: bold}\n"
		append texte_svg "\]\]>\n"
		append texte_svg "</style>\n"
		append texte_svg "<circle id='circle' cx='0' cy='0' r='10px' />\n"
		append texte_svg "<circle id='scircle' cx='0' cy='0' r='5px' />\n"
		append texte_svg "<circle id='zcircle' cx='0' cy='0' r='1px' />\n"
		append texte_svg "</defs><g transform='scale(1)' >\n"
		append texte_svg "<image x='0' y='0' width='${width}' height='${height}' xlink:href='ImageLastFTP_AllSKY.jpg' />\n"
		append texte_svg "<use xlink:href='#circle' class='${circle_color}' transform='translate(${x},${y})'/>\n"
		append texte_svg "<use xlink:href='#scircle' class='verifcircle' transform='translate(${xs},${ys})'/>\n"
		append texte_svg "<use xlink:href='#zcircle' class='verifcircle' transform='translate(${xz},${yz})'/>\n"
		append texte_svg "<text class='${label_color}' x='${xt}' y='${yt}'>${date_obs}</text>\n"
		append texte_svg "</g></svg>\n"
		set path c:/srv/www/htdocs/allsky/
		file mkdir $path
		set fic ${path}/ImageLastFTP_AllSKY.svg
		set f [open $fic w]
		puts -nonewline $f $texte_svg
		close $f
	}

}

if {($robobs(planif,mode)=="snresearch1")&&($robobs(image,afilenames)!="")} {
   
   set catastar [lindex [buf$bufNo getkwd CATASTAR] 1]
   if {$catastar>=3} {
      set objename [string trim [lindex [buf$bufNo getkwd OBJENAME] 1]]
   	file mkdir "$robobs(conf,folders,rep_images,value)/galtocheck"
      lappend robobs(image,xfilenames) "$robobs(conf,folders,rep_images,value)/galtocheck/${objename}$robobs(conf,fichier_image,extension,value)"
   	::robobs::log "Archive $robobs(image,xfilenames)"
      saveima $robobs(image,xfilenames)
	}

}

#::robobs::log "Archive robobs(planif,mode)=$robobs(planif,mode)"
#::robobs::log "Archive robobs(image,ffilenames)=$robobs(image,filenames)"
if {($robobs(planif,mode)=="vachier_berthier")&&($robobs(conf,home,telescope_id,value)=="makes_t60")} {
	# -------- PHP
	# --- update the PHP meteo script
	set date_meteo [string range [mc_date2iso8601 [::audace::date_sys2ut]] 0 18]
	set texte_php ""
	append texte_php "<?php\n"
	append texte_php "\$datemeteoiso=\"$date_meteo\";\n"
	append texte_php "\$skylight=\"$robobs(private,skylight)\";\n"
	append texte_php "\$sunelev=\"[format "%0.2f" $robobs(private,sunelev)]\";\n"
	append texte_php "\$skycover=\"[::robobs::key2val $robobs(next_scene,www_infos) skycover]\";\n"
	append texte_php "\$skytempr=\"[::robobs::key2val $robobs(next_scene,www_infos) skytempr]\";\n"
	append texte_php "\$temperature=\"[::robobs::key2val $robobs(next_scene,www_infos) temperature]\";\n"
	append texte_php "\$humidity=\"[::robobs::key2val $robobs(next_scene,www_infos) humidity]\";\n"
	append texte_php "\$pressure=\"[::robobs::key2val $robobs(next_scene,www_infos) pressure]\";\n"
	append texte_php "\$water=\"[::robobs::key2val $robobs(next_scene,www_infos) water]\";\n"
	append texte_php "\$winspeed=\"[::robobs::key2val $robobs(next_scene,www_infos) winspeed]\";\n"
	append texte_php "\$windir=\"[::robobs::key2val $robobs(next_scene,www_infos) windir]\";\n"
	append texte_php "\$checkmeteo=\"$robobs(meteo,global_check)$robobs(meteo,global_comment)\";\n";
	append texte_php "?>"
	set path c:/srv/www/htdocs/
	set fic ${path}/meteo_last.php
	set f [open $fic w]
	puts -nonewline $f $texte_php
	close $f
	# -------- SVG
	if {$robobs(image,filenames)==""} {
		# --- There is no image. We take the telescope current position
		make_svg 0
	}
}

if {(($robobs(planif,mode)=="vachier_berthier")||($robobs(planif,mode)=="asteroid_light_curve")||($robobs(planif,mode)=="star_light_curve"))&&($robobs(image,filenames)!="")} {

   proc tools_gzip { fname_in {fname_out ""} } {
      if {$fname_out == ""} {
         set fname_out ${fname_in}.gz
      } else {
         if {[file extension $fname_out] != ".gz"} {
            set fname_out ${fname_out}.gz
         }
      }
      # Force l'effacement du fichier out
      file delete -force -- $fname_out
      set errnum [catch {
         if {$fname_out == "${fname_in}.gz"} {
            ::gzip $fname_in
         } else {
            file copy -force -- "$fname_in" "[file rootname $fname_out]"
            ::gzip [file rootname $fname_out]
         }
      } msgzip ]
      return [list $errnum $msgzip]
   }
	
   ::robobs::log "Archive en cours de confection"
   set fnames ""
   set fnames $robobs(image,filenames); # on reprend les images brutes
   foreach fname $fnames {
      set fullname_in "$robobs(conf,folders,rep_images,value)/${fname}$robobs(conf,fichier_image,extension,value)"
      set fullname_out "$robobs(conf,folders,rep_images,value)/${fname}.fits"
      ::robobs::log "Rename $fullname_in ==> $fullname_out"
		file rename -force -- $fullname_in $fullname_out
      ::robobs::log "Gzip the file $fullname_out"
      set commande "tools_gzip \"$fullname_out\""
      set err1 [catch {eval $commande} msg]
      ::robobs::log "Gzip returned ($err1) $msg"
   }
	
	if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
		# --- repertoire partagé PC patates
		set robobs(misc,folders,rep_bddimages,value) c:/srv/pcpatates_incoming
		# --- copie les images calibrées
		set kf 0
		foreach fname $fnames {
			set fullname_in "[lindex $robobs(image,ffilenames) $kf]"
         buf$bufNo load $fullname_in
			# -------- SVG
			make_svg 1
			# --- save a Jpeg for the web site
			if {$robobsconf(webserver)==1} {
				set n1 [buf$bufNo getpixelswidth]
				set n2 [buf$bufNo getpixelsheight]
				set quality 60
				if {$n2>480} {
					set nn2 480
					set scale_factor [expr 1./$n2*$nn2]
					buf$bufNo scale [list $scale_factor $scale_factor] 1
					set quality 70
				}
				lassign [visu1 cut] sh sb
				buf$bufNo savejpeg $robobsconf(webserver,htdocs)/robobs_last.jpg $quality $sb $sh
			}      
         buf$bufNo load $fullname_in
			# -------- PHP
			# --- update the PHP image script
			set date_obs [string range [lindex [buf$bufNo getkwd DATE-OBS] 1] 0 18]
			set texte_php ""
			append texte_php "<?php\n"
			append texte_php "\$dateobsiso=\"$date_obs\";\n"
			append texte_php "\$skylevel=\"$robobs(private,skylight)\";\n"; # TBV
			append texte_php "\$azimuth=\"[format "%0.2f" [::robobs::key2val $robobs(next_scene,www_infos) az]]\";\n"
			append texte_php "\$elevation=\"[format "%0.2f" [::robobs::key2val $robobs(next_scene,www_infos) elev]]\";\n"
			append texte_php "\$ha=\"[format %.1f [::robobs::key2val $robobs(next_scene,www_infos) ha]]\";\n"
			append texte_php "\$moon=\"[::robobs::key2val $robobs(next_scene,www_infos) moon_dist]\";\n";
			set ra [::robobs::key2val $robobs(next_scene,www_infos) ra]
			append texte_php "\$alpha=\"${ra}\";\n"
			set dec [::robobs::key2val $robobs(next_scene,www_infos) dec]
			append texte_php "\$dec=\"${dec}\";\n"
			append texte_php "\$scene=\"[lindex [buf$bufNo getkwd OBJECT] 1]\";\n"
			append texte_php "\$exposure=\"[lindex [buf$bufNo getkwd EXPOSURE] 1]\";\n"
			append texte_php "\$binning=\"[lindex [buf$bufNo getkwd BIN1] 1]\";\n"
			append texte_php "\$nbstars=\"[lindex [buf$bufNo getkwd NBSTARS] 1]\";\n"
			append texte_php "\$catastar=\"[lindex [buf$bufNo getkwd CATASTAR] 1]\";\n"
			append texte_php "\$dra=\"-0.0\";\n"; # TBD
			append texte_php "\$ddec=\"0.0\";\n"; # TBD
			append texte_php "?>"
			set path c:/srv/www/htdocs/
			set fic ${path}/robobs_last.php
			set f [open $fic w]
			puts -nonewline $f $texte_php
			close $f
			# --------
         set catastar [lindex [buf$bufNo getkwd CATASTAR] 1]
         if {$catastar==""} {
            continue
         }
         if {$catastar<3} {
            continue
         }         
			::robobs::log "Gzip the file $fullname_in"
			set commande "tools_gzip \"$fullname_in\""
			set err1 [catch {eval $commande} msg]
			::robobs::log "Gzip returned ($err1) $msg"			
			set fullname_out "$robobs(misc,folders,rep_bddimages,value)/${fname}.fits"
			::robobs::log "Copy ${fullname_in}.gz ==> ${fullname_out}.gz"
			file copy -force -- ${fullname_in}.gz ${fullname_out}.gz
			incr kf
			# --- Update the period filling of the planif.lst file
			if {($robobs(planif,mode)=="vachier_berthier")} {
				
				set ficlst [file rootname $robobs(conf_planif,vachier_berthier,input_file)].lst
				set ficlstpart [file rootname $robobs(conf_planif,vachier_berthier,input_file)].lst.part
				if {[file exists $ficlst]==1} {
					# --- read the file planif.lst
					set f [open $ficlst r]
					set lignes [split [read $f] \n]
					close $f
					# --- get the num of the object from the FITS header
					set name [lindex [buf1 getkwd OBJECT] 1]
					set expo [lindex [buf1 getkwd EXPOSURE] 1]
					set names [split $name _]
					lassign $names num name
					# --- Modify the corresponding line of the num
					set ligne_news ""
					foreach ligne $lignes {
						set valid 1
						if {[string length $ligne]<10} {
							set valid 0
						}
						if {[string index $ligne 0]=="#"} {
							set valid 0
						}
						if {$valid==1} {
							set ligne0 [split $ligne ,]
							set as ""
							foreach val $ligne0 {
								lappend as [string trim $val]
							}
							set vals $as
							if {[lindex $vals 1]==$num} {
								# Before 7/6/2018
								# #asteroid, 22,   Kalliope,    1.00000,   4.1482, 120, 1, 12				
								# lassign $vals type nume name done_h period_h exposure bin mag
								# After 7/6/2018
								# #   Type,    Num,        Nom, Magnitude, Period(h), Binning, Expo(s), Score
								# asteroid,   5147,   Maruyama,      14.9,      3.22,       2,     180,     0
								lassign $vals type nume name mag period_h bin exposure done_h 
								if {$done_h>=0} {
									set ddone_h [expr ($expo+60.)/3600./$period_h]
									set done_h [expr $done_h+$ddone_h]
									# Before 7/6/2018
									# set ligne "${type}, ${nume}, ${name}, ${done_h}, ${period_h}, ${exposure}, ${bin}, ${mag}"
									# After 7/6/2018
									set ligne "${type}, ${nume}, ${name}, ${mag}, ${period_h}, ${bin}, ${exposure}, ${done_h}"
								}
							} else {
								set valid 0
							}
						}
						append ligne_news "${ligne}\n"
					}
					# --- read the file planif.lst
					set f [open ${ficlstpart} w]
					puts -nonewline $f $ligne_news
					close $f
					file rename -force -- ${ficlstpart} ${ficlst}
				}
			}
			
			
		}
		# --- copie les images brutes
		if {1==0} {
			set kf 0
			foreach fname $fnames {
				set fullname_in "$robobs(conf,folders,rep_images,value)/${fname}.fits"
				set fullname_out "$robobs(misc,folders,rep_bddimages,value)/${fname}_raw.fits"
				::robobs::log "Copy ${fullname_in}.gz ==> ${fullname_out}.gz"
				file copy -force -- ${fullname_in}.gz ${fullname_out}.gz
				incr kf
			}
		}
   }
}

if {$robobs(planif,mode)=="trerrlyr"} {
   proc tools_gzip { fname_in {fname_out ""} } {

      if {$fname_out == ""} {
         set fname_out ${fname_in}.gz
      } else {
         if {[file extension $fname_out] != ".gz"} {
            set fname_out ${fname_out}.gz
         }
      }

      # Force l'effacement du fichier out
      file delete -force -- $fname_out

      set errnum [catch {
         if {$fname_out == "${fname_in}.gz"} {
            ::gzip $fname_in
         } else {
            file copy -force -- "$fname_in" "[file rootname $fname_out]"
            ::gzip [file rootname $fname_out]
         }
      } msgzip ]

      return [list $errnum $msgzip]
   }
   ::robobs::log "Archive en cours de confection"
   set fnames ""
   set fnames $robobs(image,filenames); # on reprend les images brutes
	set ki -1
   foreach fname $fnames {
		incr ki
		if {$ki<=0} {
			continue ; # on passe le dark comme premiere image
		}
      set fullname_in "$robobs(conf,folders,rep_images,value)/tmp${ki}$robobs(conf,fichier_image,extension,value)"
      set fullname_out "$robobs(conf,folders,rep_images,value)/${fname}.fits"
      ::robobs::log "Rename $fullname_in ==> $fullname_out"
		file rename -force -- $fullname_in $fullname_out
      ::robobs::log "Gzip the file $fullname_out"
      set commande "tools_gzip \"$fullname_out\""
      set err1 [catch {eval $commande} msg]
      ::robobs::log "Gzip returned ($err1) $msg"
		# ===
		if {$err1==0} {
			set fullname_out ${fullname_out}.gz
			buf$bufNo load $fullname_out
			set catastar [lindex [buf$bufNo getkwd CATASTAR] 1]
			if {$catastar==""} {
				continue
			}
			if {$catastar<0} {
				continue
			}         
			set a $robobs(conf,folders,rep_images,value)
			set robobs(planif,$robobs(planif,mode),www) c:/srv/www/htdocs/robobs/[string range $a end-7 end]
			file mkdir $robobs(planif,$robobs(planif,mode),www)
			set fullname_www "$robobs(planif,$robobs(planif,mode),www)/${fname}.fits.gz"
			::robobs::log "Copy $fullname_out ==> $fullname_www"
			file copy -force -- $fullname_out $fullname_www
		}
   }
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
