#
## @file sextractor.tcl
#  @brief Functions to initialize configuration files for sextractor
#  @author Alain KLOTZ
#  $Id: sextractor.tcl 13599 2016-04-04 10:24:37Z rzachantke $
#  @todo traiter pour Doxygen
#

proc sextractor_default_nnw { {filename default.nnw} } {
   set texte    ""
   append texte "NNW\n"
   append texte "# Neural Network Weights for the SExtractor star/galaxy classifier (V1.3)\n"
   append texte "# inputs: 9 for profile parameters + 1 for seeing.\n"
   append texte "# outputs:   ``Stellarity index'' (0.0 to 1.0)\n"
   append texte "# Seeing FWHM range: from 0.025 to 5.5'' (images must have 1.5 < FWHM < 5 pixels)\n"
   append texte "# Optimized for Moffat profiles with 2<= beta <= 4.\n"
   append texte "\n"
   append texte "3 10 10  1\n"
   append texte "\n"
   append texte "-1.56604e+00 -2.48265e+00 -1.44564e+00 -1.24675e+00 -9.44913e-01 -5.22453e-01  4.61342e-02  8.31957e-01  2.15505e+00  2.64769e-01\n"
   append texte "3.03477e+00  2.69561e+00  3.16188e+00  3.34497e+00  3.51885e+00  3.65570e+00  3.74856e+00  3.84541e+00  4.22811e+00  3.27734e+00\n"
   append texte "\n"
   append texte "-3.22480e-01 -2.12804e+00  6.50750e-01 -1.11242e+00 -1.40683e+00 -1.55944e+00 -1.84558e+00 -1.18946e-01  5.52395e-01 -4.36564e-01 -5.30052e+00\n"
   append texte "4.62594e-01 -3.29127e+00  1.10950e+00 -6.01857e-01  1.29492e-01  1.42290e+00  2.90741e+00  2.44058e+00 -9.19118e-01  8.42851e-01 -4.69824e+00\n"
   append texte "-2.57424e+00  8.96469e-01  8.34775e-01  2.18845e+00  2.46526e+00  8.60878e-02 -6.88080e-01 -1.33623e-02  9.30403e-02  1.64942e+00 -1.01231e+00\n"
   append texte "4.81041e+00  1.53747e+00 -1.12216e+00 -3.16008e+00 -1.67404e+00 -1.75767e+00 -1.29310e+00  5.59549e-01  8.08468e-01 -1.01592e-02 -7.54052e+00\n"
   append texte "1.01933e+01 -2.09484e+01 -1.07426e+00  9.87912e-01  6.05210e-01 -6.04535e-02 -5.87826e-01 -7.94117e-01 -4.89190e-01 -8.12710e-02 -2.07067e+01\n"
   append texte "-5.31793e+00  7.94240e+00 -4.64165e+00 -4.37436e+00 -1.55417e+00  7.54368e-01  1.09608e+00  1.45967e+00  1.62946e+00 -1.01301e+00  1.13514e-01\n"
   append texte "2.20336e-01  1.70056e+00 -5.20105e-01 -4.28330e-01  1.57258e-03 -3.36502e-01 -8.18568e-02 -7.16163e+00  8.23195e+00 -1.71561e-02 -1.13749e+01\n"
   append texte "3.75075e+00  7.25399e+00 -1.75325e+00 -2.68814e+00 -3.71128e+00 -4.62933e+00 -2.13747e+00 -1.89186e-01  1.29122e+00 -7.49380e-01  6.71712e-01\n"
   append texte "-8.41923e-01  4.64997e+00  5.65808e-01 -3.08277e-01 -1.01687e+00  1.73127e-01 -8.92130e-01  1.89044e+00 -2.75543e-01 -7.72828e-01  5.36745e-01\n"
   append texte "-3.65598e+00  7.56997e+00 -3.76373e+00 -1.74542e+00 -1.37540e-01 -5.55400e-01 -1.59195e-01  1.27910e-01  1.91906e+00  1.42119e+00 -4.35502e+00\n"
   append texte "\n"
   append texte "-1.70059e+00 -3.65695e+00  1.22367e+00 -5.74367e-01 -3.29571e+00  2.46316e+00  5.22353e+00  2.42038e+00  1.22919e+00 -9.22250e-01 -2.32028e+00\n"
   append texte "\n"
   append texte "\n"
   append texte "0.00000e+00 \n"
   append texte "1.00000e+00 \n"
   #--- Creation du fichier de configuration default.nnw
   set f [open "$filename" w]
   puts -nonewline $f $texte
   close $f
}

proc sextractor_config_param { {filename config.param} } {
   set texte    ""
   append texte "NUMBER\n"
   append texte "\n"
   append texte "#FLUX_ISO\n"
   append texte "#FLUXERR_ISO\n"
   append texte "#MAG_ISO\n"
   append texte "#MAGERR_ISO\n"
   append texte "\n"
   append texte "#FLUX_ISOCOR\n"
   append texte "#FLUXERR_ISOCOR\n"
   append texte "#MAG_ISOCOR\n"
   append texte "#MAGERR_ISOCOR\n"
   append texte "\n"
   append texte "#FLUX_APER(1)\n"
   append texte "#FLUXERR_APER(1)\n"
   append texte "#MAG_APER(1)\n"
   append texte "#MAGERR_APER(1)\n"
   append texte "\n"
   append texte "#FLUX_AUTO\n"
   append texte "#FLUXERR_AUTO\n"
   append texte "#MAG_AUTO\n"
   append texte "#MAGERR_AUTO\n"
   append texte "\n"
   append texte "FLUX_BEST\n"
   append texte "FLUXERR_BEST\n"
   append texte "MAG_BEST\n"
   append texte "MAGERR_BEST\n"
   append texte "\n"
   append texte "#KRON_RADIUS\n"
   append texte "BACKGROUND\n"
   append texte "\n"
   append texte "#THRESHOLD\n"
   append texte "#MU_THRESHOLD\n"
   append texte "#FLUX_MAX\n"
   append texte "#MU_MAX\n"
   append texte "#ISOAREA_IMAGE\n"
   append texte "#ISOAREA_WORLD\n"
   append texte "\n"
   append texte "#XPEAK_IMAGE\n"
   append texte "#YPEAK_IMAGE\n"
   append texte "\n"
   append texte "#XMIN_IMAGE\n"
   append texte "#YMIN_IMAGE\n"
   append texte "#XMAX_IMAGE\n"
   append texte "#YMAX_IMAGE\n"
   append texte "\n"
   append texte "X_IMAGE\n"
   append texte "Y_IMAGE\n"
   append texte "#X_WORLD\n"
   append texte "#Y_WORLD\n"
   append texte "#ALPHA_SKY\n"
   append texte "#DELTA_SKY\n"
   append texte "#ALPHA_J2000\n"
   append texte "#DELTA_J2000\n"
   append texte "#ALPHA_B1950\n"
   append texte "#DELTA_B1950\n"
   append texte "\n"
   append texte "X2_IMAGE\n"
   append texte "Y2_IMAGE\n"
   append texte "XY_IMAGE\n"
   append texte "#X2_WORLD\n"
   append texte "#Y2_WORLD\n"
   append texte "#XY_WORLD\n"
   append texte "\n"
   append texte "#CXX_IMAGE\n"
   append texte "#CYY_IMAGE\n"
   append texte "#CXY_IMAGE\n"
   append texte "#CXX_WORLD\n"
   append texte "#CYY_WORLD\n"
   append texte "#CXY_WORLD\n"
   append texte "\n"
   append texte "A_IMAGE\n"
   append texte "B_IMAGE\n"
   append texte "#A_WORLD\n"
   append texte "#B_WORLD\n"
   append texte "\n"
   append texte "THETA_IMAGE\n"
   append texte "#THETA_WORLD\n"
   append texte "#THETA_SKY\n"
   append texte "#THETA_J2000\n"
   append texte "#THETA_B1950\n"
   append texte "\n"
   append texte "#ELONGATION\n"
   append texte "#ELLIPTICITY\n"
   append texte "\n"
   append texte "#ERRX2_IMAGE\n"
   append texte "#ERRY2_IMAGE\n"
   append texte "#ERRXY_IMAGE\n"
   append texte "#ERRX2_WORLD\n"
   append texte "#ERRY2_WORLD\n"
   append texte "#ERRXY_WORLD\n"
   append texte "\n"
   append texte "#ERRCXX_IMAGE\n"
   append texte "#ERRCYY_IMAGE\n"
   append texte "#ERRCXY_IMAGE\n"
   append texte "#ERRCXX_WORLD\n"
   append texte "#ERRCYY_WORLD\n"
   append texte "#ERRCXY_WORLD\n"
   append texte "\n"
   append texte "#ERRA_IMAGE\n"
   append texte "#ERRB_IMAGE\n"
   append texte "#ERRA_WORLD\n"
   append texte "#ERRB_WORLD\n"
   append texte "\n"
   append texte "#ERRTHETA_IMAGE\n"
   append texte "#ERRTHETA_WORLD\n"
   append texte "#ERRTHETA_SKY\n"
   append texte "#ERRTHETA_J2000\n"
   append texte "#ERRTHETA_B1950\n"
   append texte "\n"
   append texte "FWHM_IMAGE\n"
   append texte "#FWHM_WORLD\n"
   append texte "\n"
   append texte "#ISO0\n"
   append texte "#ISO1\n"
   append texte "#ISO2\n"
   append texte "#ISO3\n"
   append texte "#ISO4\n"
   append texte "#ISO5\n"
   append texte "#ISO6\n"
   append texte "#ISO7\n"
   append texte "\n"
   append texte "FLAGS\n"
   append texte "#IMAFLAGS_ISO(1)\n"
   append texte "#NIMAFLAGS_ISO(1)\n"
   append texte "\n"
   append texte "CLASS_STAR\n"
   append texte "#VIGNET(5,5)\n"
   #--- Creation du fichier de configuration config.param
   set f [open "$filename" w]
   puts -nonewline $f $texte
   close $f
}

proc sextractor_config_sex { {filename config.sex} } {
   set tmp_dir [file dirname $filename]
   set catalog_cat [file join $tmp_dir catalog.cat]
   set config_param [file join $tmp_dir config.param]
   set default_nnw [file join $tmp_dir default.nnw]
   set texte    ""
   append texte "\n"
   append texte "# New configuration file for SExtractor V1.2b14 - > 2.0\n"
   append texte "# EB 23/07/98\n"
   append texte "# (*) indicates parameters which can be omitted from this config file.\n"
   append texte "\n"
   append texte "#-------------------------------- Catalog ------------------------------------\n"
   append texte "\n"
   append texte "CATALOG_NAME $catalog_cat # name of the output catalog\n"
   append texte "CATALOG_TYPE ASCII # \"NONE\",\"ASCII_HEAD\",\"ASCII\",\"FITS_1.0\"\n"
   append texte "          # or \"FITS_LDAC\"\n"
   append texte "\n"
   append texte "PARAMETERS_NAME $config_param   # name of the file containing catalog contents\n"
   append texte "\n"
   append texte "#------------------------------- Extraction ----------------------------------\n"
   append texte "\n"
   append texte "DETECT_TYPE  CCD      # \"CCD\" or \"PHOTO\" (*)\n"
   append texte "FLAG_IMAGE   flag.fits   # filename for an input FLAG-image\n"
   append texte "DETECT_MINAREA  5     # minimum number of pixels above threshold\n"
   append texte "DETECT_THRESH   3     # <sigmas> or <threshold>,<ZP> in mag.arcsec-2\n"
   append texte "ANALYSIS_THRESH 1.5      # <sigmas> or <threshold>,<ZP> in mag.arcsec-2\n"
   append texte "\n"
   append texte "FILTER    N     # apply filter for detection (\"Y\" or \"N\")?\n"
   append texte "FILTER_NAME  default.conv   # name of the file containing the filter\n"
   append texte "\n"
   append texte "DEBLEND_NTHRESH 32    # Number of deblending sub-thresholds\n"
   append texte "DEBLEND_MINCONT 0.0005      # Minimum contrast parameter for deblending\n"
   append texte "\n"
   append texte "CLEAN     Y     # Clean spurious detections? (Y or N)?\n"
   append texte "CLEAN_PARAM  1.0      # Cleaning efficiency\n"
   append texte "\n"
   append texte "MASK_TYPE CORRECT     # type of detection MASKing: can be one of\n"
   append texte "# \"NONE\", \"BLANK\" or \"CORRECT\"\n"
   append texte "\n"
   append texte "#------------------------------ Photometry -----------------------------------\n"
   append texte "\n"
   append texte "PHOT_APERTURES  5     # MAG_APER aperture diameter(s) in pixels\n"
   append texte "PHOT_AUTOPARAMS 2.5, 3.5 # MAG_AUTO parameters: <Kron_fact>,<min_radius>\n"
   append texte "\n"
   append texte "SATUR_LEVEL  50000.0     # level (in ADUs) at which arises saturation\n"
   append texte "\n"
   append texte "MAG_ZEROPOINT   20.92    # magnitude zero-point\n"
   append texte "MAG_GAMMA 4.0      # gamma of emulsion (for photographic scans)\n"
   append texte "GAIN      2.8      # detector gain in e-/ADU.\n"
   append texte "PIXEL_SCALE  3.6      # size of pixel in arcsec (0=use FITS WCS info).\n"
   append texte "\n"
   append texte "#------------------------- Star/Galaxy Separation ----------------------------\n"
   append texte "\n"
   append texte "SEEING_FWHM  1.5      # stellar FWHM in arcsec\n"
   append texte "STARNNW_NAME $default_nnw # Neural-Network_Weight table filename\n"
   append texte "\n"
   append texte "#------------------------------ Background -----------------------------------\n"
   append texte "\n"
   append texte "BACK_SIZE 32    # Background mesh: <size> or <width>,<height>\n"
   append texte "BACK_FILTERSIZE 3     # Background filter: <size> or <width>,<height>\n"
   append texte "\n"
   append texte "BACKPHOTO_TYPE  GLOBAL      # can be \"GLOBAL\" or \"LOCAL\" (*)\n"
   append texte "BACKPHOTO_THICK 24    # thickness of the background LOCAL annulus (*)\n"
   append texte "\n"
   append texte "#------------------------------ Check Image ----------------------------------\n"
   append texte "\n"
   append texte "CHECKIMAGE_TYPE NONE     # can be one of \"NONE\", \"BACKGROUND\",\n"
   append texte "          # \"MINIBACKGROUND\", \"-BACKGROUND\", \"OBJECTS\",\n"
   append texte "          # \"-OBJECTS\", \"SEGMENTATION\", \"APERTURES\",\n"
   append texte "          # or \"FILTERED\" (*)\n"
   append texte "CHECKIMAGE_NAME check.fits  # Filename for the check-image (*)\n"
   append texte "\n"
   append texte "#--------------------- Memory (change with caution!) -------------------------\n"
   append texte "\n"
   append texte "MEMORY_OBJSTACK 2000     # number of objects in stack\n"
   append texte "MEMORY_PIXSTACK 100000      # number of pixels in stack\n"
   append texte "MEMORY_BUFSIZE  1024     # number of lines in buffer\n"
   append texte "\n"
   append texte "#----------------------------- Miscellaneous ---------------------------------\n"
   append texte "\n"
   append texte "VERBOSE_TYPE NORMAL      # can be \"QUIET\", \"NORMAL\" or \"FULL\" (*)\n"
   append texte "\n"
   append texte "#------------------------------- New Stuff -----------------------------------\n"
   append texte "#FITS_UNSIGNED Y\n"
   #--- Creation du fichier de configuration config.sex
   set f [open "$filename" w]
   puts -nonewline $f $texte
   close $f
}

proc sextractor { args } {
   set tmp_dir .
   set argc [llength $args]
   for {set k 0} {$k<[expr $argc-1]} {incr k} {
      set key [lindex $args $k]
      if {$key=="-c"} {
         set tmp_dir [file dirname [lindex $args [expr $k+1]]]
      }
   }
   set pathbin .
   catch { set pathbin [ file join $::audace(rep_gui) .. bin ] }
   set exefile [ file join ${pathbin} sextractor.exe ]
   set k [file exists "$exefile"]
   if {$k==0} {
      set exefile [ file join ${pathbin} sex.exe ]
      set k [file exists "$exefile"]
   }
   if {$k==0} {
      set exefile [ file join ${pathbin} sex ]
      set k [file exists "$exefile"]
   }
   if {$k==0} {
      set exefile [ file join ${pathbin} sextractor ]
      set k [file exists "$exefile"]
   }
   if {$k==0} {
      error "sextractor.exe not found"
   }
   set k1 [string first "-c" $args]
   set k2 [string first [ file join . config.sex ] $args]
   set arg_config_sex ""
   if {($k1<0)&&($k2<0)} {
      set arg_config_sex "-c [ file join . config.sex ]"
   }
   set ligne "exec \"$exefile\" $args $arg_config_sex"
   createFileConfigSextractor $tmp_dir
   set err [ catch {
      eval $ligne
   } msg ]
   return "$msg"
}

proc createFileConfigSextractor { args } {
   set tmp_dir .
   set argc [llength $args]
   if {$argc >= 1} {
      #--- change eventuellement le repertoire de stockage
      set tmp_dir [lindex $args 0]
   }
   #--- Creation des fichiers de configuration s'ils n'existent pas deja
   if { [ file exist [ file join $tmp_dir config.param ] ] == "0" } {
      sextractor_config_param [ file join $tmp_dir config.param ]
   }
   if { [ file exist [ file join $tmp_dir config.sex ] ] == "0" } {
      sextractor_config_sex [ file join $tmp_dir config.sex ]
   }
   if { [ file exist [ file join $tmp_dir default.nnw ] ] == "0" } {
      sextractor_default_nnw [ file join $tmp_dir default.nnw ]
   }
}

proc deleteFileConfigSextractor { args } {
   set tmp_dir .
   set argc [llength $args]
   if {$argc >= 1} {
      #--- change eventuellement le repertoire de stockage
      set tmp_dir [lindex $args 0]
   }
   #--- Suppression des fichiers de configuration s'ils existent deja
   if { [ file exist [ file join $tmp_dir config.param ] ] == "1" } {
      file delete [ file join $tmp_dir config.param ]
   }
   if { [ file exist [ file join $tmp_dir config.sex ] ] == "1" } {
      file delete [ file join $tmp_dir config.sex ]
   }
   if { [ file exist [ file join $tmp_dir default.nnw ] ] == "1" } {
      file delete [ file join $tmp_dir default.nnw ]
   }
   if { [ file exist [ file join $tmp_dir signal.sex ] ] == "1" } {
      #--- ce fichier est cree pendant l'exécution de sextractor
      file delete [ file join $tmp_dir signal.sex ]
   }
}

