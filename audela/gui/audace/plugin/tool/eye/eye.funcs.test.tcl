#
# Projet EYE
# Description : Pilotage d un chercheur electronique asservissant une monture
# Auteur : Frederic Vachier
# Mise a jour $Id: eye.funcs.test.tcl 11850 2015-04-24 21:20:14Z fredvachier $
#

   proc ::eye::get_header_img { } {

#      set file "/data/Chercheur_Electro/img_2_calib/vega111_calib_flip.fit"
#      loadima $file
      set head [buf1 getkwds]
      set head [list PIXSIZE1 PIXSIZE2 CRVAL1 CRVAL2 CRPIX1 CRPIX2 FOCLEN CROTA2 CDELT1 CDELT2]
      gren_info "$head\n"
      foreach kwd $head {
         gren_info "buf1 setkwd { [buf1 getkwd $kwd] }\n"
      }
   }


   proc ::eye::del_header_img { } {

      buf1 delkwd CD1_1
      buf1 delkwd CD1_2
      buf1 delkwd CD2_1
      buf1 delkwd CD2_2

      buf1 delkwd CDELT1
      buf1 delkwd CDELT2

   }

   proc ::eye::set_header_img { } {

      buf1 setkwd { {PIXSIZE1} 8.6 {double} { [um] Pixel size along naxis1 } { um} }
      buf1 setkwd { {PIXSIZE2} 8.4 {double} { [um] Pixel size along naxis2 } { um} }
      buf1 setkwd { {CRVAL1} 278.7879 {float} { [degree] reference coordinate for naxis1 } { degree} }
      buf1 setkwd { {CRVAL2} 38.7858 {float} { [degree] reference coordinate for naxis2 } { degree} }
      buf1 setkwd { {CRPIX1} 359 {float} { [pixel] reference pixel for naxis1 } { pixel} }
      buf1 setkwd { {CRPIX2} 287 {float} { [pixel] reference pixel for naxis2 } { pixel} }
      buf1 setkwd { {FOCLEN} 0.138 {double} { [m] Focal length } { m} }
      buf1 setkwd { {CROTA2} 0 {float} { [deg] position angle } { deg} }

   }

   proc ::eye::set_header_img_flip { } {

      buf1 setkwd { {PIXSIZE1} 8.600000001024449503 {double} { [um] Pixel size along naxis1 } { um} }
      buf1 setkwd { {PIXSIZE2} 8.400000297115180814 {double} { [um] Pixel size along naxis2 } { um} }
      buf1 setkwd { {CRVAL1} 278.777988853118984 {double} { [degree] reference coordinate for naxis1 } { degree} }
      buf1 setkwd { {CRVAL2} 38.79084603862850145 {double} { [degree] reference coordinate for naxis2 } { degree} }
      buf1 setkwd { {CRPIX1} 360 {float} { [pixel] reference pixel for naxis1 } { pixel} }
      buf1 setkwd { {CRPIX2} 288 {float} { [pixel] reference pixel for naxis2 } { pixel} }
      buf1 setkwd { {FOCLEN} 0.1388633400201799983 {double} { [m] Focal length } { m} }
      buf1 setkwd { {CROTA2} 23.8200883624807993 {double} { [deg] position angle } { deg} }

      buf1 setkwd { {CDELT1} 0.003284958303729140078 {double} { [deg/pixel] scale along naxis1 } { deg/pixel} }
      buf1 setkwd { {CDELT2} -0.003208563905182800022 {double} { [deg/pixel] scale along naxis2 } { deg/pixel} }

      buf1 setkwd { {BGMEAN} 44.75 {double} { mean value for background pixels } { adu} }
      buf1 setkwd { {BGSIGMA} 9.629358351030161245 {double} { std sigma value for background pixels } { adu} }
      buf1 setkwd { {BIN1} 1 {int} {  } { } }
      buf1 setkwd { {BIN2} 1 {int} {  } { } }
      buf1 setkwd { {BITPIX} 16 {int} { number of bits per data pixel } { } }
      buf1 setkwd { {BSCALE} 1 {int} { default scaling factor } { } }
      buf1 setkwd { {BZERO} 32768 {int} { offset data range to that of unsigned short } { } }
      buf1 setkwd { {CAMERA} {WEBCAM ICX098BQ-A libgrabber} string {  } { } }
      buf1 setkwd { {CATAFILE} {./cdummy.fit} string { Filename of catalog list } { } }
      buf1 setkwd { {CATAKEY} {2013-10-16T22:21:32:1221741084} string { Link key for catafile } { } }
      buf1 setkwd { {CATASTAR} 14 {int} { Number stars matched from catalog } { } }
      buf1 setkwd { {CMAGR} 0.9059000000000010377 {double} { [magR] m=CMAG-2.5*log(Flux) } { magR} }
      buf1 setkwd { {CONTRAST} -2.913113000000000e+06 {double} { Pixel contrast } { adu} }
      buf1 setkwd { {CTYPE1} {RA---TAN} string { Gnomonic projection } { } }
      buf1 setkwd { {CTYPE2} {DEC--TAN} string { Gnomonic projection } { } }
      buf1 setkwd { {CUNIT1} {deg     } string { Angles are degrees always } { } }
      buf1 setkwd { {CUNIT2} {deg     } string { Angles are degrees always } { } }
      buf1 setkwd { {CUTSCONT} 1 {float} { [adu] Contrast for cuts analysis } { adu} }
      buf1 setkwd { {CUTSMAX} 16 {float} { [adu] Max from cuts analysis } { adu} }
      buf1 setkwd { {CUTSMIN} 254 {float} { [adu] Min from cuts analysis } { adu} }
      buf1 setkwd { {CUTSMODE} 44.9883995056 {float} { [adu] Mode from cuts analysis } { adu} }
      buf1 setkwd { {DATAMAX} 254 {double} { maximum value for all pixels } { adu} }
      buf1 setkwd { {DATAMIN} 16 {double} { minimum value for all pixels } { adu} }
      buf1 setkwd { {DATE-END} {2013-09-20T22:02:06.630} string {  } { } }
      buf1 setkwd { {DATE-OBS} {2013-09-20T22:02:06.626} string { [ISO 8601] Start of exposure. FITS standar } { ISO 8601} }
      buf1 setkwd { {DEC} 38.6349983215 {float} { [DEC expected for CRPIX2] deg } { DEC expected for CRPIX2} }
      buf1 setkwd { {DETNAM} {        } string { Detector } { } }
      buf1 setkwd { {D_CMAGR} 3.30449073545596006 {double} { [magR] rms error for CMAGR } { magR} }
      buf1 setkwd { {D_FWHM} 0 {float} { [pixels] dispersion in FWHM } { pixels} }
      buf1 setkwd { {EQUINOX} 2000 {float} { System of equatorial coordinates } { } }
      buf1 setkwd { {EXPOSURE} 0 {float} { [s] Total time of exposure } { s} }
      buf1 setkwd { {EXTEND} {T} string { FITS dataset may contain extensions } { } }
      buf1 setkwd { {FWHM} 6.05000019073 {float} { [pixels] Full Width at Half Maximum } { pixels} }
      buf1 setkwd { {GPS-DATE} 0 {int} { 1 if datation is derived from GPS, else 0 } { } }
      buf1 setkwd { {LONPOLE} 180 {float} { [deg] Long. of the celest.NP in native coor.sys } { deg} }
      buf1 setkwd { {MEAN} 42.99944058641963807 {double} { mean value for all pixels } { adu} }
      buf1 setkwd { {MIPS-HI} 141.043579102 {float} { High cut for visualisation for MiPS } { adu} }
      buf1 setkwd { {MIPS-LO} -13.0261497498 {float} { Low cut for visualisation for MiPS } { adu} }
      buf1 setkwd { {MJD-OBS} 56555.91813224549696 {double} { [d] Start of exposure } { d} }
      buf1 setkwd { {NAXIS} 2 {int} { number of data axes } { } }
      buf1 setkwd { {NAXIS1} 720 {int} { length of data axis 1 } { } }
      buf1 setkwd { {NAXIS2} 576 {int} { length of data axis 2 } { } }
      buf1 setkwd { {NBSTARS} 14 {int} { Number stars detected } { } }
      buf1 setkwd { {OBJEFILE} {/mnt/data/Chercheur_Electro/test/idummy.fit} string {  } { } }
      buf1 setkwd { {OBJEKEY} {test    } string {  } { } }
      buf1 setkwd { {RA} 279.6162499999999795 {double} { [RA expected for CRPIX1] deg } { RA expected for CRPIX1} }
      buf1 setkwd { {RADECSYS} {FK5     } string { Mean Place IAU 1984 system } { } }
      buf1 setkwd { {RADESYS} {FK5     } string { Mean Place IAU 1984 system } { } }
      buf1 setkwd { {SIGMA} 10.59306906181945962 {double} { std sigma value for all pixels } { adu} }
      buf1 setkwd { {SIMPLE} {T} string { file does conform to FITS standard } { } }
      buf1 setkwd { {SWCREATE} {"[ ::audela::getPluginTitle ] $::audela(version)"} string { Acquisition software: http://www.audela.org/ } { } }
      buf1 setkwd { {SWMODIFY} {"[ ::audela::getPluginTitle ] $::audela(version)"} string { Processing software: http://www.audela.org/ } { } }
      buf1 setkwd { {TT1} {IMA/SERIES CUTS} string { TT History } { } }
      buf1 setkwd { {TT10} {IMA/SERIES STAT} string { TT History } { } }
      buf1 setkwd { {TT11} {IMA/SERIES STAT} string { TT History } { } }
      buf1 setkwd { {TT12} {IMA/SERIES STAT} string { TT History } { } }
      buf1 setkwd { {TT13} {IMA/SERIES INVERT} string { TT History } { } }
      buf1 setkwd { {TT14} {IMA/SERIES INVERT} string { TT History } { } }
      buf1 setkwd { {TT15} {IMA/SERIES STAT} string { TT History } { } }
      buf1 setkwd { {TT2} {IMA/SERIES STAT} string { TT History } { } }
      buf1 setkwd { {TT3} {IMA/SERIES CATCHART} string { TT History } { } }
      buf1 setkwd { {TT4} {IMA/SERIES ASTROMETRY} string { TT History } { } }
      buf1 setkwd { {TT5} {IMA/SERIES STAT} string { TT History } { } }
      buf1 setkwd { {TT6} {IMA/SERIES CATCHART} string { TT History } { } }
      buf1 setkwd { {TT7} {IMA/SERIES ASTROMETRY} string { TT History } { } }
      buf1 setkwd { {TT8} {IMA/SERIES STAT} string { TT History } { } }
      buf1 setkwd { {TT9} {IMA/SERIES STAT} string { TT History } { } }
      buf1 setkwd { {TTNAME} {OBJELIST} string { Table name } { } }

      buf1 setkwd { {CD1_1} 0.003284958303729140078 {double} { [deg/pixel] coord. transf. matrix } { deg/pixel} }
      buf1 setkwd { {CD1_2} 0 {float} { [deg/pixel] coord. transf. matrix } { deg/pixel} }
      buf1 setkwd { {CD2_1} 0 {float} { [deg/pixel] coord. transf. matrix } { deg/pixel} }
      buf1 setkwd { {CD2_2} -0.003208563905182800022 {double} { [deg/pixel] coord. transf. matrix } { deg/pixel} }
   }


   proc ::eye::set_header_img_calib_flip { } {

#      buf1 setkwd { {PIXSIZE1} 8.600000001024449503 {double} { [um] Pixel size along naxis1 } { um} }
#      buf1 setkwd { {PIXSIZE2} 8.400000297115180814 {double} { [um] Pixel size along naxis2 } { um} }
#      buf1 setkwd { {CRVAL1} 278.777988853118984 {double} { [degree] reference coordinate for naxis1 } { degree} }
#      buf1 setkwd { {CRVAL2} 38.79084603862850145 {double} { [degree] reference coordinate for naxis2 } { degree} }
#      buf1 setkwd { {CRPIX1} 360 {float} { [pixel] reference pixel for naxis1 } { pixel} }
#      buf1 setkwd { {CRPIX2} 288 {float} { [pixel] reference pixel for naxis2 } { pixel} }

#      buf1 setkwd { {FOCLEN} 0.1388633400201799983 {double} { [m] Focal length } { m} }
#      buf1 setkwd { {CROTA2} 23.8200883624807993 {double} { [deg] position angle } { deg} }

#      buf1 setkwd { {CDELT1} 0.003548407087675599803 {double} { [deg/pixel] scale along naxis1 } { deg/pixel} }
#      buf1 setkwd { {CDELT2} -0.003258991578691190164 {double} { [deg/pixel] scale along naxis2 } { deg/pixel} }
   }


